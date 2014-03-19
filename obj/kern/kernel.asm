
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
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

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
f0100046:	b8 b0 fd 17 f0       	mov    $0xf017fdb0,%eax
f010004b:	2d b2 ee 17 f0       	sub    $0xf017eeb2,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 b2 ee 17 f0 	movl   $0xf017eeb2,(%esp)
f0100063:	e8 69 4b 00 00       	call   f0104bd1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 be 04 00 00       	call   f010052b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 e0 50 10 f0 	movl   $0xf01050e0,(%esp)
f010007c:	e8 f9 39 00 00       	call   f0103a7a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 8e 18 00 00       	call   f0101914 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 e3 35 00 00       	call   f010366e <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 5c 3a 00 00       	call   f0103af1 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100095:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010009c:	00 
f010009d:	c7 44 24 04 35 78 00 	movl   $0x7835,0x4(%esp)
f01000a4:	00 
f01000a5:	c7 04 24 7c c3 11 f0 	movl   $0xf011c37c,(%esp)
f01000ac:	e8 f4 36 00 00       	call   f01037a5 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000b1:	a1 08 f1 17 f0       	mov    0xf017f108,%eax
f01000b6:	89 04 24             	mov    %eax,(%esp)
f01000b9:	e8 2b 39 00 00       	call   f01039e9 <env_run>

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
f01000c9:	83 3d a0 fd 17 f0 00 	cmpl   $0x0,0xf017fda0
f01000d0:	75 3d                	jne    f010010f <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000d2:	89 35 a0 fd 17 f0    	mov    %esi,0xf017fda0

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
f01000eb:	c7 04 24 fb 50 10 f0 	movl   $0xf01050fb,(%esp)
f01000f2:	e8 83 39 00 00       	call   f0103a7a <cprintf>
	vcprintf(fmt, ap);
f01000f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000fb:	89 34 24             	mov    %esi,(%esp)
f01000fe:	e8 44 39 00 00       	call   f0103a47 <vcprintf>
	cprintf("\n");
f0100103:	c7 04 24 47 63 10 f0 	movl   $0xf0106347,(%esp)
f010010a:	e8 6b 39 00 00       	call   f0103a7a <cprintf>
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
f0100135:	c7 04 24 13 51 10 f0 	movl   $0xf0105113,(%esp)
f010013c:	e8 39 39 00 00       	call   f0103a7a <cprintf>
	vcprintf(fmt, ap);
f0100141:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100145:	8b 45 10             	mov    0x10(%ebp),%eax
f0100148:	89 04 24             	mov    %eax,(%esp)
f010014b:	e8 f7 38 00 00       	call   f0103a47 <vcprintf>
	cprintf("\n");
f0100150:	c7 04 24 47 63 10 f0 	movl   $0xf0106347,(%esp)
f0100157:	e8 1e 39 00 00       	call   f0103a7a <cprintf>
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
f01001a9:	8b 15 e4 f0 17 f0    	mov    0xf017f0e4,%edx
f01001af:	88 82 e0 ee 17 f0    	mov    %al,-0xfe81120(%edx)
f01001b5:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001b8:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01001c2:	0f 44 c2             	cmove  %edx,%eax
f01001c5:	a3 e4 f0 17 f0       	mov    %eax,0xf017f0e4
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
f010024c:	a1 78 c3 11 f0       	mov    0xf011c378,%eax
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
f0100292:	0f b7 15 f4 f0 17 f0 	movzwl 0xf017f0f4,%edx
f0100299:	66 85 d2             	test   %dx,%dx
f010029c:	0f 84 e3 00 00 00    	je     f0100385 <cons_putc+0x1ae>
			crt_pos--;
f01002a2:	83 ea 01             	sub    $0x1,%edx
f01002a5:	66 89 15 f4 f0 17 f0 	mov    %dx,0xf017f0f4
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002ac:	0f b7 d2             	movzwl %dx,%edx
f01002af:	b0 00                	mov    $0x0,%al
f01002b1:	83 c8 20             	or     $0x20,%eax
f01002b4:	8b 0d f0 f0 17 f0    	mov    0xf017f0f0,%ecx
f01002ba:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01002be:	eb 78                	jmp    f0100338 <cons_putc+0x161>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002c0:	66 83 05 f4 f0 17 f0 	addw   $0x50,0xf017f0f4
f01002c7:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002c8:	0f b7 05 f4 f0 17 f0 	movzwl 0xf017f0f4,%eax
f01002cf:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01002d5:	c1 e8 16             	shr    $0x16,%eax
f01002d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01002db:	c1 e0 04             	shl    $0x4,%eax
f01002de:	66 a3 f4 f0 17 f0    	mov    %ax,0xf017f0f4
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
f010031a:	0f b7 15 f4 f0 17 f0 	movzwl 0xf017f0f4,%edx
f0100321:	0f b7 da             	movzwl %dx,%ebx
f0100324:	8b 0d f0 f0 17 f0    	mov    0xf017f0f0,%ecx
f010032a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010032e:	83 c2 01             	add    $0x1,%edx
f0100331:	66 89 15 f4 f0 17 f0 	mov    %dx,0xf017f0f4
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100338:	66 81 3d f4 f0 17 f0 	cmpw   $0x7cf,0xf017f0f4
f010033f:	cf 07 
f0100341:	76 42                	jbe    f0100385 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100343:	a1 f0 f0 17 f0       	mov    0xf017f0f0,%eax
f0100348:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010034f:	00 
f0100350:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100356:	89 54 24 04          	mov    %edx,0x4(%esp)
f010035a:	89 04 24             	mov    %eax,(%esp)
f010035d:	e8 ca 48 00 00       	call   f0104c2c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100362:	8b 15 f0 f0 17 f0    	mov    0xf017f0f0,%edx
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
f010037d:	66 83 2d f4 f0 17 f0 	subw   $0x50,0xf017f0f4
f0100384:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100385:	8b 0d ec f0 17 f0    	mov    0xf017f0ec,%ecx
f010038b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100390:	89 ca                	mov    %ecx,%edx
f0100392:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100393:	0f b7 35 f4 f0 17 f0 	movzwl 0xf017f0f4,%esi
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
f01003de:	83 0d e8 f0 17 f0 40 	orl    $0x40,0xf017f0e8
		return 0;
f01003e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ea:	e9 c4 00 00 00       	jmp    f01004b3 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01003ef:	84 c0                	test   %al,%al
f01003f1:	79 37                	jns    f010042a <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003f3:	8b 0d e8 f0 17 f0    	mov    0xf017f0e8,%ecx
f01003f9:	89 cb                	mov    %ecx,%ebx
f01003fb:	83 e3 40             	and    $0x40,%ebx
f01003fe:	83 e0 7f             	and    $0x7f,%eax
f0100401:	85 db                	test   %ebx,%ebx
f0100403:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100406:	0f b6 d2             	movzbl %dl,%edx
f0100409:	0f b6 82 60 51 10 f0 	movzbl -0xfefaea0(%edx),%eax
f0100410:	83 c8 40             	or     $0x40,%eax
f0100413:	0f b6 c0             	movzbl %al,%eax
f0100416:	f7 d0                	not    %eax
f0100418:	21 c1                	and    %eax,%ecx
f010041a:	89 0d e8 f0 17 f0    	mov    %ecx,0xf017f0e8
		return 0;
f0100420:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100425:	e9 89 00 00 00       	jmp    f01004b3 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f010042a:	8b 0d e8 f0 17 f0    	mov    0xf017f0e8,%ecx
f0100430:	f6 c1 40             	test   $0x40,%cl
f0100433:	74 0e                	je     f0100443 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100435:	89 c2                	mov    %eax,%edx
f0100437:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010043a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010043d:	89 0d e8 f0 17 f0    	mov    %ecx,0xf017f0e8
	}

	shift |= shiftcode[data];
f0100443:	0f b6 d2             	movzbl %dl,%edx
f0100446:	0f b6 82 60 51 10 f0 	movzbl -0xfefaea0(%edx),%eax
f010044d:	0b 05 e8 f0 17 f0    	or     0xf017f0e8,%eax
	shift ^= togglecode[data];
f0100453:	0f b6 8a 60 52 10 f0 	movzbl -0xfefada0(%edx),%ecx
f010045a:	31 c8                	xor    %ecx,%eax
f010045c:	a3 e8 f0 17 f0       	mov    %eax,0xf017f0e8

	c = charcode[shift & (CTL | SHIFT)][data];
f0100461:	89 c1                	mov    %eax,%ecx
f0100463:	83 e1 03             	and    $0x3,%ecx
f0100466:	8b 0c 8d 60 53 10 f0 	mov    -0xfefaca0(,%ecx,4),%ecx
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
f010049c:	c7 04 24 2d 51 10 f0 	movl   $0xf010512d,(%esp)
f01004a3:	e8 d2 35 00 00       	call   f0103a7a <cprintf>
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
f01004c1:	80 3d c0 ee 17 f0 00 	cmpb   $0x0,0xf017eec0
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
f01004f8:	8b 15 e0 f0 17 f0    	mov    0xf017f0e0,%edx
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
f0100503:	3b 15 e4 f0 17 f0    	cmp    0xf017f0e4,%edx
f0100509:	74 1e                	je     f0100529 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010050b:	0f b6 82 e0 ee 17 f0 	movzbl -0xfe81120(%edx),%eax
f0100512:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100515:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010051b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100520:	0f 44 d1             	cmove  %ecx,%edx
f0100523:	89 15 e0 f0 17 f0    	mov    %edx,0xf017f0e0
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
f0100551:	c7 05 ec f0 17 f0 b4 	movl   $0x3b4,0xf017f0ec
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
f0100569:	c7 05 ec f0 17 f0 d4 	movl   $0x3d4,0xf017f0ec
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
f0100578:	8b 0d ec f0 17 f0    	mov    0xf017f0ec,%ecx
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
f010059d:	89 35 f0 f0 17 f0    	mov    %esi,0xf017f0f0

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005a3:	0f b6 d8             	movzbl %al,%ebx
f01005a6:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005a8:	66 89 3d f4 f0 17 f0 	mov    %di,0xf017f0f4
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
f01005fb:	a2 c0 ee 17 f0       	mov    %al,0xf017eec0
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
f010060c:	c7 04 24 39 51 10 f0 	movl   $0xf0105139,(%esp)
f0100613:	e8 62 34 00 00       	call   f0103a7a <cprintf>
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
f0100656:	c7 04 24 70 53 10 f0 	movl   $0xf0105370,(%esp)
f010065d:	e8 18 34 00 00       	call   f0103a7a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100662:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100669:	00 
f010066a:	c7 04 24 fc 54 10 f0 	movl   $0xf01054fc,(%esp)
f0100671:	e8 04 34 00 00       	call   f0103a7a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100676:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010067d:	00 
f010067e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100685:	f0 
f0100686:	c7 04 24 24 55 10 f0 	movl   $0xf0105524,(%esp)
f010068d:	e8 e8 33 00 00       	call   f0103a7a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100692:	c7 44 24 08 c5 50 10 	movl   $0x1050c5,0x8(%esp)
f0100699:	00 
f010069a:	c7 44 24 04 c5 50 10 	movl   $0xf01050c5,0x4(%esp)
f01006a1:	f0 
f01006a2:	c7 04 24 48 55 10 f0 	movl   $0xf0105548,(%esp)
f01006a9:	e8 cc 33 00 00       	call   f0103a7a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ae:	c7 44 24 08 b2 ee 17 	movl   $0x17eeb2,0x8(%esp)
f01006b5:	00 
f01006b6:	c7 44 24 04 b2 ee 17 	movl   $0xf017eeb2,0x4(%esp)
f01006bd:	f0 
f01006be:	c7 04 24 6c 55 10 f0 	movl   $0xf010556c,(%esp)
f01006c5:	e8 b0 33 00 00       	call   f0103a7a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ca:	c7 44 24 08 b0 fd 17 	movl   $0x17fdb0,0x8(%esp)
f01006d1:	00 
f01006d2:	c7 44 24 04 b0 fd 17 	movl   $0xf017fdb0,0x4(%esp)
f01006d9:	f0 
f01006da:	c7 04 24 90 55 10 f0 	movl   $0xf0105590,(%esp)
f01006e1:	e8 94 33 00 00       	call   f0103a7a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e6:	b8 af 01 18 f0       	mov    $0xf01801af,%eax
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
f0100707:	c7 04 24 b4 55 10 f0 	movl   $0xf01055b4,(%esp)
f010070e:	e8 67 33 00 00       	call   f0103a7a <cprintf>
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
f0100726:	8b 83 a4 58 10 f0    	mov    -0xfefa75c(%ebx),%eax
f010072c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100730:	8b 83 a0 58 10 f0    	mov    -0xfefa760(%ebx),%eax
f0100736:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073a:	c7 04 24 89 53 10 f0 	movl   $0xf0105389,(%esp)
f0100741:	e8 34 33 00 00       	call   f0103a7a <cprintf>
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
f010078f:	e8 b0 45 00 00       	call   f0104d44 <strtol>
f0100794:	89 c6                	mov    %eax,%esi

	unsigned int _pte;
	struct PageInfo *pageofva = page_lookup(kern_pgdir, (void *)num, (pte_t **)(&_pte));
f0100796:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100799:	89 44 24 08          	mov    %eax,0x8(%esp)
f010079d:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007a1:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01007a6:	89 04 24             	mov    %eax,(%esp)
f01007a9:	e8 e9 0f 00 00       	call   f0101797 <page_lookup>
	if(!pageofva)
f01007ae:	85 c0                	test   %eax,%eax
f01007b0:	0f 84 b6 01 00 00    	je     f010096c <mon_changepermission+0x213>
		return -1;

	unsigned int perm = 0;
	
	// set: set the permission bits completely to perm
	if(strcmp(argv[1], "-set") == 0) {
f01007b6:	c7 44 24 04 92 53 10 	movl   $0xf0105392,0x4(%esp)
f01007bd:	f0 
f01007be:	8b 43 04             	mov    0x4(%ebx),%eax
f01007c1:	89 04 24             	mov    %eax,(%esp)
f01007c4:	e8 32 43 00 00       	call   f0104afb <strcmp>
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
f01007e8:	e8 57 45 00 00       	call   f0104d44 <strtol>
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
f0100800:	c7 44 24 04 97 53 10 	movl   $0xf0105397,0x4(%esp)
f0100807:	f0 
f0100808:	8b 43 04             	mov    0x4(%ebx),%eax
f010080b:	89 04 24             	mov    %eax,(%esp)
f010080e:	e8 e8 42 00 00       	call   f0104afb <strcmp>
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
f010082b:	c7 44 24 04 9e 53 10 	movl   $0xf010539e,0x4(%esp)
f0100832:	f0 
f0100833:	8b 43 04             	mov    0x4(%ebx),%eax
f0100836:	89 04 24             	mov    %eax,(%esp)
f0100839:	e8 bd 42 00 00       	call   f0104afb <strcmp>
f010083e:	85 c0                	test   %eax,%eax
f0100840:	0f 85 0b 01 00 00    	jne    f0100951 <mon_changepermission+0x1f8>
		if(strcmp(argv[3], "PTE_P") == 0)
f0100846:	c7 44 24 04 54 63 10 	movl   $0xf0106354,0x4(%esp)
f010084d:	f0 
f010084e:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100851:	89 04 24             	mov    %eax,(%esp)
f0100854:	e8 a2 42 00 00       	call   f0104afb <strcmp>
f0100859:	85 c0                	test   %eax,%eax
f010085b:	75 06                	jne    f0100863 <mon_changepermission+0x10a>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_P;
f010085d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100860:	83 30 01             	xorl   $0x1,(%eax)
		if(strcmp(argv[3], "PTE_W") == 0)
f0100863:	c7 44 24 04 65 63 10 	movl   $0xf0106365,0x4(%esp)
f010086a:	f0 
f010086b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010086e:	89 04 24             	mov    %eax,(%esp)
f0100871:	e8 85 42 00 00       	call   f0104afb <strcmp>
f0100876:	85 c0                	test   %eax,%eax
f0100878:	75 06                	jne    f0100880 <mon_changepermission+0x127>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_W;
f010087a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010087d:	83 30 02             	xorl   $0x2,(%eax)
		if(strcmp(argv[3], "PTE_PWT") == 0)
f0100880:	c7 44 24 04 a6 53 10 	movl   $0xf01053a6,0x4(%esp)
f0100887:	f0 
f0100888:	8b 43 0c             	mov    0xc(%ebx),%eax
f010088b:	89 04 24             	mov    %eax,(%esp)
f010088e:	e8 68 42 00 00       	call   f0104afb <strcmp>
f0100893:	85 c0                	test   %eax,%eax
f0100895:	75 06                	jne    f010089d <mon_changepermission+0x144>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PWT;
f0100897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010089a:	83 30 08             	xorl   $0x8,(%eax)
		if(strcmp(argv[3], "PTE_U") == 0)
f010089d:	c7 44 24 04 c8 62 10 	movl   $0xf01062c8,0x4(%esp)
f01008a4:	f0 
f01008a5:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008a8:	89 04 24             	mov    %eax,(%esp)
f01008ab:	e8 4b 42 00 00       	call   f0104afb <strcmp>
f01008b0:	85 c0                	test   %eax,%eax
f01008b2:	75 06                	jne    f01008ba <mon_changepermission+0x161>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_U;
f01008b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008b7:	83 30 04             	xorl   $0x4,(%eax)
		if(strcmp(argv[3], "PTE_PCD") == 0)
f01008ba:	c7 44 24 04 ae 53 10 	movl   $0xf01053ae,0x4(%esp)
f01008c1:	f0 
f01008c2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008c5:	89 04 24             	mov    %eax,(%esp)
f01008c8:	e8 2e 42 00 00       	call   f0104afb <strcmp>
f01008cd:	85 c0                	test   %eax,%eax
f01008cf:	75 06                	jne    f01008d7 <mon_changepermission+0x17e>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PCD;
f01008d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008d4:	83 30 10             	xorl   $0x10,(%eax)
		if(strcmp(argv[3], "PTE_A") == 0)
f01008d7:	c7 44 24 04 b6 53 10 	movl   $0xf01053b6,0x4(%esp)
f01008de:	f0 
f01008df:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008e2:	89 04 24             	mov    %eax,(%esp)
f01008e5:	e8 11 42 00 00       	call   f0104afb <strcmp>
f01008ea:	85 c0                	test   %eax,%eax
f01008ec:	75 06                	jne    f01008f4 <mon_changepermission+0x19b>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_A;
f01008ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008f1:	83 30 20             	xorl   $0x20,(%eax)
		if(strcmp(argv[3], "PTE_D") == 0)
f01008f4:	c7 44 24 04 bc 53 10 	movl   $0xf01053bc,0x4(%esp)
f01008fb:	f0 
f01008fc:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008ff:	89 04 24             	mov    %eax,(%esp)
f0100902:	e8 f4 41 00 00       	call   f0104afb <strcmp>
f0100907:	85 c0                	test   %eax,%eax
f0100909:	75 06                	jne    f0100911 <mon_changepermission+0x1b8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_D;
f010090b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010090e:	83 30 40             	xorl   $0x40,(%eax)
		if(strcmp(argv[3], "PTE_PS") == 0)
f0100911:	c7 44 24 04 c2 53 10 	movl   $0xf01053c2,0x4(%esp)
f0100918:	f0 
f0100919:	8b 43 0c             	mov    0xc(%ebx),%eax
f010091c:	89 04 24             	mov    %eax,(%esp)
f010091f:	e8 d7 41 00 00       	call   f0104afb <strcmp>
f0100924:	85 c0                	test   %eax,%eax
f0100926:	75 09                	jne    f0100931 <mon_changepermission+0x1d8>
			*((pte_t *)_pte) = *((pte_t *)_pte) ^ PTE_PS;
f0100928:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010092b:	81 30 80 00 00 00    	xorl   $0x80,(%eax)
		if(strcmp(argv[3], "PTE_G") == 0)
f0100931:	c7 44 24 04 c9 53 10 	movl   $0xf01053c9,0x4(%esp)
f0100938:	f0 
f0100939:	8b 43 0c             	mov    0xc(%ebx),%eax
f010093c:	89 04 24             	mov    %eax,(%esp)
f010093f:	e8 b7 41 00 00       	call   f0104afb <strcmp>
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
f0100959:	c7 04 24 cf 53 10 f0 	movl   $0xf01053cf,(%esp)
f0100960:	e8 15 31 00 00       	call   f0103a7a <cprintf>
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
f01009aa:	e8 95 43 00 00       	call   f0104d44 <strtol>
f01009af:	89 c3                	mov    %eax,%ebx
	num[1] = strtol(argv[2], NULL, 16);
f01009b1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01009b8:	00 
f01009b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009c0:	00 
f01009c1:	8b 46 08             	mov    0x8(%esi),%eax
f01009c4:	89 04 24             	mov    %eax,(%esp)
f01009c7:	e8 78 43 00 00       	call   f0104d44 <strtol>
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
f01009e2:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01009e7:	89 04 24             	mov    %eax,(%esp)
f01009ea:	e8 a8 0d 00 00       	call   f0101797 <page_lookup>

		if(!pageofva) {
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	75 0e                	jne    f0100a01 <mon_showmappings+0x88>
			cprintf("0x%x: There is no physical page here.\n");
f01009f3:	c7 04 24 e0 55 10 f0 	movl   $0xf01055e0,(%esp)
f01009fa:	e8 7b 30 00 00       	call   f0103a7a <cprintf>
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
f0100a1f:	c7 04 24 08 56 10 f0 	movl   $0xf0105608,(%esp)
f0100a26:	e8 4f 30 00 00       	call   f0103a7a <cprintf>
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
f0100a82:	c7 04 24 eb 53 10 f0 	movl   $0xf01053eb,(%esp)
f0100a89:	e8 ec 2f 00 00       	call   f0103a7a <cprintf>
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
f0100ad5:	c7 04 24 3c 56 10 f0 	movl   $0xf010563c,(%esp)
f0100adc:	e8 99 2f 00 00       	call   f0103a7a <cprintf>
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
f0100ae1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae8:	89 1c 24             	mov    %ebx,(%esp)
f0100aeb:	e8 de 34 00 00       	call   f0103fce <debuginfo_eip>
f0100af0:	85 c0                	test   %eax,%eax
f0100af2:	0f 88 93 00 00 00    	js     f0100b8b <mon_backtrace+0x149>
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);
f0100af8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100afb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aff:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100b05:	89 04 24             	mov    %eax,(%esp)
f0100b08:	e8 2e 3f 00 00       	call   f0104a3b <strcpy>

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
f0100b2a:	e8 57 3f 00 00       	call   f0104a86 <strncpy>
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
f0100b56:	c7 04 24 fd 53 10 f0 	movl   $0xf01053fd,(%esp)
f0100b5d:	e8 18 2f 00 00       	call   f0103a7a <cprintf>
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
f0100bc7:	e8 78 41 00 00       	call   f0104d44 <strtol>
f0100bcc:	89 c3                	mov    %eax,%ebx
	unsigned int len = strtol(argv[3], NULL, 16);
f0100bce:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100bd5:	00 
f0100bd6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100bdd:	00 
f0100bde:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100be1:	8b 42 0c             	mov    0xc(%edx),%eax
f0100be4:	89 04 24             	mov    %eax,(%esp)
f0100be7:	e8 58 41 00 00       	call   f0104d44 <strtol>
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
f0100c23:	c7 04 24 14 54 10 f0 	movl   $0xf0105414,(%esp)
f0100c2a:	e8 4b 2e 00 00       	call   f0103a7a <cprintf>

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
f0100c41:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
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
f0100c60:	c7 04 24 2d 54 10 f0 	movl   $0xf010542d,(%esp)
f0100c67:	e8 0e 2e 00 00       	call   f0103a7a <cprintf>
f0100c6c:	eb 0c                	jmp    f0100c7a <mon_dump+0xdf>
			else
				cprintf("---- ");
f0100c6e:	c7 04 24 35 54 10 f0 	movl   $0xf0105435,(%esp)
f0100c75:	e8 00 2e 00 00       	call   f0103a7a <cprintf>
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
f0100c8f:	c7 04 24 47 63 10 f0 	movl   $0xf0106347,(%esp)
f0100c96:	e8 df 2d 00 00       	call   f0103a7a <cprintf>
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
f0100cd2:	bf 00 20 11 f0       	mov    $0xf0112000,%edi
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
f0100ce6:	c7 04 24 3b 54 10 f0 	movl   $0xf010543b,(%esp)
f0100ced:	e8 88 2d 00 00       	call   f0103a7a <cprintf>
			unsigned int _addr = addr + i*4;
			if(_addr >= PADDR((void *)pages) && _addr < PADDR((void *)pages + PTSIZE))
f0100cf2:	a1 ac fd 17 f0       	mov    0xf017fdac,%eax
f0100cf7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100cfc:	77 20                	ja     f0100d1e <mon_dump+0x183>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d02:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0100d09:	f0 
f0100d0a:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100d11:	00 
f0100d12:	c7 04 24 55 54 10 f0 	movl   $0xf0105455,(%esp)
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
f0100d3e:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0100d45:	f0 
f0100d46:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
f0100d4d:	00 
f0100d4e:	c7 04 24 55 54 10 f0 	movl   $0xf0105455,(%esp)
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
f0100d74:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0100d7b:	f0 
f0100d7c:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f0100d83:	00 
f0100d84:	c7 04 24 55 54 10 f0 	movl   $0xf0105455,(%esp)
f0100d8b:	e8 2e f3 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d90:	89 da                	mov    %ebx,%edx
f0100d92:	29 c2                	sub    %eax,%edx
f0100d94:	8b 82 00 00 00 f0    	mov    -0x10000000(%edx),%eax
f0100d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d9e:	c7 04 24 2d 54 10 f0 	movl   $0xf010542d,(%esp)
f0100da5:	e8 d0 2c 00 00       	call   f0103a7a <cprintf>
f0100daa:	e9 b0 00 00 00       	jmp    f0100e5f <mon_dump+0x2c4>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100daf:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100db5:	77 24                	ja     f0100ddb <mon_dump+0x240>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100db7:	c7 44 24 0c 00 20 11 	movl   $0xf0112000,0xc(%esp)
f0100dbe:	f0 
f0100dbf:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0100dc6:	f0 
f0100dc7:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100dce:	00 
f0100dcf:	c7 04 24 55 54 10 f0 	movl   $0xf0105455,(%esp)
f0100dd6:	e8 e3 f2 ff ff       	call   f01000be <_panic>
			else if(_addr >= PADDR((void *)bootstack) && _addr < PADDR((void *)bootstack + KSTKSIZE))
f0100ddb:	81 fb 00 20 11 00    	cmp    $0x112000,%ebx
f0100de1:	72 50                	jb     f0100e33 <mon_dump+0x298>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100de3:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f0100de8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ded:	77 20                	ja     f0100e0f <mon_dump+0x274>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100def:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100df3:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0100dfa:	f0 
f0100dfb:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0100e02:	00 
f0100e03:	c7 04 24 55 54 10 f0 	movl   $0xf0105455,(%esp)
f0100e0a:	e8 af f2 ff ff       	call   f01000be <_panic>
f0100e0f:	81 fb 00 a0 11 00    	cmp    $0x11a000,%ebx
f0100e15:	73 1c                	jae    f0100e33 <mon_dump+0x298>
				cprintf("0x%08x ", 
f0100e17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100e1a:	8b 84 13 00 80 ff ce 	mov    -0x31008000(%ebx,%edx,1),%eax
f0100e21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e25:	c7 04 24 2d 54 10 f0 	movl   $0xf010542d,(%esp)
f0100e2c:	e8 49 2c 00 00       	call   f0103a7a <cprintf>
f0100e31:	eb 2c                	jmp    f0100e5f <mon_dump+0x2c4>
					*(uint32_t *)(_addr - PADDR((void *)bootstack) + UPAGES + KSTACKTOP-KSTKSIZE));
			else if(_addr >= 0 && _addr < ~KERNBASE+1)
f0100e33:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
f0100e39:	77 18                	ja     f0100e53 <mon_dump+0x2b8>
				cprintf("0x%08x ", 
f0100e3b:	8b 83 00 00 00 f0    	mov    -0x10000000(%ebx),%eax
f0100e41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e45:	c7 04 24 2d 54 10 f0 	movl   $0xf010542d,(%esp)
f0100e4c:	e8 29 2c 00 00       	call   f0103a7a <cprintf>
f0100e51:	eb 0c                	jmp    f0100e5f <mon_dump+0x2c4>
					*(uint32_t *)(_addr + KERNBASE));
			else 
				cprintf("---- ");
f0100e53:	c7 04 24 35 54 10 f0 	movl   $0xf0105435,(%esp)
f0100e5a:	e8 1b 2c 00 00       	call   f0103a7a <cprintf>
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
f0100e74:	c7 04 24 47 63 10 f0 	movl   $0xf0106347,(%esp)
f0100e7b:	e8 fa 2b 00 00       	call   f0103a7a <cprintf>
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
f0100eb5:	c7 04 24 94 56 10 f0 	movl   $0xf0105694,(%esp)
f0100ebc:	e8 b9 2b 00 00       	call   f0103a7a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ec1:	c7 04 24 b8 56 10 f0 	movl   $0xf01056b8,(%esp)
f0100ec8:	e8 ad 2b 00 00       	call   f0103a7a <cprintf>

	if (tf != NULL)
f0100ecd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ed1:	74 0b                	je     f0100ede <monitor+0x32>
		print_trapframe(tf);
f0100ed3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed6:	89 04 24             	mov    %eax,(%esp)
f0100ed9:	e8 c4 2c 00 00       	call   f0103ba2 <print_trapframe>

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
f0100ede:	c7 04 24 e0 56 10 f0 	movl   $0xf01056e0,(%esp)
f0100ee5:	e8 90 2b 00 00       	call   f0103a7a <cprintf>
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
f0100eea:	c7 04 24 14 57 10 f0 	movl   $0xf0105714,(%esp)
f0100ef1:	e8 84 2b 00 00       	call   f0103a7a <cprintf>
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);


	while (1) {
		buf = readline("K> ");
f0100ef6:	c7 04 24 64 54 10 f0 	movl   $0xf0105464,(%esp)
f0100efd:	e8 1e 3a 00 00       	call   f0104920 <readline>
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
f0100f2a:	c7 04 24 68 54 10 f0 	movl   $0xf0105468,(%esp)
f0100f31:	e8 40 3c 00 00       	call   f0104b76 <strchr>
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
f0100f4c:	c7 04 24 6d 54 10 f0 	movl   $0xf010546d,(%esp)
f0100f53:	e8 22 2b 00 00       	call   f0103a7a <cprintf>
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
f0100f7b:	c7 04 24 68 54 10 f0 	movl   $0xf0105468,(%esp)
f0100f82:	e8 ef 3b 00 00       	call   f0104b76 <strchr>
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
f0100f9d:	bb a0 58 10 f0       	mov    $0xf01058a0,%ebx
f0100fa2:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100fa7:	8b 03                	mov    (%ebx),%eax
f0100fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fad:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100fb0:	89 04 24             	mov    %eax,(%esp)
f0100fb3:	e8 43 3b 00 00       	call   f0104afb <strcmp>
f0100fb8:	85 c0                	test   %eax,%eax
f0100fba:	75 24                	jne    f0100fe0 <monitor+0x134>
			return commands[i].func(argc, argv, tf);
f0100fbc:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100fbf:	8b 55 08             	mov    0x8(%ebp),%edx
f0100fc2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100fc6:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100fc9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100fcd:	89 34 24             	mov    %esi,(%esp)
f0100fd0:	ff 14 85 a8 58 10 f0 	call   *-0xfefa758(,%eax,4)


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
f0100ff2:	c7 04 24 8a 54 10 f0 	movl   $0xf010548a,(%esp)
f0100ff9:	e8 7c 2a 00 00       	call   f0103a7a <cprintf>
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
f010102f:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f0101035:	72 20                	jb     f0101057 <check_va2pa+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101037:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010103b:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f0101042:	f0 
f0101043:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f010104a:	00 
f010104b:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
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
f0101089:	83 3d fc f0 17 f0 00 	cmpl   $0x0,0xf017f0fc
f0101090:	75 11                	jne    f01010a3 <boot_alloc+0x26>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101092:	ba af 0d 18 f0       	mov    $0xf0180daf,%edx
f0101097:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010109d:	89 15 fc f0 17 f0    	mov    %edx,0xf017f0fc
	// LAB 2: Your code here.

	// The amount of pages left.
	// Initialize npages_left if this is the first time.
	static size_t npages_left = -1;
	if(npages_left == -1) {
f01010a3:	83 3d 00 c3 11 f0 ff 	cmpl   $0xffffffff,0xf011c300
f01010aa:	75 0c                	jne    f01010b8 <boot_alloc+0x3b>
		npages_left = npages;
f01010ac:	8b 15 a4 fd 17 f0    	mov    0xf017fda4,%edx
f01010b2:	89 15 00 c3 11 f0    	mov    %edx,0xf011c300
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
f01010bc:	83 3d 00 c3 11 f0 00 	cmpl   $0x0,0xf011c300
f01010c3:	75 1c                	jne    f01010e1 <boot_alloc+0x64>
			panic("Out of memory!\n");
f01010c5:	c7 44 24 08 9d 60 10 	movl   $0xf010609d,0x8(%esp)
f01010cc:	f0 
f01010cd:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
f01010d4:	00 
f01010d5:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01010dc:	e8 dd ef ff ff       	call   f01000be <_panic>
		}
		result = nextfree;
f01010e1:	a1 fc f0 17 f0       	mov    0xf017f0fc,%eax
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
f01010fd:	c7 04 24 ad 60 10 f0 	movl   $0xf01060ad,(%esp)
f0101104:	e8 71 29 00 00       	call   f0103a7a <cprintf>

		if(npages_left < srequest/PGSIZE) {
f0101109:	8b 15 00 c3 11 f0    	mov    0xf011c300,%edx
f010110f:	39 d3                	cmp    %edx,%ebx
f0101111:	76 1c                	jbe    f010112f <boot_alloc+0xb2>
			panic("Out of memory!\n");
f0101113:	c7 44 24 08 9d 60 10 	movl   $0xf010609d,0x8(%esp)
f010111a:	f0 
f010111b:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
f0101122:	00 
f0101123:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010112a:	e8 8f ef ff ff       	call   f01000be <_panic>
		}
		result = nextfree;
f010112f:	a1 fc f0 17 f0       	mov    0xf017f0fc,%eax
		nextfree += srequest;
f0101134:	01 c6                	add    %eax,%esi
f0101136:	89 35 fc f0 17 f0    	mov    %esi,0xf017f0fc
		npages_left -= srequest/PGSIZE;
f010113c:	29 da                	sub    %ebx,%edx
f010113e:	89 15 00 c3 11 f0    	mov    %edx,0xf011c300

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
f010115f:	e8 a8 28 00 00       	call   f0103a0c <mc146818_read>
f0101164:	89 c6                	mov    %eax,%esi
f0101166:	83 c3 01             	add    $0x1,%ebx
f0101169:	89 1c 24             	mov    %ebx,(%esp)
f010116c:	e8 9b 28 00 00       	call   f0103a0c <mc146818_read>
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
f0101196:	8b 1d 00 f1 17 f0    	mov    0xf017f100,%ebx
f010119c:	85 db                	test   %ebx,%ebx
f010119e:	75 1c                	jne    f01011bc <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f01011a0:	c7 44 24 08 0c 59 10 	movl   $0xf010590c,0x8(%esp)
f01011a7:	f0 
f01011a8:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f01011af:	00 
f01011b0:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
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
f01011ce:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
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
f0101206:	89 1d 00 f1 17 f0    	mov    %ebx,0xf017f100
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010120c:	85 db                	test   %ebx,%ebx
f010120e:	74 67                	je     f0101277 <check_page_free_list+0xf7>
f0101210:	89 d8                	mov    %ebx,%eax
f0101212:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
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
f010122c:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f0101232:	72 20                	jb     f0101254 <check_page_free_list+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101234:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101238:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f010123f:	f0 
f0101240:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101247:	00 
f0101248:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f010124f:	e8 6a ee ff ff       	call   f01000be <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101254:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010125b:	00 
f010125c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101263:	00 
	return (void *)(pa + KERNBASE);
f0101264:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101269:	89 04 24             	mov    %eax,(%esp)
f010126c:	e8 60 39 00 00       	call   f0104bd1 <memset>
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
f0101284:	8b 15 00 f1 17 f0    	mov    0xf017f100,%edx
f010128a:	85 d2                	test   %edx,%edx
f010128c:	0f 84 f6 01 00 00    	je     f0101488 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101292:	8b 1d ac fd 17 f0    	mov    0xf017fdac,%ebx
f0101298:	39 da                	cmp    %ebx,%edx
f010129a:	72 4d                	jb     f01012e9 <check_page_free_list+0x169>
		assert(pp < pages + npages);
f010129c:	a1 a4 fd 17 f0       	mov    0xf017fda4,%eax
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
f01012e9:	c7 44 24 0c c7 60 10 	movl   $0xf01060c7,0xc(%esp)
f01012f0:	f0 
f01012f1:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01012f8:	f0 
f01012f9:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0101300:	00 
f0101301:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101308:	e8 b1 ed ff ff       	call   f01000be <_panic>
		assert(pp < pages + npages);
f010130d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101310:	72 24                	jb     f0101336 <check_page_free_list+0x1b6>
f0101312:	c7 44 24 0c e8 60 10 	movl   $0xf01060e8,0xc(%esp)
f0101319:	f0 
f010131a:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101321:	f0 
f0101322:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101329:	00 
f010132a:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101331:	e8 88 ed ff ff       	call   f01000be <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101336:	89 d0                	mov    %edx,%eax
f0101338:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010133b:	a8 07                	test   $0x7,%al
f010133d:	74 24                	je     f0101363 <check_page_free_list+0x1e3>
f010133f:	c7 44 24 0c 30 59 10 	movl   $0xf0105930,0xc(%esp)
f0101346:	f0 
f0101347:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010134e:	f0 
f010134f:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f0101356:	00 
f0101357:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010135e:	e8 5b ed ff ff       	call   f01000be <_panic>
f0101363:	c1 f8 03             	sar    $0x3,%eax
f0101366:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101369:	85 c0                	test   %eax,%eax
f010136b:	75 24                	jne    f0101391 <check_page_free_list+0x211>
f010136d:	c7 44 24 0c fc 60 10 	movl   $0xf01060fc,0xc(%esp)
f0101374:	f0 
f0101375:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010137c:	f0 
f010137d:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0101384:	00 
f0101385:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010138c:	e8 2d ed ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101391:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101396:	75 24                	jne    f01013bc <check_page_free_list+0x23c>
f0101398:	c7 44 24 0c 0d 61 10 	movl   $0xf010610d,0xc(%esp)
f010139f:	f0 
f01013a0:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01013a7:	f0 
f01013a8:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01013af:	00 
f01013b0:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01013b7:	e8 02 ed ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013bc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01013c1:	75 24                	jne    f01013e7 <check_page_free_list+0x267>
f01013c3:	c7 44 24 0c 64 59 10 	movl   $0xf0105964,0xc(%esp)
f01013ca:	f0 
f01013cb:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01013d2:	f0 
f01013d3:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01013da:	00 
f01013db:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01013e2:	e8 d7 ec ff ff       	call   f01000be <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01013e7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01013ec:	75 24                	jne    f0101412 <check_page_free_list+0x292>
f01013ee:	c7 44 24 0c 26 61 10 	movl   $0xf0106126,0xc(%esp)
f01013f5:	f0 
f01013f6:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0101405:	00 
f0101406:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
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
f0101427:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f010142e:	f0 
f010142f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101436:	00 
f0101437:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f010143e:	e8 7b ec ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0101443:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101449:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010144c:	76 29                	jbe    f0101477 <check_page_free_list+0x2f7>
f010144e:	c7 44 24 0c 88 59 10 	movl   $0xf0105988,0xc(%esp)
f0101455:	f0 
f0101456:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010145d:	f0 
f010145e:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f0101465:	00 
f0101466:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
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
f0101488:	c7 44 24 0c 40 61 10 	movl   $0xf0106140,0xc(%esp)
f010148f:	f0 
f0101490:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101497:	f0 
f0101498:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f010149f:	00 
f01014a0:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01014a7:	e8 12 ec ff ff       	call   f01000be <_panic>
	assert(nfree_extmem > 0);
f01014ac:	85 f6                	test   %esi,%esi
f01014ae:	7f 24                	jg     f01014d4 <check_page_free_list+0x354>
f01014b0:	c7 44 24 0c 52 61 10 	movl   $0xf0106152,0xc(%esp)
f01014b7:	f0 
f01014b8:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01014bf:	f0 
f01014c0:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f01014c7:	00 
f01014c8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01014cf:	e8 ea eb ff ff       	call   f01000be <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01014d4:	c7 04 24 d0 59 10 f0 	movl   $0xf01059d0,(%esp)
f01014db:	e8 9a 25 00 00       	call   f0103a7a <cprintf>
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
f01014f1:	83 3d a4 fd 17 f0 00 	cmpl   $0x0,0xf017fda4
f01014f8:	0f 85 98 00 00 00    	jne    f0101596 <page_init+0xae>
f01014fe:	e9 a5 00 00 00       	jmp    f01015a8 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f0101503:	a1 ac fd 17 f0       	mov    0xf017fdac,%eax
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
f0101541:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0101548:	f0 
f0101549:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
f0101550:	00 
f0101551:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101558:	e8 61 eb ff ff       	call   f01000be <_panic>
f010155d:	05 ff 0f 00 10       	add    $0x10000fff,%eax
f0101562:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101567:	39 f8                	cmp    %edi,%eax
f0101569:	77 1a                	ja     f0101585 <page_init+0x9d>
			continue;	
		}
		
		// others is free
		pages[i].pp_link = page_free_list;
f010156b:	8b 15 00 f1 17 f0    	mov    0xf017f100,%edx
f0101571:	a1 ac fd 17 f0       	mov    0xf017fdac,%eax
f0101576:	89 14 30             	mov    %edx,(%eax,%esi,1)
		page_free_list = &pages[i];
f0101579:	03 35 ac fd 17 f0    	add    0xf017fdac,%esi
f010157f:	89 35 00 f1 17 f0    	mov    %esi,0xf017f100
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	size_t i;
	for (i = 0; i < npages; i++) {
f0101585:	83 c3 01             	add    $0x1,%ebx
f0101588:	39 1d a4 fd 17 f0    	cmp    %ebx,0xf017fda4
f010158e:	0f 87 6f ff ff ff    	ja     f0101503 <page_init+0x1b>
f0101594:	eb 12                	jmp    f01015a8 <page_init+0xc0>
		
		pages[i].pp_ref = 0;
f0101596:	a1 ac fd 17 f0       	mov    0xf017fdac,%eax
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
f01015b7:	8b 1d 00 f1 17 f0    	mov    0xf017f100,%ebx
f01015bd:	85 db                	test   %ebx,%ebx
f01015bf:	74 65                	je     f0101626 <page_alloc+0x76>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f01015c1:	8b 03                	mov    (%ebx),%eax
f01015c3:	a3 00 f1 17 f0       	mov    %eax,0xf017f100
		
		if(alloc_flags & ALLOC_ZERO) { 
f01015c8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01015cc:	74 58                	je     f0101626 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015ce:	89 d8                	mov    %ebx,%eax
f01015d0:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015dc:	89 c2                	mov    %eax,%edx
f01015de:	c1 ea 0c             	shr    $0xc,%edx
f01015e1:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f01015e7:	72 20                	jb     f0101609 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015ed:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f01015f4:	f0 
f01015f5:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01015fc:	00 
f01015fd:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
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
f0101621:	e8 ab 35 00 00       	call   f0104bd1 <memset>
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
f010163b:	c7 44 24 08 f4 59 10 	movl   $0xf01059f4,0x8(%esp)
f0101642:	f0 
f0101643:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f010164a:	00 
f010164b:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101652:	e8 67 ea ff ff       	call   f01000be <_panic>
	pp->pp_link = page_free_list;
f0101657:	8b 15 00 f1 17 f0    	mov    0xf017f100,%edx
f010165d:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010165f:	a3 00 f1 17 f0       	mov    %eax,0xf017f100
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
f01016bf:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
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
f01016dc:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f01016e2:	72 20                	jb     f0101704 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016e8:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f01016ef:	f0 
f01016f0:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
f01016f7:	00 
f01016f8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
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
f01017ce:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f01017d4:	72 1c                	jb     f01017f2 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01017d6:	c7 44 24 08 18 5a 10 	movl   $0xf0105a18,0x8(%esp)
f01017dd:	f0 
f01017de:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f01017e5:	00 
f01017e6:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f01017ed:	e8 cc e8 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f01017f2:	c1 e0 03             	shl    $0x3,%eax
f01017f5:	03 05 ac fd 17 f0    	add    0xf017fdac,%eax
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
f01018a9:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
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
f01018e6:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
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
f0101938:	a3 f8 f0 17 f0       	mov    %eax,0xf017f0f8
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
f0101962:	89 15 a4 fd 17 f0    	mov    %edx,0xf017fda4
f0101968:	eb 0c                	jmp    f0101976 <mem_init+0x62>
	else
		npages = npages_basemem;
f010196a:	8b 15 f8 f0 17 f0    	mov    0xf017f0f8,%edx
f0101970:	89 15 a4 fd 17 f0    	mov    %edx,0xf017fda4

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
f0101980:	a1 f8 f0 17 f0       	mov    0xf017f0f8,%eax
f0101985:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101988:	c1 e8 0a             	shr    $0xa,%eax
f010198b:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f010198f:	a1 a4 fd 17 f0       	mov    0xf017fda4,%eax
f0101994:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101997:	c1 e8 0a             	shr    $0xa,%eax
f010199a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010199e:	c7 04 24 38 5a 10 f0 	movl   $0xf0105a38,(%esp)
f01019a5:	e8 d0 20 00 00       	call   f0103a7a <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019aa:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019af:	e8 c9 f6 ff ff       	call   f010107d <boot_alloc>
f01019b4:	a3 a8 fd 17 f0       	mov    %eax,0xf017fda8
	memset(kern_pgdir, 0, PGSIZE);
f01019b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019c0:	00 
f01019c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019c8:	00 
f01019c9:	89 04 24             	mov    %eax,(%esp)
f01019cc:	e8 00 32 00 00       	call   f0104bd1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01019d1:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01019d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01019db:	77 20                	ja     f01019fd <mem_init+0xe9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01019dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019e1:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f01019e8:	f0 
f01019e9:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
f01019f0:	00 
f01019f1:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
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
f0101a0c:	a1 a4 fd 17 f0       	mov    0xf017fda4,%eax
f0101a11:	c1 e0 03             	shl    $0x3,%eax
	pages = (struct PageInfo *)boot_alloc(pagesneed);
f0101a14:	e8 64 f6 ff ff       	call   f010107d <boot_alloc>
f0101a19:	a3 ac fd 17 f0       	mov    %eax,0xf017fdac
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a1e:	e8 c5 fa ff ff       	call   f01014e8 <page_init>

	check_page_free_list(1);
f0101a23:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a28:	e8 53 f7 ff ff       	call   f0101180 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a2d:	83 3d ac fd 17 f0 00 	cmpl   $0x0,0xf017fdac
f0101a34:	75 1c                	jne    f0101a52 <mem_init+0x13e>
		panic("'pages' is a null pointer!");
f0101a36:	c7 44 24 08 63 61 10 	movl   $0xf0106163,0x8(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0101a45:	00 
f0101a46:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101a4d:	e8 6c e6 ff ff       	call   f01000be <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a52:	a1 00 f1 17 f0       	mov    0xf017f100,%eax
f0101a57:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a5c:	85 c0                	test   %eax,%eax
f0101a5e:	74 09                	je     f0101a69 <mem_init+0x155>
		++nfree;
f0101a60:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a63:	8b 00                	mov    (%eax),%eax
f0101a65:	85 c0                	test   %eax,%eax
f0101a67:	75 f7                	jne    f0101a60 <mem_init+0x14c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a70:	e8 3b fb ff ff       	call   f01015b0 <page_alloc>
f0101a75:	89 c6                	mov    %eax,%esi
f0101a77:	85 c0                	test   %eax,%eax
f0101a79:	75 24                	jne    f0101a9f <mem_init+0x18b>
f0101a7b:	c7 44 24 0c 7e 61 10 	movl   $0xf010617e,0xc(%esp)
f0101a82:	f0 
f0101a83:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101a8a:	f0 
f0101a8b:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0101a92:	00 
f0101a93:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101a9a:	e8 1f e6 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101a9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa6:	e8 05 fb ff ff       	call   f01015b0 <page_alloc>
f0101aab:	89 c7                	mov    %eax,%edi
f0101aad:	85 c0                	test   %eax,%eax
f0101aaf:	75 24                	jne    f0101ad5 <mem_init+0x1c1>
f0101ab1:	c7 44 24 0c 94 61 10 	movl   $0xf0106194,0xc(%esp)
f0101ab8:	f0 
f0101ab9:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101ac0:	f0 
f0101ac1:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101ac8:	00 
f0101ac9:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101ad0:	e8 e9 e5 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f0101ad5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101adc:	e8 cf fa ff ff       	call   f01015b0 <page_alloc>
f0101ae1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	75 24                	jne    f0101b0c <mem_init+0x1f8>
f0101ae8:	c7 44 24 0c aa 61 10 	movl   $0xf01061aa,0xc(%esp)
f0101aef:	f0 
f0101af0:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101af7:	f0 
f0101af8:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101aff:	00 
f0101b00:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101b07:	e8 b2 e5 ff ff       	call   f01000be <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b0c:	39 fe                	cmp    %edi,%esi
f0101b0e:	75 24                	jne    f0101b34 <mem_init+0x220>
f0101b10:	c7 44 24 0c c0 61 10 	movl   $0xf01061c0,0xc(%esp)
f0101b17:	f0 
f0101b18:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101b1f:	f0 
f0101b20:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0101b27:	00 
f0101b28:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101b2f:	e8 8a e5 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b34:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b37:	74 05                	je     f0101b3e <mem_init+0x22a>
f0101b39:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b3c:	75 24                	jne    f0101b62 <mem_init+0x24e>
f0101b3e:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f0101b45:	f0 
f0101b46:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101b4d:	f0 
f0101b4e:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0101b55:	00 
f0101b56:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101b5d:	e8 5c e5 ff ff       	call   f01000be <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b62:	8b 15 ac fd 17 f0    	mov    0xf017fdac,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b68:	a1 a4 fd 17 f0       	mov    0xf017fda4,%eax
f0101b6d:	c1 e0 0c             	shl    $0xc,%eax
f0101b70:	89 f1                	mov    %esi,%ecx
f0101b72:	29 d1                	sub    %edx,%ecx
f0101b74:	c1 f9 03             	sar    $0x3,%ecx
f0101b77:	c1 e1 0c             	shl    $0xc,%ecx
f0101b7a:	39 c1                	cmp    %eax,%ecx
f0101b7c:	72 24                	jb     f0101ba2 <mem_init+0x28e>
f0101b7e:	c7 44 24 0c d2 61 10 	movl   $0xf01061d2,0xc(%esp)
f0101b85:	f0 
f0101b86:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101b8d:	f0 
f0101b8e:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101b95:	00 
f0101b96:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101b9d:	e8 1c e5 ff ff       	call   f01000be <_panic>
f0101ba2:	89 f9                	mov    %edi,%ecx
f0101ba4:	29 d1                	sub    %edx,%ecx
f0101ba6:	c1 f9 03             	sar    $0x3,%ecx
f0101ba9:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bac:	39 c8                	cmp    %ecx,%eax
f0101bae:	77 24                	ja     f0101bd4 <mem_init+0x2c0>
f0101bb0:	c7 44 24 0c ef 61 10 	movl   $0xf01061ef,0xc(%esp)
f0101bb7:	f0 
f0101bb8:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101bbf:	f0 
f0101bc0:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101bc7:	00 
f0101bc8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101bcf:	e8 ea e4 ff ff       	call   f01000be <_panic>
f0101bd4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bd7:	29 d1                	sub    %edx,%ecx
f0101bd9:	89 ca                	mov    %ecx,%edx
f0101bdb:	c1 fa 03             	sar    $0x3,%edx
f0101bde:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101be1:	39 d0                	cmp    %edx,%eax
f0101be3:	77 24                	ja     f0101c09 <mem_init+0x2f5>
f0101be5:	c7 44 24 0c 0c 62 10 	movl   $0xf010620c,0xc(%esp)
f0101bec:	f0 
f0101bed:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101bf4:	f0 
f0101bf5:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0101bfc:	00 
f0101bfd:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101c04:	e8 b5 e4 ff ff       	call   f01000be <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c09:	a1 00 f1 17 f0       	mov    0xf017f100,%eax
f0101c0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c11:	c7 05 00 f1 17 f0 00 	movl   $0x0,0xf017f100
f0101c18:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c22:	e8 89 f9 ff ff       	call   f01015b0 <page_alloc>
f0101c27:	85 c0                	test   %eax,%eax
f0101c29:	74 24                	je     f0101c4f <mem_init+0x33b>
f0101c2b:	c7 44 24 0c 29 62 10 	movl   $0xf0106229,0xc(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101c3a:	f0 
f0101c3b:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0101c42:	00 
f0101c43:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101c4a:	e8 6f e4 ff ff       	call   f01000be <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c4f:	89 34 24             	mov    %esi,(%esp)
f0101c52:	e8 d7 f9 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0101c57:	89 3c 24             	mov    %edi,(%esp)
f0101c5a:	e8 cf f9 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0101c5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c62:	89 04 24             	mov    %eax,(%esp)
f0101c65:	e8 c4 f9 ff ff       	call   f010162e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c71:	e8 3a f9 ff ff       	call   f01015b0 <page_alloc>
f0101c76:	89 c6                	mov    %eax,%esi
f0101c78:	85 c0                	test   %eax,%eax
f0101c7a:	75 24                	jne    f0101ca0 <mem_init+0x38c>
f0101c7c:	c7 44 24 0c 7e 61 10 	movl   $0xf010617e,0xc(%esp)
f0101c83:	f0 
f0101c84:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101c8b:	f0 
f0101c8c:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101c93:	00 
f0101c94:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101c9b:	e8 1e e4 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101ca0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ca7:	e8 04 f9 ff ff       	call   f01015b0 <page_alloc>
f0101cac:	89 c7                	mov    %eax,%edi
f0101cae:	85 c0                	test   %eax,%eax
f0101cb0:	75 24                	jne    f0101cd6 <mem_init+0x3c2>
f0101cb2:	c7 44 24 0c 94 61 10 	movl   $0xf0106194,0xc(%esp)
f0101cb9:	f0 
f0101cba:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101cc1:	f0 
f0101cc2:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101cc9:	00 
f0101cca:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101cd1:	e8 e8 e3 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f0101cd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cdd:	e8 ce f8 ff ff       	call   f01015b0 <page_alloc>
f0101ce2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ce5:	85 c0                	test   %eax,%eax
f0101ce7:	75 24                	jne    f0101d0d <mem_init+0x3f9>
f0101ce9:	c7 44 24 0c aa 61 10 	movl   $0xf01061aa,0xc(%esp)
f0101cf0:	f0 
f0101cf1:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101cf8:	f0 
f0101cf9:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101d00:	00 
f0101d01:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101d08:	e8 b1 e3 ff ff       	call   f01000be <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d0d:	39 fe                	cmp    %edi,%esi
f0101d0f:	75 24                	jne    f0101d35 <mem_init+0x421>
f0101d11:	c7 44 24 0c c0 61 10 	movl   $0xf01061c0,0xc(%esp)
f0101d18:	f0 
f0101d19:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101d20:	f0 
f0101d21:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101d28:	00 
f0101d29:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101d30:	e8 89 e3 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d35:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d38:	74 05                	je     f0101d3f <mem_init+0x42b>
f0101d3a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d3d:	75 24                	jne    f0101d63 <mem_init+0x44f>
f0101d3f:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f0101d46:	f0 
f0101d47:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101d4e:	f0 
f0101d4f:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101d56:	00 
f0101d57:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101d5e:	e8 5b e3 ff ff       	call   f01000be <_panic>
	assert(!page_alloc(0));
f0101d63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d6a:	e8 41 f8 ff ff       	call   f01015b0 <page_alloc>
f0101d6f:	85 c0                	test   %eax,%eax
f0101d71:	74 24                	je     f0101d97 <mem_init+0x483>
f0101d73:	c7 44 24 0c 29 62 10 	movl   $0xf0106229,0xc(%esp)
f0101d7a:	f0 
f0101d7b:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101d82:	f0 
f0101d83:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101d8a:	00 
f0101d8b:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101d92:	e8 27 e3 ff ff       	call   f01000be <_panic>
f0101d97:	89 f0                	mov    %esi,%eax
f0101d99:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f0101d9f:	c1 f8 03             	sar    $0x3,%eax
f0101da2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101da5:	89 c2                	mov    %eax,%edx
f0101da7:	c1 ea 0c             	shr    $0xc,%edx
f0101daa:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f0101db0:	72 20                	jb     f0101dd2 <mem_init+0x4be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101db2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101db6:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f0101dbd:	f0 
f0101dbe:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101dc5:	00 
f0101dc6:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f0101dcd:	e8 ec e2 ff ff       	call   f01000be <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101dd2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dd9:	00 
f0101dda:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101de1:	00 
	return (void *)(pa + KERNBASE);
f0101de2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101de7:	89 04 24             	mov    %eax,(%esp)
f0101dea:	e8 e2 2d 00 00       	call   f0104bd1 <memset>
	page_free(pp0);
f0101def:	89 34 24             	mov    %esi,(%esp)
f0101df2:	e8 37 f8 ff ff       	call   f010162e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101df7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101dfe:	e8 ad f7 ff ff       	call   f01015b0 <page_alloc>
f0101e03:	85 c0                	test   %eax,%eax
f0101e05:	75 24                	jne    f0101e2b <mem_init+0x517>
f0101e07:	c7 44 24 0c 38 62 10 	movl   $0xf0106238,0xc(%esp)
f0101e0e:	f0 
f0101e0f:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101e16:	f0 
f0101e17:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101e1e:	00 
f0101e1f:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101e26:	e8 93 e2 ff ff       	call   f01000be <_panic>
	assert(pp && pp0 == pp);
f0101e2b:	39 c6                	cmp    %eax,%esi
f0101e2d:	74 24                	je     f0101e53 <mem_init+0x53f>
f0101e2f:	c7 44 24 0c 56 62 10 	movl   $0xf0106256,0xc(%esp)
f0101e36:	f0 
f0101e37:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101e3e:	f0 
f0101e3f:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0101e46:	00 
f0101e47:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101e4e:	e8 6b e2 ff ff       	call   f01000be <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e53:	89 f2                	mov    %esi,%edx
f0101e55:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f0101e5b:	c1 fa 03             	sar    $0x3,%edx
f0101e5e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e61:	89 d0                	mov    %edx,%eax
f0101e63:	c1 e8 0c             	shr    $0xc,%eax
f0101e66:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f0101e6c:	72 20                	jb     f0101e8e <mem_init+0x57a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101e72:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f0101e79:	f0 
f0101e7a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0101e81:	00 
f0101e82:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f0101e89:	e8 30 e2 ff ff       	call   f01000be <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101e8e:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101e95:	75 11                	jne    f0101ea8 <mem_init+0x594>
f0101e97:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101e9d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ea3:	80 38 00             	cmpb   $0x0,(%eax)
f0101ea6:	74 24                	je     f0101ecc <mem_init+0x5b8>
f0101ea8:	c7 44 24 0c 66 62 10 	movl   $0xf0106266,0xc(%esp)
f0101eaf:	f0 
f0101eb0:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101eb7:	f0 
f0101eb8:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101ebf:	00 
f0101ec0:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101ec7:	e8 f2 e1 ff ff       	call   f01000be <_panic>
f0101ecc:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101ecf:	39 d0                	cmp    %edx,%eax
f0101ed1:	75 d0                	jne    f0101ea3 <mem_init+0x58f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101ed3:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101ed6:	89 15 00 f1 17 f0    	mov    %edx,0xf017f100

	// free the pages we took
	page_free(pp0);
f0101edc:	89 34 24             	mov    %esi,(%esp)
f0101edf:	e8 4a f7 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0101ee4:	89 3c 24             	mov    %edi,(%esp)
f0101ee7:	e8 42 f7 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0101eec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eef:	89 04 24             	mov    %eax,(%esp)
f0101ef2:	e8 37 f7 ff ff       	call   f010162e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ef7:	a1 00 f1 17 f0       	mov    0xf017f100,%eax
f0101efc:	85 c0                	test   %eax,%eax
f0101efe:	74 09                	je     f0101f09 <mem_init+0x5f5>
		--nfree;
f0101f00:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f03:	8b 00                	mov    (%eax),%eax
f0101f05:	85 c0                	test   %eax,%eax
f0101f07:	75 f7                	jne    f0101f00 <mem_init+0x5ec>
		--nfree;
	assert(nfree == 0);
f0101f09:	85 db                	test   %ebx,%ebx
f0101f0b:	74 24                	je     f0101f31 <mem_init+0x61d>
f0101f0d:	c7 44 24 0c 70 62 10 	movl   $0xf0106270,0xc(%esp)
f0101f14:	f0 
f0101f15:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101f1c:	f0 
f0101f1d:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101f24:	00 
f0101f25:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101f2c:	e8 8d e1 ff ff       	call   f01000be <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101f31:	c7 04 24 94 5a 10 f0 	movl   $0xf0105a94,(%esp)
f0101f38:	e8 3d 1b 00 00       	call   f0103a7a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f44:	e8 67 f6 ff ff       	call   f01015b0 <page_alloc>
f0101f49:	89 c6                	mov    %eax,%esi
f0101f4b:	85 c0                	test   %eax,%eax
f0101f4d:	75 24                	jne    f0101f73 <mem_init+0x65f>
f0101f4f:	c7 44 24 0c 7e 61 10 	movl   $0xf010617e,0xc(%esp)
f0101f56:	f0 
f0101f57:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101f5e:	f0 
f0101f5f:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101f66:	00 
f0101f67:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101f6e:	e8 4b e1 ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f0101f73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f7a:	e8 31 f6 ff ff       	call   f01015b0 <page_alloc>
f0101f7f:	89 c7                	mov    %eax,%edi
f0101f81:	85 c0                	test   %eax,%eax
f0101f83:	75 24                	jne    f0101fa9 <mem_init+0x695>
f0101f85:	c7 44 24 0c 94 61 10 	movl   $0xf0106194,0xc(%esp)
f0101f8c:	f0 
f0101f8d:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101f94:	f0 
f0101f95:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0101f9c:	00 
f0101f9d:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101fa4:	e8 15 e1 ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f0101fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fb0:	e8 fb f5 ff ff       	call   f01015b0 <page_alloc>
f0101fb5:	89 c3                	mov    %eax,%ebx
f0101fb7:	85 c0                	test   %eax,%eax
f0101fb9:	75 24                	jne    f0101fdf <mem_init+0x6cb>
f0101fbb:	c7 44 24 0c aa 61 10 	movl   $0xf01061aa,0xc(%esp)
f0101fc2:	f0 
f0101fc3:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101fca:	f0 
f0101fcb:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0101fd2:	00 
f0101fd3:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0101fda:	e8 df e0 ff ff       	call   f01000be <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101fdf:	39 fe                	cmp    %edi,%esi
f0101fe1:	75 24                	jne    f0102007 <mem_init+0x6f3>
f0101fe3:	c7 44 24 0c c0 61 10 	movl   $0xf01061c0,0xc(%esp)
f0101fea:	f0 
f0101feb:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0101ff2:	f0 
f0101ff3:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0101ffa:	00 
f0101ffb:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102002:	e8 b7 e0 ff ff       	call   f01000be <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102007:	39 c7                	cmp    %eax,%edi
f0102009:	74 04                	je     f010200f <mem_init+0x6fb>
f010200b:	39 c6                	cmp    %eax,%esi
f010200d:	75 24                	jne    f0102033 <mem_init+0x71f>
f010200f:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f0102016:	f0 
f0102017:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010201e:	f0 
f010201f:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102026:	00 
f0102027:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010202e:	e8 8b e0 ff ff       	call   f01000be <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102033:	8b 15 00 f1 17 f0    	mov    0xf017f100,%edx
f0102039:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010203c:	c7 05 00 f1 17 f0 00 	movl   $0x0,0xf017f100
f0102043:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102046:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010204d:	e8 5e f5 ff ff       	call   f01015b0 <page_alloc>
f0102052:	85 c0                	test   %eax,%eax
f0102054:	74 24                	je     f010207a <mem_init+0x766>
f0102056:	c7 44 24 0c 29 62 10 	movl   $0xf0106229,0xc(%esp)
f010205d:	f0 
f010205e:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102065:	f0 
f0102066:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f010206d:	00 
f010206e:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102075:	e8 44 e0 ff ff       	call   f01000be <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010207a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010207d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102081:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102088:	00 
f0102089:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010208e:	89 04 24             	mov    %eax,(%esp)
f0102091:	e8 01 f7 ff ff       	call   f0101797 <page_lookup>
f0102096:	85 c0                	test   %eax,%eax
f0102098:	74 24                	je     f01020be <mem_init+0x7aa>
f010209a:	c7 44 24 0c b4 5a 10 	movl   $0xf0105ab4,0xc(%esp)
f01020a1:	f0 
f01020a2:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01020a9:	f0 
f01020aa:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f01020b1:	00 
f01020b2:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01020b9:	e8 00 e0 ff ff       	call   f01000be <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01020be:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020c5:	00 
f01020c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020cd:	00 
f01020ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01020d2:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01020d7:	89 04 24             	mov    %eax,(%esp)
f01020da:	e8 8b f7 ff ff       	call   f010186a <page_insert>
f01020df:	85 c0                	test   %eax,%eax
f01020e1:	78 24                	js     f0102107 <mem_init+0x7f3>
f01020e3:	c7 44 24 0c ec 5a 10 	movl   $0xf0105aec,0xc(%esp)
f01020ea:	f0 
f01020eb:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01020f2:	f0 
f01020f3:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01020fa:	00 
f01020fb:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102102:	e8 b7 df ff ff       	call   f01000be <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102107:	89 34 24             	mov    %esi,(%esp)
f010210a:	e8 1f f5 ff ff       	call   f010162e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010210f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102116:	00 
f0102117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010211e:	00 
f010211f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102123:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102128:	89 04 24             	mov    %eax,(%esp)
f010212b:	e8 3a f7 ff ff       	call   f010186a <page_insert>
f0102130:	85 c0                	test   %eax,%eax
f0102132:	74 24                	je     f0102158 <mem_init+0x844>
f0102134:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f010213b:	f0 
f010213c:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102153:	e8 66 df ff ff       	call   f01000be <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102158:	8b 0d a8 fd 17 f0    	mov    0xf017fda8,%ecx
f010215e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102161:	a1 ac fd 17 f0       	mov    0xf017fdac,%eax
f0102166:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102169:	8b 11                	mov    (%ecx),%edx
f010216b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102171:	89 f0                	mov    %esi,%eax
f0102173:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0102176:	c1 f8 03             	sar    $0x3,%eax
f0102179:	c1 e0 0c             	shl    $0xc,%eax
f010217c:	39 c2                	cmp    %eax,%edx
f010217e:	74 24                	je     f01021a4 <mem_init+0x890>
f0102180:	c7 44 24 0c 4c 5b 10 	movl   $0xf0105b4c,0xc(%esp)
f0102187:	f0 
f0102188:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010218f:	f0 
f0102190:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102197:	00 
f0102198:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010219f:	e8 1a df ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01021a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01021a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ac:	e8 5b ee ff ff       	call   f010100c <check_va2pa>
f01021b1:	89 fa                	mov    %edi,%edx
f01021b3:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01021b6:	c1 fa 03             	sar    $0x3,%edx
f01021b9:	c1 e2 0c             	shl    $0xc,%edx
f01021bc:	39 d0                	cmp    %edx,%eax
f01021be:	74 24                	je     f01021e4 <mem_init+0x8d0>
f01021c0:	c7 44 24 0c 74 5b 10 	movl   $0xf0105b74,0xc(%esp)
f01021c7:	f0 
f01021c8:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01021cf:	f0 
f01021d0:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f01021d7:	00 
f01021d8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01021df:	e8 da de ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 1);
f01021e4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01021e9:	74 24                	je     f010220f <mem_init+0x8fb>
f01021eb:	c7 44 24 0c 7b 62 10 	movl   $0xf010627b,0xc(%esp)
f01021f2:	f0 
f01021f3:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01021fa:	f0 
f01021fb:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102202:	00 
f0102203:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010220a:	e8 af de ff ff       	call   f01000be <_panic>
	assert(pp0->pp_ref == 1);
f010220f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102214:	74 24                	je     f010223a <mem_init+0x926>
f0102216:	c7 44 24 0c 8c 62 10 	movl   $0xf010628c,0xc(%esp)
f010221d:	f0 
f010221e:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102225:	f0 
f0102226:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f010222d:	00 
f010222e:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102235:	e8 84 de ff ff       	call   f01000be <_panic>



	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010223a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102241:	00 
f0102242:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102249:	00 
f010224a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010224e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102251:	89 14 24             	mov    %edx,(%esp)
f0102254:	e8 11 f6 ff ff       	call   f010186a <page_insert>
f0102259:	85 c0                	test   %eax,%eax
f010225b:	74 24                	je     f0102281 <mem_init+0x96d>
f010225d:	c7 44 24 0c a4 5b 10 	movl   $0xf0105ba4,0xc(%esp)
f0102264:	f0 
f0102265:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010226c:	f0 
f010226d:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102274:	00 
f0102275:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010227c:	e8 3d de ff ff       	call   f01000be <_panic>
cprintf("%x %x %x\n",kern_pgdir, PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
f0102281:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102286:	89 f2                	mov    %esi,%edx
f0102288:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f010228e:	c1 fa 03             	sar    $0x3,%edx
f0102291:	c1 e2 0c             	shl    $0xc,%edx
f0102294:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102298:	8b 10                	mov    (%eax),%edx
f010229a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022a0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01022a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022a8:	c7 04 24 9d 62 10 f0 	movl   $0xf010629d,(%esp)
f01022af:	e8 c6 17 00 00       	call   f0103a7a <cprintf>
f01022b4:	89 d8                	mov    %ebx,%eax
f01022b6:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f01022bc:	c1 f8 03             	sar    $0x3,%eax
f01022bf:	c1 e0 0c             	shl    $0xc,%eax

cprintf("%x %x\n", PTE_ADDR(*((pte_t *)(PTE_ADDR(kern_pgdir[0]) + PTX(PGSIZE)))), page2pa(pp2));
f01022c2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022c6:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01022cb:	8b 00                	mov    (%eax),%eax
f01022cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022d2:	8b 40 01             	mov    0x1(%eax),%eax
f01022d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022de:	c7 04 24 a0 62 10 f0 	movl   $0xf01062a0,(%esp)
f01022e5:	e8 90 17 00 00       	call   f0103a7a <cprintf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022ea:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022ef:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01022f4:	e8 13 ed ff ff       	call   f010100c <check_va2pa>
f01022f9:	89 da                	mov    %ebx,%edx
f01022fb:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f0102301:	c1 fa 03             	sar    $0x3,%edx
f0102304:	c1 e2 0c             	shl    $0xc,%edx
f0102307:	39 d0                	cmp    %edx,%eax
f0102309:	74 24                	je     f010232f <mem_init+0xa1b>
f010230b:	c7 44 24 0c e0 5b 10 	movl   $0xf0105be0,0xc(%esp)
f0102312:	f0 
f0102313:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010231a:	f0 
f010231b:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0102322:	00 
f0102323:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010232a:	e8 8f dd ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f010232f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102334:	74 24                	je     f010235a <mem_init+0xa46>
f0102336:	c7 44 24 0c a7 62 10 	movl   $0xf01062a7,0xc(%esp)
f010233d:	f0 
f010233e:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102345:	f0 
f0102346:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f010234d:	00 
f010234e:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102355:	e8 64 dd ff ff       	call   f01000be <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010235a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102361:	e8 4a f2 ff ff       	call   f01015b0 <page_alloc>
f0102366:	85 c0                	test   %eax,%eax
f0102368:	74 24                	je     f010238e <mem_init+0xa7a>
f010236a:	c7 44 24 0c 29 62 10 	movl   $0xf0106229,0xc(%esp)
f0102371:	f0 
f0102372:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102379:	f0 
f010237a:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102381:	00 
f0102382:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102389:	e8 30 dd ff ff       	call   f01000be <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010238e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102395:	00 
f0102396:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010239d:	00 
f010239e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023a2:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01023a7:	89 04 24             	mov    %eax,(%esp)
f01023aa:	e8 bb f4 ff ff       	call   f010186a <page_insert>
f01023af:	85 c0                	test   %eax,%eax
f01023b1:	74 24                	je     f01023d7 <mem_init+0xac3>
f01023b3:	c7 44 24 0c a4 5b 10 	movl   $0xf0105ba4,0xc(%esp)
f01023ba:	f0 
f01023bb:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01023c2:	f0 
f01023c3:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f01023ca:	00 
f01023cb:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01023d2:	e8 e7 dc ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023d7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023dc:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01023e1:	e8 26 ec ff ff       	call   f010100c <check_va2pa>
f01023e6:	89 da                	mov    %ebx,%edx
f01023e8:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f01023ee:	c1 fa 03             	sar    $0x3,%edx
f01023f1:	c1 e2 0c             	shl    $0xc,%edx
f01023f4:	39 d0                	cmp    %edx,%eax
f01023f6:	74 24                	je     f010241c <mem_init+0xb08>
f01023f8:	c7 44 24 0c e0 5b 10 	movl   $0xf0105be0,0xc(%esp)
f01023ff:	f0 
f0102400:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102407:	f0 
f0102408:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f010240f:	00 
f0102410:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102417:	e8 a2 dc ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f010241c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102421:	74 24                	je     f0102447 <mem_init+0xb33>
f0102423:	c7 44 24 0c a7 62 10 	movl   $0xf01062a7,0xc(%esp)
f010242a:	f0 
f010242b:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102432:	f0 
f0102433:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f010243a:	00 
f010243b:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102442:	e8 77 dc ff ff       	call   f01000be <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102447:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010244e:	e8 5d f1 ff ff       	call   f01015b0 <page_alloc>
f0102453:	85 c0                	test   %eax,%eax
f0102455:	74 24                	je     f010247b <mem_init+0xb67>
f0102457:	c7 44 24 0c 29 62 10 	movl   $0xf0106229,0xc(%esp)
f010245e:	f0 
f010245f:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102466:	f0 
f0102467:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f010246e:	00 
f010246f:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102476:	e8 43 dc ff ff       	call   f01000be <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010247b:	8b 15 a8 fd 17 f0    	mov    0xf017fda8,%edx
f0102481:	8b 02                	mov    (%edx),%eax
f0102483:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102488:	89 c1                	mov    %eax,%ecx
f010248a:	c1 e9 0c             	shr    $0xc,%ecx
f010248d:	3b 0d a4 fd 17 f0    	cmp    0xf017fda4,%ecx
f0102493:	72 20                	jb     f01024b5 <mem_init+0xba1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102495:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102499:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f01024a0:	f0 
f01024a1:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01024a8:	00 
f01024a9:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01024b0:	e8 09 dc ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f01024b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024c4:	00 
f01024c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024cc:	00 
f01024cd:	89 14 24             	mov    %edx,(%esp)
f01024d0:	e8 b4 f1 ff ff       	call   f0101689 <pgdir_walk>
f01024d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01024d8:	83 c2 04             	add    $0x4,%edx
f01024db:	39 d0                	cmp    %edx,%eax
f01024dd:	74 24                	je     f0102503 <mem_init+0xbef>
f01024df:	c7 44 24 0c 10 5c 10 	movl   $0xf0105c10,0xc(%esp)
f01024e6:	f0 
f01024e7:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01024ee:	f0 
f01024ef:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f01024f6:	00 
f01024f7:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01024fe:	e8 bb db ff ff       	call   f01000be <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102503:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010250a:	00 
f010250b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102512:	00 
f0102513:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102517:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010251c:	89 04 24             	mov    %eax,(%esp)
f010251f:	e8 46 f3 ff ff       	call   f010186a <page_insert>
f0102524:	85 c0                	test   %eax,%eax
f0102526:	74 24                	je     f010254c <mem_init+0xc38>
f0102528:	c7 44 24 0c 50 5c 10 	movl   $0xf0105c50,0xc(%esp)
f010252f:	f0 
f0102530:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102537:	f0 
f0102538:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010253f:	00 
f0102540:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102547:	e8 72 db ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010254c:	8b 0d a8 fd 17 f0    	mov    0xf017fda8,%ecx
f0102552:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102555:	ba 00 10 00 00       	mov    $0x1000,%edx
f010255a:	89 c8                	mov    %ecx,%eax
f010255c:	e8 ab ea ff ff       	call   f010100c <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102561:	89 da                	mov    %ebx,%edx
f0102563:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f0102569:	c1 fa 03             	sar    $0x3,%edx
f010256c:	c1 e2 0c             	shl    $0xc,%edx
f010256f:	39 d0                	cmp    %edx,%eax
f0102571:	74 24                	je     f0102597 <mem_init+0xc83>
f0102573:	c7 44 24 0c e0 5b 10 	movl   $0xf0105be0,0xc(%esp)
f010257a:	f0 
f010257b:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102582:	f0 
f0102583:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f010258a:	00 
f010258b:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102592:	e8 27 db ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f0102597:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010259c:	74 24                	je     f01025c2 <mem_init+0xcae>
f010259e:	c7 44 24 0c a7 62 10 	movl   $0xf01062a7,0xc(%esp)
f01025a5:	f0 
f01025a6:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01025ad:	f0 
f01025ae:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f01025b5:	00 
f01025b6:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01025bd:	e8 fc da ff ff       	call   f01000be <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01025c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025c9:	00 
f01025ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025d1:	00 
f01025d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025d5:	89 04 24             	mov    %eax,(%esp)
f01025d8:	e8 ac f0 ff ff       	call   f0101689 <pgdir_walk>
f01025dd:	f6 00 04             	testb  $0x4,(%eax)
f01025e0:	75 24                	jne    f0102606 <mem_init+0xcf2>
f01025e2:	c7 44 24 0c 90 5c 10 	movl   $0xf0105c90,0xc(%esp)
f01025e9:	f0 
f01025ea:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01025f1:	f0 
f01025f2:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01025f9:	00 
f01025fa:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102601:	e8 b8 da ff ff       	call   f01000be <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102606:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010260b:	f6 00 04             	testb  $0x4,(%eax)
f010260e:	75 24                	jne    f0102634 <mem_init+0xd20>
f0102610:	c7 44 24 0c b8 62 10 	movl   $0xf01062b8,0xc(%esp)
f0102617:	f0 
f0102618:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010261f:	f0 
f0102620:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0102627:	00 
f0102628:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010262f:	e8 8a da ff ff       	call   f01000be <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102634:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010263b:	00 
f010263c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102643:	00 
f0102644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102648:	89 04 24             	mov    %eax,(%esp)
f010264b:	e8 1a f2 ff ff       	call   f010186a <page_insert>
f0102650:	85 c0                	test   %eax,%eax
f0102652:	74 24                	je     f0102678 <mem_init+0xd64>
f0102654:	c7 44 24 0c a4 5b 10 	movl   $0xf0105ba4,0xc(%esp)
f010265b:	f0 
f010265c:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102663:	f0 
f0102664:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f010266b:	00 
f010266c:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102673:	e8 46 da ff ff       	call   f01000be <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102678:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010267f:	00 
f0102680:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102687:	00 
f0102688:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010268d:	89 04 24             	mov    %eax,(%esp)
f0102690:	e8 f4 ef ff ff       	call   f0101689 <pgdir_walk>
f0102695:	f6 00 02             	testb  $0x2,(%eax)
f0102698:	75 24                	jne    f01026be <mem_init+0xdaa>
f010269a:	c7 44 24 0c c4 5c 10 	movl   $0xf0105cc4,0xc(%esp)
f01026a1:	f0 
f01026a2:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01026a9:	f0 
f01026aa:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01026b1:	00 
f01026b2:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01026b9:	e8 00 da ff ff       	call   f01000be <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026c5:	00 
f01026c6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026cd:	00 
f01026ce:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01026d3:	89 04 24             	mov    %eax,(%esp)
f01026d6:	e8 ae ef ff ff       	call   f0101689 <pgdir_walk>
f01026db:	f6 00 04             	testb  $0x4,(%eax)
f01026de:	74 24                	je     f0102704 <mem_init+0xdf0>
f01026e0:	c7 44 24 0c f8 5c 10 	movl   $0xf0105cf8,0xc(%esp)
f01026e7:	f0 
f01026e8:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01026ef:	f0 
f01026f0:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01026f7:	00 
f01026f8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01026ff:	e8 ba d9 ff ff       	call   f01000be <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102704:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010270b:	00 
f010270c:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102713:	00 
f0102714:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102718:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010271d:	89 04 24             	mov    %eax,(%esp)
f0102720:	e8 45 f1 ff ff       	call   f010186a <page_insert>
f0102725:	85 c0                	test   %eax,%eax
f0102727:	78 24                	js     f010274d <mem_init+0xe39>
f0102729:	c7 44 24 0c 30 5d 10 	movl   $0xf0105d30,0xc(%esp)
f0102730:	f0 
f0102731:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102738:	f0 
f0102739:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102740:	00 
f0102741:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102748:	e8 71 d9 ff ff       	call   f01000be <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010274d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102754:	00 
f0102755:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010275c:	00 
f010275d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102761:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102766:	89 04 24             	mov    %eax,(%esp)
f0102769:	e8 fc f0 ff ff       	call   f010186a <page_insert>
f010276e:	85 c0                	test   %eax,%eax
f0102770:	74 24                	je     f0102796 <mem_init+0xe82>
f0102772:	c7 44 24 0c 68 5d 10 	movl   $0xf0105d68,0xc(%esp)
f0102779:	f0 
f010277a:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102781:	f0 
f0102782:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102789:	00 
f010278a:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102791:	e8 28 d9 ff ff       	call   f01000be <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102796:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010279d:	00 
f010279e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027a5:	00 
f01027a6:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01027ab:	89 04 24             	mov    %eax,(%esp)
f01027ae:	e8 d6 ee ff ff       	call   f0101689 <pgdir_walk>
f01027b3:	f6 00 04             	testb  $0x4,(%eax)
f01027b6:	74 24                	je     f01027dc <mem_init+0xec8>
f01027b8:	c7 44 24 0c f8 5c 10 	movl   $0xf0105cf8,0xc(%esp)
f01027bf:	f0 
f01027c0:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01027c7:	f0 
f01027c8:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01027cf:	00 
f01027d0:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01027d7:	e8 e2 d8 ff ff       	call   f01000be <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01027dc:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01027e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01027e9:	e8 1e e8 ff ff       	call   f010100c <check_va2pa>
f01027ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01027f1:	89 f8                	mov    %edi,%eax
f01027f3:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f01027f9:	c1 f8 03             	sar    $0x3,%eax
f01027fc:	c1 e0 0c             	shl    $0xc,%eax
f01027ff:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102802:	74 24                	je     f0102828 <mem_init+0xf14>
f0102804:	c7 44 24 0c a4 5d 10 	movl   $0xf0105da4,0xc(%esp)
f010280b:	f0 
f010280c:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102813:	f0 
f0102814:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f010281b:	00 
f010281c:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102823:	e8 96 d8 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102828:	ba 00 10 00 00       	mov    $0x1000,%edx
f010282d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102830:	e8 d7 e7 ff ff       	call   f010100c <check_va2pa>
f0102835:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102838:	74 24                	je     f010285e <mem_init+0xf4a>
f010283a:	c7 44 24 0c d0 5d 10 	movl   $0xf0105dd0,0xc(%esp)
f0102841:	f0 
f0102842:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102849:	f0 
f010284a:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0102851:	00 
f0102852:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102859:	e8 60 d8 ff ff       	call   f01000be <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010285e:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102863:	74 24                	je     f0102889 <mem_init+0xf75>
f0102865:	c7 44 24 0c ce 62 10 	movl   $0xf01062ce,0xc(%esp)
f010286c:	f0 
f010286d:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102874:	f0 
f0102875:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f010287c:	00 
f010287d:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102884:	e8 35 d8 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f0102889:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010288e:	74 24                	je     f01028b4 <mem_init+0xfa0>
f0102890:	c7 44 24 0c df 62 10 	movl   $0xf01062df,0xc(%esp)
f0102897:	f0 
f0102898:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010289f:	f0 
f01028a0:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f01028a7:	00 
f01028a8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01028af:	e8 0a d8 ff ff       	call   f01000be <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01028b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028bb:	e8 f0 ec ff ff       	call   f01015b0 <page_alloc>
f01028c0:	85 c0                	test   %eax,%eax
f01028c2:	74 04                	je     f01028c8 <mem_init+0xfb4>
f01028c4:	39 c3                	cmp    %eax,%ebx
f01028c6:	74 24                	je     f01028ec <mem_init+0xfd8>
f01028c8:	c7 44 24 0c 00 5e 10 	movl   $0xf0105e00,0xc(%esp)
f01028cf:	f0 
f01028d0:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01028d7:	f0 
f01028d8:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01028df:	00 
f01028e0:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01028e7:	e8 d2 d7 ff ff       	call   f01000be <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01028ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028f3:	00 
f01028f4:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01028f9:	89 04 24             	mov    %eax,(%esp)
f01028fc:	e8 19 ef ff ff       	call   f010181a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102901:	8b 15 a8 fd 17 f0    	mov    0xf017fda8,%edx
f0102907:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010290a:	ba 00 00 00 00       	mov    $0x0,%edx
f010290f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102912:	e8 f5 e6 ff ff       	call   f010100c <check_va2pa>
f0102917:	83 f8 ff             	cmp    $0xffffffff,%eax
f010291a:	74 24                	je     f0102940 <mem_init+0x102c>
f010291c:	c7 44 24 0c 24 5e 10 	movl   $0xf0105e24,0xc(%esp)
f0102923:	f0 
f0102924:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010292b:	f0 
f010292c:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102933:	00 
f0102934:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010293b:	e8 7e d7 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102940:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102945:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102948:	e8 bf e6 ff ff       	call   f010100c <check_va2pa>
f010294d:	89 fa                	mov    %edi,%edx
f010294f:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f0102955:	c1 fa 03             	sar    $0x3,%edx
f0102958:	c1 e2 0c             	shl    $0xc,%edx
f010295b:	39 d0                	cmp    %edx,%eax
f010295d:	74 24                	je     f0102983 <mem_init+0x106f>
f010295f:	c7 44 24 0c d0 5d 10 	movl   $0xf0105dd0,0xc(%esp)
f0102966:	f0 
f0102967:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010296e:	f0 
f010296f:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102976:	00 
f0102977:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010297e:	e8 3b d7 ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 1);
f0102983:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102988:	74 24                	je     f01029ae <mem_init+0x109a>
f010298a:	c7 44 24 0c 7b 62 10 	movl   $0xf010627b,0xc(%esp)
f0102991:	f0 
f0102992:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102999:	f0 
f010299a:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01029a1:	00 
f01029a2:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01029a9:	e8 10 d7 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f01029ae:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029b3:	74 24                	je     f01029d9 <mem_init+0x10c5>
f01029b5:	c7 44 24 0c df 62 10 	movl   $0xf01062df,0xc(%esp)
f01029bc:	f0 
f01029bd:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01029c4:	f0 
f01029c5:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01029cc:	00 
f01029cd:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01029d4:	e8 e5 d6 ff ff       	call   f01000be <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029d9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029e0:	00 
f01029e1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029e4:	89 0c 24             	mov    %ecx,(%esp)
f01029e7:	e8 2e ee ff ff       	call   f010181a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029ec:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01029f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01029f9:	e8 0e e6 ff ff       	call   f010100c <check_va2pa>
f01029fe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a01:	74 24                	je     f0102a27 <mem_init+0x1113>
f0102a03:	c7 44 24 0c 24 5e 10 	movl   $0xf0105e24,0xc(%esp)
f0102a0a:	f0 
f0102a0b:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102a12:	f0 
f0102a13:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102a1a:	00 
f0102a1b:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102a22:	e8 97 d6 ff ff       	call   f01000be <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a27:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a2f:	e8 d8 e5 ff ff       	call   f010100c <check_va2pa>
f0102a34:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a37:	74 24                	je     f0102a5d <mem_init+0x1149>
f0102a39:	c7 44 24 0c 48 5e 10 	movl   $0xf0105e48,0xc(%esp)
f0102a40:	f0 
f0102a41:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102a48:	f0 
f0102a49:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102a50:	00 
f0102a51:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102a58:	e8 61 d6 ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 0);
f0102a5d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a62:	74 24                	je     f0102a88 <mem_init+0x1174>
f0102a64:	c7 44 24 0c f0 62 10 	movl   $0xf01062f0,0xc(%esp)
f0102a6b:	f0 
f0102a6c:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102a73:	f0 
f0102a74:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102a7b:	00 
f0102a7c:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102a83:	e8 36 d6 ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 0);
f0102a88:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a8d:	74 24                	je     f0102ab3 <mem_init+0x119f>
f0102a8f:	c7 44 24 0c df 62 10 	movl   $0xf01062df,0xc(%esp)
f0102a96:	f0 
f0102a97:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102a9e:	f0 
f0102a9f:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102aa6:	00 
f0102aa7:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102aae:	e8 0b d6 ff ff       	call   f01000be <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102ab3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aba:	e8 f1 ea ff ff       	call   f01015b0 <page_alloc>
f0102abf:	85 c0                	test   %eax,%eax
f0102ac1:	74 04                	je     f0102ac7 <mem_init+0x11b3>
f0102ac3:	39 c7                	cmp    %eax,%edi
f0102ac5:	74 24                	je     f0102aeb <mem_init+0x11d7>
f0102ac7:	c7 44 24 0c 70 5e 10 	movl   $0xf0105e70,0xc(%esp)
f0102ace:	f0 
f0102acf:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102ad6:	f0 
f0102ad7:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102ade:	00 
f0102adf:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102ae6:	e8 d3 d5 ff ff       	call   f01000be <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102aeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102af2:	e8 b9 ea ff ff       	call   f01015b0 <page_alloc>
f0102af7:	85 c0                	test   %eax,%eax
f0102af9:	74 24                	je     f0102b1f <mem_init+0x120b>
f0102afb:	c7 44 24 0c 29 62 10 	movl   $0xf0106229,0xc(%esp)
f0102b02:	f0 
f0102b03:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102b0a:	f0 
f0102b0b:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102b12:	00 
f0102b13:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102b1a:	e8 9f d5 ff ff       	call   f01000be <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b1f:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102b24:	8b 08                	mov    (%eax),%ecx
f0102b26:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b2c:	89 f2                	mov    %esi,%edx
f0102b2e:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f0102b34:	c1 fa 03             	sar    $0x3,%edx
f0102b37:	c1 e2 0c             	shl    $0xc,%edx
f0102b3a:	39 d1                	cmp    %edx,%ecx
f0102b3c:	74 24                	je     f0102b62 <mem_init+0x124e>
f0102b3e:	c7 44 24 0c 4c 5b 10 	movl   $0xf0105b4c,0xc(%esp)
f0102b45:	f0 
f0102b46:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102b4d:	f0 
f0102b4e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102b55:	00 
f0102b56:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102b5d:	e8 5c d5 ff ff       	call   f01000be <_panic>
	kern_pgdir[0] = 0;
f0102b62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b68:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b6d:	74 24                	je     f0102b93 <mem_init+0x127f>
f0102b6f:	c7 44 24 0c 8c 62 10 	movl   $0xf010628c,0xc(%esp)
f0102b76:	f0 
f0102b77:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102b7e:	f0 
f0102b7f:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102b86:	00 
f0102b87:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102b8e:	e8 2b d5 ff ff       	call   f01000be <_panic>
	pp0->pp_ref = 0;
f0102b93:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b99:	89 34 24             	mov    %esi,(%esp)
f0102b9c:	e8 8d ea ff ff       	call   f010162e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102ba1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102ba8:	00 
f0102ba9:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102bb0:	00 
f0102bb1:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102bb6:	89 04 24             	mov    %eax,(%esp)
f0102bb9:	e8 cb ea ff ff       	call   f0101689 <pgdir_walk>
f0102bbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102bc1:	8b 0d a8 fd 17 f0    	mov    0xf017fda8,%ecx
f0102bc7:	8b 51 04             	mov    0x4(%ecx),%edx
f0102bca:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102bd0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bd3:	8b 15 a4 fd 17 f0    	mov    0xf017fda4,%edx
f0102bd9:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102bdc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102bdf:	c1 ea 0c             	shr    $0xc,%edx
f0102be2:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102be5:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102be8:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102beb:	72 23                	jb     f0102c10 <mem_init+0x12fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bed:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bf0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102bf4:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f0102bfb:	f0 
f0102bfc:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102c03:	00 
f0102c04:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102c0b:	e8 ae d4 ff ff       	call   f01000be <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c10:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c13:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102c19:	39 d0                	cmp    %edx,%eax
f0102c1b:	74 24                	je     f0102c41 <mem_init+0x132d>
f0102c1d:	c7 44 24 0c 01 63 10 	movl   $0xf0106301,0xc(%esp)
f0102c24:	f0 
f0102c25:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102c2c:	f0 
f0102c2d:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102c34:	00 
f0102c35:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102c3c:	e8 7d d4 ff ff       	call   f01000be <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c41:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102c48:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c4e:	89 f0                	mov    %esi,%eax
f0102c50:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f0102c56:	c1 f8 03             	sar    $0x3,%eax
f0102c59:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c5c:	89 c1                	mov    %eax,%ecx
f0102c5e:	c1 e9 0c             	shr    $0xc,%ecx
f0102c61:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102c64:	77 20                	ja     f0102c86 <mem_init+0x1372>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c6a:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f0102c71:	f0 
f0102c72:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0102c79:	00 
f0102c7a:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f0102c81:	e8 38 d4 ff ff       	call   f01000be <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c86:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c8d:	00 
f0102c8e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c95:	00 
	return (void *)(pa + KERNBASE);
f0102c96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c9b:	89 04 24             	mov    %eax,(%esp)
f0102c9e:	e8 2e 1f 00 00       	call   f0104bd1 <memset>
	page_free(pp0);
f0102ca3:	89 34 24             	mov    %esi,(%esp)
f0102ca6:	e8 83 e9 ff ff       	call   f010162e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102cab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102cb2:	00 
f0102cb3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102cba:	00 
f0102cbb:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102cc0:	89 04 24             	mov    %eax,(%esp)
f0102cc3:	e8 c1 e9 ff ff       	call   f0101689 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cc8:	89 f2                	mov    %esi,%edx
f0102cca:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f0102cd0:	c1 fa 03             	sar    $0x3,%edx
f0102cd3:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cd6:	89 d0                	mov    %edx,%eax
f0102cd8:	c1 e8 0c             	shr    $0xc,%eax
f0102cdb:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f0102ce1:	72 20                	jb     f0102d03 <mem_init+0x13ef>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ce3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ce7:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f0102cee:	f0 
f0102cef:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0102cf6:	00 
f0102cf7:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f0102cfe:	e8 bb d3 ff ff       	call   f01000be <_panic>
	return (void *)(pa + KERNBASE);
f0102d03:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102d09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d0c:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102d13:	75 11                	jne    f0102d26 <mem_init+0x1412>
f0102d15:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d1b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d21:	f6 00 01             	testb  $0x1,(%eax)
f0102d24:	74 24                	je     f0102d4a <mem_init+0x1436>
f0102d26:	c7 44 24 0c 19 63 10 	movl   $0xf0106319,0xc(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102d35:	f0 
f0102d36:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102d3d:	00 
f0102d3e:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102d45:	e8 74 d3 ff ff       	call   f01000be <_panic>
f0102d4a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102d4d:	39 d0                	cmp    %edx,%eax
f0102d4f:	75 d0                	jne    f0102d21 <mem_init+0x140d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102d51:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102d56:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d5c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102d62:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d65:	89 0d 00 f1 17 f0    	mov    %ecx,0xf017f100

	// free the pages we took
	page_free(pp0);
f0102d6b:	89 34 24             	mov    %esi,(%esp)
f0102d6e:	e8 bb e8 ff ff       	call   f010162e <page_free>
	page_free(pp1);
f0102d73:	89 3c 24             	mov    %edi,(%esp)
f0102d76:	e8 b3 e8 ff ff       	call   f010162e <page_free>
	page_free(pp2);
f0102d7b:	89 1c 24             	mov    %ebx,(%esp)
f0102d7e:	e8 ab e8 ff ff       	call   f010162e <page_free>

	cprintf("check_page() succeeded!\n");
f0102d83:	c7 04 24 30 63 10 f0 	movl   $0xf0106330,(%esp)
f0102d8a:	e8 eb 0c 00 00       	call   f0103a7a <cprintf>
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0102d8f:	a1 ac fd 17 f0       	mov    0xf017fdac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d94:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d99:	77 20                	ja     f0102dbb <mem_init+0x14a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d9f:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0102da6:	f0 
f0102da7:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f0102dae:	00 
f0102daf:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102db6:	e8 03 d3 ff ff       	call   f01000be <_panic>
 		kern_pgdir, 
		UPAGES, 
		ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), 
f0102dbb:	8b 15 a4 fd 17 f0    	mov    0xf017fda4,%edx
f0102dc1:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102dc8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// Your code goes here:

	// Map the pages for information of physical pages.
	// Above, I have allocated physical address space for pages.
	// Here, I mapped them with vitual address space
	boot_map_region(
f0102dce:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102dd5:	00 
	return (physaddr_t)kva - KERNBASE;
f0102dd6:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ddb:	89 04 24             	mov    %eax,(%esp)
f0102dde:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102de3:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102de8:	e8 3c e9 ff ff       	call   f0101729 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ded:	be 00 20 11 f0       	mov    $0xf0112000,%esi
f0102df2:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102df8:	77 20                	ja     f0102e1a <mem_init+0x1506>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dfa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102dfe:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0102e05:	f0 
f0102e06:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0102e0d:	00 
f0102e0e:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102e15:	e8 a4 d2 ff ff       	call   f01000be <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0102e1a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e21:	00 
f0102e22:	c7 04 24 00 20 11 00 	movl   $0x112000,(%esp)
f0102e29:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e2e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102e33:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102e38:	e8 ec e8 ff ff       	call   f0101729 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(
f0102e3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e44:	00 
f0102e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e4c:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102e51:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102e56:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0102e5b:	e8 c9 e8 ff ff       	call   f0101729 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e60:	8b 1d a8 fd 17 f0    	mov    0xf017fda8,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102e66:	8b 35 a4 fd 17 f0    	mov    0xf017fda4,%esi
f0102e6c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102e6f:	8d 3c f5 ff 0f 00 00 	lea    0xfff(,%esi,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102e76:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102e7c:	0f 84 80 00 00 00    	je     f0102f02 <mem_init+0x15ee>
f0102e82:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e87:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e8d:	89 d8                	mov    %ebx,%eax
f0102e8f:	e8 78 e1 ff ff       	call   f010100c <check_va2pa>
f0102e94:	8b 15 ac fd 17 f0    	mov    0xf017fdac,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e9a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ea0:	77 20                	ja     f0102ec2 <mem_init+0x15ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ea6:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0102ead:	f0 
f0102eae:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0102eb5:	00 
f0102eb6:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102ebd:	e8 fc d1 ff ff       	call   f01000be <_panic>
f0102ec2:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102ec9:	39 d0                	cmp    %edx,%eax
f0102ecb:	74 24                	je     f0102ef1 <mem_init+0x15dd>
f0102ecd:	c7 44 24 0c 94 5e 10 	movl   $0xf0105e94,0xc(%esp)
f0102ed4:	f0 
f0102ed5:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102edc:	f0 
f0102edd:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0102ee4:	00 
f0102ee5:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102eec:	e8 cd d1 ff ff       	call   f01000be <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ef1:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ef7:	39 f7                	cmp    %esi,%edi
f0102ef9:	77 8c                	ja     f0102e87 <mem_init+0x1573>
f0102efb:	be 00 00 00 00       	mov    $0x0,%esi
f0102f00:	eb 05                	jmp    f0102f07 <mem_init+0x15f3>
f0102f02:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f07:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f0d:	89 d8                	mov    %ebx,%eax
f0102f0f:	e8 f8 e0 ff ff       	call   f010100c <check_va2pa>
f0102f14:	8b 15 08 f1 17 f0    	mov    0xf017f108,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f1a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f20:	77 20                	ja     f0102f42 <mem_init+0x162e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f22:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f26:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f0102f2d:	f0 
f0102f2e:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0102f35:	00 
f0102f36:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102f3d:	e8 7c d1 ff ff       	call   f01000be <_panic>
f0102f42:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102f49:	39 d0                	cmp    %edx,%eax
f0102f4b:	74 24                	je     f0102f71 <mem_init+0x165d>
f0102f4d:	c7 44 24 0c c8 5e 10 	movl   $0xf0105ec8,0xc(%esp)
f0102f54:	f0 
f0102f55:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102f5c:	f0 
f0102f5d:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0102f64:	00 
f0102f65:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102f6c:	e8 4d d1 ff ff       	call   f01000be <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f71:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f77:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102f7d:	75 88                	jne    f0102f07 <mem_init+0x15f3>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f7f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f82:	c1 e7 0c             	shl    $0xc,%edi
f0102f85:	85 ff                	test   %edi,%edi
f0102f87:	74 44                	je     f0102fcd <mem_init+0x16b9>
f0102f89:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102f8e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f94:	89 d8                	mov    %ebx,%eax
f0102f96:	e8 71 e0 ff ff       	call   f010100c <check_va2pa>
f0102f9b:	39 c6                	cmp    %eax,%esi
f0102f9d:	74 24                	je     f0102fc3 <mem_init+0x16af>
f0102f9f:	c7 44 24 0c fc 5e 10 	movl   $0xf0105efc,0xc(%esp)
f0102fa6:	f0 
f0102fa7:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102fae:	f0 
f0102faf:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0102fb6:	00 
f0102fb7:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0102fbe:	e8 fb d0 ff ff       	call   f01000be <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102fc3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102fc9:	39 fe                	cmp    %edi,%esi
f0102fcb:	72 c1                	jb     f0102f8e <mem_init+0x167a>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102fcd:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102fd2:	89 d8                	mov    %ebx,%eax
f0102fd4:	e8 33 e0 ff ff       	call   f010100c <check_va2pa>
f0102fd9:	be 00 90 ff ef       	mov    $0xefff9000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102fde:	bf 00 20 11 f0       	mov    $0xf0112000,%edi
f0102fe3:	81 c7 00 70 00 20    	add    $0x20007000,%edi
f0102fe9:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102fec:	39 c2                	cmp    %eax,%edx
f0102fee:	74 24                	je     f0103014 <mem_init+0x1700>
f0102ff0:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0102ff7:	f0 
f0102ff8:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0102fff:	f0 
f0103000:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0103007:	00 
f0103008:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010300f:	e8 aa d0 ff ff       	call   f01000be <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103014:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010301a:	0f 85 37 05 00 00    	jne    f0103557 <mem_init+0x1c43>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103020:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103025:	89 d8                	mov    %ebx,%eax
f0103027:	e8 e0 df ff ff       	call   f010100c <check_va2pa>
f010302c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010302f:	74 24                	je     f0103055 <mem_init+0x1741>
f0103031:	c7 44 24 0c 6c 5f 10 	movl   $0xf0105f6c,0xc(%esp)
f0103038:	f0 
f0103039:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103040:	f0 
f0103041:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0103048:	00 
f0103049:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0103050:	e8 69 d0 ff ff       	call   f01000be <_panic>
f0103055:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010305a:	ba 01 00 00 00       	mov    $0x1,%edx
f010305f:	8d 88 45 fc ff ff    	lea    -0x3bb(%eax),%ecx
f0103065:	83 f9 04             	cmp    $0x4,%ecx
f0103068:	77 39                	ja     f01030a3 <mem_init+0x178f>
f010306a:	89 d6                	mov    %edx,%esi
f010306c:	d3 e6                	shl    %cl,%esi
f010306e:	89 f1                	mov    %esi,%ecx
f0103070:	f6 c1 17             	test   $0x17,%cl
f0103073:	74 2e                	je     f01030a3 <mem_init+0x178f>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0103075:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103079:	0f 85 aa 00 00 00    	jne    f0103129 <mem_init+0x1815>
f010307f:	c7 44 24 0c 49 63 10 	movl   $0xf0106349,0xc(%esp)
f0103086:	f0 
f0103087:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010308e:	f0 
f010308f:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0103096:	00 
f0103097:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010309e:	e8 1b d0 ff ff       	call   f01000be <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01030a3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01030a8:	76 55                	jbe    f01030ff <mem_init+0x17eb>
				assert(pgdir[i] & PTE_P);
f01030aa:	8b 0c 83             	mov    (%ebx,%eax,4),%ecx
f01030ad:	f6 c1 01             	test   $0x1,%cl
f01030b0:	75 24                	jne    f01030d6 <mem_init+0x17c2>
f01030b2:	c7 44 24 0c 49 63 10 	movl   $0xf0106349,0xc(%esp)
f01030b9:	f0 
f01030ba:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01030c1:	f0 
f01030c2:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01030c9:	00 
f01030ca:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01030d1:	e8 e8 cf ff ff       	call   f01000be <_panic>
				assert(pgdir[i] & PTE_W);
f01030d6:	f6 c1 02             	test   $0x2,%cl
f01030d9:	75 4e                	jne    f0103129 <mem_init+0x1815>
f01030db:	c7 44 24 0c 5a 63 10 	movl   $0xf010635a,0xc(%esp)
f01030e2:	f0 
f01030e3:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01030ea:	f0 
f01030eb:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01030f2:	00 
f01030f3:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01030fa:	e8 bf cf ff ff       	call   f01000be <_panic>
			} else
				assert(pgdir[i] == 0);
f01030ff:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103103:	74 24                	je     f0103129 <mem_init+0x1815>
f0103105:	c7 44 24 0c 6b 63 10 	movl   $0xf010636b,0xc(%esp)
f010310c:	f0 
f010310d:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103114:	f0 
f0103115:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f010311c:	00 
f010311d:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0103124:	e8 95 cf ff ff       	call   f01000be <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103129:	83 c0 01             	add    $0x1,%eax
f010312c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103131:	0f 85 28 ff ff ff    	jne    f010305f <mem_init+0x174b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103137:	c7 04 24 9c 5f 10 f0 	movl   $0xf0105f9c,(%esp)
f010313e:	e8 37 09 00 00       	call   f0103a7a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103143:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103148:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010314d:	77 20                	ja     f010316f <mem_init+0x185b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010314f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103153:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f010315a:	f0 
f010315b:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
f0103162:	00 
f0103163:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010316a:	e8 4f cf ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f010316f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103174:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103177:	b8 00 00 00 00       	mov    $0x0,%eax
f010317c:	e8 ff df ff ff       	call   f0101180 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103181:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103184:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103189:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010318c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010318f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103196:	e8 15 e4 ff ff       	call   f01015b0 <page_alloc>
f010319b:	89 c6                	mov    %eax,%esi
f010319d:	85 c0                	test   %eax,%eax
f010319f:	75 24                	jne    f01031c5 <mem_init+0x18b1>
f01031a1:	c7 44 24 0c 7e 61 10 	movl   $0xf010617e,0xc(%esp)
f01031a8:	f0 
f01031a9:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01031b0:	f0 
f01031b1:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f01031b8:	00 
f01031b9:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01031c0:	e8 f9 ce ff ff       	call   f01000be <_panic>
	assert((pp1 = page_alloc(0)));
f01031c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031cc:	e8 df e3 ff ff       	call   f01015b0 <page_alloc>
f01031d1:	89 c7                	mov    %eax,%edi
f01031d3:	85 c0                	test   %eax,%eax
f01031d5:	75 24                	jne    f01031fb <mem_init+0x18e7>
f01031d7:	c7 44 24 0c 94 61 10 	movl   $0xf0106194,0xc(%esp)
f01031de:	f0 
f01031df:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01031e6:	f0 
f01031e7:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f01031ee:	00 
f01031ef:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01031f6:	e8 c3 ce ff ff       	call   f01000be <_panic>
	assert((pp2 = page_alloc(0)));
f01031fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103202:	e8 a9 e3 ff ff       	call   f01015b0 <page_alloc>
f0103207:	89 c3                	mov    %eax,%ebx
f0103209:	85 c0                	test   %eax,%eax
f010320b:	75 24                	jne    f0103231 <mem_init+0x191d>
f010320d:	c7 44 24 0c aa 61 10 	movl   $0xf01061aa,0xc(%esp)
f0103214:	f0 
f0103215:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010321c:	f0 
f010321d:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0103224:	00 
f0103225:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010322c:	e8 8d ce ff ff       	call   f01000be <_panic>
	page_free(pp0);
f0103231:	89 34 24             	mov    %esi,(%esp)
f0103234:	e8 f5 e3 ff ff       	call   f010162e <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103239:	89 f8                	mov    %edi,%eax
f010323b:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f0103241:	c1 f8 03             	sar    $0x3,%eax
f0103244:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103247:	89 c2                	mov    %eax,%edx
f0103249:	c1 ea 0c             	shr    $0xc,%edx
f010324c:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f0103252:	72 20                	jb     f0103274 <mem_init+0x1960>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103254:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103258:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f010325f:	f0 
f0103260:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0103267:	00 
f0103268:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f010326f:	e8 4a ce ff ff       	call   f01000be <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103274:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010327b:	00 
f010327c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103283:	00 
	return (void *)(pa + KERNBASE);
f0103284:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103289:	89 04 24             	mov    %eax,(%esp)
f010328c:	e8 40 19 00 00       	call   f0104bd1 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103291:	89 d8                	mov    %ebx,%eax
f0103293:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f0103299:	c1 f8 03             	sar    $0x3,%eax
f010329c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010329f:	89 c2                	mov    %eax,%edx
f01032a1:	c1 ea 0c             	shr    $0xc,%edx
f01032a4:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f01032aa:	72 20                	jb     f01032cc <mem_init+0x19b8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032b0:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f01032b7:	f0 
f01032b8:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f01032bf:	00 
f01032c0:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f01032c7:	e8 f2 cd ff ff       	call   f01000be <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01032cc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032d3:	00 
f01032d4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01032db:	00 
	return (void *)(pa + KERNBASE);
f01032dc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01032e1:	89 04 24             	mov    %eax,(%esp)
f01032e4:	e8 e8 18 00 00       	call   f0104bd1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01032e9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032f0:	00 
f01032f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032f8:	00 
f01032f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032fd:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f0103302:	89 04 24             	mov    %eax,(%esp)
f0103305:	e8 60 e5 ff ff       	call   f010186a <page_insert>
	assert(pp1->pp_ref == 1);
f010330a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010330f:	74 24                	je     f0103335 <mem_init+0x1a21>
f0103311:	c7 44 24 0c 7b 62 10 	movl   $0xf010627b,0xc(%esp)
f0103318:	f0 
f0103319:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103320:	f0 
f0103321:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0103328:	00 
f0103329:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0103330:	e8 89 cd ff ff       	call   f01000be <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103335:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010333c:	01 01 01 
f010333f:	74 24                	je     f0103365 <mem_init+0x1a51>
f0103341:	c7 44 24 0c bc 5f 10 	movl   $0xf0105fbc,0xc(%esp)
f0103348:	f0 
f0103349:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103350:	f0 
f0103351:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0103358:	00 
f0103359:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0103360:	e8 59 cd ff ff       	call   f01000be <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103365:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010336c:	00 
f010336d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103374:	00 
f0103375:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103379:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010337e:	89 04 24             	mov    %eax,(%esp)
f0103381:	e8 e4 e4 ff ff       	call   f010186a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103386:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010338d:	02 02 02 
f0103390:	74 24                	je     f01033b6 <mem_init+0x1aa2>
f0103392:	c7 44 24 0c e0 5f 10 	movl   $0xf0105fe0,0xc(%esp)
f0103399:	f0 
f010339a:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01033a1:	f0 
f01033a2:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f01033a9:	00 
f01033aa:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01033b1:	e8 08 cd ff ff       	call   f01000be <_panic>
	assert(pp2->pp_ref == 1);
f01033b6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01033bb:	74 24                	je     f01033e1 <mem_init+0x1acd>
f01033bd:	c7 44 24 0c a7 62 10 	movl   $0xf01062a7,0xc(%esp)
f01033c4:	f0 
f01033c5:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01033cc:	f0 
f01033cd:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f01033d4:	00 
f01033d5:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01033dc:	e8 dd cc ff ff       	call   f01000be <_panic>
	assert(pp1->pp_ref == 0);
f01033e1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01033e6:	74 24                	je     f010340c <mem_init+0x1af8>
f01033e8:	c7 44 24 0c f0 62 10 	movl   $0xf01062f0,0xc(%esp)
f01033ef:	f0 
f01033f0:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01033f7:	f0 
f01033f8:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f01033ff:	00 
f0103400:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0103407:	e8 b2 cc ff ff       	call   f01000be <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010340c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103413:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103416:	89 d8                	mov    %ebx,%eax
f0103418:	2b 05 ac fd 17 f0    	sub    0xf017fdac,%eax
f010341e:	c1 f8 03             	sar    $0x3,%eax
f0103421:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103424:	89 c2                	mov    %eax,%edx
f0103426:	c1 ea 0c             	shr    $0xc,%edx
f0103429:	3b 15 a4 fd 17 f0    	cmp    0xf017fda4,%edx
f010342f:	72 20                	jb     f0103451 <mem_init+0x1b3d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103431:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103435:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f010343c:	f0 
f010343d:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0103444:	00 
f0103445:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f010344c:	e8 6d cc ff ff       	call   f01000be <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103451:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103458:	03 03 03 
f010345b:	74 24                	je     f0103481 <mem_init+0x1b6d>
f010345d:	c7 44 24 0c 04 60 10 	movl   $0xf0106004,0xc(%esp)
f0103464:	f0 
f0103465:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f010346c:	f0 
f010346d:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0103474:	00 
f0103475:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f010347c:	e8 3d cc ff ff       	call   f01000be <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103481:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103488:	00 
f0103489:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f010348e:	89 04 24             	mov    %eax,(%esp)
f0103491:	e8 84 e3 ff ff       	call   f010181a <page_remove>
	assert(pp2->pp_ref == 0);
f0103496:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010349b:	74 24                	je     f01034c1 <mem_init+0x1bad>
f010349d:	c7 44 24 0c df 62 10 	movl   $0xf01062df,0xc(%esp)
f01034a4:	f0 
f01034a5:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01034ac:	f0 
f01034ad:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01034b4:	00 
f01034b5:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01034bc:	e8 fd cb ff ff       	call   f01000be <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01034c1:	a1 a8 fd 17 f0       	mov    0xf017fda8,%eax
f01034c6:	8b 08                	mov    (%eax),%ecx
f01034c8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01034ce:	89 f2                	mov    %esi,%edx
f01034d0:	2b 15 ac fd 17 f0    	sub    0xf017fdac,%edx
f01034d6:	c1 fa 03             	sar    $0x3,%edx
f01034d9:	c1 e2 0c             	shl    $0xc,%edx
f01034dc:	39 d1                	cmp    %edx,%ecx
f01034de:	74 24                	je     f0103504 <mem_init+0x1bf0>
f01034e0:	c7 44 24 0c 4c 5b 10 	movl   $0xf0105b4c,0xc(%esp)
f01034e7:	f0 
f01034e8:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f01034ef:	f0 
f01034f0:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f01034f7:	00 
f01034f8:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f01034ff:	e8 ba cb ff ff       	call   f01000be <_panic>
	kern_pgdir[0] = 0;
f0103504:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010350a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010350f:	74 24                	je     f0103535 <mem_init+0x1c21>
f0103511:	c7 44 24 0c 8c 62 10 	movl   $0xf010628c,0xc(%esp)
f0103518:	f0 
f0103519:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103520:	f0 
f0103521:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0103528:	00 
f0103529:	c7 04 24 91 60 10 f0 	movl   $0xf0106091,(%esp)
f0103530:	e8 89 cb ff ff       	call   f01000be <_panic>
	pp0->pp_ref = 0;
f0103535:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010353b:	89 34 24             	mov    %esi,(%esp)
f010353e:	e8 eb e0 ff ff       	call   f010162e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103543:	c7 04 24 30 60 10 f0 	movl   $0xf0106030,(%esp)
f010354a:	e8 2b 05 00 00       	call   f0103a7a <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010354f:	83 c4 3c             	add    $0x3c,%esp
f0103552:	5b                   	pop    %ebx
f0103553:	5e                   	pop    %esi
f0103554:	5f                   	pop    %edi
f0103555:	5d                   	pop    %ebp
f0103556:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103557:	89 f2                	mov    %esi,%edx
f0103559:	89 d8                	mov    %ebx,%eax
f010355b:	e8 ac da ff ff       	call   f010100c <check_va2pa>
f0103560:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103566:	e9 7e fa ff ff       	jmp    f0102fe9 <mem_init+0x16d5>

f010356b <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010356b:	55                   	push   %ebp
f010356c:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f010356e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103573:	5d                   	pop    %ebp
f0103574:	c3                   	ret    

f0103575 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103575:	55                   	push   %ebp
f0103576:	89 e5                	mov    %esp,%ebp
f0103578:	53                   	push   %ebx
f0103579:	83 ec 14             	sub    $0x14,%esp
f010357c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010357f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103582:	83 c8 04             	or     $0x4,%eax
f0103585:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103589:	8b 45 10             	mov    0x10(%ebp),%eax
f010358c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103590:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103593:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103597:	89 1c 24             	mov    %ebx,(%esp)
f010359a:	e8 cc ff ff ff       	call   f010356b <user_mem_check>
f010359f:	85 c0                	test   %eax,%eax
f01035a1:	79 23                	jns    f01035c6 <user_mem_assert+0x51>
		cprintf("[%08x] user_mem_check assertion failure for "
f01035a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01035aa:	00 
f01035ab:	8b 43 48             	mov    0x48(%ebx),%eax
f01035ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035b2:	c7 04 24 5c 60 10 f0 	movl   $0xf010605c,(%esp)
f01035b9:	e8 bc 04 00 00       	call   f0103a7a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01035be:	89 1c 24             	mov    %ebx,(%esp)
f01035c1:	e8 cc 03 00 00       	call   f0103992 <env_destroy>
	}
}
f01035c6:	83 c4 14             	add    $0x14,%esp
f01035c9:	5b                   	pop    %ebx
f01035ca:	5d                   	pop    %ebp
f01035cb:	c3                   	ret    

f01035cc <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01035cc:	55                   	push   %ebp
f01035cd:	89 e5                	mov    %esp,%ebp
f01035cf:	53                   	push   %ebx
f01035d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01035d6:	0f b6 5d 10          	movzbl 0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01035da:	85 c0                	test   %eax,%eax
f01035dc:	75 0e                	jne    f01035ec <envid2env+0x20>
		*env_store = curenv;
f01035de:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f01035e3:	89 01                	mov    %eax,(%ecx)
		return 0;
f01035e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01035ea:	eb 55                	jmp    f0103641 <envid2env+0x75>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01035ec:	89 c2                	mov    %eax,%edx
f01035ee:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01035f4:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01035f7:	c1 e2 05             	shl    $0x5,%edx
f01035fa:	03 15 08 f1 17 f0    	add    0xf017f108,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103600:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103604:	74 05                	je     f010360b <envid2env+0x3f>
f0103606:	39 42 48             	cmp    %eax,0x48(%edx)
f0103609:	74 0d                	je     f0103618 <envid2env+0x4c>
		*env_store = 0;
f010360b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0103611:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103616:	eb 29                	jmp    f0103641 <envid2env+0x75>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103618:	84 db                	test   %bl,%bl
f010361a:	74 1e                	je     f010363a <envid2env+0x6e>
f010361c:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f0103621:	39 c2                	cmp    %eax,%edx
f0103623:	74 15                	je     f010363a <envid2env+0x6e>
f0103625:	8b 58 48             	mov    0x48(%eax),%ebx
f0103628:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f010362b:	74 0d                	je     f010363a <envid2env+0x6e>
		*env_store = 0;
f010362d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0103633:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103638:	eb 07                	jmp    f0103641 <envid2env+0x75>
	}

	*env_store = e;
f010363a:	89 11                	mov    %edx,(%ecx)
	return 0;
f010363c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103641:	5b                   	pop    %ebx
f0103642:	5d                   	pop    %ebp
f0103643:	c3                   	ret    

f0103644 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103644:	55                   	push   %ebp
f0103645:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103647:	b8 20 c3 11 f0       	mov    $0xf011c320,%eax
f010364c:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010364f:	b8 23 00 00 00       	mov    $0x23,%eax
f0103654:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103656:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103658:	b0 10                	mov    $0x10,%al
f010365a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010365c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010365e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103660:	ea 67 36 10 f0 08 00 	ljmp   $0x8,$0xf0103667
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103667:	b0 00                	mov    $0x0,%al
f0103669:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010366c:	5d                   	pop    %ebp
f010366d:	c3                   	ret    

f010366e <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010366e:	55                   	push   %ebp
f010366f:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0103671:	e8 ce ff ff ff       	call   f0103644 <env_init_percpu>
}
f0103676:	5d                   	pop    %ebp
f0103677:	c3                   	ret    

f0103678 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103678:	55                   	push   %ebp
f0103679:	89 e5                	mov    %esp,%ebp
f010367b:	53                   	push   %ebx
f010367c:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010367f:	8b 1d 0c f1 17 f0    	mov    0xf017f10c,%ebx
f0103685:	85 db                	test   %ebx,%ebx
f0103687:	0f 84 06 01 00 00    	je     f0103793 <env_alloc+0x11b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010368d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103694:	e8 17 df ff ff       	call   f01015b0 <page_alloc>
f0103699:	85 c0                	test   %eax,%eax
f010369b:	0f 84 f9 00 00 00    	je     f010379a <env_alloc+0x122>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01036a1:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036a9:	77 20                	ja     f01036cb <env_alloc+0x53>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036af:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f01036b6:	f0 
f01036b7:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f01036be:	00 
f01036bf:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f01036c6:	e8 f3 c9 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036cb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01036d1:	83 ca 05             	or     $0x5,%edx
f01036d4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01036da:	8b 43 48             	mov    0x48(%ebx),%eax
f01036dd:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01036e2:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01036e7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01036ec:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01036ef:	89 da                	mov    %ebx,%edx
f01036f1:	2b 15 08 f1 17 f0    	sub    0xf017f108,%edx
f01036f7:	c1 fa 05             	sar    $0x5,%edx
f01036fa:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103700:	09 d0                	or     %edx,%eax
f0103702:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103705:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103708:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010370b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103712:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103719:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103720:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103727:	00 
f0103728:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010372f:	00 
f0103730:	89 1c 24             	mov    %ebx,(%esp)
f0103733:	e8 99 14 00 00       	call   f0104bd1 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103738:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010373e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103744:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010374a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103751:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103757:	8b 43 44             	mov    0x44(%ebx),%eax
f010375a:	a3 0c f1 17 f0       	mov    %eax,0xf017f10c
	*newenv_store = e;
f010375f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103762:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103764:	8b 4b 48             	mov    0x48(%ebx),%ecx
f0103767:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f010376c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103771:	85 c0                	test   %eax,%eax
f0103773:	74 03                	je     f0103778 <env_alloc+0x100>
f0103775:	8b 50 48             	mov    0x48(%eax),%edx
f0103778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010377c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103780:	c7 04 24 bd 63 10 f0 	movl   $0xf01063bd,(%esp)
f0103787:	e8 ee 02 00 00       	call   f0103a7a <cprintf>
	return 0;
f010378c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103791:	eb 0c                	jmp    f010379f <env_alloc+0x127>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103793:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103798:	eb 05                	jmp    f010379f <env_alloc+0x127>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010379a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010379f:	83 c4 14             	add    $0x14,%esp
f01037a2:	5b                   	pop    %ebx
f01037a3:	5d                   	pop    %ebp
f01037a4:	c3                   	ret    

f01037a5 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f01037a5:	55                   	push   %ebp
f01037a6:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f01037a8:	5d                   	pop    %ebp
f01037a9:	c3                   	ret    

f01037aa <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01037aa:	55                   	push   %ebp
f01037ab:	89 e5                	mov    %esp,%ebp
f01037ad:	57                   	push   %edi
f01037ae:	56                   	push   %esi
f01037af:	53                   	push   %ebx
f01037b0:	83 ec 2c             	sub    $0x2c,%esp
f01037b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037b6:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f01037bb:	39 c7                	cmp    %eax,%edi
f01037bd:	75 37                	jne    f01037f6 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f01037bf:	8b 15 a8 fd 17 f0    	mov    0xf017fda8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037c5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01037cb:	77 20                	ja     f01037ed <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01037d1:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f01037d8:	f0 
f01037d9:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f01037e0:	00 
f01037e1:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f01037e8:	e8 d1 c8 ff ff       	call   f01000be <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037ed:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01037f3:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037f6:	8b 4f 48             	mov    0x48(%edi),%ecx
f01037f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01037fe:	85 c0                	test   %eax,%eax
f0103800:	74 03                	je     f0103805 <env_free+0x5b>
f0103802:	8b 50 48             	mov    0x48(%eax),%edx
f0103805:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103809:	89 54 24 04          	mov    %edx,0x4(%esp)
f010380d:	c7 04 24 d2 63 10 f0 	movl   $0xf01063d2,(%esp)
f0103814:	e8 61 02 00 00       	call   f0103a7a <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103819:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103820:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103823:	c1 e0 02             	shl    $0x2,%eax
f0103826:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103829:	8b 47 5c             	mov    0x5c(%edi),%eax
f010382c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010382f:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103832:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103838:	0f 84 b8 00 00 00    	je     f01038f6 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010383e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103844:	89 f0                	mov    %esi,%eax
f0103846:	c1 e8 0c             	shr    $0xc,%eax
f0103849:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010384c:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f0103852:	72 20                	jb     f0103874 <env_free+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103854:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103858:	c7 44 24 08 e8 58 10 	movl   $0xf01058e8,0x8(%esp)
f010385f:	f0 
f0103860:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0103867:	00 
f0103868:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f010386f:	e8 4a c8 ff ff       	call   f01000be <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103874:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103877:	c1 e2 16             	shl    $0x16,%edx
f010387a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010387d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103882:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103889:	01 
f010388a:	74 17                	je     f01038a3 <env_free+0xf9>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010388c:	89 d8                	mov    %ebx,%eax
f010388e:	c1 e0 0c             	shl    $0xc,%eax
f0103891:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103894:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103898:	8b 47 5c             	mov    0x5c(%edi),%eax
f010389b:	89 04 24             	mov    %eax,(%esp)
f010389e:	e8 77 df ff ff       	call   f010181a <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01038a3:	83 c3 01             	add    $0x1,%ebx
f01038a6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01038ac:	75 d4                	jne    f0103882 <env_free+0xd8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01038ae:	8b 47 5c             	mov    0x5c(%edi),%eax
f01038b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038b4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01038be:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f01038c4:	72 1c                	jb     f01038e2 <env_free+0x138>
		panic("pa2page called with invalid pa");
f01038c6:	c7 44 24 08 18 5a 10 	movl   $0xf0105a18,0x8(%esp)
f01038cd:	f0 
f01038ce:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f01038d5:	00 
f01038d6:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f01038dd:	e8 dc c7 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f01038e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01038e5:	c1 e0 03             	shl    $0x3,%eax
f01038e8:	03 05 ac fd 17 f0    	add    0xf017fdac,%eax
		page_decref(pa2page(pa));
f01038ee:	89 04 24             	mov    %eax,(%esp)
f01038f1:	e8 70 dd ff ff       	call   f0101666 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038f6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01038fa:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103901:	0f 85 19 ff ff ff    	jne    f0103820 <env_free+0x76>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103907:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010390a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010390f:	77 20                	ja     f0103931 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103911:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103915:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f010391c:	f0 
f010391d:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0103924:	00 
f0103925:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f010392c:	e8 8d c7 ff ff       	call   f01000be <_panic>
	e->env_pgdir = 0;
f0103931:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103938:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010393d:	c1 e8 0c             	shr    $0xc,%eax
f0103940:	3b 05 a4 fd 17 f0    	cmp    0xf017fda4,%eax
f0103946:	72 1c                	jb     f0103964 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f0103948:	c7 44 24 08 18 5a 10 	movl   $0xf0105a18,0x8(%esp)
f010394f:	f0 
f0103950:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f0103957:	00 
f0103958:	c7 04 24 b9 60 10 f0 	movl   $0xf01060b9,(%esp)
f010395f:	e8 5a c7 ff ff       	call   f01000be <_panic>
	return &pages[PGNUM(pa)];
f0103964:	c1 e0 03             	shl    $0x3,%eax
f0103967:	03 05 ac fd 17 f0    	add    0xf017fdac,%eax
	page_decref(pa2page(pa));
f010396d:	89 04 24             	mov    %eax,(%esp)
f0103970:	e8 f1 dc ff ff       	call   f0101666 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103975:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010397c:	a1 0c f1 17 f0       	mov    0xf017f10c,%eax
f0103981:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103984:	89 3d 0c f1 17 f0    	mov    %edi,0xf017f10c
}
f010398a:	83 c4 2c             	add    $0x2c,%esp
f010398d:	5b                   	pop    %ebx
f010398e:	5e                   	pop    %esi
f010398f:	5f                   	pop    %edi
f0103990:	5d                   	pop    %ebp
f0103991:	c3                   	ret    

f0103992 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103992:	55                   	push   %ebp
f0103993:	89 e5                	mov    %esp,%ebp
f0103995:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103998:	8b 45 08             	mov    0x8(%ebp),%eax
f010399b:	89 04 24             	mov    %eax,(%esp)
f010399e:	e8 07 fe ff ff       	call   f01037aa <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01039a3:	c7 04 24 7c 63 10 f0 	movl   $0xf010637c,(%esp)
f01039aa:	e8 cb 00 00 00       	call   f0103a7a <cprintf>
	while (1)
		monitor(NULL);
f01039af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01039b6:	e8 f1 d4 ff ff       	call   f0100eac <monitor>
f01039bb:	eb f2                	jmp    f01039af <env_destroy+0x1d>

f01039bd <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039bd:	55                   	push   %ebp
f01039be:	89 e5                	mov    %esp,%ebp
f01039c0:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01039c3:	8b 65 08             	mov    0x8(%ebp),%esp
f01039c6:	61                   	popa   
f01039c7:	07                   	pop    %es
f01039c8:	1f                   	pop    %ds
f01039c9:	83 c4 08             	add    $0x8,%esp
f01039cc:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01039cd:	c7 44 24 08 e8 63 10 	movl   $0xf01063e8,0x8(%esp)
f01039d4:	f0 
f01039d5:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01039dc:	00 
f01039dd:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f01039e4:	e8 d5 c6 ff ff       	call   f01000be <_panic>

f01039e9 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01039e9:	55                   	push   %ebp
f01039ea:	89 e5                	mov    %esp,%ebp
f01039ec:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f01039ef:	c7 44 24 08 f4 63 10 	movl   $0xf01063f4,0x8(%esp)
f01039f6:	f0 
f01039f7:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f01039fe:	00 
f01039ff:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f0103a06:	e8 b3 c6 ff ff       	call   f01000be <_panic>
	...

f0103a0c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103a0c:	55                   	push   %ebp
f0103a0d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a0f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a14:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a17:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103a18:	b2 71                	mov    $0x71,%dl
f0103a1a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103a1b:	0f b6 c0             	movzbl %al,%eax
}
f0103a1e:	5d                   	pop    %ebp
f0103a1f:	c3                   	ret    

f0103a20 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103a20:	55                   	push   %ebp
f0103a21:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a23:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a28:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a2b:	ee                   	out    %al,(%dx)
f0103a2c:	b2 71                	mov    $0x71,%dl
f0103a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a31:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a32:	5d                   	pop    %ebp
f0103a33:	c3                   	ret    

f0103a34 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a34:	55                   	push   %ebp
f0103a35:	89 e5                	mov    %esp,%ebp
f0103a37:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103a3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a3d:	89 04 24             	mov    %eax,(%esp)
f0103a40:	e8 db cb ff ff       	call   f0100620 <cputchar>
	*cnt++;
}
f0103a45:	c9                   	leave  
f0103a46:	c3                   	ret    

f0103a47 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103a47:	55                   	push   %ebp
f0103a48:	89 e5                	mov    %esp,%ebp
f0103a4a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103a4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103a54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a57:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a5e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a69:	c7 04 24 34 3a 10 f0 	movl   $0xf0103a34,(%esp)
f0103a70:	e8 25 09 00 00       	call   f010439a <vprintfmt>
	return cnt;
}
f0103a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a78:	c9                   	leave  
f0103a79:	c3                   	ret    

f0103a7a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a7a:	55                   	push   %ebp
f0103a7b:	89 e5                	mov    %esp,%ebp
f0103a7d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103a80:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103a83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a87:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a8a:	89 04 24             	mov    %eax,(%esp)
f0103a8d:	e8 b5 ff ff ff       	call   f0103a47 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a92:	c9                   	leave  
f0103a93:	c3                   	ret    

f0103a94 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103a94:	55                   	push   %ebp
f0103a95:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103a97:	c7 05 24 f9 17 f0 00 	movl   $0xf0000000,0xf017f924
f0103a9e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103aa1:	66 c7 05 28 f9 17 f0 	movw   $0x10,0xf017f928
f0103aa8:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103aaa:	66 c7 05 68 c3 11 f0 	movw   $0x68,0xf011c368
f0103ab1:	68 00 
f0103ab3:	b8 20 f9 17 f0       	mov    $0xf017f920,%eax
f0103ab8:	66 a3 6a c3 11 f0    	mov    %ax,0xf011c36a
f0103abe:	89 c2                	mov    %eax,%edx
f0103ac0:	c1 ea 10             	shr    $0x10,%edx
f0103ac3:	88 15 6c c3 11 f0    	mov    %dl,0xf011c36c
f0103ac9:	c6 05 6e c3 11 f0 40 	movb   $0x40,0xf011c36e
f0103ad0:	c1 e8 18             	shr    $0x18,%eax
f0103ad3:	a2 6f c3 11 f0       	mov    %al,0xf011c36f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103ad8:	c6 05 6d c3 11 f0 89 	movb   $0x89,0xf011c36d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103adf:	b8 28 00 00 00       	mov    $0x28,%eax
f0103ae4:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103ae7:	b8 70 c3 11 f0       	mov    $0xf011c370,%eax
f0103aec:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103aef:	5d                   	pop    %ebp
f0103af0:	c3                   	ret    

f0103af1 <trap_init>:
}


void
trap_init(void)
{
f0103af1:	55                   	push   %ebp
f0103af2:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103af4:	e8 9b ff ff ff       	call   f0103a94 <trap_init_percpu>
}
f0103af9:	5d                   	pop    %ebp
f0103afa:	c3                   	ret    

f0103afb <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103afb:	55                   	push   %ebp
f0103afc:	89 e5                	mov    %esp,%ebp
f0103afe:	53                   	push   %ebx
f0103aff:	83 ec 14             	sub    $0x14,%esp
f0103b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103b05:	8b 03                	mov    (%ebx),%eax
f0103b07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b0b:	c7 04 24 10 64 10 f0 	movl   $0xf0106410,(%esp)
f0103b12:	e8 63 ff ff ff       	call   f0103a7a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103b17:	8b 43 04             	mov    0x4(%ebx),%eax
f0103b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b1e:	c7 04 24 1f 64 10 f0 	movl   $0xf010641f,(%esp)
f0103b25:	e8 50 ff ff ff       	call   f0103a7a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103b2a:	8b 43 08             	mov    0x8(%ebx),%eax
f0103b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b31:	c7 04 24 2e 64 10 f0 	movl   $0xf010642e,(%esp)
f0103b38:	e8 3d ff ff ff       	call   f0103a7a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103b3d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103b40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b44:	c7 04 24 3d 64 10 f0 	movl   $0xf010643d,(%esp)
f0103b4b:	e8 2a ff ff ff       	call   f0103a7a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103b50:	8b 43 10             	mov    0x10(%ebx),%eax
f0103b53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b57:	c7 04 24 4c 64 10 f0 	movl   $0xf010644c,(%esp)
f0103b5e:	e8 17 ff ff ff       	call   f0103a7a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103b63:	8b 43 14             	mov    0x14(%ebx),%eax
f0103b66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b6a:	c7 04 24 5b 64 10 f0 	movl   $0xf010645b,(%esp)
f0103b71:	e8 04 ff ff ff       	call   f0103a7a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103b76:	8b 43 18             	mov    0x18(%ebx),%eax
f0103b79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b7d:	c7 04 24 6a 64 10 f0 	movl   $0xf010646a,(%esp)
f0103b84:	e8 f1 fe ff ff       	call   f0103a7a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103b89:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b90:	c7 04 24 79 64 10 f0 	movl   $0xf0106479,(%esp)
f0103b97:	e8 de fe ff ff       	call   f0103a7a <cprintf>
}
f0103b9c:	83 c4 14             	add    $0x14,%esp
f0103b9f:	5b                   	pop    %ebx
f0103ba0:	5d                   	pop    %ebp
f0103ba1:	c3                   	ret    

f0103ba2 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ba2:	55                   	push   %ebp
f0103ba3:	89 e5                	mov    %esp,%ebp
f0103ba5:	56                   	push   %esi
f0103ba6:	53                   	push   %ebx
f0103ba7:	83 ec 10             	sub    $0x10,%esp
f0103baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103bad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103bb1:	c7 04 24 af 65 10 f0 	movl   $0xf01065af,(%esp)
f0103bb8:	e8 bd fe ff ff       	call   f0103a7a <cprintf>
	print_regs(&tf->tf_regs);
f0103bbd:	89 1c 24             	mov    %ebx,(%esp)
f0103bc0:	e8 36 ff ff ff       	call   f0103afb <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103bc5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bcd:	c7 04 24 ca 64 10 f0 	movl   $0xf01064ca,(%esp)
f0103bd4:	e8 a1 fe ff ff       	call   f0103a7a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103bd9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be1:	c7 04 24 dd 64 10 f0 	movl   $0xf01064dd,(%esp)
f0103be8:	e8 8d fe ff ff       	call   f0103a7a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103bed:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103bf0:	83 f8 13             	cmp    $0x13,%eax
f0103bf3:	77 09                	ja     f0103bfe <print_trapframe+0x5c>
		return excnames[trapno];
f0103bf5:	8b 14 85 80 67 10 f0 	mov    -0xfef9880(,%eax,4),%edx
f0103bfc:	eb 10                	jmp    f0103c0e <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0103bfe:	83 f8 30             	cmp    $0x30,%eax
f0103c01:	ba 88 64 10 f0       	mov    $0xf0106488,%edx
f0103c06:	b9 94 64 10 f0       	mov    $0xf0106494,%ecx
f0103c0b:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c0e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c16:	c7 04 24 f0 64 10 f0 	movl   $0xf01064f0,(%esp)
f0103c1d:	e8 58 fe ff ff       	call   f0103a7a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103c22:	3b 1d 88 f9 17 f0    	cmp    0xf017f988,%ebx
f0103c28:	75 19                	jne    f0103c43 <print_trapframe+0xa1>
f0103c2a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c2e:	75 13                	jne    f0103c43 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103c30:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103c33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c37:	c7 04 24 02 65 10 f0 	movl   $0xf0106502,(%esp)
f0103c3e:	e8 37 fe ff ff       	call   f0103a7a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103c43:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103c46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c4a:	c7 04 24 11 65 10 f0 	movl   $0xf0106511,(%esp)
f0103c51:	e8 24 fe ff ff       	call   f0103a7a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103c56:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c5a:	75 51                	jne    f0103cad <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103c5c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103c5f:	89 c2                	mov    %eax,%edx
f0103c61:	83 e2 01             	and    $0x1,%edx
f0103c64:	ba a3 64 10 f0       	mov    $0xf01064a3,%edx
f0103c69:	b9 ae 64 10 f0       	mov    $0xf01064ae,%ecx
f0103c6e:	0f 45 ca             	cmovne %edx,%ecx
f0103c71:	89 c2                	mov    %eax,%edx
f0103c73:	83 e2 02             	and    $0x2,%edx
f0103c76:	ba ba 64 10 f0       	mov    $0xf01064ba,%edx
f0103c7b:	be c0 64 10 f0       	mov    $0xf01064c0,%esi
f0103c80:	0f 44 d6             	cmove  %esi,%edx
f0103c83:	83 e0 04             	and    $0x4,%eax
f0103c86:	b8 c5 64 10 f0       	mov    $0xf01064c5,%eax
f0103c8b:	be da 65 10 f0       	mov    $0xf01065da,%esi
f0103c90:	0f 44 c6             	cmove  %esi,%eax
f0103c93:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103c97:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c9f:	c7 04 24 1f 65 10 f0 	movl   $0xf010651f,(%esp)
f0103ca6:	e8 cf fd ff ff       	call   f0103a7a <cprintf>
f0103cab:	eb 0c                	jmp    f0103cb9 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103cad:	c7 04 24 47 63 10 f0 	movl   $0xf0106347,(%esp)
f0103cb4:	e8 c1 fd ff ff       	call   f0103a7a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103cb9:	8b 43 30             	mov    0x30(%ebx),%eax
f0103cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cc0:	c7 04 24 2e 65 10 f0 	movl   $0xf010652e,(%esp)
f0103cc7:	e8 ae fd ff ff       	call   f0103a7a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ccc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cd4:	c7 04 24 3d 65 10 f0 	movl   $0xf010653d,(%esp)
f0103cdb:	e8 9a fd ff ff       	call   f0103a7a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ce0:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ce7:	c7 04 24 50 65 10 f0 	movl   $0xf0106550,(%esp)
f0103cee:	e8 87 fd ff ff       	call   f0103a7a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103cf3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103cf7:	74 27                	je     f0103d20 <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103cf9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d00:	c7 04 24 5f 65 10 f0 	movl   $0xf010655f,(%esp)
f0103d07:	e8 6e fd ff ff       	call   f0103a7a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d0c:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d14:	c7 04 24 6e 65 10 f0 	movl   $0xf010656e,(%esp)
f0103d1b:	e8 5a fd ff ff       	call   f0103a7a <cprintf>
	}
}
f0103d20:	83 c4 10             	add    $0x10,%esp
f0103d23:	5b                   	pop    %ebx
f0103d24:	5e                   	pop    %esi
f0103d25:	5d                   	pop    %ebp
f0103d26:	c3                   	ret    

f0103d27 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103d27:	55                   	push   %ebp
f0103d28:	89 e5                	mov    %esp,%ebp
f0103d2a:	57                   	push   %edi
f0103d2b:	56                   	push   %esi
f0103d2c:	83 ec 10             	sub    $0x10,%esp
f0103d2f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103d32:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103d33:	9c                   	pushf  
f0103d34:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103d35:	f6 c4 02             	test   $0x2,%ah
f0103d38:	74 24                	je     f0103d5e <trap+0x37>
f0103d3a:	c7 44 24 0c 81 65 10 	movl   $0xf0106581,0xc(%esp)
f0103d41:	f0 
f0103d42:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103d49:	f0 
f0103d4a:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
f0103d51:	00 
f0103d52:	c7 04 24 9a 65 10 f0 	movl   $0xf010659a,(%esp)
f0103d59:	e8 60 c3 ff ff       	call   f01000be <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103d5e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d62:	c7 04 24 a6 65 10 f0 	movl   $0xf01065a6,(%esp)
f0103d69:	e8 0c fd ff ff       	call   f0103a7a <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103d6e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d72:	83 e0 03             	and    $0x3,%eax
f0103d75:	83 f8 03             	cmp    $0x3,%eax
f0103d78:	75 3c                	jne    f0103db6 <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f0103d7a:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f0103d7f:	85 c0                	test   %eax,%eax
f0103d81:	75 24                	jne    f0103da7 <trap+0x80>
f0103d83:	c7 44 24 0c c1 65 10 	movl   $0xf01065c1,0xc(%esp)
f0103d8a:	f0 
f0103d8b:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103d92:	f0 
f0103d93:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
f0103d9a:	00 
f0103d9b:	c7 04 24 9a 65 10 f0 	movl   $0xf010659a,(%esp)
f0103da2:	e8 17 c3 ff ff       	call   f01000be <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103da7:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103dac:	89 c7                	mov    %eax,%edi
f0103dae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103db0:	8b 35 04 f1 17 f0    	mov    0xf017f104,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103db6:	89 35 88 f9 17 f0    	mov    %esi,0xf017f988
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103dbc:	89 34 24             	mov    %esi,(%esp)
f0103dbf:	e8 de fd ff ff       	call   f0103ba2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103dc4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103dc9:	75 1c                	jne    f0103de7 <trap+0xc0>
		panic("unhandled trap in kernel");
f0103dcb:	c7 44 24 08 c8 65 10 	movl   $0xf01065c8,0x8(%esp)
f0103dd2:	f0 
f0103dd3:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f0103dda:	00 
f0103ddb:	c7 04 24 9a 65 10 f0 	movl   $0xf010659a,(%esp)
f0103de2:	e8 d7 c2 ff ff       	call   f01000be <_panic>
	else {
		env_destroy(curenv);
f0103de7:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f0103dec:	89 04 24             	mov    %eax,(%esp)
f0103def:	e8 9e fb ff ff       	call   f0103992 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103df4:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f0103df9:	85 c0                	test   %eax,%eax
f0103dfb:	74 06                	je     f0103e03 <trap+0xdc>
f0103dfd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e01:	74 24                	je     f0103e27 <trap+0x100>
f0103e03:	c7 44 24 0c 24 67 10 	movl   $0xf0106724,0xc(%esp)
f0103e0a:	f0 
f0103e0b:	c7 44 24 08 d3 60 10 	movl   $0xf01060d3,0x8(%esp)
f0103e12:	f0 
f0103e13:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0103e1a:	00 
f0103e1b:	c7 04 24 9a 65 10 f0 	movl   $0xf010659a,(%esp)
f0103e22:	e8 97 c2 ff ff       	call   f01000be <_panic>
	env_run(curenv);
f0103e27:	89 04 24             	mov    %eax,(%esp)
f0103e2a:	e8 ba fb ff ff       	call   f01039e9 <env_run>

f0103e2f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e2f:	55                   	push   %ebp
f0103e30:	89 e5                	mov    %esp,%ebp
f0103e32:	53                   	push   %ebx
f0103e33:	83 ec 14             	sub    $0x14,%esp
f0103e36:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103e39:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e3c:	8b 53 30             	mov    0x30(%ebx),%edx
f0103e3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103e43:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103e47:	a1 04 f1 17 f0       	mov    0xf017f104,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e4c:	8b 40 48             	mov    0x48(%eax),%eax
f0103e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e53:	c7 04 24 50 67 10 f0 	movl   $0xf0106750,(%esp)
f0103e5a:	e8 1b fc ff ff       	call   f0103a7a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e5f:	89 1c 24             	mov    %ebx,(%esp)
f0103e62:	e8 3b fd ff ff       	call   f0103ba2 <print_trapframe>
	env_destroy(curenv);
f0103e67:	a1 04 f1 17 f0       	mov    0xf017f104,%eax
f0103e6c:	89 04 24             	mov    %eax,(%esp)
f0103e6f:	e8 1e fb ff ff       	call   f0103992 <env_destroy>
}
f0103e74:	83 c4 14             	add    $0x14,%esp
f0103e77:	5b                   	pop    %ebx
f0103e78:	5d                   	pop    %ebp
f0103e79:	c3                   	ret    
	...

f0103e7c <syscall>:
f0103e7c:	55                   	push   %ebp
f0103e7d:	89 e5                	mov    %esp,%ebp
f0103e7f:	83 ec 18             	sub    $0x18,%esp
f0103e82:	c7 44 24 08 d0 67 10 	movl   $0xf01067d0,0x8(%esp)
f0103e89:	f0 
f0103e8a:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0103e91:	00 
f0103e92:	c7 04 24 e8 67 10 f0 	movl   $0xf01067e8,(%esp)
f0103e99:	e8 20 c2 ff ff       	call   f01000be <_panic>
	...

f0103ea0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103ea0:	55                   	push   %ebp
f0103ea1:	89 e5                	mov    %esp,%ebp
f0103ea3:	57                   	push   %edi
f0103ea4:	56                   	push   %esi
f0103ea5:	53                   	push   %ebx
f0103ea6:	83 ec 14             	sub    $0x14,%esp
f0103ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103eac:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103eaf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103eb2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103eb5:	8b 1a                	mov    (%edx),%ebx
f0103eb7:	8b 01                	mov    (%ecx),%eax
f0103eb9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0103ebc:	39 c3                	cmp    %eax,%ebx
f0103ebe:	0f 8f 9c 00 00 00    	jg     f0103f60 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103ec4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ece:	01 d8                	add    %ebx,%eax
f0103ed0:	89 c7                	mov    %eax,%edi
f0103ed2:	c1 ef 1f             	shr    $0x1f,%edi
f0103ed5:	01 c7                	add    %eax,%edi
f0103ed7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ed9:	39 df                	cmp    %ebx,%edi
f0103edb:	7c 33                	jl     f0103f10 <stab_binsearch+0x70>
f0103edd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103ee0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ee3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103ee8:	39 f0                	cmp    %esi,%eax
f0103eea:	0f 84 bc 00 00 00    	je     f0103fac <stab_binsearch+0x10c>
f0103ef0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103ef4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ef8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103efa:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103efd:	39 d8                	cmp    %ebx,%eax
f0103eff:	7c 0f                	jl     f0103f10 <stab_binsearch+0x70>
f0103f01:	0f b6 0a             	movzbl (%edx),%ecx
f0103f04:	83 ea 0c             	sub    $0xc,%edx
f0103f07:	39 f1                	cmp    %esi,%ecx
f0103f09:	75 ef                	jne    f0103efa <stab_binsearch+0x5a>
f0103f0b:	e9 9e 00 00 00       	jmp    f0103fae <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103f10:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103f13:	eb 3c                	jmp    f0103f51 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103f15:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f18:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0103f1a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f1d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103f24:	eb 2b                	jmp    f0103f51 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103f26:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103f29:	76 14                	jbe    f0103f3f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103f2b:	83 e8 01             	sub    $0x1,%eax
f0103f2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103f31:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f34:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f36:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103f3d:	eb 12                	jmp    f0103f51 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103f3f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f42:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103f44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103f48:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f4a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103f51:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103f54:	0f 8d 71 ff ff ff    	jge    f0103ecb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103f5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f5e:	75 0f                	jne    f0103f6f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103f60:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f63:	8b 02                	mov    (%edx),%eax
f0103f65:	83 e8 01             	sub    $0x1,%eax
f0103f68:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f6b:	89 01                	mov    %eax,(%ecx)
f0103f6d:	eb 57                	jmp    f0103fc6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f72:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103f74:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f77:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f79:	39 c1                	cmp    %eax,%ecx
f0103f7b:	7d 28                	jge    f0103fa5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103f7d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f80:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103f83:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103f88:	39 f2                	cmp    %esi,%edx
f0103f8a:	74 19                	je     f0103fa5 <stab_binsearch+0x105>
f0103f8c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103f90:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103f94:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f97:	39 c1                	cmp    %eax,%ecx
f0103f99:	7d 0a                	jge    f0103fa5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103f9b:	0f b6 1a             	movzbl (%edx),%ebx
f0103f9e:	83 ea 0c             	sub    $0xc,%edx
f0103fa1:	39 f3                	cmp    %esi,%ebx
f0103fa3:	75 ef                	jne    f0103f94 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103fa5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103fa8:	89 02                	mov    %eax,(%edx)
f0103faa:	eb 1a                	jmp    f0103fc6 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103fac:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103fae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103fb1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103fb4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103fb8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103fbb:	0f 82 54 ff ff ff    	jb     f0103f15 <stab_binsearch+0x75>
f0103fc1:	e9 60 ff ff ff       	jmp    f0103f26 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103fc6:	83 c4 14             	add    $0x14,%esp
f0103fc9:	5b                   	pop    %ebx
f0103fca:	5e                   	pop    %esi
f0103fcb:	5f                   	pop    %edi
f0103fcc:	5d                   	pop    %ebp
f0103fcd:	c3                   	ret    

f0103fce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103fce:	55                   	push   %ebp
f0103fcf:	89 e5                	mov    %esp,%ebp
f0103fd1:	57                   	push   %edi
f0103fd2:	56                   	push   %esi
f0103fd3:	53                   	push   %ebx
f0103fd4:	83 ec 5c             	sub    $0x5c,%esp
f0103fd7:	8b 75 08             	mov    0x8(%ebp),%esi
f0103fda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103fdd:	c7 03 f7 67 10 f0    	movl   $0xf01067f7,(%ebx)
	info->eip_line = 0;
f0103fe3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103fea:	c7 43 08 f7 67 10 f0 	movl   $0xf01067f7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103ff1:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103ff8:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103ffb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104002:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104008:	77 23                	ja     f010402d <debuginfo_eip+0x5f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010400a:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0104010:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104013:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0104019:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010401f:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104022:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104028:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010402b:	eb 1a                	jmp    f0104047 <debuginfo_eip+0x79>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010402d:	c7 45 c0 f1 19 11 f0 	movl   $0xf01119f1,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104034:	c7 45 bc 59 ee 10 f0 	movl   $0xf010ee59,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010403b:	ba 58 ee 10 f0       	mov    $0xf010ee58,%edx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104040:	c7 45 c4 28 6a 10 f0 	movl   $0xf0106a28,-0x3c(%ebp)
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104047:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010404c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010404f:	39 7d bc             	cmp    %edi,-0x44(%ebp)
f0104052:	0f 83 df 01 00 00    	jae    f0104237 <debuginfo_eip+0x269>
f0104058:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010405c:	0f 85 d5 01 00 00    	jne    f0104237 <debuginfo_eip+0x269>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104062:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104069:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f010406c:	c1 fa 02             	sar    $0x2,%edx
f010406f:	69 c2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%eax
f0104075:	83 e8 01             	sub    $0x1,%eax
f0104078:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010407b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010407f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104086:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104089:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010408c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010408f:	e8 0c fe ff ff       	call   f0103ea0 <stab_binsearch>
	if (lfile == 0)
f0104094:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0104097:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010409c:	85 d2                	test   %edx,%edx
f010409e:	0f 84 93 01 00 00    	je     f0104237 <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01040a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01040a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01040ad:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040b1:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01040b8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01040bb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01040be:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01040c1:	e8 da fd ff ff       	call   f0103ea0 <stab_binsearch>

	if (lfun <= rfun) {
f01040c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01040c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040cc:	39 d0                	cmp    %edx,%eax
f01040ce:	7f 32                	jg     f0104102 <debuginfo_eip+0x134>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01040d0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01040d3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01040d6:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01040d9:	8b 39                	mov    (%ecx),%edi
f01040db:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01040de:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01040e1:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01040e4:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01040e7:	73 09                	jae    f01040f2 <debuginfo_eip+0x124>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01040e9:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01040ec:	03 7d bc             	add    -0x44(%ebp),%edi
f01040ef:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01040f2:	8b 49 08             	mov    0x8(%ecx),%ecx
f01040f5:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01040f8:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01040fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01040fd:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104100:	eb 0f                	jmp    f0104111 <debuginfo_eip+0x143>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104102:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104105:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104108:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010410b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010410e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104111:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104118:	00 
f0104119:	8b 43 08             	mov    0x8(%ebx),%eax
f010411c:	89 04 24             	mov    %eax,(%esp)
f010411f:	e8 86 0a 00 00       	call   f0104baa <strfind>
f0104124:	2b 43 08             	sub    0x8(%ebx),%eax
f0104127:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010412a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010412e:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0104135:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104138:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010413b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010413e:	e8 5d fd ff ff       	call   f0103ea0 <stab_binsearch>

	if(lline <= rline)
f0104143:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0104146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
f010414b:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010414e:	0f 8f e3 00 00 00    	jg     f0104237 <debuginfo_eip+0x269>
		info->eip_line = stabs[lline].n_desc;
f0104154:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104157:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010415a:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f010415f:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104162:	89 d0                	mov    %edx,%eax
f0104164:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104167:	89 7d b8             	mov    %edi,-0x48(%ebp)
f010416a:	39 fa                	cmp    %edi,%edx
f010416c:	7c 74                	jl     f01041e2 <debuginfo_eip+0x214>
	       && stabs[lline].n_type != N_SOL
f010416e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104171:	89 f7                	mov    %esi,%edi
f0104173:	8d 34 96             	lea    (%esi,%edx,4),%esi
f0104176:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f010417a:	80 f9 84             	cmp    $0x84,%cl
f010417d:	74 46                	je     f01041c5 <debuginfo_eip+0x1f7>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010417f:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0104183:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104186:	89 c7                	mov    %eax,%edi
f0104188:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f010418b:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010418e:	eb 1f                	jmp    f01041af <debuginfo_eip+0x1e1>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104190:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104193:	39 c3                	cmp    %eax,%ebx
f0104195:	7f 48                	jg     f01041df <debuginfo_eip+0x211>
	       && stabs[lline].n_type != N_SOL
f0104197:	89 d6                	mov    %edx,%esi
f0104199:	83 ea 0c             	sub    $0xc,%edx
f010419c:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f01041a0:	80 f9 84             	cmp    $0x84,%cl
f01041a3:	75 08                	jne    f01041ad <debuginfo_eip+0x1df>
f01041a5:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01041a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01041ab:	eb 18                	jmp    f01041c5 <debuginfo_eip+0x1f7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01041ad:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01041af:	80 f9 64             	cmp    $0x64,%cl
f01041b2:	75 dc                	jne    f0104190 <debuginfo_eip+0x1c2>
f01041b4:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f01041b8:	74 d6                	je     f0104190 <debuginfo_eip+0x1c2>
f01041ba:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01041bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01041c0:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01041c3:	7f 1d                	jg     f01041e2 <debuginfo_eip+0x214>
f01041c5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01041c8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01041cb:	8b 04 86             	mov    (%esi,%eax,4),%eax
f01041ce:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01041d1:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01041d4:	39 d0                	cmp    %edx,%eax
f01041d6:	73 0a                	jae    f01041e2 <debuginfo_eip+0x214>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01041d8:	03 45 bc             	add    -0x44(%ebp),%eax
f01041db:	89 03                	mov    %eax,(%ebx)
f01041dd:	eb 03                	jmp    f01041e2 <debuginfo_eip+0x214>
f01041df:	8b 5d b4             	mov    -0x4c(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01041e2:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01041e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01041e8:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01041eb:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01041f0:	3b 7d bc             	cmp    -0x44(%ebp),%edi
f01041f3:	7d 42                	jge    f0104237 <debuginfo_eip+0x269>
		for (lline = lfun + 1;
f01041f5:	8d 57 01             	lea    0x1(%edi),%edx
f01041f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01041fb:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f01041fe:	7e 37                	jle    f0104237 <debuginfo_eip+0x269>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104200:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0104203:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104206:	80 7c 8e 04 a0       	cmpb   $0xa0,0x4(%esi,%ecx,4)
f010420b:	75 2a                	jne    f0104237 <debuginfo_eip+0x269>
f010420d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104210:	8d 44 86 1c          	lea    0x1c(%esi,%eax,4),%eax
f0104214:	8b 4d bc             	mov    -0x44(%ebp),%ecx
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104217:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010421b:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010421e:	39 d1                	cmp    %edx,%ecx
f0104220:	7e 10                	jle    f0104232 <debuginfo_eip+0x264>
f0104222:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104225:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104229:	74 ec                	je     f0104217 <debuginfo_eip+0x249>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010422b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104230:	eb 05                	jmp    f0104237 <debuginfo_eip+0x269>
f0104232:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104237:	83 c4 5c             	add    $0x5c,%esp
f010423a:	5b                   	pop    %ebx
f010423b:	5e                   	pop    %esi
f010423c:	5f                   	pop    %edi
f010423d:	5d                   	pop    %ebp
f010423e:	c3                   	ret    
	...

f0104240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104240:	55                   	push   %ebp
f0104241:	89 e5                	mov    %esp,%ebp
f0104243:	57                   	push   %edi
f0104244:	56                   	push   %esi
f0104245:	53                   	push   %ebx
f0104246:	83 ec 3c             	sub    $0x3c,%esp
f0104249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010424c:	89 d7                	mov    %edx,%edi
f010424e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104251:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104254:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104257:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010425a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010425d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104260:	b8 00 00 00 00       	mov    $0x0,%eax
f0104265:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0104268:	72 11                	jb     f010427b <printnum+0x3b>
f010426a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010426d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104270:	76 09                	jbe    f010427b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104272:	83 eb 01             	sub    $0x1,%ebx
f0104275:	85 db                	test   %ebx,%ebx
f0104277:	7f 51                	jg     f01042ca <printnum+0x8a>
f0104279:	eb 5e                	jmp    f01042d9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010427b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010427f:	83 eb 01             	sub    $0x1,%ebx
f0104282:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104286:	8b 45 10             	mov    0x10(%ebp),%eax
f0104289:	89 44 24 08          	mov    %eax,0x8(%esp)
f010428d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0104291:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0104295:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010429c:	00 
f010429d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042a0:	89 04 24             	mov    %eax,(%esp)
f01042a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042aa:	e8 71 0b 00 00       	call   f0104e20 <__udivdi3>
f01042af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01042b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01042b7:	89 04 24             	mov    %eax,(%esp)
f01042ba:	89 54 24 04          	mov    %edx,0x4(%esp)
f01042be:	89 fa                	mov    %edi,%edx
f01042c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042c3:	e8 78 ff ff ff       	call   f0104240 <printnum>
f01042c8:	eb 0f                	jmp    f01042d9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01042ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01042ce:	89 34 24             	mov    %esi,(%esp)
f01042d1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01042d4:	83 eb 01             	sub    $0x1,%ebx
f01042d7:	75 f1                	jne    f01042ca <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01042d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01042dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01042e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01042e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01042ef:	00 
f01042f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042f3:	89 04 24             	mov    %eax,(%esp)
f01042f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042fd:	e8 4e 0c 00 00       	call   f0104f50 <__umoddi3>
f0104302:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104306:	0f be 80 01 68 10 f0 	movsbl -0xfef97ff(%eax),%eax
f010430d:	89 04 24             	mov    %eax,(%esp)
f0104310:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104313:	83 c4 3c             	add    $0x3c,%esp
f0104316:	5b                   	pop    %ebx
f0104317:	5e                   	pop    %esi
f0104318:	5f                   	pop    %edi
f0104319:	5d                   	pop    %ebp
f010431a:	c3                   	ret    

f010431b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010431b:	55                   	push   %ebp
f010431c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010431e:	83 fa 01             	cmp    $0x1,%edx
f0104321:	7e 0e                	jle    f0104331 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104323:	8b 10                	mov    (%eax),%edx
f0104325:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104328:	89 08                	mov    %ecx,(%eax)
f010432a:	8b 02                	mov    (%edx),%eax
f010432c:	8b 52 04             	mov    0x4(%edx),%edx
f010432f:	eb 22                	jmp    f0104353 <getuint+0x38>
	else if (lflag)
f0104331:	85 d2                	test   %edx,%edx
f0104333:	74 10                	je     f0104345 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104335:	8b 10                	mov    (%eax),%edx
f0104337:	8d 4a 04             	lea    0x4(%edx),%ecx
f010433a:	89 08                	mov    %ecx,(%eax)
f010433c:	8b 02                	mov    (%edx),%eax
f010433e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104343:	eb 0e                	jmp    f0104353 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104345:	8b 10                	mov    (%eax),%edx
f0104347:	8d 4a 04             	lea    0x4(%edx),%ecx
f010434a:	89 08                	mov    %ecx,(%eax)
f010434c:	8b 02                	mov    (%edx),%eax
f010434e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104353:	5d                   	pop    %ebp
f0104354:	c3                   	ret    

f0104355 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104355:	55                   	push   %ebp
f0104356:	89 e5                	mov    %esp,%ebp
f0104358:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010435b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010435f:	8b 10                	mov    (%eax),%edx
f0104361:	3b 50 04             	cmp    0x4(%eax),%edx
f0104364:	73 0a                	jae    f0104370 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104366:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104369:	88 0a                	mov    %cl,(%edx)
f010436b:	83 c2 01             	add    $0x1,%edx
f010436e:	89 10                	mov    %edx,(%eax)
}
f0104370:	5d                   	pop    %ebp
f0104371:	c3                   	ret    

f0104372 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104372:	55                   	push   %ebp
f0104373:	89 e5                	mov    %esp,%ebp
f0104375:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0104378:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010437b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010437f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104382:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104386:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104389:	89 44 24 04          	mov    %eax,0x4(%esp)
f010438d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104390:	89 04 24             	mov    %eax,(%esp)
f0104393:	e8 02 00 00 00       	call   f010439a <vprintfmt>
	va_end(ap);
}
f0104398:	c9                   	leave  
f0104399:	c3                   	ret    

f010439a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010439a:	55                   	push   %ebp
f010439b:	89 e5                	mov    %esp,%ebp
f010439d:	57                   	push   %edi
f010439e:	56                   	push   %esi
f010439f:	53                   	push   %ebx
f01043a0:	83 ec 5c             	sub    $0x5c,%esp
f01043a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043a6:	8b 75 10             	mov    0x10(%ebp),%esi
f01043a9:	eb 12                	jmp    f01043bd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01043ab:	85 c0                	test   %eax,%eax
f01043ad:	0f 84 e4 04 00 00    	je     f0104897 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
f01043b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01043b7:	89 04 24             	mov    %eax,(%esp)
f01043ba:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01043bd:	0f b6 06             	movzbl (%esi),%eax
f01043c0:	83 c6 01             	add    $0x1,%esi
f01043c3:	83 f8 25             	cmp    $0x25,%eax
f01043c6:	75 e3                	jne    f01043ab <vprintfmt+0x11>
f01043c8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f01043cc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f01043d3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01043d8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01043df:	b9 00 00 00 00       	mov    $0x0,%ecx
f01043e4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01043e7:	eb 2b                	jmp    f0104414 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01043e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01043ec:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f01043f0:	eb 22                	jmp    f0104414 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01043f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01043f5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f01043f9:	eb 19                	jmp    f0104414 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01043fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01043fe:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0104405:	eb 0d                	jmp    f0104414 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104407:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010440a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010440d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104414:	0f b6 06             	movzbl (%esi),%eax
f0104417:	0f b6 d0             	movzbl %al,%edx
f010441a:	8d 7e 01             	lea    0x1(%esi),%edi
f010441d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104420:	83 e8 23             	sub    $0x23,%eax
f0104423:	3c 55                	cmp    $0x55,%al
f0104425:	0f 87 46 04 00 00    	ja     f0104871 <vprintfmt+0x4d7>
f010442b:	0f b6 c0             	movzbl %al,%eax
f010442e:	ff 24 85 a4 68 10 f0 	jmp    *-0xfef975c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104435:	83 ea 30             	sub    $0x30,%edx
f0104438:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
f010443b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f010443f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104442:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0104445:	83 fa 09             	cmp    $0x9,%edx
f0104448:	77 4a                	ja     f0104494 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010444a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010444d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0104450:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0104453:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0104457:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010445a:	8d 50 d0             	lea    -0x30(%eax),%edx
f010445d:	83 fa 09             	cmp    $0x9,%edx
f0104460:	76 eb                	jbe    f010444d <vprintfmt+0xb3>
f0104462:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0104465:	eb 2d                	jmp    f0104494 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104467:	8b 45 14             	mov    0x14(%ebp),%eax
f010446a:	8d 50 04             	lea    0x4(%eax),%edx
f010446d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104470:	8b 00                	mov    (%eax),%eax
f0104472:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104475:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104478:	eb 1a                	jmp    f0104494 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010447a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f010447d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104481:	79 91                	jns    f0104414 <vprintfmt+0x7a>
f0104483:	e9 73 ff ff ff       	jmp    f01043fb <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104488:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010448b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
f0104492:	eb 80                	jmp    f0104414 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0104494:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104498:	0f 89 76 ff ff ff    	jns    f0104414 <vprintfmt+0x7a>
f010449e:	e9 64 ff ff ff       	jmp    f0104407 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01044a3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01044a9:	e9 66 ff ff ff       	jmp    f0104414 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01044ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01044b1:	8d 50 04             	lea    0x4(%eax),%edx
f01044b4:	89 55 14             	mov    %edx,0x14(%ebp)
f01044b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044bb:	8b 00                	mov    (%eax),%eax
f01044bd:	89 04 24             	mov    %eax,(%esp)
f01044c0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044c3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01044c6:	e9 f2 fe ff ff       	jmp    f01043bd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
f01044cb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01044cf:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
f01044d2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
f01044d6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
f01044d9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
f01044dd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
f01044e0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
f01044e3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
f01044e7:	8d 48 d0             	lea    -0x30(%eax),%ecx
f01044ea:	80 f9 09             	cmp    $0x9,%cl
f01044ed:	77 1d                	ja     f010450c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
f01044ef:	0f be c0             	movsbl %al,%eax
f01044f2:	6b c0 64             	imul   $0x64,%eax,%eax
f01044f5:	0f be d2             	movsbl %dl,%edx
f01044f8:	8d 14 92             	lea    (%edx,%edx,4),%edx
f01044fb:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
f0104502:	a3 78 c3 11 f0       	mov    %eax,0xf011c378
f0104507:	e9 b1 fe ff ff       	jmp    f01043bd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
f010450c:	c7 44 24 04 19 68 10 	movl   $0xf0106819,0x4(%esp)
f0104513:	f0 
f0104514:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104517:	89 04 24             	mov    %eax,(%esp)
f010451a:	e8 dc 05 00 00       	call   f0104afb <strcmp>
f010451f:	85 c0                	test   %eax,%eax
f0104521:	75 0f                	jne    f0104532 <vprintfmt+0x198>
f0104523:	c7 05 78 c3 11 f0 04 	movl   $0x4,0xf011c378
f010452a:	00 00 00 
f010452d:	e9 8b fe ff ff       	jmp    f01043bd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
f0104532:	c7 44 24 04 1d 68 10 	movl   $0xf010681d,0x4(%esp)
f0104539:	f0 
f010453a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010453d:	89 14 24             	mov    %edx,(%esp)
f0104540:	e8 b6 05 00 00       	call   f0104afb <strcmp>
f0104545:	85 c0                	test   %eax,%eax
f0104547:	75 0f                	jne    f0104558 <vprintfmt+0x1be>
f0104549:	c7 05 78 c3 11 f0 02 	movl   $0x2,0xf011c378
f0104550:	00 00 00 
f0104553:	e9 65 fe ff ff       	jmp    f01043bd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
f0104558:	c7 44 24 04 21 68 10 	movl   $0xf0106821,0x4(%esp)
f010455f:	f0 
f0104560:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0104563:	89 0c 24             	mov    %ecx,(%esp)
f0104566:	e8 90 05 00 00       	call   f0104afb <strcmp>
f010456b:	85 c0                	test   %eax,%eax
f010456d:	75 0f                	jne    f010457e <vprintfmt+0x1e4>
f010456f:	c7 05 78 c3 11 f0 01 	movl   $0x1,0xf011c378
f0104576:	00 00 00 
f0104579:	e9 3f fe ff ff       	jmp    f01043bd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
f010457e:	c7 44 24 04 25 68 10 	movl   $0xf0106825,0x4(%esp)
f0104585:	f0 
f0104586:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0104589:	89 3c 24             	mov    %edi,(%esp)
f010458c:	e8 6a 05 00 00       	call   f0104afb <strcmp>
f0104591:	85 c0                	test   %eax,%eax
f0104593:	75 0f                	jne    f01045a4 <vprintfmt+0x20a>
f0104595:	c7 05 78 c3 11 f0 06 	movl   $0x6,0xf011c378
f010459c:	00 00 00 
f010459f:	e9 19 fe ff ff       	jmp    f01043bd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
f01045a4:	c7 44 24 04 29 68 10 	movl   $0xf0106829,0x4(%esp)
f01045ab:	f0 
f01045ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045af:	89 04 24             	mov    %eax,(%esp)
f01045b2:	e8 44 05 00 00       	call   f0104afb <strcmp>
f01045b7:	85 c0                	test   %eax,%eax
f01045b9:	75 0f                	jne    f01045ca <vprintfmt+0x230>
f01045bb:	c7 05 78 c3 11 f0 07 	movl   $0x7,0xf011c378
f01045c2:	00 00 00 
f01045c5:	e9 f3 fd ff ff       	jmp    f01043bd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
f01045ca:	c7 44 24 04 2d 68 10 	movl   $0xf010682d,0x4(%esp)
f01045d1:	f0 
f01045d2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01045d5:	89 14 24             	mov    %edx,(%esp)
f01045d8:	e8 1e 05 00 00       	call   f0104afb <strcmp>
f01045dd:	83 f8 01             	cmp    $0x1,%eax
f01045e0:	19 c0                	sbb    %eax,%eax
f01045e2:	f7 d0                	not    %eax
f01045e4:	83 c0 08             	add    $0x8,%eax
f01045e7:	a3 78 c3 11 f0       	mov    %eax,0xf011c378
f01045ec:	e9 cc fd ff ff       	jmp    f01043bd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
f01045f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01045f4:	8d 50 04             	lea    0x4(%eax),%edx
f01045f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01045fa:	8b 00                	mov    (%eax),%eax
f01045fc:	89 c2                	mov    %eax,%edx
f01045fe:	c1 fa 1f             	sar    $0x1f,%edx
f0104601:	31 d0                	xor    %edx,%eax
f0104603:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104605:	83 f8 06             	cmp    $0x6,%eax
f0104608:	7f 0b                	jg     f0104615 <vprintfmt+0x27b>
f010460a:	8b 14 85 fc 69 10 f0 	mov    -0xfef9604(,%eax,4),%edx
f0104611:	85 d2                	test   %edx,%edx
f0104613:	75 23                	jne    f0104638 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0104615:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104619:	c7 44 24 08 31 68 10 	movl   $0xf0106831,0x8(%esp)
f0104620:	f0 
f0104621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104625:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104628:	89 3c 24             	mov    %edi,(%esp)
f010462b:	e8 42 fd ff ff       	call   f0104372 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104630:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104633:	e9 85 fd ff ff       	jmp    f01043bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0104638:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010463c:	c7 44 24 08 e5 60 10 	movl   $0xf01060e5,0x8(%esp)
f0104643:	f0 
f0104644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104648:	8b 7d 08             	mov    0x8(%ebp),%edi
f010464b:	89 3c 24             	mov    %edi,(%esp)
f010464e:	e8 1f fd ff ff       	call   f0104372 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104653:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104656:	e9 62 fd ff ff       	jmp    f01043bd <vprintfmt+0x23>
f010465b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010465e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104661:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104664:	8b 45 14             	mov    0x14(%ebp),%eax
f0104667:	8d 50 04             	lea    0x4(%eax),%edx
f010466a:	89 55 14             	mov    %edx,0x14(%ebp)
f010466d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010466f:	85 f6                	test   %esi,%esi
f0104671:	b8 12 68 10 f0       	mov    $0xf0106812,%eax
f0104676:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0104679:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f010467d:	7e 06                	jle    f0104685 <vprintfmt+0x2eb>
f010467f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0104683:	75 13                	jne    f0104698 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104685:	0f be 06             	movsbl (%esi),%eax
f0104688:	83 c6 01             	add    $0x1,%esi
f010468b:	85 c0                	test   %eax,%eax
f010468d:	0f 85 94 00 00 00    	jne    f0104727 <vprintfmt+0x38d>
f0104693:	e9 81 00 00 00       	jmp    f0104719 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104698:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010469c:	89 34 24             	mov    %esi,(%esp)
f010469f:	e8 67 03 00 00       	call   f0104a0b <strnlen>
f01046a4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01046a7:	29 c2                	sub    %eax,%edx
f01046a9:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01046ac:	85 d2                	test   %edx,%edx
f01046ae:	7e d5                	jle    f0104685 <vprintfmt+0x2eb>
					putch(padc, putdat);
f01046b0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f01046b4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01046b7:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01046ba:	89 d6                	mov    %edx,%esi
f01046bc:	89 cf                	mov    %ecx,%edi
f01046be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01046c2:	89 3c 24             	mov    %edi,(%esp)
f01046c5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01046c8:	83 ee 01             	sub    $0x1,%esi
f01046cb:	75 f1                	jne    f01046be <vprintfmt+0x324>
f01046cd:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01046d0:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01046d3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01046d6:	eb ad                	jmp    f0104685 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01046d8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01046dc:	74 1b                	je     f01046f9 <vprintfmt+0x35f>
f01046de:	8d 50 e0             	lea    -0x20(%eax),%edx
f01046e1:	83 fa 5e             	cmp    $0x5e,%edx
f01046e4:	76 13                	jbe    f01046f9 <vprintfmt+0x35f>
					putch('?', putdat);
f01046e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01046e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01046f4:	ff 55 08             	call   *0x8(%ebp)
f01046f7:	eb 0d                	jmp    f0104706 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
f01046f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01046fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104700:	89 04 24             	mov    %eax,(%esp)
f0104703:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104706:	83 eb 01             	sub    $0x1,%ebx
f0104709:	0f be 06             	movsbl (%esi),%eax
f010470c:	83 c6 01             	add    $0x1,%esi
f010470f:	85 c0                	test   %eax,%eax
f0104711:	75 1a                	jne    f010472d <vprintfmt+0x393>
f0104713:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104716:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104719:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010471c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104720:	7f 1c                	jg     f010473e <vprintfmt+0x3a4>
f0104722:	e9 96 fc ff ff       	jmp    f01043bd <vprintfmt+0x23>
f0104727:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010472a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010472d:	85 ff                	test   %edi,%edi
f010472f:	78 a7                	js     f01046d8 <vprintfmt+0x33e>
f0104731:	83 ef 01             	sub    $0x1,%edi
f0104734:	79 a2                	jns    f01046d8 <vprintfmt+0x33e>
f0104736:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0104739:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010473c:	eb db                	jmp    f0104719 <vprintfmt+0x37f>
f010473e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104741:	89 de                	mov    %ebx,%esi
f0104743:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104746:	89 74 24 04          	mov    %esi,0x4(%esp)
f010474a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104751:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104753:	83 eb 01             	sub    $0x1,%ebx
f0104756:	75 ee                	jne    f0104746 <vprintfmt+0x3ac>
f0104758:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010475a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010475d:	e9 5b fc ff ff       	jmp    f01043bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104762:	83 f9 01             	cmp    $0x1,%ecx
f0104765:	7e 10                	jle    f0104777 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
f0104767:	8b 45 14             	mov    0x14(%ebp),%eax
f010476a:	8d 50 08             	lea    0x8(%eax),%edx
f010476d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104770:	8b 30                	mov    (%eax),%esi
f0104772:	8b 78 04             	mov    0x4(%eax),%edi
f0104775:	eb 26                	jmp    f010479d <vprintfmt+0x403>
	else if (lflag)
f0104777:	85 c9                	test   %ecx,%ecx
f0104779:	74 12                	je     f010478d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
f010477b:	8b 45 14             	mov    0x14(%ebp),%eax
f010477e:	8d 50 04             	lea    0x4(%eax),%edx
f0104781:	89 55 14             	mov    %edx,0x14(%ebp)
f0104784:	8b 30                	mov    (%eax),%esi
f0104786:	89 f7                	mov    %esi,%edi
f0104788:	c1 ff 1f             	sar    $0x1f,%edi
f010478b:	eb 10                	jmp    f010479d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
f010478d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104790:	8d 50 04             	lea    0x4(%eax),%edx
f0104793:	89 55 14             	mov    %edx,0x14(%ebp)
f0104796:	8b 30                	mov    (%eax),%esi
f0104798:	89 f7                	mov    %esi,%edi
f010479a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010479d:	85 ff                	test   %edi,%edi
f010479f:	78 0e                	js     f01047af <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01047a1:	89 f0                	mov    %esi,%eax
f01047a3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01047a5:	be 0a 00 00 00       	mov    $0xa,%esi
f01047aa:	e9 84 00 00 00       	jmp    f0104833 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01047af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047b3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01047ba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01047bd:	89 f0                	mov    %esi,%eax
f01047bf:	89 fa                	mov    %edi,%edx
f01047c1:	f7 d8                	neg    %eax
f01047c3:	83 d2 00             	adc    $0x0,%edx
f01047c6:	f7 da                	neg    %edx
			}
			base = 10;
f01047c8:	be 0a 00 00 00       	mov    $0xa,%esi
f01047cd:	eb 64                	jmp    f0104833 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01047cf:	89 ca                	mov    %ecx,%edx
f01047d1:	8d 45 14             	lea    0x14(%ebp),%eax
f01047d4:	e8 42 fb ff ff       	call   f010431b <getuint>
			base = 10;
f01047d9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f01047de:	eb 53                	jmp    f0104833 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01047e0:	89 ca                	mov    %ecx,%edx
f01047e2:	8d 45 14             	lea    0x14(%ebp),%eax
f01047e5:	e8 31 fb ff ff       	call   f010431b <getuint>
    			base = 8;
f01047ea:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f01047ef:	eb 42                	jmp    f0104833 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
f01047f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047f5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01047fc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01047ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104803:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010480a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010480d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104810:	8d 50 04             	lea    0x4(%eax),%edx
f0104813:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104816:	8b 00                	mov    (%eax),%eax
f0104818:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010481d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0104822:	eb 0f                	jmp    f0104833 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104824:	89 ca                	mov    %ecx,%edx
f0104826:	8d 45 14             	lea    0x14(%ebp),%eax
f0104829:	e8 ed fa ff ff       	call   f010431b <getuint>
			base = 16;
f010482e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104833:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
f0104837:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010483b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010483e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104842:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104846:	89 04 24             	mov    %eax,(%esp)
f0104849:	89 54 24 04          	mov    %edx,0x4(%esp)
f010484d:	89 da                	mov    %ebx,%edx
f010484f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104852:	e8 e9 f9 ff ff       	call   f0104240 <printnum>
			break;
f0104857:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010485a:	e9 5e fb ff ff       	jmp    f01043bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010485f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104863:	89 14 24             	mov    %edx,(%esp)
f0104866:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104869:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010486c:	e9 4c fb ff ff       	jmp    f01043bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104871:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104875:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010487c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010487f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104883:	0f 84 34 fb ff ff    	je     f01043bd <vprintfmt+0x23>
f0104889:	83 ee 01             	sub    $0x1,%esi
f010488c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104890:	75 f7                	jne    f0104889 <vprintfmt+0x4ef>
f0104892:	e9 26 fb ff ff       	jmp    f01043bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0104897:	83 c4 5c             	add    $0x5c,%esp
f010489a:	5b                   	pop    %ebx
f010489b:	5e                   	pop    %esi
f010489c:	5f                   	pop    %edi
f010489d:	5d                   	pop    %ebp
f010489e:	c3                   	ret    

f010489f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010489f:	55                   	push   %ebp
f01048a0:	89 e5                	mov    %esp,%ebp
f01048a2:	83 ec 28             	sub    $0x28,%esp
f01048a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01048a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01048ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01048ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01048b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01048b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01048bc:	85 c0                	test   %eax,%eax
f01048be:	74 30                	je     f01048f0 <vsnprintf+0x51>
f01048c0:	85 d2                	test   %edx,%edx
f01048c2:	7e 2c                	jle    f01048f0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01048c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01048c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048cb:	8b 45 10             	mov    0x10(%ebp),%eax
f01048ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01048d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048d9:	c7 04 24 55 43 10 f0 	movl   $0xf0104355,(%esp)
f01048e0:	e8 b5 fa ff ff       	call   f010439a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01048e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01048e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01048eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048ee:	eb 05                	jmp    f01048f5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01048f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01048f5:	c9                   	leave  
f01048f6:	c3                   	ret    

f01048f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01048f7:	55                   	push   %ebp
f01048f8:	89 e5                	mov    %esp,%ebp
f01048fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01048fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104900:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104904:	8b 45 10             	mov    0x10(%ebp),%eax
f0104907:	89 44 24 08          	mov    %eax,0x8(%esp)
f010490b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010490e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104912:	8b 45 08             	mov    0x8(%ebp),%eax
f0104915:	89 04 24             	mov    %eax,(%esp)
f0104918:	e8 82 ff ff ff       	call   f010489f <vsnprintf>
	va_end(ap);

	return rc;
}
f010491d:	c9                   	leave  
f010491e:	c3                   	ret    
	...

f0104920 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104920:	55                   	push   %ebp
f0104921:	89 e5                	mov    %esp,%ebp
f0104923:	57                   	push   %edi
f0104924:	56                   	push   %esi
f0104925:	53                   	push   %ebx
f0104926:	83 ec 1c             	sub    $0x1c,%esp
f0104929:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010492c:	85 c0                	test   %eax,%eax
f010492e:	74 10                	je     f0104940 <readline+0x20>
		cprintf("%s", prompt);
f0104930:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104934:	c7 04 24 e5 60 10 f0 	movl   $0xf01060e5,(%esp)
f010493b:	e8 3a f1 ff ff       	call   f0103a7a <cprintf>

	i = 0;
	echoing = iscons(0);
f0104940:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104947:	e8 f5 bc ff ff       	call   f0100641 <iscons>
f010494c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010494e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104953:	e8 d8 bc ff ff       	call   f0100630 <getchar>
f0104958:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010495a:	85 c0                	test   %eax,%eax
f010495c:	79 17                	jns    f0104975 <readline+0x55>
			cprintf("read error: %e\n", c);
f010495e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104962:	c7 04 24 18 6a 10 f0 	movl   $0xf0106a18,(%esp)
f0104969:	e8 0c f1 ff ff       	call   f0103a7a <cprintf>
			return NULL;
f010496e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104973:	eb 6d                	jmp    f01049e2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104975:	83 f8 08             	cmp    $0x8,%eax
f0104978:	74 05                	je     f010497f <readline+0x5f>
f010497a:	83 f8 7f             	cmp    $0x7f,%eax
f010497d:	75 19                	jne    f0104998 <readline+0x78>
f010497f:	85 f6                	test   %esi,%esi
f0104981:	7e 15                	jle    f0104998 <readline+0x78>
			if (echoing)
f0104983:	85 ff                	test   %edi,%edi
f0104985:	74 0c                	je     f0104993 <readline+0x73>
				cputchar('\b');
f0104987:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010498e:	e8 8d bc ff ff       	call   f0100620 <cputchar>
			i--;
f0104993:	83 ee 01             	sub    $0x1,%esi
f0104996:	eb bb                	jmp    f0104953 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104998:	83 fb 1f             	cmp    $0x1f,%ebx
f010499b:	7e 1f                	jle    f01049bc <readline+0x9c>
f010499d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01049a3:	7f 17                	jg     f01049bc <readline+0x9c>
			if (echoing)
f01049a5:	85 ff                	test   %edi,%edi
f01049a7:	74 08                	je     f01049b1 <readline+0x91>
				cputchar(c);
f01049a9:	89 1c 24             	mov    %ebx,(%esp)
f01049ac:	e8 6f bc ff ff       	call   f0100620 <cputchar>
			buf[i++] = c;
f01049b1:	88 9e a0 f9 17 f0    	mov    %bl,-0xfe80660(%esi)
f01049b7:	83 c6 01             	add    $0x1,%esi
f01049ba:	eb 97                	jmp    f0104953 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01049bc:	83 fb 0a             	cmp    $0xa,%ebx
f01049bf:	74 05                	je     f01049c6 <readline+0xa6>
f01049c1:	83 fb 0d             	cmp    $0xd,%ebx
f01049c4:	75 8d                	jne    f0104953 <readline+0x33>
			if (echoing)
f01049c6:	85 ff                	test   %edi,%edi
f01049c8:	74 0c                	je     f01049d6 <readline+0xb6>
				cputchar('\n');
f01049ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01049d1:	e8 4a bc ff ff       	call   f0100620 <cputchar>
			buf[i] = 0;
f01049d6:	c6 86 a0 f9 17 f0 00 	movb   $0x0,-0xfe80660(%esi)
			return buf;
f01049dd:	b8 a0 f9 17 f0       	mov    $0xf017f9a0,%eax
		}
	}
}
f01049e2:	83 c4 1c             	add    $0x1c,%esp
f01049e5:	5b                   	pop    %ebx
f01049e6:	5e                   	pop    %esi
f01049e7:	5f                   	pop    %edi
f01049e8:	5d                   	pop    %ebp
f01049e9:	c3                   	ret    
f01049ea:	00 00                	add    %al,(%eax)
f01049ec:	00 00                	add    %al,(%eax)
	...

f01049f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01049f0:	55                   	push   %ebp
f01049f1:	89 e5                	mov    %esp,%ebp
f01049f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01049f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01049fb:	80 3a 00             	cmpb   $0x0,(%edx)
f01049fe:	74 09                	je     f0104a09 <strlen+0x19>
		n++;
f0104a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104a07:	75 f7                	jne    f0104a00 <strlen+0x10>
		n++;
	return n;
}
f0104a09:	5d                   	pop    %ebp
f0104a0a:	c3                   	ret    

f0104a0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104a0b:	55                   	push   %ebp
f0104a0c:	89 e5                	mov    %esp,%ebp
f0104a0e:	53                   	push   %ebx
f0104a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104a15:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a1a:	85 c9                	test   %ecx,%ecx
f0104a1c:	74 1a                	je     f0104a38 <strnlen+0x2d>
f0104a1e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104a21:	74 15                	je     f0104a38 <strnlen+0x2d>
f0104a23:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0104a28:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104a2a:	39 ca                	cmp    %ecx,%edx
f0104a2c:	74 0a                	je     f0104a38 <strnlen+0x2d>
f0104a2e:	83 c2 01             	add    $0x1,%edx
f0104a31:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104a36:	75 f0                	jne    f0104a28 <strnlen+0x1d>
		n++;
	return n;
}
f0104a38:	5b                   	pop    %ebx
f0104a39:	5d                   	pop    %ebp
f0104a3a:	c3                   	ret    

f0104a3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104a3b:	55                   	push   %ebp
f0104a3c:	89 e5                	mov    %esp,%ebp
f0104a3e:	53                   	push   %ebx
f0104a3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104a45:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a4a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104a4e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104a51:	83 c2 01             	add    $0x1,%edx
f0104a54:	84 c9                	test   %cl,%cl
f0104a56:	75 f2                	jne    f0104a4a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104a58:	5b                   	pop    %ebx
f0104a59:	5d                   	pop    %ebp
f0104a5a:	c3                   	ret    

f0104a5b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104a5b:	55                   	push   %ebp
f0104a5c:	89 e5                	mov    %esp,%ebp
f0104a5e:	53                   	push   %ebx
f0104a5f:	83 ec 08             	sub    $0x8,%esp
f0104a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104a65:	89 1c 24             	mov    %ebx,(%esp)
f0104a68:	e8 83 ff ff ff       	call   f01049f0 <strlen>
	strcpy(dst + len, src);
f0104a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a70:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a74:	01 d8                	add    %ebx,%eax
f0104a76:	89 04 24             	mov    %eax,(%esp)
f0104a79:	e8 bd ff ff ff       	call   f0104a3b <strcpy>
	return dst;
}
f0104a7e:	89 d8                	mov    %ebx,%eax
f0104a80:	83 c4 08             	add    $0x8,%esp
f0104a83:	5b                   	pop    %ebx
f0104a84:	5d                   	pop    %ebp
f0104a85:	c3                   	ret    

f0104a86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104a86:	55                   	push   %ebp
f0104a87:	89 e5                	mov    %esp,%ebp
f0104a89:	56                   	push   %esi
f0104a8a:	53                   	push   %ebx
f0104a8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a91:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104a94:	85 f6                	test   %esi,%esi
f0104a96:	74 18                	je     f0104ab0 <strncpy+0x2a>
f0104a98:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104a9d:	0f b6 1a             	movzbl (%edx),%ebx
f0104aa0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104aa3:	80 3a 01             	cmpb   $0x1,(%edx)
f0104aa6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104aa9:	83 c1 01             	add    $0x1,%ecx
f0104aac:	39 f1                	cmp    %esi,%ecx
f0104aae:	75 ed                	jne    f0104a9d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104ab0:	5b                   	pop    %ebx
f0104ab1:	5e                   	pop    %esi
f0104ab2:	5d                   	pop    %ebp
f0104ab3:	c3                   	ret    

f0104ab4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104ab4:	55                   	push   %ebp
f0104ab5:	89 e5                	mov    %esp,%ebp
f0104ab7:	57                   	push   %edi
f0104ab8:	56                   	push   %esi
f0104ab9:	53                   	push   %ebx
f0104aba:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104abd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ac0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104ac3:	89 f8                	mov    %edi,%eax
f0104ac5:	85 f6                	test   %esi,%esi
f0104ac7:	74 2b                	je     f0104af4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0104ac9:	83 fe 01             	cmp    $0x1,%esi
f0104acc:	74 23                	je     f0104af1 <strlcpy+0x3d>
f0104ace:	0f b6 0b             	movzbl (%ebx),%ecx
f0104ad1:	84 c9                	test   %cl,%cl
f0104ad3:	74 1c                	je     f0104af1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0104ad5:	83 ee 02             	sub    $0x2,%esi
f0104ad8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104add:	88 08                	mov    %cl,(%eax)
f0104adf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104ae2:	39 f2                	cmp    %esi,%edx
f0104ae4:	74 0b                	je     f0104af1 <strlcpy+0x3d>
f0104ae6:	83 c2 01             	add    $0x1,%edx
f0104ae9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104aed:	84 c9                	test   %cl,%cl
f0104aef:	75 ec                	jne    f0104add <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0104af1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104af4:	29 f8                	sub    %edi,%eax
}
f0104af6:	5b                   	pop    %ebx
f0104af7:	5e                   	pop    %esi
f0104af8:	5f                   	pop    %edi
f0104af9:	5d                   	pop    %ebp
f0104afa:	c3                   	ret    

f0104afb <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104afb:	55                   	push   %ebp
f0104afc:	89 e5                	mov    %esp,%ebp
f0104afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104b04:	0f b6 01             	movzbl (%ecx),%eax
f0104b07:	84 c0                	test   %al,%al
f0104b09:	74 16                	je     f0104b21 <strcmp+0x26>
f0104b0b:	3a 02                	cmp    (%edx),%al
f0104b0d:	75 12                	jne    f0104b21 <strcmp+0x26>
		p++, q++;
f0104b0f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104b12:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0104b16:	84 c0                	test   %al,%al
f0104b18:	74 07                	je     f0104b21 <strcmp+0x26>
f0104b1a:	83 c1 01             	add    $0x1,%ecx
f0104b1d:	3a 02                	cmp    (%edx),%al
f0104b1f:	74 ee                	je     f0104b0f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104b21:	0f b6 c0             	movzbl %al,%eax
f0104b24:	0f b6 12             	movzbl (%edx),%edx
f0104b27:	29 d0                	sub    %edx,%eax
}
f0104b29:	5d                   	pop    %ebp
f0104b2a:	c3                   	ret    

f0104b2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104b2b:	55                   	push   %ebp
f0104b2c:	89 e5                	mov    %esp,%ebp
f0104b2e:	53                   	push   %ebx
f0104b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b35:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104b38:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104b3d:	85 d2                	test   %edx,%edx
f0104b3f:	74 28                	je     f0104b69 <strncmp+0x3e>
f0104b41:	0f b6 01             	movzbl (%ecx),%eax
f0104b44:	84 c0                	test   %al,%al
f0104b46:	74 24                	je     f0104b6c <strncmp+0x41>
f0104b48:	3a 03                	cmp    (%ebx),%al
f0104b4a:	75 20                	jne    f0104b6c <strncmp+0x41>
f0104b4c:	83 ea 01             	sub    $0x1,%edx
f0104b4f:	74 13                	je     f0104b64 <strncmp+0x39>
		n--, p++, q++;
f0104b51:	83 c1 01             	add    $0x1,%ecx
f0104b54:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104b57:	0f b6 01             	movzbl (%ecx),%eax
f0104b5a:	84 c0                	test   %al,%al
f0104b5c:	74 0e                	je     f0104b6c <strncmp+0x41>
f0104b5e:	3a 03                	cmp    (%ebx),%al
f0104b60:	74 ea                	je     f0104b4c <strncmp+0x21>
f0104b62:	eb 08                	jmp    f0104b6c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104b64:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104b69:	5b                   	pop    %ebx
f0104b6a:	5d                   	pop    %ebp
f0104b6b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104b6c:	0f b6 01             	movzbl (%ecx),%eax
f0104b6f:	0f b6 13             	movzbl (%ebx),%edx
f0104b72:	29 d0                	sub    %edx,%eax
f0104b74:	eb f3                	jmp    f0104b69 <strncmp+0x3e>

f0104b76 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104b76:	55                   	push   %ebp
f0104b77:	89 e5                	mov    %esp,%ebp
f0104b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b7c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104b80:	0f b6 10             	movzbl (%eax),%edx
f0104b83:	84 d2                	test   %dl,%dl
f0104b85:	74 1c                	je     f0104ba3 <strchr+0x2d>
		if (*s == c)
f0104b87:	38 ca                	cmp    %cl,%dl
f0104b89:	75 09                	jne    f0104b94 <strchr+0x1e>
f0104b8b:	eb 1b                	jmp    f0104ba8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104b8d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0104b90:	38 ca                	cmp    %cl,%dl
f0104b92:	74 14                	je     f0104ba8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104b94:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0104b98:	84 d2                	test   %dl,%dl
f0104b9a:	75 f1                	jne    f0104b8d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0104b9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ba1:	eb 05                	jmp    f0104ba8 <strchr+0x32>
f0104ba3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ba8:	5d                   	pop    %ebp
f0104ba9:	c3                   	ret    

f0104baa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104baa:	55                   	push   %ebp
f0104bab:	89 e5                	mov    %esp,%ebp
f0104bad:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104bb4:	0f b6 10             	movzbl (%eax),%edx
f0104bb7:	84 d2                	test   %dl,%dl
f0104bb9:	74 14                	je     f0104bcf <strfind+0x25>
		if (*s == c)
f0104bbb:	38 ca                	cmp    %cl,%dl
f0104bbd:	75 06                	jne    f0104bc5 <strfind+0x1b>
f0104bbf:	eb 0e                	jmp    f0104bcf <strfind+0x25>
f0104bc1:	38 ca                	cmp    %cl,%dl
f0104bc3:	74 0a                	je     f0104bcf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104bc5:	83 c0 01             	add    $0x1,%eax
f0104bc8:	0f b6 10             	movzbl (%eax),%edx
f0104bcb:	84 d2                	test   %dl,%dl
f0104bcd:	75 f2                	jne    f0104bc1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104bcf:	5d                   	pop    %ebp
f0104bd0:	c3                   	ret    

f0104bd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104bd1:	55                   	push   %ebp
f0104bd2:	89 e5                	mov    %esp,%ebp
f0104bd4:	83 ec 0c             	sub    $0xc,%esp
f0104bd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104bda:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104bdd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104be0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104be3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104be6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104be9:	85 c9                	test   %ecx,%ecx
f0104beb:	74 30                	je     f0104c1d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104bed:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104bf3:	75 25                	jne    f0104c1a <memset+0x49>
f0104bf5:	f6 c1 03             	test   $0x3,%cl
f0104bf8:	75 20                	jne    f0104c1a <memset+0x49>
		c &= 0xFF;
f0104bfa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104bfd:	89 d3                	mov    %edx,%ebx
f0104bff:	c1 e3 08             	shl    $0x8,%ebx
f0104c02:	89 d6                	mov    %edx,%esi
f0104c04:	c1 e6 18             	shl    $0x18,%esi
f0104c07:	89 d0                	mov    %edx,%eax
f0104c09:	c1 e0 10             	shl    $0x10,%eax
f0104c0c:	09 f0                	or     %esi,%eax
f0104c0e:	09 d0                	or     %edx,%eax
f0104c10:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104c12:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104c15:	fc                   	cld    
f0104c16:	f3 ab                	rep stos %eax,%es:(%edi)
f0104c18:	eb 03                	jmp    f0104c1d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104c1a:	fc                   	cld    
f0104c1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104c1d:	89 f8                	mov    %edi,%eax
f0104c1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104c22:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104c25:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104c28:	89 ec                	mov    %ebp,%esp
f0104c2a:	5d                   	pop    %ebp
f0104c2b:	c3                   	ret    

f0104c2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104c2c:	55                   	push   %ebp
f0104c2d:	89 e5                	mov    %esp,%ebp
f0104c2f:	83 ec 08             	sub    $0x8,%esp
f0104c32:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104c35:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104c38:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c3b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104c41:	39 c6                	cmp    %eax,%esi
f0104c43:	73 36                	jae    f0104c7b <memmove+0x4f>
f0104c45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104c48:	39 d0                	cmp    %edx,%eax
f0104c4a:	73 2f                	jae    f0104c7b <memmove+0x4f>
		s += n;
		d += n;
f0104c4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104c4f:	f6 c2 03             	test   $0x3,%dl
f0104c52:	75 1b                	jne    f0104c6f <memmove+0x43>
f0104c54:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c5a:	75 13                	jne    f0104c6f <memmove+0x43>
f0104c5c:	f6 c1 03             	test   $0x3,%cl
f0104c5f:	75 0e                	jne    f0104c6f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104c61:	83 ef 04             	sub    $0x4,%edi
f0104c64:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104c67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104c6a:	fd                   	std    
f0104c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104c6d:	eb 09                	jmp    f0104c78 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104c6f:	83 ef 01             	sub    $0x1,%edi
f0104c72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104c75:	fd                   	std    
f0104c76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104c78:	fc                   	cld    
f0104c79:	eb 20                	jmp    f0104c9b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104c7b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104c81:	75 13                	jne    f0104c96 <memmove+0x6a>
f0104c83:	a8 03                	test   $0x3,%al
f0104c85:	75 0f                	jne    f0104c96 <memmove+0x6a>
f0104c87:	f6 c1 03             	test   $0x3,%cl
f0104c8a:	75 0a                	jne    f0104c96 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104c8c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104c8f:	89 c7                	mov    %eax,%edi
f0104c91:	fc                   	cld    
f0104c92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104c94:	eb 05                	jmp    f0104c9b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104c96:	89 c7                	mov    %eax,%edi
f0104c98:	fc                   	cld    
f0104c99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104c9b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104c9e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104ca1:	89 ec                	mov    %ebp,%esp
f0104ca3:	5d                   	pop    %ebp
f0104ca4:	c3                   	ret    

f0104ca5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104ca5:	55                   	push   %ebp
f0104ca6:	89 e5                	mov    %esp,%ebp
f0104ca8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104cab:	8b 45 10             	mov    0x10(%ebp),%eax
f0104cae:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cbc:	89 04 24             	mov    %eax,(%esp)
f0104cbf:	e8 68 ff ff ff       	call   f0104c2c <memmove>
}
f0104cc4:	c9                   	leave  
f0104cc5:	c3                   	ret    

f0104cc6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104cc6:	55                   	push   %ebp
f0104cc7:	89 e5                	mov    %esp,%ebp
f0104cc9:	57                   	push   %edi
f0104cca:	56                   	push   %esi
f0104ccb:	53                   	push   %ebx
f0104ccc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104ccf:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cd2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104cda:	85 ff                	test   %edi,%edi
f0104cdc:	74 37                	je     f0104d15 <memcmp+0x4f>
		if (*s1 != *s2)
f0104cde:	0f b6 03             	movzbl (%ebx),%eax
f0104ce1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104ce4:	83 ef 01             	sub    $0x1,%edi
f0104ce7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0104cec:	38 c8                	cmp    %cl,%al
f0104cee:	74 1c                	je     f0104d0c <memcmp+0x46>
f0104cf0:	eb 10                	jmp    f0104d02 <memcmp+0x3c>
f0104cf2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104cf7:	83 c2 01             	add    $0x1,%edx
f0104cfa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104cfe:	38 c8                	cmp    %cl,%al
f0104d00:	74 0a                	je     f0104d0c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0104d02:	0f b6 c0             	movzbl %al,%eax
f0104d05:	0f b6 c9             	movzbl %cl,%ecx
f0104d08:	29 c8                	sub    %ecx,%eax
f0104d0a:	eb 09                	jmp    f0104d15 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d0c:	39 fa                	cmp    %edi,%edx
f0104d0e:	75 e2                	jne    f0104cf2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104d10:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d15:	5b                   	pop    %ebx
f0104d16:	5e                   	pop    %esi
f0104d17:	5f                   	pop    %edi
f0104d18:	5d                   	pop    %ebp
f0104d19:	c3                   	ret    

f0104d1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d1a:	55                   	push   %ebp
f0104d1b:	89 e5                	mov    %esp,%ebp
f0104d1d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104d20:	89 c2                	mov    %eax,%edx
f0104d22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104d25:	39 d0                	cmp    %edx,%eax
f0104d27:	73 19                	jae    f0104d42 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d29:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104d2d:	38 08                	cmp    %cl,(%eax)
f0104d2f:	75 06                	jne    f0104d37 <memfind+0x1d>
f0104d31:	eb 0f                	jmp    f0104d42 <memfind+0x28>
f0104d33:	38 08                	cmp    %cl,(%eax)
f0104d35:	74 0b                	je     f0104d42 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d37:	83 c0 01             	add    $0x1,%eax
f0104d3a:	39 d0                	cmp    %edx,%eax
f0104d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d40:	75 f1                	jne    f0104d33 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104d42:	5d                   	pop    %ebp
f0104d43:	c3                   	ret    

f0104d44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104d44:	55                   	push   %ebp
f0104d45:	89 e5                	mov    %esp,%ebp
f0104d47:	57                   	push   %edi
f0104d48:	56                   	push   %esi
f0104d49:	53                   	push   %ebx
f0104d4a:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d50:	0f b6 02             	movzbl (%edx),%eax
f0104d53:	3c 20                	cmp    $0x20,%al
f0104d55:	74 04                	je     f0104d5b <strtol+0x17>
f0104d57:	3c 09                	cmp    $0x9,%al
f0104d59:	75 0e                	jne    f0104d69 <strtol+0x25>
		s++;
f0104d5b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d5e:	0f b6 02             	movzbl (%edx),%eax
f0104d61:	3c 20                	cmp    $0x20,%al
f0104d63:	74 f6                	je     f0104d5b <strtol+0x17>
f0104d65:	3c 09                	cmp    $0x9,%al
f0104d67:	74 f2                	je     f0104d5b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104d69:	3c 2b                	cmp    $0x2b,%al
f0104d6b:	75 0a                	jne    f0104d77 <strtol+0x33>
		s++;
f0104d6d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104d70:	bf 00 00 00 00       	mov    $0x0,%edi
f0104d75:	eb 10                	jmp    f0104d87 <strtol+0x43>
f0104d77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104d7c:	3c 2d                	cmp    $0x2d,%al
f0104d7e:	75 07                	jne    f0104d87 <strtol+0x43>
		s++, neg = 1;
f0104d80:	83 c2 01             	add    $0x1,%edx
f0104d83:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104d87:	85 db                	test   %ebx,%ebx
f0104d89:	0f 94 c0             	sete   %al
f0104d8c:	74 05                	je     f0104d93 <strtol+0x4f>
f0104d8e:	83 fb 10             	cmp    $0x10,%ebx
f0104d91:	75 15                	jne    f0104da8 <strtol+0x64>
f0104d93:	80 3a 30             	cmpb   $0x30,(%edx)
f0104d96:	75 10                	jne    f0104da8 <strtol+0x64>
f0104d98:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104d9c:	75 0a                	jne    f0104da8 <strtol+0x64>
		s += 2, base = 16;
f0104d9e:	83 c2 02             	add    $0x2,%edx
f0104da1:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104da6:	eb 13                	jmp    f0104dbb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0104da8:	84 c0                	test   %al,%al
f0104daa:	74 0f                	je     f0104dbb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104dac:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104db1:	80 3a 30             	cmpb   $0x30,(%edx)
f0104db4:	75 05                	jne    f0104dbb <strtol+0x77>
		s++, base = 8;
f0104db6:	83 c2 01             	add    $0x1,%edx
f0104db9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104dbb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dc0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104dc2:	0f b6 0a             	movzbl (%edx),%ecx
f0104dc5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104dc8:	80 fb 09             	cmp    $0x9,%bl
f0104dcb:	77 08                	ja     f0104dd5 <strtol+0x91>
			dig = *s - '0';
f0104dcd:	0f be c9             	movsbl %cl,%ecx
f0104dd0:	83 e9 30             	sub    $0x30,%ecx
f0104dd3:	eb 1e                	jmp    f0104df3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0104dd5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104dd8:	80 fb 19             	cmp    $0x19,%bl
f0104ddb:	77 08                	ja     f0104de5 <strtol+0xa1>
			dig = *s - 'a' + 10;
f0104ddd:	0f be c9             	movsbl %cl,%ecx
f0104de0:	83 e9 57             	sub    $0x57,%ecx
f0104de3:	eb 0e                	jmp    f0104df3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0104de5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104de8:	80 fb 19             	cmp    $0x19,%bl
f0104deb:	77 14                	ja     f0104e01 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104ded:	0f be c9             	movsbl %cl,%ecx
f0104df0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104df3:	39 f1                	cmp    %esi,%ecx
f0104df5:	7d 0e                	jge    f0104e05 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104df7:	83 c2 01             	add    $0x1,%edx
f0104dfa:	0f af c6             	imul   %esi,%eax
f0104dfd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104dff:	eb c1                	jmp    f0104dc2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104e01:	89 c1                	mov    %eax,%ecx
f0104e03:	eb 02                	jmp    f0104e07 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104e05:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104e07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e0b:	74 05                	je     f0104e12 <strtol+0xce>
		*endptr = (char *) s;
f0104e0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e10:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104e12:	89 ca                	mov    %ecx,%edx
f0104e14:	f7 da                	neg    %edx
f0104e16:	85 ff                	test   %edi,%edi
f0104e18:	0f 45 c2             	cmovne %edx,%eax
}
f0104e1b:	5b                   	pop    %ebx
f0104e1c:	5e                   	pop    %esi
f0104e1d:	5f                   	pop    %edi
f0104e1e:	5d                   	pop    %ebp
f0104e1f:	c3                   	ret    

f0104e20 <__udivdi3>:
f0104e20:	83 ec 1c             	sub    $0x1c,%esp
f0104e23:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104e27:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0104e2b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0104e2f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104e33:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104e37:	8b 74 24 24          	mov    0x24(%esp),%esi
f0104e3b:	85 ff                	test   %edi,%edi
f0104e3d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104e41:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e45:	89 cd                	mov    %ecx,%ebp
f0104e47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e4b:	75 33                	jne    f0104e80 <__udivdi3+0x60>
f0104e4d:	39 f1                	cmp    %esi,%ecx
f0104e4f:	77 57                	ja     f0104ea8 <__udivdi3+0x88>
f0104e51:	85 c9                	test   %ecx,%ecx
f0104e53:	75 0b                	jne    f0104e60 <__udivdi3+0x40>
f0104e55:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e5a:	31 d2                	xor    %edx,%edx
f0104e5c:	f7 f1                	div    %ecx
f0104e5e:	89 c1                	mov    %eax,%ecx
f0104e60:	89 f0                	mov    %esi,%eax
f0104e62:	31 d2                	xor    %edx,%edx
f0104e64:	f7 f1                	div    %ecx
f0104e66:	89 c6                	mov    %eax,%esi
f0104e68:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104e6c:	f7 f1                	div    %ecx
f0104e6e:	89 f2                	mov    %esi,%edx
f0104e70:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104e74:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104e78:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104e7c:	83 c4 1c             	add    $0x1c,%esp
f0104e7f:	c3                   	ret    
f0104e80:	31 d2                	xor    %edx,%edx
f0104e82:	31 c0                	xor    %eax,%eax
f0104e84:	39 f7                	cmp    %esi,%edi
f0104e86:	77 e8                	ja     f0104e70 <__udivdi3+0x50>
f0104e88:	0f bd cf             	bsr    %edi,%ecx
f0104e8b:	83 f1 1f             	xor    $0x1f,%ecx
f0104e8e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104e92:	75 2c                	jne    f0104ec0 <__udivdi3+0xa0>
f0104e94:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0104e98:	76 04                	jbe    f0104e9e <__udivdi3+0x7e>
f0104e9a:	39 f7                	cmp    %esi,%edi
f0104e9c:	73 d2                	jae    f0104e70 <__udivdi3+0x50>
f0104e9e:	31 d2                	xor    %edx,%edx
f0104ea0:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ea5:	eb c9                	jmp    f0104e70 <__udivdi3+0x50>
f0104ea7:	90                   	nop
f0104ea8:	89 f2                	mov    %esi,%edx
f0104eaa:	f7 f1                	div    %ecx
f0104eac:	31 d2                	xor    %edx,%edx
f0104eae:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104eb2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104eb6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104eba:	83 c4 1c             	add    $0x1c,%esp
f0104ebd:	c3                   	ret    
f0104ebe:	66 90                	xchg   %ax,%ax
f0104ec0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104ec5:	b8 20 00 00 00       	mov    $0x20,%eax
f0104eca:	89 ea                	mov    %ebp,%edx
f0104ecc:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104ed0:	d3 e7                	shl    %cl,%edi
f0104ed2:	89 c1                	mov    %eax,%ecx
f0104ed4:	d3 ea                	shr    %cl,%edx
f0104ed6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104edb:	09 fa                	or     %edi,%edx
f0104edd:	89 f7                	mov    %esi,%edi
f0104edf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104ee3:	89 f2                	mov    %esi,%edx
f0104ee5:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104ee9:	d3 e5                	shl    %cl,%ebp
f0104eeb:	89 c1                	mov    %eax,%ecx
f0104eed:	d3 ef                	shr    %cl,%edi
f0104eef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104ef4:	d3 e2                	shl    %cl,%edx
f0104ef6:	89 c1                	mov    %eax,%ecx
f0104ef8:	d3 ee                	shr    %cl,%esi
f0104efa:	09 d6                	or     %edx,%esi
f0104efc:	89 fa                	mov    %edi,%edx
f0104efe:	89 f0                	mov    %esi,%eax
f0104f00:	f7 74 24 0c          	divl   0xc(%esp)
f0104f04:	89 d7                	mov    %edx,%edi
f0104f06:	89 c6                	mov    %eax,%esi
f0104f08:	f7 e5                	mul    %ebp
f0104f0a:	39 d7                	cmp    %edx,%edi
f0104f0c:	72 22                	jb     f0104f30 <__udivdi3+0x110>
f0104f0e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0104f12:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104f17:	d3 e5                	shl    %cl,%ebp
f0104f19:	39 c5                	cmp    %eax,%ebp
f0104f1b:	73 04                	jae    f0104f21 <__udivdi3+0x101>
f0104f1d:	39 d7                	cmp    %edx,%edi
f0104f1f:	74 0f                	je     f0104f30 <__udivdi3+0x110>
f0104f21:	89 f0                	mov    %esi,%eax
f0104f23:	31 d2                	xor    %edx,%edx
f0104f25:	e9 46 ff ff ff       	jmp    f0104e70 <__udivdi3+0x50>
f0104f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104f30:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104f33:	31 d2                	xor    %edx,%edx
f0104f35:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104f39:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104f3d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104f41:	83 c4 1c             	add    $0x1c,%esp
f0104f44:	c3                   	ret    
	...

f0104f50 <__umoddi3>:
f0104f50:	83 ec 1c             	sub    $0x1c,%esp
f0104f53:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104f57:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0104f5b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0104f5f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104f63:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104f67:	8b 74 24 24          	mov    0x24(%esp),%esi
f0104f6b:	85 ed                	test   %ebp,%ebp
f0104f6d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104f71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f75:	89 cf                	mov    %ecx,%edi
f0104f77:	89 04 24             	mov    %eax,(%esp)
f0104f7a:	89 f2                	mov    %esi,%edx
f0104f7c:	75 1a                	jne    f0104f98 <__umoddi3+0x48>
f0104f7e:	39 f1                	cmp    %esi,%ecx
f0104f80:	76 4e                	jbe    f0104fd0 <__umoddi3+0x80>
f0104f82:	f7 f1                	div    %ecx
f0104f84:	89 d0                	mov    %edx,%eax
f0104f86:	31 d2                	xor    %edx,%edx
f0104f88:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104f8c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104f90:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104f94:	83 c4 1c             	add    $0x1c,%esp
f0104f97:	c3                   	ret    
f0104f98:	39 f5                	cmp    %esi,%ebp
f0104f9a:	77 54                	ja     f0104ff0 <__umoddi3+0xa0>
f0104f9c:	0f bd c5             	bsr    %ebp,%eax
f0104f9f:	83 f0 1f             	xor    $0x1f,%eax
f0104fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fa6:	75 60                	jne    f0105008 <__umoddi3+0xb8>
f0104fa8:	3b 0c 24             	cmp    (%esp),%ecx
f0104fab:	0f 87 07 01 00 00    	ja     f01050b8 <__umoddi3+0x168>
f0104fb1:	89 f2                	mov    %esi,%edx
f0104fb3:	8b 34 24             	mov    (%esp),%esi
f0104fb6:	29 ce                	sub    %ecx,%esi
f0104fb8:	19 ea                	sbb    %ebp,%edx
f0104fba:	89 34 24             	mov    %esi,(%esp)
f0104fbd:	8b 04 24             	mov    (%esp),%eax
f0104fc0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104fc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104fc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104fcc:	83 c4 1c             	add    $0x1c,%esp
f0104fcf:	c3                   	ret    
f0104fd0:	85 c9                	test   %ecx,%ecx
f0104fd2:	75 0b                	jne    f0104fdf <__umoddi3+0x8f>
f0104fd4:	b8 01 00 00 00       	mov    $0x1,%eax
f0104fd9:	31 d2                	xor    %edx,%edx
f0104fdb:	f7 f1                	div    %ecx
f0104fdd:	89 c1                	mov    %eax,%ecx
f0104fdf:	89 f0                	mov    %esi,%eax
f0104fe1:	31 d2                	xor    %edx,%edx
f0104fe3:	f7 f1                	div    %ecx
f0104fe5:	8b 04 24             	mov    (%esp),%eax
f0104fe8:	f7 f1                	div    %ecx
f0104fea:	eb 98                	jmp    f0104f84 <__umoddi3+0x34>
f0104fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104ff0:	89 f2                	mov    %esi,%edx
f0104ff2:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104ff6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104ffa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104ffe:	83 c4 1c             	add    $0x1c,%esp
f0105001:	c3                   	ret    
f0105002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105008:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010500d:	89 e8                	mov    %ebp,%eax
f010500f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0105014:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0105018:	89 fa                	mov    %edi,%edx
f010501a:	d3 e0                	shl    %cl,%eax
f010501c:	89 e9                	mov    %ebp,%ecx
f010501e:	d3 ea                	shr    %cl,%edx
f0105020:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105025:	09 c2                	or     %eax,%edx
f0105027:	8b 44 24 08          	mov    0x8(%esp),%eax
f010502b:	89 14 24             	mov    %edx,(%esp)
f010502e:	89 f2                	mov    %esi,%edx
f0105030:	d3 e7                	shl    %cl,%edi
f0105032:	89 e9                	mov    %ebp,%ecx
f0105034:	d3 ea                	shr    %cl,%edx
f0105036:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010503b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010503f:	d3 e6                	shl    %cl,%esi
f0105041:	89 e9                	mov    %ebp,%ecx
f0105043:	d3 e8                	shr    %cl,%eax
f0105045:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010504a:	09 f0                	or     %esi,%eax
f010504c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105050:	f7 34 24             	divl   (%esp)
f0105053:	d3 e6                	shl    %cl,%esi
f0105055:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105059:	89 d6                	mov    %edx,%esi
f010505b:	f7 e7                	mul    %edi
f010505d:	39 d6                	cmp    %edx,%esi
f010505f:	89 c1                	mov    %eax,%ecx
f0105061:	89 d7                	mov    %edx,%edi
f0105063:	72 3f                	jb     f01050a4 <__umoddi3+0x154>
f0105065:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105069:	72 35                	jb     f01050a0 <__umoddi3+0x150>
f010506b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010506f:	29 c8                	sub    %ecx,%eax
f0105071:	19 fe                	sbb    %edi,%esi
f0105073:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105078:	89 f2                	mov    %esi,%edx
f010507a:	d3 e8                	shr    %cl,%eax
f010507c:	89 e9                	mov    %ebp,%ecx
f010507e:	d3 e2                	shl    %cl,%edx
f0105080:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105085:	09 d0                	or     %edx,%eax
f0105087:	89 f2                	mov    %esi,%edx
f0105089:	d3 ea                	shr    %cl,%edx
f010508b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010508f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0105093:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0105097:	83 c4 1c             	add    $0x1c,%esp
f010509a:	c3                   	ret    
f010509b:	90                   	nop
f010509c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01050a0:	39 d6                	cmp    %edx,%esi
f01050a2:	75 c7                	jne    f010506b <__umoddi3+0x11b>
f01050a4:	89 d7                	mov    %edx,%edi
f01050a6:	89 c1                	mov    %eax,%ecx
f01050a8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01050ac:	1b 3c 24             	sbb    (%esp),%edi
f01050af:	eb ba                	jmp    f010506b <__umoddi3+0x11b>
f01050b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01050b8:	39 f5                	cmp    %esi,%ebp
f01050ba:	0f 82 f1 fe ff ff    	jb     f0104fb1 <__umoddi3+0x61>
f01050c0:	e9 f8 fe ff ff       	jmp    f0104fbd <__umoddi3+0x6d>
