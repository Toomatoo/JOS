
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
f0100039:	e8 e1 00 00 00       	call   f010011f <i386_init>

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
f010004b:	83 3d e0 5e 22 f0 00 	cmpl   $0x0,0xf0225ee0
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 e0 5e 22 f0    	mov    %esi,0xf0225ee0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 2c 63 00 00       	call   f0106390 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 e0 6a 10 f0 	movl   $0xf0106ae0,(%esp)
f010007d:	e8 5c 45 00 00       	call   f01045de <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 1d 45 00 00       	call   f01045ab <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f0100095:	e8 44 45 00 00       	call   f01045de <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 66 0f 00 00       	call   f010100c <monitor>
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
f01000ae:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 4b 6b 10 f0 	movl   $0xf0106b4b,(%esp)
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
f01000e2:	e8 a9 62 00 00       	call   f0106390 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 57 6b 10 f0 	movl   $0xf0106b57,(%esp)
f01000f2:	e8 e7 44 00 00       	call   f01045de <cprintf>

	lapic_init();
f01000f7:	e8 ae 62 00 00       	call   f01063aa <lapic_init>
	env_init_percpu();
f01000fc:	e8 80 3c 00 00       	call   f0103d81 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 fa 44 00 00       	call   f0104600 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 85 62 00 00       	call   f0106390 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 60 22 f0    	add    $0xf0226020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010011d:	eb fe                	jmp    f010011d <mp_main+0x75>

f010011f <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010011f:	55                   	push   %ebp
f0100120:	89 e5                	mov    %esp,%ebp
f0100122:	53                   	push   %ebx
f0100123:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100126:	b8 08 70 26 f0       	mov    $0xf0267008,%eax
f010012b:	2d 6a 40 22 f0       	sub    $0xf022406a,%eax
f0100130:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100134:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010013b:	00 
f010013c:	c7 04 24 6a 40 22 f0 	movl   $0xf022406a,(%esp)
f0100143:	e8 b9 5b 00 00       	call   f0105d01 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100148:	e8 1e 05 00 00       	call   f010066b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010014d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100154:	00 
f0100155:	c7 04 24 6d 6b 10 f0 	movl   $0xf0106b6d,(%esp)
f010015c:	e8 7d 44 00 00       	call   f01045de <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100161:	e8 ed 19 00 00       	call   f0101b53 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100166:	e8 40 3c 00 00       	call   f0103dab <env_init>
	trap_init();
f010016b:	90                   	nop
f010016c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100170:	e8 e8 44 00 00       	call   f010465d <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100175:	e8 37 5f 00 00       	call   f01060b1 <mp_init>
	lapic_init();
f010017a:	e8 2b 62 00 00       	call   f01063aa <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010017f:	90                   	nop
f0100180:	e8 88 43 00 00       	call   f010450d <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100185:	83 3d e8 5e 22 f0 07 	cmpl   $0x7,0xf0225ee8
f010018c:	77 24                	ja     f01001b2 <i386_init+0x93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010018e:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100195:	00 
f0100196:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010019d:	f0 
f010019e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f01001a5:	00 
f01001a6:	c7 04 24 4b 6b 10 f0 	movl   $0xf0106b4b,(%esp)
f01001ad:	e8 8e fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001b2:	b8 ca 5f 10 f0       	mov    $0xf0105fca,%eax
f01001b7:	2d 50 5f 10 f0       	sub    $0xf0105f50,%eax
f01001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001c0:	c7 44 24 04 50 5f 10 	movl   $0xf0105f50,0x4(%esp)
f01001c7:	f0 
f01001c8:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001cf:	e8 88 5b 00 00       	call   f0105d5c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001d4:	6b 05 c4 63 22 f0 74 	imul   $0x74,0xf02263c4,%eax
f01001db:	05 20 60 22 f0       	add    $0xf0226020,%eax
f01001e0:	3d 20 60 22 f0       	cmp    $0xf0226020,%eax
f01001e5:	76 62                	jbe    f0100249 <i386_init+0x12a>
f01001e7:	bb 20 60 22 f0       	mov    $0xf0226020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f01001ec:	e8 9f 61 00 00       	call   f0106390 <cpunum>
f01001f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01001f4:	05 20 60 22 f0       	add    $0xf0226020,%eax
f01001f9:	39 c3                	cmp    %eax,%ebx
f01001fb:	74 39                	je     f0100236 <i386_init+0x117>

static void boot_aps(void);


void
i386_init(void)
f01001fd:	89 d8                	mov    %ebx,%eax
f01001ff:	2d 20 60 22 f0       	sub    $0xf0226020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100204:	c1 f8 02             	sar    $0x2,%eax
f0100207:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010020d:	c1 e0 0f             	shl    $0xf,%eax
f0100210:	8d 80 00 f0 22 f0    	lea    -0xfdd1000(%eax),%eax
f0100216:	a3 e4 5e 22 f0       	mov    %eax,0xf0225ee4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100222:	00 
f0100223:	0f b6 03             	movzbl (%ebx),%eax
f0100226:	89 04 24             	mov    %eax,(%esp)
f0100229:	e8 ca 62 00 00       	call   f01064f8 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010022e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100231:	83 f8 01             	cmp    $0x1,%eax
f0100234:	75 f8                	jne    f010022e <i386_init+0x10f>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100236:	83 c3 74             	add    $0x74,%ebx
f0100239:	6b 05 c4 63 22 f0 74 	imul   $0x74,0xf02263c4,%eax
f0100240:	05 20 60 22 f0       	add    $0xf0226020,%eax
f0100245:	39 c3                	cmp    %eax,%ebx
f0100247:	72 a3                	jb     f01001ec <i386_init+0xcd>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f0100249:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100250:	00 
f0100251:	c7 44 24 04 f8 89 00 	movl   $0x89f8,0x4(%esp)
f0100258:	00 
f0100259:	c7 04 24 72 b6 21 f0 	movl   $0xf021b672,(%esp)
f0100260:	e8 33 3d 00 00       	call   f0103f98 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100265:	e8 36 4b 00 00       	call   f0104da0 <sched_yield>

f010026a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	53                   	push   %ebx
f010026e:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100271:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100274:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100277:	89 44 24 08          	mov    %eax,0x8(%esp)
f010027b:	8b 45 08             	mov    0x8(%ebp),%eax
f010027e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100282:	c7 04 24 88 6b 10 f0 	movl   $0xf0106b88,(%esp)
f0100289:	e8 50 43 00 00       	call   f01045de <cprintf>
	vcprintf(fmt, ap);
f010028e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100292:	8b 45 10             	mov    0x10(%ebp),%eax
f0100295:	89 04 24             	mov    %eax,(%esp)
f0100298:	e8 0e 43 00 00       	call   f01045ab <vcprintf>
	cprintf("\n");
f010029d:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f01002a4:	e8 35 43 00 00       	call   f01045de <cprintf>
	va_end(ap);
}
f01002a9:	83 c4 14             	add    $0x14,%esp
f01002ac:	5b                   	pop    %ebx
f01002ad:	5d                   	pop    %ebp
f01002ae:	c3                   	ret    
	...

f01002b0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002b0:	55                   	push   %ebp
f01002b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002b8:	ec                   	in     (%dx),%al
f01002b9:	ec                   	in     (%dx),%al
f01002ba:	ec                   	in     (%dx),%al
f01002bb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002be:	55                   	push   %ebp
f01002bf:	89 e5                	mov    %esp,%ebp
f01002c1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002c7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002cc:	a8 01                	test   $0x1,%al
f01002ce:	74 06                	je     f01002d6 <serial_proc_data+0x18>
f01002d0:	b2 f8                	mov    $0xf8,%dl
f01002d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d3:	0f b6 c8             	movzbl %al,%ecx
}
f01002d6:	89 c8                	mov    %ecx,%eax
f01002d8:	5d                   	pop    %ebp
f01002d9:	c3                   	ret    

f01002da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002da:	55                   	push   %ebp
f01002db:	89 e5                	mov    %esp,%ebp
f01002dd:	53                   	push   %ebx
f01002de:	83 ec 04             	sub    $0x4,%esp
f01002e1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e3:	eb 25                	jmp    f010030a <cons_intr+0x30>
		if (c == 0)
f01002e5:	85 c0                	test   %eax,%eax
f01002e7:	74 21                	je     f010030a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01002e9:	8b 15 24 52 22 f0    	mov    0xf0225224,%edx
f01002ef:	88 82 20 50 22 f0    	mov    %al,-0xfddafe0(%edx)
f01002f5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002f8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0100302:	0f 44 c2             	cmove  %edx,%eax
f0100305:	a3 24 52 22 f0       	mov    %eax,0xf0225224
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010030a:	ff d3                	call   *%ebx
f010030c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010030f:	75 d4                	jne    f01002e5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100311:	83 c4 04             	add    $0x4,%esp
f0100314:	5b                   	pop    %ebx
f0100315:	5d                   	pop    %ebp
f0100316:	c3                   	ret    

f0100317 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100317:	55                   	push   %ebp
f0100318:	89 e5                	mov    %esp,%ebp
f010031a:	57                   	push   %edi
f010031b:	56                   	push   %esi
f010031c:	53                   	push   %ebx
f010031d:	83 ec 2c             	sub    $0x2c,%esp
f0100320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100323:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100328:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100329:	a8 20                	test   $0x20,%al
f010032b:	75 1b                	jne    f0100348 <cons_putc+0x31>
f010032d:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100332:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100337:	e8 74 ff ff ff       	call   f01002b0 <delay>
f010033c:	89 f2                	mov    %esi,%edx
f010033e:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010033f:	a8 20                	test   $0x20,%al
f0100341:	75 05                	jne    f0100348 <cons_putc+0x31>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100343:	83 eb 01             	sub    $0x1,%ebx
f0100346:	75 ef                	jne    f0100337 <cons_putc+0x20>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100348:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100351:	89 f8                	mov    %edi,%eax
f0100353:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100354:	b2 79                	mov    $0x79,%dl
f0100356:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100357:	84 c0                	test   %al,%al
f0100359:	78 1b                	js     f0100376 <cons_putc+0x5f>
f010035b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100360:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100365:	e8 46 ff ff ff       	call   f01002b0 <delay>
f010036a:	89 f2                	mov    %esi,%edx
f010036c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036d:	84 c0                	test   %al,%al
f010036f:	78 05                	js     f0100376 <cons_putc+0x5f>
f0100371:	83 eb 01             	sub    $0x1,%ebx
f0100374:	75 ef                	jne    f0100365 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100376:	ba 78 03 00 00       	mov    $0x378,%edx
f010037b:	89 f8                	mov    %edi,%eax
f010037d:	ee                   	out    %al,(%dx)
f010037e:	b2 7a                	mov    $0x7a,%dl
f0100380:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100385:	ee                   	out    %al,(%dx)
f0100386:	b8 08 00 00 00       	mov    $0x8,%eax
f010038b:	ee                   	out    %al,(%dx)
extern int ncolor;

static void
cga_putc(int c)
{
	c = c + (ncolor << 8);
f010038c:	a1 78 24 12 f0       	mov    0xf0122478,%eax
f0100391:	c1 e0 08             	shl    $0x8,%eax
f0100394:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100397:	89 c1                	mov    %eax,%ecx
f0100399:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f010039f:	89 c2                	mov    %eax,%edx
f01003a1:	80 ce 07             	or     $0x7,%dh
f01003a4:	85 c9                	test   %ecx,%ecx
f01003a6:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01003a9:	0f b6 d0             	movzbl %al,%edx
f01003ac:	83 fa 09             	cmp    $0x9,%edx
f01003af:	74 75                	je     f0100426 <cons_putc+0x10f>
f01003b1:	83 fa 09             	cmp    $0x9,%edx
f01003b4:	7f 0c                	jg     f01003c2 <cons_putc+0xab>
f01003b6:	83 fa 08             	cmp    $0x8,%edx
f01003b9:	0f 85 9b 00 00 00    	jne    f010045a <cons_putc+0x143>
f01003bf:	90                   	nop
f01003c0:	eb 10                	jmp    f01003d2 <cons_putc+0xbb>
f01003c2:	83 fa 0a             	cmp    $0xa,%edx
f01003c5:	74 39                	je     f0100400 <cons_putc+0xe9>
f01003c7:	83 fa 0d             	cmp    $0xd,%edx
f01003ca:	0f 85 8a 00 00 00    	jne    f010045a <cons_putc+0x143>
f01003d0:	eb 36                	jmp    f0100408 <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f01003d2:	0f b7 15 34 52 22 f0 	movzwl 0xf0225234,%edx
f01003d9:	66 85 d2             	test   %dx,%dx
f01003dc:	0f 84 e3 00 00 00    	je     f01004c5 <cons_putc+0x1ae>
			crt_pos--;
f01003e2:	83 ea 01             	sub    $0x1,%edx
f01003e5:	66 89 15 34 52 22 f0 	mov    %dx,0xf0225234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ec:	0f b7 d2             	movzwl %dx,%edx
f01003ef:	b0 00                	mov    $0x0,%al
f01003f1:	83 c8 20             	or     $0x20,%eax
f01003f4:	8b 0d 30 52 22 f0    	mov    0xf0225230,%ecx
f01003fa:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01003fe:	eb 78                	jmp    f0100478 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100400:	66 83 05 34 52 22 f0 	addw   $0x50,0xf0225234
f0100407:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100408:	0f b7 05 34 52 22 f0 	movzwl 0xf0225234,%eax
f010040f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100415:	c1 e8 16             	shr    $0x16,%eax
f0100418:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010041b:	c1 e0 04             	shl    $0x4,%eax
f010041e:	66 a3 34 52 22 f0    	mov    %ax,0xf0225234
f0100424:	eb 52                	jmp    f0100478 <cons_putc+0x161>
		break;
	case '\t':
		cons_putc(' ');
f0100426:	b8 20 00 00 00       	mov    $0x20,%eax
f010042b:	e8 e7 fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 dd fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 d3 fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 c9 fe ff ff       	call   f0100317 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 bf fe ff ff       	call   f0100317 <cons_putc>
f0100458:	eb 1e                	jmp    f0100478 <cons_putc+0x161>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010045a:	0f b7 15 34 52 22 f0 	movzwl 0xf0225234,%edx
f0100461:	0f b7 da             	movzwl %dx,%ebx
f0100464:	8b 0d 30 52 22 f0    	mov    0xf0225230,%ecx
f010046a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010046e:	83 c2 01             	add    $0x1,%edx
f0100471:	66 89 15 34 52 22 f0 	mov    %dx,0xf0225234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100478:	66 81 3d 34 52 22 f0 	cmpw   $0x7cf,0xf0225234
f010047f:	cf 07 
f0100481:	76 42                	jbe    f01004c5 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100483:	a1 30 52 22 f0       	mov    0xf0225230,%eax
f0100488:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010048f:	00 
f0100490:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100496:	89 54 24 04          	mov    %edx,0x4(%esp)
f010049a:	89 04 24             	mov    %eax,(%esp)
f010049d:	e8 ba 58 00 00       	call   f0105d5c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004a2:	8b 15 30 52 22 f0    	mov    0xf0225230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a8:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004ad:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b3:	83 c0 01             	add    $0x1,%eax
f01004b6:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004bb:	75 f0                	jne    f01004ad <cons_putc+0x196>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004bd:	66 83 2d 34 52 22 f0 	subw   $0x50,0xf0225234
f01004c4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c5:	8b 0d 2c 52 22 f0    	mov    0xf022522c,%ecx
f01004cb:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d0:	89 ca                	mov    %ecx,%edx
f01004d2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d3:	0f b7 35 34 52 22 f0 	movzwl 0xf0225234,%esi
f01004da:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004dd:	89 f0                	mov    %esi,%eax
f01004df:	66 c1 e8 08          	shr    $0x8,%ax
f01004e3:	89 da                	mov    %ebx,%edx
f01004e5:	ee                   	out    %al,(%dx)
f01004e6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004eb:	89 ca                	mov    %ecx,%edx
f01004ed:	ee                   	out    %al,(%dx)
f01004ee:	89 f0                	mov    %esi,%eax
f01004f0:	89 da                	mov    %ebx,%edx
f01004f2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f3:	83 c4 2c             	add    $0x2c,%esp
f01004f6:	5b                   	pop    %ebx
f01004f7:	5e                   	pop    %esi
f01004f8:	5f                   	pop    %edi
f01004f9:	5d                   	pop    %ebp
f01004fa:	c3                   	ret    

f01004fb <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004fb:	55                   	push   %ebp
f01004fc:	89 e5                	mov    %esp,%ebp
f01004fe:	53                   	push   %ebx
f01004ff:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100502:	ba 64 00 00 00       	mov    $0x64,%edx
f0100507:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100508:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010050d:	a8 01                	test   $0x1,%al
f010050f:	0f 84 de 00 00 00    	je     f01005f3 <kbd_proc_data+0xf8>
f0100515:	b2 60                	mov    $0x60,%dl
f0100517:	ec                   	in     (%dx),%al
f0100518:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010051a:	3c e0                	cmp    $0xe0,%al
f010051c:	75 11                	jne    f010052f <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010051e:	83 0d 28 52 22 f0 40 	orl    $0x40,0xf0225228
		return 0;
f0100525:	bb 00 00 00 00       	mov    $0x0,%ebx
f010052a:	e9 c4 00 00 00       	jmp    f01005f3 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f010052f:	84 c0                	test   %al,%al
f0100531:	79 37                	jns    f010056a <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100533:	8b 0d 28 52 22 f0    	mov    0xf0225228,%ecx
f0100539:	89 cb                	mov    %ecx,%ebx
f010053b:	83 e3 40             	and    $0x40,%ebx
f010053e:	83 e0 7f             	and    $0x7f,%eax
f0100541:	85 db                	test   %ebx,%ebx
f0100543:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100546:	0f b6 d2             	movzbl %dl,%edx
f0100549:	0f b6 82 e0 6b 10 f0 	movzbl -0xfef9420(%edx),%eax
f0100550:	83 c8 40             	or     $0x40,%eax
f0100553:	0f b6 c0             	movzbl %al,%eax
f0100556:	f7 d0                	not    %eax
f0100558:	21 c1                	and    %eax,%ecx
f010055a:	89 0d 28 52 22 f0    	mov    %ecx,0xf0225228
		return 0;
f0100560:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100565:	e9 89 00 00 00       	jmp    f01005f3 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010056a:	8b 0d 28 52 22 f0    	mov    0xf0225228,%ecx
f0100570:	f6 c1 40             	test   $0x40,%cl
f0100573:	74 0e                	je     f0100583 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100575:	89 c2                	mov    %eax,%edx
f0100577:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010057d:	89 0d 28 52 22 f0    	mov    %ecx,0xf0225228
	}

	shift |= shiftcode[data];
f0100583:	0f b6 d2             	movzbl %dl,%edx
f0100586:	0f b6 82 e0 6b 10 f0 	movzbl -0xfef9420(%edx),%eax
f010058d:	0b 05 28 52 22 f0    	or     0xf0225228,%eax
	shift ^= togglecode[data];
f0100593:	0f b6 8a e0 6c 10 f0 	movzbl -0xfef9320(%edx),%ecx
f010059a:	31 c8                	xor    %ecx,%eax
f010059c:	a3 28 52 22 f0       	mov    %eax,0xf0225228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a1:	89 c1                	mov    %eax,%ecx
f01005a3:	83 e1 03             	and    $0x3,%ecx
f01005a6:	8b 0c 8d e0 6d 10 f0 	mov    -0xfef9220(,%ecx,4),%ecx
f01005ad:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005b1:	a8 08                	test   $0x8,%al
f01005b3:	74 19                	je     f01005ce <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01005b5:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005b8:	83 fa 19             	cmp    $0x19,%edx
f01005bb:	77 05                	ja     f01005c2 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01005bd:	83 eb 20             	sub    $0x20,%ebx
f01005c0:	eb 0c                	jmp    f01005ce <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01005c2:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01005c5:	8d 53 20             	lea    0x20(%ebx),%edx
f01005c8:	83 f9 19             	cmp    $0x19,%ecx
f01005cb:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005ce:	f7 d0                	not    %eax
f01005d0:	a8 06                	test   $0x6,%al
f01005d2:	75 1f                	jne    f01005f3 <kbd_proc_data+0xf8>
f01005d4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005da:	75 17                	jne    f01005f3 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01005dc:	c7 04 24 a2 6b 10 f0 	movl   $0xf0106ba2,(%esp)
f01005e3:	e8 f6 3f 00 00       	call   f01045de <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01005ed:	b8 03 00 00 00       	mov    $0x3,%eax
f01005f2:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005f3:	89 d8                	mov    %ebx,%eax
f01005f5:	83 c4 14             	add    $0x14,%esp
f01005f8:	5b                   	pop    %ebx
f01005f9:	5d                   	pop    %ebp
f01005fa:	c3                   	ret    

f01005fb <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100601:	80 3d 00 50 22 f0 00 	cmpb   $0x0,0xf0225000
f0100608:	74 0a                	je     f0100614 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010060a:	b8 be 02 10 f0       	mov    $0xf01002be,%eax
f010060f:	e8 c6 fc ff ff       	call   f01002da <cons_intr>
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
f0100619:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010061c:	b8 fb 04 10 f0       	mov    $0xf01004fb,%eax
f0100621:	e8 b4 fc ff ff       	call   f01002da <cons_intr>
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
f010062b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010062e:	e8 c8 ff ff ff       	call   f01005fb <serial_intr>
	kbd_intr();
f0100633:	e8 de ff ff ff       	call   f0100616 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100638:	8b 15 20 52 22 f0    	mov    0xf0225220,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010063e:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100643:	3b 15 24 52 22 f0    	cmp    0xf0225224,%edx
f0100649:	74 1e                	je     f0100669 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010064b:	0f b6 82 20 50 22 f0 	movzbl -0xfddafe0(%edx),%eax
f0100652:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100655:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010065b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100660:	0f 44 d1             	cmove  %ecx,%edx
f0100663:	89 15 20 52 22 f0    	mov    %edx,0xf0225220
		return c;
	}
	return 0;
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	57                   	push   %edi
f010066f:	56                   	push   %esi
f0100670:	53                   	push   %ebx
f0100671:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100674:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100682:	5a a5 
	if (*cp != 0xA55A) {
f0100684:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010068f:	74 11                	je     f01006a2 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100691:	c7 05 2c 52 22 f0 b4 	movl   $0x3b4,0xf022522c
f0100698:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006a0:	eb 16                	jmp    f01006b8 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006a2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006a9:	c7 05 2c 52 22 f0 d4 	movl   $0x3d4,0xf022522c
f01006b0:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b3:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006b8:	8b 0d 2c 52 22 f0    	mov    0xf022522c,%ecx
f01006be:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c3:	89 ca                	mov    %ecx,%edx
f01006c5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006c6:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c9:	89 da                	mov    %ebx,%edx
f01006cb:	ec                   	in     (%dx),%al
f01006cc:	0f b6 f8             	movzbl %al,%edi
f01006cf:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006d7:	89 ca                	mov    %ecx,%edx
f01006d9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006da:	89 da                	mov    %ebx,%edx
f01006dc:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006dd:	89 35 30 52 22 f0    	mov    %esi,0xf0225230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e3:	0f b6 d8             	movzbl %al,%ebx
f01006e6:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006e8:	66 89 3d 34 52 22 f0 	mov    %di,0xf0225234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01006ef:	e8 22 ff ff ff       	call   f0100616 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f4:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006fb:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100700:	89 04 24             	mov    %eax,(%esp)
f0100703:	e8 94 3d 00 00       	call   f010449c <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100708:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010070d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100712:	89 da                	mov    %ebx,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b2 fb                	mov    $0xfb,%dl
f0100717:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010071c:	ee                   	out    %al,(%dx)
f010071d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100722:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100727:	89 ca                	mov    %ecx,%edx
f0100729:	ee                   	out    %al,(%dx)
f010072a:	b2 f9                	mov    $0xf9,%dl
f010072c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100731:	ee                   	out    %al,(%dx)
f0100732:	b2 fb                	mov    $0xfb,%dl
f0100734:	b8 03 00 00 00       	mov    $0x3,%eax
f0100739:	ee                   	out    %al,(%dx)
f010073a:	b2 fc                	mov    $0xfc,%dl
f010073c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100741:	ee                   	out    %al,(%dx)
f0100742:	b2 f9                	mov    $0xf9,%dl
f0100744:	b8 01 00 00 00       	mov    $0x1,%eax
f0100749:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074a:	b2 fd                	mov    $0xfd,%dl
f010074c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010074d:	3c ff                	cmp    $0xff,%al
f010074f:	0f 95 c0             	setne  %al
f0100752:	89 c6                	mov    %eax,%esi
f0100754:	a2 00 50 22 f0       	mov    %al,0xf0225000
f0100759:	89 da                	mov    %ebx,%edx
f010075b:	ec                   	in     (%dx),%al
f010075c:	89 ca                	mov    %ecx,%edx
f010075e:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075f:	89 f0                	mov    %esi,%eax
f0100761:	84 c0                	test   %al,%al
f0100763:	75 0c                	jne    f0100771 <cons_init+0x106>
		cprintf("Serial port does not exist!\n");
f0100765:	c7 04 24 ae 6b 10 f0 	movl   $0xf0106bae,(%esp)
f010076c:	e8 6d 3e 00 00       	call   f01045de <cprintf>
}
f0100771:	83 c4 1c             	add    $0x1c,%esp
f0100774:	5b                   	pop    %ebx
f0100775:	5e                   	pop    %esi
f0100776:	5f                   	pop    %edi
f0100777:	5d                   	pop    %ebp
f0100778:	c3                   	ret    

f0100779 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010077f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100782:	e8 90 fb ff ff       	call   f0100317 <cons_putc>
}
f0100787:	c9                   	leave  
f0100788:	c3                   	ret    

f0100789 <getchar>:

int
getchar(void)
{
f0100789:	55                   	push   %ebp
f010078a:	89 e5                	mov    %esp,%ebp
f010078c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010078f:	e8 94 fe ff ff       	call   f0100628 <cons_getc>
f0100794:	85 c0                	test   %eax,%eax
f0100796:	74 f7                	je     f010078f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100798:	c9                   	leave  
f0100799:	c3                   	ret    

f010079a <iscons>:

int
iscons(int fdnum)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010079d:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a2:	5d                   	pop    %ebp
f01007a3:	c3                   	ret    
	...

f01007b0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b0:	55                   	push   %ebp
f01007b1:	89 e5                	mov    %esp,%ebp
f01007b3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b6:	c7 04 24 f0 6d 10 f0 	movl   $0xf0106df0,(%esp)
f01007bd:	e8 1c 3e 00 00       	call   f01045de <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007c9:	00 
f01007ca:	c7 04 24 7c 6f 10 f0 	movl   $0xf0106f7c,(%esp)
f01007d1:	e8 08 3e 00 00       	call   f01045de <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007dd:	00 
f01007de:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 a4 6f 10 f0 	movl   $0xf0106fa4,(%esp)
f01007ed:	e8 ec 3d 00 00       	call   f01045de <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f2:	c7 44 24 08 c5 6a 10 	movl   $0x106ac5,0x8(%esp)
f01007f9:	00 
f01007fa:	c7 44 24 04 c5 6a 10 	movl   $0xf0106ac5,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 c8 6f 10 f0 	movl   $0xf0106fc8,(%esp)
f0100809:	e8 d0 3d 00 00       	call   f01045de <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080e:	c7 44 24 08 6a 40 22 	movl   $0x22406a,0x8(%esp)
f0100815:	00 
f0100816:	c7 44 24 04 6a 40 22 	movl   $0xf022406a,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 ec 6f 10 f0 	movl   $0xf0106fec,(%esp)
f0100825:	e8 b4 3d 00 00       	call   f01045de <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082a:	c7 44 24 08 08 70 26 	movl   $0x267008,0x8(%esp)
f0100831:	00 
f0100832:	c7 44 24 04 08 70 26 	movl   $0xf0267008,0x4(%esp)
f0100839:	f0 
f010083a:	c7 04 24 10 70 10 f0 	movl   $0xf0107010,(%esp)
f0100841:	e8 98 3d 00 00       	call   f01045de <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100846:	b8 07 74 26 f0       	mov    $0xf0267407,%eax
f010084b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100850:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100855:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085b:	85 c0                	test   %eax,%eax
f010085d:	0f 48 c2             	cmovs  %edx,%eax
f0100860:	c1 f8 0a             	sar    $0xa,%eax
f0100863:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100867:	c7 04 24 34 70 10 f0 	movl   $0xf0107034,(%esp)
f010086e:	e8 6b 3d 00 00       	call   f01045de <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100873:	b8 00 00 00 00       	mov    $0x0,%eax
f0100878:	c9                   	leave  
f0100879:	c3                   	ret    

f010087a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010087a:	55                   	push   %ebp
f010087b:	89 e5                	mov    %esp,%ebp
f010087d:	53                   	push   %ebx
f010087e:	83 ec 14             	sub    $0x14,%esp
f0100881:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100886:	8b 83 e4 72 10 f0    	mov    -0xfef8d1c(%ebx),%eax
f010088c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100890:	8b 83 e0 72 10 f0    	mov    -0xfef8d20(%ebx),%eax
f0100896:	89 44 24 04          	mov    %eax,0x4(%esp)
f010089a:	c7 04 24 09 6e 10 f0 	movl   $0xf0106e09,(%esp)
f01008a1:	e8 38 3d 00 00       	call   f01045de <cprintf>
f01008a6:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008a9:	83 fb 48             	cmp    $0x48,%ebx
f01008ac:	75 d8                	jne    f0100886 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b3:	83 c4 14             	add    $0x14,%esp
f01008b6:	5b                   	pop    %ebx
f01008b7:	5d                   	pop    %ebp
f01008b8:	c3                   	ret    

f01008b9 <mon_changepermission>:
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
f01008b9:	55                   	push   %ebp
f01008ba:	89 e5                	mov    %esp,%ebp
f01008bc:	57                   	push   %edi
f01008bd:	56                   	push   %esi
f01008be:	53                   	push   %ebx
f01008bf:	83 ec 2c             	sub    $0x2c,%esp
f01008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f01008c5:	8b 55 08             	mov    0x8(%ebp),%edx
f01008c8:	83 ea 03             	sub    $0x3,%edx
		return -1;
f01008cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f01008d0:	83 fa 01             	cmp    $0x1,%edx
f01008d3:	0f 87 f8 01 00 00    	ja     f0100ad1 <mon_changepermission+0x218>
		return -1;

	extern pde_t *kern_pgdir;
	unsigned int num = strtol(argv[2], NULL, 16);
f01008d9:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01008e0:	00 
f01008e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01008e8:	00 
f01008e9:	8b 43 08             	mov    0x8(%ebx),%eax
f01008ec:	89 04 24             	mov    %eax,(%esp)
f01008ef:	e8 80 55 00 00       	call   f0105e74 <strtol>
f01008f4:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f01008f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01008f9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100901:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0100906:	89 04 24             	mov    %eax,(%esp)
f0100909:	e8 2f 10 00 00       	call   f010193d <page_lookup>
	if(!pageofva)
f010090e:	85 c0                	test   %eax,%eax
f0100910:	0f 84 b6 01 00 00    	je     f0100acc <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f0100916:	c7 44 24 04 12 6e 10 	movl   $0xf0106e12,0x4(%esp)
f010091d:	f0 
f010091e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100921:	89 04 24             	mov    %eax,(%esp)
f0100924:	e8 02 53 00 00       	call   f0105c2b <strcmp>
	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;

	unsigned int perm = 0;
f0100929:	bf 00 00 00 00       	mov    $0x0,%edi
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f010092e:	85 c0                	test   %eax,%eax
f0100930:	75 2e                	jne    f0100960 <mon_changepermission+0xa7>
		perm = strtol(argv[3], NULL, 16) | PTE_P;
f0100932:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100939:	00 
f010093a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100941:	00 
f0100942:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100945:	89 04 24             	mov    %eax,(%esp)
f0100948:	e8 27 55 00 00       	call   f0105e74 <strtol>
f010094d:	89 c7                	mov    %eax,%edi
f010094f:	83 cf 01             	or     $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f0100952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100955:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f010095b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010095e:	01 38                	add    %edi,(%eax)
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
f0100960:	c7 44 24 04 17 6e 10 	movl   $0xf0106e17,0x4(%esp)
f0100967:	f0 
f0100968:	8b 43 04             	mov    0x4(%ebx),%eax
f010096b:	89 04 24             	mov    %eax,(%esp)
f010096e:	e8 b8 52 00 00       	call   f0105c2b <strcmp>
f0100973:	85 c0                	test   %eax,%eax
f0100975:	75 14                	jne    f010098b <mon_changepermission+0xd2>
		perm = 1;
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f0100977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010097a:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f0100980:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100983:	83 00 01             	addl   $0x1,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
		perm = 1;
f0100986:	bf 01 00 00 00       	mov    $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// change
	if(strcmp(argv[1], "-change") == 0) {
f010098b:	c7 44 24 04 1e 6e 10 	movl   $0xf0106e1e,0x4(%esp)
f0100992:	f0 
f0100993:	8b 43 04             	mov    0x4(%ebx),%eax
f0100996:	89 04 24             	mov    %eax,(%esp)
f0100999:	e8 8d 52 00 00       	call   f0105c2b <strcmp>
f010099e:	85 c0                	test   %eax,%eax
f01009a0:	0f 85 0b 01 00 00    	jne    f0100ab1 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f01009a6:	c7 44 24 04 97 7f 10 	movl   $0xf0107f97,0x4(%esp)
f01009ad:	f0 
f01009ae:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009b1:	89 04 24             	mov    %eax,(%esp)
f01009b4:	e8 72 52 00 00       	call   f0105c2b <strcmp>
f01009b9:	85 c0                	test   %eax,%eax
f01009bb:	75 06                	jne    f01009c3 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f01009bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009c0:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f01009c3:	c7 44 24 04 a8 7f 10 	movl   $0xf0107fa8,0x4(%esp)
f01009ca:	f0 
f01009cb:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009ce:	89 04 24             	mov    %eax,(%esp)
f01009d1:	e8 55 52 00 00       	call   f0105c2b <strcmp>
f01009d6:	85 c0                	test   %eax,%eax
f01009d8:	75 06                	jne    f01009e0 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f01009da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009dd:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f01009e0:	c7 44 24 04 26 6e 10 	movl   $0xf0106e26,0x4(%esp)
f01009e7:	f0 
f01009e8:	8b 43 0c             	mov    0xc(%ebx),%eax
f01009eb:	89 04 24             	mov    %eax,(%esp)
f01009ee:	e8 38 52 00 00       	call   f0105c2b <strcmp>
f01009f3:	85 c0                	test   %eax,%eax
f01009f5:	75 06                	jne    f01009fd <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f01009f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009fa:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f01009fd:	c7 44 24 04 f9 7e 10 	movl   $0xf0107ef9,0x4(%esp)
f0100a04:	f0 
f0100a05:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a08:	89 04 24             	mov    %eax,(%esp)
f0100a0b:	e8 1b 52 00 00       	call   f0105c2b <strcmp>
f0100a10:	85 c0                	test   %eax,%eax
f0100a12:	75 06                	jne    f0100a1a <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f0100a14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a17:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f0100a1a:	c7 44 24 04 2e 6e 10 	movl   $0xf0106e2e,0x4(%esp)
f0100a21:	f0 
f0100a22:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a25:	89 04 24             	mov    %eax,(%esp)
f0100a28:	e8 fe 51 00 00       	call   f0105c2b <strcmp>
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	75 06                	jne    f0100a37 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f0100a31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a34:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f0100a37:	c7 44 24 04 36 6e 10 	movl   $0xf0106e36,0x4(%esp)
f0100a3e:	f0 
f0100a3f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a42:	89 04 24             	mov    %eax,(%esp)
f0100a45:	e8 e1 51 00 00       	call   f0105c2b <strcmp>
f0100a4a:	85 c0                	test   %eax,%eax
f0100a4c:	75 06                	jne    f0100a54 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f0100a4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a51:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f0100a54:	c7 44 24 04 3c 6e 10 	movl   $0xf0106e3c,0x4(%esp)
f0100a5b:	f0 
f0100a5c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a5f:	89 04 24             	mov    %eax,(%esp)
f0100a62:	e8 c4 51 00 00       	call   f0105c2b <strcmp>
f0100a67:	85 c0                	test   %eax,%eax
f0100a69:	75 06                	jne    f0100a71 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f0100a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a6e:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100a71:	c7 44 24 04 42 6e 10 	movl   $0xf0106e42,0x4(%esp)
f0100a78:	f0 
f0100a79:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a7c:	89 04 24             	mov    %eax,(%esp)
f0100a7f:	e8 a7 51 00 00       	call   f0105c2b <strcmp>
f0100a84:	85 c0                	test   %eax,%eax
f0100a86:	75 09                	jne    f0100a91 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100a88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8b:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100a91:	c7 44 24 04 49 6e 10 	movl   $0xf0106e49,0x4(%esp)
f0100a98:	f0 
f0100a99:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a9c:	89 04 24             	mov    %eax,(%esp)
f0100a9f:	e8 87 51 00 00       	call   f0105c2b <strcmp>
f0100aa4:	85 c0                	test   %eax,%eax
f0100aa6:	75 09                	jne    f0100ab1 <mon_changepermission+0x1f8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_G;
f0100aa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aab:	81 30 00 01 00 00    	xorl   $0x100,(%eax)
	}
	

	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
f0100ab1:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100ab5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ab9:	c7 04 24 4f 6e 10 f0 	movl   $0xf0106e4f,(%esp)
f0100ac0:	e8 19 3b 00 00       	call   f01045de <cprintf>
		num, perm);

	return 0;
f0100ac5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aca:	eb 05                	jmp    f0100ad1 <mon_changepermission+0x218>
	unsigned int num = strtol(argv[2], NULL, 16);

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;
f0100acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
		num, perm);

	return 0;
}
f0100ad1:	83 c4 2c             	add    $0x2c,%esp
f0100ad4:	5b                   	pop    %ebx
f0100ad5:	5e                   	pop    %esi
f0100ad6:	5f                   	pop    %edi
f0100ad7:	5d                   	pop    %ebp
f0100ad8:	c3                   	ret    

f0100ad9 <mon_showmappings>:
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
f0100ad9:	55                   	push   %ebp
f0100ada:	89 e5                	mov    %esp,%ebp
f0100adc:	57                   	push   %edi
f0100add:	56                   	push   %esi
f0100ade:	53                   	push   %ebx
f0100adf:	83 ec 2c             	sub    $0x2c,%esp
f0100ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
		return -1;
f0100ae5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
f0100aea:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100aee:	0f 85 a6 00 00 00    	jne    f0100b9a <mon_showmappings+0xc1>

	// Get the 2 arguments
	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
f0100af4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100afb:	00 
f0100afc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b03:	00 
f0100b04:	8b 46 04             	mov    0x4(%esi),%eax
f0100b07:	89 04 24             	mov    %eax,(%esp)
f0100b0a:	e8 65 53 00 00       	call   f0105e74 <strtol>
f0100b0f:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f0100b11:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b18:	00 
f0100b19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b20:	00 
f0100b21:	8b 46 08             	mov    0x8(%esi),%eax
f0100b24:	89 04 24             	mov    %eax,(%esp)
f0100b27:	e8 48 53 00 00       	call   f0105e74 <strtol>
f0100b2c:	89 c7                	mov    %eax,%edi
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100b2e:	b8 00 00 00 00       	mov    $0x0,%eax

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100b33:	39 fb                	cmp    %edi,%ebx
f0100b35:	77 63                	ja     f0100b9a <mon_showmappings+0xc1>
		unsigned int _pte;
		struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num[0], (pte_t **)(&_pte));
f0100b37:	8d 75 e4             	lea    -0x1c(%ebp),%esi
f0100b3a:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100b3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b42:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0100b47:	89 04 24             	mov    %eax,(%esp)
f0100b4a:	e8 ee 0d 00 00       	call   f010193d <page_lookup>

		if(!pageofva) {
f0100b4f:	85 c0                	test   %eax,%eax
f0100b51:	75 0e                	jne    f0100b61 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f0100b53:	c7 04 24 60 70 10 f0 	movl   $0xf0107060,(%esp)
f0100b5a:	e8 7f 3a 00 00       	call   f01045de <cprintf>
			continue;
f0100b5f:	eb 2a                	jmp    f0100b8b <mon_showmappings+0xb2>
		}
		pte_t pte = *((pte_t *)_pte);
f0100b61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b64:	8b 00                	mov    (%eax),%eax
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));
f0100b66:	89 c2                	mov    %eax,%edx
f0100b68:	81 e2 ff 0f 00 00    	and    $0xfff,%edx

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
f0100b6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b77:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b7f:	c7 04 24 88 70 10 f0 	movl   $0xf0107088,(%esp)
f0100b86:	e8 53 3a 00 00       	call   f01045de <cprintf>
f0100b8b:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100b91:	39 df                	cmp    %ebx,%edi
f0100b93:	73 a5                	jae    f0100b3a <mon_showmappings+0x61>
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100b95:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b9a:	83 c4 2c             	add    $0x2c,%esp
f0100b9d:	5b                   	pop    %ebx
f0100b9e:	5e                   	pop    %esi
f0100b9f:	5f                   	pop    %edi
f0100ba0:	5d                   	pop    %ebp
f0100ba1:	c3                   	ret    

f0100ba2 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100ba2:	55                   	push   %ebp
f0100ba3:	89 e5                	mov    %esp,%ebp
f0100ba5:	57                   	push   %edi
f0100ba6:	56                   	push   %esi
f0100ba7:	53                   	push   %ebx
f0100ba8:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100bae:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100bb0:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100bb2:	8b 43 04             	mov    0x4(%ebx),%eax
f0100bb5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f0100bbb:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bbe:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f0100bc4:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100bc7:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f0100bcd:	8b 43 10             	mov    0x10(%ebx),%eax
f0100bd0:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f0100bd6:	8b 43 14             	mov    0x14(%ebx),%eax
f0100bd9:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f0100bdf:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f0100be2:	c7 04 24 6b 6e 10 f0 	movl   $0xf0106e6b,(%esp)
f0100be9:	e8 f0 39 00 00       	call   f01045de <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100bee:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100bf3:	85 db                	test   %ebx,%ebx
f0100bf5:	0f 84 f5 00 00 00    	je     f0100cf0 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f0100bfb:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c01:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f0100c07:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100c0d:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100c13:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100c17:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100c1b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c23:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c2d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100c31:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c35:	c7 04 24 bc 70 10 f0 	movl   $0xf01070bc,(%esp)
f0100c3c:	e8 9d 39 00 00       	call   f01045de <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100c41:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c48:	89 1c 24             	mov    %ebx,(%esp)
f0100c4b:	e8 ea 43 00 00       	call   f010503a <debuginfo_eip>
f0100c50:	85 c0                	test   %eax,%eax
f0100c52:	0f 88 93 00 00 00    	js     f0100ceb <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100c58:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c5f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100c65:	89 04 24             	mov    %eax,(%esp)
f0100c68:	e8 fe 4e 00 00       	call   f0105b6b <strcpy>

		int eip_line = info.eip_line;
f0100c6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c70:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f0100c76:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c84:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f0100c87:	89 3c 24             	mov    %edi,(%esp)
f0100c8a:	e8 27 4f 00 00       	call   f0105bb6 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100c8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c92:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f0100c97:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100c9a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100c9e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100ca2:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100ca8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cac:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cb6:	c7 04 24 7d 6e 10 f0 	movl   $0xf0106e7d,(%esp)
f0100cbd:	e8 1c 39 00 00       	call   f01045de <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f0100cc2:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f0100cc4:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f0100cc7:	8b 46 08             	mov    0x8(%esi),%eax
f0100cca:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f0100cd0:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f0100cd3:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f0100cd6:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f0100cd9:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100cdc:	85 f6                	test   %esi,%esi
f0100cde:	0f 85 2f ff ff ff    	jne    f0100c13 <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100ce4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ce9:	eb 05                	jmp    f0100cf0 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f0100ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100cf0:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f0100cf6:	5b                   	pop    %ebx
f0100cf7:	5e                   	pop    %esi
f0100cf8:	5f                   	pop    %edi
f0100cf9:	5d                   	pop    %ebp
f0100cfa:	c3                   	ret    

f0100cfb <mon_dump>:
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100cfb:	55                   	push   %ebp
f0100cfc:	89 e5                	mov    %esp,%ebp
f0100cfe:	57                   	push   %edi
f0100cff:	56                   	push   %esi
f0100d00:	53                   	push   %ebx
f0100d01:	83 ec 3c             	sub    $0x3c,%esp
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
f0100d04:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d08:	0f 85 ea 02 00 00    	jne    f0100ff8 <mon_dump+0x2fd>
		return -1;
	
	unsigned int addr = strtol(argv[2], NULL, 16);
f0100d0e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d15:	00 
f0100d16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d1d:	00 
f0100d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d21:	8b 42 08             	mov    0x8(%edx),%eax
f0100d24:	89 04 24             	mov    %eax,(%esp)
f0100d27:	e8 48 51 00 00       	call   f0105e74 <strtol>
f0100d2c:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100d2e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d35:	00 
f0100d36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d3d:	00 
f0100d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d41:	8b 42 0c             	mov    0xc(%edx),%eax
f0100d44:	89 04 24             	mov    %eax,(%esp)
f0100d47:	e8 28 51 00 00       	call   f0105e74 <strtol>
f0100d4c:	89 45 d0             	mov    %eax,-0x30(%ebp)

	if(argv[1][1] == 'v') {
f0100d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d52:	8b 42 04             	mov    0x4(%edx),%eax
f0100d55:	80 78 01 76          	cmpb   $0x76,0x1(%eax)
f0100d59:	0f 85 af 00 00 00    	jne    f0100e0e <mon_dump+0x113>
		int i;
		for(i=0; i<len; i++) {
f0100d5f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100d63:	0f 84 a5 00 00 00    	je     f0100e0e <mon_dump+0x113>
f0100d69:	89 df                	mov    %ebx,%edi
f0100d6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d70:	be 00 00 00 00       	mov    $0x0,%esi
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100d75:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100d78:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100d7b:	a8 03                	test   $0x3,%al
f0100d7d:	75 10                	jne    f0100d8f <mon_dump+0x94>
				cprintf("Virtual Address 0x%08x: ", addr + i*4);
f0100d7f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d83:	c7 04 24 94 6e 10 f0 	movl   $0xf0106e94,(%esp)
f0100d8a:	e8 4f 38 00 00       	call   f01045de <cprintf>

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100d8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100d92:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d96:	89 f8                	mov    %edi,%eax
f0100d98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
f0100d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100da1:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0100da6:	89 04 24             	mov    %eax,(%esp)
f0100da9:	e8 8f 0b 00 00       	call   f010193d <page_lookup>
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
			if(_pte && (*(pte_t *)_pte&PTE_P))
f0100dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100db1:	85 c0                	test   %eax,%eax
f0100db3:	74 19                	je     f0100dce <mon_dump+0xd3>
f0100db5:	f6 00 01             	testb  $0x1,(%eax)
f0100db8:	74 14                	je     f0100dce <mon_dump+0xd3>
				cprintf("0x%08x ", *(uint32_t *)(addr + i*4));
f0100dba:	8b 07                	mov    (%edi),%eax
f0100dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dc0:	c7 04 24 ad 6e 10 f0 	movl   $0xf0106ead,(%esp)
f0100dc7:	e8 12 38 00 00       	call   f01045de <cprintf>
f0100dcc:	eb 0c                	jmp    f0100dda <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100dce:	c7 04 24 b5 6e 10 f0 	movl   $0xf0106eb5,(%esp)
f0100dd5:	e8 04 38 00 00       	call   f01045de <cprintf>
			if(i % 4 == 3)
f0100dda:	89 f0                	mov    %esi,%eax
f0100ddc:	c1 f8 1f             	sar    $0x1f,%eax
f0100ddf:	c1 e8 1e             	shr    $0x1e,%eax
f0100de2:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100de5:	83 e2 03             	and    $0x3,%edx
f0100de8:	29 c2                	sub    %eax,%edx
f0100dea:	83 fa 03             	cmp    $0x3,%edx
f0100ded:	75 0c                	jne    f0100dfb <mon_dump+0x100>
				cprintf("\n");
f0100def:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f0100df6:	e8 e3 37 00 00       	call   f01045de <cprintf>
	unsigned int addr = strtol(argv[2], NULL, 16);
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
f0100dfb:	83 c6 01             	add    $0x1,%esi
f0100dfe:	89 f0                	mov    %esi,%eax
f0100e00:	83 c7 04             	add    $0x4,%edi
f0100e03:	39 de                	cmp    %ebx,%esi
f0100e05:	0f 85 70 ff ff ff    	jne    f0100d7b <mon_dump+0x80>
f0100e0b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e11:	8b 50 04             	mov    0x4(%eax),%edx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e14:	b8 00 00 00 00       	mov    $0x0,%eax
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100e19:	80 7a 01 70          	cmpb   $0x70,0x1(%edx)
f0100e1d:	0f 85 e1 01 00 00    	jne    f0101004 <mon_dump+0x309>
		int i;
		for(i=0; i<len; i++) {
f0100e23:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100e27:	0f 84 d2 01 00 00    	je     f0100fff <mon_dump+0x304>
f0100e2d:	be 00 00 00 00       	mov    $0x0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e32:	bf 00 80 11 f0       	mov    $0xf0118000,%edi
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100e37:	89 fa                	mov    %edi,%edx
f0100e39:	f7 da                	neg    %edx
f0100e3b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100e3e:	a8 03                	test   $0x3,%al
f0100e40:	75 10                	jne    f0100e52 <mon_dump+0x157>
				cprintf("Physical Address 0x%08x: ", addr + i*4);
f0100e42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e46:	c7 04 24 bb 6e 10 f0 	movl   $0xf0106ebb,(%esp)
f0100e4d:	e8 8c 37 00 00       	call   f01045de <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100e52:	a1 f0 5e 22 f0       	mov    0xf0225ef0,%eax
f0100e57:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e5c:	77 20                	ja     f0100e7e <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e62:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100e69:	f0 
f0100e6a:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100e71:	00 
f0100e72:	c7 04 24 d5 6e 10 f0 	movl   $0xf0106ed5,(%esp)
f0100e79:	e8 c2 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e7e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100e84:	39 d3                	cmp    %edx,%ebx
f0100e86:	0f 82 83 00 00 00    	jb     f0100f0f <mon_dump+0x214>
f0100e8c:	8d 90 00 00 40 00    	lea    0x400000(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e92:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e98:	77 20                	ja     f0100eba <mon_dump+0x1bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e9a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e9e:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100ea5:	f0 
f0100ea6:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100ead:	00 
f0100eae:	c7 04 24 d5 6e 10 f0 	movl   $0xf0106ed5,(%esp)
f0100eb5:	e8 86 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100eba:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ec0:	39 d3                	cmp    %edx,%ebx
f0100ec2:	73 4b                	jae    f0100f0f <mon_dump+0x214>
				cprintf("0x%08x ", *(uint32_t *)(_addr - PADDR((void *)pages + UPAGES)));
f0100ec4:	2d 00 00 00 11       	sub    $0x11000000,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ec9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ece:	77 20                	ja     f0100ef0 <mon_dump+0x1f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ed0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ed4:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100edb:	f0 
f0100edc:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100ee3:	00 
f0100ee4:	c7 04 24 d5 6e 10 f0 	movl   $0xf0106ed5,(%esp)
f0100eeb:	e8 50 f1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ef0:	89 da                	mov    %ebx,%edx
f0100ef2:	29 c2                	sub    %eax,%edx
f0100ef4:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100efa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100efe:	c7 04 24 ad 6e 10 f0 	movl   $0xf0106ead,(%esp)
f0100f05:	e8 d4 36 00 00       	call   f01045de <cprintf>
f0100f0a:	e9 b0 00 00 00       	jmp    f0100fbf <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f0f:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100f15:	77 24                	ja     f0100f3b <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f17:	c7 44 24 0c 00 80 11 	movl   $0xf0118000,0xc(%esp)
f0100f1e:	f0 
f0100f1f:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100f26:	f0 
f0100f27:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f2e:	00 
f0100f2f:	c7 04 24 d5 6e 10 f0 	movl   $0xf0106ed5,(%esp)
f0100f36:	e8 05 f1 ff ff       	call   f0100040 <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100f3b:	81 fb 00 80 11 00    	cmp    $0x118000,%ebx
f0100f41:	72 50                	jb     f0100f93 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f43:	b8 00 00 12 f0       	mov    $0xf0120000,%eax
f0100f48:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f4d:	77 20                	ja     f0100f6f <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f53:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100f5a:	f0 
f0100f5b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100f62:	00 
f0100f63:	c7 04 24 d5 6e 10 f0 	movl   $0xf0106ed5,(%esp)
f0100f6a:	e8 d1 f0 ff ff       	call   f0100040 <_panic>
f0100f6f:	81 fb 00 00 12 00    	cmp    $0x120000,%ebx
f0100f75:	73 1c                	jae    f0100f93 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100f77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f7a:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100f81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f85:	c7 04 24 ad 6e 10 f0 	movl   $0xf0106ead,(%esp)
f0100f8c:	e8 4d 36 00 00       	call   f01045de <cprintf>
f0100f91:	eb 2c                	jmp    f0100fbf <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100f93:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100f99:	77 18                	ja     f0100fb3 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100f9b:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa5:	c7 04 24 ad 6e 10 f0 	movl   $0xf0106ead,(%esp)
f0100fac:	e8 2d 36 00 00       	call   f01045de <cprintf>
f0100fb1:	eb 0c                	jmp    f0100fbf <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100fb3:	c7 04 24 b5 6e 10 f0 	movl   $0xf0106eb5,(%esp)
f0100fba:	e8 1f 36 00 00       	call   f01045de <cprintf>
			if(i % 4 == 3)
f0100fbf:	89 f0                	mov    %esi,%eax
f0100fc1:	c1 f8 1f             	sar    $0x1f,%eax
f0100fc4:	c1 e8 1e             	shr    $0x1e,%eax
f0100fc7:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100fca:	83 e2 03             	and    $0x3,%edx
f0100fcd:	29 c2                	sub    %eax,%edx
f0100fcf:	83 fa 03             	cmp    $0x3,%edx
f0100fd2:	75 0c                	jne    f0100fe0 <mon_dump+0x2e5>
				cprintf("\n");
f0100fd4:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f0100fdb:	e8 fe 35 00 00       	call   f01045de <cprintf>
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
f0100fe0:	83 c6 01             	add    $0x1,%esi
f0100fe3:	89 f0                	mov    %esi,%eax
f0100fe5:	83 c3 04             	add    $0x4,%ebx
f0100fe8:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f0100feb:	0f 85 4d fe ff ff    	jne    f0100e3e <mon_dump+0x143>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100ff1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff6:	eb 0c                	jmp    f0101004 <mon_dump+0x309>
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
		return -1;
f0100ff8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ffd:	eb 05                	jmp    f0101004 <mon_dump+0x309>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100fff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101004:	83 c4 3c             	add    $0x3c,%esp
f0101007:	5b                   	pop    %ebx
f0101008:	5e                   	pop    %esi
f0101009:	5f                   	pop    %edi
f010100a:	5d                   	pop    %ebp
f010100b:	c3                   	ret    

f010100c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010100c:	55                   	push   %ebp
f010100d:	89 e5                	mov    %esp,%ebp
f010100f:	57                   	push   %edi
f0101010:	56                   	push   %esi
f0101011:	53                   	push   %ebx
f0101012:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;


	cprintf("Welcome to the JOS kernel monitor!\n");
f0101015:	c7 04 24 f0 70 10 f0 	movl   $0xf01070f0,(%esp)
f010101c:	e8 bd 35 00 00       	call   f01045de <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101021:	c7 04 24 14 71 10 f0 	movl   $0xf0107114,(%esp)
f0101028:	e8 b1 35 00 00       	call   f01045de <cprintf>

	if (tf != NULL)
f010102d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101031:	74 0b                	je     f010103e <monitor+0x32>
		print_trapframe(tf);
f0101033:	8b 45 08             	mov    0x8(%ebp),%eax
f0101036:	89 04 24             	mov    %eax,(%esp)
f0101039:	e8 87 37 00 00       	call   f01047c5 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f010103e:	c7 04 24 3c 71 10 f0 	movl   $0xf010713c,(%esp)
f0101045:	e8 94 35 00 00       	call   f01045de <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f010104a:	c7 04 24 70 71 10 f0 	movl   $0xf0107170,(%esp)
f0101051:	e8 88 35 00 00       	call   f01045de <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f0101056:	c7 04 24 e4 6e 10 f0 	movl   $0xf0106ee4,(%esp)
f010105d:	e8 ee 49 00 00       	call   f0105a50 <readline>
f0101062:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0101064:	85 c0                	test   %eax,%eax
f0101066:	74 ee                	je     f0101056 <monitor+0x4a>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0101068:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010106f:	be 00 00 00 00       	mov    $0x0,%esi
f0101074:	eb 06                	jmp    f010107c <monitor+0x70>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101076:	c6 03 00             	movb   $0x0,(%ebx)
f0101079:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010107c:	0f b6 03             	movzbl (%ebx),%eax
f010107f:	84 c0                	test   %al,%al
f0101081:	74 6a                	je     f01010ed <monitor+0xe1>
f0101083:	0f be c0             	movsbl %al,%eax
f0101086:	89 44 24 04          	mov    %eax,0x4(%esp)
f010108a:	c7 04 24 e8 6e 10 f0 	movl   $0xf0106ee8,(%esp)
f0101091:	e8 10 4c 00 00       	call   f0105ca6 <strchr>
f0101096:	85 c0                	test   %eax,%eax
f0101098:	75 dc                	jne    f0101076 <monitor+0x6a>
			*buf++ = 0;
		if (*buf == 0)
f010109a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010109d:	74 4e                	je     f01010ed <monitor+0xe1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010109f:	83 fe 0f             	cmp    $0xf,%esi
f01010a2:	75 16                	jne    f01010ba <monitor+0xae>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01010a4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01010ab:	00 
f01010ac:	c7 04 24 ed 6e 10 f0 	movl   $0xf0106eed,(%esp)
f01010b3:	e8 26 35 00 00       	call   f01045de <cprintf>
f01010b8:	eb 9c                	jmp    f0101056 <monitor+0x4a>
			return 0;
		}
		argv[argc++] = buf;
f01010ba:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01010be:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01010c1:	0f b6 03             	movzbl (%ebx),%eax
f01010c4:	84 c0                	test   %al,%al
f01010c6:	75 0c                	jne    f01010d4 <monitor+0xc8>
f01010c8:	eb b2                	jmp    f010107c <monitor+0x70>
			buf++;
f01010ca:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01010cd:	0f b6 03             	movzbl (%ebx),%eax
f01010d0:	84 c0                	test   %al,%al
f01010d2:	74 a8                	je     f010107c <monitor+0x70>
f01010d4:	0f be c0             	movsbl %al,%eax
f01010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010db:	c7 04 24 e8 6e 10 f0 	movl   $0xf0106ee8,(%esp)
f01010e2:	e8 bf 4b 00 00       	call   f0105ca6 <strchr>
f01010e7:	85 c0                	test   %eax,%eax
f01010e9:	74 df                	je     f01010ca <monitor+0xbe>
f01010eb:	eb 8f                	jmp    f010107c <monitor+0x70>
			buf++;
	}
	argv[argc] = 0;
f01010ed:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01010f4:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01010f5:	85 f6                	test   %esi,%esi
f01010f7:	0f 84 59 ff ff ff    	je     f0101056 <monitor+0x4a>
f01010fd:	bb e0 72 10 f0       	mov    $0xf01072e0,%ebx
f0101102:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101107:	8b 03                	mov    (%ebx),%eax
f0101109:	89 44 24 04          	mov    %eax,0x4(%esp)
f010110d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101110:	89 04 24             	mov    %eax,(%esp)
f0101113:	e8 13 4b 00 00       	call   f0105c2b <strcmp>
f0101118:	85 c0                	test   %eax,%eax
f010111a:	75 24                	jne    f0101140 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f010111c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010111f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101122:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101126:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101129:	89 54 24 04          	mov    %edx,0x4(%esp)
f010112d:	89 34 24             	mov    %esi,(%esp)
f0101130:	ff 14 85 e8 72 10 f0 	call   *-0xfef8d18(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0101137:	85 c0                	test   %eax,%eax
f0101139:	78 28                	js     f0101163 <monitor+0x157>
f010113b:	e9 16 ff ff ff       	jmp    f0101056 <monitor+0x4a>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0101140:	83 c7 01             	add    $0x1,%edi
f0101143:	83 c3 0c             	add    $0xc,%ebx
f0101146:	83 ff 06             	cmp    $0x6,%edi
f0101149:	75 bc                	jne    f0101107 <monitor+0xfb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010114b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010114e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101152:	c7 04 24 0a 6f 10 f0 	movl   $0xf0106f0a,(%esp)
f0101159:	e8 80 34 00 00       	call   f01045de <cprintf>
f010115e:	e9 f3 fe ff ff       	jmp    f0101056 <monitor+0x4a>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101163:	83 c4 5c             	add    $0x5c,%esp
f0101166:	5b                   	pop    %ebx
f0101167:	5e                   	pop    %esi
f0101168:	5f                   	pop    %edi
f0101169:	5d                   	pop    %ebp
f010116a:	c3                   	ret    
	...

f010116c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010116c:	55                   	push   %ebp
f010116d:	89 e5                	mov    %esp,%ebp
f010116f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101172:	89 d1                	mov    %edx,%ecx
f0101174:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0101177:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f010117a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010117f:	f6 c1 01             	test   $0x1,%cl
f0101182:	74 57                	je     f01011db <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101184:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010118a:	89 c8                	mov    %ecx,%eax
f010118c:	c1 e8 0c             	shr    $0xc,%eax
f010118f:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f0101195:	72 20                	jb     f01011b7 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101197:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010119b:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01011a2:	f0 
f01011a3:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01011aa:	00 
f01011ab:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01011b2:	e8 89 ee ff ff       	call   f0100040 <_panic>
	//cprintf("**%x\n", p);
	if (!(p[PTX(va)] & PTE_P))
f01011b7:	c1 ea 0c             	shr    $0xc,%edx
f01011ba:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01011c0:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f01011c7:	89 c2                	mov    %eax,%edx
f01011c9:	83 e2 01             	and    $0x1,%edx
		return ~0;
	//cprintf("**%x\n\n", p[PTX(va)]);
	return PTE_ADDR(p[PTX(va)]);
f01011cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011d1:	85 d2                	test   %edx,%edx
f01011d3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01011d8:	0f 44 c2             	cmove  %edx,%eax
}
f01011db:	c9                   	leave  
f01011dc:	c3                   	ret    

f01011dd <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01011dd:	55                   	push   %ebp
f01011de:	89 e5                	mov    %esp,%ebp
f01011e0:	83 ec 18             	sub    $0x18,%esp
f01011e3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01011e6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01011e9:	83 3d 3c 52 22 f0 00 	cmpl   $0x0,0xf022523c
f01011f0:	75 11                	jne    f0101203 <boot_alloc+0x26>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01011f2:	ba 07 80 26 f0       	mov    $0xf0268007,%edx
f01011f7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01011fd:	89 15 3c 52 22 f0    	mov    %edx,0xf022523c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f0101203:	83 3d 00 23 12 f0 ff 	cmpl   $0xffffffff,0xf0122300
f010120a:	75 0c                	jne    f0101218 <boot_alloc+0x3b>
		npages_left = npages;
f010120c:	8b 15 e8 5e 22 f0    	mov    0xf0225ee8,%edx
f0101212:	89 15 00 23 12 f0    	mov    %edx,0xf0122300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f0101218:	85 c0                	test   %eax,%eax
f010121a:	75 2c                	jne    f0101248 <boot_alloc+0x6b>
// !- Whether I should check here -!
		if(npages_left < 1) {
f010121c:	83 3d 00 23 12 f0 00 	cmpl   $0x0,0xf0122300
f0101223:	75 1c                	jne    f0101241 <boot_alloc+0x64>
			panic("Out of memory!\n");
f0101225:	c7 44 24 08 b1 7c 10 	movl   $0xf0107cb1,0x8(%esp)
f010122c:	f0 
f010122d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
f0101234:	00 
f0101235:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010123c:	e8 ff ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f0101241:	a1 3c 52 22 f0       	mov    0xf022523c,%eax
f0101246:	eb 5c                	jmp    f01012a4 <boot_alloc+0xc7>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f0101248:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f010124e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		cprintf("Request %u\n", srequest/PGSIZE);
f0101254:	89 f3                	mov    %esi,%ebx
f0101256:	c1 eb 0c             	shr    $0xc,%ebx
f0101259:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010125d:	c7 04 24 c1 7c 10 f0 	movl   $0xf0107cc1,(%esp)
f0101264:	e8 75 33 00 00       	call   f01045de <cprintf>

		if(npages_left < srequest/PGSIZE) {
f0101269:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f010126f:	39 d3                	cmp    %edx,%ebx
f0101271:	76 1c                	jbe    f010128f <boot_alloc+0xb2>
			panic("Out of memory!\n");
f0101273:	c7 44 24 08 b1 7c 10 	movl   $0xf0107cb1,0x8(%esp)
f010127a:	f0 
f010127b:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
f0101282:	00 
f0101283:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010128a:	e8 b1 ed ff ff       	call   f0100040 <_panic>
		}
		result = nextfree;
f010128f:	a1 3c 52 22 f0       	mov    0xf022523c,%eax
		nextfree += srequest;
f0101294:	01 c6                	add    %eax,%esi
f0101296:	89 35 3c 52 22 f0    	mov    %esi,0xf022523c
		npages_left -= srequest/PGSIZE;
f010129c:	29 da                	sub    %ebx,%edx
f010129e:	89 15 00 23 12 f0    	mov    %edx,0xf0122300

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
	//******************************My code ends***********************************//
}
f01012a4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01012a7:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01012aa:	89 ec                	mov    %ebp,%esp
f01012ac:	5d                   	pop    %ebp
f01012ad:	c3                   	ret    

f01012ae <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01012ae:	55                   	push   %ebp
f01012af:	89 e5                	mov    %esp,%ebp
f01012b1:	83 ec 18             	sub    $0x18,%esp
f01012b4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01012b7:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01012ba:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012bc:	89 04 24             	mov    %eax,(%esp)
f01012bf:	e8 b0 31 00 00       	call   f0104474 <mc146818_read>
f01012c4:	89 c6                	mov    %eax,%esi
f01012c6:	83 c3 01             	add    $0x1,%ebx
f01012c9:	89 1c 24             	mov    %ebx,(%esp)
f01012cc:	e8 a3 31 00 00       	call   f0104474 <mc146818_read>
f01012d1:	c1 e0 08             	shl    $0x8,%eax
f01012d4:	09 f0                	or     %esi,%eax
}
f01012d6:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01012d9:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01012dc:	89 ec                	mov    %ebp,%esp
f01012de:	5d                   	pop    %ebp
f01012df:	c3                   	ret    

f01012e0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01012e0:	55                   	push   %ebp
f01012e1:	89 e5                	mov    %esp,%ebp
f01012e3:	57                   	push   %edi
f01012e4:	56                   	push   %esi
f01012e5:	53                   	push   %ebx
f01012e6:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012e9:	3c 01                	cmp    $0x1,%al
f01012eb:	19 f6                	sbb    %esi,%esi
f01012ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01012f3:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01012f6:	8b 1d 40 52 22 f0    	mov    0xf0225240,%ebx
f01012fc:	85 db                	test   %ebx,%ebx
f01012fe:	75 1c                	jne    f010131c <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0101300:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0101307:	f0 
f0101308:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f010130f:	00 
f0101310:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101317:	e8 24 ed ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f010131c:	84 c0                	test   %al,%al
f010131e:	74 50                	je     f0101370 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101320:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101323:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101326:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101329:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010132c:	89 d8                	mov    %ebx,%eax
f010132e:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0101334:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101337:	c1 e8 16             	shr    $0x16,%eax
f010133a:	39 c6                	cmp    %eax,%esi
f010133c:	0f 96 c0             	setbe  %al
f010133f:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101342:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0101346:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101348:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010134c:	8b 1b                	mov    (%ebx),%ebx
f010134e:	85 db                	test   %ebx,%ebx
f0101350:	75 da                	jne    f010132c <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101352:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101355:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010135b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010135e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101361:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101363:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101366:	89 1d 40 52 22 f0    	mov    %ebx,0xf0225240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010136c:	85 db                	test   %ebx,%ebx
f010136e:	74 67                	je     f01013d7 <check_page_free_list+0xf7>
f0101370:	89 d8                	mov    %ebx,%eax
f0101372:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0101378:	c1 f8 03             	sar    $0x3,%eax
f010137b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010137e:	89 c2                	mov    %eax,%edx
f0101380:	c1 ea 16             	shr    $0x16,%edx
f0101383:	39 d6                	cmp    %edx,%esi
f0101385:	76 4a                	jbe    f01013d1 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101387:	89 c2                	mov    %eax,%edx
f0101389:	c1 ea 0c             	shr    $0xc,%edx
f010138c:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f0101392:	72 20                	jb     f01013b4 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101394:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101398:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010139f:	f0 
f01013a0:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01013a7:	00 
f01013a8:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f01013af:	e8 8c ec ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01013b4:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01013bb:	00 
f01013bc:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01013c3:	00 
	return (void *)(pa + KERNBASE);
f01013c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013c9:	89 04 24             	mov    %eax,(%esp)
f01013cc:	e8 30 49 00 00       	call   f0105d01 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013d1:	8b 1b                	mov    (%ebx),%ebx
f01013d3:	85 db                	test   %ebx,%ebx
f01013d5:	75 99                	jne    f0101370 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01013d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01013dc:	e8 fc fd ff ff       	call   f01011dd <boot_alloc>
f01013e1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013e4:	8b 15 40 52 22 f0    	mov    0xf0225240,%edx
f01013ea:	85 d2                	test   %edx,%edx
f01013ec:	0f 84 2f 02 00 00    	je     f0101621 <check_page_free_list+0x341>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01013f2:	8b 1d f0 5e 22 f0    	mov    0xf0225ef0,%ebx
f01013f8:	39 da                	cmp    %ebx,%edx
f01013fa:	72 51                	jb     f010144d <check_page_free_list+0x16d>
		assert(pp < pages + npages);
f01013fc:	a1 e8 5e 22 f0       	mov    0xf0225ee8,%eax
f0101401:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101404:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0101407:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010140a:	39 c2                	cmp    %eax,%edx
f010140c:	73 68                	jae    f0101476 <check_page_free_list+0x196>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010140e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101411:	89 d0                	mov    %edx,%eax
f0101413:	29 d8                	sub    %ebx,%eax
f0101415:	a8 07                	test   $0x7,%al
f0101417:	0f 85 86 00 00 00    	jne    f01014a3 <check_page_free_list+0x1c3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010141d:	c1 f8 03             	sar    $0x3,%eax
f0101420:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101423:	85 c0                	test   %eax,%eax
f0101425:	0f 84 a6 00 00 00    	je     f01014d1 <check_page_free_list+0x1f1>
		assert(page2pa(pp) != IOPHYSMEM);
f010142b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101430:	0f 84 c6 00 00 00    	je     f01014fc <check_page_free_list+0x21c>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101436:	be 00 00 00 00       	mov    $0x0,%esi
f010143b:	bf 00 00 00 00       	mov    $0x0,%edi
f0101440:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0101443:	e9 d8 00 00 00       	jmp    f0101520 <check_page_free_list+0x240>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101448:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f010144b:	73 24                	jae    f0101471 <check_page_free_list+0x191>
f010144d:	c7 44 24 0c db 7c 10 	movl   $0xf0107cdb,0xc(%esp)
f0101454:	f0 
f0101455:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010145c:	f0 
f010145d:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101464:	00 
f0101465:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010146c:	e8 cf eb ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101471:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101474:	72 24                	jb     f010149a <check_page_free_list+0x1ba>
f0101476:	c7 44 24 0c fc 7c 10 	movl   $0xf0107cfc,0xc(%esp)
f010147d:	f0 
f010147e:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101485:	f0 
f0101486:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010148d:	00 
f010148e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101495:	e8 a6 eb ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010149a:	89 d0                	mov    %edx,%eax
f010149c:	2b 45 cc             	sub    -0x34(%ebp),%eax
f010149f:	a8 07                	test   $0x7,%al
f01014a1:	74 24                	je     f01014c7 <check_page_free_list+0x1e7>
f01014a3:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f01014aa:	f0 
f01014ab:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01014b2:	f0 
f01014b3:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f01014ba:	00 
f01014bb:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01014c2:	e8 79 eb ff ff       	call   f0100040 <_panic>
f01014c7:	c1 f8 03             	sar    $0x3,%eax
f01014ca:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01014cd:	85 c0                	test   %eax,%eax
f01014cf:	75 24                	jne    f01014f5 <check_page_free_list+0x215>
f01014d1:	c7 44 24 0c 10 7d 10 	movl   $0xf0107d10,0xc(%esp)
f01014d8:	f0 
f01014d9:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01014e0:	f0 
f01014e1:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01014e8:	00 
f01014e9:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01014f0:	e8 4b eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01014f5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01014fa:	75 24                	jne    f0101520 <check_page_free_list+0x240>
f01014fc:	c7 44 24 0c 21 7d 10 	movl   $0xf0107d21,0xc(%esp)
f0101503:	f0 
f0101504:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010150b:	f0 
f010150c:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101513:	00 
f0101514:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010151b:	e8 20 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101520:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101525:	75 24                	jne    f010154b <check_page_free_list+0x26b>
f0101527:	c7 44 24 0c 80 73 10 	movl   $0xf0107380,0xc(%esp)
f010152e:	f0 
f010152f:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101536:	f0 
f0101537:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010153e:	00 
f010153f:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101546:	e8 f5 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010154b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101550:	75 24                	jne    f0101576 <check_page_free_list+0x296>
f0101552:	c7 44 24 0c 3a 7d 10 	movl   $0xf0107d3a,0xc(%esp)
f0101559:	f0 
f010155a:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101561:	f0 
f0101562:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101569:	00 
f010156a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101571:	e8 ca ea ff ff       	call   f0100040 <_panic>
f0101576:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101578:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010157d:	76 59                	jbe    f01015d8 <check_page_free_list+0x2f8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010157f:	89 c3                	mov    %eax,%ebx
f0101581:	c1 eb 0c             	shr    $0xc,%ebx
f0101584:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101587:	77 20                	ja     f01015a9 <check_page_free_list+0x2c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101589:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010158d:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0101594:	f0 
f0101595:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f010159c:	00 
f010159d:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f01015a4:	e8 97 ea ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01015a9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01015af:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01015b2:	76 24                	jbe    f01015d8 <check_page_free_list+0x2f8>
f01015b4:	c7 44 24 0c a4 73 10 	movl   $0xf01073a4,0xc(%esp)
f01015bb:	f0 
f01015bc:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01015c3:	f0 
f01015c4:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01015cb:	00 
f01015cc:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01015d3:	e8 68 ea ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01015d8:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01015dd:	75 24                	jne    f0101603 <check_page_free_list+0x323>
f01015df:	c7 44 24 0c 54 7d 10 	movl   $0xf0107d54,0xc(%esp)
f01015e6:	f0 
f01015e7:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01015ee:	f0 
f01015ef:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01015f6:	00 
f01015f7:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01015fe:	e8 3d ea ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0101603:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101609:	77 05                	ja     f0101610 <check_page_free_list+0x330>
			++nfree_basemem;
f010160b:	83 c7 01             	add    $0x1,%edi
f010160e:	eb 03                	jmp    f0101613 <check_page_free_list+0x333>
		else
			++nfree_extmem;
f0101610:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101613:	8b 12                	mov    (%edx),%edx
f0101615:	85 d2                	test   %edx,%edx
f0101617:	0f 85 2b fe ff ff    	jne    f0101448 <check_page_free_list+0x168>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010161d:	85 ff                	test   %edi,%edi
f010161f:	7f 24                	jg     f0101645 <check_page_free_list+0x365>
f0101621:	c7 44 24 0c 71 7d 10 	movl   $0xf0107d71,0xc(%esp)
f0101628:	f0 
f0101629:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101630:	f0 
f0101631:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101638:	00 
f0101639:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101640:	e8 fb e9 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101645:	85 f6                	test   %esi,%esi
f0101647:	7f 24                	jg     f010166d <check_page_free_list+0x38d>
f0101649:	c7 44 24 0c 83 7d 10 	movl   $0xf0107d83,0xc(%esp)
f0101650:	f0 
f0101651:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101658:	f0 
f0101659:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101660:	00 
f0101661:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101668:	e8 d3 e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f010166d:	c7 04 24 ec 73 10 f0 	movl   $0xf01073ec,(%esp)
f0101674:	e8 65 2f 00 00       	call   f01045de <cprintf>
}
f0101679:	83 c4 4c             	add    $0x4c,%esp
f010167c:	5b                   	pop    %ebx
f010167d:	5e                   	pop    %esi
f010167e:	5f                   	pop    %edi
f010167f:	5d                   	pop    %ebp
f0101680:	c3                   	ret    

f0101681 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101681:	55                   	push   %ebp
f0101682:	89 e5                	mov    %esp,%ebp
f0101684:	57                   	push   %edi
f0101685:	56                   	push   %esi
f0101686:	53                   	push   %ebx
f0101687:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f010168a:	83 3d e8 5e 22 f0 00 	cmpl   $0x0,0xf0225ee8
f0101691:	0f 85 a5 00 00 00    	jne    f010173c <page_init+0xbb>
f0101697:	e9 b2 00 00 00       	jmp    f010174e <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f010169c:	a1 f0 5e 22 f0       	mov    0xf0225ef0,%eax
f01016a1:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f01016a8:	8d 3c 30             	lea    (%eax,%esi,1),%edi
f01016ab:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f01016b1:	85 db                	test   %ebx,%ebx
f01016b3:	74 76                	je     f010172b <page_init+0xaa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016b5:	29 c7                	sub    %eax,%edi
f01016b7:	c1 ff 03             	sar    $0x3,%edi
f01016ba:	c1 e7 0c             	shl    $0xc,%edi
		// 4) Then extended memory [EXTPHYSMEM, ...).
		// extended memory: 0x100000~
		//   0x100000~0x115000 is allocated to kernel(0x115000 is the end of .bss segment)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		if(page2pa(&pages[i]) >= IOPHYSMEM
f01016bd:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f01016c3:	76 3f                	jbe    f0101704 <page_init+0x83>
			&& page2pa(&pages[i]) < ROUNDUP(PADDR(boot_alloc(0)), PGSIZE)) {	
f01016c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ca:	e8 0e fb ff ff       	call   f01011dd <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01016cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016d4:	77 20                	ja     f01016f6 <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016da:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01016e1:	f0 
f01016e2:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f01016e9:	00 
f01016ea:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01016f1:	e8 4a e9 ff ff       	call   f0100040 <_panic>
f01016f6:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f01016fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101700:	39 f8                	cmp    %edi,%eax
f0101702:	77 27                	ja     f010172b <page_init+0xaa>
			continue;	
		}
		
		if(page2pa(&pages[i]) == MPENTRY_PADDR)
f0101704:	8b 15 f0 5e 22 f0    	mov    0xf0225ef0,%edx
f010170a:	01 f2                	add    %esi,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010170c:	89 f0                	mov    %esi,%eax
f010170e:	c1 e0 09             	shl    $0x9,%eax
f0101711:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101716:	74 13                	je     f010172b <page_init+0xaa>
			continue;
		// others is free
		pages[i].pp_link = page_free_list;
f0101718:	a1 40 52 22 f0       	mov    0xf0225240,%eax
f010171d:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f010171f:	03 35 f0 5e 22 f0    	add    0xf0225ef0,%esi
f0101725:	89 35 40 52 22 f0    	mov    %esi,0xf0225240
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f010172b:	83 c3 01             	add    $0x1,%ebx
f010172e:	39 1d e8 5e 22 f0    	cmp    %ebx,0xf0225ee8
f0101734:	0f 87 62 ff ff ff    	ja     f010169c <page_init+0x1b>
f010173a:	eb 12                	jmp    f010174e <page_init+0xcd>
		
		pages[i].pp_ref = 0;
f010173c:	a1 f0 5e 22 f0       	mov    0xf0225ef0,%eax
f0101741:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101747:	bb 00 00 00 00       	mov    $0x0,%ebx
f010174c:	eb dd                	jmp    f010172b <page_init+0xaa>
			continue;
		// others is free
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f010174e:	83 c4 1c             	add    $0x1c,%esp
f0101751:	5b                   	pop    %ebx
f0101752:	5e                   	pop    %esi
f0101753:	5f                   	pop    %edi
f0101754:	5d                   	pop    %ebp
f0101755:	c3                   	ret    

f0101756 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101756:	55                   	push   %ebp
f0101757:	89 e5                	mov    %esp,%ebp
f0101759:	53                   	push   %ebx
f010175a:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in

	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	struct PageInfo *result = NULL;
	if(page_free_list) {
f010175d:	8b 1d 40 52 22 f0    	mov    0xf0225240,%ebx
f0101763:	85 db                	test   %ebx,%ebx
f0101765:	74 65                	je     f01017cc <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101767:	8b 03                	mov    (%ebx),%eax
f0101769:	a3 40 52 22 f0       	mov    %eax,0xf0225240
		
		if(alloc_flags & ALLOC_ZERO) { 
f010176e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101772:	74 58                	je     f01017cc <page_alloc+0x76>
f0101774:	89 d8                	mov    %ebx,%eax
f0101776:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f010177c:	c1 f8 03             	sar    $0x3,%eax
f010177f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101782:	89 c2                	mov    %eax,%edx
f0101784:	c1 ea 0c             	shr    $0xc,%edx
f0101787:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f010178d:	72 20                	jb     f01017af <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010178f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101793:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010179a:	f0 
f010179b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01017a2:	00 
f01017a3:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f01017aa:	e8 91 e8 ff ff       	call   f0100040 <_panic>
			// fill in '\0'
			memset(page2kva(result), 0, PGSIZE);
f01017af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017b6:	00 
f01017b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017be:	00 
	return (void *)(pa + KERNBASE);
f01017bf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017c4:	89 04 24             	mov    %eax,(%esp)
f01017c7:	e8 35 45 00 00       	call   f0105d01 <memset>
		}
	}
	return result;
}
f01017cc:	89 d8                	mov    %ebx,%eax
f01017ce:	83 c4 14             	add    $0x14,%esp
f01017d1:	5b                   	pop    %ebx
f01017d2:	5d                   	pop    %ebp
f01017d3:	c3                   	ret    

f01017d4 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01017d4:	55                   	push   %ebp
f01017d5:	89 e5                	mov    %esp,%ebp
f01017d7:	83 ec 18             	sub    $0x18,%esp
f01017da:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(!pp)
f01017dd:	85 c0                	test   %eax,%eax
f01017df:	75 1c                	jne    f01017fd <page_free+0x29>
		panic("page_free: invalid page to free!\n");
f01017e1:	c7 44 24 08 10 74 10 	movl   $0xf0107410,0x8(%esp)
f01017e8:	f0 
f01017e9:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
f01017f0:	00 
f01017f1:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01017f8:	e8 43 e8 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f01017fd:	8b 15 40 52 22 f0    	mov    0xf0225240,%edx
f0101803:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101805:	a3 40 52 22 f0       	mov    %eax,0xf0225240
}
f010180a:	c9                   	leave  
f010180b:	c3                   	ret    

f010180c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010180c:	55                   	push   %ebp
f010180d:	89 e5                	mov    %esp,%ebp
f010180f:	83 ec 18             	sub    $0x18,%esp
f0101812:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101815:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101819:	83 ea 01             	sub    $0x1,%edx
f010181c:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101820:	66 85 d2             	test   %dx,%dx
f0101823:	75 08                	jne    f010182d <page_decref+0x21>
		page_free(pp);
f0101825:	89 04 24             	mov    %eax,(%esp)
f0101828:	e8 a7 ff ff ff       	call   f01017d4 <page_free>
}
f010182d:	c9                   	leave  
f010182e:	c3                   	ret    

f010182f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010182f:	55                   	push   %ebp
f0101830:	89 e5                	mov    %esp,%ebp
f0101832:	56                   	push   %esi
f0101833:	53                   	push   %ebx
f0101834:	83 ec 10             	sub    $0x10,%esp
f0101837:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
f010183a:	89 f3                	mov    %esi,%ebx
f010183c:	c1 eb 16             	shr    $0x16,%ebx
	uintptr_t ptx = PTX(va);
	uintptr_t pgoff = PGOFF(va);

	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];
f010183f:	c1 e3 02             	shl    $0x2,%ebx
f0101842:	03 5d 08             	add    0x8(%ebp),%ebx

	if(((*pde) & PTE_P) == 0) {
f0101845:	f6 03 01             	testb  $0x1,(%ebx)
f0101848:	75 2c                	jne    f0101876 <pgdir_walk+0x47>
		if(create == 0) 
f010184a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010184e:	74 6c                	je     f01018bc <pgdir_walk+0x8d>
			return NULL;
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
f0101850:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101857:	e8 fa fe ff ff       	call   f0101756 <page_alloc>
			if(pgtbl == NULL)
f010185c:	85 c0                	test   %eax,%eax
f010185e:	74 63                	je     f01018c3 <pgdir_walk+0x94>
				return NULL;
			else {
				pgtbl->pp_ref ++;
f0101860:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101865:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f010186b:	c1 f8 03             	sar    $0x3,%eax
f010186e:	c1 e0 0c             	shl    $0xc,%eax
				/* store in physical address*/
				*pde = page2pa(pgtbl) | PTE_U | PTE_W | PTE_P;
f0101871:	83 c8 07             	or     $0x7,%eax
f0101874:	89 03                	mov    %eax,(%ebx)
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f0101876:	8b 03                	mov    (%ebx),%eax
f0101878:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010187d:	89 c2                	mov    %eax,%edx
f010187f:	c1 ea 0c             	shr    $0xc,%edx
f0101882:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f0101888:	72 20                	jb     f01018aa <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010188a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010188e:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0101895:	f0 
f0101896:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
f010189d:	00 
f010189e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01018a5:	e8 96 e7 ff ff       	call   f0100040 <_panic>
{
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
	uintptr_t ptx = PTX(va);
f01018aa:	c1 ee 0a             	shr    $0xa,%esi
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01018ad:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01018b3:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return pte;
f01018ba:	eb 0c                	jmp    f01018c8 <pgdir_walk+0x99>
	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];

	if(((*pde) & PTE_P) == 0) {
		if(create == 0) 
			return NULL;
f01018bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01018c1:	eb 05                	jmp    f01018c8 <pgdir_walk+0x99>
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
			if(pgtbl == NULL)
				return NULL;
f01018c3:	b8 00 00 00 00       	mov    $0x0,%eax
	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;

	return pte;
}
f01018c8:	83 c4 10             	add    $0x10,%esp
f01018cb:	5b                   	pop    %ebx
f01018cc:	5e                   	pop    %esi
f01018cd:	5d                   	pop    %ebp
f01018ce:	c3                   	ret    

f01018cf <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01018cf:	55                   	push   %ebp
f01018d0:	89 e5                	mov    %esp,%ebp
f01018d2:	57                   	push   %edi
f01018d3:	56                   	push   %esi
f01018d4:	53                   	push   %ebx
f01018d5:	83 ec 2c             	sub    $0x2c,%esp
f01018d8:	89 c7                	mov    %eax,%edi
f01018da:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01018dd:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01018e3:	c1 e9 0c             	shr    $0xc,%ecx
f01018e6:	85 c9                	test   %ecx,%ecx
f01018e8:	74 4b                	je     f0101935 <boot_map_region+0x66>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01018ea:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01018ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f01018f2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f01018fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018fe:	83 c8 01             	or     $0x1,%eax
f0101901:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f0101904:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010190b:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f010190c:	89 d8                	mov    %ebx,%eax
f010190e:	c1 e0 0c             	shl    $0xc,%eax

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f0101911:	03 45 e0             	add    -0x20(%ebp),%eax
f0101914:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101918:	89 3c 24             	mov    %edi,(%esp)
f010191b:	e8 0f ff ff ff       	call   f010182f <pgdir_walk>
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f0101920:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101923:	09 f2                	or     %esi,%edx
f0101925:	89 10                	mov    %edx,(%eax)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101927:	83 c3 01             	add    $0x1,%ebx
f010192a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101930:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101933:	75 cf                	jne    f0101904 <boot_map_region+0x35>
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
	}
}
f0101935:	83 c4 2c             	add    $0x2c,%esp
f0101938:	5b                   	pop    %ebx
f0101939:	5e                   	pop    %esi
f010193a:	5f                   	pop    %edi
f010193b:	5d                   	pop    %ebp
f010193c:	c3                   	ret    

f010193d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010193d:	55                   	push   %ebp
f010193e:	89 e5                	mov    %esp,%ebp
f0101940:	53                   	push   %ebx
f0101941:	83 ec 14             	sub    $0x14,%esp
f0101944:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
f0101947:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010194e:	00 
f010194f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101952:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101956:	8b 45 08             	mov    0x8(%ebp),%eax
f0101959:	89 04 24             	mov    %eax,(%esp)
f010195c:	e8 ce fe ff ff       	call   f010182f <pgdir_walk>
	struct PageInfo *pg = NULL;
	// Check if the pte_store is zero
	if(pte_store != 0)
f0101961:	85 db                	test   %ebx,%ebx
f0101963:	74 02                	je     f0101967 <page_lookup+0x2a>
		*pte_store = pte;
f0101965:	89 03                	mov    %eax,(%ebx)

	// Check if the page is mapped
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
f0101967:	85 c0                	test   %eax,%eax
f0101969:	74 38                	je     f01019a3 <page_lookup+0x66>
f010196b:	8b 00                	mov    (%eax),%eax
f010196d:	a8 01                	test   $0x1,%al
f010196f:	74 39                	je     f01019aa <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101971:	c1 e8 0c             	shr    $0xc,%eax
f0101974:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f010197a:	72 1c                	jb     f0101998 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010197c:	c7 44 24 08 34 74 10 	movl   $0xf0107434,0x8(%esp)
f0101983:	f0 
f0101984:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010198b:	00 
f010198c:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0101993:	e8 a8 e6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101998:	c1 e0 03             	shl    $0x3,%eax
f010199b:	03 05 f0 5e 22 f0    	add    0xf0225ef0,%eax
f01019a1:	eb 0c                	jmp    f01019af <page_lookup+0x72>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
	struct PageInfo *pg = NULL;
f01019a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01019a8:	eb 05                	jmp    f01019af <page_lookup+0x72>
f01019aa:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
		pg = pa2page(PTE_ADDR(*pte));
	}

	return pg;
}
f01019af:	83 c4 14             	add    $0x14,%esp
f01019b2:	5b                   	pop    %ebx
f01019b3:	5d                   	pop    %ebp
f01019b4:	c3                   	ret    

f01019b5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01019b5:	55                   	push   %ebp
f01019b6:	89 e5                	mov    %esp,%ebp
f01019b8:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01019bb:	e8 d0 49 00 00       	call   f0106390 <cpunum>
f01019c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01019c3:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f01019ca:	74 16                	je     f01019e2 <tlb_invalidate+0x2d>
f01019cc:	e8 bf 49 00 00       	call   f0106390 <cpunum>
f01019d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01019d4:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01019da:	8b 55 08             	mov    0x8(%ebp),%edx
f01019dd:	39 50 60             	cmp    %edx,0x60(%eax)
f01019e0:	75 06                	jne    f01019e8 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01019e2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019e5:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01019e8:	c9                   	leave  
f01019e9:	c3                   	ret    

f01019ea <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01019ea:	55                   	push   %ebp
f01019eb:	89 e5                	mov    %esp,%ebp
f01019ed:	83 ec 28             	sub    $0x28,%esp
f01019f0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01019f3:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01019f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01019f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;

	// look up the pte for the va
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01019fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01019ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a07:	89 34 24             	mov    %esi,(%esp)
f0101a0a:	e8 2e ff ff ff       	call   f010193d <page_lookup>

	if(pg != NULL) {
f0101a0f:	85 c0                	test   %eax,%eax
f0101a11:	74 1d                	je     f0101a30 <page_remove+0x46>
		// Decrease the count and free
		page_decref(pg);
f0101a13:	89 04 24             	mov    %eax,(%esp)
f0101a16:	e8 f1 fd ff ff       	call   f010180c <page_decref>
		// Set the pte to zero
		*pte = 0;
f0101a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		// The TLB must be invalidated if a page was formerly present at 'va'.
		tlb_invalidate(pgdir, va);
f0101a24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a28:	89 34 24             	mov    %esi,(%esp)
f0101a2b:	e8 85 ff ff ff       	call   f01019b5 <tlb_invalidate>
	}
}
f0101a30:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101a33:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101a36:	89 ec                	mov    %ebp,%esp
f0101a38:	5d                   	pop    %ebp
f0101a39:	c3                   	ret    

f0101a3a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101a3a:	55                   	push   %ebp
f0101a3b:	89 e5                	mov    %esp,%ebp
f0101a3d:	83 ec 28             	sub    $0x28,%esp
f0101a40:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101a43:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101a46:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101a49:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a4c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
f0101a4f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101a56:	00 
f0101a57:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a5e:	89 04 24             	mov    %eax,(%esp)
f0101a61:	e8 c9 fd ff ff       	call   f010182f <pgdir_walk>
f0101a66:	89 c3                	mov    %eax,%ebx
	if(pte == NULL) 
f0101a68:	85 c0                	test   %eax,%eax
f0101a6a:	74 66                	je     f0101ad2 <page_insert+0x98>
		return -E_NO_MEM;
	// If there is already a page mapped at 'va', it should be page_remove()d.
	if(((*pte) & PTE_P) == 1) {
f0101a6c:	8b 00                	mov    (%eax),%eax
f0101a6e:	a8 01                	test   $0x1,%al
f0101a70:	74 3c                	je     f0101aae <page_insert+0x74>
		//On one hand, the mapped page is pp;
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f0101a72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a77:	89 f2                	mov    %esi,%edx
f0101a79:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f0101a7f:	c1 fa 03             	sar    $0x3,%edx
f0101a82:	c1 e2 0c             	shl    $0xc,%edx
f0101a85:	39 d0                	cmp    %edx,%eax
f0101a87:	75 16                	jne    f0101a9f <page_insert+0x65>
			// The TLB must be invalidated if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f0101a89:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a90:	89 04 24             	mov    %eax,(%esp)
f0101a93:	e8 1d ff ff ff       	call   f01019b5 <tlb_invalidate>
			// The reference for the same page should not change(latter add one)
			pp->pp_ref --;
f0101a98:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101a9d:	eb 0f                	jmp    f0101aae <page_insert+0x74>
		}
		//On the other hand, the mapped page is not pp;
		else
			page_remove(pgdir, va);
f0101a9f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aa6:	89 04 24             	mov    %eax,(%esp)
f0101aa9:	e8 3c ff ff ff       	call   f01019ea <page_remove>
	}

	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
f0101aae:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ab1:	83 c8 01             	or     $0x1,%eax
f0101ab4:	89 f2                	mov    %esi,%edx
f0101ab6:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f0101abc:	c1 fa 03             	sar    $0x3,%edx
f0101abf:	c1 e2 0c             	shl    $0xc,%edx
f0101ac2:	09 d0                	or     %edx,%eax
f0101ac4:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref ++;
f0101ac6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	
	return 0;
f0101acb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ad0:	eb 05                	jmp    f0101ad7 <page_insert+0x9d>
{
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
	if(pte == NULL) 
		return -E_NO_MEM;
f0101ad2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref ++;
	
	return 0;
}
f0101ad7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101ada:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101add:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101ae0:	89 ec                	mov    %ebp,%esp
f0101ae2:	5d                   	pop    %ebp
f0101ae3:	c3                   	ret    

f0101ae4 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101ae4:	55                   	push   %ebp
f0101ae5:	89 e5                	mov    %esp,%ebp
f0101ae7:	53                   	push   %ebx
f0101ae8:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	if(base + ROUNDUP(size, PGSIZE) >= MMIOLIM)
f0101aeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101aee:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101af4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101afa:	8b 15 04 23 12 f0    	mov    0xf0122304,%edx
f0101b00:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101b03:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101b08:	76 1c                	jbe    f0101b26 <mmio_map_region+0x42>
		panic("mmio_map_region: above MMIOLIM");
f0101b0a:	c7 44 24 08 54 74 10 	movl   $0xf0107454,0x8(%esp)
f0101b11:	f0 
f0101b12:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101b19:	00 
f0101b1a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101b21:	e8 1a e5 ff ff       	call   f0100040 <_panic>
	boot_map_region(
f0101b26:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101b2d:	00 
f0101b2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b31:	89 04 24             	mov    %eax,(%esp)
f0101b34:	89 d9                	mov    %ebx,%ecx
f0101b36:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0101b3b:	e8 8f fd ff ff       	call   f01018cf <boot_map_region>
		base, 
		ROUNDUP(size, PGSIZE), 
		pa,
		PTE_PCD|PTE_PWT|PTE_W);

	void *ret = (void *)base;
f0101b40:	a1 04 23 12 f0       	mov    0xf0122304,%eax

	base += ROUNDUP(size, PGSIZE);
f0101b45:	01 c3                	add    %eax,%ebx
f0101b47:	89 1d 04 23 12 f0    	mov    %ebx,0xf0122304

	return ret;
}
f0101b4d:	83 c4 14             	add    $0x14,%esp
f0101b50:	5b                   	pop    %ebx
f0101b51:	5d                   	pop    %ebp
f0101b52:	c3                   	ret    

f0101b53 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101b53:	55                   	push   %ebp
f0101b54:	89 e5                	mov    %esp,%ebp
f0101b56:	57                   	push   %edi
f0101b57:	56                   	push   %esi
f0101b58:	53                   	push   %ebx
f0101b59:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101b5c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101b61:	e8 48 f7 ff ff       	call   f01012ae <nvram_read>
f0101b66:	c1 e0 0a             	shl    $0xa,%eax
f0101b69:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101b6f:	85 c0                	test   %eax,%eax
f0101b71:	0f 48 c2             	cmovs  %edx,%eax
f0101b74:	c1 f8 0c             	sar    $0xc,%eax
f0101b77:	a3 38 52 22 f0       	mov    %eax,0xf0225238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101b7c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101b81:	e8 28 f7 ff ff       	call   f01012ae <nvram_read>
f0101b86:	c1 e0 0a             	shl    $0xa,%eax
f0101b89:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101b8f:	85 c0                	test   %eax,%eax
f0101b91:	0f 48 c2             	cmovs  %edx,%eax
f0101b94:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101b97:	85 c0                	test   %eax,%eax
f0101b99:	74 0e                	je     f0101ba9 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101b9b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101ba1:	89 15 e8 5e 22 f0    	mov    %edx,0xf0225ee8
f0101ba7:	eb 0c                	jmp    f0101bb5 <mem_init+0x62>
	else
		npages = npages_basemem;
f0101ba9:	8b 15 38 52 22 f0    	mov    0xf0225238,%edx
f0101baf:	89 15 e8 5e 22 f0    	mov    %edx,0xf0225ee8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101bb5:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bb8:	c1 e8 0a             	shr    $0xa,%eax
f0101bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101bbf:	a1 38 52 22 f0       	mov    0xf0225238,%eax
f0101bc4:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bc7:	c1 e8 0a             	shr    $0xa,%eax
f0101bca:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101bce:	a1 e8 5e 22 f0       	mov    0xf0225ee8,%eax
f0101bd3:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bd6:	c1 e8 0a             	shr    $0xa,%eax
f0101bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bdd:	c7 04 24 74 74 10 f0 	movl   $0xf0107474,(%esp)
f0101be4:	e8 f5 29 00 00       	call   f01045de <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101be9:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101bee:	e8 ea f5 ff ff       	call   f01011dd <boot_alloc>
f0101bf3:	a3 ec 5e 22 f0       	mov    %eax,0xf0225eec
	memset(kern_pgdir, 0, PGSIZE);
f0101bf8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bff:	00 
f0101c00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c07:	00 
f0101c08:	89 04 24             	mov    %eax,(%esp)
f0101c0b:	e8 f1 40 00 00       	call   f0105d01 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c10:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101c15:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c1a:	77 20                	ja     f0101c3c <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101c1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c20:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0101c27:	f0 
f0101c28:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
f0101c2f:	00 
f0101c30:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101c37:	e8 04 e4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101c3c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c42:	83 ca 05             	or     $0x5,%edx
f0101c45:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f0101c4b:	a1 e8 5e 22 f0       	mov    0xf0225ee8,%eax
f0101c50:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101c53:	e8 85 f5 ff ff       	call   f01011dd <boot_alloc>
f0101c58:	a3 f0 5e 22 f0       	mov    %eax,0xf0225ef0
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101c5d:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101c62:	e8 76 f5 ff ff       	call   f01011dd <boot_alloc>
f0101c67:	a3 48 52 22 f0       	mov    %eax,0xf0225248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101c6c:	e8 10 fa ff ff       	call   f0101681 <page_init>

	check_page_free_list(1);
f0101c71:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c76:	e8 65 f6 ff ff       	call   f01012e0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101c7b:	83 3d f0 5e 22 f0 00 	cmpl   $0x0,0xf0225ef0
f0101c82:	75 1c                	jne    f0101ca0 <mem_init+0x14d>
		panic("'pages' is a null pointer!");
f0101c84:	c7 44 24 08 94 7d 10 	movl   $0xf0107d94,0x8(%esp)
f0101c8b:	f0 
f0101c8c:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0101c93:	00 
f0101c94:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101c9b:	e8 a0 e3 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101ca0:	a1 40 52 22 f0       	mov    0xf0225240,%eax
f0101ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101caa:	85 c0                	test   %eax,%eax
f0101cac:	74 09                	je     f0101cb7 <mem_init+0x164>
		++nfree;
f0101cae:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cb1:	8b 00                	mov    (%eax),%eax
f0101cb3:	85 c0                	test   %eax,%eax
f0101cb5:	75 f7                	jne    f0101cae <mem_init+0x15b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101cb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cbe:	e8 93 fa ff ff       	call   f0101756 <page_alloc>
f0101cc3:	89 c6                	mov    %eax,%esi
f0101cc5:	85 c0                	test   %eax,%eax
f0101cc7:	75 24                	jne    f0101ced <mem_init+0x19a>
f0101cc9:	c7 44 24 0c af 7d 10 	movl   $0xf0107daf,0xc(%esp)
f0101cd0:	f0 
f0101cd1:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101cd8:	f0 
f0101cd9:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101ce0:	00 
f0101ce1:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101ce8:	e8 53 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ced:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cf4:	e8 5d fa ff ff       	call   f0101756 <page_alloc>
f0101cf9:	89 c7                	mov    %eax,%edi
f0101cfb:	85 c0                	test   %eax,%eax
f0101cfd:	75 24                	jne    f0101d23 <mem_init+0x1d0>
f0101cff:	c7 44 24 0c c5 7d 10 	movl   $0xf0107dc5,0xc(%esp)
f0101d06:	f0 
f0101d07:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101d0e:	f0 
f0101d0f:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101d16:	00 
f0101d17:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101d1e:	e8 1d e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d2a:	e8 27 fa ff ff       	call   f0101756 <page_alloc>
f0101d2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d32:	85 c0                	test   %eax,%eax
f0101d34:	75 24                	jne    f0101d5a <mem_init+0x207>
f0101d36:	c7 44 24 0c db 7d 10 	movl   $0xf0107ddb,0xc(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101d4d:	00 
f0101d4e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101d55:	e8 e6 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d5a:	39 fe                	cmp    %edi,%esi
f0101d5c:	75 24                	jne    f0101d82 <mem_init+0x22f>
f0101d5e:	c7 44 24 0c f1 7d 10 	movl   $0xf0107df1,0xc(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101d75:	00 
f0101d76:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101d7d:	e8 be e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d82:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d85:	74 05                	je     f0101d8c <mem_init+0x239>
f0101d87:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d8a:	75 24                	jne    f0101db0 <mem_init+0x25d>
f0101d8c:	c7 44 24 0c b0 74 10 	movl   $0xf01074b0,0xc(%esp)
f0101d93:	f0 
f0101d94:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101d9b:	f0 
f0101d9c:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101da3:	00 
f0101da4:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101dab:	e8 90 e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101db0:	8b 15 f0 5e 22 f0    	mov    0xf0225ef0,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101db6:	a1 e8 5e 22 f0       	mov    0xf0225ee8,%eax
f0101dbb:	c1 e0 0c             	shl    $0xc,%eax
f0101dbe:	89 f1                	mov    %esi,%ecx
f0101dc0:	29 d1                	sub    %edx,%ecx
f0101dc2:	c1 f9 03             	sar    $0x3,%ecx
f0101dc5:	c1 e1 0c             	shl    $0xc,%ecx
f0101dc8:	39 c1                	cmp    %eax,%ecx
f0101dca:	72 24                	jb     f0101df0 <mem_init+0x29d>
f0101dcc:	c7 44 24 0c 03 7e 10 	movl   $0xf0107e03,0xc(%esp)
f0101dd3:	f0 
f0101dd4:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101ddb:	f0 
f0101ddc:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101de3:	00 
f0101de4:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101deb:	e8 50 e2 ff ff       	call   f0100040 <_panic>
f0101df0:	89 f9                	mov    %edi,%ecx
f0101df2:	29 d1                	sub    %edx,%ecx
f0101df4:	c1 f9 03             	sar    $0x3,%ecx
f0101df7:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101dfa:	39 c8                	cmp    %ecx,%eax
f0101dfc:	77 24                	ja     f0101e22 <mem_init+0x2cf>
f0101dfe:	c7 44 24 0c 20 7e 10 	movl   $0xf0107e20,0xc(%esp)
f0101e05:	f0 
f0101e06:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101e0d:	f0 
f0101e0e:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101e15:	00 
f0101e16:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101e1d:	e8 1e e2 ff ff       	call   f0100040 <_panic>
f0101e22:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e25:	29 d1                	sub    %edx,%ecx
f0101e27:	89 ca                	mov    %ecx,%edx
f0101e29:	c1 fa 03             	sar    $0x3,%edx
f0101e2c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e2f:	39 d0                	cmp    %edx,%eax
f0101e31:	77 24                	ja     f0101e57 <mem_init+0x304>
f0101e33:	c7 44 24 0c 3d 7e 10 	movl   $0xf0107e3d,0xc(%esp)
f0101e3a:	f0 
f0101e3b:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101e42:	f0 
f0101e43:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101e4a:	00 
f0101e4b:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101e52:	e8 e9 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e57:	a1 40 52 22 f0       	mov    0xf0225240,%eax
f0101e5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101e5f:	c7 05 40 52 22 f0 00 	movl   $0x0,0xf0225240
f0101e66:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e70:	e8 e1 f8 ff ff       	call   f0101756 <page_alloc>
f0101e75:	85 c0                	test   %eax,%eax
f0101e77:	74 24                	je     f0101e9d <mem_init+0x34a>
f0101e79:	c7 44 24 0c 5a 7e 10 	movl   $0xf0107e5a,0xc(%esp)
f0101e80:	f0 
f0101e81:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101e88:	f0 
f0101e89:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101e90:	00 
f0101e91:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101e98:	e8 a3 e1 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101e9d:	89 34 24             	mov    %esi,(%esp)
f0101ea0:	e8 2f f9 ff ff       	call   f01017d4 <page_free>
	page_free(pp1);
f0101ea5:	89 3c 24             	mov    %edi,(%esp)
f0101ea8:	e8 27 f9 ff ff       	call   f01017d4 <page_free>
	page_free(pp2);
f0101ead:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb0:	89 04 24             	mov    %eax,(%esp)
f0101eb3:	e8 1c f9 ff ff       	call   f01017d4 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101eb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ebf:	e8 92 f8 ff ff       	call   f0101756 <page_alloc>
f0101ec4:	89 c6                	mov    %eax,%esi
f0101ec6:	85 c0                	test   %eax,%eax
f0101ec8:	75 24                	jne    f0101eee <mem_init+0x39b>
f0101eca:	c7 44 24 0c af 7d 10 	movl   $0xf0107daf,0xc(%esp)
f0101ed1:	f0 
f0101ed2:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101ed9:	f0 
f0101eda:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101ee1:	00 
f0101ee2:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101ee9:	e8 52 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101eee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ef5:	e8 5c f8 ff ff       	call   f0101756 <page_alloc>
f0101efa:	89 c7                	mov    %eax,%edi
f0101efc:	85 c0                	test   %eax,%eax
f0101efe:	75 24                	jne    f0101f24 <mem_init+0x3d1>
f0101f00:	c7 44 24 0c c5 7d 10 	movl   $0xf0107dc5,0xc(%esp)
f0101f07:	f0 
f0101f08:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101f0f:	f0 
f0101f10:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101f17:	00 
f0101f18:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101f1f:	e8 1c e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2b:	e8 26 f8 ff ff       	call   f0101756 <page_alloc>
f0101f30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f33:	85 c0                	test   %eax,%eax
f0101f35:	75 24                	jne    f0101f5b <mem_init+0x408>
f0101f37:	c7 44 24 0c db 7d 10 	movl   $0xf0107ddb,0xc(%esp)
f0101f3e:	f0 
f0101f3f:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101f46:	f0 
f0101f47:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101f4e:	00 
f0101f4f:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101f56:	e8 e5 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f5b:	39 fe                	cmp    %edi,%esi
f0101f5d:	75 24                	jne    f0101f83 <mem_init+0x430>
f0101f5f:	c7 44 24 0c f1 7d 10 	movl   $0xf0107df1,0xc(%esp)
f0101f66:	f0 
f0101f67:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0101f76:	00 
f0101f77:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f83:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101f86:	74 05                	je     f0101f8d <mem_init+0x43a>
f0101f88:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101f8b:	75 24                	jne    f0101fb1 <mem_init+0x45e>
f0101f8d:	c7 44 24 0c b0 74 10 	movl   $0xf01074b0,0xc(%esp)
f0101f94:	f0 
f0101f95:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101f9c:	f0 
f0101f9d:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101fa4:	00 
f0101fa5:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101fac:	e8 8f e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fb8:	e8 99 f7 ff ff       	call   f0101756 <page_alloc>
f0101fbd:	85 c0                	test   %eax,%eax
f0101fbf:	74 24                	je     f0101fe5 <mem_init+0x492>
f0101fc1:	c7 44 24 0c 5a 7e 10 	movl   $0xf0107e5a,0xc(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0101fd0:	f0 
f0101fd1:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101fd8:	00 
f0101fd9:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0101fe0:	e8 5b e0 ff ff       	call   f0100040 <_panic>
f0101fe5:	89 f0                	mov    %esi,%eax
f0101fe7:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0101fed:	c1 f8 03             	sar    $0x3,%eax
f0101ff0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ff3:	89 c2                	mov    %eax,%edx
f0101ff5:	c1 ea 0c             	shr    $0xc,%edx
f0101ff8:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f0101ffe:	72 20                	jb     f0102020 <mem_init+0x4cd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102000:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102004:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010200b:	f0 
f010200c:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102013:	00 
f0102014:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f010201b:	e8 20 e0 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102020:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102027:	00 
f0102028:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010202f:	00 
	return (void *)(pa + KERNBASE);
f0102030:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102035:	89 04 24             	mov    %eax,(%esp)
f0102038:	e8 c4 3c 00 00       	call   f0105d01 <memset>
	page_free(pp0);
f010203d:	89 34 24             	mov    %esi,(%esp)
f0102040:	e8 8f f7 ff ff       	call   f01017d4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102045:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010204c:	e8 05 f7 ff ff       	call   f0101756 <page_alloc>
f0102051:	85 c0                	test   %eax,%eax
f0102053:	75 24                	jne    f0102079 <mem_init+0x526>
f0102055:	c7 44 24 0c 69 7e 10 	movl   $0xf0107e69,0xc(%esp)
f010205c:	f0 
f010205d:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102064:	f0 
f0102065:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f010206c:	00 
f010206d:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102074:	e8 c7 df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0102079:	39 c6                	cmp    %eax,%esi
f010207b:	74 24                	je     f01020a1 <mem_init+0x54e>
f010207d:	c7 44 24 0c 87 7e 10 	movl   $0xf0107e87,0xc(%esp)
f0102084:	f0 
f0102085:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010208c:	f0 
f010208d:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102094:	00 
f0102095:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010209c:	e8 9f df ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020a1:	89 f2                	mov    %esi,%edx
f01020a3:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f01020a9:	c1 fa 03             	sar    $0x3,%edx
f01020ac:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020af:	89 d0                	mov    %edx,%eax
f01020b1:	c1 e8 0c             	shr    $0xc,%eax
f01020b4:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f01020ba:	72 20                	jb     f01020dc <mem_init+0x589>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01020c0:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01020c7:	f0 
f01020c8:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f01020cf:	00 
f01020d0:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f01020d7:	e8 64 df ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01020dc:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01020e3:	75 11                	jne    f01020f6 <mem_init+0x5a3>
f01020e5:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01020eb:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01020f1:	80 38 00             	cmpb   $0x0,(%eax)
f01020f4:	74 24                	je     f010211a <mem_init+0x5c7>
f01020f6:	c7 44 24 0c 97 7e 10 	movl   $0xf0107e97,0xc(%esp)
f01020fd:	f0 
f01020fe:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102105:	f0 
f0102106:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f010210d:	00 
f010210e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102115:	e8 26 df ff ff       	call   f0100040 <_panic>
f010211a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010211d:	39 d0                	cmp    %edx,%eax
f010211f:	75 d0                	jne    f01020f1 <mem_init+0x59e>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102121:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102124:	89 15 40 52 22 f0    	mov    %edx,0xf0225240

	// free the pages we took
	page_free(pp0);
f010212a:	89 34 24             	mov    %esi,(%esp)
f010212d:	e8 a2 f6 ff ff       	call   f01017d4 <page_free>
	page_free(pp1);
f0102132:	89 3c 24             	mov    %edi,(%esp)
f0102135:	e8 9a f6 ff ff       	call   f01017d4 <page_free>
	page_free(pp2);
f010213a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010213d:	89 04 24             	mov    %eax,(%esp)
f0102140:	e8 8f f6 ff ff       	call   f01017d4 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102145:	a1 40 52 22 f0       	mov    0xf0225240,%eax
f010214a:	85 c0                	test   %eax,%eax
f010214c:	74 09                	je     f0102157 <mem_init+0x604>
		--nfree;
f010214e:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102151:	8b 00                	mov    (%eax),%eax
f0102153:	85 c0                	test   %eax,%eax
f0102155:	75 f7                	jne    f010214e <mem_init+0x5fb>
		--nfree;
	assert(nfree == 0);
f0102157:	85 db                	test   %ebx,%ebx
f0102159:	74 24                	je     f010217f <mem_init+0x62c>
f010215b:	c7 44 24 0c a1 7e 10 	movl   $0xf0107ea1,0xc(%esp)
f0102162:	f0 
f0102163:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010216a:	f0 
f010216b:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102172:	00 
f0102173:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010217a:	e8 c1 de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010217f:	c7 04 24 d0 74 10 f0 	movl   $0xf01074d0,(%esp)
f0102186:	e8 53 24 00 00       	call   f01045de <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010218b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102192:	e8 bf f5 ff ff       	call   f0101756 <page_alloc>
f0102197:	89 c6                	mov    %eax,%esi
f0102199:	85 c0                	test   %eax,%eax
f010219b:	75 24                	jne    f01021c1 <mem_init+0x66e>
f010219d:	c7 44 24 0c af 7d 10 	movl   $0xf0107daf,0xc(%esp)
f01021a4:	f0 
f01021a5:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01021ac:	f0 
f01021ad:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01021b4:	00 
f01021b5:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01021bc:	e8 7f de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021c8:	e8 89 f5 ff ff       	call   f0101756 <page_alloc>
f01021cd:	89 c7                	mov    %eax,%edi
f01021cf:	85 c0                	test   %eax,%eax
f01021d1:	75 24                	jne    f01021f7 <mem_init+0x6a4>
f01021d3:	c7 44 24 0c c5 7d 10 	movl   $0xf0107dc5,0xc(%esp)
f01021da:	f0 
f01021db:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01021f2:	e8 49 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021fe:	e8 53 f5 ff ff       	call   f0101756 <page_alloc>
f0102203:	89 c3                	mov    %eax,%ebx
f0102205:	85 c0                	test   %eax,%eax
f0102207:	75 24                	jne    f010222d <mem_init+0x6da>
f0102209:	c7 44 24 0c db 7d 10 	movl   $0xf0107ddb,0xc(%esp)
f0102210:	f0 
f0102211:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102218:	f0 
f0102219:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102220:	00 
f0102221:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102228:	e8 13 de ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010222d:	39 fe                	cmp    %edi,%esi
f010222f:	75 24                	jne    f0102255 <mem_init+0x702>
f0102231:	c7 44 24 0c f1 7d 10 	movl   $0xf0107df1,0xc(%esp)
f0102238:	f0 
f0102239:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102240:	f0 
f0102241:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102248:	00 
f0102249:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102250:	e8 eb dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102255:	39 c7                	cmp    %eax,%edi
f0102257:	74 04                	je     f010225d <mem_init+0x70a>
f0102259:	39 c6                	cmp    %eax,%esi
f010225b:	75 24                	jne    f0102281 <mem_init+0x72e>
f010225d:	c7 44 24 0c b0 74 10 	movl   $0xf01074b0,0xc(%esp)
f0102264:	f0 
f0102265:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010226c:	f0 
f010226d:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0102274:	00 
f0102275:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010227c:	e8 bf dd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102281:	8b 15 40 52 22 f0    	mov    0xf0225240,%edx
f0102287:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010228a:	c7 05 40 52 22 f0 00 	movl   $0x0,0xf0225240
f0102291:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102294:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010229b:	e8 b6 f4 ff ff       	call   f0101756 <page_alloc>
f01022a0:	85 c0                	test   %eax,%eax
f01022a2:	74 24                	je     f01022c8 <mem_init+0x775>
f01022a4:	c7 44 24 0c 5a 7e 10 	movl   $0xf0107e5a,0xc(%esp)
f01022ab:	f0 
f01022ac:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01022b3:	f0 
f01022b4:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01022bb:	00 
f01022bc:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01022c3:	e8 78 dd ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022d6:	00 
f01022d7:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01022dc:	89 04 24             	mov    %eax,(%esp)
f01022df:	e8 59 f6 ff ff       	call   f010193d <page_lookup>
f01022e4:	85 c0                	test   %eax,%eax
f01022e6:	74 24                	je     f010230c <mem_init+0x7b9>
f01022e8:	c7 44 24 0c f0 74 10 	movl   $0xf01074f0,0xc(%esp)
f01022ef:	f0 
f01022f0:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01022f7:	f0 
f01022f8:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01022ff:	00 
f0102300:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102307:	e8 34 dd ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010230c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102313:	00 
f0102314:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010231b:	00 
f010231c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102320:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102325:	89 04 24             	mov    %eax,(%esp)
f0102328:	e8 0d f7 ff ff       	call   f0101a3a <page_insert>
f010232d:	85 c0                	test   %eax,%eax
f010232f:	78 24                	js     f0102355 <mem_init+0x802>
f0102331:	c7 44 24 0c 28 75 10 	movl   $0xf0107528,0xc(%esp)
f0102338:	f0 
f0102339:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102340:	f0 
f0102341:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f0102348:	00 
f0102349:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102350:	e8 eb dc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102355:	89 34 24             	mov    %esi,(%esp)
f0102358:	e8 77 f4 ff ff       	call   f01017d4 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010235d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102364:	00 
f0102365:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010236c:	00 
f010236d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102371:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102376:	89 04 24             	mov    %eax,(%esp)
f0102379:	e8 bc f6 ff ff       	call   f0101a3a <page_insert>
f010237e:	85 c0                	test   %eax,%eax
f0102380:	74 24                	je     f01023a6 <mem_init+0x853>
f0102382:	c7 44 24 0c 58 75 10 	movl   $0xf0107558,0xc(%esp)
f0102389:	f0 
f010238a:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102391:	f0 
f0102392:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102399:	00 
f010239a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01023a1:	e8 9a dc ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023a6:	8b 0d ec 5e 22 f0    	mov    0xf0225eec,%ecx
f01023ac:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023af:	a1 f0 5e 22 f0       	mov    0xf0225ef0,%eax
f01023b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023b7:	8b 11                	mov    (%ecx),%edx
f01023b9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023bf:	89 f0                	mov    %esi,%eax
f01023c1:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01023c4:	c1 f8 03             	sar    $0x3,%eax
f01023c7:	c1 e0 0c             	shl    $0xc,%eax
f01023ca:	39 c2                	cmp    %eax,%edx
f01023cc:	74 24                	je     f01023f2 <mem_init+0x89f>
f01023ce:	c7 44 24 0c 88 75 10 	movl   $0xf0107588,0xc(%esp)
f01023d5:	f0 
f01023d6:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01023dd:	f0 
f01023de:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f01023e5:	00 
f01023e6:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01023ed:	e8 4e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01023f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023fa:	e8 6d ed ff ff       	call   f010116c <check_va2pa>
f01023ff:	89 fa                	mov    %edi,%edx
f0102401:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0102404:	c1 fa 03             	sar    $0x3,%edx
f0102407:	c1 e2 0c             	shl    $0xc,%edx
f010240a:	39 d0                	cmp    %edx,%eax
f010240c:	74 24                	je     f0102432 <mem_init+0x8df>
f010240e:	c7 44 24 0c b0 75 10 	movl   $0xf01075b0,0xc(%esp)
f0102415:	f0 
f0102416:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010241d:	f0 
f010241e:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0102425:	00 
f0102426:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010242d:	e8 0e dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102432:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102437:	74 24                	je     f010245d <mem_init+0x90a>
f0102439:	c7 44 24 0c ac 7e 10 	movl   $0xf0107eac,0xc(%esp)
f0102440:	f0 
f0102441:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102448:	f0 
f0102449:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0102450:	00 
f0102451:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102458:	e8 e3 db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010245d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102462:	74 24                	je     f0102488 <mem_init+0x935>
f0102464:	c7 44 24 0c bd 7e 10 	movl   $0xf0107ebd,0xc(%esp)
f010246b:	f0 
f010246c:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102473:	f0 
f0102474:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f010247b:	00 
f010247c:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102483:	e8 b8 db ff ff       	call   f0100040 <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102488:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010248f:	00 
f0102490:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102497:	00 
f0102498:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010249c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010249f:	89 14 24             	mov    %edx,(%esp)
f01024a2:	e8 93 f5 ff ff       	call   f0101a3a <page_insert>
f01024a7:	85 c0                	test   %eax,%eax
f01024a9:	74 24                	je     f01024cf <mem_init+0x97c>
f01024ab:	c7 44 24 0c e0 75 10 	movl   $0xf01075e0,0xc(%esp)
f01024b2:	f0 
f01024b3:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01024ba:	f0 
f01024bb:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f01024c2:	00 
f01024c3:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01024ca:	e8 71 db ff ff       	call   f0100040 <_panic>
cprintf("%x %x %x\n",kern_pgdir, PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
f01024cf:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01024d4:	89 f2                	mov    %esi,%edx
f01024d6:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f01024dc:	c1 fa 03             	sar    $0x3,%edx
f01024df:	c1 e2 0c             	shl    $0xc,%edx
f01024e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024e6:	8b 10                	mov    (%eax),%edx
f01024e8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024ee:	89 54 24 08          	mov    %edx,0x8(%esp)
f01024f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01024f6:	c7 04 24 ce 7e 10 f0 	movl   $0xf0107ece,(%esp)
f01024fd:	e8 dc 20 00 00       	call   f01045de <cprintf>
f0102502:	89 d8                	mov    %ebx,%eax
f0102504:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f010250a:	c1 f8 03             	sar    $0x3,%eax
f010250d:	c1 e0 0c             	shl    $0xc,%eax

cprintf("%x %x\n", PTE_ADDR(*((pte_t *)(PTE_ADDR(kern_pgdir[0]) + PTX(PGSIZE)))), page2pa(pp2));
f0102510:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102514:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102519:	8b 00                	mov    (%eax),%eax
f010251b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102520:	8b 40 01             	mov    0x1(%eax),%eax
f0102523:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102528:	89 44 24 04          	mov    %eax,0x4(%esp)
f010252c:	c7 04 24 d1 7e 10 f0 	movl   $0xf0107ed1,(%esp)
f0102533:	e8 a6 20 00 00       	call   f01045de <cprintf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102538:	ba 00 10 00 00       	mov    $0x1000,%edx
f010253d:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102542:	e8 25 ec ff ff       	call   f010116c <check_va2pa>
f0102547:	89 da                	mov    %ebx,%edx
f0102549:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f010254f:	c1 fa 03             	sar    $0x3,%edx
f0102552:	c1 e2 0c             	shl    $0xc,%edx
f0102555:	39 d0                	cmp    %edx,%eax
f0102557:	74 24                	je     f010257d <mem_init+0xa2a>
f0102559:	c7 44 24 0c 1c 76 10 	movl   $0xf010761c,0xc(%esp)
f0102560:	f0 
f0102561:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102568:	f0 
f0102569:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102570:	00 
f0102571:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102578:	e8 c3 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010257d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102582:	74 24                	je     f01025a8 <mem_init+0xa55>
f0102584:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f010258b:	f0 
f010258c:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102593:	f0 
f0102594:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f010259b:	00 
f010259c:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01025a3:	e8 98 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01025a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025af:	e8 a2 f1 ff ff       	call   f0101756 <page_alloc>
f01025b4:	85 c0                	test   %eax,%eax
f01025b6:	74 24                	je     f01025dc <mem_init+0xa89>
f01025b8:	c7 44 24 0c 5a 7e 10 	movl   $0xf0107e5a,0xc(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01025c7:	f0 
f01025c8:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01025cf:	00 
f01025d0:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01025d7:	e8 64 da ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025dc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025e3:	00 
f01025e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025eb:	00 
f01025ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025f0:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01025f5:	89 04 24             	mov    %eax,(%esp)
f01025f8:	e8 3d f4 ff ff       	call   f0101a3a <page_insert>
f01025fd:	85 c0                	test   %eax,%eax
f01025ff:	74 24                	je     f0102625 <mem_init+0xad2>
f0102601:	c7 44 24 0c e0 75 10 	movl   $0xf01075e0,0xc(%esp)
f0102608:	f0 
f0102609:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102610:	f0 
f0102611:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102618:	00 
f0102619:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102620:	e8 1b da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102625:	ba 00 10 00 00       	mov    $0x1000,%edx
f010262a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f010262f:	e8 38 eb ff ff       	call   f010116c <check_va2pa>
f0102634:	89 da                	mov    %ebx,%edx
f0102636:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f010263c:	c1 fa 03             	sar    $0x3,%edx
f010263f:	c1 e2 0c             	shl    $0xc,%edx
f0102642:	39 d0                	cmp    %edx,%eax
f0102644:	74 24                	je     f010266a <mem_init+0xb17>
f0102646:	c7 44 24 0c 1c 76 10 	movl   $0xf010761c,0xc(%esp)
f010264d:	f0 
f010264e:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102655:	f0 
f0102656:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f010265d:	00 
f010265e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102665:	e8 d6 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010266a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010266f:	74 24                	je     f0102695 <mem_init+0xb42>
f0102671:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f0102678:	f0 
f0102679:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102680:	f0 
f0102681:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102688:	00 
f0102689:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102690:	e8 ab d9 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102695:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010269c:	e8 b5 f0 ff ff       	call   f0101756 <page_alloc>
f01026a1:	85 c0                	test   %eax,%eax
f01026a3:	74 24                	je     f01026c9 <mem_init+0xb76>
f01026a5:	c7 44 24 0c 5a 7e 10 	movl   $0xf0107e5a,0xc(%esp)
f01026ac:	f0 
f01026ad:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01026b4:	f0 
f01026b5:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f01026bc:	00 
f01026bd:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01026c4:	e8 77 d9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01026c9:	8b 15 ec 5e 22 f0    	mov    0xf0225eec,%edx
f01026cf:	8b 02                	mov    (%edx),%eax
f01026d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026d6:	89 c1                	mov    %eax,%ecx
f01026d8:	c1 e9 0c             	shr    $0xc,%ecx
f01026db:	3b 0d e8 5e 22 f0    	cmp    0xf0225ee8,%ecx
f01026e1:	72 20                	jb     f0102703 <mem_init+0xbb0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026e7:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01026ee:	f0 
f01026ef:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01026f6:	00 
f01026f7:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01026fe:	e8 3d d9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102703:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010270b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102712:	00 
f0102713:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010271a:	00 
f010271b:	89 14 24             	mov    %edx,(%esp)
f010271e:	e8 0c f1 ff ff       	call   f010182f <pgdir_walk>
f0102723:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102726:	83 c2 04             	add    $0x4,%edx
f0102729:	39 d0                	cmp    %edx,%eax
f010272b:	74 24                	je     f0102751 <mem_init+0xbfe>
f010272d:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f0102734:	f0 
f0102735:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010273c:	f0 
f010273d:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0102744:	00 
f0102745:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010274c:	e8 ef d8 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102751:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102758:	00 
f0102759:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102760:	00 
f0102761:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102765:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f010276a:	89 04 24             	mov    %eax,(%esp)
f010276d:	e8 c8 f2 ff ff       	call   f0101a3a <page_insert>
f0102772:	85 c0                	test   %eax,%eax
f0102774:	74 24                	je     f010279a <mem_init+0xc47>
f0102776:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f010277d:	f0 
f010277e:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102785:	f0 
f0102786:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f010278d:	00 
f010278e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102795:	e8 a6 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010279a:	8b 0d ec 5e 22 f0    	mov    0xf0225eec,%ecx
f01027a0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01027a3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027a8:	89 c8                	mov    %ecx,%eax
f01027aa:	e8 bd e9 ff ff       	call   f010116c <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027af:	89 da                	mov    %ebx,%edx
f01027b1:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f01027b7:	c1 fa 03             	sar    $0x3,%edx
f01027ba:	c1 e2 0c             	shl    $0xc,%edx
f01027bd:	39 d0                	cmp    %edx,%eax
f01027bf:	74 24                	je     f01027e5 <mem_init+0xc92>
f01027c1:	c7 44 24 0c 1c 76 10 	movl   $0xf010761c,0xc(%esp)
f01027c8:	f0 
f01027c9:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01027d0:	f0 
f01027d1:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01027d8:	00 
f01027d9:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01027e0:	e8 5b d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01027e5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027ea:	74 24                	je     f0102810 <mem_init+0xcbd>
f01027ec:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f01027f3:	f0 
f01027f4:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01027fb:	f0 
f01027fc:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102803:	00 
f0102804:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010280b:	e8 30 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102810:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102817:	00 
f0102818:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010281f:	00 
f0102820:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102823:	89 04 24             	mov    %eax,(%esp)
f0102826:	e8 04 f0 ff ff       	call   f010182f <pgdir_walk>
f010282b:	f6 00 04             	testb  $0x4,(%eax)
f010282e:	75 24                	jne    f0102854 <mem_init+0xd01>
f0102830:	c7 44 24 0c cc 76 10 	movl   $0xf01076cc,0xc(%esp)
f0102837:	f0 
f0102838:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010283f:	f0 
f0102840:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f0102847:	00 
f0102848:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010284f:	e8 ec d7 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102854:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102859:	f6 00 04             	testb  $0x4,(%eax)
f010285c:	75 24                	jne    f0102882 <mem_init+0xd2f>
f010285e:	c7 44 24 0c e9 7e 10 	movl   $0xf0107ee9,0xc(%esp)
f0102865:	f0 
f0102866:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010286d:	f0 
f010286e:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0102875:	00 
f0102876:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010287d:	e8 be d7 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102882:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102889:	00 
f010288a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102891:	00 
f0102892:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102896:	89 04 24             	mov    %eax,(%esp)
f0102899:	e8 9c f1 ff ff       	call   f0101a3a <page_insert>
f010289e:	85 c0                	test   %eax,%eax
f01028a0:	74 24                	je     f01028c6 <mem_init+0xd73>
f01028a2:	c7 44 24 0c e0 75 10 	movl   $0xf01075e0,0xc(%esp)
f01028a9:	f0 
f01028aa:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01028b1:	f0 
f01028b2:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01028b9:	00 
f01028ba:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01028c1:	e8 7a d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01028c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028cd:	00 
f01028ce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028d5:	00 
f01028d6:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01028db:	89 04 24             	mov    %eax,(%esp)
f01028de:	e8 4c ef ff ff       	call   f010182f <pgdir_walk>
f01028e3:	f6 00 02             	testb  $0x2,(%eax)
f01028e6:	75 24                	jne    f010290c <mem_init+0xdb9>
f01028e8:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f01028ef:	f0 
f01028f0:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01028f7:	f0 
f01028f8:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01028ff:	00 
f0102900:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102907:	e8 34 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010290c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102913:	00 
f0102914:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010291b:	00 
f010291c:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102921:	89 04 24             	mov    %eax,(%esp)
f0102924:	e8 06 ef ff ff       	call   f010182f <pgdir_walk>
f0102929:	f6 00 04             	testb  $0x4,(%eax)
f010292c:	74 24                	je     f0102952 <mem_init+0xdff>
f010292e:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f0102935:	f0 
f0102936:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010293d:	f0 
f010293e:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102945:	00 
f0102946:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010294d:	e8 ee d6 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102952:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102959:	00 
f010295a:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102961:	00 
f0102962:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102966:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f010296b:	89 04 24             	mov    %eax,(%esp)
f010296e:	e8 c7 f0 ff ff       	call   f0101a3a <page_insert>
f0102973:	85 c0                	test   %eax,%eax
f0102975:	78 24                	js     f010299b <mem_init+0xe48>
f0102977:	c7 44 24 0c 6c 77 10 	movl   $0xf010776c,0xc(%esp)
f010297e:	f0 
f010297f:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102986:	f0 
f0102987:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f010298e:	00 
f010298f:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102996:	e8 a5 d6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010299b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01029a2:	00 
f01029a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029aa:	00 
f01029ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01029af:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01029b4:	89 04 24             	mov    %eax,(%esp)
f01029b7:	e8 7e f0 ff ff       	call   f0101a3a <page_insert>
f01029bc:	85 c0                	test   %eax,%eax
f01029be:	74 24                	je     f01029e4 <mem_init+0xe91>
f01029c0:	c7 44 24 0c a4 77 10 	movl   $0xf01077a4,0xc(%esp)
f01029c7:	f0 
f01029c8:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01029d7:	00 
f01029d8:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01029df:	e8 5c d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01029e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029eb:	00 
f01029ec:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029f3:	00 
f01029f4:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01029f9:	89 04 24             	mov    %eax,(%esp)
f01029fc:	e8 2e ee ff ff       	call   f010182f <pgdir_walk>
f0102a01:	f6 00 04             	testb  $0x4,(%eax)
f0102a04:	74 24                	je     f0102a2a <mem_init+0xed7>
f0102a06:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f0102a0d:	f0 
f0102a0e:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102a15:	f0 
f0102a16:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0102a1d:	00 
f0102a1e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102a25:	e8 16 d6 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a2a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102a2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a32:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a37:	e8 30 e7 ff ff       	call   f010116c <check_va2pa>
f0102a3c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a3f:	89 f8                	mov    %edi,%eax
f0102a41:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0102a47:	c1 f8 03             	sar    $0x3,%eax
f0102a4a:	c1 e0 0c             	shl    $0xc,%eax
f0102a4d:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a50:	74 24                	je     f0102a76 <mem_init+0xf23>
f0102a52:	c7 44 24 0c e0 77 10 	movl   $0xf01077e0,0xc(%esp)
f0102a59:	f0 
f0102a5a:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102a61:	f0 
f0102a62:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0102a69:	00 
f0102a6a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102a71:	e8 ca d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a76:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a7e:	e8 e9 e6 ff ff       	call   f010116c <check_va2pa>
f0102a83:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a86:	74 24                	je     f0102aac <mem_init+0xf59>
f0102a88:	c7 44 24 0c 0c 78 10 	movl   $0xf010780c,0xc(%esp)
f0102a8f:	f0 
f0102a90:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102a97:	f0 
f0102a98:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102a9f:	00 
f0102aa0:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102aa7:	e8 94 d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102aac:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102ab1:	74 24                	je     f0102ad7 <mem_init+0xf84>
f0102ab3:	c7 44 24 0c ff 7e 10 	movl   $0xf0107eff,0xc(%esp)
f0102aba:	f0 
f0102abb:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102ac2:	f0 
f0102ac3:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102aca:	00 
f0102acb:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102ad2:	e8 69 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102ad7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102adc:	74 24                	je     f0102b02 <mem_init+0xfaf>
f0102ade:	c7 44 24 0c 10 7f 10 	movl   $0xf0107f10,0xc(%esp)
f0102ae5:	f0 
f0102ae6:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102aed:	f0 
f0102aee:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0102af5:	00 
f0102af6:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102afd:	e8 3e d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102b02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b09:	e8 48 ec ff ff       	call   f0101756 <page_alloc>
f0102b0e:	85 c0                	test   %eax,%eax
f0102b10:	74 04                	je     f0102b16 <mem_init+0xfc3>
f0102b12:	39 c3                	cmp    %eax,%ebx
f0102b14:	74 24                	je     f0102b3a <mem_init+0xfe7>
f0102b16:	c7 44 24 0c 3c 78 10 	movl   $0xf010783c,0xc(%esp)
f0102b1d:	f0 
f0102b1e:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102b25:	f0 
f0102b26:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0102b2d:	00 
f0102b2e:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102b35:	e8 06 d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102b3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b41:	00 
f0102b42:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102b47:	89 04 24             	mov    %eax,(%esp)
f0102b4a:	e8 9b ee ff ff       	call   f01019ea <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b4f:	8b 15 ec 5e 22 f0    	mov    0xf0225eec,%edx
f0102b55:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102b58:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b60:	e8 07 e6 ff ff       	call   f010116c <check_va2pa>
f0102b65:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b68:	74 24                	je     f0102b8e <mem_init+0x103b>
f0102b6a:	c7 44 24 0c 60 78 10 	movl   $0xf0107860,0xc(%esp)
f0102b71:	f0 
f0102b72:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102b79:	f0 
f0102b7a:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f0102b81:	00 
f0102b82:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102b89:	e8 b2 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b8e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b96:	e8 d1 e5 ff ff       	call   f010116c <check_va2pa>
f0102b9b:	89 fa                	mov    %edi,%edx
f0102b9d:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f0102ba3:	c1 fa 03             	sar    $0x3,%edx
f0102ba6:	c1 e2 0c             	shl    $0xc,%edx
f0102ba9:	39 d0                	cmp    %edx,%eax
f0102bab:	74 24                	je     f0102bd1 <mem_init+0x107e>
f0102bad:	c7 44 24 0c 0c 78 10 	movl   $0xf010780c,0xc(%esp)
f0102bb4:	f0 
f0102bb5:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102bbc:	f0 
f0102bbd:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102bc4:	00 
f0102bc5:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102bcc:	e8 6f d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102bd1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bd6:	74 24                	je     f0102bfc <mem_init+0x10a9>
f0102bd8:	c7 44 24 0c ac 7e 10 	movl   $0xf0107eac,0xc(%esp)
f0102bdf:	f0 
f0102be0:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102be7:	f0 
f0102be8:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0102bef:	00 
f0102bf0:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102bf7:	e8 44 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102bfc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c01:	74 24                	je     f0102c27 <mem_init+0x10d4>
f0102c03:	c7 44 24 0c 10 7f 10 	movl   $0xf0107f10,0xc(%esp)
f0102c0a:	f0 
f0102c0b:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102c12:	f0 
f0102c13:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0102c1a:	00 
f0102c1b:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102c22:	e8 19 d4 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c27:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c2e:	00 
f0102c2f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c32:	89 0c 24             	mov    %ecx,(%esp)
f0102c35:	e8 b0 ed ff ff       	call   f01019ea <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102c3a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102c3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c42:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c47:	e8 20 e5 ff ff       	call   f010116c <check_va2pa>
f0102c4c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c4f:	74 24                	je     f0102c75 <mem_init+0x1122>
f0102c51:	c7 44 24 0c 60 78 10 	movl   $0xf0107860,0xc(%esp)
f0102c58:	f0 
f0102c59:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102c60:	f0 
f0102c61:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0102c68:	00 
f0102c69:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102c70:	e8 cb d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102c75:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c7a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c7d:	e8 ea e4 ff ff       	call   f010116c <check_va2pa>
f0102c82:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c85:	74 24                	je     f0102cab <mem_init+0x1158>
f0102c87:	c7 44 24 0c 84 78 10 	movl   $0xf0107884,0xc(%esp)
f0102c8e:	f0 
f0102c8f:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102c96:	f0 
f0102c97:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0102c9e:	00 
f0102c9f:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102ca6:	e8 95 d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102cab:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cb0:	74 24                	je     f0102cd6 <mem_init+0x1183>
f0102cb2:	c7 44 24 0c 21 7f 10 	movl   $0xf0107f21,0xc(%esp)
f0102cb9:	f0 
f0102cba:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102cc1:	f0 
f0102cc2:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f0102cc9:	00 
f0102cca:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102cd1:	e8 6a d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102cd6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102cdb:	74 24                	je     f0102d01 <mem_init+0x11ae>
f0102cdd:	c7 44 24 0c 10 7f 10 	movl   $0xf0107f10,0xc(%esp)
f0102ce4:	f0 
f0102ce5:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102cec:	f0 
f0102ced:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0102cf4:	00 
f0102cf5:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102cfc:	e8 3f d3 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d08:	e8 49 ea ff ff       	call   f0101756 <page_alloc>
f0102d0d:	85 c0                	test   %eax,%eax
f0102d0f:	74 04                	je     f0102d15 <mem_init+0x11c2>
f0102d11:	39 c7                	cmp    %eax,%edi
f0102d13:	74 24                	je     f0102d39 <mem_init+0x11e6>
f0102d15:	c7 44 24 0c ac 78 10 	movl   $0xf01078ac,0xc(%esp)
f0102d1c:	f0 
f0102d1d:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102d24:	f0 
f0102d25:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f0102d2c:	00 
f0102d2d:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102d34:	e8 07 d3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102d39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d40:	e8 11 ea ff ff       	call   f0101756 <page_alloc>
f0102d45:	85 c0                	test   %eax,%eax
f0102d47:	74 24                	je     f0102d6d <mem_init+0x121a>
f0102d49:	c7 44 24 0c 5a 7e 10 	movl   $0xf0107e5a,0xc(%esp)
f0102d50:	f0 
f0102d51:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102d58:	f0 
f0102d59:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0102d60:	00 
f0102d61:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102d68:	e8 d3 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d6d:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102d72:	8b 08                	mov    (%eax),%ecx
f0102d74:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102d7a:	89 f2                	mov    %esi,%edx
f0102d7c:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f0102d82:	c1 fa 03             	sar    $0x3,%edx
f0102d85:	c1 e2 0c             	shl    $0xc,%edx
f0102d88:	39 d1                	cmp    %edx,%ecx
f0102d8a:	74 24                	je     f0102db0 <mem_init+0x125d>
f0102d8c:	c7 44 24 0c 88 75 10 	movl   $0xf0107588,0xc(%esp)
f0102d93:	f0 
f0102d94:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102d9b:	f0 
f0102d9c:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0102da3:	00 
f0102da4:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102dab:	e8 90 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102db0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102db6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dbb:	74 24                	je     f0102de1 <mem_init+0x128e>
f0102dbd:	c7 44 24 0c bd 7e 10 	movl   $0xf0107ebd,0xc(%esp)
f0102dc4:	f0 
f0102dc5:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102dcc:	f0 
f0102dcd:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102dd4:	00 
f0102dd5:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102ddc:	e8 5f d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102de1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102de7:	89 34 24             	mov    %esi,(%esp)
f0102dea:	e8 e5 e9 ff ff       	call   f01017d4 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102def:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102df6:	00 
f0102df7:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102dfe:	00 
f0102dff:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102e04:	89 04 24             	mov    %eax,(%esp)
f0102e07:	e8 23 ea ff ff       	call   f010182f <pgdir_walk>
f0102e0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102e0f:	8b 0d ec 5e 22 f0    	mov    0xf0225eec,%ecx
f0102e15:	8b 51 04             	mov    0x4(%ecx),%edx
f0102e18:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e1e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e21:	8b 15 e8 5e 22 f0    	mov    0xf0225ee8,%edx
f0102e27:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102e2a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e2d:	c1 ea 0c             	shr    $0xc,%edx
f0102e30:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102e33:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102e36:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102e39:	72 23                	jb     f0102e5e <mem_init+0x130b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e3b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102e42:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0102e49:	f0 
f0102e4a:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f0102e51:	00 
f0102e52:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102e59:	e8 e2 d1 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102e5e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e61:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102e67:	39 d0                	cmp    %edx,%eax
f0102e69:	74 24                	je     f0102e8f <mem_init+0x133c>
f0102e6b:	c7 44 24 0c 32 7f 10 	movl   $0xf0107f32,0xc(%esp)
f0102e72:	f0 
f0102e73:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102e7a:	f0 
f0102e7b:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f0102e82:	00 
f0102e83:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102e8a:	e8 b1 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102e8f:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102e96:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e9c:	89 f0                	mov    %esi,%eax
f0102e9e:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0102ea4:	c1 f8 03             	sar    $0x3,%eax
f0102ea7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102eaa:	89 c1                	mov    %eax,%ecx
f0102eac:	c1 e9 0c             	shr    $0xc,%ecx
f0102eaf:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102eb2:	77 20                	ja     f0102ed4 <mem_init+0x1381>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102eb8:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0102ebf:	f0 
f0102ec0:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102ec7:	00 
f0102ec8:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0102ecf:	e8 6c d1 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102ed4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102edb:	00 
f0102edc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102ee3:	00 
	return (void *)(pa + KERNBASE);
f0102ee4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ee9:	89 04 24             	mov    %eax,(%esp)
f0102eec:	e8 10 2e 00 00       	call   f0105d01 <memset>
	page_free(pp0);
f0102ef1:	89 34 24             	mov    %esi,(%esp)
f0102ef4:	e8 db e8 ff ff       	call   f01017d4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102ef9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102f00:	00 
f0102f01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f08:	00 
f0102f09:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102f0e:	89 04 24             	mov    %eax,(%esp)
f0102f11:	e8 19 e9 ff ff       	call   f010182f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f16:	89 f2                	mov    %esi,%edx
f0102f18:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f0102f1e:	c1 fa 03             	sar    $0x3,%edx
f0102f21:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f24:	89 d0                	mov    %edx,%eax
f0102f26:	c1 e8 0c             	shr    $0xc,%eax
f0102f29:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f0102f2f:	72 20                	jb     f0102f51 <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f31:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f35:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0102f3c:	f0 
f0102f3d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0102f44:	00 
f0102f45:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0102f4c:	e8 ef d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102f51:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102f57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f5a:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102f61:	75 11                	jne    f0102f74 <mem_init+0x1421>
f0102f63:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f69:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f6f:	f6 00 01             	testb  $0x1,(%eax)
f0102f72:	74 24                	je     f0102f98 <mem_init+0x1445>
f0102f74:	c7 44 24 0c 4a 7f 10 	movl   $0xf0107f4a,0xc(%esp)
f0102f7b:	f0 
f0102f7c:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0102f83:	f0 
f0102f84:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f0102f8b:	00 
f0102f8c:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0102f93:	e8 a8 d0 ff ff       	call   f0100040 <_panic>
f0102f98:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102f9b:	39 d0                	cmp    %edx,%eax
f0102f9d:	75 d0                	jne    f0102f6f <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102f9f:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0102fa4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102faa:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102fb0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102fb3:	89 0d 40 52 22 f0    	mov    %ecx,0xf0225240

	// free the pages we took
	page_free(pp0);
f0102fb9:	89 34 24             	mov    %esi,(%esp)
f0102fbc:	e8 13 e8 ff ff       	call   f01017d4 <page_free>
	page_free(pp1);
f0102fc1:	89 3c 24             	mov    %edi,(%esp)
f0102fc4:	e8 0b e8 ff ff       	call   f01017d4 <page_free>
	page_free(pp2);
f0102fc9:	89 1c 24             	mov    %ebx,(%esp)
f0102fcc:	e8 03 e8 ff ff       	call   f01017d4 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102fd1:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102fd8:	00 
f0102fd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fe0:	e8 ff ea ff ff       	call   f0101ae4 <mmio_map_region>
f0102fe5:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102fe7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102fee:	00 
f0102fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ff6:	e8 e9 ea ff ff       	call   f0101ae4 <mmio_map_region>
f0102ffb:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102ffd:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0103003:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103009:	76 07                	jbe    f0103012 <mem_init+0x14bf>
f010300b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103010:	76 24                	jbe    f0103036 <mem_init+0x14e3>
f0103012:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f0103019:	f0 
f010301a:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103021:	f0 
f0103022:	c7 44 24 04 98 04 00 	movl   $0x498,0x4(%esp)
f0103029:	00 
f010302a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103031:	e8 0a d0 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103036:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010303c:	76 0e                	jbe    f010304c <mem_init+0x14f9>
f010303e:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0103044:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010304a:	76 24                	jbe    f0103070 <mem_init+0x151d>
f010304c:	c7 44 24 0c f8 78 10 	movl   $0xf01078f8,0xc(%esp)
f0103053:	f0 
f0103054:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010305b:	f0 
f010305c:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0103063:	00 
f0103064:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010306b:	e8 d0 cf ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103070:	89 da                	mov    %ebx,%edx
f0103072:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0103074:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010307a:	74 24                	je     f01030a0 <mem_init+0x154d>
f010307c:	c7 44 24 0c 20 79 10 	movl   $0xf0107920,0xc(%esp)
f0103083:	f0 
f0103084:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010308b:	f0 
f010308c:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f0103093:	00 
f0103094:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010309b:	e8 a0 cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01030a0:	39 c6                	cmp    %eax,%esi
f01030a2:	73 24                	jae    f01030c8 <mem_init+0x1575>
f01030a4:	c7 44 24 0c 61 7f 10 	movl   $0xf0107f61,0xc(%esp)
f01030ab:	f0 
f01030ac:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01030b3:	f0 
f01030b4:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f01030bb:	00 
f01030bc:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01030c3:	e8 78 cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01030c8:	8b 3d ec 5e 22 f0    	mov    0xf0225eec,%edi
f01030ce:	89 da                	mov    %ebx,%edx
f01030d0:	89 f8                	mov    %edi,%eax
f01030d2:	e8 95 e0 ff ff       	call   f010116c <check_va2pa>
f01030d7:	85 c0                	test   %eax,%eax
f01030d9:	74 24                	je     f01030ff <mem_init+0x15ac>
f01030db:	c7 44 24 0c 48 79 10 	movl   $0xf0107948,0xc(%esp)
f01030e2:	f0 
f01030e3:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01030ea:	f0 
f01030eb:	c7 44 24 04 9f 04 00 	movl   $0x49f,0x4(%esp)
f01030f2:	00 
f01030f3:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01030fa:	e8 41 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01030ff:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0103105:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103108:	89 c2                	mov    %eax,%edx
f010310a:	89 f8                	mov    %edi,%eax
f010310c:	e8 5b e0 ff ff       	call   f010116c <check_va2pa>
f0103111:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103116:	74 24                	je     f010313c <mem_init+0x15e9>
f0103118:	c7 44 24 0c 6c 79 10 	movl   $0xf010796c,0xc(%esp)
f010311f:	f0 
f0103120:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103127:	f0 
f0103128:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f010312f:	00 
f0103130:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103137:	e8 04 cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010313c:	89 f2                	mov    %esi,%edx
f010313e:	89 f8                	mov    %edi,%eax
f0103140:	e8 27 e0 ff ff       	call   f010116c <check_va2pa>
f0103145:	85 c0                	test   %eax,%eax
f0103147:	74 24                	je     f010316d <mem_init+0x161a>
f0103149:	c7 44 24 0c 9c 79 10 	movl   $0xf010799c,0xc(%esp)
f0103150:	f0 
f0103151:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103158:	f0 
f0103159:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f0103160:	00 
f0103161:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103168:	e8 d3 ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010316d:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0103173:	89 f8                	mov    %edi,%eax
f0103175:	e8 f2 df ff ff       	call   f010116c <check_va2pa>
f010317a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010317d:	74 24                	je     f01031a3 <mem_init+0x1650>
f010317f:	c7 44 24 0c c0 79 10 	movl   $0xf01079c0,0xc(%esp)
f0103186:	f0 
f0103187:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010318e:	f0 
f010318f:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0103196:	00 
f0103197:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010319e:	e8 9d ce ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01031a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031aa:	00 
f01031ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031af:	89 3c 24             	mov    %edi,(%esp)
f01031b2:	e8 78 e6 ff ff       	call   f010182f <pgdir_walk>
f01031b7:	f6 00 1a             	testb  $0x1a,(%eax)
f01031ba:	75 24                	jne    f01031e0 <mem_init+0x168d>
f01031bc:	c7 44 24 0c ec 79 10 	movl   $0xf01079ec,0xc(%esp)
f01031c3:	f0 
f01031c4:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01031cb:	f0 
f01031cc:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f01031d3:	00 
f01031d4:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01031db:	e8 60 ce ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01031e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031e7:	00 
f01031e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031ec:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01031f1:	89 04 24             	mov    %eax,(%esp)
f01031f4:	e8 36 e6 ff ff       	call   f010182f <pgdir_walk>
f01031f9:	f6 00 04             	testb  $0x4,(%eax)
f01031fc:	74 24                	je     f0103222 <mem_init+0x16cf>
f01031fe:	c7 44 24 0c 30 7a 10 	movl   $0xf0107a30,0xc(%esp)
f0103205:	f0 
f0103206:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010320d:	f0 
f010320e:	c7 44 24 04 a5 04 00 	movl   $0x4a5,0x4(%esp)
f0103215:	00 
f0103216:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010321d:	e8 1e ce ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103222:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103229:	00 
f010322a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010322e:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103233:	89 04 24             	mov    %eax,(%esp)
f0103236:	e8 f4 e5 ff ff       	call   f010182f <pgdir_walk>
f010323b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103241:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103248:	00 
f0103249:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010324c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103250:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103255:	89 04 24             	mov    %eax,(%esp)
f0103258:	e8 d2 e5 ff ff       	call   f010182f <pgdir_walk>
f010325d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103263:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010326a:	00 
f010326b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010326f:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103274:	89 04 24             	mov    %eax,(%esp)
f0103277:	e8 b3 e5 ff ff       	call   f010182f <pgdir_walk>
f010327c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103282:	c7 04 24 73 7f 10 f0 	movl   $0xf0107f73,(%esp)
f0103289:	e8 50 13 00 00       	call   f01045de <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f010328e:	a1 f0 5e 22 f0       	mov    0xf0225ef0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103293:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103298:	77 20                	ja     f01032ba <mem_init+0x1767>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010329a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010329e:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01032a5:	f0 
f01032a6:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
f01032ad:	00 
f01032ae:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01032b5:	e8 86 cd ff ff       	call   f0100040 <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f01032ba:	8b 15 e8 5e 22 f0    	mov    0xf0225ee8,%edx
f01032c0:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01032c7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f01032cd:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01032d4:	00 
	return (physaddr_t)kva - KERNBASE;
f01032d5:	05 00 00 00 10       	add    $0x10000000,%eax
f01032da:	89 04 24             	mov    %eax,(%esp)
f01032dd:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01032e2:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01032e7:	e8 e3 e5 ff ff       	call   f01018cf <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(
f01032ec:	a1 48 52 22 f0       	mov    0xf0225248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f6:	77 20                	ja     f0103318 <mem_init+0x17c5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032fc:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0103303:	f0 
f0103304:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f010330b:	00 
f010330c:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103313:	e8 28 cd ff ff       	call   f0100040 <_panic>
f0103318:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010331f:	00 
	return (physaddr_t)kva - KERNBASE;
f0103320:	05 00 00 00 10       	add    $0x10000000,%eax
f0103325:	89 04 24             	mov    %eax,(%esp)
f0103328:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010332d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103332:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103337:	e8 93 e5 ff ff       	call   f01018cf <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010333c:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0103341:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103346:	77 20                	ja     f0103368 <mem_init+0x1815>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103348:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010334c:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0103353:	f0 
f0103354:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
f010335b:	00 
f010335c:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103363:	e8 d8 cc ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0103368:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010336f:	00 
f0103370:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0103377:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010337c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103381:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103386:	e8 44 e5 ff ff       	call   f01018cf <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(
f010338b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103392:	00 
f0103393:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010339a:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010339f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01033a4:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01033a9:	e8 21 e5 ff ff       	call   f01018cf <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01033ae:	8b 1d ec 5e 22 f0    	mov    0xf0225eec,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01033b4:	8b 0d e8 5e 22 f0    	mov    0xf0225ee8,%ecx
f01033ba:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01033bd:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01033c4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01033ca:	0f 84 80 00 00 00    	je     f0103450 <mem_init+0x18fd>
f01033d0:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01033d5:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01033db:	89 d8                	mov    %ebx,%eax
f01033dd:	e8 8a dd ff ff       	call   f010116c <check_va2pa>
f01033e2:	8b 15 f0 5e 22 f0    	mov    0xf0225ef0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033e8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01033ee:	77 20                	ja     f0103410 <mem_init+0x18bd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01033f4:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01033fb:	f0 
f01033fc:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0103403:	00 
f0103404:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010340b:	e8 30 cc ff ff       	call   f0100040 <_panic>
f0103410:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103417:	39 d0                	cmp    %edx,%eax
f0103419:	74 24                	je     f010343f <mem_init+0x18ec>
f010341b:	c7 44 24 0c 64 7a 10 	movl   $0xf0107a64,0xc(%esp)
f0103422:	f0 
f0103423:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010342a:	f0 
f010342b:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0103432:	00 
f0103433:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010343a:	e8 01 cc ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010343f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103445:	39 f7                	cmp    %esi,%edi
f0103447:	77 8c                	ja     f01033d5 <mem_init+0x1882>
f0103449:	be 00 00 00 00       	mov    $0x0,%esi
f010344e:	eb 05                	jmp    f0103455 <mem_init+0x1902>
f0103450:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103455:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010345b:	89 d8                	mov    %ebx,%eax
f010345d:	e8 0a dd ff ff       	call   f010116c <check_va2pa>
f0103462:	8b 15 48 52 22 f0    	mov    0xf0225248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103468:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010346e:	77 20                	ja     f0103490 <mem_init+0x193d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103470:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103474:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f010347b:	f0 
f010347c:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0103483:	00 
f0103484:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010348b:	e8 b0 cb ff ff       	call   f0100040 <_panic>
f0103490:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103497:	39 d0                	cmp    %edx,%eax
f0103499:	74 24                	je     f01034bf <mem_init+0x196c>
f010349b:	c7 44 24 0c 98 7a 10 	movl   $0xf0107a98,0xc(%esp)
f01034a2:	f0 
f01034a3:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01034aa:	f0 
f01034ab:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01034b2:	00 
f01034b3:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01034ba:	e8 81 cb ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01034bf:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01034c5:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f01034cb:	75 88                	jne    f0103455 <mem_init+0x1902>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01034cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01034d0:	c1 e7 0c             	shl    $0xc,%edi
f01034d3:	85 ff                	test   %edi,%edi
f01034d5:	74 44                	je     f010351b <mem_init+0x19c8>
f01034d7:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01034dc:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01034e2:	89 d8                	mov    %ebx,%eax
f01034e4:	e8 83 dc ff ff       	call   f010116c <check_va2pa>
f01034e9:	39 c6                	cmp    %eax,%esi
f01034eb:	74 24                	je     f0103511 <mem_init+0x19be>
f01034ed:	c7 44 24 0c cc 7a 10 	movl   $0xf0107acc,0xc(%esp)
f01034f4:	f0 
f01034f5:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01034fc:	f0 
f01034fd:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0103504:	00 
f0103505:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010350c:	e8 2f cb ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103511:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103517:	39 fe                	cmp    %edi,%esi
f0103519:	72 c1                	jb     f01034dc <mem_init+0x1989>
f010351b:	c7 45 cc 00 70 22 f0 	movl   $0xf0227000,-0x34(%ebp)
f0103522:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)
f0103529:	89 df                	mov    %ebx,%edi
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010352b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010352e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103531:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103534:	81 c3 00 80 00 00    	add    $0x8000,%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010353a:	89 c6                	mov    %eax,%esi
f010353c:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103542:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103545:	81 c2 00 00 01 00    	add    $0x10000,%edx
f010354b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010354e:	89 da                	mov    %ebx,%edx
f0103550:	89 f8                	mov    %edi,%eax
f0103552:	e8 15 dc ff ff       	call   f010116c <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103557:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010355e:	77 23                	ja     f0103583 <mem_init+0x1a30>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103560:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103563:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103567:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f010356e:	f0 
f010356f:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0103576:	00 
f0103577:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010357e:	e8 bd ca ff ff       	call   f0100040 <_panic>
f0103583:	39 f0                	cmp    %esi,%eax
f0103585:	74 24                	je     f01035ab <mem_init+0x1a58>
f0103587:	c7 44 24 0c f4 7a 10 	movl   $0xf0107af4,0xc(%esp)
f010358e:	f0 
f010358f:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103596:	f0 
f0103597:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f010359e:	00 
f010359f:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01035a6:	e8 95 ca ff ff       	call   f0100040 <_panic>
f01035ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035b1:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01035b7:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01035ba:	0f 85 58 05 00 00    	jne    f0103b18 <mem_init+0x1fc5>
f01035c0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01035c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01035c8:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01035cb:	89 f8                	mov    %edi,%eax
f01035cd:	e8 9a db ff ff       	call   f010116c <check_va2pa>
f01035d2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01035d5:	74 24                	je     f01035fb <mem_init+0x1aa8>
f01035d7:	c7 44 24 0c 3c 7b 10 	movl   $0xf0107b3c,0xc(%esp)
f01035de:	f0 
f01035df:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01035e6:	f0 
f01035e7:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f01035ee:	00 
f01035ef:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01035f6:	e8 45 ca ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01035fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103601:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0103607:	75 bf                	jne    f01035c8 <mem_init+0x1a75>
f0103609:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0103610:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0103617:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f010361e:	0f 85 07 ff ff ff    	jne    f010352b <mem_init+0x19d8>
f0103624:	89 fb                	mov    %edi,%ebx
f0103626:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010362b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103631:	83 fa 04             	cmp    $0x4,%edx
f0103634:	77 2e                	ja     f0103664 <mem_init+0x1b11>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0103636:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010363a:	0f 85 aa 00 00 00    	jne    f01036ea <mem_init+0x1b97>
f0103640:	c7 44 24 0c 8c 7f 10 	movl   $0xf0107f8c,0xc(%esp)
f0103647:	f0 
f0103648:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010364f:	f0 
f0103650:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0103657:	00 
f0103658:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010365f:	e8 dc c9 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103664:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103669:	76 55                	jbe    f01036c0 <mem_init+0x1b6d>
				assert(pgdir[i] & PTE_P);
f010366b:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010366e:	f6 c2 01             	test   $0x1,%dl
f0103671:	75 24                	jne    f0103697 <mem_init+0x1b44>
f0103673:	c7 44 24 0c 8c 7f 10 	movl   $0xf0107f8c,0xc(%esp)
f010367a:	f0 
f010367b:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103682:	f0 
f0103683:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f010368a:	00 
f010368b:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103692:	e8 a9 c9 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103697:	f6 c2 02             	test   $0x2,%dl
f010369a:	75 4e                	jne    f01036ea <mem_init+0x1b97>
f010369c:	c7 44 24 0c 9d 7f 10 	movl   $0xf0107f9d,0xc(%esp)
f01036a3:	f0 
f01036a4:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01036ab:	f0 
f01036ac:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f01036b3:	00 
f01036b4:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01036bb:	e8 80 c9 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01036c0:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01036c4:	74 24                	je     f01036ea <mem_init+0x1b97>
f01036c6:	c7 44 24 0c ae 7f 10 	movl   $0xf0107fae,0xc(%esp)
f01036cd:	f0 
f01036ce:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01036d5:	f0 
f01036d6:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01036dd:	00 
f01036de:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01036e5:	e8 56 c9 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01036ea:	83 c0 01             	add    $0x1,%eax
f01036ed:	3d 00 04 00 00       	cmp    $0x400,%eax
f01036f2:	0f 85 33 ff ff ff    	jne    f010362b <mem_init+0x1ad8>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01036f8:	c7 04 24 60 7b 10 f0 	movl   $0xf0107b60,(%esp)
f01036ff:	e8 da 0e 00 00       	call   f01045de <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103704:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103709:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010370e:	77 20                	ja     f0103730 <mem_init+0x1bdd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103710:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103714:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f010371b:	f0 
f010371c:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0103723:	00 
f0103724:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010372b:	e8 10 c9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103730:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103735:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103738:	b8 00 00 00 00       	mov    $0x0,%eax
f010373d:	e8 9e db ff ff       	call   f01012e0 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103742:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103745:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010374a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010374d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103757:	e8 fa df ff ff       	call   f0101756 <page_alloc>
f010375c:	89 c6                	mov    %eax,%esi
f010375e:	85 c0                	test   %eax,%eax
f0103760:	75 24                	jne    f0103786 <mem_init+0x1c33>
f0103762:	c7 44 24 0c af 7d 10 	movl   $0xf0107daf,0xc(%esp)
f0103769:	f0 
f010376a:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103771:	f0 
f0103772:	c7 44 24 04 ba 04 00 	movl   $0x4ba,0x4(%esp)
f0103779:	00 
f010377a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103781:	e8 ba c8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103786:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010378d:	e8 c4 df ff ff       	call   f0101756 <page_alloc>
f0103792:	89 c7                	mov    %eax,%edi
f0103794:	85 c0                	test   %eax,%eax
f0103796:	75 24                	jne    f01037bc <mem_init+0x1c69>
f0103798:	c7 44 24 0c c5 7d 10 	movl   $0xf0107dc5,0xc(%esp)
f010379f:	f0 
f01037a0:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01037a7:	f0 
f01037a8:	c7 44 24 04 bb 04 00 	movl   $0x4bb,0x4(%esp)
f01037af:	00 
f01037b0:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01037b7:	e8 84 c8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01037bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037c3:	e8 8e df ff ff       	call   f0101756 <page_alloc>
f01037c8:	89 c3                	mov    %eax,%ebx
f01037ca:	85 c0                	test   %eax,%eax
f01037cc:	75 24                	jne    f01037f2 <mem_init+0x1c9f>
f01037ce:	c7 44 24 0c db 7d 10 	movl   $0xf0107ddb,0xc(%esp)
f01037d5:	f0 
f01037d6:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01037dd:	f0 
f01037de:	c7 44 24 04 bc 04 00 	movl   $0x4bc,0x4(%esp)
f01037e5:	00 
f01037e6:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01037ed:	e8 4e c8 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f01037f2:	89 34 24             	mov    %esi,(%esp)
f01037f5:	e8 da df ff ff       	call   f01017d4 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01037fa:	89 f8                	mov    %edi,%eax
f01037fc:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0103802:	c1 f8 03             	sar    $0x3,%eax
f0103805:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103808:	89 c2                	mov    %eax,%edx
f010380a:	c1 ea 0c             	shr    $0xc,%edx
f010380d:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f0103813:	72 20                	jb     f0103835 <mem_init+0x1ce2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103815:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103819:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0103820:	f0 
f0103821:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103828:	00 
f0103829:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0103830:	e8 0b c8 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103835:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010383c:	00 
f010383d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103844:	00 
	return (void *)(pa + KERNBASE);
f0103845:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010384a:	89 04 24             	mov    %eax,(%esp)
f010384d:	e8 af 24 00 00       	call   f0105d01 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103852:	89 d8                	mov    %ebx,%eax
f0103854:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f010385a:	c1 f8 03             	sar    $0x3,%eax
f010385d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103860:	89 c2                	mov    %eax,%edx
f0103862:	c1 ea 0c             	shr    $0xc,%edx
f0103865:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f010386b:	72 20                	jb     f010388d <mem_init+0x1d3a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010386d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103871:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0103878:	f0 
f0103879:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103880:	00 
f0103881:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0103888:	e8 b3 c7 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010388d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103894:	00 
f0103895:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010389c:	00 
	return (void *)(pa + KERNBASE);
f010389d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01038a2:	89 04 24             	mov    %eax,(%esp)
f01038a5:	e8 57 24 00 00       	call   f0105d01 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01038aa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01038b1:	00 
f01038b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038b9:	00 
f01038ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038be:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f01038c3:	89 04 24             	mov    %eax,(%esp)
f01038c6:	e8 6f e1 ff ff       	call   f0101a3a <page_insert>
	assert(pp1->pp_ref == 1);
f01038cb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01038d0:	74 24                	je     f01038f6 <mem_init+0x1da3>
f01038d2:	c7 44 24 0c ac 7e 10 	movl   $0xf0107eac,0xc(%esp)
f01038d9:	f0 
f01038da:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01038e1:	f0 
f01038e2:	c7 44 24 04 c1 04 00 	movl   $0x4c1,0x4(%esp)
f01038e9:	00 
f01038ea:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01038f1:	e8 4a c7 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01038f6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01038fd:	01 01 01 
f0103900:	74 24                	je     f0103926 <mem_init+0x1dd3>
f0103902:	c7 44 24 0c 80 7b 10 	movl   $0xf0107b80,0xc(%esp)
f0103909:	f0 
f010390a:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103911:	f0 
f0103912:	c7 44 24 04 c2 04 00 	movl   $0x4c2,0x4(%esp)
f0103919:	00 
f010391a:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103921:	e8 1a c7 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103926:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010392d:	00 
f010392e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103935:	00 
f0103936:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010393a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f010393f:	89 04 24             	mov    %eax,(%esp)
f0103942:	e8 f3 e0 ff ff       	call   f0101a3a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103947:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010394e:	02 02 02 
f0103951:	74 24                	je     f0103977 <mem_init+0x1e24>
f0103953:	c7 44 24 0c a4 7b 10 	movl   $0xf0107ba4,0xc(%esp)
f010395a:	f0 
f010395b:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103962:	f0 
f0103963:	c7 44 24 04 c4 04 00 	movl   $0x4c4,0x4(%esp)
f010396a:	00 
f010396b:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103972:	e8 c9 c6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103977:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010397c:	74 24                	je     f01039a2 <mem_init+0x1e4f>
f010397e:	c7 44 24 0c d8 7e 10 	movl   $0xf0107ed8,0xc(%esp)
f0103985:	f0 
f0103986:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f010398d:	f0 
f010398e:	c7 44 24 04 c5 04 00 	movl   $0x4c5,0x4(%esp)
f0103995:	00 
f0103996:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f010399d:	e8 9e c6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01039a2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01039a7:	74 24                	je     f01039cd <mem_init+0x1e7a>
f01039a9:	c7 44 24 0c 21 7f 10 	movl   $0xf0107f21,0xc(%esp)
f01039b0:	f0 
f01039b1:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f01039b8:	f0 
f01039b9:	c7 44 24 04 c6 04 00 	movl   $0x4c6,0x4(%esp)
f01039c0:	00 
f01039c1:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f01039c8:	e8 73 c6 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01039cd:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01039d4:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01039d7:	89 d8                	mov    %ebx,%eax
f01039d9:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f01039df:	c1 f8 03             	sar    $0x3,%eax
f01039e2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039e5:	89 c2                	mov    %eax,%edx
f01039e7:	c1 ea 0c             	shr    $0xc,%edx
f01039ea:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f01039f0:	72 20                	jb     f0103a12 <mem_init+0x1ebf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039f6:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01039fd:	f0 
f01039fe:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103a05:	00 
f0103a06:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0103a0d:	e8 2e c6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103a12:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103a19:	03 03 03 
f0103a1c:	74 24                	je     f0103a42 <mem_init+0x1eef>
f0103a1e:	c7 44 24 0c c8 7b 10 	movl   $0xf0107bc8,0xc(%esp)
f0103a25:	f0 
f0103a26:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103a2d:	f0 
f0103a2e:	c7 44 24 04 c8 04 00 	movl   $0x4c8,0x4(%esp)
f0103a35:	00 
f0103a36:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103a3d:	e8 fe c5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103a42:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103a49:	00 
f0103a4a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103a4f:	89 04 24             	mov    %eax,(%esp)
f0103a52:	e8 93 df ff ff       	call   f01019ea <page_remove>
	assert(pp2->pp_ref == 0);
f0103a57:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103a5c:	74 24                	je     f0103a82 <mem_init+0x1f2f>
f0103a5e:	c7 44 24 0c 10 7f 10 	movl   $0xf0107f10,0xc(%esp)
f0103a65:	f0 
f0103a66:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103a6d:	f0 
f0103a6e:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f0103a75:	00 
f0103a76:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103a7d:	e8 be c5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103a82:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
f0103a87:	8b 08                	mov    (%eax),%ecx
f0103a89:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a8f:	89 f2                	mov    %esi,%edx
f0103a91:	2b 15 f0 5e 22 f0    	sub    0xf0225ef0,%edx
f0103a97:	c1 fa 03             	sar    $0x3,%edx
f0103a9a:	c1 e2 0c             	shl    $0xc,%edx
f0103a9d:	39 d1                	cmp    %edx,%ecx
f0103a9f:	74 24                	je     f0103ac5 <mem_init+0x1f72>
f0103aa1:	c7 44 24 0c 88 75 10 	movl   $0xf0107588,0xc(%esp)
f0103aa8:	f0 
f0103aa9:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103ab0:	f0 
f0103ab1:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f0103ab8:	00 
f0103ab9:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103ac0:	e8 7b c5 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103ac5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103acb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103ad0:	74 24                	je     f0103af6 <mem_init+0x1fa3>
f0103ad2:	c7 44 24 0c bd 7e 10 	movl   $0xf0107ebd,0xc(%esp)
f0103ad9:	f0 
f0103ada:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0103ae1:	f0 
f0103ae2:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f0103ae9:	00 
f0103aea:	c7 04 24 a5 7c 10 f0 	movl   $0xf0107ca5,(%esp)
f0103af1:	e8 4a c5 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103af6:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103afc:	89 34 24             	mov    %esi,(%esp)
f0103aff:	e8 d0 dc ff ff       	call   f01017d4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103b04:	c7 04 24 f4 7b 10 f0 	movl   $0xf0107bf4,(%esp)
f0103b0b:	e8 ce 0a 00 00       	call   f01045de <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103b10:	83 c4 3c             	add    $0x3c,%esp
f0103b13:	5b                   	pop    %ebx
f0103b14:	5e                   	pop    %esi
f0103b15:	5f                   	pop    %edi
f0103b16:	5d                   	pop    %ebp
f0103b17:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103b18:	89 da                	mov    %ebx,%edx
f0103b1a:	89 f8                	mov    %edi,%eax
f0103b1c:	e8 4b d6 ff ff       	call   f010116c <check_va2pa>
f0103b21:	e9 5d fa ff ff       	jmp    f0103583 <mem_init+0x1a30>

f0103b26 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103b26:	55                   	push   %ebp
f0103b27:	89 e5                	mov    %esp,%ebp
f0103b29:	57                   	push   %edi
f0103b2a:	56                   	push   %esi
f0103b2b:	53                   	push   %ebx
f0103b2c:	83 ec 2c             	sub    $0x2c,%esp
f0103b2f:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b32:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	cprintf("%s\n", "Check for user memory!\n");
f0103b35:	c7 44 24 04 bc 7f 10 	movl   $0xf0107fbc,0x4(%esp)
f0103b3c:	f0 
f0103b3d:	c7 04 24 0e 6e 10 f0 	movl   $0xf0106e0e,(%esp)
f0103b44:	e8 95 0a 00 00       	call   f01045de <cprintf>

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0103b49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b4c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
f0103b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b55:	8b 55 10             	mov    0x10(%ebp),%edx
f0103b58:	8d 84 11 ff 0f 00 00 	lea    0xfff(%ecx,%edx,1),%eax
f0103b5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103b64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f0103b67:	39 c3                	cmp    %eax,%ebx
f0103b69:	73 68                	jae    f0103bd3 <user_mem_check+0xad>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)_va_start, 0);
f0103b6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103b72:	00 
f0103b73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b77:	8b 46 60             	mov    0x60(%esi),%eax
f0103b7a:	89 04 24             	mov    %eax,(%esp)
f0103b7d:	e8 ad dc ff ff       	call   f010182f <pgdir_walk>

        if ((_va_start>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103b82:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103b88:	77 10                	ja     f0103b9a <user_mem_check+0x74>
f0103b8a:	85 c0                	test   %eax,%eax
f0103b8c:	74 0c                	je     f0103b9a <user_mem_check+0x74>
f0103b8e:	8b 00                	mov    (%eax),%eax
f0103b90:	a8 01                	test   $0x1,%al
f0103b92:	74 06                	je     f0103b9a <user_mem_check+0x74>
f0103b94:	21 f8                	and    %edi,%eax
f0103b96:	39 c7                	cmp    %eax,%edi
f0103b98:	74 2e                	je     f0103bc8 <user_mem_check+0xa2>
            user_mem_check_addr = (_va_start<(uint32_t)va) ? (uint32_t)va : _va_start;
f0103b9a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103b9d:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103ba1:	89 1d 44 52 22 f0    	mov    %ebx,0xf0225244
            cprintf("user_mem_check fail va: %x, len: %x\n", va, len);
f0103ba7:	8b 45 10             	mov    0x10(%ebp),%eax
f0103baa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bae:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bb1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103bb5:	c7 04 24 20 7c 10 f0 	movl   $0xf0107c20,(%esp)
f0103bbc:	e8 1d 0a 00 00       	call   f01045de <cprintf>
            return -E_FAULT;
f0103bc1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103bc6:	eb 2a                	jmp    f0103bf2 <user_mem_check+0xcc>
	// LAB 3: Your code here.
	cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f0103bc8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103bce:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103bd1:	77 98                	ja     f0103b6b <user_mem_check+0x45>
            return -E_FAULT;
        }

	}

	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f0103bd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103bd6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103bda:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be1:	c7 04 24 48 7c 10 f0 	movl   $0xf0107c48,(%esp)
f0103be8:	e8 f1 09 00 00       	call   f01045de <cprintf>

	return 0;
f0103bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103bf2:	83 c4 2c             	add    $0x2c,%esp
f0103bf5:	5b                   	pop    %ebx
f0103bf6:	5e                   	pop    %esi
f0103bf7:	5f                   	pop    %edi
f0103bf8:	5d                   	pop    %ebp
f0103bf9:	c3                   	ret    

f0103bfa <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103bfa:	55                   	push   %ebp
f0103bfb:	89 e5                	mov    %esp,%ebp
f0103bfd:	53                   	push   %ebx
f0103bfe:	83 ec 14             	sub    $0x14,%esp
f0103c01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103c04:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c07:	83 c8 04             	or     $0x4,%eax
f0103c0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c0e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c11:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c15:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c1c:	89 1c 24             	mov    %ebx,(%esp)
f0103c1f:	e8 02 ff ff ff       	call   f0103b26 <user_mem_check>
f0103c24:	85 c0                	test   %eax,%eax
f0103c26:	79 24                	jns    f0103c4c <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103c28:	a1 44 52 22 f0       	mov    0xf0225244,%eax
f0103c2d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c31:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c38:	c7 04 24 70 7c 10 f0 	movl   $0xf0107c70,(%esp)
f0103c3f:	e8 9a 09 00 00       	call   f01045de <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103c44:	89 1c 24             	mov    %ebx,(%esp)
f0103c47:	e8 b9 06 00 00       	call   f0104305 <env_destroy>
	}
}
f0103c4c:	83 c4 14             	add    $0x14,%esp
f0103c4f:	5b                   	pop    %ebx
f0103c50:	5d                   	pop    %ebp
f0103c51:	c3                   	ret    
	...

f0103c54 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103c54:	55                   	push   %ebp
f0103c55:	89 e5                	mov    %esp,%ebp
f0103c57:	57                   	push   %edi
f0103c58:	56                   	push   %esi
f0103c59:	53                   	push   %ebx
f0103c5a:	83 ec 2c             	sub    $0x2c,%esp
f0103c5d:	89 c7                	mov    %eax,%edi
	//   (Watch out for corner-cases!)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
f0103c5f:	89 d3                	mov    %edx,%ebx
f0103c61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103c67:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0103c6d:	c1 e8 0c             	shr    $0xc,%eax
f0103c70:	85 c0                	test   %eax,%eax
f0103c72:	74 5d                	je     f0103cd1 <region_alloc+0x7d>
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
f0103c74:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103c77:	be 00 00 00 00       	mov    $0x0,%esi
		struct PageInfo *p = page_alloc(0);
f0103c7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103c83:	e8 ce da ff ff       	call   f0101756 <page_alloc>
		if(!p)
f0103c88:	85 c0                	test   %eax,%eax
f0103c8a:	75 1c                	jne    f0103ca8 <region_alloc+0x54>
			panic("region_alloc failed!");
f0103c8c:	c7 44 24 08 d4 7f 10 	movl   $0xf0107fd4,0x8(%esp)
f0103c93:	f0 
f0103c94:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0103c9b:	00 
f0103c9c:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0103ca3:	e8 98 c3 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
f0103ca8:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103caf:	00 
f0103cb0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cb8:	8b 47 60             	mov    0x60(%edi),%eax
f0103cbb:	89 04 24             	mov    %eax,(%esp)
f0103cbe:	e8 77 dd ff ff       	call   f0101a3a <page_insert>

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103cc3:	83 c6 01             	add    $0x1,%esi
f0103cc6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103ccc:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103ccf:	75 ab                	jne    f0103c7c <region_alloc+0x28>
		struct PageInfo *p = page_alloc(0);
		if(!p)
			panic("region_alloc failed!");
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
	}
}
f0103cd1:	83 c4 2c             	add    $0x2c,%esp
f0103cd4:	5b                   	pop    %ebx
f0103cd5:	5e                   	pop    %esi
f0103cd6:	5f                   	pop    %edi
f0103cd7:	5d                   	pop    %ebp
f0103cd8:	c3                   	ret    

f0103cd9 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103cd9:	55                   	push   %ebp
f0103cda:	89 e5                	mov    %esp,%ebp
f0103cdc:	83 ec 18             	sub    $0x18,%esp
f0103cdf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103ce2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103ce5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103ce8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ceb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103cee:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103cf2:	85 c0                	test   %eax,%eax
f0103cf4:	75 17                	jne    f0103d0d <envid2env+0x34>
		*env_store = curenv;
f0103cf6:	e8 95 26 00 00       	call   f0106390 <cpunum>
f0103cfb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cfe:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103d04:	89 06                	mov    %eax,(%esi)
		return 0;
f0103d06:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d0b:	eb 67                	jmp    f0103d74 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103d0d:	89 c3                	mov    %eax,%ebx
f0103d0f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103d15:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103d18:	03 1d 48 52 22 f0    	add    0xf0225248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103d1e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103d22:	74 05                	je     f0103d29 <envid2env+0x50>
f0103d24:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103d27:	74 0d                	je     f0103d36 <envid2env+0x5d>
		*env_store = 0;
f0103d29:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103d2f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d34:	eb 3e                	jmp    f0103d74 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103d36:	84 d2                	test   %dl,%dl
f0103d38:	74 33                	je     f0103d6d <envid2env+0x94>
f0103d3a:	e8 51 26 00 00       	call   f0106390 <cpunum>
f0103d3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d42:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0103d48:	74 23                	je     f0103d6d <envid2env+0x94>
f0103d4a:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103d4d:	e8 3e 26 00 00       	call   f0106390 <cpunum>
f0103d52:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d55:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103d5b:	3b 78 48             	cmp    0x48(%eax),%edi
f0103d5e:	74 0d                	je     f0103d6d <envid2env+0x94>
		*env_store = 0;
f0103d60:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103d66:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103d6b:	eb 07                	jmp    f0103d74 <envid2env+0x9b>
	}

	*env_store = e;
f0103d6d:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103d77:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103d7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103d7d:	89 ec                	mov    %ebp,%esp
f0103d7f:	5d                   	pop    %ebp
f0103d80:	c3                   	ret    

f0103d81 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103d81:	55                   	push   %ebp
f0103d82:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103d84:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103d89:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103d8c:	b8 23 00 00 00       	mov    $0x23,%eax
f0103d91:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103d93:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103d95:	b0 10                	mov    $0x10,%al
f0103d97:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103d99:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103d9b:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103d9d:	ea a4 3d 10 f0 08 00 	ljmp   $0x8,$0xf0103da4
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103da4:	b0 00                	mov    $0x0,%al
f0103da6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103da9:	5d                   	pop    %ebp
f0103daa:	c3                   	ret    

f0103dab <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103dab:	55                   	push   %ebp
f0103dac:	89 e5                	mov    %esp,%ebp
f0103dae:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	envs[0].env_id = 0;
f0103daf:	8b 15 48 52 22 f0    	mov    0xf0225248,%edx
f0103db5:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
	env_free_list = envs;
f0103dbc:	89 15 4c 52 22 f0    	mov    %edx,0xf022524c
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103dc2:	8d 42 7c             	lea    0x7c(%edx),%eax
f0103dc5:	8d 9a 00 f0 01 00    	lea    0x1f000(%edx),%ebx
f0103dcb:	eb 02                	jmp    f0103dcf <env_init+0x24>

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
		_env->env_link = &envs[i];
		_env = _env->env_link;
f0103dcd:	89 ca                	mov    %ecx,%edx
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
f0103dcf:	89 c1                	mov    %eax,%ecx
f0103dd1:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		_env->env_link = &envs[i];
f0103dd8:	89 42 44             	mov    %eax,0x44(%edx)
f0103ddb:	83 c0 7c             	add    $0x7c,%eax
	envs[0].env_id = 0;
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
f0103dde:	39 d8                	cmp    %ebx,%eax
f0103de0:	75 eb                	jne    f0103dcd <env_init+0x22>
		_env->env_link = &envs[i];
		_env = _env->env_link;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103de2:	e8 9a ff ff ff       	call   f0103d81 <env_init_percpu>
}
f0103de7:	5b                   	pop    %ebx
f0103de8:	5d                   	pop    %ebp
f0103de9:	c3                   	ret    

f0103dea <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103dea:	55                   	push   %ebp
f0103deb:	89 e5                	mov    %esp,%ebp
f0103ded:	53                   	push   %ebx
f0103dee:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103df1:	8b 1d 4c 52 22 f0    	mov    0xf022524c,%ebx
f0103df7:	85 db                	test   %ebx,%ebx
f0103df9:	0f 84 87 01 00 00    	je     f0103f86 <env_alloc+0x19c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103dff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103e06:	e8 4b d9 ff ff       	call   f0101756 <page_alloc>
f0103e0b:	85 c0                	test   %eax,%eax
f0103e0d:	0f 84 7a 01 00 00    	je     f0103f8d <env_alloc+0x1a3>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	/*************************** LAB 3: Your code here.***************************/
	p->pp_ref ++;
f0103e13:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103e18:	2b 05 f0 5e 22 f0    	sub    0xf0225ef0,%eax
f0103e1e:	c1 f8 03             	sar    $0x3,%eax
f0103e21:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e24:	89 c2                	mov    %eax,%edx
f0103e26:	c1 ea 0c             	shr    $0xc,%edx
f0103e29:	3b 15 e8 5e 22 f0    	cmp    0xf0225ee8,%edx
f0103e2f:	72 20                	jb     f0103e51 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103e31:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e35:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0103e3c:	f0 
f0103e3d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
f0103e44:	00 
f0103e45:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0103e4c:	e8 ef c1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103e51:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103e56:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103e59:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103e60:	00 
f0103e61:	8b 15 ec 5e 22 f0    	mov    0xf0225eec,%edx
f0103e67:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e6b:	89 04 24             	mov    %eax,(%esp)
f0103e6e:	e8 62 1f 00 00       	call   f0105dd5 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103e73:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e76:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e7b:	77 20                	ja     f0103e9d <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e81:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0103e88:	f0 
f0103e89:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0103e90:	00 
f0103e91:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0103e98:	e8 a3 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e9d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103ea3:	83 ca 05             	or     $0x5,%edx
f0103ea6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103eac:	8b 43 48             	mov    0x48(%ebx),%eax
f0103eaf:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103eb4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103eb9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103ebe:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103ec1:	89 da                	mov    %ebx,%edx
f0103ec3:	2b 15 48 52 22 f0    	sub    0xf0225248,%edx
f0103ec9:	c1 fa 02             	sar    $0x2,%edx
f0103ecc:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103ed2:	09 d0                	or     %edx,%eax
f0103ed4:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103eda:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103edd:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103ee4:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103eeb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103ef2:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103ef9:	00 
f0103efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103f01:	00 
f0103f02:	89 1c 24             	mov    %ebx,(%esp)
f0103f05:	e8 f7 1d 00 00       	call   f0105d01 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103f0a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103f10:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103f16:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103f1c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103f23:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103f29:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103f30:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103f34:	8b 43 44             	mov    0x44(%ebx),%eax
f0103f37:	a3 4c 52 22 f0       	mov    %eax,0xf022524c
	*newenv_store = e;
f0103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f3f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f41:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103f44:	e8 47 24 00 00       	call   f0106390 <cpunum>
f0103f49:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f4c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f51:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0103f58:	74 11                	je     f0103f6b <env_alloc+0x181>
f0103f5a:	e8 31 24 00 00       	call   f0106390 <cpunum>
f0103f5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f62:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0103f68:	8b 50 48             	mov    0x48(%eax),%edx
f0103f6b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f6f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103f73:	c7 04 24 f4 7f 10 f0 	movl   $0xf0107ff4,(%esp)
f0103f7a:	e8 5f 06 00 00       	call   f01045de <cprintf>
	return 0;
f0103f7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f84:	eb 0c                	jmp    f0103f92 <env_alloc+0x1a8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103f86:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103f8b:	eb 05                	jmp    f0103f92 <env_alloc+0x1a8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103f8d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103f92:	83 c4 14             	add    $0x14,%esp
f0103f95:	5b                   	pop    %ebx
f0103f96:	5d                   	pop    %ebp
f0103f97:	c3                   	ret    

f0103f98 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103f98:	55                   	push   %ebp
f0103f99:	89 e5                	mov    %esp,%ebp
f0103f9b:	57                   	push   %edi
f0103f9c:	56                   	push   %esi
f0103f9d:	53                   	push   %ebx
f0103f9e:	83 ec 3c             	sub    $0x3c,%esp
f0103fa1:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int res;
	if ((res = env_alloc(&env, 0)))
f0103fa4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fab:	00 
f0103fac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103faf:	89 04 24             	mov    %eax,(%esp)
f0103fb2:	e8 33 fe ff ff       	call   f0103dea <env_alloc>
f0103fb7:	85 c0                	test   %eax,%eax
f0103fb9:	74 20                	je     f0103fdb <env_create+0x43>
		panic("env_create: %e", res);
f0103fbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fbf:	c7 44 24 08 09 80 10 	movl   $0xf0108009,0x8(%esp)
f0103fc6:	f0 
f0103fc7:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0103fce:	00 
f0103fcf:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0103fd6:	e8 65 c0 ff ff       	call   f0100040 <_panic>

	load_icode(env, binary, size);
f0103fdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103fde:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f0103fe1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103fe7:	74 1c                	je     f0104005 <env_create+0x6d>
		panic("Invalid ELF!");
f0103fe9:	c7 44 24 08 18 80 10 	movl   $0xf0108018,0x8(%esp)
f0103ff0:	f0 
f0103ff1:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
f0103ff8:	00 
f0103ff9:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0104000:	e8 3b c0 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104005:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0104008:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
f010400c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010400f:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104012:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104017:	77 20                	ja     f0104039 <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104019:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010401d:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0104024:	f0 
f0104025:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f010402c:	00 
f010402d:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0104034:	e8 07 c0 ff ff       	call   f0100040 <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
		panic("Invalid ELF!");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0104039:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f010403b:	0f b7 f6             	movzwl %si,%esi
f010403e:	c1 e6 05             	shl    $0x5,%esi
f0104041:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f0104043:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104048:	0f 22 d8             	mov    %eax,%cr3

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f010404b:	39 f3                	cmp    %esi,%ebx
f010404d:	73 4f                	jae    f010409e <env_create+0x106>
		if (ph->p_type != ELF_PROG_LOAD)
f010404f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0104052:	75 43                	jne    f0104097 <env_create+0xff>
			continue;
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0104054:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0104057:	8b 53 08             	mov    0x8(%ebx),%edx
f010405a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010405d:	e8 f2 fb ff ff       	call   f0103c54 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f0104062:	8b 43 14             	mov    0x14(%ebx),%eax
f0104065:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104069:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104070:	00 
f0104071:	8b 43 08             	mov    0x8(%ebx),%eax
f0104074:	89 04 24             	mov    %eax,(%esp)
f0104077:	e8 85 1c 00 00       	call   f0105d01 <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010407c:	8b 43 10             	mov    0x10(%ebx),%eax
f010407f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104083:	89 f8                	mov    %edi,%eax
f0104085:	03 43 04             	add    0x4(%ebx),%eax
f0104088:	89 44 24 04          	mov    %eax,0x4(%esp)
f010408c:	8b 43 08             	mov    0x8(%ebx),%eax
f010408f:	89 04 24             	mov    %eax,(%esp)
f0104092:	e8 c5 1c 00 00       	call   f0105d5c <memmove>
	eph = ph + elf->e_phnum;

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f0104097:	83 c3 20             	add    $0x20,%ebx
f010409a:	39 de                	cmp    %ebx,%esi
f010409c:	77 b1                	ja     f010404f <env_create+0xb7>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
		memset((void*)ph->p_va, 0, ph->p_memsz);
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}
	// switch back to kernel page directory
	lcr3(PADDR(kern_pgdir));
f010409e:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01040a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01040a8:	77 20                	ja     f01040ca <env_create+0x132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040ae:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01040b5:	f0 
f01040b6:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f01040bd:	00 
f01040be:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f01040c5:	e8 76 bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01040ca:	05 00 00 00 10       	add    $0x10000000,%eax
f01040cf:	0f 22 d8             	mov    %eax,%cr3

	(e->env_tf).tf_eip = (uintptr_t)(elf->e_entry);
f01040d2:	8b 47 18             	mov    0x18(%edi),%eax
f01040d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01040d8:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f01040db:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01040e0:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01040e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040e8:	e8 67 fb ff ff       	call   f0103c54 <region_alloc>
	if ((res = env_alloc(&env, 0)))
		panic("env_create: %e", res);

	load_icode(env, binary, size);

	env->env_type = type;
f01040ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040f0:	8b 55 10             	mov    0x10(%ebp),%edx
f01040f3:	89 50 50             	mov    %edx,0x50(%eax)
}
f01040f6:	83 c4 3c             	add    $0x3c,%esp
f01040f9:	5b                   	pop    %ebx
f01040fa:	5e                   	pop    %esi
f01040fb:	5f                   	pop    %edi
f01040fc:	5d                   	pop    %ebp
f01040fd:	c3                   	ret    

f01040fe <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01040fe:	55                   	push   %ebp
f01040ff:	89 e5                	mov    %esp,%ebp
f0104101:	57                   	push   %edi
f0104102:	56                   	push   %esi
f0104103:	53                   	push   %ebx
f0104104:	83 ec 2c             	sub    $0x2c,%esp
f0104107:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010410a:	e8 81 22 00 00       	call   f0106390 <cpunum>
f010410f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104112:	39 b8 28 60 22 f0    	cmp    %edi,-0xfdd9fd8(%eax)
f0104118:	75 34                	jne    f010414e <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f010411a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010411f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104124:	77 20                	ja     f0104146 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104126:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010412a:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0104131:	f0 
f0104132:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0104139:	00 
f010413a:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0104141:	e8 fa be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104146:	05 00 00 00 10       	add    $0x10000000,%eax
f010414b:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010414e:	8b 5f 48             	mov    0x48(%edi),%ebx
f0104151:	e8 3a 22 00 00       	call   f0106390 <cpunum>
f0104156:	6b d0 74             	imul   $0x74,%eax,%edx
f0104159:	b8 00 00 00 00       	mov    $0x0,%eax
f010415e:	83 ba 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%edx)
f0104165:	74 11                	je     f0104178 <env_free+0x7a>
f0104167:	e8 24 22 00 00       	call   f0106390 <cpunum>
f010416c:	6b c0 74             	imul   $0x74,%eax,%eax
f010416f:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104175:	8b 40 48             	mov    0x48(%eax),%eax
f0104178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010417c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104180:	c7 04 24 25 80 10 f0 	movl   $0xf0108025,(%esp)
f0104187:	e8 52 04 00 00       	call   f01045de <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010418c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0104193:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104196:	c1 e0 02             	shl    $0x2,%eax
f0104199:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010419c:	8b 47 60             	mov    0x60(%edi),%eax
f010419f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041a2:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01041a5:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01041ab:	0f 84 b8 00 00 00    	je     f0104269 <env_free+0x16b>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01041b1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01041b7:	89 f0                	mov    %esi,%eax
f01041b9:	c1 e8 0c             	shr    $0xc,%eax
f01041bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01041bf:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f01041c5:	72 20                	jb     f01041e7 <env_free+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01041c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01041cb:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01041d2:	f0 
f01041d3:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f01041da:	00 
f01041db:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f01041e2:	e8 59 be ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01041e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041ea:	c1 e2 16             	shl    $0x16,%edx
f01041ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01041f0:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01041f5:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01041fc:	01 
f01041fd:	74 17                	je     f0104216 <env_free+0x118>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01041ff:	89 d8                	mov    %ebx,%eax
f0104201:	c1 e0 0c             	shl    $0xc,%eax
f0104204:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0104207:	89 44 24 04          	mov    %eax,0x4(%esp)
f010420b:	8b 47 60             	mov    0x60(%edi),%eax
f010420e:	89 04 24             	mov    %eax,(%esp)
f0104211:	e8 d4 d7 ff ff       	call   f01019ea <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104216:	83 c3 01             	add    $0x1,%ebx
f0104219:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010421f:	75 d4                	jne    f01041f5 <env_free+0xf7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104221:	8b 47 60             	mov    0x60(%edi),%eax
f0104224:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104227:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010422e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104231:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f0104237:	72 1c                	jb     f0104255 <env_free+0x157>
		panic("pa2page called with invalid pa");
f0104239:	c7 44 24 08 34 74 10 	movl   $0xf0107434,0x8(%esp)
f0104240:	f0 
f0104241:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0104248:	00 
f0104249:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f0104250:	e8 eb bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104255:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104258:	c1 e0 03             	shl    $0x3,%eax
f010425b:	03 05 f0 5e 22 f0    	add    0xf0225ef0,%eax
		page_decref(pa2page(pa));
f0104261:	89 04 24             	mov    %eax,(%esp)
f0104264:	e8 a3 d5 ff ff       	call   f010180c <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104269:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010426d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104274:	0f 85 19 ff ff ff    	jne    f0104193 <env_free+0x95>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010427a:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010427d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104282:	77 20                	ja     f01042a4 <env_free+0x1a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104284:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104288:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f010428f:	f0 
f0104290:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f0104297:	00 
f0104298:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f010429f:	e8 9c bd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01042a4:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01042ab:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01042b0:	c1 e8 0c             	shr    $0xc,%eax
f01042b3:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f01042b9:	72 1c                	jb     f01042d7 <env_free+0x1d9>
		panic("pa2page called with invalid pa");
f01042bb:	c7 44 24 08 34 74 10 	movl   $0xf0107434,0x8(%esp)
f01042c2:	f0 
f01042c3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01042ca:	00 
f01042cb:	c7 04 24 cd 7c 10 f0 	movl   $0xf0107ccd,(%esp)
f01042d2:	e8 69 bd ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01042d7:	c1 e0 03             	shl    $0x3,%eax
f01042da:	03 05 f0 5e 22 f0    	add    0xf0225ef0,%eax
	page_decref(pa2page(pa));
f01042e0:	89 04 24             	mov    %eax,(%esp)
f01042e3:	e8 24 d5 ff ff       	call   f010180c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01042e8:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01042ef:	a1 4c 52 22 f0       	mov    0xf022524c,%eax
f01042f4:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01042f7:	89 3d 4c 52 22 f0    	mov    %edi,0xf022524c
}
f01042fd:	83 c4 2c             	add    $0x2c,%esp
f0104300:	5b                   	pop    %ebx
f0104301:	5e                   	pop    %esi
f0104302:	5f                   	pop    %edi
f0104303:	5d                   	pop    %ebp
f0104304:	c3                   	ret    

f0104305 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104305:	55                   	push   %ebp
f0104306:	89 e5                	mov    %esp,%ebp
f0104308:	53                   	push   %ebx
f0104309:	83 ec 14             	sub    $0x14,%esp
f010430c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010430f:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0104313:	75 19                	jne    f010432e <env_destroy+0x29>
f0104315:	e8 76 20 00 00       	call   f0106390 <cpunum>
f010431a:	6b c0 74             	imul   $0x74,%eax,%eax
f010431d:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0104323:	74 09                	je     f010432e <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0104325:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010432c:	eb 2f                	jmp    f010435d <env_destroy+0x58>
	}

	env_free(e);
f010432e:	89 1c 24             	mov    %ebx,(%esp)
f0104331:	e8 c8 fd ff ff       	call   f01040fe <env_free>

	if (curenv == e) {
f0104336:	e8 55 20 00 00       	call   f0106390 <cpunum>
f010433b:	6b c0 74             	imul   $0x74,%eax,%eax
f010433e:	39 98 28 60 22 f0    	cmp    %ebx,-0xfdd9fd8(%eax)
f0104344:	75 17                	jne    f010435d <env_destroy+0x58>
		curenv = NULL;
f0104346:	e8 45 20 00 00       	call   f0106390 <cpunum>
f010434b:	6b c0 74             	imul   $0x74,%eax,%eax
f010434e:	c7 80 28 60 22 f0 00 	movl   $0x0,-0xfdd9fd8(%eax)
f0104355:	00 00 00 
		sched_yield();
f0104358:	e8 43 0a 00 00       	call   f0104da0 <sched_yield>
	}
}
f010435d:	83 c4 14             	add    $0x14,%esp
f0104360:	5b                   	pop    %ebx
f0104361:	5d                   	pop    %ebp
f0104362:	c3                   	ret    

f0104363 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104363:	55                   	push   %ebp
f0104364:	89 e5                	mov    %esp,%ebp
f0104366:	53                   	push   %ebx
f0104367:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010436a:	e8 21 20 00 00       	call   f0106390 <cpunum>
f010436f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104372:	8b 98 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%ebx
f0104378:	e8 13 20 00 00       	call   f0106390 <cpunum>
f010437d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104380:	8b 65 08             	mov    0x8(%ebp),%esp
f0104383:	61                   	popa   
f0104384:	07                   	pop    %es
f0104385:	1f                   	pop    %ds
f0104386:	83 c4 08             	add    $0x8,%esp
f0104389:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010438a:	c7 44 24 08 3b 80 10 	movl   $0xf010803b,0x8(%esp)
f0104391:	f0 
f0104392:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
f0104399:	00 
f010439a:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f01043a1:	e8 9a bc ff ff       	call   f0100040 <_panic>

f01043a6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01043a6:	55                   	push   %ebp
f01043a7:	89 e5                	mov    %esp,%ebp
f01043a9:	83 ec 18             	sub    $0x18,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv && curenv->env_status == ENV_RUNNING) {
f01043ac:	e8 df 1f 00 00       	call   f0106390 <cpunum>
f01043b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b4:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f01043bb:	74 29                	je     f01043e6 <env_run+0x40>
f01043bd:	e8 ce 1f 00 00       	call   f0106390 <cpunum>
f01043c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01043c5:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01043cb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01043cf:	75 15                	jne    f01043e6 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f01043d1:	e8 ba 1f 00 00       	call   f0106390 <cpunum>
f01043d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d9:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01043df:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f01043e6:	e8 a5 1f 00 00       	call   f0106390 <cpunum>
f01043eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ee:	8b 55 08             	mov    0x8(%ebp),%edx
f01043f1:	89 90 28 60 22 f0    	mov    %edx,-0xfdd9fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f01043f7:	e8 94 1f 00 00       	call   f0106390 <cpunum>
f01043fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ff:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104405:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs ++;
f010440c:	e8 7f 1f 00 00       	call   f0106390 <cpunum>
f0104411:	6b c0 74             	imul   $0x74,%eax,%eax
f0104414:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f010441a:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f010441e:	e8 6d 1f 00 00       	call   f0106390 <cpunum>
f0104423:	6b c0 74             	imul   $0x74,%eax,%eax
f0104426:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f010442c:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010442f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104434:	77 20                	ja     f0104456 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104436:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010443a:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0104441:	f0 
f0104442:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
f0104449:	00 
f010444a:	c7 04 24 e9 7f 10 f0 	movl   $0xf0107fe9,(%esp)
f0104451:	e8 ea bb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104456:	05 00 00 00 10       	add    $0x10000000,%eax
f010445b:	0f 22 d8             	mov    %eax,%cr3

	env_pop_tf(&(curenv->env_tf));
f010445e:	e8 2d 1f 00 00       	call   f0106390 <cpunum>
f0104463:	6b c0 74             	imul   $0x74,%eax,%eax
f0104466:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f010446c:	89 04 24             	mov    %eax,(%esp)
f010446f:	e8 ef fe ff ff       	call   f0104363 <env_pop_tf>

f0104474 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104474:	55                   	push   %ebp
f0104475:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104477:	ba 70 00 00 00       	mov    $0x70,%edx
f010447c:	8b 45 08             	mov    0x8(%ebp),%eax
f010447f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104480:	b2 71                	mov    $0x71,%dl
f0104482:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104483:	0f b6 c0             	movzbl %al,%eax
}
f0104486:	5d                   	pop    %ebp
f0104487:	c3                   	ret    

f0104488 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104488:	55                   	push   %ebp
f0104489:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010448b:	ba 70 00 00 00       	mov    $0x70,%edx
f0104490:	8b 45 08             	mov    0x8(%ebp),%eax
f0104493:	ee                   	out    %al,(%dx)
f0104494:	b2 71                	mov    $0x71,%dl
f0104496:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104499:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010449a:	5d                   	pop    %ebp
f010449b:	c3                   	ret    

f010449c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010449c:	55                   	push   %ebp
f010449d:	89 e5                	mov    %esp,%ebp
f010449f:	56                   	push   %esi
f01044a0:	53                   	push   %ebx
f01044a1:	83 ec 10             	sub    $0x10,%esp
f01044a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01044a7:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01044a9:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01044af:	80 3d 50 52 22 f0 00 	cmpb   $0x0,0xf0225250
f01044b6:	74 4e                	je     f0104506 <irq_setmask_8259A+0x6a>
f01044b8:	ba 21 00 00 00       	mov    $0x21,%edx
f01044bd:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01044be:	89 f0                	mov    %esi,%eax
f01044c0:	66 c1 e8 08          	shr    $0x8,%ax
f01044c4:	b2 a1                	mov    $0xa1,%dl
f01044c6:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01044c7:	c7 04 24 47 80 10 f0 	movl   $0xf0108047,(%esp)
f01044ce:	e8 0b 01 00 00       	call   f01045de <cprintf>
	for (i = 0; i < 16; i++)
f01044d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01044d8:	0f b7 f6             	movzwl %si,%esi
f01044db:	f7 d6                	not    %esi
f01044dd:	0f a3 de             	bt     %ebx,%esi
f01044e0:	73 10                	jae    f01044f2 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01044e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044e6:	c7 04 24 52 85 10 f0 	movl   $0xf0108552,(%esp)
f01044ed:	e8 ec 00 00 00       	call   f01045de <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01044f2:	83 c3 01             	add    $0x1,%ebx
f01044f5:	83 fb 10             	cmp    $0x10,%ebx
f01044f8:	75 e3                	jne    f01044dd <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01044fa:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f0104501:	e8 d8 00 00 00       	call   f01045de <cprintf>
}
f0104506:	83 c4 10             	add    $0x10,%esp
f0104509:	5b                   	pop    %ebx
f010450a:	5e                   	pop    %esi
f010450b:	5d                   	pop    %ebp
f010450c:	c3                   	ret    

f010450d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010450d:	55                   	push   %ebp
f010450e:	89 e5                	mov    %esp,%ebp
f0104510:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104513:	c6 05 50 52 22 f0 01 	movb   $0x1,0xf0225250
f010451a:	ba 21 00 00 00       	mov    $0x21,%edx
f010451f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104524:	ee                   	out    %al,(%dx)
f0104525:	b2 a1                	mov    $0xa1,%dl
f0104527:	ee                   	out    %al,(%dx)
f0104528:	b2 20                	mov    $0x20,%dl
f010452a:	b8 11 00 00 00       	mov    $0x11,%eax
f010452f:	ee                   	out    %al,(%dx)
f0104530:	b2 21                	mov    $0x21,%dl
f0104532:	b8 20 00 00 00       	mov    $0x20,%eax
f0104537:	ee                   	out    %al,(%dx)
f0104538:	b8 04 00 00 00       	mov    $0x4,%eax
f010453d:	ee                   	out    %al,(%dx)
f010453e:	b8 03 00 00 00       	mov    $0x3,%eax
f0104543:	ee                   	out    %al,(%dx)
f0104544:	b2 a0                	mov    $0xa0,%dl
f0104546:	b8 11 00 00 00       	mov    $0x11,%eax
f010454b:	ee                   	out    %al,(%dx)
f010454c:	b2 a1                	mov    $0xa1,%dl
f010454e:	b8 28 00 00 00       	mov    $0x28,%eax
f0104553:	ee                   	out    %al,(%dx)
f0104554:	b8 02 00 00 00       	mov    $0x2,%eax
f0104559:	ee                   	out    %al,(%dx)
f010455a:	b8 01 00 00 00       	mov    $0x1,%eax
f010455f:	ee                   	out    %al,(%dx)
f0104560:	b2 20                	mov    $0x20,%dl
f0104562:	b8 68 00 00 00       	mov    $0x68,%eax
f0104567:	ee                   	out    %al,(%dx)
f0104568:	b8 0a 00 00 00       	mov    $0xa,%eax
f010456d:	ee                   	out    %al,(%dx)
f010456e:	b2 a0                	mov    $0xa0,%dl
f0104570:	b8 68 00 00 00       	mov    $0x68,%eax
f0104575:	ee                   	out    %al,(%dx)
f0104576:	b8 0a 00 00 00       	mov    $0xa,%eax
f010457b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010457c:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0104583:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104587:	74 0b                	je     f0104594 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0104589:	0f b7 c0             	movzwl %ax,%eax
f010458c:	89 04 24             	mov    %eax,(%esp)
f010458f:	e8 08 ff ff ff       	call   f010449c <irq_setmask_8259A>
}
f0104594:	c9                   	leave  
f0104595:	c3                   	ret    
	...

f0104598 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104598:	55                   	push   %ebp
f0104599:	89 e5                	mov    %esp,%ebp
f010459b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010459e:	8b 45 08             	mov    0x8(%ebp),%eax
f01045a1:	89 04 24             	mov    %eax,(%esp)
f01045a4:	e8 d0 c1 ff ff       	call   f0100779 <cputchar>
	*cnt++;
}
f01045a9:	c9                   	leave  
f01045aa:	c3                   	ret    

f01045ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01045ab:	55                   	push   %ebp
f01045ac:	89 e5                	mov    %esp,%ebp
f01045ae:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01045b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01045b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045cd:	c7 04 24 98 45 10 f0 	movl   $0xf0104598,(%esp)
f01045d4:	e8 e5 0e 00 00       	call   f01054be <vprintfmt>
	return cnt;
}
f01045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045dc:	c9                   	leave  
f01045dd:	c3                   	ret    

f01045de <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01045de:	55                   	push   %ebp
f01045df:	89 e5                	mov    %esp,%ebp
f01045e1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01045e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01045e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ee:	89 04 24             	mov    %eax,(%esp)
f01045f1:	e8 b5 ff ff ff       	call   f01045ab <vcprintf>
	va_end(ap);

	return cnt;
}
f01045f6:	c9                   	leave  
f01045f7:	c3                   	ret    
	...

f0104600 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104600:	55                   	push   %ebp
f0104601:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0104603:	c7 05 64 5a 22 f0 00 	movl   $0xf0000000,0xf0225a64
f010460a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010460d:	66 c7 05 68 5a 22 f0 	movw   $0x10,0xf0225a68
f0104614:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0104616:	66 c7 05 68 23 12 f0 	movw   $0x68,0xf0122368
f010461d:	68 00 
f010461f:	b8 60 5a 22 f0       	mov    $0xf0225a60,%eax
f0104624:	66 a3 6a 23 12 f0    	mov    %ax,0xf012236a
f010462a:	89 c2                	mov    %eax,%edx
f010462c:	c1 ea 10             	shr    $0x10,%edx
f010462f:	88 15 6c 23 12 f0    	mov    %dl,0xf012236c
f0104635:	c6 05 6e 23 12 f0 40 	movb   $0x40,0xf012236e
f010463c:	c1 e8 18             	shr    $0x18,%eax
f010463f:	a2 6f 23 12 f0       	mov    %al,0xf012236f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0104644:	c6 05 6d 23 12 f0 89 	movb   $0x89,0xf012236d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010464b:	b8 28 00 00 00       	mov    $0x28,%eax
f0104650:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104653:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0104658:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010465b:	5d                   	pop    %ebp
f010465c:	c3                   	ret    

f010465d <trap_init>:
}


void
trap_init(void)
{
f010465d:	55                   	push   %ebp
f010465e:	89 e5                	mov    %esp,%ebp
f0104660:	53                   	push   %ebx
f0104661:	b9 01 00 00 00       	mov    $0x1,%ecx
f0104666:	b8 00 00 00 00       	mov    $0x0,%eax
f010466b:	eb 06                	jmp    f0104673 <trap_init+0x16>
f010466d:	83 c0 01             	add    $0x1,%eax
f0104670:	83 c1 01             	add    $0x1,%ecx

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
		if (i==T_BRKPT)
f0104673:	83 f8 03             	cmp    $0x3,%eax
f0104676:	75 30                	jne    f01046a8 <trap_init+0x4b>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f0104678:	8b 15 c0 23 12 f0    	mov    0xf01223c0,%edx
f010467e:	66 89 15 78 52 22 f0 	mov    %dx,0xf0225278
f0104685:	66 c7 05 7a 52 22 f0 	movw   $0x8,0xf022527a
f010468c:	08 00 
f010468e:	c6 05 7c 52 22 f0 00 	movb   $0x0,0xf022527c
f0104695:	c6 05 7d 52 22 f0 ee 	movb   $0xee,0xf022527d
f010469c:	c1 ea 10             	shr    $0x10,%edx
f010469f:	66 89 15 7e 52 22 f0 	mov    %dx,0xf022527e
f01046a6:	eb c5                	jmp    f010466d <trap_init+0x10>
		else if (i!=2 && i!=15) {
f01046a8:	83 f8 02             	cmp    $0x2,%eax
f01046ab:	74 39                	je     f01046e6 <trap_init+0x89>
f01046ad:	83 f8 0f             	cmp    $0xf,%eax
f01046b0:	74 34                	je     f01046e6 <trap_init+0x89>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f01046b2:	8b 1c 85 b4 23 12 f0 	mov    -0xfeddc4c(,%eax,4),%ebx
f01046b9:	66 89 1c c5 60 52 22 	mov    %bx,-0xfddada0(,%eax,8)
f01046c0:	f0 
f01046c1:	66 c7 04 c5 62 52 22 	movw   $0x8,-0xfddad9e(,%eax,8)
f01046c8:	f0 08 00 
f01046cb:	c6 04 c5 64 52 22 f0 	movb   $0x0,-0xfddad9c(,%eax,8)
f01046d2:	00 
f01046d3:	c6 04 c5 65 52 22 f0 	movb   $0x8e,-0xfddad9b(,%eax,8)
f01046da:	8e 
f01046db:	c1 eb 10             	shr    $0x10,%ebx
f01046de:	66 89 1c c5 66 52 22 	mov    %bx,-0xfddad9a(,%eax,8)
f01046e5:	f0 
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
f01046e6:	83 f9 10             	cmp    $0x10,%ecx
f01046e9:	7e 82                	jle    f010466d <trap_init+0x10>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f01046eb:	a1 74 24 12 f0       	mov    0xf0122474,%eax
f01046f0:	66 a3 e0 53 22 f0    	mov    %ax,0xf02253e0
f01046f6:	66 c7 05 e2 53 22 f0 	movw   $0x8,0xf02253e2
f01046fd:	08 00 
f01046ff:	c6 05 e4 53 22 f0 00 	movb   $0x0,0xf02253e4
f0104706:	c6 05 e5 53 22 f0 ee 	movb   $0xee,0xf02253e5
f010470d:	c1 e8 10             	shr    $0x10,%eax
f0104710:	66 a3 e6 53 22 f0    	mov    %ax,0xf02253e6

	// Per-CPU setup 
	trap_init_percpu();
f0104716:	e8 e5 fe ff ff       	call   f0104600 <trap_init_percpu>
}
f010471b:	5b                   	pop    %ebx
f010471c:	5d                   	pop    %ebp
f010471d:	c3                   	ret    

f010471e <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010471e:	55                   	push   %ebp
f010471f:	89 e5                	mov    %esp,%ebp
f0104721:	53                   	push   %ebx
f0104722:	83 ec 14             	sub    $0x14,%esp
f0104725:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104728:	8b 03                	mov    (%ebx),%eax
f010472a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010472e:	c7 04 24 5b 80 10 f0 	movl   $0xf010805b,(%esp)
f0104735:	e8 a4 fe ff ff       	call   f01045de <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010473a:	8b 43 04             	mov    0x4(%ebx),%eax
f010473d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104741:	c7 04 24 6a 80 10 f0 	movl   $0xf010806a,(%esp)
f0104748:	e8 91 fe ff ff       	call   f01045de <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010474d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104750:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104754:	c7 04 24 79 80 10 f0 	movl   $0xf0108079,(%esp)
f010475b:	e8 7e fe ff ff       	call   f01045de <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104760:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104763:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104767:	c7 04 24 88 80 10 f0 	movl   $0xf0108088,(%esp)
f010476e:	e8 6b fe ff ff       	call   f01045de <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104773:	8b 43 10             	mov    0x10(%ebx),%eax
f0104776:	89 44 24 04          	mov    %eax,0x4(%esp)
f010477a:	c7 04 24 97 80 10 f0 	movl   $0xf0108097,(%esp)
f0104781:	e8 58 fe ff ff       	call   f01045de <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104786:	8b 43 14             	mov    0x14(%ebx),%eax
f0104789:	89 44 24 04          	mov    %eax,0x4(%esp)
f010478d:	c7 04 24 a6 80 10 f0 	movl   $0xf01080a6,(%esp)
f0104794:	e8 45 fe ff ff       	call   f01045de <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104799:	8b 43 18             	mov    0x18(%ebx),%eax
f010479c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047a0:	c7 04 24 b5 80 10 f0 	movl   $0xf01080b5,(%esp)
f01047a7:	e8 32 fe ff ff       	call   f01045de <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01047ac:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01047af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047b3:	c7 04 24 c4 80 10 f0 	movl   $0xf01080c4,(%esp)
f01047ba:	e8 1f fe ff ff       	call   f01045de <cprintf>
}
f01047bf:	83 c4 14             	add    $0x14,%esp
f01047c2:	5b                   	pop    %ebx
f01047c3:	5d                   	pop    %ebp
f01047c4:	c3                   	ret    

f01047c5 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01047c5:	55                   	push   %ebp
f01047c6:	89 e5                	mov    %esp,%ebp
f01047c8:	56                   	push   %esi
f01047c9:	53                   	push   %ebx
f01047ca:	83 ec 10             	sub    $0x10,%esp
f01047cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01047d0:	e8 bb 1b 00 00       	call   f0106390 <cpunum>
f01047d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047dd:	c7 04 24 28 81 10 f0 	movl   $0xf0108128,(%esp)
f01047e4:	e8 f5 fd ff ff       	call   f01045de <cprintf>
	print_regs(&tf->tf_regs);
f01047e9:	89 1c 24             	mov    %ebx,(%esp)
f01047ec:	e8 2d ff ff ff       	call   f010471e <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01047f1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01047f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f9:	c7 04 24 46 81 10 f0 	movl   $0xf0108146,(%esp)
f0104800:	e8 d9 fd ff ff       	call   f01045de <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104805:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104809:	89 44 24 04          	mov    %eax,0x4(%esp)
f010480d:	c7 04 24 59 81 10 f0 	movl   $0xf0108159,(%esp)
f0104814:	e8 c5 fd ff ff       	call   f01045de <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104819:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010481c:	83 f8 13             	cmp    $0x13,%eax
f010481f:	77 09                	ja     f010482a <print_trapframe+0x65>
		return excnames[trapno];
f0104821:	8b 14 85 20 84 10 f0 	mov    -0xfef7be0(,%eax,4),%edx
f0104828:	eb 1d                	jmp    f0104847 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
		return "System call";
f010482a:	ba d3 80 10 f0       	mov    $0xf01080d3,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f010482f:	83 f8 30             	cmp    $0x30,%eax
f0104832:	74 13                	je     f0104847 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104834:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104837:	83 fa 0f             	cmp    $0xf,%edx
f010483a:	ba df 80 10 f0       	mov    $0xf01080df,%edx
f010483f:	b9 f2 80 10 f0       	mov    $0xf01080f2,%ecx
f0104844:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104847:	89 54 24 08          	mov    %edx,0x8(%esp)
f010484b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010484f:	c7 04 24 6c 81 10 f0 	movl   $0xf010816c,(%esp)
f0104856:	e8 83 fd ff ff       	call   f01045de <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010485b:	3b 1d c8 5a 22 f0    	cmp    0xf0225ac8,%ebx
f0104861:	75 19                	jne    f010487c <print_trapframe+0xb7>
f0104863:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104867:	75 13                	jne    f010487c <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104869:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010486c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104870:	c7 04 24 7e 81 10 f0 	movl   $0xf010817e,(%esp)
f0104877:	e8 62 fd ff ff       	call   f01045de <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010487c:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010487f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104883:	c7 04 24 8d 81 10 f0 	movl   $0xf010818d,(%esp)
f010488a:	e8 4f fd ff ff       	call   f01045de <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010488f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104893:	75 51                	jne    f01048e6 <print_trapframe+0x121>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104895:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104898:	89 c2                	mov    %eax,%edx
f010489a:	83 e2 01             	and    $0x1,%edx
f010489d:	ba 01 81 10 f0       	mov    $0xf0108101,%edx
f01048a2:	b9 0c 81 10 f0       	mov    $0xf010810c,%ecx
f01048a7:	0f 45 ca             	cmovne %edx,%ecx
f01048aa:	89 c2                	mov    %eax,%edx
f01048ac:	83 e2 02             	and    $0x2,%edx
f01048af:	ba 18 81 10 f0       	mov    $0xf0108118,%edx
f01048b4:	be 1e 81 10 f0       	mov    $0xf010811e,%esi
f01048b9:	0f 44 d6             	cmove  %esi,%edx
f01048bc:	83 e0 04             	and    $0x4,%eax
f01048bf:	b8 23 81 10 f0       	mov    $0xf0108123,%eax
f01048c4:	be 9c 82 10 f0       	mov    $0xf010829c,%esi
f01048c9:	0f 44 c6             	cmove  %esi,%eax
f01048cc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01048d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048d8:	c7 04 24 9b 81 10 f0 	movl   $0xf010819b,(%esp)
f01048df:	e8 fa fc ff ff       	call   f01045de <cprintf>
f01048e4:	eb 0c                	jmp    f01048f2 <print_trapframe+0x12d>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01048e6:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f01048ed:	e8 ec fc ff ff       	call   f01045de <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01048f2:	8b 43 30             	mov    0x30(%ebx),%eax
f01048f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048f9:	c7 04 24 aa 81 10 f0 	movl   $0xf01081aa,(%esp)
f0104900:	e8 d9 fc ff ff       	call   f01045de <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104905:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104909:	89 44 24 04          	mov    %eax,0x4(%esp)
f010490d:	c7 04 24 b9 81 10 f0 	movl   $0xf01081b9,(%esp)
f0104914:	e8 c5 fc ff ff       	call   f01045de <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104919:	8b 43 38             	mov    0x38(%ebx),%eax
f010491c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104920:	c7 04 24 cc 81 10 f0 	movl   $0xf01081cc,(%esp)
f0104927:	e8 b2 fc ff ff       	call   f01045de <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010492c:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104930:	74 27                	je     f0104959 <print_trapframe+0x194>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104932:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104935:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104939:	c7 04 24 db 81 10 f0 	movl   $0xf01081db,(%esp)
f0104940:	e8 99 fc ff ff       	call   f01045de <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104945:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104949:	89 44 24 04          	mov    %eax,0x4(%esp)
f010494d:	c7 04 24 ea 81 10 f0 	movl   $0xf01081ea,(%esp)
f0104954:	e8 85 fc ff ff       	call   f01045de <cprintf>
	}
}
f0104959:	83 c4 10             	add    $0x10,%esp
f010495c:	5b                   	pop    %ebx
f010495d:	5e                   	pop    %esi
f010495e:	5d                   	pop    %ebp
f010495f:	c3                   	ret    

f0104960 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104960:	55                   	push   %ebp
f0104961:	89 e5                	mov    %esp,%ebp
f0104963:	83 ec 28             	sub    $0x28,%esp
f0104966:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104969:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010496c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010496f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104972:	0f 20 d3             	mov    %cr2,%ebx
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0){
f0104975:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104979:	75 28                	jne    f01049a3 <page_fault_handler+0x43>
		print_trapframe(tf);
f010497b:	89 34 24             	mov    %esi,(%esp)
f010497e:	e8 42 fe ff ff       	call   f01047c5 <print_trapframe>
		panic("kernel page fault va: %08x", fault_va);
f0104983:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104987:	c7 44 24 08 fd 81 10 	movl   $0xf01081fd,0x8(%esp)
f010498e:	f0 
f010498f:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0104996:	00 
f0104997:	c7 04 24 18 82 10 f0 	movl   $0xf0108218,(%esp)
f010499e:	e8 9d b6 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01049a3:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01049a6:	e8 e5 19 00 00       	call   f0106390 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01049ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01049af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01049b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b6:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01049bc:	8b 40 48             	mov    0x48(%eax),%eax
f01049bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049c3:	c7 04 24 e8 83 10 f0 	movl   $0xf01083e8,(%esp)
f01049ca:	e8 0f fc ff ff       	call   f01045de <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01049cf:	89 34 24             	mov    %esi,(%esp)
f01049d2:	e8 ee fd ff ff       	call   f01047c5 <print_trapframe>
	env_destroy(curenv);
f01049d7:	e8 b4 19 00 00       	call   f0106390 <cpunum>
f01049dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049df:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01049e5:	89 04 24             	mov    %eax,(%esp)
f01049e8:	e8 18 f9 ff ff       	call   f0104305 <env_destroy>
}
f01049ed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01049f0:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01049f3:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01049f6:	89 ec                	mov    %ebp,%esp
f01049f8:	5d                   	pop    %ebp
f01049f9:	c3                   	ret    

f01049fa <breakpoint_handler>:

void
breakpoint_handler(struct Trapframe *tf) {
f01049fa:	55                   	push   %ebp
f01049fb:	89 e5                	mov    %esp,%ebp
f01049fd:	53                   	push   %ebx
f01049fe:	83 ec 14             	sub    $0x14,%esp
f0104a01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	print_trapframe(tf);
f0104a04:	89 1c 24             	mov    %ebx,(%esp)
f0104a07:	e8 b9 fd ff ff       	call   f01047c5 <print_trapframe>
	monitor(tf);
f0104a0c:	89 1c 24             	mov    %ebx,(%esp)
f0104a0f:	e8 f8 c5 ff ff       	call   f010100c <monitor>
	return;
}
f0104a14:	83 c4 14             	add    $0x14,%esp
f0104a17:	5b                   	pop    %ebx
f0104a18:	5d                   	pop    %ebp
f0104a19:	c3                   	ret    

f0104a1a <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104a1a:	55                   	push   %ebp
f0104a1b:	89 e5                	mov    %esp,%ebp
f0104a1d:	57                   	push   %edi
f0104a1e:	56                   	push   %esi
f0104a1f:	83 ec 20             	sub    $0x20,%esp
f0104a22:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104a25:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104a26:	83 3d e0 5e 22 f0 00 	cmpl   $0x0,0xf0225ee0
f0104a2d:	74 01                	je     f0104a30 <trap+0x16>
		asm volatile("hlt");
f0104a2f:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104a30:	e8 5b 19 00 00       	call   f0106390 <cpunum>
f0104a35:	6b d0 74             	imul   $0x74,%eax,%edx
f0104a38:	81 c2 20 60 22 f0    	add    $0xf0226020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104a3e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a43:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104a47:	83 f8 02             	cmp    $0x2,%eax
f0104a4a:	75 0c                	jne    f0104a58 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104a4c:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0104a53:	e8 e8 1b 00 00       	call   f0106640 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104a58:	9c                   	pushf  
f0104a59:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104a5a:	f6 c4 02             	test   $0x2,%ah
f0104a5d:	74 24                	je     f0104a83 <trap+0x69>
f0104a5f:	c7 44 24 0c 24 82 10 	movl   $0xf0108224,0xc(%esp)
f0104a66:	f0 
f0104a67:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0104a6e:	f0 
f0104a6f:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
f0104a76:	00 
f0104a77:	c7 04 24 18 82 10 f0 	movl   $0xf0108218,(%esp)
f0104a7e:	e8 bd b5 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104a83:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104a87:	83 e0 03             	and    $0x3,%eax
f0104a8a:	83 f8 03             	cmp    $0x3,%eax
f0104a8d:	0f 85 9b 00 00 00    	jne    f0104b2e <trap+0x114>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104a93:	e8 f8 18 00 00       	call   f0106390 <cpunum>
f0104a98:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a9b:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104aa2:	75 24                	jne    f0104ac8 <trap+0xae>
f0104aa4:	c7 44 24 0c 3d 82 10 	movl   $0xf010823d,0xc(%esp)
f0104aab:	f0 
f0104aac:	c7 44 24 08 e7 7c 10 	movl   $0xf0107ce7,0x8(%esp)
f0104ab3:	f0 
f0104ab4:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
f0104abb:	00 
f0104abc:	c7 04 24 18 82 10 f0 	movl   $0xf0108218,(%esp)
f0104ac3:	e8 78 b5 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104ac8:	e8 c3 18 00 00       	call   f0106390 <cpunum>
f0104acd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad0:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104ad6:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104ada:	75 2d                	jne    f0104b09 <trap+0xef>
			env_free(curenv);
f0104adc:	e8 af 18 00 00       	call   f0106390 <cpunum>
f0104ae1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae4:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104aea:	89 04 24             	mov    %eax,(%esp)
f0104aed:	e8 0c f6 ff ff       	call   f01040fe <env_free>
			curenv = NULL;
f0104af2:	e8 99 18 00 00       	call   f0106390 <cpunum>
f0104af7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afa:	c7 80 28 60 22 f0 00 	movl   $0x0,-0xfdd9fd8(%eax)
f0104b01:	00 00 00 
			sched_yield();
f0104b04:	e8 97 02 00 00       	call   f0104da0 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104b09:	e8 82 18 00 00       	call   f0106390 <cpunum>
f0104b0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b11:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104b17:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b1c:	89 c7                	mov    %eax,%edi
f0104b1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104b20:	e8 6b 18 00 00       	call   f0106390 <cpunum>
f0104b25:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b28:	8b b0 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104b2e:	89 35 c8 5a 22 f0    	mov    %esi,0xf0225ac8
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT) {
f0104b34:	8b 46 28             	mov    0x28(%esi),%eax
f0104b37:	83 f8 0e             	cmp    $0xe,%eax
f0104b3a:	75 19                	jne    f0104b55 <trap+0x13b>
		cprintf("PAGE FAULT!\n");
f0104b3c:	c7 04 24 44 82 10 f0 	movl   $0xf0108244,(%esp)
f0104b43:	e8 96 fa ff ff       	call   f01045de <cprintf>
		page_fault_handler(tf);
f0104b48:	89 34 24             	mov    %esi,(%esp)
f0104b4b:	e8 10 fe ff ff       	call   f0104960 <page_fault_handler>
f0104b50:	e9 c0 00 00 00       	jmp    f0104c15 <trap+0x1fb>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104b55:	83 f8 27             	cmp    $0x27,%eax
f0104b58:	75 19                	jne    f0104b73 <trap+0x159>
		cprintf("Spurious interrupt on irq 7\n");
f0104b5a:	c7 04 24 51 82 10 f0 	movl   $0xf0108251,(%esp)
f0104b61:	e8 78 fa ff ff       	call   f01045de <cprintf>
		print_trapframe(tf);
f0104b66:	89 34 24             	mov    %esi,(%esp)
f0104b69:	e8 57 fc ff ff       	call   f01047c5 <print_trapframe>
f0104b6e:	e9 a2 00 00 00       	jmp    f0104c15 <trap+0x1fb>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if(tf->tf_trapno == T_BRKPT) {
f0104b73:	83 f8 03             	cmp    $0x3,%eax
f0104b76:	75 19                	jne    f0104b91 <trap+0x177>
		cprintf("BREAK POINT!\n");
f0104b78:	c7 04 24 6e 82 10 f0 	movl   $0xf010826e,(%esp)
f0104b7f:	e8 5a fa ff ff       	call   f01045de <cprintf>
		breakpoint_handler(tf);
f0104b84:	89 34 24             	mov    %esi,(%esp)
f0104b87:	e8 6e fe ff ff       	call   f01049fa <breakpoint_handler>
f0104b8c:	e9 84 00 00 00       	jmp    f0104c15 <trap+0x1fb>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
f0104b91:	83 f8 30             	cmp    $0x30,%eax
f0104b94:	75 3e                	jne    f0104bd4 <trap+0x1ba>
		cprintf("SYSTEM CALL!\n");
f0104b96:	c7 04 24 7c 82 10 f0 	movl   $0xf010827c,(%esp)
f0104b9d:	e8 3c fa ff ff       	call   f01045de <cprintf>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104ba2:	8b 46 04             	mov    0x4(%esi),%eax
f0104ba5:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104ba9:	8b 06                	mov    (%esi),%eax
f0104bab:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104baf:	8b 46 10             	mov    0x10(%esi),%eax
f0104bb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104bb6:	8b 46 18             	mov    0x18(%esi),%eax
f0104bb9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104bbd:	8b 46 14             	mov    0x14(%esi),%eax
f0104bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bc4:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104bc7:	89 04 24             	mov    %eax,(%esp)
f0104bca:	e8 e1 01 00 00       	call   f0104db0 <syscall>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
f0104bcf:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104bd2:	eb 41                	jmp    f0104c15 <trap+0x1fb>
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104bd4:	89 34 24             	mov    %esi,(%esp)
f0104bd7:	e8 e9 fb ff ff       	call   f01047c5 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104bdc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104be1:	75 1c                	jne    f0104bff <trap+0x1e5>
		panic("unhandled trap in kernel");
f0104be3:	c7 44 24 08 8a 82 10 	movl   $0xf010828a,0x8(%esp)
f0104bea:	f0 
f0104beb:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0104bf2:	00 
f0104bf3:	c7 04 24 18 82 10 f0 	movl   $0xf0108218,(%esp)
f0104bfa:	e8 41 b4 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104bff:	e8 8c 17 00 00       	call   f0106390 <cpunum>
f0104c04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c07:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104c0d:	89 04 24             	mov    %eax,(%esp)
f0104c10:	e8 f0 f6 ff ff       	call   f0104305 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104c15:	e8 76 17 00 00       	call   f0106390 <cpunum>
f0104c1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1d:	83 b8 28 60 22 f0 00 	cmpl   $0x0,-0xfdd9fd8(%eax)
f0104c24:	74 2a                	je     f0104c50 <trap+0x236>
f0104c26:	e8 65 17 00 00       	call   f0106390 <cpunum>
f0104c2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2e:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104c34:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104c38:	75 16                	jne    f0104c50 <trap+0x236>
		env_run(curenv);
f0104c3a:	e8 51 17 00 00       	call   f0106390 <cpunum>
f0104c3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c42:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104c48:	89 04 24             	mov    %eax,(%esp)
f0104c4b:	e8 56 f7 ff ff       	call   f01043a6 <env_run>
	else
		sched_yield();
f0104c50:	e8 4b 01 00 00       	call   f0104da0 <sched_yield>
f0104c55:	00 00                	add    %al,(%eax)
	...

f0104c58 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec_entry(th0, 0)
f0104c58:	6a 00                	push   $0x0
f0104c5a:	6a 00                	push   $0x0
f0104c5c:	eb 4e                	jmp    f0104cac <_alltraps>

f0104c5e <th1>:
	noec_entry(th1, 1)
f0104c5e:	6a 00                	push   $0x0
f0104c60:	6a 01                	push   $0x1
f0104c62:	eb 48                	jmp    f0104cac <_alltraps>

f0104c64 <th3>:
	reserved_entry()
	noec_entry(th3, 3)
f0104c64:	6a 00                	push   $0x0
f0104c66:	6a 03                	push   $0x3
f0104c68:	eb 42                	jmp    f0104cac <_alltraps>

f0104c6a <th4>:
	noec_entry(th4, 4)
f0104c6a:	6a 00                	push   $0x0
f0104c6c:	6a 04                	push   $0x4
f0104c6e:	eb 3c                	jmp    f0104cac <_alltraps>

f0104c70 <th5>:
	noec_entry(th5, 5)
f0104c70:	6a 00                	push   $0x0
f0104c72:	6a 05                	push   $0x5
f0104c74:	eb 36                	jmp    f0104cac <_alltraps>

f0104c76 <th6>:
	noec_entry(th6, 6)
f0104c76:	6a 00                	push   $0x0
f0104c78:	6a 06                	push   $0x6
f0104c7a:	eb 30                	jmp    f0104cac <_alltraps>

f0104c7c <th7>:
	noec_entry(th7, 7)
f0104c7c:	6a 00                	push   $0x0
f0104c7e:	6a 07                	push   $0x7
f0104c80:	eb 2a                	jmp    f0104cac <_alltraps>

f0104c82 <th8>:
	ec_entry(th8, 8)
f0104c82:	6a 08                	push   $0x8
f0104c84:	eb 26                	jmp    f0104cac <_alltraps>

f0104c86 <th9>:
	noec_entry(th9, 9)
f0104c86:	6a 00                	push   $0x0
f0104c88:	6a 09                	push   $0x9
f0104c8a:	eb 20                	jmp    f0104cac <_alltraps>

f0104c8c <th10>:
	ec_entry(th10, 10)
f0104c8c:	6a 0a                	push   $0xa
f0104c8e:	eb 1c                	jmp    f0104cac <_alltraps>

f0104c90 <th11>:
	ec_entry(th11, 11)
f0104c90:	6a 0b                	push   $0xb
f0104c92:	eb 18                	jmp    f0104cac <_alltraps>

f0104c94 <th12>:
	ec_entry(th12, 12)
f0104c94:	6a 0c                	push   $0xc
f0104c96:	eb 14                	jmp    f0104cac <_alltraps>

f0104c98 <th13>:
	ec_entry(th13, 13)
f0104c98:	6a 0d                	push   $0xd
f0104c9a:	eb 10                	jmp    f0104cac <_alltraps>

f0104c9c <th14>:
	ec_entry(th14, 14)
f0104c9c:	6a 0e                	push   $0xe
f0104c9e:	eb 0c                	jmp    f0104cac <_alltraps>

f0104ca0 <th16>:
	reserved_entry()
	noec_entry(th16, 16)
f0104ca0:	6a 00                	push   $0x0
f0104ca2:	6a 10                	push   $0x10
f0104ca4:	eb 06                	jmp    f0104cac <_alltraps>

f0104ca6 <th48>:
.data
	.space 124
.text
	noec_entry(th48, 48)
f0104ca6:	6a 00                	push   $0x0
f0104ca8:	6a 30                	push   $0x30
f0104caa:	eb 00                	jmp    f0104cac <_alltraps>

f0104cac <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104cac:	1e                   	push   %ds
	pushl %es
f0104cad:	06                   	push   %es
	pushal
f0104cae:	60                   	pusha  
	pushl $GD_KD
f0104caf:	6a 10                	push   $0x10
	popl %ds
f0104cb1:	1f                   	pop    %ds
	pushl $GD_KD
f0104cb2:	6a 10                	push   $0x10
	popl %es
f0104cb4:	07                   	pop    %es
	pushl %esp
f0104cb5:	54                   	push   %esp
	call trap
f0104cb6:	e8 5f fd ff ff       	call   f0104a1a <trap>
	...

f0104cbc <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104cbc:	55                   	push   %ebp
f0104cbd:	89 e5                	mov    %esp,%ebp
f0104cbf:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104cc2:	8b 15 48 52 22 f0    	mov    0xf0225248,%edx
f0104cc8:	8b 42 54             	mov    0x54(%edx),%eax
f0104ccb:	83 e8 02             	sub    $0x2,%eax
f0104cce:	83 f8 01             	cmp    $0x1,%eax
f0104cd1:	76 45                	jbe    f0104d18 <sched_halt+0x5c>

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104cd3:	81 c2 d0 00 00 00    	add    $0xd0,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104cd9:	b8 01 00 00 00       	mov    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104cde:	8b 0a                	mov    (%edx),%ecx
f0104ce0:	83 e9 02             	sub    $0x2,%ecx
f0104ce3:	83 f9 01             	cmp    $0x1,%ecx
f0104ce6:	76 0f                	jbe    f0104cf7 <sched_halt+0x3b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104ce8:	83 c0 01             	add    $0x1,%eax
f0104ceb:	83 c2 7c             	add    $0x7c,%edx
f0104cee:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104cf3:	75 e9                	jne    f0104cde <sched_halt+0x22>
f0104cf5:	eb 07                	jmp    f0104cfe <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104cf7:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104cfc:	75 1a                	jne    f0104d18 <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f0104cfe:	c7 04 24 70 84 10 f0 	movl   $0xf0108470,(%esp)
f0104d05:	e8 d4 f8 ff ff       	call   f01045de <cprintf>
		while (1)
			monitor(NULL);
f0104d0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104d11:	e8 f6 c2 ff ff       	call   f010100c <monitor>
f0104d16:	eb f2                	jmp    f0104d0a <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104d18:	e8 73 16 00 00       	call   f0106390 <cpunum>
f0104d1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d20:	c7 80 28 60 22 f0 00 	movl   $0x0,-0xfdd9fd8(%eax)
f0104d27:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104d2a:	a1 ec 5e 22 f0       	mov    0xf0225eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104d2f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104d34:	77 20                	ja     f0104d56 <sched_halt+0x9a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104d36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d3a:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0104d41:	f0 
f0104d42:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
f0104d49:	00 
f0104d4a:	c7 04 24 99 84 10 f0 	movl   $0xf0108499,(%esp)
f0104d51:	e8 ea b2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104d56:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104d5b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104d5e:	e8 2d 16 00 00       	call   f0106390 <cpunum>
f0104d63:	6b d0 74             	imul   $0x74,%eax,%edx
f0104d66:	81 c2 20 60 22 f0    	add    $0xf0226020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104d6c:	b8 02 00 00 00       	mov    $0x2,%eax
f0104d71:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104d75:	c7 04 24 80 24 12 f0 	movl   $0xf0122480,(%esp)
f0104d7c:	e8 82 19 00 00       	call   f0106703 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104d81:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104d83:	e8 08 16 00 00       	call   f0106390 <cpunum>
f0104d88:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104d8b:	8b 80 30 60 22 f0    	mov    -0xfdd9fd0(%eax),%eax
f0104d91:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104d96:	89 c4                	mov    %eax,%esp
f0104d98:	6a 00                	push   $0x0
f0104d9a:	6a 00                	push   $0x0
f0104d9c:	fb                   	sti    
f0104d9d:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104d9e:	c9                   	leave  
f0104d9f:	c3                   	ret    

f0104da0 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104da0:	55                   	push   %ebp
f0104da1:	89 e5                	mov    %esp,%ebp
f0104da3:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f0104da6:	e8 11 ff ff ff       	call   f0104cbc <sched_halt>
}
f0104dab:	c9                   	leave  
f0104dac:	c3                   	ret    
f0104dad:	00 00                	add    %al,(%eax)
	...

f0104db0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104db0:	55                   	push   %ebp
f0104db1:	89 e5                	mov    %esp,%ebp
f0104db3:	56                   	push   %esi
f0104db4:	53                   	push   %ebx
f0104db5:	83 ec 20             	sub    $0x20,%esp
f0104db8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104dbe:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno){
f0104dc1:	83 f8 01             	cmp    $0x1,%eax
f0104dc4:	74 68                	je     f0104e2e <syscall+0x7e>
f0104dc6:	83 f8 01             	cmp    $0x1,%eax
f0104dc9:	72 13                	jb     f0104dde <syscall+0x2e>
f0104dcb:	83 f8 02             	cmp    $0x2,%eax
f0104dce:	74 74                	je     f0104e44 <syscall+0x94>
f0104dd0:	83 f8 03             	cmp    $0x3,%eax
f0104dd3:	0f 85 24 01 00 00    	jne    f0104efd <syscall+0x14d>
f0104dd9:	e9 88 00 00 00       	jmp    f0104e66 <syscall+0xb6>
		case SYS_cputs:
			cprintf("SYS_cputs\n");
f0104dde:	c7 04 24 a6 84 10 f0 	movl   $0xf01084a6,(%esp)
f0104de5:	e8 f4 f7 ff ff       	call   f01045de <cprintf>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(void *)s, len, PTE_U | PTE_P);
f0104dea:	e8 a1 15 00 00       	call   f0106390 <cpunum>
f0104def:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0104df6:	00 
f0104df7:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104dfb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104dff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e02:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104e08:	89 04 24             	mov    %eax,(%esp)
f0104e0b:	e8 ea ed ff ff       	call   f0103bfa <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104e10:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e14:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e18:	c7 04 24 b1 84 10 f0 	movl   $0xf01084b1,(%esp)
f0104e1f:	e8 ba f7 ff ff       	call   f01045de <cprintf>
	// LAB 3: Your code here.
	switch (syscallno){
		case SYS_cputs:
			cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
f0104e24:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e29:	e9 d4 00 00 00       	jmp    f0104f02 <syscall+0x152>
		case SYS_cgetc:
			cprintf("SYS_cgetc\n");
f0104e2e:	c7 04 24 b6 84 10 f0 	movl   $0xf01084b6,(%esp)
f0104e35:	e8 a4 f7 ff ff       	call   f01045de <cprintf>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104e3a:	e8 e9 b7 ff ff       	call   f0100628 <cons_getc>
			cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
		case SYS_cgetc:
			cprintf("SYS_cgetc\n");
			return sys_cgetc();
f0104e3f:	e9 be 00 00 00       	jmp    f0104f02 <syscall+0x152>
		case SYS_getenvid:
			cprintf("SYS_getenvid\n");
f0104e44:	c7 04 24 c1 84 10 f0 	movl   $0xf01084c1,(%esp)
f0104e4b:	e8 8e f7 ff ff       	call   f01045de <cprintf>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104e50:	e8 3b 15 00 00       	call   f0106390 <cpunum>
f0104e55:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e58:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104e5e:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			cprintf("SYS_getenvid\n");
			return sys_getenvid();
f0104e61:	e9 9c 00 00 00       	jmp    f0104f02 <syscall+0x152>
		case SYS_env_destroy:
			cprintf("SYS_env_destroy\n");
f0104e66:	c7 04 24 cf 84 10 f0 	movl   $0xf01084cf,(%esp)
f0104e6d:	e8 6c f7 ff ff       	call   f01045de <cprintf>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104e72:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e79:	00 
f0104e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e81:	89 1c 24             	mov    %ebx,(%esp)
f0104e84:	e8 50 ee ff ff       	call   f0103cd9 <envid2env>
f0104e89:	85 c0                	test   %eax,%eax
f0104e8b:	78 75                	js     f0104f02 <syscall+0x152>
		return r;
	if (e == curenv)
f0104e8d:	e8 fe 14 00 00       	call   f0106390 <cpunum>
f0104e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104e95:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e98:	39 90 28 60 22 f0    	cmp    %edx,-0xfdd9fd8(%eax)
f0104e9e:	75 23                	jne    f0104ec3 <syscall+0x113>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104ea0:	e8 eb 14 00 00       	call   f0106390 <cpunum>
f0104ea5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea8:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104eae:	8b 40 48             	mov    0x48(%eax),%eax
f0104eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eb5:	c7 04 24 e0 84 10 f0 	movl   $0xf01084e0,(%esp)
f0104ebc:	e8 1d f7 ff ff       	call   f01045de <cprintf>
f0104ec1:	eb 28                	jmp    f0104eeb <syscall+0x13b>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104ec3:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104ec6:	e8 c5 14 00 00       	call   f0106390 <cpunum>
f0104ecb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ecf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ed2:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f0104ed8:	8b 40 48             	mov    0x48(%eax),%eax
f0104edb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104edf:	c7 04 24 fb 84 10 f0 	movl   $0xf01084fb,(%esp)
f0104ee6:	e8 f3 f6 ff ff       	call   f01045de <cprintf>
	env_destroy(e);
f0104eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104eee:	89 04 24             	mov    %eax,(%esp)
f0104ef1:	e8 0f f4 ff ff       	call   f0104305 <env_destroy>
	return 0;
f0104ef6:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_getenvid:
			cprintf("SYS_getenvid\n");
			return sys_getenvid();
		case SYS_env_destroy:
			cprintf("SYS_env_destroy\n");
			return sys_env_destroy(a1);
f0104efb:	eb 05                	jmp    f0104f02 <syscall+0x152>
		default: 
			return -E_INVAL;
f0104efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0104f02:	83 c4 20             	add    $0x20,%esp
f0104f05:	5b                   	pop    %ebx
f0104f06:	5e                   	pop    %esi
f0104f07:	5d                   	pop    %ebp
f0104f08:	c3                   	ret    
f0104f09:	00 00                	add    %al,(%eax)
	...

f0104f0c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104f0c:	55                   	push   %ebp
f0104f0d:	89 e5                	mov    %esp,%ebp
f0104f0f:	57                   	push   %edi
f0104f10:	56                   	push   %esi
f0104f11:	53                   	push   %ebx
f0104f12:	83 ec 14             	sub    $0x14,%esp
f0104f15:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f18:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104f1b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f1e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f21:	8b 1a                	mov    (%edx),%ebx
f0104f23:	8b 01                	mov    (%ecx),%eax
f0104f25:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0104f28:	39 c3                	cmp    %eax,%ebx
f0104f2a:	0f 8f 9c 00 00 00    	jg     f0104fcc <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f3a:	01 d8                	add    %ebx,%eax
f0104f3c:	89 c7                	mov    %eax,%edi
f0104f3e:	c1 ef 1f             	shr    $0x1f,%edi
f0104f41:	01 c7                	add    %eax,%edi
f0104f43:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f45:	39 df                	cmp    %ebx,%edi
f0104f47:	7c 33                	jl     f0104f7c <stab_binsearch+0x70>
f0104f49:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104f4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104f4f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104f54:	39 f0                	cmp    %esi,%eax
f0104f56:	0f 84 bc 00 00 00    	je     f0105018 <stab_binsearch+0x10c>
f0104f5c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104f60:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104f64:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104f66:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f69:	39 d8                	cmp    %ebx,%eax
f0104f6b:	7c 0f                	jl     f0104f7c <stab_binsearch+0x70>
f0104f6d:	0f b6 0a             	movzbl (%edx),%ecx
f0104f70:	83 ea 0c             	sub    $0xc,%edx
f0104f73:	39 f1                	cmp    %esi,%ecx
f0104f75:	75 ef                	jne    f0104f66 <stab_binsearch+0x5a>
f0104f77:	e9 9e 00 00 00       	jmp    f010501a <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104f7c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104f7f:	eb 3c                	jmp    f0104fbd <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104f81:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104f84:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0104f86:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104f89:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104f90:	eb 2b                	jmp    f0104fbd <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104f92:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104f95:	76 14                	jbe    f0104fab <stab_binsearch+0x9f>
			*region_right = m - 1;
f0104f97:	83 e8 01             	sub    $0x1,%eax
f0104f9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f9d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fa0:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104fa2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104fa9:	eb 12                	jmp    f0104fbd <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104fab:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104fae:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0104fb0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104fb4:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104fb6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104fbd:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104fc0:	0f 8d 71 ff ff ff    	jge    f0104f37 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104fc6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104fca:	75 0f                	jne    f0104fdb <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0104fcc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104fcf:	8b 02                	mov    (%edx),%eax
f0104fd1:	83 e8 01             	sub    $0x1,%eax
f0104fd4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fd7:	89 01                	mov    %eax,(%ecx)
f0104fd9:	eb 57                	jmp    f0105032 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fdb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fde:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104fe0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104fe3:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fe5:	39 c1                	cmp    %eax,%ecx
f0104fe7:	7d 28                	jge    f0105011 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0104fe9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104fec:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104fef:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104ff4:	39 f2                	cmp    %esi,%edx
f0104ff6:	74 19                	je     f0105011 <stab_binsearch+0x105>
f0104ff8:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104ffc:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105000:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105003:	39 c1                	cmp    %eax,%ecx
f0105005:	7d 0a                	jge    f0105011 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105007:	0f b6 1a             	movzbl (%edx),%ebx
f010500a:	83 ea 0c             	sub    $0xc,%edx
f010500d:	39 f3                	cmp    %esi,%ebx
f010500f:	75 ef                	jne    f0105000 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105011:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105014:	89 02                	mov    %eax,(%edx)
f0105016:	eb 1a                	jmp    f0105032 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105018:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010501a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010501d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105020:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105024:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105027:	0f 82 54 ff ff ff    	jb     f0104f81 <stab_binsearch+0x75>
f010502d:	e9 60 ff ff ff       	jmp    f0104f92 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105032:	83 c4 14             	add    $0x14,%esp
f0105035:	5b                   	pop    %ebx
f0105036:	5e                   	pop    %esi
f0105037:	5f                   	pop    %edi
f0105038:	5d                   	pop    %ebp
f0105039:	c3                   	ret    

f010503a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010503a:	55                   	push   %ebp
f010503b:	89 e5                	mov    %esp,%ebp
f010503d:	57                   	push   %edi
f010503e:	56                   	push   %esi
f010503f:	53                   	push   %ebx
f0105040:	83 ec 5c             	sub    $0x5c,%esp
f0105043:	8b 75 08             	mov    0x8(%ebp),%esi
f0105046:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105049:	c7 03 13 85 10 f0    	movl   $0xf0108513,(%ebx)
	info->eip_line = 0;
f010504f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105056:	c7 43 08 13 85 10 f0 	movl   $0xf0108513,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010505d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105064:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105067:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010506e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105074:	0f 87 d8 00 00 00    	ja     f0105152 <debuginfo_eip+0x118>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010507a:	e8 11 13 00 00       	call   f0106390 <cpunum>
f010507f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105086:	00 
f0105087:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010508e:	00 
f010508f:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105096:	00 
f0105097:	6b c0 74             	imul   $0x74,%eax,%eax
f010509a:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01050a0:	89 04 24             	mov    %eax,(%esp)
f01050a3:	e8 7e ea ff ff       	call   f0103b26 <user_mem_check>
f01050a8:	89 c2                	mov    %eax,%edx
			return -1;
f01050aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01050af:	85 d2                	test   %edx,%edx
f01050b1:	0f 85 a5 02 00 00    	jne    f010535c <debuginfo_eip+0x322>
			return -1;

		stabs = usd->stabs;
f01050b7:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01050bd:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01050c0:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01050c6:	a1 08 00 20 00       	mov    0x200008,%eax
f01050cb:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01050ce:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01050d4:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f01050d7:	e8 b4 12 00 00       	call   f0106390 <cpunum>
f01050dc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01050e3:	00 
f01050e4:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01050eb:	00 
f01050ec:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01050ef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01050f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f6:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f01050fc:	89 04 24             	mov    %eax,(%esp)
f01050ff:	e8 22 ea ff ff       	call   f0103b26 <user_mem_check>
f0105104:	89 c2                	mov    %eax,%edx
			return -1;
f0105106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010510b:	85 d2                	test   %edx,%edx
f010510d:	0f 85 49 02 00 00    	jne    f010535c <debuginfo_eip+0x322>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105113:	e8 78 12 00 00       	call   f0106390 <cpunum>
f0105118:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010511f:	00 
f0105120:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105123:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105126:	89 54 24 08          	mov    %edx,0x8(%esp)
f010512a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010512d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105131:	6b c0 74             	imul   $0x74,%eax,%eax
f0105134:	8b 80 28 60 22 f0    	mov    -0xfdd9fd8(%eax),%eax
f010513a:	89 04 24             	mov    %eax,(%esp)
f010513d:	e8 e4 e9 ff ff       	call   f0103b26 <user_mem_check>
f0105142:	89 c2                	mov    %eax,%edx
			return -1;
f0105144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0105149:	85 d2                	test   %edx,%edx
f010514b:	74 1f                	je     f010516c <debuginfo_eip+0x132>
f010514d:	e9 0a 02 00 00       	jmp    f010535c <debuginfo_eip+0x322>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105152:	c7 45 c0 b3 70 11 f0 	movl   $0xf01170b3,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105159:	c7 45 bc 21 38 11 f0 	movl   $0xf0113821,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105160:	bf 20 38 11 f0       	mov    $0xf0113820,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105165:	c7 45 c4 14 8a 10 f0 	movl   $0xf0108a14,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010516c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105171:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105174:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105177:	0f 83 df 01 00 00    	jae    f010535c <debuginfo_eip+0x322>
f010517d:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105181:	0f 85 d5 01 00 00    	jne    f010535c <debuginfo_eip+0x322>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105187:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010518e:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105191:	c1 ff 02             	sar    $0x2,%edi
f0105194:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f010519a:	83 e8 01             	sub    $0x1,%eax
f010519d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01051a0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01051a4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01051ab:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01051ae:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01051b1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01051b4:	e8 53 fd ff ff       	call   f0104f0c <stab_binsearch>
	if (lfile == 0)
f01051b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01051bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01051c1:	85 d2                	test   %edx,%edx
f01051c3:	0f 84 93 01 00 00    	je     f010535c <debuginfo_eip+0x322>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01051c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01051cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01051d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01051d6:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01051dd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01051e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01051e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01051e6:	e8 21 fd ff ff       	call   f0104f0c <stab_binsearch>

	if (lfun <= rfun) {
f01051eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051ee:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01051f1:	39 d0                	cmp    %edx,%eax
f01051f3:	7f 32                	jg     f0105227 <debuginfo_eip+0x1ed>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01051f5:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01051f8:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01051fb:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01051fe:	8b 39                	mov    (%ecx),%edi
f0105200:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105203:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105206:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105209:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010520c:	73 09                	jae    f0105217 <debuginfo_eip+0x1dd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010520e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105211:	03 7d bc             	add    -0x44(%ebp),%edi
f0105214:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105217:	8b 49 08             	mov    0x8(%ecx),%ecx
f010521a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010521d:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010521f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105222:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105225:	eb 0f                	jmp    f0105236 <debuginfo_eip+0x1fc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105227:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010522a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010522d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105230:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105233:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105236:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010523d:	00 
f010523e:	8b 43 08             	mov    0x8(%ebx),%eax
f0105241:	89 04 24             	mov    %eax,(%esp)
f0105244:	e8 91 0a 00 00       	call   f0105cda <strfind>
f0105249:	2b 43 08             	sub    0x8(%ebx),%eax
f010524c:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010524f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105253:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010525a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010525d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105260:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105263:	e8 a4 fc ff ff       	call   f0104f0c <stab_binsearch>

	if(lline <= rline)
f0105268:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f010526b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0105270:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0105273:	0f 8f e3 00 00 00    	jg     f010535c <debuginfo_eip+0x322>
		info->eip_line = stabs[lline].n_desc;
f0105279:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010527c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010527f:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105284:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105287:	89 d0                	mov    %edx,%eax
f0105289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010528c:	89 7d b8             	mov    %edi,-0x48(%ebp)
f010528f:	39 fa                	cmp    %edi,%edx
f0105291:	7c 74                	jl     f0105307 <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f0105293:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105296:	89 f7                	mov    %esi,%edi
f0105298:	8d 34 96             	lea    (%esi,%edx,4),%esi
f010529b:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f010529f:	80 f9 84             	cmp    $0x84,%cl
f01052a2:	74 46                	je     f01052ea <debuginfo_eip+0x2b0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01052a4:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01052a8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01052ab:	89 c7                	mov    %eax,%edi
f01052ad:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01052b0:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01052b3:	eb 1f                	jmp    f01052d4 <debuginfo_eip+0x29a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01052b5:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01052b8:	39 c3                	cmp    %eax,%ebx
f01052ba:	7f 48                	jg     f0105304 <debuginfo_eip+0x2ca>
	       && stabs[lline].n_type != N_SOL
f01052bc:	89 d6                	mov    %edx,%esi
f01052be:	83 ea 0c             	sub    $0xc,%edx
f01052c1:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f01052c5:	80 f9 84             	cmp    $0x84,%cl
f01052c8:	75 08                	jne    f01052d2 <debuginfo_eip+0x298>
f01052ca:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01052cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01052d0:	eb 18                	jmp    f01052ea <debuginfo_eip+0x2b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01052d2:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01052d4:	80 f9 64             	cmp    $0x64,%cl
f01052d7:	75 dc                	jne    f01052b5 <debuginfo_eip+0x27b>
f01052d9:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f01052dd:	74 d6                	je     f01052b5 <debuginfo_eip+0x27b>
f01052df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01052e2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01052e5:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f01052e8:	7c 1d                	jl     f0105307 <debuginfo_eip+0x2cd>
f01052ea:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01052ed:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01052f0:	8b 04 86             	mov    (%esi,%eax,4),%eax
f01052f3:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01052f6:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01052f9:	39 d0                	cmp    %edx,%eax
f01052fb:	73 0a                	jae    f0105307 <debuginfo_eip+0x2cd>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052fd:	03 45 bc             	add    -0x44(%ebp),%eax
f0105300:	89 03                	mov    %eax,(%ebx)
f0105302:	eb 03                	jmp    f0105307 <debuginfo_eip+0x2cd>
f0105304:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105307:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010530a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010530d:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105310:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105315:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f0105318:	7d 42                	jge    f010535c <debuginfo_eip+0x322>
		for (lline = lfun + 1;
f010531a:	8d 57 01             	lea    0x1(%edi),%edx
f010531d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105320:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0105323:	7e 37                	jle    f010535c <debuginfo_eip+0x322>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105325:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0105328:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010532b:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f0105330:	75 2a                	jne    f010535c <debuginfo_eip+0x322>
f0105332:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105335:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f0105339:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010533c:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105340:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105343:	39 d1                	cmp    %edx,%ecx
f0105345:	7e 10                	jle    f0105357 <debuginfo_eip+0x31d>
f0105347:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010534a:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f010534e:	74 ec                	je     f010533c <debuginfo_eip+0x302>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105350:	b8 00 00 00 00       	mov    $0x0,%eax
f0105355:	eb 05                	jmp    f010535c <debuginfo_eip+0x322>
f0105357:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010535c:	83 c4 5c             	add    $0x5c,%esp
f010535f:	5b                   	pop    %ebx
f0105360:	5e                   	pop    %esi
f0105361:	5f                   	pop    %edi
f0105362:	5d                   	pop    %ebp
f0105363:	c3                   	ret    

f0105364 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105364:	55                   	push   %ebp
f0105365:	89 e5                	mov    %esp,%ebp
f0105367:	57                   	push   %edi
f0105368:	56                   	push   %esi
f0105369:	53                   	push   %ebx
f010536a:	83 ec 3c             	sub    $0x3c,%esp
f010536d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105370:	89 d7                	mov    %edx,%edi
f0105372:	8b 45 08             	mov    0x8(%ebp),%eax
f0105375:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105378:	8b 45 0c             	mov    0xc(%ebp),%eax
f010537b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010537e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105381:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105384:	b8 00 00 00 00       	mov    $0x0,%eax
f0105389:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010538c:	72 11                	jb     f010539f <printnum+0x3b>
f010538e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105391:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105394:	76 09                	jbe    f010539f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105396:	83 eb 01             	sub    $0x1,%ebx
f0105399:	85 db                	test   %ebx,%ebx
f010539b:	7f 51                	jg     f01053ee <printnum+0x8a>
f010539d:	eb 5e                	jmp    f01053fd <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010539f:	89 74 24 10          	mov    %esi,0x10(%esp)
f01053a3:	83 eb 01             	sub    $0x1,%ebx
f01053a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01053aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01053ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053b1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01053b5:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01053b9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01053c0:	00 
f01053c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053c4:	89 04 24             	mov    %eax,(%esp)
f01053c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ce:	e8 4d 14 00 00       	call   f0106820 <__udivdi3>
f01053d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01053d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01053db:	89 04 24             	mov    %eax,(%esp)
f01053de:	89 54 24 04          	mov    %edx,0x4(%esp)
f01053e2:	89 fa                	mov    %edi,%edx
f01053e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053e7:	e8 78 ff ff ff       	call   f0105364 <printnum>
f01053ec:	eb 0f                	jmp    f01053fd <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01053ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01053f2:	89 34 24             	mov    %esi,(%esp)
f01053f5:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01053f8:	83 eb 01             	sub    $0x1,%ebx
f01053fb:	75 f1                	jne    f01053ee <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01053fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105401:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105405:	8b 45 10             	mov    0x10(%ebp),%eax
f0105408:	89 44 24 08          	mov    %eax,0x8(%esp)
f010540c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105413:	00 
f0105414:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105417:	89 04 24             	mov    %eax,(%esp)
f010541a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010541d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105421:	e8 2a 15 00 00       	call   f0106950 <__umoddi3>
f0105426:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010542a:	0f be 80 1d 85 10 f0 	movsbl -0xfef7ae3(%eax),%eax
f0105431:	89 04 24             	mov    %eax,(%esp)
f0105434:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105437:	83 c4 3c             	add    $0x3c,%esp
f010543a:	5b                   	pop    %ebx
f010543b:	5e                   	pop    %esi
f010543c:	5f                   	pop    %edi
f010543d:	5d                   	pop    %ebp
f010543e:	c3                   	ret    

f010543f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010543f:	55                   	push   %ebp
f0105440:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105442:	83 fa 01             	cmp    $0x1,%edx
f0105445:	7e 0e                	jle    f0105455 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105447:	8b 10                	mov    (%eax),%edx
f0105449:	8d 4a 08             	lea    0x8(%edx),%ecx
f010544c:	89 08                	mov    %ecx,(%eax)
f010544e:	8b 02                	mov    (%edx),%eax
f0105450:	8b 52 04             	mov    0x4(%edx),%edx
f0105453:	eb 22                	jmp    f0105477 <getuint+0x38>
	else if (lflag)
f0105455:	85 d2                	test   %edx,%edx
f0105457:	74 10                	je     f0105469 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105459:	8b 10                	mov    (%eax),%edx
f010545b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010545e:	89 08                	mov    %ecx,(%eax)
f0105460:	8b 02                	mov    (%edx),%eax
f0105462:	ba 00 00 00 00       	mov    $0x0,%edx
f0105467:	eb 0e                	jmp    f0105477 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105469:	8b 10                	mov    (%eax),%edx
f010546b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010546e:	89 08                	mov    %ecx,(%eax)
f0105470:	8b 02                	mov    (%edx),%eax
f0105472:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105477:	5d                   	pop    %ebp
f0105478:	c3                   	ret    

f0105479 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105479:	55                   	push   %ebp
f010547a:	89 e5                	mov    %esp,%ebp
f010547c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010547f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105483:	8b 10                	mov    (%eax),%edx
f0105485:	3b 50 04             	cmp    0x4(%eax),%edx
f0105488:	73 0a                	jae    f0105494 <sprintputch+0x1b>
		*b->buf++ = ch;
f010548a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010548d:	88 0a                	mov    %cl,(%edx)
f010548f:	83 c2 01             	add    $0x1,%edx
f0105492:	89 10                	mov    %edx,(%eax)
}
f0105494:	5d                   	pop    %ebp
f0105495:	c3                   	ret    

f0105496 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105496:	55                   	push   %ebp
f0105497:	89 e5                	mov    %esp,%ebp
f0105499:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010549c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010549f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01054a3:	8b 45 10             	mov    0x10(%ebp),%eax
f01054a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01054b4:	89 04 24             	mov    %eax,(%esp)
f01054b7:	e8 02 00 00 00       	call   f01054be <vprintfmt>
	va_end(ap);
}
f01054bc:	c9                   	leave  
f01054bd:	c3                   	ret    

f01054be <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01054be:	55                   	push   %ebp
f01054bf:	89 e5                	mov    %esp,%ebp
f01054c1:	57                   	push   %edi
f01054c2:	56                   	push   %esi
f01054c3:	53                   	push   %ebx
f01054c4:	83 ec 5c             	sub    $0x5c,%esp
f01054c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054ca:	8b 75 10             	mov    0x10(%ebp),%esi
f01054cd:	eb 12                	jmp    f01054e1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01054cf:	85 c0                	test   %eax,%eax
f01054d1:	0f 84 e4 04 00 00    	je     f01059bb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f01054d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054db:	89 04 24             	mov    %eax,(%esp)
f01054de:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01054e1:	0f b6 06             	movzbl (%esi),%eax
f01054e4:	83 c6 01             	add    $0x1,%esi
f01054e7:	83 f8 25             	cmp    $0x25,%eax
f01054ea:	75 e3                	jne    f01054cf <vprintfmt+0x11>
f01054ec:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f01054f0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f01054f7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01054fc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105503:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105508:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010550b:	eb 2b                	jmp    f0105538 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010550d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105510:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0105514:	eb 22                	jmp    f0105538 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105516:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105519:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f010551d:	eb 19                	jmp    f0105538 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010551f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105522:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105529:	eb 0d                	jmp    f0105538 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010552b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010552e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105531:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105538:	0f b6 06             	movzbl (%esi),%eax
f010553b:	0f b6 d0             	movzbl %al,%edx
f010553e:	8d 7e 01             	lea    0x1(%esi),%edi
f0105541:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105544:	83 e8 23             	sub    $0x23,%eax
f0105547:	3c 55                	cmp    $0x55,%al
f0105549:	0f 87 46 04 00 00    	ja     f0105995 <vprintfmt+0x4d7>
f010554f:	0f b6 c0             	movzbl %al,%eax
f0105552:	ff 24 85 00 86 10 f0 	jmp    *-0xfef7a00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105559:	83 ea 30             	sub    $0x30,%edx
f010555c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f010555f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0105563:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105566:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0105569:	83 fa 09             	cmp    $0x9,%edx
f010556c:	77 4a                	ja     f01055b8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010556e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105571:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105574:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105577:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010557b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010557e:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105581:	83 fa 09             	cmp    $0x9,%edx
f0105584:	76 eb                	jbe    f0105571 <vprintfmt+0xb3>
f0105586:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0105589:	eb 2d                	jmp    f01055b8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010558b:	8b 45 14             	mov    0x14(%ebp),%eax
f010558e:	8d 50 04             	lea    0x4(%eax),%edx
f0105591:	89 55 14             	mov    %edx,0x14(%ebp)
f0105594:	8b 00                	mov    (%eax),%eax
f0105596:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105599:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010559c:	eb 1a                	jmp    f01055b8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010559e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f01055a1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01055a5:	79 91                	jns    f0105538 <vprintfmt+0x7a>
f01055a7:	e9 73 ff ff ff       	jmp    f010551f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055ac:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01055af:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f01055b6:	eb 80                	jmp    f0105538 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f01055b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01055bc:	0f 89 76 ff ff ff    	jns    f0105538 <vprintfmt+0x7a>
f01055c2:	e9 64 ff ff ff       	jmp    f010552b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01055c7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01055cd:	e9 66 ff ff ff       	jmp    f0105538 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01055d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01055d5:	8d 50 04             	lea    0x4(%eax),%edx
f01055d8:	89 55 14             	mov    %edx,0x14(%ebp)
f01055db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055df:	8b 00                	mov    (%eax),%eax
f01055e1:	89 04 24             	mov    %eax,(%esp)
f01055e4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055e7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01055ea:	e9 f2 fe ff ff       	jmp    f01054e1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f01055ef:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01055f3:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f01055f6:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f01055fa:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f01055fd:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0105601:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0105604:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0105607:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f010560b:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010560e:	80 f9 09             	cmp    $0x9,%cl
f0105611:	77 1d                	ja     f0105630 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0105613:	0f be c0             	movsbl %al,%eax
f0105616:	6b c0 64             	imul   $0x64,%eax,%eax
f0105619:	0f be d2             	movsbl %dl,%edx
f010561c:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010561f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0105626:	a3 78 24 12 f0       	mov    %eax,0xf0122478
f010562b:	e9 b1 fe ff ff       	jmp    f01054e1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0105630:	c7 44 24 04 35 85 10 	movl   $0xf0108535,0x4(%esp)
f0105637:	f0 
f0105638:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010563b:	89 04 24             	mov    %eax,(%esp)
f010563e:	e8 e8 05 00 00       	call   f0105c2b <strcmp>
f0105643:	85 c0                	test   %eax,%eax
f0105645:	75 0f                	jne    f0105656 <vprintfmt+0x198>
f0105647:	c7 05 78 24 12 f0 04 	movl   $0x4,0xf0122478
f010564e:	00 00 00 
f0105651:	e9 8b fe ff ff       	jmp    f01054e1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0105656:	c7 44 24 04 39 85 10 	movl   $0xf0108539,0x4(%esp)
f010565d:	f0 
f010565e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105661:	89 14 24             	mov    %edx,(%esp)
f0105664:	e8 c2 05 00 00       	call   f0105c2b <strcmp>
f0105669:	85 c0                	test   %eax,%eax
f010566b:	75 0f                	jne    f010567c <vprintfmt+0x1be>
f010566d:	c7 05 78 24 12 f0 02 	movl   $0x2,0xf0122478
f0105674:	00 00 00 
f0105677:	e9 65 fe ff ff       	jmp    f01054e1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f010567c:	c7 44 24 04 3d 85 10 	movl   $0xf010853d,0x4(%esp)
f0105683:	f0 
f0105684:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0105687:	89 0c 24             	mov    %ecx,(%esp)
f010568a:	e8 9c 05 00 00       	call   f0105c2b <strcmp>
f010568f:	85 c0                	test   %eax,%eax
f0105691:	75 0f                	jne    f01056a2 <vprintfmt+0x1e4>
f0105693:	c7 05 78 24 12 f0 01 	movl   $0x1,0xf0122478
f010569a:	00 00 00 
f010569d:	e9 3f fe ff ff       	jmp    f01054e1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f01056a2:	c7 44 24 04 41 85 10 	movl   $0xf0108541,0x4(%esp)
f01056a9:	f0 
f01056aa:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f01056ad:	89 3c 24             	mov    %edi,(%esp)
f01056b0:	e8 76 05 00 00       	call   f0105c2b <strcmp>
f01056b5:	85 c0                	test   %eax,%eax
f01056b7:	75 0f                	jne    f01056c8 <vprintfmt+0x20a>
f01056b9:	c7 05 78 24 12 f0 06 	movl   $0x6,0xf0122478
f01056c0:	00 00 00 
f01056c3:	e9 19 fe ff ff       	jmp    f01054e1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f01056c8:	c7 44 24 04 45 85 10 	movl   $0xf0108545,0x4(%esp)
f01056cf:	f0 
f01056d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056d3:	89 04 24             	mov    %eax,(%esp)
f01056d6:	e8 50 05 00 00       	call   f0105c2b <strcmp>
f01056db:	85 c0                	test   %eax,%eax
f01056dd:	75 0f                	jne    f01056ee <vprintfmt+0x230>
f01056df:	c7 05 78 24 12 f0 07 	movl   $0x7,0xf0122478
f01056e6:	00 00 00 
f01056e9:	e9 f3 fd ff ff       	jmp    f01054e1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f01056ee:	c7 44 24 04 49 85 10 	movl   $0xf0108549,0x4(%esp)
f01056f5:	f0 
f01056f6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01056f9:	89 14 24             	mov    %edx,(%esp)
f01056fc:	e8 2a 05 00 00       	call   f0105c2b <strcmp>
f0105701:	83 f8 01             	cmp    $0x1,%eax
f0105704:	19 c0                	sbb    %eax,%eax
f0105706:	f7 d0                	not    %eax
f0105708:	83 c0 08             	add    $0x8,%eax
f010570b:	a3 78 24 12 f0       	mov    %eax,0xf0122478
f0105710:	e9 cc fd ff ff       	jmp    f01054e1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0105715:	8b 45 14             	mov    0x14(%ebp),%eax
f0105718:	8d 50 04             	lea    0x4(%eax),%edx
f010571b:	89 55 14             	mov    %edx,0x14(%ebp)
f010571e:	8b 00                	mov    (%eax),%eax
f0105720:	89 c2                	mov    %eax,%edx
f0105722:	c1 fa 1f             	sar    $0x1f,%edx
f0105725:	31 d0                	xor    %edx,%eax
f0105727:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105729:	83 f8 08             	cmp    $0x8,%eax
f010572c:	7f 0b                	jg     f0105739 <vprintfmt+0x27b>
f010572e:	8b 14 85 60 87 10 f0 	mov    -0xfef78a0(,%eax,4),%edx
f0105735:	85 d2                	test   %edx,%edx
f0105737:	75 23                	jne    f010575c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0105739:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010573d:	c7 44 24 08 4d 85 10 	movl   $0xf010854d,0x8(%esp)
f0105744:	f0 
f0105745:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105749:	8b 7d 08             	mov    0x8(%ebp),%edi
f010574c:	89 3c 24             	mov    %edi,(%esp)
f010574f:	e8 42 fd ff ff       	call   f0105496 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105754:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105757:	e9 85 fd ff ff       	jmp    f01054e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010575c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105760:	c7 44 24 08 f9 7c 10 	movl   $0xf0107cf9,0x8(%esp)
f0105767:	f0 
f0105768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010576c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010576f:	89 3c 24             	mov    %edi,(%esp)
f0105772:	e8 1f fd ff ff       	call   f0105496 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105777:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010577a:	e9 62 fd ff ff       	jmp    f01054e1 <vprintfmt+0x23>
f010577f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105782:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105785:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105788:	8b 45 14             	mov    0x14(%ebp),%eax
f010578b:	8d 50 04             	lea    0x4(%eax),%edx
f010578e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105791:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0105793:	85 f6                	test   %esi,%esi
f0105795:	b8 2e 85 10 f0       	mov    $0xf010852e,%eax
f010579a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f010579d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f01057a1:	7e 06                	jle    f01057a9 <vprintfmt+0x2eb>
f01057a3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f01057a7:	75 13                	jne    f01057bc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01057a9:	0f be 06             	movsbl (%esi),%eax
f01057ac:	83 c6 01             	add    $0x1,%esi
f01057af:	85 c0                	test   %eax,%eax
f01057b1:	0f 85 94 00 00 00    	jne    f010584b <vprintfmt+0x38d>
f01057b7:	e9 81 00 00 00       	jmp    f010583d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01057bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057c0:	89 34 24             	mov    %esi,(%esp)
f01057c3:	e8 73 03 00 00       	call   f0105b3b <strnlen>
f01057c8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01057cb:	29 c2                	sub    %eax,%edx
f01057cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01057d0:	85 d2                	test   %edx,%edx
f01057d2:	7e d5                	jle    f01057a9 <vprintfmt+0x2eb>
					putch(padc, putdat);
f01057d4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f01057d8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01057db:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01057de:	89 d6                	mov    %edx,%esi
f01057e0:	89 cf                	mov    %ecx,%edi
f01057e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057e6:	89 3c 24             	mov    %edi,(%esp)
f01057e9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01057ec:	83 ee 01             	sub    $0x1,%esi
f01057ef:	75 f1                	jne    f01057e2 <vprintfmt+0x324>
f01057f1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01057f4:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01057f7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01057fa:	eb ad                	jmp    f01057a9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01057fc:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0105800:	74 1b                	je     f010581d <vprintfmt+0x35f>
f0105802:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105805:	83 fa 5e             	cmp    $0x5e,%edx
f0105808:	76 13                	jbe    f010581d <vprintfmt+0x35f>
					putch('?', putdat);
f010580a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010580d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105811:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105818:	ff 55 08             	call   *0x8(%ebp)
f010581b:	eb 0d                	jmp    f010582a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f010581d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105820:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105824:	89 04 24             	mov    %eax,(%esp)
f0105827:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010582a:	83 eb 01             	sub    $0x1,%ebx
f010582d:	0f be 06             	movsbl (%esi),%eax
f0105830:	83 c6 01             	add    $0x1,%esi
f0105833:	85 c0                	test   %eax,%eax
f0105835:	75 1a                	jne    f0105851 <vprintfmt+0x393>
f0105837:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010583a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010583d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105840:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105844:	7f 1c                	jg     f0105862 <vprintfmt+0x3a4>
f0105846:	e9 96 fc ff ff       	jmp    f01054e1 <vprintfmt+0x23>
f010584b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010584e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105851:	85 ff                	test   %edi,%edi
f0105853:	78 a7                	js     f01057fc <vprintfmt+0x33e>
f0105855:	83 ef 01             	sub    $0x1,%edi
f0105858:	79 a2                	jns    f01057fc <vprintfmt+0x33e>
f010585a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010585d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105860:	eb db                	jmp    f010583d <vprintfmt+0x37f>
f0105862:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105865:	89 de                	mov    %ebx,%esi
f0105867:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010586a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010586e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105875:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105877:	83 eb 01             	sub    $0x1,%ebx
f010587a:	75 ee                	jne    f010586a <vprintfmt+0x3ac>
f010587c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010587e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0105881:	e9 5b fc ff ff       	jmp    f01054e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105886:	83 f9 01             	cmp    $0x1,%ecx
f0105889:	7e 10                	jle    f010589b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f010588b:	8b 45 14             	mov    0x14(%ebp),%eax
f010588e:	8d 50 08             	lea    0x8(%eax),%edx
f0105891:	89 55 14             	mov    %edx,0x14(%ebp)
f0105894:	8b 30                	mov    (%eax),%esi
f0105896:	8b 78 04             	mov    0x4(%eax),%edi
f0105899:	eb 26                	jmp    f01058c1 <vprintfmt+0x403>
	else if (lflag)
f010589b:	85 c9                	test   %ecx,%ecx
f010589d:	74 12                	je     f01058b1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f010589f:	8b 45 14             	mov    0x14(%ebp),%eax
f01058a2:	8d 50 04             	lea    0x4(%eax),%edx
f01058a5:	89 55 14             	mov    %edx,0x14(%ebp)
f01058a8:	8b 30                	mov    (%eax),%esi
f01058aa:	89 f7                	mov    %esi,%edi
f01058ac:	c1 ff 1f             	sar    $0x1f,%edi
f01058af:	eb 10                	jmp    f01058c1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f01058b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01058b4:	8d 50 04             	lea    0x4(%eax),%edx
f01058b7:	89 55 14             	mov    %edx,0x14(%ebp)
f01058ba:	8b 30                	mov    (%eax),%esi
f01058bc:	89 f7                	mov    %esi,%edi
f01058be:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01058c1:	85 ff                	test   %edi,%edi
f01058c3:	78 0e                	js     f01058d3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01058c5:	89 f0                	mov    %esi,%eax
f01058c7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01058c9:	be 0a 00 00 00       	mov    $0xa,%esi
f01058ce:	e9 84 00 00 00       	jmp    f0105957 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01058d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058d7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01058de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01058e1:	89 f0                	mov    %esi,%eax
f01058e3:	89 fa                	mov    %edi,%edx
f01058e5:	f7 d8                	neg    %eax
f01058e7:	83 d2 00             	adc    $0x0,%edx
f01058ea:	f7 da                	neg    %edx
			}
			base = 10;
f01058ec:	be 0a 00 00 00       	mov    $0xa,%esi
f01058f1:	eb 64                	jmp    f0105957 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01058f3:	89 ca                	mov    %ecx,%edx
f01058f5:	8d 45 14             	lea    0x14(%ebp),%eax
f01058f8:	e8 42 fb ff ff       	call   f010543f <getuint>
			base = 10;
f01058fd:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0105902:	eb 53                	jmp    f0105957 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105904:	89 ca                	mov    %ecx,%edx
f0105906:	8d 45 14             	lea    0x14(%ebp),%eax
f0105909:	e8 31 fb ff ff       	call   f010543f <getuint>
    			base = 8;
f010590e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0105913:	eb 42                	jmp    f0105957 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0105915:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105919:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105920:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105923:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105927:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010592e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105931:	8b 45 14             	mov    0x14(%ebp),%eax
f0105934:	8d 50 04             	lea    0x4(%eax),%edx
f0105937:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010593a:	8b 00                	mov    (%eax),%eax
f010593c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105941:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0105946:	eb 0f                	jmp    f0105957 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105948:	89 ca                	mov    %ecx,%edx
f010594a:	8d 45 14             	lea    0x14(%ebp),%eax
f010594d:	e8 ed fa ff ff       	call   f010543f <getuint>
			base = 16;
f0105952:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105957:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f010595b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010595f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105962:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105966:	89 74 24 08          	mov    %esi,0x8(%esp)
f010596a:	89 04 24             	mov    %eax,(%esp)
f010596d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105971:	89 da                	mov    %ebx,%edx
f0105973:	8b 45 08             	mov    0x8(%ebp),%eax
f0105976:	e8 e9 f9 ff ff       	call   f0105364 <printnum>
			break;
f010597b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010597e:	e9 5e fb ff ff       	jmp    f01054e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105983:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105987:	89 14 24             	mov    %edx,(%esp)
f010598a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010598d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105990:	e9 4c fb ff ff       	jmp    f01054e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105995:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105999:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01059a0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01059a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01059a7:	0f 84 34 fb ff ff    	je     f01054e1 <vprintfmt+0x23>
f01059ad:	83 ee 01             	sub    $0x1,%esi
f01059b0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01059b4:	75 f7                	jne    f01059ad <vprintfmt+0x4ef>
f01059b6:	e9 26 fb ff ff       	jmp    f01054e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01059bb:	83 c4 5c             	add    $0x5c,%esp
f01059be:	5b                   	pop    %ebx
f01059bf:	5e                   	pop    %esi
f01059c0:	5f                   	pop    %edi
f01059c1:	5d                   	pop    %ebp
f01059c2:	c3                   	ret    

f01059c3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01059c3:	55                   	push   %ebp
f01059c4:	89 e5                	mov    %esp,%ebp
f01059c6:	83 ec 28             	sub    $0x28,%esp
f01059c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01059cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01059cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01059d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01059d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01059d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01059e0:	85 c0                	test   %eax,%eax
f01059e2:	74 30                	je     f0105a14 <vsnprintf+0x51>
f01059e4:	85 d2                	test   %edx,%edx
f01059e6:	7e 2c                	jle    f0105a14 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01059e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01059ef:	8b 45 10             	mov    0x10(%ebp),%eax
f01059f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01059f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059fd:	c7 04 24 79 54 10 f0 	movl   $0xf0105479,(%esp)
f0105a04:	e8 b5 fa ff ff       	call   f01054be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a09:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a0c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105a12:	eb 05                	jmp    f0105a19 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105a19:	c9                   	leave  
f0105a1a:	c3                   	ret    

f0105a1b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a1b:	55                   	push   %ebp
f0105a1c:	89 e5                	mov    %esp,%ebp
f0105a1e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a21:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a24:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a28:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a2b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a36:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a39:	89 04 24             	mov    %eax,(%esp)
f0105a3c:	e8 82 ff ff ff       	call   f01059c3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a41:	c9                   	leave  
f0105a42:	c3                   	ret    
	...

f0105a50 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105a50:	55                   	push   %ebp
f0105a51:	89 e5                	mov    %esp,%ebp
f0105a53:	57                   	push   %edi
f0105a54:	56                   	push   %esi
f0105a55:	53                   	push   %ebx
f0105a56:	83 ec 1c             	sub    $0x1c,%esp
f0105a59:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105a5c:	85 c0                	test   %eax,%eax
f0105a5e:	74 10                	je     f0105a70 <readline+0x20>
		cprintf("%s", prompt);
f0105a60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a64:	c7 04 24 f9 7c 10 f0 	movl   $0xf0107cf9,(%esp)
f0105a6b:	e8 6e eb ff ff       	call   f01045de <cprintf>

	i = 0;
	echoing = iscons(0);
f0105a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105a77:	e8 1e ad ff ff       	call   f010079a <iscons>
f0105a7c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105a7e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105a83:	e8 01 ad ff ff       	call   f0100789 <getchar>
f0105a88:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105a8a:	85 c0                	test   %eax,%eax
f0105a8c:	79 17                	jns    f0105aa5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a92:	c7 04 24 84 87 10 f0 	movl   $0xf0108784,(%esp)
f0105a99:	e8 40 eb ff ff       	call   f01045de <cprintf>
			return NULL;
f0105a9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aa3:	eb 6d                	jmp    f0105b12 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105aa5:	83 f8 08             	cmp    $0x8,%eax
f0105aa8:	74 05                	je     f0105aaf <readline+0x5f>
f0105aaa:	83 f8 7f             	cmp    $0x7f,%eax
f0105aad:	75 19                	jne    f0105ac8 <readline+0x78>
f0105aaf:	85 f6                	test   %esi,%esi
f0105ab1:	7e 15                	jle    f0105ac8 <readline+0x78>
			if (echoing)
f0105ab3:	85 ff                	test   %edi,%edi
f0105ab5:	74 0c                	je     f0105ac3 <readline+0x73>
				cputchar('\b');
f0105ab7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105abe:	e8 b6 ac ff ff       	call   f0100779 <cputchar>
			i--;
f0105ac3:	83 ee 01             	sub    $0x1,%esi
f0105ac6:	eb bb                	jmp    f0105a83 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105ac8:	83 fb 1f             	cmp    $0x1f,%ebx
f0105acb:	7e 1f                	jle    f0105aec <readline+0x9c>
f0105acd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105ad3:	7f 17                	jg     f0105aec <readline+0x9c>
			if (echoing)
f0105ad5:	85 ff                	test   %edi,%edi
f0105ad7:	74 08                	je     f0105ae1 <readline+0x91>
				cputchar(c);
f0105ad9:	89 1c 24             	mov    %ebx,(%esp)
f0105adc:	e8 98 ac ff ff       	call   f0100779 <cputchar>
			buf[i++] = c;
f0105ae1:	88 9e e0 5a 22 f0    	mov    %bl,-0xfdda520(%esi)
f0105ae7:	83 c6 01             	add    $0x1,%esi
f0105aea:	eb 97                	jmp    f0105a83 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105aec:	83 fb 0a             	cmp    $0xa,%ebx
f0105aef:	74 05                	je     f0105af6 <readline+0xa6>
f0105af1:	83 fb 0d             	cmp    $0xd,%ebx
f0105af4:	75 8d                	jne    f0105a83 <readline+0x33>
			if (echoing)
f0105af6:	85 ff                	test   %edi,%edi
f0105af8:	74 0c                	je     f0105b06 <readline+0xb6>
				cputchar('\n');
f0105afa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105b01:	e8 73 ac ff ff       	call   f0100779 <cputchar>
			buf[i] = 0;
f0105b06:	c6 86 e0 5a 22 f0 00 	movb   $0x0,-0xfdda520(%esi)
			return buf;
f0105b0d:	b8 e0 5a 22 f0       	mov    $0xf0225ae0,%eax
		}
	}
}
f0105b12:	83 c4 1c             	add    $0x1c,%esp
f0105b15:	5b                   	pop    %ebx
f0105b16:	5e                   	pop    %esi
f0105b17:	5f                   	pop    %edi
f0105b18:	5d                   	pop    %ebp
f0105b19:	c3                   	ret    
f0105b1a:	00 00                	add    %al,(%eax)
f0105b1c:	00 00                	add    %al,(%eax)
	...

f0105b20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b20:	55                   	push   %ebp
f0105b21:	89 e5                	mov    %esp,%ebp
f0105b23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b26:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b2b:	80 3a 00             	cmpb   $0x0,(%edx)
f0105b2e:	74 09                	je     f0105b39 <strlen+0x19>
		n++;
f0105b30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105b37:	75 f7                	jne    f0105b30 <strlen+0x10>
		n++;
	return n;
}
f0105b39:	5d                   	pop    %ebp
f0105b3a:	c3                   	ret    

f0105b3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b3b:	55                   	push   %ebp
f0105b3c:	89 e5                	mov    %esp,%ebp
f0105b3e:	53                   	push   %ebx
f0105b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b45:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b4a:	85 c9                	test   %ecx,%ecx
f0105b4c:	74 1a                	je     f0105b68 <strnlen+0x2d>
f0105b4e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0105b51:	74 15                	je     f0105b68 <strnlen+0x2d>
f0105b53:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0105b58:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b5a:	39 ca                	cmp    %ecx,%edx
f0105b5c:	74 0a                	je     f0105b68 <strnlen+0x2d>
f0105b5e:	83 c2 01             	add    $0x1,%edx
f0105b61:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0105b66:	75 f0                	jne    f0105b58 <strnlen+0x1d>
		n++;
	return n;
}
f0105b68:	5b                   	pop    %ebx
f0105b69:	5d                   	pop    %ebp
f0105b6a:	c3                   	ret    

f0105b6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105b6b:	55                   	push   %ebp
f0105b6c:	89 e5                	mov    %esp,%ebp
f0105b6e:	53                   	push   %ebx
f0105b6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105b75:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b7a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105b7e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105b81:	83 c2 01             	add    $0x1,%edx
f0105b84:	84 c9                	test   %cl,%cl
f0105b86:	75 f2                	jne    f0105b7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105b88:	5b                   	pop    %ebx
f0105b89:	5d                   	pop    %ebp
f0105b8a:	c3                   	ret    

f0105b8b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105b8b:	55                   	push   %ebp
f0105b8c:	89 e5                	mov    %esp,%ebp
f0105b8e:	53                   	push   %ebx
f0105b8f:	83 ec 08             	sub    $0x8,%esp
f0105b92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105b95:	89 1c 24             	mov    %ebx,(%esp)
f0105b98:	e8 83 ff ff ff       	call   f0105b20 <strlen>
	strcpy(dst + len, src);
f0105b9d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ba0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ba4:	01 d8                	add    %ebx,%eax
f0105ba6:	89 04 24             	mov    %eax,(%esp)
f0105ba9:	e8 bd ff ff ff       	call   f0105b6b <strcpy>
	return dst;
}
f0105bae:	89 d8                	mov    %ebx,%eax
f0105bb0:	83 c4 08             	add    $0x8,%esp
f0105bb3:	5b                   	pop    %ebx
f0105bb4:	5d                   	pop    %ebp
f0105bb5:	c3                   	ret    

f0105bb6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105bb6:	55                   	push   %ebp
f0105bb7:	89 e5                	mov    %esp,%ebp
f0105bb9:	56                   	push   %esi
f0105bba:	53                   	push   %ebx
f0105bbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bc1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105bc4:	85 f6                	test   %esi,%esi
f0105bc6:	74 18                	je     f0105be0 <strncpy+0x2a>
f0105bc8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0105bcd:	0f b6 1a             	movzbl (%edx),%ebx
f0105bd0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105bd3:	80 3a 01             	cmpb   $0x1,(%edx)
f0105bd6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105bd9:	83 c1 01             	add    $0x1,%ecx
f0105bdc:	39 f1                	cmp    %esi,%ecx
f0105bde:	75 ed                	jne    f0105bcd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105be0:	5b                   	pop    %ebx
f0105be1:	5e                   	pop    %esi
f0105be2:	5d                   	pop    %ebp
f0105be3:	c3                   	ret    

f0105be4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105be4:	55                   	push   %ebp
f0105be5:	89 e5                	mov    %esp,%ebp
f0105be7:	57                   	push   %edi
f0105be8:	56                   	push   %esi
f0105be9:	53                   	push   %ebx
f0105bea:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105bed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105bf0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105bf3:	89 f8                	mov    %edi,%eax
f0105bf5:	85 f6                	test   %esi,%esi
f0105bf7:	74 2b                	je     f0105c24 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0105bf9:	83 fe 01             	cmp    $0x1,%esi
f0105bfc:	74 23                	je     f0105c21 <strlcpy+0x3d>
f0105bfe:	0f b6 0b             	movzbl (%ebx),%ecx
f0105c01:	84 c9                	test   %cl,%cl
f0105c03:	74 1c                	je     f0105c21 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105c05:	83 ee 02             	sub    $0x2,%esi
f0105c08:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105c0d:	88 08                	mov    %cl,(%eax)
f0105c0f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105c12:	39 f2                	cmp    %esi,%edx
f0105c14:	74 0b                	je     f0105c21 <strlcpy+0x3d>
f0105c16:	83 c2 01             	add    $0x1,%edx
f0105c19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105c1d:	84 c9                	test   %cl,%cl
f0105c1f:	75 ec                	jne    f0105c0d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0105c21:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105c24:	29 f8                	sub    %edi,%eax
}
f0105c26:	5b                   	pop    %ebx
f0105c27:	5e                   	pop    %esi
f0105c28:	5f                   	pop    %edi
f0105c29:	5d                   	pop    %ebp
f0105c2a:	c3                   	ret    

f0105c2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105c2b:	55                   	push   %ebp
f0105c2c:	89 e5                	mov    %esp,%ebp
f0105c2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105c34:	0f b6 01             	movzbl (%ecx),%eax
f0105c37:	84 c0                	test   %al,%al
f0105c39:	74 16                	je     f0105c51 <strcmp+0x26>
f0105c3b:	3a 02                	cmp    (%edx),%al
f0105c3d:	75 12                	jne    f0105c51 <strcmp+0x26>
		p++, q++;
f0105c3f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105c42:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0105c46:	84 c0                	test   %al,%al
f0105c48:	74 07                	je     f0105c51 <strcmp+0x26>
f0105c4a:	83 c1 01             	add    $0x1,%ecx
f0105c4d:	3a 02                	cmp    (%edx),%al
f0105c4f:	74 ee                	je     f0105c3f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c51:	0f b6 c0             	movzbl %al,%eax
f0105c54:	0f b6 12             	movzbl (%edx),%edx
f0105c57:	29 d0                	sub    %edx,%eax
}
f0105c59:	5d                   	pop    %ebp
f0105c5a:	c3                   	ret    

f0105c5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105c5b:	55                   	push   %ebp
f0105c5c:	89 e5                	mov    %esp,%ebp
f0105c5e:	53                   	push   %ebx
f0105c5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105c68:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105c6d:	85 d2                	test   %edx,%edx
f0105c6f:	74 28                	je     f0105c99 <strncmp+0x3e>
f0105c71:	0f b6 01             	movzbl (%ecx),%eax
f0105c74:	84 c0                	test   %al,%al
f0105c76:	74 24                	je     f0105c9c <strncmp+0x41>
f0105c78:	3a 03                	cmp    (%ebx),%al
f0105c7a:	75 20                	jne    f0105c9c <strncmp+0x41>
f0105c7c:	83 ea 01             	sub    $0x1,%edx
f0105c7f:	74 13                	je     f0105c94 <strncmp+0x39>
		n--, p++, q++;
f0105c81:	83 c1 01             	add    $0x1,%ecx
f0105c84:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105c87:	0f b6 01             	movzbl (%ecx),%eax
f0105c8a:	84 c0                	test   %al,%al
f0105c8c:	74 0e                	je     f0105c9c <strncmp+0x41>
f0105c8e:	3a 03                	cmp    (%ebx),%al
f0105c90:	74 ea                	je     f0105c7c <strncmp+0x21>
f0105c92:	eb 08                	jmp    f0105c9c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105c94:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105c99:	5b                   	pop    %ebx
f0105c9a:	5d                   	pop    %ebp
f0105c9b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c9c:	0f b6 01             	movzbl (%ecx),%eax
f0105c9f:	0f b6 13             	movzbl (%ebx),%edx
f0105ca2:	29 d0                	sub    %edx,%eax
f0105ca4:	eb f3                	jmp    f0105c99 <strncmp+0x3e>

f0105ca6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ca6:	55                   	push   %ebp
f0105ca7:	89 e5                	mov    %esp,%ebp
f0105ca9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105cb0:	0f b6 10             	movzbl (%eax),%edx
f0105cb3:	84 d2                	test   %dl,%dl
f0105cb5:	74 1c                	je     f0105cd3 <strchr+0x2d>
		if (*s == c)
f0105cb7:	38 ca                	cmp    %cl,%dl
f0105cb9:	75 09                	jne    f0105cc4 <strchr+0x1e>
f0105cbb:	eb 1b                	jmp    f0105cd8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105cbd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0105cc0:	38 ca                	cmp    %cl,%dl
f0105cc2:	74 14                	je     f0105cd8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105cc4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0105cc8:	84 d2                	test   %dl,%dl
f0105cca:	75 f1                	jne    f0105cbd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0105ccc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cd1:	eb 05                	jmp    f0105cd8 <strchr+0x32>
f0105cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cd8:	5d                   	pop    %ebp
f0105cd9:	c3                   	ret    

f0105cda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105cda:	55                   	push   %ebp
f0105cdb:	89 e5                	mov    %esp,%ebp
f0105cdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ce0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ce4:	0f b6 10             	movzbl (%eax),%edx
f0105ce7:	84 d2                	test   %dl,%dl
f0105ce9:	74 14                	je     f0105cff <strfind+0x25>
		if (*s == c)
f0105ceb:	38 ca                	cmp    %cl,%dl
f0105ced:	75 06                	jne    f0105cf5 <strfind+0x1b>
f0105cef:	eb 0e                	jmp    f0105cff <strfind+0x25>
f0105cf1:	38 ca                	cmp    %cl,%dl
f0105cf3:	74 0a                	je     f0105cff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105cf5:	83 c0 01             	add    $0x1,%eax
f0105cf8:	0f b6 10             	movzbl (%eax),%edx
f0105cfb:	84 d2                	test   %dl,%dl
f0105cfd:	75 f2                	jne    f0105cf1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0105cff:	5d                   	pop    %ebp
f0105d00:	c3                   	ret    

f0105d01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105d01:	55                   	push   %ebp
f0105d02:	89 e5                	mov    %esp,%ebp
f0105d04:	83 ec 0c             	sub    $0xc,%esp
f0105d07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105d0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105d0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105d10:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d13:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d19:	85 c9                	test   %ecx,%ecx
f0105d1b:	74 30                	je     f0105d4d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d23:	75 25                	jne    f0105d4a <memset+0x49>
f0105d25:	f6 c1 03             	test   $0x3,%cl
f0105d28:	75 20                	jne    f0105d4a <memset+0x49>
		c &= 0xFF;
f0105d2a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d2d:	89 d3                	mov    %edx,%ebx
f0105d2f:	c1 e3 08             	shl    $0x8,%ebx
f0105d32:	89 d6                	mov    %edx,%esi
f0105d34:	c1 e6 18             	shl    $0x18,%esi
f0105d37:	89 d0                	mov    %edx,%eax
f0105d39:	c1 e0 10             	shl    $0x10,%eax
f0105d3c:	09 f0                	or     %esi,%eax
f0105d3e:	09 d0                	or     %edx,%eax
f0105d40:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105d42:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105d45:	fc                   	cld    
f0105d46:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d48:	eb 03                	jmp    f0105d4d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d4a:	fc                   	cld    
f0105d4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d4d:	89 f8                	mov    %edi,%eax
f0105d4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105d52:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105d55:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105d58:	89 ec                	mov    %ebp,%esp
f0105d5a:	5d                   	pop    %ebp
f0105d5b:	c3                   	ret    

f0105d5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d5c:	55                   	push   %ebp
f0105d5d:	89 e5                	mov    %esp,%ebp
f0105d5f:	83 ec 08             	sub    $0x8,%esp
f0105d62:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105d65:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105d68:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d6b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d71:	39 c6                	cmp    %eax,%esi
f0105d73:	73 36                	jae    f0105dab <memmove+0x4f>
f0105d75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d78:	39 d0                	cmp    %edx,%eax
f0105d7a:	73 2f                	jae    f0105dab <memmove+0x4f>
		s += n;
		d += n;
f0105d7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d7f:	f6 c2 03             	test   $0x3,%dl
f0105d82:	75 1b                	jne    f0105d9f <memmove+0x43>
f0105d84:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d8a:	75 13                	jne    f0105d9f <memmove+0x43>
f0105d8c:	f6 c1 03             	test   $0x3,%cl
f0105d8f:	75 0e                	jne    f0105d9f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105d91:	83 ef 04             	sub    $0x4,%edi
f0105d94:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105d97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105d9a:	fd                   	std    
f0105d9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d9d:	eb 09                	jmp    f0105da8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105d9f:	83 ef 01             	sub    $0x1,%edi
f0105da2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105da5:	fd                   	std    
f0105da6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105da8:	fc                   	cld    
f0105da9:	eb 20                	jmp    f0105dcb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105dab:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105db1:	75 13                	jne    f0105dc6 <memmove+0x6a>
f0105db3:	a8 03                	test   $0x3,%al
f0105db5:	75 0f                	jne    f0105dc6 <memmove+0x6a>
f0105db7:	f6 c1 03             	test   $0x3,%cl
f0105dba:	75 0a                	jne    f0105dc6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105dbc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105dbf:	89 c7                	mov    %eax,%edi
f0105dc1:	fc                   	cld    
f0105dc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105dc4:	eb 05                	jmp    f0105dcb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105dc6:	89 c7                	mov    %eax,%edi
f0105dc8:	fc                   	cld    
f0105dc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105dcb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105dce:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105dd1:	89 ec                	mov    %ebp,%esp
f0105dd3:	5d                   	pop    %ebp
f0105dd4:	c3                   	ret    

f0105dd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105dd5:	55                   	push   %ebp
f0105dd6:	89 e5                	mov    %esp,%ebp
f0105dd8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ddb:	8b 45 10             	mov    0x10(%ebp),%eax
f0105dde:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105de2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105de5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105de9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dec:	89 04 24             	mov    %eax,(%esp)
f0105def:	e8 68 ff ff ff       	call   f0105d5c <memmove>
}
f0105df4:	c9                   	leave  
f0105df5:	c3                   	ret    

f0105df6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105df6:	55                   	push   %ebp
f0105df7:	89 e5                	mov    %esp,%ebp
f0105df9:	57                   	push   %edi
f0105dfa:	56                   	push   %esi
f0105dfb:	53                   	push   %ebx
f0105dfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105dff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e02:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105e05:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e0a:	85 ff                	test   %edi,%edi
f0105e0c:	74 37                	je     f0105e45 <memcmp+0x4f>
		if (*s1 != *s2)
f0105e0e:	0f b6 03             	movzbl (%ebx),%eax
f0105e11:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e14:	83 ef 01             	sub    $0x1,%edi
f0105e17:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0105e1c:	38 c8                	cmp    %cl,%al
f0105e1e:	74 1c                	je     f0105e3c <memcmp+0x46>
f0105e20:	eb 10                	jmp    f0105e32 <memcmp+0x3c>
f0105e22:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0105e27:	83 c2 01             	add    $0x1,%edx
f0105e2a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0105e2e:	38 c8                	cmp    %cl,%al
f0105e30:	74 0a                	je     f0105e3c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0105e32:	0f b6 c0             	movzbl %al,%eax
f0105e35:	0f b6 c9             	movzbl %cl,%ecx
f0105e38:	29 c8                	sub    %ecx,%eax
f0105e3a:	eb 09                	jmp    f0105e45 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e3c:	39 fa                	cmp    %edi,%edx
f0105e3e:	75 e2                	jne    f0105e22 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105e40:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e45:	5b                   	pop    %ebx
f0105e46:	5e                   	pop    %esi
f0105e47:	5f                   	pop    %edi
f0105e48:	5d                   	pop    %ebp
f0105e49:	c3                   	ret    

f0105e4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e4a:	55                   	push   %ebp
f0105e4b:	89 e5                	mov    %esp,%ebp
f0105e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105e50:	89 c2                	mov    %eax,%edx
f0105e52:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105e55:	39 d0                	cmp    %edx,%eax
f0105e57:	73 19                	jae    f0105e72 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0105e5d:	38 08                	cmp    %cl,(%eax)
f0105e5f:	75 06                	jne    f0105e67 <memfind+0x1d>
f0105e61:	eb 0f                	jmp    f0105e72 <memfind+0x28>
f0105e63:	38 08                	cmp    %cl,(%eax)
f0105e65:	74 0b                	je     f0105e72 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e67:	83 c0 01             	add    $0x1,%eax
f0105e6a:	39 d0                	cmp    %edx,%eax
f0105e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105e70:	75 f1                	jne    f0105e63 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105e72:	5d                   	pop    %ebp
f0105e73:	c3                   	ret    

f0105e74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e74:	55                   	push   %ebp
f0105e75:	89 e5                	mov    %esp,%ebp
f0105e77:	57                   	push   %edi
f0105e78:	56                   	push   %esi
f0105e79:	53                   	push   %ebx
f0105e7a:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e80:	0f b6 02             	movzbl (%edx),%eax
f0105e83:	3c 20                	cmp    $0x20,%al
f0105e85:	74 04                	je     f0105e8b <strtol+0x17>
f0105e87:	3c 09                	cmp    $0x9,%al
f0105e89:	75 0e                	jne    f0105e99 <strtol+0x25>
		s++;
f0105e8b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e8e:	0f b6 02             	movzbl (%edx),%eax
f0105e91:	3c 20                	cmp    $0x20,%al
f0105e93:	74 f6                	je     f0105e8b <strtol+0x17>
f0105e95:	3c 09                	cmp    $0x9,%al
f0105e97:	74 f2                	je     f0105e8b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105e99:	3c 2b                	cmp    $0x2b,%al
f0105e9b:	75 0a                	jne    f0105ea7 <strtol+0x33>
		s++;
f0105e9d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105ea0:	bf 00 00 00 00       	mov    $0x0,%edi
f0105ea5:	eb 10                	jmp    f0105eb7 <strtol+0x43>
f0105ea7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105eac:	3c 2d                	cmp    $0x2d,%al
f0105eae:	75 07                	jne    f0105eb7 <strtol+0x43>
		s++, neg = 1;
f0105eb0:	83 c2 01             	add    $0x1,%edx
f0105eb3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105eb7:	85 db                	test   %ebx,%ebx
f0105eb9:	0f 94 c0             	sete   %al
f0105ebc:	74 05                	je     f0105ec3 <strtol+0x4f>
f0105ebe:	83 fb 10             	cmp    $0x10,%ebx
f0105ec1:	75 15                	jne    f0105ed8 <strtol+0x64>
f0105ec3:	80 3a 30             	cmpb   $0x30,(%edx)
f0105ec6:	75 10                	jne    f0105ed8 <strtol+0x64>
f0105ec8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105ecc:	75 0a                	jne    f0105ed8 <strtol+0x64>
		s += 2, base = 16;
f0105ece:	83 c2 02             	add    $0x2,%edx
f0105ed1:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105ed6:	eb 13                	jmp    f0105eeb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0105ed8:	84 c0                	test   %al,%al
f0105eda:	74 0f                	je     f0105eeb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105edc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105ee1:	80 3a 30             	cmpb   $0x30,(%edx)
f0105ee4:	75 05                	jne    f0105eeb <strtol+0x77>
		s++, base = 8;
f0105ee6:	83 c2 01             	add    $0x1,%edx
f0105ee9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0105eeb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ef0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105ef2:	0f b6 0a             	movzbl (%edx),%ecx
f0105ef5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105ef8:	80 fb 09             	cmp    $0x9,%bl
f0105efb:	77 08                	ja     f0105f05 <strtol+0x91>
			dig = *s - '0';
f0105efd:	0f be c9             	movsbl %cl,%ecx
f0105f00:	83 e9 30             	sub    $0x30,%ecx
f0105f03:	eb 1e                	jmp    f0105f23 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0105f05:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105f08:	80 fb 19             	cmp    $0x19,%bl
f0105f0b:	77 08                	ja     f0105f15 <strtol+0xa1>
			dig = *s - 'a' + 10;
f0105f0d:	0f be c9             	movsbl %cl,%ecx
f0105f10:	83 e9 57             	sub    $0x57,%ecx
f0105f13:	eb 0e                	jmp    f0105f23 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0105f15:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105f18:	80 fb 19             	cmp    $0x19,%bl
f0105f1b:	77 14                	ja     f0105f31 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105f1d:	0f be c9             	movsbl %cl,%ecx
f0105f20:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105f23:	39 f1                	cmp    %esi,%ecx
f0105f25:	7d 0e                	jge    f0105f35 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105f27:	83 c2 01             	add    $0x1,%edx
f0105f2a:	0f af c6             	imul   %esi,%eax
f0105f2d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105f2f:	eb c1                	jmp    f0105ef2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105f31:	89 c1                	mov    %eax,%ecx
f0105f33:	eb 02                	jmp    f0105f37 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105f35:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105f37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f3b:	74 05                	je     f0105f42 <strtol+0xce>
		*endptr = (char *) s;
f0105f3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f40:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105f42:	89 ca                	mov    %ecx,%edx
f0105f44:	f7 da                	neg    %edx
f0105f46:	85 ff                	test   %edi,%edi
f0105f48:	0f 45 c2             	cmovne %edx,%eax
}
f0105f4b:	5b                   	pop    %ebx
f0105f4c:	5e                   	pop    %esi
f0105f4d:	5f                   	pop    %edi
f0105f4e:	5d                   	pop    %ebp
f0105f4f:	c3                   	ret    

f0105f50 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f50:	fa                   	cli    

	xorw    %ax, %ax
f0105f51:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f53:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f55:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f57:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f59:	0f 01 16             	lgdtl  (%esi)
f0105f5c:	74 70                	je     f0105fce <mpentry_end+0x4>
	movl    %cr0, %eax
f0105f5e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f61:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f65:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f68:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f6e:	08 00                	or     %al,(%eax)

f0105f70 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f70:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f74:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f76:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f78:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f7a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f7e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f80:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f82:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105f87:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105f8a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105f8d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105f92:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105f95:	8b 25 e4 5e 22 f0    	mov    0xf0225ee4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f9b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105fa0:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0105fa5:	ff d0                	call   *%eax

f0105fa7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105fa7:	eb fe                	jmp    f0105fa7 <spin>
f0105fa9:	8d 76 00             	lea    0x0(%esi),%esi

f0105fac <gdt>:
	...
f0105fb4:	ff                   	(bad)  
f0105fb5:	ff 00                	incl   (%eax)
f0105fb7:	00 00                	add    %al,(%eax)
f0105fb9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105fc0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105fc4 <gdtdesc>:
f0105fc4:	17                   	pop    %ss
f0105fc5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105fca <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105fca:	90                   	nop
f0105fcb:	00 00                	add    %al,(%eax)
f0105fcd:	00 00                	add    %al,(%eax)
	...

f0105fd0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105fd0:	55                   	push   %ebp
f0105fd1:	89 e5                	mov    %esp,%ebp
f0105fd3:	56                   	push   %esi
f0105fd4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0105fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105fda:	85 d2                	test   %edx,%edx
f0105fdc:	7e 12                	jle    f0105ff0 <sum+0x20>
f0105fde:	b9 00 00 00 00       	mov    $0x0,%ecx
		sum += ((uint8_t *)addr)[i];
f0105fe3:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105fe7:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105fe9:	83 c1 01             	add    $0x1,%ecx
f0105fec:	39 d1                	cmp    %edx,%ecx
f0105fee:	75 f3                	jne    f0105fe3 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105ff0:	89 d8                	mov    %ebx,%eax
f0105ff2:	5b                   	pop    %ebx
f0105ff3:	5e                   	pop    %esi
f0105ff4:	5d                   	pop    %ebp
f0105ff5:	c3                   	ret    

f0105ff6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105ff6:	55                   	push   %ebp
f0105ff7:	89 e5                	mov    %esp,%ebp
f0105ff9:	56                   	push   %esi
f0105ffa:	53                   	push   %ebx
f0105ffb:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ffe:	8b 0d e8 5e 22 f0    	mov    0xf0225ee8,%ecx
f0106004:	89 c3                	mov    %eax,%ebx
f0106006:	c1 eb 0c             	shr    $0xc,%ebx
f0106009:	39 cb                	cmp    %ecx,%ebx
f010600b:	72 20                	jb     f010602d <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010600d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106011:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0106018:	f0 
f0106019:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106020:	00 
f0106021:	c7 04 24 21 89 10 f0 	movl   $0xf0108921,(%esp)
f0106028:	e8 13 a0 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010602d:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106030:	89 f2                	mov    %esi,%edx
f0106032:	c1 ea 0c             	shr    $0xc,%edx
f0106035:	39 d1                	cmp    %edx,%ecx
f0106037:	77 20                	ja     f0106059 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106039:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010603d:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0106044:	f0 
f0106045:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010604c:	00 
f010604d:	c7 04 24 21 89 10 f0 	movl   $0xf0108921,(%esp)
f0106054:	e8 e7 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106059:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010605f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106065:	39 f3                	cmp    %esi,%ebx
f0106067:	73 3a                	jae    f01060a3 <mpsearch1+0xad>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106069:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106070:	00 
f0106071:	c7 44 24 04 31 89 10 	movl   $0xf0108931,0x4(%esp)
f0106078:	f0 
f0106079:	89 1c 24             	mov    %ebx,(%esp)
f010607c:	e8 75 fd ff ff       	call   f0105df6 <memcmp>
f0106081:	85 c0                	test   %eax,%eax
f0106083:	75 10                	jne    f0106095 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106085:	ba 10 00 00 00       	mov    $0x10,%edx
f010608a:	89 d8                	mov    %ebx,%eax
f010608c:	e8 3f ff ff ff       	call   f0105fd0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106091:	84 c0                	test   %al,%al
f0106093:	74 13                	je     f01060a8 <mpsearch1+0xb2>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106095:	83 c3 10             	add    $0x10,%ebx
f0106098:	39 f3                	cmp    %esi,%ebx
f010609a:	72 cd                	jb     f0106069 <mpsearch1+0x73>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010609c:	bb 00 00 00 00       	mov    $0x0,%ebx
f01060a1:	eb 05                	jmp    f01060a8 <mpsearch1+0xb2>
f01060a3:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01060a8:	89 d8                	mov    %ebx,%eax
f01060aa:	83 c4 10             	add    $0x10,%esp
f01060ad:	5b                   	pop    %ebx
f01060ae:	5e                   	pop    %esi
f01060af:	5d                   	pop    %ebp
f01060b0:	c3                   	ret    

f01060b1 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01060b1:	55                   	push   %ebp
f01060b2:	89 e5                	mov    %esp,%ebp
f01060b4:	57                   	push   %edi
f01060b5:	56                   	push   %esi
f01060b6:	53                   	push   %ebx
f01060b7:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01060ba:	c7 05 c0 63 22 f0 20 	movl   $0xf0226020,0xf02263c0
f01060c1:	60 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01060c4:	83 3d e8 5e 22 f0 00 	cmpl   $0x0,0xf0225ee8
f01060cb:	75 24                	jne    f01060f1 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060cd:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01060d4:	00 
f01060d5:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01060dc:	f0 
f01060dd:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01060e4:	00 
f01060e5:	c7 04 24 21 89 10 f0 	movl   $0xf0108921,(%esp)
f01060ec:	e8 4f 9f ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060f1:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060f8:	85 c0                	test   %eax,%eax
f01060fa:	74 16                	je     f0106112 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01060fc:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01060ff:	ba 00 04 00 00       	mov    $0x400,%edx
f0106104:	e8 ed fe ff ff       	call   f0105ff6 <mpsearch1>
f0106109:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010610c:	85 c0                	test   %eax,%eax
f010610e:	75 3c                	jne    f010614c <mp_init+0x9b>
f0106110:	eb 20                	jmp    f0106132 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106112:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106119:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010611c:	2d 00 04 00 00       	sub    $0x400,%eax
f0106121:	ba 00 04 00 00       	mov    $0x400,%edx
f0106126:	e8 cb fe ff ff       	call   f0105ff6 <mpsearch1>
f010612b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010612e:	85 c0                	test   %eax,%eax
f0106130:	75 1a                	jne    f010614c <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106132:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106137:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010613c:	e8 b5 fe ff ff       	call   f0105ff6 <mpsearch1>
f0106141:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106144:	85 c0                	test   %eax,%eax
f0106146:	0f 84 24 02 00 00    	je     f0106370 <mp_init+0x2bf>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010614c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010614f:	8b 78 04             	mov    0x4(%eax),%edi
f0106152:	85 ff                	test   %edi,%edi
f0106154:	74 06                	je     f010615c <mp_init+0xab>
f0106156:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010615a:	74 11                	je     f010616d <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010615c:	c7 04 24 94 87 10 f0 	movl   $0xf0108794,(%esp)
f0106163:	e8 76 e4 ff ff       	call   f01045de <cprintf>
f0106168:	e9 03 02 00 00       	jmp    f0106370 <mp_init+0x2bf>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010616d:	89 f8                	mov    %edi,%eax
f010616f:	c1 e8 0c             	shr    $0xc,%eax
f0106172:	3b 05 e8 5e 22 f0    	cmp    0xf0225ee8,%eax
f0106178:	72 20                	jb     f010619a <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010617a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010617e:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0106185:	f0 
f0106186:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010618d:	00 
f010618e:	c7 04 24 21 89 10 f0 	movl   $0xf0108921,(%esp)
f0106195:	e8 a6 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010619a:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01061a0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01061a7:	00 
f01061a8:	c7 44 24 04 36 89 10 	movl   $0xf0108936,0x4(%esp)
f01061af:	f0 
f01061b0:	89 3c 24             	mov    %edi,(%esp)
f01061b3:	e8 3e fc ff ff       	call   f0105df6 <memcmp>
f01061b8:	85 c0                	test   %eax,%eax
f01061ba:	74 11                	je     f01061cd <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01061bc:	c7 04 24 c4 87 10 f0 	movl   $0xf01087c4,(%esp)
f01061c3:	e8 16 e4 ff ff       	call   f01045de <cprintf>
f01061c8:	e9 a3 01 00 00       	jmp    f0106370 <mp_init+0x2bf>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01061cd:	0f b7 5f 04          	movzwl 0x4(%edi),%ebx
f01061d1:	0f b7 d3             	movzwl %bx,%edx
f01061d4:	89 f8                	mov    %edi,%eax
f01061d6:	e8 f5 fd ff ff       	call   f0105fd0 <sum>
f01061db:	84 c0                	test   %al,%al
f01061dd:	74 11                	je     f01061f0 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061df:	c7 04 24 f8 87 10 f0 	movl   $0xf01087f8,(%esp)
f01061e6:	e8 f3 e3 ff ff       	call   f01045de <cprintf>
f01061eb:	e9 80 01 00 00       	jmp    f0106370 <mp_init+0x2bf>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01061f0:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f01061f4:	3c 01                	cmp    $0x1,%al
f01061f6:	74 1c                	je     f0106214 <mp_init+0x163>
f01061f8:	3c 04                	cmp    $0x4,%al
f01061fa:	74 18                	je     f0106214 <mp_init+0x163>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061fc:	0f b6 c0             	movzbl %al,%eax
f01061ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106203:	c7 04 24 1c 88 10 f0 	movl   $0xf010881c,(%esp)
f010620a:	e8 cf e3 ff ff       	call   f01045de <cprintf>
f010620f:	e9 5c 01 00 00       	jmp    f0106370 <mp_init+0x2bf>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106214:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106218:	0f b7 db             	movzwl %bx,%ebx
f010621b:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010621e:	e8 ad fd ff ff       	call   f0105fd0 <sum>
f0106223:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106226:	74 11                	je     f0106239 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106228:	c7 04 24 3c 88 10 f0 	movl   $0xf010883c,(%esp)
f010622f:	e8 aa e3 ff ff       	call   f01045de <cprintf>
f0106234:	e9 37 01 00 00       	jmp    f0106370 <mp_init+0x2bf>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106239:	85 ff                	test   %edi,%edi
f010623b:	0f 84 2f 01 00 00    	je     f0106370 <mp_init+0x2bf>
		return;
	ismp = 1;
f0106241:	c7 05 00 60 22 f0 01 	movl   $0x1,0xf0226000
f0106248:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010624b:	8b 47 24             	mov    0x24(%edi),%eax
f010624e:	a3 00 70 26 f0       	mov    %eax,0xf0267000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106253:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106258:	0f 84 97 00 00 00    	je     f01062f5 <mp_init+0x244>
f010625e:	8d 77 2c             	lea    0x2c(%edi),%esi
f0106261:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (*p) {
f0106266:	0f b6 06             	movzbl (%esi),%eax
f0106269:	84 c0                	test   %al,%al
f010626b:	74 06                	je     f0106273 <mp_init+0x1c2>
f010626d:	3c 04                	cmp    $0x4,%al
f010626f:	77 54                	ja     f01062c5 <mp_init+0x214>
f0106271:	eb 4d                	jmp    f01062c0 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106273:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106277:	74 11                	je     f010628a <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106279:	6b 05 c4 63 22 f0 74 	imul   $0x74,0xf02263c4,%eax
f0106280:	05 20 60 22 f0       	add    $0xf0226020,%eax
f0106285:	a3 c0 63 22 f0       	mov    %eax,0xf02263c0
			if (ncpu < NCPU) {
f010628a:	a1 c4 63 22 f0       	mov    0xf02263c4,%eax
f010628f:	83 f8 07             	cmp    $0x7,%eax
f0106292:	7f 13                	jg     f01062a7 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0106294:	6b d0 74             	imul   $0x74,%eax,%edx
f0106297:	88 82 20 60 22 f0    	mov    %al,-0xfdd9fe0(%edx)
				ncpu++;
f010629d:	83 c0 01             	add    $0x1,%eax
f01062a0:	a3 c4 63 22 f0       	mov    %eax,0xf02263c4
f01062a5:	eb 14                	jmp    f01062bb <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01062a7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01062ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062af:	c7 04 24 6c 88 10 f0 	movl   $0xf010886c,(%esp)
f01062b6:	e8 23 e3 ff ff       	call   f01045de <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01062bb:	83 c6 14             	add    $0x14,%esi
			continue;
f01062be:	eb 26                	jmp    f01062e6 <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01062c0:	83 c6 08             	add    $0x8,%esi
			continue;
f01062c3:	eb 21                	jmp    f01062e6 <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01062c5:	0f b6 c0             	movzbl %al,%eax
f01062c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062cc:	c7 04 24 94 88 10 f0 	movl   $0xf0108894,(%esp)
f01062d3:	e8 06 e3 ff ff       	call   f01045de <cprintf>
			ismp = 0;
f01062d8:	c7 05 00 60 22 f0 00 	movl   $0x0,0xf0226000
f01062df:	00 00 00 
			i = conf->entry;
f01062e2:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062e6:	83 c3 01             	add    $0x1,%ebx
f01062e9:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f01062ed:	39 d8                	cmp    %ebx,%eax
f01062ef:	0f 87 71 ff ff ff    	ja     f0106266 <mp_init+0x1b5>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062f5:	a1 c0 63 22 f0       	mov    0xf02263c0,%eax
f01062fa:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106301:	83 3d 00 60 22 f0 00 	cmpl   $0x0,0xf0226000
f0106308:	75 22                	jne    f010632c <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010630a:	c7 05 c4 63 22 f0 01 	movl   $0x1,0xf02263c4
f0106311:	00 00 00 
		lapicaddr = 0;
f0106314:	c7 05 00 70 26 f0 00 	movl   $0x0,0xf0267000
f010631b:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010631e:	c7 04 24 b4 88 10 f0 	movl   $0xf01088b4,(%esp)
f0106325:	e8 b4 e2 ff ff       	call   f01045de <cprintf>
		return;
f010632a:	eb 44                	jmp    f0106370 <mp_init+0x2bf>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010632c:	8b 15 c4 63 22 f0    	mov    0xf02263c4,%edx
f0106332:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106336:	0f b6 00             	movzbl (%eax),%eax
f0106339:	89 44 24 04          	mov    %eax,0x4(%esp)
f010633d:	c7 04 24 3b 89 10 f0 	movl   $0xf010893b,(%esp)
f0106344:	e8 95 e2 ff ff       	call   f01045de <cprintf>

	if (mp->imcrp) {
f0106349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010634c:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106350:	74 1e                	je     f0106370 <mp_init+0x2bf>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106352:	c7 04 24 e0 88 10 f0 	movl   $0xf01088e0,(%esp)
f0106359:	e8 80 e2 ff ff       	call   f01045de <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010635e:	ba 22 00 00 00       	mov    $0x22,%edx
f0106363:	b8 70 00 00 00       	mov    $0x70,%eax
f0106368:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106369:	b2 23                	mov    $0x23,%dl
f010636b:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010636c:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010636f:	ee                   	out    %al,(%dx)
	}
}
f0106370:	83 c4 2c             	add    $0x2c,%esp
f0106373:	5b                   	pop    %ebx
f0106374:	5e                   	pop    %esi
f0106375:	5f                   	pop    %edi
f0106376:	5d                   	pop    %ebp
f0106377:	c3                   	ret    

f0106378 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106378:	55                   	push   %ebp
f0106379:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010637b:	c1 e0 02             	shl    $0x2,%eax
f010637e:	03 05 04 70 26 f0    	add    0xf0267004,%eax
f0106384:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106386:	a1 04 70 26 f0       	mov    0xf0267004,%eax
f010638b:	8b 40 20             	mov    0x20(%eax),%eax
}
f010638e:	5d                   	pop    %ebp
f010638f:	c3                   	ret    

f0106390 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106390:	55                   	push   %ebp
f0106391:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106393:	8b 15 04 70 26 f0    	mov    0xf0267004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106399:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
cpunum(void)
{
	if (lapic)
f010639e:	85 d2                	test   %edx,%edx
f01063a0:	74 06                	je     f01063a8 <cpunum+0x18>
		return lapic[ID] >> 24;
f01063a2:	8b 42 20             	mov    0x20(%edx),%eax
f01063a5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01063a8:	5d                   	pop    %ebp
f01063a9:	c3                   	ret    

f01063aa <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01063aa:	55                   	push   %ebp
f01063ab:	89 e5                	mov    %esp,%ebp
f01063ad:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01063b0:	a1 00 70 26 f0       	mov    0xf0267000,%eax
f01063b5:	85 c0                	test   %eax,%eax
f01063b7:	0f 84 1c 01 00 00    	je     f01064d9 <lapic_init+0x12f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01063bd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01063c4:	00 
f01063c5:	89 04 24             	mov    %eax,(%esp)
f01063c8:	e8 17 b7 ff ff       	call   f0101ae4 <mmio_map_region>
f01063cd:	a3 04 70 26 f0       	mov    %eax,0xf0267004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01063d2:	ba 27 01 00 00       	mov    $0x127,%edx
f01063d7:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01063dc:	e8 97 ff ff ff       	call   f0106378 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01063e1:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063e6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063eb:	e8 88 ff ff ff       	call   f0106378 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063f0:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063f5:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063fa:	e8 79 ff ff ff       	call   f0106378 <lapicw>
	lapicw(TICR, 10000000); 
f01063ff:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106404:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106409:	e8 6a ff ff ff       	call   f0106378 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010640e:	e8 7d ff ff ff       	call   f0106390 <cpunum>
f0106413:	6b c0 74             	imul   $0x74,%eax,%eax
f0106416:	05 20 60 22 f0       	add    $0xf0226020,%eax
f010641b:	39 05 c0 63 22 f0    	cmp    %eax,0xf02263c0
f0106421:	74 0f                	je     f0106432 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106423:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106428:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010642d:	e8 46 ff ff ff       	call   f0106378 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106432:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106437:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010643c:	e8 37 ff ff ff       	call   f0106378 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106441:	a1 04 70 26 f0       	mov    0xf0267004,%eax
f0106446:	8b 40 30             	mov    0x30(%eax),%eax
f0106449:	c1 e8 10             	shr    $0x10,%eax
f010644c:	3c 03                	cmp    $0x3,%al
f010644e:	76 0f                	jbe    f010645f <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106450:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106455:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010645a:	e8 19 ff ff ff       	call   f0106378 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010645f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106464:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106469:	e8 0a ff ff ff       	call   f0106378 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010646e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106473:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106478:	e8 fb fe ff ff       	call   f0106378 <lapicw>
	lapicw(ESR, 0);
f010647d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106482:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106487:	e8 ec fe ff ff       	call   f0106378 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010648c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106491:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106496:	e8 dd fe ff ff       	call   f0106378 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010649b:	ba 00 00 00 00       	mov    $0x0,%edx
f01064a0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064a5:	e8 ce fe ff ff       	call   f0106378 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01064aa:	ba 00 85 08 00       	mov    $0x88500,%edx
f01064af:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064b4:	e8 bf fe ff ff       	call   f0106378 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01064b9:	8b 15 04 70 26 f0    	mov    0xf0267004,%edx
f01064bf:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01064c5:	f6 c4 10             	test   $0x10,%ah
f01064c8:	75 f5                	jne    f01064bf <lapic_init+0x115>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01064ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01064cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01064d4:	e8 9f fe ff ff       	call   f0106378 <lapicw>
}
f01064d9:	c9                   	leave  
f01064da:	c3                   	ret    

f01064db <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01064db:	55                   	push   %ebp
f01064dc:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01064de:	83 3d 04 70 26 f0 00 	cmpl   $0x0,0xf0267004
f01064e5:	74 0f                	je     f01064f6 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01064e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01064ec:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064f1:	e8 82 fe ff ff       	call   f0106378 <lapicw>
}
f01064f6:	5d                   	pop    %ebp
f01064f7:	c3                   	ret    

f01064f8 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064f8:	55                   	push   %ebp
f01064f9:	89 e5                	mov    %esp,%ebp
f01064fb:	56                   	push   %esi
f01064fc:	53                   	push   %ebx
f01064fd:	83 ec 10             	sub    $0x10,%esp
f0106500:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106503:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106507:	ba 70 00 00 00       	mov    $0x70,%edx
f010650c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106511:	ee                   	out    %al,(%dx)
f0106512:	b2 71                	mov    $0x71,%dl
f0106514:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106519:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010651a:	83 3d e8 5e 22 f0 00 	cmpl   $0x0,0xf0225ee8
f0106521:	75 24                	jne    f0106547 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106523:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010652a:	00 
f010652b:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0106532:	f0 
f0106533:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010653a:	00 
f010653b:	c7 04 24 58 89 10 f0 	movl   $0xf0108958,(%esp)
f0106542:	e8 f9 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106547:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010654e:	00 00 
	wrv[1] = addr >> 4;
f0106550:	89 f0                	mov    %esi,%eax
f0106552:	c1 e8 04             	shr    $0x4,%eax
f0106555:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010655b:	c1 e3 18             	shl    $0x18,%ebx
f010655e:	89 da                	mov    %ebx,%edx
f0106560:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106565:	e8 0e fe ff ff       	call   f0106378 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010656a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010656f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106574:	e8 ff fd ff ff       	call   f0106378 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106579:	ba 00 85 00 00       	mov    $0x8500,%edx
f010657e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106583:	e8 f0 fd ff ff       	call   f0106378 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106588:	c1 ee 0c             	shr    $0xc,%esi
f010658b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106591:	89 da                	mov    %ebx,%edx
f0106593:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106598:	e8 db fd ff ff       	call   f0106378 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010659d:	89 f2                	mov    %esi,%edx
f010659f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065a4:	e8 cf fd ff ff       	call   f0106378 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01065a9:	89 da                	mov    %ebx,%edx
f01065ab:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065b0:	e8 c3 fd ff ff       	call   f0106378 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065b5:	89 f2                	mov    %esi,%edx
f01065b7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065bc:	e8 b7 fd ff ff       	call   f0106378 <lapicw>
		microdelay(200);
	}
}
f01065c1:	83 c4 10             	add    $0x10,%esp
f01065c4:	5b                   	pop    %ebx
f01065c5:	5e                   	pop    %esi
f01065c6:	5d                   	pop    %ebp
f01065c7:	c3                   	ret    

f01065c8 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01065c8:	55                   	push   %ebp
f01065c9:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01065cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01065ce:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01065d4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065d9:	e8 9a fd ff ff       	call   f0106378 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065de:	8b 15 04 70 26 f0    	mov    0xf0267004,%edx
f01065e4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065ea:	f6 c4 10             	test   $0x10,%ah
f01065ed:	75 f5                	jne    f01065e4 <lapic_ipi+0x1c>
		;
}
f01065ef:	5d                   	pop    %ebp
f01065f0:	c3                   	ret    
f01065f1:	00 00                	add    %al,(%eax)
	...

f01065f4 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01065f4:	55                   	push   %ebp
f01065f5:	89 e5                	mov    %esp,%ebp
f01065f7:	53                   	push   %ebx
f01065f8:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01065fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0106600:	83 38 00             	cmpl   $0x0,(%eax)
f0106603:	74 18                	je     f010661d <holding+0x29>
f0106605:	8b 58 08             	mov    0x8(%eax),%ebx
f0106608:	e8 83 fd ff ff       	call   f0106390 <cpunum>
f010660d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106610:	05 20 60 22 f0       	add    $0xf0226020,%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106615:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106617:	0f 94 c2             	sete   %dl
f010661a:	0f b6 d2             	movzbl %dl,%edx
}
f010661d:	89 d0                	mov    %edx,%eax
f010661f:	83 c4 04             	add    $0x4,%esp
f0106622:	5b                   	pop    %ebx
f0106623:	5d                   	pop    %ebp
f0106624:	c3                   	ret    

f0106625 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106625:	55                   	push   %ebp
f0106626:	89 e5                	mov    %esp,%ebp
f0106628:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010662b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106631:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106634:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106637:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010663e:	5d                   	pop    %ebp
f010663f:	c3                   	ret    

f0106640 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106640:	55                   	push   %ebp
f0106641:	89 e5                	mov    %esp,%ebp
f0106643:	53                   	push   %ebx
f0106644:	83 ec 24             	sub    $0x24,%esp
f0106647:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010664a:	89 d8                	mov    %ebx,%eax
f010664c:	e8 a3 ff ff ff       	call   f01065f4 <holding>
f0106651:	85 c0                	test   %eax,%eax
f0106653:	75 12                	jne    f0106667 <spin_lock+0x27>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106655:	89 da                	mov    %ebx,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106657:	b0 01                	mov    $0x1,%al
f0106659:	f0 87 03             	lock xchg %eax,(%ebx)
f010665c:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106661:	85 c0                	test   %eax,%eax
f0106663:	75 2e                	jne    f0106693 <spin_lock+0x53>
f0106665:	eb 37                	jmp    f010669e <spin_lock+0x5e>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106667:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010666a:	e8 21 fd ff ff       	call   f0106390 <cpunum>
f010666f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106673:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106677:	c7 44 24 08 68 89 10 	movl   $0xf0108968,0x8(%esp)
f010667e:	f0 
f010667f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106686:	00 
f0106687:	c7 04 24 cc 89 10 f0 	movl   $0xf01089cc,(%esp)
f010668e:	e8 ad 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106693:	f3 90                	pause  
f0106695:	89 c8                	mov    %ecx,%eax
f0106697:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010669a:	85 c0                	test   %eax,%eax
f010669c:	75 f5                	jne    f0106693 <spin_lock+0x53>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010669e:	e8 ed fc ff ff       	call   f0106390 <cpunum>
f01066a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01066a6:	05 20 60 22 f0       	add    $0xf0226020,%eax
f01066ab:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01066ae:	8d 4b 0c             	lea    0xc(%ebx),%ecx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01066b1:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01066b3:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01066b8:	77 34                	ja     f01066ee <spin_lock+0xae>
f01066ba:	eb 2b                	jmp    f01066e7 <spin_lock+0xa7>
f01066bc:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01066c2:	76 12                	jbe    f01066d6 <spin_lock+0x96>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01066c4:	8b 5a 04             	mov    0x4(%edx),%ebx
f01066c7:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01066ca:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01066cc:	83 c0 01             	add    $0x1,%eax
f01066cf:	83 f8 0a             	cmp    $0xa,%eax
f01066d2:	75 e8                	jne    f01066bc <spin_lock+0x7c>
f01066d4:	eb 27                	jmp    f01066fd <spin_lock+0xbd>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01066d6:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01066dd:	83 c0 01             	add    $0x1,%eax
f01066e0:	83 f8 09             	cmp    $0x9,%eax
f01066e3:	7e f1                	jle    f01066d6 <spin_lock+0x96>
f01066e5:	eb 16                	jmp    f01066fd <spin_lock+0xbd>
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01066e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01066ec:	eb e8                	jmp    f01066d6 <spin_lock+0x96>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01066ee:	8b 50 04             	mov    0x4(%eax),%edx
f01066f1:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01066f4:	8b 10                	mov    (%eax),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01066f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01066fb:	eb bf                	jmp    f01066bc <spin_lock+0x7c>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01066fd:	83 c4 24             	add    $0x24,%esp
f0106700:	5b                   	pop    %ebx
f0106701:	5d                   	pop    %ebp
f0106702:	c3                   	ret    

f0106703 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106703:	55                   	push   %ebp
f0106704:	89 e5                	mov    %esp,%ebp
f0106706:	83 ec 78             	sub    $0x78,%esp
f0106709:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010670c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010670f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0106712:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106715:	89 d8                	mov    %ebx,%eax
f0106717:	e8 d8 fe ff ff       	call   f01065f4 <holding>
f010671c:	85 c0                	test   %eax,%eax
f010671e:	0f 85 d4 00 00 00    	jne    f01067f8 <spin_unlock+0xf5>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106724:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010672b:	00 
f010672c:	8d 43 0c             	lea    0xc(%ebx),%eax
f010672f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106733:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0106736:	89 04 24             	mov    %eax,(%esp)
f0106739:	e8 1e f6 ff ff       	call   f0105d5c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010673e:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106741:	0f b6 30             	movzbl (%eax),%esi
f0106744:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106747:	e8 44 fc ff ff       	call   f0106390 <cpunum>
f010674c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106750:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106754:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106758:	c7 04 24 94 89 10 f0 	movl   $0xf0108994,(%esp)
f010675f:	e8 7a de ff ff       	call   f01045de <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106764:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106767:	85 c0                	test   %eax,%eax
f0106769:	74 71                	je     f01067dc <spin_unlock+0xd9>
f010676b:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010676e:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106771:	8d 75 d0             	lea    -0x30(%ebp),%esi
f0106774:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106778:	89 04 24             	mov    %eax,(%esp)
f010677b:	e8 ba e8 ff ff       	call   f010503a <debuginfo_eip>
f0106780:	85 c0                	test   %eax,%eax
f0106782:	78 39                	js     f01067bd <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106784:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106786:	89 c2                	mov    %eax,%edx
f0106788:	2b 55 e0             	sub    -0x20(%ebp),%edx
f010678b:	89 54 24 18          	mov    %edx,0x18(%esp)
f010678f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106792:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106796:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106799:	89 54 24 10          	mov    %edx,0x10(%esp)
f010679d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01067a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01067a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01067a7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01067ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067af:	c7 04 24 dc 89 10 f0 	movl   $0xf01089dc,(%esp)
f01067b6:	e8 23 de ff ff       	call   f01045de <cprintf>
f01067bb:	eb 12                	jmp    f01067cf <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01067bd:	8b 03                	mov    (%ebx),%eax
f01067bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067c3:	c7 04 24 f3 89 10 f0 	movl   $0xf01089f3,(%esp)
f01067ca:	e8 0f de ff ff       	call   f01045de <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01067cf:	39 fb                	cmp    %edi,%ebx
f01067d1:	74 09                	je     f01067dc <spin_unlock+0xd9>
f01067d3:	83 c3 04             	add    $0x4,%ebx
f01067d6:	8b 03                	mov    (%ebx),%eax
f01067d8:	85 c0                	test   %eax,%eax
f01067da:	75 98                	jne    f0106774 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01067dc:	c7 44 24 08 fb 89 10 	movl   $0xf01089fb,0x8(%esp)
f01067e3:	f0 
f01067e4:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01067eb:	00 
f01067ec:	c7 04 24 cc 89 10 f0 	movl   $0xf01089cc,(%esp)
f01067f3:	e8 48 98 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01067f8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01067ff:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106806:	b8 00 00 00 00       	mov    $0x0,%eax
f010680b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010680e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106811:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106814:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106817:	89 ec                	mov    %ebp,%esp
f0106819:	5d                   	pop    %ebp
f010681a:	c3                   	ret    
f010681b:	00 00                	add    %al,(%eax)
f010681d:	00 00                	add    %al,(%eax)
	...

f0106820 <__udivdi3>:
f0106820:	83 ec 1c             	sub    $0x1c,%esp
f0106823:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106827:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010682b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010682f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106833:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106837:	8b 74 24 24          	mov    0x24(%esp),%esi
f010683b:	85 ff                	test   %edi,%edi
f010683d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106841:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106845:	89 cd                	mov    %ecx,%ebp
f0106847:	89 44 24 04          	mov    %eax,0x4(%esp)
f010684b:	75 33                	jne    f0106880 <__udivdi3+0x60>
f010684d:	39 f1                	cmp    %esi,%ecx
f010684f:	77 57                	ja     f01068a8 <__udivdi3+0x88>
f0106851:	85 c9                	test   %ecx,%ecx
f0106853:	75 0b                	jne    f0106860 <__udivdi3+0x40>
f0106855:	b8 01 00 00 00       	mov    $0x1,%eax
f010685a:	31 d2                	xor    %edx,%edx
f010685c:	f7 f1                	div    %ecx
f010685e:	89 c1                	mov    %eax,%ecx
f0106860:	89 f0                	mov    %esi,%eax
f0106862:	31 d2                	xor    %edx,%edx
f0106864:	f7 f1                	div    %ecx
f0106866:	89 c6                	mov    %eax,%esi
f0106868:	8b 44 24 04          	mov    0x4(%esp),%eax
f010686c:	f7 f1                	div    %ecx
f010686e:	89 f2                	mov    %esi,%edx
f0106870:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106874:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106878:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010687c:	83 c4 1c             	add    $0x1c,%esp
f010687f:	c3                   	ret    
f0106880:	31 d2                	xor    %edx,%edx
f0106882:	31 c0                	xor    %eax,%eax
f0106884:	39 f7                	cmp    %esi,%edi
f0106886:	77 e8                	ja     f0106870 <__udivdi3+0x50>
f0106888:	0f bd cf             	bsr    %edi,%ecx
f010688b:	83 f1 1f             	xor    $0x1f,%ecx
f010688e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106892:	75 2c                	jne    f01068c0 <__udivdi3+0xa0>
f0106894:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0106898:	76 04                	jbe    f010689e <__udivdi3+0x7e>
f010689a:	39 f7                	cmp    %esi,%edi
f010689c:	73 d2                	jae    f0106870 <__udivdi3+0x50>
f010689e:	31 d2                	xor    %edx,%edx
f01068a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01068a5:	eb c9                	jmp    f0106870 <__udivdi3+0x50>
f01068a7:	90                   	nop
f01068a8:	89 f2                	mov    %esi,%edx
f01068aa:	f7 f1                	div    %ecx
f01068ac:	31 d2                	xor    %edx,%edx
f01068ae:	8b 74 24 10          	mov    0x10(%esp),%esi
f01068b2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01068b6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01068ba:	83 c4 1c             	add    $0x1c,%esp
f01068bd:	c3                   	ret    
f01068be:	66 90                	xchg   %ax,%ax
f01068c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01068c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01068ca:	89 ea                	mov    %ebp,%edx
f01068cc:	2b 44 24 04          	sub    0x4(%esp),%eax
f01068d0:	d3 e7                	shl    %cl,%edi
f01068d2:	89 c1                	mov    %eax,%ecx
f01068d4:	d3 ea                	shr    %cl,%edx
f01068d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01068db:	09 fa                	or     %edi,%edx
f01068dd:	89 f7                	mov    %esi,%edi
f01068df:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01068e3:	89 f2                	mov    %esi,%edx
f01068e5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01068e9:	d3 e5                	shl    %cl,%ebp
f01068eb:	89 c1                	mov    %eax,%ecx
f01068ed:	d3 ef                	shr    %cl,%edi
f01068ef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01068f4:	d3 e2                	shl    %cl,%edx
f01068f6:	89 c1                	mov    %eax,%ecx
f01068f8:	d3 ee                	shr    %cl,%esi
f01068fa:	09 d6                	or     %edx,%esi
f01068fc:	89 fa                	mov    %edi,%edx
f01068fe:	89 f0                	mov    %esi,%eax
f0106900:	f7 74 24 0c          	divl   0xc(%esp)
f0106904:	89 d7                	mov    %edx,%edi
f0106906:	89 c6                	mov    %eax,%esi
f0106908:	f7 e5                	mul    %ebp
f010690a:	39 d7                	cmp    %edx,%edi
f010690c:	72 22                	jb     f0106930 <__udivdi3+0x110>
f010690e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0106912:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106917:	d3 e5                	shl    %cl,%ebp
f0106919:	39 c5                	cmp    %eax,%ebp
f010691b:	73 04                	jae    f0106921 <__udivdi3+0x101>
f010691d:	39 d7                	cmp    %edx,%edi
f010691f:	74 0f                	je     f0106930 <__udivdi3+0x110>
f0106921:	89 f0                	mov    %esi,%eax
f0106923:	31 d2                	xor    %edx,%edx
f0106925:	e9 46 ff ff ff       	jmp    f0106870 <__udivdi3+0x50>
f010692a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106930:	8d 46 ff             	lea    -0x1(%esi),%eax
f0106933:	31 d2                	xor    %edx,%edx
f0106935:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106939:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010693d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106941:	83 c4 1c             	add    $0x1c,%esp
f0106944:	c3                   	ret    
	...

f0106950 <__umoddi3>:
f0106950:	83 ec 1c             	sub    $0x1c,%esp
f0106953:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0106957:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010695b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010695f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106963:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106967:	8b 74 24 24          	mov    0x24(%esp),%esi
f010696b:	85 ed                	test   %ebp,%ebp
f010696d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106971:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106975:	89 cf                	mov    %ecx,%edi
f0106977:	89 04 24             	mov    %eax,(%esp)
f010697a:	89 f2                	mov    %esi,%edx
f010697c:	75 1a                	jne    f0106998 <__umoddi3+0x48>
f010697e:	39 f1                	cmp    %esi,%ecx
f0106980:	76 4e                	jbe    f01069d0 <__umoddi3+0x80>
f0106982:	f7 f1                	div    %ecx
f0106984:	89 d0                	mov    %edx,%eax
f0106986:	31 d2                	xor    %edx,%edx
f0106988:	8b 74 24 10          	mov    0x10(%esp),%esi
f010698c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106990:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106994:	83 c4 1c             	add    $0x1c,%esp
f0106997:	c3                   	ret    
f0106998:	39 f5                	cmp    %esi,%ebp
f010699a:	77 54                	ja     f01069f0 <__umoddi3+0xa0>
f010699c:	0f bd c5             	bsr    %ebp,%eax
f010699f:	83 f0 1f             	xor    $0x1f,%eax
f01069a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069a6:	75 60                	jne    f0106a08 <__umoddi3+0xb8>
f01069a8:	3b 0c 24             	cmp    (%esp),%ecx
f01069ab:	0f 87 07 01 00 00    	ja     f0106ab8 <__umoddi3+0x168>
f01069b1:	89 f2                	mov    %esi,%edx
f01069b3:	8b 34 24             	mov    (%esp),%esi
f01069b6:	29 ce                	sub    %ecx,%esi
f01069b8:	19 ea                	sbb    %ebp,%edx
f01069ba:	89 34 24             	mov    %esi,(%esp)
f01069bd:	8b 04 24             	mov    (%esp),%eax
f01069c0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01069c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01069c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01069cc:	83 c4 1c             	add    $0x1c,%esp
f01069cf:	c3                   	ret    
f01069d0:	85 c9                	test   %ecx,%ecx
f01069d2:	75 0b                	jne    f01069df <__umoddi3+0x8f>
f01069d4:	b8 01 00 00 00       	mov    $0x1,%eax
f01069d9:	31 d2                	xor    %edx,%edx
f01069db:	f7 f1                	div    %ecx
f01069dd:	89 c1                	mov    %eax,%ecx
f01069df:	89 f0                	mov    %esi,%eax
f01069e1:	31 d2                	xor    %edx,%edx
f01069e3:	f7 f1                	div    %ecx
f01069e5:	8b 04 24             	mov    (%esp),%eax
f01069e8:	f7 f1                	div    %ecx
f01069ea:	eb 98                	jmp    f0106984 <__umoddi3+0x34>
f01069ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069f0:	89 f2                	mov    %esi,%edx
f01069f2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01069f6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01069fa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01069fe:	83 c4 1c             	add    $0x1c,%esp
f0106a01:	c3                   	ret    
f0106a02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a08:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a0d:	89 e8                	mov    %ebp,%eax
f0106a0f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0106a14:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0106a18:	89 fa                	mov    %edi,%edx
f0106a1a:	d3 e0                	shl    %cl,%eax
f0106a1c:	89 e9                	mov    %ebp,%ecx
f0106a1e:	d3 ea                	shr    %cl,%edx
f0106a20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a25:	09 c2                	or     %eax,%edx
f0106a27:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a2b:	89 14 24             	mov    %edx,(%esp)
f0106a2e:	89 f2                	mov    %esi,%edx
f0106a30:	d3 e7                	shl    %cl,%edi
f0106a32:	89 e9                	mov    %ebp,%ecx
f0106a34:	d3 ea                	shr    %cl,%edx
f0106a36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a3f:	d3 e6                	shl    %cl,%esi
f0106a41:	89 e9                	mov    %ebp,%ecx
f0106a43:	d3 e8                	shr    %cl,%eax
f0106a45:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a4a:	09 f0                	or     %esi,%eax
f0106a4c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106a50:	f7 34 24             	divl   (%esp)
f0106a53:	d3 e6                	shl    %cl,%esi
f0106a55:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106a59:	89 d6                	mov    %edx,%esi
f0106a5b:	f7 e7                	mul    %edi
f0106a5d:	39 d6                	cmp    %edx,%esi
f0106a5f:	89 c1                	mov    %eax,%ecx
f0106a61:	89 d7                	mov    %edx,%edi
f0106a63:	72 3f                	jb     f0106aa4 <__umoddi3+0x154>
f0106a65:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0106a69:	72 35                	jb     f0106aa0 <__umoddi3+0x150>
f0106a6b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a6f:	29 c8                	sub    %ecx,%eax
f0106a71:	19 fe                	sbb    %edi,%esi
f0106a73:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a78:	89 f2                	mov    %esi,%edx
f0106a7a:	d3 e8                	shr    %cl,%eax
f0106a7c:	89 e9                	mov    %ebp,%ecx
f0106a7e:	d3 e2                	shl    %cl,%edx
f0106a80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106a85:	09 d0                	or     %edx,%eax
f0106a87:	89 f2                	mov    %esi,%edx
f0106a89:	d3 ea                	shr    %cl,%edx
f0106a8b:	8b 74 24 10          	mov    0x10(%esp),%esi
f0106a8f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0106a93:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0106a97:	83 c4 1c             	add    $0x1c,%esp
f0106a9a:	c3                   	ret    
f0106a9b:	90                   	nop
f0106a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106aa0:	39 d6                	cmp    %edx,%esi
f0106aa2:	75 c7                	jne    f0106a6b <__umoddi3+0x11b>
f0106aa4:	89 d7                	mov    %edx,%edi
f0106aa6:	89 c1                	mov    %eax,%ecx
f0106aa8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0106aac:	1b 3c 24             	sbb    (%esp),%edi
f0106aaf:	eb ba                	jmp    f0106a6b <__umoddi3+0x11b>
f0106ab1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106ab8:	39 f5                	cmp    %esi,%ebp
f0106aba:	0f 82 f1 fe ff ff    	jb     f01069b1 <__umoddi3+0x61>
f0106ac0:	e9 f8 fe ff ff       	jmp    f01069bd <__umoddi3+0x6d>
