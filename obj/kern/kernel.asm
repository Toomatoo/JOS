
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 49 11 f0       	mov    $0xf0114990,%eax
f010004b:	2d 08 43 11 f0       	sub    $0xf0114308,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 08 43 11 f0 	movl   $0xf0114308,(%esp)
f0100063:	e8 89 1e 00 00       	call   f0101ef1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 8e 04 00 00       	call   f01004fb <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 00 24 10 f0 	movl   $0xf0102400,(%esp)
f010007c:	e8 89 11 00 00       	call   f010120a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 62 0f 00 00       	call   f0100fe8 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 f0 07 00 00       	call   f0100882 <monitor>
f0100092:	eb f2                	jmp    f0100086 <i386_init+0x46>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	83 ec 10             	sub    $0x10,%esp
f010009c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009f:	83 3d 80 49 11 f0 00 	cmpl   $0x0,0xf0114980
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 80 49 11 f0    	mov    %esi,0xf0114980

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ae:	fa                   	cli    
f01000af:	fc                   	cld    

	va_start(ap, fmt);
f01000b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01000bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c1:	c7 04 24 1b 24 10 f0 	movl   $0xf010241b,(%esp)
f01000c8:	e8 3d 11 00 00       	call   f010120a <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 fe 10 00 00       	call   f01011d7 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 57 24 10 f0 	movl   $0xf0102457,(%esp)
f01000e0:	e8 25 11 00 00       	call   f010120a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 91 07 00 00       	call   f0100882 <monitor>
f01000f1:	eb f2                	jmp    f01000e5 <_panic+0x51>

f01000f3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f3:	55                   	push   %ebp
f01000f4:	89 e5                	mov    %esp,%ebp
f01000f6:	53                   	push   %ebx
f01000f7:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fa:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100100:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100104:	8b 45 08             	mov    0x8(%ebp),%eax
f0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010b:	c7 04 24 33 24 10 f0 	movl   $0xf0102433,(%esp)
f0100112:	e8 f3 10 00 00       	call   f010120a <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 b1 10 00 00       	call   f01011d7 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 57 24 10 f0 	movl   $0xf0102457,(%esp)
f010012d:	e8 d8 10 00 00       	call   f010120a <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    
	...

f0100140 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100140:	55                   	push   %ebp
f0100141:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100143:	ba 84 00 00 00       	mov    $0x84,%edx
f0100148:	ec                   	in     (%dx),%al
f0100149:	ec                   	in     (%dx),%al
f010014a:	ec                   	in     (%dx),%al
f010014b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010014c:	5d                   	pop    %ebp
f010014d:	c3                   	ret    

f010014e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010014e:	55                   	push   %ebp
f010014f:	89 e5                	mov    %esp,%ebp
f0100151:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100156:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100157:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015c:	a8 01                	test   $0x1,%al
f010015e:	74 06                	je     f0100166 <serial_proc_data+0x18>
f0100160:	b2 f8                	mov    $0xf8,%dl
f0100162:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100163:	0f b6 c8             	movzbl %al,%ecx
}
f0100166:	89 c8                	mov    %ecx,%eax
f0100168:	5d                   	pop    %ebp
f0100169:	c3                   	ret    

f010016a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010016a:	55                   	push   %ebp
f010016b:	89 e5                	mov    %esp,%ebp
f010016d:	53                   	push   %ebx
f010016e:	83 ec 04             	sub    $0x4,%esp
f0100171:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100173:	eb 25                	jmp    f010019a <cons_intr+0x30>
		if (c == 0)
f0100175:	85 c0                	test   %eax,%eax
f0100177:	74 21                	je     f010019a <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f0100179:	8b 15 44 45 11 f0    	mov    0xf0114544,%edx
f010017f:	88 82 40 43 11 f0    	mov    %al,-0xfeebcc0(%edx)
f0100185:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100188:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010018d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100192:	0f 44 c2             	cmove  %edx,%eax
f0100195:	a3 44 45 11 f0       	mov    %eax,0xf0114544
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010019a:	ff d3                	call   *%ebx
f010019c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010019f:	75 d4                	jne    f0100175 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001a1:	83 c4 04             	add    $0x4,%esp
f01001a4:	5b                   	pop    %ebx
f01001a5:	5d                   	pop    %ebp
f01001a6:	c3                   	ret    

f01001a7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001a7:	55                   	push   %ebp
f01001a8:	89 e5                	mov    %esp,%ebp
f01001aa:	57                   	push   %edi
f01001ab:	56                   	push   %esi
f01001ac:	53                   	push   %ebx
f01001ad:	83 ec 2c             	sub    $0x2c,%esp
f01001b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01001b3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b8:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001b9:	a8 20                	test   $0x20,%al
f01001bb:	75 1b                	jne    f01001d8 <cons_putc+0x31>
f01001bd:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001c2:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001c7:	e8 74 ff ff ff       	call   f0100140 <delay>
f01001cc:	89 f2                	mov    %esi,%edx
f01001ce:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001cf:	a8 20                	test   $0x20,%al
f01001d1:	75 05                	jne    f01001d8 <cons_putc+0x31>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001d3:	83 eb 01             	sub    $0x1,%ebx
f01001d6:	75 ef                	jne    f01001c7 <cons_putc+0x20>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001d8:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e1:	89 f8                	mov    %edi,%eax
f01001e3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e4:	b2 79                	mov    $0x79,%dl
f01001e6:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001e7:	84 c0                	test   %al,%al
f01001e9:	78 1b                	js     f0100206 <cons_putc+0x5f>
f01001eb:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001f0:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01001f5:	e8 46 ff ff ff       	call   f0100140 <delay>
f01001fa:	89 f2                	mov    %esi,%edx
f01001fc:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001fd:	84 c0                	test   %al,%al
f01001ff:	78 05                	js     f0100206 <cons_putc+0x5f>
f0100201:	83 eb 01             	sub    $0x1,%ebx
f0100204:	75 ef                	jne    f01001f5 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100206:	ba 78 03 00 00       	mov    $0x378,%edx
f010020b:	89 f8                	mov    %edi,%eax
f010020d:	ee                   	out    %al,(%dx)
f010020e:	b2 7a                	mov    $0x7a,%dl
f0100210:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100215:	ee                   	out    %al,(%dx)
f0100216:	b8 08 00 00 00       	mov    $0x8,%eax
f010021b:	ee                   	out    %al,(%dx)
extern int ncolor;

static void
cga_putc(int c)
{
	c = c + (ncolor << 8);
f010021c:	a1 04 43 11 f0       	mov    0xf0114304,%eax
f0100221:	c1 e0 08             	shl    $0x8,%eax
f0100224:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100227:	89 c1                	mov    %eax,%ecx
f0100229:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f010022f:	89 c2                	mov    %eax,%edx
f0100231:	80 ce 07             	or     $0x7,%dh
f0100234:	85 c9                	test   %ecx,%ecx
f0100236:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f0100239:	0f b6 d0             	movzbl %al,%edx
f010023c:	83 fa 09             	cmp    $0x9,%edx
f010023f:	74 75                	je     f01002b6 <cons_putc+0x10f>
f0100241:	83 fa 09             	cmp    $0x9,%edx
f0100244:	7f 0c                	jg     f0100252 <cons_putc+0xab>
f0100246:	83 fa 08             	cmp    $0x8,%edx
f0100249:	0f 85 9b 00 00 00    	jne    f01002ea <cons_putc+0x143>
f010024f:	90                   	nop
f0100250:	eb 10                	jmp    f0100262 <cons_putc+0xbb>
f0100252:	83 fa 0a             	cmp    $0xa,%edx
f0100255:	74 39                	je     f0100290 <cons_putc+0xe9>
f0100257:	83 fa 0d             	cmp    $0xd,%edx
f010025a:	0f 85 8a 00 00 00    	jne    f01002ea <cons_putc+0x143>
f0100260:	eb 36                	jmp    f0100298 <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f0100262:	0f b7 15 54 45 11 f0 	movzwl 0xf0114554,%edx
f0100269:	66 85 d2             	test   %dx,%dx
f010026c:	0f 84 e3 00 00 00    	je     f0100355 <cons_putc+0x1ae>
			crt_pos--;
f0100272:	83 ea 01             	sub    $0x1,%edx
f0100275:	66 89 15 54 45 11 f0 	mov    %dx,0xf0114554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010027c:	0f b7 d2             	movzwl %dx,%edx
f010027f:	b0 00                	mov    $0x0,%al
f0100281:	83 c8 20             	or     $0x20,%eax
f0100284:	8b 0d 50 45 11 f0    	mov    0xf0114550,%ecx
f010028a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010028e:	eb 78                	jmp    f0100308 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100290:	66 83 05 54 45 11 f0 	addw   $0x50,0xf0114554
f0100297:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100298:	0f b7 05 54 45 11 f0 	movzwl 0xf0114554,%eax
f010029f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002a5:	c1 e8 16             	shr    $0x16,%eax
f01002a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002ab:	c1 e0 04             	shl    $0x4,%eax
f01002ae:	66 a3 54 45 11 f0    	mov    %ax,0xf0114554
f01002b4:	eb 52                	jmp    f0100308 <cons_putc+0x161>
		break;
	case '\t':
		cons_putc(' ');
f01002b6:	b8 20 00 00 00       	mov    $0x20,%eax
f01002bb:	e8 e7 fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c5:	e8 dd fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002ca:	b8 20 00 00 00       	mov    $0x20,%eax
f01002cf:	e8 d3 fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d9:	e8 c9 fe ff ff       	call   f01001a7 <cons_putc>
		cons_putc(' ');
f01002de:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e3:	e8 bf fe ff ff       	call   f01001a7 <cons_putc>
f01002e8:	eb 1e                	jmp    f0100308 <cons_putc+0x161>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002ea:	0f b7 15 54 45 11 f0 	movzwl 0xf0114554,%edx
f01002f1:	0f b7 da             	movzwl %dx,%ebx
f01002f4:	8b 0d 50 45 11 f0    	mov    0xf0114550,%ecx
f01002fa:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01002fe:	83 c2 01             	add    $0x1,%edx
f0100301:	66 89 15 54 45 11 f0 	mov    %dx,0xf0114554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100308:	66 81 3d 54 45 11 f0 	cmpw   $0x7cf,0xf0114554
f010030f:	cf 07 
f0100311:	76 42                	jbe    f0100355 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100313:	a1 50 45 11 f0       	mov    0xf0114550,%eax
f0100318:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010031f:	00 
f0100320:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100326:	89 54 24 04          	mov    %edx,0x4(%esp)
f010032a:	89 04 24             	mov    %eax,(%esp)
f010032d:	e8 1a 1c 00 00       	call   f0101f4c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100332:	8b 15 50 45 11 f0    	mov    0xf0114550,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100338:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010033d:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100343:	83 c0 01             	add    $0x1,%eax
f0100346:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010034b:	75 f0                	jne    f010033d <cons_putc+0x196>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010034d:	66 83 2d 54 45 11 f0 	subw   $0x50,0xf0114554
f0100354:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100355:	8b 0d 4c 45 11 f0    	mov    0xf011454c,%ecx
f010035b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100360:	89 ca                	mov    %ecx,%edx
f0100362:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100363:	0f b7 35 54 45 11 f0 	movzwl 0xf0114554,%esi
f010036a:	8d 59 01             	lea    0x1(%ecx),%ebx
f010036d:	89 f0                	mov    %esi,%eax
f010036f:	66 c1 e8 08          	shr    $0x8,%ax
f0100373:	89 da                	mov    %ebx,%edx
f0100375:	ee                   	out    %al,(%dx)
f0100376:	b8 0f 00 00 00       	mov    $0xf,%eax
f010037b:	89 ca                	mov    %ecx,%edx
f010037d:	ee                   	out    %al,(%dx)
f010037e:	89 f0                	mov    %esi,%eax
f0100380:	89 da                	mov    %ebx,%edx
f0100382:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100383:	83 c4 2c             	add    $0x2c,%esp
f0100386:	5b                   	pop    %ebx
f0100387:	5e                   	pop    %esi
f0100388:	5f                   	pop    %edi
f0100389:	5d                   	pop    %ebp
f010038a:	c3                   	ret    

f010038b <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010038b:	55                   	push   %ebp
f010038c:	89 e5                	mov    %esp,%ebp
f010038e:	53                   	push   %ebx
f010038f:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100392:	ba 64 00 00 00       	mov    $0x64,%edx
f0100397:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100398:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010039d:	a8 01                	test   $0x1,%al
f010039f:	0f 84 de 00 00 00    	je     f0100483 <kbd_proc_data+0xf8>
f01003a5:	b2 60                	mov    $0x60,%dl
f01003a7:	ec                   	in     (%dx),%al
f01003a8:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003aa:	3c e0                	cmp    $0xe0,%al
f01003ac:	75 11                	jne    f01003bf <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f01003ae:	83 0d 48 45 11 f0 40 	orl    $0x40,0xf0114548
		return 0;
f01003b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ba:	e9 c4 00 00 00       	jmp    f0100483 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003bf:	84 c0                	test   %al,%al
f01003c1:	79 37                	jns    f01003fa <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c3:	8b 0d 48 45 11 f0    	mov    0xf0114548,%ecx
f01003c9:	89 cb                	mov    %ecx,%ebx
f01003cb:	83 e3 40             	and    $0x40,%ebx
f01003ce:	83 e0 7f             	and    $0x7f,%eax
f01003d1:	85 db                	test   %ebx,%ebx
f01003d3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003d6:	0f b6 d2             	movzbl %dl,%edx
f01003d9:	0f b6 82 80 24 10 f0 	movzbl -0xfefdb80(%edx),%eax
f01003e0:	83 c8 40             	or     $0x40,%eax
f01003e3:	0f b6 c0             	movzbl %al,%eax
f01003e6:	f7 d0                	not    %eax
f01003e8:	21 c1                	and    %eax,%ecx
f01003ea:	89 0d 48 45 11 f0    	mov    %ecx,0xf0114548
		return 0;
f01003f0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f5:	e9 89 00 00 00       	jmp    f0100483 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01003fa:	8b 0d 48 45 11 f0    	mov    0xf0114548,%ecx
f0100400:	f6 c1 40             	test   $0x40,%cl
f0100403:	74 0e                	je     f0100413 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100405:	89 c2                	mov    %eax,%edx
f0100407:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010040a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010040d:	89 0d 48 45 11 f0    	mov    %ecx,0xf0114548
	}

	shift |= shiftcode[data];
f0100413:	0f b6 d2             	movzbl %dl,%edx
f0100416:	0f b6 82 80 24 10 f0 	movzbl -0xfefdb80(%edx),%eax
f010041d:	0b 05 48 45 11 f0    	or     0xf0114548,%eax
	shift ^= togglecode[data];
f0100423:	0f b6 8a 80 25 10 f0 	movzbl -0xfefda80(%edx),%ecx
f010042a:	31 c8                	xor    %ecx,%eax
f010042c:	a3 48 45 11 f0       	mov    %eax,0xf0114548

	c = charcode[shift & (CTL | SHIFT)][data];
f0100431:	89 c1                	mov    %eax,%ecx
f0100433:	83 e1 03             	and    $0x3,%ecx
f0100436:	8b 0c 8d 80 26 10 f0 	mov    -0xfefd980(,%ecx,4),%ecx
f010043d:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100441:	a8 08                	test   $0x8,%al
f0100443:	74 19                	je     f010045e <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100445:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100448:	83 fa 19             	cmp    $0x19,%edx
f010044b:	77 05                	ja     f0100452 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010044d:	83 eb 20             	sub    $0x20,%ebx
f0100450:	eb 0c                	jmp    f010045e <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100452:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f0100455:	8d 53 20             	lea    0x20(%ebx),%edx
f0100458:	83 f9 19             	cmp    $0x19,%ecx
f010045b:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010045e:	f7 d0                	not    %eax
f0100460:	a8 06                	test   $0x6,%al
f0100462:	75 1f                	jne    f0100483 <kbd_proc_data+0xf8>
f0100464:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010046a:	75 17                	jne    f0100483 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010046c:	c7 04 24 4d 24 10 f0 	movl   $0xf010244d,(%esp)
f0100473:	e8 92 0d 00 00       	call   f010120a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100478:	ba 92 00 00 00       	mov    $0x92,%edx
f010047d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100482:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100483:	89 d8                	mov    %ebx,%eax
f0100485:	83 c4 14             	add    $0x14,%esp
f0100488:	5b                   	pop    %ebx
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    

f010048b <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010048b:	55                   	push   %ebp
f010048c:	89 e5                	mov    %esp,%ebp
f010048e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100491:	80 3d 20 43 11 f0 00 	cmpb   $0x0,0xf0114320
f0100498:	74 0a                	je     f01004a4 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010049a:	b8 4e 01 10 f0       	mov    $0xf010014e,%eax
f010049f:	e8 c6 fc ff ff       	call   f010016a <cons_intr>
}
f01004a4:	c9                   	leave  
f01004a5:	c3                   	ret    

f01004a6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a6:	55                   	push   %ebp
f01004a7:	89 e5                	mov    %esp,%ebp
f01004a9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ac:	b8 8b 03 10 f0       	mov    $0xf010038b,%eax
f01004b1:	e8 b4 fc ff ff       	call   f010016a <cons_intr>
}
f01004b6:	c9                   	leave  
f01004b7:	c3                   	ret    

f01004b8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b8:	55                   	push   %ebp
f01004b9:	89 e5                	mov    %esp,%ebp
f01004bb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004be:	e8 c8 ff ff ff       	call   f010048b <serial_intr>
	kbd_intr();
f01004c3:	e8 de ff ff ff       	call   f01004a6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c8:	8b 15 40 45 11 f0    	mov    0xf0114540,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01004ce:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d3:	3b 15 44 45 11 f0    	cmp    0xf0114544,%edx
f01004d9:	74 1e                	je     f01004f9 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004db:	0f b6 82 40 43 11 f0 	movzbl -0xfeebcc0(%edx),%eax
f01004e2:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01004e5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004eb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004f0:	0f 44 d1             	cmove  %ecx,%edx
f01004f3:	89 15 40 45 11 f0    	mov    %edx,0xf0114540
		return c;
	}
	return 0;
}
f01004f9:	c9                   	leave  
f01004fa:	c3                   	ret    

f01004fb <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004fb:	55                   	push   %ebp
f01004fc:	89 e5                	mov    %esp,%ebp
f01004fe:	57                   	push   %edi
f01004ff:	56                   	push   %esi
f0100500:	53                   	push   %ebx
f0100501:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100504:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100512:	5a a5 
	if (*cp != 0xA55A) {
f0100514:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051f:	74 11                	je     f0100532 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100521:	c7 05 4c 45 11 f0 b4 	movl   $0x3b4,0xf011454c
f0100528:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100530:	eb 16                	jmp    f0100548 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100532:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100539:	c7 05 4c 45 11 f0 d4 	movl   $0x3d4,0xf011454c
f0100540:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100543:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100548:	8b 0d 4c 45 11 f0    	mov    0xf011454c,%ecx
f010054e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100553:	89 ca                	mov    %ecx,%edx
f0100555:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100556:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100559:	89 da                	mov    %ebx,%edx
f010055b:	ec                   	in     (%dx),%al
f010055c:	0f b6 f8             	movzbl %al,%edi
f010055f:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100562:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100567:	89 ca                	mov    %ecx,%edx
f0100569:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056a:	89 da                	mov    %ebx,%edx
f010056c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056d:	89 35 50 45 11 f0    	mov    %esi,0xf0114550

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100573:	0f b6 d8             	movzbl %al,%ebx
f0100576:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100578:	66 89 3d 54 45 11 f0 	mov    %di,0xf0114554
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
f0100589:	89 da                	mov    %ebx,%edx
f010058b:	ee                   	out    %al,(%dx)
f010058c:	b2 fb                	mov    $0xfb,%dl
f010058e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100593:	ee                   	out    %al,(%dx)
f0100594:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100599:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059e:	89 ca                	mov    %ecx,%edx
f01005a0:	ee                   	out    %al,(%dx)
f01005a1:	b2 f9                	mov    $0xf9,%dl
f01005a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a8:	ee                   	out    %al,(%dx)
f01005a9:	b2 fb                	mov    $0xfb,%dl
f01005ab:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b0:	ee                   	out    %al,(%dx)
f01005b1:	b2 fc                	mov    $0xfc,%dl
f01005b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b8:	ee                   	out    %al,(%dx)
f01005b9:	b2 f9                	mov    $0xf9,%dl
f01005bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01005c0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c1:	b2 fd                	mov    $0xfd,%dl
f01005c3:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c4:	3c ff                	cmp    $0xff,%al
f01005c6:	0f 95 c0             	setne  %al
f01005c9:	89 c6                	mov    %eax,%esi
f01005cb:	a2 20 43 11 f0       	mov    %al,0xf0114320
f01005d0:	89 da                	mov    %ebx,%edx
f01005d2:	ec                   	in     (%dx),%al
f01005d3:	89 ca                	mov    %ecx,%edx
f01005d5:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d6:	89 f0                	mov    %esi,%eax
f01005d8:	84 c0                	test   %al,%al
f01005da:	75 0c                	jne    f01005e8 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f01005dc:	c7 04 24 59 24 10 f0 	movl   $0xf0102459,(%esp)
f01005e3:	e8 22 0c 00 00       	call   f010120a <cprintf>
}
f01005e8:	83 c4 1c             	add    $0x1c,%esp
f01005eb:	5b                   	pop    %ebx
f01005ec:	5e                   	pop    %esi
f01005ed:	5f                   	pop    %edi
f01005ee:	5d                   	pop    %ebp
f01005ef:	c3                   	ret    

f01005f0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f0:	55                   	push   %ebp
f01005f1:	89 e5                	mov    %esp,%ebp
f01005f3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01005f9:	e8 a9 fb ff ff       	call   f01001a7 <cons_putc>
}
f01005fe:	c9                   	leave  
f01005ff:	c3                   	ret    

f0100600 <getchar>:

int
getchar(void)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100606:	e8 ad fe ff ff       	call   f01004b8 <cons_getc>
f010060b:	85 c0                	test   %eax,%eax
f010060d:	74 f7                	je     f0100606 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010060f:	c9                   	leave  
f0100610:	c3                   	ret    

f0100611 <iscons>:

int
iscons(int fdnum)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100614:	b8 01 00 00 00       	mov    $0x1,%eax
f0100619:	5d                   	pop    %ebp
f010061a:	c3                   	ret    
f010061b:	00 00                	add    %al,(%eax)
f010061d:	00 00                	add    %al,(%eax)
	...

f0100620 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100626:	c7 04 24 90 26 10 f0 	movl   $0xf0102690,(%esp)
f010062d:	e8 d8 0b 00 00       	call   f010120a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100632:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100639:	00 
f010063a:	c7 04 24 50 27 10 f0 	movl   $0xf0102750,(%esp)
f0100641:	e8 c4 0b 00 00       	call   f010120a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100646:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010064d:	00 
f010064e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 78 27 10 f0 	movl   $0xf0102778,(%esp)
f010065d:	e8 a8 0b 00 00       	call   f010120a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100662:	c7 44 24 08 e5 23 10 	movl   $0x1023e5,0x8(%esp)
f0100669:	00 
f010066a:	c7 44 24 04 e5 23 10 	movl   $0xf01023e5,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 9c 27 10 f0 	movl   $0xf010279c,(%esp)
f0100679:	e8 8c 0b 00 00       	call   f010120a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010067e:	c7 44 24 08 08 43 11 	movl   $0x114308,0x8(%esp)
f0100685:	00 
f0100686:	c7 44 24 04 08 43 11 	movl   $0xf0114308,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 c0 27 10 f0 	movl   $0xf01027c0,(%esp)
f0100695:	e8 70 0b 00 00       	call   f010120a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010069a:	c7 44 24 08 90 49 11 	movl   $0x114990,0x8(%esp)
f01006a1:	00 
f01006a2:	c7 44 24 04 90 49 11 	movl   $0xf0114990,0x4(%esp)
f01006a9:	f0 
f01006aa:	c7 04 24 e4 27 10 f0 	movl   $0xf01027e4,(%esp)
f01006b1:	e8 54 0b 00 00       	call   f010120a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006b6:	b8 8f 4d 11 f0       	mov    $0xf0114d8f,%eax
f01006bb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006c0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006c5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006cb:	85 c0                	test   %eax,%eax
f01006cd:	0f 48 c2             	cmovs  %edx,%eax
f01006d0:	c1 f8 0a             	sar    $0xa,%eax
f01006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006d7:	c7 04 24 08 28 10 f0 	movl   $0xf0102808,(%esp)
f01006de:	e8 27 0b 00 00       	call   f010120a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e8:	c9                   	leave  
f01006e9:	c3                   	ret    

f01006ea <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006ea:	55                   	push   %ebp
f01006eb:	89 e5                	mov    %esp,%ebp
f01006ed:	53                   	push   %ebx
f01006ee:	83 ec 14             	sub    $0x14,%esp
f01006f1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006f6:	8b 83 24 29 10 f0    	mov    -0xfefd6dc(%ebx),%eax
f01006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100700:	8b 83 20 29 10 f0    	mov    -0xfefd6e0(%ebx),%eax
f0100706:	89 44 24 04          	mov    %eax,0x4(%esp)
f010070a:	c7 04 24 a9 26 10 f0 	movl   $0xf01026a9,(%esp)
f0100711:	e8 f4 0a 00 00       	call   f010120a <cprintf>
f0100716:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100719:	83 fb 24             	cmp    $0x24,%ebx
f010071c:	75 d8                	jne    f01006f6 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010071e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100723:	83 c4 14             	add    $0x14,%esp
f0100726:	5b                   	pop    %ebx
f0100727:	5d                   	pop    %ebp
f0100728:	c3                   	ret    

f0100729 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100729:	55                   	push   %ebp
f010072a:	89 e5                	mov    %esp,%ebp
f010072c:	57                   	push   %edi
f010072d:	56                   	push   %esi
f010072e:	53                   	push   %ebx
f010072f:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100735:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100737:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100739:	8b 43 04             	mov    0x4(%ebx),%eax
f010073c:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f0100742:	8b 43 08             	mov    0x8(%ebx),%eax
f0100745:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f010074b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010074e:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f0100754:	8b 43 10             	mov    0x10(%ebx),%eax
f0100757:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f010075d:	8b 43 14             	mov    0x14(%ebx),%eax
f0100760:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f0100766:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f0100769:	c7 04 24 b2 26 10 f0 	movl   $0xf01026b2,(%esp)
f0100770:	e8 95 0a 00 00       	call   f010120a <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100775:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f010077a:	85 db                	test   %ebx,%ebx
f010077c:	0f 84 f5 00 00 00    	je     f0100877 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f0100782:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100788:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f010078e:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100794:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f010079a:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010079e:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01007a2:	89 54 24 14          	mov    %edx,0x14(%esp)
f01007a6:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007aa:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f01007b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01007b8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007bc:	c7 04 24 34 28 10 f0 	movl   $0xf0102834,(%esp)
f01007c3:	e8 42 0a 00 00       	call   f010120a <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f01007c8:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007cf:	89 1c 24             	mov    %ebx,(%esp)
f01007d2:	e8 2d 0b 00 00       	call   f0101304 <debuginfo_eip>
f01007d7:	85 c0                	test   %eax,%eax
f01007d9:	0f 88 93 00 00 00    	js     f0100872 <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f01007df:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e6:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f01007ec:	89 04 24             	mov    %eax,(%esp)
f01007ef:	e8 67 15 00 00       	call   f0101d5b <strcpy>

		int eip_line = info.eip_line;
f01007f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01007f7:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f01007fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100800:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100804:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100807:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080b:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f010080e:	89 3c 24             	mov    %edi,(%esp)
f0100811:	e8 90 15 00 00       	call   f0101da6 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100816:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100819:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f010081e:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100821:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100825:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100829:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f010082f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100833:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100839:	89 44 24 04          	mov    %eax,0x4(%esp)
f010083d:	c7 04 24 c4 26 10 f0 	movl   $0xf01026c4,(%esp)
f0100844:	e8 c1 09 00 00       	call   f010120a <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f0100849:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f010084b:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f010084e:	8b 46 08             	mov    0x8(%esi),%eax
f0100851:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f0100857:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f010085a:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f010085d:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f0100860:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100863:	85 f6                	test   %esi,%esi
f0100865:	0f 85 2f ff ff ff    	jne    f010079a <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f010086b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100870:	eb 05                	jmp    f0100877 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f0100872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100877:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f010087d:	5b                   	pop    %ebx
f010087e:	5e                   	pop    %esi
f010087f:	5f                   	pop    %edi
f0100880:	5d                   	pop    %ebp
f0100881:	c3                   	ret    

f0100882 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100882:	55                   	push   %ebp
f0100883:	89 e5                	mov    %esp,%ebp
f0100885:	57                   	push   %edi
f0100886:	56                   	push   %esi
f0100887:	53                   	push   %ebx
f0100888:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f010088b:	c7 04 24 68 28 10 f0 	movl   $0xf0102868,(%esp)
f0100892:	e8 73 09 00 00       	call   f010120a <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f0100897:	c7 04 24 9c 28 10 f0 	movl   $0xf010289c,(%esp)
f010089e:	e8 67 09 00 00       	call   f010120a <cprintf>
    
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
f01008a3:	c7 04 24 db 26 10 f0 	movl   $0xf01026db,(%esp)
f01008aa:	e8 91 13 00 00       	call   f0101c40 <readline>
f01008af:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008b1:	85 c0                	test   %eax,%eax
f01008b3:	74 ee                	je     f01008a3 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008b5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008bc:	be 00 00 00 00       	mov    $0x0,%esi
f01008c1:	eb 06                	jmp    f01008c9 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008c3:	c6 03 00             	movb   $0x0,(%ebx)
f01008c6:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008c9:	0f b6 03             	movzbl (%ebx),%eax
f01008cc:	84 c0                	test   %al,%al
f01008ce:	74 6b                	je     f010093b <monitor+0xb9>
f01008d0:	0f be c0             	movsbl %al,%eax
f01008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d7:	c7 04 24 df 26 10 f0 	movl   $0xf01026df,(%esp)
f01008de:	e8 b3 15 00 00       	call   f0101e96 <strchr>
f01008e3:	85 c0                	test   %eax,%eax
f01008e5:	75 dc                	jne    f01008c3 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01008e7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008ea:	74 4f                	je     f010093b <monitor+0xb9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008ec:	83 fe 0f             	cmp    $0xf,%esi
f01008ef:	90                   	nop
f01008f0:	75 16                	jne    f0100908 <monitor+0x86>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008f2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008f9:	00 
f01008fa:	c7 04 24 e4 26 10 f0 	movl   $0xf01026e4,(%esp)
f0100901:	e8 04 09 00 00       	call   f010120a <cprintf>
f0100906:	eb 9b                	jmp    f01008a3 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100908:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010090c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010090f:	0f b6 03             	movzbl (%ebx),%eax
f0100912:	84 c0                	test   %al,%al
f0100914:	75 0c                	jne    f0100922 <monitor+0xa0>
f0100916:	eb b1                	jmp    f01008c9 <monitor+0x47>
			buf++;
f0100918:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010091b:	0f b6 03             	movzbl (%ebx),%eax
f010091e:	84 c0                	test   %al,%al
f0100920:	74 a7                	je     f01008c9 <monitor+0x47>
f0100922:	0f be c0             	movsbl %al,%eax
f0100925:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100929:	c7 04 24 df 26 10 f0 	movl   $0xf01026df,(%esp)
f0100930:	e8 61 15 00 00       	call   f0101e96 <strchr>
f0100935:	85 c0                	test   %eax,%eax
f0100937:	74 df                	je     f0100918 <monitor+0x96>
f0100939:	eb 8e                	jmp    f01008c9 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010093b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100942:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100943:	85 f6                	test   %esi,%esi
f0100945:	0f 84 58 ff ff ff    	je     f01008a3 <monitor+0x21>
f010094b:	bb 20 29 10 f0       	mov    $0xf0102920,%ebx
f0100950:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100955:	8b 03                	mov    (%ebx),%eax
f0100957:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010095e:	89 04 24             	mov    %eax,(%esp)
f0100961:	e8 b5 14 00 00       	call   f0101e1b <strcmp>
f0100966:	85 c0                	test   %eax,%eax
f0100968:	75 24                	jne    f010098e <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f010096a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010096d:	8b 55 08             	mov    0x8(%ebp),%edx
f0100970:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100974:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100977:	89 54 24 04          	mov    %edx,0x4(%esp)
f010097b:	89 34 24             	mov    %esi,(%esp)
f010097e:	ff 14 85 28 29 10 f0 	call   *-0xfefd6d8(,%eax,4)
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100985:	85 c0                	test   %eax,%eax
f0100987:	78 28                	js     f01009b1 <monitor+0x12f>
f0100989:	e9 15 ff ff ff       	jmp    f01008a3 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010098e:	83 c7 01             	add    $0x1,%edi
f0100991:	83 c3 0c             	add    $0xc,%ebx
f0100994:	83 ff 03             	cmp    $0x3,%edi
f0100997:	75 bc                	jne    f0100955 <monitor+0xd3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100999:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010099c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a0:	c7 04 24 01 27 10 f0 	movl   $0xf0102701,(%esp)
f01009a7:	e8 5e 08 00 00       	call   f010120a <cprintf>
f01009ac:	e9 f2 fe ff ff       	jmp    f01008a3 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009b1:	83 c4 5c             	add    $0x5c,%esp
f01009b4:	5b                   	pop    %ebx
f01009b5:	5e                   	pop    %esi
f01009b6:	5f                   	pop    %edi
f01009b7:	5d                   	pop    %ebp
f01009b8:	c3                   	ret    
f01009b9:	00 00                	add    %al,(%eax)
	...

f01009bc <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
f01009bf:	83 ec 18             	sub    $0x18,%esp
f01009c2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01009c5:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01009c8:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009ca:	89 04 24             	mov    %eax,(%esp)
f01009cd:	e8 ca 07 00 00       	call   f010119c <mc146818_read>
f01009d2:	89 c6                	mov    %eax,%esi
f01009d4:	83 c3 01             	add    $0x1,%ebx
f01009d7:	89 1c 24             	mov    %ebx,(%esp)
f01009da:	e8 bd 07 00 00       	call   f010119c <mc146818_read>
f01009df:	c1 e0 08             	shl    $0x8,%eax
f01009e2:	09 f0                	or     %esi,%eax
}
f01009e4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01009e7:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01009ea:	89 ec                	mov    %ebp,%esp
f01009ec:	5d                   	pop    %ebp
f01009ed:	c3                   	ret    

f01009ee <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01009ee:	55                   	push   %ebp
f01009ef:	89 e5                	mov    %esp,%ebp
f01009f1:	83 ec 18             	sub    $0x18,%esp
f01009f4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01009f7:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01009fa:	83 3d 5c 45 11 f0 00 	cmpl   $0x0,0xf011455c
f0100a01:	75 11                	jne    f0100a14 <boot_alloc+0x26>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a03:	ba 8f 59 11 f0       	mov    $0xf011598f,%edx
f0100a08:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a0e:	89 15 5c 45 11 f0    	mov    %edx,0xf011455c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f0100a14:	83 3d 00 43 11 f0 ff 	cmpl   $0xffffffff,0xf0114300
f0100a1b:	75 0c                	jne    f0100a29 <boot_alloc+0x3b>
		npages_left = npages;
f0100a1d:	8b 15 84 49 11 f0    	mov    0xf0114984,%edx
f0100a23:	89 15 00 43 11 f0    	mov    %edx,0xf0114300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f0100a29:	85 c0                	test   %eax,%eax
f0100a2b:	75 2c                	jne    f0100a59 <boot_alloc+0x6b>
// !- Whether I should check here -!
		if(npages_left < 1) {
f0100a2d:	83 3d 00 43 11 f0 00 	cmpl   $0x0,0xf0114300
f0100a34:	75 1c                	jne    f0100a52 <boot_alloc+0x64>
			panic("Out of memory!\n");
f0100a36:	c7 44 24 08 44 29 10 	movl   $0xf0102944,0x8(%esp)
f0100a3d:	f0 
f0100a3e:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
f0100a45:	00 
f0100a46:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100a4d:	e8 42 f6 ff ff       	call   f0100094 <_panic>
		}
		result = nextfree;
f0100a52:	a1 5c 45 11 f0       	mov    0xf011455c,%eax
f0100a57:	eb 5c                	jmp    f0100ab5 <boot_alloc+0xc7>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f0100a59:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f0100a5f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		cprintf("Request %u\n", srequest/PGSIZE);
f0100a65:	89 f3                	mov    %esi,%ebx
f0100a67:	c1 eb 0c             	shr    $0xc,%ebx
f0100a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100a6e:	c7 04 24 60 29 10 f0 	movl   $0xf0102960,(%esp)
f0100a75:	e8 90 07 00 00       	call   f010120a <cprintf>

		if(npages_left < srequest/PGSIZE) {
f0100a7a:	8b 15 00 43 11 f0    	mov    0xf0114300,%edx
f0100a80:	39 d3                	cmp    %edx,%ebx
f0100a82:	76 1c                	jbe    f0100aa0 <boot_alloc+0xb2>
			panic("Out of memory!\n");
f0100a84:	c7 44 24 08 44 29 10 	movl   $0xf0102944,0x8(%esp)
f0100a8b:	f0 
f0100a8c:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f0100a93:	00 
f0100a94:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100a9b:	e8 f4 f5 ff ff       	call   f0100094 <_panic>
		}
		result = nextfree;
f0100aa0:	a1 5c 45 11 f0       	mov    0xf011455c,%eax
		nextfree += srequest;
f0100aa5:	01 c6                	add    %eax,%esi
f0100aa7:	89 35 5c 45 11 f0    	mov    %esi,0xf011455c
		npages_left -= srequest/PGSIZE;
f0100aad:	29 da                	sub    %ebx,%edx
f0100aaf:	89 15 00 43 11 f0    	mov    %edx,0xf0114300
	}

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
}
f0100ab5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100ab8:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100abb:	89 ec                	mov    %ebp,%esp
f0100abd:	5d                   	pop    %ebp
f0100abe:	c3                   	ret    

f0100abf <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
f0100ac2:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ac5:	89 d1                	mov    %edx,%ecx
f0100ac7:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100aca:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100acd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ad2:	f6 c1 01             	test   $0x1,%cl
f0100ad5:	74 57                	je     f0100b2e <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ad7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100add:	89 c8                	mov    %ecx,%eax
f0100adf:	c1 e8 0c             	shr    $0xc,%eax
f0100ae2:	3b 05 84 49 11 f0    	cmp    0xf0114984,%eax
f0100ae8:	72 20                	jb     f0100b0a <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100aee:	c7 44 24 08 5c 2a 10 	movl   $0xf0102a5c,0x8(%esp)
f0100af5:	f0 
f0100af6:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f0100afd:	00 
f0100afe:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100b05:	e8 8a f5 ff ff       	call   f0100094 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b0a:	c1 ea 0c             	shr    $0xc,%edx
f0100b0d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b13:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100b1a:	89 c2                	mov    %eax,%edx
f0100b1c:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b24:	85 d2                	test   %edx,%edx
f0100b26:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b2b:	0f 44 c2             	cmove  %edx,%eax
}
f0100b2e:	c9                   	leave  
f0100b2f:	c3                   	ret    

f0100b30 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b30:	55                   	push   %ebp
f0100b31:	89 e5                	mov    %esp,%ebp
f0100b33:	57                   	push   %edi
f0100b34:	56                   	push   %esi
f0100b35:	53                   	push   %ebx
f0100b36:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b39:	3c 01                	cmp    $0x1,%al
f0100b3b:	19 f6                	sbb    %esi,%esi
f0100b3d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b43:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b46:	8b 1d 60 45 11 f0    	mov    0xf0114560,%ebx
f0100b4c:	85 db                	test   %ebx,%ebx
f0100b4e:	75 1c                	jne    f0100b6c <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100b50:	c7 44 24 08 80 2a 10 	movl   $0xf0102a80,0x8(%esp)
f0100b57:	f0 
f0100b58:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0100b5f:	00 
f0100b60:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100b67:	e8 28 f5 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
f0100b6c:	84 c0                	test   %al,%al
f0100b6e:	74 50                	je     f0100bc0 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b70:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100b73:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100b79:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b7c:	89 d8                	mov    %ebx,%eax
f0100b7e:	2b 05 8c 49 11 f0    	sub    0xf011498c,%eax
f0100b84:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b87:	c1 e8 16             	shr    $0x16,%eax
f0100b8a:	39 c6                	cmp    %eax,%esi
f0100b8c:	0f 96 c0             	setbe  %al
f0100b8f:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100b92:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100b96:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100b98:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b9c:	8b 1b                	mov    (%ebx),%ebx
f0100b9e:	85 db                	test   %ebx,%ebx
f0100ba0:	75 da                	jne    f0100b7c <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ba2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ba5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bab:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bb1:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bb3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100bb6:	89 1d 60 45 11 f0    	mov    %ebx,0xf0114560
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bbc:	85 db                	test   %ebx,%ebx
f0100bbe:	74 67                	je     f0100c27 <check_page_free_list+0xf7>
f0100bc0:	89 d8                	mov    %ebx,%eax
f0100bc2:	2b 05 8c 49 11 f0    	sub    0xf011498c,%eax
f0100bc8:	c1 f8 03             	sar    $0x3,%eax
f0100bcb:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bce:	89 c2                	mov    %eax,%edx
f0100bd0:	c1 ea 16             	shr    $0x16,%edx
f0100bd3:	39 d6                	cmp    %edx,%esi
f0100bd5:	76 4a                	jbe    f0100c21 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bd7:	89 c2                	mov    %eax,%edx
f0100bd9:	c1 ea 0c             	shr    $0xc,%edx
f0100bdc:	3b 15 84 49 11 f0    	cmp    0xf0114984,%edx
f0100be2:	72 20                	jb     f0100c04 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100be8:	c7 44 24 08 5c 2a 10 	movl   $0xf0102a5c,0x8(%esp)
f0100bef:	f0 
f0100bf0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bf7:	00 
f0100bf8:	c7 04 24 6c 29 10 f0 	movl   $0xf010296c,(%esp)
f0100bff:	e8 90 f4 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c04:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c0b:	00 
f0100c0c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c13:	00 
	return (void *)(pa + KERNBASE);
f0100c14:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c19:	89 04 24             	mov    %eax,(%esp)
f0100c1c:	e8 d0 12 00 00       	call   f0101ef1 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c21:	8b 1b                	mov    (%ebx),%ebx
f0100c23:	85 db                	test   %ebx,%ebx
f0100c25:	75 99                	jne    f0100bc0 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c27:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2c:	e8 bd fd ff ff       	call   f01009ee <boot_alloc>
f0100c31:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c34:	8b 15 60 45 11 f0    	mov    0xf0114560,%edx
f0100c3a:	85 d2                	test   %edx,%edx
f0100c3c:	0f 84 f6 01 00 00    	je     f0100e38 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c42:	8b 1d 8c 49 11 f0    	mov    0xf011498c,%ebx
f0100c48:	39 da                	cmp    %ebx,%edx
f0100c4a:	72 4d                	jb     f0100c99 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f0100c4c:	a1 84 49 11 f0       	mov    0xf0114984,%eax
f0100c51:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c54:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100c57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100c5a:	39 c2                	cmp    %eax,%edx
f0100c5c:	73 64                	jae    f0100cc2 <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c5e:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100c61:	89 d0                	mov    %edx,%eax
f0100c63:	29 d8                	sub    %ebx,%eax
f0100c65:	a8 07                	test   $0x7,%al
f0100c67:	0f 85 82 00 00 00    	jne    f0100cef <check_page_free_list+0x1bf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c6d:	c1 f8 03             	sar    $0x3,%eax
f0100c70:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c73:	85 c0                	test   %eax,%eax
f0100c75:	0f 84 a2 00 00 00    	je     f0100d1d <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c7b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c80:	0f 84 c2 00 00 00    	je     f0100d48 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c86:	be 00 00 00 00       	mov    $0x0,%esi
f0100c8b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c90:	e9 d7 00 00 00       	jmp    f0100d6c <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c95:	39 da                	cmp    %ebx,%edx
f0100c97:	73 24                	jae    f0100cbd <check_page_free_list+0x18d>
f0100c99:	c7 44 24 0c 7a 29 10 	movl   $0xf010297a,0xc(%esp)
f0100ca0:	f0 
f0100ca1:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100ca8:	f0 
f0100ca9:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
f0100cb0:	00 
f0100cb1:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100cb8:	e8 d7 f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100cbd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cc0:	72 24                	jb     f0100ce6 <check_page_free_list+0x1b6>
f0100cc2:	c7 44 24 0c 9b 29 10 	movl   $0xf010299b,0xc(%esp)
f0100cc9:	f0 
f0100cca:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100cd1:	f0 
f0100cd2:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
f0100cd9:	00 
f0100cda:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100ce1:	e8 ae f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ce6:	89 d0                	mov    %edx,%eax
f0100ce8:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ceb:	a8 07                	test   $0x7,%al
f0100ced:	74 24                	je     f0100d13 <check_page_free_list+0x1e3>
f0100cef:	c7 44 24 0c a4 2a 10 	movl   $0xf0102aa4,0xc(%esp)
f0100cf6:	f0 
f0100cf7:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100cfe:	f0 
f0100cff:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
f0100d06:	00 
f0100d07:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100d0e:	e8 81 f3 ff ff       	call   f0100094 <_panic>
f0100d13:	c1 f8 03             	sar    $0x3,%eax
f0100d16:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d19:	85 c0                	test   %eax,%eax
f0100d1b:	75 24                	jne    f0100d41 <check_page_free_list+0x211>
f0100d1d:	c7 44 24 0c af 29 10 	movl   $0xf01029af,0xc(%esp)
f0100d24:	f0 
f0100d25:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100d2c:	f0 
f0100d2d:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f0100d34:	00 
f0100d35:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100d3c:	e8 53 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d41:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d46:	75 24                	jne    f0100d6c <check_page_free_list+0x23c>
f0100d48:	c7 44 24 0c c0 29 10 	movl   $0xf01029c0,0xc(%esp)
f0100d4f:	f0 
f0100d50:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100d57:	f0 
f0100d58:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0100d5f:	00 
f0100d60:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100d67:	e8 28 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d6c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d71:	75 24                	jne    f0100d97 <check_page_free_list+0x267>
f0100d73:	c7 44 24 0c d8 2a 10 	movl   $0xf0102ad8,0xc(%esp)
f0100d7a:	f0 
f0100d7b:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100d82:	f0 
f0100d83:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
f0100d8a:	00 
f0100d8b:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100d92:	e8 fd f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d97:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d9c:	75 24                	jne    f0100dc2 <check_page_free_list+0x292>
f0100d9e:	c7 44 24 0c d9 29 10 	movl   $0xf01029d9,0xc(%esp)
f0100da5:	f0 
f0100da6:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100dad:	f0 
f0100dae:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
f0100db5:	00 
f0100db6:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100dbd:	e8 d2 f2 ff ff       	call   f0100094 <_panic>
f0100dc2:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc9:	76 57                	jbe    f0100e22 <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dcb:	c1 e8 0c             	shr    $0xc,%eax
f0100dce:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100dd1:	77 20                	ja     f0100df3 <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100dd7:	c7 44 24 08 5c 2a 10 	movl   $0xf0102a5c,0x8(%esp)
f0100dde:	f0 
f0100ddf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100de6:	00 
f0100de7:	c7 04 24 6c 29 10 f0 	movl   $0xf010296c,(%esp)
f0100dee:	e8 a1 f2 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100df3:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100df9:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100dfc:	76 29                	jbe    f0100e27 <check_page_free_list+0x2f7>
f0100dfe:	c7 44 24 0c fc 2a 10 	movl   $0xf0102afc,0xc(%esp)
f0100e05:	f0 
f0100e06:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100e0d:	f0 
f0100e0e:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
f0100e15:	00 
f0100e16:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100e1d:	e8 72 f2 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e22:	83 c7 01             	add    $0x1,%edi
f0100e25:	eb 03                	jmp    f0100e2a <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0100e27:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e2a:	8b 12                	mov    (%edx),%edx
f0100e2c:	85 d2                	test   %edx,%edx
f0100e2e:	0f 85 61 fe ff ff    	jne    f0100c95 <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e34:	85 ff                	test   %edi,%edi
f0100e36:	7f 24                	jg     f0100e5c <check_page_free_list+0x32c>
f0100e38:	c7 44 24 0c f3 29 10 	movl   $0xf01029f3,0xc(%esp)
f0100e3f:	f0 
f0100e40:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100e47:	f0 
f0100e48:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
f0100e4f:	00 
f0100e50:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100e57:	e8 38 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e5c:	85 f6                	test   %esi,%esi
f0100e5e:	7f 24                	jg     f0100e84 <check_page_free_list+0x354>
f0100e60:	c7 44 24 0c 05 2a 10 	movl   $0xf0102a05,0xc(%esp)
f0100e67:	f0 
f0100e68:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0100e6f:	f0 
f0100e70:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
f0100e77:	00 
f0100e78:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0100e7f:	e8 10 f2 ff ff       	call   f0100094 <_panic>
}
f0100e84:	83 c4 3c             	add    $0x3c,%esp
f0100e87:	5b                   	pop    %ebx
f0100e88:	5e                   	pop    %esi
f0100e89:	5f                   	pop    %edi
f0100e8a:	5d                   	pop    %ebp
f0100e8b:	c3                   	ret    

f0100e8c <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e8c:	55                   	push   %ebp
f0100e8d:	89 e5                	mov    %esp,%ebp
f0100e8f:	57                   	push   %edi
f0100e90:	56                   	push   %esi
f0100e91:	53                   	push   %ebx
f0100e92:	83 ec 08             	sub    $0x8,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0100e95:	83 3d 84 49 11 f0 00 	cmpl   $0x0,0xf0114984
f0100e9c:	0f 84 04 01 00 00    	je     f0100fa6 <page_init+0x11a>
		// 2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
		//    is free.
		// Low memory: 0x1000~0xA0000
		// the first page is reserved. 640KB(except first page)
		if(page2pa(&pages[i]) >= PGSIZE
			&& page2pa(&pages[i]) < npages_basemem * PGSIZE) {
f0100ea2:	a1 58 45 11 f0       	mov    0xf0114558,%eax
f0100ea7:	c1 e0 0c             	shl    $0xc,%eax
f0100eaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ead:	8b 35 60 45 11 f0    	mov    0xf0114560,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0100eb3:	ba 00 00 00 00       	mov    $0x0,%edx
			&& page2pa(&pages[i]) < pageinfo_end) {
			pages[i].pp_ref = 0;
		}
		extern char end[];
		if(page2pa(&pages[i]) >= pageinfo_end
			&& page2pa(&pages[i]) < (physaddr_t)(ROUNDUP((char *) end, PGSIZE) + npages*PGSIZE) ) {
f0100eb8:	b8 8f 59 11 f0       	mov    $0xf011598f,%eax
f0100ebd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ec2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	size_t i;
	for (i = 0; i < npages; i++) {
		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f0100ec5:	85 d2                	test   %edx,%edx
f0100ec7:	75 0b                	jne    f0100ed4 <page_init+0x48>
			// Pages allocated at boot time using pmap.c's
			// boot_alloc do not have valid reference count fields.
			pages[0].pp_ref = 0;
f0100ec9:	a1 8c 49 11 f0       	mov    0xf011498c,%eax
f0100ece:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		
		// 2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
		//    is free.
		// Low memory: 0x1000~0xA0000
		// the first page is reserved. 640KB(except first page)
		if(page2pa(&pages[i]) >= PGSIZE
f0100ed4:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100edb:	8b 1d 8c 49 11 f0    	mov    0xf011498c,%ebx
f0100ee1:	01 c3                	add    %eax,%ebx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ee3:	89 c1                	mov    %eax,%ecx
f0100ee5:	c1 e1 09             	shl    $0x9,%ecx
f0100ee8:	81 f9 ff 0f 00 00    	cmp    $0xfff,%ecx
f0100eee:	76 15                	jbe    f0100f05 <page_init+0x79>
			&& page2pa(&pages[i]) < npages_basemem * PGSIZE) {
f0100ef0:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0100ef3:	76 10                	jbe    f0100f05 <page_init+0x79>
			pages[i].pp_ref = 0;
f0100ef5:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
			pages[i].pp_link = page_free_list;
f0100efb:	89 33                	mov    %esi,(%ebx)
			page_free_list = &pages[i];
f0100efd:	89 c6                	mov    %eax,%esi
f0100eff:	03 35 8c 49 11 f0    	add    0xf011498c,%esi
		}

		// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
		//    never be allocated.
		// IO hole is reserved: 0xA0000~0x100000
		if(page2pa(&pages[i]) >= IOPHYSMEM
f0100f05:	8b 1d 8c 49 11 f0    	mov    0xf011498c,%ebx
f0100f0b:	01 c3                	add    %eax,%ebx
f0100f0d:	89 c1                	mov    %eax,%ecx
f0100f0f:	c1 e1 09             	shl    $0x9,%ecx
f0100f12:	81 f9 ff ff 09 00    	cmp    $0x9ffff,%ecx
f0100f18:	76 0e                	jbe    f0100f28 <page_init+0x9c>
			&& page2pa(&pages[i]) < EXTPHYSMEM) {		
f0100f1a:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0100f20:	77 1b                	ja     f0100f3d <page_init+0xb1>
			pages[i].pp_ref = 0;
f0100f22:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		//   others is free

		physaddr_t pageinfo_end = 0x115000 + 34*PGSIZE;
		if(page2pa(&pages[i]) >= EXTPHYSMEM
f0100f28:	8b 1d 8c 49 11 f0    	mov    0xf011498c,%ebx
f0100f2e:	01 c3                	add    %eax,%ebx
f0100f30:	89 c1                	mov    %eax,%ecx
f0100f32:	c1 e1 09             	shl    $0x9,%ecx
f0100f35:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0100f3b:	76 0e                	jbe    f0100f4b <page_init+0xbf>
			&& page2pa(&pages[i]) < pageinfo_end) {
f0100f3d:	81 f9 ff 6f 13 00    	cmp    $0x136fff,%ecx
f0100f43:	77 52                	ja     f0100f97 <page_init+0x10b>
			pages[i].pp_ref = 0;
f0100f45:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		}
		extern char end[];
		if(page2pa(&pages[i]) >= pageinfo_end
f0100f4b:	8b 1d 8c 49 11 f0    	mov    0xf011498c,%ebx
f0100f51:	01 c3                	add    %eax,%ebx
f0100f53:	89 c1                	mov    %eax,%ecx
f0100f55:	c1 e1 09             	shl    $0x9,%ecx
f0100f58:	81 f9 ff 6f 13 00    	cmp    $0x136fff,%ecx
f0100f5e:	76 20                	jbe    f0100f80 <page_init+0xf4>
			&& page2pa(&pages[i]) < (physaddr_t)(ROUNDUP((char *) end, PGSIZE) + npages*PGSIZE) ) {
f0100f60:	8b 3d 84 49 11 f0    	mov    0xf0114984,%edi
f0100f66:	c1 e7 0c             	shl    $0xc,%edi
f0100f69:	03 7d ec             	add    -0x14(%ebp),%edi
f0100f6c:	39 f9                	cmp    %edi,%ecx
f0100f6e:	73 10                	jae    f0100f80 <page_init+0xf4>
			pages[i].pp_ref = 0;
f0100f70:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
			pages[i].pp_link = page_free_list;
f0100f76:	89 33                	mov    %esi,(%ebx)
			page_free_list = &pages[i];
f0100f78:	89 c6                	mov    %eax,%esi
f0100f7a:	03 35 8c 49 11 f0    	add    0xf011498c,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0100f80:	83 c2 01             	add    $0x1,%edx
f0100f83:	39 15 84 49 11 f0    	cmp    %edx,0xf0114984
f0100f89:	0f 87 36 ff ff ff    	ja     f0100ec5 <page_init+0x39>
f0100f8f:	89 35 60 45 11 f0    	mov    %esi,0xf0114560
f0100f95:	eb 0f                	jmp    f0100fa6 <page_init+0x11a>
		if(page2pa(&pages[i]) >= EXTPHYSMEM
			&& page2pa(&pages[i]) < pageinfo_end) {
			pages[i].pp_ref = 0;
		}
		extern char end[];
		if(page2pa(&pages[i]) >= pageinfo_end
f0100f97:	8b 1d 8c 49 11 f0    	mov    0xf011498c,%ebx
f0100f9d:	01 c3                	add    %eax,%ebx
f0100f9f:	89 c1                	mov    %eax,%ecx
f0100fa1:	c1 e1 09             	shl    $0x9,%ecx
f0100fa4:	eb ba                	jmp    f0100f60 <page_init+0xd4>
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100fa6:	83 c4 08             	add    $0x8,%esp
f0100fa9:	5b                   	pop    %ebx
f0100faa:	5e                   	pop    %esi
f0100fab:	5f                   	pop    %edi
f0100fac:	5d                   	pop    %ebp
f0100fad:	c3                   	ret    

f0100fae <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fae:	55                   	push   %ebp
f0100faf:	89 e5                	mov    %esp,%ebp
	// returned physical page with '\0' bytes.
	if(alloc_flags & ALLOC_ZERO) {

	}
	return 0;
}
f0100fb1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb6:	5d                   	pop    %ebp
f0100fb7:	c3                   	ret    

f0100fb8 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fb8:	55                   	push   %ebp
f0100fb9:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100fbb:	5d                   	pop    %ebp
f0100fbc:	c3                   	ret    

f0100fbd <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100fc3:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100fc8:	5d                   	pop    %ebp
f0100fc9:	c3                   	ret    

f0100fca <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fca:	55                   	push   %ebp
f0100fcb:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100fcd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd2:	5d                   	pop    %ebp
f0100fd3:	c3                   	ret    

f0100fd4 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fd4:	55                   	push   %ebp
f0100fd5:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100fd7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fdc:	5d                   	pop    %ebp
f0100fdd:	c3                   	ret    

f0100fde <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fde:	55                   	push   %ebp
f0100fdf:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100fe1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe6:	5d                   	pop    %ebp
f0100fe7:	c3                   	ret    

f0100fe8 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100fe8:	55                   	push   %ebp
f0100fe9:	89 e5                	mov    %esp,%ebp
f0100feb:	83 ec 18             	sub    $0x18,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100fee:	b8 15 00 00 00       	mov    $0x15,%eax
f0100ff3:	e8 c4 f9 ff ff       	call   f01009bc <nvram_read>
f0100ff8:	c1 e0 0a             	shl    $0xa,%eax
f0100ffb:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101001:	85 c0                	test   %eax,%eax
f0101003:	0f 48 c2             	cmovs  %edx,%eax
f0101006:	c1 f8 0c             	sar    $0xc,%eax
f0101009:	a3 58 45 11 f0       	mov    %eax,0xf0114558
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010100e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101013:	e8 a4 f9 ff ff       	call   f01009bc <nvram_read>
f0101018:	c1 e0 0a             	shl    $0xa,%eax
f010101b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101021:	85 c0                	test   %eax,%eax
f0101023:	0f 48 c2             	cmovs  %edx,%eax
f0101026:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101029:	85 c0                	test   %eax,%eax
f010102b:	74 0e                	je     f010103b <mem_init+0x53>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010102d:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101033:	89 15 84 49 11 f0    	mov    %edx,0xf0114984
f0101039:	eb 0c                	jmp    f0101047 <mem_init+0x5f>
	else
		npages = npages_basemem;
f010103b:	8b 15 58 45 11 f0    	mov    0xf0114558,%edx
f0101041:	89 15 84 49 11 f0    	mov    %edx,0xf0114984

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101047:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010104a:	c1 e8 0a             	shr    $0xa,%eax
f010104d:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101051:	a1 58 45 11 f0       	mov    0xf0114558,%eax
f0101056:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101059:	c1 e8 0a             	shr    $0xa,%eax
f010105c:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101060:	a1 84 49 11 f0       	mov    0xf0114984,%eax
f0101065:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101068:	c1 e8 0a             	shr    $0xa,%eax
f010106b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010106f:	c7 04 24 44 2b 10 f0 	movl   $0xf0102b44,(%esp)
f0101076:	e8 8f 01 00 00       	call   f010120a <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010107b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101080:	e8 69 f9 ff ff       	call   f01009ee <boot_alloc>
f0101085:	a3 88 49 11 f0       	mov    %eax,0xf0114988
	memset(kern_pgdir, 0, PGSIZE);
f010108a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101091:	00 
f0101092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101099:	00 
f010109a:	89 04 24             	mov    %eax,(%esp)
f010109d:	e8 4f 0e 00 00       	call   f0101ef1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010a2:	a1 88 49 11 f0       	mov    0xf0114988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010ac:	77 20                	ja     f01010ce <mem_init+0xe6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010b2:	c7 44 24 08 80 2b 10 	movl   $0xf0102b80,0x8(%esp)
f01010b9:	f0 
f01010ba:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
f01010c1:	00 
f01010c2:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f01010c9:	e8 c6 ef ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010ce:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010d4:	83 ca 05             	or     $0x5,%edx
f01010d7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f01010dd:	a1 84 49 11 f0       	mov    0xf0114984,%eax
f01010e2:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f01010e5:	e8 04 f9 ff ff       	call   f01009ee <boot_alloc>
f01010ea:	a3 8c 49 11 f0       	mov    %eax,0xf011498c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01010ef:	e8 98 fd ff ff       	call   f0100e8c <page_init>

	check_page_free_list(1);
f01010f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01010f9:	e8 32 fa ff ff       	call   f0100b30 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01010fe:	83 3d 8c 49 11 f0 00 	cmpl   $0x0,0xf011498c
f0101105:	75 1c                	jne    f0101123 <mem_init+0x13b>
		panic("'pages' is a null pointer!");
f0101107:	c7 44 24 08 16 2a 10 	movl   $0xf0102a16,0x8(%esp)
f010110e:	f0 
f010110f:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0101116:	00 
f0101117:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f010111e:	e8 71 ef ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101123:	a1 60 45 11 f0       	mov    0xf0114560,%eax
f0101128:	85 c0                	test   %eax,%eax
f010112a:	74 06                	je     f0101132 <mem_init+0x14a>
f010112c:	8b 00                	mov    (%eax),%eax
f010112e:	85 c0                	test   %eax,%eax
f0101130:	75 fa                	jne    f010112c <mem_init+0x144>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101139:	e8 70 fe ff ff       	call   f0100fae <page_alloc>
f010113e:	85 c0                	test   %eax,%eax
f0101140:	75 24                	jne    f0101166 <mem_init+0x17e>
f0101142:	c7 44 24 0c 31 2a 10 	movl   $0xf0102a31,0xc(%esp)
f0101149:	f0 
f010114a:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0101151:	f0 
f0101152:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
f0101159:	00 
f010115a:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0101161:	e8 2e ef ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101166:	c7 44 24 0c 47 2a 10 	movl   $0xf0102a47,0xc(%esp)
f010116d:	f0 
f010116e:	c7 44 24 08 86 29 10 	movl   $0xf0102986,0x8(%esp)
f0101175:	f0 
f0101176:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f010117d:	00 
f010117e:	c7 04 24 54 29 10 f0 	movl   $0xf0102954,(%esp)
f0101185:	e8 0a ef ff ff       	call   f0100094 <_panic>

f010118a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010118a:	55                   	push   %ebp
f010118b:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f010118d:	5d                   	pop    %ebp
f010118e:	c3                   	ret    

f010118f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010118f:	55                   	push   %ebp
f0101190:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101192:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101195:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101198:	5d                   	pop    %ebp
f0101199:	c3                   	ret    
	...

f010119c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010119c:	55                   	push   %ebp
f010119d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010119f:	ba 70 00 00 00       	mov    $0x70,%edx
f01011a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01011a8:	b2 71                	mov    $0x71,%dl
f01011aa:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01011ab:	0f b6 c0             	movzbl %al,%eax
}
f01011ae:	5d                   	pop    %ebp
f01011af:	c3                   	ret    

f01011b0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01011b0:	55                   	push   %ebp
f01011b1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01011b3:	ba 70 00 00 00       	mov    $0x70,%edx
f01011b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01011bb:	ee                   	out    %al,(%dx)
f01011bc:	b2 71                	mov    $0x71,%dl
f01011be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01011c2:	5d                   	pop    %ebp
f01011c3:	c3                   	ret    

f01011c4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01011c4:	55                   	push   %ebp
f01011c5:	89 e5                	mov    %esp,%ebp
f01011c7:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01011ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01011cd:	89 04 24             	mov    %eax,(%esp)
f01011d0:	e8 1b f4 ff ff       	call   f01005f0 <cputchar>
	*cnt++;
}
f01011d5:	c9                   	leave  
f01011d6:	c3                   	ret    

f01011d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01011d7:	55                   	push   %ebp
f01011d8:	89 e5                	mov    %esp,%ebp
f01011da:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01011dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011f9:	c7 04 24 c4 11 10 f0 	movl   $0xf01011c4,(%esp)
f0101200:	e8 b5 04 00 00       	call   f01016ba <vprintfmt>
	return cnt;
}
f0101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101208:	c9                   	leave  
f0101209:	c3                   	ret    

f010120a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010120a:	55                   	push   %ebp
f010120b:	89 e5                	mov    %esp,%ebp
f010120d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101210:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101213:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101217:	8b 45 08             	mov    0x8(%ebp),%eax
f010121a:	89 04 24             	mov    %eax,(%esp)
f010121d:	e8 b5 ff ff ff       	call   f01011d7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0101222:	c9                   	leave  
f0101223:	c3                   	ret    

f0101224 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101224:	55                   	push   %ebp
f0101225:	89 e5                	mov    %esp,%ebp
f0101227:	57                   	push   %edi
f0101228:	56                   	push   %esi
f0101229:	53                   	push   %ebx
f010122a:	83 ec 10             	sub    $0x10,%esp
f010122d:	89 c3                	mov    %eax,%ebx
f010122f:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101232:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101235:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101238:	8b 0a                	mov    (%edx),%ecx
f010123a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010123d:	8b 00                	mov    (%eax),%eax
f010123f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101242:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0101249:	eb 77                	jmp    f01012c2 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f010124b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010124e:	01 c8                	add    %ecx,%eax
f0101250:	bf 02 00 00 00       	mov    $0x2,%edi
f0101255:	99                   	cltd   
f0101256:	f7 ff                	idiv   %edi
f0101258:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010125a:	eb 01                	jmp    f010125d <stab_binsearch+0x39>
			m--;
f010125c:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010125d:	39 ca                	cmp    %ecx,%edx
f010125f:	7c 1d                	jl     f010127e <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101261:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101264:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0101269:	39 f7                	cmp    %esi,%edi
f010126b:	75 ef                	jne    f010125c <stab_binsearch+0x38>
f010126d:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101270:	6b fa 0c             	imul   $0xc,%edx,%edi
f0101273:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0101277:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f010127a:	73 18                	jae    f0101294 <stab_binsearch+0x70>
f010127c:	eb 05                	jmp    f0101283 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010127e:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0101281:	eb 3f                	jmp    f01012c2 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0101283:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101286:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0101288:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010128b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101292:	eb 2e                	jmp    f01012c2 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0101294:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0101297:	76 15                	jbe    f01012ae <stab_binsearch+0x8a>
			*region_right = m - 1;
f0101299:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010129c:	4f                   	dec    %edi
f010129d:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01012a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012a3:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01012a5:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01012ac:	eb 14                	jmp    f01012c2 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01012ae:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01012b1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01012b4:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f01012b6:	ff 45 0c             	incl   0xc(%ebp)
f01012b9:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01012bb:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01012c2:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01012c5:	7e 84                	jle    f010124b <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01012c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01012cb:	75 0d                	jne    f01012da <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f01012cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01012d0:	8b 02                	mov    (%edx),%eax
f01012d2:	48                   	dec    %eax
f01012d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01012d6:	89 01                	mov    %eax,(%ecx)
f01012d8:	eb 22                	jmp    f01012fc <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01012da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01012dd:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01012df:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01012e2:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01012e4:	eb 01                	jmp    f01012e7 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01012e6:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01012e7:	39 c1                	cmp    %eax,%ecx
f01012e9:	7d 0c                	jge    f01012f7 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01012eb:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f01012ee:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f01012f3:	39 f2                	cmp    %esi,%edx
f01012f5:	75 ef                	jne    f01012e6 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f01012f7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01012fa:	89 02                	mov    %eax,(%edx)
	}
}
f01012fc:	83 c4 10             	add    $0x10,%esp
f01012ff:	5b                   	pop    %ebx
f0101300:	5e                   	pop    %esi
f0101301:	5f                   	pop    %edi
f0101302:	5d                   	pop    %ebp
f0101303:	c3                   	ret    

f0101304 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101304:	55                   	push   %ebp
f0101305:	89 e5                	mov    %esp,%ebp
f0101307:	83 ec 58             	sub    $0x58,%esp
f010130a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010130d:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101310:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101313:	8b 75 08             	mov    0x8(%ebp),%esi
f0101316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101319:	c7 03 a4 2b 10 f0    	movl   $0xf0102ba4,(%ebx)
	info->eip_line = 0;
f010131f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101326:	c7 43 08 a4 2b 10 f0 	movl   $0xf0102ba4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010132d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101334:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101337:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010133e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101344:	76 12                	jbe    f0101358 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101346:	b8 b5 9b 10 f0       	mov    $0xf0109bb5,%eax
f010134b:	3d ad 7d 10 f0       	cmp    $0xf0107dad,%eax
f0101350:	0f 86 f1 01 00 00    	jbe    f0101547 <debuginfo_eip+0x243>
f0101356:	eb 1c                	jmp    f0101374 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101358:	c7 44 24 08 ae 2b 10 	movl   $0xf0102bae,0x8(%esp)
f010135f:	f0 
f0101360:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0101367:	00 
f0101368:	c7 04 24 bb 2b 10 f0 	movl   $0xf0102bbb,(%esp)
f010136f:	e8 20 ed ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101379:	80 3d b4 9b 10 f0 00 	cmpb   $0x0,0xf0109bb4
f0101380:	0f 85 cd 01 00 00    	jne    f0101553 <debuginfo_eip+0x24f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101386:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010138d:	b8 ac 7d 10 f0       	mov    $0xf0107dac,%eax
f0101392:	2d f0 2d 10 f0       	sub    $0xf0102df0,%eax
f0101397:	c1 f8 02             	sar    $0x2,%eax
f010139a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01013a0:	83 e8 01             	sub    $0x1,%eax
f01013a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01013a6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013aa:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01013b1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01013b4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01013b7:	b8 f0 2d 10 f0       	mov    $0xf0102df0,%eax
f01013bc:	e8 63 fe ff ff       	call   f0101224 <stab_binsearch>
	if (lfile == 0)
f01013c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01013c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01013c9:	85 d2                	test   %edx,%edx
f01013cb:	0f 84 82 01 00 00    	je     f0101553 <debuginfo_eip+0x24f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01013d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01013d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01013da:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013de:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01013e5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01013e8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01013eb:	b8 f0 2d 10 f0       	mov    $0xf0102df0,%eax
f01013f0:	e8 2f fe ff ff       	call   f0101224 <stab_binsearch>

	if (lfun <= rfun) {
f01013f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01013f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01013fb:	39 d0                	cmp    %edx,%eax
f01013fd:	7f 3d                	jg     f010143c <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01013ff:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0101402:	8d b9 f0 2d 10 f0    	lea    -0xfefd210(%ecx),%edi
f0101408:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010140b:	8b 89 f0 2d 10 f0    	mov    -0xfefd210(%ecx),%ecx
f0101411:	bf b5 9b 10 f0       	mov    $0xf0109bb5,%edi
f0101416:	81 ef ad 7d 10 f0    	sub    $0xf0107dad,%edi
f010141c:	39 f9                	cmp    %edi,%ecx
f010141e:	73 09                	jae    f0101429 <debuginfo_eip+0x125>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101420:	81 c1 ad 7d 10 f0    	add    $0xf0107dad,%ecx
f0101426:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101429:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010142c:	8b 4f 08             	mov    0x8(%edi),%ecx
f010142f:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0101432:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0101434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0101437:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010143a:	eb 0f                	jmp    f010144b <debuginfo_eip+0x147>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010143c:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010143f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0101445:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101448:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010144b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0101452:	00 
f0101453:	8b 43 08             	mov    0x8(%ebx),%eax
f0101456:	89 04 24             	mov    %eax,(%esp)
f0101459:	e8 6c 0a 00 00       	call   f0101eca <strfind>
f010145e:	2b 43 08             	sub    0x8(%ebx),%eax
f0101461:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0101464:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101468:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010146f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0101472:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0101475:	b8 f0 2d 10 f0       	mov    $0xf0102df0,%eax
f010147a:	e8 a5 fd ff ff       	call   f0101224 <stab_binsearch>

	if(lline <= rline)
f010147f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0101482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0101487:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010148a:	0f 8f c3 00 00 00    	jg     f0101553 <debuginfo_eip+0x24f>
		info->eip_line = stabs[lline].n_desc;
f0101490:	6b d2 0c             	imul   $0xc,%edx,%edx
f0101493:	0f b7 82 f6 2d 10 f0 	movzwl -0xfefd20a(%edx),%eax
f010149a:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010149d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01014a3:	39 c8                	cmp    %ecx,%eax
f01014a5:	7c 5f                	jl     f0101506 <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f01014a7:	89 c2                	mov    %eax,%edx
f01014a9:	6b f0 0c             	imul   $0xc,%eax,%esi
f01014ac:	80 be f4 2d 10 f0 84 	cmpb   $0x84,-0xfefd20c(%esi)
f01014b3:	75 18                	jne    f01014cd <debuginfo_eip+0x1c9>
f01014b5:	eb 30                	jmp    f01014e7 <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01014b7:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01014ba:	39 c1                	cmp    %eax,%ecx
f01014bc:	7f 48                	jg     f0101506 <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f01014be:	89 c2                	mov    %eax,%edx
f01014c0:	8d 34 40             	lea    (%eax,%eax,2),%esi
f01014c3:	80 3c b5 f4 2d 10 f0 	cmpb   $0x84,-0xfefd20c(,%esi,4)
f01014ca:	84 
f01014cb:	74 1a                	je     f01014e7 <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01014cd:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01014d0:	8d 14 95 f0 2d 10 f0 	lea    -0xfefd210(,%edx,4),%edx
f01014d7:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f01014db:	75 da                	jne    f01014b7 <debuginfo_eip+0x1b3>
f01014dd:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01014e1:	74 d4                	je     f01014b7 <debuginfo_eip+0x1b3>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01014e3:	39 c1                	cmp    %eax,%ecx
f01014e5:	7f 1f                	jg     f0101506 <debuginfo_eip+0x202>
f01014e7:	6b c0 0c             	imul   $0xc,%eax,%eax
f01014ea:	8b 80 f0 2d 10 f0    	mov    -0xfefd210(%eax),%eax
f01014f0:	ba b5 9b 10 f0       	mov    $0xf0109bb5,%edx
f01014f5:	81 ea ad 7d 10 f0    	sub    $0xf0107dad,%edx
f01014fb:	39 d0                	cmp    %edx,%eax
f01014fd:	73 07                	jae    f0101506 <debuginfo_eip+0x202>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01014ff:	05 ad 7d 10 f0       	add    $0xf0107dad,%eax
f0101504:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101506:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101509:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010150c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101511:	39 ca                	cmp    %ecx,%edx
f0101513:	7d 3e                	jge    f0101553 <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
f0101515:	83 c2 01             	add    $0x1,%edx
f0101518:	39 d1                	cmp    %edx,%ecx
f010151a:	7e 37                	jle    f0101553 <debuginfo_eip+0x24f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010151c:	6b f2 0c             	imul   $0xc,%edx,%esi
f010151f:	80 be f4 2d 10 f0 a0 	cmpb   $0xa0,-0xfefd20c(%esi)
f0101526:	75 2b                	jne    f0101553 <debuginfo_eip+0x24f>
		     lline++)
			info->eip_fn_narg++;
f0101528:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010152c:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010152f:	39 d1                	cmp    %edx,%ecx
f0101531:	7e 1b                	jle    f010154e <debuginfo_eip+0x24a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101533:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101536:	80 3c 85 f4 2d 10 f0 	cmpb   $0xa0,-0xfefd20c(,%eax,4)
f010153d:	a0 
f010153e:	74 e8                	je     f0101528 <debuginfo_eip+0x224>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101540:	b8 00 00 00 00       	mov    $0x0,%eax
f0101545:	eb 0c                	jmp    f0101553 <debuginfo_eip+0x24f>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010154c:	eb 05                	jmp    f0101553 <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010154e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101553:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101556:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101559:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010155c:	89 ec                	mov    %ebp,%esp
f010155e:	5d                   	pop    %ebp
f010155f:	c3                   	ret    

f0101560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101560:	55                   	push   %ebp
f0101561:	89 e5                	mov    %esp,%ebp
f0101563:	57                   	push   %edi
f0101564:	56                   	push   %esi
f0101565:	53                   	push   %ebx
f0101566:	83 ec 3c             	sub    $0x3c,%esp
f0101569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010156c:	89 d7                	mov    %edx,%edi
f010156e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101571:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101574:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101577:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010157a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010157d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101580:	b8 00 00 00 00       	mov    $0x0,%eax
f0101585:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0101588:	72 11                	jb     f010159b <printnum+0x3b>
f010158a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010158d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101590:	76 09                	jbe    f010159b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101592:	83 eb 01             	sub    $0x1,%ebx
f0101595:	85 db                	test   %ebx,%ebx
f0101597:	7f 51                	jg     f01015ea <printnum+0x8a>
f0101599:	eb 5e                	jmp    f01015f9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010159b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010159f:	83 eb 01             	sub    $0x1,%ebx
f01015a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01015a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01015a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015ad:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01015b1:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01015b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01015bc:	00 
f01015bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01015c0:	89 04 24             	mov    %eax,(%esp)
f01015c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015ca:	e8 71 0b 00 00       	call   f0102140 <__udivdi3>
f01015cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01015d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01015d7:	89 04 24             	mov    %eax,(%esp)
f01015da:	89 54 24 04          	mov    %edx,0x4(%esp)
f01015de:	89 fa                	mov    %edi,%edx
f01015e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015e3:	e8 78 ff ff ff       	call   f0101560 <printnum>
f01015e8:	eb 0f                	jmp    f01015f9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01015ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015ee:	89 34 24             	mov    %esi,(%esp)
f01015f1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01015f4:	83 eb 01             	sub    $0x1,%ebx
f01015f7:	75 f1                	jne    f01015ea <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01015f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101601:	8b 45 10             	mov    0x10(%ebp),%eax
f0101604:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101608:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010160f:	00 
f0101610:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101613:	89 04 24             	mov    %eax,(%esp)
f0101616:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101619:	89 44 24 04          	mov    %eax,0x4(%esp)
f010161d:	e8 4e 0c 00 00       	call   f0102270 <__umoddi3>
f0101622:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101626:	0f be 80 c9 2b 10 f0 	movsbl -0xfefd437(%eax),%eax
f010162d:	89 04 24             	mov    %eax,(%esp)
f0101630:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0101633:	83 c4 3c             	add    $0x3c,%esp
f0101636:	5b                   	pop    %ebx
f0101637:	5e                   	pop    %esi
f0101638:	5f                   	pop    %edi
f0101639:	5d                   	pop    %ebp
f010163a:	c3                   	ret    

f010163b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010163b:	55                   	push   %ebp
f010163c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010163e:	83 fa 01             	cmp    $0x1,%edx
f0101641:	7e 0e                	jle    f0101651 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101643:	8b 10                	mov    (%eax),%edx
f0101645:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101648:	89 08                	mov    %ecx,(%eax)
f010164a:	8b 02                	mov    (%edx),%eax
f010164c:	8b 52 04             	mov    0x4(%edx),%edx
f010164f:	eb 22                	jmp    f0101673 <getuint+0x38>
	else if (lflag)
f0101651:	85 d2                	test   %edx,%edx
f0101653:	74 10                	je     f0101665 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101655:	8b 10                	mov    (%eax),%edx
f0101657:	8d 4a 04             	lea    0x4(%edx),%ecx
f010165a:	89 08                	mov    %ecx,(%eax)
f010165c:	8b 02                	mov    (%edx),%eax
f010165e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101663:	eb 0e                	jmp    f0101673 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101665:	8b 10                	mov    (%eax),%edx
f0101667:	8d 4a 04             	lea    0x4(%edx),%ecx
f010166a:	89 08                	mov    %ecx,(%eax)
f010166c:	8b 02                	mov    (%edx),%eax
f010166e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101673:	5d                   	pop    %ebp
f0101674:	c3                   	ret    

f0101675 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101675:	55                   	push   %ebp
f0101676:	89 e5                	mov    %esp,%ebp
f0101678:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010167b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010167f:	8b 10                	mov    (%eax),%edx
f0101681:	3b 50 04             	cmp    0x4(%eax),%edx
f0101684:	73 0a                	jae    f0101690 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101686:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101689:	88 0a                	mov    %cl,(%edx)
f010168b:	83 c2 01             	add    $0x1,%edx
f010168e:	89 10                	mov    %edx,(%eax)
}
f0101690:	5d                   	pop    %ebp
f0101691:	c3                   	ret    

f0101692 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101692:	55                   	push   %ebp
f0101693:	89 e5                	mov    %esp,%ebp
f0101695:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101698:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010169b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010169f:	8b 45 10             	mov    0x10(%ebp),%eax
f01016a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01016b0:	89 04 24             	mov    %eax,(%esp)
f01016b3:	e8 02 00 00 00       	call   f01016ba <vprintfmt>
	va_end(ap);
}
f01016b8:	c9                   	leave  
f01016b9:	c3                   	ret    

f01016ba <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01016ba:	55                   	push   %ebp
f01016bb:	89 e5                	mov    %esp,%ebp
f01016bd:	57                   	push   %edi
f01016be:	56                   	push   %esi
f01016bf:	53                   	push   %ebx
f01016c0:	83 ec 5c             	sub    $0x5c,%esp
f01016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016c6:	8b 75 10             	mov    0x10(%ebp),%esi
f01016c9:	eb 12                	jmp    f01016dd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01016cb:	85 c0                	test   %eax,%eax
f01016cd:	0f 84 e4 04 00 00    	je     f0101bb7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f01016d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016d7:	89 04 24             	mov    %eax,(%esp)
f01016da:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01016dd:	0f b6 06             	movzbl (%esi),%eax
f01016e0:	83 c6 01             	add    $0x1,%esi
f01016e3:	83 f8 25             	cmp    $0x25,%eax
f01016e6:	75 e3                	jne    f01016cb <vprintfmt+0x11>
f01016e8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f01016ec:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f01016f3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01016f8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01016ff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101704:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0101707:	eb 2b                	jmp    f0101734 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101709:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010170c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0101710:	eb 22                	jmp    f0101734 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101712:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101715:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0101719:	eb 19                	jmp    f0101734 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010171b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f010171e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0101725:	eb 0d                	jmp    f0101734 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101727:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010172a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010172d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101734:	0f b6 06             	movzbl (%esi),%eax
f0101737:	0f b6 d0             	movzbl %al,%edx
f010173a:	8d 7e 01             	lea    0x1(%esi),%edi
f010173d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101740:	83 e8 23             	sub    $0x23,%eax
f0101743:	3c 55                	cmp    $0x55,%al
f0101745:	0f 87 46 04 00 00    	ja     f0101b91 <vprintfmt+0x4d7>
f010174b:	0f b6 c0             	movzbl %al,%eax
f010174e:	ff 24 85 6c 2c 10 f0 	jmp    *-0xfefd394(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101755:	83 ea 30             	sub    $0x30,%edx
f0101758:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f010175b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f010175f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101762:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0101765:	83 fa 09             	cmp    $0x9,%edx
f0101768:	77 4a                	ja     f01017b4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010176a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010176d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0101770:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0101773:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0101777:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010177a:	8d 50 d0             	lea    -0x30(%eax),%edx
f010177d:	83 fa 09             	cmp    $0x9,%edx
f0101780:	76 eb                	jbe    f010176d <vprintfmt+0xb3>
f0101782:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0101785:	eb 2d                	jmp    f01017b4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101787:	8b 45 14             	mov    0x14(%ebp),%eax
f010178a:	8d 50 04             	lea    0x4(%eax),%edx
f010178d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101790:	8b 00                	mov    (%eax),%eax
f0101792:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101795:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101798:	eb 1a                	jmp    f01017b4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010179a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f010179d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01017a1:	79 91                	jns    f0101734 <vprintfmt+0x7a>
f01017a3:	e9 73 ff ff ff       	jmp    f010171b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01017a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01017ab:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f01017b2:	eb 80                	jmp    f0101734 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f01017b4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01017b8:	0f 89 76 ff ff ff    	jns    f0101734 <vprintfmt+0x7a>
f01017be:	e9 64 ff ff ff       	jmp    f0101727 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01017c3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01017c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01017c9:	e9 66 ff ff ff       	jmp    f0101734 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01017ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01017d1:	8d 50 04             	lea    0x4(%eax),%edx
f01017d4:	89 55 14             	mov    %edx,0x14(%ebp)
f01017d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017db:	8b 00                	mov    (%eax),%eax
f01017dd:	89 04 24             	mov    %eax,(%esp)
f01017e0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01017e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01017e6:	e9 f2 fe ff ff       	jmp    f01016dd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f01017eb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01017ef:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f01017f2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f01017f6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f01017f9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f01017fd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0101800:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0101803:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0101807:	8d 48 d0             	lea    -0x30(%eax),%ecx
f010180a:	80 f9 09             	cmp    $0x9,%cl
f010180d:	77 1d                	ja     f010182c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f010180f:	0f be c0             	movsbl %al,%eax
f0101812:	6b c0 64             	imul   $0x64,%eax,%eax
f0101815:	0f be d2             	movsbl %dl,%edx
f0101818:	8d 14 92             	lea    (%edx,%edx,4),%edx
f010181b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0101822:	a3 04 43 11 f0       	mov    %eax,0xf0114304
f0101827:	e9 b1 fe ff ff       	jmp    f01016dd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f010182c:	c7 44 24 04 e1 2b 10 	movl   $0xf0102be1,0x4(%esp)
f0101833:	f0 
f0101834:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101837:	89 04 24             	mov    %eax,(%esp)
f010183a:	e8 dc 05 00 00       	call   f0101e1b <strcmp>
f010183f:	85 c0                	test   %eax,%eax
f0101841:	75 0f                	jne    f0101852 <vprintfmt+0x198>
f0101843:	c7 05 04 43 11 f0 04 	movl   $0x4,0xf0114304
f010184a:	00 00 00 
f010184d:	e9 8b fe ff ff       	jmp    f01016dd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0101852:	c7 44 24 04 e5 2b 10 	movl   $0xf0102be5,0x4(%esp)
f0101859:	f0 
f010185a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010185d:	89 14 24             	mov    %edx,(%esp)
f0101860:	e8 b6 05 00 00       	call   f0101e1b <strcmp>
f0101865:	85 c0                	test   %eax,%eax
f0101867:	75 0f                	jne    f0101878 <vprintfmt+0x1be>
f0101869:	c7 05 04 43 11 f0 02 	movl   $0x2,0xf0114304
f0101870:	00 00 00 
f0101873:	e9 65 fe ff ff       	jmp    f01016dd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0101878:	c7 44 24 04 e9 2b 10 	movl   $0xf0102be9,0x4(%esp)
f010187f:	f0 
f0101880:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0101883:	89 0c 24             	mov    %ecx,(%esp)
f0101886:	e8 90 05 00 00       	call   f0101e1b <strcmp>
f010188b:	85 c0                	test   %eax,%eax
f010188d:	75 0f                	jne    f010189e <vprintfmt+0x1e4>
f010188f:	c7 05 04 43 11 f0 01 	movl   $0x1,0xf0114304
f0101896:	00 00 00 
f0101899:	e9 3f fe ff ff       	jmp    f01016dd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f010189e:	c7 44 24 04 ed 2b 10 	movl   $0xf0102bed,0x4(%esp)
f01018a5:	f0 
f01018a6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f01018a9:	89 3c 24             	mov    %edi,(%esp)
f01018ac:	e8 6a 05 00 00       	call   f0101e1b <strcmp>
f01018b1:	85 c0                	test   %eax,%eax
f01018b3:	75 0f                	jne    f01018c4 <vprintfmt+0x20a>
f01018b5:	c7 05 04 43 11 f0 06 	movl   $0x6,0xf0114304
f01018bc:	00 00 00 
f01018bf:	e9 19 fe ff ff       	jmp    f01016dd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f01018c4:	c7 44 24 04 f1 2b 10 	movl   $0xf0102bf1,0x4(%esp)
f01018cb:	f0 
f01018cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018cf:	89 04 24             	mov    %eax,(%esp)
f01018d2:	e8 44 05 00 00       	call   f0101e1b <strcmp>
f01018d7:	85 c0                	test   %eax,%eax
f01018d9:	75 0f                	jne    f01018ea <vprintfmt+0x230>
f01018db:	c7 05 04 43 11 f0 07 	movl   $0x7,0xf0114304
f01018e2:	00 00 00 
f01018e5:	e9 f3 fd ff ff       	jmp    f01016dd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f01018ea:	c7 44 24 04 f5 2b 10 	movl   $0xf0102bf5,0x4(%esp)
f01018f1:	f0 
f01018f2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01018f5:	89 14 24             	mov    %edx,(%esp)
f01018f8:	e8 1e 05 00 00       	call   f0101e1b <strcmp>
f01018fd:	83 f8 01             	cmp    $0x1,%eax
f0101900:	19 c0                	sbb    %eax,%eax
f0101902:	f7 d0                	not    %eax
f0101904:	83 c0 08             	add    $0x8,%eax
f0101907:	a3 04 43 11 f0       	mov    %eax,0xf0114304
f010190c:	e9 cc fd ff ff       	jmp    f01016dd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0101911:	8b 45 14             	mov    0x14(%ebp),%eax
f0101914:	8d 50 04             	lea    0x4(%eax),%edx
f0101917:	89 55 14             	mov    %edx,0x14(%ebp)
f010191a:	8b 00                	mov    (%eax),%eax
f010191c:	89 c2                	mov    %eax,%edx
f010191e:	c1 fa 1f             	sar    $0x1f,%edx
f0101921:	31 d0                	xor    %edx,%eax
f0101923:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101925:	83 f8 06             	cmp    $0x6,%eax
f0101928:	7f 0b                	jg     f0101935 <vprintfmt+0x27b>
f010192a:	8b 14 85 c4 2d 10 f0 	mov    -0xfefd23c(,%eax,4),%edx
f0101931:	85 d2                	test   %edx,%edx
f0101933:	75 23                	jne    f0101958 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0101935:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101939:	c7 44 24 08 f9 2b 10 	movl   $0xf0102bf9,0x8(%esp)
f0101940:	f0 
f0101941:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101945:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101948:	89 3c 24             	mov    %edi,(%esp)
f010194b:	e8 42 fd ff ff       	call   f0101692 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101950:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101953:	e9 85 fd ff ff       	jmp    f01016dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0101958:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010195c:	c7 44 24 08 98 29 10 	movl   $0xf0102998,0x8(%esp)
f0101963:	f0 
f0101964:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101968:	8b 7d 08             	mov    0x8(%ebp),%edi
f010196b:	89 3c 24             	mov    %edi,(%esp)
f010196e:	e8 1f fd ff ff       	call   f0101692 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101973:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101976:	e9 62 fd ff ff       	jmp    f01016dd <vprintfmt+0x23>
f010197b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010197e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101981:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101984:	8b 45 14             	mov    0x14(%ebp),%eax
f0101987:	8d 50 04             	lea    0x4(%eax),%edx
f010198a:	89 55 14             	mov    %edx,0x14(%ebp)
f010198d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010198f:	85 f6                	test   %esi,%esi
f0101991:	b8 da 2b 10 f0       	mov    $0xf0102bda,%eax
f0101996:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0101999:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f010199d:	7e 06                	jle    f01019a5 <vprintfmt+0x2eb>
f010199f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f01019a3:	75 13                	jne    f01019b8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01019a5:	0f be 06             	movsbl (%esi),%eax
f01019a8:	83 c6 01             	add    $0x1,%esi
f01019ab:	85 c0                	test   %eax,%eax
f01019ad:	0f 85 94 00 00 00    	jne    f0101a47 <vprintfmt+0x38d>
f01019b3:	e9 81 00 00 00       	jmp    f0101a39 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01019b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01019bc:	89 34 24             	mov    %esi,(%esp)
f01019bf:	e8 67 03 00 00       	call   f0101d2b <strnlen>
f01019c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01019c7:	29 c2                	sub    %eax,%edx
f01019c9:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01019cc:	85 d2                	test   %edx,%edx
f01019ce:	7e d5                	jle    f01019a5 <vprintfmt+0x2eb>
					putch(padc, putdat);
f01019d0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f01019d4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01019d7:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01019da:	89 d6                	mov    %edx,%esi
f01019dc:	89 cf                	mov    %ecx,%edi
f01019de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019e2:	89 3c 24             	mov    %edi,(%esp)
f01019e5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01019e8:	83 ee 01             	sub    $0x1,%esi
f01019eb:	75 f1                	jne    f01019de <vprintfmt+0x324>
f01019ed:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01019f0:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01019f3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01019f6:	eb ad                	jmp    f01019a5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01019f8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01019fc:	74 1b                	je     f0101a19 <vprintfmt+0x35f>
f01019fe:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101a01:	83 fa 5e             	cmp    $0x5e,%edx
f0101a04:	76 13                	jbe    f0101a19 <vprintfmt+0x35f>
					putch('?', putdat);
f0101a06:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a0d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101a14:	ff 55 08             	call   *0x8(%ebp)
f0101a17:	eb 0d                	jmp    f0101a26 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0101a19:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a1c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101a20:	89 04 24             	mov    %eax,(%esp)
f0101a23:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101a26:	83 eb 01             	sub    $0x1,%ebx
f0101a29:	0f be 06             	movsbl (%esi),%eax
f0101a2c:	83 c6 01             	add    $0x1,%esi
f0101a2f:	85 c0                	test   %eax,%eax
f0101a31:	75 1a                	jne    f0101a4d <vprintfmt+0x393>
f0101a33:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101a36:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101a39:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101a3c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0101a40:	7f 1c                	jg     f0101a5e <vprintfmt+0x3a4>
f0101a42:	e9 96 fc ff ff       	jmp    f01016dd <vprintfmt+0x23>
f0101a47:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101a4a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101a4d:	85 ff                	test   %edi,%edi
f0101a4f:	78 a7                	js     f01019f8 <vprintfmt+0x33e>
f0101a51:	83 ef 01             	sub    $0x1,%edi
f0101a54:	79 a2                	jns    f01019f8 <vprintfmt+0x33e>
f0101a56:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101a59:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101a5c:	eb db                	jmp    f0101a39 <vprintfmt+0x37f>
f0101a5e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101a61:	89 de                	mov    %ebx,%esi
f0101a63:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101a66:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101a71:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101a73:	83 eb 01             	sub    $0x1,%ebx
f0101a76:	75 ee                	jne    f0101a66 <vprintfmt+0x3ac>
f0101a78:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101a7a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101a7d:	e9 5b fc ff ff       	jmp    f01016dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101a82:	83 f9 01             	cmp    $0x1,%ecx
f0101a85:	7e 10                	jle    f0101a97 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f0101a87:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a8a:	8d 50 08             	lea    0x8(%eax),%edx
f0101a8d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101a90:	8b 30                	mov    (%eax),%esi
f0101a92:	8b 78 04             	mov    0x4(%eax),%edi
f0101a95:	eb 26                	jmp    f0101abd <vprintfmt+0x403>
	else if (lflag)
f0101a97:	85 c9                	test   %ecx,%ecx
f0101a99:	74 12                	je     f0101aad <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f0101a9b:	8b 45 14             	mov    0x14(%ebp),%eax
f0101a9e:	8d 50 04             	lea    0x4(%eax),%edx
f0101aa1:	89 55 14             	mov    %edx,0x14(%ebp)
f0101aa4:	8b 30                	mov    (%eax),%esi
f0101aa6:	89 f7                	mov    %esi,%edi
f0101aa8:	c1 ff 1f             	sar    $0x1f,%edi
f0101aab:	eb 10                	jmp    f0101abd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0101aad:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ab0:	8d 50 04             	lea    0x4(%eax),%edx
f0101ab3:	89 55 14             	mov    %edx,0x14(%ebp)
f0101ab6:	8b 30                	mov    (%eax),%esi
f0101ab8:	89 f7                	mov    %esi,%edi
f0101aba:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101abd:	85 ff                	test   %edi,%edi
f0101abf:	78 0e                	js     f0101acf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101ac1:	89 f0                	mov    %esi,%eax
f0101ac3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101ac5:	be 0a 00 00 00       	mov    $0xa,%esi
f0101aca:	e9 84 00 00 00       	jmp    f0101b53 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0101acf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ad3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101ada:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101add:	89 f0                	mov    %esi,%eax
f0101adf:	89 fa                	mov    %edi,%edx
f0101ae1:	f7 d8                	neg    %eax
f0101ae3:	83 d2 00             	adc    $0x0,%edx
f0101ae6:	f7 da                	neg    %edx
			}
			base = 10;
f0101ae8:	be 0a 00 00 00       	mov    $0xa,%esi
f0101aed:	eb 64                	jmp    f0101b53 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101aef:	89 ca                	mov    %ecx,%edx
f0101af1:	8d 45 14             	lea    0x14(%ebp),%eax
f0101af4:	e8 42 fb ff ff       	call   f010163b <getuint>
			base = 10;
f0101af9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0101afe:	eb 53                	jmp    f0101b53 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0101b00:	89 ca                	mov    %ecx,%edx
f0101b02:	8d 45 14             	lea    0x14(%ebp),%eax
f0101b05:	e8 31 fb ff ff       	call   f010163b <getuint>
    			base = 8;
f0101b0a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0101b0f:	eb 42                	jmp    f0101b53 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0101b11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b15:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101b1c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101b1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b23:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101b2a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101b2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b30:	8d 50 04             	lea    0x4(%eax),%edx
f0101b33:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101b36:	8b 00                	mov    (%eax),%eax
f0101b38:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101b3d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0101b42:	eb 0f                	jmp    f0101b53 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101b44:	89 ca                	mov    %ecx,%edx
f0101b46:	8d 45 14             	lea    0x14(%ebp),%eax
f0101b49:	e8 ed fa ff ff       	call   f010163b <getuint>
			base = 16;
f0101b4e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101b53:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0101b57:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101b5b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101b5e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101b62:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101b66:	89 04 24             	mov    %eax,(%esp)
f0101b69:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101b6d:	89 da                	mov    %ebx,%edx
f0101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b72:	e8 e9 f9 ff ff       	call   f0101560 <printnum>
			break;
f0101b77:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101b7a:	e9 5e fb ff ff       	jmp    f01016dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101b7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b83:	89 14 24             	mov    %edx,(%esp)
f0101b86:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b89:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101b8c:	e9 4c fb ff ff       	jmp    f01016dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101b91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b95:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101b9c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101b9f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101ba3:	0f 84 34 fb ff ff    	je     f01016dd <vprintfmt+0x23>
f0101ba9:	83 ee 01             	sub    $0x1,%esi
f0101bac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101bb0:	75 f7                	jne    f0101ba9 <vprintfmt+0x4ef>
f0101bb2:	e9 26 fb ff ff       	jmp    f01016dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0101bb7:	83 c4 5c             	add    $0x5c,%esp
f0101bba:	5b                   	pop    %ebx
f0101bbb:	5e                   	pop    %esi
f0101bbc:	5f                   	pop    %edi
f0101bbd:	5d                   	pop    %ebp
f0101bbe:	c3                   	ret    

f0101bbf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101bbf:	55                   	push   %ebp
f0101bc0:	89 e5                	mov    %esp,%ebp
f0101bc2:	83 ec 28             	sub    $0x28,%esp
f0101bc5:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101bcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101bce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101bd2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101bd5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101bdc:	85 c0                	test   %eax,%eax
f0101bde:	74 30                	je     f0101c10 <vsnprintf+0x51>
f0101be0:	85 d2                	test   %edx,%edx
f0101be2:	7e 2c                	jle    f0101c10 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101be4:	8b 45 14             	mov    0x14(%ebp),%eax
f0101be7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101beb:	8b 45 10             	mov    0x10(%ebp),%eax
f0101bee:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bf2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bf9:	c7 04 24 75 16 10 f0 	movl   $0xf0101675,(%esp)
f0101c00:	e8 b5 fa ff ff       	call   f01016ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101c05:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101c08:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c0e:	eb 05                	jmp    f0101c15 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101c10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101c15:	c9                   	leave  
f0101c16:	c3                   	ret    

f0101c17 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101c17:	55                   	push   %ebp
f0101c18:	89 e5                	mov    %esp,%ebp
f0101c1a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101c1d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101c20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c24:	8b 45 10             	mov    0x10(%ebp),%eax
f0101c27:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c32:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c35:	89 04 24             	mov    %eax,(%esp)
f0101c38:	e8 82 ff ff ff       	call   f0101bbf <vsnprintf>
	va_end(ap);

	return rc;
}
f0101c3d:	c9                   	leave  
f0101c3e:	c3                   	ret    
	...

f0101c40 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101c40:	55                   	push   %ebp
f0101c41:	89 e5                	mov    %esp,%ebp
f0101c43:	57                   	push   %edi
f0101c44:	56                   	push   %esi
f0101c45:	53                   	push   %ebx
f0101c46:	83 ec 1c             	sub    $0x1c,%esp
f0101c49:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101c4c:	85 c0                	test   %eax,%eax
f0101c4e:	74 10                	je     f0101c60 <readline+0x20>
		cprintf("%s", prompt);
f0101c50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c54:	c7 04 24 98 29 10 f0 	movl   $0xf0102998,(%esp)
f0101c5b:	e8 aa f5 ff ff       	call   f010120a <cprintf>

	i = 0;
	echoing = iscons(0);
f0101c60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c67:	e8 a5 e9 ff ff       	call   f0100611 <iscons>
f0101c6c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101c6e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101c73:	e8 88 e9 ff ff       	call   f0100600 <getchar>
f0101c78:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101c7a:	85 c0                	test   %eax,%eax
f0101c7c:	79 17                	jns    f0101c95 <readline+0x55>
			cprintf("read error: %e\n", c);
f0101c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c82:	c7 04 24 e0 2d 10 f0 	movl   $0xf0102de0,(%esp)
f0101c89:	e8 7c f5 ff ff       	call   f010120a <cprintf>
			return NULL;
f0101c8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c93:	eb 6d                	jmp    f0101d02 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101c95:	83 f8 08             	cmp    $0x8,%eax
f0101c98:	74 05                	je     f0101c9f <readline+0x5f>
f0101c9a:	83 f8 7f             	cmp    $0x7f,%eax
f0101c9d:	75 19                	jne    f0101cb8 <readline+0x78>
f0101c9f:	85 f6                	test   %esi,%esi
f0101ca1:	7e 15                	jle    f0101cb8 <readline+0x78>
			if (echoing)
f0101ca3:	85 ff                	test   %edi,%edi
f0101ca5:	74 0c                	je     f0101cb3 <readline+0x73>
				cputchar('\b');
f0101ca7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101cae:	e8 3d e9 ff ff       	call   f01005f0 <cputchar>
			i--;
f0101cb3:	83 ee 01             	sub    $0x1,%esi
f0101cb6:	eb bb                	jmp    f0101c73 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101cb8:	83 fb 1f             	cmp    $0x1f,%ebx
f0101cbb:	7e 1f                	jle    f0101cdc <readline+0x9c>
f0101cbd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101cc3:	7f 17                	jg     f0101cdc <readline+0x9c>
			if (echoing)
f0101cc5:	85 ff                	test   %edi,%edi
f0101cc7:	74 08                	je     f0101cd1 <readline+0x91>
				cputchar(c);
f0101cc9:	89 1c 24             	mov    %ebx,(%esp)
f0101ccc:	e8 1f e9 ff ff       	call   f01005f0 <cputchar>
			buf[i++] = c;
f0101cd1:	88 9e 80 45 11 f0    	mov    %bl,-0xfeeba80(%esi)
f0101cd7:	83 c6 01             	add    $0x1,%esi
f0101cda:	eb 97                	jmp    f0101c73 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101cdc:	83 fb 0a             	cmp    $0xa,%ebx
f0101cdf:	74 05                	je     f0101ce6 <readline+0xa6>
f0101ce1:	83 fb 0d             	cmp    $0xd,%ebx
f0101ce4:	75 8d                	jne    f0101c73 <readline+0x33>
			if (echoing)
f0101ce6:	85 ff                	test   %edi,%edi
f0101ce8:	74 0c                	je     f0101cf6 <readline+0xb6>
				cputchar('\n');
f0101cea:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101cf1:	e8 fa e8 ff ff       	call   f01005f0 <cputchar>
			buf[i] = 0;
f0101cf6:	c6 86 80 45 11 f0 00 	movb   $0x0,-0xfeeba80(%esi)
			return buf;
f0101cfd:	b8 80 45 11 f0       	mov    $0xf0114580,%eax
		}
	}
}
f0101d02:	83 c4 1c             	add    $0x1c,%esp
f0101d05:	5b                   	pop    %ebx
f0101d06:	5e                   	pop    %esi
f0101d07:	5f                   	pop    %edi
f0101d08:	5d                   	pop    %ebp
f0101d09:	c3                   	ret    
f0101d0a:	00 00                	add    %al,(%eax)
f0101d0c:	00 00                	add    %al,(%eax)
	...

f0101d10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101d10:	55                   	push   %ebp
f0101d11:	89 e5                	mov    %esp,%ebp
f0101d13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101d16:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d1b:	80 3a 00             	cmpb   $0x0,(%edx)
f0101d1e:	74 09                	je     f0101d29 <strlen+0x19>
		n++;
f0101d20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101d23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101d27:	75 f7                	jne    f0101d20 <strlen+0x10>
		n++;
	return n;
}
f0101d29:	5d                   	pop    %ebp
f0101d2a:	c3                   	ret    

f0101d2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101d2b:	55                   	push   %ebp
f0101d2c:	89 e5                	mov    %esp,%ebp
f0101d2e:	53                   	push   %ebx
f0101d2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101d35:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d3a:	85 c9                	test   %ecx,%ecx
f0101d3c:	74 1a                	je     f0101d58 <strnlen+0x2d>
f0101d3e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101d41:	74 15                	je     f0101d58 <strnlen+0x2d>
f0101d43:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0101d48:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101d4a:	39 ca                	cmp    %ecx,%edx
f0101d4c:	74 0a                	je     f0101d58 <strnlen+0x2d>
f0101d4e:	83 c2 01             	add    $0x1,%edx
f0101d51:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101d56:	75 f0                	jne    f0101d48 <strnlen+0x1d>
		n++;
	return n;
}
f0101d58:	5b                   	pop    %ebx
f0101d59:	5d                   	pop    %ebp
f0101d5a:	c3                   	ret    

f0101d5b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101d5b:	55                   	push   %ebp
f0101d5c:	89 e5                	mov    %esp,%ebp
f0101d5e:	53                   	push   %ebx
f0101d5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101d65:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d6a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101d6e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101d71:	83 c2 01             	add    $0x1,%edx
f0101d74:	84 c9                	test   %cl,%cl
f0101d76:	75 f2                	jne    f0101d6a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101d78:	5b                   	pop    %ebx
f0101d79:	5d                   	pop    %ebp
f0101d7a:	c3                   	ret    

f0101d7b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101d7b:	55                   	push   %ebp
f0101d7c:	89 e5                	mov    %esp,%ebp
f0101d7e:	53                   	push   %ebx
f0101d7f:	83 ec 08             	sub    $0x8,%esp
f0101d82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101d85:	89 1c 24             	mov    %ebx,(%esp)
f0101d88:	e8 83 ff ff ff       	call   f0101d10 <strlen>
	strcpy(dst + len, src);
f0101d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101d90:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d94:	01 d8                	add    %ebx,%eax
f0101d96:	89 04 24             	mov    %eax,(%esp)
f0101d99:	e8 bd ff ff ff       	call   f0101d5b <strcpy>
	return dst;
}
f0101d9e:	89 d8                	mov    %ebx,%eax
f0101da0:	83 c4 08             	add    $0x8,%esp
f0101da3:	5b                   	pop    %ebx
f0101da4:	5d                   	pop    %ebp
f0101da5:	c3                   	ret    

f0101da6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101da6:	55                   	push   %ebp
f0101da7:	89 e5                	mov    %esp,%ebp
f0101da9:	56                   	push   %esi
f0101daa:	53                   	push   %ebx
f0101dab:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dae:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101db1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101db4:	85 f6                	test   %esi,%esi
f0101db6:	74 18                	je     f0101dd0 <strncpy+0x2a>
f0101db8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101dbd:	0f b6 1a             	movzbl (%edx),%ebx
f0101dc0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101dc3:	80 3a 01             	cmpb   $0x1,(%edx)
f0101dc6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101dc9:	83 c1 01             	add    $0x1,%ecx
f0101dcc:	39 f1                	cmp    %esi,%ecx
f0101dce:	75 ed                	jne    f0101dbd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101dd0:	5b                   	pop    %ebx
f0101dd1:	5e                   	pop    %esi
f0101dd2:	5d                   	pop    %ebp
f0101dd3:	c3                   	ret    

f0101dd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101dd4:	55                   	push   %ebp
f0101dd5:	89 e5                	mov    %esp,%ebp
f0101dd7:	57                   	push   %edi
f0101dd8:	56                   	push   %esi
f0101dd9:	53                   	push   %ebx
f0101dda:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101ddd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101de0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101de3:	89 f8                	mov    %edi,%eax
f0101de5:	85 f6                	test   %esi,%esi
f0101de7:	74 2b                	je     f0101e14 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0101de9:	83 fe 01             	cmp    $0x1,%esi
f0101dec:	74 23                	je     f0101e11 <strlcpy+0x3d>
f0101dee:	0f b6 0b             	movzbl (%ebx),%ecx
f0101df1:	84 c9                	test   %cl,%cl
f0101df3:	74 1c                	je     f0101e11 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0101df5:	83 ee 02             	sub    $0x2,%esi
f0101df8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101dfd:	88 08                	mov    %cl,(%eax)
f0101dff:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101e02:	39 f2                	cmp    %esi,%edx
f0101e04:	74 0b                	je     f0101e11 <strlcpy+0x3d>
f0101e06:	83 c2 01             	add    $0x1,%edx
f0101e09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101e0d:	84 c9                	test   %cl,%cl
f0101e0f:	75 ec                	jne    f0101dfd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0101e11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101e14:	29 f8                	sub    %edi,%eax
}
f0101e16:	5b                   	pop    %ebx
f0101e17:	5e                   	pop    %esi
f0101e18:	5f                   	pop    %edi
f0101e19:	5d                   	pop    %ebp
f0101e1a:	c3                   	ret    

f0101e1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101e1b:	55                   	push   %ebp
f0101e1c:	89 e5                	mov    %esp,%ebp
f0101e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101e21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101e24:	0f b6 01             	movzbl (%ecx),%eax
f0101e27:	84 c0                	test   %al,%al
f0101e29:	74 16                	je     f0101e41 <strcmp+0x26>
f0101e2b:	3a 02                	cmp    (%edx),%al
f0101e2d:	75 12                	jne    f0101e41 <strcmp+0x26>
		p++, q++;
f0101e2f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101e32:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0101e36:	84 c0                	test   %al,%al
f0101e38:	74 07                	je     f0101e41 <strcmp+0x26>
f0101e3a:	83 c1 01             	add    $0x1,%ecx
f0101e3d:	3a 02                	cmp    (%edx),%al
f0101e3f:	74 ee                	je     f0101e2f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101e41:	0f b6 c0             	movzbl %al,%eax
f0101e44:	0f b6 12             	movzbl (%edx),%edx
f0101e47:	29 d0                	sub    %edx,%eax
}
f0101e49:	5d                   	pop    %ebp
f0101e4a:	c3                   	ret    

f0101e4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101e4b:	55                   	push   %ebp
f0101e4c:	89 e5                	mov    %esp,%ebp
f0101e4e:	53                   	push   %ebx
f0101e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101e52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101e55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101e58:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101e5d:	85 d2                	test   %edx,%edx
f0101e5f:	74 28                	je     f0101e89 <strncmp+0x3e>
f0101e61:	0f b6 01             	movzbl (%ecx),%eax
f0101e64:	84 c0                	test   %al,%al
f0101e66:	74 24                	je     f0101e8c <strncmp+0x41>
f0101e68:	3a 03                	cmp    (%ebx),%al
f0101e6a:	75 20                	jne    f0101e8c <strncmp+0x41>
f0101e6c:	83 ea 01             	sub    $0x1,%edx
f0101e6f:	74 13                	je     f0101e84 <strncmp+0x39>
		n--, p++, q++;
f0101e71:	83 c1 01             	add    $0x1,%ecx
f0101e74:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101e77:	0f b6 01             	movzbl (%ecx),%eax
f0101e7a:	84 c0                	test   %al,%al
f0101e7c:	74 0e                	je     f0101e8c <strncmp+0x41>
f0101e7e:	3a 03                	cmp    (%ebx),%al
f0101e80:	74 ea                	je     f0101e6c <strncmp+0x21>
f0101e82:	eb 08                	jmp    f0101e8c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101e84:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101e89:	5b                   	pop    %ebx
f0101e8a:	5d                   	pop    %ebp
f0101e8b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101e8c:	0f b6 01             	movzbl (%ecx),%eax
f0101e8f:	0f b6 13             	movzbl (%ebx),%edx
f0101e92:	29 d0                	sub    %edx,%eax
f0101e94:	eb f3                	jmp    f0101e89 <strncmp+0x3e>

f0101e96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101e96:	55                   	push   %ebp
f0101e97:	89 e5                	mov    %esp,%ebp
f0101e99:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101ea0:	0f b6 10             	movzbl (%eax),%edx
f0101ea3:	84 d2                	test   %dl,%dl
f0101ea5:	74 1c                	je     f0101ec3 <strchr+0x2d>
		if (*s == c)
f0101ea7:	38 ca                	cmp    %cl,%dl
f0101ea9:	75 09                	jne    f0101eb4 <strchr+0x1e>
f0101eab:	eb 1b                	jmp    f0101ec8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101ead:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0101eb0:	38 ca                	cmp    %cl,%dl
f0101eb2:	74 14                	je     f0101ec8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101eb4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0101eb8:	84 d2                	test   %dl,%dl
f0101eba:	75 f1                	jne    f0101ead <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0101ebc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ec1:	eb 05                	jmp    f0101ec8 <strchr+0x32>
f0101ec3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101ec8:	5d                   	pop    %ebp
f0101ec9:	c3                   	ret    

f0101eca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101eca:	55                   	push   %ebp
f0101ecb:	89 e5                	mov    %esp,%ebp
f0101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ed0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101ed4:	0f b6 10             	movzbl (%eax),%edx
f0101ed7:	84 d2                	test   %dl,%dl
f0101ed9:	74 14                	je     f0101eef <strfind+0x25>
		if (*s == c)
f0101edb:	38 ca                	cmp    %cl,%dl
f0101edd:	75 06                	jne    f0101ee5 <strfind+0x1b>
f0101edf:	eb 0e                	jmp    f0101eef <strfind+0x25>
f0101ee1:	38 ca                	cmp    %cl,%dl
f0101ee3:	74 0a                	je     f0101eef <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101ee5:	83 c0 01             	add    $0x1,%eax
f0101ee8:	0f b6 10             	movzbl (%eax),%edx
f0101eeb:	84 d2                	test   %dl,%dl
f0101eed:	75 f2                	jne    f0101ee1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101eef:	5d                   	pop    %ebp
f0101ef0:	c3                   	ret    

f0101ef1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101ef1:	55                   	push   %ebp
f0101ef2:	89 e5                	mov    %esp,%ebp
f0101ef4:	83 ec 0c             	sub    $0xc,%esp
f0101ef7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101efa:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101efd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101f00:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101f03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101f06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101f09:	85 c9                	test   %ecx,%ecx
f0101f0b:	74 30                	je     f0101f3d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101f0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101f13:	75 25                	jne    f0101f3a <memset+0x49>
f0101f15:	f6 c1 03             	test   $0x3,%cl
f0101f18:	75 20                	jne    f0101f3a <memset+0x49>
		c &= 0xFF;
f0101f1a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101f1d:	89 d3                	mov    %edx,%ebx
f0101f1f:	c1 e3 08             	shl    $0x8,%ebx
f0101f22:	89 d6                	mov    %edx,%esi
f0101f24:	c1 e6 18             	shl    $0x18,%esi
f0101f27:	89 d0                	mov    %edx,%eax
f0101f29:	c1 e0 10             	shl    $0x10,%eax
f0101f2c:	09 f0                	or     %esi,%eax
f0101f2e:	09 d0                	or     %edx,%eax
f0101f30:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101f32:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101f35:	fc                   	cld    
f0101f36:	f3 ab                	rep stos %eax,%es:(%edi)
f0101f38:	eb 03                	jmp    f0101f3d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101f3a:	fc                   	cld    
f0101f3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101f3d:	89 f8                	mov    %edi,%eax
f0101f3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101f42:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101f45:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101f48:	89 ec                	mov    %ebp,%esp
f0101f4a:	5d                   	pop    %ebp
f0101f4b:	c3                   	ret    

f0101f4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101f4c:	55                   	push   %ebp
f0101f4d:	89 e5                	mov    %esp,%ebp
f0101f4f:	83 ec 08             	sub    $0x8,%esp
f0101f52:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101f55:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101f58:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f5b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101f5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101f61:	39 c6                	cmp    %eax,%esi
f0101f63:	73 36                	jae    f0101f9b <memmove+0x4f>
f0101f65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101f68:	39 d0                	cmp    %edx,%eax
f0101f6a:	73 2f                	jae    f0101f9b <memmove+0x4f>
		s += n;
		d += n;
f0101f6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101f6f:	f6 c2 03             	test   $0x3,%dl
f0101f72:	75 1b                	jne    f0101f8f <memmove+0x43>
f0101f74:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101f7a:	75 13                	jne    f0101f8f <memmove+0x43>
f0101f7c:	f6 c1 03             	test   $0x3,%cl
f0101f7f:	75 0e                	jne    f0101f8f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101f81:	83 ef 04             	sub    $0x4,%edi
f0101f84:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101f87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101f8a:	fd                   	std    
f0101f8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101f8d:	eb 09                	jmp    f0101f98 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101f8f:	83 ef 01             	sub    $0x1,%edi
f0101f92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101f95:	fd                   	std    
f0101f96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101f98:	fc                   	cld    
f0101f99:	eb 20                	jmp    f0101fbb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101f9b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101fa1:	75 13                	jne    f0101fb6 <memmove+0x6a>
f0101fa3:	a8 03                	test   $0x3,%al
f0101fa5:	75 0f                	jne    f0101fb6 <memmove+0x6a>
f0101fa7:	f6 c1 03             	test   $0x3,%cl
f0101faa:	75 0a                	jne    f0101fb6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101fac:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101faf:	89 c7                	mov    %eax,%edi
f0101fb1:	fc                   	cld    
f0101fb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101fb4:	eb 05                	jmp    f0101fbb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101fb6:	89 c7                	mov    %eax,%edi
f0101fb8:	fc                   	cld    
f0101fb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101fbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101fbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101fc1:	89 ec                	mov    %ebp,%esp
f0101fc3:	5d                   	pop    %ebp
f0101fc4:	c3                   	ret    

f0101fc5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101fc5:	55                   	push   %ebp
f0101fc6:	89 e5                	mov    %esp,%ebp
f0101fc8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101fcb:	8b 45 10             	mov    0x10(%ebp),%eax
f0101fce:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0101fdc:	89 04 24             	mov    %eax,(%esp)
f0101fdf:	e8 68 ff ff ff       	call   f0101f4c <memmove>
}
f0101fe4:	c9                   	leave  
f0101fe5:	c3                   	ret    

f0101fe6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101fe6:	55                   	push   %ebp
f0101fe7:	89 e5                	mov    %esp,%ebp
f0101fe9:	57                   	push   %edi
f0101fea:	56                   	push   %esi
f0101feb:	53                   	push   %ebx
f0101fec:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101fef:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101ff2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101ff5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101ffa:	85 ff                	test   %edi,%edi
f0101ffc:	74 37                	je     f0102035 <memcmp+0x4f>
		if (*s1 != *s2)
f0101ffe:	0f b6 03             	movzbl (%ebx),%eax
f0102001:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102004:	83 ef 01             	sub    $0x1,%edi
f0102007:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f010200c:	38 c8                	cmp    %cl,%al
f010200e:	74 1c                	je     f010202c <memcmp+0x46>
f0102010:	eb 10                	jmp    f0102022 <memcmp+0x3c>
f0102012:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0102017:	83 c2 01             	add    $0x1,%edx
f010201a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010201e:	38 c8                	cmp    %cl,%al
f0102020:	74 0a                	je     f010202c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0102022:	0f b6 c0             	movzbl %al,%eax
f0102025:	0f b6 c9             	movzbl %cl,%ecx
f0102028:	29 c8                	sub    %ecx,%eax
f010202a:	eb 09                	jmp    f0102035 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010202c:	39 fa                	cmp    %edi,%edx
f010202e:	75 e2                	jne    f0102012 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102030:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102035:	5b                   	pop    %ebx
f0102036:	5e                   	pop    %esi
f0102037:	5f                   	pop    %edi
f0102038:	5d                   	pop    %ebp
f0102039:	c3                   	ret    

f010203a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010203a:	55                   	push   %ebp
f010203b:	89 e5                	mov    %esp,%ebp
f010203d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0102040:	89 c2                	mov    %eax,%edx
f0102042:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0102045:	39 d0                	cmp    %edx,%eax
f0102047:	73 19                	jae    f0102062 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102049:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010204d:	38 08                	cmp    %cl,(%eax)
f010204f:	75 06                	jne    f0102057 <memfind+0x1d>
f0102051:	eb 0f                	jmp    f0102062 <memfind+0x28>
f0102053:	38 08                	cmp    %cl,(%eax)
f0102055:	74 0b                	je     f0102062 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102057:	83 c0 01             	add    $0x1,%eax
f010205a:	39 d0                	cmp    %edx,%eax
f010205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102060:	75 f1                	jne    f0102053 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102062:	5d                   	pop    %ebp
f0102063:	c3                   	ret    

f0102064 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102064:	55                   	push   %ebp
f0102065:	89 e5                	mov    %esp,%ebp
f0102067:	57                   	push   %edi
f0102068:	56                   	push   %esi
f0102069:	53                   	push   %ebx
f010206a:	8b 55 08             	mov    0x8(%ebp),%edx
f010206d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102070:	0f b6 02             	movzbl (%edx),%eax
f0102073:	3c 20                	cmp    $0x20,%al
f0102075:	74 04                	je     f010207b <strtol+0x17>
f0102077:	3c 09                	cmp    $0x9,%al
f0102079:	75 0e                	jne    f0102089 <strtol+0x25>
		s++;
f010207b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010207e:	0f b6 02             	movzbl (%edx),%eax
f0102081:	3c 20                	cmp    $0x20,%al
f0102083:	74 f6                	je     f010207b <strtol+0x17>
f0102085:	3c 09                	cmp    $0x9,%al
f0102087:	74 f2                	je     f010207b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102089:	3c 2b                	cmp    $0x2b,%al
f010208b:	75 0a                	jne    f0102097 <strtol+0x33>
		s++;
f010208d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102090:	bf 00 00 00 00       	mov    $0x0,%edi
f0102095:	eb 10                	jmp    f01020a7 <strtol+0x43>
f0102097:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010209c:	3c 2d                	cmp    $0x2d,%al
f010209e:	75 07                	jne    f01020a7 <strtol+0x43>
		s++, neg = 1;
f01020a0:	83 c2 01             	add    $0x1,%edx
f01020a3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01020a7:	85 db                	test   %ebx,%ebx
f01020a9:	0f 94 c0             	sete   %al
f01020ac:	74 05                	je     f01020b3 <strtol+0x4f>
f01020ae:	83 fb 10             	cmp    $0x10,%ebx
f01020b1:	75 15                	jne    f01020c8 <strtol+0x64>
f01020b3:	80 3a 30             	cmpb   $0x30,(%edx)
f01020b6:	75 10                	jne    f01020c8 <strtol+0x64>
f01020b8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01020bc:	75 0a                	jne    f01020c8 <strtol+0x64>
		s += 2, base = 16;
f01020be:	83 c2 02             	add    $0x2,%edx
f01020c1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01020c6:	eb 13                	jmp    f01020db <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f01020c8:	84 c0                	test   %al,%al
f01020ca:	74 0f                	je     f01020db <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01020cc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01020d1:	80 3a 30             	cmpb   $0x30,(%edx)
f01020d4:	75 05                	jne    f01020db <strtol+0x77>
		s++, base = 8;
f01020d6:	83 c2 01             	add    $0x1,%edx
f01020d9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01020db:	b8 00 00 00 00       	mov    $0x0,%eax
f01020e0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01020e2:	0f b6 0a             	movzbl (%edx),%ecx
f01020e5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01020e8:	80 fb 09             	cmp    $0x9,%bl
f01020eb:	77 08                	ja     f01020f5 <strtol+0x91>
			dig = *s - '0';
f01020ed:	0f be c9             	movsbl %cl,%ecx
f01020f0:	83 e9 30             	sub    $0x30,%ecx
f01020f3:	eb 1e                	jmp    f0102113 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01020f5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01020f8:	80 fb 19             	cmp    $0x19,%bl
f01020fb:	77 08                	ja     f0102105 <strtol+0xa1>
			dig = *s - 'a' + 10;
f01020fd:	0f be c9             	movsbl %cl,%ecx
f0102100:	83 e9 57             	sub    $0x57,%ecx
f0102103:	eb 0e                	jmp    f0102113 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0102105:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0102108:	80 fb 19             	cmp    $0x19,%bl
f010210b:	77 14                	ja     f0102121 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010210d:	0f be c9             	movsbl %cl,%ecx
f0102110:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102113:	39 f1                	cmp    %esi,%ecx
f0102115:	7d 0e                	jge    f0102125 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0102117:	83 c2 01             	add    $0x1,%edx
f010211a:	0f af c6             	imul   %esi,%eax
f010211d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010211f:	eb c1                	jmp    f01020e2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102121:	89 c1                	mov    %eax,%ecx
f0102123:	eb 02                	jmp    f0102127 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0102125:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0102127:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010212b:	74 05                	je     f0102132 <strtol+0xce>
		*endptr = (char *) s;
f010212d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102130:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0102132:	89 ca                	mov    %ecx,%edx
f0102134:	f7 da                	neg    %edx
f0102136:	85 ff                	test   %edi,%edi
f0102138:	0f 45 c2             	cmovne %edx,%eax
}
f010213b:	5b                   	pop    %ebx
f010213c:	5e                   	pop    %esi
f010213d:	5f                   	pop    %edi
f010213e:	5d                   	pop    %ebp
f010213f:	c3                   	ret    

f0102140 <__udivdi3>:
f0102140:	83 ec 1c             	sub    $0x1c,%esp
f0102143:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0102147:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010214b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010214f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102153:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102157:	8b 74 24 24          	mov    0x24(%esp),%esi
f010215b:	85 ff                	test   %edi,%edi
f010215d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0102161:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102165:	89 cd                	mov    %ecx,%ebp
f0102167:	89 44 24 04          	mov    %eax,0x4(%esp)
f010216b:	75 33                	jne    f01021a0 <__udivdi3+0x60>
f010216d:	39 f1                	cmp    %esi,%ecx
f010216f:	77 57                	ja     f01021c8 <__udivdi3+0x88>
f0102171:	85 c9                	test   %ecx,%ecx
f0102173:	75 0b                	jne    f0102180 <__udivdi3+0x40>
f0102175:	b8 01 00 00 00       	mov    $0x1,%eax
f010217a:	31 d2                	xor    %edx,%edx
f010217c:	f7 f1                	div    %ecx
f010217e:	89 c1                	mov    %eax,%ecx
f0102180:	89 f0                	mov    %esi,%eax
f0102182:	31 d2                	xor    %edx,%edx
f0102184:	f7 f1                	div    %ecx
f0102186:	89 c6                	mov    %eax,%esi
f0102188:	8b 44 24 04          	mov    0x4(%esp),%eax
f010218c:	f7 f1                	div    %ecx
f010218e:	89 f2                	mov    %esi,%edx
f0102190:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102194:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102198:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010219c:	83 c4 1c             	add    $0x1c,%esp
f010219f:	c3                   	ret    
f01021a0:	31 d2                	xor    %edx,%edx
f01021a2:	31 c0                	xor    %eax,%eax
f01021a4:	39 f7                	cmp    %esi,%edi
f01021a6:	77 e8                	ja     f0102190 <__udivdi3+0x50>
f01021a8:	0f bd cf             	bsr    %edi,%ecx
f01021ab:	83 f1 1f             	xor    $0x1f,%ecx
f01021ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01021b2:	75 2c                	jne    f01021e0 <__udivdi3+0xa0>
f01021b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01021b8:	76 04                	jbe    f01021be <__udivdi3+0x7e>
f01021ba:	39 f7                	cmp    %esi,%edi
f01021bc:	73 d2                	jae    f0102190 <__udivdi3+0x50>
f01021be:	31 d2                	xor    %edx,%edx
f01021c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01021c5:	eb c9                	jmp    f0102190 <__udivdi3+0x50>
f01021c7:	90                   	nop
f01021c8:	89 f2                	mov    %esi,%edx
f01021ca:	f7 f1                	div    %ecx
f01021cc:	31 d2                	xor    %edx,%edx
f01021ce:	8b 74 24 10          	mov    0x10(%esp),%esi
f01021d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01021d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01021da:	83 c4 1c             	add    $0x1c,%esp
f01021dd:	c3                   	ret    
f01021de:	66 90                	xchg   %ax,%ax
f01021e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01021e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01021ea:	89 ea                	mov    %ebp,%edx
f01021ec:	2b 44 24 04          	sub    0x4(%esp),%eax
f01021f0:	d3 e7                	shl    %cl,%edi
f01021f2:	89 c1                	mov    %eax,%ecx
f01021f4:	d3 ea                	shr    %cl,%edx
f01021f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01021fb:	09 fa                	or     %edi,%edx
f01021fd:	89 f7                	mov    %esi,%edi
f01021ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102203:	89 f2                	mov    %esi,%edx
f0102205:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102209:	d3 e5                	shl    %cl,%ebp
f010220b:	89 c1                	mov    %eax,%ecx
f010220d:	d3 ef                	shr    %cl,%edi
f010220f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102214:	d3 e2                	shl    %cl,%edx
f0102216:	89 c1                	mov    %eax,%ecx
f0102218:	d3 ee                	shr    %cl,%esi
f010221a:	09 d6                	or     %edx,%esi
f010221c:	89 fa                	mov    %edi,%edx
f010221e:	89 f0                	mov    %esi,%eax
f0102220:	f7 74 24 0c          	divl   0xc(%esp)
f0102224:	89 d7                	mov    %edx,%edi
f0102226:	89 c6                	mov    %eax,%esi
f0102228:	f7 e5                	mul    %ebp
f010222a:	39 d7                	cmp    %edx,%edi
f010222c:	72 22                	jb     f0102250 <__udivdi3+0x110>
f010222e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0102232:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102237:	d3 e5                	shl    %cl,%ebp
f0102239:	39 c5                	cmp    %eax,%ebp
f010223b:	73 04                	jae    f0102241 <__udivdi3+0x101>
f010223d:	39 d7                	cmp    %edx,%edi
f010223f:	74 0f                	je     f0102250 <__udivdi3+0x110>
f0102241:	89 f0                	mov    %esi,%eax
f0102243:	31 d2                	xor    %edx,%edx
f0102245:	e9 46 ff ff ff       	jmp    f0102190 <__udivdi3+0x50>
f010224a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102250:	8d 46 ff             	lea    -0x1(%esi),%eax
f0102253:	31 d2                	xor    %edx,%edx
f0102255:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102259:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010225d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102261:	83 c4 1c             	add    $0x1c,%esp
f0102264:	c3                   	ret    
	...

f0102270 <__umoddi3>:
f0102270:	83 ec 1c             	sub    $0x1c,%esp
f0102273:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0102277:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010227b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010227f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102283:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102287:	8b 74 24 24          	mov    0x24(%esp),%esi
f010228b:	85 ed                	test   %ebp,%ebp
f010228d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0102291:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102295:	89 cf                	mov    %ecx,%edi
f0102297:	89 04 24             	mov    %eax,(%esp)
f010229a:	89 f2                	mov    %esi,%edx
f010229c:	75 1a                	jne    f01022b8 <__umoddi3+0x48>
f010229e:	39 f1                	cmp    %esi,%ecx
f01022a0:	76 4e                	jbe    f01022f0 <__umoddi3+0x80>
f01022a2:	f7 f1                	div    %ecx
f01022a4:	89 d0                	mov    %edx,%eax
f01022a6:	31 d2                	xor    %edx,%edx
f01022a8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01022ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01022b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01022b4:	83 c4 1c             	add    $0x1c,%esp
f01022b7:	c3                   	ret    
f01022b8:	39 f5                	cmp    %esi,%ebp
f01022ba:	77 54                	ja     f0102310 <__umoddi3+0xa0>
f01022bc:	0f bd c5             	bsr    %ebp,%eax
f01022bf:	83 f0 1f             	xor    $0x1f,%eax
f01022c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022c6:	75 60                	jne    f0102328 <__umoddi3+0xb8>
f01022c8:	3b 0c 24             	cmp    (%esp),%ecx
f01022cb:	0f 87 07 01 00 00    	ja     f01023d8 <__umoddi3+0x168>
f01022d1:	89 f2                	mov    %esi,%edx
f01022d3:	8b 34 24             	mov    (%esp),%esi
f01022d6:	29 ce                	sub    %ecx,%esi
f01022d8:	19 ea                	sbb    %ebp,%edx
f01022da:	89 34 24             	mov    %esi,(%esp)
f01022dd:	8b 04 24             	mov    (%esp),%eax
f01022e0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01022e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01022e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01022ec:	83 c4 1c             	add    $0x1c,%esp
f01022ef:	c3                   	ret    
f01022f0:	85 c9                	test   %ecx,%ecx
f01022f2:	75 0b                	jne    f01022ff <__umoddi3+0x8f>
f01022f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01022f9:	31 d2                	xor    %edx,%edx
f01022fb:	f7 f1                	div    %ecx
f01022fd:	89 c1                	mov    %eax,%ecx
f01022ff:	89 f0                	mov    %esi,%eax
f0102301:	31 d2                	xor    %edx,%edx
f0102303:	f7 f1                	div    %ecx
f0102305:	8b 04 24             	mov    (%esp),%eax
f0102308:	f7 f1                	div    %ecx
f010230a:	eb 98                	jmp    f01022a4 <__umoddi3+0x34>
f010230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102310:	89 f2                	mov    %esi,%edx
f0102312:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102316:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010231a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010231e:	83 c4 1c             	add    $0x1c,%esp
f0102321:	c3                   	ret    
f0102322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102328:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010232d:	89 e8                	mov    %ebp,%eax
f010232f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0102334:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0102338:	89 fa                	mov    %edi,%edx
f010233a:	d3 e0                	shl    %cl,%eax
f010233c:	89 e9                	mov    %ebp,%ecx
f010233e:	d3 ea                	shr    %cl,%edx
f0102340:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102345:	09 c2                	or     %eax,%edx
f0102347:	8b 44 24 08          	mov    0x8(%esp),%eax
f010234b:	89 14 24             	mov    %edx,(%esp)
f010234e:	89 f2                	mov    %esi,%edx
f0102350:	d3 e7                	shl    %cl,%edi
f0102352:	89 e9                	mov    %ebp,%ecx
f0102354:	d3 ea                	shr    %cl,%edx
f0102356:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010235b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010235f:	d3 e6                	shl    %cl,%esi
f0102361:	89 e9                	mov    %ebp,%ecx
f0102363:	d3 e8                	shr    %cl,%eax
f0102365:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010236a:	09 f0                	or     %esi,%eax
f010236c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102370:	f7 34 24             	divl   (%esp)
f0102373:	d3 e6                	shl    %cl,%esi
f0102375:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102379:	89 d6                	mov    %edx,%esi
f010237b:	f7 e7                	mul    %edi
f010237d:	39 d6                	cmp    %edx,%esi
f010237f:	89 c1                	mov    %eax,%ecx
f0102381:	89 d7                	mov    %edx,%edi
f0102383:	72 3f                	jb     f01023c4 <__umoddi3+0x154>
f0102385:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0102389:	72 35                	jb     f01023c0 <__umoddi3+0x150>
f010238b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010238f:	29 c8                	sub    %ecx,%eax
f0102391:	19 fe                	sbb    %edi,%esi
f0102393:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102398:	89 f2                	mov    %esi,%edx
f010239a:	d3 e8                	shr    %cl,%eax
f010239c:	89 e9                	mov    %ebp,%ecx
f010239e:	d3 e2                	shl    %cl,%edx
f01023a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01023a5:	09 d0                	or     %edx,%eax
f01023a7:	89 f2                	mov    %esi,%edx
f01023a9:	d3 ea                	shr    %cl,%edx
f01023ab:	8b 74 24 10          	mov    0x10(%esp),%esi
f01023af:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01023b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01023b7:	83 c4 1c             	add    $0x1c,%esp
f01023ba:	c3                   	ret    
f01023bb:	90                   	nop
f01023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01023c0:	39 d6                	cmp    %edx,%esi
f01023c2:	75 c7                	jne    f010238b <__umoddi3+0x11b>
f01023c4:	89 d7                	mov    %edx,%edi
f01023c6:	89 c1                	mov    %eax,%ecx
f01023c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01023cc:	1b 3c 24             	sbb    (%esp),%edi
f01023cf:	eb ba                	jmp    f010238b <__umoddi3+0x11b>
f01023d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01023d8:	39 f5                	cmp    %esi,%ebp
f01023da:	0f 82 f1 fe ff ff    	jb     f01022d1 <__umoddi3+0x61>
f01023e0:	e9 f8 fe ff ff       	jmp    f01022dd <__umoddi3+0x6d>
