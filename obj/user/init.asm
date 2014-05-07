
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 df 03 00 00       	call   800410 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80004b:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800050:	85 db                	test   %ebx,%ebx
  800052:	7e 15                	jle    800069 <sum+0x29>
  800054:	ba 00 00 00 00       	mov    $0x0,%edx
		tot ^= i * s[i];
  800059:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80005d:	0f af ca             	imul   %edx,%ecx
  800060:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800062:	83 c2 01             	add    $0x1,%edx
  800065:	39 da                	cmp    %ebx,%edx
  800067:	75 f0                	jne    800059 <sum+0x19>
		tot ^= i * s[i];
	return tot;
}
  800069:	5b                   	pop    %ebx
  80006a:	5e                   	pop    %esi
  80006b:	5d                   	pop    %ebp
  80006c:	c3                   	ret    

0080006d <umain>:

void
umain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	57                   	push   %edi
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800079:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80007c:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  800083:	e8 ef 04 00 00       	call   800577 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800088:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80008f:	00 
  800090:	c7 04 24 00 40 80 00 	movl   $0x804000,(%esp)
  800097:	e8 a4 ff ff ff       	call   800040 <sum>
  80009c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  8000a1:	74 1a                	je     8000bd <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  8000a3:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  8000aa:	00 
  8000ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000af:	c7 04 24 08 2d 80 00 	movl   $0x802d08,(%esp)
  8000b6:	e8 bc 04 00 00       	call   800577 <cprintf>
  8000bb:	eb 0c                	jmp    8000c9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000bd:	c7 04 24 4f 2c 80 00 	movl   $0x802c4f,(%esp)
  8000c4:	e8 ae 04 00 00       	call   800577 <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000d0:	00 
  8000d1:	c7 04 24 20 60 80 00 	movl   $0x806020,(%esp)
  8000d8:	e8 63 ff ff ff       	call   800040 <sum>
  8000dd:	85 c0                	test   %eax,%eax
  8000df:	74 12                	je     8000f3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e5:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  8000ec:	e8 86 04 00 00       	call   800577 <cprintf>
  8000f1:	eb 0c                	jmp    8000ff <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000f3:	c7 04 24 66 2c 80 00 	movl   $0x802c66,(%esp)
  8000fa:	e8 78 04 00 00       	call   800577 <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ff:	c7 44 24 04 7c 2c 80 	movl   $0x802c7c,0x4(%esp)
  800106:	00 
  800107:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010d:	89 04 24             	mov    %eax,(%esp)
  800110:	e8 d6 0b 00 00       	call   800ceb <strcat>
	for (i = 0; i < argc; i++) {
  800115:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800119:	7e 42                	jle    80015d <umain+0xf0>
  80011b:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800120:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800126:	c7 44 24 04 88 2c 80 	movl   $0x802c88,0x4(%esp)
  80012d:	00 
  80012e:	89 34 24             	mov    %esi,(%esp)
  800131:	e8 b5 0b 00 00       	call   800ceb <strcat>
		strcat(args, argv[i]);
  800136:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800139:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013d:	89 34 24             	mov    %esi,(%esp)
  800140:	e8 a6 0b 00 00       	call   800ceb <strcat>
		strcat(args, "'");
  800145:	c7 44 24 04 89 2c 80 	movl   $0x802c89,0x4(%esp)
  80014c:	00 
  80014d:	89 34 24             	mov    %esi,(%esp)
  800150:	e8 96 0b 00 00       	call   800ceb <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800155:	83 c3 01             	add    $0x1,%ebx
  800158:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80015b:	75 c9                	jne    800126 <umain+0xb9>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80015d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800163:	89 44 24 04          	mov    %eax,0x4(%esp)
  800167:	c7 04 24 8b 2c 80 00 	movl   $0x802c8b,(%esp)
  80016e:	e8 04 04 00 00       	call   800577 <cprintf>

	cprintf("init: running sh\n");
  800173:	c7 04 24 8f 2c 80 00 	movl   $0x802c8f,(%esp)
  80017a:	e8 f8 03 00 00       	call   800577 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80017f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800186:	e8 32 15 00 00       	call   8016bd <close>
	if ((r = opencons()) < 0)
  80018b:	e8 2d 02 00 00       	call   8003bd <opencons>
  800190:	85 c0                	test   %eax,%eax
  800192:	79 20                	jns    8001b4 <umain+0x147>
		panic("opencons: %e", r);
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	c7 44 24 08 a1 2c 80 	movl   $0x802ca1,0x8(%esp)
  80019f:	00 
  8001a0:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001a7:	00 
  8001a8:	c7 04 24 ae 2c 80 00 	movl   $0x802cae,(%esp)
  8001af:	e8 c8 02 00 00       	call   80047c <_panic>
	if (r != 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	74 20                	je     8001d8 <umain+0x16b>
		panic("first opencons used fd %d", r);
  8001b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bc:	c7 44 24 08 ba 2c 80 	movl   $0x802cba,0x8(%esp)
  8001c3:	00 
  8001c4:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001cb:	00 
  8001cc:	c7 04 24 ae 2c 80 00 	movl   $0x802cae,(%esp)
  8001d3:	e8 a4 02 00 00       	call   80047c <_panic>
	if ((r = dup(0, 1)) < 0)
  8001d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001df:	00 
  8001e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001e7:	e8 24 15 00 00       	call   801710 <dup>
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	79 20                	jns    800210 <umain+0x1a3>
		panic("dup: %e", r);
  8001f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f4:	c7 44 24 08 d4 2c 80 	movl   $0x802cd4,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 ae 2c 80 00 	movl   $0x802cae,(%esp)
  80020b:	e8 6c 02 00 00       	call   80047c <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  800210:	c7 04 24 dc 2c 80 00 	movl   $0x802cdc,(%esp)
  800217:	e8 5b 03 00 00       	call   800577 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  80021c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800223:	00 
  800224:	c7 44 24 04 f0 2c 80 	movl   $0x802cf0,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 ef 2c 80 00 	movl   $0x802cef,(%esp)
  800233:	e8 0c 21 00 00       	call   802344 <spawnl>
		if (r < 0) {
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1e1>
			cprintf("init: spawn sh: %e\n", r);
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	c7 04 24 f3 2c 80 00 	movl   $0x802cf3,(%esp)
  800247:	e8 2b 03 00 00       	call   800577 <cprintf>
			continue;
  80024c:	eb c2                	jmp    800210 <umain+0x1a3>
		}
		wait(r);
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	e8 5e 25 00 00       	call   8027b4 <wait>
  800256:	eb b8                	jmp    800210 <umain+0x1a3>
	...

00800260 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800270:	c7 44 24 04 73 2d 80 	movl   $0x802d73,0x4(%esp)
  800277:	00 
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 48 0a 00 00       	call   800ccb <strcpy>
	return 0;
}
  800283:	b8 00 00 00 00       	mov    $0x0,%eax
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800296:	be 00 00 00 00       	mov    $0x0,%esi
  80029b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80029f:	74 43                	je     8002e4 <devcons_write+0x5a>
  8002a1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8002a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8002ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002af:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8002b1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8002b4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8002b9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8002bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c0:	03 45 0c             	add    0xc(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	89 3c 24             	mov    %edi,(%esp)
  8002ca:	e8 ed 0b 00 00       	call   800ebc <memmove>
		sys_cputs(buf, m);
  8002cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d3:	89 3c 24             	mov    %edi,(%esp)
  8002d6:	e8 d5 0d 00 00       	call   8010b0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002db:	01 de                	add    %ebx,%esi
  8002dd:	89 f0                	mov    %esi,%eax
  8002df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8002e2:	72 c8                	jb     8002ac <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002e4:	89 f0                	mov    %esi,%eax
  8002e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8002f7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8002fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800300:	75 07                	jne    800309 <devcons_read+0x18>
  800302:	eb 31                	jmp    800335 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800304:	e8 93 0e 00 00       	call   80119c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800310:	e8 ca 0d 00 00       	call   8010df <sys_cgetc>
  800315:	85 c0                	test   %eax,%eax
  800317:	74 eb                	je     800304 <devcons_read+0x13>
  800319:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80031b:	85 c0                	test   %eax,%eax
  80031d:	78 16                	js     800335 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80031f:	83 f8 04             	cmp    $0x4,%eax
  800322:	74 0c                	je     800330 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
  800327:	88 10                	mov    %dl,(%eax)
	return 1;
  800329:	b8 01 00 00 00       	mov    $0x1,%eax
  80032e:	eb 05                	jmp    800335 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800343:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034a:	00 
  80034b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80034e:	89 04 24             	mov    %eax,(%esp)
  800351:	e8 5a 0d 00 00       	call   8010b0 <sys_cputs>
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <getchar>:

int
getchar(void)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80035e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800365:	00 
  800366:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800374:	e8 b5 14 00 00       	call   80182e <read>
	if (r < 0)
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 0f                	js     80038c <getchar+0x34>
		return r;
	if (r < 1)
  80037d:	85 c0                	test   %eax,%eax
  80037f:	7e 06                	jle    800387 <getchar+0x2f>
		return -E_EOF;
	return c;
  800381:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800385:	eb 05                	jmp    80038c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800387:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800394:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
  80039e:	89 04 24             	mov    %eax,(%esp)
  8003a1:	e8 c8 11 00 00       	call   80156e <fd_lookup>
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	78 11                	js     8003bb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8003aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ad:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003b3:	39 10                	cmp    %edx,(%eax)
  8003b5:	0f 94 c0             	sete   %al
  8003b8:	0f b6 c0             	movzbl %al,%eax
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <opencons>:

int
opencons(void)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8003c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	e8 2d 11 00 00       	call   8014fb <fd_alloc>
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	78 3c                	js     80040e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003d9:	00 
  8003da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003e8:	e8 df 0d 00 00       	call   8011cc <sys_page_alloc>
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	78 1d                	js     80040e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003f1:	8b 15 70 57 80 00    	mov    0x805770,%edx
  8003f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	e8 c2 10 00 00       	call   8014d0 <fd2num>
}
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 18             	sub    $0x18,%esp
  800416:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800419:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80041c:	8b 75 08             	mov    0x8(%ebp),%esi
  80041f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800422:	e8 45 0d 00 00       	call   80116c <sys_getenvid>
  800427:	25 ff 03 00 00       	and    $0x3ff,%eax
  80042c:	c1 e0 07             	shl    $0x7,%eax
  80042f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800434:	a3 90 77 80 00       	mov    %eax,0x807790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800439:	85 f6                	test   %esi,%esi
  80043b:	7e 07                	jle    800444 <libmain+0x34>
		binaryname = argv[0];
  80043d:	8b 03                	mov    (%ebx),%eax
  80043f:	a3 8c 57 80 00       	mov    %eax,0x80578c

	// call user main routine
	umain(argc, argv);
  800444:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800448:	89 34 24             	mov    %esi,(%esp)
  80044b:	e8 1d fc ff ff       	call   80006d <umain>

	// exit gracefully
	exit();
  800450:	e8 0b 00 00 00       	call   800460 <exit>
}
  800455:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800458:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80045b:	89 ec                	mov    %ebp,%esp
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    
	...

00800460 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800466:	e8 83 12 00 00       	call   8016ee <close_all>
	sys_env_destroy(0);
  80046b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800472:	e8 98 0c 00 00       	call   80110f <sys_env_destroy>
}
  800477:	c9                   	leave  
  800478:	c3                   	ret    
  800479:	00 00                	add    %al,(%eax)
	...

0080047c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	56                   	push   %esi
  800480:	53                   	push   %ebx
  800481:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800484:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800487:	8b 1d 8c 57 80 00    	mov    0x80578c,%ebx
  80048d:	e8 da 0c 00 00       	call   80116c <sys_getenvid>
  800492:	8b 55 0c             	mov    0xc(%ebp),%edx
  800495:	89 54 24 10          	mov    %edx,0x10(%esp)
  800499:	8b 55 08             	mov    0x8(%ebp),%edx
  80049c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a8:	c7 04 24 8c 2d 80 00 	movl   $0x802d8c,(%esp)
  8004af:	e8 c3 00 00 00       	call   800577 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	e8 53 00 00 00       	call   800516 <vcprintf>
	cprintf("\n");
  8004c3:	c7 04 24 90 32 80 00 	movl   $0x803290,(%esp)
  8004ca:	e8 a8 00 00 00       	call   800577 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004cf:	cc                   	int3   
  8004d0:	eb fd                	jmp    8004cf <_panic+0x53>
	...

008004d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	53                   	push   %ebx
  8004d8:	83 ec 14             	sub    $0x14,%esp
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004de:	8b 03                	mov    (%ebx),%eax
  8004e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004e7:	83 c0 01             	add    $0x1,%eax
  8004ea:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004f1:	75 19                	jne    80050c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004fa:	00 
  8004fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004fe:	89 04 24             	mov    %eax,(%esp)
  800501:	e8 aa 0b 00 00       	call   8010b0 <sys_cputs>
		b->idx = 0;
  800506:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80050c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800510:	83 c4 14             	add    $0x14,%esp
  800513:	5b                   	pop    %ebx
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80051f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800526:	00 00 00 
	b.cnt = 0;
  800529:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800530:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
  800536:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800541:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054b:	c7 04 24 d4 04 80 00 	movl   $0x8004d4,(%esp)
  800552:	e8 97 01 00 00       	call   8006ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800557:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800567:	89 04 24             	mov    %eax,(%esp)
  80056a:	e8 41 0b 00 00       	call   8010b0 <sys_cputs>

	return b.cnt;
}
  80056f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80057d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	8b 45 08             	mov    0x8(%ebp),%eax
  800587:	89 04 24             	mov    %eax,(%esp)
  80058a:	e8 87 ff ff ff       	call   800516 <vcprintf>
	va_end(ap);

	return cnt;
}
  80058f:	c9                   	leave  
  800590:	c3                   	ret    
  800591:	00 00                	add    %al,(%eax)
	...

00800594 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	53                   	push   %ebx
  80059a:	83 ec 3c             	sub    $0x3c,%esp
  80059d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a0:	89 d7                	mov    %edx,%edi
  8005a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005b1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005bc:	72 11                	jb     8005cf <printnum+0x3b>
  8005be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005c4:	76 09                	jbe    8005cf <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005c6:	83 eb 01             	sub    $0x1,%ebx
  8005c9:	85 db                	test   %ebx,%ebx
  8005cb:	7f 51                	jg     80061e <printnum+0x8a>
  8005cd:	eb 5e                	jmp    80062d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005d3:	83 eb 01             	sub    $0x1,%ebx
  8005d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005da:	8b 45 10             	mov    0x10(%ebp),%eax
  8005dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005e5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005f0:	00 
  8005f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fe:	e8 7d 23 00 00       	call   802980 <__udivdi3>
  800603:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800607:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800612:	89 fa                	mov    %edi,%edx
  800614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800617:	e8 78 ff ff ff       	call   800594 <printnum>
  80061c:	eb 0f                	jmp    80062d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80061e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800622:	89 34 24             	mov    %esi,(%esp)
  800625:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800628:	83 eb 01             	sub    $0x1,%ebx
  80062b:	75 f1                	jne    80061e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80062d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800631:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800635:	8b 45 10             	mov    0x10(%ebp),%eax
  800638:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800643:	00 
  800644:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800651:	e8 5a 24 00 00       	call   802ab0 <__umoddi3>
  800656:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065a:	0f be 80 af 2d 80 00 	movsbl 0x802daf(%eax),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800667:	83 c4 3c             	add    $0x3c,%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800672:	83 fa 01             	cmp    $0x1,%edx
  800675:	7e 0e                	jle    800685 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800677:	8b 10                	mov    (%eax),%edx
  800679:	8d 4a 08             	lea    0x8(%edx),%ecx
  80067c:	89 08                	mov    %ecx,(%eax)
  80067e:	8b 02                	mov    (%edx),%eax
  800680:	8b 52 04             	mov    0x4(%edx),%edx
  800683:	eb 22                	jmp    8006a7 <getuint+0x38>
	else if (lflag)
  800685:	85 d2                	test   %edx,%edx
  800687:	74 10                	je     800699 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068e:	89 08                	mov    %ecx,(%eax)
  800690:	8b 02                	mov    (%edx),%eax
  800692:	ba 00 00 00 00       	mov    $0x0,%edx
  800697:	eb 0e                	jmp    8006a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069e:	89 08                	mov    %ecx,(%eax)
  8006a0:	8b 02                	mov    (%edx),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b8:	73 0a                	jae    8006c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bd:	88 0a                	mov    %cl,(%edx)
  8006bf:	83 c2 01             	add    $0x1,%edx
  8006c2:	89 10                	mov    %edx,(%eax)
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 02 00 00 00       	call   8006ee <vprintfmt>
	va_end(ap);
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	57                   	push   %edi
  8006f2:	56                   	push   %esi
  8006f3:	53                   	push   %ebx
  8006f4:	83 ec 5c             	sub    $0x5c,%esp
  8006f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fa:	8b 75 10             	mov    0x10(%ebp),%esi
  8006fd:	eb 12                	jmp    800711 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 84 e4 04 00 00    	je     800beb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800707:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800711:	0f b6 06             	movzbl (%esi),%eax
  800714:	83 c6 01             	add    $0x1,%esi
  800717:	83 f8 25             	cmp    $0x25,%eax
  80071a:	75 e3                	jne    8006ff <vprintfmt+0x11>
  80071c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800720:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800727:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80072c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80073b:	eb 2b                	jmp    800768 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800740:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800744:	eb 22                	jmp    800768 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800749:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80074d:	eb 19                	jmp    800768 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800752:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800759:	eb 0d                	jmp    800768 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80075b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80075e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800761:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800768:	0f b6 06             	movzbl (%esi),%eax
  80076b:	0f b6 d0             	movzbl %al,%edx
  80076e:	8d 7e 01             	lea    0x1(%esi),%edi
  800771:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800774:	83 e8 23             	sub    $0x23,%eax
  800777:	3c 55                	cmp    $0x55,%al
  800779:	0f 87 46 04 00 00    	ja     800bc5 <vprintfmt+0x4d7>
  80077f:	0f b6 c0             	movzbl %al,%eax
  800782:	ff 24 85 00 2f 80 00 	jmp    *0x802f00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800789:	83 ea 30             	sub    $0x30,%edx
  80078c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80078f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800793:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800796:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800799:	83 fa 09             	cmp    $0x9,%edx
  80079c:	77 4a                	ja     8007e8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007a1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8007a4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8007a7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8007ab:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007ae:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007b1:	83 fa 09             	cmp    $0x9,%edx
  8007b4:	76 eb                	jbe    8007a1 <vprintfmt+0xb3>
  8007b6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8007b9:	eb 2d                	jmp    8007e8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 50 04             	lea    0x4(%eax),%edx
  8007c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c4:	8b 00                	mov    (%eax),%eax
  8007c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007cc:	eb 1a                	jmp    8007e8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007d1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007d5:	79 91                	jns    800768 <vprintfmt+0x7a>
  8007d7:	e9 73 ff ff ff       	jmp    80074f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007df:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007e6:	eb 80                	jmp    800768 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007e8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007ec:	0f 89 76 ff ff ff    	jns    800768 <vprintfmt+0x7a>
  8007f2:	e9 64 ff ff ff       	jmp    80075b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007fd:	e9 66 ff ff ff       	jmp    800768 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8d 50 04             	lea    0x4(%eax),%edx
  800808:	89 55 14             	mov    %edx,0x14(%ebp)
  80080b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800817:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80081a:	e9 f2 fe ff ff       	jmp    800711 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80081f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800823:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800826:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80082a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80082d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800831:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800834:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800837:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80083b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80083e:	80 f9 09             	cmp    $0x9,%cl
  800841:	77 1d                	ja     800860 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800843:	0f be c0             	movsbl %al,%eax
  800846:	6b c0 64             	imul   $0x64,%eax,%eax
  800849:	0f be d2             	movsbl %dl,%edx
  80084c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80084f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800856:	a3 90 57 80 00       	mov    %eax,0x805790
  80085b:	e9 b1 fe ff ff       	jmp    800711 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800860:	c7 44 24 04 c7 2d 80 	movl   $0x802dc7,0x4(%esp)
  800867:	00 
  800868:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 18 05 00 00       	call   800d8b <strcmp>
  800873:	85 c0                	test   %eax,%eax
  800875:	75 0f                	jne    800886 <vprintfmt+0x198>
  800877:	c7 05 90 57 80 00 04 	movl   $0x4,0x805790
  80087e:	00 00 00 
  800881:	e9 8b fe ff ff       	jmp    800711 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800886:	c7 44 24 04 cb 2d 80 	movl   $0x802dcb,0x4(%esp)
  80088d:	00 
  80088e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800891:	89 14 24             	mov    %edx,(%esp)
  800894:	e8 f2 04 00 00       	call   800d8b <strcmp>
  800899:	85 c0                	test   %eax,%eax
  80089b:	75 0f                	jne    8008ac <vprintfmt+0x1be>
  80089d:	c7 05 90 57 80 00 02 	movl   $0x2,0x805790
  8008a4:	00 00 00 
  8008a7:	e9 65 fe ff ff       	jmp    800711 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8008ac:	c7 44 24 04 cf 2d 80 	movl   $0x802dcf,0x4(%esp)
  8008b3:	00 
  8008b4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8008b7:	89 0c 24             	mov    %ecx,(%esp)
  8008ba:	e8 cc 04 00 00       	call   800d8b <strcmp>
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	75 0f                	jne    8008d2 <vprintfmt+0x1e4>
  8008c3:	c7 05 90 57 80 00 01 	movl   $0x1,0x805790
  8008ca:	00 00 00 
  8008cd:	e9 3f fe ff ff       	jmp    800711 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008d2:	c7 44 24 04 d3 2d 80 	movl   $0x802dd3,0x4(%esp)
  8008d9:	00 
  8008da:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008dd:	89 3c 24             	mov    %edi,(%esp)
  8008e0:	e8 a6 04 00 00       	call   800d8b <strcmp>
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	75 0f                	jne    8008f8 <vprintfmt+0x20a>
  8008e9:	c7 05 90 57 80 00 06 	movl   $0x6,0x805790
  8008f0:	00 00 00 
  8008f3:	e9 19 fe ff ff       	jmp    800711 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008f8:	c7 44 24 04 d7 2d 80 	movl   $0x802dd7,0x4(%esp)
  8008ff:	00 
  800900:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 80 04 00 00       	call   800d8b <strcmp>
  80090b:	85 c0                	test   %eax,%eax
  80090d:	75 0f                	jne    80091e <vprintfmt+0x230>
  80090f:	c7 05 90 57 80 00 07 	movl   $0x7,0x805790
  800916:	00 00 00 
  800919:	e9 f3 fd ff ff       	jmp    800711 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80091e:	c7 44 24 04 db 2d 80 	movl   $0x802ddb,0x4(%esp)
  800925:	00 
  800926:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800929:	89 14 24             	mov    %edx,(%esp)
  80092c:	e8 5a 04 00 00       	call   800d8b <strcmp>
  800931:	83 f8 01             	cmp    $0x1,%eax
  800934:	19 c0                	sbb    %eax,%eax
  800936:	f7 d0                	not    %eax
  800938:	83 c0 08             	add    $0x8,%eax
  80093b:	a3 90 57 80 00       	mov    %eax,0x805790
  800940:	e9 cc fd ff ff       	jmp    800711 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800945:	8b 45 14             	mov    0x14(%ebp),%eax
  800948:	8d 50 04             	lea    0x4(%eax),%edx
  80094b:	89 55 14             	mov    %edx,0x14(%ebp)
  80094e:	8b 00                	mov    (%eax),%eax
  800950:	89 c2                	mov    %eax,%edx
  800952:	c1 fa 1f             	sar    $0x1f,%edx
  800955:	31 d0                	xor    %edx,%eax
  800957:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800959:	83 f8 0f             	cmp    $0xf,%eax
  80095c:	7f 0b                	jg     800969 <vprintfmt+0x27b>
  80095e:	8b 14 85 60 30 80 00 	mov    0x803060(,%eax,4),%edx
  800965:	85 d2                	test   %edx,%edx
  800967:	75 23                	jne    80098c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800969:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096d:	c7 44 24 08 df 2d 80 	movl   $0x802ddf,0x8(%esp)
  800974:	00 
  800975:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800979:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097c:	89 3c 24             	mov    %edi,(%esp)
  80097f:	e8 42 fd ff ff       	call   8006c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800984:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800987:	e9 85 fd ff ff       	jmp    800711 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80098c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800990:	c7 44 24 08 91 31 80 	movl   $0x803191,0x8(%esp)
  800997:	00 
  800998:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099f:	89 3c 24             	mov    %edi,(%esp)
  8009a2:	e8 1f fd ff ff       	call   8006c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009aa:	e9 62 fd ff ff       	jmp    800711 <vprintfmt+0x23>
  8009af:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8009b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8d 50 04             	lea    0x4(%eax),%edx
  8009be:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009c3:	85 f6                	test   %esi,%esi
  8009c5:	b8 c0 2d 80 00       	mov    $0x802dc0,%eax
  8009ca:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009cd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009d1:	7e 06                	jle    8009d9 <vprintfmt+0x2eb>
  8009d3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009d7:	75 13                	jne    8009ec <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d9:	0f be 06             	movsbl (%esi),%eax
  8009dc:	83 c6 01             	add    $0x1,%esi
  8009df:	85 c0                	test   %eax,%eax
  8009e1:	0f 85 94 00 00 00    	jne    800a7b <vprintfmt+0x38d>
  8009e7:	e9 81 00 00 00       	jmp    800a6d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f0:	89 34 24             	mov    %esi,(%esp)
  8009f3:	e8 a3 02 00 00       	call   800c9b <strnlen>
  8009f8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009fb:	29 c2                	sub    %eax,%edx
  8009fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800a00:	85 d2                	test   %edx,%edx
  800a02:	7e d5                	jle    8009d9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800a04:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800a08:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800a0b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800a0e:	89 d6                	mov    %edx,%esi
  800a10:	89 cf                	mov    %ecx,%edi
  800a12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a16:	89 3c 24             	mov    %edi,(%esp)
  800a19:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a1c:	83 ee 01             	sub    $0x1,%esi
  800a1f:	75 f1                	jne    800a12 <vprintfmt+0x324>
  800a21:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a24:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a27:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a2a:	eb ad                	jmp    8009d9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a2c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a30:	74 1b                	je     800a4d <vprintfmt+0x35f>
  800a32:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a35:	83 fa 5e             	cmp    $0x5e,%edx
  800a38:	76 13                	jbe    800a4d <vprintfmt+0x35f>
					putch('?', putdat);
  800a3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a41:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a48:	ff 55 08             	call   *0x8(%ebp)
  800a4b:	eb 0d                	jmp    800a5a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a4d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a50:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a54:	89 04 24             	mov    %eax,(%esp)
  800a57:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5a:	83 eb 01             	sub    $0x1,%ebx
  800a5d:	0f be 06             	movsbl (%esi),%eax
  800a60:	83 c6 01             	add    $0x1,%esi
  800a63:	85 c0                	test   %eax,%eax
  800a65:	75 1a                	jne    800a81 <vprintfmt+0x393>
  800a67:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a6a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a70:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a74:	7f 1c                	jg     800a92 <vprintfmt+0x3a4>
  800a76:	e9 96 fc ff ff       	jmp    800711 <vprintfmt+0x23>
  800a7b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a7e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a81:	85 ff                	test   %edi,%edi
  800a83:	78 a7                	js     800a2c <vprintfmt+0x33e>
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	79 a2                	jns    800a2c <vprintfmt+0x33e>
  800a8a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a8d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a90:	eb db                	jmp    800a6d <vprintfmt+0x37f>
  800a92:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a95:	89 de                	mov    %ebx,%esi
  800a97:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800aa5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aa7:	83 eb 01             	sub    $0x1,%ebx
  800aaa:	75 ee                	jne    800a9a <vprintfmt+0x3ac>
  800aac:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ab1:	e9 5b fc ff ff       	jmp    800711 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ab6:	83 f9 01             	cmp    $0x1,%ecx
  800ab9:	7e 10                	jle    800acb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800abb:	8b 45 14             	mov    0x14(%ebp),%eax
  800abe:	8d 50 08             	lea    0x8(%eax),%edx
  800ac1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac4:	8b 30                	mov    (%eax),%esi
  800ac6:	8b 78 04             	mov    0x4(%eax),%edi
  800ac9:	eb 26                	jmp    800af1 <vprintfmt+0x403>
	else if (lflag)
  800acb:	85 c9                	test   %ecx,%ecx
  800acd:	74 12                	je     800ae1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800acf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad2:	8d 50 04             	lea    0x4(%eax),%edx
  800ad5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad8:	8b 30                	mov    (%eax),%esi
  800ada:	89 f7                	mov    %esi,%edi
  800adc:	c1 ff 1f             	sar    $0x1f,%edi
  800adf:	eb 10                	jmp    800af1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800ae1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae4:	8d 50 04             	lea    0x4(%eax),%edx
  800ae7:	89 55 14             	mov    %edx,0x14(%ebp)
  800aea:	8b 30                	mov    (%eax),%esi
  800aec:	89 f7                	mov    %esi,%edi
  800aee:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800af1:	85 ff                	test   %edi,%edi
  800af3:	78 0e                	js     800b03 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800af5:	89 f0                	mov    %esi,%eax
  800af7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800af9:	be 0a 00 00 00       	mov    $0xa,%esi
  800afe:	e9 84 00 00 00       	jmp    800b87 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800b03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b07:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b0e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b11:	89 f0                	mov    %esi,%eax
  800b13:	89 fa                	mov    %edi,%edx
  800b15:	f7 d8                	neg    %eax
  800b17:	83 d2 00             	adc    $0x0,%edx
  800b1a:	f7 da                	neg    %edx
			}
			base = 10;
  800b1c:	be 0a 00 00 00       	mov    $0xa,%esi
  800b21:	eb 64                	jmp    800b87 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b23:	89 ca                	mov    %ecx,%edx
  800b25:	8d 45 14             	lea    0x14(%ebp),%eax
  800b28:	e8 42 fb ff ff       	call   80066f <getuint>
			base = 10;
  800b2d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b32:	eb 53                	jmp    800b87 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b34:	89 ca                	mov    %ecx,%edx
  800b36:	8d 45 14             	lea    0x14(%ebp),%eax
  800b39:	e8 31 fb ff ff       	call   80066f <getuint>
    			base = 8;
  800b3e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b43:	eb 42                	jmp    800b87 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b49:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b50:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b57:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b5e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b61:	8b 45 14             	mov    0x14(%ebp),%eax
  800b64:	8d 50 04             	lea    0x4(%eax),%edx
  800b67:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b6a:	8b 00                	mov    (%eax),%eax
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b71:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b76:	eb 0f                	jmp    800b87 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b78:	89 ca                	mov    %ecx,%edx
  800b7a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b7d:	e8 ed fa ff ff       	call   80066f <getuint>
			base = 16;
  800b82:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b87:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b8b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b8f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b92:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b96:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b9a:	89 04 24             	mov    %eax,(%esp)
  800b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ba1:	89 da                	mov    %ebx,%edx
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba6:	e8 e9 f9 ff ff       	call   800594 <printnum>
			break;
  800bab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800bae:	e9 5e fb ff ff       	jmp    800711 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb7:	89 14 24             	mov    %edx,(%esp)
  800bba:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bbd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bc0:	e9 4c fb ff ff       	jmp    800711 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bc9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bd0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bd3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bd7:	0f 84 34 fb ff ff    	je     800711 <vprintfmt+0x23>
  800bdd:	83 ee 01             	sub    $0x1,%esi
  800be0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800be4:	75 f7                	jne    800bdd <vprintfmt+0x4ef>
  800be6:	e9 26 fb ff ff       	jmp    800711 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800beb:	83 c4 5c             	add    $0x5c,%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 28             	sub    $0x28,%esp
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c02:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c06:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	74 30                	je     800c44 <vsnprintf+0x51>
  800c14:	85 d2                	test   %edx,%edx
  800c16:	7e 2c                	jle    800c44 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c18:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c22:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c26:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2d:	c7 04 24 a9 06 80 00 	movl   $0x8006a9,(%esp)
  800c34:	e8 b5 fa ff ff       	call   8006ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c3c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c42:	eb 05                	jmp    800c49 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c51:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c58:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	89 04 24             	mov    %eax,(%esp)
  800c6c:	e8 82 ff ff ff       	call   800bf3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    
	...

00800c80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c86:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c8e:	74 09                	je     800c99 <strlen+0x19>
		n++;
  800c90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c97:	75 f7                	jne    800c90 <strlen+0x10>
		n++;
	return n;
}
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  800caa:	85 c9                	test   %ecx,%ecx
  800cac:	74 1a                	je     800cc8 <strnlen+0x2d>
  800cae:	80 3b 00             	cmpb   $0x0,(%ebx)
  800cb1:	74 15                	je     800cc8 <strnlen+0x2d>
  800cb3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800cb8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cba:	39 ca                	cmp    %ecx,%edx
  800cbc:	74 0a                	je     800cc8 <strnlen+0x2d>
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800cc6:	75 f0                	jne    800cb8 <strnlen+0x1d>
		n++;
	return n;
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	53                   	push   %ebx
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cda:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cde:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ce1:	83 c2 01             	add    $0x1,%edx
  800ce4:	84 c9                	test   %cl,%cl
  800ce6:	75 f2                	jne    800cda <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	83 ec 08             	sub    $0x8,%esp
  800cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf5:	89 1c 24             	mov    %ebx,(%esp)
  800cf8:	e8 83 ff ff ff       	call   800c80 <strlen>
	strcpy(dst + len, src);
  800cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d00:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d04:	01 d8                	add    %ebx,%eax
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	e8 bd ff ff ff       	call   800ccb <strcpy>
	return dst;
}
  800d0e:	89 d8                	mov    %ebx,%eax
  800d10:	83 c4 08             	add    $0x8,%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d21:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d24:	85 f6                	test   %esi,%esi
  800d26:	74 18                	je     800d40 <strncpy+0x2a>
  800d28:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d2d:	0f b6 1a             	movzbl (%edx),%ebx
  800d30:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d33:	80 3a 01             	cmpb   $0x1,(%edx)
  800d36:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d39:	83 c1 01             	add    $0x1,%ecx
  800d3c:	39 f1                	cmp    %esi,%ecx
  800d3e:	75 ed                	jne    800d2d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d50:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d53:	89 f8                	mov    %edi,%eax
  800d55:	85 f6                	test   %esi,%esi
  800d57:	74 2b                	je     800d84 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d59:	83 fe 01             	cmp    $0x1,%esi
  800d5c:	74 23                	je     800d81 <strlcpy+0x3d>
  800d5e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d61:	84 c9                	test   %cl,%cl
  800d63:	74 1c                	je     800d81 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d65:	83 ee 02             	sub    $0x2,%esi
  800d68:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d6d:	88 08                	mov    %cl,(%eax)
  800d6f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d72:	39 f2                	cmp    %esi,%edx
  800d74:	74 0b                	je     800d81 <strlcpy+0x3d>
  800d76:	83 c2 01             	add    $0x1,%edx
  800d79:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d7d:	84 c9                	test   %cl,%cl
  800d7f:	75 ec                	jne    800d6d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d81:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d84:	29 f8                	sub    %edi,%eax
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d94:	0f b6 01             	movzbl (%ecx),%eax
  800d97:	84 c0                	test   %al,%al
  800d99:	74 16                	je     800db1 <strcmp+0x26>
  800d9b:	3a 02                	cmp    (%edx),%al
  800d9d:	75 12                	jne    800db1 <strcmp+0x26>
		p++, q++;
  800d9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800da2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800da6:	84 c0                	test   %al,%al
  800da8:	74 07                	je     800db1 <strcmp+0x26>
  800daa:	83 c1 01             	add    $0x1,%ecx
  800dad:	3a 02                	cmp    (%edx),%al
  800daf:	74 ee                	je     800d9f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800db1:	0f b6 c0             	movzbl %al,%eax
  800db4:	0f b6 12             	movzbl (%edx),%edx
  800db7:	29 d0                	sub    %edx,%eax
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	53                   	push   %ebx
  800dbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcd:	85 d2                	test   %edx,%edx
  800dcf:	74 28                	je     800df9 <strncmp+0x3e>
  800dd1:	0f b6 01             	movzbl (%ecx),%eax
  800dd4:	84 c0                	test   %al,%al
  800dd6:	74 24                	je     800dfc <strncmp+0x41>
  800dd8:	3a 03                	cmp    (%ebx),%al
  800dda:	75 20                	jne    800dfc <strncmp+0x41>
  800ddc:	83 ea 01             	sub    $0x1,%edx
  800ddf:	74 13                	je     800df4 <strncmp+0x39>
		n--, p++, q++;
  800de1:	83 c1 01             	add    $0x1,%ecx
  800de4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800de7:	0f b6 01             	movzbl (%ecx),%eax
  800dea:	84 c0                	test   %al,%al
  800dec:	74 0e                	je     800dfc <strncmp+0x41>
  800dee:	3a 03                	cmp    (%ebx),%al
  800df0:	74 ea                	je     800ddc <strncmp+0x21>
  800df2:	eb 08                	jmp    800dfc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800df9:	5b                   	pop    %ebx
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfc:	0f b6 01             	movzbl (%ecx),%eax
  800dff:	0f b6 13             	movzbl (%ebx),%edx
  800e02:	29 d0                	sub    %edx,%eax
  800e04:	eb f3                	jmp    800df9 <strncmp+0x3e>

00800e06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e10:	0f b6 10             	movzbl (%eax),%edx
  800e13:	84 d2                	test   %dl,%dl
  800e15:	74 1c                	je     800e33 <strchr+0x2d>
		if (*s == c)
  800e17:	38 ca                	cmp    %cl,%dl
  800e19:	75 09                	jne    800e24 <strchr+0x1e>
  800e1b:	eb 1b                	jmp    800e38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e1d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800e20:	38 ca                	cmp    %cl,%dl
  800e22:	74 14                	je     800e38 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e24:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800e28:	84 d2                	test   %dl,%dl
  800e2a:	75 f1                	jne    800e1d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	eb 05                	jmp    800e38 <strchr+0x32>
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e44:	0f b6 10             	movzbl (%eax),%edx
  800e47:	84 d2                	test   %dl,%dl
  800e49:	74 14                	je     800e5f <strfind+0x25>
		if (*s == c)
  800e4b:	38 ca                	cmp    %cl,%dl
  800e4d:	75 06                	jne    800e55 <strfind+0x1b>
  800e4f:	eb 0e                	jmp    800e5f <strfind+0x25>
  800e51:	38 ca                	cmp    %cl,%dl
  800e53:	74 0a                	je     800e5f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e55:	83 c0 01             	add    $0x1,%eax
  800e58:	0f b6 10             	movzbl (%eax),%edx
  800e5b:	84 d2                	test   %dl,%dl
  800e5d:	75 f2                	jne    800e51 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e79:	85 c9                	test   %ecx,%ecx
  800e7b:	74 30                	je     800ead <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e83:	75 25                	jne    800eaa <memset+0x49>
  800e85:	f6 c1 03             	test   $0x3,%cl
  800e88:	75 20                	jne    800eaa <memset+0x49>
		c &= 0xFF;
  800e8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e8d:	89 d3                	mov    %edx,%ebx
  800e8f:	c1 e3 08             	shl    $0x8,%ebx
  800e92:	89 d6                	mov    %edx,%esi
  800e94:	c1 e6 18             	shl    $0x18,%esi
  800e97:	89 d0                	mov    %edx,%eax
  800e99:	c1 e0 10             	shl    $0x10,%eax
  800e9c:	09 f0                	or     %esi,%eax
  800e9e:	09 d0                	or     %edx,%eax
  800ea0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ea2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ea5:	fc                   	cld    
  800ea6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea8:	eb 03                	jmp    800ead <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eaa:	fc                   	cld    
  800eab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb8:	89 ec                	mov    %ebp,%esp
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ece:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed1:	39 c6                	cmp    %eax,%esi
  800ed3:	73 36                	jae    800f0b <memmove+0x4f>
  800ed5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed8:	39 d0                	cmp    %edx,%eax
  800eda:	73 2f                	jae    800f0b <memmove+0x4f>
		s += n;
		d += n;
  800edc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edf:	f6 c2 03             	test   $0x3,%dl
  800ee2:	75 1b                	jne    800eff <memmove+0x43>
  800ee4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eea:	75 13                	jne    800eff <memmove+0x43>
  800eec:	f6 c1 03             	test   $0x3,%cl
  800eef:	75 0e                	jne    800eff <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef1:	83 ef 04             	sub    $0x4,%edi
  800ef4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ef7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800efa:	fd                   	std    
  800efb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800efd:	eb 09                	jmp    800f08 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eff:	83 ef 01             	sub    $0x1,%edi
  800f02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f05:	fd                   	std    
  800f06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f08:	fc                   	cld    
  800f09:	eb 20                	jmp    800f2b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f11:	75 13                	jne    800f26 <memmove+0x6a>
  800f13:	a8 03                	test   $0x3,%al
  800f15:	75 0f                	jne    800f26 <memmove+0x6a>
  800f17:	f6 c1 03             	test   $0x3,%cl
  800f1a:	75 0a                	jne    800f26 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f1c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f1f:	89 c7                	mov    %eax,%edi
  800f21:	fc                   	cld    
  800f22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f24:	eb 05                	jmp    800f2b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f26:	89 c7                	mov    %eax,%edi
  800f28:	fc                   	cld    
  800f29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f31:	89 ec                	mov    %ebp,%esp
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	89 04 24             	mov    %eax,(%esp)
  800f4f:	e8 68 ff ff ff       	call   800ebc <memmove>
}
  800f54:	c9                   	leave  
  800f55:	c3                   	ret    

00800f56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f62:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f65:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f6a:	85 ff                	test   %edi,%edi
  800f6c:	74 37                	je     800fa5 <memcmp+0x4f>
		if (*s1 != *s2)
  800f6e:	0f b6 03             	movzbl (%ebx),%eax
  800f71:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f74:	83 ef 01             	sub    $0x1,%edi
  800f77:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f7c:	38 c8                	cmp    %cl,%al
  800f7e:	74 1c                	je     800f9c <memcmp+0x46>
  800f80:	eb 10                	jmp    800f92 <memcmp+0x3c>
  800f82:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f87:	83 c2 01             	add    $0x1,%edx
  800f8a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f8e:	38 c8                	cmp    %cl,%al
  800f90:	74 0a                	je     800f9c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f92:	0f b6 c0             	movzbl %al,%eax
  800f95:	0f b6 c9             	movzbl %cl,%ecx
  800f98:	29 c8                	sub    %ecx,%eax
  800f9a:	eb 09                	jmp    800fa5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9c:	39 fa                	cmp    %edi,%edx
  800f9e:	75 e2                	jne    800f82 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fb0:	89 c2                	mov    %eax,%edx
  800fb2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fb5:	39 d0                	cmp    %edx,%eax
  800fb7:	73 19                	jae    800fd2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800fbd:	38 08                	cmp    %cl,(%eax)
  800fbf:	75 06                	jne    800fc7 <memfind+0x1d>
  800fc1:	eb 0f                	jmp    800fd2 <memfind+0x28>
  800fc3:	38 08                	cmp    %cl,(%eax)
  800fc5:	74 0b                	je     800fd2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fc7:	83 c0 01             	add    $0x1,%eax
  800fca:	39 d0                	cmp    %edx,%eax
  800fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	75 f1                	jne    800fc3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fe0:	0f b6 02             	movzbl (%edx),%eax
  800fe3:	3c 20                	cmp    $0x20,%al
  800fe5:	74 04                	je     800feb <strtol+0x17>
  800fe7:	3c 09                	cmp    $0x9,%al
  800fe9:	75 0e                	jne    800ff9 <strtol+0x25>
		s++;
  800feb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fee:	0f b6 02             	movzbl (%edx),%eax
  800ff1:	3c 20                	cmp    $0x20,%al
  800ff3:	74 f6                	je     800feb <strtol+0x17>
  800ff5:	3c 09                	cmp    $0x9,%al
  800ff7:	74 f2                	je     800feb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ff9:	3c 2b                	cmp    $0x2b,%al
  800ffb:	75 0a                	jne    801007 <strtol+0x33>
		s++;
  800ffd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801000:	bf 00 00 00 00       	mov    $0x0,%edi
  801005:	eb 10                	jmp    801017 <strtol+0x43>
  801007:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80100c:	3c 2d                	cmp    $0x2d,%al
  80100e:	75 07                	jne    801017 <strtol+0x43>
		s++, neg = 1;
  801010:	83 c2 01             	add    $0x1,%edx
  801013:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801017:	85 db                	test   %ebx,%ebx
  801019:	0f 94 c0             	sete   %al
  80101c:	74 05                	je     801023 <strtol+0x4f>
  80101e:	83 fb 10             	cmp    $0x10,%ebx
  801021:	75 15                	jne    801038 <strtol+0x64>
  801023:	80 3a 30             	cmpb   $0x30,(%edx)
  801026:	75 10                	jne    801038 <strtol+0x64>
  801028:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80102c:	75 0a                	jne    801038 <strtol+0x64>
		s += 2, base = 16;
  80102e:	83 c2 02             	add    $0x2,%edx
  801031:	bb 10 00 00 00       	mov    $0x10,%ebx
  801036:	eb 13                	jmp    80104b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801038:	84 c0                	test   %al,%al
  80103a:	74 0f                	je     80104b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80103c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801041:	80 3a 30             	cmpb   $0x30,(%edx)
  801044:	75 05                	jne    80104b <strtol+0x77>
		s++, base = 8;
  801046:	83 c2 01             	add    $0x1,%edx
  801049:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80104b:	b8 00 00 00 00       	mov    $0x0,%eax
  801050:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801052:	0f b6 0a             	movzbl (%edx),%ecx
  801055:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801058:	80 fb 09             	cmp    $0x9,%bl
  80105b:	77 08                	ja     801065 <strtol+0x91>
			dig = *s - '0';
  80105d:	0f be c9             	movsbl %cl,%ecx
  801060:	83 e9 30             	sub    $0x30,%ecx
  801063:	eb 1e                	jmp    801083 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801065:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801068:	80 fb 19             	cmp    $0x19,%bl
  80106b:	77 08                	ja     801075 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80106d:	0f be c9             	movsbl %cl,%ecx
  801070:	83 e9 57             	sub    $0x57,%ecx
  801073:	eb 0e                	jmp    801083 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801075:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801078:	80 fb 19             	cmp    $0x19,%bl
  80107b:	77 14                	ja     801091 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80107d:	0f be c9             	movsbl %cl,%ecx
  801080:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801083:	39 f1                	cmp    %esi,%ecx
  801085:	7d 0e                	jge    801095 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801087:	83 c2 01             	add    $0x1,%edx
  80108a:	0f af c6             	imul   %esi,%eax
  80108d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80108f:	eb c1                	jmp    801052 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801091:	89 c1                	mov    %eax,%ecx
  801093:	eb 02                	jmp    801097 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801095:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801097:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80109b:	74 05                	je     8010a2 <strtol+0xce>
		*endptr = (char *) s;
  80109d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010a0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010a2:	89 ca                	mov    %ecx,%edx
  8010a4:	f7 da                	neg    %edx
  8010a6:	85 ff                	test   %edi,%edi
  8010a8:	0f 45 c2             	cmovne %edx,%eax
}
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	89 c6                	mov    %eax,%esi
  8010d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010db:	89 ec                	mov    %ebp,%esp
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_cgetc>:

int
sys_cgetc(void)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f8:	89 d1                	mov    %edx,%ecx
  8010fa:	89 d3                	mov    %edx,%ebx
  8010fc:	89 d7                	mov    %edx,%edi
  8010fe:	89 d6                	mov    %edx,%esi
  801100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801102:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801105:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801108:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80110b:	89 ec                	mov    %ebp,%esp
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 38             	sub    $0x38,%esp
  801115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80111b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801123:	b8 03 00 00 00       	mov    $0x3,%eax
  801128:	8b 55 08             	mov    0x8(%ebp),%edx
  80112b:	89 cb                	mov    %ecx,%ebx
  80112d:	89 cf                	mov    %ecx,%edi
  80112f:	89 ce                	mov    %ecx,%esi
  801131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 28                	jle    80115f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801142:	00 
  801143:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  80114a:	00 
  80114b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  80115a:	e8 1d f3 ff ff       	call   80047c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80115f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801162:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801165:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801168:	89 ec                	mov    %ebp,%esp
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801175:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801178:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117b:	ba 00 00 00 00       	mov    $0x0,%edx
  801180:	b8 02 00 00 00       	mov    $0x2,%eax
  801185:	89 d1                	mov    %edx,%ecx
  801187:	89 d3                	mov    %edx,%ebx
  801189:	89 d7                	mov    %edx,%edi
  80118b:	89 d6                	mov    %edx,%esi
  80118d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80118f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801192:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801198:	89 ec                	mov    %ebp,%esp
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sys_yield>:

void
sys_yield(void)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011b5:	89 d1                	mov    %edx,%ecx
  8011b7:	89 d3                	mov    %edx,%ebx
  8011b9:	89 d7                	mov    %edx,%edi
  8011bb:	89 d6                	mov    %edx,%esi
  8011bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011c8:	89 ec                	mov    %ebp,%esp
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	83 ec 38             	sub    $0x38,%esp
  8011d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011db:	be 00 00 00 00       	mov    $0x0,%esi
  8011e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8011e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ee:	89 f7                	mov    %esi,%edi
  8011f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	7e 28                	jle    80121e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801201:	00 
  801202:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  801219:	e8 5e f2 ff ff       	call   80047c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80121e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801221:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801224:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801227:	89 ec                	mov    %ebp,%esp
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 38             	sub    $0x38,%esp
  801231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801237:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123a:	b8 05 00 00 00       	mov    $0x5,%eax
  80123f:	8b 75 18             	mov    0x18(%ebp),%esi
  801242:	8b 7d 14             	mov    0x14(%ebp),%edi
  801245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124b:	8b 55 08             	mov    0x8(%ebp),%edx
  80124e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801250:	85 c0                	test   %eax,%eax
  801252:	7e 28                	jle    80127c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801254:	89 44 24 10          	mov    %eax,0x10(%esp)
  801258:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80125f:	00 
  801260:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  801277:	e8 00 f2 ff ff       	call   80047c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80127c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80127f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801285:	89 ec                	mov    %ebp,%esp
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 38             	sub    $0x38,%esp
  80128f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801292:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801295:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129d:	b8 06 00 00 00       	mov    $0x6,%eax
  8012a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a8:	89 df                	mov    %ebx,%edi
  8012aa:	89 de                	mov    %ebx,%esi
  8012ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	7e 28                	jle    8012da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8012bd:	00 
  8012be:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  8012c5:	00 
  8012c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012cd:	00 
  8012ce:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  8012d5:	e8 a2 f1 ff ff       	call   80047c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012e3:	89 ec                	mov    %ebp,%esp
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	83 ec 38             	sub    $0x38,%esp
  8012ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801303:	8b 55 08             	mov    0x8(%ebp),%edx
  801306:	89 df                	mov    %ebx,%edi
  801308:	89 de                	mov    %ebx,%esi
  80130a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80130c:	85 c0                	test   %eax,%eax
  80130e:	7e 28                	jle    801338 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801310:	89 44 24 10          	mov    %eax,0x10(%esp)
  801314:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80131b:	00 
  80131c:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  801323:	00 
  801324:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80132b:	00 
  80132c:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  801333:	e8 44 f1 ff ff       	call   80047c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801338:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80133b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80133e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801341:	89 ec                	mov    %ebp,%esp
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 38             	sub    $0x38,%esp
  80134b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80134e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801351:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801354:	bb 00 00 00 00       	mov    $0x0,%ebx
  801359:	b8 09 00 00 00       	mov    $0x9,%eax
  80135e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801361:	8b 55 08             	mov    0x8(%ebp),%edx
  801364:	89 df                	mov    %ebx,%edi
  801366:	89 de                	mov    %ebx,%esi
  801368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	7e 28                	jle    801396 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801372:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801379:	00 
  80137a:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  801381:	00 
  801382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801389:	00 
  80138a:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  801391:	e8 e6 f0 ff ff       	call   80047c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801396:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801399:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80139c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80139f:	89 ec                	mov    %ebp,%esp
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 38             	sub    $0x38,%esp
  8013a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8013bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c2:	89 df                	mov    %ebx,%edi
  8013c4:	89 de                	mov    %ebx,%esi
  8013c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	7e 28                	jle    8013f4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8013d7:	00 
  8013d8:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  8013df:	00 
  8013e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013e7:	00 
  8013e8:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  8013ef:	e8 88 f0 ff ff       	call   80047c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013fd:	89 ec                	mov    %ebp,%esp
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80140a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80140d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801410:	be 00 00 00 00       	mov    $0x0,%esi
  801415:	b8 0c 00 00 00       	mov    $0xc,%eax
  80141a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80141d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801420:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801423:	8b 55 08             	mov    0x8(%ebp),%edx
  801426:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801428:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80142b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80142e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801431:	89 ec                	mov    %ebp,%esp
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    

00801435 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 38             	sub    $0x38,%esp
  80143b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80143e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801441:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801444:	b9 00 00 00 00       	mov    $0x0,%ecx
  801449:	b8 0d 00 00 00       	mov    $0xd,%eax
  80144e:	8b 55 08             	mov    0x8(%ebp),%edx
  801451:	89 cb                	mov    %ecx,%ebx
  801453:	89 cf                	mov    %ecx,%edi
  801455:	89 ce                	mov    %ecx,%esi
  801457:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801459:	85 c0                	test   %eax,%eax
  80145b:	7e 28                	jle    801485 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80145d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801461:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801468:	00 
  801469:	c7 44 24 08 bf 30 80 	movl   $0x8030bf,0x8(%esp)
  801470:	00 
  801471:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801478:	00 
  801479:	c7 04 24 dc 30 80 00 	movl   $0x8030dc,(%esp)
  801480:	e8 f7 ef ff ff       	call   80047c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801485:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801488:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80148b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80148e:	89 ec                	mov    %ebp,%esp
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80149b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80149e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014a6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ae:	89 cb                	mov    %ecx,%ebx
  8014b0:	89 cf                	mov    %ecx,%edi
  8014b2:	89 ce                	mov    %ecx,%esi
  8014b4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8014b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014bf:	89 ec                	mov    %ebp,%esp
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    
	...

008014d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014db:	c1 e8 0c             	shr    $0xc,%eax
}
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	89 04 24             	mov    %eax,(%esp)
  8014ec:	e8 df ff ff ff       	call   8014d0 <fd2num>
  8014f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801502:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801507:	a8 01                	test   $0x1,%al
  801509:	74 34                	je     80153f <fd_alloc+0x44>
  80150b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801510:	a8 01                	test   $0x1,%al
  801512:	74 32                	je     801546 <fd_alloc+0x4b>
  801514:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801519:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	c1 ea 16             	shr    $0x16,%edx
  801520:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801527:	f6 c2 01             	test   $0x1,%dl
  80152a:	74 1f                	je     80154b <fd_alloc+0x50>
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	c1 ea 0c             	shr    $0xc,%edx
  801531:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801538:	f6 c2 01             	test   $0x1,%dl
  80153b:	75 17                	jne    801554 <fd_alloc+0x59>
  80153d:	eb 0c                	jmp    80154b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80153f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801544:	eb 05                	jmp    80154b <fd_alloc+0x50>
  801546:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80154b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80154d:	b8 00 00 00 00       	mov    $0x0,%eax
  801552:	eb 17                	jmp    80156b <fd_alloc+0x70>
  801554:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801559:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80155e:	75 b9                	jne    801519 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801560:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801566:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80156b:	5b                   	pop    %ebx
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801579:	83 fa 1f             	cmp    $0x1f,%edx
  80157c:	77 3f                	ja     8015bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80157e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801584:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801587:	89 d0                	mov    %edx,%eax
  801589:	c1 e8 16             	shr    $0x16,%eax
  80158c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801593:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801598:	f6 c1 01             	test   $0x1,%cl
  80159b:	74 20                	je     8015bd <fd_lookup+0x4f>
  80159d:	89 d0                	mov    %edx,%eax
  80159f:	c1 e8 0c             	shr    $0xc,%eax
  8015a2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015ae:	f6 c1 01             	test   $0x1,%cl
  8015b1:	74 0a                	je     8015bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8015b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    

008015bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 14             	sub    $0x14,%esp
  8015c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8015d1:	39 0d 94 57 80 00    	cmp    %ecx,0x805794
  8015d7:	75 17                	jne    8015f0 <dev_lookup+0x31>
  8015d9:	eb 07                	jmp    8015e2 <dev_lookup+0x23>
  8015db:	39 0a                	cmp    %ecx,(%edx)
  8015dd:	75 11                	jne    8015f0 <dev_lookup+0x31>
  8015df:	90                   	nop
  8015e0:	eb 05                	jmp    8015e7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015e2:	ba 94 57 80 00       	mov    $0x805794,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8015e7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8015e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ee:	eb 35                	jmp    801625 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015f0:	83 c0 01             	add    $0x1,%eax
  8015f3:	8b 14 85 68 31 80 00 	mov    0x803168(,%eax,4),%edx
  8015fa:	85 d2                	test   %edx,%edx
  8015fc:	75 dd                	jne    8015db <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015fe:	a1 90 77 80 00       	mov    0x807790,%eax
  801603:	8b 40 48             	mov    0x48(%eax),%eax
  801606:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80160a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160e:	c7 04 24 ec 30 80 00 	movl   $0x8030ec,(%esp)
  801615:	e8 5d ef ff ff       	call   800577 <cprintf>
	*dev = 0;
  80161a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801620:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801625:	83 c4 14             	add    $0x14,%esp
  801628:	5b                   	pop    %ebx
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 38             	sub    $0x38,%esp
  801631:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801634:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801637:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80163a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80163d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801641:	89 3c 24             	mov    %edi,(%esp)
  801644:	e8 87 fe ff ff       	call   8014d0 <fd2num>
  801649:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80164c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	e8 16 ff ff ff       	call   80156e <fd_lookup>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 05                	js     801663 <fd_close+0x38>
	    || fd != fd2)
  80165e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801661:	74 0e                	je     801671 <fd_close+0x46>
		return (must_exist ? r : 0);
  801663:	89 f0                	mov    %esi,%eax
  801665:	84 c0                	test   %al,%al
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
  80166c:	0f 44 d8             	cmove  %eax,%ebx
  80166f:	eb 3d                	jmp    8016ae <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801671:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801674:	89 44 24 04          	mov    %eax,0x4(%esp)
  801678:	8b 07                	mov    (%edi),%eax
  80167a:	89 04 24             	mov    %eax,(%esp)
  80167d:	e8 3d ff ff ff       	call   8015bf <dev_lookup>
  801682:	89 c3                	mov    %eax,%ebx
  801684:	85 c0                	test   %eax,%eax
  801686:	78 16                	js     80169e <fd_close+0x73>
		if (dev->dev_close)
  801688:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80168b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80168e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801693:	85 c0                	test   %eax,%eax
  801695:	74 07                	je     80169e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801697:	89 3c 24             	mov    %edi,(%esp)
  80169a:	ff d0                	call   *%eax
  80169c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80169e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8016a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a9:	e8 db fb ff ff       	call   801289 <sys_page_unmap>
	return r;
}
  8016ae:	89 d8                	mov    %ebx,%eax
  8016b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016b9:	89 ec                	mov    %ebp,%esp
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	89 04 24             	mov    %eax,(%esp)
  8016d0:	e8 99 fe ff ff       	call   80156e <fd_lookup>
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 13                	js     8016ec <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016e0:	00 
  8016e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e4:	89 04 24             	mov    %eax,(%esp)
  8016e7:	e8 3f ff ff ff       	call   80162b <fd_close>
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <close_all>:

void
close_all(void)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016fa:	89 1c 24             	mov    %ebx,(%esp)
  8016fd:	e8 bb ff ff ff       	call   8016bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801702:	83 c3 01             	add    $0x1,%ebx
  801705:	83 fb 20             	cmp    $0x20,%ebx
  801708:	75 f0                	jne    8016fa <close_all+0xc>
		close(i);
}
  80170a:	83 c4 14             	add    $0x14,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 58             	sub    $0x58,%esp
  801716:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801719:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80171c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80171f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801722:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	89 04 24             	mov    %eax,(%esp)
  80172f:	e8 3a fe ff ff       	call   80156e <fd_lookup>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	85 c0                	test   %eax,%eax
  801738:	0f 88 e1 00 00 00    	js     80181f <dup+0x10f>
		return r;
	close(newfdnum);
  80173e:	89 3c 24             	mov    %edi,(%esp)
  801741:	e8 77 ff ff ff       	call   8016bd <close>

	newfd = INDEX2FD(newfdnum);
  801746:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80174c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80174f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 86 fd ff ff       	call   8014e0 <fd2data>
  80175a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80175c:	89 34 24             	mov    %esi,(%esp)
  80175f:	e8 7c fd ff ff       	call   8014e0 <fd2data>
  801764:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801767:	89 d8                	mov    %ebx,%eax
  801769:	c1 e8 16             	shr    $0x16,%eax
  80176c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801773:	a8 01                	test   $0x1,%al
  801775:	74 46                	je     8017bd <dup+0xad>
  801777:	89 d8                	mov    %ebx,%eax
  801779:	c1 e8 0c             	shr    $0xc,%eax
  80177c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801783:	f6 c2 01             	test   $0x1,%dl
  801786:	74 35                	je     8017bd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801788:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80178f:	25 07 0e 00 00       	and    $0xe07,%eax
  801794:	89 44 24 10          	mov    %eax,0x10(%esp)
  801798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80179b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80179f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017a6:	00 
  8017a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b2:	e8 74 fa ff ff       	call   80122b <sys_page_map>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 3b                	js     8017f8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	c1 ea 0c             	shr    $0xc,%edx
  8017c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017e1:	00 
  8017e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ed:	e8 39 fa ff ff       	call   80122b <sys_page_map>
  8017f2:	89 c3                	mov    %eax,%ebx
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	79 25                	jns    80181d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801803:	e8 81 fa ff ff       	call   801289 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801808:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80180b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801816:	e8 6e fa ff ff       	call   801289 <sys_page_unmap>
	return r;
  80181b:	eb 02                	jmp    80181f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80181d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80181f:	89 d8                	mov    %ebx,%eax
  801821:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801824:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801827:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80182a:	89 ec                	mov    %ebp,%esp
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	53                   	push   %ebx
  801832:	83 ec 24             	sub    $0x24,%esp
  801835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	89 1c 24             	mov    %ebx,(%esp)
  801842:	e8 27 fd ff ff       	call   80156e <fd_lookup>
  801847:	85 c0                	test   %eax,%eax
  801849:	78 6d                	js     8018b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801855:	8b 00                	mov    (%eax),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 60 fd ff ff       	call   8015bf <dev_lookup>
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 55                	js     8018b8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801866:	8b 50 08             	mov    0x8(%eax),%edx
  801869:	83 e2 03             	and    $0x3,%edx
  80186c:	83 fa 01             	cmp    $0x1,%edx
  80186f:	75 23                	jne    801894 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801871:	a1 90 77 80 00       	mov    0x807790,%eax
  801876:	8b 40 48             	mov    0x48(%eax),%eax
  801879:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80187d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801881:	c7 04 24 2d 31 80 00 	movl   $0x80312d,(%esp)
  801888:	e8 ea ec ff ff       	call   800577 <cprintf>
		return -E_INVAL;
  80188d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801892:	eb 24                	jmp    8018b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801894:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801897:	8b 52 08             	mov    0x8(%edx),%edx
  80189a:	85 d2                	test   %edx,%edx
  80189c:	74 15                	je     8018b3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80189e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ac:	89 04 24             	mov    %eax,(%esp)
  8018af:	ff d2                	call   *%edx
  8018b1:	eb 05                	jmp    8018b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8018b8:	83 c4 24             	add    $0x24,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	57                   	push   %edi
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 1c             	sub    $0x1c,%esp
  8018c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d2:	85 f6                	test   %esi,%esi
  8018d4:	74 30                	je     801906 <readn+0x48>
  8018d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018db:	89 f2                	mov    %esi,%edx
  8018dd:	29 c2                	sub    %eax,%edx
  8018df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8018e3:	03 45 0c             	add    0xc(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	89 3c 24             	mov    %edi,(%esp)
  8018ed:	e8 3c ff ff ff       	call   80182e <read>
		if (m < 0)
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 10                	js     801906 <readn+0x48>
			return m;
		if (m == 0)
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	74 0a                	je     801904 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018fa:	01 c3                	add    %eax,%ebx
  8018fc:	89 d8                	mov    %ebx,%eax
  8018fe:	39 f3                	cmp    %esi,%ebx
  801900:	72 d9                	jb     8018db <readn+0x1d>
  801902:	eb 02                	jmp    801906 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801904:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801906:	83 c4 1c             	add    $0x1c,%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 24             	sub    $0x24,%esp
  801915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801918:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191f:	89 1c 24             	mov    %ebx,(%esp)
  801922:	e8 47 fc ff ff       	call   80156e <fd_lookup>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 68                	js     801993 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801935:	8b 00                	mov    (%eax),%eax
  801937:	89 04 24             	mov    %eax,(%esp)
  80193a:	e8 80 fc ff ff       	call   8015bf <dev_lookup>
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 50                	js     801993 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801946:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80194a:	75 23                	jne    80196f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80194c:	a1 90 77 80 00       	mov    0x807790,%eax
  801951:	8b 40 48             	mov    0x48(%eax),%eax
  801954:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195c:	c7 04 24 49 31 80 00 	movl   $0x803149,(%esp)
  801963:	e8 0f ec ff ff       	call   800577 <cprintf>
		return -E_INVAL;
  801968:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80196d:	eb 24                	jmp    801993 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80196f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801972:	8b 52 0c             	mov    0xc(%edx),%edx
  801975:	85 d2                	test   %edx,%edx
  801977:	74 15                	je     80198e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801979:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80197c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801983:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801987:	89 04 24             	mov    %eax,(%esp)
  80198a:	ff d2                	call   *%edx
  80198c:	eb 05                	jmp    801993 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80198e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801993:	83 c4 24             	add    $0x24,%esp
  801996:	5b                   	pop    %ebx
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <seek>:

int
seek(int fdnum, off_t offset)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80199f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	89 04 24             	mov    %eax,(%esp)
  8019ac:	e8 bd fb ff ff       	call   80156e <fd_lookup>
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 0e                	js     8019c3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019bb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 24             	sub    $0x24,%esp
  8019cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d6:	89 1c 24             	mov    %ebx,(%esp)
  8019d9:	e8 90 fb ff ff       	call   80156e <fd_lookup>
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 61                	js     801a43 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ec:	8b 00                	mov    (%eax),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 c9 fb ff ff       	call   8015bf <dev_lookup>
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 49                	js     801a43 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a01:	75 23                	jne    801a26 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a03:	a1 90 77 80 00       	mov    0x807790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a08:	8b 40 48             	mov    0x48(%eax),%eax
  801a0b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a13:	c7 04 24 0c 31 80 00 	movl   $0x80310c,(%esp)
  801a1a:	e8 58 eb ff ff       	call   800577 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a24:	eb 1d                	jmp    801a43 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a29:	8b 52 18             	mov    0x18(%edx),%edx
  801a2c:	85 d2                	test   %edx,%edx
  801a2e:	74 0e                	je     801a3e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	ff d2                	call   *%edx
  801a3c:	eb 05                	jmp    801a43 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a43:	83 c4 24             	add    $0x24,%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 24             	sub    $0x24,%esp
  801a50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 09 fb ff ff       	call   80156e <fd_lookup>
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 52                	js     801abb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a73:	8b 00                	mov    (%eax),%eax
  801a75:	89 04 24             	mov    %eax,(%esp)
  801a78:	e8 42 fb ff ff       	call   8015bf <dev_lookup>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 3a                	js     801abb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a84:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a88:	74 2c                	je     801ab6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a8a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a8d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a94:	00 00 00 
	stat->st_isdir = 0;
  801a97:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9e:	00 00 00 
	stat->st_dev = dev;
  801aa1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aa7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aae:	89 14 24             	mov    %edx,(%esp)
  801ab1:	ff 50 14             	call   *0x14(%eax)
  801ab4:	eb 05                	jmp    801abb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ab6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801abb:	83 c4 24             	add    $0x24,%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 18             	sub    $0x18,%esp
  801ac7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801aca:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801acd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ad4:	00 
  801ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad8:	89 04 24             	mov    %eax,(%esp)
  801adb:	e8 bc 01 00 00       	call   801c9c <open>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 1b                	js     801b01 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aed:	89 1c 24             	mov    %ebx,(%esp)
  801af0:	e8 54 ff ff ff       	call   801a49 <fstat>
  801af5:	89 c6                	mov    %eax,%esi
	close(fd);
  801af7:	89 1c 24             	mov    %ebx,(%esp)
  801afa:	e8 be fb ff ff       	call   8016bd <close>
	return r;
  801aff:	89 f3                	mov    %esi,%ebx
}
  801b01:	89 d8                	mov    %ebx,%eax
  801b03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b09:	89 ec                	mov    %ebp,%esp
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    
  801b0d:	00 00                	add    %al,(%eax)
	...

00801b10 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 18             	sub    $0x18,%esp
  801b16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b20:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b27:	75 11                	jne    801b3a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b30:	e8 bc 0d 00 00       	call   8028f1 <ipc_find_env>
  801b35:	a3 00 60 80 00       	mov    %eax,0x806000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b3a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b41:	00 
  801b42:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  801b49:	00 
  801b4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b4e:	a1 00 60 80 00       	mov    0x806000,%eax
  801b53:	89 04 24             	mov    %eax,(%esp)
  801b56:	e8 2b 0d 00 00       	call   802886 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801b5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b62:	00 
  801b63:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6e:	e8 ad 0c 00 00       	call   802820 <ipc_recv>
}
  801b73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b79:	89 ec                	mov    %ebp,%esp
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	53                   	push   %ebx
  801b81:	83 ec 14             	sub    $0x14,%esp
  801b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8d:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b92:	ba 00 00 00 00       	mov    $0x0,%edx
  801b97:	b8 05 00 00 00       	mov    $0x5,%eax
  801b9c:	e8 6f ff ff ff       	call   801b10 <fsipc>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 2b                	js     801bd0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ba5:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801bac:	00 
  801bad:	89 1c 24             	mov    %ebx,(%esp)
  801bb0:	e8 16 f1 ff ff       	call   800ccb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bb5:	a1 80 80 80 00       	mov    0x808080,%eax
  801bba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bc0:	a1 84 80 80 00       	mov    0x808084,%eax
  801bc5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd0:	83 c4 14             	add    $0x14,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	8b 40 0c             	mov    0xc(%eax),%eax
  801be2:	a3 00 80 80 00       	mov    %eax,0x808000
	return fsipc(FSREQ_FLUSH, NULL);
  801be7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bec:	b8 06 00 00 00       	mov    $0x6,%eax
  801bf1:	e8 1a ff ff ff       	call   801b10 <fsipc>
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 10             	sub    $0x10,%esp
  801c00:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c03:	8b 45 08             	mov    0x8(%ebp),%eax
  801c06:	8b 40 0c             	mov    0xc(%eax),%eax
  801c09:	a3 00 80 80 00       	mov    %eax,0x808000
	fsipcbuf.read.req_n = n;
  801c0e:	89 35 04 80 80 00    	mov    %esi,0x808004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c14:	ba 00 00 00 00       	mov    $0x0,%edx
  801c19:	b8 03 00 00 00       	mov    $0x3,%eax
  801c1e:	e8 ed fe ff ff       	call   801b10 <fsipc>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 6a                	js     801c93 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c29:	39 c6                	cmp    %eax,%esi
  801c2b:	73 24                	jae    801c51 <devfile_read+0x59>
  801c2d:	c7 44 24 0c 78 31 80 	movl   $0x803178,0xc(%esp)
  801c34:	00 
  801c35:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801c3c:	00 
  801c3d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801c44:	00 
  801c45:	c7 04 24 94 31 80 00 	movl   $0x803194,(%esp)
  801c4c:	e8 2b e8 ff ff       	call   80047c <_panic>
	assert(r <= PGSIZE);
  801c51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c56:	7e 24                	jle    801c7c <devfile_read+0x84>
  801c58:	c7 44 24 0c 9f 31 80 	movl   $0x80319f,0xc(%esp)
  801c5f:	00 
  801c60:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801c67:	00 
  801c68:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c6f:	00 
  801c70:	c7 04 24 94 31 80 00 	movl   $0x803194,(%esp)
  801c77:	e8 00 e8 ff ff       	call   80047c <_panic>
	memmove(buf, &fsipcbuf, r);
  801c7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c80:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801c87:	00 
  801c88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8b:	89 04 24             	mov    %eax,(%esp)
  801c8e:	e8 29 f2 ff ff       	call   800ebc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801c93:	89 d8                	mov    %ebx,%eax
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	56                   	push   %esi
  801ca0:	53                   	push   %ebx
  801ca1:	83 ec 20             	sub    $0x20,%esp
  801ca4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ca7:	89 34 24             	mov    %esi,(%esp)
  801caa:	e8 d1 ef ff ff       	call   800c80 <strlen>
		return -E_BAD_PATH;
  801caf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cb9:	7f 5e                	jg     801d19 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	89 04 24             	mov    %eax,(%esp)
  801cc1:	e8 35 f8 ff ff       	call   8014fb <fd_alloc>
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	78 4d                	js     801d19 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ccc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd0:	c7 04 24 00 80 80 00 	movl   $0x808000,(%esp)
  801cd7:	e8 ef ef ff ff       	call   800ccb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdf:	a3 00 84 80 00       	mov    %eax,0x808400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cec:	e8 1f fe ff ff       	call   801b10 <fsipc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	79 15                	jns    801d0c <open+0x70>
		fd_close(fd, 0);
  801cf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cfe:	00 
  801cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d02:	89 04 24             	mov    %eax,(%esp)
  801d05:	e8 21 f9 ff ff       	call   80162b <fd_close>
		return r;
  801d0a:	eb 0d                	jmp    801d19 <open+0x7d>
	}

	return fd2num(fd);
  801d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0f:	89 04 24             	mov    %eax,(%esp)
  801d12:	e8 b9 f7 ff ff       	call   8014d0 <fd2num>
  801d17:	89 c3                	mov    %eax,%ebx
}
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	83 c4 20             	add    $0x20,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
	...

00801d24 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	57                   	push   %edi
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801d30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d37:	00 
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	89 04 24             	mov    %eax,(%esp)
  801d3e:	e8 59 ff ff ff       	call   801c9c <open>
  801d43:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	0f 88 c9 05 00 00    	js     80231a <spawn+0x5f6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801d51:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801d58:	00 
  801d59:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d63:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d69:	89 04 24             	mov    %eax,(%esp)
  801d6c:	e8 4d fb ff ff       	call   8018be <readn>
  801d71:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d76:	75 0c                	jne    801d84 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801d78:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d7f:	45 4c 46 
  801d82:	74 3b                	je     801dbf <spawn+0x9b>
		close(fd);
  801d84:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d8a:	89 04 24             	mov    %eax,(%esp)
  801d8d:	e8 2b f9 ff ff       	call   8016bd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d92:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801d99:	46 
  801d9a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801da0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da4:	c7 04 24 ab 31 80 00 	movl   $0x8031ab,(%esp)
  801dab:	e8 c7 e7 ff ff       	call   800577 <cprintf>
		return -E_NOT_EXEC;
  801db0:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801db7:	ff ff ff 
  801dba:	e9 67 05 00 00       	jmp    802326 <spawn+0x602>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801dbf:	ba 07 00 00 00       	mov    $0x7,%edx
  801dc4:	89 d0                	mov    %edx,%eax
  801dc6:	cd 30                	int    $0x30
  801dc8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801dce:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 4a 05 00 00    	js     802326 <spawn+0x602>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ddc:	89 c6                	mov    %eax,%esi
  801dde:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801de4:	c1 e6 07             	shl    $0x7,%esi
  801de7:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801ded:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801df3:	b9 11 00 00 00       	mov    $0x11,%ecx
  801df8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801dfa:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801e00:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e09:	8b 02                	mov    (%edx),%eax
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	74 5f                	je     801e6e <spawn+0x14a>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  801e14:	be 00 00 00 00       	mov    $0x0,%esi
  801e19:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  801e1b:	89 04 24             	mov    %eax,(%esp)
  801e1e:	e8 5d ee ff ff       	call   800c80 <strlen>
  801e23:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e27:	83 c6 01             	add    $0x1,%esi
  801e2a:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801e2c:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e33:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801e36:	85 c0                	test   %eax,%eax
  801e38:	75 e1                	jne    801e1b <spawn+0xf7>
  801e3a:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801e40:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e46:	bf 00 10 40 00       	mov    $0x401000,%edi
  801e4b:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e4d:	89 f8                	mov    %edi,%eax
  801e4f:	83 e0 fc             	and    $0xfffffffc,%eax
  801e52:	f7 d2                	not    %edx
  801e54:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801e57:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801e5d:	89 d0                	mov    %edx,%eax
  801e5f:	83 e8 08             	sub    $0x8,%eax
  801e62:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801e67:	77 2d                	ja     801e96 <spawn+0x172>
  801e69:	e9 c9 04 00 00       	jmp    802337 <spawn+0x613>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e6e:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801e75:	00 00 00 
  801e78:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801e7f:	00 00 00 
  801e82:	be 00 00 00 00       	mov    $0x0,%esi
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e87:	c7 85 94 fd ff ff fc 	movl   $0x400ffc,-0x26c(%ebp)
  801e8e:	0f 40 00 
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e91:	bf 00 10 40 00       	mov    $0x401000,%edi
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e96:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e9d:	00 
  801e9e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ea5:	00 
  801ea6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ead:	e8 1a f3 ff ff       	call   8011cc <sys_page_alloc>
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	0f 88 82 04 00 00    	js     80233c <spawn+0x618>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801eba:	85 f6                	test   %esi,%esi
  801ebc:	7e 46                	jle    801f04 <spawn+0x1e0>
  801ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec3:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801ec9:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  801ecc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ed2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ed8:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801edb:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee2:	89 3c 24             	mov    %edi,(%esp)
  801ee5:	e8 e1 ed ff ff       	call   800ccb <strcpy>
		string_store += strlen(argv[i]) + 1;
  801eea:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801eed:	89 04 24             	mov    %eax,(%esp)
  801ef0:	e8 8b ed ff ff       	call   800c80 <strlen>
  801ef5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801ef9:	83 c3 01             	add    $0x1,%ebx
  801efc:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801f02:	75 c8                	jne    801ecc <spawn+0x1a8>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801f04:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801f0a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f10:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801f17:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801f1d:	74 24                	je     801f43 <spawn+0x21f>
  801f1f:	c7 44 24 0c 20 32 80 	movl   $0x803220,0xc(%esp)
  801f26:	00 
  801f27:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801f2e:	00 
  801f2f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801f36:	00 
  801f37:	c7 04 24 c5 31 80 00 	movl   $0x8031c5,(%esp)
  801f3e:	e8 39 e5 ff ff       	call   80047c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801f43:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f49:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801f4e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801f54:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801f57:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f5d:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801f60:	89 d0                	mov    %edx,%eax
  801f62:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801f67:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801f6d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801f74:	00 
  801f75:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801f7c:	ee 
  801f7d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f87:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f8e:	00 
  801f8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f96:	e8 90 f2 ff ff       	call   80122b <sys_page_map>
  801f9b:	89 c3                	mov    %eax,%ebx
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 1a                	js     801fbb <spawn+0x297>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801fa1:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fa8:	00 
  801fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb0:	e8 d4 f2 ff ff       	call   801289 <sys_page_unmap>
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	79 1f                	jns    801fda <spawn+0x2b6>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801fbb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801fc2:	00 
  801fc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fca:	e8 ba f2 ff ff       	call   801289 <sys_page_unmap>
	return r;
  801fcf:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801fd5:	e9 4c 03 00 00       	jmp    802326 <spawn+0x602>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801fda:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fe0:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801fe7:	00 
  801fe8:	0f 84 e2 01 00 00    	je     8021d0 <spawn+0x4ac>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801fee:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ff5:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ffb:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802002:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  802005:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80200b:	83 3a 01             	cmpl   $0x1,(%edx)
  80200e:	0f 85 9b 01 00 00    	jne    8021af <spawn+0x48b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802014:	8b 42 18             	mov    0x18(%edx),%eax
  802017:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80201a:	83 f8 01             	cmp    $0x1,%eax
  80201d:	19 c0                	sbb    %eax,%eax
  80201f:	83 e0 fe             	and    $0xfffffffe,%eax
  802022:	83 c0 07             	add    $0x7,%eax
  802025:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80202b:	8b 52 04             	mov    0x4(%edx),%edx
  80202e:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802034:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80203a:	8b 70 10             	mov    0x10(%eax),%esi
  80203d:	8b 50 14             	mov    0x14(%eax),%edx
  802040:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802046:	8b 40 08             	mov    0x8(%eax),%eax
  802049:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80204f:	25 ff 0f 00 00       	and    $0xfff,%eax
  802054:	74 16                	je     80206c <spawn+0x348>
		va -= i;
  802056:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  80205c:	01 c2                	add    %eax,%edx
  80205e:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802064:	01 c6                	add    %eax,%esi
		fileoffset -= i;
  802066:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80206c:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  802073:	0f 84 36 01 00 00    	je     8021af <spawn+0x48b>
  802079:	bf 00 00 00 00       	mov    $0x0,%edi
  80207e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  802083:	39 f7                	cmp    %esi,%edi
  802085:	72 31                	jb     8020b8 <spawn+0x394>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802087:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80208d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802091:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802097:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8020a1:	89 04 24             	mov    %eax,(%esp)
  8020a4:	e8 23 f1 ff ff       	call   8011cc <sys_page_alloc>
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	0f 89 ea 00 00 00    	jns    80219b <spawn+0x477>
  8020b1:	89 c6                	mov    %eax,%esi
  8020b3:	e9 3e 02 00 00       	jmp    8022f6 <spawn+0x5d2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020b8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020bf:	00 
  8020c0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020c7:	00 
  8020c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cf:	e8 f8 f0 ff ff       	call   8011cc <sys_page_alloc>
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	0f 88 10 02 00 00    	js     8022ec <spawn+0x5c8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8020dc:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8020e2:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8020ee:	89 04 24             	mov    %eax,(%esp)
  8020f1:	e8 a3 f8 ff ff       	call   801999 <seek>
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	0f 88 f2 01 00 00    	js     8022f0 <spawn+0x5cc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8020fe:	89 f0                	mov    %esi,%eax
  802100:	29 f8                	sub    %edi,%eax
  802102:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802107:	ba 00 10 00 00       	mov    $0x1000,%edx
  80210c:	0f 47 c2             	cmova  %edx,%eax
  80210f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802113:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80211a:	00 
  80211b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802121:	89 04 24             	mov    %eax,(%esp)
  802124:	e8 95 f7 ff ff       	call   8018be <readn>
  802129:	85 c0                	test   %eax,%eax
  80212b:	0f 88 c3 01 00 00    	js     8022f4 <spawn+0x5d0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802131:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802137:	89 54 24 10          	mov    %edx,0x10(%esp)
  80213b:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802141:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802145:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80214b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80214f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802156:	00 
  802157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80215e:	e8 c8 f0 ff ff       	call   80122b <sys_page_map>
  802163:	85 c0                	test   %eax,%eax
  802165:	79 20                	jns    802187 <spawn+0x463>
				panic("spawn: sys_page_map data: %e", r);
  802167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216b:	c7 44 24 08 d1 31 80 	movl   $0x8031d1,0x8(%esp)
  802172:	00 
  802173:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  80217a:	00 
  80217b:	c7 04 24 c5 31 80 00 	movl   $0x8031c5,(%esp)
  802182:	e8 f5 e2 ff ff       	call   80047c <_panic>
			sys_page_unmap(0, UTEMP);
  802187:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80218e:	00 
  80218f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802196:	e8 ee f0 ff ff       	call   801289 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80219b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8021a1:	89 df                	mov    %ebx,%edi
  8021a3:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8021a9:	0f 82 d4 fe ff ff    	jb     802083 <spawn+0x35f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8021af:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  8021b6:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8021bd:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8021c4:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  8021ca:	0f 8f 35 fe ff ff    	jg     802005 <spawn+0x2e1>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8021d0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8021d6:	89 04 24             	mov    %eax,(%esp)
  8021d9:	e8 df f4 ff ff       	call   8016bd <close>
  8021de:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  8021e3:	be 00 00 00 00       	mov    $0x0,%esi
  8021e8:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(i * PGSIZE)] & PTE_P) && (uvpt[i] & PTE_P) && (uvpt[i] & PTE_SHARE)) {
  8021ee:	89 f8                	mov    %edi,%eax
  8021f0:	c1 e8 16             	shr    $0x16,%eax
  8021f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8021fa:	a8 01                	test   $0x1,%al
  8021fc:	74 63                	je     802261 <spawn+0x53d>
  8021fe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802205:	a8 01                	test   $0x1,%al
  802207:	74 58                	je     802261 <spawn+0x53d>
  802209:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802210:	f6 c4 04             	test   $0x4,%ah
  802213:	74 4c                	je     802261 <spawn+0x53d>
			res = sys_page_map(0, (void *)(i * PGSIZE), child, (void *)(i * PGSIZE), uvpt[i] & PTE_SYSCALL);
  802215:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80221c:	25 07 0e 00 00       	and    $0xe07,%eax
  802221:	89 44 24 10          	mov    %eax,0x10(%esp)
  802225:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80222d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802231:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802238:	e8 ee ef ff ff       	call   80122b <sys_page_map>
			if (res < 0)
  80223d:	85 c0                	test   %eax,%eax
  80223f:	79 20                	jns    802261 <spawn+0x53d>
				panic("sys_page_map failed in copy_shared_pages %e\n", res);
  802241:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802245:	c7 44 24 08 48 32 80 	movl   $0x803248,0x8(%esp)
  80224c:	00 
  80224d:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  802254:	00 
  802255:	c7 04 24 c5 31 80 00 	movl   $0x8031c5,(%esp)
  80225c:	e8 1b e2 ff ff       	call   80047c <_panic>
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  802261:	83 c6 01             	add    $0x1,%esi
  802264:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80226a:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  802270:	0f 85 78 ff ff ff    	jne    8021ee <spawn+0x4ca>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802276:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80227c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802280:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802286:	89 04 24             	mov    %eax,(%esp)
  802289:	e8 b7 f0 ff ff       	call   801345 <sys_env_set_trapframe>
  80228e:	85 c0                	test   %eax,%eax
  802290:	79 20                	jns    8022b2 <spawn+0x58e>
		panic("sys_env_set_trapframe: %e", r);
  802292:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802296:	c7 44 24 08 ee 31 80 	movl   $0x8031ee,0x8(%esp)
  80229d:	00 
  80229e:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8022a5:	00 
  8022a6:	c7 04 24 c5 31 80 00 	movl   $0x8031c5,(%esp)
  8022ad:	e8 ca e1 ff ff       	call   80047c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8022b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8022b9:	00 
  8022ba:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8022c0:	89 04 24             	mov    %eax,(%esp)
  8022c3:	e8 1f f0 ff ff       	call   8012e7 <sys_env_set_status>
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	79 5a                	jns    802326 <spawn+0x602>
		panic("sys_env_set_status: %e", r);
  8022cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d0:	c7 44 24 08 08 32 80 	movl   $0x803208,0x8(%esp)
  8022d7:	00 
  8022d8:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8022df:	00 
  8022e0:	c7 04 24 c5 31 80 00 	movl   $0x8031c5,(%esp)
  8022e7:	e8 90 e1 ff ff       	call   80047c <_panic>
  8022ec:	89 c6                	mov    %eax,%esi
  8022ee:	eb 06                	jmp    8022f6 <spawn+0x5d2>
  8022f0:	89 c6                	mov    %eax,%esi
  8022f2:	eb 02                	jmp    8022f6 <spawn+0x5d2>
  8022f4:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8022f6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8022fc:	89 04 24             	mov    %eax,(%esp)
  8022ff:	e8 0b ee ff ff       	call   80110f <sys_env_destroy>
	close(fd);
  802304:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80230a:	89 04 24             	mov    %eax,(%esp)
  80230d:	e8 ab f3 ff ff       	call   8016bd <close>
	return r;
  802312:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802318:	eb 0c                	jmp    802326 <spawn+0x602>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80231a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802320:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802326:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80232c:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802332:	5b                   	pop    %ebx
  802333:	5e                   	pop    %esi
  802334:	5f                   	pop    %edi
  802335:	5d                   	pop    %ebp
  802336:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802337:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  80233c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802342:	eb e2                	jmp    802326 <spawn+0x602>

00802344 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802344:	55                   	push   %ebp
  802345:	89 e5                	mov    %esp,%ebp
  802347:	56                   	push   %esi
  802348:	53                   	push   %ebx
  802349:	83 ec 10             	sub    $0x10,%esp
  80234c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80234f:	8d 45 14             	lea    0x14(%ebp),%eax
  802352:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802356:	74 66                	je     8023be <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802358:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80235d:	83 c1 01             	add    $0x1,%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802360:	89 c2                	mov    %eax,%edx
  802362:	83 c0 04             	add    $0x4,%eax
  802365:	83 3a 00             	cmpl   $0x0,(%edx)
  802368:	75 f3                	jne    80235d <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80236a:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802371:	83 e0 f0             	and    $0xfffffff0,%eax
  802374:	29 c4                	sub    %eax,%esp
  802376:	8d 44 24 17          	lea    0x17(%esp),%eax
  80237a:	83 e0 f0             	and    $0xfffffff0,%eax
  80237d:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80237f:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802381:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802388:	00 

	va_start(vl, arg0);
  802389:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80238c:	89 ce                	mov    %ecx,%esi
  80238e:	85 c9                	test   %ecx,%ecx
  802390:	74 16                	je     8023a8 <spawnl+0x64>
  802392:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802397:	83 c0 01             	add    $0x1,%eax
  80239a:	89 d1                	mov    %edx,%ecx
  80239c:	83 c2 04             	add    $0x4,%edx
  80239f:	8b 09                	mov    (%ecx),%ecx
  8023a1:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8023a4:	39 f0                	cmp    %esi,%eax
  8023a6:	75 ef                	jne    802397 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8023a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8023af:	89 04 24             	mov    %eax,(%esp)
  8023b2:	e8 6d f9 ff ff       	call   801d24 <spawn>
}
  8023b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5e                   	pop    %esi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8023be:	83 ec 20             	sub    $0x20,%esp
  8023c1:	8d 44 24 17          	lea    0x17(%esp),%eax
  8023c5:	83 e0 f0             	and    $0xfffffff0,%eax
  8023c8:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8023ca:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8023cc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8023d3:	eb d3                	jmp    8023a8 <spawnl+0x64>
	...

008023e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	83 ec 18             	sub    $0x18,%esp
  8023e6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8023e9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8023ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f2:	89 04 24             	mov    %eax,(%esp)
  8023f5:	e8 e6 f0 ff ff       	call   8014e0 <fd2data>
  8023fa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8023fc:	c7 44 24 04 78 32 80 	movl   $0x803278,0x4(%esp)
  802403:	00 
  802404:	89 34 24             	mov    %esi,(%esp)
  802407:	e8 bf e8 ff ff       	call   800ccb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80240c:	8b 43 04             	mov    0x4(%ebx),%eax
  80240f:	2b 03                	sub    (%ebx),%eax
  802411:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802417:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80241e:	00 00 00 
	stat->st_dev = &devpipe;
  802421:	c7 86 88 00 00 00 b0 	movl   $0x8057b0,0x88(%esi)
  802428:	57 80 00 
	return 0;
}
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
  802430:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802433:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802436:	89 ec                	mov    %ebp,%esp
  802438:	5d                   	pop    %ebp
  802439:	c3                   	ret    

0080243a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	53                   	push   %ebx
  80243e:	83 ec 14             	sub    $0x14,%esp
  802441:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802444:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802448:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80244f:	e8 35 ee ff ff       	call   801289 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802454:	89 1c 24             	mov    %ebx,(%esp)
  802457:	e8 84 f0 ff ff       	call   8014e0 <fd2data>
  80245c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802460:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802467:	e8 1d ee ff ff       	call   801289 <sys_page_unmap>
}
  80246c:	83 c4 14             	add    $0x14,%esp
  80246f:	5b                   	pop    %ebx
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    

00802472 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	57                   	push   %edi
  802476:	56                   	push   %esi
  802477:	53                   	push   %ebx
  802478:	83 ec 2c             	sub    $0x2c,%esp
  80247b:	89 c7                	mov    %eax,%edi
  80247d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802480:	a1 90 77 80 00       	mov    0x807790,%eax
  802485:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802488:	89 3c 24             	mov    %edi,(%esp)
  80248b:	e8 ac 04 00 00       	call   80293c <pageref>
  802490:	89 c6                	mov    %eax,%esi
  802492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802495:	89 04 24             	mov    %eax,(%esp)
  802498:	e8 9f 04 00 00       	call   80293c <pageref>
  80249d:	39 c6                	cmp    %eax,%esi
  80249f:	0f 94 c0             	sete   %al
  8024a2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8024a5:	8b 15 90 77 80 00    	mov    0x807790,%edx
  8024ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024ae:	39 cb                	cmp    %ecx,%ebx
  8024b0:	75 08                	jne    8024ba <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8024b2:	83 c4 2c             	add    $0x2c,%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5e                   	pop    %esi
  8024b7:	5f                   	pop    %edi
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8024ba:	83 f8 01             	cmp    $0x1,%eax
  8024bd:	75 c1                	jne    802480 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024bf:	8b 52 58             	mov    0x58(%edx),%edx
  8024c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024c6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024ce:	c7 04 24 7f 32 80 00 	movl   $0x80327f,(%esp)
  8024d5:	e8 9d e0 ff ff       	call   800577 <cprintf>
  8024da:	eb a4                	jmp    802480 <_pipeisclosed+0xe>

008024dc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	57                   	push   %edi
  8024e0:	56                   	push   %esi
  8024e1:	53                   	push   %ebx
  8024e2:	83 ec 2c             	sub    $0x2c,%esp
  8024e5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024e8:	89 34 24             	mov    %esi,(%esp)
  8024eb:	e8 f0 ef ff ff       	call   8014e0 <fd2data>
  8024f0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8024f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024fb:	75 50                	jne    80254d <devpipe_write+0x71>
  8024fd:	eb 5c                	jmp    80255b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024ff:	89 da                	mov    %ebx,%edx
  802501:	89 f0                	mov    %esi,%eax
  802503:	e8 6a ff ff ff       	call   802472 <_pipeisclosed>
  802508:	85 c0                	test   %eax,%eax
  80250a:	75 53                	jne    80255f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80250c:	e8 8b ec ff ff       	call   80119c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802511:	8b 43 04             	mov    0x4(%ebx),%eax
  802514:	8b 13                	mov    (%ebx),%edx
  802516:	83 c2 20             	add    $0x20,%edx
  802519:	39 d0                	cmp    %edx,%eax
  80251b:	73 e2                	jae    8024ff <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80251d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802520:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802524:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802527:	89 c2                	mov    %eax,%edx
  802529:	c1 fa 1f             	sar    $0x1f,%edx
  80252c:	c1 ea 1b             	shr    $0x1b,%edx
  80252f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802532:	83 e1 1f             	and    $0x1f,%ecx
  802535:	29 d1                	sub    %edx,%ecx
  802537:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80253b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80253f:	83 c0 01             	add    $0x1,%eax
  802542:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802545:	83 c7 01             	add    $0x1,%edi
  802548:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80254b:	74 0e                	je     80255b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80254d:	8b 43 04             	mov    0x4(%ebx),%eax
  802550:	8b 13                	mov    (%ebx),%edx
  802552:	83 c2 20             	add    $0x20,%edx
  802555:	39 d0                	cmp    %edx,%eax
  802557:	73 a6                	jae    8024ff <devpipe_write+0x23>
  802559:	eb c2                	jmp    80251d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80255b:	89 f8                	mov    %edi,%eax
  80255d:	eb 05                	jmp    802564 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80255f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802564:	83 c4 2c             	add    $0x2c,%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	5d                   	pop    %ebp
  80256b:	c3                   	ret    

0080256c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80256c:	55                   	push   %ebp
  80256d:	89 e5                	mov    %esp,%ebp
  80256f:	83 ec 28             	sub    $0x28,%esp
  802572:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802575:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802578:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80257b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80257e:	89 3c 24             	mov    %edi,(%esp)
  802581:	e8 5a ef ff ff       	call   8014e0 <fd2data>
  802586:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802588:	be 00 00 00 00       	mov    $0x0,%esi
  80258d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802591:	75 47                	jne    8025da <devpipe_read+0x6e>
  802593:	eb 52                	jmp    8025e7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802595:	89 f0                	mov    %esi,%eax
  802597:	eb 5e                	jmp    8025f7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802599:	89 da                	mov    %ebx,%edx
  80259b:	89 f8                	mov    %edi,%eax
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	e8 cd fe ff ff       	call   802472 <_pipeisclosed>
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	75 49                	jne    8025f2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8025a9:	e8 ee eb ff ff       	call   80119c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025ae:	8b 03                	mov    (%ebx),%eax
  8025b0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8025b3:	74 e4                	je     802599 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025b5:	89 c2                	mov    %eax,%edx
  8025b7:	c1 fa 1f             	sar    $0x1f,%edx
  8025ba:	c1 ea 1b             	shr    $0x1b,%edx
  8025bd:	01 d0                	add    %edx,%eax
  8025bf:	83 e0 1f             	and    $0x1f,%eax
  8025c2:	29 d0                	sub    %edx,%eax
  8025c4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8025c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025cc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8025cf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025d2:	83 c6 01             	add    $0x1,%esi
  8025d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025d8:	74 0d                	je     8025e7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  8025da:	8b 03                	mov    (%ebx),%eax
  8025dc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8025df:	75 d4                	jne    8025b5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025e1:	85 f6                	test   %esi,%esi
  8025e3:	75 b0                	jne    802595 <devpipe_read+0x29>
  8025e5:	eb b2                	jmp    802599 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025e7:	89 f0                	mov    %esi,%eax
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	eb 05                	jmp    8025f7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8025fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8025fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802600:	89 ec                	mov    %ebp,%esp
  802602:	5d                   	pop    %ebp
  802603:	c3                   	ret    

00802604 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802604:	55                   	push   %ebp
  802605:	89 e5                	mov    %esp,%ebp
  802607:	83 ec 48             	sub    $0x48,%esp
  80260a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80260d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802610:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802613:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802616:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802619:	89 04 24             	mov    %eax,(%esp)
  80261c:	e8 da ee ff ff       	call   8014fb <fd_alloc>
  802621:	89 c3                	mov    %eax,%ebx
  802623:	85 c0                	test   %eax,%eax
  802625:	0f 88 45 01 00 00    	js     802770 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802632:	00 
  802633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80263a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802641:	e8 86 eb ff ff       	call   8011cc <sys_page_alloc>
  802646:	89 c3                	mov    %eax,%ebx
  802648:	85 c0                	test   %eax,%eax
  80264a:	0f 88 20 01 00 00    	js     802770 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802650:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802653:	89 04 24             	mov    %eax,(%esp)
  802656:	e8 a0 ee ff ff       	call   8014fb <fd_alloc>
  80265b:	89 c3                	mov    %eax,%ebx
  80265d:	85 c0                	test   %eax,%eax
  80265f:	0f 88 f8 00 00 00    	js     80275d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802665:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80266c:	00 
  80266d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802670:	89 44 24 04          	mov    %eax,0x4(%esp)
  802674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80267b:	e8 4c eb ff ff       	call   8011cc <sys_page_alloc>
  802680:	89 c3                	mov    %eax,%ebx
  802682:	85 c0                	test   %eax,%eax
  802684:	0f 88 d3 00 00 00    	js     80275d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80268a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80268d:	89 04 24             	mov    %eax,(%esp)
  802690:	e8 4b ee ff ff       	call   8014e0 <fd2data>
  802695:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802697:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80269e:	00 
  80269f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026aa:	e8 1d eb ff ff       	call   8011cc <sys_page_alloc>
  8026af:	89 c3                	mov    %eax,%ebx
  8026b1:	85 c0                	test   %eax,%eax
  8026b3:	0f 88 91 00 00 00    	js     80274a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026bc:	89 04 24             	mov    %eax,(%esp)
  8026bf:	e8 1c ee ff ff       	call   8014e0 <fd2data>
  8026c4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8026cb:	00 
  8026cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026d7:	00 
  8026d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026e3:	e8 43 eb ff ff       	call   80122b <sys_page_map>
  8026e8:	89 c3                	mov    %eax,%ebx
  8026ea:	85 c0                	test   %eax,%eax
  8026ec:	78 4c                	js     80273a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026ee:	8b 15 b0 57 80 00    	mov    0x8057b0,%edx
  8026f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802703:	8b 15 b0 57 80 00    	mov    0x8057b0,%edx
  802709:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80270c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80270e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802711:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802718:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80271b:	89 04 24             	mov    %eax,(%esp)
  80271e:	e8 ad ed ff ff       	call   8014d0 <fd2num>
  802723:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802725:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802728:	89 04 24             	mov    %eax,(%esp)
  80272b:	e8 a0 ed ff ff       	call   8014d0 <fd2num>
  802730:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802733:	bb 00 00 00 00       	mov    $0x0,%ebx
  802738:	eb 36                	jmp    802770 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80273a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80273e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802745:	e8 3f eb ff ff       	call   801289 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80274a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80274d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802751:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802758:	e8 2c eb ff ff       	call   801289 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80275d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802760:	89 44 24 04          	mov    %eax,0x4(%esp)
  802764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80276b:	e8 19 eb ff ff       	call   801289 <sys_page_unmap>
    err:
	return r;
}
  802770:	89 d8                	mov    %ebx,%eax
  802772:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802775:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802778:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80277b:	89 ec                	mov    %ebp,%esp
  80277d:	5d                   	pop    %ebp
  80277e:	c3                   	ret    

0080277f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80277f:	55                   	push   %ebp
  802780:	89 e5                	mov    %esp,%ebp
  802782:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80278c:	8b 45 08             	mov    0x8(%ebp),%eax
  80278f:	89 04 24             	mov    %eax,(%esp)
  802792:	e8 d7 ed ff ff       	call   80156e <fd_lookup>
  802797:	85 c0                	test   %eax,%eax
  802799:	78 15                	js     8027b0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80279b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80279e:	89 04 24             	mov    %eax,(%esp)
  8027a1:	e8 3a ed ff ff       	call   8014e0 <fd2data>
	return _pipeisclosed(fd, p);
  8027a6:	89 c2                	mov    %eax,%edx
  8027a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ab:	e8 c2 fc ff ff       	call   802472 <_pipeisclosed>
}
  8027b0:	c9                   	leave  
  8027b1:	c3                   	ret    
	...

008027b4 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8027b4:	55                   	push   %ebp
  8027b5:	89 e5                	mov    %esp,%ebp
  8027b7:	56                   	push   %esi
  8027b8:	53                   	push   %ebx
  8027b9:	83 ec 10             	sub    $0x10,%esp
  8027bc:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  8027bf:	85 c0                	test   %eax,%eax
  8027c1:	75 24                	jne    8027e7 <wait+0x33>
  8027c3:	c7 44 24 0c 97 32 80 	movl   $0x803297,0xc(%esp)
  8027ca:	00 
  8027cb:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  8027d2:	00 
  8027d3:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8027da:	00 
  8027db:	c7 04 24 a2 32 80 00 	movl   $0x8032a2,(%esp)
  8027e2:	e8 95 dc ff ff       	call   80047c <_panic>
	e = &envs[ENVX(envid)];
  8027e7:	89 c3                	mov    %eax,%ebx
  8027e9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8027ef:	c1 e3 07             	shl    $0x7,%ebx
  8027f2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027f8:	8b 73 48             	mov    0x48(%ebx),%esi
  8027fb:	39 c6                	cmp    %eax,%esi
  8027fd:	75 1a                	jne    802819 <wait+0x65>
  8027ff:	8b 43 54             	mov    0x54(%ebx),%eax
  802802:	85 c0                	test   %eax,%eax
  802804:	74 13                	je     802819 <wait+0x65>
		sys_yield();
  802806:	e8 91 e9 ff ff       	call   80119c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80280b:	8b 43 48             	mov    0x48(%ebx),%eax
  80280e:	39 f0                	cmp    %esi,%eax
  802810:	75 07                	jne    802819 <wait+0x65>
  802812:	8b 43 54             	mov    0x54(%ebx),%eax
  802815:	85 c0                	test   %eax,%eax
  802817:	75 ed                	jne    802806 <wait+0x52>
		sys_yield();
}
  802819:	83 c4 10             	add    $0x10,%esp
  80281c:	5b                   	pop    %ebx
  80281d:	5e                   	pop    %esi
  80281e:	5d                   	pop    %ebp
  80281f:	c3                   	ret    

00802820 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802820:	55                   	push   %ebp
  802821:	89 e5                	mov    %esp,%ebp
  802823:	56                   	push   %esi
  802824:	53                   	push   %ebx
  802825:	83 ec 10             	sub    $0x10,%esp
  802828:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80282b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80282e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802831:	85 db                	test   %ebx,%ebx
  802833:	74 06                	je     80283b <ipc_recv+0x1b>
  802835:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80283b:	85 f6                	test   %esi,%esi
  80283d:	74 06                	je     802845 <ipc_recv+0x25>
  80283f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802845:	85 c0                	test   %eax,%eax
  802847:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80284c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80284f:	89 04 24             	mov    %eax,(%esp)
  802852:	e8 de eb ff ff       	call   801435 <sys_ipc_recv>
    if (ret) return ret;
  802857:	85 c0                	test   %eax,%eax
  802859:	75 24                	jne    80287f <ipc_recv+0x5f>
    if (from_env_store)
  80285b:	85 db                	test   %ebx,%ebx
  80285d:	74 0a                	je     802869 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80285f:	a1 90 77 80 00       	mov    0x807790,%eax
  802864:	8b 40 74             	mov    0x74(%eax),%eax
  802867:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802869:	85 f6                	test   %esi,%esi
  80286b:	74 0a                	je     802877 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80286d:	a1 90 77 80 00       	mov    0x807790,%eax
  802872:	8b 40 78             	mov    0x78(%eax),%eax
  802875:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802877:	a1 90 77 80 00       	mov    0x807790,%eax
  80287c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80287f:	83 c4 10             	add    $0x10,%esp
  802882:	5b                   	pop    %ebx
  802883:	5e                   	pop    %esi
  802884:	5d                   	pop    %ebp
  802885:	c3                   	ret    

00802886 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802886:	55                   	push   %ebp
  802887:	89 e5                	mov    %esp,%ebp
  802889:	57                   	push   %edi
  80288a:	56                   	push   %esi
  80288b:	53                   	push   %ebx
  80288c:	83 ec 1c             	sub    $0x1c,%esp
  80288f:	8b 75 08             	mov    0x8(%ebp),%esi
  802892:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802895:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802898:	85 db                	test   %ebx,%ebx
  80289a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80289f:	0f 44 d8             	cmove  %eax,%ebx
  8028a2:	eb 2a                	jmp    8028ce <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8028a4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028a7:	74 20                	je     8028c9 <ipc_send+0x43>
  8028a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028ad:	c7 44 24 08 ad 32 80 	movl   $0x8032ad,0x8(%esp)
  8028b4:	00 
  8028b5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8028bc:	00 
  8028bd:	c7 04 24 c4 32 80 00 	movl   $0x8032c4,(%esp)
  8028c4:	e8 b3 db ff ff       	call   80047c <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8028c9:	e8 ce e8 ff ff       	call   80119c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8028ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8028d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028dd:	89 34 24             	mov    %esi,(%esp)
  8028e0:	e8 1c eb ff ff       	call   801401 <sys_ipc_try_send>
  8028e5:	85 c0                	test   %eax,%eax
  8028e7:	75 bb                	jne    8028a4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8028e9:	83 c4 1c             	add    $0x1c,%esp
  8028ec:	5b                   	pop    %ebx
  8028ed:	5e                   	pop    %esi
  8028ee:	5f                   	pop    %edi
  8028ef:	5d                   	pop    %ebp
  8028f0:	c3                   	ret    

008028f1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028f1:	55                   	push   %ebp
  8028f2:	89 e5                	mov    %esp,%ebp
  8028f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8028f7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8028fc:	39 c8                	cmp    %ecx,%eax
  8028fe:	74 19                	je     802919 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802900:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802905:	89 c2                	mov    %eax,%edx
  802907:	c1 e2 07             	shl    $0x7,%edx
  80290a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802910:	8b 52 50             	mov    0x50(%edx),%edx
  802913:	39 ca                	cmp    %ecx,%edx
  802915:	75 14                	jne    80292b <ipc_find_env+0x3a>
  802917:	eb 05                	jmp    80291e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802919:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80291e:	c1 e0 07             	shl    $0x7,%eax
  802921:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802926:	8b 40 40             	mov    0x40(%eax),%eax
  802929:	eb 0e                	jmp    802939 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80292b:	83 c0 01             	add    $0x1,%eax
  80292e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802933:	75 d0                	jne    802905 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802935:	66 b8 00 00          	mov    $0x0,%ax
}
  802939:	5d                   	pop    %ebp
  80293a:	c3                   	ret    
	...

0080293c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80293c:	55                   	push   %ebp
  80293d:	89 e5                	mov    %esp,%ebp
  80293f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802942:	89 d0                	mov    %edx,%eax
  802944:	c1 e8 16             	shr    $0x16,%eax
  802947:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80294e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802953:	f6 c1 01             	test   $0x1,%cl
  802956:	74 1d                	je     802975 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802958:	c1 ea 0c             	shr    $0xc,%edx
  80295b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802962:	f6 c2 01             	test   $0x1,%dl
  802965:	74 0e                	je     802975 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802967:	c1 ea 0c             	shr    $0xc,%edx
  80296a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802971:	ef 
  802972:	0f b7 c0             	movzwl %ax,%eax
}
  802975:	5d                   	pop    %ebp
  802976:	c3                   	ret    
	...

00802980 <__udivdi3>:
  802980:	83 ec 1c             	sub    $0x1c,%esp
  802983:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802987:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80298b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80298f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802993:	89 74 24 10          	mov    %esi,0x10(%esp)
  802997:	8b 74 24 24          	mov    0x24(%esp),%esi
  80299b:	85 ff                	test   %edi,%edi
  80299d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8029a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029a5:	89 cd                	mov    %ecx,%ebp
  8029a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029ab:	75 33                	jne    8029e0 <__udivdi3+0x60>
  8029ad:	39 f1                	cmp    %esi,%ecx
  8029af:	77 57                	ja     802a08 <__udivdi3+0x88>
  8029b1:	85 c9                	test   %ecx,%ecx
  8029b3:	75 0b                	jne    8029c0 <__udivdi3+0x40>
  8029b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8029ba:	31 d2                	xor    %edx,%edx
  8029bc:	f7 f1                	div    %ecx
  8029be:	89 c1                	mov    %eax,%ecx
  8029c0:	89 f0                	mov    %esi,%eax
  8029c2:	31 d2                	xor    %edx,%edx
  8029c4:	f7 f1                	div    %ecx
  8029c6:	89 c6                	mov    %eax,%esi
  8029c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029cc:	f7 f1                	div    %ecx
  8029ce:	89 f2                	mov    %esi,%edx
  8029d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029dc:	83 c4 1c             	add    $0x1c,%esp
  8029df:	c3                   	ret    
  8029e0:	31 d2                	xor    %edx,%edx
  8029e2:	31 c0                	xor    %eax,%eax
  8029e4:	39 f7                	cmp    %esi,%edi
  8029e6:	77 e8                	ja     8029d0 <__udivdi3+0x50>
  8029e8:	0f bd cf             	bsr    %edi,%ecx
  8029eb:	83 f1 1f             	xor    $0x1f,%ecx
  8029ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8029f2:	75 2c                	jne    802a20 <__udivdi3+0xa0>
  8029f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8029f8:	76 04                	jbe    8029fe <__udivdi3+0x7e>
  8029fa:	39 f7                	cmp    %esi,%edi
  8029fc:	73 d2                	jae    8029d0 <__udivdi3+0x50>
  8029fe:	31 d2                	xor    %edx,%edx
  802a00:	b8 01 00 00 00       	mov    $0x1,%eax
  802a05:	eb c9                	jmp    8029d0 <__udivdi3+0x50>
  802a07:	90                   	nop
  802a08:	89 f2                	mov    %esi,%edx
  802a0a:	f7 f1                	div    %ecx
  802a0c:	31 d2                	xor    %edx,%edx
  802a0e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a12:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802a16:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802a1a:	83 c4 1c             	add    $0x1c,%esp
  802a1d:	c3                   	ret    
  802a1e:	66 90                	xchg   %ax,%ax
  802a20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a25:	b8 20 00 00 00       	mov    $0x20,%eax
  802a2a:	89 ea                	mov    %ebp,%edx
  802a2c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a30:	d3 e7                	shl    %cl,%edi
  802a32:	89 c1                	mov    %eax,%ecx
  802a34:	d3 ea                	shr    %cl,%edx
  802a36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a3b:	09 fa                	or     %edi,%edx
  802a3d:	89 f7                	mov    %esi,%edi
  802a3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802a43:	89 f2                	mov    %esi,%edx
  802a45:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a49:	d3 e5                	shl    %cl,%ebp
  802a4b:	89 c1                	mov    %eax,%ecx
  802a4d:	d3 ef                	shr    %cl,%edi
  802a4f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a54:	d3 e2                	shl    %cl,%edx
  802a56:	89 c1                	mov    %eax,%ecx
  802a58:	d3 ee                	shr    %cl,%esi
  802a5a:	09 d6                	or     %edx,%esi
  802a5c:	89 fa                	mov    %edi,%edx
  802a5e:	89 f0                	mov    %esi,%eax
  802a60:	f7 74 24 0c          	divl   0xc(%esp)
  802a64:	89 d7                	mov    %edx,%edi
  802a66:	89 c6                	mov    %eax,%esi
  802a68:	f7 e5                	mul    %ebp
  802a6a:	39 d7                	cmp    %edx,%edi
  802a6c:	72 22                	jb     802a90 <__udivdi3+0x110>
  802a6e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802a72:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a77:	d3 e5                	shl    %cl,%ebp
  802a79:	39 c5                	cmp    %eax,%ebp
  802a7b:	73 04                	jae    802a81 <__udivdi3+0x101>
  802a7d:	39 d7                	cmp    %edx,%edi
  802a7f:	74 0f                	je     802a90 <__udivdi3+0x110>
  802a81:	89 f0                	mov    %esi,%eax
  802a83:	31 d2                	xor    %edx,%edx
  802a85:	e9 46 ff ff ff       	jmp    8029d0 <__udivdi3+0x50>
  802a8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a90:	8d 46 ff             	lea    -0x1(%esi),%eax
  802a93:	31 d2                	xor    %edx,%edx
  802a95:	8b 74 24 10          	mov    0x10(%esp),%esi
  802a99:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802a9d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802aa1:	83 c4 1c             	add    $0x1c,%esp
  802aa4:	c3                   	ret    
	...

00802ab0 <__umoddi3>:
  802ab0:	83 ec 1c             	sub    $0x1c,%esp
  802ab3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802ab7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  802abb:	8b 44 24 20          	mov    0x20(%esp),%eax
  802abf:	89 74 24 10          	mov    %esi,0x10(%esp)
  802ac3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802ac7:	8b 74 24 24          	mov    0x24(%esp),%esi
  802acb:	85 ed                	test   %ebp,%ebp
  802acd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802ad1:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ad5:	89 cf                	mov    %ecx,%edi
  802ad7:	89 04 24             	mov    %eax,(%esp)
  802ada:	89 f2                	mov    %esi,%edx
  802adc:	75 1a                	jne    802af8 <__umoddi3+0x48>
  802ade:	39 f1                	cmp    %esi,%ecx
  802ae0:	76 4e                	jbe    802b30 <__umoddi3+0x80>
  802ae2:	f7 f1                	div    %ecx
  802ae4:	89 d0                	mov    %edx,%eax
  802ae6:	31 d2                	xor    %edx,%edx
  802ae8:	8b 74 24 10          	mov    0x10(%esp),%esi
  802aec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802af0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802af4:	83 c4 1c             	add    $0x1c,%esp
  802af7:	c3                   	ret    
  802af8:	39 f5                	cmp    %esi,%ebp
  802afa:	77 54                	ja     802b50 <__umoddi3+0xa0>
  802afc:	0f bd c5             	bsr    %ebp,%eax
  802aff:	83 f0 1f             	xor    $0x1f,%eax
  802b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b06:	75 60                	jne    802b68 <__umoddi3+0xb8>
  802b08:	3b 0c 24             	cmp    (%esp),%ecx
  802b0b:	0f 87 07 01 00 00    	ja     802c18 <__umoddi3+0x168>
  802b11:	89 f2                	mov    %esi,%edx
  802b13:	8b 34 24             	mov    (%esp),%esi
  802b16:	29 ce                	sub    %ecx,%esi
  802b18:	19 ea                	sbb    %ebp,%edx
  802b1a:	89 34 24             	mov    %esi,(%esp)
  802b1d:	8b 04 24             	mov    (%esp),%eax
  802b20:	8b 74 24 10          	mov    0x10(%esp),%esi
  802b24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802b28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802b2c:	83 c4 1c             	add    $0x1c,%esp
  802b2f:	c3                   	ret    
  802b30:	85 c9                	test   %ecx,%ecx
  802b32:	75 0b                	jne    802b3f <__umoddi3+0x8f>
  802b34:	b8 01 00 00 00       	mov    $0x1,%eax
  802b39:	31 d2                	xor    %edx,%edx
  802b3b:	f7 f1                	div    %ecx
  802b3d:	89 c1                	mov    %eax,%ecx
  802b3f:	89 f0                	mov    %esi,%eax
  802b41:	31 d2                	xor    %edx,%edx
  802b43:	f7 f1                	div    %ecx
  802b45:	8b 04 24             	mov    (%esp),%eax
  802b48:	f7 f1                	div    %ecx
  802b4a:	eb 98                	jmp    802ae4 <__umoddi3+0x34>
  802b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b50:	89 f2                	mov    %esi,%edx
  802b52:	8b 74 24 10          	mov    0x10(%esp),%esi
  802b56:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802b5a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802b5e:	83 c4 1c             	add    $0x1c,%esp
  802b61:	c3                   	ret    
  802b62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b68:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802b6d:	89 e8                	mov    %ebp,%eax
  802b6f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802b74:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802b78:	89 fa                	mov    %edi,%edx
  802b7a:	d3 e0                	shl    %cl,%eax
  802b7c:	89 e9                	mov    %ebp,%ecx
  802b7e:	d3 ea                	shr    %cl,%edx
  802b80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802b85:	09 c2                	or     %eax,%edx
  802b87:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b8b:	89 14 24             	mov    %edx,(%esp)
  802b8e:	89 f2                	mov    %esi,%edx
  802b90:	d3 e7                	shl    %cl,%edi
  802b92:	89 e9                	mov    %ebp,%ecx
  802b94:	d3 ea                	shr    %cl,%edx
  802b96:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802b9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b9f:	d3 e6                	shl    %cl,%esi
  802ba1:	89 e9                	mov    %ebp,%ecx
  802ba3:	d3 e8                	shr    %cl,%eax
  802ba5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802baa:	09 f0                	or     %esi,%eax
  802bac:	8b 74 24 08          	mov    0x8(%esp),%esi
  802bb0:	f7 34 24             	divl   (%esp)
  802bb3:	d3 e6                	shl    %cl,%esi
  802bb5:	89 74 24 08          	mov    %esi,0x8(%esp)
  802bb9:	89 d6                	mov    %edx,%esi
  802bbb:	f7 e7                	mul    %edi
  802bbd:	39 d6                	cmp    %edx,%esi
  802bbf:	89 c1                	mov    %eax,%ecx
  802bc1:	89 d7                	mov    %edx,%edi
  802bc3:	72 3f                	jb     802c04 <__umoddi3+0x154>
  802bc5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802bc9:	72 35                	jb     802c00 <__umoddi3+0x150>
  802bcb:	8b 44 24 08          	mov    0x8(%esp),%eax
  802bcf:	29 c8                	sub    %ecx,%eax
  802bd1:	19 fe                	sbb    %edi,%esi
  802bd3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802bd8:	89 f2                	mov    %esi,%edx
  802bda:	d3 e8                	shr    %cl,%eax
  802bdc:	89 e9                	mov    %ebp,%ecx
  802bde:	d3 e2                	shl    %cl,%edx
  802be0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802be5:	09 d0                	or     %edx,%eax
  802be7:	89 f2                	mov    %esi,%edx
  802be9:	d3 ea                	shr    %cl,%edx
  802beb:	8b 74 24 10          	mov    0x10(%esp),%esi
  802bef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802bf3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802bf7:	83 c4 1c             	add    $0x1c,%esp
  802bfa:	c3                   	ret    
  802bfb:	90                   	nop
  802bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c00:	39 d6                	cmp    %edx,%esi
  802c02:	75 c7                	jne    802bcb <__umoddi3+0x11b>
  802c04:	89 d7                	mov    %edx,%edi
  802c06:	89 c1                	mov    %eax,%ecx
  802c08:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  802c0c:	1b 3c 24             	sbb    (%esp),%edi
  802c0f:	eb ba                	jmp    802bcb <__umoddi3+0x11b>
  802c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c18:	39 f5                	cmp    %esi,%ebp
  802c1a:	0f 82 f1 fe ff ff    	jb     802b11 <__umoddi3+0x61>
  802c20:	e9 f8 fe ff ff       	jmp    802b1d <__umoddi3+0x6d>
