
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 6e 00 00 00       	call   8000bc <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 11 01 00 00       	call   800178 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a6:	e8 43 06 00 00       	call   8006ee <close_all>
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 64 00 00 00       	call   80011b <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800104:	89 d1                	mov    %edx,%ecx
  800106:	89 d3                	mov    %edx,%ebx
  800108:	89 d7                	mov    %edx,%edi
  80010a:	89 d6                	mov    %edx,%esi
  80010c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800111:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800114:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800117:	89 ec                	mov    %ebp,%esp
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 38             	sub    $0x38,%esp
  800121:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800124:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800127:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	b8 03 00 00 00       	mov    $0x3,%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	89 cb                	mov    %ecx,%ebx
  800139:	89 cf                	mov    %ecx,%edi
  80013b:	89 ce                	mov    %ecx,%esi
  80013d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013f:	85 c0                	test   %eax,%eax
  800141:	7e 28                	jle    80016b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800143:	89 44 24 10          	mov    %eax,0x10(%esp)
  800147:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014e:	00 
  80014f:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800166:	e8 55 11 00 00       	call   8012c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800171:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800174:	89 ec                	mov    %ebp,%esp
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800181:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800184:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800187:	ba 00 00 00 00       	mov    $0x0,%edx
  80018c:	b8 02 00 00 00       	mov    $0x2,%eax
  800191:	89 d1                	mov    %edx,%ecx
  800193:	89 d3                	mov    %edx,%ebx
  800195:	89 d7                	mov    %edx,%edi
  800197:	89 d6                	mov    %edx,%esi
  800199:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a4:	89 ec                	mov    %ebp,%esp
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <sys_yield>:

void
sys_yield(void)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001b1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c1:	89 d1                	mov    %edx,%ecx
  8001c3:	89 d3                	mov    %edx,%ebx
  8001c5:	89 d7                	mov    %edx,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001cb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ce:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d4:	89 ec                	mov    %ebp,%esp
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 38             	sub    $0x38,%esp
  8001de:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e7:	be 00 00 00 00       	mov    $0x0,%esi
  8001ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	89 f7                	mov    %esi,%edi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 28                	jle    80022a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	89 44 24 10          	mov    %eax,0x10(%esp)
  800206:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80020d:	00 
  80020e:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  800215:	00 
  800216:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021d:	00 
  80021e:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800225:	e8 96 10 00 00       	call   8012c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80022d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800230:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800233:	89 ec                	mov    %ebp,%esp
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 38             	sub    $0x38,%esp
  80023d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800240:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800243:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800246:	b8 05 00 00 00       	mov    $0x5,%eax
  80024b:	8b 75 18             	mov    0x18(%ebp),%esi
  80024e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800251:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800257:	8b 55 08             	mov    0x8(%ebp),%edx
  80025a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025c:	85 c0                	test   %eax,%eax
  80025e:	7e 28                	jle    800288 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800260:	89 44 24 10          	mov    %eax,0x10(%esp)
  800264:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80026b:	00 
  80026c:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  800273:	00 
  800274:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027b:	00 
  80027c:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800283:	e8 38 10 00 00       	call   8012c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800288:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80028e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800291:	89 ec                	mov    %ebp,%esp
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 38             	sub    $0x38,%esp
  80029b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80029e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	b8 06 00 00 00       	mov    $0x6,%eax
  8002ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	89 df                	mov    %ebx,%edi
  8002b6:	89 de                	mov    %ebx,%esi
  8002b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ba:	85 c0                	test   %eax,%eax
  8002bc:	7e 28                	jle    8002e6 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d9:	00 
  8002da:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  8002e1:	e8 da 0f 00 00       	call   8012c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002e6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002ec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002ef:	89 ec                	mov    %ebp,%esp
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 38             	sub    $0x38,%esp
  8002f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800302:	bb 00 00 00 00       	mov    $0x0,%ebx
  800307:	b8 08 00 00 00       	mov    $0x8,%eax
  80030c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030f:	8b 55 08             	mov    0x8(%ebp),%edx
  800312:	89 df                	mov    %ebx,%edi
  800314:	89 de                	mov    %ebx,%esi
  800316:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800318:	85 c0                	test   %eax,%eax
  80031a:	7e 28                	jle    800344 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800320:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800327:	00 
  800328:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  80032f:	00 
  800330:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800337:	00 
  800338:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80033f:	e8 7c 0f 00 00       	call   8012c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800344:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800347:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80034d:	89 ec                	mov    %ebp,%esp
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 38             	sub    $0x38,%esp
  800357:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80035d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800360:	bb 00 00 00 00       	mov    $0x0,%ebx
  800365:	b8 09 00 00 00       	mov    $0x9,%eax
  80036a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	89 df                	mov    %ebx,%edi
  800372:	89 de                	mov    %ebx,%esi
  800374:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800376:	85 c0                	test   %eax,%eax
  800378:	7e 28                	jle    8003a2 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800385:	00 
  800386:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  80038d:	00 
  80038e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800395:	00 
  800396:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80039d:	e8 1e 0f 00 00       	call   8012c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003a2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003ab:	89 ec                	mov    %ebp,%esp
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	83 ec 38             	sub    $0x38,%esp
  8003b5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ce:	89 df                	mov    %ebx,%edi
  8003d0:	89 de                	mov    %ebx,%esi
  8003d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	7e 28                	jle    800400 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003dc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003e3:	00 
  8003e4:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  8003eb:	00 
  8003ec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f3:	00 
  8003f4:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  8003fb:	e8 c0 0e 00 00       	call   8012c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800400:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800403:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800406:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800409:	89 ec                	mov    %ebp,%esp
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	83 ec 0c             	sub    $0xc,%esp
  800413:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800416:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800419:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041c:	be 00 00 00 00       	mov    $0x0,%esi
  800421:	b8 0c 00 00 00       	mov    $0xc,%eax
  800426:	8b 7d 14             	mov    0x14(%ebp),%edi
  800429:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80042c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042f:	8b 55 08             	mov    0x8(%ebp),%edx
  800432:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800434:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800437:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80043d:	89 ec                	mov    %ebp,%esp
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	83 ec 38             	sub    $0x38,%esp
  800447:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80044a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80044d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800450:	b9 00 00 00 00       	mov    $0x0,%ecx
  800455:	b8 0d 00 00 00       	mov    $0xd,%eax
  80045a:	8b 55 08             	mov    0x8(%ebp),%edx
  80045d:	89 cb                	mov    %ecx,%ebx
  80045f:	89 cf                	mov    %ecx,%edi
  800461:	89 ce                	mov    %ecx,%esi
  800463:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800465:	85 c0                	test   %eax,%eax
  800467:	7e 28                	jle    800491 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800469:	89 44 24 10          	mov    %eax,0x10(%esp)
  80046d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800474:	00 
  800475:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  80047c:	00 
  80047d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800484:	00 
  800485:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80048c:	e8 2f 0e 00 00       	call   8012c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800491:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800494:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800497:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80049a:	89 ec                	mov    %ebp,%esp
  80049c:	5d                   	pop    %ebp
  80049d:	c3                   	ret    

0080049e <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004a7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004aa:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8004b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ba:	89 cb                	mov    %ecx,%ebx
  8004bc:	89 cf                	mov    %ecx,%edi
  8004be:	89 ce                	mov    %ecx,%esi
  8004c0:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8004c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004cb:	89 ec                	mov    %ebp,%esp
  8004cd:	5d                   	pop    %ebp
  8004ce:	c3                   	ret    
	...

008004d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004db:	c1 e8 0c             	shr    $0xc,%eax
}
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 df ff ff ff       	call   8004d0 <fd2num>
  8004f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8004f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	53                   	push   %ebx
  8004ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800502:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800507:	a8 01                	test   $0x1,%al
  800509:	74 34                	je     80053f <fd_alloc+0x44>
  80050b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800510:	a8 01                	test   $0x1,%al
  800512:	74 32                	je     800546 <fd_alloc+0x4b>
  800514:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800519:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80051b:	89 c2                	mov    %eax,%edx
  80051d:	c1 ea 16             	shr    $0x16,%edx
  800520:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800527:	f6 c2 01             	test   $0x1,%dl
  80052a:	74 1f                	je     80054b <fd_alloc+0x50>
  80052c:	89 c2                	mov    %eax,%edx
  80052e:	c1 ea 0c             	shr    $0xc,%edx
  800531:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800538:	f6 c2 01             	test   $0x1,%dl
  80053b:	75 17                	jne    800554 <fd_alloc+0x59>
  80053d:	eb 0c                	jmp    80054b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80053f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800544:	eb 05                	jmp    80054b <fd_alloc+0x50>
  800546:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80054b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80054d:	b8 00 00 00 00       	mov    $0x0,%eax
  800552:	eb 17                	jmp    80056b <fd_alloc+0x70>
  800554:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800559:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80055e:	75 b9                	jne    800519 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800560:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800566:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80056b:	5b                   	pop    %ebx
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800579:	83 fa 1f             	cmp    $0x1f,%edx
  80057c:	77 3f                	ja     8005bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80057e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  800584:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800587:	89 d0                	mov    %edx,%eax
  800589:	c1 e8 16             	shr    $0x16,%eax
  80058c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800593:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800598:	f6 c1 01             	test   $0x1,%cl
  80059b:	74 20                	je     8005bd <fd_lookup+0x4f>
  80059d:	89 d0                	mov    %edx,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8005a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8005ae:	f6 c1 01             	test   $0x1,%cl
  8005b1:	74 0a                	je     8005bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8005b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 14             	sub    $0x14,%esp
  8005c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8005cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8005d1:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8005d7:	75 17                	jne    8005f0 <dev_lookup+0x31>
  8005d9:	eb 07                	jmp    8005e2 <dev_lookup+0x23>
  8005db:	39 0a                	cmp    %ecx,(%edx)
  8005dd:	75 11                	jne    8005f0 <dev_lookup+0x31>
  8005df:	90                   	nop
  8005e0:	eb 05                	jmp    8005e7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005e2:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8005e7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8005e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ee:	eb 35                	jmp    800625 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005f0:	83 c0 01             	add    $0x1,%eax
  8005f3:	8b 14 85 b4 23 80 00 	mov    0x8023b4(,%eax,4),%edx
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	75 dd                	jne    8005db <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005fe:	a1 04 40 80 00       	mov    0x804004,%eax
  800603:	8b 40 48             	mov    0x48(%eax),%eax
  800606:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	c7 04 24 38 23 80 00 	movl   $0x802338,(%esp)
  800615:	e8 a1 0d 00 00       	call   8013bb <cprintf>
	*dev = 0;
  80061a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800620:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800625:	83 c4 14             	add    $0x14,%esp
  800628:	5b                   	pop    %ebx
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	83 ec 38             	sub    $0x38,%esp
  800631:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800634:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800637:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80063a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80063d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800641:	89 3c 24             	mov    %edi,(%esp)
  800644:	e8 87 fe ff ff       	call   8004d0 <fd2num>
  800649:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80064c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	e8 16 ff ff ff       	call   80056e <fd_lookup>
  800658:	89 c3                	mov    %eax,%ebx
  80065a:	85 c0                	test   %eax,%eax
  80065c:	78 05                	js     800663 <fd_close+0x38>
	    || fd != fd2)
  80065e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800661:	74 0e                	je     800671 <fd_close+0x46>
		return (must_exist ? r : 0);
  800663:	89 f0                	mov    %esi,%eax
  800665:	84 c0                	test   %al,%al
  800667:	b8 00 00 00 00       	mov    $0x0,%eax
  80066c:	0f 44 d8             	cmove  %eax,%ebx
  80066f:	eb 3d                	jmp    8006ae <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800671:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800674:	89 44 24 04          	mov    %eax,0x4(%esp)
  800678:	8b 07                	mov    (%edi),%eax
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	e8 3d ff ff ff       	call   8005bf <dev_lookup>
  800682:	89 c3                	mov    %eax,%ebx
  800684:	85 c0                	test   %eax,%eax
  800686:	78 16                	js     80069e <fd_close+0x73>
		if (dev->dev_close)
  800688:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80068e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800693:	85 c0                	test   %eax,%eax
  800695:	74 07                	je     80069e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  800697:	89 3c 24             	mov    %edi,(%esp)
  80069a:	ff d0                	call   *%eax
  80069c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80069e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a9:	e8 e7 fb ff ff       	call   800295 <sys_page_unmap>
	return r;
}
  8006ae:	89 d8                	mov    %ebx,%eax
  8006b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006b9:	89 ec                	mov    %ebp,%esp
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 99 fe ff ff       	call   80056e <fd_lookup>
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	78 13                	js     8006ec <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8006d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8006e0:	00 
  8006e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	e8 3f ff ff ff       	call   80062b <fd_close>
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <close_all>:

void
close_all(void)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8006f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8006fa:	89 1c 24             	mov    %ebx,(%esp)
  8006fd:	e8 bb ff ff ff       	call   8006bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800702:	83 c3 01             	add    $0x1,%ebx
  800705:	83 fb 20             	cmp    $0x20,%ebx
  800708:	75 f0                	jne    8006fa <close_all+0xc>
		close(i);
}
  80070a:	83 c4 14             	add    $0x14,%esp
  80070d:	5b                   	pop    %ebx
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 58             	sub    $0x58,%esp
  800716:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800719:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80071c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80071f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800722:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	e8 3a fe ff ff       	call   80056e <fd_lookup>
  800734:	89 c3                	mov    %eax,%ebx
  800736:	85 c0                	test   %eax,%eax
  800738:	0f 88 e1 00 00 00    	js     80081f <dup+0x10f>
		return r;
	close(newfdnum);
  80073e:	89 3c 24             	mov    %edi,(%esp)
  800741:	e8 77 ff ff ff       	call   8006bd <close>

	newfd = INDEX2FD(newfdnum);
  800746:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80074c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80074f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800752:	89 04 24             	mov    %eax,(%esp)
  800755:	e8 86 fd ff ff       	call   8004e0 <fd2data>
  80075a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80075c:	89 34 24             	mov    %esi,(%esp)
  80075f:	e8 7c fd ff ff       	call   8004e0 <fd2data>
  800764:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800767:	89 d8                	mov    %ebx,%eax
  800769:	c1 e8 16             	shr    $0x16,%eax
  80076c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800773:	a8 01                	test   $0x1,%al
  800775:	74 46                	je     8007bd <dup+0xad>
  800777:	89 d8                	mov    %ebx,%eax
  800779:	c1 e8 0c             	shr    $0xc,%eax
  80077c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800783:	f6 c2 01             	test   $0x1,%dl
  800786:	74 35                	je     8007bd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800788:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80078f:	25 07 0e 00 00       	and    $0xe07,%eax
  800794:	89 44 24 10          	mov    %eax,0x10(%esp)
  800798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80079b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007a6:	00 
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007b2:	e8 80 fa ff ff       	call   800237 <sys_page_map>
  8007b7:	89 c3                	mov    %eax,%ebx
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	78 3b                	js     8007f8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	c1 ea 0c             	shr    $0xc,%edx
  8007c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8007d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007e1:	00 
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007ed:	e8 45 fa ff ff       	call   800237 <sys_page_map>
  8007f2:	89 c3                	mov    %eax,%ebx
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	79 25                	jns    80081d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8007f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800803:	e8 8d fa ff ff       	call   800295 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800808:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80080b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800816:	e8 7a fa ff ff       	call   800295 <sys_page_unmap>
	return r;
  80081b:	eb 02                	jmp    80081f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80081d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800824:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800827:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80082a:	89 ec                	mov    %ebp,%esp
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	83 ec 24             	sub    $0x24,%esp
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083f:	89 1c 24             	mov    %ebx,(%esp)
  800842:	e8 27 fd ff ff       	call   80056e <fd_lookup>
  800847:	85 c0                	test   %eax,%eax
  800849:	78 6d                	js     8008b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800855:	8b 00                	mov    (%eax),%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 60 fd ff ff       	call   8005bf <dev_lookup>
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 55                	js     8008b8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800866:	8b 50 08             	mov    0x8(%eax),%edx
  800869:	83 e2 03             	and    $0x3,%edx
  80086c:	83 fa 01             	cmp    $0x1,%edx
  80086f:	75 23                	jne    800894 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800871:	a1 04 40 80 00       	mov    0x804004,%eax
  800876:	8b 40 48             	mov    0x48(%eax),%eax
  800879:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80087d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800881:	c7 04 24 79 23 80 00 	movl   $0x802379,(%esp)
  800888:	e8 2e 0b 00 00       	call   8013bb <cprintf>
		return -E_INVAL;
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800892:	eb 24                	jmp    8008b8 <read+0x8a>
	}
	if (!dev->dev_read)
  800894:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800897:	8b 52 08             	mov    0x8(%edx),%edx
  80089a:	85 d2                	test   %edx,%edx
  80089c:	74 15                	je     8008b3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	ff d2                	call   *%edx
  8008b1:	eb 05                	jmp    8008b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8008b8:	83 c4 24             	add    $0x24,%esp
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	83 ec 1c             	sub    $0x1c,%esp
  8008c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	85 f6                	test   %esi,%esi
  8008d4:	74 30                	je     800906 <readn+0x48>
  8008d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008db:	89 f2                	mov    %esi,%edx
  8008dd:	29 c2                	sub    %eax,%edx
  8008df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008e3:	03 45 0c             	add    0xc(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	89 3c 24             	mov    %edi,(%esp)
  8008ed:	e8 3c ff ff ff       	call   80082e <read>
		if (m < 0)
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	78 10                	js     800906 <readn+0x48>
			return m;
		if (m == 0)
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	74 0a                	je     800904 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008fa:	01 c3                	add    %eax,%ebx
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	39 f3                	cmp    %esi,%ebx
  800900:	72 d9                	jb     8008db <readn+0x1d>
  800902:	eb 02                	jmp    800906 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800904:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800906:	83 c4 1c             	add    $0x1c,%esp
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5f                   	pop    %edi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	83 ec 24             	sub    $0x24,%esp
  800915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800918:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80091b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091f:	89 1c 24             	mov    %ebx,(%esp)
  800922:	e8 47 fc ff ff       	call   80056e <fd_lookup>
  800927:	85 c0                	test   %eax,%eax
  800929:	78 68                	js     800993 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80092b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800935:	8b 00                	mov    (%eax),%eax
  800937:	89 04 24             	mov    %eax,(%esp)
  80093a:	e8 80 fc ff ff       	call   8005bf <dev_lookup>
  80093f:	85 c0                	test   %eax,%eax
  800941:	78 50                	js     800993 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800946:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80094a:	75 23                	jne    80096f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80094c:	a1 04 40 80 00       	mov    0x804004,%eax
  800951:	8b 40 48             	mov    0x48(%eax),%eax
  800954:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095c:	c7 04 24 95 23 80 00 	movl   $0x802395,(%esp)
  800963:	e8 53 0a 00 00       	call   8013bb <cprintf>
		return -E_INVAL;
  800968:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096d:	eb 24                	jmp    800993 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80096f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800972:	8b 52 0c             	mov    0xc(%edx),%edx
  800975:	85 d2                	test   %edx,%edx
  800977:	74 15                	je     80098e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80097c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800983:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	ff d2                	call   *%edx
  80098c:	eb 05                	jmp    800993 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80098e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800993:	83 c4 24             	add    $0x24,%esp
  800996:	5b                   	pop    %ebx
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <seek>:

int
seek(int fdnum, off_t offset)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80099f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 bd fb ff ff       	call   80056e <fd_lookup>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 0e                	js     8009c3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	83 ec 24             	sub    $0x24,%esp
  8009cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d6:	89 1c 24             	mov    %ebx,(%esp)
  8009d9:	e8 90 fb ff ff       	call   80056e <fd_lookup>
  8009de:	85 c0                	test   %eax,%eax
  8009e0:	78 61                	js     800a43 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ec:	8b 00                	mov    (%eax),%eax
  8009ee:	89 04 24             	mov    %eax,(%esp)
  8009f1:	e8 c9 fb ff ff       	call   8005bf <dev_lookup>
  8009f6:	85 c0                	test   %eax,%eax
  8009f8:	78 49                	js     800a43 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a01:	75 23                	jne    800a26 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a03:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a08:	8b 40 48             	mov    0x48(%eax),%eax
  800a0b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a13:	c7 04 24 58 23 80 00 	movl   $0x802358,(%esp)
  800a1a:	e8 9c 09 00 00       	call   8013bb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a24:	eb 1d                	jmp    800a43 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a29:	8b 52 18             	mov    0x18(%edx),%edx
  800a2c:	85 d2                	test   %edx,%edx
  800a2e:	74 0e                	je     800a3e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a37:	89 04 24             	mov    %eax,(%esp)
  800a3a:	ff d2                	call   *%edx
  800a3c:	eb 05                	jmp    800a43 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a43:	83 c4 24             	add    $0x24,%esp
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	53                   	push   %ebx
  800a4d:	83 ec 24             	sub    $0x24,%esp
  800a50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	89 04 24             	mov    %eax,(%esp)
  800a60:	e8 09 fb ff ff       	call   80056e <fd_lookup>
  800a65:	85 c0                	test   %eax,%eax
  800a67:	78 52                	js     800abb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a73:	8b 00                	mov    (%eax),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 42 fb ff ff       	call   8005bf <dev_lookup>
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	78 3a                	js     800abb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a84:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a88:	74 2c                	je     800ab6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a8a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a8d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a94:	00 00 00 
	stat->st_isdir = 0;
  800a97:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a9e:	00 00 00 
	stat->st_dev = dev;
  800aa1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800aa7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800aae:	89 14 24             	mov    %edx,(%esp)
  800ab1:	ff 50 14             	call   *0x14(%eax)
  800ab4:	eb 05                	jmp    800abb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ab6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800abb:	83 c4 24             	add    $0x24,%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 18             	sub    $0x18,%esp
  800ac7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800aca:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800acd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ad4:	00 
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	89 04 24             	mov    %eax,(%esp)
  800adb:	e8 bc 01 00 00       	call   800c9c <open>
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	78 1b                	js     800b01 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aed:	89 1c 24             	mov    %ebx,(%esp)
  800af0:	e8 54 ff ff ff       	call   800a49 <fstat>
  800af5:	89 c6                	mov    %eax,%esi
	close(fd);
  800af7:	89 1c 24             	mov    %ebx,(%esp)
  800afa:	e8 be fb ff ff       	call   8006bd <close>
	return r;
  800aff:	89 f3                	mov    %esi,%ebx
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b09:	89 ec                	mov    %ebp,%esp
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
  800b0d:	00 00                	add    %al,(%eax)
	...

00800b10 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	83 ec 18             	sub    $0x18,%esp
  800b16:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b19:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b1c:	89 c3                	mov    %eax,%ebx
  800b1e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b20:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b27:	75 11                	jne    800b3a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b30:	e8 8c 14 00 00       	call   801fc1 <ipc_find_env>
  800b35:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b3a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b41:	00 
  800b42:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b49:	00 
  800b4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b4e:	a1 00 40 80 00       	mov    0x804000,%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 fb 13 00 00       	call   801f56 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  800b5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b62:	00 
  800b63:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b6e:	e8 7d 13 00 00       	call   801ef0 <ipc_recv>
}
  800b73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b79:	89 ec                	mov    %ebp,%esp
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	53                   	push   %ebx
  800b81:	83 ec 14             	sub    $0x14,%esp
  800b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 40 0c             	mov    0xc(%eax),%eax
  800b8d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9c:	e8 6f ff ff ff       	call   800b10 <fsipc>
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	78 2b                	js     800bd0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ba5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bac:	00 
  800bad:	89 1c 24             	mov    %ebx,(%esp)
  800bb0:	e8 56 0f 00 00       	call   801b0b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800bb5:	a1 80 50 80 00       	mov    0x805080,%eax
  800bba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bc0:	a1 84 50 80 00       	mov    0x805084,%eax
  800bc5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd0:	83 c4 14             	add    $0x14,%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8b 40 0c             	mov    0xc(%eax),%eax
  800be2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf1:	e8 1a ff ff ff       	call   800b10 <fsipc>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 10             	sub    $0x10,%esp
  800c00:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	8b 40 0c             	mov    0xc(%eax),%eax
  800c09:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800c0e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1e:	e8 ed fe ff ff       	call   800b10 <fsipc>
  800c23:	89 c3                	mov    %eax,%ebx
  800c25:	85 c0                	test   %eax,%eax
  800c27:	78 6a                	js     800c93 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c29:	39 c6                	cmp    %eax,%esi
  800c2b:	73 24                	jae    800c51 <devfile_read+0x59>
  800c2d:	c7 44 24 0c c4 23 80 	movl   $0x8023c4,0xc(%esp)
  800c34:	00 
  800c35:	c7 44 24 08 cb 23 80 	movl   $0x8023cb,0x8(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800c44:	00 
  800c45:	c7 04 24 e0 23 80 00 	movl   $0x8023e0,(%esp)
  800c4c:	e8 6f 06 00 00       	call   8012c0 <_panic>
	assert(r <= PGSIZE);
  800c51:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c56:	7e 24                	jle    800c7c <devfile_read+0x84>
  800c58:	c7 44 24 0c eb 23 80 	movl   $0x8023eb,0xc(%esp)
  800c5f:	00 
  800c60:	c7 44 24 08 cb 23 80 	movl   $0x8023cb,0x8(%esp)
  800c67:	00 
  800c68:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c6f:	00 
  800c70:	c7 04 24 e0 23 80 00 	movl   $0x8023e0,(%esp)
  800c77:	e8 44 06 00 00       	call   8012c0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800c7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c80:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c87:	00 
  800c88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8b:	89 04 24             	mov    %eax,(%esp)
  800c8e:	e8 69 10 00 00       	call   801cfc <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  800c93:	89 d8                	mov    %ebx,%eax
  800c95:	83 c4 10             	add    $0x10,%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 20             	sub    $0x20,%esp
  800ca4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ca7:	89 34 24             	mov    %esi,(%esp)
  800caa:	e8 11 0e 00 00       	call   801ac0 <strlen>
		return -E_BAD_PATH;
  800caf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800cb4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cb9:	7f 5e                	jg     800d19 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cbe:	89 04 24             	mov    %eax,(%esp)
  800cc1:	e8 35 f8 ff ff       	call   8004fb <fd_alloc>
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	78 4d                	js     800d19 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ccc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cd0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cd7:	e8 2f 0e 00 00       	call   801b0b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cec:	e8 1f fe ff ff       	call   800b10 <fsipc>
  800cf1:	89 c3                	mov    %eax,%ebx
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	79 15                	jns    800d0c <open+0x70>
		fd_close(fd, 0);
  800cf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cfe:	00 
  800cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 21 f9 ff ff       	call   80062b <fd_close>
		return r;
  800d0a:	eb 0d                	jmp    800d19 <open+0x7d>
	}

	return fd2num(fd);
  800d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d0f:	89 04 24             	mov    %eax,(%esp)
  800d12:	e8 b9 f7 ff ff       	call   8004d0 <fd2num>
  800d17:	89 c3                	mov    %eax,%ebx
}
  800d19:	89 d8                	mov    %ebx,%eax
  800d1b:	83 c4 20             	add    $0x20,%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
	...

00800d30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 18             	sub    $0x18,%esp
  800d36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d39:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d3c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	89 04 24             	mov    %eax,(%esp)
  800d45:	e8 96 f7 ff ff       	call   8004e0 <fd2data>
  800d4a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d4c:	c7 44 24 04 f7 23 80 	movl   $0x8023f7,0x4(%esp)
  800d53:	00 
  800d54:	89 34 24             	mov    %esi,(%esp)
  800d57:	e8 af 0d 00 00       	call   801b0b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d5c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d5f:	2b 03                	sub    (%ebx),%eax
  800d61:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d67:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d6e:	00 00 00 
	stat->st_dev = &devpipe;
  800d71:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d78:	30 80 00 
	return 0;
}
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d83:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d86:	89 ec                	mov    %ebp,%esp
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 14             	sub    $0x14,%esp
  800d91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d9f:	e8 f1 f4 ff ff       	call   800295 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800da4:	89 1c 24             	mov    %ebx,(%esp)
  800da7:	e8 34 f7 ff ff       	call   8004e0 <fd2data>
  800dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800db7:	e8 d9 f4 ff ff       	call   800295 <sys_page_unmap>
}
  800dbc:	83 c4 14             	add    $0x14,%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 2c             	sub    $0x2c,%esp
  800dcb:	89 c7                	mov    %eax,%edi
  800dcd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800dd0:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800dd8:	89 3c 24             	mov    %edi,(%esp)
  800ddb:	e8 2c 12 00 00       	call   80200c <pageref>
  800de0:	89 c6                	mov    %eax,%esi
  800de2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de5:	89 04 24             	mov    %eax,(%esp)
  800de8:	e8 1f 12 00 00       	call   80200c <pageref>
  800ded:	39 c6                	cmp    %eax,%esi
  800def:	0f 94 c0             	sete   %al
  800df2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800df5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800dfb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800dfe:	39 cb                	cmp    %ecx,%ebx
  800e00:	75 08                	jne    800e0a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800e0a:	83 f8 01             	cmp    $0x1,%eax
  800e0d:	75 c1                	jne    800dd0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800e0f:	8b 52 58             	mov    0x58(%edx),%edx
  800e12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e16:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e1e:	c7 04 24 fe 23 80 00 	movl   $0x8023fe,(%esp)
  800e25:	e8 91 05 00 00       	call   8013bb <cprintf>
  800e2a:	eb a4                	jmp    800dd0 <_pipeisclosed+0xe>

00800e2c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 2c             	sub    $0x2c,%esp
  800e35:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800e38:	89 34 24             	mov    %esi,(%esp)
  800e3b:	e8 a0 f6 ff ff       	call   8004e0 <fd2data>
  800e40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e42:	bf 00 00 00 00       	mov    $0x0,%edi
  800e47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e4b:	75 50                	jne    800e9d <devpipe_write+0x71>
  800e4d:	eb 5c                	jmp    800eab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e4f:	89 da                	mov    %ebx,%edx
  800e51:	89 f0                	mov    %esi,%eax
  800e53:	e8 6a ff ff ff       	call   800dc2 <_pipeisclosed>
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	75 53                	jne    800eaf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e5c:	e8 47 f3 ff ff       	call   8001a8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e61:	8b 43 04             	mov    0x4(%ebx),%eax
  800e64:	8b 13                	mov    (%ebx),%edx
  800e66:	83 c2 20             	add    $0x20,%edx
  800e69:	39 d0                	cmp    %edx,%eax
  800e6b:	73 e2                	jae    800e4f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e70:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  800e74:	88 55 e7             	mov    %dl,-0x19(%ebp)
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	c1 fa 1f             	sar    $0x1f,%edx
  800e7c:	c1 ea 1b             	shr    $0x1b,%edx
  800e7f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800e82:	83 e1 1f             	and    $0x1f,%ecx
  800e85:	29 d1                	sub    %edx,%ecx
  800e87:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800e8b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800e8f:	83 c0 01             	add    $0x1,%eax
  800e92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e95:	83 c7 01             	add    $0x1,%edi
  800e98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e9b:	74 0e                	je     800eab <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e9d:	8b 43 04             	mov    0x4(%ebx),%eax
  800ea0:	8b 13                	mov    (%ebx),%edx
  800ea2:	83 c2 20             	add    $0x20,%edx
  800ea5:	39 d0                	cmp    %edx,%eax
  800ea7:	73 a6                	jae    800e4f <devpipe_write+0x23>
  800ea9:	eb c2                	jmp    800e6d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800eab:	89 f8                	mov    %edi,%eax
  800ead:	eb 05                	jmp    800eb4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800eb4:	83 c4 2c             	add    $0x2c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 28             	sub    $0x28,%esp
  800ec2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ecb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ece:	89 3c 24             	mov    %edi,(%esp)
  800ed1:	e8 0a f6 ff ff       	call   8004e0 <fd2data>
  800ed6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ed8:	be 00 00 00 00       	mov    $0x0,%esi
  800edd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ee1:	75 47                	jne    800f2a <devpipe_read+0x6e>
  800ee3:	eb 52                	jmp    800f37 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800ee5:	89 f0                	mov    %esi,%eax
  800ee7:	eb 5e                	jmp    800f47 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ee9:	89 da                	mov    %ebx,%edx
  800eeb:	89 f8                	mov    %edi,%eax
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
  800ef0:	e8 cd fe ff ff       	call   800dc2 <_pipeisclosed>
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 49                	jne    800f42 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  800ef9:	e8 aa f2 ff ff       	call   8001a8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800efe:	8b 03                	mov    (%ebx),%eax
  800f00:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f03:	74 e4                	je     800ee9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800f05:	89 c2                	mov    %eax,%edx
  800f07:	c1 fa 1f             	sar    $0x1f,%edx
  800f0a:	c1 ea 1b             	shr    $0x1b,%edx
  800f0d:	01 d0                	add    %edx,%eax
  800f0f:	83 e0 1f             	and    $0x1f,%eax
  800f12:	29 d0                	sub    %edx,%eax
  800f14:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800f19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800f1f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800f22:	83 c6 01             	add    $0x1,%esi
  800f25:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f28:	74 0d                	je     800f37 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  800f2a:	8b 03                	mov    (%ebx),%eax
  800f2c:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f2f:	75 d4                	jne    800f05 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800f31:	85 f6                	test   %esi,%esi
  800f33:	75 b0                	jne    800ee5 <devpipe_read+0x29>
  800f35:	eb b2                	jmp    800ee9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	eb 05                	jmp    800f47 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800f42:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800f47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f50:	89 ec                	mov    %ebp,%esp
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 48             	sub    $0x48,%esp
  800f5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f60:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f63:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800f66:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f69:	89 04 24             	mov    %eax,(%esp)
  800f6c:	e8 8a f5 ff ff       	call   8004fb <fd_alloc>
  800f71:	89 c3                	mov    %eax,%ebx
  800f73:	85 c0                	test   %eax,%eax
  800f75:	0f 88 45 01 00 00    	js     8010c0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f7b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f82:	00 
  800f83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f91:	e8 42 f2 ff ff       	call   8001d8 <sys_page_alloc>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	0f 88 20 01 00 00    	js     8010c0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800fa0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fa3:	89 04 24             	mov    %eax,(%esp)
  800fa6:	e8 50 f5 ff ff       	call   8004fb <fd_alloc>
  800fab:	89 c3                	mov    %eax,%ebx
  800fad:	85 c0                	test   %eax,%eax
  800faf:	0f 88 f8 00 00 00    	js     8010ad <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fb5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fbc:	00 
  800fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fcb:	e8 08 f2 ff ff       	call   8001d8 <sys_page_alloc>
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	0f 88 d3 00 00 00    	js     8010ad <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800fda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	e8 fb f4 ff ff       	call   8004e0 <fd2data>
  800fe5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fe7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fee:	00 
  800fef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffa:	e8 d9 f1 ff ff       	call   8001d8 <sys_page_alloc>
  800fff:	89 c3                	mov    %eax,%ebx
  801001:	85 c0                	test   %eax,%eax
  801003:	0f 88 91 00 00 00    	js     80109a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801009:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100c:	89 04 24             	mov    %eax,(%esp)
  80100f:	e8 cc f4 ff ff       	call   8004e0 <fd2data>
  801014:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80101b:	00 
  80101c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801020:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801027:	00 
  801028:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801033:	e8 ff f1 ff ff       	call   800237 <sys_page_map>
  801038:	89 c3                	mov    %eax,%ebx
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 4c                	js     80108a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80103e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801047:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801049:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801053:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801059:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80105c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80105e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801061:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80106b:	89 04 24             	mov    %eax,(%esp)
  80106e:	e8 5d f4 ff ff       	call   8004d0 <fd2num>
  801073:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801075:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801078:	89 04 24             	mov    %eax,(%esp)
  80107b:	e8 50 f4 ff ff       	call   8004d0 <fd2num>
  801080:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801083:	bb 00 00 00 00       	mov    $0x0,%ebx
  801088:	eb 36                	jmp    8010c0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80108a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80108e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801095:	e8 fb f1 ff ff       	call   800295 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80109a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80109d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a8:	e8 e8 f1 ff ff       	call   800295 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8010ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bb:	e8 d5 f1 ff ff       	call   800295 <sys_page_unmap>
    err:
	return r;
}
  8010c0:	89 d8                	mov    %ebx,%eax
  8010c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010cb:	89 ec                	mov    %ebp,%esp
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	89 04 24             	mov    %eax,(%esp)
  8010e2:	e8 87 f4 ff ff       	call   80056e <fd_lookup>
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 15                	js     801100 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8010eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ee:	89 04 24             	mov    %eax,(%esp)
  8010f1:	e8 ea f3 ff ff       	call   8004e0 <fd2data>
	return _pipeisclosed(fd, p);
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fb:	e8 c2 fc ff ff       	call   800dc2 <_pipeisclosed>
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    
	...

00801110 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801120:	c7 44 24 04 16 24 80 	movl   $0x802416,0x4(%esp)
  801127:	00 
  801128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112b:	89 04 24             	mov    %eax,(%esp)
  80112e:	e8 d8 09 00 00       	call   801b0b <strcpy>
	return 0;
}
  801133:	b8 00 00 00 00       	mov    $0x0,%eax
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801146:	be 00 00 00 00       	mov    $0x0,%esi
  80114b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80114f:	74 43                	je     801194 <devcons_write+0x5a>
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801156:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80115c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801161:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801164:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801169:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80116c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801170:	03 45 0c             	add    0xc(%ebp),%eax
  801173:	89 44 24 04          	mov    %eax,0x4(%esp)
  801177:	89 3c 24             	mov    %edi,(%esp)
  80117a:	e8 7d 0b 00 00       	call   801cfc <memmove>
		sys_cputs(buf, m);
  80117f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801183:	89 3c 24             	mov    %edi,(%esp)
  801186:	e8 31 ef ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80118b:	01 de                	add    %ebx,%esi
  80118d:	89 f0                	mov    %esi,%eax
  80118f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801192:	72 c8                	jb     80115c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801194:	89 f0                	mov    %esi,%eax
  801196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8011ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011b0:	75 07                	jne    8011b9 <devcons_read+0x18>
  8011b2:	eb 31                	jmp    8011e5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8011b4:	e8 ef ef ff ff       	call   8001a8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8011b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	e8 26 ef ff ff       	call   8000eb <sys_cgetc>
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	74 eb                	je     8011b4 <devcons_read+0x13>
  8011c9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 16                	js     8011e5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8011cf:	83 f8 04             	cmp    $0x4,%eax
  8011d2:	74 0c                	je     8011e0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d7:	88 10                	mov    %dl,(%eax)
	return 1;
  8011d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8011de:	eb 05                	jmp    8011e5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8011e5:	c9                   	leave  
  8011e6:	c3                   	ret    

008011e7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8011f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011fa:	00 
  8011fb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8011fe:	89 04 24             	mov    %eax,(%esp)
  801201:	e8 b6 ee ff ff       	call   8000bc <sys_cputs>
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <getchar>:

int
getchar(void)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80120e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801215:	00 
  801216:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801224:	e8 05 f6 ff ff       	call   80082e <read>
	if (r < 0)
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 0f                	js     80123c <getchar+0x34>
		return r;
	if (r < 1)
  80122d:	85 c0                	test   %eax,%eax
  80122f:	7e 06                	jle    801237 <getchar+0x2f>
		return -E_EOF;
	return c;
  801231:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801235:	eb 05                	jmp    80123c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801237:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801244:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124b:	8b 45 08             	mov    0x8(%ebp),%eax
  80124e:	89 04 24             	mov    %eax,(%esp)
  801251:	e8 18 f3 ff ff       	call   80056e <fd_lookup>
  801256:	85 c0                	test   %eax,%eax
  801258:	78 11                	js     80126b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80125a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801263:	39 10                	cmp    %edx,(%eax)
  801265:	0f 94 c0             	sete   %al
  801268:	0f b6 c0             	movzbl %al,%eax
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <opencons>:

int
opencons(void)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801273:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 7d f2 ff ff       	call   8004fb <fd_alloc>
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 3c                	js     8012be <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801282:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801289:	00 
  80128a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801298:	e8 3b ef ff ff       	call   8001d8 <sys_page_alloc>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 1d                	js     8012be <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8012a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8012b6:	89 04 24             	mov    %eax,(%esp)
  8012b9:	e8 12 f2 ff ff       	call   8004d0 <fd2num>
}
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012cb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8012d1:	e8 a2 ee ff ff       	call   800178 <sys_getenvid>
  8012d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ec:	c7 04 24 24 24 80 00 	movl   $0x802424,(%esp)
  8012f3:	e8 c3 00 00 00       	call   8013bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ff:	89 04 24             	mov    %eax,(%esp)
  801302:	e8 53 00 00 00       	call   80135a <vcprintf>
	cprintf("\n");
  801307:	c7 04 24 0f 24 80 00 	movl   $0x80240f,(%esp)
  80130e:	e8 a8 00 00 00       	call   8013bb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801313:	cc                   	int3   
  801314:	eb fd                	jmp    801313 <_panic+0x53>
	...

00801318 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 14             	sub    $0x14,%esp
  80131f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801322:	8b 03                	mov    (%ebx),%eax
  801324:	8b 55 08             	mov    0x8(%ebp),%edx
  801327:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80132b:	83 c0 01             	add    $0x1,%eax
  80132e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801330:	3d ff 00 00 00       	cmp    $0xff,%eax
  801335:	75 19                	jne    801350 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801337:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80133e:	00 
  80133f:	8d 43 08             	lea    0x8(%ebx),%eax
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	e8 72 ed ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  80134a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801350:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801354:	83 c4 14             	add    $0x14,%esp
  801357:	5b                   	pop    %ebx
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801363:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80136a:	00 00 00 
	b.cnt = 0;
  80136d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801374:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	89 44 24 08          	mov    %eax,0x8(%esp)
  801385:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	c7 04 24 18 13 80 00 	movl   $0x801318,(%esp)
  801396:	e8 97 01 00 00       	call   801532 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80139b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8013a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	e8 09 ed ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  8013b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8013c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 87 ff ff ff       	call   80135a <vcprintf>
	va_end(ap);

	return cnt;
}
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    
  8013d5:	00 00                	add    %al,(%eax)
	...

008013d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	57                   	push   %edi
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 3c             	sub    $0x3c,%esp
  8013e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013e4:	89 d7                	mov    %edx,%edi
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8013f5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801400:	72 11                	jb     801413 <printnum+0x3b>
  801402:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801405:	39 45 10             	cmp    %eax,0x10(%ebp)
  801408:	76 09                	jbe    801413 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80140a:	83 eb 01             	sub    $0x1,%ebx
  80140d:	85 db                	test   %ebx,%ebx
  80140f:	7f 51                	jg     801462 <printnum+0x8a>
  801411:	eb 5e                	jmp    801471 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801413:	89 74 24 10          	mov    %esi,0x10(%esp)
  801417:	83 eb 01             	sub    $0x1,%ebx
  80141a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80141e:	8b 45 10             	mov    0x10(%ebp),%eax
  801421:	89 44 24 08          	mov    %eax,0x8(%esp)
  801425:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801429:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80142d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801434:	00 
  801435:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80143e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801442:	e8 09 0c 00 00       	call   802050 <__udivdi3>
  801447:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	89 54 24 04          	mov    %edx,0x4(%esp)
  801456:	89 fa                	mov    %edi,%edx
  801458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80145b:	e8 78 ff ff ff       	call   8013d8 <printnum>
  801460:	eb 0f                	jmp    801471 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801462:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801466:	89 34 24             	mov    %esi,(%esp)
  801469:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80146c:	83 eb 01             	sub    $0x1,%ebx
  80146f:	75 f1                	jne    801462 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801471:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801475:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801479:	8b 45 10             	mov    0x10(%ebp),%eax
  80147c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801480:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801487:	00 
  801488:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80148b:	89 04 24             	mov    %eax,(%esp)
  80148e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801491:	89 44 24 04          	mov    %eax,0x4(%esp)
  801495:	e8 e6 0c 00 00       	call   802180 <__umoddi3>
  80149a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80149e:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014ab:	83 c4 3c             	add    $0x3c,%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014b6:	83 fa 01             	cmp    $0x1,%edx
  8014b9:	7e 0e                	jle    8014c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014bb:	8b 10                	mov    (%eax),%edx
  8014bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014c0:	89 08                	mov    %ecx,(%eax)
  8014c2:	8b 02                	mov    (%edx),%eax
  8014c4:	8b 52 04             	mov    0x4(%edx),%edx
  8014c7:	eb 22                	jmp    8014eb <getuint+0x38>
	else if (lflag)
  8014c9:	85 d2                	test   %edx,%edx
  8014cb:	74 10                	je     8014dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014cd:	8b 10                	mov    (%eax),%edx
  8014cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014d2:	89 08                	mov    %ecx,(%eax)
  8014d4:	8b 02                	mov    (%edx),%eax
  8014d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014db:	eb 0e                	jmp    8014eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8014dd:	8b 10                	mov    (%eax),%edx
  8014df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014e2:	89 08                	mov    %ecx,(%eax)
  8014e4:	8b 02                	mov    (%edx),%eax
  8014e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8014f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8014f7:	8b 10                	mov    (%eax),%edx
  8014f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8014fc:	73 0a                	jae    801508 <sprintputch+0x1b>
		*b->buf++ = ch;
  8014fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801501:	88 0a                	mov    %cl,(%edx)
  801503:	83 c2 01             	add    $0x1,%edx
  801506:	89 10                	mov    %edx,(%eax)
}
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801510:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801513:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801517:	8b 45 10             	mov    0x10(%ebp),%eax
  80151a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80151e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801521:	89 44 24 04          	mov    %eax,0x4(%esp)
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
  801528:	89 04 24             	mov    %eax,(%esp)
  80152b:	e8 02 00 00 00       	call   801532 <vprintfmt>
	va_end(ap);
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	57                   	push   %edi
  801536:	56                   	push   %esi
  801537:	53                   	push   %ebx
  801538:	83 ec 5c             	sub    $0x5c,%esp
  80153b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80153e:	8b 75 10             	mov    0x10(%ebp),%esi
  801541:	eb 12                	jmp    801555 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801543:	85 c0                	test   %eax,%eax
  801545:	0f 84 e4 04 00 00    	je     801a2f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80154b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80154f:	89 04 24             	mov    %eax,(%esp)
  801552:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801555:	0f b6 06             	movzbl (%esi),%eax
  801558:	83 c6 01             	add    $0x1,%esi
  80155b:	83 f8 25             	cmp    $0x25,%eax
  80155e:	75 e3                	jne    801543 <vprintfmt+0x11>
  801560:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  801564:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80156b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801570:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801577:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80157f:	eb 2b                	jmp    8015ac <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801581:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801584:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  801588:	eb 22                	jmp    8015ac <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80158a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80158d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  801591:	eb 19                	jmp    8015ac <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801593:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801596:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80159d:	eb 0d                	jmp    8015ac <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80159f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8015a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015a5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ac:	0f b6 06             	movzbl (%esi),%eax
  8015af:	0f b6 d0             	movzbl %al,%edx
  8015b2:	8d 7e 01             	lea    0x1(%esi),%edi
  8015b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8015b8:	83 e8 23             	sub    $0x23,%eax
  8015bb:	3c 55                	cmp    $0x55,%al
  8015bd:	0f 87 46 04 00 00    	ja     801a09 <vprintfmt+0x4d7>
  8015c3:	0f b6 c0             	movzbl %al,%eax
  8015c6:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015cd:	83 ea 30             	sub    $0x30,%edx
  8015d0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8015d3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8015d7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8015dd:	83 fa 09             	cmp    $0x9,%edx
  8015e0:	77 4a                	ja     80162c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015e5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8015e8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8015eb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8015ef:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8015f2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8015f5:	83 fa 09             	cmp    $0x9,%edx
  8015f8:	76 eb                	jbe    8015e5 <vprintfmt+0xb3>
  8015fa:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8015fd:	eb 2d                	jmp    80162c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801602:	8d 50 04             	lea    0x4(%eax),%edx
  801605:	89 55 14             	mov    %edx,0x14(%ebp)
  801608:	8b 00                	mov    (%eax),%eax
  80160a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801610:	eb 1a                	jmp    80162c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801612:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  801615:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801619:	79 91                	jns    8015ac <vprintfmt+0x7a>
  80161b:	e9 73 ff ff ff       	jmp    801593 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801620:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801623:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80162a:	eb 80                	jmp    8015ac <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80162c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801630:	0f 89 76 ff ff ff    	jns    8015ac <vprintfmt+0x7a>
  801636:	e9 64 ff ff ff       	jmp    80159f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80163b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80163e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801641:	e9 66 ff ff ff       	jmp    8015ac <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801646:	8b 45 14             	mov    0x14(%ebp),%eax
  801649:	8d 50 04             	lea    0x4(%eax),%edx
  80164c:	89 55 14             	mov    %edx,0x14(%ebp)
  80164f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801653:	8b 00                	mov    (%eax),%eax
  801655:	89 04 24             	mov    %eax,(%esp)
  801658:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80165e:	e9 f2 fe ff ff       	jmp    801555 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  801663:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  801667:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80166a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80166e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  801671:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  801675:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  801678:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80167b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80167f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801682:	80 f9 09             	cmp    $0x9,%cl
  801685:	77 1d                	ja     8016a4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  801687:	0f be c0             	movsbl %al,%eax
  80168a:	6b c0 64             	imul   $0x64,%eax,%eax
  80168d:	0f be d2             	movsbl %dl,%edx
  801690:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801693:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80169a:	a3 58 30 80 00       	mov    %eax,0x803058
  80169f:	e9 b1 fe ff ff       	jmp    801555 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8016a4:	c7 44 24 04 5f 24 80 	movl   $0x80245f,0x4(%esp)
  8016ab:	00 
  8016ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016af:	89 04 24             	mov    %eax,(%esp)
  8016b2:	e8 14 05 00 00       	call   801bcb <strcmp>
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	75 0f                	jne    8016ca <vprintfmt+0x198>
  8016bb:	c7 05 58 30 80 00 04 	movl   $0x4,0x803058
  8016c2:	00 00 00 
  8016c5:	e9 8b fe ff ff       	jmp    801555 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8016ca:	c7 44 24 04 63 24 80 	movl   $0x802463,0x4(%esp)
  8016d1:	00 
  8016d2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8016d5:	89 14 24             	mov    %edx,(%esp)
  8016d8:	e8 ee 04 00 00       	call   801bcb <strcmp>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	75 0f                	jne    8016f0 <vprintfmt+0x1be>
  8016e1:	c7 05 58 30 80 00 02 	movl   $0x2,0x803058
  8016e8:	00 00 00 
  8016eb:	e9 65 fe ff ff       	jmp    801555 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8016f0:	c7 44 24 04 67 24 80 	movl   $0x802467,0x4(%esp)
  8016f7:	00 
  8016f8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8016fb:	89 0c 24             	mov    %ecx,(%esp)
  8016fe:	e8 c8 04 00 00       	call   801bcb <strcmp>
  801703:	85 c0                	test   %eax,%eax
  801705:	75 0f                	jne    801716 <vprintfmt+0x1e4>
  801707:	c7 05 58 30 80 00 01 	movl   $0x1,0x803058
  80170e:	00 00 00 
  801711:	e9 3f fe ff ff       	jmp    801555 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  801716:	c7 44 24 04 6b 24 80 	movl   $0x80246b,0x4(%esp)
  80171d:	00 
  80171e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  801721:	89 3c 24             	mov    %edi,(%esp)
  801724:	e8 a2 04 00 00       	call   801bcb <strcmp>
  801729:	85 c0                	test   %eax,%eax
  80172b:	75 0f                	jne    80173c <vprintfmt+0x20a>
  80172d:	c7 05 58 30 80 00 06 	movl   $0x6,0x803058
  801734:	00 00 00 
  801737:	e9 19 fe ff ff       	jmp    801555 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80173c:	c7 44 24 04 6f 24 80 	movl   $0x80246f,0x4(%esp)
  801743:	00 
  801744:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801747:	89 04 24             	mov    %eax,(%esp)
  80174a:	e8 7c 04 00 00       	call   801bcb <strcmp>
  80174f:	85 c0                	test   %eax,%eax
  801751:	75 0f                	jne    801762 <vprintfmt+0x230>
  801753:	c7 05 58 30 80 00 07 	movl   $0x7,0x803058
  80175a:	00 00 00 
  80175d:	e9 f3 fd ff ff       	jmp    801555 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  801762:	c7 44 24 04 73 24 80 	movl   $0x802473,0x4(%esp)
  801769:	00 
  80176a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80176d:	89 14 24             	mov    %edx,(%esp)
  801770:	e8 56 04 00 00       	call   801bcb <strcmp>
  801775:	83 f8 01             	cmp    $0x1,%eax
  801778:	19 c0                	sbb    %eax,%eax
  80177a:	f7 d0                	not    %eax
  80177c:	83 c0 08             	add    $0x8,%eax
  80177f:	a3 58 30 80 00       	mov    %eax,0x803058
  801784:	e9 cc fd ff ff       	jmp    801555 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  801789:	8b 45 14             	mov    0x14(%ebp),%eax
  80178c:	8d 50 04             	lea    0x4(%eax),%edx
  80178f:	89 55 14             	mov    %edx,0x14(%ebp)
  801792:	8b 00                	mov    (%eax),%eax
  801794:	89 c2                	mov    %eax,%edx
  801796:	c1 fa 1f             	sar    $0x1f,%edx
  801799:	31 d0                	xor    %edx,%eax
  80179b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80179d:	83 f8 0f             	cmp    $0xf,%eax
  8017a0:	7f 0b                	jg     8017ad <vprintfmt+0x27b>
  8017a2:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8017a9:	85 d2                	test   %edx,%edx
  8017ab:	75 23                	jne    8017d0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8017ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b1:	c7 44 24 08 77 24 80 	movl   $0x802477,0x8(%esp)
  8017b8:	00 
  8017b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c0:	89 3c 24             	mov    %edi,(%esp)
  8017c3:	e8 42 fd ff ff       	call   80150a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017cb:	e9 85 fd ff ff       	jmp    801555 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8017d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017d4:	c7 44 24 08 dd 23 80 	movl   $0x8023dd,0x8(%esp)
  8017db:	00 
  8017dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e3:	89 3c 24             	mov    %edi,(%esp)
  8017e6:	e8 1f fd ff ff       	call   80150a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017eb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8017ee:	e9 62 fd ff ff       	jmp    801555 <vprintfmt+0x23>
  8017f3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8017f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8017f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ff:	8d 50 04             	lea    0x4(%eax),%edx
  801802:	89 55 14             	mov    %edx,0x14(%ebp)
  801805:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801807:	85 f6                	test   %esi,%esi
  801809:	b8 58 24 80 00       	mov    $0x802458,%eax
  80180e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801811:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801815:	7e 06                	jle    80181d <vprintfmt+0x2eb>
  801817:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80181b:	75 13                	jne    801830 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80181d:	0f be 06             	movsbl (%esi),%eax
  801820:	83 c6 01             	add    $0x1,%esi
  801823:	85 c0                	test   %eax,%eax
  801825:	0f 85 94 00 00 00    	jne    8018bf <vprintfmt+0x38d>
  80182b:	e9 81 00 00 00       	jmp    8018b1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801830:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801834:	89 34 24             	mov    %esi,(%esp)
  801837:	e8 9f 02 00 00       	call   801adb <strnlen>
  80183c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80183f:	29 c2                	sub    %eax,%edx
  801841:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801844:	85 d2                	test   %edx,%edx
  801846:	7e d5                	jle    80181d <vprintfmt+0x2eb>
					putch(padc, putdat);
  801848:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80184c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80184f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  801852:	89 d6                	mov    %edx,%esi
  801854:	89 cf                	mov    %ecx,%edi
  801856:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80185a:	89 3c 24             	mov    %edi,(%esp)
  80185d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801860:	83 ee 01             	sub    $0x1,%esi
  801863:	75 f1                	jne    801856 <vprintfmt+0x324>
  801865:	8b 7d c0             	mov    -0x40(%ebp),%edi
  801868:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80186b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80186e:	eb ad                	jmp    80181d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801870:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  801874:	74 1b                	je     801891 <vprintfmt+0x35f>
  801876:	8d 50 e0             	lea    -0x20(%eax),%edx
  801879:	83 fa 5e             	cmp    $0x5e,%edx
  80187c:	76 13                	jbe    801891 <vprintfmt+0x35f>
					putch('?', putdat);
  80187e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80188c:	ff 55 08             	call   *0x8(%ebp)
  80188f:	eb 0d                	jmp    80189e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  801891:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801894:	89 54 24 04          	mov    %edx,0x4(%esp)
  801898:	89 04 24             	mov    %eax,(%esp)
  80189b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80189e:	83 eb 01             	sub    $0x1,%ebx
  8018a1:	0f be 06             	movsbl (%esi),%eax
  8018a4:	83 c6 01             	add    $0x1,%esi
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	75 1a                	jne    8018c5 <vprintfmt+0x393>
  8018ab:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8018ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018b4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8018b8:	7f 1c                	jg     8018d6 <vprintfmt+0x3a4>
  8018ba:	e9 96 fc ff ff       	jmp    801555 <vprintfmt+0x23>
  8018bf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8018c2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018c5:	85 ff                	test   %edi,%edi
  8018c7:	78 a7                	js     801870 <vprintfmt+0x33e>
  8018c9:	83 ef 01             	sub    $0x1,%edi
  8018cc:	79 a2                	jns    801870 <vprintfmt+0x33e>
  8018ce:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8018d1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8018d4:	eb db                	jmp    8018b1 <vprintfmt+0x37f>
  8018d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d9:	89 de                	mov    %ebx,%esi
  8018db:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8018e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018eb:	83 eb 01             	sub    $0x1,%ebx
  8018ee:	75 ee                	jne    8018de <vprintfmt+0x3ac>
  8018f0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8018f5:	e9 5b fc ff ff       	jmp    801555 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018fa:	83 f9 01             	cmp    $0x1,%ecx
  8018fd:	7e 10                	jle    80190f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8018ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801902:	8d 50 08             	lea    0x8(%eax),%edx
  801905:	89 55 14             	mov    %edx,0x14(%ebp)
  801908:	8b 30                	mov    (%eax),%esi
  80190a:	8b 78 04             	mov    0x4(%eax),%edi
  80190d:	eb 26                	jmp    801935 <vprintfmt+0x403>
	else if (lflag)
  80190f:	85 c9                	test   %ecx,%ecx
  801911:	74 12                	je     801925 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  801913:	8b 45 14             	mov    0x14(%ebp),%eax
  801916:	8d 50 04             	lea    0x4(%eax),%edx
  801919:	89 55 14             	mov    %edx,0x14(%ebp)
  80191c:	8b 30                	mov    (%eax),%esi
  80191e:	89 f7                	mov    %esi,%edi
  801920:	c1 ff 1f             	sar    $0x1f,%edi
  801923:	eb 10                	jmp    801935 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  801925:	8b 45 14             	mov    0x14(%ebp),%eax
  801928:	8d 50 04             	lea    0x4(%eax),%edx
  80192b:	89 55 14             	mov    %edx,0x14(%ebp)
  80192e:	8b 30                	mov    (%eax),%esi
  801930:	89 f7                	mov    %esi,%edi
  801932:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801935:	85 ff                	test   %edi,%edi
  801937:	78 0e                	js     801947 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801939:	89 f0                	mov    %esi,%eax
  80193b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80193d:	be 0a 00 00 00       	mov    $0xa,%esi
  801942:	e9 84 00 00 00       	jmp    8019cb <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801947:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80194b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801952:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801955:	89 f0                	mov    %esi,%eax
  801957:	89 fa                	mov    %edi,%edx
  801959:	f7 d8                	neg    %eax
  80195b:	83 d2 00             	adc    $0x0,%edx
  80195e:	f7 da                	neg    %edx
			}
			base = 10;
  801960:	be 0a 00 00 00       	mov    $0xa,%esi
  801965:	eb 64                	jmp    8019cb <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801967:	89 ca                	mov    %ecx,%edx
  801969:	8d 45 14             	lea    0x14(%ebp),%eax
  80196c:	e8 42 fb ff ff       	call   8014b3 <getuint>
			base = 10;
  801971:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  801976:	eb 53                	jmp    8019cb <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801978:	89 ca                	mov    %ecx,%edx
  80197a:	8d 45 14             	lea    0x14(%ebp),%eax
  80197d:	e8 31 fb ff ff       	call   8014b3 <getuint>
    			base = 8;
  801982:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  801987:	eb 42                	jmp    8019cb <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  801989:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801994:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801997:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8019a2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a8:	8d 50 04             	lea    0x4(%eax),%edx
  8019ab:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019ae:	8b 00                	mov    (%eax),%eax
  8019b0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019b5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8019ba:	eb 0f                	jmp    8019cb <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019bc:	89 ca                	mov    %ecx,%edx
  8019be:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c1:	e8 ed fa ff ff       	call   8014b3 <getuint>
			base = 16;
  8019c6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019cb:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8019cf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8019d3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8019d6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019da:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019e5:	89 da                	mov    %ebx,%edx
  8019e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ea:	e8 e9 f9 ff ff       	call   8013d8 <printnum>
			break;
  8019ef:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8019f2:	e9 5e fb ff ff       	jmp    801555 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019fb:	89 14 24             	mov    %edx,(%esp)
  8019fe:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a01:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a04:	e9 4c fb ff ff       	jmp    801555 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801a14:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a17:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a1b:	0f 84 34 fb ff ff    	je     801555 <vprintfmt+0x23>
  801a21:	83 ee 01             	sub    $0x1,%esi
  801a24:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a28:	75 f7                	jne    801a21 <vprintfmt+0x4ef>
  801a2a:	e9 26 fb ff ff       	jmp    801555 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801a2f:	83 c4 5c             	add    $0x5c,%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5f                   	pop    %edi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    

00801a37 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	83 ec 28             	sub    $0x28,%esp
  801a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a40:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a46:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a4a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	74 30                	je     801a88 <vsnprintf+0x51>
  801a58:	85 d2                	test   %edx,%edx
  801a5a:	7e 2c                	jle    801a88 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a63:	8b 45 10             	mov    0x10(%ebp),%eax
  801a66:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	c7 04 24 ed 14 80 00 	movl   $0x8014ed,(%esp)
  801a78:	e8 b5 fa ff ff       	call   801532 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a80:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a86:	eb 05                	jmp    801a8d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a95:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 82 ff ff ff       	call   801a37 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    
	...

00801ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  801acb:	80 3a 00             	cmpb   $0x0,(%edx)
  801ace:	74 09                	je     801ad9 <strlen+0x19>
		n++;
  801ad0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ad7:	75 f7                	jne    801ad0 <strlen+0x10>
		n++;
	return n;
}
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	85 c9                	test   %ecx,%ecx
  801aec:	74 1a                	je     801b08 <strnlen+0x2d>
  801aee:	80 3b 00             	cmpb   $0x0,(%ebx)
  801af1:	74 15                	je     801b08 <strnlen+0x2d>
  801af3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801af8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801afa:	39 ca                	cmp    %ecx,%edx
  801afc:	74 0a                	je     801b08 <strnlen+0x2d>
  801afe:	83 c2 01             	add    $0x1,%edx
  801b01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801b06:	75 f0                	jne    801af8 <strnlen+0x1d>
		n++;
	return n;
}
  801b08:	5b                   	pop    %ebx
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	53                   	push   %ebx
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b15:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801b1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801b21:	83 c2 01             	add    $0x1,%edx
  801b24:	84 c9                	test   %cl,%cl
  801b26:	75 f2                	jne    801b1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b28:	5b                   	pop    %ebx
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 08             	sub    $0x8,%esp
  801b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b35:	89 1c 24             	mov    %ebx,(%esp)
  801b38:	e8 83 ff ff ff       	call   801ac0 <strlen>
	strcpy(dst + len, src);
  801b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b40:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b44:	01 d8                	add    %ebx,%eax
  801b46:	89 04 24             	mov    %eax,(%esp)
  801b49:	e8 bd ff ff ff       	call   801b0b <strcpy>
	return dst;
}
  801b4e:	89 d8                	mov    %ebx,%eax
  801b50:	83 c4 08             	add    $0x8,%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	56                   	push   %esi
  801b5a:	53                   	push   %ebx
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b64:	85 f6                	test   %esi,%esi
  801b66:	74 18                	je     801b80 <strncpy+0x2a>
  801b68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b6d:	0f b6 1a             	movzbl (%edx),%ebx
  801b70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b73:	80 3a 01             	cmpb   $0x1,(%edx)
  801b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b79:	83 c1 01             	add    $0x1,%ecx
  801b7c:	39 f1                	cmp    %esi,%ecx
  801b7e:	75 ed                	jne    801b6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b90:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b93:	89 f8                	mov    %edi,%eax
  801b95:	85 f6                	test   %esi,%esi
  801b97:	74 2b                	je     801bc4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801b99:	83 fe 01             	cmp    $0x1,%esi
  801b9c:	74 23                	je     801bc1 <strlcpy+0x3d>
  801b9e:	0f b6 0b             	movzbl (%ebx),%ecx
  801ba1:	84 c9                	test   %cl,%cl
  801ba3:	74 1c                	je     801bc1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801ba5:	83 ee 02             	sub    $0x2,%esi
  801ba8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bad:	88 08                	mov    %cl,(%eax)
  801baf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bb2:	39 f2                	cmp    %esi,%edx
  801bb4:	74 0b                	je     801bc1 <strlcpy+0x3d>
  801bb6:	83 c2 01             	add    $0x1,%edx
  801bb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801bbd:	84 c9                	test   %cl,%cl
  801bbf:	75 ec                	jne    801bad <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  801bc1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bc4:	29 f8                	sub    %edi,%eax
}
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bd4:	0f b6 01             	movzbl (%ecx),%eax
  801bd7:	84 c0                	test   %al,%al
  801bd9:	74 16                	je     801bf1 <strcmp+0x26>
  801bdb:	3a 02                	cmp    (%edx),%al
  801bdd:	75 12                	jne    801bf1 <strcmp+0x26>
		p++, q++;
  801bdf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801be2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801be6:	84 c0                	test   %al,%al
  801be8:	74 07                	je     801bf1 <strcmp+0x26>
  801bea:	83 c1 01             	add    $0x1,%ecx
  801bed:	3a 02                	cmp    (%edx),%al
  801bef:	74 ee                	je     801bdf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801bf1:	0f b6 c0             	movzbl %al,%eax
  801bf4:	0f b6 12             	movzbl (%edx),%edx
  801bf7:	29 d0                	sub    %edx,%eax
}
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	53                   	push   %ebx
  801bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c0d:	85 d2                	test   %edx,%edx
  801c0f:	74 28                	je     801c39 <strncmp+0x3e>
  801c11:	0f b6 01             	movzbl (%ecx),%eax
  801c14:	84 c0                	test   %al,%al
  801c16:	74 24                	je     801c3c <strncmp+0x41>
  801c18:	3a 03                	cmp    (%ebx),%al
  801c1a:	75 20                	jne    801c3c <strncmp+0x41>
  801c1c:	83 ea 01             	sub    $0x1,%edx
  801c1f:	74 13                	je     801c34 <strncmp+0x39>
		n--, p++, q++;
  801c21:	83 c1 01             	add    $0x1,%ecx
  801c24:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c27:	0f b6 01             	movzbl (%ecx),%eax
  801c2a:	84 c0                	test   %al,%al
  801c2c:	74 0e                	je     801c3c <strncmp+0x41>
  801c2e:	3a 03                	cmp    (%ebx),%al
  801c30:	74 ea                	je     801c1c <strncmp+0x21>
  801c32:	eb 08                	jmp    801c3c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c39:	5b                   	pop    %ebx
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3c:	0f b6 01             	movzbl (%ecx),%eax
  801c3f:	0f b6 13             	movzbl (%ebx),%edx
  801c42:	29 d0                	sub    %edx,%eax
  801c44:	eb f3                	jmp    801c39 <strncmp+0x3e>

00801c46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c50:	0f b6 10             	movzbl (%eax),%edx
  801c53:	84 d2                	test   %dl,%dl
  801c55:	74 1c                	je     801c73 <strchr+0x2d>
		if (*s == c)
  801c57:	38 ca                	cmp    %cl,%dl
  801c59:	75 09                	jne    801c64 <strchr+0x1e>
  801c5b:	eb 1b                	jmp    801c78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  801c60:	38 ca                	cmp    %cl,%dl
  801c62:	74 14                	je     801c78 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c64:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  801c68:	84 d2                	test   %dl,%dl
  801c6a:	75 f1                	jne    801c5d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c71:	eb 05                	jmp    801c78 <strchr+0x32>
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    

00801c7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c84:	0f b6 10             	movzbl (%eax),%edx
  801c87:	84 d2                	test   %dl,%dl
  801c89:	74 14                	je     801c9f <strfind+0x25>
		if (*s == c)
  801c8b:	38 ca                	cmp    %cl,%dl
  801c8d:	75 06                	jne    801c95 <strfind+0x1b>
  801c8f:	eb 0e                	jmp    801c9f <strfind+0x25>
  801c91:	38 ca                	cmp    %cl,%dl
  801c93:	74 0a                	je     801c9f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c95:	83 c0 01             	add    $0x1,%eax
  801c98:	0f b6 10             	movzbl (%eax),%edx
  801c9b:	84 d2                	test   %dl,%dl
  801c9d:	75 f2                	jne    801c91 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	83 ec 0c             	sub    $0xc,%esp
  801ca7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801caa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cad:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801cb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cb9:	85 c9                	test   %ecx,%ecx
  801cbb:	74 30                	je     801ced <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cc3:	75 25                	jne    801cea <memset+0x49>
  801cc5:	f6 c1 03             	test   $0x3,%cl
  801cc8:	75 20                	jne    801cea <memset+0x49>
		c &= 0xFF;
  801cca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ccd:	89 d3                	mov    %edx,%ebx
  801ccf:	c1 e3 08             	shl    $0x8,%ebx
  801cd2:	89 d6                	mov    %edx,%esi
  801cd4:	c1 e6 18             	shl    $0x18,%esi
  801cd7:	89 d0                	mov    %edx,%eax
  801cd9:	c1 e0 10             	shl    $0x10,%eax
  801cdc:	09 f0                	or     %esi,%eax
  801cde:	09 d0                	or     %edx,%eax
  801ce0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ce2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801ce5:	fc                   	cld    
  801ce6:	f3 ab                	rep stos %eax,%es:(%edi)
  801ce8:	eb 03                	jmp    801ced <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cea:	fc                   	cld    
  801ceb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ced:	89 f8                	mov    %edi,%eax
  801cef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cf2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cf5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cf8:	89 ec                	mov    %ebp,%esp
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d05:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d11:	39 c6                	cmp    %eax,%esi
  801d13:	73 36                	jae    801d4b <memmove+0x4f>
  801d15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d18:	39 d0                	cmp    %edx,%eax
  801d1a:	73 2f                	jae    801d4b <memmove+0x4f>
		s += n;
		d += n;
  801d1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1f:	f6 c2 03             	test   $0x3,%dl
  801d22:	75 1b                	jne    801d3f <memmove+0x43>
  801d24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d2a:	75 13                	jne    801d3f <memmove+0x43>
  801d2c:	f6 c1 03             	test   $0x3,%cl
  801d2f:	75 0e                	jne    801d3f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d31:	83 ef 04             	sub    $0x4,%edi
  801d34:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d3a:	fd                   	std    
  801d3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3d:	eb 09                	jmp    801d48 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d3f:	83 ef 01             	sub    $0x1,%edi
  801d42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d45:	fd                   	std    
  801d46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d48:	fc                   	cld    
  801d49:	eb 20                	jmp    801d6b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d51:	75 13                	jne    801d66 <memmove+0x6a>
  801d53:	a8 03                	test   $0x3,%al
  801d55:	75 0f                	jne    801d66 <memmove+0x6a>
  801d57:	f6 c1 03             	test   $0x3,%cl
  801d5a:	75 0a                	jne    801d66 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d5c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801d5f:	89 c7                	mov    %eax,%edi
  801d61:	fc                   	cld    
  801d62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d64:	eb 05                	jmp    801d6b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d66:	89 c7                	mov    %eax,%edi
  801d68:	fc                   	cld    
  801d69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d71:	89 ec                	mov    %ebp,%esp
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d89:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 68 ff ff ff       	call   801cfc <memmove>
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	57                   	push   %edi
  801d9a:	56                   	push   %esi
  801d9b:	53                   	push   %ebx
  801d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801da2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801daa:	85 ff                	test   %edi,%edi
  801dac:	74 37                	je     801de5 <memcmp+0x4f>
		if (*s1 != *s2)
  801dae:	0f b6 03             	movzbl (%ebx),%eax
  801db1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801db4:	83 ef 01             	sub    $0x1,%edi
  801db7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  801dbc:	38 c8                	cmp    %cl,%al
  801dbe:	74 1c                	je     801ddc <memcmp+0x46>
  801dc0:	eb 10                	jmp    801dd2 <memcmp+0x3c>
  801dc2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801dc7:	83 c2 01             	add    $0x1,%edx
  801dca:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801dce:	38 c8                	cmp    %cl,%al
  801dd0:	74 0a                	je     801ddc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801dd2:	0f b6 c0             	movzbl %al,%eax
  801dd5:	0f b6 c9             	movzbl %cl,%ecx
  801dd8:	29 c8                	sub    %ecx,%eax
  801dda:	eb 09                	jmp    801de5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ddc:	39 fa                	cmp    %edi,%edx
  801dde:	75 e2                	jne    801dc2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801de5:	5b                   	pop    %ebx
  801de6:	5e                   	pop    %esi
  801de7:	5f                   	pop    %edi
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    

00801dea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801df5:	39 d0                	cmp    %edx,%eax
  801df7:	73 19                	jae    801e12 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801df9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801dfd:	38 08                	cmp    %cl,(%eax)
  801dff:	75 06                	jne    801e07 <memfind+0x1d>
  801e01:	eb 0f                	jmp    801e12 <memfind+0x28>
  801e03:	38 08                	cmp    %cl,(%eax)
  801e05:	74 0b                	je     801e12 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e07:	83 c0 01             	add    $0x1,%eax
  801e0a:	39 d0                	cmp    %edx,%eax
  801e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e10:	75 f1                	jne    801e03 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e20:	0f b6 02             	movzbl (%edx),%eax
  801e23:	3c 20                	cmp    $0x20,%al
  801e25:	74 04                	je     801e2b <strtol+0x17>
  801e27:	3c 09                	cmp    $0x9,%al
  801e29:	75 0e                	jne    801e39 <strtol+0x25>
		s++;
  801e2b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e2e:	0f b6 02             	movzbl (%edx),%eax
  801e31:	3c 20                	cmp    $0x20,%al
  801e33:	74 f6                	je     801e2b <strtol+0x17>
  801e35:	3c 09                	cmp    $0x9,%al
  801e37:	74 f2                	je     801e2b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e39:	3c 2b                	cmp    $0x2b,%al
  801e3b:	75 0a                	jne    801e47 <strtol+0x33>
		s++;
  801e3d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e40:	bf 00 00 00 00       	mov    $0x0,%edi
  801e45:	eb 10                	jmp    801e57 <strtol+0x43>
  801e47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e4c:	3c 2d                	cmp    $0x2d,%al
  801e4e:	75 07                	jne    801e57 <strtol+0x43>
		s++, neg = 1;
  801e50:	83 c2 01             	add    $0x1,%edx
  801e53:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e57:	85 db                	test   %ebx,%ebx
  801e59:	0f 94 c0             	sete   %al
  801e5c:	74 05                	je     801e63 <strtol+0x4f>
  801e5e:	83 fb 10             	cmp    $0x10,%ebx
  801e61:	75 15                	jne    801e78 <strtol+0x64>
  801e63:	80 3a 30             	cmpb   $0x30,(%edx)
  801e66:	75 10                	jne    801e78 <strtol+0x64>
  801e68:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e6c:	75 0a                	jne    801e78 <strtol+0x64>
		s += 2, base = 16;
  801e6e:	83 c2 02             	add    $0x2,%edx
  801e71:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e76:	eb 13                	jmp    801e8b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801e78:	84 c0                	test   %al,%al
  801e7a:	74 0f                	je     801e8b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e81:	80 3a 30             	cmpb   $0x30,(%edx)
  801e84:	75 05                	jne    801e8b <strtol+0x77>
		s++, base = 8;
  801e86:	83 c2 01             	add    $0x1,%edx
  801e89:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  801e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e90:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e92:	0f b6 0a             	movzbl (%edx),%ecx
  801e95:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e98:	80 fb 09             	cmp    $0x9,%bl
  801e9b:	77 08                	ja     801ea5 <strtol+0x91>
			dig = *s - '0';
  801e9d:	0f be c9             	movsbl %cl,%ecx
  801ea0:	83 e9 30             	sub    $0x30,%ecx
  801ea3:	eb 1e                	jmp    801ec3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801ea5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801ea8:	80 fb 19             	cmp    $0x19,%bl
  801eab:	77 08                	ja     801eb5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  801ead:	0f be c9             	movsbl %cl,%ecx
  801eb0:	83 e9 57             	sub    $0x57,%ecx
  801eb3:	eb 0e                	jmp    801ec3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801eb5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801eb8:	80 fb 19             	cmp    $0x19,%bl
  801ebb:	77 14                	ja     801ed1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ebd:	0f be c9             	movsbl %cl,%ecx
  801ec0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ec3:	39 f1                	cmp    %esi,%ecx
  801ec5:	7d 0e                	jge    801ed5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801ec7:	83 c2 01             	add    $0x1,%edx
  801eca:	0f af c6             	imul   %esi,%eax
  801ecd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801ecf:	eb c1                	jmp    801e92 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801ed1:	89 c1                	mov    %eax,%ecx
  801ed3:	eb 02                	jmp    801ed7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ed5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801ed7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801edb:	74 05                	je     801ee2 <strtol+0xce>
		*endptr = (char *) s;
  801edd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ee0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801ee2:	89 ca                	mov    %ecx,%edx
  801ee4:	f7 da                	neg    %edx
  801ee6:	85 ff                	test   %edi,%edi
  801ee8:	0f 45 c2             	cmovne %edx,%eax
}
  801eeb:	5b                   	pop    %ebx
  801eec:	5e                   	pop    %esi
  801eed:	5f                   	pop    %edi
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    

00801ef0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	56                   	push   %esi
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 10             	sub    $0x10,%esp
  801ef8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801efb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efe:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f01:	85 db                	test   %ebx,%ebx
  801f03:	74 06                	je     801f0b <ipc_recv+0x1b>
  801f05:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f0b:	85 f6                	test   %esi,%esi
  801f0d:	74 06                	je     801f15 <ipc_recv+0x25>
  801f0f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f15:	85 c0                	test   %eax,%eax
  801f17:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f1c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f1f:	89 04 24             	mov    %eax,(%esp)
  801f22:	e8 1a e5 ff ff       	call   800441 <sys_ipc_recv>
    if (ret) return ret;
  801f27:	85 c0                	test   %eax,%eax
  801f29:	75 24                	jne    801f4f <ipc_recv+0x5f>
    if (from_env_store)
  801f2b:	85 db                	test   %ebx,%ebx
  801f2d:	74 0a                	je     801f39 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f2f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f34:	8b 40 74             	mov    0x74(%eax),%eax
  801f37:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f39:	85 f6                	test   %esi,%esi
  801f3b:	74 0a                	je     801f47 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f3d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f42:	8b 40 78             	mov    0x78(%eax),%eax
  801f45:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f47:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5e                   	pop    %esi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	57                   	push   %edi
  801f5a:	56                   	push   %esi
  801f5b:	53                   	push   %ebx
  801f5c:	83 ec 1c             	sub    $0x1c,%esp
  801f5f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f62:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f68:	85 db                	test   %ebx,%ebx
  801f6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f6f:	0f 44 d8             	cmove  %eax,%ebx
  801f72:	eb 2a                	jmp    801f9e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f74:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f77:	74 20                	je     801f99 <ipc_send+0x43>
  801f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f7d:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  801f84:	00 
  801f85:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801f8c:	00 
  801f8d:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  801f94:	e8 27 f3 ff ff       	call   8012c0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801f99:	e8 0a e2 ff ff       	call   8001a8 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fa5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fad:	89 34 24             	mov    %esi,(%esp)
  801fb0:	e8 58 e4 ff ff       	call   80040d <sys_ipc_try_send>
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	75 bb                	jne    801f74 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fb9:	83 c4 1c             	add    $0x1c,%esp
  801fbc:	5b                   	pop    %ebx
  801fbd:	5e                   	pop    %esi
  801fbe:	5f                   	pop    %edi
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fc7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801fcc:	39 c8                	cmp    %ecx,%eax
  801fce:	74 19                	je     801fe9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fd5:	89 c2                	mov    %eax,%edx
  801fd7:	c1 e2 07             	shl    $0x7,%edx
  801fda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe0:	8b 52 50             	mov    0x50(%edx),%edx
  801fe3:	39 ca                	cmp    %ecx,%edx
  801fe5:	75 14                	jne    801ffb <ipc_find_env+0x3a>
  801fe7:	eb 05                	jmp    801fee <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801fee:	c1 e0 07             	shl    $0x7,%eax
  801ff1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ff6:	8b 40 40             	mov    0x40(%eax),%eax
  801ff9:	eb 0e                	jmp    802009 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffb:	83 c0 01             	add    $0x1,%eax
  801ffe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802003:	75 d0                	jne    801fd5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802005:	66 b8 00 00          	mov    $0x0,%ax
}
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    
	...

0080200c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802012:	89 d0                	mov    %edx,%eax
  802014:	c1 e8 16             	shr    $0x16,%eax
  802017:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802023:	f6 c1 01             	test   $0x1,%cl
  802026:	74 1d                	je     802045 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802028:	c1 ea 0c             	shr    $0xc,%edx
  80202b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802032:	f6 c2 01             	test   $0x1,%dl
  802035:	74 0e                	je     802045 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802037:	c1 ea 0c             	shr    $0xc,%edx
  80203a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802041:	ef 
  802042:	0f b7 c0             	movzwl %ax,%eax
}
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    
	...

00802050 <__udivdi3>:
  802050:	83 ec 1c             	sub    $0x1c,%esp
  802053:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802057:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80205b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80205f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802063:	89 74 24 10          	mov    %esi,0x10(%esp)
  802067:	8b 74 24 24          	mov    0x24(%esp),%esi
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802071:	89 44 24 08          	mov    %eax,0x8(%esp)
  802075:	89 cd                	mov    %ecx,%ebp
  802077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207b:	75 33                	jne    8020b0 <__udivdi3+0x60>
  80207d:	39 f1                	cmp    %esi,%ecx
  80207f:	77 57                	ja     8020d8 <__udivdi3+0x88>
  802081:	85 c9                	test   %ecx,%ecx
  802083:	75 0b                	jne    802090 <__udivdi3+0x40>
  802085:	b8 01 00 00 00       	mov    $0x1,%eax
  80208a:	31 d2                	xor    %edx,%edx
  80208c:	f7 f1                	div    %ecx
  80208e:	89 c1                	mov    %eax,%ecx
  802090:	89 f0                	mov    %esi,%eax
  802092:	31 d2                	xor    %edx,%edx
  802094:	f7 f1                	div    %ecx
  802096:	89 c6                	mov    %eax,%esi
  802098:	8b 44 24 04          	mov    0x4(%esp),%eax
  80209c:	f7 f1                	div    %ecx
  80209e:	89 f2                	mov    %esi,%edx
  8020a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	c3                   	ret    
  8020b0:	31 d2                	xor    %edx,%edx
  8020b2:	31 c0                	xor    %eax,%eax
  8020b4:	39 f7                	cmp    %esi,%edi
  8020b6:	77 e8                	ja     8020a0 <__udivdi3+0x50>
  8020b8:	0f bd cf             	bsr    %edi,%ecx
  8020bb:	83 f1 1f             	xor    $0x1f,%ecx
  8020be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020c2:	75 2c                	jne    8020f0 <__udivdi3+0xa0>
  8020c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020c8:	76 04                	jbe    8020ce <__udivdi3+0x7e>
  8020ca:	39 f7                	cmp    %esi,%edi
  8020cc:	73 d2                	jae    8020a0 <__udivdi3+0x50>
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d5:	eb c9                	jmp    8020a0 <__udivdi3+0x50>
  8020d7:	90                   	nop
  8020d8:	89 f2                	mov    %esi,%edx
  8020da:	f7 f1                	div    %ecx
  8020dc:	31 d2                	xor    %edx,%edx
  8020de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	c3                   	ret    
  8020ee:	66 90                	xchg   %ax,%ax
  8020f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8020fa:	89 ea                	mov    %ebp,%edx
  8020fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  802100:	d3 e7                	shl    %cl,%edi
  802102:	89 c1                	mov    %eax,%ecx
  802104:	d3 ea                	shr    %cl,%edx
  802106:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80210b:	09 fa                	or     %edi,%edx
  80210d:	89 f7                	mov    %esi,%edi
  80210f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802113:	89 f2                	mov    %esi,%edx
  802115:	8b 74 24 08          	mov    0x8(%esp),%esi
  802119:	d3 e5                	shl    %cl,%ebp
  80211b:	89 c1                	mov    %eax,%ecx
  80211d:	d3 ef                	shr    %cl,%edi
  80211f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802124:	d3 e2                	shl    %cl,%edx
  802126:	89 c1                	mov    %eax,%ecx
  802128:	d3 ee                	shr    %cl,%esi
  80212a:	09 d6                	or     %edx,%esi
  80212c:	89 fa                	mov    %edi,%edx
  80212e:	89 f0                	mov    %esi,%eax
  802130:	f7 74 24 0c          	divl   0xc(%esp)
  802134:	89 d7                	mov    %edx,%edi
  802136:	89 c6                	mov    %eax,%esi
  802138:	f7 e5                	mul    %ebp
  80213a:	39 d7                	cmp    %edx,%edi
  80213c:	72 22                	jb     802160 <__udivdi3+0x110>
  80213e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802142:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802147:	d3 e5                	shl    %cl,%ebp
  802149:	39 c5                	cmp    %eax,%ebp
  80214b:	73 04                	jae    802151 <__udivdi3+0x101>
  80214d:	39 d7                	cmp    %edx,%edi
  80214f:	74 0f                	je     802160 <__udivdi3+0x110>
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	e9 46 ff ff ff       	jmp    8020a0 <__udivdi3+0x50>
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	8d 46 ff             	lea    -0x1(%esi),%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	8b 74 24 10          	mov    0x10(%esp),%esi
  802169:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80216d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	c3                   	ret    
	...

00802180 <__umoddi3>:
  802180:	83 ec 1c             	sub    $0x1c,%esp
  802183:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802187:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80218b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80218f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802193:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802197:	8b 74 24 24          	mov    0x24(%esp),%esi
  80219b:	85 ed                	test   %ebp,%ebp
  80219d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021a5:	89 cf                	mov    %ecx,%edi
  8021a7:	89 04 24             	mov    %eax,(%esp)
  8021aa:	89 f2                	mov    %esi,%edx
  8021ac:	75 1a                	jne    8021c8 <__umoddi3+0x48>
  8021ae:	39 f1                	cmp    %esi,%ecx
  8021b0:	76 4e                	jbe    802200 <__umoddi3+0x80>
  8021b2:	f7 f1                	div    %ecx
  8021b4:	89 d0                	mov    %edx,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	c3                   	ret    
  8021c8:	39 f5                	cmp    %esi,%ebp
  8021ca:	77 54                	ja     802220 <__umoddi3+0xa0>
  8021cc:	0f bd c5             	bsr    %ebp,%eax
  8021cf:	83 f0 1f             	xor    $0x1f,%eax
  8021d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d6:	75 60                	jne    802238 <__umoddi3+0xb8>
  8021d8:	3b 0c 24             	cmp    (%esp),%ecx
  8021db:	0f 87 07 01 00 00    	ja     8022e8 <__umoddi3+0x168>
  8021e1:	89 f2                	mov    %esi,%edx
  8021e3:	8b 34 24             	mov    (%esp),%esi
  8021e6:	29 ce                	sub    %ecx,%esi
  8021e8:	19 ea                	sbb    %ebp,%edx
  8021ea:	89 34 24             	mov    %esi,(%esp)
  8021ed:	8b 04 24             	mov    (%esp),%eax
  8021f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	c3                   	ret    
  802200:	85 c9                	test   %ecx,%ecx
  802202:	75 0b                	jne    80220f <__umoddi3+0x8f>
  802204:	b8 01 00 00 00       	mov    $0x1,%eax
  802209:	31 d2                	xor    %edx,%edx
  80220b:	f7 f1                	div    %ecx
  80220d:	89 c1                	mov    %eax,%ecx
  80220f:	89 f0                	mov    %esi,%eax
  802211:	31 d2                	xor    %edx,%edx
  802213:	f7 f1                	div    %ecx
  802215:	8b 04 24             	mov    (%esp),%eax
  802218:	f7 f1                	div    %ecx
  80221a:	eb 98                	jmp    8021b4 <__umoddi3+0x34>
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 f2                	mov    %esi,%edx
  802222:	8b 74 24 10          	mov    0x10(%esp),%esi
  802226:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80222a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80222e:	83 c4 1c             	add    $0x1c,%esp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80223d:	89 e8                	mov    %ebp,%eax
  80223f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802244:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802248:	89 fa                	mov    %edi,%edx
  80224a:	d3 e0                	shl    %cl,%eax
  80224c:	89 e9                	mov    %ebp,%ecx
  80224e:	d3 ea                	shr    %cl,%edx
  802250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802255:	09 c2                	or     %eax,%edx
  802257:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225b:	89 14 24             	mov    %edx,(%esp)
  80225e:	89 f2                	mov    %esi,%edx
  802260:	d3 e7                	shl    %cl,%edi
  802262:	89 e9                	mov    %ebp,%ecx
  802264:	d3 ea                	shr    %cl,%edx
  802266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80226b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80226f:	d3 e6                	shl    %cl,%esi
  802271:	89 e9                	mov    %ebp,%ecx
  802273:	d3 e8                	shr    %cl,%eax
  802275:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80227a:	09 f0                	or     %esi,%eax
  80227c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802280:	f7 34 24             	divl   (%esp)
  802283:	d3 e6                	shl    %cl,%esi
  802285:	89 74 24 08          	mov    %esi,0x8(%esp)
  802289:	89 d6                	mov    %edx,%esi
  80228b:	f7 e7                	mul    %edi
  80228d:	39 d6                	cmp    %edx,%esi
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	89 d7                	mov    %edx,%edi
  802293:	72 3f                	jb     8022d4 <__umoddi3+0x154>
  802295:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802299:	72 35                	jb     8022d0 <__umoddi3+0x150>
  80229b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80229f:	29 c8                	sub    %ecx,%eax
  8022a1:	19 fe                	sbb    %edi,%esi
  8022a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022a8:	89 f2                	mov    %esi,%edx
  8022aa:	d3 e8                	shr    %cl,%eax
  8022ac:	89 e9                	mov    %ebp,%ecx
  8022ae:	d3 e2                	shl    %cl,%edx
  8022b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022b5:	09 d0                	or     %edx,%eax
  8022b7:	89 f2                	mov    %esi,%edx
  8022b9:	d3 ea                	shr    %cl,%edx
  8022bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022c7:	83 c4 1c             	add    $0x1c,%esp
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	39 d6                	cmp    %edx,%esi
  8022d2:	75 c7                	jne    80229b <__umoddi3+0x11b>
  8022d4:	89 d7                	mov    %edx,%edi
  8022d6:	89 c1                	mov    %eax,%ecx
  8022d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8022dc:	1b 3c 24             	sbb    (%esp),%edi
  8022df:	eb ba                	jmp    80229b <__umoddi3+0x11b>
  8022e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 f5                	cmp    %esi,%ebp
  8022ea:	0f 82 f1 fe ff ff    	jb     8021e1 <__umoddi3+0x61>
  8022f0:	e9 f8 fe ff ff       	jmp    8021ed <__umoddi3+0x6d>
