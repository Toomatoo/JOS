
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 4b 07 00 00       	call   80077c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800048:	e8 de 0f 00 00       	call   80102b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 96 18 00 00       	call   8018f5 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 0b 18 00 00       	call   80188a <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 89 17 00 00       	call   801824 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 20 2a 80 00       	mov    $0x802a20,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 2b 2a 80 	movl   $0x802a2b,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8000e0:	e8 03 07 00 00       	call   8007e8 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 e0 2b 80 	movl   $0x802be0,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8000fc:	e8 e7 06 00 00       	call   8007e8 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 55 2a 80 00       	mov    $0x802a55,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 5e 2a 80 	movl   $0x802a5e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80012f:	e8 b4 06 00 00       	call   8007e8 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 04 2c 80 	movl   $0x802c04,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800166:	e8 7d 06 00 00       	call   8007e8 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 76 2a 80 00 	movl   $0x802a76,(%esp)
  800172:	e8 6c 07 00 00       	call   8008e3 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 20 40 80 00    	call   *0x804020
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 8a 2a 80 	movl   $0x802a8a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8001ad:	e8 36 06 00 00       	call   8007e8 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 40 80 00       	mov    0x804000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 21 0e 00 00       	call   800fe0 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 40 80 00       	mov    0x804000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 0f 0e 00 00       	call   800fe0 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 34 2c 80 	movl   $0x802c34,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8001f3:	e8 f0 05 00 00       	call   8007e8 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  8001ff:	e8 df 06 00 00       	call   8008e3 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 9f 0f 00 00       	call   8011c1 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 14 40 80 00    	call   *0x804014
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 ab 2a 80 	movl   $0x802aab,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80025a:	e8 89 05 00 00       	call   8007e8 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 40 80 00       	mov    0x804000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 75 0e 00 00       	call   8010eb <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 b9 2a 80 	movl   $0x802ab9,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800291:	e8 52 05 00 00       	call   8007e8 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 d7 2a 80 00 	movl   $0x802ad7,(%esp)
  80029d:	e8 41 06 00 00       	call   8008e3 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 1c 40 80 00    	call   *0x80401c
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 ea 2a 80 	movl   $0x802aea,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8002ce:	e8 15 05 00 00       	call   8007e8 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 f9 2a 80 00 	movl   $0x802af9,(%esp)
  8002da:	e8 04 06 00 00       	call   8008e3 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e7:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ef:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f7:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8002fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8002ff:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800306:	cc 
  800307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030e:	e8 d6 12 00 00       	call   8015e9 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800313:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80031a:	00 
  80031b:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 15 14 40 80 00    	call   *0x804014
  800331:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800334:	74 20                	je     800356 <umain+0x2b5>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800336:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033a:	c7 44 24 08 5c 2c 80 	movl   $0x802c5c,0x8(%esp)
  800341:	00 
  800342:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800351:	e8 92 04 00 00       	call   8007e8 <_panic>
	cprintf("stale fileid is good\n");
  800356:	c7 04 24 0d 2b 80 00 	movl   $0x802b0d,(%esp)
  80035d:	e8 81 05 00 00       	call   8008e3 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800362:	ba 02 01 00 00       	mov    $0x102,%edx
  800367:	b8 23 2b 80 00       	mov    $0x802b23,%eax
  80036c:	e8 c3 fc ff ff       	call   800034 <xopen>
  800371:	85 c0                	test   %eax,%eax
  800373:	79 20                	jns    800395 <umain+0x2f4>
		panic("serve_open /new-file: %e", r);
  800375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800379:	c7 44 24 08 2d 2b 80 	movl   $0x802b2d,0x8(%esp)
  800380:	00 
  800381:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800388:	00 
  800389:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800390:	e8 53 04 00 00       	call   8007e8 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800395:	8b 1d 18 40 80 00    	mov    0x804018,%ebx
  80039b:	a1 00 40 80 00       	mov    0x804000,%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 38 0c 00 00       	call   800fe0 <strlen>
  8003a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ac:	a1 00 40 80 00       	mov    0x804000,%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003bc:	ff d3                	call   *%ebx
  8003be:	89 c3                	mov    %eax,%ebx
  8003c0:	a1 00 40 80 00       	mov    0x804000,%eax
  8003c5:	89 04 24             	mov    %eax,(%esp)
  8003c8:	e8 13 0c 00 00       	call   800fe0 <strlen>
  8003cd:	39 c3                	cmp    %eax,%ebx
  8003cf:	74 20                	je     8003f1 <umain+0x350>
		panic("file_write: %e", r);
  8003d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d5:	c7 44 24 08 46 2b 80 	movl   $0x802b46,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8003ec:	e8 f7 03 00 00       	call   8007e8 <_panic>
	cprintf("file_write is good\n");
  8003f1:	c7 04 24 55 2b 80 00 	movl   $0x802b55,(%esp)
  8003f8:	e8 e6 04 00 00       	call   8008e3 <cprintf>

	FVA->fd_offset = 0;
  8003fd:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800404:	00 00 00 
	memset(buf, 0, sizeof buf);
  800407:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80040e:	00 
  80040f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800416:	00 
  800417:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80041d:	89 1c 24             	mov    %ebx,(%esp)
  800420:	e8 9c 0d 00 00       	call   8011c1 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800425:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80042c:	00 
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800438:	ff 15 14 40 80 00    	call   *0x804014
  80043e:	89 c3                	mov    %eax,%ebx
  800440:	85 c0                	test   %eax,%eax
  800442:	79 20                	jns    800464 <umain+0x3c3>
		panic("file_read after file_write: %e", r);
  800444:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800448:	c7 44 24 08 94 2c 80 	movl   $0x802c94,0x8(%esp)
  80044f:	00 
  800450:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800457:	00 
  800458:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80045f:	e8 84 03 00 00       	call   8007e8 <_panic>
	if (r != strlen(msg))
  800464:	a1 00 40 80 00       	mov    0x804000,%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 6f 0b 00 00       	call   800fe0 <strlen>
  800471:	39 d8                	cmp    %ebx,%eax
  800473:	74 20                	je     800495 <umain+0x3f4>
		panic("file_read after file_write returned wrong length: %d", r);
  800475:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800479:	c7 44 24 08 b4 2c 80 	movl   $0x802cb4,0x8(%esp)
  800480:	00 
  800481:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800488:	00 
  800489:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800490:	e8 53 03 00 00       	call   8007e8 <_panic>
	if (strcmp(buf, msg) != 0)
  800495:	a1 00 40 80 00       	mov    0x804000,%eax
  80049a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049e:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 3f 0c 00 00       	call   8010eb <strcmp>
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	74 1c                	je     8004cc <umain+0x42b>
		panic("file_read after file_write returned wrong data");
  8004b0:	c7 44 24 08 ec 2c 80 	movl   $0x802cec,0x8(%esp)
  8004b7:	00 
  8004b8:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004bf:	00 
  8004c0:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8004c7:	e8 1c 03 00 00       	call   8007e8 <_panic>
	cprintf("file_read after file_write is good\n");
  8004cc:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  8004d3:	e8 0b 04 00 00       	call   8008e3 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004df:	00 
  8004e0:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  8004e7:	e8 20 1c 00 00       	call   80210c <open>
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	79 25                	jns    800515 <umain+0x474>
  8004f0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004f3:	74 3c                	je     800531 <umain+0x490>
		panic("open /not-found: %e", r);
  8004f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f9:	c7 44 24 08 31 2a 80 	movl   $0x802a31,0x8(%esp)
  800500:	00 
  800501:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800508:	00 
  800509:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800510:	e8 d3 02 00 00       	call   8007e8 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800515:	c7 44 24 08 69 2b 80 	movl   $0x802b69,0x8(%esp)
  80051c:	00 
  80051d:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800524:	00 
  800525:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80052c:	e8 b7 02 00 00       	call   8007e8 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800531:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800538:	00 
  800539:	c7 04 24 55 2a 80 00 	movl   $0x802a55,(%esp)
  800540:	e8 c7 1b 00 00       	call   80210c <open>
  800545:	85 c0                	test   %eax,%eax
  800547:	79 20                	jns    800569 <umain+0x4c8>
		panic("open /newmotd: %e", r);
  800549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054d:	c7 44 24 08 64 2a 80 	movl   $0x802a64,0x8(%esp)
  800554:	00 
  800555:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80055c:	00 
  80055d:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800564:	e8 7f 02 00 00       	call   8007e8 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800569:	05 00 00 0d 00       	add    $0xd0000,%eax
  80056e:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800571:	83 38 66             	cmpl   $0x66,(%eax)
  800574:	75 0c                	jne    800582 <umain+0x4e1>
  800576:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  80057a:	75 06                	jne    800582 <umain+0x4e1>
  80057c:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  800580:	74 1c                	je     80059e <umain+0x4fd>
		panic("open did not fill struct Fd correctly\n");
  800582:	c7 44 24 08 40 2d 80 	movl   $0x802d40,0x8(%esp)
  800589:	00 
  80058a:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800591:	00 
  800592:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800599:	e8 4a 02 00 00       	call   8007e8 <_panic>
	cprintf("open is good\n");
  80059e:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  8005a5:	e8 39 03 00 00       	call   8008e3 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005aa:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005b1:	00 
  8005b2:	c7 04 24 84 2b 80 00 	movl   $0x802b84,(%esp)
  8005b9:	e8 4e 1b 00 00       	call   80210c <open>
  8005be:	89 c6                	mov    %eax,%esi
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	79 20                	jns    8005e4 <umain+0x543>
		panic("creat /big: %e", f);
  8005c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c8:	c7 44 24 08 89 2b 80 	movl   $0x802b89,0x8(%esp)
  8005cf:	00 
  8005d0:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005d7:	00 
  8005d8:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8005df:	e8 04 02 00 00       	call   8007e8 <_panic>
	memset(buf, 0, sizeof(buf));
  8005e4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005eb:	00 
  8005ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005f3:	00 
  8005f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 bf 0b 00 00       	call   8011c1 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800607:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80060d:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800613:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80061a:	00 
  80061b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	e8 57 17 00 00       	call   801d7e <write>
  800627:	85 c0                	test   %eax,%eax
  800629:	79 24                	jns    80064f <umain+0x5ae>
			panic("write /big@%d: %e", i, r);
  80062b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80062f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800633:	c7 44 24 08 98 2b 80 	movl   $0x802b98,0x8(%esp)
  80063a:	00 
  80063b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800642:	00 
  800643:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80064a:	e8 99 01 00 00       	call   8007e8 <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  80064f:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  800655:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800657:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80065c:	75 af                	jne    80060d <umain+0x56c>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80065e:	89 34 24             	mov    %esi,(%esp)
  800661:	e8 c7 14 00 00       	call   801b2d <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800666:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80066d:	00 
  80066e:	c7 04 24 84 2b 80 00 	movl   $0x802b84,(%esp)
  800675:	e8 92 1a 00 00       	call   80210c <open>
  80067a:	89 c7                	mov    %eax,%edi
  80067c:	85 c0                	test   %eax,%eax
  80067e:	79 20                	jns    8006a0 <umain+0x5ff>
		panic("open /big: %e", f);
  800680:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800684:	c7 44 24 08 aa 2b 80 	movl   $0x802baa,0x8(%esp)
  80068b:	00 
  80068c:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800693:	00 
  800694:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80069b:	e8 48 01 00 00       	call   8007e8 <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  8006a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a5:	8d b5 4c fd ff ff    	lea    -0x2b4(%ebp),%esi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8006ab:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006b1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006b8:	00 
  8006b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bd:	89 3c 24             	mov    %edi,(%esp)
  8006c0:	e8 69 16 00 00       	call   801d2e <readn>
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	79 24                	jns    8006ed <umain+0x64c>
			panic("read /big@%d: %e", i, r);
  8006c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d1:	c7 44 24 08 b8 2b 80 	movl   $0x802bb8,0x8(%esp)
  8006d8:	00 
  8006d9:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006e0:	00 
  8006e1:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  8006e8:	e8 fb 00 00 00       	call   8007e8 <_panic>
		if (r != sizeof(buf))
  8006ed:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f2:	74 2c                	je     800720 <umain+0x67f>
			panic("read /big from %d returned %d < %d bytes",
  8006f4:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006fb:	00 
  8006fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800700:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800704:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  80070b:	00 
  80070c:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800713:	00 
  800714:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  80071b:	e8 c8 00 00 00       	call   8007e8 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800720:	8b 06                	mov    (%esi),%eax
  800722:	39 d8                	cmp    %ebx,%eax
  800724:	74 24                	je     80074a <umain+0x6a9>
			panic("read /big from %d returned bad data %d",
  800726:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80072e:	c7 44 24 08 94 2d 80 	movl   $0x802d94,0x8(%esp)
  800735:	00 
  800736:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80073d:	00 
  80073e:	c7 04 24 45 2a 80 00 	movl   $0x802a45,(%esp)
  800745:	e8 9e 00 00 00       	call   8007e8 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80074a:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  800750:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  800756:	0f 8e 4f ff ff ff    	jle    8006ab <umain+0x60a>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80075c:	89 3c 24             	mov    %edi,(%esp)
  80075f:	e8 c9 13 00 00       	call   801b2d <close>
	cprintf("large file is good\n");
  800764:	c7 04 24 c9 2b 80 00 	movl   $0x802bc9,(%esp)
  80076b:	e8 73 01 00 00       	call   8008e3 <cprintf>
}
  800770:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	5f                   	pop    %edi
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    
	...

0080077c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 18             	sub    $0x18,%esp
  800782:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800785:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800788:	8b 75 08             	mov    0x8(%ebp),%esi
  80078b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80078e:	e8 39 0d 00 00       	call   8014cc <sys_getenvid>
  800793:	25 ff 03 00 00       	and    $0x3ff,%eax
  800798:	c1 e0 07             	shl    $0x7,%eax
  80079b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a0:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007a5:	85 f6                	test   %esi,%esi
  8007a7:	7e 07                	jle    8007b0 <libmain+0x34>
		binaryname = argv[0];
  8007a9:	8b 03                	mov    (%ebx),%eax
  8007ab:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	89 34 24             	mov    %esi,(%esp)
  8007b7:	e8 e5 f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007bc:	e8 0b 00 00 00       	call   8007cc <exit>
}
  8007c1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8007c4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8007c7:	89 ec                	mov    %ebp,%esp
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    
	...

008007cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007d2:	e8 87 13 00 00       	call   801b5e <close_all>
	sys_env_destroy(0);
  8007d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007de:	e8 8c 0c 00 00       	call   80146f <sys_env_destroy>
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
  8007e5:	00 00                	add    %al,(%eax)
	...

008007e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007f3:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8007f9:	e8 ce 0c 00 00       	call   8014cc <sys_getenvid>
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	89 54 24 10          	mov    %edx,0x10(%esp)
  800805:	8b 55 08             	mov    0x8(%ebp),%edx
  800808:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80080c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	c7 04 24 ec 2d 80 00 	movl   $0x802dec,(%esp)
  80081b:	e8 c3 00 00 00       	call   8008e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800820:	89 74 24 04          	mov    %esi,0x4(%esp)
  800824:	8b 45 10             	mov    0x10(%ebp),%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 53 00 00 00       	call   800882 <vcprintf>
	cprintf("\n");
  80082f:	c7 04 24 47 32 80 00 	movl   $0x803247,(%esp)
  800836:	e8 a8 00 00 00       	call   8008e3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80083b:	cc                   	int3   
  80083c:	eb fd                	jmp    80083b <_panic+0x53>
	...

00800840 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	83 ec 14             	sub    $0x14,%esp
  800847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80084a:	8b 03                	mov    (%ebx),%eax
  80084c:	8b 55 08             	mov    0x8(%ebp),%edx
  80084f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800853:	83 c0 01             	add    $0x1,%eax
  800856:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800858:	3d ff 00 00 00       	cmp    $0xff,%eax
  80085d:	75 19                	jne    800878 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80085f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800866:	00 
  800867:	8d 43 08             	lea    0x8(%ebx),%eax
  80086a:	89 04 24             	mov    %eax,(%esp)
  80086d:	e8 9e 0b 00 00       	call   801410 <sys_cputs>
		b->idx = 0;
  800872:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800878:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80087c:	83 c4 14             	add    $0x14,%esp
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80088b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800892:	00 00 00 
	b.cnt = 0;
  800895:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80089c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	c7 04 24 40 08 80 00 	movl   $0x800840,(%esp)
  8008be:	e8 97 01 00 00       	call   800a5a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008c3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	e8 35 0b 00 00       	call   801410 <sys_cputs>

	return b.cnt;
}
  8008db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	e8 87 ff ff ff       	call   800882 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    
  8008fd:	00 00                	add    %al,(%eax)
	...

00800900 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	83 ec 3c             	sub    $0x3c,%esp
  800909:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80090c:	89 d7                	mov    %edx,%edi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80091a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80091d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
  800925:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800928:	72 11                	jb     80093b <printnum+0x3b>
  80092a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80092d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800930:	76 09                	jbe    80093b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800932:	83 eb 01             	sub    $0x1,%ebx
  800935:	85 db                	test   %ebx,%ebx
  800937:	7f 51                	jg     80098a <printnum+0x8a>
  800939:	eb 5e                	jmp    800999 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80093b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80093f:	83 eb 01             	sub    $0x1,%ebx
  800942:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800946:	8b 45 10             	mov    0x10(%ebp),%eax
  800949:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800951:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800955:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80095c:	00 
  80095d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800960:	89 04 24             	mov    %eax,(%esp)
  800963:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	e8 01 1e 00 00       	call   802770 <__udivdi3>
  80096f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800973:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800977:	89 04 24             	mov    %eax,(%esp)
  80097a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097e:	89 fa                	mov    %edi,%edx
  800980:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800983:	e8 78 ff ff ff       	call   800900 <printnum>
  800988:	eb 0f                	jmp    800999 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80098a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098e:	89 34 24             	mov    %esi,(%esp)
  800991:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800994:	83 eb 01             	sub    $0x1,%ebx
  800997:	75 f1                	jne    80098a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800999:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009af:	00 
  8009b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bd:	e8 de 1e 00 00       	call   8028a0 <__umoddi3>
  8009c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c6:	0f be 80 0f 2e 80 00 	movsbl 0x802e0f(%eax),%eax
  8009cd:	89 04 24             	mov    %eax,(%esp)
  8009d0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009d3:	83 c4 3c             	add    $0x3c,%esp
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009de:	83 fa 01             	cmp    $0x1,%edx
  8009e1:	7e 0e                	jle    8009f1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009e3:	8b 10                	mov    (%eax),%edx
  8009e5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009e8:	89 08                	mov    %ecx,(%eax)
  8009ea:	8b 02                	mov    (%edx),%eax
  8009ec:	8b 52 04             	mov    0x4(%edx),%edx
  8009ef:	eb 22                	jmp    800a13 <getuint+0x38>
	else if (lflag)
  8009f1:	85 d2                	test   %edx,%edx
  8009f3:	74 10                	je     800a05 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009f5:	8b 10                	mov    (%eax),%edx
  8009f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009fa:	89 08                	mov    %ecx,(%eax)
  8009fc:	8b 02                	mov    (%edx),%eax
  8009fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800a03:	eb 0e                	jmp    800a13 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a05:	8b 10                	mov    (%eax),%edx
  800a07:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a0a:	89 08                	mov    %ecx,(%eax)
  800a0c:	8b 02                	mov    (%edx),%eax
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a1b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a1f:	8b 10                	mov    (%eax),%edx
  800a21:	3b 50 04             	cmp    0x4(%eax),%edx
  800a24:	73 0a                	jae    800a30 <sprintputch+0x1b>
		*b->buf++ = ch;
  800a26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a29:	88 0a                	mov    %cl,(%edx)
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	89 10                	mov    %edx,(%eax)
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a38:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	89 04 24             	mov    %eax,(%esp)
  800a53:	e8 02 00 00 00       	call   800a5a <vprintfmt>
	va_end(ap);
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 5c             	sub    $0x5c,%esp
  800a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a66:	8b 75 10             	mov    0x10(%ebp),%esi
  800a69:	eb 12                	jmp    800a7d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	0f 84 e4 04 00 00    	je     800f57 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800a73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a7d:	0f b6 06             	movzbl (%esi),%eax
  800a80:	83 c6 01             	add    $0x1,%esi
  800a83:	83 f8 25             	cmp    $0x25,%eax
  800a86:	75 e3                	jne    800a6b <vprintfmt+0x11>
  800a88:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800a8c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800a93:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a98:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800aa7:	eb 2b                	jmp    800ad4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800aac:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800ab0:	eb 22                	jmp    800ad4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ab5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800ab9:	eb 19                	jmp    800ad4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800abb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800abe:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800ac5:	eb 0d                	jmp    800ad4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800ac7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800aca:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800acd:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad4:	0f b6 06             	movzbl (%esi),%eax
  800ad7:	0f b6 d0             	movzbl %al,%edx
  800ada:	8d 7e 01             	lea    0x1(%esi),%edi
  800add:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800ae0:	83 e8 23             	sub    $0x23,%eax
  800ae3:	3c 55                	cmp    $0x55,%al
  800ae5:	0f 87 46 04 00 00    	ja     800f31 <vprintfmt+0x4d7>
  800aeb:	0f b6 c0             	movzbl %al,%eax
  800aee:	ff 24 85 60 2f 80 00 	jmp    *0x802f60(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800af5:	83 ea 30             	sub    $0x30,%edx
  800af8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800afb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800aff:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b02:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800b05:	83 fa 09             	cmp    $0x9,%edx
  800b08:	77 4a                	ja     800b54 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b0d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800b10:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800b13:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800b17:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800b1a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800b1d:	83 fa 09             	cmp    $0x9,%edx
  800b20:	76 eb                	jbe    800b0d <vprintfmt+0xb3>
  800b22:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800b25:	eb 2d                	jmp    800b54 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b27:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2a:	8d 50 04             	lea    0x4(%eax),%edx
  800b2d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b30:	8b 00                	mov    (%eax),%eax
  800b32:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b35:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800b38:	eb 1a                	jmp    800b54 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b3a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800b3d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800b41:	79 91                	jns    800ad4 <vprintfmt+0x7a>
  800b43:	e9 73 ff ff ff       	jmp    800abb <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b48:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b4b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800b52:	eb 80                	jmp    800ad4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800b54:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800b58:	0f 89 76 ff ff ff    	jns    800ad4 <vprintfmt+0x7a>
  800b5e:	e9 64 ff ff ff       	jmp    800ac7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b63:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b66:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b69:	e9 66 ff ff ff       	jmp    800ad4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b71:	8d 50 04             	lea    0x4(%eax),%edx
  800b74:	89 55 14             	mov    %edx,0x14(%ebp)
  800b77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b7b:	8b 00                	mov    (%eax),%eax
  800b7d:	89 04 24             	mov    %eax,(%esp)
  800b80:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b83:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b86:	e9 f2 fe ff ff       	jmp    800a7d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800b8b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800b8f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800b92:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800b96:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800b99:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800b9d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800ba0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800ba3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800ba7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800baa:	80 f9 09             	cmp    $0x9,%cl
  800bad:	77 1d                	ja     800bcc <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800baf:	0f be c0             	movsbl %al,%eax
  800bb2:	6b c0 64             	imul   $0x64,%eax,%eax
  800bb5:	0f be d2             	movsbl %dl,%edx
  800bb8:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800bbb:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800bc2:	a3 08 40 80 00       	mov    %eax,0x804008
  800bc7:	e9 b1 fe ff ff       	jmp    800a7d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800bcc:	c7 44 24 04 27 2e 80 	movl   $0x802e27,0x4(%esp)
  800bd3:	00 
  800bd4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800bd7:	89 04 24             	mov    %eax,(%esp)
  800bda:	e8 0c 05 00 00       	call   8010eb <strcmp>
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	75 0f                	jne    800bf2 <vprintfmt+0x198>
  800be3:	c7 05 08 40 80 00 04 	movl   $0x4,0x804008
  800bea:	00 00 00 
  800bed:	e9 8b fe ff ff       	jmp    800a7d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800bf2:	c7 44 24 04 2b 2e 80 	movl   $0x802e2b,0x4(%esp)
  800bf9:	00 
  800bfa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800bfd:	89 14 24             	mov    %edx,(%esp)
  800c00:	e8 e6 04 00 00       	call   8010eb <strcmp>
  800c05:	85 c0                	test   %eax,%eax
  800c07:	75 0f                	jne    800c18 <vprintfmt+0x1be>
  800c09:	c7 05 08 40 80 00 02 	movl   $0x2,0x804008
  800c10:	00 00 00 
  800c13:	e9 65 fe ff ff       	jmp    800a7d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800c18:	c7 44 24 04 2f 2e 80 	movl   $0x802e2f,0x4(%esp)
  800c1f:	00 
  800c20:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800c23:	89 0c 24             	mov    %ecx,(%esp)
  800c26:	e8 c0 04 00 00       	call   8010eb <strcmp>
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	75 0f                	jne    800c3e <vprintfmt+0x1e4>
  800c2f:	c7 05 08 40 80 00 01 	movl   $0x1,0x804008
  800c36:	00 00 00 
  800c39:	e9 3f fe ff ff       	jmp    800a7d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800c3e:	c7 44 24 04 33 2e 80 	movl   $0x802e33,0x4(%esp)
  800c45:	00 
  800c46:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800c49:	89 3c 24             	mov    %edi,(%esp)
  800c4c:	e8 9a 04 00 00       	call   8010eb <strcmp>
  800c51:	85 c0                	test   %eax,%eax
  800c53:	75 0f                	jne    800c64 <vprintfmt+0x20a>
  800c55:	c7 05 08 40 80 00 06 	movl   $0x6,0x804008
  800c5c:	00 00 00 
  800c5f:	e9 19 fe ff ff       	jmp    800a7d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800c64:	c7 44 24 04 37 2e 80 	movl   $0x802e37,0x4(%esp)
  800c6b:	00 
  800c6c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c6f:	89 04 24             	mov    %eax,(%esp)
  800c72:	e8 74 04 00 00       	call   8010eb <strcmp>
  800c77:	85 c0                	test   %eax,%eax
  800c79:	75 0f                	jne    800c8a <vprintfmt+0x230>
  800c7b:	c7 05 08 40 80 00 07 	movl   $0x7,0x804008
  800c82:	00 00 00 
  800c85:	e9 f3 fd ff ff       	jmp    800a7d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800c8a:	c7 44 24 04 3b 2e 80 	movl   $0x802e3b,0x4(%esp)
  800c91:	00 
  800c92:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800c95:	89 14 24             	mov    %edx,(%esp)
  800c98:	e8 4e 04 00 00       	call   8010eb <strcmp>
  800c9d:	83 f8 01             	cmp    $0x1,%eax
  800ca0:	19 c0                	sbb    %eax,%eax
  800ca2:	f7 d0                	not    %eax
  800ca4:	83 c0 08             	add    $0x8,%eax
  800ca7:	a3 08 40 80 00       	mov    %eax,0x804008
  800cac:	e9 cc fd ff ff       	jmp    800a7d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800cb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb4:	8d 50 04             	lea    0x4(%eax),%edx
  800cb7:	89 55 14             	mov    %edx,0x14(%ebp)
  800cba:	8b 00                	mov    (%eax),%eax
  800cbc:	89 c2                	mov    %eax,%edx
  800cbe:	c1 fa 1f             	sar    $0x1f,%edx
  800cc1:	31 d0                	xor    %edx,%eax
  800cc3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800cc5:	83 f8 0f             	cmp    $0xf,%eax
  800cc8:	7f 0b                	jg     800cd5 <vprintfmt+0x27b>
  800cca:	8b 14 85 c0 30 80 00 	mov    0x8030c0(,%eax,4),%edx
  800cd1:	85 d2                	test   %edx,%edx
  800cd3:	75 23                	jne    800cf8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800cd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd9:	c7 44 24 08 3f 2e 80 	movl   $0x802e3f,0x8(%esp)
  800ce0:	00 
  800ce1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce8:	89 3c 24             	mov    %edi,(%esp)
  800ceb:	e8 42 fd ff ff       	call   800a32 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800cf3:	e9 85 fd ff ff       	jmp    800a7d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800cf8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cfc:	c7 44 24 08 15 32 80 	movl   $0x803215,0x8(%esp)
  800d03:	00 
  800d04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0b:	89 3c 24             	mov    %edi,(%esp)
  800d0e:	e8 1f fd ff ff       	call   800a32 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d13:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800d16:	e9 62 fd ff ff       	jmp    800a7d <vprintfmt+0x23>
  800d1b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800d1e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800d21:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d24:	8b 45 14             	mov    0x14(%ebp),%eax
  800d27:	8d 50 04             	lea    0x4(%eax),%edx
  800d2a:	89 55 14             	mov    %edx,0x14(%ebp)
  800d2d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800d2f:	85 f6                	test   %esi,%esi
  800d31:	b8 20 2e 80 00       	mov    $0x802e20,%eax
  800d36:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800d39:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800d3d:	7e 06                	jle    800d45 <vprintfmt+0x2eb>
  800d3f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800d43:	75 13                	jne    800d58 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d45:	0f be 06             	movsbl (%esi),%eax
  800d48:	83 c6 01             	add    $0x1,%esi
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	0f 85 94 00 00 00    	jne    800de7 <vprintfmt+0x38d>
  800d53:	e9 81 00 00 00       	jmp    800dd9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d5c:	89 34 24             	mov    %esi,(%esp)
  800d5f:	e8 97 02 00 00       	call   800ffb <strnlen>
  800d64:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800d67:	29 c2                	sub    %eax,%edx
  800d69:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800d6c:	85 d2                	test   %edx,%edx
  800d6e:	7e d5                	jle    800d45 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800d70:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800d74:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800d77:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	89 cf                	mov    %ecx,%edi
  800d7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d82:	89 3c 24             	mov    %edi,(%esp)
  800d85:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d88:	83 ee 01             	sub    $0x1,%esi
  800d8b:	75 f1                	jne    800d7e <vprintfmt+0x324>
  800d8d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800d90:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800d93:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800d96:	eb ad                	jmp    800d45 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d98:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800d9c:	74 1b                	je     800db9 <vprintfmt+0x35f>
  800d9e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800da1:	83 fa 5e             	cmp    $0x5e,%edx
  800da4:	76 13                	jbe    800db9 <vprintfmt+0x35f>
					putch('?', putdat);
  800da6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dad:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800db4:	ff 55 08             	call   *0x8(%ebp)
  800db7:	eb 0d                	jmp    800dc6 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800db9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800dbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dc0:	89 04 24             	mov    %eax,(%esp)
  800dc3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dc6:	83 eb 01             	sub    $0x1,%ebx
  800dc9:	0f be 06             	movsbl (%esi),%eax
  800dcc:	83 c6 01             	add    $0x1,%esi
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	75 1a                	jne    800ded <vprintfmt+0x393>
  800dd3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800dd6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ddc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800de0:	7f 1c                	jg     800dfe <vprintfmt+0x3a4>
  800de2:	e9 96 fc ff ff       	jmp    800a7d <vprintfmt+0x23>
  800de7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800dea:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ded:	85 ff                	test   %edi,%edi
  800def:	78 a7                	js     800d98 <vprintfmt+0x33e>
  800df1:	83 ef 01             	sub    $0x1,%edi
  800df4:	79 a2                	jns    800d98 <vprintfmt+0x33e>
  800df6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800df9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800dfc:	eb db                	jmp    800dd9 <vprintfmt+0x37f>
  800dfe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e11:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e13:	83 eb 01             	sub    $0x1,%ebx
  800e16:	75 ee                	jne    800e06 <vprintfmt+0x3ac>
  800e18:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e1a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800e1d:	e9 5b fc ff ff       	jmp    800a7d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e22:	83 f9 01             	cmp    $0x1,%ecx
  800e25:	7e 10                	jle    800e37 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800e27:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2a:	8d 50 08             	lea    0x8(%eax),%edx
  800e2d:	89 55 14             	mov    %edx,0x14(%ebp)
  800e30:	8b 30                	mov    (%eax),%esi
  800e32:	8b 78 04             	mov    0x4(%eax),%edi
  800e35:	eb 26                	jmp    800e5d <vprintfmt+0x403>
	else if (lflag)
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	74 12                	je     800e4d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800e3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e3e:	8d 50 04             	lea    0x4(%eax),%edx
  800e41:	89 55 14             	mov    %edx,0x14(%ebp)
  800e44:	8b 30                	mov    (%eax),%esi
  800e46:	89 f7                	mov    %esi,%edi
  800e48:	c1 ff 1f             	sar    $0x1f,%edi
  800e4b:	eb 10                	jmp    800e5d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800e4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800e50:	8d 50 04             	lea    0x4(%eax),%edx
  800e53:	89 55 14             	mov    %edx,0x14(%ebp)
  800e56:	8b 30                	mov    (%eax),%esi
  800e58:	89 f7                	mov    %esi,%edi
  800e5a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800e5d:	85 ff                	test   %edi,%edi
  800e5f:	78 0e                	js     800e6f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e61:	89 f0                	mov    %esi,%eax
  800e63:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800e65:	be 0a 00 00 00       	mov    $0xa,%esi
  800e6a:	e9 84 00 00 00       	jmp    800ef3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800e6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e73:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800e7a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800e7d:	89 f0                	mov    %esi,%eax
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	f7 d8                	neg    %eax
  800e83:	83 d2 00             	adc    $0x0,%edx
  800e86:	f7 da                	neg    %edx
			}
			base = 10;
  800e88:	be 0a 00 00 00       	mov    $0xa,%esi
  800e8d:	eb 64                	jmp    800ef3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e8f:	89 ca                	mov    %ecx,%edx
  800e91:	8d 45 14             	lea    0x14(%ebp),%eax
  800e94:	e8 42 fb ff ff       	call   8009db <getuint>
			base = 10;
  800e99:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800e9e:	eb 53                	jmp    800ef3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ea0:	89 ca                	mov    %ecx,%edx
  800ea2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ea5:	e8 31 fb ff ff       	call   8009db <getuint>
    			base = 8;
  800eaa:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800eaf:	eb 42                	jmp    800ef3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800eb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eb5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ebc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800ebf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800eca:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ecd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed0:	8d 50 04             	lea    0x4(%eax),%edx
  800ed3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ed6:	8b 00                	mov    (%eax),%eax
  800ed8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800edd:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800ee2:	eb 0f                	jmp    800ef3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ee4:	89 ca                	mov    %ecx,%edx
  800ee6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ee9:	e8 ed fa ff ff       	call   8009db <getuint>
			base = 16;
  800eee:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ef3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800ef7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800efb:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800efe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f02:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f06:	89 04 24             	mov    %eax,(%esp)
  800f09:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f0d:	89 da                	mov    %ebx,%edx
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	e8 e9 f9 ff ff       	call   800900 <printnum>
			break;
  800f17:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800f1a:	e9 5e fb ff ff       	jmp    800a7d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f23:	89 14 24             	mov    %edx,(%esp)
  800f26:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f29:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800f2c:	e9 4c fb ff ff       	jmp    800a7d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f35:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800f3c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f3f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800f43:	0f 84 34 fb ff ff    	je     800a7d <vprintfmt+0x23>
  800f49:	83 ee 01             	sub    $0x1,%esi
  800f4c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800f50:	75 f7                	jne    800f49 <vprintfmt+0x4ef>
  800f52:	e9 26 fb ff ff       	jmp    800a7d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800f57:	83 c4 5c             	add    $0x5c,%esp
  800f5a:	5b                   	pop    %ebx
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 28             	sub    $0x28,%esp
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f6e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800f72:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	74 30                	je     800fb0 <vsnprintf+0x51>
  800f80:	85 d2                	test   %edx,%edx
  800f82:	7e 2c                	jle    800fb0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f84:	8b 45 14             	mov    0x14(%ebp),%eax
  800f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f92:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f99:	c7 04 24 15 0a 80 00 	movl   $0x800a15,(%esp)
  800fa0:	e8 b5 fa ff ff       	call   800a5a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800fa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fae:	eb 05                	jmp    800fb5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800fb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800fbd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800fc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 82 ff ff ff       	call   800f5f <vsnprintf>
	va_end(ap);

	return rc;
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    
	...

00800fe0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  800feb:	80 3a 00             	cmpb   $0x0,(%edx)
  800fee:	74 09                	je     800ff9 <strlen+0x19>
		n++;
  800ff0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ff3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ff7:	75 f7                	jne    800ff0 <strlen+0x10>
		n++;
	return n;
}
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	85 c9                	test   %ecx,%ecx
  80100c:	74 1a                	je     801028 <strnlen+0x2d>
  80100e:	80 3b 00             	cmpb   $0x0,(%ebx)
  801011:	74 15                	je     801028 <strnlen+0x2d>
  801013:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801018:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80101a:	39 ca                	cmp    %ecx,%edx
  80101c:	74 0a                	je     801028 <strnlen+0x2d>
  80101e:	83 c2 01             	add    $0x1,%edx
  801021:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801026:	75 f0                	jne    801018 <strnlen+0x1d>
		n++;
	return n;
}
  801028:	5b                   	pop    %ebx
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	53                   	push   %ebx
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
  801032:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801035:	ba 00 00 00 00       	mov    $0x0,%edx
  80103a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80103e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801041:	83 c2 01             	add    $0x1,%edx
  801044:	84 c9                	test   %cl,%cl
  801046:	75 f2                	jne    80103a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801048:	5b                   	pop    %ebx
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801055:	89 1c 24             	mov    %ebx,(%esp)
  801058:	e8 83 ff ff ff       	call   800fe0 <strlen>
	strcpy(dst + len, src);
  80105d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801060:	89 54 24 04          	mov    %edx,0x4(%esp)
  801064:	01 d8                	add    %ebx,%eax
  801066:	89 04 24             	mov    %eax,(%esp)
  801069:	e8 bd ff ff ff       	call   80102b <strcpy>
	return dst;
}
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	5b                   	pop    %ebx
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801081:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801084:	85 f6                	test   %esi,%esi
  801086:	74 18                	je     8010a0 <strncpy+0x2a>
  801088:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80108d:	0f b6 1a             	movzbl (%edx),%ebx
  801090:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801093:	80 3a 01             	cmpb   $0x1,(%edx)
  801096:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801099:	83 c1 01             	add    $0x1,%ecx
  80109c:	39 f1                	cmp    %esi,%ecx
  80109e:	75 ed                	jne    80108d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010b0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8010b3:	89 f8                	mov    %edi,%eax
  8010b5:	85 f6                	test   %esi,%esi
  8010b7:	74 2b                	je     8010e4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8010b9:	83 fe 01             	cmp    $0x1,%esi
  8010bc:	74 23                	je     8010e1 <strlcpy+0x3d>
  8010be:	0f b6 0b             	movzbl (%ebx),%ecx
  8010c1:	84 c9                	test   %cl,%cl
  8010c3:	74 1c                	je     8010e1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8010c5:	83 ee 02             	sub    $0x2,%esi
  8010c8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8010cd:	88 08                	mov    %cl,(%eax)
  8010cf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8010d2:	39 f2                	cmp    %esi,%edx
  8010d4:	74 0b                	je     8010e1 <strlcpy+0x3d>
  8010d6:	83 c2 01             	add    $0x1,%edx
  8010d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8010dd:	84 c9                	test   %cl,%cl
  8010df:	75 ec                	jne    8010cd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8010e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8010e4:	29 f8                	sub    %edi,%eax
}
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010f4:	0f b6 01             	movzbl (%ecx),%eax
  8010f7:	84 c0                	test   %al,%al
  8010f9:	74 16                	je     801111 <strcmp+0x26>
  8010fb:	3a 02                	cmp    (%edx),%al
  8010fd:	75 12                	jne    801111 <strcmp+0x26>
		p++, q++;
  8010ff:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801102:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801106:	84 c0                	test   %al,%al
  801108:	74 07                	je     801111 <strcmp+0x26>
  80110a:	83 c1 01             	add    $0x1,%ecx
  80110d:	3a 02                	cmp    (%edx),%al
  80110f:	74 ee                	je     8010ff <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801111:	0f b6 c0             	movzbl %al,%eax
  801114:	0f b6 12             	movzbl (%edx),%edx
  801117:	29 d0                	sub    %edx,%eax
}
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	53                   	push   %ebx
  80111f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801125:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80112d:	85 d2                	test   %edx,%edx
  80112f:	74 28                	je     801159 <strncmp+0x3e>
  801131:	0f b6 01             	movzbl (%ecx),%eax
  801134:	84 c0                	test   %al,%al
  801136:	74 24                	je     80115c <strncmp+0x41>
  801138:	3a 03                	cmp    (%ebx),%al
  80113a:	75 20                	jne    80115c <strncmp+0x41>
  80113c:	83 ea 01             	sub    $0x1,%edx
  80113f:	74 13                	je     801154 <strncmp+0x39>
		n--, p++, q++;
  801141:	83 c1 01             	add    $0x1,%ecx
  801144:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801147:	0f b6 01             	movzbl (%ecx),%eax
  80114a:	84 c0                	test   %al,%al
  80114c:	74 0e                	je     80115c <strncmp+0x41>
  80114e:	3a 03                	cmp    (%ebx),%al
  801150:	74 ea                	je     80113c <strncmp+0x21>
  801152:	eb 08                	jmp    80115c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801159:	5b                   	pop    %ebx
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80115c:	0f b6 01             	movzbl (%ecx),%eax
  80115f:	0f b6 13             	movzbl (%ebx),%edx
  801162:	29 d0                	sub    %edx,%eax
  801164:	eb f3                	jmp    801159 <strncmp+0x3e>

00801166 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801170:	0f b6 10             	movzbl (%eax),%edx
  801173:	84 d2                	test   %dl,%dl
  801175:	74 1c                	je     801193 <strchr+0x2d>
		if (*s == c)
  801177:	38 ca                	cmp    %cl,%dl
  801179:	75 09                	jne    801184 <strchr+0x1e>
  80117b:	eb 1b                	jmp    801198 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80117d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  801180:	38 ca                	cmp    %cl,%dl
  801182:	74 14                	je     801198 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801184:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  801188:	84 d2                	test   %dl,%dl
  80118a:	75 f1                	jne    80117d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 05                	jmp    801198 <strchr+0x32>
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8011a4:	0f b6 10             	movzbl (%eax),%edx
  8011a7:	84 d2                	test   %dl,%dl
  8011a9:	74 14                	je     8011bf <strfind+0x25>
		if (*s == c)
  8011ab:	38 ca                	cmp    %cl,%dl
  8011ad:	75 06                	jne    8011b5 <strfind+0x1b>
  8011af:	eb 0e                	jmp    8011bf <strfind+0x25>
  8011b1:	38 ca                	cmp    %cl,%dl
  8011b3:	74 0a                	je     8011bf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8011b5:	83 c0 01             	add    $0x1,%eax
  8011b8:	0f b6 10             	movzbl (%eax),%edx
  8011bb:	84 d2                	test   %dl,%dl
  8011bd:	75 f2                	jne    8011b1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8011d9:	85 c9                	test   %ecx,%ecx
  8011db:	74 30                	je     80120d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011e3:	75 25                	jne    80120a <memset+0x49>
  8011e5:	f6 c1 03             	test   $0x3,%cl
  8011e8:	75 20                	jne    80120a <memset+0x49>
		c &= 0xFF;
  8011ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011ed:	89 d3                	mov    %edx,%ebx
  8011ef:	c1 e3 08             	shl    $0x8,%ebx
  8011f2:	89 d6                	mov    %edx,%esi
  8011f4:	c1 e6 18             	shl    $0x18,%esi
  8011f7:	89 d0                	mov    %edx,%eax
  8011f9:	c1 e0 10             	shl    $0x10,%eax
  8011fc:	09 f0                	or     %esi,%eax
  8011fe:	09 d0                	or     %edx,%eax
  801200:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801202:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801205:	fc                   	cld    
  801206:	f3 ab                	rep stos %eax,%es:(%edi)
  801208:	eb 03                	jmp    80120d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80120a:	fc                   	cld    
  80120b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80120d:	89 f8                	mov    %edi,%eax
  80120f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801212:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801215:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801218:	89 ec                	mov    %ebp,%esp
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801225:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801228:	8b 45 08             	mov    0x8(%ebp),%eax
  80122b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80122e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801231:	39 c6                	cmp    %eax,%esi
  801233:	73 36                	jae    80126b <memmove+0x4f>
  801235:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801238:	39 d0                	cmp    %edx,%eax
  80123a:	73 2f                	jae    80126b <memmove+0x4f>
		s += n;
		d += n;
  80123c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80123f:	f6 c2 03             	test   $0x3,%dl
  801242:	75 1b                	jne    80125f <memmove+0x43>
  801244:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80124a:	75 13                	jne    80125f <memmove+0x43>
  80124c:	f6 c1 03             	test   $0x3,%cl
  80124f:	75 0e                	jne    80125f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801251:	83 ef 04             	sub    $0x4,%edi
  801254:	8d 72 fc             	lea    -0x4(%edx),%esi
  801257:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80125a:	fd                   	std    
  80125b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80125d:	eb 09                	jmp    801268 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80125f:	83 ef 01             	sub    $0x1,%edi
  801262:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801265:	fd                   	std    
  801266:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801268:	fc                   	cld    
  801269:	eb 20                	jmp    80128b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80126b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801271:	75 13                	jne    801286 <memmove+0x6a>
  801273:	a8 03                	test   $0x3,%al
  801275:	75 0f                	jne    801286 <memmove+0x6a>
  801277:	f6 c1 03             	test   $0x3,%cl
  80127a:	75 0a                	jne    801286 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80127c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80127f:	89 c7                	mov    %eax,%edi
  801281:	fc                   	cld    
  801282:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801284:	eb 05                	jmp    80128b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801286:	89 c7                	mov    %eax,%edi
  801288:	fc                   	cld    
  801289:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80128b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80128e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801291:	89 ec                	mov    %ebp,%esp
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80129b:	8b 45 10             	mov    0x10(%ebp),%eax
  80129e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	e8 68 ff ff ff       	call   80121c <memmove>
}
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    

008012b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	57                   	push   %edi
  8012ba:	56                   	push   %esi
  8012bb:	53                   	push   %ebx
  8012bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012ca:	85 ff                	test   %edi,%edi
  8012cc:	74 37                	je     801305 <memcmp+0x4f>
		if (*s1 != *s2)
  8012ce:	0f b6 03             	movzbl (%ebx),%eax
  8012d1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012d4:	83 ef 01             	sub    $0x1,%edi
  8012d7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8012dc:	38 c8                	cmp    %cl,%al
  8012de:	74 1c                	je     8012fc <memcmp+0x46>
  8012e0:	eb 10                	jmp    8012f2 <memcmp+0x3c>
  8012e2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8012e7:	83 c2 01             	add    $0x1,%edx
  8012ea:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8012ee:	38 c8                	cmp    %cl,%al
  8012f0:	74 0a                	je     8012fc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  8012f2:	0f b6 c0             	movzbl %al,%eax
  8012f5:	0f b6 c9             	movzbl %cl,%ecx
  8012f8:	29 c8                	sub    %ecx,%eax
  8012fa:	eb 09                	jmp    801305 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012fc:	39 fa                	cmp    %edi,%edx
  8012fe:	75 e2                	jne    8012e2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801305:	5b                   	pop    %ebx
  801306:	5e                   	pop    %esi
  801307:	5f                   	pop    %edi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801310:	89 c2                	mov    %eax,%edx
  801312:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801315:	39 d0                	cmp    %edx,%eax
  801317:	73 19                	jae    801332 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801319:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  80131d:	38 08                	cmp    %cl,(%eax)
  80131f:	75 06                	jne    801327 <memfind+0x1d>
  801321:	eb 0f                	jmp    801332 <memfind+0x28>
  801323:	38 08                	cmp    %cl,(%eax)
  801325:	74 0b                	je     801332 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801327:	83 c0 01             	add    $0x1,%eax
  80132a:	39 d0                	cmp    %edx,%eax
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	75 f1                	jne    801323 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	57                   	push   %edi
  801338:	56                   	push   %esi
  801339:	53                   	push   %ebx
  80133a:	8b 55 08             	mov    0x8(%ebp),%edx
  80133d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801340:	0f b6 02             	movzbl (%edx),%eax
  801343:	3c 20                	cmp    $0x20,%al
  801345:	74 04                	je     80134b <strtol+0x17>
  801347:	3c 09                	cmp    $0x9,%al
  801349:	75 0e                	jne    801359 <strtol+0x25>
		s++;
  80134b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80134e:	0f b6 02             	movzbl (%edx),%eax
  801351:	3c 20                	cmp    $0x20,%al
  801353:	74 f6                	je     80134b <strtol+0x17>
  801355:	3c 09                	cmp    $0x9,%al
  801357:	74 f2                	je     80134b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801359:	3c 2b                	cmp    $0x2b,%al
  80135b:	75 0a                	jne    801367 <strtol+0x33>
		s++;
  80135d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801360:	bf 00 00 00 00       	mov    $0x0,%edi
  801365:	eb 10                	jmp    801377 <strtol+0x43>
  801367:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80136c:	3c 2d                	cmp    $0x2d,%al
  80136e:	75 07                	jne    801377 <strtol+0x43>
		s++, neg = 1;
  801370:	83 c2 01             	add    $0x1,%edx
  801373:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801377:	85 db                	test   %ebx,%ebx
  801379:	0f 94 c0             	sete   %al
  80137c:	74 05                	je     801383 <strtol+0x4f>
  80137e:	83 fb 10             	cmp    $0x10,%ebx
  801381:	75 15                	jne    801398 <strtol+0x64>
  801383:	80 3a 30             	cmpb   $0x30,(%edx)
  801386:	75 10                	jne    801398 <strtol+0x64>
  801388:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80138c:	75 0a                	jne    801398 <strtol+0x64>
		s += 2, base = 16;
  80138e:	83 c2 02             	add    $0x2,%edx
  801391:	bb 10 00 00 00       	mov    $0x10,%ebx
  801396:	eb 13                	jmp    8013ab <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801398:	84 c0                	test   %al,%al
  80139a:	74 0f                	je     8013ab <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80139c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8013a1:	80 3a 30             	cmpb   $0x30,(%edx)
  8013a4:	75 05                	jne    8013ab <strtol+0x77>
		s++, base = 8;
  8013a6:	83 c2 01             	add    $0x1,%edx
  8013a9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8013b2:	0f b6 0a             	movzbl (%edx),%ecx
  8013b5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8013b8:	80 fb 09             	cmp    $0x9,%bl
  8013bb:	77 08                	ja     8013c5 <strtol+0x91>
			dig = *s - '0';
  8013bd:	0f be c9             	movsbl %cl,%ecx
  8013c0:	83 e9 30             	sub    $0x30,%ecx
  8013c3:	eb 1e                	jmp    8013e3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  8013c5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8013c8:	80 fb 19             	cmp    $0x19,%bl
  8013cb:	77 08                	ja     8013d5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8013cd:	0f be c9             	movsbl %cl,%ecx
  8013d0:	83 e9 57             	sub    $0x57,%ecx
  8013d3:	eb 0e                	jmp    8013e3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8013d5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8013d8:	80 fb 19             	cmp    $0x19,%bl
  8013db:	77 14                	ja     8013f1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8013dd:	0f be c9             	movsbl %cl,%ecx
  8013e0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8013e3:	39 f1                	cmp    %esi,%ecx
  8013e5:	7d 0e                	jge    8013f5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8013e7:	83 c2 01             	add    $0x1,%edx
  8013ea:	0f af c6             	imul   %esi,%eax
  8013ed:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8013ef:	eb c1                	jmp    8013b2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8013f1:	89 c1                	mov    %eax,%ecx
  8013f3:	eb 02                	jmp    8013f7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8013f5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8013f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013fb:	74 05                	je     801402 <strtol+0xce>
		*endptr = (char *) s;
  8013fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801400:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801402:	89 ca                	mov    %ecx,%edx
  801404:	f7 da                	neg    %edx
  801406:	85 ff                	test   %edi,%edi
  801408:	0f 45 c2             	cmovne %edx,%eax
}
  80140b:	5b                   	pop    %ebx
  80140c:	5e                   	pop    %esi
  80140d:	5f                   	pop    %edi
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801419:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80141c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
  801424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801427:	8b 55 08             	mov    0x8(%ebp),%edx
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	89 c7                	mov    %eax,%edi
  80142e:	89 c6                	mov    %eax,%esi
  801430:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801432:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801435:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801438:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80143b:	89 ec                	mov    %ebp,%esp
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <sys_cgetc>:

int
sys_cgetc(void)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 0c             	sub    $0xc,%esp
  801445:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801448:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80144b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80144e:	ba 00 00 00 00       	mov    $0x0,%edx
  801453:	b8 01 00 00 00       	mov    $0x1,%eax
  801458:	89 d1                	mov    %edx,%ecx
  80145a:	89 d3                	mov    %edx,%ebx
  80145c:	89 d7                	mov    %edx,%edi
  80145e:	89 d6                	mov    %edx,%esi
  801460:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801462:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801465:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801468:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80146b:	89 ec                	mov    %ebp,%esp
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	83 ec 38             	sub    $0x38,%esp
  801475:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801478:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80147b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80147e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801483:	b8 03 00 00 00       	mov    $0x3,%eax
  801488:	8b 55 08             	mov    0x8(%ebp),%edx
  80148b:	89 cb                	mov    %ecx,%ebx
  80148d:	89 cf                	mov    %ecx,%edi
  80148f:	89 ce                	mov    %ecx,%esi
  801491:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801493:	85 c0                	test   %eax,%eax
  801495:	7e 28                	jle    8014bf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801497:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8014a2:	00 
  8014a3:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  8014aa:	00 
  8014ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014b2:	00 
  8014b3:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  8014ba:	e8 29 f3 ff ff       	call   8007e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c8:	89 ec                	mov    %ebp,%esp
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014db:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e5:	89 d1                	mov    %edx,%ecx
  8014e7:	89 d3                	mov    %edx,%ebx
  8014e9:	89 d7                	mov    %edx,%edi
  8014eb:	89 d6                	mov    %edx,%esi
  8014ed:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014ef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014f2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014f5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014f8:	89 ec                	mov    %ebp,%esp
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <sys_yield>:

void
sys_yield(void)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801505:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801508:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150b:	ba 00 00 00 00       	mov    $0x0,%edx
  801510:	b8 0b 00 00 00       	mov    $0xb,%eax
  801515:	89 d1                	mov    %edx,%ecx
  801517:	89 d3                	mov    %edx,%ebx
  801519:	89 d7                	mov    %edx,%edi
  80151b:	89 d6                	mov    %edx,%esi
  80151d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80151f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801522:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801525:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801528:	89 ec                	mov    %ebp,%esp
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 38             	sub    $0x38,%esp
  801532:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801535:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801538:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80153b:	be 00 00 00 00       	mov    $0x0,%esi
  801540:	b8 04 00 00 00       	mov    $0x4,%eax
  801545:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801548:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154b:	8b 55 08             	mov    0x8(%ebp),%edx
  80154e:	89 f7                	mov    %esi,%edi
  801550:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801552:	85 c0                	test   %eax,%eax
  801554:	7e 28                	jle    80157e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801556:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801561:	00 
  801562:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  801569:	00 
  80156a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801571:	00 
  801572:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  801579:	e8 6a f2 ff ff       	call   8007e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80157e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801581:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801584:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801587:	89 ec                	mov    %ebp,%esp
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 38             	sub    $0x38,%esp
  801591:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801594:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801597:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80159a:	b8 05 00 00 00       	mov    $0x5,%eax
  80159f:	8b 75 18             	mov    0x18(%ebp),%esi
  8015a2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	7e 28                	jle    8015dc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015b8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8015bf:	00 
  8015c0:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  8015c7:	00 
  8015c8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015cf:	00 
  8015d0:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  8015d7:	e8 0c f2 ff ff       	call   8007e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015dc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015df:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015e2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015e5:	89 ec                	mov    %ebp,%esp
  8015e7:	5d                   	pop    %ebp
  8015e8:	c3                   	ret    

008015e9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	83 ec 38             	sub    $0x38,%esp
  8015ef:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015f2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015f5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fd:	b8 06 00 00 00       	mov    $0x6,%eax
  801602:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801605:	8b 55 08             	mov    0x8(%ebp),%edx
  801608:	89 df                	mov    %ebx,%edi
  80160a:	89 de                	mov    %ebx,%esi
  80160c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80160e:	85 c0                	test   %eax,%eax
  801610:	7e 28                	jle    80163a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801612:	89 44 24 10          	mov    %eax,0x10(%esp)
  801616:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80161d:	00 
  80161e:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  801625:	00 
  801626:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80162d:	00 
  80162e:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  801635:	e8 ae f1 ff ff       	call   8007e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80163a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80163d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801640:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801643:	89 ec                	mov    %ebp,%esp
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 38             	sub    $0x38,%esp
  80164d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801650:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801653:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801656:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165b:	b8 08 00 00 00       	mov    $0x8,%eax
  801660:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801663:	8b 55 08             	mov    0x8(%ebp),%edx
  801666:	89 df                	mov    %ebx,%edi
  801668:	89 de                	mov    %ebx,%esi
  80166a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80166c:	85 c0                	test   %eax,%eax
  80166e:	7e 28                	jle    801698 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801670:	89 44 24 10          	mov    %eax,0x10(%esp)
  801674:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80167b:	00 
  80167c:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  801683:	00 
  801684:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80168b:	00 
  80168c:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  801693:	e8 50 f1 ff ff       	call   8007e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801698:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80169b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80169e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016a1:	89 ec                	mov    %ebp,%esp
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 38             	sub    $0x38,%esp
  8016ab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016ae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016b1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8016be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c4:	89 df                	mov    %ebx,%edi
  8016c6:	89 de                	mov    %ebx,%esi
  8016c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	7e 28                	jle    8016f6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016d2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8016d9:	00 
  8016da:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  8016e1:	00 
  8016e2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016e9:	00 
  8016ea:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  8016f1:	e8 f2 f0 ff ff       	call   8007e8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016ff:	89 ec                	mov    %ebp,%esp
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 38             	sub    $0x38,%esp
  801709:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80170c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80170f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801712:	bb 00 00 00 00       	mov    $0x0,%ebx
  801717:	b8 0a 00 00 00       	mov    $0xa,%eax
  80171c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171f:	8b 55 08             	mov    0x8(%ebp),%edx
  801722:	89 df                	mov    %ebx,%edi
  801724:	89 de                	mov    %ebx,%esi
  801726:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801728:	85 c0                	test   %eax,%eax
  80172a:	7e 28                	jle    801754 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80172c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801730:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801737:	00 
  801738:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  80173f:	00 
  801740:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801747:	00 
  801748:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  80174f:	e8 94 f0 ff ff       	call   8007e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801754:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801757:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80175a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80175d:	89 ec                	mov    %ebp,%esp
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 0c             	sub    $0xc,%esp
  801767:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80176a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80176d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801770:	be 00 00 00 00       	mov    $0x0,%esi
  801775:	b8 0c 00 00 00       	mov    $0xc,%eax
  80177a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80177d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801783:	8b 55 08             	mov    0x8(%ebp),%edx
  801786:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801788:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80178b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80178e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801791:	89 ec                	mov    %ebp,%esp
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 38             	sub    $0x38,%esp
  80179b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80179e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017a9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b1:	89 cb                	mov    %ecx,%ebx
  8017b3:	89 cf                	mov    %ecx,%edi
  8017b5:	89 ce                	mov    %ecx,%esi
  8017b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	7e 28                	jle    8017e5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017c1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017c8:	00 
  8017c9:	c7 44 24 08 1f 31 80 	movl   $0x80311f,0x8(%esp)
  8017d0:	00 
  8017d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017d8:	00 
  8017d9:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  8017e0:	e8 03 f0 ff ff       	call   8007e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017e5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017e8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017eb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017ee:	89 ec                	mov    %ebp,%esp
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017fb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017fe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801801:	b9 00 00 00 00       	mov    $0x0,%ecx
  801806:	b8 0e 00 00 00       	mov    $0xe,%eax
  80180b:	8b 55 08             	mov    0x8(%ebp),%edx
  80180e:	89 cb                	mov    %ecx,%ebx
  801810:	89 cf                	mov    %ecx,%edi
  801812:	89 ce                	mov    %ecx,%esi
  801814:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801816:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801819:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80181c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80181f:	89 ec                	mov    %ebp,%esp
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    
	...

00801824 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	83 ec 10             	sub    $0x10,%esp
  80182c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80182f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801832:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801835:	85 db                	test   %ebx,%ebx
  801837:	74 06                	je     80183f <ipc_recv+0x1b>
  801839:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80183f:	85 f6                	test   %esi,%esi
  801841:	74 06                	je     801849 <ipc_recv+0x25>
  801843:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801849:	85 c0                	test   %eax,%eax
  80184b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801850:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801853:	89 04 24             	mov    %eax,(%esp)
  801856:	e8 3a ff ff ff       	call   801795 <sys_ipc_recv>
    if (ret) return ret;
  80185b:	85 c0                	test   %eax,%eax
  80185d:	75 24                	jne    801883 <ipc_recv+0x5f>
    if (from_env_store)
  80185f:	85 db                	test   %ebx,%ebx
  801861:	74 0a                	je     80186d <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801863:	a1 04 50 80 00       	mov    0x805004,%eax
  801868:	8b 40 74             	mov    0x74(%eax),%eax
  80186b:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  80186d:	85 f6                	test   %esi,%esi
  80186f:	74 0a                	je     80187b <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801871:	a1 04 50 80 00       	mov    0x805004,%eax
  801876:	8b 40 78             	mov    0x78(%eax),%eax
  801879:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  80187b:	a1 04 50 80 00       	mov    0x805004,%eax
  801880:	8b 40 70             	mov    0x70(%eax),%eax
}
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
  801890:	83 ec 1c             	sub    $0x1c,%esp
  801893:	8b 75 08             	mov    0x8(%ebp),%esi
  801896:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801899:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80189c:	85 db                	test   %ebx,%ebx
  80189e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8018a3:	0f 44 d8             	cmove  %eax,%ebx
  8018a6:	eb 2a                	jmp    8018d2 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8018a8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8018ab:	74 20                	je     8018cd <ipc_send+0x43>
  8018ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b1:	c7 44 24 08 4a 31 80 	movl   $0x80314a,0x8(%esp)
  8018b8:	00 
  8018b9:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8018c0:	00 
  8018c1:	c7 04 24 61 31 80 00 	movl   $0x803161,(%esp)
  8018c8:	e8 1b ef ff ff       	call   8007e8 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8018cd:	e8 2a fc ff ff       	call   8014fc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8018d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018e1:	89 34 24             	mov    %esi,(%esp)
  8018e4:	e8 78 fe ff ff       	call   801761 <sys_ipc_try_send>
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	75 bb                	jne    8018a8 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8018ed:	83 c4 1c             	add    $0x1c,%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5f                   	pop    %edi
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8018fb:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801900:	39 c8                	cmp    %ecx,%eax
  801902:	74 19                	je     80191d <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801904:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801909:	89 c2                	mov    %eax,%edx
  80190b:	c1 e2 07             	shl    $0x7,%edx
  80190e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801914:	8b 52 50             	mov    0x50(%edx),%edx
  801917:	39 ca                	cmp    %ecx,%edx
  801919:	75 14                	jne    80192f <ipc_find_env+0x3a>
  80191b:	eb 05                	jmp    801922 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801922:	c1 e0 07             	shl    $0x7,%eax
  801925:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80192a:	8b 40 40             	mov    0x40(%eax),%eax
  80192d:	eb 0e                	jmp    80193d <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80192f:	83 c0 01             	add    $0x1,%eax
  801932:	3d 00 04 00 00       	cmp    $0x400,%eax
  801937:	75 d0                	jne    801909 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801939:	66 b8 00 00          	mov    $0x0,%ax
}
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    
	...

00801940 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	05 00 00 00 30       	add    $0x30000000,%eax
  80194b:	c1 e8 0c             	shr    $0xc,%eax
}
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	89 04 24             	mov    %eax,(%esp)
  80195c:	e8 df ff ff ff       	call   801940 <fd2num>
  801961:	05 20 00 0d 00       	add    $0xd0020,%eax
  801966:	c1 e0 0c             	shl    $0xc,%eax
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	53                   	push   %ebx
  80196f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801972:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801977:	a8 01                	test   $0x1,%al
  801979:	74 34                	je     8019af <fd_alloc+0x44>
  80197b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801980:	a8 01                	test   $0x1,%al
  801982:	74 32                	je     8019b6 <fd_alloc+0x4b>
  801984:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801989:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80198b:	89 c2                	mov    %eax,%edx
  80198d:	c1 ea 16             	shr    $0x16,%edx
  801990:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801997:	f6 c2 01             	test   $0x1,%dl
  80199a:	74 1f                	je     8019bb <fd_alloc+0x50>
  80199c:	89 c2                	mov    %eax,%edx
  80199e:	c1 ea 0c             	shr    $0xc,%edx
  8019a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019a8:	f6 c2 01             	test   $0x1,%dl
  8019ab:	75 17                	jne    8019c4 <fd_alloc+0x59>
  8019ad:	eb 0c                	jmp    8019bb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8019af:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8019b4:	eb 05                	jmp    8019bb <fd_alloc+0x50>
  8019b6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8019bb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	eb 17                	jmp    8019db <fd_alloc+0x70>
  8019c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8019c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019ce:	75 b9                	jne    801989 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8019d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8019d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8019e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019e9:	83 fa 1f             	cmp    $0x1f,%edx
  8019ec:	77 3f                	ja     801a2d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019ee:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8019f4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8019f7:	89 d0                	mov    %edx,%eax
  8019f9:	c1 e8 16             	shr    $0x16,%eax
  8019fc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801a08:	f6 c1 01             	test   $0x1,%cl
  801a0b:	74 20                	je     801a2d <fd_lookup+0x4f>
  801a0d:	89 d0                	mov    %edx,%eax
  801a0f:	c1 e8 0c             	shr    $0xc,%eax
  801a12:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801a1e:	f6 c1 01             	test   $0x1,%cl
  801a21:	74 0a                	je     801a2d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a26:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	53                   	push   %ebx
  801a33:	83 ec 14             	sub    $0x14,%esp
  801a36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801a41:	39 0d 0c 40 80 00    	cmp    %ecx,0x80400c
  801a47:	75 17                	jne    801a60 <dev_lookup+0x31>
  801a49:	eb 07                	jmp    801a52 <dev_lookup+0x23>
  801a4b:	39 0a                	cmp    %ecx,(%edx)
  801a4d:	75 11                	jne    801a60 <dev_lookup+0x31>
  801a4f:	90                   	nop
  801a50:	eb 05                	jmp    801a57 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a52:	ba 0c 40 80 00       	mov    $0x80400c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801a57:	89 13                	mov    %edx,(%ebx)
			return 0;
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5e:	eb 35                	jmp    801a95 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a60:	83 c0 01             	add    $0x1,%eax
  801a63:	8b 14 85 ec 31 80 00 	mov    0x8031ec(,%eax,4),%edx
  801a6a:	85 d2                	test   %edx,%edx
  801a6c:	75 dd                	jne    801a4b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a6e:	a1 04 50 80 00       	mov    0x805004,%eax
  801a73:	8b 40 48             	mov    0x48(%eax),%eax
  801a76:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7e:	c7 04 24 6c 31 80 00 	movl   $0x80316c,(%esp)
  801a85:	e8 59 ee ff ff       	call   8008e3 <cprintf>
	*dev = 0;
  801a8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801a90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a95:	83 c4 14             	add    $0x14,%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 38             	sub    $0x38,%esp
  801aa1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801aa4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801aa7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aad:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ab1:	89 3c 24             	mov    %edi,(%esp)
  801ab4:	e8 87 fe ff ff       	call   801940 <fd2num>
  801ab9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801abc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ac0:	89 04 24             	mov    %eax,(%esp)
  801ac3:	e8 16 ff ff ff       	call   8019de <fd_lookup>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 05                	js     801ad3 <fd_close+0x38>
	    || fd != fd2)
  801ace:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801ad1:	74 0e                	je     801ae1 <fd_close+0x46>
		return (must_exist ? r : 0);
  801ad3:	89 f0                	mov    %esi,%eax
  801ad5:	84 c0                	test   %al,%al
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  801adc:	0f 44 d8             	cmove  %eax,%ebx
  801adf:	eb 3d                	jmp    801b1e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ae1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	8b 07                	mov    (%edi),%eax
  801aea:	89 04 24             	mov    %eax,(%esp)
  801aed:	e8 3d ff ff ff       	call   801a2f <dev_lookup>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 16                	js     801b0e <fd_close+0x73>
		if (dev->dev_close)
  801af8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801afb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801afe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801b03:	85 c0                	test   %eax,%eax
  801b05:	74 07                	je     801b0e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801b07:	89 3c 24             	mov    %edi,(%esp)
  801b0a:	ff d0                	call   *%eax
  801b0c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b19:	e8 cb fa ff ff       	call   8015e9 <sys_page_unmap>
	return r;
}
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b23:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b26:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b29:	89 ec                	mov    %ebp,%esp
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	89 04 24             	mov    %eax,(%esp)
  801b40:	e8 99 fe ff ff       	call   8019de <fd_lookup>
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 13                	js     801b5c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b49:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b50:	00 
  801b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 3f ff ff ff       	call   801a9b <fd_close>
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <close_all>:

void
close_all(void)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801b65:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801b6a:	89 1c 24             	mov    %ebx,(%esp)
  801b6d:	e8 bb ff ff ff       	call   801b2d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b72:	83 c3 01             	add    $0x1,%ebx
  801b75:	83 fb 20             	cmp    $0x20,%ebx
  801b78:	75 f0                	jne    801b6a <close_all+0xc>
		close(i);
}
  801b7a:	83 c4 14             	add    $0x14,%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 58             	sub    $0x58,%esp
  801b86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b8f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b92:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	89 04 24             	mov    %eax,(%esp)
  801b9f:	e8 3a fe ff ff       	call   8019de <fd_lookup>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	0f 88 e1 00 00 00    	js     801c8f <dup+0x10f>
		return r;
	close(newfdnum);
  801bae:	89 3c 24             	mov    %edi,(%esp)
  801bb1:	e8 77 ff ff ff       	call   801b2d <close>

	newfd = INDEX2FD(newfdnum);
  801bb6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bbc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc2:	89 04 24             	mov    %eax,(%esp)
  801bc5:	e8 86 fd ff ff       	call   801950 <fd2data>
  801bca:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bcc:	89 34 24             	mov    %esi,(%esp)
  801bcf:	e8 7c fd ff ff       	call   801950 <fd2data>
  801bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801bd7:	89 d8                	mov    %ebx,%eax
  801bd9:	c1 e8 16             	shr    $0x16,%eax
  801bdc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801be3:	a8 01                	test   $0x1,%al
  801be5:	74 46                	je     801c2d <dup+0xad>
  801be7:	89 d8                	mov    %ebx,%eax
  801be9:	c1 e8 0c             	shr    $0xc,%eax
  801bec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bf3:	f6 c2 01             	test   $0x1,%dl
  801bf6:	74 35                	je     801c2d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bf8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bff:	25 07 0e 00 00       	and    $0xe07,%eax
  801c04:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c16:	00 
  801c17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c22:	e8 64 f9 ff ff       	call   80158b <sys_page_map>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 3b                	js     801c68 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c30:	89 c2                	mov    %eax,%edx
  801c32:	c1 ea 0c             	shr    $0xc,%edx
  801c35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c3c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c42:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c46:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c51:	00 
  801c52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5d:	e8 29 f9 ff ff       	call   80158b <sys_page_map>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	85 c0                	test   %eax,%eax
  801c66:	79 25                	jns    801c8d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c68:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c73:	e8 71 f9 ff ff       	call   8015e9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c86:	e8 5e f9 ff ff       	call   8015e9 <sys_page_unmap>
	return r;
  801c8b:	eb 02                	jmp    801c8f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801c8d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801c8f:	89 d8                	mov    %ebx,%eax
  801c91:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c94:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c97:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c9a:	89 ec                	mov    %ebp,%esp
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 24             	sub    $0x24,%esp
  801ca5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ca8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caf:	89 1c 24             	mov    %ebx,(%esp)
  801cb2:	e8 27 fd ff ff       	call   8019de <fd_lookup>
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 6d                	js     801d28 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc5:	8b 00                	mov    (%eax),%eax
  801cc7:	89 04 24             	mov    %eax,(%esp)
  801cca:	e8 60 fd ff ff       	call   801a2f <dev_lookup>
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 55                	js     801d28 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd6:	8b 50 08             	mov    0x8(%eax),%edx
  801cd9:	83 e2 03             	and    $0x3,%edx
  801cdc:	83 fa 01             	cmp    $0x1,%edx
  801cdf:	75 23                	jne    801d04 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ce1:	a1 04 50 80 00       	mov    0x805004,%eax
  801ce6:	8b 40 48             	mov    0x48(%eax),%eax
  801ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf1:	c7 04 24 b0 31 80 00 	movl   $0x8031b0,(%esp)
  801cf8:	e8 e6 eb ff ff       	call   8008e3 <cprintf>
		return -E_INVAL;
  801cfd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d02:	eb 24                	jmp    801d28 <read+0x8a>
	}
	if (!dev->dev_read)
  801d04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d07:	8b 52 08             	mov    0x8(%edx),%edx
  801d0a:	85 d2                	test   %edx,%edx
  801d0c:	74 15                	je     801d23 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801d11:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d18:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d1c:	89 04 24             	mov    %eax,(%esp)
  801d1f:	ff d2                	call   *%edx
  801d21:	eb 05                	jmp    801d28 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801d23:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801d28:	83 c4 24             	add    $0x24,%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 1c             	sub    $0x1c,%esp
  801d37:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d3a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d42:	85 f6                	test   %esi,%esi
  801d44:	74 30                	je     801d76 <readn+0x48>
  801d46:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801d4b:	89 f2                	mov    %esi,%edx
  801d4d:	29 c2                	sub    %eax,%edx
  801d4f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d53:	03 45 0c             	add    0xc(%ebp),%eax
  801d56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5a:	89 3c 24             	mov    %edi,(%esp)
  801d5d:	e8 3c ff ff ff       	call   801c9e <read>
		if (m < 0)
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 10                	js     801d76 <readn+0x48>
			return m;
		if (m == 0)
  801d66:	85 c0                	test   %eax,%eax
  801d68:	74 0a                	je     801d74 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d6a:	01 c3                	add    %eax,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	39 f3                	cmp    %esi,%ebx
  801d70:	72 d9                	jb     801d4b <readn+0x1d>
  801d72:	eb 02                	jmp    801d76 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801d74:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801d76:	83 c4 1c             	add    $0x1c,%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	53                   	push   %ebx
  801d82:	83 ec 24             	sub    $0x24,%esp
  801d85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8f:	89 1c 24             	mov    %ebx,(%esp)
  801d92:	e8 47 fc ff ff       	call   8019de <fd_lookup>
  801d97:	85 c0                	test   %eax,%eax
  801d99:	78 68                	js     801e03 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da5:	8b 00                	mov    (%eax),%eax
  801da7:	89 04 24             	mov    %eax,(%esp)
  801daa:	e8 80 fc ff ff       	call   801a2f <dev_lookup>
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 50                	js     801e03 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801dba:	75 23                	jne    801ddf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801dbc:	a1 04 50 80 00       	mov    0x805004,%eax
  801dc1:	8b 40 48             	mov    0x48(%eax),%eax
  801dc4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcc:	c7 04 24 cc 31 80 00 	movl   $0x8031cc,(%esp)
  801dd3:	e8 0b eb ff ff       	call   8008e3 <cprintf>
		return -E_INVAL;
  801dd8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ddd:	eb 24                	jmp    801e03 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ddf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801de2:	8b 52 0c             	mov    0xc(%edx),%edx
  801de5:	85 d2                	test   %edx,%edx
  801de7:	74 15                	je     801dfe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801de9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801dec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801df3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801df7:	89 04 24             	mov    %eax,(%esp)
  801dfa:	ff d2                	call   *%edx
  801dfc:	eb 05                	jmp    801e03 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801dfe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801e03:	83 c4 24             	add    $0x24,%esp
  801e06:	5b                   	pop    %ebx
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <seek>:

int
seek(int fdnum, off_t offset)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e0f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	89 04 24             	mov    %eax,(%esp)
  801e1c:	e8 bd fb ff ff       	call   8019de <fd_lookup>
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 0e                	js     801e33 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801e25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	53                   	push   %ebx
  801e39:	83 ec 24             	sub    $0x24,%esp
  801e3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e46:	89 1c 24             	mov    %ebx,(%esp)
  801e49:	e8 90 fb ff ff       	call   8019de <fd_lookup>
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 61                	js     801eb3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e5c:	8b 00                	mov    (%eax),%eax
  801e5e:	89 04 24             	mov    %eax,(%esp)
  801e61:	e8 c9 fb ff ff       	call   801a2f <dev_lookup>
  801e66:	85 c0                	test   %eax,%eax
  801e68:	78 49                	js     801eb3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e71:	75 23                	jne    801e96 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e73:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e78:	8b 40 48             	mov    0x48(%eax),%eax
  801e7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e83:	c7 04 24 8c 31 80 00 	movl   $0x80318c,(%esp)
  801e8a:	e8 54 ea ff ff       	call   8008e3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e94:	eb 1d                	jmp    801eb3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801e96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e99:	8b 52 18             	mov    0x18(%edx),%edx
  801e9c:	85 d2                	test   %edx,%edx
  801e9e:	74 0e                	je     801eae <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ea7:	89 04 24             	mov    %eax,(%esp)
  801eaa:	ff d2                	call   *%edx
  801eac:	eb 05                	jmp    801eb3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801eae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801eb3:	83 c4 24             	add    $0x24,%esp
  801eb6:	5b                   	pop    %ebx
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	53                   	push   %ebx
  801ebd:	83 ec 24             	sub    $0x24,%esp
  801ec0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ec3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eca:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecd:	89 04 24             	mov    %eax,(%esp)
  801ed0:	e8 09 fb ff ff       	call   8019de <fd_lookup>
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 52                	js     801f2b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee3:	8b 00                	mov    (%eax),%eax
  801ee5:	89 04 24             	mov    %eax,(%esp)
  801ee8:	e8 42 fb ff ff       	call   801a2f <dev_lookup>
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 3a                	js     801f2b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ef8:	74 2c                	je     801f26 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801efa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801efd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801f04:	00 00 00 
	stat->st_isdir = 0;
  801f07:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f0e:	00 00 00 
	stat->st_dev = dev;
  801f11:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801f17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f1e:	89 14 24             	mov    %edx,(%esp)
  801f21:	ff 50 14             	call   *0x14(%eax)
  801f24:	eb 05                	jmp    801f2b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801f26:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801f2b:	83 c4 24             	add    $0x24,%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 18             	sub    $0x18,%esp
  801f37:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f3a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801f3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f44:	00 
  801f45:	8b 45 08             	mov    0x8(%ebp),%eax
  801f48:	89 04 24             	mov    %eax,(%esp)
  801f4b:	e8 bc 01 00 00       	call   80210c <open>
  801f50:	89 c3                	mov    %eax,%ebx
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 1b                	js     801f71 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	89 1c 24             	mov    %ebx,(%esp)
  801f60:	e8 54 ff ff ff       	call   801eb9 <fstat>
  801f65:	89 c6                	mov    %eax,%esi
	close(fd);
  801f67:	89 1c 24             	mov    %ebx,(%esp)
  801f6a:	e8 be fb ff ff       	call   801b2d <close>
	return r;
  801f6f:	89 f3                	mov    %esi,%ebx
}
  801f71:	89 d8                	mov    %ebx,%eax
  801f73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f79:	89 ec                	mov    %ebp,%esp
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	00 00                	add    %al,(%eax)
	...

00801f80 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 18             	sub    $0x18,%esp
  801f86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f89:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f8c:	89 c3                	mov    %eax,%ebx
  801f8e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801f90:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801f97:	75 11                	jne    801faa <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801fa0:	e8 50 f9 ff ff       	call   8018f5 <ipc_find_env>
  801fa5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801faa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fb1:	00 
  801fb2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801fb9:	00 
  801fba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fbe:	a1 00 50 80 00       	mov    0x805000,%eax
  801fc3:	89 04 24             	mov    %eax,(%esp)
  801fc6:	e8 bf f8 ff ff       	call   80188a <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801fcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fd2:	00 
  801fd3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fde:	e8 41 f8 ff ff       	call   801824 <ipc_recv>
}
  801fe3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fe6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fe9:	89 ec                	mov    %ebp,%esp
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	53                   	push   %ebx
  801ff1:	83 ec 14             	sub    $0x14,%esp
  801ff4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffa:	8b 40 0c             	mov    0xc(%eax),%eax
  801ffd:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802002:	ba 00 00 00 00       	mov    $0x0,%edx
  802007:	b8 05 00 00 00       	mov    $0x5,%eax
  80200c:	e8 6f ff ff ff       	call   801f80 <fsipc>
  802011:	85 c0                	test   %eax,%eax
  802013:	78 2b                	js     802040 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802015:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80201c:	00 
  80201d:	89 1c 24             	mov    %ebx,(%esp)
  802020:	e8 06 f0 ff ff       	call   80102b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802025:	a1 80 60 80 00       	mov    0x806080,%eax
  80202a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802030:	a1 84 60 80 00       	mov    0x806084,%eax
  802035:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802040:	83 c4 14             	add    $0x14,%esp
  802043:	5b                   	pop    %ebx
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    

00802046 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	8b 40 0c             	mov    0xc(%eax),%eax
  802052:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802057:	ba 00 00 00 00       	mov    $0x0,%edx
  80205c:	b8 06 00 00 00       	mov    $0x6,%eax
  802061:	e8 1a ff ff ff       	call   801f80 <fsipc>
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	56                   	push   %esi
  80206c:	53                   	push   %ebx
  80206d:	83 ec 10             	sub    $0x10,%esp
  802070:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802073:	8b 45 08             	mov    0x8(%ebp),%eax
  802076:	8b 40 0c             	mov    0xc(%eax),%eax
  802079:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80207e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802084:	ba 00 00 00 00       	mov    $0x0,%edx
  802089:	b8 03 00 00 00       	mov    $0x3,%eax
  80208e:	e8 ed fe ff ff       	call   801f80 <fsipc>
  802093:	89 c3                	mov    %eax,%ebx
  802095:	85 c0                	test   %eax,%eax
  802097:	78 6a                	js     802103 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 24                	jae    8020c1 <devfile_read+0x59>
  80209d:	c7 44 24 0c fc 31 80 	movl   $0x8031fc,0xc(%esp)
  8020a4:	00 
  8020a5:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  8020ac:	00 
  8020ad:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  8020b4:	00 
  8020b5:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8020bc:	e8 27 e7 ff ff       	call   8007e8 <_panic>
	assert(r <= PGSIZE);
  8020c1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020c6:	7e 24                	jle    8020ec <devfile_read+0x84>
  8020c8:	c7 44 24 0c 23 32 80 	movl   $0x803223,0xc(%esp)
  8020cf:	00 
  8020d0:	c7 44 24 08 03 32 80 	movl   $0x803203,0x8(%esp)
  8020d7:	00 
  8020d8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8020df:	00 
  8020e0:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8020e7:	e8 fc e6 ff ff       	call   8007e8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8020ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020f0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020f7:	00 
  8020f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 19 f1 ff ff       	call   80121c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  802103:	89 d8                	mov    %ebx,%eax
  802105:	83 c4 10             	add    $0x10,%esp
  802108:	5b                   	pop    %ebx
  802109:	5e                   	pop    %esi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	56                   	push   %esi
  802110:	53                   	push   %ebx
  802111:	83 ec 20             	sub    $0x20,%esp
  802114:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802117:	89 34 24             	mov    %esi,(%esp)
  80211a:	e8 c1 ee ff ff       	call   800fe0 <strlen>
		return -E_BAD_PATH;
  80211f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802124:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802129:	7f 5e                	jg     802189 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80212b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212e:	89 04 24             	mov    %eax,(%esp)
  802131:	e8 35 f8 ff ff       	call   80196b <fd_alloc>
  802136:	89 c3                	mov    %eax,%ebx
  802138:	85 c0                	test   %eax,%eax
  80213a:	78 4d                	js     802189 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80213c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802140:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802147:	e8 df ee ff ff       	call   80102b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80214c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802154:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802157:	b8 01 00 00 00       	mov    $0x1,%eax
  80215c:	e8 1f fe ff ff       	call   801f80 <fsipc>
  802161:	89 c3                	mov    %eax,%ebx
  802163:	85 c0                	test   %eax,%eax
  802165:	79 15                	jns    80217c <open+0x70>
		fd_close(fd, 0);
  802167:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80216e:	00 
  80216f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802172:	89 04 24             	mov    %eax,(%esp)
  802175:	e8 21 f9 ff ff       	call   801a9b <fd_close>
		return r;
  80217a:	eb 0d                	jmp    802189 <open+0x7d>
	}

	return fd2num(fd);
  80217c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217f:	89 04 24             	mov    %eax,(%esp)
  802182:	e8 b9 f7 ff ff       	call   801940 <fd2num>
  802187:	89 c3                	mov    %eax,%ebx
}
  802189:	89 d8                	mov    %ebx,%eax
  80218b:	83 c4 20             	add    $0x20,%esp
  80218e:	5b                   	pop    %ebx
  80218f:	5e                   	pop    %esi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
	...

008021a0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 18             	sub    $0x18,%esp
  8021a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8021a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8021ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	89 04 24             	mov    %eax,(%esp)
  8021b5:	e8 96 f7 ff ff       	call   801950 <fd2data>
  8021ba:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021bc:	c7 44 24 04 2f 32 80 	movl   $0x80322f,0x4(%esp)
  8021c3:	00 
  8021c4:	89 34 24             	mov    %esi,(%esp)
  8021c7:	e8 5f ee ff ff       	call   80102b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8021cf:	2b 03                	sub    (%ebx),%eax
  8021d1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021d7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021de:	00 00 00 
	stat->st_dev = &devpipe;
  8021e1:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  8021e8:	40 80 00 
	return 0;
}
  8021eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021f3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021f6:	89 ec                	mov    %ebp,%esp
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    

008021fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	53                   	push   %ebx
  8021fe:	83 ec 14             	sub    $0x14,%esp
  802201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802204:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802208:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80220f:	e8 d5 f3 ff ff       	call   8015e9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802214:	89 1c 24             	mov    %ebx,(%esp)
  802217:	e8 34 f7 ff ff       	call   801950 <fd2data>
  80221c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802227:	e8 bd f3 ff ff       	call   8015e9 <sys_page_unmap>
}
  80222c:	83 c4 14             	add    $0x14,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    

00802232 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	83 ec 2c             	sub    $0x2c,%esp
  80223b:	89 c7                	mov    %eax,%edi
  80223d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802240:	a1 04 50 80 00       	mov    0x805004,%eax
  802245:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802248:	89 3c 24             	mov    %edi,(%esp)
  80224b:	e8 e0 04 00 00       	call   802730 <pageref>
  802250:	89 c6                	mov    %eax,%esi
  802252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802255:	89 04 24             	mov    %eax,(%esp)
  802258:	e8 d3 04 00 00       	call   802730 <pageref>
  80225d:	39 c6                	cmp    %eax,%esi
  80225f:	0f 94 c0             	sete   %al
  802262:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802265:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80226b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80226e:	39 cb                	cmp    %ecx,%ebx
  802270:	75 08                	jne    80227a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802272:	83 c4 2c             	add    $0x2c,%esp
  802275:	5b                   	pop    %ebx
  802276:	5e                   	pop    %esi
  802277:	5f                   	pop    %edi
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80227a:	83 f8 01             	cmp    $0x1,%eax
  80227d:	75 c1                	jne    802240 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80227f:	8b 52 58             	mov    0x58(%edx),%edx
  802282:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802286:	89 54 24 08          	mov    %edx,0x8(%esp)
  80228a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80228e:	c7 04 24 36 32 80 00 	movl   $0x803236,(%esp)
  802295:	e8 49 e6 ff ff       	call   8008e3 <cprintf>
  80229a:	eb a4                	jmp    802240 <_pipeisclosed+0xe>

0080229c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	57                   	push   %edi
  8022a0:	56                   	push   %esi
  8022a1:	53                   	push   %ebx
  8022a2:	83 ec 2c             	sub    $0x2c,%esp
  8022a5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022a8:	89 34 24             	mov    %esi,(%esp)
  8022ab:	e8 a0 f6 ff ff       	call   801950 <fd2data>
  8022b0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8022b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022bb:	75 50                	jne    80230d <devpipe_write+0x71>
  8022bd:	eb 5c                	jmp    80231b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022bf:	89 da                	mov    %ebx,%edx
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	e8 6a ff ff ff       	call   802232 <_pipeisclosed>
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	75 53                	jne    80231f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022cc:	e8 2b f2 ff ff       	call   8014fc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022d1:	8b 43 04             	mov    0x4(%ebx),%eax
  8022d4:	8b 13                	mov    (%ebx),%edx
  8022d6:	83 c2 20             	add    $0x20,%edx
  8022d9:	39 d0                	cmp    %edx,%eax
  8022db:	73 e2                	jae    8022bf <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022e0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8022e4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8022e7:	89 c2                	mov    %eax,%edx
  8022e9:	c1 fa 1f             	sar    $0x1f,%edx
  8022ec:	c1 ea 1b             	shr    $0x1b,%edx
  8022ef:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8022f2:	83 e1 1f             	and    $0x1f,%ecx
  8022f5:	29 d1                	sub    %edx,%ecx
  8022f7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8022fb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8022ff:	83 c0 01             	add    $0x1,%eax
  802302:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802305:	83 c7 01             	add    $0x1,%edi
  802308:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80230b:	74 0e                	je     80231b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80230d:	8b 43 04             	mov    0x4(%ebx),%eax
  802310:	8b 13                	mov    (%ebx),%edx
  802312:	83 c2 20             	add    $0x20,%edx
  802315:	39 d0                	cmp    %edx,%eax
  802317:	73 a6                	jae    8022bf <devpipe_write+0x23>
  802319:	eb c2                	jmp    8022dd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80231b:	89 f8                	mov    %edi,%eax
  80231d:	eb 05                	jmp    802324 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80231f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802324:	83 c4 2c             	add    $0x2c,%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5f                   	pop    %edi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    

0080232c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	83 ec 28             	sub    $0x28,%esp
  802332:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802335:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802338:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80233b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80233e:	89 3c 24             	mov    %edi,(%esp)
  802341:	e8 0a f6 ff ff       	call   801950 <fd2data>
  802346:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802348:	be 00 00 00 00       	mov    $0x0,%esi
  80234d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802351:	75 47                	jne    80239a <devpipe_read+0x6e>
  802353:	eb 52                	jmp    8023a7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802355:	89 f0                	mov    %esi,%eax
  802357:	eb 5e                	jmp    8023b7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802359:	89 da                	mov    %ebx,%edx
  80235b:	89 f8                	mov    %edi,%eax
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	e8 cd fe ff ff       	call   802232 <_pipeisclosed>
  802365:	85 c0                	test   %eax,%eax
  802367:	75 49                	jne    8023b2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802369:	e8 8e f1 ff ff       	call   8014fc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80236e:	8b 03                	mov    (%ebx),%eax
  802370:	3b 43 04             	cmp    0x4(%ebx),%eax
  802373:	74 e4                	je     802359 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802375:	89 c2                	mov    %eax,%edx
  802377:	c1 fa 1f             	sar    $0x1f,%edx
  80237a:	c1 ea 1b             	shr    $0x1b,%edx
  80237d:	01 d0                	add    %edx,%eax
  80237f:	83 e0 1f             	and    $0x1f,%eax
  802382:	29 d0                	sub    %edx,%eax
  802384:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802389:	8b 55 0c             	mov    0xc(%ebp),%edx
  80238c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80238f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802392:	83 c6 01             	add    $0x1,%esi
  802395:	3b 75 10             	cmp    0x10(%ebp),%esi
  802398:	74 0d                	je     8023a7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80239a:	8b 03                	mov    (%ebx),%eax
  80239c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80239f:	75 d4                	jne    802375 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023a1:	85 f6                	test   %esi,%esi
  8023a3:	75 b0                	jne    802355 <devpipe_read+0x29>
  8023a5:	eb b2                	jmp    802359 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023a7:	89 f0                	mov    %esi,%eax
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	eb 05                	jmp    8023b7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023b2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8023ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8023bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8023c0:	89 ec                	mov    %ebp,%esp
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    

008023c4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 48             	sub    $0x48,%esp
  8023ca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8023cd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8023d0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8023d3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023d9:	89 04 24             	mov    %eax,(%esp)
  8023dc:	e8 8a f5 ff ff       	call   80196b <fd_alloc>
  8023e1:	89 c3                	mov    %eax,%ebx
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	0f 88 45 01 00 00    	js     802530 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023eb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023f2:	00 
  8023f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802401:	e8 26 f1 ff ff       	call   80152c <sys_page_alloc>
  802406:	89 c3                	mov    %eax,%ebx
  802408:	85 c0                	test   %eax,%eax
  80240a:	0f 88 20 01 00 00    	js     802530 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802410:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802413:	89 04 24             	mov    %eax,(%esp)
  802416:	e8 50 f5 ff ff       	call   80196b <fd_alloc>
  80241b:	89 c3                	mov    %eax,%ebx
  80241d:	85 c0                	test   %eax,%eax
  80241f:	0f 88 f8 00 00 00    	js     80251d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802425:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80242c:	00 
  80242d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802430:	89 44 24 04          	mov    %eax,0x4(%esp)
  802434:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80243b:	e8 ec f0 ff ff       	call   80152c <sys_page_alloc>
  802440:	89 c3                	mov    %eax,%ebx
  802442:	85 c0                	test   %eax,%eax
  802444:	0f 88 d3 00 00 00    	js     80251d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80244a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80244d:	89 04 24             	mov    %eax,(%esp)
  802450:	e8 fb f4 ff ff       	call   801950 <fd2data>
  802455:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802457:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80245e:	00 
  80245f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802463:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80246a:	e8 bd f0 ff ff       	call   80152c <sys_page_alloc>
  80246f:	89 c3                	mov    %eax,%ebx
  802471:	85 c0                	test   %eax,%eax
  802473:	0f 88 91 00 00 00    	js     80250a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802479:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80247c:	89 04 24             	mov    %eax,(%esp)
  80247f:	e8 cc f4 ff ff       	call   801950 <fd2data>
  802484:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80248b:	00 
  80248c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802490:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802497:	00 
  802498:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a3:	e8 e3 f0 ff ff       	call   80158b <sys_page_map>
  8024a8:	89 c3                	mov    %eax,%ebx
  8024aa:	85 c0                	test   %eax,%eax
  8024ac:	78 4c                	js     8024fa <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024ae:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8024b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024b7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024c3:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8024c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024cc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024db:	89 04 24             	mov    %eax,(%esp)
  8024de:	e8 5d f4 ff ff       	call   801940 <fd2num>
  8024e3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8024e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024e8:	89 04 24             	mov    %eax,(%esp)
  8024eb:	e8 50 f4 ff ff       	call   801940 <fd2num>
  8024f0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8024f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024f8:	eb 36                	jmp    802530 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8024fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802505:	e8 df f0 ff ff       	call   8015e9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80250a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80250d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802511:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802518:	e8 cc f0 ff ff       	call   8015e9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80251d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802520:	89 44 24 04          	mov    %eax,0x4(%esp)
  802524:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80252b:	e8 b9 f0 ff ff       	call   8015e9 <sys_page_unmap>
    err:
	return r;
}
  802530:	89 d8                	mov    %ebx,%eax
  802532:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802535:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802538:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80253b:	89 ec                	mov    %ebp,%esp
  80253d:	5d                   	pop    %ebp
  80253e:	c3                   	ret    

0080253f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80253f:	55                   	push   %ebp
  802540:	89 e5                	mov    %esp,%ebp
  802542:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254c:	8b 45 08             	mov    0x8(%ebp),%eax
  80254f:	89 04 24             	mov    %eax,(%esp)
  802552:	e8 87 f4 ff ff       	call   8019de <fd_lookup>
  802557:	85 c0                	test   %eax,%eax
  802559:	78 15                	js     802570 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80255b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255e:	89 04 24             	mov    %eax,(%esp)
  802561:	e8 ea f3 ff ff       	call   801950 <fd2data>
	return _pipeisclosed(fd, p);
  802566:	89 c2                	mov    %eax,%edx
  802568:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256b:	e8 c2 fc ff ff       	call   802232 <_pipeisclosed>
}
  802570:	c9                   	leave  
  802571:	c3                   	ret    
	...

00802580 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802583:	b8 00 00 00 00       	mov    $0x0,%eax
  802588:	5d                   	pop    %ebp
  802589:	c3                   	ret    

0080258a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80258a:	55                   	push   %ebp
  80258b:	89 e5                	mov    %esp,%ebp
  80258d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802590:	c7 44 24 04 4e 32 80 	movl   $0x80324e,0x4(%esp)
  802597:	00 
  802598:	8b 45 0c             	mov    0xc(%ebp),%eax
  80259b:	89 04 24             	mov    %eax,(%esp)
  80259e:	e8 88 ea ff ff       	call   80102b <strcpy>
	return 0;
}
  8025a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8025a8:	c9                   	leave  
  8025a9:	c3                   	ret    

008025aa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025aa:	55                   	push   %ebp
  8025ab:	89 e5                	mov    %esp,%ebp
  8025ad:	57                   	push   %edi
  8025ae:	56                   	push   %esi
  8025af:	53                   	push   %ebx
  8025b0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025b6:	be 00 00 00 00       	mov    $0x0,%esi
  8025bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025bf:	74 43                	je     802604 <devcons_write+0x5a>
  8025c1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025c6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025cf:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8025d1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025d4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8025d9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025e0:	03 45 0c             	add    0xc(%ebp),%eax
  8025e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e7:	89 3c 24             	mov    %edi,(%esp)
  8025ea:	e8 2d ec ff ff       	call   80121c <memmove>
		sys_cputs(buf, m);
  8025ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8025f3:	89 3c 24             	mov    %edi,(%esp)
  8025f6:	e8 15 ee ff ff       	call   801410 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025fb:	01 de                	add    %ebx,%esi
  8025fd:	89 f0                	mov    %esi,%eax
  8025ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  802602:	72 c8                	jb     8025cc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802604:	89 f0                	mov    %esi,%eax
  802606:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    

00802611 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802611:	55                   	push   %ebp
  802612:	89 e5                	mov    %esp,%ebp
  802614:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802617:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80261c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802620:	75 07                	jne    802629 <devcons_read+0x18>
  802622:	eb 31                	jmp    802655 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802624:	e8 d3 ee ff ff       	call   8014fc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	e8 0a ee ff ff       	call   80143f <sys_cgetc>
  802635:	85 c0                	test   %eax,%eax
  802637:	74 eb                	je     802624 <devcons_read+0x13>
  802639:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80263b:	85 c0                	test   %eax,%eax
  80263d:	78 16                	js     802655 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80263f:	83 f8 04             	cmp    $0x4,%eax
  802642:	74 0c                	je     802650 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802644:	8b 45 0c             	mov    0xc(%ebp),%eax
  802647:	88 10                	mov    %dl,(%eax)
	return 1;
  802649:	b8 01 00 00 00       	mov    $0x1,%eax
  80264e:	eb 05                	jmp    802655 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802650:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802655:	c9                   	leave  
  802656:	c3                   	ret    

00802657 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802657:	55                   	push   %ebp
  802658:	89 e5                	mov    %esp,%ebp
  80265a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80265d:	8b 45 08             	mov    0x8(%ebp),%eax
  802660:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802663:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80266a:	00 
  80266b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80266e:	89 04 24             	mov    %eax,(%esp)
  802671:	e8 9a ed ff ff       	call   801410 <sys_cputs>
}
  802676:	c9                   	leave  
  802677:	c3                   	ret    

00802678 <getchar>:

int
getchar(void)
{
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80267e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802685:	00 
  802686:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80268d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802694:	e8 05 f6 ff ff       	call   801c9e <read>
	if (r < 0)
  802699:	85 c0                	test   %eax,%eax
  80269b:	78 0f                	js     8026ac <getchar+0x34>
		return r;
	if (r < 1)
  80269d:	85 c0                	test   %eax,%eax
  80269f:	7e 06                	jle    8026a7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8026a1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026a5:	eb 05                	jmp    8026ac <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026a7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026ac:	c9                   	leave  
  8026ad:	c3                   	ret    

008026ae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026ae:	55                   	push   %ebp
  8026af:	89 e5                	mov    %esp,%ebp
  8026b1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026be:	89 04 24             	mov    %eax,(%esp)
  8026c1:	e8 18 f3 ff ff       	call   8019de <fd_lookup>
  8026c6:	85 c0                	test   %eax,%eax
  8026c8:	78 11                	js     8026db <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026cd:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026d3:	39 10                	cmp    %edx,(%eax)
  8026d5:	0f 94 c0             	sete   %al
  8026d8:	0f b6 c0             	movzbl %al,%eax
}
  8026db:	c9                   	leave  
  8026dc:	c3                   	ret    

008026dd <opencons>:

int
opencons(void)
{
  8026dd:	55                   	push   %ebp
  8026de:	89 e5                	mov    %esp,%ebp
  8026e0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026e6:	89 04 24             	mov    %eax,(%esp)
  8026e9:	e8 7d f2 ff ff       	call   80196b <fd_alloc>
  8026ee:	85 c0                	test   %eax,%eax
  8026f0:	78 3c                	js     80272e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026f9:	00 
  8026fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802701:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802708:	e8 1f ee ff ff       	call   80152c <sys_page_alloc>
  80270d:	85 c0                	test   %eax,%eax
  80270f:	78 1d                	js     80272e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802711:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80271c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802726:	89 04 24             	mov    %eax,(%esp)
  802729:	e8 12 f2 ff ff       	call   801940 <fd2num>
}
  80272e:	c9                   	leave  
  80272f:	c3                   	ret    

00802730 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802736:	89 d0                	mov    %edx,%eax
  802738:	c1 e8 16             	shr    $0x16,%eax
  80273b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802742:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802747:	f6 c1 01             	test   $0x1,%cl
  80274a:	74 1d                	je     802769 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80274c:	c1 ea 0c             	shr    $0xc,%edx
  80274f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802756:	f6 c2 01             	test   $0x1,%dl
  802759:	74 0e                	je     802769 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80275b:	c1 ea 0c             	shr    $0xc,%edx
  80275e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802765:	ef 
  802766:	0f b7 c0             	movzwl %ax,%eax
}
  802769:	5d                   	pop    %ebp
  80276a:	c3                   	ret    
  80276b:	00 00                	add    %al,(%eax)
  80276d:	00 00                	add    %al,(%eax)
	...

00802770 <__udivdi3>:
  802770:	83 ec 1c             	sub    $0x1c,%esp
  802773:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802777:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80277b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80277f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802783:	89 74 24 10          	mov    %esi,0x10(%esp)
  802787:	8b 74 24 24          	mov    0x24(%esp),%esi
  80278b:	85 ff                	test   %edi,%edi
  80278d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802791:	89 44 24 08          	mov    %eax,0x8(%esp)
  802795:	89 cd                	mov    %ecx,%ebp
  802797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80279b:	75 33                	jne    8027d0 <__udivdi3+0x60>
  80279d:	39 f1                	cmp    %esi,%ecx
  80279f:	77 57                	ja     8027f8 <__udivdi3+0x88>
  8027a1:	85 c9                	test   %ecx,%ecx
  8027a3:	75 0b                	jne    8027b0 <__udivdi3+0x40>
  8027a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8027aa:	31 d2                	xor    %edx,%edx
  8027ac:	f7 f1                	div    %ecx
  8027ae:	89 c1                	mov    %eax,%ecx
  8027b0:	89 f0                	mov    %esi,%eax
  8027b2:	31 d2                	xor    %edx,%edx
  8027b4:	f7 f1                	div    %ecx
  8027b6:	89 c6                	mov    %eax,%esi
  8027b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027bc:	f7 f1                	div    %ecx
  8027be:	89 f2                	mov    %esi,%edx
  8027c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027cc:	83 c4 1c             	add    $0x1c,%esp
  8027cf:	c3                   	ret    
  8027d0:	31 d2                	xor    %edx,%edx
  8027d2:	31 c0                	xor    %eax,%eax
  8027d4:	39 f7                	cmp    %esi,%edi
  8027d6:	77 e8                	ja     8027c0 <__udivdi3+0x50>
  8027d8:	0f bd cf             	bsr    %edi,%ecx
  8027db:	83 f1 1f             	xor    $0x1f,%ecx
  8027de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027e2:	75 2c                	jne    802810 <__udivdi3+0xa0>
  8027e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8027e8:	76 04                	jbe    8027ee <__udivdi3+0x7e>
  8027ea:	39 f7                	cmp    %esi,%edi
  8027ec:	73 d2                	jae    8027c0 <__udivdi3+0x50>
  8027ee:	31 d2                	xor    %edx,%edx
  8027f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027f5:	eb c9                	jmp    8027c0 <__udivdi3+0x50>
  8027f7:	90                   	nop
  8027f8:	89 f2                	mov    %esi,%edx
  8027fa:	f7 f1                	div    %ecx
  8027fc:	31 d2                	xor    %edx,%edx
  8027fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  802802:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802806:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80280a:	83 c4 1c             	add    $0x1c,%esp
  80280d:	c3                   	ret    
  80280e:	66 90                	xchg   %ax,%ax
  802810:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802815:	b8 20 00 00 00       	mov    $0x20,%eax
  80281a:	89 ea                	mov    %ebp,%edx
  80281c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802820:	d3 e7                	shl    %cl,%edi
  802822:	89 c1                	mov    %eax,%ecx
  802824:	d3 ea                	shr    %cl,%edx
  802826:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80282b:	09 fa                	or     %edi,%edx
  80282d:	89 f7                	mov    %esi,%edi
  80282f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802833:	89 f2                	mov    %esi,%edx
  802835:	8b 74 24 08          	mov    0x8(%esp),%esi
  802839:	d3 e5                	shl    %cl,%ebp
  80283b:	89 c1                	mov    %eax,%ecx
  80283d:	d3 ef                	shr    %cl,%edi
  80283f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802844:	d3 e2                	shl    %cl,%edx
  802846:	89 c1                	mov    %eax,%ecx
  802848:	d3 ee                	shr    %cl,%esi
  80284a:	09 d6                	or     %edx,%esi
  80284c:	89 fa                	mov    %edi,%edx
  80284e:	89 f0                	mov    %esi,%eax
  802850:	f7 74 24 0c          	divl   0xc(%esp)
  802854:	89 d7                	mov    %edx,%edi
  802856:	89 c6                	mov    %eax,%esi
  802858:	f7 e5                	mul    %ebp
  80285a:	39 d7                	cmp    %edx,%edi
  80285c:	72 22                	jb     802880 <__udivdi3+0x110>
  80285e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802862:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802867:	d3 e5                	shl    %cl,%ebp
  802869:	39 c5                	cmp    %eax,%ebp
  80286b:	73 04                	jae    802871 <__udivdi3+0x101>
  80286d:	39 d7                	cmp    %edx,%edi
  80286f:	74 0f                	je     802880 <__udivdi3+0x110>
  802871:	89 f0                	mov    %esi,%eax
  802873:	31 d2                	xor    %edx,%edx
  802875:	e9 46 ff ff ff       	jmp    8027c0 <__udivdi3+0x50>
  80287a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802880:	8d 46 ff             	lea    -0x1(%esi),%eax
  802883:	31 d2                	xor    %edx,%edx
  802885:	8b 74 24 10          	mov    0x10(%esp),%esi
  802889:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80288d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802891:	83 c4 1c             	add    $0x1c,%esp
  802894:	c3                   	ret    
	...

008028a0 <__umoddi3>:
  8028a0:	83 ec 1c             	sub    $0x1c,%esp
  8028a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8028a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8028ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8028af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8028b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8028b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8028bb:	85 ed                	test   %ebp,%ebp
  8028bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8028c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028c5:	89 cf                	mov    %ecx,%edi
  8028c7:	89 04 24             	mov    %eax,(%esp)
  8028ca:	89 f2                	mov    %esi,%edx
  8028cc:	75 1a                	jne    8028e8 <__umoddi3+0x48>
  8028ce:	39 f1                	cmp    %esi,%ecx
  8028d0:	76 4e                	jbe    802920 <__umoddi3+0x80>
  8028d2:	f7 f1                	div    %ecx
  8028d4:	89 d0                	mov    %edx,%eax
  8028d6:	31 d2                	xor    %edx,%edx
  8028d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028e4:	83 c4 1c             	add    $0x1c,%esp
  8028e7:	c3                   	ret    
  8028e8:	39 f5                	cmp    %esi,%ebp
  8028ea:	77 54                	ja     802940 <__umoddi3+0xa0>
  8028ec:	0f bd c5             	bsr    %ebp,%eax
  8028ef:	83 f0 1f             	xor    $0x1f,%eax
  8028f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028f6:	75 60                	jne    802958 <__umoddi3+0xb8>
  8028f8:	3b 0c 24             	cmp    (%esp),%ecx
  8028fb:	0f 87 07 01 00 00    	ja     802a08 <__umoddi3+0x168>
  802901:	89 f2                	mov    %esi,%edx
  802903:	8b 34 24             	mov    (%esp),%esi
  802906:	29 ce                	sub    %ecx,%esi
  802908:	19 ea                	sbb    %ebp,%edx
  80290a:	89 34 24             	mov    %esi,(%esp)
  80290d:	8b 04 24             	mov    (%esp),%eax
  802910:	8b 74 24 10          	mov    0x10(%esp),%esi
  802914:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802918:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80291c:	83 c4 1c             	add    $0x1c,%esp
  80291f:	c3                   	ret    
  802920:	85 c9                	test   %ecx,%ecx
  802922:	75 0b                	jne    80292f <__umoddi3+0x8f>
  802924:	b8 01 00 00 00       	mov    $0x1,%eax
  802929:	31 d2                	xor    %edx,%edx
  80292b:	f7 f1                	div    %ecx
  80292d:	89 c1                	mov    %eax,%ecx
  80292f:	89 f0                	mov    %esi,%eax
  802931:	31 d2                	xor    %edx,%edx
  802933:	f7 f1                	div    %ecx
  802935:	8b 04 24             	mov    (%esp),%eax
  802938:	f7 f1                	div    %ecx
  80293a:	eb 98                	jmp    8028d4 <__umoddi3+0x34>
  80293c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802940:	89 f2                	mov    %esi,%edx
  802942:	8b 74 24 10          	mov    0x10(%esp),%esi
  802946:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80294a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80294e:	83 c4 1c             	add    $0x1c,%esp
  802951:	c3                   	ret    
  802952:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802958:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80295d:	89 e8                	mov    %ebp,%eax
  80295f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802964:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802968:	89 fa                	mov    %edi,%edx
  80296a:	d3 e0                	shl    %cl,%eax
  80296c:	89 e9                	mov    %ebp,%ecx
  80296e:	d3 ea                	shr    %cl,%edx
  802970:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802975:	09 c2                	or     %eax,%edx
  802977:	8b 44 24 08          	mov    0x8(%esp),%eax
  80297b:	89 14 24             	mov    %edx,(%esp)
  80297e:	89 f2                	mov    %esi,%edx
  802980:	d3 e7                	shl    %cl,%edi
  802982:	89 e9                	mov    %ebp,%ecx
  802984:	d3 ea                	shr    %cl,%edx
  802986:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80298b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80298f:	d3 e6                	shl    %cl,%esi
  802991:	89 e9                	mov    %ebp,%ecx
  802993:	d3 e8                	shr    %cl,%eax
  802995:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80299a:	09 f0                	or     %esi,%eax
  80299c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8029a0:	f7 34 24             	divl   (%esp)
  8029a3:	d3 e6                	shl    %cl,%esi
  8029a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8029a9:	89 d6                	mov    %edx,%esi
  8029ab:	f7 e7                	mul    %edi
  8029ad:	39 d6                	cmp    %edx,%esi
  8029af:	89 c1                	mov    %eax,%ecx
  8029b1:	89 d7                	mov    %edx,%edi
  8029b3:	72 3f                	jb     8029f4 <__umoddi3+0x154>
  8029b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029b9:	72 35                	jb     8029f0 <__umoddi3+0x150>
  8029bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029bf:	29 c8                	sub    %ecx,%eax
  8029c1:	19 fe                	sbb    %edi,%esi
  8029c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029c8:	89 f2                	mov    %esi,%edx
  8029ca:	d3 e8                	shr    %cl,%eax
  8029cc:	89 e9                	mov    %ebp,%ecx
  8029ce:	d3 e2                	shl    %cl,%edx
  8029d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029d5:	09 d0                	or     %edx,%eax
  8029d7:	89 f2                	mov    %esi,%edx
  8029d9:	d3 ea                	shr    %cl,%edx
  8029db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8029df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8029e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8029e7:	83 c4 1c             	add    $0x1c,%esp
  8029ea:	c3                   	ret    
  8029eb:	90                   	nop
  8029ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029f0:	39 d6                	cmp    %edx,%esi
  8029f2:	75 c7                	jne    8029bb <__umoddi3+0x11b>
  8029f4:	89 d7                	mov    %edx,%edi
  8029f6:	89 c1                	mov    %eax,%ecx
  8029f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8029fc:	1b 3c 24             	sbb    (%esp),%edi
  8029ff:	eb ba                	jmp    8029bb <__umoddi3+0x11b>
  802a01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a08:	39 f5                	cmp    %esi,%ebp
  802a0a:	0f 82 f1 fe ff ff    	jb     802901 <__umoddi3+0x61>
  802a10:	e9 f8 fe ff ff       	jmp    80290d <__umoddi3+0x6d>
