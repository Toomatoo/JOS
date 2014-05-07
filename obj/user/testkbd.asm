
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 9f 02 00 00       	call   8002d0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 07 11 00 00       	call   80114c <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	83 eb 01             	sub    $0x1,%ebx
  800048:	75 f6                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 17 16 00 00       	call   80166d <close>
	if ((r = opencons()) < 0)
  800056:	e8 22 02 00 00       	call   80027d <opencons>
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 20                	jns    80007f <umain+0x4b>
		panic("opencons: %e", r);
  80005f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800063:	c7 44 24 08 00 26 80 	movl   $0x802600,0x8(%esp)
  80006a:	00 
  80006b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 0d 26 80 00 	movl   $0x80260d,(%esp)
  80007a:	e8 bd 02 00 00       	call   80033c <_panic>
	if (r != 0)
  80007f:	85 c0                	test   %eax,%eax
  800081:	74 20                	je     8000a3 <umain+0x6f>
		panic("first opencons used fd %d", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 1c 26 80 	movl   $0x80261c,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 0d 26 80 00 	movl   $0x80260d,(%esp)
  80009e:	e8 99 02 00 00       	call   80033c <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000aa:	00 
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 09 16 00 00       	call   8016c0 <dup>
  8000b7:	85 c0                	test   %eax,%eax
  8000b9:	79 20                	jns    8000db <umain+0xa7>
		panic("dup: %e", r);
  8000bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bf:	c7 44 24 08 36 26 80 	movl   $0x802636,0x8(%esp)
  8000c6:	00 
  8000c7:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000ce:	00 
  8000cf:	c7 04 24 0d 26 80 00 	movl   $0x80260d,(%esp)
  8000d6:	e8 61 02 00 00       	call   80033c <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000db:	c7 04 24 3e 26 80 00 	movl   $0x80263e,(%esp)
  8000e2:	e8 59 0a 00 00       	call   800b40 <readline>
		if (buf != NULL)
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	74 1a                	je     800105 <umain+0xd1>
			fprintf(1, "%s\n", buf);
  8000eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ef:	c7 44 24 04 4c 26 80 	movl   $0x80264c,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fe:	e8 c5 1c 00 00       	call   801dc8 <fprintf>
  800103:	eb d6                	jmp    8000db <umain+0xa7>
		else
			fprintf(1, "(end of file received)\n");
  800105:	c7 44 24 04 50 26 80 	movl   $0x802650,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800114:	e8 af 1c 00 00       	call   801dc8 <fprintf>
  800119:	eb c0                	jmp    8000db <umain+0xa7>
  80011b:	00 00                	add    %al,(%eax)
  80011d:	00 00                	add    %al,(%eax)
	...

00800120 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800130:	c7 44 24 04 68 26 80 	movl   $0x802668,0x4(%esp)
  800137:	00 
  800138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013b:	89 04 24             	mov    %eax,(%esp)
  80013e:	e8 38 0b 00 00       	call   800c7b <strcpy>
	return 0;
}
  800143:	b8 00 00 00 00       	mov    $0x0,%eax
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80015f:	74 43                	je     8001a4 <devcons_write+0x5a>
  800161:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800166:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80016c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800171:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800174:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800179:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80017c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800180:	03 45 0c             	add    0xc(%ebp),%eax
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	89 3c 24             	mov    %edi,(%esp)
  80018a:	e8 dd 0c 00 00       	call   800e6c <memmove>
		sys_cputs(buf, m);
  80018f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800193:	89 3c 24             	mov    %edi,(%esp)
  800196:	e8 c5 0e 00 00       	call   801060 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80019b:	01 de                	add    %ebx,%esi
  80019d:	89 f0                	mov    %esi,%eax
  80019f:	3b 75 10             	cmp    0x10(%ebp),%esi
  8001a2:	72 c8                	jb     80016c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8001a4:	89 f0                	mov    %esi,%eax
  8001a6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8001ac:	5b                   	pop    %ebx
  8001ad:	5e                   	pop    %esi
  8001ae:	5f                   	pop    %edi
  8001af:	5d                   	pop    %ebp
  8001b0:	c3                   	ret    

008001b1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8001b7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8001bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001c0:	75 07                	jne    8001c9 <devcons_read+0x18>
  8001c2:	eb 31                	jmp    8001f5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001c4:	e8 83 0f 00 00       	call   80114c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8001d0:	e8 ba 0e 00 00       	call   80108f <sys_cgetc>
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	74 eb                	je     8001c4 <devcons_read+0x13>
  8001d9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	78 16                	js     8001f5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001df:	83 f8 04             	cmp    $0x4,%eax
  8001e2:	74 0c                	je     8001f0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	88 10                	mov    %dl,(%eax)
	return 1;
  8001e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8001ee:	eb 05                	jmp    8001f5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800203:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80020a:	00 
  80020b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 4a 0e 00 00       	call   801060 <sys_cputs>
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <getchar>:

int
getchar(void)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80021e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800225:	00 
  800226:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800234:	e8 a5 15 00 00       	call   8017de <read>
	if (r < 0)
  800239:	85 c0                	test   %eax,%eax
  80023b:	78 0f                	js     80024c <getchar+0x34>
		return r;
	if (r < 1)
  80023d:	85 c0                	test   %eax,%eax
  80023f:	7e 06                	jle    800247 <getchar+0x2f>
		return -E_EOF;
	return c;
  800241:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800245:	eb 05                	jmp    80024c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800247:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	e8 b8 12 00 00       	call   80151e <fd_lookup>
  800266:	85 c0                	test   %eax,%eax
  800268:	78 11                	js     80027b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80026a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80026d:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800273:	39 10                	cmp    %edx,(%eax)
  800275:	0f 94 c0             	sete   %al
  800278:	0f b6 c0             	movzbl %al,%eax
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <opencons>:

int
opencons(void)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800283:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	e8 1d 12 00 00       	call   8014ab <fd_alloc>
  80028e:	85 c0                	test   %eax,%eax
  800290:	78 3c                	js     8002ce <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800292:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800299:	00 
  80029a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a8:	e8 cf 0e 00 00       	call   80117c <sys_page_alloc>
  8002ad:	85 c0                	test   %eax,%eax
  8002af:	78 1d                	js     8002ce <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8002b1:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002ba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002bf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	e8 b2 11 00 00       	call   801480 <fd2num>
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 18             	sub    $0x18,%esp
  8002d6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002d9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8002dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002e2:	e8 35 0e 00 00       	call   80111c <sys_getenvid>
  8002e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002ec:	c1 e0 07             	shl    $0x7,%eax
  8002ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f4:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f9:	85 f6                	test   %esi,%esi
  8002fb:	7e 07                	jle    800304 <libmain+0x34>
		binaryname = argv[0];
  8002fd:	8b 03                	mov    (%ebx),%eax
  8002ff:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800304:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800308:	89 34 24             	mov    %esi,(%esp)
  80030b:	e8 24 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800310:	e8 0b 00 00 00       	call   800320 <exit>
}
  800315:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800318:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80031b:	89 ec                	mov    %ebp,%esp
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    
	...

00800320 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800326:	e8 73 13 00 00       	call   80169e <close_all>
	sys_env_destroy(0);
  80032b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800332:	e8 88 0d 00 00       	call   8010bf <sys_env_destroy>
}
  800337:	c9                   	leave  
  800338:	c3                   	ret    
  800339:	00 00                	add    %al,(%eax)
	...

0080033c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800347:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  80034d:	e8 ca 0d 00 00       	call   80111c <sys_getenvid>
  800352:	8b 55 0c             	mov    0xc(%ebp),%edx
  800355:	89 54 24 10          	mov    %edx,0x10(%esp)
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800360:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800364:	89 44 24 04          	mov    %eax,0x4(%esp)
  800368:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  80036f:	e8 c3 00 00 00       	call   800437 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800374:	89 74 24 04          	mov    %esi,0x4(%esp)
  800378:	8b 45 10             	mov    0x10(%ebp),%eax
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	e8 53 00 00 00       	call   8003d6 <vcprintf>
	cprintf("\n");
  800383:	c7 04 24 66 26 80 00 	movl   $0x802666,(%esp)
  80038a:	e8 a8 00 00 00       	call   800437 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038f:	cc                   	int3   
  800390:	eb fd                	jmp    80038f <_panic+0x53>
	...

00800394 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	53                   	push   %ebx
  800398:	83 ec 14             	sub    $0x14,%esp
  80039b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039e:	8b 03                	mov    (%ebx),%eax
  8003a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003a7:	83 c0 01             	add    $0x1,%eax
  8003aa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b1:	75 19                	jne    8003cc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003b3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ba:	00 
  8003bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8003be:	89 04 24             	mov    %eax,(%esp)
  8003c1:	e8 9a 0c 00 00       	call   801060 <sys_cputs>
		b->idx = 0;
  8003c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d0:	83 c4 14             	add    $0x14,%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e6:	00 00 00 
	b.cnt = 0;
  8003e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800401:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040b:	c7 04 24 94 03 80 00 	movl   $0x800394,(%esp)
  800412:	e8 97 01 00 00       	call   8005ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800417:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 31 0c 00 00       	call   801060 <sys_cputs>

	return b.cnt;
}
  80042f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800435:	c9                   	leave  
  800436:	c3                   	ret    

00800437 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800440:	89 44 24 04          	mov    %eax,0x4(%esp)
  800444:	8b 45 08             	mov    0x8(%ebp),%eax
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	e8 87 ff ff ff       	call   8003d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    
  800451:	00 00                	add    %al,(%eax)
	...

00800454 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 3c             	sub    $0x3c,%esp
  80045d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800460:	89 d7                	mov    %edx,%edi
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800468:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800471:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80047c:	72 11                	jb     80048f <printnum+0x3b>
  80047e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800481:	39 45 10             	cmp    %eax,0x10(%ebp)
  800484:	76 09                	jbe    80048f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800486:	83 eb 01             	sub    $0x1,%ebx
  800489:	85 db                	test   %ebx,%ebx
  80048b:	7f 51                	jg     8004de <printnum+0x8a>
  80048d:	eb 5e                	jmp    8004ed <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80048f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800493:	83 eb 01             	sub    $0x1,%ebx
  800496:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80049a:	8b 45 10             	mov    0x10(%ebp),%eax
  80049d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004a5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b0:	00 
  8004b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	e8 7d 1e 00 00       	call   802340 <__udivdi3>
  8004c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004cb:	89 04 24             	mov    %eax,(%esp)
  8004ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004d2:	89 fa                	mov    %edi,%edx
  8004d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d7:	e8 78 ff ff ff       	call   800454 <printnum>
  8004dc:	eb 0f                	jmp    8004ed <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e2:	89 34 24             	mov    %esi,(%esp)
  8004e5:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e8:	83 eb 01             	sub    $0x1,%ebx
  8004eb:	75 f1                	jne    8004de <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800503:	00 
  800504:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800507:	89 04 24             	mov    %eax,(%esp)
  80050a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	e8 5a 1f 00 00       	call   802470 <__umoddi3>
  800516:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051a:	0f be 80 a3 26 80 00 	movsbl 0x8026a3(%eax),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800527:	83 c4 3c             	add    $0x3c,%esp
  80052a:	5b                   	pop    %ebx
  80052b:	5e                   	pop    %esi
  80052c:	5f                   	pop    %edi
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800532:	83 fa 01             	cmp    $0x1,%edx
  800535:	7e 0e                	jle    800545 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800537:	8b 10                	mov    (%eax),%edx
  800539:	8d 4a 08             	lea    0x8(%edx),%ecx
  80053c:	89 08                	mov    %ecx,(%eax)
  80053e:	8b 02                	mov    (%edx),%eax
  800540:	8b 52 04             	mov    0x4(%edx),%edx
  800543:	eb 22                	jmp    800567 <getuint+0x38>
	else if (lflag)
  800545:	85 d2                	test   %edx,%edx
  800547:	74 10                	je     800559 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800549:	8b 10                	mov    (%eax),%edx
  80054b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80054e:	89 08                	mov    %ecx,(%eax)
  800550:	8b 02                	mov    (%edx),%eax
  800552:	ba 00 00 00 00       	mov    $0x0,%edx
  800557:	eb 0e                	jmp    800567 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80055e:	89 08                	mov    %ecx,(%eax)
  800560:	8b 02                	mov    (%edx),%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    

00800569 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80056f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800573:	8b 10                	mov    (%eax),%edx
  800575:	3b 50 04             	cmp    0x4(%eax),%edx
  800578:	73 0a                	jae    800584 <sprintputch+0x1b>
		*b->buf++ = ch;
  80057a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80057d:	88 0a                	mov    %cl,(%edx)
  80057f:	83 c2 01             	add    $0x1,%edx
  800582:	89 10                	mov    %edx,(%eax)
}
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80058f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800593:	8b 45 10             	mov    0x10(%ebp),%eax
  800596:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	e8 02 00 00 00       	call   8005ae <vprintfmt>
	va_end(ap);
}
  8005ac:	c9                   	leave  
  8005ad:	c3                   	ret    

008005ae <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	57                   	push   %edi
  8005b2:	56                   	push   %esi
  8005b3:	53                   	push   %ebx
  8005b4:	83 ec 5c             	sub    $0x5c,%esp
  8005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8005bd:	eb 12                	jmp    8005d1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	0f 84 e4 04 00 00    	je     800aab <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8005c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d1:	0f b6 06             	movzbl (%esi),%eax
  8005d4:	83 c6 01             	add    $0x1,%esi
  8005d7:	83 f8 25             	cmp    $0x25,%eax
  8005da:	75 e3                	jne    8005bf <vprintfmt+0x11>
  8005dc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8005e0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8005e7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ec:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8005fb:	eb 2b                	jmp    800628 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800600:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800604:	eb 22                	jmp    800628 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800609:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80060d:	eb 19                	jmp    800628 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800612:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800619:	eb 0d                	jmp    800628 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80061b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80061e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800621:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	0f b6 06             	movzbl (%esi),%eax
  80062b:	0f b6 d0             	movzbl %al,%edx
  80062e:	8d 7e 01             	lea    0x1(%esi),%edi
  800631:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800634:	83 e8 23             	sub    $0x23,%eax
  800637:	3c 55                	cmp    $0x55,%al
  800639:	0f 87 46 04 00 00    	ja     800a85 <vprintfmt+0x4d7>
  80063f:	0f b6 c0             	movzbl %al,%eax
  800642:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800649:	83 ea 30             	sub    $0x30,%edx
  80064c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80064f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800653:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800659:	83 fa 09             	cmp    $0x9,%edx
  80065c:	77 4a                	ja     8006a8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800661:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800664:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800667:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80066b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80066e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800671:	83 fa 09             	cmp    $0x9,%edx
  800674:	76 eb                	jbe    800661 <vprintfmt+0xb3>
  800676:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800679:	eb 2d                	jmp    8006a8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80068c:	eb 1a                	jmp    8006a8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800691:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800695:	79 91                	jns    800628 <vprintfmt+0x7a>
  800697:	e9 73 ff ff ff       	jmp    80060f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80069f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8006a6:	eb 80                	jmp    800628 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8006a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ac:	0f 89 76 ff ff ff    	jns    800628 <vprintfmt+0x7a>
  8006b2:	e9 64 ff ff ff       	jmp    80061b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006bd:	e9 66 ff ff ff       	jmp    800628 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006da:	e9 f2 fe ff ff       	jmp    8005d1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8006df:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8006e3:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8006e6:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8006ea:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8006ed:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8006f1:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8006f4:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8006f7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8006fb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8006fe:	80 f9 09             	cmp    $0x9,%cl
  800701:	77 1d                	ja     800720 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800703:	0f be c0             	movsbl %al,%eax
  800706:	6b c0 64             	imul   $0x64,%eax,%eax
  800709:	0f be d2             	movsbl %dl,%edx
  80070c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80070f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800716:	a3 20 30 80 00       	mov    %eax,0x803020
  80071b:	e9 b1 fe ff ff       	jmp    8005d1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800720:	c7 44 24 04 bb 26 80 	movl   $0x8026bb,0x4(%esp)
  800727:	00 
  800728:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	e8 08 06 00 00       	call   800d3b <strcmp>
  800733:	85 c0                	test   %eax,%eax
  800735:	75 0f                	jne    800746 <vprintfmt+0x198>
  800737:	c7 05 20 30 80 00 04 	movl   $0x4,0x803020
  80073e:	00 00 00 
  800741:	e9 8b fe ff ff       	jmp    8005d1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800746:	c7 44 24 04 bf 26 80 	movl   $0x8026bf,0x4(%esp)
  80074d:	00 
  80074e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800751:	89 14 24             	mov    %edx,(%esp)
  800754:	e8 e2 05 00 00       	call   800d3b <strcmp>
  800759:	85 c0                	test   %eax,%eax
  80075b:	75 0f                	jne    80076c <vprintfmt+0x1be>
  80075d:	c7 05 20 30 80 00 02 	movl   $0x2,0x803020
  800764:	00 00 00 
  800767:	e9 65 fe ff ff       	jmp    8005d1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80076c:	c7 44 24 04 c3 26 80 	movl   $0x8026c3,0x4(%esp)
  800773:	00 
  800774:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800777:	89 0c 24             	mov    %ecx,(%esp)
  80077a:	e8 bc 05 00 00       	call   800d3b <strcmp>
  80077f:	85 c0                	test   %eax,%eax
  800781:	75 0f                	jne    800792 <vprintfmt+0x1e4>
  800783:	c7 05 20 30 80 00 01 	movl   $0x1,0x803020
  80078a:	00 00 00 
  80078d:	e9 3f fe ff ff       	jmp    8005d1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800792:	c7 44 24 04 c7 26 80 	movl   $0x8026c7,0x4(%esp)
  800799:	00 
  80079a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80079d:	89 3c 24             	mov    %edi,(%esp)
  8007a0:	e8 96 05 00 00       	call   800d3b <strcmp>
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	75 0f                	jne    8007b8 <vprintfmt+0x20a>
  8007a9:	c7 05 20 30 80 00 06 	movl   $0x6,0x803020
  8007b0:	00 00 00 
  8007b3:	e9 19 fe ff ff       	jmp    8005d1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8007b8:	c7 44 24 04 cb 26 80 	movl   $0x8026cb,0x4(%esp)
  8007bf:	00 
  8007c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 70 05 00 00       	call   800d3b <strcmp>
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	75 0f                	jne    8007de <vprintfmt+0x230>
  8007cf:	c7 05 20 30 80 00 07 	movl   $0x7,0x803020
  8007d6:	00 00 00 
  8007d9:	e9 f3 fd ff ff       	jmp    8005d1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8007de:	c7 44 24 04 cf 26 80 	movl   $0x8026cf,0x4(%esp)
  8007e5:	00 
  8007e6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8007e9:	89 14 24             	mov    %edx,(%esp)
  8007ec:	e8 4a 05 00 00       	call   800d3b <strcmp>
  8007f1:	83 f8 01             	cmp    $0x1,%eax
  8007f4:	19 c0                	sbb    %eax,%eax
  8007f6:	f7 d0                	not    %eax
  8007f8:	83 c0 08             	add    $0x8,%eax
  8007fb:	a3 20 30 80 00       	mov    %eax,0x803020
  800800:	e9 cc fd ff ff       	jmp    8005d1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8d 50 04             	lea    0x4(%eax),%edx
  80080b:	89 55 14             	mov    %edx,0x14(%ebp)
  80080e:	8b 00                	mov    (%eax),%eax
  800810:	89 c2                	mov    %eax,%edx
  800812:	c1 fa 1f             	sar    $0x1f,%edx
  800815:	31 d0                	xor    %edx,%eax
  800817:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800819:	83 f8 0f             	cmp    $0xf,%eax
  80081c:	7f 0b                	jg     800829 <vprintfmt+0x27b>
  80081e:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  800825:	85 d2                	test   %edx,%edx
  800827:	75 23                	jne    80084c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082d:	c7 44 24 08 d3 26 80 	movl   $0x8026d3,0x8(%esp)
  800834:	00 
  800835:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800839:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083c:	89 3c 24             	mov    %edi,(%esp)
  80083f:	e8 42 fd ff ff       	call   800586 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800844:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800847:	e9 85 fd ff ff       	jmp    8005d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80084c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800850:	c7 44 24 08 a5 2a 80 	movl   $0x802aa5,0x8(%esp)
  800857:	00 
  800858:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	89 3c 24             	mov    %edi,(%esp)
  800862:	e8 1f fd ff ff       	call   800586 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800867:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80086a:	e9 62 fd ff ff       	jmp    8005d1 <vprintfmt+0x23>
  80086f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800872:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800875:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8d 50 04             	lea    0x4(%eax),%edx
  80087e:	89 55 14             	mov    %edx,0x14(%ebp)
  800881:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800883:	85 f6                	test   %esi,%esi
  800885:	b8 b4 26 80 00       	mov    $0x8026b4,%eax
  80088a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80088d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800891:	7e 06                	jle    800899 <vprintfmt+0x2eb>
  800893:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800897:	75 13                	jne    8008ac <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800899:	0f be 06             	movsbl (%esi),%eax
  80089c:	83 c6 01             	add    $0x1,%esi
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	0f 85 94 00 00 00    	jne    80093b <vprintfmt+0x38d>
  8008a7:	e9 81 00 00 00       	jmp    80092d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b0:	89 34 24             	mov    %esi,(%esp)
  8008b3:	e8 93 03 00 00       	call   800c4b <strnlen>
  8008b8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008bb:	29 c2                	sub    %eax,%edx
  8008bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8008c0:	85 d2                	test   %edx,%edx
  8008c2:	7e d5                	jle    800899 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8008c4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008c8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8008cb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8008ce:	89 d6                	mov    %edx,%esi
  8008d0:	89 cf                	mov    %ecx,%edi
  8008d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d6:	89 3c 24             	mov    %edi,(%esp)
  8008d9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008dc:	83 ee 01             	sub    $0x1,%esi
  8008df:	75 f1                	jne    8008d2 <vprintfmt+0x324>
  8008e1:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8008e4:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8008e7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8008ea:	eb ad                	jmp    800899 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008ec:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008f0:	74 1b                	je     80090d <vprintfmt+0x35f>
  8008f2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008f5:	83 fa 5e             	cmp    $0x5e,%edx
  8008f8:	76 13                	jbe    80090d <vprintfmt+0x35f>
					putch('?', putdat);
  8008fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800908:	ff 55 08             	call   *0x8(%ebp)
  80090b:	eb 0d                	jmp    80091a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80090d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800910:	89 54 24 04          	mov    %edx,0x4(%esp)
  800914:	89 04 24             	mov    %eax,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80091a:	83 eb 01             	sub    $0x1,%ebx
  80091d:	0f be 06             	movsbl (%esi),%eax
  800920:	83 c6 01             	add    $0x1,%esi
  800923:	85 c0                	test   %eax,%eax
  800925:	75 1a                	jne    800941 <vprintfmt+0x393>
  800927:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80092a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800930:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800934:	7f 1c                	jg     800952 <vprintfmt+0x3a4>
  800936:	e9 96 fc ff ff       	jmp    8005d1 <vprintfmt+0x23>
  80093b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80093e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800941:	85 ff                	test   %edi,%edi
  800943:	78 a7                	js     8008ec <vprintfmt+0x33e>
  800945:	83 ef 01             	sub    $0x1,%edi
  800948:	79 a2                	jns    8008ec <vprintfmt+0x33e>
  80094a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80094d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800950:	eb db                	jmp    80092d <vprintfmt+0x37f>
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	89 de                	mov    %ebx,%esi
  800957:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80095a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80095e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800965:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800967:	83 eb 01             	sub    $0x1,%ebx
  80096a:	75 ee                	jne    80095a <vprintfmt+0x3ac>
  80096c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800971:	e9 5b fc ff ff       	jmp    8005d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800976:	83 f9 01             	cmp    $0x1,%ecx
  800979:	7e 10                	jle    80098b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8d 50 08             	lea    0x8(%eax),%edx
  800981:	89 55 14             	mov    %edx,0x14(%ebp)
  800984:	8b 30                	mov    (%eax),%esi
  800986:	8b 78 04             	mov    0x4(%eax),%edi
  800989:	eb 26                	jmp    8009b1 <vprintfmt+0x403>
	else if (lflag)
  80098b:	85 c9                	test   %ecx,%ecx
  80098d:	74 12                	je     8009a1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 30                	mov    (%eax),%esi
  80099a:	89 f7                	mov    %esi,%edi
  80099c:	c1 ff 1f             	sar    $0x1f,%edi
  80099f:	eb 10                	jmp    8009b1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8009a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a4:	8d 50 04             	lea    0x4(%eax),%edx
  8009a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009aa:	8b 30                	mov    (%eax),%esi
  8009ac:	89 f7                	mov    %esi,%edi
  8009ae:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b1:	85 ff                	test   %edi,%edi
  8009b3:	78 0e                	js     8009c3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009b5:	89 f0                	mov    %esi,%eax
  8009b7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009b9:	be 0a 00 00 00       	mov    $0xa,%esi
  8009be:	e9 84 00 00 00       	jmp    800a47 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8009c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ce:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009d1:	89 f0                	mov    %esi,%eax
  8009d3:	89 fa                	mov    %edi,%edx
  8009d5:	f7 d8                	neg    %eax
  8009d7:	83 d2 00             	adc    $0x0,%edx
  8009da:	f7 da                	neg    %edx
			}
			base = 10;
  8009dc:	be 0a 00 00 00       	mov    $0xa,%esi
  8009e1:	eb 64                	jmp    800a47 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009e3:	89 ca                	mov    %ecx,%edx
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e8:	e8 42 fb ff ff       	call   80052f <getuint>
			base = 10;
  8009ed:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8009f2:	eb 53                	jmp    800a47 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8009f4:	89 ca                	mov    %ecx,%edx
  8009f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f9:	e8 31 fb ff ff       	call   80052f <getuint>
    			base = 8;
  8009fe:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800a03:	eb 42                	jmp    800a47 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800a05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a09:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a10:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a17:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a1e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a21:	8b 45 14             	mov    0x14(%ebp),%eax
  800a24:	8d 50 04             	lea    0x4(%eax),%edx
  800a27:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2a:	8b 00                	mov    (%eax),%eax
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a31:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800a36:	eb 0f                	jmp    800a47 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a38:	89 ca                	mov    %ecx,%edx
  800a3a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3d:	e8 ed fa ff ff       	call   80052f <getuint>
			base = 16;
  800a42:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a47:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800a4b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800a4f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800a52:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a56:	89 74 24 08          	mov    %esi,0x8(%esp)
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a61:	89 da                	mov    %ebx,%edx
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	e8 e9 f9 ff ff       	call   800454 <printnum>
			break;
  800a6b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a6e:	e9 5e fb ff ff       	jmp    8005d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a77:	89 14 24             	mov    %edx,(%esp)
  800a7a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a80:	e9 4c fb ff ff       	jmp    8005d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a89:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a90:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a93:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a97:	0f 84 34 fb ff ff    	je     8005d1 <vprintfmt+0x23>
  800a9d:	83 ee 01             	sub    $0x1,%esi
  800aa0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aa4:	75 f7                	jne    800a9d <vprintfmt+0x4ef>
  800aa6:	e9 26 fb ff ff       	jmp    8005d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800aab:	83 c4 5c             	add    $0x5c,%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	83 ec 28             	sub    $0x28,%esp
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800abf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ac2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ac6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ac9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	74 30                	je     800b04 <vsnprintf+0x51>
  800ad4:	85 d2                	test   %edx,%edx
  800ad6:	7e 2c                	jle    800b04 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  800adb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800adf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aed:	c7 04 24 69 05 80 00 	movl   $0x800569,(%esp)
  800af4:	e8 b5 fa ff ff       	call   8005ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b02:	eb 05                	jmp    800b09 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b18:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	89 04 24             	mov    %eax,(%esp)
  800b2c:	e8 82 ff ff ff       	call   800ab3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    
	...

00800b40 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 1c             	sub    $0x1c,%esp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	74 18                	je     800b68 <readline+0x28>
		fprintf(1, "%s", prompt);
  800b50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b54:	c7 44 24 04 a5 2a 80 	movl   $0x802aa5,0x4(%esp)
  800b5b:	00 
  800b5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b63:	e8 60 12 00 00       	call   801dc8 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  800b68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b6f:	e8 da f6 ff ff       	call   80024e <iscons>
  800b74:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800b76:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800b7b:	e8 98 f6 ff ff       	call   800218 <getchar>
  800b80:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800b82:	85 c0                	test   %eax,%eax
  800b84:	79 25                	jns    800bab <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800b8b:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800b8e:	0f 84 88 00 00 00    	je     800c1c <readline+0xdc>
				cprintf("read error: %e\n", c);
  800b94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b98:	c7 04 24 bf 29 80 00 	movl   $0x8029bf,(%esp)
  800b9f:	e8 93 f8 ff ff       	call   800437 <cprintf>
			return NULL;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	eb 71                	jmp    800c1c <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800bab:	83 f8 08             	cmp    $0x8,%eax
  800bae:	74 05                	je     800bb5 <readline+0x75>
  800bb0:	83 f8 7f             	cmp    $0x7f,%eax
  800bb3:	75 19                	jne    800bce <readline+0x8e>
  800bb5:	85 f6                	test   %esi,%esi
  800bb7:	7e 15                	jle    800bce <readline+0x8e>
			if (echoing)
  800bb9:	85 ff                	test   %edi,%edi
  800bbb:	74 0c                	je     800bc9 <readline+0x89>
				cputchar('\b');
  800bbd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800bc4:	e8 2e f6 ff ff       	call   8001f7 <cputchar>
			i--;
  800bc9:	83 ee 01             	sub    $0x1,%esi
  800bcc:	eb ad                	jmp    800b7b <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800bce:	83 fb 1f             	cmp    $0x1f,%ebx
  800bd1:	7e 1f                	jle    800bf2 <readline+0xb2>
  800bd3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800bd9:	7f 17                	jg     800bf2 <readline+0xb2>
			if (echoing)
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	74 08                	je     800be7 <readline+0xa7>
				cputchar(c);
  800bdf:	89 1c 24             	mov    %ebx,(%esp)
  800be2:	e8 10 f6 ff ff       	call   8001f7 <cputchar>
			buf[i++] = c;
  800be7:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800bed:	83 c6 01             	add    $0x1,%esi
  800bf0:	eb 89                	jmp    800b7b <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800bf2:	83 fb 0a             	cmp    $0xa,%ebx
  800bf5:	74 09                	je     800c00 <readline+0xc0>
  800bf7:	83 fb 0d             	cmp    $0xd,%ebx
  800bfa:	0f 85 7b ff ff ff    	jne    800b7b <readline+0x3b>
			if (echoing)
  800c00:	85 ff                	test   %edi,%edi
  800c02:	74 0c                	je     800c10 <readline+0xd0>
				cputchar('\n');
  800c04:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800c0b:	e8 e7 f5 ff ff       	call   8001f7 <cputchar>
			buf[i] = 0;
  800c10:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800c17:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800c1c:	83 c4 1c             	add    $0x1c,%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    
	...

00800c30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c3e:	74 09                	je     800c49 <strlen+0x19>
		n++;
  800c40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c47:	75 f7                	jne    800c40 <strlen+0x10>
		n++;
	return n;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	53                   	push   %ebx
  800c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	85 c9                	test   %ecx,%ecx
  800c5c:	74 1a                	je     800c78 <strnlen+0x2d>
  800c5e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c61:	74 15                	je     800c78 <strnlen+0x2d>
  800c63:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c68:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6a:	39 ca                	cmp    %ecx,%edx
  800c6c:	74 0a                	je     800c78 <strnlen+0x2d>
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c76:	75 f0                	jne    800c68 <strnlen+0x1d>
		n++;
	return n;
}
  800c78:	5b                   	pop    %ebx
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c8e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c91:	83 c2 01             	add    $0x1,%edx
  800c94:	84 c9                	test   %cl,%cl
  800c96:	75 f2                	jne    800c8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 08             	sub    $0x8,%esp
  800ca2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca5:	89 1c 24             	mov    %ebx,(%esp)
  800ca8:	e8 83 ff ff ff       	call   800c30 <strlen>
	strcpy(dst + len, src);
  800cad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb4:	01 d8                	add    %ebx,%eax
  800cb6:	89 04 24             	mov    %eax,(%esp)
  800cb9:	e8 bd ff ff ff       	call   800c7b <strcpy>
	return dst;
}
  800cbe:	89 d8                	mov    %ebx,%eax
  800cc0:	83 c4 08             	add    $0x8,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd4:	85 f6                	test   %esi,%esi
  800cd6:	74 18                	je     800cf0 <strncpy+0x2a>
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800cdd:	0f b6 1a             	movzbl (%edx),%ebx
  800ce0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ce3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ce6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce9:	83 c1 01             	add    $0x1,%ecx
  800cec:	39 f1                	cmp    %esi,%ecx
  800cee:	75 ed                	jne    800cdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d00:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d03:	89 f8                	mov    %edi,%eax
  800d05:	85 f6                	test   %esi,%esi
  800d07:	74 2b                	je     800d34 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d09:	83 fe 01             	cmp    $0x1,%esi
  800d0c:	74 23                	je     800d31 <strlcpy+0x3d>
  800d0e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d11:	84 c9                	test   %cl,%cl
  800d13:	74 1c                	je     800d31 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d15:	83 ee 02             	sub    $0x2,%esi
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d1d:	88 08                	mov    %cl,(%eax)
  800d1f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d22:	39 f2                	cmp    %esi,%edx
  800d24:	74 0b                	je     800d31 <strlcpy+0x3d>
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d2d:	84 c9                	test   %cl,%cl
  800d2f:	75 ec                	jne    800d1d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d34:	29 f8                	sub    %edi,%eax
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d41:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d44:	0f b6 01             	movzbl (%ecx),%eax
  800d47:	84 c0                	test   %al,%al
  800d49:	74 16                	je     800d61 <strcmp+0x26>
  800d4b:	3a 02                	cmp    (%edx),%al
  800d4d:	75 12                	jne    800d61 <strcmp+0x26>
		p++, q++;
  800d4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d56:	84 c0                	test   %al,%al
  800d58:	74 07                	je     800d61 <strcmp+0x26>
  800d5a:	83 c1 01             	add    $0x1,%ecx
  800d5d:	3a 02                	cmp    (%edx),%al
  800d5f:	74 ee                	je     800d4f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d61:	0f b6 c0             	movzbl %al,%eax
  800d64:	0f b6 12             	movzbl (%edx),%edx
  800d67:	29 d0                	sub    %edx,%eax
}
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d75:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d7d:	85 d2                	test   %edx,%edx
  800d7f:	74 28                	je     800da9 <strncmp+0x3e>
  800d81:	0f b6 01             	movzbl (%ecx),%eax
  800d84:	84 c0                	test   %al,%al
  800d86:	74 24                	je     800dac <strncmp+0x41>
  800d88:	3a 03                	cmp    (%ebx),%al
  800d8a:	75 20                	jne    800dac <strncmp+0x41>
  800d8c:	83 ea 01             	sub    $0x1,%edx
  800d8f:	74 13                	je     800da4 <strncmp+0x39>
		n--, p++, q++;
  800d91:	83 c1 01             	add    $0x1,%ecx
  800d94:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d97:	0f b6 01             	movzbl (%ecx),%eax
  800d9a:	84 c0                	test   %al,%al
  800d9c:	74 0e                	je     800dac <strncmp+0x41>
  800d9e:	3a 03                	cmp    (%ebx),%al
  800da0:	74 ea                	je     800d8c <strncmp+0x21>
  800da2:	eb 08                	jmp    800dac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 01             	movzbl (%ecx),%eax
  800daf:	0f b6 13             	movzbl (%ebx),%edx
  800db2:	29 d0                	sub    %edx,%eax
  800db4:	eb f3                	jmp    800da9 <strncmp+0x3e>

00800db6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc0:	0f b6 10             	movzbl (%eax),%edx
  800dc3:	84 d2                	test   %dl,%dl
  800dc5:	74 1c                	je     800de3 <strchr+0x2d>
		if (*s == c)
  800dc7:	38 ca                	cmp    %cl,%dl
  800dc9:	75 09                	jne    800dd4 <strchr+0x1e>
  800dcb:	eb 1b                	jmp    800de8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dcd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800dd0:	38 ca                	cmp    %cl,%dl
  800dd2:	74 14                	je     800de8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dd4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800dd8:	84 d2                	test   %dl,%dl
  800dda:	75 f1                	jne    800dcd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  800de1:	eb 05                	jmp    800de8 <strchr+0x32>
  800de3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df4:	0f b6 10             	movzbl (%eax),%edx
  800df7:	84 d2                	test   %dl,%dl
  800df9:	74 14                	je     800e0f <strfind+0x25>
		if (*s == c)
  800dfb:	38 ca                	cmp    %cl,%dl
  800dfd:	75 06                	jne    800e05 <strfind+0x1b>
  800dff:	eb 0e                	jmp    800e0f <strfind+0x25>
  800e01:	38 ca                	cmp    %cl,%dl
  800e03:	74 0a                	je     800e0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e05:	83 c0 01             	add    $0x1,%eax
  800e08:	0f b6 10             	movzbl (%eax),%edx
  800e0b:	84 d2                	test   %dl,%dl
  800e0d:	75 f2                	jne    800e01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e29:	85 c9                	test   %ecx,%ecx
  800e2b:	74 30                	je     800e5d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e33:	75 25                	jne    800e5a <memset+0x49>
  800e35:	f6 c1 03             	test   $0x3,%cl
  800e38:	75 20                	jne    800e5a <memset+0x49>
		c &= 0xFF;
  800e3a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e3d:	89 d3                	mov    %edx,%ebx
  800e3f:	c1 e3 08             	shl    $0x8,%ebx
  800e42:	89 d6                	mov    %edx,%esi
  800e44:	c1 e6 18             	shl    $0x18,%esi
  800e47:	89 d0                	mov    %edx,%eax
  800e49:	c1 e0 10             	shl    $0x10,%eax
  800e4c:	09 f0                	or     %esi,%eax
  800e4e:	09 d0                	or     %edx,%eax
  800e50:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e52:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e55:	fc                   	cld    
  800e56:	f3 ab                	rep stos %eax,%es:(%edi)
  800e58:	eb 03                	jmp    800e5d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e5a:	fc                   	cld    
  800e5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e81:	39 c6                	cmp    %eax,%esi
  800e83:	73 36                	jae    800ebb <memmove+0x4f>
  800e85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e88:	39 d0                	cmp    %edx,%eax
  800e8a:	73 2f                	jae    800ebb <memmove+0x4f>
		s += n;
		d += n;
  800e8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e8f:	f6 c2 03             	test   $0x3,%dl
  800e92:	75 1b                	jne    800eaf <memmove+0x43>
  800e94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e9a:	75 13                	jne    800eaf <memmove+0x43>
  800e9c:	f6 c1 03             	test   $0x3,%cl
  800e9f:	75 0e                	jne    800eaf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ea1:	83 ef 04             	sub    $0x4,%edi
  800ea4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ea7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eaa:	fd                   	std    
  800eab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ead:	eb 09                	jmp    800eb8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eaf:	83 ef 01             	sub    $0x1,%edi
  800eb2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb5:	fd                   	std    
  800eb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eb8:	fc                   	cld    
  800eb9:	eb 20                	jmp    800edb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ec1:	75 13                	jne    800ed6 <memmove+0x6a>
  800ec3:	a8 03                	test   $0x3,%al
  800ec5:	75 0f                	jne    800ed6 <memmove+0x6a>
  800ec7:	f6 c1 03             	test   $0x3,%cl
  800eca:	75 0a                	jne    800ed6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ecc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ecf:	89 c7                	mov    %eax,%edi
  800ed1:	fc                   	cld    
  800ed2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed4:	eb 05                	jmp    800edb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed6:	89 c7                	mov    %eax,%edi
  800ed8:	fc                   	cld    
  800ed9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ede:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee1:	89 ec                	mov    %ebp,%esp
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800eee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	89 04 24             	mov    %eax,(%esp)
  800eff:	e8 68 ff ff ff       	call   800e6c <memmove>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f12:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1a:	85 ff                	test   %edi,%edi
  800f1c:	74 37                	je     800f55 <memcmp+0x4f>
		if (*s1 != *s2)
  800f1e:	0f b6 03             	movzbl (%ebx),%eax
  800f21:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f24:	83 ef 01             	sub    $0x1,%edi
  800f27:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f2c:	38 c8                	cmp    %cl,%al
  800f2e:	74 1c                	je     800f4c <memcmp+0x46>
  800f30:	eb 10                	jmp    800f42 <memcmp+0x3c>
  800f32:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f37:	83 c2 01             	add    $0x1,%edx
  800f3a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f3e:	38 c8                	cmp    %cl,%al
  800f40:	74 0a                	je     800f4c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f42:	0f b6 c0             	movzbl %al,%eax
  800f45:	0f b6 c9             	movzbl %cl,%ecx
  800f48:	29 c8                	sub    %ecx,%eax
  800f4a:	eb 09                	jmp    800f55 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4c:	39 fa                	cmp    %edi,%edx
  800f4e:	75 e2                	jne    800f32 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f65:	39 d0                	cmp    %edx,%eax
  800f67:	73 19                	jae    800f82 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f6d:	38 08                	cmp    %cl,(%eax)
  800f6f:	75 06                	jne    800f77 <memfind+0x1d>
  800f71:	eb 0f                	jmp    800f82 <memfind+0x28>
  800f73:	38 08                	cmp    %cl,(%eax)
  800f75:	74 0b                	je     800f82 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f77:	83 c0 01             	add    $0x1,%eax
  800f7a:	39 d0                	cmp    %edx,%eax
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	75 f1                	jne    800f73 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f90:	0f b6 02             	movzbl (%edx),%eax
  800f93:	3c 20                	cmp    $0x20,%al
  800f95:	74 04                	je     800f9b <strtol+0x17>
  800f97:	3c 09                	cmp    $0x9,%al
  800f99:	75 0e                	jne    800fa9 <strtol+0x25>
		s++;
  800f9b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f9e:	0f b6 02             	movzbl (%edx),%eax
  800fa1:	3c 20                	cmp    $0x20,%al
  800fa3:	74 f6                	je     800f9b <strtol+0x17>
  800fa5:	3c 09                	cmp    $0x9,%al
  800fa7:	74 f2                	je     800f9b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fa9:	3c 2b                	cmp    $0x2b,%al
  800fab:	75 0a                	jne    800fb7 <strtol+0x33>
		s++;
  800fad:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb5:	eb 10                	jmp    800fc7 <strtol+0x43>
  800fb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fbc:	3c 2d                	cmp    $0x2d,%al
  800fbe:	75 07                	jne    800fc7 <strtol+0x43>
		s++, neg = 1;
  800fc0:	83 c2 01             	add    $0x1,%edx
  800fc3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fc7:	85 db                	test   %ebx,%ebx
  800fc9:	0f 94 c0             	sete   %al
  800fcc:	74 05                	je     800fd3 <strtol+0x4f>
  800fce:	83 fb 10             	cmp    $0x10,%ebx
  800fd1:	75 15                	jne    800fe8 <strtol+0x64>
  800fd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fd6:	75 10                	jne    800fe8 <strtol+0x64>
  800fd8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fdc:	75 0a                	jne    800fe8 <strtol+0x64>
		s += 2, base = 16;
  800fde:	83 c2 02             	add    $0x2,%edx
  800fe1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fe6:	eb 13                	jmp    800ffb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800fe8:	84 c0                	test   %al,%al
  800fea:	74 0f                	je     800ffb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ff1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff4:	75 05                	jne    800ffb <strtol+0x77>
		s++, base = 8;
  800ff6:	83 c2 01             	add    $0x1,%edx
  800ff9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  801000:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801002:	0f b6 0a             	movzbl (%edx),%ecx
  801005:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801008:	80 fb 09             	cmp    $0x9,%bl
  80100b:	77 08                	ja     801015 <strtol+0x91>
			dig = *s - '0';
  80100d:	0f be c9             	movsbl %cl,%ecx
  801010:	83 e9 30             	sub    $0x30,%ecx
  801013:	eb 1e                	jmp    801033 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801015:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801018:	80 fb 19             	cmp    $0x19,%bl
  80101b:	77 08                	ja     801025 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80101d:	0f be c9             	movsbl %cl,%ecx
  801020:	83 e9 57             	sub    $0x57,%ecx
  801023:	eb 0e                	jmp    801033 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801025:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801028:	80 fb 19             	cmp    $0x19,%bl
  80102b:	77 14                	ja     801041 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80102d:	0f be c9             	movsbl %cl,%ecx
  801030:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801033:	39 f1                	cmp    %esi,%ecx
  801035:	7d 0e                	jge    801045 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801037:	83 c2 01             	add    $0x1,%edx
  80103a:	0f af c6             	imul   %esi,%eax
  80103d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80103f:	eb c1                	jmp    801002 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801041:	89 c1                	mov    %eax,%ecx
  801043:	eb 02                	jmp    801047 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801045:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801047:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80104b:	74 05                	je     801052 <strtol+0xce>
		*endptr = (char *) s;
  80104d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801050:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801052:	89 ca                	mov    %ecx,%edx
  801054:	f7 da                	neg    %edx
  801056:	85 ff                	test   %edi,%edi
  801058:	0f 45 c2             	cmovne %edx,%eax
}
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801069:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80106c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106f:	b8 00 00 00 00       	mov    $0x0,%eax
  801074:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801077:	8b 55 08             	mov    0x8(%ebp),%edx
  80107a:	89 c3                	mov    %eax,%ebx
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	89 c6                	mov    %eax,%esi
  801080:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801082:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801085:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801088:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108b:	89 ec                	mov    %ebp,%esp
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    

0080108f <sys_cgetc>:

int
sys_cgetc(void)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801098:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80109b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109e:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a8:	89 d1                	mov    %edx,%ecx
  8010aa:	89 d3                	mov    %edx,%ebx
  8010ac:	89 d7                	mov    %edx,%edi
  8010ae:	89 d6                	mov    %edx,%esi
  8010b0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010bb:	89 ec                	mov    %ebp,%esp
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 38             	sub    $0x38,%esp
  8010c5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010cb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010db:	89 cb                	mov    %ecx,%ebx
  8010dd:	89 cf                	mov    %ecx,%edi
  8010df:	89 ce                	mov    %ecx,%esi
  8010e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	7e 28                	jle    80110f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010eb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801102:	00 
  801103:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  80110a:	e8 2d f2 ff ff       	call   80033c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80110f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801112:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801115:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801118:	89 ec                	mov    %ebp,%esp
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801125:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801128:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112b:	ba 00 00 00 00       	mov    $0x0,%edx
  801130:	b8 02 00 00 00       	mov    $0x2,%eax
  801135:	89 d1                	mov    %edx,%ecx
  801137:	89 d3                	mov    %edx,%ebx
  801139:	89 d7                	mov    %edx,%edi
  80113b:	89 d6                	mov    %edx,%esi
  80113d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80113f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801142:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801145:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801148:	89 ec                	mov    %ebp,%esp
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <sys_yield>:

void
sys_yield(void)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801155:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801158:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115b:	ba 00 00 00 00       	mov    $0x0,%edx
  801160:	b8 0b 00 00 00       	mov    $0xb,%eax
  801165:	89 d1                	mov    %edx,%ecx
  801167:	89 d3                	mov    %edx,%ebx
  801169:	89 d7                	mov    %edx,%edi
  80116b:	89 d6                	mov    %edx,%esi
  80116d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80116f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801178:	89 ec                	mov    %ebp,%esp
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 38             	sub    $0x38,%esp
  801182:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801185:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801188:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118b:	be 00 00 00 00       	mov    $0x0,%esi
  801190:	b8 04 00 00 00       	mov    $0x4,%eax
  801195:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
  80119e:	89 f7                	mov    %esi,%edi
  8011a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	7e 28                	jle    8011ce <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011aa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8011b1:	00 
  8011b2:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c1:	00 
  8011c2:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  8011c9:	e8 6e f1 ff ff       	call   80033c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011d7:	89 ec                	mov    %ebp,%esp
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 38             	sub    $0x38,%esp
  8011e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8011ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8011f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801200:	85 c0                	test   %eax,%eax
  801202:	7e 28                	jle    80122c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801204:	89 44 24 10          	mov    %eax,0x10(%esp)
  801208:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80120f:	00 
  801210:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  801217:	00 
  801218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801227:	e8 10 f1 ff ff       	call   80033c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80122c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80122f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801232:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801235:	89 ec                	mov    %ebp,%esp
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 38             	sub    $0x38,%esp
  80123f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801242:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801245:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124d:	b8 06 00 00 00       	mov    $0x6,%eax
  801252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801255:	8b 55 08             	mov    0x8(%ebp),%edx
  801258:	89 df                	mov    %ebx,%edi
  80125a:	89 de                	mov    %ebx,%esi
  80125c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125e:	85 c0                	test   %eax,%eax
  801260:	7e 28                	jle    80128a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801262:	89 44 24 10          	mov    %eax,0x10(%esp)
  801266:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80126d:	00 
  80126e:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  801275:	00 
  801276:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127d:	00 
  80127e:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801285:	e8 b2 f0 ff ff       	call   80033c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80128a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80128d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801290:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801293:	89 ec                	mov    %ebp,%esp
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 38             	sub    $0x38,%esp
  80129d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012a0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012a3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b6:	89 df                	mov    %ebx,%edi
  8012b8:	89 de                	mov    %ebx,%esi
  8012ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	7e 28                	jle    8012e8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012db:	00 
  8012dc:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  8012e3:	e8 54 f0 ff ff       	call   80033c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012f1:	89 ec                	mov    %ebp,%esp
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 38             	sub    $0x38,%esp
  8012fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801301:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
  801309:	b8 09 00 00 00       	mov    $0x9,%eax
  80130e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801311:	8b 55 08             	mov    0x8(%ebp),%edx
  801314:	89 df                	mov    %ebx,%edi
  801316:	89 de                	mov    %ebx,%esi
  801318:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80131a:	85 c0                	test   %eax,%eax
  80131c:	7e 28                	jle    801346 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801322:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801329:	00 
  80132a:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  801331:	00 
  801332:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801339:	00 
  80133a:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801341:	e8 f6 ef ff ff       	call   80033c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801346:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801349:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80134c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80134f:	89 ec                	mov    %ebp,%esp
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 38             	sub    $0x38,%esp
  801359:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80135c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80135f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801362:	bb 00 00 00 00       	mov    $0x0,%ebx
  801367:	b8 0a 00 00 00       	mov    $0xa,%eax
  80136c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136f:	8b 55 08             	mov    0x8(%ebp),%edx
  801372:	89 df                	mov    %ebx,%edi
  801374:	89 de                	mov    %ebx,%esi
  801376:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801378:	85 c0                	test   %eax,%eax
  80137a:	7e 28                	jle    8013a4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801380:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801387:	00 
  801388:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  80138f:	00 
  801390:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801397:	00 
  801398:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  80139f:	e8 98 ef ff ff       	call   80033c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ad:	89 ec                	mov    %ebp,%esp
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013bd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c0:	be 00 00 00 00       	mov    $0x0,%esi
  8013c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8013ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8013d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013e1:	89 ec                	mov    %ebp,%esp
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 38             	sub    $0x38,%esp
  8013eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801401:	89 cb                	mov    %ecx,%ebx
  801403:	89 cf                	mov    %ecx,%edi
  801405:	89 ce                	mov    %ecx,%esi
  801407:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801409:	85 c0                	test   %eax,%eax
  80140b:	7e 28                	jle    801435 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80140d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801411:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801418:	00 
  801419:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  801420:	00 
  801421:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801428:	00 
  801429:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801430:	e8 07 ef ff ff       	call   80033c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801435:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801438:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80143b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80143e:	89 ec                	mov    %ebp,%esp
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80144b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80144e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801451:	b9 00 00 00 00       	mov    $0x0,%ecx
  801456:	b8 0e 00 00 00       	mov    $0xe,%eax
  80145b:	8b 55 08             	mov    0x8(%ebp),%edx
  80145e:	89 cb                	mov    %ecx,%ebx
  801460:	89 cf                	mov    %ecx,%edi
  801462:	89 ce                	mov    %ecx,%esi
  801464:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801466:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801469:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80146c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80146f:	89 ec                	mov    %ebp,%esp
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    
	...

00801480 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	05 00 00 00 30       	add    $0x30000000,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
}
  80148e:	5d                   	pop    %ebp
  80148f:	c3                   	ret    

00801490 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801496:	8b 45 08             	mov    0x8(%ebp),%eax
  801499:	89 04 24             	mov    %eax,(%esp)
  80149c:	e8 df ff ff ff       	call   801480 <fd2num>
  8014a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014b7:	a8 01                	test   $0x1,%al
  8014b9:	74 34                	je     8014ef <fd_alloc+0x44>
  8014bb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014c0:	a8 01                	test   $0x1,%al
  8014c2:	74 32                	je     8014f6 <fd_alloc+0x4b>
  8014c4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014c9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	c1 ea 16             	shr    $0x16,%edx
  8014d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d7:	f6 c2 01             	test   $0x1,%dl
  8014da:	74 1f                	je     8014fb <fd_alloc+0x50>
  8014dc:	89 c2                	mov    %eax,%edx
  8014de:	c1 ea 0c             	shr    $0xc,%edx
  8014e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e8:	f6 c2 01             	test   $0x1,%dl
  8014eb:	75 17                	jne    801504 <fd_alloc+0x59>
  8014ed:	eb 0c                	jmp    8014fb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014ef:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8014f4:	eb 05                	jmp    8014fb <fd_alloc+0x50>
  8014f6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8014fb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801502:	eb 17                	jmp    80151b <fd_alloc+0x70>
  801504:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801509:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80150e:	75 b9                	jne    8014c9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801510:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801516:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80151b:	5b                   	pop    %ebx
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801524:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801529:	83 fa 1f             	cmp    $0x1f,%edx
  80152c:	77 3f                	ja     80156d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80152e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801534:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801537:	89 d0                	mov    %edx,%eax
  801539:	c1 e8 16             	shr    $0x16,%eax
  80153c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801543:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801548:	f6 c1 01             	test   $0x1,%cl
  80154b:	74 20                	je     80156d <fd_lookup+0x4f>
  80154d:	89 d0                	mov    %edx,%eax
  80154f:	c1 e8 0c             	shr    $0xc,%eax
  801552:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801559:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80155e:	f6 c1 01             	test   $0x1,%cl
  801561:	74 0a                	je     80156d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801563:	8b 45 0c             	mov    0xc(%ebp),%eax
  801566:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801568:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	53                   	push   %ebx
  801573:	83 ec 14             	sub    $0x14,%esp
  801576:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80157c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801581:	39 0d 24 30 80 00    	cmp    %ecx,0x803024
  801587:	75 17                	jne    8015a0 <dev_lookup+0x31>
  801589:	eb 07                	jmp    801592 <dev_lookup+0x23>
  80158b:	39 0a                	cmp    %ecx,(%edx)
  80158d:	75 11                	jne    8015a0 <dev_lookup+0x31>
  80158f:	90                   	nop
  801590:	eb 05                	jmp    801597 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801592:	ba 24 30 80 00       	mov    $0x803024,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801597:	89 13                	mov    %edx,(%ebx)
			return 0;
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
  80159e:	eb 35                	jmp    8015d5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015a0:	83 c0 01             	add    $0x1,%eax
  8015a3:	8b 14 85 7c 2a 80 00 	mov    0x802a7c(,%eax,4),%edx
  8015aa:	85 d2                	test   %edx,%edx
  8015ac:	75 dd                	jne    80158b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015ae:	a1 04 44 80 00       	mov    0x804404,%eax
  8015b3:	8b 40 48             	mov    0x48(%eax),%eax
  8015b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015be:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8015c5:	e8 6d ee ff ff       	call   800437 <cprintf>
	*dev = 0;
  8015ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015d5:	83 c4 14             	add    $0x14,%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 38             	sub    $0x38,%esp
  8015e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ed:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015f1:	89 3c 24             	mov    %edi,(%esp)
  8015f4:	e8 87 fe ff ff       	call   801480 <fd2num>
  8015f9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8015fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801600:	89 04 24             	mov    %eax,(%esp)
  801603:	e8 16 ff ff ff       	call   80151e <fd_lookup>
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 05                	js     801613 <fd_close+0x38>
	    || fd != fd2)
  80160e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801611:	74 0e                	je     801621 <fd_close+0x46>
		return (must_exist ? r : 0);
  801613:	89 f0                	mov    %esi,%eax
  801615:	84 c0                	test   %al,%al
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
  80161c:	0f 44 d8             	cmove  %eax,%ebx
  80161f:	eb 3d                	jmp    80165e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801621:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801624:	89 44 24 04          	mov    %eax,0x4(%esp)
  801628:	8b 07                	mov    (%edi),%eax
  80162a:	89 04 24             	mov    %eax,(%esp)
  80162d:	e8 3d ff ff ff       	call   80156f <dev_lookup>
  801632:	89 c3                	mov    %eax,%ebx
  801634:	85 c0                	test   %eax,%eax
  801636:	78 16                	js     80164e <fd_close+0x73>
		if (dev->dev_close)
  801638:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80163b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80163e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801643:	85 c0                	test   %eax,%eax
  801645:	74 07                	je     80164e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801647:	89 3c 24             	mov    %edi,(%esp)
  80164a:	ff d0                	call   *%eax
  80164c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80164e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801652:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801659:	e8 db fb ff ff       	call   801239 <sys_page_unmap>
	return r;
}
  80165e:	89 d8                	mov    %ebx,%eax
  801660:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801663:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801666:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801669:	89 ec                	mov    %ebp,%esp
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 99 fe ff ff       	call   80151e <fd_lookup>
  801685:	85 c0                	test   %eax,%eax
  801687:	78 13                	js     80169c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801689:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801690:	00 
  801691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801694:	89 04 24             	mov    %eax,(%esp)
  801697:	e8 3f ff ff ff       	call   8015db <fd_close>
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <close_all>:

void
close_all(void)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016aa:	89 1c 24             	mov    %ebx,(%esp)
  8016ad:	e8 bb ff ff ff       	call   80166d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b2:	83 c3 01             	add    $0x1,%ebx
  8016b5:	83 fb 20             	cmp    $0x20,%ebx
  8016b8:	75 f0                	jne    8016aa <close_all+0xc>
		close(i);
}
  8016ba:	83 c4 14             	add    $0x14,%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 58             	sub    $0x58,%esp
  8016c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	89 04 24             	mov    %eax,(%esp)
  8016df:	e8 3a fe ff ff       	call   80151e <fd_lookup>
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	0f 88 e1 00 00 00    	js     8017cf <dup+0x10f>
		return r;
	close(newfdnum);
  8016ee:	89 3c 24             	mov    %edi,(%esp)
  8016f1:	e8 77 ff ff ff       	call   80166d <close>

	newfd = INDEX2FD(newfdnum);
  8016f6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016fc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801702:	89 04 24             	mov    %eax,(%esp)
  801705:	e8 86 fd ff ff       	call   801490 <fd2data>
  80170a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80170c:	89 34 24             	mov    %esi,(%esp)
  80170f:	e8 7c fd ff ff       	call   801490 <fd2data>
  801714:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801717:	89 d8                	mov    %ebx,%eax
  801719:	c1 e8 16             	shr    $0x16,%eax
  80171c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801723:	a8 01                	test   $0x1,%al
  801725:	74 46                	je     80176d <dup+0xad>
  801727:	89 d8                	mov    %ebx,%eax
  801729:	c1 e8 0c             	shr    $0xc,%eax
  80172c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801733:	f6 c2 01             	test   $0x1,%dl
  801736:	74 35                	je     80176d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801738:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173f:	25 07 0e 00 00       	and    $0xe07,%eax
  801744:	89 44 24 10          	mov    %eax,0x10(%esp)
  801748:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80174b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80174f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801756:	00 
  801757:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801762:	e8 74 fa ff ff       	call   8011db <sys_page_map>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 3b                	js     8017a8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80176d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801770:	89 c2                	mov    %eax,%edx
  801772:	c1 ea 0c             	shr    $0xc,%edx
  801775:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80177c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801782:	89 54 24 10          	mov    %edx,0x10(%esp)
  801786:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80178a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801791:	00 
  801792:	89 44 24 04          	mov    %eax,0x4(%esp)
  801796:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179d:	e8 39 fa ff ff       	call   8011db <sys_page_map>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	79 25                	jns    8017cd <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b3:	e8 81 fa ff ff       	call   801239 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c6:	e8 6e fa ff ff       	call   801239 <sys_page_unmap>
	return r;
  8017cb:	eb 02                	jmp    8017cf <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017cd:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017cf:	89 d8                	mov    %ebx,%eax
  8017d1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017d4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017da:	89 ec                	mov    %ebp,%esp
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 24             	sub    $0x24,%esp
  8017e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ef:	89 1c 24             	mov    %ebx,(%esp)
  8017f2:	e8 27 fd ff ff       	call   80151e <fd_lookup>
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 6d                	js     801868 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	8b 00                	mov    (%eax),%eax
  801807:	89 04 24             	mov    %eax,(%esp)
  80180a:	e8 60 fd ff ff       	call   80156f <dev_lookup>
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 55                	js     801868 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801816:	8b 50 08             	mov    0x8(%eax),%edx
  801819:	83 e2 03             	and    $0x3,%edx
  80181c:	83 fa 01             	cmp    $0x1,%edx
  80181f:	75 23                	jne    801844 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801821:	a1 04 44 80 00       	mov    0x804404,%eax
  801826:	8b 40 48             	mov    0x48(%eax),%eax
  801829:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80182d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801831:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  801838:	e8 fa eb ff ff       	call   800437 <cprintf>
		return -E_INVAL;
  80183d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801842:	eb 24                	jmp    801868 <read+0x8a>
	}
	if (!dev->dev_read)
  801844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801847:	8b 52 08             	mov    0x8(%edx),%edx
  80184a:	85 d2                	test   %edx,%edx
  80184c:	74 15                	je     801863 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80184e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801851:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801858:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80185c:	89 04 24             	mov    %eax,(%esp)
  80185f:	ff d2                	call   *%edx
  801861:	eb 05                	jmp    801868 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801863:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801868:	83 c4 24             	add    $0x24,%esp
  80186b:	5b                   	pop    %ebx
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	57                   	push   %edi
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
  801874:	83 ec 1c             	sub    $0x1c,%esp
  801877:	8b 7d 08             	mov    0x8(%ebp),%edi
  80187a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80187d:	b8 00 00 00 00       	mov    $0x0,%eax
  801882:	85 f6                	test   %esi,%esi
  801884:	74 30                	je     8018b6 <readn+0x48>
  801886:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80188b:	89 f2                	mov    %esi,%edx
  80188d:	29 c2                	sub    %eax,%edx
  80188f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801893:	03 45 0c             	add    0xc(%ebp),%eax
  801896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189a:	89 3c 24             	mov    %edi,(%esp)
  80189d:	e8 3c ff ff ff       	call   8017de <read>
		if (m < 0)
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 10                	js     8018b6 <readn+0x48>
			return m;
		if (m == 0)
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	74 0a                	je     8018b4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018aa:	01 c3                	add    %eax,%ebx
  8018ac:	89 d8                	mov    %ebx,%eax
  8018ae:	39 f3                	cmp    %esi,%ebx
  8018b0:	72 d9                	jb     80188b <readn+0x1d>
  8018b2:	eb 02                	jmp    8018b6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018b4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018b6:	83 c4 1c             	add    $0x1c,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5f                   	pop    %edi
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 24             	sub    $0x24,%esp
  8018c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cf:	89 1c 24             	mov    %ebx,(%esp)
  8018d2:	e8 47 fc ff ff       	call   80151e <fd_lookup>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 68                	js     801943 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e5:	8b 00                	mov    (%eax),%eax
  8018e7:	89 04 24             	mov    %eax,(%esp)
  8018ea:	e8 80 fc ff ff       	call   80156f <dev_lookup>
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 50                	js     801943 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018fa:	75 23                	jne    80191f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018fc:	a1 04 44 80 00       	mov    0x804404,%eax
  801901:	8b 40 48             	mov    0x48(%eax),%eax
  801904:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190c:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  801913:	e8 1f eb ff ff       	call   800437 <cprintf>
		return -E_INVAL;
  801918:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80191d:	eb 24                	jmp    801943 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80191f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801922:	8b 52 0c             	mov    0xc(%edx),%edx
  801925:	85 d2                	test   %edx,%edx
  801927:	74 15                	je     80193e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801929:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80192c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801930:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801933:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801937:	89 04 24             	mov    %eax,(%esp)
  80193a:	ff d2                	call   *%edx
  80193c:	eb 05                	jmp    801943 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80193e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801943:	83 c4 24             	add    $0x24,%esp
  801946:	5b                   	pop    %ebx
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <seek>:

int
seek(int fdnum, off_t offset)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80194f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801952:	89 44 24 04          	mov    %eax,0x4(%esp)
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	89 04 24             	mov    %eax,(%esp)
  80195c:	e8 bd fb ff ff       	call   80151e <fd_lookup>
  801961:	85 c0                	test   %eax,%eax
  801963:	78 0e                	js     801973 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801965:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801968:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	53                   	push   %ebx
  801979:	83 ec 24             	sub    $0x24,%esp
  80197c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	89 1c 24             	mov    %ebx,(%esp)
  801989:	e8 90 fb ff ff       	call   80151e <fd_lookup>
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 61                	js     8019f3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801995:	89 44 24 04          	mov    %eax,0x4(%esp)
  801999:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199c:	8b 00                	mov    (%eax),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 c9 fb ff ff       	call   80156f <dev_lookup>
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 49                	js     8019f3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019b1:	75 23                	jne    8019d6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019b3:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019b8:	8b 40 48             	mov    0x48(%eax),%eax
  8019bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c3:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  8019ca:	e8 68 ea ff ff       	call   800437 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019d4:	eb 1d                	jmp    8019f3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d9:	8b 52 18             	mov    0x18(%edx),%edx
  8019dc:	85 d2                	test   %edx,%edx
  8019de:	74 0e                	je     8019ee <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	ff d2                	call   *%edx
  8019ec:	eb 05                	jmp    8019f3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019f3:	83 c4 24             	add    $0x24,%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 24             	sub    $0x24,%esp
  801a00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 09 fb ff ff       	call   80151e <fd_lookup>
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 52                	js     801a6b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a23:	8b 00                	mov    (%eax),%eax
  801a25:	89 04 24             	mov    %eax,(%esp)
  801a28:	e8 42 fb ff ff       	call   80156f <dev_lookup>
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 3a                	js     801a6b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a34:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a38:	74 2c                	je     801a66 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a3a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a3d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a44:	00 00 00 
	stat->st_isdir = 0;
  801a47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a4e:	00 00 00 
	stat->st_dev = dev;
  801a51:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a5e:	89 14 24             	mov    %edx,(%esp)
  801a61:	ff 50 14             	call   *0x14(%eax)
  801a64:	eb 05                	jmp    801a6b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a6b:	83 c4 24             	add    $0x24,%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 18             	sub    $0x18,%esp
  801a77:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a7a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a84:	00 
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	89 04 24             	mov    %eax,(%esp)
  801a8b:	e8 bc 01 00 00       	call   801c4c <open>
  801a90:	89 c3                	mov    %eax,%ebx
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 1b                	js     801ab1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9d:	89 1c 24             	mov    %ebx,(%esp)
  801aa0:	e8 54 ff ff ff       	call   8019f9 <fstat>
  801aa5:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa7:	89 1c 24             	mov    %ebx,(%esp)
  801aaa:	e8 be fb ff ff       	call   80166d <close>
	return r;
  801aaf:	89 f3                	mov    %esi,%ebx
}
  801ab1:	89 d8                	mov    %ebx,%eax
  801ab3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab9:	89 ec                	mov    %ebp,%esp
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    
  801abd:	00 00                	add    %al,(%eax)
	...

00801ac0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 18             	sub    $0x18,%esp
  801ac6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ac9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ad0:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801ad7:	75 11                	jne    801aea <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ae0:	e8 d0 07 00 00       	call   8022b5 <ipc_find_env>
  801ae5:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801af1:	00 
  801af2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801af9:	00 
  801afa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801afe:	a1 00 44 80 00       	mov    0x804400,%eax
  801b03:	89 04 24             	mov    %eax,(%esp)
  801b06:	e8 3f 07 00 00       	call   80224a <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801b0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b12:	00 
  801b13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1e:	e8 c1 06 00 00       	call   8021e4 <ipc_recv>
}
  801b23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b26:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b29:	89 ec                	mov    %ebp,%esp
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	53                   	push   %ebx
  801b31:	83 ec 14             	sub    $0x14,%esp
  801b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b42:	ba 00 00 00 00       	mov    $0x0,%edx
  801b47:	b8 05 00 00 00       	mov    $0x5,%eax
  801b4c:	e8 6f ff ff ff       	call   801ac0 <fsipc>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 2b                	js     801b80 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b55:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b5c:	00 
  801b5d:	89 1c 24             	mov    %ebx,(%esp)
  801b60:	e8 16 f1 ff ff       	call   800c7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b65:	a1 80 50 80 00       	mov    0x805080,%eax
  801b6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b70:	a1 84 50 80 00       	mov    0x805084,%eax
  801b75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b80:	83 c4 14             	add    $0x14,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b92:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801ba1:	e8 1a ff ff ff       	call   801ac0 <fsipc>
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 10             	sub    $0x10,%esp
  801bb0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb6:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bbe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc9:	b8 03 00 00 00       	mov    $0x3,%eax
  801bce:	e8 ed fe ff ff       	call   801ac0 <fsipc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 6a                	js     801c43 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bd9:	39 c6                	cmp    %eax,%esi
  801bdb:	73 24                	jae    801c01 <devfile_read+0x59>
  801bdd:	c7 44 24 0c 8c 2a 80 	movl   $0x802a8c,0xc(%esp)
  801be4:	00 
  801be5:	c7 44 24 08 93 2a 80 	movl   $0x802a93,0x8(%esp)
  801bec:	00 
  801bed:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801bf4:	00 
  801bf5:	c7 04 24 a8 2a 80 00 	movl   $0x802aa8,(%esp)
  801bfc:	e8 3b e7 ff ff       	call   80033c <_panic>
	assert(r <= PGSIZE);
  801c01:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c06:	7e 24                	jle    801c2c <devfile_read+0x84>
  801c08:	c7 44 24 0c b3 2a 80 	movl   $0x802ab3,0xc(%esp)
  801c0f:	00 
  801c10:	c7 44 24 08 93 2a 80 	movl   $0x802a93,0x8(%esp)
  801c17:	00 
  801c18:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c1f:	00 
  801c20:	c7 04 24 a8 2a 80 00 	movl   $0x802aa8,(%esp)
  801c27:	e8 10 e7 ff ff       	call   80033c <_panic>
	memmove(buf, &fsipcbuf, r);
  801c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c30:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c37:	00 
  801c38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 29 f2 ff ff       	call   800e6c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801c43:	89 d8                	mov    %ebx,%eax
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 20             	sub    $0x20,%esp
  801c54:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c57:	89 34 24             	mov    %esi,(%esp)
  801c5a:	e8 d1 ef ff ff       	call   800c30 <strlen>
		return -E_BAD_PATH;
  801c5f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c64:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c69:	7f 5e                	jg     801cc9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6e:	89 04 24             	mov    %eax,(%esp)
  801c71:	e8 35 f8 ff ff       	call   8014ab <fd_alloc>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 4d                	js     801cc9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c80:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c87:	e8 ef ef ff ff       	call   800c7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c97:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9c:	e8 1f fe ff ff       	call   801ac0 <fsipc>
  801ca1:	89 c3                	mov    %eax,%ebx
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	79 15                	jns    801cbc <open+0x70>
		fd_close(fd, 0);
  801ca7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cae:	00 
  801caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb2:	89 04 24             	mov    %eax,(%esp)
  801cb5:	e8 21 f9 ff ff       	call   8015db <fd_close>
		return r;
  801cba:	eb 0d                	jmp    801cc9 <open+0x7d>
	}

	return fd2num(fd);
  801cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 b9 f7 ff ff       	call   801480 <fd2num>
  801cc7:	89 c3                	mov    %eax,%ebx
}
  801cc9:	89 d8                	mov    %ebx,%eax
  801ccb:	83 c4 20             	add    $0x20,%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
	...

00801cd4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	53                   	push   %ebx
  801cd8:	83 ec 14             	sub    $0x14,%esp
  801cdb:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801cdd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801ce1:	7e 31                	jle    801d14 <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801ce3:	8b 40 04             	mov    0x4(%eax),%eax
  801ce6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cea:	8d 43 10             	lea    0x10(%ebx),%eax
  801ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf1:	8b 03                	mov    (%ebx),%eax
  801cf3:	89 04 24             	mov    %eax,(%esp)
  801cf6:	e8 c3 fb ff ff       	call   8018be <write>
		if (result > 0)
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	7e 03                	jle    801d02 <writebuf+0x2e>
			b->result += result;
  801cff:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801d02:	39 43 04             	cmp    %eax,0x4(%ebx)
  801d05:	74 0d                	je     801d14 <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801d07:	85 c0                	test   %eax,%eax
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	0f 4f c2             	cmovg  %edx,%eax
  801d11:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801d14:	83 c4 14             	add    $0x14,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <putch>:

static void
putch(int ch, void *thunk)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 04             	sub    $0x4,%esp
  801d21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801d24:	8b 43 04             	mov    0x4(%ebx),%eax
  801d27:	8b 55 08             	mov    0x8(%ebp),%edx
  801d2a:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801d2e:	83 c0 01             	add    $0x1,%eax
  801d31:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801d34:	3d 00 01 00 00       	cmp    $0x100,%eax
  801d39:	75 0e                	jne    801d49 <putch+0x2f>
		writebuf(b);
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	e8 92 ff ff ff       	call   801cd4 <writebuf>
		b->idx = 0;
  801d42:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801d49:	83 c4 04             	add    $0x4,%esp
  801d4c:	5b                   	pop    %ebx
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801d61:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801d68:	00 00 00 
	b.result = 0;
  801d6b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d72:	00 00 00 
	b.error = 1;
  801d75:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801d7c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d89:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d8d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d97:	c7 04 24 1a 1d 80 00 	movl   $0x801d1a,(%esp)
  801d9e:	e8 0b e8 ff ff       	call   8005ae <vprintfmt>
	if (b.idx > 0)
  801da3:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801daa:	7e 0b                	jle    801db7 <vfprintf+0x68>
		writebuf(&b);
  801dac:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801db2:	e8 1d ff ff ff       	call   801cd4 <writebuf>

	return (b.result ? b.result : b.error);
  801db7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801dce:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801dd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	89 04 24             	mov    %eax,(%esp)
  801de2:	e8 68 ff ff ff       	call   801d4f <vfprintf>
	va_end(ap);

	return cnt;
}
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <printf>:

int
printf(const char *fmt, ...)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801def:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801df2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801e04:	e8 46 ff ff ff       	call   801d4f <vfprintf>
	va_end(ap);

	return cnt;
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    
  801e0b:	00 00                	add    %al,(%eax)
  801e0d:	00 00                	add    %al,(%eax)
	...

00801e10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 18             	sub    $0x18,%esp
  801e16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	89 04 24             	mov    %eax,(%esp)
  801e25:	e8 66 f6 ff ff       	call   801490 <fd2data>
  801e2a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e2c:	c7 44 24 04 bf 2a 80 	movl   $0x802abf,0x4(%esp)
  801e33:	00 
  801e34:	89 34 24             	mov    %esi,(%esp)
  801e37:	e8 3f ee ff ff       	call   800c7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e3f:	2b 03                	sub    (%ebx),%eax
  801e41:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e47:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e4e:	00 00 00 
	stat->st_dev = &devpipe;
  801e51:	c7 86 88 00 00 00 40 	movl   $0x803040,0x88(%esi)
  801e58:	30 80 00 
	return 0;
}
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e60:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e63:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e66:	89 ec                	mov    %ebp,%esp
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 14             	sub    $0x14,%esp
  801e71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7f:	e8 b5 f3 ff ff       	call   801239 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e84:	89 1c 24             	mov    %ebx,(%esp)
  801e87:	e8 04 f6 ff ff       	call   801490 <fd2data>
  801e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e97:	e8 9d f3 ff ff       	call   801239 <sys_page_unmap>
}
  801e9c:	83 c4 14             	add    $0x14,%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	83 ec 2c             	sub    $0x2c,%esp
  801eab:	89 c7                	mov    %eax,%edi
  801ead:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eb0:	a1 04 44 80 00       	mov    0x804404,%eax
  801eb5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801eb8:	89 3c 24             	mov    %edi,(%esp)
  801ebb:	e8 40 04 00 00       	call   802300 <pageref>
  801ec0:	89 c6                	mov    %eax,%esi
  801ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec5:	89 04 24             	mov    %eax,(%esp)
  801ec8:	e8 33 04 00 00       	call   802300 <pageref>
  801ecd:	39 c6                	cmp    %eax,%esi
  801ecf:	0f 94 c0             	sete   %al
  801ed2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ed5:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801edb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ede:	39 cb                	cmp    %ecx,%ebx
  801ee0:	75 08                	jne    801eea <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ee2:	83 c4 2c             	add    $0x2c,%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5f                   	pop    %edi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801eea:	83 f8 01             	cmp    $0x1,%eax
  801eed:	75 c1                	jne    801eb0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eef:	8b 52 58             	mov    0x58(%edx),%edx
  801ef2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ef6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801efa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801efe:	c7 04 24 c6 2a 80 00 	movl   $0x802ac6,(%esp)
  801f05:	e8 2d e5 ff ff       	call   800437 <cprintf>
  801f0a:	eb a4                	jmp    801eb0 <_pipeisclosed+0xe>

00801f0c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 2c             	sub    $0x2c,%esp
  801f15:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f18:	89 34 24             	mov    %esi,(%esp)
  801f1b:	e8 70 f5 ff ff       	call   801490 <fd2data>
  801f20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f22:	bf 00 00 00 00       	mov    $0x0,%edi
  801f27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2b:	75 50                	jne    801f7d <devpipe_write+0x71>
  801f2d:	eb 5c                	jmp    801f8b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f2f:	89 da                	mov    %ebx,%edx
  801f31:	89 f0                	mov    %esi,%eax
  801f33:	e8 6a ff ff ff       	call   801ea2 <_pipeisclosed>
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	75 53                	jne    801f8f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f3c:	e8 0b f2 ff ff       	call   80114c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f41:	8b 43 04             	mov    0x4(%ebx),%eax
  801f44:	8b 13                	mov    (%ebx),%edx
  801f46:	83 c2 20             	add    $0x20,%edx
  801f49:	39 d0                	cmp    %edx,%eax
  801f4b:	73 e2                	jae    801f2f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f50:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801f54:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801f57:	89 c2                	mov    %eax,%edx
  801f59:	c1 fa 1f             	sar    $0x1f,%edx
  801f5c:	c1 ea 1b             	shr    $0x1b,%edx
  801f5f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801f62:	83 e1 1f             	and    $0x1f,%ecx
  801f65:	29 d1                	sub    %edx,%ecx
  801f67:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801f6b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801f6f:	83 c0 01             	add    $0x1,%eax
  801f72:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f75:	83 c7 01             	add    $0x1,%edi
  801f78:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f7b:	74 0e                	je     801f8b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f7d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f80:	8b 13                	mov    (%ebx),%edx
  801f82:	83 c2 20             	add    $0x20,%edx
  801f85:	39 d0                	cmp    %edx,%eax
  801f87:	73 a6                	jae    801f2f <devpipe_write+0x23>
  801f89:	eb c2                	jmp    801f4d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f8b:	89 f8                	mov    %edi,%eax
  801f8d:	eb 05                	jmp    801f94 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f8f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f94:	83 c4 2c             	add    $0x2c,%esp
  801f97:	5b                   	pop    %ebx
  801f98:	5e                   	pop    %esi
  801f99:	5f                   	pop    %edi
  801f9a:	5d                   	pop    %ebp
  801f9b:	c3                   	ret    

00801f9c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 28             	sub    $0x28,%esp
  801fa2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fa5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fa8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801fab:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fae:	89 3c 24             	mov    %edi,(%esp)
  801fb1:	e8 da f4 ff ff       	call   801490 <fd2data>
  801fb6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb8:	be 00 00 00 00       	mov    $0x0,%esi
  801fbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc1:	75 47                	jne    80200a <devpipe_read+0x6e>
  801fc3:	eb 52                	jmp    802017 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801fc5:	89 f0                	mov    %esi,%eax
  801fc7:	eb 5e                	jmp    802027 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fc9:	89 da                	mov    %ebx,%edx
  801fcb:	89 f8                	mov    %edi,%eax
  801fcd:	8d 76 00             	lea    0x0(%esi),%esi
  801fd0:	e8 cd fe ff ff       	call   801ea2 <_pipeisclosed>
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	75 49                	jne    802022 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801fd9:	e8 6e f1 ff ff       	call   80114c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fde:	8b 03                	mov    (%ebx),%eax
  801fe0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fe3:	74 e4                	je     801fc9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe5:	89 c2                	mov    %eax,%edx
  801fe7:	c1 fa 1f             	sar    $0x1f,%edx
  801fea:	c1 ea 1b             	shr    $0x1b,%edx
  801fed:	01 d0                	add    %edx,%eax
  801fef:	83 e0 1f             	and    $0x1f,%eax
  801ff2:	29 d0                	sub    %edx,%eax
  801ff4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ff9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ffc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801fff:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802002:	83 c6 01             	add    $0x1,%esi
  802005:	3b 75 10             	cmp    0x10(%ebp),%esi
  802008:	74 0d                	je     802017 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80200a:	8b 03                	mov    (%ebx),%eax
  80200c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80200f:	75 d4                	jne    801fe5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802011:	85 f6                	test   %esi,%esi
  802013:	75 b0                	jne    801fc5 <devpipe_read+0x29>
  802015:	eb b2                	jmp    801fc9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802017:	89 f0                	mov    %esi,%eax
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	eb 05                	jmp    802027 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802027:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80202a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80202d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802030:	89 ec                	mov    %ebp,%esp
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 48             	sub    $0x48,%esp
  80203a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80203d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802040:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802043:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802046:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802049:	89 04 24             	mov    %eax,(%esp)
  80204c:	e8 5a f4 ff ff       	call   8014ab <fd_alloc>
  802051:	89 c3                	mov    %eax,%ebx
  802053:	85 c0                	test   %eax,%eax
  802055:	0f 88 45 01 00 00    	js     8021a0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802062:	00 
  802063:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802071:	e8 06 f1 ff ff       	call   80117c <sys_page_alloc>
  802076:	89 c3                	mov    %eax,%ebx
  802078:	85 c0                	test   %eax,%eax
  80207a:	0f 88 20 01 00 00    	js     8021a0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802080:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802083:	89 04 24             	mov    %eax,(%esp)
  802086:	e8 20 f4 ff ff       	call   8014ab <fd_alloc>
  80208b:	89 c3                	mov    %eax,%ebx
  80208d:	85 c0                	test   %eax,%eax
  80208f:	0f 88 f8 00 00 00    	js     80218d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802095:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80209c:	00 
  80209d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ab:	e8 cc f0 ff ff       	call   80117c <sys_page_alloc>
  8020b0:	89 c3                	mov    %eax,%ebx
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	0f 88 d3 00 00 00    	js     80218d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020bd:	89 04 24             	mov    %eax,(%esp)
  8020c0:	e8 cb f3 ff ff       	call   801490 <fd2data>
  8020c5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020ce:	00 
  8020cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020da:	e8 9d f0 ff ff       	call   80117c <sys_page_alloc>
  8020df:	89 c3                	mov    %eax,%ebx
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	0f 88 91 00 00 00    	js     80217a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 9c f3 ff ff       	call   801490 <fd2data>
  8020f4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020fb:	00 
  8020fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802100:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802107:	00 
  802108:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802113:	e8 c3 f0 ff ff       	call   8011db <sys_page_map>
  802118:	89 c3                	mov    %eax,%ebx
  80211a:	85 c0                	test   %eax,%eax
  80211c:	78 4c                	js     80216a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80211e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802127:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802133:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802139:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80213c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80213e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802141:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802148:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 2d f3 ff ff       	call   801480 <fd2num>
  802153:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802155:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	e8 20 f3 ff ff       	call   801480 <fd2num>
  802160:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802163:	bb 00 00 00 00       	mov    $0x0,%ebx
  802168:	eb 36                	jmp    8021a0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80216a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80216e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802175:	e8 bf f0 ff ff       	call   801239 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80217a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80217d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802188:	e8 ac f0 ff ff       	call   801239 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80218d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802190:	89 44 24 04          	mov    %eax,0x4(%esp)
  802194:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219b:	e8 99 f0 ff ff       	call   801239 <sys_page_unmap>
    err:
	return r;
}
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021a5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021a8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8021ab:	89 ec                	mov    %ebp,%esp
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bf:	89 04 24             	mov    %eax,(%esp)
  8021c2:	e8 57 f3 ff ff       	call   80151e <fd_lookup>
  8021c7:	85 c0                	test   %eax,%eax
  8021c9:	78 15                	js     8021e0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ce:	89 04 24             	mov    %eax,(%esp)
  8021d1:	e8 ba f2 ff ff       	call   801490 <fd2data>
	return _pipeisclosed(fd, p);
  8021d6:	89 c2                	mov    %eax,%edx
  8021d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021db:	e8 c2 fc ff ff       	call   801ea2 <_pipeisclosed>
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    
	...

008021e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	56                   	push   %esi
  8021e8:	53                   	push   %ebx
  8021e9:	83 ec 10             	sub    $0x10,%esp
  8021ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8021ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8021f5:	85 db                	test   %ebx,%ebx
  8021f7:	74 06                	je     8021ff <ipc_recv+0x1b>
  8021f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  8021ff:	85 f6                	test   %esi,%esi
  802201:	74 06                	je     802209 <ipc_recv+0x25>
  802203:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802209:	85 c0                	test   %eax,%eax
  80220b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802210:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802213:	89 04 24             	mov    %eax,(%esp)
  802216:	e8 ca f1 ff ff       	call   8013e5 <sys_ipc_recv>
    if (ret) return ret;
  80221b:	85 c0                	test   %eax,%eax
  80221d:	75 24                	jne    802243 <ipc_recv+0x5f>
    if (from_env_store)
  80221f:	85 db                	test   %ebx,%ebx
  802221:	74 0a                	je     80222d <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  802223:	a1 04 44 80 00       	mov    0x804404,%eax
  802228:	8b 40 74             	mov    0x74(%eax),%eax
  80222b:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  80222d:	85 f6                	test   %esi,%esi
  80222f:	74 0a                	je     80223b <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  802231:	a1 04 44 80 00       	mov    0x804404,%eax
  802236:	8b 40 78             	mov    0x78(%eax),%eax
  802239:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  80223b:	a1 04 44 80 00       	mov    0x804404,%eax
  802240:	8b 40 70             	mov    0x70(%eax),%eax
}
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	5b                   	pop    %ebx
  802247:	5e                   	pop    %esi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	57                   	push   %edi
  80224e:	56                   	push   %esi
  80224f:	53                   	push   %ebx
  802250:	83 ec 1c             	sub    $0x1c,%esp
  802253:	8b 75 08             	mov    0x8(%ebp),%esi
  802256:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802259:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80225c:	85 db                	test   %ebx,%ebx
  80225e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802263:	0f 44 d8             	cmove  %eax,%ebx
  802266:	eb 2a                	jmp    802292 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802268:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80226b:	74 20                	je     80228d <ipc_send+0x43>
  80226d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802271:	c7 44 24 08 de 2a 80 	movl   $0x802ade,0x8(%esp)
  802278:	00 
  802279:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  802280:	00 
  802281:	c7 04 24 f5 2a 80 00 	movl   $0x802af5,(%esp)
  802288:	e8 af e0 ff ff       	call   80033c <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  80228d:	e8 ba ee ff ff       	call   80114c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802292:	8b 45 14             	mov    0x14(%ebp),%eax
  802295:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022a1:	89 34 24             	mov    %esi,(%esp)
  8022a4:	e8 08 f1 ff ff       	call   8013b1 <sys_ipc_try_send>
  8022a9:	85 c0                	test   %eax,%eax
  8022ab:	75 bb                	jne    802268 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8022ad:	83 c4 1c             	add    $0x1c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    

008022b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8022bb:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8022c0:	39 c8                	cmp    %ecx,%eax
  8022c2:	74 19                	je     8022dd <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022c4:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8022c9:	89 c2                	mov    %eax,%edx
  8022cb:	c1 e2 07             	shl    $0x7,%edx
  8022ce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022d4:	8b 52 50             	mov    0x50(%edx),%edx
  8022d7:	39 ca                	cmp    %ecx,%edx
  8022d9:	75 14                	jne    8022ef <ipc_find_env+0x3a>
  8022db:	eb 05                	jmp    8022e2 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022dd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8022e2:	c1 e0 07             	shl    $0x7,%eax
  8022e5:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8022ea:	8b 40 40             	mov    0x40(%eax),%eax
  8022ed:	eb 0e                	jmp    8022fd <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ef:	83 c0 01             	add    $0x1,%eax
  8022f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022f7:	75 d0                	jne    8022c9 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022f9:	66 b8 00 00          	mov    $0x0,%ax
}
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    
	...

00802300 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802306:	89 d0                	mov    %edx,%eax
  802308:	c1 e8 16             	shr    $0x16,%eax
  80230b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802312:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802317:	f6 c1 01             	test   $0x1,%cl
  80231a:	74 1d                	je     802339 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80231c:	c1 ea 0c             	shr    $0xc,%edx
  80231f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802326:	f6 c2 01             	test   $0x1,%dl
  802329:	74 0e                	je     802339 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80232b:	c1 ea 0c             	shr    $0xc,%edx
  80232e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802335:	ef 
  802336:	0f b7 c0             	movzwl %ax,%eax
}
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    
  80233b:	00 00                	add    %al,(%eax)
  80233d:	00 00                	add    %al,(%eax)
	...

00802340 <__udivdi3>:
  802340:	83 ec 1c             	sub    $0x1c,%esp
  802343:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802347:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80234b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80234f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802353:	89 74 24 10          	mov    %esi,0x10(%esp)
  802357:	8b 74 24 24          	mov    0x24(%esp),%esi
  80235b:	85 ff                	test   %edi,%edi
  80235d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802361:	89 44 24 08          	mov    %eax,0x8(%esp)
  802365:	89 cd                	mov    %ecx,%ebp
  802367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236b:	75 33                	jne    8023a0 <__udivdi3+0x60>
  80236d:	39 f1                	cmp    %esi,%ecx
  80236f:	77 57                	ja     8023c8 <__udivdi3+0x88>
  802371:	85 c9                	test   %ecx,%ecx
  802373:	75 0b                	jne    802380 <__udivdi3+0x40>
  802375:	b8 01 00 00 00       	mov    $0x1,%eax
  80237a:	31 d2                	xor    %edx,%edx
  80237c:	f7 f1                	div    %ecx
  80237e:	89 c1                	mov    %eax,%ecx
  802380:	89 f0                	mov    %esi,%eax
  802382:	31 d2                	xor    %edx,%edx
  802384:	f7 f1                	div    %ecx
  802386:	89 c6                	mov    %eax,%esi
  802388:	8b 44 24 04          	mov    0x4(%esp),%eax
  80238c:	f7 f1                	div    %ecx
  80238e:	89 f2                	mov    %esi,%edx
  802390:	8b 74 24 10          	mov    0x10(%esp),%esi
  802394:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802398:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80239c:	83 c4 1c             	add    $0x1c,%esp
  80239f:	c3                   	ret    
  8023a0:	31 d2                	xor    %edx,%edx
  8023a2:	31 c0                	xor    %eax,%eax
  8023a4:	39 f7                	cmp    %esi,%edi
  8023a6:	77 e8                	ja     802390 <__udivdi3+0x50>
  8023a8:	0f bd cf             	bsr    %edi,%ecx
  8023ab:	83 f1 1f             	xor    $0x1f,%ecx
  8023ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023b2:	75 2c                	jne    8023e0 <__udivdi3+0xa0>
  8023b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8023b8:	76 04                	jbe    8023be <__udivdi3+0x7e>
  8023ba:	39 f7                	cmp    %esi,%edi
  8023bc:	73 d2                	jae    802390 <__udivdi3+0x50>
  8023be:	31 d2                	xor    %edx,%edx
  8023c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c5:	eb c9                	jmp    802390 <__udivdi3+0x50>
  8023c7:	90                   	nop
  8023c8:	89 f2                	mov    %esi,%edx
  8023ca:	f7 f1                	div    %ecx
  8023cc:	31 d2                	xor    %edx,%edx
  8023ce:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8023d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8023da:	83 c4 1c             	add    $0x1c,%esp
  8023dd:	c3                   	ret    
  8023de:	66 90                	xchg   %ax,%ax
  8023e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023e5:	b8 20 00 00 00       	mov    $0x20,%eax
  8023ea:	89 ea                	mov    %ebp,%edx
  8023ec:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023f0:	d3 e7                	shl    %cl,%edi
  8023f2:	89 c1                	mov    %eax,%ecx
  8023f4:	d3 ea                	shr    %cl,%edx
  8023f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023fb:	09 fa                	or     %edi,%edx
  8023fd:	89 f7                	mov    %esi,%edi
  8023ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802403:	89 f2                	mov    %esi,%edx
  802405:	8b 74 24 08          	mov    0x8(%esp),%esi
  802409:	d3 e5                	shl    %cl,%ebp
  80240b:	89 c1                	mov    %eax,%ecx
  80240d:	d3 ef                	shr    %cl,%edi
  80240f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802414:	d3 e2                	shl    %cl,%edx
  802416:	89 c1                	mov    %eax,%ecx
  802418:	d3 ee                	shr    %cl,%esi
  80241a:	09 d6                	or     %edx,%esi
  80241c:	89 fa                	mov    %edi,%edx
  80241e:	89 f0                	mov    %esi,%eax
  802420:	f7 74 24 0c          	divl   0xc(%esp)
  802424:	89 d7                	mov    %edx,%edi
  802426:	89 c6                	mov    %eax,%esi
  802428:	f7 e5                	mul    %ebp
  80242a:	39 d7                	cmp    %edx,%edi
  80242c:	72 22                	jb     802450 <__udivdi3+0x110>
  80242e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802432:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802437:	d3 e5                	shl    %cl,%ebp
  802439:	39 c5                	cmp    %eax,%ebp
  80243b:	73 04                	jae    802441 <__udivdi3+0x101>
  80243d:	39 d7                	cmp    %edx,%edi
  80243f:	74 0f                	je     802450 <__udivdi3+0x110>
  802441:	89 f0                	mov    %esi,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	e9 46 ff ff ff       	jmp    802390 <__udivdi3+0x50>
  80244a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802450:	8d 46 ff             	lea    -0x1(%esi),%eax
  802453:	31 d2                	xor    %edx,%edx
  802455:	8b 74 24 10          	mov    0x10(%esp),%esi
  802459:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80245d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802461:	83 c4 1c             	add    $0x1c,%esp
  802464:	c3                   	ret    
	...

00802470 <__umoddi3>:
  802470:	83 ec 1c             	sub    $0x1c,%esp
  802473:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802477:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80247b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80247f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802483:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802487:	8b 74 24 24          	mov    0x24(%esp),%esi
  80248b:	85 ed                	test   %ebp,%ebp
  80248d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802491:	89 44 24 08          	mov    %eax,0x8(%esp)
  802495:	89 cf                	mov    %ecx,%edi
  802497:	89 04 24             	mov    %eax,(%esp)
  80249a:	89 f2                	mov    %esi,%edx
  80249c:	75 1a                	jne    8024b8 <__umoddi3+0x48>
  80249e:	39 f1                	cmp    %esi,%ecx
  8024a0:	76 4e                	jbe    8024f0 <__umoddi3+0x80>
  8024a2:	f7 f1                	div    %ecx
  8024a4:	89 d0                	mov    %edx,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8024b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8024b4:	83 c4 1c             	add    $0x1c,%esp
  8024b7:	c3                   	ret    
  8024b8:	39 f5                	cmp    %esi,%ebp
  8024ba:	77 54                	ja     802510 <__umoddi3+0xa0>
  8024bc:	0f bd c5             	bsr    %ebp,%eax
  8024bf:	83 f0 1f             	xor    $0x1f,%eax
  8024c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c6:	75 60                	jne    802528 <__umoddi3+0xb8>
  8024c8:	3b 0c 24             	cmp    (%esp),%ecx
  8024cb:	0f 87 07 01 00 00    	ja     8025d8 <__umoddi3+0x168>
  8024d1:	89 f2                	mov    %esi,%edx
  8024d3:	8b 34 24             	mov    (%esp),%esi
  8024d6:	29 ce                	sub    %ecx,%esi
  8024d8:	19 ea                	sbb    %ebp,%edx
  8024da:	89 34 24             	mov    %esi,(%esp)
  8024dd:	8b 04 24             	mov    (%esp),%eax
  8024e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8024e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8024ec:	83 c4 1c             	add    $0x1c,%esp
  8024ef:	c3                   	ret    
  8024f0:	85 c9                	test   %ecx,%ecx
  8024f2:	75 0b                	jne    8024ff <__umoddi3+0x8f>
  8024f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f9:	31 d2                	xor    %edx,%edx
  8024fb:	f7 f1                	div    %ecx
  8024fd:	89 c1                	mov    %eax,%ecx
  8024ff:	89 f0                	mov    %esi,%eax
  802501:	31 d2                	xor    %edx,%edx
  802503:	f7 f1                	div    %ecx
  802505:	8b 04 24             	mov    (%esp),%eax
  802508:	f7 f1                	div    %ecx
  80250a:	eb 98                	jmp    8024a4 <__umoddi3+0x34>
  80250c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802510:	89 f2                	mov    %esi,%edx
  802512:	8b 74 24 10          	mov    0x10(%esp),%esi
  802516:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80251a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80251e:	83 c4 1c             	add    $0x1c,%esp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80252d:	89 e8                	mov    %ebp,%eax
  80252f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802534:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802538:	89 fa                	mov    %edi,%edx
  80253a:	d3 e0                	shl    %cl,%eax
  80253c:	89 e9                	mov    %ebp,%ecx
  80253e:	d3 ea                	shr    %cl,%edx
  802540:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802545:	09 c2                	or     %eax,%edx
  802547:	8b 44 24 08          	mov    0x8(%esp),%eax
  80254b:	89 14 24             	mov    %edx,(%esp)
  80254e:	89 f2                	mov    %esi,%edx
  802550:	d3 e7                	shl    %cl,%edi
  802552:	89 e9                	mov    %ebp,%ecx
  802554:	d3 ea                	shr    %cl,%edx
  802556:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80255b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80255f:	d3 e6                	shl    %cl,%esi
  802561:	89 e9                	mov    %ebp,%ecx
  802563:	d3 e8                	shr    %cl,%eax
  802565:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80256a:	09 f0                	or     %esi,%eax
  80256c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802570:	f7 34 24             	divl   (%esp)
  802573:	d3 e6                	shl    %cl,%esi
  802575:	89 74 24 08          	mov    %esi,0x8(%esp)
  802579:	89 d6                	mov    %edx,%esi
  80257b:	f7 e7                	mul    %edi
  80257d:	39 d6                	cmp    %edx,%esi
  80257f:	89 c1                	mov    %eax,%ecx
  802581:	89 d7                	mov    %edx,%edi
  802583:	72 3f                	jb     8025c4 <__umoddi3+0x154>
  802585:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802589:	72 35                	jb     8025c0 <__umoddi3+0x150>
  80258b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80258f:	29 c8                	sub    %ecx,%eax
  802591:	19 fe                	sbb    %edi,%esi
  802593:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802598:	89 f2                	mov    %esi,%edx
  80259a:	d3 e8                	shr    %cl,%eax
  80259c:	89 e9                	mov    %ebp,%ecx
  80259e:	d3 e2                	shl    %cl,%edx
  8025a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025a5:	09 d0                	or     %edx,%eax
  8025a7:	89 f2                	mov    %esi,%edx
  8025a9:	d3 ea                	shr    %cl,%edx
  8025ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8025af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8025b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8025b7:	83 c4 1c             	add    $0x1c,%esp
  8025ba:	c3                   	ret    
  8025bb:	90                   	nop
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	39 d6                	cmp    %edx,%esi
  8025c2:	75 c7                	jne    80258b <__umoddi3+0x11b>
  8025c4:	89 d7                	mov    %edx,%edi
  8025c6:	89 c1                	mov    %eax,%ecx
  8025c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8025cc:	1b 3c 24             	sbb    (%esp),%edi
  8025cf:	eb ba                	jmp    80258b <__umoddi3+0x11b>
  8025d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	39 f5                	cmp    %esi,%ebp
  8025da:	0f 82 f1 fe ff ff    	jb     8024d1 <__umoddi3+0x61>
  8025e0:	e9 f8 fe ff ff       	jmp    8024dd <__umoddi3+0x6d>
