
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 0b 03 00 00       	call   80033c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004b:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80004f:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800056:	74 23                	je     80007b <ls1+0x3b>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800058:	89 f0                	mov    %esi,%eax
  80005a:	3c 01                	cmp    $0x1,%al
  80005c:	19 c0                	sbb    %eax,%eax
  80005e:	83 e0 c9             	and    $0xffffffc9,%eax
  800061:	83 c0 64             	add    $0x64,%eax
  800064:	89 44 24 08          	mov    %eax,0x8(%esp)
  800068:	8b 45 10             	mov    0x10(%ebp),%eax
  80006b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006f:	c7 04 24 82 28 80 00 	movl   $0x802882,(%esp)
  800076:	e8 2e 1e 00 00       	call   801ea9 <printf>
	if(prefix) {
  80007b:	85 db                	test   %ebx,%ebx
  80007d:	74 38                	je     8000b7 <ls1+0x77>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80007f:	b8 e8 28 80 00       	mov    $0x8028e8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800084:	80 3b 00             	cmpb   $0x0,(%ebx)
  800087:	74 1a                	je     8000a3 <ls1+0x63>
  800089:	89 1c 24             	mov    %ebx,(%esp)
  80008c:	e8 0f 0b 00 00       	call   800ba0 <strlen>
			sep = "/";
  800091:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800096:	b8 80 28 80 00       	mov    $0x802880,%eax
  80009b:	ba e8 28 80 00       	mov    $0x8028e8,%edx
  8000a0:	0f 44 c2             	cmove  %edx,%eax
		else
			sep = "";
		printf("%s%s", prefix, sep);
  8000a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ab:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  8000b2:	e8 f2 1d 00 00       	call   801ea9 <printf>
	}
	printf("%s", name);
  8000b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8000ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000be:	c7 04 24 35 2d 80 00 	movl   $0x802d35,(%esp)
  8000c5:	e8 df 1d 00 00       	call   801ea9 <printf>
	if(flag['F'] && isdir)
  8000ca:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000d1:	74 12                	je     8000e5 <ls1+0xa5>
  8000d3:	89 f0                	mov    %esi,%eax
  8000d5:	84 c0                	test   %al,%al
  8000d7:	74 0c                	je     8000e5 <ls1+0xa5>
		printf("/");
  8000d9:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  8000e0:	e8 c4 1d 00 00       	call   801ea9 <printf>
	printf("\n");
  8000e5:	c7 04 24 e7 28 80 00 	movl   $0x8028e7,(%esp)
  8000ec:	e8 b8 1d 00 00       	call   801ea9 <printf>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  800104:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  800107:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010e:	00 
  80010f:	8b 45 08             	mov    0x8(%ebp),%eax
  800112:	89 04 24             	mov    %eax,(%esp)
  800115:	e8 f2 1b 00 00       	call   801d0c <open>
  80011a:	89 c6                	mov    %eax,%esi
  80011c:	85 c0                	test   %eax,%eax
  80011e:	79 59                	jns    800179 <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800120:	89 44 24 10          	mov    %eax,0x10(%esp)
  800124:	8b 45 08             	mov    0x8(%ebp),%eax
  800127:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012b:	c7 44 24 08 90 28 80 	movl   $0x802890,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800142:	e8 61 02 00 00       	call   8003a8 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800147:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80014e:	74 2f                	je     80017f <lsdir+0x87>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800150:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800154:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80015a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015e:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800165:	0f 94 c0             	sete   %al
  800168:	0f b6 c0             	movzbl %al,%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	89 3c 24             	mov    %edi,(%esp)
  800172:	e8 c9 fe ff ff       	call   800040 <ls1>
  800177:	eb 06                	jmp    80017f <lsdir+0x87>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  800179:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  80017f:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  800186:	00 
  800187:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018b:	89 34 24             	mov    %esi,(%esp)
  80018e:	e8 9b 17 00 00       	call   80192e <readn>
  800193:	3d 00 01 00 00       	cmp    $0x100,%eax
  800198:	74 ad                	je     800147 <lsdir+0x4f>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80019a:	85 c0                	test   %eax,%eax
  80019c:	7e 23                	jle    8001c1 <lsdir+0xc9>
		panic("short read in directory %s", path);
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a5:	c7 44 24 08 a6 28 80 	movl   $0x8028a6,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  8001bc:	e8 e7 01 00 00       	call   8003a8 <_panic>
	if (n < 0)
  8001c1:	85 c0                	test   %eax,%eax
  8001c3:	79 27                	jns    8001ec <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d0:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001df:	00 
  8001e0:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  8001e7:	e8 bc 01 00 00       	call   8003a8 <_panic>
}
  8001ec:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	53                   	push   %ebx
  8001fb:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  800201:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  800204:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	89 1c 24             	mov    %ebx,(%esp)
  800211:	e8 1b 19 00 00       	call   801b31 <stat>
  800216:	85 c0                	test   %eax,%eax
  800218:	79 24                	jns    80023e <ls+0x47>
		panic("stat %s: %e", path, r);
  80021a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800222:	c7 44 24 08 c1 28 80 	movl   $0x8028c1,0x8(%esp)
  800229:	00 
  80022a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800231:	00 
  800232:	c7 04 24 9c 28 80 00 	movl   $0x80289c,(%esp)
  800239:	e8 6a 01 00 00       	call   8003a8 <_panic>
	if (st.st_isdir && !flag['d'])
  80023e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800241:	85 c0                	test   %eax,%eax
  800243:	74 1a                	je     80025f <ls+0x68>
  800245:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  80024c:	75 11                	jne    80025f <ls+0x68>
		lsdir(path, prefix);
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	89 1c 24             	mov    %ebx,(%esp)
  800258:	e8 9b fe ff ff       	call   8000f8 <lsdir>
  80025d:	eb 23                	jmp    800282 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  80025f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800263:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800266:	89 54 24 08          	mov    %edx,0x8(%esp)
  80026a:	85 c0                	test   %eax,%eax
  80026c:	0f 95 c0             	setne  %al
  80026f:	0f b6 c0             	movzbl %al,%eax
  800272:	89 44 24 04          	mov    %eax,0x4(%esp)
  800276:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80027d:	e8 be fd ff ff       	call   800040 <ls1>
}
  800282:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  800288:	5b                   	pop    %ebx
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <usage>:
	printf("\n");
}

void
usage(void)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800291:	c7 04 24 cd 28 80 00 	movl   $0x8028cd,(%esp)
  800298:	e8 0c 1c 00 00       	call   801ea9 <printf>
	exit();
  80029d:	e8 ea 00 00 00       	call   80038c <exit>
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <umain>:

void
umain(int argc, char **argv)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 20             	sub    $0x20,%esp
  8002ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002af:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ba:	8d 45 08             	lea    0x8(%ebp),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	e8 1f 11 00 00       	call   8013e4 <argstart>
	while ((i = argnext(&args)) >= 0)
  8002c5:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002c8:	eb 1e                	jmp    8002e8 <umain+0x44>
		switch (i) {
  8002ca:	83 f8 64             	cmp    $0x64,%eax
  8002cd:	74 0a                	je     8002d9 <umain+0x35>
  8002cf:	83 f8 6c             	cmp    $0x6c,%eax
  8002d2:	74 05                	je     8002d9 <umain+0x35>
  8002d4:	83 f8 46             	cmp    $0x46,%eax
  8002d7:	75 0a                	jne    8002e3 <umain+0x3f>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002d9:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  8002e0:	01 
			break;
  8002e1:	eb 05                	jmp    8002e8 <umain+0x44>
		default:
			usage();
  8002e3:	e8 a3 ff ff ff       	call   80028b <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002e8:	89 1c 24             	mov    %ebx,(%esp)
  8002eb:	e8 24 11 00 00       	call   801414 <argnext>
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	79 d6                	jns    8002ca <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	83 f8 01             	cmp    $0x1,%eax
  8002fa:	74 0c                	je     800308 <umain+0x64>
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002fc:	bb 01 00 00 00       	mov    $0x1,%ebx
  800301:	83 f8 01             	cmp    $0x1,%eax
  800304:	7f 18                	jg     80031e <umain+0x7a>
  800306:	eb 2d                	jmp    800335 <umain+0x91>
		default:
			usage();
		}

	if (argc == 1)
		ls("/", "");
  800308:	c7 44 24 04 e8 28 80 	movl   $0x8028e8,0x4(%esp)
  80030f:	00 
  800310:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800317:	e8 db fe ff ff       	call   8001f7 <ls>
  80031c:	eb 17                	jmp    800335 <umain+0x91>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  80031e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	e8 ca fe ff ff       	call   8001f7 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80032d:	83 c3 01             	add    $0x1,%ebx
  800330:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  800333:	7f e9                	jg     80031e <umain+0x7a>
			ls(argv[i], argv[i]);
	}
}
  800335:	83 c4 20             	add    $0x20,%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 18             	sub    $0x18,%esp
  800342:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800345:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80034e:	e8 39 0d 00 00       	call   80108c <sys_getenvid>
  800353:	25 ff 03 00 00       	and    $0x3ff,%eax
  800358:	c1 e0 07             	shl    $0x7,%eax
  80035b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800360:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800365:	85 f6                	test   %esi,%esi
  800367:	7e 07                	jle    800370 <libmain+0x34>
		binaryname = argv[0];
  800369:	8b 03                	mov    (%ebx),%eax
  80036b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800370:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800374:	89 34 24             	mov    %esi,(%esp)
  800377:	e8 28 ff ff ff       	call   8002a4 <umain>

	// exit gracefully
	exit();
  80037c:	e8 0b 00 00 00       	call   80038c <exit>
}
  800381:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800384:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800387:	89 ec                	mov    %ebp,%esp
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    
	...

0080038c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800392:	e8 c7 13 00 00       	call   80175e <close_all>
	sys_env_destroy(0);
  800397:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80039e:	e8 8c 0c 00 00       	call   80102f <sys_env_destroy>
}
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    
  8003a5:	00 00                	add    %al,(%eax)
	...

008003a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003b3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003b9:	e8 ce 0c 00 00       	call   80108c <sys_getenvid>
  8003be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d4:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  8003db:	e8 c3 00 00 00       	call   8004a3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	e8 53 00 00 00       	call   800442 <vcprintf>
	cprintf("\n");
  8003ef:	c7 04 24 e7 28 80 00 	movl   $0x8028e7,(%esp)
  8003f6:	e8 a8 00 00 00       	call   8004a3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003fb:	cc                   	int3   
  8003fc:	eb fd                	jmp    8003fb <_panic+0x53>
	...

00800400 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	53                   	push   %ebx
  800404:	83 ec 14             	sub    $0x14,%esp
  800407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80040a:	8b 03                	mov    (%ebx),%eax
  80040c:	8b 55 08             	mov    0x8(%ebp),%edx
  80040f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800413:	83 c0 01             	add    $0x1,%eax
  800416:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800418:	3d ff 00 00 00       	cmp    $0xff,%eax
  80041d:	75 19                	jne    800438 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80041f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800426:	00 
  800427:	8d 43 08             	lea    0x8(%ebx),%eax
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	e8 9e 0b 00 00       	call   800fd0 <sys_cputs>
		b->idx = 0;
  800432:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800438:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80043c:	83 c4 14             	add    $0x14,%esp
  80043f:	5b                   	pop    %ebx
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80044b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800452:	00 00 00 
	b.cnt = 0;
  800455:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80045c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80045f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	89 44 24 08          	mov    %eax,0x8(%esp)
  80046d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800473:	89 44 24 04          	mov    %eax,0x4(%esp)
  800477:	c7 04 24 00 04 80 00 	movl   $0x800400,(%esp)
  80047e:	e8 97 01 00 00       	call   80061a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800483:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 35 0b 00 00       	call   800fd0 <sys_cputs>

	return b.cnt;
}
  80049b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004a1:	c9                   	leave  
  8004a2:	c3                   	ret    

008004a3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004a3:	55                   	push   %ebp
  8004a4:	89 e5                	mov    %esp,%ebp
  8004a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004a9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b3:	89 04 24             	mov    %eax,(%esp)
  8004b6:	e8 87 ff ff ff       	call   800442 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004bb:	c9                   	leave  
  8004bc:	c3                   	ret    
  8004bd:	00 00                	add    %al,(%eax)
	...

008004c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
  8004c6:	83 ec 3c             	sub    $0x3c,%esp
  8004c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cc:	89 d7                	mov    %edx,%edi
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8004e8:	72 11                	jb     8004fb <printnum+0x3b>
  8004ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ed:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004f0:	76 09                	jbe    8004fb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004f2:	83 eb 01             	sub    $0x1,%ebx
  8004f5:	85 db                	test   %ebx,%ebx
  8004f7:	7f 51                	jg     80054a <printnum+0x8a>
  8004f9:	eb 5e                	jmp    800559 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800506:	8b 45 10             	mov    0x10(%ebp),%eax
  800509:	89 44 24 08          	mov    %eax,0x8(%esp)
  80050d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800511:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800515:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80051c:	00 
  80051d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800520:	89 04 24             	mov    %eax,(%esp)
  800523:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052a:	e8 91 20 00 00       	call   8025c0 <__udivdi3>
  80052f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800533:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80053e:	89 fa                	mov    %edi,%edx
  800540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800543:	e8 78 ff ff ff       	call   8004c0 <printnum>
  800548:	eb 0f                	jmp    800559 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80054a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054e:	89 34 24             	mov    %esi,(%esp)
  800551:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	75 f1                	jne    80054a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800561:	8b 45 10             	mov    0x10(%ebp),%eax
  800564:	89 44 24 08          	mov    %eax,0x8(%esp)
  800568:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80056f:	00 
  800570:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	e8 6e 21 00 00       	call   8026f0 <__umoddi3>
  800582:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800586:	0f be 80 3b 29 80 00 	movsbl 0x80293b(%eax),%eax
  80058d:	89 04 24             	mov    %eax,(%esp)
  800590:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800593:	83 c4 3c             	add    $0x3c,%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005e9:	88 0a                	mov    %cl,(%edx)
  8005eb:	83 c2 01             	add    $0x1,%edx
  8005ee:	89 10                	mov    %edx,(%eax)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800602:	89 44 24 08          	mov    %eax,0x8(%esp)
  800606:	8b 45 0c             	mov    0xc(%ebp),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	e8 02 00 00 00       	call   80061a <vprintfmt>
	va_end(ap);
}
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 5c             	sub    $0x5c,%esp
  800623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800626:	8b 75 10             	mov    0x10(%ebp),%esi
  800629:	eb 12                	jmp    80063d <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80062b:	85 c0                	test   %eax,%eax
  80062d:	0f 84 e4 04 00 00    	je     800b17 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800633:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063d:	0f b6 06             	movzbl (%esi),%eax
  800640:	83 c6 01             	add    $0x1,%esi
  800643:	83 f8 25             	cmp    $0x25,%eax
  800646:	75 e3                	jne    80062b <vprintfmt+0x11>
  800648:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80064c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800653:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800658:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800667:	eb 2b                	jmp    800694 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80066c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800670:	eb 22                	jmp    800694 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800675:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800679:	eb 19                	jmp    800694 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80067e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800685:	eb 0d                	jmp    800694 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800687:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80068a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80068d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	0f b6 06             	movzbl (%esi),%eax
  800697:	0f b6 d0             	movzbl %al,%edx
  80069a:	8d 7e 01             	lea    0x1(%esi),%edi
  80069d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006a0:	83 e8 23             	sub    $0x23,%eax
  8006a3:	3c 55                	cmp    $0x55,%al
  8006a5:	0f 87 46 04 00 00    	ja     800af1 <vprintfmt+0x4d7>
  8006ab:	0f b6 c0             	movzbl %al,%eax
  8006ae:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b5:	83 ea 30             	sub    $0x30,%edx
  8006b8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8006bb:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8006bf:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8006c5:	83 fa 09             	cmp    $0x9,%edx
  8006c8:	77 4a                	ja     800714 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006cd:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8006d0:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006d3:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006d7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006da:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006dd:	83 fa 09             	cmp    $0x9,%edx
  8006e0:	76 eb                	jbe    8006cd <vprintfmt+0xb3>
  8006e2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8006e5:	eb 2d                	jmp    800714 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 50 04             	lea    0x4(%eax),%edx
  8006ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006f8:	eb 1a                	jmp    800714 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8006fd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800701:	79 91                	jns    800694 <vprintfmt+0x7a>
  800703:	e9 73 ff ff ff       	jmp    80067b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80070b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800712:	eb 80                	jmp    800694 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800714:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800718:	0f 89 76 ff ff ff    	jns    800694 <vprintfmt+0x7a>
  80071e:	e9 64 ff ff ff       	jmp    800687 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800723:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800729:	e9 66 ff ff ff       	jmp    800694 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)
  800737:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	89 04 24             	mov    %eax,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800746:	e9 f2 fe ff ff       	jmp    80063d <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80074b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80074f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800752:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800756:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800759:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80075d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800760:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800763:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800767:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80076a:	80 f9 09             	cmp    $0x9,%cl
  80076d:	77 1d                	ja     80078c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80076f:	0f be c0             	movsbl %al,%eax
  800772:	6b c0 64             	imul   $0x64,%eax,%eax
  800775:	0f be d2             	movsbl %dl,%edx
  800778:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80077b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800782:	a3 04 30 80 00       	mov    %eax,0x803004
  800787:	e9 b1 fe ff ff       	jmp    80063d <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80078c:	c7 44 24 04 53 29 80 	movl   $0x802953,0x4(%esp)
  800793:	00 
  800794:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800797:	89 04 24             	mov    %eax,(%esp)
  80079a:	e8 0c 05 00 00       	call   800cab <strcmp>
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	75 0f                	jne    8007b2 <vprintfmt+0x198>
  8007a3:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  8007aa:	00 00 00 
  8007ad:	e9 8b fe ff ff       	jmp    80063d <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8007b2:	c7 44 24 04 57 29 80 	movl   $0x802957,0x4(%esp)
  8007b9:	00 
  8007ba:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8007bd:	89 14 24             	mov    %edx,(%esp)
  8007c0:	e8 e6 04 00 00       	call   800cab <strcmp>
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	75 0f                	jne    8007d8 <vprintfmt+0x1be>
  8007c9:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  8007d0:	00 00 00 
  8007d3:	e9 65 fe ff ff       	jmp    80063d <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8007d8:	c7 44 24 04 5b 29 80 	movl   $0x80295b,0x4(%esp)
  8007df:	00 
  8007e0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8007e3:	89 0c 24             	mov    %ecx,(%esp)
  8007e6:	e8 c0 04 00 00       	call   800cab <strcmp>
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	75 0f                	jne    8007fe <vprintfmt+0x1e4>
  8007ef:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  8007f6:	00 00 00 
  8007f9:	e9 3f fe ff ff       	jmp    80063d <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8007fe:	c7 44 24 04 5f 29 80 	movl   $0x80295f,0x4(%esp)
  800805:	00 
  800806:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800809:	89 3c 24             	mov    %edi,(%esp)
  80080c:	e8 9a 04 00 00       	call   800cab <strcmp>
  800811:	85 c0                	test   %eax,%eax
  800813:	75 0f                	jne    800824 <vprintfmt+0x20a>
  800815:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  80081c:	00 00 00 
  80081f:	e9 19 fe ff ff       	jmp    80063d <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800824:	c7 44 24 04 63 29 80 	movl   $0x802963,0x4(%esp)
  80082b:	00 
  80082c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 74 04 00 00       	call   800cab <strcmp>
  800837:	85 c0                	test   %eax,%eax
  800839:	75 0f                	jne    80084a <vprintfmt+0x230>
  80083b:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800842:	00 00 00 
  800845:	e9 f3 fd ff ff       	jmp    80063d <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80084a:	c7 44 24 04 67 29 80 	movl   $0x802967,0x4(%esp)
  800851:	00 
  800852:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800855:	89 14 24             	mov    %edx,(%esp)
  800858:	e8 4e 04 00 00       	call   800cab <strcmp>
  80085d:	83 f8 01             	cmp    $0x1,%eax
  800860:	19 c0                	sbb    %eax,%eax
  800862:	f7 d0                	not    %eax
  800864:	83 c0 08             	add    $0x8,%eax
  800867:	a3 04 30 80 00       	mov    %eax,0x803004
  80086c:	e9 cc fd ff ff       	jmp    80063d <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8d 50 04             	lea    0x4(%eax),%edx
  800877:	89 55 14             	mov    %edx,0x14(%ebp)
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	89 c2                	mov    %eax,%edx
  80087e:	c1 fa 1f             	sar    $0x1f,%edx
  800881:	31 d0                	xor    %edx,%eax
  800883:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800885:	83 f8 0f             	cmp    $0xf,%eax
  800888:	7f 0b                	jg     800895 <vprintfmt+0x27b>
  80088a:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  800891:	85 d2                	test   %edx,%edx
  800893:	75 23                	jne    8008b8 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800895:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800899:	c7 44 24 08 6b 29 80 	movl   $0x80296b,0x8(%esp)
  8008a0:	00 
  8008a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a8:	89 3c 24             	mov    %edi,(%esp)
  8008ab:	e8 42 fd ff ff       	call   8005f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008b3:	e9 85 fd ff ff       	jmp    80063d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008bc:	c7 44 24 08 35 2d 80 	movl   $0x802d35,0x8(%esp)
  8008c3:	00 
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	89 3c 24             	mov    %edi,(%esp)
  8008ce:	e8 1f fd ff ff       	call   8005f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008d6:	e9 62 fd ff ff       	jmp    80063d <vprintfmt+0x23>
  8008db:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8008de:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008e1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ed:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008ef:	85 f6                	test   %esi,%esi
  8008f1:	b8 4c 29 80 00       	mov    $0x80294c,%eax
  8008f6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8008f9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8008fd:	7e 06                	jle    800905 <vprintfmt+0x2eb>
  8008ff:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800903:	75 13                	jne    800918 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800905:	0f be 06             	movsbl (%esi),%eax
  800908:	83 c6 01             	add    $0x1,%esi
  80090b:	85 c0                	test   %eax,%eax
  80090d:	0f 85 94 00 00 00    	jne    8009a7 <vprintfmt+0x38d>
  800913:	e9 81 00 00 00       	jmp    800999 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800918:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091c:	89 34 24             	mov    %esi,(%esp)
  80091f:	e8 97 02 00 00       	call   800bbb <strnlen>
  800924:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800927:	29 c2                	sub    %eax,%edx
  800929:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80092c:	85 d2                	test   %edx,%edx
  80092e:	7e d5                	jle    800905 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800930:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800934:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800937:	89 7d c0             	mov    %edi,-0x40(%ebp)
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	89 cf                	mov    %ecx,%edi
  80093e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800942:	89 3c 24             	mov    %edi,(%esp)
  800945:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800948:	83 ee 01             	sub    $0x1,%esi
  80094b:	75 f1                	jne    80093e <vprintfmt+0x324>
  80094d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800950:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800953:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800956:	eb ad                	jmp    800905 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800958:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80095c:	74 1b                	je     800979 <vprintfmt+0x35f>
  80095e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800961:	83 fa 5e             	cmp    $0x5e,%edx
  800964:	76 13                	jbe    800979 <vprintfmt+0x35f>
					putch('?', putdat);
  800966:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800974:	ff 55 08             	call   *0x8(%ebp)
  800977:	eb 0d                	jmp    800986 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800979:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80097c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800980:	89 04 24             	mov    %eax,(%esp)
  800983:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800986:	83 eb 01             	sub    $0x1,%ebx
  800989:	0f be 06             	movsbl (%esi),%eax
  80098c:	83 c6 01             	add    $0x1,%esi
  80098f:	85 c0                	test   %eax,%eax
  800991:	75 1a                	jne    8009ad <vprintfmt+0x393>
  800993:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800996:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800999:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80099c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8009a0:	7f 1c                	jg     8009be <vprintfmt+0x3a4>
  8009a2:	e9 96 fc ff ff       	jmp    80063d <vprintfmt+0x23>
  8009a7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8009aa:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ad:	85 ff                	test   %edi,%edi
  8009af:	78 a7                	js     800958 <vprintfmt+0x33e>
  8009b1:	83 ef 01             	sub    $0x1,%edi
  8009b4:	79 a2                	jns    800958 <vprintfmt+0x33e>
  8009b6:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8009b9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009bc:	eb db                	jmp    800999 <vprintfmt+0x37f>
  8009be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c1:	89 de                	mov    %ebx,%esi
  8009c3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d3:	83 eb 01             	sub    $0x1,%ebx
  8009d6:	75 ee                	jne    8009c6 <vprintfmt+0x3ac>
  8009d8:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009dd:	e9 5b fc ff ff       	jmp    80063d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009e2:	83 f9 01             	cmp    $0x1,%ecx
  8009e5:	7e 10                	jle    8009f7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8009e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ea:	8d 50 08             	lea    0x8(%eax),%edx
  8009ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8009f0:	8b 30                	mov    (%eax),%esi
  8009f2:	8b 78 04             	mov    0x4(%eax),%edi
  8009f5:	eb 26                	jmp    800a1d <vprintfmt+0x403>
	else if (lflag)
  8009f7:	85 c9                	test   %ecx,%ecx
  8009f9:	74 12                	je     800a0d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8009fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fe:	8d 50 04             	lea    0x4(%eax),%edx
  800a01:	89 55 14             	mov    %edx,0x14(%ebp)
  800a04:	8b 30                	mov    (%eax),%esi
  800a06:	89 f7                	mov    %esi,%edi
  800a08:	c1 ff 1f             	sar    $0x1f,%edi
  800a0b:	eb 10                	jmp    800a1d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800a0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a10:	8d 50 04             	lea    0x4(%eax),%edx
  800a13:	89 55 14             	mov    %edx,0x14(%ebp)
  800a16:	8b 30                	mov    (%eax),%esi
  800a18:	89 f7                	mov    %esi,%edi
  800a1a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a1d:	85 ff                	test   %edi,%edi
  800a1f:	78 0e                	js     800a2f <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a21:	89 f0                	mov    %esi,%eax
  800a23:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a25:	be 0a 00 00 00       	mov    $0xa,%esi
  800a2a:	e9 84 00 00 00       	jmp    800ab3 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a33:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a3d:	89 f0                	mov    %esi,%eax
  800a3f:	89 fa                	mov    %edi,%edx
  800a41:	f7 d8                	neg    %eax
  800a43:	83 d2 00             	adc    $0x0,%edx
  800a46:	f7 da                	neg    %edx
			}
			base = 10;
  800a48:	be 0a 00 00 00       	mov    $0xa,%esi
  800a4d:	eb 64                	jmp    800ab3 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a4f:	89 ca                	mov    %ecx,%edx
  800a51:	8d 45 14             	lea    0x14(%ebp),%eax
  800a54:	e8 42 fb ff ff       	call   80059b <getuint>
			base = 10;
  800a59:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800a5e:	eb 53                	jmp    800ab3 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800a60:	89 ca                	mov    %ecx,%edx
  800a62:	8d 45 14             	lea    0x14(%ebp),%eax
  800a65:	e8 31 fb ff ff       	call   80059b <getuint>
    			base = 8;
  800a6a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800a6f:	eb 42                	jmp    800ab3 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800a71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a75:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a7c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a83:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a8a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a90:	8d 50 04             	lea    0x4(%eax),%edx
  800a93:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a96:	8b 00                	mov    (%eax),%eax
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a9d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800aa2:	eb 0f                	jmp    800ab3 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa4:	89 ca                	mov    %ecx,%edx
  800aa6:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa9:	e8 ed fa ff ff       	call   80059b <getuint>
			base = 16;
  800aae:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab3:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800ab7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800abb:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800abe:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ac2:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800acd:	89 da                	mov    %ebx,%edx
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	e8 e9 f9 ff ff       	call   8004c0 <printnum>
			break;
  800ad7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ada:	e9 5e fb ff ff       	jmp    80063d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae3:	89 14 24             	mov    %edx,(%esp)
  800ae6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800aec:	e9 4c fb ff ff       	jmp    80063d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800afc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b03:	0f 84 34 fb ff ff    	je     80063d <vprintfmt+0x23>
  800b09:	83 ee 01             	sub    $0x1,%esi
  800b0c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b10:	75 f7                	jne    800b09 <vprintfmt+0x4ef>
  800b12:	e9 26 fb ff ff       	jmp    80063d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b17:	83 c4 5c             	add    $0x5c,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 28             	sub    $0x28,%esp
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b32:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	74 30                	je     800b70 <vsnprintf+0x51>
  800b40:	85 d2                	test   %edx,%edx
  800b42:	7e 2c                	jle    800b70 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b44:	8b 45 14             	mov    0x14(%ebp),%eax
  800b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b52:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b59:	c7 04 24 d5 05 80 00 	movl   $0x8005d5,(%esp)
  800b60:	e8 b5 fa ff ff       	call   80061a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b65:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b68:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b6e:	eb 05                	jmp    800b75 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b7d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b84:	8b 45 10             	mov    0x10(%ebp),%eax
  800b87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	89 04 24             	mov    %eax,(%esp)
  800b98:	e8 82 ff ff ff       	call   800b1f <vsnprintf>
	va_end(ap);

	return rc;
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    
	...

00800ba0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	80 3a 00             	cmpb   $0x0,(%edx)
  800bae:	74 09                	je     800bb9 <strlen+0x19>
		n++;
  800bb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb7:	75 f7                	jne    800bb0 <strlen+0x10>
		n++;
	return n;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	85 c9                	test   %ecx,%ecx
  800bcc:	74 1a                	je     800be8 <strnlen+0x2d>
  800bce:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bd1:	74 15                	je     800be8 <strnlen+0x2d>
  800bd3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800bd8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bda:	39 ca                	cmp    %ecx,%edx
  800bdc:	74 0a                	je     800be8 <strnlen+0x2d>
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800be6:	75 f0                	jne    800bd8 <strnlen+0x1d>
		n++;
	return n;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bfe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c01:	83 c2 01             	add    $0x1,%edx
  800c04:	84 c9                	test   %cl,%cl
  800c06:	75 f2                	jne    800bfa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c08:	5b                   	pop    %ebx
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 08             	sub    $0x8,%esp
  800c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c15:	89 1c 24             	mov    %ebx,(%esp)
  800c18:	e8 83 ff ff ff       	call   800ba0 <strlen>
	strcpy(dst + len, src);
  800c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c20:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c24:	01 d8                	add    %ebx,%eax
  800c26:	89 04 24             	mov    %eax,(%esp)
  800c29:	e8 bd ff ff ff       	call   800beb <strcpy>
	return dst;
}
  800c2e:	89 d8                	mov    %ebx,%eax
  800c30:	83 c4 08             	add    $0x8,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c44:	85 f6                	test   %esi,%esi
  800c46:	74 18                	je     800c60 <strncpy+0x2a>
  800c48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c4d:	0f b6 1a             	movzbl (%edx),%ebx
  800c50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c53:	80 3a 01             	cmpb   $0x1,(%edx)
  800c56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	39 f1                	cmp    %esi,%ecx
  800c5e:	75 ed                	jne    800c4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c70:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c73:	89 f8                	mov    %edi,%eax
  800c75:	85 f6                	test   %esi,%esi
  800c77:	74 2b                	je     800ca4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c79:	83 fe 01             	cmp    $0x1,%esi
  800c7c:	74 23                	je     800ca1 <strlcpy+0x3d>
  800c7e:	0f b6 0b             	movzbl (%ebx),%ecx
  800c81:	84 c9                	test   %cl,%cl
  800c83:	74 1c                	je     800ca1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c85:	83 ee 02             	sub    $0x2,%esi
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c8d:	88 08                	mov    %cl,(%eax)
  800c8f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c92:	39 f2                	cmp    %esi,%edx
  800c94:	74 0b                	je     800ca1 <strlcpy+0x3d>
  800c96:	83 c2 01             	add    $0x1,%edx
  800c99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c9d:	84 c9                	test   %cl,%cl
  800c9f:	75 ec                	jne    800c8d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800ca1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ca4:	29 f8                	sub    %edi,%eax
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cb4:	0f b6 01             	movzbl (%ecx),%eax
  800cb7:	84 c0                	test   %al,%al
  800cb9:	74 16                	je     800cd1 <strcmp+0x26>
  800cbb:	3a 02                	cmp    (%edx),%al
  800cbd:	75 12                	jne    800cd1 <strcmp+0x26>
		p++, q++;
  800cbf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cc2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800cc6:	84 c0                	test   %al,%al
  800cc8:	74 07                	je     800cd1 <strcmp+0x26>
  800cca:	83 c1 01             	add    $0x1,%ecx
  800ccd:	3a 02                	cmp    (%edx),%al
  800ccf:	74 ee                	je     800cbf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd1:	0f b6 c0             	movzbl %al,%eax
  800cd4:	0f b6 12             	movzbl (%edx),%edx
  800cd7:	29 d0                	sub    %edx,%eax
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	53                   	push   %ebx
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ced:	85 d2                	test   %edx,%edx
  800cef:	74 28                	je     800d19 <strncmp+0x3e>
  800cf1:	0f b6 01             	movzbl (%ecx),%eax
  800cf4:	84 c0                	test   %al,%al
  800cf6:	74 24                	je     800d1c <strncmp+0x41>
  800cf8:	3a 03                	cmp    (%ebx),%al
  800cfa:	75 20                	jne    800d1c <strncmp+0x41>
  800cfc:	83 ea 01             	sub    $0x1,%edx
  800cff:	74 13                	je     800d14 <strncmp+0x39>
		n--, p++, q++;
  800d01:	83 c1 01             	add    $0x1,%ecx
  800d04:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d07:	0f b6 01             	movzbl (%ecx),%eax
  800d0a:	84 c0                	test   %al,%al
  800d0c:	74 0e                	je     800d1c <strncmp+0x41>
  800d0e:	3a 03                	cmp    (%ebx),%al
  800d10:	74 ea                	je     800cfc <strncmp+0x21>
  800d12:	eb 08                	jmp    800d1c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1c:	0f b6 01             	movzbl (%ecx),%eax
  800d1f:	0f b6 13             	movzbl (%ebx),%edx
  800d22:	29 d0                	sub    %edx,%eax
  800d24:	eb f3                	jmp    800d19 <strncmp+0x3e>

00800d26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d30:	0f b6 10             	movzbl (%eax),%edx
  800d33:	84 d2                	test   %dl,%dl
  800d35:	74 1c                	je     800d53 <strchr+0x2d>
		if (*s == c)
  800d37:	38 ca                	cmp    %cl,%dl
  800d39:	75 09                	jne    800d44 <strchr+0x1e>
  800d3b:	eb 1b                	jmp    800d58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d3d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800d40:	38 ca                	cmp    %cl,%dl
  800d42:	74 14                	je     800d58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d44:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800d48:	84 d2                	test   %dl,%dl
  800d4a:	75 f1                	jne    800d3d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800d4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d51:	eb 05                	jmp    800d58 <strchr+0x32>
  800d53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d64:	0f b6 10             	movzbl (%eax),%edx
  800d67:	84 d2                	test   %dl,%dl
  800d69:	74 14                	je     800d7f <strfind+0x25>
		if (*s == c)
  800d6b:	38 ca                	cmp    %cl,%dl
  800d6d:	75 06                	jne    800d75 <strfind+0x1b>
  800d6f:	eb 0e                	jmp    800d7f <strfind+0x25>
  800d71:	38 ca                	cmp    %cl,%dl
  800d73:	74 0a                	je     800d7f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	0f b6 10             	movzbl (%eax),%edx
  800d7b:	84 d2                	test   %dl,%dl
  800d7d:	75 f2                	jne    800d71 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d99:	85 c9                	test   %ecx,%ecx
  800d9b:	74 30                	je     800dcd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da3:	75 25                	jne    800dca <memset+0x49>
  800da5:	f6 c1 03             	test   $0x3,%cl
  800da8:	75 20                	jne    800dca <memset+0x49>
		c &= 0xFF;
  800daa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dad:	89 d3                	mov    %edx,%ebx
  800daf:	c1 e3 08             	shl    $0x8,%ebx
  800db2:	89 d6                	mov    %edx,%esi
  800db4:	c1 e6 18             	shl    $0x18,%esi
  800db7:	89 d0                	mov    %edx,%eax
  800db9:	c1 e0 10             	shl    $0x10,%eax
  800dbc:	09 f0                	or     %esi,%eax
  800dbe:	09 d0                	or     %edx,%eax
  800dc0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dc2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dc5:	fc                   	cld    
  800dc6:	f3 ab                	rep stos %eax,%es:(%edi)
  800dc8:	eb 03                	jmp    800dcd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dca:	fc                   	cld    
  800dcb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dcd:	89 f8                	mov    %edi,%eax
  800dcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd8:	89 ec                	mov    %ebp,%esp
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 08             	sub    $0x8,%esp
  800de2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df1:	39 c6                	cmp    %eax,%esi
  800df3:	73 36                	jae    800e2b <memmove+0x4f>
  800df5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df8:	39 d0                	cmp    %edx,%eax
  800dfa:	73 2f                	jae    800e2b <memmove+0x4f>
		s += n;
		d += n;
  800dfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dff:	f6 c2 03             	test   $0x3,%dl
  800e02:	75 1b                	jne    800e1f <memmove+0x43>
  800e04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e0a:	75 13                	jne    800e1f <memmove+0x43>
  800e0c:	f6 c1 03             	test   $0x3,%cl
  800e0f:	75 0e                	jne    800e1f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e11:	83 ef 04             	sub    $0x4,%edi
  800e14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e1a:	fd                   	std    
  800e1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1d:	eb 09                	jmp    800e28 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e1f:	83 ef 01             	sub    $0x1,%edi
  800e22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e25:	fd                   	std    
  800e26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e28:	fc                   	cld    
  800e29:	eb 20                	jmp    800e4b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e31:	75 13                	jne    800e46 <memmove+0x6a>
  800e33:	a8 03                	test   $0x3,%al
  800e35:	75 0f                	jne    800e46 <memmove+0x6a>
  800e37:	f6 c1 03             	test   $0x3,%cl
  800e3a:	75 0a                	jne    800e46 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e3c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e3f:	89 c7                	mov    %eax,%edi
  800e41:	fc                   	cld    
  800e42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e44:	eb 05                	jmp    800e4b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e46:	89 c7                	mov    %eax,%edi
  800e48:	fc                   	cld    
  800e49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e51:	89 ec                	mov    %ebp,%esp
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	89 04 24             	mov    %eax,(%esp)
  800e6f:	e8 68 ff ff ff       	call   800ddc <memmove>
}
  800e74:	c9                   	leave  
  800e75:	c3                   	ret    

00800e76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e82:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8a:	85 ff                	test   %edi,%edi
  800e8c:	74 37                	je     800ec5 <memcmp+0x4f>
		if (*s1 != *s2)
  800e8e:	0f b6 03             	movzbl (%ebx),%eax
  800e91:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e94:	83 ef 01             	sub    $0x1,%edi
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e9c:	38 c8                	cmp    %cl,%al
  800e9e:	74 1c                	je     800ebc <memcmp+0x46>
  800ea0:	eb 10                	jmp    800eb2 <memcmp+0x3c>
  800ea2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ea7:	83 c2 01             	add    $0x1,%edx
  800eaa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800eae:	38 c8                	cmp    %cl,%al
  800eb0:	74 0a                	je     800ebc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800eb2:	0f b6 c0             	movzbl %al,%eax
  800eb5:	0f b6 c9             	movzbl %cl,%ecx
  800eb8:	29 c8                	sub    %ecx,%eax
  800eba:	eb 09                	jmp    800ec5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ebc:	39 fa                	cmp    %edi,%edx
  800ebe:	75 e2                	jne    800ea2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ed5:	39 d0                	cmp    %edx,%eax
  800ed7:	73 19                	jae    800ef2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800edd:	38 08                	cmp    %cl,(%eax)
  800edf:	75 06                	jne    800ee7 <memfind+0x1d>
  800ee1:	eb 0f                	jmp    800ef2 <memfind+0x28>
  800ee3:	38 08                	cmp    %cl,(%eax)
  800ee5:	74 0b                	je     800ef2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee7:	83 c0 01             	add    $0x1,%eax
  800eea:	39 d0                	cmp    %edx,%eax
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	75 f1                	jne    800ee3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f00:	0f b6 02             	movzbl (%edx),%eax
  800f03:	3c 20                	cmp    $0x20,%al
  800f05:	74 04                	je     800f0b <strtol+0x17>
  800f07:	3c 09                	cmp    $0x9,%al
  800f09:	75 0e                	jne    800f19 <strtol+0x25>
		s++;
  800f0b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0e:	0f b6 02             	movzbl (%edx),%eax
  800f11:	3c 20                	cmp    $0x20,%al
  800f13:	74 f6                	je     800f0b <strtol+0x17>
  800f15:	3c 09                	cmp    $0x9,%al
  800f17:	74 f2                	je     800f0b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f19:	3c 2b                	cmp    $0x2b,%al
  800f1b:	75 0a                	jne    800f27 <strtol+0x33>
		s++;
  800f1d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f20:	bf 00 00 00 00       	mov    $0x0,%edi
  800f25:	eb 10                	jmp    800f37 <strtol+0x43>
  800f27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f2c:	3c 2d                	cmp    $0x2d,%al
  800f2e:	75 07                	jne    800f37 <strtol+0x43>
		s++, neg = 1;
  800f30:	83 c2 01             	add    $0x1,%edx
  800f33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f37:	85 db                	test   %ebx,%ebx
  800f39:	0f 94 c0             	sete   %al
  800f3c:	74 05                	je     800f43 <strtol+0x4f>
  800f3e:	83 fb 10             	cmp    $0x10,%ebx
  800f41:	75 15                	jne    800f58 <strtol+0x64>
  800f43:	80 3a 30             	cmpb   $0x30,(%edx)
  800f46:	75 10                	jne    800f58 <strtol+0x64>
  800f48:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f4c:	75 0a                	jne    800f58 <strtol+0x64>
		s += 2, base = 16;
  800f4e:	83 c2 02             	add    $0x2,%edx
  800f51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f56:	eb 13                	jmp    800f6b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800f58:	84 c0                	test   %al,%al
  800f5a:	74 0f                	je     800f6b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f61:	80 3a 30             	cmpb   $0x30,(%edx)
  800f64:	75 05                	jne    800f6b <strtol+0x77>
		s++, base = 8;
  800f66:	83 c2 01             	add    $0x1,%edx
  800f69:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f72:	0f b6 0a             	movzbl (%edx),%ecx
  800f75:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f78:	80 fb 09             	cmp    $0x9,%bl
  800f7b:	77 08                	ja     800f85 <strtol+0x91>
			dig = *s - '0';
  800f7d:	0f be c9             	movsbl %cl,%ecx
  800f80:	83 e9 30             	sub    $0x30,%ecx
  800f83:	eb 1e                	jmp    800fa3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f85:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f88:	80 fb 19             	cmp    $0x19,%bl
  800f8b:	77 08                	ja     800f95 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f8d:	0f be c9             	movsbl %cl,%ecx
  800f90:	83 e9 57             	sub    $0x57,%ecx
  800f93:	eb 0e                	jmp    800fa3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f95:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f98:	80 fb 19             	cmp    $0x19,%bl
  800f9b:	77 14                	ja     800fb1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f9d:	0f be c9             	movsbl %cl,%ecx
  800fa0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fa3:	39 f1                	cmp    %esi,%ecx
  800fa5:	7d 0e                	jge    800fb5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800fa7:	83 c2 01             	add    $0x1,%edx
  800faa:	0f af c6             	imul   %esi,%eax
  800fad:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800faf:	eb c1                	jmp    800f72 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800fb1:	89 c1                	mov    %eax,%ecx
  800fb3:	eb 02                	jmp    800fb7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fb5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800fb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fbb:	74 05                	je     800fc2 <strtol+0xce>
		*endptr = (char *) s;
  800fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fc0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fc2:	89 ca                	mov    %ecx,%edx
  800fc4:	f7 da                	neg    %edx
  800fc6:	85 ff                	test   %edi,%edi
  800fc8:	0f 45 c2             	cmovne %edx,%eax
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5f                   	pop    %edi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fdc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	89 c7                	mov    %eax,%edi
  800fee:	89 c6                	mov    %eax,%esi
  800ff0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ff2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffb:	89 ec                	mov    %ebp,%esp
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <sys_cgetc>:

int
sys_cgetc(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801008:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	89 d1                	mov    %edx,%ecx
  80101a:	89 d3                	mov    %edx,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 d6                	mov    %edx,%esi
  801020:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801022:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801025:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801028:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80102b:	89 ec                	mov    %ebp,%esp
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 38             	sub    $0x38,%esp
  801035:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801038:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80103b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801043:	b8 03 00 00 00       	mov    $0x3,%eax
  801048:	8b 55 08             	mov    0x8(%ebp),%edx
  80104b:	89 cb                	mov    %ecx,%ebx
  80104d:	89 cf                	mov    %ecx,%edi
  80104f:	89 ce                	mov    %ecx,%esi
  801051:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801053:	85 c0                	test   %eax,%eax
  801055:	7e 28                	jle    80107f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801057:	89 44 24 10          	mov    %eax,0x10(%esp)
  80105b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801062:	00 
  801063:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  80106a:	00 
  80106b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801072:	00 
  801073:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  80107a:	e8 29 f3 ff ff       	call   8003a8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80107f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801082:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801085:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801088:	89 ec                	mov    %ebp,%esp
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801095:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801098:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	89 d3                	mov    %edx,%ebx
  8010a9:	89 d7                	mov    %edx,%edi
  8010ab:	89 d6                	mov    %edx,%esi
  8010ad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b8:	89 ec                	mov    %ebp,%esp
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <sys_yield>:

void
sys_yield(void)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010d5:	89 d1                	mov    %edx,%ecx
  8010d7:	89 d3                	mov    %edx,%ebx
  8010d9:	89 d7                	mov    %edx,%edi
  8010db:	89 d6                	mov    %edx,%esi
  8010dd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010e8:	89 ec                	mov    %ebp,%esp
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 38             	sub    $0x38,%esp
  8010f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	be 00 00 00 00       	mov    $0x0,%esi
  801100:	b8 04 00 00 00       	mov    $0x4,%eax
  801105:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	89 f7                	mov    %esi,%edi
  801110:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7e 28                	jle    80113e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801116:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801121:	00 
  801122:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801129:	00 
  80112a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801131:	00 
  801132:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801139:	e8 6a f2 ff ff       	call   8003a8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80113e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801141:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801144:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801147:	89 ec                	mov    %ebp,%esp
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	83 ec 38             	sub    $0x38,%esp
  801151:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801154:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801157:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115a:	b8 05 00 00 00       	mov    $0x5,%eax
  80115f:	8b 75 18             	mov    0x18(%ebp),%esi
  801162:	8b 7d 14             	mov    0x14(%ebp),%edi
  801165:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116b:	8b 55 08             	mov    0x8(%ebp),%edx
  80116e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801170:	85 c0                	test   %eax,%eax
  801172:	7e 28                	jle    80119c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801174:	89 44 24 10          	mov    %eax,0x10(%esp)
  801178:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80117f:	00 
  801180:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801187:	00 
  801188:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80118f:	00 
  801190:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801197:	e8 0c f2 ff ff       	call   8003a8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80119c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80119f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011a2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011a5:	89 ec                	mov    %ebp,%esp
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	83 ec 38             	sub    $0x38,%esp
  8011af:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011b2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011b5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8011c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c8:	89 df                	mov    %ebx,%edi
  8011ca:	89 de                	mov    %ebx,%esi
  8011cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	7e 28                	jle    8011fa <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011d6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8011dd:	00 
  8011de:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  8011e5:	00 
  8011e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011ed:	00 
  8011ee:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  8011f5:	e8 ae f1 ff ff       	call   8003a8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801200:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801203:	89 ec                	mov    %ebp,%esp
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 38             	sub    $0x38,%esp
  80120d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801210:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801213:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121b:	b8 08 00 00 00       	mov    $0x8,%eax
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	89 df                	mov    %ebx,%edi
  801228:	89 de                	mov    %ebx,%esi
  80122a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80122c:	85 c0                	test   %eax,%eax
  80122e:	7e 28                	jle    801258 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801230:	89 44 24 10          	mov    %eax,0x10(%esp)
  801234:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80123b:	00 
  80123c:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80124b:	00 
  80124c:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801253:	e8 50 f1 ff ff       	call   8003a8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801258:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80125b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80125e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801261:	89 ec                	mov    %ebp,%esp
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 38             	sub    $0x38,%esp
  80126b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80126e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801271:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801274:	bb 00 00 00 00       	mov    $0x0,%ebx
  801279:	b8 09 00 00 00       	mov    $0x9,%eax
  80127e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801281:	8b 55 08             	mov    0x8(%ebp),%edx
  801284:	89 df                	mov    %ebx,%edi
  801286:	89 de                	mov    %ebx,%esi
  801288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80128a:	85 c0                	test   %eax,%eax
  80128c:	7e 28                	jle    8012b6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801292:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801299:	00 
  80129a:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  8012a1:	00 
  8012a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012a9:	00 
  8012aa:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  8012b1:	e8 f2 f0 ff ff       	call   8003a8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012b6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012b9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012bc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012bf:	89 ec                	mov    %ebp,%esp
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 38             	sub    $0x38,%esp
  8012c9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012cc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012cf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012df:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e2:	89 df                	mov    %ebx,%edi
  8012e4:	89 de                	mov    %ebx,%esi
  8012e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	7e 28                	jle    801314 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  8012ff:	00 
  801300:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801307:	00 
  801308:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  80130f:	e8 94 f0 ff ff       	call   8003a8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801314:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801317:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80131a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80131d:	89 ec                	mov    %ebp,%esp
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80132a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80132d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801330:	be 00 00 00 00       	mov    $0x0,%esi
  801335:	b8 0c 00 00 00       	mov    $0xc,%eax
  80133a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80133d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801343:	8b 55 08             	mov    0x8(%ebp),%edx
  801346:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80134b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80134e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801351:	89 ec                	mov    %ebp,%esp
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 38             	sub    $0x38,%esp
  80135b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80135e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801361:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801364:	b9 00 00 00 00       	mov    $0x0,%ecx
  801369:	b8 0d 00 00 00       	mov    $0xd,%eax
  80136e:	8b 55 08             	mov    0x8(%ebp),%edx
  801371:	89 cb                	mov    %ecx,%ebx
  801373:	89 cf                	mov    %ecx,%edi
  801375:	89 ce                	mov    %ecx,%esi
  801377:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801379:	85 c0                	test   %eax,%eax
  80137b:	7e 28                	jle    8013a5 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801381:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801388:	00 
  801389:	c7 44 24 08 5f 2c 80 	movl   $0x802c5f,0x8(%esp)
  801390:	00 
  801391:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801398:	00 
  801399:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  8013a0:	e8 03 f0 ff ff       	call   8003a8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013a5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013a8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013ae:	89 ec                	mov    %ebp,%esp
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013bb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013be:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013c6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	89 cb                	mov    %ecx,%ebx
  8013d0:	89 cf                	mov    %ecx,%edi
  8013d2:	89 ce                	mov    %ecx,%esi
  8013d4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8013d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013df:	89 ec                	mov    %ebp,%esp
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    
	...

008013e4 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ed:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8013f0:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8013f2:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8013f5:	83 3a 01             	cmpl   $0x1,(%edx)
  8013f8:	7e 09                	jle    801403 <argstart+0x1f>
  8013fa:	ba e8 28 80 00       	mov    $0x8028e8,%edx
  8013ff:	85 c9                	test   %ecx,%ecx
  801401:	75 05                	jne    801408 <argstart+0x24>
  801403:	ba 00 00 00 00       	mov    $0x0,%edx
  801408:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80140b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <argnext>:

int
argnext(struct Argstate *args)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	53                   	push   %ebx
  801418:	83 ec 14             	sub    $0x14,%esp
  80141b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80141e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801425:	8b 43 08             	mov    0x8(%ebx),%eax
  801428:	85 c0                	test   %eax,%eax
  80142a:	74 71                	je     80149d <argnext+0x89>
		return -1;

	if (!*args->curarg) {
  80142c:	80 38 00             	cmpb   $0x0,(%eax)
  80142f:	75 50                	jne    801481 <argnext+0x6d>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801431:	8b 0b                	mov    (%ebx),%ecx
  801433:	83 39 01             	cmpl   $0x1,(%ecx)
  801436:	74 57                	je     80148f <argnext+0x7b>
		    || args->argv[1][0] != '-'
  801438:	8b 53 04             	mov    0x4(%ebx),%edx
  80143b:	8b 42 04             	mov    0x4(%edx),%eax
  80143e:	80 38 2d             	cmpb   $0x2d,(%eax)
  801441:	75 4c                	jne    80148f <argnext+0x7b>
		    || args->argv[1][1] == '\0')
  801443:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801447:	74 46                	je     80148f <argnext+0x7b>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801449:	83 c0 01             	add    $0x1,%eax
  80144c:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80144f:	8b 01                	mov    (%ecx),%eax
  801451:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801458:	89 44 24 08          	mov    %eax,0x8(%esp)
  80145c:	8d 42 08             	lea    0x8(%edx),%eax
  80145f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801463:	83 c2 04             	add    $0x4,%edx
  801466:	89 14 24             	mov    %edx,(%esp)
  801469:	e8 6e f9 ff ff       	call   800ddc <memmove>
		(*args->argc)--;
  80146e:	8b 03                	mov    (%ebx),%eax
  801470:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801473:	8b 43 08             	mov    0x8(%ebx),%eax
  801476:	80 38 2d             	cmpb   $0x2d,(%eax)
  801479:	75 06                	jne    801481 <argnext+0x6d>
  80147b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80147f:	74 0e                	je     80148f <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801481:	8b 53 08             	mov    0x8(%ebx),%edx
  801484:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801487:	83 c2 01             	add    $0x1,%edx
  80148a:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80148d:	eb 13                	jmp    8014a2 <argnext+0x8e>

    endofargs:
	args->curarg = 0;
  80148f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801496:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80149b:	eb 05                	jmp    8014a2 <argnext+0x8e>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80149d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8014a2:	83 c4 14             	add    $0x14,%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 14             	sub    $0x14,%esp
  8014af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8014b2:	8b 43 08             	mov    0x8(%ebx),%eax
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	74 5a                	je     801513 <argnextvalue+0x6b>
		return 0;
	if (*args->curarg) {
  8014b9:	80 38 00             	cmpb   $0x0,(%eax)
  8014bc:	74 0c                	je     8014ca <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8014be:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8014c1:	c7 43 08 e8 28 80 00 	movl   $0x8028e8,0x8(%ebx)
  8014c8:	eb 44                	jmp    80150e <argnextvalue+0x66>
	} else if (*args->argc > 1) {
  8014ca:	8b 03                	mov    (%ebx),%eax
  8014cc:	83 38 01             	cmpl   $0x1,(%eax)
  8014cf:	7e 2f                	jle    801500 <argnextvalue+0x58>
		args->argvalue = args->argv[1];
  8014d1:	8b 53 04             	mov    0x4(%ebx),%edx
  8014d4:	8b 4a 04             	mov    0x4(%edx),%ecx
  8014d7:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8014da:	8b 00                	mov    (%eax),%eax
  8014dc:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8014e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e7:	8d 42 08             	lea    0x8(%edx),%eax
  8014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ee:	83 c2 04             	add    $0x4,%edx
  8014f1:	89 14 24             	mov    %edx,(%esp)
  8014f4:	e8 e3 f8 ff ff       	call   800ddc <memmove>
		(*args->argc)--;
  8014f9:	8b 03                	mov    (%ebx),%eax
  8014fb:	83 28 01             	subl   $0x1,(%eax)
  8014fe:	eb 0e                	jmp    80150e <argnextvalue+0x66>
	} else {
		args->argvalue = 0;
  801500:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801507:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80150e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801511:	eb 05                	jmp    801518 <argnextvalue+0x70>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801513:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801518:	83 c4 14             	add    $0x14,%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    

0080151e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 18             	sub    $0x18,%esp
  801524:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801527:	8b 42 0c             	mov    0xc(%edx),%eax
  80152a:	85 c0                	test   %eax,%eax
  80152c:	75 08                	jne    801536 <argvalue+0x18>
  80152e:	89 14 24             	mov    %edx,(%esp)
  801531:	e8 72 ff ff ff       	call   8014a8 <argnextvalue>
}
  801536:	c9                   	leave  
  801537:	c3                   	ret    
	...

00801540 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801543:	8b 45 08             	mov    0x8(%ebp),%eax
  801546:	05 00 00 00 30       	add    $0x30000000,%eax
  80154b:	c1 e8 0c             	shr    $0xc,%eax
}
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 df ff ff ff       	call   801540 <fd2num>
  801561:	05 20 00 0d 00       	add    $0xd0020,%eax
  801566:	c1 e0 0c             	shl    $0xc,%eax
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801572:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801577:	a8 01                	test   $0x1,%al
  801579:	74 34                	je     8015af <fd_alloc+0x44>
  80157b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801580:	a8 01                	test   $0x1,%al
  801582:	74 32                	je     8015b6 <fd_alloc+0x4b>
  801584:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801589:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	c1 ea 16             	shr    $0x16,%edx
  801590:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801597:	f6 c2 01             	test   $0x1,%dl
  80159a:	74 1f                	je     8015bb <fd_alloc+0x50>
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	c1 ea 0c             	shr    $0xc,%edx
  8015a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a8:	f6 c2 01             	test   $0x1,%dl
  8015ab:	75 17                	jne    8015c4 <fd_alloc+0x59>
  8015ad:	eb 0c                	jmp    8015bb <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8015af:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8015b4:	eb 05                	jmp    8015bb <fd_alloc+0x50>
  8015b6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8015bb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8015bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c2:	eb 17                	jmp    8015db <fd_alloc+0x70>
  8015c4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015c9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015ce:	75 b9                	jne    801589 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8015d6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015db:	5b                   	pop    %ebx
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015e9:	83 fa 1f             	cmp    $0x1f,%edx
  8015ec:	77 3f                	ja     80162d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015ee:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8015f4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015f7:	89 d0                	mov    %edx,%eax
  8015f9:	c1 e8 16             	shr    $0x16,%eax
  8015fc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801608:	f6 c1 01             	test   $0x1,%cl
  80160b:	74 20                	je     80162d <fd_lookup+0x4f>
  80160d:	89 d0                	mov    %edx,%eax
  80160f:	c1 e8 0c             	shr    $0xc,%eax
  801612:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801619:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80161e:	f6 c1 01             	test   $0x1,%cl
  801621:	74 0a                	je     80162d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801623:	8b 45 0c             	mov    0xc(%ebp),%eax
  801626:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  801628:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 14             	sub    $0x14,%esp
  801636:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801641:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801647:	75 17                	jne    801660 <dev_lookup+0x31>
  801649:	eb 07                	jmp    801652 <dev_lookup+0x23>
  80164b:	39 0a                	cmp    %ecx,(%edx)
  80164d:	75 11                	jne    801660 <dev_lookup+0x31>
  80164f:	90                   	nop
  801650:	eb 05                	jmp    801657 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801652:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801657:	89 13                	mov    %edx,(%ebx)
			return 0;
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
  80165e:	eb 35                	jmp    801695 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801660:	83 c0 01             	add    $0x1,%eax
  801663:	8b 14 85 0c 2d 80 00 	mov    0x802d0c(,%eax,4),%edx
  80166a:	85 d2                	test   %edx,%edx
  80166c:	75 dd                	jne    80164b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80166e:	a1 20 44 80 00       	mov    0x804420,%eax
  801673:	8b 40 48             	mov    0x48(%eax),%eax
  801676:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80167a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167e:	c7 04 24 8c 2c 80 00 	movl   $0x802c8c,(%esp)
  801685:	e8 19 ee ff ff       	call   8004a3 <cprintf>
	*dev = 0;
  80168a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801690:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801695:	83 c4 14             	add    $0x14,%esp
  801698:	5b                   	pop    %ebx
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 38             	sub    $0x38,%esp
  8016a1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016a4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ad:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016b1:	89 3c 24             	mov    %edi,(%esp)
  8016b4:	e8 87 fe ff ff       	call   801540 <fd2num>
  8016b9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8016bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016c0:	89 04 24             	mov    %eax,(%esp)
  8016c3:	e8 16 ff ff ff       	call   8015de <fd_lookup>
  8016c8:	89 c3                	mov    %eax,%ebx
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 05                	js     8016d3 <fd_close+0x38>
	    || fd != fd2)
  8016ce:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8016d1:	74 0e                	je     8016e1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8016d3:	89 f0                	mov    %esi,%eax
  8016d5:	84 c0                	test   %al,%al
  8016d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dc:	0f 44 d8             	cmove  %eax,%ebx
  8016df:	eb 3d                	jmp    80171e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e8:	8b 07                	mov    (%edi),%eax
  8016ea:	89 04 24             	mov    %eax,(%esp)
  8016ed:	e8 3d ff ff ff       	call   80162f <dev_lookup>
  8016f2:	89 c3                	mov    %eax,%ebx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 16                	js     80170e <fd_close+0x73>
		if (dev->dev_close)
  8016f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016fb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8016fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801703:	85 c0                	test   %eax,%eax
  801705:	74 07                	je     80170e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  801707:	89 3c 24             	mov    %edi,(%esp)
  80170a:	ff d0                	call   *%eax
  80170c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80170e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801712:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801719:	e8 8b fa ff ff       	call   8011a9 <sys_page_unmap>
	return r;
}
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801723:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801726:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801729:	89 ec                	mov    %ebp,%esp
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	e8 99 fe ff ff       	call   8015de <fd_lookup>
  801745:	85 c0                	test   %eax,%eax
  801747:	78 13                	js     80175c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801749:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801750:	00 
  801751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 3f ff ff ff       	call   80169b <fd_close>
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <close_all>:

void
close_all(void)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801765:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80176a:	89 1c 24             	mov    %ebx,(%esp)
  80176d:	e8 bb ff ff ff       	call   80172d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801772:	83 c3 01             	add    $0x1,%ebx
  801775:	83 fb 20             	cmp    $0x20,%ebx
  801778:	75 f0                	jne    80176a <close_all+0xc>
		close(i);
}
  80177a:	83 c4 14             	add    $0x14,%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 58             	sub    $0x58,%esp
  801786:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801789:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80178c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80178f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801792:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801795:	89 44 24 04          	mov    %eax,0x4(%esp)
  801799:	8b 45 08             	mov    0x8(%ebp),%eax
  80179c:	89 04 24             	mov    %eax,(%esp)
  80179f:	e8 3a fe ff ff       	call   8015de <fd_lookup>
  8017a4:	89 c3                	mov    %eax,%ebx
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	0f 88 e1 00 00 00    	js     80188f <dup+0x10f>
		return r;
	close(newfdnum);
  8017ae:	89 3c 24             	mov    %edi,(%esp)
  8017b1:	e8 77 ff ff ff       	call   80172d <close>

	newfd = INDEX2FD(newfdnum);
  8017b6:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8017bc:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8017bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017c2:	89 04 24             	mov    %eax,(%esp)
  8017c5:	e8 86 fd ff ff       	call   801550 <fd2data>
  8017ca:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017cc:	89 34 24             	mov    %esi,(%esp)
  8017cf:	e8 7c fd ff ff       	call   801550 <fd2data>
  8017d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017d7:	89 d8                	mov    %ebx,%eax
  8017d9:	c1 e8 16             	shr    $0x16,%eax
  8017dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017e3:	a8 01                	test   $0x1,%al
  8017e5:	74 46                	je     80182d <dup+0xad>
  8017e7:	89 d8                	mov    %ebx,%eax
  8017e9:	c1 e8 0c             	shr    $0xc,%eax
  8017ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017f3:	f6 c2 01             	test   $0x1,%dl
  8017f6:	74 35                	je     80182d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ff:	25 07 0e 00 00       	and    $0xe07,%eax
  801804:	89 44 24 10          	mov    %eax,0x10(%esp)
  801808:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80180b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80180f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801816:	00 
  801817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801822:	e8 24 f9 ff ff       	call   80114b <sys_page_map>
  801827:	89 c3                	mov    %eax,%ebx
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 3b                	js     801868 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80182d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801830:	89 c2                	mov    %eax,%edx
  801832:	c1 ea 0c             	shr    $0xc,%edx
  801835:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80183c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801842:	89 54 24 10          	mov    %edx,0x10(%esp)
  801846:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80184a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801851:	00 
  801852:	89 44 24 04          	mov    %eax,0x4(%esp)
  801856:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80185d:	e8 e9 f8 ff ff       	call   80114b <sys_page_map>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	85 c0                	test   %eax,%eax
  801866:	79 25                	jns    80188d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801868:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801873:	e8 31 f9 ff ff       	call   8011a9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801878:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80187b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801886:	e8 1e f9 ff ff       	call   8011a9 <sys_page_unmap>
	return r;
  80188b:	eb 02                	jmp    80188f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80188d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80188f:	89 d8                	mov    %ebx,%eax
  801891:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801894:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801897:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80189a:	89 ec                	mov    %ebp,%esp
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 24             	sub    $0x24,%esp
  8018a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018af:	89 1c 24             	mov    %ebx,(%esp)
  8018b2:	e8 27 fd ff ff       	call   8015de <fd_lookup>
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 6d                	js     801928 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c5:	8b 00                	mov    (%eax),%eax
  8018c7:	89 04 24             	mov    %eax,(%esp)
  8018ca:	e8 60 fd ff ff       	call   80162f <dev_lookup>
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 55                	js     801928 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d6:	8b 50 08             	mov    0x8(%eax),%edx
  8018d9:	83 e2 03             	and    $0x3,%edx
  8018dc:	83 fa 01             	cmp    $0x1,%edx
  8018df:	75 23                	jne    801904 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e1:	a1 20 44 80 00       	mov    0x804420,%eax
  8018e6:	8b 40 48             	mov    0x48(%eax),%eax
  8018e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	c7 04 24 d0 2c 80 00 	movl   $0x802cd0,(%esp)
  8018f8:	e8 a6 eb ff ff       	call   8004a3 <cprintf>
		return -E_INVAL;
  8018fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801902:	eb 24                	jmp    801928 <read+0x8a>
	}
	if (!dev->dev_read)
  801904:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801907:	8b 52 08             	mov    0x8(%edx),%edx
  80190a:	85 d2                	test   %edx,%edx
  80190c:	74 15                	je     801923 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80190e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801911:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801918:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	ff d2                	call   *%edx
  801921:	eb 05                	jmp    801928 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801923:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801928:	83 c4 24             	add    $0x24,%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 1c             	sub    $0x1c,%esp
  801937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80193d:	b8 00 00 00 00       	mov    $0x0,%eax
  801942:	85 f6                	test   %esi,%esi
  801944:	74 30                	je     801976 <readn+0x48>
  801946:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80194b:	89 f2                	mov    %esi,%edx
  80194d:	29 c2                	sub    %eax,%edx
  80194f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801953:	03 45 0c             	add    0xc(%ebp),%eax
  801956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195a:	89 3c 24             	mov    %edi,(%esp)
  80195d:	e8 3c ff ff ff       	call   80189e <read>
		if (m < 0)
  801962:	85 c0                	test   %eax,%eax
  801964:	78 10                	js     801976 <readn+0x48>
			return m;
		if (m == 0)
  801966:	85 c0                	test   %eax,%eax
  801968:	74 0a                	je     801974 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80196a:	01 c3                	add    %eax,%ebx
  80196c:	89 d8                	mov    %ebx,%eax
  80196e:	39 f3                	cmp    %esi,%ebx
  801970:	72 d9                	jb     80194b <readn+0x1d>
  801972:	eb 02                	jmp    801976 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801974:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801976:	83 c4 1c             	add    $0x1c,%esp
  801979:	5b                   	pop    %ebx
  80197a:	5e                   	pop    %esi
  80197b:	5f                   	pop    %edi
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 24             	sub    $0x24,%esp
  801985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	89 1c 24             	mov    %ebx,(%esp)
  801992:	e8 47 fc ff ff       	call   8015de <fd_lookup>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 68                	js     801a03 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a5:	8b 00                	mov    (%eax),%eax
  8019a7:	89 04 24             	mov    %eax,(%esp)
  8019aa:	e8 80 fc ff ff       	call   80162f <dev_lookup>
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 50                	js     801a03 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019ba:	75 23                	jne    8019df <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019bc:	a1 20 44 80 00       	mov    0x804420,%eax
  8019c1:	8b 40 48             	mov    0x48(%eax),%eax
  8019c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cc:	c7 04 24 ec 2c 80 00 	movl   $0x802cec,(%esp)
  8019d3:	e8 cb ea ff ff       	call   8004a3 <cprintf>
		return -E_INVAL;
  8019d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019dd:	eb 24                	jmp    801a03 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8019e5:	85 d2                	test   %edx,%edx
  8019e7:	74 15                	je     8019fe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019f7:	89 04 24             	mov    %eax,(%esp)
  8019fa:	ff d2                	call   *%edx
  8019fc:	eb 05                	jmp    801a03 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8019fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a03:	83 c4 24             	add    $0x24,%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a0f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	89 04 24             	mov    %eax,(%esp)
  801a1c:	e8 bd fb ff ff       	call   8015de <fd_lookup>
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 0e                	js     801a33 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a2b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 24             	sub    $0x24,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a46:	89 1c 24             	mov    %ebx,(%esp)
  801a49:	e8 90 fb ff ff       	call   8015de <fd_lookup>
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	78 61                	js     801ab3 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5c:	8b 00                	mov    (%eax),%eax
  801a5e:	89 04 24             	mov    %eax,(%esp)
  801a61:	e8 c9 fb ff ff       	call   80162f <dev_lookup>
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 49                	js     801ab3 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a71:	75 23                	jne    801a96 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a73:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a78:	8b 40 48             	mov    0x48(%eax),%eax
  801a7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a83:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  801a8a:	e8 14 ea ff ff       	call   8004a3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a94:	eb 1d                	jmp    801ab3 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a99:	8b 52 18             	mov    0x18(%edx),%edx
  801a9c:	85 d2                	test   %edx,%edx
  801a9e:	74 0e                	je     801aae <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aa7:	89 04 24             	mov    %eax,(%esp)
  801aaa:	ff d2                	call   *%edx
  801aac:	eb 05                	jmp    801ab3 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801aae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801ab3:	83 c4 24             	add    $0x24,%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 24             	sub    $0x24,%esp
  801ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aca:	8b 45 08             	mov    0x8(%ebp),%eax
  801acd:	89 04 24             	mov    %eax,(%esp)
  801ad0:	e8 09 fb ff ff       	call   8015de <fd_lookup>
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 52                	js     801b2b <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ad9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae3:	8b 00                	mov    (%eax),%eax
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 42 fb ff ff       	call   80162f <dev_lookup>
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 3a                	js     801b2b <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801af8:	74 2c                	je     801b26 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801afa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801afd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b04:	00 00 00 
	stat->st_isdir = 0;
  801b07:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b0e:	00 00 00 
	stat->st_dev = dev;
  801b11:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b1e:	89 14 24             	mov    %edx,(%esp)
  801b21:	ff 50 14             	call   *0x14(%eax)
  801b24:	eb 05                	jmp    801b2b <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b26:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b2b:	83 c4 24             	add    $0x24,%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	83 ec 18             	sub    $0x18,%esp
  801b37:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b3a:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b44:	00 
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	89 04 24             	mov    %eax,(%esp)
  801b4b:	e8 bc 01 00 00       	call   801d0c <open>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 1b                	js     801b71 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5d:	89 1c 24             	mov    %ebx,(%esp)
  801b60:	e8 54 ff ff ff       	call   801ab9 <fstat>
  801b65:	89 c6                	mov    %eax,%esi
	close(fd);
  801b67:	89 1c 24             	mov    %ebx,(%esp)
  801b6a:	e8 be fb ff ff       	call   80172d <close>
	return r;
  801b6f:	89 f3                	mov    %esi,%ebx
}
  801b71:	89 d8                	mov    %ebx,%eax
  801b73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b79:	89 ec                	mov    %ebp,%esp
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    
  801b7d:	00 00                	add    %al,(%eax)
	...

00801b80 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 18             	sub    $0x18,%esp
  801b86:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b89:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b90:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b97:	75 11                	jne    801baa <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ba0:	e8 8c 09 00 00       	call   802531 <ipc_find_env>
  801ba5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801baa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bb1:	00 
  801bb2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bb9:	00 
  801bba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bbe:	a1 00 40 80 00       	mov    0x804000,%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 fb 08 00 00       	call   8024c6 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801bcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bd2:	00 
  801bd3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bde:	e8 7d 08 00 00       	call   802460 <ipc_recv>
}
  801be3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801be6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801be9:	89 ec                	mov    %ebp,%esp
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	53                   	push   %ebx
  801bf1:	83 ec 14             	sub    $0x14,%esp
  801bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfa:	8b 40 0c             	mov    0xc(%eax),%eax
  801bfd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c02:	ba 00 00 00 00       	mov    $0x0,%edx
  801c07:	b8 05 00 00 00       	mov    $0x5,%eax
  801c0c:	e8 6f ff ff ff       	call   801b80 <fsipc>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 2b                	js     801c40 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c15:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c1c:	00 
  801c1d:	89 1c 24             	mov    %ebx,(%esp)
  801c20:	e8 c6 ef ff ff       	call   800beb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c25:	a1 80 50 80 00       	mov    0x805080,%eax
  801c2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c30:	a1 84 50 80 00       	mov    0x805084,%eax
  801c35:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c40:	83 c4 14             	add    $0x14,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4f:	8b 40 0c             	mov    0xc(%eax),%eax
  801c52:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c57:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5c:	b8 06 00 00 00       	mov    $0x6,%eax
  801c61:	e8 1a ff ff ff       	call   801b80 <fsipc>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 10             	sub    $0x10,%esp
  801c70:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	8b 40 0c             	mov    0xc(%eax),%eax
  801c79:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c7e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c84:	ba 00 00 00 00       	mov    $0x0,%edx
  801c89:	b8 03 00 00 00       	mov    $0x3,%eax
  801c8e:	e8 ed fe ff ff       	call   801b80 <fsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 6a                	js     801d03 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 24                	jae    801cc1 <devfile_read+0x59>
  801c9d:	c7 44 24 0c 1c 2d 80 	movl   $0x802d1c,0xc(%esp)
  801ca4:	00 
  801ca5:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  801cac:	00 
  801cad:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801cb4:	00 
  801cb5:	c7 04 24 38 2d 80 00 	movl   $0x802d38,(%esp)
  801cbc:	e8 e7 e6 ff ff       	call   8003a8 <_panic>
	assert(r <= PGSIZE);
  801cc1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cc6:	7e 24                	jle    801cec <devfile_read+0x84>
  801cc8:	c7 44 24 0c 43 2d 80 	movl   $0x802d43,0xc(%esp)
  801ccf:	00 
  801cd0:	c7 44 24 08 23 2d 80 	movl   $0x802d23,0x8(%esp)
  801cd7:	00 
  801cd8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801cdf:	00 
  801ce0:	c7 04 24 38 2d 80 00 	movl   $0x802d38,(%esp)
  801ce7:	e8 bc e6 ff ff       	call   8003a8 <_panic>
	memmove(buf, &fsipcbuf, r);
  801cec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cf7:	00 
  801cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfb:	89 04 24             	mov    %eax,(%esp)
  801cfe:	e8 d9 f0 ff ff       	call   800ddc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801d03:	89 d8                	mov    %ebx,%eax
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	56                   	push   %esi
  801d10:	53                   	push   %ebx
  801d11:	83 ec 20             	sub    $0x20,%esp
  801d14:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d17:	89 34 24             	mov    %esi,(%esp)
  801d1a:	e8 81 ee ff ff       	call   800ba0 <strlen>
		return -E_BAD_PATH;
  801d1f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d29:	7f 5e                	jg     801d89 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	89 04 24             	mov    %eax,(%esp)
  801d31:	e8 35 f8 ff ff       	call   80156b <fd_alloc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 4d                	js     801d89 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d40:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d47:	e8 9f ee ff ff       	call   800beb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d57:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5c:	e8 1f fe ff ff       	call   801b80 <fsipc>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	85 c0                	test   %eax,%eax
  801d65:	79 15                	jns    801d7c <open+0x70>
		fd_close(fd, 0);
  801d67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d6e:	00 
  801d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d72:	89 04 24             	mov    %eax,(%esp)
  801d75:	e8 21 f9 ff ff       	call   80169b <fd_close>
		return r;
  801d7a:	eb 0d                	jmp    801d89 <open+0x7d>
	}

	return fd2num(fd);
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	89 04 24             	mov    %eax,(%esp)
  801d82:	e8 b9 f7 ff ff       	call   801540 <fd2num>
  801d87:	89 c3                	mov    %eax,%ebx
}
  801d89:	89 d8                	mov    %ebx,%eax
  801d8b:	83 c4 20             	add    $0x20,%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
	...

00801d94 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	83 ec 14             	sub    $0x14,%esp
  801d9b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801d9d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801da1:	7e 31                	jle    801dd4 <writebuf+0x40>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801da3:	8b 40 04             	mov    0x4(%eax),%eax
  801da6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801daa:	8d 43 10             	lea    0x10(%ebx),%eax
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	8b 03                	mov    (%ebx),%eax
  801db3:	89 04 24             	mov    %eax,(%esp)
  801db6:	e8 c3 fb ff ff       	call   80197e <write>
		if (result > 0)
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	7e 03                	jle    801dc2 <writebuf+0x2e>
			b->result += result;
  801dbf:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801dc2:	39 43 04             	cmp    %eax,0x4(%ebx)
  801dc5:	74 0d                	je     801dd4 <writebuf+0x40>
			b->error = (result < 0 ? result : 0);
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dce:	0f 4f c2             	cmovg  %edx,%eax
  801dd1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801dd4:	83 c4 14             	add    $0x14,%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    

00801dda <putch>:

static void
putch(int ch, void *thunk)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 04             	sub    $0x4,%esp
  801de1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801de4:	8b 43 04             	mov    0x4(%ebx),%eax
  801de7:	8b 55 08             	mov    0x8(%ebp),%edx
  801dea:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801dee:	83 c0 01             	add    $0x1,%eax
  801df1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801df4:	3d 00 01 00 00       	cmp    $0x100,%eax
  801df9:	75 0e                	jne    801e09 <putch+0x2f>
		writebuf(b);
  801dfb:	89 d8                	mov    %ebx,%eax
  801dfd:	e8 92 ff ff ff       	call   801d94 <writebuf>
		b->idx = 0;
  801e02:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801e09:	83 c4 04             	add    $0x4,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801e21:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801e28:	00 00 00 
	b.result = 0;
  801e2b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801e32:	00 00 00 
	b.error = 1;
  801e35:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801e3c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801e3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e49:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801e53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e57:	c7 04 24 da 1d 80 00 	movl   $0x801dda,(%esp)
  801e5e:	e8 b7 e7 ff ff       	call   80061a <vprintfmt>
	if (b.idx > 0)
  801e63:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801e6a:	7e 0b                	jle    801e77 <vfprintf+0x68>
		writebuf(&b);
  801e6c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801e72:	e8 1d ff ff ff       	call   801d94 <writebuf>

	return (b.result ? b.result : b.error);
  801e77:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801e8e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801e91:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	89 04 24             	mov    %eax,(%esp)
  801ea2:	e8 68 ff ff ff       	call   801e0f <vfprintf>
	va_end(ap);

	return cnt;
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <printf>:

int
printf(const char *fmt, ...)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801eaf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801eb2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ebd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ec4:	e8 46 ff ff ff       	call   801e0f <vfprintf>
	va_end(ap);

	return cnt;
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    
  801ecb:	00 00                	add    %al,(%eax)
  801ecd:	00 00                	add    %al,(%eax)
	...

00801ed0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 18             	sub    $0x18,%esp
  801ed6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ed9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801edc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	89 04 24             	mov    %eax,(%esp)
  801ee5:	e8 66 f6 ff ff       	call   801550 <fd2data>
  801eea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801eec:	c7 44 24 04 4f 2d 80 	movl   $0x802d4f,0x4(%esp)
  801ef3:	00 
  801ef4:	89 34 24             	mov    %esi,(%esp)
  801ef7:	e8 ef ec ff ff       	call   800beb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801efc:	8b 43 04             	mov    0x4(%ebx),%eax
  801eff:	2b 03                	sub    (%ebx),%eax
  801f01:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f07:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f0e:	00 00 00 
	stat->st_dev = &devpipe;
  801f11:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801f18:	30 80 00 
	return 0;
}
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f20:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f23:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f26:	89 ec                	mov    %ebp,%esp
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	53                   	push   %ebx
  801f2e:	83 ec 14             	sub    $0x14,%esp
  801f31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3f:	e8 65 f2 ff ff       	call   8011a9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f44:	89 1c 24             	mov    %ebx,(%esp)
  801f47:	e8 04 f6 ff ff       	call   801550 <fd2data>
  801f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f57:	e8 4d f2 ff ff       	call   8011a9 <sys_page_unmap>
}
  801f5c:	83 c4 14             	add    $0x14,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5d                   	pop    %ebp
  801f61:	c3                   	ret    

00801f62 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	57                   	push   %edi
  801f66:	56                   	push   %esi
  801f67:	53                   	push   %ebx
  801f68:	83 ec 2c             	sub    $0x2c,%esp
  801f6b:	89 c7                	mov    %eax,%edi
  801f6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f70:	a1 20 44 80 00       	mov    0x804420,%eax
  801f75:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f78:	89 3c 24             	mov    %edi,(%esp)
  801f7b:	e8 fc 05 00 00       	call   80257c <pageref>
  801f80:	89 c6                	mov    %eax,%esi
  801f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 ef 05 00 00       	call   80257c <pageref>
  801f8d:	39 c6                	cmp    %eax,%esi
  801f8f:	0f 94 c0             	sete   %al
  801f92:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f95:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f9b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f9e:	39 cb                	cmp    %ecx,%ebx
  801fa0:	75 08                	jne    801faa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801fa2:	83 c4 2c             	add    $0x2c,%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5f                   	pop    %edi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801faa:	83 f8 01             	cmp    $0x1,%eax
  801fad:	75 c1                	jne    801f70 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801faf:	8b 52 58             	mov    0x58(%edx),%edx
  801fb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fbe:	c7 04 24 56 2d 80 00 	movl   $0x802d56,(%esp)
  801fc5:	e8 d9 e4 ff ff       	call   8004a3 <cprintf>
  801fca:	eb a4                	jmp    801f70 <_pipeisclosed+0xe>

00801fcc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	57                   	push   %edi
  801fd0:	56                   	push   %esi
  801fd1:	53                   	push   %ebx
  801fd2:	83 ec 2c             	sub    $0x2c,%esp
  801fd5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fd8:	89 34 24             	mov    %esi,(%esp)
  801fdb:	e8 70 f5 ff ff       	call   801550 <fd2data>
  801fe0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fe7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801feb:	75 50                	jne    80203d <devpipe_write+0x71>
  801fed:	eb 5c                	jmp    80204b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fef:	89 da                	mov    %ebx,%edx
  801ff1:	89 f0                	mov    %esi,%eax
  801ff3:	e8 6a ff ff ff       	call   801f62 <_pipeisclosed>
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	75 53                	jne    80204f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ffc:	e8 bb f0 ff ff       	call   8010bc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802001:	8b 43 04             	mov    0x4(%ebx),%eax
  802004:	8b 13                	mov    (%ebx),%edx
  802006:	83 c2 20             	add    $0x20,%edx
  802009:	39 d0                	cmp    %edx,%eax
  80200b:	73 e2                	jae    801fef <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80200d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802010:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  802014:	88 55 e7             	mov    %dl,-0x19(%ebp)
  802017:	89 c2                	mov    %eax,%edx
  802019:	c1 fa 1f             	sar    $0x1f,%edx
  80201c:	c1 ea 1b             	shr    $0x1b,%edx
  80201f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802022:	83 e1 1f             	and    $0x1f,%ecx
  802025:	29 d1                	sub    %edx,%ecx
  802027:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  80202b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  80202f:	83 c0 01             	add    $0x1,%eax
  802032:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802035:	83 c7 01             	add    $0x1,%edi
  802038:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80203b:	74 0e                	je     80204b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80203d:	8b 43 04             	mov    0x4(%ebx),%eax
  802040:	8b 13                	mov    (%ebx),%edx
  802042:	83 c2 20             	add    $0x20,%edx
  802045:	39 d0                	cmp    %edx,%eax
  802047:	73 a6                	jae    801fef <devpipe_write+0x23>
  802049:	eb c2                	jmp    80200d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80204b:	89 f8                	mov    %edi,%eax
  80204d:	eb 05                	jmp    802054 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802054:	83 c4 2c             	add    $0x2c,%esp
  802057:	5b                   	pop    %ebx
  802058:	5e                   	pop    %esi
  802059:	5f                   	pop    %edi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    

0080205c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 28             	sub    $0x28,%esp
  802062:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802065:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802068:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80206b:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80206e:	89 3c 24             	mov    %edi,(%esp)
  802071:	e8 da f4 ff ff       	call   801550 <fd2data>
  802076:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802078:	be 00 00 00 00       	mov    $0x0,%esi
  80207d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802081:	75 47                	jne    8020ca <devpipe_read+0x6e>
  802083:	eb 52                	jmp    8020d7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802085:	89 f0                	mov    %esi,%eax
  802087:	eb 5e                	jmp    8020e7 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802089:	89 da                	mov    %ebx,%edx
  80208b:	89 f8                	mov    %edi,%eax
  80208d:	8d 76 00             	lea    0x0(%esi),%esi
  802090:	e8 cd fe ff ff       	call   801f62 <_pipeisclosed>
  802095:	85 c0                	test   %eax,%eax
  802097:	75 49                	jne    8020e2 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802099:	e8 1e f0 ff ff       	call   8010bc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80209e:	8b 03                	mov    (%ebx),%eax
  8020a0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020a3:	74 e4                	je     802089 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020a5:	89 c2                	mov    %eax,%edx
  8020a7:	c1 fa 1f             	sar    $0x1f,%edx
  8020aa:	c1 ea 1b             	shr    $0x1b,%edx
  8020ad:	01 d0                	add    %edx,%eax
  8020af:	83 e0 1f             	and    $0x1f,%eax
  8020b2:	29 d0                	sub    %edx,%eax
  8020b4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020bc:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8020bf:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c2:	83 c6 01             	add    $0x1,%esi
  8020c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020c8:	74 0d                	je     8020d7 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  8020ca:	8b 03                	mov    (%ebx),%eax
  8020cc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020cf:	75 d4                	jne    8020a5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020d1:	85 f6                	test   %esi,%esi
  8020d3:	75 b0                	jne    802085 <devpipe_read+0x29>
  8020d5:	eb b2                	jmp    802089 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020d7:	89 f0                	mov    %esi,%eax
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	eb 05                	jmp    8020e7 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020e7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8020ea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8020ed:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8020f0:	89 ec                	mov    %ebp,%esp
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 48             	sub    $0x48,%esp
  8020fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802100:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802103:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802106:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802109:	89 04 24             	mov    %eax,(%esp)
  80210c:	e8 5a f4 ff ff       	call   80156b <fd_alloc>
  802111:	89 c3                	mov    %eax,%ebx
  802113:	85 c0                	test   %eax,%eax
  802115:	0f 88 45 01 00 00    	js     802260 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802122:	00 
  802123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802131:	e8 b6 ef ff ff       	call   8010ec <sys_page_alloc>
  802136:	89 c3                	mov    %eax,%ebx
  802138:	85 c0                	test   %eax,%eax
  80213a:	0f 88 20 01 00 00    	js     802260 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802140:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802143:	89 04 24             	mov    %eax,(%esp)
  802146:	e8 20 f4 ff ff       	call   80156b <fd_alloc>
  80214b:	89 c3                	mov    %eax,%ebx
  80214d:	85 c0                	test   %eax,%eax
  80214f:	0f 88 f8 00 00 00    	js     80224d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802155:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80215c:	00 
  80215d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802160:	89 44 24 04          	mov    %eax,0x4(%esp)
  802164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216b:	e8 7c ef ff ff       	call   8010ec <sys_page_alloc>
  802170:	89 c3                	mov    %eax,%ebx
  802172:	85 c0                	test   %eax,%eax
  802174:	0f 88 d3 00 00 00    	js     80224d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80217a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80217d:	89 04 24             	mov    %eax,(%esp)
  802180:	e8 cb f3 ff ff       	call   801550 <fd2data>
  802185:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802187:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80218e:	00 
  80218f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219a:	e8 4d ef ff ff       	call   8010ec <sys_page_alloc>
  80219f:	89 c3                	mov    %eax,%ebx
  8021a1:	85 c0                	test   %eax,%eax
  8021a3:	0f 88 91 00 00 00    	js     80223a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ac:	89 04 24             	mov    %eax,(%esp)
  8021af:	e8 9c f3 ff ff       	call   801550 <fd2data>
  8021b4:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8021bb:	00 
  8021bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021c7:	00 
  8021c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021d3:	e8 73 ef ff ff       	call   80114b <sys_page_map>
  8021d8:	89 c3                	mov    %eax,%ebx
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	78 4c                	js     80222a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021de:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021e7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021f3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021fc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802201:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80220b:	89 04 24             	mov    %eax,(%esp)
  80220e:	e8 2d f3 ff ff       	call   801540 <fd2num>
  802213:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802215:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802218:	89 04 24             	mov    %eax,(%esp)
  80221b:	e8 20 f3 ff ff       	call   801540 <fd2num>
  802220:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802223:	bb 00 00 00 00       	mov    $0x0,%ebx
  802228:	eb 36                	jmp    802260 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80222a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802235:	e8 6f ef ff ff       	call   8011a9 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80223a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80223d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802248:	e8 5c ef ff ff       	call   8011a9 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80224d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802250:	89 44 24 04          	mov    %eax,0x4(%esp)
  802254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80225b:	e8 49 ef ff ff       	call   8011a9 <sys_page_unmap>
    err:
	return r;
}
  802260:	89 d8                	mov    %ebx,%eax
  802262:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802265:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802268:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80226b:	89 ec                	mov    %ebp,%esp
  80226d:	5d                   	pop    %ebp
  80226e:	c3                   	ret    

0080226f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
  80227f:	89 04 24             	mov    %eax,(%esp)
  802282:	e8 57 f3 ff ff       	call   8015de <fd_lookup>
  802287:	85 c0                	test   %eax,%eax
  802289:	78 15                	js     8022a0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80228b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228e:	89 04 24             	mov    %eax,(%esp)
  802291:	e8 ba f2 ff ff       	call   801550 <fd2data>
	return _pipeisclosed(fd, p);
  802296:	89 c2                	mov    %eax,%edx
  802298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229b:	e8 c2 fc ff ff       	call   801f62 <_pipeisclosed>
}
  8022a0:	c9                   	leave  
  8022a1:	c3                   	ret    
	...

008022b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b8:	5d                   	pop    %ebp
  8022b9:	c3                   	ret    

008022ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ba:	55                   	push   %ebp
  8022bb:	89 e5                	mov    %esp,%ebp
  8022bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8022c0:	c7 44 24 04 6e 2d 80 	movl   $0x802d6e,0x4(%esp)
  8022c7:	00 
  8022c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022cb:	89 04 24             	mov    %eax,(%esp)
  8022ce:	e8 18 e9 ff ff       	call   800beb <strcpy>
	return 0;
}
  8022d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d8:	c9                   	leave  
  8022d9:	c3                   	ret    

008022da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022da:	55                   	push   %ebp
  8022db:	89 e5                	mov    %esp,%ebp
  8022dd:	57                   	push   %edi
  8022de:	56                   	push   %esi
  8022df:	53                   	push   %ebx
  8022e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e6:	be 00 00 00 00       	mov    $0x0,%esi
  8022eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ef:	74 43                	je     802334 <devcons_write+0x5a>
  8022f1:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022ff:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802301:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802304:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802309:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80230c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802310:	03 45 0c             	add    0xc(%ebp),%eax
  802313:	89 44 24 04          	mov    %eax,0x4(%esp)
  802317:	89 3c 24             	mov    %edi,(%esp)
  80231a:	e8 bd ea ff ff       	call   800ddc <memmove>
		sys_cputs(buf, m);
  80231f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	e8 a5 ec ff ff       	call   800fd0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232b:	01 de                	add    %ebx,%esi
  80232d:	89 f0                	mov    %esi,%eax
  80232f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802332:	72 c8                	jb     8022fc <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802334:	89 f0                	mov    %esi,%eax
  802336:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80233c:	5b                   	pop    %ebx
  80233d:	5e                   	pop    %esi
  80233e:	5f                   	pop    %edi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  802347:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80234c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802350:	75 07                	jne    802359 <devcons_read+0x18>
  802352:	eb 31                	jmp    802385 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802354:	e8 63 ed ff ff       	call   8010bc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	e8 9a ec ff ff       	call   800fff <sys_cgetc>
  802365:	85 c0                	test   %eax,%eax
  802367:	74 eb                	je     802354 <devcons_read+0x13>
  802369:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80236b:	85 c0                	test   %eax,%eax
  80236d:	78 16                	js     802385 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80236f:	83 f8 04             	cmp    $0x4,%eax
  802372:	74 0c                	je     802380 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802374:	8b 45 0c             	mov    0xc(%ebp),%eax
  802377:	88 10                	mov    %dl,(%eax)
	return 1;
  802379:	b8 01 00 00 00       	mov    $0x1,%eax
  80237e:	eb 05                	jmp    802385 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802380:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802385:	c9                   	leave  
  802386:	c3                   	ret    

00802387 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80238d:	8b 45 08             	mov    0x8(%ebp),%eax
  802390:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802393:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80239a:	00 
  80239b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80239e:	89 04 24             	mov    %eax,(%esp)
  8023a1:	e8 2a ec ff ff       	call   800fd0 <sys_cputs>
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <getchar>:

int
getchar(void)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8023b5:	00 
  8023b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c4:	e8 d5 f4 ff ff       	call   80189e <read>
	if (r < 0)
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	78 0f                	js     8023dc <getchar+0x34>
		return r;
	if (r < 1)
  8023cd:	85 c0                	test   %eax,%eax
  8023cf:	7e 06                	jle    8023d7 <getchar+0x2f>
		return -E_EOF;
	return c;
  8023d1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023d5:	eb 05                	jmp    8023dc <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023d7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023dc:	c9                   	leave  
  8023dd:	c3                   	ret    

008023de <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023de:	55                   	push   %ebp
  8023df:	89 e5                	mov    %esp,%ebp
  8023e1:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ee:	89 04 24             	mov    %eax,(%esp)
  8023f1:	e8 e8 f1 ff ff       	call   8015de <fd_lookup>
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	78 11                	js     80240b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fd:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802403:	39 10                	cmp    %edx,(%eax)
  802405:	0f 94 c0             	sete   %al
  802408:	0f b6 c0             	movzbl %al,%eax
}
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    

0080240d <opencons>:

int
opencons(void)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802416:	89 04 24             	mov    %eax,(%esp)
  802419:	e8 4d f1 ff ff       	call   80156b <fd_alloc>
  80241e:	85 c0                	test   %eax,%eax
  802420:	78 3c                	js     80245e <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802422:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802429:	00 
  80242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802438:	e8 af ec ff ff       	call   8010ec <sys_page_alloc>
  80243d:	85 c0                	test   %eax,%eax
  80243f:	78 1d                	js     80245e <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802441:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802447:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80244c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802456:	89 04 24             	mov    %eax,(%esp)
  802459:	e8 e2 f0 ff ff       	call   801540 <fd2num>
}
  80245e:	c9                   	leave  
  80245f:	c3                   	ret    

00802460 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	56                   	push   %esi
  802464:	53                   	push   %ebx
  802465:	83 ec 10             	sub    $0x10,%esp
  802468:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80246b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80246e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802471:	85 db                	test   %ebx,%ebx
  802473:	74 06                	je     80247b <ipc_recv+0x1b>
  802475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80247b:	85 f6                	test   %esi,%esi
  80247d:	74 06                	je     802485 <ipc_recv+0x25>
  80247f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802485:	85 c0                	test   %eax,%eax
  802487:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80248c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80248f:	89 04 24             	mov    %eax,(%esp)
  802492:	e8 be ee ff ff       	call   801355 <sys_ipc_recv>
    if (ret) return ret;
  802497:	85 c0                	test   %eax,%eax
  802499:	75 24                	jne    8024bf <ipc_recv+0x5f>
    if (from_env_store)
  80249b:	85 db                	test   %ebx,%ebx
  80249d:	74 0a                	je     8024a9 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80249f:	a1 20 44 80 00       	mov    0x804420,%eax
  8024a4:	8b 40 74             	mov    0x74(%eax),%eax
  8024a7:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  8024a9:	85 f6                	test   %esi,%esi
  8024ab:	74 0a                	je     8024b7 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  8024ad:	a1 20 44 80 00       	mov    0x804420,%eax
  8024b2:	8b 40 78             	mov    0x78(%eax),%eax
  8024b5:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  8024b7:	a1 20 44 80 00       	mov    0x804420,%eax
  8024bc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024bf:	83 c4 10             	add    $0x10,%esp
  8024c2:	5b                   	pop    %ebx
  8024c3:	5e                   	pop    %esi
  8024c4:	5d                   	pop    %ebp
  8024c5:	c3                   	ret    

008024c6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	57                   	push   %edi
  8024ca:	56                   	push   %esi
  8024cb:	53                   	push   %ebx
  8024cc:	83 ec 1c             	sub    $0x1c,%esp
  8024cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8024d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8024d8:	85 db                	test   %ebx,%ebx
  8024da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024df:	0f 44 d8             	cmove  %eax,%ebx
  8024e2:	eb 2a                	jmp    80250e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8024e4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024e7:	74 20                	je     802509 <ipc_send+0x43>
  8024e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ed:	c7 44 24 08 7a 2d 80 	movl   $0x802d7a,0x8(%esp)
  8024f4:	00 
  8024f5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8024fc:	00 
  8024fd:	c7 04 24 91 2d 80 00 	movl   $0x802d91,(%esp)
  802504:	e8 9f de ff ff       	call   8003a8 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802509:	e8 ae eb ff ff       	call   8010bc <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80250e:	8b 45 14             	mov    0x14(%ebp),%eax
  802511:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802515:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80251d:	89 34 24             	mov    %esi,(%esp)
  802520:	e8 fc ed ff ff       	call   801321 <sys_ipc_try_send>
  802525:	85 c0                	test   %eax,%eax
  802527:	75 bb                	jne    8024e4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  802529:	83 c4 1c             	add    $0x1c,%esp
  80252c:	5b                   	pop    %ebx
  80252d:	5e                   	pop    %esi
  80252e:	5f                   	pop    %edi
  80252f:	5d                   	pop    %ebp
  802530:	c3                   	ret    

00802531 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802531:	55                   	push   %ebp
  802532:	89 e5                	mov    %esp,%ebp
  802534:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802537:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80253c:	39 c8                	cmp    %ecx,%eax
  80253e:	74 19                	je     802559 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802540:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802545:	89 c2                	mov    %eax,%edx
  802547:	c1 e2 07             	shl    $0x7,%edx
  80254a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802550:	8b 52 50             	mov    0x50(%edx),%edx
  802553:	39 ca                	cmp    %ecx,%edx
  802555:	75 14                	jne    80256b <ipc_find_env+0x3a>
  802557:	eb 05                	jmp    80255e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802559:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80255e:	c1 e0 07             	shl    $0x7,%eax
  802561:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802566:	8b 40 40             	mov    0x40(%eax),%eax
  802569:	eb 0e                	jmp    802579 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80256b:	83 c0 01             	add    $0x1,%eax
  80256e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802573:	75 d0                	jne    802545 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802575:	66 b8 00 00          	mov    $0x0,%ax
}
  802579:	5d                   	pop    %ebp
  80257a:	c3                   	ret    
	...

0080257c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80257c:	55                   	push   %ebp
  80257d:	89 e5                	mov    %esp,%ebp
  80257f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802582:	89 d0                	mov    %edx,%eax
  802584:	c1 e8 16             	shr    $0x16,%eax
  802587:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80258e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802593:	f6 c1 01             	test   $0x1,%cl
  802596:	74 1d                	je     8025b5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802598:	c1 ea 0c             	shr    $0xc,%edx
  80259b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025a2:	f6 c2 01             	test   $0x1,%dl
  8025a5:	74 0e                	je     8025b5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025a7:	c1 ea 0c             	shr    $0xc,%edx
  8025aa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025b1:	ef 
  8025b2:	0f b7 c0             	movzwl %ax,%eax
}
  8025b5:	5d                   	pop    %ebp
  8025b6:	c3                   	ret    
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
