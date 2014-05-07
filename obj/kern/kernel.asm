
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
f010004b:	83 3d 80 ce 20 f0 00 	cmpl   $0x0,0xf020ce80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 ce 20 f0    	mov    %esi,0xf020ce80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 5c 6b 00 00       	call   f0106bc0 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 73 10 f0 	movl   $0xf0107300,(%esp)
f010007d:	e8 80 45 00 00       	call   f0104602 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 41 45 00 00       	call   f01045cf <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 36 87 10 f0 	movl   $0xf0108736,(%esp)
f0100095:	e8 68 45 00 00       	call   f0104602 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 c6 0f 00 00       	call   f010106c <monitor>
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
f01000ae:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 6b 73 10 f0 	movl   $0xf010736b,(%esp)
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
f01000e2:	e8 d9 6a 00 00       	call   f0106bc0 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 77 73 10 f0 	movl   $0xf0107377,(%esp)
f01000f2:	e8 0b 45 00 00       	call   f0104602 <cprintf>

	lapic_init();
f01000f7:	e8 de 6a 00 00       	call   f0106bda <lapic_init>
	env_init_percpu();
f01000fc:	e8 d0 3c 00 00       	call   f0103dd1 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 1a 45 00 00       	call   f0104620 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 b5 6a 00 00       	call   f0106bc0 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 d0 20 f0    	add    $0xf020d020,%edx
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
f0100124:	e8 47 6d 00 00       	call   f0106e70 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 12 4f 00 00       	call   f0105040 <sched_yield>

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
f0100135:	b8 08 e0 24 f0       	mov    $0xf024e008,%eax
f010013a:	2d ec b3 20 f0       	sub    $0xf020b3ec,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 ec b3 20 f0 	movl   $0xf020b3ec,(%esp)
f0100152:	e8 da 63 00 00       	call   f0106531 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 4f 05 00 00       	call   f01006ab <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 8d 73 10 f0 	movl   $0xf010738d,(%esp)
f010016b:	e8 92 44 00 00       	call   f0104602 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 32 1a 00 00       	call   f0101ba7 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 81 3c 00 00       	call   f0103dfb <env_init>
	trap_init();
f010017a:	e8 99 45 00 00       	call   f0104718 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	90                   	nop
f0100180:	e8 5c 67 00 00       	call   f01068e1 <mp_init>
	lapic_init();
f0100185:	e8 50 6a 00 00       	call   f0106bda <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010018a:	e8 a2 43 00 00       	call   f0104531 <pic_init>
f010018f:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0100196:	e8 d5 6c 00 00       	call   f0106e70 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019b:	83 3d 88 ce 20 f0 07 	cmpl   $0x7,0xf020ce88
f01001a2:	77 24                	ja     f01001c8 <i386_init+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001ab:	00 
f01001ac:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01001b3:	f0 
f01001b4:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
f01001bb:	00 
f01001bc:	c7 04 24 6b 73 10 f0 	movl   $0xf010736b,(%esp)
f01001c3:	e8 78 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c8:	b8 fa 67 10 f0       	mov    $0xf01067fa,%eax
f01001cd:	2d 80 67 10 f0       	sub    $0xf0106780,%eax
f01001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d6:	c7 44 24 04 80 67 10 	movl   $0xf0106780,0x4(%esp)
f01001dd:	f0 
f01001de:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e5:	e8 a2 63 00 00       	call   f010658c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001ea:	6b 05 c4 d3 20 f0 74 	imul   $0x74,0xf020d3c4,%eax
f01001f1:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f01001f6:	3d 20 d0 20 f0       	cmp    $0xf020d020,%eax
f01001fb:	76 62                	jbe    f010025f <i386_init+0x131>
f01001fd:	bb 20 d0 20 f0       	mov    $0xf020d020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100202:	e8 b9 69 00 00       	call   f0106bc0 <cpunum>
f0100207:	6b c0 74             	imul   $0x74,%eax,%eax
f010020a:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f010020f:	39 c3                	cmp    %eax,%ebx
f0100211:	74 39                	je     f010024c <i386_init+0x11e>

static void boot_aps(void);


void
i386_init(void)
f0100213:	89 d8                	mov    %ebx,%eax
f0100215:	2d 20 d0 20 f0       	sub    $0xf020d020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	c1 f8 02             	sar    $0x2,%eax
f010021d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100223:	c1 e0 0f             	shl    $0xf,%eax
f0100226:	8d 80 00 60 21 f0    	lea    -0xfdea000(%eax),%eax
f010022c:	a3 84 ce 20 f0       	mov    %eax,0xf020ce84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100231:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100238:	00 
f0100239:	0f b6 03             	movzbl (%ebx),%eax
f010023c:	89 04 24             	mov    %eax,(%esp)
f010023f:	e8 e4 6a 00 00       	call   f0106d28 <lapic_startap>
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
f010024f:	6b 05 c4 d3 20 f0 74 	imul   $0x74,0xf020d3c4,%eax
f0100256:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f010025b:	39 c3                	cmp    %eax,%ebx
f010025d:	72 a3                	jb     f0100202 <i386_init+0xd4>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010025f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100266:	00 
f0100267:	c7 44 24 04 cd 52 01 	movl   $0x152cd,0x4(%esp)
f010026e:	00 
f010026f:	c7 04 24 0c 76 1c f0 	movl   $0xf01c760c,(%esp)
f0100276:	e8 71 3d 00 00       	call   f0103fec <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010027b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100282:	00 
f0100283:	c7 44 24 04 3c 5f 00 	movl   $0x5f3c,0x4(%esp)
f010028a:	00 
f010028b:	c7 04 24 f3 a5 1f f0 	movl   $0xf01fa5f3,(%esp)
f0100292:	e8 55 3d 00 00       	call   f0103fec <env_create>
	// Touch all you want.
	ENV_CREATE(user_spawnhello, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100297:	e8 ba 03 00 00       	call   f0100656 <kbd_intr>
//#endif // TEST*

	
//>>>>>>> lab4
	// Schedule and run the first user environment!
	sched_yield();
f010029c:	e8 9f 4d 00 00       	call   f0105040 <sched_yield>

f01002a1 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002a1:	55                   	push   %ebp
f01002a2:	89 e5                	mov    %esp,%ebp
f01002a4:	53                   	push   %ebx
f01002a5:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002a8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002b9:	c7 04 24 a8 73 10 f0 	movl   $0xf01073a8,(%esp)
f01002c0:	e8 3d 43 00 00       	call   f0104602 <cprintf>
	vcprintf(fmt, ap);
f01002c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002c9:	8b 45 10             	mov    0x10(%ebp),%eax
f01002cc:	89 04 24             	mov    %eax,(%esp)
f01002cf:	e8 fb 42 00 00       	call   f01045cf <vcprintf>
	cprintf("\n");
f01002d4:	c7 04 24 36 87 10 f0 	movl   $0xf0108736,(%esp)
f01002db:	e8 22 43 00 00       	call   f0104602 <cprintf>
	va_end(ap);
}
f01002e0:	83 c4 14             	add    $0x14,%esp
f01002e3:	5b                   	pop    %ebx
f01002e4:	5d                   	pop    %ebp
f01002e5:	c3                   	ret    
	...

f01002f0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002f0:	55                   	push   %ebp
f01002f1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002f8:	ec                   	in     (%dx),%al
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	ec                   	in     (%dx),%al
f01002fb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002fc:	5d                   	pop    %ebp
f01002fd:	c3                   	ret    

f01002fe <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002fe:	55                   	push   %ebp
f01002ff:	89 e5                	mov    %esp,%ebp
f0100301:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100306:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100307:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010030c:	a8 01                	test   $0x1,%al
f010030e:	74 06                	je     f0100316 <serial_proc_data+0x18>
f0100310:	b2 f8                	mov    $0xf8,%dl
f0100312:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100313:	0f b6 c8             	movzbl %al,%ecx
}
f0100316:	89 c8                	mov    %ecx,%eax
f0100318:	5d                   	pop    %ebp
f0100319:	c3                   	ret    

f010031a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010031a:	55                   	push   %ebp
f010031b:	89 e5                	mov    %esp,%ebp
f010031d:	53                   	push   %ebx
f010031e:	83 ec 04             	sub    $0x4,%esp
f0100321:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100323:	eb 25                	jmp    f010034a <cons_intr+0x30>
		if (c == 0)
f0100325:	85 c0                	test   %eax,%eax
f0100327:	74 21                	je     f010034a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f0100329:	8b 15 24 c2 20 f0    	mov    0xf020c224,%edx
f010032f:	88 82 20 c0 20 f0    	mov    %al,-0xfdf3fe0(%edx)
f0100335:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100338:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010033d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100342:	0f 44 c2             	cmove  %edx,%eax
f0100345:	a3 24 c2 20 f0       	mov    %eax,0xf020c224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010034a:	ff d3                	call   *%ebx
f010034c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010034f:	75 d4                	jne    f0100325 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100351:	83 c4 04             	add    $0x4,%esp
f0100354:	5b                   	pop    %ebx
f0100355:	5d                   	pop    %ebp
f0100356:	c3                   	ret    

f0100357 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100357:	55                   	push   %ebp
f0100358:	89 e5                	mov    %esp,%ebp
f010035a:	57                   	push   %edi
f010035b:	56                   	push   %esi
f010035c:	53                   	push   %ebx
f010035d:	83 ec 2c             	sub    $0x2c,%esp
f0100360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100363:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100368:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100369:	a8 20                	test   $0x20,%al
f010036b:	75 1b                	jne    f0100388 <cons_putc+0x31>
f010036d:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100372:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100377:	e8 74 ff ff ff       	call   f01002f0 <delay>
f010037c:	89 f2                	mov    %esi,%edx
f010037e:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010037f:	a8 20                	test   $0x20,%al
f0100381:	75 05                	jne    f0100388 <cons_putc+0x31>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100383:	83 eb 01             	sub    $0x1,%ebx
f0100386:	75 ef                	jne    f0100377 <cons_putc+0x20>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100388:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100391:	89 f8                	mov    %edi,%eax
f0100393:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100394:	b2 79                	mov    $0x79,%dl
f0100396:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100397:	84 c0                	test   %al,%al
f0100399:	78 1b                	js     f01003b6 <cons_putc+0x5f>
f010039b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01003a0:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01003a5:	e8 46 ff ff ff       	call   f01002f0 <delay>
f01003aa:	89 f2                	mov    %esi,%edx
f01003ac:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ad:	84 c0                	test   %al,%al
f01003af:	78 05                	js     f01003b6 <cons_putc+0x5f>
f01003b1:	83 eb 01             	sub    $0x1,%ebx
f01003b4:	75 ef                	jne    f01003a5 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b6:	ba 78 03 00 00       	mov    $0x378,%edx
f01003bb:	89 f8                	mov    %edi,%eax
f01003bd:	ee                   	out    %al,(%dx)
f01003be:	b2 7a                	mov    $0x7a,%dl
f01003c0:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003c5:	ee                   	out    %al,(%dx)
f01003c6:	b8 08 00 00 00       	mov    $0x8,%eax
f01003cb:	ee                   	out    %al,(%dx)
extern int ncolor;

static void
cga_putc(int c)
{
	c = c + (ncolor << 8);
f01003cc:	a1 78 34 12 f0       	mov    0xf0123478,%eax
f01003d1:	c1 e0 08             	shl    $0x8,%eax
f01003d4:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003d7:	89 c1                	mov    %eax,%ecx
f01003d9:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f01003df:	89 c2                	mov    %eax,%edx
f01003e1:	80 ce 07             	or     $0x7,%dh
f01003e4:	85 c9                	test   %ecx,%ecx
f01003e6:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01003e9:	0f b6 d0             	movzbl %al,%edx
f01003ec:	83 fa 09             	cmp    $0x9,%edx
f01003ef:	74 75                	je     f0100466 <cons_putc+0x10f>
f01003f1:	83 fa 09             	cmp    $0x9,%edx
f01003f4:	7f 0c                	jg     f0100402 <cons_putc+0xab>
f01003f6:	83 fa 08             	cmp    $0x8,%edx
f01003f9:	0f 85 9b 00 00 00    	jne    f010049a <cons_putc+0x143>
f01003ff:	90                   	nop
f0100400:	eb 10                	jmp    f0100412 <cons_putc+0xbb>
f0100402:	83 fa 0a             	cmp    $0xa,%edx
f0100405:	74 39                	je     f0100440 <cons_putc+0xe9>
f0100407:	83 fa 0d             	cmp    $0xd,%edx
f010040a:	0f 85 8a 00 00 00    	jne    f010049a <cons_putc+0x143>
f0100410:	eb 36                	jmp    f0100448 <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f0100412:	0f b7 15 34 c2 20 f0 	movzwl 0xf020c234,%edx
f0100419:	66 85 d2             	test   %dx,%dx
f010041c:	0f 84 e3 00 00 00    	je     f0100505 <cons_putc+0x1ae>
			crt_pos--;
f0100422:	83 ea 01             	sub    $0x1,%edx
f0100425:	66 89 15 34 c2 20 f0 	mov    %dx,0xf020c234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010042c:	0f b7 d2             	movzwl %dx,%edx
f010042f:	b0 00                	mov    $0x0,%al
f0100431:	83 c8 20             	or     $0x20,%eax
f0100434:	8b 0d 30 c2 20 f0    	mov    0xf020c230,%ecx
f010043a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010043e:	eb 78                	jmp    f01004b8 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100440:	66 83 05 34 c2 20 f0 	addw   $0x50,0xf020c234
f0100447:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100448:	0f b7 05 34 c2 20 f0 	movzwl 0xf020c234,%eax
f010044f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100455:	c1 e8 16             	shr    $0x16,%eax
f0100458:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010045b:	c1 e0 04             	shl    $0x4,%eax
f010045e:	66 a3 34 c2 20 f0    	mov    %ax,0xf020c234
f0100464:	eb 52                	jmp    f01004b8 <cons_putc+0x161>
		break;
	case '\t':
		cons_putc(' ');
f0100466:	b8 20 00 00 00       	mov    $0x20,%eax
f010046b:	e8 e7 fe ff ff       	call   f0100357 <cons_putc>
		cons_putc(' ');
f0100470:	b8 20 00 00 00       	mov    $0x20,%eax
f0100475:	e8 dd fe ff ff       	call   f0100357 <cons_putc>
		cons_putc(' ');
f010047a:	b8 20 00 00 00       	mov    $0x20,%eax
f010047f:	e8 d3 fe ff ff       	call   f0100357 <cons_putc>
		cons_putc(' ');
f0100484:	b8 20 00 00 00       	mov    $0x20,%eax
f0100489:	e8 c9 fe ff ff       	call   f0100357 <cons_putc>
		cons_putc(' ');
f010048e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100493:	e8 bf fe ff ff       	call   f0100357 <cons_putc>
f0100498:	eb 1e                	jmp    f01004b8 <cons_putc+0x161>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010049a:	0f b7 15 34 c2 20 f0 	movzwl 0xf020c234,%edx
f01004a1:	0f b7 da             	movzwl %dx,%ebx
f01004a4:	8b 0d 30 c2 20 f0    	mov    0xf020c230,%ecx
f01004aa:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01004ae:	83 c2 01             	add    $0x1,%edx
f01004b1:	66 89 15 34 c2 20 f0 	mov    %dx,0xf020c234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004b8:	66 81 3d 34 c2 20 f0 	cmpw   $0x7cf,0xf020c234
f01004bf:	cf 07 
f01004c1:	76 42                	jbe    f0100505 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004c3:	a1 30 c2 20 f0       	mov    0xf020c230,%eax
f01004c8:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004cf:	00 
f01004d0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004da:	89 04 24             	mov    %eax,(%esp)
f01004dd:	e8 aa 60 00 00       	call   f010658c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004e2:	8b 15 30 c2 20 f0    	mov    0xf020c230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004e8:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004ed:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004f3:	83 c0 01             	add    $0x1,%eax
f01004f6:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004fb:	75 f0                	jne    f01004ed <cons_putc+0x196>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004fd:	66 83 2d 34 c2 20 f0 	subw   $0x50,0xf020c234
f0100504:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100505:	8b 0d 2c c2 20 f0    	mov    0xf020c22c,%ecx
f010050b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100510:	89 ca                	mov    %ecx,%edx
f0100512:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100513:	0f b7 35 34 c2 20 f0 	movzwl 0xf020c234,%esi
f010051a:	8d 59 01             	lea    0x1(%ecx),%ebx
f010051d:	89 f0                	mov    %esi,%eax
f010051f:	66 c1 e8 08          	shr    $0x8,%ax
f0100523:	89 da                	mov    %ebx,%edx
f0100525:	ee                   	out    %al,(%dx)
f0100526:	b8 0f 00 00 00       	mov    $0xf,%eax
f010052b:	89 ca                	mov    %ecx,%edx
f010052d:	ee                   	out    %al,(%dx)
f010052e:	89 f0                	mov    %esi,%eax
f0100530:	89 da                	mov    %ebx,%edx
f0100532:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100533:	83 c4 2c             	add    $0x2c,%esp
f0100536:	5b                   	pop    %ebx
f0100537:	5e                   	pop    %esi
f0100538:	5f                   	pop    %edi
f0100539:	5d                   	pop    %ebp
f010053a:	c3                   	ret    

f010053b <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010053b:	55                   	push   %ebp
f010053c:	89 e5                	mov    %esp,%ebp
f010053e:	53                   	push   %ebx
f010053f:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100542:	ba 64 00 00 00       	mov    $0x64,%edx
f0100547:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100548:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010054d:	a8 01                	test   $0x1,%al
f010054f:	0f 84 de 00 00 00    	je     f0100633 <kbd_proc_data+0xf8>
f0100555:	b2 60                	mov    $0x60,%dl
f0100557:	ec                   	in     (%dx),%al
f0100558:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010055a:	3c e0                	cmp    $0xe0,%al
f010055c:	75 11                	jne    f010056f <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010055e:	83 0d 28 c2 20 f0 40 	orl    $0x40,0xf020c228
		return 0;
f0100565:	bb 00 00 00 00       	mov    $0x0,%ebx
f010056a:	e9 c4 00 00 00       	jmp    f0100633 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f010056f:	84 c0                	test   %al,%al
f0100571:	79 37                	jns    f01005aa <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100573:	8b 0d 28 c2 20 f0    	mov    0xf020c228,%ecx
f0100579:	89 cb                	mov    %ecx,%ebx
f010057b:	83 e3 40             	and    $0x40,%ebx
f010057e:	83 e0 7f             	and    $0x7f,%eax
f0100581:	85 db                	test   %ebx,%ebx
f0100583:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100586:	0f b6 d2             	movzbl %dl,%edx
f0100589:	0f b6 82 00 74 10 f0 	movzbl -0xfef8c00(%edx),%eax
f0100590:	83 c8 40             	or     $0x40,%eax
f0100593:	0f b6 c0             	movzbl %al,%eax
f0100596:	f7 d0                	not    %eax
f0100598:	21 c1                	and    %eax,%ecx
f010059a:	89 0d 28 c2 20 f0    	mov    %ecx,0xf020c228
		return 0;
f01005a0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005a5:	e9 89 00 00 00       	jmp    f0100633 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01005aa:	8b 0d 28 c2 20 f0    	mov    0xf020c228,%ecx
f01005b0:	f6 c1 40             	test   $0x40,%cl
f01005b3:	74 0e                	je     f01005c3 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005b5:	89 c2                	mov    %eax,%edx
f01005b7:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005ba:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005bd:	89 0d 28 c2 20 f0    	mov    %ecx,0xf020c228
	}

	shift |= shiftcode[data];
f01005c3:	0f b6 d2             	movzbl %dl,%edx
f01005c6:	0f b6 82 00 74 10 f0 	movzbl -0xfef8c00(%edx),%eax
f01005cd:	0b 05 28 c2 20 f0    	or     0xf020c228,%eax
	shift ^= togglecode[data];
f01005d3:	0f b6 8a 00 75 10 f0 	movzbl -0xfef8b00(%edx),%ecx
f01005da:	31 c8                	xor    %ecx,%eax
f01005dc:	a3 28 c2 20 f0       	mov    %eax,0xf020c228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005e1:	89 c1                	mov    %eax,%ecx
f01005e3:	83 e1 03             	and    $0x3,%ecx
f01005e6:	8b 0c 8d 00 76 10 f0 	mov    -0xfef8a00(,%ecx,4),%ecx
f01005ed:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005f1:	a8 08                	test   $0x8,%al
f01005f3:	74 19                	je     f010060e <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005f5:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005f8:	83 fa 19             	cmp    $0x19,%edx
f01005fb:	77 05                	ja     f0100602 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005fd:	83 eb 20             	sub    $0x20,%ebx
f0100600:	eb 0c                	jmp    f010060e <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100602:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f0100605:	8d 53 20             	lea    0x20(%ebx),%edx
f0100608:	83 f9 19             	cmp    $0x19,%ecx
f010060b:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010060e:	f7 d0                	not    %eax
f0100610:	a8 06                	test   $0x6,%al
f0100612:	75 1f                	jne    f0100633 <kbd_proc_data+0xf8>
f0100614:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010061a:	75 17                	jne    f0100633 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010061c:	c7 04 24 c2 73 10 f0 	movl   $0xf01073c2,(%esp)
f0100623:	e8 da 3f 00 00       	call   f0104602 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100628:	ba 92 00 00 00       	mov    $0x92,%edx
f010062d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100632:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100633:	89 d8                	mov    %ebx,%eax
f0100635:	83 c4 14             	add    $0x14,%esp
f0100638:	5b                   	pop    %ebx
f0100639:	5d                   	pop    %ebp
f010063a:	c3                   	ret    

f010063b <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010063b:	55                   	push   %ebp
f010063c:	89 e5                	mov    %esp,%ebp
f010063e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100641:	80 3d 00 c0 20 f0 00 	cmpb   $0x0,0xf020c000
f0100648:	74 0a                	je     f0100654 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010064a:	b8 fe 02 10 f0       	mov    $0xf01002fe,%eax
f010064f:	e8 c6 fc ff ff       	call   f010031a <cons_intr>
}
f0100654:	c9                   	leave  
f0100655:	c3                   	ret    

f0100656 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010065c:	b8 3b 05 10 f0       	mov    $0xf010053b,%eax
f0100661:	e8 b4 fc ff ff       	call   f010031a <cons_intr>
}
f0100666:	c9                   	leave  
f0100667:	c3                   	ret    

f0100668 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100668:	55                   	push   %ebp
f0100669:	89 e5                	mov    %esp,%ebp
f010066b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010066e:	e8 c8 ff ff ff       	call   f010063b <serial_intr>
	kbd_intr();
f0100673:	e8 de ff ff ff       	call   f0100656 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100678:	8b 15 20 c2 20 f0    	mov    0xf020c220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010067e:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100683:	3b 15 24 c2 20 f0    	cmp    0xf020c224,%edx
f0100689:	74 1e                	je     f01006a9 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010068b:	0f b6 82 20 c0 20 f0 	movzbl -0xfdf3fe0(%edx),%eax
f0100692:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100695:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010069b:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006a0:	0f 44 d1             	cmove  %ecx,%edx
f01006a3:	89 15 20 c2 20 f0    	mov    %edx,0xf020c220
		return c;
	}
	return 0;
}
f01006a9:	c9                   	leave  
f01006aa:	c3                   	ret    

f01006ab <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006ab:	55                   	push   %ebp
f01006ac:	89 e5                	mov    %esp,%ebp
f01006ae:	57                   	push   %edi
f01006af:	56                   	push   %esi
f01006b0:	53                   	push   %ebx
f01006b1:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006b4:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006bb:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006c2:	5a a5 
	if (*cp != 0xA55A) {
f01006c4:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006cb:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006cf:	74 11                	je     f01006e2 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006d1:	c7 05 2c c2 20 f0 b4 	movl   $0x3b4,0xf020c22c
f01006d8:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006db:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006e0:	eb 16                	jmp    f01006f8 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006e2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006e9:	c7 05 2c c2 20 f0 d4 	movl   $0x3d4,0xf020c22c
f01006f0:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006f3:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006f8:	8b 0d 2c c2 20 f0    	mov    0xf020c22c,%ecx
f01006fe:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100703:	89 ca                	mov    %ecx,%edx
f0100705:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100706:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100709:	89 da                	mov    %ebx,%edx
f010070b:	ec                   	in     (%dx),%al
f010070c:	0f b6 f8             	movzbl %al,%edi
f010070f:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100712:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100717:	89 ca                	mov    %ecx,%edx
f0100719:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071a:	89 da                	mov    %ebx,%edx
f010071c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010071d:	89 35 30 c2 20 f0    	mov    %esi,0xf020c230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100723:	0f b6 d8             	movzbl %al,%ebx
f0100726:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100728:	66 89 3d 34 c2 20 f0 	mov    %di,0xf020c234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f010072f:	e8 22 ff ff ff       	call   f0100656 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100734:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f010073b:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100740:	89 04 24             	mov    %eax,(%esp)
f0100743:	e8 78 3d 00 00       	call   f01044c0 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100748:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010074d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100752:	89 da                	mov    %ebx,%edx
f0100754:	ee                   	out    %al,(%dx)
f0100755:	b2 fb                	mov    $0xfb,%dl
f0100757:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010075c:	ee                   	out    %al,(%dx)
f010075d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100762:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100767:	89 ca                	mov    %ecx,%edx
f0100769:	ee                   	out    %al,(%dx)
f010076a:	b2 f9                	mov    $0xf9,%dl
f010076c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100771:	ee                   	out    %al,(%dx)
f0100772:	b2 fb                	mov    $0xfb,%dl
f0100774:	b8 03 00 00 00       	mov    $0x3,%eax
f0100779:	ee                   	out    %al,(%dx)
f010077a:	b2 fc                	mov    $0xfc,%dl
f010077c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100781:	ee                   	out    %al,(%dx)
f0100782:	b2 f9                	mov    $0xf9,%dl
f0100784:	b8 01 00 00 00       	mov    $0x1,%eax
f0100789:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010078a:	b2 fd                	mov    $0xfd,%dl
f010078c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010078d:	3c ff                	cmp    $0xff,%al
f010078f:	0f 95 c0             	setne  %al
f0100792:	89 c6                	mov    %eax,%esi
f0100794:	a2 00 c0 20 f0       	mov    %al,0xf020c000
f0100799:	89 da                	mov    %ebx,%edx
f010079b:	ec                   	in     (%dx),%al
f010079c:	89 ca                	mov    %ecx,%edx
f010079e:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010079f:	89 f0                	mov    %esi,%eax
f01007a1:	84 c0                	test   %al,%al
f01007a3:	74 1d                	je     f01007c2 <cons_init+0x117>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f01007a5:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01007ac:	25 ef ff 00 00       	and    $0xffef,%eax
f01007b1:	89 04 24             	mov    %eax,(%esp)
f01007b4:	e8 07 3d 00 00       	call   f01044c0 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b9:	80 3d 00 c0 20 f0 00 	cmpb   $0x0,0xf020c000
f01007c0:	75 0c                	jne    f01007ce <cons_init+0x123>
		cprintf("Serial port does not exist!\n");
f01007c2:	c7 04 24 ce 73 10 f0 	movl   $0xf01073ce,(%esp)
f01007c9:	e8 34 3e 00 00       	call   f0104602 <cprintf>
}
f01007ce:	83 c4 1c             	add    $0x1c,%esp
f01007d1:	5b                   	pop    %ebx
f01007d2:	5e                   	pop    %esi
f01007d3:	5f                   	pop    %edi
f01007d4:	5d                   	pop    %ebp
f01007d5:	c3                   	ret    

f01007d6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007d6:	55                   	push   %ebp
f01007d7:	89 e5                	mov    %esp,%ebp
f01007d9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01007df:	e8 73 fb ff ff       	call   f0100357 <cons_putc>
}
f01007e4:	c9                   	leave  
f01007e5:	c3                   	ret    

f01007e6 <getchar>:

int
getchar(void)
{
f01007e6:	55                   	push   %ebp
f01007e7:	89 e5                	mov    %esp,%ebp
f01007e9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ec:	e8 77 fe ff ff       	call   f0100668 <cons_getc>
f01007f1:	85 c0                	test   %eax,%eax
f01007f3:	74 f7                	je     f01007ec <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007f5:	c9                   	leave  
f01007f6:	c3                   	ret    

f01007f7 <iscons>:

int
iscons(int fdnum)
{
f01007f7:	55                   	push   %ebp
f01007f8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ff:	5d                   	pop    %ebp
f0100800:	c3                   	ret    
	...

f0100810 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100810:	55                   	push   %ebp
f0100811:	89 e5                	mov    %esp,%ebp
f0100813:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100816:	c7 04 24 10 76 10 f0 	movl   $0xf0107610,(%esp)
f010081d:	e8 e0 3d 00 00       	call   f0104602 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100822:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100829:	00 
f010082a:	c7 04 24 9c 77 10 f0 	movl   $0xf010779c,(%esp)
f0100831:	e8 cc 3d 00 00       	call   f0104602 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100836:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010083d:	00 
f010083e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100845:	f0 
f0100846:	c7 04 24 c4 77 10 f0 	movl   $0xf01077c4,(%esp)
f010084d:	e8 b0 3d 00 00       	call   f0104602 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100852:	c7 44 24 08 f5 72 10 	movl   $0x1072f5,0x8(%esp)
f0100859:	00 
f010085a:	c7 44 24 04 f5 72 10 	movl   $0xf01072f5,0x4(%esp)
f0100861:	f0 
f0100862:	c7 04 24 e8 77 10 f0 	movl   $0xf01077e8,(%esp)
f0100869:	e8 94 3d 00 00       	call   f0104602 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010086e:	c7 44 24 08 ec b3 20 	movl   $0x20b3ec,0x8(%esp)
f0100875:	00 
f0100876:	c7 44 24 04 ec b3 20 	movl   $0xf020b3ec,0x4(%esp)
f010087d:	f0 
f010087e:	c7 04 24 0c 78 10 f0 	movl   $0xf010780c,(%esp)
f0100885:	e8 78 3d 00 00       	call   f0104602 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010088a:	c7 44 24 08 08 e0 24 	movl   $0x24e008,0x8(%esp)
f0100891:	00 
f0100892:	c7 44 24 04 08 e0 24 	movl   $0xf024e008,0x4(%esp)
f0100899:	f0 
f010089a:	c7 04 24 30 78 10 f0 	movl   $0xf0107830,(%esp)
f01008a1:	e8 5c 3d 00 00       	call   f0104602 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008a6:	b8 07 e4 24 f0       	mov    $0xf024e407,%eax
f01008ab:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008b0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008bb:	85 c0                	test   %eax,%eax
f01008bd:	0f 48 c2             	cmovs  %edx,%eax
f01008c0:	c1 f8 0a             	sar    $0xa,%eax
f01008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c7:	c7 04 24 54 78 10 f0 	movl   $0xf0107854,(%esp)
f01008ce:	e8 2f 3d 00 00       	call   f0104602 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d8:	c9                   	leave  
f01008d9:	c3                   	ret    

f01008da <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008da:	55                   	push   %ebp
f01008db:	89 e5                	mov    %esp,%ebp
f01008dd:	53                   	push   %ebx
f01008de:	83 ec 14             	sub    $0x14,%esp
f01008e1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008e6:	8b 83 04 7b 10 f0    	mov    -0xfef84fc(%ebx),%eax
f01008ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008f0:	8b 83 00 7b 10 f0    	mov    -0xfef8500(%ebx),%eax
f01008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fa:	c7 04 24 29 76 10 f0 	movl   $0xf0107629,(%esp)
f0100901:	e8 fc 3c 00 00       	call   f0104602 <cprintf>
f0100906:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100909:	83 fb 48             	cmp    $0x48,%ebx
f010090c:	75 d8                	jne    f01008e6 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010090e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100913:	83 c4 14             	add    $0x14,%esp
f0100916:	5b                   	pop    %ebx
f0100917:	5d                   	pop    %ebp
f0100918:	c3                   	ret    

f0100919 <mon_changepermission>:
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
f0100919:	55                   	push   %ebp
f010091a:	89 e5                	mov    %esp,%ebp
f010091c:	57                   	push   %edi
f010091d:	56                   	push   %esi
f010091e:	53                   	push   %ebx
f010091f:	83 ec 2c             	sub    $0x2c,%esp
f0100922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f0100925:	8b 55 08             	mov    0x8(%ebp),%edx
f0100928:	83 ea 03             	sub    $0x3,%edx
		return -1;
f010092b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f0100930:	83 fa 01             	cmp    $0x1,%edx
f0100933:	0f 87 f8 01 00 00    	ja     f0100b31 <mon_changepermission+0x218>
		return -1;

	extern pde_t *kern_pgdir;
	unsigned int num = strtol(argv[2], NULL, 16);
f0100939:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100940:	00 
f0100941:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100948:	00 
f0100949:	8b 43 08             	mov    0x8(%ebx),%eax
f010094c:	89 04 24             	mov    %eax,(%esp)
f010094f:	e8 50 5d 00 00       	call   f01066a4 <strtol>
f0100954:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f0100956:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100959:	89 44 24 08          	mov    %eax,0x8(%esp)
f010095d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100961:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0100966:	89 04 24             	mov    %eax,(%esp)
f0100969:	e8 1b 10 00 00       	call   f0101989 <page_lookup>
	if(!pageofva)
f010096e:	85 c0                	test   %eax,%eax
f0100970:	0f 84 b6 01 00 00    	je     f0100b2c <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f0100976:	c7 44 24 04 32 76 10 	movl   $0xf0107632,0x4(%esp)
f010097d:	f0 
f010097e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100981:	89 04 24             	mov    %eax,(%esp)
f0100984:	e8 d2 5a 00 00       	call   f010645b <strcmp>
	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;

	unsigned int perm = 0;
f0100989:	bf 00 00 00 00       	mov    $0x0,%edi
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f010098e:	85 c0                	test   %eax,%eax
f0100990:	75 2e                	jne    f01009c0 <mon_changepermission+0xa7>
		perm = strtol(argv[3], NULL, 16) | PTE_P;
f0100992:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100999:	00 
f010099a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009a1:	00 
f01009a2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009a5:	89 04 24             	mov    %eax,(%esp)
f01009a8:	e8 f7 5c 00 00       	call   f01066a4 <strtol>
f01009ad:	89 c7                	mov    %eax,%edi
f01009af:	83 cf 01             	or     $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f01009b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009b5:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f01009bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009be:	01 38                	add    %edi,(%eax)
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
f01009c0:	c7 44 24 04 37 76 10 	movl   $0xf0107637,0x4(%esp)
f01009c7:	f0 
f01009c8:	8b 43 04             	mov    0x4(%ebx),%eax
f01009cb:	89 04 24             	mov    %eax,(%esp)
f01009ce:	e8 88 5a 00 00       	call   f010645b <strcmp>
f01009d3:	85 c0                	test   %eax,%eax
f01009d5:	75 14                	jne    f01009eb <mon_changepermission+0xd2>
		perm = 1;
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f01009d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009da:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f01009e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009e3:	83 00 01             	addl   $0x1,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
		perm = 1;
f01009e6:	bf 01 00 00 00       	mov    $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// change
	if(strcmp(argv[1], "-change") == 0) {
f01009eb:	c7 44 24 04 3e 76 10 	movl   $0xf010763e,0x4(%esp)
f01009f2:	f0 
f01009f3:	8b 43 04             	mov    0x4(%ebx),%eax
f01009f6:	89 04 24             	mov    %eax,(%esp)
f01009f9:	e8 5d 5a 00 00       	call   f010645b <strcmp>
f01009fe:	85 c0                	test   %eax,%eax
f0100a00:	0f 85 0b 01 00 00    	jne    f0100b11 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f0100a06:	c7 44 24 04 43 87 10 	movl   $0xf0108743,0x4(%esp)
f0100a0d:	f0 
f0100a0e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a11:	89 04 24             	mov    %eax,(%esp)
f0100a14:	e8 42 5a 00 00       	call   f010645b <strcmp>
f0100a19:	85 c0                	test   %eax,%eax
f0100a1b:	75 06                	jne    f0100a23 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f0100a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a20:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f0100a23:	c7 44 24 04 54 87 10 	movl   $0xf0108754,0x4(%esp)
f0100a2a:	f0 
f0100a2b:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a2e:	89 04 24             	mov    %eax,(%esp)
f0100a31:	e8 25 5a 00 00       	call   f010645b <strcmp>
f0100a36:	85 c0                	test   %eax,%eax
f0100a38:	75 06                	jne    f0100a40 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f0100a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a3d:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100a40:	c7 44 24 04 46 76 10 	movl   $0xf0107646,0x4(%esp)
f0100a47:	f0 
f0100a48:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a4b:	89 04 24             	mov    %eax,(%esp)
f0100a4e:	e8 08 5a 00 00       	call   f010645b <strcmp>
f0100a53:	85 c0                	test   %eax,%eax
f0100a55:	75 06                	jne    f0100a5d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100a57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a5a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f0100a5d:	c7 44 24 04 a5 86 10 	movl   $0xf01086a5,0x4(%esp)
f0100a64:	f0 
f0100a65:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a68:	89 04 24             	mov    %eax,(%esp)
f0100a6b:	e8 eb 59 00 00       	call   f010645b <strcmp>
f0100a70:	85 c0                	test   %eax,%eax
f0100a72:	75 06                	jne    f0100a7a <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f0100a74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a77:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f0100a7a:	c7 44 24 04 4e 76 10 	movl   $0xf010764e,0x4(%esp)
f0100a81:	f0 
f0100a82:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a85:	89 04 24             	mov    %eax,(%esp)
f0100a88:	e8 ce 59 00 00       	call   f010645b <strcmp>
f0100a8d:	85 c0                	test   %eax,%eax
f0100a8f:	75 06                	jne    f0100a97 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f0100a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a94:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f0100a97:	c7 44 24 04 56 76 10 	movl   $0xf0107656,0x4(%esp)
f0100a9e:	f0 
f0100a9f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100aa2:	89 04 24             	mov    %eax,(%esp)
f0100aa5:	e8 b1 59 00 00       	call   f010645b <strcmp>
f0100aaa:	85 c0                	test   %eax,%eax
f0100aac:	75 06                	jne    f0100ab4 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f0100aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ab1:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f0100ab4:	c7 44 24 04 5c 76 10 	movl   $0xf010765c,0x4(%esp)
f0100abb:	f0 
f0100abc:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100abf:	89 04 24             	mov    %eax,(%esp)
f0100ac2:	e8 94 59 00 00       	call   f010645b <strcmp>
f0100ac7:	85 c0                	test   %eax,%eax
f0100ac9:	75 06                	jne    f0100ad1 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f0100acb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ace:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100ad1:	c7 44 24 04 62 76 10 	movl   $0xf0107662,0x4(%esp)
f0100ad8:	f0 
f0100ad9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100adc:	89 04 24             	mov    %eax,(%esp)
f0100adf:	e8 77 59 00 00       	call   f010645b <strcmp>
f0100ae4:	85 c0                	test   %eax,%eax
f0100ae6:	75 09                	jne    f0100af1 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100ae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aeb:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100af1:	c7 44 24 04 69 76 10 	movl   $0xf0107669,0x4(%esp)
f0100af8:	f0 
f0100af9:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100afc:	89 04 24             	mov    %eax,(%esp)
f0100aff:	e8 57 59 00 00       	call   f010645b <strcmp>
f0100b04:	85 c0                	test   %eax,%eax
f0100b06:	75 09                	jne    f0100b11 <mon_changepermission+0x1f8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_G;
f0100b08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b0b:	81 30 00 01 00 00    	xorl   $0x100,(%eax)
	}
	

	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
f0100b11:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100b15:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b19:	c7 04 24 6f 76 10 f0 	movl   $0xf010766f,(%esp)
f0100b20:	e8 dd 3a 00 00       	call   f0104602 <cprintf>
		num, perm);

	return 0;
f0100b25:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b2a:	eb 05                	jmp    f0100b31 <mon_changepermission+0x218>
	unsigned int num = strtol(argv[2], NULL, 16);

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;
f0100b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
		num, perm);

	return 0;
}
f0100b31:	83 c4 2c             	add    $0x2c,%esp
f0100b34:	5b                   	pop    %ebx
f0100b35:	5e                   	pop    %esi
f0100b36:	5f                   	pop    %edi
f0100b37:	5d                   	pop    %ebp
f0100b38:	c3                   	ret    

f0100b39 <mon_showmappings>:
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
f0100b39:	55                   	push   %ebp
f0100b3a:	89 e5                	mov    %esp,%ebp
f0100b3c:	57                   	push   %edi
f0100b3d:	56                   	push   %esi
f0100b3e:	53                   	push   %ebx
f0100b3f:	83 ec 2c             	sub    $0x2c,%esp
f0100b42:	8b 75 0c             	mov    0xc(%ebp),%esi
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
		return -1;
f0100b45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
f0100b4a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100b4e:	0f 85 a6 00 00 00    	jne    f0100bfa <mon_showmappings+0xc1>

	// Get the 2 arguments
	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
f0100b54:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b5b:	00 
f0100b5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b63:	00 
f0100b64:	8b 46 04             	mov    0x4(%esi),%eax
f0100b67:	89 04 24             	mov    %eax,(%esp)
f0100b6a:	e8 35 5b 00 00       	call   f01066a4 <strtol>
f0100b6f:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f0100b71:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b78:	00 
f0100b79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b80:	00 
f0100b81:	8b 46 08             	mov    0x8(%esi),%eax
f0100b84:	89 04 24             	mov    %eax,(%esp)
f0100b87:	e8 18 5b 00 00       	call   f01066a4 <strtol>
f0100b8c:	89 c7                	mov    %eax,%edi
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100b8e:	b8 00 00 00 00       	mov    $0x0,%eax

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100b93:	39 fb                	cmp    %edi,%ebx
f0100b95:	77 63                	ja     f0100bfa <mon_showmappings+0xc1>
		unsigned int _pte;
		struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num[0], (pte_t **)(&_pte));
f0100b97:	8d 75 e4             	lea    -0x1c(%ebp),%esi
f0100b9a:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100b9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ba2:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0100ba7:	89 04 24             	mov    %eax,(%esp)
f0100baa:	e8 da 0d 00 00       	call   f0101989 <page_lookup>

		if(!pageofva) {
f0100baf:	85 c0                	test   %eax,%eax
f0100bb1:	75 0e                	jne    f0100bc1 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f0100bb3:	c7 04 24 80 78 10 f0 	movl   $0xf0107880,(%esp)
f0100bba:	e8 43 3a 00 00       	call   f0104602 <cprintf>
			continue;
f0100bbf:	eb 2a                	jmp    f0100beb <mon_showmappings+0xb2>
		}
		pte_t pte = *((pte_t *)_pte);
f0100bc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc4:	8b 00                	mov    (%eax),%eax
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));
f0100bc6:	89 c2                	mov    %eax,%edx
f0100bc8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
f0100bce:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100bd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bd7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bdf:	c7 04 24 a8 78 10 f0 	movl   $0xf01078a8,(%esp)
f0100be6:	e8 17 3a 00 00       	call   f0104602 <cprintf>
f0100beb:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100bf1:	39 df                	cmp    %ebx,%edi
f0100bf3:	73 a5                	jae    f0100b9a <mon_showmappings+0x61>
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bfa:	83 c4 2c             	add    $0x2c,%esp
f0100bfd:	5b                   	pop    %ebx
f0100bfe:	5e                   	pop    %esi
f0100bff:	5f                   	pop    %edi
f0100c00:	5d                   	pop    %ebp
f0100c01:	c3                   	ret    

f0100c02 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100c02:	55                   	push   %ebp
f0100c03:	89 e5                	mov    %esp,%ebp
f0100c05:	57                   	push   %edi
f0100c06:	56                   	push   %esi
f0100c07:	53                   	push   %ebx
f0100c08:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100c0e:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100c10:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100c12:	8b 43 04             	mov    0x4(%ebx),%eax
f0100c15:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f0100c1b:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c1e:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f0100c24:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100c27:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f0100c2d:	8b 43 10             	mov    0x10(%ebx),%eax
f0100c30:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f0100c36:	8b 43 14             	mov    0x14(%ebx),%eax
f0100c39:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f0100c3f:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f0100c42:	c7 04 24 8b 76 10 f0 	movl   $0xf010768b,(%esp)
f0100c49:	e8 b4 39 00 00       	call   f0104602 <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100c4e:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100c53:	85 db                	test   %ebx,%ebx
f0100c55:	0f 84 f5 00 00 00    	je     f0100d50 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f0100c5b:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c61:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f0100c67:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100c6d:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100c73:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100c77:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100c7b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100c7f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c83:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100c89:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100c91:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c95:	c7 04 24 dc 78 10 f0 	movl   $0xf01078dc,(%esp)
f0100c9c:	e8 61 39 00 00       	call   f0104602 <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100ca1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ca8:	89 1c 24             	mov    %ebx,(%esp)
f0100cab:	e8 aa 4b 00 00       	call   f010585a <debuginfo_eip>
f0100cb0:	85 c0                	test   %eax,%eax
f0100cb2:	0f 88 93 00 00 00    	js     f0100d4b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100cb8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cbf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100cc5:	89 04 24             	mov    %eax,(%esp)
f0100cc8:	e8 ce 56 00 00       	call   f010639b <strcpy>

		int eip_line = info.eip_line;
f0100ccd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cd0:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f0100cd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce4:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f0100ce7:	89 3c 24             	mov    %edi,(%esp)
f0100cea:	e8 f7 56 00 00       	call   f01063e6 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100cef:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cf2:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f0100cf7:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100cfa:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100cfe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100d02:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100d08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d0c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100d12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d16:	c7 04 24 9d 76 10 f0 	movl   $0xf010769d,(%esp)
f0100d1d:	e8 e0 38 00 00       	call   f0104602 <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f0100d22:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f0100d24:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f0100d27:	8b 46 08             	mov    0x8(%esi),%eax
f0100d2a:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f0100d30:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f0100d33:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f0100d36:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f0100d39:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100d3c:	85 f6                	test   %esi,%esi
f0100d3e:	0f 85 2f ff ff ff    	jne    f0100c73 <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100d44:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d49:	eb 05                	jmp    f0100d50 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f0100d4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100d50:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f0100d56:	5b                   	pop    %ebx
f0100d57:	5e                   	pop    %esi
f0100d58:	5f                   	pop    %edi
f0100d59:	5d                   	pop    %ebp
f0100d5a:	c3                   	ret    

f0100d5b <mon_dump>:
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100d5b:	55                   	push   %ebp
f0100d5c:	89 e5                	mov    %esp,%ebp
f0100d5e:	57                   	push   %edi
f0100d5f:	56                   	push   %esi
f0100d60:	53                   	push   %ebx
f0100d61:	83 ec 3c             	sub    $0x3c,%esp
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
f0100d64:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d68:	0f 85 ea 02 00 00    	jne    f0101058 <mon_dump+0x2fd>
		return -1;
	
	unsigned int addr = strtol(argv[2], NULL, 16);
f0100d6e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d75:	00 
f0100d76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d7d:	00 
f0100d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d81:	8b 42 08             	mov    0x8(%edx),%eax
f0100d84:	89 04 24             	mov    %eax,(%esp)
f0100d87:	e8 18 59 00 00       	call   f01066a4 <strtol>
f0100d8c:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100d8e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d95:	00 
f0100d96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d9d:	00 
f0100d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100da1:	8b 42 0c             	mov    0xc(%edx),%eax
f0100da4:	89 04 24             	mov    %eax,(%esp)
f0100da7:	e8 f8 58 00 00       	call   f01066a4 <strtol>
f0100dac:	89 45 d0             	mov    %eax,-0x30(%ebp)

	if(argv[1][1] == 'v') {
f0100daf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100db2:	8b 42 04             	mov    0x4(%edx),%eax
f0100db5:	80 78 01 76          	cmpb   $0x76,0x1(%eax)
f0100db9:	0f 85 af 00 00 00    	jne    f0100e6e <mon_dump+0x113>
		int i;
		for(i=0; i<len; i++) {
f0100dbf:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100dc3:	0f 84 a5 00 00 00    	je     f0100e6e <mon_dump+0x113>
f0100dc9:	89 df                	mov    %ebx,%edi
f0100dcb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd0:	be 00 00 00 00       	mov    $0x0,%esi
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100dd5:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100dd8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100ddb:	a8 03                	test   $0x3,%al
f0100ddd:	75 10                	jne    f0100def <mon_dump+0x94>
				cprintf("Virtual Address 0x%08x: ", addr + i*4);
f0100ddf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100de3:	c7 04 24 b4 76 10 f0 	movl   $0xf01076b4,(%esp)
f0100dea:	e8 13 38 00 00       	call   f0104602 <cprintf>

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100def:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100df2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100df6:	89 f8                	mov    %edi,%eax
f0100df8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
f0100dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e01:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0100e06:	89 04 24             	mov    %eax,(%esp)
f0100e09:	e8 7b 0b 00 00       	call   f0101989 <page_lookup>
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
			if(_pte && (*(pte_t *)_pte&PTE_P))
f0100e0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e11:	85 c0                	test   %eax,%eax
f0100e13:	74 19                	je     f0100e2e <mon_dump+0xd3>
f0100e15:	f6 00 01             	testb  $0x1,(%eax)
f0100e18:	74 14                	je     f0100e2e <mon_dump+0xd3>
				cprintf("0x%08x ", *(uint32_t *)(addr + i*4));
f0100e1a:	8b 07                	mov    (%edi),%eax
f0100e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e20:	c7 04 24 cd 76 10 f0 	movl   $0xf01076cd,(%esp)
f0100e27:	e8 d6 37 00 00       	call   f0104602 <cprintf>
f0100e2c:	eb 0c                	jmp    f0100e3a <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100e2e:	c7 04 24 d5 76 10 f0 	movl   $0xf01076d5,(%esp)
f0100e35:	e8 c8 37 00 00       	call   f0104602 <cprintf>
			if(i % 4 == 3)
f0100e3a:	89 f0                	mov    %esi,%eax
f0100e3c:	c1 f8 1f             	sar    $0x1f,%eax
f0100e3f:	c1 e8 1e             	shr    $0x1e,%eax
f0100e42:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100e45:	83 e2 03             	and    $0x3,%edx
f0100e48:	29 c2                	sub    %eax,%edx
f0100e4a:	83 fa 03             	cmp    $0x3,%edx
f0100e4d:	75 0c                	jne    f0100e5b <mon_dump+0x100>
				cprintf("\n");
f0100e4f:	c7 04 24 36 87 10 f0 	movl   $0xf0108736,(%esp)
f0100e56:	e8 a7 37 00 00       	call   f0104602 <cprintf>
	unsigned int addr = strtol(argv[2], NULL, 16);
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
f0100e5b:	83 c6 01             	add    $0x1,%esi
f0100e5e:	89 f0                	mov    %esi,%eax
f0100e60:	83 c7 04             	add    $0x4,%edi
f0100e63:	39 de                	cmp    %ebx,%esi
f0100e65:	0f 85 70 ff ff ff    	jne    f0100ddb <mon_dump+0x80>
f0100e6b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e71:	8b 50 04             	mov    0x4(%eax),%edx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e74:	b8 00 00 00 00       	mov    $0x0,%eax
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100e79:	80 7a 01 70          	cmpb   $0x70,0x1(%edx)
f0100e7d:	0f 85 e1 01 00 00    	jne    f0101064 <mon_dump+0x309>
		int i;
		for(i=0; i<len; i++) {
f0100e83:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100e87:	0f 84 d2 01 00 00    	je     f010105f <mon_dump+0x304>
f0100e8d:	be 00 00 00 00       	mov    $0x0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e92:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100e97:	89 fa                	mov    %edi,%edx
f0100e99:	f7 da                	neg    %edx
f0100e9b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100e9e:	a8 03                	test   $0x3,%al
f0100ea0:	75 10                	jne    f0100eb2 <mon_dump+0x157>
				cprintf("Physical Address 0x%08x: ", addr + i*4);
f0100ea2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ea6:	c7 04 24 db 76 10 f0 	movl   $0xf01076db,(%esp)
f0100ead:	e8 50 37 00 00       	call   f0104602 <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100eb2:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0100eb7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ebc:	77 20                	ja     f0100ede <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ebe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ec2:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0100ec9:	f0 
f0100eca:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100ed1:	00 
f0100ed2:	c7 04 24 f5 76 10 f0 	movl   $0xf01076f5,(%esp)
f0100ed9:	e8 62 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ede:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100ee4:	39 d3                	cmp    %edx,%ebx
f0100ee6:	0f 82 83 00 00 00    	jb     f0100f6f <mon_dump+0x214>
f0100eec:	8d 90 00 00 40 00    	lea    0x400000(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ef2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100ef8:	77 20                	ja     f0100f1a <mon_dump+0x1bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100efa:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100efe:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0100f05:	f0 
f0100f06:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100f0d:	00 
f0100f0e:	c7 04 24 f5 76 10 f0 	movl   $0xf01076f5,(%esp)
f0100f15:	e8 26 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f1a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100f20:	39 d3                	cmp    %edx,%ebx
f0100f22:	73 4b                	jae    f0100f6f <mon_dump+0x214>
				cprintf("0x%08x ", *(uint32_t *)(_addr - PADDR((void *)pages + UPAGES)));
f0100f24:	2d 00 00 00 11       	sub    $0x11000000,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f2e:	77 20                	ja     f0100f50 <mon_dump+0x1f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f34:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0100f3b:	f0 
f0100f3c:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100f43:	00 
f0100f44:	c7 04 24 f5 76 10 f0 	movl   $0xf01076f5,(%esp)
f0100f4b:	e8 f0 f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f50:	89 da                	mov    %ebx,%edx
f0100f52:	29 c2                	sub    %eax,%edx
f0100f54:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f5e:	c7 04 24 cd 76 10 f0 	movl   $0xf01076cd,(%esp)
f0100f65:	e8 98 36 00 00       	call   f0104602 <cprintf>
f0100f6a:	e9 b0 00 00 00       	jmp    f010101f <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f6f:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100f75:	77 24                	ja     f0100f9b <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f77:	c7 44 24 0c 00 90 11 	movl   $0xf0119000,0xc(%esp)
f0100f7e:	f0 
f0100f7f:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0100f86:	f0 
f0100f87:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f8e:	00 
f0100f8f:	c7 04 24 f5 76 10 f0 	movl   $0xf01076f5,(%esp)
f0100f96:	e8 a5 f0 ff ff       	call   f0100040 <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100f9b:	81 fb 00 90 11 00    	cmp    $0x119000,%ebx
f0100fa1:	72 50                	jb     f0100ff3 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fa3:	b8 00 10 12 f0       	mov    $0xf0121000,%eax
f0100fa8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fad:	77 20                	ja     f0100fcf <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb3:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0100fba:	f0 
f0100fbb:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100fc2:	00 
f0100fc3:	c7 04 24 f5 76 10 f0 	movl   $0xf01076f5,(%esp)
f0100fca:	e8 71 f0 ff ff       	call   f0100040 <_panic>
f0100fcf:	81 fb 00 10 12 00    	cmp    $0x121000,%ebx
f0100fd5:	73 1c                	jae    f0100ff3 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100fd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100fda:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fe5:	c7 04 24 cd 76 10 f0 	movl   $0xf01076cd,(%esp)
f0100fec:	e8 11 36 00 00       	call   f0104602 <cprintf>
f0100ff1:	eb 2c                	jmp    f010101f <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100ff3:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100ff9:	77 18                	ja     f0101013 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100ffb:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0101001:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101005:	c7 04 24 cd 76 10 f0 	movl   $0xf01076cd,(%esp)
f010100c:	e8 f1 35 00 00       	call   f0104602 <cprintf>
f0101011:	eb 0c                	jmp    f010101f <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0101013:	c7 04 24 d5 76 10 f0 	movl   $0xf01076d5,(%esp)
f010101a:	e8 e3 35 00 00       	call   f0104602 <cprintf>
			if(i % 4 == 3)
f010101f:	89 f0                	mov    %esi,%eax
f0101021:	c1 f8 1f             	sar    $0x1f,%eax
f0101024:	c1 e8 1e             	shr    $0x1e,%eax
f0101027:	8d 14 06             	lea    (%esi,%eax,1),%edx
f010102a:	83 e2 03             	and    $0x3,%edx
f010102d:	29 c2                	sub    %eax,%edx
f010102f:	83 fa 03             	cmp    $0x3,%edx
f0101032:	75 0c                	jne    f0101040 <mon_dump+0x2e5>
				cprintf("\n");
f0101034:	c7 04 24 36 87 10 f0 	movl   $0xf0108736,(%esp)
f010103b:	e8 c2 35 00 00       	call   f0104602 <cprintf>
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
f0101040:	83 c6 01             	add    $0x1,%esi
f0101043:	89 f0                	mov    %esi,%eax
f0101045:	83 c3 04             	add    $0x4,%ebx
f0101048:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f010104b:	0f 85 4d fe ff ff    	jne    f0100e9e <mon_dump+0x143>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0101051:	b8 00 00 00 00       	mov    $0x0,%eax
f0101056:	eb 0c                	jmp    f0101064 <mon_dump+0x309>
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
		return -1;
f0101058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010105d:	eb 05                	jmp    f0101064 <mon_dump+0x309>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f010105f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101064:	83 c4 3c             	add    $0x3c,%esp
f0101067:	5b                   	pop    %ebx
f0101068:	5e                   	pop    %esi
f0101069:	5f                   	pop    %edi
f010106a:	5d                   	pop    %ebp
f010106b:	c3                   	ret    

f010106c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010106c:	55                   	push   %ebp
f010106d:	89 e5                	mov    %esp,%ebp
f010106f:	57                   	push   %edi
f0101070:	56                   	push   %esi
f0101071:	53                   	push   %ebx
f0101072:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;


	cprintf("Welcome to the JOS kernel monitor!\n");
f0101075:	c7 04 24 10 79 10 f0 	movl   $0xf0107910,(%esp)
f010107c:	e8 81 35 00 00       	call   f0104602 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101081:	c7 04 24 34 79 10 f0 	movl   $0xf0107934,(%esp)
f0101088:	e8 75 35 00 00       	call   f0104602 <cprintf>

	if (tf != NULL)
f010108d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101091:	74 0b                	je     f010109e <monitor+0x32>
		print_trapframe(tf);
f0101093:	8b 45 08             	mov    0x8(%ebp),%eax
f0101096:	89 04 24             	mov    %eax,(%esp)
f0101099:	e8 29 38 00 00       	call   f01048c7 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f010109e:	c7 04 24 5c 79 10 f0 	movl   $0xf010795c,(%esp)
f01010a5:	e8 58 35 00 00       	call   f0104602 <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f01010aa:	c7 04 24 90 79 10 f0 	movl   $0xf0107990,(%esp)
f01010b1:	e8 4c 35 00 00       	call   f0104602 <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f01010b6:	c7 04 24 04 77 10 f0 	movl   $0xf0107704,(%esp)
f01010bd:	e8 ae 51 00 00       	call   f0106270 <readline>
f01010c2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01010c4:	85 c0                	test   %eax,%eax
f01010c6:	74 ee                	je     f01010b6 <monitor+0x4a>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01010c8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01010cf:	be 00 00 00 00       	mov    $0x0,%esi
f01010d4:	eb 06                	jmp    f01010dc <monitor+0x70>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01010d6:	c6 03 00             	movb   $0x0,(%ebx)
f01010d9:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01010dc:	0f b6 03             	movzbl (%ebx),%eax
f01010df:	84 c0                	test   %al,%al
f01010e1:	74 6a                	je     f010114d <monitor+0xe1>
f01010e3:	0f be c0             	movsbl %al,%eax
f01010e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010ea:	c7 04 24 08 77 10 f0 	movl   $0xf0107708,(%esp)
f01010f1:	e8 e0 53 00 00       	call   f01064d6 <strchr>
f01010f6:	85 c0                	test   %eax,%eax
f01010f8:	75 dc                	jne    f01010d6 <monitor+0x6a>
			*buf++ = 0;
		if (*buf == 0)
f01010fa:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010fd:	74 4e                	je     f010114d <monitor+0xe1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01010ff:	83 fe 0f             	cmp    $0xf,%esi
f0101102:	75 16                	jne    f010111a <monitor+0xae>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101104:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010110b:	00 
f010110c:	c7 04 24 0d 77 10 f0 	movl   $0xf010770d,(%esp)
f0101113:	e8 ea 34 00 00       	call   f0104602 <cprintf>
f0101118:	eb 9c                	jmp    f01010b6 <monitor+0x4a>
			return 0;
		}
		argv[argc++] = buf;
f010111a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010111e:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0101121:	0f b6 03             	movzbl (%ebx),%eax
f0101124:	84 c0                	test   %al,%al
f0101126:	75 0c                	jne    f0101134 <monitor+0xc8>
f0101128:	eb b2                	jmp    f01010dc <monitor+0x70>
			buf++;
f010112a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010112d:	0f b6 03             	movzbl (%ebx),%eax
f0101130:	84 c0                	test   %al,%al
f0101132:	74 a8                	je     f01010dc <monitor+0x70>
f0101134:	0f be c0             	movsbl %al,%eax
f0101137:	89 44 24 04          	mov    %eax,0x4(%esp)
f010113b:	c7 04 24 08 77 10 f0 	movl   $0xf0107708,(%esp)
f0101142:	e8 8f 53 00 00       	call   f01064d6 <strchr>
f0101147:	85 c0                	test   %eax,%eax
f0101149:	74 df                	je     f010112a <monitor+0xbe>
f010114b:	eb 8f                	jmp    f01010dc <monitor+0x70>
			buf++;
	}
	argv[argc] = 0;
f010114d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101154:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101155:	85 f6                	test   %esi,%esi
f0101157:	0f 84 59 ff ff ff    	je     f01010b6 <monitor+0x4a>
f010115d:	bb 00 7b 10 f0       	mov    $0xf0107b00,%ebx
f0101162:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101167:	8b 03                	mov    (%ebx),%eax
f0101169:	89 44 24 04          	mov    %eax,0x4(%esp)
f010116d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101170:	89 04 24             	mov    %eax,(%esp)
f0101173:	e8 e3 52 00 00       	call   f010645b <strcmp>
f0101178:	85 c0                	test   %eax,%eax
f010117a:	75 24                	jne    f01011a0 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f010117c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010117f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101182:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101186:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101189:	89 54 24 04          	mov    %edx,0x4(%esp)
f010118d:	89 34 24             	mov    %esi,(%esp)
f0101190:	ff 14 85 08 7b 10 f0 	call   *-0xfef84f8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101197:	85 c0                	test   %eax,%eax
f0101199:	78 28                	js     f01011c3 <monitor+0x157>
f010119b:	e9 16 ff ff ff       	jmp    f01010b6 <monitor+0x4a>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01011a0:	83 c7 01             	add    $0x1,%edi
f01011a3:	83 c3 0c             	add    $0xc,%ebx
f01011a6:	83 ff 06             	cmp    $0x6,%edi
f01011a9:	75 bc                	jne    f0101167 <monitor+0xfb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01011ab:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011b2:	c7 04 24 2a 77 10 f0 	movl   $0xf010772a,(%esp)
f01011b9:	e8 44 34 00 00       	call   f0104602 <cprintf>
f01011be:	e9 f3 fe ff ff       	jmp    f01010b6 <monitor+0x4a>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01011c3:	83 c4 5c             	add    $0x5c,%esp
f01011c6:	5b                   	pop    %ebx
f01011c7:	5e                   	pop    %esi
f01011c8:	5f                   	pop    %edi
f01011c9:	5d                   	pop    %ebp
f01011ca:	c3                   	ret    
f01011cb:	00 00                	add    %al,(%eax)
f01011cd:	00 00                	add    %al,(%eax)
	...

f01011d0 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01011d0:	55                   	push   %ebp
f01011d1:	89 e5                	mov    %esp,%ebp
f01011d3:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01011d6:	89 d1                	mov    %edx,%ecx
f01011d8:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01011db:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f01011de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01011e3:	f6 c1 01             	test   $0x1,%cl
f01011e6:	74 57                	je     f010123f <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011e8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011ee:	89 c8                	mov    %ecx,%eax
f01011f0:	c1 e8 0c             	shr    $0xc,%eax
f01011f3:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f01011f9:	72 20                	jb     f010121b <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011fb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01011ff:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0101206:	f0 
f0101207:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f010120e:	00 
f010120f:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101216:	e8 25 ee ff ff       	call   f0100040 <_panic>
	//cprintf("**%x\n", p);
	if (!(p[PTX(va)] & PTE_P))
f010121b:	c1 ea 0c             	shr    $0xc,%edx
f010121e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101224:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f010122b:	89 c2                	mov    %eax,%edx
f010122d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	//cprintf("**%x\n\n", p[PTX(va)]);
	return PTE_ADDR(p[PTX(va)]);
f0101230:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101235:	85 d2                	test   %edx,%edx
f0101237:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010123c:	0f 44 c2             	cmove  %edx,%eax
}
f010123f:	c9                   	leave  
f0101240:	c3                   	ret    

f0101241 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101241:	55                   	push   %ebp
f0101242:	89 e5                	mov    %esp,%ebp
f0101244:	53                   	push   %ebx
f0101245:	83 ec 14             	sub    $0x14,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101248:	83 3d 3c c2 20 f0 00 	cmpl   $0x0,0xf020c23c
f010124f:	75 11                	jne    f0101262 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101251:	ba 07 f0 24 f0       	mov    $0xf024f007,%edx
f0101256:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010125c:	89 15 3c c2 20 f0    	mov    %edx,0xf020c23c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f0101262:	83 3d 00 33 12 f0 ff 	cmpl   $0xffffffff,0xf0123300
f0101269:	75 0c                	jne    f0101277 <boot_alloc+0x36>
		npages_left = npages;
f010126b:	8b 15 88 ce 20 f0    	mov    0xf020ce88,%edx
f0101271:	89 15 00 33 12 f0    	mov    %edx,0xf0123300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f0101277:	85 c0                	test   %eax,%eax
f0101279:	75 2c                	jne    f01012a7 <boot_alloc+0x66>
// !- Whether I should check here -!
		if(npages_left < 1) {
f010127b:	83 3d 00 33 12 f0 00 	cmpl   $0x0,0xf0123300
f0101282:	75 1c                	jne    f01012a0 <boot_alloc+0x5f>
			panic("Out of memory!\n");
f0101284:	c7 44 24 08 61 84 10 	movl   $0xf0108461,0x8(%esp)
f010128b:	f0 
f010128c:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0101293:	00 
f0101294:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010129b:	e8 a0 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f01012a0:	a1 3c c2 20 f0       	mov    0xf020c23c,%eax
f01012a5:	eb 4d                	jmp    f01012f4 <boot_alloc+0xb3>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f01012a7:	05 ff 0f 00 00       	add    $0xfff,%eax
f01012ac:	89 c3                	mov    %eax,%ebx
f01012ae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

		if(npages_left < srequest/PGSIZE) {
f01012b4:	89 da                	mov    %ebx,%edx
f01012b6:	c1 ea 0c             	shr    $0xc,%edx
f01012b9:	8b 0d 00 33 12 f0    	mov    0xf0123300,%ecx
f01012bf:	39 ca                	cmp    %ecx,%edx
f01012c1:	76 1c                	jbe    f01012df <boot_alloc+0x9e>
			panic("Out of memory!\n");
f01012c3:	c7 44 24 08 61 84 10 	movl   $0xf0108461,0x8(%esp)
f01012ca:	f0 
f01012cb:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
f01012d2:	00 
f01012d3:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01012da:	e8 61 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f01012df:	a1 3c c2 20 f0       	mov    0xf020c23c,%eax
		nextfree += srequest;
f01012e4:	01 c3                	add    %eax,%ebx
f01012e6:	89 1d 3c c2 20 f0    	mov    %ebx,0xf020c23c
		npages_left -= srequest/PGSIZE;
f01012ec:	29 d1                	sub    %edx,%ecx
f01012ee:	89 0d 00 33 12 f0    	mov    %ecx,0xf0123300

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
	//******************************My code ends***********************************//
}
f01012f4:	83 c4 14             	add    $0x14,%esp
f01012f7:	5b                   	pop    %ebx
f01012f8:	5d                   	pop    %ebp
f01012f9:	c3                   	ret    

f01012fa <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01012fa:	55                   	push   %ebp
f01012fb:	89 e5                	mov    %esp,%ebp
f01012fd:	83 ec 18             	sub    $0x18,%esp
f0101300:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101303:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101306:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101308:	89 04 24             	mov    %eax,(%esp)
f010130b:	e8 88 31 00 00       	call   f0104498 <mc146818_read>
f0101310:	89 c6                	mov    %eax,%esi
f0101312:	83 c3 01             	add    $0x1,%ebx
f0101315:	89 1c 24             	mov    %ebx,(%esp)
f0101318:	e8 7b 31 00 00       	call   f0104498 <mc146818_read>
f010131d:	c1 e0 08             	shl    $0x8,%eax
f0101320:	09 f0                	or     %esi,%eax
}
f0101322:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101325:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101328:	89 ec                	mov    %ebp,%esp
f010132a:	5d                   	pop    %ebp
f010132b:	c3                   	ret    

f010132c <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010132c:	55                   	push   %ebp
f010132d:	89 e5                	mov    %esp,%ebp
f010132f:	57                   	push   %edi
f0101330:	56                   	push   %esi
f0101331:	53                   	push   %ebx
f0101332:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101335:	3c 01                	cmp    $0x1,%al
f0101337:	19 f6                	sbb    %esi,%esi
f0101339:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010133f:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101342:	8b 1d 40 c2 20 f0    	mov    0xf020c240,%ebx
f0101348:	85 db                	test   %ebx,%ebx
f010134a:	75 1c                	jne    f0101368 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f010134c:	c7 44 24 08 48 7b 10 	movl   $0xf0107b48,0x8(%esp)
f0101353:	f0 
f0101354:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010135b:	00 
f010135c:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101363:	e8 d8 ec ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0101368:	84 c0                	test   %al,%al
f010136a:	74 50                	je     f01013bc <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010136c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010136f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101372:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101375:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101378:	89 d8                	mov    %ebx,%eax
f010137a:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0101380:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101383:	c1 e8 16             	shr    $0x16,%eax
f0101386:	39 c6                	cmp    %eax,%esi
f0101388:	0f 96 c0             	setbe  %al
f010138b:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010138e:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101392:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101394:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101398:	8b 1b                	mov    (%ebx),%ebx
f010139a:	85 db                	test   %ebx,%ebx
f010139c:	75 da                	jne    f0101378 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010139e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01013a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01013a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01013aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01013ad:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01013af:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01013b2:	89 1d 40 c2 20 f0    	mov    %ebx,0xf020c240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013b8:	85 db                	test   %ebx,%ebx
f01013ba:	74 67                	je     f0101423 <check_page_free_list+0xf7>
f01013bc:	89 d8                	mov    %ebx,%eax
f01013be:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01013c4:	c1 f8 03             	sar    $0x3,%eax
f01013c7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01013ca:	89 c2                	mov    %eax,%edx
f01013cc:	c1 ea 16             	shr    $0x16,%edx
f01013cf:	39 d6                	cmp    %edx,%esi
f01013d1:	76 4a                	jbe    f010141d <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d3:	89 c2                	mov    %eax,%edx
f01013d5:	c1 ea 0c             	shr    $0xc,%edx
f01013d8:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01013de:	72 20                	jb     f0101400 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013e4:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01013eb:	f0 
f01013ec:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01013f3:	00 
f01013f4:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f01013fb:	e8 40 ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101400:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101407:	00 
f0101408:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f010140f:	00 
	return (void *)(pa + KERNBASE);
f0101410:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101415:	89 04 24             	mov    %eax,(%esp)
f0101418:	e8 14 51 00 00       	call   f0106531 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010141d:	8b 1b                	mov    (%ebx),%ebx
f010141f:	85 db                	test   %ebx,%ebx
f0101421:	75 99                	jne    f01013bc <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101423:	b8 00 00 00 00       	mov    $0x0,%eax
f0101428:	e8 14 fe ff ff       	call   f0101241 <boot_alloc>
f010142d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101430:	8b 15 40 c2 20 f0    	mov    0xf020c240,%edx
f0101436:	85 d2                	test   %edx,%edx
f0101438:	0f 84 2f 02 00 00    	je     f010166d <check_page_free_list+0x341>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010143e:	8b 1d 90 ce 20 f0    	mov    0xf020ce90,%ebx
f0101444:	39 da                	cmp    %ebx,%edx
f0101446:	72 51                	jb     f0101499 <check_page_free_list+0x16d>
		assert(pp < pages + npages);
f0101448:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f010144d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101450:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101453:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101456:	39 c2                	cmp    %eax,%edx
f0101458:	73 68                	jae    f01014c2 <check_page_free_list+0x196>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010145a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010145d:	89 d0                	mov    %edx,%eax
f010145f:	29 d8                	sub    %ebx,%eax
f0101461:	a8 07                	test   $0x7,%al
f0101463:	0f 85 86 00 00 00    	jne    f01014ef <check_page_free_list+0x1c3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101469:	c1 f8 03             	sar    $0x3,%eax
f010146c:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010146f:	85 c0                	test   %eax,%eax
f0101471:	0f 84 a6 00 00 00    	je     f010151d <check_page_free_list+0x1f1>
		assert(page2pa(pp) != IOPHYSMEM);
f0101477:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010147c:	0f 84 c6 00 00 00    	je     f0101548 <check_page_free_list+0x21c>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101482:	be 00 00 00 00       	mov    $0x0,%esi
f0101487:	bf 00 00 00 00       	mov    $0x0,%edi
f010148c:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f010148f:	e9 d8 00 00 00       	jmp    f010156c <check_page_free_list+0x240>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101494:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0101497:	73 24                	jae    f01014bd <check_page_free_list+0x191>
f0101499:	c7 44 24 0c 7f 84 10 	movl   $0xf010847f,0xc(%esp)
f01014a0:	f0 
f01014a1:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01014a8:	f0 
f01014a9:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01014b0:	00 
f01014b1:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01014b8:	e8 83 eb ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f01014bd:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01014c0:	72 24                	jb     f01014e6 <check_page_free_list+0x1ba>
f01014c2:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f01014c9:	f0 
f01014ca:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01014d1:	f0 
f01014d2:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f01014d9:	00 
f01014da:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01014e1:	e8 5a eb ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01014e6:	89 d0                	mov    %edx,%eax
f01014e8:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01014eb:	a8 07                	test   $0x7,%al
f01014ed:	74 24                	je     f0101513 <check_page_free_list+0x1e7>
f01014ef:	c7 44 24 0c 6c 7b 10 	movl   $0xf0107b6c,0xc(%esp)
f01014f6:	f0 
f01014f7:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01014fe:	f0 
f01014ff:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0101506:	00 
f0101507:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010150e:	e8 2d eb ff ff       	call   f0100040 <_panic>
f0101513:	c1 f8 03             	sar    $0x3,%eax
f0101516:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101519:	85 c0                	test   %eax,%eax
f010151b:	75 24                	jne    f0101541 <check_page_free_list+0x215>
f010151d:	c7 44 24 0c b4 84 10 	movl   $0xf01084b4,0xc(%esp)
f0101524:	f0 
f0101525:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010152c:	f0 
f010152d:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101534:	00 
f0101535:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010153c:	e8 ff ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101541:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101546:	75 24                	jne    f010156c <check_page_free_list+0x240>
f0101548:	c7 44 24 0c c5 84 10 	movl   $0xf01084c5,0xc(%esp)
f010154f:	f0 
f0101550:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101557:	f0 
f0101558:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f010155f:	00 
f0101560:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101567:	e8 d4 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010156c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101571:	75 24                	jne    f0101597 <check_page_free_list+0x26b>
f0101573:	c7 44 24 0c a0 7b 10 	movl   $0xf0107ba0,0xc(%esp)
f010157a:	f0 
f010157b:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101582:	f0 
f0101583:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f010158a:	00 
f010158b:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101592:	e8 a9 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101597:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010159c:	75 24                	jne    f01015c2 <check_page_free_list+0x296>
f010159e:	c7 44 24 0c de 84 10 	movl   $0xf01084de,0xc(%esp)
f01015a5:	f0 
f01015a6:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01015ad:	f0 
f01015ae:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01015b5:	00 
f01015b6:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01015bd:	e8 7e ea ff ff       	call   f0100040 <_panic>
f01015c2:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01015c4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01015c9:	76 59                	jbe    f0101624 <check_page_free_list+0x2f8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015cb:	89 c3                	mov    %eax,%ebx
f01015cd:	c1 eb 0c             	shr    $0xc,%ebx
f01015d0:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f01015d3:	77 20                	ja     f01015f5 <check_page_free_list+0x2c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015d9:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01015e0:	f0 
f01015e1:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01015e8:	00 
f01015e9:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f01015f0:	e8 4b ea ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01015f5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01015fb:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01015fe:	76 24                	jbe    f0101624 <check_page_free_list+0x2f8>
f0101600:	c7 44 24 0c c4 7b 10 	movl   $0xf0107bc4,0xc(%esp)
f0101607:	f0 
f0101608:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010160f:	f0 
f0101610:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101617:	00 
f0101618:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010161f:	e8 1c ea ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101624:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101629:	75 24                	jne    f010164f <check_page_free_list+0x323>
f010162b:	c7 44 24 0c f8 84 10 	movl   $0xf01084f8,0xc(%esp)
f0101632:	f0 
f0101633:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010163a:	f0 
f010163b:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101642:	00 
f0101643:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010164a:	e8 f1 e9 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010164f:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101655:	77 05                	ja     f010165c <check_page_free_list+0x330>
			++nfree_basemem;
f0101657:	83 c7 01             	add    $0x1,%edi
f010165a:	eb 03                	jmp    f010165f <check_page_free_list+0x333>
		else
			++nfree_extmem;
f010165c:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010165f:	8b 12                	mov    (%edx),%edx
f0101661:	85 d2                	test   %edx,%edx
f0101663:	0f 85 2b fe ff ff    	jne    f0101494 <check_page_free_list+0x168>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101669:	85 ff                	test   %edi,%edi
f010166b:	7f 24                	jg     f0101691 <check_page_free_list+0x365>
f010166d:	c7 44 24 0c 15 85 10 	movl   $0xf0108515,0xc(%esp)
f0101674:	f0 
f0101675:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010167c:	f0 
f010167d:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101684:	00 
f0101685:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010168c:	e8 af e9 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101691:	85 f6                	test   %esi,%esi
f0101693:	7f 24                	jg     f01016b9 <check_page_free_list+0x38d>
f0101695:	c7 44 24 0c 27 85 10 	movl   $0xf0108527,0xc(%esp)
f010169c:	f0 
f010169d:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01016a4:	f0 
f01016a5:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01016ac:	00 
f01016ad:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01016b4:	e8 87 e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01016b9:	c7 04 24 0c 7c 10 f0 	movl   $0xf0107c0c,(%esp)
f01016c0:	e8 3d 2f 00 00       	call   f0104602 <cprintf>
}
f01016c5:	83 c4 4c             	add    $0x4c,%esp
f01016c8:	5b                   	pop    %ebx
f01016c9:	5e                   	pop    %esi
f01016ca:	5f                   	pop    %edi
f01016cb:	5d                   	pop    %ebp
f01016cc:	c3                   	ret    

f01016cd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01016cd:	55                   	push   %ebp
f01016ce:	89 e5                	mov    %esp,%ebp
f01016d0:	57                   	push   %edi
f01016d1:	56                   	push   %esi
f01016d2:	53                   	push   %ebx
f01016d3:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f01016d6:	83 3d 88 ce 20 f0 00 	cmpl   $0x0,0xf020ce88
f01016dd:	0f 85 a5 00 00 00    	jne    f0101788 <page_init+0xbb>
f01016e3:	e9 b2 00 00 00       	jmp    f010179a <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f01016e8:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f01016ed:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f01016f4:	8d 3c 30             	lea    (%eax,%esi,1),%edi
f01016f7:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f01016fd:	85 db                	test   %ebx,%ebx
f01016ff:	74 76                	je     f0101777 <page_init+0xaa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101701:	29 c7                	sub    %eax,%edi
f0101703:	c1 ff 03             	sar    $0x3,%edi
f0101706:	c1 e7 0c             	shl    $0xc,%edi
		// 4) Then extended memory [EXTPHYSMEM, ...).
		// extended memory: 0x100000~
		//   0x100000~0x115000 is allocated to kernel(0x115000 is the end of .bss segment)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		if(page2pa(&pages[i]) >= IOPHYSMEM
f0101709:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f010170f:	76 3f                	jbe    f0101750 <page_init+0x83>
			&& page2pa(&pages[i]) < ROUNDUP(PADDR(boot_alloc(0)), PGSIZE)) {	
f0101711:	b8 00 00 00 00       	mov    $0x0,%eax
f0101716:	e8 26 fb ff ff       	call   f0101241 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010171b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101720:	77 20                	ja     f0101742 <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101722:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101726:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f010172d:	f0 
f010172e:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0101735:	00 
f0101736:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010173d:	e8 fe e8 ff ff       	call   f0100040 <_panic>
f0101742:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0101747:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010174c:	39 f8                	cmp    %edi,%eax
f010174e:	77 27                	ja     f0101777 <page_init+0xaa>
			continue;	
		}
		
		if(page2pa(&pages[i]) == MPENTRY_PADDR)
f0101750:	8b 15 90 ce 20 f0    	mov    0xf020ce90,%edx
f0101756:	01 f2                	add    %esi,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101758:	89 f0                	mov    %esi,%eax
f010175a:	c1 e0 09             	shl    $0x9,%eax
f010175d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101762:	74 13                	je     f0101777 <page_init+0xaa>
			continue;
		// others is free
		pages[i].pp_link = page_free_list;
f0101764:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0101769:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f010176b:	03 35 90 ce 20 f0    	add    0xf020ce90,%esi
f0101771:	89 35 40 c2 20 f0    	mov    %esi,0xf020c240
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101777:	83 c3 01             	add    $0x1,%ebx
f010177a:	39 1d 88 ce 20 f0    	cmp    %ebx,0xf020ce88
f0101780:	0f 87 62 ff ff ff    	ja     f01016e8 <page_init+0x1b>
f0101786:	eb 12                	jmp    f010179a <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f0101788:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f010178d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101793:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101798:	eb dd                	jmp    f0101777 <page_init+0xaa>
			continue;
		// others is free
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f010179a:	83 c4 1c             	add    $0x1c,%esp
f010179d:	5b                   	pop    %ebx
f010179e:	5e                   	pop    %esi
f010179f:	5f                   	pop    %edi
f01017a0:	5d                   	pop    %ebp
f01017a1:	c3                   	ret    

f01017a2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01017a2:	55                   	push   %ebp
f01017a3:	89 e5                	mov    %esp,%ebp
f01017a5:	53                   	push   %ebx
f01017a6:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in

	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	struct PageInfo *result = NULL;
	if(page_free_list) {
f01017a9:	8b 1d 40 c2 20 f0    	mov    0xf020c240,%ebx
f01017af:	85 db                	test   %ebx,%ebx
f01017b1:	74 65                	je     f0101818 <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f01017b3:	8b 03                	mov    (%ebx),%eax
f01017b5:	a3 40 c2 20 f0       	mov    %eax,0xf020c240
		
		if(alloc_flags & ALLOC_ZERO) { 
f01017ba:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01017be:	74 58                	je     f0101818 <page_alloc+0x76>
f01017c0:	89 d8                	mov    %ebx,%eax
f01017c2:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01017c8:	c1 f8 03             	sar    $0x3,%eax
f01017cb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017ce:	89 c2                	mov    %eax,%edx
f01017d0:	c1 ea 0c             	shr    $0xc,%edx
f01017d3:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01017d9:	72 20                	jb     f01017fb <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017df:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01017e6:	f0 
f01017e7:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01017ee:	00 
f01017ef:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f01017f6:	e8 45 e8 ff ff       	call   f0100040 <_panic>
			// fill in '\0'
			memset(page2kva(result), 0, PGSIZE);
f01017fb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101802:	00 
f0101803:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010180a:	00 
	return (void *)(pa + KERNBASE);
f010180b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101810:	89 04 24             	mov    %eax,(%esp)
f0101813:	e8 19 4d 00 00       	call   f0106531 <memset>
		}
	}
	return result;
}
f0101818:	89 d8                	mov    %ebx,%eax
f010181a:	83 c4 14             	add    $0x14,%esp
f010181d:	5b                   	pop    %ebx
f010181e:	5d                   	pop    %ebp
f010181f:	c3                   	ret    

f0101820 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101820:	55                   	push   %ebp
f0101821:	89 e5                	mov    %esp,%ebp
f0101823:	83 ec 18             	sub    $0x18,%esp
f0101826:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(!pp)
f0101829:	85 c0                	test   %eax,%eax
f010182b:	75 1c                	jne    f0101849 <page_free+0x29>
		panic("page_free: invalid page to free!\n");
f010182d:	c7 44 24 08 30 7c 10 	movl   $0xf0107c30,0x8(%esp)
f0101834:	f0 
f0101835:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f010183c:	00 
f010183d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101844:	e8 f7 e7 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0101849:	8b 15 40 c2 20 f0    	mov    0xf020c240,%edx
f010184f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101851:	a3 40 c2 20 f0       	mov    %eax,0xf020c240
}
f0101856:	c9                   	leave  
f0101857:	c3                   	ret    

f0101858 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101858:	55                   	push   %ebp
f0101859:	89 e5                	mov    %esp,%ebp
f010185b:	83 ec 18             	sub    $0x18,%esp
f010185e:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101861:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101865:	83 ea 01             	sub    $0x1,%edx
f0101868:	66 89 50 04          	mov    %dx,0x4(%eax)
f010186c:	66 85 d2             	test   %dx,%dx
f010186f:	75 08                	jne    f0101879 <page_decref+0x21>
		page_free(pp);
f0101871:	89 04 24             	mov    %eax,(%esp)
f0101874:	e8 a7 ff ff ff       	call   f0101820 <page_free>
//cprintf("page_decref: success!\n");
}
f0101879:	c9                   	leave  
f010187a:	c3                   	ret    

f010187b <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010187b:	55                   	push   %ebp
f010187c:	89 e5                	mov    %esp,%ebp
f010187e:	56                   	push   %esi
f010187f:	53                   	push   %ebx
f0101880:	83 ec 10             	sub    $0x10,%esp
f0101883:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
f0101886:	89 f3                	mov    %esi,%ebx
f0101888:	c1 eb 16             	shr    $0x16,%ebx
	uintptr_t ptx = PTX(va);
	uintptr_t pgoff = PGOFF(va);

	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];
f010188b:	c1 e3 02             	shl    $0x2,%ebx
f010188e:	03 5d 08             	add    0x8(%ebp),%ebx

	if(((*pde) & PTE_P) == 0) {
f0101891:	f6 03 01             	testb  $0x1,(%ebx)
f0101894:	75 2c                	jne    f01018c2 <pgdir_walk+0x47>
		if(create == 0) 
f0101896:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010189a:	74 6c                	je     f0101908 <pgdir_walk+0x8d>
			return NULL;
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
f010189c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018a3:	e8 fa fe ff ff       	call   f01017a2 <page_alloc>
			if(pgtbl == NULL)
f01018a8:	85 c0                	test   %eax,%eax
f01018aa:	74 63                	je     f010190f <pgdir_walk+0x94>
				return NULL;
			else {
				pgtbl->pp_ref ++;
f01018ac:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b1:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01018b7:	c1 f8 03             	sar    $0x3,%eax
f01018ba:	c1 e0 0c             	shl    $0xc,%eax
				/* store in physical address*/
				*pde = page2pa(pgtbl) | PTE_U | PTE_W | PTE_P;
f01018bd:	83 c8 07             	or     $0x7,%eax
f01018c0:	89 03                	mov    %eax,(%ebx)
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01018c2:	8b 03                	mov    (%ebx),%eax
f01018c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c9:	89 c2                	mov    %eax,%edx
f01018cb:	c1 ea 0c             	shr    $0xc,%edx
f01018ce:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01018d4:	72 20                	jb     f01018f6 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018da:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01018e1:	f0 
f01018e2:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
f01018e9:	00 
f01018ea:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01018f1:	e8 4a e7 ff ff       	call   f0100040 <_panic>
{
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
	uintptr_t ptx = PTX(va);
f01018f6:	c1 ee 0a             	shr    $0xa,%esi
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01018f9:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01018ff:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return pte;
f0101906:	eb 0c                	jmp    f0101914 <pgdir_walk+0x99>
	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];

	if(((*pde) & PTE_P) == 0) {
		if(create == 0) 
			return NULL;
f0101908:	b8 00 00 00 00       	mov    $0x0,%eax
f010190d:	eb 05                	jmp    f0101914 <pgdir_walk+0x99>
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
			if(pgtbl == NULL)
				return NULL;
f010190f:	b8 00 00 00 00       	mov    $0x0,%eax
	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;

	return pte;
}
f0101914:	83 c4 10             	add    $0x10,%esp
f0101917:	5b                   	pop    %ebx
f0101918:	5e                   	pop    %esi
f0101919:	5d                   	pop    %ebp
f010191a:	c3                   	ret    

f010191b <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010191b:	55                   	push   %ebp
f010191c:	89 e5                	mov    %esp,%ebp
f010191e:	57                   	push   %edi
f010191f:	56                   	push   %esi
f0101920:	53                   	push   %ebx
f0101921:	83 ec 2c             	sub    $0x2c,%esp
f0101924:	89 c7                	mov    %eax,%edi
f0101926:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101929:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f010192f:	c1 e9 0c             	shr    $0xc,%ecx
f0101932:	85 c9                	test   %ecx,%ecx
f0101934:	74 4b                	je     f0101981 <boot_map_region+0x66>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101936:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101939:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010193e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101944:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f0101947:	8b 45 0c             	mov    0xc(%ebp),%eax
f010194a:	83 c8 01             	or     $0x1,%eax
f010194d:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f0101950:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101957:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101958:	89 d8                	mov    %ebx,%eax
f010195a:	c1 e0 0c             	shl    $0xc,%eax

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010195d:	03 45 e0             	add    -0x20(%ebp),%eax
f0101960:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101964:	89 3c 24             	mov    %edi,(%esp)
f0101967:	e8 0f ff ff ff       	call   f010187b <pgdir_walk>
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f010196c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010196f:	09 f2                	or     %esi,%edx
f0101971:	89 10                	mov    %edx,(%eax)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101973:	83 c3 01             	add    $0x1,%ebx
f0101976:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010197c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010197f:	75 cf                	jne    f0101950 <boot_map_region+0x35>
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
	}
}
f0101981:	83 c4 2c             	add    $0x2c,%esp
f0101984:	5b                   	pop    %ebx
f0101985:	5e                   	pop    %esi
f0101986:	5f                   	pop    %edi
f0101987:	5d                   	pop    %ebp
f0101988:	c3                   	ret    

f0101989 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101989:	55                   	push   %ebp
f010198a:	89 e5                	mov    %esp,%ebp
f010198c:	53                   	push   %ebx
f010198d:	83 ec 14             	sub    $0x14,%esp
f0101990:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
f0101993:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010199a:	00 
f010199b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010199e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01019a5:	89 04 24             	mov    %eax,(%esp)
f01019a8:	e8 ce fe ff ff       	call   f010187b <pgdir_walk>
	struct PageInfo *pg = NULL;
	// Check if the pte_store is zero
	if(pte_store != 0)
f01019ad:	85 db                	test   %ebx,%ebx
f01019af:	74 02                	je     f01019b3 <page_lookup+0x2a>
		*pte_store = pte;
f01019b1:	89 03                	mov    %eax,(%ebx)

	// Check if the page is mapped
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
f01019b3:	85 c0                	test   %eax,%eax
f01019b5:	74 38                	je     f01019ef <page_lookup+0x66>
f01019b7:	8b 00                	mov    (%eax),%eax
f01019b9:	a8 01                	test   $0x1,%al
f01019bb:	74 39                	je     f01019f6 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019bd:	c1 e8 0c             	shr    $0xc,%eax
f01019c0:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f01019c6:	72 1c                	jb     f01019e4 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01019c8:	c7 44 24 08 54 7c 10 	movl   $0xf0107c54,0x8(%esp)
f01019cf:	f0 
f01019d0:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01019d7:	00 
f01019d8:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f01019df:	e8 5c e6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01019e4:	c1 e0 03             	shl    $0x3,%eax
f01019e7:	03 05 90 ce 20 f0    	add    0xf020ce90,%eax
f01019ed:	eb 0c                	jmp    f01019fb <page_lookup+0x72>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
	struct PageInfo *pg = NULL;
f01019ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01019f4:	eb 05                	jmp    f01019fb <page_lookup+0x72>
f01019f6:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
		pg = pa2page(PTE_ADDR(*pte));
	}

	return pg;
}
f01019fb:	83 c4 14             	add    $0x14,%esp
f01019fe:	5b                   	pop    %ebx
f01019ff:	5d                   	pop    %ebp
f0101a00:	c3                   	ret    

f0101a01 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101a01:	55                   	push   %ebp
f0101a02:	89 e5                	mov    %esp,%ebp
f0101a04:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101a07:	e8 b4 51 00 00       	call   f0106bc0 <cpunum>
f0101a0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0101a0f:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0101a16:	74 16                	je     f0101a2e <tlb_invalidate+0x2d>
f0101a18:	e8 a3 51 00 00       	call   f0106bc0 <cpunum>
f0101a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101a20:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0101a26:	8b 55 08             	mov    0x8(%ebp),%edx
f0101a29:	39 50 60             	cmp    %edx,0x60(%eax)
f0101a2c:	75 06                	jne    f0101a34 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a31:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101a34:	c9                   	leave  
f0101a35:	c3                   	ret    

f0101a36 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101a36:	55                   	push   %ebp
f0101a37:	89 e5                	mov    %esp,%ebp
f0101a39:	83 ec 28             	sub    $0x28,%esp
f0101a3c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101a3f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101a42:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;

	// look up the pte for the va
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f0101a48:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101a4b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a53:	89 34 24             	mov    %esi,(%esp)
f0101a56:	e8 2e ff ff ff       	call   f0101989 <page_lookup>

	if(pg != NULL) {
f0101a5b:	85 c0                	test   %eax,%eax
f0101a5d:	74 1d                	je     f0101a7c <page_remove+0x46>
		// Decrease the count and free
		page_decref(pg);
f0101a5f:	89 04 24             	mov    %eax,(%esp)
f0101a62:	e8 f1 fd ff ff       	call   f0101858 <page_decref>
		// Set the pte to zero
		*pte = 0;
f0101a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		// The TLB must be invalidated if a page was formerly present at 'va'.
		tlb_invalidate(pgdir, va);
f0101a70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a74:	89 34 24             	mov    %esi,(%esp)
f0101a77:	e8 85 ff ff ff       	call   f0101a01 <tlb_invalidate>
	}
}
f0101a7c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101a7f:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101a82:	89 ec                	mov    %ebp,%esp
f0101a84:	5d                   	pop    %ebp
f0101a85:	c3                   	ret    

f0101a86 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101a86:	55                   	push   %ebp
f0101a87:	89 e5                	mov    %esp,%ebp
f0101a89:	83 ec 28             	sub    $0x28,%esp
f0101a8c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101a8f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101a92:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101a95:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a98:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
f0101a9b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101aa2:	00 
f0101aa3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aaa:	89 04 24             	mov    %eax,(%esp)
f0101aad:	e8 c9 fd ff ff       	call   f010187b <pgdir_walk>
f0101ab2:	89 c3                	mov    %eax,%ebx
	if(pte == NULL) 
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	74 66                	je     f0101b1e <page_insert+0x98>
		return -E_NO_MEM;
	// If there is already a page mapped at 'va', it should be page_remove()d.
	if(((*pte) & PTE_P) == 1) {
f0101ab8:	8b 00                	mov    (%eax),%eax
f0101aba:	a8 01                	test   $0x1,%al
f0101abc:	74 3c                	je     f0101afa <page_insert+0x74>
		//On one hand, the mapped page is pp;
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f0101abe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ac3:	89 f2                	mov    %esi,%edx
f0101ac5:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0101acb:	c1 fa 03             	sar    $0x3,%edx
f0101ace:	c1 e2 0c             	shl    $0xc,%edx
f0101ad1:	39 d0                	cmp    %edx,%eax
f0101ad3:	75 16                	jne    f0101aeb <page_insert+0x65>
			// The TLB must be invalidated if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f0101ad5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ad9:	8b 45 08             	mov    0x8(%ebp),%eax
f0101adc:	89 04 24             	mov    %eax,(%esp)
f0101adf:	e8 1d ff ff ff       	call   f0101a01 <tlb_invalidate>
			// The reference for the same page should not change(latter add one)
			pp->pp_ref --;
f0101ae4:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101ae9:	eb 0f                	jmp    f0101afa <page_insert+0x74>
		}
		//On the other hand, the mapped page is not pp;
		else
			page_remove(pgdir, va);
f0101aeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101aef:	8b 45 08             	mov    0x8(%ebp),%eax
f0101af2:	89 04 24             	mov    %eax,(%esp)
f0101af5:	e8 3c ff ff ff       	call   f0101a36 <page_remove>
	}

	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
f0101afa:	8b 45 14             	mov    0x14(%ebp),%eax
f0101afd:	83 c8 01             	or     $0x1,%eax
f0101b00:	89 f2                	mov    %esi,%edx
f0101b02:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0101b08:	c1 fa 03             	sar    $0x3,%edx
f0101b0b:	c1 e2 0c             	shl    $0xc,%edx
f0101b0e:	09 d0                	or     %edx,%eax
f0101b10:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref ++;
f0101b12:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	
	return 0;
f0101b17:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b1c:	eb 05                	jmp    f0101b23 <page_insert+0x9d>
{
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
	if(pte == NULL) 
		return -E_NO_MEM;
f0101b1e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref ++;
	
	return 0;
}
f0101b23:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101b26:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101b29:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101b2c:	89 ec                	mov    %ebp,%esp
f0101b2e:	5d                   	pop    %ebp
f0101b2f:	c3                   	ret    

f0101b30 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101b30:	55                   	push   %ebp
f0101b31:	89 e5                	mov    %esp,%ebp
f0101b33:	53                   	push   %ebx
f0101b34:	83 ec 14             	sub    $0x14,%esp
f0101b37:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

    size = ROUNDUP(pa+size, PGSIZE);
f0101b3a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101b40:	03 5d 0c             	add    0xc(%ebp),%ebx
f0101b43:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    pa = ROUNDDOWN(pa, PGSIZE);
f0101b49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    size -= pa;
f0101b4e:	29 c3                	sub    %eax,%ebx

    if (base+size >= MMIOLIM) 
f0101b50:	8b 15 04 33 12 f0    	mov    0xf0123304,%edx
f0101b56:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0101b59:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101b5f:	76 1c                	jbe    f0101b7d <mmio_map_region+0x4d>
    	panic("not enough memory");
f0101b61:	c7 44 24 08 38 85 10 	movl   $0xf0108538,0x8(%esp)
f0101b68:	f0 
f0101b69:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101b70:	00 
f0101b71:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101b78:	e8 c3 e4 ff ff       	call   f0100040 <_panic>
    
    boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101b7d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101b84:	00 
f0101b85:	89 04 24             	mov    %eax,(%esp)
f0101b88:	89 d9                	mov    %ebx,%ecx
f0101b8a:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0101b8f:	e8 87 fd ff ff       	call   f010191b <boot_map_region>
    
    base += size;
f0101b94:	a1 04 33 12 f0       	mov    0xf0123304,%eax
f0101b99:	01 c3                	add    %eax,%ebx
f0101b9b:	89 1d 04 33 12 f0    	mov    %ebx,0xf0123304
    return (void*) (base - size);
}
f0101ba1:	83 c4 14             	add    $0x14,%esp
f0101ba4:	5b                   	pop    %ebx
f0101ba5:	5d                   	pop    %ebp
f0101ba6:	c3                   	ret    

f0101ba7 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101ba7:	55                   	push   %ebp
f0101ba8:	89 e5                	mov    %esp,%ebp
f0101baa:	57                   	push   %edi
f0101bab:	56                   	push   %esi
f0101bac:	53                   	push   %ebx
f0101bad:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101bb0:	b8 15 00 00 00       	mov    $0x15,%eax
f0101bb5:	e8 40 f7 ff ff       	call   f01012fa <nvram_read>
f0101bba:	c1 e0 0a             	shl    $0xa,%eax
f0101bbd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101bc3:	85 c0                	test   %eax,%eax
f0101bc5:	0f 48 c2             	cmovs  %edx,%eax
f0101bc8:	c1 f8 0c             	sar    $0xc,%eax
f0101bcb:	a3 38 c2 20 f0       	mov    %eax,0xf020c238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101bd0:	b8 17 00 00 00       	mov    $0x17,%eax
f0101bd5:	e8 20 f7 ff ff       	call   f01012fa <nvram_read>
f0101bda:	c1 e0 0a             	shl    $0xa,%eax
f0101bdd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101be3:	85 c0                	test   %eax,%eax
f0101be5:	0f 48 c2             	cmovs  %edx,%eax
f0101be8:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101beb:	85 c0                	test   %eax,%eax
f0101bed:	74 0e                	je     f0101bfd <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101bef:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101bf5:	89 15 88 ce 20 f0    	mov    %edx,0xf020ce88
f0101bfb:	eb 0c                	jmp    f0101c09 <mem_init+0x62>
	else
		npages = npages_basemem;
f0101bfd:	8b 15 38 c2 20 f0    	mov    0xf020c238,%edx
f0101c03:	89 15 88 ce 20 f0    	mov    %edx,0xf020ce88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101c09:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101c0c:	c1 e8 0a             	shr    $0xa,%eax
f0101c0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101c13:	a1 38 c2 20 f0       	mov    0xf020c238,%eax
f0101c18:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101c1b:	c1 e8 0a             	shr    $0xa,%eax
f0101c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101c22:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f0101c27:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101c2a:	c1 e8 0a             	shr    $0xa,%eax
f0101c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c31:	c7 04 24 74 7c 10 f0 	movl   $0xf0107c74,(%esp)
f0101c38:	e8 c5 29 00 00       	call   f0104602 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101c3d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101c42:	e8 fa f5 ff ff       	call   f0101241 <boot_alloc>
f0101c47:	a3 8c ce 20 f0       	mov    %eax,0xf020ce8c
	memset(kern_pgdir, 0, PGSIZE);
f0101c4c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c53:	00 
f0101c54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c5b:	00 
f0101c5c:	89 04 24             	mov    %eax,(%esp)
f0101c5f:	e8 cd 48 00 00       	call   f0106531 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c64:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101c69:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c6e:	77 20                	ja     f0101c90 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101c70:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c74:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0101c7b:	f0 
f0101c7c:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
f0101c83:	00 
f0101c84:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101c8b:	e8 b0 e3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101c90:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c96:	83 ca 05             	or     $0x5,%edx
f0101c99:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f0101c9f:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f0101ca4:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101ca7:	e8 95 f5 ff ff       	call   f0101241 <boot_alloc>
f0101cac:	a3 90 ce 20 f0       	mov    %eax,0xf020ce90
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101cb1:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101cb6:	e8 86 f5 ff ff       	call   f0101241 <boot_alloc>
f0101cbb:	a3 48 c2 20 f0       	mov    %eax,0xf020c248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101cc0:	e8 08 fa ff ff       	call   f01016cd <page_init>

	check_page_free_list(1);
f0101cc5:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cca:	e8 5d f6 ff ff       	call   f010132c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101ccf:	83 3d 90 ce 20 f0 00 	cmpl   $0x0,0xf020ce90
f0101cd6:	75 1c                	jne    f0101cf4 <mem_init+0x14d>
		panic("'pages' is a null pointer!");
f0101cd8:	c7 44 24 08 4a 85 10 	movl   $0xf010854a,0x8(%esp)
f0101cdf:	f0 
f0101ce0:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101ce7:	00 
f0101ce8:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101cef:	e8 4c e3 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cf4:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0101cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101cfe:	85 c0                	test   %eax,%eax
f0101d00:	74 09                	je     f0101d0b <mem_init+0x164>
		++nfree;
f0101d02:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101d05:	8b 00                	mov    (%eax),%eax
f0101d07:	85 c0                	test   %eax,%eax
f0101d09:	75 f7                	jne    f0101d02 <mem_init+0x15b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d12:	e8 8b fa ff ff       	call   f01017a2 <page_alloc>
f0101d17:	89 c6                	mov    %eax,%esi
f0101d19:	85 c0                	test   %eax,%eax
f0101d1b:	75 24                	jne    f0101d41 <mem_init+0x19a>
f0101d1d:	c7 44 24 0c 65 85 10 	movl   $0xf0108565,0xc(%esp)
f0101d24:	f0 
f0101d25:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101d2c:	f0 
f0101d2d:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101d34:	00 
f0101d35:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101d3c:	e8 ff e2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d48:	e8 55 fa ff ff       	call   f01017a2 <page_alloc>
f0101d4d:	89 c7                	mov    %eax,%edi
f0101d4f:	85 c0                	test   %eax,%eax
f0101d51:	75 24                	jne    f0101d77 <mem_init+0x1d0>
f0101d53:	c7 44 24 0c 7b 85 10 	movl   $0xf010857b,0xc(%esp)
f0101d5a:	f0 
f0101d5b:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101d62:	f0 
f0101d63:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101d6a:	00 
f0101d6b:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101d72:	e8 c9 e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d7e:	e8 1f fa ff ff       	call   f01017a2 <page_alloc>
f0101d83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d86:	85 c0                	test   %eax,%eax
f0101d88:	75 24                	jne    f0101dae <mem_init+0x207>
f0101d8a:	c7 44 24 0c 91 85 10 	movl   $0xf0108591,0xc(%esp)
f0101d91:	f0 
f0101d92:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101d99:	f0 
f0101d9a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101da1:	00 
f0101da2:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101da9:	e8 92 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101dae:	39 fe                	cmp    %edi,%esi
f0101db0:	75 24                	jne    f0101dd6 <mem_init+0x22f>
f0101db2:	c7 44 24 0c a7 85 10 	movl   $0xf01085a7,0xc(%esp)
f0101db9:	f0 
f0101dba:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101dc1:	f0 
f0101dc2:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101dc9:	00 
f0101dca:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101dd1:	e8 6a e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101dd6:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101dd9:	74 05                	je     f0101de0 <mem_init+0x239>
f0101ddb:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101dde:	75 24                	jne    f0101e04 <mem_init+0x25d>
f0101de0:	c7 44 24 0c b0 7c 10 	movl   $0xf0107cb0,0xc(%esp)
f0101de7:	f0 
f0101de8:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101def:	f0 
f0101df0:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101df7:	00 
f0101df8:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101dff:	e8 3c e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e04:	8b 15 90 ce 20 f0    	mov    0xf020ce90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101e0a:	a1 88 ce 20 f0       	mov    0xf020ce88,%eax
f0101e0f:	c1 e0 0c             	shl    $0xc,%eax
f0101e12:	89 f1                	mov    %esi,%ecx
f0101e14:	29 d1                	sub    %edx,%ecx
f0101e16:	c1 f9 03             	sar    $0x3,%ecx
f0101e19:	c1 e1 0c             	shl    $0xc,%ecx
f0101e1c:	39 c1                	cmp    %eax,%ecx
f0101e1e:	72 24                	jb     f0101e44 <mem_init+0x29d>
f0101e20:	c7 44 24 0c b9 85 10 	movl   $0xf01085b9,0xc(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101e2f:	f0 
f0101e30:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101e37:	00 
f0101e38:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101e3f:	e8 fc e1 ff ff       	call   f0100040 <_panic>
f0101e44:	89 f9                	mov    %edi,%ecx
f0101e46:	29 d1                	sub    %edx,%ecx
f0101e48:	c1 f9 03             	sar    $0x3,%ecx
f0101e4b:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e4e:	39 c8                	cmp    %ecx,%eax
f0101e50:	77 24                	ja     f0101e76 <mem_init+0x2cf>
f0101e52:	c7 44 24 0c d6 85 10 	movl   $0xf01085d6,0xc(%esp)
f0101e59:	f0 
f0101e5a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101e69:	00 
f0101e6a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101e71:	e8 ca e1 ff ff       	call   f0100040 <_panic>
f0101e76:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e79:	29 d1                	sub    %edx,%ecx
f0101e7b:	89 ca                	mov    %ecx,%edx
f0101e7d:	c1 fa 03             	sar    $0x3,%edx
f0101e80:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e83:	39 d0                	cmp    %edx,%eax
f0101e85:	77 24                	ja     f0101eab <mem_init+0x304>
f0101e87:	c7 44 24 0c f3 85 10 	movl   $0xf01085f3,0xc(%esp)
f0101e8e:	f0 
f0101e8f:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101e96:	f0 
f0101e97:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101e9e:	00 
f0101e9f:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101ea6:	e8 95 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101eab:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f0101eb0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101eb3:	c7 05 40 c2 20 f0 00 	movl   $0x0,0xf020c240
f0101eba:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ebd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ec4:	e8 d9 f8 ff ff       	call   f01017a2 <page_alloc>
f0101ec9:	85 c0                	test   %eax,%eax
f0101ecb:	74 24                	je     f0101ef1 <mem_init+0x34a>
f0101ecd:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f0101ed4:	f0 
f0101ed5:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101edc:	f0 
f0101edd:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101ee4:	00 
f0101ee5:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101eec:	e8 4f e1 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101ef1:	89 34 24             	mov    %esi,(%esp)
f0101ef4:	e8 27 f9 ff ff       	call   f0101820 <page_free>
	page_free(pp1);
f0101ef9:	89 3c 24             	mov    %edi,(%esp)
f0101efc:	e8 1f f9 ff ff       	call   f0101820 <page_free>
	page_free(pp2);
f0101f01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f04:	89 04 24             	mov    %eax,(%esp)
f0101f07:	e8 14 f9 ff ff       	call   f0101820 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f13:	e8 8a f8 ff ff       	call   f01017a2 <page_alloc>
f0101f18:	89 c6                	mov    %eax,%esi
f0101f1a:	85 c0                	test   %eax,%eax
f0101f1c:	75 24                	jne    f0101f42 <mem_init+0x39b>
f0101f1e:	c7 44 24 0c 65 85 10 	movl   $0xf0108565,0xc(%esp)
f0101f25:	f0 
f0101f26:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101f2d:	f0 
f0101f2e:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101f35:	00 
f0101f36:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101f3d:	e8 fe e0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f49:	e8 54 f8 ff ff       	call   f01017a2 <page_alloc>
f0101f4e:	89 c7                	mov    %eax,%edi
f0101f50:	85 c0                	test   %eax,%eax
f0101f52:	75 24                	jne    f0101f78 <mem_init+0x3d1>
f0101f54:	c7 44 24 0c 7b 85 10 	movl   $0xf010857b,0xc(%esp)
f0101f5b:	f0 
f0101f5c:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101f63:	f0 
f0101f64:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101f6b:	00 
f0101f6c:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101f73:	e8 c8 e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f7f:	e8 1e f8 ff ff       	call   f01017a2 <page_alloc>
f0101f84:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f87:	85 c0                	test   %eax,%eax
f0101f89:	75 24                	jne    f0101faf <mem_init+0x408>
f0101f8b:	c7 44 24 0c 91 85 10 	movl   $0xf0108591,0xc(%esp)
f0101f92:	f0 
f0101f93:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101fa2:	00 
f0101fa3:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101faa:	e8 91 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101faf:	39 fe                	cmp    %edi,%esi
f0101fb1:	75 24                	jne    f0101fd7 <mem_init+0x430>
f0101fb3:	c7 44 24 0c a7 85 10 	movl   $0xf01085a7,0xc(%esp)
f0101fba:	f0 
f0101fbb:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101fc2:	f0 
f0101fc3:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101fca:	00 
f0101fcb:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0101fd2:	e8 69 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fd7:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101fda:	74 05                	je     f0101fe1 <mem_init+0x43a>
f0101fdc:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101fdf:	75 24                	jne    f0102005 <mem_init+0x45e>
f0101fe1:	c7 44 24 0c b0 7c 10 	movl   $0xf0107cb0,0xc(%esp)
f0101fe8:	f0 
f0101fe9:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0101ff0:	f0 
f0101ff1:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101ff8:	00 
f0101ff9:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102000:	e8 3b e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102005:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010200c:	e8 91 f7 ff ff       	call   f01017a2 <page_alloc>
f0102011:	85 c0                	test   %eax,%eax
f0102013:	74 24                	je     f0102039 <mem_init+0x492>
f0102015:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f010201c:	f0 
f010201d:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102024:	f0 
f0102025:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f010202c:	00 
f010202d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102034:	e8 07 e0 ff ff       	call   f0100040 <_panic>
f0102039:	89 f0                	mov    %esi,%eax
f010203b:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0102041:	c1 f8 03             	sar    $0x3,%eax
f0102044:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102047:	89 c2                	mov    %eax,%edx
f0102049:	c1 ea 0c             	shr    $0xc,%edx
f010204c:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0102052:	72 20                	jb     f0102074 <mem_init+0x4cd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102054:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102058:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f010205f:	f0 
f0102060:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102067:	00 
f0102068:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f010206f:	e8 cc df ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102074:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010207b:	00 
f010207c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102083:	00 
	return (void *)(pa + KERNBASE);
f0102084:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102089:	89 04 24             	mov    %eax,(%esp)
f010208c:	e8 a0 44 00 00       	call   f0106531 <memset>
	page_free(pp0);
f0102091:	89 34 24             	mov    %esi,(%esp)
f0102094:	e8 87 f7 ff ff       	call   f0101820 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102099:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01020a0:	e8 fd f6 ff ff       	call   f01017a2 <page_alloc>
f01020a5:	85 c0                	test   %eax,%eax
f01020a7:	75 24                	jne    f01020cd <mem_init+0x526>
f01020a9:	c7 44 24 0c 1f 86 10 	movl   $0xf010861f,0xc(%esp)
f01020b0:	f0 
f01020b1:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01020b8:	f0 
f01020b9:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01020c0:	00 
f01020c1:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01020c8:	e8 73 df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01020cd:	39 c6                	cmp    %eax,%esi
f01020cf:	74 24                	je     f01020f5 <mem_init+0x54e>
f01020d1:	c7 44 24 0c 3d 86 10 	movl   $0xf010863d,0xc(%esp)
f01020d8:	f0 
f01020d9:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01020e0:	f0 
f01020e1:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01020e8:	00 
f01020e9:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01020f0:	e8 4b df ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020f5:	89 f2                	mov    %esi,%edx
f01020f7:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f01020fd:	c1 fa 03             	sar    $0x3,%edx
f0102100:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102103:	89 d0                	mov    %edx,%eax
f0102105:	c1 e8 0c             	shr    $0xc,%eax
f0102108:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f010210e:	72 20                	jb     f0102130 <mem_init+0x589>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102110:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102114:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f010211b:	f0 
f010211c:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102123:	00 
f0102124:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f010212b:	e8 10 df ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102130:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102137:	75 11                	jne    f010214a <mem_init+0x5a3>
f0102139:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010213f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102145:	80 38 00             	cmpb   $0x0,(%eax)
f0102148:	74 24                	je     f010216e <mem_init+0x5c7>
f010214a:	c7 44 24 0c 4d 86 10 	movl   $0xf010864d,0xc(%esp)
f0102151:	f0 
f0102152:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102159:	f0 
f010215a:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102161:	00 
f0102162:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102169:	e8 d2 de ff ff       	call   f0100040 <_panic>
f010216e:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102171:	39 d0                	cmp    %edx,%eax
f0102173:	75 d0                	jne    f0102145 <mem_init+0x59e>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102175:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102178:	89 15 40 c2 20 f0    	mov    %edx,0xf020c240

	// free the pages we took
	page_free(pp0);
f010217e:	89 34 24             	mov    %esi,(%esp)
f0102181:	e8 9a f6 ff ff       	call   f0101820 <page_free>
	page_free(pp1);
f0102186:	89 3c 24             	mov    %edi,(%esp)
f0102189:	e8 92 f6 ff ff       	call   f0101820 <page_free>
	page_free(pp2);
f010218e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102191:	89 04 24             	mov    %eax,(%esp)
f0102194:	e8 87 f6 ff ff       	call   f0101820 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102199:	a1 40 c2 20 f0       	mov    0xf020c240,%eax
f010219e:	85 c0                	test   %eax,%eax
f01021a0:	74 09                	je     f01021ab <mem_init+0x604>
		--nfree;
f01021a2:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01021a5:	8b 00                	mov    (%eax),%eax
f01021a7:	85 c0                	test   %eax,%eax
f01021a9:	75 f7                	jne    f01021a2 <mem_init+0x5fb>
		--nfree;
	assert(nfree == 0);
f01021ab:	85 db                	test   %ebx,%ebx
f01021ad:	74 24                	je     f01021d3 <mem_init+0x62c>
f01021af:	c7 44 24 0c 57 86 10 	movl   $0xf0108657,0xc(%esp)
f01021b6:	f0 
f01021b7:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01021be:	f0 
f01021bf:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01021c6:	00 
f01021c7:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01021ce:	e8 6d de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01021d3:	c7 04 24 d0 7c 10 f0 	movl   $0xf0107cd0,(%esp)
f01021da:	e8 23 24 00 00       	call   f0104602 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01021df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021e6:	e8 b7 f5 ff ff       	call   f01017a2 <page_alloc>
f01021eb:	89 c6                	mov    %eax,%esi
f01021ed:	85 c0                	test   %eax,%eax
f01021ef:	75 24                	jne    f0102215 <mem_init+0x66e>
f01021f1:	c7 44 24 0c 65 85 10 	movl   $0xf0108565,0xc(%esp)
f01021f8:	f0 
f01021f9:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102200:	f0 
f0102201:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102208:	00 
f0102209:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102210:	e8 2b de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102215:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010221c:	e8 81 f5 ff ff       	call   f01017a2 <page_alloc>
f0102221:	89 c7                	mov    %eax,%edi
f0102223:	85 c0                	test   %eax,%eax
f0102225:	75 24                	jne    f010224b <mem_init+0x6a4>
f0102227:	c7 44 24 0c 7b 85 10 	movl   $0xf010857b,0xc(%esp)
f010222e:	f0 
f010222f:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102236:	f0 
f0102237:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f010223e:	00 
f010223f:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102246:	e8 f5 dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010224b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102252:	e8 4b f5 ff ff       	call   f01017a2 <page_alloc>
f0102257:	89 c3                	mov    %eax,%ebx
f0102259:	85 c0                	test   %eax,%eax
f010225b:	75 24                	jne    f0102281 <mem_init+0x6da>
f010225d:	c7 44 24 0c 91 85 10 	movl   $0xf0108591,0xc(%esp)
f0102264:	f0 
f0102265:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010226c:	f0 
f010226d:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102274:	00 
f0102275:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010227c:	e8 bf dd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102281:	39 fe                	cmp    %edi,%esi
f0102283:	75 24                	jne    f01022a9 <mem_init+0x702>
f0102285:	c7 44 24 0c a7 85 10 	movl   $0xf01085a7,0xc(%esp)
f010228c:	f0 
f010228d:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102294:	f0 
f0102295:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010229c:	00 
f010229d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01022a4:	e8 97 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022a9:	39 c7                	cmp    %eax,%edi
f01022ab:	74 04                	je     f01022b1 <mem_init+0x70a>
f01022ad:	39 c6                	cmp    %eax,%esi
f01022af:	75 24                	jne    f01022d5 <mem_init+0x72e>
f01022b1:	c7 44 24 0c b0 7c 10 	movl   $0xf0107cb0,0xc(%esp)
f01022b8:	f0 
f01022b9:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01022c0:	f0 
f01022c1:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01022c8:	00 
f01022c9:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01022d0:	e8 6b dd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01022d5:	8b 15 40 c2 20 f0    	mov    0xf020c240,%edx
f01022db:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f01022de:	c7 05 40 c2 20 f0 00 	movl   $0x0,0xf020c240
f01022e5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01022e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022ef:	e8 ae f4 ff ff       	call   f01017a2 <page_alloc>
f01022f4:	85 c0                	test   %eax,%eax
f01022f6:	74 24                	je     f010231c <mem_init+0x775>
f01022f8:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f01022ff:	f0 
f0102300:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102307:	f0 
f0102308:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f010230f:	00 
f0102310:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102317:	e8 24 dd ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010231c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010231f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102323:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010232a:	00 
f010232b:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102330:	89 04 24             	mov    %eax,(%esp)
f0102333:	e8 51 f6 ff ff       	call   f0101989 <page_lookup>
f0102338:	85 c0                	test   %eax,%eax
f010233a:	74 24                	je     f0102360 <mem_init+0x7b9>
f010233c:	c7 44 24 0c f0 7c 10 	movl   $0xf0107cf0,0xc(%esp)
f0102343:	f0 
f0102344:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010234b:	f0 
f010234c:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102353:	00 
f0102354:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010235b:	e8 e0 dc ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102360:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102367:	00 
f0102368:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010236f:	00 
f0102370:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102374:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102379:	89 04 24             	mov    %eax,(%esp)
f010237c:	e8 05 f7 ff ff       	call   f0101a86 <page_insert>
f0102381:	85 c0                	test   %eax,%eax
f0102383:	78 24                	js     f01023a9 <mem_init+0x802>
f0102385:	c7 44 24 0c 28 7d 10 	movl   $0xf0107d28,0xc(%esp)
f010238c:	f0 
f010238d:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102394:	f0 
f0102395:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f010239c:	00 
f010239d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01023a4:	e8 97 dc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01023a9:	89 34 24             	mov    %esi,(%esp)
f01023ac:	e8 6f f4 ff ff       	call   f0101820 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023b1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023b8:	00 
f01023b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023c0:	00 
f01023c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01023c5:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01023ca:	89 04 24             	mov    %eax,(%esp)
f01023cd:	e8 b4 f6 ff ff       	call   f0101a86 <page_insert>
f01023d2:	85 c0                	test   %eax,%eax
f01023d4:	74 24                	je     f01023fa <mem_init+0x853>
f01023d6:	c7 44 24 0c 58 7d 10 	movl   $0xf0107d58,0xc(%esp)
f01023dd:	f0 
f01023de:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01023e5:	f0 
f01023e6:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01023ed:	00 
f01023ee:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01023f5:	e8 46 dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023fa:	8b 0d 8c ce 20 f0    	mov    0xf020ce8c,%ecx
f0102400:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102403:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
f0102408:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010240b:	8b 11                	mov    (%ecx),%edx
f010240d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102413:	89 f0                	mov    %esi,%eax
f0102415:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102418:	c1 f8 03             	sar    $0x3,%eax
f010241b:	c1 e0 0c             	shl    $0xc,%eax
f010241e:	39 c2                	cmp    %eax,%edx
f0102420:	74 24                	je     f0102446 <mem_init+0x89f>
f0102422:	c7 44 24 0c 88 7d 10 	movl   $0xf0107d88,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102446:	ba 00 00 00 00       	mov    $0x0,%edx
f010244b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010244e:	e8 7d ed ff ff       	call   f01011d0 <check_va2pa>
f0102453:	89 fa                	mov    %edi,%edx
f0102455:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0102458:	c1 fa 03             	sar    $0x3,%edx
f010245b:	c1 e2 0c             	shl    $0xc,%edx
f010245e:	39 d0                	cmp    %edx,%eax
f0102460:	74 24                	je     f0102486 <mem_init+0x8df>
f0102462:	c7 44 24 0c b0 7d 10 	movl   $0xf0107db0,0xc(%esp)
f0102469:	f0 
f010246a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102471:	f0 
f0102472:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102479:	00 
f010247a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102481:	e8 ba db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102486:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010248b:	74 24                	je     f01024b1 <mem_init+0x90a>
f010248d:	c7 44 24 0c 62 86 10 	movl   $0xf0108662,0xc(%esp)
f0102494:	f0 
f0102495:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010249c:	f0 
f010249d:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f01024a4:	00 
f01024a5:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01024ac:	e8 8f db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01024b1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024b6:	74 24                	je     f01024dc <mem_init+0x935>
f01024b8:	c7 44 24 0c 73 86 10 	movl   $0xf0108673,0xc(%esp)
f01024bf:	f0 
f01024c0:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01024c7:	f0 
f01024c8:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f01024cf:	00 
f01024d0:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01024d7:	e8 64 db ff ff       	call   f0100040 <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024dc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024e3:	00 
f01024e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024eb:	00 
f01024ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024f3:	89 14 24             	mov    %edx,(%esp)
f01024f6:	e8 8b f5 ff ff       	call   f0101a86 <page_insert>
f01024fb:	85 c0                	test   %eax,%eax
f01024fd:	74 24                	je     f0102523 <mem_init+0x97c>
f01024ff:	c7 44 24 0c e0 7d 10 	movl   $0xf0107de0,0xc(%esp)
f0102506:	f0 
f0102507:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010250e:	f0 
f010250f:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102516:	00 
f0102517:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010251e:	e8 1d db ff ff       	call   f0100040 <_panic>

	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102523:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102528:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010252d:	e8 9e ec ff ff       	call   f01011d0 <check_va2pa>
f0102532:	89 da                	mov    %ebx,%edx
f0102534:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f010253a:	c1 fa 03             	sar    $0x3,%edx
f010253d:	c1 e2 0c             	shl    $0xc,%edx
f0102540:	39 d0                	cmp    %edx,%eax
f0102542:	74 24                	je     f0102568 <mem_init+0x9c1>
f0102544:	c7 44 24 0c 1c 7e 10 	movl   $0xf0107e1c,0xc(%esp)
f010254b:	f0 
f010254c:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102553:	f0 
f0102554:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f010255b:	00 
f010255c:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102563:	e8 d8 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102568:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010256d:	74 24                	je     f0102593 <mem_init+0x9ec>
f010256f:	c7 44 24 0c 84 86 10 	movl   $0xf0108684,0xc(%esp)
f0102576:	f0 
f0102577:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010257e:	f0 
f010257f:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102586:	00 
f0102587:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010258e:	e8 ad da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010259a:	e8 03 f2 ff ff       	call   f01017a2 <page_alloc>
f010259f:	85 c0                	test   %eax,%eax
f01025a1:	74 24                	je     f01025c7 <mem_init+0xa20>
f01025a3:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f01025aa:	f0 
f01025ab:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01025b2:	f0 
f01025b3:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f01025ba:	00 
f01025bb:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01025c2:	e8 79 da ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025c7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025ce:	00 
f01025cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025d6:	00 
f01025d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025db:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01025e0:	89 04 24             	mov    %eax,(%esp)
f01025e3:	e8 9e f4 ff ff       	call   f0101a86 <page_insert>
f01025e8:	85 c0                	test   %eax,%eax
f01025ea:	74 24                	je     f0102610 <mem_init+0xa69>
f01025ec:	c7 44 24 0c e0 7d 10 	movl   $0xf0107de0,0xc(%esp)
f01025f3:	f0 
f01025f4:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01025fb:	f0 
f01025fc:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102603:	00 
f0102604:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010260b:	e8 30 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102610:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102615:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010261a:	e8 b1 eb ff ff       	call   f01011d0 <check_va2pa>
f010261f:	89 da                	mov    %ebx,%edx
f0102621:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0102627:	c1 fa 03             	sar    $0x3,%edx
f010262a:	c1 e2 0c             	shl    $0xc,%edx
f010262d:	39 d0                	cmp    %edx,%eax
f010262f:	74 24                	je     f0102655 <mem_init+0xaae>
f0102631:	c7 44 24 0c 1c 7e 10 	movl   $0xf0107e1c,0xc(%esp)
f0102638:	f0 
f0102639:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102640:	f0 
f0102641:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102648:	00 
f0102649:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102650:	e8 eb d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102655:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010265a:	74 24                	je     f0102680 <mem_init+0xad9>
f010265c:	c7 44 24 0c 84 86 10 	movl   $0xf0108684,0xc(%esp)
f0102663:	f0 
f0102664:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010266b:	f0 
f010266c:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102673:	00 
f0102674:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010267b:	e8 c0 d9 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102687:	e8 16 f1 ff ff       	call   f01017a2 <page_alloc>
f010268c:	85 c0                	test   %eax,%eax
f010268e:	74 24                	je     f01026b4 <mem_init+0xb0d>
f0102690:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f0102697:	f0 
f0102698:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010269f:	f0 
f01026a0:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f01026a7:	00 
f01026a8:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01026af:	e8 8c d9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01026b4:	8b 15 8c ce 20 f0    	mov    0xf020ce8c,%edx
f01026ba:	8b 02                	mov    (%edx),%eax
f01026bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026c1:	89 c1                	mov    %eax,%ecx
f01026c3:	c1 e9 0c             	shr    $0xc,%ecx
f01026c6:	3b 0d 88 ce 20 f0    	cmp    0xf020ce88,%ecx
f01026cc:	72 20                	jb     f01026ee <mem_init+0xb47>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026d2:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01026d9:	f0 
f01026da:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01026e1:	00 
f01026e2:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01026e9:	e8 52 d9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01026ee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026fd:	00 
f01026fe:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102705:	00 
f0102706:	89 14 24             	mov    %edx,(%esp)
f0102709:	e8 6d f1 ff ff       	call   f010187b <pgdir_walk>
f010270e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102711:	83 c2 04             	add    $0x4,%edx
f0102714:	39 d0                	cmp    %edx,%eax
f0102716:	74 24                	je     f010273c <mem_init+0xb95>
f0102718:	c7 44 24 0c 4c 7e 10 	movl   $0xf0107e4c,0xc(%esp)
f010271f:	f0 
f0102720:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102727:	f0 
f0102728:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f010272f:	00 
f0102730:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102737:	e8 04 d9 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010273c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102743:	00 
f0102744:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010274b:	00 
f010274c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102750:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102755:	89 04 24             	mov    %eax,(%esp)
f0102758:	e8 29 f3 ff ff       	call   f0101a86 <page_insert>
f010275d:	85 c0                	test   %eax,%eax
f010275f:	74 24                	je     f0102785 <mem_init+0xbde>
f0102761:	c7 44 24 0c 8c 7e 10 	movl   $0xf0107e8c,0xc(%esp)
f0102768:	f0 
f0102769:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102770:	f0 
f0102771:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102778:	00 
f0102779:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102780:	e8 bb d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102785:	8b 0d 8c ce 20 f0    	mov    0xf020ce8c,%ecx
f010278b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010278e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102793:	89 c8                	mov    %ecx,%eax
f0102795:	e8 36 ea ff ff       	call   f01011d0 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010279a:	89 da                	mov    %ebx,%edx
f010279c:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f01027a2:	c1 fa 03             	sar    $0x3,%edx
f01027a5:	c1 e2 0c             	shl    $0xc,%edx
f01027a8:	39 d0                	cmp    %edx,%eax
f01027aa:	74 24                	je     f01027d0 <mem_init+0xc29>
f01027ac:	c7 44 24 0c 1c 7e 10 	movl   $0xf0107e1c,0xc(%esp)
f01027b3:	f0 
f01027b4:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01027bb:	f0 
f01027bc:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f01027c3:	00 
f01027c4:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01027cb:	e8 70 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01027d0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027d5:	74 24                	je     f01027fb <mem_init+0xc54>
f01027d7:	c7 44 24 0c 84 86 10 	movl   $0xf0108684,0xc(%esp)
f01027de:	f0 
f01027df:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01027e6:	f0 
f01027e7:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01027ee:	00 
f01027ef:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01027f6:	e8 45 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01027fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102802:	00 
f0102803:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010280a:	00 
f010280b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010280e:	89 04 24             	mov    %eax,(%esp)
f0102811:	e8 65 f0 ff ff       	call   f010187b <pgdir_walk>
f0102816:	f6 00 04             	testb  $0x4,(%eax)
f0102819:	75 24                	jne    f010283f <mem_init+0xc98>
f010281b:	c7 44 24 0c cc 7e 10 	movl   $0xf0107ecc,0xc(%esp)
f0102822:	f0 
f0102823:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010282a:	f0 
f010282b:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f0102832:	00 
f0102833:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010283a:	e8 01 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010283f:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102844:	f6 00 04             	testb  $0x4,(%eax)
f0102847:	75 24                	jne    f010286d <mem_init+0xcc6>
f0102849:	c7 44 24 0c 95 86 10 	movl   $0xf0108695,0xc(%esp)
f0102850:	f0 
f0102851:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102858:	f0 
f0102859:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102860:	00 
f0102861:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102868:	e8 d3 d7 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010286d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102874:	00 
f0102875:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010287c:	00 
f010287d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102881:	89 04 24             	mov    %eax,(%esp)
f0102884:	e8 fd f1 ff ff       	call   f0101a86 <page_insert>
f0102889:	85 c0                	test   %eax,%eax
f010288b:	74 24                	je     f01028b1 <mem_init+0xd0a>
f010288d:	c7 44 24 0c e0 7d 10 	movl   $0xf0107de0,0xc(%esp)
f0102894:	f0 
f0102895:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010289c:	f0 
f010289d:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f01028a4:	00 
f01028a5:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01028ac:	e8 8f d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01028b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028b8:	00 
f01028b9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028c0:	00 
f01028c1:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01028c6:	89 04 24             	mov    %eax,(%esp)
f01028c9:	e8 ad ef ff ff       	call   f010187b <pgdir_walk>
f01028ce:	f6 00 02             	testb  $0x2,(%eax)
f01028d1:	75 24                	jne    f01028f7 <mem_init+0xd50>
f01028d3:	c7 44 24 0c 00 7f 10 	movl   $0xf0107f00,0xc(%esp)
f01028da:	f0 
f01028db:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01028e2:	f0 
f01028e3:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f01028ea:	00 
f01028eb:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01028f2:	e8 49 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028fe:	00 
f01028ff:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102906:	00 
f0102907:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010290c:	89 04 24             	mov    %eax,(%esp)
f010290f:	e8 67 ef ff ff       	call   f010187b <pgdir_walk>
f0102914:	f6 00 04             	testb  $0x4,(%eax)
f0102917:	74 24                	je     f010293d <mem_init+0xd96>
f0102919:	c7 44 24 0c 34 7f 10 	movl   $0xf0107f34,0xc(%esp)
f0102920:	f0 
f0102921:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102928:	f0 
f0102929:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0102930:	00 
f0102931:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102938:	e8 03 d7 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010293d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102944:	00 
f0102945:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010294c:	00 
f010294d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102951:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102956:	89 04 24             	mov    %eax,(%esp)
f0102959:	e8 28 f1 ff ff       	call   f0101a86 <page_insert>
f010295e:	85 c0                	test   %eax,%eax
f0102960:	78 24                	js     f0102986 <mem_init+0xddf>
f0102962:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0102969:	f0 
f010296a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102971:	f0 
f0102972:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102979:	00 
f010297a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102981:	e8 ba d6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102986:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010298d:	00 
f010298e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102995:	00 
f0102996:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010299a:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010299f:	89 04 24             	mov    %eax,(%esp)
f01029a2:	e8 df f0 ff ff       	call   f0101a86 <page_insert>
f01029a7:	85 c0                	test   %eax,%eax
f01029a9:	74 24                	je     f01029cf <mem_init+0xe28>
f01029ab:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f01029b2:	f0 
f01029b3:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01029ba:	f0 
f01029bb:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f01029c2:	00 
f01029c3:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01029ca:	e8 71 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01029cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029d6:	00 
f01029d7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029de:	00 
f01029df:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01029e4:	89 04 24             	mov    %eax,(%esp)
f01029e7:	e8 8f ee ff ff       	call   f010187b <pgdir_walk>
f01029ec:	f6 00 04             	testb  $0x4,(%eax)
f01029ef:	74 24                	je     f0102a15 <mem_init+0xe6e>
f01029f1:	c7 44 24 0c 34 7f 10 	movl   $0xf0107f34,0xc(%esp)
f01029f8:	f0 
f01029f9:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102a00:	f0 
f0102a01:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0102a08:	00 
f0102a09:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102a10:	e8 2b d6 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a15:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102a1a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a22:	e8 a9 e7 ff ff       	call   f01011d0 <check_va2pa>
f0102a27:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a2a:	89 f8                	mov    %edi,%eax
f0102a2c:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0102a32:	c1 f8 03             	sar    $0x3,%eax
f0102a35:	c1 e0 0c             	shl    $0xc,%eax
f0102a38:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a3b:	74 24                	je     f0102a61 <mem_init+0xeba>
f0102a3d:	c7 44 24 0c e0 7f 10 	movl   $0xf0107fe0,0xc(%esp)
f0102a44:	f0 
f0102a45:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102a4c:	f0 
f0102a4d:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102a54:	00 
f0102a55:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102a5c:	e8 df d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a61:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a69:	e8 62 e7 ff ff       	call   f01011d0 <check_va2pa>
f0102a6e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a71:	74 24                	je     f0102a97 <mem_init+0xef0>
f0102a73:	c7 44 24 0c 0c 80 10 	movl   $0xf010800c,0xc(%esp)
f0102a7a:	f0 
f0102a7b:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102a82:	f0 
f0102a83:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102a8a:	00 
f0102a8b:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102a92:	e8 a9 d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102a97:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102a9c:	74 24                	je     f0102ac2 <mem_init+0xf1b>
f0102a9e:	c7 44 24 0c ab 86 10 	movl   $0xf01086ab,0xc(%esp)
f0102aa5:	f0 
f0102aa6:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102aad:	f0 
f0102aae:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102ab5:	00 
f0102ab6:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102abd:	e8 7e d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ac2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102ac7:	74 24                	je     f0102aed <mem_init+0xf46>
f0102ac9:	c7 44 24 0c bc 86 10 	movl   $0xf01086bc,0xc(%esp)
f0102ad0:	f0 
f0102ad1:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102ad8:	f0 
f0102ad9:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102ae0:	00 
f0102ae1:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102ae8:	e8 53 d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102af4:	e8 a9 ec ff ff       	call   f01017a2 <page_alloc>
f0102af9:	85 c0                	test   %eax,%eax
f0102afb:	74 04                	je     f0102b01 <mem_init+0xf5a>
f0102afd:	39 c3                	cmp    %eax,%ebx
f0102aff:	74 24                	je     f0102b25 <mem_init+0xf7e>
f0102b01:	c7 44 24 0c 3c 80 10 	movl   $0xf010803c,0xc(%esp)
f0102b08:	f0 
f0102b09:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102b10:	f0 
f0102b11:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102b18:	00 
f0102b19:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102b20:	e8 1b d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102b25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b2c:	00 
f0102b2d:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102b32:	89 04 24             	mov    %eax,(%esp)
f0102b35:	e8 fc ee ff ff       	call   f0101a36 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b3a:	8b 15 8c ce 20 f0    	mov    0xf020ce8c,%edx
f0102b40:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102b43:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b4b:	e8 80 e6 ff ff       	call   f01011d0 <check_va2pa>
f0102b50:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b53:	74 24                	je     f0102b79 <mem_init+0xfd2>
f0102b55:	c7 44 24 0c 60 80 10 	movl   $0xf0108060,0xc(%esp)
f0102b5c:	f0 
f0102b5d:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102b64:	f0 
f0102b65:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102b6c:	00 
f0102b6d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102b74:	e8 c7 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b79:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b81:	e8 4a e6 ff ff       	call   f01011d0 <check_va2pa>
f0102b86:	89 fa                	mov    %edi,%edx
f0102b88:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0102b8e:	c1 fa 03             	sar    $0x3,%edx
f0102b91:	c1 e2 0c             	shl    $0xc,%edx
f0102b94:	39 d0                	cmp    %edx,%eax
f0102b96:	74 24                	je     f0102bbc <mem_init+0x1015>
f0102b98:	c7 44 24 0c 0c 80 10 	movl   $0xf010800c,0xc(%esp)
f0102b9f:	f0 
f0102ba0:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102ba7:	f0 
f0102ba8:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0102baf:	00 
f0102bb0:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102bb7:	e8 84 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102bbc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bc1:	74 24                	je     f0102be7 <mem_init+0x1040>
f0102bc3:	c7 44 24 0c 62 86 10 	movl   $0xf0108662,0xc(%esp)
f0102bca:	f0 
f0102bcb:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102bd2:	f0 
f0102bd3:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0102bda:	00 
f0102bdb:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102be2:	e8 59 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102be7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bec:	74 24                	je     f0102c12 <mem_init+0x106b>
f0102bee:	c7 44 24 0c bc 86 10 	movl   $0xf01086bc,0xc(%esp)
f0102bf5:	f0 
f0102bf6:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102bfd:	f0 
f0102bfe:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0102c05:	00 
f0102c06:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102c0d:	e8 2e d4 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c12:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c19:	00 
f0102c1a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c1d:	89 0c 24             	mov    %ecx,(%esp)
f0102c20:	e8 11 ee ff ff       	call   f0101a36 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102c25:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102c2a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c32:	e8 99 e5 ff ff       	call   f01011d0 <check_va2pa>
f0102c37:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c3a:	74 24                	je     f0102c60 <mem_init+0x10b9>
f0102c3c:	c7 44 24 0c 60 80 10 	movl   $0xf0108060,0xc(%esp)
f0102c43:	f0 
f0102c44:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102c4b:	f0 
f0102c4c:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102c53:	00 
f0102c54:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102c5b:	e8 e0 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102c60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c68:	e8 63 e5 ff ff       	call   f01011d0 <check_va2pa>
f0102c6d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c70:	74 24                	je     f0102c96 <mem_init+0x10ef>
f0102c72:	c7 44 24 0c 84 80 10 	movl   $0xf0108084,0xc(%esp)
f0102c79:	f0 
f0102c7a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102c81:	f0 
f0102c82:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0102c89:	00 
f0102c8a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102c91:	e8 aa d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c96:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c9b:	74 24                	je     f0102cc1 <mem_init+0x111a>
f0102c9d:	c7 44 24 0c cd 86 10 	movl   $0xf01086cd,0xc(%esp)
f0102ca4:	f0 
f0102ca5:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102cac:	f0 
f0102cad:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f0102cb4:	00 
f0102cb5:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102cbc:	e8 7f d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102cc1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102cc6:	74 24                	je     f0102cec <mem_init+0x1145>
f0102cc8:	c7 44 24 0c bc 86 10 	movl   $0xf01086bc,0xc(%esp)
f0102ccf:	f0 
f0102cd0:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102cd7:	f0 
f0102cd8:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102cdf:	00 
f0102ce0:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102ce7:	e8 54 d3 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102cec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cf3:	e8 aa ea ff ff       	call   f01017a2 <page_alloc>
f0102cf8:	85 c0                	test   %eax,%eax
f0102cfa:	74 04                	je     f0102d00 <mem_init+0x1159>
f0102cfc:	39 c7                	cmp    %eax,%edi
f0102cfe:	74 24                	je     f0102d24 <mem_init+0x117d>
f0102d00:	c7 44 24 0c ac 80 10 	movl   $0xf01080ac,0xc(%esp)
f0102d07:	f0 
f0102d08:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102d0f:	f0 
f0102d10:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102d17:	00 
f0102d18:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102d1f:	e8 1c d3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102d24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d2b:	e8 72 ea ff ff       	call   f01017a2 <page_alloc>
f0102d30:	85 c0                	test   %eax,%eax
f0102d32:	74 24                	je     f0102d58 <mem_init+0x11b1>
f0102d34:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f0102d3b:	f0 
f0102d3c:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102d43:	f0 
f0102d44:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102d4b:	00 
f0102d4c:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102d53:	e8 e8 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d58:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102d5d:	8b 08                	mov    (%eax),%ecx
f0102d5f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102d65:	89 f2                	mov    %esi,%edx
f0102d67:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0102d6d:	c1 fa 03             	sar    $0x3,%edx
f0102d70:	c1 e2 0c             	shl    $0xc,%edx
f0102d73:	39 d1                	cmp    %edx,%ecx
f0102d75:	74 24                	je     f0102d9b <mem_init+0x11f4>
f0102d77:	c7 44 24 0c 88 7d 10 	movl   $0xf0107d88,0xc(%esp)
f0102d7e:	f0 
f0102d7f:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102d86:	f0 
f0102d87:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102d8e:	00 
f0102d8f:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102d96:	e8 a5 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102da1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102da6:	74 24                	je     f0102dcc <mem_init+0x1225>
f0102da8:	c7 44 24 0c 73 86 10 	movl   $0xf0108673,0xc(%esp)
f0102daf:	f0 
f0102db0:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102db7:	f0 
f0102db8:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f0102dbf:	00 
f0102dc0:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102dc7:	e8 74 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102dcc:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102dd2:	89 34 24             	mov    %esi,(%esp)
f0102dd5:	e8 46 ea ff ff       	call   f0101820 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102dda:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102de1:	00 
f0102de2:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102de9:	00 
f0102dea:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102def:	89 04 24             	mov    %eax,(%esp)
f0102df2:	e8 84 ea ff ff       	call   f010187b <pgdir_walk>
f0102df7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102dfa:	8b 0d 8c ce 20 f0    	mov    0xf020ce8c,%ecx
f0102e00:	8b 51 04             	mov    0x4(%ecx),%edx
f0102e03:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e09:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e0c:	8b 15 88 ce 20 f0    	mov    0xf020ce88,%edx
f0102e12:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102e15:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e18:	c1 ea 0c             	shr    $0xc,%edx
f0102e1b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102e1e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102e21:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102e24:	72 23                	jb     f0102e49 <mem_init+0x12a2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e26:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102e2d:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0102e34:	f0 
f0102e35:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f0102e3c:	00 
f0102e3d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102e44:	e8 f7 d1 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102e49:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e4c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102e52:	39 d0                	cmp    %edx,%eax
f0102e54:	74 24                	je     f0102e7a <mem_init+0x12d3>
f0102e56:	c7 44 24 0c de 86 10 	movl   $0xf01086de,0xc(%esp)
f0102e5d:	f0 
f0102e5e:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102e65:	f0 
f0102e66:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102e6d:	00 
f0102e6e:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102e75:	e8 c6 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102e7a:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102e81:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e87:	89 f0                	mov    %esi,%eax
f0102e89:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0102e8f:	c1 f8 03             	sar    $0x3,%eax
f0102e92:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e95:	89 c1                	mov    %eax,%ecx
f0102e97:	c1 e9 0c             	shr    $0xc,%ecx
f0102e9a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102e9d:	77 20                	ja     f0102ebf <mem_init+0x1318>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ea3:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0102eaa:	f0 
f0102eab:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102eb2:	00 
f0102eb3:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f0102eba:	e8 81 d1 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102ebf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ec6:	00 
f0102ec7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102ece:	00 
	return (void *)(pa + KERNBASE);
f0102ecf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ed4:	89 04 24             	mov    %eax,(%esp)
f0102ed7:	e8 55 36 00 00       	call   f0106531 <memset>
	page_free(pp0);
f0102edc:	89 34 24             	mov    %esi,(%esp)
f0102edf:	e8 3c e9 ff ff       	call   f0101820 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102ee4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102eeb:	00 
f0102eec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102ef3:	00 
f0102ef4:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102ef9:	89 04 24             	mov    %eax,(%esp)
f0102efc:	e8 7a e9 ff ff       	call   f010187b <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f01:	89 f2                	mov    %esi,%edx
f0102f03:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0102f09:	c1 fa 03             	sar    $0x3,%edx
f0102f0c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f0f:	89 d0                	mov    %edx,%eax
f0102f11:	c1 e8 0c             	shr    $0xc,%eax
f0102f14:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0102f1a:	72 20                	jb     f0102f3c <mem_init+0x1395>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f20:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0102f27:	f0 
f0102f28:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102f2f:	00 
f0102f30:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f0102f37:	e8 04 d1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102f3c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102f42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f45:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102f4c:	75 11                	jne    f0102f5f <mem_init+0x13b8>
f0102f4e:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f54:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f5a:	f6 00 01             	testb  $0x1,(%eax)
f0102f5d:	74 24                	je     f0102f83 <mem_init+0x13dc>
f0102f5f:	c7 44 24 0c f6 86 10 	movl   $0xf01086f6,0xc(%esp)
f0102f66:	f0 
f0102f67:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0102f6e:	f0 
f0102f6f:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0102f76:	00 
f0102f77:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0102f7e:	e8 bd d0 ff ff       	call   f0100040 <_panic>
f0102f83:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102f86:	39 d0                	cmp    %edx,%eax
f0102f88:	75 d0                	jne    f0102f5a <mem_init+0x13b3>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102f8a:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0102f8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102f95:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102f9b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102f9e:	89 0d 40 c2 20 f0    	mov    %ecx,0xf020c240

	// free the pages we took
	page_free(pp0);
f0102fa4:	89 34 24             	mov    %esi,(%esp)
f0102fa7:	e8 74 e8 ff ff       	call   f0101820 <page_free>
	page_free(pp1);
f0102fac:	89 3c 24             	mov    %edi,(%esp)
f0102faf:	e8 6c e8 ff ff       	call   f0101820 <page_free>
	page_free(pp2);
f0102fb4:	89 1c 24             	mov    %ebx,(%esp)
f0102fb7:	e8 64 e8 ff ff       	call   f0101820 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102fbc:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102fc3:	00 
f0102fc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fcb:	e8 60 eb ff ff       	call   f0101b30 <mmio_map_region>
f0102fd0:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102fd2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102fd9:	00 
f0102fda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fe1:	e8 4a eb ff ff       	call   f0101b30 <mmio_map_region>
f0102fe6:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102fe8:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102fee:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ff4:	76 07                	jbe    f0102ffd <mem_init+0x1456>
f0102ff6:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102ffb:	76 24                	jbe    f0103021 <mem_init+0x147a>
f0102ffd:	c7 44 24 0c d0 80 10 	movl   $0xf01080d0,0xc(%esp)
f0103004:	f0 
f0103005:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010300c:	f0 
f010300d:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f0103014:	00 
f0103015:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010301c:	e8 1f d0 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103021:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103027:	76 0e                	jbe    f0103037 <mem_init+0x1490>
f0103029:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010302f:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0103035:	76 24                	jbe    f010305b <mem_init+0x14b4>
f0103037:	c7 44 24 0c f8 80 10 	movl   $0xf01080f8,0xc(%esp)
f010303e:	f0 
f010303f:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103046:	f0 
f0103047:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f010304e:	00 
f010304f:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103056:	e8 e5 cf ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010305b:	89 da                	mov    %ebx,%edx
f010305d:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010305f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0103065:	74 24                	je     f010308b <mem_init+0x14e4>
f0103067:	c7 44 24 0c 20 81 10 	movl   $0xf0108120,0xc(%esp)
f010306e:	f0 
f010306f:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103076:	f0 
f0103077:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010307e:	00 
f010307f:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103086:	e8 b5 cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010308b:	39 c6                	cmp    %eax,%esi
f010308d:	73 24                	jae    f01030b3 <mem_init+0x150c>
f010308f:	c7 44 24 0c 0d 87 10 	movl   $0xf010870d,0xc(%esp)
f0103096:	f0 
f0103097:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010309e:	f0 
f010309f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f01030a6:	00 
f01030a7:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01030ae:	e8 8d cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01030b3:	8b 3d 8c ce 20 f0    	mov    0xf020ce8c,%edi
f01030b9:	89 da                	mov    %ebx,%edx
f01030bb:	89 f8                	mov    %edi,%eax
f01030bd:	e8 0e e1 ff ff       	call   f01011d0 <check_va2pa>
f01030c2:	85 c0                	test   %eax,%eax
f01030c4:	74 24                	je     f01030ea <mem_init+0x1543>
f01030c6:	c7 44 24 0c 48 81 10 	movl   $0xf0108148,0xc(%esp)
f01030cd:	f0 
f01030ce:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01030d5:	f0 
f01030d6:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f01030dd:	00 
f01030de:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01030e5:	e8 56 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01030ea:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01030f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01030f3:	89 c2                	mov    %eax,%edx
f01030f5:	89 f8                	mov    %edi,%eax
f01030f7:	e8 d4 e0 ff ff       	call   f01011d0 <check_va2pa>
f01030fc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103101:	74 24                	je     f0103127 <mem_init+0x1580>
f0103103:	c7 44 24 0c 6c 81 10 	movl   $0xf010816c,0xc(%esp)
f010310a:	f0 
f010310b:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103112:	f0 
f0103113:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f010311a:	00 
f010311b:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103122:	e8 19 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0103127:	89 f2                	mov    %esi,%edx
f0103129:	89 f8                	mov    %edi,%eax
f010312b:	e8 a0 e0 ff ff       	call   f01011d0 <check_va2pa>
f0103130:	85 c0                	test   %eax,%eax
f0103132:	74 24                	je     f0103158 <mem_init+0x15b1>
f0103134:	c7 44 24 0c 9c 81 10 	movl   $0xf010819c,0xc(%esp)
f010313b:	f0 
f010313c:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103143:	f0 
f0103144:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f010314b:	00 
f010314c:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103153:	e8 e8 ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103158:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010315e:	89 f8                	mov    %edi,%eax
f0103160:	e8 6b e0 ff ff       	call   f01011d0 <check_va2pa>
f0103165:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103168:	74 24                	je     f010318e <mem_init+0x15e7>
f010316a:	c7 44 24 0c c0 81 10 	movl   $0xf01081c0,0xc(%esp)
f0103171:	f0 
f0103172:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103179:	f0 
f010317a:	c7 44 24 04 a7 04 00 	movl   $0x4a7,0x4(%esp)
f0103181:	00 
f0103182:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103189:	e8 b2 ce ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010318e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103195:	00 
f0103196:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010319a:	89 3c 24             	mov    %edi,(%esp)
f010319d:	e8 d9 e6 ff ff       	call   f010187b <pgdir_walk>
f01031a2:	f6 00 1a             	testb  $0x1a,(%eax)
f01031a5:	75 24                	jne    f01031cb <mem_init+0x1624>
f01031a7:	c7 44 24 0c ec 81 10 	movl   $0xf01081ec,0xc(%esp)
f01031ae:	f0 
f01031af:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01031b6:	f0 
f01031b7:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f01031be:	00 
f01031bf:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01031c6:	e8 75 ce ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01031cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031d2:	00 
f01031d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031d7:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01031dc:	89 04 24             	mov    %eax,(%esp)
f01031df:	e8 97 e6 ff ff       	call   f010187b <pgdir_walk>
f01031e4:	f6 00 04             	testb  $0x4,(%eax)
f01031e7:	74 24                	je     f010320d <mem_init+0x1666>
f01031e9:	c7 44 24 0c 30 82 10 	movl   $0xf0108230,0xc(%esp)
f01031f0:	f0 
f01031f1:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01031f8:	f0 
f01031f9:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f0103200:	00 
f0103201:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103208:	e8 33 ce ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010320d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103214:	00 
f0103215:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103219:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010321e:	89 04 24             	mov    %eax,(%esp)
f0103221:	e8 55 e6 ff ff       	call   f010187b <pgdir_walk>
f0103226:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010322c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103233:	00 
f0103234:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103237:	89 54 24 04          	mov    %edx,0x4(%esp)
f010323b:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103240:	89 04 24             	mov    %eax,(%esp)
f0103243:	e8 33 e6 ff ff       	call   f010187b <pgdir_walk>
f0103248:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010324e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103255:	00 
f0103256:	89 74 24 04          	mov    %esi,0x4(%esp)
f010325a:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f010325f:	89 04 24             	mov    %eax,(%esp)
f0103262:	e8 14 e6 ff ff       	call   f010187b <pgdir_walk>
f0103267:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010326d:	c7 04 24 1f 87 10 f0 	movl   $0xf010871f,(%esp)
f0103274:	e8 89 13 00 00       	call   f0104602 <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0103279:	a1 90 ce 20 f0       	mov    0xf020ce90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010327e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103283:	77 20                	ja     f01032a5 <mem_init+0x16fe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103285:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103289:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0103290:	f0 
f0103291:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f0103298:	00 
f0103299:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01032a0:	e8 9b cd ff ff       	call   f0100040 <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f01032a5:	8b 15 88 ce 20 f0    	mov    0xf020ce88,%edx
f01032ab:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01032b2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f01032b8:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01032bf:	00 
	return (physaddr_t)kva - KERNBASE;
f01032c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01032c5:	89 04 24             	mov    %eax,(%esp)
f01032c8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01032cd:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01032d2:	e8 44 e6 ff ff       	call   f010191b <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(
f01032d7:	a1 48 c2 20 f0       	mov    0xf020c248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e1:	77 20                	ja     f0103303 <mem_init+0x175c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032e7:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f01032ee:	f0 
f01032ef:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f01032f6:	00 
f01032f7:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01032fe:	e8 3d cd ff ff       	call   f0100040 <_panic>
f0103303:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010330a:	00 
	return (physaddr_t)kva - KERNBASE;
f010330b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103310:	89 04 24             	mov    %eax,(%esp)
f0103313:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0103318:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010331d:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103322:	e8 f4 e5 ff ff       	call   f010191b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103327:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f010332c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103331:	77 20                	ja     f0103353 <mem_init+0x17ac>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103333:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103337:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f010333e:	f0 
f010333f:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f0103346:	00 
f0103347:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010334e:	e8 ed cc ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0103353:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010335a:	00 
f010335b:	c7 04 24 00 90 11 00 	movl   $0x119000,(%esp)
f0103362:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103367:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010336c:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103371:	e8 a5 e5 ff ff       	call   f010191b <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(
f0103376:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010337d:	00 
f010337e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103385:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010338a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010338f:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103394:	e8 82 e5 ff ff       	call   f010191b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103399:	b8 00 e0 20 f0       	mov    $0xf020e000,%eax
f010339e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033a3:	0f 87 d3 07 00 00    	ja     f0103b7c <mem_init+0x1fd5>
f01033a9:	eb 0c                	jmp    f01033b7 <mem_init+0x1810>
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);

		boot_map_region(
f01033ab:	89 d8                	mov    %ebx,%eax
f01033ad:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01033b3:	77 27                	ja     f01033dc <mem_init+0x1835>
f01033b5:	eb 05                	jmp    f01033bc <mem_init+0x1815>
f01033b7:	b8 00 e0 20 f0       	mov    $0xf020e000,%eax
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033c0:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f01033c7:	f0 
f01033c8:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f01033cf:	00 
f01033d0:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01033d7:	e8 64 cc ff ff       	call   f0100040 <_panic>
f01033dc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01033e3:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01033e4:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);

		boot_map_region(
f01033ea:	89 04 24             	mov    %eax,(%esp)
f01033ed:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033f2:	89 f2                	mov    %esi,%edx
f01033f4:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01033f9:	e8 1d e5 ff ff       	call   f010191b <boot_map_region>
f01033fe:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103404:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
f010340a:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103410:	75 99                	jne    f01033ab <mem_init+0x1804>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103412:	8b 1d 8c ce 20 f0    	mov    0xf020ce8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103418:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f010341e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103421:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0103428:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f010342e:	0f 84 80 00 00 00    	je     f01034b4 <mem_init+0x190d>
f0103434:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103439:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010343f:	89 d8                	mov    %ebx,%eax
f0103441:	e8 8a dd ff ff       	call   f01011d0 <check_va2pa>
f0103446:	8b 15 90 ce 20 f0    	mov    0xf020ce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010344c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103452:	77 20                	ja     f0103474 <mem_init+0x18cd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103454:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103458:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f010345f:	f0 
f0103460:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103467:	00 
f0103468:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010346f:	e8 cc cb ff ff       	call   f0100040 <_panic>
f0103474:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010347b:	39 d0                	cmp    %edx,%eax
f010347d:	74 24                	je     f01034a3 <mem_init+0x18fc>
f010347f:	c7 44 24 0c 64 82 10 	movl   $0xf0108264,0xc(%esp)
f0103486:	f0 
f0103487:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010348e:	f0 
f010348f:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0103496:	00 
f0103497:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010349e:	e8 9d cb ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01034a3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01034a9:	39 f7                	cmp    %esi,%edi
f01034ab:	77 8c                	ja     f0103439 <mem_init+0x1892>
f01034ad:	be 00 00 00 00       	mov    $0x0,%esi
f01034b2:	eb 05                	jmp    f01034b9 <mem_init+0x1912>
f01034b4:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01034b9:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034bf:	89 d8                	mov    %ebx,%eax
f01034c1:	e8 0a dd ff ff       	call   f01011d0 <check_va2pa>
f01034c6:	8b 15 48 c2 20 f0    	mov    0xf020c248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034cc:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01034d2:	77 20                	ja     f01034f4 <mem_init+0x194d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01034d8:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f01034df:	f0 
f01034e0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034e7:	00 
f01034e8:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01034ef:	e8 4c cb ff ff       	call   f0100040 <_panic>
f01034f4:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01034fb:	39 d0                	cmp    %edx,%eax
f01034fd:	74 24                	je     f0103523 <mem_init+0x197c>
f01034ff:	c7 44 24 0c 98 82 10 	movl   $0xf0108298,0xc(%esp)
f0103506:	f0 
f0103507:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010350e:	f0 
f010350f:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0103516:	00 
f0103517:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010351e:	e8 1d cb ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103523:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103529:	81 fe 00 00 02 00    	cmp    $0x20000,%esi
f010352f:	75 88                	jne    f01034b9 <mem_init+0x1912>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103531:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103534:	c1 e7 0c             	shl    $0xc,%edi
f0103537:	85 ff                	test   %edi,%edi
f0103539:	74 44                	je     f010357f <mem_init+0x19d8>
f010353b:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103540:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103546:	89 d8                	mov    %ebx,%eax
f0103548:	e8 83 dc ff ff       	call   f01011d0 <check_va2pa>
f010354d:	39 c6                	cmp    %eax,%esi
f010354f:	74 24                	je     f0103575 <mem_init+0x19ce>
f0103551:	c7 44 24 0c cc 82 10 	movl   $0xf01082cc,0xc(%esp)
f0103558:	f0 
f0103559:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103560:	f0 
f0103561:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0103568:	00 
f0103569:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103570:	e8 cb ca ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103575:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010357b:	39 fe                	cmp    %edi,%esi
f010357d:	72 c1                	jb     f0103540 <mem_init+0x1999>
f010357f:	c7 45 cc 00 e0 20 f0 	movl   $0xf020e000,-0x34(%ebp)
f0103586:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f010358d:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010358f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103592:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103595:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103598:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010359e:	89 c6                	mov    %eax,%esi
f01035a0:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f01035a6:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01035a9:	81 c2 00 00 01 00    	add    $0x10000,%edx
f01035af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01035b2:	89 da                	mov    %ebx,%edx
f01035b4:	89 f8                	mov    %edi,%eax
f01035b6:	e8 15 dc ff ff       	call   f01011d0 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035bb:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01035c2:	77 23                	ja     f01035e7 <mem_init+0x1a40>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035c4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01035c7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01035cb:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f01035d2:	f0 
f01035d3:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01035da:	00 
f01035db:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01035e2:	e8 59 ca ff ff       	call   f0100040 <_panic>
f01035e7:	39 f0                	cmp    %esi,%eax
f01035e9:	74 24                	je     f010360f <mem_init+0x1a68>
f01035eb:	c7 44 24 0c f4 82 10 	movl   $0xf01082f4,0xc(%esp)
f01035f2:	f0 
f01035f3:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01035fa:	f0 
f01035fb:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0103602:	00 
f0103603:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010360a:	e8 31 ca ff ff       	call   f0100040 <_panic>
f010360f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103615:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010361b:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010361e:	0f 85 8a 05 00 00    	jne    f0103bae <mem_init+0x2007>
f0103624:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103629:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010362c:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f010362f:	89 f8                	mov    %edi,%eax
f0103631:	e8 9a db ff ff       	call   f01011d0 <check_va2pa>
f0103636:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103639:	74 24                	je     f010365f <mem_init+0x1ab8>
f010363b:	c7 44 24 0c 3c 83 10 	movl   $0xf010833c,0xc(%esp)
f0103642:	f0 
f0103643:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010364a:	f0 
f010364b:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0103652:	00 
f0103653:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010365a:	e8 e1 c9 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010365f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103665:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010366b:	75 bf                	jne    f010362c <mem_init+0x1a85>
f010366d:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0103674:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010367b:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f0103682:	0f 85 07 ff ff ff    	jne    f010358f <mem_init+0x19e8>
f0103688:	89 fb                	mov    %edi,%ebx
f010368a:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010368f:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103695:	83 fa 04             	cmp    $0x4,%edx
f0103698:	77 2e                	ja     f01036c8 <mem_init+0x1b21>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010369a:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010369e:	0f 85 aa 00 00 00    	jne    f010374e <mem_init+0x1ba7>
f01036a4:	c7 44 24 0c 38 87 10 	movl   $0xf0108738,0xc(%esp)
f01036ab:	f0 
f01036ac:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01036b3:	f0 
f01036b4:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01036bb:	00 
f01036bc:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01036c3:	e8 78 c9 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01036c8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01036cd:	76 55                	jbe    f0103724 <mem_init+0x1b7d>
				assert(pgdir[i] & PTE_P);
f01036cf:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01036d2:	f6 c2 01             	test   $0x1,%dl
f01036d5:	75 24                	jne    f01036fb <mem_init+0x1b54>
f01036d7:	c7 44 24 0c 38 87 10 	movl   $0xf0108738,0xc(%esp)
f01036de:	f0 
f01036df:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01036e6:	f0 
f01036e7:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01036ee:	00 
f01036ef:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01036f6:	e8 45 c9 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01036fb:	f6 c2 02             	test   $0x2,%dl
f01036fe:	75 4e                	jne    f010374e <mem_init+0x1ba7>
f0103700:	c7 44 24 0c 49 87 10 	movl   $0xf0108749,0xc(%esp)
f0103707:	f0 
f0103708:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010370f:	f0 
f0103710:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0103717:	00 
f0103718:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010371f:	e8 1c c9 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103724:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103728:	74 24                	je     f010374e <mem_init+0x1ba7>
f010372a:	c7 44 24 0c 5a 87 10 	movl   $0xf010875a,0xc(%esp)
f0103731:	f0 
f0103732:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103739:	f0 
f010373a:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0103741:	00 
f0103742:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103749:	e8 f2 c8 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010374e:	83 c0 01             	add    $0x1,%eax
f0103751:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103756:	0f 85 33 ff ff ff    	jne    f010368f <mem_init+0x1ae8>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010375c:	c7 04 24 60 83 10 f0 	movl   $0xf0108360,(%esp)
f0103763:	e8 9a 0e 00 00       	call   f0104602 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103768:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010376d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103772:	77 20                	ja     f0103794 <mem_init+0x1bed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103774:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103778:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f010377f:	f0 
f0103780:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0103787:	00 
f0103788:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010378f:	e8 ac c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103794:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103799:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010379c:	b8 00 00 00 00       	mov    $0x0,%eax
f01037a1:	e8 86 db ff ff       	call   f010132c <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01037a6:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01037a9:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01037ae:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01037b1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01037b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037bb:	e8 e2 df ff ff       	call   f01017a2 <page_alloc>
f01037c0:	89 c6                	mov    %eax,%esi
f01037c2:	85 c0                	test   %eax,%eax
f01037c4:	75 24                	jne    f01037ea <mem_init+0x1c43>
f01037c6:	c7 44 24 0c 65 85 10 	movl   $0xf0108565,0xc(%esp)
f01037cd:	f0 
f01037ce:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01037d5:	f0 
f01037d6:	c7 44 24 04 bf 04 00 	movl   $0x4bf,0x4(%esp)
f01037dd:	00 
f01037de:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01037e5:	e8 56 c8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01037ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037f1:	e8 ac df ff ff       	call   f01017a2 <page_alloc>
f01037f6:	89 c7                	mov    %eax,%edi
f01037f8:	85 c0                	test   %eax,%eax
f01037fa:	75 24                	jne    f0103820 <mem_init+0x1c79>
f01037fc:	c7 44 24 0c 7b 85 10 	movl   $0xf010857b,0xc(%esp)
f0103803:	f0 
f0103804:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f010380b:	f0 
f010380c:	c7 44 24 04 c0 04 00 	movl   $0x4c0,0x4(%esp)
f0103813:	00 
f0103814:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f010381b:	e8 20 c8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103820:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103827:	e8 76 df ff ff       	call   f01017a2 <page_alloc>
f010382c:	89 c3                	mov    %eax,%ebx
f010382e:	85 c0                	test   %eax,%eax
f0103830:	75 24                	jne    f0103856 <mem_init+0x1caf>
f0103832:	c7 44 24 0c 91 85 10 	movl   $0xf0108591,0xc(%esp)
f0103839:	f0 
f010383a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103841:	f0 
f0103842:	c7 44 24 04 c1 04 00 	movl   $0x4c1,0x4(%esp)
f0103849:	00 
f010384a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103851:	e8 ea c7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103856:	89 34 24             	mov    %esi,(%esp)
f0103859:	e8 c2 df ff ff       	call   f0101820 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010385e:	89 f8                	mov    %edi,%eax
f0103860:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0103866:	c1 f8 03             	sar    $0x3,%eax
f0103869:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010386c:	89 c2                	mov    %eax,%edx
f010386e:	c1 ea 0c             	shr    $0xc,%edx
f0103871:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0103877:	72 20                	jb     f0103899 <mem_init+0x1cf2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103879:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010387d:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0103884:	f0 
f0103885:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f010388c:	00 
f010388d:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f0103894:	e8 a7 c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103899:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038a0:	00 
f01038a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01038a8:	00 
	return (void *)(pa + KERNBASE);
f01038a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038ae:	89 04 24             	mov    %eax,(%esp)
f01038b1:	e8 7b 2c 00 00       	call   f0106531 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01038b6:	89 d8                	mov    %ebx,%eax
f01038b8:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f01038be:	c1 f8 03             	sar    $0x3,%eax
f01038c1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038c4:	89 c2                	mov    %eax,%edx
f01038c6:	c1 ea 0c             	shr    $0xc,%edx
f01038c9:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f01038cf:	72 20                	jb     f01038f1 <mem_init+0x1d4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038d5:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01038dc:	f0 
f01038dd:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01038e4:	00 
f01038e5:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f01038ec:	e8 4f c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01038f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038f8:	00 
f01038f9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103900:	00 
	return (void *)(pa + KERNBASE);
f0103901:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103906:	89 04 24             	mov    %eax,(%esp)
f0103909:	e8 23 2c 00 00       	call   f0106531 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010390e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103915:	00 
f0103916:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010391d:	00 
f010391e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103922:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103927:	89 04 24             	mov    %eax,(%esp)
f010392a:	e8 57 e1 ff ff       	call   f0101a86 <page_insert>
	assert(pp1->pp_ref == 1);
f010392f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103934:	74 24                	je     f010395a <mem_init+0x1db3>
f0103936:	c7 44 24 0c 62 86 10 	movl   $0xf0108662,0xc(%esp)
f010393d:	f0 
f010393e:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103945:	f0 
f0103946:	c7 44 24 04 c6 04 00 	movl   $0x4c6,0x4(%esp)
f010394d:	00 
f010394e:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103955:	e8 e6 c6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010395a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103961:	01 01 01 
f0103964:	74 24                	je     f010398a <mem_init+0x1de3>
f0103966:	c7 44 24 0c 80 83 10 	movl   $0xf0108380,0xc(%esp)
f010396d:	f0 
f010396e:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103975:	f0 
f0103976:	c7 44 24 04 c7 04 00 	movl   $0x4c7,0x4(%esp)
f010397d:	00 
f010397e:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103985:	e8 b6 c6 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010398a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103991:	00 
f0103992:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103999:	00 
f010399a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010399e:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f01039a3:	89 04 24             	mov    %eax,(%esp)
f01039a6:	e8 db e0 ff ff       	call   f0101a86 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01039ab:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01039b2:	02 02 02 
f01039b5:	74 24                	je     f01039db <mem_init+0x1e34>
f01039b7:	c7 44 24 0c a4 83 10 	movl   $0xf01083a4,0xc(%esp)
f01039be:	f0 
f01039bf:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01039c6:	f0 
f01039c7:	c7 44 24 04 c9 04 00 	movl   $0x4c9,0x4(%esp)
f01039ce:	00 
f01039cf:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f01039d6:	e8 65 c6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01039db:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01039e0:	74 24                	je     f0103a06 <mem_init+0x1e5f>
f01039e2:	c7 44 24 0c 84 86 10 	movl   $0xf0108684,0xc(%esp)
f01039e9:	f0 
f01039ea:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f01039f1:	f0 
f01039f2:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f01039f9:	00 
f01039fa:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103a01:	e8 3a c6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103a06:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103a0b:	74 24                	je     f0103a31 <mem_init+0x1e8a>
f0103a0d:	c7 44 24 0c cd 86 10 	movl   $0xf01086cd,0xc(%esp)
f0103a14:	f0 
f0103a15:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103a1c:	f0 
f0103a1d:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f0103a24:	00 
f0103a25:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103a2c:	e8 0f c6 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103a31:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103a38:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a3b:	89 d8                	mov    %ebx,%eax
f0103a3d:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0103a43:	c1 f8 03             	sar    $0x3,%eax
f0103a46:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a49:	89 c2                	mov    %eax,%edx
f0103a4b:	c1 ea 0c             	shr    $0xc,%edx
f0103a4e:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0103a54:	72 20                	jb     f0103a76 <mem_init+0x1ecf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a56:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a5a:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0103a61:	f0 
f0103a62:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103a69:	00 
f0103a6a:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f0103a71:	e8 ca c5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a76:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a7d:	03 03 03 
f0103a80:	74 24                	je     f0103aa6 <mem_init+0x1eff>
f0103a82:	c7 44 24 0c c8 83 10 	movl   $0xf01083c8,0xc(%esp)
f0103a89:	f0 
f0103a8a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103a91:	f0 
f0103a92:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f0103a99:	00 
f0103a9a:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103aa1:	e8 9a c5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103aa6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103aad:	00 
f0103aae:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103ab3:	89 04 24             	mov    %eax,(%esp)
f0103ab6:	e8 7b df ff ff       	call   f0101a36 <page_remove>
	assert(pp2->pp_ref == 0);
f0103abb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103ac0:	74 24                	je     f0103ae6 <mem_init+0x1f3f>
f0103ac2:	c7 44 24 0c bc 86 10 	movl   $0xf01086bc,0xc(%esp)
f0103ac9:	f0 
f0103aca:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103ad1:	f0 
f0103ad2:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f0103ad9:	00 
f0103ada:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103ae1:	e8 5a c5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103ae6:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103aeb:	8b 08                	mov    (%eax),%ecx
f0103aed:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103af3:	89 f2                	mov    %esi,%edx
f0103af5:	2b 15 90 ce 20 f0    	sub    0xf020ce90,%edx
f0103afb:	c1 fa 03             	sar    $0x3,%edx
f0103afe:	c1 e2 0c             	shl    $0xc,%edx
f0103b01:	39 d1                	cmp    %edx,%ecx
f0103b03:	74 24                	je     f0103b29 <mem_init+0x1f82>
f0103b05:	c7 44 24 0c 88 7d 10 	movl   $0xf0107d88,0xc(%esp)
f0103b0c:	f0 
f0103b0d:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103b14:	f0 
f0103b15:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
f0103b1c:	00 
f0103b1d:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103b24:	e8 17 c5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103b29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103b2f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103b34:	74 24                	je     f0103b5a <mem_init+0x1fb3>
f0103b36:	c7 44 24 0c 73 86 10 	movl   $0xf0108673,0xc(%esp)
f0103b3d:	f0 
f0103b3e:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0103b45:	f0 
f0103b46:	c7 44 24 04 d4 04 00 	movl   $0x4d4,0x4(%esp)
f0103b4d:	00 
f0103b4e:	c7 04 24 55 84 10 f0 	movl   $0xf0108455,(%esp)
f0103b55:	e8 e6 c4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103b5a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103b60:	89 34 24             	mov    %esi,(%esp)
f0103b63:	e8 b8 dc ff ff       	call   f0101820 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b68:	c7 04 24 f4 83 10 f0 	movl   $0xf01083f4,(%esp)
f0103b6f:	e8 8e 0a 00 00       	call   f0104602 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103b74:	83 c4 3c             	add    $0x3c,%esp
f0103b77:	5b                   	pop    %ebx
f0103b78:	5e                   	pop    %esi
f0103b79:	5f                   	pop    %edi
f0103b7a:	5d                   	pop    %ebp
f0103b7b:	c3                   	ret    
	// LAB 4: Your code here:
	int i=0;
	for(; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);

		boot_map_region(
f0103b7c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103b83:	00 
f0103b84:	c7 04 24 00 e0 20 00 	movl   $0x20e000,(%esp)
f0103b8b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103b90:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103b95:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
f0103b9a:	e8 7c dd ff ff       	call   f010191b <boot_map_region>
f0103b9f:	bb 00 60 21 f0       	mov    $0xf0216000,%ebx
f0103ba4:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0103ba9:	e9 fd f7 ff ff       	jmp    f01033ab <mem_init+0x1804>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103bae:	89 da                	mov    %ebx,%edx
f0103bb0:	89 f8                	mov    %edi,%eax
f0103bb2:	e8 19 d6 ff ff       	call   f01011d0 <check_va2pa>
f0103bb7:	e9 2b fa ff ff       	jmp    f01035e7 <mem_init+0x1a40>

f0103bbc <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103bbc:	55                   	push   %ebp
f0103bbd:	89 e5                	mov    %esp,%ebp
f0103bbf:	57                   	push   %edi
f0103bc0:	56                   	push   %esi
f0103bc1:	53                   	push   %ebx
f0103bc2:	83 ec 2c             	sub    $0x2c,%esp
f0103bc5:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bc8:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
//cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0103bcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bce:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
f0103bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bd7:	03 45 10             	add    0x10(%ebp),%eax
f0103bda:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103bdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103be4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	}

//cprintf("user_mem_check success va: %x, len: %x\n", va, len);

	return 0;
f0103be7:	b8 00 00 00 00       	mov    $0x0,%eax
	// LAB 3: Your code here.
//cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f0103bec:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103bef:	73 53                	jae    f0103c44 <user_mem_check+0x88>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)_va_start, 0);
f0103bf1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103bf8:	00 
f0103bf9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103bfd:	8b 46 60             	mov    0x60(%esi),%eax
f0103c00:	89 04 24             	mov    %eax,(%esp)
f0103c03:	e8 73 dc ff ff       	call   f010187b <pgdir_walk>

        if ((_va_start>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103c08:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103c0e:	77 10                	ja     f0103c20 <user_mem_check+0x64>
f0103c10:	85 c0                	test   %eax,%eax
f0103c12:	74 0c                	je     f0103c20 <user_mem_check+0x64>
f0103c14:	8b 00                	mov    (%eax),%eax
f0103c16:	a8 01                	test   $0x1,%al
f0103c18:	74 06                	je     f0103c20 <user_mem_check+0x64>
f0103c1a:	21 f8                	and    %edi,%eax
f0103c1c:	39 c7                	cmp    %eax,%edi
f0103c1e:	74 14                	je     f0103c34 <user_mem_check+0x78>
            user_mem_check_addr = (_va_start<(uint32_t)va) ? (uint32_t)va : _va_start;
f0103c20:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103c23:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103c27:	89 1d 44 c2 20 f0    	mov    %ebx,0xf020c244
//cprintf("user_mem_check fail va: %x, len: %x\n", va, len);
            return -E_FAULT;
f0103c2d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103c32:	eb 10                	jmp    f0103c44 <user_mem_check+0x88>
	// LAB 3: Your code here.
//cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f0103c34:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103c3a:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103c3d:	77 b2                	ja     f0103bf1 <user_mem_check+0x35>

	}

//cprintf("user_mem_check success va: %x, len: %x\n", va, len);

	return 0;
f0103c3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c44:	83 c4 2c             	add    $0x2c,%esp
f0103c47:	5b                   	pop    %ebx
f0103c48:	5e                   	pop    %esi
f0103c49:	5f                   	pop    %edi
f0103c4a:	5d                   	pop    %ebp
f0103c4b:	c3                   	ret    

f0103c4c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103c4c:	55                   	push   %ebp
f0103c4d:	89 e5                	mov    %esp,%ebp
f0103c4f:	53                   	push   %ebx
f0103c50:	83 ec 14             	sub    $0x14,%esp
f0103c53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103c56:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c59:	83 c8 04             	or     $0x4,%eax
f0103c5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c60:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c63:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c67:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c6e:	89 1c 24             	mov    %ebx,(%esp)
f0103c71:	e8 46 ff ff ff       	call   f0103bbc <user_mem_check>
f0103c76:	85 c0                	test   %eax,%eax
f0103c78:	79 24                	jns    f0103c9e <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103c7a:	a1 44 c2 20 f0       	mov    0xf020c244,%eax
f0103c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c83:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c8a:	c7 04 24 20 84 10 f0 	movl   $0xf0108420,(%esp)
f0103c91:	e8 6c 09 00 00       	call   f0104602 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103c96:	89 1c 24             	mov    %ebx,(%esp)
f0103c99:	e8 90 06 00 00       	call   f010432e <env_destroy>
	}
}
f0103c9e:	83 c4 14             	add    $0x14,%esp
f0103ca1:	5b                   	pop    %ebx
f0103ca2:	5d                   	pop    %ebp
f0103ca3:	c3                   	ret    

f0103ca4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103ca4:	55                   	push   %ebp
f0103ca5:	89 e5                	mov    %esp,%ebp
f0103ca7:	57                   	push   %edi
f0103ca8:	56                   	push   %esi
f0103ca9:	53                   	push   %ebx
f0103caa:	83 ec 2c             	sub    $0x2c,%esp
f0103cad:	89 c7                	mov    %eax,%edi
	//   (Watch out for corner-cases!)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
f0103caf:	89 d3                	mov    %edx,%ebx
f0103cb1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103cb7:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0103cbd:	c1 e8 0c             	shr    $0xc,%eax
f0103cc0:	85 c0                	test   %eax,%eax
f0103cc2:	74 5d                	je     f0103d21 <region_alloc+0x7d>
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
f0103cc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103cc7:	be 00 00 00 00       	mov    $0x0,%esi
		struct PageInfo *p = page_alloc(0);
f0103ccc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103cd3:	e8 ca da ff ff       	call   f01017a2 <page_alloc>
		if(!p)
f0103cd8:	85 c0                	test   %eax,%eax
f0103cda:	75 1c                	jne    f0103cf8 <region_alloc+0x54>
			panic("region_alloc failed!");
f0103cdc:	c7 44 24 08 68 87 10 	movl   $0xf0108768,0x8(%esp)
f0103ce3:	f0 
f0103ce4:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0103ceb:	00 
f0103cec:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f0103cf3:	e8 48 c3 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
f0103cf8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103cff:	00 
f0103d00:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d08:	8b 47 60             	mov    0x60(%edi),%eax
f0103d0b:	89 04 24             	mov    %eax,(%esp)
f0103d0e:	e8 73 dd ff ff       	call   f0101a86 <page_insert>

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103d13:	83 c6 01             	add    $0x1,%esi
f0103d16:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103d1c:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103d1f:	75 ab                	jne    f0103ccc <region_alloc+0x28>
		struct PageInfo *p = page_alloc(0);
		if(!p)
			panic("region_alloc failed!");
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
	}
}
f0103d21:	83 c4 2c             	add    $0x2c,%esp
f0103d24:	5b                   	pop    %ebx
f0103d25:	5e                   	pop    %esi
f0103d26:	5f                   	pop    %edi
f0103d27:	5d                   	pop    %ebp
f0103d28:	c3                   	ret    

f0103d29 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103d29:	55                   	push   %ebp
f0103d2a:	89 e5                	mov    %esp,%ebp
f0103d2c:	83 ec 18             	sub    $0x18,%esp
f0103d2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103d32:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103d35:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103d38:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103d3e:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103d42:	85 c0                	test   %eax,%eax
f0103d44:	75 17                	jne    f0103d5d <envid2env+0x34>
		*env_store = curenv;
f0103d46:	e8 75 2e 00 00       	call   f0106bc0 <cpunum>
f0103d4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d4e:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103d54:	89 06                	mov    %eax,(%esi)
		return 0;
f0103d56:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d5b:	eb 67                	jmp    f0103dc4 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103d5d:	89 c3                	mov    %eax,%ebx
f0103d5f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103d65:	c1 e3 07             	shl    $0x7,%ebx
f0103d68:	03 1d 48 c2 20 f0    	add    0xf020c248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103d6e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103d72:	74 05                	je     f0103d79 <envid2env+0x50>
f0103d74:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103d77:	74 0d                	je     f0103d86 <envid2env+0x5d>
		*env_store = 0;
f0103d79:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103d7f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d84:	eb 3e                	jmp    f0103dc4 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103d86:	84 d2                	test   %dl,%dl
f0103d88:	74 33                	je     f0103dbd <envid2env+0x94>
f0103d8a:	e8 31 2e 00 00       	call   f0106bc0 <cpunum>
f0103d8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d92:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f0103d98:	74 23                	je     f0103dbd <envid2env+0x94>
f0103d9a:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103d9d:	e8 1e 2e 00 00       	call   f0106bc0 <cpunum>
f0103da2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da5:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103dab:	3b 78 48             	cmp    0x48(%eax),%edi
f0103dae:	74 0d                	je     f0103dbd <envid2env+0x94>
		*env_store = 0;
f0103db0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103db6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103dbb:	eb 07                	jmp    f0103dc4 <envid2env+0x9b>
	}

	*env_store = e;
f0103dbd:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103dc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103dc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103dca:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103dcd:	89 ec                	mov    %ebp,%esp
f0103dcf:	5d                   	pop    %ebp
f0103dd0:	c3                   	ret    

f0103dd1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103dd1:	55                   	push   %ebp
f0103dd2:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103dd4:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0103dd9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103ddc:	b8 23 00 00 00       	mov    $0x23,%eax
f0103de1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103de3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103de5:	b0 10                	mov    $0x10,%al
f0103de7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103de9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103deb:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103ded:	ea f4 3d 10 f0 08 00 	ljmp   $0x8,$0xf0103df4
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103df4:	b0 00                	mov    $0x0,%al
f0103df6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103df9:	5d                   	pop    %ebp
f0103dfa:	c3                   	ret    

f0103dfb <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103dfb:	55                   	push   %ebp
f0103dfc:	89 e5                	mov    %esp,%ebp
f0103dfe:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	envs[0].env_id = 0;
f0103dff:	8b 15 48 c2 20 f0    	mov    0xf020c248,%edx
f0103e05:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
	env_free_list = envs;
f0103e0c:	89 15 4c c2 20 f0    	mov    %edx,0xf020c24c
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103e12:	8d 82 80 00 00 00    	lea    0x80(%edx),%eax
f0103e18:	8d 9a 00 00 02 00    	lea    0x20000(%edx),%ebx
f0103e1e:	eb 02                	jmp    f0103e22 <env_init+0x27>

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
		_env->env_link = &envs[i];
		_env = _env->env_link;
f0103e20:	89 ca                	mov    %ecx,%edx
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
f0103e22:	89 c1                	mov    %eax,%ecx
f0103e24:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		_env->env_link = &envs[i];
f0103e2b:	89 42 44             	mov    %eax,0x44(%edx)
f0103e2e:	83 e8 80             	sub    $0xffffff80,%eax
	envs[0].env_id = 0;
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
f0103e31:	39 d8                	cmp    %ebx,%eax
f0103e33:	75 eb                	jne    f0103e20 <env_init+0x25>
		_env->env_link = &envs[i];
		_env = _env->env_link;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103e35:	e8 97 ff ff ff       	call   f0103dd1 <env_init_percpu>
}
f0103e3a:	5b                   	pop    %ebx
f0103e3b:	5d                   	pop    %ebp
f0103e3c:	c3                   	ret    

f0103e3d <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103e3d:	55                   	push   %ebp
f0103e3e:	89 e5                	mov    %esp,%ebp
f0103e40:	53                   	push   %ebx
f0103e41:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103e44:	8b 1d 4c c2 20 f0    	mov    0xf020c24c,%ebx
f0103e4a:	85 db                	test   %ebx,%ebx
f0103e4c:	0f 84 88 01 00 00    	je     f0103fda <env_alloc+0x19d>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103e52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103e59:	e8 44 d9 ff ff       	call   f01017a2 <page_alloc>
f0103e5e:	85 c0                	test   %eax,%eax
f0103e60:	0f 84 7b 01 00 00    	je     f0103fe1 <env_alloc+0x1a4>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	/*************************** LAB 3: Your code here.***************************/
	p->pp_ref ++;
f0103e66:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103e6b:	2b 05 90 ce 20 f0    	sub    0xf020ce90,%eax
f0103e71:	c1 f8 03             	sar    $0x3,%eax
f0103e74:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e77:	89 c2                	mov    %eax,%edx
f0103e79:	c1 ea 0c             	shr    $0xc,%edx
f0103e7c:	3b 15 88 ce 20 f0    	cmp    0xf020ce88,%edx
f0103e82:	72 20                	jb     f0103ea4 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e88:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0103e8f:	f0 
f0103e90:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103e97:	00 
f0103e98:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f0103e9f:	e8 9c c1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103ea4:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103ea9:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103eac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103eb3:	00 
f0103eb4:	8b 15 8c ce 20 f0    	mov    0xf020ce8c,%edx
f0103eba:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ebe:	89 04 24             	mov    %eax,(%esp)
f0103ec1:	e8 3f 27 00 00       	call   f0106605 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103ec6:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ec9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ece:	77 20                	ja     f0103ef0 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ed0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ed4:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0103edb:	f0 
f0103edc:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0103ee3:	00 
f0103ee4:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f0103eeb:	e8 50 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ef0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103ef6:	83 ca 05             	or     $0x5,%edx
f0103ef9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103eff:	8b 43 48             	mov    0x48(%ebx),%eax
f0103f02:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103f07:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103f0c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103f11:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103f14:	89 da                	mov    %ebx,%edx
f0103f16:	2b 15 48 c2 20 f0    	sub    0xf020c248,%edx
f0103f1c:	c1 fa 07             	sar    $0x7,%edx
f0103f1f:	09 d0                	or     %edx,%eax
f0103f21:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103f24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f27:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103f2a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103f31:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103f38:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103f3f:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103f46:	00 
f0103f47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103f4e:	00 
f0103f4f:	89 1c 24             	mov    %ebx,(%esp)
f0103f52:	e8 da 25 00 00       	call   f0106531 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103f57:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103f5d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103f63:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103f69:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103f70:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103f76:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103f7d:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103f84:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103f88:	8b 43 44             	mov    0x44(%ebx),%eax
f0103f8b:	a3 4c c2 20 f0       	mov    %eax,0xf020c24c
	*newenv_store = e;
f0103f90:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f93:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f95:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103f98:	e8 23 2c 00 00       	call   f0106bc0 <cpunum>
f0103f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103fa5:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0103fac:	74 11                	je     f0103fbf <env_alloc+0x182>
f0103fae:	e8 0d 2c 00 00       	call   f0106bc0 <cpunum>
f0103fb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb6:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0103fbc:	8b 50 48             	mov    0x48(%eax),%edx
f0103fbf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103fc7:	c7 04 24 88 87 10 f0 	movl   $0xf0108788,(%esp)
f0103fce:	e8 2f 06 00 00       	call   f0104602 <cprintf>
	return 0;
f0103fd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fd8:	eb 0c                	jmp    f0103fe6 <env_alloc+0x1a9>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103fda:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103fdf:	eb 05                	jmp    f0103fe6 <env_alloc+0x1a9>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103fe1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103fe6:	83 c4 14             	add    $0x14,%esp
f0103fe9:	5b                   	pop    %ebx
f0103fea:	5d                   	pop    %ebp
f0103feb:	c3                   	ret    

f0103fec <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103fec:	55                   	push   %ebp
f0103fed:	89 e5                	mov    %esp,%ebp
f0103fef:	57                   	push   %edi
f0103ff0:	56                   	push   %esi
f0103ff1:	53                   	push   %ebx
f0103ff2:	83 ec 3c             	sub    $0x3c,%esp
f0103ff5:	8b 7d 08             	mov    0x8(%ebp),%edi

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	struct Env *env;
	int res;
	if ((res = env_alloc(&env, 0)))
f0103ff8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fff:	00 
f0104000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104003:	89 04 24             	mov    %eax,(%esp)
f0104006:	e8 32 fe ff ff       	call   f0103e3d <env_alloc>
f010400b:	85 c0                	test   %eax,%eax
f010400d:	74 20                	je     f010402f <env_create+0x43>
		panic("env_create: %e", res);
f010400f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104013:	c7 44 24 08 9d 87 10 	movl   $0xf010879d,0x8(%esp)
f010401a:	f0 
f010401b:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
f0104022:	00 
f0104023:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f010402a:	e8 11 c0 ff ff       	call   f0100040 <_panic>

	load_icode(env, binary, size);
f010402f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104032:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f0104035:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010403b:	74 1c                	je     f0104059 <env_create+0x6d>
		panic("Invalid ELF!");
f010403d:	c7 44 24 08 ac 87 10 	movl   $0xf01087ac,0x8(%esp)
f0104044:	f0 
f0104045:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f010404c:	00 
f010404d:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f0104054:	e8 e7 bf ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104059:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f010405c:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
f0104060:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104063:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104066:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010406b:	77 20                	ja     f010408d <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010406d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104071:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0104078:	f0 
f0104079:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0104080:	00 
f0104081:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f0104088:	e8 b3 bf ff ff       	call   f0100040 <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
		panic("Invalid ELF!");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010408d:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f010408f:	0f b7 f6             	movzwl %si,%esi
f0104092:	c1 e6 05             	shl    $0x5,%esi
f0104095:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f0104097:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010409c:	0f 22 d8             	mov    %eax,%cr3

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f010409f:	39 f3                	cmp    %esi,%ebx
f01040a1:	73 4f                	jae    f01040f2 <env_create+0x106>
		if (ph->p_type != ELF_PROG_LOAD)
f01040a3:	83 3b 01             	cmpl   $0x1,(%ebx)
f01040a6:	75 43                	jne    f01040eb <env_create+0xff>
			continue;
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f01040a8:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01040ab:	8b 53 08             	mov    0x8(%ebx),%edx
f01040ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040b1:	e8 ee fb ff ff       	call   f0103ca4 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f01040b6:	8b 43 14             	mov    0x14(%ebx),%eax
f01040b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01040c4:	00 
f01040c5:	8b 43 08             	mov    0x8(%ebx),%eax
f01040c8:	89 04 24             	mov    %eax,(%esp)
f01040cb:	e8 61 24 00 00       	call   f0106531 <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01040d0:	8b 43 10             	mov    0x10(%ebx),%eax
f01040d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040d7:	89 f8                	mov    %edi,%eax
f01040d9:	03 43 04             	add    0x4(%ebx),%eax
f01040dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e0:	8b 43 08             	mov    0x8(%ebx),%eax
f01040e3:	89 04 24             	mov    %eax,(%esp)
f01040e6:	e8 a1 24 00 00       	call   f010658c <memmove>
	eph = ph + elf->e_phnum;

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01040eb:	83 c3 20             	add    $0x20,%ebx
f01040ee:	39 de                	cmp    %ebx,%esi
f01040f0:	77 b1                	ja     f01040a3 <env_create+0xb7>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
		memset((void*)ph->p_va, 0, ph->p_memsz);
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}
	// switch back to kernel page directory
	lcr3(PADDR(kern_pgdir));
f01040f2:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040fc:	77 20                	ja     f010411e <env_create+0x132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104102:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0104109:	f0 
f010410a:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f0104111:	00 
f0104112:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f0104119:	e8 22 bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010411e:	05 00 00 00 10       	add    $0x10000000,%eax
f0104123:	0f 22 d8             	mov    %eax,%cr3

	(e->env_tf).tf_eip = (uintptr_t)(elf->e_entry);
f0104126:	8b 47 18             	mov    0x18(%edi),%eax
f0104129:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010412c:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f010412f:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0104134:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104139:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010413c:	e8 63 fb ff ff       	call   f0103ca4 <region_alloc>
	if ((res = env_alloc(&env, 0)))
		panic("env_create: %e", res);

	load_icode(env, binary, size);

	env->env_type = type;
f0104141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104144:	8b 55 10             	mov    0x10(%ebp),%edx
f0104147:	89 50 50             	mov    %edx,0x50(%eax)

	if(type == ENV_TYPE_FS) {
f010414a:	83 fa 01             	cmp    $0x1,%edx
f010414d:	75 07                	jne    f0104156 <env_create+0x16a>
		env->env_tf.tf_eflags |= FL_IOPL_MASK;
f010414f:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f0104156:	83 c4 3c             	add    $0x3c,%esp
f0104159:	5b                   	pop    %ebx
f010415a:	5e                   	pop    %esi
f010415b:	5f                   	pop    %edi
f010415c:	5d                   	pop    %ebp
f010415d:	c3                   	ret    

f010415e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010415e:	55                   	push   %ebp
f010415f:	89 e5                	mov    %esp,%ebp
f0104161:	57                   	push   %edi
f0104162:	56                   	push   %esi
f0104163:	53                   	push   %ebx
f0104164:	83 ec 2c             	sub    $0x2c,%esp
f0104167:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010416a:	e8 51 2a 00 00       	call   f0106bc0 <cpunum>
f010416f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104172:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0104179:	39 b8 28 d0 20 f0    	cmp    %edi,-0xfdf2fd8(%eax)
f010417f:	75 3b                	jne    f01041bc <env_free+0x5e>
		lcr3(PADDR(kern_pgdir));
f0104181:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104186:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010418b:	77 20                	ja     f01041ad <env_free+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010418d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104191:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0104198:	f0 
f0104199:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f01041a0:	00 
f01041a1:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f01041a8:	e8 93 be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01041ad:	05 00 00 00 10       	add    $0x10000000,%eax
f01041b2:	0f 22 d8             	mov    %eax,%cr3
f01041b5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
//cprintf("*****e->env_pgdir[pdeno]: up to now!\n");
		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01041bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041bf:	c1 e0 02             	shl    $0x2,%eax
f01041c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01041c5:	8b 47 60             	mov    0x60(%edi),%eax
f01041c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041cb:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01041ce:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01041d4:	0f 84 b8 00 00 00    	je     f0104292 <env_free+0x134>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01041da:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01041e0:	89 f0                	mov    %esi,%eax
f01041e2:	c1 e8 0c             	shr    $0xc,%eax
f01041e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01041e8:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f01041ee:	72 20                	jb     f0104210 <env_free+0xb2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01041f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01041f4:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01041fb:	f0 
f01041fc:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f0104203:	00 
f0104204:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f010420b:	e8 30 be ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104210:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104213:	c1 e2 16             	shl    $0x16,%edx
f0104216:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104219:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010421e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0104225:	01 
f0104226:	74 17                	je     f010423f <env_free+0xe1>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104228:	89 d8                	mov    %ebx,%eax
f010422a:	c1 e0 0c             	shl    $0xc,%eax
f010422d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104230:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104234:	8b 47 60             	mov    0x60(%edi),%eax
f0104237:	89 04 24             	mov    %eax,(%esp)
f010423a:	e8 f7 d7 ff ff       	call   f0101a36 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);
//cprintf("*****e entry: up to now!\n");
		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010423f:	83 c3 01             	add    $0x1,%ebx
f0104242:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0104248:	75 d4                	jne    f010421e <env_free+0xc0>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}
//cprintf("*****e table: up to now!\n");
		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010424a:	8b 47 60             	mov    0x60(%edi),%eax
f010424d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104250:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104257:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010425a:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f0104260:	72 1c                	jb     f010427e <env_free+0x120>
		panic("pa2page called with invalid pa");
f0104262:	c7 44 24 08 54 7c 10 	movl   $0xf0107c54,0x8(%esp)
f0104269:	f0 
f010426a:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104271:	00 
f0104272:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f0104279:	e8 c2 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010427e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104281:	c1 e0 03             	shl    $0x3,%eax
f0104284:	03 05 90 ce 20 f0    	add    0xf020ce90,%eax
		page_decref(pa2page(pa));
f010428a:	89 04 24             	mov    %eax,(%esp)
f010428d:	e8 c6 d5 ff ff       	call   f0101858 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104292:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0104296:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010429d:	0f 85 19 ff ff ff    	jne    f01041bc <env_free+0x5e>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}
//cprintf("*****e->env_pgdir: up to now!\n");
	// free the page directory
	pa = PADDR(e->env_pgdir);
f01042a3:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01042a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01042ab:	77 20                	ja     f01042cd <env_free+0x16f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01042ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042b1:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f01042b8:	f0 
f01042b9:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
f01042c0:	00 
f01042c1:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f01042c8:	e8 73 bd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01042cd:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01042d4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042d9:	c1 e8 0c             	shr    $0xc,%eax
f01042dc:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f01042e2:	72 1c                	jb     f0104300 <env_free+0x1a2>
		panic("pa2page called with invalid pa");
f01042e4:	c7 44 24 08 54 7c 10 	movl   $0xf0107c54,0x8(%esp)
f01042eb:	f0 
f01042ec:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01042f3:	00 
f01042f4:	c7 04 24 71 84 10 f0 	movl   $0xf0108471,(%esp)
f01042fb:	e8 40 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104300:	c1 e0 03             	shl    $0x3,%eax
f0104303:	03 05 90 ce 20 f0    	add    0xf020ce90,%eax
//cprintf("*****Get into page_decref!\n");
	page_decref(pa2page(pa));
f0104309:	89 04 24             	mov    %eax,(%esp)
f010430c:	e8 47 d5 ff ff       	call   f0101858 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104311:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104318:	a1 4c c2 20 f0       	mov    0xf020c24c,%eax
f010431d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0104320:	89 3d 4c c2 20 f0    	mov    %edi,0xf020c24c
}
f0104326:	83 c4 2c             	add    $0x2c,%esp
f0104329:	5b                   	pop    %ebx
f010432a:	5e                   	pop    %esi
f010432b:	5f                   	pop    %edi
f010432c:	5d                   	pop    %ebp
f010432d:	c3                   	ret    

f010432e <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010432e:	55                   	push   %ebp
f010432f:	89 e5                	mov    %esp,%ebp
f0104331:	53                   	push   %ebx
f0104332:	83 ec 14             	sub    $0x14,%esp
f0104335:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104338:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010433c:	75 19                	jne    f0104357 <env_destroy+0x29>
f010433e:	e8 7d 28 00 00       	call   f0106bc0 <cpunum>
f0104343:	6b c0 74             	imul   $0x74,%eax,%eax
f0104346:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f010434c:	74 09                	je     f0104357 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010434e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0104355:	eb 2f                	jmp    f0104386 <env_destroy+0x58>
	}
	env_free(e);
f0104357:	89 1c 24             	mov    %ebx,(%esp)
f010435a:	e8 ff fd ff ff       	call   f010415e <env_free>

	if (curenv == e) {
f010435f:	e8 5c 28 00 00       	call   f0106bc0 <cpunum>
f0104364:	6b c0 74             	imul   $0x74,%eax,%eax
f0104367:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f010436d:	75 17                	jne    f0104386 <env_destroy+0x58>
		curenv = NULL;
f010436f:	e8 4c 28 00 00       	call   f0106bc0 <cpunum>
f0104374:	6b c0 74             	imul   $0x74,%eax,%eax
f0104377:	c7 80 28 d0 20 f0 00 	movl   $0x0,-0xfdf2fd8(%eax)
f010437e:	00 00 00 
//cprintf("****destroy\n");
		sched_yield();
f0104381:	e8 ba 0c 00 00       	call   f0105040 <sched_yield>
	}
}
f0104386:	83 c4 14             	add    $0x14,%esp
f0104389:	5b                   	pop    %ebx
f010438a:	5d                   	pop    %ebp
f010438b:	c3                   	ret    

f010438c <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010438c:	55                   	push   %ebp
f010438d:	89 e5                	mov    %esp,%ebp
f010438f:	53                   	push   %ebx
f0104390:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104393:	e8 28 28 00 00       	call   f0106bc0 <cpunum>
f0104398:	6b c0 74             	imul   $0x74,%eax,%eax
f010439b:	8b 98 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%ebx
f01043a1:	e8 1a 28 00 00       	call   f0106bc0 <cpunum>
f01043a6:	89 43 5c             	mov    %eax,0x5c(%ebx)
//cprintf("**Start transfering\n");

	__asm __volatile("movl %0,%%esp\n"
f01043a9:	8b 65 08             	mov    0x8(%ebp),%esp
f01043ac:	61                   	popa   
f01043ad:	07                   	pop    %es
f01043ae:	1f                   	pop    %ds
f01043af:	83 c4 08             	add    $0x8,%esp
f01043b2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01043b3:	c7 44 24 08 b9 87 10 	movl   $0xf01087b9,0x8(%esp)
f01043ba:	f0 
f01043bb:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f01043c2:	00 
f01043c3:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f01043ca:	e8 71 bc ff ff       	call   f0100040 <_panic>

f01043cf <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01043cf:	55                   	push   %ebp
f01043d0:	89 e5                	mov    %esp,%ebp
f01043d2:	53                   	push   %ebx
f01043d3:	83 ec 14             	sub    $0x14,%esp
f01043d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f01043d9:	e8 e2 27 00 00       	call   f0106bc0 <cpunum>
f01043de:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e1:	39 98 28 d0 20 f0    	cmp    %ebx,-0xfdf2fd8(%eax)
f01043e7:	0f 84 85 00 00 00    	je     f0104472 <env_run+0xa3>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01043ed:	e8 ce 27 00 00       	call   f0106bc0 <cpunum>
f01043f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f5:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f01043fc:	74 29                	je     f0104427 <env_run+0x58>
f01043fe:	e8 bd 27 00 00       	call   f0106bc0 <cpunum>
f0104403:	6b c0 74             	imul   $0x74,%eax,%eax
f0104406:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010440c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104410:	75 15                	jne    f0104427 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0104412:	e8 a9 27 00 00       	call   f0106bc0 <cpunum>
f0104417:	6b c0 74             	imul   $0x74,%eax,%eax
f010441a:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104420:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0104427:	e8 94 27 00 00       	call   f0106bc0 <cpunum>
f010442c:	6b c0 74             	imul   $0x74,%eax,%eax
f010442f:	89 98 28 d0 20 f0    	mov    %ebx,-0xfdf2fd8(%eax)
		e->env_status = ENV_RUNNING;
f0104435:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f010443c:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0104440:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104443:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104448:	77 20                	ja     f010446a <env_run+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010444a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010444e:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0104455:	f0 
f0104456:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
f010445d:	00 
f010445e:	c7 04 24 7d 87 10 f0 	movl   $0xf010877d,(%esp)
f0104465:	e8 d6 bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010446a:	05 00 00 00 10       	add    $0x10000000,%eax
f010446f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104472:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104479:	e8 b5 2a 00 00       	call   f0106f33 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010447e:	f3 90                	pause  
	}

	unlock_kernel();

	env_pop_tf(&(curenv->env_tf));
f0104480:	e8 3b 27 00 00       	call   f0106bc0 <cpunum>
f0104485:	6b c0 74             	imul   $0x74,%eax,%eax
f0104488:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010448e:	89 04 24             	mov    %eax,(%esp)
f0104491:	e8 f6 fe ff ff       	call   f010438c <env_pop_tf>
	...

f0104498 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
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

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01044a4:	b2 71                	mov    $0x71,%dl
f01044a6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01044a7:	0f b6 c0             	movzbl %al,%eax
}
f01044aa:	5d                   	pop    %ebp
f01044ab:	c3                   	ret    

f01044ac <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01044ac:	55                   	push   %ebp
f01044ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01044af:	ba 70 00 00 00       	mov    $0x70,%edx
f01044b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01044b7:	ee                   	out    %al,(%dx)
f01044b8:	b2 71                	mov    $0x71,%dl
f01044ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044bd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01044be:	5d                   	pop    %ebp
f01044bf:	c3                   	ret    

f01044c0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01044c0:	55                   	push   %ebp
f01044c1:	89 e5                	mov    %esp,%ebp
f01044c3:	56                   	push   %esi
f01044c4:	53                   	push   %ebx
f01044c5:	83 ec 10             	sub    $0x10,%esp
f01044c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01044cb:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01044cd:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f01044d3:	80 3d 50 c2 20 f0 00 	cmpb   $0x0,0xf020c250
f01044da:	74 4e                	je     f010452a <irq_setmask_8259A+0x6a>
f01044dc:	ba 21 00 00 00       	mov    $0x21,%edx
f01044e1:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01044e2:	89 f0                	mov    %esi,%eax
f01044e4:	66 c1 e8 08          	shr    $0x8,%ax
f01044e8:	b2 a1                	mov    $0xa1,%dl
f01044ea:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01044eb:	c7 04 24 c5 87 10 f0 	movl   $0xf01087c5,(%esp)
f01044f2:	e8 0b 01 00 00       	call   f0104602 <cprintf>
	for (i = 0; i < 16; i++)
f01044f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01044fc:	0f b7 f6             	movzwl %si,%esi
f01044ff:	f7 d6                	not    %esi
f0104501:	0f a3 de             	bt     %ebx,%esi
f0104504:	73 10                	jae    f0104516 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0104506:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010450a:	c7 04 24 bf 8c 10 f0 	movl   $0xf0108cbf,(%esp)
f0104511:	e8 ec 00 00 00       	call   f0104602 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104516:	83 c3 01             	add    $0x1,%ebx
f0104519:	83 fb 10             	cmp    $0x10,%ebx
f010451c:	75 e3                	jne    f0104501 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010451e:	c7 04 24 36 87 10 f0 	movl   $0xf0108736,(%esp)
f0104525:	e8 d8 00 00 00       	call   f0104602 <cprintf>
}
f010452a:	83 c4 10             	add    $0x10,%esp
f010452d:	5b                   	pop    %ebx
f010452e:	5e                   	pop    %esi
f010452f:	5d                   	pop    %ebp
f0104530:	c3                   	ret    

f0104531 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104531:	55                   	push   %ebp
f0104532:	89 e5                	mov    %esp,%ebp
f0104534:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104537:	c6 05 50 c2 20 f0 01 	movb   $0x1,0xf020c250
f010453e:	ba 21 00 00 00       	mov    $0x21,%edx
f0104543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104548:	ee                   	out    %al,(%dx)
f0104549:	b2 a1                	mov    $0xa1,%dl
f010454b:	ee                   	out    %al,(%dx)
f010454c:	b2 20                	mov    $0x20,%dl
f010454e:	b8 11 00 00 00       	mov    $0x11,%eax
f0104553:	ee                   	out    %al,(%dx)
f0104554:	b2 21                	mov    $0x21,%dl
f0104556:	b8 20 00 00 00       	mov    $0x20,%eax
f010455b:	ee                   	out    %al,(%dx)
f010455c:	b8 04 00 00 00       	mov    $0x4,%eax
f0104561:	ee                   	out    %al,(%dx)
f0104562:	b8 03 00 00 00       	mov    $0x3,%eax
f0104567:	ee                   	out    %al,(%dx)
f0104568:	b2 a0                	mov    $0xa0,%dl
f010456a:	b8 11 00 00 00       	mov    $0x11,%eax
f010456f:	ee                   	out    %al,(%dx)
f0104570:	b2 a1                	mov    $0xa1,%dl
f0104572:	b8 28 00 00 00       	mov    $0x28,%eax
f0104577:	ee                   	out    %al,(%dx)
f0104578:	b8 02 00 00 00       	mov    $0x2,%eax
f010457d:	ee                   	out    %al,(%dx)
f010457e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104583:	ee                   	out    %al,(%dx)
f0104584:	b2 20                	mov    $0x20,%dl
f0104586:	b8 68 00 00 00       	mov    $0x68,%eax
f010458b:	ee                   	out    %al,(%dx)
f010458c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104591:	ee                   	out    %al,(%dx)
f0104592:	b2 a0                	mov    $0xa0,%dl
f0104594:	b8 68 00 00 00       	mov    $0x68,%eax
f0104599:	ee                   	out    %al,(%dx)
f010459a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010459f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01045a0:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01045a7:	66 83 f8 ff          	cmp    $0xffff,%ax
f01045ab:	74 0b                	je     f01045b8 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f01045ad:	0f b7 c0             	movzwl %ax,%eax
f01045b0:	89 04 24             	mov    %eax,(%esp)
f01045b3:	e8 08 ff ff ff       	call   f01044c0 <irq_setmask_8259A>
}
f01045b8:	c9                   	leave  
f01045b9:	c3                   	ret    
	...

f01045bc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01045bc:	55                   	push   %ebp
f01045bd:	89 e5                	mov    %esp,%ebp
f01045bf:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01045c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c5:	89 04 24             	mov    %eax,(%esp)
f01045c8:	e8 09 c2 ff ff       	call   f01007d6 <cputchar>
	*cnt++;
}
f01045cd:	c9                   	leave  
f01045ce:	c3                   	ret    

f01045cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01045cf:	55                   	push   %ebp
f01045d0:	89 e5                	mov    %esp,%ebp
f01045d2:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01045d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01045dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01045e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f1:	c7 04 24 bc 45 10 f0 	movl   $0xf01045bc,(%esp)
f01045f8:	e8 e1 16 00 00       	call   f0105cde <vprintfmt>
	return cnt;
}
f01045fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104600:	c9                   	leave  
f0104601:	c3                   	ret    

f0104602 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104602:	55                   	push   %ebp
f0104603:	89 e5                	mov    %esp,%ebp
f0104605:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104608:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010460b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010460f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104612:	89 04 24             	mov    %eax,(%esp)
f0104615:	e8 b5 ff ff ff       	call   f01045cf <vcprintf>
	va_end(ap);

	return cnt;
}
f010461a:	c9                   	leave  
f010461b:	c3                   	ret    
f010461c:	00 00                	add    %al,(%eax)
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
f0104629:	e8 92 25 00 00       	call   f0106bc0 <cpunum>
f010462e:	89 c3                	mov    %eax,%ebx
f0104630:	e8 8b 25 00 00       	call   f0106bc0 <cpunum>
f0104635:	6b db 74             	imul   $0x74,%ebx,%ebx
f0104638:	6b c0 74             	imul   $0x74,%eax,%eax
f010463b:	0f b6 80 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%eax
f0104642:	f7 d8                	neg    %eax
f0104644:	c1 e0 10             	shl    $0x10,%eax
f0104647:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010464c:	89 83 30 d0 20 f0    	mov    %eax,-0xfdf2fd0(%ebx)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104652:	e8 69 25 00 00       	call   f0106bc0 <cpunum>
f0104657:	6b c0 74             	imul   $0x74,%eax,%eax
f010465a:	66 c7 80 34 d0 20 f0 	movw   $0x10,-0xfdf2fcc(%eax)
f0104661:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0104663:	e8 58 25 00 00       	call   f0106bc0 <cpunum>
f0104668:	6b c0 74             	imul   $0x74,%eax,%eax
f010466b:	0f b6 98 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%ebx
f0104672:	83 c3 05             	add    $0x5,%ebx
f0104675:	e8 46 25 00 00       	call   f0106bc0 <cpunum>
f010467a:	89 c6                	mov    %eax,%esi
f010467c:	e8 3f 25 00 00       	call   f0106bc0 <cpunum>
f0104681:	89 c7                	mov    %eax,%edi
f0104683:	e8 38 25 00 00       	call   f0106bc0 <cpunum>
f0104688:	66 c7 04 dd 40 33 12 	movw   $0x68,-0xfedccc0(,%ebx,8)
f010468f:	f0 68 00 
f0104692:	6b f6 74             	imul   $0x74,%esi,%esi
f0104695:	81 c6 2c d0 20 f0    	add    $0xf020d02c,%esi
f010469b:	66 89 34 dd 42 33 12 	mov    %si,-0xfedccbe(,%ebx,8)
f01046a2:	f0 
f01046a3:	6b d7 74             	imul   $0x74,%edi,%edx
f01046a6:	81 c2 2c d0 20 f0    	add    $0xf020d02c,%edx
f01046ac:	c1 ea 10             	shr    $0x10,%edx
f01046af:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f01046b6:	c6 04 dd 45 33 12 f0 	movb   $0x99,-0xfedccbb(,%ebx,8)
f01046bd:	99 
f01046be:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f01046c5:	40 
f01046c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c9:	05 2c d0 20 f0       	add    $0xf020d02c,%eax
f01046ce:	c1 e8 18             	shr    $0x18,%eax
f01046d1:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
                    sizeof(struct Taskstate), 0);
    gdt[(GD_TSS0 >> 3)+thiscpu->cpu_id].sd_s = 0;
f01046d8:	e8 e3 24 00 00       	call   f0106bc0 <cpunum>
f01046dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e0:	0f b6 80 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%eax
f01046e7:	80 24 c5 6d 33 12 f0 	andb   $0xef,-0xfedcc93(,%eax,8)
f01046ee:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8*(thiscpu->cpu_id));
f01046ef:	e8 cc 24 00 00       	call   f0106bc0 <cpunum>
f01046f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f7:	0f b6 80 20 d0 20 f0 	movzbl -0xfdf2fe0(%eax),%eax
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
f010473c:	66 89 15 78 c2 20 f0 	mov    %dx,0xf020c278
f0104743:	66 c7 05 7a c2 20 f0 	movw   $0x8,0xf020c27a
f010474a:	08 00 
f010474c:	c6 05 7c c2 20 f0 00 	movb   $0x0,0xf020c27c
f0104753:	c6 05 7d c2 20 f0 ee 	movb   $0xee,0xf020c27d
f010475a:	c1 ea 10             	shr    $0x10,%edx
f010475d:	66 89 15 7e c2 20 f0 	mov    %dx,0xf020c27e
f0104764:	eb c5                	jmp    f010472b <trap_init+0x13>
		else if (i!=2 && i!=15) {
f0104766:	83 f8 02             	cmp    $0x2,%eax
f0104769:	74 39                	je     f01047a4 <trap_init+0x8c>
f010476b:	83 f8 0f             	cmp    $0xf,%eax
f010476e:	74 34                	je     f01047a4 <trap_init+0x8c>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0104770:	8b 1c 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%ebx
f0104777:	66 89 1c c5 60 c2 20 	mov    %bx,-0xfdf3da0(,%eax,8)
f010477e:	f0 
f010477f:	66 c7 04 c5 62 c2 20 	movw   $0x8,-0xfdf3d9e(,%eax,8)
f0104786:	f0 08 00 
f0104789:	c6 04 c5 64 c2 20 f0 	movb   $0x0,-0xfdf3d9c(,%eax,8)
f0104790:	00 
f0104791:	c6 04 c5 65 c2 20 f0 	movb   $0x8e,-0xfdf3d9b(,%eax,8)
f0104798:	8e 
f0104799:	c1 eb 10             	shr    $0x10,%ebx
f010479c:	66 89 1c c5 66 c2 20 	mov    %bx,-0xfdf3d9a(,%eax,8)
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
f01047ae:	66 a3 e0 c3 20 f0    	mov    %ax,0xf020c3e0
f01047b4:	66 c7 05 e2 c3 20 f0 	movw   $0x8,0xf020c3e2
f01047bb:	08 00 
f01047bd:	c6 05 e4 c3 20 f0 00 	movb   $0x0,0xf020c3e4
f01047c4:	c6 05 e5 c3 20 f0 ee 	movb   $0xee,0xf020c3e5
f01047cb:	c1 e8 10             	shr    $0x10,%eax
f01047ce:	66 a3 e6 c3 20 f0    	mov    %ax,0xf020c3e6
f01047d4:	b8 20 00 00 00       	mov    $0x20,%eax

	for (i = 0; i < 16; ++i)
    	SETGATE(idt[IRQ_OFFSET+i], 0, GD_KT, funs[IRQ_OFFSET+i], 0);
f01047d9:	8b 14 85 b4 33 12 f0 	mov    -0xfedcc4c(,%eax,4),%edx
f01047e0:	66 89 14 c5 60 c2 20 	mov    %dx,-0xfdf3da0(,%eax,8)
f01047e7:	f0 
f01047e8:	66 c7 04 c5 62 c2 20 	movw   $0x8,-0xfdf3d9e(,%eax,8)
f01047ef:	f0 08 00 
f01047f2:	c6 04 c5 64 c2 20 f0 	movb   $0x0,-0xfdf3d9c(,%eax,8)
f01047f9:	00 
f01047fa:	c6 04 c5 65 c2 20 f0 	movb   $0x8e,-0xfdf3d9b(,%eax,8)
f0104801:	8e 
f0104802:	c1 ea 10             	shr    $0x10,%edx
f0104805:	66 89 14 c5 66 c2 20 	mov    %dx,-0xfdf3d9a(,%eax,8)
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
f0104830:	c7 04 24 d9 87 10 f0 	movl   $0xf01087d9,(%esp)
f0104837:	e8 c6 fd ff ff       	call   f0104602 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010483c:	8b 43 04             	mov    0x4(%ebx),%eax
f010483f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104843:	c7 04 24 e8 87 10 f0 	movl   $0xf01087e8,(%esp)
f010484a:	e8 b3 fd ff ff       	call   f0104602 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010484f:	8b 43 08             	mov    0x8(%ebx),%eax
f0104852:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104856:	c7 04 24 f7 87 10 f0 	movl   $0xf01087f7,(%esp)
f010485d:	e8 a0 fd ff ff       	call   f0104602 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104862:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104865:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104869:	c7 04 24 06 88 10 f0 	movl   $0xf0108806,(%esp)
f0104870:	e8 8d fd ff ff       	call   f0104602 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104875:	8b 43 10             	mov    0x10(%ebx),%eax
f0104878:	89 44 24 04          	mov    %eax,0x4(%esp)
f010487c:	c7 04 24 15 88 10 f0 	movl   $0xf0108815,(%esp)
f0104883:	e8 7a fd ff ff       	call   f0104602 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104888:	8b 43 14             	mov    0x14(%ebx),%eax
f010488b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010488f:	c7 04 24 24 88 10 f0 	movl   $0xf0108824,(%esp)
f0104896:	e8 67 fd ff ff       	call   f0104602 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010489b:	8b 43 18             	mov    0x18(%ebx),%eax
f010489e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a2:	c7 04 24 33 88 10 f0 	movl   $0xf0108833,(%esp)
f01048a9:	e8 54 fd ff ff       	call   f0104602 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01048ae:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01048b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b5:	c7 04 24 42 88 10 f0 	movl   $0xf0108842,(%esp)
f01048bc:	e8 41 fd ff ff       	call   f0104602 <cprintf>
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
f01048d2:	e8 e9 22 00 00       	call   f0106bc0 <cpunum>
f01048d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048df:	c7 04 24 a6 88 10 f0 	movl   $0xf01088a6,(%esp)
f01048e6:	e8 17 fd ff ff       	call   f0104602 <cprintf>
	print_regs(&tf->tf_regs);
f01048eb:	89 1c 24             	mov    %ebx,(%esp)
f01048ee:	e8 2d ff ff ff       	call   f0104820 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01048f3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01048f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fb:	c7 04 24 c4 88 10 f0 	movl   $0xf01088c4,(%esp)
f0104902:	e8 fb fc ff ff       	call   f0104602 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104907:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010490b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010490f:	c7 04 24 d7 88 10 f0 	movl   $0xf01088d7,(%esp)
f0104916:	e8 e7 fc ff ff       	call   f0104602 <cprintf>
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
f0104923:	8b 14 85 60 8b 10 f0 	mov    -0xfef74a0(,%eax,4),%edx
f010492a:	eb 1d                	jmp    f0104949 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f010492c:	ba 51 88 10 f0       	mov    $0xf0108851,%edx
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
f010493c:	ba 5d 88 10 f0       	mov    $0xf010885d,%edx
f0104941:	b9 70 88 10 f0       	mov    $0xf0108870,%ecx
f0104946:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104949:	89 54 24 08          	mov    %edx,0x8(%esp)
f010494d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104951:	c7 04 24 ea 88 10 f0 	movl   $0xf01088ea,(%esp)
f0104958:	e8 a5 fc ff ff       	call   f0104602 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010495d:	3b 1d 60 ca 20 f0    	cmp    0xf020ca60,%ebx
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
f0104972:	c7 04 24 fc 88 10 f0 	movl   $0xf01088fc,(%esp)
f0104979:	e8 84 fc ff ff       	call   f0104602 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010497e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104981:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104985:	c7 04 24 0b 89 10 f0 	movl   $0xf010890b,(%esp)
f010498c:	e8 71 fc ff ff       	call   f0104602 <cprintf>
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
f010499f:	ba 7f 88 10 f0       	mov    $0xf010887f,%edx
f01049a4:	b9 8a 88 10 f0       	mov    $0xf010888a,%ecx
f01049a9:	0f 45 ca             	cmovne %edx,%ecx
f01049ac:	89 c2                	mov    %eax,%edx
f01049ae:	83 e2 02             	and    $0x2,%edx
f01049b1:	ba 96 88 10 f0       	mov    $0xf0108896,%edx
f01049b6:	be 9c 88 10 f0       	mov    $0xf010889c,%esi
f01049bb:	0f 44 d6             	cmove  %esi,%edx
f01049be:	83 e0 04             	and    $0x4,%eax
f01049c1:	b8 a1 88 10 f0       	mov    $0xf01088a1,%eax
f01049c6:	be d4 89 10 f0       	mov    $0xf01089d4,%esi
f01049cb:	0f 44 c6             	cmove  %esi,%eax
f01049ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01049d2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01049d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049da:	c7 04 24 19 89 10 f0 	movl   $0xf0108919,(%esp)
f01049e1:	e8 1c fc ff ff       	call   f0104602 <cprintf>
f01049e6:	eb 0c                	jmp    f01049f4 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01049e8:	c7 04 24 36 87 10 f0 	movl   $0xf0108736,(%esp)
f01049ef:	e8 0e fc ff ff       	call   f0104602 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01049f4:	8b 43 30             	mov    0x30(%ebx),%eax
f01049f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049fb:	c7 04 24 28 89 10 f0 	movl   $0xf0108928,(%esp)
f0104a02:	e8 fb fb ff ff       	call   f0104602 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104a07:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a0f:	c7 04 24 37 89 10 f0 	movl   $0xf0108937,(%esp)
f0104a16:	e8 e7 fb ff ff       	call   f0104602 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104a1b:	8b 43 38             	mov    0x38(%ebx),%eax
f0104a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a22:	c7 04 24 4a 89 10 f0 	movl   $0xf010894a,(%esp)
f0104a29:	e8 d4 fb ff ff       	call   f0104602 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104a2e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104a32:	74 27                	je     f0104a5b <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104a34:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104a37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a3b:	c7 04 24 59 89 10 f0 	movl   $0xf0108959,(%esp)
f0104a42:	e8 bb fb ff ff       	call   f0104602 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104a47:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a4f:	c7 04 24 68 89 10 f0 	movl   $0xf0108968,(%esp)
f0104a56:	e8 a7 fb ff ff       	call   f0104602 <cprintf>
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
f0104a89:	c7 44 24 08 7b 89 10 	movl   $0xf010897b,0x8(%esp)
f0104a90:	f0 
f0104a91:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f0104a98:	00 
f0104a99:	c7 04 24 96 89 10 f0 	movl   $0xf0108996,(%esp)
f0104aa0:	e8 9b b5 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104aa5:	e8 16 21 00 00       	call   f0106bc0 <cpunum>
f0104aaa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aad:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
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
f0104ada:	e8 e1 20 00 00       	call   f0106bc0 <cpunum>
f0104adf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104ae6:	00 
f0104ae7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104aee:	00 
f0104aef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104af2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104af6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af9:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104aff:	89 04 24             	mov    %eax,(%esp)
f0104b02:	e8 45 f1 ff ff       	call   f0103c4c <user_mem_assert>
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
f0104b77:	e8 44 20 00 00       	call   f0106bc0 <cpunum>
f0104b7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b7f:	8b 98 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%ebx
f0104b85:	e8 36 20 00 00       	call   f0106bc0 <cpunum>
f0104b8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b8d:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104b93:	8b 40 64             	mov    0x64(%eax),%eax
f0104b96:	89 43 30             	mov    %eax,0x30(%ebx)
        curenv->env_tf.tf_esp = utf_addr;
f0104b99:	e8 22 20 00 00       	call   f0106bc0 <cpunum>
f0104b9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba1:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104ba7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104baa:	89 50 3c             	mov    %edx,0x3c(%eax)
        env_run(curenv);
f0104bad:	e8 0e 20 00 00       	call   f0106bc0 <cpunum>
f0104bb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb5:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104bbb:	89 04 24             	mov    %eax,(%esp)
f0104bbe:	e8 0c f8 ff ff       	call   f01043cf <env_run>
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bc3:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104bc6:	e8 f5 1f 00 00       	call   f0106bc0 <cpunum>
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
f0104bd6:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
        curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
        curenv->env_tf.tf_esp = utf_addr;
        env_run(curenv);
    }
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104bdc:	8b 40 48             	mov    0x48(%eax),%eax
f0104bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104be3:	c7 04 24 20 8b 10 f0 	movl   $0xf0108b20,(%esp)
f0104bea:	e8 13 fa ff ff       	call   f0104602 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104bef:	89 1c 24             	mov    %ebx,(%esp)
f0104bf2:	e8 d0 fc ff ff       	call   f01048c7 <print_trapframe>
	env_destroy(curenv);
f0104bf7:	e8 c4 1f 00 00       	call   f0106bc0 <cpunum>
f0104bfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bff:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104c05:	89 04 24             	mov    %eax,(%esp)
f0104c08:	e8 21 f7 ff ff       	call   f010432e <env_destroy>
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
f0104c26:	e8 41 c4 ff ff       	call   f010106c <monitor>
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
f0104c39:	83 3d 80 ce 20 f0 00 	cmpl   $0x0,0xf020ce80
f0104c40:	74 01                	je     f0104c43 <trap+0x16>
		asm volatile("hlt");
f0104c42:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104c43:	e8 78 1f 00 00       	call   f0106bc0 <cpunum>
f0104c48:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c4b:	81 c2 20 d0 20 f0    	add    $0xf020d020,%edx
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
f0104c66:	e8 05 22 00 00       	call   f0106e70 <spin_lock>

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
f0104c72:	c7 44 24 0c a2 89 10 	movl   $0xf01089a2,0xc(%esp)
f0104c79:	f0 
f0104c7a:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0104c81:	f0 
f0104c82:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0104c89:	00 
f0104c8a:	c7 04 24 96 89 10 f0 	movl   $0xf0108996,(%esp)
f0104c91:	e8 aa b3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104c96:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104c9a:	83 e0 03             	and    $0x3,%eax
f0104c9d:	83 f8 03             	cmp    $0x3,%eax
f0104ca0:	0f 85 a7 00 00 00    	jne    f0104d4d <trap+0x120>
f0104ca6:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f0104cad:	e8 be 21 00 00       	call   f0106e70 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104cb2:	e8 09 1f 00 00       	call   f0106bc0 <cpunum>
f0104cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cba:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0104cc1:	75 24                	jne    f0104ce7 <trap+0xba>
f0104cc3:	c7 44 24 0c bb 89 10 	movl   $0xf01089bb,0xc(%esp)
f0104cca:	f0 
f0104ccb:	c7 44 24 08 8b 84 10 	movl   $0xf010848b,0x8(%esp)
f0104cd2:	f0 
f0104cd3:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f0104cda:	00 
f0104cdb:	c7 04 24 96 89 10 f0 	movl   $0xf0108996,(%esp)
f0104ce2:	e8 59 b3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104ce7:	e8 d4 1e 00 00       	call   f0106bc0 <cpunum>
f0104cec:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cef:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104cf5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104cf9:	75 2d                	jne    f0104d28 <trap+0xfb>
			env_free(curenv);
f0104cfb:	e8 c0 1e 00 00       	call   f0106bc0 <cpunum>
f0104d00:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d03:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104d09:	89 04 24             	mov    %eax,(%esp)
f0104d0c:	e8 4d f4 ff ff       	call   f010415e <env_free>
			curenv = NULL;
f0104d11:	e8 aa 1e 00 00       	call   f0106bc0 <cpunum>
f0104d16:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d19:	c7 80 28 d0 20 f0 00 	movl   $0x0,-0xfdf2fd8(%eax)
f0104d20:	00 00 00 
			sched_yield();
f0104d23:	e8 18 03 00 00       	call   f0105040 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104d28:	e8 93 1e 00 00       	call   f0106bc0 <cpunum>
f0104d2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d30:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104d36:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d3b:	89 c7                	mov    %eax,%edi
f0104d3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104d3f:	e8 7c 1e 00 00       	call   f0106bc0 <cpunum>
f0104d44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d47:	8b b0 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104d4d:	89 35 60 ca 20 f0    	mov    %esi,0xf020ca60
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
f0104d63:	e9 cb 00 00 00       	jmp    f0104e33 <trap+0x206>
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
f0104d75:	e9 b9 00 00 00       	jmp    f0104e33 <trap+0x206>
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if(tf->tf_trapno == T_BRKPT) {
f0104d7a:	83 f8 03             	cmp    $0x3,%eax
f0104d7d:	75 0d                	jne    f0104d8c <trap+0x15f>
//		cprintf("BREAK POINT!\n");
		breakpoint_handler(tf);
f0104d7f:	89 34 24             	mov    %esi,(%esp)
f0104d82:	e8 93 fe ff ff       	call   f0104c1a <breakpoint_handler>
f0104d87:	e9 a7 00 00 00       	jmp    f0104e33 <trap+0x206>
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
f0104dba:	e8 61 03 00 00       	call   f0105120 <syscall>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
		//cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
f0104dbf:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104dc2:	eb 6f                	jmp    f0104e33 <trap+0x206>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104dc4:	83 f8 20             	cmp    $0x20,%eax
f0104dc7:	75 0c                	jne    f0104dd5 <trap+0x1a8>
		lapic_eoi();
f0104dc9:	e8 3d 1f 00 00       	call   f0106d0b <lapic_eoi>
		sched_yield();
f0104dce:	66 90                	xchg   %ax,%ax
f0104dd0:	e8 6b 02 00 00       	call   f0105040 <sched_yield>
		return;
	}

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104dd5:	83 f8 21             	cmp    $0x21,%eax
f0104dd8:	75 08                	jne    f0104de2 <trap+0x1b5>
		kbd_intr();
f0104dda:	e8 77 b8 ff ff       	call   f0100656 <kbd_intr>
f0104ddf:	90                   	nop
f0104de0:	eb 51                	jmp    f0104e33 <trap+0x206>
		return;
	}

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0104de2:	83 f8 24             	cmp    $0x24,%eax
f0104de5:	75 0b                	jne    f0104df2 <trap+0x1c5>
		serial_intr();
f0104de7:	e8 4f b8 ff ff       	call   f010063b <serial_intr>
f0104dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104df0:	eb 41                	jmp    f0104e33 <trap+0x206>
		return;
	}


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104df2:	89 34 24             	mov    %esi,(%esp)
f0104df5:	e8 cd fa ff ff       	call   f01048c7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104dfa:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104dff:	75 1c                	jne    f0104e1d <trap+0x1f0>
		panic("unhandled trap in kernel");
f0104e01:	c7 44 24 08 c2 89 10 	movl   $0xf01089c2,0x8(%esp)
f0104e08:	f0 
f0104e09:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
f0104e10:	00 
f0104e11:	c7 04 24 96 89 10 f0 	movl   $0xf0108996,(%esp)
f0104e18:	e8 23 b2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104e1d:	e8 9e 1d 00 00       	call   f0106bc0 <cpunum>
f0104e22:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e25:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104e2b:	89 04 24             	mov    %eax,(%esp)
f0104e2e:	e8 fb f4 ff ff       	call   f010432e <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104e33:	e8 88 1d 00 00       	call   f0106bc0 <cpunum>
f0104e38:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e3b:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f0104e42:	74 2a                	je     f0104e6e <trap+0x241>
f0104e44:	e8 77 1d 00 00       	call   f0106bc0 <cpunum>
f0104e49:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e4c:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104e52:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e56:	75 16                	jne    f0104e6e <trap+0x241>
		env_run(curenv);
f0104e58:	e8 63 1d 00 00       	call   f0106bc0 <cpunum>
f0104e5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e60:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0104e66:	89 04 24             	mov    %eax,(%esp)
f0104e69:	e8 61 f5 ff ff       	call   f01043cf <env_run>
	else
		sched_yield();
f0104e6e:	e8 cd 01 00 00       	call   f0105040 <sched_yield>
	...

f0104e74 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec_entry(th0, 0)
f0104e74:	6a 00                	push   $0x0
f0104e76:	6a 00                	push   $0x0
f0104e78:	e9 cf 00 00 00       	jmp    f0104f4c <_alltraps>
f0104e7d:	90                   	nop

f0104e7e <th1>:
	noec_entry(th1, 1)
f0104e7e:	6a 00                	push   $0x0
f0104e80:	6a 01                	push   $0x1
f0104e82:	e9 c5 00 00 00       	jmp    f0104f4c <_alltraps>
f0104e87:	90                   	nop

f0104e88 <th3>:
	reserved_entry()
	noec_entry(th3, 3)
f0104e88:	6a 00                	push   $0x0
f0104e8a:	6a 03                	push   $0x3
f0104e8c:	e9 bb 00 00 00       	jmp    f0104f4c <_alltraps>
f0104e91:	90                   	nop

f0104e92 <th4>:
	noec_entry(th4, 4)
f0104e92:	6a 00                	push   $0x0
f0104e94:	6a 04                	push   $0x4
f0104e96:	e9 b1 00 00 00       	jmp    f0104f4c <_alltraps>
f0104e9b:	90                   	nop

f0104e9c <th5>:
	noec_entry(th5, 5)
f0104e9c:	6a 00                	push   $0x0
f0104e9e:	6a 05                	push   $0x5
f0104ea0:	e9 a7 00 00 00       	jmp    f0104f4c <_alltraps>
f0104ea5:	90                   	nop

f0104ea6 <th6>:
	noec_entry(th6, 6)
f0104ea6:	6a 00                	push   $0x0
f0104ea8:	6a 06                	push   $0x6
f0104eaa:	e9 9d 00 00 00       	jmp    f0104f4c <_alltraps>
f0104eaf:	90                   	nop

f0104eb0 <th7>:
	noec_entry(th7, 7)
f0104eb0:	6a 00                	push   $0x0
f0104eb2:	6a 07                	push   $0x7
f0104eb4:	e9 93 00 00 00       	jmp    f0104f4c <_alltraps>
f0104eb9:	90                   	nop

f0104eba <th8>:
	ec_entry(th8, 8)
f0104eba:	6a 08                	push   $0x8
f0104ebc:	e9 8b 00 00 00       	jmp    f0104f4c <_alltraps>
f0104ec1:	90                   	nop

f0104ec2 <th9>:
	noec_entry(th9, 9)
f0104ec2:	6a 00                	push   $0x0
f0104ec4:	6a 09                	push   $0x9
f0104ec6:	e9 81 00 00 00       	jmp    f0104f4c <_alltraps>
f0104ecb:	90                   	nop

f0104ecc <th10>:
	ec_entry(th10, 10)
f0104ecc:	6a 0a                	push   $0xa
f0104ece:	eb 7c                	jmp    f0104f4c <_alltraps>

f0104ed0 <th11>:
	ec_entry(th11, 11)
f0104ed0:	6a 0b                	push   $0xb
f0104ed2:	eb 78                	jmp    f0104f4c <_alltraps>

f0104ed4 <th12>:
	ec_entry(th12, 12)
f0104ed4:	6a 0c                	push   $0xc
f0104ed6:	eb 74                	jmp    f0104f4c <_alltraps>

f0104ed8 <th13>:
	ec_entry(th13, 13)
f0104ed8:	6a 0d                	push   $0xd
f0104eda:	eb 70                	jmp    f0104f4c <_alltraps>

f0104edc <th14>:
	ec_entry(th14, 14)
f0104edc:	6a 0e                	push   $0xe
f0104ede:	eb 6c                	jmp    f0104f4c <_alltraps>

f0104ee0 <th16>:
	reserved_entry()
	
.data
	.space 60
.text
	noec_entry(th16, 16)
f0104ee0:	6a 00                	push   $0x0
f0104ee2:	6a 10                	push   $0x10
f0104ee4:	eb 66                	jmp    f0104f4c <_alltraps>

f0104ee6 <th32>:
	noec_entry(th32, 32)
f0104ee6:	6a 00                	push   $0x0
f0104ee8:	6a 20                	push   $0x20
f0104eea:	eb 60                	jmp    f0104f4c <_alltraps>

f0104eec <th33>:
    noec_entry(th33, 33)
f0104eec:	6a 00                	push   $0x0
f0104eee:	6a 21                	push   $0x21
f0104ef0:	eb 5a                	jmp    f0104f4c <_alltraps>

f0104ef2 <th34>:
    noec_entry(th34, 34)
f0104ef2:	6a 00                	push   $0x0
f0104ef4:	6a 22                	push   $0x22
f0104ef6:	eb 54                	jmp    f0104f4c <_alltraps>

f0104ef8 <th35>:
    noec_entry(th35, 35)
f0104ef8:	6a 00                	push   $0x0
f0104efa:	6a 23                	push   $0x23
f0104efc:	eb 4e                	jmp    f0104f4c <_alltraps>

f0104efe <th36>:
    noec_entry(th36, 36)
f0104efe:	6a 00                	push   $0x0
f0104f00:	6a 24                	push   $0x24
f0104f02:	eb 48                	jmp    f0104f4c <_alltraps>

f0104f04 <th37>:
    noec_entry(th37, 37)
f0104f04:	6a 00                	push   $0x0
f0104f06:	6a 25                	push   $0x25
f0104f08:	eb 42                	jmp    f0104f4c <_alltraps>

f0104f0a <th38>:
    noec_entry(th38, 38)
f0104f0a:	6a 00                	push   $0x0
f0104f0c:	6a 26                	push   $0x26
f0104f0e:	eb 3c                	jmp    f0104f4c <_alltraps>

f0104f10 <th39>:
    noec_entry(th39, 39)
f0104f10:	6a 00                	push   $0x0
f0104f12:	6a 27                	push   $0x27
f0104f14:	eb 36                	jmp    f0104f4c <_alltraps>

f0104f16 <th40>:
    noec_entry(th40, 40)
f0104f16:	6a 00                	push   $0x0
f0104f18:	6a 28                	push   $0x28
f0104f1a:	eb 30                	jmp    f0104f4c <_alltraps>

f0104f1c <th41>:
    noec_entry(th41, 41)
f0104f1c:	6a 00                	push   $0x0
f0104f1e:	6a 29                	push   $0x29
f0104f20:	eb 2a                	jmp    f0104f4c <_alltraps>

f0104f22 <th42>:
    noec_entry(th42, 42)
f0104f22:	6a 00                	push   $0x0
f0104f24:	6a 2a                	push   $0x2a
f0104f26:	eb 24                	jmp    f0104f4c <_alltraps>

f0104f28 <th43>:
    noec_entry(th43, 43)
f0104f28:	6a 00                	push   $0x0
f0104f2a:	6a 2b                	push   $0x2b
f0104f2c:	eb 1e                	jmp    f0104f4c <_alltraps>

f0104f2e <th44>:
    noec_entry(th44, 44)
f0104f2e:	6a 00                	push   $0x0
f0104f30:	6a 2c                	push   $0x2c
f0104f32:	eb 18                	jmp    f0104f4c <_alltraps>

f0104f34 <th45>:
    noec_entry(th45, 45)
f0104f34:	6a 00                	push   $0x0
f0104f36:	6a 2d                	push   $0x2d
f0104f38:	eb 12                	jmp    f0104f4c <_alltraps>

f0104f3a <th46>:
    noec_entry(th46, 46)
f0104f3a:	6a 00                	push   $0x0
f0104f3c:	6a 2e                	push   $0x2e
f0104f3e:	eb 0c                	jmp    f0104f4c <_alltraps>

f0104f40 <th47>:
    noec_entry(th47, 47)
f0104f40:	6a 00                	push   $0x0
f0104f42:	6a 2f                	push   $0x2f
f0104f44:	eb 06                	jmp    f0104f4c <_alltraps>

f0104f46 <th48>:
	noec_entry(th48, 48)
f0104f46:	6a 00                	push   $0x0
f0104f48:	6a 30                	push   $0x30
f0104f4a:	eb 00                	jmp    f0104f4c <_alltraps>

f0104f4c <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104f4c:	1e                   	push   %ds
	pushl %es
f0104f4d:	06                   	push   %es
	pushal
f0104f4e:	60                   	pusha  
	pushl $GD_KD
f0104f4f:	6a 10                	push   $0x10
	popl %ds
f0104f51:	1f                   	pop    %ds
	pushl $GD_KD
f0104f52:	6a 10                	push   $0x10
	popl %es
f0104f54:	07                   	pop    %es
	pushl %esp
f0104f55:	54                   	push   %esp
	call trap
f0104f56:	e8 d2 fc ff ff       	call   f0104c2d <trap>
	...

f0104f5c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104f5c:	55                   	push   %ebp
f0104f5d:	89 e5                	mov    %esp,%ebp
f0104f5f:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f62:	8b 15 48 c2 20 f0    	mov    0xf020c248,%edx
		     envs[i].env_status == ENV_RUNNING ||
f0104f68:	8b 42 54             	mov    0x54(%edx),%eax
f0104f6b:	83 e8 01             	sub    $0x1,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f6e:	83 f8 02             	cmp    $0x2,%eax
f0104f71:	76 45                	jbe    f0104fb8 <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104f73:	81 c2 d4 00 00 00    	add    $0xd4,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f79:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104f7e:	8b 0a                	mov    (%edx),%ecx
f0104f80:	83 e9 01             	sub    $0x1,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104f83:	83 f9 02             	cmp    $0x2,%ecx
f0104f86:	76 0f                	jbe    f0104f97 <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104f88:	83 c0 01             	add    $0x1,%eax
f0104f8b:	83 ea 80             	sub    $0xffffff80,%edx
f0104f8e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f93:	75 e9                	jne    f0104f7e <sched_halt+0x22>
f0104f95:	eb 07                	jmp    f0104f9e <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104f97:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104f9c:	75 1a                	jne    f0104fb8 <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0104f9e:	c7 04 24 b0 8b 10 f0 	movl   $0xf0108bb0,(%esp)
f0104fa5:	e8 58 f6 ff ff       	call   f0104602 <cprintf>
		while (1)
			monitor(NULL);
f0104faa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104fb1:	e8 b6 c0 ff ff       	call   f010106c <monitor>
f0104fb6:	eb f2                	jmp    f0104faa <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104fb8:	e8 03 1c 00 00       	call   f0106bc0 <cpunum>
f0104fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fc0:	c7 80 28 d0 20 f0 00 	movl   $0x0,-0xfdf2fd8(%eax)
f0104fc7:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104fca:	a1 8c ce 20 f0       	mov    0xf020ce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104fcf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104fd4:	77 20                	ja     f0104ff6 <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104fd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fda:	c7 44 24 08 24 73 10 	movl   $0xf0107324,0x8(%esp)
f0104fe1:	f0 
f0104fe2:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0104fe9:	00 
f0104fea:	c7 04 24 d9 8b 10 f0 	movl   $0xf0108bd9,(%esp)
f0104ff1:	e8 4a b0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104ff6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104ffb:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104ffe:	e8 bd 1b 00 00       	call   f0106bc0 <cpunum>
f0105003:	6b d0 74             	imul   $0x74,%eax,%edx
f0105006:	81 c2 20 d0 20 f0    	add    $0xf020d020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010500c:	b8 02 00 00 00       	mov    $0x2,%eax
f0105011:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105015:	c7 04 24 80 34 12 f0 	movl   $0xf0123480,(%esp)
f010501c:	e8 12 1f 00 00       	call   f0106f33 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105021:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0105023:	e8 98 1b 00 00       	call   f0106bc0 <cpunum>
f0105028:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010502b:	8b 80 30 d0 20 f0    	mov    -0xfdf2fd0(%eax),%eax
f0105031:	bd 00 00 00 00       	mov    $0x0,%ebp
f0105036:	89 c4                	mov    %eax,%esp
f0105038:	6a 00                	push   $0x0
f010503a:	6a 00                	push   $0x0
f010503c:	fb                   	sti    
f010503d:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010503e:	c9                   	leave  
f010503f:	c3                   	ret    

f0105040 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105040:	55                   	push   %ebp
f0105041:	89 e5                	mov    %esp,%ebp
f0105043:	53                   	push   %ebx
f0105044:	83 ec 14             	sub    $0x14,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int envid, i;
	if (curenv != NULL) {
f0105047:	e8 74 1b 00 00       	call   f0106bc0 <cpunum>
f010504c:	6b d0 74             	imul   $0x74,%eax,%edx
		envid = (ENVX(curenv->env_id) + 1) % NENV;
	}
	else {
		envid = 0;
f010504f:	b8 00 00 00 00       	mov    $0x0,%eax
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int envid, i;
	if (curenv != NULL) {
f0105054:	83 ba 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%edx)
f010505b:	74 19                	je     f0105076 <sched_yield+0x36>
		envid = (ENVX(curenv->env_id) + 1) % NENV;
f010505d:	e8 5e 1b 00 00       	call   f0106bc0 <cpunum>
f0105062:	6b c0 74             	imul   $0x74,%eax,%eax
f0105065:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010506b:	8b 40 48             	mov    0x48(%eax),%eax
f010506e:	8d 40 01             	lea    0x1(%eax),%eax
f0105071:	25 ff 03 00 00       	and    $0x3ff,%eax
	}
	else {
		envid = 0;
	}
	for (i = 0; i < NENV; i++, envid = (envid + 1) % NENV) {
		if (envs[envid].env_status == ENV_RUNNABLE) 
f0105076:	8b 1d 48 c2 20 f0    	mov    0xf020c248,%ebx
f010507c:	89 c1                	mov    %eax,%ecx
f010507e:	c1 e1 07             	shl    $0x7,%ecx
f0105081:	01 d9                	add    %ebx,%ecx
f0105083:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0105087:	75 76                	jne    f01050ff <sched_yield+0xbf>
f0105089:	eb 0d                	jmp    f0105098 <sched_yield+0x58>
f010508b:	89 c1                	mov    %eax,%ecx
f010508d:	c1 e1 07             	shl    $0x7,%ecx
f0105090:	01 d9                	add    %ebx,%ecx
f0105092:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0105096:	75 08                	jne    f01050a0 <sched_yield+0x60>
			env_run(&envs[envid]);
f0105098:	89 0c 24             	mov    %ecx,(%esp)
f010509b:	e8 2f f3 ff ff       	call   f01043cf <env_run>
		envid = (ENVX(curenv->env_id) + 1) % NENV;
	}
	else {
		envid = 0;
	}
	for (i = 0; i < NENV; i++, envid = (envid + 1) % NENV) {
f01050a0:	83 c0 01             	add    $0x1,%eax
f01050a3:	89 c1                	mov    %eax,%ecx
f01050a5:	c1 f9 1f             	sar    $0x1f,%ecx
f01050a8:	c1 e9 16             	shr    $0x16,%ecx
f01050ab:	01 c8                	add    %ecx,%eax
f01050ad:	25 ff 03 00 00       	and    $0x3ff,%eax
f01050b2:	29 c8                	sub    %ecx,%eax
f01050b4:	83 ea 01             	sub    $0x1,%edx
f01050b7:	75 d2                	jne    f010508b <sched_yield+0x4b>
		if (envs[envid].env_status == ENV_RUNNABLE) 
			env_run(&envs[envid]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f01050b9:	e8 02 1b 00 00       	call   f0106bc0 <cpunum>
f01050be:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c1:	83 b8 28 d0 20 f0 00 	cmpl   $0x0,-0xfdf2fd8(%eax)
f01050c8:	74 2a                	je     f01050f4 <sched_yield+0xb4>
f01050ca:	e8 f1 1a 00 00       	call   f0106bc0 <cpunum>
f01050cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d2:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01050d8:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01050dc:	75 16                	jne    f01050f4 <sched_yield+0xb4>
		env_run(curenv);
f01050de:	e8 dd 1a 00 00       	call   f0106bc0 <cpunum>
f01050e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e6:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01050ec:	89 04 24             	mov    %eax,(%esp)
f01050ef:	e8 db f2 ff ff       	call   f01043cf <env_run>
	// sched_halt never returns
	sched_halt();
f01050f4:	e8 63 fe ff ff       	call   f0104f5c <sched_halt>
}
f01050f9:	83 c4 14             	add    $0x14,%esp
f01050fc:	5b                   	pop    %ebx
f01050fd:	5d                   	pop    %ebp
f01050fe:	c3                   	ret    
		envid = (ENVX(curenv->env_id) + 1) % NENV;
	}
	else {
		envid = 0;
	}
	for (i = 0; i < NENV; i++, envid = (envid + 1) % NENV) {
f01050ff:	83 c0 01             	add    $0x1,%eax
f0105102:	89 c2                	mov    %eax,%edx
f0105104:	c1 fa 1f             	sar    $0x1f,%edx
f0105107:	c1 ea 16             	shr    $0x16,%edx
f010510a:	01 d0                	add    %edx,%eax
f010510c:	25 ff 03 00 00       	and    $0x3ff,%eax
f0105111:	29 d0                	sub    %edx,%eax
f0105113:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0105118:	e9 6e ff ff ff       	jmp    f010508b <sched_yield+0x4b>
f010511d:	00 00                	add    %al,(%eax)
	...

f0105120 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105120:	55                   	push   %ebp
f0105121:	89 e5                	mov    %esp,%ebp
f0105123:	83 ec 38             	sub    $0x38,%esp
f0105126:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105129:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010512c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010512f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105132:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105135:	8b 75 10             	mov    0x10(%ebp),%esi
f0105138:	8b 5d 14             	mov    0x14(%ebp),%ebx
     		break;
		case SYS_env_set_trapframe:
			res = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
			break;
		default:
            return -E_INVAL;
f010513b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	uint32_t res = 0;
	switch (syscallno) {
f0105140:	83 fa 0d             	cmp    $0xd,%edx
f0105143:	0f 87 d3 05 00 00    	ja     f010571c <syscall+0x5fc>
f0105149:	ff 24 95 48 8c 10 f0 	jmp    *-0xfef73b8(,%edx,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_U);
f0105150:	e8 6b 1a 00 00       	call   f0106bc0 <cpunum>
f0105155:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010515c:	00 
f010515d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105161:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105165:	6b c0 74             	imul   $0x74,%eax,%eax
f0105168:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010516e:	89 04 24             	mov    %eax,(%esp)
f0105171:	e8 d6 ea ff ff       	call   f0103c4c <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0105176:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010517a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010517e:	c7 04 24 e6 8b 10 f0 	movl   $0xf0108be6,(%esp)
f0105185:	e8 78 f4 ff ff       	call   f0104602 <cprintf>
	// LAB 3: Your code here.
	uint32_t res = 0;
	switch (syscallno) {
     	case SYS_cputs:
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
f010518a:	b8 00 00 00 00       	mov    $0x0,%eax
f010518f:	e9 88 05 00 00       	jmp    f010571c <syscall+0x5fc>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105194:	e8 cf b4 ff ff       	call   f0100668 <cons_getc>
            sys_cputs((char *)a1, (size_t)a2);
            return 0;
            break;
        case SYS_cgetc:
            res = sys_cgetc();
            break;
f0105199:	e9 7e 05 00 00       	jmp    f010571c <syscall+0x5fc>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010519e:	66 90                	xchg   %ax,%ax
f01051a0:	e8 1b 1a 00 00       	call   f0106bc0 <cpunum>
f01051a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01051a8:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
            break;
        case SYS_cgetc:
            res = sys_cgetc();
            break;
        case SYS_getenvid:
            res = sys_getenvid();
f01051ae:	8b 40 48             	mov    0x48(%eax),%eax
            break;
f01051b1:	e9 66 05 00 00       	jmp    f010571c <syscall+0x5fc>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01051b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051bd:	00 
f01051be:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051c5:	89 3c 24             	mov    %edi,(%esp)
f01051c8:	e8 5c eb ff ff       	call   f0103d29 <envid2env>
f01051cd:	85 c0                	test   %eax,%eax
f01051cf:	0f 88 47 05 00 00    	js     f010571c <syscall+0x5fc>
		return r;
	env_destroy(e);
f01051d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051d8:	89 04 24             	mov    %eax,(%esp)
f01051db:	e8 4e f1 ff ff       	call   f010432e <env_destroy>
	return 0;
f01051e0:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_getenvid:
            res = sys_getenvid();
            break;
        case SYS_env_destroy:
            res = sys_env_destroy((envid_t)a1);
            break;
f01051e5:	e9 32 05 00 00       	jmp    f010571c <syscall+0x5fc>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01051ea:	e8 51 fe ff ff       	call   f0105040 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	//cprintf("sys_exofork begin!\n");
	struct Env *newenv = NULL;
f01051ef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	int res = 0;
	res = env_alloc(&newenv, curenv->env_id);
f01051f6:	e8 c5 19 00 00       	call   f0106bc0 <cpunum>
f01051fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01051fe:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105204:	8b 40 48             	mov    0x48(%eax),%eax
f0105207:	89 44 24 04          	mov    %eax,0x4(%esp)
f010520b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010520e:	89 04 24             	mov    %eax,(%esp)
f0105211:	e8 27 ec ff ff       	call   f0103e3d <env_alloc>
f0105216:	89 c6                	mov    %eax,%esi
	if (res < 0) {
f0105218:	85 c0                	test   %eax,%eax
f010521a:	79 0e                	jns    f010522a <syscall+0x10a>
		cprintf("env_alloc failed in sys_exofork!\n");
f010521c:	c7 04 24 fc 8b 10 f0 	movl   $0xf0108bfc,(%esp)
f0105223:	e8 da f3 ff ff       	call   f0104602 <cprintf>
f0105228:	eb 2e                	jmp    f0105258 <syscall+0x138>
		return res;
	}
	
	newenv->env_tf = curenv->env_tf;
f010522a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010522d:	e8 8e 19 00 00       	call   f0106bc0 <cpunum>
f0105232:	6b c0 74             	imul   $0x74,%eax,%eax
f0105235:	8b b0 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%esi
f010523b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105240:	89 df                	mov    %ebx,%edi
f0105242:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_status = ENV_NOT_RUNNABLE;
f0105244:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105247:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	newenv->env_tf.tf_regs.reg_eax = 0;
f010524e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	//cprintf("sys_exofork finished!\n");
	return newenv->env_id;
f0105255:	8b 70 48             	mov    0x48(%eax),%esi
            break;
        case SYS_yield:
        	sys_yield();
        	break;
     	case SYS_exofork:
     		res = sys_exofork();
f0105258:	89 f0                	mov    %esi,%eax
     		break;
f010525a:	e9 bd 04 00 00       	jmp    f010571c <syscall+0x5fc>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	//cprintf("sys_env_set_status begin!\n");
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f010525f:	83 fe 02             	cmp    $0x2,%esi
f0105262:	74 0e                	je     f0105272 <syscall+0x152>
		return -E_INVAL;
f0105264:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	//cprintf("sys_env_set_status begin!\n");
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0105269:	83 fe 04             	cmp    $0x4,%esi
f010526c:	0f 85 aa 04 00 00    	jne    f010571c <syscall+0x5fc>
		return -E_INVAL;
	struct Env *e;
	int res;
	res = envid2env(envid, &e, 1);
f0105272:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105279:	00 
f010527a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010527d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105281:	89 3c 24             	mov    %edi,(%esp)
f0105284:	e8 a0 ea ff ff       	call   f0103d29 <envid2env>
	if (res < 0) return -E_BAD_ENV;
f0105289:	85 c0                	test   %eax,%eax
f010528b:	78 10                	js     f010529d <syscall+0x17d>
	e->env_status = status;
f010528d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105290:	89 70 54             	mov    %esi,0x54(%eax)
	//cprintf("sys_env_set_status finished!\n");
	return 0;
f0105293:	b8 00 00 00 00       	mov    $0x0,%eax
f0105298:	e9 7f 04 00 00       	jmp    f010571c <syscall+0x5fc>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
	struct Env *e;
	int res;
	res = envid2env(envid, &e, 1);
	if (res < 0) return -E_BAD_ENV;
f010529d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
     	case SYS_exofork:
     		res = sys_exofork();
     		break;
     	case SYS_env_set_status:
     		res = sys_env_set_status((envid_t)a1, (int)a2);
     		break;
f01052a2:	e9 75 04 00 00       	jmp    f010571c <syscall+0x5fc>

	// LAB 4: Your code here.
	//cprintf("sys_page_alloc begin!\n");
	struct Env *e;
	int res = 0;
	res = envid2env(envid, &e, 1);
f01052a7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052ae:	00 
f01052af:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01052b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052b6:	89 3c 24             	mov    %edi,(%esp)
f01052b9:	e8 6b ea ff ff       	call   f0103d29 <envid2env>
	if (res < 0) return -E_BAD_ENV;
f01052be:	85 c0                	test   %eax,%eax
f01052c0:	78 78                	js     f010533a <syscall+0x21a>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f01052c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052c7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01052cd:	0f 87 49 04 00 00    	ja     f010571c <syscall+0x5fc>
f01052d3:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f01052d9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01052df:	39 d6                	cmp    %edx,%esi
f01052e1:	0f 85 35 04 00 00    	jne    f010571c <syscall+0x5fc>
	if (!(( perm & PTE_U) && (perm & PTE_P) && (perm & (~ PTE_SYSCALL))==0)) return -E_INVAL;
f01052e7:	89 da                	mov    %ebx,%edx
f01052e9:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f01052ef:	83 fa 05             	cmp    $0x5,%edx
f01052f2:	0f 85 24 04 00 00    	jne    f010571c <syscall+0x5fc>

	struct PageInfo * p = NULL;
	p = page_alloc(ALLOC_ZERO);
f01052f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01052ff:	e8 9e c4 ff ff       	call   f01017a2 <page_alloc>
f0105304:	89 c7                	mov    %eax,%edi
	if (p == NULL)
f0105306:	85 c0                	test   %eax,%eax
f0105308:	74 3a                	je     f0105344 <syscall+0x224>
		return -E_NO_MEM;
	res = page_insert(e->env_pgdir, p, va, perm);
f010530a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010530e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105312:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105316:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105319:	8b 40 60             	mov    0x60(%eax),%eax
f010531c:	89 04 24             	mov    %eax,(%esp)
f010531f:	e8 62 c7 ff ff       	call   f0101a86 <page_insert>
	if (res < 0){
f0105324:	85 c0                	test   %eax,%eax
f0105326:	79 26                	jns    f010534e <syscall+0x22e>
		page_free(p);
f0105328:	89 3c 24             	mov    %edi,(%esp)
f010532b:	e8 f0 c4 ff ff       	call   f0101820 <page_free>
		return -E_NO_MEM;
f0105330:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105335:	e9 e2 03 00 00       	jmp    f010571c <syscall+0x5fc>
	// LAB 4: Your code here.
	//cprintf("sys_page_alloc begin!\n");
	struct Env *e;
	int res = 0;
	res = envid2env(envid, &e, 1);
	if (res < 0) return -E_BAD_ENV;
f010533a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010533f:	e9 d8 03 00 00       	jmp    f010571c <syscall+0x5fc>
	if (!(( perm & PTE_U) && (perm & PTE_P) && (perm & (~ PTE_SYSCALL))==0)) return -E_INVAL;

	struct PageInfo * p = NULL;
	p = page_alloc(ALLOC_ZERO);
	if (p == NULL)
		return -E_NO_MEM;
f0105344:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105349:	e9 ce 03 00 00       	jmp    f010571c <syscall+0x5fc>
	if (res < 0){
		page_free(p);
		return -E_NO_MEM;
	}
	//cprintf("sys_page_alloc finished!\n");
	return 0;
f010534e:	b8 00 00 00 00       	mov    $0x0,%eax
     	case SYS_env_set_status:
     		res = sys_env_set_status((envid_t)a1, (int)a2);
     		break;
     	case SYS_page_alloc:
     		res = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
     		break;
f0105353:	e9 c4 03 00 00       	jmp    f010571c <syscall+0x5fc>

	// LAB 4: Your code here.
	//cprintf("sys_page_map begin!\n");
	struct Env *se, *de;
	int res;
	res = envid2env(srcenvid, &se, 1);
f0105358:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010535f:	00 
f0105360:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105363:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105367:	89 3c 24             	mov    %edi,(%esp)
f010536a:	e8 ba e9 ff ff       	call   f0103d29 <envid2env>
	if (res < 0) return -E_BAD_ENV;
f010536f:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f0105374:	85 c0                	test   %eax,%eax
f0105376:	0f 88 d6 00 00 00    	js     f0105452 <syscall+0x332>
	res = envid2env(dstenvid, &de, 1);
f010537c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105383:	00 
f0105384:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105387:	89 44 24 04          	mov    %eax,0x4(%esp)
f010538b:	89 1c 24             	mov    %ebx,(%esp)
f010538e:	e8 96 e9 ff ff       	call   f0103d29 <envid2env>
	if (res < 0) return -E_BAD_ENV;
f0105393:	85 c0                	test   %eax,%eax
f0105395:	0f 88 ab 00 00 00    	js     f0105446 <syscall+0x326>

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f010539b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01053a0:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01053a6:	0f 87 a6 00 00 00    	ja     f0105452 <syscall+0x332>
f01053ac:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f01053b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01053b7:	39 c6                	cmp    %eax,%esi
f01053b9:	0f 85 93 00 00 00    	jne    f0105452 <syscall+0x332>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;
f01053bf:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01053c6:	0f 87 86 00 00 00    	ja     f0105452 <syscall+0x332>
f01053cc:	8b 45 18             	mov    0x18(%ebp),%eax
f01053cf:	05 ff 0f 00 00       	add    $0xfff,%eax
f01053d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01053d9:	39 45 18             	cmp    %eax,0x18(%ebp)
f01053dc:	75 74                	jne    f0105452 <syscall+0x332>

	struct PageInfo *sp;
	pte_t *pte;
	sp = page_lookup(se->env_pgdir, srcva, &pte);
f01053de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01053e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053ec:	8b 40 60             	mov    0x60(%eax),%eax
f01053ef:	89 04 24             	mov    %eax,(%esp)
f01053f2:	e8 92 c5 ff ff       	call   f0101989 <page_lookup>
	if (sp == NULL) return -E_INVAL;
f01053f7:	85 c0                	test   %eax,%eax
f01053f9:	74 52                	je     f010544d <syscall+0x32d>

	if (!(( perm & PTE_U) && (perm & PTE_P) && (perm & (~ PTE_SYSCALL))==0)) return -E_INVAL;
f01053fb:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f01053fe:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
f0105404:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105409:	83 f9 05             	cmp    $0x5,%ecx
f010540c:	75 44                	jne    f0105452 <syscall+0x332>

	if ((perm & PTE_W) && ((*pte) & PTE_W) == 0) return -E_INVAL;
f010540e:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105412:	74 08                	je     f010541c <syscall+0x2fc>
f0105414:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105417:	f6 01 02             	testb  $0x2,(%ecx)
f010541a:	74 36                	je     f0105452 <syscall+0x332>

	res = page_insert(de->env_pgdir, sp, dstva, perm);
f010541c:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f010541f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105423:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105426:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010542a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010542e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105431:	8b 40 60             	mov    0x60(%eax),%eax
f0105434:	89 04 24             	mov    %eax,(%esp)
f0105437:	e8 4a c6 ff ff       	call   f0101a86 <page_insert>
	if (res < 0) return -E_NO_MEM;
f010543c:	89 c2                	mov    %eax,%edx
f010543e:	c1 fa 1f             	sar    $0x1f,%edx
f0105441:	83 e2 fc             	and    $0xfffffffc,%edx
f0105444:	eb 0c                	jmp    f0105452 <syscall+0x332>
	struct Env *se, *de;
	int res;
	res = envid2env(srcenvid, &se, 1);
	if (res < 0) return -E_BAD_ENV;
	res = envid2env(dstenvid, &de, 1);
	if (res < 0) return -E_BAD_ENV;
f0105446:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f010544b:	eb 05                	jmp    f0105452 <syscall+0x332>
	if ((uint32_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) return -E_INVAL;

	struct PageInfo *sp;
	pte_t *pte;
	sp = page_lookup(se->env_pgdir, srcva, &pte);
	if (sp == NULL) return -E_INVAL;
f010544d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
     		break;
     	case SYS_page_alloc:
     		res = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
     		break;
     	case SYS_page_map:
     		res = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0105452:	89 d0                	mov    %edx,%eax
     		break;
f0105454:	e9 c3 02 00 00       	jmp    f010571c <syscall+0x5fc>

	// LAB 4: Your code here.
	//cprintf("SYS_page_unmap begin!\n");
	struct Env *e;
	int res = 0;
	res = envid2env(envid, &e, 1);
f0105459:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105460:	00 
f0105461:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105464:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105468:	89 3c 24             	mov    %edi,(%esp)
f010546b:	e8 b9 e8 ff ff       	call   f0103d29 <envid2env>
	if (res < 0) return -E_BAD_ENV;
f0105470:	85 c0                	test   %eax,%eax
f0105472:	78 41                	js     f01054b5 <syscall+0x395>

	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0105474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105479:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010547f:	0f 87 97 02 00 00    	ja     f010571c <syscall+0x5fc>
f0105485:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f010548b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0105491:	39 d6                	cmp    %edx,%esi
f0105493:	0f 85 83 02 00 00    	jne    f010571c <syscall+0x5fc>
	
	page_remove(e->env_pgdir, va);
f0105499:	89 74 24 04          	mov    %esi,0x4(%esp)
f010549d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054a0:	8b 40 60             	mov    0x60(%eax),%eax
f01054a3:	89 04 24             	mov    %eax,(%esp)
f01054a6:	e8 8b c5 ff ff       	call   f0101a36 <page_remove>
	//cprintf("sys_page_unmap finished!\n");
	return 0;
f01054ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01054b0:	e9 67 02 00 00       	jmp    f010571c <syscall+0x5fc>
	// LAB 4: Your code here.
	//cprintf("SYS_page_unmap begin!\n");
	struct Env *e;
	int res = 0;
	res = envid2env(envid, &e, 1);
	if (res < 0) return -E_BAD_ENV;
f01054b5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
     	case SYS_page_map:
     		res = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
     		break;
     	case SYS_page_unmap:
     		res = sys_page_unmap((envid_t)a1, (void *)a2);
     		break;
f01054ba:	e9 5d 02 00 00       	jmp    f010571c <syscall+0x5fc>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	int res = 0;
	res = envid2env(envid, &e, 1);
f01054bf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054c6:	00 
f01054c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054ce:	89 3c 24             	mov    %edi,(%esp)
f01054d1:	e8 53 e8 ff ff       	call   f0103d29 <envid2env>
	if (res < 0) return -E_BAD_ENV;
f01054d6:	85 c0                	test   %eax,%eax
f01054d8:	78 10                	js     f01054ea <syscall+0x3ca>
	e->env_pgfault_upcall = func;
f01054da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054dd:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f01054e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01054e5:	e9 32 02 00 00       	jmp    f010571c <syscall+0x5fc>
{
	// LAB 4: Your code here.
	struct Env *e;
	int res = 0;
	res = envid2env(envid, &e, 1);
	if (res < 0) return -E_BAD_ENV;
f01054ea:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
     	case SYS_page_unmap:
     		res = sys_page_unmap((envid_t)a1, (void *)a2);
     		break;
     	case SYS_env_set_pgfault_upcall:
     		res = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
     		break;
f01054ef:	e9 28 02 00 00       	jmp    f010571c <syscall+0x5fc>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env * env;
	int res = envid2env(envid , &env , 0);
f01054f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01054fb:	00 
f01054fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105503:	89 3c 24             	mov    %edi,(%esp)
f0105506:	e8 1e e8 ff ff       	call   f0103d29 <envid2env>
	if (res < 0) 
f010550b:	85 c0                	test   %eax,%eax
f010550d:	0f 88 05 01 00 00    	js     f0105618 <syscall+0x4f8>
		return -E_BAD_ENV;
	
	if (env->env_ipc_recving == false || env ->env_ipc_from != 0) 
f0105513:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -E_IPC_NOT_RECV;
f0105516:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	struct Env * env;
	int res = envid2env(envid , &env , 0);
	if (res < 0) 
		return -E_BAD_ENV;
	
	if (env->env_ipc_recving == false || env ->env_ipc_from != 0) 
f010551b:	80 7a 68 00          	cmpb   $0x0,0x68(%edx)
f010551f:	0f 84 f7 01 00 00    	je     f010571c <syscall+0x5fc>
f0105525:	83 7a 74 00          	cmpl   $0x0,0x74(%edx)
f0105529:	0f 85 ed 01 00 00    	jne    f010571c <syscall+0x5fc>
		return -E_IPC_NOT_RECV;
	
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f010552f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105535:	0f 87 a4 00 00 00    	ja     f01055df <syscall+0x4bf>
f010553b:	8d 93 ff 0f 00 00    	lea    0xfff(%ebx),%edx
f0105541:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		return -E_INVAL;
f0105547:	b0 fd                	mov    $0xfd,%al
		return -E_BAD_ENV;
	
	if (env->env_ipc_recving == false || env ->env_ipc_from != 0) 
		return -E_IPC_NOT_RECV;
	
	if ((uint32_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva)
f0105549:	39 d3                	cmp    %edx,%ebx
f010554b:	0f 85 cb 01 00 00    	jne    f010571c <syscall+0x5fc>
		return -E_INVAL;
	
	if (( uint32_t)srcva < UTOP && (!((perm & PTE_U) && (perm & PTE_P) && (perm & (~PTE_SYSCALL))==0)))
f0105551:	8b 55 18             	mov    0x18(%ebp),%edx
f0105554:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f010555a:	83 fa 05             	cmp    $0x5,%edx
f010555d:	0f 85 b9 01 00 00    	jne    f010571c <syscall+0x5fc>
		return -E_INVAL;
	
	if ((uint32_t)srcva < UTOP) {
		pte_t * pte;
		struct PageInfo * p;
		p = page_lookup(curenv->env_pgdir, srcva, &pte);
f0105563:	e8 58 16 00 00       	call   f0106bc0 <cpunum>
f0105568:	8d 55 e0             	lea    -0x20(%ebp),%edx
f010556b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010556f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105573:	6b c0 74             	imul   $0x74,%eax,%eax
f0105576:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010557c:	8b 40 60             	mov    0x60(%eax),%eax
f010557f:	89 04 24             	mov    %eax,(%esp)
f0105582:	e8 02 c4 ff ff       	call   f0101989 <page_lookup>
f0105587:	89 c1                	mov    %eax,%ecx
		if (p == NULL) 
f0105589:	85 c0                	test   %eax,%eax
f010558b:	0f 84 91 00 00 00    	je     f0105622 <syscall+0x502>
			return -E_INVAL;

		if ((perm & PTE_W) && (*pte & PTE_W) == 0)
f0105591:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105595:	74 11                	je     f01055a8 <syscall+0x488>
			return -E_INVAL;
f0105597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		struct PageInfo * p;
		p = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (p == NULL) 
			return -E_INVAL;

		if ((perm & PTE_W) && (*pte & PTE_W) == 0)
f010559c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010559f:	f6 02 02             	testb  $0x2,(%edx)
f01055a2:	0f 84 74 01 00 00    	je     f010571c <syscall+0x5fc>
			return -E_INVAL;

		if (env->env_ipc_dstva != NULL) {
f01055a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055ab:	8b 42 6c             	mov    0x6c(%edx),%eax
f01055ae:	85 c0                	test   %eax,%eax
f01055b0:	74 26                	je     f01055d8 <syscall+0x4b8>
			res = page_insert(env->env_pgdir, p, env->env_ipc_dstva, perm);
f01055b2:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01055b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01055b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055bd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01055c1:	8b 42 60             	mov    0x60(%edx),%eax
f01055c4:	89 04 24             	mov    %eax,(%esp)
f01055c7:	e8 ba c4 ff ff       	call   f0101a86 <page_insert>
			if (res < 0) 
f01055cc:	85 c0                	test   %eax,%eax
f01055ce:	78 5c                	js     f010562c <syscall+0x50c>
				return -E_NO_MEM;
			env ->env_ipc_perm = perm;
f01055d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055d3:	89 58 78             	mov    %ebx,0x78(%eax)
f01055d6:	eb 07                	jmp    f01055df <syscall+0x4bf>
		} 
		else 
			env ->env_ipc_perm = 0;
f01055d8:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
	}
	
	env->env_ipc_recving = false;
f01055df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01055e2:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv ->env_id;
f01055e6:	e8 d5 15 00 00       	call   f0106bc0 <cpunum>
f01055eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01055ee:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01055f4:	8b 40 48             	mov    0x48(%eax),%eax
f01055f7:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f01055fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055fd:	89 70 70             	mov    %esi,0x70(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f0105600:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	env->env_status = ENV_RUNNABLE;
f0105607:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
//cprintf("sys_ipc_try_send: return\n");
	return 0;
f010560e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105613:	e9 04 01 00 00       	jmp    f010571c <syscall+0x5fc>
{
	// LAB 4: Your code here.
	struct Env * env;
	int res = envid2env(envid , &env , 0);
	if (res < 0) 
		return -E_BAD_ENV;
f0105618:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010561d:	e9 fa 00 00 00       	jmp    f010571c <syscall+0x5fc>
	if ((uint32_t)srcva < UTOP) {
		pte_t * pte;
		struct PageInfo * p;
		p = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (p == NULL) 
			return -E_INVAL;
f0105622:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105627:	e9 f0 00 00 00       	jmp    f010571c <syscall+0x5fc>
			return -E_INVAL;

		if (env->env_ipc_dstva != NULL) {
			res = page_insert(env->env_pgdir, p, env->env_ipc_dstva, perm);
			if (res < 0) 
				return -E_NO_MEM;
f010562c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
     	case SYS_env_set_pgfault_upcall:
     		res = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
     		break;
     	case SYS_ipc_try_send:
     		res = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
     		break;
f0105631:	e9 e6 00 00 00       	jmp    f010571c <syscall+0x5fc>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((( uint32_t)dstva < UTOP) && ROUNDUP(dstva , PGSIZE) != dstva) return -E_INVAL;
f0105636:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010563c:	77 13                	ja     f0105651 <syscall+0x531>
f010563e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0105644:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105649:	39 c7                	cmp    %eax,%edi
f010564b:	0f 85 c6 00 00 00    	jne    f0105717 <syscall+0x5f7>
	
	curenv->env_ipc_recving = true;
f0105651:	e8 6a 15 00 00       	call   f0106bc0 <cpunum>
f0105656:	6b c0 74             	imul   $0x74,%eax,%eax
f0105659:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010565f:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0105663:	e8 58 15 00 00       	call   f0106bc0 <cpunum>
f0105668:	6b c0 74             	imul   $0x74,%eax,%eax
f010566b:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105671:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_ipc_from = 0;
f0105674:	e8 47 15 00 00       	call   f0106bc0 <cpunum>
f0105679:	6b c0 74             	imul   $0x74,%eax,%eax
f010567c:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105682:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105689:	e8 32 15 00 00       	call   f0106bc0 <cpunum>
f010568e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105691:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f0105697:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	sched_yield ();
f010569e:	e8 9d f9 ff ff       	call   f0105040 <sched_yield>
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	int res;
	struct Env *env;
	res = envid2env(envid, &env, 1);
f01056a3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01056aa:	00 
f01056ab:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01056ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056b2:	89 3c 24             	mov    %edi,(%esp)
f01056b5:	e8 6f e6 ff ff       	call   f0103d29 <envid2env>
	if (res < 0)
f01056ba:	85 c0                	test   %eax,%eax
f01056bc:	78 52                	js     f0105710 <syscall+0x5f0>
		return -E_BAD_ENV;
	if (tf == NULL) 
f01056be:	85 f6                	test   %esi,%esi
f01056c0:	75 1c                	jne    f01056de <syscall+0x5be>
		panic("tf is null in sys_env_set_trapframe!\n");
f01056c2:	c7 44 24 08 20 8c 10 	movl   $0xf0108c20,0x8(%esp)
f01056c9:	f0 
f01056ca:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
f01056d1:	00 
f01056d2:	c7 04 24 eb 8b 10 f0 	movl   $0xf0108beb,(%esp)
f01056d9:	e8 62 a9 ff ff       	call   f0100040 <_panic>

	user_mem_assert(env, tf, sizeof(struct Trapframe), PTE_U);
f01056de:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01056e5:	00 
f01056e6:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01056ed:	00 
f01056ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01056f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056f5:	89 04 24             	mov    %eax,(%esp)
f01056f8:	e8 4f e5 ff ff       	call   f0103c4c <user_mem_assert>

	env->env_tf = *tf;
f01056fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105700:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105705:	89 c7                	mov    %eax,%edi
f0105707:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	//env->env_tf.tf_eflags |= FL_IF;

	return 0;
f0105709:	b8 00 00 00 00       	mov    $0x0,%eax
f010570e:	eb 0c                	jmp    f010571c <syscall+0x5fc>
	// LAB 5: Your code here.
	int res;
	struct Env *env;
	res = envid2env(envid, &env, 1);
	if (res < 0)
		return -E_BAD_ENV;
f0105710:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
     	case SYS_ipc_recv:
     		res = sys_ipc_recv((void *)a1);
     		break;
		case SYS_env_set_trapframe:
			res = sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
			break;
f0105715:	eb 05                	jmp    f010571c <syscall+0x5fc>
     		break;
     	case SYS_ipc_try_send:
     		res = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
     		break;
     	case SYS_ipc_recv:
     		res = sys_ipc_recv((void *)a1);
f0105717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		default:
            return -E_INVAL;
	}
	return res;			
	panic("syscall not implemented");
}
f010571c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010571f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105722:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105725:	89 ec                	mov    %ebp,%esp
f0105727:	5d                   	pop    %ebp
f0105728:	c3                   	ret    
f0105729:	00 00                	add    %al,(%eax)
	...

f010572c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010572c:	55                   	push   %ebp
f010572d:	89 e5                	mov    %esp,%ebp
f010572f:	57                   	push   %edi
f0105730:	56                   	push   %esi
f0105731:	53                   	push   %ebx
f0105732:	83 ec 14             	sub    $0x14,%esp
f0105735:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105738:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010573b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010573e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105741:	8b 1a                	mov    (%edx),%ebx
f0105743:	8b 01                	mov    (%ecx),%eax
f0105745:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0105748:	39 c3                	cmp    %eax,%ebx
f010574a:	0f 8f 9c 00 00 00    	jg     f01057ec <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0105750:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105757:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010575a:	01 d8                	add    %ebx,%eax
f010575c:	89 c7                	mov    %eax,%edi
f010575e:	c1 ef 1f             	shr    $0x1f,%edi
f0105761:	01 c7                	add    %eax,%edi
f0105763:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105765:	39 df                	cmp    %ebx,%edi
f0105767:	7c 33                	jl     f010579c <stab_binsearch+0x70>
f0105769:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010576c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010576f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105774:	39 f0                	cmp    %esi,%eax
f0105776:	0f 84 bc 00 00 00    	je     f0105838 <stab_binsearch+0x10c>
f010577c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105780:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105784:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105786:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105789:	39 d8                	cmp    %ebx,%eax
f010578b:	7c 0f                	jl     f010579c <stab_binsearch+0x70>
f010578d:	0f b6 0a             	movzbl (%edx),%ecx
f0105790:	83 ea 0c             	sub    $0xc,%edx
f0105793:	39 f1                	cmp    %esi,%ecx
f0105795:	75 ef                	jne    f0105786 <stab_binsearch+0x5a>
f0105797:	e9 9e 00 00 00       	jmp    f010583a <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010579c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010579f:	eb 3c                	jmp    f01057dd <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01057a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01057a4:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01057a6:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01057a9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01057b0:	eb 2b                	jmp    f01057dd <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01057b2:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01057b5:	76 14                	jbe    f01057cb <stab_binsearch+0x9f>
			*region_right = m - 1;
f01057b7:	83 e8 01             	sub    $0x1,%eax
f01057ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01057bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057c0:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01057c2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01057c9:	eb 12                	jmp    f01057dd <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01057cb:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01057ce:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f01057d0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01057d4:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01057d6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01057dd:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01057e0:	0f 8d 71 ff ff ff    	jge    f0105757 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01057e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01057ea:	75 0f                	jne    f01057fb <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01057ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01057ef:	8b 02                	mov    (%edx),%eax
f01057f1:	83 e8 01             	sub    $0x1,%eax
f01057f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057f7:	89 01                	mov    %eax,(%ecx)
f01057f9:	eb 57                	jmp    f0105852 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01057fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057fe:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105800:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105803:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105805:	39 c1                	cmp    %eax,%ecx
f0105807:	7d 28                	jge    f0105831 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105809:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010580c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f010580f:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105814:	39 f2                	cmp    %esi,%edx
f0105816:	74 19                	je     f0105831 <stab_binsearch+0x105>
f0105818:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010581c:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105820:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105823:	39 c1                	cmp    %eax,%ecx
f0105825:	7d 0a                	jge    f0105831 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105827:	0f b6 1a             	movzbl (%edx),%ebx
f010582a:	83 ea 0c             	sub    $0xc,%edx
f010582d:	39 f3                	cmp    %esi,%ebx
f010582f:	75 ef                	jne    f0105820 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105831:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105834:	89 02                	mov    %eax,(%edx)
f0105836:	eb 1a                	jmp    f0105852 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105838:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010583a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010583d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105840:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105844:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105847:	0f 82 54 ff ff ff    	jb     f01057a1 <stab_binsearch+0x75>
f010584d:	e9 60 ff ff ff       	jmp    f01057b2 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105852:	83 c4 14             	add    $0x14,%esp
f0105855:	5b                   	pop    %ebx
f0105856:	5e                   	pop    %esi
f0105857:	5f                   	pop    %edi
f0105858:	5d                   	pop    %ebp
f0105859:	c3                   	ret    

f010585a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010585a:	55                   	push   %ebp
f010585b:	89 e5                	mov    %esp,%ebp
f010585d:	57                   	push   %edi
f010585e:	56                   	push   %esi
f010585f:	53                   	push   %ebx
f0105860:	83 ec 5c             	sub    $0x5c,%esp
f0105863:	8b 75 08             	mov    0x8(%ebp),%esi
f0105866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105869:	c7 03 80 8c 10 f0    	movl   $0xf0108c80,(%ebx)
	info->eip_line = 0;
f010586f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105876:	c7 43 08 80 8c 10 f0 	movl   $0xf0108c80,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010587d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105884:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105887:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010588e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105894:	0f 87 d8 00 00 00    	ja     f0105972 <debuginfo_eip+0x118>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010589a:	e8 21 13 00 00       	call   f0106bc0 <cpunum>
f010589f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01058a6:	00 
f01058a7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01058ae:	00 
f01058af:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01058b6:	00 
f01058b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01058ba:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f01058c0:	89 04 24             	mov    %eax,(%esp)
f01058c3:	e8 f4 e2 ff ff       	call   f0103bbc <user_mem_check>
f01058c8:	89 c2                	mov    %eax,%edx
			return -1;
f01058ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01058cf:	85 d2                	test   %edx,%edx
f01058d1:	0f 85 a5 02 00 00    	jne    f0105b7c <debuginfo_eip+0x322>
			return -1;

		stabs = usd->stabs;
f01058d7:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01058dd:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01058e0:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01058e6:	a1 08 00 20 00       	mov    0x200008,%eax
f01058eb:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01058ee:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01058f4:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01058f7:	e8 c4 12 00 00       	call   f0106bc0 <cpunum>
f01058fc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105903:	00 
f0105904:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f010590b:	00 
f010590c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010590f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105913:	6b c0 74             	imul   $0x74,%eax,%eax
f0105916:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010591c:	89 04 24             	mov    %eax,(%esp)
f010591f:	e8 98 e2 ff ff       	call   f0103bbc <user_mem_check>
f0105924:	89 c2                	mov    %eax,%edx
			return -1;
f0105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010592b:	85 d2                	test   %edx,%edx
f010592d:	0f 85 49 02 00 00    	jne    f0105b7c <debuginfo_eip+0x322>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105933:	e8 88 12 00 00       	call   f0106bc0 <cpunum>
f0105938:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010593f:	00 
f0105940:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105943:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105946:	89 54 24 08          	mov    %edx,0x8(%esp)
f010594a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010594d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105951:	6b c0 74             	imul   $0x74,%eax,%eax
f0105954:	8b 80 28 d0 20 f0    	mov    -0xfdf2fd8(%eax),%eax
f010595a:	89 04 24             	mov    %eax,(%esp)
f010595d:	e8 5a e2 ff ff       	call   f0103bbc <user_mem_check>
f0105962:	89 c2                	mov    %eax,%edx
			return -1;
f0105964:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105969:	85 d2                	test   %edx,%edx
f010596b:	74 1f                	je     f010598c <debuginfo_eip+0x132>
f010596d:	e9 0a 02 00 00       	jmp    f0105b7c <debuginfo_eip+0x322>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105972:	c7 45 c0 2d 85 11 f0 	movl   $0xf011852d,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105979:	c7 45 bc 71 4b 11 f0 	movl   $0xf0114b71,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105980:	bf 70 4b 11 f0       	mov    $0xf0114b70,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105985:	c7 45 c4 30 92 10 f0 	movl   $0xf0109230,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010598c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105991:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105994:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105997:	0f 83 df 01 00 00    	jae    f0105b7c <debuginfo_eip+0x322>
f010599d:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01059a1:	0f 85 d5 01 00 00    	jne    f0105b7c <debuginfo_eip+0x322>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01059a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01059ae:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01059b1:	c1 ff 02             	sar    $0x2,%edi
f01059b4:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01059ba:	83 e8 01             	sub    $0x1,%eax
f01059bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01059c0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059c4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01059cb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01059ce:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01059d1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01059d4:	e8 53 fd ff ff       	call   f010572c <stab_binsearch>
	if (lfile == 0)
f01059d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01059dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01059e1:	85 d2                	test   %edx,%edx
f01059e3:	0f 84 93 01 00 00    	je     f0105b7c <debuginfo_eip+0x322>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01059e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01059ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01059f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059f6:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01059fd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105a00:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105a03:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105a06:	e8 21 fd ff ff       	call   f010572c <stab_binsearch>

	if (lfun <= rfun) {
f0105a0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a0e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105a11:	39 d0                	cmp    %edx,%eax
f0105a13:	7f 32                	jg     f0105a47 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105a15:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105a18:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105a1b:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0105a1e:	8b 39                	mov    (%ecx),%edi
f0105a20:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105a23:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105a26:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105a29:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105a2c:	73 09                	jae    f0105a37 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105a2e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105a31:	03 7d bc             	add    -0x44(%ebp),%edi
f0105a34:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105a37:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105a3a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105a3d:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105a3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105a42:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105a45:	eb 0f                	jmp    f0105a56 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105a47:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105a4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a53:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105a56:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105a5d:	00 
f0105a5e:	8b 43 08             	mov    0x8(%ebx),%eax
f0105a61:	89 04 24             	mov    %eax,(%esp)
f0105a64:	e8 a1 0a 00 00       	call   f010650a <strfind>
f0105a69:	2b 43 08             	sub    0x8(%ebx),%eax
f0105a6c:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105a6f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a73:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105a7a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105a7d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105a80:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105a83:	e8 a4 fc ff ff       	call   f010572c <stab_binsearch>

	if(lline <= rline)
f0105a88:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0105a8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0105a90:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105a93:	0f 8f e3 00 00 00    	jg     f0105b7c <debuginfo_eip+0x322>
		info->eip_line = stabs[lline].n_desc;
f0105a99:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105a9c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105a9f:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105aa4:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105aa7:	89 d0                	mov    %edx,%eax
f0105aa9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105aac:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0105aaf:	39 fa                	cmp    %edi,%edx
f0105ab1:	7c 74                	jl     f0105b27 <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f0105ab3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105ab6:	89 f7                	mov    %esi,%edi
f0105ab8:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0105abb:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f0105abf:	80 f9 84             	cmp    $0x84,%cl
f0105ac2:	74 46                	je     f0105b0a <debuginfo_eip+0x2b0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105ac4:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105ac8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105acb:	89 c7                	mov    %eax,%edi
f0105acd:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0105ad0:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105ad3:	eb 1f                	jmp    f0105af4 <debuginfo_eip+0x29a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105ad5:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105ad8:	39 c3                	cmp    %eax,%ebx
f0105ada:	7f 48                	jg     f0105b24 <debuginfo_eip+0x2ca>
	       && stabs[lline].n_type != N_SOL
f0105adc:	89 d6                	mov    %edx,%esi
f0105ade:	83 ea 0c             	sub    $0xc,%edx
f0105ae1:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f0105ae5:	80 f9 84             	cmp    $0x84,%cl
f0105ae8:	75 08                	jne    f0105af2 <debuginfo_eip+0x298>
f0105aea:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105aed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105af0:	eb 18                	jmp    f0105b0a <debuginfo_eip+0x2b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105af2:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105af4:	80 f9 64             	cmp    $0x64,%cl
f0105af7:	75 dc                	jne    f0105ad5 <debuginfo_eip+0x27b>
f0105af9:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105afd:	74 d6                	je     f0105ad5 <debuginfo_eip+0x27b>
f0105aff:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0105b02:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105b05:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f0105b08:	7c 1d                	jl     f0105b27 <debuginfo_eip+0x2cd>
f0105b0a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105b0d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b10:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105b13:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105b16:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105b19:	39 d0                	cmp    %edx,%eax
f0105b1b:	73 0a                	jae    f0105b27 <debuginfo_eip+0x2cd>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105b1d:	03 45 bc             	add    -0x44(%ebp),%eax
f0105b20:	89 03                	mov    %eax,(%ebx)
f0105b22:	eb 03                	jmp    f0105b27 <debuginfo_eip+0x2cd>
f0105b24:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105b27:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105b2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105b2d:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105b30:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105b35:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f0105b38:	7d 42                	jge    f0105b7c <debuginfo_eip+0x322>
		for (lline = lfun + 1;
f0105b3a:	8d 57 01             	lea    0x1(%edi),%edx
f0105b3d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105b40:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0105b43:	7e 37                	jle    f0105b7c <debuginfo_eip+0x322>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105b45:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0105b48:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b4b:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f0105b50:	75 2a                	jne    f0105b7c <debuginfo_eip+0x322>
f0105b52:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105b55:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f0105b59:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105b5c:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105b60:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105b63:	39 d1                	cmp    %edx,%ecx
f0105b65:	7e 10                	jle    f0105b77 <debuginfo_eip+0x31d>
f0105b67:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105b6a:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0105b6e:	74 ec                	je     f0105b5c <debuginfo_eip+0x302>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105b70:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b75:	eb 05                	jmp    f0105b7c <debuginfo_eip+0x322>
f0105b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b7c:	83 c4 5c             	add    $0x5c,%esp
f0105b7f:	5b                   	pop    %ebx
f0105b80:	5e                   	pop    %esi
f0105b81:	5f                   	pop    %edi
f0105b82:	5d                   	pop    %ebp
f0105b83:	c3                   	ret    

f0105b84 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105b84:	55                   	push   %ebp
f0105b85:	89 e5                	mov    %esp,%ebp
f0105b87:	57                   	push   %edi
f0105b88:	56                   	push   %esi
f0105b89:	53                   	push   %ebx
f0105b8a:	83 ec 3c             	sub    $0x3c,%esp
f0105b8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105b90:	89 d7                	mov    %edx,%edi
f0105b92:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b95:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105b98:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105b9e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105ba1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105ba4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ba9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105bac:	72 11                	jb     f0105bbf <printnum+0x3b>
f0105bae:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105bb1:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105bb4:	76 09                	jbe    f0105bbf <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105bb6:	83 eb 01             	sub    $0x1,%ebx
f0105bb9:	85 db                	test   %ebx,%ebx
f0105bbb:	7f 51                	jg     f0105c0e <printnum+0x8a>
f0105bbd:	eb 5e                	jmp    f0105c1d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105bbf:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105bc3:	83 eb 01             	sub    $0x1,%ebx
f0105bc6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105bca:	8b 45 10             	mov    0x10(%ebp),%eax
f0105bcd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bd1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105bd5:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105bd9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105be0:	00 
f0105be1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105be4:	89 04 24             	mov    %eax,(%esp)
f0105be7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bee:	e8 5d 14 00 00       	call   f0107050 <__udivdi3>
f0105bf3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105bf7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105bfb:	89 04 24             	mov    %eax,(%esp)
f0105bfe:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105c02:	89 fa                	mov    %edi,%edx
f0105c04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c07:	e8 78 ff ff ff       	call   f0105b84 <printnum>
f0105c0c:	eb 0f                	jmp    f0105c1d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105c0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c12:	89 34 24             	mov    %esi,(%esp)
f0105c15:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105c18:	83 eb 01             	sub    $0x1,%ebx
f0105c1b:	75 f1                	jne    f0105c0e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105c1d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c21:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105c25:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c28:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c2c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105c33:	00 
f0105c34:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105c37:	89 04 24             	mov    %eax,(%esp)
f0105c3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c41:	e8 3a 15 00 00       	call   f0107180 <__umoddi3>
f0105c46:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105c4a:	0f be 80 8a 8c 10 f0 	movsbl -0xfef7376(%eax),%eax
f0105c51:	89 04 24             	mov    %eax,(%esp)
f0105c54:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105c57:	83 c4 3c             	add    $0x3c,%esp
f0105c5a:	5b                   	pop    %ebx
f0105c5b:	5e                   	pop    %esi
f0105c5c:	5f                   	pop    %edi
f0105c5d:	5d                   	pop    %ebp
f0105c5e:	c3                   	ret    

f0105c5f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105c5f:	55                   	push   %ebp
f0105c60:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105c62:	83 fa 01             	cmp    $0x1,%edx
f0105c65:	7e 0e                	jle    f0105c75 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105c67:	8b 10                	mov    (%eax),%edx
f0105c69:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105c6c:	89 08                	mov    %ecx,(%eax)
f0105c6e:	8b 02                	mov    (%edx),%eax
f0105c70:	8b 52 04             	mov    0x4(%edx),%edx
f0105c73:	eb 22                	jmp    f0105c97 <getuint+0x38>
	else if (lflag)
f0105c75:	85 d2                	test   %edx,%edx
f0105c77:	74 10                	je     f0105c89 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105c79:	8b 10                	mov    (%eax),%edx
f0105c7b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c7e:	89 08                	mov    %ecx,(%eax)
f0105c80:	8b 02                	mov    (%edx),%eax
f0105c82:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c87:	eb 0e                	jmp    f0105c97 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105c89:	8b 10                	mov    (%eax),%edx
f0105c8b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105c8e:	89 08                	mov    %ecx,(%eax)
f0105c90:	8b 02                	mov    (%edx),%eax
f0105c92:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105c97:	5d                   	pop    %ebp
f0105c98:	c3                   	ret    

f0105c99 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105c99:	55                   	push   %ebp
f0105c9a:	89 e5                	mov    %esp,%ebp
f0105c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105c9f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105ca3:	8b 10                	mov    (%eax),%edx
f0105ca5:	3b 50 04             	cmp    0x4(%eax),%edx
f0105ca8:	73 0a                	jae    f0105cb4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105cad:	88 0a                	mov    %cl,(%edx)
f0105caf:	83 c2 01             	add    $0x1,%edx
f0105cb2:	89 10                	mov    %edx,(%eax)
}
f0105cb4:	5d                   	pop    %ebp
f0105cb5:	c3                   	ret    

f0105cb6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105cb6:	55                   	push   %ebp
f0105cb7:	89 e5                	mov    %esp,%ebp
f0105cb9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105cbc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105cbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105cc3:	8b 45 10             	mov    0x10(%ebp),%eax
f0105cc6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105cca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cd4:	89 04 24             	mov    %eax,(%esp)
f0105cd7:	e8 02 00 00 00       	call   f0105cde <vprintfmt>
	va_end(ap);
}
f0105cdc:	c9                   	leave  
f0105cdd:	c3                   	ret    

f0105cde <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105cde:	55                   	push   %ebp
f0105cdf:	89 e5                	mov    %esp,%ebp
f0105ce1:	57                   	push   %edi
f0105ce2:	56                   	push   %esi
f0105ce3:	53                   	push   %ebx
f0105ce4:	83 ec 5c             	sub    $0x5c,%esp
f0105ce7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105cea:	8b 75 10             	mov    0x10(%ebp),%esi
f0105ced:	eb 12                	jmp    f0105d01 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105cef:	85 c0                	test   %eax,%eax
f0105cf1:	0f 84 e4 04 00 00    	je     f01061db <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f0105cf7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cfb:	89 04 24             	mov    %eax,(%esp)
f0105cfe:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105d01:	0f b6 06             	movzbl (%esi),%eax
f0105d04:	83 c6 01             	add    $0x1,%esi
f0105d07:	83 f8 25             	cmp    $0x25,%eax
f0105d0a:	75 e3                	jne    f0105cef <vprintfmt+0x11>
f0105d0c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0105d10:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0105d17:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105d1c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105d23:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d28:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105d2b:	eb 2b                	jmp    f0105d58 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d2d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105d30:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0105d34:	eb 22                	jmp    f0105d58 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d36:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105d39:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0105d3d:	eb 19                	jmp    f0105d58 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d3f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105d42:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105d49:	eb 0d                	jmp    f0105d58 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105d4b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105d4e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105d51:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d58:	0f b6 06             	movzbl (%esi),%eax
f0105d5b:	0f b6 d0             	movzbl %al,%edx
f0105d5e:	8d 7e 01             	lea    0x1(%esi),%edi
f0105d61:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105d64:	83 e8 23             	sub    $0x23,%eax
f0105d67:	3c 55                	cmp    $0x55,%al
f0105d69:	0f 87 46 04 00 00    	ja     f01061b5 <vprintfmt+0x4d7>
f0105d6f:	0f b6 c0             	movzbl %al,%eax
f0105d72:	ff 24 85 e0 8d 10 f0 	jmp    *-0xfef7220(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105d79:	83 ea 30             	sub    $0x30,%edx
f0105d7c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0105d7f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105d83:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d86:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0105d89:	83 fa 09             	cmp    $0x9,%edx
f0105d8c:	77 4a                	ja     f0105dd8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d8e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105d91:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105d94:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105d97:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105d9b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105d9e:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105da1:	83 fa 09             	cmp    $0x9,%edx
f0105da4:	76 eb                	jbe    f0105d91 <vprintfmt+0xb3>
f0105da6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105da9:	eb 2d                	jmp    f0105dd8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105dab:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dae:	8d 50 04             	lea    0x4(%eax),%edx
f0105db1:	89 55 14             	mov    %edx,0x14(%ebp)
f0105db4:	8b 00                	mov    (%eax),%eax
f0105db6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105db9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105dbc:	eb 1a                	jmp    f0105dd8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105dbe:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0105dc1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105dc5:	79 91                	jns    f0105d58 <vprintfmt+0x7a>
f0105dc7:	e9 73 ff ff ff       	jmp    f0105d3f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105dcc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105dcf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0105dd6:	eb 80                	jmp    f0105d58 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0105dd8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105ddc:	0f 89 76 ff ff ff    	jns    f0105d58 <vprintfmt+0x7a>
f0105de2:	e9 64 ff ff ff       	jmp    f0105d4b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105de7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105dea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105ded:	e9 66 ff ff ff       	jmp    f0105d58 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105df2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105df5:	8d 50 04             	lea    0x4(%eax),%edx
f0105df8:	89 55 14             	mov    %edx,0x14(%ebp)
f0105dfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105dff:	8b 00                	mov    (%eax),%eax
f0105e01:	89 04 24             	mov    %eax,(%esp)
f0105e04:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e07:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105e0a:	e9 f2 fe ff ff       	jmp    f0105d01 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0105e0f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105e13:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f0105e16:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f0105e1a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0105e1d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105e21:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0105e24:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0105e27:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0105e2b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105e2e:	80 f9 09             	cmp    $0x9,%cl
f0105e31:	77 1d                	ja     f0105e50 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0105e33:	0f be c0             	movsbl %al,%eax
f0105e36:	6b c0 64             	imul   $0x64,%eax,%eax
f0105e39:	0f be d2             	movsbl %dl,%edx
f0105e3c:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0105e3f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0105e46:	a3 78 34 12 f0       	mov    %eax,0xf0123478
f0105e4b:	e9 b1 fe ff ff       	jmp    f0105d01 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0105e50:	c7 44 24 04 a2 8c 10 	movl   $0xf0108ca2,0x4(%esp)
f0105e57:	f0 
f0105e58:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105e5b:	89 04 24             	mov    %eax,(%esp)
f0105e5e:	e8 f8 05 00 00       	call   f010645b <strcmp>
f0105e63:	85 c0                	test   %eax,%eax
f0105e65:	75 0f                	jne    f0105e76 <vprintfmt+0x198>
f0105e67:	c7 05 78 34 12 f0 04 	movl   $0x4,0xf0123478
f0105e6e:	00 00 00 
f0105e71:	e9 8b fe ff ff       	jmp    f0105d01 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0105e76:	c7 44 24 04 a6 8c 10 	movl   $0xf0108ca6,0x4(%esp)
f0105e7d:	f0 
f0105e7e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105e81:	89 14 24             	mov    %edx,(%esp)
f0105e84:	e8 d2 05 00 00       	call   f010645b <strcmp>
f0105e89:	85 c0                	test   %eax,%eax
f0105e8b:	75 0f                	jne    f0105e9c <vprintfmt+0x1be>
f0105e8d:	c7 05 78 34 12 f0 02 	movl   $0x2,0xf0123478
f0105e94:	00 00 00 
f0105e97:	e9 65 fe ff ff       	jmp    f0105d01 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0105e9c:	c7 44 24 04 aa 8c 10 	movl   $0xf0108caa,0x4(%esp)
f0105ea3:	f0 
f0105ea4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0105ea7:	89 0c 24             	mov    %ecx,(%esp)
f0105eaa:	e8 ac 05 00 00       	call   f010645b <strcmp>
f0105eaf:	85 c0                	test   %eax,%eax
f0105eb1:	75 0f                	jne    f0105ec2 <vprintfmt+0x1e4>
f0105eb3:	c7 05 78 34 12 f0 01 	movl   $0x1,0xf0123478
f0105eba:	00 00 00 
f0105ebd:	e9 3f fe ff ff       	jmp    f0105d01 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0105ec2:	c7 44 24 04 ae 8c 10 	movl   $0xf0108cae,0x4(%esp)
f0105ec9:	f0 
f0105eca:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0105ecd:	89 3c 24             	mov    %edi,(%esp)
f0105ed0:	e8 86 05 00 00       	call   f010645b <strcmp>
f0105ed5:	85 c0                	test   %eax,%eax
f0105ed7:	75 0f                	jne    f0105ee8 <vprintfmt+0x20a>
f0105ed9:	c7 05 78 34 12 f0 06 	movl   $0x6,0xf0123478
f0105ee0:	00 00 00 
f0105ee3:	e9 19 fe ff ff       	jmp    f0105d01 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f0105ee8:	c7 44 24 04 b2 8c 10 	movl   $0xf0108cb2,0x4(%esp)
f0105eef:	f0 
f0105ef0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105ef3:	89 04 24             	mov    %eax,(%esp)
f0105ef6:	e8 60 05 00 00       	call   f010645b <strcmp>
f0105efb:	85 c0                	test   %eax,%eax
f0105efd:	75 0f                	jne    f0105f0e <vprintfmt+0x230>
f0105eff:	c7 05 78 34 12 f0 07 	movl   $0x7,0xf0123478
f0105f06:	00 00 00 
f0105f09:	e9 f3 fd ff ff       	jmp    f0105d01 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0105f0e:	c7 44 24 04 b6 8c 10 	movl   $0xf0108cb6,0x4(%esp)
f0105f15:	f0 
f0105f16:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105f19:	89 14 24             	mov    %edx,(%esp)
f0105f1c:	e8 3a 05 00 00       	call   f010645b <strcmp>
f0105f21:	83 f8 01             	cmp    $0x1,%eax
f0105f24:	19 c0                	sbb    %eax,%eax
f0105f26:	f7 d0                	not    %eax
f0105f28:	83 c0 08             	add    $0x8,%eax
f0105f2b:	a3 78 34 12 f0       	mov    %eax,0xf0123478
f0105f30:	e9 cc fd ff ff       	jmp    f0105d01 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0105f35:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f38:	8d 50 04             	lea    0x4(%eax),%edx
f0105f3b:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f3e:	8b 00                	mov    (%eax),%eax
f0105f40:	89 c2                	mov    %eax,%edx
f0105f42:	c1 fa 1f             	sar    $0x1f,%edx
f0105f45:	31 d0                	xor    %edx,%eax
f0105f47:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105f49:	83 f8 0f             	cmp    $0xf,%eax
f0105f4c:	7f 0b                	jg     f0105f59 <vprintfmt+0x27b>
f0105f4e:	8b 14 85 40 8f 10 f0 	mov    -0xfef70c0(,%eax,4),%edx
f0105f55:	85 d2                	test   %edx,%edx
f0105f57:	75 23                	jne    f0105f7c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0105f59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f5d:	c7 44 24 08 ba 8c 10 	movl   $0xf0108cba,0x8(%esp)
f0105f64:	f0 
f0105f65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f69:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f6c:	89 3c 24             	mov    %edi,(%esp)
f0105f6f:	e8 42 fd ff ff       	call   f0105cb6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f74:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105f77:	e9 85 fd ff ff       	jmp    f0105d01 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105f7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f80:	c7 44 24 08 9d 84 10 	movl   $0xf010849d,0x8(%esp)
f0105f87:	f0 
f0105f88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f8c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f8f:	89 3c 24             	mov    %edi,(%esp)
f0105f92:	e8 1f fd ff ff       	call   f0105cb6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f97:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105f9a:	e9 62 fd ff ff       	jmp    f0105d01 <vprintfmt+0x23>
f0105f9f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105fa2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105fa5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105fa8:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fab:	8d 50 04             	lea    0x4(%eax),%edx
f0105fae:	89 55 14             	mov    %edx,0x14(%ebp)
f0105fb1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105fb3:	85 f6                	test   %esi,%esi
f0105fb5:	b8 9b 8c 10 f0       	mov    $0xf0108c9b,%eax
f0105fba:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105fbd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0105fc1:	7e 06                	jle    f0105fc9 <vprintfmt+0x2eb>
f0105fc3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0105fc7:	75 13                	jne    f0105fdc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105fc9:	0f be 06             	movsbl (%esi),%eax
f0105fcc:	83 c6 01             	add    $0x1,%esi
f0105fcf:	85 c0                	test   %eax,%eax
f0105fd1:	0f 85 94 00 00 00    	jne    f010606b <vprintfmt+0x38d>
f0105fd7:	e9 81 00 00 00       	jmp    f010605d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105fdc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fe0:	89 34 24             	mov    %esi,(%esp)
f0105fe3:	e8 83 03 00 00       	call   f010636b <strnlen>
f0105fe8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105feb:	29 c2                	sub    %eax,%edx
f0105fed:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0105ff0:	85 d2                	test   %edx,%edx
f0105ff2:	7e d5                	jle    f0105fc9 <vprintfmt+0x2eb>
					putch(padc, putdat);
f0105ff4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0105ff8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105ffb:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0105ffe:	89 d6                	mov    %edx,%esi
f0106000:	89 cf                	mov    %ecx,%edi
f0106002:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106006:	89 3c 24             	mov    %edi,(%esp)
f0106009:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010600c:	83 ee 01             	sub    $0x1,%esi
f010600f:	75 f1                	jne    f0106002 <vprintfmt+0x324>
f0106011:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0106014:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0106017:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010601a:	eb ad                	jmp    f0105fc9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010601c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0106020:	74 1b                	je     f010603d <vprintfmt+0x35f>
f0106022:	8d 50 e0             	lea    -0x20(%eax),%edx
f0106025:	83 fa 5e             	cmp    $0x5e,%edx
f0106028:	76 13                	jbe    f010603d <vprintfmt+0x35f>
					putch('?', putdat);
f010602a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010602d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106031:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106038:	ff 55 08             	call   *0x8(%ebp)
f010603b:	eb 0d                	jmp    f010604a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f010603d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106040:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106044:	89 04 24             	mov    %eax,(%esp)
f0106047:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010604a:	83 eb 01             	sub    $0x1,%ebx
f010604d:	0f be 06             	movsbl (%esi),%eax
f0106050:	83 c6 01             	add    $0x1,%esi
f0106053:	85 c0                	test   %eax,%eax
f0106055:	75 1a                	jne    f0106071 <vprintfmt+0x393>
f0106057:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010605a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010605d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106060:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0106064:	7f 1c                	jg     f0106082 <vprintfmt+0x3a4>
f0106066:	e9 96 fc ff ff       	jmp    f0105d01 <vprintfmt+0x23>
f010606b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010606e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106071:	85 ff                	test   %edi,%edi
f0106073:	78 a7                	js     f010601c <vprintfmt+0x33e>
f0106075:	83 ef 01             	sub    $0x1,%edi
f0106078:	79 a2                	jns    f010601c <vprintfmt+0x33e>
f010607a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010607d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106080:	eb db                	jmp    f010605d <vprintfmt+0x37f>
f0106082:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106085:	89 de                	mov    %ebx,%esi
f0106087:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010608a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010608e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106095:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0106097:	83 eb 01             	sub    $0x1,%ebx
f010609a:	75 ee                	jne    f010608a <vprintfmt+0x3ac>
f010609c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010609e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01060a1:	e9 5b fc ff ff       	jmp    f0105d01 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01060a6:	83 f9 01             	cmp    $0x1,%ecx
f01060a9:	7e 10                	jle    f01060bb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f01060ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01060ae:	8d 50 08             	lea    0x8(%eax),%edx
f01060b1:	89 55 14             	mov    %edx,0x14(%ebp)
f01060b4:	8b 30                	mov    (%eax),%esi
f01060b6:	8b 78 04             	mov    0x4(%eax),%edi
f01060b9:	eb 26                	jmp    f01060e1 <vprintfmt+0x403>
	else if (lflag)
f01060bb:	85 c9                	test   %ecx,%ecx
f01060bd:	74 12                	je     f01060d1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f01060bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01060c2:	8d 50 04             	lea    0x4(%eax),%edx
f01060c5:	89 55 14             	mov    %edx,0x14(%ebp)
f01060c8:	8b 30                	mov    (%eax),%esi
f01060ca:	89 f7                	mov    %esi,%edi
f01060cc:	c1 ff 1f             	sar    $0x1f,%edi
f01060cf:	eb 10                	jmp    f01060e1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f01060d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01060d4:	8d 50 04             	lea    0x4(%eax),%edx
f01060d7:	89 55 14             	mov    %edx,0x14(%ebp)
f01060da:	8b 30                	mov    (%eax),%esi
f01060dc:	89 f7                	mov    %esi,%edi
f01060de:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01060e1:	85 ff                	test   %edi,%edi
f01060e3:	78 0e                	js     f01060f3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01060e5:	89 f0                	mov    %esi,%eax
f01060e7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01060e9:	be 0a 00 00 00       	mov    $0xa,%esi
f01060ee:	e9 84 00 00 00       	jmp    f0106177 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01060f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01060f7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01060fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106101:	89 f0                	mov    %esi,%eax
f0106103:	89 fa                	mov    %edi,%edx
f0106105:	f7 d8                	neg    %eax
f0106107:	83 d2 00             	adc    $0x0,%edx
f010610a:	f7 da                	neg    %edx
			}
			base = 10;
f010610c:	be 0a 00 00 00       	mov    $0xa,%esi
f0106111:	eb 64                	jmp    f0106177 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0106113:	89 ca                	mov    %ecx,%edx
f0106115:	8d 45 14             	lea    0x14(%ebp),%eax
f0106118:	e8 42 fb ff ff       	call   f0105c5f <getuint>
			base = 10;
f010611d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0106122:	eb 53                	jmp    f0106177 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0106124:	89 ca                	mov    %ecx,%edx
f0106126:	8d 45 14             	lea    0x14(%ebp),%eax
f0106129:	e8 31 fb ff ff       	call   f0105c5f <getuint>
    			base = 8;
f010612e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0106133:	eb 42                	jmp    f0106177 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0106135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106139:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106140:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0106143:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106147:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010614e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0106151:	8b 45 14             	mov    0x14(%ebp),%eax
f0106154:	8d 50 04             	lea    0x4(%eax),%edx
f0106157:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010615a:	8b 00                	mov    (%eax),%eax
f010615c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0106161:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0106166:	eb 0f                	jmp    f0106177 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106168:	89 ca                	mov    %ecx,%edx
f010616a:	8d 45 14             	lea    0x14(%ebp),%eax
f010616d:	e8 ed fa ff ff       	call   f0105c5f <getuint>
			base = 16;
f0106172:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106177:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f010617b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010617f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0106182:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106186:	89 74 24 08          	mov    %esi,0x8(%esp)
f010618a:	89 04 24             	mov    %eax,(%esp)
f010618d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106191:	89 da                	mov    %ebx,%edx
f0106193:	8b 45 08             	mov    0x8(%ebp),%eax
f0106196:	e8 e9 f9 ff ff       	call   f0105b84 <printnum>
			break;
f010619b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010619e:	e9 5e fb ff ff       	jmp    f0105d01 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01061a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01061a7:	89 14 24             	mov    %edx,(%esp)
f01061aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01061ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01061b0:	e9 4c fb ff ff       	jmp    f0105d01 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01061b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01061b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01061c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01061c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01061c7:	0f 84 34 fb ff ff    	je     f0105d01 <vprintfmt+0x23>
f01061cd:	83 ee 01             	sub    $0x1,%esi
f01061d0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01061d4:	75 f7                	jne    f01061cd <vprintfmt+0x4ef>
f01061d6:	e9 26 fb ff ff       	jmp    f0105d01 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01061db:	83 c4 5c             	add    $0x5c,%esp
f01061de:	5b                   	pop    %ebx
f01061df:	5e                   	pop    %esi
f01061e0:	5f                   	pop    %edi
f01061e1:	5d                   	pop    %ebp
f01061e2:	c3                   	ret    

f01061e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01061e3:	55                   	push   %ebp
f01061e4:	89 e5                	mov    %esp,%ebp
f01061e6:	83 ec 28             	sub    $0x28,%esp
f01061e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01061ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01061ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01061f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01061f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01061f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0106200:	85 c0                	test   %eax,%eax
f0106202:	74 30                	je     f0106234 <vsnprintf+0x51>
f0106204:	85 d2                	test   %edx,%edx
f0106206:	7e 2c                	jle    f0106234 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0106208:	8b 45 14             	mov    0x14(%ebp),%eax
f010620b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010620f:	8b 45 10             	mov    0x10(%ebp),%eax
f0106212:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106216:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106219:	89 44 24 04          	mov    %eax,0x4(%esp)
f010621d:	c7 04 24 99 5c 10 f0 	movl   $0xf0105c99,(%esp)
f0106224:	e8 b5 fa ff ff       	call   f0105cde <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106229:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010622c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010622f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106232:	eb 05                	jmp    f0106239 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0106234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0106239:	c9                   	leave  
f010623a:	c3                   	ret    

f010623b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010623b:	55                   	push   %ebp
f010623c:	89 e5                	mov    %esp,%ebp
f010623e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0106241:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0106244:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106248:	8b 45 10             	mov    0x10(%ebp),%eax
f010624b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010624f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106252:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106256:	8b 45 08             	mov    0x8(%ebp),%eax
f0106259:	89 04 24             	mov    %eax,(%esp)
f010625c:	e8 82 ff ff ff       	call   f01061e3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0106261:	c9                   	leave  
f0106262:	c3                   	ret    
	...

f0106270 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106270:	55                   	push   %ebp
f0106271:	89 e5                	mov    %esp,%ebp
f0106273:	57                   	push   %edi
f0106274:	56                   	push   %esi
f0106275:	53                   	push   %ebx
f0106276:	83 ec 1c             	sub    $0x1c,%esp
f0106279:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010627c:	85 c0                	test   %eax,%eax
f010627e:	74 10                	je     f0106290 <readline+0x20>
		cprintf("%s", prompt);
f0106280:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106284:	c7 04 24 9d 84 10 f0 	movl   $0xf010849d,(%esp)
f010628b:	e8 72 e3 ff ff       	call   f0104602 <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0106290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106297:	e8 5b a5 ff ff       	call   f01007f7 <iscons>
f010629c:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f010629e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01062a3:	e8 3e a5 ff ff       	call   f01007e6 <getchar>
f01062a8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01062aa:	85 c0                	test   %eax,%eax
f01062ac:	79 25                	jns    f01062d3 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01062ae:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01062b3:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01062b6:	0f 84 89 00 00 00    	je     f0106345 <readline+0xd5>
				cprintf("read error: %e\n", c);
f01062bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01062c0:	c7 04 24 9f 8f 10 f0 	movl   $0xf0108f9f,(%esp)
f01062c7:	e8 36 e3 ff ff       	call   f0104602 <cprintf>
			return NULL;
f01062cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01062d1:	eb 72                	jmp    f0106345 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01062d3:	83 f8 08             	cmp    $0x8,%eax
f01062d6:	74 05                	je     f01062dd <readline+0x6d>
f01062d8:	83 f8 7f             	cmp    $0x7f,%eax
f01062db:	75 1a                	jne    f01062f7 <readline+0x87>
f01062dd:	85 f6                	test   %esi,%esi
f01062df:	90                   	nop
f01062e0:	7e 15                	jle    f01062f7 <readline+0x87>
			if (echoing)
f01062e2:	85 ff                	test   %edi,%edi
f01062e4:	74 0c                	je     f01062f2 <readline+0x82>
				cputchar('\b');
f01062e6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01062ed:	e8 e4 a4 ff ff       	call   f01007d6 <cputchar>
			i--;
f01062f2:	83 ee 01             	sub    $0x1,%esi
f01062f5:	eb ac                	jmp    f01062a3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01062f7:	83 fb 1f             	cmp    $0x1f,%ebx
f01062fa:	7e 1f                	jle    f010631b <readline+0xab>
f01062fc:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106302:	7f 17                	jg     f010631b <readline+0xab>
			if (echoing)
f0106304:	85 ff                	test   %edi,%edi
f0106306:	74 08                	je     f0106310 <readline+0xa0>
				cputchar(c);
f0106308:	89 1c 24             	mov    %ebx,(%esp)
f010630b:	e8 c6 a4 ff ff       	call   f01007d6 <cputchar>
			buf[i++] = c;
f0106310:	88 9e 80 ca 20 f0    	mov    %bl,-0xfdf3580(%esi)
f0106316:	83 c6 01             	add    $0x1,%esi
f0106319:	eb 88                	jmp    f01062a3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010631b:	83 fb 0a             	cmp    $0xa,%ebx
f010631e:	74 09                	je     f0106329 <readline+0xb9>
f0106320:	83 fb 0d             	cmp    $0xd,%ebx
f0106323:	0f 85 7a ff ff ff    	jne    f01062a3 <readline+0x33>
			if (echoing)
f0106329:	85 ff                	test   %edi,%edi
f010632b:	74 0c                	je     f0106339 <readline+0xc9>
				cputchar('\n');
f010632d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106334:	e8 9d a4 ff ff       	call   f01007d6 <cputchar>
			buf[i] = 0;
f0106339:	c6 86 80 ca 20 f0 00 	movb   $0x0,-0xfdf3580(%esi)
			return buf;
f0106340:	b8 80 ca 20 f0       	mov    $0xf020ca80,%eax
		}
	}
}
f0106345:	83 c4 1c             	add    $0x1c,%esp
f0106348:	5b                   	pop    %ebx
f0106349:	5e                   	pop    %esi
f010634a:	5f                   	pop    %edi
f010634b:	5d                   	pop    %ebp
f010634c:	c3                   	ret    
f010634d:	00 00                	add    %al,(%eax)
	...

f0106350 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106350:	55                   	push   %ebp
f0106351:	89 e5                	mov    %esp,%ebp
f0106353:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106356:	b8 00 00 00 00       	mov    $0x0,%eax
f010635b:	80 3a 00             	cmpb   $0x0,(%edx)
f010635e:	74 09                	je     f0106369 <strlen+0x19>
		n++;
f0106360:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0106363:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106367:	75 f7                	jne    f0106360 <strlen+0x10>
		n++;
	return n;
}
f0106369:	5d                   	pop    %ebp
f010636a:	c3                   	ret    

f010636b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010636b:	55                   	push   %ebp
f010636c:	89 e5                	mov    %esp,%ebp
f010636e:	53                   	push   %ebx
f010636f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106375:	b8 00 00 00 00       	mov    $0x0,%eax
f010637a:	85 c9                	test   %ecx,%ecx
f010637c:	74 1a                	je     f0106398 <strnlen+0x2d>
f010637e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0106381:	74 15                	je     f0106398 <strnlen+0x2d>
f0106383:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0106388:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010638a:	39 ca                	cmp    %ecx,%edx
f010638c:	74 0a                	je     f0106398 <strnlen+0x2d>
f010638e:	83 c2 01             	add    $0x1,%edx
f0106391:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0106396:	75 f0                	jne    f0106388 <strnlen+0x1d>
		n++;
	return n;
}
f0106398:	5b                   	pop    %ebx
f0106399:	5d                   	pop    %ebp
f010639a:	c3                   	ret    

f010639b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010639b:	55                   	push   %ebp
f010639c:	89 e5                	mov    %esp,%ebp
f010639e:	53                   	push   %ebx
f010639f:	8b 45 08             	mov    0x8(%ebp),%eax
f01063a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01063a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01063aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01063ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01063b1:	83 c2 01             	add    $0x1,%edx
f01063b4:	84 c9                	test   %cl,%cl
f01063b6:	75 f2                	jne    f01063aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01063b8:	5b                   	pop    %ebx
f01063b9:	5d                   	pop    %ebp
f01063ba:	c3                   	ret    

f01063bb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01063bb:	55                   	push   %ebp
f01063bc:	89 e5                	mov    %esp,%ebp
f01063be:	53                   	push   %ebx
f01063bf:	83 ec 08             	sub    $0x8,%esp
f01063c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01063c5:	89 1c 24             	mov    %ebx,(%esp)
f01063c8:	e8 83 ff ff ff       	call   f0106350 <strlen>
	strcpy(dst + len, src);
f01063cd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063d0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01063d4:	01 d8                	add    %ebx,%eax
f01063d6:	89 04 24             	mov    %eax,(%esp)
f01063d9:	e8 bd ff ff ff       	call   f010639b <strcpy>
	return dst;
}
f01063de:	89 d8                	mov    %ebx,%eax
f01063e0:	83 c4 08             	add    $0x8,%esp
f01063e3:	5b                   	pop    %ebx
f01063e4:	5d                   	pop    %ebp
f01063e5:	c3                   	ret    

f01063e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01063e6:	55                   	push   %ebp
f01063e7:	89 e5                	mov    %esp,%ebp
f01063e9:	56                   	push   %esi
f01063ea:	53                   	push   %ebx
f01063eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01063ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01063f4:	85 f6                	test   %esi,%esi
f01063f6:	74 18                	je     f0106410 <strncpy+0x2a>
f01063f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01063fd:	0f b6 1a             	movzbl (%edx),%ebx
f0106400:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106403:	80 3a 01             	cmpb   $0x1,(%edx)
f0106406:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106409:	83 c1 01             	add    $0x1,%ecx
f010640c:	39 f1                	cmp    %esi,%ecx
f010640e:	75 ed                	jne    f01063fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106410:	5b                   	pop    %ebx
f0106411:	5e                   	pop    %esi
f0106412:	5d                   	pop    %ebp
f0106413:	c3                   	ret    

f0106414 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106414:	55                   	push   %ebp
f0106415:	89 e5                	mov    %esp,%ebp
f0106417:	57                   	push   %edi
f0106418:	56                   	push   %esi
f0106419:	53                   	push   %ebx
f010641a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010641d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106420:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106423:	89 f8                	mov    %edi,%eax
f0106425:	85 f6                	test   %esi,%esi
f0106427:	74 2b                	je     f0106454 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0106429:	83 fe 01             	cmp    $0x1,%esi
f010642c:	74 23                	je     f0106451 <strlcpy+0x3d>
f010642e:	0f b6 0b             	movzbl (%ebx),%ecx
f0106431:	84 c9                	test   %cl,%cl
f0106433:	74 1c                	je     f0106451 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0106435:	83 ee 02             	sub    $0x2,%esi
f0106438:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010643d:	88 08                	mov    %cl,(%eax)
f010643f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106442:	39 f2                	cmp    %esi,%edx
f0106444:	74 0b                	je     f0106451 <strlcpy+0x3d>
f0106446:	83 c2 01             	add    $0x1,%edx
f0106449:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010644d:	84 c9                	test   %cl,%cl
f010644f:	75 ec                	jne    f010643d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0106451:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0106454:	29 f8                	sub    %edi,%eax
}
f0106456:	5b                   	pop    %ebx
f0106457:	5e                   	pop    %esi
f0106458:	5f                   	pop    %edi
f0106459:	5d                   	pop    %ebp
f010645a:	c3                   	ret    

f010645b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010645b:	55                   	push   %ebp
f010645c:	89 e5                	mov    %esp,%ebp
f010645e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106461:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106464:	0f b6 01             	movzbl (%ecx),%eax
f0106467:	84 c0                	test   %al,%al
f0106469:	74 16                	je     f0106481 <strcmp+0x26>
f010646b:	3a 02                	cmp    (%edx),%al
f010646d:	75 12                	jne    f0106481 <strcmp+0x26>
		p++, q++;
f010646f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0106472:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0106476:	84 c0                	test   %al,%al
f0106478:	74 07                	je     f0106481 <strcmp+0x26>
f010647a:	83 c1 01             	add    $0x1,%ecx
f010647d:	3a 02                	cmp    (%edx),%al
f010647f:	74 ee                	je     f010646f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106481:	0f b6 c0             	movzbl %al,%eax
f0106484:	0f b6 12             	movzbl (%edx),%edx
f0106487:	29 d0                	sub    %edx,%eax
}
f0106489:	5d                   	pop    %ebp
f010648a:	c3                   	ret    

f010648b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010648b:	55                   	push   %ebp
f010648c:	89 e5                	mov    %esp,%ebp
f010648e:	53                   	push   %ebx
f010648f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106495:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106498:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010649d:	85 d2                	test   %edx,%edx
f010649f:	74 28                	je     f01064c9 <strncmp+0x3e>
f01064a1:	0f b6 01             	movzbl (%ecx),%eax
f01064a4:	84 c0                	test   %al,%al
f01064a6:	74 24                	je     f01064cc <strncmp+0x41>
f01064a8:	3a 03                	cmp    (%ebx),%al
f01064aa:	75 20                	jne    f01064cc <strncmp+0x41>
f01064ac:	83 ea 01             	sub    $0x1,%edx
f01064af:	74 13                	je     f01064c4 <strncmp+0x39>
		n--, p++, q++;
f01064b1:	83 c1 01             	add    $0x1,%ecx
f01064b4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01064b7:	0f b6 01             	movzbl (%ecx),%eax
f01064ba:	84 c0                	test   %al,%al
f01064bc:	74 0e                	je     f01064cc <strncmp+0x41>
f01064be:	3a 03                	cmp    (%ebx),%al
f01064c0:	74 ea                	je     f01064ac <strncmp+0x21>
f01064c2:	eb 08                	jmp    f01064cc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01064c4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01064c9:	5b                   	pop    %ebx
f01064ca:	5d                   	pop    %ebp
f01064cb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01064cc:	0f b6 01             	movzbl (%ecx),%eax
f01064cf:	0f b6 13             	movzbl (%ebx),%edx
f01064d2:	29 d0                	sub    %edx,%eax
f01064d4:	eb f3                	jmp    f01064c9 <strncmp+0x3e>

f01064d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01064d6:	55                   	push   %ebp
f01064d7:	89 e5                	mov    %esp,%ebp
f01064d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01064dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01064e0:	0f b6 10             	movzbl (%eax),%edx
f01064e3:	84 d2                	test   %dl,%dl
f01064e5:	74 1c                	je     f0106503 <strchr+0x2d>
		if (*s == c)
f01064e7:	38 ca                	cmp    %cl,%dl
f01064e9:	75 09                	jne    f01064f4 <strchr+0x1e>
f01064eb:	eb 1b                	jmp    f0106508 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01064ed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f01064f0:	38 ca                	cmp    %cl,%dl
f01064f2:	74 14                	je     f0106508 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01064f4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f01064f8:	84 d2                	test   %dl,%dl
f01064fa:	75 f1                	jne    f01064ed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f01064fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0106501:	eb 05                	jmp    f0106508 <strchr+0x32>
f0106503:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106508:	5d                   	pop    %ebp
f0106509:	c3                   	ret    

f010650a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010650a:	55                   	push   %ebp
f010650b:	89 e5                	mov    %esp,%ebp
f010650d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106510:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106514:	0f b6 10             	movzbl (%eax),%edx
f0106517:	84 d2                	test   %dl,%dl
f0106519:	74 14                	je     f010652f <strfind+0x25>
		if (*s == c)
f010651b:	38 ca                	cmp    %cl,%dl
f010651d:	75 06                	jne    f0106525 <strfind+0x1b>
f010651f:	eb 0e                	jmp    f010652f <strfind+0x25>
f0106521:	38 ca                	cmp    %cl,%dl
f0106523:	74 0a                	je     f010652f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106525:	83 c0 01             	add    $0x1,%eax
f0106528:	0f b6 10             	movzbl (%eax),%edx
f010652b:	84 d2                	test   %dl,%dl
f010652d:	75 f2                	jne    f0106521 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f010652f:	5d                   	pop    %ebp
f0106530:	c3                   	ret    

f0106531 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106531:	55                   	push   %ebp
f0106532:	89 e5                	mov    %esp,%ebp
f0106534:	83 ec 0c             	sub    $0xc,%esp
f0106537:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010653a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010653d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106540:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106543:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106546:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106549:	85 c9                	test   %ecx,%ecx
f010654b:	74 30                	je     f010657d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010654d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106553:	75 25                	jne    f010657a <memset+0x49>
f0106555:	f6 c1 03             	test   $0x3,%cl
f0106558:	75 20                	jne    f010657a <memset+0x49>
		c &= 0xFF;
f010655a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010655d:	89 d3                	mov    %edx,%ebx
f010655f:	c1 e3 08             	shl    $0x8,%ebx
f0106562:	89 d6                	mov    %edx,%esi
f0106564:	c1 e6 18             	shl    $0x18,%esi
f0106567:	89 d0                	mov    %edx,%eax
f0106569:	c1 e0 10             	shl    $0x10,%eax
f010656c:	09 f0                	or     %esi,%eax
f010656e:	09 d0                	or     %edx,%eax
f0106570:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106572:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106575:	fc                   	cld    
f0106576:	f3 ab                	rep stos %eax,%es:(%edi)
f0106578:	eb 03                	jmp    f010657d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010657a:	fc                   	cld    
f010657b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010657d:	89 f8                	mov    %edi,%eax
f010657f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106582:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106585:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106588:	89 ec                	mov    %ebp,%esp
f010658a:	5d                   	pop    %ebp
f010658b:	c3                   	ret    

f010658c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010658c:	55                   	push   %ebp
f010658d:	89 e5                	mov    %esp,%ebp
f010658f:	83 ec 08             	sub    $0x8,%esp
f0106592:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106595:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106598:	8b 45 08             	mov    0x8(%ebp),%eax
f010659b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010659e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01065a1:	39 c6                	cmp    %eax,%esi
f01065a3:	73 36                	jae    f01065db <memmove+0x4f>
f01065a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01065a8:	39 d0                	cmp    %edx,%eax
f01065aa:	73 2f                	jae    f01065db <memmove+0x4f>
		s += n;
		d += n;
f01065ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01065af:	f6 c2 03             	test   $0x3,%dl
f01065b2:	75 1b                	jne    f01065cf <memmove+0x43>
f01065b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01065ba:	75 13                	jne    f01065cf <memmove+0x43>
f01065bc:	f6 c1 03             	test   $0x3,%cl
f01065bf:	75 0e                	jne    f01065cf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01065c1:	83 ef 04             	sub    $0x4,%edi
f01065c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01065c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01065ca:	fd                   	std    
f01065cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01065cd:	eb 09                	jmp    f01065d8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01065cf:	83 ef 01             	sub    $0x1,%edi
f01065d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01065d5:	fd                   	std    
f01065d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01065d8:	fc                   	cld    
f01065d9:	eb 20                	jmp    f01065fb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01065db:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01065e1:	75 13                	jne    f01065f6 <memmove+0x6a>
f01065e3:	a8 03                	test   $0x3,%al
f01065e5:	75 0f                	jne    f01065f6 <memmove+0x6a>
f01065e7:	f6 c1 03             	test   $0x3,%cl
f01065ea:	75 0a                	jne    f01065f6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01065ec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01065ef:	89 c7                	mov    %eax,%edi
f01065f1:	fc                   	cld    
f01065f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01065f4:	eb 05                	jmp    f01065fb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01065f6:	89 c7                	mov    %eax,%edi
f01065f8:	fc                   	cld    
f01065f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01065fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01065fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106601:	89 ec                	mov    %ebp,%esp
f0106603:	5d                   	pop    %ebp
f0106604:	c3                   	ret    

f0106605 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106605:	55                   	push   %ebp
f0106606:	89 e5                	mov    %esp,%ebp
f0106608:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010660b:	8b 45 10             	mov    0x10(%ebp),%eax
f010660e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106612:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106615:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106619:	8b 45 08             	mov    0x8(%ebp),%eax
f010661c:	89 04 24             	mov    %eax,(%esp)
f010661f:	e8 68 ff ff ff       	call   f010658c <memmove>
}
f0106624:	c9                   	leave  
f0106625:	c3                   	ret    

f0106626 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106626:	55                   	push   %ebp
f0106627:	89 e5                	mov    %esp,%ebp
f0106629:	57                   	push   %edi
f010662a:	56                   	push   %esi
f010662b:	53                   	push   %ebx
f010662c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010662f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106632:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106635:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010663a:	85 ff                	test   %edi,%edi
f010663c:	74 37                	je     f0106675 <memcmp+0x4f>
		if (*s1 != *s2)
f010663e:	0f b6 03             	movzbl (%ebx),%eax
f0106641:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106644:	83 ef 01             	sub    $0x1,%edi
f0106647:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f010664c:	38 c8                	cmp    %cl,%al
f010664e:	74 1c                	je     f010666c <memcmp+0x46>
f0106650:	eb 10                	jmp    f0106662 <memcmp+0x3c>
f0106652:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0106657:	83 c2 01             	add    $0x1,%edx
f010665a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010665e:	38 c8                	cmp    %cl,%al
f0106660:	74 0a                	je     f010666c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0106662:	0f b6 c0             	movzbl %al,%eax
f0106665:	0f b6 c9             	movzbl %cl,%ecx
f0106668:	29 c8                	sub    %ecx,%eax
f010666a:	eb 09                	jmp    f0106675 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010666c:	39 fa                	cmp    %edi,%edx
f010666e:	75 e2                	jne    f0106652 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106670:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106675:	5b                   	pop    %ebx
f0106676:	5e                   	pop    %esi
f0106677:	5f                   	pop    %edi
f0106678:	5d                   	pop    %ebp
f0106679:	c3                   	ret    

f010667a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010667a:	55                   	push   %ebp
f010667b:	89 e5                	mov    %esp,%ebp
f010667d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106680:	89 c2                	mov    %eax,%edx
f0106682:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106685:	39 d0                	cmp    %edx,%eax
f0106687:	73 19                	jae    f01066a2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106689:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010668d:	38 08                	cmp    %cl,(%eax)
f010668f:	75 06                	jne    f0106697 <memfind+0x1d>
f0106691:	eb 0f                	jmp    f01066a2 <memfind+0x28>
f0106693:	38 08                	cmp    %cl,(%eax)
f0106695:	74 0b                	je     f01066a2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106697:	83 c0 01             	add    $0x1,%eax
f010669a:	39 d0                	cmp    %edx,%eax
f010669c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01066a0:	75 f1                	jne    f0106693 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01066a2:	5d                   	pop    %ebp
f01066a3:	c3                   	ret    

f01066a4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01066a4:	55                   	push   %ebp
f01066a5:	89 e5                	mov    %esp,%ebp
f01066a7:	57                   	push   %edi
f01066a8:	56                   	push   %esi
f01066a9:	53                   	push   %ebx
f01066aa:	8b 55 08             	mov    0x8(%ebp),%edx
f01066ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01066b0:	0f b6 02             	movzbl (%edx),%eax
f01066b3:	3c 20                	cmp    $0x20,%al
f01066b5:	74 04                	je     f01066bb <strtol+0x17>
f01066b7:	3c 09                	cmp    $0x9,%al
f01066b9:	75 0e                	jne    f01066c9 <strtol+0x25>
		s++;
f01066bb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01066be:	0f b6 02             	movzbl (%edx),%eax
f01066c1:	3c 20                	cmp    $0x20,%al
f01066c3:	74 f6                	je     f01066bb <strtol+0x17>
f01066c5:	3c 09                	cmp    $0x9,%al
f01066c7:	74 f2                	je     f01066bb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01066c9:	3c 2b                	cmp    $0x2b,%al
f01066cb:	75 0a                	jne    f01066d7 <strtol+0x33>
		s++;
f01066cd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01066d0:	bf 00 00 00 00       	mov    $0x0,%edi
f01066d5:	eb 10                	jmp    f01066e7 <strtol+0x43>
f01066d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01066dc:	3c 2d                	cmp    $0x2d,%al
f01066de:	75 07                	jne    f01066e7 <strtol+0x43>
		s++, neg = 1;
f01066e0:	83 c2 01             	add    $0x1,%edx
f01066e3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01066e7:	85 db                	test   %ebx,%ebx
f01066e9:	0f 94 c0             	sete   %al
f01066ec:	74 05                	je     f01066f3 <strtol+0x4f>
f01066ee:	83 fb 10             	cmp    $0x10,%ebx
f01066f1:	75 15                	jne    f0106708 <strtol+0x64>
f01066f3:	80 3a 30             	cmpb   $0x30,(%edx)
f01066f6:	75 10                	jne    f0106708 <strtol+0x64>
f01066f8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01066fc:	75 0a                	jne    f0106708 <strtol+0x64>
		s += 2, base = 16;
f01066fe:	83 c2 02             	add    $0x2,%edx
f0106701:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106706:	eb 13                	jmp    f010671b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0106708:	84 c0                	test   %al,%al
f010670a:	74 0f                	je     f010671b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010670c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106711:	80 3a 30             	cmpb   $0x30,(%edx)
f0106714:	75 05                	jne    f010671b <strtol+0x77>
		s++, base = 8;
f0106716:	83 c2 01             	add    $0x1,%edx
f0106719:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010671b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106720:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106722:	0f b6 0a             	movzbl (%edx),%ecx
f0106725:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106728:	80 fb 09             	cmp    $0x9,%bl
f010672b:	77 08                	ja     f0106735 <strtol+0x91>
			dig = *s - '0';
f010672d:	0f be c9             	movsbl %cl,%ecx
f0106730:	83 e9 30             	sub    $0x30,%ecx
f0106733:	eb 1e                	jmp    f0106753 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0106735:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0106738:	80 fb 19             	cmp    $0x19,%bl
f010673b:	77 08                	ja     f0106745 <strtol+0xa1>
			dig = *s - 'a' + 10;
f010673d:	0f be c9             	movsbl %cl,%ecx
f0106740:	83 e9 57             	sub    $0x57,%ecx
f0106743:	eb 0e                	jmp    f0106753 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0106745:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0106748:	80 fb 19             	cmp    $0x19,%bl
f010674b:	77 14                	ja     f0106761 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010674d:	0f be c9             	movsbl %cl,%ecx
f0106750:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106753:	39 f1                	cmp    %esi,%ecx
f0106755:	7d 0e                	jge    f0106765 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0106757:	83 c2 01             	add    $0x1,%edx
f010675a:	0f af c6             	imul   %esi,%eax
f010675d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010675f:	eb c1                	jmp    f0106722 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106761:	89 c1                	mov    %eax,%ecx
f0106763:	eb 02                	jmp    f0106767 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106765:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106767:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010676b:	74 05                	je     f0106772 <strtol+0xce>
		*endptr = (char *) s;
f010676d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106770:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106772:	89 ca                	mov    %ecx,%edx
f0106774:	f7 da                	neg    %edx
f0106776:	85 ff                	test   %edi,%edi
f0106778:	0f 45 c2             	cmovne %edx,%eax
}
f010677b:	5b                   	pop    %ebx
f010677c:	5e                   	pop    %esi
f010677d:	5f                   	pop    %edi
f010677e:	5d                   	pop    %ebp
f010677f:	c3                   	ret    

f0106780 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106780:	fa                   	cli    

	xorw    %ax, %ax
f0106781:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106783:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106785:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106787:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106789:	0f 01 16             	lgdtl  (%esi)
f010678c:	74 70                	je     f01067fe <mpentry_end+0x4>
	movl    %cr0, %eax
f010678e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106791:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106795:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106798:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010679e:	08 00                	or     %al,(%eax)

f01067a0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01067a0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01067a4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01067a6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01067a8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01067aa:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01067ae:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01067b0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01067b2:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f01067b7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01067ba:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01067bd:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01067c2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01067c5:	8b 25 84 ce 20 f0    	mov    0xf020ce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01067cb:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01067d0:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01067d5:	ff d0                	call   *%eax

f01067d7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01067d7:	eb fe                	jmp    f01067d7 <spin>
f01067d9:	8d 76 00             	lea    0x0(%esi),%esi

f01067dc <gdt>:
	...
f01067e4:	ff                   	(bad)  
f01067e5:	ff 00                	incl   (%eax)
f01067e7:	00 00                	add    %al,(%eax)
f01067e9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01067f0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01067f4 <gdtdesc>:
f01067f4:	17                   	pop    %ss
f01067f5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01067fa <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01067fa:	90                   	nop
f01067fb:	00 00                	add    %al,(%eax)
f01067fd:	00 00                	add    %al,(%eax)
	...

f0106800 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106800:	55                   	push   %ebp
f0106801:	89 e5                	mov    %esp,%ebp
f0106803:	56                   	push   %esi
f0106804:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106805:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f010680a:	85 d2                	test   %edx,%edx
f010680c:	7e 12                	jle    f0106820 <sum+0x20>
f010680e:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0106813:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106817:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106819:	83 c1 01             	add    $0x1,%ecx
f010681c:	39 d1                	cmp    %edx,%ecx
f010681e:	75 f3                	jne    f0106813 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106820:	89 d8                	mov    %ebx,%eax
f0106822:	5b                   	pop    %ebx
f0106823:	5e                   	pop    %esi
f0106824:	5d                   	pop    %ebp
f0106825:	c3                   	ret    

f0106826 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106826:	55                   	push   %ebp
f0106827:	89 e5                	mov    %esp,%ebp
f0106829:	56                   	push   %esi
f010682a:	53                   	push   %ebx
f010682b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010682e:	8b 0d 88 ce 20 f0    	mov    0xf020ce88,%ecx
f0106834:	89 c3                	mov    %eax,%ebx
f0106836:	c1 eb 0c             	shr    $0xc,%ebx
f0106839:	39 cb                	cmp    %ecx,%ebx
f010683b:	72 20                	jb     f010685d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010683d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106841:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0106848:	f0 
f0106849:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106850:	00 
f0106851:	c7 04 24 3d 91 10 f0 	movl   $0xf010913d,(%esp)
f0106858:	e8 e3 97 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010685d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106860:	89 f2                	mov    %esi,%edx
f0106862:	c1 ea 0c             	shr    $0xc,%edx
f0106865:	39 d1                	cmp    %edx,%ecx
f0106867:	77 20                	ja     f0106889 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106869:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010686d:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0106874:	f0 
f0106875:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010687c:	00 
f010687d:	c7 04 24 3d 91 10 f0 	movl   $0xf010913d,(%esp)
f0106884:	e8 b7 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106889:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010688f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106895:	39 f3                	cmp    %esi,%ebx
f0106897:	73 3a                	jae    f01068d3 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106899:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01068a0:	00 
f01068a1:	c7 44 24 04 4d 91 10 	movl   $0xf010914d,0x4(%esp)
f01068a8:	f0 
f01068a9:	89 1c 24             	mov    %ebx,(%esp)
f01068ac:	e8 75 fd ff ff       	call   f0106626 <memcmp>
f01068b1:	85 c0                	test   %eax,%eax
f01068b3:	75 10                	jne    f01068c5 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f01068b5:	ba 10 00 00 00       	mov    $0x10,%edx
f01068ba:	89 d8                	mov    %ebx,%eax
f01068bc:	e8 3f ff ff ff       	call   f0106800 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01068c1:	84 c0                	test   %al,%al
f01068c3:	74 13                	je     f01068d8 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01068c5:	83 c3 10             	add    $0x10,%ebx
f01068c8:	39 f3                	cmp    %esi,%ebx
f01068ca:	72 cd                	jb     f0106899 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01068cc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01068d1:	eb 05                	jmp    f01068d8 <mpsearch1+0xb2>
f01068d3:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01068d8:	89 d8                	mov    %ebx,%eax
f01068da:	83 c4 10             	add    $0x10,%esp
f01068dd:	5b                   	pop    %ebx
f01068de:	5e                   	pop    %esi
f01068df:	5d                   	pop    %ebp
f01068e0:	c3                   	ret    

f01068e1 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01068e1:	55                   	push   %ebp
f01068e2:	89 e5                	mov    %esp,%ebp
f01068e4:	57                   	push   %edi
f01068e5:	56                   	push   %esi
f01068e6:	53                   	push   %ebx
f01068e7:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01068ea:	c7 05 c0 d3 20 f0 20 	movl   $0xf020d020,0xf020d3c0
f01068f1:	d0 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01068f4:	83 3d 88 ce 20 f0 00 	cmpl   $0x0,0xf020ce88
f01068fb:	75 24                	jne    f0106921 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01068fd:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106904:	00 
f0106905:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f010690c:	f0 
f010690d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106914:	00 
f0106915:	c7 04 24 3d 91 10 f0 	movl   $0xf010913d,(%esp)
f010691c:	e8 1f 97 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106921:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106928:	85 c0                	test   %eax,%eax
f010692a:	74 16                	je     f0106942 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010692c:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010692f:	ba 00 04 00 00       	mov    $0x400,%edx
f0106934:	e8 ed fe ff ff       	call   f0106826 <mpsearch1>
f0106939:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010693c:	85 c0                	test   %eax,%eax
f010693e:	75 3c                	jne    f010697c <mp_init+0x9b>
f0106940:	eb 20                	jmp    f0106962 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106942:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106949:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010694c:	2d 00 04 00 00       	sub    $0x400,%eax
f0106951:	ba 00 04 00 00       	mov    $0x400,%edx
f0106956:	e8 cb fe ff ff       	call   f0106826 <mpsearch1>
f010695b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010695e:	85 c0                	test   %eax,%eax
f0106960:	75 1a                	jne    f010697c <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106962:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106967:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010696c:	e8 b5 fe ff ff       	call   f0106826 <mpsearch1>
f0106971:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106974:	85 c0                	test   %eax,%eax
f0106976:	0f 84 24 02 00 00    	je     f0106ba0 <mp_init+0x2bf>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010697c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010697f:	8b 78 04             	mov    0x4(%eax),%edi
f0106982:	85 ff                	test   %edi,%edi
f0106984:	74 06                	je     f010698c <mp_init+0xab>
f0106986:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010698a:	74 11                	je     f010699d <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010698c:	c7 04 24 b0 8f 10 f0 	movl   $0xf0108fb0,(%esp)
f0106993:	e8 6a dc ff ff       	call   f0104602 <cprintf>
f0106998:	e9 03 02 00 00       	jmp    f0106ba0 <mp_init+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010699d:	89 f8                	mov    %edi,%eax
f010699f:	c1 e8 0c             	shr    $0xc,%eax
f01069a2:	3b 05 88 ce 20 f0    	cmp    0xf020ce88,%eax
f01069a8:	72 20                	jb     f01069ca <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01069aa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01069ae:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f01069b5:	f0 
f01069b6:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01069bd:	00 
f01069be:	c7 04 24 3d 91 10 f0 	movl   $0xf010913d,(%esp)
f01069c5:	e8 76 96 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01069ca:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01069d0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01069d7:	00 
f01069d8:	c7 44 24 04 52 91 10 	movl   $0xf0109152,0x4(%esp)
f01069df:	f0 
f01069e0:	89 3c 24             	mov    %edi,(%esp)
f01069e3:	e8 3e fc ff ff       	call   f0106626 <memcmp>
f01069e8:	85 c0                	test   %eax,%eax
f01069ea:	74 11                	je     f01069fd <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01069ec:	c7 04 24 e0 8f 10 f0 	movl   $0xf0108fe0,(%esp)
f01069f3:	e8 0a dc ff ff       	call   f0104602 <cprintf>
f01069f8:	e9 a3 01 00 00       	jmp    f0106ba0 <mp_init+0x2bf>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01069fd:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f0106a01:	0f b7 d3             	movzwl %bx,%edx
f0106a04:	89 f8                	mov    %edi,%eax
f0106a06:	e8 f5 fd ff ff       	call   f0106800 <sum>
f0106a0b:	84 c0                	test   %al,%al
f0106a0d:	74 11                	je     f0106a20 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106a0f:	c7 04 24 14 90 10 f0 	movl   $0xf0109014,(%esp)
f0106a16:	e8 e7 db ff ff       	call   f0104602 <cprintf>
f0106a1b:	e9 80 01 00 00       	jmp    f0106ba0 <mp_init+0x2bf>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106a20:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106a24:	3c 01                	cmp    $0x1,%al
f0106a26:	74 1c                	je     f0106a44 <mp_init+0x163>
f0106a28:	3c 04                	cmp    $0x4,%al
f0106a2a:	74 18                	je     f0106a44 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106a2c:	0f b6 c0             	movzbl %al,%eax
f0106a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a33:	c7 04 24 38 90 10 f0 	movl   $0xf0109038,(%esp)
f0106a3a:	e8 c3 db ff ff       	call   f0104602 <cprintf>
f0106a3f:	e9 5c 01 00 00       	jmp    f0106ba0 <mp_init+0x2bf>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106a44:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106a48:	0f b7 db             	movzwl %bx,%ebx
f0106a4b:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0106a4e:	e8 ad fd ff ff       	call   f0106800 <sum>
f0106a53:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106a56:	74 11                	je     f0106a69 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106a58:	c7 04 24 58 90 10 f0 	movl   $0xf0109058,(%esp)
f0106a5f:	e8 9e db ff ff       	call   f0104602 <cprintf>
f0106a64:	e9 37 01 00 00       	jmp    f0106ba0 <mp_init+0x2bf>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106a69:	85 ff                	test   %edi,%edi
f0106a6b:	0f 84 2f 01 00 00    	je     f0106ba0 <mp_init+0x2bf>
		return;
	ismp = 1;
f0106a71:	c7 05 00 d0 20 f0 01 	movl   $0x1,0xf020d000
f0106a78:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106a7b:	8b 47 24             	mov    0x24(%edi),%eax
f0106a7e:	a3 00 e0 24 f0       	mov    %eax,0xf024e000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106a83:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106a88:	0f 84 97 00 00 00    	je     f0106b25 <mp_init+0x244>
f0106a8e:	8d 77 2c             	lea    0x2c(%edi),%esi
f0106a91:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0106a96:	0f b6 06             	movzbl (%esi),%eax
f0106a99:	84 c0                	test   %al,%al
f0106a9b:	74 06                	je     f0106aa3 <mp_init+0x1c2>
f0106a9d:	3c 04                	cmp    $0x4,%al
f0106a9f:	77 54                	ja     f0106af5 <mp_init+0x214>
f0106aa1:	eb 4d                	jmp    f0106af0 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106aa3:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106aa7:	74 11                	je     f0106aba <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106aa9:	6b 05 c4 d3 20 f0 74 	imul   $0x74,0xf020d3c4,%eax
f0106ab0:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f0106ab5:	a3 c0 d3 20 f0       	mov    %eax,0xf020d3c0
			if (ncpu < NCPU) {
f0106aba:	a1 c4 d3 20 f0       	mov    0xf020d3c4,%eax
f0106abf:	83 f8 07             	cmp    $0x7,%eax
f0106ac2:	7f 13                	jg     f0106ad7 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0106ac4:	6b d0 74             	imul   $0x74,%eax,%edx
f0106ac7:	88 82 20 d0 20 f0    	mov    %al,-0xfdf2fe0(%edx)
				ncpu++;
f0106acd:	83 c0 01             	add    $0x1,%eax
f0106ad0:	a3 c4 d3 20 f0       	mov    %eax,0xf020d3c4
f0106ad5:	eb 14                	jmp    f0106aeb <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106ad7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106adb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106adf:	c7 04 24 88 90 10 f0 	movl   $0xf0109088,(%esp)
f0106ae6:	e8 17 db ff ff       	call   f0104602 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106aeb:	83 c6 14             	add    $0x14,%esi
			continue;
f0106aee:	eb 26                	jmp    f0106b16 <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106af0:	83 c6 08             	add    $0x8,%esi
			continue;
f0106af3:	eb 21                	jmp    f0106b16 <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106af5:	0f b6 c0             	movzbl %al,%eax
f0106af8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106afc:	c7 04 24 b0 90 10 f0 	movl   $0xf01090b0,(%esp)
f0106b03:	e8 fa da ff ff       	call   f0104602 <cprintf>
			ismp = 0;
f0106b08:	c7 05 00 d0 20 f0 00 	movl   $0x0,0xf020d000
f0106b0f:	00 00 00 
			i = conf->entry;
f0106b12:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106b16:	83 c3 01             	add    $0x1,%ebx
f0106b19:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106b1d:	39 d8                	cmp    %ebx,%eax
f0106b1f:	0f 87 71 ff ff ff    	ja     f0106a96 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106b25:	a1 c0 d3 20 f0       	mov    0xf020d3c0,%eax
f0106b2a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106b31:	83 3d 00 d0 20 f0 00 	cmpl   $0x0,0xf020d000
f0106b38:	75 22                	jne    f0106b5c <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106b3a:	c7 05 c4 d3 20 f0 01 	movl   $0x1,0xf020d3c4
f0106b41:	00 00 00 
		lapicaddr = 0;
f0106b44:	c7 05 00 e0 24 f0 00 	movl   $0x0,0xf024e000
f0106b4b:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106b4e:	c7 04 24 d0 90 10 f0 	movl   $0xf01090d0,(%esp)
f0106b55:	e8 a8 da ff ff       	call   f0104602 <cprintf>
		return;
f0106b5a:	eb 44                	jmp    f0106ba0 <mp_init+0x2bf>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106b5c:	8b 15 c4 d3 20 f0    	mov    0xf020d3c4,%edx
f0106b62:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b66:	0f b6 00             	movzbl (%eax),%eax
f0106b69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b6d:	c7 04 24 57 91 10 f0 	movl   $0xf0109157,(%esp)
f0106b74:	e8 89 da ff ff       	call   f0104602 <cprintf>

	if (mp->imcrp) {
f0106b79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106b7c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106b80:	74 1e                	je     f0106ba0 <mp_init+0x2bf>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106b82:	c7 04 24 fc 90 10 f0 	movl   $0xf01090fc,(%esp)
f0106b89:	e8 74 da ff ff       	call   f0104602 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b8e:	ba 22 00 00 00       	mov    $0x22,%edx
f0106b93:	b8 70 00 00 00       	mov    $0x70,%eax
f0106b98:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106b99:	b2 23                	mov    $0x23,%dl
f0106b9b:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106b9c:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b9f:	ee                   	out    %al,(%dx)
	}
}
f0106ba0:	83 c4 2c             	add    $0x2c,%esp
f0106ba3:	5b                   	pop    %ebx
f0106ba4:	5e                   	pop    %esi
f0106ba5:	5f                   	pop    %edi
f0106ba6:	5d                   	pop    %ebp
f0106ba7:	c3                   	ret    

f0106ba8 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106ba8:	55                   	push   %ebp
f0106ba9:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106bab:	c1 e0 02             	shl    $0x2,%eax
f0106bae:	03 05 04 e0 24 f0    	add    0xf024e004,%eax
f0106bb4:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106bb6:	a1 04 e0 24 f0       	mov    0xf024e004,%eax
f0106bbb:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106bbe:	5d                   	pop    %ebp
f0106bbf:	c3                   	ret    

f0106bc0 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106bc0:	55                   	push   %ebp
f0106bc1:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106bc3:	8b 15 04 e0 24 f0    	mov    0xf024e004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f0106bce:	85 d2                	test   %edx,%edx
f0106bd0:	74 06                	je     f0106bd8 <cpunum+0x18>
		return lapic[ID] >> 24;
f0106bd2:	8b 42 20             	mov    0x20(%edx),%eax
f0106bd5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106bd8:	5d                   	pop    %ebp
f0106bd9:	c3                   	ret    

f0106bda <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106bda:	55                   	push   %ebp
f0106bdb:	89 e5                	mov    %esp,%ebp
f0106bdd:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106be0:	a1 00 e0 24 f0       	mov    0xf024e000,%eax
f0106be5:	85 c0                	test   %eax,%eax
f0106be7:	0f 84 1c 01 00 00    	je     f0106d09 <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106bed:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106bf4:	00 
f0106bf5:	89 04 24             	mov    %eax,(%esp)
f0106bf8:	e8 33 af ff ff       	call   f0101b30 <mmio_map_region>
f0106bfd:	a3 04 e0 24 f0       	mov    %eax,0xf024e004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106c02:	ba 27 01 00 00       	mov    $0x127,%edx
f0106c07:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106c0c:	e8 97 ff ff ff       	call   f0106ba8 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106c11:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106c16:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106c1b:	e8 88 ff ff ff       	call   f0106ba8 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106c20:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106c25:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106c2a:	e8 79 ff ff ff       	call   f0106ba8 <lapicw>
	lapicw(TICR, 10000000); 
f0106c2f:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106c34:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106c39:	e8 6a ff ff ff       	call   f0106ba8 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106c3e:	e8 7d ff ff ff       	call   f0106bc0 <cpunum>
f0106c43:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c46:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f0106c4b:	39 05 c0 d3 20 f0    	cmp    %eax,0xf020d3c0
f0106c51:	74 0f                	je     f0106c62 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106c53:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106c58:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106c5d:	e8 46 ff ff ff       	call   f0106ba8 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106c62:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106c67:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106c6c:	e8 37 ff ff ff       	call   f0106ba8 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106c71:	a1 04 e0 24 f0       	mov    0xf024e004,%eax
f0106c76:	8b 40 30             	mov    0x30(%eax),%eax
f0106c79:	c1 e8 10             	shr    $0x10,%eax
f0106c7c:	3c 03                	cmp    $0x3,%al
f0106c7e:	76 0f                	jbe    f0106c8f <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106c80:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106c85:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106c8a:	e8 19 ff ff ff       	call   f0106ba8 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106c8f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106c94:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106c99:	e8 0a ff ff ff       	call   f0106ba8 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106c9e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ca3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106ca8:	e8 fb fe ff ff       	call   f0106ba8 <lapicw>
	lapicw(ESR, 0);
f0106cad:	ba 00 00 00 00       	mov    $0x0,%edx
f0106cb2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106cb7:	e8 ec fe ff ff       	call   f0106ba8 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106cbc:	ba 00 00 00 00       	mov    $0x0,%edx
f0106cc1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106cc6:	e8 dd fe ff ff       	call   f0106ba8 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106ccb:	ba 00 00 00 00       	mov    $0x0,%edx
f0106cd0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106cd5:	e8 ce fe ff ff       	call   f0106ba8 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106cda:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106cdf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ce4:	e8 bf fe ff ff       	call   f0106ba8 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106ce9:	8b 15 04 e0 24 f0    	mov    0xf024e004,%edx
f0106cef:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106cf5:	f6 c4 10             	test   $0x10,%ah
f0106cf8:	75 f5                	jne    f0106cef <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106cfa:	ba 00 00 00 00       	mov    $0x0,%edx
f0106cff:	b8 20 00 00 00       	mov    $0x20,%eax
f0106d04:	e8 9f fe ff ff       	call   f0106ba8 <lapicw>
}
f0106d09:	c9                   	leave  
f0106d0a:	c3                   	ret    

f0106d0b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106d0b:	55                   	push   %ebp
f0106d0c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106d0e:	83 3d 04 e0 24 f0 00 	cmpl   $0x0,0xf024e004
f0106d15:	74 0f                	je     f0106d26 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0106d17:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d1c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106d21:	e8 82 fe ff ff       	call   f0106ba8 <lapicw>
}
f0106d26:	5d                   	pop    %ebp
f0106d27:	c3                   	ret    

f0106d28 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106d28:	55                   	push   %ebp
f0106d29:	89 e5                	mov    %esp,%ebp
f0106d2b:	56                   	push   %esi
f0106d2c:	53                   	push   %ebx
f0106d2d:	83 ec 10             	sub    $0x10,%esp
f0106d30:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106d33:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106d37:	ba 70 00 00 00       	mov    $0x70,%edx
f0106d3c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106d41:	ee                   	out    %al,(%dx)
f0106d42:	b2 71                	mov    $0x71,%dl
f0106d44:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106d49:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106d4a:	83 3d 88 ce 20 f0 00 	cmpl   $0x0,0xf020ce88
f0106d51:	75 24                	jne    f0106d77 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d53:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106d5a:	00 
f0106d5b:	c7 44 24 08 48 73 10 	movl   $0xf0107348,0x8(%esp)
f0106d62:	f0 
f0106d63:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106d6a:	00 
f0106d6b:	c7 04 24 74 91 10 f0 	movl   $0xf0109174,(%esp)
f0106d72:	e8 c9 92 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106d77:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106d7e:	00 00 
	wrv[1] = addr >> 4;
f0106d80:	89 f0                	mov    %esi,%eax
f0106d82:	c1 e8 04             	shr    $0x4,%eax
f0106d85:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106d8b:	c1 e3 18             	shl    $0x18,%ebx
f0106d8e:	89 da                	mov    %ebx,%edx
f0106d90:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d95:	e8 0e fe ff ff       	call   f0106ba8 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106d9a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106d9f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106da4:	e8 ff fd ff ff       	call   f0106ba8 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106da9:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106dae:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106db3:	e8 f0 fd ff ff       	call   f0106ba8 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106db8:	c1 ee 0c             	shr    $0xc,%esi
f0106dbb:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106dc1:	89 da                	mov    %ebx,%edx
f0106dc3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106dc8:	e8 db fd ff ff       	call   f0106ba8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106dcd:	89 f2                	mov    %esi,%edx
f0106dcf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106dd4:	e8 cf fd ff ff       	call   f0106ba8 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106dd9:	89 da                	mov    %ebx,%edx
f0106ddb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106de0:	e8 c3 fd ff ff       	call   f0106ba8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106de5:	89 f2                	mov    %esi,%edx
f0106de7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106dec:	e8 b7 fd ff ff       	call   f0106ba8 <lapicw>
		microdelay(200);
	}
}
f0106df1:	83 c4 10             	add    $0x10,%esp
f0106df4:	5b                   	pop    %ebx
f0106df5:	5e                   	pop    %esi
f0106df6:	5d                   	pop    %ebp
f0106df7:	c3                   	ret    

f0106df8 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106df8:	55                   	push   %ebp
f0106df9:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106dfb:	8b 55 08             	mov    0x8(%ebp),%edx
f0106dfe:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106e04:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106e09:	e8 9a fd ff ff       	call   f0106ba8 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106e0e:	8b 15 04 e0 24 f0    	mov    0xf024e004,%edx
f0106e14:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106e1a:	f6 c4 10             	test   $0x10,%ah
f0106e1d:	75 f5                	jne    f0106e14 <lapic_ipi+0x1c>
		;
}
f0106e1f:	5d                   	pop    %ebp
f0106e20:	c3                   	ret    
f0106e21:	00 00                	add    %al,(%eax)
	...

f0106e24 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106e24:	55                   	push   %ebp
f0106e25:	89 e5                	mov    %esp,%ebp
f0106e27:	53                   	push   %ebx
f0106e28:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106e2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106e30:	83 38 00             	cmpl   $0x0,(%eax)
f0106e33:	74 18                	je     f0106e4d <holding+0x29>
f0106e35:	8b 58 08             	mov    0x8(%eax),%ebx
f0106e38:	e8 83 fd ff ff       	call   f0106bc0 <cpunum>
f0106e3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e40:	05 20 d0 20 f0       	add    $0xf020d020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106e45:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106e47:	0f 94 c2             	sete   %dl
f0106e4a:	0f b6 d2             	movzbl %dl,%edx
}
f0106e4d:	89 d0                	mov    %edx,%eax
f0106e4f:	83 c4 04             	add    $0x4,%esp
f0106e52:	5b                   	pop    %ebx
f0106e53:	5d                   	pop    %ebp
f0106e54:	c3                   	ret    

f0106e55 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106e55:	55                   	push   %ebp
f0106e56:	89 e5                	mov    %esp,%ebp
f0106e58:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106e5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106e61:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e64:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106e67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106e6e:	5d                   	pop    %ebp
f0106e6f:	c3                   	ret    

f0106e70 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106e70:	55                   	push   %ebp
f0106e71:	89 e5                	mov    %esp,%ebp
f0106e73:	53                   	push   %ebx
f0106e74:	83 ec 24             	sub    $0x24,%esp
f0106e77:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106e7a:	89 d8                	mov    %ebx,%eax
f0106e7c:	e8 a3 ff ff ff       	call   f0106e24 <holding>
f0106e81:	85 c0                	test   %eax,%eax
f0106e83:	75 12                	jne    f0106e97 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106e85:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106e87:	b0 01                	mov    $0x1,%al
f0106e89:	f0 87 03             	lock xchg %eax,(%ebx)
f0106e8c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106e91:	85 c0                	test   %eax,%eax
f0106e93:	75 2e                	jne    f0106ec3 <spin_lock+0x53>
f0106e95:	eb 37                	jmp    f0106ece <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106e97:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106e9a:	e8 21 fd ff ff       	call   f0106bc0 <cpunum>
f0106e9f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106ea7:	c7 44 24 08 84 91 10 	movl   $0xf0109184,0x8(%esp)
f0106eae:	f0 
f0106eaf:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106eb6:	00 
f0106eb7:	c7 04 24 e8 91 10 f0 	movl   $0xf01091e8,(%esp)
f0106ebe:	e8 7d 91 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106ec3:	f3 90                	pause  
f0106ec5:	89 c8                	mov    %ecx,%eax
f0106ec7:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106eca:	85 c0                	test   %eax,%eax
f0106ecc:	75 f5                	jne    f0106ec3 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106ece:	e8 ed fc ff ff       	call   f0106bc0 <cpunum>
f0106ed3:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ed6:	05 20 d0 20 f0       	add    $0xf020d020,%eax
f0106edb:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106ede:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0106ee1:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106ee3:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0106ee8:	77 34                	ja     f0106f1e <spin_lock+0xae>
f0106eea:	eb 2b                	jmp    f0106f17 <spin_lock+0xa7>
f0106eec:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106ef2:	76 12                	jbe    f0106f06 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106ef4:	8b 5a 04             	mov    0x4(%edx),%ebx
f0106ef7:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106efa:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106efc:	83 c0 01             	add    $0x1,%eax
f0106eff:	83 f8 0a             	cmp    $0xa,%eax
f0106f02:	75 e8                	jne    f0106eec <spin_lock+0x7c>
f0106f04:	eb 27                	jmp    f0106f2d <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106f06:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106f0d:	83 c0 01             	add    $0x1,%eax
f0106f10:	83 f8 09             	cmp    $0x9,%eax
f0106f13:	7e f1                	jle    f0106f06 <spin_lock+0x96>
f0106f15:	eb 16                	jmp    f0106f2d <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106f17:	b8 00 00 00 00       	mov    $0x0,%eax
f0106f1c:	eb e8                	jmp    f0106f06 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106f1e:	8b 50 04             	mov    0x4(%eax),%edx
f0106f21:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106f24:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106f26:	b8 01 00 00 00       	mov    $0x1,%eax
f0106f2b:	eb bf                	jmp    f0106eec <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106f2d:	83 c4 24             	add    $0x24,%esp
f0106f30:	5b                   	pop    %ebx
f0106f31:	5d                   	pop    %ebp
f0106f32:	c3                   	ret    

f0106f33 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106f33:	55                   	push   %ebp
f0106f34:	89 e5                	mov    %esp,%ebp
f0106f36:	83 ec 78             	sub    $0x78,%esp
f0106f39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106f3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106f3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106f42:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106f45:	89 d8                	mov    %ebx,%eax
f0106f47:	e8 d8 fe ff ff       	call   f0106e24 <holding>
f0106f4c:	85 c0                	test   %eax,%eax
f0106f4e:	0f 85 d4 00 00 00    	jne    f0107028 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106f54:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106f5b:	00 
f0106f5c:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f63:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106f66:	89 04 24             	mov    %eax,(%esp)
f0106f69:	e8 1e f6 ff ff       	call   f010658c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106f6e:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106f71:	0f b6 30             	movzbl (%eax),%esi
f0106f74:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106f77:	e8 44 fc ff ff       	call   f0106bc0 <cpunum>
f0106f7c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106f80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106f84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f88:	c7 04 24 b0 91 10 f0 	movl   $0xf01091b0,(%esp)
f0106f8f:	e8 6e d6 ff ff       	call   f0104602 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f94:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106f97:	85 c0                	test   %eax,%eax
f0106f99:	74 71                	je     f010700c <spin_unlock+0xd9>
f0106f9b:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106f9e:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106fa1:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106fa8:	89 04 24             	mov    %eax,(%esp)
f0106fab:	e8 aa e8 ff ff       	call   f010585a <debuginfo_eip>
f0106fb0:	85 c0                	test   %eax,%eax
f0106fb2:	78 39                	js     f0106fed <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106fb4:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106fb6:	89 c2                	mov    %eax,%edx
f0106fb8:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106fbb:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106fbf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106fc2:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106fc6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106fc9:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106fcd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106fd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106fd4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106fd7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fdf:	c7 04 24 f8 91 10 f0 	movl   $0xf01091f8,(%esp)
f0106fe6:	e8 17 d6 ff ff       	call   f0104602 <cprintf>
f0106feb:	eb 12                	jmp    f0106fff <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106fed:	8b 03                	mov    (%ebx),%eax
f0106fef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ff3:	c7 04 24 0f 92 10 f0 	movl   $0xf010920f,(%esp)
f0106ffa:	e8 03 d6 ff ff       	call   f0104602 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106fff:	39 fb                	cmp    %edi,%ebx
f0107001:	74 09                	je     f010700c <spin_unlock+0xd9>
f0107003:	83 c3 04             	add    $0x4,%ebx
f0107006:	8b 03                	mov    (%ebx),%eax
f0107008:	85 c0                	test   %eax,%eax
f010700a:	75 98                	jne    f0106fa4 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010700c:	c7 44 24 08 17 92 10 	movl   $0xf0109217,0x8(%esp)
f0107013:	f0 
f0107014:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010701b:	00 
f010701c:	c7 04 24 e8 91 10 f0 	movl   $0xf01091e8,(%esp)
f0107023:	e8 18 90 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0107028:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010702f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107036:	b8 00 00 00 00       	mov    $0x0,%eax
f010703b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010703e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0107041:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0107044:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107047:	89 ec                	mov    %ebp,%esp
f0107049:	5d                   	pop    %ebp
f010704a:	c3                   	ret    
f010704b:	00 00                	add    %al,(%eax)
f010704d:	00 00                	add    %al,(%eax)
	...

f0107050 <__udivdi3>:
f0107050:	83 ec 1c             	sub    $0x1c,%esp
f0107053:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0107057:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010705b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010705f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0107063:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107067:	8b 74 24 24          	mov    0x24(%esp),%esi
f010706b:	85 ff                	test   %edi,%edi
f010706d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0107071:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107075:	89 cd                	mov    %ecx,%ebp
f0107077:	89 44 24 04          	mov    %eax,0x4(%esp)
f010707b:	75 33                	jne    f01070b0 <__udivdi3+0x60>
f010707d:	39 f1                	cmp    %esi,%ecx
f010707f:	77 57                	ja     f01070d8 <__udivdi3+0x88>
f0107081:	85 c9                	test   %ecx,%ecx
f0107083:	75 0b                	jne    f0107090 <__udivdi3+0x40>
f0107085:	b8 01 00 00 00       	mov    $0x1,%eax
f010708a:	31 d2                	xor    %edx,%edx
f010708c:	f7 f1                	div    %ecx
f010708e:	89 c1                	mov    %eax,%ecx
f0107090:	89 f0                	mov    %esi,%eax
f0107092:	31 d2                	xor    %edx,%edx
f0107094:	f7 f1                	div    %ecx
f0107096:	89 c6                	mov    %eax,%esi
f0107098:	8b 44 24 04          	mov    0x4(%esp),%eax
f010709c:	f7 f1                	div    %ecx
f010709e:	89 f2                	mov    %esi,%edx
f01070a0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01070a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01070a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01070ac:	83 c4 1c             	add    $0x1c,%esp
f01070af:	c3                   	ret    
f01070b0:	31 d2                	xor    %edx,%edx
f01070b2:	31 c0                	xor    %eax,%eax
f01070b4:	39 f7                	cmp    %esi,%edi
f01070b6:	77 e8                	ja     f01070a0 <__udivdi3+0x50>
f01070b8:	0f bd cf             	bsr    %edi,%ecx
f01070bb:	83 f1 1f             	xor    $0x1f,%ecx
f01070be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01070c2:	75 2c                	jne    f01070f0 <__udivdi3+0xa0>
f01070c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01070c8:	76 04                	jbe    f01070ce <__udivdi3+0x7e>
f01070ca:	39 f7                	cmp    %esi,%edi
f01070cc:	73 d2                	jae    f01070a0 <__udivdi3+0x50>
f01070ce:	31 d2                	xor    %edx,%edx
f01070d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01070d5:	eb c9                	jmp    f01070a0 <__udivdi3+0x50>
f01070d7:	90                   	nop
f01070d8:	89 f2                	mov    %esi,%edx
f01070da:	f7 f1                	div    %ecx
f01070dc:	31 d2                	xor    %edx,%edx
f01070de:	8b 74 24 10          	mov    0x10(%esp),%esi
f01070e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01070e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01070ea:	83 c4 1c             	add    $0x1c,%esp
f01070ed:	c3                   	ret    
f01070ee:	66 90                	xchg   %ax,%ax
f01070f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01070f5:	b8 20 00 00 00       	mov    $0x20,%eax
f01070fa:	89 ea                	mov    %ebp,%edx
f01070fc:	2b 44 24 04          	sub    0x4(%esp),%eax
f0107100:	d3 e7                	shl    %cl,%edi
f0107102:	89 c1                	mov    %eax,%ecx
f0107104:	d3 ea                	shr    %cl,%edx
f0107106:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010710b:	09 fa                	or     %edi,%edx
f010710d:	89 f7                	mov    %esi,%edi
f010710f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107113:	89 f2                	mov    %esi,%edx
f0107115:	8b 74 24 08          	mov    0x8(%esp),%esi
f0107119:	d3 e5                	shl    %cl,%ebp
f010711b:	89 c1                	mov    %eax,%ecx
f010711d:	d3 ef                	shr    %cl,%edi
f010711f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107124:	d3 e2                	shl    %cl,%edx
f0107126:	89 c1                	mov    %eax,%ecx
f0107128:	d3 ee                	shr    %cl,%esi
f010712a:	09 d6                	or     %edx,%esi
f010712c:	89 fa                	mov    %edi,%edx
f010712e:	89 f0                	mov    %esi,%eax
f0107130:	f7 74 24 0c          	divl   0xc(%esp)
f0107134:	89 d7                	mov    %edx,%edi
f0107136:	89 c6                	mov    %eax,%esi
f0107138:	f7 e5                	mul    %ebp
f010713a:	39 d7                	cmp    %edx,%edi
f010713c:	72 22                	jb     f0107160 <__udivdi3+0x110>
f010713e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0107142:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107147:	d3 e5                	shl    %cl,%ebp
f0107149:	39 c5                	cmp    %eax,%ebp
f010714b:	73 04                	jae    f0107151 <__udivdi3+0x101>
f010714d:	39 d7                	cmp    %edx,%edi
f010714f:	74 0f                	je     f0107160 <__udivdi3+0x110>
f0107151:	89 f0                	mov    %esi,%eax
f0107153:	31 d2                	xor    %edx,%edx
f0107155:	e9 46 ff ff ff       	jmp    f01070a0 <__udivdi3+0x50>
f010715a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107160:	8d 46 ff             	lea    -0x1(%esi),%eax
f0107163:	31 d2                	xor    %edx,%edx
f0107165:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107169:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010716d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0107171:	83 c4 1c             	add    $0x1c,%esp
f0107174:	c3                   	ret    
	...

f0107180 <__umoddi3>:
f0107180:	83 ec 1c             	sub    $0x1c,%esp
f0107183:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0107187:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010718b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010718f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107193:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0107197:	8b 74 24 24          	mov    0x24(%esp),%esi
f010719b:	85 ed                	test   %ebp,%ebp
f010719d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01071a1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01071a5:	89 cf                	mov    %ecx,%edi
f01071a7:	89 04 24             	mov    %eax,(%esp)
f01071aa:	89 f2                	mov    %esi,%edx
f01071ac:	75 1a                	jne    f01071c8 <__umoddi3+0x48>
f01071ae:	39 f1                	cmp    %esi,%ecx
f01071b0:	76 4e                	jbe    f0107200 <__umoddi3+0x80>
f01071b2:	f7 f1                	div    %ecx
f01071b4:	89 d0                	mov    %edx,%eax
f01071b6:	31 d2                	xor    %edx,%edx
f01071b8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01071bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01071c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01071c4:	83 c4 1c             	add    $0x1c,%esp
f01071c7:	c3                   	ret    
f01071c8:	39 f5                	cmp    %esi,%ebp
f01071ca:	77 54                	ja     f0107220 <__umoddi3+0xa0>
f01071cc:	0f bd c5             	bsr    %ebp,%eax
f01071cf:	83 f0 1f             	xor    $0x1f,%eax
f01071d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01071d6:	75 60                	jne    f0107238 <__umoddi3+0xb8>
f01071d8:	3b 0c 24             	cmp    (%esp),%ecx
f01071db:	0f 87 07 01 00 00    	ja     f01072e8 <__umoddi3+0x168>
f01071e1:	89 f2                	mov    %esi,%edx
f01071e3:	8b 34 24             	mov    (%esp),%esi
f01071e6:	29 ce                	sub    %ecx,%esi
f01071e8:	19 ea                	sbb    %ebp,%edx
f01071ea:	89 34 24             	mov    %esi,(%esp)
f01071ed:	8b 04 24             	mov    (%esp),%eax
f01071f0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01071f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01071f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01071fc:	83 c4 1c             	add    $0x1c,%esp
f01071ff:	c3                   	ret    
f0107200:	85 c9                	test   %ecx,%ecx
f0107202:	75 0b                	jne    f010720f <__umoddi3+0x8f>
f0107204:	b8 01 00 00 00       	mov    $0x1,%eax
f0107209:	31 d2                	xor    %edx,%edx
f010720b:	f7 f1                	div    %ecx
f010720d:	89 c1                	mov    %eax,%ecx
f010720f:	89 f0                	mov    %esi,%eax
f0107211:	31 d2                	xor    %edx,%edx
f0107213:	f7 f1                	div    %ecx
f0107215:	8b 04 24             	mov    (%esp),%eax
f0107218:	f7 f1                	div    %ecx
f010721a:	eb 98                	jmp    f01071b4 <__umoddi3+0x34>
f010721c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107220:	89 f2                	mov    %esi,%edx
f0107222:	8b 74 24 10          	mov    0x10(%esp),%esi
f0107226:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010722a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010722e:	83 c4 1c             	add    $0x1c,%esp
f0107231:	c3                   	ret    
f0107232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107238:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010723d:	89 e8                	mov    %ebp,%eax
f010723f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0107244:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0107248:	89 fa                	mov    %edi,%edx
f010724a:	d3 e0                	shl    %cl,%eax
f010724c:	89 e9                	mov    %ebp,%ecx
f010724e:	d3 ea                	shr    %cl,%edx
f0107250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0107255:	09 c2                	or     %eax,%edx
f0107257:	8b 44 24 08          	mov    0x8(%esp),%eax
f010725b:	89 14 24             	mov    %edx,(%esp)
f010725e:	89 f2                	mov    %esi,%edx
f0107260:	d3 e7                	shl    %cl,%edi
f0107262:	89 e9                	mov    %ebp,%ecx
f0107264:	d3 ea                	shr    %cl,%edx
f0107266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010726b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010726f:	d3 e6                	shl    %cl,%esi
f0107271:	89 e9                	mov    %ebp,%ecx
f0107273:	d3 e8                	shr    %cl,%eax
f0107275:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010727a:	09 f0                	or     %esi,%eax
f010727c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0107280:	f7 34 24             	divl   (%esp)
f0107283:	d3 e6                	shl    %cl,%esi
f0107285:	89 74 24 08          	mov    %esi,0x8(%esp)
f0107289:	89 d6                	mov    %edx,%esi
f010728b:	f7 e7                	mul    %edi
f010728d:	39 d6                	cmp    %edx,%esi
f010728f:	89 c1                	mov    %eax,%ecx
f0107291:	89 d7                	mov    %edx,%edi
f0107293:	72 3f                	jb     f01072d4 <__umoddi3+0x154>
f0107295:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0107299:	72 35                	jb     f01072d0 <__umoddi3+0x150>
f010729b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010729f:	29 c8                	sub    %ecx,%eax
f01072a1:	19 fe                	sbb    %edi,%esi
f01072a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01072a8:	89 f2                	mov    %esi,%edx
f01072aa:	d3 e8                	shr    %cl,%eax
f01072ac:	89 e9                	mov    %ebp,%ecx
f01072ae:	d3 e2                	shl    %cl,%edx
f01072b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01072b5:	09 d0                	or     %edx,%eax
f01072b7:	89 f2                	mov    %esi,%edx
f01072b9:	d3 ea                	shr    %cl,%edx
f01072bb:	8b 74 24 10          	mov    0x10(%esp),%esi
f01072bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01072c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01072c7:	83 c4 1c             	add    $0x1c,%esp
f01072ca:	c3                   	ret    
f01072cb:	90                   	nop
f01072cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01072d0:	39 d6                	cmp    %edx,%esi
f01072d2:	75 c7                	jne    f010729b <__umoddi3+0x11b>
f01072d4:	89 d7                	mov    %edx,%edi
f01072d6:	89 c1                	mov    %eax,%ecx
f01072d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01072dc:	1b 3c 24             	sbb    (%esp),%edi
f01072df:	eb ba                	jmp    f010729b <__umoddi3+0x11b>
f01072e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01072e8:	39 f5                	cmp    %esi,%ebp
f01072ea:	0f 82 f1 fe ff ff    	jb     f01071e1 <__umoddi3+0x61>
f01072f0:	e9 f8 fe ff ff       	jmp    f01071ed <__umoddi3+0x6d>
