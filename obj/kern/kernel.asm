
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

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
f0100046:	b8 90 89 11 f0       	mov    $0xf0118990,%eax
f010004b:	2d 08 83 11 f0       	sub    $0xf0118308,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 08 83 11 f0 	movl   $0xf0118308,(%esp)
f0100063:	e8 f9 3b 00 00       	call   f0103c61 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 8e 04 00 00       	call   f01004fb <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 60 41 10 f0 	movl   $0xf0104160,(%esp)
f010007c:	e8 f1 2e 00 00       	call   f0102f72 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 ae 12 00 00       	call   f0101334 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 5e 08 00 00       	call   f01008f0 <monitor>
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
f010009f:	83 3d 80 89 11 f0 00 	cmpl   $0x0,0xf0118980
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 80 89 11 f0    	mov    %esi,0xf0118980

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
f01000c1:	c7 04 24 7b 41 10 f0 	movl   $0xf010417b,(%esp)
f01000c8:	e8 a5 2e 00 00       	call   f0102f72 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 66 2e 00 00       	call   f0102f3f <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 2a 51 10 f0 	movl   $0xf010512a,(%esp)
f01000e0:	e8 8d 2e 00 00       	call   f0102f72 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 ff 07 00 00       	call   f01008f0 <monitor>
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
f010010b:	c7 04 24 93 41 10 f0 	movl   $0xf0104193,(%esp)
f0100112:	e8 5b 2e 00 00       	call   f0102f72 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 19 2e 00 00       	call   f0102f3f <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 2a 51 10 f0 	movl   $0xf010512a,(%esp)
f010012d:	e8 40 2e 00 00       	call   f0102f72 <cprintf>
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
f0100179:	8b 15 44 85 11 f0    	mov    0xf0118544,%edx
f010017f:	88 82 40 83 11 f0    	mov    %al,-0xfee7cc0(%edx)
f0100185:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100188:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010018d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100192:	0f 44 c2             	cmove  %edx,%eax
f0100195:	a3 44 85 11 f0       	mov    %eax,0xf0118544
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
f010021c:	a1 04 83 11 f0       	mov    0xf0118304,%eax
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
f0100262:	0f b7 15 54 85 11 f0 	movzwl 0xf0118554,%edx
f0100269:	66 85 d2             	test   %dx,%dx
f010026c:	0f 84 e3 00 00 00    	je     f0100355 <cons_putc+0x1ae>
			crt_pos--;
f0100272:	83 ea 01             	sub    $0x1,%edx
f0100275:	66 89 15 54 85 11 f0 	mov    %dx,0xf0118554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010027c:	0f b7 d2             	movzwl %dx,%edx
f010027f:	b0 00                	mov    $0x0,%al
f0100281:	83 c8 20             	or     $0x20,%eax
f0100284:	8b 0d 50 85 11 f0    	mov    0xf0118550,%ecx
f010028a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010028e:	eb 78                	jmp    f0100308 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100290:	66 83 05 54 85 11 f0 	addw   $0x50,0xf0118554
f0100297:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100298:	0f b7 05 54 85 11 f0 	movzwl 0xf0118554,%eax
f010029f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002a5:	c1 e8 16             	shr    $0x16,%eax
f01002a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002ab:	c1 e0 04             	shl    $0x4,%eax
f01002ae:	66 a3 54 85 11 f0    	mov    %ax,0xf0118554
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
f01002ea:	0f b7 15 54 85 11 f0 	movzwl 0xf0118554,%edx
f01002f1:	0f b7 da             	movzwl %dx,%ebx
f01002f4:	8b 0d 50 85 11 f0    	mov    0xf0118550,%ecx
f01002fa:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01002fe:	83 c2 01             	add    $0x1,%edx
f0100301:	66 89 15 54 85 11 f0 	mov    %dx,0xf0118554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100308:	66 81 3d 54 85 11 f0 	cmpw   $0x7cf,0xf0118554
f010030f:	cf 07 
f0100311:	76 42                	jbe    f0100355 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100313:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f0100318:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010031f:	00 
f0100320:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100326:	89 54 24 04          	mov    %edx,0x4(%esp)
f010032a:	89 04 24             	mov    %eax,(%esp)
f010032d:	e8 8a 39 00 00       	call   f0103cbc <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100332:	8b 15 50 85 11 f0    	mov    0xf0118550,%edx
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
f010034d:	66 83 2d 54 85 11 f0 	subw   $0x50,0xf0118554
f0100354:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100355:	8b 0d 4c 85 11 f0    	mov    0xf011854c,%ecx
f010035b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100360:	89 ca                	mov    %ecx,%edx
f0100362:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100363:	0f b7 35 54 85 11 f0 	movzwl 0xf0118554,%esi
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
f01003ae:	83 0d 48 85 11 f0 40 	orl    $0x40,0xf0118548
		return 0;
f01003b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ba:	e9 c4 00 00 00       	jmp    f0100483 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003bf:	84 c0                	test   %al,%al
f01003c1:	79 37                	jns    f01003fa <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c3:	8b 0d 48 85 11 f0    	mov    0xf0118548,%ecx
f01003c9:	89 cb                	mov    %ecx,%ebx
f01003cb:	83 e3 40             	and    $0x40,%ebx
f01003ce:	83 e0 7f             	and    $0x7f,%eax
f01003d1:	85 db                	test   %ebx,%ebx
f01003d3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003d6:	0f b6 d2             	movzbl %dl,%edx
f01003d9:	0f b6 82 e0 41 10 f0 	movzbl -0xfefbe20(%edx),%eax
f01003e0:	83 c8 40             	or     $0x40,%eax
f01003e3:	0f b6 c0             	movzbl %al,%eax
f01003e6:	f7 d0                	not    %eax
f01003e8:	21 c1                	and    %eax,%ecx
f01003ea:	89 0d 48 85 11 f0    	mov    %ecx,0xf0118548
		return 0;
f01003f0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f5:	e9 89 00 00 00       	jmp    f0100483 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01003fa:	8b 0d 48 85 11 f0    	mov    0xf0118548,%ecx
f0100400:	f6 c1 40             	test   $0x40,%cl
f0100403:	74 0e                	je     f0100413 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100405:	89 c2                	mov    %eax,%edx
f0100407:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010040a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010040d:	89 0d 48 85 11 f0    	mov    %ecx,0xf0118548
	}

	shift |= shiftcode[data];
f0100413:	0f b6 d2             	movzbl %dl,%edx
f0100416:	0f b6 82 e0 41 10 f0 	movzbl -0xfefbe20(%edx),%eax
f010041d:	0b 05 48 85 11 f0    	or     0xf0118548,%eax
	shift ^= togglecode[data];
f0100423:	0f b6 8a e0 42 10 f0 	movzbl -0xfefbd20(%edx),%ecx
f010042a:	31 c8                	xor    %ecx,%eax
f010042c:	a3 48 85 11 f0       	mov    %eax,0xf0118548

	c = charcode[shift & (CTL | SHIFT)][data];
f0100431:	89 c1                	mov    %eax,%ecx
f0100433:	83 e1 03             	and    $0x3,%ecx
f0100436:	8b 0c 8d e0 43 10 f0 	mov    -0xfefbc20(,%ecx,4),%ecx
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
f010046c:	c7 04 24 ad 41 10 f0 	movl   $0xf01041ad,(%esp)
f0100473:	e8 fa 2a 00 00       	call   f0102f72 <cprintf>
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
f0100491:	80 3d 20 83 11 f0 00 	cmpb   $0x0,0xf0118320
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
f01004c8:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
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
f01004d3:	3b 15 44 85 11 f0    	cmp    0xf0118544,%edx
f01004d9:	74 1e                	je     f01004f9 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004db:	0f b6 82 40 83 11 f0 	movzbl -0xfee7cc0(%edx),%eax
f01004e2:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01004e5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004eb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004f0:	0f 44 d1             	cmove  %ecx,%edx
f01004f3:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
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
f0100521:	c7 05 4c 85 11 f0 b4 	movl   $0x3b4,0xf011854c
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
f0100539:	c7 05 4c 85 11 f0 d4 	movl   $0x3d4,0xf011854c
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
f0100548:	8b 0d 4c 85 11 f0    	mov    0xf011854c,%ecx
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
f010056d:	89 35 50 85 11 f0    	mov    %esi,0xf0118550

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100573:	0f b6 d8             	movzbl %al,%ebx
f0100576:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100578:	66 89 3d 54 85 11 f0 	mov    %di,0xf0118554
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
f01005cb:	a2 20 83 11 f0       	mov    %al,0xf0118320
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
f01005dc:	c7 04 24 b9 41 10 f0 	movl   $0xf01041b9,(%esp)
f01005e3:	e8 8a 29 00 00       	call   f0102f72 <cprintf>
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
f0100626:	c7 04 24 f0 43 10 f0 	movl   $0xf01043f0,(%esp)
f010062d:	e8 40 29 00 00       	call   f0102f72 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100632:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100639:	00 
f010063a:	c7 04 24 c4 44 10 f0 	movl   $0xf01044c4,(%esp)
f0100641:	e8 2c 29 00 00       	call   f0102f72 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100646:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010064d:	00 
f010064e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 ec 44 10 f0 	movl   $0xf01044ec,(%esp)
f010065d:	e8 10 29 00 00       	call   f0102f72 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100662:	c7 44 24 08 55 41 10 	movl   $0x104155,0x8(%esp)
f0100669:	00 
f010066a:	c7 44 24 04 55 41 10 	movl   $0xf0104155,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 10 45 10 f0 	movl   $0xf0104510,(%esp)
f0100679:	e8 f4 28 00 00       	call   f0102f72 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010067e:	c7 44 24 08 08 83 11 	movl   $0x118308,0x8(%esp)
f0100685:	00 
f0100686:	c7 44 24 04 08 83 11 	movl   $0xf0118308,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 34 45 10 f0 	movl   $0xf0104534,(%esp)
f0100695:	e8 d8 28 00 00       	call   f0102f72 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010069a:	c7 44 24 08 90 89 11 	movl   $0x118990,0x8(%esp)
f01006a1:	00 
f01006a2:	c7 44 24 04 90 89 11 	movl   $0xf0118990,0x4(%esp)
f01006a9:	f0 
f01006aa:	c7 04 24 58 45 10 f0 	movl   $0xf0104558,(%esp)
f01006b1:	e8 bc 28 00 00       	call   f0102f72 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006b6:	b8 8f 8d 11 f0       	mov    $0xf0118d8f,%eax
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
f01006d7:	c7 04 24 7c 45 10 f0 	movl   $0xf010457c,(%esp)
f01006de:	e8 8f 28 00 00       	call   f0102f72 <cprintf>
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
f01006f6:	8b 83 e4 46 10 f0    	mov    -0xfefb91c(%ebx),%eax
f01006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100700:	8b 83 e0 46 10 f0    	mov    -0xfefb920(%ebx),%eax
f0100706:	89 44 24 04          	mov    %eax,0x4(%esp)
f010070a:	c7 04 24 09 44 10 f0 	movl   $0xf0104409,(%esp)
f0100711:	e8 5c 28 00 00       	call   f0102f72 <cprintf>
f0100716:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100719:	83 fb 30             	cmp    $0x30,%ebx
f010071c:	75 d8                	jne    f01006f6 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010071e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100723:	83 c4 14             	add    $0x14,%esp
f0100726:	5b                   	pop    %ebx
f0100727:	5d                   	pop    %ebp
f0100728:	c3                   	ret    

f0100729 <mon_showmappings>:
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
f0100729:	55                   	push   %ebp
f010072a:	89 e5                	mov    %esp,%ebp
f010072c:	56                   	push   %esi
f010072d:	53                   	push   %ebx
f010072e:	83 ec 10             	sub    $0x10,%esp
f0100731:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc > 3)
		return -1;
f0100734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	if(argc > 3)
f0100739:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010073d:	7f 51                	jg     f0100790 <mon_showmappings+0x67>
		return -1;

	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
f010073f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100746:	00 
f0100747:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010074e:	00 
f010074f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100752:	89 04 24             	mov    %eax,(%esp)
f0100755:	e8 7a 36 00 00       	call   f0103dd4 <strtol>
f010075a:	89 c6                	mov    %eax,%esi
	num[1] = strtol(argv[2], NULL, 16);
f010075c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100763:	00 
f0100764:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010076b:	00 
f010076c:	8b 43 08             	mov    0x8(%ebx),%eax
f010076f:	89 04 24             	mov    %eax,(%esp)
f0100772:	e8 5d 36 00 00       	call   f0103dd4 <strtol>
	cprintf("%d %d\n", num[0], num[1]);
f0100777:	89 44 24 08          	mov    %eax,0x8(%esp)
f010077b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010077f:	c7 04 24 12 44 10 f0 	movl   $0xf0104412,(%esp)
f0100786:	e8 e7 27 00 00       	call   f0102f72 <cprintf>
	return 0;
f010078b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100790:	83 c4 10             	add    $0x10,%esp
f0100793:	5b                   	pop    %ebx
f0100794:	5e                   	pop    %esi
f0100795:	5d                   	pop    %ebp
f0100796:	c3                   	ret    

f0100797 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100797:	55                   	push   %ebp
f0100798:	89 e5                	mov    %esp,%ebp
f010079a:	57                   	push   %edi
f010079b:	56                   	push   %esi
f010079c:	53                   	push   %ebx
f010079d:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01007a3:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f01007a5:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f01007a7:	8b 43 04             	mov    0x4(%ebx),%eax
f01007aa:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f01007b0:	8b 43 08             	mov    0x8(%ebx),%eax
f01007b3:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f01007b9:	8b 43 0c             	mov    0xc(%ebx),%eax
f01007bc:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f01007c2:	8b 43 10             	mov    0x10(%ebx),%eax
f01007c5:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f01007cb:	8b 43 14             	mov    0x14(%ebx),%eax
f01007ce:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f01007d4:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f01007d7:	c7 04 24 19 44 10 f0 	movl   $0xf0104419,(%esp)
f01007de:	e8 8f 27 00 00       	call   f0102f72 <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f01007e3:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f01007e8:	85 db                	test   %ebx,%ebx
f01007ea:	0f 84 f5 00 00 00    	je     f01008e5 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f01007f0:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f01007f6:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f01007fc:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100802:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100808:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010080c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100810:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100814:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100818:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f010081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100822:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100826:	89 74 24 04          	mov    %esi,0x4(%esp)
f010082a:	c7 04 24 a8 45 10 f0 	movl   $0xf01045a8,(%esp)
f0100831:	e8 3c 27 00 00       	call   f0102f72 <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100836:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100839:	89 44 24 04          	mov    %eax,0x4(%esp)
f010083d:	89 1c 24             	mov    %ebx,(%esp)
f0100840:	e8 27 28 00 00       	call   f010306c <debuginfo_eip>
f0100845:	85 c0                	test   %eax,%eax
f0100847:	0f 88 93 00 00 00    	js     f01008e0 <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f010084d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100850:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100854:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010085a:	89 04 24             	mov    %eax,(%esp)
f010085d:	e8 69 32 00 00       	call   f0103acb <strcpy>

		int eip_line = info.eip_line;
f0100862:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100865:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f010086b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010086e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100872:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100875:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100879:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f010087c:	89 3c 24             	mov    %edi,(%esp)
f010087f:	e8 92 32 00 00       	call   f0103b16 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100884:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100887:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f010088c:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f010088f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100893:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100897:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f010089d:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008a1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f01008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ab:	c7 04 24 2b 44 10 f0 	movl   $0xf010442b,(%esp)
f01008b2:	e8 bb 26 00 00       	call   f0102f72 <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f01008b7:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f01008b9:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f01008bc:	8b 46 08             	mov    0x8(%esi),%eax
f01008bf:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f01008c5:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f01008c8:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f01008cb:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f01008ce:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f01008d1:	85 f6                	test   %esi,%esi
f01008d3:	0f 85 2f ff ff ff    	jne    f0100808 <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f01008d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008de:	eb 05                	jmp    f01008e5 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f01008e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f01008e5:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f01008eb:	5b                   	pop    %ebx
f01008ec:	5e                   	pop    %esi
f01008ed:	5f                   	pop    %edi
f01008ee:	5d                   	pop    %ebp
f01008ef:	c3                   	ret    

f01008f0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008f0:	55                   	push   %ebp
f01008f1:	89 e5                	mov    %esp,%ebp
f01008f3:	57                   	push   %edi
f01008f4:	56                   	push   %esi
f01008f5:	53                   	push   %ebx
f01008f6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f01008f9:	c7 04 24 dc 45 10 f0 	movl   $0xf01045dc,(%esp)
f0100900:	e8 6d 26 00 00       	call   f0102f72 <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f0100905:	c7 04 24 10 46 10 f0 	movl   $0xf0104610,(%esp)
f010090c:	e8 61 26 00 00       	call   f0102f72 <cprintf>
    
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
f0100911:	c7 04 24 42 44 10 f0 	movl   $0xf0104442,(%esp)
f0100918:	e8 93 30 00 00       	call   f01039b0 <readline>
f010091d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010091f:	85 c0                	test   %eax,%eax
f0100921:	74 ee                	je     f0100911 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100923:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010092a:	be 00 00 00 00       	mov    $0x0,%esi
f010092f:	eb 06                	jmp    f0100937 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100931:	c6 03 00             	movb   $0x0,(%ebx)
f0100934:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100937:	0f b6 03             	movzbl (%ebx),%eax
f010093a:	84 c0                	test   %al,%al
f010093c:	74 6d                	je     f01009ab <monitor+0xbb>
f010093e:	0f be c0             	movsbl %al,%eax
f0100941:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100945:	c7 04 24 46 44 10 f0 	movl   $0xf0104446,(%esp)
f010094c:	e8 b5 32 00 00       	call   f0103c06 <strchr>
f0100951:	85 c0                	test   %eax,%eax
f0100953:	75 dc                	jne    f0100931 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100955:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100958:	74 51                	je     f01009ab <monitor+0xbb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010095a:	83 fe 0f             	cmp    $0xf,%esi
f010095d:	8d 76 00             	lea    0x0(%esi),%esi
f0100960:	75 16                	jne    f0100978 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100962:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100969:	00 
f010096a:	c7 04 24 4b 44 10 f0 	movl   $0xf010444b,(%esp)
f0100971:	e8 fc 25 00 00       	call   f0102f72 <cprintf>
f0100976:	eb 99                	jmp    f0100911 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100978:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010097c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010097f:	0f b6 03             	movzbl (%ebx),%eax
f0100982:	84 c0                	test   %al,%al
f0100984:	75 0c                	jne    f0100992 <monitor+0xa2>
f0100986:	eb af                	jmp    f0100937 <monitor+0x47>
			buf++;
f0100988:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010098b:	0f b6 03             	movzbl (%ebx),%eax
f010098e:	84 c0                	test   %al,%al
f0100990:	74 a5                	je     f0100937 <monitor+0x47>
f0100992:	0f be c0             	movsbl %al,%eax
f0100995:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100999:	c7 04 24 46 44 10 f0 	movl   $0xf0104446,(%esp)
f01009a0:	e8 61 32 00 00       	call   f0103c06 <strchr>
f01009a5:	85 c0                	test   %eax,%eax
f01009a7:	74 df                	je     f0100988 <monitor+0x98>
f01009a9:	eb 8c                	jmp    f0100937 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f01009ab:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009b2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009b3:	85 f6                	test   %esi,%esi
f01009b5:	0f 84 56 ff ff ff    	je     f0100911 <monitor+0x21>
f01009bb:	bb e0 46 10 f0       	mov    $0xf01046e0,%ebx
f01009c0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c5:	8b 03                	mov    (%ebx),%eax
f01009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009cb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009ce:	89 04 24             	mov    %eax,(%esp)
f01009d1:	e8 b5 31 00 00       	call   f0103b8b <strcmp>
f01009d6:	85 c0                	test   %eax,%eax
f01009d8:	75 24                	jne    f01009fe <monitor+0x10e>
			return commands[i].func(argc, argv, tf);
f01009da:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01009dd:	8b 55 08             	mov    0x8(%ebp),%edx
f01009e0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01009e4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009e7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009eb:	89 34 24             	mov    %esi,(%esp)
f01009ee:	ff 14 85 e8 46 10 f0 	call   *-0xfefb918(,%eax,4)
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009f5:	85 c0                	test   %eax,%eax
f01009f7:	78 28                	js     f0100a21 <monitor+0x131>
f01009f9:	e9 13 ff ff ff       	jmp    f0100911 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009fe:	83 c7 01             	add    $0x1,%edi
f0100a01:	83 c3 0c             	add    $0xc,%ebx
f0100a04:	83 ff 04             	cmp    $0x4,%edi
f0100a07:	75 bc                	jne    f01009c5 <monitor+0xd5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a09:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a10:	c7 04 24 68 44 10 f0 	movl   $0xf0104468,(%esp)
f0100a17:	e8 56 25 00 00       	call   f0102f72 <cprintf>
f0100a1c:	e9 f0 fe ff ff       	jmp    f0100911 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a21:	83 c4 5c             	add    $0x5c,%esp
f0100a24:	5b                   	pop    %ebx
f0100a25:	5e                   	pop    %esi
f0100a26:	5f                   	pop    %edi
f0100a27:	5d                   	pop    %ebp
f0100a28:	c3                   	ret    
f0100a29:	00 00                	add    %al,(%eax)
	...

f0100a2c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a2c:	55                   	push   %ebp
f0100a2d:	89 e5                	mov    %esp,%ebp
f0100a2f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a32:	89 d1                	mov    %edx,%ecx
f0100a34:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a37:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100a3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a3f:	f6 c1 01             	test   $0x1,%cl
f0100a42:	74 57                	je     f0100a9b <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a44:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a4a:	89 c8                	mov    %ecx,%eax
f0100a4c:	c1 e8 0c             	shr    $0xc,%eax
f0100a4f:	3b 05 84 89 11 f0    	cmp    0xf0118984,%eax
f0100a55:	72 20                	jb     f0100a77 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a57:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a5b:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0100a62:	f0 
f0100a63:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0100a6a:	00 
f0100a6b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100a72:	e8 1d f6 ff ff       	call   f0100094 <_panic>
	//cprintf("**%x\n", p);
	if (!(p[PTX(va)] & PTE_P))
f0100a77:	c1 ea 0c             	shr    $0xc,%edx
f0100a7a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a80:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100a87:	89 c2                	mov    %eax,%edx
f0100a89:	83 e2 01             	and    $0x1,%edx
		return ~0;
	//cprintf("**%x\n\n", p[PTX(va)]);
	return PTE_ADDR(p[PTX(va)]);
f0100a8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a91:	85 d2                	test   %edx,%edx
f0100a93:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a98:	0f 44 c2             	cmove  %edx,%eax
}
f0100a9b:	c9                   	leave  
f0100a9c:	c3                   	ret    

f0100a9d <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a9d:	55                   	push   %ebp
f0100a9e:	89 e5                	mov    %esp,%ebp
f0100aa0:	83 ec 18             	sub    $0x18,%esp
f0100aa3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100aa6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aa9:	83 3d 5c 85 11 f0 00 	cmpl   $0x0,0xf011855c
f0100ab0:	75 11                	jne    f0100ac3 <boot_alloc+0x26>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab2:	ba 8f 99 11 f0       	mov    $0xf011998f,%edx
f0100ab7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100abd:	89 15 5c 85 11 f0    	mov    %edx,0xf011855c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f0100ac3:	83 3d 00 83 11 f0 ff 	cmpl   $0xffffffff,0xf0118300
f0100aca:	75 0c                	jne    f0100ad8 <boot_alloc+0x3b>
		npages_left = npages;
f0100acc:	8b 15 84 89 11 f0    	mov    0xf0118984,%edx
f0100ad2:	89 15 00 83 11 f0    	mov    %edx,0xf0118300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f0100ad8:	85 c0                	test   %eax,%eax
f0100ada:	75 2c                	jne    f0100b08 <boot_alloc+0x6b>
// !- Whether I should check here -!
		if(npages_left < 1) {
f0100adc:	83 3d 00 83 11 f0 00 	cmpl   $0x0,0xf0118300
f0100ae3:	75 1c                	jne    f0100b01 <boot_alloc+0x64>
			panic("Out of memory!\n");
f0100ae5:	c7 44 24 08 80 4e 10 	movl   $0xf0104e80,0x8(%esp)
f0100aec:	f0 
f0100aed:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f0100af4:	00 
f0100af5:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100afc:	e8 93 f5 ff ff       	call   f0100094 <_panic>
		}
		result = nextfree;
f0100b01:	a1 5c 85 11 f0       	mov    0xf011855c,%eax
f0100b06:	eb 5c                	jmp    f0100b64 <boot_alloc+0xc7>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f0100b08:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f0100b0e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		cprintf("Request %u\n", srequest/PGSIZE);
f0100b14:	89 f3                	mov    %esi,%ebx
f0100b16:	c1 eb 0c             	shr    $0xc,%ebx
f0100b19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b1d:	c7 04 24 90 4e 10 f0 	movl   $0xf0104e90,(%esp)
f0100b24:	e8 49 24 00 00       	call   f0102f72 <cprintf>

		if(npages_left < srequest/PGSIZE) {
f0100b29:	8b 15 00 83 11 f0    	mov    0xf0118300,%edx
f0100b2f:	39 d3                	cmp    %edx,%ebx
f0100b31:	76 1c                	jbe    f0100b4f <boot_alloc+0xb2>
			panic("Out of memory!\n");
f0100b33:	c7 44 24 08 80 4e 10 	movl   $0xf0104e80,0x8(%esp)
f0100b3a:	f0 
f0100b3b:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
f0100b42:	00 
f0100b43:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100b4a:	e8 45 f5 ff ff       	call   f0100094 <_panic>
		}
		result = nextfree;
f0100b4f:	a1 5c 85 11 f0       	mov    0xf011855c,%eax
		nextfree += srequest;
f0100b54:	01 c6                	add    %eax,%esi
f0100b56:	89 35 5c 85 11 f0    	mov    %esi,0xf011855c
		npages_left -= srequest/PGSIZE;
f0100b5c:	29 da                	sub    %ebx,%edx
f0100b5e:	89 15 00 83 11 f0    	mov    %edx,0xf0118300

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
	//******************************My code ends***********************************//
}
f0100b64:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b67:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b6a:	89 ec                	mov    %ebp,%esp
f0100b6c:	5d                   	pop    %ebp
f0100b6d:	c3                   	ret    

f0100b6e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b6e:	55                   	push   %ebp
f0100b6f:	89 e5                	mov    %esp,%ebp
f0100b71:	83 ec 18             	sub    $0x18,%esp
f0100b74:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100b77:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100b7a:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b7c:	89 04 24             	mov    %eax,(%esp)
f0100b7f:	e8 80 23 00 00       	call   f0102f04 <mc146818_read>
f0100b84:	89 c6                	mov    %eax,%esi
f0100b86:	83 c3 01             	add    $0x1,%ebx
f0100b89:	89 1c 24             	mov    %ebx,(%esp)
f0100b8c:	e8 73 23 00 00       	call   f0102f04 <mc146818_read>
f0100b91:	c1 e0 08             	shl    $0x8,%eax
f0100b94:	09 f0                	or     %esi,%eax
}
f0100b96:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b99:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b9c:	89 ec                	mov    %ebp,%esp
f0100b9e:	5d                   	pop    %ebp
f0100b9f:	c3                   	ret    

f0100ba0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ba0:	55                   	push   %ebp
f0100ba1:	89 e5                	mov    %esp,%ebp
f0100ba3:	57                   	push   %edi
f0100ba4:	56                   	push   %esi
f0100ba5:	53                   	push   %ebx
f0100ba6:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba9:	3c 01                	cmp    $0x1,%al
f0100bab:	19 f6                	sbb    %esi,%esi
f0100bad:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100bb3:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100bb6:	8b 1d 60 85 11 f0    	mov    0xf0118560,%ebx
f0100bbc:	85 db                	test   %ebx,%ebx
f0100bbe:	75 1c                	jne    f0100bdc <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100bc0:	c7 44 24 08 34 47 10 	movl   $0xf0104734,0x8(%esp)
f0100bc7:	f0 
f0100bc8:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f0100bcf:	00 
f0100bd0:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100bd7:	e8 b8 f4 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
f0100bdc:	84 c0                	test   %al,%al
f0100bde:	74 50                	je     f0100c30 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100be0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100be3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100be6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100be9:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bec:	89 d8                	mov    %ebx,%eax
f0100bee:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0100bf4:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bf7:	c1 e8 16             	shr    $0x16,%eax
f0100bfa:	39 c6                	cmp    %eax,%esi
f0100bfc:	0f 96 c0             	setbe  %al
f0100bff:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c02:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100c06:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100c08:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0c:	8b 1b                	mov    (%ebx),%ebx
f0100c0e:	85 db                	test   %ebx,%ebx
f0100c10:	75 da                	jne    f0100bec <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c12:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c21:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c23:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100c26:	89 1d 60 85 11 f0    	mov    %ebx,0xf0118560
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c2c:	85 db                	test   %ebx,%ebx
f0100c2e:	74 67                	je     f0100c97 <check_page_free_list+0xf7>
f0100c30:	89 d8                	mov    %ebx,%eax
f0100c32:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0100c38:	c1 f8 03             	sar    $0x3,%eax
f0100c3b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c3e:	89 c2                	mov    %eax,%edx
f0100c40:	c1 ea 16             	shr    $0x16,%edx
f0100c43:	39 d6                	cmp    %edx,%esi
f0100c45:	76 4a                	jbe    f0100c91 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c47:	89 c2                	mov    %eax,%edx
f0100c49:	c1 ea 0c             	shr    $0xc,%edx
f0100c4c:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f0100c52:	72 20                	jb     f0100c74 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c54:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c58:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0100c5f:	f0 
f0100c60:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c67:	00 
f0100c68:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f0100c6f:	e8 20 f4 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c74:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c7b:	00 
f0100c7c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c83:	00 
	return (void *)(pa + KERNBASE);
f0100c84:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c89:	89 04 24             	mov    %eax,(%esp)
f0100c8c:	e8 d0 2f 00 00       	call   f0103c61 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c91:	8b 1b                	mov    (%ebx),%ebx
f0100c93:	85 db                	test   %ebx,%ebx
f0100c95:	75 99                	jne    f0100c30 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c97:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c9c:	e8 fc fd ff ff       	call   f0100a9d <boot_alloc>
f0100ca1:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca4:	8b 15 60 85 11 f0    	mov    0xf0118560,%edx
f0100caa:	85 d2                	test   %edx,%edx
f0100cac:	0f 84 f6 01 00 00    	je     f0100ea8 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb2:	8b 1d 8c 89 11 f0    	mov    0xf011898c,%ebx
f0100cb8:	39 da                	cmp    %ebx,%edx
f0100cba:	72 4d                	jb     f0100d09 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f0100cbc:	a1 84 89 11 f0       	mov    0xf0118984,%eax
f0100cc1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cc4:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100cc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100cca:	39 c2                	cmp    %eax,%edx
f0100ccc:	73 64                	jae    f0100d32 <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cce:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100cd1:	89 d0                	mov    %edx,%eax
f0100cd3:	29 d8                	sub    %ebx,%eax
f0100cd5:	a8 07                	test   $0x7,%al
f0100cd7:	0f 85 82 00 00 00    	jne    f0100d5f <check_page_free_list+0x1bf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cdd:	c1 f8 03             	sar    $0x3,%eax
f0100ce0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ce3:	85 c0                	test   %eax,%eax
f0100ce5:	0f 84 a2 00 00 00    	je     f0100d8d <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ceb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cf0:	0f 84 c2 00 00 00    	je     f0100db8 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cf6:	be 00 00 00 00       	mov    $0x0,%esi
f0100cfb:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d00:	e9 d7 00 00 00       	jmp    f0100ddc <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d05:	39 da                	cmp    %ebx,%edx
f0100d07:	73 24                	jae    f0100d2d <check_page_free_list+0x18d>
f0100d09:	c7 44 24 0c aa 4e 10 	movl   $0xf0104eaa,0xc(%esp)
f0100d10:	f0 
f0100d11:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100d18:	f0 
f0100d19:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f0100d20:	00 
f0100d21:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100d28:	e8 67 f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100d2d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d30:	72 24                	jb     f0100d56 <check_page_free_list+0x1b6>
f0100d32:	c7 44 24 0c cb 4e 10 	movl   $0xf0104ecb,0xc(%esp)
f0100d39:	f0 
f0100d3a:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100d41:	f0 
f0100d42:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0100d49:	00 
f0100d4a:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100d51:	e8 3e f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d56:	89 d0                	mov    %edx,%eax
f0100d58:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d5b:	a8 07                	test   $0x7,%al
f0100d5d:	74 24                	je     f0100d83 <check_page_free_list+0x1e3>
f0100d5f:	c7 44 24 0c 58 47 10 	movl   $0xf0104758,0xc(%esp)
f0100d66:	f0 
f0100d67:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100d6e:	f0 
f0100d6f:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f0100d76:	00 
f0100d77:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100d7e:	e8 11 f3 ff ff       	call   f0100094 <_panic>
f0100d83:	c1 f8 03             	sar    $0x3,%eax
f0100d86:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d89:	85 c0                	test   %eax,%eax
f0100d8b:	75 24                	jne    f0100db1 <check_page_free_list+0x211>
f0100d8d:	c7 44 24 0c df 4e 10 	movl   $0xf0104edf,0xc(%esp)
f0100d94:	f0 
f0100d95:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100d9c:	f0 
f0100d9d:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f0100da4:	00 
f0100da5:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100dac:	e8 e3 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100db1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100db6:	75 24                	jne    f0100ddc <check_page_free_list+0x23c>
f0100db8:	c7 44 24 0c f0 4e 10 	movl   $0xf0104ef0,0xc(%esp)
f0100dbf:	f0 
f0100dc0:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100dc7:	f0 
f0100dc8:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f0100dcf:	00 
f0100dd0:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100dd7:	e8 b8 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ddc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100de1:	75 24                	jne    f0100e07 <check_page_free_list+0x267>
f0100de3:	c7 44 24 0c 8c 47 10 	movl   $0xf010478c,0xc(%esp)
f0100dea:	f0 
f0100deb:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100df2:	f0 
f0100df3:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0100dfa:	00 
f0100dfb:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100e02:	e8 8d f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e07:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e0c:	75 24                	jne    f0100e32 <check_page_free_list+0x292>
f0100e0e:	c7 44 24 0c 09 4f 10 	movl   $0xf0104f09,0xc(%esp)
f0100e15:	f0 
f0100e16:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100e1d:	f0 
f0100e1e:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0100e25:	00 
f0100e26:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100e2d:	e8 62 f2 ff ff       	call   f0100094 <_panic>
f0100e32:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e34:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e39:	76 57                	jbe    f0100e92 <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3b:	c1 e8 0c             	shr    $0xc,%eax
f0100e3e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100e41:	77 20                	ja     f0100e63 <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e43:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100e47:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0100e4e:	f0 
f0100e4f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e56:	00 
f0100e57:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f0100e5e:	e8 31 f2 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100e63:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100e69:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e6c:	76 29                	jbe    f0100e97 <check_page_free_list+0x2f7>
f0100e6e:	c7 44 24 0c b0 47 10 	movl   $0xf01047b0,0xc(%esp)
f0100e75:	f0 
f0100e76:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100e7d:	f0 
f0100e7e:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
f0100e85:	00 
f0100e86:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100e8d:	e8 02 f2 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e92:	83 c7 01             	add    $0x1,%edi
f0100e95:	eb 03                	jmp    f0100e9a <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0100e97:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e9a:	8b 12                	mov    (%edx),%edx
f0100e9c:	85 d2                	test   %edx,%edx
f0100e9e:	0f 85 61 fe ff ff    	jne    f0100d05 <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ea4:	85 ff                	test   %edi,%edi
f0100ea6:	7f 24                	jg     f0100ecc <check_page_free_list+0x32c>
f0100ea8:	c7 44 24 0c 23 4f 10 	movl   $0xf0104f23,0xc(%esp)
f0100eaf:	f0 
f0100eb0:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100eb7:	f0 
f0100eb8:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f0100ebf:	00 
f0100ec0:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100ec7:	e8 c8 f1 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100ecc:	85 f6                	test   %esi,%esi
f0100ece:	7f 24                	jg     f0100ef4 <check_page_free_list+0x354>
f0100ed0:	c7 44 24 0c 35 4f 10 	movl   $0xf0104f35,0xc(%esp)
f0100ed7:	f0 
f0100ed8:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0100edf:	f0 
f0100ee0:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0100ee7:	00 
f0100ee8:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100eef:	e8 a0 f1 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ef4:	c7 04 24 f8 47 10 f0 	movl   $0xf01047f8,(%esp)
f0100efb:	e8 72 20 00 00       	call   f0102f72 <cprintf>
}
f0100f00:	83 c4 3c             	add    $0x3c,%esp
f0100f03:	5b                   	pop    %ebx
f0100f04:	5e                   	pop    %esi
f0100f05:	5f                   	pop    %edi
f0100f06:	5d                   	pop    %ebp
f0100f07:	c3                   	ret    

f0100f08 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f08:	55                   	push   %ebp
f0100f09:	89 e5                	mov    %esp,%ebp
f0100f0b:	57                   	push   %edi
f0100f0c:	56                   	push   %esi
f0100f0d:	53                   	push   %ebx
f0100f0e:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0100f11:	83 3d 84 89 11 f0 00 	cmpl   $0x0,0xf0118984
f0100f18:	0f 85 98 00 00 00    	jne    f0100fb6 <page_init+0xae>
f0100f1e:	e9 a5 00 00 00       	jmp    f0100fc8 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f0100f23:	a1 8c 89 11 f0       	mov    0xf011898c,%eax
f0100f28:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f0100f2f:	8d 3c 30             	lea    (%eax,%esi,1),%edi
f0100f32:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f0100f38:	85 db                	test   %ebx,%ebx
f0100f3a:	74 69                	je     f0100fa5 <page_init+0x9d>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f3c:	29 c7                	sub    %eax,%edi
f0100f3e:	c1 ff 03             	sar    $0x3,%edi
f0100f41:	c1 e7 0c             	shl    $0xc,%edi
		// 4) Then extended memory [EXTPHYSMEM, ...).
		// extended memory: 0x100000~
		//   0x100000~0x115000 is allocated to kernel(0x115000 is the end of .bss segment)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		if(page2pa(&pages[i]) >= IOPHYSMEM
f0100f44:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f0100f4a:	76 3f                	jbe    f0100f8b <page_init+0x83>
			&& page2pa(&pages[i]) < ROUNDUP(PADDR(boot_alloc(0)), PGSIZE)) {	
f0100f4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f51:	e8 47 fb ff ff       	call   f0100a9d <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f56:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f5b:	77 20                	ja     f0100f7d <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f61:	c7 44 24 08 1c 48 10 	movl   $0xf010481c,0x8(%esp)
f0100f68:	f0 
f0100f69:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f0100f70:	00 
f0100f71:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0100f78:	e8 17 f1 ff ff       	call   f0100094 <_panic>
f0100f7d:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0100f82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f87:	39 f8                	cmp    %edi,%eax
f0100f89:	77 1a                	ja     f0100fa5 <page_init+0x9d>
			continue;	
		}
		
		// others is free
		pages[i].pp_link = page_free_list;
f0100f8b:	8b 15 60 85 11 f0    	mov    0xf0118560,%edx
f0100f91:	a1 8c 89 11 f0       	mov    0xf011898c,%eax
f0100f96:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f0100f99:	03 35 8c 89 11 f0    	add    0xf011898c,%esi
f0100f9f:	89 35 60 85 11 f0    	mov    %esi,0xf0118560
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0100fa5:	83 c3 01             	add    $0x1,%ebx
f0100fa8:	39 1d 84 89 11 f0    	cmp    %ebx,0xf0118984
f0100fae:	0f 87 6f ff ff ff    	ja     f0100f23 <page_init+0x1b>
f0100fb4:	eb 12                	jmp    f0100fc8 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f0100fb6:	a1 8c 89 11 f0       	mov    0xf011898c,%eax
f0100fbb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0100fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100fc6:	eb dd                	jmp    f0100fa5 <page_init+0x9d>
		
		// others is free
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100fc8:	83 c4 1c             	add    $0x1c,%esp
f0100fcb:	5b                   	pop    %ebx
f0100fcc:	5e                   	pop    %esi
f0100fcd:	5f                   	pop    %edi
f0100fce:	5d                   	pop    %ebp
f0100fcf:	c3                   	ret    

f0100fd0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fd0:	55                   	push   %ebp
f0100fd1:	89 e5                	mov    %esp,%ebp
f0100fd3:	53                   	push   %ebx
f0100fd4:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in

	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	struct PageInfo *result = NULL;
	if(page_free_list) {
f0100fd7:	8b 1d 60 85 11 f0    	mov    0xf0118560,%ebx
f0100fdd:	85 db                	test   %ebx,%ebx
f0100fdf:	74 65                	je     f0101046 <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100fe1:	8b 03                	mov    (%ebx),%eax
f0100fe3:	a3 60 85 11 f0       	mov    %eax,0xf0118560
		
		if(alloc_flags & ALLOC_ZERO) { 
f0100fe8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fec:	74 58                	je     f0101046 <page_alloc+0x76>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fee:	89 d8                	mov    %ebx,%eax
f0100ff0:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0100ff6:	c1 f8 03             	sar    $0x3,%eax
f0100ff9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ffc:	89 c2                	mov    %eax,%edx
f0100ffe:	c1 ea 0c             	shr    $0xc,%edx
f0101001:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f0101007:	72 20                	jb     f0101029 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101009:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010100d:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0101014:	f0 
f0101015:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010101c:	00 
f010101d:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f0101024:	e8 6b f0 ff ff       	call   f0100094 <_panic>
			// fill in '\0'
			memset(page2kva(result), 0, PGSIZE);
f0101029:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101030:	00 
f0101031:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101038:	00 
	return (void *)(pa + KERNBASE);
f0101039:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010103e:	89 04 24             	mov    %eax,(%esp)
f0101041:	e8 1b 2c 00 00       	call   f0103c61 <memset>
		}
	}
	return result;
}
f0101046:	89 d8                	mov    %ebx,%eax
f0101048:	83 c4 14             	add    $0x14,%esp
f010104b:	5b                   	pop    %ebx
f010104c:	5d                   	pop    %ebp
f010104d:	c3                   	ret    

f010104e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010104e:	55                   	push   %ebp
f010104f:	89 e5                	mov    %esp,%ebp
f0101051:	83 ec 18             	sub    $0x18,%esp
f0101054:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(!pp)
f0101057:	85 c0                	test   %eax,%eax
f0101059:	75 1c                	jne    f0101077 <page_free+0x29>
		panic("page_free: invalid page to free!\n");
f010105b:	c7 44 24 08 40 48 10 	movl   $0xf0104840,0x8(%esp)
f0101062:	f0 
f0101063:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f010106a:	00 
f010106b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101072:	e8 1d f0 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0101077:	8b 15 60 85 11 f0    	mov    0xf0118560,%edx
f010107d:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010107f:	a3 60 85 11 f0       	mov    %eax,0xf0118560
}
f0101084:	c9                   	leave  
f0101085:	c3                   	ret    

f0101086 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101086:	55                   	push   %ebp
f0101087:	89 e5                	mov    %esp,%ebp
f0101089:	83 ec 18             	sub    $0x18,%esp
f010108c:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010108f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101093:	83 ea 01             	sub    $0x1,%edx
f0101096:	66 89 50 04          	mov    %dx,0x4(%eax)
f010109a:	66 85 d2             	test   %dx,%dx
f010109d:	75 08                	jne    f01010a7 <page_decref+0x21>
		page_free(pp);
f010109f:	89 04 24             	mov    %eax,(%esp)
f01010a2:	e8 a7 ff ff ff       	call   f010104e <page_free>
}
f01010a7:	c9                   	leave  
f01010a8:	c3                   	ret    

f01010a9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010a9:	55                   	push   %ebp
f01010aa:	89 e5                	mov    %esp,%ebp
f01010ac:	56                   	push   %esi
f01010ad:	53                   	push   %ebx
f01010ae:	83 ec 10             	sub    $0x10,%esp
f01010b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
f01010b4:	89 f3                	mov    %esi,%ebx
f01010b6:	c1 eb 16             	shr    $0x16,%ebx
	uintptr_t ptx = PTX(va);
	uintptr_t pgoff = PGOFF(va);

	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];
f01010b9:	c1 e3 02             	shl    $0x2,%ebx
f01010bc:	03 5d 08             	add    0x8(%ebp),%ebx

	if(((*pde) & PTE_P) == 0) {
f01010bf:	f6 03 01             	testb  $0x1,(%ebx)
f01010c2:	75 2c                	jne    f01010f0 <pgdir_walk+0x47>
		if(create == 0) 
f01010c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010c8:	74 6c                	je     f0101136 <pgdir_walk+0x8d>
			return NULL;
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
f01010ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010d1:	e8 fa fe ff ff       	call   f0100fd0 <page_alloc>
			if(pgtbl == NULL)
f01010d6:	85 c0                	test   %eax,%eax
f01010d8:	74 63                	je     f010113d <pgdir_walk+0x94>
				return NULL;
			else {
				pgtbl->pp_ref ++;
f01010da:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010df:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f01010e5:	c1 f8 03             	sar    $0x3,%eax
f01010e8:	c1 e0 0c             	shl    $0xc,%eax
				/* store in physical address*/
				*pde = page2pa(pgtbl) | PTE_U | PTE_W | PTE_P;
f01010eb:	83 c8 07             	or     $0x7,%eax
f01010ee:	89 03                	mov    %eax,(%ebx)
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01010f0:	8b 03                	mov    (%ebx),%eax
f01010f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010f7:	89 c2                	mov    %eax,%edx
f01010f9:	c1 ea 0c             	shr    $0xc,%edx
f01010fc:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f0101102:	72 20                	jb     f0101124 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101104:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101108:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f010110f:	f0 
f0101110:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
f0101117:	00 
f0101118:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010111f:	e8 70 ef ff ff       	call   f0100094 <_panic>
{
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
	uintptr_t ptx = PTX(va);
f0101124:	c1 ee 0a             	shr    $0xa,%esi
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f0101127:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010112d:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return pte;
f0101134:	eb 0c                	jmp    f0101142 <pgdir_walk+0x99>
	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];

	if(((*pde) & PTE_P) == 0) {
		if(create == 0) 
			return NULL;
f0101136:	b8 00 00 00 00       	mov    $0x0,%eax
f010113b:	eb 05                	jmp    f0101142 <pgdir_walk+0x99>
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
			if(pgtbl == NULL)
				return NULL;
f010113d:	b8 00 00 00 00       	mov    $0x0,%eax
	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;

	return pte;
}
f0101142:	83 c4 10             	add    $0x10,%esp
f0101145:	5b                   	pop    %ebx
f0101146:	5e                   	pop    %esi
f0101147:	5d                   	pop    %ebp
f0101148:	c3                   	ret    

f0101149 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101149:	55                   	push   %ebp
f010114a:	89 e5                	mov    %esp,%ebp
f010114c:	57                   	push   %edi
f010114d:	56                   	push   %esi
f010114e:	53                   	push   %ebx
f010114f:	83 ec 2c             	sub    $0x2c,%esp
f0101152:	89 c7                	mov    %eax,%edi
f0101154:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101157:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f010115d:	c1 e9 0c             	shr    $0xc,%ecx
f0101160:	85 c9                	test   %ecx,%ecx
f0101162:	74 4b                	je     f01011af <boot_map_region+0x66>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101164:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101167:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010116c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101172:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f0101175:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101178:	83 c8 01             	or     $0x1,%eax
f010117b:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010117e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101185:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101186:	89 d8                	mov    %ebx,%eax
f0101188:	c1 e0 0c             	shl    $0xc,%eax

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010118b:	03 45 e0             	add    -0x20(%ebp),%eax
f010118e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101192:	89 3c 24             	mov    %edi,(%esp)
f0101195:	e8 0f ff ff ff       	call   f01010a9 <pgdir_walk>
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f010119a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010119d:	09 f2                	or     %esi,%edx
f010119f:	89 10                	mov    %edx,(%eax)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01011a1:	83 c3 01             	add    $0x1,%ebx
f01011a4:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01011aa:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01011ad:	75 cf                	jne    f010117e <boot_map_region+0x35>
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
	}
}
f01011af:	83 c4 2c             	add    $0x2c,%esp
f01011b2:	5b                   	pop    %ebx
f01011b3:	5e                   	pop    %esi
f01011b4:	5f                   	pop    %edi
f01011b5:	5d                   	pop    %ebp
f01011b6:	c3                   	ret    

f01011b7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01011b7:	55                   	push   %ebp
f01011b8:	89 e5                	mov    %esp,%ebp
f01011ba:	53                   	push   %ebx
f01011bb:	83 ec 14             	sub    $0x14,%esp
f01011be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
f01011c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01011c8:	00 
f01011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01011d3:	89 04 24             	mov    %eax,(%esp)
f01011d6:	e8 ce fe ff ff       	call   f01010a9 <pgdir_walk>
	struct PageInfo *pg = NULL;
	// Check if the pte_store is zero
	if(pte_store != 0)
f01011db:	85 db                	test   %ebx,%ebx
f01011dd:	74 02                	je     f01011e1 <page_lookup+0x2a>
		*pte_store = pte;
f01011df:	89 03                	mov    %eax,(%ebx)

	// Check if the page is mapped
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
f01011e1:	85 c0                	test   %eax,%eax
f01011e3:	74 38                	je     f010121d <page_lookup+0x66>
f01011e5:	8b 00                	mov    (%eax),%eax
f01011e7:	a8 01                	test   $0x1,%al
f01011e9:	74 39                	je     f0101224 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011eb:	c1 e8 0c             	shr    $0xc,%eax
f01011ee:	3b 05 84 89 11 f0    	cmp    0xf0118984,%eax
f01011f4:	72 1c                	jb     f0101212 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01011f6:	c7 44 24 08 64 48 10 	movl   $0xf0104864,0x8(%esp)
f01011fd:	f0 
f01011fe:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101205:	00 
f0101206:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f010120d:	e8 82 ee ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101212:	c1 e0 03             	shl    $0x3,%eax
f0101215:	03 05 8c 89 11 f0    	add    0xf011898c,%eax
f010121b:	eb 0c                	jmp    f0101229 <page_lookup+0x72>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
	struct PageInfo *pg = NULL;
f010121d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101222:	eb 05                	jmp    f0101229 <page_lookup+0x72>
f0101224:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
		pg = pa2page(PTE_ADDR(*pte));
	}

	return pg;
}
f0101229:	83 c4 14             	add    $0x14,%esp
f010122c:	5b                   	pop    %ebx
f010122d:	5d                   	pop    %ebp
f010122e:	c3                   	ret    

f010122f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010122f:	55                   	push   %ebp
f0101230:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101232:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101235:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101238:	5d                   	pop    %ebp
f0101239:	c3                   	ret    

f010123a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010123a:	55                   	push   %ebp
f010123b:	89 e5                	mov    %esp,%ebp
f010123d:	83 ec 28             	sub    $0x28,%esp
f0101240:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101243:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101246:	8b 75 08             	mov    0x8(%ebp),%esi
f0101249:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;

	// look up the pte for the va
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010124c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010124f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101253:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101257:	89 34 24             	mov    %esi,(%esp)
f010125a:	e8 58 ff ff ff       	call   f01011b7 <page_lookup>

	if(pg != NULL) {
f010125f:	85 c0                	test   %eax,%eax
f0101261:	74 1d                	je     f0101280 <page_remove+0x46>
		// Decrease the count and free
		page_decref(pg);
f0101263:	89 04 24             	mov    %eax,(%esp)
f0101266:	e8 1b fe ff ff       	call   f0101086 <page_decref>
		// Set the pte to zero
		*pte = 0;
f010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010126e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		// The TLB must be invalidated if a page was formerly present at 'va'.
		tlb_invalidate(pgdir, va);
f0101274:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101278:	89 34 24             	mov    %esi,(%esp)
f010127b:	e8 af ff ff ff       	call   f010122f <tlb_invalidate>
	}
}
f0101280:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101283:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101286:	89 ec                	mov    %ebp,%esp
f0101288:	5d                   	pop    %ebp
f0101289:	c3                   	ret    

f010128a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010128a:	55                   	push   %ebp
f010128b:	89 e5                	mov    %esp,%ebp
f010128d:	83 ec 28             	sub    $0x28,%esp
f0101290:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101293:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101296:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101299:	8b 75 0c             	mov    0xc(%ebp),%esi
f010129c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
f010129f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012a6:	00 
f01012a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ae:	89 04 24             	mov    %eax,(%esp)
f01012b1:	e8 f3 fd ff ff       	call   f01010a9 <pgdir_walk>
f01012b6:	89 c3                	mov    %eax,%ebx
	if(pte == NULL) 
f01012b8:	85 c0                	test   %eax,%eax
f01012ba:	74 66                	je     f0101322 <page_insert+0x98>
		return -E_NO_MEM;
	// If there is already a page mapped at 'va', it should be page_remove()d.
	if(((*pte) & PTE_P) == 1) {
f01012bc:	8b 00                	mov    (%eax),%eax
f01012be:	a8 01                	test   $0x1,%al
f01012c0:	74 3c                	je     f01012fe <page_insert+0x74>
		//On one hand, the mapped page is pp;
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f01012c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012c7:	89 f2                	mov    %esi,%edx
f01012c9:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f01012cf:	c1 fa 03             	sar    $0x3,%edx
f01012d2:	c1 e2 0c             	shl    $0xc,%edx
f01012d5:	39 d0                	cmp    %edx,%eax
f01012d7:	75 16                	jne    f01012ef <page_insert+0x65>
			// The TLB must be invalidated if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f01012d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01012e0:	89 04 24             	mov    %eax,(%esp)
f01012e3:	e8 47 ff ff ff       	call   f010122f <tlb_invalidate>
			// The reference for the same page should not change(latter add one)
			pp->pp_ref --;
f01012e8:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f01012ed:	eb 0f                	jmp    f01012fe <page_insert+0x74>
		}
		//On the other hand, the mapped page is not pp;
		else
			page_remove(pgdir, va);
f01012ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f6:	89 04 24             	mov    %eax,(%esp)
f01012f9:	e8 3c ff ff ff       	call   f010123a <page_remove>
	}

	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
f01012fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101301:	83 c8 01             	or     $0x1,%eax
f0101304:	89 f2                	mov    %esi,%edx
f0101306:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f010130c:	c1 fa 03             	sar    $0x3,%edx
f010130f:	c1 e2 0c             	shl    $0xc,%edx
f0101312:	09 d0                	or     %edx,%eax
f0101314:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref ++;
f0101316:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	
	return 0;
f010131b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101320:	eb 05                	jmp    f0101327 <page_insert+0x9d>
{
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
	if(pte == NULL) 
		return -E_NO_MEM;
f0101322:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref ++;
	
	return 0;
}
f0101327:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010132a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010132d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101330:	89 ec                	mov    %ebp,%esp
f0101332:	5d                   	pop    %ebp
f0101333:	c3                   	ret    

f0101334 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101334:	55                   	push   %ebp
f0101335:	89 e5                	mov    %esp,%ebp
f0101337:	57                   	push   %edi
f0101338:	56                   	push   %esi
f0101339:	53                   	push   %ebx
f010133a:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010133d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101342:	e8 27 f8 ff ff       	call   f0100b6e <nvram_read>
f0101347:	c1 e0 0a             	shl    $0xa,%eax
f010134a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101350:	85 c0                	test   %eax,%eax
f0101352:	0f 48 c2             	cmovs  %edx,%eax
f0101355:	c1 f8 0c             	sar    $0xc,%eax
f0101358:	a3 58 85 11 f0       	mov    %eax,0xf0118558
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010135d:	b8 17 00 00 00       	mov    $0x17,%eax
f0101362:	e8 07 f8 ff ff       	call   f0100b6e <nvram_read>
f0101367:	c1 e0 0a             	shl    $0xa,%eax
f010136a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101370:	85 c0                	test   %eax,%eax
f0101372:	0f 48 c2             	cmovs  %edx,%eax
f0101375:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101378:	85 c0                	test   %eax,%eax
f010137a:	74 0e                	je     f010138a <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010137c:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101382:	89 15 84 89 11 f0    	mov    %edx,0xf0118984
f0101388:	eb 0c                	jmp    f0101396 <mem_init+0x62>
	else
		npages = npages_basemem;
f010138a:	8b 15 58 85 11 f0    	mov    0xf0118558,%edx
f0101390:	89 15 84 89 11 f0    	mov    %edx,0xf0118984

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101396:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101399:	c1 e8 0a             	shr    $0xa,%eax
f010139c:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01013a0:	a1 58 85 11 f0       	mov    0xf0118558,%eax
f01013a5:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013a8:	c1 e8 0a             	shr    $0xa,%eax
f01013ab:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01013af:	a1 84 89 11 f0       	mov    0xf0118984,%eax
f01013b4:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b7:	c1 e8 0a             	shr    $0xa,%eax
f01013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013be:	c7 04 24 84 48 10 f0 	movl   $0xf0104884,(%esp)
f01013c5:	e8 a8 1b 00 00       	call   f0102f72 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013ca:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013cf:	e8 c9 f6 ff ff       	call   f0100a9d <boot_alloc>
f01013d4:	a3 88 89 11 f0       	mov    %eax,0xf0118988
	memset(kern_pgdir, 0, PGSIZE);
f01013d9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013e0:	00 
f01013e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013e8:	00 
f01013e9:	89 04 24             	mov    %eax,(%esp)
f01013ec:	e8 70 28 00 00       	call   f0103c61 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013f1:	a1 88 89 11 f0       	mov    0xf0118988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013f6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013fb:	77 20                	ja     f010141d <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101401:	c7 44 24 08 1c 48 10 	movl   $0xf010481c,0x8(%esp)
f0101408:	f0 
f0101409:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
f0101410:	00 
f0101411:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101418:	e8 77 ec ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010141d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101423:	83 ca 05             	or     $0x5,%edx
f0101426:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f010142c:	a1 84 89 11 f0       	mov    0xf0118984,%eax
f0101431:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101434:	e8 64 f6 ff ff       	call   f0100a9d <boot_alloc>
f0101439:	a3 8c 89 11 f0       	mov    %eax,0xf011898c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010143e:	e8 c5 fa ff ff       	call   f0100f08 <page_init>

	check_page_free_list(1);
f0101443:	b8 01 00 00 00       	mov    $0x1,%eax
f0101448:	e8 53 f7 ff ff       	call   f0100ba0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010144d:	83 3d 8c 89 11 f0 00 	cmpl   $0x0,0xf011898c
f0101454:	75 1c                	jne    f0101472 <mem_init+0x13e>
		panic("'pages' is a null pointer!");
f0101456:	c7 44 24 08 46 4f 10 	movl   $0xf0104f46,0x8(%esp)
f010145d:	f0 
f010145e:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f0101465:	00 
f0101466:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010146d:	e8 22 ec ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101472:	a1 60 85 11 f0       	mov    0xf0118560,%eax
f0101477:	bb 00 00 00 00       	mov    $0x0,%ebx
f010147c:	85 c0                	test   %eax,%eax
f010147e:	74 09                	je     f0101489 <mem_init+0x155>
		++nfree;
f0101480:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101483:	8b 00                	mov    (%eax),%eax
f0101485:	85 c0                	test   %eax,%eax
f0101487:	75 f7                	jne    f0101480 <mem_init+0x14c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101489:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101490:	e8 3b fb ff ff       	call   f0100fd0 <page_alloc>
f0101495:	89 c6                	mov    %eax,%esi
f0101497:	85 c0                	test   %eax,%eax
f0101499:	75 24                	jne    f01014bf <mem_init+0x18b>
f010149b:	c7 44 24 0c 61 4f 10 	movl   $0xf0104f61,0xc(%esp)
f01014a2:	f0 
f01014a3:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01014aa:	f0 
f01014ab:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f01014b2:	00 
f01014b3:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01014ba:	e8 d5 eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01014bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014c6:	e8 05 fb ff ff       	call   f0100fd0 <page_alloc>
f01014cb:	89 c7                	mov    %eax,%edi
f01014cd:	85 c0                	test   %eax,%eax
f01014cf:	75 24                	jne    f01014f5 <mem_init+0x1c1>
f01014d1:	c7 44 24 0c 77 4f 10 	movl   $0xf0104f77,0xc(%esp)
f01014d8:	f0 
f01014d9:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01014e0:	f0 
f01014e1:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f01014e8:	00 
f01014e9:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01014f0:	e8 9f eb ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01014f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014fc:	e8 cf fa ff ff       	call   f0100fd0 <page_alloc>
f0101501:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101504:	85 c0                	test   %eax,%eax
f0101506:	75 24                	jne    f010152c <mem_init+0x1f8>
f0101508:	c7 44 24 0c 8d 4f 10 	movl   $0xf0104f8d,0xc(%esp)
f010150f:	f0 
f0101510:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101517:	f0 
f0101518:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f010151f:	00 
f0101520:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101527:	e8 68 eb ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010152c:	39 fe                	cmp    %edi,%esi
f010152e:	75 24                	jne    f0101554 <mem_init+0x220>
f0101530:	c7 44 24 0c a3 4f 10 	movl   $0xf0104fa3,0xc(%esp)
f0101537:	f0 
f0101538:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010153f:	f0 
f0101540:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0101547:	00 
f0101548:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010154f:	e8 40 eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101554:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101557:	74 05                	je     f010155e <mem_init+0x22a>
f0101559:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010155c:	75 24                	jne    f0101582 <mem_init+0x24e>
f010155e:	c7 44 24 0c c0 48 10 	movl   $0xf01048c0,0xc(%esp)
f0101565:	f0 
f0101566:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010156d:	f0 
f010156e:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0101575:	00 
f0101576:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010157d:	e8 12 eb ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101582:	8b 15 8c 89 11 f0    	mov    0xf011898c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101588:	a1 84 89 11 f0       	mov    0xf0118984,%eax
f010158d:	c1 e0 0c             	shl    $0xc,%eax
f0101590:	89 f1                	mov    %esi,%ecx
f0101592:	29 d1                	sub    %edx,%ecx
f0101594:	c1 f9 03             	sar    $0x3,%ecx
f0101597:	c1 e1 0c             	shl    $0xc,%ecx
f010159a:	39 c1                	cmp    %eax,%ecx
f010159c:	72 24                	jb     f01015c2 <mem_init+0x28e>
f010159e:	c7 44 24 0c b5 4f 10 	movl   $0xf0104fb5,0xc(%esp)
f01015a5:	f0 
f01015a6:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01015ad:	f0 
f01015ae:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f01015b5:	00 
f01015b6:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01015bd:	e8 d2 ea ff ff       	call   f0100094 <_panic>
f01015c2:	89 f9                	mov    %edi,%ecx
f01015c4:	29 d1                	sub    %edx,%ecx
f01015c6:	c1 f9 03             	sar    $0x3,%ecx
f01015c9:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01015cc:	39 c8                	cmp    %ecx,%eax
f01015ce:	77 24                	ja     f01015f4 <mem_init+0x2c0>
f01015d0:	c7 44 24 0c d2 4f 10 	movl   $0xf0104fd2,0xc(%esp)
f01015d7:	f0 
f01015d8:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01015df:	f0 
f01015e0:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01015e7:	00 
f01015e8:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01015ef:	e8 a0 ea ff ff       	call   f0100094 <_panic>
f01015f4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015f7:	29 d1                	sub    %edx,%ecx
f01015f9:	89 ca                	mov    %ecx,%edx
f01015fb:	c1 fa 03             	sar    $0x3,%edx
f01015fe:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101601:	39 d0                	cmp    %edx,%eax
f0101603:	77 24                	ja     f0101629 <mem_init+0x2f5>
f0101605:	c7 44 24 0c ef 4f 10 	movl   $0xf0104fef,0xc(%esp)
f010160c:	f0 
f010160d:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101614:	f0 
f0101615:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f010161c:	00 
f010161d:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101624:	e8 6b ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101629:	a1 60 85 11 f0       	mov    0xf0118560,%eax
f010162e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101631:	c7 05 60 85 11 f0 00 	movl   $0x0,0xf0118560
f0101638:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010163b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101642:	e8 89 f9 ff ff       	call   f0100fd0 <page_alloc>
f0101647:	85 c0                	test   %eax,%eax
f0101649:	74 24                	je     f010166f <mem_init+0x33b>
f010164b:	c7 44 24 0c 0c 50 10 	movl   $0xf010500c,0xc(%esp)
f0101652:	f0 
f0101653:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010165a:	f0 
f010165b:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101662:	00 
f0101663:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010166a:	e8 25 ea ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010166f:	89 34 24             	mov    %esi,(%esp)
f0101672:	e8 d7 f9 ff ff       	call   f010104e <page_free>
	page_free(pp1);
f0101677:	89 3c 24             	mov    %edi,(%esp)
f010167a:	e8 cf f9 ff ff       	call   f010104e <page_free>
	page_free(pp2);
f010167f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101682:	89 04 24             	mov    %eax,(%esp)
f0101685:	e8 c4 f9 ff ff       	call   f010104e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010168a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101691:	e8 3a f9 ff ff       	call   f0100fd0 <page_alloc>
f0101696:	89 c6                	mov    %eax,%esi
f0101698:	85 c0                	test   %eax,%eax
f010169a:	75 24                	jne    f01016c0 <mem_init+0x38c>
f010169c:	c7 44 24 0c 61 4f 10 	movl   $0xf0104f61,0xc(%esp)
f01016a3:	f0 
f01016a4:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01016ab:	f0 
f01016ac:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f01016b3:	00 
f01016b4:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01016bb:	e8 d4 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01016c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016c7:	e8 04 f9 ff ff       	call   f0100fd0 <page_alloc>
f01016cc:	89 c7                	mov    %eax,%edi
f01016ce:	85 c0                	test   %eax,%eax
f01016d0:	75 24                	jne    f01016f6 <mem_init+0x3c2>
f01016d2:	c7 44 24 0c 77 4f 10 	movl   $0xf0104f77,0xc(%esp)
f01016d9:	f0 
f01016da:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01016e1:	f0 
f01016e2:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f01016e9:	00 
f01016ea:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01016f1:	e8 9e e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01016f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016fd:	e8 ce f8 ff ff       	call   f0100fd0 <page_alloc>
f0101702:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101705:	85 c0                	test   %eax,%eax
f0101707:	75 24                	jne    f010172d <mem_init+0x3f9>
f0101709:	c7 44 24 0c 8d 4f 10 	movl   $0xf0104f8d,0xc(%esp)
f0101710:	f0 
f0101711:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101718:	f0 
f0101719:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101720:	00 
f0101721:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101728:	e8 67 e9 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010172d:	39 fe                	cmp    %edi,%esi
f010172f:	75 24                	jne    f0101755 <mem_init+0x421>
f0101731:	c7 44 24 0c a3 4f 10 	movl   $0xf0104fa3,0xc(%esp)
f0101738:	f0 
f0101739:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101740:	f0 
f0101741:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101748:	00 
f0101749:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101750:	e8 3f e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101755:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101758:	74 05                	je     f010175f <mem_init+0x42b>
f010175a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010175d:	75 24                	jne    f0101783 <mem_init+0x44f>
f010175f:	c7 44 24 0c c0 48 10 	movl   $0xf01048c0,0xc(%esp)
f0101766:	f0 
f0101767:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010176e:	f0 
f010176f:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0101776:	00 
f0101777:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010177e:	e8 11 e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101783:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010178a:	e8 41 f8 ff ff       	call   f0100fd0 <page_alloc>
f010178f:	85 c0                	test   %eax,%eax
f0101791:	74 24                	je     f01017b7 <mem_init+0x483>
f0101793:	c7 44 24 0c 0c 50 10 	movl   $0xf010500c,0xc(%esp)
f010179a:	f0 
f010179b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01017a2:	f0 
f01017a3:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f01017aa:	00 
f01017ab:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01017b2:	e8 dd e8 ff ff       	call   f0100094 <_panic>
f01017b7:	89 f0                	mov    %esi,%eax
f01017b9:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f01017bf:	c1 f8 03             	sar    $0x3,%eax
f01017c2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017c5:	89 c2                	mov    %eax,%edx
f01017c7:	c1 ea 0c             	shr    $0xc,%edx
f01017ca:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f01017d0:	72 20                	jb     f01017f2 <mem_init+0x4be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017d6:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f01017dd:	f0 
f01017de:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01017e5:	00 
f01017e6:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f01017ed:	e8 a2 e8 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017f9:	00 
f01017fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101801:	00 
	return (void *)(pa + KERNBASE);
f0101802:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101807:	89 04 24             	mov    %eax,(%esp)
f010180a:	e8 52 24 00 00       	call   f0103c61 <memset>
	page_free(pp0);
f010180f:	89 34 24             	mov    %esi,(%esp)
f0101812:	e8 37 f8 ff ff       	call   f010104e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101817:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010181e:	e8 ad f7 ff ff       	call   f0100fd0 <page_alloc>
f0101823:	85 c0                	test   %eax,%eax
f0101825:	75 24                	jne    f010184b <mem_init+0x517>
f0101827:	c7 44 24 0c 1b 50 10 	movl   $0xf010501b,0xc(%esp)
f010182e:	f0 
f010182f:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101836:	f0 
f0101837:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f010183e:	00 
f010183f:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101846:	e8 49 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010184b:	39 c6                	cmp    %eax,%esi
f010184d:	74 24                	je     f0101873 <mem_init+0x53f>
f010184f:	c7 44 24 0c 39 50 10 	movl   $0xf0105039,0xc(%esp)
f0101856:	f0 
f0101857:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010185e:	f0 
f010185f:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101866:	00 
f0101867:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010186e:	e8 21 e8 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101873:	89 f2                	mov    %esi,%edx
f0101875:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f010187b:	c1 fa 03             	sar    $0x3,%edx
f010187e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101881:	89 d0                	mov    %edx,%eax
f0101883:	c1 e8 0c             	shr    $0xc,%eax
f0101886:	3b 05 84 89 11 f0    	cmp    0xf0118984,%eax
f010188c:	72 20                	jb     f01018ae <mem_init+0x57a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010188e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101892:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0101899:	f0 
f010189a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018a1:	00 
f01018a2:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f01018a9:	e8 e6 e7 ff ff       	call   f0100094 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018ae:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01018b5:	75 11                	jne    f01018c8 <mem_init+0x594>
f01018b7:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01018bd:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018c3:	80 38 00             	cmpb   $0x0,(%eax)
f01018c6:	74 24                	je     f01018ec <mem_init+0x5b8>
f01018c8:	c7 44 24 0c 49 50 10 	movl   $0xf0105049,0xc(%esp)
f01018cf:	f0 
f01018d0:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01018d7:	f0 
f01018d8:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f01018df:	00 
f01018e0:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01018e7:	e8 a8 e7 ff ff       	call   f0100094 <_panic>
f01018ec:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018ef:	39 d0                	cmp    %edx,%eax
f01018f1:	75 d0                	jne    f01018c3 <mem_init+0x58f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018f3:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01018f6:	89 15 60 85 11 f0    	mov    %edx,0xf0118560

	// free the pages we took
	page_free(pp0);
f01018fc:	89 34 24             	mov    %esi,(%esp)
f01018ff:	e8 4a f7 ff ff       	call   f010104e <page_free>
	page_free(pp1);
f0101904:	89 3c 24             	mov    %edi,(%esp)
f0101907:	e8 42 f7 ff ff       	call   f010104e <page_free>
	page_free(pp2);
f010190c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010190f:	89 04 24             	mov    %eax,(%esp)
f0101912:	e8 37 f7 ff ff       	call   f010104e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101917:	a1 60 85 11 f0       	mov    0xf0118560,%eax
f010191c:	85 c0                	test   %eax,%eax
f010191e:	74 09                	je     f0101929 <mem_init+0x5f5>
		--nfree;
f0101920:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101923:	8b 00                	mov    (%eax),%eax
f0101925:	85 c0                	test   %eax,%eax
f0101927:	75 f7                	jne    f0101920 <mem_init+0x5ec>
		--nfree;
	assert(nfree == 0);
f0101929:	85 db                	test   %ebx,%ebx
f010192b:	74 24                	je     f0101951 <mem_init+0x61d>
f010192d:	c7 44 24 0c 53 50 10 	movl   $0xf0105053,0xc(%esp)
f0101934:	f0 
f0101935:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010193c:	f0 
f010193d:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101944:	00 
f0101945:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010194c:	e8 43 e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101951:	c7 04 24 e0 48 10 f0 	movl   $0xf01048e0,(%esp)
f0101958:	e8 15 16 00 00       	call   f0102f72 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010195d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101964:	e8 67 f6 ff ff       	call   f0100fd0 <page_alloc>
f0101969:	89 c6                	mov    %eax,%esi
f010196b:	85 c0                	test   %eax,%eax
f010196d:	75 24                	jne    f0101993 <mem_init+0x65f>
f010196f:	c7 44 24 0c 61 4f 10 	movl   $0xf0104f61,0xc(%esp)
f0101976:	f0 
f0101977:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010197e:	f0 
f010197f:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101986:	00 
f0101987:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010198e:	e8 01 e7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010199a:	e8 31 f6 ff ff       	call   f0100fd0 <page_alloc>
f010199f:	89 c7                	mov    %eax,%edi
f01019a1:	85 c0                	test   %eax,%eax
f01019a3:	75 24                	jne    f01019c9 <mem_init+0x695>
f01019a5:	c7 44 24 0c 77 4f 10 	movl   $0xf0104f77,0xc(%esp)
f01019ac:	f0 
f01019ad:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f01019bc:	00 
f01019bd:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01019c4:	e8 cb e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019d0:	e8 fb f5 ff ff       	call   f0100fd0 <page_alloc>
f01019d5:	89 c3                	mov    %eax,%ebx
f01019d7:	85 c0                	test   %eax,%eax
f01019d9:	75 24                	jne    f01019ff <mem_init+0x6cb>
f01019db:	c7 44 24 0c 8d 4f 10 	movl   $0xf0104f8d,0xc(%esp)
f01019e2:	f0 
f01019e3:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01019ea:	f0 
f01019eb:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f01019f2:	00 
f01019f3:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01019fa:	e8 95 e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019ff:	39 fe                	cmp    %edi,%esi
f0101a01:	75 24                	jne    f0101a27 <mem_init+0x6f3>
f0101a03:	c7 44 24 0c a3 4f 10 	movl   $0xf0104fa3,0xc(%esp)
f0101a0a:	f0 
f0101a0b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101a1a:	00 
f0101a1b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101a22:	e8 6d e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a27:	39 c7                	cmp    %eax,%edi
f0101a29:	74 04                	je     f0101a2f <mem_init+0x6fb>
f0101a2b:	39 c6                	cmp    %eax,%esi
f0101a2d:	75 24                	jne    f0101a53 <mem_init+0x71f>
f0101a2f:	c7 44 24 0c c0 48 10 	movl   $0xf01048c0,0xc(%esp)
f0101a36:	f0 
f0101a37:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101a46:	00 
f0101a47:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101a4e:	e8 41 e6 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a53:	8b 15 60 85 11 f0    	mov    0xf0118560,%edx
f0101a59:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101a5c:	c7 05 60 85 11 f0 00 	movl   $0x0,0xf0118560
f0101a63:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a6d:	e8 5e f5 ff ff       	call   f0100fd0 <page_alloc>
f0101a72:	85 c0                	test   %eax,%eax
f0101a74:	74 24                	je     f0101a9a <mem_init+0x766>
f0101a76:	c7 44 24 0c 0c 50 10 	movl   $0xf010500c,0xc(%esp)
f0101a7d:	f0 
f0101a7e:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101a85:	f0 
f0101a86:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101a8d:	00 
f0101a8e:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101a95:	e8 fa e5 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a9a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101aa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101aa8:	00 
f0101aa9:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101aae:	89 04 24             	mov    %eax,(%esp)
f0101ab1:	e8 01 f7 ff ff       	call   f01011b7 <page_lookup>
f0101ab6:	85 c0                	test   %eax,%eax
f0101ab8:	74 24                	je     f0101ade <mem_init+0x7aa>
f0101aba:	c7 44 24 0c 00 49 10 	movl   $0xf0104900,0xc(%esp)
f0101ac1:	f0 
f0101ac2:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101ac9:	f0 
f0101aca:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0101ad1:	00 
f0101ad2:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101ad9:	e8 b6 e5 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ade:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ae5:	00 
f0101ae6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101aed:	00 
f0101aee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101af2:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101af7:	89 04 24             	mov    %eax,(%esp)
f0101afa:	e8 8b f7 ff ff       	call   f010128a <page_insert>
f0101aff:	85 c0                	test   %eax,%eax
f0101b01:	78 24                	js     f0101b27 <mem_init+0x7f3>
f0101b03:	c7 44 24 0c 38 49 10 	movl   $0xf0104938,0xc(%esp)
f0101b0a:	f0 
f0101b0b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101b12:	f0 
f0101b13:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0101b1a:	00 
f0101b1b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101b22:	e8 6d e5 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b27:	89 34 24             	mov    %esi,(%esp)
f0101b2a:	e8 1f f5 ff ff       	call   f010104e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b2f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b36:	00 
f0101b37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b3e:	00 
f0101b3f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b43:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101b48:	89 04 24             	mov    %eax,(%esp)
f0101b4b:	e8 3a f7 ff ff       	call   f010128a <page_insert>
f0101b50:	85 c0                	test   %eax,%eax
f0101b52:	74 24                	je     f0101b78 <mem_init+0x844>
f0101b54:	c7 44 24 0c 68 49 10 	movl   $0xf0104968,0xc(%esp)
f0101b5b:	f0 
f0101b5c:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101b63:	f0 
f0101b64:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101b6b:	00 
f0101b6c:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101b73:	e8 1c e5 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b78:	8b 0d 88 89 11 f0    	mov    0xf0118988,%ecx
f0101b7e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b81:	a1 8c 89 11 f0       	mov    0xf011898c,%eax
f0101b86:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b89:	8b 11                	mov    (%ecx),%edx
f0101b8b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b91:	89 f0                	mov    %esi,%eax
f0101b93:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101b96:	c1 f8 03             	sar    $0x3,%eax
f0101b99:	c1 e0 0c             	shl    $0xc,%eax
f0101b9c:	39 c2                	cmp    %eax,%edx
f0101b9e:	74 24                	je     f0101bc4 <mem_init+0x890>
f0101ba0:	c7 44 24 0c 98 49 10 	movl   $0xf0104998,0xc(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101baf:	f0 
f0101bb0:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101bb7:	00 
f0101bb8:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101bbf:	e8 d0 e4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bcc:	e8 5b ee ff ff       	call   f0100a2c <check_va2pa>
f0101bd1:	89 fa                	mov    %edi,%edx
f0101bd3:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101bd6:	c1 fa 03             	sar    $0x3,%edx
f0101bd9:	c1 e2 0c             	shl    $0xc,%edx
f0101bdc:	39 d0                	cmp    %edx,%eax
f0101bde:	74 24                	je     f0101c04 <mem_init+0x8d0>
f0101be0:	c7 44 24 0c c0 49 10 	movl   $0xf01049c0,0xc(%esp)
f0101be7:	f0 
f0101be8:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101bef:	f0 
f0101bf0:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101bf7:	00 
f0101bf8:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101bff:	e8 90 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101c04:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c09:	74 24                	je     f0101c2f <mem_init+0x8fb>
f0101c0b:	c7 44 24 0c 5e 50 10 	movl   $0xf010505e,0xc(%esp)
f0101c12:	f0 
f0101c13:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101c1a:	f0 
f0101c1b:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101c22:	00 
f0101c23:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101c2a:	e8 65 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101c2f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c34:	74 24                	je     f0101c5a <mem_init+0x926>
f0101c36:	c7 44 24 0c 6f 50 10 	movl   $0xf010506f,0xc(%esp)
f0101c3d:	f0 
f0101c3e:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101c45:	f0 
f0101c46:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101c4d:	00 
f0101c4e:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101c55:	e8 3a e4 ff ff       	call   f0100094 <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c5a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c61:	00 
f0101c62:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c69:	00 
f0101c6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c6e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c71:	89 14 24             	mov    %edx,(%esp)
f0101c74:	e8 11 f6 ff ff       	call   f010128a <page_insert>
f0101c79:	85 c0                	test   %eax,%eax
f0101c7b:	74 24                	je     f0101ca1 <mem_init+0x96d>
f0101c7d:	c7 44 24 0c f0 49 10 	movl   $0xf01049f0,0xc(%esp)
f0101c84:	f0 
f0101c85:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101c8c:	f0 
f0101c8d:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101c94:	00 
f0101c95:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101c9c:	e8 f3 e3 ff ff       	call   f0100094 <_panic>
cprintf("%x %x %x\n",kern_pgdir, PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
f0101ca1:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101ca6:	89 f2                	mov    %esi,%edx
f0101ca8:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0101cae:	c1 fa 03             	sar    $0x3,%edx
f0101cb1:	c1 e2 0c             	shl    $0xc,%edx
f0101cb4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101cb8:	8b 10                	mov    (%eax),%edx
f0101cba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101cc0:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101cc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101cc8:	c7 04 24 80 50 10 f0 	movl   $0xf0105080,(%esp)
f0101ccf:	e8 9e 12 00 00       	call   f0102f72 <cprintf>
f0101cd4:	89 d8                	mov    %ebx,%eax
f0101cd6:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0101cdc:	c1 f8 03             	sar    $0x3,%eax
f0101cdf:	c1 e0 0c             	shl    $0xc,%eax

cprintf("%x %x\n", PTE_ADDR(*((pte_t *)(PTE_ADDR(kern_pgdir[0]) + PTX(PGSIZE)))), page2pa(pp2));
f0101ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ce6:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101ceb:	8b 00                	mov    (%eax),%eax
f0101ced:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cf2:	8b 40 01             	mov    0x1(%eax),%eax
f0101cf5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101cfe:	c7 04 24 83 50 10 f0 	movl   $0xf0105083,(%esp)
f0101d05:	e8 68 12 00 00       	call   f0102f72 <cprintf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0f:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101d14:	e8 13 ed ff ff       	call   f0100a2c <check_va2pa>
f0101d19:	89 da                	mov    %ebx,%edx
f0101d1b:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0101d21:	c1 fa 03             	sar    $0x3,%edx
f0101d24:	c1 e2 0c             	shl    $0xc,%edx
f0101d27:	39 d0                	cmp    %edx,%eax
f0101d29:	74 24                	je     f0101d4f <mem_init+0xa1b>
f0101d2b:	c7 44 24 0c 2c 4a 10 	movl   $0xf0104a2c,0xc(%esp)
f0101d32:	f0 
f0101d33:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101d3a:	f0 
f0101d3b:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101d42:	00 
f0101d43:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101d4a:	e8 45 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d4f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d54:	74 24                	je     f0101d7a <mem_init+0xa46>
f0101d56:	c7 44 24 0c 8a 50 10 	movl   $0xf010508a,0xc(%esp)
f0101d5d:	f0 
f0101d5e:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101d6d:	00 
f0101d6e:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101d75:	e8 1a e3 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d81:	e8 4a f2 ff ff       	call   f0100fd0 <page_alloc>
f0101d86:	85 c0                	test   %eax,%eax
f0101d88:	74 24                	je     f0101dae <mem_init+0xa7a>
f0101d8a:	c7 44 24 0c 0c 50 10 	movl   $0xf010500c,0xc(%esp)
f0101d91:	f0 
f0101d92:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101d99:	f0 
f0101d9a:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101da1:	00 
f0101da2:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101da9:	e8 e6 e2 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dae:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101db5:	00 
f0101db6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dbd:	00 
f0101dbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dc2:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101dc7:	89 04 24             	mov    %eax,(%esp)
f0101dca:	e8 bb f4 ff ff       	call   f010128a <page_insert>
f0101dcf:	85 c0                	test   %eax,%eax
f0101dd1:	74 24                	je     f0101df7 <mem_init+0xac3>
f0101dd3:	c7 44 24 0c f0 49 10 	movl   $0xf01049f0,0xc(%esp)
f0101dda:	f0 
f0101ddb:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101de2:	f0 
f0101de3:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0101dea:	00 
f0101deb:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101df2:	e8 9d e2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101df7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dfc:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101e01:	e8 26 ec ff ff       	call   f0100a2c <check_va2pa>
f0101e06:	89 da                	mov    %ebx,%edx
f0101e08:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0101e0e:	c1 fa 03             	sar    $0x3,%edx
f0101e11:	c1 e2 0c             	shl    $0xc,%edx
f0101e14:	39 d0                	cmp    %edx,%eax
f0101e16:	74 24                	je     f0101e3c <mem_init+0xb08>
f0101e18:	c7 44 24 0c 2c 4a 10 	movl   $0xf0104a2c,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101e37:	e8 58 e2 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101e3c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e41:	74 24                	je     f0101e67 <mem_init+0xb33>
f0101e43:	c7 44 24 0c 8a 50 10 	movl   $0xf010508a,0xc(%esp)
f0101e4a:	f0 
f0101e4b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101e52:	f0 
f0101e53:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101e5a:	00 
f0101e5b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101e62:	e8 2d e2 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e6e:	e8 5d f1 ff ff       	call   f0100fd0 <page_alloc>
f0101e73:	85 c0                	test   %eax,%eax
f0101e75:	74 24                	je     f0101e9b <mem_init+0xb67>
f0101e77:	c7 44 24 0c 0c 50 10 	movl   $0xf010500c,0xc(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101e86:	f0 
f0101e87:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101e8e:	00 
f0101e8f:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101e96:	e8 f9 e1 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e9b:	8b 15 88 89 11 f0    	mov    0xf0118988,%edx
f0101ea1:	8b 02                	mov    (%edx),%eax
f0101ea3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ea8:	89 c1                	mov    %eax,%ecx
f0101eaa:	c1 e9 0c             	shr    $0xc,%ecx
f0101ead:	3b 0d 84 89 11 f0    	cmp    0xf0118984,%ecx
f0101eb3:	72 20                	jb     f0101ed5 <mem_init+0xba1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101eb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101eb9:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0101ec0:	f0 
f0101ec1:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101ec8:	00 
f0101ec9:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101ed0:	e8 bf e1 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101ed5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101edd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ee4:	00 
f0101ee5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101eec:	00 
f0101eed:	89 14 24             	mov    %edx,(%esp)
f0101ef0:	e8 b4 f1 ff ff       	call   f01010a9 <pgdir_walk>
f0101ef5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ef8:	83 c2 04             	add    $0x4,%edx
f0101efb:	39 d0                	cmp    %edx,%eax
f0101efd:	74 24                	je     f0101f23 <mem_init+0xbef>
f0101eff:	c7 44 24 0c 5c 4a 10 	movl   $0xf0104a5c,0xc(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101f0e:	f0 
f0101f0f:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101f16:	00 
f0101f17:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101f1e:	e8 71 e1 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101f2a:	00 
f0101f2b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f32:	00 
f0101f33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f37:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0101f3c:	89 04 24             	mov    %eax,(%esp)
f0101f3f:	e8 46 f3 ff ff       	call   f010128a <page_insert>
f0101f44:	85 c0                	test   %eax,%eax
f0101f46:	74 24                	je     f0101f6c <mem_init+0xc38>
f0101f48:	c7 44 24 0c 9c 4a 10 	movl   $0xf0104a9c,0xc(%esp)
f0101f4f:	f0 
f0101f50:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101f57:	f0 
f0101f58:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101f5f:	00 
f0101f60:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101f67:	e8 28 e1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f6c:	8b 0d 88 89 11 f0    	mov    0xf0118988,%ecx
f0101f72:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f75:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f7a:	89 c8                	mov    %ecx,%eax
f0101f7c:	e8 ab ea ff ff       	call   f0100a2c <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f81:	89 da                	mov    %ebx,%edx
f0101f83:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0101f89:	c1 fa 03             	sar    $0x3,%edx
f0101f8c:	c1 e2 0c             	shl    $0xc,%edx
f0101f8f:	39 d0                	cmp    %edx,%eax
f0101f91:	74 24                	je     f0101fb7 <mem_init+0xc83>
f0101f93:	c7 44 24 0c 2c 4a 10 	movl   $0xf0104a2c,0xc(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101fa2:	f0 
f0101fa3:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101faa:	00 
f0101fab:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101fb2:	e8 dd e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101fb7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fbc:	74 24                	je     f0101fe2 <mem_init+0xcae>
f0101fbe:	c7 44 24 0c 8a 50 10 	movl   $0xf010508a,0xc(%esp)
f0101fc5:	f0 
f0101fc6:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0101fcd:	f0 
f0101fce:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101fd5:	00 
f0101fd6:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0101fdd:	e8 b2 e0 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fe2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fe9:	00 
f0101fea:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ff1:	00 
f0101ff2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff5:	89 04 24             	mov    %eax,(%esp)
f0101ff8:	e8 ac f0 ff ff       	call   f01010a9 <pgdir_walk>
f0101ffd:	f6 00 04             	testb  $0x4,(%eax)
f0102000:	75 24                	jne    f0102026 <mem_init+0xcf2>
f0102002:	c7 44 24 0c dc 4a 10 	movl   $0xf0104adc,0xc(%esp)
f0102009:	f0 
f010200a:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102011:	f0 
f0102012:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102019:	00 
f010201a:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102021:	e8 6e e0 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102026:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f010202b:	f6 00 04             	testb  $0x4,(%eax)
f010202e:	75 24                	jne    f0102054 <mem_init+0xd20>
f0102030:	c7 44 24 0c 9b 50 10 	movl   $0xf010509b,0xc(%esp)
f0102037:	f0 
f0102038:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010203f:	f0 
f0102040:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102047:	00 
f0102048:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010204f:	e8 40 e0 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102054:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010205b:	00 
f010205c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102063:	00 
f0102064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102068:	89 04 24             	mov    %eax,(%esp)
f010206b:	e8 1a f2 ff ff       	call   f010128a <page_insert>
f0102070:	85 c0                	test   %eax,%eax
f0102072:	74 24                	je     f0102098 <mem_init+0xd64>
f0102074:	c7 44 24 0c f0 49 10 	movl   $0xf01049f0,0xc(%esp)
f010207b:	f0 
f010207c:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102083:	f0 
f0102084:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f010208b:	00 
f010208c:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102093:	e8 fc df ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102098:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010209f:	00 
f01020a0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020a7:	00 
f01020a8:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f01020ad:	89 04 24             	mov    %eax,(%esp)
f01020b0:	e8 f4 ef ff ff       	call   f01010a9 <pgdir_walk>
f01020b5:	f6 00 02             	testb  $0x2,(%eax)
f01020b8:	75 24                	jne    f01020de <mem_init+0xdaa>
f01020ba:	c7 44 24 0c 10 4b 10 	movl   $0xf0104b10,0xc(%esp)
f01020c1:	f0 
f01020c2:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01020c9:	f0 
f01020ca:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f01020d1:	00 
f01020d2:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01020d9:	e8 b6 df ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020e5:	00 
f01020e6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020ed:	00 
f01020ee:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f01020f3:	89 04 24             	mov    %eax,(%esp)
f01020f6:	e8 ae ef ff ff       	call   f01010a9 <pgdir_walk>
f01020fb:	f6 00 04             	testb  $0x4,(%eax)
f01020fe:	74 24                	je     f0102124 <mem_init+0xdf0>
f0102100:	c7 44 24 0c 44 4b 10 	movl   $0xf0104b44,0xc(%esp)
f0102107:	f0 
f0102108:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010210f:	f0 
f0102110:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102117:	00 
f0102118:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010211f:	e8 70 df ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102124:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010212b:	00 
f010212c:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102133:	00 
f0102134:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102138:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f010213d:	89 04 24             	mov    %eax,(%esp)
f0102140:	e8 45 f1 ff ff       	call   f010128a <page_insert>
f0102145:	85 c0                	test   %eax,%eax
f0102147:	78 24                	js     f010216d <mem_init+0xe39>
f0102149:	c7 44 24 0c 7c 4b 10 	movl   $0xf0104b7c,0xc(%esp)
f0102150:	f0 
f0102151:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102158:	f0 
f0102159:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0102160:	00 
f0102161:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102168:	e8 27 df ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010216d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102174:	00 
f0102175:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010217c:	00 
f010217d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102181:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102186:	89 04 24             	mov    %eax,(%esp)
f0102189:	e8 fc f0 ff ff       	call   f010128a <page_insert>
f010218e:	85 c0                	test   %eax,%eax
f0102190:	74 24                	je     f01021b6 <mem_init+0xe82>
f0102192:	c7 44 24 0c b4 4b 10 	movl   $0xf0104bb4,0xc(%esp)
f0102199:	f0 
f010219a:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01021a1:	f0 
f01021a2:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01021a9:	00 
f01021aa:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01021b1:	e8 de de ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021bd:	00 
f01021be:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021c5:	00 
f01021c6:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f01021cb:	89 04 24             	mov    %eax,(%esp)
f01021ce:	e8 d6 ee ff ff       	call   f01010a9 <pgdir_walk>
f01021d3:	f6 00 04             	testb  $0x4,(%eax)
f01021d6:	74 24                	je     f01021fc <mem_init+0xec8>
f01021d8:	c7 44 24 0c 44 4b 10 	movl   $0xf0104b44,0xc(%esp)
f01021df:	f0 
f01021e0:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01021e7:	f0 
f01021e8:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01021ef:	00 
f01021f0:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01021f7:	e8 98 de ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021fc:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102201:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102204:	ba 00 00 00 00       	mov    $0x0,%edx
f0102209:	e8 1e e8 ff ff       	call   f0100a2c <check_va2pa>
f010220e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102211:	89 f8                	mov    %edi,%eax
f0102213:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0102219:	c1 f8 03             	sar    $0x3,%eax
f010221c:	c1 e0 0c             	shl    $0xc,%eax
f010221f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102222:	74 24                	je     f0102248 <mem_init+0xf14>
f0102224:	c7 44 24 0c f0 4b 10 	movl   $0xf0104bf0,0xc(%esp)
f010222b:	f0 
f010222c:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102233:	f0 
f0102234:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f010223b:	00 
f010223c:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102243:	e8 4c de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102248:	ba 00 10 00 00       	mov    $0x1000,%edx
f010224d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102250:	e8 d7 e7 ff ff       	call   f0100a2c <check_va2pa>
f0102255:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102258:	74 24                	je     f010227e <mem_init+0xf4a>
f010225a:	c7 44 24 0c 1c 4c 10 	movl   $0xf0104c1c,0xc(%esp)
f0102261:	f0 
f0102262:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102269:	f0 
f010226a:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102271:	00 
f0102272:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102279:	e8 16 de ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010227e:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102283:	74 24                	je     f01022a9 <mem_init+0xf75>
f0102285:	c7 44 24 0c b1 50 10 	movl   $0xf01050b1,0xc(%esp)
f010228c:	f0 
f010228d:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102294:	f0 
f0102295:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f010229c:	00 
f010229d:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01022a4:	e8 eb dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01022a9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022ae:	74 24                	je     f01022d4 <mem_init+0xfa0>
f01022b0:	c7 44 24 0c c2 50 10 	movl   $0xf01050c2,0xc(%esp)
f01022b7:	f0 
f01022b8:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01022bf:	f0 
f01022c0:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f01022c7:	00 
f01022c8:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01022cf:	e8 c0 dd ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022db:	e8 f0 ec ff ff       	call   f0100fd0 <page_alloc>
f01022e0:	85 c0                	test   %eax,%eax
f01022e2:	74 04                	je     f01022e8 <mem_init+0xfb4>
f01022e4:	39 c3                	cmp    %eax,%ebx
f01022e6:	74 24                	je     f010230c <mem_init+0xfd8>
f01022e8:	c7 44 24 0c 4c 4c 10 	movl   $0xf0104c4c,0xc(%esp)
f01022ef:	f0 
f01022f0:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01022f7:	f0 
f01022f8:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01022ff:	00 
f0102300:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102307:	e8 88 dd ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010230c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102313:	00 
f0102314:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102319:	89 04 24             	mov    %eax,(%esp)
f010231c:	e8 19 ef ff ff       	call   f010123a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102321:	8b 15 88 89 11 f0    	mov    0xf0118988,%edx
f0102327:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010232a:	ba 00 00 00 00       	mov    $0x0,%edx
f010232f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102332:	e8 f5 e6 ff ff       	call   f0100a2c <check_va2pa>
f0102337:	83 f8 ff             	cmp    $0xffffffff,%eax
f010233a:	74 24                	je     f0102360 <mem_init+0x102c>
f010233c:	c7 44 24 0c 70 4c 10 	movl   $0xf0104c70,0xc(%esp)
f0102343:	f0 
f0102344:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010234b:	f0 
f010234c:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102353:	00 
f0102354:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010235b:	e8 34 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102360:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102365:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102368:	e8 bf e6 ff ff       	call   f0100a2c <check_va2pa>
f010236d:	89 fa                	mov    %edi,%edx
f010236f:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0102375:	c1 fa 03             	sar    $0x3,%edx
f0102378:	c1 e2 0c             	shl    $0xc,%edx
f010237b:	39 d0                	cmp    %edx,%eax
f010237d:	74 24                	je     f01023a3 <mem_init+0x106f>
f010237f:	c7 44 24 0c 1c 4c 10 	movl   $0xf0104c1c,0xc(%esp)
f0102386:	f0 
f0102387:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010238e:	f0 
f010238f:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102396:	00 
f0102397:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010239e:	e8 f1 dc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01023a3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023a8:	74 24                	je     f01023ce <mem_init+0x109a>
f01023aa:	c7 44 24 0c 5e 50 10 	movl   $0xf010505e,0xc(%esp)
f01023b1:	f0 
f01023b2:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01023b9:	f0 
f01023ba:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f01023c1:	00 
f01023c2:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01023c9:	e8 c6 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01023ce:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023d3:	74 24                	je     f01023f9 <mem_init+0x10c5>
f01023d5:	c7 44 24 0c c2 50 10 	movl   $0xf01050c2,0xc(%esp)
f01023dc:	f0 
f01023dd:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01023e4:	f0 
f01023e5:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f01023ec:	00 
f01023ed:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01023f4:	e8 9b dc ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023f9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102400:	00 
f0102401:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102404:	89 0c 24             	mov    %ecx,(%esp)
f0102407:	e8 2e ee ff ff       	call   f010123a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010240c:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102411:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102414:	ba 00 00 00 00       	mov    $0x0,%edx
f0102419:	e8 0e e6 ff ff       	call   f0100a2c <check_va2pa>
f010241e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102421:	74 24                	je     f0102447 <mem_init+0x1113>
f0102423:	c7 44 24 0c 70 4c 10 	movl   $0xf0104c70,0xc(%esp)
f010242a:	f0 
f010242b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102432:	f0 
f0102433:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f010243a:	00 
f010243b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102442:	e8 4d dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102447:	ba 00 10 00 00       	mov    $0x1000,%edx
f010244c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010244f:	e8 d8 e5 ff ff       	call   f0100a2c <check_va2pa>
f0102454:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102457:	74 24                	je     f010247d <mem_init+0x1149>
f0102459:	c7 44 24 0c 94 4c 10 	movl   $0xf0104c94,0xc(%esp)
f0102460:	f0 
f0102461:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102468:	f0 
f0102469:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0102470:	00 
f0102471:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102478:	e8 17 dc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f010247d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102482:	74 24                	je     f01024a8 <mem_init+0x1174>
f0102484:	c7 44 24 0c d3 50 10 	movl   $0xf01050d3,0xc(%esp)
f010248b:	f0 
f010248c:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102493:	f0 
f0102494:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f010249b:	00 
f010249c:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01024a3:	e8 ec db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01024a8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024ad:	74 24                	je     f01024d3 <mem_init+0x119f>
f01024af:	c7 44 24 0c c2 50 10 	movl   $0xf01050c2,0xc(%esp)
f01024b6:	f0 
f01024b7:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01024be:	f0 
f01024bf:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f01024c6:	00 
f01024c7:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01024ce:	e8 c1 db ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01024d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024da:	e8 f1 ea ff ff       	call   f0100fd0 <page_alloc>
f01024df:	85 c0                	test   %eax,%eax
f01024e1:	74 04                	je     f01024e7 <mem_init+0x11b3>
f01024e3:	39 c7                	cmp    %eax,%edi
f01024e5:	74 24                	je     f010250b <mem_init+0x11d7>
f01024e7:	c7 44 24 0c bc 4c 10 	movl   $0xf0104cbc,0xc(%esp)
f01024ee:	f0 
f01024ef:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01024f6:	f0 
f01024f7:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f01024fe:	00 
f01024ff:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102506:	e8 89 db ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010250b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102512:	e8 b9 ea ff ff       	call   f0100fd0 <page_alloc>
f0102517:	85 c0                	test   %eax,%eax
f0102519:	74 24                	je     f010253f <mem_init+0x120b>
f010251b:	c7 44 24 0c 0c 50 10 	movl   $0xf010500c,0xc(%esp)
f0102522:	f0 
f0102523:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010252a:	f0 
f010252b:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102532:	00 
f0102533:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010253a:	e8 55 db ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010253f:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102544:	8b 08                	mov    (%eax),%ecx
f0102546:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010254c:	89 f2                	mov    %esi,%edx
f010254e:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0102554:	c1 fa 03             	sar    $0x3,%edx
f0102557:	c1 e2 0c             	shl    $0xc,%edx
f010255a:	39 d1                	cmp    %edx,%ecx
f010255c:	74 24                	je     f0102582 <mem_init+0x124e>
f010255e:	c7 44 24 0c 98 49 10 	movl   $0xf0104998,0xc(%esp)
f0102565:	f0 
f0102566:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010256d:	f0 
f010256e:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102575:	00 
f0102576:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010257d:	e8 12 db ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102582:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102588:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010258d:	74 24                	je     f01025b3 <mem_init+0x127f>
f010258f:	c7 44 24 0c 6f 50 10 	movl   $0xf010506f,0xc(%esp)
f0102596:	f0 
f0102597:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010259e:	f0 
f010259f:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f01025a6:	00 
f01025a7:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01025ae:	e8 e1 da ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01025b3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025b9:	89 34 24             	mov    %esi,(%esp)
f01025bc:	e8 8d ea ff ff       	call   f010104e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025c8:	00 
f01025c9:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01025d0:	00 
f01025d1:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f01025d6:	89 04 24             	mov    %eax,(%esp)
f01025d9:	e8 cb ea ff ff       	call   f01010a9 <pgdir_walk>
f01025de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01025e1:	8b 0d 88 89 11 f0    	mov    0xf0118988,%ecx
f01025e7:	8b 51 04             	mov    0x4(%ecx),%edx
f01025ea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025f3:	8b 15 84 89 11 f0    	mov    0xf0118984,%edx
f01025f9:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01025fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01025ff:	c1 ea 0c             	shr    $0xc,%edx
f0102602:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102605:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102608:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010260b:	72 23                	jb     f0102630 <mem_init+0x12fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010260d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102610:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102614:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f010261b:	f0 
f010261c:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102623:	00 
f0102624:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010262b:	e8 64 da ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102630:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102633:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102639:	39 d0                	cmp    %edx,%eax
f010263b:	74 24                	je     f0102661 <mem_init+0x132d>
f010263d:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f0102644:	f0 
f0102645:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f010264c:	f0 
f010264d:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0102654:	00 
f0102655:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f010265c:	e8 33 da ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102661:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102668:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010266e:	89 f0                	mov    %esi,%eax
f0102670:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0102676:	c1 f8 03             	sar    $0x3,%eax
f0102679:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010267c:	89 c1                	mov    %eax,%ecx
f010267e:	c1 e9 0c             	shr    $0xc,%ecx
f0102681:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102684:	77 20                	ja     f01026a6 <mem_init+0x1372>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102686:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010268a:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0102691:	f0 
f0102692:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102699:	00 
f010269a:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f01026a1:	e8 ee d9 ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026a6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026ad:	00 
f01026ae:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01026b5:	00 
	return (void *)(pa + KERNBASE);
f01026b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026bb:	89 04 24             	mov    %eax,(%esp)
f01026be:	e8 9e 15 00 00       	call   f0103c61 <memset>
	page_free(pp0);
f01026c3:	89 34 24             	mov    %esi,(%esp)
f01026c6:	e8 83 e9 ff ff       	call   f010104e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026cb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026d2:	00 
f01026d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01026da:	00 
f01026db:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f01026e0:	89 04 24             	mov    %eax,(%esp)
f01026e3:	e8 c1 e9 ff ff       	call   f01010a9 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026e8:	89 f2                	mov    %esi,%edx
f01026ea:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f01026f0:	c1 fa 03             	sar    $0x3,%edx
f01026f3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026f6:	89 d0                	mov    %edx,%eax
f01026f8:	c1 e8 0c             	shr    $0xc,%eax
f01026fb:	3b 05 84 89 11 f0    	cmp    0xf0118984,%eax
f0102701:	72 20                	jb     f0102723 <mem_init+0x13ef>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102703:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102707:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f010270e:	f0 
f010270f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102716:	00 
f0102717:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f010271e:	e8 71 d9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102723:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010272c:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102733:	75 11                	jne    f0102746 <mem_init+0x1412>
f0102735:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010273b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102741:	f6 00 01             	testb  $0x1,(%eax)
f0102744:	74 24                	je     f010276a <mem_init+0x1436>
f0102746:	c7 44 24 0c fc 50 10 	movl   $0xf01050fc,0xc(%esp)
f010274d:	f0 
f010274e:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102755:	f0 
f0102756:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f010275d:	00 
f010275e:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102765:	e8 2a d9 ff ff       	call   f0100094 <_panic>
f010276a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010276d:	39 d0                	cmp    %edx,%eax
f010276f:	75 d0                	jne    f0102741 <mem_init+0x140d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102771:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102776:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010277c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102782:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102785:	89 0d 60 85 11 f0    	mov    %ecx,0xf0118560

	// free the pages we took
	page_free(pp0);
f010278b:	89 34 24             	mov    %esi,(%esp)
f010278e:	e8 bb e8 ff ff       	call   f010104e <page_free>
	page_free(pp1);
f0102793:	89 3c 24             	mov    %edi,(%esp)
f0102796:	e8 b3 e8 ff ff       	call   f010104e <page_free>
	page_free(pp2);
f010279b:	89 1c 24             	mov    %ebx,(%esp)
f010279e:	e8 ab e8 ff ff       	call   f010104e <page_free>

	cprintf("check_page() succeeded!\n");
f01027a3:	c7 04 24 13 51 10 f0 	movl   $0xf0105113,(%esp)
f01027aa:	e8 c3 07 00 00       	call   f0102f72 <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f01027af:	a1 8c 89 11 f0       	mov    0xf011898c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027b9:	77 20                	ja     f01027db <mem_init+0x14a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027bf:	c7 44 24 08 1c 48 10 	movl   $0xf010481c,0x8(%esp)
f01027c6:	f0 
f01027c7:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f01027ce:	00 
f01027cf:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01027d6:	e8 b9 d8 ff ff       	call   f0100094 <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f01027db:	8b 15 84 89 11 f0    	mov    0xf0118984,%edx
f01027e1:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01027e8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f01027ee:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01027f5:	00 
	return (physaddr_t)kva - KERNBASE;
f01027f6:	05 00 00 00 10       	add    $0x10000000,%eax
f01027fb:	89 04 24             	mov    %eax,(%esp)
f01027fe:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102803:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102808:	e8 3c e9 ff ff       	call   f0101149 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280d:	be 00 e0 10 f0       	mov    $0xf010e000,%esi
f0102812:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102818:	77 20                	ja     f010283a <mem_init+0x1506>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010281e:	c7 44 24 08 1c 48 10 	movl   $0xf010481c,0x8(%esp)
f0102825:	f0 
f0102826:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f010282d:	00 
f010282e:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102835:	e8 5a d8 ff ff       	call   f0100094 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f010283a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102841:	00 
f0102842:	c7 04 24 00 e0 10 00 	movl   $0x10e000,(%esp)
f0102849:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010284e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102853:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102858:	e8 ec e8 ff ff       	call   f0101149 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f010285d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102864:	00 
f0102865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010286c:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102871:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102876:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f010287b:	e8 c9 e8 ff ff       	call   f0101149 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102880:	8b 1d 88 89 11 f0    	mov    0xf0118988,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102886:	8b 35 84 89 11 f0    	mov    0xf0118984,%esi
f010288c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010288f:	8d 3c f5 ff 0f 00 00 	lea    0xfff(,%esi,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102896:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f010289c:	74 79                	je     f0102917 <mem_init+0x15e3>
f010289e:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028a3:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a9:	89 d8                	mov    %ebx,%eax
f01028ab:	e8 7c e1 ff ff       	call   f0100a2c <check_va2pa>
f01028b0:	8b 15 8c 89 11 f0    	mov    0xf011898c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028b6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01028bc:	77 20                	ja     f01028de <mem_init+0x15aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028be:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01028c2:	c7 44 24 08 1c 48 10 	movl   $0xf010481c,0x8(%esp)
f01028c9:	f0 
f01028ca:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01028d1:	00 
f01028d2:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01028d9:	e8 b6 d7 ff ff       	call   f0100094 <_panic>
f01028de:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01028e5:	39 d0                	cmp    %edx,%eax
f01028e7:	74 24                	je     f010290d <mem_init+0x15d9>
f01028e9:	c7 44 24 0c e0 4c 10 	movl   $0xf0104ce0,0xc(%esp)
f01028f0:	f0 
f01028f1:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01028f8:	f0 
f01028f9:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0102900:	00 
f0102901:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102908:	e8 87 d7 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010290d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102913:	39 f7                	cmp    %esi,%edi
f0102915:	77 8c                	ja     f01028a3 <mem_init+0x156f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102917:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010291a:	c1 e7 0c             	shl    $0xc,%edi
f010291d:	85 ff                	test   %edi,%edi
f010291f:	74 44                	je     f0102965 <mem_init+0x1631>
f0102921:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102926:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010292c:	89 d8                	mov    %ebx,%eax
f010292e:	e8 f9 e0 ff ff       	call   f0100a2c <check_va2pa>
f0102933:	39 c6                	cmp    %eax,%esi
f0102935:	74 24                	je     f010295b <mem_init+0x1627>
f0102937:	c7 44 24 0c 14 4d 10 	movl   $0xf0104d14,0xc(%esp)
f010293e:	f0 
f010293f:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102946:	f0 
f0102947:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f010294e:	00 
f010294f:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102956:	e8 39 d7 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010295b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102961:	39 fe                	cmp    %edi,%esi
f0102963:	72 c1                	jb     f0102926 <mem_init+0x15f2>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102965:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010296a:	89 d8                	mov    %ebx,%eax
f010296c:	e8 bb e0 ff ff       	call   f0100a2c <check_va2pa>
f0102971:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102976:	bf 00 e0 10 f0       	mov    $0xf010e000,%edi
f010297b:	81 c7 00 70 00 20    	add    $0x20007000,%edi
f0102981:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102984:	39 c2                	cmp    %eax,%edx
f0102986:	74 24                	je     f01029ac <mem_init+0x1678>
f0102988:	c7 44 24 0c 3c 4d 10 	movl   $0xf0104d3c,0xc(%esp)
f010298f:	f0 
f0102990:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102997:	f0 
f0102998:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010299f:	00 
f01029a0:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01029a7:	e8 e8 d6 ff ff       	call   f0100094 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029ac:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01029b2:	0f 85 37 05 00 00    	jne    f0102eef <mem_init+0x1bbb>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029b8:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029bd:	89 d8                	mov    %ebx,%eax
f01029bf:	e8 68 e0 ff ff       	call   f0100a2c <check_va2pa>
f01029c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029c7:	74 24                	je     f01029ed <mem_init+0x16b9>
f01029c9:	c7 44 24 0c 84 4d 10 	movl   $0xf0104d84,0xc(%esp)
f01029d0:	f0 
f01029d1:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f01029d8:	f0 
f01029d9:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f01029e0:	00 
f01029e1:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f01029e8:	e8 a7 d6 ff ff       	call   f0100094 <_panic>
f01029ed:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029f2:	ba 01 00 00 00       	mov    $0x1,%edx
f01029f7:	8d 88 44 fc ff ff    	lea    -0x3bc(%eax),%ecx
f01029fd:	83 f9 03             	cmp    $0x3,%ecx
f0102a00:	77 39                	ja     f0102a3b <mem_init+0x1707>
f0102a02:	89 d6                	mov    %edx,%esi
f0102a04:	d3 e6                	shl    %cl,%esi
f0102a06:	89 f1                	mov    %esi,%ecx
f0102a08:	f6 c1 0b             	test   $0xb,%cl
f0102a0b:	74 2e                	je     f0102a3b <mem_init+0x1707>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102a0d:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102a11:	0f 85 aa 00 00 00    	jne    f0102ac1 <mem_init+0x178d>
f0102a17:	c7 44 24 0c 2c 51 10 	movl   $0xf010512c,0xc(%esp)
f0102a1e:	f0 
f0102a1f:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102a26:	f0 
f0102a27:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0102a2e:	00 
f0102a2f:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102a36:	e8 59 d6 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a3b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a40:	76 55                	jbe    f0102a97 <mem_init+0x1763>
				assert(pgdir[i] & PTE_P);
f0102a42:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0102a45:	f6 c1 01             	test   $0x1,%cl
f0102a48:	75 24                	jne    f0102a6e <mem_init+0x173a>
f0102a4a:	c7 44 24 0c 2c 51 10 	movl   $0xf010512c,0xc(%esp)
f0102a51:	f0 
f0102a52:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102a59:	f0 
f0102a5a:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102a61:	00 
f0102a62:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102a69:	e8 26 d6 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a6e:	f6 c1 02             	test   $0x2,%cl
f0102a71:	75 4e                	jne    f0102ac1 <mem_init+0x178d>
f0102a73:	c7 44 24 0c 3d 51 10 	movl   $0xf010513d,0xc(%esp)
f0102a7a:	f0 
f0102a7b:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102a82:	f0 
f0102a83:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0102a8a:	00 
f0102a8b:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102a92:	e8 fd d5 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a97:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102a9b:	74 24                	je     f0102ac1 <mem_init+0x178d>
f0102a9d:	c7 44 24 0c 4e 51 10 	movl   $0xf010514e,0xc(%esp)
f0102aa4:	f0 
f0102aa5:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102aac:	f0 
f0102aad:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0102ab4:	00 
f0102ab5:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102abc:	e8 d3 d5 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102ac1:	83 c0 01             	add    $0x1,%eax
f0102ac4:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ac9:	0f 85 28 ff ff ff    	jne    f01029f7 <mem_init+0x16c3>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102acf:	c7 04 24 b4 4d 10 f0 	movl   $0xf0104db4,(%esp)
f0102ad6:	e8 97 04 00 00       	call   f0102f72 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102adb:	a1 88 89 11 f0       	mov    0xf0118988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ae0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ae5:	77 20                	ja     f0102b07 <mem_init+0x17d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102aeb:	c7 44 24 08 1c 48 10 	movl   $0xf010481c,0x8(%esp)
f0102af2:	f0 
f0102af3:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0102afa:	00 
f0102afb:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102b02:	e8 8d d5 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b07:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b0c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b14:	e8 87 e0 ff ff       	call   f0100ba0 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102b19:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102b1c:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b21:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b24:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b2e:	e8 9d e4 ff ff       	call   f0100fd0 <page_alloc>
f0102b33:	89 c6                	mov    %eax,%esi
f0102b35:	85 c0                	test   %eax,%eax
f0102b37:	75 24                	jne    f0102b5d <mem_init+0x1829>
f0102b39:	c7 44 24 0c 61 4f 10 	movl   $0xf0104f61,0xc(%esp)
f0102b40:	f0 
f0102b41:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102b48:	f0 
f0102b49:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102b50:	00 
f0102b51:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102b58:	e8 37 d5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b64:	e8 67 e4 ff ff       	call   f0100fd0 <page_alloc>
f0102b69:	89 c7                	mov    %eax,%edi
f0102b6b:	85 c0                	test   %eax,%eax
f0102b6d:	75 24                	jne    f0102b93 <mem_init+0x185f>
f0102b6f:	c7 44 24 0c 77 4f 10 	movl   $0xf0104f77,0xc(%esp)
f0102b76:	f0 
f0102b77:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102b7e:	f0 
f0102b7f:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102b86:	00 
f0102b87:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102b8e:	e8 01 d5 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b9a:	e8 31 e4 ff ff       	call   f0100fd0 <page_alloc>
f0102b9f:	89 c3                	mov    %eax,%ebx
f0102ba1:	85 c0                	test   %eax,%eax
f0102ba3:	75 24                	jne    f0102bc9 <mem_init+0x1895>
f0102ba5:	c7 44 24 0c 8d 4f 10 	movl   $0xf0104f8d,0xc(%esp)
f0102bac:	f0 
f0102bad:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102bb4:	f0 
f0102bb5:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102bbc:	00 
f0102bbd:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102bc4:	e8 cb d4 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102bc9:	89 34 24             	mov    %esi,(%esp)
f0102bcc:	e8 7d e4 ff ff       	call   f010104e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bd1:	89 f8                	mov    %edi,%eax
f0102bd3:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0102bd9:	c1 f8 03             	sar    $0x3,%eax
f0102bdc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bdf:	89 c2                	mov    %eax,%edx
f0102be1:	c1 ea 0c             	shr    $0xc,%edx
f0102be4:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f0102bea:	72 20                	jb     f0102c0c <mem_init+0x18d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bf0:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0102bf7:	f0 
f0102bf8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102bff:	00 
f0102c00:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f0102c07:	e8 88 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c0c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c13:	00 
f0102c14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102c1b:	00 
	return (void *)(pa + KERNBASE);
f0102c1c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c21:	89 04 24             	mov    %eax,(%esp)
f0102c24:	e8 38 10 00 00       	call   f0103c61 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c29:	89 d8                	mov    %ebx,%eax
f0102c2b:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0102c31:	c1 f8 03             	sar    $0x3,%eax
f0102c34:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c37:	89 c2                	mov    %eax,%edx
f0102c39:	c1 ea 0c             	shr    $0xc,%edx
f0102c3c:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f0102c42:	72 20                	jb     f0102c64 <mem_init+0x1930>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c48:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0102c4f:	f0 
f0102c50:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c57:	00 
f0102c58:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f0102c5f:	e8 30 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c64:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c6b:	00 
f0102c6c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c73:	00 
	return (void *)(pa + KERNBASE);
f0102c74:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c79:	89 04 24             	mov    %eax,(%esp)
f0102c7c:	e8 e0 0f 00 00       	call   f0103c61 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c81:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c88:	00 
f0102c89:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c90:	00 
f0102c91:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102c95:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102c9a:	89 04 24             	mov    %eax,(%esp)
f0102c9d:	e8 e8 e5 ff ff       	call   f010128a <page_insert>
	assert(pp1->pp_ref == 1);
f0102ca2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ca7:	74 24                	je     f0102ccd <mem_init+0x1999>
f0102ca9:	c7 44 24 0c 5e 50 10 	movl   $0xf010505e,0xc(%esp)
f0102cb0:	f0 
f0102cb1:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102cb8:	f0 
f0102cb9:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102cc0:	00 
f0102cc1:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102cc8:	e8 c7 d3 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ccd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cd4:	01 01 01 
f0102cd7:	74 24                	je     f0102cfd <mem_init+0x19c9>
f0102cd9:	c7 44 24 0c d4 4d 10 	movl   $0xf0104dd4,0xc(%esp)
f0102ce0:	f0 
f0102ce1:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102ce8:	f0 
f0102ce9:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102cf0:	00 
f0102cf1:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102cf8:	e8 97 d3 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cfd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102d04:	00 
f0102d05:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d0c:	00 
f0102d0d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d11:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102d16:	89 04 24             	mov    %eax,(%esp)
f0102d19:	e8 6c e5 ff ff       	call   f010128a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d1e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d25:	02 02 02 
f0102d28:	74 24                	je     f0102d4e <mem_init+0x1a1a>
f0102d2a:	c7 44 24 0c f8 4d 10 	movl   $0xf0104df8,0xc(%esp)
f0102d31:	f0 
f0102d32:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102d39:	f0 
f0102d3a:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102d41:	00 
f0102d42:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102d49:	e8 46 d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102d4e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d53:	74 24                	je     f0102d79 <mem_init+0x1a45>
f0102d55:	c7 44 24 0c 8a 50 10 	movl   $0xf010508a,0xc(%esp)
f0102d5c:	f0 
f0102d5d:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102d64:	f0 
f0102d65:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102d6c:	00 
f0102d6d:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102d74:	e8 1b d3 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102d79:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d7e:	74 24                	je     f0102da4 <mem_init+0x1a70>
f0102d80:	c7 44 24 0c d3 50 10 	movl   $0xf01050d3,0xc(%esp)
f0102d87:	f0 
f0102d88:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102d8f:	f0 
f0102d90:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102d97:	00 
f0102d98:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102d9f:	e8 f0 d2 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102da4:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102dab:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102dae:	89 d8                	mov    %ebx,%eax
f0102db0:	2b 05 8c 89 11 f0    	sub    0xf011898c,%eax
f0102db6:	c1 f8 03             	sar    $0x3,%eax
f0102db9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dbc:	89 c2                	mov    %eax,%edx
f0102dbe:	c1 ea 0c             	shr    $0xc,%edx
f0102dc1:	3b 15 84 89 11 f0    	cmp    0xf0118984,%edx
f0102dc7:	72 20                	jb     f0102de9 <mem_init+0x1ab5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dcd:	c7 44 24 08 10 47 10 	movl   $0xf0104710,0x8(%esp)
f0102dd4:	f0 
f0102dd5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102ddc:	00 
f0102ddd:	c7 04 24 9c 4e 10 f0 	movl   $0xf0104e9c,(%esp)
f0102de4:	e8 ab d2 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102de9:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102df0:	03 03 03 
f0102df3:	74 24                	je     f0102e19 <mem_init+0x1ae5>
f0102df5:	c7 44 24 0c 1c 4e 10 	movl   $0xf0104e1c,0xc(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102e0c:	00 
f0102e0d:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102e14:	e8 7b d2 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e19:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102e20:	00 
f0102e21:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102e26:	89 04 24             	mov    %eax,(%esp)
f0102e29:	e8 0c e4 ff ff       	call   f010123a <page_remove>
	assert(pp2->pp_ref == 0);
f0102e2e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102e33:	74 24                	je     f0102e59 <mem_init+0x1b25>
f0102e35:	c7 44 24 0c c2 50 10 	movl   $0xf01050c2,0xc(%esp)
f0102e3c:	f0 
f0102e3d:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102e44:	f0 
f0102e45:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102e4c:	00 
f0102e4d:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102e54:	e8 3b d2 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e59:	a1 88 89 11 f0       	mov    0xf0118988,%eax
f0102e5e:	8b 08                	mov    (%eax),%ecx
f0102e60:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e66:	89 f2                	mov    %esi,%edx
f0102e68:	2b 15 8c 89 11 f0    	sub    0xf011898c,%edx
f0102e6e:	c1 fa 03             	sar    $0x3,%edx
f0102e71:	c1 e2 0c             	shl    $0xc,%edx
f0102e74:	39 d1                	cmp    %edx,%ecx
f0102e76:	74 24                	je     f0102e9c <mem_init+0x1b68>
f0102e78:	c7 44 24 0c 98 49 10 	movl   $0xf0104998,0xc(%esp)
f0102e7f:	f0 
f0102e80:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102e87:	f0 
f0102e88:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102e8f:	00 
f0102e90:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102e97:	e8 f8 d1 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102e9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102ea2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ea7:	74 24                	je     f0102ecd <mem_init+0x1b99>
f0102ea9:	c7 44 24 0c 6f 50 10 	movl   $0xf010506f,0xc(%esp)
f0102eb0:	f0 
f0102eb1:	c7 44 24 08 b6 4e 10 	movl   $0xf0104eb6,0x8(%esp)
f0102eb8:	f0 
f0102eb9:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102ec0:	00 
f0102ec1:	c7 04 24 74 4e 10 f0 	movl   $0xf0104e74,(%esp)
f0102ec8:	e8 c7 d1 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102ecd:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102ed3:	89 34 24             	mov    %esi,(%esp)
f0102ed6:	e8 73 e1 ff ff       	call   f010104e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102edb:	c7 04 24 48 4e 10 f0 	movl   $0xf0104e48,(%esp)
f0102ee2:	e8 8b 00 00 00       	call   f0102f72 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ee7:	83 c4 3c             	add    $0x3c,%esp
f0102eea:	5b                   	pop    %ebx
f0102eeb:	5e                   	pop    %esi
f0102eec:	5f                   	pop    %edi
f0102eed:	5d                   	pop    %ebp
f0102eee:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102eef:	89 f2                	mov    %esi,%edx
f0102ef1:	89 d8                	mov    %ebx,%eax
f0102ef3:	e8 34 db ff ff       	call   f0100a2c <check_va2pa>
f0102ef8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102efe:	e9 7e fa ff ff       	jmp    f0102981 <mem_init+0x164d>
	...

f0102f04 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f04:	55                   	push   %ebp
f0102f05:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f07:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f0f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f10:	b2 71                	mov    $0x71,%dl
f0102f12:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f13:	0f b6 c0             	movzbl %al,%eax
}
f0102f16:	5d                   	pop    %ebp
f0102f17:	c3                   	ret    

f0102f18 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f18:	55                   	push   %ebp
f0102f19:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f1b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f20:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f23:	ee                   	out    %al,(%dx)
f0102f24:	b2 71                	mov    $0x71,%dl
f0102f26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f29:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f2a:	5d                   	pop    %ebp
f0102f2b:	c3                   	ret    

f0102f2c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f2c:	55                   	push   %ebp
f0102f2d:	89 e5                	mov    %esp,%ebp
f0102f2f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102f32:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f35:	89 04 24             	mov    %eax,(%esp)
f0102f38:	e8 b3 d6 ff ff       	call   f01005f0 <cputchar>
	*cnt++;
}
f0102f3d:	c9                   	leave  
f0102f3e:	c3                   	ret    

f0102f3f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f3f:	55                   	push   %ebp
f0102f40:	89 e5                	mov    %esp,%ebp
f0102f42:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f53:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f61:	c7 04 24 2c 2f 10 f0 	movl   $0xf0102f2c,(%esp)
f0102f68:	e8 b5 04 00 00       	call   f0103422 <vprintfmt>
	return cnt;
}
f0102f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f70:	c9                   	leave  
f0102f71:	c3                   	ret    

f0102f72 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f72:	55                   	push   %ebp
f0102f73:	89 e5                	mov    %esp,%ebp
f0102f75:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f78:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f82:	89 04 24             	mov    %eax,(%esp)
f0102f85:	e8 b5 ff ff ff       	call   f0102f3f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f8a:	c9                   	leave  
f0102f8b:	c3                   	ret    

f0102f8c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102f8c:	55                   	push   %ebp
f0102f8d:	89 e5                	mov    %esp,%ebp
f0102f8f:	57                   	push   %edi
f0102f90:	56                   	push   %esi
f0102f91:	53                   	push   %ebx
f0102f92:	83 ec 10             	sub    $0x10,%esp
f0102f95:	89 c3                	mov    %eax,%ebx
f0102f97:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102f9a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102f9d:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fa0:	8b 0a                	mov    (%edx),%ecx
f0102fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fa5:	8b 00                	mov    (%eax),%eax
f0102fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102faa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102fb1:	eb 77                	jmp    f010302a <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0102fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102fb6:	01 c8                	add    %ecx,%eax
f0102fb8:	bf 02 00 00 00       	mov    $0x2,%edi
f0102fbd:	99                   	cltd   
f0102fbe:	f7 ff                	idiv   %edi
f0102fc0:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102fc2:	eb 01                	jmp    f0102fc5 <stab_binsearch+0x39>
			m--;
f0102fc4:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102fc5:	39 ca                	cmp    %ecx,%edx
f0102fc7:	7c 1d                	jl     f0102fe6 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102fc9:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102fcc:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0102fd1:	39 f7                	cmp    %esi,%edi
f0102fd3:	75 ef                	jne    f0102fc4 <stab_binsearch+0x38>
f0102fd5:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102fd8:	6b fa 0c             	imul   $0xc,%edx,%edi
f0102fdb:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0102fdf:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102fe2:	73 18                	jae    f0102ffc <stab_binsearch+0x70>
f0102fe4:	eb 05                	jmp    f0102feb <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102fe6:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0102fe9:	eb 3f                	jmp    f010302a <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102feb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102fee:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0102ff0:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102ff3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102ffa:	eb 2e                	jmp    f010302a <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102ffc:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102fff:	76 15                	jbe    f0103016 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0103001:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103004:	4f                   	dec    %edi
f0103005:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010300b:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010300d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0103014:	eb 14                	jmp    f010302a <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103016:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103019:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010301c:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f010301e:	ff 45 0c             	incl   0xc(%ebp)
f0103021:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103023:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010302a:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f010302d:	7e 84                	jle    f0102fb3 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010302f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0103033:	75 0d                	jne    f0103042 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0103035:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103038:	8b 02                	mov    (%edx),%eax
f010303a:	48                   	dec    %eax
f010303b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010303e:	89 01                	mov    %eax,(%ecx)
f0103040:	eb 22                	jmp    f0103064 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103042:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103045:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103047:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010304a:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010304c:	eb 01                	jmp    f010304f <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010304e:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010304f:	39 c1                	cmp    %eax,%ecx
f0103051:	7d 0c                	jge    f010305f <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103053:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0103056:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f010305b:	39 f2                	cmp    %esi,%edx
f010305d:	75 ef                	jne    f010304e <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f010305f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103062:	89 02                	mov    %eax,(%edx)
	}
}
f0103064:	83 c4 10             	add    $0x10,%esp
f0103067:	5b                   	pop    %ebx
f0103068:	5e                   	pop    %esi
f0103069:	5f                   	pop    %edi
f010306a:	5d                   	pop    %ebp
f010306b:	c3                   	ret    

f010306c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010306c:	55                   	push   %ebp
f010306d:	89 e5                	mov    %esp,%ebp
f010306f:	83 ec 58             	sub    $0x58,%esp
f0103072:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103075:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103078:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010307b:	8b 75 08             	mov    0x8(%ebp),%esi
f010307e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103081:	c7 03 5c 51 10 f0    	movl   $0xf010515c,(%ebx)
	info->eip_line = 0;
f0103087:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010308e:	c7 43 08 5c 51 10 f0 	movl   $0xf010515c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103095:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010309c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010309f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01030a6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01030ac:	76 12                	jbe    f01030c0 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01030ae:	b8 27 d9 10 f0       	mov    $0xf010d927,%eax
f01030b3:	3d f1 b9 10 f0       	cmp    $0xf010b9f1,%eax
f01030b8:	0f 86 f1 01 00 00    	jbe    f01032af <debuginfo_eip+0x243>
f01030be:	eb 1c                	jmp    f01030dc <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01030c0:	c7 44 24 08 66 51 10 	movl   $0xf0105166,0x8(%esp)
f01030c7:	f0 
f01030c8:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f01030cf:	00 
f01030d0:	c7 04 24 73 51 10 f0 	movl   $0xf0105173,(%esp)
f01030d7:	e8 b8 cf ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01030dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01030e1:	80 3d 26 d9 10 f0 00 	cmpb   $0x0,0xf010d926
f01030e8:	0f 85 cd 01 00 00    	jne    f01032bb <debuginfo_eip+0x24f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01030ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01030f5:	b8 f0 b9 10 f0       	mov    $0xf010b9f0,%eax
f01030fa:	2d a8 53 10 f0       	sub    $0xf01053a8,%eax
f01030ff:	c1 f8 02             	sar    $0x2,%eax
f0103102:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103108:	83 e8 01             	sub    $0x1,%eax
f010310b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010310e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103112:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103119:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010311c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010311f:	b8 a8 53 10 f0       	mov    $0xf01053a8,%eax
f0103124:	e8 63 fe ff ff       	call   f0102f8c <stab_binsearch>
	if (lfile == 0)
f0103129:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f010312c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103131:	85 d2                	test   %edx,%edx
f0103133:	0f 84 82 01 00 00    	je     f01032bb <debuginfo_eip+0x24f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103139:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010313c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010313f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103142:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103146:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010314d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103150:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103153:	b8 a8 53 10 f0       	mov    $0xf01053a8,%eax
f0103158:	e8 2f fe ff ff       	call   f0102f8c <stab_binsearch>

	if (lfun <= rfun) {
f010315d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103160:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103163:	39 d0                	cmp    %edx,%eax
f0103165:	7f 3d                	jg     f01031a4 <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103167:	6b c8 0c             	imul   $0xc,%eax,%ecx
f010316a:	8d b9 a8 53 10 f0    	lea    -0xfefac58(%ecx),%edi
f0103170:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0103173:	8b 89 a8 53 10 f0    	mov    -0xfefac58(%ecx),%ecx
f0103179:	bf 27 d9 10 f0       	mov    $0xf010d927,%edi
f010317e:	81 ef f1 b9 10 f0    	sub    $0xf010b9f1,%edi
f0103184:	39 f9                	cmp    %edi,%ecx
f0103186:	73 09                	jae    f0103191 <debuginfo_eip+0x125>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103188:	81 c1 f1 b9 10 f0    	add    $0xf010b9f1,%ecx
f010318e:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103191:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103194:	8b 4f 08             	mov    0x8(%edi),%ecx
f0103197:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010319a:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010319c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010319f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01031a2:	eb 0f                	jmp    f01031b3 <debuginfo_eip+0x147>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01031a4:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01031a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01031ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01031b3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01031ba:	00 
f01031bb:	8b 43 08             	mov    0x8(%ebx),%eax
f01031be:	89 04 24             	mov    %eax,(%esp)
f01031c1:	e8 74 0a 00 00       	call   f0103c3a <strfind>
f01031c6:	2b 43 08             	sub    0x8(%ebx),%eax
f01031c9:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01031cc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01031d0:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01031d7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01031da:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01031dd:	b8 a8 53 10 f0       	mov    $0xf01053a8,%eax
f01031e2:	e8 a5 fd ff ff       	call   f0102f8c <stab_binsearch>

	if(lline <= rline)
f01031e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f01031ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f01031ef:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01031f2:	0f 8f c3 00 00 00    	jg     f01032bb <debuginfo_eip+0x24f>
		info->eip_line = stabs[lline].n_desc;
f01031f8:	6b d2 0c             	imul   $0xc,%edx,%edx
f01031fb:	0f b7 82 ae 53 10 f0 	movzwl -0xfefac52(%edx),%eax
f0103202:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103205:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103208:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010320b:	39 c8                	cmp    %ecx,%eax
f010320d:	7c 5f                	jl     f010326e <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f010320f:	89 c2                	mov    %eax,%edx
f0103211:	6b f0 0c             	imul   $0xc,%eax,%esi
f0103214:	80 be ac 53 10 f0 84 	cmpb   $0x84,-0xfefac54(%esi)
f010321b:	75 18                	jne    f0103235 <debuginfo_eip+0x1c9>
f010321d:	eb 30                	jmp    f010324f <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010321f:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103222:	39 c1                	cmp    %eax,%ecx
f0103224:	7f 48                	jg     f010326e <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f0103226:	89 c2                	mov    %eax,%edx
f0103228:	8d 34 40             	lea    (%eax,%eax,2),%esi
f010322b:	80 3c b5 ac 53 10 f0 	cmpb   $0x84,-0xfefac54(,%esi,4)
f0103232:	84 
f0103233:	74 1a                	je     f010324f <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103235:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103238:	8d 14 95 a8 53 10 f0 	lea    -0xfefac58(,%edx,4),%edx
f010323f:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f0103243:	75 da                	jne    f010321f <debuginfo_eip+0x1b3>
f0103245:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103249:	74 d4                	je     f010321f <debuginfo_eip+0x1b3>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010324b:	39 c1                	cmp    %eax,%ecx
f010324d:	7f 1f                	jg     f010326e <debuginfo_eip+0x202>
f010324f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103252:	8b 80 a8 53 10 f0    	mov    -0xfefac58(%eax),%eax
f0103258:	ba 27 d9 10 f0       	mov    $0xf010d927,%edx
f010325d:	81 ea f1 b9 10 f0    	sub    $0xf010b9f1,%edx
f0103263:	39 d0                	cmp    %edx,%eax
f0103265:	73 07                	jae    f010326e <debuginfo_eip+0x202>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103267:	05 f1 b9 10 f0       	add    $0xf010b9f1,%eax
f010326c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010326e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103271:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103274:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103279:	39 ca                	cmp    %ecx,%edx
f010327b:	7d 3e                	jge    f01032bb <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
f010327d:	83 c2 01             	add    $0x1,%edx
f0103280:	39 d1                	cmp    %edx,%ecx
f0103282:	7e 37                	jle    f01032bb <debuginfo_eip+0x24f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103284:	6b f2 0c             	imul   $0xc,%edx,%esi
f0103287:	80 be ac 53 10 f0 a0 	cmpb   $0xa0,-0xfefac54(%esi)
f010328e:	75 2b                	jne    f01032bb <debuginfo_eip+0x24f>
		     lline++)
			info->eip_fn_narg++;
f0103290:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103294:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103297:	39 d1                	cmp    %edx,%ecx
f0103299:	7e 1b                	jle    f01032b6 <debuginfo_eip+0x24a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010329b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010329e:	80 3c 85 ac 53 10 f0 	cmpb   $0xa0,-0xfefac54(,%eax,4)
f01032a5:	a0 
f01032a6:	74 e8                	je     f0103290 <debuginfo_eip+0x224>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01032ad:	eb 0c                	jmp    f01032bb <debuginfo_eip+0x24f>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01032af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032b4:	eb 05                	jmp    f01032bb <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01032be:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01032c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01032c4:	89 ec                	mov    %ebp,%esp
f01032c6:	5d                   	pop    %ebp
f01032c7:	c3                   	ret    

f01032c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01032c8:	55                   	push   %ebp
f01032c9:	89 e5                	mov    %esp,%ebp
f01032cb:	57                   	push   %edi
f01032cc:	56                   	push   %esi
f01032cd:	53                   	push   %ebx
f01032ce:	83 ec 3c             	sub    $0x3c,%esp
f01032d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01032d4:	89 d7                	mov    %edx,%edi
f01032d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01032dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032df:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01032e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01032e5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01032e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01032ed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01032f0:	72 11                	jb     f0103303 <printnum+0x3b>
f01032f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01032f5:	39 45 10             	cmp    %eax,0x10(%ebp)
f01032f8:	76 09                	jbe    f0103303 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01032fa:	83 eb 01             	sub    $0x1,%ebx
f01032fd:	85 db                	test   %ebx,%ebx
f01032ff:	7f 51                	jg     f0103352 <printnum+0x8a>
f0103301:	eb 5e                	jmp    f0103361 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103303:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103307:	83 eb 01             	sub    $0x1,%ebx
f010330a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010330e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103311:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103315:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0103319:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010331d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103324:	00 
f0103325:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103328:	89 04 24             	mov    %eax,(%esp)
f010332b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010332e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103332:	e8 79 0b 00 00       	call   f0103eb0 <__udivdi3>
f0103337:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010333b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010333f:	89 04 24             	mov    %eax,(%esp)
f0103342:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103346:	89 fa                	mov    %edi,%edx
f0103348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010334b:	e8 78 ff ff ff       	call   f01032c8 <printnum>
f0103350:	eb 0f                	jmp    f0103361 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103352:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103356:	89 34 24             	mov    %esi,(%esp)
f0103359:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010335c:	83 eb 01             	sub    $0x1,%ebx
f010335f:	75 f1                	jne    f0103352 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103361:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103365:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103369:	8b 45 10             	mov    0x10(%ebp),%eax
f010336c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103370:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103377:	00 
f0103378:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010337b:	89 04 24             	mov    %eax,(%esp)
f010337e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103381:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103385:	e8 56 0c 00 00       	call   f0103fe0 <__umoddi3>
f010338a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010338e:	0f be 80 81 51 10 f0 	movsbl -0xfefae7f(%eax),%eax
f0103395:	89 04 24             	mov    %eax,(%esp)
f0103398:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010339b:	83 c4 3c             	add    $0x3c,%esp
f010339e:	5b                   	pop    %ebx
f010339f:	5e                   	pop    %esi
f01033a0:	5f                   	pop    %edi
f01033a1:	5d                   	pop    %ebp
f01033a2:	c3                   	ret    

f01033a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01033a3:	55                   	push   %ebp
f01033a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01033a6:	83 fa 01             	cmp    $0x1,%edx
f01033a9:	7e 0e                	jle    f01033b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01033ab:	8b 10                	mov    (%eax),%edx
f01033ad:	8d 4a 08             	lea    0x8(%edx),%ecx
f01033b0:	89 08                	mov    %ecx,(%eax)
f01033b2:	8b 02                	mov    (%edx),%eax
f01033b4:	8b 52 04             	mov    0x4(%edx),%edx
f01033b7:	eb 22                	jmp    f01033db <getuint+0x38>
	else if (lflag)
f01033b9:	85 d2                	test   %edx,%edx
f01033bb:	74 10                	je     f01033cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01033bd:	8b 10                	mov    (%eax),%edx
f01033bf:	8d 4a 04             	lea    0x4(%edx),%ecx
f01033c2:	89 08                	mov    %ecx,(%eax)
f01033c4:	8b 02                	mov    (%edx),%eax
f01033c6:	ba 00 00 00 00       	mov    $0x0,%edx
f01033cb:	eb 0e                	jmp    f01033db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01033cd:	8b 10                	mov    (%eax),%edx
f01033cf:	8d 4a 04             	lea    0x4(%edx),%ecx
f01033d2:	89 08                	mov    %ecx,(%eax)
f01033d4:	8b 02                	mov    (%edx),%eax
f01033d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01033db:	5d                   	pop    %ebp
f01033dc:	c3                   	ret    

f01033dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01033dd:	55                   	push   %ebp
f01033de:	89 e5                	mov    %esp,%ebp
f01033e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01033e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01033e7:	8b 10                	mov    (%eax),%edx
f01033e9:	3b 50 04             	cmp    0x4(%eax),%edx
f01033ec:	73 0a                	jae    f01033f8 <sprintputch+0x1b>
		*b->buf++ = ch;
f01033ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01033f1:	88 0a                	mov    %cl,(%edx)
f01033f3:	83 c2 01             	add    $0x1,%edx
f01033f6:	89 10                	mov    %edx,(%eax)
}
f01033f8:	5d                   	pop    %ebp
f01033f9:	c3                   	ret    

f01033fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01033fa:	55                   	push   %ebp
f01033fb:	89 e5                	mov    %esp,%ebp
f01033fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103400:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103403:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103407:	8b 45 10             	mov    0x10(%ebp),%eax
f010340a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010340e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103411:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103415:	8b 45 08             	mov    0x8(%ebp),%eax
f0103418:	89 04 24             	mov    %eax,(%esp)
f010341b:	e8 02 00 00 00       	call   f0103422 <vprintfmt>
	va_end(ap);
}
f0103420:	c9                   	leave  
f0103421:	c3                   	ret    

f0103422 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103422:	55                   	push   %ebp
f0103423:	89 e5                	mov    %esp,%ebp
f0103425:	57                   	push   %edi
f0103426:	56                   	push   %esi
f0103427:	53                   	push   %ebx
f0103428:	83 ec 5c             	sub    $0x5c,%esp
f010342b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010342e:	8b 75 10             	mov    0x10(%ebp),%esi
f0103431:	eb 12                	jmp    f0103445 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103433:	85 c0                	test   %eax,%eax
f0103435:	0f 84 e4 04 00 00    	je     f010391f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f010343b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010343f:	89 04 24             	mov    %eax,(%esp)
f0103442:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103445:	0f b6 06             	movzbl (%esi),%eax
f0103448:	83 c6 01             	add    $0x1,%esi
f010344b:	83 f8 25             	cmp    $0x25,%eax
f010344e:	75 e3                	jne    f0103433 <vprintfmt+0x11>
f0103450:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0103454:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f010345b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103460:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0103467:	b9 00 00 00 00       	mov    $0x0,%ecx
f010346c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010346f:	eb 2b                	jmp    f010349c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103471:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103474:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0103478:	eb 22                	jmp    f010349c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010347a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010347d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0103481:	eb 19                	jmp    f010349c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103483:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103486:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f010348d:	eb 0d                	jmp    f010349c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010348f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103492:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103495:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010349c:	0f b6 06             	movzbl (%esi),%eax
f010349f:	0f b6 d0             	movzbl %al,%edx
f01034a2:	8d 7e 01             	lea    0x1(%esi),%edi
f01034a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01034a8:	83 e8 23             	sub    $0x23,%eax
f01034ab:	3c 55                	cmp    $0x55,%al
f01034ad:	0f 87 46 04 00 00    	ja     f01038f9 <vprintfmt+0x4d7>
f01034b3:	0f b6 c0             	movzbl %al,%eax
f01034b6:	ff 24 85 24 52 10 f0 	jmp    *-0xfefaddc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01034bd:	83 ea 30             	sub    $0x30,%edx
f01034c0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f01034c3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f01034c7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f01034cd:	83 fa 09             	cmp    $0x9,%edx
f01034d0:	77 4a                	ja     f010351c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034d2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01034d5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f01034d8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01034db:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01034df:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01034e2:	8d 50 d0             	lea    -0x30(%eax),%edx
f01034e5:	83 fa 09             	cmp    $0x9,%edx
f01034e8:	76 eb                	jbe    f01034d5 <vprintfmt+0xb3>
f01034ea:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01034ed:	eb 2d                	jmp    f010351c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01034ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f2:	8d 50 04             	lea    0x4(%eax),%edx
f01034f5:	89 55 14             	mov    %edx,0x14(%ebp)
f01034f8:	8b 00                	mov    (%eax),%eax
f01034fa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103500:	eb 1a                	jmp    f010351c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103502:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0103505:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103509:	79 91                	jns    f010349c <vprintfmt+0x7a>
f010350b:	e9 73 ff ff ff       	jmp    f0103483 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103510:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103513:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f010351a:	eb 80                	jmp    f010349c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f010351c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103520:	0f 89 76 ff ff ff    	jns    f010349c <vprintfmt+0x7a>
f0103526:	e9 64 ff ff ff       	jmp    f010348f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010352b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010352e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103531:	e9 66 ff ff ff       	jmp    f010349c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103536:	8b 45 14             	mov    0x14(%ebp),%eax
f0103539:	8d 50 04             	lea    0x4(%eax),%edx
f010353c:	89 55 14             	mov    %edx,0x14(%ebp)
f010353f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103543:	8b 00                	mov    (%eax),%eax
f0103545:	89 04 24             	mov    %eax,(%esp)
f0103548:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010354b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010354e:	e9 f2 fe ff ff       	jmp    f0103445 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0103553:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0103557:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f010355a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f010355e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0103561:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0103565:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0103568:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f010356b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f010356f:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103572:	80 f9 09             	cmp    $0x9,%cl
f0103575:	77 1d                	ja     f0103594 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0103577:	0f be c0             	movsbl %al,%eax
f010357a:	6b c0 64             	imul   $0x64,%eax,%eax
f010357d:	0f be d2             	movsbl %dl,%edx
f0103580:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103583:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f010358a:	a3 04 83 11 f0       	mov    %eax,0xf0118304
f010358f:	e9 b1 fe ff ff       	jmp    f0103445 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0103594:	c7 44 24 04 99 51 10 	movl   $0xf0105199,0x4(%esp)
f010359b:	f0 
f010359c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010359f:	89 04 24             	mov    %eax,(%esp)
f01035a2:	e8 e4 05 00 00       	call   f0103b8b <strcmp>
f01035a7:	85 c0                	test   %eax,%eax
f01035a9:	75 0f                	jne    f01035ba <vprintfmt+0x198>
f01035ab:	c7 05 04 83 11 f0 04 	movl   $0x4,0xf0118304
f01035b2:	00 00 00 
f01035b5:	e9 8b fe ff ff       	jmp    f0103445 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f01035ba:	c7 44 24 04 9d 51 10 	movl   $0xf010519d,0x4(%esp)
f01035c1:	f0 
f01035c2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01035c5:	89 14 24             	mov    %edx,(%esp)
f01035c8:	e8 be 05 00 00       	call   f0103b8b <strcmp>
f01035cd:	85 c0                	test   %eax,%eax
f01035cf:	75 0f                	jne    f01035e0 <vprintfmt+0x1be>
f01035d1:	c7 05 04 83 11 f0 02 	movl   $0x2,0xf0118304
f01035d8:	00 00 00 
f01035db:	e9 65 fe ff ff       	jmp    f0103445 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f01035e0:	c7 44 24 04 a1 51 10 	movl   $0xf01051a1,0x4(%esp)
f01035e7:	f0 
f01035e8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f01035eb:	89 0c 24             	mov    %ecx,(%esp)
f01035ee:	e8 98 05 00 00       	call   f0103b8b <strcmp>
f01035f3:	85 c0                	test   %eax,%eax
f01035f5:	75 0f                	jne    f0103606 <vprintfmt+0x1e4>
f01035f7:	c7 05 04 83 11 f0 01 	movl   $0x1,0xf0118304
f01035fe:	00 00 00 
f0103601:	e9 3f fe ff ff       	jmp    f0103445 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0103606:	c7 44 24 04 a5 51 10 	movl   $0xf01051a5,0x4(%esp)
f010360d:	f0 
f010360e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0103611:	89 3c 24             	mov    %edi,(%esp)
f0103614:	e8 72 05 00 00       	call   f0103b8b <strcmp>
f0103619:	85 c0                	test   %eax,%eax
f010361b:	75 0f                	jne    f010362c <vprintfmt+0x20a>
f010361d:	c7 05 04 83 11 f0 06 	movl   $0x6,0xf0118304
f0103624:	00 00 00 
f0103627:	e9 19 fe ff ff       	jmp    f0103445 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f010362c:	c7 44 24 04 a9 51 10 	movl   $0xf01051a9,0x4(%esp)
f0103633:	f0 
f0103634:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103637:	89 04 24             	mov    %eax,(%esp)
f010363a:	e8 4c 05 00 00       	call   f0103b8b <strcmp>
f010363f:	85 c0                	test   %eax,%eax
f0103641:	75 0f                	jne    f0103652 <vprintfmt+0x230>
f0103643:	c7 05 04 83 11 f0 07 	movl   $0x7,0xf0118304
f010364a:	00 00 00 
f010364d:	e9 f3 fd ff ff       	jmp    f0103445 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0103652:	c7 44 24 04 ad 51 10 	movl   $0xf01051ad,0x4(%esp)
f0103659:	f0 
f010365a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010365d:	89 14 24             	mov    %edx,(%esp)
f0103660:	e8 26 05 00 00       	call   f0103b8b <strcmp>
f0103665:	83 f8 01             	cmp    $0x1,%eax
f0103668:	19 c0                	sbb    %eax,%eax
f010366a:	f7 d0                	not    %eax
f010366c:	83 c0 08             	add    $0x8,%eax
f010366f:	a3 04 83 11 f0       	mov    %eax,0xf0118304
f0103674:	e9 cc fd ff ff       	jmp    f0103445 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0103679:	8b 45 14             	mov    0x14(%ebp),%eax
f010367c:	8d 50 04             	lea    0x4(%eax),%edx
f010367f:	89 55 14             	mov    %edx,0x14(%ebp)
f0103682:	8b 00                	mov    (%eax),%eax
f0103684:	89 c2                	mov    %eax,%edx
f0103686:	c1 fa 1f             	sar    $0x1f,%edx
f0103689:	31 d0                	xor    %edx,%eax
f010368b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010368d:	83 f8 06             	cmp    $0x6,%eax
f0103690:	7f 0b                	jg     f010369d <vprintfmt+0x27b>
f0103692:	8b 14 85 7c 53 10 f0 	mov    -0xfefac84(,%eax,4),%edx
f0103699:	85 d2                	test   %edx,%edx
f010369b:	75 23                	jne    f01036c0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f010369d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036a1:	c7 44 24 08 b1 51 10 	movl   $0xf01051b1,0x8(%esp)
f01036a8:	f0 
f01036a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036ad:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036b0:	89 3c 24             	mov    %edi,(%esp)
f01036b3:	e8 42 fd ff ff       	call   f01033fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036b8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01036bb:	e9 85 fd ff ff       	jmp    f0103445 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01036c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01036c4:	c7 44 24 08 c8 4e 10 	movl   $0xf0104ec8,0x8(%esp)
f01036cb:	f0 
f01036cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036d0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036d3:	89 3c 24             	mov    %edi,(%esp)
f01036d6:	e8 1f fd ff ff       	call   f01033fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036db:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01036de:	e9 62 fd ff ff       	jmp    f0103445 <vprintfmt+0x23>
f01036e3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01036e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01036e9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01036ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01036ef:	8d 50 04             	lea    0x4(%eax),%edx
f01036f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01036f5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01036f7:	85 f6                	test   %esi,%esi
f01036f9:	b8 92 51 10 f0       	mov    $0xf0105192,%eax
f01036fe:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0103701:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0103705:	7e 06                	jle    f010370d <vprintfmt+0x2eb>
f0103707:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f010370b:	75 13                	jne    f0103720 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010370d:	0f be 06             	movsbl (%esi),%eax
f0103710:	83 c6 01             	add    $0x1,%esi
f0103713:	85 c0                	test   %eax,%eax
f0103715:	0f 85 94 00 00 00    	jne    f01037af <vprintfmt+0x38d>
f010371b:	e9 81 00 00 00       	jmp    f01037a1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103720:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103724:	89 34 24             	mov    %esi,(%esp)
f0103727:	e8 6f 03 00 00       	call   f0103a9b <strnlen>
f010372c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010372f:	29 c2                	sub    %eax,%edx
f0103731:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0103734:	85 d2                	test   %edx,%edx
f0103736:	7e d5                	jle    f010370d <vprintfmt+0x2eb>
					putch(padc, putdat);
f0103738:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f010373c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010373f:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0103742:	89 d6                	mov    %edx,%esi
f0103744:	89 cf                	mov    %ecx,%edi
f0103746:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010374a:	89 3c 24             	mov    %edi,(%esp)
f010374d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103750:	83 ee 01             	sub    $0x1,%esi
f0103753:	75 f1                	jne    f0103746 <vprintfmt+0x324>
f0103755:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103758:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010375b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010375e:	eb ad                	jmp    f010370d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103760:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0103764:	74 1b                	je     f0103781 <vprintfmt+0x35f>
f0103766:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103769:	83 fa 5e             	cmp    $0x5e,%edx
f010376c:	76 13                	jbe    f0103781 <vprintfmt+0x35f>
					putch('?', putdat);
f010376e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103771:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103775:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010377c:	ff 55 08             	call   *0x8(%ebp)
f010377f:	eb 0d                	jmp    f010378e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0103781:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103784:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103788:	89 04 24             	mov    %eax,(%esp)
f010378b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010378e:	83 eb 01             	sub    $0x1,%ebx
f0103791:	0f be 06             	movsbl (%esi),%eax
f0103794:	83 c6 01             	add    $0x1,%esi
f0103797:	85 c0                	test   %eax,%eax
f0103799:	75 1a                	jne    f01037b5 <vprintfmt+0x393>
f010379b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010379e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01037a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01037a4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01037a8:	7f 1c                	jg     f01037c6 <vprintfmt+0x3a4>
f01037aa:	e9 96 fc ff ff       	jmp    f0103445 <vprintfmt+0x23>
f01037af:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01037b2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01037b5:	85 ff                	test   %edi,%edi
f01037b7:	78 a7                	js     f0103760 <vprintfmt+0x33e>
f01037b9:	83 ef 01             	sub    $0x1,%edi
f01037bc:	79 a2                	jns    f0103760 <vprintfmt+0x33e>
f01037be:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01037c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01037c4:	eb db                	jmp    f01037a1 <vprintfmt+0x37f>
f01037c6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01037c9:	89 de                	mov    %ebx,%esi
f01037cb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01037ce:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01037d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01037db:	83 eb 01             	sub    $0x1,%ebx
f01037de:	75 ee                	jne    f01037ce <vprintfmt+0x3ac>
f01037e0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01037e2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01037e5:	e9 5b fc ff ff       	jmp    f0103445 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01037ea:	83 f9 01             	cmp    $0x1,%ecx
f01037ed:	7e 10                	jle    f01037ff <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f01037ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01037f2:	8d 50 08             	lea    0x8(%eax),%edx
f01037f5:	89 55 14             	mov    %edx,0x14(%ebp)
f01037f8:	8b 30                	mov    (%eax),%esi
f01037fa:	8b 78 04             	mov    0x4(%eax),%edi
f01037fd:	eb 26                	jmp    f0103825 <vprintfmt+0x403>
	else if (lflag)
f01037ff:	85 c9                	test   %ecx,%ecx
f0103801:	74 12                	je     f0103815 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f0103803:	8b 45 14             	mov    0x14(%ebp),%eax
f0103806:	8d 50 04             	lea    0x4(%eax),%edx
f0103809:	89 55 14             	mov    %edx,0x14(%ebp)
f010380c:	8b 30                	mov    (%eax),%esi
f010380e:	89 f7                	mov    %esi,%edi
f0103810:	c1 ff 1f             	sar    $0x1f,%edi
f0103813:	eb 10                	jmp    f0103825 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0103815:	8b 45 14             	mov    0x14(%ebp),%eax
f0103818:	8d 50 04             	lea    0x4(%eax),%edx
f010381b:	89 55 14             	mov    %edx,0x14(%ebp)
f010381e:	8b 30                	mov    (%eax),%esi
f0103820:	89 f7                	mov    %esi,%edi
f0103822:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103825:	85 ff                	test   %edi,%edi
f0103827:	78 0e                	js     f0103837 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103829:	89 f0                	mov    %esi,%eax
f010382b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010382d:	be 0a 00 00 00       	mov    $0xa,%esi
f0103832:	e9 84 00 00 00       	jmp    f01038bb <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103837:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010383b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103842:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103845:	89 f0                	mov    %esi,%eax
f0103847:	89 fa                	mov    %edi,%edx
f0103849:	f7 d8                	neg    %eax
f010384b:	83 d2 00             	adc    $0x0,%edx
f010384e:	f7 da                	neg    %edx
			}
			base = 10;
f0103850:	be 0a 00 00 00       	mov    $0xa,%esi
f0103855:	eb 64                	jmp    f01038bb <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103857:	89 ca                	mov    %ecx,%edx
f0103859:	8d 45 14             	lea    0x14(%ebp),%eax
f010385c:	e8 42 fb ff ff       	call   f01033a3 <getuint>
			base = 10;
f0103861:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0103866:	eb 53                	jmp    f01038bb <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0103868:	89 ca                	mov    %ecx,%edx
f010386a:	8d 45 14             	lea    0x14(%ebp),%eax
f010386d:	e8 31 fb ff ff       	call   f01033a3 <getuint>
    			base = 8;
f0103872:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0103877:	eb 42                	jmp    f01038bb <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0103879:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010387d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103884:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103887:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010388b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103892:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103895:	8b 45 14             	mov    0x14(%ebp),%eax
f0103898:	8d 50 04             	lea    0x4(%eax),%edx
f010389b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010389e:	8b 00                	mov    (%eax),%eax
f01038a0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01038a5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f01038aa:	eb 0f                	jmp    f01038bb <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01038ac:	89 ca                	mov    %ecx,%edx
f01038ae:	8d 45 14             	lea    0x14(%ebp),%eax
f01038b1:	e8 ed fa ff ff       	call   f01033a3 <getuint>
			base = 16;
f01038b6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01038bb:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f01038bf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01038c3:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01038c6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01038ca:	89 74 24 08          	mov    %esi,0x8(%esp)
f01038ce:	89 04 24             	mov    %eax,(%esp)
f01038d1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038d5:	89 da                	mov    %ebx,%edx
f01038d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01038da:	e8 e9 f9 ff ff       	call   f01032c8 <printnum>
			break;
f01038df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01038e2:	e9 5e fb ff ff       	jmp    f0103445 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01038e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038eb:	89 14 24             	mov    %edx,(%esp)
f01038ee:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01038f4:	e9 4c fb ff ff       	jmp    f0103445 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01038f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038fd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103904:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103907:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010390b:	0f 84 34 fb ff ff    	je     f0103445 <vprintfmt+0x23>
f0103911:	83 ee 01             	sub    $0x1,%esi
f0103914:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103918:	75 f7                	jne    f0103911 <vprintfmt+0x4ef>
f010391a:	e9 26 fb ff ff       	jmp    f0103445 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f010391f:	83 c4 5c             	add    $0x5c,%esp
f0103922:	5b                   	pop    %ebx
f0103923:	5e                   	pop    %esi
f0103924:	5f                   	pop    %edi
f0103925:	5d                   	pop    %ebp
f0103926:	c3                   	ret    

f0103927 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103927:	55                   	push   %ebp
f0103928:	89 e5                	mov    %esp,%ebp
f010392a:	83 ec 28             	sub    $0x28,%esp
f010392d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103930:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103933:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103936:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010393a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010393d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103944:	85 c0                	test   %eax,%eax
f0103946:	74 30                	je     f0103978 <vsnprintf+0x51>
f0103948:	85 d2                	test   %edx,%edx
f010394a:	7e 2c                	jle    f0103978 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010394c:	8b 45 14             	mov    0x14(%ebp),%eax
f010394f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103953:	8b 45 10             	mov    0x10(%ebp),%eax
f0103956:	89 44 24 08          	mov    %eax,0x8(%esp)
f010395a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010395d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103961:	c7 04 24 dd 33 10 f0 	movl   $0xf01033dd,(%esp)
f0103968:	e8 b5 fa ff ff       	call   f0103422 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010396d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103970:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103973:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103976:	eb 05                	jmp    f010397d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103978:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010397d:	c9                   	leave  
f010397e:	c3                   	ret    

f010397f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010397f:	55                   	push   %ebp
f0103980:	89 e5                	mov    %esp,%ebp
f0103982:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103985:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103988:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010398c:	8b 45 10             	mov    0x10(%ebp),%eax
f010398f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103993:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103996:	89 44 24 04          	mov    %eax,0x4(%esp)
f010399a:	8b 45 08             	mov    0x8(%ebp),%eax
f010399d:	89 04 24             	mov    %eax,(%esp)
f01039a0:	e8 82 ff ff ff       	call   f0103927 <vsnprintf>
	va_end(ap);

	return rc;
}
f01039a5:	c9                   	leave  
f01039a6:	c3                   	ret    
	...

f01039b0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01039b0:	55                   	push   %ebp
f01039b1:	89 e5                	mov    %esp,%ebp
f01039b3:	57                   	push   %edi
f01039b4:	56                   	push   %esi
f01039b5:	53                   	push   %ebx
f01039b6:	83 ec 1c             	sub    $0x1c,%esp
f01039b9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01039bc:	85 c0                	test   %eax,%eax
f01039be:	74 10                	je     f01039d0 <readline+0x20>
		cprintf("%s", prompt);
f01039c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039c4:	c7 04 24 c8 4e 10 f0 	movl   $0xf0104ec8,(%esp)
f01039cb:	e8 a2 f5 ff ff       	call   f0102f72 <cprintf>

	i = 0;
	echoing = iscons(0);
f01039d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01039d7:	e8 35 cc ff ff       	call   f0100611 <iscons>
f01039dc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01039de:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01039e3:	e8 18 cc ff ff       	call   f0100600 <getchar>
f01039e8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01039ea:	85 c0                	test   %eax,%eax
f01039ec:	79 17                	jns    f0103a05 <readline+0x55>
			cprintf("read error: %e\n", c);
f01039ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039f2:	c7 04 24 98 53 10 f0 	movl   $0xf0105398,(%esp)
f01039f9:	e8 74 f5 ff ff       	call   f0102f72 <cprintf>
			return NULL;
f01039fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a03:	eb 6d                	jmp    f0103a72 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103a05:	83 f8 08             	cmp    $0x8,%eax
f0103a08:	74 05                	je     f0103a0f <readline+0x5f>
f0103a0a:	83 f8 7f             	cmp    $0x7f,%eax
f0103a0d:	75 19                	jne    f0103a28 <readline+0x78>
f0103a0f:	85 f6                	test   %esi,%esi
f0103a11:	7e 15                	jle    f0103a28 <readline+0x78>
			if (echoing)
f0103a13:	85 ff                	test   %edi,%edi
f0103a15:	74 0c                	je     f0103a23 <readline+0x73>
				cputchar('\b');
f0103a17:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103a1e:	e8 cd cb ff ff       	call   f01005f0 <cputchar>
			i--;
f0103a23:	83 ee 01             	sub    $0x1,%esi
f0103a26:	eb bb                	jmp    f01039e3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103a28:	83 fb 1f             	cmp    $0x1f,%ebx
f0103a2b:	7e 1f                	jle    f0103a4c <readline+0x9c>
f0103a2d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103a33:	7f 17                	jg     f0103a4c <readline+0x9c>
			if (echoing)
f0103a35:	85 ff                	test   %edi,%edi
f0103a37:	74 08                	je     f0103a41 <readline+0x91>
				cputchar(c);
f0103a39:	89 1c 24             	mov    %ebx,(%esp)
f0103a3c:	e8 af cb ff ff       	call   f01005f0 <cputchar>
			buf[i++] = c;
f0103a41:	88 9e 80 85 11 f0    	mov    %bl,-0xfee7a80(%esi)
f0103a47:	83 c6 01             	add    $0x1,%esi
f0103a4a:	eb 97                	jmp    f01039e3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103a4c:	83 fb 0a             	cmp    $0xa,%ebx
f0103a4f:	74 05                	je     f0103a56 <readline+0xa6>
f0103a51:	83 fb 0d             	cmp    $0xd,%ebx
f0103a54:	75 8d                	jne    f01039e3 <readline+0x33>
			if (echoing)
f0103a56:	85 ff                	test   %edi,%edi
f0103a58:	74 0c                	je     f0103a66 <readline+0xb6>
				cputchar('\n');
f0103a5a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103a61:	e8 8a cb ff ff       	call   f01005f0 <cputchar>
			buf[i] = 0;
f0103a66:	c6 86 80 85 11 f0 00 	movb   $0x0,-0xfee7a80(%esi)
			return buf;
f0103a6d:	b8 80 85 11 f0       	mov    $0xf0118580,%eax
		}
	}
}
f0103a72:	83 c4 1c             	add    $0x1c,%esp
f0103a75:	5b                   	pop    %ebx
f0103a76:	5e                   	pop    %esi
f0103a77:	5f                   	pop    %edi
f0103a78:	5d                   	pop    %ebp
f0103a79:	c3                   	ret    
f0103a7a:	00 00                	add    %al,(%eax)
f0103a7c:	00 00                	add    %al,(%eax)
	...

f0103a80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103a80:	55                   	push   %ebp
f0103a81:	89 e5                	mov    %esp,%ebp
f0103a83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103a86:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a8b:	80 3a 00             	cmpb   $0x0,(%edx)
f0103a8e:	74 09                	je     f0103a99 <strlen+0x19>
		n++;
f0103a90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103a93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103a97:	75 f7                	jne    f0103a90 <strlen+0x10>
		n++;
	return n;
}
f0103a99:	5d                   	pop    %ebp
f0103a9a:	c3                   	ret    

f0103a9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103a9b:	55                   	push   %ebp
f0103a9c:	89 e5                	mov    %esp,%ebp
f0103a9e:	53                   	push   %ebx
f0103a9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103aa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103aaa:	85 c9                	test   %ecx,%ecx
f0103aac:	74 1a                	je     f0103ac8 <strnlen+0x2d>
f0103aae:	80 3b 00             	cmpb   $0x0,(%ebx)
f0103ab1:	74 15                	je     f0103ac8 <strnlen+0x2d>
f0103ab3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0103ab8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103aba:	39 ca                	cmp    %ecx,%edx
f0103abc:	74 0a                	je     f0103ac8 <strnlen+0x2d>
f0103abe:	83 c2 01             	add    $0x1,%edx
f0103ac1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0103ac6:	75 f0                	jne    f0103ab8 <strnlen+0x1d>
		n++;
	return n;
}
f0103ac8:	5b                   	pop    %ebx
f0103ac9:	5d                   	pop    %ebp
f0103aca:	c3                   	ret    

f0103acb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103acb:	55                   	push   %ebp
f0103acc:	89 e5                	mov    %esp,%ebp
f0103ace:	53                   	push   %ebx
f0103acf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103ad5:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ada:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103ade:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103ae1:	83 c2 01             	add    $0x1,%edx
f0103ae4:	84 c9                	test   %cl,%cl
f0103ae6:	75 f2                	jne    f0103ada <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103ae8:	5b                   	pop    %ebx
f0103ae9:	5d                   	pop    %ebp
f0103aea:	c3                   	ret    

f0103aeb <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103aeb:	55                   	push   %ebp
f0103aec:	89 e5                	mov    %esp,%ebp
f0103aee:	53                   	push   %ebx
f0103aef:	83 ec 08             	sub    $0x8,%esp
f0103af2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103af5:	89 1c 24             	mov    %ebx,(%esp)
f0103af8:	e8 83 ff ff ff       	call   f0103a80 <strlen>
	strcpy(dst + len, src);
f0103afd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b00:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103b04:	01 d8                	add    %ebx,%eax
f0103b06:	89 04 24             	mov    %eax,(%esp)
f0103b09:	e8 bd ff ff ff       	call   f0103acb <strcpy>
	return dst;
}
f0103b0e:	89 d8                	mov    %ebx,%eax
f0103b10:	83 c4 08             	add    $0x8,%esp
f0103b13:	5b                   	pop    %ebx
f0103b14:	5d                   	pop    %ebp
f0103b15:	c3                   	ret    

f0103b16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103b16:	55                   	push   %ebp
f0103b17:	89 e5                	mov    %esp,%ebp
f0103b19:	56                   	push   %esi
f0103b1a:	53                   	push   %ebx
f0103b1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b24:	85 f6                	test   %esi,%esi
f0103b26:	74 18                	je     f0103b40 <strncpy+0x2a>
f0103b28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103b2d:	0f b6 1a             	movzbl (%edx),%ebx
f0103b30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103b33:	80 3a 01             	cmpb   $0x1,(%edx)
f0103b36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b39:	83 c1 01             	add    $0x1,%ecx
f0103b3c:	39 f1                	cmp    %esi,%ecx
f0103b3e:	75 ed                	jne    f0103b2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103b40:	5b                   	pop    %ebx
f0103b41:	5e                   	pop    %esi
f0103b42:	5d                   	pop    %ebp
f0103b43:	c3                   	ret    

f0103b44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103b44:	55                   	push   %ebp
f0103b45:	89 e5                	mov    %esp,%ebp
f0103b47:	57                   	push   %edi
f0103b48:	56                   	push   %esi
f0103b49:	53                   	push   %ebx
f0103b4a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b50:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103b53:	89 f8                	mov    %edi,%eax
f0103b55:	85 f6                	test   %esi,%esi
f0103b57:	74 2b                	je     f0103b84 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0103b59:	83 fe 01             	cmp    $0x1,%esi
f0103b5c:	74 23                	je     f0103b81 <strlcpy+0x3d>
f0103b5e:	0f b6 0b             	movzbl (%ebx),%ecx
f0103b61:	84 c9                	test   %cl,%cl
f0103b63:	74 1c                	je     f0103b81 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103b65:	83 ee 02             	sub    $0x2,%esi
f0103b68:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103b6d:	88 08                	mov    %cl,(%eax)
f0103b6f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103b72:	39 f2                	cmp    %esi,%edx
f0103b74:	74 0b                	je     f0103b81 <strlcpy+0x3d>
f0103b76:	83 c2 01             	add    $0x1,%edx
f0103b79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103b7d:	84 c9                	test   %cl,%cl
f0103b7f:	75 ec                	jne    f0103b6d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0103b81:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103b84:	29 f8                	sub    %edi,%eax
}
f0103b86:	5b                   	pop    %ebx
f0103b87:	5e                   	pop    %esi
f0103b88:	5f                   	pop    %edi
f0103b89:	5d                   	pop    %ebp
f0103b8a:	c3                   	ret    

f0103b8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103b8b:	55                   	push   %ebp
f0103b8c:	89 e5                	mov    %esp,%ebp
f0103b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103b94:	0f b6 01             	movzbl (%ecx),%eax
f0103b97:	84 c0                	test   %al,%al
f0103b99:	74 16                	je     f0103bb1 <strcmp+0x26>
f0103b9b:	3a 02                	cmp    (%edx),%al
f0103b9d:	75 12                	jne    f0103bb1 <strcmp+0x26>
		p++, q++;
f0103b9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103ba2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0103ba6:	84 c0                	test   %al,%al
f0103ba8:	74 07                	je     f0103bb1 <strcmp+0x26>
f0103baa:	83 c1 01             	add    $0x1,%ecx
f0103bad:	3a 02                	cmp    (%edx),%al
f0103baf:	74 ee                	je     f0103b9f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bb1:	0f b6 c0             	movzbl %al,%eax
f0103bb4:	0f b6 12             	movzbl (%edx),%edx
f0103bb7:	29 d0                	sub    %edx,%eax
}
f0103bb9:	5d                   	pop    %ebp
f0103bba:	c3                   	ret    

f0103bbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103bbb:	55                   	push   %ebp
f0103bbc:	89 e5                	mov    %esp,%ebp
f0103bbe:	53                   	push   %ebx
f0103bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bc5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103bcd:	85 d2                	test   %edx,%edx
f0103bcf:	74 28                	je     f0103bf9 <strncmp+0x3e>
f0103bd1:	0f b6 01             	movzbl (%ecx),%eax
f0103bd4:	84 c0                	test   %al,%al
f0103bd6:	74 24                	je     f0103bfc <strncmp+0x41>
f0103bd8:	3a 03                	cmp    (%ebx),%al
f0103bda:	75 20                	jne    f0103bfc <strncmp+0x41>
f0103bdc:	83 ea 01             	sub    $0x1,%edx
f0103bdf:	74 13                	je     f0103bf4 <strncmp+0x39>
		n--, p++, q++;
f0103be1:	83 c1 01             	add    $0x1,%ecx
f0103be4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103be7:	0f b6 01             	movzbl (%ecx),%eax
f0103bea:	84 c0                	test   %al,%al
f0103bec:	74 0e                	je     f0103bfc <strncmp+0x41>
f0103bee:	3a 03                	cmp    (%ebx),%al
f0103bf0:	74 ea                	je     f0103bdc <strncmp+0x21>
f0103bf2:	eb 08                	jmp    f0103bfc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103bf4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103bf9:	5b                   	pop    %ebx
f0103bfa:	5d                   	pop    %ebp
f0103bfb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bfc:	0f b6 01             	movzbl (%ecx),%eax
f0103bff:	0f b6 13             	movzbl (%ebx),%edx
f0103c02:	29 d0                	sub    %edx,%eax
f0103c04:	eb f3                	jmp    f0103bf9 <strncmp+0x3e>

f0103c06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103c06:	55                   	push   %ebp
f0103c07:	89 e5                	mov    %esp,%ebp
f0103c09:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c10:	0f b6 10             	movzbl (%eax),%edx
f0103c13:	84 d2                	test   %dl,%dl
f0103c15:	74 1c                	je     f0103c33 <strchr+0x2d>
		if (*s == c)
f0103c17:	38 ca                	cmp    %cl,%dl
f0103c19:	75 09                	jne    f0103c24 <strchr+0x1e>
f0103c1b:	eb 1b                	jmp    f0103c38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103c1d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0103c20:	38 ca                	cmp    %cl,%dl
f0103c22:	74 14                	je     f0103c38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103c24:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0103c28:	84 d2                	test   %dl,%dl
f0103c2a:	75 f1                	jne    f0103c1d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0103c2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c31:	eb 05                	jmp    f0103c38 <strchr+0x32>
f0103c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c38:	5d                   	pop    %ebp
f0103c39:	c3                   	ret    

f0103c3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103c3a:	55                   	push   %ebp
f0103c3b:	89 e5                	mov    %esp,%ebp
f0103c3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c44:	0f b6 10             	movzbl (%eax),%edx
f0103c47:	84 d2                	test   %dl,%dl
f0103c49:	74 14                	je     f0103c5f <strfind+0x25>
		if (*s == c)
f0103c4b:	38 ca                	cmp    %cl,%dl
f0103c4d:	75 06                	jne    f0103c55 <strfind+0x1b>
f0103c4f:	eb 0e                	jmp    f0103c5f <strfind+0x25>
f0103c51:	38 ca                	cmp    %cl,%dl
f0103c53:	74 0a                	je     f0103c5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103c55:	83 c0 01             	add    $0x1,%eax
f0103c58:	0f b6 10             	movzbl (%eax),%edx
f0103c5b:	84 d2                	test   %dl,%dl
f0103c5d:	75 f2                	jne    f0103c51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103c5f:	5d                   	pop    %ebp
f0103c60:	c3                   	ret    

f0103c61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103c61:	55                   	push   %ebp
f0103c62:	89 e5                	mov    %esp,%ebp
f0103c64:	83 ec 0c             	sub    $0xc,%esp
f0103c67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103c6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103c6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103c70:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c73:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103c79:	85 c9                	test   %ecx,%ecx
f0103c7b:	74 30                	je     f0103cad <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103c7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103c83:	75 25                	jne    f0103caa <memset+0x49>
f0103c85:	f6 c1 03             	test   $0x3,%cl
f0103c88:	75 20                	jne    f0103caa <memset+0x49>
		c &= 0xFF;
f0103c8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103c8d:	89 d3                	mov    %edx,%ebx
f0103c8f:	c1 e3 08             	shl    $0x8,%ebx
f0103c92:	89 d6                	mov    %edx,%esi
f0103c94:	c1 e6 18             	shl    $0x18,%esi
f0103c97:	89 d0                	mov    %edx,%eax
f0103c99:	c1 e0 10             	shl    $0x10,%eax
f0103c9c:	09 f0                	or     %esi,%eax
f0103c9e:	09 d0                	or     %edx,%eax
f0103ca0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103ca2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103ca5:	fc                   	cld    
f0103ca6:	f3 ab                	rep stos %eax,%es:(%edi)
f0103ca8:	eb 03                	jmp    f0103cad <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103caa:	fc                   	cld    
f0103cab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103cad:	89 f8                	mov    %edi,%eax
f0103caf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103cb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103cb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103cb8:	89 ec                	mov    %ebp,%esp
f0103cba:	5d                   	pop    %ebp
f0103cbb:	c3                   	ret    

f0103cbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103cbc:	55                   	push   %ebp
f0103cbd:	89 e5                	mov    %esp,%ebp
f0103cbf:	83 ec 08             	sub    $0x8,%esp
f0103cc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103cc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103cc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ccb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103cce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103cd1:	39 c6                	cmp    %eax,%esi
f0103cd3:	73 36                	jae    f0103d0b <memmove+0x4f>
f0103cd5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103cd8:	39 d0                	cmp    %edx,%eax
f0103cda:	73 2f                	jae    f0103d0b <memmove+0x4f>
		s += n;
		d += n;
f0103cdc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cdf:	f6 c2 03             	test   $0x3,%dl
f0103ce2:	75 1b                	jne    f0103cff <memmove+0x43>
f0103ce4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103cea:	75 13                	jne    f0103cff <memmove+0x43>
f0103cec:	f6 c1 03             	test   $0x3,%cl
f0103cef:	75 0e                	jne    f0103cff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103cf1:	83 ef 04             	sub    $0x4,%edi
f0103cf4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103cf7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103cfa:	fd                   	std    
f0103cfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cfd:	eb 09                	jmp    f0103d08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103cff:	83 ef 01             	sub    $0x1,%edi
f0103d02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103d05:	fd                   	std    
f0103d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103d08:	fc                   	cld    
f0103d09:	eb 20                	jmp    f0103d2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103d0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103d11:	75 13                	jne    f0103d26 <memmove+0x6a>
f0103d13:	a8 03                	test   $0x3,%al
f0103d15:	75 0f                	jne    f0103d26 <memmove+0x6a>
f0103d17:	f6 c1 03             	test   $0x3,%cl
f0103d1a:	75 0a                	jne    f0103d26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103d1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103d1f:	89 c7                	mov    %eax,%edi
f0103d21:	fc                   	cld    
f0103d22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103d24:	eb 05                	jmp    f0103d2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103d26:	89 c7                	mov    %eax,%edi
f0103d28:	fc                   	cld    
f0103d29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103d2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103d2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103d31:	89 ec                	mov    %ebp,%esp
f0103d33:	5d                   	pop    %ebp
f0103d34:	c3                   	ret    

f0103d35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103d35:	55                   	push   %ebp
f0103d36:	89 e5                	mov    %esp,%ebp
f0103d38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103d3b:	8b 45 10             	mov    0x10(%ebp),%eax
f0103d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d49:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d4c:	89 04 24             	mov    %eax,(%esp)
f0103d4f:	e8 68 ff ff ff       	call   f0103cbc <memmove>
}
f0103d54:	c9                   	leave  
f0103d55:	c3                   	ret    

f0103d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103d56:	55                   	push   %ebp
f0103d57:	89 e5                	mov    %esp,%ebp
f0103d59:	57                   	push   %edi
f0103d5a:	56                   	push   %esi
f0103d5b:	53                   	push   %ebx
f0103d5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103d5f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103d62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103d65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d6a:	85 ff                	test   %edi,%edi
f0103d6c:	74 37                	je     f0103da5 <memcmp+0x4f>
		if (*s1 != *s2)
f0103d6e:	0f b6 03             	movzbl (%ebx),%eax
f0103d71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d74:	83 ef 01             	sub    $0x1,%edi
f0103d77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0103d7c:	38 c8                	cmp    %cl,%al
f0103d7e:	74 1c                	je     f0103d9c <memcmp+0x46>
f0103d80:	eb 10                	jmp    f0103d92 <memcmp+0x3c>
f0103d82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0103d87:	83 c2 01             	add    $0x1,%edx
f0103d8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103d8e:	38 c8                	cmp    %cl,%al
f0103d90:	74 0a                	je     f0103d9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0103d92:	0f b6 c0             	movzbl %al,%eax
f0103d95:	0f b6 c9             	movzbl %cl,%ecx
f0103d98:	29 c8                	sub    %ecx,%eax
f0103d9a:	eb 09                	jmp    f0103da5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d9c:	39 fa                	cmp    %edi,%edx
f0103d9e:	75 e2                	jne    f0103d82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103da0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103da5:	5b                   	pop    %ebx
f0103da6:	5e                   	pop    %esi
f0103da7:	5f                   	pop    %edi
f0103da8:	5d                   	pop    %ebp
f0103da9:	c3                   	ret    

f0103daa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103daa:	55                   	push   %ebp
f0103dab:	89 e5                	mov    %esp,%ebp
f0103dad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103db0:	89 c2                	mov    %eax,%edx
f0103db2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103db5:	39 d0                	cmp    %edx,%eax
f0103db7:	73 19                	jae    f0103dd2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103db9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103dbd:	38 08                	cmp    %cl,(%eax)
f0103dbf:	75 06                	jne    f0103dc7 <memfind+0x1d>
f0103dc1:	eb 0f                	jmp    f0103dd2 <memfind+0x28>
f0103dc3:	38 08                	cmp    %cl,(%eax)
f0103dc5:	74 0b                	je     f0103dd2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103dc7:	83 c0 01             	add    $0x1,%eax
f0103dca:	39 d0                	cmp    %edx,%eax
f0103dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103dd0:	75 f1                	jne    f0103dc3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103dd2:	5d                   	pop    %ebp
f0103dd3:	c3                   	ret    

f0103dd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103dd4:	55                   	push   %ebp
f0103dd5:	89 e5                	mov    %esp,%ebp
f0103dd7:	57                   	push   %edi
f0103dd8:	56                   	push   %esi
f0103dd9:	53                   	push   %ebx
f0103dda:	8b 55 08             	mov    0x8(%ebp),%edx
f0103ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103de0:	0f b6 02             	movzbl (%edx),%eax
f0103de3:	3c 20                	cmp    $0x20,%al
f0103de5:	74 04                	je     f0103deb <strtol+0x17>
f0103de7:	3c 09                	cmp    $0x9,%al
f0103de9:	75 0e                	jne    f0103df9 <strtol+0x25>
		s++;
f0103deb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103dee:	0f b6 02             	movzbl (%edx),%eax
f0103df1:	3c 20                	cmp    $0x20,%al
f0103df3:	74 f6                	je     f0103deb <strtol+0x17>
f0103df5:	3c 09                	cmp    $0x9,%al
f0103df7:	74 f2                	je     f0103deb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103df9:	3c 2b                	cmp    $0x2b,%al
f0103dfb:	75 0a                	jne    f0103e07 <strtol+0x33>
		s++;
f0103dfd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103e00:	bf 00 00 00 00       	mov    $0x0,%edi
f0103e05:	eb 10                	jmp    f0103e17 <strtol+0x43>
f0103e07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103e0c:	3c 2d                	cmp    $0x2d,%al
f0103e0e:	75 07                	jne    f0103e17 <strtol+0x43>
		s++, neg = 1;
f0103e10:	83 c2 01             	add    $0x1,%edx
f0103e13:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103e17:	85 db                	test   %ebx,%ebx
f0103e19:	0f 94 c0             	sete   %al
f0103e1c:	74 05                	je     f0103e23 <strtol+0x4f>
f0103e1e:	83 fb 10             	cmp    $0x10,%ebx
f0103e21:	75 15                	jne    f0103e38 <strtol+0x64>
f0103e23:	80 3a 30             	cmpb   $0x30,(%edx)
f0103e26:	75 10                	jne    f0103e38 <strtol+0x64>
f0103e28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103e2c:	75 0a                	jne    f0103e38 <strtol+0x64>
		s += 2, base = 16;
f0103e2e:	83 c2 02             	add    $0x2,%edx
f0103e31:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103e36:	eb 13                	jmp    f0103e4b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0103e38:	84 c0                	test   %al,%al
f0103e3a:	74 0f                	je     f0103e4b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103e3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103e41:	80 3a 30             	cmpb   $0x30,(%edx)
f0103e44:	75 05                	jne    f0103e4b <strtol+0x77>
		s++, base = 8;
f0103e46:	83 c2 01             	add    $0x1,%edx
f0103e49:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0103e4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103e52:	0f b6 0a             	movzbl (%edx),%ecx
f0103e55:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103e58:	80 fb 09             	cmp    $0x9,%bl
f0103e5b:	77 08                	ja     f0103e65 <strtol+0x91>
			dig = *s - '0';
f0103e5d:	0f be c9             	movsbl %cl,%ecx
f0103e60:	83 e9 30             	sub    $0x30,%ecx
f0103e63:	eb 1e                	jmp    f0103e83 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0103e65:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103e68:	80 fb 19             	cmp    $0x19,%bl
f0103e6b:	77 08                	ja     f0103e75 <strtol+0xa1>
			dig = *s - 'a' + 10;
f0103e6d:	0f be c9             	movsbl %cl,%ecx
f0103e70:	83 e9 57             	sub    $0x57,%ecx
f0103e73:	eb 0e                	jmp    f0103e83 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0103e75:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103e78:	80 fb 19             	cmp    $0x19,%bl
f0103e7b:	77 14                	ja     f0103e91 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103e7d:	0f be c9             	movsbl %cl,%ecx
f0103e80:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103e83:	39 f1                	cmp    %esi,%ecx
f0103e85:	7d 0e                	jge    f0103e95 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103e87:	83 c2 01             	add    $0x1,%edx
f0103e8a:	0f af c6             	imul   %esi,%eax
f0103e8d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103e8f:	eb c1                	jmp    f0103e52 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103e91:	89 c1                	mov    %eax,%ecx
f0103e93:	eb 02                	jmp    f0103e97 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103e95:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103e97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e9b:	74 05                	je     f0103ea2 <strtol+0xce>
		*endptr = (char *) s;
f0103e9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ea0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103ea2:	89 ca                	mov    %ecx,%edx
f0103ea4:	f7 da                	neg    %edx
f0103ea6:	85 ff                	test   %edi,%edi
f0103ea8:	0f 45 c2             	cmovne %edx,%eax
}
f0103eab:	5b                   	pop    %ebx
f0103eac:	5e                   	pop    %esi
f0103ead:	5f                   	pop    %edi
f0103eae:	5d                   	pop    %ebp
f0103eaf:	c3                   	ret    

f0103eb0 <__udivdi3>:
f0103eb0:	83 ec 1c             	sub    $0x1c,%esp
f0103eb3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103eb7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0103ebb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0103ebf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103ec3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103ec7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103ecb:	85 ff                	test   %edi,%edi
f0103ecd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103ed1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ed5:	89 cd                	mov    %ecx,%ebp
f0103ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103edb:	75 33                	jne    f0103f10 <__udivdi3+0x60>
f0103edd:	39 f1                	cmp    %esi,%ecx
f0103edf:	77 57                	ja     f0103f38 <__udivdi3+0x88>
f0103ee1:	85 c9                	test   %ecx,%ecx
f0103ee3:	75 0b                	jne    f0103ef0 <__udivdi3+0x40>
f0103ee5:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eea:	31 d2                	xor    %edx,%edx
f0103eec:	f7 f1                	div    %ecx
f0103eee:	89 c1                	mov    %eax,%ecx
f0103ef0:	89 f0                	mov    %esi,%eax
f0103ef2:	31 d2                	xor    %edx,%edx
f0103ef4:	f7 f1                	div    %ecx
f0103ef6:	89 c6                	mov    %eax,%esi
f0103ef8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103efc:	f7 f1                	div    %ecx
f0103efe:	89 f2                	mov    %esi,%edx
f0103f00:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103f04:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103f08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103f0c:	83 c4 1c             	add    $0x1c,%esp
f0103f0f:	c3                   	ret    
f0103f10:	31 d2                	xor    %edx,%edx
f0103f12:	31 c0                	xor    %eax,%eax
f0103f14:	39 f7                	cmp    %esi,%edi
f0103f16:	77 e8                	ja     f0103f00 <__udivdi3+0x50>
f0103f18:	0f bd cf             	bsr    %edi,%ecx
f0103f1b:	83 f1 1f             	xor    $0x1f,%ecx
f0103f1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103f22:	75 2c                	jne    f0103f50 <__udivdi3+0xa0>
f0103f24:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0103f28:	76 04                	jbe    f0103f2e <__udivdi3+0x7e>
f0103f2a:	39 f7                	cmp    %esi,%edi
f0103f2c:	73 d2                	jae    f0103f00 <__udivdi3+0x50>
f0103f2e:	31 d2                	xor    %edx,%edx
f0103f30:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f35:	eb c9                	jmp    f0103f00 <__udivdi3+0x50>
f0103f37:	90                   	nop
f0103f38:	89 f2                	mov    %esi,%edx
f0103f3a:	f7 f1                	div    %ecx
f0103f3c:	31 d2                	xor    %edx,%edx
f0103f3e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103f42:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103f46:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103f4a:	83 c4 1c             	add    $0x1c,%esp
f0103f4d:	c3                   	ret    
f0103f4e:	66 90                	xchg   %ax,%ax
f0103f50:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f55:	b8 20 00 00 00       	mov    $0x20,%eax
f0103f5a:	89 ea                	mov    %ebp,%edx
f0103f5c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103f60:	d3 e7                	shl    %cl,%edi
f0103f62:	89 c1                	mov    %eax,%ecx
f0103f64:	d3 ea                	shr    %cl,%edx
f0103f66:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f6b:	09 fa                	or     %edi,%edx
f0103f6d:	89 f7                	mov    %esi,%edi
f0103f6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f73:	89 f2                	mov    %esi,%edx
f0103f75:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103f79:	d3 e5                	shl    %cl,%ebp
f0103f7b:	89 c1                	mov    %eax,%ecx
f0103f7d:	d3 ef                	shr    %cl,%edi
f0103f7f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f84:	d3 e2                	shl    %cl,%edx
f0103f86:	89 c1                	mov    %eax,%ecx
f0103f88:	d3 ee                	shr    %cl,%esi
f0103f8a:	09 d6                	or     %edx,%esi
f0103f8c:	89 fa                	mov    %edi,%edx
f0103f8e:	89 f0                	mov    %esi,%eax
f0103f90:	f7 74 24 0c          	divl   0xc(%esp)
f0103f94:	89 d7                	mov    %edx,%edi
f0103f96:	89 c6                	mov    %eax,%esi
f0103f98:	f7 e5                	mul    %ebp
f0103f9a:	39 d7                	cmp    %edx,%edi
f0103f9c:	72 22                	jb     f0103fc0 <__udivdi3+0x110>
f0103f9e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0103fa2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103fa7:	d3 e5                	shl    %cl,%ebp
f0103fa9:	39 c5                	cmp    %eax,%ebp
f0103fab:	73 04                	jae    f0103fb1 <__udivdi3+0x101>
f0103fad:	39 d7                	cmp    %edx,%edi
f0103faf:	74 0f                	je     f0103fc0 <__udivdi3+0x110>
f0103fb1:	89 f0                	mov    %esi,%eax
f0103fb3:	31 d2                	xor    %edx,%edx
f0103fb5:	e9 46 ff ff ff       	jmp    f0103f00 <__udivdi3+0x50>
f0103fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103fc0:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103fc3:	31 d2                	xor    %edx,%edx
f0103fc5:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103fc9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103fcd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103fd1:	83 c4 1c             	add    $0x1c,%esp
f0103fd4:	c3                   	ret    
	...

f0103fe0 <__umoddi3>:
f0103fe0:	83 ec 1c             	sub    $0x1c,%esp
f0103fe3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103fe7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0103feb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0103fef:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103ff3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103ff7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103ffb:	85 ed                	test   %ebp,%ebp
f0103ffd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104001:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104005:	89 cf                	mov    %ecx,%edi
f0104007:	89 04 24             	mov    %eax,(%esp)
f010400a:	89 f2                	mov    %esi,%edx
f010400c:	75 1a                	jne    f0104028 <__umoddi3+0x48>
f010400e:	39 f1                	cmp    %esi,%ecx
f0104010:	76 4e                	jbe    f0104060 <__umoddi3+0x80>
f0104012:	f7 f1                	div    %ecx
f0104014:	89 d0                	mov    %edx,%eax
f0104016:	31 d2                	xor    %edx,%edx
f0104018:	8b 74 24 10          	mov    0x10(%esp),%esi
f010401c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104020:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104024:	83 c4 1c             	add    $0x1c,%esp
f0104027:	c3                   	ret    
f0104028:	39 f5                	cmp    %esi,%ebp
f010402a:	77 54                	ja     f0104080 <__umoddi3+0xa0>
f010402c:	0f bd c5             	bsr    %ebp,%eax
f010402f:	83 f0 1f             	xor    $0x1f,%eax
f0104032:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104036:	75 60                	jne    f0104098 <__umoddi3+0xb8>
f0104038:	3b 0c 24             	cmp    (%esp),%ecx
f010403b:	0f 87 07 01 00 00    	ja     f0104148 <__umoddi3+0x168>
f0104041:	89 f2                	mov    %esi,%edx
f0104043:	8b 34 24             	mov    (%esp),%esi
f0104046:	29 ce                	sub    %ecx,%esi
f0104048:	19 ea                	sbb    %ebp,%edx
f010404a:	89 34 24             	mov    %esi,(%esp)
f010404d:	8b 04 24             	mov    (%esp),%eax
f0104050:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104054:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104058:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010405c:	83 c4 1c             	add    $0x1c,%esp
f010405f:	c3                   	ret    
f0104060:	85 c9                	test   %ecx,%ecx
f0104062:	75 0b                	jne    f010406f <__umoddi3+0x8f>
f0104064:	b8 01 00 00 00       	mov    $0x1,%eax
f0104069:	31 d2                	xor    %edx,%edx
f010406b:	f7 f1                	div    %ecx
f010406d:	89 c1                	mov    %eax,%ecx
f010406f:	89 f0                	mov    %esi,%eax
f0104071:	31 d2                	xor    %edx,%edx
f0104073:	f7 f1                	div    %ecx
f0104075:	8b 04 24             	mov    (%esp),%eax
f0104078:	f7 f1                	div    %ecx
f010407a:	eb 98                	jmp    f0104014 <__umoddi3+0x34>
f010407c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104080:	89 f2                	mov    %esi,%edx
f0104082:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104086:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010408a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010408e:	83 c4 1c             	add    $0x1c,%esp
f0104091:	c3                   	ret    
f0104092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104098:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010409d:	89 e8                	mov    %ebp,%eax
f010409f:	bd 20 00 00 00       	mov    $0x20,%ebp
f01040a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01040a8:	89 fa                	mov    %edi,%edx
f01040aa:	d3 e0                	shl    %cl,%eax
f01040ac:	89 e9                	mov    %ebp,%ecx
f01040ae:	d3 ea                	shr    %cl,%edx
f01040b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01040b5:	09 c2                	or     %eax,%edx
f01040b7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01040bb:	89 14 24             	mov    %edx,(%esp)
f01040be:	89 f2                	mov    %esi,%edx
f01040c0:	d3 e7                	shl    %cl,%edi
f01040c2:	89 e9                	mov    %ebp,%ecx
f01040c4:	d3 ea                	shr    %cl,%edx
f01040c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01040cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01040cf:	d3 e6                	shl    %cl,%esi
f01040d1:	89 e9                	mov    %ebp,%ecx
f01040d3:	d3 e8                	shr    %cl,%eax
f01040d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01040da:	09 f0                	or     %esi,%eax
f01040dc:	8b 74 24 08          	mov    0x8(%esp),%esi
f01040e0:	f7 34 24             	divl   (%esp)
f01040e3:	d3 e6                	shl    %cl,%esi
f01040e5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01040e9:	89 d6                	mov    %edx,%esi
f01040eb:	f7 e7                	mul    %edi
f01040ed:	39 d6                	cmp    %edx,%esi
f01040ef:	89 c1                	mov    %eax,%ecx
f01040f1:	89 d7                	mov    %edx,%edi
f01040f3:	72 3f                	jb     f0104134 <__umoddi3+0x154>
f01040f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01040f9:	72 35                	jb     f0104130 <__umoddi3+0x150>
f01040fb:	8b 44 24 08          	mov    0x8(%esp),%eax
f01040ff:	29 c8                	sub    %ecx,%eax
f0104101:	19 fe                	sbb    %edi,%esi
f0104103:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104108:	89 f2                	mov    %esi,%edx
f010410a:	d3 e8                	shr    %cl,%eax
f010410c:	89 e9                	mov    %ebp,%ecx
f010410e:	d3 e2                	shl    %cl,%edx
f0104110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104115:	09 d0                	or     %edx,%eax
f0104117:	89 f2                	mov    %esi,%edx
f0104119:	d3 ea                	shr    %cl,%edx
f010411b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010411f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104123:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104127:	83 c4 1c             	add    $0x1c,%esp
f010412a:	c3                   	ret    
f010412b:	90                   	nop
f010412c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104130:	39 d6                	cmp    %edx,%esi
f0104132:	75 c7                	jne    f01040fb <__umoddi3+0x11b>
f0104134:	89 d7                	mov    %edx,%edi
f0104136:	89 c1                	mov    %eax,%ecx
f0104138:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010413c:	1b 3c 24             	sbb    (%esp),%edi
f010413f:	eb ba                	jmp    f01040fb <__umoddi3+0x11b>
f0104141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104148:	39 f5                	cmp    %esi,%ebp
f010414a:	0f 82 f1 fe ff ff    	jb     f0104041 <__umoddi3+0x61>
f0104150:	e9 f8 fe ff ff       	jmp    f010404d <__umoddi3+0x6d>
