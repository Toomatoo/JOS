
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 70 0e 18 f0       	mov    $0xf0180e70,%eax
f010004b:	2d 76 ff 17 f0       	sub    $0xf017ff76,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 76 ff 17 f0 	movl   $0xf017ff76,(%esp)
f0100063:	e8 09 53 00 00       	call   f0105371 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 be 04 00 00       	call   f010052b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 58 10 f0 	movl   $0xf0105880,(%esp)
f010007c:	e8 e9 3d 00 00       	call   f0103e6a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 8e 18 00 00       	call   f0101914 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 94 37 00 00       	call   f010381f <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 58 3e 00 00       	call   f0103eed <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100095:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010009c:	00 
f010009d:	c7 44 24 04 39 78 00 	movl   $0x7839,0x4(%esp)
f01000a4:	00 
f01000a5:	c7 04 24 04 3d 13 f0 	movl   $0xf0133d04,(%esp)
f01000ac:	e8 3a 39 00 00       	call   f01039eb <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000b1:	a1 cc 01 18 f0       	mov    0xf01801cc,%eax
f01000b6:	89 04 24             	mov    %eax,(%esp)
f01000b9:	e8 d2 3c 00 00       	call   f0103d90 <env_run>

f01000be <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000be:	55                   	push   %ebp
f01000bf:	89 e5                	mov    %esp,%ebp
f01000c1:	56                   	push   %esi
f01000c2:	53                   	push   %ebx
f01000c3:	83 ec 10             	sub    $0x10,%esp
f01000c6:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000c9:	83 3d 60 0e 18 f0 00 	cmpl   $0x0,0xf0180e60
f01000d0:	75 3d                	jne    f010010f <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000d2:	89 35 60 0e 18 f0    	mov    %esi,0xf0180e60

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000d8:	fa                   	cli    
f01000d9:	fc                   	cld    

	va_start(ap, fmt);
f01000da:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 9b 58 10 f0 	movl   $0xf010589b,(%esp)
f01000f2:	e8 73 3d 00 00       	call   f0103e6a <cprintf>
	vcprintf(fmt, ap);
f01000f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000fb:	89 34 24             	mov    %esi,(%esp)
f01000fe:	e8 34 3d 00 00       	call   f0103e37 <vcprintf>
	cprintf("\n");
f0100103:	c7 04 24 24 6e 10 f0 	movl   $0xf0106e24,(%esp)
f010010a:	e8 5b 3d 00 00       	call   f0103e6a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010010f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100116:	e8 91 0d 00 00       	call   f0100eac <monitor>
f010011b:	eb f2                	jmp    f010010f <_panic+0x51>

f010011d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011d:	55                   	push   %ebp
f010011e:	89 e5                	mov    %esp,%ebp
f0100120:	53                   	push   %ebx
f0100121:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100124:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100127:	8b 45 0c             	mov    0xc(%ebp),%eax
f010012a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010012e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100131:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100135:	c7 04 24 b3 58 10 f0 	movl   $0xf01058b3,(%esp)
f010013c:	e8 29 3d 00 00       	call   f0103e6a <cprintf>
	vcprintf(fmt, ap);
f0100141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100145:	8b 45 10             	mov    0x10(%ebp),%eax
f0100148:	89 04 24             	mov    %eax,(%esp)
f010014b:	e8 e7 3c 00 00       	call   f0103e37 <vcprintf>
	cprintf("\n");
f0100150:	c7 04 24 24 6e 10 f0 	movl   $0xf0106e24,(%esp)
f0100157:	e8 0e 3d 00 00       	call   f0103e6a <cprintf>
	va_end(ap);
}
f010015c:	83 c4 14             	add    $0x14,%esp
f010015f:	5b                   	pop    %ebx
f0100160:	5d                   	pop    %ebp
f0100161:	c3                   	ret    
	...

f0100170 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100173:	ba 84 00 00 00       	mov    $0x84,%edx
f0100178:	ec                   	in     (%dx),%al
f0100179:	ec                   	in     (%dx),%al
f010017a:	ec                   	in     (%dx),%al
f010017b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010017e:	55                   	push   %ebp
f010017f:	89 e5                	mov    %esp,%ebp
f0100181:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100186:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100187:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010018c:	a8 01                	test   $0x1,%al
f010018e:	74 06                	je     f0100196 <serial_proc_data+0x18>
f0100190:	b2 f8                	mov    $0xf8,%dl
f0100192:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100193:	0f b6 c8             	movzbl %al,%ecx
}
f0100196:	89 c8                	mov    %ecx,%eax
f0100198:	5d                   	pop    %ebp
f0100199:	c3                   	ret    

f010019a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010019a:	55                   	push   %ebp
f010019b:	89 e5                	mov    %esp,%ebp
f010019d:	53                   	push   %ebx
f010019e:	83 ec 04             	sub    $0x4,%esp
f01001a1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a3:	eb 25                	jmp    f01001ca <cons_intr+0x30>
		if (c == 0)
f01001a5:	85 c0                	test   %eax,%eax
f01001a7:	74 21                	je     f01001ca <cons_intr+0x30>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a9:	8b 15 a4 01 18 f0    	mov    0xf01801a4,%edx
f01001af:	88 82 a0 ff 17 f0    	mov    %al,-0xfe80060(%edx)
f01001b5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001b8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01001c2:	0f 44 c2             	cmove  %edx,%eax
f01001c5:	a3 a4 01 18 f0       	mov    %eax,0xf01801a4
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001ca:	ff d3                	call   *%ebx
f01001cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001cf:	75 d4                	jne    f01001a5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d1:	83 c4 04             	add    $0x4,%esp
f01001d4:	5b                   	pop    %ebx
f01001d5:	5d                   	pop    %ebp
f01001d6:	c3                   	ret    

f01001d7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001d7:	55                   	push   %ebp
f01001d8:	89 e5                	mov    %esp,%ebp
f01001da:	57                   	push   %edi
f01001db:	56                   	push   %esi
f01001dc:	53                   	push   %ebx
f01001dd:	83 ec 2c             	sub    $0x2c,%esp
f01001e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01001e3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e8:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001e9:	a8 20                	test   $0x20,%al
f01001eb:	75 1b                	jne    f0100208 <cons_putc+0x31>
f01001ed:	bb 00 32 00 00       	mov    $0x3200,%ebx
f01001f2:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001f7:	e8 74 ff ff ff       	call   f0100170 <delay>
f01001fc:	89 f2                	mov    %esi,%edx
f01001fe:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ff:	a8 20                	test   $0x20,%al
f0100201:	75 05                	jne    f0100208 <cons_putc+0x31>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100203:	83 eb 01             	sub    $0x1,%ebx
f0100206:	75 ef                	jne    f01001f7 <cons_putc+0x20>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100208:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010020c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100211:	89 f8                	mov    %edi,%eax
f0100213:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100214:	b2 79                	mov    $0x79,%dl
f0100216:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100217:	84 c0                	test   %al,%al
f0100219:	78 1b                	js     f0100236 <cons_putc+0x5f>
f010021b:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100220:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100225:	e8 46 ff ff ff       	call   f0100170 <delay>
f010022a:	89 f2                	mov    %esi,%edx
f010022c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010022d:	84 c0                	test   %al,%al
f010022f:	78 05                	js     f0100236 <cons_putc+0x5f>
f0100231:	83 eb 01             	sub    $0x1,%ebx
f0100234:	75 ef                	jne    f0100225 <cons_putc+0x4e>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100236:	ba 78 03 00 00       	mov    $0x378,%edx
f010023b:	89 f8                	mov    %edi,%eax
f010023d:	ee                   	out    %al,(%dx)
f010023e:	b2 7a                	mov    $0x7a,%dl
f0100240:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100245:	ee                   	out    %al,(%dx)
f0100246:	b8 08 00 00 00       	mov    $0x8,%eax
f010024b:	ee                   	out    %al,(%dx)
extern int ncolor;

static void
cga_putc(int c)
{
	c = c + (ncolor << 8);
f010024c:	a1 3c d4 11 f0       	mov    0xf011d43c,%eax
f0100251:	c1 e0 08             	shl    $0x8,%eax
f0100254:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100257:	89 c1                	mov    %eax,%ecx
f0100259:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f010025f:	89 c2                	mov    %eax,%edx
f0100261:	80 ce 07             	or     $0x7,%dh
f0100264:	85 c9                	test   %ecx,%ecx
f0100266:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f0100269:	0f b6 d0             	movzbl %al,%edx
f010026c:	83 fa 09             	cmp    $0x9,%edx
f010026f:	74 75                	je     f01002e6 <cons_putc+0x10f>
f0100271:	83 fa 09             	cmp    $0x9,%edx
f0100274:	7f 0c                	jg     f0100282 <cons_putc+0xab>
f0100276:	83 fa 08             	cmp    $0x8,%edx
f0100279:	0f 85 9b 00 00 00    	jne    f010031a <cons_putc+0x143>
f010027f:	90                   	nop
f0100280:	eb 10                	jmp    f0100292 <cons_putc+0xbb>
f0100282:	83 fa 0a             	cmp    $0xa,%edx
f0100285:	74 39                	je     f01002c0 <cons_putc+0xe9>
f0100287:	83 fa 0d             	cmp    $0xd,%edx
f010028a:	0f 85 8a 00 00 00    	jne    f010031a <cons_putc+0x143>
f0100290:	eb 36                	jmp    f01002c8 <cons_putc+0xf1>
	case '\b':
		if (crt_pos > 0) {
f0100292:	0f b7 15 b4 01 18 f0 	movzwl 0xf01801b4,%edx
f0100299:	66 85 d2             	test   %dx,%dx
f010029c:	0f 84 e3 00 00 00    	je     f0100385 <cons_putc+0x1ae>
			crt_pos--;
f01002a2:	83 ea 01             	sub    $0x1,%edx
f01002a5:	66 89 15 b4 01 18 f0 	mov    %dx,0xf01801b4
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002ac:	0f b7 d2             	movzwl %dx,%edx
f01002af:	b0 00                	mov    $0x0,%al
f01002b1:	83 c8 20             	or     $0x20,%eax
f01002b4:	8b 0d b0 01 18 f0    	mov    0xf01801b0,%ecx
f01002ba:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01002be:	eb 78                	jmp    f0100338 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002c0:	66 83 05 b4 01 18 f0 	addw   $0x50,0xf01801b4
f01002c7:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002c8:	0f b7 05 b4 01 18 f0 	movzwl 0xf01801b4,%eax
f01002cf:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002d5:	c1 e8 16             	shr    $0x16,%eax
f01002d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002db:	c1 e0 04             	shl    $0x4,%eax
f01002de:	66 a3 b4 01 18 f0    	mov    %ax,0xf01801b4
f01002e4:	eb 52                	jmp    f0100338 <cons_putc+0x161>
		break;
	case '\t':
		cons_putc(' ');
f01002e6:	b8 20 00 00 00       	mov    $0x20,%eax
f01002eb:	e8 e7 fe ff ff       	call   f01001d7 <cons_putc>
		cons_putc(' ');
f01002f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f5:	e8 dd fe ff ff       	call   f01001d7 <cons_putc>
		cons_putc(' ');
f01002fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ff:	e8 d3 fe ff ff       	call   f01001d7 <cons_putc>
		cons_putc(' ');
f0100304:	b8 20 00 00 00       	mov    $0x20,%eax
f0100309:	e8 c9 fe ff ff       	call   f01001d7 <cons_putc>
		cons_putc(' ');
f010030e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100313:	e8 bf fe ff ff       	call   f01001d7 <cons_putc>
f0100318:	eb 1e                	jmp    f0100338 <cons_putc+0x161>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010031a:	0f b7 15 b4 01 18 f0 	movzwl 0xf01801b4,%edx
f0100321:	0f b7 da             	movzwl %dx,%ebx
f0100324:	8b 0d b0 01 18 f0    	mov    0xf01801b0,%ecx
f010032a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010032e:	83 c2 01             	add    $0x1,%edx
f0100331:	66 89 15 b4 01 18 f0 	mov    %dx,0xf01801b4
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100338:	66 81 3d b4 01 18 f0 	cmpw   $0x7cf,0xf01801b4
f010033f:	cf 07 
f0100341:	76 42                	jbe    f0100385 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100343:	a1 b0 01 18 f0       	mov    0xf01801b0,%eax
f0100348:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010034f:	00 
f0100350:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100356:	89 54 24 04          	mov    %edx,0x4(%esp)
f010035a:	89 04 24             	mov    %eax,(%esp)
f010035d:	e8 6a 50 00 00       	call   f01053cc <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100362:	8b 15 b0 01 18 f0    	mov    0xf01801b0,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100368:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010036d:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100373:	83 c0 01             	add    $0x1,%eax
f0100376:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010037b:	75 f0                	jne    f010036d <cons_putc+0x196>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010037d:	66 83 2d b4 01 18 f0 	subw   $0x50,0xf01801b4
f0100384:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100385:	8b 0d ac 01 18 f0    	mov    0xf01801ac,%ecx
f010038b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100390:	89 ca                	mov    %ecx,%edx
f0100392:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100393:	0f b7 35 b4 01 18 f0 	movzwl 0xf01801b4,%esi
f010039a:	8d 59 01             	lea    0x1(%ecx),%ebx
f010039d:	89 f0                	mov    %esi,%eax
f010039f:	66 c1 e8 08          	shr    $0x8,%ax
f01003a3:	89 da                	mov    %ebx,%edx
f01003a5:	ee                   	out    %al,(%dx)
f01003a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003ab:	89 ca                	mov    %ecx,%edx
f01003ad:	ee                   	out    %al,(%dx)
f01003ae:	89 f0                	mov    %esi,%eax
f01003b0:	89 da                	mov    %ebx,%edx
f01003b2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003b3:	83 c4 2c             	add    $0x2c,%esp
f01003b6:	5b                   	pop    %ebx
f01003b7:	5e                   	pop    %esi
f01003b8:	5f                   	pop    %edi
f01003b9:	5d                   	pop    %ebp
f01003ba:	c3                   	ret    

f01003bb <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003bb:	55                   	push   %ebp
f01003bc:	89 e5                	mov    %esp,%ebp
f01003be:	53                   	push   %ebx
f01003bf:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c2:	ba 64 00 00 00       	mov    $0x64,%edx
f01003c7:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003cd:	a8 01                	test   $0x1,%al
f01003cf:	0f 84 de 00 00 00    	je     f01004b3 <kbd_proc_data+0xf8>
f01003d5:	b2 60                	mov    $0x60,%dl
f01003d7:	ec                   	in     (%dx),%al
f01003d8:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003da:	3c e0                	cmp    $0xe0,%al
f01003dc:	75 11                	jne    f01003ef <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f01003de:	83 0d a8 01 18 f0 40 	orl    $0x40,0xf01801a8
		return 0;
f01003e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ea:	e9 c4 00 00 00       	jmp    f01004b3 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003ef:	84 c0                	test   %al,%al
f01003f1:	79 37                	jns    f010042a <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003f3:	8b 0d a8 01 18 f0    	mov    0xf01801a8,%ecx
f01003f9:	89 cb                	mov    %ecx,%ebx
f01003fb:	83 e3 40             	and    $0x40,%ebx
f01003fe:	83 e0 7f             	and    $0x7f,%eax
f0100401:	85 db                	test   %ebx,%ebx
f0100403:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100406:	0f b6 d2             	movzbl %dl,%edx
f0100409:	0f b6 82 00 59 10 f0 	movzbl -0xfefa700(%edx),%eax
f0100410:	83 c8 40             	or     $0x40,%eax
f0100413:	0f b6 c0             	movzbl %al,%eax
f0100416:	f7 d0                	not    %eax
f0100418:	21 c1                	and    %eax,%ecx
f010041a:	89 0d a8 01 18 f0    	mov    %ecx,0xf01801a8
		return 0;
f0100420:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100425:	e9 89 00 00 00       	jmp    f01004b3 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010042a:	8b 0d a8 01 18 f0    	mov    0xf01801a8,%ecx
f0100430:	f6 c1 40             	test   $0x40,%cl
f0100433:	74 0e                	je     f0100443 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100435:	89 c2                	mov    %eax,%edx
f0100437:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010043a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010043d:	89 0d a8 01 18 f0    	mov    %ecx,0xf01801a8
	}

	shift |= shiftcode[data];
f0100443:	0f b6 d2             	movzbl %dl,%edx
f0100446:	0f b6 82 00 59 10 f0 	movzbl -0xfefa700(%edx),%eax
f010044d:	0b 05 a8 01 18 f0    	or     0xf01801a8,%eax
	shift ^= togglecode[data];
f0100453:	0f b6 8a 00 5a 10 f0 	movzbl -0xfefa600(%edx),%ecx
f010045a:	31 c8                	xor    %ecx,%eax
f010045c:	a3 a8 01 18 f0       	mov    %eax,0xf01801a8

	c = charcode[shift & (CTL | SHIFT)][data];
f0100461:	89 c1                	mov    %eax,%ecx
f0100463:	83 e1 03             	and    $0x3,%ecx
f0100466:	8b 0c 8d 00 5b 10 f0 	mov    -0xfefa500(,%ecx,4),%ecx
f010046d:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100471:	a8 08                	test   $0x8,%al
f0100473:	74 19                	je     f010048e <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100475:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100478:	83 fa 19             	cmp    $0x19,%edx
f010047b:	77 05                	ja     f0100482 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010047d:	83 eb 20             	sub    $0x20,%ebx
f0100480:	eb 0c                	jmp    f010048e <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100482:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f0100485:	8d 53 20             	lea    0x20(%ebx),%edx
f0100488:	83 f9 19             	cmp    $0x19,%ecx
f010048b:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010048e:	f7 d0                	not    %eax
f0100490:	a8 06                	test   $0x6,%al
f0100492:	75 1f                	jne    f01004b3 <kbd_proc_data+0xf8>
f0100494:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010049a:	75 17                	jne    f01004b3 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010049c:	c7 04 24 cd 58 10 f0 	movl   $0xf01058cd,(%esp)
f01004a3:	e8 c2 39 00 00       	call   f0103e6a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a8:	ba 92 00 00 00       	mov    $0x92,%edx
f01004ad:	b8 03 00 00 00       	mov    $0x3,%eax
f01004b2:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004b3:	89 d8                	mov    %ebx,%eax
f01004b5:	83 c4 14             	add    $0x14,%esp
f01004b8:	5b                   	pop    %ebx
f01004b9:	5d                   	pop    %ebp
f01004ba:	c3                   	ret    

f01004bb <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004bb:	55                   	push   %ebp
f01004bc:	89 e5                	mov    %esp,%ebp
f01004be:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004c1:	80 3d 80 ff 17 f0 00 	cmpb   $0x0,0xf017ff80
f01004c8:	74 0a                	je     f01004d4 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004ca:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004cf:	e8 c6 fc ff ff       	call   f010019a <cons_intr>
}
f01004d4:	c9                   	leave  
f01004d5:	c3                   	ret    

f01004d6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004d6:	55                   	push   %ebp
f01004d7:	89 e5                	mov    %esp,%ebp
f01004d9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004dc:	b8 bb 03 10 f0       	mov    $0xf01003bb,%eax
f01004e1:	e8 b4 fc ff ff       	call   f010019a <cons_intr>
}
f01004e6:	c9                   	leave  
f01004e7:	c3                   	ret    

f01004e8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004e8:	55                   	push   %ebp
f01004e9:	89 e5                	mov    %esp,%ebp
f01004eb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004ee:	e8 c8 ff ff ff       	call   f01004bb <serial_intr>
	kbd_intr();
f01004f3:	e8 de ff ff ff       	call   f01004d6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004f8:	8b 15 a0 01 18 f0    	mov    0xf01801a0,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01004fe:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100503:	3b 15 a4 01 18 f0    	cmp    0xf01801a4,%edx
f0100509:	74 1e                	je     f0100529 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010050b:	0f b6 82 a0 ff 17 f0 	movzbl -0xfe80060(%edx),%eax
f0100512:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100515:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010051b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100520:	0f 44 d1             	cmove  %ecx,%edx
f0100523:	89 15 a0 01 18 f0    	mov    %edx,0xf01801a0
		return c;
	}
	return 0;
}
f0100529:	c9                   	leave  
f010052a:	c3                   	ret    

f010052b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010052b:	55                   	push   %ebp
f010052c:	89 e5                	mov    %esp,%ebp
f010052e:	57                   	push   %edi
f010052f:	56                   	push   %esi
f0100530:	53                   	push   %ebx
f0100531:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100534:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010053b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100542:	5a a5 
	if (*cp != 0xA55A) {
f0100544:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010054b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010054f:	74 11                	je     f0100562 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100551:	c7 05 ac 01 18 f0 b4 	movl   $0x3b4,0xf01801ac
f0100558:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010055b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100560:	eb 16                	jmp    f0100578 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100562:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100569:	c7 05 ac 01 18 f0 d4 	movl   $0x3d4,0xf01801ac
f0100570:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100573:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100578:	8b 0d ac 01 18 f0    	mov    0xf01801ac,%ecx
f010057e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100583:	89 ca                	mov    %ecx,%edx
f0100585:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100586:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100589:	89 da                	mov    %ebx,%edx
f010058b:	ec                   	in     (%dx),%al
f010058c:	0f b6 f8             	movzbl %al,%edi
f010058f:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100592:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100597:	89 ca                	mov    %ecx,%edx
f0100599:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010059a:	89 da                	mov    %ebx,%edx
f010059c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010059d:	89 35 b0 01 18 f0    	mov    %esi,0xf01801b0

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005a3:	0f b6 d8             	movzbl %al,%ebx
f01005a6:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005a8:	66 89 3d b4 01 18 f0 	mov    %di,0xf01801b4
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005af:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b9:	89 da                	mov    %ebx,%edx
f01005bb:	ee                   	out    %al,(%dx)
f01005bc:	b2 fb                	mov    $0xfb,%dl
f01005be:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005c3:	ee                   	out    %al,(%dx)
f01005c4:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005c9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ce:	89 ca                	mov    %ecx,%edx
f01005d0:	ee                   	out    %al,(%dx)
f01005d1:	b2 f9                	mov    $0xf9,%dl
f01005d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d8:	ee                   	out    %al,(%dx)
f01005d9:	b2 fb                	mov    $0xfb,%dl
f01005db:	b8 03 00 00 00       	mov    $0x3,%eax
f01005e0:	ee                   	out    %al,(%dx)
f01005e1:	b2 fc                	mov    $0xfc,%dl
f01005e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e8:	ee                   	out    %al,(%dx)
f01005e9:	b2 f9                	mov    $0xf9,%dl
f01005eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01005f0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f1:	b2 fd                	mov    $0xfd,%dl
f01005f3:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005f4:	3c ff                	cmp    $0xff,%al
f01005f6:	0f 95 c0             	setne  %al
f01005f9:	89 c6                	mov    %eax,%esi
f01005fb:	a2 80 ff 17 f0       	mov    %al,0xf017ff80
f0100600:	89 da                	mov    %ebx,%edx
f0100602:	ec                   	in     (%dx),%al
f0100603:	89 ca                	mov    %ecx,%edx
f0100605:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100606:	89 f0                	mov    %esi,%eax
f0100608:	84 c0                	test   %al,%al
f010060a:	75 0c                	jne    f0100618 <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f010060c:	c7 04 24 d9 58 10 f0 	movl   $0xf01058d9,(%esp)
f0100613:	e8 52 38 00 00       	call   f0103e6a <cprintf>
}
f0100618:	83 c4 1c             	add    $0x1c,%esp
f010061b:	5b                   	pop    %ebx
f010061c:	5e                   	pop    %esi
f010061d:	5f                   	pop    %edi
f010061e:	5d                   	pop    %ebp
f010061f:	c3                   	ret    

f0100620 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100626:	8b 45 08             	mov    0x8(%ebp),%eax
f0100629:	e8 a9 fb ff ff       	call   f01001d7 <cons_putc>
}
f010062e:	c9                   	leave  
f010062f:	c3                   	ret    

f0100630 <getchar>:

int
getchar(void)
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100636:	e8 ad fe ff ff       	call   f01004e8 <cons_getc>
f010063b:	85 c0                	test   %eax,%eax
f010063d:	74 f7                	je     f0100636 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010063f:	c9                   	leave  
f0100640:	c3                   	ret    

f0100641 <iscons>:

int
iscons(int fdnum)
{
f0100641:	55                   	push   %ebp
f0100642:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100644:	b8 01 00 00 00       	mov    $0x1,%eax
f0100649:	5d                   	pop    %ebp
f010064a:	c3                   	ret    
f010064b:	00 00                	add    %al,(%eax)
f010064d:	00 00                	add    %al,(%eax)
	...

f0100650 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100656:	c7 04 24 10 5b 10 f0 	movl   $0xf0105b10,(%esp)
f010065d:	e8 08 38 00 00       	call   f0103e6a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100662:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100669:	00 
f010066a:	c7 04 24 9c 5c 10 f0 	movl   $0xf0105c9c,(%esp)
f0100671:	e8 f4 37 00 00       	call   f0103e6a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100676:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010067d:	00 
f010067e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100685:	f0 
f0100686:	c7 04 24 c4 5c 10 f0 	movl   $0xf0105cc4,(%esp)
f010068d:	e8 d8 37 00 00       	call   f0103e6a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100692:	c7 44 24 08 65 58 10 	movl   $0x105865,0x8(%esp)
f0100699:	00 
f010069a:	c7 44 24 04 65 58 10 	movl   $0xf0105865,0x4(%esp)
f01006a1:	f0 
f01006a2:	c7 04 24 e8 5c 10 f0 	movl   $0xf0105ce8,(%esp)
f01006a9:	e8 bc 37 00 00       	call   f0103e6a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ae:	c7 44 24 08 76 ff 17 	movl   $0x17ff76,0x8(%esp)
f01006b5:	00 
f01006b6:	c7 44 24 04 76 ff 17 	movl   $0xf017ff76,0x4(%esp)
f01006bd:	f0 
f01006be:	c7 04 24 0c 5d 10 f0 	movl   $0xf0105d0c,(%esp)
f01006c5:	e8 a0 37 00 00       	call   f0103e6a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ca:	c7 44 24 08 70 0e 18 	movl   $0x180e70,0x8(%esp)
f01006d1:	00 
f01006d2:	c7 44 24 04 70 0e 18 	movl   $0xf0180e70,0x4(%esp)
f01006d9:	f0 
f01006da:	c7 04 24 30 5d 10 f0 	movl   $0xf0105d30,(%esp)
f01006e1:	e8 84 37 00 00       	call   f0103e6a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e6:	b8 6f 12 18 f0       	mov    $0xf018126f,%eax
f01006eb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006f0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006fb:	85 c0                	test   %eax,%eax
f01006fd:	0f 48 c2             	cmovs  %edx,%eax
f0100700:	c1 f8 0a             	sar    $0xa,%eax
f0100703:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100707:	c7 04 24 54 5d 10 f0 	movl   $0xf0105d54,(%esp)
f010070e:	e8 57 37 00 00       	call   f0103e6a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100713:	b8 00 00 00 00       	mov    $0x0,%eax
f0100718:	c9                   	leave  
f0100719:	c3                   	ret    

f010071a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	53                   	push   %ebx
f010071e:	83 ec 14             	sub    $0x14,%esp
f0100721:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100726:	8b 83 44 60 10 f0    	mov    -0xfef9fbc(%ebx),%eax
f010072c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100730:	8b 83 40 60 10 f0    	mov    -0xfef9fc0(%ebx),%eax
f0100736:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073a:	c7 04 24 29 5b 10 f0 	movl   $0xf0105b29,(%esp)
f0100741:	e8 24 37 00 00       	call   f0103e6a <cprintf>
f0100746:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100749:	83 fb 48             	cmp    $0x48,%ebx
f010074c:	75 d8                	jne    f0100726 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010074e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100753:	83 c4 14             	add    $0x14,%esp
f0100756:	5b                   	pop    %ebx
f0100757:	5d                   	pop    %ebp
f0100758:	c3                   	ret    

f0100759 <mon_changepermission>:
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
f0100759:	55                   	push   %ebp
f010075a:	89 e5                	mov    %esp,%ebp
f010075c:	57                   	push   %edi
f010075d:	56                   	push   %esi
f010075e:	53                   	push   %ebx
f010075f:	83 ec 2c             	sub    $0x2c,%esp
f0100762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f0100765:	8b 55 08             	mov    0x8(%ebp),%edx
f0100768:	83 ea 03             	sub    $0x3,%edx
		return -1;
f010076b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return 0;
}

int mon_changepermission(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: changepermission [-option] [vitual address] [perm]
	if(argc != 4 && argc != 3)
f0100770:	83 fa 01             	cmp    $0x1,%edx
f0100773:	0f 87 f8 01 00 00    	ja     f0100971 <mon_changepermission+0x218>
		return -1;

	extern pde_t *kern_pgdir;
	unsigned int num = strtol(argv[2], NULL, 16);
f0100779:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100780:	00 
f0100781:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100788:	00 
f0100789:	8b 43 08             	mov    0x8(%ebx),%eax
f010078c:	89 04 24             	mov    %eax,(%esp)
f010078f:	e8 50 4d 00 00       	call   f01054e4 <strtol>
f0100794:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f0100796:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100799:	89 44 24 08          	mov    %eax,0x8(%esp)
f010079d:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007a1:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01007a6:	89 04 24             	mov    %eax,(%esp)
f01007a9:	e8 e9 0f 00 00       	call   f0101797 <page_lookup>
	if(!pageofva)
f01007ae:	85 c0                	test   %eax,%eax
f01007b0:	0f 84 b6 01 00 00    	je     f010096c <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f01007b6:	c7 44 24 04 32 5b 10 	movl   $0xf0105b32,0x4(%esp)
f01007bd:	f0 
f01007be:	8b 43 04             	mov    0x4(%ebx),%eax
f01007c1:	89 04 24             	mov    %eax,(%esp)
f01007c4:	e8 d2 4a 00 00       	call   f010529b <strcmp>
	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;

	unsigned int perm = 0;
f01007c9:	bf 00 00 00 00       	mov    $0x0,%edi
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f01007ce:	85 c0                	test   %eax,%eax
f01007d0:	75 2e                	jne    f0100800 <mon_changepermission+0xa7>
		perm = strtol(argv[3], NULL, 16) | PTE_P;
f01007d2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01007d9:	00 
f01007da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01007e1:	00 
f01007e2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01007e5:	89 04 24             	mov    %eax,(%esp)
f01007e8:	e8 f7 4c 00 00       	call   f01054e4 <strtol>
f01007ed:	89 c7                	mov    %eax,%edi
f01007ef:	83 cf 01             	or     $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f01007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007f5:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f01007fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007fe:	01 38                	add    %edi,(%eax)
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
f0100800:	c7 44 24 04 37 5b 10 	movl   $0xf0105b37,0x4(%esp)
f0100807:	f0 
f0100808:	8b 43 04             	mov    0x4(%ebx),%eax
f010080b:	89 04 24             	mov    %eax,(%esp)
f010080e:	e8 88 4a 00 00       	call   f010529b <strcmp>
f0100813:	85 c0                	test   %eax,%eax
f0100815:	75 14                	jne    f010082b <mon_changepermission+0xd2>
		perm = 1;
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
f0100817:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010081a:	81 20 00 f0 ff ff    	andl   $0xfffff000,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
f0100820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100823:	83 00 01             	addl   $0x1,(%eax)
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// clear: clear all the permission bits
	if(strcmp(argv[1], "-clear") == 0) {
		perm = 1;
f0100826:	bf 01 00 00 00       	mov    $0x1,%edi
		*((pte_t *)_pte) = *((pte_t *)_pte) & 0xfffff000;
		*((pte_t *)_pte) = *((pte_t *)_pte) + perm;
	}
	// change
	if(strcmp(argv[1], "-change") == 0) {
f010082b:	c7 44 24 04 3e 5b 10 	movl   $0xf0105b3e,0x4(%esp)
f0100832:	f0 
f0100833:	8b 43 04             	mov    0x4(%ebx),%eax
f0100836:	89 04 24             	mov    %eax,(%esp)
f0100839:	e8 5d 4a 00 00       	call   f010529b <strcmp>
f010083e:	85 c0                	test   %eax,%eax
f0100840:	0f 85 0b 01 00 00    	jne    f0100951 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f0100846:	c7 44 24 04 44 6b 10 	movl   $0xf0106b44,0x4(%esp)
f010084d:	f0 
f010084e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 42 4a 00 00       	call   f010529b <strcmp>
f0100859:	85 c0                	test   %eax,%eax
f010085b:	75 06                	jne    f0100863 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f010085d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100860:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f0100863:	c7 44 24 04 55 6b 10 	movl   $0xf0106b55,0x4(%esp)
f010086a:	f0 
f010086b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010086e:	89 04 24             	mov    %eax,(%esp)
f0100871:	e8 25 4a 00 00       	call   f010529b <strcmp>
f0100876:	85 c0                	test   %eax,%eax
f0100878:	75 06                	jne    f0100880 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f010087a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010087d:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100880:	c7 44 24 04 46 5b 10 	movl   $0xf0105b46,0x4(%esp)
f0100887:	f0 
f0100888:	8b 43 0c             	mov    0xc(%ebx),%eax
f010088b:	89 04 24             	mov    %eax,(%esp)
f010088e:	e8 08 4a 00 00       	call   f010529b <strcmp>
f0100893:	85 c0                	test   %eax,%eax
f0100895:	75 06                	jne    f010089d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010089a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f010089d:	c7 44 24 04 b8 6a 10 	movl   $0xf0106ab8,0x4(%esp)
f01008a4:	f0 
f01008a5:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008a8:	89 04 24             	mov    %eax,(%esp)
f01008ab:	e8 eb 49 00 00       	call   f010529b <strcmp>
f01008b0:	85 c0                	test   %eax,%eax
f01008b2:	75 06                	jne    f01008ba <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f01008b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008b7:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f01008ba:	c7 44 24 04 4e 5b 10 	movl   $0xf0105b4e,0x4(%esp)
f01008c1:	f0 
f01008c2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008c5:	89 04 24             	mov    %eax,(%esp)
f01008c8:	e8 ce 49 00 00       	call   f010529b <strcmp>
f01008cd:	85 c0                	test   %eax,%eax
f01008cf:	75 06                	jne    f01008d7 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f01008d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008d4:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f01008d7:	c7 44 24 04 56 5b 10 	movl   $0xf0105b56,0x4(%esp)
f01008de:	f0 
f01008df:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008e2:	89 04 24             	mov    %eax,(%esp)
f01008e5:	e8 b1 49 00 00       	call   f010529b <strcmp>
f01008ea:	85 c0                	test   %eax,%eax
f01008ec:	75 06                	jne    f01008f4 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f01008ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008f1:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f01008f4:	c7 44 24 04 5c 5b 10 	movl   $0xf0105b5c,0x4(%esp)
f01008fb:	f0 
f01008fc:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008ff:	89 04 24             	mov    %eax,(%esp)
f0100902:	e8 94 49 00 00       	call   f010529b <strcmp>
f0100907:	85 c0                	test   %eax,%eax
f0100909:	75 06                	jne    f0100911 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f010090b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010090e:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100911:	c7 44 24 04 62 5b 10 	movl   $0xf0105b62,0x4(%esp)
f0100918:	f0 
f0100919:	8b 43 0c             	mov    0xc(%ebx),%eax
f010091c:	89 04 24             	mov    %eax,(%esp)
f010091f:	e8 77 49 00 00       	call   f010529b <strcmp>
f0100924:	85 c0                	test   %eax,%eax
f0100926:	75 09                	jne    f0100931 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100928:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010092b:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100931:	c7 44 24 04 69 5b 10 	movl   $0xf0105b69,0x4(%esp)
f0100938:	f0 
f0100939:	8b 43 0c             	mov    0xc(%ebx),%eax
f010093c:	89 04 24             	mov    %eax,(%esp)
f010093f:	e8 57 49 00 00       	call   f010529b <strcmp>
f0100944:	85 c0                	test   %eax,%eax
f0100946:	75 09                	jne    f0100951 <mon_changepermission+0x1f8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_G;
f0100948:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010094b:	81 30 00 01 00 00    	xorl   $0x100,(%eax)
	}
	

	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
f0100951:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100955:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100959:	c7 04 24 6f 5b 10 f0 	movl   $0xf0105b6f,(%esp)
f0100960:	e8 05 35 00 00       	call   f0103e6a <cprintf>
		num, perm);

	return 0;
f0100965:	b8 00 00 00 00       	mov    $0x0,%eax
f010096a:	eb 05                	jmp    f0100971 <mon_changepermission+0x218>
	unsigned int num = strtol(argv[2], NULL, 16);

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
	if(!pageofva)
		return -1;
f010096c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// print the result of permission bits
	cprintf("0x%x permission bits: 0x%x\n", 
		num, perm);

	return 0;
}
f0100971:	83 c4 2c             	add    $0x2c,%esp
f0100974:	5b                   	pop    %ebx
f0100975:	5e                   	pop    %esi
f0100976:	5f                   	pop    %edi
f0100977:	5d                   	pop    %ebp
f0100978:	c3                   	ret    

f0100979 <mon_showmappings>:
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
f0100979:	55                   	push   %ebp
f010097a:	89 e5                	mov    %esp,%ebp
f010097c:	57                   	push   %edi
f010097d:	56                   	push   %esi
f010097e:	53                   	push   %ebx
f010097f:	83 ec 2c             	sub    $0x2c,%esp
f0100982:	8b 75 0c             	mov    0xc(%ebp),%esi
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
		return -1;
f0100985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc != 3)
f010098a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010098e:	0f 85 a6 00 00 00    	jne    f0100a3a <mon_showmappings+0xc1>

	// Get the 2 arguments
	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
f0100994:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010099b:	00 
f010099c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009a3:	00 
f01009a4:	8b 46 04             	mov    0x4(%esi),%eax
f01009a7:	89 04 24             	mov    %eax,(%esp)
f01009aa:	e8 35 4b 00 00       	call   f01054e4 <strtol>
f01009af:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f01009b1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01009b8:	00 
f01009b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009c0:	00 
f01009c1:	8b 46 08             	mov    0x8(%esi),%eax
f01009c4:	89 04 24             	mov    %eax,(%esp)
f01009c7:	e8 18 4b 00 00       	call   f01054e4 <strtol>
f01009cc:	89 c7                	mov    %eax,%edi
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f01009ce:	b8 00 00 00 00       	mov    $0x0,%eax

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f01009d3:	39 fb                	cmp    %edi,%ebx
f01009d5:	77 63                	ja     f0100a3a <mon_showmappings+0xc1>
		unsigned int _pte;
		struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num[0], (pte_t **)(&_pte));
f01009d7:	8d 75 e4             	lea    -0x1c(%ebp),%esi
f01009da:	89 74 24 08          	mov    %esi,0x8(%esp)
f01009de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009e2:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01009e7:	89 04 24             	mov    %eax,(%esp)
f01009ea:	e8 a8 0d 00 00       	call   f0101797 <page_lookup>

		if(!pageofva) {
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	75 0e                	jne    f0100a01 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f01009f3:	c7 04 24 80 5d 10 f0 	movl   $0xf0105d80,(%esp)
f01009fa:	e8 6b 34 00 00       	call   f0103e6a <cprintf>
			continue;
f01009ff:	eb 2a                	jmp    f0100a2b <mon_showmappings+0xb2>
		}
		pte_t pte = *((pte_t *)_pte);
f0100a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a04:	8b 00                	mov    (%eax),%eax
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));
f0100a06:	89 c2                	mov    %eax,%edx
f0100a08:	81 e2 ff 0f 00 00    	and    $0xfff,%edx

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
f0100a0e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100a12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a17:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100a1f:	c7 04 24 a8 5d 10 f0 	movl   $0xf0105da8,(%esp)
f0100a26:	e8 3f 34 00 00       	call   f0103e6a <cprintf>
f0100a2b:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
f0100a31:	39 df                	cmp    %ebx,%edi
f0100a33:	73 a5                	jae    f01009da <mon_showmappings+0x61>
		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address-0x%x, permission bits-0x%x\n", 
			num[0], PTE_ADDR(pte), perm);
	}
	return 0;
f0100a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a3a:	83 c4 2c             	add    $0x2c,%esp
f0100a3d:	5b                   	pop    %ebx
f0100a3e:	5e                   	pop    %esi
f0100a3f:	5f                   	pop    %edi
f0100a40:	5d                   	pop    %ebp
f0100a41:	c3                   	ret    

f0100a42 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a42:	55                   	push   %ebp
f0100a43:	89 e5                	mov    %esp,%ebp
f0100a45:	57                   	push   %edi
f0100a46:	56                   	push   %esi
f0100a47:	53                   	push   %ebx
f0100a48:	81 ec cc 00 00 00    	sub    $0xcc,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a4e:	89 eb                	mov    %ebp,%ebx
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
f0100a50:	89 de                	mov    %ebx,%esi
 	eip = (uint32_t*) ebp[1];
f0100a52:	8b 43 04             	mov    0x4(%ebx),%eax
f0100a55:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
 	arg0 = ebp[2];
f0100a5b:	8b 43 08             	mov    0x8(%ebx),%eax
f0100a5e:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 	arg1 = ebp[3];
f0100a64:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100a67:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	arg2 = ebp[4];
f0100a6d:	8b 43 10             	mov    0x10(%ebx),%eax
f0100a70:	89 85 58 ff ff ff    	mov    %eax,-0xa8(%ebp)
	arg3 = ebp[5];
f0100a76:	8b 43 14             	mov    0x14(%ebx),%eax
f0100a79:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	arg4 = ebp[6];
f0100a7f:	8b 7b 18             	mov    0x18(%ebx),%edi

	cprintf ("Stack backtrace:\n");
f0100a82:	c7 04 24 8b 5b 10 f0 	movl   $0xf0105b8b,(%esp)
f0100a89:	e8 dc 33 00 00       	call   f0103e6a <cprintf>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100a8e:	b8 00 00 00 00       	mov    $0x0,%eax
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100a93:	85 db                	test   %ebx,%ebx
f0100a95:	0f 84 f5 00 00 00    	je     f0100b90 <mon_backtrace+0x14e>
	// Lab1 Ex11.	
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;

	ebp = (uint32_t*) read_ebp();
 	eip = (uint32_t*) ebp[1];
f0100a9b:	8b 9d 60 ff ff ff    	mov    -0xa0(%ebp),%ebx
		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100aa1:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f0100aa7:	8b 95 58 ff ff ff    	mov    -0xa8(%ebp),%edx
f0100aad:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100ab3:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100ab7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100abb:	89 54 24 14          	mov    %edx,0x14(%esp)
f0100abf:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100ac3:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100ac9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100acd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100ad1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ad5:	c7 04 24 dc 5d 10 f0 	movl   $0xf0105ddc,(%esp)
f0100adc:	e8 89 33 00 00       	call   f0103e6a <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100ae1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae8:	89 1c 24             	mov    %ebx,(%esp)
f0100aeb:	e8 da 3b 00 00       	call   f01046ca <debuginfo_eip>
f0100af0:	85 c0                	test   %eax,%eax
f0100af2:	0f 88 93 00 00 00    	js     f0100b8b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100af8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100afb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aff:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100b05:	89 04 24             	mov    %eax,(%esp)
f0100b08:	e8 ce 46 00 00       	call   f01051db <strcpy>

		int eip_line = info.eip_line;
f0100b0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b10:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
f0100b16:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b19:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b24:	8d 7d 9e             	lea    -0x62(%ebp),%edi
f0100b27:	89 3c 24             	mov    %edi,(%esp)
f0100b2a:	e8 f7 46 00 00       	call   f0105226 <strncpy>
		eip_fn_name[info.eip_fn_namelen] = '\0';
f0100b2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b32:	c6 44 05 9e 00       	movb   $0x0,-0x62(%ebp,%eax,1)
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;
f0100b37:	2b 5d e0             	sub    -0x20(%ebp),%ebx


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100b3a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
			eip_fn_name, eip_fn_line);
f0100b3e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
f0100b42:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f0100b48:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b4c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100b52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b56:	c7 04 24 9d 5b 10 f0 	movl   $0xf0105b9d,(%esp)
f0100b5d:	e8 08 33 00 00       	call   f0103e6a <cprintf>
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
f0100b62:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t*) ebp[1];
f0100b64:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f0100b67:	8b 46 08             	mov    0x8(%esi),%eax
f0100b6a:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		arg1 = ebp[3];
f0100b70:	8b 46 0c             	mov    0xc(%esi),%eax
		arg2 = ebp[4];
f0100b73:	8b 56 10             	mov    0x10(%esi),%edx
		arg3 = ebp[5];
f0100b76:	8b 4e 14             	mov    0x14(%esi),%ecx
		arg4 = ebp[6];
f0100b79:	8b 7e 18             	mov    0x18(%esi),%edi
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
f0100b7c:	85 f6                	test   %esi,%esi
f0100b7e:	0f 85 2f ff ff ff    	jne    f0100ab3 <mon_backtrace+0x71>
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
f0100b84:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b89:	eb 05                	jmp    f0100b90 <mon_backtrace+0x14e>
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
f0100b8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100b90:	81 c4 cc 00 00 00    	add    $0xcc,%esp
f0100b96:	5b                   	pop    %ebx
f0100b97:	5e                   	pop    %esi
f0100b98:	5f                   	pop    %edi
f0100b99:	5d                   	pop    %ebp
f0100b9a:	c3                   	ret    

f0100b9b <mon_dump>:
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100b9b:	55                   	push   %ebp
f0100b9c:	89 e5                	mov    %esp,%ebp
f0100b9e:	57                   	push   %edi
f0100b9f:	56                   	push   %esi
f0100ba0:	53                   	push   %ebx
f0100ba1:	83 ec 3c             	sub    $0x3c,%esp
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
f0100ba4:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100ba8:	0f 85 ea 02 00 00    	jne    f0100e98 <mon_dump+0x2fd>
		return -1;
	
	unsigned int addr = strtol(argv[2], NULL, 16);
f0100bae:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100bb5:	00 
f0100bb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100bbd:	00 
f0100bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bc1:	8b 42 08             	mov    0x8(%edx),%eax
f0100bc4:	89 04 24             	mov    %eax,(%esp)
f0100bc7:	e8 18 49 00 00       	call   f01054e4 <strtol>
f0100bcc:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100bce:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100bd5:	00 
f0100bd6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100bdd:	00 
f0100bde:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100be1:	8b 42 0c             	mov    0xc(%edx),%eax
f0100be4:	89 04 24             	mov    %eax,(%esp)
f0100be7:	e8 f8 48 00 00       	call   f01054e4 <strtol>
f0100bec:	89 45 d0             	mov    %eax,-0x30(%ebp)

	if(argv[1][1] == 'v') {
f0100bef:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bf2:	8b 42 04             	mov    0x4(%edx),%eax
f0100bf5:	80 78 01 76          	cmpb   $0x76,0x1(%eax)
f0100bf9:	0f 85 af 00 00 00    	jne    f0100cae <mon_dump+0x113>
		int i;
		for(i=0; i<len; i++) {
f0100bff:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100c03:	0f 84 a5 00 00 00    	je     f0100cae <mon_dump+0x113>
f0100c09:	89 df                	mov    %ebx,%edi
f0100c0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c10:	be 00 00 00 00       	mov    $0x0,%esi
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100c15:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100c18:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100c1b:	a8 03                	test   $0x3,%al
f0100c1d:	75 10                	jne    f0100c2f <mon_dump+0x94>
				cprintf("Virtual Address 0x%08x: ", addr + i*4);
f0100c1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c23:	c7 04 24 b4 5b 10 f0 	movl   $0xf0105bb4,(%esp)
f0100c2a:	e8 3b 32 00 00       	call   f0103e6a <cprintf>

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
f0100c2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c32:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c36:	89 f8                	mov    %edi,%eax
f0100c38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
				cprintf("Virtual Address 0x%08x: ", addr + i*4);

			unsigned int _pte;
			struct PageInfo *pageofva = page_lookup(kern_pgdir, 
f0100c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c41:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0100c46:	89 04 24             	mov    %eax,(%esp)
f0100c49:	e8 49 0b 00 00       	call   f0101797 <page_lookup>
				(void *)ROUNDDOWN(addr + i*4, PGSIZE), (pte_t **)(&_pte));
			if(_pte && (*(pte_t *)_pte&PTE_P))
f0100c4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c51:	85 c0                	test   %eax,%eax
f0100c53:	74 19                	je     f0100c6e <mon_dump+0xd3>
f0100c55:	f6 00 01             	testb  $0x1,(%eax)
f0100c58:	74 14                	je     f0100c6e <mon_dump+0xd3>
				cprintf("0x%08x ", *(uint32_t *)(addr + i*4));
f0100c5a:	8b 07                	mov    (%edi),%eax
f0100c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c60:	c7 04 24 cd 5b 10 f0 	movl   $0xf0105bcd,(%esp)
f0100c67:	e8 fe 31 00 00       	call   f0103e6a <cprintf>
f0100c6c:	eb 0c                	jmp    f0100c7a <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100c6e:	c7 04 24 d5 5b 10 f0 	movl   $0xf0105bd5,(%esp)
f0100c75:	e8 f0 31 00 00       	call   f0103e6a <cprintf>
			if(i % 4 == 3)
f0100c7a:	89 f0                	mov    %esi,%eax
f0100c7c:	c1 f8 1f             	sar    $0x1f,%eax
f0100c7f:	c1 e8 1e             	shr    $0x1e,%eax
f0100c82:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100c85:	83 e2 03             	and    $0x3,%edx
f0100c88:	29 c2                	sub    %eax,%edx
f0100c8a:	83 fa 03             	cmp    $0x3,%edx
f0100c8d:	75 0c                	jne    f0100c9b <mon_dump+0x100>
				cprintf("\n");
f0100c8f:	c7 04 24 24 6e 10 f0 	movl   $0xf0106e24,(%esp)
f0100c96:	e8 cf 31 00 00       	call   f0103e6a <cprintf>
	unsigned int addr = strtol(argv[2], NULL, 16);
	unsigned int len = strtol(argv[3], NULL, 16);

	if(argv[1][1] == 'v') {
		int i;
		for(i=0; i<len; i++) {
f0100c9b:	83 c6 01             	add    $0x1,%esi
f0100c9e:	89 f0                	mov    %esi,%eax
f0100ca0:	83 c7 04             	add    $0x4,%edi
f0100ca3:	39 de                	cmp    %ebx,%esi
f0100ca5:	0f 85 70 ff ff ff    	jne    f0100c1b <mon_dump+0x80>
f0100cab:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100cae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cb1:	8b 50 04             	mov    0x4(%eax),%edx
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100cb4:	b8 00 00 00 00       	mov    $0x0,%eax
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
f0100cb9:	80 7a 01 70          	cmpb   $0x70,0x1(%edx)
f0100cbd:	0f 85 e1 01 00 00    	jne    f0100ea4 <mon_dump+0x309>
		int i;
		for(i=0; i<len; i++) {
f0100cc3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100cc7:	0f 84 d2 01 00 00    	je     f0100e9f <mon_dump+0x304>
f0100ccd:	be 00 00 00 00       	mov    $0x0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100cd2:	bf 00 30 11 f0       	mov    $0xf0113000,%edi
		num, perm);

	return 0;
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
f0100cd7:	89 fa                	mov    %edi,%edx
f0100cd9:	f7 da                	neg    %edx
f0100cdb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
			if(i % 4 == 0)
f0100cde:	a8 03                	test   $0x3,%al
f0100ce0:	75 10                	jne    f0100cf2 <mon_dump+0x157>
				cprintf("Physical Address 0x%08x: ", addr + i*4);
f0100ce2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ce6:	c7 04 24 db 5b 10 f0 	movl   $0xf0105bdb,(%esp)
f0100ced:	e8 78 31 00 00       	call   f0103e6a <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100cf2:	a1 6c 0e 18 f0       	mov    0xf0180e6c,%eax
f0100cf7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100cfc:	77 20                	ja     f0100d1e <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d02:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0100d09:	f0 
f0100d0a:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100d11:	00 
f0100d12:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f0100d19:	e8 a0 f3 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d1e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100d24:	39 d3                	cmp    %edx,%ebx
f0100d26:	0f 82 83 00 00 00    	jb     f0100daf <mon_dump+0x214>
f0100d2c:	8d 90 00 00 40 00    	lea    0x400000(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d32:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100d38:	77 20                	ja     f0100d5a <mon_dump+0x1bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d3a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d3e:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0100d45:	f0 
f0100d46:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100d4d:	00 
f0100d4e:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f0100d55:	e8 64 f3 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d5a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100d60:	39 d3                	cmp    %edx,%ebx
f0100d62:	73 4b                	jae    f0100daf <mon_dump+0x214>
				cprintf("0x%08x ", *(uint32_t *)(_addr - PADDR((void *)pages + UPAGES)));
f0100d64:	2d 00 00 00 11       	sub    $0x11000000,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d69:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d6e:	77 20                	ja     f0100d90 <mon_dump+0x1f5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d70:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d74:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0100d7b:	f0 
f0100d7c:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100d83:	00 
f0100d84:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f0100d8b:	e8 2e f3 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d90:	89 da                	mov    %ebx,%edx
f0100d92:	29 c2                	sub    %eax,%edx
f0100d94:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d9e:	c7 04 24 cd 5b 10 f0 	movl   $0xf0105bcd,(%esp)
f0100da5:	e8 c0 30 00 00       	call   f0103e6a <cprintf>
f0100daa:	e9 b0 00 00 00       	jmp    f0100e5f <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100daf:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100db5:	77 24                	ja     f0100ddb <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100db7:	c7 44 24 0c 00 30 11 	movl   $0xf0113000,0xc(%esp)
f0100dbe:	f0 
f0100dbf:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0100dc6:	f0 
f0100dc7:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100dce:	00 
f0100dcf:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f0100dd6:	e8 e3 f2 ff ff       	call   f01000be <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100ddb:	81 fb 00 30 11 00    	cmp    $0x113000,%ebx
f0100de1:	72 50                	jb     f0100e33 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100de3:	b8 00 b0 11 f0       	mov    $0xf011b000,%eax
f0100de8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ded:	77 20                	ja     f0100e0f <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100def:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100df3:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0100dfa:	f0 
f0100dfb:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100e02:	00 
f0100e03:	c7 04 24 f5 5b 10 f0 	movl   $0xf0105bf5,(%esp)
f0100e0a:	e8 af f2 ff ff       	call   f01000be <_panic>
f0100e0f:	81 fb 00 b0 11 00    	cmp    $0x11b000,%ebx
f0100e15:	73 1c                	jae    f0100e33 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100e17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100e1a:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100e21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e25:	c7 04 24 cd 5b 10 f0 	movl   $0xf0105bcd,(%esp)
f0100e2c:	e8 39 30 00 00       	call   f0103e6a <cprintf>
f0100e31:	eb 2c                	jmp    f0100e5f <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100e33:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100e39:	77 18                	ja     f0100e53 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100e3b:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100e41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e45:	c7 04 24 cd 5b 10 f0 	movl   $0xf0105bcd,(%esp)
f0100e4c:	e8 19 30 00 00       	call   f0103e6a <cprintf>
f0100e51:	eb 0c                	jmp    f0100e5f <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100e53:	c7 04 24 d5 5b 10 f0 	movl   $0xf0105bd5,(%esp)
f0100e5a:	e8 0b 30 00 00       	call   f0103e6a <cprintf>
			if(i % 4 == 3)
f0100e5f:	89 f0                	mov    %esi,%eax
f0100e61:	c1 f8 1f             	sar    $0x1f,%eax
f0100e64:	c1 e8 1e             	shr    $0x1e,%eax
f0100e67:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0100e6a:	83 e2 03             	and    $0x3,%edx
f0100e6d:	29 c2                	sub    %eax,%edx
f0100e6f:	83 fa 03             	cmp    $0x3,%edx
f0100e72:	75 0c                	jne    f0100e80 <mon_dump+0x2e5>
				cprintf("\n");
f0100e74:	c7 04 24 24 6e 10 f0 	movl   $0xf0106e24,(%esp)
f0100e7b:	e8 ea 2f 00 00       	call   f0103e6a <cprintf>
				cprintf("\n");
		}
	}
	if(argv[1][1] == 'p') {
		int i;
		for(i=0; i<len; i++) {
f0100e80:	83 c6 01             	add    $0x1,%esi
f0100e83:	89 f0                	mov    %esi,%eax
f0100e85:	83 c3 04             	add    $0x4,%ebx
f0100e88:	3b 75 d0             	cmp    -0x30(%ebp),%esi
f0100e8b:	0f 85 4d fe ff ff    	jne    f0100cde <mon_dump+0x143>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e91:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e96:	eb 0c                	jmp    f0100ea4 <mon_dump+0x309>
}

int mon_dump(int argc, char **argv, struct Trapframe *tf) {
	// instruction format: dump [-option] [address] [length]
	if(argc != 4)
		return -1;
f0100e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e9d:	eb 05                	jmp    f0100ea4 <mon_dump+0x309>
				cprintf("---- ");
			if(i % 4 == 3)
				cprintf("\n");
		}
	}
	return 0;
f0100e9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ea4:	83 c4 3c             	add    $0x3c,%esp
f0100ea7:	5b                   	pop    %ebx
f0100ea8:	5e                   	pop    %esi
f0100ea9:	5f                   	pop    %edi
f0100eaa:	5d                   	pop    %ebp
f0100eab:	c3                   	ret    

f0100eac <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100eac:	55                   	push   %ebp
f0100ead:	89 e5                	mov    %esp,%ebp
f0100eaf:	57                   	push   %edi
f0100eb0:	56                   	push   %esi
f0100eb1:	53                   	push   %ebx
f0100eb2:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;


	cprintf("Welcome to the JOS kernel monitor!\n");
f0100eb5:	c7 04 24 34 5e 10 f0 	movl   $0xf0105e34,(%esp)
f0100ebc:	e8 a9 2f 00 00       	call   f0103e6a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ec1:	c7 04 24 58 5e 10 f0 	movl   $0xf0105e58,(%esp)
f0100ec8:	e8 9d 2f 00 00       	call   f0103e6a <cprintf>

	if (tf != NULL)
f0100ecd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ed1:	74 0b                	je     f0100ede <monitor+0x32>
		print_trapframe(tf);
f0100ed3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed6:	89 04 24             	mov    %eax,(%esp)
f0100ed9:	e8 77 31 00 00       	call   f0104055 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f0100ede:	c7 04 24 80 5e 10 f0 	movl   $0xf0105e80,(%esp)
f0100ee5:	e8 80 2f 00 00       	call   f0103e6a <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f0100eea:	c7 04 24 b4 5e 10 f0 	movl   $0xf0105eb4,(%esp)
f0100ef1:	e8 74 2f 00 00       	call   f0103e6a <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f0100ef6:	c7 04 24 04 5c 10 f0 	movl   $0xf0105c04,(%esp)
f0100efd:	e8 be 41 00 00       	call   f01050c0 <readline>
f0100f02:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100f04:	85 c0                	test   %eax,%eax
f0100f06:	74 ee                	je     f0100ef6 <monitor+0x4a>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100f08:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100f0f:	be 00 00 00 00       	mov    $0x0,%esi
f0100f14:	eb 06                	jmp    f0100f1c <monitor+0x70>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100f16:	c6 03 00             	movb   $0x0,(%ebx)
f0100f19:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100f1c:	0f b6 03             	movzbl (%ebx),%eax
f0100f1f:	84 c0                	test   %al,%al
f0100f21:	74 6a                	je     f0100f8d <monitor+0xe1>
f0100f23:	0f be c0             	movsbl %al,%eax
f0100f26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f2a:	c7 04 24 08 5c 10 f0 	movl   $0xf0105c08,(%esp)
f0100f31:	e8 e0 43 00 00       	call   f0105316 <strchr>
f0100f36:	85 c0                	test   %eax,%eax
f0100f38:	75 dc                	jne    f0100f16 <monitor+0x6a>
			*buf++ = 0;
		if (*buf == 0)
f0100f3a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100f3d:	74 4e                	je     f0100f8d <monitor+0xe1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100f3f:	83 fe 0f             	cmp    $0xf,%esi
f0100f42:	75 16                	jne    f0100f5a <monitor+0xae>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100f44:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100f4b:	00 
f0100f4c:	c7 04 24 0d 5c 10 f0 	movl   $0xf0105c0d,(%esp)
f0100f53:	e8 12 2f 00 00       	call   f0103e6a <cprintf>
f0100f58:	eb 9c                	jmp    f0100ef6 <monitor+0x4a>
			return 0;
		}
		argv[argc++] = buf;
f0100f5a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100f5e:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f61:	0f b6 03             	movzbl (%ebx),%eax
f0100f64:	84 c0                	test   %al,%al
f0100f66:	75 0c                	jne    f0100f74 <monitor+0xc8>
f0100f68:	eb b2                	jmp    f0100f1c <monitor+0x70>
			buf++;
f0100f6a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f6d:	0f b6 03             	movzbl (%ebx),%eax
f0100f70:	84 c0                	test   %al,%al
f0100f72:	74 a8                	je     f0100f1c <monitor+0x70>
f0100f74:	0f be c0             	movsbl %al,%eax
f0100f77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7b:	c7 04 24 08 5c 10 f0 	movl   $0xf0105c08,(%esp)
f0100f82:	e8 8f 43 00 00       	call   f0105316 <strchr>
f0100f87:	85 c0                	test   %eax,%eax
f0100f89:	74 df                	je     f0100f6a <monitor+0xbe>
f0100f8b:	eb 8f                	jmp    f0100f1c <monitor+0x70>
			buf++;
	}
	argv[argc] = 0;
f0100f8d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100f94:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100f95:	85 f6                	test   %esi,%esi
f0100f97:	0f 84 59 ff ff ff    	je     f0100ef6 <monitor+0x4a>
f0100f9d:	bb 40 60 10 f0       	mov    $0xf0106040,%ebx
f0100fa2:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100fa7:	8b 03                	mov    (%ebx),%eax
f0100fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fad:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100fb0:	89 04 24             	mov    %eax,(%esp)
f0100fb3:	e8 e3 42 00 00       	call   f010529b <strcmp>
f0100fb8:	85 c0                	test   %eax,%eax
f0100fba:	75 24                	jne    f0100fe0 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f0100fbc:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100fbf:	8b 55 08             	mov    0x8(%ebp),%edx
f0100fc2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100fc6:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100fc9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fcd:	89 34 24             	mov    %esi,(%esp)
f0100fd0:	ff 14 85 48 60 10 f0 	call   *-0xfef9fb8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100fd7:	85 c0                	test   %eax,%eax
f0100fd9:	78 28                	js     f0101003 <monitor+0x157>
f0100fdb:	e9 16 ff ff ff       	jmp    f0100ef6 <monitor+0x4a>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100fe0:	83 c7 01             	add    $0x1,%edi
f0100fe3:	83 c3 0c             	add    $0xc,%ebx
f0100fe6:	83 ff 06             	cmp    $0x6,%edi
f0100fe9:	75 bc                	jne    f0100fa7 <monitor+0xfb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100feb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100fee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ff2:	c7 04 24 2a 5c 10 f0 	movl   $0xf0105c2a,(%esp)
f0100ff9:	e8 6c 2e 00 00       	call   f0103e6a <cprintf>
f0100ffe:	e9 f3 fe ff ff       	jmp    f0100ef6 <monitor+0x4a>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0101003:	83 c4 5c             	add    $0x5c,%esp
f0101006:	5b                   	pop    %ebx
f0101007:	5e                   	pop    %esi
f0101008:	5f                   	pop    %edi
f0101009:	5d                   	pop    %ebp
f010100a:	c3                   	ret    
	...

f010100c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010100c:	55                   	push   %ebp
f010100d:	89 e5                	mov    %esp,%ebp
f010100f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101012:	89 d1                	mov    %edx,%ecx
f0101014:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0101017:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f010101a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010101f:	f6 c1 01             	test   $0x1,%cl
f0101022:	74 57                	je     f010107b <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101024:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010102a:	89 c8                	mov    %ecx,%eax
f010102c:	c1 e8 0c             	shr    $0xc,%eax
f010102f:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f0101035:	72 20                	jb     f0101057 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101037:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010103b:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0101042:	f0 
f0101043:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f010104a:	00 
f010104b:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101052:	e8 67 f0 ff ff       	call   f01000be <_panic>
	//cprintf("**%x\n", p);
	if (!(p[PTX(va)] & PTE_P))
f0101057:	c1 ea 0c             	shr    $0xc,%edx
f010105a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101060:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0101067:	89 c2                	mov    %eax,%edx
f0101069:	83 e2 01             	and    $0x1,%edx
		return ~0;
	//cprintf("**%x\n\n", p[PTX(va)]);
	return PTE_ADDR(p[PTX(va)]);
f010106c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101071:	85 d2                	test   %edx,%edx
f0101073:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0101078:	0f 44 c2             	cmove  %edx,%eax
}
f010107b:	c9                   	leave  
f010107c:	c3                   	ret    

f010107d <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010107d:	55                   	push   %ebp
f010107e:	89 e5                	mov    %esp,%ebp
f0101080:	83 ec 18             	sub    $0x18,%esp
f0101083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101086:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101089:	83 3d bc 01 18 f0 00 	cmpl   $0x0,0xf01801bc
f0101090:	75 11                	jne    f01010a3 <boot_alloc+0x26>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101092:	ba 6f 1e 18 f0       	mov    $0xf0181e6f,%edx
f0101097:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010109d:	89 15 bc 01 18 f0    	mov    %edx,0xf01801bc
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f01010a3:	83 3d 00 d3 11 f0 ff 	cmpl   $0xffffffff,0xf011d300
f01010aa:	75 0c                	jne    f01010b8 <boot_alloc+0x3b>
		npages_left = npages;
f01010ac:	8b 15 64 0e 18 f0    	mov    0xf0180e64,%edx
f01010b2:	89 15 00 d3 11 f0    	mov    %edx,0xf011d300
		panic("The size of space requested is below 0!\n");
		return NULL;
	}
	// if n==0, returns the address of the next free page without allocating
	// anything.
	if (n == 0) {
f01010b8:	85 c0                	test   %eax,%eax
f01010ba:	75 2c                	jne    f01010e8 <boot_alloc+0x6b>
// !- Whether I should check here -!
		if(npages_left < 1) {
f01010bc:	83 3d 00 d3 11 f0 00 	cmpl   $0x0,0xf011d300
f01010c3:	75 1c                	jne    f01010e1 <boot_alloc+0x64>
			panic("Out of memory!\n");
f01010c5:	c7 44 24 08 8d 68 10 	movl   $0xf010688d,0x8(%esp)
f01010cc:	f0 
f01010cd:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f01010d4:	00 
f01010d5:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01010dc:	e8 dd ef ff ff       	call   f01000be <_panic>
		}
		result = nextfree;
f01010e1:	a1 bc 01 18 f0       	mov    0xf01801bc,%eax
f01010e6:	eb 5c                	jmp    f0101144 <boot_alloc+0xc7>
	}
	// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
	// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
	else if (n > 0) {
		size_t srequest = (size_t)ROUNDUP((char *)n, PGSIZE);
f01010e8:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
f01010ee:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		cprintf("Request %u\n", srequest/PGSIZE);
f01010f4:	89 f3                	mov    %esi,%ebx
f01010f6:	c1 eb 0c             	shr    $0xc,%ebx
f01010f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010fd:	c7 04 24 9d 68 10 f0 	movl   $0xf010689d,(%esp)
f0101104:	e8 61 2d 00 00       	call   f0103e6a <cprintf>

		if(npages_left < srequest/PGSIZE) {
f0101109:	8b 15 00 d3 11 f0    	mov    0xf011d300,%edx
f010110f:	39 d3                	cmp    %edx,%ebx
f0101111:	76 1c                	jbe    f010112f <boot_alloc+0xb2>
			panic("Out of memory!\n");
f0101113:	c7 44 24 08 8d 68 10 	movl   $0xf010688d,0x8(%esp)
f010111a:	f0 
f010111b:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
f0101122:	00 
f0101123:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010112a:	e8 8f ef ff ff       	call   f01000be <_panic>
		}
		result = nextfree;
f010112f:	a1 bc 01 18 f0       	mov    0xf01801bc,%eax
		nextfree += srequest;
f0101134:	01 c6                	add    %eax,%esi
f0101136:	89 35 bc 01 18 f0    	mov    %esi,0xf01801bc
		npages_left -= srequest/PGSIZE;
f010113c:	29 da                	sub    %ebx,%edx
f010113e:	89 15 00 d3 11 f0    	mov    %edx,0xf011d300

	// Make sure nextfree is kept aligned to a multiple of PGSIZE;
	//nextfree = ROUNDUP((char *) nextfree, PGSIZE);
	return result;
	//******************************My code ends***********************************//
}
f0101144:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101147:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010114a:	89 ec                	mov    %ebp,%esp
f010114c:	5d                   	pop    %ebp
f010114d:	c3                   	ret    

f010114e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010114e:	55                   	push   %ebp
f010114f:	89 e5                	mov    %esp,%ebp
f0101151:	83 ec 18             	sub    $0x18,%esp
f0101154:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101157:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010115a:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010115c:	89 04 24             	mov    %eax,(%esp)
f010115f:	e8 98 2c 00 00       	call   f0103dfc <mc146818_read>
f0101164:	89 c6                	mov    %eax,%esi
f0101166:	83 c3 01             	add    $0x1,%ebx
f0101169:	89 1c 24             	mov    %ebx,(%esp)
f010116c:	e8 8b 2c 00 00       	call   f0103dfc <mc146818_read>
f0101171:	c1 e0 08             	shl    $0x8,%eax
f0101174:	09 f0                	or     %esi,%eax
}
f0101176:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101179:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010117c:	89 ec                	mov    %ebp,%esp
f010117e:	5d                   	pop    %ebp
f010117f:	c3                   	ret    

f0101180 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101180:	55                   	push   %ebp
f0101181:	89 e5                	mov    %esp,%ebp
f0101183:	57                   	push   %edi
f0101184:	56                   	push   %esi
f0101185:	53                   	push   %ebx
f0101186:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101189:	3c 01                	cmp    $0x1,%al
f010118b:	19 f6                	sbb    %esi,%esi
f010118d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101193:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101196:	8b 1d c0 01 18 f0    	mov    0xf01801c0,%ebx
f010119c:	85 db                	test   %ebx,%ebx
f010119e:	75 1c                	jne    f01011bc <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f01011a0:	c7 44 24 08 ac 60 10 	movl   $0xf01060ac,0x8(%esp)
f01011a7:	f0 
f01011a8:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01011af:	00 
f01011b0:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01011b7:	e8 02 ef ff ff       	call   f01000be <_panic>

	if (only_low_memory) {
f01011bc:	84 c0                	test   %al,%al
f01011be:	74 50                	je     f0101210 <check_page_free_list+0x90>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01011c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01011c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01011c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011cc:	89 d8                	mov    %ebx,%eax
f01011ce:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f01011d4:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01011d7:	c1 e8 16             	shr    $0x16,%eax
f01011da:	39 c6                	cmp    %eax,%esi
f01011dc:	0f 96 c0             	setbe  %al
f01011df:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01011e2:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01011e6:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01011e8:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011ec:	8b 1b                	mov    (%ebx),%ebx
f01011ee:	85 db                	test   %ebx,%ebx
f01011f0:	75 da                	jne    f01011cc <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01011f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01011f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101201:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101203:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101206:	89 1d c0 01 18 f0    	mov    %ebx,0xf01801c0
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010120c:	85 db                	test   %ebx,%ebx
f010120e:	74 67                	je     f0101277 <check_page_free_list+0xf7>
f0101210:	89 d8                	mov    %ebx,%eax
f0101212:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f0101218:	c1 f8 03             	sar    $0x3,%eax
f010121b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010121e:	89 c2                	mov    %eax,%edx
f0101220:	c1 ea 16             	shr    $0x16,%edx
f0101223:	39 d6                	cmp    %edx,%esi
f0101225:	76 4a                	jbe    f0101271 <check_page_free_list+0xf1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101227:	89 c2                	mov    %eax,%edx
f0101229:	c1 ea 0c             	shr    $0xc,%edx
f010122c:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f0101232:	72 20                	jb     f0101254 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101234:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101238:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f010123f:	f0 
f0101240:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101247:	00 
f0101248:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f010124f:	e8 6a ee ff ff       	call   f01000be <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101254:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010125b:	00 
f010125c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101263:	00 
	return (void *)(pa + KERNBASE);
f0101264:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101269:	89 04 24             	mov    %eax,(%esp)
f010126c:	e8 00 41 00 00       	call   f0105371 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101271:	8b 1b                	mov    (%ebx),%ebx
f0101273:	85 db                	test   %ebx,%ebx
f0101275:	75 99                	jne    f0101210 <check_page_free_list+0x90>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101277:	b8 00 00 00 00       	mov    $0x0,%eax
f010127c:	e8 fc fd ff ff       	call   f010107d <boot_alloc>
f0101281:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101284:	8b 15 c0 01 18 f0    	mov    0xf01801c0,%edx
f010128a:	85 d2                	test   %edx,%edx
f010128c:	0f 84 f6 01 00 00    	je     f0101488 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101292:	8b 1d 6c 0e 18 f0    	mov    0xf0180e6c,%ebx
f0101298:	39 da                	cmp    %ebx,%edx
f010129a:	72 4d                	jb     f01012e9 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f010129c:	a1 64 0e 18 f0       	mov    0xf0180e64,%eax
f01012a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01012a4:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f01012a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012aa:	39 c2                	cmp    %eax,%edx
f01012ac:	73 64                	jae    f0101312 <check_page_free_list+0x192>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012ae:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01012b1:	89 d0                	mov    %edx,%eax
f01012b3:	29 d8                	sub    %ebx,%eax
f01012b5:	a8 07                	test   $0x7,%al
f01012b7:	0f 85 82 00 00 00    	jne    f010133f <check_page_free_list+0x1bf>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012bd:	c1 f8 03             	sar    $0x3,%eax
f01012c0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01012c3:	85 c0                	test   %eax,%eax
f01012c5:	0f 84 a2 00 00 00    	je     f010136d <check_page_free_list+0x1ed>
		assert(page2pa(pp) != IOPHYSMEM);
f01012cb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01012d0:	0f 84 c2 00 00 00    	je     f0101398 <check_page_free_list+0x218>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01012d6:	be 00 00 00 00       	mov    $0x0,%esi
f01012db:	bf 00 00 00 00       	mov    $0x0,%edi
f01012e0:	e9 d7 00 00 00       	jmp    f01013bc <check_page_free_list+0x23c>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012e5:	39 da                	cmp    %ebx,%edx
f01012e7:	73 24                	jae    f010130d <check_page_free_list+0x18d>
f01012e9:	c7 44 24 0c b7 68 10 	movl   $0xf01068b7,0xc(%esp)
f01012f0:	f0 
f01012f1:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01012f8:	f0 
f01012f9:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101300:	00 
f0101301:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101308:	e8 b1 ed ff ff       	call   f01000be <_panic>
		assert(pp < pages + npages);
f010130d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101310:	72 24                	jb     f0101336 <check_page_free_list+0x1b6>
f0101312:	c7 44 24 0c d8 68 10 	movl   $0xf01068d8,0xc(%esp)
f0101319:	f0 
f010131a:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101321:	f0 
f0101322:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0101329:	00 
f010132a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101331:	e8 88 ed ff ff       	call   f01000be <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101336:	89 d0                	mov    %edx,%eax
f0101338:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010133b:	a8 07                	test   $0x7,%al
f010133d:	74 24                	je     f0101363 <check_page_free_list+0x1e3>
f010133f:	c7 44 24 0c d0 60 10 	movl   $0xf01060d0,0xc(%esp)
f0101346:	f0 
f0101347:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010134e:	f0 
f010134f:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f0101356:	00 
f0101357:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010135e:	e8 5b ed ff ff       	call   f01000be <_panic>
f0101363:	c1 f8 03             	sar    $0x3,%eax
f0101366:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101369:	85 c0                	test   %eax,%eax
f010136b:	75 24                	jne    f0101391 <check_page_free_list+0x211>
f010136d:	c7 44 24 0c ec 68 10 	movl   $0xf01068ec,0xc(%esp)
f0101374:	f0 
f0101375:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010137c:	f0 
f010137d:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0101384:	00 
f0101385:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010138c:	e8 2d ed ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101391:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101396:	75 24                	jne    f01013bc <check_page_free_list+0x23c>
f0101398:	c7 44 24 0c fd 68 10 	movl   $0xf01068fd,0xc(%esp)
f010139f:	f0 
f01013a0:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01013a7:	f0 
f01013a8:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f01013af:	00 
f01013b0:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01013b7:	e8 02 ed ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013bc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01013c1:	75 24                	jne    f01013e7 <check_page_free_list+0x267>
f01013c3:	c7 44 24 0c 04 61 10 	movl   $0xf0106104,0xc(%esp)
f01013ca:	f0 
f01013cb:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01013d2:	f0 
f01013d3:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f01013da:	00 
f01013db:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01013e2:	e8 d7 ec ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01013e7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01013ec:	75 24                	jne    f0101412 <check_page_free_list+0x292>
f01013ee:	c7 44 24 0c 16 69 10 	movl   $0xf0106916,0xc(%esp)
f01013f5:	f0 
f01013f6:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0101405:	00 
f0101406:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010140d:	e8 ac ec ff ff       	call   f01000be <_panic>
f0101412:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101414:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101419:	76 57                	jbe    f0101472 <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010141b:	c1 e8 0c             	shr    $0xc,%eax
f010141e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101421:	77 20                	ja     f0101443 <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101423:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101427:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f010142e:	f0 
f010142f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101436:	00 
f0101437:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f010143e:	e8 7b ec ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0101443:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101449:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010144c:	76 29                	jbe    f0101477 <check_page_free_list+0x2f7>
f010144e:	c7 44 24 0c 28 61 10 	movl   $0xf0106128,0xc(%esp)
f0101455:	f0 
f0101456:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010145d:	f0 
f010145e:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0101465:	00 
f0101466:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010146d:	e8 4c ec ff ff       	call   f01000be <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101472:	83 c7 01             	add    $0x1,%edi
f0101475:	eb 03                	jmp    f010147a <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0101477:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010147a:	8b 12                	mov    (%edx),%edx
f010147c:	85 d2                	test   %edx,%edx
f010147e:	0f 85 61 fe ff ff    	jne    f01012e5 <check_page_free_list+0x165>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101484:	85 ff                	test   %edi,%edi
f0101486:	7f 24                	jg     f01014ac <check_page_free_list+0x32c>
f0101488:	c7 44 24 0c 30 69 10 	movl   $0xf0106930,0xc(%esp)
f010148f:	f0 
f0101490:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101497:	f0 
f0101498:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f010149f:	00 
f01014a0:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01014a7:	e8 12 ec ff ff       	call   f01000be <_panic>
	assert(nfree_extmem > 0);
f01014ac:	85 f6                	test   %esi,%esi
f01014ae:	7f 24                	jg     f01014d4 <check_page_free_list+0x354>
f01014b0:	c7 44 24 0c 42 69 10 	movl   $0xf0106942,0xc(%esp)
f01014b7:	f0 
f01014b8:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01014bf:	f0 
f01014c0:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01014c7:	00 
f01014c8:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01014cf:	e8 ea eb ff ff       	call   f01000be <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01014d4:	c7 04 24 70 61 10 f0 	movl   $0xf0106170,(%esp)
f01014db:	e8 8a 29 00 00       	call   f0103e6a <cprintf>
}
f01014e0:	83 c4 3c             	add    $0x3c,%esp
f01014e3:	5b                   	pop    %ebx
f01014e4:	5e                   	pop    %esi
f01014e5:	5f                   	pop    %edi
f01014e6:	5d                   	pop    %ebp
f01014e7:	c3                   	ret    

f01014e8 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01014e8:	55                   	push   %ebp
f01014e9:	89 e5                	mov    %esp,%ebp
f01014eb:	57                   	push   %edi
f01014ec:	56                   	push   %esi
f01014ed:	53                   	push   %ebx
f01014ee:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f01014f1:	83 3d 64 0e 18 f0 00 	cmpl   $0x0,0xf0180e64
f01014f8:	0f 85 98 00 00 00    	jne    f0101596 <page_init+0xae>
f01014fe:	e9 a5 00 00 00       	jmp    f01015a8 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f0101503:	a1 6c 0e 18 f0       	mov    0xf0180e6c,%eax
f0101508:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
f010150f:	8d 3c 30             	lea    (%eax,%esi,1),%edi
f0101512:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

		// 1) Mark physical page 0 as in use.
		//    This way we preserve the real-mode IDT and BIOS structures
		//    in case we ever need them.  (Currently we don't, but...)
		if(i == 0) {
f0101518:	85 db                	test   %ebx,%ebx
f010151a:	74 69                	je     f0101585 <page_init+0x9d>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010151c:	29 c7                	sub    %eax,%edi
f010151e:	c1 ff 03             	sar    $0x3,%edi
f0101521:	c1 e7 0c             	shl    $0xc,%edi
		// 4) Then extended memory [EXTPHYSMEM, ...).
		// extended memory: 0x100000~
		//   0x100000~0x115000 is allocated to kernel(0x115000 is the end of .bss segment)
		//   0x115000~0x116000 is for kern_pgdir.
		//   0x116000~... is for pages (amount is 33)
		if(page2pa(&pages[i]) >= IOPHYSMEM
f0101524:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f010152a:	76 3f                	jbe    f010156b <page_init+0x83>
			&& page2pa(&pages[i]) < ROUNDUP(PADDR(boot_alloc(0)), PGSIZE)) {	
f010152c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101531:	e8 47 fb ff ff       	call   f010107d <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101536:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010153b:	77 20                	ja     f010155d <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010153d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101541:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0101548:	f0 
f0101549:	c7 44 24 04 6d 01 00 	movl   $0x16d,0x4(%esp)
f0101550:	00 
f0101551:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101558:	e8 61 eb ff ff       	call   f01000be <_panic>
f010155d:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0101562:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101567:	39 f8                	cmp    %edi,%eax
f0101569:	77 1a                	ja     f0101585 <page_init+0x9d>
			continue;	
		}
		
		// others is free
		pages[i].pp_link = page_free_list;
f010156b:	8b 15 c0 01 18 f0    	mov    0xf01801c0,%edx
f0101571:	a1 6c 0e 18 f0       	mov    0xf0180e6c,%eax
f0101576:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f0101579:	03 35 6c 0e 18 f0    	add    0xf0180e6c,%esi
f010157f:	89 35 c0 01 18 f0    	mov    %esi,0xf01801c0
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101585:	83 c3 01             	add    $0x1,%ebx
f0101588:	39 1d 64 0e 18 f0    	cmp    %ebx,0xf0180e64
f010158e:	0f 87 6f ff ff ff    	ja     f0101503 <page_init+0x1b>
f0101594:	eb 12                	jmp    f01015a8 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f0101596:	a1 6c 0e 18 f0       	mov    0xf0180e6c,%eax
f010159b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f01015a1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015a6:	eb dd                	jmp    f0101585 <page_init+0x9d>
		
		// others is free
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01015a8:	83 c4 1c             	add    $0x1c,%esp
f01015ab:	5b                   	pop    %ebx
f01015ac:	5e                   	pop    %esi
f01015ad:	5f                   	pop    %edi
f01015ae:	5d                   	pop    %ebp
f01015af:	c3                   	ret    

f01015b0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01015b0:	55                   	push   %ebp
f01015b1:	89 e5                	mov    %esp,%ebp
f01015b3:	53                   	push   %ebx
f01015b4:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in

	// If (alloc_flags & ALLOC_ZERO), fills the entire
	// returned physical page with '\0' bytes.
	struct PageInfo *result = NULL;
	if(page_free_list) {
f01015b7:	8b 1d c0 01 18 f0    	mov    0xf01801c0,%ebx
f01015bd:	85 db                	test   %ebx,%ebx
f01015bf:	74 65                	je     f0101626 <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f01015c1:	8b 03                	mov    (%ebx),%eax
f01015c3:	a3 c0 01 18 f0       	mov    %eax,0xf01801c0
		
		if(alloc_flags & ALLOC_ZERO) { 
f01015c8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01015cc:	74 58                	je     f0101626 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015ce:	89 d8                	mov    %ebx,%eax
f01015d0:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015dc:	89 c2                	mov    %eax,%edx
f01015de:	c1 ea 0c             	shr    $0xc,%edx
f01015e1:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f01015e7:	72 20                	jb     f0101609 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015ed:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f01015f4:	f0 
f01015f5:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01015fc:	00 
f01015fd:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0101604:	e8 b5 ea ff ff       	call   f01000be <_panic>
			// fill in '\0'
			memset(page2kva(result), 0, PGSIZE);
f0101609:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101610:	00 
f0101611:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101618:	00 
	return (void *)(pa + KERNBASE);
f0101619:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010161e:	89 04 24             	mov    %eax,(%esp)
f0101621:	e8 4b 3d 00 00       	call   f0105371 <memset>
		}
	}
	return result;
}
f0101626:	89 d8                	mov    %ebx,%eax
f0101628:	83 c4 14             	add    $0x14,%esp
f010162b:	5b                   	pop    %ebx
f010162c:	5d                   	pop    %ebp
f010162d:	c3                   	ret    

f010162e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010162e:	55                   	push   %ebp
f010162f:	89 e5                	mov    %esp,%ebp
f0101631:	83 ec 18             	sub    $0x18,%esp
f0101634:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(!pp)
f0101637:	85 c0                	test   %eax,%eax
f0101639:	75 1c                	jne    f0101657 <page_free+0x29>
		panic("page_free: invalid page to free!\n");
f010163b:	c7 44 24 08 94 61 10 	movl   $0xf0106194,0x8(%esp)
f0101642:	f0 
f0101643:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
f010164a:	00 
f010164b:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101652:	e8 67 ea ff ff       	call   f01000be <_panic>
	pp->pp_link = page_free_list;
f0101657:	8b 15 c0 01 18 f0    	mov    0xf01801c0,%edx
f010165d:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010165f:	a3 c0 01 18 f0       	mov    %eax,0xf01801c0
}
f0101664:	c9                   	leave  
f0101665:	c3                   	ret    

f0101666 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101666:	55                   	push   %ebp
f0101667:	89 e5                	mov    %esp,%ebp
f0101669:	83 ec 18             	sub    $0x18,%esp
f010166c:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010166f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101673:	83 ea 01             	sub    $0x1,%edx
f0101676:	66 89 50 04          	mov    %dx,0x4(%eax)
f010167a:	66 85 d2             	test   %dx,%dx
f010167d:	75 08                	jne    f0101687 <page_decref+0x21>
		page_free(pp);
f010167f:	89 04 24             	mov    %eax,(%esp)
f0101682:	e8 a7 ff ff ff       	call   f010162e <page_free>
}
f0101687:	c9                   	leave  
f0101688:	c3                   	ret    

f0101689 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101689:	55                   	push   %ebp
f010168a:	89 e5                	mov    %esp,%ebp
f010168c:	56                   	push   %esi
f010168d:	53                   	push   %ebx
f010168e:	83 ec 10             	sub    $0x10,%esp
f0101691:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
f0101694:	89 f3                	mov    %esi,%ebx
f0101696:	c1 eb 16             	shr    $0x16,%ebx
	uintptr_t ptx = PTX(va);
	uintptr_t pgoff = PGOFF(va);

	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];
f0101699:	c1 e3 02             	shl    $0x2,%ebx
f010169c:	03 5d 08             	add    0x8(%ebp),%ebx

	if(((*pde) & PTE_P) == 0) {
f010169f:	f6 03 01             	testb  $0x1,(%ebx)
f01016a2:	75 2c                	jne    f01016d0 <pgdir_walk+0x47>
		if(create == 0) 
f01016a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01016a8:	74 6c                	je     f0101716 <pgdir_walk+0x8d>
			return NULL;
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
f01016aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016b1:	e8 fa fe ff ff       	call   f01015b0 <page_alloc>
			if(pgtbl == NULL)
f01016b6:	85 c0                	test   %eax,%eax
f01016b8:	74 63                	je     f010171d <pgdir_walk+0x94>
				return NULL;
			else {
				pgtbl->pp_ref ++;
f01016ba:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016bf:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f01016c5:	c1 f8 03             	sar    $0x3,%eax
f01016c8:	c1 e0 0c             	shl    $0xc,%eax
				/* store in physical address*/
				*pde = page2pa(pgtbl) | PTE_U | PTE_W | PTE_P;
f01016cb:	83 c8 07             	or     $0x7,%eax
f01016ce:	89 03                	mov    %eax,(%ebx)
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f01016d0:	8b 03                	mov    (%ebx),%eax
f01016d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016d7:	89 c2                	mov    %eax,%edx
f01016d9:	c1 ea 0c             	shr    $0xc,%edx
f01016dc:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f01016e2:	72 20                	jb     f0101704 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016e8:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f01016ef:	f0 
f01016f0:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
f01016f7:	00 
f01016f8:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01016ff:	e8 ba e9 ff ff       	call   f01000be <_panic>
{
	// Fill this function in
	
	// First, segment the vritual address to three part: PDX, PTX, PGOFF
	uintptr_t pdx = PDX(va);
	uintptr_t ptx = PTX(va);
f0101704:	c1 ee 0a             	shr    $0xa,%esi
		}
	}

	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;
f0101707:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010170d:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax

	return pte;
f0101714:	eb 0c                	jmp    f0101722 <pgdir_walk+0x99>
	// Second, check the page directory entity
	pde_t *pde = &pgdir[pdx];

	if(((*pde) & PTE_P) == 0) {
		if(create == 0) 
			return NULL;
f0101716:	b8 00 00 00 00       	mov    $0x0,%eax
f010171b:	eb 05                	jmp    f0101722 <pgdir_walk+0x99>
		else {
			// !- I assume that the page need to be zero -!
			struct PageInfo *pgtbl = page_alloc(ALLOC_ZERO);
			if(pgtbl == NULL)
				return NULL;
f010171d:	b8 00 00 00 00       	mov    $0x0,%eax
	// Third, check the page table entiry (return an address - vitual address to memory)
	pte_t *pte;
	pte = (pte_t *)KADDR(PTE_ADDR(*pde)) + ptx;

	return pte;
}
f0101722:	83 c4 10             	add    $0x10,%esp
f0101725:	5b                   	pop    %ebx
f0101726:	5e                   	pop    %esi
f0101727:	5d                   	pop    %ebp
f0101728:	c3                   	ret    

f0101729 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101729:	55                   	push   %ebp
f010172a:	89 e5                	mov    %esp,%ebp
f010172c:	57                   	push   %edi
f010172d:	56                   	push   %esi
f010172e:	53                   	push   %ebx
f010172f:	83 ec 2c             	sub    $0x2c,%esp
f0101732:	89 c7                	mov    %eax,%edi
f0101734:	8b 75 08             	mov    0x8(%ebp),%esi
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101737:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f010173d:	c1 e9 0c             	shr    $0xc,%ecx
f0101740:	85 c9                	test   %ecx,%ecx
f0101742:	74 4b                	je     f010178f <boot_map_region+0x66>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101744:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101747:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010174c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101752:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f0101755:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101758:	83 c8 01             	or     $0x1,%eax
f010175b:	89 45 dc             	mov    %eax,-0x24(%ebp)

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010175e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101765:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101766:	89 d8                	mov    %ebx,%eax
f0101768:	c1 e0 0c             	shl    $0xc,%eax

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
f010176b:	03 45 e0             	add    -0x20(%ebp),%eax
f010176e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101772:	89 3c 24             	mov    %edi,(%esp)
f0101775:	e8 0f ff ff ff       	call   f0101689 <pgdir_walk>
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
f010177a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010177d:	09 f2                	or     %esi,%edx
f010177f:	89 10                	mov    %edx,(%eax)
	uintptr_t pgoff = PGOFF(va);

	// Second, map the virtual address and physical address
	int i;
	/* Do I need to consider the align?*/
	for(i=0; i<ROUNDUP(size, PGSIZE)/PGSIZE; i++) {
f0101781:	83 c3 01             	add    $0x1,%ebx
f0101784:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010178a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010178d:	75 cf                	jne    f010175e <boot_map_region+0x35>
		pte_t *pte = pgdir_walk(pgdir, (void *)(PTE_ADDR(va)+i*PGSIZE), 1);
		*pte = (pa+i*PGSIZE) | perm | PTE_P;
	}
}
f010178f:	83 c4 2c             	add    $0x2c,%esp
f0101792:	5b                   	pop    %ebx
f0101793:	5e                   	pop    %esi
f0101794:	5f                   	pop    %edi
f0101795:	5d                   	pop    %ebp
f0101796:	c3                   	ret    

f0101797 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101797:	55                   	push   %ebp
f0101798:	89 e5                	mov    %esp,%ebp
f010179a:	53                   	push   %ebx
f010179b:	83 ec 14             	sub    $0x14,%esp
f010179e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
f01017a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01017a8:	00 
f01017a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b3:	89 04 24             	mov    %eax,(%esp)
f01017b6:	e8 ce fe ff ff       	call   f0101689 <pgdir_walk>
	struct PageInfo *pg = NULL;
	// Check if the pte_store is zero
	if(pte_store != 0)
f01017bb:	85 db                	test   %ebx,%ebx
f01017bd:	74 02                	je     f01017c1 <page_lookup+0x2a>
		*pte_store = pte;
f01017bf:	89 03                	mov    %eax,(%ebx)

	// Check if the page is mapped
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
f01017c1:	85 c0                	test   %eax,%eax
f01017c3:	74 38                	je     f01017fd <page_lookup+0x66>
f01017c5:	8b 00                	mov    (%eax),%eax
f01017c7:	a8 01                	test   $0x1,%al
f01017c9:	74 39                	je     f0101804 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017cb:	c1 e8 0c             	shr    $0xc,%eax
f01017ce:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f01017d4:	72 1c                	jb     f01017f2 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01017d6:	c7 44 24 08 b8 61 10 	movl   $0xf01061b8,0x8(%esp)
f01017dd:	f0 
f01017de:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f01017e5:	00 
f01017e6:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f01017ed:	e8 cc e8 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f01017f2:	c1 e0 03             	shl    $0x3,%eax
f01017f5:	03 05 6c 0e 18 f0    	add    0xf0180e6c,%eax
f01017fb:	eb 0c                	jmp    f0101809 <page_lookup+0x72>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte= pgdir_walk(pgdir, va, 0);
	struct PageInfo *pg = NULL;
f01017fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101802:	eb 05                	jmp    f0101809 <page_lookup+0x72>
f0101804:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte != NULL && (((*pte) & PTE_P) == 1)) {
		pg = pa2page(PTE_ADDR(*pte));
	}

	return pg;
}
f0101809:	83 c4 14             	add    $0x14,%esp
f010180c:	5b                   	pop    %ebx
f010180d:	5d                   	pop    %ebp
f010180e:	c3                   	ret    

f010180f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010180f:	55                   	push   %ebp
f0101810:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101812:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101815:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101818:	5d                   	pop    %ebp
f0101819:	c3                   	ret    

f010181a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010181a:	55                   	push   %ebp
f010181b:	89 e5                	mov    %esp,%ebp
f010181d:	83 ec 28             	sub    $0x28,%esp
f0101820:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101823:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101826:	8b 75 08             	mov    0x8(%ebp),%esi
f0101829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;

	// look up the pte for the va
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010182c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010182f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101833:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101837:	89 34 24             	mov    %esi,(%esp)
f010183a:	e8 58 ff ff ff       	call   f0101797 <page_lookup>

	if(pg != NULL) {
f010183f:	85 c0                	test   %eax,%eax
f0101841:	74 1d                	je     f0101860 <page_remove+0x46>
		// Decrease the count and free
		page_decref(pg);
f0101843:	89 04 24             	mov    %eax,(%esp)
f0101846:	e8 1b fe ff ff       	call   f0101666 <page_decref>
		// Set the pte to zero
		*pte = 0;
f010184b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010184e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		// The TLB must be invalidated if a page was formerly present at 'va'.
		tlb_invalidate(pgdir, va);
f0101854:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101858:	89 34 24             	mov    %esi,(%esp)
f010185b:	e8 af ff ff ff       	call   f010180f <tlb_invalidate>
	}
}
f0101860:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101863:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101866:	89 ec                	mov    %ebp,%esp
f0101868:	5d                   	pop    %ebp
f0101869:	c3                   	ret    

f010186a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010186a:	55                   	push   %ebp
f010186b:	89 e5                	mov    %esp,%ebp
f010186d:	83 ec 28             	sub    $0x28,%esp
f0101870:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101873:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101876:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101879:	8b 75 0c             	mov    0xc(%ebp),%esi
f010187c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
f010187f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101886:	00 
f0101887:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010188b:	8b 45 08             	mov    0x8(%ebp),%eax
f010188e:	89 04 24             	mov    %eax,(%esp)
f0101891:	e8 f3 fd ff ff       	call   f0101689 <pgdir_walk>
f0101896:	89 c3                	mov    %eax,%ebx
	if(pte == NULL) 
f0101898:	85 c0                	test   %eax,%eax
f010189a:	74 66                	je     f0101902 <page_insert+0x98>
		return -E_NO_MEM;
	// If there is already a page mapped at 'va', it should be page_remove()d.
	if(((*pte) & PTE_P) == 1) {
f010189c:	8b 00                	mov    (%eax),%eax
f010189e:	a8 01                	test   $0x1,%al
f01018a0:	74 3c                	je     f01018de <page_insert+0x74>
		//On one hand, the mapped page is pp;
		if(PTE_ADDR(*pte) == page2pa(pp)) {
f01018a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018a7:	89 f2                	mov    %esi,%edx
f01018a9:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f01018af:	c1 fa 03             	sar    $0x3,%edx
f01018b2:	c1 e2 0c             	shl    $0xc,%edx
f01018b5:	39 d0                	cmp    %edx,%eax
f01018b7:	75 16                	jne    f01018cf <page_insert+0x65>
			// The TLB must be invalidated if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f01018b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01018bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01018c0:	89 04 24             	mov    %eax,(%esp)
f01018c3:	e8 47 ff ff ff       	call   f010180f <tlb_invalidate>
			// The reference for the same page should not change(latter add one)
			pp->pp_ref --;
f01018c8:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f01018cd:	eb 0f                	jmp    f01018de <page_insert+0x74>
		}
		//On the other hand, the mapped page is not pp;
		else
			page_remove(pgdir, va);
f01018cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01018d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01018d6:	89 04 24             	mov    %eax,(%esp)
f01018d9:	e8 3c ff ff ff       	call   f010181a <page_remove>
	}

	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
f01018de:	8b 45 14             	mov    0x14(%ebp),%eax
f01018e1:	83 c8 01             	or     $0x1,%eax
f01018e4:	89 f2                	mov    %esi,%edx
f01018e6:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f01018ec:	c1 fa 03             	sar    $0x3,%edx
f01018ef:	c1 e2 0c             	shl    $0xc,%edx
f01018f2:	09 d0                	or     %edx,%eax
f01018f4:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref ++;
f01018f6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	
	return 0;
f01018fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101900:	eb 05                	jmp    f0101907 <page_insert+0x9d>
{
	// Fill this function in

	pte_t *pte= pgdir_walk(pgdir, va, 1);
	if(pte == NULL) 
		return -E_NO_MEM;
f0101902:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// pp->pp_ref should be incremented if the insertion succeeds.
	*pte = page2pa(pp) | perm | PTE_P;
	pp->pp_ref ++;
	
	return 0;
}
f0101907:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010190a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010190d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101910:	89 ec                	mov    %ebp,%esp
f0101912:	5d                   	pop    %ebp
f0101913:	c3                   	ret    

f0101914 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101914:	55                   	push   %ebp
f0101915:	89 e5                	mov    %esp,%ebp
f0101917:	57                   	push   %edi
f0101918:	56                   	push   %esi
f0101919:	53                   	push   %ebx
f010191a:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010191d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101922:	e8 27 f8 ff ff       	call   f010114e <nvram_read>
f0101927:	c1 e0 0a             	shl    $0xa,%eax
f010192a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101930:	85 c0                	test   %eax,%eax
f0101932:	0f 48 c2             	cmovs  %edx,%eax
f0101935:	c1 f8 0c             	sar    $0xc,%eax
f0101938:	a3 b8 01 18 f0       	mov    %eax,0xf01801b8
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010193d:	b8 17 00 00 00       	mov    $0x17,%eax
f0101942:	e8 07 f8 ff ff       	call   f010114e <nvram_read>
f0101947:	c1 e0 0a             	shl    $0xa,%eax
f010194a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101950:	85 c0                	test   %eax,%eax
f0101952:	0f 48 c2             	cmovs  %edx,%eax
f0101955:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101958:	85 c0                	test   %eax,%eax
f010195a:	74 0e                	je     f010196a <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010195c:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101962:	89 15 64 0e 18 f0    	mov    %edx,0xf0180e64
f0101968:	eb 0c                	jmp    f0101976 <mem_init+0x62>
	else
		npages = npages_basemem;
f010196a:	8b 15 b8 01 18 f0    	mov    0xf01801b8,%edx
f0101970:	89 15 64 0e 18 f0    	mov    %edx,0xf0180e64

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101976:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101979:	c1 e8 0a             	shr    $0xa,%eax
f010197c:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101980:	a1 b8 01 18 f0       	mov    0xf01801b8,%eax
f0101985:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101988:	c1 e8 0a             	shr    $0xa,%eax
f010198b:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f010198f:	a1 64 0e 18 f0       	mov    0xf0180e64,%eax
f0101994:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101997:	c1 e8 0a             	shr    $0xa,%eax
f010199a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010199e:	c7 04 24 d8 61 10 f0 	movl   $0xf01061d8,(%esp)
f01019a5:	e8 c0 24 00 00       	call   f0103e6a <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019aa:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019af:	e8 c9 f6 ff ff       	call   f010107d <boot_alloc>
f01019b4:	a3 68 0e 18 f0       	mov    %eax,0xf0180e68
	memset(kern_pgdir, 0, PGSIZE);
f01019b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019c0:	00 
f01019c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019c8:	00 
f01019c9:	89 04 24             	mov    %eax,(%esp)
f01019cc:	e8 a0 39 00 00       	call   f0105371 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01019d1:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01019d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01019db:	77 20                	ja     f01019fd <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01019dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019e1:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f01019e8:	f0 
f01019e9:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
f01019f0:	00 
f01019f1:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01019f8:	e8 c1 e6 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f01019fd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101a03:	83 ca 05             	or     $0x5,%edx
f0101a06:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// Request for pages to store 'struct PageInfo's
	uint32_t pagesneed = (uint32_t)(sizeof(struct PageInfo) * npages);
f0101a0c:	a1 64 0e 18 f0       	mov    0xf0180e64,%eax
f0101a11:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101a14:	e8 64 f6 ff ff       	call   f010107d <boot_alloc>
f0101a19:	a3 6c 0e 18 f0       	mov    %eax,0xf0180e6c
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f0101a1e:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101a23:	e8 55 f6 ff ff       	call   f010107d <boot_alloc>
f0101a28:	a3 cc 01 18 f0       	mov    %eax,0xf01801cc
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a2d:	e8 b6 fa ff ff       	call   f01014e8 <page_init>

	check_page_free_list(1);
f0101a32:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a37:	e8 44 f7 ff ff       	call   f0101180 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a3c:	83 3d 6c 0e 18 f0 00 	cmpl   $0x0,0xf0180e6c
f0101a43:	75 1c                	jne    f0101a61 <mem_init+0x14d>
		panic("'pages' is a null pointer!");
f0101a45:	c7 44 24 08 53 69 10 	movl   $0xf0106953,0x8(%esp)
f0101a4c:	f0 
f0101a4d:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f0101a54:	00 
f0101a55:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101a5c:	e8 5d e6 ff ff       	call   f01000be <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a61:	a1 c0 01 18 f0       	mov    0xf01801c0,%eax
f0101a66:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	74 09                	je     f0101a78 <mem_init+0x164>
		++nfree;
f0101a6f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a72:	8b 00                	mov    (%eax),%eax
f0101a74:	85 c0                	test   %eax,%eax
f0101a76:	75 f7                	jne    f0101a6f <mem_init+0x15b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a7f:	e8 2c fb ff ff       	call   f01015b0 <page_alloc>
f0101a84:	89 c6                	mov    %eax,%esi
f0101a86:	85 c0                	test   %eax,%eax
f0101a88:	75 24                	jne    f0101aae <mem_init+0x19a>
f0101a8a:	c7 44 24 0c 6e 69 10 	movl   $0xf010696e,0xc(%esp)
f0101a91:	f0 
f0101a92:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101a99:	f0 
f0101a9a:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101aa1:	00 
f0101aa2:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101aa9:	e8 10 e6 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101aae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ab5:	e8 f6 fa ff ff       	call   f01015b0 <page_alloc>
f0101aba:	89 c7                	mov    %eax,%edi
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	75 24                	jne    f0101ae4 <mem_init+0x1d0>
f0101ac0:	c7 44 24 0c 84 69 10 	movl   $0xf0106984,0xc(%esp)
f0101ac7:	f0 
f0101ac8:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101acf:	f0 
f0101ad0:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101ad7:	00 
f0101ad8:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101adf:	e8 da e5 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f0101ae4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aeb:	e8 c0 fa ff ff       	call   f01015b0 <page_alloc>
f0101af0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101af3:	85 c0                	test   %eax,%eax
f0101af5:	75 24                	jne    f0101b1b <mem_init+0x207>
f0101af7:	c7 44 24 0c 9a 69 10 	movl   $0xf010699a,0xc(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101b06:	f0 
f0101b07:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101b0e:	00 
f0101b0f:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101b16:	e8 a3 e5 ff ff       	call   f01000be <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b1b:	39 fe                	cmp    %edi,%esi
f0101b1d:	75 24                	jne    f0101b43 <mem_init+0x22f>
f0101b1f:	c7 44 24 0c b0 69 10 	movl   $0xf01069b0,0xc(%esp)
f0101b26:	f0 
f0101b27:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101b36:	00 
f0101b37:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101b3e:	e8 7b e5 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b43:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b46:	74 05                	je     f0101b4d <mem_init+0x239>
f0101b48:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b4b:	75 24                	jne    f0101b71 <mem_init+0x25d>
f0101b4d:	c7 44 24 0c 14 62 10 	movl   $0xf0106214,0xc(%esp)
f0101b54:	f0 
f0101b55:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101b5c:	f0 
f0101b5d:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101b64:	00 
f0101b65:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101b6c:	e8 4d e5 ff ff       	call   f01000be <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b71:	8b 15 6c 0e 18 f0    	mov    0xf0180e6c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b77:	a1 64 0e 18 f0       	mov    0xf0180e64,%eax
f0101b7c:	c1 e0 0c             	shl    $0xc,%eax
f0101b7f:	89 f1                	mov    %esi,%ecx
f0101b81:	29 d1                	sub    %edx,%ecx
f0101b83:	c1 f9 03             	sar    $0x3,%ecx
f0101b86:	c1 e1 0c             	shl    $0xc,%ecx
f0101b89:	39 c1                	cmp    %eax,%ecx
f0101b8b:	72 24                	jb     f0101bb1 <mem_init+0x29d>
f0101b8d:	c7 44 24 0c c2 69 10 	movl   $0xf01069c2,0xc(%esp)
f0101b94:	f0 
f0101b95:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101b9c:	f0 
f0101b9d:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101ba4:	00 
f0101ba5:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101bac:	e8 0d e5 ff ff       	call   f01000be <_panic>
f0101bb1:	89 f9                	mov    %edi,%ecx
f0101bb3:	29 d1                	sub    %edx,%ecx
f0101bb5:	c1 f9 03             	sar    $0x3,%ecx
f0101bb8:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bbb:	39 c8                	cmp    %ecx,%eax
f0101bbd:	77 24                	ja     f0101be3 <mem_init+0x2cf>
f0101bbf:	c7 44 24 0c df 69 10 	movl   $0xf01069df,0xc(%esp)
f0101bc6:	f0 
f0101bc7:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101bce:	f0 
f0101bcf:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101bd6:	00 
f0101bd7:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101bde:	e8 db e4 ff ff       	call   f01000be <_panic>
f0101be3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101be6:	29 d1                	sub    %edx,%ecx
f0101be8:	89 ca                	mov    %ecx,%edx
f0101bea:	c1 fa 03             	sar    $0x3,%edx
f0101bed:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101bf0:	39 d0                	cmp    %edx,%eax
f0101bf2:	77 24                	ja     f0101c18 <mem_init+0x304>
f0101bf4:	c7 44 24 0c fc 69 10 	movl   $0xf01069fc,0xc(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101c0b:	00 
f0101c0c:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101c13:	e8 a6 e4 ff ff       	call   f01000be <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c18:	a1 c0 01 18 f0       	mov    0xf01801c0,%eax
f0101c1d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c20:	c7 05 c0 01 18 f0 00 	movl   $0x0,0xf01801c0
f0101c27:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c31:	e8 7a f9 ff ff       	call   f01015b0 <page_alloc>
f0101c36:	85 c0                	test   %eax,%eax
f0101c38:	74 24                	je     f0101c5e <mem_init+0x34a>
f0101c3a:	c7 44 24 0c 19 6a 10 	movl   $0xf0106a19,0xc(%esp)
f0101c41:	f0 
f0101c42:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101c49:	f0 
f0101c4a:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101c51:	00 
f0101c52:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101c59:	e8 60 e4 ff ff       	call   f01000be <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c5e:	89 34 24             	mov    %esi,(%esp)
f0101c61:	e8 c8 f9 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0101c66:	89 3c 24             	mov    %edi,(%esp)
f0101c69:	e8 c0 f9 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0101c6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c71:	89 04 24             	mov    %eax,(%esp)
f0101c74:	e8 b5 f9 ff ff       	call   f010162e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c80:	e8 2b f9 ff ff       	call   f01015b0 <page_alloc>
f0101c85:	89 c6                	mov    %eax,%esi
f0101c87:	85 c0                	test   %eax,%eax
f0101c89:	75 24                	jne    f0101caf <mem_init+0x39b>
f0101c8b:	c7 44 24 0c 6e 69 10 	movl   $0xf010696e,0xc(%esp)
f0101c92:	f0 
f0101c93:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101c9a:	f0 
f0101c9b:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101ca2:	00 
f0101ca3:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101caa:	e8 0f e4 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101caf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cb6:	e8 f5 f8 ff ff       	call   f01015b0 <page_alloc>
f0101cbb:	89 c7                	mov    %eax,%edi
f0101cbd:	85 c0                	test   %eax,%eax
f0101cbf:	75 24                	jne    f0101ce5 <mem_init+0x3d1>
f0101cc1:	c7 44 24 0c 84 69 10 	movl   $0xf0106984,0xc(%esp)
f0101cc8:	f0 
f0101cc9:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101cd0:	f0 
f0101cd1:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101cd8:	00 
f0101cd9:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101ce0:	e8 d9 e3 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f0101ce5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cec:	e8 bf f8 ff ff       	call   f01015b0 <page_alloc>
f0101cf1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cf4:	85 c0                	test   %eax,%eax
f0101cf6:	75 24                	jne    f0101d1c <mem_init+0x408>
f0101cf8:	c7 44 24 0c 9a 69 10 	movl   $0xf010699a,0xc(%esp)
f0101cff:	f0 
f0101d00:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101d07:	f0 
f0101d08:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101d0f:	00 
f0101d10:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101d17:	e8 a2 e3 ff ff       	call   f01000be <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d1c:	39 fe                	cmp    %edi,%esi
f0101d1e:	75 24                	jne    f0101d44 <mem_init+0x430>
f0101d20:	c7 44 24 0c b0 69 10 	movl   $0xf01069b0,0xc(%esp)
f0101d27:	f0 
f0101d28:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101d37:	00 
f0101d38:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101d3f:	e8 7a e3 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d44:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d47:	74 05                	je     f0101d4e <mem_init+0x43a>
f0101d49:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d4c:	75 24                	jne    f0101d72 <mem_init+0x45e>
f0101d4e:	c7 44 24 0c 14 62 10 	movl   $0xf0106214,0xc(%esp)
f0101d55:	f0 
f0101d56:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101d5d:	f0 
f0101d5e:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101d65:	00 
f0101d66:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101d6d:	e8 4c e3 ff ff       	call   f01000be <_panic>
	assert(!page_alloc(0));
f0101d72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d79:	e8 32 f8 ff ff       	call   f01015b0 <page_alloc>
f0101d7e:	85 c0                	test   %eax,%eax
f0101d80:	74 24                	je     f0101da6 <mem_init+0x492>
f0101d82:	c7 44 24 0c 19 6a 10 	movl   $0xf0106a19,0xc(%esp)
f0101d89:	f0 
f0101d8a:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101d91:	f0 
f0101d92:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101d99:	00 
f0101d9a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101da1:	e8 18 e3 ff ff       	call   f01000be <_panic>
f0101da6:	89 f0                	mov    %esi,%eax
f0101da8:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f0101dae:	c1 f8 03             	sar    $0x3,%eax
f0101db1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101db4:	89 c2                	mov    %eax,%edx
f0101db6:	c1 ea 0c             	shr    $0xc,%edx
f0101db9:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f0101dbf:	72 20                	jb     f0101de1 <mem_init+0x4cd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101dc5:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0101dcc:	f0 
f0101dcd:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101dd4:	00 
f0101dd5:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0101ddc:	e8 dd e2 ff ff       	call   f01000be <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101de1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101de8:	00 
f0101de9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101df0:	00 
	return (void *)(pa + KERNBASE);
f0101df1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101df6:	89 04 24             	mov    %eax,(%esp)
f0101df9:	e8 73 35 00 00       	call   f0105371 <memset>
	page_free(pp0);
f0101dfe:	89 34 24             	mov    %esi,(%esp)
f0101e01:	e8 28 f8 ff ff       	call   f010162e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101e06:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e0d:	e8 9e f7 ff ff       	call   f01015b0 <page_alloc>
f0101e12:	85 c0                	test   %eax,%eax
f0101e14:	75 24                	jne    f0101e3a <mem_init+0x526>
f0101e16:	c7 44 24 0c 28 6a 10 	movl   $0xf0106a28,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101e35:	e8 84 e2 ff ff       	call   f01000be <_panic>
	assert(pp && pp0 == pp);
f0101e3a:	39 c6                	cmp    %eax,%esi
f0101e3c:	74 24                	je     f0101e62 <mem_init+0x54e>
f0101e3e:	c7 44 24 0c 46 6a 10 	movl   $0xf0106a46,0xc(%esp)
f0101e45:	f0 
f0101e46:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101e4d:	f0 
f0101e4e:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101e55:	00 
f0101e56:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101e5d:	e8 5c e2 ff ff       	call   f01000be <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e62:	89 f2                	mov    %esi,%edx
f0101e64:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0101e6a:	c1 fa 03             	sar    $0x3,%edx
f0101e6d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e70:	89 d0                	mov    %edx,%eax
f0101e72:	c1 e8 0c             	shr    $0xc,%eax
f0101e75:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f0101e7b:	72 20                	jb     f0101e9d <mem_init+0x589>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101e81:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0101e88:	f0 
f0101e89:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101e90:	00 
f0101e91:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0101e98:	e8 21 e2 ff ff       	call   f01000be <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e9d:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101ea4:	75 11                	jne    f0101eb7 <mem_init+0x5a3>
f0101ea6:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101eac:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101eb2:	80 38 00             	cmpb   $0x0,(%eax)
f0101eb5:	74 24                	je     f0101edb <mem_init+0x5c7>
f0101eb7:	c7 44 24 0c 56 6a 10 	movl   $0xf0106a56,0xc(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101ece:	00 
f0101ecf:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101ed6:	e8 e3 e1 ff ff       	call   f01000be <_panic>
f0101edb:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101ede:	39 d0                	cmp    %edx,%eax
f0101ee0:	75 d0                	jne    f0101eb2 <mem_init+0x59e>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ee2:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101ee5:	89 15 c0 01 18 f0    	mov    %edx,0xf01801c0

	// free the pages we took
	page_free(pp0);
f0101eeb:	89 34 24             	mov    %esi,(%esp)
f0101eee:	e8 3b f7 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0101ef3:	89 3c 24             	mov    %edi,(%esp)
f0101ef6:	e8 33 f7 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0101efb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101efe:	89 04 24             	mov    %eax,(%esp)
f0101f01:	e8 28 f7 ff ff       	call   f010162e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f06:	a1 c0 01 18 f0       	mov    0xf01801c0,%eax
f0101f0b:	85 c0                	test   %eax,%eax
f0101f0d:	74 09                	je     f0101f18 <mem_init+0x604>
		--nfree;
f0101f0f:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f12:	8b 00                	mov    (%eax),%eax
f0101f14:	85 c0                	test   %eax,%eax
f0101f16:	75 f7                	jne    f0101f0f <mem_init+0x5fb>
		--nfree;
	assert(nfree == 0);
f0101f18:	85 db                	test   %ebx,%ebx
f0101f1a:	74 24                	je     f0101f40 <mem_init+0x62c>
f0101f1c:	c7 44 24 0c 60 6a 10 	movl   $0xf0106a60,0xc(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101f2b:	f0 
f0101f2c:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101f33:	00 
f0101f34:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101f3b:	e8 7e e1 ff ff       	call   f01000be <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101f40:	c7 04 24 34 62 10 f0 	movl   $0xf0106234,(%esp)
f0101f47:	e8 1e 1f 00 00       	call   f0103e6a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f53:	e8 58 f6 ff ff       	call   f01015b0 <page_alloc>
f0101f58:	89 c6                	mov    %eax,%esi
f0101f5a:	85 c0                	test   %eax,%eax
f0101f5c:	75 24                	jne    f0101f82 <mem_init+0x66e>
f0101f5e:	c7 44 24 0c 6e 69 10 	movl   $0xf010696e,0xc(%esp)
f0101f65:	f0 
f0101f66:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101f6d:	f0 
f0101f6e:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101f75:	00 
f0101f76:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101f7d:	e8 3c e1 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101f82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f89:	e8 22 f6 ff ff       	call   f01015b0 <page_alloc>
f0101f8e:	89 c7                	mov    %eax,%edi
f0101f90:	85 c0                	test   %eax,%eax
f0101f92:	75 24                	jne    f0101fb8 <mem_init+0x6a4>
f0101f94:	c7 44 24 0c 84 69 10 	movl   $0xf0106984,0xc(%esp)
f0101f9b:	f0 
f0101f9c:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101fa3:	f0 
f0101fa4:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101fab:	00 
f0101fac:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101fb3:	e8 06 e1 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f0101fb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fbf:	e8 ec f5 ff ff       	call   f01015b0 <page_alloc>
f0101fc4:	89 c3                	mov    %eax,%ebx
f0101fc6:	85 c0                	test   %eax,%eax
f0101fc8:	75 24                	jne    f0101fee <mem_init+0x6da>
f0101fca:	c7 44 24 0c 9a 69 10 	movl   $0xf010699a,0xc(%esp)
f0101fd1:	f0 
f0101fd2:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0101fd9:	f0 
f0101fda:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101fe1:	00 
f0101fe2:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0101fe9:	e8 d0 e0 ff ff       	call   f01000be <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101fee:	39 fe                	cmp    %edi,%esi
f0101ff0:	75 24                	jne    f0102016 <mem_init+0x702>
f0101ff2:	c7 44 24 0c b0 69 10 	movl   $0xf01069b0,0xc(%esp)
f0101ff9:	f0 
f0101ffa:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102001:	f0 
f0102002:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0102009:	00 
f010200a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102011:	e8 a8 e0 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102016:	39 c7                	cmp    %eax,%edi
f0102018:	74 04                	je     f010201e <mem_init+0x70a>
f010201a:	39 c6                	cmp    %eax,%esi
f010201c:	75 24                	jne    f0102042 <mem_init+0x72e>
f010201e:	c7 44 24 0c 14 62 10 	movl   $0xf0106214,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010203d:	e8 7c e0 ff ff       	call   f01000be <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102042:	8b 15 c0 01 18 f0    	mov    0xf01801c0,%edx
f0102048:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010204b:	c7 05 c0 01 18 f0 00 	movl   $0x0,0xf01801c0
f0102052:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102055:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010205c:	e8 4f f5 ff ff       	call   f01015b0 <page_alloc>
f0102061:	85 c0                	test   %eax,%eax
f0102063:	74 24                	je     f0102089 <mem_init+0x775>
f0102065:	c7 44 24 0c 19 6a 10 	movl   $0xf0106a19,0xc(%esp)
f010206c:	f0 
f010206d:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102074:	f0 
f0102075:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f010207c:	00 
f010207d:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102084:	e8 35 e0 ff ff       	call   f01000be <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102089:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010208c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102097:	00 
f0102098:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f010209d:	89 04 24             	mov    %eax,(%esp)
f01020a0:	e8 f2 f6 ff ff       	call   f0101797 <page_lookup>
f01020a5:	85 c0                	test   %eax,%eax
f01020a7:	74 24                	je     f01020cd <mem_init+0x7b9>
f01020a9:	c7 44 24 0c 54 62 10 	movl   $0xf0106254,0xc(%esp)
f01020b0:	f0 
f01020b1:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01020b8:	f0 
f01020b9:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f01020c0:	00 
f01020c1:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01020c8:	e8 f1 df ff ff       	call   f01000be <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01020cd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020d4:	00 
f01020d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020dc:	00 
f01020dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01020e1:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01020e6:	89 04 24             	mov    %eax,(%esp)
f01020e9:	e8 7c f7 ff ff       	call   f010186a <page_insert>
f01020ee:	85 c0                	test   %eax,%eax
f01020f0:	78 24                	js     f0102116 <mem_init+0x802>
f01020f2:	c7 44 24 0c 8c 62 10 	movl   $0xf010628c,0xc(%esp)
f01020f9:	f0 
f01020fa:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102101:	f0 
f0102102:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102109:	00 
f010210a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102111:	e8 a8 df ff ff       	call   f01000be <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102116:	89 34 24             	mov    %esi,(%esp)
f0102119:	e8 10 f5 ff ff       	call   f010162e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010211e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102125:	00 
f0102126:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010212d:	00 
f010212e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102132:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102137:	89 04 24             	mov    %eax,(%esp)
f010213a:	e8 2b f7 ff ff       	call   f010186a <page_insert>
f010213f:	85 c0                	test   %eax,%eax
f0102141:	74 24                	je     f0102167 <mem_init+0x853>
f0102143:	c7 44 24 0c bc 62 10 	movl   $0xf01062bc,0xc(%esp)
f010214a:	f0 
f010214b:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102152:	f0 
f0102153:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f010215a:	00 
f010215b:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102162:	e8 57 df ff ff       	call   f01000be <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102167:	8b 0d 68 0e 18 f0    	mov    0xf0180e68,%ecx
f010216d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102170:	a1 6c 0e 18 f0       	mov    0xf0180e6c,%eax
f0102175:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102178:	8b 11                	mov    (%ecx),%edx
f010217a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102180:	89 f0                	mov    %esi,%eax
f0102182:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102185:	c1 f8 03             	sar    $0x3,%eax
f0102188:	c1 e0 0c             	shl    $0xc,%eax
f010218b:	39 c2                	cmp    %eax,%edx
f010218d:	74 24                	je     f01021b3 <mem_init+0x89f>
f010218f:	c7 44 24 0c ec 62 10 	movl   $0xf01062ec,0xc(%esp)
f0102196:	f0 
f0102197:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010219e:	f0 
f010219f:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01021a6:	00 
f01021a7:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01021ae:	e8 0b df ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01021b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01021b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bb:	e8 4c ee ff ff       	call   f010100c <check_va2pa>
f01021c0:	89 fa                	mov    %edi,%edx
f01021c2:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01021c5:	c1 fa 03             	sar    $0x3,%edx
f01021c8:	c1 e2 0c             	shl    $0xc,%edx
f01021cb:	39 d0                	cmp    %edx,%eax
f01021cd:	74 24                	je     f01021f3 <mem_init+0x8df>
f01021cf:	c7 44 24 0c 14 63 10 	movl   $0xf0106314,0xc(%esp)
f01021d6:	f0 
f01021d7:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01021de:	f0 
f01021df:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f01021e6:	00 
f01021e7:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01021ee:	e8 cb de ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 1);
f01021f3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01021f8:	74 24                	je     f010221e <mem_init+0x90a>
f01021fa:	c7 44 24 0c 6b 6a 10 	movl   $0xf0106a6b,0xc(%esp)
f0102201:	f0 
f0102202:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102209:	f0 
f010220a:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102211:	00 
f0102212:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102219:	e8 a0 de ff ff       	call   f01000be <_panic>
	assert(pp0->pp_ref == 1);
f010221e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102223:	74 24                	je     f0102249 <mem_init+0x935>
f0102225:	c7 44 24 0c 7c 6a 10 	movl   $0xf0106a7c,0xc(%esp)
f010222c:	f0 
f010222d:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102234:	f0 
f0102235:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f010223c:	00 
f010223d:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102244:	e8 75 de ff ff       	call   f01000be <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102249:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102250:	00 
f0102251:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102258:	00 
f0102259:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010225d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102260:	89 14 24             	mov    %edx,(%esp)
f0102263:	e8 02 f6 ff ff       	call   f010186a <page_insert>
f0102268:	85 c0                	test   %eax,%eax
f010226a:	74 24                	je     f0102290 <mem_init+0x97c>
f010226c:	c7 44 24 0c 44 63 10 	movl   $0xf0106344,0xc(%esp)
f0102273:	f0 
f0102274:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010227b:	f0 
f010227c:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0102283:	00 
f0102284:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010228b:	e8 2e de ff ff       	call   f01000be <_panic>
cprintf("%x %x %x\n",kern_pgdir, PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
f0102290:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102295:	89 f2                	mov    %esi,%edx
f0102297:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f010229d:	c1 fa 03             	sar    $0x3,%edx
f01022a0:	c1 e2 0c             	shl    $0xc,%edx
f01022a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01022a7:	8b 10                	mov    (%eax),%edx
f01022a9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022af:	89 54 24 08          	mov    %edx,0x8(%esp)
f01022b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022b7:	c7 04 24 8d 6a 10 f0 	movl   $0xf0106a8d,(%esp)
f01022be:	e8 a7 1b 00 00       	call   f0103e6a <cprintf>
f01022c3:	89 d8                	mov    %ebx,%eax
f01022c5:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f01022cb:	c1 f8 03             	sar    $0x3,%eax
f01022ce:	c1 e0 0c             	shl    $0xc,%eax

cprintf("%x %x\n", PTE_ADDR(*((pte_t *)(PTE_ADDR(kern_pgdir[0]) + PTX(PGSIZE)))), page2pa(pp2));
f01022d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022d5:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01022da:	8b 00                	mov    (%eax),%eax
f01022dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022e1:	8b 40 01             	mov    0x1(%eax),%eax
f01022e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022ed:	c7 04 24 90 6a 10 f0 	movl   $0xf0106a90,(%esp)
f01022f4:	e8 71 1b 00 00       	call   f0103e6a <cprintf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022f9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022fe:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102303:	e8 04 ed ff ff       	call   f010100c <check_va2pa>
f0102308:	89 da                	mov    %ebx,%edx
f010230a:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0102310:	c1 fa 03             	sar    $0x3,%edx
f0102313:	c1 e2 0c             	shl    $0xc,%edx
f0102316:	39 d0                	cmp    %edx,%eax
f0102318:	74 24                	je     f010233e <mem_init+0xa2a>
f010231a:	c7 44 24 0c 80 63 10 	movl   $0xf0106380,0xc(%esp)
f0102321:	f0 
f0102322:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102329:	f0 
f010232a:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102331:	00 
f0102332:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102339:	e8 80 dd ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f010233e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102343:	74 24                	je     f0102369 <mem_init+0xa55>
f0102345:	c7 44 24 0c 97 6a 10 	movl   $0xf0106a97,0xc(%esp)
f010234c:	f0 
f010234d:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102364:	e8 55 dd ff ff       	call   f01000be <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102369:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102370:	e8 3b f2 ff ff       	call   f01015b0 <page_alloc>
f0102375:	85 c0                	test   %eax,%eax
f0102377:	74 24                	je     f010239d <mem_init+0xa89>
f0102379:	c7 44 24 0c 19 6a 10 	movl   $0xf0106a19,0xc(%esp)
f0102380:	f0 
f0102381:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102388:	f0 
f0102389:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0102390:	00 
f0102391:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102398:	e8 21 dd ff ff       	call   f01000be <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010239d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023a4:	00 
f01023a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023ac:	00 
f01023ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023b1:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01023b6:	89 04 24             	mov    %eax,(%esp)
f01023b9:	e8 ac f4 ff ff       	call   f010186a <page_insert>
f01023be:	85 c0                	test   %eax,%eax
f01023c0:	74 24                	je     f01023e6 <mem_init+0xad2>
f01023c2:	c7 44 24 0c 44 63 10 	movl   $0xf0106344,0xc(%esp)
f01023c9:	f0 
f01023ca:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01023d1:	f0 
f01023d2:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01023d9:	00 
f01023da:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01023e1:	e8 d8 dc ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023e6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023eb:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01023f0:	e8 17 ec ff ff       	call   f010100c <check_va2pa>
f01023f5:	89 da                	mov    %ebx,%edx
f01023f7:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f01023fd:	c1 fa 03             	sar    $0x3,%edx
f0102400:	c1 e2 0c             	shl    $0xc,%edx
f0102403:	39 d0                	cmp    %edx,%eax
f0102405:	74 24                	je     f010242b <mem_init+0xb17>
f0102407:	c7 44 24 0c 80 63 10 	movl   $0xf0106380,0xc(%esp)
f010240e:	f0 
f010240f:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102416:	f0 
f0102417:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010241e:	00 
f010241f:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102426:	e8 93 dc ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f010242b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102430:	74 24                	je     f0102456 <mem_init+0xb42>
f0102432:	c7 44 24 0c 97 6a 10 	movl   $0xf0106a97,0xc(%esp)
f0102439:	f0 
f010243a:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102441:	f0 
f0102442:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102449:	00 
f010244a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102451:	e8 68 dc ff ff       	call   f01000be <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102456:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010245d:	e8 4e f1 ff ff       	call   f01015b0 <page_alloc>
f0102462:	85 c0                	test   %eax,%eax
f0102464:	74 24                	je     f010248a <mem_init+0xb76>
f0102466:	c7 44 24 0c 19 6a 10 	movl   $0xf0106a19,0xc(%esp)
f010246d:	f0 
f010246e:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102475:	f0 
f0102476:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f010247d:	00 
f010247e:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102485:	e8 34 dc ff ff       	call   f01000be <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010248a:	8b 15 68 0e 18 f0    	mov    0xf0180e68,%edx
f0102490:	8b 02                	mov    (%edx),%eax
f0102492:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102497:	89 c1                	mov    %eax,%ecx
f0102499:	c1 e9 0c             	shr    $0xc,%ecx
f010249c:	3b 0d 64 0e 18 f0    	cmp    0xf0180e64,%ecx
f01024a2:	72 20                	jb     f01024c4 <mem_init+0xbb0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024a8:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f01024af:	f0 
f01024b0:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f01024b7:	00 
f01024b8:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01024bf:	e8 fa db ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f01024c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024d3:	00 
f01024d4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024db:	00 
f01024dc:	89 14 24             	mov    %edx,(%esp)
f01024df:	e8 a5 f1 ff ff       	call   f0101689 <pgdir_walk>
f01024e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01024e7:	83 c2 04             	add    $0x4,%edx
f01024ea:	39 d0                	cmp    %edx,%eax
f01024ec:	74 24                	je     f0102512 <mem_init+0xbfe>
f01024ee:	c7 44 24 0c b0 63 10 	movl   $0xf01063b0,0xc(%esp)
f01024f5:	f0 
f01024f6:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01024fd:	f0 
f01024fe:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102505:	00 
f0102506:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010250d:	e8 ac db ff ff       	call   f01000be <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102512:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102519:	00 
f010251a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102521:	00 
f0102522:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102526:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f010252b:	89 04 24             	mov    %eax,(%esp)
f010252e:	e8 37 f3 ff ff       	call   f010186a <page_insert>
f0102533:	85 c0                	test   %eax,%eax
f0102535:	74 24                	je     f010255b <mem_init+0xc47>
f0102537:	c7 44 24 0c f0 63 10 	movl   $0xf01063f0,0xc(%esp)
f010253e:	f0 
f010253f:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102546:	f0 
f0102547:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f010254e:	00 
f010254f:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102556:	e8 63 db ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010255b:	8b 0d 68 0e 18 f0    	mov    0xf0180e68,%ecx
f0102561:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102564:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102569:	89 c8                	mov    %ecx,%eax
f010256b:	e8 9c ea ff ff       	call   f010100c <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102570:	89 da                	mov    %ebx,%edx
f0102572:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0102578:	c1 fa 03             	sar    $0x3,%edx
f010257b:	c1 e2 0c             	shl    $0xc,%edx
f010257e:	39 d0                	cmp    %edx,%eax
f0102580:	74 24                	je     f01025a6 <mem_init+0xc92>
f0102582:	c7 44 24 0c 80 63 10 	movl   $0xf0106380,0xc(%esp)
f0102589:	f0 
f010258a:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102591:	f0 
f0102592:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102599:	00 
f010259a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01025a1:	e8 18 db ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f01025a6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025ab:	74 24                	je     f01025d1 <mem_init+0xcbd>
f01025ad:	c7 44 24 0c 97 6a 10 	movl   $0xf0106a97,0xc(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f01025c4:	00 
f01025c5:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01025cc:	e8 ed da ff ff       	call   f01000be <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025d8:	00 
f01025d9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025e0:	00 
f01025e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025e4:	89 04 24             	mov    %eax,(%esp)
f01025e7:	e8 9d f0 ff ff       	call   f0101689 <pgdir_walk>
f01025ec:	f6 00 04             	testb  $0x4,(%eax)
f01025ef:	75 24                	jne    f0102615 <mem_init+0xd01>
f01025f1:	c7 44 24 0c 30 64 10 	movl   $0xf0106430,0xc(%esp)
f01025f8:	f0 
f01025f9:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102600:	f0 
f0102601:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102608:	00 
f0102609:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102610:	e8 a9 da ff ff       	call   f01000be <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102615:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f010261a:	f6 00 04             	testb  $0x4,(%eax)
f010261d:	75 24                	jne    f0102643 <mem_init+0xd2f>
f010261f:	c7 44 24 0c a8 6a 10 	movl   $0xf0106aa8,0xc(%esp)
f0102626:	f0 
f0102627:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010262e:	f0 
f010262f:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102636:	00 
f0102637:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010263e:	e8 7b da ff ff       	call   f01000be <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102643:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010264a:	00 
f010264b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102652:	00 
f0102653:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102657:	89 04 24             	mov    %eax,(%esp)
f010265a:	e8 0b f2 ff ff       	call   f010186a <page_insert>
f010265f:	85 c0                	test   %eax,%eax
f0102661:	74 24                	je     f0102687 <mem_init+0xd73>
f0102663:	c7 44 24 0c 44 63 10 	movl   $0xf0106344,0xc(%esp)
f010266a:	f0 
f010266b:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102672:	f0 
f0102673:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f010267a:	00 
f010267b:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102682:	e8 37 da ff ff       	call   f01000be <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102687:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010268e:	00 
f010268f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102696:	00 
f0102697:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f010269c:	89 04 24             	mov    %eax,(%esp)
f010269f:	e8 e5 ef ff ff       	call   f0101689 <pgdir_walk>
f01026a4:	f6 00 02             	testb  $0x2,(%eax)
f01026a7:	75 24                	jne    f01026cd <mem_init+0xdb9>
f01026a9:	c7 44 24 0c 64 64 10 	movl   $0xf0106464,0xc(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01026b8:	f0 
f01026b9:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01026c0:	00 
f01026c1:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01026c8:	e8 f1 d9 ff ff       	call   f01000be <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026d4:	00 
f01026d5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026dc:	00 
f01026dd:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01026e2:	89 04 24             	mov    %eax,(%esp)
f01026e5:	e8 9f ef ff ff       	call   f0101689 <pgdir_walk>
f01026ea:	f6 00 04             	testb  $0x4,(%eax)
f01026ed:	74 24                	je     f0102713 <mem_init+0xdff>
f01026ef:	c7 44 24 0c 98 64 10 	movl   $0xf0106498,0xc(%esp)
f01026f6:	f0 
f01026f7:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01026fe:	f0 
f01026ff:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102706:	00 
f0102707:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010270e:	e8 ab d9 ff ff       	call   f01000be <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102713:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010271a:	00 
f010271b:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102722:	00 
f0102723:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102727:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f010272c:	89 04 24             	mov    %eax,(%esp)
f010272f:	e8 36 f1 ff ff       	call   f010186a <page_insert>
f0102734:	85 c0                	test   %eax,%eax
f0102736:	78 24                	js     f010275c <mem_init+0xe48>
f0102738:	c7 44 24 0c d0 64 10 	movl   $0xf01064d0,0xc(%esp)
f010273f:	f0 
f0102740:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102747:	f0 
f0102748:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010274f:	00 
f0102750:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102757:	e8 62 d9 ff ff       	call   f01000be <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010275c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102763:	00 
f0102764:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010276b:	00 
f010276c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102770:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102775:	89 04 24             	mov    %eax,(%esp)
f0102778:	e8 ed f0 ff ff       	call   f010186a <page_insert>
f010277d:	85 c0                	test   %eax,%eax
f010277f:	74 24                	je     f01027a5 <mem_init+0xe91>
f0102781:	c7 44 24 0c 08 65 10 	movl   $0xf0106508,0xc(%esp)
f0102788:	f0 
f0102789:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102790:	f0 
f0102791:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102798:	00 
f0102799:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01027a0:	e8 19 d9 ff ff       	call   f01000be <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027ac:	00 
f01027ad:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027b4:	00 
f01027b5:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01027ba:	89 04 24             	mov    %eax,(%esp)
f01027bd:	e8 c7 ee ff ff       	call   f0101689 <pgdir_walk>
f01027c2:	f6 00 04             	testb  $0x4,(%eax)
f01027c5:	74 24                	je     f01027eb <mem_init+0xed7>
f01027c7:	c7 44 24 0c 98 64 10 	movl   $0xf0106498,0xc(%esp)
f01027ce:	f0 
f01027cf:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01027d6:	f0 
f01027d7:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f01027de:	00 
f01027df:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01027e6:	e8 d3 d8 ff ff       	call   f01000be <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01027eb:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01027f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01027f8:	e8 0f e8 ff ff       	call   f010100c <check_va2pa>
f01027fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102800:	89 f8                	mov    %edi,%eax
f0102802:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f0102808:	c1 f8 03             	sar    $0x3,%eax
f010280b:	c1 e0 0c             	shl    $0xc,%eax
f010280e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102811:	74 24                	je     f0102837 <mem_init+0xf23>
f0102813:	c7 44 24 0c 44 65 10 	movl   $0xf0106544,0xc(%esp)
f010281a:	f0 
f010281b:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102822:	f0 
f0102823:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f010282a:	00 
f010282b:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102832:	e8 87 d8 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102837:	ba 00 10 00 00       	mov    $0x1000,%edx
f010283c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010283f:	e8 c8 e7 ff ff       	call   f010100c <check_va2pa>
f0102844:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102847:	74 24                	je     f010286d <mem_init+0xf59>
f0102849:	c7 44 24 0c 70 65 10 	movl   $0xf0106570,0xc(%esp)
f0102850:	f0 
f0102851:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102858:	f0 
f0102859:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102860:	00 
f0102861:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102868:	e8 51 d8 ff ff       	call   f01000be <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010286d:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102872:	74 24                	je     f0102898 <mem_init+0xf84>
f0102874:	c7 44 24 0c be 6a 10 	movl   $0xf0106abe,0xc(%esp)
f010287b:	f0 
f010287c:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102883:	f0 
f0102884:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f010288b:	00 
f010288c:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102893:	e8 26 d8 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f0102898:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010289d:	74 24                	je     f01028c3 <mem_init+0xfaf>
f010289f:	c7 44 24 0c cf 6a 10 	movl   $0xf0106acf,0xc(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01028b6:	00 
f01028b7:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01028be:	e8 fb d7 ff ff       	call   f01000be <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01028c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028ca:	e8 e1 ec ff ff       	call   f01015b0 <page_alloc>
f01028cf:	85 c0                	test   %eax,%eax
f01028d1:	74 04                	je     f01028d7 <mem_init+0xfc3>
f01028d3:	39 c3                	cmp    %eax,%ebx
f01028d5:	74 24                	je     f01028fb <mem_init+0xfe7>
f01028d7:	c7 44 24 0c a0 65 10 	movl   $0xf01065a0,0xc(%esp)
f01028de:	f0 
f01028df:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01028e6:	f0 
f01028e7:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f01028ee:	00 
f01028ef:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01028f6:	e8 c3 d7 ff ff       	call   f01000be <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01028fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102902:	00 
f0102903:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102908:	89 04 24             	mov    %eax,(%esp)
f010290b:	e8 0a ef ff ff       	call   f010181a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102910:	8b 15 68 0e 18 f0    	mov    0xf0180e68,%edx
f0102916:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102919:	ba 00 00 00 00       	mov    $0x0,%edx
f010291e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102921:	e8 e6 e6 ff ff       	call   f010100c <check_va2pa>
f0102926:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102929:	74 24                	je     f010294f <mem_init+0x103b>
f010292b:	c7 44 24 0c c4 65 10 	movl   $0xf01065c4,0xc(%esp)
f0102932:	f0 
f0102933:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010293a:	f0 
f010293b:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102942:	00 
f0102943:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010294a:	e8 6f d7 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010294f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102954:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102957:	e8 b0 e6 ff ff       	call   f010100c <check_va2pa>
f010295c:	89 fa                	mov    %edi,%edx
f010295e:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0102964:	c1 fa 03             	sar    $0x3,%edx
f0102967:	c1 e2 0c             	shl    $0xc,%edx
f010296a:	39 d0                	cmp    %edx,%eax
f010296c:	74 24                	je     f0102992 <mem_init+0x107e>
f010296e:	c7 44 24 0c 70 65 10 	movl   $0xf0106570,0xc(%esp)
f0102975:	f0 
f0102976:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010297d:	f0 
f010297e:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102985:	00 
f0102986:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010298d:	e8 2c d7 ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 1);
f0102992:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102997:	74 24                	je     f01029bd <mem_init+0x10a9>
f0102999:	c7 44 24 0c 6b 6a 10 	movl   $0xf0106a6b,0xc(%esp)
f01029a0:	f0 
f01029a1:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01029a8:	f0 
f01029a9:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01029b0:	00 
f01029b1:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01029b8:	e8 01 d7 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f01029bd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029c2:	74 24                	je     f01029e8 <mem_init+0x10d4>
f01029c4:	c7 44 24 0c cf 6a 10 	movl   $0xf0106acf,0xc(%esp)
f01029cb:	f0 
f01029cc:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01029d3:	f0 
f01029d4:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01029db:	00 
f01029dc:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01029e3:	e8 d6 d6 ff ff       	call   f01000be <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029e8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029ef:	00 
f01029f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029f3:	89 0c 24             	mov    %ecx,(%esp)
f01029f6:	e8 1f ee ff ff       	call   f010181a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029fb:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102a00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a03:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a08:	e8 ff e5 ff ff       	call   f010100c <check_va2pa>
f0102a0d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a10:	74 24                	je     f0102a36 <mem_init+0x1122>
f0102a12:	c7 44 24 0c c4 65 10 	movl   $0xf01065c4,0xc(%esp)
f0102a19:	f0 
f0102a1a:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102a21:	f0 
f0102a22:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102a29:	00 
f0102a2a:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102a31:	e8 88 d6 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a36:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a3e:	e8 c9 e5 ff ff       	call   f010100c <check_va2pa>
f0102a43:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a46:	74 24                	je     f0102a6c <mem_init+0x1158>
f0102a48:	c7 44 24 0c e8 65 10 	movl   $0xf01065e8,0xc(%esp)
f0102a4f:	f0 
f0102a50:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102a57:	f0 
f0102a58:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102a5f:	00 
f0102a60:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102a67:	e8 52 d6 ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 0);
f0102a6c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a71:	74 24                	je     f0102a97 <mem_init+0x1183>
f0102a73:	c7 44 24 0c e0 6a 10 	movl   $0xf0106ae0,0xc(%esp)
f0102a7a:	f0 
f0102a7b:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102a82:	f0 
f0102a83:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102a8a:	00 
f0102a8b:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102a92:	e8 27 d6 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f0102a97:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a9c:	74 24                	je     f0102ac2 <mem_init+0x11ae>
f0102a9e:	c7 44 24 0c cf 6a 10 	movl   $0xf0106acf,0xc(%esp)
f0102aa5:	f0 
f0102aa6:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102aad:	f0 
f0102aae:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102ab5:	00 
f0102ab6:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102abd:	e8 fc d5 ff ff       	call   f01000be <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102ac2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ac9:	e8 e2 ea ff ff       	call   f01015b0 <page_alloc>
f0102ace:	85 c0                	test   %eax,%eax
f0102ad0:	74 04                	je     f0102ad6 <mem_init+0x11c2>
f0102ad2:	39 c7                	cmp    %eax,%edi
f0102ad4:	74 24                	je     f0102afa <mem_init+0x11e6>
f0102ad6:	c7 44 24 0c 10 66 10 	movl   $0xf0106610,0xc(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102ae5:	f0 
f0102ae6:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102aed:	00 
f0102aee:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102af5:	e8 c4 d5 ff ff       	call   f01000be <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102afa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b01:	e8 aa ea ff ff       	call   f01015b0 <page_alloc>
f0102b06:	85 c0                	test   %eax,%eax
f0102b08:	74 24                	je     f0102b2e <mem_init+0x121a>
f0102b0a:	c7 44 24 0c 19 6a 10 	movl   $0xf0106a19,0xc(%esp)
f0102b11:	f0 
f0102b12:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102b19:	f0 
f0102b1a:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102b21:	00 
f0102b22:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102b29:	e8 90 d5 ff ff       	call   f01000be <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b2e:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102b33:	8b 08                	mov    (%eax),%ecx
f0102b35:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b3b:	89 f2                	mov    %esi,%edx
f0102b3d:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0102b43:	c1 fa 03             	sar    $0x3,%edx
f0102b46:	c1 e2 0c             	shl    $0xc,%edx
f0102b49:	39 d1                	cmp    %edx,%ecx
f0102b4b:	74 24                	je     f0102b71 <mem_init+0x125d>
f0102b4d:	c7 44 24 0c ec 62 10 	movl   $0xf01062ec,0xc(%esp)
f0102b54:	f0 
f0102b55:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102b5c:	f0 
f0102b5d:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102b64:	00 
f0102b65:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102b6c:	e8 4d d5 ff ff       	call   f01000be <_panic>
	kern_pgdir[0] = 0;
f0102b71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b77:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b7c:	74 24                	je     f0102ba2 <mem_init+0x128e>
f0102b7e:	c7 44 24 0c 7c 6a 10 	movl   $0xf0106a7c,0xc(%esp)
f0102b85:	f0 
f0102b86:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102b8d:	f0 
f0102b8e:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102b95:	00 
f0102b96:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102b9d:	e8 1c d5 ff ff       	call   f01000be <_panic>
	pp0->pp_ref = 0;
f0102ba2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102ba8:	89 34 24             	mov    %esi,(%esp)
f0102bab:	e8 7e ea ff ff       	call   f010162e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102bb0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102bb7:	00 
f0102bb8:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102bbf:	00 
f0102bc0:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102bc5:	89 04 24             	mov    %eax,(%esp)
f0102bc8:	e8 bc ea ff ff       	call   f0101689 <pgdir_walk>
f0102bcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102bd0:	8b 0d 68 0e 18 f0    	mov    0xf0180e68,%ecx
f0102bd6:	8b 51 04             	mov    0x4(%ecx),%edx
f0102bd9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102bdf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102be2:	8b 15 64 0e 18 f0    	mov    0xf0180e64,%edx
f0102be8:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102beb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102bee:	c1 ea 0c             	shr    $0xc,%edx
f0102bf1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102bf4:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102bf7:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102bfa:	72 23                	jb     f0102c1f <mem_init+0x130b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bfc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bff:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102c03:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0102c0a:	f0 
f0102c0b:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102c12:	00 
f0102c13:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102c1a:	e8 9f d4 ff ff       	call   f01000be <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c22:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102c28:	39 d0                	cmp    %edx,%eax
f0102c2a:	74 24                	je     f0102c50 <mem_init+0x133c>
f0102c2c:	c7 44 24 0c f1 6a 10 	movl   $0xf0106af1,0xc(%esp)
f0102c33:	f0 
f0102c34:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102c3b:	f0 
f0102c3c:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0102c43:	00 
f0102c44:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102c4b:	e8 6e d4 ff ff       	call   f01000be <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c50:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102c57:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c5d:	89 f0                	mov    %esi,%eax
f0102c5f:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f0102c65:	c1 f8 03             	sar    $0x3,%eax
f0102c68:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c6b:	89 c1                	mov    %eax,%ecx
f0102c6d:	c1 e9 0c             	shr    $0xc,%ecx
f0102c70:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102c73:	77 20                	ja     f0102c95 <mem_init+0x1381>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c79:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0102c80:	f0 
f0102c81:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0102c88:	00 
f0102c89:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0102c90:	e8 29 d4 ff ff       	call   f01000be <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c95:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c9c:	00 
f0102c9d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102ca4:	00 
	return (void *)(pa + KERNBASE);
f0102ca5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102caa:	89 04 24             	mov    %eax,(%esp)
f0102cad:	e8 bf 26 00 00       	call   f0105371 <memset>
	page_free(pp0);
f0102cb2:	89 34 24             	mov    %esi,(%esp)
f0102cb5:	e8 74 e9 ff ff       	call   f010162e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102cba:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102cc1:	00 
f0102cc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102cc9:	00 
f0102cca:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102ccf:	89 04 24             	mov    %eax,(%esp)
f0102cd2:	e8 b2 e9 ff ff       	call   f0101689 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cd7:	89 f2                	mov    %esi,%edx
f0102cd9:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0102cdf:	c1 fa 03             	sar    $0x3,%edx
f0102ce2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ce5:	89 d0                	mov    %edx,%eax
f0102ce7:	c1 e8 0c             	shr    $0xc,%eax
f0102cea:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f0102cf0:	72 20                	jb     f0102d12 <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cf2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cf6:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0102cfd:	f0 
f0102cfe:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0102d05:	00 
f0102d06:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0102d0d:	e8 ac d3 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0102d12:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102d18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d1b:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102d22:	75 11                	jne    f0102d35 <mem_init+0x1421>
f0102d24:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d2a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d30:	f6 00 01             	testb  $0x1,(%eax)
f0102d33:	74 24                	je     f0102d59 <mem_init+0x1445>
f0102d35:	c7 44 24 0c 09 6b 10 	movl   $0xf0106b09,0xc(%esp)
f0102d3c:	f0 
f0102d3d:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102d44:	f0 
f0102d45:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102d4c:	00 
f0102d4d:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102d54:	e8 65 d3 ff ff       	call   f01000be <_panic>
f0102d59:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102d5c:	39 d0                	cmp    %edx,%eax
f0102d5e:	75 d0                	jne    f0102d30 <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102d60:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102d65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d6b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102d71:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d74:	89 0d c0 01 18 f0    	mov    %ecx,0xf01801c0

	// free the pages we took
	page_free(pp0);
f0102d7a:	89 34 24             	mov    %esi,(%esp)
f0102d7d:	e8 ac e8 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0102d82:	89 3c 24             	mov    %edi,(%esp)
f0102d85:	e8 a4 e8 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0102d8a:	89 1c 24             	mov    %ebx,(%esp)
f0102d8d:	e8 9c e8 ff ff       	call   f010162e <page_free>

	cprintf("check_page() succeeded!\n");
f0102d92:	c7 04 24 20 6b 10 f0 	movl   $0xf0106b20,(%esp)
f0102d99:	e8 cc 10 00 00       	call   f0103e6a <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0102d9e:	a1 6c 0e 18 f0       	mov    0xf0180e6c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102da3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102da8:	77 20                	ja     f0102dca <mem_init+0x14b6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102daa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dae:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0102db5:	f0 
f0102db6:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f0102dbd:	00 
f0102dbe:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102dc5:	e8 f4 d2 ff ff       	call   f01000be <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f0102dca:	8b 15 64 0e 18 f0    	mov    0xf0180e64,%edx
f0102dd0:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102dd7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0102ddd:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102de4:	00 
	return (physaddr_t)kva - KERNBASE;
f0102de5:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dea:	89 04 24             	mov    %eax,(%esp)
f0102ded:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102df2:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102df7:	e8 2d e9 ff ff       	call   f0101729 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(
f0102dfc:	a1 cc 01 18 f0       	mov    0xf01801cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e01:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e06:	77 20                	ja     f0102e28 <mem_init+0x1514>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e0c:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0102e13:	f0 
f0102e14:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f0102e1b:	00 
f0102e1c:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102e23:	e8 96 d2 ff ff       	call   f01000be <_panic>
f0102e28:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102e2f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102e30:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e35:	89 04 24             	mov    %eax,(%esp)
f0102e38:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102e3d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e42:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102e47:	e8 dd e8 ff ff       	call   f0101729 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e4c:	be 00 30 11 f0       	mov    $0xf0113000,%esi
f0102e51:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102e57:	77 20                	ja     f0102e79 <mem_init+0x1565>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e59:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e5d:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0102e64:	f0 
f0102e65:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
f0102e6c:	00 
f0102e6d:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102e74:	e8 45 d2 ff ff       	call   f01000be <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0102e79:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e80:	00 
f0102e81:	c7 04 24 00 30 11 00 	movl   $0x113000,(%esp)
f0102e88:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e8d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102e92:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102e97:	e8 8d e8 ff ff       	call   f0101729 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0102e9c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ea3:	00 
f0102ea4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102eab:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102eb0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102eb5:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0102eba:	e8 6a e8 ff ff       	call   f0101729 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102ebf:	8b 1d 68 0e 18 f0    	mov    0xf0180e68,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ec5:	8b 35 64 0e 18 f0    	mov    0xf0180e64,%esi
f0102ecb:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102ece:	8d 3c f5 ff 0f 00 00 	lea    0xfff(,%esi,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102ed5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102edb:	0f 84 80 00 00 00    	je     f0102f61 <mem_init+0x164d>
f0102ee1:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ee6:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102eec:	89 d8                	mov    %ebx,%eax
f0102eee:	e8 19 e1 ff ff       	call   f010100c <check_va2pa>
f0102ef3:	8b 15 6c 0e 18 f0    	mov    0xf0180e6c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ef9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102eff:	77 20                	ja     f0102f21 <mem_init+0x160d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f01:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f05:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0102f0c:	f0 
f0102f0d:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102f14:	00 
f0102f15:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102f1c:	e8 9d d1 ff ff       	call   f01000be <_panic>
f0102f21:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102f28:	39 d0                	cmp    %edx,%eax
f0102f2a:	74 24                	je     f0102f50 <mem_init+0x163c>
f0102f2c:	c7 44 24 0c 34 66 10 	movl   $0xf0106634,0xc(%esp)
f0102f33:	f0 
f0102f34:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102f3b:	f0 
f0102f3c:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102f43:	00 
f0102f44:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102f4b:	e8 6e d1 ff ff       	call   f01000be <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f50:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f56:	39 f7                	cmp    %esi,%edi
f0102f58:	77 8c                	ja     f0102ee6 <mem_init+0x15d2>
f0102f5a:	be 00 00 00 00       	mov    $0x0,%esi
f0102f5f:	eb 05                	jmp    f0102f66 <mem_init+0x1652>
f0102f61:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f66:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f6c:	89 d8                	mov    %ebx,%eax
f0102f6e:	e8 99 e0 ff ff       	call   f010100c <check_va2pa>
f0102f73:	8b 15 cc 01 18 f0    	mov    0xf01801cc,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f79:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f7f:	77 20                	ja     f0102fa1 <mem_init+0x168d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f81:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f85:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0102f8c:	f0 
f0102f8d:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102f94:	00 
f0102f95:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102f9c:	e8 1d d1 ff ff       	call   f01000be <_panic>
f0102fa1:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102fa8:	39 d0                	cmp    %edx,%eax
f0102faa:	74 24                	je     f0102fd0 <mem_init+0x16bc>
f0102fac:	c7 44 24 0c 68 66 10 	movl   $0xf0106668,0xc(%esp)
f0102fb3:	f0 
f0102fb4:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0102fbb:	f0 
f0102fbc:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102fc3:	00 
f0102fc4:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0102fcb:	e8 ee d0 ff ff       	call   f01000be <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102fd0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102fd6:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102fdc:	75 88                	jne    f0102f66 <mem_init+0x1652>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102fde:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102fe1:	c1 e7 0c             	shl    $0xc,%edi
f0102fe4:	85 ff                	test   %edi,%edi
f0102fe6:	74 44                	je     f010302c <mem_init+0x1718>
f0102fe8:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102fed:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ff3:	89 d8                	mov    %ebx,%eax
f0102ff5:	e8 12 e0 ff ff       	call   f010100c <check_va2pa>
f0102ffa:	39 c6                	cmp    %eax,%esi
f0102ffc:	74 24                	je     f0103022 <mem_init+0x170e>
f0102ffe:	c7 44 24 0c 9c 66 10 	movl   $0xf010669c,0xc(%esp)
f0103005:	f0 
f0103006:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010300d:	f0 
f010300e:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0103015:	00 
f0103016:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010301d:	e8 9c d0 ff ff       	call   f01000be <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103022:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103028:	39 fe                	cmp    %edi,%esi
f010302a:	72 c1                	jb     f0102fed <mem_init+0x16d9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010302c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103031:	89 d8                	mov    %ebx,%eax
f0103033:	e8 d4 df ff ff       	call   f010100c <check_va2pa>
f0103038:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010303d:	bf 00 30 11 f0       	mov    $0xf0113000,%edi
f0103042:	81 c7 00 70 00 20    	add    $0x20007000,%edi
f0103048:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010304b:	39 c2                	cmp    %eax,%edx
f010304d:	74 24                	je     f0103073 <mem_init+0x175f>
f010304f:	c7 44 24 0c c4 66 10 	movl   $0xf01066c4,0xc(%esp)
f0103056:	f0 
f0103057:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010305e:	f0 
f010305f:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0103066:	00 
f0103067:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010306e:	e8 4b d0 ff ff       	call   f01000be <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103073:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0103079:	0f 85 37 05 00 00    	jne    f01035b6 <mem_init+0x1ca2>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010307f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103084:	89 d8                	mov    %ebx,%eax
f0103086:	e8 81 df ff ff       	call   f010100c <check_va2pa>
f010308b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010308e:	74 24                	je     f01030b4 <mem_init+0x17a0>
f0103090:	c7 44 24 0c 0c 67 10 	movl   $0xf010670c,0xc(%esp)
f0103097:	f0 
f0103098:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010309f:	f0 
f01030a0:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f01030a7:	00 
f01030a8:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01030af:	e8 0a d0 ff ff       	call   f01000be <_panic>
f01030b4:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01030b9:	ba 01 00 00 00       	mov    $0x1,%edx
f01030be:	8d 88 45 fc ff ff    	lea    -0x3bb(%eax),%ecx
f01030c4:	83 f9 04             	cmp    $0x4,%ecx
f01030c7:	77 39                	ja     f0103102 <mem_init+0x17ee>
f01030c9:	89 d6                	mov    %edx,%esi
f01030cb:	d3 e6                	shl    %cl,%esi
f01030cd:	89 f1                	mov    %esi,%ecx
f01030cf:	f6 c1 17             	test   $0x17,%cl
f01030d2:	74 2e                	je     f0103102 <mem_init+0x17ee>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01030d4:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01030d8:	0f 85 aa 00 00 00    	jne    f0103188 <mem_init+0x1874>
f01030de:	c7 44 24 0c 39 6b 10 	movl   $0xf0106b39,0xc(%esp)
f01030e5:	f0 
f01030e6:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01030ed:	f0 
f01030ee:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01030f5:	00 
f01030f6:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01030fd:	e8 bc cf ff ff       	call   f01000be <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103102:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103107:	76 55                	jbe    f010315e <mem_init+0x184a>
				assert(pgdir[i] & PTE_P);
f0103109:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f010310c:	f6 c1 01             	test   $0x1,%cl
f010310f:	75 24                	jne    f0103135 <mem_init+0x1821>
f0103111:	c7 44 24 0c 39 6b 10 	movl   $0xf0106b39,0xc(%esp)
f0103118:	f0 
f0103119:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0103120:	f0 
f0103121:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0103128:	00 
f0103129:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0103130:	e8 89 cf ff ff       	call   f01000be <_panic>
				assert(pgdir[i] & PTE_W);
f0103135:	f6 c1 02             	test   $0x2,%cl
f0103138:	75 4e                	jne    f0103188 <mem_init+0x1874>
f010313a:	c7 44 24 0c 4a 6b 10 	movl   $0xf0106b4a,0xc(%esp)
f0103141:	f0 
f0103142:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0103149:	f0 
f010314a:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0103151:	00 
f0103152:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0103159:	e8 60 cf ff ff       	call   f01000be <_panic>
			} else
				assert(pgdir[i] == 0);
f010315e:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103162:	74 24                	je     f0103188 <mem_init+0x1874>
f0103164:	c7 44 24 0c 5b 6b 10 	movl   $0xf0106b5b,0xc(%esp)
f010316b:	f0 
f010316c:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0103173:	f0 
f0103174:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f010317b:	00 
f010317c:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0103183:	e8 36 cf ff ff       	call   f01000be <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103188:	83 c0 01             	add    $0x1,%eax
f010318b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103190:	0f 85 28 ff ff ff    	jne    f01030be <mem_init+0x17aa>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103196:	c7 04 24 3c 67 10 f0 	movl   $0xf010673c,(%esp)
f010319d:	e8 c8 0c 00 00       	call   f0103e6a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01031a2:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ac:	77 20                	ja     f01031ce <mem_init+0x18ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031b2:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f01031b9:	f0 
f01031ba:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
f01031c1:	00 
f01031c2:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01031c9:	e8 f0 ce ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031ce:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01031d3:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01031d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01031db:	e8 a0 df ff ff       	call   f0101180 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01031e0:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01031e3:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01031e8:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01031eb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01031ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031f5:	e8 b6 e3 ff ff       	call   f01015b0 <page_alloc>
f01031fa:	89 c6                	mov    %eax,%esi
f01031fc:	85 c0                	test   %eax,%eax
f01031fe:	75 24                	jne    f0103224 <mem_init+0x1910>
f0103200:	c7 44 24 0c 6e 69 10 	movl   $0xf010696e,0xc(%esp)
f0103207:	f0 
f0103208:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010320f:	f0 
f0103210:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0103217:	00 
f0103218:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010321f:	e8 9a ce ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0103224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010322b:	e8 80 e3 ff ff       	call   f01015b0 <page_alloc>
f0103230:	89 c7                	mov    %eax,%edi
f0103232:	85 c0                	test   %eax,%eax
f0103234:	75 24                	jne    f010325a <mem_init+0x1946>
f0103236:	c7 44 24 0c 84 69 10 	movl   $0xf0106984,0xc(%esp)
f010323d:	f0 
f010323e:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0103245:	f0 
f0103246:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f010324d:	00 
f010324e:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0103255:	e8 64 ce ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f010325a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103261:	e8 4a e3 ff ff       	call   f01015b0 <page_alloc>
f0103266:	89 c3                	mov    %eax,%ebx
f0103268:	85 c0                	test   %eax,%eax
f010326a:	75 24                	jne    f0103290 <mem_init+0x197c>
f010326c:	c7 44 24 0c 9a 69 10 	movl   $0xf010699a,0xc(%esp)
f0103273:	f0 
f0103274:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010327b:	f0 
f010327c:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0103283:	00 
f0103284:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010328b:	e8 2e ce ff ff       	call   f01000be <_panic>
	page_free(pp0);
f0103290:	89 34 24             	mov    %esi,(%esp)
f0103293:	e8 96 e3 ff ff       	call   f010162e <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103298:	89 f8                	mov    %edi,%eax
f010329a:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f01032a0:	c1 f8 03             	sar    $0x3,%eax
f01032a3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032a6:	89 c2                	mov    %eax,%edx
f01032a8:	c1 ea 0c             	shr    $0xc,%edx
f01032ab:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f01032b1:	72 20                	jb     f01032d3 <mem_init+0x19bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032b7:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f01032be:	f0 
f01032bf:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01032c6:	00 
f01032c7:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f01032ce:	e8 eb cd ff ff       	call   f01000be <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01032d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032da:	00 
f01032db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01032e2:	00 
	return (void *)(pa + KERNBASE);
f01032e3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01032e8:	89 04 24             	mov    %eax,(%esp)
f01032eb:	e8 81 20 00 00       	call   f0105371 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01032f0:	89 d8                	mov    %ebx,%eax
f01032f2:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f01032f8:	c1 f8 03             	sar    $0x3,%eax
f01032fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032fe:	89 c2                	mov    %eax,%edx
f0103300:	c1 ea 0c             	shr    $0xc,%edx
f0103303:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f0103309:	72 20                	jb     f010332b <mem_init+0x1a17>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010330b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010330f:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0103316:	f0 
f0103317:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f010331e:	00 
f010331f:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0103326:	e8 93 cd ff ff       	call   f01000be <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010332b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103332:	00 
f0103333:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010333a:	00 
	return (void *)(pa + KERNBASE);
f010333b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103340:	89 04 24             	mov    %eax,(%esp)
f0103343:	e8 29 20 00 00       	call   f0105371 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103348:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010334f:	00 
f0103350:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103357:	00 
f0103358:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010335c:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0103361:	89 04 24             	mov    %eax,(%esp)
f0103364:	e8 01 e5 ff ff       	call   f010186a <page_insert>
	assert(pp1->pp_ref == 1);
f0103369:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010336e:	74 24                	je     f0103394 <mem_init+0x1a80>
f0103370:	c7 44 24 0c 6b 6a 10 	movl   $0xf0106a6b,0xc(%esp)
f0103377:	f0 
f0103378:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010337f:	f0 
f0103380:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0103387:	00 
f0103388:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010338f:	e8 2a cd ff ff       	call   f01000be <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103394:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010339b:	01 01 01 
f010339e:	74 24                	je     f01033c4 <mem_init+0x1ab0>
f01033a0:	c7 44 24 0c 5c 67 10 	movl   $0xf010675c,0xc(%esp)
f01033a7:	f0 
f01033a8:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01033af:	f0 
f01033b0:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01033b7:	00 
f01033b8:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01033bf:	e8 fa cc ff ff       	call   f01000be <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01033c4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01033cb:	00 
f01033cc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01033d3:	00 
f01033d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033d8:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01033dd:	89 04 24             	mov    %eax,(%esp)
f01033e0:	e8 85 e4 ff ff       	call   f010186a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01033e5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01033ec:	02 02 02 
f01033ef:	74 24                	je     f0103415 <mem_init+0x1b01>
f01033f1:	c7 44 24 0c 80 67 10 	movl   $0xf0106780,0xc(%esp)
f01033f8:	f0 
f01033f9:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0103400:	f0 
f0103401:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0103408:	00 
f0103409:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0103410:	e8 a9 cc ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f0103415:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010341a:	74 24                	je     f0103440 <mem_init+0x1b2c>
f010341c:	c7 44 24 0c 97 6a 10 	movl   $0xf0106a97,0xc(%esp)
f0103423:	f0 
f0103424:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010342b:	f0 
f010342c:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0103433:	00 
f0103434:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010343b:	e8 7e cc ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 0);
f0103440:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103445:	74 24                	je     f010346b <mem_init+0x1b57>
f0103447:	c7 44 24 0c e0 6a 10 	movl   $0xf0106ae0,0xc(%esp)
f010344e:	f0 
f010344f:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f0103456:	f0 
f0103457:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f010345e:	00 
f010345f:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f0103466:	e8 53 cc ff ff       	call   f01000be <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010346b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103472:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103475:	89 d8                	mov    %ebx,%eax
f0103477:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f010347d:	c1 f8 03             	sar    $0x3,%eax
f0103480:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103483:	89 c2                	mov    %eax,%edx
f0103485:	c1 ea 0c             	shr    $0xc,%edx
f0103488:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f010348e:	72 20                	jb     f01034b0 <mem_init+0x1b9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103490:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103494:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f010349b:	f0 
f010349c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01034a3:	00 
f01034a4:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f01034ab:	e8 0e cc ff ff       	call   f01000be <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01034b0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01034b7:	03 03 03 
f01034ba:	74 24                	je     f01034e0 <mem_init+0x1bcc>
f01034bc:	c7 44 24 0c a4 67 10 	movl   $0xf01067a4,0xc(%esp)
f01034c3:	f0 
f01034c4:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01034cb:	f0 
f01034cc:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01034d3:	00 
f01034d4:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f01034db:	e8 de cb ff ff       	call   f01000be <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01034e0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01034e7:	00 
f01034e8:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f01034ed:	89 04 24             	mov    %eax,(%esp)
f01034f0:	e8 25 e3 ff ff       	call   f010181a <page_remove>
	assert(pp2->pp_ref == 0);
f01034f5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01034fa:	74 24                	je     f0103520 <mem_init+0x1c0c>
f01034fc:	c7 44 24 0c cf 6a 10 	movl   $0xf0106acf,0xc(%esp)
f0103503:	f0 
f0103504:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010350b:	f0 
f010350c:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0103513:	00 
f0103514:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010351b:	e8 9e cb ff ff       	call   f01000be <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103520:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
f0103525:	8b 08                	mov    (%eax),%ecx
f0103527:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010352d:	89 f2                	mov    %esi,%edx
f010352f:	2b 15 6c 0e 18 f0    	sub    0xf0180e6c,%edx
f0103535:	c1 fa 03             	sar    $0x3,%edx
f0103538:	c1 e2 0c             	shl    $0xc,%edx
f010353b:	39 d1                	cmp    %edx,%ecx
f010353d:	74 24                	je     f0103563 <mem_init+0x1c4f>
f010353f:	c7 44 24 0c ec 62 10 	movl   $0xf01062ec,0xc(%esp)
f0103546:	f0 
f0103547:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010354e:	f0 
f010354f:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f0103556:	00 
f0103557:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010355e:	e8 5b cb ff ff       	call   f01000be <_panic>
	kern_pgdir[0] = 0;
f0103563:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103569:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010356e:	74 24                	je     f0103594 <mem_init+0x1c80>
f0103570:	c7 44 24 0c 7c 6a 10 	movl   $0xf0106a7c,0xc(%esp)
f0103577:	f0 
f0103578:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010357f:	f0 
f0103580:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0103587:	00 
f0103588:	c7 04 24 81 68 10 f0 	movl   $0xf0106881,(%esp)
f010358f:	e8 2a cb ff ff       	call   f01000be <_panic>
	pp0->pp_ref = 0;
f0103594:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010359a:	89 34 24             	mov    %esi,(%esp)
f010359d:	e8 8c e0 ff ff       	call   f010162e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01035a2:	c7 04 24 d0 67 10 f0 	movl   $0xf01067d0,(%esp)
f01035a9:	e8 bc 08 00 00       	call   f0103e6a <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01035ae:	83 c4 3c             	add    $0x3c,%esp
f01035b1:	5b                   	pop    %ebx
f01035b2:	5e                   	pop    %esi
f01035b3:	5f                   	pop    %edi
f01035b4:	5d                   	pop    %ebp
f01035b5:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01035b6:	89 f2                	mov    %esi,%edx
f01035b8:	89 d8                	mov    %ebx,%eax
f01035ba:	e8 4d da ff ff       	call   f010100c <check_va2pa>
f01035bf:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01035c5:	e9 7e fa ff ff       	jmp    f0103048 <mem_init+0x1734>

f01035ca <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01035ca:	55                   	push   %ebp
f01035cb:	89 e5                	mov    %esp,%ebp
f01035cd:	57                   	push   %edi
f01035ce:	56                   	push   %esi
f01035cf:	53                   	push   %ebx
f01035d0:	83 ec 2c             	sub    $0x2c,%esp
f01035d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01035d6:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	cprintf("%s\n", "Check for user memory!\n");
f01035d9:	c7 44 24 04 69 6b 10 	movl   $0xf0106b69,0x4(%esp)
f01035e0:	f0 
f01035e1:	c7 04 24 2e 5b 10 f0 	movl   $0xf0105b2e,(%esp)
f01035e8:	e8 7d 08 00 00       	call   f0103e6a <cprintf>

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
f01035ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01035f0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
f01035f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01035f9:	8b 55 10             	mov    0x10(%ebp),%edx
f01035fc:	8d 84 11 ff 0f 00 00 	lea    0xfff(%ecx,%edx,1),%eax
f0103603:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103608:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f010360b:	39 c3                	cmp    %eax,%ebx
f010360d:	73 68                	jae    f0103677 <user_mem_check+0xad>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)_va_start, 0);
f010360f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103616:	00 
f0103617:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010361b:	8b 46 5c             	mov    0x5c(%esi),%eax
f010361e:	89 04 24             	mov    %eax,(%esp)
f0103621:	e8 63 e0 ff ff       	call   f0101689 <pgdir_walk>

        if ((_va_start>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103626:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010362c:	77 10                	ja     f010363e <user_mem_check+0x74>
f010362e:	85 c0                	test   %eax,%eax
f0103630:	74 0c                	je     f010363e <user_mem_check+0x74>
f0103632:	8b 00                	mov    (%eax),%eax
f0103634:	a8 01                	test   $0x1,%al
f0103636:	74 06                	je     f010363e <user_mem_check+0x74>
f0103638:	21 f8                	and    %edi,%eax
f010363a:	39 c7                	cmp    %eax,%edi
f010363c:	74 2e                	je     f010366c <user_mem_check+0xa2>
            user_mem_check_addr = (_va_start<(uint32_t)va) ? (uint32_t)va : _va_start;
f010363e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103641:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103645:	89 1d c4 01 18 f0    	mov    %ebx,0xf01801c4
            cprintf("user_mem_check fail va: %x, len: %x\n", va, len);
f010364b:	8b 45 10             	mov    0x10(%ebp),%eax
f010364e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103652:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103655:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103659:	c7 04 24 fc 67 10 f0 	movl   $0xf01067fc,(%esp)
f0103660:	e8 05 08 00 00       	call   f0103e6a <cprintf>
            return -E_FAULT;
f0103665:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010366a:	eb 2a                	jmp    f0103696 <user_mem_check+0xcc>
	// LAB 3: Your code here.
	cprintf("%s\n", "Check for user memory!\n");

	uint32_t _va_start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t _va_end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	for(; _va_start<_va_end; _va_start+=PGSIZE) {
f010366c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103672:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0103675:	77 98                	ja     f010360f <user_mem_check+0x45>
            return -E_FAULT;
        }

	}

	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f0103677:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010367a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010367e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103681:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103685:	c7 04 24 24 68 10 f0 	movl   $0xf0106824,(%esp)
f010368c:	e8 d9 07 00 00       	call   f0103e6a <cprintf>

	return 0;
f0103691:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103696:	83 c4 2c             	add    $0x2c,%esp
f0103699:	5b                   	pop    %ebx
f010369a:	5e                   	pop    %esi
f010369b:	5f                   	pop    %edi
f010369c:	5d                   	pop    %ebp
f010369d:	c3                   	ret    

f010369e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010369e:	55                   	push   %ebp
f010369f:	89 e5                	mov    %esp,%ebp
f01036a1:	53                   	push   %ebx
f01036a2:	83 ec 14             	sub    $0x14,%esp
f01036a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01036a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01036ab:	83 c8 04             	or     $0x4,%eax
f01036ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036b2:	8b 45 10             	mov    0x10(%ebp),%eax
f01036b5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036c0:	89 1c 24             	mov    %ebx,(%esp)
f01036c3:	e8 02 ff ff ff       	call   f01035ca <user_mem_check>
f01036c8:	85 c0                	test   %eax,%eax
f01036ca:	79 24                	jns    f01036f0 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f01036cc:	a1 c4 01 18 f0       	mov    0xf01801c4,%eax
f01036d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036d5:	8b 43 48             	mov    0x48(%ebx),%eax
f01036d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036dc:	c7 04 24 4c 68 10 f0 	movl   $0xf010684c,(%esp)
f01036e3:	e8 82 07 00 00       	call   f0103e6a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01036e8:	89 1c 24             	mov    %ebx,(%esp)
f01036eb:	e8 49 06 00 00       	call   f0103d39 <env_destroy>
	}
}
f01036f0:	83 c4 14             	add    $0x14,%esp
f01036f3:	5b                   	pop    %ebx
f01036f4:	5d                   	pop    %ebp
f01036f5:	c3                   	ret    
	...

f01036f8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01036f8:	55                   	push   %ebp
f01036f9:	89 e5                	mov    %esp,%ebp
f01036fb:	57                   	push   %edi
f01036fc:	56                   	push   %esi
f01036fd:	53                   	push   %ebx
f01036fe:	83 ec 2c             	sub    $0x2c,%esp
f0103701:	89 c7                	mov    %eax,%edi
	//   (Watch out for corner-cases!)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
f0103703:	89 d3                	mov    %edx,%ebx
f0103705:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f010370b:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0103711:	c1 e8 0c             	shr    $0xc,%eax
f0103714:	85 c0                	test   %eax,%eax
f0103716:	74 5d                	je     f0103775 <region_alloc+0x7d>
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
f0103718:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f010371b:	be 00 00 00 00       	mov    $0x0,%esi
		struct PageInfo *p = page_alloc(0);
f0103720:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103727:	e8 84 de ff ff       	call   f01015b0 <page_alloc>
		if(!p)
f010372c:	85 c0                	test   %eax,%eax
f010372e:	75 1c                	jne    f010374c <region_alloc+0x54>
			panic("region_alloc failed!");
f0103730:	c7 44 24 08 81 6b 10 	movl   $0xf0106b81,0x8(%esp)
f0103737:	f0 
f0103738:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f010373f:	00 
f0103740:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103747:	e8 72 c9 ff ff       	call   f01000be <_panic>
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
f010374c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103753:	00 
f0103754:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103758:	89 44 24 04          	mov    %eax,0x4(%esp)
f010375c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010375f:	89 04 24             	mov    %eax,(%esp)
f0103762:	e8 03 e1 ff ff       	call   f010186a <page_insert>

	// Aplly for physical pages
	// Map the pages into page directory
	int i;
	void *_va = ROUNDDOWN(va, PGSIZE);
	for(i=0; i<ROUNDUP(len, PGSIZE)/PGSIZE; i++) {
f0103767:	83 c6 01             	add    $0x1,%esi
f010376a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103770:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103773:	75 ab                	jne    f0103720 <region_alloc+0x28>
		struct PageInfo *p = page_alloc(0);
		if(!p)
			panic("region_alloc failed!");
		page_insert(e->env_pgdir, p, _va+i*PGSIZE, PTE_W | PTE_U);
	}
}
f0103775:	83 c4 2c             	add    $0x2c,%esp
f0103778:	5b                   	pop    %ebx
f0103779:	5e                   	pop    %esi
f010377a:	5f                   	pop    %edi
f010377b:	5d                   	pop    %ebp
f010377c:	c3                   	ret    

f010377d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010377d:	55                   	push   %ebp
f010377e:	89 e5                	mov    %esp,%ebp
f0103780:	53                   	push   %ebx
f0103781:	8b 45 08             	mov    0x8(%ebp),%eax
f0103784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103787:	0f b6 5d 10          	movzbl 0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010378b:	85 c0                	test   %eax,%eax
f010378d:	75 0e                	jne    f010379d <envid2env+0x20>
		*env_store = curenv;
f010378f:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f0103794:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103796:	b8 00 00 00 00       	mov    $0x0,%eax
f010379b:	eb 55                	jmp    f01037f2 <envid2env+0x75>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010379d:	89 c2                	mov    %eax,%edx
f010379f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01037a5:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01037a8:	c1 e2 05             	shl    $0x5,%edx
f01037ab:	03 15 cc 01 18 f0    	add    0xf01801cc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01037b1:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01037b5:	74 05                	je     f01037bc <envid2env+0x3f>
f01037b7:	39 42 48             	cmp    %eax,0x48(%edx)
f01037ba:	74 0d                	je     f01037c9 <envid2env+0x4c>
		*env_store = 0;
f01037bc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01037c2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01037c7:	eb 29                	jmp    f01037f2 <envid2env+0x75>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01037c9:	84 db                	test   %bl,%bl
f01037cb:	74 1e                	je     f01037eb <envid2env+0x6e>
f01037cd:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01037d2:	39 c2                	cmp    %eax,%edx
f01037d4:	74 15                	je     f01037eb <envid2env+0x6e>
f01037d6:	8b 58 48             	mov    0x48(%eax),%ebx
f01037d9:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f01037dc:	74 0d                	je     f01037eb <envid2env+0x6e>
		*env_store = 0;
f01037de:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01037e4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01037e9:	eb 07                	jmp    f01037f2 <envid2env+0x75>
	}

	*env_store = e;
f01037eb:	89 11                	mov    %edx,(%ecx)
	return 0;
f01037ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037f2:	5b                   	pop    %ebx
f01037f3:	5d                   	pop    %ebp
f01037f4:	c3                   	ret    

f01037f5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01037f5:	55                   	push   %ebp
f01037f6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01037f8:	b8 20 d3 11 f0       	mov    $0xf011d320,%eax
f01037fd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103800:	b8 23 00 00 00       	mov    $0x23,%eax
f0103805:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103807:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103809:	b0 10                	mov    $0x10,%al
f010380b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010380d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010380f:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103811:	ea 18 38 10 f0 08 00 	ljmp   $0x8,$0xf0103818
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103818:	b0 00                	mov    $0x0,%al
f010381a:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010381d:	5d                   	pop    %ebp
f010381e:	c3                   	ret    

f010381f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010381f:	55                   	push   %ebp
f0103820:	89 e5                	mov    %esp,%ebp
f0103822:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	envs[0].env_id = 0;
f0103823:	8b 15 cc 01 18 f0    	mov    0xf01801cc,%edx
f0103829:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
	env_free_list = envs;
f0103830:	89 15 d0 01 18 f0    	mov    %edx,0xf01801d0
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103836:	8d 42 60             	lea    0x60(%edx),%eax
f0103839:	8d 9a 00 80 01 00    	lea    0x18000(%edx),%ebx
f010383f:	eb 02                	jmp    f0103843 <env_init+0x24>

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
		_env->env_link = &envs[i];
		_env = _env->env_link;
f0103841:	89 ca                	mov    %ecx,%edx
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
		envs[i].env_id = 0;
f0103843:	89 c1                	mov    %eax,%ecx
f0103845:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		_env->env_link = &envs[i];
f010384c:	89 42 44             	mov    %eax,0x44(%edx)
f010384f:	83 c0 60             	add    $0x60,%eax
	envs[0].env_id = 0;
	env_free_list = envs;
	struct Env *_env = env_free_list;

	int i;
	for(i=1; i<NENV; i++) {
f0103852:	39 d8                	cmp    %ebx,%eax
f0103854:	75 eb                	jne    f0103841 <env_init+0x22>
		_env->env_link = &envs[i];
		_env = _env->env_link;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0103856:	e8 9a ff ff ff       	call   f01037f5 <env_init_percpu>
}
f010385b:	5b                   	pop    %ebx
f010385c:	5d                   	pop    %ebp
f010385d:	c3                   	ret    

f010385e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010385e:	55                   	push   %ebp
f010385f:	89 e5                	mov    %esp,%ebp
f0103861:	53                   	push   %ebx
f0103862:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103865:	8b 1d d0 01 18 f0    	mov    0xf01801d0,%ebx
f010386b:	85 db                	test   %ebx,%ebx
f010386d:	0f 84 66 01 00 00    	je     f01039d9 <env_alloc+0x17b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103873:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010387a:	e8 31 dd ff ff       	call   f01015b0 <page_alloc>
f010387f:	85 c0                	test   %eax,%eax
f0103881:	0f 84 59 01 00 00    	je     f01039e0 <env_alloc+0x182>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	/*************************** LAB 3: Your code here.***************************/
	p->pp_ref ++;
f0103887:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010388c:	2b 05 6c 0e 18 f0    	sub    0xf0180e6c,%eax
f0103892:	c1 f8 03             	sar    $0x3,%eax
f0103895:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103898:	89 c2                	mov    %eax,%edx
f010389a:	c1 ea 0c             	shr    $0xc,%edx
f010389d:	3b 15 64 0e 18 f0    	cmp    0xf0180e64,%edx
f01038a3:	72 20                	jb     f01038c5 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038a9:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f01038b0:	f0 
f01038b1:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01038b8:	00 
f01038b9:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f01038c0:	e8 f9 c7 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f01038c5:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f01038ca:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01038cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01038d4:	00 
f01038d5:	8b 15 68 0e 18 f0    	mov    0xf0180e68,%edx
f01038db:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038df:	89 04 24             	mov    %eax,(%esp)
f01038e2:	e8 5e 1b 00 00       	call   f0105445 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01038e7:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038ef:	77 20                	ja     f0103911 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038f5:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f01038fc:	f0 
f01038fd:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0103904:	00 
f0103905:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f010390c:	e8 ad c7 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103911:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103917:	83 ca 05             	or     $0x5,%edx
f010391a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103920:	8b 43 48             	mov    0x48(%ebx),%eax
f0103923:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103928:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010392d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103932:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103935:	89 da                	mov    %ebx,%edx
f0103937:	2b 15 cc 01 18 f0    	sub    0xf01801cc,%edx
f010393d:	c1 fa 05             	sar    $0x5,%edx
f0103940:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103946:	09 d0                	or     %edx,%eax
f0103948:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010394b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010394e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103951:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103958:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010395f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103966:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010396d:	00 
f010396e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103975:	00 
f0103976:	89 1c 24             	mov    %ebx,(%esp)
f0103979:	e8 f3 19 00 00       	call   f0105371 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010397e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103984:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010398a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103990:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103997:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010399d:	8b 43 44             	mov    0x44(%ebx),%eax
f01039a0:	a3 d0 01 18 f0       	mov    %eax,0xf01801d0
	*newenv_store = e;
f01039a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01039a8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01039aa:	8b 4b 48             	mov    0x48(%ebx),%ecx
f01039ad:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01039b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01039b7:	85 c0                	test   %eax,%eax
f01039b9:	74 03                	je     f01039be <env_alloc+0x160>
f01039bb:	8b 50 48             	mov    0x48(%eax),%edx
f01039be:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01039c2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01039c6:	c7 04 24 a1 6b 10 f0 	movl   $0xf0106ba1,(%esp)
f01039cd:	e8 98 04 00 00       	call   f0103e6a <cprintf>
	return 0;
f01039d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01039d7:	eb 0c                	jmp    f01039e5 <env_alloc+0x187>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01039d9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01039de:	eb 05                	jmp    f01039e5 <env_alloc+0x187>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01039e0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01039e5:	83 c4 14             	add    $0x14,%esp
f01039e8:	5b                   	pop    %ebx
f01039e9:	5d                   	pop    %ebp
f01039ea:	c3                   	ret    

f01039eb <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f01039eb:	55                   	push   %ebp
f01039ec:	89 e5                	mov    %esp,%ebp
f01039ee:	57                   	push   %edi
f01039ef:	56                   	push   %esi
f01039f0:	53                   	push   %ebx
f01039f1:	83 ec 3c             	sub    $0x3c,%esp
f01039f4:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int res;
	if ((res = env_alloc(&env, 0)))
f01039f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039fe:	00 
f01039ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103a02:	89 04 24             	mov    %eax,(%esp)
f0103a05:	e8 54 fe ff ff       	call   f010385e <env_alloc>
f0103a0a:	85 c0                	test   %eax,%eax
f0103a0c:	74 20                	je     f0103a2e <env_create+0x43>
		panic("env_create: %e", res);
f0103a0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a12:	c7 44 24 08 b6 6b 10 	movl   $0xf0106bb6,0x8(%esp)
f0103a19:	f0 
f0103a1a:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f0103a21:	00 
f0103a22:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103a29:	e8 90 c6 ff ff       	call   f01000be <_panic>

	load_icode(env, binary, size);
f0103a2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
f0103a34:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103a3a:	74 1c                	je     f0103a58 <env_create+0x6d>
		panic("Invalid ELF!");
f0103a3c:	c7 44 24 08 c5 6b 10 	movl   $0xf0106bc5,0x8(%esp)
f0103a43:	f0 
f0103a44:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0103a4b:	00 
f0103a4c:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103a53:	e8 66 c6 ff ff       	call   f01000be <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103a58:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f0103a5b:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
f0103a5f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a62:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a65:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a6a:	77 20                	ja     f0103a8c <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a70:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0103a77:	f0 
f0103a78:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f0103a7f:	00 
f0103a80:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103a87:	e8 32 c6 ff ff       	call   f01000be <_panic>
	struct Proghdr *ph, *eph;

	if(elf->e_magic != ELF_MAGIC)
		panic("Invalid ELF!");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103a8c:	01 fb                	add    %edi,%ebx
	eph = ph + elf->e_phnum;
f0103a8e:	0f b7 f6             	movzwl %si,%esi
f0103a91:	c1 e6 05             	shl    $0x5,%esi
f0103a94:	01 de                	add    %ebx,%esi
	return (physaddr_t)kva - KERNBASE;
f0103a96:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a9b:	0f 22 d8             	mov    %eax,%cr3

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f0103a9e:	39 f3                	cmp    %esi,%ebx
f0103aa0:	73 4f                	jae    f0103af1 <env_create+0x106>
		if (ph->p_type != ELF_PROG_LOAD)
f0103aa2:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103aa5:	75 43                	jne    f0103aea <env_create+0xff>
			continue;
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f0103aa7:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103aaa:	8b 53 08             	mov    0x8(%ebx),%edx
f0103aad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ab0:	e8 43 fc ff ff       	call   f01036f8 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f0103ab5:	8b 43 14             	mov    0x14(%ebx),%eax
f0103ab8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103abc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ac3:	00 
f0103ac4:	8b 43 08             	mov    0x8(%ebx),%eax
f0103ac7:	89 04 24             	mov    %eax,(%esp)
f0103aca:	e8 a2 18 00 00       	call   f0105371 <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103acf:	8b 43 10             	mov    0x10(%ebx),%eax
f0103ad2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ad6:	89 f8                	mov    %edi,%eax
f0103ad8:	03 43 04             	add    0x4(%ebx),%eax
f0103adb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103adf:	8b 43 08             	mov    0x8(%ebx),%eax
f0103ae2:	89 04 24             	mov    %eax,(%esp)
f0103ae5:	e8 e2 18 00 00       	call   f01053cc <memmove>
	eph = ph + elf->e_phnum;

	// switch to user page directory 
	// Note: lcr3 need a physical address!
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f0103aea:	83 c3 20             	add    $0x20,%ebx
f0103aed:	39 de                	cmp    %ebx,%esi
f0103aef:	77 b1                	ja     f0103aa2 <env_create+0xb7>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
		memset((void*)ph->p_va, 0, ph->p_memsz);
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
	}
	// switch back to kernel page directory
	lcr3(PADDR(kern_pgdir));
f0103af1:	a1 68 0e 18 f0       	mov    0xf0180e68,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103af6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103afb:	77 20                	ja     f0103b1d <env_create+0x132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103afd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b01:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0103b08:	f0 
f0103b09:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103b10:	00 
f0103b11:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103b18:	e8 a1 c5 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b1d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b22:	0f 22 d8             	mov    %eax,%cr3

	(e->env_tf).tf_eip = (uintptr_t)(elf->e_entry);
f0103b25:	8b 47 18             	mov    0x18(%edi),%eax
f0103b28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103b2b:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);
f0103b2e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103b33:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103b38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103b3b:	e8 b8 fb ff ff       	call   f01036f8 <region_alloc>
	if ((res = env_alloc(&env, 0)))
		panic("env_create: %e", res);

	load_icode(env, binary, size);

	env->env_type = type;
f0103b40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b43:	8b 55 10             	mov    0x10(%ebp),%edx
f0103b46:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103b49:	83 c4 3c             	add    $0x3c,%esp
f0103b4c:	5b                   	pop    %ebx
f0103b4d:	5e                   	pop    %esi
f0103b4e:	5f                   	pop    %edi
f0103b4f:	5d                   	pop    %ebp
f0103b50:	c3                   	ret    

f0103b51 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103b51:	55                   	push   %ebp
f0103b52:	89 e5                	mov    %esp,%ebp
f0103b54:	57                   	push   %edi
f0103b55:	56                   	push   %esi
f0103b56:	53                   	push   %ebx
f0103b57:	83 ec 2c             	sub    $0x2c,%esp
f0103b5a:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103b5d:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f0103b62:	39 c7                	cmp    %eax,%edi
f0103b64:	75 37                	jne    f0103b9d <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103b66:	8b 15 68 0e 18 f0    	mov    0xf0180e68,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b6c:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103b72:	77 20                	ja     f0103b94 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b74:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b78:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0103b7f:	f0 
f0103b80:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f0103b87:	00 
f0103b88:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103b8f:	e8 2a c5 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b94:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103b9a:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103b9d:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103ba0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ba5:	85 c0                	test   %eax,%eax
f0103ba7:	74 03                	je     f0103bac <env_free+0x5b>
f0103ba9:	8b 50 48             	mov    0x48(%eax),%edx
f0103bac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103bb0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103bb4:	c7 04 24 d2 6b 10 f0 	movl   $0xf0106bd2,(%esp)
f0103bbb:	e8 aa 02 00 00       	call   f0103e6a <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bc0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103bc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bca:	c1 e0 02             	shl    $0x2,%eax
f0103bcd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103bd0:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103bd3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103bd6:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103bd9:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103bdf:	0f 84 b8 00 00 00    	je     f0103c9d <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103be5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103beb:	89 f0                	mov    %esi,%eax
f0103bed:	c1 e8 0c             	shr    $0xc,%eax
f0103bf0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103bf3:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f0103bf9:	72 20                	jb     f0103c1b <env_free+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103bfb:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103bff:	c7 44 24 08 88 60 10 	movl   $0xf0106088,0x8(%esp)
f0103c06:	f0 
f0103c07:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
f0103c0e:	00 
f0103c0f:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103c16:	e8 a3 c4 ff ff       	call   f01000be <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103c1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103c1e:	c1 e2 16             	shl    $0x16,%edx
f0103c21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103c24:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103c29:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103c30:	01 
f0103c31:	74 17                	je     f0103c4a <env_free+0xf9>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103c33:	89 d8                	mov    %ebx,%eax
f0103c35:	c1 e0 0c             	shl    $0xc,%eax
f0103c38:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c3f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103c42:	89 04 24             	mov    %eax,(%esp)
f0103c45:	e8 d0 db ff ff       	call   f010181a <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103c4a:	83 c3 01             	add    $0x1,%ebx
f0103c4d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103c53:	75 d4                	jne    f0103c29 <env_free+0xd8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103c55:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103c58:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103c5b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c62:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103c65:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f0103c6b:	72 1c                	jb     f0103c89 <env_free+0x138>
		panic("pa2page called with invalid pa");
f0103c6d:	c7 44 24 08 b8 61 10 	movl   $0xf01061b8,0x8(%esp)
f0103c74:	f0 
f0103c75:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f0103c7c:	00 
f0103c7d:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0103c84:	e8 35 c4 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f0103c89:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103c8c:	c1 e0 03             	shl    $0x3,%eax
f0103c8f:	03 05 6c 0e 18 f0    	add    0xf0180e6c,%eax
		page_decref(pa2page(pa));
f0103c95:	89 04 24             	mov    %eax,(%esp)
f0103c98:	e8 c9 d9 ff ff       	call   f0101666 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c9d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103ca1:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103ca8:	0f 85 19 ff ff ff    	jne    f0103bc7 <env_free+0x76>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103cae:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cb1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cb6:	77 20                	ja     f0103cd8 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cbc:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0103cc3:	f0 
f0103cc4:	c7 44 24 04 bc 01 00 	movl   $0x1bc,0x4(%esp)
f0103ccb:	00 
f0103ccc:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103cd3:	e8 e6 c3 ff ff       	call   f01000be <_panic>
	e->env_pgdir = 0;
f0103cd8:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103cdf:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ce4:	c1 e8 0c             	shr    $0xc,%eax
f0103ce7:	3b 05 64 0e 18 f0    	cmp    0xf0180e64,%eax
f0103ced:	72 1c                	jb     f0103d0b <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f0103cef:	c7 44 24 08 b8 61 10 	movl   $0xf01061b8,0x8(%esp)
f0103cf6:	f0 
f0103cf7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f0103cfe:	00 
f0103cff:	c7 04 24 a9 68 10 f0 	movl   $0xf01068a9,(%esp)
f0103d06:	e8 b3 c3 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f0103d0b:	c1 e0 03             	shl    $0x3,%eax
f0103d0e:	03 05 6c 0e 18 f0    	add    0xf0180e6c,%eax
	page_decref(pa2page(pa));
f0103d14:	89 04 24             	mov    %eax,(%esp)
f0103d17:	e8 4a d9 ff ff       	call   f0101666 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103d1c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103d23:	a1 d0 01 18 f0       	mov    0xf01801d0,%eax
f0103d28:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103d2b:	89 3d d0 01 18 f0    	mov    %edi,0xf01801d0
}
f0103d31:	83 c4 2c             	add    $0x2c,%esp
f0103d34:	5b                   	pop    %ebx
f0103d35:	5e                   	pop    %esi
f0103d36:	5f                   	pop    %edi
f0103d37:	5d                   	pop    %ebp
f0103d38:	c3                   	ret    

f0103d39 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103d39:	55                   	push   %ebp
f0103d3a:	89 e5                	mov    %esp,%ebp
f0103d3c:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103d3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d42:	89 04 24             	mov    %eax,(%esp)
f0103d45:	e8 07 fe ff ff       	call   f0103b51 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103d4a:	c7 04 24 f4 6b 10 f0 	movl   $0xf0106bf4,(%esp)
f0103d51:	e8 14 01 00 00       	call   f0103e6a <cprintf>
	while (1)
		monitor(NULL);
f0103d56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103d5d:	e8 4a d1 ff ff       	call   f0100eac <monitor>
f0103d62:	eb f2                	jmp    f0103d56 <env_destroy+0x1d>

f0103d64 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d64:	55                   	push   %ebp
f0103d65:	89 e5                	mov    %esp,%ebp
f0103d67:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103d6a:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d6d:	61                   	popa   
f0103d6e:	07                   	pop    %es
f0103d6f:	1f                   	pop    %ds
f0103d70:	83 c4 08             	add    $0x8,%esp
f0103d73:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d74:	c7 44 24 08 e8 6b 10 	movl   $0xf0106be8,0x8(%esp)
f0103d7b:	f0 
f0103d7c:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
f0103d83:	00 
f0103d84:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103d8b:	e8 2e c3 ff ff       	call   f01000be <_panic>

f0103d90 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d90:	55                   	push   %ebp
f0103d91:	89 e5                	mov    %esp,%ebp
f0103d93:	83 ec 18             	sub    $0x18,%esp
f0103d96:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv && curenv->env_status == ENV_RUNNING) {
f0103d99:	8b 15 c8 01 18 f0    	mov    0xf01801c8,%edx
f0103d9f:	85 d2                	test   %edx,%edx
f0103da1:	74 0d                	je     f0103db0 <env_run+0x20>
f0103da3:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103da7:	75 07                	jne    f0103db0 <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0103da9:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	}
	curenv = e;
f0103db0:	a3 c8 01 18 f0       	mov    %eax,0xf01801c8
	curenv->env_status = ENV_RUNNING;
f0103db5:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs ++;
f0103dbc:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f0103dc0:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dc3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103dc9:	77 20                	ja     f0103deb <env_run+0x5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103dcf:	c7 44 24 08 10 5e 10 	movl   $0xf0105e10,0x8(%esp)
f0103dd6:	f0 
f0103dd7:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
f0103dde:	00 
f0103ddf:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f0103de6:	e8 d3 c2 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103deb:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103df1:	0f 22 da             	mov    %edx,%cr3

	env_pop_tf(&(curenv->env_tf));
f0103df4:	89 04 24             	mov    %eax,(%esp)
f0103df7:	e8 68 ff ff ff       	call   f0103d64 <env_pop_tf>

f0103dfc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103dfc:	55                   	push   %ebp
f0103dfd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103dff:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e04:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e07:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e08:	b2 71                	mov    $0x71,%dl
f0103e0a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e0b:	0f b6 c0             	movzbl %al,%eax
}
f0103e0e:	5d                   	pop    %ebp
f0103e0f:	c3                   	ret    

f0103e10 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e10:	55                   	push   %ebp
f0103e11:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e13:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e18:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e1b:	ee                   	out    %al,(%dx)
f0103e1c:	b2 71                	mov    $0x71,%dl
f0103e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e21:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e22:	5d                   	pop    %ebp
f0103e23:	c3                   	ret    

f0103e24 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
f0103e27:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103e2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e2d:	89 04 24             	mov    %eax,(%esp)
f0103e30:	e8 eb c7 ff ff       	call   f0100620 <cputchar>
	*cnt++;
}
f0103e35:	c9                   	leave  
f0103e36:	c3                   	ret    

f0103e37 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e37:	55                   	push   %ebp
f0103e38:	89 e5                	mov    %esp,%ebp
f0103e3a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103e3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e47:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e55:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e59:	c7 04 24 24 3e 10 f0 	movl   $0xf0103e24,(%esp)
f0103e60:	e8 d1 0c 00 00       	call   f0104b36 <vprintfmt>
	return cnt;
}
f0103e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e68:	c9                   	leave  
f0103e69:	c3                   	ret    

f0103e6a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e6a:	55                   	push   %ebp
f0103e6b:	89 e5                	mov    %esp,%ebp
f0103e6d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e70:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e77:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e7a:	89 04 24             	mov    %eax,(%esp)
f0103e7d:	e8 b5 ff ff ff       	call   f0103e37 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103e82:	c9                   	leave  
f0103e83:	c3                   	ret    
	...

f0103e90 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103e90:	55                   	push   %ebp
f0103e91:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103e93:	c7 05 e4 09 18 f0 00 	movl   $0xf0000000,0xf01809e4
f0103e9a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103e9d:	66 c7 05 e8 09 18 f0 	movw   $0x10,0xf01809e8
f0103ea4:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103ea6:	66 c7 05 68 d3 11 f0 	movw   $0x68,0xf011d368
f0103ead:	68 00 
f0103eaf:	b8 e0 09 18 f0       	mov    $0xf01809e0,%eax
f0103eb4:	66 a3 6a d3 11 f0    	mov    %ax,0xf011d36a
f0103eba:	89 c2                	mov    %eax,%edx
f0103ebc:	c1 ea 10             	shr    $0x10,%edx
f0103ebf:	88 15 6c d3 11 f0    	mov    %dl,0xf011d36c
f0103ec5:	c6 05 6e d3 11 f0 40 	movb   $0x40,0xf011d36e
f0103ecc:	c1 e8 18             	shr    $0x18,%eax
f0103ecf:	a2 6f d3 11 f0       	mov    %al,0xf011d36f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103ed4:	c6 05 6d d3 11 f0 89 	movb   $0x89,0xf011d36d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103edb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ee0:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103ee3:	b8 70 d3 11 f0       	mov    $0xf011d370,%eax
f0103ee8:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103eeb:	5d                   	pop    %ebp
f0103eec:	c3                   	ret    

f0103eed <trap_init>:
}


void
trap_init(void)
{
f0103eed:	55                   	push   %ebp
f0103eee:	89 e5                	mov    %esp,%ebp
f0103ef0:	53                   	push   %ebx
f0103ef1:	b9 01 00 00 00       	mov    $0x1,%ecx
f0103ef6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103efb:	eb 06                	jmp    f0103f03 <trap_init+0x16>
f0103efd:	83 c0 01             	add    $0x1,%eax
f0103f00:	83 c1 01             	add    $0x1,%ecx

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
		if (i==T_BRKPT)
f0103f03:	83 f8 03             	cmp    $0x3,%eax
f0103f06:	75 30                	jne    f0103f38 <trap_init+0x4b>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f0103f08:	8b 15 84 d3 11 f0    	mov    0xf011d384,%edx
f0103f0e:	66 89 15 f8 01 18 f0 	mov    %dx,0xf01801f8
f0103f15:	66 c7 05 fa 01 18 f0 	movw   $0x8,0xf01801fa
f0103f1c:	08 00 
f0103f1e:	c6 05 fc 01 18 f0 00 	movb   $0x0,0xf01801fc
f0103f25:	c6 05 fd 01 18 f0 ee 	movb   $0xee,0xf01801fd
f0103f2c:	c1 ea 10             	shr    $0x10,%edx
f0103f2f:	66 89 15 fe 01 18 f0 	mov    %dx,0xf01801fe
f0103f36:	eb c5                	jmp    f0103efd <trap_init+0x10>
		else if (i!=2 && i!=15) {
f0103f38:	83 f8 02             	cmp    $0x2,%eax
f0103f3b:	74 39                	je     f0103f76 <trap_init+0x89>
f0103f3d:	83 f8 0f             	cmp    $0xf,%eax
f0103f40:	74 34                	je     f0103f76 <trap_init+0x89>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0103f42:	8b 1c 85 78 d3 11 f0 	mov    -0xfee2c88(,%eax,4),%ebx
f0103f49:	66 89 1c c5 e0 01 18 	mov    %bx,-0xfe7fe20(,%eax,8)
f0103f50:	f0 
f0103f51:	66 c7 04 c5 e2 01 18 	movw   $0x8,-0xfe7fe1e(,%eax,8)
f0103f58:	f0 08 00 
f0103f5b:	c6 04 c5 e4 01 18 f0 	movb   $0x0,-0xfe7fe1c(,%eax,8)
f0103f62:	00 
f0103f63:	c6 04 c5 e5 01 18 f0 	movb   $0x8e,-0xfe7fe1b(,%eax,8)
f0103f6a:	8e 
f0103f6b:	c1 eb 10             	shr    $0x10,%ebx
f0103f6e:	66 89 1c c5 e6 01 18 	mov    %bx,-0xfe7fe1a(,%eax,8)
f0103f75:	f0 
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	int i;
	for (i = 0; i <= 16; ++i)
f0103f76:	83 f9 10             	cmp    $0x10,%ecx
f0103f79:	7e 82                	jle    f0103efd <trap_init+0x10>
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f0103f7b:	a1 38 d4 11 f0       	mov    0xf011d438,%eax
f0103f80:	66 a3 60 03 18 f0    	mov    %ax,0xf0180360
f0103f86:	66 c7 05 62 03 18 f0 	movw   $0x8,0xf0180362
f0103f8d:	08 00 
f0103f8f:	c6 05 64 03 18 f0 00 	movb   $0x0,0xf0180364
f0103f96:	c6 05 65 03 18 f0 ee 	movb   $0xee,0xf0180365
f0103f9d:	c1 e8 10             	shr    $0x10,%eax
f0103fa0:	66 a3 66 03 18 f0    	mov    %ax,0xf0180366

	// Per-CPU setup 
	trap_init_percpu();
f0103fa6:	e8 e5 fe ff ff       	call   f0103e90 <trap_init_percpu>
}
f0103fab:	5b                   	pop    %ebx
f0103fac:	5d                   	pop    %ebp
f0103fad:	c3                   	ret    

f0103fae <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103fae:	55                   	push   %ebp
f0103faf:	89 e5                	mov    %esp,%ebp
f0103fb1:	53                   	push   %ebx
f0103fb2:	83 ec 14             	sub    $0x14,%esp
f0103fb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103fb8:	8b 03                	mov    (%ebx),%eax
f0103fba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fbe:	c7 04 24 2a 6c 10 f0 	movl   $0xf0106c2a,(%esp)
f0103fc5:	e8 a0 fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103fca:	8b 43 04             	mov    0x4(%ebx),%eax
f0103fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fd1:	c7 04 24 39 6c 10 f0 	movl   $0xf0106c39,(%esp)
f0103fd8:	e8 8d fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103fdd:	8b 43 08             	mov    0x8(%ebx),%eax
f0103fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fe4:	c7 04 24 48 6c 10 f0 	movl   $0xf0106c48,(%esp)
f0103feb:	e8 7a fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ff0:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ff7:	c7 04 24 57 6c 10 f0 	movl   $0xf0106c57,(%esp)
f0103ffe:	e8 67 fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104003:	8b 43 10             	mov    0x10(%ebx),%eax
f0104006:	89 44 24 04          	mov    %eax,0x4(%esp)
f010400a:	c7 04 24 66 6c 10 f0 	movl   $0xf0106c66,(%esp)
f0104011:	e8 54 fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104016:	8b 43 14             	mov    0x14(%ebx),%eax
f0104019:	89 44 24 04          	mov    %eax,0x4(%esp)
f010401d:	c7 04 24 75 6c 10 f0 	movl   $0xf0106c75,(%esp)
f0104024:	e8 41 fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104029:	8b 43 18             	mov    0x18(%ebx),%eax
f010402c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104030:	c7 04 24 84 6c 10 f0 	movl   $0xf0106c84,(%esp)
f0104037:	e8 2e fe ff ff       	call   f0103e6a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010403c:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010403f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104043:	c7 04 24 93 6c 10 f0 	movl   $0xf0106c93,(%esp)
f010404a:	e8 1b fe ff ff       	call   f0103e6a <cprintf>
}
f010404f:	83 c4 14             	add    $0x14,%esp
f0104052:	5b                   	pop    %ebx
f0104053:	5d                   	pop    %ebp
f0104054:	c3                   	ret    

f0104055 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104055:	55                   	push   %ebp
f0104056:	89 e5                	mov    %esp,%ebp
f0104058:	56                   	push   %esi
f0104059:	53                   	push   %ebx
f010405a:	83 ec 10             	sub    $0x10,%esp
f010405d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0104060:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104064:	c7 04 24 e4 6d 10 f0 	movl   $0xf0106de4,(%esp)
f010406b:	e8 fa fd ff ff       	call   f0103e6a <cprintf>
	print_regs(&tf->tf_regs);
f0104070:	89 1c 24             	mov    %ebx,(%esp)
f0104073:	e8 36 ff ff ff       	call   f0103fae <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104078:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010407c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104080:	c7 04 24 e4 6c 10 f0 	movl   $0xf0106ce4,(%esp)
f0104087:	e8 de fd ff ff       	call   f0103e6a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010408c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104090:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104094:	c7 04 24 f7 6c 10 f0 	movl   $0xf0106cf7,(%esp)
f010409b:	e8 ca fd ff ff       	call   f0103e6a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040a0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01040a3:	83 f8 13             	cmp    $0x13,%eax
f01040a6:	77 09                	ja     f01040b1 <print_trapframe+0x5c>
		return excnames[trapno];
f01040a8:	8b 14 85 e0 6f 10 f0 	mov    -0xfef9020(,%eax,4),%edx
f01040af:	eb 10                	jmp    f01040c1 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f01040b1:	83 f8 30             	cmp    $0x30,%eax
f01040b4:	ba a2 6c 10 f0       	mov    $0xf0106ca2,%edx
f01040b9:	b9 ae 6c 10 f0       	mov    $0xf0106cae,%ecx
f01040be:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040c1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01040c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040c9:	c7 04 24 0a 6d 10 f0 	movl   $0xf0106d0a,(%esp)
f01040d0:	e8 95 fd ff ff       	call   f0103e6a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040d5:	3b 1d 48 0a 18 f0    	cmp    0xf0180a48,%ebx
f01040db:	75 19                	jne    f01040f6 <print_trapframe+0xa1>
f01040dd:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01040e1:	75 13                	jne    f01040f6 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01040e3:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01040e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040ea:	c7 04 24 1c 6d 10 f0 	movl   $0xf0106d1c,(%esp)
f01040f1:	e8 74 fd ff ff       	call   f0103e6a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01040f6:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040fd:	c7 04 24 2b 6d 10 f0 	movl   $0xf0106d2b,(%esp)
f0104104:	e8 61 fd ff ff       	call   f0103e6a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104109:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010410d:	75 51                	jne    f0104160 <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010410f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104112:	89 c2                	mov    %eax,%edx
f0104114:	83 e2 01             	and    $0x1,%edx
f0104117:	ba bd 6c 10 f0       	mov    $0xf0106cbd,%edx
f010411c:	b9 c8 6c 10 f0       	mov    $0xf0106cc8,%ecx
f0104121:	0f 45 ca             	cmovne %edx,%ecx
f0104124:	89 c2                	mov    %eax,%edx
f0104126:	83 e2 02             	and    $0x2,%edx
f0104129:	ba d4 6c 10 f0       	mov    $0xf0106cd4,%edx
f010412e:	be da 6c 10 f0       	mov    $0xf0106cda,%esi
f0104133:	0f 44 d6             	cmove  %esi,%edx
f0104136:	83 e0 04             	and    $0x4,%eax
f0104139:	b8 df 6c 10 f0       	mov    $0xf0106cdf,%eax
f010413e:	be 38 6e 10 f0       	mov    $0xf0106e38,%esi
f0104143:	0f 44 c6             	cmove  %esi,%eax
f0104146:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010414a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010414e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104152:	c7 04 24 39 6d 10 f0 	movl   $0xf0106d39,(%esp)
f0104159:	e8 0c fd ff ff       	call   f0103e6a <cprintf>
f010415e:	eb 0c                	jmp    f010416c <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104160:	c7 04 24 24 6e 10 f0 	movl   $0xf0106e24,(%esp)
f0104167:	e8 fe fc ff ff       	call   f0103e6a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010416c:	8b 43 30             	mov    0x30(%ebx),%eax
f010416f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104173:	c7 04 24 48 6d 10 f0 	movl   $0xf0106d48,(%esp)
f010417a:	e8 eb fc ff ff       	call   f0103e6a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010417f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104183:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104187:	c7 04 24 57 6d 10 f0 	movl   $0xf0106d57,(%esp)
f010418e:	e8 d7 fc ff ff       	call   f0103e6a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104193:	8b 43 38             	mov    0x38(%ebx),%eax
f0104196:	89 44 24 04          	mov    %eax,0x4(%esp)
f010419a:	c7 04 24 6a 6d 10 f0 	movl   $0xf0106d6a,(%esp)
f01041a1:	e8 c4 fc ff ff       	call   f0103e6a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01041a6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01041aa:	74 27                	je     f01041d3 <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01041ac:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01041af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041b3:	c7 04 24 79 6d 10 f0 	movl   $0xf0106d79,(%esp)
f01041ba:	e8 ab fc ff ff       	call   f0103e6a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01041bf:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01041c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041c7:	c7 04 24 88 6d 10 f0 	movl   $0xf0106d88,(%esp)
f01041ce:	e8 97 fc ff ff       	call   f0103e6a <cprintf>
	}
}
f01041d3:	83 c4 10             	add    $0x10,%esp
f01041d6:	5b                   	pop    %ebx
f01041d7:	5e                   	pop    %esi
f01041d8:	5d                   	pop    %ebp
f01041d9:	c3                   	ret    

f01041da <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01041da:	55                   	push   %ebp
f01041db:	89 e5                	mov    %esp,%ebp
f01041dd:	83 ec 18             	sub    $0x18,%esp
f01041e0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01041e3:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01041e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01041e9:	0f 20 d3             	mov    %cr2,%ebx
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0){
f01041ec:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01041f0:	75 28                	jne    f010421a <page_fault_handler+0x40>
		print_trapframe(tf);
f01041f2:	89 34 24             	mov    %esi,(%esp)
f01041f5:	e8 5b fe ff ff       	call   f0104055 <print_trapframe>
		panic("kernel page fault va: %08x", fault_va);
f01041fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01041fe:	c7 44 24 08 9b 6d 10 	movl   $0xf0106d9b,0x8(%esp)
f0104205:	f0 
f0104206:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f010420d:	00 
f010420e:	c7 04 24 b6 6d 10 f0 	movl   $0xf0106db6,(%esp)
f0104215:	e8 a4 be ff ff       	call   f01000be <_panic>
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010421a:	8b 46 30             	mov    0x30(%esi),%eax
f010421d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104221:	89 5c 24 08          	mov    %ebx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104225:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010422a:	8b 40 48             	mov    0x48(%eax),%eax
f010422d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104231:	c7 04 24 84 6f 10 f0 	movl   $0xf0106f84,(%esp)
f0104238:	e8 2d fc ff ff       	call   f0103e6a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010423d:	89 34 24             	mov    %esi,(%esp)
f0104240:	e8 10 fe ff ff       	call   f0104055 <print_trapframe>
	env_destroy(curenv);
f0104245:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f010424a:	89 04 24             	mov    %eax,(%esp)
f010424d:	e8 e7 fa ff ff       	call   f0103d39 <env_destroy>
}
f0104252:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0104255:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0104258:	89 ec                	mov    %ebp,%esp
f010425a:	5d                   	pop    %ebp
f010425b:	c3                   	ret    

f010425c <breakpoint_handler>:

void
breakpoint_handler(struct Trapframe *tf) {
f010425c:	55                   	push   %ebp
f010425d:	89 e5                	mov    %esp,%ebp
f010425f:	53                   	push   %ebx
f0104260:	83 ec 14             	sub    $0x14,%esp
f0104263:	8b 5d 08             	mov    0x8(%ebp),%ebx
	print_trapframe(tf);
f0104266:	89 1c 24             	mov    %ebx,(%esp)
f0104269:	e8 e7 fd ff ff       	call   f0104055 <print_trapframe>
	monitor(tf);
f010426e:	89 1c 24             	mov    %ebx,(%esp)
f0104271:	e8 36 cc ff ff       	call   f0100eac <monitor>
	return;
}
f0104276:	83 c4 14             	add    $0x14,%esp
f0104279:	5b                   	pop    %ebx
f010427a:	5d                   	pop    %ebp
f010427b:	c3                   	ret    

f010427c <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010427c:	55                   	push   %ebp
f010427d:	89 e5                	mov    %esp,%ebp
f010427f:	57                   	push   %edi
f0104280:	56                   	push   %esi
f0104281:	83 ec 20             	sub    $0x20,%esp
f0104284:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104287:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104288:	9c                   	pushf  
f0104289:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010428a:	f6 c4 02             	test   $0x2,%ah
f010428d:	74 24                	je     f01042b3 <trap+0x37>
f010428f:	c7 44 24 0c c2 6d 10 	movl   $0xf0106dc2,0xc(%esp)
f0104296:	f0 
f0104297:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f010429e:	f0 
f010429f:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
f01042a6:	00 
f01042a7:	c7 04 24 b6 6d 10 f0 	movl   $0xf0106db6,(%esp)
f01042ae:	e8 0b be ff ff       	call   f01000be <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01042b3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042b7:	c7 04 24 db 6d 10 f0 	movl   $0xf0106ddb,(%esp)
f01042be:	e8 a7 fb ff ff       	call   f0103e6a <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01042c3:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01042c7:	83 e0 03             	and    $0x3,%eax
f01042ca:	83 f8 03             	cmp    $0x3,%eax
f01042cd:	75 3c                	jne    f010430b <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f01042cf:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01042d4:	85 c0                	test   %eax,%eax
f01042d6:	75 24                	jne    f01042fc <trap+0x80>
f01042d8:	c7 44 24 0c f6 6d 10 	movl   $0xf0106df6,0xc(%esp)
f01042df:	f0 
f01042e0:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01042e7:	f0 
f01042e8:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f01042ef:	00 
f01042f0:	c7 04 24 b6 6d 10 f0 	movl   $0xf0106db6,(%esp)
f01042f7:	e8 c2 bd ff ff       	call   f01000be <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01042fc:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104301:	89 c7                	mov    %eax,%edi
f0104303:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104305:	8b 35 c8 01 18 f0    	mov    0xf01801c8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010430b:	89 35 48 0a 18 f0    	mov    %esi,0xf0180a48
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT) {
f0104311:	8b 46 28             	mov    0x28(%esi),%eax
f0104314:	83 f8 0e             	cmp    $0xe,%eax
f0104317:	75 19                	jne    f0104332 <trap+0xb6>
		cprintf("PAGE FAULT!\n");
f0104319:	c7 04 24 fd 6d 10 f0 	movl   $0xf0106dfd,(%esp)
f0104320:	e8 45 fb ff ff       	call   f0103e6a <cprintf>
		page_fault_handler(tf);
f0104325:	89 34 24             	mov    %esi,(%esp)
f0104328:	e8 ad fe ff ff       	call   f01041da <page_fault_handler>
f010432d:	e9 96 00 00 00       	jmp    f01043c8 <trap+0x14c>
		return;
	}

	if(tf->tf_trapno == T_BRKPT) {
f0104332:	83 f8 03             	cmp    $0x3,%eax
f0104335:	75 16                	jne    f010434d <trap+0xd1>
		cprintf("BREAK POINT!\n");
f0104337:	c7 04 24 0a 6e 10 f0 	movl   $0xf0106e0a,(%esp)
f010433e:	e8 27 fb ff ff       	call   f0103e6a <cprintf>
		breakpoint_handler(tf);
f0104343:	89 34 24             	mov    %esi,(%esp)
f0104346:	e8 11 ff ff ff       	call   f010425c <breakpoint_handler>
f010434b:	eb 7b                	jmp    f01043c8 <trap+0x14c>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
f010434d:	83 f8 30             	cmp    $0x30,%eax
f0104350:	75 3e                	jne    f0104390 <trap+0x114>
		cprintf("SYSTEM CALL!\n");
f0104352:	c7 04 24 18 6e 10 f0 	movl   $0xf0106e18,(%esp)
f0104359:	e8 0c fb ff ff       	call   f0103e6a <cprintf>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010435e:	8b 46 04             	mov    0x4(%esi),%eax
f0104361:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104365:	8b 06                	mov    (%esi),%eax
f0104367:	89 44 24 10          	mov    %eax,0x10(%esp)
f010436b:	8b 46 10             	mov    0x10(%esi),%eax
f010436e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104372:	8b 46 18             	mov    0x18(%esi),%eax
f0104375:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104379:	8b 46 14             	mov    0x14(%esi),%eax
f010437c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104380:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104383:	89 04 24             	mov    %eax,(%esp)
f0104386:	e8 e5 00 00 00       	call   f0104470 <syscall>
		return;
	}

	if(tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL!\n");
		tf->tf_regs.reg_eax = 
f010438b:	89 46 1c             	mov    %eax,0x1c(%esi)
f010438e:	eb 38                	jmp    f01043c8 <trap+0x14c>
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104390:	89 34 24             	mov    %esi,(%esp)
f0104393:	e8 bd fc ff ff       	call   f0104055 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104398:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010439d:	75 1c                	jne    f01043bb <trap+0x13f>
		panic("unhandled trap in kernel");
f010439f:	c7 44 24 08 26 6e 10 	movl   $0xf0106e26,0x8(%esp)
f01043a6:	f0 
f01043a7:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f01043ae:	00 
f01043af:	c7 04 24 b6 6d 10 f0 	movl   $0xf0106db6,(%esp)
f01043b6:	e8 03 bd ff ff       	call   f01000be <_panic>
	else {
		env_destroy(curenv);
f01043bb:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01043c0:	89 04 24             	mov    %eax,(%esp)
f01043c3:	e8 71 f9 ff ff       	call   f0103d39 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01043c8:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01043cd:	85 c0                	test   %eax,%eax
f01043cf:	74 06                	je     f01043d7 <trap+0x15b>
f01043d1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01043d5:	74 24                	je     f01043fb <trap+0x17f>
f01043d7:	c7 44 24 0c a8 6f 10 	movl   $0xf0106fa8,0xc(%esp)
f01043de:	f0 
f01043df:	c7 44 24 08 c3 68 10 	movl   $0xf01068c3,0x8(%esp)
f01043e6:	f0 
f01043e7:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f01043ee:	00 
f01043ef:	c7 04 24 b6 6d 10 f0 	movl   $0xf0106db6,(%esp)
f01043f6:	e8 c3 bc ff ff       	call   f01000be <_panic>
	env_run(curenv);
f01043fb:	89 04 24             	mov    %eax,(%esp)
f01043fe:	e8 8d f9 ff ff       	call   f0103d90 <env_run>
	...

f0104404 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec_entry(th0, 0)
f0104404:	6a 00                	push   $0x0
f0104406:	6a 00                	push   $0x0
f0104408:	eb 4e                	jmp    f0104458 <_alltraps>

f010440a <th1>:
	noec_entry(th1, 1)
f010440a:	6a 00                	push   $0x0
f010440c:	6a 01                	push   $0x1
f010440e:	eb 48                	jmp    f0104458 <_alltraps>

f0104410 <th3>:
	reserved_entry()
	noec_entry(th3, 3)
f0104410:	6a 00                	push   $0x0
f0104412:	6a 03                	push   $0x3
f0104414:	eb 42                	jmp    f0104458 <_alltraps>

f0104416 <th4>:
	noec_entry(th4, 4)
f0104416:	6a 00                	push   $0x0
f0104418:	6a 04                	push   $0x4
f010441a:	eb 3c                	jmp    f0104458 <_alltraps>

f010441c <th5>:
	noec_entry(th5, 5)
f010441c:	6a 00                	push   $0x0
f010441e:	6a 05                	push   $0x5
f0104420:	eb 36                	jmp    f0104458 <_alltraps>

f0104422 <th6>:
	noec_entry(th6, 6)
f0104422:	6a 00                	push   $0x0
f0104424:	6a 06                	push   $0x6
f0104426:	eb 30                	jmp    f0104458 <_alltraps>

f0104428 <th7>:
	noec_entry(th7, 7)
f0104428:	6a 00                	push   $0x0
f010442a:	6a 07                	push   $0x7
f010442c:	eb 2a                	jmp    f0104458 <_alltraps>

f010442e <th8>:
	ec_entry(th8, 8)
f010442e:	6a 08                	push   $0x8
f0104430:	eb 26                	jmp    f0104458 <_alltraps>

f0104432 <th9>:
	noec_entry(th9, 9)
f0104432:	6a 00                	push   $0x0
f0104434:	6a 09                	push   $0x9
f0104436:	eb 20                	jmp    f0104458 <_alltraps>

f0104438 <th10>:
	ec_entry(th10, 10)
f0104438:	6a 0a                	push   $0xa
f010443a:	eb 1c                	jmp    f0104458 <_alltraps>

f010443c <th11>:
	ec_entry(th11, 11)
f010443c:	6a 0b                	push   $0xb
f010443e:	eb 18                	jmp    f0104458 <_alltraps>

f0104440 <th12>:
	ec_entry(th12, 12)
f0104440:	6a 0c                	push   $0xc
f0104442:	eb 14                	jmp    f0104458 <_alltraps>

f0104444 <th13>:
	ec_entry(th13, 13)
f0104444:	6a 0d                	push   $0xd
f0104446:	eb 10                	jmp    f0104458 <_alltraps>

f0104448 <th14>:
	ec_entry(th14, 14)
f0104448:	6a 0e                	push   $0xe
f010444a:	eb 0c                	jmp    f0104458 <_alltraps>

f010444c <th16>:
	reserved_entry()
	noec_entry(th16, 16)
f010444c:	6a 00                	push   $0x0
f010444e:	6a 10                	push   $0x10
f0104450:	eb 06                	jmp    f0104458 <_alltraps>

f0104452 <th48>:
.data
	.space 124
.text
	noec_entry(th48, 48)
f0104452:	6a 00                	push   $0x0
f0104454:	6a 30                	push   $0x30
f0104456:	eb 00                	jmp    f0104458 <_alltraps>

f0104458 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104458:	1e                   	push   %ds
	pushl %es
f0104459:	06                   	push   %es
	pushal
f010445a:	60                   	pusha  
	pushl $GD_KD
f010445b:	6a 10                	push   $0x10
	popl %ds
f010445d:	1f                   	pop    %ds
	pushl $GD_KD
f010445e:	6a 10                	push   $0x10
	popl %es
f0104460:	07                   	pop    %es
	pushl %esp
f0104461:	54                   	push   %esp
	call trap
f0104462:	e8 15 fe ff ff       	call   f010427c <trap>
	...

f0104470 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104470:	55                   	push   %ebp
f0104471:	89 e5                	mov    %esp,%ebp
f0104473:	83 ec 28             	sub    $0x28,%esp
f0104476:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0104479:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010447c:	8b 45 08             	mov    0x8(%ebp),%eax
f010447f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104482:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno){
f0104485:	83 f8 01             	cmp    $0x1,%eax
f0104488:	74 5f                	je     f01044e9 <syscall+0x79>
f010448a:	83 f8 01             	cmp    $0x1,%eax
f010448d:	72 13                	jb     f01044a2 <syscall+0x32>
f010448f:	83 f8 02             	cmp    $0x2,%eax
f0104492:	74 6b                	je     f01044ff <syscall+0x8f>
f0104494:	83 f8 03             	cmp    $0x3,%eax
f0104497:	0f 85 ed 00 00 00    	jne    f010458a <syscall+0x11a>
f010449d:	8d 76 00             	lea    0x0(%esi),%esi
f01044a0:	eb 73                	jmp    f0104515 <syscall+0xa5>
		case SYS_cputs:
			cprintf("SYS_cputs\n");
f01044a2:	c7 04 24 30 70 10 f0 	movl   $0xf0107030,(%esp)
f01044a9:	e8 bc f9 ff ff       	call   f0103e6a <cprintf>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,(void *)s, len, PTE_U | PTE_P);
f01044ae:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01044b5:	00 
f01044b6:	89 74 24 08          	mov    %esi,0x8(%esp)
f01044ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044be:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01044c3:	89 04 24             	mov    %eax,(%esp)
f01044c6:	e8 d3 f1 ff ff       	call   f010369e <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01044cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01044cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01044d3:	c7 04 24 3b 70 10 f0 	movl   $0xf010703b,(%esp)
f01044da:	e8 8b f9 ff ff       	call   f0103e6a <cprintf>
	// LAB 3: Your code here.
	switch (syscallno){
		case SYS_cputs:
			cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
f01044df:	b8 00 00 00 00       	mov    $0x0,%eax
f01044e4:	e9 a6 00 00 00       	jmp    f010458f <syscall+0x11f>
		case SYS_cgetc:
			cprintf("SYS_cgetc\n");
f01044e9:	c7 04 24 40 70 10 f0 	movl   $0xf0107040,(%esp)
f01044f0:	e8 75 f9 ff ff       	call   f0103e6a <cprintf>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01044f5:	e8 ee bf ff ff       	call   f01004e8 <cons_getc>
			cprintf("SYS_cputs\n");
			sys_cputs((char*)a1, a2);
			return 0;
		case SYS_cgetc:
			cprintf("SYS_cgetc\n");
			return sys_cgetc();
f01044fa:	e9 90 00 00 00       	jmp    f010458f <syscall+0x11f>
		case SYS_getenvid:
			cprintf("SYS_getenvid\n");
f01044ff:	c7 04 24 4b 70 10 f0 	movl   $0xf010704b,(%esp)
f0104506:	e8 5f f9 ff ff       	call   f0103e6a <cprintf>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010450b:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f0104510:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			cprintf("SYS_cgetc\n");
			return sys_cgetc();
		case SYS_getenvid:
			cprintf("SYS_getenvid\n");
			return sys_getenvid();
f0104513:	eb 7a                	jmp    f010458f <syscall+0x11f>
		case SYS_env_destroy:
			cprintf("SYS_env_destroy\n");
f0104515:	c7 04 24 59 70 10 f0 	movl   $0xf0107059,(%esp)
f010451c:	e8 49 f9 ff ff       	call   f0103e6a <cprintf>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104521:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104528:	00 
f0104529:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010452c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104530:	89 1c 24             	mov    %ebx,(%esp)
f0104533:	e8 45 f2 ff ff       	call   f010377d <envid2env>
f0104538:	85 c0                	test   %eax,%eax
f010453a:	78 53                	js     f010458f <syscall+0x11f>
		return r;
	if (e == curenv)
f010453c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010453f:	8b 15 c8 01 18 f0    	mov    0xf01801c8,%edx
f0104545:	39 d0                	cmp    %edx,%eax
f0104547:	75 15                	jne    f010455e <syscall+0xee>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104549:	8b 40 48             	mov    0x48(%eax),%eax
f010454c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104550:	c7 04 24 6a 70 10 f0 	movl   $0xf010706a,(%esp)
f0104557:	e8 0e f9 ff ff       	call   f0103e6a <cprintf>
f010455c:	eb 1a                	jmp    f0104578 <syscall+0x108>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010455e:	8b 40 48             	mov    0x48(%eax),%eax
f0104561:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104565:	8b 42 48             	mov    0x48(%edx),%eax
f0104568:	89 44 24 04          	mov    %eax,0x4(%esp)
f010456c:	c7 04 24 85 70 10 f0 	movl   $0xf0107085,(%esp)
f0104573:	e8 f2 f8 ff ff       	call   f0103e6a <cprintf>
	env_destroy(e);
f0104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010457b:	89 04 24             	mov    %eax,(%esp)
f010457e:	e8 b6 f7 ff ff       	call   f0103d39 <env_destroy>
	return 0;
f0104583:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_getenvid:
			cprintf("SYS_getenvid\n");
			return sys_getenvid();
		case SYS_env_destroy:
			cprintf("SYS_env_destroy\n");
			return sys_env_destroy(a1);
f0104588:	eb 05                	jmp    f010458f <syscall+0x11f>
		default: 
			return -E_INVAL;
f010458a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f010458f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0104592:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0104595:	89 ec                	mov    %ebp,%esp
f0104597:	5d                   	pop    %ebp
f0104598:	c3                   	ret    
f0104599:	00 00                	add    %al,(%eax)
	...

f010459c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010459c:	55                   	push   %ebp
f010459d:	89 e5                	mov    %esp,%ebp
f010459f:	57                   	push   %edi
f01045a0:	56                   	push   %esi
f01045a1:	53                   	push   %ebx
f01045a2:	83 ec 14             	sub    $0x14,%esp
f01045a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045a8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01045ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01045ae:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01045b1:	8b 1a                	mov    (%edx),%ebx
f01045b3:	8b 01                	mov    (%ecx),%eax
f01045b5:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f01045b8:	39 c3                	cmp    %eax,%ebx
f01045ba:	0f 8f 9c 00 00 00    	jg     f010465c <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01045c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01045c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01045ca:	01 d8                	add    %ebx,%eax
f01045cc:	89 c7                	mov    %eax,%edi
f01045ce:	c1 ef 1f             	shr    $0x1f,%edi
f01045d1:	01 c7                	add    %eax,%edi
f01045d3:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01045d5:	39 df                	cmp    %ebx,%edi
f01045d7:	7c 33                	jl     f010460c <stab_binsearch+0x70>
f01045d9:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01045dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01045df:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01045e4:	39 f0                	cmp    %esi,%eax
f01045e6:	0f 84 bc 00 00 00    	je     f01046a8 <stab_binsearch+0x10c>
f01045ec:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01045f0:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01045f4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01045f6:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01045f9:	39 d8                	cmp    %ebx,%eax
f01045fb:	7c 0f                	jl     f010460c <stab_binsearch+0x70>
f01045fd:	0f b6 0a             	movzbl (%edx),%ecx
f0104600:	83 ea 0c             	sub    $0xc,%edx
f0104603:	39 f1                	cmp    %esi,%ecx
f0104605:	75 ef                	jne    f01045f6 <stab_binsearch+0x5a>
f0104607:	e9 9e 00 00 00       	jmp    f01046aa <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010460c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010460f:	eb 3c                	jmp    f010464d <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104611:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104614:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0104616:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104619:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104620:	eb 2b                	jmp    f010464d <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104622:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104625:	76 14                	jbe    f010463b <stab_binsearch+0x9f>
			*region_right = m - 1;
f0104627:	83 e8 01             	sub    $0x1,%eax
f010462a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010462d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104630:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104632:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104639:	eb 12                	jmp    f010464d <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010463b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010463e:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0104640:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104644:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104646:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010464d:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104650:	0f 8d 71 ff ff ff    	jge    f01045c7 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104656:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010465a:	75 0f                	jne    f010466b <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f010465c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010465f:	8b 02                	mov    (%edx),%eax
f0104661:	83 e8 01             	sub    $0x1,%eax
f0104664:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104667:	89 01                	mov    %eax,(%ecx)
f0104669:	eb 57                	jmp    f01046c2 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010466b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010466e:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104670:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104673:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104675:	39 c1                	cmp    %eax,%ecx
f0104677:	7d 28                	jge    f01046a1 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0104679:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010467c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f010467f:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104684:	39 f2                	cmp    %esi,%edx
f0104686:	74 19                	je     f01046a1 <stab_binsearch+0x105>
f0104688:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010468c:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104690:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104693:	39 c1                	cmp    %eax,%ecx
f0104695:	7d 0a                	jge    f01046a1 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0104697:	0f b6 1a             	movzbl (%edx),%ebx
f010469a:	83 ea 0c             	sub    $0xc,%edx
f010469d:	39 f3                	cmp    %esi,%ebx
f010469f:	75 ef                	jne    f0104690 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01046a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01046a4:	89 02                	mov    %eax,(%edx)
f01046a6:	eb 1a                	jmp    f01046c2 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01046a8:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01046aa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046ad:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01046b0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01046b4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01046b7:	0f 82 54 ff ff ff    	jb     f0104611 <stab_binsearch+0x75>
f01046bd:	e9 60 ff ff ff       	jmp    f0104622 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01046c2:	83 c4 14             	add    $0x14,%esp
f01046c5:	5b                   	pop    %ebx
f01046c6:	5e                   	pop    %esi
f01046c7:	5f                   	pop    %edi
f01046c8:	5d                   	pop    %ebp
f01046c9:	c3                   	ret    

f01046ca <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01046ca:	55                   	push   %ebp
f01046cb:	89 e5                	mov    %esp,%ebp
f01046cd:	57                   	push   %edi
f01046ce:	56                   	push   %esi
f01046cf:	53                   	push   %ebx
f01046d0:	83 ec 5c             	sub    $0x5c,%esp
f01046d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01046d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01046d9:	c7 03 9d 70 10 f0    	movl   $0xf010709d,(%ebx)
	info->eip_line = 0;
f01046df:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01046e6:	c7 43 08 9d 70 10 f0 	movl   $0xf010709d,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01046ed:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01046f4:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01046f7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01046fe:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104704:	0f 87 bd 00 00 00    	ja     f01047c7 <debuginfo_eip+0xfd>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010470a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104711:	00 
f0104712:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0104719:	00 
f010471a:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0104721:	00 
f0104722:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f0104727:	89 04 24             	mov    %eax,(%esp)
f010472a:	e8 9b ee ff ff       	call   f01035ca <user_mem_check>
f010472f:	89 c2                	mov    %eax,%edx
			return -1;
f0104731:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104736:	85 d2                	test   %edx,%edx
f0104738:	0f 85 93 02 00 00    	jne    f01049d1 <debuginfo_eip+0x307>
			return -1;

		stabs = usd->stabs;
f010473e:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0104744:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104747:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010474d:	a1 08 00 20 00       	mov    0x200008,%eax
f0104752:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104755:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010475b:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010475e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104765:	00 
f0104766:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f010476d:	00 
f010476e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104771:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104775:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f010477a:	89 04 24             	mov    %eax,(%esp)
f010477d:	e8 48 ee ff ff       	call   f01035ca <user_mem_check>
f0104782:	89 c2                	mov    %eax,%edx
			return -1;
f0104784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104789:	85 d2                	test   %edx,%edx
f010478b:	0f 85 40 02 00 00    	jne    f01049d1 <debuginfo_eip+0x307>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104791:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104798:	00 
f0104799:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010479c:	2b 45 bc             	sub    -0x44(%ebp),%eax
f010479f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047a3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01047a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047aa:	a1 c8 01 18 f0       	mov    0xf01801c8,%eax
f01047af:	89 04 24             	mov    %eax,(%esp)
f01047b2:	e8 13 ee ff ff       	call   f01035ca <user_mem_check>
f01047b7:	89 c2                	mov    %eax,%edx
			return -1;
f01047b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// LAB 3: Your code here.
		
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f01047be:	85 d2                	test   %edx,%edx
f01047c0:	74 1f                	je     f01047e1 <debuginfo_eip+0x117>
f01047c2:	e9 0a 02 00 00       	jmp    f01049d1 <debuginfo_eip+0x307>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01047c7:	c7 45 c0 10 2e 11 f0 	movl   $0xf0112e10,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01047ce:	c7 45 bc 75 01 11 f0 	movl   $0xf0110175,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01047d5:	bf 74 01 11 f0       	mov    $0xf0110174,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01047da:	c7 45 c4 d0 72 10 f0 	movl   $0xf01072d0,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01047e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01047e6:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01047e9:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f01047ec:	0f 83 df 01 00 00    	jae    f01049d1 <debuginfo_eip+0x307>
f01047f2:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f01047f6:	0f 85 d5 01 00 00    	jne    f01049d1 <debuginfo_eip+0x307>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01047fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104803:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104806:	c1 ff 02             	sar    $0x2,%edi
f0104809:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f010480f:	83 e8 01             	sub    $0x1,%eax
f0104812:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104815:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104819:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104820:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104823:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104826:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104829:	e8 6e fd ff ff       	call   f010459c <stab_binsearch>
	if (lfile == 0)
f010482e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0104831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0104836:	85 d2                	test   %edx,%edx
f0104838:	0f 84 93 01 00 00    	je     f01049d1 <debuginfo_eip+0x307>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010483e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0104841:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104844:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104847:	89 74 24 04          	mov    %esi,0x4(%esp)
f010484b:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104852:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104855:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104858:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010485b:	e8 3c fd ff ff       	call   f010459c <stab_binsearch>

	if (lfun <= rfun) {
f0104860:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104863:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104866:	39 d0                	cmp    %edx,%eax
f0104868:	7f 32                	jg     f010489c <debuginfo_eip+0x1d2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010486a:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010486d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104870:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0104873:	8b 39                	mov    (%ecx),%edi
f0104875:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0104878:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010487b:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010487e:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104881:	73 09                	jae    f010488c <debuginfo_eip+0x1c2>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104883:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104886:	03 7d bc             	add    -0x44(%ebp),%edi
f0104889:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010488c:	8b 49 08             	mov    0x8(%ecx),%ecx
f010488f:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104892:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104894:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104897:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010489a:	eb 0f                	jmp    f01048ab <debuginfo_eip+0x1e1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010489c:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010489f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01048a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01048ab:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01048b2:	00 
f01048b3:	8b 43 08             	mov    0x8(%ebx),%eax
f01048b6:	89 04 24             	mov    %eax,(%esp)
f01048b9:	e8 8c 0a 00 00       	call   f010534a <strfind>
f01048be:	2b 43 08             	sub    0x8(%ebx),%eax
f01048c1:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01048c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01048c8:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01048cf:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01048d2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01048d5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01048d8:	e8 bf fc ff ff       	call   f010459c <stab_binsearch>

	if(lline <= rline)
f01048dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f01048e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f01048e5:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01048e8:	0f 8f e3 00 00 00    	jg     f01049d1 <debuginfo_eip+0x307>
		info->eip_line = stabs[lline].n_desc;
f01048ee:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01048f1:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01048f4:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01048f9:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01048fc:	89 d0                	mov    %edx,%eax
f01048fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104901:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0104904:	39 fa                	cmp    %edi,%edx
f0104906:	7c 74                	jl     f010497c <debuginfo_eip+0x2b2>
	       && stabs[lline].n_type != N_SOL
f0104908:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010490b:	89 f7                	mov    %esi,%edi
f010490d:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0104910:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f0104914:	80 f9 84             	cmp    $0x84,%cl
f0104917:	74 46                	je     f010495f <debuginfo_eip+0x295>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104919:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f010491d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104920:	89 c7                	mov    %eax,%edi
f0104922:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0104925:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0104928:	eb 1f                	jmp    f0104949 <debuginfo_eip+0x27f>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010492a:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010492d:	39 c3                	cmp    %eax,%ebx
f010492f:	7f 48                	jg     f0104979 <debuginfo_eip+0x2af>
	       && stabs[lline].n_type != N_SOL
f0104931:	89 d6                	mov    %edx,%esi
f0104933:	83 ea 0c             	sub    $0xc,%edx
f0104936:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f010493a:	80 f9 84             	cmp    $0x84,%cl
f010493d:	75 08                	jne    f0104947 <debuginfo_eip+0x27d>
f010493f:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0104942:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104945:	eb 18                	jmp    f010495f <debuginfo_eip+0x295>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104947:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104949:	80 f9 64             	cmp    $0x64,%cl
f010494c:	75 dc                	jne    f010492a <debuginfo_eip+0x260>
f010494e:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0104952:	74 d6                	je     f010492a <debuginfo_eip+0x260>
f0104954:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0104957:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010495a:	3b 45 b8             	cmp    -0x48(%ebp),%eax
f010495d:	7c 1d                	jl     f010497c <debuginfo_eip+0x2b2>
f010495f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104962:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104965:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0104968:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010496b:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010496e:	39 d0                	cmp    %edx,%eax
f0104970:	73 0a                	jae    f010497c <debuginfo_eip+0x2b2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104972:	03 45 bc             	add    -0x44(%ebp),%eax
f0104975:	89 03                	mov    %eax,(%ebx)
f0104977:	eb 03                	jmp    f010497c <debuginfo_eip+0x2b2>
f0104979:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010497c:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010497f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104982:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104985:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010498a:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f010498d:	7d 42                	jge    f01049d1 <debuginfo_eip+0x307>
		for (lline = lfun + 1;
f010498f:	8d 57 01             	lea    0x1(%edi),%edx
f0104992:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104995:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0104998:	7e 37                	jle    f01049d1 <debuginfo_eip+0x307>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010499a:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f010499d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01049a0:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f01049a5:	75 2a                	jne    f01049d1 <debuginfo_eip+0x307>
f01049a7:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01049aa:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f01049ae:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01049b1:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01049b5:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01049b8:	39 d1                	cmp    %edx,%ecx
f01049ba:	7e 10                	jle    f01049cc <debuginfo_eip+0x302>
f01049bc:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01049bf:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f01049c3:	74 ec                	je     f01049b1 <debuginfo_eip+0x2e7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01049c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01049ca:	eb 05                	jmp    f01049d1 <debuginfo_eip+0x307>
f01049cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01049d1:	83 c4 5c             	add    $0x5c,%esp
f01049d4:	5b                   	pop    %ebx
f01049d5:	5e                   	pop    %esi
f01049d6:	5f                   	pop    %edi
f01049d7:	5d                   	pop    %ebp
f01049d8:	c3                   	ret    
f01049d9:	00 00                	add    %al,(%eax)
	...

f01049dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01049dc:	55                   	push   %ebp
f01049dd:	89 e5                	mov    %esp,%ebp
f01049df:	57                   	push   %edi
f01049e0:	56                   	push   %esi
f01049e1:	53                   	push   %ebx
f01049e2:	83 ec 3c             	sub    $0x3c,%esp
f01049e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049e8:	89 d7                	mov    %edx,%edi
f01049ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01049f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01049f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01049f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01049fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a01:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0104a04:	72 11                	jb     f0104a17 <printnum+0x3b>
f0104a06:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a09:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104a0c:	76 09                	jbe    f0104a17 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104a0e:	83 eb 01             	sub    $0x1,%ebx
f0104a11:	85 db                	test   %ebx,%ebx
f0104a13:	7f 51                	jg     f0104a66 <printnum+0x8a>
f0104a15:	eb 5e                	jmp    f0104a75 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104a17:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104a1b:	83 eb 01             	sub    $0x1,%ebx
f0104a1e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104a22:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a29:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0104a2d:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0104a31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104a38:	00 
f0104a39:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a3c:	89 04 24             	mov    %eax,(%esp)
f0104a3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a46:	e8 75 0b 00 00       	call   f01055c0 <__udivdi3>
f0104a4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a4f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104a53:	89 04 24             	mov    %eax,(%esp)
f0104a56:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a5a:	89 fa                	mov    %edi,%edx
f0104a5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a5f:	e8 78 ff ff ff       	call   f01049dc <printnum>
f0104a64:	eb 0f                	jmp    f0104a75 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104a66:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a6a:	89 34 24             	mov    %esi,(%esp)
f0104a6d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104a70:	83 eb 01             	sub    $0x1,%ebx
f0104a73:	75 f1                	jne    f0104a66 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104a75:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a79:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104a7d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a80:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a84:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104a8b:	00 
f0104a8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a8f:	89 04 24             	mov    %eax,(%esp)
f0104a92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a99:	e8 52 0c 00 00       	call   f01056f0 <__umoddi3>
f0104a9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104aa2:	0f be 80 a7 70 10 f0 	movsbl -0xfef8f59(%eax),%eax
f0104aa9:	89 04 24             	mov    %eax,(%esp)
f0104aac:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104aaf:	83 c4 3c             	add    $0x3c,%esp
f0104ab2:	5b                   	pop    %ebx
f0104ab3:	5e                   	pop    %esi
f0104ab4:	5f                   	pop    %edi
f0104ab5:	5d                   	pop    %ebp
f0104ab6:	c3                   	ret    

f0104ab7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104ab7:	55                   	push   %ebp
f0104ab8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104aba:	83 fa 01             	cmp    $0x1,%edx
f0104abd:	7e 0e                	jle    f0104acd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104abf:	8b 10                	mov    (%eax),%edx
f0104ac1:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104ac4:	89 08                	mov    %ecx,(%eax)
f0104ac6:	8b 02                	mov    (%edx),%eax
f0104ac8:	8b 52 04             	mov    0x4(%edx),%edx
f0104acb:	eb 22                	jmp    f0104aef <getuint+0x38>
	else if (lflag)
f0104acd:	85 d2                	test   %edx,%edx
f0104acf:	74 10                	je     f0104ae1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104ad1:	8b 10                	mov    (%eax),%edx
f0104ad3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ad6:	89 08                	mov    %ecx,(%eax)
f0104ad8:	8b 02                	mov    (%edx),%eax
f0104ada:	ba 00 00 00 00       	mov    $0x0,%edx
f0104adf:	eb 0e                	jmp    f0104aef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104ae1:	8b 10                	mov    (%eax),%edx
f0104ae3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ae6:	89 08                	mov    %ecx,(%eax)
f0104ae8:	8b 02                	mov    (%edx),%eax
f0104aea:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104aef:	5d                   	pop    %ebp
f0104af0:	c3                   	ret    

f0104af1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104af1:	55                   	push   %ebp
f0104af2:	89 e5                	mov    %esp,%ebp
f0104af4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104af7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104afb:	8b 10                	mov    (%eax),%edx
f0104afd:	3b 50 04             	cmp    0x4(%eax),%edx
f0104b00:	73 0a                	jae    f0104b0c <sprintputch+0x1b>
		*b->buf++ = ch;
f0104b02:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b05:	88 0a                	mov    %cl,(%edx)
f0104b07:	83 c2 01             	add    $0x1,%edx
f0104b0a:	89 10                	mov    %edx,(%eax)
}
f0104b0c:	5d                   	pop    %ebp
f0104b0d:	c3                   	ret    

f0104b0e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104b0e:	55                   	push   %ebp
f0104b0f:	89 e5                	mov    %esp,%ebp
f0104b11:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0104b14:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104b17:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b1b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b22:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b29:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b2c:	89 04 24             	mov    %eax,(%esp)
f0104b2f:	e8 02 00 00 00       	call   f0104b36 <vprintfmt>
	va_end(ap);
}
f0104b34:	c9                   	leave  
f0104b35:	c3                   	ret    

f0104b36 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104b36:	55                   	push   %ebp
f0104b37:	89 e5                	mov    %esp,%ebp
f0104b39:	57                   	push   %edi
f0104b3a:	56                   	push   %esi
f0104b3b:	53                   	push   %ebx
f0104b3c:	83 ec 5c             	sub    $0x5c,%esp
f0104b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b42:	8b 75 10             	mov    0x10(%ebp),%esi
f0104b45:	eb 12                	jmp    f0104b59 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104b47:	85 c0                	test   %eax,%eax
f0104b49:	0f 84 e4 04 00 00    	je     f0105033 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f0104b4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b53:	89 04 24             	mov    %eax,(%esp)
f0104b56:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104b59:	0f b6 06             	movzbl (%esi),%eax
f0104b5c:	83 c6 01             	add    $0x1,%esi
f0104b5f:	83 f8 25             	cmp    $0x25,%eax
f0104b62:	75 e3                	jne    f0104b47 <vprintfmt+0x11>
f0104b64:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0104b68:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f0104b6f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0104b74:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104b7b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b80:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0104b83:	eb 2b                	jmp    f0104bb0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b85:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104b88:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0104b8c:	eb 22                	jmp    f0104bb0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b8e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104b91:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0104b95:	eb 19                	jmp    f0104bb0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b97:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104b9a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0104ba1:	eb 0d                	jmp    f0104bb0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104ba3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104ba6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104ba9:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bb0:	0f b6 06             	movzbl (%esi),%eax
f0104bb3:	0f b6 d0             	movzbl %al,%edx
f0104bb6:	8d 7e 01             	lea    0x1(%esi),%edi
f0104bb9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104bbc:	83 e8 23             	sub    $0x23,%eax
f0104bbf:	3c 55                	cmp    $0x55,%al
f0104bc1:	0f 87 46 04 00 00    	ja     f010500d <vprintfmt+0x4d7>
f0104bc7:	0f b6 c0             	movzbl %al,%eax
f0104bca:	ff 24 85 4c 71 10 f0 	jmp    *-0xfef8eb4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104bd1:	83 ea 30             	sub    $0x30,%edx
f0104bd4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f0104bd7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0104bdb:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bde:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0104be1:	83 fa 09             	cmp    $0x9,%edx
f0104be4:	77 4a                	ja     f0104c30 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104be6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104be9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0104bec:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0104bef:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0104bf3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104bf6:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104bf9:	83 fa 09             	cmp    $0x9,%edx
f0104bfc:	76 eb                	jbe    f0104be9 <vprintfmt+0xb3>
f0104bfe:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0104c01:	eb 2d                	jmp    f0104c30 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104c03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c06:	8d 50 04             	lea    0x4(%eax),%edx
f0104c09:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c0c:	8b 00                	mov    (%eax),%eax
f0104c0e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c11:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104c14:	eb 1a                	jmp    f0104c30 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c16:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0104c19:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104c1d:	79 91                	jns    f0104bb0 <vprintfmt+0x7a>
f0104c1f:	e9 73 ff ff ff       	jmp    f0104b97 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c24:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104c27:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0104c2e:	eb 80                	jmp    f0104bb0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0104c30:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104c34:	0f 89 76 ff ff ff    	jns    f0104bb0 <vprintfmt+0x7a>
f0104c3a:	e9 64 ff ff ff       	jmp    f0104ba3 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104c3f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c42:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104c45:	e9 66 ff ff ff       	jmp    f0104bb0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104c4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c4d:	8d 50 04             	lea    0x4(%eax),%edx
f0104c50:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104c57:	8b 00                	mov    (%eax),%eax
f0104c59:	89 04 24             	mov    %eax,(%esp)
f0104c5c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c5f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104c62:	e9 f2 fe ff ff       	jmp    f0104b59 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f0104c67:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0104c6b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f0104c6e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f0104c72:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f0104c75:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f0104c79:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f0104c7c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f0104c7f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f0104c83:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0104c86:	80 f9 09             	cmp    $0x9,%cl
f0104c89:	77 1d                	ja     f0104ca8 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f0104c8b:	0f be c0             	movsbl %al,%eax
f0104c8e:	6b c0 64             	imul   $0x64,%eax,%eax
f0104c91:	0f be d2             	movsbl %dl,%edx
f0104c94:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104c97:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0104c9e:	a3 3c d4 11 f0       	mov    %eax,0xf011d43c
f0104ca3:	e9 b1 fe ff ff       	jmp    f0104b59 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f0104ca8:	c7 44 24 04 bf 70 10 	movl   $0xf01070bf,0x4(%esp)
f0104caf:	f0 
f0104cb0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cb3:	89 04 24             	mov    %eax,(%esp)
f0104cb6:	e8 e0 05 00 00       	call   f010529b <strcmp>
f0104cbb:	85 c0                	test   %eax,%eax
f0104cbd:	75 0f                	jne    f0104cce <vprintfmt+0x198>
f0104cbf:	c7 05 3c d4 11 f0 04 	movl   $0x4,0xf011d43c
f0104cc6:	00 00 00 
f0104cc9:	e9 8b fe ff ff       	jmp    f0104b59 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0104cce:	c7 44 24 04 c3 70 10 	movl   $0xf01070c3,0x4(%esp)
f0104cd5:	f0 
f0104cd6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104cd9:	89 14 24             	mov    %edx,(%esp)
f0104cdc:	e8 ba 05 00 00       	call   f010529b <strcmp>
f0104ce1:	85 c0                	test   %eax,%eax
f0104ce3:	75 0f                	jne    f0104cf4 <vprintfmt+0x1be>
f0104ce5:	c7 05 3c d4 11 f0 02 	movl   $0x2,0xf011d43c
f0104cec:	00 00 00 
f0104cef:	e9 65 fe ff ff       	jmp    f0104b59 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0104cf4:	c7 44 24 04 c7 70 10 	movl   $0xf01070c7,0x4(%esp)
f0104cfb:	f0 
f0104cfc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0104cff:	89 0c 24             	mov    %ecx,(%esp)
f0104d02:	e8 94 05 00 00       	call   f010529b <strcmp>
f0104d07:	85 c0                	test   %eax,%eax
f0104d09:	75 0f                	jne    f0104d1a <vprintfmt+0x1e4>
f0104d0b:	c7 05 3c d4 11 f0 01 	movl   $0x1,0xf011d43c
f0104d12:	00 00 00 
f0104d15:	e9 3f fe ff ff       	jmp    f0104b59 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f0104d1a:	c7 44 24 04 cb 70 10 	movl   $0xf01070cb,0x4(%esp)
f0104d21:	f0 
f0104d22:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0104d25:	89 3c 24             	mov    %edi,(%esp)
f0104d28:	e8 6e 05 00 00       	call   f010529b <strcmp>
f0104d2d:	85 c0                	test   %eax,%eax
f0104d2f:	75 0f                	jne    f0104d40 <vprintfmt+0x20a>
f0104d31:	c7 05 3c d4 11 f0 06 	movl   $0x6,0xf011d43c
f0104d38:	00 00 00 
f0104d3b:	e9 19 fe ff ff       	jmp    f0104b59 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f0104d40:	c7 44 24 04 cf 70 10 	movl   $0xf01070cf,0x4(%esp)
f0104d47:	f0 
f0104d48:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d4b:	89 04 24             	mov    %eax,(%esp)
f0104d4e:	e8 48 05 00 00       	call   f010529b <strcmp>
f0104d53:	85 c0                	test   %eax,%eax
f0104d55:	75 0f                	jne    f0104d66 <vprintfmt+0x230>
f0104d57:	c7 05 3c d4 11 f0 07 	movl   $0x7,0xf011d43c
f0104d5e:	00 00 00 
f0104d61:	e9 f3 fd ff ff       	jmp    f0104b59 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f0104d66:	c7 44 24 04 d3 70 10 	movl   $0xf01070d3,0x4(%esp)
f0104d6d:	f0 
f0104d6e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d71:	89 14 24             	mov    %edx,(%esp)
f0104d74:	e8 22 05 00 00       	call   f010529b <strcmp>
f0104d79:	83 f8 01             	cmp    $0x1,%eax
f0104d7c:	19 c0                	sbb    %eax,%eax
f0104d7e:	f7 d0                	not    %eax
f0104d80:	83 c0 08             	add    $0x8,%eax
f0104d83:	a3 3c d4 11 f0       	mov    %eax,0xf011d43c
f0104d88:	e9 cc fd ff ff       	jmp    f0104b59 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f0104d8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d90:	8d 50 04             	lea    0x4(%eax),%edx
f0104d93:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d96:	8b 00                	mov    (%eax),%eax
f0104d98:	89 c2                	mov    %eax,%edx
f0104d9a:	c1 fa 1f             	sar    $0x1f,%edx
f0104d9d:	31 d0                	xor    %edx,%eax
f0104d9f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104da1:	83 f8 06             	cmp    $0x6,%eax
f0104da4:	7f 0b                	jg     f0104db1 <vprintfmt+0x27b>
f0104da6:	8b 14 85 a4 72 10 f0 	mov    -0xfef8d5c(,%eax,4),%edx
f0104dad:	85 d2                	test   %edx,%edx
f0104daf:	75 23                	jne    f0104dd4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0104db1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104db5:	c7 44 24 08 d7 70 10 	movl   $0xf01070d7,0x8(%esp)
f0104dbc:	f0 
f0104dbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104dc1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104dc4:	89 3c 24             	mov    %edi,(%esp)
f0104dc7:	e8 42 fd ff ff       	call   f0104b0e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dcc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104dcf:	e9 85 fd ff ff       	jmp    f0104b59 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0104dd4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104dd8:	c7 44 24 08 d5 68 10 	movl   $0xf01068d5,0x8(%esp)
f0104ddf:	f0 
f0104de0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104de4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104de7:	89 3c 24             	mov    %edi,(%esp)
f0104dea:	e8 1f fd ff ff       	call   f0104b0e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104def:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104df2:	e9 62 fd ff ff       	jmp    f0104b59 <vprintfmt+0x23>
f0104df7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104dfa:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104dfd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104e00:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e03:	8d 50 04             	lea    0x4(%eax),%edx
f0104e06:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e09:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0104e0b:	85 f6                	test   %esi,%esi
f0104e0d:	b8 b8 70 10 f0       	mov    $0xf01070b8,%eax
f0104e12:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0104e15:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0104e19:	7e 06                	jle    f0104e21 <vprintfmt+0x2eb>
f0104e1b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0104e1f:	75 13                	jne    f0104e34 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104e21:	0f be 06             	movsbl (%esi),%eax
f0104e24:	83 c6 01             	add    $0x1,%esi
f0104e27:	85 c0                	test   %eax,%eax
f0104e29:	0f 85 94 00 00 00    	jne    f0104ec3 <vprintfmt+0x38d>
f0104e2f:	e9 81 00 00 00       	jmp    f0104eb5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e34:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e38:	89 34 24             	mov    %esi,(%esp)
f0104e3b:	e8 6b 03 00 00       	call   f01051ab <strnlen>
f0104e40:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e43:	29 c2                	sub    %eax,%edx
f0104e45:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104e48:	85 d2                	test   %edx,%edx
f0104e4a:	7e d5                	jle    f0104e21 <vprintfmt+0x2eb>
					putch(padc, putdat);
f0104e4c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0104e50:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e53:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0104e56:	89 d6                	mov    %edx,%esi
f0104e58:	89 cf                	mov    %ecx,%edi
f0104e5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104e5e:	89 3c 24             	mov    %edi,(%esp)
f0104e61:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e64:	83 ee 01             	sub    $0x1,%esi
f0104e67:	75 f1                	jne    f0104e5a <vprintfmt+0x324>
f0104e69:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104e6c:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0104e6f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104e72:	eb ad                	jmp    f0104e21 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104e74:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0104e78:	74 1b                	je     f0104e95 <vprintfmt+0x35f>
f0104e7a:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104e7d:	83 fa 5e             	cmp    $0x5e,%edx
f0104e80:	76 13                	jbe    f0104e95 <vprintfmt+0x35f>
					putch('?', putdat);
f0104e82:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e89:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104e90:	ff 55 08             	call   *0x8(%ebp)
f0104e93:	eb 0d                	jmp    f0104ea2 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f0104e95:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104e98:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104e9c:	89 04 24             	mov    %eax,(%esp)
f0104e9f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ea2:	83 eb 01             	sub    $0x1,%ebx
f0104ea5:	0f be 06             	movsbl (%esi),%eax
f0104ea8:	83 c6 01             	add    $0x1,%esi
f0104eab:	85 c0                	test   %eax,%eax
f0104ead:	75 1a                	jne    f0104ec9 <vprintfmt+0x393>
f0104eaf:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104eb2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104eb5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104eb8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104ebc:	7f 1c                	jg     f0104eda <vprintfmt+0x3a4>
f0104ebe:	e9 96 fc ff ff       	jmp    f0104b59 <vprintfmt+0x23>
f0104ec3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104ec6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ec9:	85 ff                	test   %edi,%edi
f0104ecb:	78 a7                	js     f0104e74 <vprintfmt+0x33e>
f0104ecd:	83 ef 01             	sub    $0x1,%edi
f0104ed0:	79 a2                	jns    f0104e74 <vprintfmt+0x33e>
f0104ed2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104ed5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104ed8:	eb db                	jmp    f0104eb5 <vprintfmt+0x37f>
f0104eda:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104edd:	89 de                	mov    %ebx,%esi
f0104edf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104ee2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ee6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104eed:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104eef:	83 eb 01             	sub    $0x1,%ebx
f0104ef2:	75 ee                	jne    f0104ee2 <vprintfmt+0x3ac>
f0104ef4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ef6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104ef9:	e9 5b fc ff ff       	jmp    f0104b59 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104efe:	83 f9 01             	cmp    $0x1,%ecx
f0104f01:	7e 10                	jle    f0104f13 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f0104f03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f06:	8d 50 08             	lea    0x8(%eax),%edx
f0104f09:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f0c:	8b 30                	mov    (%eax),%esi
f0104f0e:	8b 78 04             	mov    0x4(%eax),%edi
f0104f11:	eb 26                	jmp    f0104f39 <vprintfmt+0x403>
	else if (lflag)
f0104f13:	85 c9                	test   %ecx,%ecx
f0104f15:	74 12                	je     f0104f29 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f0104f17:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f1a:	8d 50 04             	lea    0x4(%eax),%edx
f0104f1d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f20:	8b 30                	mov    (%eax),%esi
f0104f22:	89 f7                	mov    %esi,%edi
f0104f24:	c1 ff 1f             	sar    $0x1f,%edi
f0104f27:	eb 10                	jmp    f0104f39 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f0104f29:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f2c:	8d 50 04             	lea    0x4(%eax),%edx
f0104f2f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f32:	8b 30                	mov    (%eax),%esi
f0104f34:	89 f7                	mov    %esi,%edi
f0104f36:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104f39:	85 ff                	test   %edi,%edi
f0104f3b:	78 0e                	js     f0104f4b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104f3d:	89 f0                	mov    %esi,%eax
f0104f3f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104f41:	be 0a 00 00 00       	mov    $0xa,%esi
f0104f46:	e9 84 00 00 00       	jmp    f0104fcf <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104f4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104f4f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104f56:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104f59:	89 f0                	mov    %esi,%eax
f0104f5b:	89 fa                	mov    %edi,%edx
f0104f5d:	f7 d8                	neg    %eax
f0104f5f:	83 d2 00             	adc    $0x0,%edx
f0104f62:	f7 da                	neg    %edx
			}
			base = 10;
f0104f64:	be 0a 00 00 00       	mov    $0xa,%esi
f0104f69:	eb 64                	jmp    f0104fcf <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104f6b:	89 ca                	mov    %ecx,%edx
f0104f6d:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f70:	e8 42 fb ff ff       	call   f0104ab7 <getuint>
			base = 10;
f0104f75:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0104f7a:	eb 53                	jmp    f0104fcf <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0104f7c:	89 ca                	mov    %ecx,%edx
f0104f7e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f81:	e8 31 fb ff ff       	call   f0104ab7 <getuint>
    			base = 8;
f0104f86:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0104f8b:	eb 42                	jmp    f0104fcf <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f0104f8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104f91:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104f98:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104f9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104f9f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104fa6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104fa9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fac:	8d 50 04             	lea    0x4(%eax),%edx
f0104faf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104fb2:	8b 00                	mov    (%eax),%eax
f0104fb4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104fb9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0104fbe:	eb 0f                	jmp    f0104fcf <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104fc0:	89 ca                	mov    %ecx,%edx
f0104fc2:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fc5:	e8 ed fa ff ff       	call   f0104ab7 <getuint>
			base = 16;
f0104fca:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104fcf:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0104fd3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104fd7:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104fda:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104fde:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104fe2:	89 04 24             	mov    %eax,(%esp)
f0104fe5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104fe9:	89 da                	mov    %ebx,%edx
f0104feb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fee:	e8 e9 f9 ff ff       	call   f01049dc <printnum>
			break;
f0104ff3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104ff6:	e9 5e fb ff ff       	jmp    f0104b59 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104ffb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fff:	89 14 24             	mov    %edx,(%esp)
f0105002:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105005:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105008:	e9 4c fb ff ff       	jmp    f0104b59 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010500d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105011:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105018:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010501b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010501f:	0f 84 34 fb ff ff    	je     f0104b59 <vprintfmt+0x23>
f0105025:	83 ee 01             	sub    $0x1,%esi
f0105028:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010502c:	75 f7                	jne    f0105025 <vprintfmt+0x4ef>
f010502e:	e9 26 fb ff ff       	jmp    f0104b59 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105033:	83 c4 5c             	add    $0x5c,%esp
f0105036:	5b                   	pop    %ebx
f0105037:	5e                   	pop    %esi
f0105038:	5f                   	pop    %edi
f0105039:	5d                   	pop    %ebp
f010503a:	c3                   	ret    

f010503b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010503b:	55                   	push   %ebp
f010503c:	89 e5                	mov    %esp,%ebp
f010503e:	83 ec 28             	sub    $0x28,%esp
f0105041:	8b 45 08             	mov    0x8(%ebp),%eax
f0105044:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105047:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010504a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010504e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105051:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105058:	85 c0                	test   %eax,%eax
f010505a:	74 30                	je     f010508c <vsnprintf+0x51>
f010505c:	85 d2                	test   %edx,%edx
f010505e:	7e 2c                	jle    f010508c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105060:	8b 45 14             	mov    0x14(%ebp),%eax
f0105063:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105067:	8b 45 10             	mov    0x10(%ebp),%eax
f010506a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010506e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105071:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105075:	c7 04 24 f1 4a 10 f0 	movl   $0xf0104af1,(%esp)
f010507c:	e8 b5 fa ff ff       	call   f0104b36 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105081:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105084:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105087:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010508a:	eb 05                	jmp    f0105091 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010508c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105091:	c9                   	leave  
f0105092:	c3                   	ret    

f0105093 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105093:	55                   	push   %ebp
f0105094:	89 e5                	mov    %esp,%ebp
f0105096:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105099:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010509c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01050a0:	8b 45 10             	mov    0x10(%ebp),%eax
f01050a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01050b1:	89 04 24             	mov    %eax,(%esp)
f01050b4:	e8 82 ff ff ff       	call   f010503b <vsnprintf>
	va_end(ap);

	return rc;
}
f01050b9:	c9                   	leave  
f01050ba:	c3                   	ret    
f01050bb:	00 00                	add    %al,(%eax)
f01050bd:	00 00                	add    %al,(%eax)
	...

f01050c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01050c0:	55                   	push   %ebp
f01050c1:	89 e5                	mov    %esp,%ebp
f01050c3:	57                   	push   %edi
f01050c4:	56                   	push   %esi
f01050c5:	53                   	push   %ebx
f01050c6:	83 ec 1c             	sub    $0x1c,%esp
f01050c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01050cc:	85 c0                	test   %eax,%eax
f01050ce:	74 10                	je     f01050e0 <readline+0x20>
		cprintf("%s", prompt);
f01050d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050d4:	c7 04 24 d5 68 10 f0 	movl   $0xf01068d5,(%esp)
f01050db:	e8 8a ed ff ff       	call   f0103e6a <cprintf>

	i = 0;
	echoing = iscons(0);
f01050e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01050e7:	e8 55 b5 ff ff       	call   f0100641 <iscons>
f01050ec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01050ee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01050f3:	e8 38 b5 ff ff       	call   f0100630 <getchar>
f01050f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01050fa:	85 c0                	test   %eax,%eax
f01050fc:	79 17                	jns    f0105115 <readline+0x55>
			cprintf("read error: %e\n", c);
f01050fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105102:	c7 04 24 c0 72 10 f0 	movl   $0xf01072c0,(%esp)
f0105109:	e8 5c ed ff ff       	call   f0103e6a <cprintf>
			return NULL;
f010510e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105113:	eb 6d                	jmp    f0105182 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105115:	83 f8 08             	cmp    $0x8,%eax
f0105118:	74 05                	je     f010511f <readline+0x5f>
f010511a:	83 f8 7f             	cmp    $0x7f,%eax
f010511d:	75 19                	jne    f0105138 <readline+0x78>
f010511f:	85 f6                	test   %esi,%esi
f0105121:	7e 15                	jle    f0105138 <readline+0x78>
			if (echoing)
f0105123:	85 ff                	test   %edi,%edi
f0105125:	74 0c                	je     f0105133 <readline+0x73>
				cputchar('\b');
f0105127:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010512e:	e8 ed b4 ff ff       	call   f0100620 <cputchar>
			i--;
f0105133:	83 ee 01             	sub    $0x1,%esi
f0105136:	eb bb                	jmp    f01050f3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105138:	83 fb 1f             	cmp    $0x1f,%ebx
f010513b:	7e 1f                	jle    f010515c <readline+0x9c>
f010513d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105143:	7f 17                	jg     f010515c <readline+0x9c>
			if (echoing)
f0105145:	85 ff                	test   %edi,%edi
f0105147:	74 08                	je     f0105151 <readline+0x91>
				cputchar(c);
f0105149:	89 1c 24             	mov    %ebx,(%esp)
f010514c:	e8 cf b4 ff ff       	call   f0100620 <cputchar>
			buf[i++] = c;
f0105151:	88 9e 60 0a 18 f0    	mov    %bl,-0xfe7f5a0(%esi)
f0105157:	83 c6 01             	add    $0x1,%esi
f010515a:	eb 97                	jmp    f01050f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010515c:	83 fb 0a             	cmp    $0xa,%ebx
f010515f:	74 05                	je     f0105166 <readline+0xa6>
f0105161:	83 fb 0d             	cmp    $0xd,%ebx
f0105164:	75 8d                	jne    f01050f3 <readline+0x33>
			if (echoing)
f0105166:	85 ff                	test   %edi,%edi
f0105168:	74 0c                	je     f0105176 <readline+0xb6>
				cputchar('\n');
f010516a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105171:	e8 aa b4 ff ff       	call   f0100620 <cputchar>
			buf[i] = 0;
f0105176:	c6 86 60 0a 18 f0 00 	movb   $0x0,-0xfe7f5a0(%esi)
			return buf;
f010517d:	b8 60 0a 18 f0       	mov    $0xf0180a60,%eax
		}
	}
}
f0105182:	83 c4 1c             	add    $0x1c,%esp
f0105185:	5b                   	pop    %ebx
f0105186:	5e                   	pop    %esi
f0105187:	5f                   	pop    %edi
f0105188:	5d                   	pop    %ebp
f0105189:	c3                   	ret    
f010518a:	00 00                	add    %al,(%eax)
f010518c:	00 00                	add    %al,(%eax)
	...

f0105190 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105190:	55                   	push   %ebp
f0105191:	89 e5                	mov    %esp,%ebp
f0105193:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105196:	b8 00 00 00 00       	mov    $0x0,%eax
f010519b:	80 3a 00             	cmpb   $0x0,(%edx)
f010519e:	74 09                	je     f01051a9 <strlen+0x19>
		n++;
f01051a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01051a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01051a7:	75 f7                	jne    f01051a0 <strlen+0x10>
		n++;
	return n;
}
f01051a9:	5d                   	pop    %ebp
f01051aa:	c3                   	ret    

f01051ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01051ab:	55                   	push   %ebp
f01051ac:	89 e5                	mov    %esp,%ebp
f01051ae:	53                   	push   %ebx
f01051af:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01051b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01051ba:	85 c9                	test   %ecx,%ecx
f01051bc:	74 1a                	je     f01051d8 <strnlen+0x2d>
f01051be:	80 3b 00             	cmpb   $0x0,(%ebx)
f01051c1:	74 15                	je     f01051d8 <strnlen+0x2d>
f01051c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01051c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051ca:	39 ca                	cmp    %ecx,%edx
f01051cc:	74 0a                	je     f01051d8 <strnlen+0x2d>
f01051ce:	83 c2 01             	add    $0x1,%edx
f01051d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01051d6:	75 f0                	jne    f01051c8 <strnlen+0x1d>
		n++;
	return n;
}
f01051d8:	5b                   	pop    %ebx
f01051d9:	5d                   	pop    %ebp
f01051da:	c3                   	ret    

f01051db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01051db:	55                   	push   %ebp
f01051dc:	89 e5                	mov    %esp,%ebp
f01051de:	53                   	push   %ebx
f01051df:	8b 45 08             	mov    0x8(%ebp),%eax
f01051e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01051e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01051ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01051ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01051f1:	83 c2 01             	add    $0x1,%edx
f01051f4:	84 c9                	test   %cl,%cl
f01051f6:	75 f2                	jne    f01051ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01051f8:	5b                   	pop    %ebx
f01051f9:	5d                   	pop    %ebp
f01051fa:	c3                   	ret    

f01051fb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01051fb:	55                   	push   %ebp
f01051fc:	89 e5                	mov    %esp,%ebp
f01051fe:	53                   	push   %ebx
f01051ff:	83 ec 08             	sub    $0x8,%esp
f0105202:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105205:	89 1c 24             	mov    %ebx,(%esp)
f0105208:	e8 83 ff ff ff       	call   f0105190 <strlen>
	strcpy(dst + len, src);
f010520d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105210:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105214:	01 d8                	add    %ebx,%eax
f0105216:	89 04 24             	mov    %eax,(%esp)
f0105219:	e8 bd ff ff ff       	call   f01051db <strcpy>
	return dst;
}
f010521e:	89 d8                	mov    %ebx,%eax
f0105220:	83 c4 08             	add    $0x8,%esp
f0105223:	5b                   	pop    %ebx
f0105224:	5d                   	pop    %ebp
f0105225:	c3                   	ret    

f0105226 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105226:	55                   	push   %ebp
f0105227:	89 e5                	mov    %esp,%ebp
f0105229:	56                   	push   %esi
f010522a:	53                   	push   %ebx
f010522b:	8b 45 08             	mov    0x8(%ebp),%eax
f010522e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105231:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105234:	85 f6                	test   %esi,%esi
f0105236:	74 18                	je     f0105250 <strncpy+0x2a>
f0105238:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010523d:	0f b6 1a             	movzbl (%edx),%ebx
f0105240:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105243:	80 3a 01             	cmpb   $0x1,(%edx)
f0105246:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105249:	83 c1 01             	add    $0x1,%ecx
f010524c:	39 f1                	cmp    %esi,%ecx
f010524e:	75 ed                	jne    f010523d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105250:	5b                   	pop    %ebx
f0105251:	5e                   	pop    %esi
f0105252:	5d                   	pop    %ebp
f0105253:	c3                   	ret    

f0105254 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105254:	55                   	push   %ebp
f0105255:	89 e5                	mov    %esp,%ebp
f0105257:	57                   	push   %edi
f0105258:	56                   	push   %esi
f0105259:	53                   	push   %ebx
f010525a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010525d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105260:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105263:	89 f8                	mov    %edi,%eax
f0105265:	85 f6                	test   %esi,%esi
f0105267:	74 2b                	je     f0105294 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0105269:	83 fe 01             	cmp    $0x1,%esi
f010526c:	74 23                	je     f0105291 <strlcpy+0x3d>
f010526e:	0f b6 0b             	movzbl (%ebx),%ecx
f0105271:	84 c9                	test   %cl,%cl
f0105273:	74 1c                	je     f0105291 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0105275:	83 ee 02             	sub    $0x2,%esi
f0105278:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010527d:	88 08                	mov    %cl,(%eax)
f010527f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105282:	39 f2                	cmp    %esi,%edx
f0105284:	74 0b                	je     f0105291 <strlcpy+0x3d>
f0105286:	83 c2 01             	add    $0x1,%edx
f0105289:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010528d:	84 c9                	test   %cl,%cl
f010528f:	75 ec                	jne    f010527d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0105291:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105294:	29 f8                	sub    %edi,%eax
}
f0105296:	5b                   	pop    %ebx
f0105297:	5e                   	pop    %esi
f0105298:	5f                   	pop    %edi
f0105299:	5d                   	pop    %ebp
f010529a:	c3                   	ret    

f010529b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010529b:	55                   	push   %ebp
f010529c:	89 e5                	mov    %esp,%ebp
f010529e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01052a4:	0f b6 01             	movzbl (%ecx),%eax
f01052a7:	84 c0                	test   %al,%al
f01052a9:	74 16                	je     f01052c1 <strcmp+0x26>
f01052ab:	3a 02                	cmp    (%edx),%al
f01052ad:	75 12                	jne    f01052c1 <strcmp+0x26>
		p++, q++;
f01052af:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01052b2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01052b6:	84 c0                	test   %al,%al
f01052b8:	74 07                	je     f01052c1 <strcmp+0x26>
f01052ba:	83 c1 01             	add    $0x1,%ecx
f01052bd:	3a 02                	cmp    (%edx),%al
f01052bf:	74 ee                	je     f01052af <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01052c1:	0f b6 c0             	movzbl %al,%eax
f01052c4:	0f b6 12             	movzbl (%edx),%edx
f01052c7:	29 d0                	sub    %edx,%eax
}
f01052c9:	5d                   	pop    %ebp
f01052ca:	c3                   	ret    

f01052cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01052cb:	55                   	push   %ebp
f01052cc:	89 e5                	mov    %esp,%ebp
f01052ce:	53                   	push   %ebx
f01052cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052d5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01052d8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01052dd:	85 d2                	test   %edx,%edx
f01052df:	74 28                	je     f0105309 <strncmp+0x3e>
f01052e1:	0f b6 01             	movzbl (%ecx),%eax
f01052e4:	84 c0                	test   %al,%al
f01052e6:	74 24                	je     f010530c <strncmp+0x41>
f01052e8:	3a 03                	cmp    (%ebx),%al
f01052ea:	75 20                	jne    f010530c <strncmp+0x41>
f01052ec:	83 ea 01             	sub    $0x1,%edx
f01052ef:	74 13                	je     f0105304 <strncmp+0x39>
		n--, p++, q++;
f01052f1:	83 c1 01             	add    $0x1,%ecx
f01052f4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01052f7:	0f b6 01             	movzbl (%ecx),%eax
f01052fa:	84 c0                	test   %al,%al
f01052fc:	74 0e                	je     f010530c <strncmp+0x41>
f01052fe:	3a 03                	cmp    (%ebx),%al
f0105300:	74 ea                	je     f01052ec <strncmp+0x21>
f0105302:	eb 08                	jmp    f010530c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105304:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105309:	5b                   	pop    %ebx
f010530a:	5d                   	pop    %ebp
f010530b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010530c:	0f b6 01             	movzbl (%ecx),%eax
f010530f:	0f b6 13             	movzbl (%ebx),%edx
f0105312:	29 d0                	sub    %edx,%eax
f0105314:	eb f3                	jmp    f0105309 <strncmp+0x3e>

f0105316 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105316:	55                   	push   %ebp
f0105317:	89 e5                	mov    %esp,%ebp
f0105319:	8b 45 08             	mov    0x8(%ebp),%eax
f010531c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105320:	0f b6 10             	movzbl (%eax),%edx
f0105323:	84 d2                	test   %dl,%dl
f0105325:	74 1c                	je     f0105343 <strchr+0x2d>
		if (*s == c)
f0105327:	38 ca                	cmp    %cl,%dl
f0105329:	75 09                	jne    f0105334 <strchr+0x1e>
f010532b:	eb 1b                	jmp    f0105348 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010532d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0105330:	38 ca                	cmp    %cl,%dl
f0105332:	74 14                	je     f0105348 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105334:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0105338:	84 d2                	test   %dl,%dl
f010533a:	75 f1                	jne    f010532d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f010533c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105341:	eb 05                	jmp    f0105348 <strchr+0x32>
f0105343:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105348:	5d                   	pop    %ebp
f0105349:	c3                   	ret    

f010534a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010534a:	55                   	push   %ebp
f010534b:	89 e5                	mov    %esp,%ebp
f010534d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105350:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105354:	0f b6 10             	movzbl (%eax),%edx
f0105357:	84 d2                	test   %dl,%dl
f0105359:	74 14                	je     f010536f <strfind+0x25>
		if (*s == c)
f010535b:	38 ca                	cmp    %cl,%dl
f010535d:	75 06                	jne    f0105365 <strfind+0x1b>
f010535f:	eb 0e                	jmp    f010536f <strfind+0x25>
f0105361:	38 ca                	cmp    %cl,%dl
f0105363:	74 0a                	je     f010536f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105365:	83 c0 01             	add    $0x1,%eax
f0105368:	0f b6 10             	movzbl (%eax),%edx
f010536b:	84 d2                	test   %dl,%dl
f010536d:	75 f2                	jne    f0105361 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f010536f:	5d                   	pop    %ebp
f0105370:	c3                   	ret    

f0105371 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105371:	55                   	push   %ebp
f0105372:	89 e5                	mov    %esp,%ebp
f0105374:	83 ec 0c             	sub    $0xc,%esp
f0105377:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010537a:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010537d:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105380:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105383:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105386:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105389:	85 c9                	test   %ecx,%ecx
f010538b:	74 30                	je     f01053bd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010538d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105393:	75 25                	jne    f01053ba <memset+0x49>
f0105395:	f6 c1 03             	test   $0x3,%cl
f0105398:	75 20                	jne    f01053ba <memset+0x49>
		c &= 0xFF;
f010539a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010539d:	89 d3                	mov    %edx,%ebx
f010539f:	c1 e3 08             	shl    $0x8,%ebx
f01053a2:	89 d6                	mov    %edx,%esi
f01053a4:	c1 e6 18             	shl    $0x18,%esi
f01053a7:	89 d0                	mov    %edx,%eax
f01053a9:	c1 e0 10             	shl    $0x10,%eax
f01053ac:	09 f0                	or     %esi,%eax
f01053ae:	09 d0                	or     %edx,%eax
f01053b0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01053b2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01053b5:	fc                   	cld    
f01053b6:	f3 ab                	rep stos %eax,%es:(%edi)
f01053b8:	eb 03                	jmp    f01053bd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01053ba:	fc                   	cld    
f01053bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01053bd:	89 f8                	mov    %edi,%eax
f01053bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01053c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01053c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01053c8:	89 ec                	mov    %ebp,%esp
f01053ca:	5d                   	pop    %ebp
f01053cb:	c3                   	ret    

f01053cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01053cc:	55                   	push   %ebp
f01053cd:	89 e5                	mov    %esp,%ebp
f01053cf:	83 ec 08             	sub    $0x8,%esp
f01053d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01053d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01053d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01053db:	8b 75 0c             	mov    0xc(%ebp),%esi
f01053de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01053e1:	39 c6                	cmp    %eax,%esi
f01053e3:	73 36                	jae    f010541b <memmove+0x4f>
f01053e5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01053e8:	39 d0                	cmp    %edx,%eax
f01053ea:	73 2f                	jae    f010541b <memmove+0x4f>
		s += n;
		d += n;
f01053ec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053ef:	f6 c2 03             	test   $0x3,%dl
f01053f2:	75 1b                	jne    f010540f <memmove+0x43>
f01053f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01053fa:	75 13                	jne    f010540f <memmove+0x43>
f01053fc:	f6 c1 03             	test   $0x3,%cl
f01053ff:	75 0e                	jne    f010540f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105401:	83 ef 04             	sub    $0x4,%edi
f0105404:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105407:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010540a:	fd                   	std    
f010540b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010540d:	eb 09                	jmp    f0105418 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010540f:	83 ef 01             	sub    $0x1,%edi
f0105412:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105415:	fd                   	std    
f0105416:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105418:	fc                   	cld    
f0105419:	eb 20                	jmp    f010543b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010541b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105421:	75 13                	jne    f0105436 <memmove+0x6a>
f0105423:	a8 03                	test   $0x3,%al
f0105425:	75 0f                	jne    f0105436 <memmove+0x6a>
f0105427:	f6 c1 03             	test   $0x3,%cl
f010542a:	75 0a                	jne    f0105436 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010542c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010542f:	89 c7                	mov    %eax,%edi
f0105431:	fc                   	cld    
f0105432:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105434:	eb 05                	jmp    f010543b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105436:	89 c7                	mov    %eax,%edi
f0105438:	fc                   	cld    
f0105439:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010543b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010543e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105441:	89 ec                	mov    %ebp,%esp
f0105443:	5d                   	pop    %ebp
f0105444:	c3                   	ret    

f0105445 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105445:	55                   	push   %ebp
f0105446:	89 e5                	mov    %esp,%ebp
f0105448:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010544b:	8b 45 10             	mov    0x10(%ebp),%eax
f010544e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105452:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105455:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105459:	8b 45 08             	mov    0x8(%ebp),%eax
f010545c:	89 04 24             	mov    %eax,(%esp)
f010545f:	e8 68 ff ff ff       	call   f01053cc <memmove>
}
f0105464:	c9                   	leave  
f0105465:	c3                   	ret    

f0105466 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105466:	55                   	push   %ebp
f0105467:	89 e5                	mov    %esp,%ebp
f0105469:	57                   	push   %edi
f010546a:	56                   	push   %esi
f010546b:	53                   	push   %ebx
f010546c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010546f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105472:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105475:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010547a:	85 ff                	test   %edi,%edi
f010547c:	74 37                	je     f01054b5 <memcmp+0x4f>
		if (*s1 != *s2)
f010547e:	0f b6 03             	movzbl (%ebx),%eax
f0105481:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105484:	83 ef 01             	sub    $0x1,%edi
f0105487:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f010548c:	38 c8                	cmp    %cl,%al
f010548e:	74 1c                	je     f01054ac <memcmp+0x46>
f0105490:	eb 10                	jmp    f01054a2 <memcmp+0x3c>
f0105492:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0105497:	83 c2 01             	add    $0x1,%edx
f010549a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010549e:	38 c8                	cmp    %cl,%al
f01054a0:	74 0a                	je     f01054ac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f01054a2:	0f b6 c0             	movzbl %al,%eax
f01054a5:	0f b6 c9             	movzbl %cl,%ecx
f01054a8:	29 c8                	sub    %ecx,%eax
f01054aa:	eb 09                	jmp    f01054b5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01054ac:	39 fa                	cmp    %edi,%edx
f01054ae:	75 e2                	jne    f0105492 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01054b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01054b5:	5b                   	pop    %ebx
f01054b6:	5e                   	pop    %esi
f01054b7:	5f                   	pop    %edi
f01054b8:	5d                   	pop    %ebp
f01054b9:	c3                   	ret    

f01054ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01054ba:	55                   	push   %ebp
f01054bb:	89 e5                	mov    %esp,%ebp
f01054bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01054c0:	89 c2                	mov    %eax,%edx
f01054c2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01054c5:	39 d0                	cmp    %edx,%eax
f01054c7:	73 19                	jae    f01054e2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f01054c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01054cd:	38 08                	cmp    %cl,(%eax)
f01054cf:	75 06                	jne    f01054d7 <memfind+0x1d>
f01054d1:	eb 0f                	jmp    f01054e2 <memfind+0x28>
f01054d3:	38 08                	cmp    %cl,(%eax)
f01054d5:	74 0b                	je     f01054e2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01054d7:	83 c0 01             	add    $0x1,%eax
f01054da:	39 d0                	cmp    %edx,%eax
f01054dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01054e0:	75 f1                	jne    f01054d3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01054e2:	5d                   	pop    %ebp
f01054e3:	c3                   	ret    

f01054e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01054e4:	55                   	push   %ebp
f01054e5:	89 e5                	mov    %esp,%ebp
f01054e7:	57                   	push   %edi
f01054e8:	56                   	push   %esi
f01054e9:	53                   	push   %ebx
f01054ea:	8b 55 08             	mov    0x8(%ebp),%edx
f01054ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01054f0:	0f b6 02             	movzbl (%edx),%eax
f01054f3:	3c 20                	cmp    $0x20,%al
f01054f5:	74 04                	je     f01054fb <strtol+0x17>
f01054f7:	3c 09                	cmp    $0x9,%al
f01054f9:	75 0e                	jne    f0105509 <strtol+0x25>
		s++;
f01054fb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01054fe:	0f b6 02             	movzbl (%edx),%eax
f0105501:	3c 20                	cmp    $0x20,%al
f0105503:	74 f6                	je     f01054fb <strtol+0x17>
f0105505:	3c 09                	cmp    $0x9,%al
f0105507:	74 f2                	je     f01054fb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105509:	3c 2b                	cmp    $0x2b,%al
f010550b:	75 0a                	jne    f0105517 <strtol+0x33>
		s++;
f010550d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105510:	bf 00 00 00 00       	mov    $0x0,%edi
f0105515:	eb 10                	jmp    f0105527 <strtol+0x43>
f0105517:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010551c:	3c 2d                	cmp    $0x2d,%al
f010551e:	75 07                	jne    f0105527 <strtol+0x43>
		s++, neg = 1;
f0105520:	83 c2 01             	add    $0x1,%edx
f0105523:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105527:	85 db                	test   %ebx,%ebx
f0105529:	0f 94 c0             	sete   %al
f010552c:	74 05                	je     f0105533 <strtol+0x4f>
f010552e:	83 fb 10             	cmp    $0x10,%ebx
f0105531:	75 15                	jne    f0105548 <strtol+0x64>
f0105533:	80 3a 30             	cmpb   $0x30,(%edx)
f0105536:	75 10                	jne    f0105548 <strtol+0x64>
f0105538:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010553c:	75 0a                	jne    f0105548 <strtol+0x64>
		s += 2, base = 16;
f010553e:	83 c2 02             	add    $0x2,%edx
f0105541:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105546:	eb 13                	jmp    f010555b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0105548:	84 c0                	test   %al,%al
f010554a:	74 0f                	je     f010555b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010554c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105551:	80 3a 30             	cmpb   $0x30,(%edx)
f0105554:	75 05                	jne    f010555b <strtol+0x77>
		s++, base = 8;
f0105556:	83 c2 01             	add    $0x1,%edx
f0105559:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010555b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105560:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105562:	0f b6 0a             	movzbl (%edx),%ecx
f0105565:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105568:	80 fb 09             	cmp    $0x9,%bl
f010556b:	77 08                	ja     f0105575 <strtol+0x91>
			dig = *s - '0';
f010556d:	0f be c9             	movsbl %cl,%ecx
f0105570:	83 e9 30             	sub    $0x30,%ecx
f0105573:	eb 1e                	jmp    f0105593 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0105575:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105578:	80 fb 19             	cmp    $0x19,%bl
f010557b:	77 08                	ja     f0105585 <strtol+0xa1>
			dig = *s - 'a' + 10;
f010557d:	0f be c9             	movsbl %cl,%ecx
f0105580:	83 e9 57             	sub    $0x57,%ecx
f0105583:	eb 0e                	jmp    f0105593 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0105585:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105588:	80 fb 19             	cmp    $0x19,%bl
f010558b:	77 14                	ja     f01055a1 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010558d:	0f be c9             	movsbl %cl,%ecx
f0105590:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105593:	39 f1                	cmp    %esi,%ecx
f0105595:	7d 0e                	jge    f01055a5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105597:	83 c2 01             	add    $0x1,%edx
f010559a:	0f af c6             	imul   %esi,%eax
f010559d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010559f:	eb c1                	jmp    f0105562 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01055a1:	89 c1                	mov    %eax,%ecx
f01055a3:	eb 02                	jmp    f01055a7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01055a5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01055a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01055ab:	74 05                	je     f01055b2 <strtol+0xce>
		*endptr = (char *) s;
f01055ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01055b0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01055b2:	89 ca                	mov    %ecx,%edx
f01055b4:	f7 da                	neg    %edx
f01055b6:	85 ff                	test   %edi,%edi
f01055b8:	0f 45 c2             	cmovne %edx,%eax
}
f01055bb:	5b                   	pop    %ebx
f01055bc:	5e                   	pop    %esi
f01055bd:	5f                   	pop    %edi
f01055be:	5d                   	pop    %ebp
f01055bf:	c3                   	ret    

f01055c0 <__udivdi3>:
f01055c0:	83 ec 1c             	sub    $0x1c,%esp
f01055c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01055c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f01055cb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01055cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01055d3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01055d7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01055db:	85 ff                	test   %edi,%edi
f01055dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01055e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055e5:	89 cd                	mov    %ecx,%ebp
f01055e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055eb:	75 33                	jne    f0105620 <__udivdi3+0x60>
f01055ed:	39 f1                	cmp    %esi,%ecx
f01055ef:	77 57                	ja     f0105648 <__udivdi3+0x88>
f01055f1:	85 c9                	test   %ecx,%ecx
f01055f3:	75 0b                	jne    f0105600 <__udivdi3+0x40>
f01055f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01055fa:	31 d2                	xor    %edx,%edx
f01055fc:	f7 f1                	div    %ecx
f01055fe:	89 c1                	mov    %eax,%ecx
f0105600:	89 f0                	mov    %esi,%eax
f0105602:	31 d2                	xor    %edx,%edx
f0105604:	f7 f1                	div    %ecx
f0105606:	89 c6                	mov    %eax,%esi
f0105608:	8b 44 24 04          	mov    0x4(%esp),%eax
f010560c:	f7 f1                	div    %ecx
f010560e:	89 f2                	mov    %esi,%edx
f0105610:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105614:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105618:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010561c:	83 c4 1c             	add    $0x1c,%esp
f010561f:	c3                   	ret    
f0105620:	31 d2                	xor    %edx,%edx
f0105622:	31 c0                	xor    %eax,%eax
f0105624:	39 f7                	cmp    %esi,%edi
f0105626:	77 e8                	ja     f0105610 <__udivdi3+0x50>
f0105628:	0f bd cf             	bsr    %edi,%ecx
f010562b:	83 f1 1f             	xor    $0x1f,%ecx
f010562e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105632:	75 2c                	jne    f0105660 <__udivdi3+0xa0>
f0105634:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0105638:	76 04                	jbe    f010563e <__udivdi3+0x7e>
f010563a:	39 f7                	cmp    %esi,%edi
f010563c:	73 d2                	jae    f0105610 <__udivdi3+0x50>
f010563e:	31 d2                	xor    %edx,%edx
f0105640:	b8 01 00 00 00       	mov    $0x1,%eax
f0105645:	eb c9                	jmp    f0105610 <__udivdi3+0x50>
f0105647:	90                   	nop
f0105648:	89 f2                	mov    %esi,%edx
f010564a:	f7 f1                	div    %ecx
f010564c:	31 d2                	xor    %edx,%edx
f010564e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105652:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105656:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010565a:	83 c4 1c             	add    $0x1c,%esp
f010565d:	c3                   	ret    
f010565e:	66 90                	xchg   %ax,%ax
f0105660:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105665:	b8 20 00 00 00       	mov    $0x20,%eax
f010566a:	89 ea                	mov    %ebp,%edx
f010566c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105670:	d3 e7                	shl    %cl,%edi
f0105672:	89 c1                	mov    %eax,%ecx
f0105674:	d3 ea                	shr    %cl,%edx
f0105676:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010567b:	09 fa                	or     %edi,%edx
f010567d:	89 f7                	mov    %esi,%edi
f010567f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105683:	89 f2                	mov    %esi,%edx
f0105685:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105689:	d3 e5                	shl    %cl,%ebp
f010568b:	89 c1                	mov    %eax,%ecx
f010568d:	d3 ef                	shr    %cl,%edi
f010568f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105694:	d3 e2                	shl    %cl,%edx
f0105696:	89 c1                	mov    %eax,%ecx
f0105698:	d3 ee                	shr    %cl,%esi
f010569a:	09 d6                	or     %edx,%esi
f010569c:	89 fa                	mov    %edi,%edx
f010569e:	89 f0                	mov    %esi,%eax
f01056a0:	f7 74 24 0c          	divl   0xc(%esp)
f01056a4:	89 d7                	mov    %edx,%edi
f01056a6:	89 c6                	mov    %eax,%esi
f01056a8:	f7 e5                	mul    %ebp
f01056aa:	39 d7                	cmp    %edx,%edi
f01056ac:	72 22                	jb     f01056d0 <__udivdi3+0x110>
f01056ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01056b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01056b7:	d3 e5                	shl    %cl,%ebp
f01056b9:	39 c5                	cmp    %eax,%ebp
f01056bb:	73 04                	jae    f01056c1 <__udivdi3+0x101>
f01056bd:	39 d7                	cmp    %edx,%edi
f01056bf:	74 0f                	je     f01056d0 <__udivdi3+0x110>
f01056c1:	89 f0                	mov    %esi,%eax
f01056c3:	31 d2                	xor    %edx,%edx
f01056c5:	e9 46 ff ff ff       	jmp    f0105610 <__udivdi3+0x50>
f01056ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01056d0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01056d3:	31 d2                	xor    %edx,%edx
f01056d5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01056d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01056dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01056e1:	83 c4 1c             	add    $0x1c,%esp
f01056e4:	c3                   	ret    
	...

f01056f0 <__umoddi3>:
f01056f0:	83 ec 1c             	sub    $0x1c,%esp
f01056f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01056f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f01056fb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01056ff:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105703:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0105707:	8b 74 24 24          	mov    0x24(%esp),%esi
f010570b:	85 ed                	test   %ebp,%ebp
f010570d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0105711:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105715:	89 cf                	mov    %ecx,%edi
f0105717:	89 04 24             	mov    %eax,(%esp)
f010571a:	89 f2                	mov    %esi,%edx
f010571c:	75 1a                	jne    f0105738 <__umoddi3+0x48>
f010571e:	39 f1                	cmp    %esi,%ecx
f0105720:	76 4e                	jbe    f0105770 <__umoddi3+0x80>
f0105722:	f7 f1                	div    %ecx
f0105724:	89 d0                	mov    %edx,%eax
f0105726:	31 d2                	xor    %edx,%edx
f0105728:	8b 74 24 10          	mov    0x10(%esp),%esi
f010572c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105730:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0105734:	83 c4 1c             	add    $0x1c,%esp
f0105737:	c3                   	ret    
f0105738:	39 f5                	cmp    %esi,%ebp
f010573a:	77 54                	ja     f0105790 <__umoddi3+0xa0>
f010573c:	0f bd c5             	bsr    %ebp,%eax
f010573f:	83 f0 1f             	xor    $0x1f,%eax
f0105742:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105746:	75 60                	jne    f01057a8 <__umoddi3+0xb8>
f0105748:	3b 0c 24             	cmp    (%esp),%ecx
f010574b:	0f 87 07 01 00 00    	ja     f0105858 <__umoddi3+0x168>
f0105751:	89 f2                	mov    %esi,%edx
f0105753:	8b 34 24             	mov    (%esp),%esi
f0105756:	29 ce                	sub    %ecx,%esi
f0105758:	19 ea                	sbb    %ebp,%edx
f010575a:	89 34 24             	mov    %esi,(%esp)
f010575d:	8b 04 24             	mov    (%esp),%eax
f0105760:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105764:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105768:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010576c:	83 c4 1c             	add    $0x1c,%esp
f010576f:	c3                   	ret    
f0105770:	85 c9                	test   %ecx,%ecx
f0105772:	75 0b                	jne    f010577f <__umoddi3+0x8f>
f0105774:	b8 01 00 00 00       	mov    $0x1,%eax
f0105779:	31 d2                	xor    %edx,%edx
f010577b:	f7 f1                	div    %ecx
f010577d:	89 c1                	mov    %eax,%ecx
f010577f:	89 f0                	mov    %esi,%eax
f0105781:	31 d2                	xor    %edx,%edx
f0105783:	f7 f1                	div    %ecx
f0105785:	8b 04 24             	mov    (%esp),%eax
f0105788:	f7 f1                	div    %ecx
f010578a:	eb 98                	jmp    f0105724 <__umoddi3+0x34>
f010578c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105790:	89 f2                	mov    %esi,%edx
f0105792:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105796:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010579a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010579e:	83 c4 1c             	add    $0x1c,%esp
f01057a1:	c3                   	ret    
f01057a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01057a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01057ad:	89 e8                	mov    %ebp,%eax
f01057af:	bd 20 00 00 00       	mov    $0x20,%ebp
f01057b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01057b8:	89 fa                	mov    %edi,%edx
f01057ba:	d3 e0                	shl    %cl,%eax
f01057bc:	89 e9                	mov    %ebp,%ecx
f01057be:	d3 ea                	shr    %cl,%edx
f01057c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01057c5:	09 c2                	or     %eax,%edx
f01057c7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01057cb:	89 14 24             	mov    %edx,(%esp)
f01057ce:	89 f2                	mov    %esi,%edx
f01057d0:	d3 e7                	shl    %cl,%edi
f01057d2:	89 e9                	mov    %ebp,%ecx
f01057d4:	d3 ea                	shr    %cl,%edx
f01057d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01057db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01057df:	d3 e6                	shl    %cl,%esi
f01057e1:	89 e9                	mov    %ebp,%ecx
f01057e3:	d3 e8                	shr    %cl,%eax
f01057e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01057ea:	09 f0                	or     %esi,%eax
f01057ec:	8b 74 24 08          	mov    0x8(%esp),%esi
f01057f0:	f7 34 24             	divl   (%esp)
f01057f3:	d3 e6                	shl    %cl,%esi
f01057f5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01057f9:	89 d6                	mov    %edx,%esi
f01057fb:	f7 e7                	mul    %edi
f01057fd:	39 d6                	cmp    %edx,%esi
f01057ff:	89 c1                	mov    %eax,%ecx
f0105801:	89 d7                	mov    %edx,%edi
f0105803:	72 3f                	jb     f0105844 <__umoddi3+0x154>
f0105805:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105809:	72 35                	jb     f0105840 <__umoddi3+0x150>
f010580b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010580f:	29 c8                	sub    %ecx,%eax
f0105811:	19 fe                	sbb    %edi,%esi
f0105813:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105818:	89 f2                	mov    %esi,%edx
f010581a:	d3 e8                	shr    %cl,%eax
f010581c:	89 e9                	mov    %ebp,%ecx
f010581e:	d3 e2                	shl    %cl,%edx
f0105820:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105825:	09 d0                	or     %edx,%eax
f0105827:	89 f2                	mov    %esi,%edx
f0105829:	d3 ea                	shr    %cl,%edx
f010582b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010582f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105833:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0105837:	83 c4 1c             	add    $0x1c,%esp
f010583a:	c3                   	ret    
f010583b:	90                   	nop
f010583c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105840:	39 d6                	cmp    %edx,%esi
f0105842:	75 c7                	jne    f010580b <__umoddi3+0x11b>
f0105844:	89 d7                	mov    %edx,%edi
f0105846:	89 c1                	mov    %eax,%ecx
f0105848:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010584c:	1b 3c 24             	sbb    (%esp),%edi
f010584f:	eb ba                	jmp    f010580b <__umoddi3+0x11b>
f0105851:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105858:	39 f5                	cmp    %esi,%ebp
f010585a:	0f 82 f1 fe ff ff    	jb     f0105751 <__umoddi3+0x61>
f0105860:	e9 f8 fe ff ff       	jmp    f010575d <__umoddi3+0x6d>
