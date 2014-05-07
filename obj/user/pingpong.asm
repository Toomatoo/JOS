
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 35 12 00 00       	call   801277 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 ac 0d 00 00       	call   800dfc <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  80005f:	e8 a3 01 00 00       	call   800207 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 3f 15 00 00       	call   8015c6 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 be 14 00 00       	call   801560 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 50 0d 00 00       	call   800dfc <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 96 28 80 00 	movl   $0x802896,(%esp)
  8000bf:	e8 43 01 00 00       	call   800207 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 db 14 00 00       	call   8015c6 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010a:	e8 ed 0c 00 00       	call   800dfc <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 4b 17 00 00       	call   80189e <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 40 0c 00 00       	call   800d9f <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	83 c0 01             	add    $0x1,%eax
  80017a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	75 19                	jne    80019c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800183:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80018a:	00 
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 aa 0b 00 00       	call   800d40 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80019c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a0:	83 c4 14             	add    $0x14,%esp
  8001a3:	5b                   	pop    %ebx
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001db:	c7 04 24 64 01 80 00 	movl   $0x800164,(%esp)
  8001e2:	e8 97 01 00 00       	call   80037e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	e8 41 0b 00 00       	call   800d40 <sys_cputs>

	return b.cnt;
}
  8001ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	e8 87 ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    
  800221:	00 00                	add    %al,(%eax)
	...

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 3c             	sub    $0x3c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d7                	mov    %edx,%edi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800241:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800244:	b8 00 00 00 00       	mov    $0x0,%eax
  800249:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80024c:	72 11                	jb     80025f <printnum+0x3b>
  80024e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800251:	39 45 10             	cmp    %eax,0x10(%ebp)
  800254:	76 09                	jbe    80025f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	85 db                	test   %ebx,%ebx
  80025b:	7f 51                	jg     8002ae <printnum+0x8a>
  80025d:	eb 5e                	jmp    8002bd <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800263:	83 eb 01             	sub    $0x1,%ebx
  800266:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
  80026d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800271:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800275:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800279:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800280:	00 
  800281:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800284:	89 04 24             	mov    %eax,(%esp)
  800287:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80028a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028e:	e8 2d 23 00 00       	call   8025c0 <__udivdi3>
  800293:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800297:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a2:	89 fa                	mov    %edi,%edx
  8002a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a7:	e8 78 ff ff ff       	call   800224 <printnum>
  8002ac:	eb 0f                	jmp    8002bd <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b2:	89 34 24             	mov    %esi,(%esp)
  8002b5:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	75 f1                	jne    8002ae <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d3:	00 
  8002d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	e8 0a 24 00 00       	call   8026f0 <__umoddi3>
  8002e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ea:	0f be 80 b3 28 80 00 	movsbl 0x8028b3(%eax),%eax
  8002f1:	89 04 24             	mov    %eax,(%esp)
  8002f4:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002f7:	83 c4 3c             	add    $0x3c,%esp
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800302:	83 fa 01             	cmp    $0x1,%edx
  800305:	7e 0e                	jle    800315 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	8b 52 04             	mov    0x4(%edx),%edx
  800313:	eb 22                	jmp    800337 <getuint+0x38>
	else if (lflag)
  800315:	85 d2                	test   %edx,%edx
  800317:	74 10                	je     800329 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 0e                	jmp    800337 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 02                	mov    (%edx),%eax
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 0a                	jae    800354 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034d:	88 0a                	mov    %cl,(%edx)
  80034f:	83 c2 01             	add    $0x1,%edx
  800352:	89 10                	mov    %edx,(%eax)
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800363:	8b 45 10             	mov    0x10(%ebp),%eax
  800366:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	e8 02 00 00 00       	call   80037e <vprintfmt>
	va_end(ap);
}
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 5c             	sub    $0x5c,%esp
  800387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80038a:	8b 75 10             	mov    0x10(%ebp),%esi
  80038d:	eb 12                	jmp    8003a1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038f:	85 c0                	test   %eax,%eax
  800391:	0f 84 e4 04 00 00    	je     80087b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800397:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80039b:	89 04 24             	mov    %eax,(%esp)
  80039e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a1:	0f b6 06             	movzbl (%esi),%eax
  8003a4:	83 c6 01             	add    $0x1,%esi
  8003a7:	83 f8 25             	cmp    $0x25,%eax
  8003aa:	75 e3                	jne    80038f <vprintfmt+0x11>
  8003ac:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8003b0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003b7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003bc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8003cb:	eb 2b                	jmp    8003f8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d0:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8003d4:	eb 22                	jmp    8003f8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d9:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8003dd:	eb 19                	jmp    8003f8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003e9:	eb 0d                	jmp    8003f8 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003eb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8003ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f1:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	0f b6 06             	movzbl (%esi),%eax
  8003fb:	0f b6 d0             	movzbl %al,%edx
  8003fe:	8d 7e 01             	lea    0x1(%esi),%edi
  800401:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800404:	83 e8 23             	sub    $0x23,%eax
  800407:	3c 55                	cmp    $0x55,%al
  800409:	0f 87 46 04 00 00    	ja     800855 <vprintfmt+0x4d7>
  80040f:	0f b6 c0             	movzbl %al,%eax
  800412:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800419:	83 ea 30             	sub    $0x30,%edx
  80041c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80041f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800423:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800429:	83 fa 09             	cmp    $0x9,%edx
  80042c:	77 4a                	ja     800478 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800431:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800434:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800437:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80043b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80043e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800441:	83 fa 09             	cmp    $0x9,%edx
  800444:	76 eb                	jbe    800431 <vprintfmt+0xb3>
  800446:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800449:	eb 2d                	jmp    800478 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	8b 00                	mov    (%eax),%eax
  800456:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045c:	eb 1a                	jmp    800478 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800461:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800465:	79 91                	jns    8003f8 <vprintfmt+0x7a>
  800467:	e9 73 ff ff ff       	jmp    8003df <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800476:	eb 80                	jmp    8003f8 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800478:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80047c:	0f 89 76 ff ff ff    	jns    8003f8 <vprintfmt+0x7a>
  800482:	e9 64 ff ff ff       	jmp    8003eb <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800487:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048d:	e9 66 ff ff ff       	jmp    8003f8 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	89 04 24             	mov    %eax,(%esp)
  8004a4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004aa:	e9 f2 fe ff ff       	jmp    8003a1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8004af:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8004b3:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8004b6:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8004ba:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8004bd:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8004c1:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8004c4:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8004c7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8004cb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8004ce:	80 f9 09             	cmp    $0x9,%cl
  8004d1:	77 1d                	ja     8004f0 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8004d3:	0f be c0             	movsbl %al,%eax
  8004d6:	6b c0 64             	imul   $0x64,%eax,%eax
  8004d9:	0f be d2             	movsbl %dl,%edx
  8004dc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004df:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8004e6:	a3 04 30 80 00       	mov    %eax,0x803004
  8004eb:	e9 b1 fe ff ff       	jmp    8003a1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8004f0:	c7 44 24 04 cb 28 80 	movl   $0x8028cb,0x4(%esp)
  8004f7:	00 
  8004f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	e8 18 05 00 00       	call   800a1b <strcmp>
  800503:	85 c0                	test   %eax,%eax
  800505:	75 0f                	jne    800516 <vprintfmt+0x198>
  800507:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  80050e:	00 00 00 
  800511:	e9 8b fe ff ff       	jmp    8003a1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800516:	c7 44 24 04 cf 28 80 	movl   $0x8028cf,0x4(%esp)
  80051d:	00 
  80051e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800521:	89 14 24             	mov    %edx,(%esp)
  800524:	e8 f2 04 00 00       	call   800a1b <strcmp>
  800529:	85 c0                	test   %eax,%eax
  80052b:	75 0f                	jne    80053c <vprintfmt+0x1be>
  80052d:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800534:	00 00 00 
  800537:	e9 65 fe ff ff       	jmp    8003a1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80053c:	c7 44 24 04 d3 28 80 	movl   $0x8028d3,0x4(%esp)
  800543:	00 
  800544:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800547:	89 0c 24             	mov    %ecx,(%esp)
  80054a:	e8 cc 04 00 00       	call   800a1b <strcmp>
  80054f:	85 c0                	test   %eax,%eax
  800551:	75 0f                	jne    800562 <vprintfmt+0x1e4>
  800553:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  80055a:	00 00 00 
  80055d:	e9 3f fe ff ff       	jmp    8003a1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800562:	c7 44 24 04 d7 28 80 	movl   $0x8028d7,0x4(%esp)
  800569:	00 
  80056a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80056d:	89 3c 24             	mov    %edi,(%esp)
  800570:	e8 a6 04 00 00       	call   800a1b <strcmp>
  800575:	85 c0                	test   %eax,%eax
  800577:	75 0f                	jne    800588 <vprintfmt+0x20a>
  800579:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800580:	00 00 00 
  800583:	e9 19 fe ff ff       	jmp    8003a1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800588:	c7 44 24 04 db 28 80 	movl   $0x8028db,0x4(%esp)
  80058f:	00 
  800590:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 80 04 00 00       	call   800a1b <strcmp>
  80059b:	85 c0                	test   %eax,%eax
  80059d:	75 0f                	jne    8005ae <vprintfmt+0x230>
  80059f:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  8005a6:	00 00 00 
  8005a9:	e9 f3 fd ff ff       	jmp    8003a1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8005ae:	c7 44 24 04 df 28 80 	movl   $0x8028df,0x4(%esp)
  8005b5:	00 
  8005b6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005b9:	89 14 24             	mov    %edx,(%esp)
  8005bc:	e8 5a 04 00 00       	call   800a1b <strcmp>
  8005c1:	83 f8 01             	cmp    $0x1,%eax
  8005c4:	19 c0                	sbb    %eax,%eax
  8005c6:	f7 d0                	not    %eax
  8005c8:	83 c0 08             	add    $0x8,%eax
  8005cb:	a3 04 30 80 00       	mov    %eax,0x803004
  8005d0:	e9 cc fd ff ff       	jmp    8003a1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 c2                	mov    %eax,%edx
  8005e2:	c1 fa 1f             	sar    $0x1f,%edx
  8005e5:	31 d0                	xor    %edx,%eax
  8005e7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e9:	83 f8 0f             	cmp    $0xf,%eax
  8005ec:	7f 0b                	jg     8005f9 <vprintfmt+0x27b>
  8005ee:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  8005f5:	85 d2                	test   %edx,%edx
  8005f7:	75 23                	jne    80061c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005fd:	c7 44 24 08 e3 28 80 	movl   $0x8028e3,0x8(%esp)
  800604:	00 
  800605:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800609:	8b 7d 08             	mov    0x8(%ebp),%edi
  80060c:	89 3c 24             	mov    %edi,(%esp)
  80060f:	e8 42 fd ff ff       	call   800356 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800617:	e9 85 fd ff ff       	jmp    8003a1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	c7 44 24 08 41 2e 80 	movl   $0x802e41,0x8(%esp)
  800627:	00 
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062f:	89 3c 24             	mov    %edi,(%esp)
  800632:	e8 1f fd ff ff       	call   800356 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80063a:	e9 62 fd ff ff       	jmp    8003a1 <vprintfmt+0x23>
  80063f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800642:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800645:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800653:	85 f6                	test   %esi,%esi
  800655:	b8 c4 28 80 00       	mov    $0x8028c4,%eax
  80065a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80065d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800661:	7e 06                	jle    800669 <vprintfmt+0x2eb>
  800663:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800667:	75 13                	jne    80067c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800669:	0f be 06             	movsbl (%esi),%eax
  80066c:	83 c6 01             	add    $0x1,%esi
  80066f:	85 c0                	test   %eax,%eax
  800671:	0f 85 94 00 00 00    	jne    80070b <vprintfmt+0x38d>
  800677:	e9 81 00 00 00       	jmp    8006fd <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800680:	89 34 24             	mov    %esi,(%esp)
  800683:	e8 a3 02 00 00       	call   80092b <strnlen>
  800688:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80068b:	29 c2                	sub    %eax,%edx
  80068d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800690:	85 d2                	test   %edx,%edx
  800692:	7e d5                	jle    800669 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800694:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800698:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80069b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80069e:	89 d6                	mov    %edx,%esi
  8006a0:	89 cf                	mov    %ecx,%edi
  8006a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a6:	89 3c 24             	mov    %edi,(%esp)
  8006a9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	83 ee 01             	sub    $0x1,%esi
  8006af:	75 f1                	jne    8006a2 <vprintfmt+0x324>
  8006b1:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8006b4:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8006b7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8006ba:	eb ad                	jmp    800669 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006bc:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006c0:	74 1b                	je     8006dd <vprintfmt+0x35f>
  8006c2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006c5:	83 fa 5e             	cmp    $0x5e,%edx
  8006c8:	76 13                	jbe    8006dd <vprintfmt+0x35f>
					putch('?', putdat);
  8006ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006d8:	ff 55 08             	call   *0x8(%ebp)
  8006db:	eb 0d                	jmp    8006ea <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8006dd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8006e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ea:	83 eb 01             	sub    $0x1,%ebx
  8006ed:	0f be 06             	movsbl (%esi),%eax
  8006f0:	83 c6 01             	add    $0x1,%esi
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	75 1a                	jne    800711 <vprintfmt+0x393>
  8006f7:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006fa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800700:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800704:	7f 1c                	jg     800722 <vprintfmt+0x3a4>
  800706:	e9 96 fc ff ff       	jmp    8003a1 <vprintfmt+0x23>
  80070b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80070e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800711:	85 ff                	test   %edi,%edi
  800713:	78 a7                	js     8006bc <vprintfmt+0x33e>
  800715:	83 ef 01             	sub    $0x1,%edi
  800718:	79 a2                	jns    8006bc <vprintfmt+0x33e>
  80071a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80071d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800720:	eb db                	jmp    8006fd <vprintfmt+0x37f>
  800722:	8b 7d 08             	mov    0x8(%ebp),%edi
  800725:	89 de                	mov    %ebx,%esi
  800727:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800735:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800737:	83 eb 01             	sub    $0x1,%ebx
  80073a:	75 ee                	jne    80072a <vprintfmt+0x3ac>
  80073c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800741:	e9 5b fc ff ff       	jmp    8003a1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800746:	83 f9 01             	cmp    $0x1,%ecx
  800749:	7e 10                	jle    80075b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 08             	lea    0x8(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 30                	mov    (%eax),%esi
  800756:	8b 78 04             	mov    0x4(%eax),%edi
  800759:	eb 26                	jmp    800781 <vprintfmt+0x403>
	else if (lflag)
  80075b:	85 c9                	test   %ecx,%ecx
  80075d:	74 12                	je     800771 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 30                	mov    (%eax),%esi
  80076a:	89 f7                	mov    %esi,%edi
  80076c:	c1 ff 1f             	sar    $0x1f,%edi
  80076f:	eb 10                	jmp    800781 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8d 50 04             	lea    0x4(%eax),%edx
  800777:	89 55 14             	mov    %edx,0x14(%ebp)
  80077a:	8b 30                	mov    (%eax),%esi
  80077c:	89 f7                	mov    %esi,%edi
  80077e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800781:	85 ff                	test   %edi,%edi
  800783:	78 0e                	js     800793 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800785:	89 f0                	mov    %esi,%eax
  800787:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800789:	be 0a 00 00 00       	mov    $0xa,%esi
  80078e:	e9 84 00 00 00       	jmp    800817 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800793:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800797:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80079e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	89 fa                	mov    %edi,%edx
  8007a5:	f7 d8                	neg    %eax
  8007a7:	83 d2 00             	adc    $0x0,%edx
  8007aa:	f7 da                	neg    %edx
			}
			base = 10;
  8007ac:	be 0a 00 00 00       	mov    $0xa,%esi
  8007b1:	eb 64                	jmp    800817 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b3:	89 ca                	mov    %ecx,%edx
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b8:	e8 42 fb ff ff       	call   8002ff <getuint>
			base = 10;
  8007bd:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8007c2:	eb 53                	jmp    800817 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 31 fb ff ff       	call   8002ff <getuint>
    			base = 8;
  8007ce:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8007d3:	eb 42                	jmp    800817 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8007d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ee:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fa:	8b 00                	mov    (%eax),%eax
  8007fc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800801:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800806:	eb 0f                	jmp    800817 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800808:	89 ca                	mov    %ecx,%edx
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	e8 ed fa ff ff       	call   8002ff <getuint>
			base = 16;
  800812:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800817:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80081b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80081f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800822:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800826:	89 74 24 08          	mov    %esi,0x8(%esp)
  80082a:	89 04 24             	mov    %eax,(%esp)
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	89 da                	mov    %ebx,%edx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	e8 e9 f9 ff ff       	call   800224 <printnum>
			break;
  80083b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80083e:	e9 5e fb ff ff       	jmp    8003a1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800843:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800847:	89 14 24             	mov    %edx,(%esp)
  80084a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800850:	e9 4c fb ff ff       	jmp    8003a1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800855:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800859:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800860:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800863:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800867:	0f 84 34 fb ff ff    	je     8003a1 <vprintfmt+0x23>
  80086d:	83 ee 01             	sub    $0x1,%esi
  800870:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800874:	75 f7                	jne    80086d <vprintfmt+0x4ef>
  800876:	e9 26 fb ff ff       	jmp    8003a1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80087b:	83 c4 5c             	add    $0x5c,%esp
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5f                   	pop    %edi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	83 ec 28             	sub    $0x28,%esp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800892:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800896:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800899:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	74 30                	je     8008d4 <vsnprintf+0x51>
  8008a4:	85 d2                	test   %edx,%edx
  8008a6:	7e 2c                	jle    8008d4 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008af:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bd:	c7 04 24 39 03 80 00 	movl   $0x800339,(%esp)
  8008c4:	e8 b5 fa ff ff       	call   80037e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d2:	eb 05                	jmp    8008d9 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8008eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	89 04 24             	mov    %eax,(%esp)
  8008fc:	e8 82 ff ff ff       	call   800883 <vsnprintf>
	va_end(ap);

	return rc;
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    
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
  800dd3:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800dda:	00 
  800ddb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de2:	00 
  800de3:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800dea:	e8 81 16 00 00       	call   802470 <_panic>

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
  800e92:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800ea9:	e8 c2 15 00 00       	call   802470 <_panic>

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
  800ef0:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eff:	00 
  800f00:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800f07:	e8 64 15 00 00       	call   802470 <_panic>

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
  800f4e:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800f65:	e8 06 15 00 00       	call   802470 <_panic>

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
  800fac:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbb:	00 
  800fbc:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  800fc3:	e8 a8 14 00 00       	call   802470 <_panic>

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
  80100a:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  801011:	00 
  801012:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  801021:	e8 4a 14 00 00       	call   802470 <_panic>

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
  801068:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  80107f:	e8 ec 13 00 00       	call   802470 <_panic>

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
  8010f9:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  801100:	00 
  801101:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  801110:	e8 5b 13 00 00       	call   802470 <_panic>

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
  801166:	c7 44 24 08 ea 2b 80 	movl   $0x802bea,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  80117d:	e8 ee 12 00 00       	call   802470 <_panic>
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
  8011cf:	c7 44 24 08 24 2c 80 	movl   $0x802c24,0x8(%esp)
  8011d6:	00 
  8011d7:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8011de:	00 
  8011df:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  8011e6:	e8 85 12 00 00       	call   802470 <_panic>
		
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
  801239:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  801240:	00 
  801241:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801248:	00 
  801249:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  801250:	e8 1b 12 00 00       	call   802470 <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801255:	c7 44 24 08 70 2c 80 	movl   $0x802c70,0x8(%esp)
  80125c:	00 
  80125d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801264:	00 
  801265:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  80126c:	e8 ff 11 00 00       	call   802470 <_panic>
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
  801287:	e8 3c 12 00 00       	call   8024c8 <set_pgfault_handler>
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
  8012a2:	c7 44 24 08 90 2c 80 	movl   $0x802c90,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  8012b9:	e8 b2 11 00 00       	call   802470 <_panic>
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
  801370:	c7 44 24 08 b0 2c 80 	movl   $0x802cb0,0x8(%esp)
  801377:	00 
  801378:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  80137f:	00 
  801380:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  801387:	e8 e4 10 00 00       	call   802470 <_panic>
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
  8013d3:	c7 44 24 08 dc 2c 80 	movl   $0x802cdc,0x8(%esp)
  8013da:	00 
  8013db:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  8013ea:	e8 81 10 00 00       	call   802470 <_panic>

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
  80141b:	c7 44 24 08 dc 2c 80 	movl   $0x802cdc,0x8(%esp)
  801422:	00 
  801423:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  80142a:	00 
  80142b:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  801432:	e8 39 10 00 00       	call   802470 <_panic>
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
  801462:	c7 44 24 08 dc 2c 80 	movl   $0x802cdc,0x8(%esp)
  801469:	00 
  80146a:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801471:	00 
  801472:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  801479:	e8 f2 0f 00 00       	call   802470 <_panic>
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
  8014b0:	c7 44 24 08 00 2d 80 	movl   $0x802d00,0x8(%esp)
  8014b7:	00 
  8014b8:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8014bf:	00 
  8014c0:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  8014c7:	e8 a4 0f 00 00       	call   802470 <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  8014cc:	c7 44 24 04 54 25 80 	movl   $0x802554,0x4(%esp)
  8014d3:	00 
  8014d4:	89 3c 24             	mov    %edi,(%esp)
  8014d7:	e8 57 fb ff ff       	call   801033 <sys_env_set_pgfault_upcall>
	if (res < 0)
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	79 20                	jns    801500 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  8014e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e4:	c7 44 24 08 24 2d 80 	movl   $0x802d24,0x8(%esp)
  8014eb:	00 
  8014ec:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8014f3:	00 
  8014f4:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  8014fb:	e8 70 0f 00 00       	call   802470 <_panic>

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
  801518:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  80151f:	00 
  801520:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801527:	00 
  801528:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  80152f:	e8 3c 0f 00 00       	call   802470 <_panic>

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
  801544:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  80154b:	00 
  80154c:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801553:	00 
  801554:	c7 04 24 01 2c 80 00 	movl   $0x802c01,(%esp)
  80155b:	e8 10 0f 00 00       	call   802470 <_panic>

00801560 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
  801565:	83 ec 10             	sub    $0x10,%esp
  801568:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80156b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801571:	85 db                	test   %ebx,%ebx
  801573:	74 06                	je     80157b <ipc_recv+0x1b>
  801575:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80157b:	85 f6                	test   %esi,%esi
  80157d:	74 06                	je     801585 <ipc_recv+0x25>
  80157f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801585:	85 c0                	test   %eax,%eax
  801587:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80158c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 2e fb ff ff       	call   8010c5 <sys_ipc_recv>
    if (ret) return ret;
  801597:	85 c0                	test   %eax,%eax
  801599:	75 24                	jne    8015bf <ipc_recv+0x5f>
    if (from_env_store)
  80159b:	85 db                	test   %ebx,%ebx
  80159d:	74 0a                	je     8015a9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80159f:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a4:	8b 40 74             	mov    0x74(%eax),%eax
  8015a7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8015a9:	85 f6                	test   %esi,%esi
  8015ab:	74 0a                	je     8015b7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8015ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b2:	8b 40 78             	mov    0x78(%eax),%eax
  8015b5:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8015b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	5b                   	pop    %ebx
  8015c3:	5e                   	pop    %esi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	57                   	push   %edi
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 1c             	sub    $0x1c,%esp
  8015cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8015d8:	85 db                	test   %ebx,%ebx
  8015da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8015df:	0f 44 d8             	cmove  %eax,%ebx
  8015e2:	eb 2a                	jmp    80160e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8015e4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015e7:	74 20                	je     801609 <ipc_send+0x43>
  8015e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ed:	c7 44 24 08 7a 2d 80 	movl   $0x802d7a,0x8(%esp)
  8015f4:	00 
  8015f5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8015fc:	00 
  8015fd:	c7 04 24 91 2d 80 00 	movl   $0x802d91,(%esp)
  801604:	e8 67 0e 00 00       	call   802470 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801609:	e8 1e f8 ff ff       	call   800e2c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80160e:	8b 45 14             	mov    0x14(%ebp),%eax
  801611:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801615:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80161d:	89 34 24             	mov    %esi,(%esp)
  801620:	e8 6c fa ff ff       	call   801091 <sys_ipc_try_send>
  801625:	85 c0                	test   %eax,%eax
  801627:	75 bb                	jne    8015e4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801629:	83 c4 1c             	add    $0x1c,%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5f                   	pop    %edi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    

00801631 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801637:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80163c:	39 c8                	cmp    %ecx,%eax
  80163e:	74 19                	je     801659 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801640:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801645:	89 c2                	mov    %eax,%edx
  801647:	c1 e2 07             	shl    $0x7,%edx
  80164a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801650:	8b 52 50             	mov    0x50(%edx),%edx
  801653:	39 ca                	cmp    %ecx,%edx
  801655:	75 14                	jne    80166b <ipc_find_env+0x3a>
  801657:	eb 05                	jmp    80165e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80165e:	c1 e0 07             	shl    $0x7,%eax
  801661:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801666:	8b 40 40             	mov    0x40(%eax),%eax
  801669:	eb 0e                	jmp    801679 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80166b:	83 c0 01             	add    $0x1,%eax
  80166e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801673:	75 d0                	jne    801645 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801675:	66 b8 00 00          	mov    $0x0,%ax
}
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    
  80167b:	00 00                	add    %al,(%eax)
  80167d:	00 00                	add    %al,(%eax)
	...

00801680 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	05 00 00 00 30       	add    $0x30000000,%eax
  80168b:	c1 e8 0c             	shr    $0xc,%eax
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	89 04 24             	mov    %eax,(%esp)
  80169c:	e8 df ff ff ff       	call   801680 <fd2num>
  8016a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016b2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016b7:	a8 01                	test   $0x1,%al
  8016b9:	74 34                	je     8016ef <fd_alloc+0x44>
  8016bb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016c0:	a8 01                	test   $0x1,%al
  8016c2:	74 32                	je     8016f6 <fd_alloc+0x4b>
  8016c4:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016c9:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	c1 ea 16             	shr    $0x16,%edx
  8016d0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016d7:	f6 c2 01             	test   $0x1,%dl
  8016da:	74 1f                	je     8016fb <fd_alloc+0x50>
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	c1 ea 0c             	shr    $0xc,%edx
  8016e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016e8:	f6 c2 01             	test   $0x1,%dl
  8016eb:	75 17                	jne    801704 <fd_alloc+0x59>
  8016ed:	eb 0c                	jmp    8016fb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016ef:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8016f4:	eb 05                	jmp    8016fb <fd_alloc+0x50>
  8016f6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8016fb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801702:	eb 17                	jmp    80171b <fd_alloc+0x70>
  801704:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801709:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80170e:	75 b9                	jne    8016c9 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801710:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801716:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80171b:	5b                   	pop    %ebx
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801724:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801729:	83 fa 1f             	cmp    $0x1f,%edx
  80172c:	77 3f                	ja     80176d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80172e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  801734:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801737:	89 d0                	mov    %edx,%eax
  801739:	c1 e8 16             	shr    $0x16,%eax
  80173c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801748:	f6 c1 01             	test   $0x1,%cl
  80174b:	74 20                	je     80176d <fd_lookup+0x4f>
  80174d:	89 d0                	mov    %edx,%eax
  80174f:	c1 e8 0c             	shr    $0xc,%eax
  801752:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80175e:	f6 c1 01             	test   $0x1,%cl
  801761:	74 0a                	je     80176d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801763:	8b 45 0c             	mov    0xc(%ebp),%eax
  801766:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	53                   	push   %ebx
  801773:	83 ec 14             	sub    $0x14,%esp
  801776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801779:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801781:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801787:	75 17                	jne    8017a0 <dev_lookup+0x31>
  801789:	eb 07                	jmp    801792 <dev_lookup+0x23>
  80178b:	39 0a                	cmp    %ecx,(%edx)
  80178d:	75 11                	jne    8017a0 <dev_lookup+0x31>
  80178f:	90                   	nop
  801790:	eb 05                	jmp    801797 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801792:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801797:	89 13                	mov    %edx,(%ebx)
			return 0;
  801799:	b8 00 00 00 00       	mov    $0x0,%eax
  80179e:	eb 35                	jmp    8017d5 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017a0:	83 c0 01             	add    $0x1,%eax
  8017a3:	8b 14 85 18 2e 80 00 	mov    0x802e18(,%eax,4),%edx
  8017aa:	85 d2                	test   %edx,%edx
  8017ac:	75 dd                	jne    80178b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8017b3:	8b 40 48             	mov    0x48(%eax),%eax
  8017b6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017be:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  8017c5:	e8 3d ea ff ff       	call   800207 <cprintf>
	*dev = 0;
  8017ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8017d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017d5:	83 c4 14             	add    $0x14,%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	83 ec 38             	sub    $0x38,%esp
  8017e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8017ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ed:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017f1:	89 3c 24             	mov    %edi,(%esp)
  8017f4:	e8 87 fe ff ff       	call   801680 <fd2num>
  8017f9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8017fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	e8 16 ff ff ff       	call   80171e <fd_lookup>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 05                	js     801813 <fd_close+0x38>
	    || fd != fd2)
  80180e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801811:	74 0e                	je     801821 <fd_close+0x46>
		return (must_exist ? r : 0);
  801813:	89 f0                	mov    %esi,%eax
  801815:	84 c0                	test   %al,%al
  801817:	b8 00 00 00 00       	mov    $0x0,%eax
  80181c:	0f 44 d8             	cmove  %eax,%ebx
  80181f:	eb 3d                	jmp    80185e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801821:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801824:	89 44 24 04          	mov    %eax,0x4(%esp)
  801828:	8b 07                	mov    (%edi),%eax
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	e8 3d ff ff ff       	call   80176f <dev_lookup>
  801832:	89 c3                	mov    %eax,%ebx
  801834:	85 c0                	test   %eax,%eax
  801836:	78 16                	js     80184e <fd_close+0x73>
		if (dev->dev_close)
  801838:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80183b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80183e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801843:	85 c0                	test   %eax,%eax
  801845:	74 07                	je     80184e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801847:	89 3c 24             	mov    %edi,(%esp)
  80184a:	ff d0                	call   *%eax
  80184c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80184e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801852:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801859:	e8 bb f6 ff ff       	call   800f19 <sys_page_unmap>
	return r;
}
  80185e:	89 d8                	mov    %ebx,%eax
  801860:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801863:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801866:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801869:	89 ec                	mov    %ebp,%esp
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801873:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	89 04 24             	mov    %eax,(%esp)
  801880:	e8 99 fe ff ff       	call   80171e <fd_lookup>
  801885:	85 c0                	test   %eax,%eax
  801887:	78 13                	js     80189c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801889:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801890:	00 
  801891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801894:	89 04 24             	mov    %eax,(%esp)
  801897:	e8 3f ff ff ff       	call   8017db <fd_close>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <close_all>:

void
close_all(void)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018aa:	89 1c 24             	mov    %ebx,(%esp)
  8018ad:	e8 bb ff ff ff       	call   80186d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018b2:	83 c3 01             	add    $0x1,%ebx
  8018b5:	83 fb 20             	cmp    $0x20,%ebx
  8018b8:	75 f0                	jne    8018aa <close_all+0xc>
		close(i);
}
  8018ba:	83 c4 14             	add    $0x14,%esp
  8018bd:	5b                   	pop    %ebx
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 58             	sub    $0x58,%esp
  8018c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	89 04 24             	mov    %eax,(%esp)
  8018df:	e8 3a fe ff ff       	call   80171e <fd_lookup>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	0f 88 e1 00 00 00    	js     8019cf <dup+0x10f>
		return r;
	close(newfdnum);
  8018ee:	89 3c 24             	mov    %edi,(%esp)
  8018f1:	e8 77 ff ff ff       	call   80186d <close>

	newfd = INDEX2FD(newfdnum);
  8018f6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8018fc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8018ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	e8 86 fd ff ff       	call   801690 <fd2data>
  80190a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80190c:	89 34 24             	mov    %esi,(%esp)
  80190f:	e8 7c fd ff ff       	call   801690 <fd2data>
  801914:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801917:	89 d8                	mov    %ebx,%eax
  801919:	c1 e8 16             	shr    $0x16,%eax
  80191c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801923:	a8 01                	test   $0x1,%al
  801925:	74 46                	je     80196d <dup+0xad>
  801927:	89 d8                	mov    %ebx,%eax
  801929:	c1 e8 0c             	shr    $0xc,%eax
  80192c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801933:	f6 c2 01             	test   $0x1,%dl
  801936:	74 35                	je     80196d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801938:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80193f:	25 07 0e 00 00       	and    $0xe07,%eax
  801944:	89 44 24 10          	mov    %eax,0x10(%esp)
  801948:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80194b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80194f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801956:	00 
  801957:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801962:	e8 54 f5 ff ff       	call   800ebb <sys_page_map>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 3b                	js     8019a8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80196d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801970:	89 c2                	mov    %eax,%edx
  801972:	c1 ea 0c             	shr    $0xc,%edx
  801975:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80197c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801982:	89 54 24 10          	mov    %edx,0x10(%esp)
  801986:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80198a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801991:	00 
  801992:	89 44 24 04          	mov    %eax,0x4(%esp)
  801996:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199d:	e8 19 f5 ff ff       	call   800ebb <sys_page_map>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	79 25                	jns    8019cd <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b3:	e8 61 f5 ff ff       	call   800f19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c6:	e8 4e f5 ff ff       	call   800f19 <sys_page_unmap>
	return r;
  8019cb:	eb 02                	jmp    8019cf <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8019cd:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019d4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019d7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019da:	89 ec                	mov    %ebp,%esp
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 24             	sub    $0x24,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ef:	89 1c 24             	mov    %ebx,(%esp)
  8019f2:	e8 27 fd ff ff       	call   80171e <fd_lookup>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 6d                	js     801a68 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a05:	8b 00                	mov    (%eax),%eax
  801a07:	89 04 24             	mov    %eax,(%esp)
  801a0a:	e8 60 fd ff ff       	call   80176f <dev_lookup>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 55                	js     801a68 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a16:	8b 50 08             	mov    0x8(%eax),%edx
  801a19:	83 e2 03             	and    $0x3,%edx
  801a1c:	83 fa 01             	cmp    $0x1,%edx
  801a1f:	75 23                	jne    801a44 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a21:	a1 04 40 80 00       	mov    0x804004,%eax
  801a26:	8b 40 48             	mov    0x48(%eax),%eax
  801a29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a31:	c7 04 24 dd 2d 80 00 	movl   $0x802ddd,(%esp)
  801a38:	e8 ca e7 ff ff       	call   800207 <cprintf>
		return -E_INVAL;
  801a3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a42:	eb 24                	jmp    801a68 <read+0x8a>
	}
	if (!dev->dev_read)
  801a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a47:	8b 52 08             	mov    0x8(%edx),%edx
  801a4a:	85 d2                	test   %edx,%edx
  801a4c:	74 15                	je     801a63 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a51:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a58:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	ff d2                	call   *%edx
  801a61:	eb 05                	jmp    801a68 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a63:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801a68:	83 c4 24             	add    $0x24,%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	83 ec 1c             	sub    $0x1c,%esp
  801a77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a82:	85 f6                	test   %esi,%esi
  801a84:	74 30                	je     801ab6 <readn+0x48>
  801a86:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a8b:	89 f2                	mov    %esi,%edx
  801a8d:	29 c2                	sub    %eax,%edx
  801a8f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a93:	03 45 0c             	add    0xc(%ebp),%eax
  801a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9a:	89 3c 24             	mov    %edi,(%esp)
  801a9d:	e8 3c ff ff ff       	call   8019de <read>
		if (m < 0)
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 10                	js     801ab6 <readn+0x48>
			return m;
		if (m == 0)
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	74 0a                	je     801ab4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aaa:	01 c3                	add    %eax,%ebx
  801aac:	89 d8                	mov    %ebx,%eax
  801aae:	39 f3                	cmp    %esi,%ebx
  801ab0:	72 d9                	jb     801a8b <readn+0x1d>
  801ab2:	eb 02                	jmp    801ab6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801ab4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801ab6:	83 c4 1c             	add    $0x1c,%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5f                   	pop    %edi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 24             	sub    $0x24,%esp
  801ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acf:	89 1c 24             	mov    %ebx,(%esp)
  801ad2:	e8 47 fc ff ff       	call   80171e <fd_lookup>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 68                	js     801b43 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae5:	8b 00                	mov    (%eax),%eax
  801ae7:	89 04 24             	mov    %eax,(%esp)
  801aea:	e8 80 fc ff ff       	call   80176f <dev_lookup>
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 50                	js     801b43 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801afa:	75 23                	jne    801b1f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801afc:	a1 04 40 80 00       	mov    0x804004,%eax
  801b01:	8b 40 48             	mov    0x48(%eax),%eax
  801b04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0c:	c7 04 24 f9 2d 80 00 	movl   $0x802df9,(%esp)
  801b13:	e8 ef e6 ff ff       	call   800207 <cprintf>
		return -E_INVAL;
  801b18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b1d:	eb 24                	jmp    801b43 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b22:	8b 52 0c             	mov    0xc(%edx),%edx
  801b25:	85 d2                	test   %edx,%edx
  801b27:	74 15                	je     801b3e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b29:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b2c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b37:	89 04 24             	mov    %eax,(%esp)
  801b3a:	ff d2                	call   *%edx
  801b3c:	eb 05                	jmp    801b43 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b43:	83 c4 24             	add    $0x24,%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b4f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	89 04 24             	mov    %eax,(%esp)
  801b5c:	e8 bd fb ff ff       	call   80171e <fd_lookup>
  801b61:	85 c0                	test   %eax,%eax
  801b63:	78 0e                	js     801b73 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	83 ec 24             	sub    $0x24,%esp
  801b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b86:	89 1c 24             	mov    %ebx,(%esp)
  801b89:	e8 90 fb ff ff       	call   80171e <fd_lookup>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 61                	js     801bf3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9c:	8b 00                	mov    (%eax),%eax
  801b9e:	89 04 24             	mov    %eax,(%esp)
  801ba1:	e8 c9 fb ff ff       	call   80176f <dev_lookup>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 49                	js     801bf3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bb1:	75 23                	jne    801bd6 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bb3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bb8:	8b 40 48             	mov    0x48(%eax),%eax
  801bbb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc3:	c7 04 24 bc 2d 80 00 	movl   $0x802dbc,(%esp)
  801bca:	e8 38 e6 ff ff       	call   800207 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bd4:	eb 1d                	jmp    801bf3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801bd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bd9:	8b 52 18             	mov    0x18(%edx),%edx
  801bdc:	85 d2                	test   %edx,%edx
  801bde:	74 0e                	je     801bee <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801be7:	89 04 24             	mov    %eax,(%esp)
  801bea:	ff d2                	call   *%edx
  801bec:	eb 05                	jmp    801bf3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801bee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801bf3:	83 c4 24             	add    $0x24,%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 24             	sub    $0x24,%esp
  801c00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	89 04 24             	mov    %eax,(%esp)
  801c10:	e8 09 fb ff ff       	call   80171e <fd_lookup>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 52                	js     801c6b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c23:	8b 00                	mov    (%eax),%eax
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 42 fb ff ff       	call   80176f <dev_lookup>
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 3a                	js     801c6b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c34:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c38:	74 2c                	je     801c66 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c3a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c3d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c44:	00 00 00 
	stat->st_isdir = 0;
  801c47:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c4e:	00 00 00 
	stat->st_dev = dev;
  801c51:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5e:	89 14 24             	mov    %edx,(%esp)
  801c61:	ff 50 14             	call   *0x14(%eax)
  801c64:	eb 05                	jmp    801c6b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c6b:	83 c4 24             	add    $0x24,%esp
  801c6e:	5b                   	pop    %ebx
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c7a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c84:	00 
  801c85:	8b 45 08             	mov    0x8(%ebp),%eax
  801c88:	89 04 24             	mov    %eax,(%esp)
  801c8b:	e8 bc 01 00 00       	call   801e4c <open>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	85 c0                	test   %eax,%eax
  801c94:	78 1b                	js     801cb1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9d:	89 1c 24             	mov    %ebx,(%esp)
  801ca0:	e8 54 ff ff ff       	call   801bf9 <fstat>
  801ca5:	89 c6                	mov    %eax,%esi
	close(fd);
  801ca7:	89 1c 24             	mov    %ebx,(%esp)
  801caa:	e8 be fb ff ff       	call   80186d <close>
	return r;
  801caf:	89 f3                	mov    %esi,%ebx
}
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cb6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cb9:	89 ec                	mov    %ebp,%esp
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    
  801cbd:	00 00                	add    %al,(%eax)
	...

00801cc0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 18             	sub    $0x18,%esp
  801cc6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cc9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ccc:	89 c3                	mov    %eax,%ebx
  801cce:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cd0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801cd7:	75 11                	jne    801cea <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ce0:	e8 4c f9 ff ff       	call   801631 <ipc_find_env>
  801ce5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cea:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cf1:	00 
  801cf2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cf9:	00 
  801cfa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cfe:	a1 00 40 80 00       	mov    0x804000,%eax
  801d03:	89 04 24             	mov    %eax,(%esp)
  801d06:	e8 bb f8 ff ff       	call   8015c6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801d0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d12:	00 
  801d13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1e:	e8 3d f8 ff ff       	call   801560 <ipc_recv>
}
  801d23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d26:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d29:	89 ec                	mov    %ebp,%esp
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	53                   	push   %ebx
  801d31:	83 ec 14             	sub    $0x14,%esp
  801d34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d37:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d42:	ba 00 00 00 00       	mov    $0x0,%edx
  801d47:	b8 05 00 00 00       	mov    $0x5,%eax
  801d4c:	e8 6f ff ff ff       	call   801cc0 <fsipc>
  801d51:	85 c0                	test   %eax,%eax
  801d53:	78 2b                	js     801d80 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d55:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d5c:	00 
  801d5d:	89 1c 24             	mov    %ebx,(%esp)
  801d60:	e8 f6 eb ff ff       	call   80095b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d65:	a1 80 50 80 00       	mov    0x805080,%eax
  801d6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d70:	a1 84 50 80 00       	mov    0x805084,%eax
  801d75:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d80:	83 c4 14             	add    $0x14,%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d92:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d97:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801da1:	e8 1a ff ff ff       	call   801cc0 <fsipc>
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	83 ec 10             	sub    $0x10,%esp
  801db0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801db3:	8b 45 08             	mov    0x8(%ebp),%eax
  801db6:	8b 40 0c             	mov    0xc(%eax),%eax
  801db9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801dbe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc9:	b8 03 00 00 00       	mov    $0x3,%eax
  801dce:	e8 ed fe ff ff       	call   801cc0 <fsipc>
  801dd3:	89 c3                	mov    %eax,%ebx
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 6a                	js     801e43 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 24                	jae    801e01 <devfile_read+0x59>
  801ddd:	c7 44 24 0c 28 2e 80 	movl   $0x802e28,0xc(%esp)
  801de4:	00 
  801de5:	c7 44 24 08 2f 2e 80 	movl   $0x802e2f,0x8(%esp)
  801dec:	00 
  801ded:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801df4:	00 
  801df5:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  801dfc:	e8 6f 06 00 00       	call   802470 <_panic>
	assert(r <= PGSIZE);
  801e01:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e06:	7e 24                	jle    801e2c <devfile_read+0x84>
  801e08:	c7 44 24 0c 4f 2e 80 	movl   $0x802e4f,0xc(%esp)
  801e0f:	00 
  801e10:	c7 44 24 08 2f 2e 80 	movl   $0x802e2f,0x8(%esp)
  801e17:	00 
  801e18:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e1f:	00 
  801e20:	c7 04 24 44 2e 80 00 	movl   $0x802e44,(%esp)
  801e27:	e8 44 06 00 00       	call   802470 <_panic>
	memmove(buf, &fsipcbuf, r);
  801e2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e30:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e37:	00 
  801e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3b:	89 04 24             	mov    %eax,(%esp)
  801e3e:	e8 09 ed ff ff       	call   800b4c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801e43:	89 d8                	mov    %ebx,%eax
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
  801e51:	83 ec 20             	sub    $0x20,%esp
  801e54:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e57:	89 34 24             	mov    %esi,(%esp)
  801e5a:	e8 b1 ea ff ff       	call   800910 <strlen>
		return -E_BAD_PATH;
  801e5f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e64:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e69:	7f 5e                	jg     801ec9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 35 f8 ff ff       	call   8016ab <fd_alloc>
  801e76:	89 c3                	mov    %eax,%ebx
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 4d                	js     801ec9 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e80:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e87:	e8 cf ea ff ff       	call   80095b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e97:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9c:	e8 1f fe ff ff       	call   801cc0 <fsipc>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	79 15                	jns    801ebc <open+0x70>
		fd_close(fd, 0);
  801ea7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801eae:	00 
  801eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb2:	89 04 24             	mov    %eax,(%esp)
  801eb5:	e8 21 f9 ff ff       	call   8017db <fd_close>
		return r;
  801eba:	eb 0d                	jmp    801ec9 <open+0x7d>
	}

	return fd2num(fd);
  801ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebf:	89 04 24             	mov    %eax,(%esp)
  801ec2:	e8 b9 f7 ff ff       	call   801680 <fd2num>
  801ec7:	89 c3                	mov    %eax,%ebx
}
  801ec9:	89 d8                	mov    %ebx,%eax
  801ecb:	83 c4 20             	add    $0x20,%esp
  801ece:	5b                   	pop    %ebx
  801ecf:	5e                   	pop    %esi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    
	...

00801ee0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 18             	sub    $0x18,%esp
  801ee6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ee9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801eec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801eef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 96 f7 ff ff       	call   801690 <fd2data>
  801efa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801efc:	c7 44 24 04 5b 2e 80 	movl   $0x802e5b,0x4(%esp)
  801f03:	00 
  801f04:	89 34 24             	mov    %esi,(%esp)
  801f07:	e8 4f ea ff ff       	call   80095b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f0c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0f:	2b 03                	sub    (%ebx),%eax
  801f11:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f17:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f1e:	00 00 00 
	stat->st_dev = &devpipe;
  801f21:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801f28:	30 80 00 
	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f33:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f36:	89 ec                	mov    %ebp,%esp
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 14             	sub    $0x14,%esp
  801f41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4f:	e8 c5 ef ff ff       	call   800f19 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f54:	89 1c 24             	mov    %ebx,(%esp)
  801f57:	e8 34 f7 ff ff       	call   801690 <fd2data>
  801f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f67:	e8 ad ef ff ff       	call   800f19 <sys_page_unmap>
}
  801f6c:	83 c4 14             	add    $0x14,%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 2c             	sub    $0x2c,%esp
  801f7b:	89 c7                	mov    %eax,%edi
  801f7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f80:	a1 04 40 80 00       	mov    0x804004,%eax
  801f85:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f88:	89 3c 24             	mov    %edi,(%esp)
  801f8b:	e8 e8 05 00 00       	call   802578 <pageref>
  801f90:	89 c6                	mov    %eax,%esi
  801f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 db 05 00 00       	call   802578 <pageref>
  801f9d:	39 c6                	cmp    %eax,%esi
  801f9f:	0f 94 c0             	sete   %al
  801fa2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801fa5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fae:	39 cb                	cmp    %ecx,%ebx
  801fb0:	75 08                	jne    801fba <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801fb2:	83 c4 2c             	add    $0x2c,%esp
  801fb5:	5b                   	pop    %ebx
  801fb6:	5e                   	pop    %esi
  801fb7:	5f                   	pop    %edi
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801fba:	83 f8 01             	cmp    $0x1,%eax
  801fbd:	75 c1                	jne    801f80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbf:	8b 52 58             	mov    0x58(%edx),%edx
  801fc2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fce:	c7 04 24 62 2e 80 00 	movl   $0x802e62,(%esp)
  801fd5:	e8 2d e2 ff ff       	call   800207 <cprintf>
  801fda:	eb a4                	jmp    801f80 <_pipeisclosed+0xe>

00801fdc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	57                   	push   %edi
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 2c             	sub    $0x2c,%esp
  801fe5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fe8:	89 34 24             	mov    %esi,(%esp)
  801feb:	e8 a0 f6 ff ff       	call   801690 <fd2data>
  801ff0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ff7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ffb:	75 50                	jne    80204d <devpipe_write+0x71>
  801ffd:	eb 5c                	jmp    80205b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fff:	89 da                	mov    %ebx,%edx
  802001:	89 f0                	mov    %esi,%eax
  802003:	e8 6a ff ff ff       	call   801f72 <_pipeisclosed>
  802008:	85 c0                	test   %eax,%eax
  80200a:	75 53                	jne    80205f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80200c:	e8 1b ee ff ff       	call   800e2c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802011:	8b 43 04             	mov    0x4(%ebx),%eax
  802014:	8b 13                	mov    (%ebx),%edx
  802016:	83 c2 20             	add    $0x20,%edx
  802019:	39 d0                	cmp    %edx,%eax
  80201b:	73 e2                	jae    801fff <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80201d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802020:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802024:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802027:	89 c2                	mov    %eax,%edx
  802029:	c1 fa 1f             	sar    $0x1f,%edx
  80202c:	c1 ea 1b             	shr    $0x1b,%edx
  80202f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802032:	83 e1 1f             	and    $0x1f,%ecx
  802035:	29 d1                	sub    %edx,%ecx
  802037:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80203b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80203f:	83 c0 01             	add    $0x1,%eax
  802042:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802045:	83 c7 01             	add    $0x1,%edi
  802048:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80204b:	74 0e                	je     80205b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80204d:	8b 43 04             	mov    0x4(%ebx),%eax
  802050:	8b 13                	mov    (%ebx),%edx
  802052:	83 c2 20             	add    $0x20,%edx
  802055:	39 d0                	cmp    %edx,%eax
  802057:	73 a6                	jae    801fff <devpipe_write+0x23>
  802059:	eb c2                	jmp    80201d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80205b:	89 f8                	mov    %edi,%eax
  80205d:	eb 05                	jmp    802064 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80205f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802064:	83 c4 2c             	add    $0x2c,%esp
  802067:	5b                   	pop    %ebx
  802068:	5e                   	pop    %esi
  802069:	5f                   	pop    %edi
  80206a:	5d                   	pop    %ebp
  80206b:	c3                   	ret    

0080206c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 28             	sub    $0x28,%esp
  802072:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802075:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802078:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80207b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80207e:	89 3c 24             	mov    %edi,(%esp)
  802081:	e8 0a f6 ff ff       	call   801690 <fd2data>
  802086:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802088:	be 00 00 00 00       	mov    $0x0,%esi
  80208d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802091:	75 47                	jne    8020da <devpipe_read+0x6e>
  802093:	eb 52                	jmp    8020e7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802095:	89 f0                	mov    %esi,%eax
  802097:	eb 5e                	jmp    8020f7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802099:	89 da                	mov    %ebx,%edx
  80209b:	89 f8                	mov    %edi,%eax
  80209d:	8d 76 00             	lea    0x0(%esi),%esi
  8020a0:	e8 cd fe ff ff       	call   801f72 <_pipeisclosed>
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	75 49                	jne    8020f2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  8020a9:	e8 7e ed ff ff       	call   800e2c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020ae:	8b 03                	mov    (%ebx),%eax
  8020b0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020b3:	74 e4                	je     802099 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020b5:	89 c2                	mov    %eax,%edx
  8020b7:	c1 fa 1f             	sar    $0x1f,%edx
  8020ba:	c1 ea 1b             	shr    $0x1b,%edx
  8020bd:	01 d0                	add    %edx,%eax
  8020bf:	83 e0 1f             	and    $0x1f,%eax
  8020c2:	29 d0                	sub    %edx,%eax
  8020c4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020cc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8020cf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d2:	83 c6 01             	add    $0x1,%esi
  8020d5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020d8:	74 0d                	je     8020e7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  8020da:	8b 03                	mov    (%ebx),%eax
  8020dc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020df:	75 d4                	jne    8020b5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020e1:	85 f6                	test   %esi,%esi
  8020e3:	75 b0                	jne    802095 <devpipe_read+0x29>
  8020e5:	eb b2                	jmp    802099 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020e7:	89 f0                	mov    %esi,%eax
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	eb 05                	jmp    8020f7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8020fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8020fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802100:	89 ec                	mov    %ebp,%esp
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    

00802104 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	83 ec 48             	sub    $0x48,%esp
  80210a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80210d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802110:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802113:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802116:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802119:	89 04 24             	mov    %eax,(%esp)
  80211c:	e8 8a f5 ff ff       	call   8016ab <fd_alloc>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	85 c0                	test   %eax,%eax
  802125:	0f 88 45 01 00 00    	js     802270 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802132:	00 
  802133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802141:	e8 16 ed ff ff       	call   800e5c <sys_page_alloc>
  802146:	89 c3                	mov    %eax,%ebx
  802148:	85 c0                	test   %eax,%eax
  80214a:	0f 88 20 01 00 00    	js     802270 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802150:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802153:	89 04 24             	mov    %eax,(%esp)
  802156:	e8 50 f5 ff ff       	call   8016ab <fd_alloc>
  80215b:	89 c3                	mov    %eax,%ebx
  80215d:	85 c0                	test   %eax,%eax
  80215f:	0f 88 f8 00 00 00    	js     80225d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802165:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80216c:	00 
  80216d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802170:	89 44 24 04          	mov    %eax,0x4(%esp)
  802174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217b:	e8 dc ec ff ff       	call   800e5c <sys_page_alloc>
  802180:	89 c3                	mov    %eax,%ebx
  802182:	85 c0                	test   %eax,%eax
  802184:	0f 88 d3 00 00 00    	js     80225d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80218a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218d:	89 04 24             	mov    %eax,(%esp)
  802190:	e8 fb f4 ff ff       	call   801690 <fd2data>
  802195:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802197:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80219e:	00 
  80219f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021aa:	e8 ad ec ff ff       	call   800e5c <sys_page_alloc>
  8021af:	89 c3                	mov    %eax,%ebx
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	0f 88 91 00 00 00    	js     80224a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021bc:	89 04 24             	mov    %eax,(%esp)
  8021bf:	e8 cc f4 ff ff       	call   801690 <fd2data>
  8021c4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8021cb:	00 
  8021cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021d7:	00 
  8021d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e3:	e8 d3 ec ff ff       	call   800ebb <sys_page_map>
  8021e8:	89 c3                	mov    %eax,%ebx
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	78 4c                	js     80223a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021ee:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802203:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802209:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80220c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80220e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802211:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80221b:	89 04 24             	mov    %eax,(%esp)
  80221e:	e8 5d f4 ff ff       	call   801680 <fd2num>
  802223:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802228:	89 04 24             	mov    %eax,(%esp)
  80222b:	e8 50 f4 ff ff       	call   801680 <fd2num>
  802230:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802233:	bb 00 00 00 00       	mov    $0x0,%ebx
  802238:	eb 36                	jmp    802270 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80223a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802245:	e8 cf ec ff ff       	call   800f19 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80224a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80224d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802251:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802258:	e8 bc ec ff ff       	call   800f19 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80225d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802260:	89 44 24 04          	mov    %eax,0x4(%esp)
  802264:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80226b:	e8 a9 ec ff ff       	call   800f19 <sys_page_unmap>
    err:
	return r;
}
  802270:	89 d8                	mov    %ebx,%eax
  802272:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802275:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802278:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80227b:	89 ec                	mov    %ebp,%esp
  80227d:	5d                   	pop    %ebp
  80227e:	c3                   	ret    

0080227f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	89 04 24             	mov    %eax,(%esp)
  802292:	e8 87 f4 ff ff       	call   80171e <fd_lookup>
  802297:	85 c0                	test   %eax,%eax
  802299:	78 15                	js     8022b0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80229b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229e:	89 04 24             	mov    %eax,(%esp)
  8022a1:	e8 ea f3 ff ff       	call   801690 <fd2data>
	return _pipeisclosed(fd, p);
  8022a6:	89 c2                	mov    %eax,%edx
  8022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ab:	e8 c2 fc ff ff       	call   801f72 <_pipeisclosed>
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    
	...

008022c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c8:	5d                   	pop    %ebp
  8022c9:	c3                   	ret    

008022ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8022d0:	c7 44 24 04 7a 2e 80 	movl   $0x802e7a,0x4(%esp)
  8022d7:	00 
  8022d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022db:	89 04 24             	mov    %eax,(%esp)
  8022de:	e8 78 e6 ff ff       	call   80095b <strcpy>
	return 0;
}
  8022e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e8:	c9                   	leave  
  8022e9:	c3                   	ret    

008022ea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	57                   	push   %edi
  8022ee:	56                   	push   %esi
  8022ef:	53                   	push   %ebx
  8022f0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f6:	be 00 00 00 00       	mov    $0x0,%esi
  8022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ff:	74 43                	je     802344 <devcons_write+0x5a>
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802306:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80230c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80230f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802311:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802314:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802319:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80231c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802320:	03 45 0c             	add    0xc(%ebp),%eax
  802323:	89 44 24 04          	mov    %eax,0x4(%esp)
  802327:	89 3c 24             	mov    %edi,(%esp)
  80232a:	e8 1d e8 ff ff       	call   800b4c <memmove>
		sys_cputs(buf, m);
  80232f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	e8 05 ea ff ff       	call   800d40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80233b:	01 de                	add    %ebx,%esi
  80233d:	89 f0                	mov    %esi,%eax
  80233f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802342:	72 c8                	jb     80230c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802344:	89 f0                	mov    %esi,%eax
  802346:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80234c:	5b                   	pop    %ebx
  80234d:	5e                   	pop    %esi
  80234e:	5f                   	pop    %edi
  80234f:	5d                   	pop    %ebp
  802350:	c3                   	ret    

00802351 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802351:	55                   	push   %ebp
  802352:	89 e5                	mov    %esp,%ebp
  802354:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802357:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80235c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802360:	75 07                	jne    802369 <devcons_read+0x18>
  802362:	eb 31                	jmp    802395 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802364:	e8 c3 ea ff ff       	call   800e2c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	e8 fa e9 ff ff       	call   800d6f <sys_cgetc>
  802375:	85 c0                	test   %eax,%eax
  802377:	74 eb                	je     802364 <devcons_read+0x13>
  802379:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80237b:	85 c0                	test   %eax,%eax
  80237d:	78 16                	js     802395 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80237f:	83 f8 04             	cmp    $0x4,%eax
  802382:	74 0c                	je     802390 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802384:	8b 45 0c             	mov    0xc(%ebp),%eax
  802387:	88 10                	mov    %dl,(%eax)
	return 1;
  802389:	b8 01 00 00 00       	mov    $0x1,%eax
  80238e:	eb 05                	jmp    802395 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802390:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802395:	c9                   	leave  
  802396:	c3                   	ret    

00802397 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80239d:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8023aa:	00 
  8023ab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ae:	89 04 24             	mov    %eax,(%esp)
  8023b1:	e8 8a e9 ff ff       	call   800d40 <sys_cputs>
}
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    

008023b8 <getchar>:

int
getchar(void)
{
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
  8023bb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023be:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8023c5:	00 
  8023c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023d4:	e8 05 f6 ff ff       	call   8019de <read>
	if (r < 0)
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	78 0f                	js     8023ec <getchar+0x34>
		return r;
	if (r < 1)
  8023dd:	85 c0                	test   %eax,%eax
  8023df:	7e 06                	jle    8023e7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8023e1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023e5:	eb 05                	jmp    8023ec <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023e7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ec:	c9                   	leave  
  8023ed:	c3                   	ret    

008023ee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fe:	89 04 24             	mov    %eax,(%esp)
  802401:	e8 18 f3 ff ff       	call   80171e <fd_lookup>
  802406:	85 c0                	test   %eax,%eax
  802408:	78 11                	js     80241b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80240a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802413:	39 10                	cmp    %edx,(%eax)
  802415:	0f 94 c0             	sete   %al
  802418:	0f b6 c0             	movzbl %al,%eax
}
  80241b:	c9                   	leave  
  80241c:	c3                   	ret    

0080241d <opencons>:

int
opencons(void)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802426:	89 04 24             	mov    %eax,(%esp)
  802429:	e8 7d f2 ff ff       	call   8016ab <fd_alloc>
  80242e:	85 c0                	test   %eax,%eax
  802430:	78 3c                	js     80246e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802432:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802439:	00 
  80243a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802448:	e8 0f ea ff ff       	call   800e5c <sys_page_alloc>
  80244d:	85 c0                	test   %eax,%eax
  80244f:	78 1d                	js     80246e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802451:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802457:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80245c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802466:	89 04 24             	mov    %eax,(%esp)
  802469:	e8 12 f2 ff ff       	call   801680 <fd2num>
}
  80246e:	c9                   	leave  
  80246f:	c3                   	ret    

00802470 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	56                   	push   %esi
  802474:	53                   	push   %ebx
  802475:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802478:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80247b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802481:	e8 76 e9 ff ff       	call   800dfc <sys_getenvid>
  802486:	8b 55 0c             	mov    0xc(%ebp),%edx
  802489:	89 54 24 10          	mov    %edx,0x10(%esp)
  80248d:	8b 55 08             	mov    0x8(%ebp),%edx
  802490:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802494:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249c:	c7 04 24 88 2e 80 00 	movl   $0x802e88,(%esp)
  8024a3:	e8 5f dd ff ff       	call   800207 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8024af:	89 04 24             	mov    %eax,(%esp)
  8024b2:	e8 ef dc ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  8024b7:	c7 04 24 ff 2b 80 00 	movl   $0x802bff,(%esp)
  8024be:	e8 44 dd ff ff       	call   800207 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8024c3:	cc                   	int3   
  8024c4:	eb fd                	jmp    8024c3 <_panic+0x53>
	...

008024c8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024ce:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024d5:	75 3c                	jne    802513 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8024d7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8024de:	00 
  8024df:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8024e6:	ee 
  8024e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024ee:	e8 69 e9 ff ff       	call   800e5c <sys_page_alloc>
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	79 1c                	jns    802513 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8024f7:	c7 44 24 08 ac 2e 80 	movl   $0x802eac,0x8(%esp)
  8024fe:	00 
  8024ff:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802506:	00 
  802507:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  80250e:	e8 5d ff ff ff       	call   802470 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802513:	8b 45 08             	mov    0x8(%ebp),%eax
  802516:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80251b:	c7 44 24 04 54 25 80 	movl   $0x802554,0x4(%esp)
  802522:	00 
  802523:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80252a:	e8 04 eb ff ff       	call   801033 <sys_env_set_pgfault_upcall>
  80252f:	85 c0                	test   %eax,%eax
  802531:	79 1c                	jns    80254f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802533:	c7 44 24 08 d8 2e 80 	movl   $0x802ed8,0x8(%esp)
  80253a:	00 
  80253b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  802542:	00 
  802543:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  80254a:	e8 21 ff ff ff       	call   802470 <_panic>
}
  80254f:	c9                   	leave  
  802550:	c3                   	ret    
  802551:	00 00                	add    %al,(%eax)
	...

00802554 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802554:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802555:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80255a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80255c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80255f:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  802563:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  802568:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80256c:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80256e:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  802571:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  802572:	83 c4 04             	add    $0x4,%esp
    popfl
  802575:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  802576:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  802577:	c3                   	ret    

00802578 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802578:	55                   	push   %ebp
  802579:	89 e5                	mov    %esp,%ebp
  80257b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80257e:	89 d0                	mov    %edx,%eax
  802580:	c1 e8 16             	shr    $0x16,%eax
  802583:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80258a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80258f:	f6 c1 01             	test   $0x1,%cl
  802592:	74 1d                	je     8025b1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802594:	c1 ea 0c             	shr    $0xc,%edx
  802597:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80259e:	f6 c2 01             	test   $0x1,%dl
  8025a1:	74 0e                	je     8025b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025a3:	c1 ea 0c             	shr    $0xc,%edx
  8025a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025ad:	ef 
  8025ae:	0f b7 c0             	movzwl %ax,%eax
}
  8025b1:	5d                   	pop    %ebp
  8025b2:	c3                   	ret    
	...

008025c0 <__udivdi3>:
  8025c0:	83 ec 1c             	sub    $0x1c,%esp
  8025c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8025c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8025cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8025cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8025d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8025d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8025e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025e5:	89 cd                	mov    %ecx,%ebp
  8025e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025eb:	75 33                	jne    802620 <__udivdi3+0x60>
  8025ed:	39 f1                	cmp    %esi,%ecx
  8025ef:	77 57                	ja     802648 <__udivdi3+0x88>
  8025f1:	85 c9                	test   %ecx,%ecx
  8025f3:	75 0b                	jne    802600 <__udivdi3+0x40>
  8025f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8025fa:	31 d2                	xor    %edx,%edx
  8025fc:	f7 f1                	div    %ecx
  8025fe:	89 c1                	mov    %eax,%ecx
  802600:	89 f0                	mov    %esi,%eax
  802602:	31 d2                	xor    %edx,%edx
  802604:	f7 f1                	div    %ecx
  802606:	89 c6                	mov    %eax,%esi
  802608:	8b 44 24 04          	mov    0x4(%esp),%eax
  80260c:	f7 f1                	div    %ecx
  80260e:	89 f2                	mov    %esi,%edx
  802610:	8b 74 24 10          	mov    0x10(%esp),%esi
  802614:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802618:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80261c:	83 c4 1c             	add    $0x1c,%esp
  80261f:	c3                   	ret    
  802620:	31 d2                	xor    %edx,%edx
  802622:	31 c0                	xor    %eax,%eax
  802624:	39 f7                	cmp    %esi,%edi
  802626:	77 e8                	ja     802610 <__udivdi3+0x50>
  802628:	0f bd cf             	bsr    %edi,%ecx
  80262b:	83 f1 1f             	xor    $0x1f,%ecx
  80262e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802632:	75 2c                	jne    802660 <__udivdi3+0xa0>
  802634:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  802638:	76 04                	jbe    80263e <__udivdi3+0x7e>
  80263a:	39 f7                	cmp    %esi,%edi
  80263c:	73 d2                	jae    802610 <__udivdi3+0x50>
  80263e:	31 d2                	xor    %edx,%edx
  802640:	b8 01 00 00 00       	mov    $0x1,%eax
  802645:	eb c9                	jmp    802610 <__udivdi3+0x50>
  802647:	90                   	nop
  802648:	89 f2                	mov    %esi,%edx
  80264a:	f7 f1                	div    %ecx
  80264c:	31 d2                	xor    %edx,%edx
  80264e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802652:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802656:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	c3                   	ret    
  80265e:	66 90                	xchg   %ax,%ax
  802660:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802665:	b8 20 00 00 00       	mov    $0x20,%eax
  80266a:	89 ea                	mov    %ebp,%edx
  80266c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802670:	d3 e7                	shl    %cl,%edi
  802672:	89 c1                	mov    %eax,%ecx
  802674:	d3 ea                	shr    %cl,%edx
  802676:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80267b:	09 fa                	or     %edi,%edx
  80267d:	89 f7                	mov    %esi,%edi
  80267f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802683:	89 f2                	mov    %esi,%edx
  802685:	8b 74 24 08          	mov    0x8(%esp),%esi
  802689:	d3 e5                	shl    %cl,%ebp
  80268b:	89 c1                	mov    %eax,%ecx
  80268d:	d3 ef                	shr    %cl,%edi
  80268f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802694:	d3 e2                	shl    %cl,%edx
  802696:	89 c1                	mov    %eax,%ecx
  802698:	d3 ee                	shr    %cl,%esi
  80269a:	09 d6                	or     %edx,%esi
  80269c:	89 fa                	mov    %edi,%edx
  80269e:	89 f0                	mov    %esi,%eax
  8026a0:	f7 74 24 0c          	divl   0xc(%esp)
  8026a4:	89 d7                	mov    %edx,%edi
  8026a6:	89 c6                	mov    %eax,%esi
  8026a8:	f7 e5                	mul    %ebp
  8026aa:	39 d7                	cmp    %edx,%edi
  8026ac:	72 22                	jb     8026d0 <__udivdi3+0x110>
  8026ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8026b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026b7:	d3 e5                	shl    %cl,%ebp
  8026b9:	39 c5                	cmp    %eax,%ebp
  8026bb:	73 04                	jae    8026c1 <__udivdi3+0x101>
  8026bd:	39 d7                	cmp    %edx,%edi
  8026bf:	74 0f                	je     8026d0 <__udivdi3+0x110>
  8026c1:	89 f0                	mov    %esi,%eax
  8026c3:	31 d2                	xor    %edx,%edx
  8026c5:	e9 46 ff ff ff       	jmp    802610 <__udivdi3+0x50>
  8026ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8026d3:	31 d2                	xor    %edx,%edx
  8026d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026e1:	83 c4 1c             	add    $0x1c,%esp
  8026e4:	c3                   	ret    
	...

008026f0 <__umoddi3>:
  8026f0:	83 ec 1c             	sub    $0x1c,%esp
  8026f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8026f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8026fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8026ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  802703:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802707:	8b 74 24 24          	mov    0x24(%esp),%esi
  80270b:	85 ed                	test   %ebp,%ebp
  80270d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802711:	89 44 24 08          	mov    %eax,0x8(%esp)
  802715:	89 cf                	mov    %ecx,%edi
  802717:	89 04 24             	mov    %eax,(%esp)
  80271a:	89 f2                	mov    %esi,%edx
  80271c:	75 1a                	jne    802738 <__umoddi3+0x48>
  80271e:	39 f1                	cmp    %esi,%ecx
  802720:	76 4e                	jbe    802770 <__umoddi3+0x80>
  802722:	f7 f1                	div    %ecx
  802724:	89 d0                	mov    %edx,%eax
  802726:	31 d2                	xor    %edx,%edx
  802728:	8b 74 24 10          	mov    0x10(%esp),%esi
  80272c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802730:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802734:	83 c4 1c             	add    $0x1c,%esp
  802737:	c3                   	ret    
  802738:	39 f5                	cmp    %esi,%ebp
  80273a:	77 54                	ja     802790 <__umoddi3+0xa0>
  80273c:	0f bd c5             	bsr    %ebp,%eax
  80273f:	83 f0 1f             	xor    $0x1f,%eax
  802742:	89 44 24 04          	mov    %eax,0x4(%esp)
  802746:	75 60                	jne    8027a8 <__umoddi3+0xb8>
  802748:	3b 0c 24             	cmp    (%esp),%ecx
  80274b:	0f 87 07 01 00 00    	ja     802858 <__umoddi3+0x168>
  802751:	89 f2                	mov    %esi,%edx
  802753:	8b 34 24             	mov    (%esp),%esi
  802756:	29 ce                	sub    %ecx,%esi
  802758:	19 ea                	sbb    %ebp,%edx
  80275a:	89 34 24             	mov    %esi,(%esp)
  80275d:	8b 04 24             	mov    (%esp),%eax
  802760:	8b 74 24 10          	mov    0x10(%esp),%esi
  802764:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802768:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80276c:	83 c4 1c             	add    $0x1c,%esp
  80276f:	c3                   	ret    
  802770:	85 c9                	test   %ecx,%ecx
  802772:	75 0b                	jne    80277f <__umoddi3+0x8f>
  802774:	b8 01 00 00 00       	mov    $0x1,%eax
  802779:	31 d2                	xor    %edx,%edx
  80277b:	f7 f1                	div    %ecx
  80277d:	89 c1                	mov    %eax,%ecx
  80277f:	89 f0                	mov    %esi,%eax
  802781:	31 d2                	xor    %edx,%edx
  802783:	f7 f1                	div    %ecx
  802785:	8b 04 24             	mov    (%esp),%eax
  802788:	f7 f1                	div    %ecx
  80278a:	eb 98                	jmp    802724 <__umoddi3+0x34>
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 f2                	mov    %esi,%edx
  802792:	8b 74 24 10          	mov    0x10(%esp),%esi
  802796:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80279a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80279e:	83 c4 1c             	add    $0x1c,%esp
  8027a1:	c3                   	ret    
  8027a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027ad:	89 e8                	mov    %ebp,%eax
  8027af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8027b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8027b8:	89 fa                	mov    %edi,%edx
  8027ba:	d3 e0                	shl    %cl,%eax
  8027bc:	89 e9                	mov    %ebp,%ecx
  8027be:	d3 ea                	shr    %cl,%edx
  8027c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027c5:	09 c2                	or     %eax,%edx
  8027c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027cb:	89 14 24             	mov    %edx,(%esp)
  8027ce:	89 f2                	mov    %esi,%edx
  8027d0:	d3 e7                	shl    %cl,%edi
  8027d2:	89 e9                	mov    %ebp,%ecx
  8027d4:	d3 ea                	shr    %cl,%edx
  8027d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027df:	d3 e6                	shl    %cl,%esi
  8027e1:	89 e9                	mov    %ebp,%ecx
  8027e3:	d3 e8                	shr    %cl,%eax
  8027e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027ea:	09 f0                	or     %esi,%eax
  8027ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027f0:	f7 34 24             	divl   (%esp)
  8027f3:	d3 e6                	shl    %cl,%esi
  8027f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027f9:	89 d6                	mov    %edx,%esi
  8027fb:	f7 e7                	mul    %edi
  8027fd:	39 d6                	cmp    %edx,%esi
  8027ff:	89 c1                	mov    %eax,%ecx
  802801:	89 d7                	mov    %edx,%edi
  802803:	72 3f                	jb     802844 <__umoddi3+0x154>
  802805:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802809:	72 35                	jb     802840 <__umoddi3+0x150>
  80280b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80280f:	29 c8                	sub    %ecx,%eax
  802811:	19 fe                	sbb    %edi,%esi
  802813:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802818:	89 f2                	mov    %esi,%edx
  80281a:	d3 e8                	shr    %cl,%eax
  80281c:	89 e9                	mov    %ebp,%ecx
  80281e:	d3 e2                	shl    %cl,%edx
  802820:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802825:	09 d0                	or     %edx,%eax
  802827:	89 f2                	mov    %esi,%edx
  802829:	d3 ea                	shr    %cl,%edx
  80282b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80282f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802833:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802837:	83 c4 1c             	add    $0x1c,%esp
  80283a:	c3                   	ret    
  80283b:	90                   	nop
  80283c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802840:	39 d6                	cmp    %edx,%esi
  802842:	75 c7                	jne    80280b <__umoddi3+0x11b>
  802844:	89 d7                	mov    %edx,%edi
  802846:	89 c1                	mov    %eax,%ecx
  802848:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80284c:	1b 3c 24             	sbb    (%esp),%edi
  80284f:	eb ba                	jmp    80280b <__umoddi3+0x11b>
  802851:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802858:	39 f5                	cmp    %esi,%ebp
  80285a:	0f 82 f1 fe ff ff    	jb     802751 <__umoddi3+0x61>
  802860:	e9 f8 fe ff ff       	jmp    80275d <__umoddi3+0x6d>
