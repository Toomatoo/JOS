
obj/user/forktree:     file format elf32-i386


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
  80003e:	e8 a9 0d 00 00       	call   800dec <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800052:	e8 ac 01 00 00       	call   800203 <cprintf>

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
  800093:	e8 68 08 00 00       	call   800900 <strlen>
  800098:	83 f8 02             	cmp    $0x2,%eax
  80009b:	7f 41                	jg     8000de <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000aa:	c7 44 24 08 51 19 80 	movl   $0x801951,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b9:	00 
  8000ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 12 08 00 00       	call   8008d7 <snprintf>
	if (fork() == 0) {
  8000c5:	e8 2c 12 00 00       	call   8012f6 <fork>
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
  8000ee:	c7 04 24 50 19 80 00 	movl   $0x801950,(%esp)
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
  80010e:	e8 d9 0c 00 00       	call   800dec <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	c1 e0 07             	shl    $0x7,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x34>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 31 0c 00 00       	call   800d8f <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 14             	sub    $0x14,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800173:	83 c0 01             	add    $0x1,%eax
  800176:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	75 19                	jne    800198 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800186:	00 
  800187:	8d 43 08             	lea    0x8(%ebx),%eax
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 9e 0b 00 00       	call   800d30 <sys_cputs>
		b->idx = 0;
  800192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800198:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019c:	83 c4 14             	add    $0x14,%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b2:	00 00 00 
	b.cnt = 0;
  8001b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	c7 04 24 60 01 80 00 	movl   $0x800160,(%esp)
  8001de:	e8 97 01 00 00       	call   80037a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 35 0b 00 00       	call   800d30 <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	8b 45 08             	mov    0x8(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 87 ff ff ff       	call   8001a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	b8 00 00 00 00       	mov    $0x0,%eax
  800245:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800248:	72 11                	jb     80025b <printnum+0x3b>
  80024a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800250:	76 09                	jbe    80025b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	85 db                	test   %ebx,%ebx
  800257:	7f 51                	jg     8002aa <printnum+0x8a>
  800259:	eb 5e                	jmp    8002b9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800266:	8b 45 10             	mov    0x10(%ebp),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800271:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800275:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027c:	00 
  80027d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028a:	e8 01 14 00 00       	call   801690 <__udivdi3>
  80028f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800293:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029e:	89 fa                	mov    %edi,%edx
  8002a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a3:	e8 78 ff ff ff       	call   800220 <printnum>
  8002a8:	eb 0f                	jmp    8002b9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ae:	89 34 24             	mov    %esi,(%esp)
  8002b1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b4:	83 eb 01             	sub    $0x1,%ebx
  8002b7:	75 f1                	jne    8002aa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 de 14 00 00       	call   8017c0 <__umoddi3>
  8002e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e6:	0f be 80 60 19 80 00 	movsbl 0x801960(%eax),%eax
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002f3:	83 c4 3c             	add    $0x3c,%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fe:	83 fa 01             	cmp    $0x1,%edx
  800301:	7e 0e                	jle    800311 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 08             	lea    0x8(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	8b 52 04             	mov    0x4(%edx),%edx
  80030f:	eb 22                	jmp    800333 <getuint+0x38>
	else if (lflag)
  800311:	85 d2                	test   %edx,%edx
  800313:	74 10                	je     800325 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800315:	8b 10                	mov    (%eax),%edx
  800317:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031a:	89 08                	mov    %ecx,(%eax)
  80031c:	8b 02                	mov    (%edx),%eax
  80031e:	ba 00 00 00 00       	mov    $0x0,%edx
  800323:	eb 0e                	jmp    800333 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 0a                	jae    800350 <sprintputch+0x1b>
		*b->buf++ = ch;
  800346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800349:	88 0a                	mov    %cl,(%edx)
  80034b:	83 c2 01             	add    $0x1,%edx
  80034e:	89 10                	mov    %edx,(%eax)
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800358:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035f:	8b 45 10             	mov    0x10(%ebp),%eax
  800362:	89 44 24 08          	mov    %eax,0x8(%esp)
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	89 04 24             	mov    %eax,(%esp)
  800373:	e8 02 00 00 00       	call   80037a <vprintfmt>
	va_end(ap);
}
  800378:	c9                   	leave  
  800379:	c3                   	ret    

0080037a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
  800380:	83 ec 5c             	sub    $0x5c,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800386:	8b 75 10             	mov    0x10(%ebp),%esi
  800389:	eb 12                	jmp    80039d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038b:	85 c0                	test   %eax,%eax
  80038d:	0f 84 e4 04 00 00    	je     800877 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800393:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039d:	0f b6 06             	movzbl (%esi),%eax
  8003a0:	83 c6 01             	add    $0x1,%esi
  8003a3:	83 f8 25             	cmp    $0x25,%eax
  8003a6:	75 e3                	jne    80038b <vprintfmt+0x11>
  8003a8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003ac:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003b3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003b8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003c7:	eb 2b                	jmp    8003f4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003cc:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003d0:	eb 22                	jmp    8003f4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003d9:	eb 19                	jmp    8003f4 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003de:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003e5:	eb 0d                	jmp    8003f4 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ed:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	0f b6 06             	movzbl (%esi),%eax
  8003f7:	0f b6 d0             	movzbl %al,%edx
  8003fa:	8d 7e 01             	lea    0x1(%esi),%edi
  8003fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800400:	83 e8 23             	sub    $0x23,%eax
  800403:	3c 55                	cmp    $0x55,%al
  800405:	0f 87 46 04 00 00    	ja     800851 <vprintfmt+0x4d7>
  80040b:	0f b6 c0             	movzbl %al,%eax
  80040e:	ff 24 85 40 1a 80 00 	jmp    *0x801a40(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800415:	83 ea 30             	sub    $0x30,%edx
  800418:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80041b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80041f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800425:	83 fa 09             	cmp    $0x9,%edx
  800428:	77 4a                	ja     800474 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800430:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800433:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800437:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80043a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80043d:	83 fa 09             	cmp    $0x9,%edx
  800440:	76 eb                	jbe    80042d <vprintfmt+0xb3>
  800442:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800445:	eb 2d                	jmp    800474 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800458:	eb 1a                	jmp    800474 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80045d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800461:	79 91                	jns    8003f4 <vprintfmt+0x7a>
  800463:	e9 73 ff ff ff       	jmp    8003db <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800472:	eb 80                	jmp    8003f4 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800474:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800478:	0f 89 76 ff ff ff    	jns    8003f4 <vprintfmt+0x7a>
  80047e:	e9 64 ff ff ff       	jmp    8003e7 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800489:	e9 66 ff ff ff       	jmp    8003f4 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 50 04             	lea    0x4(%eax),%edx
  800494:	89 55 14             	mov    %edx,0x14(%ebp)
  800497:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 04 24             	mov    %eax,(%esp)
  8004a0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a6:	e9 f2 fe ff ff       	jmp    80039d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004ab:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004af:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004b2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004b6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8004b9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8004bd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8004c0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8004c3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8004c7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ca:	80 f9 09             	cmp    $0x9,%cl
  8004cd:	77 1d                	ja     8004ec <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8004cf:	0f be c0             	movsbl %al,%eax
  8004d2:	6b c0 64             	imul   $0x64,%eax,%eax
  8004d5:	0f be d2             	movsbl %dl,%edx
  8004d8:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004db:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004e2:	a3 04 20 80 00       	mov    %eax,0x802004
  8004e7:	e9 b1 fe ff ff       	jmp    80039d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004ec:	c7 44 24 04 78 19 80 	movl   $0x801978,0x4(%esp)
  8004f3:	00 
  8004f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	e8 0c 05 00 00       	call   800a0b <strcmp>
  8004ff:	85 c0                	test   %eax,%eax
  800501:	75 0f                	jne    800512 <vprintfmt+0x198>
  800503:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80050a:	00 00 00 
  80050d:	e9 8b fe ff ff       	jmp    80039d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800512:	c7 44 24 04 7c 19 80 	movl   $0x80197c,0x4(%esp)
  800519:	00 
  80051a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80051d:	89 14 24             	mov    %edx,(%esp)
  800520:	e8 e6 04 00 00       	call   800a0b <strcmp>
  800525:	85 c0                	test   %eax,%eax
  800527:	75 0f                	jne    800538 <vprintfmt+0x1be>
  800529:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800530:	00 00 00 
  800533:	e9 65 fe ff ff       	jmp    80039d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800538:	c7 44 24 04 80 19 80 	movl   $0x801980,0x4(%esp)
  80053f:	00 
  800540:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800543:	89 0c 24             	mov    %ecx,(%esp)
  800546:	e8 c0 04 00 00       	call   800a0b <strcmp>
  80054b:	85 c0                	test   %eax,%eax
  80054d:	75 0f                	jne    80055e <vprintfmt+0x1e4>
  80054f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800556:	00 00 00 
  800559:	e9 3f fe ff ff       	jmp    80039d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80055e:	c7 44 24 04 84 19 80 	movl   $0x801984,0x4(%esp)
  800565:	00 
  800566:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	e8 9a 04 00 00       	call   800a0b <strcmp>
  800571:	85 c0                	test   %eax,%eax
  800573:	75 0f                	jne    800584 <vprintfmt+0x20a>
  800575:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  80057c:	00 00 00 
  80057f:	e9 19 fe ff ff       	jmp    80039d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800584:	c7 44 24 04 88 19 80 	movl   $0x801988,0x4(%esp)
  80058b:	00 
  80058c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 74 04 00 00       	call   800a0b <strcmp>
  800597:	85 c0                	test   %eax,%eax
  800599:	75 0f                	jne    8005aa <vprintfmt+0x230>
  80059b:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8005a2:	00 00 00 
  8005a5:	e9 f3 fd ff ff       	jmp    80039d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005aa:	c7 44 24 04 8c 19 80 	movl   $0x80198c,0x4(%esp)
  8005b1:	00 
  8005b2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005b5:	89 14 24             	mov    %edx,(%esp)
  8005b8:	e8 4e 04 00 00       	call   800a0b <strcmp>
  8005bd:	83 f8 01             	cmp    $0x1,%eax
  8005c0:	19 c0                	sbb    %eax,%eax
  8005c2:	f7 d0                	not    %eax
  8005c4:	83 c0 08             	add    $0x8,%eax
  8005c7:	a3 04 20 80 00       	mov    %eax,0x802004
  8005cc:	e9 cc fd ff ff       	jmp    80039d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 c2                	mov    %eax,%edx
  8005de:	c1 fa 1f             	sar    $0x1f,%edx
  8005e1:	31 d0                	xor    %edx,%eax
  8005e3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e5:	83 f8 08             	cmp    $0x8,%eax
  8005e8:	7f 0b                	jg     8005f5 <vprintfmt+0x27b>
  8005ea:	8b 14 85 a0 1b 80 00 	mov    0x801ba0(,%eax,4),%edx
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	75 23                	jne    800618 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f9:	c7 44 24 08 90 19 80 	movl   $0x801990,0x8(%esp)
  800600:	00 
  800601:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800605:	8b 7d 08             	mov    0x8(%ebp),%edi
  800608:	89 3c 24             	mov    %edi,(%esp)
  80060b:	e8 42 fd ff ff       	call   800352 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800613:	e9 85 fd ff ff       	jmp    80039d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800618:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061c:	c7 44 24 08 99 19 80 	movl   $0x801999,0x8(%esp)
  800623:	00 
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062b:	89 3c 24             	mov    %edi,(%esp)
  80062e:	e8 1f fd ff ff       	call   800352 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800636:	e9 62 fd ff ff       	jmp    80039d <vprintfmt+0x23>
  80063b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80063e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800641:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80064f:	85 f6                	test   %esi,%esi
  800651:	b8 71 19 80 00       	mov    $0x801971,%eax
  800656:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800659:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80065d:	7e 06                	jle    800665 <vprintfmt+0x2eb>
  80065f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800663:	75 13                	jne    800678 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	0f be 06             	movsbl (%esi),%eax
  800668:	83 c6 01             	add    $0x1,%esi
  80066b:	85 c0                	test   %eax,%eax
  80066d:	0f 85 94 00 00 00    	jne    800707 <vprintfmt+0x38d>
  800673:	e9 81 00 00 00       	jmp    8006f9 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800678:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067c:	89 34 24             	mov    %esi,(%esp)
  80067f:	e8 97 02 00 00       	call   80091b <strnlen>
  800684:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800687:	29 c2                	sub    %eax,%edx
  800689:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80068c:	85 d2                	test   %edx,%edx
  80068e:	7e d5                	jle    800665 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800690:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800694:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800697:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80069a:	89 d6                	mov    %edx,%esi
  80069c:	89 cf                	mov    %ecx,%edi
  80069e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a2:	89 3c 24             	mov    %edi,(%esp)
  8006a5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	83 ee 01             	sub    $0x1,%esi
  8006ab:	75 f1                	jne    80069e <vprintfmt+0x324>
  8006ad:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006b0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006b3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006b6:	eb ad                	jmp    800665 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006b8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006bc:	74 1b                	je     8006d9 <vprintfmt+0x35f>
  8006be:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006c1:	83 fa 5e             	cmp    $0x5e,%edx
  8006c4:	76 13                	jbe    8006d9 <vprintfmt+0x35f>
					putch('?', putdat);
  8006c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
  8006d7:	eb 0d                	jmp    8006e6 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e6:	83 eb 01             	sub    $0x1,%ebx
  8006e9:	0f be 06             	movsbl (%esi),%eax
  8006ec:	83 c6 01             	add    $0x1,%esi
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	75 1a                	jne    80070d <vprintfmt+0x393>
  8006f3:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800700:	7f 1c                	jg     80071e <vprintfmt+0x3a4>
  800702:	e9 96 fc ff ff       	jmp    80039d <vprintfmt+0x23>
  800707:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80070a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070d:	85 ff                	test   %edi,%edi
  80070f:	78 a7                	js     8006b8 <vprintfmt+0x33e>
  800711:	83 ef 01             	sub    $0x1,%edi
  800714:	79 a2                	jns    8006b8 <vprintfmt+0x33e>
  800716:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800719:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80071c:	eb db                	jmp    8006f9 <vprintfmt+0x37f>
  80071e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800721:	89 de                	mov    %ebx,%esi
  800723:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800731:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800733:	83 eb 01             	sub    $0x1,%ebx
  800736:	75 ee                	jne    800726 <vprintfmt+0x3ac>
  800738:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80073d:	e9 5b fc ff ff       	jmp    80039d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800742:	83 f9 01             	cmp    $0x1,%ecx
  800745:	7e 10                	jle    800757 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 50 08             	lea    0x8(%eax),%edx
  80074d:	89 55 14             	mov    %edx,0x14(%ebp)
  800750:	8b 30                	mov    (%eax),%esi
  800752:	8b 78 04             	mov    0x4(%eax),%edi
  800755:	eb 26                	jmp    80077d <vprintfmt+0x403>
	else if (lflag)
  800757:	85 c9                	test   %ecx,%ecx
  800759:	74 12                	je     80076d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 30                	mov    (%eax),%esi
  800766:	89 f7                	mov    %esi,%edi
  800768:	c1 ff 1f             	sar    $0x1f,%edi
  80076b:	eb 10                	jmp    80077d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8d 50 04             	lea    0x4(%eax),%edx
  800773:	89 55 14             	mov    %edx,0x14(%ebp)
  800776:	8b 30                	mov    (%eax),%esi
  800778:	89 f7                	mov    %esi,%edi
  80077a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80077d:	85 ff                	test   %edi,%edi
  80077f:	78 0e                	js     80078f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800781:	89 f0                	mov    %esi,%eax
  800783:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800785:	be 0a 00 00 00       	mov    $0xa,%esi
  80078a:	e9 84 00 00 00       	jmp    800813 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80078f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800793:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80079a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80079d:	89 f0                	mov    %esi,%eax
  80079f:	89 fa                	mov    %edi,%edx
  8007a1:	f7 d8                	neg    %eax
  8007a3:	83 d2 00             	adc    $0x0,%edx
  8007a6:	f7 da                	neg    %edx
			}
			base = 10;
  8007a8:	be 0a 00 00 00       	mov    $0xa,%esi
  8007ad:	eb 64                	jmp    800813 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007af:	89 ca                	mov    %ecx,%edx
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b4:	e8 42 fb ff ff       	call   8002fb <getuint>
			base = 10;
  8007b9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007be:	eb 53                	jmp    800813 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007c0:	89 ca                	mov    %ecx,%edx
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	e8 31 fb ff ff       	call   8002fb <getuint>
    			base = 8;
  8007ca:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8007cf:	eb 42                	jmp    800813 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ea:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f6:	8b 00                	mov    (%eax),%eax
  8007f8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fd:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800802:	eb 0f                	jmp    800813 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800804:	89 ca                	mov    %ecx,%edx
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
  800809:	e8 ed fa ff ff       	call   8002fb <getuint>
			base = 16;
  80080e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800813:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800817:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80081b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80081e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800822:	89 74 24 08          	mov    %esi,0x8(%esp)
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	89 da                	mov    %ebx,%edx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	e8 e9 f9 ff ff       	call   800220 <printnum>
			break;
  800837:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80083a:	e9 5e fb ff ff       	jmp    80039d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800843:	89 14 24             	mov    %edx,(%esp)
  800846:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800849:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084c:	e9 4c fb ff ff       	jmp    80039d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800851:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800855:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80085c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800863:	0f 84 34 fb ff ff    	je     80039d <vprintfmt+0x23>
  800869:	83 ee 01             	sub    $0x1,%esi
  80086c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800870:	75 f7                	jne    800869 <vprintfmt+0x4ef>
  800872:	e9 26 fb ff ff       	jmp    80039d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800877:	83 c4 5c             	add    $0x5c,%esp
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 28             	sub    $0x28,%esp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800892:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800895:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089c:	85 c0                	test   %eax,%eax
  80089e:	74 30                	je     8008d0 <vsnprintf+0x51>
  8008a0:	85 d2                	test   %edx,%edx
  8008a2:	7e 2c                	jle    8008d0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b9:	c7 04 24 35 03 80 00 	movl   $0x800335,(%esp)
  8008c0:	e8 b5 fa ff ff       	call   80037a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ce:	eb 05                	jmp    8008d5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	89 04 24             	mov    %eax,(%esp)
  8008f8:	e8 82 ff ff ff       	call   80087f <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 09                	je     800919 <strlen+0x19>
		n++;
  800910:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800913:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800917:	75 f7                	jne    800910 <strlen+0x10>
		n++;
	return n;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
  80092a:	85 c9                	test   %ecx,%ecx
  80092c:	74 1a                	je     800948 <strnlen+0x2d>
  80092e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800931:	74 15                	je     800948 <strnlen+0x2d>
  800933:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800938:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093a:	39 ca                	cmp    %ecx,%edx
  80093c:	74 0a                	je     800948 <strnlen+0x2d>
  80093e:	83 c2 01             	add    $0x1,%edx
  800941:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800946:	75 f0                	jne    800938 <strnlen+0x1d>
		n++;
	return n;
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800961:	83 c2 01             	add    $0x1,%edx
  800964:	84 c9                	test   %cl,%cl
  800966:	75 f2                	jne    80095a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	83 ec 08             	sub    $0x8,%esp
  800972:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800975:	89 1c 24             	mov    %ebx,(%esp)
  800978:	e8 83 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800980:	89 54 24 04          	mov    %edx,0x4(%esp)
  800984:	01 d8                	add    %ebx,%eax
  800986:	89 04 24             	mov    %eax,(%esp)
  800989:	e8 bd ff ff ff       	call   80094b <strcpy>
	return dst;
}
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	83 c4 08             	add    $0x8,%esp
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	85 f6                	test   %esi,%esi
  8009a6:	74 18                	je     8009c0 <strncpy+0x2a>
  8009a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ad:	0f b6 1a             	movzbl (%edx),%ebx
  8009b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	39 f1                	cmp    %esi,%ecx
  8009be:	75 ed                	jne    8009ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d3:	89 f8                	mov    %edi,%eax
  8009d5:	85 f6                	test   %esi,%esi
  8009d7:	74 2b                	je     800a04 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8009d9:	83 fe 01             	cmp    $0x1,%esi
  8009dc:	74 23                	je     800a01 <strlcpy+0x3d>
  8009de:	0f b6 0b             	movzbl (%ebx),%ecx
  8009e1:	84 c9                	test   %cl,%cl
  8009e3:	74 1c                	je     800a01 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8009e5:	83 ee 02             	sub    $0x2,%esi
  8009e8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ed:	88 08                	mov    %cl,(%eax)
  8009ef:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f2:	39 f2                	cmp    %esi,%edx
  8009f4:	74 0b                	je     800a01 <strlcpy+0x3d>
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009fd:	84 c9                	test   %cl,%cl
  8009ff:	75 ec                	jne    8009ed <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a04:	29 f8                	sub    %edi,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	84 c0                	test   %al,%al
  800a19:	74 16                	je     800a31 <strcmp+0x26>
  800a1b:	3a 02                	cmp    (%edx),%al
  800a1d:	75 12                	jne    800a31 <strcmp+0x26>
		p++, q++;
  800a1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a22:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800a26:	84 c0                	test   %al,%al
  800a28:	74 07                	je     800a31 <strcmp+0x26>
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	3a 02                	cmp    (%edx),%al
  800a2f:	74 ee                	je     800a1f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 c0             	movzbl %al,%eax
  800a34:	0f b6 12             	movzbl (%edx),%edx
  800a37:	29 d0                	sub    %edx,%eax
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4d:	85 d2                	test   %edx,%edx
  800a4f:	74 28                	je     800a79 <strncmp+0x3e>
  800a51:	0f b6 01             	movzbl (%ecx),%eax
  800a54:	84 c0                	test   %al,%al
  800a56:	74 24                	je     800a7c <strncmp+0x41>
  800a58:	3a 03                	cmp    (%ebx),%al
  800a5a:	75 20                	jne    800a7c <strncmp+0x41>
  800a5c:	83 ea 01             	sub    $0x1,%edx
  800a5f:	74 13                	je     800a74 <strncmp+0x39>
		n--, p++, q++;
  800a61:	83 c1 01             	add    $0x1,%ecx
  800a64:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	84 c0                	test   %al,%al
  800a6c:	74 0e                	je     800a7c <strncmp+0x41>
  800a6e:	3a 03                	cmp    (%ebx),%al
  800a70:	74 ea                	je     800a5c <strncmp+0x21>
  800a72:	eb 08                	jmp    800a7c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7c:	0f b6 01             	movzbl (%ecx),%eax
  800a7f:	0f b6 13             	movzbl (%ebx),%edx
  800a82:	29 d0                	sub    %edx,%eax
  800a84:	eb f3                	jmp    800a79 <strncmp+0x3e>

00800a86 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a90:	0f b6 10             	movzbl (%eax),%edx
  800a93:	84 d2                	test   %dl,%dl
  800a95:	74 1c                	je     800ab3 <strchr+0x2d>
		if (*s == c)
  800a97:	38 ca                	cmp    %cl,%dl
  800a99:	75 09                	jne    800aa4 <strchr+0x1e>
  800a9b:	eb 1b                	jmp    800ab8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 14                	je     800ab8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	75 f1                	jne    800a9d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800aac:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab1:	eb 05                	jmp    800ab8 <strchr+0x32>
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac4:	0f b6 10             	movzbl (%eax),%edx
  800ac7:	84 d2                	test   %dl,%dl
  800ac9:	74 14                	je     800adf <strfind+0x25>
		if (*s == c)
  800acb:	38 ca                	cmp    %cl,%dl
  800acd:	75 06                	jne    800ad5 <strfind+0x1b>
  800acf:	eb 0e                	jmp    800adf <strfind+0x25>
  800ad1:	38 ca                	cmp    %cl,%dl
  800ad3:	74 0a                	je     800adf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	0f b6 10             	movzbl (%eax),%edx
  800adb:	84 d2                	test   %dl,%dl
  800add:	75 f2                	jne    800ad1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 0c             	sub    $0xc,%esp
  800ae7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800af0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af9:	85 c9                	test   %ecx,%ecx
  800afb:	74 30                	je     800b2d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b03:	75 25                	jne    800b2a <memset+0x49>
  800b05:	f6 c1 03             	test   $0x3,%cl
  800b08:	75 20                	jne    800b2a <memset+0x49>
		c &= 0xFF;
  800b0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	c1 e3 08             	shl    $0x8,%ebx
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	c1 e6 18             	shl    $0x18,%esi
  800b17:	89 d0                	mov    %edx,%eax
  800b19:	c1 e0 10             	shl    $0x10,%eax
  800b1c:	09 f0                	or     %esi,%eax
  800b1e:	09 d0                	or     %edx,%eax
  800b20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b25:	fc                   	cld    
  800b26:	f3 ab                	rep stos %eax,%es:(%edi)
  800b28:	eb 03                	jmp    800b2d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2a:	fc                   	cld    
  800b2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b32:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b35:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b38:	89 ec                	mov    %ebp,%esp
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b45:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b51:	39 c6                	cmp    %eax,%esi
  800b53:	73 36                	jae    800b8b <memmove+0x4f>
  800b55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b58:	39 d0                	cmp    %edx,%eax
  800b5a:	73 2f                	jae    800b8b <memmove+0x4f>
		s += n;
		d += n;
  800b5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 1b                	jne    800b7f <memmove+0x43>
  800b64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6a:	75 13                	jne    800b7f <memmove+0x43>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	75 0e                	jne    800b7f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b71:	83 ef 04             	sub    $0x4,%edi
  800b74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b7a:	fd                   	std    
  800b7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7d:	eb 09                	jmp    800b88 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7f:	83 ef 01             	sub    $0x1,%edi
  800b82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b85:	fd                   	std    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b88:	fc                   	cld    
  800b89:	eb 20                	jmp    800bab <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b91:	75 13                	jne    800ba6 <memmove+0x6a>
  800b93:	a8 03                	test   $0x3,%al
  800b95:	75 0f                	jne    800ba6 <memmove+0x6a>
  800b97:	f6 c1 03             	test   $0x3,%cl
  800b9a:	75 0a                	jne    800ba6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	fc                   	cld    
  800ba2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba4:	eb 05                	jmp    800bab <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb1:	89 ec                	mov    %ebp,%esp
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	89 04 24             	mov    %eax,(%esp)
  800bcf:	e8 68 ff ff ff       	call   800b3c <memmove>
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bea:	85 ff                	test   %edi,%edi
  800bec:	74 37                	je     800c25 <memcmp+0x4f>
		if (*s1 != *s2)
  800bee:	0f b6 03             	movzbl (%ebx),%eax
  800bf1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf4:	83 ef 01             	sub    $0x1,%edi
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800bfc:	38 c8                	cmp    %cl,%al
  800bfe:	74 1c                	je     800c1c <memcmp+0x46>
  800c00:	eb 10                	jmp    800c12 <memcmp+0x3c>
  800c02:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c07:	83 c2 01             	add    $0x1,%edx
  800c0a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c0e:	38 c8                	cmp    %cl,%al
  800c10:	74 0a                	je     800c1c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c12:	0f b6 c0             	movzbl %al,%eax
  800c15:	0f b6 c9             	movzbl %cl,%ecx
  800c18:	29 c8                	sub    %ecx,%eax
  800c1a:	eb 09                	jmp    800c25 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1c:	39 fa                	cmp    %edi,%edx
  800c1e:	75 e2                	jne    800c02 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c30:	89 c2                	mov    %eax,%edx
  800c32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	73 19                	jae    800c52 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c3d:	38 08                	cmp    %cl,(%eax)
  800c3f:	75 06                	jne    800c47 <memfind+0x1d>
  800c41:	eb 0f                	jmp    800c52 <memfind+0x28>
  800c43:	38 08                	cmp    %cl,(%eax)
  800c45:	74 0b                	je     800c52 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c47:	83 c0 01             	add    $0x1,%eax
  800c4a:	39 d0                	cmp    %edx,%eax
  800c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c50:	75 f1                	jne    800c43 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c60:	0f b6 02             	movzbl (%edx),%eax
  800c63:	3c 20                	cmp    $0x20,%al
  800c65:	74 04                	je     800c6b <strtol+0x17>
  800c67:	3c 09                	cmp    $0x9,%al
  800c69:	75 0e                	jne    800c79 <strtol+0x25>
		s++;
  800c6b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6e:	0f b6 02             	movzbl (%edx),%eax
  800c71:	3c 20                	cmp    $0x20,%al
  800c73:	74 f6                	je     800c6b <strtol+0x17>
  800c75:	3c 09                	cmp    $0x9,%al
  800c77:	74 f2                	je     800c6b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c79:	3c 2b                	cmp    $0x2b,%al
  800c7b:	75 0a                	jne    800c87 <strtol+0x33>
		s++;
  800c7d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c80:	bf 00 00 00 00       	mov    $0x0,%edi
  800c85:	eb 10                	jmp    800c97 <strtol+0x43>
  800c87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c8c:	3c 2d                	cmp    $0x2d,%al
  800c8e:	75 07                	jne    800c97 <strtol+0x43>
		s++, neg = 1;
  800c90:	83 c2 01             	add    $0x1,%edx
  800c93:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c97:	85 db                	test   %ebx,%ebx
  800c99:	0f 94 c0             	sete   %al
  800c9c:	74 05                	je     800ca3 <strtol+0x4f>
  800c9e:	83 fb 10             	cmp    $0x10,%ebx
  800ca1:	75 15                	jne    800cb8 <strtol+0x64>
  800ca3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ca6:	75 10                	jne    800cb8 <strtol+0x64>
  800ca8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cac:	75 0a                	jne    800cb8 <strtol+0x64>
		s += 2, base = 16;
  800cae:	83 c2 02             	add    $0x2,%edx
  800cb1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cb6:	eb 13                	jmp    800ccb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cb8:	84 c0                	test   %al,%al
  800cba:	74 0f                	je     800ccb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cbc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc1:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc4:	75 05                	jne    800ccb <strtol+0x77>
		s++, base = 8;
  800cc6:	83 c2 01             	add    $0x1,%edx
  800cc9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd2:	0f b6 0a             	movzbl (%edx),%ecx
  800cd5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cd8:	80 fb 09             	cmp    $0x9,%bl
  800cdb:	77 08                	ja     800ce5 <strtol+0x91>
			dig = *s - '0';
  800cdd:	0f be c9             	movsbl %cl,%ecx
  800ce0:	83 e9 30             	sub    $0x30,%ecx
  800ce3:	eb 1e                	jmp    800d03 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ce5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ced:	0f be c9             	movsbl %cl,%ecx
  800cf0:	83 e9 57             	sub    $0x57,%ecx
  800cf3:	eb 0e                	jmp    800d03 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cf8:	80 fb 19             	cmp    $0x19,%bl
  800cfb:	77 14                	ja     800d11 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cfd:	0f be c9             	movsbl %cl,%ecx
  800d00:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d03:	39 f1                	cmp    %esi,%ecx
  800d05:	7d 0e                	jge    800d15 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d07:	83 c2 01             	add    $0x1,%edx
  800d0a:	0f af c6             	imul   %esi,%eax
  800d0d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d0f:	eb c1                	jmp    800cd2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d11:	89 c1                	mov    %eax,%ecx
  800d13:	eb 02                	jmp    800d17 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d15:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d1b:	74 05                	je     800d22 <strtol+0xce>
		*endptr = (char *) s;
  800d1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d20:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d22:	89 ca                	mov    %ecx,%edx
  800d24:	f7 da                	neg    %edx
  800d26:	85 ff                	test   %edi,%edi
  800d28:	0f 45 c2             	cmovne %edx,%eax
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	89 c6                	mov    %eax,%esi
  800d50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5b:	89 ec                	mov    %ebp,%esp
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d73:	b8 01 00 00 00       	mov    $0x1,%eax
  800d78:	89 d1                	mov    %edx,%ecx
  800d7a:	89 d3                	mov    %edx,%ebx
  800d7c:	89 d7                	mov    %edx,%edi
  800d7e:	89 d6                	mov    %edx,%esi
  800d80:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8b:	89 ec                	mov    %ebp,%esp
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 38             	sub    $0x38,%esp
  800d95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	b8 03 00 00 00       	mov    $0x3,%eax
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 28                	jle    800ddf <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  800dda:	e8 a1 07 00 00       	call   801580 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de8:	89 ec                	mov    %ebp,%esp
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800e00:	b8 02 00 00 00       	mov    $0x2,%eax
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 d3                	mov    %edx,%ebx
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	89 d6                	mov    %edx,%esi
  800e0d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e0f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e18:	89 ec                	mov    %ebp,%esp
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_yield>:

void
sys_yield(void)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e28:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e42:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e45:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e48:	89 ec                	mov    %ebp,%esp
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 38             	sub    $0x38,%esp
  800e52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	be 00 00 00 00       	mov    $0x0,%esi
  800e60:	b8 04 00 00 00       	mov    $0x4,%eax
  800e65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 f7                	mov    %esi,%edi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 28                	jle    800e9e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e91:	00 
  800e92:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  800e99:	e8 e2 06 00 00       	call   801580 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea7:	89 ec                	mov    %ebp,%esp
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 38             	sub    $0x38,%esp
  800eb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eba:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebf:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	7e 28                	jle    800efc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800edf:	00 
  800ee0:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eef:	00 
  800ef0:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  800ef7:	e8 84 06 00 00       	call   801580 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800efc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f02:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f05:	89 ec                	mov    %ebp,%esp
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 38             	sub    $0x38,%esp
  800f0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 28                	jle    800f5a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f36:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  800f55:	e8 26 06 00 00       	call   801580 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f63:	89 ec                	mov    %ebp,%esp
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 38             	sub    $0x38,%esp
  800f6d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f70:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f73:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f83:	8b 55 08             	mov    0x8(%ebp),%edx
  800f86:	89 df                	mov    %ebx,%edi
  800f88:	89 de                	mov    %ebx,%esi
  800f8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	7e 28                	jle    800fb8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f94:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  800fb3:	e8 c8 05 00 00       	call   801580 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fb8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc1:	89 ec                	mov    %ebp,%esp
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 38             	sub    $0x38,%esp
  800fcb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 df                	mov    %ebx,%edi
  800fe6:	89 de                	mov    %ebx,%esi
  800fe8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 28                	jle    801016 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  801001:	00 
  801002:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801009:	00 
  80100a:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  801011:	e8 6a 05 00 00       	call   801580 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801016:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801019:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101f:	89 ec                	mov    %ebp,%esp
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80102c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80102f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	be 00 00 00 00       	mov    $0x0,%esi
  801037:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80103f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801045:	8b 55 08             	mov    0x8(%ebp),%edx
  801048:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80104a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801050:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801053:	89 ec                	mov    %ebp,%esp
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 38             	sub    $0x38,%esp
  80105d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801060:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801063:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801066:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	89 cb                	mov    %ecx,%ebx
  801075:	89 cf                	mov    %ecx,%edi
  801077:	89 ce                	mov    %ecx,%esi
  801079:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107b:	85 c0                	test   %eax,%eax
  80107d:	7e 28                	jle    8010a7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801083:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80108a:	00 
  80108b:	c7 44 24 08 c4 1b 80 	movl   $0x801bc4,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 e1 1b 80 00 	movl   $0x801be1,(%esp)
  8010a2:	e8 d9 04 00 00       	call   801580 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b0:	89 ec                	mov    %ebp,%esp
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d0:	89 cb                	mov    %ecx,%ebx
  8010d2:	89 cf                	mov    %ecx,%edi
  8010d4:	89 ce                	mov    %ecx,%esi
  8010d6:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  8010d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e1:	89 ec                	mov    %ebp,%esp
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    
  8010e5:	00 00                	add    %al,(%eax)
	...

008010e8 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 24             	sub    $0x24,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  8010ef:	89 d3                	mov    %edx,%ebx
  8010f1:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010f4:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8010fb:	f6 c1 02             	test   $0x2,%cl
  8010fe:	75 10                	jne    801110 <duppage+0x28>
  801100:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801107:	f6 c6 08             	test   $0x8,%dh
  80110a:	0f 84 84 00 00 00    	je     801194 <duppage+0xac>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801110:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801117:	00 
  801118:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80111c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112b:	e8 7b fd ff ff       	call   800eab <sys_page_map>
  801130:	85 c0                	test   %eax,%eax
  801132:	79 1c                	jns    801150 <duppage+0x68>
			panic("2");
  801134:	c7 44 24 08 ef 1b 80 	movl   $0x801bef,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  80114b:	e8 30 04 00 00       	call   801580 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801150:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801157:	00 
  801158:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80115c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801163:	00 
  801164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116f:	e8 37 fd ff ff       	call   800eab <sys_page_map>
  801174:	85 c0                	test   %eax,%eax
  801176:	79 3c                	jns    8011b4 <duppage+0xcc>
			panic("3");
  801178:	c7 44 24 08 fc 1b 80 	movl   $0x801bfc,0x8(%esp)
  80117f:	00 
  801180:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801187:	00 
  801188:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  80118f:	e8 ec 03 00 00       	call   801580 <_panic>
		
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801194:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80119b:	00 
  80119c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011af:	e8 f7 fc ff ff       	call   800eab <sys_page_map>
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b9:	83 c4 24             	add    $0x24,%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 24             	sub    $0x24,%esp
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  8011c9:	8b 18                	mov    (%eax),%ebx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011cb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011cf:	74 2d                	je     8011fe <pgfault+0x3f>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011d1:	89 d8                	mov    %ebx,%eax
  8011d3:	c1 e8 16             	shr    $0x16,%eax
  8011d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011dd:	a8 01                	test   $0x1,%al
  8011df:	74 1d                	je     8011fe <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011e1:	89 d8                	mov    %ebx,%eax
  8011e3:	c1 e8 0c             	shr    $0xc,%eax
  8011e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  8011ed:	f6 c2 01             	test   $0x1,%dl
  8011f0:	74 0c                	je     8011fe <pgfault+0x3f>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  8011f9:	f6 c4 08             	test   $0x8,%ah
  8011fc:	75 1c                	jne    80121a <pgfault+0x5b>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  8011fe:	c7 44 24 08 fe 1b 80 	movl   $0x801bfe,0x8(%esp)
  801205:	00 
  801206:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80120d:	00 
  80120e:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  801215:	e8 66 03 00 00       	call   801580 <_panic>
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  80121a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801231:	e8 16 fc ff ff       	call   800e4c <sys_page_alloc>
  801236:	85 c0                	test   %eax,%eax
  801238:	79 1c                	jns    801256 <pgfault+0x97>
		panic("sys_page_alloc");
  80123a:	c7 44 24 08 10 1c 80 	movl   $0x801c10,0x8(%esp)
  801241:	00 
  801242:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801249:	00 
  80124a:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  801251:	e8 2a 03 00 00       	call   801580 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  801256:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  80125c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801263:	00 
  801264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801268:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80126f:	e8 41 f9 ff ff       	call   800bb5 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801274:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80127b:	00 
  80127c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801287:	00 
  801288:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80128f:	00 
  801290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801297:	e8 0f fc ff ff       	call   800eab <sys_page_map>
  80129c:	85 c0                	test   %eax,%eax
  80129e:	79 1c                	jns    8012bc <pgfault+0xfd>
		panic("sys_page_map");
  8012a0:	c7 44 24 08 1f 1c 80 	movl   $0x801c1f,0x8(%esp)
  8012a7:	00 
  8012a8:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  8012af:	00 
  8012b0:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  8012b7:	e8 c4 02 00 00       	call   801580 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  8012bc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012c3:	00 
  8012c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cb:	e8 39 fc ff ff       	call   800f09 <sys_page_unmap>
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	79 1c                	jns    8012f0 <pgfault+0x131>
		panic("sys_page_unmap");
  8012d4:	c7 44 24 08 2c 1c 80 	movl   $0x801c2c,0x8(%esp)
  8012db:	00 
  8012dc:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8012e3:	00 
  8012e4:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  8012eb:	e8 90 02 00 00       	call   801580 <_panic>
	return;
}
  8012f0:	83 c4 24             	add    $0x24,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 1c             	sub    $0x1c,%esp
	set_pgfault_handler(pgfault);
  8012ff:	c7 04 24 bf 11 80 00 	movl   $0x8011bf,(%esp)
  801306:	e8 cd 02 00 00       	call   8015d8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80130b:	be 07 00 00 00       	mov    $0x7,%esi
  801310:	89 f0                	mov    %esi,%eax
  801312:	cd 30                	int    $0x30
  801314:	89 c6                	mov    %eax,%esi
  801316:	89 c7                	mov    %eax,%edi

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801318:	85 c0                	test   %eax,%eax
  80131a:	75 1c                	jne    801338 <fork+0x42>
		thisenv = &envs[ENVX(sys_getenvid())];
  80131c:	e8 cb fa ff ff       	call   800dec <sys_getenvid>
  801321:	25 ff 03 00 00       	and    $0x3ff,%eax
  801326:	c1 e0 07             	shl    $0x7,%eax
  801329:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80132e:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801333:	e9 e1 00 00 00       	jmp    801419 <fork+0x123>
	}
	if (envid < 0)
  801338:	85 c0                	test   %eax,%eax
  80133a:	79 20                	jns    80135c <fork+0x66>
		panic("sys_exofork: %e", envid);
  80133c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801340:	c7 44 24 08 3b 1c 80 	movl   $0x801c3b,0x8(%esp)
  801347:	00 
  801348:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80134f:	00 
  801350:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  801357:	e8 24 02 00 00       	call   801580 <_panic>
	envid = sys_exofork();
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  80135c:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801361:	89 d8                	mov    %ebx,%eax
  801363:	c1 e8 16             	shr    $0x16,%eax
  801366:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80136d:	a8 01                	test   $0x1,%al
  80136f:	74 22                	je     801393 <fork+0x9d>
  801371:	89 da                	mov    %ebx,%edx
  801373:	c1 ea 0c             	shr    $0xc,%edx
  801376:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80137d:	a8 01                	test   $0x1,%al
  80137f:	74 12                	je     801393 <fork+0x9d>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801381:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801388:	a8 04                	test   $0x4,%al
  80138a:	74 07                	je     801393 <fork+0x9d>
			duppage(envid, PGNUM(addr));
  80138c:	89 f8                	mov    %edi,%eax
  80138e:	e8 55 fd ff ff       	call   8010e8 <duppage>
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801393:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801399:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80139f:	75 c0                	jne    801361 <fork+0x6b>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8013a1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013a8:	00 
  8013a9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013b0:	ee 
  8013b1:	89 34 24             	mov    %esi,(%esp)
  8013b4:	e8 93 fa ff ff       	call   800e4c <sys_page_alloc>
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	79 1c                	jns    8013d9 <fork+0xe3>
		panic("1");
  8013bd:	c7 44 24 08 4b 1c 80 	movl   $0x801c4b,0x8(%esp)
  8013c4:	00 
  8013c5:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8013cc:	00 
  8013cd:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  8013d4:	e8 a7 01 00 00       	call   801580 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8013d9:	c7 44 24 04 64 16 80 	movl   $0x801664,0x4(%esp)
  8013e0:	00 
  8013e1:	89 34 24             	mov    %esi,(%esp)
  8013e4:	e8 dc fb ff ff       	call   800fc5 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8013e9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013f0:	00 
  8013f1:	89 34 24             	mov    %esi,(%esp)
  8013f4:	e8 6e fb ff ff       	call   800f67 <sys_env_set_status>
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	79 1c                	jns    801419 <fork+0x123>
		panic("sys_env_set_status");
  8013fd:	c7 44 24 08 4d 1c 80 	movl   $0x801c4d,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  801414:	e8 67 01 00 00       	call   801580 <_panic>

	return envid;
}
  801419:	89 f0                	mov    %esi,%eax
  80141b:	83 c4 1c             	add    $0x1c,%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <sfork>:

// Challenge!
int
sfork(void)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801429:	c7 44 24 08 60 1c 80 	movl   $0x801c60,0x8(%esp)
  801430:	00 
  801431:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801438:	00 
  801439:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  801440:	e8 3b 01 00 00       	call   801580 <_panic>

00801445 <pfork>:
	return -E_INVAL;
}

envid_t
pfork(int pr)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	57                   	push   %edi
  801449:	56                   	push   %esi
  80144a:	53                   	push   %ebx
  80144b:	83 ec 1c             	sub    $0x1c,%esp
    set_pgfault_handler(pgfault);
  80144e:	c7 04 24 bf 11 80 00 	movl   $0x8011bf,(%esp)
  801455:	e8 7e 01 00 00       	call   8015d8 <set_pgfault_handler>
  80145a:	be 07 00 00 00       	mov    $0x7,%esi
  80145f:	89 f0                	mov    %esi,%eax
  801461:	cd 30                	int    $0x30
  801463:	89 c6                	mov    %eax,%esi
  801465:	89 c7                	mov    %eax,%edi

    envid_t envid;
    uint32_t addr;
    envid = sys_exofork();
    if (envid == 0) {
  801467:	85 c0                	test   %eax,%eax
  801469:	75 27                	jne    801492 <pfork+0x4d>
        thisenv = &envs[ENVX(sys_getenvid())];
  80146b:	e8 7c f9 ff ff       	call   800dec <sys_getenvid>
  801470:	25 ff 03 00 00       	and    $0x3ff,%eax
  801475:	c1 e0 07             	shl    $0x7,%eax
  801478:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80147d:	a3 08 20 80 00       	mov    %eax,0x802008
        sys_change_pr(pr);
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	89 04 24             	mov    %eax,(%esp)
  801488:	e8 27 fc ff ff       	call   8010b4 <sys_change_pr>
        return 0;
  80148d:	e9 e1 00 00 00       	jmp    801573 <pfork+0x12e>
    }

    if (envid < 0)
  801492:	85 c0                	test   %eax,%eax
  801494:	79 20                	jns    8014b6 <pfork+0x71>
        panic("sys_exofork: %e", envid);
  801496:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80149a:	c7 44 24 08 3b 1c 80 	movl   $0x801c3b,0x8(%esp)
  8014a1:	00 
  8014a2:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8014a9:	00 
  8014aa:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  8014b1:	e8 ca 00 00 00       	call   801580 <_panic>
        thisenv = &envs[ENVX(sys_getenvid())];
        sys_change_pr(pr);
        return 0;
    }

    if (envid < 0)
  8014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8014bb:	89 d8                	mov    %ebx,%eax
  8014bd:	c1 e8 16             	shr    $0x16,%eax
  8014c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c7:	a8 01                	test   $0x1,%al
  8014c9:	74 22                	je     8014ed <pfork+0xa8>
  8014cb:	89 da                	mov    %ebx,%edx
  8014cd:	c1 ea 0c             	shr    $0xc,%edx
  8014d0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014d7:	a8 01                	test   $0x1,%al
  8014d9:	74 12                	je     8014ed <pfork+0xa8>
            && (uvpt[PGNUM(addr)] & PTE_U)) {
  8014db:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014e2:	a8 04                	test   $0x4,%al
  8014e4:	74 07                	je     8014ed <pfork+0xa8>
            duppage(envid, PGNUM(addr));
  8014e6:	89 f8                	mov    %edi,%eax
  8014e8:	e8 fb fb ff ff       	call   8010e8 <duppage>
    }

    if (envid < 0)
        panic("sys_exofork: %e", envid);

    for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8014ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014f3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8014f9:	75 c0                	jne    8014bb <pfork+0x76>
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
            && (uvpt[PGNUM(addr)] & PTE_U)) {
            duppage(envid, PGNUM(addr));
        }

    if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8014fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801502:	00 
  801503:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80150a:	ee 
  80150b:	89 34 24             	mov    %esi,(%esp)
  80150e:	e8 39 f9 ff ff       	call   800e4c <sys_page_alloc>
  801513:	85 c0                	test   %eax,%eax
  801515:	79 1c                	jns    801533 <pfork+0xee>
        panic("1");
  801517:	c7 44 24 08 4b 1c 80 	movl   $0x801c4b,0x8(%esp)
  80151e:	00 
  80151f:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801526:	00 
  801527:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  80152e:	e8 4d 00 00 00       	call   801580 <_panic>
    extern void _pgfault_upcall();
    sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801533:	c7 44 24 04 64 16 80 	movl   $0x801664,0x4(%esp)
  80153a:	00 
  80153b:	89 34 24             	mov    %esi,(%esp)
  80153e:	e8 82 fa ff ff       	call   800fc5 <sys_env_set_pgfault_upcall>

    if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801543:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80154a:	00 
  80154b:	89 34 24             	mov    %esi,(%esp)
  80154e:	e8 14 fa ff ff       	call   800f67 <sys_env_set_status>
  801553:	85 c0                	test   %eax,%eax
  801555:	79 1c                	jns    801573 <pfork+0x12e>
        panic("sys_env_set_status");
  801557:	c7 44 24 08 4d 1c 80 	movl   $0x801c4d,0x8(%esp)
  80155e:	00 
  80155f:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
  801566:	00 
  801567:	c7 04 24 f1 1b 80 00 	movl   $0x801bf1,(%esp)
  80156e:	e8 0d 00 00 00       	call   801580 <_panic>

    return envid;
    panic("fork not implemented");
  801573:	89 f0                	mov    %esi,%eax
  801575:	83 c4 1c             	add    $0x1c,%esp
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	5f                   	pop    %edi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    
  80157d:	00 00                	add    %al,(%eax)
	...

00801580 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801588:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80158b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801591:	e8 56 f8 ff ff       	call   800dec <sys_getenvid>
  801596:	8b 55 0c             	mov    0xc(%ebp),%edx
  801599:	89 54 24 10          	mov    %edx,0x10(%esp)
  80159d:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ac:	c7 04 24 78 1c 80 00 	movl   $0x801c78,(%esp)
  8015b3:	e8 4b ec ff ff       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8015bf:	89 04 24             	mov    %eax,(%esp)
  8015c2:	e8 db eb ff ff       	call   8001a2 <vcprintf>
	cprintf("\n");
  8015c7:	c7 04 24 4f 19 80 00 	movl   $0x80194f,(%esp)
  8015ce:	e8 30 ec ff ff       	call   800203 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015d3:	cc                   	int3   
  8015d4:	eb fd                	jmp    8015d3 <_panic+0x53>
	...

008015d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8015de:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8015e5:	75 3c                	jne    801623 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8015e7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015ee:	00 
  8015ef:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015f6:	ee 
  8015f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fe:	e8 49 f8 ff ff       	call   800e4c <sys_page_alloc>
  801603:	85 c0                	test   %eax,%eax
  801605:	79 1c                	jns    801623 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801607:	c7 44 24 08 9c 1c 80 	movl   $0x801c9c,0x8(%esp)
  80160e:	00 
  80160f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801616:	00 
  801617:	c7 04 24 00 1d 80 00 	movl   $0x801d00,(%esp)
  80161e:	e8 5d ff ff ff       	call   801580 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80162b:	c7 44 24 04 64 16 80 	movl   $0x801664,0x4(%esp)
  801632:	00 
  801633:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163a:	e8 86 f9 ff ff       	call   800fc5 <sys_env_set_pgfault_upcall>
  80163f:	85 c0                	test   %eax,%eax
  801641:	79 1c                	jns    80165f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801643:	c7 44 24 08 c8 1c 80 	movl   $0x801cc8,0x8(%esp)
  80164a:	00 
  80164b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801652:	00 
  801653:	c7 04 24 00 1d 80 00 	movl   $0x801d00,(%esp)
  80165a:	e8 21 ff ff ff       	call   801580 <_panic>
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    
  801661:	00 00                	add    %al,(%eax)
	...

00801664 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801664:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801665:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80166a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80166c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80166f:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  801673:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801678:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80167c:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80167e:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  801681:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  801682:	83 c4 04             	add    $0x4,%esp
    popfl
  801685:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801686:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801687:	c3                   	ret    
	...

00801690 <__udivdi3>:
  801690:	83 ec 1c             	sub    $0x1c,%esp
  801693:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801697:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80169b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80169f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8016a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8016ab:	85 ff                	test   %edi,%edi
  8016ad:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8016b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016b5:	89 cd                	mov    %ecx,%ebp
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	75 33                	jne    8016f0 <__udivdi3+0x60>
  8016bd:	39 f1                	cmp    %esi,%ecx
  8016bf:	77 57                	ja     801718 <__udivdi3+0x88>
  8016c1:	85 c9                	test   %ecx,%ecx
  8016c3:	75 0b                	jne    8016d0 <__udivdi3+0x40>
  8016c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ca:	31 d2                	xor    %edx,%edx
  8016cc:	f7 f1                	div    %ecx
  8016ce:	89 c1                	mov    %eax,%ecx
  8016d0:	89 f0                	mov    %esi,%eax
  8016d2:	31 d2                	xor    %edx,%edx
  8016d4:	f7 f1                	div    %ecx
  8016d6:	89 c6                	mov    %eax,%esi
  8016d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016dc:	f7 f1                	div    %ecx
  8016de:	89 f2                	mov    %esi,%edx
  8016e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016ec:	83 c4 1c             	add    $0x1c,%esp
  8016ef:	c3                   	ret    
  8016f0:	31 d2                	xor    %edx,%edx
  8016f2:	31 c0                	xor    %eax,%eax
  8016f4:	39 f7                	cmp    %esi,%edi
  8016f6:	77 e8                	ja     8016e0 <__udivdi3+0x50>
  8016f8:	0f bd cf             	bsr    %edi,%ecx
  8016fb:	83 f1 1f             	xor    $0x1f,%ecx
  8016fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801702:	75 2c                	jne    801730 <__udivdi3+0xa0>
  801704:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801708:	76 04                	jbe    80170e <__udivdi3+0x7e>
  80170a:	39 f7                	cmp    %esi,%edi
  80170c:	73 d2                	jae    8016e0 <__udivdi3+0x50>
  80170e:	31 d2                	xor    %edx,%edx
  801710:	b8 01 00 00 00       	mov    $0x1,%eax
  801715:	eb c9                	jmp    8016e0 <__udivdi3+0x50>
  801717:	90                   	nop
  801718:	89 f2                	mov    %esi,%edx
  80171a:	f7 f1                	div    %ecx
  80171c:	31 d2                	xor    %edx,%edx
  80171e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801722:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801726:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80172a:	83 c4 1c             	add    $0x1c,%esp
  80172d:	c3                   	ret    
  80172e:	66 90                	xchg   %ax,%ax
  801730:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801735:	b8 20 00 00 00       	mov    $0x20,%eax
  80173a:	89 ea                	mov    %ebp,%edx
  80173c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801740:	d3 e7                	shl    %cl,%edi
  801742:	89 c1                	mov    %eax,%ecx
  801744:	d3 ea                	shr    %cl,%edx
  801746:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80174b:	09 fa                	or     %edi,%edx
  80174d:	89 f7                	mov    %esi,%edi
  80174f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801753:	89 f2                	mov    %esi,%edx
  801755:	8b 74 24 08          	mov    0x8(%esp),%esi
  801759:	d3 e5                	shl    %cl,%ebp
  80175b:	89 c1                	mov    %eax,%ecx
  80175d:	d3 ef                	shr    %cl,%edi
  80175f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801764:	d3 e2                	shl    %cl,%edx
  801766:	89 c1                	mov    %eax,%ecx
  801768:	d3 ee                	shr    %cl,%esi
  80176a:	09 d6                	or     %edx,%esi
  80176c:	89 fa                	mov    %edi,%edx
  80176e:	89 f0                	mov    %esi,%eax
  801770:	f7 74 24 0c          	divl   0xc(%esp)
  801774:	89 d7                	mov    %edx,%edi
  801776:	89 c6                	mov    %eax,%esi
  801778:	f7 e5                	mul    %ebp
  80177a:	39 d7                	cmp    %edx,%edi
  80177c:	72 22                	jb     8017a0 <__udivdi3+0x110>
  80177e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801782:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801787:	d3 e5                	shl    %cl,%ebp
  801789:	39 c5                	cmp    %eax,%ebp
  80178b:	73 04                	jae    801791 <__udivdi3+0x101>
  80178d:	39 d7                	cmp    %edx,%edi
  80178f:	74 0f                	je     8017a0 <__udivdi3+0x110>
  801791:	89 f0                	mov    %esi,%eax
  801793:	31 d2                	xor    %edx,%edx
  801795:	e9 46 ff ff ff       	jmp    8016e0 <__udivdi3+0x50>
  80179a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017a0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8017a3:	31 d2                	xor    %edx,%edx
  8017a5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017a9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017ad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017b1:	83 c4 1c             	add    $0x1c,%esp
  8017b4:	c3                   	ret    
	...

008017c0 <__umoddi3>:
  8017c0:	83 ec 1c             	sub    $0x1c,%esp
  8017c3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8017c7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8017cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8017cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017d3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8017d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8017db:	85 ed                	test   %ebp,%ebp
  8017dd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8017e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e5:	89 cf                	mov    %ecx,%edi
  8017e7:	89 04 24             	mov    %eax,(%esp)
  8017ea:	89 f2                	mov    %esi,%edx
  8017ec:	75 1a                	jne    801808 <__umoddi3+0x48>
  8017ee:	39 f1                	cmp    %esi,%ecx
  8017f0:	76 4e                	jbe    801840 <__umoddi3+0x80>
  8017f2:	f7 f1                	div    %ecx
  8017f4:	89 d0                	mov    %edx,%eax
  8017f6:	31 d2                	xor    %edx,%edx
  8017f8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801800:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801804:	83 c4 1c             	add    $0x1c,%esp
  801807:	c3                   	ret    
  801808:	39 f5                	cmp    %esi,%ebp
  80180a:	77 54                	ja     801860 <__umoddi3+0xa0>
  80180c:	0f bd c5             	bsr    %ebp,%eax
  80180f:	83 f0 1f             	xor    $0x1f,%eax
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	75 60                	jne    801878 <__umoddi3+0xb8>
  801818:	3b 0c 24             	cmp    (%esp),%ecx
  80181b:	0f 87 07 01 00 00    	ja     801928 <__umoddi3+0x168>
  801821:	89 f2                	mov    %esi,%edx
  801823:	8b 34 24             	mov    (%esp),%esi
  801826:	29 ce                	sub    %ecx,%esi
  801828:	19 ea                	sbb    %ebp,%edx
  80182a:	89 34 24             	mov    %esi,(%esp)
  80182d:	8b 04 24             	mov    (%esp),%eax
  801830:	8b 74 24 10          	mov    0x10(%esp),%esi
  801834:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801838:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80183c:	83 c4 1c             	add    $0x1c,%esp
  80183f:	c3                   	ret    
  801840:	85 c9                	test   %ecx,%ecx
  801842:	75 0b                	jne    80184f <__umoddi3+0x8f>
  801844:	b8 01 00 00 00       	mov    $0x1,%eax
  801849:	31 d2                	xor    %edx,%edx
  80184b:	f7 f1                	div    %ecx
  80184d:	89 c1                	mov    %eax,%ecx
  80184f:	89 f0                	mov    %esi,%eax
  801851:	31 d2                	xor    %edx,%edx
  801853:	f7 f1                	div    %ecx
  801855:	8b 04 24             	mov    (%esp),%eax
  801858:	f7 f1                	div    %ecx
  80185a:	eb 98                	jmp    8017f4 <__umoddi3+0x34>
  80185c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801860:	89 f2                	mov    %esi,%edx
  801862:	8b 74 24 10          	mov    0x10(%esp),%esi
  801866:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80186a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80186e:	83 c4 1c             	add    $0x1c,%esp
  801871:	c3                   	ret    
  801872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801878:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80187d:	89 e8                	mov    %ebp,%eax
  80187f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801884:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801888:	89 fa                	mov    %edi,%edx
  80188a:	d3 e0                	shl    %cl,%eax
  80188c:	89 e9                	mov    %ebp,%ecx
  80188e:	d3 ea                	shr    %cl,%edx
  801890:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801895:	09 c2                	or     %eax,%edx
  801897:	8b 44 24 08          	mov    0x8(%esp),%eax
  80189b:	89 14 24             	mov    %edx,(%esp)
  80189e:	89 f2                	mov    %esi,%edx
  8018a0:	d3 e7                	shl    %cl,%edi
  8018a2:	89 e9                	mov    %ebp,%ecx
  8018a4:	d3 ea                	shr    %cl,%edx
  8018a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018af:	d3 e6                	shl    %cl,%esi
  8018b1:	89 e9                	mov    %ebp,%ecx
  8018b3:	d3 e8                	shr    %cl,%eax
  8018b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018ba:	09 f0                	or     %esi,%eax
  8018bc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8018c0:	f7 34 24             	divl   (%esp)
  8018c3:	d3 e6                	shl    %cl,%esi
  8018c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018c9:	89 d6                	mov    %edx,%esi
  8018cb:	f7 e7                	mul    %edi
  8018cd:	39 d6                	cmp    %edx,%esi
  8018cf:	89 c1                	mov    %eax,%ecx
  8018d1:	89 d7                	mov    %edx,%edi
  8018d3:	72 3f                	jb     801914 <__umoddi3+0x154>
  8018d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8018d9:	72 35                	jb     801910 <__umoddi3+0x150>
  8018db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018df:	29 c8                	sub    %ecx,%eax
  8018e1:	19 fe                	sbb    %edi,%esi
  8018e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018e8:	89 f2                	mov    %esi,%edx
  8018ea:	d3 e8                	shr    %cl,%eax
  8018ec:	89 e9                	mov    %ebp,%ecx
  8018ee:	d3 e2                	shl    %cl,%edx
  8018f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018f5:	09 d0                	or     %edx,%eax
  8018f7:	89 f2                	mov    %esi,%edx
  8018f9:	d3 ea                	shr    %cl,%edx
  8018fb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8018ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801903:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801907:	83 c4 1c             	add    $0x1c,%esp
  80190a:	c3                   	ret    
  80190b:	90                   	nop
  80190c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801910:	39 d6                	cmp    %edx,%esi
  801912:	75 c7                	jne    8018db <__umoddi3+0x11b>
  801914:	89 d7                	mov    %edx,%edi
  801916:	89 c1                	mov    %eax,%ecx
  801918:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80191c:	1b 3c 24             	sbb    (%esp),%edi
  80191f:	eb ba                	jmp    8018db <__umoddi3+0x11b>
  801921:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801928:	39 f5                	cmp    %esi,%ebp
  80192a:	0f 82 f1 fe ff ff    	jb     801821 <__umoddi3+0x61>
  801930:	e9 f8 fe ff ff       	jmp    80182d <__umoddi3+0x6d>
