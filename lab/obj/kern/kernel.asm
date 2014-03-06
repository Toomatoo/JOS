
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
f010004e:	c7 04 24 c0 19 10 f0 	movl   $0xf01019c0,(%esp)
f0100055:	e8 cc 08 00 00       	call   f0100926 <cprintf>
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
f0100082:	e8 08 07 00 00       	call   f010078f <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 dc 19 10 f0 	movl   $0xf01019dc,(%esp)
f0100092:	e8 8f 08 00 00       	call   f0100926 <cprintf>
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
f01000a3:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f01000a8:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f01000c0:	e8 ec 13 00 00       	call   f01014b1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 92 04 00 00       	call   f010055c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 f7 19 10 f0 	movl   $0xf01019f7,(%esp)
f01000d9:	e8 48 08 00 00       	call   f0100926 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 a3 06 00 00       	call   f0100799 <monitor>
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
f0100103:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

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
f0100125:	c7 04 24 12 1a 10 f0 	movl   $0xf0101a12,(%esp)
f010012c:	e8 f5 07 00 00       	call   f0100926 <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 b6 07 00 00       	call   f01008f3 <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 4e 1a 10 f0 	movl   $0xf0101a4e,(%esp)
f0100144:	e8 dd 07 00 00       	call   f0100926 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 44 06 00 00       	call   f0100799 <monitor>
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
f010016f:	c7 04 24 2a 1a 10 f0 	movl   $0xf0101a2a,(%esp)
f0100176:	e8 ab 07 00 00       	call   f0100926 <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 69 07 00 00       	call   f01008f3 <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 4e 1a 10 f0 	movl   $0xf0101a4e,(%esp)
f0100191:	e8 90 07 00 00       	call   f0100926 <cprintf>
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
f01001d9:	8b 15 24 25 11 f0    	mov    0xf0112524,%edx
f01001df:	88 82 20 23 11 f0    	mov    %al,-0xfeedce0(%edx)
f01001e5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001e8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001ed:	ba 00 00 00 00       	mov    $0x0,%edx
f01001f2:	0f 44 c2             	cmove  %edx,%eax
f01001f5:	a3 24 25 11 f0       	mov    %eax,0xf0112524
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
f0100210:	89 c7                	mov    %eax,%edi
f0100212:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100217:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100218:	a8 20                	test   $0x20,%al
f010021a:	75 1b                	jne    f0100237 <cons_putc+0x30>
f010021c:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100221:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100226:	e8 75 ff ff ff       	call   f01001a0 <delay>
f010022b:	89 f2                	mov    %esi,%edx
f010022d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010022e:	a8 20                	test   $0x20,%al
f0100230:	75 05                	jne    f0100237 <cons_putc+0x30>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100232:	83 eb 01             	sub    $0x1,%ebx
f0100235:	75 ef                	jne    f0100226 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100237:	89 fa                	mov    %edi,%edx
f0100239:	89 f8                	mov    %edi,%eax
f010023b:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010023e:	ba f8 03 00 00       	mov    $0x3f8,%edx
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
f010026b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010026f:	ee                   	out    %al,(%dx)
f0100270:	b2 7a                	mov    $0x7a,%dl
f0100272:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100277:	ee                   	out    %al,(%dx)
f0100278:	b8 08 00 00 00       	mov    $0x8,%eax
f010027d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010027e:	89 fa                	mov    %edi,%edx
f0100280:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100286:	89 f8                	mov    %edi,%eax
f0100288:	80 cc 07             	or     $0x7,%ah
f010028b:	85 d2                	test   %edx,%edx
f010028d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100290:	89 f8                	mov    %edi,%eax
f0100292:	25 ff 00 00 00       	and    $0xff,%eax
f0100297:	83 f8 09             	cmp    $0x9,%eax
f010029a:	74 7c                	je     f0100318 <cons_putc+0x111>
f010029c:	83 f8 09             	cmp    $0x9,%eax
f010029f:	7f 0b                	jg     f01002ac <cons_putc+0xa5>
f01002a1:	83 f8 08             	cmp    $0x8,%eax
f01002a4:	0f 85 a2 00 00 00    	jne    f010034c <cons_putc+0x145>
f01002aa:	eb 16                	jmp    f01002c2 <cons_putc+0xbb>
f01002ac:	83 f8 0a             	cmp    $0xa,%eax
f01002af:	90                   	nop
f01002b0:	74 40                	je     f01002f2 <cons_putc+0xeb>
f01002b2:	83 f8 0d             	cmp    $0xd,%eax
f01002b5:	0f 85 91 00 00 00    	jne    f010034c <cons_putc+0x145>
f01002bb:	90                   	nop
f01002bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01002c0:	eb 38                	jmp    f01002fa <cons_putc+0xf3>
	case '\b':
		if (crt_pos > 0) {
f01002c2:	0f b7 05 34 25 11 f0 	movzwl 0xf0112534,%eax
f01002c9:	66 85 c0             	test   %ax,%ax
f01002cc:	0f 84 e4 00 00 00    	je     f01003b6 <cons_putc+0x1af>
			crt_pos--;
f01002d2:	83 e8 01             	sub    $0x1,%eax
f01002d5:	66 a3 34 25 11 f0    	mov    %ax,0xf0112534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002db:	0f b7 c0             	movzwl %ax,%eax
f01002de:	66 81 e7 00 ff       	and    $0xff00,%di
f01002e3:	83 cf 20             	or     $0x20,%edi
f01002e6:	8b 15 30 25 11 f0    	mov    0xf0112530,%edx
f01002ec:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01002f0:	eb 77                	jmp    f0100369 <cons_putc+0x162>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002f2:	66 83 05 34 25 11 f0 	addw   $0x50,0xf0112534
f01002f9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002fa:	0f b7 05 34 25 11 f0 	movzwl 0xf0112534,%eax
f0100301:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100307:	c1 e8 16             	shr    $0x16,%eax
f010030a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010030d:	c1 e0 04             	shl    $0x4,%eax
f0100310:	66 a3 34 25 11 f0    	mov    %ax,0xf0112534
f0100316:	eb 51                	jmp    f0100369 <cons_putc+0x162>
		break;
	case '\t':
		cons_putc(' ');
f0100318:	b8 20 00 00 00       	mov    $0x20,%eax
f010031d:	e8 e5 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100322:	b8 20 00 00 00       	mov    $0x20,%eax
f0100327:	e8 db fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010032c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100331:	e8 d1 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100336:	b8 20 00 00 00       	mov    $0x20,%eax
f010033b:	e8 c7 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100340:	b8 20 00 00 00       	mov    $0x20,%eax
f0100345:	e8 bd fe ff ff       	call   f0100207 <cons_putc>
f010034a:	eb 1d                	jmp    f0100369 <cons_putc+0x162>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010034c:	0f b7 05 34 25 11 f0 	movzwl 0xf0112534,%eax
f0100353:	0f b7 c8             	movzwl %ax,%ecx
f0100356:	8b 15 30 25 11 f0    	mov    0xf0112530,%edx
f010035c:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100360:	83 c0 01             	add    $0x1,%eax
f0100363:	66 a3 34 25 11 f0    	mov    %ax,0xf0112534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100369:	66 81 3d 34 25 11 f0 	cmpw   $0x7cf,0xf0112534
f0100370:	cf 07 
f0100372:	76 42                	jbe    f01003b6 <cons_putc+0x1af>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100374:	a1 30 25 11 f0       	mov    0xf0112530,%eax
f0100379:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100380:	00 
f0100381:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100387:	89 54 24 04          	mov    %edx,0x4(%esp)
f010038b:	89 04 24             	mov    %eax,(%esp)
f010038e:	e8 79 11 00 00       	call   f010150c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100393:	8b 15 30 25 11 f0    	mov    0xf0112530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100399:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010039e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003a4:	83 c0 01             	add    $0x1,%eax
f01003a7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01003ac:	75 f0                	jne    f010039e <cons_putc+0x197>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01003ae:	66 83 2d 34 25 11 f0 	subw   $0x50,0xf0112534
f01003b5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01003b6:	8b 0d 2c 25 11 f0    	mov    0xf011252c,%ecx
f01003bc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003c1:	89 ca                	mov    %ecx,%edx
f01003c3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003c4:	0f b7 35 34 25 11 f0 	movzwl 0xf0112534,%esi
f01003cb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003ce:	89 f0                	mov    %esi,%eax
f01003d0:	66 c1 e8 08          	shr    $0x8,%ax
f01003d4:	89 da                	mov    %ebx,%edx
f01003d6:	ee                   	out    %al,(%dx)
f01003d7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003dc:	89 ca                	mov    %ecx,%edx
f01003de:	ee                   	out    %al,(%dx)
f01003df:	89 f0                	mov    %esi,%eax
f01003e1:	89 da                	mov    %ebx,%edx
f01003e3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003e4:	83 c4 2c             	add    $0x2c,%esp
f01003e7:	5b                   	pop    %ebx
f01003e8:	5e                   	pop    %esi
f01003e9:	5f                   	pop    %edi
f01003ea:	5d                   	pop    %ebp
f01003eb:	c3                   	ret    

f01003ec <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003ec:	55                   	push   %ebp
f01003ed:	89 e5                	mov    %esp,%ebp
f01003ef:	53                   	push   %ebx
f01003f0:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f3:	ba 64 00 00 00       	mov    $0x64,%edx
f01003f8:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003f9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003fe:	a8 01                	test   $0x1,%al
f0100400:	0f 84 de 00 00 00    	je     f01004e4 <kbd_proc_data+0xf8>
f0100406:	b2 60                	mov    $0x60,%dl
f0100408:	ec                   	in     (%dx),%al
f0100409:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010040b:	3c e0                	cmp    $0xe0,%al
f010040d:	75 11                	jne    f0100420 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f010040f:	83 0d 28 25 11 f0 40 	orl    $0x40,0xf0112528
		return 0;
f0100416:	bb 00 00 00 00       	mov    $0x0,%ebx
f010041b:	e9 c4 00 00 00       	jmp    f01004e4 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100420:	84 c0                	test   %al,%al
f0100422:	79 37                	jns    f010045b <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100424:	8b 0d 28 25 11 f0    	mov    0xf0112528,%ecx
f010042a:	89 cb                	mov    %ecx,%ebx
f010042c:	83 e3 40             	and    $0x40,%ebx
f010042f:	83 e0 7f             	and    $0x7f,%eax
f0100432:	85 db                	test   %ebx,%ebx
f0100434:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100437:	0f b6 d2             	movzbl %dl,%edx
f010043a:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f0100441:	83 c8 40             	or     $0x40,%eax
f0100444:	0f b6 c0             	movzbl %al,%eax
f0100447:	f7 d0                	not    %eax
f0100449:	21 c1                	and    %eax,%ecx
f010044b:	89 0d 28 25 11 f0    	mov    %ecx,0xf0112528
		return 0;
f0100451:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100456:	e9 89 00 00 00       	jmp    f01004e4 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010045b:	8b 0d 28 25 11 f0    	mov    0xf0112528,%ecx
f0100461:	f6 c1 40             	test   $0x40,%cl
f0100464:	74 0e                	je     f0100474 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100466:	89 c2                	mov    %eax,%edx
f0100468:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010046b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010046e:	89 0d 28 25 11 f0    	mov    %ecx,0xf0112528
	}

	shift |= shiftcode[data];
f0100474:	0f b6 d2             	movzbl %dl,%edx
f0100477:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f010047e:	0b 05 28 25 11 f0    	or     0xf0112528,%eax
	shift ^= togglecode[data];
f0100484:	0f b6 8a 80 1b 10 f0 	movzbl -0xfefe480(%edx),%ecx
f010048b:	31 c8                	xor    %ecx,%eax
f010048d:	a3 28 25 11 f0       	mov    %eax,0xf0112528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100492:	89 c1                	mov    %eax,%ecx
f0100494:	83 e1 03             	and    $0x3,%ecx
f0100497:	8b 0c 8d 80 1c 10 f0 	mov    -0xfefe380(,%ecx,4),%ecx
f010049e:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01004a2:	a8 08                	test   $0x8,%al
f01004a4:	74 19                	je     f01004bf <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f01004a6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01004a9:	83 fa 19             	cmp    $0x19,%edx
f01004ac:	77 05                	ja     f01004b3 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f01004ae:	83 eb 20             	sub    $0x20,%ebx
f01004b1:	eb 0c                	jmp    f01004bf <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f01004b3:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f01004b6:	8d 53 20             	lea    0x20(%ebx),%edx
f01004b9:	83 f9 19             	cmp    $0x19,%ecx
f01004bc:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004bf:	f7 d0                	not    %eax
f01004c1:	a8 06                	test   $0x6,%al
f01004c3:	75 1f                	jne    f01004e4 <kbd_proc_data+0xf8>
f01004c5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004cb:	75 17                	jne    f01004e4 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f01004cd:	c7 04 24 44 1a 10 f0 	movl   $0xf0101a44,(%esp)
f01004d4:	e8 4d 04 00 00       	call   f0100926 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004d9:	ba 92 00 00 00       	mov    $0x92,%edx
f01004de:	b8 03 00 00 00       	mov    $0x3,%eax
f01004e3:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004e4:	89 d8                	mov    %ebx,%eax
f01004e6:	83 c4 14             	add    $0x14,%esp
f01004e9:	5b                   	pop    %ebx
f01004ea:	5d                   	pop    %ebp
f01004eb:	c3                   	ret    

f01004ec <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004ec:	55                   	push   %ebp
f01004ed:	89 e5                	mov    %esp,%ebp
f01004ef:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004f2:	80 3d 00 23 11 f0 00 	cmpb   $0x0,0xf0112300
f01004f9:	74 0a                	je     f0100505 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004fb:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f0100500:	e8 c5 fc ff ff       	call   f01001ca <cons_intr>
}
f0100505:	c9                   	leave  
f0100506:	c3                   	ret    

f0100507 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100507:	55                   	push   %ebp
f0100508:	89 e5                	mov    %esp,%ebp
f010050a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010050d:	b8 ec 03 10 f0       	mov    $0xf01003ec,%eax
f0100512:	e8 b3 fc ff ff       	call   f01001ca <cons_intr>
}
f0100517:	c9                   	leave  
f0100518:	c3                   	ret    

f0100519 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100519:	55                   	push   %ebp
f010051a:	89 e5                	mov    %esp,%ebp
f010051c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010051f:	e8 c8 ff ff ff       	call   f01004ec <serial_intr>
	kbd_intr();
f0100524:	e8 de ff ff ff       	call   f0100507 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100529:	8b 15 20 25 11 f0    	mov    0xf0112520,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010052f:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100534:	3b 15 24 25 11 f0    	cmp    0xf0112524,%edx
f010053a:	74 1e                	je     f010055a <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010053c:	0f b6 82 20 23 11 f0 	movzbl -0xfeedce0(%edx),%eax
f0100543:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100546:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010054c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100551:	0f 44 d1             	cmove  %ecx,%edx
f0100554:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
		return c;
	}
	return 0;
}
f010055a:	c9                   	leave  
f010055b:	c3                   	ret    

f010055c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010055c:	55                   	push   %ebp
f010055d:	89 e5                	mov    %esp,%ebp
f010055f:	57                   	push   %edi
f0100560:	56                   	push   %esi
f0100561:	53                   	push   %ebx
f0100562:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100565:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010056c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100573:	5a a5 
	if (*cp != 0xA55A) {
f0100575:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010057c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100580:	74 11                	je     f0100593 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100582:	c7 05 2c 25 11 f0 b4 	movl   $0x3b4,0xf011252c
f0100589:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010058c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100591:	eb 16                	jmp    f01005a9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100593:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010059a:	c7 05 2c 25 11 f0 d4 	movl   $0x3d4,0xf011252c
f01005a1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005a4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a9:	8b 0d 2c 25 11 f0    	mov    0xf011252c,%ecx
f01005af:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b4:	89 ca                	mov    %ecx,%edx
f01005b6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b7:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ba:	89 da                	mov    %ebx,%edx
f01005bc:	ec                   	in     (%dx),%al
f01005bd:	0f b6 f8             	movzbl %al,%edi
f01005c0:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c8:	89 ca                	mov    %ecx,%edx
f01005ca:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cb:	89 da                	mov    %ebx,%edx
f01005cd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005ce:	89 35 30 25 11 f0    	mov    %esi,0xf0112530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005d4:	0f b6 d8             	movzbl %al,%ebx
f01005d7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005d9:	66 89 3d 34 25 11 f0 	mov    %di,0xf0112534
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e0:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ea:	89 da                	mov    %ebx,%edx
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	b2 fb                	mov    $0xfb,%dl
f01005ef:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f4:	ee                   	out    %al,(%dx)
f01005f5:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005fa:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ff:	89 ca                	mov    %ecx,%edx
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b2 f9                	mov    $0xf9,%dl
f0100604:	b8 00 00 00 00       	mov    $0x0,%eax
f0100609:	ee                   	out    %al,(%dx)
f010060a:	b2 fb                	mov    $0xfb,%dl
f010060c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100611:	ee                   	out    %al,(%dx)
f0100612:	b2 fc                	mov    $0xfc,%dl
f0100614:	b8 00 00 00 00       	mov    $0x0,%eax
f0100619:	ee                   	out    %al,(%dx)
f010061a:	b2 f9                	mov    $0xf9,%dl
f010061c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100621:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100622:	b2 fd                	mov    $0xfd,%dl
f0100624:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100625:	3c ff                	cmp    $0xff,%al
f0100627:	0f 95 c0             	setne  %al
f010062a:	89 c6                	mov    %eax,%esi
f010062c:	a2 00 23 11 f0       	mov    %al,0xf0112300
f0100631:	89 da                	mov    %ebx,%edx
f0100633:	ec                   	in     (%dx),%al
f0100634:	89 ca                	mov    %ecx,%edx
f0100636:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100637:	89 f0                	mov    %esi,%eax
f0100639:	84 c0                	test   %al,%al
f010063b:	75 0c                	jne    f0100649 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f010063d:	c7 04 24 50 1a 10 f0 	movl   $0xf0101a50,(%esp)
f0100644:	e8 dd 02 00 00       	call   f0100926 <cprintf>
}
f0100649:	83 c4 1c             	add    $0x1c,%esp
f010064c:	5b                   	pop    %ebx
f010064d:	5e                   	pop    %esi
f010064e:	5f                   	pop    %edi
f010064f:	5d                   	pop    %ebp
f0100650:	c3                   	ret    

f0100651 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100651:	55                   	push   %ebp
f0100652:	89 e5                	mov    %esp,%ebp
f0100654:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100657:	8b 45 08             	mov    0x8(%ebp),%eax
f010065a:	e8 a8 fb ff ff       	call   f0100207 <cons_putc>
}
f010065f:	c9                   	leave  
f0100660:	c3                   	ret    

f0100661 <getchar>:

int
getchar(void)
{
f0100661:	55                   	push   %ebp
f0100662:	89 e5                	mov    %esp,%ebp
f0100664:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100667:	e8 ad fe ff ff       	call   f0100519 <cons_getc>
f010066c:	85 c0                	test   %eax,%eax
f010066e:	74 f7                	je     f0100667 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100670:	c9                   	leave  
f0100671:	c3                   	ret    

f0100672 <iscons>:

int
iscons(int fdnum)
{
f0100672:	55                   	push   %ebp
f0100673:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100675:	b8 01 00 00 00       	mov    $0x1,%eax
f010067a:	5d                   	pop    %ebp
f010067b:	c3                   	ret    
f010067c:	00 00                	add    %al,(%eax)
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
f0100686:	c7 04 24 90 1c 10 f0 	movl   $0xf0101c90,(%esp)
f010068d:	e8 94 02 00 00       	call   f0100926 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100692:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100699:	00 
f010069a:	c7 04 24 1c 1d 10 f0 	movl   $0xf0101d1c,(%esp)
f01006a1:	e8 80 02 00 00       	call   f0100926 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006ad:	00 
f01006ae:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006b5:	f0 
f01006b6:	c7 04 24 44 1d 10 f0 	movl   $0xf0101d44,(%esp)
f01006bd:	e8 64 02 00 00       	call   f0100926 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c2:	c7 44 24 08 a5 19 10 	movl   $0x1019a5,0x8(%esp)
f01006c9:	00 
f01006ca:	c7 44 24 04 a5 19 10 	movl   $0xf01019a5,0x4(%esp)
f01006d1:	f0 
f01006d2:	c7 04 24 68 1d 10 f0 	movl   $0xf0101d68,(%esp)
f01006d9:	e8 48 02 00 00       	call   f0100926 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006de:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f01006e5:	00 
f01006e6:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f01006ed:	f0 
f01006ee:	c7 04 24 8c 1d 10 f0 	movl   $0xf0101d8c,(%esp)
f01006f5:	e8 2c 02 00 00       	call   f0100926 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006fa:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f0100701:	00 
f0100702:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f0100709:	f0 
f010070a:	c7 04 24 b0 1d 10 f0 	movl   $0xf0101db0,(%esp)
f0100711:	e8 10 02 00 00       	call   f0100926 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100716:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
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
f0100737:	c7 04 24 d4 1d 10 f0 	movl   $0xf0101dd4,(%esp)
f010073e:	e8 e3 01 00 00       	call   f0100926 <cprintf>
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
f010074d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100750:	c7 44 24 08 a9 1c 10 	movl   $0xf0101ca9,0x8(%esp)
f0100757:	f0 
f0100758:	c7 44 24 04 c7 1c 10 	movl   $0xf0101cc7,0x4(%esp)
f010075f:	f0 
f0100760:	c7 04 24 cc 1c 10 f0 	movl   $0xf0101ccc,(%esp)
f0100767:	e8 ba 01 00 00       	call   f0100926 <cprintf>
f010076c:	c7 44 24 08 00 1e 10 	movl   $0xf0101e00,0x8(%esp)
f0100773:	f0 
f0100774:	c7 44 24 04 d5 1c 10 	movl   $0xf0101cd5,0x4(%esp)
f010077b:	f0 
f010077c:	c7 04 24 cc 1c 10 f0 	movl   $0xf0101ccc,(%esp)
f0100783:	e8 9e 01 00 00       	call   f0100926 <cprintf>
	return 0;
}
f0100788:	b8 00 00 00 00       	mov    $0x0,%eax
f010078d:	c9                   	leave  
f010078e:	c3                   	ret    

f010078f <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010078f:	55                   	push   %ebp
f0100790:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100792:	b8 00 00 00 00       	mov    $0x0,%eax
f0100797:	5d                   	pop    %ebp
f0100798:	c3                   	ret    

f0100799 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100799:	55                   	push   %ebp
f010079a:	89 e5                	mov    %esp,%ebp
f010079c:	57                   	push   %edi
f010079d:	56                   	push   %esi
f010079e:	53                   	push   %ebx
f010079f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007a2:	c7 04 24 28 1e 10 f0 	movl   $0xf0101e28,(%esp)
f01007a9:	e8 78 01 00 00       	call   f0100926 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007ae:	c7 04 24 4c 1e 10 f0 	movl   $0xf0101e4c,(%esp)
f01007b5:	e8 6c 01 00 00       	call   f0100926 <cprintf>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f01007ba:	8d 7d a8             	lea    -0x58(%ebp),%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01007bd:	c7 04 24 de 1c 10 f0 	movl   $0xf0101cde,(%esp)
f01007c4:	e8 37 0a 00 00       	call   f0101200 <readline>
f01007c9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007cb:	85 c0                	test   %eax,%eax
f01007cd:	74 ee                	je     f01007bd <monitor+0x24>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007cf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007d6:	be 00 00 00 00       	mov    $0x0,%esi
f01007db:	eb 06                	jmp    f01007e3 <monitor+0x4a>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007dd:	c6 03 00             	movb   $0x0,(%ebx)
f01007e0:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007e3:	0f b6 03             	movzbl (%ebx),%eax
f01007e6:	84 c0                	test   %al,%al
f01007e8:	74 6a                	je     f0100854 <monitor+0xbb>
f01007ea:	0f be c0             	movsbl %al,%eax
f01007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007f1:	c7 04 24 e2 1c 10 f0 	movl   $0xf0101ce2,(%esp)
f01007f8:	e8 59 0c 00 00       	call   f0101456 <strchr>
f01007fd:	85 c0                	test   %eax,%eax
f01007ff:	75 dc                	jne    f01007dd <monitor+0x44>
			*buf++ = 0;
		if (*buf == 0)
f0100801:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100804:	74 4e                	je     f0100854 <monitor+0xbb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100806:	83 fe 0f             	cmp    $0xf,%esi
f0100809:	75 16                	jne    f0100821 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010080b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100812:	00 
f0100813:	c7 04 24 e7 1c 10 f0 	movl   $0xf0101ce7,(%esp)
f010081a:	e8 07 01 00 00       	call   f0100926 <cprintf>
f010081f:	eb 9c                	jmp    f01007bd <monitor+0x24>
			return 0;
		}
		argv[argc++] = buf;
f0100821:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100825:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100828:	0f b6 03             	movzbl (%ebx),%eax
f010082b:	84 c0                	test   %al,%al
f010082d:	75 0c                	jne    f010083b <monitor+0xa2>
f010082f:	eb b2                	jmp    f01007e3 <monitor+0x4a>
			buf++;
f0100831:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100834:	0f b6 03             	movzbl (%ebx),%eax
f0100837:	84 c0                	test   %al,%al
f0100839:	74 a8                	je     f01007e3 <monitor+0x4a>
f010083b:	0f be c0             	movsbl %al,%eax
f010083e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100842:	c7 04 24 e2 1c 10 f0 	movl   $0xf0101ce2,(%esp)
f0100849:	e8 08 0c 00 00       	call   f0101456 <strchr>
f010084e:	85 c0                	test   %eax,%eax
f0100850:	74 df                	je     f0100831 <monitor+0x98>
f0100852:	eb 8f                	jmp    f01007e3 <monitor+0x4a>
			buf++;
	}
	argv[argc] = 0;
f0100854:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010085b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010085c:	85 f6                	test   %esi,%esi
f010085e:	0f 84 59 ff ff ff    	je     f01007bd <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100864:	c7 44 24 04 c7 1c 10 	movl   $0xf0101cc7,0x4(%esp)
f010086b:	f0 
f010086c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010086f:	89 04 24             	mov    %eax,(%esp)
f0100872:	e8 64 0b 00 00       	call   f01013db <strcmp>
f0100877:	ba 00 00 00 00       	mov    $0x0,%edx
f010087c:	85 c0                	test   %eax,%eax
f010087e:	74 1c                	je     f010089c <monitor+0x103>
f0100880:	c7 44 24 04 d5 1c 10 	movl   $0xf0101cd5,0x4(%esp)
f0100887:	f0 
f0100888:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010088b:	89 04 24             	mov    %eax,(%esp)
f010088e:	e8 48 0b 00 00       	call   f01013db <strcmp>
f0100893:	85 c0                	test   %eax,%eax
f0100895:	75 28                	jne    f01008bf <monitor+0x126>
f0100897:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f010089c:	8d 04 12             	lea    (%edx,%edx,1),%eax
f010089f:	01 c2                	add    %eax,%edx
f01008a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01008a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01008ac:	89 34 24             	mov    %esi,(%esp)
f01008af:	ff 14 95 7c 1e 10 f0 	call   *-0xfefe184(,%edx,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008b6:	85 c0                	test   %eax,%eax
f01008b8:	78 1d                	js     f01008d7 <monitor+0x13e>
f01008ba:	e9 fe fe ff ff       	jmp    f01007bd <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008bf:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c6:	c7 04 24 04 1d 10 f0 	movl   $0xf0101d04,(%esp)
f01008cd:	e8 54 00 00 00       	call   f0100926 <cprintf>
f01008d2:	e9 e6 fe ff ff       	jmp    f01007bd <monitor+0x24>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008d7:	83 c4 5c             	add    $0x5c,%esp
f01008da:	5b                   	pop    %ebx
f01008db:	5e                   	pop    %esi
f01008dc:	5f                   	pop    %edi
f01008dd:	5d                   	pop    %ebp
f01008de:	c3                   	ret    
	...

f01008e0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008e0:	55                   	push   %ebp
f01008e1:	89 e5                	mov    %esp,%ebp
f01008e3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01008e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01008e9:	89 04 24             	mov    %eax,(%esp)
f01008ec:	e8 60 fd ff ff       	call   f0100651 <cputchar>
	*cnt++;
}
f01008f1:	c9                   	leave  
f01008f2:	c3                   	ret    

f01008f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008f3:	55                   	push   %ebp
f01008f4:	89 e5                	mov    %esp,%ebp
f01008f6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01008f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100900:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100903:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100907:	8b 45 08             	mov    0x8(%ebp),%eax
f010090a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010090e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100911:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100915:	c7 04 24 e0 08 10 f0 	movl   $0xf01008e0,(%esp)
f010091c:	e8 69 04 00 00       	call   f0100d8a <vprintfmt>
	return cnt;
}
f0100921:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100924:	c9                   	leave  
f0100925:	c3                   	ret    

f0100926 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100926:	55                   	push   %ebp
f0100927:	89 e5                	mov    %esp,%ebp
f0100929:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010092c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100933:	8b 45 08             	mov    0x8(%ebp),%eax
f0100936:	89 04 24             	mov    %eax,(%esp)
f0100939:	e8 b5 ff ff ff       	call   f01008f3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010093e:	c9                   	leave  
f010093f:	c3                   	ret    

f0100940 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100940:	55                   	push   %ebp
f0100941:	89 e5                	mov    %esp,%ebp
f0100943:	57                   	push   %edi
f0100944:	56                   	push   %esi
f0100945:	53                   	push   %ebx
f0100946:	83 ec 10             	sub    $0x10,%esp
f0100949:	89 c3                	mov    %eax,%ebx
f010094b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010094e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100951:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100954:	8b 0a                	mov    (%edx),%ecx
f0100956:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100959:	8b 00                	mov    (%eax),%eax
f010095b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010095e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100965:	eb 77                	jmp    f01009de <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100967:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010096a:	01 c8                	add    %ecx,%eax
f010096c:	bf 02 00 00 00       	mov    $0x2,%edi
f0100971:	99                   	cltd   
f0100972:	f7 ff                	idiv   %edi
f0100974:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100976:	eb 01                	jmp    f0100979 <stab_binsearch+0x39>
			m--;
f0100978:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100979:	39 ca                	cmp    %ecx,%edx
f010097b:	7c 1d                	jl     f010099a <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010097d:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100980:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100985:	39 f7                	cmp    %esi,%edi
f0100987:	75 ef                	jne    f0100978 <stab_binsearch+0x38>
f0100989:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010098c:	6b fa 0c             	imul   $0xc,%edx,%edi
f010098f:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100993:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100996:	73 18                	jae    f01009b0 <stab_binsearch+0x70>
f0100998:	eb 05                	jmp    f010099f <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010099a:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f010099d:	eb 3f                	jmp    f01009de <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010099f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009a2:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f01009a4:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009a7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01009ae:	eb 2e                	jmp    f01009de <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009b0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f01009b3:	76 15                	jbe    f01009ca <stab_binsearch+0x8a>
			*region_right = m - 1;
f01009b5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01009b8:	4f                   	dec    %edi
f01009b9:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01009bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009bf:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009c1:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01009c8:	eb 14                	jmp    f01009de <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01009ca:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01009cd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009d0:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f01009d2:	ff 45 0c             	incl   0xc(%ebp)
f01009d5:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009d7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01009de:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01009e1:	7e 84                	jle    f0100967 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01009e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01009e7:	75 0d                	jne    f01009f6 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f01009e9:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009ec:	8b 02                	mov    (%edx),%eax
f01009ee:	48                   	dec    %eax
f01009ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01009f2:	89 01                	mov    %eax,(%ecx)
f01009f4:	eb 22                	jmp    f0100a18 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01009f9:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009fb:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009fe:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a00:	eb 01                	jmp    f0100a03 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a02:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a03:	39 c1                	cmp    %eax,%ecx
f0100a05:	7d 0c                	jge    f0100a13 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100a07:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100a0a:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100a0f:	39 f2                	cmp    %esi,%edx
f0100a11:	75 ef                	jne    f0100a02 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a13:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a16:	89 02                	mov    %eax,(%edx)
	}
}
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	5b                   	pop    %ebx
f0100a1c:	5e                   	pop    %esi
f0100a1d:	5f                   	pop    %edi
f0100a1e:	5d                   	pop    %ebp
f0100a1f:	c3                   	ret    

f0100a20 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a20:	55                   	push   %ebp
f0100a21:	89 e5                	mov    %esp,%ebp
f0100a23:	83 ec 38             	sub    $0x38,%esp
f0100a26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100a29:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100a2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100a2f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a35:	c7 03 8c 1e 10 f0    	movl   $0xf0101e8c,(%ebx)
	info->eip_line = 0;
f0100a3b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a42:	c7 43 08 8c 1e 10 f0 	movl   $0xf0101e8c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a49:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a50:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a53:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a5a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100a60:	76 12                	jbe    f0100a74 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a62:	b8 27 75 10 f0       	mov    $0xf0107527,%eax
f0100a67:	3d 11 5c 10 f0       	cmp    $0xf0105c11,%eax
f0100a6c:	0f 86 9b 01 00 00    	jbe    f0100c0d <debuginfo_eip+0x1ed>
f0100a72:	eb 1c                	jmp    f0100a90 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a74:	c7 44 24 08 96 1e 10 	movl   $0xf0101e96,0x8(%esp)
f0100a7b:	f0 
f0100a7c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100a83:	00 
f0100a84:	c7 04 24 a3 1e 10 f0 	movl   $0xf0101ea3,(%esp)
f0100a8b:	e8 68 f6 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a95:	80 3d 26 75 10 f0 00 	cmpb   $0x0,0xf0107526
f0100a9c:	0f 85 77 01 00 00    	jne    f0100c19 <debuginfo_eip+0x1f9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100aa2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aa9:	b8 10 5c 10 f0       	mov    $0xf0105c10,%eax
f0100aae:	2d c4 20 10 f0       	sub    $0xf01020c4,%eax
f0100ab3:	c1 f8 02             	sar    $0x2,%eax
f0100ab6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100abc:	83 e8 01             	sub    $0x1,%eax
f0100abf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100ac2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ac6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100acd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100ad0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100ad3:	b8 c4 20 10 f0       	mov    $0xf01020c4,%eax
f0100ad8:	e8 63 fe ff ff       	call   f0100940 <stab_binsearch>
	if (lfile == 0)
f0100add:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100ae0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100ae5:	85 d2                	test   %edx,%edx
f0100ae7:	0f 84 2c 01 00 00    	je     f0100c19 <debuginfo_eip+0x1f9>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100aed:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100af0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100af3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100af6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100afa:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100b01:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b04:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b07:	b8 c4 20 10 f0       	mov    $0xf01020c4,%eax
f0100b0c:	e8 2f fe ff ff       	call   f0100940 <stab_binsearch>

	if (lfun <= rfun) {
f0100b11:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100b14:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100b17:	7f 2e                	jg     f0100b47 <debuginfo_eip+0x127>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b19:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100b1c:	8d 90 c4 20 10 f0    	lea    -0xfefdf3c(%eax),%edx
f0100b22:	8b 80 c4 20 10 f0    	mov    -0xfefdf3c(%eax),%eax
f0100b28:	b9 27 75 10 f0       	mov    $0xf0107527,%ecx
f0100b2d:	81 e9 11 5c 10 f0    	sub    $0xf0105c11,%ecx
f0100b33:	39 c8                	cmp    %ecx,%eax
f0100b35:	73 08                	jae    f0100b3f <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b37:	05 11 5c 10 f0       	add    $0xf0105c11,%eax
f0100b3c:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b3f:	8b 42 08             	mov    0x8(%edx),%eax
f0100b42:	89 43 10             	mov    %eax,0x10(%ebx)
f0100b45:	eb 06                	jmp    f0100b4d <debuginfo_eip+0x12d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b47:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b4d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100b54:	00 
f0100b55:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b58:	89 04 24             	mov    %eax,(%esp)
f0100b5b:	e8 2a 09 00 00       	call   f010148a <strfind>
f0100b60:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b63:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b69:	39 d7                	cmp    %edx,%edi
f0100b6b:	7c 5f                	jl     f0100bcc <debuginfo_eip+0x1ac>
	       && stabs[lline].n_type != N_SOL
f0100b6d:	89 f8                	mov    %edi,%eax
f0100b6f:	6b cf 0c             	imul   $0xc,%edi,%ecx
f0100b72:	80 b9 c8 20 10 f0 84 	cmpb   $0x84,-0xfefdf38(%ecx)
f0100b79:	75 18                	jne    f0100b93 <debuginfo_eip+0x173>
f0100b7b:	eb 30                	jmp    f0100bad <debuginfo_eip+0x18d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b7d:	83 ef 01             	sub    $0x1,%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b80:	39 fa                	cmp    %edi,%edx
f0100b82:	7f 48                	jg     f0100bcc <debuginfo_eip+0x1ac>
	       && stabs[lline].n_type != N_SOL
f0100b84:	89 f8                	mov    %edi,%eax
f0100b86:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0100b89:	80 3c 8d c8 20 10 f0 	cmpb   $0x84,-0xfefdf38(,%ecx,4)
f0100b90:	84 
f0100b91:	74 1a                	je     f0100bad <debuginfo_eip+0x18d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b93:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b96:	8d 04 85 c4 20 10 f0 	lea    -0xfefdf3c(,%eax,4),%eax
f0100b9d:	80 78 04 64          	cmpb   $0x64,0x4(%eax)
f0100ba1:	75 da                	jne    f0100b7d <debuginfo_eip+0x15d>
f0100ba3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100ba7:	74 d4                	je     f0100b7d <debuginfo_eip+0x15d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ba9:	39 fa                	cmp    %edi,%edx
f0100bab:	7f 1f                	jg     f0100bcc <debuginfo_eip+0x1ac>
f0100bad:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100bb0:	8b 87 c4 20 10 f0    	mov    -0xfefdf3c(%edi),%eax
f0100bb6:	ba 27 75 10 f0       	mov    $0xf0107527,%edx
f0100bbb:	81 ea 11 5c 10 f0    	sub    $0xf0105c11,%edx
f0100bc1:	39 d0                	cmp    %edx,%eax
f0100bc3:	73 07                	jae    f0100bcc <debuginfo_eip+0x1ac>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100bc5:	05 11 5c 10 f0       	add    $0xf0105c11,%eax
f0100bca:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bcc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bcf:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bd2:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bd7:	39 ca                	cmp    %ecx,%edx
f0100bd9:	7d 3e                	jge    f0100c19 <debuginfo_eip+0x1f9>
		for (lline = lfun + 1;
f0100bdb:	83 c2 01             	add    $0x1,%edx
f0100bde:	39 d1                	cmp    %edx,%ecx
f0100be0:	7e 37                	jle    f0100c19 <debuginfo_eip+0x1f9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100be2:	6b f2 0c             	imul   $0xc,%edx,%esi
f0100be5:	80 be c8 20 10 f0 a0 	cmpb   $0xa0,-0xfefdf38(%esi)
f0100bec:	75 2b                	jne    f0100c19 <debuginfo_eip+0x1f9>
		     lline++)
			info->eip_fn_narg++;
f0100bee:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100bf2:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100bf5:	39 d1                	cmp    %edx,%ecx
f0100bf7:	7e 1b                	jle    f0100c14 <debuginfo_eip+0x1f4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100bf9:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100bfc:	80 3c 85 c8 20 10 f0 	cmpb   $0xa0,-0xfefdf38(,%eax,4)
f0100c03:	a0 
f0100c04:	74 e8                	je     f0100bee <debuginfo_eip+0x1ce>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c06:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c0b:	eb 0c                	jmp    f0100c19 <debuginfo_eip+0x1f9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c12:	eb 05                	jmp    f0100c19 <debuginfo_eip+0x1f9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c14:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c19:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100c1c:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100c1f:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100c22:	89 ec                	mov    %ebp,%esp
f0100c24:	5d                   	pop    %ebp
f0100c25:	c3                   	ret    
	...

f0100c30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c30:	55                   	push   %ebp
f0100c31:	89 e5                	mov    %esp,%ebp
f0100c33:	57                   	push   %edi
f0100c34:	56                   	push   %esi
f0100c35:	53                   	push   %ebx
f0100c36:	83 ec 3c             	sub    $0x3c,%esp
f0100c39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c3c:	89 d7                	mov    %edx,%edi
f0100c3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c41:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100c44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c47:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c4a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c4d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c55:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100c58:	72 11                	jb     f0100c6b <printnum+0x3b>
f0100c5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c5d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c60:	76 09                	jbe    f0100c6b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c62:	83 eb 01             	sub    $0x1,%ebx
f0100c65:	85 db                	test   %ebx,%ebx
f0100c67:	7f 51                	jg     f0100cba <printnum+0x8a>
f0100c69:	eb 5e                	jmp    f0100cc9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c6b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100c6f:	83 eb 01             	sub    $0x1,%ebx
f0100c72:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100c76:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c7d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100c81:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100c85:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100c8c:	00 
f0100c8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c90:	89 04 24             	mov    %eax,(%esp)
f0100c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c9a:	e8 61 0a 00 00       	call   f0101700 <__udivdi3>
f0100c9f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100ca3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100ca7:	89 04 24             	mov    %eax,(%esp)
f0100caa:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cae:	89 fa                	mov    %edi,%edx
f0100cb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cb3:	e8 78 ff ff ff       	call   f0100c30 <printnum>
f0100cb8:	eb 0f                	jmp    f0100cc9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100cba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100cbe:	89 34 24             	mov    %esi,(%esp)
f0100cc1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100cc4:	83 eb 01             	sub    $0x1,%ebx
f0100cc7:	75 f1                	jne    f0100cba <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100cc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ccd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100cd1:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cd4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cd8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100cdf:	00 
f0100ce0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ce3:	89 04 24             	mov    %eax,(%esp)
f0100ce6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ced:	e8 3e 0b 00 00       	call   f0101830 <__umoddi3>
f0100cf2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100cf6:	0f be 80 b1 1e 10 f0 	movsbl -0xfefe14f(%eax),%eax
f0100cfd:	89 04 24             	mov    %eax,(%esp)
f0100d00:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100d03:	83 c4 3c             	add    $0x3c,%esp
f0100d06:	5b                   	pop    %ebx
f0100d07:	5e                   	pop    %esi
f0100d08:	5f                   	pop    %edi
f0100d09:	5d                   	pop    %ebp
f0100d0a:	c3                   	ret    

f0100d0b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d0b:	55                   	push   %ebp
f0100d0c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d0e:	83 fa 01             	cmp    $0x1,%edx
f0100d11:	7e 0e                	jle    f0100d21 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d13:	8b 10                	mov    (%eax),%edx
f0100d15:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d18:	89 08                	mov    %ecx,(%eax)
f0100d1a:	8b 02                	mov    (%edx),%eax
f0100d1c:	8b 52 04             	mov    0x4(%edx),%edx
f0100d1f:	eb 22                	jmp    f0100d43 <getuint+0x38>
	else if (lflag)
f0100d21:	85 d2                	test   %edx,%edx
f0100d23:	74 10                	je     f0100d35 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d25:	8b 10                	mov    (%eax),%edx
f0100d27:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d2a:	89 08                	mov    %ecx,(%eax)
f0100d2c:	8b 02                	mov    (%edx),%eax
f0100d2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d33:	eb 0e                	jmp    f0100d43 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d35:	8b 10                	mov    (%eax),%edx
f0100d37:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d3a:	89 08                	mov    %ecx,(%eax)
f0100d3c:	8b 02                	mov    (%edx),%eax
f0100d3e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d43:	5d                   	pop    %ebp
f0100d44:	c3                   	ret    

f0100d45 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d45:	55                   	push   %ebp
f0100d46:	89 e5                	mov    %esp,%ebp
f0100d48:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d4b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d4f:	8b 10                	mov    (%eax),%edx
f0100d51:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d54:	73 0a                	jae    f0100d60 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d56:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100d59:	88 0a                	mov    %cl,(%edx)
f0100d5b:	83 c2 01             	add    $0x1,%edx
f0100d5e:	89 10                	mov    %edx,(%eax)
}
f0100d60:	5d                   	pop    %ebp
f0100d61:	c3                   	ret    

f0100d62 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d62:	55                   	push   %ebp
f0100d63:	89 e5                	mov    %esp,%ebp
f0100d65:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d68:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d6f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d72:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d80:	89 04 24             	mov    %eax,(%esp)
f0100d83:	e8 02 00 00 00       	call   f0100d8a <vprintfmt>
	va_end(ap);
}
f0100d88:	c9                   	leave  
f0100d89:	c3                   	ret    

f0100d8a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d8a:	55                   	push   %ebp
f0100d8b:	89 e5                	mov    %esp,%ebp
f0100d8d:	57                   	push   %edi
f0100d8e:	56                   	push   %esi
f0100d8f:	53                   	push   %ebx
f0100d90:	83 ec 4c             	sub    $0x4c,%esp
f0100d93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d96:	8b 75 10             	mov    0x10(%ebp),%esi
f0100d99:	eb 12                	jmp    f0100dad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d9b:	85 c0                	test   %eax,%eax
f0100d9d:	0f 84 c9 03 00 00    	je     f010116c <vprintfmt+0x3e2>
				return;
			putch(ch, putdat);
f0100da3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100da7:	89 04 24             	mov    %eax,(%esp)
f0100daa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100dad:	0f b6 06             	movzbl (%esi),%eax
f0100db0:	83 c6 01             	add    $0x1,%esi
f0100db3:	83 f8 25             	cmp    $0x25,%eax
f0100db6:	75 e3                	jne    f0100d9b <vprintfmt+0x11>
f0100db8:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100dbc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100dc3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100dc8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100dd4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100dd7:	eb 2b                	jmp    f0100e04 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dd9:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100ddc:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100de0:	eb 22                	jmp    f0100e04 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100de2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100de5:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100de9:	eb 19                	jmp    f0100e04 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100deb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100dee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100df5:	eb 0d                	jmp    f0100e04 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100df7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dfd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e04:	0f b6 06             	movzbl (%esi),%eax
f0100e07:	0f b6 d0             	movzbl %al,%edx
f0100e0a:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e0d:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100e10:	83 e8 23             	sub    $0x23,%eax
f0100e13:	3c 55                	cmp    $0x55,%al
f0100e15:	0f 87 2b 03 00 00    	ja     f0101146 <vprintfmt+0x3bc>
f0100e1b:	0f b6 c0             	movzbl %al,%eax
f0100e1e:	ff 24 85 40 1f 10 f0 	jmp    *-0xfefe0c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e25:	83 ea 30             	sub    $0x30,%edx
f0100e28:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0100e2b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0100e2f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e32:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0100e35:	83 fa 09             	cmp    $0x9,%edx
f0100e38:	77 4a                	ja     f0100e84 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e3a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e3d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0100e40:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100e43:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100e47:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100e4a:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100e4d:	83 fa 09             	cmp    $0x9,%edx
f0100e50:	76 eb                	jbe    f0100e3d <vprintfmt+0xb3>
f0100e52:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e55:	eb 2d                	jmp    f0100e84 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e57:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e5a:	8d 50 04             	lea    0x4(%eax),%edx
f0100e5d:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e60:	8b 00                	mov    (%eax),%eax
f0100e62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e65:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e68:	eb 1a                	jmp    f0100e84 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0100e6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e71:	79 91                	jns    f0100e04 <vprintfmt+0x7a>
f0100e73:	e9 73 ff ff ff       	jmp    f0100deb <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e78:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e7b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0100e82:	eb 80                	jmp    f0100e04 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0100e84:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e88:	0f 89 76 ff ff ff    	jns    f0100e04 <vprintfmt+0x7a>
f0100e8e:	e9 64 ff ff ff       	jmp    f0100df7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e93:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e96:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100e99:	e9 66 ff ff ff       	jmp    f0100e04 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ea1:	8d 50 04             	lea    0x4(%eax),%edx
f0100ea4:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ea7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100eab:	8b 00                	mov    (%eax),%eax
f0100ead:	89 04 24             	mov    %eax,(%esp)
f0100eb0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100eb6:	e9 f2 fe ff ff       	jmp    f0100dad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ebb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ebe:	8d 50 04             	lea    0x4(%eax),%edx
f0100ec1:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ec4:	8b 00                	mov    (%eax),%eax
f0100ec6:	89 c2                	mov    %eax,%edx
f0100ec8:	c1 fa 1f             	sar    $0x1f,%edx
f0100ecb:	31 d0                	xor    %edx,%eax
f0100ecd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ecf:	83 f8 06             	cmp    $0x6,%eax
f0100ed2:	7f 0b                	jg     f0100edf <vprintfmt+0x155>
f0100ed4:	8b 14 85 98 20 10 f0 	mov    -0xfefdf68(,%eax,4),%edx
f0100edb:	85 d2                	test   %edx,%edx
f0100edd:	75 23                	jne    f0100f02 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0100edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee3:	c7 44 24 08 c9 1e 10 	movl   $0xf0101ec9,0x8(%esp)
f0100eea:	f0 
f0100eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100eef:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100ef2:	89 3c 24             	mov    %edi,(%esp)
f0100ef5:	e8 68 fe ff ff       	call   f0100d62 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100efa:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100efd:	e9 ab fe ff ff       	jmp    f0100dad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100f02:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f06:	c7 44 24 08 d2 1e 10 	movl   $0xf0101ed2,0x8(%esp)
f0100f0d:	f0 
f0100f0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f12:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100f15:	89 3c 24             	mov    %edi,(%esp)
f0100f18:	e8 45 fe ff ff       	call   f0100d62 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f1d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f20:	e9 88 fe ff ff       	jmp    f0100dad <vprintfmt+0x23>
f0100f25:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f31:	8d 50 04             	lea    0x4(%eax),%edx
f0100f34:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f37:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0100f39:	85 f6                	test   %esi,%esi
f0100f3b:	ba c2 1e 10 f0       	mov    $0xf0101ec2,%edx
f0100f40:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0100f43:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f47:	7e 06                	jle    f0100f4f <vprintfmt+0x1c5>
f0100f49:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100f4d:	75 10                	jne    f0100f5f <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f4f:	0f be 06             	movsbl (%esi),%eax
f0100f52:	83 c6 01             	add    $0x1,%esi
f0100f55:	85 c0                	test   %eax,%eax
f0100f57:	0f 85 86 00 00 00    	jne    f0100fe3 <vprintfmt+0x259>
f0100f5d:	eb 76                	jmp    f0100fd5 <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f5f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f63:	89 34 24             	mov    %esi,(%esp)
f0100f66:	e8 80 03 00 00       	call   f01012eb <strnlen>
f0100f6b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f6e:	29 c2                	sub    %eax,%edx
f0100f70:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100f73:	85 d2                	test   %edx,%edx
f0100f75:	7e d8                	jle    f0100f4f <vprintfmt+0x1c5>
					putch(padc, putdat);
f0100f77:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0100f7b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100f7e:	89 d6                	mov    %edx,%esi
f0100f80:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0100f83:	89 c7                	mov    %eax,%edi
f0100f85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f89:	89 3c 24             	mov    %edi,(%esp)
f0100f8c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f8f:	83 ee 01             	sub    $0x1,%esi
f0100f92:	75 f1                	jne    f0100f85 <vprintfmt+0x1fb>
f0100f94:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100f97:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100f9a:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100f9d:	eb b0                	jmp    f0100f4f <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f9f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fa3:	74 18                	je     f0100fbd <vprintfmt+0x233>
f0100fa5:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100fa8:	83 fa 5e             	cmp    $0x5e,%edx
f0100fab:	76 10                	jbe    f0100fbd <vprintfmt+0x233>
					putch('?', putdat);
f0100fad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fb1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100fb8:	ff 55 08             	call   *0x8(%ebp)
f0100fbb:	eb 0a                	jmp    f0100fc7 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0100fbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fc1:	89 04 24             	mov    %eax,(%esp)
f0100fc4:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fc7:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100fcb:	0f be 06             	movsbl (%esi),%eax
f0100fce:	83 c6 01             	add    $0x1,%esi
f0100fd1:	85 c0                	test   %eax,%eax
f0100fd3:	75 0e                	jne    f0100fe3 <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fd5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100fd8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100fdc:	7f 16                	jg     f0100ff4 <vprintfmt+0x26a>
f0100fde:	e9 ca fd ff ff       	jmp    f0100dad <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fe3:	85 ff                	test   %edi,%edi
f0100fe5:	78 b8                	js     f0100f9f <vprintfmt+0x215>
f0100fe7:	83 ef 01             	sub    $0x1,%edi
f0100fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100ff0:	79 ad                	jns    f0100f9f <vprintfmt+0x215>
f0100ff2:	eb e1                	jmp    f0100fd5 <vprintfmt+0x24b>
f0100ff4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ff7:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100ffa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ffe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101005:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101007:	83 ee 01             	sub    $0x1,%esi
f010100a:	75 ee                	jne    f0100ffa <vprintfmt+0x270>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010100c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010100f:	e9 99 fd ff ff       	jmp    f0100dad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101014:	83 f9 01             	cmp    $0x1,%ecx
f0101017:	7e 10                	jle    f0101029 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101019:	8b 45 14             	mov    0x14(%ebp),%eax
f010101c:	8d 50 08             	lea    0x8(%eax),%edx
f010101f:	89 55 14             	mov    %edx,0x14(%ebp)
f0101022:	8b 30                	mov    (%eax),%esi
f0101024:	8b 78 04             	mov    0x4(%eax),%edi
f0101027:	eb 26                	jmp    f010104f <vprintfmt+0x2c5>
	else if (lflag)
f0101029:	85 c9                	test   %ecx,%ecx
f010102b:	74 12                	je     f010103f <vprintfmt+0x2b5>
		return va_arg(*ap, long);
f010102d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101030:	8d 50 04             	lea    0x4(%eax),%edx
f0101033:	89 55 14             	mov    %edx,0x14(%ebp)
f0101036:	8b 30                	mov    (%eax),%esi
f0101038:	89 f7                	mov    %esi,%edi
f010103a:	c1 ff 1f             	sar    $0x1f,%edi
f010103d:	eb 10                	jmp    f010104f <vprintfmt+0x2c5>
	else
		return va_arg(*ap, int);
f010103f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101042:	8d 50 04             	lea    0x4(%eax),%edx
f0101045:	89 55 14             	mov    %edx,0x14(%ebp)
f0101048:	8b 30                	mov    (%eax),%esi
f010104a:	89 f7                	mov    %esi,%edi
f010104c:	c1 ff 1f             	sar    $0x1f,%edi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010104f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101054:	85 ff                	test   %edi,%edi
f0101056:	0f 89 ac 00 00 00    	jns    f0101108 <vprintfmt+0x37e>
				putch('-', putdat);
f010105c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101060:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101067:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010106a:	f7 de                	neg    %esi
f010106c:	83 d7 00             	adc    $0x0,%edi
f010106f:	f7 df                	neg    %edi
			}
			base = 10;
f0101071:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101076:	e9 8d 00 00 00       	jmp    f0101108 <vprintfmt+0x37e>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010107b:	89 ca                	mov    %ecx,%edx
f010107d:	8d 45 14             	lea    0x14(%ebp),%eax
f0101080:	e8 86 fc ff ff       	call   f0100d0b <getuint>
f0101085:	89 c6                	mov    %eax,%esi
f0101087:	89 d7                	mov    %edx,%edi
			base = 10;
f0101089:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010108e:	eb 78                	jmp    f0101108 <vprintfmt+0x37e>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101094:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010109b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010109e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010a2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01010a9:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01010ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010b0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01010b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01010bd:	e9 eb fc ff ff       	jmp    f0100dad <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f01010c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01010cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01010d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01010db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010de:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e1:	8d 50 04             	lea    0x4(%eax),%edx
f01010e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01010e7:	8b 30                	mov    (%eax),%esi
f01010e9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01010ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01010f3:	eb 13                	jmp    f0101108 <vprintfmt+0x37e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010f5:	89 ca                	mov    %ecx,%edx
f01010f7:	8d 45 14             	lea    0x14(%ebp),%eax
f01010fa:	e8 0c fc ff ff       	call   f0100d0b <getuint>
f01010ff:	89 c6                	mov    %eax,%esi
f0101101:	89 d7                	mov    %edx,%edi
			base = 16;
f0101103:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101108:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f010110c:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101110:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101113:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101117:	89 44 24 08          	mov    %eax,0x8(%esp)
f010111b:	89 34 24             	mov    %esi,(%esp)
f010111e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101122:	89 da                	mov    %ebx,%edx
f0101124:	8b 45 08             	mov    0x8(%ebp),%eax
f0101127:	e8 04 fb ff ff       	call   f0100c30 <printnum>
			break;
f010112c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010112f:	e9 79 fc ff ff       	jmp    f0100dad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101138:	89 14 24             	mov    %edx,(%esp)
f010113b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010113e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101141:	e9 67 fc ff ff       	jmp    f0100dad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101146:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010114a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101151:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101154:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101158:	0f 84 4f fc ff ff    	je     f0100dad <vprintfmt+0x23>
f010115e:	83 ee 01             	sub    $0x1,%esi
f0101161:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101165:	75 f7                	jne    f010115e <vprintfmt+0x3d4>
f0101167:	e9 41 fc ff ff       	jmp    f0100dad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f010116c:	83 c4 4c             	add    $0x4c,%esp
f010116f:	5b                   	pop    %ebx
f0101170:	5e                   	pop    %esi
f0101171:	5f                   	pop    %edi
f0101172:	5d                   	pop    %ebp
f0101173:	c3                   	ret    

f0101174 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101174:	55                   	push   %ebp
f0101175:	89 e5                	mov    %esp,%ebp
f0101177:	83 ec 28             	sub    $0x28,%esp
f010117a:	8b 45 08             	mov    0x8(%ebp),%eax
f010117d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101180:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101183:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101187:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010118a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101191:	85 c0                	test   %eax,%eax
f0101193:	74 30                	je     f01011c5 <vsnprintf+0x51>
f0101195:	85 d2                	test   %edx,%edx
f0101197:	7e 2c                	jle    f01011c5 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101199:	8b 45 14             	mov    0x14(%ebp),%eax
f010119c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011a0:	8b 45 10             	mov    0x10(%ebp),%eax
f01011a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ae:	c7 04 24 45 0d 10 f0 	movl   $0xf0100d45,(%esp)
f01011b5:	e8 d0 fb ff ff       	call   f0100d8a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011c3:	eb 05                	jmp    f01011ca <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011ca:	c9                   	leave  
f01011cb:	c3                   	ret    

f01011cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011cc:	55                   	push   %ebp
f01011cd:	89 e5                	mov    %esp,%ebp
f01011cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01011dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ea:	89 04 24             	mov    %eax,(%esp)
f01011ed:	e8 82 ff ff ff       	call   f0101174 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011f2:	c9                   	leave  
f01011f3:	c3                   	ret    
	...

f0101200 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
f0101203:	57                   	push   %edi
f0101204:	56                   	push   %esi
f0101205:	53                   	push   %ebx
f0101206:	83 ec 1c             	sub    $0x1c,%esp
f0101209:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010120c:	85 c0                	test   %eax,%eax
f010120e:	74 10                	je     f0101220 <readline+0x20>
		cprintf("%s", prompt);
f0101210:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101214:	c7 04 24 d2 1e 10 f0 	movl   $0xf0101ed2,(%esp)
f010121b:	e8 06 f7 ff ff       	call   f0100926 <cprintf>

	i = 0;
	echoing = iscons(0);
f0101220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101227:	e8 46 f4 ff ff       	call   f0100672 <iscons>
f010122c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010122e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101233:	e8 29 f4 ff ff       	call   f0100661 <getchar>
f0101238:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010123a:	85 c0                	test   %eax,%eax
f010123c:	79 17                	jns    f0101255 <readline+0x55>
			cprintf("read error: %e\n", c);
f010123e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101242:	c7 04 24 b4 20 10 f0 	movl   $0xf01020b4,(%esp)
f0101249:	e8 d8 f6 ff ff       	call   f0100926 <cprintf>
			return NULL;
f010124e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101253:	eb 6d                	jmp    f01012c2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101255:	83 f8 08             	cmp    $0x8,%eax
f0101258:	74 05                	je     f010125f <readline+0x5f>
f010125a:	83 f8 7f             	cmp    $0x7f,%eax
f010125d:	75 19                	jne    f0101278 <readline+0x78>
f010125f:	85 f6                	test   %esi,%esi
f0101261:	7e 15                	jle    f0101278 <readline+0x78>
			if (echoing)
f0101263:	85 ff                	test   %edi,%edi
f0101265:	74 0c                	je     f0101273 <readline+0x73>
				cputchar('\b');
f0101267:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010126e:	e8 de f3 ff ff       	call   f0100651 <cputchar>
			i--;
f0101273:	83 ee 01             	sub    $0x1,%esi
f0101276:	eb bb                	jmp    f0101233 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101278:	83 fb 1f             	cmp    $0x1f,%ebx
f010127b:	7e 1f                	jle    f010129c <readline+0x9c>
f010127d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101283:	7f 17                	jg     f010129c <readline+0x9c>
			if (echoing)
f0101285:	85 ff                	test   %edi,%edi
f0101287:	74 08                	je     f0101291 <readline+0x91>
				cputchar(c);
f0101289:	89 1c 24             	mov    %ebx,(%esp)
f010128c:	e8 c0 f3 ff ff       	call   f0100651 <cputchar>
			buf[i++] = c;
f0101291:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101297:	83 c6 01             	add    $0x1,%esi
f010129a:	eb 97                	jmp    f0101233 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010129c:	83 fb 0a             	cmp    $0xa,%ebx
f010129f:	74 05                	je     f01012a6 <readline+0xa6>
f01012a1:	83 fb 0d             	cmp    $0xd,%ebx
f01012a4:	75 8d                	jne    f0101233 <readline+0x33>
			if (echoing)
f01012a6:	85 ff                	test   %edi,%edi
f01012a8:	74 0c                	je     f01012b6 <readline+0xb6>
				cputchar('\n');
f01012aa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01012b1:	e8 9b f3 ff ff       	call   f0100651 <cputchar>
			buf[i] = 0;
f01012b6:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012bd:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012c2:	83 c4 1c             	add    $0x1c,%esp
f01012c5:	5b                   	pop    %ebx
f01012c6:	5e                   	pop    %esi
f01012c7:	5f                   	pop    %edi
f01012c8:	5d                   	pop    %ebp
f01012c9:	c3                   	ret    
f01012ca:	00 00                	add    %al,(%eax)
f01012cc:	00 00                	add    %al,(%eax)
	...

f01012d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012d0:	55                   	push   %ebp
f01012d1:	89 e5                	mov    %esp,%ebp
f01012d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012db:	80 3a 00             	cmpb   $0x0,(%edx)
f01012de:	74 09                	je     f01012e9 <strlen+0x19>
		n++;
f01012e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012e7:	75 f7                	jne    f01012e0 <strlen+0x10>
		n++;
	return n;
}
f01012e9:	5d                   	pop    %ebp
f01012ea:	c3                   	ret    

f01012eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012eb:	55                   	push   %ebp
f01012ec:	89 e5                	mov    %esp,%ebp
f01012ee:	53                   	push   %ebx
f01012ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01012fa:	85 c9                	test   %ecx,%ecx
f01012fc:	74 1a                	je     f0101318 <strnlen+0x2d>
f01012fe:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101301:	74 15                	je     f0101318 <strnlen+0x2d>
f0101303:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0101308:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010130a:	39 ca                	cmp    %ecx,%edx
f010130c:	74 0a                	je     f0101318 <strnlen+0x2d>
f010130e:	83 c2 01             	add    $0x1,%edx
f0101311:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101316:	75 f0                	jne    f0101308 <strnlen+0x1d>
		n++;
	return n;
}
f0101318:	5b                   	pop    %ebx
f0101319:	5d                   	pop    %ebp
f010131a:	c3                   	ret    

f010131b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010131b:	55                   	push   %ebp
f010131c:	89 e5                	mov    %esp,%ebp
f010131e:	53                   	push   %ebx
f010131f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101322:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101325:	ba 00 00 00 00       	mov    $0x0,%edx
f010132a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010132e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101331:	83 c2 01             	add    $0x1,%edx
f0101334:	84 c9                	test   %cl,%cl
f0101336:	75 f2                	jne    f010132a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101338:	5b                   	pop    %ebx
f0101339:	5d                   	pop    %ebp
f010133a:	c3                   	ret    

f010133b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010133b:	55                   	push   %ebp
f010133c:	89 e5                	mov    %esp,%ebp
f010133e:	53                   	push   %ebx
f010133f:	83 ec 08             	sub    $0x8,%esp
f0101342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101345:	89 1c 24             	mov    %ebx,(%esp)
f0101348:	e8 83 ff ff ff       	call   f01012d0 <strlen>
	strcpy(dst + len, src);
f010134d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101350:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101354:	01 d8                	add    %ebx,%eax
f0101356:	89 04 24             	mov    %eax,(%esp)
f0101359:	e8 bd ff ff ff       	call   f010131b <strcpy>
	return dst;
}
f010135e:	89 d8                	mov    %ebx,%eax
f0101360:	83 c4 08             	add    $0x8,%esp
f0101363:	5b                   	pop    %ebx
f0101364:	5d                   	pop    %ebp
f0101365:	c3                   	ret    

f0101366 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101366:	55                   	push   %ebp
f0101367:	89 e5                	mov    %esp,%ebp
f0101369:	56                   	push   %esi
f010136a:	53                   	push   %ebx
f010136b:	8b 45 08             	mov    0x8(%ebp),%eax
f010136e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101371:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101374:	85 f6                	test   %esi,%esi
f0101376:	74 18                	je     f0101390 <strncpy+0x2a>
f0101378:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010137d:	0f b6 1a             	movzbl (%edx),%ebx
f0101380:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101383:	80 3a 01             	cmpb   $0x1,(%edx)
f0101386:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101389:	83 c1 01             	add    $0x1,%ecx
f010138c:	39 f1                	cmp    %esi,%ecx
f010138e:	75 ed                	jne    f010137d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101390:	5b                   	pop    %ebx
f0101391:	5e                   	pop    %esi
f0101392:	5d                   	pop    %ebp
f0101393:	c3                   	ret    

f0101394 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101394:	55                   	push   %ebp
f0101395:	89 e5                	mov    %esp,%ebp
f0101397:	57                   	push   %edi
f0101398:	56                   	push   %esi
f0101399:	53                   	push   %ebx
f010139a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010139d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013a0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013a3:	89 f8                	mov    %edi,%eax
f01013a5:	85 f6                	test   %esi,%esi
f01013a7:	74 2b                	je     f01013d4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01013a9:	83 fe 01             	cmp    $0x1,%esi
f01013ac:	74 23                	je     f01013d1 <strlcpy+0x3d>
f01013ae:	0f b6 0b             	movzbl (%ebx),%ecx
f01013b1:	84 c9                	test   %cl,%cl
f01013b3:	74 1c                	je     f01013d1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01013b5:	83 ee 02             	sub    $0x2,%esi
f01013b8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013bd:	88 08                	mov    %cl,(%eax)
f01013bf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013c2:	39 f2                	cmp    %esi,%edx
f01013c4:	74 0b                	je     f01013d1 <strlcpy+0x3d>
f01013c6:	83 c2 01             	add    $0x1,%edx
f01013c9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01013cd:	84 c9                	test   %cl,%cl
f01013cf:	75 ec                	jne    f01013bd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01013d1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013d4:	29 f8                	sub    %edi,%eax
}
f01013d6:	5b                   	pop    %ebx
f01013d7:	5e                   	pop    %esi
f01013d8:	5f                   	pop    %edi
f01013d9:	5d                   	pop    %ebp
f01013da:	c3                   	ret    

f01013db <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013db:	55                   	push   %ebp
f01013dc:	89 e5                	mov    %esp,%ebp
f01013de:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013e4:	0f b6 01             	movzbl (%ecx),%eax
f01013e7:	84 c0                	test   %al,%al
f01013e9:	74 16                	je     f0101401 <strcmp+0x26>
f01013eb:	3a 02                	cmp    (%edx),%al
f01013ed:	75 12                	jne    f0101401 <strcmp+0x26>
		p++, q++;
f01013ef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013f2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01013f6:	84 c0                	test   %al,%al
f01013f8:	74 07                	je     f0101401 <strcmp+0x26>
f01013fa:	83 c1 01             	add    $0x1,%ecx
f01013fd:	3a 02                	cmp    (%edx),%al
f01013ff:	74 ee                	je     f01013ef <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101401:	0f b6 c0             	movzbl %al,%eax
f0101404:	0f b6 12             	movzbl (%edx),%edx
f0101407:	29 d0                	sub    %edx,%eax
}
f0101409:	5d                   	pop    %ebp
f010140a:	c3                   	ret    

f010140b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010140b:	55                   	push   %ebp
f010140c:	89 e5                	mov    %esp,%ebp
f010140e:	53                   	push   %ebx
f010140f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101412:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101415:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101418:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010141d:	85 d2                	test   %edx,%edx
f010141f:	74 28                	je     f0101449 <strncmp+0x3e>
f0101421:	0f b6 01             	movzbl (%ecx),%eax
f0101424:	84 c0                	test   %al,%al
f0101426:	74 24                	je     f010144c <strncmp+0x41>
f0101428:	3a 03                	cmp    (%ebx),%al
f010142a:	75 20                	jne    f010144c <strncmp+0x41>
f010142c:	83 ea 01             	sub    $0x1,%edx
f010142f:	74 13                	je     f0101444 <strncmp+0x39>
		n--, p++, q++;
f0101431:	83 c1 01             	add    $0x1,%ecx
f0101434:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101437:	0f b6 01             	movzbl (%ecx),%eax
f010143a:	84 c0                	test   %al,%al
f010143c:	74 0e                	je     f010144c <strncmp+0x41>
f010143e:	3a 03                	cmp    (%ebx),%al
f0101440:	74 ea                	je     f010142c <strncmp+0x21>
f0101442:	eb 08                	jmp    f010144c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101444:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101449:	5b                   	pop    %ebx
f010144a:	5d                   	pop    %ebp
f010144b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010144c:	0f b6 01             	movzbl (%ecx),%eax
f010144f:	0f b6 13             	movzbl (%ebx),%edx
f0101452:	29 d0                	sub    %edx,%eax
f0101454:	eb f3                	jmp    f0101449 <strncmp+0x3e>

f0101456 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101456:	55                   	push   %ebp
f0101457:	89 e5                	mov    %esp,%ebp
f0101459:	8b 45 08             	mov    0x8(%ebp),%eax
f010145c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101460:	0f b6 10             	movzbl (%eax),%edx
f0101463:	84 d2                	test   %dl,%dl
f0101465:	74 1c                	je     f0101483 <strchr+0x2d>
		if (*s == c)
f0101467:	38 ca                	cmp    %cl,%dl
f0101469:	75 09                	jne    f0101474 <strchr+0x1e>
f010146b:	eb 1b                	jmp    f0101488 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010146d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0101470:	38 ca                	cmp    %cl,%dl
f0101472:	74 14                	je     f0101488 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101474:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0101478:	84 d2                	test   %dl,%dl
f010147a:	75 f1                	jne    f010146d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f010147c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101481:	eb 05                	jmp    f0101488 <strchr+0x32>
f0101483:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101488:	5d                   	pop    %ebp
f0101489:	c3                   	ret    

f010148a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010148a:	55                   	push   %ebp
f010148b:	89 e5                	mov    %esp,%ebp
f010148d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101490:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101494:	0f b6 10             	movzbl (%eax),%edx
f0101497:	84 d2                	test   %dl,%dl
f0101499:	74 14                	je     f01014af <strfind+0x25>
		if (*s == c)
f010149b:	38 ca                	cmp    %cl,%dl
f010149d:	75 06                	jne    f01014a5 <strfind+0x1b>
f010149f:	eb 0e                	jmp    f01014af <strfind+0x25>
f01014a1:	38 ca                	cmp    %cl,%dl
f01014a3:	74 0a                	je     f01014af <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01014a5:	83 c0 01             	add    $0x1,%eax
f01014a8:	0f b6 10             	movzbl (%eax),%edx
f01014ab:	84 d2                	test   %dl,%dl
f01014ad:	75 f2                	jne    f01014a1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01014af:	5d                   	pop    %ebp
f01014b0:	c3                   	ret    

f01014b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014b1:	55                   	push   %ebp
f01014b2:	89 e5                	mov    %esp,%ebp
f01014b4:	83 ec 0c             	sub    $0xc,%esp
f01014b7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01014ba:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01014bd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01014c0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014c9:	85 c9                	test   %ecx,%ecx
f01014cb:	74 30                	je     f01014fd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014d3:	75 25                	jne    f01014fa <memset+0x49>
f01014d5:	f6 c1 03             	test   $0x3,%cl
f01014d8:	75 20                	jne    f01014fa <memset+0x49>
		c &= 0xFF;
f01014da:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014dd:	89 d3                	mov    %edx,%ebx
f01014df:	c1 e3 08             	shl    $0x8,%ebx
f01014e2:	89 d6                	mov    %edx,%esi
f01014e4:	c1 e6 18             	shl    $0x18,%esi
f01014e7:	89 d0                	mov    %edx,%eax
f01014e9:	c1 e0 10             	shl    $0x10,%eax
f01014ec:	09 f0                	or     %esi,%eax
f01014ee:	09 d0                	or     %edx,%eax
f01014f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01014f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01014f5:	fc                   	cld    
f01014f6:	f3 ab                	rep stos %eax,%es:(%edi)
f01014f8:	eb 03                	jmp    f01014fd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014fa:	fc                   	cld    
f01014fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014fd:	89 f8                	mov    %edi,%eax
f01014ff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101502:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101505:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101508:	89 ec                	mov    %ebp,%esp
f010150a:	5d                   	pop    %ebp
f010150b:	c3                   	ret    

f010150c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010150c:	55                   	push   %ebp
f010150d:	89 e5                	mov    %esp,%ebp
f010150f:	83 ec 08             	sub    $0x8,%esp
f0101512:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101515:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101518:	8b 45 08             	mov    0x8(%ebp),%eax
f010151b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010151e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101521:	39 c6                	cmp    %eax,%esi
f0101523:	73 36                	jae    f010155b <memmove+0x4f>
f0101525:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101528:	39 d0                	cmp    %edx,%eax
f010152a:	73 2f                	jae    f010155b <memmove+0x4f>
		s += n;
		d += n;
f010152c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010152f:	f6 c2 03             	test   $0x3,%dl
f0101532:	75 1b                	jne    f010154f <memmove+0x43>
f0101534:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010153a:	75 13                	jne    f010154f <memmove+0x43>
f010153c:	f6 c1 03             	test   $0x3,%cl
f010153f:	75 0e                	jne    f010154f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101541:	83 ef 04             	sub    $0x4,%edi
f0101544:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101547:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010154a:	fd                   	std    
f010154b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010154d:	eb 09                	jmp    f0101558 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010154f:	83 ef 01             	sub    $0x1,%edi
f0101552:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101555:	fd                   	std    
f0101556:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101558:	fc                   	cld    
f0101559:	eb 20                	jmp    f010157b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010155b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101561:	75 13                	jne    f0101576 <memmove+0x6a>
f0101563:	a8 03                	test   $0x3,%al
f0101565:	75 0f                	jne    f0101576 <memmove+0x6a>
f0101567:	f6 c1 03             	test   $0x3,%cl
f010156a:	75 0a                	jne    f0101576 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010156c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010156f:	89 c7                	mov    %eax,%edi
f0101571:	fc                   	cld    
f0101572:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101574:	eb 05                	jmp    f010157b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101576:	89 c7                	mov    %eax,%edi
f0101578:	fc                   	cld    
f0101579:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010157b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010157e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101581:	89 ec                	mov    %ebp,%esp
f0101583:	5d                   	pop    %ebp
f0101584:	c3                   	ret    

f0101585 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101585:	55                   	push   %ebp
f0101586:	89 e5                	mov    %esp,%ebp
f0101588:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010158b:	8b 45 10             	mov    0x10(%ebp),%eax
f010158e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101592:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101595:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101599:	8b 45 08             	mov    0x8(%ebp),%eax
f010159c:	89 04 24             	mov    %eax,(%esp)
f010159f:	e8 68 ff ff ff       	call   f010150c <memmove>
}
f01015a4:	c9                   	leave  
f01015a5:	c3                   	ret    

f01015a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01015a6:	55                   	push   %ebp
f01015a7:	89 e5                	mov    %esp,%ebp
f01015a9:	57                   	push   %edi
f01015aa:	56                   	push   %esi
f01015ab:	53                   	push   %ebx
f01015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01015af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015b2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015b5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015ba:	85 ff                	test   %edi,%edi
f01015bc:	74 37                	je     f01015f5 <memcmp+0x4f>
		if (*s1 != *s2)
f01015be:	0f b6 03             	movzbl (%ebx),%eax
f01015c1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015c4:	83 ef 01             	sub    $0x1,%edi
f01015c7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f01015cc:	38 c8                	cmp    %cl,%al
f01015ce:	74 1c                	je     f01015ec <memcmp+0x46>
f01015d0:	eb 10                	jmp    f01015e2 <memcmp+0x3c>
f01015d2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01015d7:	83 c2 01             	add    $0x1,%edx
f01015da:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01015de:	38 c8                	cmp    %cl,%al
f01015e0:	74 0a                	je     f01015ec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f01015e2:	0f b6 c0             	movzbl %al,%eax
f01015e5:	0f b6 c9             	movzbl %cl,%ecx
f01015e8:	29 c8                	sub    %ecx,%eax
f01015ea:	eb 09                	jmp    f01015f5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015ec:	39 fa                	cmp    %edi,%edx
f01015ee:	75 e2                	jne    f01015d2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015f5:	5b                   	pop    %ebx
f01015f6:	5e                   	pop    %esi
f01015f7:	5f                   	pop    %edi
f01015f8:	5d                   	pop    %ebp
f01015f9:	c3                   	ret    

f01015fa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015fa:	55                   	push   %ebp
f01015fb:	89 e5                	mov    %esp,%ebp
f01015fd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101600:	89 c2                	mov    %eax,%edx
f0101602:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101605:	39 d0                	cmp    %edx,%eax
f0101607:	73 19                	jae    f0101622 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101609:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010160d:	38 08                	cmp    %cl,(%eax)
f010160f:	75 06                	jne    f0101617 <memfind+0x1d>
f0101611:	eb 0f                	jmp    f0101622 <memfind+0x28>
f0101613:	38 08                	cmp    %cl,(%eax)
f0101615:	74 0b                	je     f0101622 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101617:	83 c0 01             	add    $0x1,%eax
f010161a:	39 d0                	cmp    %edx,%eax
f010161c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101620:	75 f1                	jne    f0101613 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101622:	5d                   	pop    %ebp
f0101623:	c3                   	ret    

f0101624 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101624:	55                   	push   %ebp
f0101625:	89 e5                	mov    %esp,%ebp
f0101627:	57                   	push   %edi
f0101628:	56                   	push   %esi
f0101629:	53                   	push   %ebx
f010162a:	8b 55 08             	mov    0x8(%ebp),%edx
f010162d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101630:	0f b6 02             	movzbl (%edx),%eax
f0101633:	3c 20                	cmp    $0x20,%al
f0101635:	74 04                	je     f010163b <strtol+0x17>
f0101637:	3c 09                	cmp    $0x9,%al
f0101639:	75 0e                	jne    f0101649 <strtol+0x25>
		s++;
f010163b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010163e:	0f b6 02             	movzbl (%edx),%eax
f0101641:	3c 20                	cmp    $0x20,%al
f0101643:	74 f6                	je     f010163b <strtol+0x17>
f0101645:	3c 09                	cmp    $0x9,%al
f0101647:	74 f2                	je     f010163b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101649:	3c 2b                	cmp    $0x2b,%al
f010164b:	75 0a                	jne    f0101657 <strtol+0x33>
		s++;
f010164d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101650:	bf 00 00 00 00       	mov    $0x0,%edi
f0101655:	eb 10                	jmp    f0101667 <strtol+0x43>
f0101657:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010165c:	3c 2d                	cmp    $0x2d,%al
f010165e:	75 07                	jne    f0101667 <strtol+0x43>
		s++, neg = 1;
f0101660:	83 c2 01             	add    $0x1,%edx
f0101663:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101667:	85 db                	test   %ebx,%ebx
f0101669:	0f 94 c0             	sete   %al
f010166c:	74 05                	je     f0101673 <strtol+0x4f>
f010166e:	83 fb 10             	cmp    $0x10,%ebx
f0101671:	75 15                	jne    f0101688 <strtol+0x64>
f0101673:	80 3a 30             	cmpb   $0x30,(%edx)
f0101676:	75 10                	jne    f0101688 <strtol+0x64>
f0101678:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010167c:	75 0a                	jne    f0101688 <strtol+0x64>
		s += 2, base = 16;
f010167e:	83 c2 02             	add    $0x2,%edx
f0101681:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101686:	eb 13                	jmp    f010169b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101688:	84 c0                	test   %al,%al
f010168a:	74 0f                	je     f010169b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010168c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101691:	80 3a 30             	cmpb   $0x30,(%edx)
f0101694:	75 05                	jne    f010169b <strtol+0x77>
		s++, base = 8;
f0101696:	83 c2 01             	add    $0x1,%edx
f0101699:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010169b:	b8 00 00 00 00       	mov    $0x0,%eax
f01016a0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01016a2:	0f b6 0a             	movzbl (%edx),%ecx
f01016a5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01016a8:	80 fb 09             	cmp    $0x9,%bl
f01016ab:	77 08                	ja     f01016b5 <strtol+0x91>
			dig = *s - '0';
f01016ad:	0f be c9             	movsbl %cl,%ecx
f01016b0:	83 e9 30             	sub    $0x30,%ecx
f01016b3:	eb 1e                	jmp    f01016d3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01016b5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01016b8:	80 fb 19             	cmp    $0x19,%bl
f01016bb:	77 08                	ja     f01016c5 <strtol+0xa1>
			dig = *s - 'a' + 10;
f01016bd:	0f be c9             	movsbl %cl,%ecx
f01016c0:	83 e9 57             	sub    $0x57,%ecx
f01016c3:	eb 0e                	jmp    f01016d3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f01016c5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01016c8:	80 fb 19             	cmp    $0x19,%bl
f01016cb:	77 14                	ja     f01016e1 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01016cd:	0f be c9             	movsbl %cl,%ecx
f01016d0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01016d3:	39 f1                	cmp    %esi,%ecx
f01016d5:	7d 0e                	jge    f01016e5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01016d7:	83 c2 01             	add    $0x1,%edx
f01016da:	0f af c6             	imul   %esi,%eax
f01016dd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01016df:	eb c1                	jmp    f01016a2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01016e1:	89 c1                	mov    %eax,%ecx
f01016e3:	eb 02                	jmp    f01016e7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01016e5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01016e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016eb:	74 05                	je     f01016f2 <strtol+0xce>
		*endptr = (char *) s;
f01016ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016f0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01016f2:	89 ca                	mov    %ecx,%edx
f01016f4:	f7 da                	neg    %edx
f01016f6:	85 ff                	test   %edi,%edi
f01016f8:	0f 45 c2             	cmovne %edx,%eax
}
f01016fb:	5b                   	pop    %ebx
f01016fc:	5e                   	pop    %esi
f01016fd:	5f                   	pop    %edi
f01016fe:	5d                   	pop    %ebp
f01016ff:	c3                   	ret    

f0101700 <__udivdi3>:
f0101700:	83 ec 1c             	sub    $0x1c,%esp
f0101703:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101707:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010170b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010170f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101713:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101717:	8b 74 24 24          	mov    0x24(%esp),%esi
f010171b:	85 ff                	test   %edi,%edi
f010171d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101721:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101725:	89 cd                	mov    %ecx,%ebp
f0101727:	89 44 24 04          	mov    %eax,0x4(%esp)
f010172b:	75 33                	jne    f0101760 <__udivdi3+0x60>
f010172d:	39 f1                	cmp    %esi,%ecx
f010172f:	77 57                	ja     f0101788 <__udivdi3+0x88>
f0101731:	85 c9                	test   %ecx,%ecx
f0101733:	75 0b                	jne    f0101740 <__udivdi3+0x40>
f0101735:	b8 01 00 00 00       	mov    $0x1,%eax
f010173a:	31 d2                	xor    %edx,%edx
f010173c:	f7 f1                	div    %ecx
f010173e:	89 c1                	mov    %eax,%ecx
f0101740:	89 f0                	mov    %esi,%eax
f0101742:	31 d2                	xor    %edx,%edx
f0101744:	f7 f1                	div    %ecx
f0101746:	89 c6                	mov    %eax,%esi
f0101748:	8b 44 24 04          	mov    0x4(%esp),%eax
f010174c:	f7 f1                	div    %ecx
f010174e:	89 f2                	mov    %esi,%edx
f0101750:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101754:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101758:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010175c:	83 c4 1c             	add    $0x1c,%esp
f010175f:	c3                   	ret    
f0101760:	31 d2                	xor    %edx,%edx
f0101762:	31 c0                	xor    %eax,%eax
f0101764:	39 f7                	cmp    %esi,%edi
f0101766:	77 e8                	ja     f0101750 <__udivdi3+0x50>
f0101768:	0f bd cf             	bsr    %edi,%ecx
f010176b:	83 f1 1f             	xor    $0x1f,%ecx
f010176e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101772:	75 2c                	jne    f01017a0 <__udivdi3+0xa0>
f0101774:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0101778:	76 04                	jbe    f010177e <__udivdi3+0x7e>
f010177a:	39 f7                	cmp    %esi,%edi
f010177c:	73 d2                	jae    f0101750 <__udivdi3+0x50>
f010177e:	31 d2                	xor    %edx,%edx
f0101780:	b8 01 00 00 00       	mov    $0x1,%eax
f0101785:	eb c9                	jmp    f0101750 <__udivdi3+0x50>
f0101787:	90                   	nop
f0101788:	89 f2                	mov    %esi,%edx
f010178a:	f7 f1                	div    %ecx
f010178c:	31 d2                	xor    %edx,%edx
f010178e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101792:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101796:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010179a:	83 c4 1c             	add    $0x1c,%esp
f010179d:	c3                   	ret    
f010179e:	66 90                	xchg   %ax,%ax
f01017a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01017a5:	b8 20 00 00 00       	mov    $0x20,%eax
f01017aa:	89 ea                	mov    %ebp,%edx
f01017ac:	2b 44 24 04          	sub    0x4(%esp),%eax
f01017b0:	d3 e7                	shl    %cl,%edi
f01017b2:	89 c1                	mov    %eax,%ecx
f01017b4:	d3 ea                	shr    %cl,%edx
f01017b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01017bb:	09 fa                	or     %edi,%edx
f01017bd:	89 f7                	mov    %esi,%edi
f01017bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01017c3:	89 f2                	mov    %esi,%edx
f01017c5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01017c9:	d3 e5                	shl    %cl,%ebp
f01017cb:	89 c1                	mov    %eax,%ecx
f01017cd:	d3 ef                	shr    %cl,%edi
f01017cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01017d4:	d3 e2                	shl    %cl,%edx
f01017d6:	89 c1                	mov    %eax,%ecx
f01017d8:	d3 ee                	shr    %cl,%esi
f01017da:	09 d6                	or     %edx,%esi
f01017dc:	89 fa                	mov    %edi,%edx
f01017de:	89 f0                	mov    %esi,%eax
f01017e0:	f7 74 24 0c          	divl   0xc(%esp)
f01017e4:	89 d7                	mov    %edx,%edi
f01017e6:	89 c6                	mov    %eax,%esi
f01017e8:	f7 e5                	mul    %ebp
f01017ea:	39 d7                	cmp    %edx,%edi
f01017ec:	72 22                	jb     f0101810 <__udivdi3+0x110>
f01017ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01017f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01017f7:	d3 e5                	shl    %cl,%ebp
f01017f9:	39 c5                	cmp    %eax,%ebp
f01017fb:	73 04                	jae    f0101801 <__udivdi3+0x101>
f01017fd:	39 d7                	cmp    %edx,%edi
f01017ff:	74 0f                	je     f0101810 <__udivdi3+0x110>
f0101801:	89 f0                	mov    %esi,%eax
f0101803:	31 d2                	xor    %edx,%edx
f0101805:	e9 46 ff ff ff       	jmp    f0101750 <__udivdi3+0x50>
f010180a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101810:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101813:	31 d2                	xor    %edx,%edx
f0101815:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101819:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010181d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101821:	83 c4 1c             	add    $0x1c,%esp
f0101824:	c3                   	ret    
	...

f0101830 <__umoddi3>:
f0101830:	83 ec 1c             	sub    $0x1c,%esp
f0101833:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101837:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010183b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010183f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101843:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101847:	8b 74 24 24          	mov    0x24(%esp),%esi
f010184b:	85 ed                	test   %ebp,%ebp
f010184d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101851:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101855:	89 cf                	mov    %ecx,%edi
f0101857:	89 04 24             	mov    %eax,(%esp)
f010185a:	89 f2                	mov    %esi,%edx
f010185c:	75 1a                	jne    f0101878 <__umoddi3+0x48>
f010185e:	39 f1                	cmp    %esi,%ecx
f0101860:	76 4e                	jbe    f01018b0 <__umoddi3+0x80>
f0101862:	f7 f1                	div    %ecx
f0101864:	89 d0                	mov    %edx,%eax
f0101866:	31 d2                	xor    %edx,%edx
f0101868:	8b 74 24 10          	mov    0x10(%esp),%esi
f010186c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101870:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101874:	83 c4 1c             	add    $0x1c,%esp
f0101877:	c3                   	ret    
f0101878:	39 f5                	cmp    %esi,%ebp
f010187a:	77 54                	ja     f01018d0 <__umoddi3+0xa0>
f010187c:	0f bd c5             	bsr    %ebp,%eax
f010187f:	83 f0 1f             	xor    $0x1f,%eax
f0101882:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101886:	75 60                	jne    f01018e8 <__umoddi3+0xb8>
f0101888:	3b 0c 24             	cmp    (%esp),%ecx
f010188b:	0f 87 07 01 00 00    	ja     f0101998 <__umoddi3+0x168>
f0101891:	89 f2                	mov    %esi,%edx
f0101893:	8b 34 24             	mov    (%esp),%esi
f0101896:	29 ce                	sub    %ecx,%esi
f0101898:	19 ea                	sbb    %ebp,%edx
f010189a:	89 34 24             	mov    %esi,(%esp)
f010189d:	8b 04 24             	mov    (%esp),%eax
f01018a0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01018a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01018a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01018ac:	83 c4 1c             	add    $0x1c,%esp
f01018af:	c3                   	ret    
f01018b0:	85 c9                	test   %ecx,%ecx
f01018b2:	75 0b                	jne    f01018bf <__umoddi3+0x8f>
f01018b4:	b8 01 00 00 00       	mov    $0x1,%eax
f01018b9:	31 d2                	xor    %edx,%edx
f01018bb:	f7 f1                	div    %ecx
f01018bd:	89 c1                	mov    %eax,%ecx
f01018bf:	89 f0                	mov    %esi,%eax
f01018c1:	31 d2                	xor    %edx,%edx
f01018c3:	f7 f1                	div    %ecx
f01018c5:	8b 04 24             	mov    (%esp),%eax
f01018c8:	f7 f1                	div    %ecx
f01018ca:	eb 98                	jmp    f0101864 <__umoddi3+0x34>
f01018cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018d0:	89 f2                	mov    %esi,%edx
f01018d2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01018d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01018da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01018de:	83 c4 1c             	add    $0x1c,%esp
f01018e1:	c3                   	ret    
f01018e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01018ed:	89 e8                	mov    %ebp,%eax
f01018ef:	bd 20 00 00 00       	mov    $0x20,%ebp
f01018f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01018f8:	89 fa                	mov    %edi,%edx
f01018fa:	d3 e0                	shl    %cl,%eax
f01018fc:	89 e9                	mov    %ebp,%ecx
f01018fe:	d3 ea                	shr    %cl,%edx
f0101900:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101905:	09 c2                	or     %eax,%edx
f0101907:	8b 44 24 08          	mov    0x8(%esp),%eax
f010190b:	89 14 24             	mov    %edx,(%esp)
f010190e:	89 f2                	mov    %esi,%edx
f0101910:	d3 e7                	shl    %cl,%edi
f0101912:	89 e9                	mov    %ebp,%ecx
f0101914:	d3 ea                	shr    %cl,%edx
f0101916:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010191b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010191f:	d3 e6                	shl    %cl,%esi
f0101921:	89 e9                	mov    %ebp,%ecx
f0101923:	d3 e8                	shr    %cl,%eax
f0101925:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010192a:	09 f0                	or     %esi,%eax
f010192c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101930:	f7 34 24             	divl   (%esp)
f0101933:	d3 e6                	shl    %cl,%esi
f0101935:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101939:	89 d6                	mov    %edx,%esi
f010193b:	f7 e7                	mul    %edi
f010193d:	39 d6                	cmp    %edx,%esi
f010193f:	89 c1                	mov    %eax,%ecx
f0101941:	89 d7                	mov    %edx,%edi
f0101943:	72 3f                	jb     f0101984 <__umoddi3+0x154>
f0101945:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101949:	72 35                	jb     f0101980 <__umoddi3+0x150>
f010194b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010194f:	29 c8                	sub    %ecx,%eax
f0101951:	19 fe                	sbb    %edi,%esi
f0101953:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101958:	89 f2                	mov    %esi,%edx
f010195a:	d3 e8                	shr    %cl,%eax
f010195c:	89 e9                	mov    %ebp,%ecx
f010195e:	d3 e2                	shl    %cl,%edx
f0101960:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101965:	09 d0                	or     %edx,%eax
f0101967:	89 f2                	mov    %esi,%edx
f0101969:	d3 ea                	shr    %cl,%edx
f010196b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010196f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101973:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101977:	83 c4 1c             	add    $0x1c,%esp
f010197a:	c3                   	ret    
f010197b:	90                   	nop
f010197c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101980:	39 d6                	cmp    %edx,%esi
f0101982:	75 c7                	jne    f010194b <__umoddi3+0x11b>
f0101984:	89 d7                	mov    %edx,%edi
f0101986:	89 c1                	mov    %eax,%ecx
f0101988:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010198c:	1b 3c 24             	sbb    (%esp),%edi
f010198f:	eb ba                	jmp    f010194b <__umoddi3+0x11b>
f0101991:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101998:	39 f5                	cmp    %esi,%ebp
f010199a:	0f 82 f1 fe ff ff    	jb     f0101891 <__umoddi3+0x61>
f01019a0:	e9 f8 fe ff ff       	jmp    f010189d <__umoddi3+0x6d>
