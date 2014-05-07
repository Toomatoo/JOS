
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 b9 0d 00 00       	call   800dfc <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 60 28 80 00 	movl   $0x802860,(%esp)
  800052:	e8 b4 01 00 00       	call   80020b <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 38             	sub    $0x38,%esp
  800083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800086:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800090:	89 1c 24             	mov    %ebx,(%esp)
  800093:	e8 78 08 00 00       	call   800910 <strlen>
  800098:	83 f8 02             	cmp    $0x2,%eax
  80009b:	7f 41                	jg     8000de <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000aa:	c7 44 24 08 71 28 80 	movl   $0x802871,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b9:	00 
  8000ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 1a 08 00 00       	call   8008df <snprintf>
	if (fork() == 0) {
  8000c5:	e8 ad 11 00 00       	call   801277 <fork>
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 10                	jne    8000de <forkchild+0x61>
		forktree(nxt);
  8000ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d1:	89 04 24             	mov    %eax,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <forktree>
		exit();
  8000d9:	e8 6e 00 00 00       	call   80014c <exit>
	}
}
  8000de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e4:	89 ec                	mov    %ebp,%esp
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ee:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  8000f5:	e8 3a ff ff ff       	call   800034 <forktree>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 75 08             	mov    0x8(%ebp),%esi
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010e:	e8 e9 0c 00 00       	call   800dfc <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	c1 e0 07             	shl    $0x7,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x34>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 ac ff ff ff       	call   8000e8 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800144:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800152:	e8 27 16 00 00       	call   80177e <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 3c 0c 00 00       	call   800d9f <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 14             	sub    $0x14,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	83 c0 01             	add    $0x1,%eax
  80017e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 19                	jne    8001a0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800187:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018e:	00 
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 a6 0b 00 00       	call   800d40 <sys_cputs>
		b->idx = 0;
  80019a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a4:	83 c4 14             	add    $0x14,%esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5d                   	pop    %ebp
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001df:	c7 04 24 68 01 80 00 	movl   $0x800168,(%esp)
  8001e6:	e8 97 01 00 00       	call   800382 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 3d 0b 00 00       	call   800d40 <sys_cputs>

	return b.cnt;
}
  800203:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	89 04 24             	mov    %eax,(%esp)
  80021e:	e8 87 ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    
  800225:	00 00                	add    %al,(%eax)
	...

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 3c             	sub    $0x3c,%esp
  800231:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800234:	89 d7                	mov    %edx,%edi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800245:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800248:	b8 00 00 00 00       	mov    $0x0,%eax
  80024d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800250:	72 11                	jb     800263 <printnum+0x3b>
  800252:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800255:	39 45 10             	cmp    %eax,0x10(%ebp)
  800258:	76 09                	jbe    800263 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025a:	83 eb 01             	sub    $0x1,%ebx
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	7f 51                	jg     8002b2 <printnum+0x8a>
  800261:	eb 5e                	jmp    8002c1 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800263:	89 74 24 10          	mov    %esi,0x10(%esp)
  800267:	83 eb 01             	sub    $0x1,%ebx
  80026a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80026e:	8b 45 10             	mov    0x10(%ebp),%eax
  800271:	89 44 24 08          	mov    %eax,0x8(%esp)
  800275:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800279:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80027d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800284:	00 
  800285:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80028e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800292:	e8 19 23 00 00       	call   8025b0 <__udivdi3>
  800297:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80029b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a6:	89 fa                	mov    %edi,%edx
  8002a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ab:	e8 78 ff ff ff       	call   800228 <printnum>
  8002b0:	eb 0f                	jmp    8002c1 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b6:	89 34 24             	mov    %esi,(%esp)
  8002b9:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	75 f1                	jne    8002b2 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	e8 f6 23 00 00       	call   8026e0 <__umoddi3>
  8002ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ee:	0f be 80 80 28 80 00 	movsbl 0x802880(%eax),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002fb:	83 c4 3c             	add    $0x3c,%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800306:	83 fa 01             	cmp    $0x1,%edx
  800309:	7e 0e                	jle    800319 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	8b 52 04             	mov    0x4(%edx),%edx
  800317:	eb 22                	jmp    80033b <getuint+0x38>
	else if (lflag)
  800319:	85 d2                	test   %edx,%edx
  80031b:	74 10                	je     80032d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
  80032b:	eb 0e                	jmp    80033b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800332:	89 08                	mov    %ecx,(%eax)
  800334:	8b 02                	mov    (%edx),%eax
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800343:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800347:	8b 10                	mov    (%eax),%edx
  800349:	3b 50 04             	cmp    0x4(%eax),%edx
  80034c:	73 0a                	jae    800358 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800351:	88 0a                	mov    %cl,(%edx)
  800353:	83 c2 01             	add    $0x1,%edx
  800356:	89 10                	mov    %edx,(%eax)
}
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800360:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800363:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800367:	8b 45 10             	mov    0x10(%ebp),%eax
  80036a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800371:	89 44 24 04          	mov    %eax,0x4(%esp)
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	e8 02 00 00 00       	call   800382 <vprintfmt>
	va_end(ap);
}
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	57                   	push   %edi
  800386:	56                   	push   %esi
  800387:	53                   	push   %ebx
  800388:	83 ec 5c             	sub    $0x5c,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80038e:	8b 75 10             	mov    0x10(%ebp),%esi
  800391:	eb 12                	jmp    8003a5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800393:	85 c0                	test   %eax,%eax
  800395:	0f 84 e4 04 00 00    	je     80087f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80039b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a5:	0f b6 06             	movzbl (%esi),%eax
  8003a8:	83 c6 01             	add    $0x1,%esi
  8003ab:	83 f8 25             	cmp    $0x25,%eax
  8003ae:	75 e3                	jne    800393 <vprintfmt+0x11>
  8003b0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003b4:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003bb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003c0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cc:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003cf:	eb 2b                	jmp    8003fc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d4:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003d8:	eb 22                	jmp    8003fc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003dd:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003e1:	eb 19                	jmp    8003fc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003ed:	eb 0d                	jmp    8003fc <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ef:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	0f b6 06             	movzbl (%esi),%eax
  8003ff:	0f b6 d0             	movzbl %al,%edx
  800402:	8d 7e 01             	lea    0x1(%esi),%edi
  800405:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 46 04 00 00    	ja     800859 <vprintfmt+0x4d7>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041d:	83 ea 30             	sub    $0x30,%edx
  800420:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800423:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800427:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80042d:	83 fa 09             	cmp    $0x9,%edx
  800430:	77 4a                	ja     80047c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800435:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800438:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80043b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80043f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800442:	8d 50 d0             	lea    -0x30(%eax),%edx
  800445:	83 fa 09             	cmp    $0x9,%edx
  800448:	76 eb                	jbe    800435 <vprintfmt+0xb3>
  80044a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80044d:	eb 2d                	jmp    80047c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800460:	eb 1a                	jmp    80047c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800465:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800469:	79 91                	jns    8003fc <vprintfmt+0x7a>
  80046b:	e9 73 ff ff ff       	jmp    8003e3 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80047a:	eb 80                	jmp    8003fc <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80047c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800480:	0f 89 76 ff ff ff    	jns    8003fc <vprintfmt+0x7a>
  800486:	e9 64 ff ff ff       	jmp    8003ef <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800491:	e9 66 ff ff ff       	jmp    8003fc <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 04 24             	mov    %eax,(%esp)
  8004a8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ae:	e9 f2 fe ff ff       	jmp    8003a5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004b3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004b7:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004ba:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004be:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8004c1:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8004c5:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8004c8:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8004cb:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8004cf:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004d2:	80 f9 09             	cmp    $0x9,%cl
  8004d5:	77 1d                	ja     8004f4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	6b c0 64             	imul   $0x64,%eax,%eax
  8004dd:	0f be d2             	movsbl %dl,%edx
  8004e0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004e3:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004ea:	a3 04 30 80 00       	mov    %eax,0x803004
  8004ef:	e9 b1 fe ff ff       	jmp    8003a5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004f4:	c7 44 24 04 98 28 80 	movl   $0x802898,0x4(%esp)
  8004fb:	00 
  8004fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	e8 14 05 00 00       	call   800a1b <strcmp>
  800507:	85 c0                	test   %eax,%eax
  800509:	75 0f                	jne    80051a <vprintfmt+0x198>
  80050b:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800512:	00 00 00 
  800515:	e9 8b fe ff ff       	jmp    8003a5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80051a:	c7 44 24 04 9c 28 80 	movl   $0x80289c,0x4(%esp)
  800521:	00 
  800522:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800525:	89 14 24             	mov    %edx,(%esp)
  800528:	e8 ee 04 00 00       	call   800a1b <strcmp>
  80052d:	85 c0                	test   %eax,%eax
  80052f:	75 0f                	jne    800540 <vprintfmt+0x1be>
  800531:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800538:	00 00 00 
  80053b:	e9 65 fe ff ff       	jmp    8003a5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800540:	c7 44 24 04 a0 28 80 	movl   $0x8028a0,0x4(%esp)
  800547:	00 
  800548:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80054b:	89 0c 24             	mov    %ecx,(%esp)
  80054e:	e8 c8 04 00 00       	call   800a1b <strcmp>
  800553:	85 c0                	test   %eax,%eax
  800555:	75 0f                	jne    800566 <vprintfmt+0x1e4>
  800557:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  80055e:	00 00 00 
  800561:	e9 3f fe ff ff       	jmp    8003a5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800566:	c7 44 24 04 a4 28 80 	movl   $0x8028a4,0x4(%esp)
  80056d:	00 
  80056e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800571:	89 3c 24             	mov    %edi,(%esp)
  800574:	e8 a2 04 00 00       	call   800a1b <strcmp>
  800579:	85 c0                	test   %eax,%eax
  80057b:	75 0f                	jne    80058c <vprintfmt+0x20a>
  80057d:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800584:	00 00 00 
  800587:	e9 19 fe ff ff       	jmp    8003a5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80058c:	c7 44 24 04 a8 28 80 	movl   $0x8028a8,0x4(%esp)
  800593:	00 
  800594:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	e8 7c 04 00 00       	call   800a1b <strcmp>
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	75 0f                	jne    8005b2 <vprintfmt+0x230>
  8005a3:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  8005aa:	00 00 00 
  8005ad:	e9 f3 fd ff ff       	jmp    8003a5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005b2:	c7 44 24 04 ac 28 80 	movl   $0x8028ac,0x4(%esp)
  8005b9:	00 
  8005ba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005bd:	89 14 24             	mov    %edx,(%esp)
  8005c0:	e8 56 04 00 00       	call   800a1b <strcmp>
  8005c5:	83 f8 01             	cmp    $0x1,%eax
  8005c8:	19 c0                	sbb    %eax,%eax
  8005ca:	f7 d0                	not    %eax
  8005cc:	83 c0 08             	add    $0x8,%eax
  8005cf:	a3 04 30 80 00       	mov    %eax,0x803004
  8005d4:	e9 cc fd ff ff       	jmp    8003a5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 c2                	mov    %eax,%edx
  8005e6:	c1 fa 1f             	sar    $0x1f,%edx
  8005e9:	31 d0                	xor    %edx,%eax
  8005eb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ed:	83 f8 0f             	cmp    $0xf,%eax
  8005f0:	7f 0b                	jg     8005fd <vprintfmt+0x27b>
  8005f2:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  8005f9:	85 d2                	test   %edx,%edx
  8005fb:	75 23                	jne    800620 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800601:	c7 44 24 08 b0 28 80 	movl   $0x8028b0,0x8(%esp)
  800608:	00 
  800609:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800610:	89 3c 24             	mov    %edi,(%esp)
  800613:	e8 42 fd ff ff       	call   80035a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80061b:	e9 85 fd ff ff       	jmp    8003a5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800620:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800624:	c7 44 24 08 01 2e 80 	movl   $0x802e01,0x8(%esp)
  80062b:	00 
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	8b 7d 08             	mov    0x8(%ebp),%edi
  800633:	89 3c 24             	mov    %edi,(%esp)
  800636:	e8 1f fd ff ff       	call   80035a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80063e:	e9 62 fd ff ff       	jmp    8003a5 <vprintfmt+0x23>
  800643:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800646:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800649:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800657:	85 f6                	test   %esi,%esi
  800659:	b8 91 28 80 00       	mov    $0x802891,%eax
  80065e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800661:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800665:	7e 06                	jle    80066d <vprintfmt+0x2eb>
  800667:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80066b:	75 13                	jne    800680 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066d:	0f be 06             	movsbl (%esi),%eax
  800670:	83 c6 01             	add    $0x1,%esi
  800673:	85 c0                	test   %eax,%eax
  800675:	0f 85 94 00 00 00    	jne    80070f <vprintfmt+0x38d>
  80067b:	e9 81 00 00 00       	jmp    800701 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800680:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800684:	89 34 24             	mov    %esi,(%esp)
  800687:	e8 9f 02 00 00       	call   80092b <strnlen>
  80068c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80068f:	29 c2                	sub    %eax,%edx
  800691:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800694:	85 d2                	test   %edx,%edx
  800696:	7e d5                	jle    80066d <vprintfmt+0x2eb>
					putch(padc, putdat);
  800698:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80069c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80069f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8006a2:	89 d6                	mov    %edx,%esi
  8006a4:	89 cf                	mov    %ecx,%edi
  8006a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006aa:	89 3c 24             	mov    %edi,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b0:	83 ee 01             	sub    $0x1,%esi
  8006b3:	75 f1                	jne    8006a6 <vprintfmt+0x324>
  8006b5:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006b8:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006bb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006be:	eb ad                	jmp    80066d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006c4:	74 1b                	je     8006e1 <vprintfmt+0x35f>
  8006c6:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006c9:	83 fa 5e             	cmp    $0x5e,%edx
  8006cc:	76 13                	jbe    8006e1 <vprintfmt+0x35f>
					putch('?', putdat);
  8006ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006dc:	ff 55 08             	call   *0x8(%ebp)
  8006df:	eb 0d                	jmp    8006ee <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e8:	89 04 24             	mov    %eax,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	83 eb 01             	sub    $0x1,%ebx
  8006f1:	0f be 06             	movsbl (%esi),%eax
  8006f4:	83 c6 01             	add    $0x1,%esi
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	75 1a                	jne    800715 <vprintfmt+0x393>
  8006fb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006fe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800704:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800708:	7f 1c                	jg     800726 <vprintfmt+0x3a4>
  80070a:	e9 96 fc ff ff       	jmp    8003a5 <vprintfmt+0x23>
  80070f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800712:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800715:	85 ff                	test   %edi,%edi
  800717:	78 a7                	js     8006c0 <vprintfmt+0x33e>
  800719:	83 ef 01             	sub    $0x1,%edi
  80071c:	79 a2                	jns    8006c0 <vprintfmt+0x33e>
  80071e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800721:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800724:	eb db                	jmp    800701 <vprintfmt+0x37f>
  800726:	8b 7d 08             	mov    0x8(%ebp),%edi
  800729:	89 de                	mov    %ebx,%esi
  80072b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800732:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800739:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80073b:	83 eb 01             	sub    $0x1,%ebx
  80073e:	75 ee                	jne    80072e <vprintfmt+0x3ac>
  800740:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800745:	e9 5b fc ff ff       	jmp    8003a5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074a:	83 f9 01             	cmp    $0x1,%ecx
  80074d:	7e 10                	jle    80075f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 50 08             	lea    0x8(%eax),%edx
  800755:	89 55 14             	mov    %edx,0x14(%ebp)
  800758:	8b 30                	mov    (%eax),%esi
  80075a:	8b 78 04             	mov    0x4(%eax),%edi
  80075d:	eb 26                	jmp    800785 <vprintfmt+0x403>
	else if (lflag)
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 12                	je     800775 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 30                	mov    (%eax),%esi
  80076e:	89 f7                	mov    %esi,%edi
  800770:	c1 ff 1f             	sar    $0x1f,%edi
  800773:	eb 10                	jmp    800785 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)
  80077e:	8b 30                	mov    (%eax),%esi
  800780:	89 f7                	mov    %esi,%edi
  800782:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800785:	85 ff                	test   %edi,%edi
  800787:	78 0e                	js     800797 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800789:	89 f0                	mov    %esi,%eax
  80078b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80078d:	be 0a 00 00 00       	mov    $0xa,%esi
  800792:	e9 84 00 00 00       	jmp    80081b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a5:	89 f0                	mov    %esi,%eax
  8007a7:	89 fa                	mov    %edi,%edx
  8007a9:	f7 d8                	neg    %eax
  8007ab:	83 d2 00             	adc    $0x0,%edx
  8007ae:	f7 da                	neg    %edx
			}
			base = 10;
  8007b0:	be 0a 00 00 00       	mov    $0xa,%esi
  8007b5:	eb 64                	jmp    80081b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b7:	89 ca                	mov    %ecx,%edx
  8007b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bc:	e8 42 fb ff ff       	call   800303 <getuint>
			base = 10;
  8007c1:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007c6:	eb 53                	jmp    80081b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007c8:	89 ca                	mov    %ecx,%edx
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8007cd:	e8 31 fb ff ff       	call   800303 <getuint>
    			base = 8;
  8007d2:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8007d7:	eb 42                	jmp    80081b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007dd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007eb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007f2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 50 04             	lea    0x4(%eax),%edx
  8007fb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fe:	8b 00                	mov    (%eax),%eax
  800800:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800805:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80080a:	eb 0f                	jmp    80081b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80080c:	89 ca                	mov    %ecx,%edx
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
  800811:	e8 ed fa ff ff       	call   800303 <getuint>
			base = 16;
  800816:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80081f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800823:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800826:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80082a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80082e:	89 04 24             	mov    %eax,(%esp)
  800831:	89 54 24 04          	mov    %edx,0x4(%esp)
  800835:	89 da                	mov    %ebx,%edx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	e8 e9 f9 ff ff       	call   800228 <printnum>
			break;
  80083f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800842:	e9 5e fb ff ff       	jmp    8003a5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800847:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084b:	89 14 24             	mov    %edx,(%esp)
  80084e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800854:	e9 4c fb ff ff       	jmp    8003a5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800859:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800864:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800867:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80086b:	0f 84 34 fb ff ff    	je     8003a5 <vprintfmt+0x23>
  800871:	83 ee 01             	sub    $0x1,%esi
  800874:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800878:	75 f7                	jne    800871 <vprintfmt+0x4ef>
  80087a:	e9 26 fb ff ff       	jmp    8003a5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80087f:	83 c4 5c             	add    $0x5c,%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 28             	sub    $0x28,%esp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800896:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 30                	je     8008d8 <vsnprintf+0x51>
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e 2c                	jle    8008d8 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c1:	c7 04 24 3d 03 80 00 	movl   $0x80033d,(%esp)
  8008c8:	e8 b5 fa ff ff       	call   800382 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d6:	eb 05                	jmp    8008dd <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	89 04 24             	mov    %eax,(%esp)
  800900:	e8 82 ff ff ff       	call   800887 <vsnprintf>
	va_end(ap);

	return rc;
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    
	...

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	80 3a 00             	cmpb   $0x0,(%edx)
  80091e:	74 09                	je     800929 <strlen+0x19>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0x10>
		n++;
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 1a                	je     800958 <strnlen+0x2d>
  80093e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800941:	74 15                	je     800958 <strnlen+0x2d>
  800943:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800948:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094a:	39 ca                	cmp    %ecx,%edx
  80094c:	74 0a                	je     800958 <strnlen+0x2d>
  80094e:	83 c2 01             	add    $0x1,%edx
  800951:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800956:	75 f0                	jne    800948 <strnlen+0x1d>
		n++;
	return n;
}
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80096e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800971:	83 c2 01             	add    $0x1,%edx
  800974:	84 c9                	test   %cl,%cl
  800976:	75 f2                	jne    80096a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800985:	89 1c 24             	mov    %ebx,(%esp)
  800988:	e8 83 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800990:	89 54 24 04          	mov    %edx,0x4(%esp)
  800994:	01 d8                	add    %ebx,%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	e8 bd ff ff ff       	call   80095b <strcpy>
	return dst;
}
  80099e:	89 d8                	mov    %ebx,%eax
  8009a0:	83 c4 08             	add    $0x8,%esp
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	74 18                	je     8009d0 <strncpy+0x2a>
  8009b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	39 f1                	cmp    %esi,%ecx
  8009ce:	75 ed                	jne    8009bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e3:	89 f8                	mov    %edi,%eax
  8009e5:	85 f6                	test   %esi,%esi
  8009e7:	74 2b                	je     800a14 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8009e9:	83 fe 01             	cmp    $0x1,%esi
  8009ec:	74 23                	je     800a11 <strlcpy+0x3d>
  8009ee:	0f b6 0b             	movzbl (%ebx),%ecx
  8009f1:	84 c9                	test   %cl,%cl
  8009f3:	74 1c                	je     800a11 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009f5:	83 ee 02             	sub    $0x2,%esi
  8009f8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fd:	88 08                	mov    %cl,(%eax)
  8009ff:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a02:	39 f2                	cmp    %esi,%edx
  800a04:	74 0b                	je     800a11 <strlcpy+0x3d>
  800a06:	83 c2 01             	add    $0x1,%edx
  800a09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a0d:	84 c9                	test   %cl,%cl
  800a0f:	75 ec                	jne    8009fd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a14:	29 f8                	sub    %edi,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a24:	0f b6 01             	movzbl (%ecx),%eax
  800a27:	84 c0                	test   %al,%al
  800a29:	74 16                	je     800a41 <strcmp+0x26>
  800a2b:	3a 02                	cmp    (%edx),%al
  800a2d:	75 12                	jne    800a41 <strcmp+0x26>
		p++, q++;
  800a2f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a32:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a36:	84 c0                	test   %al,%al
  800a38:	74 07                	je     800a41 <strcmp+0x26>
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	3a 02                	cmp    (%edx),%al
  800a3f:	74 ee                	je     800a2f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a41:	0f b6 c0             	movzbl %al,%eax
  800a44:	0f b6 12             	movzbl (%edx),%edx
  800a47:	29 d0                	sub    %edx,%eax
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5d:	85 d2                	test   %edx,%edx
  800a5f:	74 28                	je     800a89 <strncmp+0x3e>
  800a61:	0f b6 01             	movzbl (%ecx),%eax
  800a64:	84 c0                	test   %al,%al
  800a66:	74 24                	je     800a8c <strncmp+0x41>
  800a68:	3a 03                	cmp    (%ebx),%al
  800a6a:	75 20                	jne    800a8c <strncmp+0x41>
  800a6c:	83 ea 01             	sub    $0x1,%edx
  800a6f:	74 13                	je     800a84 <strncmp+0x39>
		n--, p++, q++;
  800a71:	83 c1 01             	add    $0x1,%ecx
  800a74:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a77:	0f b6 01             	movzbl (%ecx),%eax
  800a7a:	84 c0                	test   %al,%al
  800a7c:	74 0e                	je     800a8c <strncmp+0x41>
  800a7e:	3a 03                	cmp    (%ebx),%al
  800a80:	74 ea                	je     800a6c <strncmp+0x21>
  800a82:	eb 08                	jmp    800a8c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8c:	0f b6 01             	movzbl (%ecx),%eax
  800a8f:	0f b6 13             	movzbl (%ebx),%edx
  800a92:	29 d0                	sub    %edx,%eax
  800a94:	eb f3                	jmp    800a89 <strncmp+0x3e>

00800a96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa0:	0f b6 10             	movzbl (%eax),%edx
  800aa3:	84 d2                	test   %dl,%dl
  800aa5:	74 1c                	je     800ac3 <strchr+0x2d>
		if (*s == c)
  800aa7:	38 ca                	cmp    %cl,%dl
  800aa9:	75 09                	jne    800ab4 <strchr+0x1e>
  800aab:	eb 1b                	jmp    800ac8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aad:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	74 14                	je     800ac8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800ab8:	84 d2                	test   %dl,%dl
  800aba:	75 f1                	jne    800aad <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	eb 05                	jmp    800ac8 <strchr+0x32>
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad4:	0f b6 10             	movzbl (%eax),%edx
  800ad7:	84 d2                	test   %dl,%dl
  800ad9:	74 14                	je     800aef <strfind+0x25>
		if (*s == c)
  800adb:	38 ca                	cmp    %cl,%dl
  800add:	75 06                	jne    800ae5 <strfind+0x1b>
  800adf:	eb 0e                	jmp    800aef <strfind+0x25>
  800ae1:	38 ca                	cmp    %cl,%dl
  800ae3:	74 0a                	je     800aef <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ae5:	83 c0 01             	add    $0x1,%eax
  800ae8:	0f b6 10             	movzbl (%eax),%edx
  800aeb:	84 d2                	test   %dl,%dl
  800aed:	75 f2                	jne    800ae1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800afa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800afd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b09:	85 c9                	test   %ecx,%ecx
  800b0b:	74 30                	je     800b3d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b13:	75 25                	jne    800b3a <memset+0x49>
  800b15:	f6 c1 03             	test   $0x3,%cl
  800b18:	75 20                	jne    800b3a <memset+0x49>
		c &= 0xFF;
  800b1a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	c1 e3 08             	shl    $0x8,%ebx
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	c1 e6 18             	shl    $0x18,%esi
  800b27:	89 d0                	mov    %edx,%eax
  800b29:	c1 e0 10             	shl    $0x10,%eax
  800b2c:	09 f0                	or     %esi,%eax
  800b2e:	09 d0                	or     %edx,%eax
  800b30:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b32:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b35:	fc                   	cld    
  800b36:	f3 ab                	rep stos %eax,%es:(%edi)
  800b38:	eb 03                	jmp    800b3d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3a:	fc                   	cld    
  800b3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b48:	89 ec                	mov    %ebp,%esp
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 08             	sub    $0x8,%esp
  800b52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b55:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b61:	39 c6                	cmp    %eax,%esi
  800b63:	73 36                	jae    800b9b <memmove+0x4f>
  800b65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b68:	39 d0                	cmp    %edx,%eax
  800b6a:	73 2f                	jae    800b9b <memmove+0x4f>
		s += n;
		d += n;
  800b6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6f:	f6 c2 03             	test   $0x3,%dl
  800b72:	75 1b                	jne    800b8f <memmove+0x43>
  800b74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7a:	75 13                	jne    800b8f <memmove+0x43>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 0e                	jne    800b8f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b81:	83 ef 04             	sub    $0x4,%edi
  800b84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b87:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8a:	fd                   	std    
  800b8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8d:	eb 09                	jmp    800b98 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b8f:	83 ef 01             	sub    $0x1,%edi
  800b92:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b95:	fd                   	std    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b98:	fc                   	cld    
  800b99:	eb 20                	jmp    800bbb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba1:	75 13                	jne    800bb6 <memmove+0x6a>
  800ba3:	a8 03                	test   $0x3,%al
  800ba5:	75 0f                	jne    800bb6 <memmove+0x6a>
  800ba7:	f6 c1 03             	test   $0x3,%cl
  800baa:	75 0a                	jne    800bb6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bac:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	fc                   	cld    
  800bb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb4:	eb 05                	jmp    800bbb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	fc                   	cld    
  800bb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc1:	89 ec                	mov    %ebp,%esp
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	89 04 24             	mov    %eax,(%esp)
  800bdf:	e8 68 ff ff ff       	call   800b4c <memmove>
}
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    

00800be6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bef:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfa:	85 ff                	test   %edi,%edi
  800bfc:	74 37                	je     800c35 <memcmp+0x4f>
		if (*s1 != *s2)
  800bfe:	0f b6 03             	movzbl (%ebx),%eax
  800c01:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c04:	83 ef 01             	sub    $0x1,%edi
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c0c:	38 c8                	cmp    %cl,%al
  800c0e:	74 1c                	je     800c2c <memcmp+0x46>
  800c10:	eb 10                	jmp    800c22 <memcmp+0x3c>
  800c12:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c1e:	38 c8                	cmp    %cl,%al
  800c20:	74 0a                	je     800c2c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c22:	0f b6 c0             	movzbl %al,%eax
  800c25:	0f b6 c9             	movzbl %cl,%ecx
  800c28:	29 c8                	sub    %ecx,%eax
  800c2a:	eb 09                	jmp    800c35 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2c:	39 fa                	cmp    %edi,%edx
  800c2e:	75 e2                	jne    800c12 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c45:	39 d0                	cmp    %edx,%eax
  800c47:	73 19                	jae    800c62 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c4d:	38 08                	cmp    %cl,(%eax)
  800c4f:	75 06                	jne    800c57 <memfind+0x1d>
  800c51:	eb 0f                	jmp    800c62 <memfind+0x28>
  800c53:	38 08                	cmp    %cl,(%eax)
  800c55:	74 0b                	je     800c62 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	39 d0                	cmp    %edx,%eax
  800c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c60:	75 f1                	jne    800c53 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c70:	0f b6 02             	movzbl (%edx),%eax
  800c73:	3c 20                	cmp    $0x20,%al
  800c75:	74 04                	je     800c7b <strtol+0x17>
  800c77:	3c 09                	cmp    $0x9,%al
  800c79:	75 0e                	jne    800c89 <strtol+0x25>
		s++;
  800c7b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7e:	0f b6 02             	movzbl (%edx),%eax
  800c81:	3c 20                	cmp    $0x20,%al
  800c83:	74 f6                	je     800c7b <strtol+0x17>
  800c85:	3c 09                	cmp    $0x9,%al
  800c87:	74 f2                	je     800c7b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c89:	3c 2b                	cmp    $0x2b,%al
  800c8b:	75 0a                	jne    800c97 <strtol+0x33>
		s++;
  800c8d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c90:	bf 00 00 00 00       	mov    $0x0,%edi
  800c95:	eb 10                	jmp    800ca7 <strtol+0x43>
  800c97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c9c:	3c 2d                	cmp    $0x2d,%al
  800c9e:	75 07                	jne    800ca7 <strtol+0x43>
		s++, neg = 1;
  800ca0:	83 c2 01             	add    $0x1,%edx
  800ca3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca7:	85 db                	test   %ebx,%ebx
  800ca9:	0f 94 c0             	sete   %al
  800cac:	74 05                	je     800cb3 <strtol+0x4f>
  800cae:	83 fb 10             	cmp    $0x10,%ebx
  800cb1:	75 15                	jne    800cc8 <strtol+0x64>
  800cb3:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb6:	75 10                	jne    800cc8 <strtol+0x64>
  800cb8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cbc:	75 0a                	jne    800cc8 <strtol+0x64>
		s += 2, base = 16;
  800cbe:	83 c2 02             	add    $0x2,%edx
  800cc1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc6:	eb 13                	jmp    800cdb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cc8:	84 c0                	test   %al,%al
  800cca:	74 0f                	je     800cdb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ccc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd1:	80 3a 30             	cmpb   $0x30,(%edx)
  800cd4:	75 05                	jne    800cdb <strtol+0x77>
		s++, base = 8;
  800cd6:	83 c2 01             	add    $0x1,%edx
  800cd9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce2:	0f b6 0a             	movzbl (%edx),%ecx
  800ce5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ce8:	80 fb 09             	cmp    $0x9,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0x91>
			dig = *s - '0';
  800ced:	0f be c9             	movsbl %cl,%ecx
  800cf0:	83 e9 30             	sub    $0x30,%ecx
  800cf3:	eb 1e                	jmp    800d13 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800cf5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cf8:	80 fb 19             	cmp    $0x19,%bl
  800cfb:	77 08                	ja     800d05 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800cfd:	0f be c9             	movsbl %cl,%ecx
  800d00:	83 e9 57             	sub    $0x57,%ecx
  800d03:	eb 0e                	jmp    800d13 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d05:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d08:	80 fb 19             	cmp    $0x19,%bl
  800d0b:	77 14                	ja     800d21 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d0d:	0f be c9             	movsbl %cl,%ecx
  800d10:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d13:	39 f1                	cmp    %esi,%ecx
  800d15:	7d 0e                	jge    800d25 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d17:	83 c2 01             	add    $0x1,%edx
  800d1a:	0f af c6             	imul   %esi,%eax
  800d1d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d1f:	eb c1                	jmp    800ce2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d21:	89 c1                	mov    %eax,%ecx
  800d23:	eb 02                	jmp    800d27 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d25:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d2b:	74 05                	je     800d32 <strtol+0xce>
		*endptr = (char *) s;
  800d2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d30:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d32:	89 ca                	mov    %ecx,%edx
  800d34:	f7 da                	neg    %edx
  800d36:	85 ff                	test   %edi,%edi
  800d38:	0f 45 c2             	cmovne %edx,%eax
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 c7                	mov    %eax,%edi
  800d5e:	89 c6                	mov    %eax,%esi
  800d60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d62:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d65:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d68:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6b:	89 ec                	mov    %ebp,%esp
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d78:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 01 00 00 00       	mov    $0x1,%eax
  800d88:	89 d1                	mov    %edx,%ecx
  800d8a:	89 d3                	mov    %edx,%ebx
  800d8c:	89 d7                	mov    %edx,%edi
  800d8e:	89 d6                	mov    %edx,%esi
  800d90:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d92:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d95:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d98:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9b:	89 ec                	mov    %ebp,%esp
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 38             	sub    $0x38,%esp
  800da5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 03 00 00 00       	mov    $0x3,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 28                	jle    800def <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800dda:	00 
  800ddb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de2:	00 
  800de3:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800dea:	e8 61 15 00 00       	call   802350 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800def:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800df5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df8:	89 ec                	mov    %ebp,%esp
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e10:	b8 02 00 00 00       	mov    $0x2,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e28:	89 ec                	mov    %ebp,%esp
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_yield>:

void
sys_yield(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e35:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e38:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e45:	89 d1                	mov    %edx,%ecx
  800e47:	89 d3                	mov    %edx,%ebx
  800e49:	89 d7                	mov    %edx,%edi
  800e4b:	89 d6                	mov    %edx,%esi
  800e4d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 38             	sub    $0x38,%esp
  800e62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	be 00 00 00 00       	mov    $0x0,%esi
  800e70:	b8 04 00 00 00       	mov    $0x4,%eax
  800e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 f7                	mov    %esi,%edi
  800e80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	7e 28                	jle    800eae <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e91:	00 
  800e92:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800ea9:	e8 a2 14 00 00       	call   802350 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb7:	89 ec                	mov    %ebp,%esp
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 38             	sub    $0x38,%esp
  800ec1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecf:	8b 75 18             	mov    0x18(%ebp),%esi
  800ed2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	7e 28                	jle    800f0c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eef:	00 
  800ef0:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eff:	00 
  800f00:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f07:	e8 44 14 00 00       	call   802350 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f0c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f0f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f12:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f15:	89 ec                	mov    %ebp,%esp
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	83 ec 38             	sub    $0x38,%esp
  800f1f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f22:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f25:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f35:	8b 55 08             	mov    0x8(%ebp),%edx
  800f38:	89 df                	mov    %ebx,%edi
  800f3a:	89 de                	mov    %ebx,%esi
  800f3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	7e 28                	jle    800f6a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f46:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f65:	e8 e6 13 00 00       	call   802350 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f73:	89 ec                	mov    %ebp,%esp
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 38             	sub    $0x38,%esp
  800f7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f93:	8b 55 08             	mov    0x8(%ebp),%edx
  800f96:	89 df                	mov    %ebx,%edi
  800f98:	89 de                	mov    %ebx,%esi
  800f9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	7e 28                	jle    800fc8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fab:	00 
  800fac:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbb:	00 
  800fbc:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800fc3:	e8 88 13 00 00       	call   802350 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fc8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fcb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd1:	89 ec                	mov    %ebp,%esp
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 38             	sub    $0x38,%esp
  800fdb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fde:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	89 df                	mov    %ebx,%edi
  800ff6:	89 de                	mov    %ebx,%esi
  800ff8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	7e 28                	jle    801026 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801002:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801009:	00 
  80100a:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801011:	00 
  801012:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801021:	e8 2a 13 00 00       	call   802350 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801026:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801029:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80102c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80102f:	89 ec                	mov    %ebp,%esp
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 38             	sub    $0x38,%esp
  801039:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80103c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80103f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104f:	8b 55 08             	mov    0x8(%ebp),%edx
  801052:	89 df                	mov    %ebx,%edi
  801054:	89 de                	mov    %ebx,%esi
  801056:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	7e 28                	jle    801084 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801060:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801067:	00 
  801068:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  80107f:	e8 cc 12 00 00       	call   802350 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801084:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801087:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108d:	89 ec                	mov    %ebp,%esp
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80109a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80109d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a0:	be 00 00 00 00       	mov    $0x0,%esi
  8010a5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010aa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010bb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c1:	89 ec                	mov    %ebp,%esp
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 38             	sub    $0x38,%esp
  8010cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	89 cb                	mov    %ecx,%ebx
  8010e3:	89 cf                	mov    %ecx,%edi
  8010e5:	89 ce                	mov    %ecx,%esi
  8010e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	7e 28                	jle    801115 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801100:	00 
  801101:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801110:	e8 3b 12 00 00       	call   802350 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801115:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801118:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80111b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80111e:	89 ec                	mov    %ebp,%esp
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80112b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80112e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801131:	b9 00 00 00 00       	mov    $0x0,%ecx
  801136:	b8 0e 00 00 00       	mov    $0xe,%eax
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	89 cb                	mov    %ecx,%ebx
  801140:	89 cf                	mov    %ecx,%edi
  801142:	89 ce                	mov    %ecx,%esi
  801144:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801146:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801149:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80114f:	89 ec                	mov    %ebp,%esp
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
	...

00801154 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	53                   	push   %ebx
  801158:	83 ec 24             	sub    $0x24,%esp
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80115e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801160:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801164:	75 1c                	jne    801182 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801166:	c7 44 24 08 ca 2b 80 	movl   $0x802bca,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80117d:	e8 ce 11 00 00       	call   802350 <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801182:	89 d8                	mov    %ebx,%eax
  801184:	c1 e8 0c             	shr    $0xc,%eax
  801187:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118e:	f6 c4 08             	test   $0x8,%ah
  801191:	0f 84 be 00 00 00    	je     801255 <pgfault+0x101>
  801197:	89 d8                	mov    %ebx,%eax
  801199:	c1 e8 16             	shr    $0x16,%eax
  80119c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a3:	a8 01                	test   $0x1,%al
  8011a5:	0f 84 aa 00 00 00    	je     801255 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  8011ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c2:	e8 95 fc ff ff       	call   800e5c <sys_page_alloc>
		if (r < 0)
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	79 20                	jns    8011eb <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  8011cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cf:	c7 44 24 08 04 2c 80 	movl   $0x802c04,0x8(%esp)
  8011d6:	00 
  8011d7:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8011de:	00 
  8011df:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  8011e6:	e8 65 11 00 00       	call   802350 <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  8011eb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  8011f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011f8:	00 
  8011f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011fd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801204:	e8 bc f9 ff ff       	call   800bc5 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801209:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801210:	00 
  801211:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801215:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80121c:	00 
  80121d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801224:	00 
  801225:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122c:	e8 8a fc ff ff       	call   800ebb <sys_page_map>
		if (r < 0)
  801231:	85 c0                	test   %eax,%eax
  801233:	79 3c                	jns    801271 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  801235:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801239:	c7 44 24 08 2c 2c 80 	movl   $0x802c2c,0x8(%esp)
  801240:	00 
  801241:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801248:	00 
  801249:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  801250:	e8 fb 10 00 00       	call   802350 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801255:	c7 44 24 08 50 2c 80 	movl   $0x802c50,0x8(%esp)
  80125c:	00 
  80125d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801264:	00 
  801265:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80126c:	e8 df 10 00 00       	call   802350 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801271:	83 c4 24             	add    $0x24,%esp
  801274:	5b                   	pop    %ebx
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	57                   	push   %edi
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801280:	c7 04 24 54 11 80 00 	movl   $0x801154,(%esp)
  801287:	e8 1c 11 00 00       	call   8023a8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80128c:	bf 07 00 00 00       	mov    $0x7,%edi
  801291:	89 f8                	mov    %edi,%eax
  801293:	cd 30                	int    $0x30
  801295:	89 c7                	mov    %eax,%edi
  801297:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  80129a:	85 c0                	test   %eax,%eax
  80129c:	79 20                	jns    8012be <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  80129e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a2:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  8012b9:	e8 92 10 00 00       	call   802350 <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  8012be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	75 1c                	jne    8012e3 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  8012c7:	e8 30 fb ff ff       	call   800dfc <sys_getenvid>
  8012cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012d1:	c1 e0 07             	shl    $0x7,%eax
  8012d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d9:	a3 04 40 80 00       	mov    %eax,0x804004
		//cprintf("child fork ok!\n");
		return 0;
  8012de:	e9 51 02 00 00       	jmp    801534 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  8012e3:	89 d8                	mov    %ebx,%eax
  8012e5:	c1 e8 16             	shr    $0x16,%eax
  8012e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ef:	a8 01                	test   $0x1,%al
  8012f1:	0f 84 87 01 00 00    	je     80147e <fork+0x207>
  8012f7:	89 d8                	mov    %ebx,%eax
  8012f9:	c1 e8 0c             	shr    $0xc,%eax
  8012fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	0f 84 72 01 00 00    	je     80147e <fork+0x207>
  80130c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801313:	f6 c2 04             	test   $0x4,%dl
  801316:	0f 84 62 01 00 00    	je     80147e <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  80131c:	89 c6                	mov    %eax,%esi
  80131e:	c1 e6 0c             	shl    $0xc,%esi
  801321:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801327:	0f 84 51 01 00 00    	je     80147e <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  80132d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801334:	f6 c6 04             	test   $0x4,%dh
  801337:	74 53                	je     80138c <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801339:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801340:	25 07 0e 00 00       	and    $0xe07,%eax
  801345:	89 44 24 10          	mov    %eax,0x10(%esp)
  801349:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80134d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801350:	89 44 24 08          	mov    %eax,0x8(%esp)
  801354:	89 74 24 04          	mov    %esi,0x4(%esp)
  801358:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135f:	e8 57 fb ff ff       	call   800ebb <sys_page_map>
		if (r < 0)
  801364:	85 c0                	test   %eax,%eax
  801366:	0f 89 12 01 00 00    	jns    80147e <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  80136c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801370:	c7 44 24 08 90 2c 80 	movl   $0x802c90,0x8(%esp)
  801377:	00 
  801378:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80137f:	00 
  801380:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  801387:	e8 c4 0f 00 00       	call   802350 <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  80138c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801393:	f6 c2 02             	test   $0x2,%dl
  801396:	75 10                	jne    8013a8 <fork+0x131>
  801398:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139f:	f6 c4 08             	test   $0x8,%ah
  8013a2:	0f 84 8f 00 00 00    	je     801437 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8013a8:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013af:	00 
  8013b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c6:	e8 f0 fa ff ff       	call   800ebb <sys_page_map>
		if (r < 0)
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	79 20                	jns    8013ef <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  8013cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d3:	c7 44 24 08 bc 2c 80 	movl   $0x802cbc,0x8(%esp)
  8013da:	00 
  8013db:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  8013ea:	e8 61 0f 00 00       	call   802350 <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  8013ef:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8013f6:	00 
  8013f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801402:	00 
  801403:	89 74 24 04          	mov    %esi,0x4(%esp)
  801407:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140e:	e8 a8 fa ff ff       	call   800ebb <sys_page_map>
		if (r < 0)
  801413:	85 c0                	test   %eax,%eax
  801415:	79 67                	jns    80147e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801417:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141b:	c7 44 24 08 bc 2c 80 	movl   $0x802cbc,0x8(%esp)
  801422:	00 
  801423:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80142a:	00 
  80142b:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  801432:	e8 19 0f 00 00       	call   802350 <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  801437:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80143e:	00 
  80143f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801443:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801446:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801455:	e8 61 fa ff ff       	call   800ebb <sys_page_map>
		if (r < 0)
  80145a:	85 c0                	test   %eax,%eax
  80145c:	79 20                	jns    80147e <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  80145e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801462:	c7 44 24 08 bc 2c 80 	movl   $0x802cbc,0x8(%esp)
  801469:	00 
  80146a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801471:	00 
  801472:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  801479:	e8 d2 0e 00 00       	call   802350 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  80147e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801484:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80148a:	0f 85 53 fe ff ff    	jne    8012e3 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801490:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801497:	00 
  801498:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80149f:	ee 
  8014a0:	89 3c 24             	mov    %edi,(%esp)
  8014a3:	e8 b4 f9 ff ff       	call   800e5c <sys_page_alloc>
	if (res < 0)
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	79 20                	jns    8014cc <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  8014ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b0:	c7 44 24 08 e0 2c 80 	movl   $0x802ce0,0x8(%esp)
  8014b7:	00 
  8014b8:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8014bf:	00 
  8014c0:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  8014c7:	e8 84 0e 00 00       	call   802350 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  8014cc:	c7 44 24 04 34 24 80 	movl   $0x802434,0x4(%esp)
  8014d3:	00 
  8014d4:	89 3c 24             	mov    %edi,(%esp)
  8014d7:	e8 57 fb ff ff       	call   801033 <sys_env_set_pgfault_upcall>
	if (res < 0)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	79 20                	jns    801500 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  8014e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e4:	c7 44 24 08 04 2d 80 	movl   $0x802d04,0x8(%esp)
  8014eb:	00 
  8014ec:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8014f3:	00 
  8014f4:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  8014fb:	e8 50 0e 00 00       	call   802350 <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801500:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801507:	00 
  801508:	89 3c 24             	mov    %edi,(%esp)
  80150b:	e8 67 fa ff ff       	call   800f77 <sys_env_set_status>
	if (res < 0)
  801510:	85 c0                	test   %eax,%eax
  801512:	79 20                	jns    801534 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801514:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801518:	c7 44 24 08 34 2d 80 	movl   $0x802d34,0x8(%esp)
  80151f:	00 
  801520:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801527:	00 
  801528:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80152f:	e8 1c 0e 00 00       	call   802350 <_panic>

	return pid;
	//panic("fork not implemented");
}
  801534:	89 f8                	mov    %edi,%eax
  801536:	83 c4 3c             	add    $0x3c,%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5f                   	pop    %edi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <sfork>:

// Challenge!
int
sfork(void)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801544:	c7 44 24 08 ec 2b 80 	movl   $0x802bec,0x8(%esp)
  80154b:	00 
  80154c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801553:	00 
  801554:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80155b:	e8 f0 0d 00 00       	call   802350 <_panic>

00801560 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	05 00 00 00 30       	add    $0x30000000,%eax
  80156b:	c1 e8 0c             	shr    $0xc,%eax
}
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801576:	8b 45 08             	mov    0x8(%ebp),%eax
  801579:	89 04 24             	mov    %eax,(%esp)
  80157c:	e8 df ff ff ff       	call   801560 <fd2num>
  801581:	05 20 00 0d 00       	add    $0xd0020,%eax
  801586:	c1 e0 0c             	shl    $0xc,%eax
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801592:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801597:	a8 01                	test   $0x1,%al
  801599:	74 34                	je     8015cf <fd_alloc+0x44>
  80159b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015a0:	a8 01                	test   $0x1,%al
  8015a2:	74 32                	je     8015d6 <fd_alloc+0x4b>
  8015a4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8015a9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	c1 ea 16             	shr    $0x16,%edx
  8015b0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015b7:	f6 c2 01             	test   $0x1,%dl
  8015ba:	74 1f                	je     8015db <fd_alloc+0x50>
  8015bc:	89 c2                	mov    %eax,%edx
  8015be:	c1 ea 0c             	shr    $0xc,%edx
  8015c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015c8:	f6 c2 01             	test   $0x1,%dl
  8015cb:	75 17                	jne    8015e4 <fd_alloc+0x59>
  8015cd:	eb 0c                	jmp    8015db <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8015cf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8015d4:	eb 05                	jmp    8015db <fd_alloc+0x50>
  8015d6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8015db:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8015dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e2:	eb 17                	jmp    8015fb <fd_alloc+0x70>
  8015e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015ee:	75 b9                	jne    8015a9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8015f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015fb:	5b                   	pop    %ebx
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801604:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801609:	83 fa 1f             	cmp    $0x1f,%edx
  80160c:	77 3f                	ja     80164d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80160e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801614:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801617:	89 d0                	mov    %edx,%eax
  801619:	c1 e8 16             	shr    $0x16,%eax
  80161c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801623:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801628:	f6 c1 01             	test   $0x1,%cl
  80162b:	74 20                	je     80164d <fd_lookup+0x4f>
  80162d:	89 d0                	mov    %edx,%eax
  80162f:	c1 e8 0c             	shr    $0xc,%eax
  801632:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801639:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80163e:	f6 c1 01             	test   $0x1,%cl
  801641:	74 0a                	je     80164d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801643:	8b 45 0c             	mov    0xc(%ebp),%eax
  801646:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	83 ec 14             	sub    $0x14,%esp
  801656:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801659:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801661:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801667:	75 17                	jne    801680 <dev_lookup+0x31>
  801669:	eb 07                	jmp    801672 <dev_lookup+0x23>
  80166b:	39 0a                	cmp    %ecx,(%edx)
  80166d:	75 11                	jne    801680 <dev_lookup+0x31>
  80166f:	90                   	nop
  801670:	eb 05                	jmp    801677 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801672:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801677:	89 13                	mov    %edx,(%ebx)
			return 0;
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
  80167e:	eb 35                	jmp    8016b5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801680:	83 c0 01             	add    $0x1,%eax
  801683:	8b 14 85 d8 2d 80 00 	mov    0x802dd8(,%eax,4),%edx
  80168a:	85 d2                	test   %edx,%edx
  80168c:	75 dd                	jne    80166b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80168e:	a1 04 40 80 00       	mov    0x804004,%eax
  801693:	8b 40 48             	mov    0x48(%eax),%eax
  801696:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80169a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169e:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  8016a5:	e8 61 eb ff ff       	call   80020b <cprintf>
	*dev = 0;
  8016aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8016b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016b5:	83 c4 14             	add    $0x14,%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 38             	sub    $0x38,%esp
  8016c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016cd:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016d1:	89 3c 24             	mov    %edi,(%esp)
  8016d4:	e8 87 fe ff ff       	call   801560 <fd2num>
  8016d9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8016dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016e0:	89 04 24             	mov    %eax,(%esp)
  8016e3:	e8 16 ff ff ff       	call   8015fe <fd_lookup>
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 05                	js     8016f3 <fd_close+0x38>
	    || fd != fd2)
  8016ee:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8016f1:	74 0e                	je     801701 <fd_close+0x46>
		return (must_exist ? r : 0);
  8016f3:	89 f0                	mov    %esi,%eax
  8016f5:	84 c0                	test   %al,%al
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fc:	0f 44 d8             	cmove  %eax,%ebx
  8016ff:	eb 3d                	jmp    80173e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801701:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801704:	89 44 24 04          	mov    %eax,0x4(%esp)
  801708:	8b 07                	mov    (%edi),%eax
  80170a:	89 04 24             	mov    %eax,(%esp)
  80170d:	e8 3d ff ff ff       	call   80164f <dev_lookup>
  801712:	89 c3                	mov    %eax,%ebx
  801714:	85 c0                	test   %eax,%eax
  801716:	78 16                	js     80172e <fd_close+0x73>
		if (dev->dev_close)
  801718:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80171b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80171e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801723:	85 c0                	test   %eax,%eax
  801725:	74 07                	je     80172e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801727:	89 3c 24             	mov    %edi,(%esp)
  80172a:	ff d0                	call   *%eax
  80172c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80172e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801732:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801739:	e8 db f7 ff ff       	call   800f19 <sys_page_unmap>
	return r;
}
  80173e:	89 d8                	mov    %ebx,%eax
  801740:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801743:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801746:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801749:	89 ec                	mov    %ebp,%esp
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    

0080174d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	89 04 24             	mov    %eax,(%esp)
  801760:	e8 99 fe ff ff       	call   8015fe <fd_lookup>
  801765:	85 c0                	test   %eax,%eax
  801767:	78 13                	js     80177c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801769:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801770:	00 
  801771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801774:	89 04 24             	mov    %eax,(%esp)
  801777:	e8 3f ff ff ff       	call   8016bb <fd_close>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <close_all>:

void
close_all(void)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801785:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80178a:	89 1c 24             	mov    %ebx,(%esp)
  80178d:	e8 bb ff ff ff       	call   80174d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801792:	83 c3 01             	add    $0x1,%ebx
  801795:	83 fb 20             	cmp    $0x20,%ebx
  801798:	75 f0                	jne    80178a <close_all+0xc>
		close(i);
}
  80179a:	83 c4 14             	add    $0x14,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 58             	sub    $0x58,%esp
  8017a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8017af:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	e8 3a fe ff ff       	call   8015fe <fd_lookup>
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	0f 88 e1 00 00 00    	js     8018af <dup+0x10f>
		return r;
	close(newfdnum);
  8017ce:	89 3c 24             	mov    %edi,(%esp)
  8017d1:	e8 77 ff ff ff       	call   80174d <close>

	newfd = INDEX2FD(newfdnum);
  8017d6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8017dc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8017df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	e8 86 fd ff ff       	call   801570 <fd2data>
  8017ea:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017ec:	89 34 24             	mov    %esi,(%esp)
  8017ef:	e8 7c fd ff ff       	call   801570 <fd2data>
  8017f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	c1 e8 16             	shr    $0x16,%eax
  8017fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801803:	a8 01                	test   $0x1,%al
  801805:	74 46                	je     80184d <dup+0xad>
  801807:	89 d8                	mov    %ebx,%eax
  801809:	c1 e8 0c             	shr    $0xc,%eax
  80180c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801813:	f6 c2 01             	test   $0x1,%dl
  801816:	74 35                	je     80184d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801818:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80181f:	25 07 0e 00 00       	and    $0xe07,%eax
  801824:	89 44 24 10          	mov    %eax,0x10(%esp)
  801828:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80182b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80182f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801836:	00 
  801837:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801842:	e8 74 f6 ff ff       	call   800ebb <sys_page_map>
  801847:	89 c3                	mov    %eax,%ebx
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 3b                	js     801888 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80184d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801850:	89 c2                	mov    %eax,%edx
  801852:	c1 ea 0c             	shr    $0xc,%edx
  801855:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80185c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801862:	89 54 24 10          	mov    %edx,0x10(%esp)
  801866:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80186a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801871:	00 
  801872:	89 44 24 04          	mov    %eax,0x4(%esp)
  801876:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187d:	e8 39 f6 ff ff       	call   800ebb <sys_page_map>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	85 c0                	test   %eax,%eax
  801886:	79 25                	jns    8018ad <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801888:	89 74 24 04          	mov    %esi,0x4(%esp)
  80188c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801893:	e8 81 f6 ff ff       	call   800f19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801898:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80189b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a6:	e8 6e f6 ff ff       	call   800f19 <sys_page_unmap>
	return r;
  8018ab:	eb 02                	jmp    8018af <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8018ad:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8018af:	89 d8                	mov    %ebx,%eax
  8018b1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018b4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018ba:	89 ec                	mov    %ebp,%esp
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    

008018be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 24             	sub    $0x24,%esp
  8018c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cf:	89 1c 24             	mov    %ebx,(%esp)
  8018d2:	e8 27 fd ff ff       	call   8015fe <fd_lookup>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 6d                	js     801948 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e5:	8b 00                	mov    (%eax),%eax
  8018e7:	89 04 24             	mov    %eax,(%esp)
  8018ea:	e8 60 fd ff ff       	call   80164f <dev_lookup>
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 55                	js     801948 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f6:	8b 50 08             	mov    0x8(%eax),%edx
  8018f9:	83 e2 03             	and    $0x3,%edx
  8018fc:	83 fa 01             	cmp    $0x1,%edx
  8018ff:	75 23                	jne    801924 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801901:	a1 04 40 80 00       	mov    0x804004,%eax
  801906:	8b 40 48             	mov    0x48(%eax),%eax
  801909:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80190d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801911:	c7 04 24 9d 2d 80 00 	movl   $0x802d9d,(%esp)
  801918:	e8 ee e8 ff ff       	call   80020b <cprintf>
		return -E_INVAL;
  80191d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801922:	eb 24                	jmp    801948 <read+0x8a>
	}
	if (!dev->dev_read)
  801924:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801927:	8b 52 08             	mov    0x8(%edx),%edx
  80192a:	85 d2                	test   %edx,%edx
  80192c:	74 15                	je     801943 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80192e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801931:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801938:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	ff d2                	call   *%edx
  801941:	eb 05                	jmp    801948 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801943:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801948:	83 c4 24             	add    $0x24,%esp
  80194b:	5b                   	pop    %ebx
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	83 ec 1c             	sub    $0x1c,%esp
  801957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80195a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
  801962:	85 f6                	test   %esi,%esi
  801964:	74 30                	je     801996 <readn+0x48>
  801966:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80196b:	89 f2                	mov    %esi,%edx
  80196d:	29 c2                	sub    %eax,%edx
  80196f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801973:	03 45 0c             	add    0xc(%ebp),%eax
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	89 3c 24             	mov    %edi,(%esp)
  80197d:	e8 3c ff ff ff       	call   8018be <read>
		if (m < 0)
  801982:	85 c0                	test   %eax,%eax
  801984:	78 10                	js     801996 <readn+0x48>
			return m;
		if (m == 0)
  801986:	85 c0                	test   %eax,%eax
  801988:	74 0a                	je     801994 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80198a:	01 c3                	add    %eax,%ebx
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	39 f3                	cmp    %esi,%ebx
  801990:	72 d9                	jb     80196b <readn+0x1d>
  801992:	eb 02                	jmp    801996 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801994:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801996:	83 c4 1c             	add    $0x1c,%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5f                   	pop    %edi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 24             	sub    $0x24,%esp
  8019a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019af:	89 1c 24             	mov    %ebx,(%esp)
  8019b2:	e8 47 fc ff ff       	call   8015fe <fd_lookup>
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	78 68                	js     801a23 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c5:	8b 00                	mov    (%eax),%eax
  8019c7:	89 04 24             	mov    %eax,(%esp)
  8019ca:	e8 80 fc ff ff       	call   80164f <dev_lookup>
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 50                	js     801a23 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019da:	75 23                	jne    8019ff <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8019e1:	8b 40 48             	mov    0x48(%eax),%eax
  8019e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ec:	c7 04 24 b9 2d 80 00 	movl   $0x802db9,(%esp)
  8019f3:	e8 13 e8 ff ff       	call   80020b <cprintf>
		return -E_INVAL;
  8019f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019fd:	eb 24                	jmp    801a23 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a02:	8b 52 0c             	mov    0xc(%edx),%edx
  801a05:	85 d2                	test   %edx,%edx
  801a07:	74 15                	je     801a1e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a0c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a13:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a17:	89 04 24             	mov    %eax,(%esp)
  801a1a:	ff d2                	call   *%edx
  801a1c:	eb 05                	jmp    801a23 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a1e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a23:	83 c4 24             	add    $0x24,%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a2f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a36:	8b 45 08             	mov    0x8(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 bd fb ff ff       	call   8015fe <fd_lookup>
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 0e                	js     801a53 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	53                   	push   %ebx
  801a59:	83 ec 24             	sub    $0x24,%esp
  801a5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a66:	89 1c 24             	mov    %ebx,(%esp)
  801a69:	e8 90 fb ff ff       	call   8015fe <fd_lookup>
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	78 61                	js     801ad3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7c:	8b 00                	mov    (%eax),%eax
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 c9 fb ff ff       	call   80164f <dev_lookup>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 49                	js     801ad3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a91:	75 23                	jne    801ab6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a93:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a98:	8b 40 48             	mov    0x48(%eax),%eax
  801a9b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa3:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801aaa:	e8 5c e7 ff ff       	call   80020b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801aaf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ab4:	eb 1d                	jmp    801ad3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801ab6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab9:	8b 52 18             	mov    0x18(%edx),%edx
  801abc:	85 d2                	test   %edx,%edx
  801abe:	74 0e                	je     801ace <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ac7:	89 04 24             	mov    %eax,(%esp)
  801aca:	ff d2                	call   *%edx
  801acc:	eb 05                	jmp    801ad3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801ace:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801ad3:	83 c4 24             	add    $0x24,%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	53                   	push   %ebx
  801add:	83 ec 24             	sub    $0x24,%esp
  801ae0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ae3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	89 04 24             	mov    %eax,(%esp)
  801af0:	e8 09 fb ff ff       	call   8015fe <fd_lookup>
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 52                	js     801b4b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801af9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b03:	8b 00                	mov    (%eax),%eax
  801b05:	89 04 24             	mov    %eax,(%esp)
  801b08:	e8 42 fb ff ff       	call   80164f <dev_lookup>
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 3a                	js     801b4b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b14:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b18:	74 2c                	je     801b46 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b1a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b1d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b24:	00 00 00 
	stat->st_isdir = 0;
  801b27:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b2e:	00 00 00 
	stat->st_dev = dev;
  801b31:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b3e:	89 14 24             	mov    %edx,(%esp)
  801b41:	ff 50 14             	call   *0x14(%eax)
  801b44:	eb 05                	jmp    801b4b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b4b:	83 c4 24             	add    $0x24,%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 18             	sub    $0x18,%esp
  801b57:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b5a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b64:	00 
  801b65:	8b 45 08             	mov    0x8(%ebp),%eax
  801b68:	89 04 24             	mov    %eax,(%esp)
  801b6b:	e8 bc 01 00 00       	call   801d2c <open>
  801b70:	89 c3                	mov    %eax,%ebx
  801b72:	85 c0                	test   %eax,%eax
  801b74:	78 1b                	js     801b91 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7d:	89 1c 24             	mov    %ebx,(%esp)
  801b80:	e8 54 ff ff ff       	call   801ad9 <fstat>
  801b85:	89 c6                	mov    %eax,%esi
	close(fd);
  801b87:	89 1c 24             	mov    %ebx,(%esp)
  801b8a:	e8 be fb ff ff       	call   80174d <close>
	return r;
  801b8f:	89 f3                	mov    %esi,%ebx
}
  801b91:	89 d8                	mov    %ebx,%eax
  801b93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b96:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b99:	89 ec                	mov    %ebp,%esp
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    
  801b9d:	00 00                	add    %al,(%eax)
	...

00801ba0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	83 ec 18             	sub    $0x18,%esp
  801ba6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ba9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801bac:	89 c3                	mov    %eax,%ebx
  801bae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bb0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801bb7:	75 11                	jne    801bca <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bb9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801bc0:	e8 64 09 00 00       	call   802529 <ipc_find_env>
  801bc5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bd1:	00 
  801bd2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bd9:	00 
  801bda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bde:	a1 00 40 80 00       	mov    0x804000,%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 d3 08 00 00       	call   8024be <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801beb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf2:	00 
  801bf3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bf7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfe:	e8 55 08 00 00       	call   802458 <ipc_recv>
}
  801c03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c09:	89 ec                	mov    %ebp,%esp
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	53                   	push   %ebx
  801c11:	83 ec 14             	sub    $0x14,%esp
  801c14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c1d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c22:	ba 00 00 00 00       	mov    $0x0,%edx
  801c27:	b8 05 00 00 00       	mov    $0x5,%eax
  801c2c:	e8 6f ff ff ff       	call   801ba0 <fsipc>
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 2b                	js     801c60 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c35:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c3c:	00 
  801c3d:	89 1c 24             	mov    %ebx,(%esp)
  801c40:	e8 16 ed ff ff       	call   80095b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c45:	a1 80 50 80 00       	mov    0x805080,%eax
  801c4a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c50:	a1 84 50 80 00       	mov    0x805084,%eax
  801c55:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c60:	83 c4 14             	add    $0x14,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c72:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c77:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7c:	b8 06 00 00 00       	mov    $0x6,%eax
  801c81:	e8 1a ff ff ff       	call   801ba0 <fsipc>
}
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	83 ec 10             	sub    $0x10,%esp
  801c90:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
  801c96:	8b 40 0c             	mov    0xc(%eax),%eax
  801c99:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c9e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca9:	b8 03 00 00 00       	mov    $0x3,%eax
  801cae:	e8 ed fe ff ff       	call   801ba0 <fsipc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 6a                	js     801d23 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801cb9:	39 c6                	cmp    %eax,%esi
  801cbb:	73 24                	jae    801ce1 <devfile_read+0x59>
  801cbd:	c7 44 24 0c e8 2d 80 	movl   $0x802de8,0xc(%esp)
  801cc4:	00 
  801cc5:	c7 44 24 08 ef 2d 80 	movl   $0x802def,0x8(%esp)
  801ccc:	00 
  801ccd:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801cd4:	00 
  801cd5:	c7 04 24 04 2e 80 00 	movl   $0x802e04,(%esp)
  801cdc:	e8 6f 06 00 00       	call   802350 <_panic>
	assert(r <= PGSIZE);
  801ce1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ce6:	7e 24                	jle    801d0c <devfile_read+0x84>
  801ce8:	c7 44 24 0c 0f 2e 80 	movl   $0x802e0f,0xc(%esp)
  801cef:	00 
  801cf0:	c7 44 24 08 ef 2d 80 	movl   $0x802def,0x8(%esp)
  801cf7:	00 
  801cf8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801cff:	00 
  801d00:	c7 04 24 04 2e 80 00 	movl   $0x802e04,(%esp)
  801d07:	e8 44 06 00 00       	call   802350 <_panic>
	memmove(buf, &fsipcbuf, r);
  801d0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d10:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d17:	00 
  801d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1b:	89 04 24             	mov    %eax,(%esp)
  801d1e:	e8 29 ee ff ff       	call   800b4c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801d23:	89 d8                	mov    %ebx,%eax
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	5b                   	pop    %ebx
  801d29:	5e                   	pop    %esi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	56                   	push   %esi
  801d30:	53                   	push   %ebx
  801d31:	83 ec 20             	sub    $0x20,%esp
  801d34:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d37:	89 34 24             	mov    %esi,(%esp)
  801d3a:	e8 d1 eb ff ff       	call   800910 <strlen>
		return -E_BAD_PATH;
  801d3f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d44:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d49:	7f 5e                	jg     801da9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4e:	89 04 24             	mov    %eax,(%esp)
  801d51:	e8 35 f8 ff ff       	call   80158b <fd_alloc>
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	78 4d                	js     801da9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d60:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d67:	e8 ef eb ff ff       	call   80095b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d77:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7c:	e8 1f fe ff ff       	call   801ba0 <fsipc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	85 c0                	test   %eax,%eax
  801d85:	79 15                	jns    801d9c <open+0x70>
		fd_close(fd, 0);
  801d87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d8e:	00 
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	89 04 24             	mov    %eax,(%esp)
  801d95:	e8 21 f9 ff ff       	call   8016bb <fd_close>
		return r;
  801d9a:	eb 0d                	jmp    801da9 <open+0x7d>
	}

	return fd2num(fd);
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	89 04 24             	mov    %eax,(%esp)
  801da2:	e8 b9 f7 ff ff       	call   801560 <fd2num>
  801da7:	89 c3                	mov    %eax,%ebx
}
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	83 c4 20             	add    $0x20,%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
	...

00801dc0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 18             	sub    $0x18,%esp
  801dc6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dc9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801dcc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	89 04 24             	mov    %eax,(%esp)
  801dd5:	e8 96 f7 ff ff       	call   801570 <fd2data>
  801dda:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ddc:	c7 44 24 04 1b 2e 80 	movl   $0x802e1b,0x4(%esp)
  801de3:	00 
  801de4:	89 34 24             	mov    %esi,(%esp)
  801de7:	e8 6f eb ff ff       	call   80095b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dec:	8b 43 04             	mov    0x4(%ebx),%eax
  801def:	2b 03                	sub    (%ebx),%eax
  801df1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801df7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801dfe:	00 00 00 
	stat->st_dev = &devpipe;
  801e01:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801e08:	30 80 00 
	return 0;
}
  801e0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e10:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e13:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e16:	89 ec                	mov    %ebp,%esp
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    

00801e1a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	53                   	push   %ebx
  801e1e:	83 ec 14             	sub    $0x14,%esp
  801e21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2f:	e8 e5 f0 ff ff       	call   800f19 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e34:	89 1c 24             	mov    %ebx,(%esp)
  801e37:	e8 34 f7 ff ff       	call   801570 <fd2data>
  801e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e47:	e8 cd f0 ff ff       	call   800f19 <sys_page_unmap>
}
  801e4c:	83 c4 14             	add    $0x14,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    

00801e52 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 2c             	sub    $0x2c,%esp
  801e5b:	89 c7                	mov    %eax,%edi
  801e5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e60:	a1 04 40 80 00       	mov    0x804004,%eax
  801e65:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e68:	89 3c 24             	mov    %edi,(%esp)
  801e6b:	e8 04 07 00 00       	call   802574 <pageref>
  801e70:	89 c6                	mov    %eax,%esi
  801e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e75:	89 04 24             	mov    %eax,(%esp)
  801e78:	e8 f7 06 00 00       	call   802574 <pageref>
  801e7d:	39 c6                	cmp    %eax,%esi
  801e7f:	0f 94 c0             	sete   %al
  801e82:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e85:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e8b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e8e:	39 cb                	cmp    %ecx,%ebx
  801e90:	75 08                	jne    801e9a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e92:	83 c4 2c             	add    $0x2c,%esp
  801e95:	5b                   	pop    %ebx
  801e96:	5e                   	pop    %esi
  801e97:	5f                   	pop    %edi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e9a:	83 f8 01             	cmp    $0x1,%eax
  801e9d:	75 c1                	jne    801e60 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e9f:	8b 52 58             	mov    0x58(%edx),%edx
  801ea2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eaa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eae:	c7 04 24 22 2e 80 00 	movl   $0x802e22,(%esp)
  801eb5:	e8 51 e3 ff ff       	call   80020b <cprintf>
  801eba:	eb a4                	jmp    801e60 <_pipeisclosed+0xe>

00801ebc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	57                   	push   %edi
  801ec0:	56                   	push   %esi
  801ec1:	53                   	push   %ebx
  801ec2:	83 ec 2c             	sub    $0x2c,%esp
  801ec5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ec8:	89 34 24             	mov    %esi,(%esp)
  801ecb:	e8 a0 f6 ff ff       	call   801570 <fd2data>
  801ed0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ed7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801edb:	75 50                	jne    801f2d <devpipe_write+0x71>
  801edd:	eb 5c                	jmp    801f3b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801edf:	89 da                	mov    %ebx,%edx
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	e8 6a ff ff ff       	call   801e52 <_pipeisclosed>
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	75 53                	jne    801f3f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eec:	e8 3b ef ff ff       	call   800e2c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ef1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ef4:	8b 13                	mov    (%ebx),%edx
  801ef6:	83 c2 20             	add    $0x20,%edx
  801ef9:	39 d0                	cmp    %edx,%eax
  801efb:	73 e2                	jae    801edf <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801efd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f00:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  801f04:	88 55 e7             	mov    %dl,-0x19(%ebp)
  801f07:	89 c2                	mov    %eax,%edx
  801f09:	c1 fa 1f             	sar    $0x1f,%edx
  801f0c:	c1 ea 1b             	shr    $0x1b,%edx
  801f0f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801f12:	83 e1 1f             	and    $0x1f,%ecx
  801f15:	29 d1                	sub    %edx,%ecx
  801f17:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  801f1b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  801f1f:	83 c0 01             	add    $0x1,%eax
  801f22:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f25:	83 c7 01             	add    $0x1,%edi
  801f28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f2b:	74 0e                	je     801f3b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f2d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f30:	8b 13                	mov    (%ebx),%edx
  801f32:	83 c2 20             	add    $0x20,%edx
  801f35:	39 d0                	cmp    %edx,%eax
  801f37:	73 a6                	jae    801edf <devpipe_write+0x23>
  801f39:	eb c2                	jmp    801efd <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f3b:	89 f8                	mov    %edi,%eax
  801f3d:	eb 05                	jmp    801f44 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f44:	83 c4 2c             	add    $0x2c,%esp
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 28             	sub    $0x28,%esp
  801f52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f58:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f5b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f5e:	89 3c 24             	mov    %edi,(%esp)
  801f61:	e8 0a f6 ff ff       	call   801570 <fd2data>
  801f66:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f68:	be 00 00 00 00       	mov    $0x0,%esi
  801f6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f71:	75 47                	jne    801fba <devpipe_read+0x6e>
  801f73:	eb 52                	jmp    801fc7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	eb 5e                	jmp    801fd7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f79:	89 da                	mov    %ebx,%edx
  801f7b:	89 f8                	mov    %edi,%eax
  801f7d:	8d 76 00             	lea    0x0(%esi),%esi
  801f80:	e8 cd fe ff ff       	call   801e52 <_pipeisclosed>
  801f85:	85 c0                	test   %eax,%eax
  801f87:	75 49                	jne    801fd2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  801f89:	e8 9e ee ff ff       	call   800e2c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f8e:	8b 03                	mov    (%ebx),%eax
  801f90:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f93:	74 e4                	je     801f79 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f95:	89 c2                	mov    %eax,%edx
  801f97:	c1 fa 1f             	sar    $0x1f,%edx
  801f9a:	c1 ea 1b             	shr    $0x1b,%edx
  801f9d:	01 d0                	add    %edx,%eax
  801f9f:	83 e0 1f             	and    $0x1f,%eax
  801fa2:	29 d0                	sub    %edx,%eax
  801fa4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fac:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801faf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb2:	83 c6 01             	add    $0x1,%esi
  801fb5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fb8:	74 0d                	je     801fc7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  801fba:	8b 03                	mov    (%ebx),%eax
  801fbc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fbf:	75 d4                	jne    801f95 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc1:	85 f6                	test   %esi,%esi
  801fc3:	75 b0                	jne    801f75 <devpipe_read+0x29>
  801fc5:	eb b2                	jmp    801f79 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc7:	89 f0                	mov    %esi,%eax
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	eb 05                	jmp    801fd7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fd2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fdd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fe0:	89 ec                	mov    %ebp,%esp
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	83 ec 48             	sub    $0x48,%esp
  801fea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ff0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ff3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ff6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ff9:	89 04 24             	mov    %eax,(%esp)
  801ffc:	e8 8a f5 ff ff       	call   80158b <fd_alloc>
  802001:	89 c3                	mov    %eax,%ebx
  802003:	85 c0                	test   %eax,%eax
  802005:	0f 88 45 01 00 00    	js     802150 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802012:	00 
  802013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802021:	e8 36 ee ff ff       	call   800e5c <sys_page_alloc>
  802026:	89 c3                	mov    %eax,%ebx
  802028:	85 c0                	test   %eax,%eax
  80202a:	0f 88 20 01 00 00    	js     802150 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802030:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802033:	89 04 24             	mov    %eax,(%esp)
  802036:	e8 50 f5 ff ff       	call   80158b <fd_alloc>
  80203b:	89 c3                	mov    %eax,%ebx
  80203d:	85 c0                	test   %eax,%eax
  80203f:	0f 88 f8 00 00 00    	js     80213d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802045:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80204c:	00 
  80204d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802050:	89 44 24 04          	mov    %eax,0x4(%esp)
  802054:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80205b:	e8 fc ed ff ff       	call   800e5c <sys_page_alloc>
  802060:	89 c3                	mov    %eax,%ebx
  802062:	85 c0                	test   %eax,%eax
  802064:	0f 88 d3 00 00 00    	js     80213d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80206a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206d:	89 04 24             	mov    %eax,(%esp)
  802070:	e8 fb f4 ff ff       	call   801570 <fd2data>
  802075:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802077:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80207e:	00 
  80207f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802083:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208a:	e8 cd ed ff ff       	call   800e5c <sys_page_alloc>
  80208f:	89 c3                	mov    %eax,%ebx
  802091:	85 c0                	test   %eax,%eax
  802093:	0f 88 91 00 00 00    	js     80212a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802099:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80209c:	89 04 24             	mov    %eax,(%esp)
  80209f:	e8 cc f4 ff ff       	call   801570 <fd2data>
  8020a4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020ab:	00 
  8020ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020b7:	00 
  8020b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c3:	e8 f3 ed ff ff       	call   800ebb <sys_page_map>
  8020c8:	89 c3                	mov    %eax,%ebx
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	78 4c                	js     80211a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020ce:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8020d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020e3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8020e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020f1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 5d f4 ff ff       	call   801560 <fd2num>
  802103:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802105:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802108:	89 04 24             	mov    %eax,(%esp)
  80210b:	e8 50 f4 ff ff       	call   801560 <fd2num>
  802110:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802113:	bb 00 00 00 00       	mov    $0x0,%ebx
  802118:	eb 36                	jmp    802150 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80211a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802125:	e8 ef ed ff ff       	call   800f19 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80212a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80212d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802138:	e8 dc ed ff ff       	call   800f19 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80213d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802140:	89 44 24 04          	mov    %eax,0x4(%esp)
  802144:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80214b:	e8 c9 ed ff ff       	call   800f19 <sys_page_unmap>
    err:
	return r;
}
  802150:	89 d8                	mov    %ebx,%eax
  802152:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802155:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802158:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80215b:	89 ec                	mov    %ebp,%esp
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216c:	8b 45 08             	mov    0x8(%ebp),%eax
  80216f:	89 04 24             	mov    %eax,(%esp)
  802172:	e8 87 f4 ff ff       	call   8015fe <fd_lookup>
  802177:	85 c0                	test   %eax,%eax
  802179:	78 15                	js     802190 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80217b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217e:	89 04 24             	mov    %eax,(%esp)
  802181:	e8 ea f3 ff ff       	call   801570 <fd2data>
	return _pipeisclosed(fd, p);
  802186:	89 c2                	mov    %eax,%edx
  802188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218b:	e8 c2 fc ff ff       	call   801e52 <_pipeisclosed>
}
  802190:	c9                   	leave  
  802191:	c3                   	ret    
	...

008021a0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    

008021aa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021b0:	c7 44 24 04 3a 2e 80 	movl   $0x802e3a,0x4(%esp)
  8021b7:	00 
  8021b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021bb:	89 04 24             	mov    %eax,(%esp)
  8021be:	e8 98 e7 ff ff       	call   80095b <strcpy>
	return 0;
}
  8021c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c8:	c9                   	leave  
  8021c9:	c3                   	ret    

008021ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	57                   	push   %edi
  8021ce:	56                   	push   %esi
  8021cf:	53                   	push   %ebx
  8021d0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d6:	be 00 00 00 00       	mov    $0x0,%esi
  8021db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021df:	74 43                	je     802224 <devcons_write+0x5a>
  8021e1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ef:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8021f1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021f4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021f9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802200:	03 45 0c             	add    0xc(%ebp),%eax
  802203:	89 44 24 04          	mov    %eax,0x4(%esp)
  802207:	89 3c 24             	mov    %edi,(%esp)
  80220a:	e8 3d e9 ff ff       	call   800b4c <memmove>
		sys_cputs(buf, m);
  80220f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	e8 25 eb ff ff       	call   800d40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221b:	01 de                	add    %ebx,%esi
  80221d:	89 f0                	mov    %esi,%eax
  80221f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802222:	72 c8                	jb     8021ec <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802224:	89 f0                	mov    %esi,%eax
  802226:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80222c:	5b                   	pop    %ebx
  80222d:	5e                   	pop    %esi
  80222e:	5f                   	pop    %edi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    

00802231 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802237:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80223c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802240:	75 07                	jne    802249 <devcons_read+0x18>
  802242:	eb 31                	jmp    802275 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802244:	e8 e3 eb ff ff       	call   800e2c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	e8 1a eb ff ff       	call   800d6f <sys_cgetc>
  802255:	85 c0                	test   %eax,%eax
  802257:	74 eb                	je     802244 <devcons_read+0x13>
  802259:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 16                	js     802275 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80225f:	83 f8 04             	cmp    $0x4,%eax
  802262:	74 0c                	je     802270 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802264:	8b 45 0c             	mov    0xc(%ebp),%eax
  802267:	88 10                	mov    %dl,(%eax)
	return 1;
  802269:	b8 01 00 00 00       	mov    $0x1,%eax
  80226e:	eb 05                	jmp    802275 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802270:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    

00802277 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80227d:	8b 45 08             	mov    0x8(%ebp),%eax
  802280:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802283:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80228a:	00 
  80228b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80228e:	89 04 24             	mov    %eax,(%esp)
  802291:	e8 aa ea ff ff       	call   800d40 <sys_cputs>
}
  802296:	c9                   	leave  
  802297:	c3                   	ret    

00802298 <getchar>:

int
getchar(void)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80229e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022a5:	00 
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b4:	e8 05 f6 ff ff       	call   8018be <read>
	if (r < 0)
  8022b9:	85 c0                	test   %eax,%eax
  8022bb:	78 0f                	js     8022cc <getchar+0x34>
		return r;
	if (r < 1)
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	7e 06                	jle    8022c7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8022c1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022c5:	eb 05                	jmp    8022cc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022c7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022cc:	c9                   	leave  
  8022cd:	c3                   	ret    

008022ce <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022db:	8b 45 08             	mov    0x8(%ebp),%eax
  8022de:	89 04 24             	mov    %eax,(%esp)
  8022e1:	e8 18 f3 ff ff       	call   8015fe <fd_lookup>
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	78 11                	js     8022fb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ed:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022f3:	39 10                	cmp    %edx,(%eax)
  8022f5:	0f 94 c0             	sete   %al
  8022f8:	0f b6 c0             	movzbl %al,%eax
}
  8022fb:	c9                   	leave  
  8022fc:	c3                   	ret    

008022fd <opencons>:

int
opencons(void)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802303:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802306:	89 04 24             	mov    %eax,(%esp)
  802309:	e8 7d f2 ff ff       	call   80158b <fd_alloc>
  80230e:	85 c0                	test   %eax,%eax
  802310:	78 3c                	js     80234e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802312:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802319:	00 
  80231a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802321:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802328:	e8 2f eb ff ff       	call   800e5c <sys_page_alloc>
  80232d:	85 c0                	test   %eax,%eax
  80232f:	78 1d                	js     80234e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802331:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80233c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802346:	89 04 24             	mov    %eax,(%esp)
  802349:	e8 12 f2 ff ff       	call   801560 <fd2num>
}
  80234e:	c9                   	leave  
  80234f:	c3                   	ret    

00802350 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	56                   	push   %esi
  802354:	53                   	push   %ebx
  802355:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802358:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80235b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802361:	e8 96 ea ff ff       	call   800dfc <sys_getenvid>
  802366:	8b 55 0c             	mov    0xc(%ebp),%edx
  802369:	89 54 24 10          	mov    %edx,0x10(%esp)
  80236d:	8b 55 08             	mov    0x8(%ebp),%edx
  802370:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802374:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237c:	c7 04 24 48 2e 80 00 	movl   $0x802e48,(%esp)
  802383:	e8 83 de ff ff       	call   80020b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802388:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238c:	8b 45 10             	mov    0x10(%ebp),%eax
  80238f:	89 04 24             	mov    %eax,(%esp)
  802392:	e8 13 de ff ff       	call   8001aa <vcprintf>
	cprintf("\n");
  802397:	c7 04 24 df 2b 80 00 	movl   $0x802bdf,(%esp)
  80239e:	e8 68 de ff ff       	call   80020b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023a3:	cc                   	int3   
  8023a4:	eb fd                	jmp    8023a3 <_panic+0x53>
	...

008023a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023ae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023b5:	75 3c                	jne    8023f3 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8023b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023be:	00 
  8023bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023c6:	ee 
  8023c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ce:	e8 89 ea ff ff       	call   800e5c <sys_page_alloc>
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	79 1c                	jns    8023f3 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8023d7:	c7 44 24 08 6c 2e 80 	movl   $0x802e6c,0x8(%esp)
  8023de:	00 
  8023df:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8023e6:	00 
  8023e7:	c7 04 24 d0 2e 80 00 	movl   $0x802ed0,(%esp)
  8023ee:	e8 5d ff ff ff       	call   802350 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f6:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8023fb:	c7 44 24 04 34 24 80 	movl   $0x802434,0x4(%esp)
  802402:	00 
  802403:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80240a:	e8 24 ec ff ff       	call   801033 <sys_env_set_pgfault_upcall>
  80240f:	85 c0                	test   %eax,%eax
  802411:	79 1c                	jns    80242f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802413:	c7 44 24 08 98 2e 80 	movl   $0x802e98,0x8(%esp)
  80241a:	00 
  80241b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  802422:	00 
  802423:	c7 04 24 d0 2e 80 00 	movl   $0x802ed0,(%esp)
  80242a:	e8 21 ff ff ff       	call   802350 <_panic>
}
  80242f:	c9                   	leave  
  802430:	c3                   	ret    
  802431:	00 00                	add    %al,(%eax)
	...

00802434 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802434:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802435:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80243a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80243c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80243f:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  802443:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802448:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80244c:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80244e:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802451:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  802452:	83 c4 04             	add    $0x4,%esp
    popfl
  802455:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  802456:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  802457:	c3                   	ret    

00802458 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	56                   	push   %esi
  80245c:	53                   	push   %ebx
  80245d:	83 ec 10             	sub    $0x10,%esp
  802460:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802463:	8b 45 0c             	mov    0xc(%ebp),%eax
  802466:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802469:	85 db                	test   %ebx,%ebx
  80246b:	74 06                	je     802473 <ipc_recv+0x1b>
  80246d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  802473:	85 f6                	test   %esi,%esi
  802475:	74 06                	je     80247d <ipc_recv+0x25>
  802477:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  80247d:	85 c0                	test   %eax,%eax
  80247f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802484:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  802487:	89 04 24             	mov    %eax,(%esp)
  80248a:	e8 36 ec ff ff       	call   8010c5 <sys_ipc_recv>
    if (ret) return ret;
  80248f:	85 c0                	test   %eax,%eax
  802491:	75 24                	jne    8024b7 <ipc_recv+0x5f>
    if (from_env_store)
  802493:	85 db                	test   %ebx,%ebx
  802495:	74 0a                	je     8024a1 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  802497:	a1 04 40 80 00       	mov    0x804004,%eax
  80249c:	8b 40 74             	mov    0x74(%eax),%eax
  80249f:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8024a1:	85 f6                	test   %esi,%esi
  8024a3:	74 0a                	je     8024af <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8024a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8024aa:	8b 40 78             	mov    0x78(%eax),%eax
  8024ad:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8024af:	a1 04 40 80 00       	mov    0x804004,%eax
  8024b4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024b7:	83 c4 10             	add    $0x10,%esp
  8024ba:	5b                   	pop    %ebx
  8024bb:	5e                   	pop    %esi
  8024bc:	5d                   	pop    %ebp
  8024bd:	c3                   	ret    

008024be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8024ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8024d0:	85 db                	test   %ebx,%ebx
  8024d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024d7:	0f 44 d8             	cmove  %eax,%ebx
  8024da:	eb 2a                	jmp    802506 <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8024dc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024df:	74 20                	je     802501 <ipc_send+0x43>
  8024e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024e5:	c7 44 24 08 de 2e 80 	movl   $0x802ede,0x8(%esp)
  8024ec:	00 
  8024ed:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8024f4:	00 
  8024f5:	c7 04 24 f5 2e 80 00 	movl   $0x802ef5,(%esp)
  8024fc:	e8 4f fe ff ff       	call   802350 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802501:	e8 26 e9 ff ff       	call   800e2c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802506:	8b 45 14             	mov    0x14(%ebp),%eax
  802509:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80250d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802511:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802515:	89 34 24             	mov    %esi,(%esp)
  802518:	e8 74 eb ff ff       	call   801091 <sys_ipc_try_send>
  80251d:	85 c0                	test   %eax,%eax
  80251f:	75 bb                	jne    8024dc <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    

00802529 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802529:	55                   	push   %ebp
  80252a:	89 e5                	mov    %esp,%ebp
  80252c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80252f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802534:	39 c8                	cmp    %ecx,%eax
  802536:	74 19                	je     802551 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802538:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80253d:	89 c2                	mov    %eax,%edx
  80253f:	c1 e2 07             	shl    $0x7,%edx
  802542:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802548:	8b 52 50             	mov    0x50(%edx),%edx
  80254b:	39 ca                	cmp    %ecx,%edx
  80254d:	75 14                	jne    802563 <ipc_find_env+0x3a>
  80254f:	eb 05                	jmp    802556 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802551:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802556:	c1 e0 07             	shl    $0x7,%eax
  802559:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80255e:	8b 40 40             	mov    0x40(%eax),%eax
  802561:	eb 0e                	jmp    802571 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802563:	83 c0 01             	add    $0x1,%eax
  802566:	3d 00 04 00 00       	cmp    $0x400,%eax
  80256b:	75 d0                	jne    80253d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80256d:	66 b8 00 00          	mov    $0x0,%ax
}
  802571:	5d                   	pop    %ebp
  802572:	c3                   	ret    
	...

00802574 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
  802577:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80257a:	89 d0                	mov    %edx,%eax
  80257c:	c1 e8 16             	shr    $0x16,%eax
  80257f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802586:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258b:	f6 c1 01             	test   $0x1,%cl
  80258e:	74 1d                	je     8025ad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802590:	c1 ea 0c             	shr    $0xc,%edx
  802593:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80259a:	f6 c2 01             	test   $0x1,%dl
  80259d:	74 0e                	je     8025ad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80259f:	c1 ea 0c             	shr    $0xc,%edx
  8025a2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025a9:	ef 
  8025aa:	0f b7 c0             	movzwl %ax,%eax
}
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    
	...

008025b0 <__udivdi3>:
  8025b0:	83 ec 1c             	sub    $0x1c,%esp
  8025b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8025b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8025bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8025bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8025c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8025c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8025cb:	85 ff                	test   %edi,%edi
  8025cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8025d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025d5:	89 cd                	mov    %ecx,%ebp
  8025d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025db:	75 33                	jne    802610 <__udivdi3+0x60>
  8025dd:	39 f1                	cmp    %esi,%ecx
  8025df:	77 57                	ja     802638 <__udivdi3+0x88>
  8025e1:	85 c9                	test   %ecx,%ecx
  8025e3:	75 0b                	jne    8025f0 <__udivdi3+0x40>
  8025e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ea:	31 d2                	xor    %edx,%edx
  8025ec:	f7 f1                	div    %ecx
  8025ee:	89 c1                	mov    %eax,%ecx
  8025f0:	89 f0                	mov    %esi,%eax
  8025f2:	31 d2                	xor    %edx,%edx
  8025f4:	f7 f1                	div    %ecx
  8025f6:	89 c6                	mov    %eax,%esi
  8025f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025fc:	f7 f1                	div    %ecx
  8025fe:	89 f2                	mov    %esi,%edx
  802600:	8b 74 24 10          	mov    0x10(%esp),%esi
  802604:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802608:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80260c:	83 c4 1c             	add    $0x1c,%esp
  80260f:	c3                   	ret    
  802610:	31 d2                	xor    %edx,%edx
  802612:	31 c0                	xor    %eax,%eax
  802614:	39 f7                	cmp    %esi,%edi
  802616:	77 e8                	ja     802600 <__udivdi3+0x50>
  802618:	0f bd cf             	bsr    %edi,%ecx
  80261b:	83 f1 1f             	xor    $0x1f,%ecx
  80261e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802622:	75 2c                	jne    802650 <__udivdi3+0xa0>
  802624:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802628:	76 04                	jbe    80262e <__udivdi3+0x7e>
  80262a:	39 f7                	cmp    %esi,%edi
  80262c:	73 d2                	jae    802600 <__udivdi3+0x50>
  80262e:	31 d2                	xor    %edx,%edx
  802630:	b8 01 00 00 00       	mov    $0x1,%eax
  802635:	eb c9                	jmp    802600 <__udivdi3+0x50>
  802637:	90                   	nop
  802638:	89 f2                	mov    %esi,%edx
  80263a:	f7 f1                	div    %ecx
  80263c:	31 d2                	xor    %edx,%edx
  80263e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802642:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802646:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80264a:	83 c4 1c             	add    $0x1c,%esp
  80264d:	c3                   	ret    
  80264e:	66 90                	xchg   %ax,%ax
  802650:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802655:	b8 20 00 00 00       	mov    $0x20,%eax
  80265a:	89 ea                	mov    %ebp,%edx
  80265c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802660:	d3 e7                	shl    %cl,%edi
  802662:	89 c1                	mov    %eax,%ecx
  802664:	d3 ea                	shr    %cl,%edx
  802666:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80266b:	09 fa                	or     %edi,%edx
  80266d:	89 f7                	mov    %esi,%edi
  80266f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802673:	89 f2                	mov    %esi,%edx
  802675:	8b 74 24 08          	mov    0x8(%esp),%esi
  802679:	d3 e5                	shl    %cl,%ebp
  80267b:	89 c1                	mov    %eax,%ecx
  80267d:	d3 ef                	shr    %cl,%edi
  80267f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802684:	d3 e2                	shl    %cl,%edx
  802686:	89 c1                	mov    %eax,%ecx
  802688:	d3 ee                	shr    %cl,%esi
  80268a:	09 d6                	or     %edx,%esi
  80268c:	89 fa                	mov    %edi,%edx
  80268e:	89 f0                	mov    %esi,%eax
  802690:	f7 74 24 0c          	divl   0xc(%esp)
  802694:	89 d7                	mov    %edx,%edi
  802696:	89 c6                	mov    %eax,%esi
  802698:	f7 e5                	mul    %ebp
  80269a:	39 d7                	cmp    %edx,%edi
  80269c:	72 22                	jb     8026c0 <__udivdi3+0x110>
  80269e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8026a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026a7:	d3 e5                	shl    %cl,%ebp
  8026a9:	39 c5                	cmp    %eax,%ebp
  8026ab:	73 04                	jae    8026b1 <__udivdi3+0x101>
  8026ad:	39 d7                	cmp    %edx,%edi
  8026af:	74 0f                	je     8026c0 <__udivdi3+0x110>
  8026b1:	89 f0                	mov    %esi,%eax
  8026b3:	31 d2                	xor    %edx,%edx
  8026b5:	e9 46 ff ff ff       	jmp    802600 <__udivdi3+0x50>
  8026ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8026c3:	31 d2                	xor    %edx,%edx
  8026c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026d1:	83 c4 1c             	add    $0x1c,%esp
  8026d4:	c3                   	ret    
	...

008026e0 <__umoddi3>:
  8026e0:	83 ec 1c             	sub    $0x1c,%esp
  8026e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8026e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8026eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8026ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8026f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8026f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8026fb:	85 ed                	test   %ebp,%ebp
  8026fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802701:	89 44 24 08          	mov    %eax,0x8(%esp)
  802705:	89 cf                	mov    %ecx,%edi
  802707:	89 04 24             	mov    %eax,(%esp)
  80270a:	89 f2                	mov    %esi,%edx
  80270c:	75 1a                	jne    802728 <__umoddi3+0x48>
  80270e:	39 f1                	cmp    %esi,%ecx
  802710:	76 4e                	jbe    802760 <__umoddi3+0x80>
  802712:	f7 f1                	div    %ecx
  802714:	89 d0                	mov    %edx,%eax
  802716:	31 d2                	xor    %edx,%edx
  802718:	8b 74 24 10          	mov    0x10(%esp),%esi
  80271c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802720:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802724:	83 c4 1c             	add    $0x1c,%esp
  802727:	c3                   	ret    
  802728:	39 f5                	cmp    %esi,%ebp
  80272a:	77 54                	ja     802780 <__umoddi3+0xa0>
  80272c:	0f bd c5             	bsr    %ebp,%eax
  80272f:	83 f0 1f             	xor    $0x1f,%eax
  802732:	89 44 24 04          	mov    %eax,0x4(%esp)
  802736:	75 60                	jne    802798 <__umoddi3+0xb8>
  802738:	3b 0c 24             	cmp    (%esp),%ecx
  80273b:	0f 87 07 01 00 00    	ja     802848 <__umoddi3+0x168>
  802741:	89 f2                	mov    %esi,%edx
  802743:	8b 34 24             	mov    (%esp),%esi
  802746:	29 ce                	sub    %ecx,%esi
  802748:	19 ea                	sbb    %ebp,%edx
  80274a:	89 34 24             	mov    %esi,(%esp)
  80274d:	8b 04 24             	mov    (%esp),%eax
  802750:	8b 74 24 10          	mov    0x10(%esp),%esi
  802754:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802758:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80275c:	83 c4 1c             	add    $0x1c,%esp
  80275f:	c3                   	ret    
  802760:	85 c9                	test   %ecx,%ecx
  802762:	75 0b                	jne    80276f <__umoddi3+0x8f>
  802764:	b8 01 00 00 00       	mov    $0x1,%eax
  802769:	31 d2                	xor    %edx,%edx
  80276b:	f7 f1                	div    %ecx
  80276d:	89 c1                	mov    %eax,%ecx
  80276f:	89 f0                	mov    %esi,%eax
  802771:	31 d2                	xor    %edx,%edx
  802773:	f7 f1                	div    %ecx
  802775:	8b 04 24             	mov    (%esp),%eax
  802778:	f7 f1                	div    %ecx
  80277a:	eb 98                	jmp    802714 <__umoddi3+0x34>
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	89 f2                	mov    %esi,%edx
  802782:	8b 74 24 10          	mov    0x10(%esp),%esi
  802786:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80278a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80278e:	83 c4 1c             	add    $0x1c,%esp
  802791:	c3                   	ret    
  802792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802798:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80279d:	89 e8                	mov    %ebp,%eax
  80279f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8027a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8027a8:	89 fa                	mov    %edi,%edx
  8027aa:	d3 e0                	shl    %cl,%eax
  8027ac:	89 e9                	mov    %ebp,%ecx
  8027ae:	d3 ea                	shr    %cl,%edx
  8027b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027b5:	09 c2                	or     %eax,%edx
  8027b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027bb:	89 14 24             	mov    %edx,(%esp)
  8027be:	89 f2                	mov    %esi,%edx
  8027c0:	d3 e7                	shl    %cl,%edi
  8027c2:	89 e9                	mov    %ebp,%ecx
  8027c4:	d3 ea                	shr    %cl,%edx
  8027c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027cf:	d3 e6                	shl    %cl,%esi
  8027d1:	89 e9                	mov    %ebp,%ecx
  8027d3:	d3 e8                	shr    %cl,%eax
  8027d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027da:	09 f0                	or     %esi,%eax
  8027dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027e0:	f7 34 24             	divl   (%esp)
  8027e3:	d3 e6                	shl    %cl,%esi
  8027e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027e9:	89 d6                	mov    %edx,%esi
  8027eb:	f7 e7                	mul    %edi
  8027ed:	39 d6                	cmp    %edx,%esi
  8027ef:	89 c1                	mov    %eax,%ecx
  8027f1:	89 d7                	mov    %edx,%edi
  8027f3:	72 3f                	jb     802834 <__umoddi3+0x154>
  8027f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027f9:	72 35                	jb     802830 <__umoddi3+0x150>
  8027fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ff:	29 c8                	sub    %ecx,%eax
  802801:	19 fe                	sbb    %edi,%esi
  802803:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802808:	89 f2                	mov    %esi,%edx
  80280a:	d3 e8                	shr    %cl,%eax
  80280c:	89 e9                	mov    %ebp,%ecx
  80280e:	d3 e2                	shl    %cl,%edx
  802810:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802815:	09 d0                	or     %edx,%eax
  802817:	89 f2                	mov    %esi,%edx
  802819:	d3 ea                	shr    %cl,%edx
  80281b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80281f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802823:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802827:	83 c4 1c             	add    $0x1c,%esp
  80282a:	c3                   	ret    
  80282b:	90                   	nop
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	39 d6                	cmp    %edx,%esi
  802832:	75 c7                	jne    8027fb <__umoddi3+0x11b>
  802834:	89 d7                	mov    %edx,%edi
  802836:	89 c1                	mov    %eax,%ecx
  802838:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80283c:	1b 3c 24             	sbb    (%esp),%edi
  80283f:	eb ba                	jmp    8027fb <__umoddi3+0x11b>
  802841:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802848:	39 f5                	cmp    %esi,%ebp
  80284a:	0f 82 f1 fe ff ff    	jb     802741 <__umoddi3+0x61>
  802850:	e9 f8 fe ff ff       	jmp    80274d <__umoddi3+0x6d>
