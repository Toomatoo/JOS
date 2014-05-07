
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 df 09 00 00       	call   800a10 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int t;

	if (s == 0) {
  80004c:	85 db                	test   %ebx,%ebx
  80004e:	75 23                	jne    800073 <_gettoken+0x33>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800050:	be 00 00 00 00       	mov    $0x0,%esi
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  800055:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80005c:	0f 8e 37 01 00 00    	jle    800199 <_gettoken+0x159>
			cprintf("GETTOKEN NULL\n");
  800062:	c7 04 24 60 3a 80 00 	movl   $0x803a60,(%esp)
  800069:	e8 09 0b 00 00       	call   800b77 <cprintf>
  80006e:	e9 26 01 00 00       	jmp    800199 <_gettoken+0x159>
		return 0;
	}

	if (debug > 1)
  800073:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80007a:	7e 10                	jle    80008c <_gettoken+0x4c>
		cprintf("GETTOKEN: %s\n", s);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	c7 04 24 6f 3a 80 00 	movl   $0x803a6f,(%esp)
  800087:	e8 eb 0a 00 00       	call   800b77 <cprintf>

	*p1 = 0;
  80008c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*p2 = 0;
  800095:	8b 55 10             	mov    0x10(%ebp),%edx
  800098:	c7 02 00 00 00 00    	movl   $0x0,(%edx)

	while (strchr(WHITESPACE, *s))
  80009e:	eb 06                	jmp    8000a6 <_gettoken+0x66>
		*s++ = 0;
  8000a0:	c6 03 00             	movb   $0x0,(%ebx)
  8000a3:	83 c3 01             	add    $0x1,%ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a6:	0f be 03             	movsbl (%ebx),%eax
  8000a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ad:	c7 04 24 7d 3a 80 00 	movl   $0x803a7d,(%esp)
  8000b4:	e8 3d 14 00 00       	call   8014f6 <strchr>
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	75 e3                	jne    8000a0 <_gettoken+0x60>
  8000bd:	89 df                	mov    %ebx,%edi
		*s++ = 0;
	if (*s == 0) {
  8000bf:	0f b6 03             	movzbl (%ebx),%eax
  8000c2:	84 c0                	test   %al,%al
  8000c4:	75 23                	jne    8000e9 <_gettoken+0xa9>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c6:	be 00 00 00 00       	mov    $0x0,%esi
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000cb:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000d2:	0f 8e c1 00 00 00    	jle    800199 <_gettoken+0x159>
			cprintf("EOL\n");
  8000d8:	c7 04 24 82 3a 80 00 	movl   $0x803a82,(%esp)
  8000df:	e8 93 0a 00 00       	call   800b77 <cprintf>
  8000e4:	e9 b0 00 00 00       	jmp    800199 <_gettoken+0x159>
		return 0;
	}
	if (strchr(SYMBOLS, *s)) {
  8000e9:	0f be c0             	movsbl %al,%eax
  8000ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f0:	c7 04 24 93 3a 80 00 	movl   $0x803a93,(%esp)
  8000f7:	e8 fa 13 00 00       	call   8014f6 <strchr>
  8000fc:	85 c0                	test   %eax,%eax
  8000fe:	74 2e                	je     80012e <_gettoken+0xee>
		t = *s;
  800100:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  800103:	8b 45 0c             	mov    0xc(%ebp),%eax
  800106:	89 18                	mov    %ebx,(%eax)
		*s++ = 0;
  800108:	c6 03 00             	movb   $0x0,(%ebx)
  80010b:	83 c7 01             	add    $0x1,%edi
  80010e:	8b 55 10             	mov    0x10(%ebp),%edx
  800111:	89 3a                	mov    %edi,(%edx)
		*p2 = s;
		if (debug > 1)
  800113:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80011a:	7e 7d                	jle    800199 <_gettoken+0x159>
			cprintf("TOK %c\n", t);
  80011c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800120:	c7 04 24 87 3a 80 00 	movl   $0x803a87,(%esp)
  800127:	e8 4b 0a 00 00       	call   800b77 <cprintf>
  80012c:	eb 6b                	jmp    800199 <_gettoken+0x159>
		return t;
	}
	*p1 = s;
  80012e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800131:	89 18                	mov    %ebx,(%eax)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800133:	0f b6 03             	movzbl (%ebx),%eax
  800136:	84 c0                	test   %al,%al
  800138:	75 0c                	jne    800146 <_gettoken+0x106>
  80013a:	eb 21                	jmp    80015d <_gettoken+0x11d>
		s++;
  80013c:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013f:	0f b6 03             	movzbl (%ebx),%eax
  800142:	84 c0                	test   %al,%al
  800144:	74 17                	je     80015d <_gettoken+0x11d>
  800146:	0f be c0             	movsbl %al,%eax
  800149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014d:	c7 04 24 8f 3a 80 00 	movl   $0x803a8f,(%esp)
  800154:	e8 9d 13 00 00       	call   8014f6 <strchr>
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 df                	je     80013c <_gettoken+0xfc>
		s++;
	*p2 = s;
  80015d:	8b 55 10             	mov    0x10(%ebp),%edx
  800160:	89 1a                	mov    %ebx,(%edx)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	be 77 00 00 00       	mov    $0x77,%esi
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80016e:	7e 29                	jle    800199 <_gettoken+0x159>
		t = **p2;
  800170:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	8b 55 0c             	mov    0xc(%ebp),%edx
  800179:	8b 02                	mov    (%edx),%eax
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	c7 04 24 9b 3a 80 00 	movl   $0x803a9b,(%esp)
  800186:	e8 ec 09 00 00       	call   800b77 <cprintf>
		**p2 = t;
  80018b:	8b 55 10             	mov    0x10(%ebp),%edx
  80018e:	8b 02                	mov    (%edx),%eax
  800190:	89 f2                	mov    %esi,%edx
  800192:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800194:	be 77 00 00 00       	mov    $0x77,%esi
}
  800199:	89 f0                	mov    %esi,%eax
  80019b:	83 c4 1c             	add    $0x1c,%esp
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	83 ec 18             	sub    $0x18,%esp
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	74 24                	je     8001d4 <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  8001b0:	c7 44 24 08 08 60 80 	movl   $0x806008,0x8(%esp)
  8001b7:	00 
  8001b8:	c7 44 24 04 04 60 80 	movl   $0x806004,0x4(%esp)
  8001bf:	00 
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 78 fe ff ff       	call   800040 <_gettoken>
  8001c8:	a3 0c 60 80 00       	mov    %eax,0x80600c
		return 0;
  8001cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d2:	eb 3c                	jmp    800210 <gettoken+0x6d>
	}
	c = nc;
  8001d4:	a1 0c 60 80 00       	mov    0x80600c,%eax
  8001d9:	a3 10 60 80 00       	mov    %eax,0x806010
	*p1 = np1;
  8001de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e1:	8b 15 04 60 80 00    	mov    0x806004,%edx
  8001e7:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e9:	c7 44 24 08 08 60 80 	movl   $0x806008,0x8(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 04 04 60 80 	movl   $0x806004,0x4(%esp)
  8001f8:	00 
  8001f9:	a1 08 60 80 00       	mov    0x806008,%eax
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	e8 3a fe ff ff       	call   800040 <_gettoken>
  800206:	a3 0c 60 80 00       	mov    %eax,0x80600c
	return c;
  80020b:	a1 10 60 80 00       	mov    0x806010,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  80021e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800225:	00 
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 72 ff ff ff       	call   8001a3 <gettoken>

again:
	argc = 0;
  800231:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800236:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800239:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80023d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800244:	e8 5a ff ff ff       	call   8001a3 <gettoken>
  800249:	83 f8 77             	cmp    $0x77,%eax
  80024c:	74 37                	je     800285 <runcmd+0x73>
  80024e:	83 f8 77             	cmp    $0x77,%eax
  800251:	7f 20                	jg     800273 <runcmd+0x61>
  800253:	83 f8 3c             	cmp    $0x3c,%eax
  800256:	74 4f                	je     8002a7 <runcmd+0x95>
  800258:	83 f8 3e             	cmp    $0x3e,%eax
  80025b:	0f 84 c8 00 00 00    	je     800329 <runcmd+0x117>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800261:	bf 00 00 00 00       	mov    $0x0,%edi
	gettoken(s, 0);

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800266:	85 c0                	test   %eax,%eax
  800268:	0f 84 49 02 00 00    	je     8004b7 <runcmd+0x2a5>
  80026e:	e9 24 02 00 00       	jmp    800497 <runcmd+0x285>
  800273:	83 f8 7c             	cmp    $0x7c,%eax
  800276:	0f 85 1b 02 00 00    	jne    800497 <runcmd+0x285>
  80027c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800280:	e9 25 01 00 00       	jmp    8003aa <runcmd+0x198>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800285:	83 fe 10             	cmp    $0x10,%esi
  800288:	75 11                	jne    80029b <runcmd+0x89>
				cprintf("too many arguments\n");
  80028a:	c7 04 24 a5 3a 80 00 	movl   $0x803aa5,(%esp)
  800291:	e8 e1 08 00 00       	call   800b77 <cprintf>
				exit();
  800296:	e8 c5 07 00 00       	call   800a60 <exit>
			}
			argv[argc++] = t;
  80029b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80029e:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  8002a2:	83 c6 01             	add    $0x1,%esi
			break;
  8002a5:	eb 92                	jmp    800239 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b2:	e8 ec fe ff ff       	call   8001a3 <gettoken>
  8002b7:	83 f8 77             	cmp    $0x77,%eax
  8002ba:	74 11                	je     8002cd <runcmd+0xbb>
				cprintf("syntax error: < not followed by word\n");
  8002bc:	c7 04 24 f8 3b 80 00 	movl   $0x803bf8,(%esp)
  8002c3:	e8 af 08 00 00       	call   800b77 <cprintf>
				exit();
  8002c8:	e8 93 07 00 00       	call   800a60 <exit>
			}
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002d4:	00 
  8002d5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 0c 26 00 00       	call   8028ec <open>
  8002e0:	89 c7                	mov    %eax,%edi
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	79 1e                	jns    800304 <runcmd+0xf2>
				cprintf("open %s for read: %e", t, fd);
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	c7 04 24 b9 3a 80 00 	movl   $0x803ab9,(%esp)
  8002f8:	e8 7a 08 00 00       	call   800b77 <cprintf>
				exit();
  8002fd:	e8 5e 07 00 00       	call   800a60 <exit>
  800302:	eb 08                	jmp    80030c <runcmd+0xfa>
			}
			if (fd != 0) {
  800304:	85 c0                	test   %eax,%eax
  800306:	0f 84 2d ff ff ff    	je     800239 <runcmd+0x27>
				dup(fd, 0);
  80030c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800313:	00 
  800314:	89 3c 24             	mov    %edi,(%esp)
  800317:	e8 44 20 00 00       	call   802360 <dup>
				close(fd);
  80031c:	89 3c 24             	mov    %edi,(%esp)
  80031f:	e8 e9 1f 00 00       	call   80230d <close>
  800324:	e9 10 ff ff ff       	jmp    800239 <runcmd+0x27>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800329:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800334:	e8 6a fe ff ff       	call   8001a3 <gettoken>
  800339:	83 f8 77             	cmp    $0x77,%eax
  80033c:	74 11                	je     80034f <runcmd+0x13d>
				cprintf("syntax error: > not followed by word\n");
  80033e:	c7 04 24 20 3c 80 00 	movl   $0x803c20,(%esp)
  800345:	e8 2d 08 00 00       	call   800b77 <cprintf>
				exit();
  80034a:	e8 11 07 00 00       	call   800a60 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80034f:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800356:	00 
  800357:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	e8 8a 25 00 00       	call   8028ec <open>
  800362:	89 c7                	mov    %eax,%edi
  800364:	85 c0                	test   %eax,%eax
  800366:	79 1c                	jns    800384 <runcmd+0x172>
				cprintf("open %s for write: %e", t, fd);
  800368:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80036f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800373:	c7 04 24 ce 3a 80 00 	movl   $0x803ace,(%esp)
  80037a:	e8 f8 07 00 00       	call   800b77 <cprintf>
				exit();
  80037f:	e8 dc 06 00 00       	call   800a60 <exit>
			}
			if (fd != 1) {
  800384:	83 ff 01             	cmp    $0x1,%edi
  800387:	0f 84 ac fe ff ff    	je     800239 <runcmd+0x27>
				dup(fd, 1);
  80038d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800394:	00 
  800395:	89 3c 24             	mov    %edi,(%esp)
  800398:	e8 c3 1f 00 00       	call   802360 <dup>
				close(fd);
  80039d:	89 3c 24             	mov    %edi,(%esp)
  8003a0:	e8 68 1f 00 00       	call   80230d <close>
  8003a5:	e9 8f fe ff ff       	jmp    800239 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  8003aa:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 cc 2f 00 00       	call   803384 <pipe>
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	79 15                	jns    8003d1 <runcmd+0x1bf>
				cprintf("pipe: %e", r);
  8003bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c0:	c7 04 24 e4 3a 80 00 	movl   $0x803ae4,(%esp)
  8003c7:	e8 ab 07 00 00       	call   800b77 <cprintf>
				exit();
  8003cc:	e8 8f 06 00 00       	call   800a60 <exit>
			}
			if (debug)
  8003d1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8003d8:	74 20                	je     8003fa <runcmd+0x1e8>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003da:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ee:	c7 04 24 ed 3a 80 00 	movl   $0x803aed,(%esp)
  8003f5:	e8 7d 07 00 00       	call   800b77 <cprintf>
			if ((r = fork()) < 0) {
  8003fa:	e8 d8 18 00 00       	call   801cd7 <fork>
  8003ff:	89 c7                	mov    %eax,%edi
  800401:	85 c0                	test   %eax,%eax
  800403:	79 15                	jns    80041a <runcmd+0x208>
				cprintf("fork: %e", r);
  800405:	89 44 24 04          	mov    %eax,0x4(%esp)
  800409:	c7 04 24 fa 3a 80 00 	movl   $0x803afa,(%esp)
  800410:	e8 62 07 00 00       	call   800b77 <cprintf>
				exit();
  800415:	e8 46 06 00 00       	call   800a60 <exit>
			}
			if (r == 0) {
  80041a:	85 ff                	test   %edi,%edi
  80041c:	75 40                	jne    80045e <runcmd+0x24c>
				if (p[0] != 0) {
  80041e:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800424:	85 c0                	test   %eax,%eax
  800426:	74 1e                	je     800446 <runcmd+0x234>
					dup(p[0], 0);
  800428:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80042f:	00 
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	e8 28 1f 00 00       	call   802360 <dup>
					close(p[0]);
  800438:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80043e:	89 04 24             	mov    %eax,(%esp)
  800441:	e8 c7 1e 00 00       	call   80230d <close>
				}
				close(p[1]);
  800446:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	e8 b9 1e 00 00       	call   80230d <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800454:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  800459:	e9 db fd ff ff       	jmp    800239 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80045e:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800464:	83 f8 01             	cmp    $0x1,%eax
  800467:	74 1e                	je     800487 <runcmd+0x275>
					dup(p[1], 1);
  800469:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800470:	00 
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 e7 1e 00 00       	call   802360 <dup>
					close(p[1]);
  800479:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80047f:	89 04 24             	mov    %eax,(%esp)
  800482:	e8 86 1e 00 00       	call   80230d <close>
				}
				close(p[0]);
  800487:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	e8 78 1e 00 00       	call   80230d <close>
				goto runit;
  800495:	eb 20                	jmp    8004b7 <runcmd+0x2a5>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800497:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049b:	c7 44 24 08 03 3b 80 	movl   $0x803b03,0x8(%esp)
  8004a2:	00 
  8004a3:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
  8004aa:	00 
  8004ab:	c7 04 24 1f 3b 80 00 	movl   $0x803b1f,(%esp)
  8004b2:	e8 c5 05 00 00       	call   800a7c <_panic>
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	75 1e                	jne    8004d9 <runcmd+0x2c7>
		if (debug)
  8004bb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004c2:	0f 84 7b 01 00 00    	je     800643 <runcmd+0x431>
			cprintf("EMPTY COMMAND\n");
  8004c8:	c7 04 24 29 3b 80 00 	movl   $0x803b29,(%esp)
  8004cf:	e8 a3 06 00 00       	call   800b77 <cprintf>
  8004d4:	e9 6a 01 00 00       	jmp    800643 <runcmd+0x431>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004d9:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004dc:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004df:	74 22                	je     800503 <runcmd+0x2f1>
		argv0buf[0] = '/';
  8004e1:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004f2:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 bb 0e 00 00       	call   8013bb <strcpy>
		argv[0] = argv0buf;
  800500:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  800503:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  80050a:	00 

	// Print the command.
	if (debug) {
  80050b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800512:	74 48                	je     80055c <runcmd+0x34a>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  800514:	a1 24 64 80 00       	mov    0x806424,%eax
  800519:	8b 40 48             	mov    0x48(%eax),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 38 3b 80 00 	movl   $0x803b38,(%esp)
  800527:	e8 4b 06 00 00       	call   800b77 <cprintf>
		for (i = 0; argv[i]; i++)
  80052c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80052f:	85 c0                	test   %eax,%eax
  800531:	74 1d                	je     800550 <runcmd+0x33e>
  800533:	8d 5d ac             	lea    -0x54(%ebp),%ebx
			cprintf(" %s", argv[i]);
  800536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053a:	c7 04 24 c3 3b 80 00 	movl   $0x803bc3,(%esp)
  800541:	e8 31 06 00 00       	call   800b77 <cprintf>
  800546:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800549:	8b 43 fc             	mov    -0x4(%ebx),%eax
  80054c:	85 c0                	test   %eax,%eax
  80054e:	75 e6                	jne    800536 <runcmd+0x324>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800550:	c7 04 24 80 3a 80 00 	movl   $0x803a80,(%esp)
  800557:	e8 1b 06 00 00       	call   800b77 <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80055c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	e8 3e 25 00 00       	call   802aac <spawn>
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	85 c0                	test   %eax,%eax
  800572:	79 1e                	jns    800592 <runcmd+0x380>
		cprintf("spawn %s: %e\n", argv[0], r);
  800574:	89 44 24 08          	mov    %eax,0x8(%esp)
  800578:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	c7 04 24 46 3b 80 00 	movl   $0x803b46,(%esp)
  800586:	e8 ec 05 00 00       	call   800b77 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80058b:	e8 ae 1d 00 00       	call   80233e <close_all>
  800590:	eb 5a                	jmp    8005ec <runcmd+0x3da>
  800592:	e8 a7 1d 00 00       	call   80233e <close_all>
	if (r >= 0) {
		if (debug)
  800597:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80059e:	74 23                	je     8005c3 <runcmd+0x3b1>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  8005a0:	a1 24 64 80 00       	mov    0x806424,%eax
  8005a5:	8b 40 48             	mov    0x48(%eax),%eax
  8005a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005ac:	8b 55 a8             	mov    -0x58(%ebp),%edx
  8005af:	89 54 24 08          	mov    %edx,0x8(%esp)
  8005b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b7:	c7 04 24 54 3b 80 00 	movl   $0x803b54,(%esp)
  8005be:	e8 b4 05 00 00       	call   800b77 <cprintf>
		wait(r);
  8005c3:	89 1c 24             	mov    %ebx,(%esp)
  8005c6:	e8 69 2f 00 00       	call   803534 <wait>
		if (debug)
  8005cb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005d2:	74 18                	je     8005ec <runcmd+0x3da>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005d4:	a1 24 64 80 00       	mov    0x806424,%eax
  8005d9:	8b 40 48             	mov    0x48(%eax),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	c7 04 24 69 3b 80 00 	movl   $0x803b69,(%esp)
  8005e7:	e8 8b 05 00 00       	call   800b77 <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005ec:	85 ff                	test   %edi,%edi
  8005ee:	74 4e                	je     80063e <runcmd+0x42c>
		if (debug)
  8005f0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005f7:	74 1c                	je     800615 <runcmd+0x403>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005f9:	a1 24 64 80 00       	mov    0x806424,%eax
  8005fe:	8b 40 48             	mov    0x48(%eax),%eax
  800601:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800605:	89 44 24 04          	mov    %eax,0x4(%esp)
  800609:	c7 04 24 7f 3b 80 00 	movl   $0x803b7f,(%esp)
  800610:	e8 62 05 00 00       	call   800b77 <cprintf>
		wait(pipe_child);
  800615:	89 3c 24             	mov    %edi,(%esp)
  800618:	e8 17 2f 00 00       	call   803534 <wait>
		if (debug)
  80061d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800624:	74 18                	je     80063e <runcmd+0x42c>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800626:	a1 24 64 80 00       	mov    0x806424,%eax
  80062b:	8b 40 48             	mov    0x48(%eax),%eax
  80062e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800632:	c7 04 24 69 3b 80 00 	movl   $0x803b69,(%esp)
  800639:	e8 39 05 00 00       	call   800b77 <cprintf>
	}

	// Done!
	exit();
  80063e:	e8 1d 04 00 00       	call   800a60 <exit>
}
  800643:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <usage>:
}


void
usage(void)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800654:	c7 04 24 48 3c 80 00 	movl   $0x803c48,(%esp)
  80065b:	e8 17 05 00 00       	call   800b77 <cprintf>
	exit();
  800660:	e8 fb 03 00 00       	call   800a60 <exit>
}
  800665:	c9                   	leave  
  800666:	c3                   	ret    

00800667 <umain>:

void
umain(int argc, char **argv)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	57                   	push   %edi
  80066b:	56                   	push   %esi
  80066c:	53                   	push   %ebx
  80066d:	83 ec 4c             	sub    $0x4c,%esp
  800670:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800673:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800676:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067e:	8d 45 08             	lea    0x8(%ebp),%eax
  800681:	89 04 24             	mov    %eax,(%esp)
  800684:	e8 37 19 00 00       	call   801fc0 <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800689:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  800690:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800695:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800698:	eb 2f                	jmp    8006c9 <umain+0x62>
		switch (r) {
  80069a:	83 f8 69             	cmp    $0x69,%eax
  80069d:	74 0c                	je     8006ab <umain+0x44>
  80069f:	83 f8 78             	cmp    $0x78,%eax
  8006a2:	74 1e                	je     8006c2 <umain+0x5b>
  8006a4:	83 f8 64             	cmp    $0x64,%eax
  8006a7:	75 12                	jne    8006bb <umain+0x54>
  8006a9:	eb 07                	jmp    8006b2 <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006ab:	bf 01 00 00 00       	mov    $0x1,%edi
  8006b0:	eb 17                	jmp    8006c9 <umain+0x62>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  8006b2:	83 05 00 60 80 00 01 	addl   $0x1,0x806000
			break;
  8006b9:	eb 0e                	jmp    8006c9 <umain+0x62>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006bb:	e8 8e ff ff ff       	call   80064e <usage>
  8006c0:	eb 07                	jmp    8006c9 <umain+0x62>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  8006c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006c9:	89 1c 24             	mov    %ebx,(%esp)
  8006cc:	e8 1f 19 00 00       	call   801ff0 <argnext>
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	79 c5                	jns    80069a <umain+0x33>
  8006d5:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006d7:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006db:	7e 05                	jle    8006e2 <umain+0x7b>
		usage();
  8006dd:	e8 6c ff ff ff       	call   80064e <usage>
	if (argc == 2) {
  8006e2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006e6:	75 72                	jne    80075a <umain+0xf3>
		close(0);
  8006e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ef:	e8 19 1c 00 00       	call   80230d <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006fb:	00 
  8006fc:	8b 46 04             	mov    0x4(%esi),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 e5 21 00 00       	call   8028ec <open>
  800707:	85 c0                	test   %eax,%eax
  800709:	79 27                	jns    800732 <umain+0xcb>
			panic("open %s: %e", argv[1], r);
  80070b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80070f:	8b 46 04             	mov    0x4(%esi),%eax
  800712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800716:	c7 44 24 08 9f 3b 80 	movl   $0x803b9f,0x8(%esp)
  80071d:	00 
  80071e:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  800725:	00 
  800726:	c7 04 24 1f 3b 80 00 	movl   $0x803b1f,(%esp)
  80072d:	e8 4a 03 00 00       	call   800a7c <_panic>
		assert(r == 0);
  800732:	85 c0                	test   %eax,%eax
  800734:	74 24                	je     80075a <umain+0xf3>
  800736:	c7 44 24 0c ab 3b 80 	movl   $0x803bab,0xc(%esp)
  80073d:	00 
  80073e:	c7 44 24 08 b2 3b 80 	movl   $0x803bb2,0x8(%esp)
  800745:	00 
  800746:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  80074d:	00 
  80074e:	c7 04 24 1f 3b 80 00 	movl   $0x803b1f,(%esp)
  800755:	e8 22 03 00 00       	call   800a7c <_panic>
	}
	if (interactive == '?')
  80075a:	83 fb 3f             	cmp    $0x3f,%ebx
  80075d:	75 0e                	jne    80076d <umain+0x106>
		interactive = iscons(0);
  80075f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800766:	e8 23 02 00 00       	call   80098e <iscons>
  80076b:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80076d:	85 ff                	test   %edi,%edi
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	ba 9c 3b 80 00       	mov    $0x803b9c,%edx
  800779:	0f 45 c2             	cmovne %edx,%eax
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	e8 fc 0a 00 00       	call   801280 <readline>
  800784:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800786:	85 c0                	test   %eax,%eax
  800788:	75 1a                	jne    8007a4 <umain+0x13d>
			if (debug)
  80078a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800791:	74 0c                	je     80079f <umain+0x138>
				cprintf("EXITING\n");
  800793:	c7 04 24 c7 3b 80 00 	movl   $0x803bc7,(%esp)
  80079a:	e8 d8 03 00 00       	call   800b77 <cprintf>
			exit();	// end of file
  80079f:	e8 bc 02 00 00       	call   800a60 <exit>
		}
		if (debug)
  8007a4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007ab:	74 10                	je     8007bd <umain+0x156>
			cprintf("LINE: %s\n", buf);
  8007ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b1:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  8007b8:	e8 ba 03 00 00       	call   800b77 <cprintf>
		if (buf[0] == '#')
  8007bd:	80 3b 23             	cmpb   $0x23,(%ebx)
  8007c0:	74 ab                	je     80076d <umain+0x106>
			continue;
		if (echocmds)
  8007c2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007c6:	74 10                	je     8007d8 <umain+0x171>
			printf("# %s\n", buf);
  8007c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cc:	c7 04 24 da 3b 80 00 	movl   $0x803bda,(%esp)
  8007d3:	e8 b1 22 00 00       	call   802a89 <printf>
		if (debug)
  8007d8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007df:	74 0c                	je     8007ed <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007e1:	c7 04 24 e0 3b 80 00 	movl   $0x803be0,(%esp)
  8007e8:	e8 8a 03 00 00       	call   800b77 <cprintf>
		if ((r = fork()) < 0)
  8007ed:	e8 e5 14 00 00       	call   801cd7 <fork>
  8007f2:	89 c6                	mov    %eax,%esi
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	79 20                	jns    800818 <umain+0x1b1>
			panic("fork: %e", r);
  8007f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fc:	c7 44 24 08 fa 3a 80 	movl   $0x803afa,0x8(%esp)
  800803:	00 
  800804:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  80080b:	00 
  80080c:	c7 04 24 1f 3b 80 00 	movl   $0x803b1f,(%esp)
  800813:	e8 64 02 00 00       	call   800a7c <_panic>
		if (debug)
  800818:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80081f:	74 10                	je     800831 <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	c7 04 24 ed 3b 80 00 	movl   $0x803bed,(%esp)
  80082c:	e8 46 03 00 00       	call   800b77 <cprintf>
		if (r == 0) {
  800831:	85 f6                	test   %esi,%esi
  800833:	75 12                	jne    800847 <umain+0x1e0>
			runcmd(buf);
  800835:	89 1c 24             	mov    %ebx,(%esp)
  800838:	e8 d5 f9 ff ff       	call   800212 <runcmd>
			exit();
  80083d:	e8 1e 02 00 00       	call   800a60 <exit>
  800842:	e9 26 ff ff ff       	jmp    80076d <umain+0x106>
		} else
			wait(r);
  800847:	89 34 24             	mov    %esi,(%esp)
  80084a:	e8 e5 2c 00 00       	call   803534 <wait>
  80084f:	90                   	nop
  800850:	e9 18 ff ff ff       	jmp    80076d <umain+0x106>
	...

00800860 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800870:	c7 44 24 04 69 3c 80 	movl   $0x803c69,0x4(%esp)
  800877:	00 
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 38 0b 00 00       	call   8013bb <strcpy>
	return 0;
}
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800896:	be 00 00 00 00       	mov    $0x0,%esi
  80089b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80089f:	74 43                	je     8008e4 <devcons_write+0x5a>
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8008a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8008ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008af:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8008b1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8008b4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8008b9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8008bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008c0:	03 45 0c             	add    0xc(%ebp),%eax
  8008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c7:	89 3c 24             	mov    %edi,(%esp)
  8008ca:	e8 dd 0c 00 00       	call   8015ac <memmove>
		sys_cputs(buf, m);
  8008cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d3:	89 3c 24             	mov    %edi,(%esp)
  8008d6:	e8 c5 0e 00 00       	call   8017a0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008db:	01 de                	add    %ebx,%esi
  8008dd:	89 f0                	mov    %esi,%eax
  8008df:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008e2:	72 c8                	jb     8008ac <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008e4:	89 f0                	mov    %esi,%eax
  8008e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8008fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800900:	75 07                	jne    800909 <devcons_read+0x18>
  800902:	eb 31                	jmp    800935 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800904:	e8 83 0f 00 00       	call   80188c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800910:	e8 ba 0e 00 00       	call   8017cf <sys_cgetc>
  800915:	85 c0                	test   %eax,%eax
  800917:	74 eb                	je     800904 <devcons_read+0x13>
  800919:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80091b:	85 c0                	test   %eax,%eax
  80091d:	78 16                	js     800935 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80091f:	83 f8 04             	cmp    $0x4,%eax
  800922:	74 0c                	je     800930 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	88 10                	mov    %dl,(%eax)
	return 1;
  800929:	b8 01 00 00 00       	mov    $0x1,%eax
  80092e:	eb 05                	jmp    800935 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800943:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80094a:	00 
  80094b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80094e:	89 04 24             	mov    %eax,(%esp)
  800951:	e8 4a 0e 00 00       	call   8017a0 <sys_cputs>
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <getchar>:

int
getchar(void)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80095e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800965:	00 
  800966:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800974:	e8 05 1b 00 00       	call   80247e <read>
	if (r < 0)
  800979:	85 c0                	test   %eax,%eax
  80097b:	78 0f                	js     80098c <getchar+0x34>
		return r;
	if (r < 1)
  80097d:	85 c0                	test   %eax,%eax
  80097f:	7e 06                	jle    800987 <getchar+0x2f>
		return -E_EOF;
	return c;
  800981:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800985:	eb 05                	jmp    80098c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800987:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800994:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 18 18 00 00       	call   8021be <fd_lookup>
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	78 11                	js     8009bb <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8009aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ad:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009b3:	39 10                	cmp    %edx,(%eax)
  8009b5:	0f 94 c0             	sete   %al
  8009b8:	0f b6 c0             	movzbl %al,%eax
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <opencons>:

int
opencons(void)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8009c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 7d 17 00 00       	call   80214b <fd_alloc>
  8009ce:	85 c0                	test   %eax,%eax
  8009d0:	78 3c                	js     800a0e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8009d9:	00 
  8009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009e8:	e8 cf 0e 00 00       	call   8018bc <sys_page_alloc>
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	78 1d                	js     800a0e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009f1:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800a06:	89 04 24             	mov    %eax,(%esp)
  800a09:	e8 12 17 00 00       	call   802120 <fd2num>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 18             	sub    $0x18,%esp
  800a16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800a19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800a1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800a22:	e8 35 0e 00 00       	call   80185c <sys_getenvid>
  800a27:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a2c:	c1 e0 07             	shl    $0x7,%eax
  800a2f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a34:	a3 24 64 80 00       	mov    %eax,0x806424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a39:	85 f6                	test   %esi,%esi
  800a3b:	7e 07                	jle    800a44 <libmain+0x34>
		binaryname = argv[0];
  800a3d:	8b 03                	mov    (%ebx),%eax
  800a3f:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  800a44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a48:	89 34 24             	mov    %esi,(%esp)
  800a4b:	e8 17 fc ff ff       	call   800667 <umain>

	// exit gracefully
	exit();
  800a50:	e8 0b 00 00 00       	call   800a60 <exit>
}
  800a55:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800a58:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800a5b:	89 ec                	mov    %ebp,%esp
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    
	...

00800a60 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800a66:	e8 d3 18 00 00       	call   80233e <close_all>
	sys_env_destroy(0);
  800a6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a72:	e8 88 0d 00 00       	call   8017ff <sys_env_destroy>
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    
  800a79:	00 00                	add    %al,(%eax)
	...

00800a7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a84:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a87:	8b 1d 1c 50 80 00    	mov    0x80501c,%ebx
  800a8d:	e8 ca 0d 00 00       	call   80185c <sys_getenvid>
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	c7 04 24 80 3c 80 00 	movl   $0x803c80,(%esp)
  800aaf:	e8 c3 00 00 00       	call   800b77 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ab4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 53 00 00 00       	call   800b16 <vcprintf>
	cprintf("\n");
  800ac3:	c7 04 24 80 3a 80 00 	movl   $0x803a80,(%esp)
  800aca:	e8 a8 00 00 00       	call   800b77 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800acf:	cc                   	int3   
  800ad0:	eb fd                	jmp    800acf <_panic+0x53>
	...

00800ad4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 14             	sub    $0x14,%esp
  800adb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ade:	8b 03                	mov    (%ebx),%eax
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800aec:	3d ff 00 00 00       	cmp    $0xff,%eax
  800af1:	75 19                	jne    800b0c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800af3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800afa:	00 
  800afb:	8d 43 08             	lea    0x8(%ebx),%eax
  800afe:	89 04 24             	mov    %eax,(%esp)
  800b01:	e8 9a 0c 00 00       	call   8017a0 <sys_cputs>
		b->idx = 0;
  800b06:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800b0c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800b10:	83 c4 14             	add    $0x14,%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800b1f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b26:	00 00 00 
	b.cnt = 0;
  800b29:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b30:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b41:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4b:	c7 04 24 d4 0a 80 00 	movl   $0x800ad4,(%esp)
  800b52:	e8 97 01 00 00       	call   800cee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b57:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b61:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b67:	89 04 24             	mov    %eax,(%esp)
  800b6a:	e8 31 0c 00 00       	call   8017a0 <sys_cputs>

	return b.cnt;
}
  800b6f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b7d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	89 04 24             	mov    %eax,(%esp)
  800b8a:	e8 87 ff ff ff       	call   800b16 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    
  800b91:	00 00                	add    %al,(%eax)
	...

00800b94 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 3c             	sub    $0x3c,%esp
  800b9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ba0:	89 d7                	mov    %edx,%edi
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800bb1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800bbc:	72 11                	jb     800bcf <printnum+0x3b>
  800bbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bc1:	39 45 10             	cmp    %eax,0x10(%ebp)
  800bc4:	76 09                	jbe    800bcf <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bc6:	83 eb 01             	sub    $0x1,%ebx
  800bc9:	85 db                	test   %ebx,%ebx
  800bcb:	7f 51                	jg     800c1e <printnum+0x8a>
  800bcd:	eb 5e                	jmp    800c2d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800bcf:	89 74 24 10          	mov    %esi,0x10(%esp)
  800bd3:	83 eb 01             	sub    $0x1,%ebx
  800bd6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800bda:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800be5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800be9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bf0:	00 
  800bf1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bf4:	89 04 24             	mov    %eax,(%esp)
  800bf7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfe:	e8 ad 2b 00 00       	call   8037b0 <__udivdi3>
  800c03:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c07:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c0b:	89 04 24             	mov    %eax,(%esp)
  800c0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c12:	89 fa                	mov    %edi,%edx
  800c14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c17:	e8 78 ff ff ff       	call   800b94 <printnum>
  800c1c:	eb 0f                	jmp    800c2d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800c1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c22:	89 34 24             	mov    %esi,(%esp)
  800c25:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800c28:	83 eb 01             	sub    $0x1,%ebx
  800c2b:	75 f1                	jne    800c1e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800c2d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c31:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c35:	8b 45 10             	mov    0x10(%ebp),%eax
  800c38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800c43:	00 
  800c44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800c47:	89 04 24             	mov    %eax,(%esp)
  800c4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	e8 8a 2c 00 00       	call   8038e0 <__umoddi3>
  800c56:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c5a:	0f be 80 a3 3c 80 00 	movsbl 0x803ca3(%eax),%eax
  800c61:	89 04 24             	mov    %eax,(%esp)
  800c64:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800c67:	83 c4 3c             	add    $0x3c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c72:	83 fa 01             	cmp    $0x1,%edx
  800c75:	7e 0e                	jle    800c85 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c77:	8b 10                	mov    (%eax),%edx
  800c79:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c7c:	89 08                	mov    %ecx,(%eax)
  800c7e:	8b 02                	mov    (%edx),%eax
  800c80:	8b 52 04             	mov    0x4(%edx),%edx
  800c83:	eb 22                	jmp    800ca7 <getuint+0x38>
	else if (lflag)
  800c85:	85 d2                	test   %edx,%edx
  800c87:	74 10                	je     800c99 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c89:	8b 10                	mov    (%eax),%edx
  800c8b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c8e:	89 08                	mov    %ecx,(%eax)
  800c90:	8b 02                	mov    (%edx),%eax
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	eb 0e                	jmp    800ca7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c99:	8b 10                	mov    (%eax),%edx
  800c9b:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c9e:	89 08                	mov    %ecx,(%eax)
  800ca0:	8b 02                	mov    (%edx),%eax
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800caf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800cb3:	8b 10                	mov    (%eax),%edx
  800cb5:	3b 50 04             	cmp    0x4(%eax),%edx
  800cb8:	73 0a                	jae    800cc4 <sprintputch+0x1b>
		*b->buf++ = ch;
  800cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbd:	88 0a                	mov    %cl,(%edx)
  800cbf:	83 c2 01             	add    $0x1,%edx
  800cc2:	89 10                	mov    %edx,(%eax)
}
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800ccc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce4:	89 04 24             	mov    %eax,(%esp)
  800ce7:	e8 02 00 00 00       	call   800cee <vprintfmt>
	va_end(ap);
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 5c             	sub    $0x5c,%esp
  800cf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cfa:	8b 75 10             	mov    0x10(%ebp),%esi
  800cfd:	eb 12                	jmp    800d11 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800cff:	85 c0                	test   %eax,%eax
  800d01:	0f 84 e4 04 00 00    	je     8011eb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800d07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d0b:	89 04 24             	mov    %eax,(%esp)
  800d0e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d11:	0f b6 06             	movzbl (%esi),%eax
  800d14:	83 c6 01             	add    $0x1,%esi
  800d17:	83 f8 25             	cmp    $0x25,%eax
  800d1a:	75 e3                	jne    800cff <vprintfmt+0x11>
  800d1c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800d20:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800d27:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800d2c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800d33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d38:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800d3b:	eb 2b                	jmp    800d68 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800d40:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800d44:	eb 22                	jmp    800d68 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d46:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800d49:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800d4d:	eb 19                	jmp    800d68 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d4f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800d52:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800d59:	eb 0d                	jmp    800d68 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800d5b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800d5e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800d61:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d68:	0f b6 06             	movzbl (%esi),%eax
  800d6b:	0f b6 d0             	movzbl %al,%edx
  800d6e:	8d 7e 01             	lea    0x1(%esi),%edi
  800d71:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800d74:	83 e8 23             	sub    $0x23,%eax
  800d77:	3c 55                	cmp    $0x55,%al
  800d79:	0f 87 46 04 00 00    	ja     8011c5 <vprintfmt+0x4d7>
  800d7f:	0f b6 c0             	movzbl %al,%eax
  800d82:	ff 24 85 00 3e 80 00 	jmp    *0x803e00(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d89:	83 ea 30             	sub    $0x30,%edx
  800d8c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800d8f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800d93:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d96:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800d99:	83 fa 09             	cmp    $0x9,%edx
  800d9c:	77 4a                	ja     800de8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800da1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800da4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800da7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800dab:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800dae:	8d 50 d0             	lea    -0x30(%eax),%edx
  800db1:	83 fa 09             	cmp    $0x9,%edx
  800db4:	76 eb                	jbe    800da1 <vprintfmt+0xb3>
  800db6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800db9:	eb 2d                	jmp    800de8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800dbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbe:	8d 50 04             	lea    0x4(%eax),%edx
  800dc1:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc4:	8b 00                	mov    (%eax),%eax
  800dc6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dc9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800dcc:	eb 1a                	jmp    800de8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800dd1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800dd5:	79 91                	jns    800d68 <vprintfmt+0x7a>
  800dd7:	e9 73 ff ff ff       	jmp    800d4f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ddc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800ddf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800de6:	eb 80                	jmp    800d68 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800de8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800dec:	0f 89 76 ff ff ff    	jns    800d68 <vprintfmt+0x7a>
  800df2:	e9 64 ff ff ff       	jmp    800d5b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800df7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dfa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800dfd:	e9 66 ff ff ff       	jmp    800d68 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800e02:	8b 45 14             	mov    0x14(%ebp),%eax
  800e05:	8d 50 04             	lea    0x4(%eax),%edx
  800e08:	89 55 14             	mov    %edx,0x14(%ebp)
  800e0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e0f:	8b 00                	mov    (%eax),%eax
  800e11:	89 04 24             	mov    %eax,(%esp)
  800e14:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e17:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800e1a:	e9 f2 fe ff ff       	jmp    800d11 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800e1f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800e23:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800e26:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800e2a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800e2d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800e31:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800e34:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800e37:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800e3b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800e3e:	80 f9 09             	cmp    $0x9,%cl
  800e41:	77 1d                	ja     800e60 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800e43:	0f be c0             	movsbl %al,%eax
  800e46:	6b c0 64             	imul   $0x64,%eax,%eax
  800e49:	0f be d2             	movsbl %dl,%edx
  800e4c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800e4f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800e56:	a3 20 50 80 00       	mov    %eax,0x805020
  800e5b:	e9 b1 fe ff ff       	jmp    800d11 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800e60:	c7 44 24 04 bb 3c 80 	movl   $0x803cbb,0x4(%esp)
  800e67:	00 
  800e68:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e6b:	89 04 24             	mov    %eax,(%esp)
  800e6e:	e8 08 06 00 00       	call   80147b <strcmp>
  800e73:	85 c0                	test   %eax,%eax
  800e75:	75 0f                	jne    800e86 <vprintfmt+0x198>
  800e77:	c7 05 20 50 80 00 04 	movl   $0x4,0x805020
  800e7e:	00 00 00 
  800e81:	e9 8b fe ff ff       	jmp    800d11 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800e86:	c7 44 24 04 bf 3c 80 	movl   $0x803cbf,0x4(%esp)
  800e8d:	00 
  800e8e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800e91:	89 14 24             	mov    %edx,(%esp)
  800e94:	e8 e2 05 00 00       	call   80147b <strcmp>
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	75 0f                	jne    800eac <vprintfmt+0x1be>
  800e9d:	c7 05 20 50 80 00 02 	movl   $0x2,0x805020
  800ea4:	00 00 00 
  800ea7:	e9 65 fe ff ff       	jmp    800d11 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800eac:	c7 44 24 04 c3 3c 80 	movl   $0x803cc3,0x4(%esp)
  800eb3:	00 
  800eb4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800eb7:	89 0c 24             	mov    %ecx,(%esp)
  800eba:	e8 bc 05 00 00       	call   80147b <strcmp>
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	75 0f                	jne    800ed2 <vprintfmt+0x1e4>
  800ec3:	c7 05 20 50 80 00 01 	movl   $0x1,0x805020
  800eca:	00 00 00 
  800ecd:	e9 3f fe ff ff       	jmp    800d11 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800ed2:	c7 44 24 04 c7 3c 80 	movl   $0x803cc7,0x4(%esp)
  800ed9:	00 
  800eda:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800edd:	89 3c 24             	mov    %edi,(%esp)
  800ee0:	e8 96 05 00 00       	call   80147b <strcmp>
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	75 0f                	jne    800ef8 <vprintfmt+0x20a>
  800ee9:	c7 05 20 50 80 00 06 	movl   $0x6,0x805020
  800ef0:	00 00 00 
  800ef3:	e9 19 fe ff ff       	jmp    800d11 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800ef8:	c7 44 24 04 cb 3c 80 	movl   $0x803ccb,0x4(%esp)
  800eff:	00 
  800f00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f03:	89 04 24             	mov    %eax,(%esp)
  800f06:	e8 70 05 00 00       	call   80147b <strcmp>
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	75 0f                	jne    800f1e <vprintfmt+0x230>
  800f0f:	c7 05 20 50 80 00 07 	movl   $0x7,0x805020
  800f16:	00 00 00 
  800f19:	e9 f3 fd ff ff       	jmp    800d11 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800f1e:	c7 44 24 04 cf 3c 80 	movl   $0x803ccf,0x4(%esp)
  800f25:	00 
  800f26:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f29:	89 14 24             	mov    %edx,(%esp)
  800f2c:	e8 4a 05 00 00       	call   80147b <strcmp>
  800f31:	83 f8 01             	cmp    $0x1,%eax
  800f34:	19 c0                	sbb    %eax,%eax
  800f36:	f7 d0                	not    %eax
  800f38:	83 c0 08             	add    $0x8,%eax
  800f3b:	a3 20 50 80 00       	mov    %eax,0x805020
  800f40:	e9 cc fd ff ff       	jmp    800d11 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800f45:	8b 45 14             	mov    0x14(%ebp),%eax
  800f48:	8d 50 04             	lea    0x4(%eax),%edx
  800f4b:	89 55 14             	mov    %edx,0x14(%ebp)
  800f4e:	8b 00                	mov    (%eax),%eax
  800f50:	89 c2                	mov    %eax,%edx
  800f52:	c1 fa 1f             	sar    $0x1f,%edx
  800f55:	31 d0                	xor    %edx,%eax
  800f57:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800f59:	83 f8 0f             	cmp    $0xf,%eax
  800f5c:	7f 0b                	jg     800f69 <vprintfmt+0x27b>
  800f5e:	8b 14 85 60 3f 80 00 	mov    0x803f60(,%eax,4),%edx
  800f65:	85 d2                	test   %edx,%edx
  800f67:	75 23                	jne    800f8c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6d:	c7 44 24 08 d3 3c 80 	movl   $0x803cd3,0x8(%esp)
  800f74:	00 
  800f75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f7c:	89 3c 24             	mov    %edi,(%esp)
  800f7f:	e8 42 fd ff ff       	call   800cc6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f84:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800f87:	e9 85 fd ff ff       	jmp    800d11 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800f8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f90:	c7 44 24 08 c4 3b 80 	movl   $0x803bc4,0x8(%esp)
  800f97:	00 
  800f98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f9f:	89 3c 24             	mov    %edi,(%esp)
  800fa2:	e8 1f fd ff ff       	call   800cc6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800faa:	e9 62 fd ff ff       	jmp    800d11 <vprintfmt+0x23>
  800faf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800fb2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800fb5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800fb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbb:	8d 50 04             	lea    0x4(%eax),%edx
  800fbe:	89 55 14             	mov    %edx,0x14(%ebp)
  800fc1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800fc3:	85 f6                	test   %esi,%esi
  800fc5:	b8 b4 3c 80 00       	mov    $0x803cb4,%eax
  800fca:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800fcd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800fd1:	7e 06                	jle    800fd9 <vprintfmt+0x2eb>
  800fd3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800fd7:	75 13                	jne    800fec <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800fd9:	0f be 06             	movsbl (%esi),%eax
  800fdc:	83 c6 01             	add    $0x1,%esi
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	0f 85 94 00 00 00    	jne    80107b <vprintfmt+0x38d>
  800fe7:	e9 81 00 00 00       	jmp    80106d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800fec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ff0:	89 34 24             	mov    %esi,(%esp)
  800ff3:	e8 93 03 00 00       	call   80138b <strnlen>
  800ff8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800ffb:	29 c2                	sub    %eax,%edx
  800ffd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801000:	85 d2                	test   %edx,%edx
  801002:	7e d5                	jle    800fd9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  801004:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  801008:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80100b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80100e:	89 d6                	mov    %edx,%esi
  801010:	89 cf                	mov    %ecx,%edi
  801012:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801016:	89 3c 24             	mov    %edi,(%esp)
  801019:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80101c:	83 ee 01             	sub    $0x1,%esi
  80101f:	75 f1                	jne    801012 <vprintfmt+0x324>
  801021:	8b 7d c0             	mov    -0x40(%ebp),%edi
  801024:	89 75 cc             	mov    %esi,-0x34(%ebp)
  801027:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80102a:	eb ad                	jmp    800fd9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80102c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  801030:	74 1b                	je     80104d <vprintfmt+0x35f>
  801032:	8d 50 e0             	lea    -0x20(%eax),%edx
  801035:	83 fa 5e             	cmp    $0x5e,%edx
  801038:	76 13                	jbe    80104d <vprintfmt+0x35f>
					putch('?', putdat);
  80103a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80103d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801041:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801048:	ff 55 08             	call   *0x8(%ebp)
  80104b:	eb 0d                	jmp    80105a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  80104d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801050:	89 54 24 04          	mov    %edx,0x4(%esp)
  801054:	89 04 24             	mov    %eax,(%esp)
  801057:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80105a:	83 eb 01             	sub    $0x1,%ebx
  80105d:	0f be 06             	movsbl (%esi),%eax
  801060:	83 c6 01             	add    $0x1,%esi
  801063:	85 c0                	test   %eax,%eax
  801065:	75 1a                	jne    801081 <vprintfmt+0x393>
  801067:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80106a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80106d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801070:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801074:	7f 1c                	jg     801092 <vprintfmt+0x3a4>
  801076:	e9 96 fc ff ff       	jmp    800d11 <vprintfmt+0x23>
  80107b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80107e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801081:	85 ff                	test   %edi,%edi
  801083:	78 a7                	js     80102c <vprintfmt+0x33e>
  801085:	83 ef 01             	sub    $0x1,%edi
  801088:	79 a2                	jns    80102c <vprintfmt+0x33e>
  80108a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80108d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801090:	eb db                	jmp    80106d <vprintfmt+0x37f>
  801092:	8b 7d 08             	mov    0x8(%ebp),%edi
  801095:	89 de                	mov    %ebx,%esi
  801097:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80109a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8010a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8010a7:	83 eb 01             	sub    $0x1,%ebx
  8010aa:	75 ee                	jne    80109a <vprintfmt+0x3ac>
  8010ac:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8010b1:	e9 5b fc ff ff       	jmp    800d11 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8010b6:	83 f9 01             	cmp    $0x1,%ecx
  8010b9:	7e 10                	jle    8010cb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8010bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8010be:	8d 50 08             	lea    0x8(%eax),%edx
  8010c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8010c4:	8b 30                	mov    (%eax),%esi
  8010c6:	8b 78 04             	mov    0x4(%eax),%edi
  8010c9:	eb 26                	jmp    8010f1 <vprintfmt+0x403>
	else if (lflag)
  8010cb:	85 c9                	test   %ecx,%ecx
  8010cd:	74 12                	je     8010e1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8010cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d2:	8d 50 04             	lea    0x4(%eax),%edx
  8010d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8010d8:	8b 30                	mov    (%eax),%esi
  8010da:	89 f7                	mov    %esi,%edi
  8010dc:	c1 ff 1f             	sar    $0x1f,%edi
  8010df:	eb 10                	jmp    8010f1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  8010e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8010e4:	8d 50 04             	lea    0x4(%eax),%edx
  8010e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8010ea:	8b 30                	mov    (%eax),%esi
  8010ec:	89 f7                	mov    %esi,%edi
  8010ee:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8010f1:	85 ff                	test   %edi,%edi
  8010f3:	78 0e                	js     801103 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8010f5:	89 f0                	mov    %esi,%eax
  8010f7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8010f9:	be 0a 00 00 00       	mov    $0xa,%esi
  8010fe:	e9 84 00 00 00       	jmp    801187 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801107:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80110e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801111:	89 f0                	mov    %esi,%eax
  801113:	89 fa                	mov    %edi,%edx
  801115:	f7 d8                	neg    %eax
  801117:	83 d2 00             	adc    $0x0,%edx
  80111a:	f7 da                	neg    %edx
			}
			base = 10;
  80111c:	be 0a 00 00 00       	mov    $0xa,%esi
  801121:	eb 64                	jmp    801187 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801123:	89 ca                	mov    %ecx,%edx
  801125:	8d 45 14             	lea    0x14(%ebp),%eax
  801128:	e8 42 fb ff ff       	call   800c6f <getuint>
			base = 10;
  80112d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  801132:	eb 53                	jmp    801187 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801134:	89 ca                	mov    %ecx,%edx
  801136:	8d 45 14             	lea    0x14(%ebp),%eax
  801139:	e8 31 fb ff ff       	call   800c6f <getuint>
    			base = 8;
  80113e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  801143:	eb 42                	jmp    801187 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  801145:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801149:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801150:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801153:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801157:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80115e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801161:	8b 45 14             	mov    0x14(%ebp),%eax
  801164:	8d 50 04             	lea    0x4(%eax),%edx
  801167:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80116a:	8b 00                	mov    (%eax),%eax
  80116c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801171:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  801176:	eb 0f                	jmp    801187 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801178:	89 ca                	mov    %ecx,%edx
  80117a:	8d 45 14             	lea    0x14(%ebp),%eax
  80117d:	e8 ed fa ff ff       	call   800c6f <getuint>
			base = 16;
  801182:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801187:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80118b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80118f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801192:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801196:	89 74 24 08          	mov    %esi,0x8(%esp)
  80119a:	89 04 24             	mov    %eax,(%esp)
  80119d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011a1:	89 da                	mov    %ebx,%edx
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	e8 e9 f9 ff ff       	call   800b94 <printnum>
			break;
  8011ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8011ae:	e9 5e fb ff ff       	jmp    800d11 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8011b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b7:	89 14 24             	mov    %edx,(%esp)
  8011ba:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8011bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8011c0:	e9 4c fb ff ff       	jmp    800d11 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8011c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8011d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8011d3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8011d7:	0f 84 34 fb ff ff    	je     800d11 <vprintfmt+0x23>
  8011dd:	83 ee 01             	sub    $0x1,%esi
  8011e0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8011e4:	75 f7                	jne    8011dd <vprintfmt+0x4ef>
  8011e6:	e9 26 fb ff ff       	jmp    800d11 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8011eb:	83 c4 5c             	add    $0x5c,%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 28             	sub    $0x28,%esp
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8011ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801202:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801206:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801209:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801210:	85 c0                	test   %eax,%eax
  801212:	74 30                	je     801244 <vsnprintf+0x51>
  801214:	85 d2                	test   %edx,%edx
  801216:	7e 2c                	jle    801244 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801218:	8b 45 14             	mov    0x14(%ebp),%eax
  80121b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121f:	8b 45 10             	mov    0x10(%ebp),%eax
  801222:	89 44 24 08          	mov    %eax,0x8(%esp)
  801226:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122d:	c7 04 24 a9 0c 80 00 	movl   $0x800ca9,(%esp)
  801234:	e8 b5 fa ff ff       	call   800cee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801239:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80123c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	eb 05                	jmp    801249 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801244:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801251:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801254:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801258:	8b 45 10             	mov    0x10(%ebp),%eax
  80125b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 82 ff ff ff       	call   8011f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801271:	c9                   	leave  
  801272:	c3                   	ret    
	...

00801280 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 1c             	sub    $0x1c,%esp
  801289:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80128c:	85 c0                	test   %eax,%eax
  80128e:	74 18                	je     8012a8 <readline+0x28>
		fprintf(1, "%s", prompt);
  801290:	89 44 24 08          	mov    %eax,0x8(%esp)
  801294:	c7 44 24 04 c4 3b 80 	movl   $0x803bc4,0x4(%esp)
  80129b:	00 
  80129c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8012a3:	e8 c0 17 00 00       	call   802a68 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8012a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012af:	e8 da f6 ff ff       	call   80098e <iscons>
  8012b4:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8012b6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8012bb:	e8 98 f6 ff ff       	call   800958 <getchar>
  8012c0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	79 25                	jns    8012eb <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  8012cb:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8012ce:	0f 84 88 00 00 00    	je     80135c <readline+0xdc>
				cprintf("read error: %e\n", c);
  8012d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012d8:	c7 04 24 bf 3f 80 00 	movl   $0x803fbf,(%esp)
  8012df:	e8 93 f8 ff ff       	call   800b77 <cprintf>
			return NULL;
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e9:	eb 71                	jmp    80135c <readline+0xdc>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8012eb:	83 f8 08             	cmp    $0x8,%eax
  8012ee:	74 05                	je     8012f5 <readline+0x75>
  8012f0:	83 f8 7f             	cmp    $0x7f,%eax
  8012f3:	75 19                	jne    80130e <readline+0x8e>
  8012f5:	85 f6                	test   %esi,%esi
  8012f7:	7e 15                	jle    80130e <readline+0x8e>
			if (echoing)
  8012f9:	85 ff                	test   %edi,%edi
  8012fb:	74 0c                	je     801309 <readline+0x89>
				cputchar('\b');
  8012fd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801304:	e8 2e f6 ff ff       	call   800937 <cputchar>
			i--;
  801309:	83 ee 01             	sub    $0x1,%esi
  80130c:	eb ad                	jmp    8012bb <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80130e:	83 fb 1f             	cmp    $0x1f,%ebx
  801311:	7e 1f                	jle    801332 <readline+0xb2>
  801313:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801319:	7f 17                	jg     801332 <readline+0xb2>
			if (echoing)
  80131b:	85 ff                	test   %edi,%edi
  80131d:	74 08                	je     801327 <readline+0xa7>
				cputchar(c);
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 10 f6 ff ff       	call   800937 <cputchar>
			buf[i++] = c;
  801327:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  80132d:	83 c6 01             	add    $0x1,%esi
  801330:	eb 89                	jmp    8012bb <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  801332:	83 fb 0a             	cmp    $0xa,%ebx
  801335:	74 09                	je     801340 <readline+0xc0>
  801337:	83 fb 0d             	cmp    $0xd,%ebx
  80133a:	0f 85 7b ff ff ff    	jne    8012bb <readline+0x3b>
			if (echoing)
  801340:	85 ff                	test   %edi,%edi
  801342:	74 0c                	je     801350 <readline+0xd0>
				cputchar('\n');
  801344:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80134b:	e8 e7 f5 ff ff       	call   800937 <cputchar>
			buf[i] = 0;
  801350:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  801357:	b8 20 60 80 00       	mov    $0x806020,%eax
		}
	}
}
  80135c:	83 c4 1c             	add    $0x1c,%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
	...

00801370 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
  80137b:	80 3a 00             	cmpb   $0x0,(%edx)
  80137e:	74 09                	je     801389 <strlen+0x19>
		n++;
  801380:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801383:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801387:	75 f7                	jne    801380 <strlen+0x10>
		n++;
	return n;
}
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    

0080138b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	85 c9                	test   %ecx,%ecx
  80139c:	74 1a                	je     8013b8 <strnlen+0x2d>
  80139e:	80 3b 00             	cmpb   $0x0,(%ebx)
  8013a1:	74 15                	je     8013b8 <strnlen+0x2d>
  8013a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8013a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8013aa:	39 ca                	cmp    %ecx,%edx
  8013ac:	74 0a                	je     8013b8 <strnlen+0x2d>
  8013ae:	83 c2 01             	add    $0x1,%edx
  8013b1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8013b6:	75 f0                	jne    8013a8 <strnlen+0x1d>
		n++;
	return n;
}
  8013b8:	5b                   	pop    %ebx
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	53                   	push   %ebx
  8013bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8013c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8013ce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8013d1:	83 c2 01             	add    $0x1,%edx
  8013d4:	84 c9                	test   %cl,%cl
  8013d6:	75 f2                	jne    8013ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8013d8:	5b                   	pop    %ebx
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	53                   	push   %ebx
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8013e5:	89 1c 24             	mov    %ebx,(%esp)
  8013e8:	e8 83 ff ff ff       	call   801370 <strlen>
	strcpy(dst + len, src);
  8013ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f4:	01 d8                	add    %ebx,%eax
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 bd ff ff ff       	call   8013bb <strcpy>
	return dst;
}
  8013fe:	89 d8                	mov    %ebx,%eax
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	5b                   	pop    %ebx
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
  80140b:	8b 45 08             	mov    0x8(%ebp),%eax
  80140e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801411:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801414:	85 f6                	test   %esi,%esi
  801416:	74 18                	je     801430 <strncpy+0x2a>
  801418:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80141d:	0f b6 1a             	movzbl (%edx),%ebx
  801420:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801423:	80 3a 01             	cmpb   $0x1,(%edx)
  801426:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801429:	83 c1 01             	add    $0x1,%ecx
  80142c:	39 f1                	cmp    %esi,%ecx
  80142e:	75 ed                	jne    80141d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801430:	5b                   	pop    %ebx
  801431:	5e                   	pop    %esi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	57                   	push   %edi
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801440:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801443:	89 f8                	mov    %edi,%eax
  801445:	85 f6                	test   %esi,%esi
  801447:	74 2b                	je     801474 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801449:	83 fe 01             	cmp    $0x1,%esi
  80144c:	74 23                	je     801471 <strlcpy+0x3d>
  80144e:	0f b6 0b             	movzbl (%ebx),%ecx
  801451:	84 c9                	test   %cl,%cl
  801453:	74 1c                	je     801471 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801455:	83 ee 02             	sub    $0x2,%esi
  801458:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80145d:	88 08                	mov    %cl,(%eax)
  80145f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801462:	39 f2                	cmp    %esi,%edx
  801464:	74 0b                	je     801471 <strlcpy+0x3d>
  801466:	83 c2 01             	add    $0x1,%edx
  801469:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80146d:	84 c9                	test   %cl,%cl
  80146f:	75 ec                	jne    80145d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  801471:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801474:	29 f8                	sub    %edi,%eax
}
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801481:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801484:	0f b6 01             	movzbl (%ecx),%eax
  801487:	84 c0                	test   %al,%al
  801489:	74 16                	je     8014a1 <strcmp+0x26>
  80148b:	3a 02                	cmp    (%edx),%al
  80148d:	75 12                	jne    8014a1 <strcmp+0x26>
		p++, q++;
  80148f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801492:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801496:	84 c0                	test   %al,%al
  801498:	74 07                	je     8014a1 <strcmp+0x26>
  80149a:	83 c1 01             	add    $0x1,%ecx
  80149d:	3a 02                	cmp    (%edx),%al
  80149f:	74 ee                	je     80148f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8014a1:	0f b6 c0             	movzbl %al,%eax
  8014a4:	0f b6 12             	movzbl (%edx),%edx
  8014a7:	29 d0                	sub    %edx,%eax
}
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    

008014ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	53                   	push   %ebx
  8014af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8014bd:	85 d2                	test   %edx,%edx
  8014bf:	74 28                	je     8014e9 <strncmp+0x3e>
  8014c1:	0f b6 01             	movzbl (%ecx),%eax
  8014c4:	84 c0                	test   %al,%al
  8014c6:	74 24                	je     8014ec <strncmp+0x41>
  8014c8:	3a 03                	cmp    (%ebx),%al
  8014ca:	75 20                	jne    8014ec <strncmp+0x41>
  8014cc:	83 ea 01             	sub    $0x1,%edx
  8014cf:	74 13                	je     8014e4 <strncmp+0x39>
		n--, p++, q++;
  8014d1:	83 c1 01             	add    $0x1,%ecx
  8014d4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8014d7:	0f b6 01             	movzbl (%ecx),%eax
  8014da:	84 c0                	test   %al,%al
  8014dc:	74 0e                	je     8014ec <strncmp+0x41>
  8014de:	3a 03                	cmp    (%ebx),%al
  8014e0:	74 ea                	je     8014cc <strncmp+0x21>
  8014e2:	eb 08                	jmp    8014ec <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8014e9:	5b                   	pop    %ebx
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8014ec:	0f b6 01             	movzbl (%ecx),%eax
  8014ef:	0f b6 13             	movzbl (%ebx),%edx
  8014f2:	29 d0                	sub    %edx,%eax
  8014f4:	eb f3                	jmp    8014e9 <strncmp+0x3e>

008014f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801500:	0f b6 10             	movzbl (%eax),%edx
  801503:	84 d2                	test   %dl,%dl
  801505:	74 1c                	je     801523 <strchr+0x2d>
		if (*s == c)
  801507:	38 ca                	cmp    %cl,%dl
  801509:	75 09                	jne    801514 <strchr+0x1e>
  80150b:	eb 1b                	jmp    801528 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80150d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  801510:	38 ca                	cmp    %cl,%dl
  801512:	74 14                	je     801528 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801514:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  801518:	84 d2                	test   %dl,%dl
  80151a:	75 f1                	jne    80150d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
  801521:	eb 05                	jmp    801528 <strchr+0x32>
  801523:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	8b 45 08             	mov    0x8(%ebp),%eax
  801530:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801534:	0f b6 10             	movzbl (%eax),%edx
  801537:	84 d2                	test   %dl,%dl
  801539:	74 14                	je     80154f <strfind+0x25>
		if (*s == c)
  80153b:	38 ca                	cmp    %cl,%dl
  80153d:	75 06                	jne    801545 <strfind+0x1b>
  80153f:	eb 0e                	jmp    80154f <strfind+0x25>
  801541:	38 ca                	cmp    %cl,%dl
  801543:	74 0a                	je     80154f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801545:	83 c0 01             	add    $0x1,%eax
  801548:	0f b6 10             	movzbl (%eax),%edx
  80154b:	84 d2                	test   %dl,%dl
  80154d:	75 f2                	jne    801541 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80155a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80155d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801560:	8b 7d 08             	mov    0x8(%ebp),%edi
  801563:	8b 45 0c             	mov    0xc(%ebp),%eax
  801566:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801569:	85 c9                	test   %ecx,%ecx
  80156b:	74 30                	je     80159d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80156d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801573:	75 25                	jne    80159a <memset+0x49>
  801575:	f6 c1 03             	test   $0x3,%cl
  801578:	75 20                	jne    80159a <memset+0x49>
		c &= 0xFF;
  80157a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80157d:	89 d3                	mov    %edx,%ebx
  80157f:	c1 e3 08             	shl    $0x8,%ebx
  801582:	89 d6                	mov    %edx,%esi
  801584:	c1 e6 18             	shl    $0x18,%esi
  801587:	89 d0                	mov    %edx,%eax
  801589:	c1 e0 10             	shl    $0x10,%eax
  80158c:	09 f0                	or     %esi,%eax
  80158e:	09 d0                	or     %edx,%eax
  801590:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801592:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801595:	fc                   	cld    
  801596:	f3 ab                	rep stos %eax,%es:(%edi)
  801598:	eb 03                	jmp    80159d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80159a:	fc                   	cld    
  80159b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80159d:	89 f8                	mov    %edi,%eax
  80159f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015a8:	89 ec                	mov    %ebp,%esp
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8015c1:	39 c6                	cmp    %eax,%esi
  8015c3:	73 36                	jae    8015fb <memmove+0x4f>
  8015c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8015c8:	39 d0                	cmp    %edx,%eax
  8015ca:	73 2f                	jae    8015fb <memmove+0x4f>
		s += n;
		d += n;
  8015cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8015cf:	f6 c2 03             	test   $0x3,%dl
  8015d2:	75 1b                	jne    8015ef <memmove+0x43>
  8015d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8015da:	75 13                	jne    8015ef <memmove+0x43>
  8015dc:	f6 c1 03             	test   $0x3,%cl
  8015df:	75 0e                	jne    8015ef <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8015e1:	83 ef 04             	sub    $0x4,%edi
  8015e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8015e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8015ea:	fd                   	std    
  8015eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8015ed:	eb 09                	jmp    8015f8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8015ef:	83 ef 01             	sub    $0x1,%edi
  8015f2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8015f5:	fd                   	std    
  8015f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8015f8:	fc                   	cld    
  8015f9:	eb 20                	jmp    80161b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8015fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801601:	75 13                	jne    801616 <memmove+0x6a>
  801603:	a8 03                	test   $0x3,%al
  801605:	75 0f                	jne    801616 <memmove+0x6a>
  801607:	f6 c1 03             	test   $0x3,%cl
  80160a:	75 0a                	jne    801616 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80160c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80160f:	89 c7                	mov    %eax,%edi
  801611:	fc                   	cld    
  801612:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801614:	eb 05                	jmp    80161b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801616:	89 c7                	mov    %eax,%edi
  801618:	fc                   	cld    
  801619:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80161b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80161e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801621:	89 ec                	mov    %ebp,%esp
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80162b:	8b 45 10             	mov    0x10(%ebp),%eax
  80162e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801632:	8b 45 0c             	mov    0xc(%ebp),%eax
  801635:	89 44 24 04          	mov    %eax,0x4(%esp)
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 68 ff ff ff       	call   8015ac <memmove>
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	57                   	push   %edi
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80164f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801652:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801655:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80165a:	85 ff                	test   %edi,%edi
  80165c:	74 37                	je     801695 <memcmp+0x4f>
		if (*s1 != *s2)
  80165e:	0f b6 03             	movzbl (%ebx),%eax
  801661:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801664:	83 ef 01             	sub    $0x1,%edi
  801667:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  80166c:	38 c8                	cmp    %cl,%al
  80166e:	74 1c                	je     80168c <memcmp+0x46>
  801670:	eb 10                	jmp    801682 <memcmp+0x3c>
  801672:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801677:	83 c2 01             	add    $0x1,%edx
  80167a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  80167e:	38 c8                	cmp    %cl,%al
  801680:	74 0a                	je     80168c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801682:	0f b6 c0             	movzbl %al,%eax
  801685:	0f b6 c9             	movzbl %cl,%ecx
  801688:	29 c8                	sub    %ecx,%eax
  80168a:	eb 09                	jmp    801695 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80168c:	39 fa                	cmp    %edi,%edx
  80168e:	75 e2                	jne    801672 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801690:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5f                   	pop    %edi
  801698:	5d                   	pop    %ebp
  801699:	c3                   	ret    

0080169a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8016a5:	39 d0                	cmp    %edx,%eax
  8016a7:	73 19                	jae    8016c2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  8016a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8016ad:	38 08                	cmp    %cl,(%eax)
  8016af:	75 06                	jne    8016b7 <memfind+0x1d>
  8016b1:	eb 0f                	jmp    8016c2 <memfind+0x28>
  8016b3:	38 08                	cmp    %cl,(%eax)
  8016b5:	74 0b                	je     8016c2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8016b7:	83 c0 01             	add    $0x1,%eax
  8016ba:	39 d0                	cmp    %edx,%eax
  8016bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016c0:	75 f1                	jne    8016b3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	57                   	push   %edi
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
  8016ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8016d0:	0f b6 02             	movzbl (%edx),%eax
  8016d3:	3c 20                	cmp    $0x20,%al
  8016d5:	74 04                	je     8016db <strtol+0x17>
  8016d7:	3c 09                	cmp    $0x9,%al
  8016d9:	75 0e                	jne    8016e9 <strtol+0x25>
		s++;
  8016db:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8016de:	0f b6 02             	movzbl (%edx),%eax
  8016e1:	3c 20                	cmp    $0x20,%al
  8016e3:	74 f6                	je     8016db <strtol+0x17>
  8016e5:	3c 09                	cmp    $0x9,%al
  8016e7:	74 f2                	je     8016db <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  8016e9:	3c 2b                	cmp    $0x2b,%al
  8016eb:	75 0a                	jne    8016f7 <strtol+0x33>
		s++;
  8016ed:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8016f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f5:	eb 10                	jmp    801707 <strtol+0x43>
  8016f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8016fc:	3c 2d                	cmp    $0x2d,%al
  8016fe:	75 07                	jne    801707 <strtol+0x43>
		s++, neg = 1;
  801700:	83 c2 01             	add    $0x1,%edx
  801703:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801707:	85 db                	test   %ebx,%ebx
  801709:	0f 94 c0             	sete   %al
  80170c:	74 05                	je     801713 <strtol+0x4f>
  80170e:	83 fb 10             	cmp    $0x10,%ebx
  801711:	75 15                	jne    801728 <strtol+0x64>
  801713:	80 3a 30             	cmpb   $0x30,(%edx)
  801716:	75 10                	jne    801728 <strtol+0x64>
  801718:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80171c:	75 0a                	jne    801728 <strtol+0x64>
		s += 2, base = 16;
  80171e:	83 c2 02             	add    $0x2,%edx
  801721:	bb 10 00 00 00       	mov    $0x10,%ebx
  801726:	eb 13                	jmp    80173b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801728:	84 c0                	test   %al,%al
  80172a:	74 0f                	je     80173b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80172c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801731:	80 3a 30             	cmpb   $0x30,(%edx)
  801734:	75 05                	jne    80173b <strtol+0x77>
		s++, base = 8;
  801736:	83 c2 01             	add    $0x1,%edx
  801739:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80173b:	b8 00 00 00 00       	mov    $0x0,%eax
  801740:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801742:	0f b6 0a             	movzbl (%edx),%ecx
  801745:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801748:	80 fb 09             	cmp    $0x9,%bl
  80174b:	77 08                	ja     801755 <strtol+0x91>
			dig = *s - '0';
  80174d:	0f be c9             	movsbl %cl,%ecx
  801750:	83 e9 30             	sub    $0x30,%ecx
  801753:	eb 1e                	jmp    801773 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801755:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801758:	80 fb 19             	cmp    $0x19,%bl
  80175b:	77 08                	ja     801765 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80175d:	0f be c9             	movsbl %cl,%ecx
  801760:	83 e9 57             	sub    $0x57,%ecx
  801763:	eb 0e                	jmp    801773 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801765:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801768:	80 fb 19             	cmp    $0x19,%bl
  80176b:	77 14                	ja     801781 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80176d:	0f be c9             	movsbl %cl,%ecx
  801770:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801773:	39 f1                	cmp    %esi,%ecx
  801775:	7d 0e                	jge    801785 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801777:	83 c2 01             	add    $0x1,%edx
  80177a:	0f af c6             	imul   %esi,%eax
  80177d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80177f:	eb c1                	jmp    801742 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801781:	89 c1                	mov    %eax,%ecx
  801783:	eb 02                	jmp    801787 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801785:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801787:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80178b:	74 05                	je     801792 <strtol+0xce>
		*endptr = (char *) s;
  80178d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801790:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801792:	89 ca                	mov    %ecx,%edx
  801794:	f7 da                	neg    %edx
  801796:	85 ff                	test   %edi,%edi
  801798:	0f 45 c2             	cmovne %edx,%eax
}
  80179b:	5b                   	pop    %ebx
  80179c:	5e                   	pop    %esi
  80179d:	5f                   	pop    %edi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    

008017a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017af:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	89 c7                	mov    %eax,%edi
  8017be:	89 c6                	mov    %eax,%esi
  8017c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8017c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017cb:	89 ec                	mov    %ebp,%esp
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e8:	89 d1                	mov    %edx,%ecx
  8017ea:	89 d3                	mov    %edx,%ebx
  8017ec:	89 d7                	mov    %edx,%edi
  8017ee:	89 d6                	mov    %edx,%esi
  8017f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8017f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017fb:	89 ec                	mov    %ebp,%esp
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 38             	sub    $0x38,%esp
  801805:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801808:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80180b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80180e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801813:	b8 03 00 00 00       	mov    $0x3,%eax
  801818:	8b 55 08             	mov    0x8(%ebp),%edx
  80181b:	89 cb                	mov    %ecx,%ebx
  80181d:	89 cf                	mov    %ecx,%edi
  80181f:	89 ce                	mov    %ecx,%esi
  801821:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801823:	85 c0                	test   %eax,%eax
  801825:	7e 28                	jle    80184f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801827:	89 44 24 10          	mov    %eax,0x10(%esp)
  80182b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801832:	00 
  801833:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  80183a:	00 
  80183b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801842:	00 
  801843:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  80184a:	e8 2d f2 ff ff       	call   800a7c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80184f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801852:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801855:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801858:	89 ec                	mov    %ebp,%esp
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801865:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801868:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	b8 02 00 00 00       	mov    $0x2,%eax
  801875:	89 d1                	mov    %edx,%ecx
  801877:	89 d3                	mov    %edx,%ebx
  801879:	89 d7                	mov    %edx,%edi
  80187b:	89 d6                	mov    %edx,%esi
  80187d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80187f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801882:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801885:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801888:	89 ec                	mov    %ebp,%esp
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <sys_yield>:

void
sys_yield(void)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 0c             	sub    $0xc,%esp
  801892:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801895:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801898:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8018a5:	89 d1                	mov    %edx,%ecx
  8018a7:	89 d3                	mov    %edx,%ebx
  8018a9:	89 d7                	mov    %edx,%edi
  8018ab:	89 d6                	mov    %edx,%esi
  8018ad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8018af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018b8:	89 ec                	mov    %ebp,%esp
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 38             	sub    $0x38,%esp
  8018c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8018cb:	be 00 00 00 00       	mov    $0x0,%esi
  8018d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018db:	8b 55 08             	mov    0x8(%ebp),%edx
  8018de:	89 f7                	mov    %esi,%edi
  8018e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	7e 28                	jle    80190e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8018e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018ea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8018f1:	00 
  8018f2:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  8018f9:	00 
  8018fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801901:	00 
  801902:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  801909:	e8 6e f1 ff ff       	call   800a7c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80190e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801911:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801914:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801917:	89 ec                	mov    %ebp,%esp
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 38             	sub    $0x38,%esp
  801921:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801924:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801927:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80192a:	b8 05 00 00 00       	mov    $0x5,%eax
  80192f:	8b 75 18             	mov    0x18(%ebp),%esi
  801932:	8b 7d 14             	mov    0x14(%ebp),%edi
  801935:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80193b:	8b 55 08             	mov    0x8(%ebp),%edx
  80193e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801940:	85 c0                	test   %eax,%eax
  801942:	7e 28                	jle    80196c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801944:	89 44 24 10          	mov    %eax,0x10(%esp)
  801948:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80194f:	00 
  801950:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  801957:	00 
  801958:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80195f:	00 
  801960:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  801967:	e8 10 f1 ff ff       	call   800a7c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80196c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80196f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801972:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801975:	89 ec                	mov    %ebp,%esp
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 38             	sub    $0x38,%esp
  80197f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801982:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801985:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801988:	bb 00 00 00 00       	mov    $0x0,%ebx
  80198d:	b8 06 00 00 00       	mov    $0x6,%eax
  801992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801995:	8b 55 08             	mov    0x8(%ebp),%edx
  801998:	89 df                	mov    %ebx,%edi
  80199a:	89 de                	mov    %ebx,%esi
  80199c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	7e 28                	jle    8019ca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8019a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019a6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8019ad:	00 
  8019ae:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  8019b5:	00 
  8019b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8019bd:	00 
  8019be:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  8019c5:	e8 b2 f0 ff ff       	call   800a7c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8019ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019d3:	89 ec                	mov    %ebp,%esp
  8019d5:	5d                   	pop    %ebp
  8019d6:	c3                   	ret    

008019d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	83 ec 38             	sub    $0x38,%esp
  8019dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8019e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8019f6:	89 df                	mov    %ebx,%edi
  8019f8:	89 de                	mov    %ebx,%esi
  8019fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	7e 28                	jle    801a28 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a00:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801a0b:	00 
  801a0c:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  801a13:	00 
  801a14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a1b:	00 
  801a1c:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  801a23:	e8 54 f0 ff ff       	call   800a7c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801a28:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a31:	89 ec                	mov    %ebp,%esp
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 38             	sub    $0x38,%esp
  801a3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a41:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801a44:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a49:	b8 09 00 00 00       	mov    $0x9,%eax
  801a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a51:	8b 55 08             	mov    0x8(%ebp),%edx
  801a54:	89 df                	mov    %ebx,%edi
  801a56:	89 de                	mov    %ebx,%esi
  801a58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	7e 28                	jle    801a86 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801a5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a62:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801a69:	00 
  801a6a:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  801a71:	00 
  801a72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a79:	00 
  801a7a:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  801a81:	e8 f6 ef ff ff       	call   800a7c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801a86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a8f:	89 ec                	mov    %ebp,%esp
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 38             	sub    $0x38,%esp
  801a99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801aa2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa7:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab2:	89 df                	mov    %ebx,%edi
  801ab4:	89 de                	mov    %ebx,%esi
  801ab6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	7e 28                	jle    801ae4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801abc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ac0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801ac7:	00 
  801ac8:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  801acf:	00 
  801ad0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801ad7:	00 
  801ad8:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  801adf:	e8 98 ef ff ff       	call   800a7c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801ae4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ae7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801aea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801aed:	89 ec                	mov    %ebp,%esp
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801afa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801afd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801b00:	be 00 00 00 00       	mov    $0x0,%esi
  801b05:	b8 0c 00 00 00       	mov    $0xc,%eax
  801b0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  801b0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b13:	8b 55 08             	mov    0x8(%ebp),%edx
  801b16:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801b18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b21:	89 ec                	mov    %ebp,%esp
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 38             	sub    $0x38,%esp
  801b2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b31:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801b34:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b39:	b8 0d 00 00 00       	mov    $0xd,%eax
  801b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  801b41:	89 cb                	mov    %ecx,%ebx
  801b43:	89 cf                	mov    %ecx,%edi
  801b45:	89 ce                	mov    %ecx,%esi
  801b47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	7e 28                	jle    801b75 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801b4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b51:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801b58:	00 
  801b59:	c7 44 24 08 cf 3f 80 	movl   $0x803fcf,0x8(%esp)
  801b60:	00 
  801b61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801b68:	00 
  801b69:	c7 04 24 ec 3f 80 00 	movl   $0x803fec,(%esp)
  801b70:	e8 07 ef ff ff       	call   800a7c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801b75:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b78:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b7b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b7e:	89 ec                	mov    %ebp,%esp
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b8b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b8e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801b91:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b96:	b8 0e 00 00 00       	mov    $0xe,%eax
  801b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b9e:	89 cb                	mov    %ecx,%ebx
  801ba0:	89 cf                	mov    %ecx,%edi
  801ba2:	89 ce                	mov    %ecx,%esi
  801ba4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801ba6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ba9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801bac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801baf:	89 ec                	mov    %ebp,%esp
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    
	...

00801bb4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 24             	sub    $0x24,%esp
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801bbe:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0) 
  801bc0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801bc4:	75 1c                	jne    801be2 <pgfault+0x2e>
		panic("pgfault: not a write!\n");
  801bc6:	c7 44 24 08 fa 3f 80 	movl   $0x803ffa,0x8(%esp)
  801bcd:	00 
  801bce:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801bd5:	00 
  801bd6:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801bdd:	e8 9a ee ff ff       	call   800a7c <_panic>
	uintptr_t ad = (uintptr_t) addr;
	if ( (uvpt[ad / PGSIZE] & PTE_COW) && (uvpd[PDX(addr)] & PTE_P) ) {
  801be2:	89 d8                	mov    %ebx,%eax
  801be4:	c1 e8 0c             	shr    $0xc,%eax
  801be7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bee:	f6 c4 08             	test   $0x8,%ah
  801bf1:	0f 84 be 00 00 00    	je     801cb5 <pgfault+0x101>
  801bf7:	89 d8                	mov    %ebx,%eax
  801bf9:	c1 e8 16             	shr    $0x16,%eax
  801bfc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c03:	a8 01                	test   $0x1,%al
  801c05:	0f 84 aa 00 00 00    	je     801cb5 <pgfault+0x101>
		r = sys_page_alloc(0, (void *)PFTEMP, PTE_P | PTE_U | PTE_W);
  801c0b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c12:	00 
  801c13:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801c1a:	00 
  801c1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c22:	e8 95 fc ff ff       	call   8018bc <sys_page_alloc>
		if (r < 0)
  801c27:	85 c0                	test   %eax,%eax
  801c29:	79 20                	jns    801c4b <pgfault+0x97>
			panic("sys_page_alloc failed in pgfault %e\n", r);
  801c2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2f:	c7 44 24 08 34 40 80 	movl   $0x804034,0x8(%esp)
  801c36:	00 
  801c37:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801c3e:	00 
  801c3f:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801c46:	e8 31 ee ff ff       	call   800a7c <_panic>
		
		addr = ROUNDDOWN(addr, PGSIZE);
  801c4b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		memcpy(PFTEMP, addr, PGSIZE);
  801c51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801c58:	00 
  801c59:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c5d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801c64:	e8 bc f9 ff ff       	call   801625 <memcpy>

		r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  801c69:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c70:	00 
  801c71:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c7c:	00 
  801c7d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801c84:	00 
  801c85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8c:	e8 8a fc ff ff       	call   80191b <sys_page_map>
		if (r < 0)
  801c91:	85 c0                	test   %eax,%eax
  801c93:	79 3c                	jns    801cd1 <pgfault+0x11d>
			panic("sys_page_map failed in pgfault %e\n", r);
  801c95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c99:	c7 44 24 08 5c 40 80 	movl   $0x80405c,0x8(%esp)
  801ca0:	00 
  801ca1:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801ca8:	00 
  801ca9:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801cb0:	e8 c7 ed ff ff       	call   800a7c <_panic>

		return;
	}
	else {
		panic("pgfault: not a copy-on-write!\n");
  801cb5:	c7 44 24 08 80 40 80 	movl   $0x804080,0x8(%esp)
  801cbc:	00 
  801cbd:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801cc4:	00 
  801cc5:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801ccc:	e8 ab ed ff ff       	call   800a7c <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	//panic("pgfault not implemented");
}
  801cd1:	83 c4 24             	add    $0x24,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801ce0:	c7 04 24 b4 1b 80 00 	movl   $0x801bb4,(%esp)
  801ce7:	e8 b4 18 00 00       	call   8035a0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801cec:	bf 07 00 00 00       	mov    $0x7,%edi
  801cf1:	89 f8                	mov    %edi,%eax
  801cf3:	cd 30                	int    $0x30
  801cf5:	89 c7                	mov    %eax,%edi
  801cf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t pid = sys_exofork();
	//cprintf("pid: %x\n", pid);
	if (pid < 0)
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	79 20                	jns    801d1e <fork+0x47>
		panic("sys_exofork failed in fork %e\n", pid);
  801cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d02:	c7 44 24 08 a0 40 80 	movl   $0x8040a0,0x8(%esp)
  801d09:	00 
  801d0a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801d11:	00 
  801d12:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801d19:	e8 5e ed ff ff       	call   800a7c <_panic>
	//cprintf("fork point2!\n");
	if (pid == 0) {
  801d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d23:	85 c0                	test   %eax,%eax
  801d25:	75 1c                	jne    801d43 <fork+0x6c>
		//cprintf("child forked!\n");
		thisenv = &envs[ENVX(sys_getenvid())];
  801d27:	e8 30 fb ff ff       	call   80185c <sys_getenvid>
  801d2c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d31:	c1 e0 07             	shl    $0x7,%eax
  801d34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d39:	a3 24 64 80 00       	mov    %eax,0x806424
		//cprintf("child fork ok!\n");
		return 0;
  801d3e:	e9 51 02 00 00       	jmp    801f94 <fork+0x2bd>
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
  801d43:	89 d8                	mov    %ebx,%eax
  801d45:	c1 e8 16             	shr    $0x16,%eax
  801d48:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d4f:	a8 01                	test   $0x1,%al
  801d51:	0f 84 87 01 00 00    	je     801ede <fork+0x207>
  801d57:	89 d8                	mov    %ebx,%eax
  801d59:	c1 e8 0c             	shr    $0xc,%eax
  801d5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d63:	f6 c2 01             	test   $0x1,%dl
  801d66:	0f 84 72 01 00 00    	je     801ede <fork+0x207>
  801d6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d73:	f6 c2 04             	test   $0x4,%dl
  801d76:	0f 84 62 01 00 00    	je     801ede <fork+0x207>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801d7c:	89 c6                	mov    %eax,%esi
  801d7e:	c1 e6 0c             	shl    $0xc,%esi
  801d81:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801d87:	0f 84 51 01 00 00    	je     801ede <fork+0x207>

	uintptr_t addr = (uintptr_t)(pn * PGSIZE);
	if (uvpt[pn] & PTE_SHARE) {
  801d8d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d94:	f6 c6 04             	test   $0x4,%dh
  801d97:	74 53                	je     801dec <fork+0x115>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
  801d99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801da0:	25 07 0e 00 00       	and    $0xe07,%eax
  801da5:	89 44 24 10          	mov    %eax,0x10(%esp)
  801da9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbf:	e8 57 fb ff ff       	call   80191b <sys_page_map>
		if (r < 0)
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 89 12 01 00 00    	jns    801ede <fork+0x207>
			panic("share sys_page_map failed in duppage %e\n", r);
  801dcc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dd0:	c7 44 24 08 c0 40 80 	movl   $0x8040c0,0x8(%esp)
  801dd7:	00 
  801dd8:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801ddf:	00 
  801de0:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801de7:	e8 90 ec ff ff       	call   800a7c <_panic>
	}
	else 
	if ( (uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW) ) {
  801dec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801df3:	f6 c2 02             	test   $0x2,%dl
  801df6:	75 10                	jne    801e08 <fork+0x131>
  801df8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dff:	f6 c4 08             	test   $0x8,%ah
  801e02:	0f 84 8f 00 00 00    	je     801e97 <fork+0x1c0>
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801e08:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801e0f:	00 
  801e10:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e26:	e8 f0 fa ff ff       	call   80191b <sys_page_map>
		if (r < 0)
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	79 20                	jns    801e4f <fork+0x178>
			panic("sys_page_map failed in duppage %e\n", r);
  801e2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e33:	c7 44 24 08 ec 40 80 	movl   $0x8040ec,0x8(%esp)
  801e3a:	00 
  801e3b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801e42:	00 
  801e43:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801e4a:	e8 2d ec ff ff       	call   800a7c <_panic>

		r = sys_page_map(0, (void *)addr, 0, (void *)addr, PTE_P | PTE_U | PTE_COW);
  801e4f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801e56:	00 
  801e57:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e62:	00 
  801e63:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6e:	e8 a8 fa ff ff       	call   80191b <sys_page_map>
		if (r < 0)
  801e73:	85 c0                	test   %eax,%eax
  801e75:	79 67                	jns    801ede <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801e77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e7b:	c7 44 24 08 ec 40 80 	movl   $0x8040ec,0x8(%esp)
  801e82:	00 
  801e83:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  801e8a:	00 
  801e8b:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801e92:	e8 e5 eb ff ff       	call   800a7c <_panic>
	}
	else {
		r = sys_page_map(0, (void *)addr, envid, (void *)addr, PTE_P | PTE_U);
  801e97:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801e9e:	00 
  801e9f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ea3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eaa:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb5:	e8 61 fa ff ff       	call   80191b <sys_page_map>
		if (r < 0)
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	79 20                	jns    801ede <fork+0x207>
			panic("sys_page_map failed in duppage %e\n", r);
  801ebe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ec2:	c7 44 24 08 ec 40 80 	movl   $0x8040ec,0x8(%esp)
  801ec9:	00 
  801eca:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801ed1:	00 
  801ed2:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801ed9:	e8 9e eb ff ff       	call   800a7c <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		//cprintf("child fork ok!\n");
		return 0;
	}
	uint32_t i;
	for (i = 0; i < UTOP; i += PGSIZE){
  801ede:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ee4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801eea:	0f 85 53 fe ff ff    	jne    801d43 <fork+0x6c>
		if ( (uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U) )
			duppage(pid, i / PGSIZE);
	}

	int res;
	res = sys_page_alloc(pid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ef0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ef7:	00 
  801ef8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801eff:	ee 
  801f00:	89 3c 24             	mov    %edi,(%esp)
  801f03:	e8 b4 f9 ff ff       	call   8018bc <sys_page_alloc>
	if (res < 0)
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	79 20                	jns    801f2c <fork+0x255>
		panic("sys_page_alloc failed in fork %e\n", res);
  801f0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f10:	c7 44 24 08 10 41 80 	movl   $0x804110,0x8(%esp)
  801f17:	00 
  801f18:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801f1f:	00 
  801f20:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801f27:	e8 50 eb ff ff       	call   800a7c <_panic>

	extern void _pgfault_upcall(void);
	res = sys_env_set_pgfault_upcall(pid, _pgfault_upcall);
  801f2c:	c7 44 24 04 2c 36 80 	movl   $0x80362c,0x4(%esp)
  801f33:	00 
  801f34:	89 3c 24             	mov    %edi,(%esp)
  801f37:	e8 57 fb ff ff       	call   801a93 <sys_env_set_pgfault_upcall>
	if (res < 0)
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	79 20                	jns    801f60 <fork+0x289>
		panic("sys_env_set_pgfault_upcall failed in fork %e\n", res);
  801f40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f44:	c7 44 24 08 34 41 80 	movl   $0x804134,0x8(%esp)
  801f4b:	00 
  801f4c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801f53:	00 
  801f54:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801f5b:	e8 1c eb ff ff       	call   800a7c <_panic>

	res = sys_env_set_status(pid, ENV_RUNNABLE);
  801f60:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f67:	00 
  801f68:	89 3c 24             	mov    %edi,(%esp)
  801f6b:	e8 67 fa ff ff       	call   8019d7 <sys_env_set_status>
	if (res < 0)
  801f70:	85 c0                	test   %eax,%eax
  801f72:	79 20                	jns    801f94 <fork+0x2bd>
		panic("sys_env_set_status failed in fork %e\n", res);
  801f74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f78:	c7 44 24 08 64 41 80 	movl   $0x804164,0x8(%esp)
  801f7f:	00 
  801f80:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
  801f87:	00 
  801f88:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801f8f:	e8 e8 ea ff ff       	call   800a7c <_panic>

	return pid;
	//panic("fork not implemented");
}
  801f94:	89 f8                	mov    %edi,%eax
  801f96:	83 c4 3c             	add    $0x3c,%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <sfork>:

// Challenge!
int
sfork(void)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801fa4:	c7 44 24 08 1c 40 80 	movl   $0x80401c,0x8(%esp)
  801fab:	00 
  801fac:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801fb3:	00 
  801fb4:	c7 04 24 11 40 80 00 	movl   $0x804011,(%esp)
  801fbb:	e8 bc ea ff ff       	call   800a7c <_panic>

00801fc0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  801fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801fcc:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801fce:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801fd1:	83 3a 01             	cmpl   $0x1,(%edx)
  801fd4:	7e 09                	jle    801fdf <argstart+0x1f>
  801fd6:	ba 81 3a 80 00       	mov    $0x803a81,%edx
  801fdb:	85 c9                	test   %ecx,%ecx
  801fdd:	75 05                	jne    801fe4 <argstart+0x24>
  801fdf:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801fe7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <argnext>:

int
argnext(struct Argstate *args)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 14             	sub    $0x14,%esp
  801ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801ffa:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  802001:	8b 43 08             	mov    0x8(%ebx),%eax
  802004:	85 c0                	test   %eax,%eax
  802006:	74 71                	je     802079 <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  802008:	80 38 00             	cmpb   $0x0,(%eax)
  80200b:	75 50                	jne    80205d <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80200d:	8b 0b                	mov    (%ebx),%ecx
  80200f:	83 39 01             	cmpl   $0x1,(%ecx)
  802012:	74 57                	je     80206b <argnext+0x7b>
		    || args->argv[1][0] != '-'
  802014:	8b 53 04             	mov    0x4(%ebx),%edx
  802017:	8b 42 04             	mov    0x4(%edx),%eax
  80201a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80201d:	75 4c                	jne    80206b <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  80201f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  802023:	74 46                	je     80206b <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  802025:	83 c0 01             	add    $0x1,%eax
  802028:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80202b:	8b 01                	mov    (%ecx),%eax
  80202d:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  802034:	89 44 24 08          	mov    %eax,0x8(%esp)
  802038:	8d 42 08             	lea    0x8(%edx),%eax
  80203b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203f:	83 c2 04             	add    $0x4,%edx
  802042:	89 14 24             	mov    %edx,(%esp)
  802045:	e8 62 f5 ff ff       	call   8015ac <memmove>
		(*args->argc)--;
  80204a:	8b 03                	mov    (%ebx),%eax
  80204c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80204f:	8b 43 08             	mov    0x8(%ebx),%eax
  802052:	80 38 2d             	cmpb   $0x2d,(%eax)
  802055:	75 06                	jne    80205d <argnext+0x6d>
  802057:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80205b:	74 0e                	je     80206b <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80205d:	8b 53 08             	mov    0x8(%ebx),%edx
  802060:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  802063:	83 c2 01             	add    $0x1,%edx
  802066:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  802069:	eb 13                	jmp    80207e <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  80206b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  802072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802077:	eb 05                	jmp    80207e <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  802079:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80207e:	83 c4 14             	add    $0x14,%esp
  802081:	5b                   	pop    %ebx
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	53                   	push   %ebx
  802088:	83 ec 14             	sub    $0x14,%esp
  80208b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80208e:	8b 43 08             	mov    0x8(%ebx),%eax
  802091:	85 c0                	test   %eax,%eax
  802093:	74 5a                	je     8020ef <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  802095:	80 38 00             	cmpb   $0x0,(%eax)
  802098:	74 0c                	je     8020a6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80209a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80209d:	c7 43 08 81 3a 80 00 	movl   $0x803a81,0x8(%ebx)
  8020a4:	eb 44                	jmp    8020ea <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  8020a6:	8b 03                	mov    (%ebx),%eax
  8020a8:	83 38 01             	cmpl   $0x1,(%eax)
  8020ab:	7e 2f                	jle    8020dc <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  8020ad:	8b 53 04             	mov    0x4(%ebx),%edx
  8020b0:	8b 4a 04             	mov    0x4(%edx),%ecx
  8020b3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8020b6:	8b 00                	mov    (%eax),%eax
  8020b8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8020bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c3:	8d 42 08             	lea    0x8(%edx),%eax
  8020c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ca:	83 c2 04             	add    $0x4,%edx
  8020cd:	89 14 24             	mov    %edx,(%esp)
  8020d0:	e8 d7 f4 ff ff       	call   8015ac <memmove>
		(*args->argc)--;
  8020d5:	8b 03                	mov    (%ebx),%eax
  8020d7:	83 28 01             	subl   $0x1,(%eax)
  8020da:	eb 0e                	jmp    8020ea <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  8020dc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8020e3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8020ea:	8b 43 0c             	mov    0xc(%ebx),%eax
  8020ed:	eb 05                	jmp    8020f4 <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8020ef:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8020f4:	83 c4 14             	add    $0x14,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    

008020fa <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	83 ec 18             	sub    $0x18,%esp
  802100:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  802103:	8b 42 0c             	mov    0xc(%edx),%eax
  802106:	85 c0                	test   %eax,%eax
  802108:	75 08                	jne    802112 <argvalue+0x18>
  80210a:	89 14 24             	mov    %edx,(%esp)
  80210d:	e8 72 ff ff ff       	call   802084 <argnextvalue>
}
  802112:	c9                   	leave  
  802113:	c3                   	ret    
	...

00802120 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802123:	8b 45 08             	mov    0x8(%ebp),%eax
  802126:	05 00 00 00 30       	add    $0x30000000,%eax
  80212b:	c1 e8 0c             	shr    $0xc,%eax
}
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802136:	8b 45 08             	mov    0x8(%ebp),%eax
  802139:	89 04 24             	mov    %eax,(%esp)
  80213c:	e8 df ff ff ff       	call   802120 <fd2num>
  802141:	05 20 00 0d 00       	add    $0xd0020,%eax
  802146:	c1 e0 0c             	shl    $0xc,%eax
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	53                   	push   %ebx
  80214f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802152:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  802157:	a8 01                	test   $0x1,%al
  802159:	74 34                	je     80218f <fd_alloc+0x44>
  80215b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  802160:	a8 01                	test   $0x1,%al
  802162:	74 32                	je     802196 <fd_alloc+0x4b>
  802164:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802169:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80216b:	89 c2                	mov    %eax,%edx
  80216d:	c1 ea 16             	shr    $0x16,%edx
  802170:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802177:	f6 c2 01             	test   $0x1,%dl
  80217a:	74 1f                	je     80219b <fd_alloc+0x50>
  80217c:	89 c2                	mov    %eax,%edx
  80217e:	c1 ea 0c             	shr    $0xc,%edx
  802181:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802188:	f6 c2 01             	test   $0x1,%dl
  80218b:	75 17                	jne    8021a4 <fd_alloc+0x59>
  80218d:	eb 0c                	jmp    80219b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80218f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  802194:	eb 05                	jmp    80219b <fd_alloc+0x50>
  802196:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80219b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80219d:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a2:	eb 17                	jmp    8021bb <fd_alloc+0x70>
  8021a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8021a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8021ae:	75 b9                	jne    802169 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8021b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8021b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8021bb:	5b                   	pop    %ebx
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    

008021be <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8021c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8021c9:	83 fa 1f             	cmp    $0x1f,%edx
  8021cc:	77 3f                	ja     80220d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8021ce:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8021d4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8021d7:	89 d0                	mov    %edx,%eax
  8021d9:	c1 e8 16             	shr    $0x16,%eax
  8021dc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8021e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8021e8:	f6 c1 01             	test   $0x1,%cl
  8021eb:	74 20                	je     80220d <fd_lookup+0x4f>
  8021ed:	89 d0                	mov    %edx,%eax
  8021ef:	c1 e8 0c             	shr    $0xc,%eax
  8021f2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8021f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8021fe:	f6 c1 01             	test   $0x1,%cl
  802201:	74 0a                	je     80220d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802203:	8b 45 0c             	mov    0xc(%ebp),%eax
  802206:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  802208:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	53                   	push   %ebx
  802213:	83 ec 14             	sub    $0x14,%esp
  802216:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802219:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  802221:	39 0d 24 50 80 00    	cmp    %ecx,0x805024
  802227:	75 17                	jne    802240 <dev_lookup+0x31>
  802229:	eb 07                	jmp    802232 <dev_lookup+0x23>
  80222b:	39 0a                	cmp    %ecx,(%edx)
  80222d:	75 11                	jne    802240 <dev_lookup+0x31>
  80222f:	90                   	nop
  802230:	eb 05                	jmp    802237 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802232:	ba 24 50 80 00       	mov    $0x805024,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  802237:	89 13                	mov    %edx,(%ebx)
			return 0;
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
  80223e:	eb 35                	jmp    802275 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802240:	83 c0 01             	add    $0x1,%eax
  802243:	8b 14 85 08 42 80 00 	mov    0x804208(,%eax,4),%edx
  80224a:	85 d2                	test   %edx,%edx
  80224c:	75 dd                	jne    80222b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80224e:	a1 24 64 80 00       	mov    0x806424,%eax
  802253:	8b 40 48             	mov    0x48(%eax),%eax
  802256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225e:	c7 04 24 8c 41 80 00 	movl   $0x80418c,(%esp)
  802265:	e8 0d e9 ff ff       	call   800b77 <cprintf>
	*dev = 0;
  80226a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  802270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802275:	83 c4 14             	add    $0x14,%esp
  802278:	5b                   	pop    %ebx
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	83 ec 38             	sub    $0x38,%esp
  802281:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802284:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802287:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80228a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80228d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802291:	89 3c 24             	mov    %edi,(%esp)
  802294:	e8 87 fe ff ff       	call   802120 <fd2num>
  802299:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80229c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a0:	89 04 24             	mov    %eax,(%esp)
  8022a3:	e8 16 ff ff ff       	call   8021be <fd_lookup>
  8022a8:	89 c3                	mov    %eax,%ebx
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	78 05                	js     8022b3 <fd_close+0x38>
	    || fd != fd2)
  8022ae:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8022b1:	74 0e                	je     8022c1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8022b3:	89 f0                	mov    %esi,%eax
  8022b5:	84 c0                	test   %al,%al
  8022b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8022bc:	0f 44 d8             	cmove  %eax,%ebx
  8022bf:	eb 3d                	jmp    8022fe <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8022c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8022c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c8:	8b 07                	mov    (%edi),%eax
  8022ca:	89 04 24             	mov    %eax,(%esp)
  8022cd:	e8 3d ff ff ff       	call   80220f <dev_lookup>
  8022d2:	89 c3                	mov    %eax,%ebx
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 16                	js     8022ee <fd_close+0x73>
		if (dev->dev_close)
  8022d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8022de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	74 07                	je     8022ee <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8022e7:	89 3c 24             	mov    %edi,(%esp)
  8022ea:	ff d0                	call   *%eax
  8022ec:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8022ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f9:	e8 7b f6 ff ff       	call   801979 <sys_page_unmap>
	return r;
}
  8022fe:	89 d8                	mov    %ebx,%eax
  802300:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802303:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802306:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802309:	89 ec                	mov    %ebp,%esp
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80231a:	8b 45 08             	mov    0x8(%ebp),%eax
  80231d:	89 04 24             	mov    %eax,(%esp)
  802320:	e8 99 fe ff ff       	call   8021be <fd_lookup>
  802325:	85 c0                	test   %eax,%eax
  802327:	78 13                	js     80233c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802329:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802330:	00 
  802331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802334:	89 04 24             	mov    %eax,(%esp)
  802337:	e8 3f ff ff ff       	call   80227b <fd_close>
}
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    

0080233e <close_all>:

void
close_all(void)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	53                   	push   %ebx
  802342:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802345:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80234a:	89 1c 24             	mov    %ebx,(%esp)
  80234d:	e8 bb ff ff ff       	call   80230d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802352:	83 c3 01             	add    $0x1,%ebx
  802355:	83 fb 20             	cmp    $0x20,%ebx
  802358:	75 f0                	jne    80234a <close_all+0xc>
		close(i);
}
  80235a:	83 c4 14             	add    $0x14,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5d                   	pop    %ebp
  80235f:	c3                   	ret    

00802360 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	83 ec 58             	sub    $0x58,%esp
  802366:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802369:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80236c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80236f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802372:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802375:	89 44 24 04          	mov    %eax,0x4(%esp)
  802379:	8b 45 08             	mov    0x8(%ebp),%eax
  80237c:	89 04 24             	mov    %eax,(%esp)
  80237f:	e8 3a fe ff ff       	call   8021be <fd_lookup>
  802384:	89 c3                	mov    %eax,%ebx
  802386:	85 c0                	test   %eax,%eax
  802388:	0f 88 e1 00 00 00    	js     80246f <dup+0x10f>
		return r;
	close(newfdnum);
  80238e:	89 3c 24             	mov    %edi,(%esp)
  802391:	e8 77 ff ff ff       	call   80230d <close>

	newfd = INDEX2FD(newfdnum);
  802396:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80239c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80239f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023a2:	89 04 24             	mov    %eax,(%esp)
  8023a5:	e8 86 fd ff ff       	call   802130 <fd2data>
  8023aa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8023ac:	89 34 24             	mov    %esi,(%esp)
  8023af:	e8 7c fd ff ff       	call   802130 <fd2data>
  8023b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	c1 e8 16             	shr    $0x16,%eax
  8023bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8023c3:	a8 01                	test   $0x1,%al
  8023c5:	74 46                	je     80240d <dup+0xad>
  8023c7:	89 d8                	mov    %ebx,%eax
  8023c9:	c1 e8 0c             	shr    $0xc,%eax
  8023cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8023d3:	f6 c2 01             	test   $0x1,%dl
  8023d6:	74 35                	je     80240d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8023d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8023df:	25 07 0e 00 00       	and    $0xe07,%eax
  8023e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8023eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023f6:	00 
  8023f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802402:	e8 14 f5 ff ff       	call   80191b <sys_page_map>
  802407:	89 c3                	mov    %eax,%ebx
  802409:	85 c0                	test   %eax,%eax
  80240b:	78 3b                	js     802448 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80240d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802410:	89 c2                	mov    %eax,%edx
  802412:	c1 ea 0c             	shr    $0xc,%edx
  802415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80241c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802422:	89 54 24 10          	mov    %edx,0x10(%esp)
  802426:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80242a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802431:	00 
  802432:	89 44 24 04          	mov    %eax,0x4(%esp)
  802436:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80243d:	e8 d9 f4 ff ff       	call   80191b <sys_page_map>
  802442:	89 c3                	mov    %eax,%ebx
  802444:	85 c0                	test   %eax,%eax
  802446:	79 25                	jns    80246d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802448:	89 74 24 04          	mov    %esi,0x4(%esp)
  80244c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802453:	e8 21 f5 ff ff       	call   801979 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802458:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80245b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802466:	e8 0e f5 ff ff       	call   801979 <sys_page_unmap>
	return r;
  80246b:	eb 02                	jmp    80246f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80246d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80246f:	89 d8                	mov    %ebx,%eax
  802471:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802474:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802477:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80247a:	89 ec                	mov    %ebp,%esp
  80247c:	5d                   	pop    %ebp
  80247d:	c3                   	ret    

0080247e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	53                   	push   %ebx
  802482:	83 ec 24             	sub    $0x24,%esp
  802485:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802488:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80248b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248f:	89 1c 24             	mov    %ebx,(%esp)
  802492:	e8 27 fd ff ff       	call   8021be <fd_lookup>
  802497:	85 c0                	test   %eax,%eax
  802499:	78 6d                	js     802508 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80249b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024a5:	8b 00                	mov    (%eax),%eax
  8024a7:	89 04 24             	mov    %eax,(%esp)
  8024aa:	e8 60 fd ff ff       	call   80220f <dev_lookup>
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	78 55                	js     802508 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8024b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024b6:	8b 50 08             	mov    0x8(%eax),%edx
  8024b9:	83 e2 03             	and    $0x3,%edx
  8024bc:	83 fa 01             	cmp    $0x1,%edx
  8024bf:	75 23                	jne    8024e4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8024c1:	a1 24 64 80 00       	mov    0x806424,%eax
  8024c6:	8b 40 48             	mov    0x48(%eax),%eax
  8024c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d1:	c7 04 24 cd 41 80 00 	movl   $0x8041cd,(%esp)
  8024d8:	e8 9a e6 ff ff       	call   800b77 <cprintf>
		return -E_INVAL;
  8024dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8024e2:	eb 24                	jmp    802508 <read+0x8a>
	}
	if (!dev->dev_read)
  8024e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024e7:	8b 52 08             	mov    0x8(%edx),%edx
  8024ea:	85 d2                	test   %edx,%edx
  8024ec:	74 15                	je     802503 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8024ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8024f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8024fc:	89 04 24             	mov    %eax,(%esp)
  8024ff:	ff d2                	call   *%edx
  802501:	eb 05                	jmp    802508 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802503:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  802508:	83 c4 24             	add    $0x24,%esp
  80250b:	5b                   	pop    %ebx
  80250c:	5d                   	pop    %ebp
  80250d:	c3                   	ret    

0080250e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 7d 08             	mov    0x8(%ebp),%edi
  80251a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80251d:	b8 00 00 00 00       	mov    $0x0,%eax
  802522:	85 f6                	test   %esi,%esi
  802524:	74 30                	je     802556 <readn+0x48>
  802526:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80252b:	89 f2                	mov    %esi,%edx
  80252d:	29 c2                	sub    %eax,%edx
  80252f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802533:	03 45 0c             	add    0xc(%ebp),%eax
  802536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80253a:	89 3c 24             	mov    %edi,(%esp)
  80253d:	e8 3c ff ff ff       	call   80247e <read>
		if (m < 0)
  802542:	85 c0                	test   %eax,%eax
  802544:	78 10                	js     802556 <readn+0x48>
			return m;
		if (m == 0)
  802546:	85 c0                	test   %eax,%eax
  802548:	74 0a                	je     802554 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80254a:	01 c3                	add    %eax,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	39 f3                	cmp    %esi,%ebx
  802550:	72 d9                	jb     80252b <readn+0x1d>
  802552:	eb 02                	jmp    802556 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802554:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802556:	83 c4 1c             	add    $0x1c,%esp
  802559:	5b                   	pop    %ebx
  80255a:	5e                   	pop    %esi
  80255b:	5f                   	pop    %edi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    

0080255e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	53                   	push   %ebx
  802562:	83 ec 24             	sub    $0x24,%esp
  802565:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80256b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80256f:	89 1c 24             	mov    %ebx,(%esp)
  802572:	e8 47 fc ff ff       	call   8021be <fd_lookup>
  802577:	85 c0                	test   %eax,%eax
  802579:	78 68                	js     8025e3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80257b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802585:	8b 00                	mov    (%eax),%eax
  802587:	89 04 24             	mov    %eax,(%esp)
  80258a:	e8 80 fc ff ff       	call   80220f <dev_lookup>
  80258f:	85 c0                	test   %eax,%eax
  802591:	78 50                	js     8025e3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802593:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802596:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80259a:	75 23                	jne    8025bf <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80259c:	a1 24 64 80 00       	mov    0x806424,%eax
  8025a1:	8b 40 48             	mov    0x48(%eax),%eax
  8025a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ac:	c7 04 24 e9 41 80 00 	movl   $0x8041e9,(%esp)
  8025b3:	e8 bf e5 ff ff       	call   800b77 <cprintf>
		return -E_INVAL;
  8025b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8025bd:	eb 24                	jmp    8025e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8025bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8025c5:	85 d2                	test   %edx,%edx
  8025c7:	74 15                	je     8025de <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8025c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8025cc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8025d7:	89 04 24             	mov    %eax,(%esp)
  8025da:	ff d2                	call   *%edx
  8025dc:	eb 05                	jmp    8025e3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8025de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8025e3:	83 c4 24             	add    $0x24,%esp
  8025e6:	5b                   	pop    %ebx
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    

008025e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8025e9:	55                   	push   %ebp
  8025ea:	89 e5                	mov    %esp,%ebp
  8025ec:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8025f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8025f9:	89 04 24             	mov    %eax,(%esp)
  8025fc:	e8 bd fb ff ff       	call   8021be <fd_lookup>
  802601:	85 c0                	test   %eax,%eax
  802603:	78 0e                	js     802613 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802605:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802608:	8b 55 0c             	mov    0xc(%ebp),%edx
  80260b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80260e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802613:	c9                   	leave  
  802614:	c3                   	ret    

00802615 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	53                   	push   %ebx
  802619:	83 ec 24             	sub    $0x24,%esp
  80261c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80261f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802622:	89 44 24 04          	mov    %eax,0x4(%esp)
  802626:	89 1c 24             	mov    %ebx,(%esp)
  802629:	e8 90 fb ff ff       	call   8021be <fd_lookup>
  80262e:	85 c0                	test   %eax,%eax
  802630:	78 61                	js     802693 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802635:	89 44 24 04          	mov    %eax,0x4(%esp)
  802639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80263c:	8b 00                	mov    (%eax),%eax
  80263e:	89 04 24             	mov    %eax,(%esp)
  802641:	e8 c9 fb ff ff       	call   80220f <dev_lookup>
  802646:	85 c0                	test   %eax,%eax
  802648:	78 49                	js     802693 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80264a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80264d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802651:	75 23                	jne    802676 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802653:	a1 24 64 80 00       	mov    0x806424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802658:	8b 40 48             	mov    0x48(%eax),%eax
  80265b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80265f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802663:	c7 04 24 ac 41 80 00 	movl   $0x8041ac,(%esp)
  80266a:	e8 08 e5 ff ff       	call   800b77 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80266f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802674:	eb 1d                	jmp    802693 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  802676:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802679:	8b 52 18             	mov    0x18(%edx),%edx
  80267c:	85 d2                	test   %edx,%edx
  80267e:	74 0e                	je     80268e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802680:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802683:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802687:	89 04 24             	mov    %eax,(%esp)
  80268a:	ff d2                	call   *%edx
  80268c:	eb 05                	jmp    802693 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80268e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802693:	83 c4 24             	add    $0x24,%esp
  802696:	5b                   	pop    %ebx
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    

00802699 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802699:	55                   	push   %ebp
  80269a:	89 e5                	mov    %esp,%ebp
  80269c:	53                   	push   %ebx
  80269d:	83 ec 24             	sub    $0x24,%esp
  8026a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8026a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ad:	89 04 24             	mov    %eax,(%esp)
  8026b0:	e8 09 fb ff ff       	call   8021be <fd_lookup>
  8026b5:	85 c0                	test   %eax,%eax
  8026b7:	78 52                	js     80270b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8026b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026c3:	8b 00                	mov    (%eax),%eax
  8026c5:	89 04 24             	mov    %eax,(%esp)
  8026c8:	e8 42 fb ff ff       	call   80220f <dev_lookup>
  8026cd:	85 c0                	test   %eax,%eax
  8026cf:	78 3a                	js     80270b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8026d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8026d8:	74 2c                	je     802706 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8026da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8026dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8026e4:	00 00 00 
	stat->st_isdir = 0;
  8026e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026ee:	00 00 00 
	stat->st_dev = dev;
  8026f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8026f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026fe:	89 14 24             	mov    %edx,(%esp)
  802701:	ff 50 14             	call   *0x14(%eax)
  802704:	eb 05                	jmp    80270b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802706:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80270b:	83 c4 24             	add    $0x24,%esp
  80270e:	5b                   	pop    %ebx
  80270f:	5d                   	pop    %ebp
  802710:	c3                   	ret    

00802711 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802711:	55                   	push   %ebp
  802712:	89 e5                	mov    %esp,%ebp
  802714:	83 ec 18             	sub    $0x18,%esp
  802717:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80271a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80271d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802724:	00 
  802725:	8b 45 08             	mov    0x8(%ebp),%eax
  802728:	89 04 24             	mov    %eax,(%esp)
  80272b:	e8 bc 01 00 00       	call   8028ec <open>
  802730:	89 c3                	mov    %eax,%ebx
  802732:	85 c0                	test   %eax,%eax
  802734:	78 1b                	js     802751 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802736:	8b 45 0c             	mov    0xc(%ebp),%eax
  802739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80273d:	89 1c 24             	mov    %ebx,(%esp)
  802740:	e8 54 ff ff ff       	call   802699 <fstat>
  802745:	89 c6                	mov    %eax,%esi
	close(fd);
  802747:	89 1c 24             	mov    %ebx,(%esp)
  80274a:	e8 be fb ff ff       	call   80230d <close>
	return r;
  80274f:	89 f3                	mov    %esi,%ebx
}
  802751:	89 d8                	mov    %ebx,%eax
  802753:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802756:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802759:	89 ec                	mov    %ebp,%esp
  80275b:	5d                   	pop    %ebp
  80275c:	c3                   	ret    
  80275d:	00 00                	add    %al,(%eax)
	...

00802760 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	83 ec 18             	sub    $0x18,%esp
  802766:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802769:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80276c:	89 c3                	mov    %eax,%ebx
  80276e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802770:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  802777:	75 11                	jne    80278a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802779:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802780:	e8 9c 0f 00 00       	call   803721 <ipc_find_env>
  802785:	a3 20 64 80 00       	mov    %eax,0x806420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80278a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802791:	00 
  802792:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802799:	00 
  80279a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80279e:	a1 20 64 80 00       	mov    0x806420,%eax
  8027a3:	89 04 24             	mov    %eax,(%esp)
  8027a6:	e8 0b 0f 00 00       	call   8036b6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  8027ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8027b2:	00 
  8027b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027be:	e8 8d 0e 00 00       	call   803650 <ipc_recv>
}
  8027c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8027c6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8027c9:	89 ec                	mov    %ebp,%esp
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    

008027cd <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8027cd:	55                   	push   %ebp
  8027ce:	89 e5                	mov    %esp,%ebp
  8027d0:	53                   	push   %ebx
  8027d1:	83 ec 14             	sub    $0x14,%esp
  8027d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8027d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027da:	8b 40 0c             	mov    0xc(%eax),%eax
  8027dd:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8027e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8027e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8027ec:	e8 6f ff ff ff       	call   802760 <fsipc>
  8027f1:	85 c0                	test   %eax,%eax
  8027f3:	78 2b                	js     802820 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8027f5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8027fc:	00 
  8027fd:	89 1c 24             	mov    %ebx,(%esp)
  802800:	e8 b6 eb ff ff       	call   8013bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802805:	a1 80 70 80 00       	mov    0x807080,%eax
  80280a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802810:	a1 84 70 80 00       	mov    0x807084,%eax
  802815:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80281b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802820:	83 c4 14             	add    $0x14,%esp
  802823:	5b                   	pop    %ebx
  802824:	5d                   	pop    %ebp
  802825:	c3                   	ret    

00802826 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802826:	55                   	push   %ebp
  802827:	89 e5                	mov    %esp,%ebp
  802829:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80282c:	8b 45 08             	mov    0x8(%ebp),%eax
  80282f:	8b 40 0c             	mov    0xc(%eax),%eax
  802832:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  802837:	ba 00 00 00 00       	mov    $0x0,%edx
  80283c:	b8 06 00 00 00       	mov    $0x6,%eax
  802841:	e8 1a ff ff ff       	call   802760 <fsipc>
}
  802846:	c9                   	leave  
  802847:	c3                   	ret    

00802848 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802848:	55                   	push   %ebp
  802849:	89 e5                	mov    %esp,%ebp
  80284b:	56                   	push   %esi
  80284c:	53                   	push   %ebx
  80284d:	83 ec 10             	sub    $0x10,%esp
  802850:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802853:	8b 45 08             	mov    0x8(%ebp),%eax
  802856:	8b 40 0c             	mov    0xc(%eax),%eax
  802859:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80285e:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802864:	ba 00 00 00 00       	mov    $0x0,%edx
  802869:	b8 03 00 00 00       	mov    $0x3,%eax
  80286e:	e8 ed fe ff ff       	call   802760 <fsipc>
  802873:	89 c3                	mov    %eax,%ebx
  802875:	85 c0                	test   %eax,%eax
  802877:	78 6a                	js     8028e3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802879:	39 c6                	cmp    %eax,%esi
  80287b:	73 24                	jae    8028a1 <devfile_read+0x59>
  80287d:	c7 44 24 0c 18 42 80 	movl   $0x804218,0xc(%esp)
  802884:	00 
  802885:	c7 44 24 08 b2 3b 80 	movl   $0x803bb2,0x8(%esp)
  80288c:	00 
  80288d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  802894:	00 
  802895:	c7 04 24 1f 42 80 00 	movl   $0x80421f,(%esp)
  80289c:	e8 db e1 ff ff       	call   800a7c <_panic>
	assert(r <= PGSIZE);
  8028a1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8028a6:	7e 24                	jle    8028cc <devfile_read+0x84>
  8028a8:	c7 44 24 0c 2a 42 80 	movl   $0x80422a,0xc(%esp)
  8028af:	00 
  8028b0:	c7 44 24 08 b2 3b 80 	movl   $0x803bb2,0x8(%esp)
  8028b7:	00 
  8028b8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8028bf:	00 
  8028c0:	c7 04 24 1f 42 80 00 	movl   $0x80421f,(%esp)
  8028c7:	e8 b0 e1 ff ff       	call   800a7c <_panic>
	memmove(buf, &fsipcbuf, r);
  8028cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028d0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8028d7:	00 
  8028d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028db:	89 04 24             	mov    %eax,(%esp)
  8028de:	e8 c9 ec ff ff       	call   8015ac <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  8028e3:	89 d8                	mov    %ebx,%eax
  8028e5:	83 c4 10             	add    $0x10,%esp
  8028e8:	5b                   	pop    %ebx
  8028e9:	5e                   	pop    %esi
  8028ea:	5d                   	pop    %ebp
  8028eb:	c3                   	ret    

008028ec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8028ec:	55                   	push   %ebp
  8028ed:	89 e5                	mov    %esp,%ebp
  8028ef:	56                   	push   %esi
  8028f0:	53                   	push   %ebx
  8028f1:	83 ec 20             	sub    $0x20,%esp
  8028f4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8028f7:	89 34 24             	mov    %esi,(%esp)
  8028fa:	e8 71 ea ff ff       	call   801370 <strlen>
		return -E_BAD_PATH;
  8028ff:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802904:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802909:	7f 5e                	jg     802969 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80290b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80290e:	89 04 24             	mov    %eax,(%esp)
  802911:	e8 35 f8 ff ff       	call   80214b <fd_alloc>
  802916:	89 c3                	mov    %eax,%ebx
  802918:	85 c0                	test   %eax,%eax
  80291a:	78 4d                	js     802969 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80291c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802920:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  802927:	e8 8f ea ff ff       	call   8013bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  80292c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80292f:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802934:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802937:	b8 01 00 00 00       	mov    $0x1,%eax
  80293c:	e8 1f fe ff ff       	call   802760 <fsipc>
  802941:	89 c3                	mov    %eax,%ebx
  802943:	85 c0                	test   %eax,%eax
  802945:	79 15                	jns    80295c <open+0x70>
		fd_close(fd, 0);
  802947:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80294e:	00 
  80294f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802952:	89 04 24             	mov    %eax,(%esp)
  802955:	e8 21 f9 ff ff       	call   80227b <fd_close>
		return r;
  80295a:	eb 0d                	jmp    802969 <open+0x7d>
	}

	return fd2num(fd);
  80295c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80295f:	89 04 24             	mov    %eax,(%esp)
  802962:	e8 b9 f7 ff ff       	call   802120 <fd2num>
  802967:	89 c3                	mov    %eax,%ebx
}
  802969:	89 d8                	mov    %ebx,%eax
  80296b:	83 c4 20             	add    $0x20,%esp
  80296e:	5b                   	pop    %ebx
  80296f:	5e                   	pop    %esi
  802970:	5d                   	pop    %ebp
  802971:	c3                   	ret    
	...

00802974 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  802974:	55                   	push   %ebp
  802975:	89 e5                	mov    %esp,%ebp
  802977:	53                   	push   %ebx
  802978:	83 ec 14             	sub    $0x14,%esp
  80297b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80297d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802981:	7e 31                	jle    8029b4 <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  802983:	8b 40 04             	mov    0x4(%eax),%eax
  802986:	89 44 24 08          	mov    %eax,0x8(%esp)
  80298a:	8d 43 10             	lea    0x10(%ebx),%eax
  80298d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802991:	8b 03                	mov    (%ebx),%eax
  802993:	89 04 24             	mov    %eax,(%esp)
  802996:	e8 c3 fb ff ff       	call   80255e <write>
		if (result > 0)
  80299b:	85 c0                	test   %eax,%eax
  80299d:	7e 03                	jle    8029a2 <writebuf+0x2e>
			b->result += result;
  80299f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8029a2:	39 43 04             	cmp    %eax,0x4(%ebx)
  8029a5:	74 0d                	je     8029b4 <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  8029a7:	85 c0                	test   %eax,%eax
  8029a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8029ae:	0f 4f c2             	cmovg  %edx,%eax
  8029b1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8029b4:	83 c4 14             	add    $0x14,%esp
  8029b7:	5b                   	pop    %ebx
  8029b8:	5d                   	pop    %ebp
  8029b9:	c3                   	ret    

008029ba <putch>:

static void
putch(int ch, void *thunk)
{
  8029ba:	55                   	push   %ebp
  8029bb:	89 e5                	mov    %esp,%ebp
  8029bd:	53                   	push   %ebx
  8029be:	83 ec 04             	sub    $0x4,%esp
  8029c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8029c4:	8b 43 04             	mov    0x4(%ebx),%eax
  8029c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8029ca:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8029ce:	83 c0 01             	add    $0x1,%eax
  8029d1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8029d4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8029d9:	75 0e                	jne    8029e9 <putch+0x2f>
		writebuf(b);
  8029db:	89 d8                	mov    %ebx,%eax
  8029dd:	e8 92 ff ff ff       	call   802974 <writebuf>
		b->idx = 0;
  8029e2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8029e9:	83 c4 04             	add    $0x4,%esp
  8029ec:	5b                   	pop    %ebx
  8029ed:	5d                   	pop    %ebp
  8029ee:	c3                   	ret    

008029ef <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8029ef:	55                   	push   %ebp
  8029f0:	89 e5                	mov    %esp,%ebp
  8029f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8029f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8029fb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802a01:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802a08:	00 00 00 
	b.result = 0;
  802a0b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802a12:	00 00 00 
	b.error = 1;
  802a15:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802a1c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802a1f:	8b 45 10             	mov    0x10(%ebp),%eax
  802a22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a29:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a2d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a37:	c7 04 24 ba 29 80 00 	movl   $0x8029ba,(%esp)
  802a3e:	e8 ab e2 ff ff       	call   800cee <vprintfmt>
	if (b.idx > 0)
  802a43:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802a4a:	7e 0b                	jle    802a57 <vfprintf+0x68>
		writebuf(&b);
  802a4c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802a52:	e8 1d ff ff ff       	call   802974 <writebuf>

	return (b.result ? b.result : b.error);
  802a57:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802a5d:	85 c0                	test   %eax,%eax
  802a5f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802a66:	c9                   	leave  
  802a67:	c3                   	ret    

00802a68 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802a68:	55                   	push   %ebp
  802a69:	89 e5                	mov    %esp,%ebp
  802a6b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802a6e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802a71:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7f:	89 04 24             	mov    %eax,(%esp)
  802a82:	e8 68 ff ff ff       	call   8029ef <vfprintf>
	va_end(ap);

	return cnt;
}
  802a87:	c9                   	leave  
  802a88:	c3                   	ret    

00802a89 <printf>:

int
printf(const char *fmt, ...)
{
  802a89:	55                   	push   %ebp
  802a8a:	89 e5                	mov    %esp,%ebp
  802a8c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802a8f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802a92:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a96:	8b 45 08             	mov    0x8(%ebp),%eax
  802a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802aa4:	e8 46 ff ff ff       	call   8029ef <vfprintf>
	va_end(ap);

	return cnt;
}
  802aa9:	c9                   	leave  
  802aaa:	c3                   	ret    
	...

00802aac <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802aac:	55                   	push   %ebp
  802aad:	89 e5                	mov    %esp,%ebp
  802aaf:	57                   	push   %edi
  802ab0:	56                   	push   %esi
  802ab1:	53                   	push   %ebx
  802ab2:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802ab8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802abf:	00 
  802ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  802ac3:	89 04 24             	mov    %eax,(%esp)
  802ac6:	e8 21 fe ff ff       	call   8028ec <open>
  802acb:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802ad1:	85 c0                	test   %eax,%eax
  802ad3:	0f 88 c9 05 00 00    	js     8030a2 <spawn+0x5f6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802ad9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802ae0:	00 
  802ae1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802aeb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802af1:	89 04 24             	mov    %eax,(%esp)
  802af4:	e8 15 fa ff ff       	call   80250e <readn>
  802af9:	3d 00 02 00 00       	cmp    $0x200,%eax
  802afe:	75 0c                	jne    802b0c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  802b00:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802b07:	45 4c 46 
  802b0a:	74 3b                	je     802b47 <spawn+0x9b>
		close(fd);
  802b0c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b12:	89 04 24             	mov    %eax,(%esp)
  802b15:	e8 f3 f7 ff ff       	call   80230d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802b1a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802b21:	46 
  802b22:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802b28:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b2c:	c7 04 24 36 42 80 00 	movl   $0x804236,(%esp)
  802b33:	e8 3f e0 ff ff       	call   800b77 <cprintf>
		return -E_NOT_EXEC;
  802b38:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  802b3f:	ff ff ff 
  802b42:	e9 67 05 00 00       	jmp    8030ae <spawn+0x602>
  802b47:	ba 07 00 00 00       	mov    $0x7,%edx
  802b4c:	89 d0                	mov    %edx,%eax
  802b4e:	cd 30                	int    $0x30
  802b50:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802b56:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802b5c:	85 c0                	test   %eax,%eax
  802b5e:	0f 88 4a 05 00 00    	js     8030ae <spawn+0x602>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802b64:	89 c6                	mov    %eax,%esi
  802b66:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802b6c:	c1 e6 07             	shl    $0x7,%esi
  802b6f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802b75:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802b7b:	b9 11 00 00 00       	mov    $0x11,%ecx
  802b80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802b82:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802b88:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b91:	8b 02                	mov    (%edx),%eax
  802b93:	85 c0                	test   %eax,%eax
  802b95:	74 5f                	je     802bf6 <spawn+0x14a>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802b97:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (argc = 0; argv[argc] != 0; argc++)
  802b9c:	be 00 00 00 00       	mov    $0x0,%esi
  802ba1:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  802ba3:	89 04 24             	mov    %eax,(%esp)
  802ba6:	e8 c5 e7 ff ff       	call   801370 <strlen>
  802bab:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802baf:	83 c6 01             	add    $0x1,%esi
  802bb2:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802bb4:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802bbb:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  802bbe:	85 c0                	test   %eax,%eax
  802bc0:	75 e1                	jne    802ba3 <spawn+0xf7>
  802bc2:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802bc8:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802bce:	bf 00 10 40 00       	mov    $0x401000,%edi
  802bd3:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802bd5:	89 f8                	mov    %edi,%eax
  802bd7:	83 e0 fc             	and    $0xfffffffc,%eax
  802bda:	f7 d2                	not    %edx
  802bdc:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802bdf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802be5:	89 d0                	mov    %edx,%eax
  802be7:	83 e8 08             	sub    $0x8,%eax
  802bea:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802bef:	77 2d                	ja     802c1e <spawn+0x172>
  802bf1:	e9 c9 04 00 00       	jmp    8030bf <spawn+0x613>
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802bf6:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802bfd:	00 00 00 
  802c00:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  802c07:	00 00 00 
  802c0a:	be 00 00 00 00       	mov    $0x0,%esi
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802c0f:	c7 85 94 fd ff ff fc 	movl   $0x400ffc,-0x26c(%ebp)
  802c16:	0f 40 00 
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802c19:	bf 00 10 40 00       	mov    $0x401000,%edi
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802c1e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802c25:	00 
  802c26:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802c2d:	00 
  802c2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c35:	e8 82 ec ff ff       	call   8018bc <sys_page_alloc>
  802c3a:	85 c0                	test   %eax,%eax
  802c3c:	0f 88 82 04 00 00    	js     8030c4 <spawn+0x618>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802c42:	85 f6                	test   %esi,%esi
  802c44:	7e 46                	jle    802c8c <spawn+0x1e0>
  802c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c4b:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802c51:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  802c54:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802c5a:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802c60:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802c63:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c6a:	89 3c 24             	mov    %edi,(%esp)
  802c6d:	e8 49 e7 ff ff       	call   8013bb <strcpy>
		string_store += strlen(argv[i]) + 1;
  802c72:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802c75:	89 04 24             	mov    %eax,(%esp)
  802c78:	e8 f3 e6 ff ff       	call   801370 <strlen>
  802c7d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802c81:	83 c3 01             	add    $0x1,%ebx
  802c84:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802c8a:	75 c8                	jne    802c54 <spawn+0x1a8>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802c8c:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802c92:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802c98:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802c9f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802ca5:	74 24                	je     802ccb <spawn+0x21f>
  802ca7:	c7 44 24 0c ac 42 80 	movl   $0x8042ac,0xc(%esp)
  802cae:	00 
  802caf:	c7 44 24 08 b2 3b 80 	movl   $0x803bb2,0x8(%esp)
  802cb6:	00 
  802cb7:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  802cbe:	00 
  802cbf:	c7 04 24 50 42 80 00 	movl   $0x804250,(%esp)
  802cc6:	e8 b1 dd ff ff       	call   800a7c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802ccb:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802cd1:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802cd6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802cdc:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802cdf:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802ce5:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802ce8:	89 d0                	mov    %edx,%eax
  802cea:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802cef:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802cf5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802cfc:	00 
  802cfd:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802d04:	ee 
  802d05:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d0f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802d16:	00 
  802d17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d1e:	e8 f8 eb ff ff       	call   80191b <sys_page_map>
  802d23:	89 c3                	mov    %eax,%ebx
  802d25:	85 c0                	test   %eax,%eax
  802d27:	78 1a                	js     802d43 <spawn+0x297>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802d29:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802d30:	00 
  802d31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d38:	e8 3c ec ff ff       	call   801979 <sys_page_unmap>
  802d3d:	89 c3                	mov    %eax,%ebx
  802d3f:	85 c0                	test   %eax,%eax
  802d41:	79 1f                	jns    802d62 <spawn+0x2b6>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802d43:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802d4a:	00 
  802d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d52:	e8 22 ec ff ff       	call   801979 <sys_page_unmap>
	return r;
  802d57:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802d5d:	e9 4c 03 00 00       	jmp    8030ae <spawn+0x602>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802d62:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802d68:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  802d6f:	00 
  802d70:	0f 84 e2 01 00 00    	je     802f58 <spawn+0x4ac>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802d76:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802d7d:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802d83:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802d8a:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  802d8d:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802d93:	83 3a 01             	cmpl   $0x1,(%edx)
  802d96:	0f 85 9b 01 00 00    	jne    802f37 <spawn+0x48b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802d9c:	8b 42 18             	mov    0x18(%edx),%eax
  802d9f:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802da2:	83 f8 01             	cmp    $0x1,%eax
  802da5:	19 c0                	sbb    %eax,%eax
  802da7:	83 e0 fe             	and    $0xfffffffe,%eax
  802daa:	83 c0 07             	add    $0x7,%eax
  802dad:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802db3:	8b 52 04             	mov    0x4(%edx),%edx
  802db6:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802dbc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802dc2:	8b 70 10             	mov    0x10(%eax),%esi
  802dc5:	8b 50 14             	mov    0x14(%eax),%edx
  802dc8:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802dce:	8b 40 08             	mov    0x8(%eax),%eax
  802dd1:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802dd7:	25 ff 0f 00 00       	and    $0xfff,%eax
  802ddc:	74 16                	je     802df4 <spawn+0x348>
		va -= i;
  802dde:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  802de4:	01 c2                	add    %eax,%edx
  802de6:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802dec:	01 c6                	add    %eax,%esi
		fileoffset -= i;
  802dee:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802df4:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  802dfb:	0f 84 36 01 00 00    	je     802f37 <spawn+0x48b>
  802e01:	bf 00 00 00 00       	mov    $0x0,%edi
  802e06:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  802e0b:	39 f7                	cmp    %esi,%edi
  802e0d:	72 31                	jb     802e40 <spawn+0x394>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802e0f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802e15:	89 54 24 08          	mov    %edx,0x8(%esp)
  802e19:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802e1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e23:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802e29:	89 04 24             	mov    %eax,(%esp)
  802e2c:	e8 8b ea ff ff       	call   8018bc <sys_page_alloc>
  802e31:	85 c0                	test   %eax,%eax
  802e33:	0f 89 ea 00 00 00    	jns    802f23 <spawn+0x477>
  802e39:	89 c6                	mov    %eax,%esi
  802e3b:	e9 3e 02 00 00       	jmp    80307e <spawn+0x5d2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802e40:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802e47:	00 
  802e48:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802e4f:	00 
  802e50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e57:	e8 60 ea ff ff       	call   8018bc <sys_page_alloc>
  802e5c:	85 c0                	test   %eax,%eax
  802e5e:	0f 88 10 02 00 00    	js     803074 <spawn+0x5c8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802e64:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802e6a:	01 d8                	add    %ebx,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e70:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802e76:	89 04 24             	mov    %eax,(%esp)
  802e79:	e8 6b f7 ff ff       	call   8025e9 <seek>
  802e7e:	85 c0                	test   %eax,%eax
  802e80:	0f 88 f2 01 00 00    	js     803078 <spawn+0x5cc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802e86:	89 f0                	mov    %esi,%eax
  802e88:	29 f8                	sub    %edi,%eax
  802e8a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802e8f:	ba 00 10 00 00       	mov    $0x1000,%edx
  802e94:	0f 47 c2             	cmova  %edx,%eax
  802e97:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e9b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ea2:	00 
  802ea3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802ea9:	89 04 24             	mov    %eax,(%esp)
  802eac:	e8 5d f6 ff ff       	call   80250e <readn>
  802eb1:	85 c0                	test   %eax,%eax
  802eb3:	0f 88 c3 01 00 00    	js     80307c <spawn+0x5d0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802eb9:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802ebf:	89 54 24 10          	mov    %edx,0x10(%esp)
  802ec3:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  802ec9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ecd:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ed7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ede:	00 
  802edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ee6:	e8 30 ea ff ff       	call   80191b <sys_page_map>
  802eeb:	85 c0                	test   %eax,%eax
  802eed:	79 20                	jns    802f0f <spawn+0x463>
				panic("spawn: sys_page_map data: %e", r);
  802eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ef3:	c7 44 24 08 5c 42 80 	movl   $0x80425c,0x8(%esp)
  802efa:	00 
  802efb:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  802f02:	00 
  802f03:	c7 04 24 50 42 80 00 	movl   $0x804250,(%esp)
  802f0a:	e8 6d db ff ff       	call   800a7c <_panic>
			sys_page_unmap(0, UTEMP);
  802f0f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802f16:	00 
  802f17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f1e:	e8 56 ea ff ff       	call   801979 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802f23:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802f29:	89 df                	mov    %ebx,%edi
  802f2b:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802f31:	0f 82 d4 fe ff ff    	jb     802e0b <spawn+0x35f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802f37:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802f3e:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802f45:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802f4c:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  802f52:	0f 8f 35 fe ff ff    	jg     802d8d <spawn+0x2e1>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802f58:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802f5e:	89 04 24             	mov    %eax,(%esp)
  802f61:	e8 a7 f3 ff ff       	call   80230d <close>
  802f66:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  802f6b:	be 00 00 00 00       	mov    $0x0,%esi
  802f70:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(i * PGSIZE)] & PTE_P) && (uvpt[i] & PTE_P) && (uvpt[i] & PTE_SHARE)) {
  802f76:	89 f8                	mov    %edi,%eax
  802f78:	c1 e8 16             	shr    $0x16,%eax
  802f7b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802f82:	a8 01                	test   $0x1,%al
  802f84:	74 63                	je     802fe9 <spawn+0x53d>
  802f86:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802f8d:	a8 01                	test   $0x1,%al
  802f8f:	74 58                	je     802fe9 <spawn+0x53d>
  802f91:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802f98:	f6 c4 04             	test   $0x4,%ah
  802f9b:	74 4c                	je     802fe9 <spawn+0x53d>
			res = sys_page_map(0, (void *)(i * PGSIZE), child, (void *)(i * PGSIZE), uvpt[i] & PTE_SYSCALL);
  802f9d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802fa4:	25 07 0e 00 00       	and    $0xe07,%eax
  802fa9:	89 44 24 10          	mov    %eax,0x10(%esp)
  802fad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802fb1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fb5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fc0:	e8 56 e9 ff ff       	call   80191b <sys_page_map>
			if (res < 0)
  802fc5:	85 c0                	test   %eax,%eax
  802fc7:	79 20                	jns    802fe9 <spawn+0x53d>
				panic("sys_page_map failed in copy_shared_pages %e\n", res);
  802fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802fcd:	c7 44 24 08 d4 42 80 	movl   $0x8042d4,0x8(%esp)
  802fd4:	00 
  802fd5:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  802fdc:	00 
  802fdd:	c7 04 24 50 42 80 00 	movl   $0x804250,(%esp)
  802fe4:	e8 93 da ff ff       	call   800a7c <_panic>
	// LAB 5: Your code here.
//-----------------------------------------------------------------------  Lab5  -----------------------------	
	uint32_t i;
	int res;

	for (i = 0; i < UTOP / PGSIZE; i++) {
  802fe9:	83 c6 01             	add    $0x1,%esi
  802fec:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802ff2:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  802ff8:	0f 85 78 ff ff ff    	jne    802f76 <spawn+0x4ca>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802ffe:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  803004:	89 44 24 04          	mov    %eax,0x4(%esp)
  803008:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80300e:	89 04 24             	mov    %eax,(%esp)
  803011:	e8 1f ea ff ff       	call   801a35 <sys_env_set_trapframe>
  803016:	85 c0                	test   %eax,%eax
  803018:	79 20                	jns    80303a <spawn+0x58e>
		panic("sys_env_set_trapframe: %e", r);
  80301a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80301e:	c7 44 24 08 79 42 80 	movl   $0x804279,0x8(%esp)
  803025:	00 
  803026:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80302d:	00 
  80302e:	c7 04 24 50 42 80 00 	movl   $0x804250,(%esp)
  803035:	e8 42 da ff ff       	call   800a7c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80303a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  803041:	00 
  803042:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  803048:	89 04 24             	mov    %eax,(%esp)
  80304b:	e8 87 e9 ff ff       	call   8019d7 <sys_env_set_status>
  803050:	85 c0                	test   %eax,%eax
  803052:	79 5a                	jns    8030ae <spawn+0x602>
		panic("sys_env_set_status: %e", r);
  803054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803058:	c7 44 24 08 93 42 80 	movl   $0x804293,0x8(%esp)
  80305f:	00 
  803060:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  803067:	00 
  803068:	c7 04 24 50 42 80 00 	movl   $0x804250,(%esp)
  80306f:	e8 08 da ff ff       	call   800a7c <_panic>
  803074:	89 c6                	mov    %eax,%esi
  803076:	eb 06                	jmp    80307e <spawn+0x5d2>
  803078:	89 c6                	mov    %eax,%esi
  80307a:	eb 02                	jmp    80307e <spawn+0x5d2>
  80307c:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  80307e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  803084:	89 04 24             	mov    %eax,(%esp)
  803087:	e8 73 e7 ff ff       	call   8017ff <sys_env_destroy>
	close(fd);
  80308c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  803092:	89 04 24             	mov    %eax,(%esp)
  803095:	e8 73 f2 ff ff       	call   80230d <close>
	return r;
  80309a:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8030a0:	eb 0c                	jmp    8030ae <spawn+0x602>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8030a2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8030a8:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8030ae:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8030b4:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8030ba:	5b                   	pop    %ebx
  8030bb:	5e                   	pop    %esi
  8030bc:	5f                   	pop    %edi
  8030bd:	5d                   	pop    %ebp
  8030be:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8030bf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  8030c4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8030ca:	eb e2                	jmp    8030ae <spawn+0x602>

008030cc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8030cc:	55                   	push   %ebp
  8030cd:	89 e5                	mov    %esp,%ebp
  8030cf:	56                   	push   %esi
  8030d0:	53                   	push   %ebx
  8030d1:	83 ec 10             	sub    $0x10,%esp
  8030d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8030d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8030da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8030de:	74 66                	je     803146 <spawnl+0x7a>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8030e0:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8030e5:	83 c1 01             	add    $0x1,%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8030e8:	89 c2                	mov    %eax,%edx
  8030ea:	83 c0 04             	add    $0x4,%eax
  8030ed:	83 3a 00             	cmpl   $0x0,(%edx)
  8030f0:	75 f3                	jne    8030e5 <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8030f2:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8030f9:	83 e0 f0             	and    $0xfffffff0,%eax
  8030fc:	29 c4                	sub    %eax,%esp
  8030fe:	8d 44 24 17          	lea    0x17(%esp),%eax
  803102:	83 e0 f0             	and    $0xfffffff0,%eax
  803105:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  803107:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  803109:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  803110:	00 

	va_start(vl, arg0);
  803111:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  803114:	89 ce                	mov    %ecx,%esi
  803116:	85 c9                	test   %ecx,%ecx
  803118:	74 16                	je     803130 <spawnl+0x64>
  80311a:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80311f:	83 c0 01             	add    $0x1,%eax
  803122:	89 d1                	mov    %edx,%ecx
  803124:	83 c2 04             	add    $0x4,%edx
  803127:	8b 09                	mov    (%ecx),%ecx
  803129:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80312c:	39 f0                	cmp    %esi,%eax
  80312e:	75 ef                	jne    80311f <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  803130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803134:	8b 45 08             	mov    0x8(%ebp),%eax
  803137:	89 04 24             	mov    %eax,(%esp)
  80313a:	e8 6d f9 ff ff       	call   802aac <spawn>
}
  80313f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803142:	5b                   	pop    %ebx
  803143:	5e                   	pop    %esi
  803144:	5d                   	pop    %ebp
  803145:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  803146:	83 ec 20             	sub    $0x20,%esp
  803149:	8d 44 24 17          	lea    0x17(%esp),%eax
  80314d:	83 e0 f0             	and    $0xfffffff0,%eax
  803150:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  803152:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  803154:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80315b:	eb d3                	jmp    803130 <spawnl+0x64>
  80315d:	00 00                	add    %al,(%eax)
	...

00803160 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803160:	55                   	push   %ebp
  803161:	89 e5                	mov    %esp,%ebp
  803163:	83 ec 18             	sub    $0x18,%esp
  803166:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803169:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80316c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80316f:	8b 45 08             	mov    0x8(%ebp),%eax
  803172:	89 04 24             	mov    %eax,(%esp)
  803175:	e8 b6 ef ff ff       	call   802130 <fd2data>
  80317a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80317c:	c7 44 24 04 01 43 80 	movl   $0x804301,0x4(%esp)
  803183:	00 
  803184:	89 34 24             	mov    %esi,(%esp)
  803187:	e8 2f e2 ff ff       	call   8013bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80318c:	8b 43 04             	mov    0x4(%ebx),%eax
  80318f:	2b 03                	sub    (%ebx),%eax
  803191:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  803197:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80319e:	00 00 00 
	stat->st_dev = &devpipe;
  8031a1:	c7 86 88 00 00 00 40 	movl   $0x805040,0x88(%esi)
  8031a8:	50 80 00 
	return 0;
}
  8031ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8031b0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8031b3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8031b6:	89 ec                	mov    %ebp,%esp
  8031b8:	5d                   	pop    %ebp
  8031b9:	c3                   	ret    

008031ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8031ba:	55                   	push   %ebp
  8031bb:	89 e5                	mov    %esp,%ebp
  8031bd:	53                   	push   %ebx
  8031be:	83 ec 14             	sub    $0x14,%esp
  8031c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8031c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8031c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031cf:	e8 a5 e7 ff ff       	call   801979 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8031d4:	89 1c 24             	mov    %ebx,(%esp)
  8031d7:	e8 54 ef ff ff       	call   802130 <fd2data>
  8031dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031e7:	e8 8d e7 ff ff       	call   801979 <sys_page_unmap>
}
  8031ec:	83 c4 14             	add    $0x14,%esp
  8031ef:	5b                   	pop    %ebx
  8031f0:	5d                   	pop    %ebp
  8031f1:	c3                   	ret    

008031f2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8031f2:	55                   	push   %ebp
  8031f3:	89 e5                	mov    %esp,%ebp
  8031f5:	57                   	push   %edi
  8031f6:	56                   	push   %esi
  8031f7:	53                   	push   %ebx
  8031f8:	83 ec 2c             	sub    $0x2c,%esp
  8031fb:	89 c7                	mov    %eax,%edi
  8031fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803200:	a1 24 64 80 00       	mov    0x806424,%eax
  803205:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803208:	89 3c 24             	mov    %edi,(%esp)
  80320b:	e8 5c 05 00 00       	call   80376c <pageref>
  803210:	89 c6                	mov    %eax,%esi
  803212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803215:	89 04 24             	mov    %eax,(%esp)
  803218:	e8 4f 05 00 00       	call   80376c <pageref>
  80321d:	39 c6                	cmp    %eax,%esi
  80321f:	0f 94 c0             	sete   %al
  803222:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  803225:	8b 15 24 64 80 00    	mov    0x806424,%edx
  80322b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80322e:	39 cb                	cmp    %ecx,%ebx
  803230:	75 08                	jne    80323a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  803232:	83 c4 2c             	add    $0x2c,%esp
  803235:	5b                   	pop    %ebx
  803236:	5e                   	pop    %esi
  803237:	5f                   	pop    %edi
  803238:	5d                   	pop    %ebp
  803239:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80323a:	83 f8 01             	cmp    $0x1,%eax
  80323d:	75 c1                	jne    803200 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80323f:	8b 52 58             	mov    0x58(%edx),%edx
  803242:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803246:	89 54 24 08          	mov    %edx,0x8(%esp)
  80324a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80324e:	c7 04 24 08 43 80 00 	movl   $0x804308,(%esp)
  803255:	e8 1d d9 ff ff       	call   800b77 <cprintf>
  80325a:	eb a4                	jmp    803200 <_pipeisclosed+0xe>

0080325c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80325c:	55                   	push   %ebp
  80325d:	89 e5                	mov    %esp,%ebp
  80325f:	57                   	push   %edi
  803260:	56                   	push   %esi
  803261:	53                   	push   %ebx
  803262:	83 ec 2c             	sub    $0x2c,%esp
  803265:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803268:	89 34 24             	mov    %esi,(%esp)
  80326b:	e8 c0 ee ff ff       	call   802130 <fd2data>
  803270:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803272:	bf 00 00 00 00       	mov    $0x0,%edi
  803277:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80327b:	75 50                	jne    8032cd <devpipe_write+0x71>
  80327d:	eb 5c                	jmp    8032db <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80327f:	89 da                	mov    %ebx,%edx
  803281:	89 f0                	mov    %esi,%eax
  803283:	e8 6a ff ff ff       	call   8031f2 <_pipeisclosed>
  803288:	85 c0                	test   %eax,%eax
  80328a:	75 53                	jne    8032df <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80328c:	e8 fb e5 ff ff       	call   80188c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803291:	8b 43 04             	mov    0x4(%ebx),%eax
  803294:	8b 13                	mov    (%ebx),%edx
  803296:	83 c2 20             	add    $0x20,%edx
  803299:	39 d0                	cmp    %edx,%eax
  80329b:	73 e2                	jae    80327f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80329d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032a0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8032a4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8032a7:	89 c2                	mov    %eax,%edx
  8032a9:	c1 fa 1f             	sar    $0x1f,%edx
  8032ac:	c1 ea 1b             	shr    $0x1b,%edx
  8032af:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8032b2:	83 e1 1f             	and    $0x1f,%ecx
  8032b5:	29 d1                	sub    %edx,%ecx
  8032b7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8032bb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8032bf:	83 c0 01             	add    $0x1,%eax
  8032c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032c5:	83 c7 01             	add    $0x1,%edi
  8032c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8032cb:	74 0e                	je     8032db <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8032cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8032d0:	8b 13                	mov    (%ebx),%edx
  8032d2:	83 c2 20             	add    $0x20,%edx
  8032d5:	39 d0                	cmp    %edx,%eax
  8032d7:	73 a6                	jae    80327f <devpipe_write+0x23>
  8032d9:	eb c2                	jmp    80329d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8032db:	89 f8                	mov    %edi,%eax
  8032dd:	eb 05                	jmp    8032e4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8032df:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8032e4:	83 c4 2c             	add    $0x2c,%esp
  8032e7:	5b                   	pop    %ebx
  8032e8:	5e                   	pop    %esi
  8032e9:	5f                   	pop    %edi
  8032ea:	5d                   	pop    %ebp
  8032eb:	c3                   	ret    

008032ec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8032ec:	55                   	push   %ebp
  8032ed:	89 e5                	mov    %esp,%ebp
  8032ef:	83 ec 28             	sub    $0x28,%esp
  8032f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8032f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8032f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8032fb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8032fe:	89 3c 24             	mov    %edi,(%esp)
  803301:	e8 2a ee ff ff       	call   802130 <fd2data>
  803306:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803308:	be 00 00 00 00       	mov    $0x0,%esi
  80330d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803311:	75 47                	jne    80335a <devpipe_read+0x6e>
  803313:	eb 52                	jmp    803367 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  803315:	89 f0                	mov    %esi,%eax
  803317:	eb 5e                	jmp    803377 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803319:	89 da                	mov    %ebx,%edx
  80331b:	89 f8                	mov    %edi,%eax
  80331d:	8d 76 00             	lea    0x0(%esi),%esi
  803320:	e8 cd fe ff ff       	call   8031f2 <_pipeisclosed>
  803325:	85 c0                	test   %eax,%eax
  803327:	75 49                	jne    803372 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  803329:	e8 5e e5 ff ff       	call   80188c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80332e:	8b 03                	mov    (%ebx),%eax
  803330:	3b 43 04             	cmp    0x4(%ebx),%eax
  803333:	74 e4                	je     803319 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803335:	89 c2                	mov    %eax,%edx
  803337:	c1 fa 1f             	sar    $0x1f,%edx
  80333a:	c1 ea 1b             	shr    $0x1b,%edx
  80333d:	01 d0                	add    %edx,%eax
  80333f:	83 e0 1f             	and    $0x1f,%eax
  803342:	29 d0                	sub    %edx,%eax
  803344:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803349:	8b 55 0c             	mov    0xc(%ebp),%edx
  80334c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80334f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803352:	83 c6 01             	add    $0x1,%esi
  803355:	3b 75 10             	cmp    0x10(%ebp),%esi
  803358:	74 0d                	je     803367 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80335a:	8b 03                	mov    (%ebx),%eax
  80335c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80335f:	75 d4                	jne    803335 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803361:	85 f6                	test   %esi,%esi
  803363:	75 b0                	jne    803315 <devpipe_read+0x29>
  803365:	eb b2                	jmp    803319 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803367:	89 f0                	mov    %esi,%eax
  803369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803370:	eb 05                	jmp    803377 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803372:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803377:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80337a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80337d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  803380:	89 ec                	mov    %ebp,%esp
  803382:	5d                   	pop    %ebp
  803383:	c3                   	ret    

00803384 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803384:	55                   	push   %ebp
  803385:	89 e5                	mov    %esp,%ebp
  803387:	83 ec 48             	sub    $0x48,%esp
  80338a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80338d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  803390:	89 7d fc             	mov    %edi,-0x4(%ebp)
  803393:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803396:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803399:	89 04 24             	mov    %eax,(%esp)
  80339c:	e8 aa ed ff ff       	call   80214b <fd_alloc>
  8033a1:	89 c3                	mov    %eax,%ebx
  8033a3:	85 c0                	test   %eax,%eax
  8033a5:	0f 88 45 01 00 00    	js     8034f0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8033b2:	00 
  8033b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8033c1:	e8 f6 e4 ff ff       	call   8018bc <sys_page_alloc>
  8033c6:	89 c3                	mov    %eax,%ebx
  8033c8:	85 c0                	test   %eax,%eax
  8033ca:	0f 88 20 01 00 00    	js     8034f0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8033d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8033d3:	89 04 24             	mov    %eax,(%esp)
  8033d6:	e8 70 ed ff ff       	call   80214b <fd_alloc>
  8033db:	89 c3                	mov    %eax,%ebx
  8033dd:	85 c0                	test   %eax,%eax
  8033df:	0f 88 f8 00 00 00    	js     8034dd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8033ec:	00 
  8033ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8033f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8033fb:	e8 bc e4 ff ff       	call   8018bc <sys_page_alloc>
  803400:	89 c3                	mov    %eax,%ebx
  803402:	85 c0                	test   %eax,%eax
  803404:	0f 88 d3 00 00 00    	js     8034dd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80340a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80340d:	89 04 24             	mov    %eax,(%esp)
  803410:	e8 1b ed ff ff       	call   802130 <fd2data>
  803415:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803417:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80341e:	00 
  80341f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80342a:	e8 8d e4 ff ff       	call   8018bc <sys_page_alloc>
  80342f:	89 c3                	mov    %eax,%ebx
  803431:	85 c0                	test   %eax,%eax
  803433:	0f 88 91 00 00 00    	js     8034ca <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803439:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80343c:	89 04 24             	mov    %eax,(%esp)
  80343f:	e8 ec ec ff ff       	call   802130 <fd2data>
  803444:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80344b:	00 
  80344c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803450:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803457:	00 
  803458:	89 74 24 04          	mov    %esi,0x4(%esp)
  80345c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803463:	e8 b3 e4 ff ff       	call   80191b <sys_page_map>
  803468:	89 c3                	mov    %eax,%ebx
  80346a:	85 c0                	test   %eax,%eax
  80346c:	78 4c                	js     8034ba <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80346e:	8b 15 40 50 80 00    	mov    0x805040,%edx
  803474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803477:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80347c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803483:	8b 15 40 50 80 00    	mov    0x805040,%edx
  803489:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80348c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80348e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803491:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80349b:	89 04 24             	mov    %eax,(%esp)
  80349e:	e8 7d ec ff ff       	call   802120 <fd2num>
  8034a3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8034a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8034a8:	89 04 24             	mov    %eax,(%esp)
  8034ab:	e8 70 ec ff ff       	call   802120 <fd2num>
  8034b0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8034b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8034b8:	eb 36                	jmp    8034f0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8034ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8034be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034c5:	e8 af e4 ff ff       	call   801979 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8034ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8034cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034d8:	e8 9c e4 ff ff       	call   801979 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8034dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034eb:	e8 89 e4 ff ff       	call   801979 <sys_page_unmap>
    err:
	return r;
}
  8034f0:	89 d8                	mov    %ebx,%eax
  8034f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8034f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8034f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8034fb:	89 ec                	mov    %ebp,%esp
  8034fd:	5d                   	pop    %ebp
  8034fe:	c3                   	ret    

008034ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8034ff:	55                   	push   %ebp
  803500:	89 e5                	mov    %esp,%ebp
  803502:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80350c:	8b 45 08             	mov    0x8(%ebp),%eax
  80350f:	89 04 24             	mov    %eax,(%esp)
  803512:	e8 a7 ec ff ff       	call   8021be <fd_lookup>
  803517:	85 c0                	test   %eax,%eax
  803519:	78 15                	js     803530 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80351b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80351e:	89 04 24             	mov    %eax,(%esp)
  803521:	e8 0a ec ff ff       	call   802130 <fd2data>
	return _pipeisclosed(fd, p);
  803526:	89 c2                	mov    %eax,%edx
  803528:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80352b:	e8 c2 fc ff ff       	call   8031f2 <_pipeisclosed>
}
  803530:	c9                   	leave  
  803531:	c3                   	ret    
	...

00803534 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803534:	55                   	push   %ebp
  803535:	89 e5                	mov    %esp,%ebp
  803537:	56                   	push   %esi
  803538:	53                   	push   %ebx
  803539:	83 ec 10             	sub    $0x10,%esp
  80353c:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  80353f:	85 c0                	test   %eax,%eax
  803541:	75 24                	jne    803567 <wait+0x33>
  803543:	c7 44 24 0c 20 43 80 	movl   $0x804320,0xc(%esp)
  80354a:	00 
  80354b:	c7 44 24 08 b2 3b 80 	movl   $0x803bb2,0x8(%esp)
  803552:	00 
  803553:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80355a:	00 
  80355b:	c7 04 24 2b 43 80 00 	movl   $0x80432b,(%esp)
  803562:	e8 15 d5 ff ff       	call   800a7c <_panic>
	e = &envs[ENVX(envid)];
  803567:	89 c3                	mov    %eax,%ebx
  803569:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80356f:	c1 e3 07             	shl    $0x7,%ebx
  803572:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803578:	8b 73 48             	mov    0x48(%ebx),%esi
  80357b:	39 c6                	cmp    %eax,%esi
  80357d:	75 1a                	jne    803599 <wait+0x65>
  80357f:	8b 43 54             	mov    0x54(%ebx),%eax
  803582:	85 c0                	test   %eax,%eax
  803584:	74 13                	je     803599 <wait+0x65>
		sys_yield();
  803586:	e8 01 e3 ff ff       	call   80188c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80358b:	8b 43 48             	mov    0x48(%ebx),%eax
  80358e:	39 f0                	cmp    %esi,%eax
  803590:	75 07                	jne    803599 <wait+0x65>
  803592:	8b 43 54             	mov    0x54(%ebx),%eax
  803595:	85 c0                	test   %eax,%eax
  803597:	75 ed                	jne    803586 <wait+0x52>
		sys_yield();
}
  803599:	83 c4 10             	add    $0x10,%esp
  80359c:	5b                   	pop    %ebx
  80359d:	5e                   	pop    %esi
  80359e:	5d                   	pop    %ebp
  80359f:	c3                   	ret    

008035a0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8035a0:	55                   	push   %ebp
  8035a1:	89 e5                	mov    %esp,%ebp
  8035a3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8035a6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8035ad:	75 3c                	jne    8035eb <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8035af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8035b6:	00 
  8035b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8035be:	ee 
  8035bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035c6:	e8 f1 e2 ff ff       	call   8018bc <sys_page_alloc>
  8035cb:	85 c0                	test   %eax,%eax
  8035cd:	79 1c                	jns    8035eb <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8035cf:	c7 44 24 08 38 43 80 	movl   $0x804338,0x8(%esp)
  8035d6:	00 
  8035d7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8035de:	00 
  8035df:	c7 04 24 9c 43 80 00 	movl   $0x80439c,(%esp)
  8035e6:	e8 91 d4 ff ff       	call   800a7c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8035eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8035ee:	a3 00 80 80 00       	mov    %eax,0x808000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8035f3:	c7 44 24 04 2c 36 80 	movl   $0x80362c,0x4(%esp)
  8035fa:	00 
  8035fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803602:	e8 8c e4 ff ff       	call   801a93 <sys_env_set_pgfault_upcall>
  803607:	85 c0                	test   %eax,%eax
  803609:	79 1c                	jns    803627 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80360b:	c7 44 24 08 64 43 80 	movl   $0x804364,0x8(%esp)
  803612:	00 
  803613:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80361a:	00 
  80361b:	c7 04 24 9c 43 80 00 	movl   $0x80439c,(%esp)
  803622:	e8 55 d4 ff ff       	call   800a7c <_panic>
}
  803627:	c9                   	leave  
  803628:	c3                   	ret    
  803629:	00 00                	add    %al,(%eax)
	...

0080362c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80362c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80362d:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  803632:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803634:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  803637:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  80363b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  803640:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  803644:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  803646:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  803649:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  80364a:	83 c4 04             	add    $0x4,%esp
    popfl
  80364d:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  80364e:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  80364f:	c3                   	ret    

00803650 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803650:	55                   	push   %ebp
  803651:	89 e5                	mov    %esp,%ebp
  803653:	56                   	push   %esi
  803654:	53                   	push   %ebx
  803655:	83 ec 10             	sub    $0x10,%esp
  803658:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80365b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80365e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  803661:	85 db                	test   %ebx,%ebx
  803663:	74 06                	je     80366b <ipc_recv+0x1b>
  803665:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80366b:	85 f6                	test   %esi,%esi
  80366d:	74 06                	je     803675 <ipc_recv+0x25>
  80366f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  803675:	85 c0                	test   %eax,%eax
  803677:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80367c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80367f:	89 04 24             	mov    %eax,(%esp)
  803682:	e8 9e e4 ff ff       	call   801b25 <sys_ipc_recv>
    if (ret) return ret;
  803687:	85 c0                	test   %eax,%eax
  803689:	75 24                	jne    8036af <ipc_recv+0x5f>
    if (from_env_store)
  80368b:	85 db                	test   %ebx,%ebx
  80368d:	74 0a                	je     803699 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80368f:	a1 24 64 80 00       	mov    0x806424,%eax
  803694:	8b 40 74             	mov    0x74(%eax),%eax
  803697:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  803699:	85 f6                	test   %esi,%esi
  80369b:	74 0a                	je     8036a7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80369d:	a1 24 64 80 00       	mov    0x806424,%eax
  8036a2:	8b 40 78             	mov    0x78(%eax),%eax
  8036a5:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8036a7:	a1 24 64 80 00       	mov    0x806424,%eax
  8036ac:	8b 40 70             	mov    0x70(%eax),%eax
}
  8036af:	83 c4 10             	add    $0x10,%esp
  8036b2:	5b                   	pop    %ebx
  8036b3:	5e                   	pop    %esi
  8036b4:	5d                   	pop    %ebp
  8036b5:	c3                   	ret    

008036b6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8036b6:	55                   	push   %ebp
  8036b7:	89 e5                	mov    %esp,%ebp
  8036b9:	57                   	push   %edi
  8036ba:	56                   	push   %esi
  8036bb:	53                   	push   %ebx
  8036bc:	83 ec 1c             	sub    $0x1c,%esp
  8036bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8036c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8036c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8036c8:	85 db                	test   %ebx,%ebx
  8036ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8036cf:	0f 44 d8             	cmove  %eax,%ebx
  8036d2:	eb 2a                	jmp    8036fe <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8036d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8036d7:	74 20                	je     8036f9 <ipc_send+0x43>
  8036d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8036dd:	c7 44 24 08 aa 43 80 	movl   $0x8043aa,0x8(%esp)
  8036e4:	00 
  8036e5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8036ec:	00 
  8036ed:	c7 04 24 c1 43 80 00 	movl   $0x8043c1,(%esp)
  8036f4:	e8 83 d3 ff ff       	call   800a7c <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  8036f9:	e8 8e e1 ff ff       	call   80188c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8036fe:	8b 45 14             	mov    0x14(%ebp),%eax
  803701:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803705:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803709:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80370d:	89 34 24             	mov    %esi,(%esp)
  803710:	e8 dc e3 ff ff       	call   801af1 <sys_ipc_try_send>
  803715:	85 c0                	test   %eax,%eax
  803717:	75 bb                	jne    8036d4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  803719:	83 c4 1c             	add    $0x1c,%esp
  80371c:	5b                   	pop    %ebx
  80371d:	5e                   	pop    %esi
  80371e:	5f                   	pop    %edi
  80371f:	5d                   	pop    %ebp
  803720:	c3                   	ret    

00803721 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803721:	55                   	push   %ebp
  803722:	89 e5                	mov    %esp,%ebp
  803724:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  803727:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80372c:	39 c8                	cmp    %ecx,%eax
  80372e:	74 19                	je     803749 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803730:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  803735:	89 c2                	mov    %eax,%edx
  803737:	c1 e2 07             	shl    $0x7,%edx
  80373a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803740:	8b 52 50             	mov    0x50(%edx),%edx
  803743:	39 ca                	cmp    %ecx,%edx
  803745:	75 14                	jne    80375b <ipc_find_env+0x3a>
  803747:	eb 05                	jmp    80374e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803749:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80374e:	c1 e0 07             	shl    $0x7,%eax
  803751:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803756:	8b 40 40             	mov    0x40(%eax),%eax
  803759:	eb 0e                	jmp    803769 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80375b:	83 c0 01             	add    $0x1,%eax
  80375e:	3d 00 04 00 00       	cmp    $0x400,%eax
  803763:	75 d0                	jne    803735 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803765:	66 b8 00 00          	mov    $0x0,%ax
}
  803769:	5d                   	pop    %ebp
  80376a:	c3                   	ret    
	...

0080376c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80376c:	55                   	push   %ebp
  80376d:	89 e5                	mov    %esp,%ebp
  80376f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803772:	89 d0                	mov    %edx,%eax
  803774:	c1 e8 16             	shr    $0x16,%eax
  803777:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80377e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803783:	f6 c1 01             	test   $0x1,%cl
  803786:	74 1d                	je     8037a5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803788:	c1 ea 0c             	shr    $0xc,%edx
  80378b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803792:	f6 c2 01             	test   $0x1,%dl
  803795:	74 0e                	je     8037a5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803797:	c1 ea 0c             	shr    $0xc,%edx
  80379a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8037a1:	ef 
  8037a2:	0f b7 c0             	movzwl %ax,%eax
}
  8037a5:	5d                   	pop    %ebp
  8037a6:	c3                   	ret    
	...

008037b0 <__udivdi3>:
  8037b0:	83 ec 1c             	sub    $0x1c,%esp
  8037b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8037b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8037bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8037bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8037c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8037c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8037cb:	85 ff                	test   %edi,%edi
  8037cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8037d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8037d5:	89 cd                	mov    %ecx,%ebp
  8037d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037db:	75 33                	jne    803810 <__udivdi3+0x60>
  8037dd:	39 f1                	cmp    %esi,%ecx
  8037df:	77 57                	ja     803838 <__udivdi3+0x88>
  8037e1:	85 c9                	test   %ecx,%ecx
  8037e3:	75 0b                	jne    8037f0 <__udivdi3+0x40>
  8037e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8037ea:	31 d2                	xor    %edx,%edx
  8037ec:	f7 f1                	div    %ecx
  8037ee:	89 c1                	mov    %eax,%ecx
  8037f0:	89 f0                	mov    %esi,%eax
  8037f2:	31 d2                	xor    %edx,%edx
  8037f4:	f7 f1                	div    %ecx
  8037f6:	89 c6                	mov    %eax,%esi
  8037f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8037fc:	f7 f1                	div    %ecx
  8037fe:	89 f2                	mov    %esi,%edx
  803800:	8b 74 24 10          	mov    0x10(%esp),%esi
  803804:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803808:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80380c:	83 c4 1c             	add    $0x1c,%esp
  80380f:	c3                   	ret    
  803810:	31 d2                	xor    %edx,%edx
  803812:	31 c0                	xor    %eax,%eax
  803814:	39 f7                	cmp    %esi,%edi
  803816:	77 e8                	ja     803800 <__udivdi3+0x50>
  803818:	0f bd cf             	bsr    %edi,%ecx
  80381b:	83 f1 1f             	xor    $0x1f,%ecx
  80381e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803822:	75 2c                	jne    803850 <__udivdi3+0xa0>
  803824:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  803828:	76 04                	jbe    80382e <__udivdi3+0x7e>
  80382a:	39 f7                	cmp    %esi,%edi
  80382c:	73 d2                	jae    803800 <__udivdi3+0x50>
  80382e:	31 d2                	xor    %edx,%edx
  803830:	b8 01 00 00 00       	mov    $0x1,%eax
  803835:	eb c9                	jmp    803800 <__udivdi3+0x50>
  803837:	90                   	nop
  803838:	89 f2                	mov    %esi,%edx
  80383a:	f7 f1                	div    %ecx
  80383c:	31 d2                	xor    %edx,%edx
  80383e:	8b 74 24 10          	mov    0x10(%esp),%esi
  803842:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803846:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80384a:	83 c4 1c             	add    $0x1c,%esp
  80384d:	c3                   	ret    
  80384e:	66 90                	xchg   %ax,%ax
  803850:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803855:	b8 20 00 00 00       	mov    $0x20,%eax
  80385a:	89 ea                	mov    %ebp,%edx
  80385c:	2b 44 24 04          	sub    0x4(%esp),%eax
  803860:	d3 e7                	shl    %cl,%edi
  803862:	89 c1                	mov    %eax,%ecx
  803864:	d3 ea                	shr    %cl,%edx
  803866:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80386b:	09 fa                	or     %edi,%edx
  80386d:	89 f7                	mov    %esi,%edi
  80386f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803873:	89 f2                	mov    %esi,%edx
  803875:	8b 74 24 08          	mov    0x8(%esp),%esi
  803879:	d3 e5                	shl    %cl,%ebp
  80387b:	89 c1                	mov    %eax,%ecx
  80387d:	d3 ef                	shr    %cl,%edi
  80387f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803884:	d3 e2                	shl    %cl,%edx
  803886:	89 c1                	mov    %eax,%ecx
  803888:	d3 ee                	shr    %cl,%esi
  80388a:	09 d6                	or     %edx,%esi
  80388c:	89 fa                	mov    %edi,%edx
  80388e:	89 f0                	mov    %esi,%eax
  803890:	f7 74 24 0c          	divl   0xc(%esp)
  803894:	89 d7                	mov    %edx,%edi
  803896:	89 c6                	mov    %eax,%esi
  803898:	f7 e5                	mul    %ebp
  80389a:	39 d7                	cmp    %edx,%edi
  80389c:	72 22                	jb     8038c0 <__udivdi3+0x110>
  80389e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8038a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8038a7:	d3 e5                	shl    %cl,%ebp
  8038a9:	39 c5                	cmp    %eax,%ebp
  8038ab:	73 04                	jae    8038b1 <__udivdi3+0x101>
  8038ad:	39 d7                	cmp    %edx,%edi
  8038af:	74 0f                	je     8038c0 <__udivdi3+0x110>
  8038b1:	89 f0                	mov    %esi,%eax
  8038b3:	31 d2                	xor    %edx,%edx
  8038b5:	e9 46 ff ff ff       	jmp    803800 <__udivdi3+0x50>
  8038ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8038c0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8038c3:	31 d2                	xor    %edx,%edx
  8038c5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8038c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8038cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8038d1:	83 c4 1c             	add    $0x1c,%esp
  8038d4:	c3                   	ret    
	...

008038e0 <__umoddi3>:
  8038e0:	83 ec 1c             	sub    $0x1c,%esp
  8038e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8038e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8038eb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8038ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8038f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8038f7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8038fb:	85 ed                	test   %ebp,%ebp
  8038fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  803901:	89 44 24 08          	mov    %eax,0x8(%esp)
  803905:	89 cf                	mov    %ecx,%edi
  803907:	89 04 24             	mov    %eax,(%esp)
  80390a:	89 f2                	mov    %esi,%edx
  80390c:	75 1a                	jne    803928 <__umoddi3+0x48>
  80390e:	39 f1                	cmp    %esi,%ecx
  803910:	76 4e                	jbe    803960 <__umoddi3+0x80>
  803912:	f7 f1                	div    %ecx
  803914:	89 d0                	mov    %edx,%eax
  803916:	31 d2                	xor    %edx,%edx
  803918:	8b 74 24 10          	mov    0x10(%esp),%esi
  80391c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803920:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  803924:	83 c4 1c             	add    $0x1c,%esp
  803927:	c3                   	ret    
  803928:	39 f5                	cmp    %esi,%ebp
  80392a:	77 54                	ja     803980 <__umoddi3+0xa0>
  80392c:	0f bd c5             	bsr    %ebp,%eax
  80392f:	83 f0 1f             	xor    $0x1f,%eax
  803932:	89 44 24 04          	mov    %eax,0x4(%esp)
  803936:	75 60                	jne    803998 <__umoddi3+0xb8>
  803938:	3b 0c 24             	cmp    (%esp),%ecx
  80393b:	0f 87 07 01 00 00    	ja     803a48 <__umoddi3+0x168>
  803941:	89 f2                	mov    %esi,%edx
  803943:	8b 34 24             	mov    (%esp),%esi
  803946:	29 ce                	sub    %ecx,%esi
  803948:	19 ea                	sbb    %ebp,%edx
  80394a:	89 34 24             	mov    %esi,(%esp)
  80394d:	8b 04 24             	mov    (%esp),%eax
  803950:	8b 74 24 10          	mov    0x10(%esp),%esi
  803954:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803958:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80395c:	83 c4 1c             	add    $0x1c,%esp
  80395f:	c3                   	ret    
  803960:	85 c9                	test   %ecx,%ecx
  803962:	75 0b                	jne    80396f <__umoddi3+0x8f>
  803964:	b8 01 00 00 00       	mov    $0x1,%eax
  803969:	31 d2                	xor    %edx,%edx
  80396b:	f7 f1                	div    %ecx
  80396d:	89 c1                	mov    %eax,%ecx
  80396f:	89 f0                	mov    %esi,%eax
  803971:	31 d2                	xor    %edx,%edx
  803973:	f7 f1                	div    %ecx
  803975:	8b 04 24             	mov    (%esp),%eax
  803978:	f7 f1                	div    %ecx
  80397a:	eb 98                	jmp    803914 <__umoddi3+0x34>
  80397c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803980:	89 f2                	mov    %esi,%edx
  803982:	8b 74 24 10          	mov    0x10(%esp),%esi
  803986:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80398a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80398e:	83 c4 1c             	add    $0x1c,%esp
  803991:	c3                   	ret    
  803992:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803998:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80399d:	89 e8                	mov    %ebp,%eax
  80399f:	bd 20 00 00 00       	mov    $0x20,%ebp
  8039a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8039a8:	89 fa                	mov    %edi,%edx
  8039aa:	d3 e0                	shl    %cl,%eax
  8039ac:	89 e9                	mov    %ebp,%ecx
  8039ae:	d3 ea                	shr    %cl,%edx
  8039b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8039b5:	09 c2                	or     %eax,%edx
  8039b7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8039bb:	89 14 24             	mov    %edx,(%esp)
  8039be:	89 f2                	mov    %esi,%edx
  8039c0:	d3 e7                	shl    %cl,%edi
  8039c2:	89 e9                	mov    %ebp,%ecx
  8039c4:	d3 ea                	shr    %cl,%edx
  8039c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8039cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8039cf:	d3 e6                	shl    %cl,%esi
  8039d1:	89 e9                	mov    %ebp,%ecx
  8039d3:	d3 e8                	shr    %cl,%eax
  8039d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8039da:	09 f0                	or     %esi,%eax
  8039dc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8039e0:	f7 34 24             	divl   (%esp)
  8039e3:	d3 e6                	shl    %cl,%esi
  8039e5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8039e9:	89 d6                	mov    %edx,%esi
  8039eb:	f7 e7                	mul    %edi
  8039ed:	39 d6                	cmp    %edx,%esi
  8039ef:	89 c1                	mov    %eax,%ecx
  8039f1:	89 d7                	mov    %edx,%edi
  8039f3:	72 3f                	jb     803a34 <__umoddi3+0x154>
  8039f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8039f9:	72 35                	jb     803a30 <__umoddi3+0x150>
  8039fb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8039ff:	29 c8                	sub    %ecx,%eax
  803a01:	19 fe                	sbb    %edi,%esi
  803a03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803a08:	89 f2                	mov    %esi,%edx
  803a0a:	d3 e8                	shr    %cl,%eax
  803a0c:	89 e9                	mov    %ebp,%ecx
  803a0e:	d3 e2                	shl    %cl,%edx
  803a10:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803a15:	09 d0                	or     %edx,%eax
  803a17:	89 f2                	mov    %esi,%edx
  803a19:	d3 ea                	shr    %cl,%edx
  803a1b:	8b 74 24 10          	mov    0x10(%esp),%esi
  803a1f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  803a23:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  803a27:	83 c4 1c             	add    $0x1c,%esp
  803a2a:	c3                   	ret    
  803a2b:	90                   	nop
  803a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a30:	39 d6                	cmp    %edx,%esi
  803a32:	75 c7                	jne    8039fb <__umoddi3+0x11b>
  803a34:	89 d7                	mov    %edx,%edi
  803a36:	89 c1                	mov    %eax,%ecx
  803a38:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  803a3c:	1b 3c 24             	sbb    (%esp),%edi
  803a3f:	eb ba                	jmp    8039fb <__umoddi3+0x11b>
  803a41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a48:	39 f5                	cmp    %esi,%ebp
  803a4a:	0f 82 f1 fe ff ff    	jb     803941 <__umoddi3+0x61>
  803a50:	e9 f8 fe ff ff       	jmp    80394d <__umoddi3+0x6d>
