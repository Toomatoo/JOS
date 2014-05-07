
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 9b 0b 00 00       	call   800bcc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 d8             	movzbl %al,%ebx
  800043:	89 d8                	mov    %ebx,%eax
  800045:	25 c0 00 00 00       	and    $0xc0,%eax
  80004a:	83 f8 40             	cmp    $0x40,%eax
  80004d:	75 f0                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  80004f:	b0 00                	mov    $0x0,%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800051:	84 c9                	test   %cl,%cl
  800053:	74 0a                	je     80005f <ide_wait_ready+0x2b>
  800055:	83 e3 21             	and    $0x21,%ebx
		return -1;
	return 0;
  800058:	83 fb 01             	cmp    $0x1,%ebx
  80005b:	19 c0                	sbb    %eax,%eax
  80005d:	f7 d0                	not    %eax
}
  80005f:	5b                   	pop    %ebx
  800060:	5d                   	pop    %ebp
  800061:	c3                   	ret    

00800062 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	53                   	push   %ebx
  800066:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
  80006e:	e8 c1 ff ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800073:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800078:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80007e:	b2 f7                	mov    $0xf7,%dl
  800080:	ec                   	in     (%dx),%al
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800081:	bb 01 00 00 00       	mov    $0x1,%ebx
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800086:	a8 a1                	test   $0xa1,%al
  800088:	75 0f                	jne    800099 <ide_probe_disk1+0x37>

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	b3 00                	mov    $0x0,%bl
  80008c:	eb 10                	jmp    80009e <ide_probe_disk1+0x3c>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008e:	83 c3 01             	add    $0x1,%ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800091:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800097:	74 05                	je     80009e <ide_probe_disk1+0x3c>
  800099:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  80009a:	a8 a1                	test   $0xa1,%al
  80009c:	75 f0                	jne    80008e <ide_probe_disk1+0x2c>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80009e:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000a3:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a8:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a9:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000af:	0f 9e c0             	setle  %al
  8000b2:	0f b6 c0             	movzbl %al,%eax
  8000b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b9:	c7 04 24 20 2f 80 00 	movl   $0x802f20,(%esp)
  8000c0:	e8 6e 0c 00 00       	call   800d33 <cprintf>
	return (x < 1000);
  8000c5:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000cb:	0f 9e c0             	setle  %al
}
  8000ce:	83 c4 14             	add    $0x14,%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 18             	sub    $0x18,%esp
  8000da:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000dd:	83 f8 01             	cmp    $0x1,%eax
  8000e0:	76 1c                	jbe    8000fe <ide_set_disk+0x2a>
		panic("bad disk number");
  8000e2:	c7 44 24 08 37 2f 80 	movl   $0x802f37,0x8(%esp)
  8000e9:	00 
  8000ea:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 47 2f 80 00 	movl   $0x802f47,(%esp)
  8000f9:	e8 3a 0b 00 00       	call   800c38 <_panic>
	diskno = d;
  8000fe:	a3 00 40 80 00       	mov    %eax,0x804000
}
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <ide_read>:

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 1c             	sub    $0x1c,%esp
  80010e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800114:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800117:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80011d:	76 24                	jbe    800143 <ide_read+0x3e>
  80011f:	c7 44 24 0c 50 2f 80 	movl   $0x802f50,0xc(%esp)
  800126:	00 
  800127:	c7 44 24 08 5d 2f 80 	movl   $0x802f5d,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 47 2f 80 00 	movl   $0x802f47,(%esp)
  80013e:	e8 f5 0a 00 00       	call   800c38 <_panic>

	ide_wait_ready(0);
  800143:	b8 00 00 00 00       	mov    $0x0,%eax
  800148:	e8 e7 fe ff ff       	call   800034 <ide_wait_ready>
  80014d:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800152:	89 f0                	mov    %esi,%eax
  800154:	ee                   	out    %al,(%dx)
  800155:	b2 f3                	mov    $0xf3,%dl
  800157:	89 f8                	mov    %edi,%eax
  800159:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80015a:	89 f8                	mov    %edi,%eax
  80015c:	c1 e8 08             	shr    $0x8,%eax
  80015f:	b2 f4                	mov    $0xf4,%dl
  800161:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800162:	89 f8                	mov    %edi,%eax
  800164:	c1 e8 10             	shr    $0x10,%eax
  800167:	b2 f5                	mov    $0xf5,%dl
  800169:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80016a:	a1 00 40 80 00       	mov    0x804000,%eax
  80016f:	83 e0 01             	and    $0x1,%eax
  800172:	c1 e0 04             	shl    $0x4,%eax
  800175:	83 c8 e0             	or     $0xffffffe0,%eax
  800178:	c1 ef 18             	shr    $0x18,%edi
  80017b:	83 e7 0f             	and    $0xf,%edi
  80017e:	09 f8                	or     %edi,%eax
  800180:	b2 f6                	mov    $0xf6,%dl
  800182:	ee                   	out    %al,(%dx)
  800183:	b2 f7                	mov    $0xf7,%dl
  800185:	b8 20 00 00 00       	mov    $0x20,%eax
  80018a:	ee                   	out    %al,(%dx)
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  80018b:	b8 00 00 00 00       	mov    $0x0,%eax
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800190:	85 f6                	test   %esi,%esi
  800192:	74 2d                	je     8001c1 <ide_read+0xbc>
		if ((r = ide_wait_ready(1)) < 0)
  800194:	b8 01 00 00 00       	mov    $0x1,%eax
  800199:	e8 96 fe ff ff       	call   800034 <ide_wait_ready>
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	78 1f                	js     8001c1 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  8001a2:	89 df                	mov    %ebx,%edi
  8001a4:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001a9:	ba f0 01 00 00       	mov    $0x1f0,%edx
  8001ae:	fc                   	cld    
  8001af:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001b1:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001b7:	83 ee 01             	sub    $0x1,%esi
  8001ba:	75 d8                	jne    800194 <ide_read+0x8f>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001c1:	83 c4 1c             	add    $0x1c,%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 1c             	sub    $0x1c,%esp
  8001d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8001d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001d8:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001db:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001e1:	76 24                	jbe    800207 <ide_write+0x3e>
  8001e3:	c7 44 24 0c 50 2f 80 	movl   $0x802f50,0xc(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 08 5d 2f 80 	movl   $0x802f5d,0x8(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8001fa:	00 
  8001fb:	c7 04 24 47 2f 80 00 	movl   $0x802f47,(%esp)
  800202:	e8 31 0a 00 00       	call   800c38 <_panic>

	ide_wait_ready(0);
  800207:	b8 00 00 00 00       	mov    $0x0,%eax
  80020c:	e8 23 fe ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800211:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800216:	89 f8                	mov    %edi,%eax
  800218:	ee                   	out    %al,(%dx)
  800219:	b2 f3                	mov    $0xf3,%dl
  80021b:	89 f0                	mov    %esi,%eax
  80021d:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80021e:	89 f0                	mov    %esi,%eax
  800220:	c1 e8 08             	shr    $0x8,%eax
  800223:	b2 f4                	mov    $0xf4,%dl
  800225:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800226:	89 f0                	mov    %esi,%eax
  800228:	c1 e8 10             	shr    $0x10,%eax
  80022b:	b2 f5                	mov    $0xf5,%dl
  80022d:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80022e:	a1 00 40 80 00       	mov    0x804000,%eax
  800233:	83 e0 01             	and    $0x1,%eax
  800236:	c1 e0 04             	shl    $0x4,%eax
  800239:	83 c8 e0             	or     $0xffffffe0,%eax
  80023c:	c1 ee 18             	shr    $0x18,%esi
  80023f:	83 e6 0f             	and    $0xf,%esi
  800242:	09 f0                	or     %esi,%eax
  800244:	b2 f6                	mov    $0xf6,%dl
  800246:	ee                   	out    %al,(%dx)
  800247:	b2 f7                	mov    $0xf7,%dl
  800249:	b8 30 00 00 00       	mov    $0x30,%eax
  80024e:	ee                   	out    %al,(%dx)
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80024f:	b8 00 00 00 00       	mov    $0x0,%eax
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800254:	85 ff                	test   %edi,%edi
  800256:	74 2d                	je     800285 <ide_write+0xbc>
		if ((r = ide_wait_ready(1)) < 0)
  800258:	b8 01 00 00 00       	mov    $0x1,%eax
  80025d:	e8 d2 fd ff ff       	call   800034 <ide_wait_ready>
  800262:	85 c0                	test   %eax,%eax
  800264:	78 1f                	js     800285 <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800266:	89 de                	mov    %ebx,%esi
  800268:	b9 80 00 00 00       	mov    $0x80,%ecx
  80026d:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800272:	fc                   	cld    
  800273:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800275:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80027b:	83 ef 01             	sub    $0x1,%edi
  80027e:	75 d8                	jne    800258 <ide_write+0x8f>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800280:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800285:	83 c4 1c             	add    $0x1c,%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    
  80028d:	00 00                	add    %al,(%eax)
	...

00800290 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 20             	sub    $0x20,%esp
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80029b:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80029d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  8002a3:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  8002a9:	76 2e                	jbe    8002d9 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8002ab:	8b 50 04             	mov    0x4(%eax),%edx
  8002ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8002b2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8002b6:	8b 40 28             	mov    0x28(%eax),%eax
  8002b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bd:	c7 44 24 08 74 2f 80 	movl   $0x802f74,0x8(%esp)
  8002c4:	00 
  8002c5:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  8002cc:	00 
  8002cd:	c7 04 24 36 30 80 00 	movl   $0x803036,(%esp)
  8002d4:	e8 5f 09 00 00       	call   800c38 <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002d9:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002df:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002e2:	a1 08 90 80 00       	mov    0x809008,%eax
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	74 25                	je     800310 <bc_pgfault+0x80>
  8002eb:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ee:	72 20                	jb     800310 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f4:	c7 44 24 08 a4 2f 80 	movl   $0x802fa4,0x8(%esp)
  8002fb:	00 
  8002fc:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800303:	00 
  800304:	c7 04 24 36 30 80 00 	movl   $0x803036,(%esp)
  80030b:	e8 28 09 00 00       	call   800c38 <_panic>
	// Allocate a page in the disk map region, read the contents
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary.
	//
	// LAB 5: you code here:
	addr = ROUNDDOWN(addr, PGSIZE);
  800310:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W);
  800316:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80031d:	00 
  80031e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800322:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800329:	e8 4e 16 00 00       	call   80197c <sys_page_alloc>
	if (r < 0)
  80032e:	85 c0                	test   %eax,%eax
  800330:	79 20                	jns    800352 <bc_pgfault+0xc2>
		panic("sys_page_alloc failed in bc_pgfault %e\n", r);
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	c7 44 24 08 c8 2f 80 	movl   $0x802fc8,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 36 30 80 00 	movl   $0x803036,(%esp)
  80034d:	e8 e6 08 00 00       	call   800c38 <_panic>
	//4096 = one block; 512 = one sector
	r = ide_read(blockno * 8, addr, 8);
  800352:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800359:	00 
  80035a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035e:	c1 e6 03             	shl    $0x3,%esi
  800361:	89 34 24             	mov    %esi,(%esp)
  800364:	e8 9c fd ff ff       	call   800105 <ide_read>
	if (r < 0)
  800369:	85 c0                	test   %eax,%eax
  80036b:	79 20                	jns    80038d <bc_pgfault+0xfd>
		panic("ide_read failed in bc_pgfault %e\n", r);
  80036d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800371:	c7 44 24 08 f0 2f 80 	movl   $0x802ff0,0x8(%esp)
  800378:	00 
  800379:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800380:	00 
  800381:	c7 04 24 36 30 80 00 	movl   $0x803036,(%esp)
  800388:	e8 ab 08 00 00       	call   800c38 <_panic>
}
  80038d:	83 c4 20             	add    $0x20,%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	83 ec 18             	sub    $0x18,%esp
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039d:	85 c0                	test   %eax,%eax
  80039f:	74 0f                	je     8003b0 <diskaddr+0x1c>
  8003a1:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8003a7:	85 d2                	test   %edx,%edx
  8003a9:	74 25                	je     8003d0 <diskaddr+0x3c>
  8003ab:	3b 42 04             	cmp    0x4(%edx),%eax
  8003ae:	72 20                	jb     8003d0 <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8003b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b4:	c7 44 24 08 14 30 80 	movl   $0x803014,0x8(%esp)
  8003bb:	00 
  8003bc:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8003c3:	00 
  8003c4:	c7 04 24 36 30 80 00 	movl   $0x803036,(%esp)
  8003cb:	e8 68 08 00 00       	call   800c38 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003d0:	05 00 00 01 00       	add    $0x10000,%eax
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
}
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <bc_init>:
}


void
bc_init(void)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8003e3:	c7 04 24 90 02 80 00 	movl   $0x800290,(%esp)
  8003ea:	e8 85 18 00 00       	call   801c74 <set_pgfault_handler>

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  8003ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8003f6:	e8 99 ff ff ff       	call   800394 <diskaddr>
  8003fb:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800402:	00 
  800403:	89 44 24 04          	mov    %eax,0x4(%esp)
  800407:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040d:	89 04 24             	mov    %eax,(%esp)
  800410:	e8 57 12 00 00       	call   80166c <memmove>
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    
	...

00800418 <skip_slash>:


// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  80041b:	80 38 2f             	cmpb   $0x2f,(%eax)
  80041e:	75 08                	jne    800428 <skip_slash+0x10>
		p++;
  800420:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800423:	80 38 2f             	cmpb   $0x2f,(%eax)
  800426:	74 f8                	je     800420 <skip_slash+0x8>
		p++;
	return p;
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800430:	a1 08 90 80 00       	mov    0x809008,%eax
  800435:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80043b:	74 1c                	je     800459 <check_super+0x2f>
		panic("bad file system magic number");
  80043d:	c7 44 24 08 3e 30 80 	movl   $0x80303e,0x8(%esp)
  800444:	00 
  800445:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80044c:	00 
  80044d:	c7 04 24 5b 30 80 00 	movl   $0x80305b,(%esp)
  800454:	e8 df 07 00 00       	call   800c38 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800459:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800460:	76 1c                	jbe    80047e <check_super+0x54>
		panic("file system is too large");
  800462:	c7 44 24 08 63 30 80 	movl   $0x803063,0x8(%esp)
  800469:	00 
  80046a:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800471:	00 
  800472:	c7 04 24 5b 30 80 00 	movl   $0x80305b,(%esp)
  800479:	e8 ba 07 00 00       	call   800c38 <_panic>

	cprintf("superblock is good\n");
  80047e:	c7 04 24 7c 30 80 00 	movl   $0x80307c,(%esp)
  800485:	e8 a9 08 00 00       	call   800d33 <cprintf>
}
  80048a:	c9                   	leave  
  80048b:	c3                   	ret    

0080048c <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  800492:	e8 cb fb ff ff       	call   800062 <ide_probe_disk1>
  800497:	84 c0                	test   %al,%al
  800499:	74 0e                	je     8004a9 <fs_init+0x1d>
		ide_set_disk(1);
  80049b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004a2:	e8 2d fc ff ff       	call   8000d4 <ide_set_disk>
  8004a7:	eb 0c                	jmp    8004b5 <fs_init+0x29>
	else
		ide_set_disk(0);
  8004a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004b0:	e8 1f fc ff ff       	call   8000d4 <ide_set_disk>

	bc_init();
  8004b5:	e8 20 ff ff ff       	call   8003da <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8004ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004c1:	e8 ce fe ff ff       	call   800394 <diskaddr>
  8004c6:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  8004cb:	e8 5a ff ff ff       	call   80042a <check_super>
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    

008004d2 <file_get_block>:
//	-E_NO_DISK if a block needed to be allocated but the disk is full.
//	-E_INVAL if filebno is out of range.
//
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 14             	sub    $0x14,%esp
  8004d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	uint32_t *ptr;
	char *blk;

	if (filebno < NDIRECT)
		ptr = &f->f_direct[filebno];
  8004df:	8d 84 9a 88 00 00 00 	lea    0x88(%edx,%ebx,4),%eax
{
	int r;
	uint32_t *ptr;
	char *blk;

	if (filebno < NDIRECT)
  8004e6:	83 fb 09             	cmp    $0x9,%ebx
  8004e9:	76 25                	jbe    800510 <file_get_block+0x3e>
		if (f->f_indirect == 0) {
			return -E_NOT_FOUND;
		}
		ptr = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
	} else
		return -E_INVAL;
  8004eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	uint32_t *ptr;
	char *blk;

	if (filebno < NDIRECT)
		ptr = &f->f_direct[filebno];
	else if (filebno < NDIRECT + NINDIRECT) {
  8004f0:	81 fb 09 04 00 00    	cmp    $0x409,%ebx
  8004f6:	77 35                	ja     80052d <file_get_block+0x5b>
		if (f->f_indirect == 0) {
  8004f8:	8b 92 b0 00 00 00    	mov    0xb0(%edx),%edx
			return -E_NOT_FOUND;
  8004fe:	b0 f5                	mov    $0xf5,%al
	char *blk;

	if (filebno < NDIRECT)
		ptr = &f->f_direct[filebno];
	else if (filebno < NDIRECT + NINDIRECT) {
		if (f->f_indirect == 0) {
  800500:	85 d2                	test   %edx,%edx
  800502:	74 29                	je     80052d <file_get_block+0x5b>
			return -E_NOT_FOUND;
		}
		ptr = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
  800504:	89 14 24             	mov    %edx,(%esp)
  800507:	e8 88 fe ff ff       	call   800394 <diskaddr>
  80050c:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
  800510:	8b 10                	mov    (%eax),%edx
		return -E_NOT_FOUND;
  800512:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
		return r;
	if (*ptr == 0) {
  800517:	85 d2                	test   %edx,%edx
  800519:	74 12                	je     80052d <file_get_block+0x5b>
		return -E_NOT_FOUND;
	}
	*blk = diskaddr(*ptr);
  80051b:	89 14 24             	mov    %edx,(%esp)
  80051e:	e8 71 fe ff ff       	call   800394 <diskaddr>
  800523:	8b 55 10             	mov    0x10(%ebp),%edx
  800526:	89 02                	mov    %eax,(%edx)
	return 0;
  800528:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80052d:	83 c4 14             	add    $0x14,%esp
  800530:	5b                   	pop    %ebx
  800531:	5d                   	pop    %ebp
  800532:	c3                   	ret    

00800533 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	57                   	push   %edi
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  80053f:	8b 45 08             	mov    0x8(%ebp),%eax
  800542:	e8 d1 fe ff ff       	call   800418 <skip_slash>
  800547:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
	f = &super->s_root;
  80054d:	a1 08 90 80 00       	mov    0x809008,%eax
  800552:	83 c0 08             	add    $0x8,%eax
  800555:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  80055b:	c6 85 64 ff ff ff 00 	movb   $0x0,-0x9c(%ebp)

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800562:	8b 45 0c             	mov    0xc(%ebp),%eax
  800565:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80056b:	e9 4a 01 00 00       	jmp    8006ba <file_open+0x187>
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800570:	83 c6 01             	add    $0x1,%esi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800573:	0f b6 06             	movzbl (%esi),%eax
  800576:	3c 2f                	cmp    $0x2f,%al
  800578:	74 04                	je     80057e <file_open+0x4b>
  80057a:	84 c0                	test   %al,%al
  80057c:	75 f2                	jne    800570 <file_open+0x3d>
			path++;
		if (path - p >= MAXNAMELEN)
  80057e:	89 f3                	mov    %esi,%ebx
  800580:	2b 9d 50 ff ff ff    	sub    -0xb0(%ebp),%ebx
  800586:	83 fb 7f             	cmp    $0x7f,%ebx
  800589:	0f 8f 59 01 00 00    	jg     8006e8 <file_open+0x1b5>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  80058f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800593:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8005a3:	89 14 24             	mov    %edx,(%esp)
  8005a6:	e8 c1 10 00 00       	call   80166c <memmove>
		name[path - p] = '\0';
  8005ab:	c6 84 1d 64 ff ff ff 	movb   $0x0,-0x9c(%ebp,%ebx,1)
  8005b2:	00 
		path = skip_slash(path);
  8005b3:	89 f0                	mov    %esi,%eax
  8005b5:	e8 5e fe ff ff       	call   800418 <skip_slash>
  8005ba:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)

		if (dir->f_type != FTYPE_DIR)
  8005c0:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  8005c6:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8005cd:	0f 85 1c 01 00 00    	jne    8006ef <file_open+0x1bc>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  8005d3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8005d9:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8005de:	74 24                	je     800604 <file_open+0xd1>
  8005e0:	c7 44 24 0c 90 30 80 	movl   $0x803090,0xc(%esp)
  8005e7:	00 
  8005e8:	c7 44 24 08 5d 2f 80 	movl   $0x802f5d,0x8(%esp)
  8005ef:	00 
  8005f0:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  8005f7:	00 
  8005f8:	c7 04 24 5b 30 80 00 	movl   $0x80305b,(%esp)
  8005ff:	e8 34 06 00 00       	call   800c38 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800604:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80060a:	85 c0                	test   %eax,%eax
  80060c:	0f 48 c2             	cmovs  %edx,%eax
  80060f:	c1 f8 0c             	sar    $0xc,%eax
  800612:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800618:	85 c0                	test   %eax,%eax
  80061a:	74 78                	je     800694 <file_open+0x161>
  80061c:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800623:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800626:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800629:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062d:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800633:	89 54 24 04          	mov    %edx,0x4(%esp)
  800637:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	e8 8d fe ff ff       	call   8004d2 <file_get_block>
  800645:	85 c0                	test   %eax,%eax
  800647:	78 46                	js     80068f <file_open+0x15c>
			return r;
		f = (struct File*) blk;
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064c:	bb 00 00 00 00       	mov    $0x0,%ebx


// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
  800651:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800654:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80065a:	89 54 24 04          	mov    %edx,0x4(%esp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  80065e:	89 34 24             	mov    %esi,(%esp)
  800661:	e8 d5 0e 00 00       	call   80153b <strcmp>
  800666:	85 c0                	test   %eax,%eax
  800668:	74 4a                	je     8006b4 <file_open+0x181>
  80066a:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800670:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800676:	75 d9                	jne    800651 <file_open+0x11e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800678:	83 85 54 ff ff ff 01 	addl   $0x1,-0xac(%ebp)
  80067f:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800685:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  80068b:	75 99                	jne    800626 <file_open+0xf3>
  80068d:	eb 05                	jmp    800694 <file_open+0x161>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  80068f:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800692:	75 60                	jne    8006f4 <file_open+0x1c1>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800694:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800699:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  80069f:	80 3a 00             	cmpb   $0x0,(%edx)
  8006a2:	75 50                	jne    8006f4 <file_open+0x1c1>
				if (pdir)
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
  8006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  8006ad:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8006b2:	eb 40                	jmp    8006f4 <file_open+0x1c1>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  8006b4:	89 b5 4c ff ff ff    	mov    %esi,-0xb4(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  8006ba:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  8006c0:	0f b6 02             	movzbl (%edx),%eax
  8006c3:	84 c0                	test   %al,%al
  8006c5:	74 0f                	je     8006d6 <file_open+0x1a3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8006c7:	89 d6                	mov    %edx,%esi
  8006c9:	3c 2f                	cmp    $0x2f,%al
  8006cb:	0f 85 9f fe ff ff    	jne    800570 <file_open+0x3d>
  8006d1:	e9 a8 fe ff ff       	jmp    80057e <file_open+0x4b>
		}
	}

	if (pdir)
		*pdir = dir;
	*pf = f;
  8006d6:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  8006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006df:	89 10                	mov    %edx,(%eax)
	return 0;
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	eb 0c                	jmp    8006f4 <file_open+0x1c1>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  8006e8:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8006ed:	eb 05                	jmp    8006f4 <file_open+0x1c1>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  8006ef:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
	return walk_path(path, 0, pf, 0);
}
  8006f4:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	5f                   	pop    %edi
  8006fd:	5d                   	pop    %ebp
  8006fe:	c3                   	ret    

008006ff <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	83 ec 3c             	sub    $0x3c,%esp
  800708:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80070b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80070e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  80071f:	39 da                	cmp    %ebx,%edx
  800721:	0f 8e 83 00 00 00    	jle    8007aa <file_read+0xab>
		return 0;

	count = MIN(count, f->f_size - offset);
  800727:	29 da                	sub    %ebx,%edx
  800729:	39 ca                	cmp    %ecx,%edx
  80072b:	0f 46 ca             	cmovbe %edx,%ecx
  80072e:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800731:	89 de                	mov    %ebx,%esi
  800733:	01 d9                	add    %ebx,%ecx
  800735:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800738:	39 cb                	cmp    %ecx,%ebx
  80073a:	73 6b                	jae    8007a7 <file_read+0xa8>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  80073c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80073f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800743:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800749:	85 db                	test   %ebx,%ebx
  80074b:	0f 49 c3             	cmovns %ebx,%eax
  80074e:	c1 f8 0c             	sar    $0xc,%eax
  800751:	89 44 24 04          	mov    %eax,0x4(%esp)
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	e8 72 fd ff ff       	call   8004d2 <file_get_block>
  800760:	85 c0                	test   %eax,%eax
  800762:	78 46                	js     8007aa <file_read+0xab>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800764:	89 da                	mov    %ebx,%edx
  800766:	c1 fa 1f             	sar    $0x1f,%edx
  800769:	c1 ea 14             	shr    $0x14,%edx
  80076c:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  80076f:	25 ff 0f 00 00       	and    $0xfff,%eax
  800774:	29 d0                	sub    %edx,%eax
  800776:	ba 00 10 00 00       	mov    $0x1000,%edx
  80077b:	29 c2                	sub    %eax,%edx
  80077d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800780:	29 f1                	sub    %esi,%ecx
  800782:	89 ce                	mov    %ecx,%esi
  800784:	39 ca                	cmp    %ecx,%edx
  800786:	0f 46 f2             	cmovbe %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800789:	89 74 24 08          	mov    %esi,0x8(%esp)
  80078d:	03 45 e4             	add    -0x1c(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	89 3c 24             	mov    %edi,(%esp)
  800797:	e8 d0 0e 00 00       	call   80166c <memmove>
		pos += bn;
  80079c:	01 f3                	add    %esi,%ebx
		buf += bn;
  80079e:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  8007a0:	89 de                	mov    %ebx,%esi
  8007a2:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  8007a5:	72 95                	jb     80073c <file_read+0x3d>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  8007a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  8007aa:	83 c4 3c             	add    $0x3c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    
	...

008007c0 <serve_flush>:


// Our read-only file system do nothing for flush
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8007cd:	ba 40 40 80 00       	mov    $0x804040,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  8007d2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8007dc:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8007de:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8007e1:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8007e7:	83 c0 01             	add    $0x1,%eax
  8007ea:	83 c2 10             	add    $0x10,%edx
  8007ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8007f2:	75 e8                	jne    8007dc <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	83 ec 10             	sub    $0x10,%esp
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800801:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  800806:	89 d8                	mov    %ebx,%eax
  800808:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  80080b:	8b 80 4c 40 80 00    	mov    0x80404c(%eax),%eax
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	e8 7b 1e 00 00       	call   802694 <pageref>
  800819:	85 c0                	test   %eax,%eax
  80081b:	74 07                	je     800824 <openfile_alloc+0x2e>
  80081d:	83 f8 01             	cmp    $0x1,%eax
  800820:	75 62                	jne    800884 <openfile_alloc+0x8e>
  800822:	eb 27                	jmp    80084b <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800824:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80082b:	00 
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	c1 e0 04             	shl    $0x4,%eax
  800831:	8b 80 4c 40 80 00    	mov    0x80404c(%eax),%eax
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800842:	e8 35 11 00 00       	call   80197c <sys_page_alloc>
  800847:	85 c0                	test   %eax,%eax
  800849:	78 4d                	js     800898 <openfile_alloc+0xa2>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  80084b:	c1 e3 04             	shl    $0x4,%ebx
  80084e:	8d 83 40 40 80 00    	lea    0x804040(%ebx),%eax
  800854:	81 83 40 40 80 00 00 	addl   $0x400,0x804040(%ebx)
  80085b:	04 00 00 
			*o = &opentab[i];
  80085e:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800860:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800867:	00 
  800868:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80086f:	00 
  800870:	8b 83 4c 40 80 00    	mov    0x80404c(%ebx),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 93 0d 00 00       	call   801611 <memset>
			return (*o)->o_fileid;
  80087e:	8b 06                	mov    (%esi),%eax
  800880:	8b 00                	mov    (%eax),%eax
  800882:	eb 14                	jmp    800898 <openfile_alloc+0xa2>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800884:	83 c3 01             	add    $0x1,%ebx
  800887:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80088d:	0f 85 73 ff ff ff    	jne    800806 <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800893:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800898:	83 c4 10             	add    $0x10,%esp
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 28             	sub    $0x28,%esp
  8008a5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8008a8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8008ab:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8008ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8008b1:	89 fe                	mov    %edi,%esi
  8008b3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8008b9:	c1 e6 04             	shl    $0x4,%esi
  8008bc:	8d 9e 40 40 80 00    	lea    0x804040(%esi),%ebx
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  8008c2:	8b 86 4c 40 80 00    	mov    0x80404c(%esi),%eax
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	e8 c4 1d 00 00       	call   802694 <pageref>
  8008d0:	83 f8 01             	cmp    $0x1,%eax
  8008d3:	74 19                	je     8008ee <openfile_lookup+0x4f>
		return -E_INVAL;
  8008d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  8008da:	39 be 40 40 80 00    	cmp    %edi,0x804040(%esi)
  8008e0:	75 11                	jne    8008f3 <openfile_lookup+0x54>
		return -E_INVAL;
	*po = o;
  8008e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e5:	89 18                	mov    %ebx,(%eax)
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ec:	eb 05                	jmp    8008f3 <openfile_lookup+0x54>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8008f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8008f6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8008f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8008fc:	89 ec                	mov    %ebp,%esp
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	53                   	push   %ebx
  800904:	83 ec 24             	sub    $0x24,%esp
  800907:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80090a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800911:	8b 03                	mov    (%ebx),%eax
  800913:	89 44 24 04          	mov    %eax,0x4(%esp)
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	89 04 24             	mov    %eax,(%esp)
  80091d:	e8 7d ff ff ff       	call   80089f <openfile_lookup>
  800922:	85 c0                	test   %eax,%eax
  800924:	78 3f                	js     800965 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800926:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800929:	8b 40 04             	mov    0x4(%eax),%eax
  80092c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800930:	89 1c 24             	mov    %ebx,(%esp)
  800933:	e8 43 0b 00 00       	call   80147b <strcpy>
	ret->ret_size = o->o_file->f_size;
  800938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093b:	8b 50 04             	mov    0x4(%eax),%edx
  80093e:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800944:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80094a:	8b 40 04             	mov    0x4(%eax),%eax
  80094d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800954:	0f 94 c0             	sete   %al
  800957:	0f b6 c0             	movzbl %al,%eax
  80095a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800965:	83 c4 24             	add    $0x24,%esp
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	83 ec 24             	sub    $0x24,%esp
  800972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// so filling in ret will overwrite req.
	//
	struct OpenFile *o;
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800975:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800978:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097c:	8b 03                	mov    (%ebx),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 12 ff ff ff       	call   80089f <openfile_lookup>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 3d                	js     8009ce <serve_read+0x63>
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
			   MIN(req->req_n, sizeof ret->ret_buf),
			   o->o_fd->fd_offset)) < 0)
  800991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800994:	8b 50 0c             	mov    0xc(%eax),%edx
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
  800997:	8b 52 04             	mov    0x4(%edx),%edx
  80099a:	89 54 24 0c          	mov    %edx,0xc(%esp)
			   MIN(req->req_n, sizeof ret->ret_buf),
  80099e:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8009a5:	ba 00 10 00 00       	mov    $0x1000,%edx
  8009aa:	0f 46 53 04          	cmovbe 0x4(%ebx),%edx
	int r;

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	if ((r = file_read(o->o_file, ret->ret_buf,
  8009ae:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b6:	8b 40 04             	mov    0x4(%eax),%eax
  8009b9:	89 04 24             	mov    %eax,(%esp)
  8009bc:	e8 3e fd ff ff       	call   8006ff <file_read>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 09                	js     8009ce <serve_read+0x63>
			   MIN(req->req_n, sizeof ret->ret_buf),
			   o->o_fd->fd_offset)) < 0)
		return r;

	o->o_fd->fd_offset += r;
  8009c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8009cb:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  8009ce:	83 c4 24             	add    $0x24,%esp
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	81 ec 24 04 00 00    	sub    $0x424,%esp
  8009de:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8009e1:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  8009e8:	00 
  8009e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ed:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 71 0c 00 00       	call   80166c <memmove>
	path[MAXPATHLEN-1] = 0;
  8009fb:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8009ff:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 e9 fd ff ff       	call   8007f6 <openfile_alloc>
  800a0d:	85 c0                	test   %eax,%eax
  800a0f:	0f 88 80 00 00 00    	js     800a95 <serve_open+0xc1>
	fileid = r;

	if (req->req_omode != 0) {
		if (debug)
			cprintf("file_open omode 0x%x unsupported", req->req_omode);
		return -E_INVAL;
  800a15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			cprintf("openfile_alloc failed: %e", r);
		return r;
	}
	fileid = r;

	if (req->req_omode != 0) {
  800a1a:	83 bb 00 04 00 00 00 	cmpl   $0x0,0x400(%ebx)
  800a21:	75 72                	jne    800a95 <serve_open+0xc1>
		if (debug)
			cprintf("file_open omode 0x%x unsupported", req->req_omode);
		return -E_INVAL;
	}

	if ((r = file_open(path, &f)) < 0) {
  800a23:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 f8 fa ff ff       	call   800533 <file_open>
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	78 56                	js     800a95 <serve_open+0xc1>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800a3f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800a45:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800a4b:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800a4e:	8b 50 0c             	mov    0xc(%eax),%edx
  800a51:	8b 08                	mov    (%eax),%ecx
  800a53:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800a56:	8b 50 0c             	mov    0xc(%eax),%edx
  800a59:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  800a5f:	83 e1 03             	and    $0x3,%ecx
  800a62:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800a65:	8b 40 0c             	mov    0xc(%eax),%eax
  800a68:	8b 15 48 80 80 00    	mov    0x808048,%edx
  800a6e:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800a70:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800a76:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800a7c:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  800a7f:	8b 50 0c             	mov    0xc(%eax),%edx
  800a82:	8b 45 10             	mov    0x10(%ebp),%eax
  800a85:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  800a87:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8a:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a95:	81 c4 24 04 00 00    	add    $0x424,%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800aa6:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800aa9:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  800aac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800ab3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ab7:	a1 3c 40 80 00       	mov    0x80403c,%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	89 34 24             	mov    %esi,(%esp)
  800ac3:	e8 5c 12 00 00       	call   801d24 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800ac8:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800acc:	75 15                	jne    800ae3 <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  800ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	c7 04 24 b0 30 80 00 	movl   $0x8030b0,(%esp)
  800adc:	e8 52 02 00 00       	call   800d33 <cprintf>
				whom);
			continue; // just leave it hanging...
  800ae1:	eb c9                	jmp    800aac <serve+0xe>
		}

		pg = NULL;
  800ae3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800aea:	83 f8 01             	cmp    $0x1,%eax
  800aed:	75 21                	jne    800b10 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800aef:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800af3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afa:	a1 3c 40 80 00       	mov    0x80403c,%eax
  800aff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b06:	89 04 24             	mov    %eax,(%esp)
  800b09:	e8 c6 fe ff ff       	call   8009d4 <serve_open>
  800b0e:	eb 3f                	jmp    800b4f <serve+0xb1>
		} else if (req < NHANDLERS && handlers[req]) {
  800b10:	83 f8 06             	cmp    $0x6,%eax
  800b13:	77 1e                	ja     800b33 <serve+0x95>
  800b15:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  800b1c:	85 d2                	test   %edx,%edx
  800b1e:	74 13                	je     800b33 <serve+0x95>
			r = handlers[req](whom, fsreq);
  800b20:	a1 3c 40 80 00       	mov    0x80403c,%eax
  800b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	ff d2                	call   *%edx
  800b31:	eb 1c                	jmp    800b4f <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800b33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b36:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3e:	c7 04 24 e0 30 80 00 	movl   $0x8030e0,(%esp)
  800b45:	e8 e9 01 00 00       	call   800d33 <cprintf>
			r = -E_INVAL;
  800b4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
//cprintf("serve: to ipc_send\n");
		ipc_send(whom, r, pg, perm);
  800b4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b52:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b56:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b59:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b64:	89 04 24             	mov    %eax,(%esp)
  800b67:	e8 1e 12 00 00       	call   801d8a <ipc_send>
		sys_page_unmap(0, fsreq);
  800b6c:	a1 3c 40 80 00       	mov    0x80403c,%eax
  800b71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b7c:	e8 b8 0e 00 00       	call   801a39 <sys_page_unmap>
  800b81:	e9 26 ff ff ff       	jmp    800aac <serve+0xe>

00800b86 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  800b8c:	c7 05 40 80 80 00 03 	movl   $0x803103,0x808040
  800b93:	31 80 00 
	cprintf("FS is running\n");
  800b96:	c7 04 24 06 31 80 00 	movl   $0x803106,(%esp)
  800b9d:	e8 91 01 00 00       	call   800d33 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  800ba2:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  800ba7:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  800bac:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  800bae:	c7 04 24 15 31 80 00 	movl   $0x803115,(%esp)
  800bb5:	e8 79 01 00 00       	call   800d33 <cprintf>

	serve_init();
  800bba:	e8 0b fc ff ff       	call   8007ca <serve_init>
	fs_init();
  800bbf:	e8 c8 f8 ff ff       	call   80048c <fs_init>
	serve();
  800bc4:	e8 d5 fe ff ff       	call   800a9e <serve>
  800bc9:	00 00                	add    %al,(%eax)
	...

00800bcc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 18             	sub    $0x18,%esp
  800bd2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800bd5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800bd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bdb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800bde:	e8 39 0d 00 00       	call   80191c <sys_getenvid>
  800be3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800be8:	c1 e0 07             	shl    $0x7,%eax
  800beb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800bf0:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800bf5:	85 f6                	test   %esi,%esi
  800bf7:	7e 07                	jle    800c00 <libmain+0x34>
		binaryname = argv[0];
  800bf9:	8b 03                	mov    (%ebx),%eax
  800bfb:	a3 40 80 80 00       	mov    %eax,0x808040

	// call user main routine
	umain(argc, argv);
  800c00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c04:	89 34 24             	mov    %esi,(%esp)
  800c07:	e8 7a ff ff ff       	call   800b86 <umain>

	// exit gracefully
	exit();
  800c0c:	e8 0b 00 00 00       	call   800c1c <exit>
}
  800c11:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800c14:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800c17:	89 ec                	mov    %ebp,%esp
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    
	...

00800c1c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800c22:	e8 37 14 00 00       	call   80205e <close_all>
	sys_env_destroy(0);
  800c27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c2e:	e8 8c 0c 00 00       	call   8018bf <sys_env_destroy>
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    
  800c35:	00 00                	add    %al,(%eax)
	...

00800c38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800c40:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c43:	8b 1d 40 80 80 00    	mov    0x808040,%ebx
  800c49:	e8 ce 0c 00 00       	call   80191c <sys_getenvid>
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c51:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c64:	c7 04 24 30 31 80 00 	movl   $0x803130,(%esp)
  800c6b:	e8 c3 00 00 00       	call   800d33 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c74:	8b 45 10             	mov    0x10(%ebp),%eax
  800c77:	89 04 24             	mov    %eax,(%esp)
  800c7a:	e8 53 00 00 00       	call   800cd2 <vcprintf>
	cprintf("\n");
  800c7f:	c7 04 24 22 31 80 00 	movl   $0x803122,(%esp)
  800c86:	e8 a8 00 00 00       	call   800d33 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c8b:	cc                   	int3   
  800c8c:	eb fd                	jmp    800c8b <_panic+0x53>
	...

00800c90 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	53                   	push   %ebx
  800c94:	83 ec 14             	sub    $0x14,%esp
  800c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800c9a:	8b 03                	mov    (%ebx),%eax
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800ca3:	83 c0 01             	add    $0x1,%eax
  800ca6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800ca8:	3d ff 00 00 00       	cmp    $0xff,%eax
  800cad:	75 19                	jne    800cc8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800caf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800cb6:	00 
  800cb7:	8d 43 08             	lea    0x8(%ebx),%eax
  800cba:	89 04 24             	mov    %eax,(%esp)
  800cbd:	e8 9e 0b 00 00       	call   801860 <sys_cputs>
		b->idx = 0;
  800cc2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800cc8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ccc:	83 c4 14             	add    $0x14,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800cdb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ce2:	00 00 00 
	b.cnt = 0;
  800ce5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800cec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800d03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d07:	c7 04 24 90 0c 80 00 	movl   $0x800c90,(%esp)
  800d0e:	e8 97 01 00 00       	call   800eaa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800d13:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800d19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d1d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800d23:	89 04 24             	mov    %eax,(%esp)
  800d26:	e8 35 0b 00 00       	call   801860 <sys_cputs>

	return b.cnt;
}
  800d2b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800d39:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	89 04 24             	mov    %eax,(%esp)
  800d46:	e8 87 ff ff ff       	call   800cd2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    
  800d4d:	00 00                	add    %al,(%eax)
	...

00800d50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 3c             	sub    $0x3c,%esp
  800d59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d5c:	89 d7                	mov    %edx,%edi
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d67:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d6a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800d6d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
  800d75:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800d78:	72 11                	jb     800d8b <printnum+0x3b>
  800d7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d7d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800d80:	76 09                	jbe    800d8b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800d82:	83 eb 01             	sub    $0x1,%ebx
  800d85:	85 db                	test   %ebx,%ebx
  800d87:	7f 51                	jg     800dda <printnum+0x8a>
  800d89:	eb 5e                	jmp    800de9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800d8b:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d8f:	83 eb 01             	sub    $0x1,%ebx
  800d92:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d96:	8b 45 10             	mov    0x10(%ebp),%eax
  800d99:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800da1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800da5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dac:	00 
  800dad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800db0:	89 04 24             	mov    %eax,(%esp)
  800db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800db6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dba:	e8 a1 1e 00 00       	call   802c60 <__udivdi3>
  800dbf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dc3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800dc7:	89 04 24             	mov    %eax,(%esp)
  800dca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd3:	e8 78 ff ff ff       	call   800d50 <printnum>
  800dd8:	eb 0f                	jmp    800de9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800dda:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dde:	89 34 24             	mov    %esi,(%esp)
  800de1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800de4:	83 eb 01             	sub    $0x1,%ebx
  800de7:	75 f1                	jne    800dda <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800de9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ded:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800df1:	8b 45 10             	mov    0x10(%ebp),%eax
  800df4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dff:	00 
  800e00:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e03:	89 04 24             	mov    %eax,(%esp)
  800e06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0d:	e8 7e 1f 00 00       	call   802d90 <__umoddi3>
  800e12:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e16:	0f be 80 53 31 80 00 	movsbl 0x803153(%eax),%eax
  800e1d:	89 04 24             	mov    %eax,(%esp)
  800e20:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800e23:	83 c4 3c             	add    $0x3c,%esp
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800e2e:	83 fa 01             	cmp    $0x1,%edx
  800e31:	7e 0e                	jle    800e41 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800e33:	8b 10                	mov    (%eax),%edx
  800e35:	8d 4a 08             	lea    0x8(%edx),%ecx
  800e38:	89 08                	mov    %ecx,(%eax)
  800e3a:	8b 02                	mov    (%edx),%eax
  800e3c:	8b 52 04             	mov    0x4(%edx),%edx
  800e3f:	eb 22                	jmp    800e63 <getuint+0x38>
	else if (lflag)
  800e41:	85 d2                	test   %edx,%edx
  800e43:	74 10                	je     800e55 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800e45:	8b 10                	mov    (%eax),%edx
  800e47:	8d 4a 04             	lea    0x4(%edx),%ecx
  800e4a:	89 08                	mov    %ecx,(%eax)
  800e4c:	8b 02                	mov    (%edx),%eax
  800e4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e53:	eb 0e                	jmp    800e63 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800e55:	8b 10                	mov    (%eax),%edx
  800e57:	8d 4a 04             	lea    0x4(%edx),%ecx
  800e5a:	89 08                	mov    %ecx,(%eax)
  800e5c:	8b 02                	mov    (%edx),%eax
  800e5e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800e6b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800e6f:	8b 10                	mov    (%eax),%edx
  800e71:	3b 50 04             	cmp    0x4(%eax),%edx
  800e74:	73 0a                	jae    800e80 <sprintputch+0x1b>
		*b->buf++ = ch;
  800e76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e79:	88 0a                	mov    %cl,(%edx)
  800e7b:	83 c2 01             	add    $0x1,%edx
  800e7e:	89 10                	mov    %edx,(%eax)
}
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800e88:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800e8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	89 04 24             	mov    %eax,(%esp)
  800ea3:	e8 02 00 00 00       	call   800eaa <vprintfmt>
	va_end(ap);
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 5c             	sub    $0x5c,%esp
  800eb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb6:	8b 75 10             	mov    0x10(%ebp),%esi
  800eb9:	eb 12                	jmp    800ecd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	0f 84 e4 04 00 00    	je     8013a7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800ec3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec7:	89 04 24             	mov    %eax,(%esp)
  800eca:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ecd:	0f b6 06             	movzbl (%esi),%eax
  800ed0:	83 c6 01             	add    $0x1,%esi
  800ed3:	83 f8 25             	cmp    $0x25,%eax
  800ed6:	75 e3                	jne    800ebb <vprintfmt+0x11>
  800ed8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800edc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800ee3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800ee8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800eef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800ef7:	eb 2b                	jmp    800f24 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ef9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800efc:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800f00:	eb 22                	jmp    800f24 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f02:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800f05:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800f09:	eb 19                	jmp    800f24 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f0b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800f0e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800f15:	eb 0d                	jmp    800f24 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800f17:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800f1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800f1d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f24:	0f b6 06             	movzbl (%esi),%eax
  800f27:	0f b6 d0             	movzbl %al,%edx
  800f2a:	8d 7e 01             	lea    0x1(%esi),%edi
  800f2d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800f30:	83 e8 23             	sub    $0x23,%eax
  800f33:	3c 55                	cmp    $0x55,%al
  800f35:	0f 87 46 04 00 00    	ja     801381 <vprintfmt+0x4d7>
  800f3b:	0f b6 c0             	movzbl %al,%eax
  800f3e:	ff 24 85 a0 32 80 00 	jmp    *0x8032a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800f45:	83 ea 30             	sub    $0x30,%edx
  800f48:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800f4b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800f4f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f52:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800f55:	83 fa 09             	cmp    $0x9,%edx
  800f58:	77 4a                	ja     800fa4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f5a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800f5d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800f60:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800f63:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800f67:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800f6a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800f6d:	83 fa 09             	cmp    $0x9,%edx
  800f70:	76 eb                	jbe    800f5d <vprintfmt+0xb3>
  800f72:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800f75:	eb 2d                	jmp    800fa4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800f77:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7a:	8d 50 04             	lea    0x4(%eax),%edx
  800f7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800f80:	8b 00                	mov    (%eax),%eax
  800f82:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f85:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800f88:	eb 1a                	jmp    800fa4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f8a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800f8d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800f91:	79 91                	jns    800f24 <vprintfmt+0x7a>
  800f93:	e9 73 ff ff ff       	jmp    800f0b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f98:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800f9b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800fa2:	eb 80                	jmp    800f24 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800fa4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800fa8:	0f 89 76 ff ff ff    	jns    800f24 <vprintfmt+0x7a>
  800fae:	e9 64 ff ff ff       	jmp    800f17 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800fb3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fb6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800fb9:	e9 66 ff ff ff       	jmp    800f24 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800fbe:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc1:	8d 50 04             	lea    0x4(%eax),%edx
  800fc4:	89 55 14             	mov    %edx,0x14(%ebp)
  800fc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fcb:	8b 00                	mov    (%eax),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fd3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800fd6:	e9 f2 fe ff ff       	jmp    800ecd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800fdb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800fdf:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800fe2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800fe6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800fe9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800fed:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800ff0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800ff3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800ff7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800ffa:	80 f9 09             	cmp    $0x9,%cl
  800ffd:	77 1d                	ja     80101c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800fff:	0f be c0             	movsbl %al,%eax
  801002:	6b c0 64             	imul   $0x64,%eax,%eax
  801005:	0f be d2             	movsbl %dl,%edx
  801008:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80100b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  801012:	a3 44 80 80 00       	mov    %eax,0x808044
  801017:	e9 b1 fe ff ff       	jmp    800ecd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80101c:	c7 44 24 04 6b 31 80 	movl   $0x80316b,0x4(%esp)
  801023:	00 
  801024:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801027:	89 04 24             	mov    %eax,(%esp)
  80102a:	e8 0c 05 00 00       	call   80153b <strcmp>
  80102f:	85 c0                	test   %eax,%eax
  801031:	75 0f                	jne    801042 <vprintfmt+0x198>
  801033:	c7 05 44 80 80 00 04 	movl   $0x4,0x808044
  80103a:	00 00 00 
  80103d:	e9 8b fe ff ff       	jmp    800ecd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  801042:	c7 44 24 04 6f 31 80 	movl   $0x80316f,0x4(%esp)
  801049:	00 
  80104a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80104d:	89 14 24             	mov    %edx,(%esp)
  801050:	e8 e6 04 00 00       	call   80153b <strcmp>
  801055:	85 c0                	test   %eax,%eax
  801057:	75 0f                	jne    801068 <vprintfmt+0x1be>
  801059:	c7 05 44 80 80 00 02 	movl   $0x2,0x808044
  801060:	00 00 00 
  801063:	e9 65 fe ff ff       	jmp    800ecd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  801068:	c7 44 24 04 73 31 80 	movl   $0x803173,0x4(%esp)
  80106f:	00 
  801070:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  801073:	89 0c 24             	mov    %ecx,(%esp)
  801076:	e8 c0 04 00 00       	call   80153b <strcmp>
  80107b:	85 c0                	test   %eax,%eax
  80107d:	75 0f                	jne    80108e <vprintfmt+0x1e4>
  80107f:	c7 05 44 80 80 00 01 	movl   $0x1,0x808044
  801086:	00 00 00 
  801089:	e9 3f fe ff ff       	jmp    800ecd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80108e:	c7 44 24 04 77 31 80 	movl   $0x803177,0x4(%esp)
  801095:	00 
  801096:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  801099:	89 3c 24             	mov    %edi,(%esp)
  80109c:	e8 9a 04 00 00       	call   80153b <strcmp>
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	75 0f                	jne    8010b4 <vprintfmt+0x20a>
  8010a5:	c7 05 44 80 80 00 06 	movl   $0x6,0x808044
  8010ac:	00 00 00 
  8010af:	e9 19 fe ff ff       	jmp    800ecd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8010b4:	c7 44 24 04 7b 31 80 	movl   $0x80317b,0x4(%esp)
  8010bb:	00 
  8010bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 74 04 00 00       	call   80153b <strcmp>
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	75 0f                	jne    8010da <vprintfmt+0x230>
  8010cb:	c7 05 44 80 80 00 07 	movl   $0x7,0x808044
  8010d2:	00 00 00 
  8010d5:	e9 f3 fd ff ff       	jmp    800ecd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8010da:	c7 44 24 04 7f 31 80 	movl   $0x80317f,0x4(%esp)
  8010e1:	00 
  8010e2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8010e5:	89 14 24             	mov    %edx,(%esp)
  8010e8:	e8 4e 04 00 00       	call   80153b <strcmp>
  8010ed:	83 f8 01             	cmp    $0x1,%eax
  8010f0:	19 c0                	sbb    %eax,%eax
  8010f2:	f7 d0                	not    %eax
  8010f4:	83 c0 08             	add    $0x8,%eax
  8010f7:	a3 44 80 80 00       	mov    %eax,0x808044
  8010fc:	e9 cc fd ff ff       	jmp    800ecd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  801101:	8b 45 14             	mov    0x14(%ebp),%eax
  801104:	8d 50 04             	lea    0x4(%eax),%edx
  801107:	89 55 14             	mov    %edx,0x14(%ebp)
  80110a:	8b 00                	mov    (%eax),%eax
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	c1 fa 1f             	sar    $0x1f,%edx
  801111:	31 d0                	xor    %edx,%eax
  801113:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801115:	83 f8 0f             	cmp    $0xf,%eax
  801118:	7f 0b                	jg     801125 <vprintfmt+0x27b>
  80111a:	8b 14 85 00 34 80 00 	mov    0x803400(,%eax,4),%edx
  801121:	85 d2                	test   %edx,%edx
  801123:	75 23                	jne    801148 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801125:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801129:	c7 44 24 08 83 31 80 	movl   $0x803183,0x8(%esp)
  801130:	00 
  801131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801135:	8b 7d 08             	mov    0x8(%ebp),%edi
  801138:	89 3c 24             	mov    %edi,(%esp)
  80113b:	e8 42 fd ff ff       	call   800e82 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801140:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801143:	e9 85 fd ff ff       	jmp    800ecd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801148:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114c:	c7 44 24 08 6f 2f 80 	movl   $0x802f6f,0x8(%esp)
  801153:	00 
  801154:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801158:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115b:	89 3c 24             	mov    %edi,(%esp)
  80115e:	e8 1f fd ff ff       	call   800e82 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801163:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801166:	e9 62 fd ff ff       	jmp    800ecd <vprintfmt+0x23>
  80116b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80116e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801171:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801174:	8b 45 14             	mov    0x14(%ebp),%eax
  801177:	8d 50 04             	lea    0x4(%eax),%edx
  80117a:	89 55 14             	mov    %edx,0x14(%ebp)
  80117d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80117f:	85 f6                	test   %esi,%esi
  801181:	b8 64 31 80 00       	mov    $0x803164,%eax
  801186:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801189:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80118d:	7e 06                	jle    801195 <vprintfmt+0x2eb>
  80118f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  801193:	75 13                	jne    8011a8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801195:	0f be 06             	movsbl (%esi),%eax
  801198:	83 c6 01             	add    $0x1,%esi
  80119b:	85 c0                	test   %eax,%eax
  80119d:	0f 85 94 00 00 00    	jne    801237 <vprintfmt+0x38d>
  8011a3:	e9 81 00 00 00       	jmp    801229 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ac:	89 34 24             	mov    %esi,(%esp)
  8011af:	e8 97 02 00 00       	call   80144b <strnlen>
  8011b4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8011b7:	29 c2                	sub    %eax,%edx
  8011b9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8011bc:	85 d2                	test   %edx,%edx
  8011be:	7e d5                	jle    801195 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8011c0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8011c4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8011c7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8011ca:	89 d6                	mov    %edx,%esi
  8011cc:	89 cf                	mov    %ecx,%edi
  8011ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d2:	89 3c 24             	mov    %edi,(%esp)
  8011d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011d8:	83 ee 01             	sub    $0x1,%esi
  8011db:	75 f1                	jne    8011ce <vprintfmt+0x324>
  8011dd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8011e0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8011e3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8011e6:	eb ad                	jmp    801195 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011e8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8011ec:	74 1b                	je     801209 <vprintfmt+0x35f>
  8011ee:	8d 50 e0             	lea    -0x20(%eax),%edx
  8011f1:	83 fa 5e             	cmp    $0x5e,%edx
  8011f4:	76 13                	jbe    801209 <vprintfmt+0x35f>
					putch('?', putdat);
  8011f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8011f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801204:	ff 55 08             	call   *0x8(%ebp)
  801207:	eb 0d                	jmp    801216 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  801209:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80120c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801216:	83 eb 01             	sub    $0x1,%ebx
  801219:	0f be 06             	movsbl (%esi),%eax
  80121c:	83 c6 01             	add    $0x1,%esi
  80121f:	85 c0                	test   %eax,%eax
  801221:	75 1a                	jne    80123d <vprintfmt+0x393>
  801223:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  801226:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801229:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80122c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801230:	7f 1c                	jg     80124e <vprintfmt+0x3a4>
  801232:	e9 96 fc ff ff       	jmp    800ecd <vprintfmt+0x23>
  801237:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80123a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80123d:	85 ff                	test   %edi,%edi
  80123f:	78 a7                	js     8011e8 <vprintfmt+0x33e>
  801241:	83 ef 01             	sub    $0x1,%edi
  801244:	79 a2                	jns    8011e8 <vprintfmt+0x33e>
  801246:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  801249:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80124c:	eb db                	jmp    801229 <vprintfmt+0x37f>
  80124e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801251:	89 de                	mov    %ebx,%esi
  801253:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801256:	89 74 24 04          	mov    %esi,0x4(%esp)
  80125a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801261:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801263:	83 eb 01             	sub    $0x1,%ebx
  801266:	75 ee                	jne    801256 <vprintfmt+0x3ac>
  801268:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80126d:	e9 5b fc ff ff       	jmp    800ecd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801272:	83 f9 01             	cmp    $0x1,%ecx
  801275:	7e 10                	jle    801287 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  801277:	8b 45 14             	mov    0x14(%ebp),%eax
  80127a:	8d 50 08             	lea    0x8(%eax),%edx
  80127d:	89 55 14             	mov    %edx,0x14(%ebp)
  801280:	8b 30                	mov    (%eax),%esi
  801282:	8b 78 04             	mov    0x4(%eax),%edi
  801285:	eb 26                	jmp    8012ad <vprintfmt+0x403>
	else if (lflag)
  801287:	85 c9                	test   %ecx,%ecx
  801289:	74 12                	je     80129d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80128b:	8b 45 14             	mov    0x14(%ebp),%eax
  80128e:	8d 50 04             	lea    0x4(%eax),%edx
  801291:	89 55 14             	mov    %edx,0x14(%ebp)
  801294:	8b 30                	mov    (%eax),%esi
  801296:	89 f7                	mov    %esi,%edi
  801298:	c1 ff 1f             	sar    $0x1f,%edi
  80129b:	eb 10                	jmp    8012ad <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80129d:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a0:	8d 50 04             	lea    0x4(%eax),%edx
  8012a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8012a6:	8b 30                	mov    (%eax),%esi
  8012a8:	89 f7                	mov    %esi,%edi
  8012aa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8012ad:	85 ff                	test   %edi,%edi
  8012af:	78 0e                	js     8012bf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012b1:	89 f0                	mov    %esi,%eax
  8012b3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8012b5:	be 0a 00 00 00       	mov    $0xa,%esi
  8012ba:	e9 84 00 00 00       	jmp    801343 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8012bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012c3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8012cd:	89 f0                	mov    %esi,%eax
  8012cf:	89 fa                	mov    %edi,%edx
  8012d1:	f7 d8                	neg    %eax
  8012d3:	83 d2 00             	adc    $0x0,%edx
  8012d6:	f7 da                	neg    %edx
			}
			base = 10;
  8012d8:	be 0a 00 00 00       	mov    $0xa,%esi
  8012dd:	eb 64                	jmp    801343 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8012df:	89 ca                	mov    %ecx,%edx
  8012e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8012e4:	e8 42 fb ff ff       	call   800e2b <getuint>
			base = 10;
  8012e9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8012ee:	eb 53                	jmp    801343 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8012f0:	89 ca                	mov    %ecx,%edx
  8012f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8012f5:	e8 31 fb ff ff       	call   800e2b <getuint>
    			base = 8;
  8012fa:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8012ff:	eb 42                	jmp    801343 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  801301:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801305:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80130c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80130f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801313:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80131a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80131d:	8b 45 14             	mov    0x14(%ebp),%eax
  801320:	8d 50 04             	lea    0x4(%eax),%edx
  801323:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801326:	8b 00                	mov    (%eax),%eax
  801328:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80132d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  801332:	eb 0f                	jmp    801343 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801334:	89 ca                	mov    %ecx,%edx
  801336:	8d 45 14             	lea    0x14(%ebp),%eax
  801339:	e8 ed fa ff ff       	call   800e2b <getuint>
			base = 16;
  80133e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801343:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  801347:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80134b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80134e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801352:	89 74 24 08          	mov    %esi,0x8(%esp)
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	89 54 24 04          	mov    %edx,0x4(%esp)
  80135d:	89 da                	mov    %ebx,%edx
  80135f:	8b 45 08             	mov    0x8(%ebp),%eax
  801362:	e8 e9 f9 ff ff       	call   800d50 <printnum>
			break;
  801367:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80136a:	e9 5e fb ff ff       	jmp    800ecd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80136f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801373:	89 14 24             	mov    %edx,(%esp)
  801376:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80137c:	e9 4c fb ff ff       	jmp    800ecd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801381:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801385:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80138c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80138f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801393:	0f 84 34 fb ff ff    	je     800ecd <vprintfmt+0x23>
  801399:	83 ee 01             	sub    $0x1,%esi
  80139c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8013a0:	75 f7                	jne    801399 <vprintfmt+0x4ef>
  8013a2:	e9 26 fb ff ff       	jmp    800ecd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8013a7:	83 c4 5c             	add    $0x5c,%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	83 ec 28             	sub    $0x28,%esp
  8013b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8013bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8013be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8013c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8013c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	74 30                	je     801400 <vsnprintf+0x51>
  8013d0:	85 d2                	test   %edx,%edx
  8013d2:	7e 2c                	jle    801400 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8013d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013db:	8b 45 10             	mov    0x10(%ebp),%eax
  8013de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	c7 04 24 65 0e 80 00 	movl   $0x800e65,(%esp)
  8013f0:	e8 b5 fa ff ff       	call   800eaa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8013f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fe:	eb 05                	jmp    801405 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801400:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80140d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801414:	8b 45 10             	mov    0x10(%ebp),%eax
  801417:	89 44 24 08          	mov    %eax,0x8(%esp)
  80141b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 82 ff ff ff       	call   8013af <vsnprintf>
	va_end(ap);

	return rc;
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    
	...

00801430 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
  80143b:	80 3a 00             	cmpb   $0x0,(%edx)
  80143e:	74 09                	je     801449 <strlen+0x19>
		n++;
  801440:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801443:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801447:	75 f7                	jne    801440 <strlen+0x10>
		n++;
	return n;
}
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801452:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
  80145a:	85 c9                	test   %ecx,%ecx
  80145c:	74 1a                	je     801478 <strnlen+0x2d>
  80145e:	80 3b 00             	cmpb   $0x0,(%ebx)
  801461:	74 15                	je     801478 <strnlen+0x2d>
  801463:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801468:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80146a:	39 ca                	cmp    %ecx,%edx
  80146c:	74 0a                	je     801478 <strnlen+0x2d>
  80146e:	83 c2 01             	add    $0x1,%edx
  801471:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801476:	75 f0                	jne    801468 <strnlen+0x1d>
		n++;
	return n;
}
  801478:	5b                   	pop    %ebx
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	53                   	push   %ebx
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801485:	ba 00 00 00 00       	mov    $0x0,%edx
  80148a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80148e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801491:	83 c2 01             	add    $0x1,%edx
  801494:	84 c9                	test   %cl,%cl
  801496:	75 f2                	jne    80148a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801498:	5b                   	pop    %ebx
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    

0080149b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8014a5:	89 1c 24             	mov    %ebx,(%esp)
  8014a8:	e8 83 ff ff ff       	call   801430 <strlen>
	strcpy(dst + len, src);
  8014ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b4:	01 d8                	add    %ebx,%eax
  8014b6:	89 04 24             	mov    %eax,(%esp)
  8014b9:	e8 bd ff ff ff       	call   80147b <strcpy>
	return dst;
}
  8014be:	89 d8                	mov    %ebx,%eax
  8014c0:	83 c4 08             	add    $0x8,%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014d4:	85 f6                	test   %esi,%esi
  8014d6:	74 18                	je     8014f0 <strncpy+0x2a>
  8014d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8014dd:	0f b6 1a             	movzbl (%edx),%ebx
  8014e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8014e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8014e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8014e9:	83 c1 01             	add    $0x1,%ecx
  8014ec:	39 f1                	cmp    %esi,%ecx
  8014ee:	75 ed                	jne    8014dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8014f0:	5b                   	pop    %ebx
  8014f1:	5e                   	pop    %esi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	57                   	push   %edi
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801500:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801503:	89 f8                	mov    %edi,%eax
  801505:	85 f6                	test   %esi,%esi
  801507:	74 2b                	je     801534 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801509:	83 fe 01             	cmp    $0x1,%esi
  80150c:	74 23                	je     801531 <strlcpy+0x3d>
  80150e:	0f b6 0b             	movzbl (%ebx),%ecx
  801511:	84 c9                	test   %cl,%cl
  801513:	74 1c                	je     801531 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801515:	83 ee 02             	sub    $0x2,%esi
  801518:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80151d:	88 08                	mov    %cl,(%eax)
  80151f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801522:	39 f2                	cmp    %esi,%edx
  801524:	74 0b                	je     801531 <strlcpy+0x3d>
  801526:	83 c2 01             	add    $0x1,%edx
  801529:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80152d:	84 c9                	test   %cl,%cl
  80152f:	75 ec                	jne    80151d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  801531:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801534:	29 f8                	sub    %edi,%eax
}
  801536:	5b                   	pop    %ebx
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801541:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801544:	0f b6 01             	movzbl (%ecx),%eax
  801547:	84 c0                	test   %al,%al
  801549:	74 16                	je     801561 <strcmp+0x26>
  80154b:	3a 02                	cmp    (%edx),%al
  80154d:	75 12                	jne    801561 <strcmp+0x26>
		p++, q++;
  80154f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801552:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801556:	84 c0                	test   %al,%al
  801558:	74 07                	je     801561 <strcmp+0x26>
  80155a:	83 c1 01             	add    $0x1,%ecx
  80155d:	3a 02                	cmp    (%edx),%al
  80155f:	74 ee                	je     80154f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801561:	0f b6 c0             	movzbl %al,%eax
  801564:	0f b6 12             	movzbl (%edx),%edx
  801567:	29 d0                	sub    %edx,%eax
}
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801575:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80157d:	85 d2                	test   %edx,%edx
  80157f:	74 28                	je     8015a9 <strncmp+0x3e>
  801581:	0f b6 01             	movzbl (%ecx),%eax
  801584:	84 c0                	test   %al,%al
  801586:	74 24                	je     8015ac <strncmp+0x41>
  801588:	3a 03                	cmp    (%ebx),%al
  80158a:	75 20                	jne    8015ac <strncmp+0x41>
  80158c:	83 ea 01             	sub    $0x1,%edx
  80158f:	74 13                	je     8015a4 <strncmp+0x39>
		n--, p++, q++;
  801591:	83 c1 01             	add    $0x1,%ecx
  801594:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801597:	0f b6 01             	movzbl (%ecx),%eax
  80159a:	84 c0                	test   %al,%al
  80159c:	74 0e                	je     8015ac <strncmp+0x41>
  80159e:	3a 03                	cmp    (%ebx),%al
  8015a0:	74 ea                	je     80158c <strncmp+0x21>
  8015a2:	eb 08                	jmp    8015ac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8015a4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8015a9:	5b                   	pop    %ebx
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8015ac:	0f b6 01             	movzbl (%ecx),%eax
  8015af:	0f b6 13             	movzbl (%ebx),%edx
  8015b2:	29 d0                	sub    %edx,%eax
  8015b4:	eb f3                	jmp    8015a9 <strncmp+0x3e>

008015b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8015c0:	0f b6 10             	movzbl (%eax),%edx
  8015c3:	84 d2                	test   %dl,%dl
  8015c5:	74 1c                	je     8015e3 <strchr+0x2d>
		if (*s == c)
  8015c7:	38 ca                	cmp    %cl,%dl
  8015c9:	75 09                	jne    8015d4 <strchr+0x1e>
  8015cb:	eb 1b                	jmp    8015e8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8015cd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8015d0:	38 ca                	cmp    %cl,%dl
  8015d2:	74 14                	je     8015e8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8015d4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8015d8:	84 d2                	test   %dl,%dl
  8015da:	75 f1                	jne    8015cd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8015dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e1:	eb 05                	jmp    8015e8 <strchr+0x32>
  8015e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8015f4:	0f b6 10             	movzbl (%eax),%edx
  8015f7:	84 d2                	test   %dl,%dl
  8015f9:	74 14                	je     80160f <strfind+0x25>
		if (*s == c)
  8015fb:	38 ca                	cmp    %cl,%dl
  8015fd:	75 06                	jne    801605 <strfind+0x1b>
  8015ff:	eb 0e                	jmp    80160f <strfind+0x25>
  801601:	38 ca                	cmp    %cl,%dl
  801603:	74 0a                	je     80160f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801605:	83 c0 01             	add    $0x1,%eax
  801608:	0f b6 10             	movzbl (%eax),%edx
  80160b:	84 d2                	test   %dl,%dl
  80160d:	75 f2                	jne    801601 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80160f:	5d                   	pop    %ebp
  801610:	c3                   	ret    

00801611 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80161a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80161d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801620:	8b 7d 08             	mov    0x8(%ebp),%edi
  801623:	8b 45 0c             	mov    0xc(%ebp),%eax
  801626:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801629:	85 c9                	test   %ecx,%ecx
  80162b:	74 30                	je     80165d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80162d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801633:	75 25                	jne    80165a <memset+0x49>
  801635:	f6 c1 03             	test   $0x3,%cl
  801638:	75 20                	jne    80165a <memset+0x49>
		c &= 0xFF;
  80163a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80163d:	89 d3                	mov    %edx,%ebx
  80163f:	c1 e3 08             	shl    $0x8,%ebx
  801642:	89 d6                	mov    %edx,%esi
  801644:	c1 e6 18             	shl    $0x18,%esi
  801647:	89 d0                	mov    %edx,%eax
  801649:	c1 e0 10             	shl    $0x10,%eax
  80164c:	09 f0                	or     %esi,%eax
  80164e:	09 d0                	or     %edx,%eax
  801650:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801652:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801655:	fc                   	cld    
  801656:	f3 ab                	rep stos %eax,%es:(%edi)
  801658:	eb 03                	jmp    80165d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80165a:	fc                   	cld    
  80165b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80165d:	89 f8                	mov    %edi,%eax
  80165f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801662:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801665:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801668:	89 ec                	mov    %ebp,%esp
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801675:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80167e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801681:	39 c6                	cmp    %eax,%esi
  801683:	73 36                	jae    8016bb <memmove+0x4f>
  801685:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801688:	39 d0                	cmp    %edx,%eax
  80168a:	73 2f                	jae    8016bb <memmove+0x4f>
		s += n;
		d += n;
  80168c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80168f:	f6 c2 03             	test   $0x3,%dl
  801692:	75 1b                	jne    8016af <memmove+0x43>
  801694:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80169a:	75 13                	jne    8016af <memmove+0x43>
  80169c:	f6 c1 03             	test   $0x3,%cl
  80169f:	75 0e                	jne    8016af <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8016a1:	83 ef 04             	sub    $0x4,%edi
  8016a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8016a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8016aa:	fd                   	std    
  8016ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016ad:	eb 09                	jmp    8016b8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8016af:	83 ef 01             	sub    $0x1,%edi
  8016b2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8016b5:	fd                   	std    
  8016b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8016b8:	fc                   	cld    
  8016b9:	eb 20                	jmp    8016db <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8016bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8016c1:	75 13                	jne    8016d6 <memmove+0x6a>
  8016c3:	a8 03                	test   $0x3,%al
  8016c5:	75 0f                	jne    8016d6 <memmove+0x6a>
  8016c7:	f6 c1 03             	test   $0x3,%cl
  8016ca:	75 0a                	jne    8016d6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8016cc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8016cf:	89 c7                	mov    %eax,%edi
  8016d1:	fc                   	cld    
  8016d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8016d4:	eb 05                	jmp    8016db <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8016d6:	89 c7                	mov    %eax,%edi
  8016d8:	fc                   	cld    
  8016d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8016db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016e1:	89 ec                	mov    %ebp,%esp
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8016eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fc:	89 04 24             	mov    %eax,(%esp)
  8016ff:	e8 68 ff ff ff       	call   80166c <memmove>
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	57                   	push   %edi
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80170f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801712:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801715:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80171a:	85 ff                	test   %edi,%edi
  80171c:	74 37                	je     801755 <memcmp+0x4f>
		if (*s1 != *s2)
  80171e:	0f b6 03             	movzbl (%ebx),%eax
  801721:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801724:	83 ef 01             	sub    $0x1,%edi
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  80172c:	38 c8                	cmp    %cl,%al
  80172e:	74 1c                	je     80174c <memcmp+0x46>
  801730:	eb 10                	jmp    801742 <memcmp+0x3c>
  801732:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801737:	83 c2 01             	add    $0x1,%edx
  80173a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  80173e:	38 c8                	cmp    %cl,%al
  801740:	74 0a                	je     80174c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801742:	0f b6 c0             	movzbl %al,%eax
  801745:	0f b6 c9             	movzbl %cl,%ecx
  801748:	29 c8                	sub    %ecx,%eax
  80174a:	eb 09                	jmp    801755 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80174c:	39 fa                	cmp    %edi,%edx
  80174e:	75 e2                	jne    801732 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801750:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5f                   	pop    %edi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801760:	89 c2                	mov    %eax,%edx
  801762:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801765:	39 d0                	cmp    %edx,%eax
  801767:	73 19                	jae    801782 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801769:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  80176d:	38 08                	cmp    %cl,(%eax)
  80176f:	75 06                	jne    801777 <memfind+0x1d>
  801771:	eb 0f                	jmp    801782 <memfind+0x28>
  801773:	38 08                	cmp    %cl,(%eax)
  801775:	74 0b                	je     801782 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801777:	83 c0 01             	add    $0x1,%eax
  80177a:	39 d0                	cmp    %edx,%eax
  80177c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801780:	75 f1                	jne    801773 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	57                   	push   %edi
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	8b 55 08             	mov    0x8(%ebp),%edx
  80178d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801790:	0f b6 02             	movzbl (%edx),%eax
  801793:	3c 20                	cmp    $0x20,%al
  801795:	74 04                	je     80179b <strtol+0x17>
  801797:	3c 09                	cmp    $0x9,%al
  801799:	75 0e                	jne    8017a9 <strtol+0x25>
		s++;
  80179b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80179e:	0f b6 02             	movzbl (%edx),%eax
  8017a1:	3c 20                	cmp    $0x20,%al
  8017a3:	74 f6                	je     80179b <strtol+0x17>
  8017a5:	3c 09                	cmp    $0x9,%al
  8017a7:	74 f2                	je     80179b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  8017a9:	3c 2b                	cmp    $0x2b,%al
  8017ab:	75 0a                	jne    8017b7 <strtol+0x33>
		s++;
  8017ad:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8017b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8017b5:	eb 10                	jmp    8017c7 <strtol+0x43>
  8017b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8017bc:	3c 2d                	cmp    $0x2d,%al
  8017be:	75 07                	jne    8017c7 <strtol+0x43>
		s++, neg = 1;
  8017c0:	83 c2 01             	add    $0x1,%edx
  8017c3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8017c7:	85 db                	test   %ebx,%ebx
  8017c9:	0f 94 c0             	sete   %al
  8017cc:	74 05                	je     8017d3 <strtol+0x4f>
  8017ce:	83 fb 10             	cmp    $0x10,%ebx
  8017d1:	75 15                	jne    8017e8 <strtol+0x64>
  8017d3:	80 3a 30             	cmpb   $0x30,(%edx)
  8017d6:	75 10                	jne    8017e8 <strtol+0x64>
  8017d8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8017dc:	75 0a                	jne    8017e8 <strtol+0x64>
		s += 2, base = 16;
  8017de:	83 c2 02             	add    $0x2,%edx
  8017e1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8017e6:	eb 13                	jmp    8017fb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8017e8:	84 c0                	test   %al,%al
  8017ea:	74 0f                	je     8017fb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8017ec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8017f1:	80 3a 30             	cmpb   $0x30,(%edx)
  8017f4:	75 05                	jne    8017fb <strtol+0x77>
		s++, base = 8;
  8017f6:	83 c2 01             	add    $0x1,%edx
  8017f9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801800:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801802:	0f b6 0a             	movzbl (%edx),%ecx
  801805:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801808:	80 fb 09             	cmp    $0x9,%bl
  80180b:	77 08                	ja     801815 <strtol+0x91>
			dig = *s - '0';
  80180d:	0f be c9             	movsbl %cl,%ecx
  801810:	83 e9 30             	sub    $0x30,%ecx
  801813:	eb 1e                	jmp    801833 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801815:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801818:	80 fb 19             	cmp    $0x19,%bl
  80181b:	77 08                	ja     801825 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80181d:	0f be c9             	movsbl %cl,%ecx
  801820:	83 e9 57             	sub    $0x57,%ecx
  801823:	eb 0e                	jmp    801833 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801825:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801828:	80 fb 19             	cmp    $0x19,%bl
  80182b:	77 14                	ja     801841 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80182d:	0f be c9             	movsbl %cl,%ecx
  801830:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801833:	39 f1                	cmp    %esi,%ecx
  801835:	7d 0e                	jge    801845 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801837:	83 c2 01             	add    $0x1,%edx
  80183a:	0f af c6             	imul   %esi,%eax
  80183d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80183f:	eb c1                	jmp    801802 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801841:	89 c1                	mov    %eax,%ecx
  801843:	eb 02                	jmp    801847 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801845:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801847:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80184b:	74 05                	je     801852 <strtol+0xce>
		*endptr = (char *) s;
  80184d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801850:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801852:	89 ca                	mov    %ecx,%edx
  801854:	f7 da                	neg    %edx
  801856:	85 ff                	test   %edi,%edi
  801858:	0f 45 c2             	cmovne %edx,%eax
}
  80185b:	5b                   	pop    %ebx
  80185c:	5e                   	pop    %esi
  80185d:	5f                   	pop    %edi
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801869:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80186c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801877:	8b 55 08             	mov    0x8(%ebp),%edx
  80187a:	89 c3                	mov    %eax,%ebx
  80187c:	89 c7                	mov    %eax,%edi
  80187e:	89 c6                	mov    %eax,%esi
  801880:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801882:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801885:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801888:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80188b:	89 ec                	mov    %ebp,%esp
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <sys_cgetc>:

int
sys_cgetc(void)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801898:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80189b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a8:	89 d1                	mov    %edx,%ecx
  8018aa:	89 d3                	mov    %edx,%ebx
  8018ac:	89 d7                	mov    %edx,%edi
  8018ae:	89 d6                	mov    %edx,%esi
  8018b0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8018b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018bb:	89 ec                	mov    %ebp,%esp
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 38             	sub    $0x38,%esp
  8018c5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018c8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018cb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8018ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018db:	89 cb                	mov    %ecx,%ebx
  8018dd:	89 cf                	mov    %ecx,%edi
  8018df:	89 ce                	mov    %ecx,%esi
  8018e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	7e 28                	jle    80190f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018eb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8018f2:	00 
  8018f3:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  8018fa:	00 
  8018fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801902:	00 
  801903:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  80190a:	e8 29 f3 ff ff       	call   800c38 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80190f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801912:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801915:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801918:	89 ec                	mov    %ebp,%esp
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801925:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801928:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 02 00 00 00       	mov    $0x2,%eax
  801935:	89 d1                	mov    %edx,%ecx
  801937:	89 d3                	mov    %edx,%ebx
  801939:	89 d7                	mov    %edx,%edi
  80193b:	89 d6                	mov    %edx,%esi
  80193d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80193f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801942:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801945:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801948:	89 ec                	mov    %ebp,%esp
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <sys_yield>:

void
sys_yield(void)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801955:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801958:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 0b 00 00 00       	mov    $0xb,%eax
  801965:	89 d1                	mov    %edx,%ecx
  801967:	89 d3                	mov    %edx,%ebx
  801969:	89 d7                	mov    %edx,%edi
  80196b:	89 d6                	mov    %edx,%esi
  80196d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80196f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801972:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801975:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801978:	89 ec                	mov    %ebp,%esp
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 38             	sub    $0x38,%esp
  801982:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801985:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801988:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80198b:	be 00 00 00 00       	mov    $0x0,%esi
  801990:	b8 04 00 00 00       	mov    $0x4,%eax
  801995:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801998:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80199b:	8b 55 08             	mov    0x8(%ebp),%edx
  80199e:	89 f7                	mov    %esi,%edi
  8019a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	7e 28                	jle    8019ce <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8019a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019aa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8019b1:	00 
  8019b2:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  8019b9:	00 
  8019ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8019c1:	00 
  8019c2:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  8019c9:	e8 6a f2 ff ff       	call   800c38 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8019ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019d7:	89 ec                	mov    %ebp,%esp
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 38             	sub    $0x38,%esp
  8019e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8019ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8019ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8019f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8019f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8019fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801a00:	85 c0                	test   %eax,%eax
  801a02:	7e 28                	jle    801a2c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a04:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801a0f:	00 
  801a10:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  801a17:	00 
  801a18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a1f:	00 
  801a20:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  801a27:	e8 0c f2 ff ff       	call   800c38 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801a2c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a2f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a32:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a35:	89 ec                	mov    %ebp,%esp
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 38             	sub    $0x38,%esp
  801a3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a45:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801a48:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4d:	b8 06 00 00 00       	mov    $0x6,%eax
  801a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a55:	8b 55 08             	mov    0x8(%ebp),%edx
  801a58:	89 df                	mov    %ebx,%edi
  801a5a:	89 de                	mov    %ebx,%esi
  801a5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	7e 28                	jle    801a8a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a62:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a66:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801a6d:	00 
  801a6e:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  801a75:	00 
  801a76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a7d:	00 
  801a7e:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  801a85:	e8 ae f1 ff ff       	call   800c38 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801a8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a90:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a93:	89 ec                	mov    %ebp,%esp
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 38             	sub    $0x38,%esp
  801a9d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801aa0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801aa3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801aa6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aab:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab6:	89 df                	mov    %ebx,%edi
  801ab8:	89 de                	mov    %ebx,%esi
  801aba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801abc:	85 c0                	test   %eax,%eax
  801abe:	7e 28                	jle    801ae8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801ac0:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ac4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801acb:	00 
  801acc:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  801ad3:	00 
  801ad4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801adb:	00 
  801adc:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  801ae3:	e8 50 f1 ff ff       	call   800c38 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801ae8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801aeb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801aee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801af1:	89 ec                	mov    %ebp,%esp
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 38             	sub    $0x38,%esp
  801afb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801afe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b01:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801b04:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b09:	b8 09 00 00 00       	mov    $0x9,%eax
  801b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b11:	8b 55 08             	mov    0x8(%ebp),%edx
  801b14:	89 df                	mov    %ebx,%edi
  801b16:	89 de                	mov    %ebx,%esi
  801b18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	7e 28                	jle    801b46 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801b1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b22:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801b29:	00 
  801b2a:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  801b31:	00 
  801b32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801b39:	00 
  801b3a:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  801b41:	e8 f2 f0 ff ff       	call   800c38 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801b46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b4f:	89 ec                	mov    %ebp,%esp
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 38             	sub    $0x38,%esp
  801b59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801b62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b67:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  801b72:	89 df                	mov    %ebx,%edi
  801b74:	89 de                	mov    %ebx,%esi
  801b76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	7e 28                	jle    801ba4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801b7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b80:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801b87:	00 
  801b88:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  801b8f:	00 
  801b90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801b97:	00 
  801b98:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  801b9f:	e8 94 f0 ff ff       	call   800c38 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801ba4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ba7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801baa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801bad:	89 ec                	mov    %ebp,%esp
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801bc0:	be 00 00 00 00       	mov    $0x0,%esi
  801bc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  801bca:	8b 7d 14             	mov    0x14(%ebp),%edi
  801bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  801bd6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801bd8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801bdb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801bde:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801be1:	89 ec                	mov    %ebp,%esp
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 38             	sub    $0x38,%esp
  801beb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bf1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801bf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bf9:	b8 0d 00 00 00       	mov    $0xd,%eax
  801bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  801c01:	89 cb                	mov    %ecx,%ebx
  801c03:	89 cf                	mov    %ecx,%edi
  801c05:	89 ce                	mov    %ecx,%esi
  801c07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	7e 28                	jle    801c35 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801c0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c11:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801c18:	00 
  801c19:	c7 44 24 08 5f 34 80 	movl   $0x80345f,0x8(%esp)
  801c20:	00 
  801c21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801c28:	00 
  801c29:	c7 04 24 7c 34 80 00 	movl   $0x80347c,(%esp)
  801c30:	e8 03 f0 ff ff       	call   800c38 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801c35:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c38:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c3b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c3e:	89 ec                	mov    %ebp,%esp
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c4b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c4e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801c51:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c56:	b8 0e 00 00 00       	mov    $0xe,%eax
  801c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  801c5e:	89 cb                	mov    %ecx,%ebx
  801c60:	89 cf                	mov    %ecx,%edi
  801c62:	89 ce                	mov    %ecx,%esi
  801c64:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801c66:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c69:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c6c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c6f:	89 ec                	mov    %ebp,%esp
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    
	...

00801c74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801c7a:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  801c81:	75 3c                	jne    801cbf <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801c83:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c8a:	00 
  801c8b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801c92:	ee 
  801c93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9a:	e8 dd fc ff ff       	call   80197c <sys_page_alloc>
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	79 1c                	jns    801cbf <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801ca3:	c7 44 24 08 8c 34 80 	movl   $0x80348c,0x8(%esp)
  801caa:	00 
  801cab:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801cb2:	00 
  801cb3:	c7 04 24 ee 34 80 00 	movl   $0x8034ee,(%esp)
  801cba:	e8 79 ef ff ff       	call   800c38 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	a3 10 90 80 00       	mov    %eax,0x809010
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801cc7:	c7 44 24 04 00 1d 80 	movl   $0x801d00,0x4(%esp)
  801cce:	00 
  801ccf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd6:	e8 78 fe ff ff       	call   801b53 <sys_env_set_pgfault_upcall>
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	79 1c                	jns    801cfb <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801cdf:	c7 44 24 08 b8 34 80 	movl   $0x8034b8,0x8(%esp)
  801ce6:	00 
  801ce7:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801cee:	00 
  801cef:	c7 04 24 ee 34 80 00 	movl   $0x8034ee,(%esp)
  801cf6:	e8 3d ef ff ff       	call   800c38 <_panic>
}
  801cfb:	c9                   	leave  
  801cfc:	c3                   	ret    
  801cfd:	00 00                	add    %al,(%eax)
	...

00801d00 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d00:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d01:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  801d06:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d08:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  801d0b:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  801d0f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801d14:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  801d18:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  801d1a:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  801d1d:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  801d1e:	83 c4 04             	add    $0x4,%esp
    popfl
  801d21:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801d22:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801d23:	c3                   	ret    

00801d24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
  801d29:	83 ec 10             	sub    $0x10,%esp
  801d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d32:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801d35:	85 db                	test   %ebx,%ebx
  801d37:	74 06                	je     801d3f <ipc_recv+0x1b>
  801d39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801d3f:	85 f6                	test   %esi,%esi
  801d41:	74 06                	je     801d49 <ipc_recv+0x25>
  801d43:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d50:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 8a fe ff ff       	call   801be5 <sys_ipc_recv>
    if (ret) return ret;
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	75 24                	jne    801d83 <ipc_recv+0x5f>
    if (from_env_store)
  801d5f:	85 db                	test   %ebx,%ebx
  801d61:	74 0a                	je     801d6d <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801d63:	a1 0c 90 80 00       	mov    0x80900c,%eax
  801d68:	8b 40 74             	mov    0x74(%eax),%eax
  801d6b:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801d6d:	85 f6                	test   %esi,%esi
  801d6f:	74 0a                	je     801d7b <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801d71:	a1 0c 90 80 00       	mov    0x80900c,%eax
  801d76:	8b 40 78             	mov    0x78(%eax),%eax
  801d79:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801d7b:	a1 0c 90 80 00       	mov    0x80900c,%eax
  801d80:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	5b                   	pop    %ebx
  801d87:	5e                   	pop    %esi
  801d88:	5d                   	pop    %ebp
  801d89:	c3                   	ret    

00801d8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	57                   	push   %edi
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 1c             	sub    $0x1c,%esp
  801d93:	8b 75 08             	mov    0x8(%ebp),%esi
  801d96:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801d9c:	85 db                	test   %ebx,%ebx
  801d9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801da3:	0f 44 d8             	cmove  %eax,%ebx
  801da6:	eb 2a                	jmp    801dd2 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801da8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dab:	74 20                	je     801dcd <ipc_send+0x43>
  801dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801db1:	c7 44 24 08 fc 34 80 	movl   $0x8034fc,0x8(%esp)
  801db8:	00 
  801db9:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801dc0:	00 
  801dc1:	c7 04 24 13 35 80 00 	movl   $0x803513,(%esp)
  801dc8:	e8 6b ee ff ff       	call   800c38 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801dcd:	e8 7a fb ff ff       	call   80194c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801dd2:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ddd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801de1:	89 34 24             	mov    %esi,(%esp)
  801de4:	e8 c8 fd ff ff       	call   801bb1 <sys_ipc_try_send>
  801de9:	85 c0                	test   %eax,%eax
  801deb:	75 bb                	jne    801da8 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801ded:	83 c4 1c             	add    $0x1c,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801dfb:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801e00:	39 c8                	cmp    %ecx,%eax
  801e02:	74 19                	je     801e1d <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e04:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801e09:	89 c2                	mov    %eax,%edx
  801e0b:	c1 e2 07             	shl    $0x7,%edx
  801e0e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e14:	8b 52 50             	mov    0x50(%edx),%edx
  801e17:	39 ca                	cmp    %ecx,%edx
  801e19:	75 14                	jne    801e2f <ipc_find_env+0x3a>
  801e1b:	eb 05                	jmp    801e22 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801e22:	c1 e0 07             	shl    $0x7,%eax
  801e25:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e2a:	8b 40 40             	mov    0x40(%eax),%eax
  801e2d:	eb 0e                	jmp    801e3d <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e2f:	83 c0 01             	add    $0x1,%eax
  801e32:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e37:	75 d0                	jne    801e09 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e39:	66 b8 00 00          	mov    $0x0,%ax
}
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    
	...

00801e40 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e43:	8b 45 08             	mov    0x8(%ebp),%eax
  801e46:	05 00 00 00 30       	add    $0x30000000,%eax
  801e4b:	c1 e8 0c             	shr    $0xc,%eax
}
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801e56:	8b 45 08             	mov    0x8(%ebp),%eax
  801e59:	89 04 24             	mov    %eax,(%esp)
  801e5c:	e8 df ff ff ff       	call   801e40 <fd2num>
  801e61:	05 20 00 0d 00       	add    $0xd0020,%eax
  801e66:	c1 e0 0c             	shl    $0xc,%eax
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	53                   	push   %ebx
  801e6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e72:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801e77:	a8 01                	test   $0x1,%al
  801e79:	74 34                	je     801eaf <fd_alloc+0x44>
  801e7b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801e80:	a8 01                	test   $0x1,%al
  801e82:	74 32                	je     801eb6 <fd_alloc+0x4b>
  801e84:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801e89:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e8b:	89 c2                	mov    %eax,%edx
  801e8d:	c1 ea 16             	shr    $0x16,%edx
  801e90:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e97:	f6 c2 01             	test   $0x1,%dl
  801e9a:	74 1f                	je     801ebb <fd_alloc+0x50>
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	c1 ea 0c             	shr    $0xc,%edx
  801ea1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ea8:	f6 c2 01             	test   $0x1,%dl
  801eab:	75 17                	jne    801ec4 <fd_alloc+0x59>
  801ead:	eb 0c                	jmp    801ebb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801eaf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801eb4:	eb 05                	jmp    801ebb <fd_alloc+0x50>
  801eb6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801ebb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec2:	eb 17                	jmp    801edb <fd_alloc+0x70>
  801ec4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ec9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801ece:	75 b9                	jne    801e89 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801ed0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801ed6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801edb:	5b                   	pop    %ebx
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801ee4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ee9:	83 fa 1f             	cmp    $0x1f,%edx
  801eec:	77 3f                	ja     801f2d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801eee:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801ef4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ef7:	89 d0                	mov    %edx,%eax
  801ef9:	c1 e8 16             	shr    $0x16,%eax
  801efc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801f08:	f6 c1 01             	test   $0x1,%cl
  801f0b:	74 20                	je     801f2d <fd_lookup+0x4f>
  801f0d:	89 d0                	mov    %edx,%eax
  801f0f:	c1 e8 0c             	shr    $0xc,%eax
  801f12:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801f1e:	f6 c1 01             	test   $0x1,%cl
  801f21:	74 0a                	je     801f2d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f26:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    

00801f2f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	53                   	push   %ebx
  801f33:	83 ec 14             	sub    $0x14,%esp
  801f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801f41:	39 0d 48 80 80 00    	cmp    %ecx,0x808048
  801f47:	75 17                	jne    801f60 <dev_lookup+0x31>
  801f49:	eb 07                	jmp    801f52 <dev_lookup+0x23>
  801f4b:	39 0a                	cmp    %ecx,(%edx)
  801f4d:	75 11                	jne    801f60 <dev_lookup+0x31>
  801f4f:	90                   	nop
  801f50:	eb 05                	jmp    801f57 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801f52:	ba 48 80 80 00       	mov    $0x808048,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801f57:	89 13                	mov    %edx,(%ebx)
			return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5e:	eb 35                	jmp    801f95 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801f60:	83 c0 01             	add    $0x1,%eax
  801f63:	8b 14 85 a0 35 80 00 	mov    0x8035a0(,%eax,4),%edx
  801f6a:	85 d2                	test   %edx,%edx
  801f6c:	75 dd                	jne    801f4b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801f6e:	a1 0c 90 80 00       	mov    0x80900c,%eax
  801f73:	8b 40 48             	mov    0x48(%eax),%eax
  801f76:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7e:	c7 04 24 20 35 80 00 	movl   $0x803520,(%esp)
  801f85:	e8 a9 ed ff ff       	call   800d33 <cprintf>
	*dev = 0;
  801f8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801f90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f95:	83 c4 14             	add    $0x14,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 38             	sub    $0x38,%esp
  801fa1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fa4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fa7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801faa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fad:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801fb1:	89 3c 24             	mov    %edi,(%esp)
  801fb4:	e8 87 fe ff ff       	call   801e40 <fd2num>
  801fb9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801fbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc0:	89 04 24             	mov    %eax,(%esp)
  801fc3:	e8 16 ff ff ff       	call   801ede <fd_lookup>
  801fc8:	89 c3                	mov    %eax,%ebx
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	78 05                	js     801fd3 <fd_close+0x38>
	    || fd != fd2)
  801fce:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801fd1:	74 0e                	je     801fe1 <fd_close+0x46>
		return (must_exist ? r : 0);
  801fd3:	89 f0                	mov    %esi,%eax
  801fd5:	84 c0                	test   %al,%al
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdc:	0f 44 d8             	cmove  %eax,%ebx
  801fdf:	eb 3d                	jmp    80201e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801fe1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe8:	8b 07                	mov    (%edi),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 3d ff ff ff       	call   801f2f <dev_lookup>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	78 16                	js     80200e <fd_close+0x73>
		if (dev->dev_close)
  801ff8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ffb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802003:	85 c0                	test   %eax,%eax
  802005:	74 07                	je     80200e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  802007:	89 3c 24             	mov    %edi,(%esp)
  80200a:	ff d0                	call   *%eax
  80200c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80200e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802019:	e8 1b fa ff ff       	call   801a39 <sys_page_unmap>
	return r;
}
  80201e:	89 d8                	mov    %ebx,%eax
  802020:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802023:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802026:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802029:	89 ec                	mov    %ebp,%esp
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203a:	8b 45 08             	mov    0x8(%ebp),%eax
  80203d:	89 04 24             	mov    %eax,(%esp)
  802040:	e8 99 fe ff ff       	call   801ede <fd_lookup>
  802045:	85 c0                	test   %eax,%eax
  802047:	78 13                	js     80205c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802049:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802050:	00 
  802051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802054:	89 04 24             	mov    %eax,(%esp)
  802057:	e8 3f ff ff ff       	call   801f9b <fd_close>
}
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <close_all>:

void
close_all(void)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	53                   	push   %ebx
  802062:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802065:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80206a:	89 1c 24             	mov    %ebx,(%esp)
  80206d:	e8 bb ff ff ff       	call   80202d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802072:	83 c3 01             	add    $0x1,%ebx
  802075:	83 fb 20             	cmp    $0x20,%ebx
  802078:	75 f0                	jne    80206a <close_all+0xc>
		close(i);
}
  80207a:	83 c4 14             	add    $0x14,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    

00802080 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	83 ec 58             	sub    $0x58,%esp
  802086:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802089:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80208c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80208f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802092:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802095:	89 44 24 04          	mov    %eax,0x4(%esp)
  802099:	8b 45 08             	mov    0x8(%ebp),%eax
  80209c:	89 04 24             	mov    %eax,(%esp)
  80209f:	e8 3a fe ff ff       	call   801ede <fd_lookup>
  8020a4:	89 c3                	mov    %eax,%ebx
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	0f 88 e1 00 00 00    	js     80218f <dup+0x10f>
		return r;
	close(newfdnum);
  8020ae:	89 3c 24             	mov    %edi,(%esp)
  8020b1:	e8 77 ff ff ff       	call   80202d <close>

	newfd = INDEX2FD(newfdnum);
  8020b6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8020bc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8020bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020c2:	89 04 24             	mov    %eax,(%esp)
  8020c5:	e8 86 fd ff ff       	call   801e50 <fd2data>
  8020ca:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8020cc:	89 34 24             	mov    %esi,(%esp)
  8020cf:	e8 7c fd ff ff       	call   801e50 <fd2data>
  8020d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8020d7:	89 d8                	mov    %ebx,%eax
  8020d9:	c1 e8 16             	shr    $0x16,%eax
  8020dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020e3:	a8 01                	test   $0x1,%al
  8020e5:	74 46                	je     80212d <dup+0xad>
  8020e7:	89 d8                	mov    %ebx,%eax
  8020e9:	c1 e8 0c             	shr    $0xc,%eax
  8020ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020f3:	f6 c2 01             	test   $0x1,%dl
  8020f6:	74 35                	je     80212d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020ff:	25 07 0e 00 00       	and    $0xe07,%eax
  802104:	89 44 24 10          	mov    %eax,0x10(%esp)
  802108:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80210b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802116:	00 
  802117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80211b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802122:	e8 b4 f8 ff ff       	call   8019db <sys_page_map>
  802127:	89 c3                	mov    %eax,%ebx
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 3b                	js     802168 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80212d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802130:	89 c2                	mov    %eax,%edx
  802132:	c1 ea 0c             	shr    $0xc,%edx
  802135:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80213c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802142:	89 54 24 10          	mov    %edx,0x10(%esp)
  802146:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80214a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802151:	00 
  802152:	89 44 24 04          	mov    %eax,0x4(%esp)
  802156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80215d:	e8 79 f8 ff ff       	call   8019db <sys_page_map>
  802162:	89 c3                	mov    %eax,%ebx
  802164:	85 c0                	test   %eax,%eax
  802166:	79 25                	jns    80218d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802168:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802173:	e8 c1 f8 ff ff       	call   801a39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802178:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80217b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802186:	e8 ae f8 ff ff       	call   801a39 <sys_page_unmap>
	return r;
  80218b:	eb 02                	jmp    80218f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80218d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80218f:	89 d8                	mov    %ebx,%eax
  802191:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802194:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802197:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80219a:	89 ec                	mov    %ebp,%esp
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    

0080219e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	53                   	push   %ebx
  8021a2:	83 ec 24             	sub    $0x24,%esp
  8021a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021af:	89 1c 24             	mov    %ebx,(%esp)
  8021b2:	e8 27 fd ff ff       	call   801ede <fd_lookup>
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	78 6d                	js     802228 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c5:	8b 00                	mov    (%eax),%eax
  8021c7:	89 04 24             	mov    %eax,(%esp)
  8021ca:	e8 60 fd ff ff       	call   801f2f <dev_lookup>
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	78 55                	js     802228 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8021d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d6:	8b 50 08             	mov    0x8(%eax),%edx
  8021d9:	83 e2 03             	and    $0x3,%edx
  8021dc:	83 fa 01             	cmp    $0x1,%edx
  8021df:	75 23                	jne    802204 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8021e1:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8021e6:	8b 40 48             	mov    0x48(%eax),%eax
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f1:	c7 04 24 64 35 80 00 	movl   $0x803564,(%esp)
  8021f8:	e8 36 eb ff ff       	call   800d33 <cprintf>
		return -E_INVAL;
  8021fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802202:	eb 24                	jmp    802228 <read+0x8a>
	}
	if (!dev->dev_read)
  802204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802207:	8b 52 08             	mov    0x8(%edx),%edx
  80220a:	85 d2                	test   %edx,%edx
  80220c:	74 15                	je     802223 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80220e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802211:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802218:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80221c:	89 04 24             	mov    %eax,(%esp)
  80221f:	ff d2                	call   *%edx
  802221:	eb 05                	jmp    802228 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802223:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  802228:	83 c4 24             	add    $0x24,%esp
  80222b:	5b                   	pop    %ebx
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    

0080222e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80223a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80223d:	b8 00 00 00 00       	mov    $0x0,%eax
  802242:	85 f6                	test   %esi,%esi
  802244:	74 30                	je     802276 <readn+0x48>
  802246:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80224b:	89 f2                	mov    %esi,%edx
  80224d:	29 c2                	sub    %eax,%edx
  80224f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802253:	03 45 0c             	add    0xc(%ebp),%eax
  802256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225a:	89 3c 24             	mov    %edi,(%esp)
  80225d:	e8 3c ff ff ff       	call   80219e <read>
		if (m < 0)
  802262:	85 c0                	test   %eax,%eax
  802264:	78 10                	js     802276 <readn+0x48>
			return m;
		if (m == 0)
  802266:	85 c0                	test   %eax,%eax
  802268:	74 0a                	je     802274 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80226a:	01 c3                	add    %eax,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	39 f3                	cmp    %esi,%ebx
  802270:	72 d9                	jb     80224b <readn+0x1d>
  802272:	eb 02                	jmp    802276 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802274:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802276:	83 c4 1c             	add    $0x1c,%esp
  802279:	5b                   	pop    %ebx
  80227a:	5e                   	pop    %esi
  80227b:	5f                   	pop    %edi
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    

0080227e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	53                   	push   %ebx
  802282:	83 ec 24             	sub    $0x24,%esp
  802285:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802288:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80228b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228f:	89 1c 24             	mov    %ebx,(%esp)
  802292:	e8 47 fc ff ff       	call   801ede <fd_lookup>
  802297:	85 c0                	test   %eax,%eax
  802299:	78 68                	js     802303 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80229b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022a5:	8b 00                	mov    (%eax),%eax
  8022a7:	89 04 24             	mov    %eax,(%esp)
  8022aa:	e8 80 fc ff ff       	call   801f2f <dev_lookup>
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	78 50                	js     802303 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8022ba:	75 23                	jne    8022df <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8022bc:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8022c1:	8b 40 48             	mov    0x48(%eax),%eax
  8022c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022cc:	c7 04 24 80 35 80 00 	movl   $0x803580,(%esp)
  8022d3:	e8 5b ea ff ff       	call   800d33 <cprintf>
		return -E_INVAL;
  8022d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022dd:	eb 24                	jmp    802303 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8022df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8022e5:	85 d2                	test   %edx,%edx
  8022e7:	74 15                	je     8022fe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8022e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8022ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022f7:	89 04 24             	mov    %eax,(%esp)
  8022fa:	ff d2                	call   *%edx
  8022fc:	eb 05                	jmp    802303 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8022fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802303:	83 c4 24             	add    $0x24,%esp
  802306:	5b                   	pop    %ebx
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    

00802309 <seek>:

int
seek(int fdnum, off_t offset)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80230f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802312:	89 44 24 04          	mov    %eax,0x4(%esp)
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	89 04 24             	mov    %eax,(%esp)
  80231c:	e8 bd fb ff ff       	call   801ede <fd_lookup>
  802321:	85 c0                	test   %eax,%eax
  802323:	78 0e                	js     802333 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802325:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802328:	8b 55 0c             	mov    0xc(%ebp),%edx
  80232b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80232e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    

00802335 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	53                   	push   %ebx
  802339:	83 ec 24             	sub    $0x24,%esp
  80233c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80233f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802342:	89 44 24 04          	mov    %eax,0x4(%esp)
  802346:	89 1c 24             	mov    %ebx,(%esp)
  802349:	e8 90 fb ff ff       	call   801ede <fd_lookup>
  80234e:	85 c0                	test   %eax,%eax
  802350:	78 61                	js     8023b3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802355:	89 44 24 04          	mov    %eax,0x4(%esp)
  802359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80235c:	8b 00                	mov    (%eax),%eax
  80235e:	89 04 24             	mov    %eax,(%esp)
  802361:	e8 c9 fb ff ff       	call   801f2f <dev_lookup>
  802366:	85 c0                	test   %eax,%eax
  802368:	78 49                	js     8023b3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80236a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80236d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802371:	75 23                	jne    802396 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802373:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802378:	8b 40 48             	mov    0x48(%eax),%eax
  80237b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80237f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802383:	c7 04 24 40 35 80 00 	movl   $0x803540,(%esp)
  80238a:	e8 a4 e9 ff ff       	call   800d33 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80238f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802394:	eb 1d                	jmp    8023b3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  802396:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802399:	8b 52 18             	mov    0x18(%edx),%edx
  80239c:	85 d2                	test   %edx,%edx
  80239e:	74 0e                	je     8023ae <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8023a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023a7:	89 04 24             	mov    %eax,(%esp)
  8023aa:	ff d2                	call   *%edx
  8023ac:	eb 05                	jmp    8023b3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8023ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8023b3:	83 c4 24             	add    $0x24,%esp
  8023b6:	5b                   	pop    %ebx
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    

008023b9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8023b9:	55                   	push   %ebp
  8023ba:	89 e5                	mov    %esp,%ebp
  8023bc:	53                   	push   %ebx
  8023bd:	83 ec 24             	sub    $0x24,%esp
  8023c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8023c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cd:	89 04 24             	mov    %eax,(%esp)
  8023d0:	e8 09 fb ff ff       	call   801ede <fd_lookup>
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	78 52                	js     80242b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8023d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023e3:	8b 00                	mov    (%eax),%eax
  8023e5:	89 04 24             	mov    %eax,(%esp)
  8023e8:	e8 42 fb ff ff       	call   801f2f <dev_lookup>
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 3a                	js     80242b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8023f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8023f8:	74 2c                	je     802426 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8023fa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8023fd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802404:	00 00 00 
	stat->st_isdir = 0;
  802407:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80240e:	00 00 00 
	stat->st_dev = dev;
  802411:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802417:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80241b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80241e:	89 14 24             	mov    %edx,(%esp)
  802421:	ff 50 14             	call   *0x14(%eax)
  802424:	eb 05                	jmp    80242b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802426:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80242b:	83 c4 24             	add    $0x24,%esp
  80242e:	5b                   	pop    %ebx
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    

00802431 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802431:	55                   	push   %ebp
  802432:	89 e5                	mov    %esp,%ebp
  802434:	83 ec 18             	sub    $0x18,%esp
  802437:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80243a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80243d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802444:	00 
  802445:	8b 45 08             	mov    0x8(%ebp),%eax
  802448:	89 04 24             	mov    %eax,(%esp)
  80244b:	e8 bc 01 00 00       	call   80260c <open>
  802450:	89 c3                	mov    %eax,%ebx
  802452:	85 c0                	test   %eax,%eax
  802454:	78 1b                	js     802471 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802456:	8b 45 0c             	mov    0xc(%ebp),%eax
  802459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245d:	89 1c 24             	mov    %ebx,(%esp)
  802460:	e8 54 ff ff ff       	call   8023b9 <fstat>
  802465:	89 c6                	mov    %eax,%esi
	close(fd);
  802467:	89 1c 24             	mov    %ebx,(%esp)
  80246a:	e8 be fb ff ff       	call   80202d <close>
	return r;
  80246f:	89 f3                	mov    %esi,%ebx
}
  802471:	89 d8                	mov    %ebx,%eax
  802473:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802476:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802479:	89 ec                	mov    %ebp,%esp
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	00 00                	add    %al,(%eax)
	...

00802480 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	83 ec 18             	sub    $0x18,%esp
  802486:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802489:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80248c:	89 c3                	mov    %eax,%ebx
  80248e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802490:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802497:	75 11                	jne    8024aa <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802499:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8024a0:	e8 50 f9 ff ff       	call   801df5 <ipc_find_env>
  8024a5:	a3 00 90 80 00       	mov    %eax,0x809000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8024aa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8024b1:	00 
  8024b2:	c7 44 24 08 00 a0 80 	movl   $0x80a000,0x8(%esp)
  8024b9:	00 
  8024ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024be:	a1 00 90 80 00       	mov    0x809000,%eax
  8024c3:	89 04 24             	mov    %eax,(%esp)
  8024c6:	e8 bf f8 ff ff       	call   801d8a <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8024cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024d2:	00 
  8024d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024de:	e8 41 f8 ff ff       	call   801d24 <ipc_recv>
}
  8024e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8024e6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8024e9:	89 ec                	mov    %ebp,%esp
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    

008024ed <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8024ed:	55                   	push   %ebp
  8024ee:	89 e5                	mov    %esp,%ebp
  8024f0:	53                   	push   %ebx
  8024f1:	83 ec 14             	sub    $0x14,%esp
  8024f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8024f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8024fd:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802502:	ba 00 00 00 00       	mov    $0x0,%edx
  802507:	b8 05 00 00 00       	mov    $0x5,%eax
  80250c:	e8 6f ff ff ff       	call   802480 <fsipc>
  802511:	85 c0                	test   %eax,%eax
  802513:	78 2b                	js     802540 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802515:	c7 44 24 04 00 a0 80 	movl   $0x80a000,0x4(%esp)
  80251c:	00 
  80251d:	89 1c 24             	mov    %ebx,(%esp)
  802520:	e8 56 ef ff ff       	call   80147b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802525:	a1 80 a0 80 00       	mov    0x80a080,%eax
  80252a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802530:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802535:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80253b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802540:	83 c4 14             	add    $0x14,%esp
  802543:	5b                   	pop    %ebx
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    

00802546 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
  802549:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80254c:	8b 45 08             	mov    0x8(%ebp),%eax
  80254f:	8b 40 0c             	mov    0xc(%eax),%eax
  802552:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  802557:	ba 00 00 00 00       	mov    $0x0,%edx
  80255c:	b8 06 00 00 00       	mov    $0x6,%eax
  802561:	e8 1a ff ff ff       	call   802480 <fsipc>
}
  802566:	c9                   	leave  
  802567:	c3                   	ret    

00802568 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802568:	55                   	push   %ebp
  802569:	89 e5                	mov    %esp,%ebp
  80256b:	56                   	push   %esi
  80256c:	53                   	push   %ebx
  80256d:	83 ec 10             	sub    $0x10,%esp
  802570:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802573:	8b 45 08             	mov    0x8(%ebp),%eax
  802576:	8b 40 0c             	mov    0xc(%eax),%eax
  802579:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  80257e:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802584:	ba 00 00 00 00       	mov    $0x0,%edx
  802589:	b8 03 00 00 00       	mov    $0x3,%eax
  80258e:	e8 ed fe ff ff       	call   802480 <fsipc>
  802593:	89 c3                	mov    %eax,%ebx
  802595:	85 c0                	test   %eax,%eax
  802597:	78 6a                	js     802603 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802599:	39 c6                	cmp    %eax,%esi
  80259b:	73 24                	jae    8025c1 <devfile_read+0x59>
  80259d:	c7 44 24 0c b0 35 80 	movl   $0x8035b0,0xc(%esp)
  8025a4:	00 
  8025a5:	c7 44 24 08 5d 2f 80 	movl   $0x802f5d,0x8(%esp)
  8025ac:	00 
  8025ad:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8025b4:	00 
  8025b5:	c7 04 24 b7 35 80 00 	movl   $0x8035b7,(%esp)
  8025bc:	e8 77 e6 ff ff       	call   800c38 <_panic>
	assert(r <= PGSIZE);
  8025c1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8025c6:	7e 24                	jle    8025ec <devfile_read+0x84>
  8025c8:	c7 44 24 0c c2 35 80 	movl   $0x8035c2,0xc(%esp)
  8025cf:	00 
  8025d0:	c7 44 24 08 5d 2f 80 	movl   $0x802f5d,0x8(%esp)
  8025d7:	00 
  8025d8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8025df:	00 
  8025e0:	c7 04 24 b7 35 80 00 	movl   $0x8035b7,(%esp)
  8025e7:	e8 4c e6 ff ff       	call   800c38 <_panic>
	memmove(buf, &fsipcbuf, r);
  8025ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025f0:	c7 44 24 04 00 a0 80 	movl   $0x80a000,0x4(%esp)
  8025f7:	00 
  8025f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fb:	89 04 24             	mov    %eax,(%esp)
  8025fe:	e8 69 f0 ff ff       	call   80166c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  802603:	89 d8                	mov    %ebx,%eax
  802605:	83 c4 10             	add    $0x10,%esp
  802608:	5b                   	pop    %ebx
  802609:	5e                   	pop    %esi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    

0080260c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80260c:	55                   	push   %ebp
  80260d:	89 e5                	mov    %esp,%ebp
  80260f:	56                   	push   %esi
  802610:	53                   	push   %ebx
  802611:	83 ec 20             	sub    $0x20,%esp
  802614:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802617:	89 34 24             	mov    %esi,(%esp)
  80261a:	e8 11 ee ff ff       	call   801430 <strlen>
		return -E_BAD_PATH;
  80261f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802624:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802629:	7f 5e                	jg     802689 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80262b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80262e:	89 04 24             	mov    %eax,(%esp)
  802631:	e8 35 f8 ff ff       	call   801e6b <fd_alloc>
  802636:	89 c3                	mov    %eax,%ebx
  802638:	85 c0                	test   %eax,%eax
  80263a:	78 4d                	js     802689 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80263c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802640:	c7 04 24 00 a0 80 00 	movl   $0x80a000,(%esp)
  802647:	e8 2f ee ff ff       	call   80147b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80264c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80264f:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802654:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802657:	b8 01 00 00 00       	mov    $0x1,%eax
  80265c:	e8 1f fe ff ff       	call   802480 <fsipc>
  802661:	89 c3                	mov    %eax,%ebx
  802663:	85 c0                	test   %eax,%eax
  802665:	79 15                	jns    80267c <open+0x70>
		fd_close(fd, 0);
  802667:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80266e:	00 
  80266f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802672:	89 04 24             	mov    %eax,(%esp)
  802675:	e8 21 f9 ff ff       	call   801f9b <fd_close>
		return r;
  80267a:	eb 0d                	jmp    802689 <open+0x7d>
	}

	return fd2num(fd);
  80267c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267f:	89 04 24             	mov    %eax,(%esp)
  802682:	e8 b9 f7 ff ff       	call   801e40 <fd2num>
  802687:	89 c3                	mov    %eax,%ebx
}
  802689:	89 d8                	mov    %ebx,%eax
  80268b:	83 c4 20             	add    $0x20,%esp
  80268e:	5b                   	pop    %ebx
  80268f:	5e                   	pop    %esi
  802690:	5d                   	pop    %ebp
  802691:	c3                   	ret    
	...

00802694 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802694:	55                   	push   %ebp
  802695:	89 e5                	mov    %esp,%ebp
  802697:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80269a:	89 d0                	mov    %edx,%eax
  80269c:	c1 e8 16             	shr    $0x16,%eax
  80269f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026a6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ab:	f6 c1 01             	test   $0x1,%cl
  8026ae:	74 1d                	je     8026cd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026b0:	c1 ea 0c             	shr    $0xc,%edx
  8026b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8026ba:	f6 c2 01             	test   $0x1,%dl
  8026bd:	74 0e                	je     8026cd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026bf:	c1 ea 0c             	shr    $0xc,%edx
  8026c2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026c9:	ef 
  8026ca:	0f b7 c0             	movzwl %ax,%eax
}
  8026cd:	5d                   	pop    %ebp
  8026ce:	c3                   	ret    
	...

008026d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	83 ec 18             	sub    $0x18,%esp
  8026d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8026d9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8026dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8026df:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e2:	89 04 24             	mov    %eax,(%esp)
  8026e5:	e8 66 f7 ff ff       	call   801e50 <fd2data>
  8026ea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8026ec:	c7 44 24 04 ce 35 80 	movl   $0x8035ce,0x4(%esp)
  8026f3:	00 
  8026f4:	89 34 24             	mov    %esi,(%esp)
  8026f7:	e8 7f ed ff ff       	call   80147b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8026ff:	2b 03                	sub    (%ebx),%eax
  802701:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802707:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80270e:	00 00 00 
	stat->st_dev = &devpipe;
  802711:	c7 86 88 00 00 00 64 	movl   $0x808064,0x88(%esi)
  802718:	80 80 00 
	return 0;
}
  80271b:	b8 00 00 00 00       	mov    $0x0,%eax
  802720:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802723:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802726:	89 ec                	mov    %ebp,%esp
  802728:	5d                   	pop    %ebp
  802729:	c3                   	ret    

0080272a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80272a:	55                   	push   %ebp
  80272b:	89 e5                	mov    %esp,%ebp
  80272d:	53                   	push   %ebx
  80272e:	83 ec 14             	sub    $0x14,%esp
  802731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80273f:	e8 f5 f2 ff ff       	call   801a39 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802744:	89 1c 24             	mov    %ebx,(%esp)
  802747:	e8 04 f7 ff ff       	call   801e50 <fd2data>
  80274c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802757:	e8 dd f2 ff ff       	call   801a39 <sys_page_unmap>
}
  80275c:	83 c4 14             	add    $0x14,%esp
  80275f:	5b                   	pop    %ebx
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    

00802762 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802762:	55                   	push   %ebp
  802763:	89 e5                	mov    %esp,%ebp
  802765:	57                   	push   %edi
  802766:	56                   	push   %esi
  802767:	53                   	push   %ebx
  802768:	83 ec 2c             	sub    $0x2c,%esp
  80276b:	89 c7                	mov    %eax,%edi
  80276d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802770:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802775:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802778:	89 3c 24             	mov    %edi,(%esp)
  80277b:	e8 14 ff ff ff       	call   802694 <pageref>
  802780:	89 c6                	mov    %eax,%esi
  802782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802785:	89 04 24             	mov    %eax,(%esp)
  802788:	e8 07 ff ff ff       	call   802694 <pageref>
  80278d:	39 c6                	cmp    %eax,%esi
  80278f:	0f 94 c0             	sete   %al
  802792:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802795:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  80279b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80279e:	39 cb                	cmp    %ecx,%ebx
  8027a0:	75 08                	jne    8027aa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8027a2:	83 c4 2c             	add    $0x2c,%esp
  8027a5:	5b                   	pop    %ebx
  8027a6:	5e                   	pop    %esi
  8027a7:	5f                   	pop    %edi
  8027a8:	5d                   	pop    %ebp
  8027a9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8027aa:	83 f8 01             	cmp    $0x1,%eax
  8027ad:	75 c1                	jne    802770 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8027af:	8b 52 58             	mov    0x58(%edx),%edx
  8027b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027b6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8027be:	c7 04 24 d5 35 80 00 	movl   $0x8035d5,(%esp)
  8027c5:	e8 69 e5 ff ff       	call   800d33 <cprintf>
  8027ca:	eb a4                	jmp    802770 <_pipeisclosed+0xe>

008027cc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027cc:	55                   	push   %ebp
  8027cd:	89 e5                	mov    %esp,%ebp
  8027cf:	57                   	push   %edi
  8027d0:	56                   	push   %esi
  8027d1:	53                   	push   %ebx
  8027d2:	83 ec 2c             	sub    $0x2c,%esp
  8027d5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8027d8:	89 34 24             	mov    %esi,(%esp)
  8027db:	e8 70 f6 ff ff       	call   801e50 <fd2data>
  8027e0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8027e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027eb:	75 50                	jne    80283d <devpipe_write+0x71>
  8027ed:	eb 5c                	jmp    80284b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8027ef:	89 da                	mov    %ebx,%edx
  8027f1:	89 f0                	mov    %esi,%eax
  8027f3:	e8 6a ff ff ff       	call   802762 <_pipeisclosed>
  8027f8:	85 c0                	test   %eax,%eax
  8027fa:	75 53                	jne    80284f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8027fc:	e8 4b f1 ff ff       	call   80194c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802801:	8b 43 04             	mov    0x4(%ebx),%eax
  802804:	8b 13                	mov    (%ebx),%edx
  802806:	83 c2 20             	add    $0x20,%edx
  802809:	39 d0                	cmp    %edx,%eax
  80280b:	73 e2                	jae    8027ef <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80280d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802810:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802814:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802817:	89 c2                	mov    %eax,%edx
  802819:	c1 fa 1f             	sar    $0x1f,%edx
  80281c:	c1 ea 1b             	shr    $0x1b,%edx
  80281f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802822:	83 e1 1f             	and    $0x1f,%ecx
  802825:	29 d1                	sub    %edx,%ecx
  802827:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80282b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80282f:	83 c0 01             	add    $0x1,%eax
  802832:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802835:	83 c7 01             	add    $0x1,%edi
  802838:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80283b:	74 0e                	je     80284b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80283d:	8b 43 04             	mov    0x4(%ebx),%eax
  802840:	8b 13                	mov    (%ebx),%edx
  802842:	83 c2 20             	add    $0x20,%edx
  802845:	39 d0                	cmp    %edx,%eax
  802847:	73 a6                	jae    8027ef <devpipe_write+0x23>
  802849:	eb c2                	jmp    80280d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80284b:	89 f8                	mov    %edi,%eax
  80284d:	eb 05                	jmp    802854 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80284f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802854:	83 c4 2c             	add    $0x2c,%esp
  802857:	5b                   	pop    %ebx
  802858:	5e                   	pop    %esi
  802859:	5f                   	pop    %edi
  80285a:	5d                   	pop    %ebp
  80285b:	c3                   	ret    

0080285c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80285c:	55                   	push   %ebp
  80285d:	89 e5                	mov    %esp,%ebp
  80285f:	83 ec 28             	sub    $0x28,%esp
  802862:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802865:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802868:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80286b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80286e:	89 3c 24             	mov    %edi,(%esp)
  802871:	e8 da f5 ff ff       	call   801e50 <fd2data>
  802876:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802878:	be 00 00 00 00       	mov    $0x0,%esi
  80287d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802881:	75 47                	jne    8028ca <devpipe_read+0x6e>
  802883:	eb 52                	jmp    8028d7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802885:	89 f0                	mov    %esi,%eax
  802887:	eb 5e                	jmp    8028e7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802889:	89 da                	mov    %ebx,%edx
  80288b:	89 f8                	mov    %edi,%eax
  80288d:	8d 76 00             	lea    0x0(%esi),%esi
  802890:	e8 cd fe ff ff       	call   802762 <_pipeisclosed>
  802895:	85 c0                	test   %eax,%eax
  802897:	75 49                	jne    8028e2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802899:	e8 ae f0 ff ff       	call   80194c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80289e:	8b 03                	mov    (%ebx),%eax
  8028a0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8028a3:	74 e4                	je     802889 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8028a5:	89 c2                	mov    %eax,%edx
  8028a7:	c1 fa 1f             	sar    $0x1f,%edx
  8028aa:	c1 ea 1b             	shr    $0x1b,%edx
  8028ad:	01 d0                	add    %edx,%eax
  8028af:	83 e0 1f             	and    $0x1f,%eax
  8028b2:	29 d0                	sub    %edx,%eax
  8028b4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8028b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028bc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8028bf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028c2:	83 c6 01             	add    $0x1,%esi
  8028c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8028c8:	74 0d                	je     8028d7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  8028ca:	8b 03                	mov    (%ebx),%eax
  8028cc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8028cf:	75 d4                	jne    8028a5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8028d1:	85 f6                	test   %esi,%esi
  8028d3:	75 b0                	jne    802885 <devpipe_read+0x29>
  8028d5:	eb b2                	jmp    802889 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8028d7:	89 f0                	mov    %esi,%eax
  8028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	eb 05                	jmp    8028e7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8028e2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8028e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8028ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8028ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8028f0:	89 ec                	mov    %ebp,%esp
  8028f2:	5d                   	pop    %ebp
  8028f3:	c3                   	ret    

008028f4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8028f4:	55                   	push   %ebp
  8028f5:	89 e5                	mov    %esp,%ebp
  8028f7:	83 ec 48             	sub    $0x48,%esp
  8028fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8028fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802900:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802903:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802906:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802909:	89 04 24             	mov    %eax,(%esp)
  80290c:	e8 5a f5 ff ff       	call   801e6b <fd_alloc>
  802911:	89 c3                	mov    %eax,%ebx
  802913:	85 c0                	test   %eax,%eax
  802915:	0f 88 45 01 00 00    	js     802a60 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80291b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802922:	00 
  802923:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80292a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802931:	e8 46 f0 ff ff       	call   80197c <sys_page_alloc>
  802936:	89 c3                	mov    %eax,%ebx
  802938:	85 c0                	test   %eax,%eax
  80293a:	0f 88 20 01 00 00    	js     802a60 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802940:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802943:	89 04 24             	mov    %eax,(%esp)
  802946:	e8 20 f5 ff ff       	call   801e6b <fd_alloc>
  80294b:	89 c3                	mov    %eax,%ebx
  80294d:	85 c0                	test   %eax,%eax
  80294f:	0f 88 f8 00 00 00    	js     802a4d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802955:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80295c:	00 
  80295d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802960:	89 44 24 04          	mov    %eax,0x4(%esp)
  802964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80296b:	e8 0c f0 ff ff       	call   80197c <sys_page_alloc>
  802970:	89 c3                	mov    %eax,%ebx
  802972:	85 c0                	test   %eax,%eax
  802974:	0f 88 d3 00 00 00    	js     802a4d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80297a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80297d:	89 04 24             	mov    %eax,(%esp)
  802980:	e8 cb f4 ff ff       	call   801e50 <fd2data>
  802985:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802987:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80298e:	00 
  80298f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80299a:	e8 dd ef ff ff       	call   80197c <sys_page_alloc>
  80299f:	89 c3                	mov    %eax,%ebx
  8029a1:	85 c0                	test   %eax,%eax
  8029a3:	0f 88 91 00 00 00    	js     802a3a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029ac:	89 04 24             	mov    %eax,(%esp)
  8029af:	e8 9c f4 ff ff       	call   801e50 <fd2data>
  8029b4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8029bb:	00 
  8029bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8029c7:	00 
  8029c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029d3:	e8 03 f0 ff ff       	call   8019db <sys_page_map>
  8029d8:	89 c3                	mov    %eax,%ebx
  8029da:	85 c0                	test   %eax,%eax
  8029dc:	78 4c                	js     802a2a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8029de:	8b 15 64 80 80 00    	mov    0x808064,%edx
  8029e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029e7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8029e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8029f3:	8b 15 64 80 80 00    	mov    0x808064,%edx
  8029f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029fc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8029fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a01:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a0b:	89 04 24             	mov    %eax,(%esp)
  802a0e:	e8 2d f4 ff ff       	call   801e40 <fd2num>
  802a13:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802a15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a18:	89 04 24             	mov    %eax,(%esp)
  802a1b:	e8 20 f4 ff ff       	call   801e40 <fd2num>
  802a20:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802a23:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a28:	eb 36                	jmp    802a60 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  802a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a35:	e8 ff ef ff ff       	call   801a39 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802a3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a48:	e8 ec ef ff ff       	call   801a39 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802a4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a50:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a5b:	e8 d9 ef ff ff       	call   801a39 <sys_page_unmap>
    err:
	return r;
}
  802a60:	89 d8                	mov    %ebx,%eax
  802a62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802a65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802a68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802a6b:	89 ec                	mov    %ebp,%esp
  802a6d:	5d                   	pop    %ebp
  802a6e:	c3                   	ret    

00802a6f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802a6f:	55                   	push   %ebp
  802a70:	89 e5                	mov    %esp,%ebp
  802a72:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7f:	89 04 24             	mov    %eax,(%esp)
  802a82:	e8 57 f4 ff ff       	call   801ede <fd_lookup>
  802a87:	85 c0                	test   %eax,%eax
  802a89:	78 15                	js     802aa0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a8e:	89 04 24             	mov    %eax,(%esp)
  802a91:	e8 ba f3 ff ff       	call   801e50 <fd2data>
	return _pipeisclosed(fd, p);
  802a96:	89 c2                	mov    %eax,%edx
  802a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a9b:	e8 c2 fc ff ff       	call   802762 <_pipeisclosed>
}
  802aa0:	c9                   	leave  
  802aa1:	c3                   	ret    
	...

00802ab0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ab8:	5d                   	pop    %ebp
  802ab9:	c3                   	ret    

00802aba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802aba:	55                   	push   %ebp
  802abb:	89 e5                	mov    %esp,%ebp
  802abd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802ac0:	c7 44 24 04 ed 35 80 	movl   $0x8035ed,0x4(%esp)
  802ac7:	00 
  802ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
  802acb:	89 04 24             	mov    %eax,(%esp)
  802ace:	e8 a8 e9 ff ff       	call   80147b <strcpy>
	return 0;
}
  802ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  802ad8:	c9                   	leave  
  802ad9:	c3                   	ret    

00802ada <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802ada:	55                   	push   %ebp
  802adb:	89 e5                	mov    %esp,%ebp
  802add:	57                   	push   %edi
  802ade:	56                   	push   %esi
  802adf:	53                   	push   %ebx
  802ae0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802ae6:	be 00 00 00 00       	mov    $0x0,%esi
  802aeb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802aef:	74 43                	je     802b34 <devcons_write+0x5a>
  802af1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802af6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802aff:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802b01:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802b04:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802b09:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802b0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b10:	03 45 0c             	add    0xc(%ebp),%eax
  802b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b17:	89 3c 24             	mov    %edi,(%esp)
  802b1a:	e8 4d eb ff ff       	call   80166c <memmove>
		sys_cputs(buf, m);
  802b1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b23:	89 3c 24             	mov    %edi,(%esp)
  802b26:	e8 35 ed ff ff       	call   801860 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802b2b:	01 de                	add    %ebx,%esi
  802b2d:	89 f0                	mov    %esi,%eax
  802b2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802b32:	72 c8                	jb     802afc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802b34:	89 f0                	mov    %esi,%eax
  802b36:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802b3c:	5b                   	pop    %ebx
  802b3d:	5e                   	pop    %esi
  802b3e:	5f                   	pop    %edi
  802b3f:	5d                   	pop    %ebp
  802b40:	c3                   	ret    

00802b41 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b41:	55                   	push   %ebp
  802b42:	89 e5                	mov    %esp,%ebp
  802b44:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802b47:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  802b4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802b50:	75 07                	jne    802b59 <devcons_read+0x18>
  802b52:	eb 31                	jmp    802b85 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802b54:	e8 f3 ed ff ff       	call   80194c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b60:	e8 2a ed ff ff       	call   80188f <sys_cgetc>
  802b65:	85 c0                	test   %eax,%eax
  802b67:	74 eb                	je     802b54 <devcons_read+0x13>
  802b69:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802b6b:	85 c0                	test   %eax,%eax
  802b6d:	78 16                	js     802b85 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802b6f:	83 f8 04             	cmp    $0x4,%eax
  802b72:	74 0c                	je     802b80 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b77:	88 10                	mov    %dl,(%eax)
	return 1;
  802b79:	b8 01 00 00 00       	mov    $0x1,%eax
  802b7e:	eb 05                	jmp    802b85 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802b80:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802b85:	c9                   	leave  
  802b86:	c3                   	ret    

00802b87 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802b87:	55                   	push   %ebp
  802b88:	89 e5                	mov    %esp,%ebp
  802b8a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  802b90:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802b93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802b9a:	00 
  802b9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802b9e:	89 04 24             	mov    %eax,(%esp)
  802ba1:	e8 ba ec ff ff       	call   801860 <sys_cputs>
}
  802ba6:	c9                   	leave  
  802ba7:	c3                   	ret    

00802ba8 <getchar>:

int
getchar(void)
{
  802ba8:	55                   	push   %ebp
  802ba9:	89 e5                	mov    %esp,%ebp
  802bab:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802bae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802bb5:	00 
  802bb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bc4:	e8 d5 f5 ff ff       	call   80219e <read>
	if (r < 0)
  802bc9:	85 c0                	test   %eax,%eax
  802bcb:	78 0f                	js     802bdc <getchar+0x34>
		return r;
	if (r < 1)
  802bcd:	85 c0                	test   %eax,%eax
  802bcf:	7e 06                	jle    802bd7 <getchar+0x2f>
		return -E_EOF;
	return c;
  802bd1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802bd5:	eb 05                	jmp    802bdc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802bd7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802bdc:	c9                   	leave  
  802bdd:	c3                   	ret    

00802bde <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802bde:	55                   	push   %ebp
  802bdf:	89 e5                	mov    %esp,%ebp
  802be1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802be4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802beb:	8b 45 08             	mov    0x8(%ebp),%eax
  802bee:	89 04 24             	mov    %eax,(%esp)
  802bf1:	e8 e8 f2 ff ff       	call   801ede <fd_lookup>
  802bf6:	85 c0                	test   %eax,%eax
  802bf8:	78 11                	js     802c0b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bfd:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802c03:	39 10                	cmp    %edx,(%eax)
  802c05:	0f 94 c0             	sete   %al
  802c08:	0f b6 c0             	movzbl %al,%eax
}
  802c0b:	c9                   	leave  
  802c0c:	c3                   	ret    

00802c0d <opencons>:

int
opencons(void)
{
  802c0d:	55                   	push   %ebp
  802c0e:	89 e5                	mov    %esp,%ebp
  802c10:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c16:	89 04 24             	mov    %eax,(%esp)
  802c19:	e8 4d f2 ff ff       	call   801e6b <fd_alloc>
  802c1e:	85 c0                	test   %eax,%eax
  802c20:	78 3c                	js     802c5e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802c22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802c29:	00 
  802c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c38:	e8 3f ed ff ff       	call   80197c <sys_page_alloc>
  802c3d:	85 c0                	test   %eax,%eax
  802c3f:	78 1d                	js     802c5e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802c41:	8b 15 80 80 80 00    	mov    0x808080,%edx
  802c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c4a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c4f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802c56:	89 04 24             	mov    %eax,(%esp)
  802c59:	e8 e2 f1 ff ff       	call   801e40 <fd2num>
}
  802c5e:	c9                   	leave  
  802c5f:	c3                   	ret    

00802c60 <__udivdi3>:
  802c60:	83 ec 1c             	sub    $0x1c,%esp
  802c63:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802c67:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  802c6b:	8b 44 24 20          	mov    0x20(%esp),%eax
  802c6f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802c73:	89 74 24 10          	mov    %esi,0x10(%esp)
  802c77:	8b 74 24 24          	mov    0x24(%esp),%esi
  802c7b:	85 ff                	test   %edi,%edi
  802c7d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c85:	89 cd                	mov    %ecx,%ebp
  802c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c8b:	75 33                	jne    802cc0 <__udivdi3+0x60>
  802c8d:	39 f1                	cmp    %esi,%ecx
  802c8f:	77 57                	ja     802ce8 <__udivdi3+0x88>
  802c91:	85 c9                	test   %ecx,%ecx
  802c93:	75 0b                	jne    802ca0 <__udivdi3+0x40>
  802c95:	b8 01 00 00 00       	mov    $0x1,%eax
  802c9a:	31 d2                	xor    %edx,%edx
  802c9c:	f7 f1                	div    %ecx
  802c9e:	89 c1                	mov    %eax,%ecx
  802ca0:	89 f0                	mov    %esi,%eax
  802ca2:	31 d2                	xor    %edx,%edx
  802ca4:	f7 f1                	div    %ecx
  802ca6:	89 c6                	mov    %eax,%esi
  802ca8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802cac:	f7 f1                	div    %ecx
  802cae:	89 f2                	mov    %esi,%edx
  802cb0:	8b 74 24 10          	mov    0x10(%esp),%esi
  802cb4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802cb8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802cbc:	83 c4 1c             	add    $0x1c,%esp
  802cbf:	c3                   	ret    
  802cc0:	31 d2                	xor    %edx,%edx
  802cc2:	31 c0                	xor    %eax,%eax
  802cc4:	39 f7                	cmp    %esi,%edi
  802cc6:	77 e8                	ja     802cb0 <__udivdi3+0x50>
  802cc8:	0f bd cf             	bsr    %edi,%ecx
  802ccb:	83 f1 1f             	xor    $0x1f,%ecx
  802cce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802cd2:	75 2c                	jne    802d00 <__udivdi3+0xa0>
  802cd4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802cd8:	76 04                	jbe    802cde <__udivdi3+0x7e>
  802cda:	39 f7                	cmp    %esi,%edi
  802cdc:	73 d2                	jae    802cb0 <__udivdi3+0x50>
  802cde:	31 d2                	xor    %edx,%edx
  802ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ce5:	eb c9                	jmp    802cb0 <__udivdi3+0x50>
  802ce7:	90                   	nop
  802ce8:	89 f2                	mov    %esi,%edx
  802cea:	f7 f1                	div    %ecx
  802cec:	31 d2                	xor    %edx,%edx
  802cee:	8b 74 24 10          	mov    0x10(%esp),%esi
  802cf2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802cf6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802cfa:	83 c4 1c             	add    $0x1c,%esp
  802cfd:	c3                   	ret    
  802cfe:	66 90                	xchg   %ax,%ax
  802d00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802d05:	b8 20 00 00 00       	mov    $0x20,%eax
  802d0a:	89 ea                	mov    %ebp,%edx
  802d0c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802d10:	d3 e7                	shl    %cl,%edi
  802d12:	89 c1                	mov    %eax,%ecx
  802d14:	d3 ea                	shr    %cl,%edx
  802d16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802d1b:	09 fa                	or     %edi,%edx
  802d1d:	89 f7                	mov    %esi,%edi
  802d1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802d23:	89 f2                	mov    %esi,%edx
  802d25:	8b 74 24 08          	mov    0x8(%esp),%esi
  802d29:	d3 e5                	shl    %cl,%ebp
  802d2b:	89 c1                	mov    %eax,%ecx
  802d2d:	d3 ef                	shr    %cl,%edi
  802d2f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802d34:	d3 e2                	shl    %cl,%edx
  802d36:	89 c1                	mov    %eax,%ecx
  802d38:	d3 ee                	shr    %cl,%esi
  802d3a:	09 d6                	or     %edx,%esi
  802d3c:	89 fa                	mov    %edi,%edx
  802d3e:	89 f0                	mov    %esi,%eax
  802d40:	f7 74 24 0c          	divl   0xc(%esp)
  802d44:	89 d7                	mov    %edx,%edi
  802d46:	89 c6                	mov    %eax,%esi
  802d48:	f7 e5                	mul    %ebp
  802d4a:	39 d7                	cmp    %edx,%edi
  802d4c:	72 22                	jb     802d70 <__udivdi3+0x110>
  802d4e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802d52:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802d57:	d3 e5                	shl    %cl,%ebp
  802d59:	39 c5                	cmp    %eax,%ebp
  802d5b:	73 04                	jae    802d61 <__udivdi3+0x101>
  802d5d:	39 d7                	cmp    %edx,%edi
  802d5f:	74 0f                	je     802d70 <__udivdi3+0x110>
  802d61:	89 f0                	mov    %esi,%eax
  802d63:	31 d2                	xor    %edx,%edx
  802d65:	e9 46 ff ff ff       	jmp    802cb0 <__udivdi3+0x50>
  802d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d70:	8d 46 ff             	lea    -0x1(%esi),%eax
  802d73:	31 d2                	xor    %edx,%edx
  802d75:	8b 74 24 10          	mov    0x10(%esp),%esi
  802d79:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802d7d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802d81:	83 c4 1c             	add    $0x1c,%esp
  802d84:	c3                   	ret    
	...

00802d90 <__umoddi3>:
  802d90:	83 ec 1c             	sub    $0x1c,%esp
  802d93:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802d97:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  802d9b:	8b 44 24 20          	mov    0x20(%esp),%eax
  802d9f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802da3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802da7:	8b 74 24 24          	mov    0x24(%esp),%esi
  802dab:	85 ed                	test   %ebp,%ebp
  802dad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802db1:	89 44 24 08          	mov    %eax,0x8(%esp)
  802db5:	89 cf                	mov    %ecx,%edi
  802db7:	89 04 24             	mov    %eax,(%esp)
  802dba:	89 f2                	mov    %esi,%edx
  802dbc:	75 1a                	jne    802dd8 <__umoddi3+0x48>
  802dbe:	39 f1                	cmp    %esi,%ecx
  802dc0:	76 4e                	jbe    802e10 <__umoddi3+0x80>
  802dc2:	f7 f1                	div    %ecx
  802dc4:	89 d0                	mov    %edx,%eax
  802dc6:	31 d2                	xor    %edx,%edx
  802dc8:	8b 74 24 10          	mov    0x10(%esp),%esi
  802dcc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802dd0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802dd4:	83 c4 1c             	add    $0x1c,%esp
  802dd7:	c3                   	ret    
  802dd8:	39 f5                	cmp    %esi,%ebp
  802dda:	77 54                	ja     802e30 <__umoddi3+0xa0>
  802ddc:	0f bd c5             	bsr    %ebp,%eax
  802ddf:	83 f0 1f             	xor    $0x1f,%eax
  802de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802de6:	75 60                	jne    802e48 <__umoddi3+0xb8>
  802de8:	3b 0c 24             	cmp    (%esp),%ecx
  802deb:	0f 87 07 01 00 00    	ja     802ef8 <__umoddi3+0x168>
  802df1:	89 f2                	mov    %esi,%edx
  802df3:	8b 34 24             	mov    (%esp),%esi
  802df6:	29 ce                	sub    %ecx,%esi
  802df8:	19 ea                	sbb    %ebp,%edx
  802dfa:	89 34 24             	mov    %esi,(%esp)
  802dfd:	8b 04 24             	mov    (%esp),%eax
  802e00:	8b 74 24 10          	mov    0x10(%esp),%esi
  802e04:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802e08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802e0c:	83 c4 1c             	add    $0x1c,%esp
  802e0f:	c3                   	ret    
  802e10:	85 c9                	test   %ecx,%ecx
  802e12:	75 0b                	jne    802e1f <__umoddi3+0x8f>
  802e14:	b8 01 00 00 00       	mov    $0x1,%eax
  802e19:	31 d2                	xor    %edx,%edx
  802e1b:	f7 f1                	div    %ecx
  802e1d:	89 c1                	mov    %eax,%ecx
  802e1f:	89 f0                	mov    %esi,%eax
  802e21:	31 d2                	xor    %edx,%edx
  802e23:	f7 f1                	div    %ecx
  802e25:	8b 04 24             	mov    (%esp),%eax
  802e28:	f7 f1                	div    %ecx
  802e2a:	eb 98                	jmp    802dc4 <__umoddi3+0x34>
  802e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e30:	89 f2                	mov    %esi,%edx
  802e32:	8b 74 24 10          	mov    0x10(%esp),%esi
  802e36:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802e3a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802e3e:	83 c4 1c             	add    $0x1c,%esp
  802e41:	c3                   	ret    
  802e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802e48:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e4d:	89 e8                	mov    %ebp,%eax
  802e4f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802e54:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802e58:	89 fa                	mov    %edi,%edx
  802e5a:	d3 e0                	shl    %cl,%eax
  802e5c:	89 e9                	mov    %ebp,%ecx
  802e5e:	d3 ea                	shr    %cl,%edx
  802e60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e65:	09 c2                	or     %eax,%edx
  802e67:	8b 44 24 08          	mov    0x8(%esp),%eax
  802e6b:	89 14 24             	mov    %edx,(%esp)
  802e6e:	89 f2                	mov    %esi,%edx
  802e70:	d3 e7                	shl    %cl,%edi
  802e72:	89 e9                	mov    %ebp,%ecx
  802e74:	d3 ea                	shr    %cl,%edx
  802e76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802e7f:	d3 e6                	shl    %cl,%esi
  802e81:	89 e9                	mov    %ebp,%ecx
  802e83:	d3 e8                	shr    %cl,%eax
  802e85:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e8a:	09 f0                	or     %esi,%eax
  802e8c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802e90:	f7 34 24             	divl   (%esp)
  802e93:	d3 e6                	shl    %cl,%esi
  802e95:	89 74 24 08          	mov    %esi,0x8(%esp)
  802e99:	89 d6                	mov    %edx,%esi
  802e9b:	f7 e7                	mul    %edi
  802e9d:	39 d6                	cmp    %edx,%esi
  802e9f:	89 c1                	mov    %eax,%ecx
  802ea1:	89 d7                	mov    %edx,%edi
  802ea3:	72 3f                	jb     802ee4 <__umoddi3+0x154>
  802ea5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802ea9:	72 35                	jb     802ee0 <__umoddi3+0x150>
  802eab:	8b 44 24 08          	mov    0x8(%esp),%eax
  802eaf:	29 c8                	sub    %ecx,%eax
  802eb1:	19 fe                	sbb    %edi,%esi
  802eb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802eb8:	89 f2                	mov    %esi,%edx
  802eba:	d3 e8                	shr    %cl,%eax
  802ebc:	89 e9                	mov    %ebp,%ecx
  802ebe:	d3 e2                	shl    %cl,%edx
  802ec0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802ec5:	09 d0                	or     %edx,%eax
  802ec7:	89 f2                	mov    %esi,%edx
  802ec9:	d3 ea                	shr    %cl,%edx
  802ecb:	8b 74 24 10          	mov    0x10(%esp),%esi
  802ecf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802ed3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802ed7:	83 c4 1c             	add    $0x1c,%esp
  802eda:	c3                   	ret    
  802edb:	90                   	nop
  802edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ee0:	39 d6                	cmp    %edx,%esi
  802ee2:	75 c7                	jne    802eab <__umoddi3+0x11b>
  802ee4:	89 d7                	mov    %edx,%edi
  802ee6:	89 c1                	mov    %eax,%ecx
  802ee8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  802eec:	1b 3c 24             	sbb    (%esp),%edi
  802eef:	eb ba                	jmp    802eab <__umoddi3+0x11b>
  802ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ef8:	39 f5                	cmp    %esi,%ebp
  802efa:	0f 82 f1 fe ff ff    	jb     802df1 <__umoddi3+0x61>
  802f00:	e9 f8 fe ff ff       	jmp    802dfd <__umoddi3+0x6d>
