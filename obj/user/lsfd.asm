
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 0f 01 00 00       	call   800140 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: lsfd [-1]\n");
  800046:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  80004d:	e8 fd 01 00 00       	call   80024f <cprintf>
	exit();
  800052:	e8 39 01 00 00       	call   800190 <exit>
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <umain>:

void
umain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	57                   	push   %edi
  80005d:	56                   	push   %esi
  80005e:	53                   	push   %ebx
  80005f:	81 ec cc 00 00 00    	sub    $0xcc,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800065:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80006b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	8d 45 08             	lea    0x8(%ebp),%eax
  800079:	89 04 24             	mov    %eax,(%esp)
  80007c:	e8 13 11 00 00       	call   801194 <argstart>
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  800081:	bf 00 00 00 00       	mov    $0x0,%edi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800086:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80008c:	eb 11                	jmp    80009f <umain+0x46>
		if (i == '1')
  80008e:	83 f8 31             	cmp    $0x31,%eax
  800091:	74 07                	je     80009a <umain+0x41>
			usefprint = 1;
		else
			usage();
  800093:	e8 a8 ff ff ff       	call   800040 <usage>
  800098:	eb 05                	jmp    80009f <umain+0x46>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  80009a:	bf 01 00 00 00       	mov    $0x1,%edi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80009f:	89 1c 24             	mov    %ebx,(%esp)
  8000a2:	e8 1d 11 00 00       	call   8011c4 <argnext>
  8000a7:	85 c0                	test   %eax,%eax
  8000a9:	79 e3                	jns    80008e <umain+0x35>
  8000ab:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000b0:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	e8 a7 17 00 00       	call   801869 <fstat>
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	78 66                	js     80012c <umain+0xd3>
			if (usefprint)
  8000c6:	85 ff                	test   %edi,%edi
  8000c8:	74 36                	je     800100 <umain+0xa7>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  8000ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000cd:	8b 40 04             	mov    0x4(%eax),%eax
  8000d0:	89 44 24 18          	mov    %eax,0x18(%esp)
  8000d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000d7:	89 44 24 14          	mov    %eax,0x14(%esp)
  8000db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000de:	89 44 24 10          	mov    %eax,0x10(%esp)
					i, st.st_name, st.st_isdir,
  8000e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000ea:	c7 44 24 04 94 26 80 	movl   $0x802694,0x4(%esp)
  8000f1:	00 
  8000f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000f9:	e8 3a 1b 00 00       	call   801c38 <fprintf>
  8000fe:	eb 2c                	jmp    80012c <umain+0xd3>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
  800100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  800103:	8b 40 04             	mov    0x4(%eax),%eax
  800106:	89 44 24 14          	mov    %eax,0x14(%esp)
  80010a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80010d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800111:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
					i, st.st_name, st.st_isdir,
  800118:	89 74 24 08          	mov    %esi,0x8(%esp)
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  80011c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800120:	c7 04 24 94 26 80 00 	movl   $0x802694,(%esp)
  800127:	e8 23 01 00 00       	call   80024f <cprintf>
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  80012c:	83 c3 01             	add    $0x1,%ebx
  80012f:	83 fb 20             	cmp    $0x20,%ebx
  800132:	75 82                	jne    8000b6 <umain+0x5d>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800134:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    
	...

00800140 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
  800146:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800149:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80014c:	8b 75 08             	mov    0x8(%ebp),%esi
  80014f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800152:	e8 e5 0c 00 00       	call   800e3c <sys_getenvid>
  800157:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015c:	c1 e0 07             	shl    $0x7,%eax
  80015f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800164:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800169:	85 f6                	test   %esi,%esi
  80016b:	7e 07                	jle    800174 <libmain+0x34>
		binaryname = argv[0];
  80016d:	8b 03                	mov    (%ebx),%eax
  80016f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 d9 fe ff ff       	call   800059 <umain>

	// exit gracefully
	exit();
  800180:	e8 0b 00 00 00       	call   800190 <exit>
}
  800185:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800188:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80018b:	89 ec                	mov    %ebp,%esp
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    
	...

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800196:	e8 73 13 00 00       	call   80150e <close_all>
	sys_env_destroy(0);
  80019b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a2:	e8 38 0c 00 00       	call   800ddf <sys_env_destroy>
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    
  8001a9:	00 00                	add    %al,(%eax)
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	83 c0 01             	add    $0x1,%eax
  8001c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c9:	75 19                	jne    8001e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d2:	00 
  8001d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 a2 0b 00 00       	call   800d80 <sys_cputs>
		b->idx = 0;
  8001de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fe:	00 00 00 
	b.cnt = 0;
  800201:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800208:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  80022a:	e8 97 01 00 00       	call   8003c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800235:	89 44 24 04          	mov    %eax,0x4(%esp)
  800239:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 39 0b 00 00       	call   800d80 <sys_cputs>

	return b.cnt;
}
  800247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800255:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 87 ff ff ff       	call   8001ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    
  800269:	00 00                	add    %al,(%eax)
	...

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d7                	mov    %edx,%edi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800289:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	b8 00 00 00 00       	mov    $0x0,%eax
  800291:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800294:	72 11                	jb     8002a7 <printnum+0x3b>
  800296:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800299:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029c:	76 09                	jbe    8002a7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029e:	83 eb 01             	sub    $0x1,%ebx
  8002a1:	85 db                	test   %ebx,%ebx
  8002a3:	7f 51                	jg     8002f6 <printnum+0x8a>
  8002a5:	eb 5e                	jmp    800305 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ab:	83 eb 01             	sub    $0x1,%ebx
  8002ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002bd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c8:	00 
  8002c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d6:	e8 e5 20 00 00       	call   8023c0 <__udivdi3>
  8002db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002df:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ea:	89 fa                	mov    %edi,%edx
  8002ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ef:	e8 78 ff ff ff       	call   80026c <printnum>
  8002f4:	eb 0f                	jmp    800305 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fa:	89 34 24             	mov    %esi,(%esp)
  8002fd:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800300:	83 eb 01             	sub    $0x1,%ebx
  800303:	75 f1                	jne    8002f6 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	89 44 24 08          	mov    %eax,0x8(%esp)
  800314:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031b:	00 
  80031c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	e8 c2 21 00 00       	call   8024f0 <__umoddi3>
  80032e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800332:	0f be 80 c6 26 80 00 	movsbl 0x8026c6(%eax),%eax
  800339:	89 04 24             	mov    %eax,(%esp)
  80033c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033f:	83 c4 3c             	add    $0x3c,%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034a:	83 fa 01             	cmp    $0x1,%edx
  80034d:	7e 0e                	jle    80035d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 08             	lea    0x8(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	8b 52 04             	mov    0x4(%edx),%edx
  80035b:	eb 22                	jmp    80037f <getuint+0x38>
	else if (lflag)
  80035d:	85 d2                	test   %edx,%edx
  80035f:	74 10                	je     800371 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800361:	8b 10                	mov    (%eax),%edx
  800363:	8d 4a 04             	lea    0x4(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 02                	mov    (%edx),%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	eb 0e                	jmp    80037f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800395:	88 0a                	mov    %cl,(%edx)
  800397:	83 c2 01             	add    $0x1,%edx
  80039a:	89 10                	mov    %edx,(%eax)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 02 00 00 00       	call   8003c6 <vprintfmt>
	va_end(ap);
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	57                   	push   %edi
  8003ca:	56                   	push   %esi
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 5c             	sub    $0x5c,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 e4 04 00 00    	je     8008c3 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8003df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e3:	89 04 24             	mov    %eax,(%esp)
  8003e6:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	83 c6 01             	add    $0x1,%esi
  8003ef:	83 f8 25             	cmp    $0x25,%eax
  8003f2:	75 e3                	jne    8003d7 <vprintfmt+0x11>
  8003f4:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003f8:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003ff:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800404:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800410:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800413:	eb 2b                	jmp    800440 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80041c:	eb 22                	jmp    800440 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800425:	eb 19                	jmp    800440 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80042a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800431:	eb 0d                	jmp    800440 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800433:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800436:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800439:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	0f b6 06             	movzbl (%esi),%eax
  800443:	0f b6 d0             	movzbl %al,%edx
  800446:	8d 7e 01             	lea    0x1(%esi),%edi
  800449:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044c:	83 e8 23             	sub    $0x23,%eax
  80044f:	3c 55                	cmp    $0x55,%al
  800451:	0f 87 46 04 00 00    	ja     80089d <vprintfmt+0x4d7>
  800457:	0f b6 c0             	movzbl %al,%eax
  80045a:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800461:	83 ea 30             	sub    $0x30,%edx
  800464:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800467:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80046b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800471:	83 fa 09             	cmp    $0x9,%edx
  800474:	77 4a                	ja     8004c0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800479:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80047c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80047f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800483:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800486:	8d 50 d0             	lea    -0x30(%eax),%edx
  800489:	83 fa 09             	cmp    $0x9,%edx
  80048c:	76 eb                	jbe    800479 <vprintfmt+0xb3>
  80048e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800491:	eb 2d                	jmp    8004c0 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 00                	mov    (%eax),%eax
  80049e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a4:	eb 1a                	jmp    8004c0 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004a9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004ad:	79 91                	jns    800440 <vprintfmt+0x7a>
  8004af:	e9 73 ff ff ff       	jmp    800427 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8004be:	eb 80                	jmp    800440 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004c0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004c4:	0f 89 76 ff ff ff    	jns    800440 <vprintfmt+0x7a>
  8004ca:	e9 64 ff ff ff       	jmp    800433 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004cf:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004d5:	e9 66 ff ff ff       	jmp    800440 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f2:	e9 f2 fe ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004f7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004fb:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004fe:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800502:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800505:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800509:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80050c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80050f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800513:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800516:	80 f9 09             	cmp    $0x9,%cl
  800519:	77 1d                	ja     800538 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80051b:	0f be c0             	movsbl %al,%eax
  80051e:	6b c0 64             	imul   $0x64,%eax,%eax
  800521:	0f be d2             	movsbl %dl,%edx
  800524:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800527:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80052e:	a3 04 30 80 00       	mov    %eax,0x803004
  800533:	e9 b1 fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800538:	c7 44 24 04 de 26 80 	movl   $0x8026de,0x4(%esp)
  80053f:	00 
  800540:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	e8 10 05 00 00       	call   800a5b <strcmp>
  80054b:	85 c0                	test   %eax,%eax
  80054d:	75 0f                	jne    80055e <vprintfmt+0x198>
  80054f:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800556:	00 00 00 
  800559:	e9 8b fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80055e:	c7 44 24 04 e2 26 80 	movl   $0x8026e2,0x4(%esp)
  800565:	00 
  800566:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800569:	89 14 24             	mov    %edx,(%esp)
  80056c:	e8 ea 04 00 00       	call   800a5b <strcmp>
  800571:	85 c0                	test   %eax,%eax
  800573:	75 0f                	jne    800584 <vprintfmt+0x1be>
  800575:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  80057c:	00 00 00 
  80057f:	e9 65 fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800584:	c7 44 24 04 e6 26 80 	movl   $0x8026e6,0x4(%esp)
  80058b:	00 
  80058c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80058f:	89 0c 24             	mov    %ecx,(%esp)
  800592:	e8 c4 04 00 00       	call   800a5b <strcmp>
  800597:	85 c0                	test   %eax,%eax
  800599:	75 0f                	jne    8005aa <vprintfmt+0x1e4>
  80059b:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8005a2:	00 00 00 
  8005a5:	e9 3f fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005aa:	c7 44 24 04 ea 26 80 	movl   $0x8026ea,0x4(%esp)
  8005b1:	00 
  8005b2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8005b5:	89 3c 24             	mov    %edi,(%esp)
  8005b8:	e8 9e 04 00 00       	call   800a5b <strcmp>
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	75 0f                	jne    8005d0 <vprintfmt+0x20a>
  8005c1:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  8005c8:	00 00 00 
  8005cb:	e9 19 fe ff ff       	jmp    8003e9 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8005d0:	c7 44 24 04 ee 26 80 	movl   $0x8026ee,0x4(%esp)
  8005d7:	00 
  8005d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	e8 78 04 00 00       	call   800a5b <strcmp>
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	75 0f                	jne    8005f6 <vprintfmt+0x230>
  8005e7:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  8005ee:	00 00 00 
  8005f1:	e9 f3 fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005f6:	c7 44 24 04 f2 26 80 	movl   $0x8026f2,0x4(%esp)
  8005fd:	00 
  8005fe:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800601:	89 14 24             	mov    %edx,(%esp)
  800604:	e8 52 04 00 00       	call   800a5b <strcmp>
  800609:	83 f8 01             	cmp    $0x1,%eax
  80060c:	19 c0                	sbb    %eax,%eax
  80060e:	f7 d0                	not    %eax
  800610:	83 c0 08             	add    $0x8,%eax
  800613:	a3 04 30 80 00       	mov    %eax,0x803004
  800618:	e9 cc fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	89 c2                	mov    %eax,%edx
  80062a:	c1 fa 1f             	sar    $0x1f,%edx
  80062d:	31 d0                	xor    %edx,%eax
  80062f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800631:	83 f8 0f             	cmp    $0xf,%eax
  800634:	7f 0b                	jg     800641 <vprintfmt+0x27b>
  800636:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  80063d:	85 d2                	test   %edx,%edx
  80063f:	75 23                	jne    800664 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800641:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800645:	c7 44 24 08 f6 26 80 	movl   $0x8026f6,0x8(%esp)
  80064c:	00 
  80064d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800651:	8b 7d 08             	mov    0x8(%ebp),%edi
  800654:	89 3c 24             	mov    %edi,(%esp)
  800657:	e8 42 fd ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80065f:	e9 85 fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800664:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800668:	c7 44 24 08 b1 2a 80 	movl   $0x802ab1,0x8(%esp)
  80066f:	00 
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	8b 7d 08             	mov    0x8(%ebp),%edi
  800677:	89 3c 24             	mov    %edi,(%esp)
  80067a:	e8 1f fd ff ff       	call   80039e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800682:	e9 62 fd ff ff       	jmp    8003e9 <vprintfmt+0x23>
  800687:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80068a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80068d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80069b:	85 f6                	test   %esi,%esi
  80069d:	b8 d7 26 80 00       	mov    $0x8026d7,%eax
  8006a2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006a5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006a9:	7e 06                	jle    8006b1 <vprintfmt+0x2eb>
  8006ab:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006af:	75 13                	jne    8006c4 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b1:	0f be 06             	movsbl (%esi),%eax
  8006b4:	83 c6 01             	add    $0x1,%esi
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	0f 85 94 00 00 00    	jne    800753 <vprintfmt+0x38d>
  8006bf:	e9 81 00 00 00       	jmp    800745 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c8:	89 34 24             	mov    %esi,(%esp)
  8006cb:	e8 9b 02 00 00       	call   80096b <strnlen>
  8006d0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006d3:	29 c2                	sub    %eax,%edx
  8006d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	7e d5                	jle    8006b1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8006dc:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8006e0:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8006e3:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006e6:	89 d6                	mov    %edx,%esi
  8006e8:	89 cf                	mov    %ecx,%edi
  8006ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ee:	89 3c 24             	mov    %edi,(%esp)
  8006f1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f4:	83 ee 01             	sub    $0x1,%esi
  8006f7:	75 f1                	jne    8006ea <vprintfmt+0x324>
  8006f9:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006fc:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006ff:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800702:	eb ad                	jmp    8006b1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800704:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800708:	74 1b                	je     800725 <vprintfmt+0x35f>
  80070a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80070d:	83 fa 5e             	cmp    $0x5e,%edx
  800710:	76 13                	jbe    800725 <vprintfmt+0x35f>
					putch('?', putdat);
  800712:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800715:	89 44 24 04          	mov    %eax,0x4(%esp)
  800719:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800720:	ff 55 08             	call   *0x8(%ebp)
  800723:	eb 0d                	jmp    800732 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800725:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800728:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800732:	83 eb 01             	sub    $0x1,%ebx
  800735:	0f be 06             	movsbl (%esi),%eax
  800738:	83 c6 01             	add    $0x1,%esi
  80073b:	85 c0                	test   %eax,%eax
  80073d:	75 1a                	jne    800759 <vprintfmt+0x393>
  80073f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800742:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800748:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80074c:	7f 1c                	jg     80076a <vprintfmt+0x3a4>
  80074e:	e9 96 fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
  800753:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800756:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800759:	85 ff                	test   %edi,%edi
  80075b:	78 a7                	js     800704 <vprintfmt+0x33e>
  80075d:	83 ef 01             	sub    $0x1,%edi
  800760:	79 a2                	jns    800704 <vprintfmt+0x33e>
  800762:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800765:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800768:	eb db                	jmp    800745 <vprintfmt+0x37f>
  80076a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076d:	89 de                	mov    %ebx,%esi
  80076f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800772:	89 74 24 04          	mov    %esi,0x4(%esp)
  800776:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80077d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077f:	83 eb 01             	sub    $0x1,%ebx
  800782:	75 ee                	jne    800772 <vprintfmt+0x3ac>
  800784:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800789:	e9 5b fc ff ff       	jmp    8003e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80078e:	83 f9 01             	cmp    $0x1,%ecx
  800791:	7e 10                	jle    8007a3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 50 08             	lea    0x8(%eax),%edx
  800799:	89 55 14             	mov    %edx,0x14(%ebp)
  80079c:	8b 30                	mov    (%eax),%esi
  80079e:	8b 78 04             	mov    0x4(%eax),%edi
  8007a1:	eb 26                	jmp    8007c9 <vprintfmt+0x403>
	else if (lflag)
  8007a3:	85 c9                	test   %ecx,%ecx
  8007a5:	74 12                	je     8007b9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 50 04             	lea    0x4(%eax),%edx
  8007ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b0:	8b 30                	mov    (%eax),%esi
  8007b2:	89 f7                	mov    %esi,%edi
  8007b4:	c1 ff 1f             	sar    $0x1f,%edi
  8007b7:	eb 10                	jmp    8007c9 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 50 04             	lea    0x4(%eax),%edx
  8007bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c2:	8b 30                	mov    (%eax),%esi
  8007c4:	89 f7                	mov    %esi,%edi
  8007c6:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007c9:	85 ff                	test   %edi,%edi
  8007cb:	78 0e                	js     8007db <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007d1:	be 0a 00 00 00       	mov    $0xa,%esi
  8007d6:	e9 84 00 00 00       	jmp    80085f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007df:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	89 fa                	mov    %edi,%edx
  8007ed:	f7 d8                	neg    %eax
  8007ef:	83 d2 00             	adc    $0x0,%edx
  8007f2:	f7 da                	neg    %edx
			}
			base = 10;
  8007f4:	be 0a 00 00 00       	mov    $0xa,%esi
  8007f9:	eb 64                	jmp    80085f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007fb:	89 ca                	mov    %ecx,%edx
  8007fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800800:	e8 42 fb ff ff       	call   800347 <getuint>
			base = 10;
  800805:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80080a:	eb 53                	jmp    80085f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80080c:	89 ca                	mov    %ecx,%edx
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
  800811:	e8 31 fb ff ff       	call   800347 <getuint>
    			base = 8;
  800816:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80081b:	eb 42                	jmp    80085f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80081d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800821:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800828:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80082b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800836:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8d 50 04             	lea    0x4(%eax),%edx
  80083f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800842:	8b 00                	mov    (%eax),%eax
  800844:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800849:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80084e:	eb 0f                	jmp    80085f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800850:	89 ca                	mov    %ecx,%edx
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	e8 ed fa ff ff       	call   800347 <getuint>
			base = 16;
  80085a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800863:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800867:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80086a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80086e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	89 54 24 04          	mov    %edx,0x4(%esp)
  800879:	89 da                	mov    %ebx,%edx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	e8 e9 f9 ff ff       	call   80026c <printnum>
			break;
  800883:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800886:	e9 5e fb ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088f:	89 14 24             	mov    %edx,(%esp)
  800892:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800895:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800898:	e9 4c fb ff ff       	jmp    8003e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008a8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008af:	0f 84 34 fb ff ff    	je     8003e9 <vprintfmt+0x23>
  8008b5:	83 ee 01             	sub    $0x1,%esi
  8008b8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008bc:	75 f7                	jne    8008b5 <vprintfmt+0x4ef>
  8008be:	e9 26 fb ff ff       	jmp    8003e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008c3:	83 c4 5c             	add    $0x5c,%esp
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	83 ec 28             	sub    $0x28,%esp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	74 30                	je     80091c <vsnprintf+0x51>
  8008ec:	85 d2                	test   %edx,%edx
  8008ee:	7e 2c                	jle    80091c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800901:	89 44 24 04          	mov    %eax,0x4(%esp)
  800905:	c7 04 24 81 03 80 00 	movl   $0x800381,(%esp)
  80090c:	e8 b5 fa ff ff       	call   8003c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800911:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800914:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091a:	eb 05                	jmp    800921 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800929:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800930:	8b 45 10             	mov    0x10(%ebp),%eax
  800933:	89 44 24 08          	mov    %eax,0x8(%esp)
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	89 04 24             	mov    %eax,(%esp)
  800944:	e8 82 ff ff ff       	call   8008cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    
  80094b:	00 00                	add    %al,(%eax)
  80094d:	00 00                	add    %al,(%eax)
	...

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	80 3a 00             	cmpb   $0x0,(%edx)
  80095e:	74 09                	je     800969 <strlen+0x19>
		n++;
  800960:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800967:	75 f7                	jne    800960 <strlen+0x10>
		n++;
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	85 c9                	test   %ecx,%ecx
  80097c:	74 1a                	je     800998 <strnlen+0x2d>
  80097e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800981:	74 15                	je     800998 <strnlen+0x2d>
  800983:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800988:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098a:	39 ca                	cmp    %ecx,%edx
  80098c:	74 0a                	je     800998 <strnlen+0x2d>
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800996:	75 f0                	jne    800988 <strnlen+0x1d>
		n++;
	return n;
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009b1:	83 c2 01             	add    $0x1,%edx
  8009b4:	84 c9                	test   %cl,%cl
  8009b6:	75 f2                	jne    8009aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c5:	89 1c 24             	mov    %ebx,(%esp)
  8009c8:	e8 83 ff ff ff       	call   800950 <strlen>
	strcpy(dst + len, src);
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d4:	01 d8                	add    %ebx,%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 bd ff ff ff       	call   80099b <strcpy>
	return dst;
}
  8009de:	89 d8                	mov    %ebx,%eax
  8009e0:	83 c4 08             	add    $0x8,%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f4:	85 f6                	test   %esi,%esi
  8009f6:	74 18                	je     800a10 <strncpy+0x2a>
  8009f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a03:	80 3a 01             	cmpb   $0x1,(%edx)
  800a06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	39 f1                	cmp    %esi,%ecx
  800a0e:	75 ed                	jne    8009fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a20:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a23:	89 f8                	mov    %edi,%eax
  800a25:	85 f6                	test   %esi,%esi
  800a27:	74 2b                	je     800a54 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a29:	83 fe 01             	cmp    $0x1,%esi
  800a2c:	74 23                	je     800a51 <strlcpy+0x3d>
  800a2e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a31:	84 c9                	test   %cl,%cl
  800a33:	74 1c                	je     800a51 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a35:	83 ee 02             	sub    $0x2,%esi
  800a38:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3d:	88 08                	mov    %cl,(%eax)
  800a3f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a42:	39 f2                	cmp    %esi,%edx
  800a44:	74 0b                	je     800a51 <strlcpy+0x3d>
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a4d:	84 c9                	test   %cl,%cl
  800a4f:	75 ec                	jne    800a3d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a54:	29 f8                	sub    %edi,%eax
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	84 c0                	test   %al,%al
  800a69:	74 16                	je     800a81 <strcmp+0x26>
  800a6b:	3a 02                	cmp    (%edx),%al
  800a6d:	75 12                	jne    800a81 <strcmp+0x26>
		p++, q++;
  800a6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a72:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a76:	84 c0                	test   %al,%al
  800a78:	74 07                	je     800a81 <strcmp+0x26>
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	3a 02                	cmp    (%edx),%al
  800a7f:	74 ee                	je     800a6f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a95:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9d:	85 d2                	test   %edx,%edx
  800a9f:	74 28                	je     800ac9 <strncmp+0x3e>
  800aa1:	0f b6 01             	movzbl (%ecx),%eax
  800aa4:	84 c0                	test   %al,%al
  800aa6:	74 24                	je     800acc <strncmp+0x41>
  800aa8:	3a 03                	cmp    (%ebx),%al
  800aaa:	75 20                	jne    800acc <strncmp+0x41>
  800aac:	83 ea 01             	sub    $0x1,%edx
  800aaf:	74 13                	je     800ac4 <strncmp+0x39>
		n--, p++, q++;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab7:	0f b6 01             	movzbl (%ecx),%eax
  800aba:	84 c0                	test   %al,%al
  800abc:	74 0e                	je     800acc <strncmp+0x41>
  800abe:	3a 03                	cmp    (%ebx),%al
  800ac0:	74 ea                	je     800aac <strncmp+0x21>
  800ac2:	eb 08                	jmp    800acc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acc:	0f b6 01             	movzbl (%ecx),%eax
  800acf:	0f b6 13             	movzbl (%ebx),%edx
  800ad2:	29 d0                	sub    %edx,%eax
  800ad4:	eb f3                	jmp    800ac9 <strncmp+0x3e>

00800ad6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae0:	0f b6 10             	movzbl (%eax),%edx
  800ae3:	84 d2                	test   %dl,%dl
  800ae5:	74 1c                	je     800b03 <strchr+0x2d>
		if (*s == c)
  800ae7:	38 ca                	cmp    %cl,%dl
  800ae9:	75 09                	jne    800af4 <strchr+0x1e>
  800aeb:	eb 1b                	jmp    800b08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800af0:	38 ca                	cmp    %cl,%dl
  800af2:	74 14                	je     800b08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	75 f1                	jne    800aed <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb 05                	jmp    800b08 <strchr+0x32>
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b14:	0f b6 10             	movzbl (%eax),%edx
  800b17:	84 d2                	test   %dl,%dl
  800b19:	74 14                	je     800b2f <strfind+0x25>
		if (*s == c)
  800b1b:	38 ca                	cmp    %cl,%dl
  800b1d:	75 06                	jne    800b25 <strfind+0x1b>
  800b1f:	eb 0e                	jmp    800b2f <strfind+0x25>
  800b21:	38 ca                	cmp    %cl,%dl
  800b23:	74 0a                	je     800b2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b25:	83 c0 01             	add    $0x1,%eax
  800b28:	0f b6 10             	movzbl (%eax),%edx
  800b2b:	84 d2                	test   %dl,%dl
  800b2d:	75 f2                	jne    800b21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b49:	85 c9                	test   %ecx,%ecx
  800b4b:	74 30                	je     800b7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b53:	75 25                	jne    800b7a <memset+0x49>
  800b55:	f6 c1 03             	test   $0x3,%cl
  800b58:	75 20                	jne    800b7a <memset+0x49>
		c &= 0xFF;
  800b5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5d:	89 d3                	mov    %edx,%ebx
  800b5f:	c1 e3 08             	shl    $0x8,%ebx
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	c1 e6 18             	shl    $0x18,%esi
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	c1 e0 10             	shl    $0x10,%eax
  800b6c:	09 f0                	or     %esi,%eax
  800b6e:	09 d0                	or     %edx,%eax
  800b70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b75:	fc                   	cld    
  800b76:	f3 ab                	rep stos %eax,%es:(%edi)
  800b78:	eb 03                	jmp    800b7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7a:	fc                   	cld    
  800b7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b88:	89 ec                	mov    %ebp,%esp
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba1:	39 c6                	cmp    %eax,%esi
  800ba3:	73 36                	jae    800bdb <memmove+0x4f>
  800ba5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba8:	39 d0                	cmp    %edx,%eax
  800baa:	73 2f                	jae    800bdb <memmove+0x4f>
		s += n;
		d += n;
  800bac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	75 1b                	jne    800bcf <memmove+0x43>
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 13                	jne    800bcf <memmove+0x43>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 0e                	jne    800bcf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc1:	83 ef 04             	sub    $0x4,%edi
  800bc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bca:	fd                   	std    
  800bcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcd:	eb 09                	jmp    800bd8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcf:	83 ef 01             	sub    $0x1,%edi
  800bd2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd5:	fd                   	std    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd8:	fc                   	cld    
  800bd9:	eb 20                	jmp    800bfb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be1:	75 13                	jne    800bf6 <memmove+0x6a>
  800be3:	a8 03                	test   $0x3,%al
  800be5:	75 0f                	jne    800bf6 <memmove+0x6a>
  800be7:	f6 c1 03             	test   $0x3,%cl
  800bea:	75 0a                	jne    800bf6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	fc                   	cld    
  800bf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf4:	eb 05                	jmp    800bfb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	fc                   	cld    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bfb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c01:	89 ec                	mov    %ebp,%esp
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	89 04 24             	mov    %eax,(%esp)
  800c1f:	e8 68 ff ff ff       	call   800b8c <memmove>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	74 37                	je     800c75 <memcmp+0x4f>
		if (*s1 != *s2)
  800c3e:	0f b6 03             	movzbl (%ebx),%eax
  800c41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c44:	83 ef 01             	sub    $0x1,%edi
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c4c:	38 c8                	cmp    %cl,%al
  800c4e:	74 1c                	je     800c6c <memcmp+0x46>
  800c50:	eb 10                	jmp    800c62 <memcmp+0x3c>
  800c52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c5e:	38 c8                	cmp    %cl,%al
  800c60:	74 0a                	je     800c6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c62:	0f b6 c0             	movzbl %al,%eax
  800c65:	0f b6 c9             	movzbl %cl,%ecx
  800c68:	29 c8                	sub    %ecx,%eax
  800c6a:	eb 09                	jmp    800c75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6c:	39 fa                	cmp    %edi,%edx
  800c6e:	75 e2                	jne    800c52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c80:	89 c2                	mov    %eax,%edx
  800c82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 19                	jae    800ca2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c8d:	38 08                	cmp    %cl,(%eax)
  800c8f:	75 06                	jne    800c97 <memfind+0x1d>
  800c91:	eb 0f                	jmp    800ca2 <memfind+0x28>
  800c93:	38 08                	cmp    %cl,(%eax)
  800c95:	74 0b                	je     800ca2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	39 d0                	cmp    %edx,%eax
  800c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	75 f1                	jne    800c93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	0f b6 02             	movzbl (%edx),%eax
  800cb3:	3c 20                	cmp    $0x20,%al
  800cb5:	74 04                	je     800cbb <strtol+0x17>
  800cb7:	3c 09                	cmp    $0x9,%al
  800cb9:	75 0e                	jne    800cc9 <strtol+0x25>
		s++;
  800cbb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cbe:	0f b6 02             	movzbl (%edx),%eax
  800cc1:	3c 20                	cmp    $0x20,%al
  800cc3:	74 f6                	je     800cbb <strtol+0x17>
  800cc5:	3c 09                	cmp    $0x9,%al
  800cc7:	74 f2                	je     800cbb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc9:	3c 2b                	cmp    $0x2b,%al
  800ccb:	75 0a                	jne    800cd7 <strtol+0x33>
		s++;
  800ccd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd5:	eb 10                	jmp    800ce7 <strtol+0x43>
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cdc:	3c 2d                	cmp    $0x2d,%al
  800cde:	75 07                	jne    800ce7 <strtol+0x43>
		s++, neg = 1;
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	0f 94 c0             	sete   %al
  800cec:	74 05                	je     800cf3 <strtol+0x4f>
  800cee:	83 fb 10             	cmp    $0x10,%ebx
  800cf1:	75 15                	jne    800d08 <strtol+0x64>
  800cf3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf6:	75 10                	jne    800d08 <strtol+0x64>
  800cf8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cfc:	75 0a                	jne    800d08 <strtol+0x64>
		s += 2, base = 16;
  800cfe:	83 c2 02             	add    $0x2,%edx
  800d01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d06:	eb 13                	jmp    800d1b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d08:	84 c0                	test   %al,%al
  800d0a:	74 0f                	je     800d1b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d11:	80 3a 30             	cmpb   $0x30,(%edx)
  800d14:	75 05                	jne    800d1b <strtol+0x77>
		s++, base = 8;
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d22:	0f b6 0a             	movzbl (%edx),%ecx
  800d25:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d28:	80 fb 09             	cmp    $0x9,%bl
  800d2b:	77 08                	ja     800d35 <strtol+0x91>
			dig = *s - '0';
  800d2d:	0f be c9             	movsbl %cl,%ecx
  800d30:	83 e9 30             	sub    $0x30,%ecx
  800d33:	eb 1e                	jmp    800d53 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d35:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d38:	80 fb 19             	cmp    $0x19,%bl
  800d3b:	77 08                	ja     800d45 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d3d:	0f be c9             	movsbl %cl,%ecx
  800d40:	83 e9 57             	sub    $0x57,%ecx
  800d43:	eb 0e                	jmp    800d53 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d45:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d48:	80 fb 19             	cmp    $0x19,%bl
  800d4b:	77 14                	ja     800d61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d4d:	0f be c9             	movsbl %cl,%ecx
  800d50:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d53:	39 f1                	cmp    %esi,%ecx
  800d55:	7d 0e                	jge    800d65 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d57:	83 c2 01             	add    $0x1,%edx
  800d5a:	0f af c6             	imul   %esi,%eax
  800d5d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d5f:	eb c1                	jmp    800d22 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d61:	89 c1                	mov    %eax,%ecx
  800d63:	eb 02                	jmp    800d67 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d65:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6b:	74 05                	je     800d72 <strtol+0xce>
		*endptr = (char *) s;
  800d6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d70:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d72:	89 ca                	mov    %ecx,%edx
  800d74:	f7 da                	neg    %edx
  800d76:	85 ff                	test   %edi,%edi
  800d78:	0f 45 c2             	cmovne %edx,%eax
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	89 c7                	mov    %eax,%edi
  800d9e:	89 c6                	mov    %eax,%esi
  800da0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800da8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dab:	89 ec                	mov    %ebp,%esp
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_cgetc>:

int
sys_cgetc(void)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc8:	89 d1                	mov    %edx,%ecx
  800dca:	89 d3                	mov    %edx,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	89 d6                	mov    %edx,%esi
  800dd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddb:	89 ec                	mov    %ebp,%esp
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 38             	sub    $0x38,%esp
  800de5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800deb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df3:	b8 03 00 00 00       	mov    $0x3,%eax
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 cb                	mov    %ecx,%ebx
  800dfd:	89 cf                	mov    %ecx,%edi
  800dff:	89 ce                	mov    %ecx,%esi
  800e01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7e 28                	jle    800e2f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e22:	00 
  800e23:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e2a:	e8 e1 13 00 00       	call   802210 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e38:	89 ec                	mov    %ebp,%esp
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	b8 02 00 00 00       	mov    $0x2,%eax
  800e55:	89 d1                	mov    %edx,%ecx
  800e57:	89 d3                	mov    %edx,%ebx
  800e59:	89 d7                	mov    %edx,%edi
  800e5b:	89 d6                	mov    %edx,%esi
  800e5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_yield>:

void
sys_yield(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e85:	89 d1                	mov    %edx,%ecx
  800e87:	89 d3                	mov    %edx,%ebx
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	89 d6                	mov    %edx,%esi
  800e8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 38             	sub    $0x38,%esp
  800ea2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eab:	be 00 00 00 00       	mov    $0x0,%esi
  800eb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 f7                	mov    %esi,%edi
  800ec0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 28                	jle    800eee <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eca:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800ee9:	e8 22 13 00 00       	call   802210 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ef4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef7:	89 ec                	mov    %ebp,%esp
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 38             	sub    $0x38,%esp
  800f01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800f12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	7e 28                	jle    800f4c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f2f:	00 
  800f30:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800f37:	00 
  800f38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3f:	00 
  800f40:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800f47:	e8 c4 12 00 00       	call   802210 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f4c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f52:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f55:	89 ec                	mov    %ebp,%esp
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 38             	sub    $0x38,%esp
  800f5f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f65:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 df                	mov    %ebx,%edi
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	7e 28                	jle    800faa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f86:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800f95:	00 
  800f96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800fa5:	e8 66 12 00 00       	call   802210 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800faa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fb3:	89 ec                	mov    %ebp,%esp
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 38             	sub    $0x38,%esp
  800fbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 df                	mov    %ebx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 28                	jle    801008 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801003:	e8 08 12 00 00       	call   802210 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801008:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801011:	89 ec                	mov    %ebp,%esp
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 38             	sub    $0x38,%esp
  80101b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801021:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
  801029:	b8 09 00 00 00       	mov    $0x9,%eax
  80102e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801031:	8b 55 08             	mov    0x8(%ebp),%edx
  801034:	89 df                	mov    %ebx,%edi
  801036:	89 de                	mov    %ebx,%esi
  801038:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	7e 28                	jle    801066 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801042:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801049:	00 
  80104a:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  801051:	00 
  801052:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801059:	00 
  80105a:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801061:	e8 aa 11 00 00       	call   802210 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801066:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801069:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106f:	89 ec                	mov    %ebp,%esp
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 38             	sub    $0x38,%esp
  801079:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80107c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80107f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	bb 00 00 00 00       	mov    $0x0,%ebx
  801087:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80108f:	8b 55 08             	mov    0x8(%ebp),%edx
  801092:	89 df                	mov    %ebx,%edi
  801094:	89 de                	mov    %ebx,%esi
  801096:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801098:	85 c0                	test   %eax,%eax
  80109a:	7e 28                	jle    8010c4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  8010af:	00 
  8010b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b7:	00 
  8010b8:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  8010bf:	e8 4c 11 00 00       	call   802210 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cd:	89 ec                	mov    %ebp,%esp
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	be 00 00 00 00       	mov    $0x0,%esi
  8010e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801101:	89 ec                	mov    %ebp,%esp
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 38             	sub    $0x38,%esp
  80110b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80110e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801111:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801114:	b9 00 00 00 00       	mov    $0x0,%ecx
  801119:	b8 0d 00 00 00       	mov    $0xd,%eax
  80111e:	8b 55 08             	mov    0x8(%ebp),%edx
  801121:	89 cb                	mov    %ecx,%ebx
  801123:	89 cf                	mov    %ecx,%edi
  801125:	89 ce                	mov    %ecx,%esi
  801127:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801129:	85 c0                	test   %eax,%eax
  80112b:	7e 28                	jle    801155 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801131:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801138:	00 
  801139:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  801140:	00 
  801141:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801148:	00 
  801149:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  801150:	e8 bb 10 00 00       	call   802210 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801155:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801158:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80115b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80115e:	89 ec                	mov    %ebp,%esp
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80116b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80116e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801171:	b9 00 00 00 00       	mov    $0x0,%ecx
  801176:	b8 0e 00 00 00       	mov    $0xe,%eax
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	89 cb                	mov    %ecx,%ebx
  801180:	89 cf                	mov    %ecx,%edi
  801182:	89 ce                	mov    %ecx,%esi
  801184:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801186:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801189:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80118c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80118f:	89 ec                	mov    %ebp,%esp
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    
	...

00801194 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 55 08             	mov    0x8(%ebp),%edx
  80119a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8011a0:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8011a2:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8011a5:	83 3a 01             	cmpl   $0x1,(%edx)
  8011a8:	7e 09                	jle    8011b3 <argstart+0x1f>
  8011aa:	ba 91 26 80 00       	mov    $0x802691,%edx
  8011af:	85 c9                	test   %ecx,%ecx
  8011b1:	75 05                	jne    8011b8 <argstart+0x24>
  8011b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b8:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8011bb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <argnext>:

int
argnext(struct Argstate *args)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 14             	sub    $0x14,%esp
  8011cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8011ce:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8011d5:	8b 43 08             	mov    0x8(%ebx),%eax
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	74 71                	je     80124d <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  8011dc:	80 38 00             	cmpb   $0x0,(%eax)
  8011df:	75 50                	jne    801231 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8011e1:	8b 0b                	mov    (%ebx),%ecx
  8011e3:	83 39 01             	cmpl   $0x1,(%ecx)
  8011e6:	74 57                	je     80123f <argnext+0x7b>
		    || args->argv[1][0] != '-'
  8011e8:	8b 53 04             	mov    0x4(%ebx),%edx
  8011eb:	8b 42 04             	mov    0x4(%edx),%eax
  8011ee:	80 38 2d             	cmpb   $0x2d,(%eax)
  8011f1:	75 4c                	jne    80123f <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  8011f3:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8011f7:	74 46                	je     80123f <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8011f9:	83 c0 01             	add    $0x1,%eax
  8011fc:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011ff:	8b 01                	mov    (%ecx),%eax
  801201:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801208:	89 44 24 08          	mov    %eax,0x8(%esp)
  80120c:	8d 42 08             	lea    0x8(%edx),%eax
  80120f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801213:	83 c2 04             	add    $0x4,%edx
  801216:	89 14 24             	mov    %edx,(%esp)
  801219:	e8 6e f9 ff ff       	call   800b8c <memmove>
		(*args->argc)--;
  80121e:	8b 03                	mov    (%ebx),%eax
  801220:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801223:	8b 43 08             	mov    0x8(%ebx),%eax
  801226:	80 38 2d             	cmpb   $0x2d,(%eax)
  801229:	75 06                	jne    801231 <argnext+0x6d>
  80122b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80122f:	74 0e                	je     80123f <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801231:	8b 53 08             	mov    0x8(%ebx),%edx
  801234:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801237:	83 c2 01             	add    $0x1,%edx
  80123a:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80123d:	eb 13                	jmp    801252 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  80123f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801246:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80124b:	eb 05                	jmp    801252 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80124d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801252:	83 c4 14             	add    $0x14,%esp
  801255:	5b                   	pop    %ebx
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 14             	sub    $0x14,%esp
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801262:	8b 43 08             	mov    0x8(%ebx),%eax
  801265:	85 c0                	test   %eax,%eax
  801267:	74 5a                	je     8012c3 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  801269:	80 38 00             	cmpb   $0x0,(%eax)
  80126c:	74 0c                	je     80127a <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80126e:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801271:	c7 43 08 91 26 80 00 	movl   $0x802691,0x8(%ebx)
  801278:	eb 44                	jmp    8012be <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  80127a:	8b 03                	mov    (%ebx),%eax
  80127c:	83 38 01             	cmpl   $0x1,(%eax)
  80127f:	7e 2f                	jle    8012b0 <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  801281:	8b 53 04             	mov    0x4(%ebx),%edx
  801284:	8b 4a 04             	mov    0x4(%edx),%ecx
  801287:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80128a:	8b 00                	mov    (%eax),%eax
  80128c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801293:	89 44 24 08          	mov    %eax,0x8(%esp)
  801297:	8d 42 08             	lea    0x8(%edx),%eax
  80129a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129e:	83 c2 04             	add    $0x4,%edx
  8012a1:	89 14 24             	mov    %edx,(%esp)
  8012a4:	e8 e3 f8 ff ff       	call   800b8c <memmove>
		(*args->argc)--;
  8012a9:	8b 03                	mov    (%ebx),%eax
  8012ab:	83 28 01             	subl   $0x1,(%eax)
  8012ae:	eb 0e                	jmp    8012be <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  8012b0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8012b7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8012be:	8b 43 0c             	mov    0xc(%ebx),%eax
  8012c1:	eb 05                	jmp    8012c8 <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8012c8:	83 c4 14             	add    $0x14,%esp
  8012cb:	5b                   	pop    %ebx
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 18             	sub    $0x18,%esp
  8012d4:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8012d7:	8b 42 0c             	mov    0xc(%edx),%eax
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	75 08                	jne    8012e6 <argvalue+0x18>
  8012de:	89 14 24             	mov    %edx,(%esp)
  8012e1:	e8 72 ff ff ff       	call   801258 <argnextvalue>
}
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    
	...

008012f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801306:	8b 45 08             	mov    0x8(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 df ff ff ff       	call   8012f0 <fd2num>
  801311:	05 20 00 0d 00       	add    $0xd0020,%eax
  801316:	c1 e0 0c             	shl    $0xc,%eax
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801322:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801327:	a8 01                	test   $0x1,%al
  801329:	74 34                	je     80135f <fd_alloc+0x44>
  80132b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801330:	a8 01                	test   $0x1,%al
  801332:	74 32                	je     801366 <fd_alloc+0x4b>
  801334:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801339:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80133b:	89 c2                	mov    %eax,%edx
  80133d:	c1 ea 16             	shr    $0x16,%edx
  801340:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801347:	f6 c2 01             	test   $0x1,%dl
  80134a:	74 1f                	je     80136b <fd_alloc+0x50>
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	c1 ea 0c             	shr    $0xc,%edx
  801351:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801358:	f6 c2 01             	test   $0x1,%dl
  80135b:	75 17                	jne    801374 <fd_alloc+0x59>
  80135d:	eb 0c                	jmp    80136b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80135f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801364:	eb 05                	jmp    80136b <fd_alloc+0x50>
  801366:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80136b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	eb 17                	jmp    80138b <fd_alloc+0x70>
  801374:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801379:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80137e:	75 b9                	jne    801339 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801386:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80138b:	5b                   	pop    %ebx
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    

0080138e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801394:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801399:	83 fa 1f             	cmp    $0x1f,%edx
  80139c:	77 3f                	ja     8013dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8013a4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a7:	89 d0                	mov    %edx,%eax
  8013a9:	c1 e8 16             	shr    $0x16,%eax
  8013ac:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013b8:	f6 c1 01             	test   $0x1,%cl
  8013bb:	74 20                	je     8013dd <fd_lookup+0x4f>
  8013bd:	89 d0                	mov    %edx,%eax
  8013bf:	c1 e8 0c             	shr    $0xc,%eax
  8013c2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ce:	f6 c1 01             	test   $0x1,%cl
  8013d1:	74 0a                	je     8013dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8013d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 14             	sub    $0x14,%esp
  8013e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013f1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8013f7:	75 17                	jne    801410 <dev_lookup+0x31>
  8013f9:	eb 07                	jmp    801402 <dev_lookup+0x23>
  8013fb:	39 0a                	cmp    %ecx,(%edx)
  8013fd:	75 11                	jne    801410 <dev_lookup+0x31>
  8013ff:	90                   	nop
  801400:	eb 05                	jmp    801407 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801402:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801407:	89 13                	mov    %edx,(%ebx)
			return 0;
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
  80140e:	eb 35                	jmp    801445 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801410:	83 c0 01             	add    $0x1,%eax
  801413:	8b 14 85 88 2a 80 00 	mov    0x802a88(,%eax,4),%edx
  80141a:	85 d2                	test   %edx,%edx
  80141c:	75 dd                	jne    8013fb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80141e:	a1 04 40 80 00       	mov    0x804004,%eax
  801423:	8b 40 48             	mov    0x48(%eax),%eax
  801426:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142e:	c7 04 24 0c 2a 80 00 	movl   $0x802a0c,(%esp)
  801435:	e8 15 ee ff ff       	call   80024f <cprintf>
	*dev = 0;
  80143a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801440:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801445:	83 c4 14             	add    $0x14,%esp
  801448:	5b                   	pop    %ebx
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 38             	sub    $0x38,%esp
  801451:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801454:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801457:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80145a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801461:	89 3c 24             	mov    %edi,(%esp)
  801464:	e8 87 fe ff ff       	call   8012f0 <fd2num>
  801469:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80146c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801470:	89 04 24             	mov    %eax,(%esp)
  801473:	e8 16 ff ff ff       	call   80138e <fd_lookup>
  801478:	89 c3                	mov    %eax,%ebx
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 05                	js     801483 <fd_close+0x38>
	    || fd != fd2)
  80147e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801481:	74 0e                	je     801491 <fd_close+0x46>
		return (must_exist ? r : 0);
  801483:	89 f0                	mov    %esi,%eax
  801485:	84 c0                	test   %al,%al
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
  80148c:	0f 44 d8             	cmove  %eax,%ebx
  80148f:	eb 3d                	jmp    8014ce <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801491:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	8b 07                	mov    (%edi),%eax
  80149a:	89 04 24             	mov    %eax,(%esp)
  80149d:	e8 3d ff ff ff       	call   8013df <dev_lookup>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 16                	js     8014be <fd_close+0x73>
		if (dev->dev_close)
  8014a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	74 07                	je     8014be <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8014b7:	89 3c 24             	mov    %edi,(%esp)
  8014ba:	ff d0                	call   *%eax
  8014bc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c9:	e8 8b fa ff ff       	call   800f59 <sys_page_unmap>
	return r;
}
  8014ce:	89 d8                	mov    %ebx,%eax
  8014d0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014d3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014d6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014d9:	89 ec                	mov    %ebp,%esp
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	89 04 24             	mov    %eax,(%esp)
  8014f0:	e8 99 fe ff ff       	call   80138e <fd_lookup>
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 13                	js     80150c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801500:	00 
  801501:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 3f ff ff ff       	call   80144b <fd_close>
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <close_all>:

void
close_all(void)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	53                   	push   %ebx
  801512:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801515:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80151a:	89 1c 24             	mov    %ebx,(%esp)
  80151d:	e8 bb ff ff ff       	call   8014dd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801522:	83 c3 01             	add    $0x1,%ebx
  801525:	83 fb 20             	cmp    $0x20,%ebx
  801528:	75 f0                	jne    80151a <close_all+0xc>
		close(i);
}
  80152a:	83 c4 14             	add    $0x14,%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 58             	sub    $0x58,%esp
  801536:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801539:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80153c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80153f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801545:	89 44 24 04          	mov    %eax,0x4(%esp)
  801549:	8b 45 08             	mov    0x8(%ebp),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 3a fe ff ff       	call   80138e <fd_lookup>
  801554:	89 c3                	mov    %eax,%ebx
  801556:	85 c0                	test   %eax,%eax
  801558:	0f 88 e1 00 00 00    	js     80163f <dup+0x10f>
		return r;
	close(newfdnum);
  80155e:	89 3c 24             	mov    %edi,(%esp)
  801561:	e8 77 ff ff ff       	call   8014dd <close>

	newfd = INDEX2FD(newfdnum);
  801566:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80156c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80156f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801572:	89 04 24             	mov    %eax,(%esp)
  801575:	e8 86 fd ff ff       	call   801300 <fd2data>
  80157a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80157c:	89 34 24             	mov    %esi,(%esp)
  80157f:	e8 7c fd ff ff       	call   801300 <fd2data>
  801584:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801587:	89 d8                	mov    %ebx,%eax
  801589:	c1 e8 16             	shr    $0x16,%eax
  80158c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801593:	a8 01                	test   $0x1,%al
  801595:	74 46                	je     8015dd <dup+0xad>
  801597:	89 d8                	mov    %ebx,%eax
  801599:	c1 e8 0c             	shr    $0xc,%eax
  80159c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a3:	f6 c2 01             	test   $0x1,%dl
  8015a6:	74 35                	je     8015dd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015af:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015c6:	00 
  8015c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d2:	e8 24 f9 ff ff       	call   800efb <sys_page_map>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 3b                	js     801618 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	c1 ea 0c             	shr    $0xc,%edx
  8015e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ec:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015f2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015f6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801601:	00 
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160d:	e8 e9 f8 ff ff       	call   800efb <sys_page_map>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	85 c0                	test   %eax,%eax
  801616:	79 25                	jns    80163d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801618:	89 74 24 04          	mov    %esi,0x4(%esp)
  80161c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801623:	e8 31 f9 ff ff       	call   800f59 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801628:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80162b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801636:	e8 1e f9 ff ff       	call   800f59 <sys_page_unmap>
	return r;
  80163b:	eb 02                	jmp    80163f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80163d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80163f:	89 d8                	mov    %ebx,%eax
  801641:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801644:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801647:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80164a:	89 ec                	mov    %ebp,%esp
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    

0080164e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	83 ec 24             	sub    $0x24,%esp
  801655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165f:	89 1c 24             	mov    %ebx,(%esp)
  801662:	e8 27 fd ff ff       	call   80138e <fd_lookup>
  801667:	85 c0                	test   %eax,%eax
  801669:	78 6d                	js     8016d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801675:	8b 00                	mov    (%eax),%eax
  801677:	89 04 24             	mov    %eax,(%esp)
  80167a:	e8 60 fd ff ff       	call   8013df <dev_lookup>
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 55                	js     8016d8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	8b 50 08             	mov    0x8(%eax),%edx
  801689:	83 e2 03             	and    $0x3,%edx
  80168c:	83 fa 01             	cmp    $0x1,%edx
  80168f:	75 23                	jne    8016b4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801691:	a1 04 40 80 00       	mov    0x804004,%eax
  801696:	8b 40 48             	mov    0x48(%eax),%eax
  801699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80169d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a1:	c7 04 24 4d 2a 80 00 	movl   $0x802a4d,(%esp)
  8016a8:	e8 a2 eb ff ff       	call   80024f <cprintf>
		return -E_INVAL;
  8016ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b2:	eb 24                	jmp    8016d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	8b 52 08             	mov    0x8(%edx),%edx
  8016ba:	85 d2                	test   %edx,%edx
  8016bc:	74 15                	je     8016d3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8016be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	ff d2                	call   *%edx
  8016d1:	eb 05                	jmp    8016d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8016d8:	83 c4 24             	add    $0x24,%esp
  8016db:	5b                   	pop    %ebx
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	57                   	push   %edi
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 1c             	sub    $0x1c,%esp
  8016e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f2:	85 f6                	test   %esi,%esi
  8016f4:	74 30                	je     801726 <readn+0x48>
  8016f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016fb:	89 f2                	mov    %esi,%edx
  8016fd:	29 c2                	sub    %eax,%edx
  8016ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801703:	03 45 0c             	add    0xc(%ebp),%eax
  801706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170a:	89 3c 24             	mov    %edi,(%esp)
  80170d:	e8 3c ff ff ff       	call   80164e <read>
		if (m < 0)
  801712:	85 c0                	test   %eax,%eax
  801714:	78 10                	js     801726 <readn+0x48>
			return m;
		if (m == 0)
  801716:	85 c0                	test   %eax,%eax
  801718:	74 0a                	je     801724 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80171a:	01 c3                	add    %eax,%ebx
  80171c:	89 d8                	mov    %ebx,%eax
  80171e:	39 f3                	cmp    %esi,%ebx
  801720:	72 d9                	jb     8016fb <readn+0x1d>
  801722:	eb 02                	jmp    801726 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801724:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801726:	83 c4 1c             	add    $0x1c,%esp
  801729:	5b                   	pop    %ebx
  80172a:	5e                   	pop    %esi
  80172b:	5f                   	pop    %edi
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 24             	sub    $0x24,%esp
  801735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	89 1c 24             	mov    %ebx,(%esp)
  801742:	e8 47 fc ff ff       	call   80138e <fd_lookup>
  801747:	85 c0                	test   %eax,%eax
  801749:	78 68                	js     8017b3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	8b 00                	mov    (%eax),%eax
  801757:	89 04 24             	mov    %eax,(%esp)
  80175a:	e8 80 fc ff ff       	call   8013df <dev_lookup>
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 50                	js     8017b3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80176a:	75 23                	jne    80178f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80176c:	a1 04 40 80 00       	mov    0x804004,%eax
  801771:	8b 40 48             	mov    0x48(%eax),%eax
  801774:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801778:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177c:	c7 04 24 69 2a 80 00 	movl   $0x802a69,(%esp)
  801783:	e8 c7 ea ff ff       	call   80024f <cprintf>
		return -E_INVAL;
  801788:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178d:	eb 24                	jmp    8017b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80178f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801792:	8b 52 0c             	mov    0xc(%edx),%edx
  801795:	85 d2                	test   %edx,%edx
  801797:	74 15                	je     8017ae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801799:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80179c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	ff d2                	call   *%edx
  8017ac:	eb 05                	jmp    8017b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017b3:	83 c4 24             	add    $0x24,%esp
  8017b6:	5b                   	pop    %ebx
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c9:	89 04 24             	mov    %eax,(%esp)
  8017cc:	e8 bd fb ff ff       	call   80138e <fd_lookup>
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 0e                	js     8017e3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	c9                   	leave  
  8017e4:	c3                   	ret    

008017e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 24             	sub    $0x24,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f6:	89 1c 24             	mov    %ebx,(%esp)
  8017f9:	e8 90 fb ff ff       	call   80138e <fd_lookup>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 61                	js     801863 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180c:	8b 00                	mov    (%eax),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 c9 fb ff ff       	call   8013df <dev_lookup>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 49                	js     801863 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801821:	75 23                	jne    801846 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801823:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801828:	8b 40 48             	mov    0x48(%eax),%eax
  80182b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80182f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801833:	c7 04 24 2c 2a 80 00 	movl   $0x802a2c,(%esp)
  80183a:	e8 10 ea ff ff       	call   80024f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80183f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801844:	eb 1d                	jmp    801863 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801846:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801849:	8b 52 18             	mov    0x18(%edx),%edx
  80184c:	85 d2                	test   %edx,%edx
  80184e:	74 0e                	je     80185e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801850:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801853:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	ff d2                	call   *%edx
  80185c:	eb 05                	jmp    801863 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80185e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801863:	83 c4 24             	add    $0x24,%esp
  801866:	5b                   	pop    %ebx
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 24             	sub    $0x24,%esp
  801870:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	89 04 24             	mov    %eax,(%esp)
  801880:	e8 09 fb ff ff       	call   80138e <fd_lookup>
  801885:	85 c0                	test   %eax,%eax
  801887:	78 52                	js     8018db <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801893:	8b 00                	mov    (%eax),%eax
  801895:	89 04 24             	mov    %eax,(%esp)
  801898:	e8 42 fb ff ff       	call   8013df <dev_lookup>
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 3a                	js     8018db <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a8:	74 2c                	je     8018d6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018b4:	00 00 00 
	stat->st_isdir = 0;
  8018b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018be:	00 00 00 
	stat->st_dev = dev;
  8018c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ce:	89 14 24             	mov    %edx,(%esp)
  8018d1:	ff 50 14             	call   *0x14(%eax)
  8018d4:	eb 05                	jmp    8018db <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018db:	83 c4 24             	add    $0x24,%esp
  8018de:	5b                   	pop    %ebx
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    

008018e1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 18             	sub    $0x18,%esp
  8018e7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018ea:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018f4:	00 
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	89 04 24             	mov    %eax,(%esp)
  8018fb:	e8 bc 01 00 00       	call   801abc <open>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	85 c0                	test   %eax,%eax
  801904:	78 1b                	js     801921 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801906:	8b 45 0c             	mov    0xc(%ebp),%eax
  801909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 54 ff ff ff       	call   801869 <fstat>
  801915:	89 c6                	mov    %eax,%esi
	close(fd);
  801917:	89 1c 24             	mov    %ebx,(%esp)
  80191a:	e8 be fb ff ff       	call   8014dd <close>
	return r;
  80191f:	89 f3                	mov    %esi,%ebx
}
  801921:	89 d8                	mov    %ebx,%eax
  801923:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801926:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801929:	89 ec                	mov    %ebp,%esp
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    
  80192d:	00 00                	add    %al,(%eax)
	...

00801930 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 18             	sub    $0x18,%esp
  801936:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801939:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801940:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801947:	75 11                	jne    80195a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801949:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801950:	e8 e4 09 00 00       	call   802339 <ipc_find_env>
  801955:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80195a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801961:	00 
  801962:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801969:	00 
  80196a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80196e:	a1 00 40 80 00       	mov    0x804000,%eax
  801973:	89 04 24             	mov    %eax,(%esp)
  801976:	e8 53 09 00 00       	call   8022ce <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  80197b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801982:	00 
  801983:	89 74 24 04          	mov    %esi,0x4(%esp)
  801987:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198e:	e8 d5 08 00 00       	call   802268 <ipc_recv>
}
  801993:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801996:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801999:	89 ec                	mov    %ebp,%esp
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 14             	sub    $0x14,%esp
  8019a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8019bc:	e8 6f ff ff ff       	call   801930 <fsipc>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 2b                	js     8019f0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019cc:	00 
  8019cd:	89 1c 24             	mov    %ebx,(%esp)
  8019d0:	e8 c6 ef ff ff       	call   80099b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8019da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f0:	83 c4 14             	add    $0x14,%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801a02:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a07:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0c:	b8 06 00 00 00       	mov    $0x6,%eax
  801a11:	e8 1a ff ff ff       	call   801930 <fsipc>
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 10             	sub    $0x10,%esp
  801a20:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	8b 40 0c             	mov    0xc(%eax),%eax
  801a29:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a2e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
  801a39:	b8 03 00 00 00       	mov    $0x3,%eax
  801a3e:	e8 ed fe ff ff       	call   801930 <fsipc>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 6a                	js     801ab3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a49:	39 c6                	cmp    %eax,%esi
  801a4b:	73 24                	jae    801a71 <devfile_read+0x59>
  801a4d:	c7 44 24 0c 98 2a 80 	movl   $0x802a98,0xc(%esp)
  801a54:	00 
  801a55:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  801a5c:	00 
  801a5d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801a64:	00 
  801a65:	c7 04 24 b4 2a 80 00 	movl   $0x802ab4,(%esp)
  801a6c:	e8 9f 07 00 00       	call   802210 <_panic>
	assert(r <= PGSIZE);
  801a71:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a76:	7e 24                	jle    801a9c <devfile_read+0x84>
  801a78:	c7 44 24 0c bf 2a 80 	movl   $0x802abf,0xc(%esp)
  801a7f:	00 
  801a80:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  801a87:	00 
  801a88:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a8f:	00 
  801a90:	c7 04 24 b4 2a 80 00 	movl   $0x802ab4,(%esp)
  801a97:	e8 74 07 00 00       	call   802210 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801aa7:	00 
  801aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 d9 f0 ff ff       	call   800b8c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801ab3:	89 d8                	mov    %ebx,%eax
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 20             	sub    $0x20,%esp
  801ac4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ac7:	89 34 24             	mov    %esi,(%esp)
  801aca:	e8 81 ee ff ff       	call   800950 <strlen>
		return -E_BAD_PATH;
  801acf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad9:	7f 5e                	jg     801b39 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ade:	89 04 24             	mov    %eax,(%esp)
  801ae1:	e8 35 f8 ff ff       	call   80131b <fd_alloc>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 4d                	js     801b39 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aec:	89 74 24 04          	mov    %esi,0x4(%esp)
  801af0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801af7:	e8 9f ee ff ff       	call   80099b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b07:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0c:	e8 1f fe ff ff       	call   801930 <fsipc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	85 c0                	test   %eax,%eax
  801b15:	79 15                	jns    801b2c <open+0x70>
		fd_close(fd, 0);
  801b17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b1e:	00 
  801b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b22:	89 04 24             	mov    %eax,(%esp)
  801b25:	e8 21 f9 ff ff       	call   80144b <fd_close>
		return r;
  801b2a:	eb 0d                	jmp    801b39 <open+0x7d>
	}

	return fd2num(fd);
  801b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2f:	89 04 24             	mov    %eax,(%esp)
  801b32:	e8 b9 f7 ff ff       	call   8012f0 <fd2num>
  801b37:	89 c3                	mov    %eax,%ebx
}
  801b39:	89 d8                	mov    %ebx,%eax
  801b3b:	83 c4 20             	add    $0x20,%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    
	...

00801b44 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 14             	sub    $0x14,%esp
  801b4b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801b4d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801b51:	7e 31                	jle    801b84 <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801b53:	8b 40 04             	mov    0x4(%eax),%eax
  801b56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b5a:	8d 43 10             	lea    0x10(%ebx),%eax
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	8b 03                	mov    (%ebx),%eax
  801b63:	89 04 24             	mov    %eax,(%esp)
  801b66:	e8 c3 fb ff ff       	call   80172e <write>
		if (result > 0)
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	7e 03                	jle    801b72 <writebuf+0x2e>
			b->result += result;
  801b6f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b72:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b75:	74 0d                	je     801b84 <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801b77:	85 c0                	test   %eax,%eax
  801b79:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7e:	0f 4f c2             	cmovg  %edx,%eax
  801b81:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801b84:	83 c4 14             	add    $0x14,%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <putch>:

static void
putch(int ch, void *thunk)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 04             	sub    $0x4,%esp
  801b91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b94:	8b 43 04             	mov    0x4(%ebx),%eax
  801b97:	8b 55 08             	mov    0x8(%ebp),%edx
  801b9a:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801b9e:	83 c0 01             	add    $0x1,%eax
  801ba1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801ba4:	3d 00 01 00 00       	cmp    $0x100,%eax
  801ba9:	75 0e                	jne    801bb9 <putch+0x2f>
		writebuf(b);
  801bab:	89 d8                	mov    %ebx,%eax
  801bad:	e8 92 ff ff ff       	call   801b44 <writebuf>
		b->idx = 0;
  801bb2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801bb9:	83 c4 04             	add    $0x4,%esp
  801bbc:	5b                   	pop    %ebx
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801bd1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801bd8:	00 00 00 
	b.result = 0;
  801bdb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801be2:	00 00 00 
	b.error = 1;
  801be5:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801bec:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801bef:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c07:	c7 04 24 8a 1b 80 00 	movl   $0x801b8a,(%esp)
  801c0e:	e8 b3 e7 ff ff       	call   8003c6 <vprintfmt>
	if (b.idx > 0)
  801c13:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801c1a:	7e 0b                	jle    801c27 <vfprintf+0x68>
		writebuf(&b);
  801c1c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801c22:	e8 1d ff ff ff       	call   801b44 <writebuf>

	return (b.result ? b.result : b.error);
  801c27:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c3e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801c41:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	89 04 24             	mov    %eax,(%esp)
  801c52:	e8 68 ff ff ff       	call   801bbf <vfprintf>
	va_end(ap);

	return cnt;
}
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <printf>:

int
printf(const char *fmt, ...)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c5f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801c62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c66:	8b 45 08             	mov    0x8(%ebp),%eax
  801c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c74:	e8 46 ff ff ff       	call   801bbf <vfprintf>
	va_end(ap);

	return cnt;
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    
  801c7b:	00 00                	add    %al,(%eax)
  801c7d:	00 00                	add    %al,(%eax)
	...

00801c80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 18             	sub    $0x18,%esp
  801c86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c89:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 66 f6 ff ff       	call   801300 <fd2data>
  801c9a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c9c:	c7 44 24 04 cb 2a 80 	movl   $0x802acb,0x4(%esp)
  801ca3:	00 
  801ca4:	89 34 24             	mov    %esi,(%esp)
  801ca7:	e8 ef ec ff ff       	call   80099b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cac:	8b 43 04             	mov    0x4(%ebx),%eax
  801caf:	2b 03                	sub    (%ebx),%eax
  801cb1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801cb7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cbe:	00 00 00 
	stat->st_dev = &devpipe;
  801cc1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801cc8:	30 80 00 
	return 0;
}
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cd3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cd6:	89 ec                	mov    %ebp,%esp
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	53                   	push   %ebx
  801cde:	83 ec 14             	sub    $0x14,%esp
  801ce1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ce4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cef:	e8 65 f2 ff ff       	call   800f59 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf4:	89 1c 24             	mov    %ebx,(%esp)
  801cf7:	e8 04 f6 ff ff       	call   801300 <fd2data>
  801cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d07:	e8 4d f2 ff ff       	call   800f59 <sys_page_unmap>
}
  801d0c:	83 c4 14             	add    $0x14,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 2c             	sub    $0x2c,%esp
  801d1b:	89 c7                	mov    %eax,%edi
  801d1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d20:	a1 04 40 80 00       	mov    0x804004,%eax
  801d25:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d28:	89 3c 24             	mov    %edi,(%esp)
  801d2b:	e8 54 06 00 00       	call   802384 <pageref>
  801d30:	89 c6                	mov    %eax,%esi
  801d32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 47 06 00 00       	call   802384 <pageref>
  801d3d:	39 c6                	cmp    %eax,%esi
  801d3f:	0f 94 c0             	sete   %al
  801d42:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d45:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d4b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d4e:	39 cb                	cmp    %ecx,%ebx
  801d50:	75 08                	jne    801d5a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d52:	83 c4 2c             	add    $0x2c,%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5f                   	pop    %edi
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d5a:	83 f8 01             	cmp    $0x1,%eax
  801d5d:	75 c1                	jne    801d20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d5f:	8b 52 58             	mov    0x58(%edx),%edx
  801d62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d66:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d6e:	c7 04 24 d2 2a 80 00 	movl   $0x802ad2,(%esp)
  801d75:	e8 d5 e4 ff ff       	call   80024f <cprintf>
  801d7a:	eb a4                	jmp    801d20 <_pipeisclosed+0xe>

00801d7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 2c             	sub    $0x2c,%esp
  801d85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d88:	89 34 24             	mov    %esi,(%esp)
  801d8b:	e8 70 f5 ff ff       	call   801300 <fd2data>
  801d90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d92:	bf 00 00 00 00       	mov    $0x0,%edi
  801d97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9b:	75 50                	jne    801ded <devpipe_write+0x71>
  801d9d:	eb 5c                	jmp    801dfb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d9f:	89 da                	mov    %ebx,%edx
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	e8 6a ff ff ff       	call   801d12 <_pipeisclosed>
  801da8:	85 c0                	test   %eax,%eax
  801daa:	75 53                	jne    801dff <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dac:	e8 bb f0 ff ff       	call   800e6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801db1:	8b 43 04             	mov    0x4(%ebx),%eax
  801db4:	8b 13                	mov    (%ebx),%edx
  801db6:	83 c2 20             	add    $0x20,%edx
  801db9:	39 d0                	cmp    %edx,%eax
  801dbb:	73 e2                	jae    801d9f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801dc4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801dc7:	89 c2                	mov    %eax,%edx
  801dc9:	c1 fa 1f             	sar    $0x1f,%edx
  801dcc:	c1 ea 1b             	shr    $0x1b,%edx
  801dcf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801dd2:	83 e1 1f             	and    $0x1f,%ecx
  801dd5:	29 d1                	sub    %edx,%ecx
  801dd7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801ddb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801ddf:	83 c0 01             	add    $0x1,%eax
  801de2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de5:	83 c7 01             	add    $0x1,%edi
  801de8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801deb:	74 0e                	je     801dfb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ded:	8b 43 04             	mov    0x4(%ebx),%eax
  801df0:	8b 13                	mov    (%ebx),%edx
  801df2:	83 c2 20             	add    $0x20,%edx
  801df5:	39 d0                	cmp    %edx,%eax
  801df7:	73 a6                	jae    801d9f <devpipe_write+0x23>
  801df9:	eb c2                	jmp    801dbd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dfb:	89 f8                	mov    %edi,%eax
  801dfd:	eb 05                	jmp    801e04 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e04:	83 c4 2c             	add    $0x2c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 28             	sub    $0x28,%esp
  801e12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801e15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801e18:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e1b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e1e:	89 3c 24             	mov    %edi,(%esp)
  801e21:	e8 da f4 ff ff       	call   801300 <fd2data>
  801e26:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e28:	be 00 00 00 00       	mov    $0x0,%esi
  801e2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e31:	75 47                	jne    801e7a <devpipe_read+0x6e>
  801e33:	eb 52                	jmp    801e87 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	eb 5e                	jmp    801e97 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e39:	89 da                	mov    %ebx,%edx
  801e3b:	89 f8                	mov    %edi,%eax
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	e8 cd fe ff ff       	call   801d12 <_pipeisclosed>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	75 49                	jne    801e92 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801e49:	e8 1e f0 ff ff       	call   800e6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e4e:	8b 03                	mov    (%ebx),%eax
  801e50:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e53:	74 e4                	je     801e39 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e55:	89 c2                	mov    %eax,%edx
  801e57:	c1 fa 1f             	sar    $0x1f,%edx
  801e5a:	c1 ea 1b             	shr    $0x1b,%edx
  801e5d:	01 d0                	add    %edx,%eax
  801e5f:	83 e0 1f             	and    $0x1f,%eax
  801e62:	29 d0                	sub    %edx,%eax
  801e64:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e6f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e72:	83 c6 01             	add    $0x1,%esi
  801e75:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e78:	74 0d                	je     801e87 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801e7a:	8b 03                	mov    (%ebx),%eax
  801e7c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e7f:	75 d4                	jne    801e55 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e81:	85 f6                	test   %esi,%esi
  801e83:	75 b0                	jne    801e35 <devpipe_read+0x29>
  801e85:	eb b2                	jmp    801e39 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e87:	89 f0                	mov    %esi,%eax
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	eb 05                	jmp    801e97 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801e9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ea0:	89 ec                	mov    %ebp,%esp
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 48             	sub    $0x48,%esp
  801eaa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ead:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801eb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801eb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801eb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801eb9:	89 04 24             	mov    %eax,(%esp)
  801ebc:	e8 5a f4 ff ff       	call   80131b <fd_alloc>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	0f 88 45 01 00 00    	js     802010 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecb:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ed2:	00 
  801ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee1:	e8 b6 ef ff ff       	call   800e9c <sys_page_alloc>
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	0f 88 20 01 00 00    	js     802010 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ef0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ef3:	89 04 24             	mov    %eax,(%esp)
  801ef6:	e8 20 f4 ff ff       	call   80131b <fd_alloc>
  801efb:	89 c3                	mov    %eax,%ebx
  801efd:	85 c0                	test   %eax,%eax
  801eff:	0f 88 f8 00 00 00    	js     801ffd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f05:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f0c:	00 
  801f0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1b:	e8 7c ef ff ff       	call   800e9c <sys_page_alloc>
  801f20:	89 c3                	mov    %eax,%ebx
  801f22:	85 c0                	test   %eax,%eax
  801f24:	0f 88 d3 00 00 00    	js     801ffd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2d:	89 04 24             	mov    %eax,(%esp)
  801f30:	e8 cb f3 ff ff       	call   801300 <fd2data>
  801f35:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f37:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f3e:	00 
  801f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4a:	e8 4d ef ff ff       	call   800e9c <sys_page_alloc>
  801f4f:	89 c3                	mov    %eax,%ebx
  801f51:	85 c0                	test   %eax,%eax
  801f53:	0f 88 91 00 00 00    	js     801fea <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 9c f3 ff ff       	call   801300 <fd2data>
  801f64:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f6b:	00 
  801f6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f77:	00 
  801f78:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f83:	e8 73 ef ff ff       	call   800efb <sys_page_map>
  801f88:	89 c3                	mov    %eax,%ebx
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	78 4c                	js     801fda <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f8e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f97:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f9c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fa3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fb1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 2d f3 ff ff       	call   8012f0 <fd2num>
  801fc3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801fc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fc8:	89 04 24             	mov    %eax,(%esp)
  801fcb:	e8 20 f3 ff ff       	call   8012f0 <fd2num>
  801fd0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fd8:	eb 36                	jmp    802010 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  801fda:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe5:	e8 6f ef ff ff       	call   800f59 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff8:	e8 5c ef ff ff       	call   800f59 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ffd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802000:	89 44 24 04          	mov    %eax,0x4(%esp)
  802004:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200b:	e8 49 ef ff ff       	call   800f59 <sys_page_unmap>
    err:
	return r;
}
  802010:	89 d8                	mov    %ebx,%eax
  802012:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802015:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802018:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80201b:	89 ec                	mov    %ebp,%esp
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802028:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	89 04 24             	mov    %eax,(%esp)
  802032:	e8 57 f3 ff ff       	call   80138e <fd_lookup>
  802037:	85 c0                	test   %eax,%eax
  802039:	78 15                	js     802050 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80203b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203e:	89 04 24             	mov    %eax,(%esp)
  802041:	e8 ba f2 ff ff       	call   801300 <fd2data>
	return _pipeisclosed(fd, p);
  802046:	89 c2                	mov    %eax,%edx
  802048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204b:	e8 c2 fc ff ff       	call   801d12 <_pipeisclosed>
}
  802050:	c9                   	leave  
  802051:	c3                   	ret    
	...

00802060 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    

0080206a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802070:	c7 44 24 04 ea 2a 80 	movl   $0x802aea,0x4(%esp)
  802077:	00 
  802078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207b:	89 04 24             	mov    %eax,(%esp)
  80207e:	e8 18 e9 ff ff       	call   80099b <strcpy>
	return 0;
}
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	c9                   	leave  
  802089:	c3                   	ret    

0080208a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	57                   	push   %edi
  80208e:	56                   	push   %esi
  80208f:	53                   	push   %ebx
  802090:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802096:	be 00 00 00 00       	mov    $0x0,%esi
  80209b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80209f:	74 43                	je     8020e4 <devcons_write+0x5a>
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020af:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8020b1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020b4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020b9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c0:	03 45 0c             	add    0xc(%ebp),%eax
  8020c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c7:	89 3c 24             	mov    %edi,(%esp)
  8020ca:	e8 bd ea ff ff       	call   800b8c <memmove>
		sys_cputs(buf, m);
  8020cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	e8 a5 ec ff ff       	call   800d80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020db:	01 de                	add    %ebx,%esi
  8020dd:	89 f0                	mov    %esi,%eax
  8020df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020e2:	72 c8                	jb     8020ac <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020e4:	89 f0                	mov    %esi,%eax
  8020e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020ec:	5b                   	pop    %ebx
  8020ed:	5e                   	pop    %esi
  8020ee:	5f                   	pop    %edi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    

008020f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8020f7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8020fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802100:	75 07                	jne    802109 <devcons_read+0x18>
  802102:	eb 31                	jmp    802135 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802104:	e8 63 ed ff ff       	call   800e6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	e8 9a ec ff ff       	call   800daf <sys_cgetc>
  802115:	85 c0                	test   %eax,%eax
  802117:	74 eb                	je     802104 <devcons_read+0x13>
  802119:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80211b:	85 c0                	test   %eax,%eax
  80211d:	78 16                	js     802135 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80211f:	83 f8 04             	cmp    $0x4,%eax
  802122:	74 0c                	je     802130 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	88 10                	mov    %dl,(%eax)
	return 1;
  802129:	b8 01 00 00 00       	mov    $0x1,%eax
  80212e:	eb 05                	jmp    802135 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802135:	c9                   	leave  
  802136:	c3                   	ret    

00802137 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80213d:	8b 45 08             	mov    0x8(%ebp),%eax
  802140:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802143:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80214a:	00 
  80214b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80214e:	89 04 24             	mov    %eax,(%esp)
  802151:	e8 2a ec ff ff       	call   800d80 <sys_cputs>
}
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <getchar>:

int
getchar(void)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80215e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802165:	00 
  802166:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802174:	e8 d5 f4 ff ff       	call   80164e <read>
	if (r < 0)
  802179:	85 c0                	test   %eax,%eax
  80217b:	78 0f                	js     80218c <getchar+0x34>
		return r;
	if (r < 1)
  80217d:	85 c0                	test   %eax,%eax
  80217f:	7e 06                	jle    802187 <getchar+0x2f>
		return -E_EOF;
	return c;
  802181:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802185:	eb 05                	jmp    80218c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802187:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80218c:	c9                   	leave  
  80218d:	c3                   	ret    

0080218e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219b:	8b 45 08             	mov    0x8(%ebp),%eax
  80219e:	89 04 24             	mov    %eax,(%esp)
  8021a1:	e8 e8 f1 ff ff       	call   80138e <fd_lookup>
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	78 11                	js     8021bb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ad:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021b3:	39 10                	cmp    %edx,(%eax)
  8021b5:	0f 94 c0             	sete   %al
  8021b8:	0f b6 c0             	movzbl %al,%eax
}
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    

008021bd <opencons>:

int
opencons(void)
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c6:	89 04 24             	mov    %eax,(%esp)
  8021c9:	e8 4d f1 ff ff       	call   80131b <fd_alloc>
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	78 3c                	js     80220e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021d9:	00 
  8021da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e8:	e8 af ec ff ff       	call   800e9c <sys_page_alloc>
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	78 1d                	js     80220e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021f1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802206:	89 04 24             	mov    %eax,(%esp)
  802209:	e8 e2 f0 ff ff       	call   8012f0 <fd2num>
}
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	56                   	push   %esi
  802214:	53                   	push   %ebx
  802215:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802218:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80221b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802221:	e8 16 ec ff ff       	call   800e3c <sys_getenvid>
  802226:	8b 55 0c             	mov    0xc(%ebp),%edx
  802229:	89 54 24 10          	mov    %edx,0x10(%esp)
  80222d:	8b 55 08             	mov    0x8(%ebp),%edx
  802230:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223c:	c7 04 24 f8 2a 80 00 	movl   $0x802af8,(%esp)
  802243:	e8 07 e0 ff ff       	call   80024f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802248:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224c:	8b 45 10             	mov    0x10(%ebp),%eax
  80224f:	89 04 24             	mov    %eax,(%esp)
  802252:	e8 97 df ff ff       	call   8001ee <vcprintf>
	cprintf("\n");
  802257:	c7 04 24 90 26 80 00 	movl   $0x802690,(%esp)
  80225e:	e8 ec df ff ff       	call   80024f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802263:	cc                   	int3   
  802264:	eb fd                	jmp    802263 <_panic+0x53>
	...

00802268 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	56                   	push   %esi
  80226c:	53                   	push   %ebx
  80226d:	83 ec 10             	sub    $0x10,%esp
  802270:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802273:	8b 45 0c             	mov    0xc(%ebp),%eax
  802276:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802279:	85 db                	test   %ebx,%ebx
  80227b:	74 06                	je     802283 <ipc_recv+0x1b>
  80227d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  802283:	85 f6                	test   %esi,%esi
  802285:	74 06                	je     80228d <ipc_recv+0x25>
  802287:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  80228d:	85 c0                	test   %eax,%eax
  80228f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802294:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802297:	89 04 24             	mov    %eax,(%esp)
  80229a:	e8 66 ee ff ff       	call   801105 <sys_ipc_recv>
    if (ret) return ret;
  80229f:	85 c0                	test   %eax,%eax
  8022a1:	75 24                	jne    8022c7 <ipc_recv+0x5f>
    if (from_env_store)
  8022a3:	85 db                	test   %ebx,%ebx
  8022a5:	74 0a                	je     8022b1 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  8022a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022ac:	8b 40 74             	mov    0x74(%eax),%eax
  8022af:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8022b1:	85 f6                	test   %esi,%esi
  8022b3:	74 0a                	je     8022bf <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8022b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8022ba:	8b 40 78             	mov    0x78(%eax),%eax
  8022bd:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8022bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8022c4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022c7:	83 c4 10             	add    $0x10,%esp
  8022ca:	5b                   	pop    %ebx
  8022cb:	5e                   	pop    %esi
  8022cc:	5d                   	pop    %ebp
  8022cd:	c3                   	ret    

008022ce <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8022da:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8022e0:	85 db                	test   %ebx,%ebx
  8022e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8022e7:	0f 44 d8             	cmove  %eax,%ebx
  8022ea:	eb 2a                	jmp    802316 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8022ec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ef:	74 20                	je     802311 <ipc_send+0x43>
  8022f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022f5:	c7 44 24 08 1c 2b 80 	movl   $0x802b1c,0x8(%esp)
  8022fc:	00 
  8022fd:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  802304:	00 
  802305:	c7 04 24 33 2b 80 00 	movl   $0x802b33,(%esp)
  80230c:	e8 ff fe ff ff       	call   802210 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802311:	e8 56 eb ff ff       	call   800e6c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802316:	8b 45 14             	mov    0x14(%ebp),%eax
  802319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80231d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802325:	89 34 24             	mov    %esi,(%esp)
  802328:	e8 a4 ed ff ff       	call   8010d1 <sys_ipc_try_send>
  80232d:	85 c0                	test   %eax,%eax
  80232f:	75 bb                	jne    8022ec <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    

00802339 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80233f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802344:	39 c8                	cmp    %ecx,%eax
  802346:	74 19                	je     802361 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802348:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80234d:	89 c2                	mov    %eax,%edx
  80234f:	c1 e2 07             	shl    $0x7,%edx
  802352:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802358:	8b 52 50             	mov    0x50(%edx),%edx
  80235b:	39 ca                	cmp    %ecx,%edx
  80235d:	75 14                	jne    802373 <ipc_find_env+0x3a>
  80235f:	eb 05                	jmp    802366 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802361:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802366:	c1 e0 07             	shl    $0x7,%eax
  802369:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80236e:	8b 40 40             	mov    0x40(%eax),%eax
  802371:	eb 0e                	jmp    802381 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802373:	83 c0 01             	add    $0x1,%eax
  802376:	3d 00 04 00 00       	cmp    $0x400,%eax
  80237b:	75 d0                	jne    80234d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80237d:	66 b8 00 00          	mov    $0x0,%ax
}
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    
	...

00802384 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
  802387:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80238a:	89 d0                	mov    %edx,%eax
  80238c:	c1 e8 16             	shr    $0x16,%eax
  80238f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802396:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80239b:	f6 c1 01             	test   $0x1,%cl
  80239e:	74 1d                	je     8023bd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023a0:	c1 ea 0c             	shr    $0xc,%edx
  8023a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023aa:	f6 c2 01             	test   $0x1,%dl
  8023ad:	74 0e                	je     8023bd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023af:	c1 ea 0c             	shr    $0xc,%edx
  8023b2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023b9:	ef 
  8023ba:	0f b7 c0             	movzwl %ax,%eax
}
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
	...

008023c0 <__udivdi3>:
  8023c0:	83 ec 1c             	sub    $0x1c,%esp
  8023c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8023c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8023cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8023cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8023d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8023db:	85 ff                	test   %edi,%edi
  8023dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8023e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e5:	89 cd                	mov    %ecx,%ebp
  8023e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023eb:	75 33                	jne    802420 <__udivdi3+0x60>
  8023ed:	39 f1                	cmp    %esi,%ecx
  8023ef:	77 57                	ja     802448 <__udivdi3+0x88>
  8023f1:	85 c9                	test   %ecx,%ecx
  8023f3:	75 0b                	jne    802400 <__udivdi3+0x40>
  8023f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fa:	31 d2                	xor    %edx,%edx
  8023fc:	f7 f1                	div    %ecx
  8023fe:	89 c1                	mov    %eax,%ecx
  802400:	89 f0                	mov    %esi,%eax
  802402:	31 d2                	xor    %edx,%edx
  802404:	f7 f1                	div    %ecx
  802406:	89 c6                	mov    %eax,%esi
  802408:	8b 44 24 04          	mov    0x4(%esp),%eax
  80240c:	f7 f1                	div    %ecx
  80240e:	89 f2                	mov    %esi,%edx
  802410:	8b 74 24 10          	mov    0x10(%esp),%esi
  802414:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802418:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80241c:	83 c4 1c             	add    $0x1c,%esp
  80241f:	c3                   	ret    
  802420:	31 d2                	xor    %edx,%edx
  802422:	31 c0                	xor    %eax,%eax
  802424:	39 f7                	cmp    %esi,%edi
  802426:	77 e8                	ja     802410 <__udivdi3+0x50>
  802428:	0f bd cf             	bsr    %edi,%ecx
  80242b:	83 f1 1f             	xor    $0x1f,%ecx
  80242e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802432:	75 2c                	jne    802460 <__udivdi3+0xa0>
  802434:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802438:	76 04                	jbe    80243e <__udivdi3+0x7e>
  80243a:	39 f7                	cmp    %esi,%edi
  80243c:	73 d2                	jae    802410 <__udivdi3+0x50>
  80243e:	31 d2                	xor    %edx,%edx
  802440:	b8 01 00 00 00       	mov    $0x1,%eax
  802445:	eb c9                	jmp    802410 <__udivdi3+0x50>
  802447:	90                   	nop
  802448:	89 f2                	mov    %esi,%edx
  80244a:	f7 f1                	div    %ecx
  80244c:	31 d2                	xor    %edx,%edx
  80244e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802452:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802456:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80245a:	83 c4 1c             	add    $0x1c,%esp
  80245d:	c3                   	ret    
  80245e:	66 90                	xchg   %ax,%ax
  802460:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802465:	b8 20 00 00 00       	mov    $0x20,%eax
  80246a:	89 ea                	mov    %ebp,%edx
  80246c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802470:	d3 e7                	shl    %cl,%edi
  802472:	89 c1                	mov    %eax,%ecx
  802474:	d3 ea                	shr    %cl,%edx
  802476:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80247b:	09 fa                	or     %edi,%edx
  80247d:	89 f7                	mov    %esi,%edi
  80247f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802483:	89 f2                	mov    %esi,%edx
  802485:	8b 74 24 08          	mov    0x8(%esp),%esi
  802489:	d3 e5                	shl    %cl,%ebp
  80248b:	89 c1                	mov    %eax,%ecx
  80248d:	d3 ef                	shr    %cl,%edi
  80248f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802494:	d3 e2                	shl    %cl,%edx
  802496:	89 c1                	mov    %eax,%ecx
  802498:	d3 ee                	shr    %cl,%esi
  80249a:	09 d6                	or     %edx,%esi
  80249c:	89 fa                	mov    %edi,%edx
  80249e:	89 f0                	mov    %esi,%eax
  8024a0:	f7 74 24 0c          	divl   0xc(%esp)
  8024a4:	89 d7                	mov    %edx,%edi
  8024a6:	89 c6                	mov    %eax,%esi
  8024a8:	f7 e5                	mul    %ebp
  8024aa:	39 d7                	cmp    %edx,%edi
  8024ac:	72 22                	jb     8024d0 <__udivdi3+0x110>
  8024ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8024b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024b7:	d3 e5                	shl    %cl,%ebp
  8024b9:	39 c5                	cmp    %eax,%ebp
  8024bb:	73 04                	jae    8024c1 <__udivdi3+0x101>
  8024bd:	39 d7                	cmp    %edx,%edi
  8024bf:	74 0f                	je     8024d0 <__udivdi3+0x110>
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	e9 46 ff ff ff       	jmp    802410 <__udivdi3+0x50>
  8024ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8024d3:	31 d2                	xor    %edx,%edx
  8024d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8024d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8024dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8024e1:	83 c4 1c             	add    $0x1c,%esp
  8024e4:	c3                   	ret    
	...

008024f0 <__umoddi3>:
  8024f0:	83 ec 1c             	sub    $0x1c,%esp
  8024f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8024f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8024fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8024ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  802503:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802507:	8b 74 24 24          	mov    0x24(%esp),%esi
  80250b:	85 ed                	test   %ebp,%ebp
  80250d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802511:	89 44 24 08          	mov    %eax,0x8(%esp)
  802515:	89 cf                	mov    %ecx,%edi
  802517:	89 04 24             	mov    %eax,(%esp)
  80251a:	89 f2                	mov    %esi,%edx
  80251c:	75 1a                	jne    802538 <__umoddi3+0x48>
  80251e:	39 f1                	cmp    %esi,%ecx
  802520:	76 4e                	jbe    802570 <__umoddi3+0x80>
  802522:	f7 f1                	div    %ecx
  802524:	89 d0                	mov    %edx,%eax
  802526:	31 d2                	xor    %edx,%edx
  802528:	8b 74 24 10          	mov    0x10(%esp),%esi
  80252c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802530:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802534:	83 c4 1c             	add    $0x1c,%esp
  802537:	c3                   	ret    
  802538:	39 f5                	cmp    %esi,%ebp
  80253a:	77 54                	ja     802590 <__umoddi3+0xa0>
  80253c:	0f bd c5             	bsr    %ebp,%eax
  80253f:	83 f0 1f             	xor    $0x1f,%eax
  802542:	89 44 24 04          	mov    %eax,0x4(%esp)
  802546:	75 60                	jne    8025a8 <__umoddi3+0xb8>
  802548:	3b 0c 24             	cmp    (%esp),%ecx
  80254b:	0f 87 07 01 00 00    	ja     802658 <__umoddi3+0x168>
  802551:	89 f2                	mov    %esi,%edx
  802553:	8b 34 24             	mov    (%esp),%esi
  802556:	29 ce                	sub    %ecx,%esi
  802558:	19 ea                	sbb    %ebp,%edx
  80255a:	89 34 24             	mov    %esi,(%esp)
  80255d:	8b 04 24             	mov    (%esp),%eax
  802560:	8b 74 24 10          	mov    0x10(%esp),%esi
  802564:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802568:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	c3                   	ret    
  802570:	85 c9                	test   %ecx,%ecx
  802572:	75 0b                	jne    80257f <__umoddi3+0x8f>
  802574:	b8 01 00 00 00       	mov    $0x1,%eax
  802579:	31 d2                	xor    %edx,%edx
  80257b:	f7 f1                	div    %ecx
  80257d:	89 c1                	mov    %eax,%ecx
  80257f:	89 f0                	mov    %esi,%eax
  802581:	31 d2                	xor    %edx,%edx
  802583:	f7 f1                	div    %ecx
  802585:	8b 04 24             	mov    (%esp),%eax
  802588:	f7 f1                	div    %ecx
  80258a:	eb 98                	jmp    802524 <__umoddi3+0x34>
  80258c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802590:	89 f2                	mov    %esi,%edx
  802592:	8b 74 24 10          	mov    0x10(%esp),%esi
  802596:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80259a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80259e:	83 c4 1c             	add    $0x1c,%esp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025ad:	89 e8                	mov    %ebp,%eax
  8025af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8025b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8025b8:	89 fa                	mov    %edi,%edx
  8025ba:	d3 e0                	shl    %cl,%eax
  8025bc:	89 e9                	mov    %ebp,%ecx
  8025be:	d3 ea                	shr    %cl,%edx
  8025c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025c5:	09 c2                	or     %eax,%edx
  8025c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cb:	89 14 24             	mov    %edx,(%esp)
  8025ce:	89 f2                	mov    %esi,%edx
  8025d0:	d3 e7                	shl    %cl,%edi
  8025d2:	89 e9                	mov    %ebp,%ecx
  8025d4:	d3 ea                	shr    %cl,%edx
  8025d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025df:	d3 e6                	shl    %cl,%esi
  8025e1:	89 e9                	mov    %ebp,%ecx
  8025e3:	d3 e8                	shr    %cl,%eax
  8025e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025ea:	09 f0                	or     %esi,%eax
  8025ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025f0:	f7 34 24             	divl   (%esp)
  8025f3:	d3 e6                	shl    %cl,%esi
  8025f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025f9:	89 d6                	mov    %edx,%esi
  8025fb:	f7 e7                	mul    %edi
  8025fd:	39 d6                	cmp    %edx,%esi
  8025ff:	89 c1                	mov    %eax,%ecx
  802601:	89 d7                	mov    %edx,%edi
  802603:	72 3f                	jb     802644 <__umoddi3+0x154>
  802605:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802609:	72 35                	jb     802640 <__umoddi3+0x150>
  80260b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260f:	29 c8                	sub    %ecx,%eax
  802611:	19 fe                	sbb    %edi,%esi
  802613:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802618:	89 f2                	mov    %esi,%edx
  80261a:	d3 e8                	shr    %cl,%eax
  80261c:	89 e9                	mov    %ebp,%ecx
  80261e:	d3 e2                	shl    %cl,%edx
  802620:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802625:	09 d0                	or     %edx,%eax
  802627:	89 f2                	mov    %esi,%edx
  802629:	d3 ea                	shr    %cl,%edx
  80262b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80262f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802633:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802637:	83 c4 1c             	add    $0x1c,%esp
  80263a:	c3                   	ret    
  80263b:	90                   	nop
  80263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802640:	39 d6                	cmp    %edx,%esi
  802642:	75 c7                	jne    80260b <__umoddi3+0x11b>
  802644:	89 d7                	mov    %edx,%edi
  802646:	89 c1                	mov    %eax,%ecx
  802648:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80264c:	1b 3c 24             	sbb    (%esp),%edi
  80264f:	eb ba                	jmp    80260b <__umoddi3+0x11b>
  802651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802658:	39 f5                	cmp    %esi,%ebp
  80265a:	0f 82 f1 fe ff ff    	jb     802551 <__umoddi3+0x61>
  802660:	e9 f8 fe ff ff       	jmp    80255d <__umoddi3+0x6d>
