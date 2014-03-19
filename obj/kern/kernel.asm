
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
f0100015:	b8 00 70 11 00       	mov    $0x117000,%eax
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
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

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
f0100046:	b8 90 99 11 f0       	mov    $0xf0119990,%eax
f010004b:	2d 08 93 11 f0       	sub    $0xf0119308,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 08 93 11 f0 	movl   $0xf0119308,(%esp)
f0100063:	e8 79 41 00 00       	call   f01041e1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 8e 04 00 00       	call   f01004fb <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 e0 46 10 f0 	movl   $0xf01046e0,(%esp)
f010007c:	e8 79 34 00 00       	call   f01034fa <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 36 18 00 00       	call   f01018bc <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 ea 0d 00 00       	call   f0100e7c <monitor>
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
f010009f:	83 3d 80 99 11 f0 00 	cmpl   $0x0,0xf0119980
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 80 99 11 f0    	mov    %esi,0xf0119980

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
f01000c1:	c7 04 24 fb 46 10 f0 	movl   $0xf01046fb,(%esp)
f01000c8:	e8 2d 34 00 00       	call   f01034fa <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 ee 33 00 00       	call   f01034c7 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f01000e0:	e8 15 34 00 00       	call   f01034fa <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 8b 0d 00 00       	call   f0100e7c <monitor>
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
f010010b:	c7 04 24 13 47 10 f0 	movl   $0xf0104713,(%esp)
f0100112:	e8 e3 33 00 00       	call   f01034fa <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 a1 33 00 00       	call   f01034c7 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f010012d:	e8 c8 33 00 00       	call   f01034fa <cprintf>
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
f0100179:	8b 15 44 95 11 f0    	mov    0xf0119544,%edx
f010017f:	88 82 40 93 11 f0    	mov    %al,-0xfee6cc0(%edx)
f0100185:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100188:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f010018d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100192:	0f 44 c2             	cmove  %edx,%eax
f0100195:	a3 44 95 11 f0       	mov    %eax,0xf0119544
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
f010021c:	a1 04 93 11 f0       	mov    0xf0119304,%eax
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
f0100262:	0f b7 15 54 95 11 f0 	movzwl 0xf0119554,%edx
f0100269:	66 85 d2             	test   %dx,%dx
f010026c:	0f 84 e3 00 00 00    	je     f0100355 <cons_putc+0x1ae>
			crt_pos--;
f0100272:	83 ea 01             	sub    $0x1,%edx
f0100275:	66 89 15 54 95 11 f0 	mov    %dx,0xf0119554
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010027c:	0f b7 d2             	movzwl %dx,%edx
f010027f:	b0 00                	mov    $0x0,%al
f0100281:	83 c8 20             	or     $0x20,%eax
f0100284:	8b 0d 50 95 11 f0    	mov    0xf0119550,%ecx
f010028a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010028e:	eb 78                	jmp    f0100308 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100290:	66 83 05 54 95 11 f0 	addw   $0x50,0xf0119554
f0100297:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100298:	0f b7 05 54 95 11 f0 	movzwl 0xf0119554,%eax
f010029f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002a5:	c1 e8 16             	shr    $0x16,%eax
f01002a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002ab:	c1 e0 04             	shl    $0x4,%eax
f01002ae:	66 a3 54 95 11 f0    	mov    %ax,0xf0119554
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
f01002ea:	0f b7 15 54 95 11 f0 	movzwl 0xf0119554,%edx
f01002f1:	0f b7 da             	movzwl %dx,%ebx
f01002f4:	8b 0d 50 95 11 f0    	mov    0xf0119550,%ecx
f01002fa:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01002fe:	83 c2 01             	add    $0x1,%edx
f0100301:	66 89 15 54 95 11 f0 	mov    %dx,0xf0119554
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100308:	66 81 3d 54 95 11 f0 	cmpw   $0x7cf,0xf0119554
f010030f:	cf 07 
f0100311:	76 42                	jbe    f0100355 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100313:	a1 50 95 11 f0       	mov    0xf0119550,%eax
f0100318:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010031f:	00 
f0100320:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100326:	89 54 24 04          	mov    %edx,0x4(%esp)
f010032a:	89 04 24             	mov    %eax,(%esp)
f010032d:	e8 0a 3f 00 00       	call   f010423c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100332:	8b 15 50 95 11 f0    	mov    0xf0119550,%edx
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
f010034d:	66 83 2d 54 95 11 f0 	subw   $0x50,0xf0119554
f0100354:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100355:	8b 0d 4c 95 11 f0    	mov    0xf011954c,%ecx
f010035b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100360:	89 ca                	mov    %ecx,%edx
f0100362:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100363:	0f b7 35 54 95 11 f0 	movzwl 0xf0119554,%esi
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
f01003ae:	83 0d 48 95 11 f0 40 	orl    $0x40,0xf0119548
		return 0;
f01003b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ba:	e9 c4 00 00 00       	jmp    f0100483 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003bf:	84 c0                	test   %al,%al
f01003c1:	79 37                	jns    f01003fa <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003c3:	8b 0d 48 95 11 f0    	mov    0xf0119548,%ecx
f01003c9:	89 cb                	mov    %ecx,%ebx
f01003cb:	83 e3 40             	and    $0x40,%ebx
f01003ce:	83 e0 7f             	and    $0x7f,%eax
f01003d1:	85 db                	test   %ebx,%ebx
f01003d3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003d6:	0f b6 d2             	movzbl %dl,%edx
f01003d9:	0f b6 82 60 47 10 f0 	movzbl -0xfefb8a0(%edx),%eax
f01003e0:	83 c8 40             	or     $0x40,%eax
f01003e3:	0f b6 c0             	movzbl %al,%eax
f01003e6:	f7 d0                	not    %eax
f01003e8:	21 c1                	and    %eax,%ecx
f01003ea:	89 0d 48 95 11 f0    	mov    %ecx,0xf0119548
		return 0;
f01003f0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f5:	e9 89 00 00 00       	jmp    f0100483 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01003fa:	8b 0d 48 95 11 f0    	mov    0xf0119548,%ecx
f0100400:	f6 c1 40             	test   $0x40,%cl
f0100403:	74 0e                	je     f0100413 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100405:	89 c2                	mov    %eax,%edx
f0100407:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010040a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010040d:	89 0d 48 95 11 f0    	mov    %ecx,0xf0119548
	}

	shift |= shiftcode[data];
f0100413:	0f b6 d2             	movzbl %dl,%edx
f0100416:	0f b6 82 60 47 10 f0 	movzbl -0xfefb8a0(%edx),%eax
f010041d:	0b 05 48 95 11 f0    	or     0xf0119548,%eax
	shift ^= togglecode[data];
f0100423:	0f b6 8a 60 48 10 f0 	movzbl -0xfefb7a0(%edx),%ecx
f010042a:	31 c8                	xor    %ecx,%eax
f010042c:	a3 48 95 11 f0       	mov    %eax,0xf0119548

	c = charcode[shift & (CTL | SHIFT)][data];
f0100431:	89 c1                	mov    %eax,%ecx
f0100433:	83 e1 03             	and    $0x3,%ecx
f0100436:	8b 0c 8d 60 49 10 f0 	mov    -0xfefb6a0(,%ecx,4),%ecx
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
f010046c:	c7 04 24 2d 47 10 f0 	movl   $0xf010472d,(%esp)
f0100473:	e8 82 30 00 00       	call   f01034fa <cprintf>
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
f0100491:	80 3d 20 93 11 f0 00 	cmpb   $0x0,0xf0119320
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
f01004c8:	8b 15 40 95 11 f0    	mov    0xf0119540,%edx
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
f01004d3:	3b 15 44 95 11 f0    	cmp    0xf0119544,%edx
f01004d9:	74 1e                	je     f01004f9 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004db:	0f b6 82 40 93 11 f0 	movzbl -0xfee6cc0(%edx),%eax
f01004e2:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01004e5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004eb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004f0:	0f 44 d1             	cmove  %ecx,%edx
f01004f3:	89 15 40 95 11 f0    	mov    %edx,0xf0119540
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
f0100521:	c7 05 4c 95 11 f0 b4 	movl   $0x3b4,0xf011954c
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
f0100539:	c7 05 4c 95 11 f0 d4 	movl   $0x3d4,0xf011954c
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
f0100548:	8b 0d 4c 95 11 f0    	mov    0xf011954c,%ecx
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
f010056d:	89 35 50 95 11 f0    	mov    %esi,0xf0119550

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100573:	0f b6 d8             	movzbl %al,%ebx
f0100576:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100578:	66 89 3d 54 95 11 f0 	mov    %di,0xf0119554
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
f01005cb:	a2 20 93 11 f0       	mov    %al,0xf0119320
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
f01005dc:	c7 04 24 39 47 10 f0 	movl   $0xf0104739,(%esp)
f01005e3:	e8 12 2f 00 00       	call   f01034fa <cprintf>
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
f0100626:	c7 04 24 70 49 10 f0 	movl   $0xf0104970,(%esp)
f010062d:	e8 c8 2e 00 00       	call   f01034fa <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100632:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100639:	00 
f010063a:	c7 04 24 fc 4a 10 f0 	movl   $0xf0104afc,(%esp)
f0100641:	e8 b4 2e 00 00       	call   f01034fa <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100646:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010064d:	00 
f010064e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 24 4b 10 f0 	movl   $0xf0104b24,(%esp)
f010065d:	e8 98 2e 00 00       	call   f01034fa <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100662:	c7 44 24 08 d5 46 10 	movl   $0x1046d5,0x8(%esp)
f0100669:	00 
f010066a:	c7 44 24 04 d5 46 10 	movl   $0xf01046d5,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 48 4b 10 f0 	movl   $0xf0104b48,(%esp)
f0100679:	e8 7c 2e 00 00       	call   f01034fa <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010067e:	c7 44 24 08 08 93 11 	movl   $0x119308,0x8(%esp)
f0100685:	00 
f0100686:	c7 44 24 04 08 93 11 	movl   $0xf0119308,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 6c 4b 10 f0 	movl   $0xf0104b6c,(%esp)
f0100695:	e8 60 2e 00 00       	call   f01034fa <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010069a:	c7 44 24 08 90 99 11 	movl   $0x119990,0x8(%esp)
f01006a1:	00 
f01006a2:	c7 44 24 04 90 99 11 	movl   $0xf0119990,0x4(%esp)
f01006a9:	f0 
f01006aa:	c7 04 24 90 4b 10 f0 	movl   $0xf0104b90,(%esp)
f01006b1:	e8 44 2e 00 00       	call   f01034fa <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006b6:	b8 8f 9d 11 f0       	mov    $0xf0119d8f,%eax
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
f01006d7:	c7 04 24 b4 4b 10 f0 	movl   $0xf0104bb4,(%esp)
f01006de:	e8 17 2e 00 00       	call   f01034fa <cprintf>
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
f01006f6:	8b 83 44 4e 10 f0    	mov    -0xfefb1bc(%ebx),%eax
f01006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100700:	8b 83 40 4e 10 f0    	mov    -0xfefb1c0(%ebx),%eax
f0100706:	89 44 24 04          	mov    %eax,0x4(%esp)
f010070a:	c7 04 24 89 49 10 f0 	movl   $0xf0104989,(%esp)
f0100711:	e8 e4 2d 00 00       	call   f01034fa <cprintf>
f0100716:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100719:	83 fb 48             	cmp    $0x48,%ebx
f010071c:	75 d8                	jne    f01006f6 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010071e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100723:	83 c4 14             	add    $0x14,%esp
f0100726:	5b                   	pop    %ebx
f0100727:	5d                   	pop    %ebp
f0100728:	c3                   	ret    

f0100729 <mon_changepermission>:
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
f0100729:	55                   	push   %ebp
f010072a:	89 e5                	mov    %esp,%ebp
f010072c:	57                   	push   %edi
f010072d:	56                   	push   %esi
f010072e:	53                   	push   %ebx
f010072f:	83 ec 2c             	sub    $0x2c,%esp
f0100732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f0100735:	8b 55 08             	mov    0x8(%ebp),%edx
f0100738:	83 ea 03             	sub    $0x3,%edx
		return -1;
f010073b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f0100740:	83 fa 01             	cmp    $0x1,%edx
f0100743:	0f 87 f8 01 00 00    	ja     f0100941 <mon_changepermission+0x218>
		return -1;

	extern pde_t *kern_pgdir;
	unsigned int num = strtol(argv[2], NULL, 16);
f0100749:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100750:	00 
f0100751:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100758:	00 
f0100759:	8b 43 08             	mov    0x8(%ebx),%eax
f010075c:	89 04 24             	mov    %eax,(%esp)
f010075f:	e8 f0 3b 00 00       	call   f0104354 <strtol>
f0100764:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f0100766:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100769:	89 44 24 08          	mov    %eax,0x8(%esp)
f010076d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100771:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0100776:	89 04 24             	mov    %eax,(%esp)
f0100779:	e8 c1 0f 00 00       	call   f010173f <page_lookup>
	if(!pageofva)
f010077e:	85 c0                	test   %eax,%eax
f0100780:	0f 84 b6 01 00 00    	je     f010093c <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f0100786:	c7 44 24 04 92 49 10 	movl   $0xf0104992,0x4(%esp)
f010078d:	f0 
f010078e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100791:	89 04 24             	mov    %eax,(%esp)
f0100794:	e8 72 39 00 00       	call   f010410b <strcmp>
	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;

	unsigned int perm = 0;
f0100799:	bf 00 00 00 00       	mov    $0x0,%edi
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f010079e:	85 c0                	test   %eax,%eax
f01007a0:	75 2e                	jne    f01007d0 <mon_changepermission+0xa7>
		perm = strtol(argv[3], NULL, 16) | PTE_P;
f01007a2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01007a9:	00 
f01007aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01007b1:	00 
f01007b2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01007b5:	89 04 24             	mov    %eax,(%esp)
f01007b8:	e8 97 3b 00 00       	call   f0104354 <strtol>
f01007bd:	89 c7                	mov    %eax,%edi
f01007bf:	83 cf 01             	or     $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f01007c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007c5:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f01007cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007ce:	01 38                	add    %edi,(%eax)
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
f01007d0:	c7 44 24 04 97 49 10 	movl   $0xf0104997,0x4(%esp)
f01007d7:	f0 
f01007d8:	8b 43 04             	mov    0x4(%ebx),%eax
f01007db:	89 04 24             	mov    %eax,(%esp)
f01007de:	e8 28 39 00 00       	call   f010410b <strcmp>
f01007e3:	85 c0                	test   %eax,%eax
f01007e5:	75 14                	jne    f01007fb <mon_changepermission+0xd2>
		perm = 1;
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f01007e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007ea:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f01007f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007f3:	83 00 01             	addl   $0x1,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
		perm = 1;
f01007f6:	bf 01 00 00 00       	mov    $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// change
	if(strcmp(argv[1], "-change") == 0) {
f01007fb:	c7 44 24 04 9e 49 10 	movl   $0xf010499e,0x4(%esp)
f0100802:	f0 
f0100803:	8b 43 04             	mov    0x4(%ebx),%eax
f0100806:	89 04 24             	mov    %eax,(%esp)
f0100809:	e8 fd 38 00 00       	call   f010410b <strcmp>
f010080e:	85 c0                	test   %eax,%eax
f0100810:	0f 85 0b 01 00 00    	jne    f0100921 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f0100816:	c7 44 24 04 8b 58 10 	movl   $0xf010588b,0x4(%esp)
f010081d:	f0 
f010081e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100821:	89 04 24             	mov    %eax,(%esp)
f0100824:	e8 e2 38 00 00       	call   f010410b <strcmp>
f0100829:	85 c0                	test   %eax,%eax
f010082b:	75 06                	jne    f0100833 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f010082d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100830:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f0100833:	c7 44 24 04 9c 58 10 	movl   $0xf010589c,0x4(%esp)
f010083a:	f0 
f010083b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010083e:	89 04 24             	mov    %eax,(%esp)
f0100841:	e8 c5 38 00 00       	call   f010410b <strcmp>
f0100846:	85 c0                	test   %eax,%eax
f0100848:	75 06                	jne    f0100850 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f010084a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010084d:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100850:	c7 44 24 04 a6 49 10 	movl   $0xf01049a6,0x4(%esp)
f0100857:	f0 
f0100858:	8b 43 0c             	mov    0xc(%ebx),%eax
f010085b:	89 04 24             	mov    %eax,(%esp)
f010085e:	e8 a8 38 00 00       	call   f010410b <strcmp>
f0100863:	85 c0                	test   %eax,%eax
f0100865:	75 06                	jne    f010086d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100867:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010086a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f010086d:	c7 44 24 04 ff 57 10 	movl   $0xf01057ff,0x4(%esp)
f0100874:	f0 
f0100875:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100878:	89 04 24             	mov    %eax,(%esp)
f010087b:	e8 8b 38 00 00       	call   f010410b <strcmp>
f0100880:	85 c0                	test   %eax,%eax
f0100882:	75 06                	jne    f010088a <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f0100884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100887:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f010088a:	c7 44 24 04 ae 49 10 	movl   $0xf01049ae,0x4(%esp)
f0100891:	f0 
f0100892:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100895:	89 04 24             	mov    %eax,(%esp)
f0100898:	e8 6e 38 00 00       	call   f010410b <strcmp>
f010089d:	85 c0                	test   %eax,%eax
f010089f:	75 06                	jne    f01008a7 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f01008a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008a4:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f01008a7:	c7 44 24 04 b6 49 10 	movl   $0xf01049b6,0x4(%esp)
f01008ae:	f0 
f01008af:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008b2:	89 04 24             	mov    %eax,(%esp)
f01008b5:	e8 51 38 00 00       	call   f010410b <strcmp>
f01008ba:	85 c0                	test   %eax,%eax
f01008bc:	75 06                	jne    f01008c4 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f01008be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008c1:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f01008c4:	c7 44 24 04 bc 49 10 	movl   $0xf01049bc,0x4(%esp)
f01008cb:	f0 
f01008cc:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008cf:	89 04 24             	mov    %eax,(%esp)
f01008d2:	e8 34 38 00 00       	call   f010410b <strcmp>
f01008d7:	85 c0                	test   %eax,%eax
f01008d9:	75 06                	jne    f01008e1 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f01008db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008de:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f01008e1:	c7 44 24 04 c2 49 10 	movl   $0xf01049c2,0x4(%esp)
f01008e8:	f0 
f01008e9:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008ec:	89 04 24             	mov    %eax,(%esp)
f01008ef:	e8 17 38 00 00       	call   f010410b <strcmp>
f01008f4:	85 c0                	test   %eax,%eax
f01008f6:	75 09                	jne    f0100901 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f01008f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008fb:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100901:	c7 44 24 04 c9 49 10 	movl   $0xf01049c9,0x4(%esp)
f0100908:	f0 
f0100909:	8b 43 0c             	mov    0xc(%ebx),%eax
f010090c:	89 04 24             	mov    %eax,(%esp)
f010090f:	e8 f7 37 00 00       	call   f010410b <strcmp>
f0100914:	85 c0                	test   %eax,%eax
f0100916:	75 09                	jne    f0100921 <mon_changepermission+0x1f8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_G;
f0100918:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010091b:	81 30 00 01 00 00    	xorl   $0x100,(%eax)
	}
	

	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
f0100921:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100925:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100929:	c7 04 24 cf 49 10 f0 	movl   $0xf01049cf,(%esp)
f0100930:	e8 c5 2b 00 00       	call   f01034fa <cprintf>
		num, perm);

	return 0;
f0100935:	b8 00 00 00 00       	mov    $0x0,%eax
f010093a:	eb 05                	jmp    f0100941 <mon_changepermission+0x218>
	unsigned int num = strtol(argv[2], NULL, 16);

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;
f010093c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
		num, perm);

	return 0;
}
f0100941:	83 c4 2c             	add    $0x2c,%esp
f0100944:	5b                   	pop    %ebx
f0100945:	5e                   	pop    %esi
f0100946:	5f                   	pop    %edi
f0100947:	5d                   	pop    %ebp
f0100948:	c3                   	ret    

f0100949 <mon_showmappings>:
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
f0100949:	55                   	push   %ebp
f010094a:	89 e5                	mov    %esp,%ebp
f010094c:	57                   	push   %edi
f010094d:	56                   	push   %esi
f010094e:	53                   	push   %ebx
f010094f:	83 ec 2c             	sub    $0x2c,%esp
f0100952:	8b 75 0c             	mov    0xc(%ebp),%esi
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
		return -1;
f0100955:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
f010095a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010095e:	0f 85 a6 00 00 00    	jne    f0100a0a <mon_showmappings+0xc1>

	// Get the 2 arguments
	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
f0100964:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010096b:	00 
f010096c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100973:	00 
f0100974:	8b 46 04             	mov    0x4(%esi),%eax
f0100977:	89 04 24             	mov    %eax,(%esp)
f010097a:	e8 d5 39 00 00       	call   f0104354 <strtol>
f010097f:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f0100981:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100988:	00 
f0100989:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100990:	00 
f0100991:	8b 46 08             	mov    0x8(%esi),%eax
f0100994:	89 04 24             	mov    %eax,(%esp)
f0100997:	e8 b8 39 00 00       	call   f0104354 <strtol>
f010099c:	89 c7                	mov    %eax,%edi
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f010099e:	b8 00 00 00 00       	mov    $0x0,%eax

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f01009a3:	39 fb                	cmp    %edi,%ebx
f01009a5:	77 63                	ja     f0100a0a <mon_showmappings+0xc1>
		unsigned int _pte;
		struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num[0], (pte_t **)(&_pte));
f01009a7:	8d 75 e4             	lea    -0x1c(%ebp),%esi
f01009aa:	89 74 24 08          	mov    %esi,0x8(%esp)
f01009ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009b2:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01009b7:	89 04 24             	mov    %eax,(%esp)
f01009ba:	e8 80 0d 00 00       	call   f010173f <page_lookup>

		if(!pageofva) {
f01009bf:	85 c0                	test   %eax,%eax
f01009c1:	75 0e                	jne    f01009d1 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f01009c3:	c7 04 24 e0 4b 10 f0 	movl   $0xf0104be0,(%esp)
f01009ca:	e8 2b 2b 00 00       	call   f01034fa <cprintf>
			continue;
f01009cf:	eb 2a                	jmp    f01009fb <mon_showmappings+0xb2>
		}
		pte_t pte = *((pte_t *)_pte);
f01009d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009d4:	8b 00                	mov    (%eax),%eax
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));
f01009d6:	89 c2                	mov    %eax,%edx
f01009d8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
f01009de:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01009e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009ef:	c7 04 24 08 4c 10 f0 	movl   $0xf0104c08,(%esp)
f01009f6:	e8 ff 2a 00 00       	call   f01034fa <cprintf>
f01009fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100a01:	39 df                	cmp    %ebx,%edi
f0100a03:	73 a5                	jae    f01009aa <mon_showmappings+0x61>
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a0a:	83 c4 2c             	add    $0x2c,%esp
f0100a0d:	5b                   	pop    %ebx
f0100a0e:	5e                   	pop    %esi
f0100a0f:	5f                   	pop    %edi
f0100a10:	5d                   	pop    %ebp
f0100a11:	c3                   	ret    

f0100a12 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a12:	55                   	push   %ebp
f0100a13:	89 e5                	mov    %esp,%ebp
f0100a15:	57                   	push   %edi
f0100a16:	56                   	push   %esi
f0100a17:	53                   	push   %ebx
f0100a18:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a1e:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100a20:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100a22:	8b 43 04             	mov    0x4(%ebx),%eax
f0100a25:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f0100a2b:	8b 43 08             	mov    0x8(%ebx),%eax
f0100a2e:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f0100a34:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a37:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f0100a3d:	8b 43 10             	mov    0x10(%ebx),%eax
f0100a40:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f0100a46:	8b 43 14             	mov    0x14(%ebx),%eax
f0100a49:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f0100a4f:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f0100a52:	c7 04 24 eb 49 10 f0 	movl   $0xf01049eb,(%esp)
f0100a59:	e8 9c 2a 00 00       	call   f01034fa <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100a5e:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100a63:	85 db                	test   %ebx,%ebx
f0100a65:	0f 84 f5 00 00 00    	je     f0100b60 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f0100a6b:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100a71:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f0100a77:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100a7d:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100a83:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100a87:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100a8b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100a8f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100a93:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100a99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a9d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100aa1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aa5:	c7 04 24 3c 4c 10 f0 	movl   $0xf0104c3c,(%esp)
f0100aac:	e8 49 2a 00 00       	call   f01034fa <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100ab1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ab8:	89 1c 24             	mov    %ebx,(%esp)
f0100abb:	e8 34 2b 00 00       	call   f01035f4 <debuginfo_eip>
f0100ac0:	85 c0                	test   %eax,%eax
f0100ac2:	0f 88 93 00 00 00    	js     f0100b5b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100ac8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100acb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100acf:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100ad5:	89 04 24             	mov    %eax,(%esp)
f0100ad8:	e8 6e 35 00 00       	call   f010404b <strcpy>

		int eip_line = info.eip_line;
f0100add:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ae0:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f0100ae6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ae9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100aed:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100af0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100af4:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f0100af7:	89 3c 24             	mov    %edi,(%esp)
f0100afa:	e8 97 35 00 00       	call   f0104096 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100aff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b02:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f0100b07:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100b0a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100b0e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100b12:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100b18:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b1c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100b22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b26:	c7 04 24 fd 49 10 f0 	movl   $0xf01049fd,(%esp)
f0100b2d:	e8 c8 29 00 00       	call   f01034fa <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f0100b32:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f0100b34:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f0100b37:	8b 46 08             	mov    0x8(%esi),%eax
f0100b3a:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f0100b40:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f0100b43:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f0100b46:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f0100b49:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100b4c:	85 f6                	test   %esi,%esi
f0100b4e:	0f 85 2f ff ff ff    	jne    f0100a83 <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100b54:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b59:	eb 05                	jmp    f0100b60 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f0100b5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100b60:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f0100b66:	5b                   	pop    %ebx
f0100b67:	5e                   	pop    %esi
f0100b68:	5f                   	pop    %edi
f0100b69:	5d                   	pop    %ebp
f0100b6a:	c3                   	ret    

f0100b6b <mon_dump>:
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100b6b:	55                   	push   %ebp
f0100b6c:	89 e5                	mov    %esp,%ebp
f0100b6e:	57                   	push   %edi
f0100b6f:	56                   	push   %esi
f0100b70:	53                   	push   %ebx
f0100b71:	83 ec 3c             	sub    $0x3c,%esp
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
f0100b74:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b78:	0f 85 ea 02 00 00    	jne    f0100e68 <mon_dump+0x2fd>
		return -1;
	
	unsigned int addr = strtol(argv[2], NULL, 16);
f0100b7e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b85:	00 
f0100b86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b8d:	00 
f0100b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100b91:	8b 42 08             	mov    0x8(%edx),%eax
f0100b94:	89 04 24             	mov    %eax,(%esp)
f0100b97:	e8 b8 37 00 00       	call   f0104354 <strtol>
f0100b9c:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100b9e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100ba5:	00 
f0100ba6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100bad:	00 
f0100bae:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bb1:	8b 42 0c             	mov    0xc(%edx),%eax
f0100bb4:	89 04 24             	mov    %eax,(%esp)
f0100bb7:	e8 98 37 00 00       	call   f0104354 <strtol>
f0100bbc:	89 45 d0             	mov    %eax,-0x30(%ebp)

	if(argv[1][1] == 'v') {
f0100bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bc2:	8b 42 04             	mov    0x4(%edx),%eax
f0100bc5:	80 78 01 76          	cmpb   $0x76,0x1(%eax)
f0100bc9:	0f 85 af 00 00 00    	jne    f0100c7e <mon_dump+0x113>
		int i;
		for(i=0; i<len; i++) {
f0100bcf:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100bd3:	0f 84 a5 00 00 00    	je     f0100c7e <mon_dump+0x113>
f0100bd9:	89 df                	mov    %ebx,%edi
f0100bdb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be0:	be 00 00 00 00       	mov    $0x0,%esi
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100be5:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100be8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100beb:	a8 03                	test   $0x3,%al
f0100bed:	75 10                	jne    f0100bff <mon_dump+0x94>
				cprintf("Virtual Address 0x%08x: ", addr + i*4);
f0100bef:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100bf3:	c7 04 24 14 4a 10 f0 	movl   $0xf0104a14,(%esp)
f0100bfa:	e8 fb 28 00 00       	call   f01034fa <cprintf>

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100bff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c02:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c06:	89 f8                	mov    %edi,%eax
f0100c08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
f0100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c11:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0100c16:	89 04 24             	mov    %eax,(%esp)
f0100c19:	e8 21 0b 00 00       	call   f010173f <page_lookup>
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
			if(_pte && (*(pte_t *)_pte&PTE_P))
f0100c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c21:	85 c0                	test   %eax,%eax
f0100c23:	74 19                	je     f0100c3e <mon_dump+0xd3>
f0100c25:	f6 00 01             	testb  $0x1,(%eax)
f0100c28:	74 14                	je     f0100c3e <mon_dump+0xd3>
				cprintf("0x%08x ", *(uint32_t *)(addr + i*4));
f0100c2a:	8b 07                	mov    (%edi),%eax
f0100c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c30:	c7 04 24 2d 4a 10 f0 	movl   $0xf0104a2d,(%esp)
f0100c37:	e8 be 28 00 00       	call   f01034fa <cprintf>
f0100c3c:	eb 0c                	jmp    f0100c4a <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100c3e:	c7 04 24 35 4a 10 f0 	movl   $0xf0104a35,(%esp)
f0100c45:	e8 b0 28 00 00       	call   f01034fa <cprintf>
			if(i % 4 == 3)
f0100c4a:	89 f0                	mov    %esi,%eax
f0100c4c:	c1 f8 1f             	sar    $0x1f,%eax
f0100c4f:	c1 e8 1e             	shr    $0x1e,%eax
f0100c52:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100c55:	83 e2 03             	and    $0x3,%edx
f0100c58:	29 c2                	sub    %eax,%edx
f0100c5a:	83 fa 03             	cmp    $0x3,%edx
f0100c5d:	75 0c                	jne    f0100c6b <mon_dump+0x100>
				cprintf("\n");
f0100c5f:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f0100c66:	e8 8f 28 00 00       	call   f01034fa <cprintf>
	unsigned int addr = strtol(argv[2], NULL, 16);
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
f0100c6b:	83 c6 01             	add    $0x1,%esi
f0100c6e:	89 f0                	mov    %esi,%eax
f0100c70:	83 c7 04             	add    $0x4,%edi
f0100c73:	39 de                	cmp    %ebx,%esi
f0100c75:	0f 85 70 ff ff ff    	jne    f0100beb <mon_dump+0x80>
f0100c7b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c81:	8b 50 04             	mov    0x4(%eax),%edx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100c84:	b8 00 00 00 00       	mov    $0x0,%eax
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100c89:	80 7a 01 70          	cmpb   $0x70,0x1(%edx)
f0100c8d:	0f 85 e1 01 00 00    	jne    f0100e74 <mon_dump+0x309>
		int i;
		for(i=0; i<len; i++) {
f0100c93:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100c97:	0f 84 d2 01 00 00    	je     f0100e6f <mon_dump+0x304>
f0100c9d:	be 00 00 00 00       	mov    $0x0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ca2:	bf 00 f0 10 f0       	mov    $0xf010f000,%edi
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100ca7:	89 fa                	mov    %edi,%edx
f0100ca9:	f7 da                	neg    %edx
f0100cab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100cae:	a8 03                	test   $0x3,%al
f0100cb0:	75 10                	jne    f0100cc2 <mon_dump+0x157>
				cprintf("Physical Address 0x%08x: ", addr + i*4);
f0100cb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cb6:	c7 04 24 3b 4a 10 f0 	movl   $0xf0104a3b,(%esp)
f0100cbd:	e8 38 28 00 00       	call   f01034fa <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100cc2:	a1 8c 99 11 f0       	mov    0xf011998c,%eax
f0100cc7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ccc:	77 20                	ja     f0100cee <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cd2:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0100cd9:	f0 
f0100cda:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
f0100ce1:	00 
f0100ce2:	c7 04 24 55 4a 10 f0 	movl   $0xf0104a55,(%esp)
f0100ce9:	e8 a6 f3 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100cee:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100cf4:	39 d3                	cmp    %edx,%ebx
f0100cf6:	0f 82 83 00 00 00    	jb     f0100d7f <mon_dump+0x214>
f0100cfc:	8d 90 00 00 40 00    	lea    0x400000(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d02:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100d08:	77 20                	ja     f0100d2a <mon_dump+0x1bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d0a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d0e:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0100d15:	f0 
f0100d16:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
f0100d1d:	00 
f0100d1e:	c7 04 24 55 4a 10 f0 	movl   $0xf0104a55,(%esp)
f0100d25:	e8 6a f3 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d2a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100d30:	39 d3                	cmp    %edx,%ebx
f0100d32:	73 4b                	jae    f0100d7f <mon_dump+0x214>
				cprintf("0x%08x ", *(uint32_t *)(_addr - PADDR((void *)pages + UPAGES)));
f0100d34:	2d 00 00 00 11       	sub    $0x11000000,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d39:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d3e:	77 20                	ja     f0100d60 <mon_dump+0x1f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d44:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0100d4b:	f0 
f0100d4c:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
f0100d53:	00 
f0100d54:	c7 04 24 55 4a 10 f0 	movl   $0xf0104a55,(%esp)
f0100d5b:	e8 34 f3 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d60:	89 da                	mov    %ebx,%edx
f0100d62:	29 c2                	sub    %eax,%edx
f0100d64:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d6e:	c7 04 24 2d 4a 10 f0 	movl   $0xf0104a2d,(%esp)
f0100d75:	e8 80 27 00 00       	call   f01034fa <cprintf>
f0100d7a:	e9 b0 00 00 00       	jmp    f0100e2f <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d7f:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100d85:	77 24                	ja     f0100dab <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d87:	c7 44 24 0c 00 f0 10 	movl   $0xf010f000,0xc(%esp)
f0100d8e:	f0 
f0100d8f:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0100d96:	f0 
f0100d97:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0100d9e:	00 
f0100d9f:	c7 04 24 55 4a 10 f0 	movl   $0xf0104a55,(%esp)
f0100da6:	e8 e9 f2 ff ff       	call   f0100094 <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100dab:	81 fb 00 f0 10 00    	cmp    $0x10f000,%ebx
f0100db1:	72 50                	jb     f0100e03 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100db3:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0100db8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100dbd:	77 20                	ja     f0100ddf <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dc3:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0100dca:	f0 
f0100dcb:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0100dd2:	00 
f0100dd3:	c7 04 24 55 4a 10 f0 	movl   $0xf0104a55,(%esp)
f0100dda:	e8 b5 f2 ff ff       	call   f0100094 <_panic>
f0100ddf:	81 fb 00 70 11 00    	cmp    $0x117000,%ebx
f0100de5:	73 1c                	jae    f0100e03 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100de7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100dea:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100df1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100df5:	c7 04 24 2d 4a 10 f0 	movl   $0xf0104a2d,(%esp)
f0100dfc:	e8 f9 26 00 00       	call   f01034fa <cprintf>
f0100e01:	eb 2c                	jmp    f0100e2f <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100e03:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100e09:	77 18                	ja     f0100e23 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100e0b:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100e11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e15:	c7 04 24 2d 4a 10 f0 	movl   $0xf0104a2d,(%esp)
f0100e1c:	e8 d9 26 00 00       	call   f01034fa <cprintf>
f0100e21:	eb 0c                	jmp    f0100e2f <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100e23:	c7 04 24 35 4a 10 f0 	movl   $0xf0104a35,(%esp)
f0100e2a:	e8 cb 26 00 00       	call   f01034fa <cprintf>
			if(i % 4 == 3)
f0100e2f:	89 f0                	mov    %esi,%eax
f0100e31:	c1 f8 1f             	sar    $0x1f,%eax
f0100e34:	c1 e8 1e             	shr    $0x1e,%eax
f0100e37:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100e3a:	83 e2 03             	and    $0x3,%edx
f0100e3d:	29 c2                	sub    %eax,%edx
f0100e3f:	83 fa 03             	cmp    $0x3,%edx
f0100e42:	75 0c                	jne    f0100e50 <mon_dump+0x2e5>
				cprintf("\n");
f0100e44:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f0100e4b:	e8 aa 26 00 00       	call   f01034fa <cprintf>
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
f0100e50:	83 c6 01             	add    $0x1,%esi
f0100e53:	89 f0                	mov    %esi,%eax
f0100e55:	83 c3 04             	add    $0x4,%ebx
f0100e58:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f0100e5b:	0f 85 4d fe ff ff    	jne    f0100cae <mon_dump+0x143>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e61:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e66:	eb 0c                	jmp    f0100e74 <mon_dump+0x309>
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
		return -1;
f0100e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e6d:	eb 05                	jmp    f0100e74 <mon_dump+0x309>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e74:	83 c4 3c             	add    $0x3c,%esp
f0100e77:	5b                   	pop    %ebx
f0100e78:	5e                   	pop    %esi
f0100e79:	5f                   	pop    %edi
f0100e7a:	5d                   	pop    %ebp
f0100e7b:	c3                   	ret    

f0100e7c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100e7c:	55                   	push   %ebp
f0100e7d:	89 e5                	mov    %esp,%ebp
f0100e7f:	57                   	push   %edi
f0100e80:	56                   	push   %esi
f0100e81:	53                   	push   %ebx
f0100e82:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f0100e85:	c7 04 24 94 4c 10 f0 	movl   $0xf0104c94,(%esp)
f0100e8c:	e8 69 26 00 00       	call   f01034fa <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f0100e91:	c7 04 24 c8 4c 10 f0 	movl   $0xf0104cc8,(%esp)
f0100e98:	e8 5d 26 00 00       	call   f01034fa <cprintf>
    
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
f0100e9d:	c7 04 24 64 4a 10 f0 	movl   $0xf0104a64,(%esp)
f0100ea4:	e8 87 30 00 00       	call   f0103f30 <readline>
f0100ea9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100eab:	85 c0                	test   %eax,%eax
f0100ead:	74 ee                	je     f0100e9d <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100eaf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100eb6:	be 00 00 00 00       	mov    $0x0,%esi
f0100ebb:	eb 06                	jmp    f0100ec3 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100ebd:	c6 03 00             	movb   $0x0,(%ebx)
f0100ec0:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100ec3:	0f b6 03             	movzbl (%ebx),%eax
f0100ec6:	84 c0                	test   %al,%al
f0100ec8:	74 6a                	je     f0100f34 <monitor+0xb8>
f0100eca:	0f be c0             	movsbl %al,%eax
f0100ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ed1:	c7 04 24 68 4a 10 f0 	movl   $0xf0104a68,(%esp)
f0100ed8:	e8 a9 32 00 00       	call   f0104186 <strchr>
f0100edd:	85 c0                	test   %eax,%eax
f0100edf:	75 dc                	jne    f0100ebd <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100ee1:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ee4:	74 4e                	je     f0100f34 <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100ee6:	83 fe 0f             	cmp    $0xf,%esi
f0100ee9:	75 16                	jne    f0100f01 <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100eeb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100ef2:	00 
f0100ef3:	c7 04 24 6d 4a 10 f0 	movl   $0xf0104a6d,(%esp)
f0100efa:	e8 fb 25 00 00       	call   f01034fa <cprintf>
f0100eff:	eb 9c                	jmp    f0100e9d <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100f01:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f05:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f08:	0f b6 03             	movzbl (%ebx),%eax
f0100f0b:	84 c0                	test   %al,%al
f0100f0d:	75 0c                	jne    f0100f1b <monitor+0x9f>
f0100f0f:	eb b2                	jmp    f0100ec3 <monitor+0x47>
			buf++;
f0100f11:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f14:	0f b6 03             	movzbl (%ebx),%eax
f0100f17:	84 c0                	test   %al,%al
f0100f19:	74 a8                	je     f0100ec3 <monitor+0x47>
f0100f1b:	0f be c0             	movsbl %al,%eax
f0100f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f22:	c7 04 24 68 4a 10 f0 	movl   $0xf0104a68,(%esp)
f0100f29:	e8 58 32 00 00       	call   f0104186 <strchr>
f0100f2e:	85 c0                	test   %eax,%eax
f0100f30:	74 df                	je     f0100f11 <monitor+0x95>
f0100f32:	eb 8f                	jmp    f0100ec3 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f0100f34:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f3b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100f3c:	85 f6                	test   %esi,%esi
f0100f3e:	0f 84 59 ff ff ff    	je     f0100e9d <monitor+0x21>
f0100f44:	bb 40 4e 10 f0       	mov    $0xf0104e40,%ebx
f0100f49:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f4e:	8b 03                	mov    (%ebx),%eax
f0100f50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f54:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100f57:	89 04 24             	mov    %eax,(%esp)
f0100f5a:	e8 ac 31 00 00       	call   f010410b <strcmp>
f0100f5f:	85 c0                	test   %eax,%eax
f0100f61:	75 24                	jne    f0100f87 <monitor+0x10b>
			return commands[i].func(argc, argv, tf);
f0100f63:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100f66:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f69:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100f6d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100f70:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f74:	89 34 24             	mov    %esi,(%esp)
f0100f77:	ff 14 85 48 4e 10 f0 	call   *-0xfefb1b8(,%eax,4)
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100f7e:	85 c0                	test   %eax,%eax
f0100f80:	78 28                	js     f0100faa <monitor+0x12e>
f0100f82:	e9 16 ff ff ff       	jmp    f0100e9d <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f87:	83 c7 01             	add    $0x1,%edi
f0100f8a:	83 c3 0c             	add    $0xc,%ebx
f0100f8d:	83 ff 06             	cmp    $0x6,%edi
f0100f90:	75 bc                	jne    f0100f4e <monitor+0xd2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f92:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100f95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f99:	c7 04 24 8a 4a 10 f0 	movl   $0xf0104a8a,(%esp)
f0100fa0:	e8 55 25 00 00       	call   f01034fa <cprintf>
f0100fa5:	e9 f3 fe ff ff       	jmp    f0100e9d <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100faa:	83 c4 5c             	add    $0x5c,%esp
f0100fad:	5b                   	pop    %ebx
f0100fae:	5e                   	pop    %esi
f0100faf:	5f                   	pop    %edi
f0100fb0:	5d                   	pop    %ebp
f0100fb1:	c3                   	ret    
	...

f0100fb4 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100fb4:	55                   	push   %ebp
f0100fb5:	89 e5                	mov    %esp,%ebp
f0100fb7:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100fba:	89 d1                	mov    %edx,%ecx
f0100fbc:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100fbf:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100fc7:	f6 c1 01             	test   $0x1,%cl
f0100fca:	74 57                	je     f0101023 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100fcc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd2:	89 c8                	mov    %ecx,%eax
f0100fd4:	c1 e8 0c             	shr    $0xc,%eax
f0100fd7:	3b 05 84 99 11 f0    	cmp    0xf0119984,%eax
f0100fdd:	72 20                	jb     f0100fff <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fdf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100fe3:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0100fea:	f0 
f0100feb:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0100ff2:	00 
f0100ff3:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0100ffa:	e8 95 f0 ff ff       	call   f0100094 <_panic>
	//cprintf("**%x\n", p);
	if (!(p[PTX(va)] & PTE_P))
f0100fff:	c1 ea 0c             	shr    $0xc,%edx
f0101002:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101008:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f010100f:	89 c2                	mov    %eax,%edx
f0101011:	83 e2 01             	and    $0x1,%edx
		return ~0;
	//cprintf("**%x\n\n", p[PTX(va)]);
	return PTE_ADDR(p[PTX(va)]);
f0101014:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101019:	85 d2                	test   %edx,%edx
f010101b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0101020:	0f 44 c2             	cmove  %edx,%eax
}
f0101023:	c9                   	leave  
f0101024:	c3                   	ret    

f0101025 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101025:	55                   	push   %ebp
f0101026:	89 e5                	mov    %esp,%ebp
f0101028:	83 ec 18             	sub    $0x18,%esp
f010102b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010102e:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101031:	83 3d 5c 95 11 f0 00 	cmpl   $0x0,0xf011955c
f0101038:	75 11                	jne    f010104b <boot_alloc+0x26>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010103a:	ba 8f a9 11 f0       	mov    $0xf011a98f,%edx
f010103f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101045:	89 15 5c 95 11 f0    	mov    %edx,0xf011955c
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f010104b:	83 3d 00 93 11 f0 ff 	cmpl   $0xffffffff,0xf0119300
f0101052:	75 0c                	jne    f0101060 <boot_alloc+0x3b>
		npages_left = npages;
f0101054:	8b 15 84 99 11 f0    	mov    0xf0119984,%edx
f010105a:	89 15 00 93 11 f0    	mov    %edx,0xf0119300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f0101060:	85 c0                	test   %eax,%eax
f0101062:	75 2c                	jne    f0101090 <boot_alloc+0x6b>
// !- Whether I should check here -!
		if(npages_left < 1) {
f0101064:	83 3d 00 93 11 f0 00 	cmpl   $0x0,0xf0119300
f010106b:	75 1c                	jne    f0101089 <boot_alloc+0x64>
			panic("Out of memory!\n");
f010106d:	c7 44 24 08 d4 55 10 	movl   $0xf01055d4,0x8(%esp)
f0101074:	f0 
f0101075:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f010107c:	00 
f010107d:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101084:	e8 0b f0 ff ff       	call   f0100094 <_panic>
		}
		result = nextfree;
f0101089:	a1 5c 95 11 f0       	mov    0xf011955c,%eax
f010108e:	eb 5c                	jmp    f01010ec <boot_alloc+0xc7>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f0101090:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f0101096:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		cprintf("Request %u\n", srequest/PGSIZE);
f010109c:	89 f3                	mov    %esi,%ebx
f010109e:	c1 eb 0c             	shr    $0xc,%ebx
f01010a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010a5:	c7 04 24 e4 55 10 f0 	movl   $0xf01055e4,(%esp)
f01010ac:	e8 49 24 00 00       	call   f01034fa <cprintf>

		if(npages_left < srequest/PGSIZE) {
f01010b1:	8b 15 00 93 11 f0    	mov    0xf0119300,%edx
f01010b7:	39 d3                	cmp    %edx,%ebx
f01010b9:	76 1c                	jbe    f01010d7 <boot_alloc+0xb2>
			panic("Out of memory!\n");
f01010bb:	c7 44 24 08 d4 55 10 	movl   $0xf01055d4,0x8(%esp)
f01010c2:	f0 
f01010c3:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
f01010ca:	00 
f01010cb:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01010d2:	e8 bd ef ff ff       	call   f0100094 <_panic>
		}
		result = nextfree;
f01010d7:	a1 5c 95 11 f0       	mov    0xf011955c,%eax
		nextfree += srequest;
f01010dc:	01 c6                	add    %eax,%esi
f01010de:	89 35 5c 95 11 f0    	mov    %esi,0xf011955c
		npages_left -= srequest/PGSIZE;
f01010e4:	29 da                	sub    %ebx,%edx
f01010e6:	89 15 00 93 11 f0    	mov    %edx,0xf0119300

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
	//******************************My code ends***********************************//
}
f01010ec:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01010ef:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01010f2:	89 ec                	mov    %ebp,%esp
f01010f4:	5d                   	pop    %ebp
f01010f5:	c3                   	ret    

f01010f6 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01010f6:	55                   	push   %ebp
f01010f7:	89 e5                	mov    %esp,%ebp
f01010f9:	83 ec 18             	sub    $0x18,%esp
f01010fc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01010ff:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101102:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101104:	89 04 24             	mov    %eax,(%esp)
f0101107:	e8 80 23 00 00       	call   f010348c <mc146818_read>
f010110c:	89 c6                	mov    %eax,%esi
f010110e:	83 c3 01             	add    $0x1,%ebx
f0101111:	89 1c 24             	mov    %ebx,(%esp)
f0101114:	e8 73 23 00 00       	call   f010348c <mc146818_read>
f0101119:	c1 e0 08             	shl    $0x8,%eax
f010111c:	09 f0                	or     %esi,%eax
}
f010111e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101121:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101124:	89 ec                	mov    %ebp,%esp
f0101126:	5d                   	pop    %ebp
f0101127:	c3                   	ret    

f0101128 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101128:	55                   	push   %ebp
f0101129:	89 e5                	mov    %esp,%ebp
f010112b:	57                   	push   %edi
f010112c:	56                   	push   %esi
f010112d:	53                   	push   %ebx
f010112e:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101131:	3c 01                	cmp    $0x1,%al
f0101133:	19 f6                	sbb    %esi,%esi
f0101135:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010113b:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010113e:	8b 1d 60 95 11 f0    	mov    0xf0119560,%ebx
f0101144:	85 db                	test   %ebx,%ebx
f0101146:	75 1c                	jne    f0101164 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0101148:	c7 44 24 08 ac 4e 10 	movl   $0xf0104eac,0x8(%esp)
f010114f:	f0 
f0101150:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f0101157:	00 
f0101158:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010115f:	e8 30 ef ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
f0101164:	84 c0                	test   %al,%al
f0101166:	74 50                	je     f01011b8 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101168:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010116b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010116e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101171:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101174:	89 d8                	mov    %ebx,%eax
f0101176:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f010117c:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010117f:	c1 e8 16             	shr    $0x16,%eax
f0101182:	39 c6                	cmp    %eax,%esi
f0101184:	0f 96 c0             	setbe  %al
f0101187:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010118a:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f010118e:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101190:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101194:	8b 1b                	mov    (%ebx),%ebx
f0101196:	85 db                	test   %ebx,%ebx
f0101198:	75 da                	jne    f0101174 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010119a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010119d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01011a9:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011ae:	89 1d 60 95 11 f0    	mov    %ebx,0xf0119560
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01011b4:	85 db                	test   %ebx,%ebx
f01011b6:	74 67                	je     f010121f <check_page_free_list+0xf7>
f01011b8:	89 d8                	mov    %ebx,%eax
f01011ba:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f01011c0:	c1 f8 03             	sar    $0x3,%eax
f01011c3:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01011c6:	89 c2                	mov    %eax,%edx
f01011c8:	c1 ea 16             	shr    $0x16,%edx
f01011cb:	39 d6                	cmp    %edx,%esi
f01011cd:	76 4a                	jbe    f0101219 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011cf:	89 c2                	mov    %eax,%edx
f01011d1:	c1 ea 0c             	shr    $0xc,%edx
f01011d4:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f01011da:	72 20                	jb     f01011fc <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011e0:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f01011e7:	f0 
f01011e8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011ef:	00 
f01011f0:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f01011f7:	e8 98 ee ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01011fc:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101203:	00 
f0101204:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f010120b:	00 
	return (void *)(pa + KERNBASE);
f010120c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101211:	89 04 24             	mov    %eax,(%esp)
f0101214:	e8 c8 2f 00 00       	call   f01041e1 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101219:	8b 1b                	mov    (%ebx),%ebx
f010121b:	85 db                	test   %ebx,%ebx
f010121d:	75 99                	jne    f01011b8 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f010121f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101224:	e8 fc fd ff ff       	call   f0101025 <boot_alloc>
f0101229:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010122c:	8b 15 60 95 11 f0    	mov    0xf0119560,%edx
f0101232:	85 d2                	test   %edx,%edx
f0101234:	0f 84 f6 01 00 00    	je     f0101430 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010123a:	8b 1d 8c 99 11 f0    	mov    0xf011998c,%ebx
f0101240:	39 da                	cmp    %ebx,%edx
f0101242:	72 4d                	jb     f0101291 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f0101244:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0101249:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010124c:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f010124f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101252:	39 c2                	cmp    %eax,%edx
f0101254:	73 64                	jae    f01012ba <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101256:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101259:	89 d0                	mov    %edx,%eax
f010125b:	29 d8                	sub    %ebx,%eax
f010125d:	a8 07                	test   $0x7,%al
f010125f:	0f 85 82 00 00 00    	jne    f01012e7 <check_page_free_list+0x1bf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101265:	c1 f8 03             	sar    $0x3,%eax
f0101268:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010126b:	85 c0                	test   %eax,%eax
f010126d:	0f 84 a2 00 00 00    	je     f0101315 <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f0101273:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101278:	0f 84 c2 00 00 00    	je     f0101340 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010127e:	be 00 00 00 00       	mov    $0x0,%esi
f0101283:	bf 00 00 00 00       	mov    $0x0,%edi
f0101288:	e9 d7 00 00 00       	jmp    f0101364 <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010128d:	39 da                	cmp    %ebx,%edx
f010128f:	73 24                	jae    f01012b5 <check_page_free_list+0x18d>
f0101291:	c7 44 24 0c fe 55 10 	movl   $0xf01055fe,0xc(%esp)
f0101298:	f0 
f0101299:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01012a0:	f0 
f01012a1:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f01012a8:	00 
f01012a9:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01012b0:	e8 df ed ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f01012b5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01012b8:	72 24                	jb     f01012de <check_page_free_list+0x1b6>
f01012ba:	c7 44 24 0c 1f 56 10 	movl   $0xf010561f,0xc(%esp)
f01012c1:	f0 
f01012c2:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01012c9:	f0 
f01012ca:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f01012d1:	00 
f01012d2:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01012d9:	e8 b6 ed ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012de:	89 d0                	mov    %edx,%eax
f01012e0:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01012e3:	a8 07                	test   $0x7,%al
f01012e5:	74 24                	je     f010130b <check_page_free_list+0x1e3>
f01012e7:	c7 44 24 0c d0 4e 10 	movl   $0xf0104ed0,0xc(%esp)
f01012ee:	f0 
f01012ef:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01012f6:	f0 
f01012f7:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f01012fe:	00 
f01012ff:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101306:	e8 89 ed ff ff       	call   f0100094 <_panic>
f010130b:	c1 f8 03             	sar    $0x3,%eax
f010130e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101311:	85 c0                	test   %eax,%eax
f0101313:	75 24                	jne    f0101339 <check_page_free_list+0x211>
f0101315:	c7 44 24 0c 33 56 10 	movl   $0xf0105633,0xc(%esp)
f010131c:	f0 
f010131d:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101324:	f0 
f0101325:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f010132c:	00 
f010132d:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101334:	e8 5b ed ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101339:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010133e:	75 24                	jne    f0101364 <check_page_free_list+0x23c>
f0101340:	c7 44 24 0c 44 56 10 	movl   $0xf0105644,0xc(%esp)
f0101347:	f0 
f0101348:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010134f:	f0 
f0101350:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f0101357:	00 
f0101358:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010135f:	e8 30 ed ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101364:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101369:	75 24                	jne    f010138f <check_page_free_list+0x267>
f010136b:	c7 44 24 0c 04 4f 10 	movl   $0xf0104f04,0xc(%esp)
f0101372:	f0 
f0101373:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010137a:	f0 
f010137b:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0101382:	00 
f0101383:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010138a:	e8 05 ed ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010138f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101394:	75 24                	jne    f01013ba <check_page_free_list+0x292>
f0101396:	c7 44 24 0c 5d 56 10 	movl   $0xf010565d,0xc(%esp)
f010139d:	f0 
f010139e:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01013a5:	f0 
f01013a6:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f01013ad:	00 
f01013ae:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01013b5:	e8 da ec ff ff       	call   f0100094 <_panic>
f01013ba:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01013bc:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01013c1:	76 57                	jbe    f010141a <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013c3:	c1 e8 0c             	shr    $0xc,%eax
f01013c6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01013c9:	77 20                	ja     f01013eb <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013cb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01013cf:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f01013d6:	f0 
f01013d7:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01013de:	00 
f01013df:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f01013e6:	e8 a9 ec ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01013eb:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f01013f1:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01013f4:	76 29                	jbe    f010141f <check_page_free_list+0x2f7>
f01013f6:	c7 44 24 0c 28 4f 10 	movl   $0xf0104f28,0xc(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101405:	f0 
f0101406:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
f010140d:	00 
f010140e:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101415:	e8 7a ec ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010141a:	83 c7 01             	add    $0x1,%edi
f010141d:	eb 03                	jmp    f0101422 <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f010141f:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101422:	8b 12                	mov    (%edx),%edx
f0101424:	85 d2                	test   %edx,%edx
f0101426:	0f 85 61 fe ff ff    	jne    f010128d <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010142c:	85 ff                	test   %edi,%edi
f010142e:	7f 24                	jg     f0101454 <check_page_free_list+0x32c>
f0101430:	c7 44 24 0c 77 56 10 	movl   $0xf0105677,0xc(%esp)
f0101437:	f0 
f0101438:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010143f:	f0 
f0101440:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f0101447:	00 
f0101448:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010144f:	e8 40 ec ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0101454:	85 f6                	test   %esi,%esi
f0101456:	7f 24                	jg     f010147c <check_page_free_list+0x354>
f0101458:	c7 44 24 0c 89 56 10 	movl   $0xf0105689,0xc(%esp)
f010145f:	f0 
f0101460:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101467:	f0 
f0101468:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f010146f:	00 
f0101470:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101477:	e8 18 ec ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f010147c:	c7 04 24 70 4f 10 f0 	movl   $0xf0104f70,(%esp)
f0101483:	e8 72 20 00 00       	call   f01034fa <cprintf>
}
f0101488:	83 c4 3c             	add    $0x3c,%esp
f010148b:	5b                   	pop    %ebx
f010148c:	5e                   	pop    %esi
f010148d:	5f                   	pop    %edi
f010148e:	5d                   	pop    %ebp
f010148f:	c3                   	ret    

f0101490 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101490:	55                   	push   %ebp
f0101491:	89 e5                	mov    %esp,%ebp
f0101493:	57                   	push   %edi
f0101494:	56                   	push   %esi
f0101495:	53                   	push   %ebx
f0101496:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101499:	83 3d 84 99 11 f0 00 	cmpl   $0x0,0xf0119984
f01014a0:	0f 85 98 00 00 00    	jne    f010153e <page_init+0xae>
f01014a6:	e9 a5 00 00 00       	jmp    f0101550 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f01014ab:	a1 8c 99 11 f0       	mov    0xf011998c,%eax
f01014b0:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f01014b7:	8d 3c 30             	lea    (%eax,%esi,1),%edi
f01014ba:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f01014c0:	85 db                	test   %ebx,%ebx
f01014c2:	74 69                	je     f010152d <page_init+0x9d>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014c4:	29 c7                	sub    %eax,%edi
f01014c6:	c1 ff 03             	sar    $0x3,%edi
f01014c9:	c1 e7 0c             	shl    $0xc,%edi
		// 4) Then extended memory [EXTPHYSMEM, ...).
		// extended memory: 0x100000~
		//   0x100000~0x115000 is allocated to kernel(0x115000 is the end of .bss segment)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		if(page2pa(&pages[i]) >= IOPHYSMEM
f01014cc:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f01014d2:	76 3f                	jbe    f0101513 <page_init+0x83>
			&& page2pa(&pages[i]) < ROUNDUP(PADDR(boot_alloc(0)), PGSIZE)) {	
f01014d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01014d9:	e8 47 fb ff ff       	call   f0101025 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014e3:	77 20                	ja     f0101505 <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014e9:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f01014f0:	f0 
f01014f1:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
f01014f8:	00 
f01014f9:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101500:	e8 8f eb ff ff       	call   f0100094 <_panic>
f0101505:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f010150a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010150f:	39 f8                	cmp    %edi,%eax
f0101511:	77 1a                	ja     f010152d <page_init+0x9d>
			continue;	
		}
		
		// others is free
		pages[i].pp_link = page_free_list;
f0101513:	8b 15 60 95 11 f0    	mov    0xf0119560,%edx
f0101519:	a1 8c 99 11 f0       	mov    0xf011998c,%eax
f010151e:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f0101521:	03 35 8c 99 11 f0    	add    0xf011998c,%esi
f0101527:	89 35 60 95 11 f0    	mov    %esi,0xf0119560
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f010152d:	83 c3 01             	add    $0x1,%ebx
f0101530:	39 1d 84 99 11 f0    	cmp    %ebx,0xf0119984
f0101536:	0f 87 6f ff ff ff    	ja     f01014ab <page_init+0x1b>
f010153c:	eb 12                	jmp    f0101550 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f010153e:	a1 8c 99 11 f0       	mov    0xf011998c,%eax
f0101543:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101549:	bb 00 00 00 00       	mov    $0x0,%ebx
f010154e:	eb dd                	jmp    f010152d <page_init+0x9d>
		
		// others is free
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0101550:	83 c4 1c             	add    $0x1c,%esp
f0101553:	5b                   	pop    %ebx
f0101554:	5e                   	pop    %esi
f0101555:	5f                   	pop    %edi
f0101556:	5d                   	pop    %ebp
f0101557:	c3                   	ret    

f0101558 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101558:	55                   	push   %ebp
f0101559:	89 e5                	mov    %esp,%ebp
f010155b:	53                   	push   %ebx
f010155c:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in

	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	struct PageInfo *result = NULL;
	if(page_free_list) {
f010155f:	8b 1d 60 95 11 f0    	mov    0xf0119560,%ebx
f0101565:	85 db                	test   %ebx,%ebx
f0101567:	74 65                	je     f01015ce <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101569:	8b 03                	mov    (%ebx),%eax
f010156b:	a3 60 95 11 f0       	mov    %eax,0xf0119560
		
		if(alloc_flags & ALLOC_ZERO) { 
f0101570:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101574:	74 58                	je     f01015ce <page_alloc+0x76>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101576:	89 d8                	mov    %ebx,%eax
f0101578:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f010157e:	c1 f8 03             	sar    $0x3,%eax
f0101581:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101584:	89 c2                	mov    %eax,%edx
f0101586:	c1 ea 0c             	shr    $0xc,%edx
f0101589:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f010158f:	72 20                	jb     f01015b1 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101591:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101595:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f010159c:	f0 
f010159d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01015a4:	00 
f01015a5:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f01015ac:	e8 e3 ea ff ff       	call   f0100094 <_panic>
			// fill in '\0'
			memset(page2kva(result), 0, PGSIZE);
f01015b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015b8:	00 
f01015b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015c0:	00 
	return (void *)(pa + KERNBASE);
f01015c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015c6:	89 04 24             	mov    %eax,(%esp)
f01015c9:	e8 13 2c 00 00       	call   f01041e1 <memset>
		}
	}
	return result;
}
f01015ce:	89 d8                	mov    %ebx,%eax
f01015d0:	83 c4 14             	add    $0x14,%esp
f01015d3:	5b                   	pop    %ebx
f01015d4:	5d                   	pop    %ebp
f01015d5:	c3                   	ret    

f01015d6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01015d6:	55                   	push   %ebp
f01015d7:	89 e5                	mov    %esp,%ebp
f01015d9:	83 ec 18             	sub    $0x18,%esp
f01015dc:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(!pp)
f01015df:	85 c0                	test   %eax,%eax
f01015e1:	75 1c                	jne    f01015ff <page_free+0x29>
		panic("page_free: invalid page to free!\n");
f01015e3:	c7 44 24 08 94 4f 10 	movl   $0xf0104f94,0x8(%esp)
f01015ea:	f0 
f01015eb:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f01015f2:	00 
f01015f3:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01015fa:	e8 95 ea ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f01015ff:	8b 15 60 95 11 f0    	mov    0xf0119560,%edx
f0101605:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101607:	a3 60 95 11 f0       	mov    %eax,0xf0119560
}
f010160c:	c9                   	leave  
f010160d:	c3                   	ret    

f010160e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010160e:	55                   	push   %ebp
f010160f:	89 e5                	mov    %esp,%ebp
f0101611:	83 ec 18             	sub    $0x18,%esp
f0101614:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101617:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f010161b:	83 ea 01             	sub    $0x1,%edx
f010161e:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101622:	66 85 d2             	test   %dx,%dx
f0101625:	75 08                	jne    f010162f <page_decref+0x21>
		page_free(pp);
f0101627:	89 04 24             	mov    %eax,(%esp)
f010162a:	e8 a7 ff ff ff       	call   f01015d6 <page_free>
}
f010162f:	c9                   	leave  
f0101630:	c3                   	ret    

f0101631 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101631:	55                   	push   %ebp
f0101632:	89 e5                	mov    %esp,%ebp
f0101634:	56                   	push   %esi
f0101635:	53                   	push   %ebx
f0101636:	83 ec 10             	sub    $0x10,%esp
f0101639:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
f010163c:	89 f3                	mov    %esi,%ebx
f010163e:	c1 eb 16             	shr    $0x16,%ebx
	uintptr_t ptx = PTX(va);
	uintptr_t pgoff = PGOFF(va);

	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];
f0101641:	c1 e3 02             	shl    $0x2,%ebx
f0101644:	03 5d 08             	add    0x8(%ebp),%ebx

	if(((*pde) & PTE_P) == 0) {
f0101647:	f6 03 01             	testb  $0x1,(%ebx)
f010164a:	75 2c                	jne    f0101678 <pgdir_walk+0x47>
		if(create == 0) 
f010164c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101650:	74 6c                	je     f01016be <pgdir_walk+0x8d>
			return NULL;
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
f0101652:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101659:	e8 fa fe ff ff       	call   f0101558 <page_alloc>
			if(pgtbl == NULL)
f010165e:	85 c0                	test   %eax,%eax
f0101660:	74 63                	je     f01016c5 <pgdir_walk+0x94>
				return NULL;
			else {
				pgtbl->pp_ref ++;
f0101662:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101667:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f010166d:	c1 f8 03             	sar    $0x3,%eax
f0101670:	c1 e0 0c             	shl    $0xc,%eax
				/* store in physical address*/
				*pde = page2pa(pgtbl) | PTE_U | PTE_W | PTE_P;
f0101673:	83 c8 07             	or     $0x7,%eax
f0101676:	89 03                	mov    %eax,(%ebx)
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f0101678:	8b 03                	mov    (%ebx),%eax
f010167a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010167f:	89 c2                	mov    %eax,%edx
f0101681:	c1 ea 0c             	shr    $0xc,%edx
f0101684:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f010168a:	72 20                	jb     f01016ac <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010168c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101690:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0101697:	f0 
f0101698:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
f010169f:	00 
f01016a0:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01016a7:	e8 e8 e9 ff ff       	call   f0100094 <_panic>
{
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
	uintptr_t ptx = PTX(va);
f01016ac:	c1 ee 0a             	shr    $0xa,%esi
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01016af:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01016b5:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return pte;
f01016bc:	eb 0c                	jmp    f01016ca <pgdir_walk+0x99>
	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];

	if(((*pde) & PTE_P) == 0) {
		if(create == 0) 
			return NULL;
f01016be:	b8 00 00 00 00       	mov    $0x0,%eax
f01016c3:	eb 05                	jmp    f01016ca <pgdir_walk+0x99>
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
			if(pgtbl == NULL)
				return NULL;
f01016c5:	b8 00 00 00 00       	mov    $0x0,%eax
	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;

	return pte;
}
f01016ca:	83 c4 10             	add    $0x10,%esp
f01016cd:	5b                   	pop    %ebx
f01016ce:	5e                   	pop    %esi
f01016cf:	5d                   	pop    %ebp
f01016d0:	c3                   	ret    

f01016d1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01016d1:	55                   	push   %ebp
f01016d2:	89 e5                	mov    %esp,%ebp
f01016d4:	57                   	push   %edi
f01016d5:	56                   	push   %esi
f01016d6:	53                   	push   %ebx
f01016d7:	83 ec 2c             	sub    $0x2c,%esp
f01016da:	89 c7                	mov    %eax,%edi
f01016dc:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01016df:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01016e5:	c1 e9 0c             	shr    $0xc,%ecx
f01016e8:	85 c9                	test   %ecx,%ecx
f01016ea:	74 4b                	je     f0101737 <boot_map_region+0x66>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01016ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f01016ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f01016f4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f01016fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101700:	83 c8 01             	or     $0x1,%eax
f0101703:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f0101706:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010170d:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f010170e:	89 d8                	mov    %ebx,%eax
f0101710:	c1 e0 0c             	shl    $0xc,%eax

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f0101713:	03 45 e0             	add    -0x20(%ebp),%eax
f0101716:	89 44 24 04          	mov    %eax,0x4(%esp)
f010171a:	89 3c 24             	mov    %edi,(%esp)
f010171d:	e8 0f ff ff ff       	call   f0101631 <pgdir_walk>
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f0101722:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101725:	09 f2                	or     %esi,%edx
f0101727:	89 10                	mov    %edx,(%eax)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101729:	83 c3 01             	add    $0x1,%ebx
f010172c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101732:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101735:	75 cf                	jne    f0101706 <boot_map_region+0x35>
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
	}
}
f0101737:	83 c4 2c             	add    $0x2c,%esp
f010173a:	5b                   	pop    %ebx
f010173b:	5e                   	pop    %esi
f010173c:	5f                   	pop    %edi
f010173d:	5d                   	pop    %ebp
f010173e:	c3                   	ret    

f010173f <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010173f:	55                   	push   %ebp
f0101740:	89 e5                	mov    %esp,%ebp
f0101742:	53                   	push   %ebx
f0101743:	83 ec 14             	sub    $0x14,%esp
f0101746:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
f0101749:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101750:	00 
f0101751:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101754:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101758:	8b 45 08             	mov    0x8(%ebp),%eax
f010175b:	89 04 24             	mov    %eax,(%esp)
f010175e:	e8 ce fe ff ff       	call   f0101631 <pgdir_walk>
	struct PageInfo *pg = NULL;
	// Check if the pte_store is zero
	if(pte_store != 0)
f0101763:	85 db                	test   %ebx,%ebx
f0101765:	74 02                	je     f0101769 <page_lookup+0x2a>
		*pte_store = pte;
f0101767:	89 03                	mov    %eax,(%ebx)

	// Check if the page is mapped
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
f0101769:	85 c0                	test   %eax,%eax
f010176b:	74 38                	je     f01017a5 <page_lookup+0x66>
f010176d:	8b 00                	mov    (%eax),%eax
f010176f:	a8 01                	test   $0x1,%al
f0101771:	74 39                	je     f01017ac <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101773:	c1 e8 0c             	shr    $0xc,%eax
f0101776:	3b 05 84 99 11 f0    	cmp    0xf0119984,%eax
f010177c:	72 1c                	jb     f010179a <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010177e:	c7 44 24 08 b8 4f 10 	movl   $0xf0104fb8,0x8(%esp)
f0101785:	f0 
f0101786:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010178d:	00 
f010178e:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f0101795:	e8 fa e8 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f010179a:	c1 e0 03             	shl    $0x3,%eax
f010179d:	03 05 8c 99 11 f0    	add    0xf011998c,%eax
f01017a3:	eb 0c                	jmp    f01017b1 <page_lookup+0x72>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
	struct PageInfo *pg = NULL;
f01017a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01017aa:	eb 05                	jmp    f01017b1 <page_lookup+0x72>
f01017ac:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
		pg = pa2page(PTE_ADDR(*pte));
	}

	return pg;
}
f01017b1:	83 c4 14             	add    $0x14,%esp
f01017b4:	5b                   	pop    %ebx
f01017b5:	5d                   	pop    %ebp
f01017b6:	c3                   	ret    

f01017b7 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01017b7:	55                   	push   %ebp
f01017b8:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01017ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017bd:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01017c0:	5d                   	pop    %ebp
f01017c1:	c3                   	ret    

f01017c2 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01017c2:	55                   	push   %ebp
f01017c3:	89 e5                	mov    %esp,%ebp
f01017c5:	83 ec 28             	sub    $0x28,%esp
f01017c8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01017cb:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01017ce:	8b 75 08             	mov    0x8(%ebp),%esi
f01017d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;

	// look up the pte for the va
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01017d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01017df:	89 34 24             	mov    %esi,(%esp)
f01017e2:	e8 58 ff ff ff       	call   f010173f <page_lookup>

	if(pg != NULL) {
f01017e7:	85 c0                	test   %eax,%eax
f01017e9:	74 1d                	je     f0101808 <page_remove+0x46>
		// Decrease the count and free
		page_decref(pg);
f01017eb:	89 04 24             	mov    %eax,(%esp)
f01017ee:	e8 1b fe ff ff       	call   f010160e <page_decref>
		// Set the pte to zero
		*pte = 0;
f01017f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		// The TLB must be invalidated if a page was formerly present at 'va'.
		tlb_invalidate(pgdir, va);
f01017fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101800:	89 34 24             	mov    %esi,(%esp)
f0101803:	e8 af ff ff ff       	call   f01017b7 <tlb_invalidate>
	}
}
f0101808:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010180b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010180e:	89 ec                	mov    %ebp,%esp
f0101810:	5d                   	pop    %ebp
f0101811:	c3                   	ret    

f0101812 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101812:	55                   	push   %ebp
f0101813:	89 e5                	mov    %esp,%ebp
f0101815:	83 ec 28             	sub    $0x28,%esp
f0101818:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010181b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010181e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101821:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101824:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
f0101827:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010182e:	00 
f010182f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101833:	8b 45 08             	mov    0x8(%ebp),%eax
f0101836:	89 04 24             	mov    %eax,(%esp)
f0101839:	e8 f3 fd ff ff       	call   f0101631 <pgdir_walk>
f010183e:	89 c3                	mov    %eax,%ebx
	if(pte == NULL) 
f0101840:	85 c0                	test   %eax,%eax
f0101842:	74 66                	je     f01018aa <page_insert+0x98>
		return -E_NO_MEM;
	// If there is already a page mapped at 'va', it should be page_remove()d.
	if(((*pte) & PTE_P) == 1) {
f0101844:	8b 00                	mov    (%eax),%eax
f0101846:	a8 01                	test   $0x1,%al
f0101848:	74 3c                	je     f0101886 <page_insert+0x74>
		//On one hand, the mapped page is pp;
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f010184a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010184f:	89 f2                	mov    %esi,%edx
f0101851:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0101857:	c1 fa 03             	sar    $0x3,%edx
f010185a:	c1 e2 0c             	shl    $0xc,%edx
f010185d:	39 d0                	cmp    %edx,%eax
f010185f:	75 16                	jne    f0101877 <page_insert+0x65>
			// The TLB must be invalidated if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f0101861:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101865:	8b 45 08             	mov    0x8(%ebp),%eax
f0101868:	89 04 24             	mov    %eax,(%esp)
f010186b:	e8 47 ff ff ff       	call   f01017b7 <tlb_invalidate>
			// The reference for the same page should not change(latter add one)
			pp->pp_ref --;
f0101870:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101875:	eb 0f                	jmp    f0101886 <page_insert+0x74>
		}
		//On the other hand, the mapped page is not pp;
		else
			page_remove(pgdir, va);
f0101877:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010187b:	8b 45 08             	mov    0x8(%ebp),%eax
f010187e:	89 04 24             	mov    %eax,(%esp)
f0101881:	e8 3c ff ff ff       	call   f01017c2 <page_remove>
	}

	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
f0101886:	8b 45 14             	mov    0x14(%ebp),%eax
f0101889:	83 c8 01             	or     $0x1,%eax
f010188c:	89 f2                	mov    %esi,%edx
f010188e:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0101894:	c1 fa 03             	sar    $0x3,%edx
f0101897:	c1 e2 0c             	shl    $0xc,%edx
f010189a:	09 d0                	or     %edx,%eax
f010189c:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref ++;
f010189e:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	
	return 0;
f01018a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01018a8:	eb 05                	jmp    f01018af <page_insert+0x9d>
{
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
	if(pte == NULL) 
		return -E_NO_MEM;
f01018aa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref ++;
	
	return 0;
}
f01018af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01018b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01018b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01018b8:	89 ec                	mov    %ebp,%esp
f01018ba:	5d                   	pop    %ebp
f01018bb:	c3                   	ret    

f01018bc <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01018bc:	55                   	push   %ebp
f01018bd:	89 e5                	mov    %esp,%ebp
f01018bf:	57                   	push   %edi
f01018c0:	56                   	push   %esi
f01018c1:	53                   	push   %ebx
f01018c2:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01018c5:	b8 15 00 00 00       	mov    $0x15,%eax
f01018ca:	e8 27 f8 ff ff       	call   f01010f6 <nvram_read>
f01018cf:	c1 e0 0a             	shl    $0xa,%eax
f01018d2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01018d8:	85 c0                	test   %eax,%eax
f01018da:	0f 48 c2             	cmovs  %edx,%eax
f01018dd:	c1 f8 0c             	sar    $0xc,%eax
f01018e0:	a3 58 95 11 f0       	mov    %eax,0xf0119558
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01018e5:	b8 17 00 00 00       	mov    $0x17,%eax
f01018ea:	e8 07 f8 ff ff       	call   f01010f6 <nvram_read>
f01018ef:	c1 e0 0a             	shl    $0xa,%eax
f01018f2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01018f8:	85 c0                	test   %eax,%eax
f01018fa:	0f 48 c2             	cmovs  %edx,%eax
f01018fd:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101900:	85 c0                	test   %eax,%eax
f0101902:	74 0e                	je     f0101912 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101904:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010190a:	89 15 84 99 11 f0    	mov    %edx,0xf0119984
f0101910:	eb 0c                	jmp    f010191e <mem_init+0x62>
	else
		npages = npages_basemem;
f0101912:	8b 15 58 95 11 f0    	mov    0xf0119558,%edx
f0101918:	89 15 84 99 11 f0    	mov    %edx,0xf0119984

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010191e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101921:	c1 e8 0a             	shr    $0xa,%eax
f0101924:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101928:	a1 58 95 11 f0       	mov    0xf0119558,%eax
f010192d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101930:	c1 e8 0a             	shr    $0xa,%eax
f0101933:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101937:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f010193c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010193f:	c1 e8 0a             	shr    $0xa,%eax
f0101942:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101946:	c7 04 24 d8 4f 10 f0 	movl   $0xf0104fd8,(%esp)
f010194d:	e8 a8 1b 00 00       	call   f01034fa <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101952:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101957:	e8 c9 f6 ff ff       	call   f0101025 <boot_alloc>
f010195c:	a3 88 99 11 f0       	mov    %eax,0xf0119988
	memset(kern_pgdir, 0, PGSIZE);
f0101961:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101968:	00 
f0101969:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101970:	00 
f0101971:	89 04 24             	mov    %eax,(%esp)
f0101974:	e8 68 28 00 00       	call   f01041e1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101979:	a1 88 99 11 f0       	mov    0xf0119988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010197e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101983:	77 20                	ja     f01019a5 <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101985:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101989:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0101990:	f0 
f0101991:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
f0101998:	00 
f0101999:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01019a0:	e8 ef e6 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01019a5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01019ab:	83 ca 05             	or     $0x5,%edx
f01019ae:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f01019b4:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f01019b9:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f01019bc:	e8 64 f6 ff ff       	call   f0101025 <boot_alloc>
f01019c1:	a3 8c 99 11 f0       	mov    %eax,0xf011998c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01019c6:	e8 c5 fa ff ff       	call   f0101490 <page_init>

	check_page_free_list(1);
f01019cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01019d0:	e8 53 f7 ff ff       	call   f0101128 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01019d5:	83 3d 8c 99 11 f0 00 	cmpl   $0x0,0xf011998c
f01019dc:	75 1c                	jne    f01019fa <mem_init+0x13e>
		panic("'pages' is a null pointer!");
f01019de:	c7 44 24 08 9a 56 10 	movl   $0xf010569a,0x8(%esp)
f01019e5:	f0 
f01019e6:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01019ed:	00 
f01019ee:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01019f5:	e8 9a e6 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01019fa:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f01019ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a04:	85 c0                	test   %eax,%eax
f0101a06:	74 09                	je     f0101a11 <mem_init+0x155>
		++nfree;
f0101a08:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a0b:	8b 00                	mov    (%eax),%eax
f0101a0d:	85 c0                	test   %eax,%eax
f0101a0f:	75 f7                	jne    f0101a08 <mem_init+0x14c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a18:	e8 3b fb ff ff       	call   f0101558 <page_alloc>
f0101a1d:	89 c6                	mov    %eax,%esi
f0101a1f:	85 c0                	test   %eax,%eax
f0101a21:	75 24                	jne    f0101a47 <mem_init+0x18b>
f0101a23:	c7 44 24 0c b5 56 10 	movl   $0xf01056b5,0xc(%esp)
f0101a2a:	f0 
f0101a2b:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101a32:	f0 
f0101a33:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101a3a:	00 
f0101a3b:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101a42:	e8 4d e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a4e:	e8 05 fb ff ff       	call   f0101558 <page_alloc>
f0101a53:	89 c7                	mov    %eax,%edi
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	75 24                	jne    f0101a7d <mem_init+0x1c1>
f0101a59:	c7 44 24 0c cb 56 10 	movl   $0xf01056cb,0xc(%esp)
f0101a60:	f0 
f0101a61:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101a68:	f0 
f0101a69:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101a70:	00 
f0101a71:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101a78:	e8 17 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a84:	e8 cf fa ff ff       	call   f0101558 <page_alloc>
f0101a89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a8c:	85 c0                	test   %eax,%eax
f0101a8e:	75 24                	jne    f0101ab4 <mem_init+0x1f8>
f0101a90:	c7 44 24 0c e1 56 10 	movl   $0xf01056e1,0xc(%esp)
f0101a97:	f0 
f0101a98:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101aa7:	00 
f0101aa8:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101aaf:	e8 e0 e5 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ab4:	39 fe                	cmp    %edi,%esi
f0101ab6:	75 24                	jne    f0101adc <mem_init+0x220>
f0101ab8:	c7 44 24 0c f7 56 10 	movl   $0xf01056f7,0xc(%esp)
f0101abf:	f0 
f0101ac0:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101ac7:	f0 
f0101ac8:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0101acf:	00 
f0101ad0:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101ad7:	e8 b8 e5 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101adc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101adf:	74 05                	je     f0101ae6 <mem_init+0x22a>
f0101ae1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101ae4:	75 24                	jne    f0101b0a <mem_init+0x24e>
f0101ae6:	c7 44 24 0c 14 50 10 	movl   $0xf0105014,0xc(%esp)
f0101aed:	f0 
f0101aee:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101af5:	f0 
f0101af6:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0101afd:	00 
f0101afe:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101b05:	e8 8a e5 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b0a:	8b 15 8c 99 11 f0    	mov    0xf011998c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b10:	a1 84 99 11 f0       	mov    0xf0119984,%eax
f0101b15:	c1 e0 0c             	shl    $0xc,%eax
f0101b18:	89 f1                	mov    %esi,%ecx
f0101b1a:	29 d1                	sub    %edx,%ecx
f0101b1c:	c1 f9 03             	sar    $0x3,%ecx
f0101b1f:	c1 e1 0c             	shl    $0xc,%ecx
f0101b22:	39 c1                	cmp    %eax,%ecx
f0101b24:	72 24                	jb     f0101b4a <mem_init+0x28e>
f0101b26:	c7 44 24 0c 09 57 10 	movl   $0xf0105709,0xc(%esp)
f0101b2d:	f0 
f0101b2e:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101b35:	f0 
f0101b36:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101b3d:	00 
f0101b3e:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101b45:	e8 4a e5 ff ff       	call   f0100094 <_panic>
f0101b4a:	89 f9                	mov    %edi,%ecx
f0101b4c:	29 d1                	sub    %edx,%ecx
f0101b4e:	c1 f9 03             	sar    $0x3,%ecx
f0101b51:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b54:	39 c8                	cmp    %ecx,%eax
f0101b56:	77 24                	ja     f0101b7c <mem_init+0x2c0>
f0101b58:	c7 44 24 0c 26 57 10 	movl   $0xf0105726,0xc(%esp)
f0101b5f:	f0 
f0101b60:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101b67:	f0 
f0101b68:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0101b6f:	00 
f0101b70:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101b77:	e8 18 e5 ff ff       	call   f0100094 <_panic>
f0101b7c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b7f:	29 d1                	sub    %edx,%ecx
f0101b81:	89 ca                	mov    %ecx,%edx
f0101b83:	c1 fa 03             	sar    $0x3,%edx
f0101b86:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101b89:	39 d0                	cmp    %edx,%eax
f0101b8b:	77 24                	ja     f0101bb1 <mem_init+0x2f5>
f0101b8d:	c7 44 24 0c 43 57 10 	movl   $0xf0105743,0xc(%esp)
f0101b94:	f0 
f0101b95:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101b9c:	f0 
f0101b9d:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0101ba4:	00 
f0101ba5:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101bac:	e8 e3 e4 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bb1:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f0101bb6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bb9:	c7 05 60 95 11 f0 00 	movl   $0x0,0xf0119560
f0101bc0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bca:	e8 89 f9 ff ff       	call   f0101558 <page_alloc>
f0101bcf:	85 c0                	test   %eax,%eax
f0101bd1:	74 24                	je     f0101bf7 <mem_init+0x33b>
f0101bd3:	c7 44 24 0c 60 57 10 	movl   $0xf0105760,0xc(%esp)
f0101bda:	f0 
f0101bdb:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101be2:	f0 
f0101be3:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101bea:	00 
f0101beb:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101bf2:	e8 9d e4 ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101bf7:	89 34 24             	mov    %esi,(%esp)
f0101bfa:	e8 d7 f9 ff ff       	call   f01015d6 <page_free>
	page_free(pp1);
f0101bff:	89 3c 24             	mov    %edi,(%esp)
f0101c02:	e8 cf f9 ff ff       	call   f01015d6 <page_free>
	page_free(pp2);
f0101c07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c0a:	89 04 24             	mov    %eax,(%esp)
f0101c0d:	e8 c4 f9 ff ff       	call   f01015d6 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c19:	e8 3a f9 ff ff       	call   f0101558 <page_alloc>
f0101c1e:	89 c6                	mov    %eax,%esi
f0101c20:	85 c0                	test   %eax,%eax
f0101c22:	75 24                	jne    f0101c48 <mem_init+0x38c>
f0101c24:	c7 44 24 0c b5 56 10 	movl   $0xf01056b5,0xc(%esp)
f0101c2b:	f0 
f0101c2c:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0101c3b:	00 
f0101c3c:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101c43:	e8 4c e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c4f:	e8 04 f9 ff ff       	call   f0101558 <page_alloc>
f0101c54:	89 c7                	mov    %eax,%edi
f0101c56:	85 c0                	test   %eax,%eax
f0101c58:	75 24                	jne    f0101c7e <mem_init+0x3c2>
f0101c5a:	c7 44 24 0c cb 56 10 	movl   $0xf01056cb,0xc(%esp)
f0101c61:	f0 
f0101c62:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101c69:	f0 
f0101c6a:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0101c71:	00 
f0101c72:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101c79:	e8 16 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c85:	e8 ce f8 ff ff       	call   f0101558 <page_alloc>
f0101c8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c8d:	85 c0                	test   %eax,%eax
f0101c8f:	75 24                	jne    f0101cb5 <mem_init+0x3f9>
f0101c91:	c7 44 24 0c e1 56 10 	movl   $0xf01056e1,0xc(%esp)
f0101c98:	f0 
f0101c99:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101ca0:	f0 
f0101ca1:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101ca8:	00 
f0101ca9:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101cb0:	e8 df e3 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cb5:	39 fe                	cmp    %edi,%esi
f0101cb7:	75 24                	jne    f0101cdd <mem_init+0x421>
f0101cb9:	c7 44 24 0c f7 56 10 	movl   $0xf01056f7,0xc(%esp)
f0101cc0:	f0 
f0101cc1:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101cc8:	f0 
f0101cc9:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101cd0:	00 
f0101cd1:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101cd8:	e8 b7 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cdd:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101ce0:	74 05                	je     f0101ce7 <mem_init+0x42b>
f0101ce2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101ce5:	75 24                	jne    f0101d0b <mem_init+0x44f>
f0101ce7:	c7 44 24 0c 14 50 10 	movl   $0xf0105014,0xc(%esp)
f0101cee:	f0 
f0101cef:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101cf6:	f0 
f0101cf7:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0101cfe:	00 
f0101cff:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101d06:	e8 89 e3 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d12:	e8 41 f8 ff ff       	call   f0101558 <page_alloc>
f0101d17:	85 c0                	test   %eax,%eax
f0101d19:	74 24                	je     f0101d3f <mem_init+0x483>
f0101d1b:	c7 44 24 0c 60 57 10 	movl   $0xf0105760,0xc(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101d2a:	f0 
f0101d2b:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0101d32:	00 
f0101d33:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101d3a:	e8 55 e3 ff ff       	call   f0100094 <_panic>
f0101d3f:	89 f0                	mov    %esi,%eax
f0101d41:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f0101d47:	c1 f8 03             	sar    $0x3,%eax
f0101d4a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d4d:	89 c2                	mov    %eax,%edx
f0101d4f:	c1 ea 0c             	shr    $0xc,%edx
f0101d52:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f0101d58:	72 20                	jb     f0101d7a <mem_init+0x4be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d5e:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101d6d:	00 
f0101d6e:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f0101d75:	e8 1a e3 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d7a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d81:	00 
f0101d82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101d89:	00 
	return (void *)(pa + KERNBASE);
f0101d8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d8f:	89 04 24             	mov    %eax,(%esp)
f0101d92:	e8 4a 24 00 00       	call   f01041e1 <memset>
	page_free(pp0);
f0101d97:	89 34 24             	mov    %esi,(%esp)
f0101d9a:	e8 37 f8 ff ff       	call   f01015d6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101da6:	e8 ad f7 ff ff       	call   f0101558 <page_alloc>
f0101dab:	85 c0                	test   %eax,%eax
f0101dad:	75 24                	jne    f0101dd3 <mem_init+0x517>
f0101daf:	c7 44 24 0c 6f 57 10 	movl   $0xf010576f,0xc(%esp)
f0101db6:	f0 
f0101db7:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101dbe:	f0 
f0101dbf:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0101dc6:	00 
f0101dc7:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101dce:	e8 c1 e2 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101dd3:	39 c6                	cmp    %eax,%esi
f0101dd5:	74 24                	je     f0101dfb <mem_init+0x53f>
f0101dd7:	c7 44 24 0c 8d 57 10 	movl   $0xf010578d,0xc(%esp)
f0101dde:	f0 
f0101ddf:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101de6:	f0 
f0101de7:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101dee:	00 
f0101def:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101df6:	e8 99 e2 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dfb:	89 f2                	mov    %esi,%edx
f0101dfd:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0101e03:	c1 fa 03             	sar    $0x3,%edx
f0101e06:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e09:	89 d0                	mov    %edx,%eax
f0101e0b:	c1 e8 0c             	shr    $0xc,%eax
f0101e0e:	3b 05 84 99 11 f0    	cmp    0xf0119984,%eax
f0101e14:	72 20                	jb     f0101e36 <mem_init+0x57a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e16:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101e1a:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0101e21:	f0 
f0101e22:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101e29:	00 
f0101e2a:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f0101e31:	e8 5e e2 ff ff       	call   f0100094 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e36:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101e3d:	75 11                	jne    f0101e50 <mem_init+0x594>
f0101e3f:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101e45:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e4b:	80 38 00             	cmpb   $0x0,(%eax)
f0101e4e:	74 24                	je     f0101e74 <mem_init+0x5b8>
f0101e50:	c7 44 24 0c 9d 57 10 	movl   $0xf010579d,0xc(%esp)
f0101e57:	f0 
f0101e58:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101e5f:	f0 
f0101e60:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0101e67:	00 
f0101e68:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101e6f:	e8 20 e2 ff ff       	call   f0100094 <_panic>
f0101e74:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101e77:	39 d0                	cmp    %edx,%eax
f0101e79:	75 d0                	jne    f0101e4b <mem_init+0x58f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e7b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101e7e:	89 15 60 95 11 f0    	mov    %edx,0xf0119560

	// free the pages we took
	page_free(pp0);
f0101e84:	89 34 24             	mov    %esi,(%esp)
f0101e87:	e8 4a f7 ff ff       	call   f01015d6 <page_free>
	page_free(pp1);
f0101e8c:	89 3c 24             	mov    %edi,(%esp)
f0101e8f:	e8 42 f7 ff ff       	call   f01015d6 <page_free>
	page_free(pp2);
f0101e94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e97:	89 04 24             	mov    %eax,(%esp)
f0101e9a:	e8 37 f7 ff ff       	call   f01015d6 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e9f:	a1 60 95 11 f0       	mov    0xf0119560,%eax
f0101ea4:	85 c0                	test   %eax,%eax
f0101ea6:	74 09                	je     f0101eb1 <mem_init+0x5f5>
		--nfree;
f0101ea8:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101eab:	8b 00                	mov    (%eax),%eax
f0101ead:	85 c0                	test   %eax,%eax
f0101eaf:	75 f7                	jne    f0101ea8 <mem_init+0x5ec>
		--nfree;
	assert(nfree == 0);
f0101eb1:	85 db                	test   %ebx,%ebx
f0101eb3:	74 24                	je     f0101ed9 <mem_init+0x61d>
f0101eb5:	c7 44 24 0c a7 57 10 	movl   $0xf01057a7,0xc(%esp)
f0101ebc:	f0 
f0101ebd:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101ec4:	f0 
f0101ec5:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101ecc:	00 
f0101ecd:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101ed4:	e8 bb e1 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101ed9:	c7 04 24 34 50 10 f0 	movl   $0xf0105034,(%esp)
f0101ee0:	e8 15 16 00 00       	call   f01034fa <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eec:	e8 67 f6 ff ff       	call   f0101558 <page_alloc>
f0101ef1:	89 c6                	mov    %eax,%esi
f0101ef3:	85 c0                	test   %eax,%eax
f0101ef5:	75 24                	jne    f0101f1b <mem_init+0x65f>
f0101ef7:	c7 44 24 0c b5 56 10 	movl   $0xf01056b5,0xc(%esp)
f0101efe:	f0 
f0101eff:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101f0e:	00 
f0101f0f:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101f16:	e8 79 e1 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f22:	e8 31 f6 ff ff       	call   f0101558 <page_alloc>
f0101f27:	89 c7                	mov    %eax,%edi
f0101f29:	85 c0                	test   %eax,%eax
f0101f2b:	75 24                	jne    f0101f51 <mem_init+0x695>
f0101f2d:	c7 44 24 0c cb 56 10 	movl   $0xf01056cb,0xc(%esp)
f0101f34:	f0 
f0101f35:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101f3c:	f0 
f0101f3d:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101f44:	00 
f0101f45:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101f4c:	e8 43 e1 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f58:	e8 fb f5 ff ff       	call   f0101558 <page_alloc>
f0101f5d:	89 c3                	mov    %eax,%ebx
f0101f5f:	85 c0                	test   %eax,%eax
f0101f61:	75 24                	jne    f0101f87 <mem_init+0x6cb>
f0101f63:	c7 44 24 0c e1 56 10 	movl   $0xf01056e1,0xc(%esp)
f0101f6a:	f0 
f0101f6b:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101f7a:	00 
f0101f7b:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101f82:	e8 0d e1 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f87:	39 fe                	cmp    %edi,%esi
f0101f89:	75 24                	jne    f0101faf <mem_init+0x6f3>
f0101f8b:	c7 44 24 0c f7 56 10 	movl   $0xf01056f7,0xc(%esp)
f0101f92:	f0 
f0101f93:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101fa2:	00 
f0101fa3:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101faa:	e8 e5 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101faf:	39 c7                	cmp    %eax,%edi
f0101fb1:	74 04                	je     f0101fb7 <mem_init+0x6fb>
f0101fb3:	39 c6                	cmp    %eax,%esi
f0101fb5:	75 24                	jne    f0101fdb <mem_init+0x71f>
f0101fb7:	c7 44 24 0c 14 50 10 	movl   $0xf0105014,0xc(%esp)
f0101fbe:	f0 
f0101fbf:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101fce:	00 
f0101fcf:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0101fd6:	e8 b9 e0 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101fdb:	8b 15 60 95 11 f0    	mov    0xf0119560,%edx
f0101fe1:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101fe4:	c7 05 60 95 11 f0 00 	movl   $0x0,0xf0119560
f0101feb:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101fee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ff5:	e8 5e f5 ff ff       	call   f0101558 <page_alloc>
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	74 24                	je     f0102022 <mem_init+0x766>
f0101ffe:	c7 44 24 0c 60 57 10 	movl   $0xf0105760,0xc(%esp)
f0102005:	f0 
f0102006:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010200d:	f0 
f010200e:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102015:	00 
f0102016:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010201d:	e8 72 e0 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102022:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102025:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102029:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102030:	00 
f0102031:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102036:	89 04 24             	mov    %eax,(%esp)
f0102039:	e8 01 f7 ff ff       	call   f010173f <page_lookup>
f010203e:	85 c0                	test   %eax,%eax
f0102040:	74 24                	je     f0102066 <mem_init+0x7aa>
f0102042:	c7 44 24 0c 54 50 10 	movl   $0xf0105054,0xc(%esp)
f0102049:	f0 
f010204a:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102051:	f0 
f0102052:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102059:	00 
f010205a:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102061:	e8 2e e0 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102066:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010206d:	00 
f010206e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102075:	00 
f0102076:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010207a:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010207f:	89 04 24             	mov    %eax,(%esp)
f0102082:	e8 8b f7 ff ff       	call   f0101812 <page_insert>
f0102087:	85 c0                	test   %eax,%eax
f0102089:	78 24                	js     f01020af <mem_init+0x7f3>
f010208b:	c7 44 24 0c 8c 50 10 	movl   $0xf010508c,0xc(%esp)
f0102092:	f0 
f0102093:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010209a:	f0 
f010209b:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01020a2:	00 
f01020a3:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01020aa:	e8 e5 df ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01020af:	89 34 24             	mov    %esi,(%esp)
f01020b2:	e8 1f f5 ff ff       	call   f01015d6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01020b7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020be:	00 
f01020bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020c6:	00 
f01020c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01020cb:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01020d0:	89 04 24             	mov    %eax,(%esp)
f01020d3:	e8 3a f7 ff ff       	call   f0101812 <page_insert>
f01020d8:	85 c0                	test   %eax,%eax
f01020da:	74 24                	je     f0102100 <mem_init+0x844>
f01020dc:	c7 44 24 0c bc 50 10 	movl   $0xf01050bc,0xc(%esp)
f01020e3:	f0 
f01020e4:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01020eb:	f0 
f01020ec:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01020f3:	00 
f01020f4:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01020fb:	e8 94 df ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102100:	8b 0d 88 99 11 f0    	mov    0xf0119988,%ecx
f0102106:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102109:	a1 8c 99 11 f0       	mov    0xf011998c,%eax
f010210e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102111:	8b 11                	mov    (%ecx),%edx
f0102113:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102119:	89 f0                	mov    %esi,%eax
f010211b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010211e:	c1 f8 03             	sar    $0x3,%eax
f0102121:	c1 e0 0c             	shl    $0xc,%eax
f0102124:	39 c2                	cmp    %eax,%edx
f0102126:	74 24                	je     f010214c <mem_init+0x890>
f0102128:	c7 44 24 0c ec 50 10 	movl   $0xf01050ec,0xc(%esp)
f010212f:	f0 
f0102130:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102137:	f0 
f0102138:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f010213f:	00 
f0102140:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102147:	e8 48 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010214c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102151:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102154:	e8 5b ee ff ff       	call   f0100fb4 <check_va2pa>
f0102159:	89 fa                	mov    %edi,%edx
f010215b:	2b 55 d0             	sub    -0x30(%ebp),%edx
f010215e:	c1 fa 03             	sar    $0x3,%edx
f0102161:	c1 e2 0c             	shl    $0xc,%edx
f0102164:	39 d0                	cmp    %edx,%eax
f0102166:	74 24                	je     f010218c <mem_init+0x8d0>
f0102168:	c7 44 24 0c 14 51 10 	movl   $0xf0105114,0xc(%esp)
f010216f:	f0 
f0102170:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102177:	f0 
f0102178:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f010217f:	00 
f0102180:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102187:	e8 08 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010218c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102191:	74 24                	je     f01021b7 <mem_init+0x8fb>
f0102193:	c7 44 24 0c b2 57 10 	movl   $0xf01057b2,0xc(%esp)
f010219a:	f0 
f010219b:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01021a2:	f0 
f01021a3:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f01021aa:	00 
f01021ab:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01021b2:	e8 dd de ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01021b7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021bc:	74 24                	je     f01021e2 <mem_init+0x926>
f01021be:	c7 44 24 0c c3 57 10 	movl   $0xf01057c3,0xc(%esp)
f01021c5:	f0 
f01021c6:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01021cd:	f0 
f01021ce:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f01021d5:	00 
f01021d6:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01021dd:	e8 b2 de ff ff       	call   f0100094 <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021e2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021e9:	00 
f01021ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021f1:	00 
f01021f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01021f9:	89 14 24             	mov    %edx,(%esp)
f01021fc:	e8 11 f6 ff ff       	call   f0101812 <page_insert>
f0102201:	85 c0                	test   %eax,%eax
f0102203:	74 24                	je     f0102229 <mem_init+0x96d>
f0102205:	c7 44 24 0c 44 51 10 	movl   $0xf0105144,0xc(%esp)
f010220c:	f0 
f010220d:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102214:	f0 
f0102215:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f010221c:	00 
f010221d:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102224:	e8 6b de ff ff       	call   f0100094 <_panic>
cprintf("%x %x %x\n",kern_pgdir, PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
f0102229:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010222e:	89 f2                	mov    %esi,%edx
f0102230:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0102236:	c1 fa 03             	sar    $0x3,%edx
f0102239:	c1 e2 0c             	shl    $0xc,%edx
f010223c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102240:	8b 10                	mov    (%eax),%edx
f0102242:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102248:	89 54 24 08          	mov    %edx,0x8(%esp)
f010224c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102250:	c7 04 24 d4 57 10 f0 	movl   $0xf01057d4,(%esp)
f0102257:	e8 9e 12 00 00       	call   f01034fa <cprintf>
f010225c:	89 d8                	mov    %ebx,%eax
f010225e:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f0102264:	c1 f8 03             	sar    $0x3,%eax
f0102267:	c1 e0 0c             	shl    $0xc,%eax

cprintf("%x %x\n", PTE_ADDR(*((pte_t *)(PTE_ADDR(kern_pgdir[0]) + PTX(PGSIZE)))), page2pa(pp2));
f010226a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010226e:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102273:	8b 00                	mov    (%eax),%eax
f0102275:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010227a:	8b 40 01             	mov    0x1(%eax),%eax
f010227d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102282:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102286:	c7 04 24 d7 57 10 f0 	movl   $0xf01057d7,(%esp)
f010228d:	e8 68 12 00 00       	call   f01034fa <cprintf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102292:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102297:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010229c:	e8 13 ed ff ff       	call   f0100fb4 <check_va2pa>
f01022a1:	89 da                	mov    %ebx,%edx
f01022a3:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f01022a9:	c1 fa 03             	sar    $0x3,%edx
f01022ac:	c1 e2 0c             	shl    $0xc,%edx
f01022af:	39 d0                	cmp    %edx,%eax
f01022b1:	74 24                	je     f01022d7 <mem_init+0xa1b>
f01022b3:	c7 44 24 0c 80 51 10 	movl   $0xf0105180,0xc(%esp)
f01022ba:	f0 
f01022bb:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01022c2:	f0 
f01022c3:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01022ca:	00 
f01022cb:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01022d2:	e8 bd dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01022d7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022dc:	74 24                	je     f0102302 <mem_init+0xa46>
f01022de:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f01022e5:	f0 
f01022e6:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01022ed:	f0 
f01022ee:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f01022f5:	00 
f01022f6:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01022fd:	e8 92 dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102309:	e8 4a f2 ff ff       	call   f0101558 <page_alloc>
f010230e:	85 c0                	test   %eax,%eax
f0102310:	74 24                	je     f0102336 <mem_init+0xa7a>
f0102312:	c7 44 24 0c 60 57 10 	movl   $0xf0105760,0xc(%esp)
f0102319:	f0 
f010231a:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102321:	f0 
f0102322:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0102329:	00 
f010232a:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102331:	e8 5e dd ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102336:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010233d:	00 
f010233e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102345:	00 
f0102346:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010234a:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010234f:	89 04 24             	mov    %eax,(%esp)
f0102352:	e8 bb f4 ff ff       	call   f0101812 <page_insert>
f0102357:	85 c0                	test   %eax,%eax
f0102359:	74 24                	je     f010237f <mem_init+0xac3>
f010235b:	c7 44 24 0c 44 51 10 	movl   $0xf0105144,0xc(%esp)
f0102362:	f0 
f0102363:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010236a:	f0 
f010236b:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102372:	00 
f0102373:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010237a:	e8 15 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010237f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102384:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102389:	e8 26 ec ff ff       	call   f0100fb4 <check_va2pa>
f010238e:	89 da                	mov    %ebx,%edx
f0102390:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0102396:	c1 fa 03             	sar    $0x3,%edx
f0102399:	c1 e2 0c             	shl    $0xc,%edx
f010239c:	39 d0                	cmp    %edx,%eax
f010239e:	74 24                	je     f01023c4 <mem_init+0xb08>
f01023a0:	c7 44 24 0c 80 51 10 	movl   $0xf0105180,0xc(%esp)
f01023a7:	f0 
f01023a8:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01023af:	f0 
f01023b0:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01023b7:	00 
f01023b8:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01023bf:	e8 d0 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01023c4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01023c9:	74 24                	je     f01023ef <mem_init+0xb33>
f01023cb:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f01023d2:	f0 
f01023d3:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01023da:	f0 
f01023db:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f01023e2:	00 
f01023e3:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01023ea:	e8 a5 dc ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01023ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023f6:	e8 5d f1 ff ff       	call   f0101558 <page_alloc>
f01023fb:	85 c0                	test   %eax,%eax
f01023fd:	74 24                	je     f0102423 <mem_init+0xb67>
f01023ff:	c7 44 24 0c 60 57 10 	movl   $0xf0105760,0xc(%esp)
f0102406:	f0 
f0102407:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010240e:	f0 
f010240f:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102416:	00 
f0102417:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010241e:	e8 71 dc ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102423:	8b 15 88 99 11 f0    	mov    0xf0119988,%edx
f0102429:	8b 02                	mov    (%edx),%eax
f010242b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102430:	89 c1                	mov    %eax,%ecx
f0102432:	c1 e9 0c             	shr    $0xc,%ecx
f0102435:	3b 0d 84 99 11 f0    	cmp    0xf0119984,%ecx
f010243b:	72 20                	jb     f010245d <mem_init+0xba1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010243d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102441:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0102448:	f0 
f0102449:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102450:	00 
f0102451:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102458:	e8 37 dc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f010245d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102465:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010246c:	00 
f010246d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102474:	00 
f0102475:	89 14 24             	mov    %edx,(%esp)
f0102478:	e8 b4 f1 ff ff       	call   f0101631 <pgdir_walk>
f010247d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102480:	83 c2 04             	add    $0x4,%edx
f0102483:	39 d0                	cmp    %edx,%eax
f0102485:	74 24                	je     f01024ab <mem_init+0xbef>
f0102487:	c7 44 24 0c b0 51 10 	movl   $0xf01051b0,0xc(%esp)
f010248e:	f0 
f010248f:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102496:	f0 
f0102497:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010249e:	00 
f010249f:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01024a6:	e8 e9 db ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024ab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01024b2:	00 
f01024b3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ba:	00 
f01024bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024bf:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01024c4:	89 04 24             	mov    %eax,(%esp)
f01024c7:	e8 46 f3 ff ff       	call   f0101812 <page_insert>
f01024cc:	85 c0                	test   %eax,%eax
f01024ce:	74 24                	je     f01024f4 <mem_init+0xc38>
f01024d0:	c7 44 24 0c f0 51 10 	movl   $0xf01051f0,0xc(%esp)
f01024d7:	f0 
f01024d8:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01024df:	f0 
f01024e0:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01024e7:	00 
f01024e8:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01024ef:	e8 a0 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024f4:	8b 0d 88 99 11 f0    	mov    0xf0119988,%ecx
f01024fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01024fd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102502:	89 c8                	mov    %ecx,%eax
f0102504:	e8 ab ea ff ff       	call   f0100fb4 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102509:	89 da                	mov    %ebx,%edx
f010250b:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0102511:	c1 fa 03             	sar    $0x3,%edx
f0102514:	c1 e2 0c             	shl    $0xc,%edx
f0102517:	39 d0                	cmp    %edx,%eax
f0102519:	74 24                	je     f010253f <mem_init+0xc83>
f010251b:	c7 44 24 0c 80 51 10 	movl   $0xf0105180,0xc(%esp)
f0102522:	f0 
f0102523:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010252a:	f0 
f010252b:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102532:	00 
f0102533:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010253a:	e8 55 db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f010253f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102544:	74 24                	je     f010256a <mem_init+0xcae>
f0102546:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102565:	e8 2a db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010256a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102571:	00 
f0102572:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102579:	00 
f010257a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010257d:	89 04 24             	mov    %eax,(%esp)
f0102580:	e8 ac f0 ff ff       	call   f0101631 <pgdir_walk>
f0102585:	f6 00 04             	testb  $0x4,(%eax)
f0102588:	75 24                	jne    f01025ae <mem_init+0xcf2>
f010258a:	c7 44 24 0c 30 52 10 	movl   $0xf0105230,0xc(%esp)
f0102591:	f0 
f0102592:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102599:	f0 
f010259a:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f01025a1:	00 
f01025a2:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01025a9:	e8 e6 da ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025ae:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01025b3:	f6 00 04             	testb  $0x4,(%eax)
f01025b6:	75 24                	jne    f01025dc <mem_init+0xd20>
f01025b8:	c7 44 24 0c ef 57 10 	movl   $0xf01057ef,0xc(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01025c7:	f0 
f01025c8:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f01025cf:	00 
f01025d0:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01025d7:	e8 b8 da ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025dc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025e3:	00 
f01025e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025eb:	00 
f01025ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025f0:	89 04 24             	mov    %eax,(%esp)
f01025f3:	e8 1a f2 ff ff       	call   f0101812 <page_insert>
f01025f8:	85 c0                	test   %eax,%eax
f01025fa:	74 24                	je     f0102620 <mem_init+0xd64>
f01025fc:	c7 44 24 0c 44 51 10 	movl   $0xf0105144,0xc(%esp)
f0102603:	f0 
f0102604:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010260b:	f0 
f010260c:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102613:	00 
f0102614:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010261b:	e8 74 da ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102620:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102627:	00 
f0102628:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010262f:	00 
f0102630:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102635:	89 04 24             	mov    %eax,(%esp)
f0102638:	e8 f4 ef ff ff       	call   f0101631 <pgdir_walk>
f010263d:	f6 00 02             	testb  $0x2,(%eax)
f0102640:	75 24                	jne    f0102666 <mem_init+0xdaa>
f0102642:	c7 44 24 0c 64 52 10 	movl   $0xf0105264,0xc(%esp)
f0102649:	f0 
f010264a:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102651:	f0 
f0102652:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102659:	00 
f010265a:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102661:	e8 2e da ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102666:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010266d:	00 
f010266e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102675:	00 
f0102676:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010267b:	89 04 24             	mov    %eax,(%esp)
f010267e:	e8 ae ef ff ff       	call   f0101631 <pgdir_walk>
f0102683:	f6 00 04             	testb  $0x4,(%eax)
f0102686:	74 24                	je     f01026ac <mem_init+0xdf0>
f0102688:	c7 44 24 0c 98 52 10 	movl   $0xf0105298,0xc(%esp)
f010268f:	f0 
f0102690:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102697:	f0 
f0102698:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010269f:	00 
f01026a0:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01026a7:	e8 e8 d9 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026ac:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026b3:	00 
f01026b4:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01026bb:	00 
f01026bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01026c0:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01026c5:	89 04 24             	mov    %eax,(%esp)
f01026c8:	e8 45 f1 ff ff       	call   f0101812 <page_insert>
f01026cd:	85 c0                	test   %eax,%eax
f01026cf:	78 24                	js     f01026f5 <mem_init+0xe39>
f01026d1:	c7 44 24 0c d0 52 10 	movl   $0xf01052d0,0xc(%esp)
f01026d8:	f0 
f01026d9:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01026e0:	f0 
f01026e1:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f01026e8:	00 
f01026e9:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01026f0:	e8 9f d9 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026f5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026fc:	00 
f01026fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102704:	00 
f0102705:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102709:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010270e:	89 04 24             	mov    %eax,(%esp)
f0102711:	e8 fc f0 ff ff       	call   f0101812 <page_insert>
f0102716:	85 c0                	test   %eax,%eax
f0102718:	74 24                	je     f010273e <mem_init+0xe82>
f010271a:	c7 44 24 0c 08 53 10 	movl   $0xf0105308,0xc(%esp)
f0102721:	f0 
f0102722:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102729:	f0 
f010272a:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102731:	00 
f0102732:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102739:	e8 56 d9 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010273e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102745:	00 
f0102746:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010274d:	00 
f010274e:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102753:	89 04 24             	mov    %eax,(%esp)
f0102756:	e8 d6 ee ff ff       	call   f0101631 <pgdir_walk>
f010275b:	f6 00 04             	testb  $0x4,(%eax)
f010275e:	74 24                	je     f0102784 <mem_init+0xec8>
f0102760:	c7 44 24 0c 98 52 10 	movl   $0xf0105298,0xc(%esp)
f0102767:	f0 
f0102768:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010276f:	f0 
f0102770:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102777:	00 
f0102778:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010277f:	e8 10 d9 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102784:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102789:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010278c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102791:	e8 1e e8 ff ff       	call   f0100fb4 <check_va2pa>
f0102796:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102799:	89 f8                	mov    %edi,%eax
f010279b:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f01027a1:	c1 f8 03             	sar    $0x3,%eax
f01027a4:	c1 e0 0c             	shl    $0xc,%eax
f01027a7:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01027aa:	74 24                	je     f01027d0 <mem_init+0xf14>
f01027ac:	c7 44 24 0c 44 53 10 	movl   $0xf0105344,0xc(%esp)
f01027b3:	f0 
f01027b4:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01027bb:	f0 
f01027bc:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01027c3:	00 
f01027c4:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01027cb:	e8 c4 d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027d0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027d8:	e8 d7 e7 ff ff       	call   f0100fb4 <check_va2pa>
f01027dd:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01027e0:	74 24                	je     f0102806 <mem_init+0xf4a>
f01027e2:	c7 44 24 0c 70 53 10 	movl   $0xf0105370,0xc(%esp)
f01027e9:	f0 
f01027ea:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01027f1:	f0 
f01027f2:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f01027f9:	00 
f01027fa:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102801:	e8 8e d8 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102806:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f010280b:	74 24                	je     f0102831 <mem_init+0xf75>
f010280d:	c7 44 24 0c 05 58 10 	movl   $0xf0105805,0xc(%esp)
f0102814:	f0 
f0102815:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010281c:	f0 
f010281d:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102824:	00 
f0102825:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010282c:	e8 63 d8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102831:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102836:	74 24                	je     f010285c <mem_init+0xfa0>
f0102838:	c7 44 24 0c 16 58 10 	movl   $0xf0105816,0xc(%esp)
f010283f:	f0 
f0102840:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102847:	f0 
f0102848:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010284f:	00 
f0102850:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102857:	e8 38 d8 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010285c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102863:	e8 f0 ec ff ff       	call   f0101558 <page_alloc>
f0102868:	85 c0                	test   %eax,%eax
f010286a:	74 04                	je     f0102870 <mem_init+0xfb4>
f010286c:	39 c3                	cmp    %eax,%ebx
f010286e:	74 24                	je     f0102894 <mem_init+0xfd8>
f0102870:	c7 44 24 0c a0 53 10 	movl   $0xf01053a0,0xc(%esp)
f0102877:	f0 
f0102878:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010287f:	f0 
f0102880:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102887:	00 
f0102888:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010288f:	e8 00 d8 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102894:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010289b:	00 
f010289c:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01028a1:	89 04 24             	mov    %eax,(%esp)
f01028a4:	e8 19 ef ff ff       	call   f01017c2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028a9:	8b 15 88 99 11 f0    	mov    0xf0119988,%edx
f01028af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01028b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01028b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028ba:	e8 f5 e6 ff ff       	call   f0100fb4 <check_va2pa>
f01028bf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028c2:	74 24                	je     f01028e8 <mem_init+0x102c>
f01028c4:	c7 44 24 0c c4 53 10 	movl   $0xf01053c4,0xc(%esp)
f01028cb:	f0 
f01028cc:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01028d3:	f0 
f01028d4:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f01028db:	00 
f01028dc:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01028e3:	e8 ac d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028e8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028f0:	e8 bf e6 ff ff       	call   f0100fb4 <check_va2pa>
f01028f5:	89 fa                	mov    %edi,%edx
f01028f7:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f01028fd:	c1 fa 03             	sar    $0x3,%edx
f0102900:	c1 e2 0c             	shl    $0xc,%edx
f0102903:	39 d0                	cmp    %edx,%eax
f0102905:	74 24                	je     f010292b <mem_init+0x106f>
f0102907:	c7 44 24 0c 70 53 10 	movl   $0xf0105370,0xc(%esp)
f010290e:	f0 
f010290f:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102916:	f0 
f0102917:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f010291e:	00 
f010291f:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102926:	e8 69 d7 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010292b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102930:	74 24                	je     f0102956 <mem_init+0x109a>
f0102932:	c7 44 24 0c b2 57 10 	movl   $0xf01057b2,0xc(%esp)
f0102939:	f0 
f010293a:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102941:	f0 
f0102942:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102949:	00 
f010294a:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102951:	e8 3e d7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102956:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010295b:	74 24                	je     f0102981 <mem_init+0x10c5>
f010295d:	c7 44 24 0c 16 58 10 	movl   $0xf0105816,0xc(%esp)
f0102964:	f0 
f0102965:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010296c:	f0 
f010296d:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102974:	00 
f0102975:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010297c:	e8 13 d7 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102981:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102988:	00 
f0102989:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010298c:	89 0c 24             	mov    %ecx,(%esp)
f010298f:	e8 2e ee ff ff       	call   f01017c2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102994:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102999:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010299c:	ba 00 00 00 00       	mov    $0x0,%edx
f01029a1:	e8 0e e6 ff ff       	call   f0100fb4 <check_va2pa>
f01029a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a9:	74 24                	je     f01029cf <mem_init+0x1113>
f01029ab:	c7 44 24 0c c4 53 10 	movl   $0xf01053c4,0xc(%esp)
f01029b2:	f0 
f01029b3:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01029ba:	f0 
f01029bb:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01029c2:	00 
f01029c3:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01029ca:	e8 c5 d6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01029cf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029d7:	e8 d8 e5 ff ff       	call   f0100fb4 <check_va2pa>
f01029dc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029df:	74 24                	je     f0102a05 <mem_init+0x1149>
f01029e1:	c7 44 24 0c e8 53 10 	movl   $0xf01053e8,0xc(%esp)
f01029e8:	f0 
f01029e9:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01029f0:	f0 
f01029f1:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01029f8:	00 
f01029f9:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102a00:	e8 8f d6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102a05:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a0a:	74 24                	je     f0102a30 <mem_init+0x1174>
f0102a0c:	c7 44 24 0c 27 58 10 	movl   $0xf0105827,0xc(%esp)
f0102a13:	f0 
f0102a14:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102a1b:	f0 
f0102a1c:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102a23:	00 
f0102a24:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102a2b:	e8 64 d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102a30:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a35:	74 24                	je     f0102a5b <mem_init+0x119f>
f0102a37:	c7 44 24 0c 16 58 10 	movl   $0xf0105816,0xc(%esp)
f0102a3e:	f0 
f0102a3f:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102a46:	f0 
f0102a47:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102a4e:	00 
f0102a4f:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102a56:	e8 39 d6 ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a62:	e8 f1 ea ff ff       	call   f0101558 <page_alloc>
f0102a67:	85 c0                	test   %eax,%eax
f0102a69:	74 04                	je     f0102a6f <mem_init+0x11b3>
f0102a6b:	39 c7                	cmp    %eax,%edi
f0102a6d:	74 24                	je     f0102a93 <mem_init+0x11d7>
f0102a6f:	c7 44 24 0c 10 54 10 	movl   $0xf0105410,0xc(%esp)
f0102a76:	f0 
f0102a77:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102a7e:	f0 
f0102a7f:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0102a86:	00 
f0102a87:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102a8e:	e8 01 d6 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102a93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a9a:	e8 b9 ea ff ff       	call   f0101558 <page_alloc>
f0102a9f:	85 c0                	test   %eax,%eax
f0102aa1:	74 24                	je     f0102ac7 <mem_init+0x120b>
f0102aa3:	c7 44 24 0c 60 57 10 	movl   $0xf0105760,0xc(%esp)
f0102aaa:	f0 
f0102aab:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102ab2:	f0 
f0102ab3:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102aba:	00 
f0102abb:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102ac2:	e8 cd d5 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ac7:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102acc:	8b 08                	mov    (%eax),%ecx
f0102ace:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102ad4:	89 f2                	mov    %esi,%edx
f0102ad6:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0102adc:	c1 fa 03             	sar    $0x3,%edx
f0102adf:	c1 e2 0c             	shl    $0xc,%edx
f0102ae2:	39 d1                	cmp    %edx,%ecx
f0102ae4:	74 24                	je     f0102b0a <mem_init+0x124e>
f0102ae6:	c7 44 24 0c ec 50 10 	movl   $0xf01050ec,0xc(%esp)
f0102aed:	f0 
f0102aee:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102af5:	f0 
f0102af6:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102afd:	00 
f0102afe:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102b05:	e8 8a d5 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102b0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b10:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b15:	74 24                	je     f0102b3b <mem_init+0x127f>
f0102b17:	c7 44 24 0c c3 57 10 	movl   $0xf01057c3,0xc(%esp)
f0102b1e:	f0 
f0102b1f:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102b26:	f0 
f0102b27:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102b2e:	00 
f0102b2f:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102b36:	e8 59 d5 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102b3b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b41:	89 34 24             	mov    %esi,(%esp)
f0102b44:	e8 8d ea ff ff       	call   f01015d6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b49:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b50:	00 
f0102b51:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b58:	00 
f0102b59:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102b5e:	89 04 24             	mov    %eax,(%esp)
f0102b61:	e8 cb ea ff ff       	call   f0101631 <pgdir_walk>
f0102b66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102b69:	8b 0d 88 99 11 f0    	mov    0xf0119988,%ecx
f0102b6f:	8b 51 04             	mov    0x4(%ecx),%edx
f0102b72:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b78:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b7b:	8b 15 84 99 11 f0    	mov    0xf0119984,%edx
f0102b81:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102b84:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b87:	c1 ea 0c             	shr    $0xc,%edx
f0102b8a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102b8d:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102b90:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102b93:	72 23                	jb     f0102bb8 <mem_init+0x12fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b95:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102b98:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102b9c:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0102ba3:	f0 
f0102ba4:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102bab:	00 
f0102bac:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102bb3:	e8 dc d4 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102bb8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102bbb:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102bc1:	39 d0                	cmp    %edx,%eax
f0102bc3:	74 24                	je     f0102be9 <mem_init+0x132d>
f0102bc5:	c7 44 24 0c 38 58 10 	movl   $0xf0105838,0xc(%esp)
f0102bcc:	f0 
f0102bcd:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102bd4:	f0 
f0102bd5:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0102bdc:	00 
f0102bdd:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102be4:	e8 ab d4 ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102be9:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102bf0:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf6:	89 f0                	mov    %esi,%eax
f0102bf8:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f0102bfe:	c1 f8 03             	sar    $0x3,%eax
f0102c01:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c04:	89 c1                	mov    %eax,%ecx
f0102c06:	c1 e9 0c             	shr    $0xc,%ecx
f0102c09:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102c0c:	77 20                	ja     f0102c2e <mem_init+0x1372>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c12:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0102c19:	f0 
f0102c1a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c21:	00 
f0102c22:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f0102c29:	e8 66 d4 ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c35:	00 
f0102c36:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c3d:	00 
	return (void *)(pa + KERNBASE);
f0102c3e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c43:	89 04 24             	mov    %eax,(%esp)
f0102c46:	e8 96 15 00 00       	call   f01041e1 <memset>
	page_free(pp0);
f0102c4b:	89 34 24             	mov    %esi,(%esp)
f0102c4e:	e8 83 e9 ff ff       	call   f01015d6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c53:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c5a:	00 
f0102c5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c62:	00 
f0102c63:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102c68:	89 04 24             	mov    %eax,(%esp)
f0102c6b:	e8 c1 e9 ff ff       	call   f0101631 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c70:	89 f2                	mov    %esi,%edx
f0102c72:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f0102c78:	c1 fa 03             	sar    $0x3,%edx
f0102c7b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c7e:	89 d0                	mov    %edx,%eax
f0102c80:	c1 e8 0c             	shr    $0xc,%eax
f0102c83:	3b 05 84 99 11 f0    	cmp    0xf0119984,%eax
f0102c89:	72 20                	jb     f0102cab <mem_init+0x13ef>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c8f:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f0102c96:	f0 
f0102c97:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c9e:	00 
f0102c9f:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f0102ca6:	e8 e9 d3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102cab:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102cb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cb4:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102cbb:	75 11                	jne    f0102cce <mem_init+0x1412>
f0102cbd:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cc3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cc9:	f6 00 01             	testb  $0x1,(%eax)
f0102ccc:	74 24                	je     f0102cf2 <mem_init+0x1436>
f0102cce:	c7 44 24 0c 50 58 10 	movl   $0xf0105850,0xc(%esp)
f0102cd5:	f0 
f0102cd6:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102cdd:	f0 
f0102cde:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0102ce5:	00 
f0102ce6:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102ced:	e8 a2 d3 ff ff       	call   f0100094 <_panic>
f0102cf2:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102cf5:	39 d0                	cmp    %edx,%eax
f0102cf7:	75 d0                	jne    f0102cc9 <mem_init+0x140d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102cf9:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102cfe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d04:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102d0a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d0d:	89 0d 60 95 11 f0    	mov    %ecx,0xf0119560

	// free the pages we took
	page_free(pp0);
f0102d13:	89 34 24             	mov    %esi,(%esp)
f0102d16:	e8 bb e8 ff ff       	call   f01015d6 <page_free>
	page_free(pp1);
f0102d1b:	89 3c 24             	mov    %edi,(%esp)
f0102d1e:	e8 b3 e8 ff ff       	call   f01015d6 <page_free>
	page_free(pp2);
f0102d23:	89 1c 24             	mov    %ebx,(%esp)
f0102d26:	e8 ab e8 ff ff       	call   f01015d6 <page_free>

	cprintf("check_page() succeeded!\n");
f0102d2b:	c7 04 24 67 58 10 f0 	movl   $0xf0105867,(%esp)
f0102d32:	e8 c3 07 00 00       	call   f01034fa <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0102d37:	a1 8c 99 11 f0       	mov    0xf011998c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d3c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d41:	77 20                	ja     f0102d63 <mem_init+0x14a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d47:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0102d4e:	f0 
f0102d4f:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102d56:	00 
f0102d57:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102d5e:	e8 31 d3 ff ff       	call   f0100094 <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f0102d63:	8b 15 84 99 11 f0    	mov    0xf0119984,%edx
f0102d69:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102d70:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0102d76:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102d7d:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d7e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d83:	89 04 24             	mov    %eax,(%esp)
f0102d86:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d8b:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102d90:	e8 3c e9 ff ff       	call   f01016d1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d95:	be 00 f0 10 f0       	mov    $0xf010f000,%esi
f0102d9a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102da0:	77 20                	ja     f0102dc2 <mem_init+0x1506>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102da6:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0102dad:	f0 
f0102dae:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f0102db5:	00 
f0102db6:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102dbd:	e8 d2 d2 ff ff       	call   f0100094 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0102dc2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102dc9:	00 
f0102dca:	c7 04 24 00 f0 10 00 	movl   $0x10f000,(%esp)
f0102dd1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dd6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102ddb:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102de0:	e8 ec e8 ff ff       	call   f01016d1 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0102de5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102dec:	00 
f0102ded:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102df4:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102df9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102dfe:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0102e03:	e8 c9 e8 ff ff       	call   f01016d1 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e08:	8b 1d 88 99 11 f0    	mov    0xf0119988,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102e0e:	8b 35 84 99 11 f0    	mov    0xf0119984,%esi
f0102e14:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102e17:	8d 3c f5 ff 0f 00 00 	lea    0xfff(,%esi,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102e1e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102e24:	74 79                	je     f0102e9f <mem_init+0x15e3>
f0102e26:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e2b:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e31:	89 d8                	mov    %ebx,%eax
f0102e33:	e8 7c e1 ff ff       	call   f0100fb4 <check_va2pa>
f0102e38:	8b 15 8c 99 11 f0    	mov    0xf011998c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e3e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102e44:	77 20                	ja     f0102e66 <mem_init+0x15aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e46:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e4a:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f0102e51:	f0 
f0102e52:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0102e59:	00 
f0102e5a:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102e61:	e8 2e d2 ff ff       	call   f0100094 <_panic>
f0102e66:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102e6d:	39 d0                	cmp    %edx,%eax
f0102e6f:	74 24                	je     f0102e95 <mem_init+0x15d9>
f0102e71:	c7 44 24 0c 34 54 10 	movl   $0xf0105434,0xc(%esp)
f0102e78:	f0 
f0102e79:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102e80:	f0 
f0102e81:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0102e88:	00 
f0102e89:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102e90:	e8 ff d1 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e95:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e9b:	39 f7                	cmp    %esi,%edi
f0102e9d:	77 8c                	ja     f0102e2b <mem_init+0x156f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e9f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102ea2:	c1 e7 0c             	shl    $0xc,%edi
f0102ea5:	85 ff                	test   %edi,%edi
f0102ea7:	74 44                	je     f0102eed <mem_init+0x1631>
f0102ea9:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102eae:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102eb4:	89 d8                	mov    %ebx,%eax
f0102eb6:	e8 f9 e0 ff ff       	call   f0100fb4 <check_va2pa>
f0102ebb:	39 c6                	cmp    %eax,%esi
f0102ebd:	74 24                	je     f0102ee3 <mem_init+0x1627>
f0102ebf:	c7 44 24 0c 68 54 10 	movl   $0xf0105468,0xc(%esp)
f0102ec6:	f0 
f0102ec7:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102ece:	f0 
f0102ecf:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0102ed6:	00 
f0102ed7:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102ede:	e8 b1 d1 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ee3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ee9:	39 fe                	cmp    %edi,%esi
f0102eeb:	72 c1                	jb     f0102eae <mem_init+0x15f2>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102eed:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102ef2:	89 d8                	mov    %ebx,%eax
f0102ef4:	e8 bb e0 ff ff       	call   f0100fb4 <check_va2pa>
f0102ef9:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102efe:	bf 00 f0 10 f0       	mov    $0xf010f000,%edi
f0102f03:	81 c7 00 70 00 20    	add    $0x20007000,%edi
f0102f09:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102f0c:	39 c2                	cmp    %eax,%edx
f0102f0e:	74 24                	je     f0102f34 <mem_init+0x1678>
f0102f10:	c7 44 24 0c 90 54 10 	movl   $0xf0105490,0xc(%esp)
f0102f17:	f0 
f0102f18:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102f1f:	f0 
f0102f20:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0102f27:	00 
f0102f28:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102f2f:	e8 60 d1 ff ff       	call   f0100094 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f34:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102f3a:	0f 85 37 05 00 00    	jne    f0103477 <mem_init+0x1bbb>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102f40:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102f45:	89 d8                	mov    %ebx,%eax
f0102f47:	e8 68 e0 ff ff       	call   f0100fb4 <check_va2pa>
f0102f4c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f4f:	74 24                	je     f0102f75 <mem_init+0x16b9>
f0102f51:	c7 44 24 0c d8 54 10 	movl   $0xf01054d8,0xc(%esp)
f0102f58:	f0 
f0102f59:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102f60:	f0 
f0102f61:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0102f68:	00 
f0102f69:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102f70:	e8 1f d1 ff ff       	call   f0100094 <_panic>
f0102f75:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f7a:	ba 01 00 00 00       	mov    $0x1,%edx
f0102f7f:	8d 88 44 fc ff ff    	lea    -0x3bc(%eax),%ecx
f0102f85:	83 f9 03             	cmp    $0x3,%ecx
f0102f88:	77 39                	ja     f0102fc3 <mem_init+0x1707>
f0102f8a:	89 d6                	mov    %edx,%esi
f0102f8c:	d3 e6                	shl    %cl,%esi
f0102f8e:	89 f1                	mov    %esi,%ecx
f0102f90:	f6 c1 0b             	test   $0xb,%cl
f0102f93:	74 2e                	je     f0102fc3 <mem_init+0x1707>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102f95:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f99:	0f 85 aa 00 00 00    	jne    f0103049 <mem_init+0x178d>
f0102f9f:	c7 44 24 0c 80 58 10 	movl   $0xf0105880,0xc(%esp)
f0102fa6:	f0 
f0102fa7:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102fae:	f0 
f0102faf:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0102fb6:	00 
f0102fb7:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102fbe:	e8 d1 d0 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102fc3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fc8:	76 55                	jbe    f010301f <mem_init+0x1763>
				assert(pgdir[i] & PTE_P);
f0102fca:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f0102fcd:	f6 c1 01             	test   $0x1,%cl
f0102fd0:	75 24                	jne    f0102ff6 <mem_init+0x173a>
f0102fd2:	c7 44 24 0c 80 58 10 	movl   $0xf0105880,0xc(%esp)
f0102fd9:	f0 
f0102fda:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0102fe1:	f0 
f0102fe2:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102fe9:	00 
f0102fea:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0102ff1:	e8 9e d0 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ff6:	f6 c1 02             	test   $0x2,%cl
f0102ff9:	75 4e                	jne    f0103049 <mem_init+0x178d>
f0102ffb:	c7 44 24 0c 91 58 10 	movl   $0xf0105891,0xc(%esp)
f0103002:	f0 
f0103003:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010300a:	f0 
f010300b:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0103012:	00 
f0103013:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010301a:	e8 75 d0 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f010301f:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103023:	74 24                	je     f0103049 <mem_init+0x178d>
f0103025:	c7 44 24 0c a2 58 10 	movl   $0xf01058a2,0xc(%esp)
f010302c:	f0 
f010302d:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0103034:	f0 
f0103035:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010303c:	00 
f010303d:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0103044:	e8 4b d0 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103049:	83 c0 01             	add    $0x1,%eax
f010304c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103051:	0f 85 28 ff ff ff    	jne    f0102f7f <mem_init+0x16c3>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103057:	c7 04 24 08 55 10 f0 	movl   $0xf0105508,(%esp)
f010305e:	e8 97 04 00 00       	call   f01034fa <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103063:	a1 88 99 11 f0       	mov    0xf0119988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103068:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010306d:	77 20                	ja     f010308f <mem_init+0x17d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010306f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103073:	c7 44 24 08 70 4c 10 	movl   $0xf0104c70,0x8(%esp)
f010307a:	f0 
f010307b:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0103082:	00 
f0103083:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010308a:	e8 05 d0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010308f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103094:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103097:	b8 00 00 00 00       	mov    $0x0,%eax
f010309c:	e8 87 e0 ff ff       	call   f0101128 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030a1:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01030a4:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030a9:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030ac:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030b6:	e8 9d e4 ff ff       	call   f0101558 <page_alloc>
f01030bb:	89 c6                	mov    %eax,%esi
f01030bd:	85 c0                	test   %eax,%eax
f01030bf:	75 24                	jne    f01030e5 <mem_init+0x1829>
f01030c1:	c7 44 24 0c b5 56 10 	movl   $0xf01056b5,0xc(%esp)
f01030c8:	f0 
f01030c9:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01030d0:	f0 
f01030d1:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01030d8:	00 
f01030d9:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01030e0:	e8 af cf ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01030e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030ec:	e8 67 e4 ff ff       	call   f0101558 <page_alloc>
f01030f1:	89 c7                	mov    %eax,%edi
f01030f3:	85 c0                	test   %eax,%eax
f01030f5:	75 24                	jne    f010311b <mem_init+0x185f>
f01030f7:	c7 44 24 0c cb 56 10 	movl   $0xf01056cb,0xc(%esp)
f01030fe:	f0 
f01030ff:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0103106:	f0 
f0103107:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010310e:	00 
f010310f:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0103116:	e8 79 cf ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010311b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103122:	e8 31 e4 ff ff       	call   f0101558 <page_alloc>
f0103127:	89 c3                	mov    %eax,%ebx
f0103129:	85 c0                	test   %eax,%eax
f010312b:	75 24                	jne    f0103151 <mem_init+0x1895>
f010312d:	c7 44 24 0c e1 56 10 	movl   $0xf01056e1,0xc(%esp)
f0103134:	f0 
f0103135:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010313c:	f0 
f010313d:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0103144:	00 
f0103145:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010314c:	e8 43 cf ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0103151:	89 34 24             	mov    %esi,(%esp)
f0103154:	e8 7d e4 ff ff       	call   f01015d6 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103159:	89 f8                	mov    %edi,%eax
f010315b:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f0103161:	c1 f8 03             	sar    $0x3,%eax
f0103164:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103167:	89 c2                	mov    %eax,%edx
f0103169:	c1 ea 0c             	shr    $0xc,%edx
f010316c:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f0103172:	72 20                	jb     f0103194 <mem_init+0x18d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103174:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103178:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f010317f:	f0 
f0103180:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103187:	00 
f0103188:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f010318f:	e8 00 cf ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103194:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010319b:	00 
f010319c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031a3:	00 
	return (void *)(pa + KERNBASE);
f01031a4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031a9:	89 04 24             	mov    %eax,(%esp)
f01031ac:	e8 30 10 00 00       	call   f01041e1 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031b1:	89 d8                	mov    %ebx,%eax
f01031b3:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f01031b9:	c1 f8 03             	sar    $0x3,%eax
f01031bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031bf:	89 c2                	mov    %eax,%edx
f01031c1:	c1 ea 0c             	shr    $0xc,%edx
f01031c4:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f01031ca:	72 20                	jb     f01031ec <mem_init+0x1930>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031d0:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f01031d7:	f0 
f01031d8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031df:	00 
f01031e0:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f01031e7:	e8 a8 ce ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031f3:	00 
f01031f4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031fb:	00 
	return (void *)(pa + KERNBASE);
f01031fc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103201:	89 04 24             	mov    %eax,(%esp)
f0103204:	e8 d8 0f 00 00       	call   f01041e1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103209:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103210:	00 
f0103211:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103218:	00 
f0103219:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010321d:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f0103222:	89 04 24             	mov    %eax,(%esp)
f0103225:	e8 e8 e5 ff ff       	call   f0101812 <page_insert>
	assert(pp1->pp_ref == 1);
f010322a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010322f:	74 24                	je     f0103255 <mem_init+0x1999>
f0103231:	c7 44 24 0c b2 57 10 	movl   $0xf01057b2,0xc(%esp)
f0103238:	f0 
f0103239:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0103240:	f0 
f0103241:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0103248:	00 
f0103249:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0103250:	e8 3f ce ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103255:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010325c:	01 01 01 
f010325f:	74 24                	je     f0103285 <mem_init+0x19c9>
f0103261:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f0103268:	f0 
f0103269:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0103270:	f0 
f0103271:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0103278:	00 
f0103279:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0103280:	e8 0f ce ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103285:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010328c:	00 
f010328d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103294:	00 
f0103295:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103299:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f010329e:	89 04 24             	mov    %eax,(%esp)
f01032a1:	e8 6c e5 ff ff       	call   f0101812 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032a6:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032ad:	02 02 02 
f01032b0:	74 24                	je     f01032d6 <mem_init+0x1a1a>
f01032b2:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f01032b9:	f0 
f01032ba:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01032c1:	f0 
f01032c2:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01032c9:	00 
f01032ca:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01032d1:	e8 be cd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01032d6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032db:	74 24                	je     f0103301 <mem_init+0x1a45>
f01032dd:	c7 44 24 0c de 57 10 	movl   $0xf01057de,0xc(%esp)
f01032e4:	f0 
f01032e5:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01032ec:	f0 
f01032ed:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01032f4:	00 
f01032f5:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01032fc:	e8 93 cd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0103301:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103306:	74 24                	je     f010332c <mem_init+0x1a70>
f0103308:	c7 44 24 0c 27 58 10 	movl   $0xf0105827,0xc(%esp)
f010330f:	f0 
f0103310:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0103317:	f0 
f0103318:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f010331f:	00 
f0103320:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0103327:	e8 68 cd ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010332c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103333:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103336:	89 d8                	mov    %ebx,%eax
f0103338:	2b 05 8c 99 11 f0    	sub    0xf011998c,%eax
f010333e:	c1 f8 03             	sar    $0x3,%eax
f0103341:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103344:	89 c2                	mov    %eax,%edx
f0103346:	c1 ea 0c             	shr    $0xc,%edx
f0103349:	3b 15 84 99 11 f0    	cmp    0xf0119984,%edx
f010334f:	72 20                	jb     f0103371 <mem_init+0x1ab5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103351:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103355:	c7 44 24 08 88 4e 10 	movl   $0xf0104e88,0x8(%esp)
f010335c:	f0 
f010335d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103364:	00 
f0103365:	c7 04 24 f0 55 10 f0 	movl   $0xf01055f0,(%esp)
f010336c:	e8 23 cd ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103371:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103378:	03 03 03 
f010337b:	74 24                	je     f01033a1 <mem_init+0x1ae5>
f010337d:	c7 44 24 0c 70 55 10 	movl   $0xf0105570,0xc(%esp)
f0103384:	f0 
f0103385:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010338c:	f0 
f010338d:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0103394:	00 
f0103395:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010339c:	e8 f3 cc ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033a1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033a8:	00 
f01033a9:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01033ae:	89 04 24             	mov    %eax,(%esp)
f01033b1:	e8 0c e4 ff ff       	call   f01017c2 <page_remove>
	assert(pp2->pp_ref == 0);
f01033b6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01033bb:	74 24                	je     f01033e1 <mem_init+0x1b25>
f01033bd:	c7 44 24 0c 16 58 10 	movl   $0xf0105816,0xc(%esp)
f01033c4:	f0 
f01033c5:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f01033cc:	f0 
f01033cd:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01033d4:	00 
f01033d5:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f01033dc:	e8 b3 cc ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033e1:	a1 88 99 11 f0       	mov    0xf0119988,%eax
f01033e6:	8b 08                	mov    (%eax),%ecx
f01033e8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033ee:	89 f2                	mov    %esi,%edx
f01033f0:	2b 15 8c 99 11 f0    	sub    0xf011998c,%edx
f01033f6:	c1 fa 03             	sar    $0x3,%edx
f01033f9:	c1 e2 0c             	shl    $0xc,%edx
f01033fc:	39 d1                	cmp    %edx,%ecx
f01033fe:	74 24                	je     f0103424 <mem_init+0x1b68>
f0103400:	c7 44 24 0c ec 50 10 	movl   $0xf01050ec,0xc(%esp)
f0103407:	f0 
f0103408:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f010340f:	f0 
f0103410:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0103417:	00 
f0103418:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f010341f:	e8 70 cc ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0103424:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010342a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010342f:	74 24                	je     f0103455 <mem_init+0x1b99>
f0103431:	c7 44 24 0c c3 57 10 	movl   $0xf01057c3,0xc(%esp)
f0103438:	f0 
f0103439:	c7 44 24 08 0a 56 10 	movl   $0xf010560a,0x8(%esp)
f0103440:	f0 
f0103441:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0103448:	00 
f0103449:	c7 04 24 c8 55 10 f0 	movl   $0xf01055c8,(%esp)
f0103450:	e8 3f cc ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0103455:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010345b:	89 34 24             	mov    %esi,(%esp)
f010345e:	e8 73 e1 ff ff       	call   f01015d6 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103463:	c7 04 24 9c 55 10 f0 	movl   $0xf010559c,(%esp)
f010346a:	e8 8b 00 00 00       	call   f01034fa <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010346f:	83 c4 3c             	add    $0x3c,%esp
f0103472:	5b                   	pop    %ebx
f0103473:	5e                   	pop    %esi
f0103474:	5f                   	pop    %edi
f0103475:	5d                   	pop    %ebp
f0103476:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103477:	89 f2                	mov    %esi,%edx
f0103479:	89 d8                	mov    %ebx,%eax
f010347b:	e8 34 db ff ff       	call   f0100fb4 <check_va2pa>
f0103480:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103486:	e9 7e fa ff ff       	jmp    f0102f09 <mem_init+0x164d>
	...

f010348c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010348c:	55                   	push   %ebp
f010348d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010348f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103494:	8b 45 08             	mov    0x8(%ebp),%eax
f0103497:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103498:	b2 71                	mov    $0x71,%dl
f010349a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010349b:	0f b6 c0             	movzbl %al,%eax
}
f010349e:	5d                   	pop    %ebp
f010349f:	c3                   	ret    

f01034a0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034a0:	55                   	push   %ebp
f01034a1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01034a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ab:	ee                   	out    %al,(%dx)
f01034ac:	b2 71                	mov    $0x71,%dl
f01034ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034b1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034b2:	5d                   	pop    %ebp
f01034b3:	c3                   	ret    

f01034b4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01034b4:	55                   	push   %ebp
f01034b5:	89 e5                	mov    %esp,%ebp
f01034b7:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01034ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01034bd:	89 04 24             	mov    %eax,(%esp)
f01034c0:	e8 2b d1 ff ff       	call   f01005f0 <cputchar>
	*cnt++;
}
f01034c5:	c9                   	leave  
f01034c6:	c3                   	ret    

f01034c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01034c7:	55                   	push   %ebp
f01034c8:	89 e5                	mov    %esp,%ebp
f01034ca:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01034cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01034d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034db:	8b 45 08             	mov    0x8(%ebp),%eax
f01034de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01034e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e9:	c7 04 24 b4 34 10 f0 	movl   $0xf01034b4,(%esp)
f01034f0:	e8 b5 04 00 00       	call   f01039aa <vprintfmt>
	return cnt;
}
f01034f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034f8:	c9                   	leave  
f01034f9:	c3                   	ret    

f01034fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01034fa:	55                   	push   %ebp
f01034fb:	89 e5                	mov    %esp,%ebp
f01034fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103500:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103503:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103507:	8b 45 08             	mov    0x8(%ebp),%eax
f010350a:	89 04 24             	mov    %eax,(%esp)
f010350d:	e8 b5 ff ff ff       	call   f01034c7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103512:	c9                   	leave  
f0103513:	c3                   	ret    

f0103514 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103514:	55                   	push   %ebp
f0103515:	89 e5                	mov    %esp,%ebp
f0103517:	57                   	push   %edi
f0103518:	56                   	push   %esi
f0103519:	53                   	push   %ebx
f010351a:	83 ec 10             	sub    $0x10,%esp
f010351d:	89 c3                	mov    %eax,%ebx
f010351f:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103522:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103525:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103528:	8b 0a                	mov    (%edx),%ecx
f010352a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010352d:	8b 00                	mov    (%eax),%eax
f010352f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103532:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0103539:	eb 77                	jmp    f01035b2 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f010353b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010353e:	01 c8                	add    %ecx,%eax
f0103540:	bf 02 00 00 00       	mov    $0x2,%edi
f0103545:	99                   	cltd   
f0103546:	f7 ff                	idiv   %edi
f0103548:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010354a:	eb 01                	jmp    f010354d <stab_binsearch+0x39>
			m--;
f010354c:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010354d:	39 ca                	cmp    %ecx,%edx
f010354f:	7c 1d                	jl     f010356e <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103551:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103554:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0103559:	39 f7                	cmp    %esi,%edi
f010355b:	75 ef                	jne    f010354c <stab_binsearch+0x38>
f010355d:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103560:	6b fa 0c             	imul   $0xc,%edx,%edi
f0103563:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0103567:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f010356a:	73 18                	jae    f0103584 <stab_binsearch+0x70>
f010356c:	eb 05                	jmp    f0103573 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010356e:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0103571:	eb 3f                	jmp    f01035b2 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103573:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103576:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0103578:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010357b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0103582:	eb 2e                	jmp    f01035b2 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103584:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0103587:	76 15                	jbe    f010359e <stab_binsearch+0x8a>
			*region_right = m - 1;
f0103589:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010358c:	4f                   	dec    %edi
f010358d:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0103590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103593:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103595:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f010359c:	eb 14                	jmp    f01035b2 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010359e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01035a1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01035a4:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f01035a6:	ff 45 0c             	incl   0xc(%ebp)
f01035a9:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01035ab:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01035b2:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01035b5:	7e 84                	jle    f010353b <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01035b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01035bb:	75 0d                	jne    f01035ca <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f01035bd:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01035c0:	8b 02                	mov    (%edx),%eax
f01035c2:	48                   	dec    %eax
f01035c3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01035c6:	89 01                	mov    %eax,(%ecx)
f01035c8:	eb 22                	jmp    f01035ec <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01035cd:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01035cf:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01035d2:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035d4:	eb 01                	jmp    f01035d7 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01035d6:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035d7:	39 c1                	cmp    %eax,%ecx
f01035d9:	7d 0c                	jge    f01035e7 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01035db:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f01035de:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f01035e3:	39 f2                	cmp    %esi,%edx
f01035e5:	75 ef                	jne    f01035d6 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f01035e7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01035ea:	89 02                	mov    %eax,(%edx)
	}
}
f01035ec:	83 c4 10             	add    $0x10,%esp
f01035ef:	5b                   	pop    %ebx
f01035f0:	5e                   	pop    %esi
f01035f1:	5f                   	pop    %edi
f01035f2:	5d                   	pop    %ebp
f01035f3:	c3                   	ret    

f01035f4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01035f4:	55                   	push   %ebp
f01035f5:	89 e5                	mov    %esp,%ebp
f01035f7:	83 ec 58             	sub    $0x58,%esp
f01035fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01035fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103600:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103603:	8b 75 08             	mov    0x8(%ebp),%esi
f0103606:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103609:	c7 03 b0 58 10 f0    	movl   $0xf01058b0,(%ebx)
	info->eip_line = 0;
f010360f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103616:	c7 43 08 b0 58 10 f0 	movl   $0xf01058b0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010361d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103624:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103627:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010362e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103634:	76 12                	jbe    f0103648 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103636:	b8 28 e8 10 f0       	mov    $0xf010e828,%eax
f010363b:	3d 89 c8 10 f0       	cmp    $0xf010c889,%eax
f0103640:	0f 86 f1 01 00 00    	jbe    f0103837 <debuginfo_eip+0x243>
f0103646:	eb 1c                	jmp    f0103664 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103648:	c7 44 24 08 ba 58 10 	movl   $0xf01058ba,0x8(%esp)
f010364f:	f0 
f0103650:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103657:	00 
f0103658:	c7 04 24 c7 58 10 f0 	movl   $0xf01058c7,(%esp)
f010365f:	e8 30 ca ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103669:	80 3d 27 e8 10 f0 00 	cmpb   $0x0,0xf010e827
f0103670:	0f 85 cd 01 00 00    	jne    f0103843 <debuginfo_eip+0x24f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103676:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010367d:	b8 88 c8 10 f0       	mov    $0xf010c888,%eax
f0103682:	2d fc 5a 10 f0       	sub    $0xf0105afc,%eax
f0103687:	c1 f8 02             	sar    $0x2,%eax
f010368a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103690:	83 e8 01             	sub    $0x1,%eax
f0103693:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103696:	89 74 24 04          	mov    %esi,0x4(%esp)
f010369a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01036a1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01036a4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01036a7:	b8 fc 5a 10 f0       	mov    $0xf0105afc,%eax
f01036ac:	e8 63 fe ff ff       	call   f0103514 <stab_binsearch>
	if (lfile == 0)
f01036b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01036b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01036b9:	85 d2                	test   %edx,%edx
f01036bb:	0f 84 82 01 00 00    	je     f0103843 <debuginfo_eip+0x24f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01036c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01036c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01036ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036ce:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01036d5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01036d8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01036db:	b8 fc 5a 10 f0       	mov    $0xf0105afc,%eax
f01036e0:	e8 2f fe ff ff       	call   f0103514 <stab_binsearch>

	if (lfun <= rfun) {
f01036e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01036eb:	39 d0                	cmp    %edx,%eax
f01036ed:	7f 3d                	jg     f010372c <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01036ef:	6b c8 0c             	imul   $0xc,%eax,%ecx
f01036f2:	8d b9 fc 5a 10 f0    	lea    -0xfefa504(%ecx),%edi
f01036f8:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01036fb:	8b 89 fc 5a 10 f0    	mov    -0xfefa504(%ecx),%ecx
f0103701:	bf 28 e8 10 f0       	mov    $0xf010e828,%edi
f0103706:	81 ef 89 c8 10 f0    	sub    $0xf010c889,%edi
f010370c:	39 f9                	cmp    %edi,%ecx
f010370e:	73 09                	jae    f0103719 <debuginfo_eip+0x125>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103710:	81 c1 89 c8 10 f0    	add    $0xf010c889,%ecx
f0103716:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103719:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010371c:	8b 4f 08             	mov    0x8(%edi),%ecx
f010371f:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103722:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103724:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103727:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010372a:	eb 0f                	jmp    f010373b <debuginfo_eip+0x147>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010372c:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010372f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103732:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103735:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103738:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010373b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103742:	00 
f0103743:	8b 43 08             	mov    0x8(%ebx),%eax
f0103746:	89 04 24             	mov    %eax,(%esp)
f0103749:	e8 6c 0a 00 00       	call   f01041ba <strfind>
f010374e:	2b 43 08             	sub    0x8(%ebx),%eax
f0103751:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103754:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103758:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010375f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103762:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103765:	b8 fc 5a 10 f0       	mov    $0xf0105afc,%eax
f010376a:	e8 a5 fd ff ff       	call   f0103514 <stab_binsearch>

	if(lline <= rline)
f010376f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0103772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f0103777:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010377a:	0f 8f c3 00 00 00    	jg     f0103843 <debuginfo_eip+0x24f>
		info->eip_line = stabs[lline].n_desc;
f0103780:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103783:	0f b7 82 02 5b 10 f0 	movzwl -0xfefa4fe(%edx),%eax
f010378a:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010378d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103790:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103793:	39 c8                	cmp    %ecx,%eax
f0103795:	7c 5f                	jl     f01037f6 <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f0103797:	89 c2                	mov    %eax,%edx
f0103799:	6b f0 0c             	imul   $0xc,%eax,%esi
f010379c:	80 be 00 5b 10 f0 84 	cmpb   $0x84,-0xfefa500(%esi)
f01037a3:	75 18                	jne    f01037bd <debuginfo_eip+0x1c9>
f01037a5:	eb 30                	jmp    f01037d7 <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01037a7:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01037aa:	39 c1                	cmp    %eax,%ecx
f01037ac:	7f 48                	jg     f01037f6 <debuginfo_eip+0x202>
	       && stabs[lline].n_type != N_SOL
f01037ae:	89 c2                	mov    %eax,%edx
f01037b0:	8d 34 40             	lea    (%eax,%eax,2),%esi
f01037b3:	80 3c b5 00 5b 10 f0 	cmpb   $0x84,-0xfefa500(,%esi,4)
f01037ba:	84 
f01037bb:	74 1a                	je     f01037d7 <debuginfo_eip+0x1e3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01037bd:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01037c0:	8d 14 95 fc 5a 10 f0 	lea    -0xfefa504(,%edx,4),%edx
f01037c7:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f01037cb:	75 da                	jne    f01037a7 <debuginfo_eip+0x1b3>
f01037cd:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01037d1:	74 d4                	je     f01037a7 <debuginfo_eip+0x1b3>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01037d3:	39 c1                	cmp    %eax,%ecx
f01037d5:	7f 1f                	jg     f01037f6 <debuginfo_eip+0x202>
f01037d7:	6b c0 0c             	imul   $0xc,%eax,%eax
f01037da:	8b 80 fc 5a 10 f0    	mov    -0xfefa504(%eax),%eax
f01037e0:	ba 28 e8 10 f0       	mov    $0xf010e828,%edx
f01037e5:	81 ea 89 c8 10 f0    	sub    $0xf010c889,%edx
f01037eb:	39 d0                	cmp    %edx,%eax
f01037ed:	73 07                	jae    f01037f6 <debuginfo_eip+0x202>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01037ef:	05 89 c8 10 f0       	add    $0xf010c889,%eax
f01037f4:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01037f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037f9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01037fc:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103801:	39 ca                	cmp    %ecx,%edx
f0103803:	7d 3e                	jge    f0103843 <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
f0103805:	83 c2 01             	add    $0x1,%edx
f0103808:	39 d1                	cmp    %edx,%ecx
f010380a:	7e 37                	jle    f0103843 <debuginfo_eip+0x24f>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010380c:	6b f2 0c             	imul   $0xc,%edx,%esi
f010380f:	80 be 00 5b 10 f0 a0 	cmpb   $0xa0,-0xfefa500(%esi)
f0103816:	75 2b                	jne    f0103843 <debuginfo_eip+0x24f>
		     lline++)
			info->eip_fn_narg++;
f0103818:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010381c:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010381f:	39 d1                	cmp    %edx,%ecx
f0103821:	7e 1b                	jle    f010383e <debuginfo_eip+0x24a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103823:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103826:	80 3c 85 00 5b 10 f0 	cmpb   $0xa0,-0xfefa500(,%eax,4)
f010382d:	a0 
f010382e:	74 e8                	je     f0103818 <debuginfo_eip+0x224>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103830:	b8 00 00 00 00       	mov    $0x0,%eax
f0103835:	eb 0c                	jmp    f0103843 <debuginfo_eip+0x24f>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010383c:	eb 05                	jmp    f0103843 <debuginfo_eip+0x24f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010383e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103843:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103846:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103849:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010384c:	89 ec                	mov    %ebp,%esp
f010384e:	5d                   	pop    %ebp
f010384f:	c3                   	ret    

f0103850 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103850:	55                   	push   %ebp
f0103851:	89 e5                	mov    %esp,%ebp
f0103853:	57                   	push   %edi
f0103854:	56                   	push   %esi
f0103855:	53                   	push   %ebx
f0103856:	83 ec 3c             	sub    $0x3c,%esp
f0103859:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010385c:	89 d7                	mov    %edx,%edi
f010385e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103861:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103864:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103867:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010386a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010386d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103870:	b8 00 00 00 00       	mov    $0x0,%eax
f0103875:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103878:	72 11                	jb     f010388b <printnum+0x3b>
f010387a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010387d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103880:	76 09                	jbe    f010388b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103882:	83 eb 01             	sub    $0x1,%ebx
f0103885:	85 db                	test   %ebx,%ebx
f0103887:	7f 51                	jg     f01038da <printnum+0x8a>
f0103889:	eb 5e                	jmp    f01038e9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010388b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010388f:	83 eb 01             	sub    $0x1,%ebx
f0103892:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103896:	8b 45 10             	mov    0x10(%ebp),%eax
f0103899:	89 44 24 08          	mov    %eax,0x8(%esp)
f010389d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01038a1:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01038a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01038ac:	00 
f01038ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01038b0:	89 04 24             	mov    %eax,(%esp)
f01038b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038ba:	e8 71 0b 00 00       	call   f0104430 <__udivdi3>
f01038bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01038c7:	89 04 24             	mov    %eax,(%esp)
f01038ca:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038ce:	89 fa                	mov    %edi,%edx
f01038d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038d3:	e8 78 ff ff ff       	call   f0103850 <printnum>
f01038d8:	eb 0f                	jmp    f01038e9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01038da:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038de:	89 34 24             	mov    %esi,(%esp)
f01038e1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01038e4:	83 eb 01             	sub    $0x1,%ebx
f01038e7:	75 f1                	jne    f01038da <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01038e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01038f1:	8b 45 10             	mov    0x10(%ebp),%eax
f01038f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01038ff:	00 
f0103900:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103903:	89 04 24             	mov    %eax,(%esp)
f0103906:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103909:	89 44 24 04          	mov    %eax,0x4(%esp)
f010390d:	e8 4e 0c 00 00       	call   f0104560 <__umoddi3>
f0103912:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103916:	0f be 80 d5 58 10 f0 	movsbl -0xfefa72b(%eax),%eax
f010391d:	89 04 24             	mov    %eax,(%esp)
f0103920:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103923:	83 c4 3c             	add    $0x3c,%esp
f0103926:	5b                   	pop    %ebx
f0103927:	5e                   	pop    %esi
f0103928:	5f                   	pop    %edi
f0103929:	5d                   	pop    %ebp
f010392a:	c3                   	ret    

f010392b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010392b:	55                   	push   %ebp
f010392c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010392e:	83 fa 01             	cmp    $0x1,%edx
f0103931:	7e 0e                	jle    f0103941 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103933:	8b 10                	mov    (%eax),%edx
f0103935:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103938:	89 08                	mov    %ecx,(%eax)
f010393a:	8b 02                	mov    (%edx),%eax
f010393c:	8b 52 04             	mov    0x4(%edx),%edx
f010393f:	eb 22                	jmp    f0103963 <getuint+0x38>
	else if (lflag)
f0103941:	85 d2                	test   %edx,%edx
f0103943:	74 10                	je     f0103955 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103945:	8b 10                	mov    (%eax),%edx
f0103947:	8d 4a 04             	lea    0x4(%edx),%ecx
f010394a:	89 08                	mov    %ecx,(%eax)
f010394c:	8b 02                	mov    (%edx),%eax
f010394e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103953:	eb 0e                	jmp    f0103963 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103955:	8b 10                	mov    (%eax),%edx
f0103957:	8d 4a 04             	lea    0x4(%edx),%ecx
f010395a:	89 08                	mov    %ecx,(%eax)
f010395c:	8b 02                	mov    (%edx),%eax
f010395e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103963:	5d                   	pop    %ebp
f0103964:	c3                   	ret    

f0103965 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103965:	55                   	push   %ebp
f0103966:	89 e5                	mov    %esp,%ebp
f0103968:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010396b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010396f:	8b 10                	mov    (%eax),%edx
f0103971:	3b 50 04             	cmp    0x4(%eax),%edx
f0103974:	73 0a                	jae    f0103980 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103976:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103979:	88 0a                	mov    %cl,(%edx)
f010397b:	83 c2 01             	add    $0x1,%edx
f010397e:	89 10                	mov    %edx,(%eax)
}
f0103980:	5d                   	pop    %ebp
f0103981:	c3                   	ret    

f0103982 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103982:	55                   	push   %ebp
f0103983:	89 e5                	mov    %esp,%ebp
f0103985:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103988:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010398b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010398f:	8b 45 10             	mov    0x10(%ebp),%eax
f0103992:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103996:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103999:	89 44 24 04          	mov    %eax,0x4(%esp)
f010399d:	8b 45 08             	mov    0x8(%ebp),%eax
f01039a0:	89 04 24             	mov    %eax,(%esp)
f01039a3:	e8 02 00 00 00       	call   f01039aa <vprintfmt>
	va_end(ap);
}
f01039a8:	c9                   	leave  
f01039a9:	c3                   	ret    

f01039aa <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01039aa:	55                   	push   %ebp
f01039ab:	89 e5                	mov    %esp,%ebp
f01039ad:	57                   	push   %edi
f01039ae:	56                   	push   %esi
f01039af:	53                   	push   %ebx
f01039b0:	83 ec 5c             	sub    $0x5c,%esp
f01039b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039b6:	8b 75 10             	mov    0x10(%ebp),%esi
f01039b9:	eb 12                	jmp    f01039cd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01039bb:	85 c0                	test   %eax,%eax
f01039bd:	0f 84 e4 04 00 00    	je     f0103ea7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f01039c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01039c7:	89 04 24             	mov    %eax,(%esp)
f01039ca:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039cd:	0f b6 06             	movzbl (%esi),%eax
f01039d0:	83 c6 01             	add    $0x1,%esi
f01039d3:	83 f8 25             	cmp    $0x25,%eax
f01039d6:	75 e3                	jne    f01039bb <vprintfmt+0x11>
f01039d8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f01039dc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f01039e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01039e8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01039ef:	b9 00 00 00 00       	mov    $0x0,%ecx
f01039f4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01039f7:	eb 2b                	jmp    f0103a24 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01039fc:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0103a00:	eb 22                	jmp    f0103a24 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a02:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103a05:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0103a09:	eb 19                	jmp    f0103a24 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a0b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103a0e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0103a15:	eb 0d                	jmp    f0103a24 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103a17:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103a1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103a1d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a24:	0f b6 06             	movzbl (%esi),%eax
f0103a27:	0f b6 d0             	movzbl %al,%edx
f0103a2a:	8d 7e 01             	lea    0x1(%esi),%edi
f0103a2d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103a30:	83 e8 23             	sub    $0x23,%eax
f0103a33:	3c 55                	cmp    $0x55,%al
f0103a35:	0f 87 46 04 00 00    	ja     f0103e81 <vprintfmt+0x4d7>
f0103a3b:	0f b6 c0             	movzbl %al,%eax
f0103a3e:	ff 24 85 78 59 10 f0 	jmp    *-0xfefa688(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103a45:	83 ea 30             	sub    $0x30,%edx
f0103a48:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0103a4b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0103a4f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a52:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0103a55:	83 fa 09             	cmp    $0x9,%edx
f0103a58:	77 4a                	ja     f0103aa4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a5a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103a5d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0103a60:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0103a63:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103a67:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103a6a:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103a6d:	83 fa 09             	cmp    $0x9,%edx
f0103a70:	76 eb                	jbe    f0103a5d <vprintfmt+0xb3>
f0103a72:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0103a75:	eb 2d                	jmp    f0103aa4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103a77:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a7a:	8d 50 04             	lea    0x4(%eax),%edx
f0103a7d:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a80:	8b 00                	mov    (%eax),%eax
f0103a82:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a85:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103a88:	eb 1a                	jmp    f0103aa4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a8a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0103a8d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103a91:	79 91                	jns    f0103a24 <vprintfmt+0x7a>
f0103a93:	e9 73 ff ff ff       	jmp    f0103a0b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a98:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103a9b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0103aa2:	eb 80                	jmp    f0103a24 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0103aa4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103aa8:	0f 89 76 ff ff ff    	jns    f0103a24 <vprintfmt+0x7a>
f0103aae:	e9 64 ff ff ff       	jmp    f0103a17 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ab3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ab6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103ab9:	e9 66 ff ff ff       	jmp    f0103a24 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103abe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ac1:	8d 50 04             	lea    0x4(%eax),%edx
f0103ac4:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ac7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103acb:	8b 00                	mov    (%eax),%eax
f0103acd:	89 04 24             	mov    %eax,(%esp)
f0103ad0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ad3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103ad6:	e9 f2 fe ff ff       	jmp    f01039cd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0103adb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0103adf:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f0103ae2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f0103ae6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0103ae9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0103aed:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0103af0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0103af3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0103af7:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0103afa:	80 f9 09             	cmp    $0x9,%cl
f0103afd:	77 1d                	ja     f0103b1c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0103aff:	0f be c0             	movsbl %al,%eax
f0103b02:	6b c0 64             	imul   $0x64,%eax,%eax
f0103b05:	0f be d2             	movsbl %dl,%edx
f0103b08:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103b0b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0103b12:	a3 04 93 11 f0       	mov    %eax,0xf0119304
f0103b17:	e9 b1 fe ff ff       	jmp    f01039cd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0103b1c:	c7 44 24 04 ed 58 10 	movl   $0xf01058ed,0x4(%esp)
f0103b23:	f0 
f0103b24:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103b27:	89 04 24             	mov    %eax,(%esp)
f0103b2a:	e8 dc 05 00 00       	call   f010410b <strcmp>
f0103b2f:	85 c0                	test   %eax,%eax
f0103b31:	75 0f                	jne    f0103b42 <vprintfmt+0x198>
f0103b33:	c7 05 04 93 11 f0 04 	movl   $0x4,0xf0119304
f0103b3a:	00 00 00 
f0103b3d:	e9 8b fe ff ff       	jmp    f01039cd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0103b42:	c7 44 24 04 f1 58 10 	movl   $0xf01058f1,0x4(%esp)
f0103b49:	f0 
f0103b4a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b4d:	89 14 24             	mov    %edx,(%esp)
f0103b50:	e8 b6 05 00 00       	call   f010410b <strcmp>
f0103b55:	85 c0                	test   %eax,%eax
f0103b57:	75 0f                	jne    f0103b68 <vprintfmt+0x1be>
f0103b59:	c7 05 04 93 11 f0 02 	movl   $0x2,0xf0119304
f0103b60:	00 00 00 
f0103b63:	e9 65 fe ff ff       	jmp    f01039cd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0103b68:	c7 44 24 04 f5 58 10 	movl   $0xf01058f5,0x4(%esp)
f0103b6f:	f0 
f0103b70:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0103b73:	89 0c 24             	mov    %ecx,(%esp)
f0103b76:	e8 90 05 00 00       	call   f010410b <strcmp>
f0103b7b:	85 c0                	test   %eax,%eax
f0103b7d:	75 0f                	jne    f0103b8e <vprintfmt+0x1e4>
f0103b7f:	c7 05 04 93 11 f0 01 	movl   $0x1,0xf0119304
f0103b86:	00 00 00 
f0103b89:	e9 3f fe ff ff       	jmp    f01039cd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0103b8e:	c7 44 24 04 f9 58 10 	movl   $0xf01058f9,0x4(%esp)
f0103b95:	f0 
f0103b96:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0103b99:	89 3c 24             	mov    %edi,(%esp)
f0103b9c:	e8 6a 05 00 00       	call   f010410b <strcmp>
f0103ba1:	85 c0                	test   %eax,%eax
f0103ba3:	75 0f                	jne    f0103bb4 <vprintfmt+0x20a>
f0103ba5:	c7 05 04 93 11 f0 06 	movl   $0x6,0xf0119304
f0103bac:	00 00 00 
f0103baf:	e9 19 fe ff ff       	jmp    f01039cd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f0103bb4:	c7 44 24 04 fd 58 10 	movl   $0xf01058fd,0x4(%esp)
f0103bbb:	f0 
f0103bbc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103bbf:	89 04 24             	mov    %eax,(%esp)
f0103bc2:	e8 44 05 00 00       	call   f010410b <strcmp>
f0103bc7:	85 c0                	test   %eax,%eax
f0103bc9:	75 0f                	jne    f0103bda <vprintfmt+0x230>
f0103bcb:	c7 05 04 93 11 f0 07 	movl   $0x7,0xf0119304
f0103bd2:	00 00 00 
f0103bd5:	e9 f3 fd ff ff       	jmp    f01039cd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0103bda:	c7 44 24 04 01 59 10 	movl   $0xf0105901,0x4(%esp)
f0103be1:	f0 
f0103be2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103be5:	89 14 24             	mov    %edx,(%esp)
f0103be8:	e8 1e 05 00 00       	call   f010410b <strcmp>
f0103bed:	83 f8 01             	cmp    $0x1,%eax
f0103bf0:	19 c0                	sbb    %eax,%eax
f0103bf2:	f7 d0                	not    %eax
f0103bf4:	83 c0 08             	add    $0x8,%eax
f0103bf7:	a3 04 93 11 f0       	mov    %eax,0xf0119304
f0103bfc:	e9 cc fd ff ff       	jmp    f01039cd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0103c01:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c04:	8d 50 04             	lea    0x4(%eax),%edx
f0103c07:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c0a:	8b 00                	mov    (%eax),%eax
f0103c0c:	89 c2                	mov    %eax,%edx
f0103c0e:	c1 fa 1f             	sar    $0x1f,%edx
f0103c11:	31 d0                	xor    %edx,%eax
f0103c13:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103c15:	83 f8 06             	cmp    $0x6,%eax
f0103c18:	7f 0b                	jg     f0103c25 <vprintfmt+0x27b>
f0103c1a:	8b 14 85 d0 5a 10 f0 	mov    -0xfefa530(,%eax,4),%edx
f0103c21:	85 d2                	test   %edx,%edx
f0103c23:	75 23                	jne    f0103c48 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0103c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c29:	c7 44 24 08 05 59 10 	movl   $0xf0105905,0x8(%esp)
f0103c30:	f0 
f0103c31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c35:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c38:	89 3c 24             	mov    %edi,(%esp)
f0103c3b:	e8 42 fd ff ff       	call   f0103982 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c40:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103c43:	e9 85 fd ff ff       	jmp    f01039cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103c48:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103c4c:	c7 44 24 08 1c 56 10 	movl   $0xf010561c,0x8(%esp)
f0103c53:	f0 
f0103c54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c58:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c5b:	89 3c 24             	mov    %edi,(%esp)
f0103c5e:	e8 1f fd ff ff       	call   f0103982 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c63:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103c66:	e9 62 fd ff ff       	jmp    f01039cd <vprintfmt+0x23>
f0103c6b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103c6e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103c71:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103c74:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c77:	8d 50 04             	lea    0x4(%eax),%edx
f0103c7a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c7d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103c7f:	85 f6                	test   %esi,%esi
f0103c81:	b8 e6 58 10 f0       	mov    $0xf01058e6,%eax
f0103c86:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0103c89:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0103c8d:	7e 06                	jle    f0103c95 <vprintfmt+0x2eb>
f0103c8f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0103c93:	75 13                	jne    f0103ca8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103c95:	0f be 06             	movsbl (%esi),%eax
f0103c98:	83 c6 01             	add    $0x1,%esi
f0103c9b:	85 c0                	test   %eax,%eax
f0103c9d:	0f 85 94 00 00 00    	jne    f0103d37 <vprintfmt+0x38d>
f0103ca3:	e9 81 00 00 00       	jmp    f0103d29 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ca8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103cac:	89 34 24             	mov    %esi,(%esp)
f0103caf:	e8 67 03 00 00       	call   f010401b <strnlen>
f0103cb4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103cb7:	29 c2                	sub    %eax,%edx
f0103cb9:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0103cbc:	85 d2                	test   %edx,%edx
f0103cbe:	7e d5                	jle    f0103c95 <vprintfmt+0x2eb>
					putch(padc, putdat);
f0103cc0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0103cc4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0103cc7:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0103cca:	89 d6                	mov    %edx,%esi
f0103ccc:	89 cf                	mov    %ecx,%edi
f0103cce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cd2:	89 3c 24             	mov    %edi,(%esp)
f0103cd5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103cd8:	83 ee 01             	sub    $0x1,%esi
f0103cdb:	75 f1                	jne    f0103cce <vprintfmt+0x324>
f0103cdd:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103ce0:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0103ce3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103ce6:	eb ad                	jmp    f0103c95 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103ce8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0103cec:	74 1b                	je     f0103d09 <vprintfmt+0x35f>
f0103cee:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103cf1:	83 fa 5e             	cmp    $0x5e,%edx
f0103cf4:	76 13                	jbe    f0103d09 <vprintfmt+0x35f>
					putch('?', putdat);
f0103cf6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cfd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103d04:	ff 55 08             	call   *0x8(%ebp)
f0103d07:	eb 0d                	jmp    f0103d16 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0103d09:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103d0c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d10:	89 04 24             	mov    %eax,(%esp)
f0103d13:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103d16:	83 eb 01             	sub    $0x1,%ebx
f0103d19:	0f be 06             	movsbl (%esi),%eax
f0103d1c:	83 c6 01             	add    $0x1,%esi
f0103d1f:	85 c0                	test   %eax,%eax
f0103d21:	75 1a                	jne    f0103d3d <vprintfmt+0x393>
f0103d23:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0103d26:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d29:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103d2c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103d30:	7f 1c                	jg     f0103d4e <vprintfmt+0x3a4>
f0103d32:	e9 96 fc ff ff       	jmp    f01039cd <vprintfmt+0x23>
f0103d37:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0103d3a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103d3d:	85 ff                	test   %edi,%edi
f0103d3f:	78 a7                	js     f0103ce8 <vprintfmt+0x33e>
f0103d41:	83 ef 01             	sub    $0x1,%edi
f0103d44:	79 a2                	jns    f0103ce8 <vprintfmt+0x33e>
f0103d46:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0103d49:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103d4c:	eb db                	jmp    f0103d29 <vprintfmt+0x37f>
f0103d4e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103d51:	89 de                	mov    %ebx,%esi
f0103d53:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103d56:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d5a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103d61:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103d63:	83 eb 01             	sub    $0x1,%ebx
f0103d66:	75 ee                	jne    f0103d56 <vprintfmt+0x3ac>
f0103d68:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d6a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103d6d:	e9 5b fc ff ff       	jmp    f01039cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103d72:	83 f9 01             	cmp    $0x1,%ecx
f0103d75:	7e 10                	jle    f0103d87 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f0103d77:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d7a:	8d 50 08             	lea    0x8(%eax),%edx
f0103d7d:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d80:	8b 30                	mov    (%eax),%esi
f0103d82:	8b 78 04             	mov    0x4(%eax),%edi
f0103d85:	eb 26                	jmp    f0103dad <vprintfmt+0x403>
	else if (lflag)
f0103d87:	85 c9                	test   %ecx,%ecx
f0103d89:	74 12                	je     f0103d9d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f0103d8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d8e:	8d 50 04             	lea    0x4(%eax),%edx
f0103d91:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d94:	8b 30                	mov    (%eax),%esi
f0103d96:	89 f7                	mov    %esi,%edi
f0103d98:	c1 ff 1f             	sar    $0x1f,%edi
f0103d9b:	eb 10                	jmp    f0103dad <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0103d9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103da0:	8d 50 04             	lea    0x4(%eax),%edx
f0103da3:	89 55 14             	mov    %edx,0x14(%ebp)
f0103da6:	8b 30                	mov    (%eax),%esi
f0103da8:	89 f7                	mov    %esi,%edi
f0103daa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103dad:	85 ff                	test   %edi,%edi
f0103daf:	78 0e                	js     f0103dbf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103db1:	89 f0                	mov    %esi,%eax
f0103db3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103db5:	be 0a 00 00 00       	mov    $0xa,%esi
f0103dba:	e9 84 00 00 00       	jmp    f0103e43 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103dbf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dc3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103dca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103dcd:	89 f0                	mov    %esi,%eax
f0103dcf:	89 fa                	mov    %edi,%edx
f0103dd1:	f7 d8                	neg    %eax
f0103dd3:	83 d2 00             	adc    $0x0,%edx
f0103dd6:	f7 da                	neg    %edx
			}
			base = 10;
f0103dd8:	be 0a 00 00 00       	mov    $0xa,%esi
f0103ddd:	eb 64                	jmp    f0103e43 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103ddf:	89 ca                	mov    %ecx,%edx
f0103de1:	8d 45 14             	lea    0x14(%ebp),%eax
f0103de4:	e8 42 fb ff ff       	call   f010392b <getuint>
			base = 10;
f0103de9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0103dee:	eb 53                	jmp    f0103e43 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0103df0:	89 ca                	mov    %ecx,%edx
f0103df2:	8d 45 14             	lea    0x14(%ebp),%eax
f0103df5:	e8 31 fb ff ff       	call   f010392b <getuint>
    			base = 8;
f0103dfa:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0103dff:	eb 42                	jmp    f0103e43 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0103e01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e05:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103e0c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103e0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e13:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103e1a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103e1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e20:	8d 50 04             	lea    0x4(%eax),%edx
f0103e23:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103e26:	8b 00                	mov    (%eax),%eax
f0103e28:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103e2d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0103e32:	eb 0f                	jmp    f0103e43 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103e34:	89 ca                	mov    %ecx,%edx
f0103e36:	8d 45 14             	lea    0x14(%ebp),%eax
f0103e39:	e8 ed fa ff ff       	call   f010392b <getuint>
			base = 16;
f0103e3e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103e43:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0103e47:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103e4b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103e4e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103e52:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103e56:	89 04 24             	mov    %eax,(%esp)
f0103e59:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e5d:	89 da                	mov    %ebx,%edx
f0103e5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e62:	e8 e9 f9 ff ff       	call   f0103850 <printnum>
			break;
f0103e67:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103e6a:	e9 5e fb ff ff       	jmp    f01039cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103e6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e73:	89 14 24             	mov    %edx,(%esp)
f0103e76:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e79:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103e7c:	e9 4c fb ff ff       	jmp    f01039cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103e81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e85:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103e8c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103e8f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103e93:	0f 84 34 fb ff ff    	je     f01039cd <vprintfmt+0x23>
f0103e99:	83 ee 01             	sub    $0x1,%esi
f0103e9c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103ea0:	75 f7                	jne    f0103e99 <vprintfmt+0x4ef>
f0103ea2:	e9 26 fb ff ff       	jmp    f01039cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103ea7:	83 c4 5c             	add    $0x5c,%esp
f0103eaa:	5b                   	pop    %ebx
f0103eab:	5e                   	pop    %esi
f0103eac:	5f                   	pop    %edi
f0103ead:	5d                   	pop    %ebp
f0103eae:	c3                   	ret    

f0103eaf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103eaf:	55                   	push   %ebp
f0103eb0:	89 e5                	mov    %esp,%ebp
f0103eb2:	83 ec 28             	sub    $0x28,%esp
f0103eb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eb8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103ebb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ebe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103ec2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103ec5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103ecc:	85 c0                	test   %eax,%eax
f0103ece:	74 30                	je     f0103f00 <vsnprintf+0x51>
f0103ed0:	85 d2                	test   %edx,%edx
f0103ed2:	7e 2c                	jle    f0103f00 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103ed4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ed7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103edb:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ede:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ee2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee9:	c7 04 24 65 39 10 f0 	movl   $0xf0103965,(%esp)
f0103ef0:	e8 b5 fa ff ff       	call   f01039aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103ef5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ef8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103efe:	eb 05                	jmp    f0103f05 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103f00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103f05:	c9                   	leave  
f0103f06:	c3                   	ret    

f0103f07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103f07:	55                   	push   %ebp
f0103f08:	89 e5                	mov    %esp,%ebp
f0103f0a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103f0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103f10:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f14:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f17:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f22:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f25:	89 04 24             	mov    %eax,(%esp)
f0103f28:	e8 82 ff ff ff       	call   f0103eaf <vsnprintf>
	va_end(ap);

	return rc;
}
f0103f2d:	c9                   	leave  
f0103f2e:	c3                   	ret    
	...

f0103f30 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103f30:	55                   	push   %ebp
f0103f31:	89 e5                	mov    %esp,%ebp
f0103f33:	57                   	push   %edi
f0103f34:	56                   	push   %esi
f0103f35:	53                   	push   %ebx
f0103f36:	83 ec 1c             	sub    $0x1c,%esp
f0103f39:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103f3c:	85 c0                	test   %eax,%eax
f0103f3e:	74 10                	je     f0103f50 <readline+0x20>
		cprintf("%s", prompt);
f0103f40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f44:	c7 04 24 1c 56 10 f0 	movl   $0xf010561c,(%esp)
f0103f4b:	e8 aa f5 ff ff       	call   f01034fa <cprintf>

	i = 0;
	echoing = iscons(0);
f0103f50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f57:	e8 b5 c6 ff ff       	call   f0100611 <iscons>
f0103f5c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103f5e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103f63:	e8 98 c6 ff ff       	call   f0100600 <getchar>
f0103f68:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103f6a:	85 c0                	test   %eax,%eax
f0103f6c:	79 17                	jns    f0103f85 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f72:	c7 04 24 ec 5a 10 f0 	movl   $0xf0105aec,(%esp)
f0103f79:	e8 7c f5 ff ff       	call   f01034fa <cprintf>
			return NULL;
f0103f7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f83:	eb 6d                	jmp    f0103ff2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103f85:	83 f8 08             	cmp    $0x8,%eax
f0103f88:	74 05                	je     f0103f8f <readline+0x5f>
f0103f8a:	83 f8 7f             	cmp    $0x7f,%eax
f0103f8d:	75 19                	jne    f0103fa8 <readline+0x78>
f0103f8f:	85 f6                	test   %esi,%esi
f0103f91:	7e 15                	jle    f0103fa8 <readline+0x78>
			if (echoing)
f0103f93:	85 ff                	test   %edi,%edi
f0103f95:	74 0c                	je     f0103fa3 <readline+0x73>
				cputchar('\b');
f0103f97:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103f9e:	e8 4d c6 ff ff       	call   f01005f0 <cputchar>
			i--;
f0103fa3:	83 ee 01             	sub    $0x1,%esi
f0103fa6:	eb bb                	jmp    f0103f63 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103fa8:	83 fb 1f             	cmp    $0x1f,%ebx
f0103fab:	7e 1f                	jle    f0103fcc <readline+0x9c>
f0103fad:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103fb3:	7f 17                	jg     f0103fcc <readline+0x9c>
			if (echoing)
f0103fb5:	85 ff                	test   %edi,%edi
f0103fb7:	74 08                	je     f0103fc1 <readline+0x91>
				cputchar(c);
f0103fb9:	89 1c 24             	mov    %ebx,(%esp)
f0103fbc:	e8 2f c6 ff ff       	call   f01005f0 <cputchar>
			buf[i++] = c;
f0103fc1:	88 9e 80 95 11 f0    	mov    %bl,-0xfee6a80(%esi)
f0103fc7:	83 c6 01             	add    $0x1,%esi
f0103fca:	eb 97                	jmp    f0103f63 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103fcc:	83 fb 0a             	cmp    $0xa,%ebx
f0103fcf:	74 05                	je     f0103fd6 <readline+0xa6>
f0103fd1:	83 fb 0d             	cmp    $0xd,%ebx
f0103fd4:	75 8d                	jne    f0103f63 <readline+0x33>
			if (echoing)
f0103fd6:	85 ff                	test   %edi,%edi
f0103fd8:	74 0c                	je     f0103fe6 <readline+0xb6>
				cputchar('\n');
f0103fda:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103fe1:	e8 0a c6 ff ff       	call   f01005f0 <cputchar>
			buf[i] = 0;
f0103fe6:	c6 86 80 95 11 f0 00 	movb   $0x0,-0xfee6a80(%esi)
			return buf;
f0103fed:	b8 80 95 11 f0       	mov    $0xf0119580,%eax
		}
	}
}
f0103ff2:	83 c4 1c             	add    $0x1c,%esp
f0103ff5:	5b                   	pop    %ebx
f0103ff6:	5e                   	pop    %esi
f0103ff7:	5f                   	pop    %edi
f0103ff8:	5d                   	pop    %ebp
f0103ff9:	c3                   	ret    
f0103ffa:	00 00                	add    %al,(%eax)
f0103ffc:	00 00                	add    %al,(%eax)
	...

f0104000 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104000:	55                   	push   %ebp
f0104001:	89 e5                	mov    %esp,%ebp
f0104003:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104006:	b8 00 00 00 00       	mov    $0x0,%eax
f010400b:	80 3a 00             	cmpb   $0x0,(%edx)
f010400e:	74 09                	je     f0104019 <strlen+0x19>
		n++;
f0104010:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104013:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104017:	75 f7                	jne    f0104010 <strlen+0x10>
		n++;
	return n;
}
f0104019:	5d                   	pop    %ebp
f010401a:	c3                   	ret    

f010401b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010401b:	55                   	push   %ebp
f010401c:	89 e5                	mov    %esp,%ebp
f010401e:	53                   	push   %ebx
f010401f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104025:	b8 00 00 00 00       	mov    $0x0,%eax
f010402a:	85 c9                	test   %ecx,%ecx
f010402c:	74 1a                	je     f0104048 <strnlen+0x2d>
f010402e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104031:	74 15                	je     f0104048 <strnlen+0x2d>
f0104033:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0104038:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010403a:	39 ca                	cmp    %ecx,%edx
f010403c:	74 0a                	je     f0104048 <strnlen+0x2d>
f010403e:	83 c2 01             	add    $0x1,%edx
f0104041:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104046:	75 f0                	jne    f0104038 <strnlen+0x1d>
		n++;
	return n;
}
f0104048:	5b                   	pop    %ebx
f0104049:	5d                   	pop    %ebp
f010404a:	c3                   	ret    

f010404b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010404b:	55                   	push   %ebp
f010404c:	89 e5                	mov    %esp,%ebp
f010404e:	53                   	push   %ebx
f010404f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104052:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104055:	ba 00 00 00 00       	mov    $0x0,%edx
f010405a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010405e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104061:	83 c2 01             	add    $0x1,%edx
f0104064:	84 c9                	test   %cl,%cl
f0104066:	75 f2                	jne    f010405a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104068:	5b                   	pop    %ebx
f0104069:	5d                   	pop    %ebp
f010406a:	c3                   	ret    

f010406b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010406b:	55                   	push   %ebp
f010406c:	89 e5                	mov    %esp,%ebp
f010406e:	53                   	push   %ebx
f010406f:	83 ec 08             	sub    $0x8,%esp
f0104072:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104075:	89 1c 24             	mov    %ebx,(%esp)
f0104078:	e8 83 ff ff ff       	call   f0104000 <strlen>
	strcpy(dst + len, src);
f010407d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104080:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104084:	01 d8                	add    %ebx,%eax
f0104086:	89 04 24             	mov    %eax,(%esp)
f0104089:	e8 bd ff ff ff       	call   f010404b <strcpy>
	return dst;
}
f010408e:	89 d8                	mov    %ebx,%eax
f0104090:	83 c4 08             	add    $0x8,%esp
f0104093:	5b                   	pop    %ebx
f0104094:	5d                   	pop    %ebp
f0104095:	c3                   	ret    

f0104096 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104096:	55                   	push   %ebp
f0104097:	89 e5                	mov    %esp,%ebp
f0104099:	56                   	push   %esi
f010409a:	53                   	push   %ebx
f010409b:	8b 45 08             	mov    0x8(%ebp),%eax
f010409e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040a4:	85 f6                	test   %esi,%esi
f01040a6:	74 18                	je     f01040c0 <strncpy+0x2a>
f01040a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01040ad:	0f b6 1a             	movzbl (%edx),%ebx
f01040b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01040b3:	80 3a 01             	cmpb   $0x1,(%edx)
f01040b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040b9:	83 c1 01             	add    $0x1,%ecx
f01040bc:	39 f1                	cmp    %esi,%ecx
f01040be:	75 ed                	jne    f01040ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01040c0:	5b                   	pop    %ebx
f01040c1:	5e                   	pop    %esi
f01040c2:	5d                   	pop    %ebp
f01040c3:	c3                   	ret    

f01040c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01040c4:	55                   	push   %ebp
f01040c5:	89 e5                	mov    %esp,%ebp
f01040c7:	57                   	push   %edi
f01040c8:	56                   	push   %esi
f01040c9:	53                   	push   %ebx
f01040ca:	8b 7d 08             	mov    0x8(%ebp),%edi
f01040cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01040d0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01040d3:	89 f8                	mov    %edi,%eax
f01040d5:	85 f6                	test   %esi,%esi
f01040d7:	74 2b                	je     f0104104 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01040d9:	83 fe 01             	cmp    $0x1,%esi
f01040dc:	74 23                	je     f0104101 <strlcpy+0x3d>
f01040de:	0f b6 0b             	movzbl (%ebx),%ecx
f01040e1:	84 c9                	test   %cl,%cl
f01040e3:	74 1c                	je     f0104101 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01040e5:	83 ee 02             	sub    $0x2,%esi
f01040e8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01040ed:	88 08                	mov    %cl,(%eax)
f01040ef:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01040f2:	39 f2                	cmp    %esi,%edx
f01040f4:	74 0b                	je     f0104101 <strlcpy+0x3d>
f01040f6:	83 c2 01             	add    $0x1,%edx
f01040f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01040fd:	84 c9                	test   %cl,%cl
f01040ff:	75 ec                	jne    f01040ed <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0104101:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104104:	29 f8                	sub    %edi,%eax
}
f0104106:	5b                   	pop    %ebx
f0104107:	5e                   	pop    %esi
f0104108:	5f                   	pop    %edi
f0104109:	5d                   	pop    %ebp
f010410a:	c3                   	ret    

f010410b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010410b:	55                   	push   %ebp
f010410c:	89 e5                	mov    %esp,%ebp
f010410e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104111:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104114:	0f b6 01             	movzbl (%ecx),%eax
f0104117:	84 c0                	test   %al,%al
f0104119:	74 16                	je     f0104131 <strcmp+0x26>
f010411b:	3a 02                	cmp    (%edx),%al
f010411d:	75 12                	jne    f0104131 <strcmp+0x26>
		p++, q++;
f010411f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104122:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0104126:	84 c0                	test   %al,%al
f0104128:	74 07                	je     f0104131 <strcmp+0x26>
f010412a:	83 c1 01             	add    $0x1,%ecx
f010412d:	3a 02                	cmp    (%edx),%al
f010412f:	74 ee                	je     f010411f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104131:	0f b6 c0             	movzbl %al,%eax
f0104134:	0f b6 12             	movzbl (%edx),%edx
f0104137:	29 d0                	sub    %edx,%eax
}
f0104139:	5d                   	pop    %ebp
f010413a:	c3                   	ret    

f010413b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010413b:	55                   	push   %ebp
f010413c:	89 e5                	mov    %esp,%ebp
f010413e:	53                   	push   %ebx
f010413f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104145:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104148:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010414d:	85 d2                	test   %edx,%edx
f010414f:	74 28                	je     f0104179 <strncmp+0x3e>
f0104151:	0f b6 01             	movzbl (%ecx),%eax
f0104154:	84 c0                	test   %al,%al
f0104156:	74 24                	je     f010417c <strncmp+0x41>
f0104158:	3a 03                	cmp    (%ebx),%al
f010415a:	75 20                	jne    f010417c <strncmp+0x41>
f010415c:	83 ea 01             	sub    $0x1,%edx
f010415f:	74 13                	je     f0104174 <strncmp+0x39>
		n--, p++, q++;
f0104161:	83 c1 01             	add    $0x1,%ecx
f0104164:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104167:	0f b6 01             	movzbl (%ecx),%eax
f010416a:	84 c0                	test   %al,%al
f010416c:	74 0e                	je     f010417c <strncmp+0x41>
f010416e:	3a 03                	cmp    (%ebx),%al
f0104170:	74 ea                	je     f010415c <strncmp+0x21>
f0104172:	eb 08                	jmp    f010417c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104174:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104179:	5b                   	pop    %ebx
f010417a:	5d                   	pop    %ebp
f010417b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010417c:	0f b6 01             	movzbl (%ecx),%eax
f010417f:	0f b6 13             	movzbl (%ebx),%edx
f0104182:	29 d0                	sub    %edx,%eax
f0104184:	eb f3                	jmp    f0104179 <strncmp+0x3e>

f0104186 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104186:	55                   	push   %ebp
f0104187:	89 e5                	mov    %esp,%ebp
f0104189:	8b 45 08             	mov    0x8(%ebp),%eax
f010418c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104190:	0f b6 10             	movzbl (%eax),%edx
f0104193:	84 d2                	test   %dl,%dl
f0104195:	74 1c                	je     f01041b3 <strchr+0x2d>
		if (*s == c)
f0104197:	38 ca                	cmp    %cl,%dl
f0104199:	75 09                	jne    f01041a4 <strchr+0x1e>
f010419b:	eb 1b                	jmp    f01041b8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010419d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f01041a0:	38 ca                	cmp    %cl,%dl
f01041a2:	74 14                	je     f01041b8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01041a4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f01041a8:	84 d2                	test   %dl,%dl
f01041aa:	75 f1                	jne    f010419d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f01041ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01041b1:	eb 05                	jmp    f01041b8 <strchr+0x32>
f01041b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01041b8:	5d                   	pop    %ebp
f01041b9:	c3                   	ret    

f01041ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01041ba:	55                   	push   %ebp
f01041bb:	89 e5                	mov    %esp,%ebp
f01041bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01041c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01041c4:	0f b6 10             	movzbl (%eax),%edx
f01041c7:	84 d2                	test   %dl,%dl
f01041c9:	74 14                	je     f01041df <strfind+0x25>
		if (*s == c)
f01041cb:	38 ca                	cmp    %cl,%dl
f01041cd:	75 06                	jne    f01041d5 <strfind+0x1b>
f01041cf:	eb 0e                	jmp    f01041df <strfind+0x25>
f01041d1:	38 ca                	cmp    %cl,%dl
f01041d3:	74 0a                	je     f01041df <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01041d5:	83 c0 01             	add    $0x1,%eax
f01041d8:	0f b6 10             	movzbl (%eax),%edx
f01041db:	84 d2                	test   %dl,%dl
f01041dd:	75 f2                	jne    f01041d1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01041df:	5d                   	pop    %ebp
f01041e0:	c3                   	ret    

f01041e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01041e1:	55                   	push   %ebp
f01041e2:	89 e5                	mov    %esp,%ebp
f01041e4:	83 ec 0c             	sub    $0xc,%esp
f01041e7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01041ea:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01041ed:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01041f0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01041f9:	85 c9                	test   %ecx,%ecx
f01041fb:	74 30                	je     f010422d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01041fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104203:	75 25                	jne    f010422a <memset+0x49>
f0104205:	f6 c1 03             	test   $0x3,%cl
f0104208:	75 20                	jne    f010422a <memset+0x49>
		c &= 0xFF;
f010420a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010420d:	89 d3                	mov    %edx,%ebx
f010420f:	c1 e3 08             	shl    $0x8,%ebx
f0104212:	89 d6                	mov    %edx,%esi
f0104214:	c1 e6 18             	shl    $0x18,%esi
f0104217:	89 d0                	mov    %edx,%eax
f0104219:	c1 e0 10             	shl    $0x10,%eax
f010421c:	09 f0                	or     %esi,%eax
f010421e:	09 d0                	or     %edx,%eax
f0104220:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104222:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104225:	fc                   	cld    
f0104226:	f3 ab                	rep stos %eax,%es:(%edi)
f0104228:	eb 03                	jmp    f010422d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010422a:	fc                   	cld    
f010422b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010422d:	89 f8                	mov    %edi,%eax
f010422f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104232:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104235:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104238:	89 ec                	mov    %ebp,%esp
f010423a:	5d                   	pop    %ebp
f010423b:	c3                   	ret    

f010423c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010423c:	55                   	push   %ebp
f010423d:	89 e5                	mov    %esp,%ebp
f010423f:	83 ec 08             	sub    $0x8,%esp
f0104242:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104245:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104248:	8b 45 08             	mov    0x8(%ebp),%eax
f010424b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010424e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104251:	39 c6                	cmp    %eax,%esi
f0104253:	73 36                	jae    f010428b <memmove+0x4f>
f0104255:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104258:	39 d0                	cmp    %edx,%eax
f010425a:	73 2f                	jae    f010428b <memmove+0x4f>
		s += n;
		d += n;
f010425c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010425f:	f6 c2 03             	test   $0x3,%dl
f0104262:	75 1b                	jne    f010427f <memmove+0x43>
f0104264:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010426a:	75 13                	jne    f010427f <memmove+0x43>
f010426c:	f6 c1 03             	test   $0x3,%cl
f010426f:	75 0e                	jne    f010427f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104271:	83 ef 04             	sub    $0x4,%edi
f0104274:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104277:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010427a:	fd                   	std    
f010427b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010427d:	eb 09                	jmp    f0104288 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010427f:	83 ef 01             	sub    $0x1,%edi
f0104282:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104285:	fd                   	std    
f0104286:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104288:	fc                   	cld    
f0104289:	eb 20                	jmp    f01042ab <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010428b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104291:	75 13                	jne    f01042a6 <memmove+0x6a>
f0104293:	a8 03                	test   $0x3,%al
f0104295:	75 0f                	jne    f01042a6 <memmove+0x6a>
f0104297:	f6 c1 03             	test   $0x3,%cl
f010429a:	75 0a                	jne    f01042a6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010429c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010429f:	89 c7                	mov    %eax,%edi
f01042a1:	fc                   	cld    
f01042a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01042a4:	eb 05                	jmp    f01042ab <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01042a6:	89 c7                	mov    %eax,%edi
f01042a8:	fc                   	cld    
f01042a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01042ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01042ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01042b1:	89 ec                	mov    %ebp,%esp
f01042b3:	5d                   	pop    %ebp
f01042b4:	c3                   	ret    

f01042b5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01042b5:	55                   	push   %ebp
f01042b6:	89 e5                	mov    %esp,%ebp
f01042b8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01042bb:	8b 45 10             	mov    0x10(%ebp),%eax
f01042be:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01042cc:	89 04 24             	mov    %eax,(%esp)
f01042cf:	e8 68 ff ff ff       	call   f010423c <memmove>
}
f01042d4:	c9                   	leave  
f01042d5:	c3                   	ret    

f01042d6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01042d6:	55                   	push   %ebp
f01042d7:	89 e5                	mov    %esp,%ebp
f01042d9:	57                   	push   %edi
f01042da:	56                   	push   %esi
f01042db:	53                   	push   %ebx
f01042dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01042df:	8b 75 0c             	mov    0xc(%ebp),%esi
f01042e2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01042e5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01042ea:	85 ff                	test   %edi,%edi
f01042ec:	74 37                	je     f0104325 <memcmp+0x4f>
		if (*s1 != *s2)
f01042ee:	0f b6 03             	movzbl (%ebx),%eax
f01042f1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01042f4:	83 ef 01             	sub    $0x1,%edi
f01042f7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f01042fc:	38 c8                	cmp    %cl,%al
f01042fe:	74 1c                	je     f010431c <memcmp+0x46>
f0104300:	eb 10                	jmp    f0104312 <memcmp+0x3c>
f0104302:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104307:	83 c2 01             	add    $0x1,%edx
f010430a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010430e:	38 c8                	cmp    %cl,%al
f0104310:	74 0a                	je     f010431c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0104312:	0f b6 c0             	movzbl %al,%eax
f0104315:	0f b6 c9             	movzbl %cl,%ecx
f0104318:	29 c8                	sub    %ecx,%eax
f010431a:	eb 09                	jmp    f0104325 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010431c:	39 fa                	cmp    %edi,%edx
f010431e:	75 e2                	jne    f0104302 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104320:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104325:	5b                   	pop    %ebx
f0104326:	5e                   	pop    %esi
f0104327:	5f                   	pop    %edi
f0104328:	5d                   	pop    %ebp
f0104329:	c3                   	ret    

f010432a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010432a:	55                   	push   %ebp
f010432b:	89 e5                	mov    %esp,%ebp
f010432d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104330:	89 c2                	mov    %eax,%edx
f0104332:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104335:	39 d0                	cmp    %edx,%eax
f0104337:	73 19                	jae    f0104352 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104339:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010433d:	38 08                	cmp    %cl,(%eax)
f010433f:	75 06                	jne    f0104347 <memfind+0x1d>
f0104341:	eb 0f                	jmp    f0104352 <memfind+0x28>
f0104343:	38 08                	cmp    %cl,(%eax)
f0104345:	74 0b                	je     f0104352 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104347:	83 c0 01             	add    $0x1,%eax
f010434a:	39 d0                	cmp    %edx,%eax
f010434c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104350:	75 f1                	jne    f0104343 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104352:	5d                   	pop    %ebp
f0104353:	c3                   	ret    

f0104354 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104354:	55                   	push   %ebp
f0104355:	89 e5                	mov    %esp,%ebp
f0104357:	57                   	push   %edi
f0104358:	56                   	push   %esi
f0104359:	53                   	push   %ebx
f010435a:	8b 55 08             	mov    0x8(%ebp),%edx
f010435d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104360:	0f b6 02             	movzbl (%edx),%eax
f0104363:	3c 20                	cmp    $0x20,%al
f0104365:	74 04                	je     f010436b <strtol+0x17>
f0104367:	3c 09                	cmp    $0x9,%al
f0104369:	75 0e                	jne    f0104379 <strtol+0x25>
		s++;
f010436b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010436e:	0f b6 02             	movzbl (%edx),%eax
f0104371:	3c 20                	cmp    $0x20,%al
f0104373:	74 f6                	je     f010436b <strtol+0x17>
f0104375:	3c 09                	cmp    $0x9,%al
f0104377:	74 f2                	je     f010436b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104379:	3c 2b                	cmp    $0x2b,%al
f010437b:	75 0a                	jne    f0104387 <strtol+0x33>
		s++;
f010437d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104380:	bf 00 00 00 00       	mov    $0x0,%edi
f0104385:	eb 10                	jmp    f0104397 <strtol+0x43>
f0104387:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010438c:	3c 2d                	cmp    $0x2d,%al
f010438e:	75 07                	jne    f0104397 <strtol+0x43>
		s++, neg = 1;
f0104390:	83 c2 01             	add    $0x1,%edx
f0104393:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104397:	85 db                	test   %ebx,%ebx
f0104399:	0f 94 c0             	sete   %al
f010439c:	74 05                	je     f01043a3 <strtol+0x4f>
f010439e:	83 fb 10             	cmp    $0x10,%ebx
f01043a1:	75 15                	jne    f01043b8 <strtol+0x64>
f01043a3:	80 3a 30             	cmpb   $0x30,(%edx)
f01043a6:	75 10                	jne    f01043b8 <strtol+0x64>
f01043a8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01043ac:	75 0a                	jne    f01043b8 <strtol+0x64>
		s += 2, base = 16;
f01043ae:	83 c2 02             	add    $0x2,%edx
f01043b1:	bb 10 00 00 00       	mov    $0x10,%ebx
f01043b6:	eb 13                	jmp    f01043cb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f01043b8:	84 c0                	test   %al,%al
f01043ba:	74 0f                	je     f01043cb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01043bc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01043c1:	80 3a 30             	cmpb   $0x30,(%edx)
f01043c4:	75 05                	jne    f01043cb <strtol+0x77>
		s++, base = 8;
f01043c6:	83 c2 01             	add    $0x1,%edx
f01043c9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01043cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01043d0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01043d2:	0f b6 0a             	movzbl (%edx),%ecx
f01043d5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01043d8:	80 fb 09             	cmp    $0x9,%bl
f01043db:	77 08                	ja     f01043e5 <strtol+0x91>
			dig = *s - '0';
f01043dd:	0f be c9             	movsbl %cl,%ecx
f01043e0:	83 e9 30             	sub    $0x30,%ecx
f01043e3:	eb 1e                	jmp    f0104403 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01043e5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01043e8:	80 fb 19             	cmp    $0x19,%bl
f01043eb:	77 08                	ja     f01043f5 <strtol+0xa1>
			dig = *s - 'a' + 10;
f01043ed:	0f be c9             	movsbl %cl,%ecx
f01043f0:	83 e9 57             	sub    $0x57,%ecx
f01043f3:	eb 0e                	jmp    f0104403 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f01043f5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01043f8:	80 fb 19             	cmp    $0x19,%bl
f01043fb:	77 14                	ja     f0104411 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01043fd:	0f be c9             	movsbl %cl,%ecx
f0104400:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104403:	39 f1                	cmp    %esi,%ecx
f0104405:	7d 0e                	jge    f0104415 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104407:	83 c2 01             	add    $0x1,%edx
f010440a:	0f af c6             	imul   %esi,%eax
f010440d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010440f:	eb c1                	jmp    f01043d2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104411:	89 c1                	mov    %eax,%ecx
f0104413:	eb 02                	jmp    f0104417 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104415:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104417:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010441b:	74 05                	je     f0104422 <strtol+0xce>
		*endptr = (char *) s;
f010441d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104420:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104422:	89 ca                	mov    %ecx,%edx
f0104424:	f7 da                	neg    %edx
f0104426:	85 ff                	test   %edi,%edi
f0104428:	0f 45 c2             	cmovne %edx,%eax
}
f010442b:	5b                   	pop    %ebx
f010442c:	5e                   	pop    %esi
f010442d:	5f                   	pop    %edi
f010442e:	5d                   	pop    %ebp
f010442f:	c3                   	ret    

f0104430 <__udivdi3>:
f0104430:	83 ec 1c             	sub    $0x1c,%esp
f0104433:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104437:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010443b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010443f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104443:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104447:	8b 74 24 24          	mov    0x24(%esp),%esi
f010444b:	85 ff                	test   %edi,%edi
f010444d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104451:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104455:	89 cd                	mov    %ecx,%ebp
f0104457:	89 44 24 04          	mov    %eax,0x4(%esp)
f010445b:	75 33                	jne    f0104490 <__udivdi3+0x60>
f010445d:	39 f1                	cmp    %esi,%ecx
f010445f:	77 57                	ja     f01044b8 <__udivdi3+0x88>
f0104461:	85 c9                	test   %ecx,%ecx
f0104463:	75 0b                	jne    f0104470 <__udivdi3+0x40>
f0104465:	b8 01 00 00 00       	mov    $0x1,%eax
f010446a:	31 d2                	xor    %edx,%edx
f010446c:	f7 f1                	div    %ecx
f010446e:	89 c1                	mov    %eax,%ecx
f0104470:	89 f0                	mov    %esi,%eax
f0104472:	31 d2                	xor    %edx,%edx
f0104474:	f7 f1                	div    %ecx
f0104476:	89 c6                	mov    %eax,%esi
f0104478:	8b 44 24 04          	mov    0x4(%esp),%eax
f010447c:	f7 f1                	div    %ecx
f010447e:	89 f2                	mov    %esi,%edx
f0104480:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104484:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104488:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010448c:	83 c4 1c             	add    $0x1c,%esp
f010448f:	c3                   	ret    
f0104490:	31 d2                	xor    %edx,%edx
f0104492:	31 c0                	xor    %eax,%eax
f0104494:	39 f7                	cmp    %esi,%edi
f0104496:	77 e8                	ja     f0104480 <__udivdi3+0x50>
f0104498:	0f bd cf             	bsr    %edi,%ecx
f010449b:	83 f1 1f             	xor    $0x1f,%ecx
f010449e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01044a2:	75 2c                	jne    f01044d0 <__udivdi3+0xa0>
f01044a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01044a8:	76 04                	jbe    f01044ae <__udivdi3+0x7e>
f01044aa:	39 f7                	cmp    %esi,%edi
f01044ac:	73 d2                	jae    f0104480 <__udivdi3+0x50>
f01044ae:	31 d2                	xor    %edx,%edx
f01044b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01044b5:	eb c9                	jmp    f0104480 <__udivdi3+0x50>
f01044b7:	90                   	nop
f01044b8:	89 f2                	mov    %esi,%edx
f01044ba:	f7 f1                	div    %ecx
f01044bc:	31 d2                	xor    %edx,%edx
f01044be:	8b 74 24 10          	mov    0x10(%esp),%esi
f01044c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01044c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01044ca:	83 c4 1c             	add    $0x1c,%esp
f01044cd:	c3                   	ret    
f01044ce:	66 90                	xchg   %ax,%ax
f01044d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01044d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01044da:	89 ea                	mov    %ebp,%edx
f01044dc:	2b 44 24 04          	sub    0x4(%esp),%eax
f01044e0:	d3 e7                	shl    %cl,%edi
f01044e2:	89 c1                	mov    %eax,%ecx
f01044e4:	d3 ea                	shr    %cl,%edx
f01044e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01044eb:	09 fa                	or     %edi,%edx
f01044ed:	89 f7                	mov    %esi,%edi
f01044ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01044f3:	89 f2                	mov    %esi,%edx
f01044f5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01044f9:	d3 e5                	shl    %cl,%ebp
f01044fb:	89 c1                	mov    %eax,%ecx
f01044fd:	d3 ef                	shr    %cl,%edi
f01044ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104504:	d3 e2                	shl    %cl,%edx
f0104506:	89 c1                	mov    %eax,%ecx
f0104508:	d3 ee                	shr    %cl,%esi
f010450a:	09 d6                	or     %edx,%esi
f010450c:	89 fa                	mov    %edi,%edx
f010450e:	89 f0                	mov    %esi,%eax
f0104510:	f7 74 24 0c          	divl   0xc(%esp)
f0104514:	89 d7                	mov    %edx,%edi
f0104516:	89 c6                	mov    %eax,%esi
f0104518:	f7 e5                	mul    %ebp
f010451a:	39 d7                	cmp    %edx,%edi
f010451c:	72 22                	jb     f0104540 <__udivdi3+0x110>
f010451e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0104522:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104527:	d3 e5                	shl    %cl,%ebp
f0104529:	39 c5                	cmp    %eax,%ebp
f010452b:	73 04                	jae    f0104531 <__udivdi3+0x101>
f010452d:	39 d7                	cmp    %edx,%edi
f010452f:	74 0f                	je     f0104540 <__udivdi3+0x110>
f0104531:	89 f0                	mov    %esi,%eax
f0104533:	31 d2                	xor    %edx,%edx
f0104535:	e9 46 ff ff ff       	jmp    f0104480 <__udivdi3+0x50>
f010453a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104540:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104543:	31 d2                	xor    %edx,%edx
f0104545:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104549:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010454d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104551:	83 c4 1c             	add    $0x1c,%esp
f0104554:	c3                   	ret    
	...

f0104560 <__umoddi3>:
f0104560:	83 ec 1c             	sub    $0x1c,%esp
f0104563:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104567:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010456b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010456f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104573:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104577:	8b 74 24 24          	mov    0x24(%esp),%esi
f010457b:	85 ed                	test   %ebp,%ebp
f010457d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104581:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104585:	89 cf                	mov    %ecx,%edi
f0104587:	89 04 24             	mov    %eax,(%esp)
f010458a:	89 f2                	mov    %esi,%edx
f010458c:	75 1a                	jne    f01045a8 <__umoddi3+0x48>
f010458e:	39 f1                	cmp    %esi,%ecx
f0104590:	76 4e                	jbe    f01045e0 <__umoddi3+0x80>
f0104592:	f7 f1                	div    %ecx
f0104594:	89 d0                	mov    %edx,%eax
f0104596:	31 d2                	xor    %edx,%edx
f0104598:	8b 74 24 10          	mov    0x10(%esp),%esi
f010459c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01045a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01045a4:	83 c4 1c             	add    $0x1c,%esp
f01045a7:	c3                   	ret    
f01045a8:	39 f5                	cmp    %esi,%ebp
f01045aa:	77 54                	ja     f0104600 <__umoddi3+0xa0>
f01045ac:	0f bd c5             	bsr    %ebp,%eax
f01045af:	83 f0 1f             	xor    $0x1f,%eax
f01045b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b6:	75 60                	jne    f0104618 <__umoddi3+0xb8>
f01045b8:	3b 0c 24             	cmp    (%esp),%ecx
f01045bb:	0f 87 07 01 00 00    	ja     f01046c8 <__umoddi3+0x168>
f01045c1:	89 f2                	mov    %esi,%edx
f01045c3:	8b 34 24             	mov    (%esp),%esi
f01045c6:	29 ce                	sub    %ecx,%esi
f01045c8:	19 ea                	sbb    %ebp,%edx
f01045ca:	89 34 24             	mov    %esi,(%esp)
f01045cd:	8b 04 24             	mov    (%esp),%eax
f01045d0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01045d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01045d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01045dc:	83 c4 1c             	add    $0x1c,%esp
f01045df:	c3                   	ret    
f01045e0:	85 c9                	test   %ecx,%ecx
f01045e2:	75 0b                	jne    f01045ef <__umoddi3+0x8f>
f01045e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01045e9:	31 d2                	xor    %edx,%edx
f01045eb:	f7 f1                	div    %ecx
f01045ed:	89 c1                	mov    %eax,%ecx
f01045ef:	89 f0                	mov    %esi,%eax
f01045f1:	31 d2                	xor    %edx,%edx
f01045f3:	f7 f1                	div    %ecx
f01045f5:	8b 04 24             	mov    (%esp),%eax
f01045f8:	f7 f1                	div    %ecx
f01045fa:	eb 98                	jmp    f0104594 <__umoddi3+0x34>
f01045fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104600:	89 f2                	mov    %esi,%edx
f0104602:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104606:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010460a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010460e:	83 c4 1c             	add    $0x1c,%esp
f0104611:	c3                   	ret    
f0104612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104618:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010461d:	89 e8                	mov    %ebp,%eax
f010461f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0104624:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0104628:	89 fa                	mov    %edi,%edx
f010462a:	d3 e0                	shl    %cl,%eax
f010462c:	89 e9                	mov    %ebp,%ecx
f010462e:	d3 ea                	shr    %cl,%edx
f0104630:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104635:	09 c2                	or     %eax,%edx
f0104637:	8b 44 24 08          	mov    0x8(%esp),%eax
f010463b:	89 14 24             	mov    %edx,(%esp)
f010463e:	89 f2                	mov    %esi,%edx
f0104640:	d3 e7                	shl    %cl,%edi
f0104642:	89 e9                	mov    %ebp,%ecx
f0104644:	d3 ea                	shr    %cl,%edx
f0104646:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010464b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010464f:	d3 e6                	shl    %cl,%esi
f0104651:	89 e9                	mov    %ebp,%ecx
f0104653:	d3 e8                	shr    %cl,%eax
f0104655:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010465a:	09 f0                	or     %esi,%eax
f010465c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104660:	f7 34 24             	divl   (%esp)
f0104663:	d3 e6                	shl    %cl,%esi
f0104665:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104669:	89 d6                	mov    %edx,%esi
f010466b:	f7 e7                	mul    %edi
f010466d:	39 d6                	cmp    %edx,%esi
f010466f:	89 c1                	mov    %eax,%ecx
f0104671:	89 d7                	mov    %edx,%edi
f0104673:	72 3f                	jb     f01046b4 <__umoddi3+0x154>
f0104675:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0104679:	72 35                	jb     f01046b0 <__umoddi3+0x150>
f010467b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010467f:	29 c8                	sub    %ecx,%eax
f0104681:	19 fe                	sbb    %edi,%esi
f0104683:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104688:	89 f2                	mov    %esi,%edx
f010468a:	d3 e8                	shr    %cl,%eax
f010468c:	89 e9                	mov    %ebp,%ecx
f010468e:	d3 e2                	shl    %cl,%edx
f0104690:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104695:	09 d0                	or     %edx,%eax
f0104697:	89 f2                	mov    %esi,%edx
f0104699:	d3 ea                	shr    %cl,%edx
f010469b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010469f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01046a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01046a7:	83 c4 1c             	add    $0x1c,%esp
f01046aa:	c3                   	ret    
f01046ab:	90                   	nop
f01046ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046b0:	39 d6                	cmp    %edx,%esi
f01046b2:	75 c7                	jne    f010467b <__umoddi3+0x11b>
f01046b4:	89 d7                	mov    %edx,%edi
f01046b6:	89 c1                	mov    %eax,%ecx
f01046b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01046bc:	1b 3c 24             	sbb    (%esp),%edi
f01046bf:	eb ba                	jmp    f010467b <__umoddi3+0x11b>
f01046c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01046c8:	39 f5                	cmp    %esi,%ebp
f01046ca:	0f 82 f1 fe ff ff    	jb     f01045c1 <__umoddi3+0x61>
f01046d0:	e9 f8 fe ff ff       	jmp    f01045cd <__umoddi3+0x6d>
