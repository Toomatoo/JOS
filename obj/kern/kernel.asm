
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 60 1c 10 f0 	movl   $0xf0101c60,(%esp)
f0100055:	e8 08 0a 00 00       	call   f0100a62 <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 02 07 00 00       	call   f0100789 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 7c 1c 10 f0 	movl   $0xf0101c7c,(%esp)
f0100092:	e8 cb 09 00 00       	call   f0100a62 <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 64 29 11 f0       	mov    $0xf0112964,%eax
f01000a8:	2d 04 23 11 f0       	sub    $0xf0112304,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 04 23 11 f0 	movl   $0xf0112304,(%esp)
f01000c0:	e8 8c 16 00 00       	call   f0101751 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 91 04 00 00       	call   f010055b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 97 1c 10 f0 	movl   $0xf0101c97,(%esp)
f01000d9:	e8 84 09 00 00       	call   f0100a62 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 ec 07 00 00       	call   f01008e2 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 60 29 11 f0 00 	cmpl   $0x0,0xf0112960
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 60 29 11 f0    	mov    %esi,0xf0112960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 b2 1c 10 f0 	movl   $0xf0101cb2,(%esp)
f010012c:	e8 31 09 00 00       	call   f0100a62 <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 f2 08 00 00       	call   f0100a2f <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 ee 1c 10 f0 	movl   $0xf0101cee,(%esp)
f0100144:	e8 19 09 00 00       	call   f0100a62 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 8d 07 00 00       	call   f01008e2 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 ca 1c 10 f0 	movl   $0xf0101cca,(%esp)
f0100176:	e8 e7 08 00 00       	call   f0100a62 <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 a5 08 00 00       	call   f0100a2f <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 ee 1c 10 f0 	movl   $0xf0101cee,(%esp)
f0100191:	e8 cc 08 00 00       	call   f0100a62 <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    
f010019c:	00 00                	add    %al,(%eax)
	...

f01001a0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001bc:	a8 01                	test   $0x1,%al
f01001be:	74 06                	je     f01001c6 <serial_proc_data+0x18>
f01001c0:	b2 f8                	mov    $0xf8,%dl
f01001c2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c3:	0f b6 c8             	movzbl %al,%ecx
}
f01001c6:	89 c8                	mov    %ecx,%eax
f01001c8:	5d                   	pop    %ebp
f01001c9:	c3                   	ret    

f01001ca <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ca:	55                   	push   %ebp
f01001cb:	89 e5                	mov    %esp,%ebp
f01001cd:	53                   	push   %ebx
f01001ce:	83 ec 04             	sub    $0x4,%esp
f01001d1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001d3:	eb 25                	jmp    f01001fa <cons_intr+0x30>
		if (c == 0)
f01001d5:	85 c0                	test   %eax,%eax
f01001d7:	74 21                	je     f01001fa <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01001d9:	8b 15 44 25 11 f0    	mov    0xf0112544,%edx
f01001df:	88 82 40 23 11 f0    	mov    %al,-0xfeedcc0(%edx)
f01001e5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001e8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001ed:	ba 00 00 00 00       	mov    $0x0,%edx
f01001f2:	0f 44 c2             	cmove  %edx,%eax
f01001f5:	a3 44 25 11 f0       	mov    %eax,0xf0112544
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001fa:	ff d3                	call   *%ebx
f01001fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ff:	75 d4                	jne    f01001d5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100201:	83 c4 04             	add    $0x4,%esp
f0100204:	5b                   	pop    %ebx
f0100205:	5d                   	pop    %ebp
f0100206:	c3                   	ret    

f0100207 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100207:	55                   	push   %ebp
f0100208:	89 e5                	mov    %esp,%ebp
f010020a:	57                   	push   %edi
f010020b:	56                   	push   %esi
f010020c:	53                   	push   %ebx
f010020d:	83 ec 2c             	sub    $0x2c,%esp
f0100210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100213:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100218:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100219:	a8 20                	test   $0x20,%al
f010021b:	75 1b                	jne    f0100238 <cons_putc+0x31>
f010021d:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100222:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100227:	e8 74 ff ff ff       	call   f01001a0 <delay>
f010022c:	89 f2                	mov    %esi,%edx
f010022e:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010022f:	a8 20                	test   $0x20,%al
f0100231:	75 05                	jne    f0100238 <cons_putc+0x31>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100233:	83 eb 01             	sub    $0x1,%ebx
f0100236:	75 ef                	jne    f0100227 <cons_putc+0x20>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100238:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010023c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100241:	89 f8                	mov    %edi,%eax
f0100243:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100244:	b2 79                	mov    $0x79,%dl
f0100246:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100247:	84 c0                	test   %al,%al
f0100249:	78 1b                	js     f0100266 <cons_putc+0x5f>
f010024b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100250:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100255:	e8 46 ff ff ff       	call   f01001a0 <delay>
f010025a:	89 f2                	mov    %esi,%edx
f010025c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010025d:	84 c0                	test   %al,%al
f010025f:	78 05                	js     f0100266 <cons_putc+0x5f>
f0100261:	83 eb 01             	sub    $0x1,%ebx
f0100264:	75 ef                	jne    f0100255 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100266:	ba 78 03 00 00       	mov    $0x378,%edx
f010026b:	89 f8                	mov    %edi,%eax
f010026d:	ee                   	out    %al,(%dx)
f010026e:	b2 7a                	mov    $0x7a,%dl
f0100270:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100275:	ee                   	out    %al,(%dx)
f0100276:	b8 08 00 00 00       	mov    $0x8,%eax
f010027b:	ee                   	out    %al,(%dx)
extern int ncolor;

static void
cga_putc(int c)
{
	c = c + (ncolor << 8);
f010027c:	a1 00 23 11 f0       	mov    0xf0112300,%eax
f0100281:	c1 e0 08             	shl    $0x8,%eax
f0100284:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100287:	89 c1                	mov    %eax,%ecx
f0100289:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f010028f:	89 c2                	mov    %eax,%edx
f0100291:	80 ce 07             	or     $0x7,%dh
f0100294:	85 c9                	test   %ecx,%ecx
f0100296:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f0100299:	0f b6 d0             	movzbl %al,%edx
f010029c:	83 fa 09             	cmp    $0x9,%edx
f010029f:	74 75                	je     f0100316 <cons_putc+0x10f>
f01002a1:	83 fa 09             	cmp    $0x9,%edx
f01002a4:	7f 0c                	jg     f01002b2 <cons_putc+0xab>
f01002a6:	83 fa 08             	cmp    $0x8,%edx
f01002a9:	0f 85 9b 00 00 00    	jne    f010034a <cons_putc+0x143>
f01002af:	90                   	nop
f01002b0:	eb 10                	jmp    f01002c2 <cons_putc+0xbb>
f01002b2:	83 fa 0a             	cmp    $0xa,%edx
f01002b5:	74 39                	je     f01002f0 <cons_putc+0xe9>
f01002b7:	83 fa 0d             	cmp    $0xd,%edx
f01002ba:	0f 85 8a 00 00 00    	jne    f010034a <cons_putc+0x143>
f01002c0:	eb 36                	jmp    f01002f8 <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f01002c2:	0f b7 15 54 25 11 f0 	movzwl 0xf0112554,%edx
f01002c9:	66 85 d2             	test   %dx,%dx
f01002cc:	0f 84 e3 00 00 00    	je     f01003b5 <cons_putc+0x1ae>
			crt_pos--;
f01002d2:	83 ea 01             	sub    $0x1,%edx
f01002d5:	66 89 15 54 25 11 f0 	mov    %dx,0xf0112554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002dc:	0f b7 d2             	movzwl %dx,%edx
f01002df:	b0 00                	mov    $0x0,%al
f01002e1:	83 c8 20             	or     $0x20,%eax
f01002e4:	8b 0d 50 25 11 f0    	mov    0xf0112550,%ecx
f01002ea:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01002ee:	eb 78                	jmp    f0100368 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002f0:	66 83 05 54 25 11 f0 	addw   $0x50,0xf0112554
f01002f7:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002f8:	0f b7 05 54 25 11 f0 	movzwl 0xf0112554,%eax
f01002ff:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100305:	c1 e8 16             	shr    $0x16,%eax
f0100308:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010030b:	c1 e0 04             	shl    $0x4,%eax
f010030e:	66 a3 54 25 11 f0    	mov    %ax,0xf0112554
f0100314:	eb 52                	jmp    f0100368 <cons_putc+0x161>
		break;
	case '\t':
		cons_putc(' ');
f0100316:	b8 20 00 00 00       	mov    $0x20,%eax
f010031b:	e8 e7 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100320:	b8 20 00 00 00       	mov    $0x20,%eax
f0100325:	e8 dd fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010032a:	b8 20 00 00 00       	mov    $0x20,%eax
f010032f:	e8 d3 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100334:	b8 20 00 00 00       	mov    $0x20,%eax
f0100339:	e8 c9 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010033e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100343:	e8 bf fe ff ff       	call   f0100207 <cons_putc>
f0100348:	eb 1e                	jmp    f0100368 <cons_putc+0x161>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010034a:	0f b7 15 54 25 11 f0 	movzwl 0xf0112554,%edx
f0100351:	0f b7 da             	movzwl %dx,%ebx
f0100354:	8b 0d 50 25 11 f0    	mov    0xf0112550,%ecx
f010035a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010035e:	83 c2 01             	add    $0x1,%edx
f0100361:	66 89 15 54 25 11 f0 	mov    %dx,0xf0112554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100368:	66 81 3d 54 25 11 f0 	cmpw   $0x7cf,0xf0112554
f010036f:	cf 07 
f0100371:	76 42                	jbe    f01003b5 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100373:	a1 50 25 11 f0       	mov    0xf0112550,%eax
f0100378:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010037f:	00 
f0100380:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100386:	89 54 24 04          	mov    %edx,0x4(%esp)
f010038a:	89 04 24             	mov    %eax,(%esp)
f010038d:	e8 1a 14 00 00       	call   f01017ac <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100392:	8b 15 50 25 11 f0    	mov    0xf0112550,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100398:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010039d:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003a3:	83 c0 01             	add    $0x1,%eax
f01003a6:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01003ab:	75 f0                	jne    f010039d <cons_putc+0x196>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01003ad:	66 83 2d 54 25 11 f0 	subw   $0x50,0xf0112554
f01003b4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01003b5:	8b 0d 4c 25 11 f0    	mov    0xf011254c,%ecx
f01003bb:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003c0:	89 ca                	mov    %ecx,%edx
f01003c2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003c3:	0f b7 35 54 25 11 f0 	movzwl 0xf0112554,%esi
f01003ca:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003cd:	89 f0                	mov    %esi,%eax
f01003cf:	66 c1 e8 08          	shr    $0x8,%ax
f01003d3:	89 da                	mov    %ebx,%edx
f01003d5:	ee                   	out    %al,(%dx)
f01003d6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003db:	89 ca                	mov    %ecx,%edx
f01003dd:	ee                   	out    %al,(%dx)
f01003de:	89 f0                	mov    %esi,%eax
f01003e0:	89 da                	mov    %ebx,%edx
f01003e2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003e3:	83 c4 2c             	add    $0x2c,%esp
f01003e6:	5b                   	pop    %ebx
f01003e7:	5e                   	pop    %esi
f01003e8:	5f                   	pop    %edi
f01003e9:	5d                   	pop    %ebp
f01003ea:	c3                   	ret    

f01003eb <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003eb:	55                   	push   %ebp
f01003ec:	89 e5                	mov    %esp,%ebp
f01003ee:	53                   	push   %ebx
f01003ef:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f2:	ba 64 00 00 00       	mov    $0x64,%edx
f01003f7:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003f8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003fd:	a8 01                	test   $0x1,%al
f01003ff:	0f 84 de 00 00 00    	je     f01004e3 <kbd_proc_data+0xf8>
f0100405:	b2 60                	mov    $0x60,%dl
f0100407:	ec                   	in     (%dx),%al
f0100408:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010040a:	3c e0                	cmp    $0xe0,%al
f010040c:	75 11                	jne    f010041f <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010040e:	83 0d 48 25 11 f0 40 	orl    $0x40,0xf0112548
		return 0;
f0100415:	bb 00 00 00 00       	mov    $0x0,%ebx
f010041a:	e9 c4 00 00 00       	jmp    f01004e3 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f010041f:	84 c0                	test   %al,%al
f0100421:	79 37                	jns    f010045a <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100423:	8b 0d 48 25 11 f0    	mov    0xf0112548,%ecx
f0100429:	89 cb                	mov    %ecx,%ebx
f010042b:	83 e3 40             	and    $0x40,%ebx
f010042e:	83 e0 7f             	and    $0x7f,%eax
f0100431:	85 db                	test   %ebx,%ebx
f0100433:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100436:	0f b6 d2             	movzbl %dl,%edx
f0100439:	0f b6 82 20 1d 10 f0 	movzbl -0xfefe2e0(%edx),%eax
f0100440:	83 c8 40             	or     $0x40,%eax
f0100443:	0f b6 c0             	movzbl %al,%eax
f0100446:	f7 d0                	not    %eax
f0100448:	21 c1                	and    %eax,%ecx
f010044a:	89 0d 48 25 11 f0    	mov    %ecx,0xf0112548
		return 0;
f0100450:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100455:	e9 89 00 00 00       	jmp    f01004e3 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010045a:	8b 0d 48 25 11 f0    	mov    0xf0112548,%ecx
f0100460:	f6 c1 40             	test   $0x40,%cl
f0100463:	74 0e                	je     f0100473 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100465:	89 c2                	mov    %eax,%edx
f0100467:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010046a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010046d:	89 0d 48 25 11 f0    	mov    %ecx,0xf0112548
	}

	shift |= shiftcode[data];
f0100473:	0f b6 d2             	movzbl %dl,%edx
f0100476:	0f b6 82 20 1d 10 f0 	movzbl -0xfefe2e0(%edx),%eax
f010047d:	0b 05 48 25 11 f0    	or     0xf0112548,%eax
	shift ^= togglecode[data];
f0100483:	0f b6 8a 20 1e 10 f0 	movzbl -0xfefe1e0(%edx),%ecx
f010048a:	31 c8                	xor    %ecx,%eax
f010048c:	a3 48 25 11 f0       	mov    %eax,0xf0112548

	c = charcode[shift & (CTL | SHIFT)][data];
f0100491:	89 c1                	mov    %eax,%ecx
f0100493:	83 e1 03             	and    $0x3,%ecx
f0100496:	8b 0c 8d 20 1f 10 f0 	mov    -0xfefe0e0(,%ecx,4),%ecx
f010049d:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01004a1:	a8 08                	test   $0x8,%al
f01004a3:	74 19                	je     f01004be <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01004a5:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01004a8:	83 fa 19             	cmp    $0x19,%edx
f01004ab:	77 05                	ja     f01004b2 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01004ad:	83 eb 20             	sub    $0x20,%ebx
f01004b0:	eb 0c                	jmp    f01004be <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01004b2:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01004b5:	8d 53 20             	lea    0x20(%ebx),%edx
f01004b8:	83 f9 19             	cmp    $0x19,%ecx
f01004bb:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004be:	f7 d0                	not    %eax
f01004c0:	a8 06                	test   $0x6,%al
f01004c2:	75 1f                	jne    f01004e3 <kbd_proc_data+0xf8>
f01004c4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004ca:	75 17                	jne    f01004e3 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01004cc:	c7 04 24 e4 1c 10 f0 	movl   $0xf0101ce4,(%esp)
f01004d3:	e8 8a 05 00 00       	call   f0100a62 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004d8:	ba 92 00 00 00       	mov    $0x92,%edx
f01004dd:	b8 03 00 00 00       	mov    $0x3,%eax
f01004e2:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004e3:	89 d8                	mov    %ebx,%eax
f01004e5:	83 c4 14             	add    $0x14,%esp
f01004e8:	5b                   	pop    %ebx
f01004e9:	5d                   	pop    %ebp
f01004ea:	c3                   	ret    

f01004eb <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004eb:	55                   	push   %ebp
f01004ec:	89 e5                	mov    %esp,%ebp
f01004ee:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004f1:	80 3d 20 23 11 f0 00 	cmpb   $0x0,0xf0112320
f01004f8:	74 0a                	je     f0100504 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004fa:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f01004ff:	e8 c6 fc ff ff       	call   f01001ca <cons_intr>
}
f0100504:	c9                   	leave  
f0100505:	c3                   	ret    

f0100506 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100506:	55                   	push   %ebp
f0100507:	89 e5                	mov    %esp,%ebp
f0100509:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010050c:	b8 eb 03 10 f0       	mov    $0xf01003eb,%eax
f0100511:	e8 b4 fc ff ff       	call   f01001ca <cons_intr>
}
f0100516:	c9                   	leave  
f0100517:	c3                   	ret    

f0100518 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100518:	55                   	push   %ebp
f0100519:	89 e5                	mov    %esp,%ebp
f010051b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010051e:	e8 c8 ff ff ff       	call   f01004eb <serial_intr>
	kbd_intr();
f0100523:	e8 de ff ff ff       	call   f0100506 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100528:	8b 15 40 25 11 f0    	mov    0xf0112540,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010052e:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100533:	3b 15 44 25 11 f0    	cmp    0xf0112544,%edx
f0100539:	74 1e                	je     f0100559 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010053b:	0f b6 82 40 23 11 f0 	movzbl -0xfeedcc0(%edx),%eax
f0100542:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100545:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010054b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100550:	0f 44 d1             	cmove  %ecx,%edx
f0100553:	89 15 40 25 11 f0    	mov    %edx,0xf0112540
		return c;
	}
	return 0;
}
f0100559:	c9                   	leave  
f010055a:	c3                   	ret    

f010055b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010055b:	55                   	push   %ebp
f010055c:	89 e5                	mov    %esp,%ebp
f010055e:	57                   	push   %edi
f010055f:	56                   	push   %esi
f0100560:	53                   	push   %ebx
f0100561:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100564:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010056b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100572:	5a a5 
	if (*cp != 0xA55A) {
f0100574:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010057b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010057f:	74 11                	je     f0100592 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100581:	c7 05 4c 25 11 f0 b4 	movl   $0x3b4,0xf011254c
f0100588:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010058b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100590:	eb 16                	jmp    f01005a8 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100592:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100599:	c7 05 4c 25 11 f0 d4 	movl   $0x3d4,0xf011254c
f01005a0:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005a3:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a8:	8b 0d 4c 25 11 f0    	mov    0xf011254c,%ecx
f01005ae:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b3:	89 ca                	mov    %ecx,%edx
f01005b5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b6:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b9:	89 da                	mov    %ebx,%edx
f01005bb:	ec                   	in     (%dx),%al
f01005bc:	0f b6 f8             	movzbl %al,%edi
f01005bf:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c7:	89 ca                	mov    %ecx,%edx
f01005c9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ca:	89 da                	mov    %ebx,%edx
f01005cc:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005cd:	89 35 50 25 11 f0    	mov    %esi,0xf0112550

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005d3:	0f b6 d8             	movzbl %al,%ebx
f01005d6:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005d8:	66 89 3d 54 25 11 f0 	mov    %di,0xf0112554
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005df:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e9:	89 da                	mov    %ebx,%edx
f01005eb:	ee                   	out    %al,(%dx)
f01005ec:	b2 fb                	mov    $0xfb,%dl
f01005ee:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f3:	ee                   	out    %al,(%dx)
f01005f4:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005f9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005fe:	89 ca                	mov    %ecx,%edx
f0100600:	ee                   	out    %al,(%dx)
f0100601:	b2 f9                	mov    $0xf9,%dl
f0100603:	b8 00 00 00 00       	mov    $0x0,%eax
f0100608:	ee                   	out    %al,(%dx)
f0100609:	b2 fb                	mov    $0xfb,%dl
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	b2 fc                	mov    $0xfc,%dl
f0100613:	b8 00 00 00 00       	mov    $0x0,%eax
f0100618:	ee                   	out    %al,(%dx)
f0100619:	b2 f9                	mov    $0xf9,%dl
f010061b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100620:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100621:	b2 fd                	mov    $0xfd,%dl
f0100623:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100624:	3c ff                	cmp    $0xff,%al
f0100626:	0f 95 c0             	setne  %al
f0100629:	89 c6                	mov    %eax,%esi
f010062b:	a2 20 23 11 f0       	mov    %al,0xf0112320
f0100630:	89 da                	mov    %ebx,%edx
f0100632:	ec                   	in     (%dx),%al
f0100633:	89 ca                	mov    %ecx,%edx
f0100635:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100636:	89 f0                	mov    %esi,%eax
f0100638:	84 c0                	test   %al,%al
f010063a:	75 0c                	jne    f0100648 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f010063c:	c7 04 24 f0 1c 10 f0 	movl   $0xf0101cf0,(%esp)
f0100643:	e8 1a 04 00 00       	call   f0100a62 <cprintf>
}
f0100648:	83 c4 1c             	add    $0x1c,%esp
f010064b:	5b                   	pop    %ebx
f010064c:	5e                   	pop    %esi
f010064d:	5f                   	pop    %edi
f010064e:	5d                   	pop    %ebp
f010064f:	c3                   	ret    

f0100650 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100656:	8b 45 08             	mov    0x8(%ebp),%eax
f0100659:	e8 a9 fb ff ff       	call   f0100207 <cons_putc>
}
f010065e:	c9                   	leave  
f010065f:	c3                   	ret    

f0100660 <getchar>:

int
getchar(void)
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
f0100663:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100666:	e8 ad fe ff ff       	call   f0100518 <cons_getc>
f010066b:	85 c0                	test   %eax,%eax
f010066d:	74 f7                	je     f0100666 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010066f:	c9                   	leave  
f0100670:	c3                   	ret    

f0100671 <iscons>:

int
iscons(int fdnum)
{
f0100671:	55                   	push   %ebp
f0100672:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100674:	b8 01 00 00 00       	mov    $0x1,%eax
f0100679:	5d                   	pop    %ebp
f010067a:	c3                   	ret    
f010067b:	00 00                	add    %al,(%eax)
f010067d:	00 00                	add    %al,(%eax)
	...

f0100680 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100680:	55                   	push   %ebp
f0100681:	89 e5                	mov    %esp,%ebp
f0100683:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100686:	c7 04 24 30 1f 10 f0 	movl   $0xf0101f30,(%esp)
f010068d:	e8 d0 03 00 00       	call   f0100a62 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100692:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100699:	00 
f010069a:	c7 04 24 f0 1f 10 f0 	movl   $0xf0101ff0,(%esp)
f01006a1:	e8 bc 03 00 00       	call   f0100a62 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006ad:	00 
f01006ae:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006b5:	f0 
f01006b6:	c7 04 24 18 20 10 f0 	movl   $0xf0102018,(%esp)
f01006bd:	e8 a0 03 00 00       	call   f0100a62 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c2:	c7 44 24 08 45 1c 10 	movl   $0x101c45,0x8(%esp)
f01006c9:	00 
f01006ca:	c7 44 24 04 45 1c 10 	movl   $0xf0101c45,0x4(%esp)
f01006d1:	f0 
f01006d2:	c7 04 24 3c 20 10 f0 	movl   $0xf010203c,(%esp)
f01006d9:	e8 84 03 00 00       	call   f0100a62 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006de:	c7 44 24 08 04 23 11 	movl   $0x112304,0x8(%esp)
f01006e5:	00 
f01006e6:	c7 44 24 04 04 23 11 	movl   $0xf0112304,0x4(%esp)
f01006ed:	f0 
f01006ee:	c7 04 24 60 20 10 f0 	movl   $0xf0102060,(%esp)
f01006f5:	e8 68 03 00 00       	call   f0100a62 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006fa:	c7 44 24 08 64 29 11 	movl   $0x112964,0x8(%esp)
f0100701:	00 
f0100702:	c7 44 24 04 64 29 11 	movl   $0xf0112964,0x4(%esp)
f0100709:	f0 
f010070a:	c7 04 24 84 20 10 f0 	movl   $0xf0102084,(%esp)
f0100711:	e8 4c 03 00 00       	call   f0100a62 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100716:	b8 63 2d 11 f0       	mov    $0xf0112d63,%eax
f010071b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100720:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100725:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010072b:	85 c0                	test   %eax,%eax
f010072d:	0f 48 c2             	cmovs  %edx,%eax
f0100730:	c1 f8 0a             	sar    $0xa,%eax
f0100733:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100737:	c7 04 24 a8 20 10 f0 	movl   $0xf01020a8,(%esp)
f010073e:	e8 1f 03 00 00       	call   f0100a62 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100743:	b8 00 00 00 00       	mov    $0x0,%eax
f0100748:	c9                   	leave  
f0100749:	c3                   	ret    

f010074a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010074a:	55                   	push   %ebp
f010074b:	89 e5                	mov    %esp,%ebp
f010074d:	53                   	push   %ebx
f010074e:	83 ec 14             	sub    $0x14,%esp
f0100751:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100756:	8b 83 c4 21 10 f0    	mov    -0xfefde3c(%ebx),%eax
f010075c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100760:	8b 83 c0 21 10 f0    	mov    -0xfefde40(%ebx),%eax
f0100766:	89 44 24 04          	mov    %eax,0x4(%esp)
f010076a:	c7 04 24 49 1f 10 f0 	movl   $0xf0101f49,(%esp)
f0100771:	e8 ec 02 00 00       	call   f0100a62 <cprintf>
f0100776:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100779:	83 fb 24             	cmp    $0x24,%ebx
f010077c:	75 d8                	jne    f0100756 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010077e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100783:	83 c4 14             	add    $0x14,%esp
f0100786:	5b                   	pop    %ebx
f0100787:	5d                   	pop    %ebp
f0100788:	c3                   	ret    

f0100789 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100789:	55                   	push   %ebp
f010078a:	89 e5                	mov    %esp,%ebp
f010078c:	57                   	push   %edi
f010078d:	56                   	push   %esi
f010078e:	53                   	push   %ebx
f010078f:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100795:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100797:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100799:	8b 43 04             	mov    0x4(%ebx),%eax
f010079c:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f01007a2:	8b 43 08             	mov    0x8(%ebx),%eax
f01007a5:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f01007ab:	8b 43 0c             	mov    0xc(%ebx),%eax
f01007ae:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f01007b4:	8b 43 10             	mov    0x10(%ebx),%eax
f01007b7:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f01007bd:	8b 43 14             	mov    0x14(%ebx),%eax
f01007c0:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f01007c6:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f01007c9:	c7 04 24 52 1f 10 f0 	movl   $0xf0101f52,(%esp)
f01007d0:	e8 8d 02 00 00       	call   f0100a62 <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f01007d5:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f01007da:	85 db                	test   %ebx,%ebx
f01007dc:	0f 84 f5 00 00 00    	je     f01008d7 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f01007e2:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f01007e8:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f01007ee:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f01007f4:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f01007fa:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f01007fe:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100802:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100806:	89 44 24 10          	mov    %eax,0x10(%esp)
f010080a:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100810:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100814:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100818:	89 74 24 04          	mov    %esi,0x4(%esp)
f010081c:	c7 04 24 d4 20 10 f0 	movl   $0xf01020d4,(%esp)
f0100823:	e8 3a 02 00 00       	call   f0100a62 <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100828:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010082b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082f:	89 1c 24             	mov    %ebx,(%esp)
f0100832:	e8 25 03 00 00       	call   f0100b5c <debuginfo_eip>
f0100837:	85 c0                	test   %eax,%eax
f0100839:	0f 88 93 00 00 00    	js     f01008d2 <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f010083f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100842:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100846:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010084c:	89 04 24             	mov    %eax,(%esp)
f010084f:	e8 67 0d 00 00       	call   f01015bb <strcpy>

		int eip_line = info.eip_line;
f0100854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100857:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f010085d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100860:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100864:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100867:	89 44 24 04          	mov    %eax,0x4(%esp)
f010086b:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f010086e:	89 3c 24             	mov    %edi,(%esp)
f0100871:	e8 90 0d 00 00       	call   f0101606 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100876:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100879:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f010087e:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100881:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100885:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100889:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f010088f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100893:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100899:	89 44 24 04          	mov    %eax,0x4(%esp)
f010089d:	c7 04 24 64 1f 10 f0 	movl   $0xf0101f64,(%esp)
f01008a4:	e8 b9 01 00 00       	call   f0100a62 <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f01008a9:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f01008ab:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f01008ae:	8b 46 08             	mov    0x8(%esi),%eax
f01008b1:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f01008b7:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f01008ba:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f01008bd:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f01008c0:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f01008c3:	85 f6                	test   %esi,%esi
f01008c5:	0f 85 2f ff ff ff    	jne    f01007fa <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f01008cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d0:	eb 05                	jmp    f01008d7 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f01008d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f01008d7:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f01008dd:	5b                   	pop    %ebx
f01008de:	5e                   	pop    %esi
f01008df:	5f                   	pop    %edi
f01008e0:	5d                   	pop    %ebp
f01008e1:	c3                   	ret    

f01008e2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008e2:	55                   	push   %ebp
f01008e3:	89 e5                	mov    %esp,%ebp
f01008e5:	57                   	push   %edi
f01008e6:	56                   	push   %esi
f01008e7:	53                   	push   %ebx
f01008e8:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f01008eb:	c7 04 24 08 21 10 f0 	movl   $0xf0102108,(%esp)
f01008f2:	e8 6b 01 00 00       	call   f0100a62 <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f01008f7:	c7 04 24 3c 21 10 f0 	movl   $0xf010213c,(%esp)
f01008fe:	e8 5f 01 00 00       	call   f0100a62 <cprintf>
    
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
f0100903:	c7 04 24 7b 1f 10 f0 	movl   $0xf0101f7b,(%esp)
f010090a:	e8 91 0b 00 00       	call   f01014a0 <readline>
f010090f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100911:	85 c0                	test   %eax,%eax
f0100913:	74 ee                	je     f0100903 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100915:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010091c:	be 00 00 00 00       	mov    $0x0,%esi
f0100921:	eb 06                	jmp    f0100929 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100923:	c6 03 00             	movb   $0x0,(%ebx)
f0100926:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100929:	0f b6 03             	movzbl (%ebx),%eax
f010092c:	84 c0                	test   %al,%al
f010092e:	74 6b                	je     f010099b <monitor+0xb9>
f0100930:	0f be c0             	movsbl %al,%eax
f0100933:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100937:	c7 04 24 7f 1f 10 f0 	movl   $0xf0101f7f,(%esp)
f010093e:	e8 b3 0d 00 00       	call   f01016f6 <strchr>
f0100943:	85 c0                	test   %eax,%eax
f0100945:	75 dc                	jne    f0100923 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100947:	80 3b 00             	cmpb   $0x0,(%ebx)
f010094a:	74 4f                	je     f010099b <monitor+0xb9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010094c:	83 fe 0f             	cmp    $0xf,%esi
f010094f:	90                   	nop
f0100950:	75 16                	jne    f0100968 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100952:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100959:	00 
f010095a:	c7 04 24 84 1f 10 f0 	movl   $0xf0101f84,(%esp)
f0100961:	e8 fc 00 00 00       	call   f0100a62 <cprintf>
f0100966:	eb 9b                	jmp    f0100903 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100968:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010096c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010096f:	0f b6 03             	movzbl (%ebx),%eax
f0100972:	84 c0                	test   %al,%al
f0100974:	75 0c                	jne    f0100982 <monitor+0xa0>
f0100976:	eb b1                	jmp    f0100929 <monitor+0x47>
			buf++;
f0100978:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010097b:	0f b6 03             	movzbl (%ebx),%eax
f010097e:	84 c0                	test   %al,%al
f0100980:	74 a7                	je     f0100929 <monitor+0x47>
f0100982:	0f be c0             	movsbl %al,%eax
f0100985:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100989:	c7 04 24 7f 1f 10 f0 	movl   $0xf0101f7f,(%esp)
f0100990:	e8 61 0d 00 00       	call   f01016f6 <strchr>
f0100995:	85 c0                	test   %eax,%eax
f0100997:	74 df                	je     f0100978 <monitor+0x96>
f0100999:	eb 8e                	jmp    f0100929 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010099b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009a2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009a3:	85 f6                	test   %esi,%esi
f01009a5:	0f 84 58 ff ff ff    	je     f0100903 <monitor+0x21>
f01009ab:	bb c0 21 10 f0       	mov    $0xf01021c0,%ebx
f01009b0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009b5:	8b 03                	mov    (%ebx),%eax
f01009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009bb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009be:	89 04 24             	mov    %eax,(%esp)
f01009c1:	e8 b5 0c 00 00       	call   f010167b <strcmp>
f01009c6:	85 c0                	test   %eax,%eax
f01009c8:	75 24                	jne    f01009ee <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01009ca:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01009cd:	8b 55 08             	mov    0x8(%ebp),%edx
f01009d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01009d4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009d7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009db:	89 34 24             	mov    %esi,(%esp)
f01009de:	ff 14 85 c8 21 10 f0 	call   *-0xfefde38(,%eax,4)
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009e5:	85 c0                	test   %eax,%eax
f01009e7:	78 28                	js     f0100a11 <monitor+0x12f>
f01009e9:	e9 15 ff ff ff       	jmp    f0100903 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009ee:	83 c7 01             	add    $0x1,%edi
f01009f1:	83 c3 0c             	add    $0xc,%ebx
f01009f4:	83 ff 03             	cmp    $0x3,%edi
f01009f7:	75 bc                	jne    f01009b5 <monitor+0xd3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a00:	c7 04 24 a1 1f 10 f0 	movl   $0xf0101fa1,(%esp)
f0100a07:	e8 56 00 00 00       	call   f0100a62 <cprintf>
f0100a0c:	e9 f2 fe ff ff       	jmp    f0100903 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a11:	83 c4 5c             	add    $0x5c,%esp
f0100a14:	5b                   	pop    %ebx
f0100a15:	5e                   	pop    %esi
f0100a16:	5f                   	pop    %edi
f0100a17:	5d                   	pop    %ebp
f0100a18:	c3                   	ret    
f0100a19:	00 00                	add    %al,(%eax)
	...

f0100a1c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a1c:	55                   	push   %ebp
f0100a1d:	89 e5                	mov    %esp,%ebp
f0100a1f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100a22:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a25:	89 04 24             	mov    %eax,(%esp)
f0100a28:	e8 23 fc ff ff       	call   f0100650 <cputchar>
	*cnt++;
}
f0100a2d:	c9                   	leave  
f0100a2e:	c3                   	ret    

f0100a2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a2f:	55                   	push   %ebp
f0100a30:	89 e5                	mov    %esp,%ebp
f0100a32:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100a35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a43:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a46:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a51:	c7 04 24 1c 0a 10 f0 	movl   $0xf0100a1c,(%esp)
f0100a58:	e8 b5 04 00 00       	call   f0100f12 <vprintfmt>
	return cnt;
}
f0100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a60:	c9                   	leave  
f0100a61:	c3                   	ret    

f0100a62 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a62:	55                   	push   %ebp
f0100a63:	89 e5                	mov    %esp,%ebp
f0100a65:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a68:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a72:	89 04 24             	mov    %eax,(%esp)
f0100a75:	e8 b5 ff ff ff       	call   f0100a2f <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a7a:	c9                   	leave  
f0100a7b:	c3                   	ret    

f0100a7c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a7c:	55                   	push   %ebp
f0100a7d:	89 e5                	mov    %esp,%ebp
f0100a7f:	57                   	push   %edi
f0100a80:	56                   	push   %esi
f0100a81:	53                   	push   %ebx
f0100a82:	83 ec 10             	sub    $0x10,%esp
f0100a85:	89 c3                	mov    %eax,%ebx
f0100a87:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100a8a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100a8d:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a90:	8b 0a                	mov    (%edx),%ecx
f0100a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a95:	8b 00                	mov    (%eax),%eax
f0100a97:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a9a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100aa1:	eb 77                	jmp    f0100b1a <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100aa6:	01 c8                	add    %ecx,%eax
f0100aa8:	bf 02 00 00 00       	mov    $0x2,%edi
f0100aad:	99                   	cltd   
f0100aae:	f7 ff                	idiv   %edi
f0100ab0:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ab2:	eb 01                	jmp    f0100ab5 <stab_binsearch+0x39>
			m--;
f0100ab4:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ab5:	39 ca                	cmp    %ecx,%edx
f0100ab7:	7c 1d                	jl     f0100ad6 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100ab9:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100abc:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100ac1:	39 f7                	cmp    %esi,%edi
f0100ac3:	75 ef                	jne    f0100ab4 <stab_binsearch+0x38>
f0100ac5:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100ac8:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100acb:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100acf:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100ad2:	73 18                	jae    f0100aec <stab_binsearch+0x70>
f0100ad4:	eb 05                	jmp    f0100adb <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100ad6:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100ad9:	eb 3f                	jmp    f0100b1a <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100adb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100ade:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100ae0:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ae3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100aea:	eb 2e                	jmp    f0100b1a <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100aec:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100aef:	76 15                	jbe    f0100b06 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100af1:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100af4:	4f                   	dec    %edi
f0100af5:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100af8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100afb:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100afd:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100b04:	eb 14                	jmp    f0100b1a <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b06:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100b09:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100b0c:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100b0e:	ff 45 0c             	incl   0xc(%ebp)
f0100b11:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100b13:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100b1a:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100b1d:	7e 84                	jle    f0100aa3 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b1f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100b23:	75 0d                	jne    f0100b32 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0100b25:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b28:	8b 02                	mov    (%edx),%eax
f0100b2a:	48                   	dec    %eax
f0100b2b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100b2e:	89 01                	mov    %eax,(%ecx)
f0100b30:	eb 22                	jmp    f0100b54 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b32:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100b35:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b37:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b3a:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b3c:	eb 01                	jmp    f0100b3f <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100b3e:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b3f:	39 c1                	cmp    %eax,%ecx
f0100b41:	7d 0c                	jge    f0100b4f <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100b43:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100b46:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100b4b:	39 f2                	cmp    %esi,%edx
f0100b4d:	75 ef                	jne    f0100b3e <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b4f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b52:	89 02                	mov    %eax,(%edx)
	}
}
f0100b54:	83 c4 10             	add    $0x10,%esp
f0100b57:	5b                   	pop    %ebx
f0100b58:	5e                   	pop    %esi
f0100b59:	5f                   	pop    %edi
f0100b5a:	5d                   	pop    %ebp
f0100b5b:	c3                   	ret    

f0100b5c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b5c:	55                   	push   %ebp
f0100b5d:	89 e5                	mov    %esp,%ebp
f0100b5f:	83 ec 58             	sub    $0x58,%esp
f0100b62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100b65:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100b68:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100b6b:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b71:	c7 03 e4 21 10 f0    	movl   $0xf01021e4,(%ebx)
	info->eip_line = 0;
f0100b77:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b7e:	c7 43 08 e4 21 10 f0 	movl   $0xf01021e4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b85:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b8c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b8f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b96:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b9c:	76 12                	jbe    f0100bb0 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b9e:	b8 92 7d 10 f0       	mov    $0xf0107d92,%eax
f0100ba3:	3d 89 63 10 f0       	cmp    $0xf0106389,%eax
f0100ba8:	0f 86 f1 01 00 00    	jbe    f0100d9f <debuginfo_eip+0x243>
f0100bae:	eb 1c                	jmp    f0100bcc <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100bb0:	c7 44 24 08 ee 21 10 	movl   $0xf01021ee,0x8(%esp)
f0100bb7:	f0 
f0100bb8:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100bbf:	00 
f0100bc0:	c7 04 24 fb 21 10 f0 	movl   $0xf01021fb,(%esp)
f0100bc7:	e8 2c f5 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bd1:	80 3d 91 7d 10 f0 00 	cmpb   $0x0,0xf0107d91
f0100bd8:	0f 85 cd 01 00 00    	jne    f0100dab <debuginfo_eip+0x24f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bde:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100be5:	b8 88 63 10 f0       	mov    $0xf0106388,%eax
f0100bea:	2d 34 24 10 f0       	sub    $0xf0102434,%eax
f0100bef:	c1 f8 02             	sar    $0x2,%eax
f0100bf2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100bf8:	83 e8 01             	sub    $0x1,%eax
f0100bfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bfe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c02:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100c09:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c0c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c0f:	b8 34 24 10 f0       	mov    $0xf0102434,%eax
f0100c14:	e8 63 fe ff ff       	call   f0100a7c <stab_binsearch>
	if (lfile == 0)
f0100c19:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100c21:	85 d2                	test   %edx,%edx
f0100c23:	0f 84 82 01 00 00    	je     f0100dab <debuginfo_eip+0x24f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c29:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100c2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c32:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c36:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100c3d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c40:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c43:	b8 34 24 10 f0       	mov    $0xf0102434,%eax
f0100c48:	e8 2f fe ff ff       	call   f0100a7c <stab_binsearch>

	if (lfun <= rfun) {
f0100c4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c50:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c53:	39 d0                	cmp    %edx,%eax
f0100c55:	7f 3d                	jg     f0100c94 <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c57:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100c5a:	8d b9 34 24 10 f0    	lea    -0xfefdbcc(%ecx),%edi
f0100c60:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0100c63:	8b 89 34 24 10 f0    	mov    -0xfefdbcc(%ecx),%ecx
f0100c69:	bf 92 7d 10 f0       	mov    $0xf0107d92,%edi
f0100c6e:	81 ef 89 63 10 f0    	sub    $0xf0106389,%edi
f0100c74:	39 f9                	cmp    %edi,%ecx
f0100c76:	73 09                	jae    f0100c81 <debuginfo_eip+0x125>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c78:	81 c1 89 63 10 f0    	add    $0xf0106389,%ecx
f0100c7e:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c81:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100c84:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c87:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c8a:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c8f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c92:	eb 0f                	jmp    f0100ca3 <debuginfo_eip+0x147>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c94:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ca0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ca3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100caa:	00 
f0100cab:	8b 43 08             	mov    0x8(%ebx),%eax
f0100cae:	89 04 24             	mov    %eax,(%esp)
f0100cb1:	e8 74 0a 00 00       	call   f010172a <strfind>
f0100cb6:	2b 43 08             	sub    0x8(%ebx),%eax
f0100cb9:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100cbc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cc0:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100cc7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100cca:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100ccd:	b8 34 24 10 f0       	mov    $0xf0102434,%eax
f0100cd2:	e8 a5 fd ff ff       	call   f0100a7c <stab_binsearch>

	if(lline <= rline)
f0100cd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0100cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0100cdf:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100ce2:	0f 8f c3 00 00 00    	jg     f0100dab <debuginfo_eip+0x24f>
		info->eip_line = stabs[lline].n_desc;
f0100ce8:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100ceb:	0f b7 82 3a 24 10 f0 	movzwl -0xfefdbc6(%edx),%eax
f0100cf2:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cf8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100cfb:	39 c8                	cmp    %ecx,%eax
f0100cfd:	7c 5f                	jl     f0100d5e <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f0100cff:	89 c2                	mov    %eax,%edx
f0100d01:	6b f0 0c             	imul   $0xc,%eax,%esi
f0100d04:	80 be 38 24 10 f0 84 	cmpb   $0x84,-0xfefdbc8(%esi)
f0100d0b:	75 18                	jne    f0100d25 <debuginfo_eip+0x1c9>
f0100d0d:	eb 30                	jmp    f0100d3f <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100d0f:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d12:	39 c1                	cmp    %eax,%ecx
f0100d14:	7f 48                	jg     f0100d5e <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f0100d16:	89 c2                	mov    %eax,%edx
f0100d18:	8d 34 40             	lea    (%eax,%eax,2),%esi
f0100d1b:	80 3c b5 38 24 10 f0 	cmpb   $0x84,-0xfefdbc8(,%esi,4)
f0100d22:	84 
f0100d23:	74 1a                	je     f0100d3f <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d25:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d28:	8d 14 95 34 24 10 f0 	lea    -0xfefdbcc(,%edx,4),%edx
f0100d2f:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f0100d33:	75 da                	jne    f0100d0f <debuginfo_eip+0x1b3>
f0100d35:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100d39:	74 d4                	je     f0100d0f <debuginfo_eip+0x1b3>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d3b:	39 c1                	cmp    %eax,%ecx
f0100d3d:	7f 1f                	jg     f0100d5e <debuginfo_eip+0x202>
f0100d3f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d42:	8b 80 34 24 10 f0    	mov    -0xfefdbcc(%eax),%eax
f0100d48:	ba 92 7d 10 f0       	mov    $0xf0107d92,%edx
f0100d4d:	81 ea 89 63 10 f0    	sub    $0xf0106389,%edx
f0100d53:	39 d0                	cmp    %edx,%eax
f0100d55:	73 07                	jae    f0100d5e <debuginfo_eip+0x202>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d57:	05 89 63 10 f0       	add    $0xf0106389,%eax
f0100d5c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d61:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d64:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d69:	39 ca                	cmp    %ecx,%edx
f0100d6b:	7d 3e                	jge    f0100dab <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
f0100d6d:	83 c2 01             	add    $0x1,%edx
f0100d70:	39 d1                	cmp    %edx,%ecx
f0100d72:	7e 37                	jle    f0100dab <debuginfo_eip+0x24f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d74:	6b f2 0c             	imul   $0xc,%edx,%esi
f0100d77:	80 be 38 24 10 f0 a0 	cmpb   $0xa0,-0xfefdbc8(%esi)
f0100d7e:	75 2b                	jne    f0100dab <debuginfo_eip+0x24f>
		     lline++)
			info->eip_fn_narg++;
f0100d80:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100d84:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d87:	39 d1                	cmp    %edx,%ecx
f0100d89:	7e 1b                	jle    f0100da6 <debuginfo_eip+0x24a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d8b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100d8e:	80 3c 85 38 24 10 f0 	cmpb   $0xa0,-0xfefdbc8(,%eax,4)
f0100d95:	a0 
f0100d96:	74 e8                	je     f0100d80 <debuginfo_eip+0x224>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d98:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d9d:	eb 0c                	jmp    f0100dab <debuginfo_eip+0x24f>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100da4:	eb 05                	jmp    f0100dab <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100dab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100dae:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100db1:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100db4:	89 ec                	mov    %ebp,%esp
f0100db6:	5d                   	pop    %ebp
f0100db7:	c3                   	ret    

f0100db8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100db8:	55                   	push   %ebp
f0100db9:	89 e5                	mov    %esp,%ebp
f0100dbb:	57                   	push   %edi
f0100dbc:	56                   	push   %esi
f0100dbd:	53                   	push   %ebx
f0100dbe:	83 ec 3c             	sub    $0x3c,%esp
f0100dc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dc4:	89 d7                	mov    %edx,%edi
f0100dc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dc9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dcf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100dd2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100dd5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100dd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ddd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100de0:	72 11                	jb     f0100df3 <printnum+0x3b>
f0100de2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100de5:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100de8:	76 09                	jbe    f0100df3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100dea:	83 eb 01             	sub    $0x1,%ebx
f0100ded:	85 db                	test   %ebx,%ebx
f0100def:	7f 51                	jg     f0100e42 <printnum+0x8a>
f0100df1:	eb 5e                	jmp    f0100e51 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100df3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100df7:	83 eb 01             	sub    $0x1,%ebx
f0100dfa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100dfe:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e01:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e05:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100e09:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100e0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100e14:	00 
f0100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e18:	89 04 24             	mov    %eax,(%esp)
f0100e1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e22:	e8 79 0b 00 00       	call   f01019a0 <__udivdi3>
f0100e27:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100e2b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100e2f:	89 04 24             	mov    %eax,(%esp)
f0100e32:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e36:	89 fa                	mov    %edi,%edx
f0100e38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e3b:	e8 78 ff ff ff       	call   f0100db8 <printnum>
f0100e40:	eb 0f                	jmp    f0100e51 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e42:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e46:	89 34 24             	mov    %esi,(%esp)
f0100e49:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e4c:	83 eb 01             	sub    $0x1,%ebx
f0100e4f:	75 f1                	jne    f0100e42 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e51:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e55:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100e59:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e5c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e60:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100e67:	00 
f0100e68:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e6b:	89 04 24             	mov    %eax,(%esp)
f0100e6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e75:	e8 56 0c 00 00       	call   f0101ad0 <__umoddi3>
f0100e7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e7e:	0f be 80 09 22 10 f0 	movsbl -0xfefddf7(%eax),%eax
f0100e85:	89 04 24             	mov    %eax,(%esp)
f0100e88:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100e8b:	83 c4 3c             	add    $0x3c,%esp
f0100e8e:	5b                   	pop    %ebx
f0100e8f:	5e                   	pop    %esi
f0100e90:	5f                   	pop    %edi
f0100e91:	5d                   	pop    %ebp
f0100e92:	c3                   	ret    

f0100e93 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100e93:	55                   	push   %ebp
f0100e94:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e96:	83 fa 01             	cmp    $0x1,%edx
f0100e99:	7e 0e                	jle    f0100ea9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100e9b:	8b 10                	mov    (%eax),%edx
f0100e9d:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100ea0:	89 08                	mov    %ecx,(%eax)
f0100ea2:	8b 02                	mov    (%edx),%eax
f0100ea4:	8b 52 04             	mov    0x4(%edx),%edx
f0100ea7:	eb 22                	jmp    f0100ecb <getuint+0x38>
	else if (lflag)
f0100ea9:	85 d2                	test   %edx,%edx
f0100eab:	74 10                	je     f0100ebd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100ead:	8b 10                	mov    (%eax),%edx
f0100eaf:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100eb2:	89 08                	mov    %ecx,(%eax)
f0100eb4:	8b 02                	mov    (%edx),%eax
f0100eb6:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ebb:	eb 0e                	jmp    f0100ecb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100ebd:	8b 10                	mov    (%eax),%edx
f0100ebf:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100ec2:	89 08                	mov    %ecx,(%eax)
f0100ec4:	8b 02                	mov    (%edx),%eax
f0100ec6:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100ecb:	5d                   	pop    %ebp
f0100ecc:	c3                   	ret    

f0100ecd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ecd:	55                   	push   %ebp
f0100ece:	89 e5                	mov    %esp,%ebp
f0100ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ed3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ed7:	8b 10                	mov    (%eax),%edx
f0100ed9:	3b 50 04             	cmp    0x4(%eax),%edx
f0100edc:	73 0a                	jae    f0100ee8 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ee1:	88 0a                	mov    %cl,(%edx)
f0100ee3:	83 c2 01             	add    $0x1,%edx
f0100ee6:	89 10                	mov    %edx,(%eax)
}
f0100ee8:	5d                   	pop    %ebp
f0100ee9:	c3                   	ret    

f0100eea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100eea:	55                   	push   %ebp
f0100eeb:	89 e5                	mov    %esp,%ebp
f0100eed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100ef0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ef3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ef7:	8b 45 10             	mov    0x10(%ebp),%eax
f0100efa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100efe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f05:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f08:	89 04 24             	mov    %eax,(%esp)
f0100f0b:	e8 02 00 00 00       	call   f0100f12 <vprintfmt>
	va_end(ap);
}
f0100f10:	c9                   	leave  
f0100f11:	c3                   	ret    

f0100f12 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100f12:	55                   	push   %ebp
f0100f13:	89 e5                	mov    %esp,%ebp
f0100f15:	57                   	push   %edi
f0100f16:	56                   	push   %esi
f0100f17:	53                   	push   %ebx
f0100f18:	83 ec 5c             	sub    $0x5c,%esp
f0100f1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f1e:	8b 75 10             	mov    0x10(%ebp),%esi
f0100f21:	eb 12                	jmp    f0100f35 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100f23:	85 c0                	test   %eax,%eax
f0100f25:	0f 84 e4 04 00 00    	je     f010140f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f0100f2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f2f:	89 04 24             	mov    %eax,(%esp)
f0100f32:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f35:	0f b6 06             	movzbl (%esi),%eax
f0100f38:	83 c6 01             	add    $0x1,%esi
f0100f3b:	83 f8 25             	cmp    $0x25,%eax
f0100f3e:	75 e3                	jne    f0100f23 <vprintfmt+0x11>
f0100f40:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0100f44:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0100f4b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100f50:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100f57:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f5c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100f5f:	eb 2b                	jmp    f0100f8c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f61:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100f64:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0100f68:	eb 22                	jmp    f0100f8c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f6a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100f6d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0100f71:	eb 19                	jmp    f0100f8c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f73:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100f76:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0100f7d:	eb 0d                	jmp    f0100f8c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100f7f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f82:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f85:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f8c:	0f b6 06             	movzbl (%esi),%eax
f0100f8f:	0f b6 d0             	movzbl %al,%edx
f0100f92:	8d 7e 01             	lea    0x1(%esi),%edi
f0100f95:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f98:	83 e8 23             	sub    $0x23,%eax
f0100f9b:	3c 55                	cmp    $0x55,%al
f0100f9d:	0f 87 46 04 00 00    	ja     f01013e9 <vprintfmt+0x4d7>
f0100fa3:	0f b6 c0             	movzbl %al,%eax
f0100fa6:	ff 24 85 b0 22 10 f0 	jmp    *-0xfefdd50(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100fad:	83 ea 30             	sub    $0x30,%edx
f0100fb0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0100fb3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0100fb7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0100fbd:	83 fa 09             	cmp    $0x9,%edx
f0100fc0:	77 4a                	ja     f010100c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fc2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100fc5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0100fc8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100fcb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100fcf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100fd2:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100fd5:	83 fa 09             	cmp    $0x9,%edx
f0100fd8:	76 eb                	jbe    f0100fc5 <vprintfmt+0xb3>
f0100fda:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100fdd:	eb 2d                	jmp    f010100c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100fdf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe2:	8d 50 04             	lea    0x4(%eax),%edx
f0100fe5:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fe8:	8b 00                	mov    (%eax),%eax
f0100fea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fed:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ff0:	eb 1a                	jmp    f010100c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ff2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0100ff5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0100ff9:	79 91                	jns    f0100f8c <vprintfmt+0x7a>
f0100ffb:	e9 73 ff ff ff       	jmp    f0100f73 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101000:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101003:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f010100a:	eb 80                	jmp    f0100f8c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f010100c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0101010:	0f 89 76 ff ff ff    	jns    f0100f8c <vprintfmt+0x7a>
f0101016:	e9 64 ff ff ff       	jmp    f0100f7f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010101b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010101e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101021:	e9 66 ff ff ff       	jmp    f0100f8c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101026:	8b 45 14             	mov    0x14(%ebp),%eax
f0101029:	8d 50 04             	lea    0x4(%eax),%edx
f010102c:	89 55 14             	mov    %edx,0x14(%ebp)
f010102f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101033:	8b 00                	mov    (%eax),%eax
f0101035:	89 04 24             	mov    %eax,(%esp)
f0101038:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010103b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010103e:	e9 f2 fe ff ff       	jmp    f0100f35 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0101043:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0101047:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f010104a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f010104e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0101051:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0101055:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0101058:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f010105b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f010105f:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0101062:	80 f9 09             	cmp    $0x9,%cl
f0101065:	77 1d                	ja     f0101084 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0101067:	0f be c0             	movsbl %al,%eax
f010106a:	6b c0 64             	imul   $0x64,%eax,%eax
f010106d:	0f be d2             	movsbl %dl,%edx
f0101070:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0101073:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f010107a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
f010107f:	e9 b1 fe ff ff       	jmp    f0100f35 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0101084:	c7 44 24 04 21 22 10 	movl   $0xf0102221,0x4(%esp)
f010108b:	f0 
f010108c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010108f:	89 04 24             	mov    %eax,(%esp)
f0101092:	e8 e4 05 00 00       	call   f010167b <strcmp>
f0101097:	85 c0                	test   %eax,%eax
f0101099:	75 0f                	jne    f01010aa <vprintfmt+0x198>
f010109b:	c7 05 00 23 11 f0 04 	movl   $0x4,0xf0112300
f01010a2:	00 00 00 
f01010a5:	e9 8b fe ff ff       	jmp    f0100f35 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f01010aa:	c7 44 24 04 25 22 10 	movl   $0xf0102225,0x4(%esp)
f01010b1:	f0 
f01010b2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01010b5:	89 14 24             	mov    %edx,(%esp)
f01010b8:	e8 be 05 00 00       	call   f010167b <strcmp>
f01010bd:	85 c0                	test   %eax,%eax
f01010bf:	75 0f                	jne    f01010d0 <vprintfmt+0x1be>
f01010c1:	c7 05 00 23 11 f0 02 	movl   $0x2,0xf0112300
f01010c8:	00 00 00 
f01010cb:	e9 65 fe ff ff       	jmp    f0100f35 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f01010d0:	c7 44 24 04 29 22 10 	movl   $0xf0102229,0x4(%esp)
f01010d7:	f0 
f01010d8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f01010db:	89 0c 24             	mov    %ecx,(%esp)
f01010de:	e8 98 05 00 00       	call   f010167b <strcmp>
f01010e3:	85 c0                	test   %eax,%eax
f01010e5:	75 0f                	jne    f01010f6 <vprintfmt+0x1e4>
f01010e7:	c7 05 00 23 11 f0 01 	movl   $0x1,0xf0112300
f01010ee:	00 00 00 
f01010f1:	e9 3f fe ff ff       	jmp    f0100f35 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f01010f6:	c7 44 24 04 2d 22 10 	movl   $0xf010222d,0x4(%esp)
f01010fd:	f0 
f01010fe:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0101101:	89 3c 24             	mov    %edi,(%esp)
f0101104:	e8 72 05 00 00       	call   f010167b <strcmp>
f0101109:	85 c0                	test   %eax,%eax
f010110b:	75 0f                	jne    f010111c <vprintfmt+0x20a>
f010110d:	c7 05 00 23 11 f0 06 	movl   $0x6,0xf0112300
f0101114:	00 00 00 
f0101117:	e9 19 fe ff ff       	jmp    f0100f35 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f010111c:	c7 44 24 04 31 22 10 	movl   $0xf0102231,0x4(%esp)
f0101123:	f0 
f0101124:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101127:	89 04 24             	mov    %eax,(%esp)
f010112a:	e8 4c 05 00 00       	call   f010167b <strcmp>
f010112f:	85 c0                	test   %eax,%eax
f0101131:	75 0f                	jne    f0101142 <vprintfmt+0x230>
f0101133:	c7 05 00 23 11 f0 07 	movl   $0x7,0xf0112300
f010113a:	00 00 00 
f010113d:	e9 f3 fd ff ff       	jmp    f0100f35 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0101142:	c7 44 24 04 35 22 10 	movl   $0xf0102235,0x4(%esp)
f0101149:	f0 
f010114a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010114d:	89 14 24             	mov    %edx,(%esp)
f0101150:	e8 26 05 00 00       	call   f010167b <strcmp>
f0101155:	83 f8 01             	cmp    $0x1,%eax
f0101158:	19 c0                	sbb    %eax,%eax
f010115a:	f7 d0                	not    %eax
f010115c:	83 c0 08             	add    $0x8,%eax
f010115f:	a3 00 23 11 f0       	mov    %eax,0xf0112300
f0101164:	e9 cc fd ff ff       	jmp    f0100f35 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0101169:	8b 45 14             	mov    0x14(%ebp),%eax
f010116c:	8d 50 04             	lea    0x4(%eax),%edx
f010116f:	89 55 14             	mov    %edx,0x14(%ebp)
f0101172:	8b 00                	mov    (%eax),%eax
f0101174:	89 c2                	mov    %eax,%edx
f0101176:	c1 fa 1f             	sar    $0x1f,%edx
f0101179:	31 d0                	xor    %edx,%eax
f010117b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010117d:	83 f8 06             	cmp    $0x6,%eax
f0101180:	7f 0b                	jg     f010118d <vprintfmt+0x27b>
f0101182:	8b 14 85 08 24 10 f0 	mov    -0xfefdbf8(,%eax,4),%edx
f0101189:	85 d2                	test   %edx,%edx
f010118b:	75 23                	jne    f01011b0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f010118d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101191:	c7 44 24 08 39 22 10 	movl   $0xf0102239,0x8(%esp)
f0101198:	f0 
f0101199:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010119d:	8b 7d 08             	mov    0x8(%ebp),%edi
f01011a0:	89 3c 24             	mov    %edi,(%esp)
f01011a3:	e8 42 fd ff ff       	call   f0100eea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01011ab:	e9 85 fd ff ff       	jmp    f0100f35 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01011b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01011b4:	c7 44 24 08 42 22 10 	movl   $0xf0102242,0x8(%esp)
f01011bb:	f0 
f01011bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011c0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01011c3:	89 3c 24             	mov    %edi,(%esp)
f01011c6:	e8 1f fd ff ff       	call   f0100eea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011cb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01011ce:	e9 62 fd ff ff       	jmp    f0100f35 <vprintfmt+0x23>
f01011d3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01011d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01011d9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01011dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01011df:	8d 50 04             	lea    0x4(%eax),%edx
f01011e2:	89 55 14             	mov    %edx,0x14(%ebp)
f01011e5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01011e7:	85 f6                	test   %esi,%esi
f01011e9:	b8 1a 22 10 f0       	mov    $0xf010221a,%eax
f01011ee:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01011f1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f01011f5:	7e 06                	jle    f01011fd <vprintfmt+0x2eb>
f01011f7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f01011fb:	75 13                	jne    f0101210 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011fd:	0f be 06             	movsbl (%esi),%eax
f0101200:	83 c6 01             	add    $0x1,%esi
f0101203:	85 c0                	test   %eax,%eax
f0101205:	0f 85 94 00 00 00    	jne    f010129f <vprintfmt+0x38d>
f010120b:	e9 81 00 00 00       	jmp    f0101291 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101210:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101214:	89 34 24             	mov    %esi,(%esp)
f0101217:	e8 6f 03 00 00       	call   f010158b <strnlen>
f010121c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010121f:	29 c2                	sub    %eax,%edx
f0101221:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0101224:	85 d2                	test   %edx,%edx
f0101226:	7e d5                	jle    f01011fd <vprintfmt+0x2eb>
					putch(padc, putdat);
f0101228:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f010122c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010122f:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0101232:	89 d6                	mov    %edx,%esi
f0101234:	89 cf                	mov    %ecx,%edi
f0101236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010123a:	89 3c 24             	mov    %edi,(%esp)
f010123d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101240:	83 ee 01             	sub    $0x1,%esi
f0101243:	75 f1                	jne    f0101236 <vprintfmt+0x324>
f0101245:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0101248:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010124b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010124e:	eb ad                	jmp    f01011fd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101250:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0101254:	74 1b                	je     f0101271 <vprintfmt+0x35f>
f0101256:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101259:	83 fa 5e             	cmp    $0x5e,%edx
f010125c:	76 13                	jbe    f0101271 <vprintfmt+0x35f>
					putch('?', putdat);
f010125e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101261:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101265:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010126c:	ff 55 08             	call   *0x8(%ebp)
f010126f:	eb 0d                	jmp    f010127e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0101271:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101274:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101278:	89 04 24             	mov    %eax,(%esp)
f010127b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010127e:	83 eb 01             	sub    $0x1,%ebx
f0101281:	0f be 06             	movsbl (%esi),%eax
f0101284:	83 c6 01             	add    $0x1,%esi
f0101287:	85 c0                	test   %eax,%eax
f0101289:	75 1a                	jne    f01012a5 <vprintfmt+0x393>
f010128b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010128e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101291:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101294:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0101298:	7f 1c                	jg     f01012b6 <vprintfmt+0x3a4>
f010129a:	e9 96 fc ff ff       	jmp    f0100f35 <vprintfmt+0x23>
f010129f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01012a2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012a5:	85 ff                	test   %edi,%edi
f01012a7:	78 a7                	js     f0101250 <vprintfmt+0x33e>
f01012a9:	83 ef 01             	sub    $0x1,%edi
f01012ac:	79 a2                	jns    f0101250 <vprintfmt+0x33e>
f01012ae:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01012b1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01012b4:	eb db                	jmp    f0101291 <vprintfmt+0x37f>
f01012b6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012b9:	89 de                	mov    %ebx,%esi
f01012bb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01012be:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01012c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01012cb:	83 eb 01             	sub    $0x1,%ebx
f01012ce:	75 ee                	jne    f01012be <vprintfmt+0x3ac>
f01012d0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012d2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01012d5:	e9 5b fc ff ff       	jmp    f0100f35 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01012da:	83 f9 01             	cmp    $0x1,%ecx
f01012dd:	7e 10                	jle    f01012ef <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f01012df:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e2:	8d 50 08             	lea    0x8(%eax),%edx
f01012e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01012e8:	8b 30                	mov    (%eax),%esi
f01012ea:	8b 78 04             	mov    0x4(%eax),%edi
f01012ed:	eb 26                	jmp    f0101315 <vprintfmt+0x403>
	else if (lflag)
f01012ef:	85 c9                	test   %ecx,%ecx
f01012f1:	74 12                	je     f0101305 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f01012f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f6:	8d 50 04             	lea    0x4(%eax),%edx
f01012f9:	89 55 14             	mov    %edx,0x14(%ebp)
f01012fc:	8b 30                	mov    (%eax),%esi
f01012fe:	89 f7                	mov    %esi,%edi
f0101300:	c1 ff 1f             	sar    $0x1f,%edi
f0101303:	eb 10                	jmp    f0101315 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0101305:	8b 45 14             	mov    0x14(%ebp),%eax
f0101308:	8d 50 04             	lea    0x4(%eax),%edx
f010130b:	89 55 14             	mov    %edx,0x14(%ebp)
f010130e:	8b 30                	mov    (%eax),%esi
f0101310:	89 f7                	mov    %esi,%edi
f0101312:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101315:	85 ff                	test   %edi,%edi
f0101317:	78 0e                	js     f0101327 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101319:	89 f0                	mov    %esi,%eax
f010131b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010131d:	be 0a 00 00 00       	mov    $0xa,%esi
f0101322:	e9 84 00 00 00       	jmp    f01013ab <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0101327:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010132b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101332:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101335:	89 f0                	mov    %esi,%eax
f0101337:	89 fa                	mov    %edi,%edx
f0101339:	f7 d8                	neg    %eax
f010133b:	83 d2 00             	adc    $0x0,%edx
f010133e:	f7 da                	neg    %edx
			}
			base = 10;
f0101340:	be 0a 00 00 00       	mov    $0xa,%esi
f0101345:	eb 64                	jmp    f01013ab <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101347:	89 ca                	mov    %ecx,%edx
f0101349:	8d 45 14             	lea    0x14(%ebp),%eax
f010134c:	e8 42 fb ff ff       	call   f0100e93 <getuint>
			base = 10;
f0101351:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0101356:	eb 53                	jmp    f01013ab <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0101358:	89 ca                	mov    %ecx,%edx
f010135a:	8d 45 14             	lea    0x14(%ebp),%eax
f010135d:	e8 31 fb ff ff       	call   f0100e93 <getuint>
    			base = 8;
f0101362:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0101367:	eb 42                	jmp    f01013ab <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0101369:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010136d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101374:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101377:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010137b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101382:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101385:	8b 45 14             	mov    0x14(%ebp),%eax
f0101388:	8d 50 04             	lea    0x4(%eax),%edx
f010138b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010138e:	8b 00                	mov    (%eax),%eax
f0101390:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101395:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f010139a:	eb 0f                	jmp    f01013ab <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010139c:	89 ca                	mov    %ecx,%edx
f010139e:	8d 45 14             	lea    0x14(%ebp),%eax
f01013a1:	e8 ed fa ff ff       	call   f0100e93 <getuint>
			base = 16;
f01013a6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01013ab:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f01013af:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01013b3:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01013b6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01013ba:	89 74 24 08          	mov    %esi,0x8(%esp)
f01013be:	89 04 24             	mov    %eax,(%esp)
f01013c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013c5:	89 da                	mov    %ebx,%edx
f01013c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ca:	e8 e9 f9 ff ff       	call   f0100db8 <printnum>
			break;
f01013cf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01013d2:	e9 5e fb ff ff       	jmp    f0100f35 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01013d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013db:	89 14 24             	mov    %edx,(%esp)
f01013de:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01013e4:	e9 4c fb ff ff       	jmp    f0100f35 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01013e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01013f4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013f7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01013fb:	0f 84 34 fb ff ff    	je     f0100f35 <vprintfmt+0x23>
f0101401:	83 ee 01             	sub    $0x1,%esi
f0101404:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101408:	75 f7                	jne    f0101401 <vprintfmt+0x4ef>
f010140a:	e9 26 fb ff ff       	jmp    f0100f35 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f010140f:	83 c4 5c             	add    $0x5c,%esp
f0101412:	5b                   	pop    %ebx
f0101413:	5e                   	pop    %esi
f0101414:	5f                   	pop    %edi
f0101415:	5d                   	pop    %ebp
f0101416:	c3                   	ret    

f0101417 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101417:	55                   	push   %ebp
f0101418:	89 e5                	mov    %esp,%ebp
f010141a:	83 ec 28             	sub    $0x28,%esp
f010141d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101420:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101423:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101426:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010142a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010142d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101434:	85 c0                	test   %eax,%eax
f0101436:	74 30                	je     f0101468 <vsnprintf+0x51>
f0101438:	85 d2                	test   %edx,%edx
f010143a:	7e 2c                	jle    f0101468 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010143c:	8b 45 14             	mov    0x14(%ebp),%eax
f010143f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101443:	8b 45 10             	mov    0x10(%ebp),%eax
f0101446:	89 44 24 08          	mov    %eax,0x8(%esp)
f010144a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010144d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101451:	c7 04 24 cd 0e 10 f0 	movl   $0xf0100ecd,(%esp)
f0101458:	e8 b5 fa ff ff       	call   f0100f12 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010145d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101460:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101463:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101466:	eb 05                	jmp    f010146d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010146d:	c9                   	leave  
f010146e:	c3                   	ret    

f010146f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010146f:	55                   	push   %ebp
f0101470:	89 e5                	mov    %esp,%ebp
f0101472:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101475:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101478:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010147c:	8b 45 10             	mov    0x10(%ebp),%eax
f010147f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101483:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101486:	89 44 24 04          	mov    %eax,0x4(%esp)
f010148a:	8b 45 08             	mov    0x8(%ebp),%eax
f010148d:	89 04 24             	mov    %eax,(%esp)
f0101490:	e8 82 ff ff ff       	call   f0101417 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101495:	c9                   	leave  
f0101496:	c3                   	ret    
	...

f01014a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
f01014a3:	57                   	push   %edi
f01014a4:	56                   	push   %esi
f01014a5:	53                   	push   %ebx
f01014a6:	83 ec 1c             	sub    $0x1c,%esp
f01014a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014ac:	85 c0                	test   %eax,%eax
f01014ae:	74 10                	je     f01014c0 <readline+0x20>
		cprintf("%s", prompt);
f01014b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014b4:	c7 04 24 42 22 10 f0 	movl   $0xf0102242,(%esp)
f01014bb:	e8 a2 f5 ff ff       	call   f0100a62 <cprintf>

	i = 0;
	echoing = iscons(0);
f01014c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014c7:	e8 a5 f1 ff ff       	call   f0100671 <iscons>
f01014cc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01014ce:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01014d3:	e8 88 f1 ff ff       	call   f0100660 <getchar>
f01014d8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01014da:	85 c0                	test   %eax,%eax
f01014dc:	79 17                	jns    f01014f5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01014de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014e2:	c7 04 24 24 24 10 f0 	movl   $0xf0102424,(%esp)
f01014e9:	e8 74 f5 ff ff       	call   f0100a62 <cprintf>
			return NULL;
f01014ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01014f3:	eb 6d                	jmp    f0101562 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01014f5:	83 f8 08             	cmp    $0x8,%eax
f01014f8:	74 05                	je     f01014ff <readline+0x5f>
f01014fa:	83 f8 7f             	cmp    $0x7f,%eax
f01014fd:	75 19                	jne    f0101518 <readline+0x78>
f01014ff:	85 f6                	test   %esi,%esi
f0101501:	7e 15                	jle    f0101518 <readline+0x78>
			if (echoing)
f0101503:	85 ff                	test   %edi,%edi
f0101505:	74 0c                	je     f0101513 <readline+0x73>
				cputchar('\b');
f0101507:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010150e:	e8 3d f1 ff ff       	call   f0100650 <cputchar>
			i--;
f0101513:	83 ee 01             	sub    $0x1,%esi
f0101516:	eb bb                	jmp    f01014d3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101518:	83 fb 1f             	cmp    $0x1f,%ebx
f010151b:	7e 1f                	jle    f010153c <readline+0x9c>
f010151d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101523:	7f 17                	jg     f010153c <readline+0x9c>
			if (echoing)
f0101525:	85 ff                	test   %edi,%edi
f0101527:	74 08                	je     f0101531 <readline+0x91>
				cputchar(c);
f0101529:	89 1c 24             	mov    %ebx,(%esp)
f010152c:	e8 1f f1 ff ff       	call   f0100650 <cputchar>
			buf[i++] = c;
f0101531:	88 9e 60 25 11 f0    	mov    %bl,-0xfeedaa0(%esi)
f0101537:	83 c6 01             	add    $0x1,%esi
f010153a:	eb 97                	jmp    f01014d3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010153c:	83 fb 0a             	cmp    $0xa,%ebx
f010153f:	74 05                	je     f0101546 <readline+0xa6>
f0101541:	83 fb 0d             	cmp    $0xd,%ebx
f0101544:	75 8d                	jne    f01014d3 <readline+0x33>
			if (echoing)
f0101546:	85 ff                	test   %edi,%edi
f0101548:	74 0c                	je     f0101556 <readline+0xb6>
				cputchar('\n');
f010154a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101551:	e8 fa f0 ff ff       	call   f0100650 <cputchar>
			buf[i] = 0;
f0101556:	c6 86 60 25 11 f0 00 	movb   $0x0,-0xfeedaa0(%esi)
			return buf;
f010155d:	b8 60 25 11 f0       	mov    $0xf0112560,%eax
		}
	}
}
f0101562:	83 c4 1c             	add    $0x1c,%esp
f0101565:	5b                   	pop    %ebx
f0101566:	5e                   	pop    %esi
f0101567:	5f                   	pop    %edi
f0101568:	5d                   	pop    %ebp
f0101569:	c3                   	ret    
f010156a:	00 00                	add    %al,(%eax)
f010156c:	00 00                	add    %al,(%eax)
	...

f0101570 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101570:	55                   	push   %ebp
f0101571:	89 e5                	mov    %esp,%ebp
f0101573:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101576:	b8 00 00 00 00       	mov    $0x0,%eax
f010157b:	80 3a 00             	cmpb   $0x0,(%edx)
f010157e:	74 09                	je     f0101589 <strlen+0x19>
		n++;
f0101580:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101583:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101587:	75 f7                	jne    f0101580 <strlen+0x10>
		n++;
	return n;
}
f0101589:	5d                   	pop    %ebp
f010158a:	c3                   	ret    

f010158b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010158b:	55                   	push   %ebp
f010158c:	89 e5                	mov    %esp,%ebp
f010158e:	53                   	push   %ebx
f010158f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101592:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101595:	b8 00 00 00 00       	mov    $0x0,%eax
f010159a:	85 c9                	test   %ecx,%ecx
f010159c:	74 1a                	je     f01015b8 <strnlen+0x2d>
f010159e:	80 3b 00             	cmpb   $0x0,(%ebx)
f01015a1:	74 15                	je     f01015b8 <strnlen+0x2d>
f01015a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01015a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015aa:	39 ca                	cmp    %ecx,%edx
f01015ac:	74 0a                	je     f01015b8 <strnlen+0x2d>
f01015ae:	83 c2 01             	add    $0x1,%edx
f01015b1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01015b6:	75 f0                	jne    f01015a8 <strnlen+0x1d>
		n++;
	return n;
}
f01015b8:	5b                   	pop    %ebx
f01015b9:	5d                   	pop    %ebp
f01015ba:	c3                   	ret    

f01015bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015bb:	55                   	push   %ebp
f01015bc:	89 e5                	mov    %esp,%ebp
f01015be:	53                   	push   %ebx
f01015bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015c5:	ba 00 00 00 00       	mov    $0x0,%edx
f01015ca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01015ce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01015d1:	83 c2 01             	add    $0x1,%edx
f01015d4:	84 c9                	test   %cl,%cl
f01015d6:	75 f2                	jne    f01015ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015d8:	5b                   	pop    %ebx
f01015d9:	5d                   	pop    %ebp
f01015da:	c3                   	ret    

f01015db <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015db:	55                   	push   %ebp
f01015dc:	89 e5                	mov    %esp,%ebp
f01015de:	53                   	push   %ebx
f01015df:	83 ec 08             	sub    $0x8,%esp
f01015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015e5:	89 1c 24             	mov    %ebx,(%esp)
f01015e8:	e8 83 ff ff ff       	call   f0101570 <strlen>
	strcpy(dst + len, src);
f01015ed:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015f0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01015f4:	01 d8                	add    %ebx,%eax
f01015f6:	89 04 24             	mov    %eax,(%esp)
f01015f9:	e8 bd ff ff ff       	call   f01015bb <strcpy>
	return dst;
}
f01015fe:	89 d8                	mov    %ebx,%eax
f0101600:	83 c4 08             	add    $0x8,%esp
f0101603:	5b                   	pop    %ebx
f0101604:	5d                   	pop    %ebp
f0101605:	c3                   	ret    

f0101606 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101606:	55                   	push   %ebp
f0101607:	89 e5                	mov    %esp,%ebp
f0101609:	56                   	push   %esi
f010160a:	53                   	push   %ebx
f010160b:	8b 45 08             	mov    0x8(%ebp),%eax
f010160e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101611:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101614:	85 f6                	test   %esi,%esi
f0101616:	74 18                	je     f0101630 <strncpy+0x2a>
f0101618:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010161d:	0f b6 1a             	movzbl (%edx),%ebx
f0101620:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101623:	80 3a 01             	cmpb   $0x1,(%edx)
f0101626:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101629:	83 c1 01             	add    $0x1,%ecx
f010162c:	39 f1                	cmp    %esi,%ecx
f010162e:	75 ed                	jne    f010161d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101630:	5b                   	pop    %ebx
f0101631:	5e                   	pop    %esi
f0101632:	5d                   	pop    %ebp
f0101633:	c3                   	ret    

f0101634 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101634:	55                   	push   %ebp
f0101635:	89 e5                	mov    %esp,%ebp
f0101637:	57                   	push   %edi
f0101638:	56                   	push   %esi
f0101639:	53                   	push   %ebx
f010163a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101640:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101643:	89 f8                	mov    %edi,%eax
f0101645:	85 f6                	test   %esi,%esi
f0101647:	74 2b                	je     f0101674 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0101649:	83 fe 01             	cmp    $0x1,%esi
f010164c:	74 23                	je     f0101671 <strlcpy+0x3d>
f010164e:	0f b6 0b             	movzbl (%ebx),%ecx
f0101651:	84 c9                	test   %cl,%cl
f0101653:	74 1c                	je     f0101671 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0101655:	83 ee 02             	sub    $0x2,%esi
f0101658:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010165d:	88 08                	mov    %cl,(%eax)
f010165f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101662:	39 f2                	cmp    %esi,%edx
f0101664:	74 0b                	je     f0101671 <strlcpy+0x3d>
f0101666:	83 c2 01             	add    $0x1,%edx
f0101669:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010166d:	84 c9                	test   %cl,%cl
f010166f:	75 ec                	jne    f010165d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0101671:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101674:	29 f8                	sub    %edi,%eax
}
f0101676:	5b                   	pop    %ebx
f0101677:	5e                   	pop    %esi
f0101678:	5f                   	pop    %edi
f0101679:	5d                   	pop    %ebp
f010167a:	c3                   	ret    

f010167b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010167b:	55                   	push   %ebp
f010167c:	89 e5                	mov    %esp,%ebp
f010167e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101681:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101684:	0f b6 01             	movzbl (%ecx),%eax
f0101687:	84 c0                	test   %al,%al
f0101689:	74 16                	je     f01016a1 <strcmp+0x26>
f010168b:	3a 02                	cmp    (%edx),%al
f010168d:	75 12                	jne    f01016a1 <strcmp+0x26>
		p++, q++;
f010168f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101692:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0101696:	84 c0                	test   %al,%al
f0101698:	74 07                	je     f01016a1 <strcmp+0x26>
f010169a:	83 c1 01             	add    $0x1,%ecx
f010169d:	3a 02                	cmp    (%edx),%al
f010169f:	74 ee                	je     f010168f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016a1:	0f b6 c0             	movzbl %al,%eax
f01016a4:	0f b6 12             	movzbl (%edx),%edx
f01016a7:	29 d0                	sub    %edx,%eax
}
f01016a9:	5d                   	pop    %ebp
f01016aa:	c3                   	ret    

f01016ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016ab:	55                   	push   %ebp
f01016ac:	89 e5                	mov    %esp,%ebp
f01016ae:	53                   	push   %ebx
f01016af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01016b8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01016bd:	85 d2                	test   %edx,%edx
f01016bf:	74 28                	je     f01016e9 <strncmp+0x3e>
f01016c1:	0f b6 01             	movzbl (%ecx),%eax
f01016c4:	84 c0                	test   %al,%al
f01016c6:	74 24                	je     f01016ec <strncmp+0x41>
f01016c8:	3a 03                	cmp    (%ebx),%al
f01016ca:	75 20                	jne    f01016ec <strncmp+0x41>
f01016cc:	83 ea 01             	sub    $0x1,%edx
f01016cf:	74 13                	je     f01016e4 <strncmp+0x39>
		n--, p++, q++;
f01016d1:	83 c1 01             	add    $0x1,%ecx
f01016d4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01016d7:	0f b6 01             	movzbl (%ecx),%eax
f01016da:	84 c0                	test   %al,%al
f01016dc:	74 0e                	je     f01016ec <strncmp+0x41>
f01016de:	3a 03                	cmp    (%ebx),%al
f01016e0:	74 ea                	je     f01016cc <strncmp+0x21>
f01016e2:	eb 08                	jmp    f01016ec <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01016e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01016e9:	5b                   	pop    %ebx
f01016ea:	5d                   	pop    %ebp
f01016eb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016ec:	0f b6 01             	movzbl (%ecx),%eax
f01016ef:	0f b6 13             	movzbl (%ebx),%edx
f01016f2:	29 d0                	sub    %edx,%eax
f01016f4:	eb f3                	jmp    f01016e9 <strncmp+0x3e>

f01016f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016f6:	55                   	push   %ebp
f01016f7:	89 e5                	mov    %esp,%ebp
f01016f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01016fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101700:	0f b6 10             	movzbl (%eax),%edx
f0101703:	84 d2                	test   %dl,%dl
f0101705:	74 1c                	je     f0101723 <strchr+0x2d>
		if (*s == c)
f0101707:	38 ca                	cmp    %cl,%dl
f0101709:	75 09                	jne    f0101714 <strchr+0x1e>
f010170b:	eb 1b                	jmp    f0101728 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010170d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0101710:	38 ca                	cmp    %cl,%dl
f0101712:	74 14                	je     f0101728 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101714:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0101718:	84 d2                	test   %dl,%dl
f010171a:	75 f1                	jne    f010170d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f010171c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101721:	eb 05                	jmp    f0101728 <strchr+0x32>
f0101723:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101728:	5d                   	pop    %ebp
f0101729:	c3                   	ret    

f010172a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010172a:	55                   	push   %ebp
f010172b:	89 e5                	mov    %esp,%ebp
f010172d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101730:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101734:	0f b6 10             	movzbl (%eax),%edx
f0101737:	84 d2                	test   %dl,%dl
f0101739:	74 14                	je     f010174f <strfind+0x25>
		if (*s == c)
f010173b:	38 ca                	cmp    %cl,%dl
f010173d:	75 06                	jne    f0101745 <strfind+0x1b>
f010173f:	eb 0e                	jmp    f010174f <strfind+0x25>
f0101741:	38 ca                	cmp    %cl,%dl
f0101743:	74 0a                	je     f010174f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101745:	83 c0 01             	add    $0x1,%eax
f0101748:	0f b6 10             	movzbl (%eax),%edx
f010174b:	84 d2                	test   %dl,%dl
f010174d:	75 f2                	jne    f0101741 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f010174f:	5d                   	pop    %ebp
f0101750:	c3                   	ret    

f0101751 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101751:	55                   	push   %ebp
f0101752:	89 e5                	mov    %esp,%ebp
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010175a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010175d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101760:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101763:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101766:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101769:	85 c9                	test   %ecx,%ecx
f010176b:	74 30                	je     f010179d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010176d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101773:	75 25                	jne    f010179a <memset+0x49>
f0101775:	f6 c1 03             	test   $0x3,%cl
f0101778:	75 20                	jne    f010179a <memset+0x49>
		c &= 0xFF;
f010177a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010177d:	89 d3                	mov    %edx,%ebx
f010177f:	c1 e3 08             	shl    $0x8,%ebx
f0101782:	89 d6                	mov    %edx,%esi
f0101784:	c1 e6 18             	shl    $0x18,%esi
f0101787:	89 d0                	mov    %edx,%eax
f0101789:	c1 e0 10             	shl    $0x10,%eax
f010178c:	09 f0                	or     %esi,%eax
f010178e:	09 d0                	or     %edx,%eax
f0101790:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101792:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101795:	fc                   	cld    
f0101796:	f3 ab                	rep stos %eax,%es:(%edi)
f0101798:	eb 03                	jmp    f010179d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010179a:	fc                   	cld    
f010179b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010179d:	89 f8                	mov    %edi,%eax
f010179f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01017a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01017a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01017a8:	89 ec                	mov    %ebp,%esp
f01017aa:	5d                   	pop    %ebp
f01017ab:	c3                   	ret    

f01017ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017ac:	55                   	push   %ebp
f01017ad:	89 e5                	mov    %esp,%ebp
f01017af:	83 ec 08             	sub    $0x8,%esp
f01017b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01017b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01017b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01017bb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017c1:	39 c6                	cmp    %eax,%esi
f01017c3:	73 36                	jae    f01017fb <memmove+0x4f>
f01017c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017c8:	39 d0                	cmp    %edx,%eax
f01017ca:	73 2f                	jae    f01017fb <memmove+0x4f>
		s += n;
		d += n;
f01017cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017cf:	f6 c2 03             	test   $0x3,%dl
f01017d2:	75 1b                	jne    f01017ef <memmove+0x43>
f01017d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01017da:	75 13                	jne    f01017ef <memmove+0x43>
f01017dc:	f6 c1 03             	test   $0x3,%cl
f01017df:	75 0e                	jne    f01017ef <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017e1:	83 ef 04             	sub    $0x4,%edi
f01017e4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01017ea:	fd                   	std    
f01017eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017ed:	eb 09                	jmp    f01017f8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017ef:	83 ef 01             	sub    $0x1,%edi
f01017f2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01017f5:	fd                   	std    
f01017f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017f8:	fc                   	cld    
f01017f9:	eb 20                	jmp    f010181b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101801:	75 13                	jne    f0101816 <memmove+0x6a>
f0101803:	a8 03                	test   $0x3,%al
f0101805:	75 0f                	jne    f0101816 <memmove+0x6a>
f0101807:	f6 c1 03             	test   $0x3,%cl
f010180a:	75 0a                	jne    f0101816 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010180c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010180f:	89 c7                	mov    %eax,%edi
f0101811:	fc                   	cld    
f0101812:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101814:	eb 05                	jmp    f010181b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101816:	89 c7                	mov    %eax,%edi
f0101818:	fc                   	cld    
f0101819:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010181b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010181e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101821:	89 ec                	mov    %ebp,%esp
f0101823:	5d                   	pop    %ebp
f0101824:	c3                   	ret    

f0101825 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101825:	55                   	push   %ebp
f0101826:	89 e5                	mov    %esp,%ebp
f0101828:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010182b:	8b 45 10             	mov    0x10(%ebp),%eax
f010182e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101832:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101835:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101839:	8b 45 08             	mov    0x8(%ebp),%eax
f010183c:	89 04 24             	mov    %eax,(%esp)
f010183f:	e8 68 ff ff ff       	call   f01017ac <memmove>
}
f0101844:	c9                   	leave  
f0101845:	c3                   	ret    

f0101846 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101846:	55                   	push   %ebp
f0101847:	89 e5                	mov    %esp,%ebp
f0101849:	57                   	push   %edi
f010184a:	56                   	push   %esi
f010184b:	53                   	push   %ebx
f010184c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010184f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101852:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101855:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010185a:	85 ff                	test   %edi,%edi
f010185c:	74 37                	je     f0101895 <memcmp+0x4f>
		if (*s1 != *s2)
f010185e:	0f b6 03             	movzbl (%ebx),%eax
f0101861:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101864:	83 ef 01             	sub    $0x1,%edi
f0101867:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f010186c:	38 c8                	cmp    %cl,%al
f010186e:	74 1c                	je     f010188c <memcmp+0x46>
f0101870:	eb 10                	jmp    f0101882 <memcmp+0x3c>
f0101872:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0101877:	83 c2 01             	add    $0x1,%edx
f010187a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010187e:	38 c8                	cmp    %cl,%al
f0101880:	74 0a                	je     f010188c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0101882:	0f b6 c0             	movzbl %al,%eax
f0101885:	0f b6 c9             	movzbl %cl,%ecx
f0101888:	29 c8                	sub    %ecx,%eax
f010188a:	eb 09                	jmp    f0101895 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010188c:	39 fa                	cmp    %edi,%edx
f010188e:	75 e2                	jne    f0101872 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101890:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101895:	5b                   	pop    %ebx
f0101896:	5e                   	pop    %esi
f0101897:	5f                   	pop    %edi
f0101898:	5d                   	pop    %ebp
f0101899:	c3                   	ret    

f010189a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010189a:	55                   	push   %ebp
f010189b:	89 e5                	mov    %esp,%ebp
f010189d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01018a0:	89 c2                	mov    %eax,%edx
f01018a2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01018a5:	39 d0                	cmp    %edx,%eax
f01018a7:	73 19                	jae    f01018c2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f01018a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01018ad:	38 08                	cmp    %cl,(%eax)
f01018af:	75 06                	jne    f01018b7 <memfind+0x1d>
f01018b1:	eb 0f                	jmp    f01018c2 <memfind+0x28>
f01018b3:	38 08                	cmp    %cl,(%eax)
f01018b5:	74 0b                	je     f01018c2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01018b7:	83 c0 01             	add    $0x1,%eax
f01018ba:	39 d0                	cmp    %edx,%eax
f01018bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018c0:	75 f1                	jne    f01018b3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01018c2:	5d                   	pop    %ebp
f01018c3:	c3                   	ret    

f01018c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01018c4:	55                   	push   %ebp
f01018c5:	89 e5                	mov    %esp,%ebp
f01018c7:	57                   	push   %edi
f01018c8:	56                   	push   %esi
f01018c9:	53                   	push   %ebx
f01018ca:	8b 55 08             	mov    0x8(%ebp),%edx
f01018cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01018d0:	0f b6 02             	movzbl (%edx),%eax
f01018d3:	3c 20                	cmp    $0x20,%al
f01018d5:	74 04                	je     f01018db <strtol+0x17>
f01018d7:	3c 09                	cmp    $0x9,%al
f01018d9:	75 0e                	jne    f01018e9 <strtol+0x25>
		s++;
f01018db:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01018de:	0f b6 02             	movzbl (%edx),%eax
f01018e1:	3c 20                	cmp    $0x20,%al
f01018e3:	74 f6                	je     f01018db <strtol+0x17>
f01018e5:	3c 09                	cmp    $0x9,%al
f01018e7:	74 f2                	je     f01018db <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01018e9:	3c 2b                	cmp    $0x2b,%al
f01018eb:	75 0a                	jne    f01018f7 <strtol+0x33>
		s++;
f01018ed:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01018f0:	bf 00 00 00 00       	mov    $0x0,%edi
f01018f5:	eb 10                	jmp    f0101907 <strtol+0x43>
f01018f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01018fc:	3c 2d                	cmp    $0x2d,%al
f01018fe:	75 07                	jne    f0101907 <strtol+0x43>
		s++, neg = 1;
f0101900:	83 c2 01             	add    $0x1,%edx
f0101903:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101907:	85 db                	test   %ebx,%ebx
f0101909:	0f 94 c0             	sete   %al
f010190c:	74 05                	je     f0101913 <strtol+0x4f>
f010190e:	83 fb 10             	cmp    $0x10,%ebx
f0101911:	75 15                	jne    f0101928 <strtol+0x64>
f0101913:	80 3a 30             	cmpb   $0x30,(%edx)
f0101916:	75 10                	jne    f0101928 <strtol+0x64>
f0101918:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010191c:	75 0a                	jne    f0101928 <strtol+0x64>
		s += 2, base = 16;
f010191e:	83 c2 02             	add    $0x2,%edx
f0101921:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101926:	eb 13                	jmp    f010193b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101928:	84 c0                	test   %al,%al
f010192a:	74 0f                	je     f010193b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010192c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101931:	80 3a 30             	cmpb   $0x30,(%edx)
f0101934:	75 05                	jne    f010193b <strtol+0x77>
		s++, base = 8;
f0101936:	83 c2 01             	add    $0x1,%edx
f0101939:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010193b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101940:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101942:	0f b6 0a             	movzbl (%edx),%ecx
f0101945:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101948:	80 fb 09             	cmp    $0x9,%bl
f010194b:	77 08                	ja     f0101955 <strtol+0x91>
			dig = *s - '0';
f010194d:	0f be c9             	movsbl %cl,%ecx
f0101950:	83 e9 30             	sub    $0x30,%ecx
f0101953:	eb 1e                	jmp    f0101973 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0101955:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101958:	80 fb 19             	cmp    $0x19,%bl
f010195b:	77 08                	ja     f0101965 <strtol+0xa1>
			dig = *s - 'a' + 10;
f010195d:	0f be c9             	movsbl %cl,%ecx
f0101960:	83 e9 57             	sub    $0x57,%ecx
f0101963:	eb 0e                	jmp    f0101973 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0101965:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0101968:	80 fb 19             	cmp    $0x19,%bl
f010196b:	77 14                	ja     f0101981 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010196d:	0f be c9             	movsbl %cl,%ecx
f0101970:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101973:	39 f1                	cmp    %esi,%ecx
f0101975:	7d 0e                	jge    f0101985 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101977:	83 c2 01             	add    $0x1,%edx
f010197a:	0f af c6             	imul   %esi,%eax
f010197d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010197f:	eb c1                	jmp    f0101942 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0101981:	89 c1                	mov    %eax,%ecx
f0101983:	eb 02                	jmp    f0101987 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101985:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101987:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010198b:	74 05                	je     f0101992 <strtol+0xce>
		*endptr = (char *) s;
f010198d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101990:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101992:	89 ca                	mov    %ecx,%edx
f0101994:	f7 da                	neg    %edx
f0101996:	85 ff                	test   %edi,%edi
f0101998:	0f 45 c2             	cmovne %edx,%eax
}
f010199b:	5b                   	pop    %ebx
f010199c:	5e                   	pop    %esi
f010199d:	5f                   	pop    %edi
f010199e:	5d                   	pop    %ebp
f010199f:	c3                   	ret    

f01019a0 <__udivdi3>:
f01019a0:	83 ec 1c             	sub    $0x1c,%esp
f01019a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01019a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f01019ab:	8b 44 24 20          	mov    0x20(%esp),%eax
f01019af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01019b3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01019b7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01019bb:	85 ff                	test   %edi,%edi
f01019bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01019c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019c5:	89 cd                	mov    %ecx,%ebp
f01019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019cb:	75 33                	jne    f0101a00 <__udivdi3+0x60>
f01019cd:	39 f1                	cmp    %esi,%ecx
f01019cf:	77 57                	ja     f0101a28 <__udivdi3+0x88>
f01019d1:	85 c9                	test   %ecx,%ecx
f01019d3:	75 0b                	jne    f01019e0 <__udivdi3+0x40>
f01019d5:	b8 01 00 00 00       	mov    $0x1,%eax
f01019da:	31 d2                	xor    %edx,%edx
f01019dc:	f7 f1                	div    %ecx
f01019de:	89 c1                	mov    %eax,%ecx
f01019e0:	89 f0                	mov    %esi,%eax
f01019e2:	31 d2                	xor    %edx,%edx
f01019e4:	f7 f1                	div    %ecx
f01019e6:	89 c6                	mov    %eax,%esi
f01019e8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01019ec:	f7 f1                	div    %ecx
f01019ee:	89 f2                	mov    %esi,%edx
f01019f0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01019f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01019f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01019fc:	83 c4 1c             	add    $0x1c,%esp
f01019ff:	c3                   	ret    
f0101a00:	31 d2                	xor    %edx,%edx
f0101a02:	31 c0                	xor    %eax,%eax
f0101a04:	39 f7                	cmp    %esi,%edi
f0101a06:	77 e8                	ja     f01019f0 <__udivdi3+0x50>
f0101a08:	0f bd cf             	bsr    %edi,%ecx
f0101a0b:	83 f1 1f             	xor    $0x1f,%ecx
f0101a0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a12:	75 2c                	jne    f0101a40 <__udivdi3+0xa0>
f0101a14:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0101a18:	76 04                	jbe    f0101a1e <__udivdi3+0x7e>
f0101a1a:	39 f7                	cmp    %esi,%edi
f0101a1c:	73 d2                	jae    f01019f0 <__udivdi3+0x50>
f0101a1e:	31 d2                	xor    %edx,%edx
f0101a20:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a25:	eb c9                	jmp    f01019f0 <__udivdi3+0x50>
f0101a27:	90                   	nop
f0101a28:	89 f2                	mov    %esi,%edx
f0101a2a:	f7 f1                	div    %ecx
f0101a2c:	31 d2                	xor    %edx,%edx
f0101a2e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101a32:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101a36:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101a3a:	83 c4 1c             	add    $0x1c,%esp
f0101a3d:	c3                   	ret    
f0101a3e:	66 90                	xchg   %ax,%ax
f0101a40:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a45:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a4a:	89 ea                	mov    %ebp,%edx
f0101a4c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101a50:	d3 e7                	shl    %cl,%edi
f0101a52:	89 c1                	mov    %eax,%ecx
f0101a54:	d3 ea                	shr    %cl,%edx
f0101a56:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a5b:	09 fa                	or     %edi,%edx
f0101a5d:	89 f7                	mov    %esi,%edi
f0101a5f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a63:	89 f2                	mov    %esi,%edx
f0101a65:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101a69:	d3 e5                	shl    %cl,%ebp
f0101a6b:	89 c1                	mov    %eax,%ecx
f0101a6d:	d3 ef                	shr    %cl,%edi
f0101a6f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a74:	d3 e2                	shl    %cl,%edx
f0101a76:	89 c1                	mov    %eax,%ecx
f0101a78:	d3 ee                	shr    %cl,%esi
f0101a7a:	09 d6                	or     %edx,%esi
f0101a7c:	89 fa                	mov    %edi,%edx
f0101a7e:	89 f0                	mov    %esi,%eax
f0101a80:	f7 74 24 0c          	divl   0xc(%esp)
f0101a84:	89 d7                	mov    %edx,%edi
f0101a86:	89 c6                	mov    %eax,%esi
f0101a88:	f7 e5                	mul    %ebp
f0101a8a:	39 d7                	cmp    %edx,%edi
f0101a8c:	72 22                	jb     f0101ab0 <__udivdi3+0x110>
f0101a8e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0101a92:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a97:	d3 e5                	shl    %cl,%ebp
f0101a99:	39 c5                	cmp    %eax,%ebp
f0101a9b:	73 04                	jae    f0101aa1 <__udivdi3+0x101>
f0101a9d:	39 d7                	cmp    %edx,%edi
f0101a9f:	74 0f                	je     f0101ab0 <__udivdi3+0x110>
f0101aa1:	89 f0                	mov    %esi,%eax
f0101aa3:	31 d2                	xor    %edx,%edx
f0101aa5:	e9 46 ff ff ff       	jmp    f01019f0 <__udivdi3+0x50>
f0101aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ab0:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101ab3:	31 d2                	xor    %edx,%edx
f0101ab5:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101ab9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101abd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101ac1:	83 c4 1c             	add    $0x1c,%esp
f0101ac4:	c3                   	ret    
	...

f0101ad0 <__umoddi3>:
f0101ad0:	83 ec 1c             	sub    $0x1c,%esp
f0101ad3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101ad7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0101adb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0101adf:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101ae3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101ae7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0101aeb:	85 ed                	test   %ebp,%ebp
f0101aed:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101af1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101af5:	89 cf                	mov    %ecx,%edi
f0101af7:	89 04 24             	mov    %eax,(%esp)
f0101afa:	89 f2                	mov    %esi,%edx
f0101afc:	75 1a                	jne    f0101b18 <__umoddi3+0x48>
f0101afe:	39 f1                	cmp    %esi,%ecx
f0101b00:	76 4e                	jbe    f0101b50 <__umoddi3+0x80>
f0101b02:	f7 f1                	div    %ecx
f0101b04:	89 d0                	mov    %edx,%eax
f0101b06:	31 d2                	xor    %edx,%edx
f0101b08:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101b0c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101b10:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101b14:	83 c4 1c             	add    $0x1c,%esp
f0101b17:	c3                   	ret    
f0101b18:	39 f5                	cmp    %esi,%ebp
f0101b1a:	77 54                	ja     f0101b70 <__umoddi3+0xa0>
f0101b1c:	0f bd c5             	bsr    %ebp,%eax
f0101b1f:	83 f0 1f             	xor    $0x1f,%eax
f0101b22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b26:	75 60                	jne    f0101b88 <__umoddi3+0xb8>
f0101b28:	3b 0c 24             	cmp    (%esp),%ecx
f0101b2b:	0f 87 07 01 00 00    	ja     f0101c38 <__umoddi3+0x168>
f0101b31:	89 f2                	mov    %esi,%edx
f0101b33:	8b 34 24             	mov    (%esp),%esi
f0101b36:	29 ce                	sub    %ecx,%esi
f0101b38:	19 ea                	sbb    %ebp,%edx
f0101b3a:	89 34 24             	mov    %esi,(%esp)
f0101b3d:	8b 04 24             	mov    (%esp),%eax
f0101b40:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101b44:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101b48:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101b4c:	83 c4 1c             	add    $0x1c,%esp
f0101b4f:	c3                   	ret    
f0101b50:	85 c9                	test   %ecx,%ecx
f0101b52:	75 0b                	jne    f0101b5f <__umoddi3+0x8f>
f0101b54:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b59:	31 d2                	xor    %edx,%edx
f0101b5b:	f7 f1                	div    %ecx
f0101b5d:	89 c1                	mov    %eax,%ecx
f0101b5f:	89 f0                	mov    %esi,%eax
f0101b61:	31 d2                	xor    %edx,%edx
f0101b63:	f7 f1                	div    %ecx
f0101b65:	8b 04 24             	mov    (%esp),%eax
f0101b68:	f7 f1                	div    %ecx
f0101b6a:	eb 98                	jmp    f0101b04 <__umoddi3+0x34>
f0101b6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b70:	89 f2                	mov    %esi,%edx
f0101b72:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101b76:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101b7a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101b7e:	83 c4 1c             	add    $0x1c,%esp
f0101b81:	c3                   	ret    
f0101b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b88:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b8d:	89 e8                	mov    %ebp,%eax
f0101b8f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0101b94:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0101b98:	89 fa                	mov    %edi,%edx
f0101b9a:	d3 e0                	shl    %cl,%eax
f0101b9c:	89 e9                	mov    %ebp,%ecx
f0101b9e:	d3 ea                	shr    %cl,%edx
f0101ba0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ba5:	09 c2                	or     %eax,%edx
f0101ba7:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101bab:	89 14 24             	mov    %edx,(%esp)
f0101bae:	89 f2                	mov    %esi,%edx
f0101bb0:	d3 e7                	shl    %cl,%edi
f0101bb2:	89 e9                	mov    %ebp,%ecx
f0101bb4:	d3 ea                	shr    %cl,%edx
f0101bb6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101bbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101bbf:	d3 e6                	shl    %cl,%esi
f0101bc1:	89 e9                	mov    %ebp,%ecx
f0101bc3:	d3 e8                	shr    %cl,%eax
f0101bc5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101bca:	09 f0                	or     %esi,%eax
f0101bcc:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101bd0:	f7 34 24             	divl   (%esp)
f0101bd3:	d3 e6                	shl    %cl,%esi
f0101bd5:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101bd9:	89 d6                	mov    %edx,%esi
f0101bdb:	f7 e7                	mul    %edi
f0101bdd:	39 d6                	cmp    %edx,%esi
f0101bdf:	89 c1                	mov    %eax,%ecx
f0101be1:	89 d7                	mov    %edx,%edi
f0101be3:	72 3f                	jb     f0101c24 <__umoddi3+0x154>
f0101be5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101be9:	72 35                	jb     f0101c20 <__umoddi3+0x150>
f0101beb:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101bef:	29 c8                	sub    %ecx,%eax
f0101bf1:	19 fe                	sbb    %edi,%esi
f0101bf3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101bf8:	89 f2                	mov    %esi,%edx
f0101bfa:	d3 e8                	shr    %cl,%eax
f0101bfc:	89 e9                	mov    %ebp,%ecx
f0101bfe:	d3 e2                	shl    %cl,%edx
f0101c00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101c05:	09 d0                	or     %edx,%eax
f0101c07:	89 f2                	mov    %esi,%edx
f0101c09:	d3 ea                	shr    %cl,%edx
f0101c0b:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101c0f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101c13:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101c17:	83 c4 1c             	add    $0x1c,%esp
f0101c1a:	c3                   	ret    
f0101c1b:	90                   	nop
f0101c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c20:	39 d6                	cmp    %edx,%esi
f0101c22:	75 c7                	jne    f0101beb <__umoddi3+0x11b>
f0101c24:	89 d7                	mov    %edx,%edi
f0101c26:	89 c1                	mov    %eax,%ecx
f0101c28:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0101c2c:	1b 3c 24             	sbb    (%esp),%edi
f0101c2f:	eb ba                	jmp    f0101beb <__umoddi3+0x11b>
f0101c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c38:	39 f5                	cmp    %esi,%ebp
f0101c3a:	0f 82 f1 fe ff ff    	jb     f0101b31 <__umoddi3+0x61>
f0101c40:	e9 f8 fe ff ff       	jmp    f0101b3d <__umoddi3+0x6d>
