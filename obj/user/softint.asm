
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 09 01 00 00       	call   80015c <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	c1 e0 07             	shl    $0x7,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	89 34 24             	mov    %esi,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 61 00 00 00       	call   8000ff <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cb:	89 ec                	mov    %ebp,%esp
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000fb:	89 ec                	mov    %ebp,%esp
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	83 ec 38             	sub    $0x38,%esp
  800105:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800108:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 28                	jle    80014f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800132:	00 
  800133:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  80014a:	e8 09 03 00 00       	call   800458 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800152:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800155:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800158:	89 ec                	mov    %ebp,%esp
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800165:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800168:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800182:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800185:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800188:	89 ec                	mov    %ebp,%esp
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_yield>:

void
sys_yield(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800195:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800198:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019b:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a5:	89 d1                	mov    %edx,%ecx
  8001a7:	89 d3                	mov    %edx,%ebx
  8001a9:	89 d7                	mov    %edx,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001af:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b8:	89 ec                	mov    %ebp,%esp
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 38             	sub    $0x38,%esp
  8001c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cb:	be 00 00 00 00       	mov    $0x0,%esi
  8001d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001db:	8b 55 08             	mov    0x8(%ebp),%edx
  8001de:	89 f7                	mov    %esi,%edi
  8001e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	7e 28                	jle    80020e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800201:	00 
  800202:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800209:	e8 4a 02 00 00       	call   800458 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80020e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800211:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800214:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800217:	89 ec                	mov    %ebp,%esp
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 38             	sub    $0x38,%esp
  800221:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800224:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800227:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	b8 05 00 00 00       	mov    $0x5,%eax
  80022f:	8b 75 18             	mov    0x18(%ebp),%esi
  800232:	8b 7d 14             	mov    0x14(%ebp),%edi
  800235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 28                	jle    80026c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	89 44 24 10          	mov    %eax,0x10(%esp)
  800248:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80024f:	00 
  800250:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800257:	00 
  800258:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025f:	00 
  800260:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800267:	e8 ec 01 00 00       	call   800458 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80026c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80026f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800272:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800275:	89 ec                	mov    %ebp,%esp
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	83 ec 38             	sub    $0x38,%esp
  80027f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800282:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800285:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 06 00 00 00       	mov    $0x6,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  8002c5:	e8 8e 01 00 00       	call   800458 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d3:	89 ec                	mov    %ebp,%esp
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 38             	sub    $0x38,%esp
  8002dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 df                	mov    %ebx,%edi
  8002f8:	89 de                	mov    %ebx,%esi
  8002fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	7e 28                	jle    800328 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	89 44 24 10          	mov    %eax,0x10(%esp)
  800304:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80030b:	00 
  80030c:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800313:	00 
  800314:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031b:	00 
  80031c:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800323:	e8 30 01 00 00       	call   800458 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800328:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80032b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80032e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800331:	89 ec                	mov    %ebp,%esp
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 38             	sub    $0x38,%esp
  80033b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80033e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800341:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	b8 09 00 00 00       	mov    $0x9,%eax
  80034e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	89 df                	mov    %ebx,%edi
  800356:	89 de                	mov    %ebx,%esi
  800358:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	7e 28                	jle    800386 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800369:	00 
  80036a:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800381:	e8 d2 00 00 00       	call   800458 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800386:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800389:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80038c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80038f:	89 ec                	mov    %ebp,%esp
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80039c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80039f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a2:	be 00 00 00 00       	mov    $0x0,%esi
  8003a7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003bd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c3:	89 ec                	mov    %ebp,%esp
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 38             	sub    $0x38,%esp
  8003cd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003d3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e3:	89 cb                	mov    %ecx,%ebx
  8003e5:	89 cf                	mov    %ecx,%edi
  8003e7:	89 ce                	mov    %ecx,%esi
  8003e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	7e 28                	jle    800417 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8003fa:	00 
  8003fb:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800402:	00 
  800403:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040a:	00 
  80040b:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800412:	e8 41 00 00 00       	call   800458 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800417:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80041a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80041d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800420:	89 ec                	mov    %ebp,%esp
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80042d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800430:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800433:	b9 00 00 00 00       	mov    $0x0,%ecx
  800438:	b8 0d 00 00 00       	mov    $0xd,%eax
  80043d:	8b 55 08             	mov    0x8(%ebp),%edx
  800440:	89 cb                	mov    %ecx,%ebx
  800442:	89 cf                	mov    %ecx,%edi
  800444:	89 ce                	mov    %ecx,%esi
  800446:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  800448:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80044b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80044e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800451:	89 ec                	mov    %ebp,%esp
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    
  800455:	00 00                	add    %al,(%eax)
	...

00800458 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	56                   	push   %esi
  80045c:	53                   	push   %ebx
  80045d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800460:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800463:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800469:	e8 ee fc ff ff       	call   80015c <sys_getenvid>
  80046e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800471:	89 54 24 10          	mov    %edx,0x10(%esp)
  800475:	8b 55 08             	mov    0x8(%ebp),%edx
  800478:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800480:	89 44 24 04          	mov    %eax,0x4(%esp)
  800484:	c7 04 24 78 13 80 00 	movl   $0x801378,(%esp)
  80048b:	e8 c3 00 00 00       	call   800553 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800490:	89 74 24 04          	mov    %esi,0x4(%esp)
  800494:	8b 45 10             	mov    0x10(%ebp),%eax
  800497:	89 04 24             	mov    %eax,(%esp)
  80049a:	e8 53 00 00 00       	call   8004f2 <vcprintf>
	cprintf("\n");
  80049f:	c7 04 24 9c 13 80 00 	movl   $0x80139c,(%esp)
  8004a6:	e8 a8 00 00 00       	call   800553 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ab:	cc                   	int3   
  8004ac:	eb fd                	jmp    8004ab <_panic+0x53>
	...

008004b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 14             	sub    $0x14,%esp
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ba:	8b 03                	mov    (%ebx),%eax
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004c3:	83 c0 01             	add    $0x1,%eax
  8004c6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004cd:	75 19                	jne    8004e8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004cf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d6:	00 
  8004d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	e8 be fb ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8004e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004ec:	83 c4 14             	add    $0x14,%esp
  8004ef:	5b                   	pop    %ebx
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800502:	00 00 00 
	b.cnt = 0;
  800505:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80050c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800523:	89 44 24 04          	mov    %eax,0x4(%esp)
  800527:	c7 04 24 b0 04 80 00 	movl   $0x8004b0,(%esp)
  80052e:	e8 97 01 00 00       	call   8006ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800533:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	e8 55 fb ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  80054b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800551:	c9                   	leave  
  800552:	c3                   	ret    

00800553 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800559:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80055c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800560:	8b 45 08             	mov    0x8(%ebp),%eax
  800563:	89 04 24             	mov    %eax,(%esp)
  800566:	e8 87 ff ff ff       	call   8004f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    
  80056d:	00 00                	add    %al,(%eax)
	...

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	57                   	push   %edi
  800574:	56                   	push   %esi
  800575:	53                   	push   %ebx
  800576:	83 ec 3c             	sub    $0x3c,%esp
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	89 d7                	mov    %edx,%edi
  80057e:	8b 45 08             	mov    0x8(%ebp),%eax
  800581:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800584:	8b 45 0c             	mov    0xc(%ebp),%eax
  800587:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80058d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800598:	72 11                	jb     8005ab <printnum+0x3b>
  80059a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005a0:	76 09                	jbe    8005ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005a2:	83 eb 01             	sub    $0x1,%ebx
  8005a5:	85 db                	test   %ebx,%ebx
  8005a7:	7f 51                	jg     8005fa <printnum+0x8a>
  8005a9:	eb 5e                	jmp    800609 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005af:	83 eb 01             	sub    $0x1,%ebx
  8005b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005cc:	00 
  8005cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005da:	e8 a1 0a 00 00       	call   801080 <__udivdi3>
  8005df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005e7:	89 04 24             	mov    %eax,(%esp)
  8005ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ee:	89 fa                	mov    %edi,%edx
  8005f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f3:	e8 78 ff ff ff       	call   800570 <printnum>
  8005f8:	eb 0f                	jmp    800609 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fe:	89 34 24             	mov    %esi,(%esp)
  800601:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800604:	83 eb 01             	sub    $0x1,%ebx
  800607:	75 f1                	jne    8005fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800609:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800611:	8b 45 10             	mov    0x10(%ebp),%eax
  800614:	89 44 24 08          	mov    %eax,0x8(%esp)
  800618:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80061f:	00 
  800620:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800629:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062d:	e8 7e 0b 00 00       	call   8011b0 <__umoddi3>
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	0f be 80 9e 13 80 00 	movsbl 0x80139e(%eax),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800643:	83 c4 3c             	add    $0x3c,%esp
  800646:	5b                   	pop    %ebx
  800647:	5e                   	pop    %esi
  800648:	5f                   	pop    %edi
  800649:	5d                   	pop    %ebp
  80064a:	c3                   	ret    

0080064b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80064e:	83 fa 01             	cmp    $0x1,%edx
  800651:	7e 0e                	jle    800661 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800653:	8b 10                	mov    (%eax),%edx
  800655:	8d 4a 08             	lea    0x8(%edx),%ecx
  800658:	89 08                	mov    %ecx,(%eax)
  80065a:	8b 02                	mov    (%edx),%eax
  80065c:	8b 52 04             	mov    0x4(%edx),%edx
  80065f:	eb 22                	jmp    800683 <getuint+0x38>
	else if (lflag)
  800661:	85 d2                	test   %edx,%edx
  800663:	74 10                	je     800675 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800665:	8b 10                	mov    (%eax),%edx
  800667:	8d 4a 04             	lea    0x4(%edx),%ecx
  80066a:	89 08                	mov    %ecx,(%eax)
  80066c:	8b 02                	mov    (%edx),%eax
  80066e:	ba 00 00 00 00       	mov    $0x0,%edx
  800673:	eb 0e                	jmp    800683 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800675:	8b 10                	mov    (%eax),%edx
  800677:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067a:	89 08                	mov    %ecx,(%eax)
  80067c:	8b 02                	mov    (%edx),%eax
  80067e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80068b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	3b 50 04             	cmp    0x4(%eax),%edx
  800694:	73 0a                	jae    8006a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800696:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800699:	88 0a                	mov    %cl,(%edx)
  80069b:	83 c2 01             	add    $0x1,%edx
  80069e:	89 10                	mov    %edx,(%eax)
}
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006af:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	e8 02 00 00 00       	call   8006ca <vprintfmt>
	va_end(ap);
}
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	57                   	push   %edi
  8006ce:	56                   	push   %esi
  8006cf:	53                   	push   %ebx
  8006d0:	83 ec 5c             	sub    $0x5c,%esp
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006d9:	eb 12                	jmp    8006ed <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	0f 84 e4 04 00 00    	je     800bc7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ed:	0f b6 06             	movzbl (%esi),%eax
  8006f0:	83 c6 01             	add    $0x1,%esi
  8006f3:	83 f8 25             	cmp    $0x25,%eax
  8006f6:	75 e3                	jne    8006db <vprintfmt+0x11>
  8006f8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8006fc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800703:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800708:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800717:	eb 2b                	jmp    800744 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800719:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80071c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800720:	eb 22                	jmp    800744 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800725:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800729:	eb 19                	jmp    800744 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80072e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800735:	eb 0d                	jmp    800744 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800737:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80073a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80073d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800744:	0f b6 06             	movzbl (%esi),%eax
  800747:	0f b6 d0             	movzbl %al,%edx
  80074a:	8d 7e 01             	lea    0x1(%esi),%edi
  80074d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800750:	83 e8 23             	sub    $0x23,%eax
  800753:	3c 55                	cmp    $0x55,%al
  800755:	0f 87 46 04 00 00    	ja     800ba1 <vprintfmt+0x4d7>
  80075b:	0f b6 c0             	movzbl %al,%eax
  80075e:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800765:	83 ea 30             	sub    $0x30,%edx
  800768:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80076b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80076f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800775:	83 fa 09             	cmp    $0x9,%edx
  800778:	77 4a                	ja     8007c4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80077d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800780:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800783:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800787:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80078a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80078d:	83 fa 09             	cmp    $0x9,%edx
  800790:	76 eb                	jbe    80077d <vprintfmt+0xb3>
  800792:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800795:	eb 2d                	jmp    8007c4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a8:	eb 1a                	jmp    8007c4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007ad:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007b1:	79 91                	jns    800744 <vprintfmt+0x7a>
  8007b3:	e9 73 ff ff ff       	jmp    80072b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007c2:	eb 80                	jmp    800744 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007c4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007c8:	0f 89 76 ff ff ff    	jns    800744 <vprintfmt+0x7a>
  8007ce:	e9 64 ff ff ff       	jmp    800737 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007d9:	e9 66 ff ff ff       	jmp    800744 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007f6:	e9 f2 fe ff ff       	jmp    8006ed <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007fb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8007ff:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800802:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800806:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800809:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80080d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800810:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800813:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800817:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80081a:	80 f9 09             	cmp    $0x9,%cl
  80081d:	77 1d                	ja     80083c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80081f:	0f be c0             	movsbl %al,%eax
  800822:	6b c0 64             	imul   $0x64,%eax,%eax
  800825:	0f be d2             	movsbl %dl,%edx
  800828:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80082b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800832:	a3 04 20 80 00       	mov    %eax,0x802004
  800837:	e9 b1 fe ff ff       	jmp    8006ed <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80083c:	c7 44 24 04 b6 13 80 	movl   $0x8013b6,0x4(%esp)
  800843:	00 
  800844:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 0c 05 00 00       	call   800d5b <strcmp>
  80084f:	85 c0                	test   %eax,%eax
  800851:	75 0f                	jne    800862 <vprintfmt+0x198>
  800853:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80085a:	00 00 00 
  80085d:	e9 8b fe ff ff       	jmp    8006ed <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800862:	c7 44 24 04 ba 13 80 	movl   $0x8013ba,0x4(%esp)
  800869:	00 
  80086a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80086d:	89 14 24             	mov    %edx,(%esp)
  800870:	e8 e6 04 00 00       	call   800d5b <strcmp>
  800875:	85 c0                	test   %eax,%eax
  800877:	75 0f                	jne    800888 <vprintfmt+0x1be>
  800879:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800880:	00 00 00 
  800883:	e9 65 fe ff ff       	jmp    8006ed <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800888:	c7 44 24 04 be 13 80 	movl   $0x8013be,0x4(%esp)
  80088f:	00 
  800890:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800893:	89 0c 24             	mov    %ecx,(%esp)
  800896:	e8 c0 04 00 00       	call   800d5b <strcmp>
  80089b:	85 c0                	test   %eax,%eax
  80089d:	75 0f                	jne    8008ae <vprintfmt+0x1e4>
  80089f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8008a6:	00 00 00 
  8008a9:	e9 3f fe ff ff       	jmp    8006ed <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008ae:	c7 44 24 04 c2 13 80 	movl   $0x8013c2,0x4(%esp)
  8008b5:	00 
  8008b6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008b9:	89 3c 24             	mov    %edi,(%esp)
  8008bc:	e8 9a 04 00 00       	call   800d5b <strcmp>
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	75 0f                	jne    8008d4 <vprintfmt+0x20a>
  8008c5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008cc:	00 00 00 
  8008cf:	e9 19 fe ff ff       	jmp    8006ed <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008d4:	c7 44 24 04 c6 13 80 	movl   $0x8013c6,0x4(%esp)
  8008db:	00 
  8008dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008df:	89 04 24             	mov    %eax,(%esp)
  8008e2:	e8 74 04 00 00       	call   800d5b <strcmp>
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	75 0f                	jne    8008fa <vprintfmt+0x230>
  8008eb:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008f2:	00 00 00 
  8008f5:	e9 f3 fd ff ff       	jmp    8006ed <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008fa:	c7 44 24 04 ca 13 80 	movl   $0x8013ca,0x4(%esp)
  800901:	00 
  800902:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800905:	89 14 24             	mov    %edx,(%esp)
  800908:	e8 4e 04 00 00       	call   800d5b <strcmp>
  80090d:	83 f8 01             	cmp    $0x1,%eax
  800910:	19 c0                	sbb    %eax,%eax
  800912:	f7 d0                	not    %eax
  800914:	83 c0 08             	add    $0x8,%eax
  800917:	a3 04 20 80 00       	mov    %eax,0x802004
  80091c:	e9 cc fd ff ff       	jmp    8006ed <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800921:	8b 45 14             	mov    0x14(%ebp),%eax
  800924:	8d 50 04             	lea    0x4(%eax),%edx
  800927:	89 55 14             	mov    %edx,0x14(%ebp)
  80092a:	8b 00                	mov    (%eax),%eax
  80092c:	89 c2                	mov    %eax,%edx
  80092e:	c1 fa 1f             	sar    $0x1f,%edx
  800931:	31 d0                	xor    %edx,%eax
  800933:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800935:	83 f8 08             	cmp    $0x8,%eax
  800938:	7f 0b                	jg     800945 <vprintfmt+0x27b>
  80093a:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800941:	85 d2                	test   %edx,%edx
  800943:	75 23                	jne    800968 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800945:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800949:	c7 44 24 08 ce 13 80 	movl   $0x8013ce,0x8(%esp)
  800950:	00 
  800951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800955:	8b 7d 08             	mov    0x8(%ebp),%edi
  800958:	89 3c 24             	mov    %edi,(%esp)
  80095b:	e8 42 fd ff ff       	call   8006a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800963:	e9 85 fd ff ff       	jmp    8006ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800968:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80096c:	c7 44 24 08 d7 13 80 	movl   $0x8013d7,0x8(%esp)
  800973:	00 
  800974:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800978:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097b:	89 3c 24             	mov    %edi,(%esp)
  80097e:	e8 1f fd ff ff       	call   8006a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800983:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800986:	e9 62 fd ff ff       	jmp    8006ed <vprintfmt+0x23>
  80098b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80098e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800991:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8d 50 04             	lea    0x4(%eax),%edx
  80099a:	89 55 14             	mov    %edx,0x14(%ebp)
  80099d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80099f:	85 f6                	test   %esi,%esi
  8009a1:	b8 af 13 80 00       	mov    $0x8013af,%eax
  8009a6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009a9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009ad:	7e 06                	jle    8009b5 <vprintfmt+0x2eb>
  8009af:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009b3:	75 13                	jne    8009c8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b5:	0f be 06             	movsbl (%esi),%eax
  8009b8:	83 c6 01             	add    $0x1,%esi
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	0f 85 94 00 00 00    	jne    800a57 <vprintfmt+0x38d>
  8009c3:	e9 81 00 00 00       	jmp    800a49 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cc:	89 34 24             	mov    %esi,(%esp)
  8009cf:	e8 97 02 00 00       	call   800c6b <strnlen>
  8009d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009d7:	29 c2                	sub    %eax,%edx
  8009d9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009dc:	85 d2                	test   %edx,%edx
  8009de:	7e d5                	jle    8009b5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009e0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009e4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009e7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009ea:	89 d6                	mov    %edx,%esi
  8009ec:	89 cf                	mov    %ecx,%edi
  8009ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f2:	89 3c 24             	mov    %edi,(%esp)
  8009f5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f8:	83 ee 01             	sub    $0x1,%esi
  8009fb:	75 f1                	jne    8009ee <vprintfmt+0x324>
  8009fd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a00:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a03:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a06:	eb ad                	jmp    8009b5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a08:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a0c:	74 1b                	je     800a29 <vprintfmt+0x35f>
  800a0e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a11:	83 fa 5e             	cmp    $0x5e,%edx
  800a14:	76 13                	jbe    800a29 <vprintfmt+0x35f>
					putch('?', putdat);
  800a16:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a24:	ff 55 08             	call   *0x8(%ebp)
  800a27:	eb 0d                	jmp    800a36 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a29:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a2c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a30:	89 04 24             	mov    %eax,(%esp)
  800a33:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a36:	83 eb 01             	sub    $0x1,%ebx
  800a39:	0f be 06             	movsbl (%esi),%eax
  800a3c:	83 c6 01             	add    $0x1,%esi
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	75 1a                	jne    800a5d <vprintfmt+0x393>
  800a43:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a46:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a49:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a4c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a50:	7f 1c                	jg     800a6e <vprintfmt+0x3a4>
  800a52:	e9 96 fc ff ff       	jmp    8006ed <vprintfmt+0x23>
  800a57:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a5a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a5d:	85 ff                	test   %edi,%edi
  800a5f:	78 a7                	js     800a08 <vprintfmt+0x33e>
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	79 a2                	jns    800a08 <vprintfmt+0x33e>
  800a66:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a69:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a6c:	eb db                	jmp    800a49 <vprintfmt+0x37f>
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	89 de                	mov    %ebx,%esi
  800a73:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a81:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a83:	83 eb 01             	sub    $0x1,%ebx
  800a86:	75 ee                	jne    800a76 <vprintfmt+0x3ac>
  800a88:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a8d:	e9 5b fc ff ff       	jmp    8006ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a92:	83 f9 01             	cmp    $0x1,%ecx
  800a95:	7e 10                	jle    800aa7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a97:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9a:	8d 50 08             	lea    0x8(%eax),%edx
  800a9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa0:	8b 30                	mov    (%eax),%esi
  800aa2:	8b 78 04             	mov    0x4(%eax),%edi
  800aa5:	eb 26                	jmp    800acd <vprintfmt+0x403>
	else if (lflag)
  800aa7:	85 c9                	test   %ecx,%ecx
  800aa9:	74 12                	je     800abd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800aab:	8b 45 14             	mov    0x14(%ebp),%eax
  800aae:	8d 50 04             	lea    0x4(%eax),%edx
  800ab1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab4:	8b 30                	mov    (%eax),%esi
  800ab6:	89 f7                	mov    %esi,%edi
  800ab8:	c1 ff 1f             	sar    $0x1f,%edi
  800abb:	eb 10                	jmp    800acd <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800abd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac0:	8d 50 04             	lea    0x4(%eax),%edx
  800ac3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac6:	8b 30                	mov    (%eax),%esi
  800ac8:	89 f7                	mov    %esi,%edi
  800aca:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800acd:	85 ff                	test   %edi,%edi
  800acf:	78 0e                	js     800adf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad1:	89 f0                	mov    %esi,%eax
  800ad3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad5:	be 0a 00 00 00       	mov    $0xa,%esi
  800ada:	e9 84 00 00 00       	jmp    800b63 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aed:	89 f0                	mov    %esi,%eax
  800aef:	89 fa                	mov    %edi,%edx
  800af1:	f7 d8                	neg    %eax
  800af3:	83 d2 00             	adc    $0x0,%edx
  800af6:	f7 da                	neg    %edx
			}
			base = 10;
  800af8:	be 0a 00 00 00       	mov    $0xa,%esi
  800afd:	eb 64                	jmp    800b63 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aff:	89 ca                	mov    %ecx,%edx
  800b01:	8d 45 14             	lea    0x14(%ebp),%eax
  800b04:	e8 42 fb ff ff       	call   80064b <getuint>
			base = 10;
  800b09:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b0e:	eb 53                	jmp    800b63 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b10:	89 ca                	mov    %ecx,%edx
  800b12:	8d 45 14             	lea    0x14(%ebp),%eax
  800b15:	e8 31 fb ff ff       	call   80064b <getuint>
    			base = 8;
  800b1a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b1f:	eb 42                	jmp    800b63 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b25:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b2c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b33:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b3a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b40:	8d 50 04             	lea    0x4(%eax),%edx
  800b43:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b46:	8b 00                	mov    (%eax),%eax
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b4d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b52:	eb 0f                	jmp    800b63 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b54:	89 ca                	mov    %ecx,%edx
  800b56:	8d 45 14             	lea    0x14(%ebp),%eax
  800b59:	e8 ed fa ff ff       	call   80064b <getuint>
			base = 16;
  800b5e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b63:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b67:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b6b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b6e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b72:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b76:	89 04 24             	mov    %eax,(%esp)
  800b79:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b7d:	89 da                	mov    %ebx,%edx
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	e8 e9 f9 ff ff       	call   800570 <printnum>
			break;
  800b87:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b8a:	e9 5e fb ff ff       	jmp    8006ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b93:	89 14 24             	mov    %edx,(%esp)
  800b96:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b99:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b9c:	e9 4c fb ff ff       	jmp    8006ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ba1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bac:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800baf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bb3:	0f 84 34 fb ff ff    	je     8006ed <vprintfmt+0x23>
  800bb9:	83 ee 01             	sub    $0x1,%esi
  800bbc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bc0:	75 f7                	jne    800bb9 <vprintfmt+0x4ef>
  800bc2:	e9 26 fb ff ff       	jmp    8006ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bc7:	83 c4 5c             	add    $0x5c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 28             	sub    $0x28,%esp
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bde:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800be2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800be5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	74 30                	je     800c20 <vsnprintf+0x51>
  800bf0:	85 d2                	test   %edx,%edx
  800bf2:	7e 2c                	jle    800c20 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bf4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bfb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c02:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c09:	c7 04 24 85 06 80 00 	movl   $0x800685,(%esp)
  800c10:	e8 b5 fa ff ff       	call   8006ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c18:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1e:	eb 05                	jmp    800c25 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c2d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c34:	8b 45 10             	mov    0x10(%ebp),%eax
  800c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	e8 82 ff ff ff       	call   800bcf <vsnprintf>
	va_end(ap);

	return rc;
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    
	...

00800c50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c56:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c5e:	74 09                	je     800c69 <strlen+0x19>
		n++;
  800c60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c67:	75 f7                	jne    800c60 <strlen+0x10>
		n++;
	return n;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	53                   	push   %ebx
  800c6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7a:	85 c9                	test   %ecx,%ecx
  800c7c:	74 1a                	je     800c98 <strnlen+0x2d>
  800c7e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c81:	74 15                	je     800c98 <strnlen+0x2d>
  800c83:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c88:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c8a:	39 ca                	cmp    %ecx,%edx
  800c8c:	74 0a                	je     800c98 <strnlen+0x2d>
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c96:	75 f0                	jne    800c88 <strnlen+0x1d>
		n++;
	return n;
}
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  800caa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cb1:	83 c2 01             	add    $0x1,%edx
  800cb4:	84 c9                	test   %cl,%cl
  800cb6:	75 f2                	jne    800caa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 08             	sub    $0x8,%esp
  800cc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cc5:	89 1c 24             	mov    %ebx,(%esp)
  800cc8:	e8 83 ff ff ff       	call   800c50 <strlen>
	strcpy(dst + len, src);
  800ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cd4:	01 d8                	add    %ebx,%eax
  800cd6:	89 04 24             	mov    %eax,(%esp)
  800cd9:	e8 bd ff ff ff       	call   800c9b <strcpy>
	return dst;
}
  800cde:	89 d8                	mov    %ebx,%eax
  800ce0:	83 c4 08             	add    $0x8,%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf4:	85 f6                	test   %esi,%esi
  800cf6:	74 18                	je     800d10 <strncpy+0x2a>
  800cf8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800cfd:	0f b6 1a             	movzbl (%edx),%ebx
  800d00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d03:	80 3a 01             	cmpb   $0x1,(%edx)
  800d06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d09:	83 c1 01             	add    $0x1,%ecx
  800d0c:	39 f1                	cmp    %esi,%ecx
  800d0e:	75 ed                	jne    800cfd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d20:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d23:	89 f8                	mov    %edi,%eax
  800d25:	85 f6                	test   %esi,%esi
  800d27:	74 2b                	je     800d54 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d29:	83 fe 01             	cmp    $0x1,%esi
  800d2c:	74 23                	je     800d51 <strlcpy+0x3d>
  800d2e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d31:	84 c9                	test   %cl,%cl
  800d33:	74 1c                	je     800d51 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d35:	83 ee 02             	sub    $0x2,%esi
  800d38:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d3d:	88 08                	mov    %cl,(%eax)
  800d3f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d42:	39 f2                	cmp    %esi,%edx
  800d44:	74 0b                	je     800d51 <strlcpy+0x3d>
  800d46:	83 c2 01             	add    $0x1,%edx
  800d49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d4d:	84 c9                	test   %cl,%cl
  800d4f:	75 ec                	jne    800d3d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d54:	29 f8                	sub    %edi,%eax
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d64:	0f b6 01             	movzbl (%ecx),%eax
  800d67:	84 c0                	test   %al,%al
  800d69:	74 16                	je     800d81 <strcmp+0x26>
  800d6b:	3a 02                	cmp    (%edx),%al
  800d6d:	75 12                	jne    800d81 <strcmp+0x26>
		p++, q++;
  800d6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d72:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d76:	84 c0                	test   %al,%al
  800d78:	74 07                	je     800d81 <strcmp+0x26>
  800d7a:	83 c1 01             	add    $0x1,%ecx
  800d7d:	3a 02                	cmp    (%edx),%al
  800d7f:	74 ee                	je     800d6f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d81:	0f b6 c0             	movzbl %al,%eax
  800d84:	0f b6 12             	movzbl (%edx),%edx
  800d87:	29 d0                	sub    %edx,%eax
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	53                   	push   %ebx
  800d8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d95:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d98:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d9d:	85 d2                	test   %edx,%edx
  800d9f:	74 28                	je     800dc9 <strncmp+0x3e>
  800da1:	0f b6 01             	movzbl (%ecx),%eax
  800da4:	84 c0                	test   %al,%al
  800da6:	74 24                	je     800dcc <strncmp+0x41>
  800da8:	3a 03                	cmp    (%ebx),%al
  800daa:	75 20                	jne    800dcc <strncmp+0x41>
  800dac:	83 ea 01             	sub    $0x1,%edx
  800daf:	74 13                	je     800dc4 <strncmp+0x39>
		n--, p++, q++;
  800db1:	83 c1 01             	add    $0x1,%ecx
  800db4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800db7:	0f b6 01             	movzbl (%ecx),%eax
  800dba:	84 c0                	test   %al,%al
  800dbc:	74 0e                	je     800dcc <strncmp+0x41>
  800dbe:	3a 03                	cmp    (%ebx),%al
  800dc0:	74 ea                	je     800dac <strncmp+0x21>
  800dc2:	eb 08                	jmp    800dcc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dc4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dcc:	0f b6 01             	movzbl (%ecx),%eax
  800dcf:	0f b6 13             	movzbl (%ebx),%edx
  800dd2:	29 d0                	sub    %edx,%eax
  800dd4:	eb f3                	jmp    800dc9 <strncmp+0x3e>

00800dd6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de0:	0f b6 10             	movzbl (%eax),%edx
  800de3:	84 d2                	test   %dl,%dl
  800de5:	74 1c                	je     800e03 <strchr+0x2d>
		if (*s == c)
  800de7:	38 ca                	cmp    %cl,%dl
  800de9:	75 09                	jne    800df4 <strchr+0x1e>
  800deb:	eb 1b                	jmp    800e08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ded:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800df0:	38 ca                	cmp    %cl,%dl
  800df2:	74 14                	je     800e08 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800df8:	84 d2                	test   %dl,%dl
  800dfa:	75 f1                	jne    800ded <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	eb 05                	jmp    800e08 <strchr+0x32>
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e14:	0f b6 10             	movzbl (%eax),%edx
  800e17:	84 d2                	test   %dl,%dl
  800e19:	74 14                	je     800e2f <strfind+0x25>
		if (*s == c)
  800e1b:	38 ca                	cmp    %cl,%dl
  800e1d:	75 06                	jne    800e25 <strfind+0x1b>
  800e1f:	eb 0e                	jmp    800e2f <strfind+0x25>
  800e21:	38 ca                	cmp    %cl,%dl
  800e23:	74 0a                	je     800e2f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e25:	83 c0 01             	add    $0x1,%eax
  800e28:	0f b6 10             	movzbl (%eax),%edx
  800e2b:	84 d2                	test   %dl,%dl
  800e2d:	75 f2                	jne    800e21 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e49:	85 c9                	test   %ecx,%ecx
  800e4b:	74 30                	je     800e7d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e53:	75 25                	jne    800e7a <memset+0x49>
  800e55:	f6 c1 03             	test   $0x3,%cl
  800e58:	75 20                	jne    800e7a <memset+0x49>
		c &= 0xFF;
  800e5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e5d:	89 d3                	mov    %edx,%ebx
  800e5f:	c1 e3 08             	shl    $0x8,%ebx
  800e62:	89 d6                	mov    %edx,%esi
  800e64:	c1 e6 18             	shl    $0x18,%esi
  800e67:	89 d0                	mov    %edx,%eax
  800e69:	c1 e0 10             	shl    $0x10,%eax
  800e6c:	09 f0                	or     %esi,%eax
  800e6e:	09 d0                	or     %edx,%eax
  800e70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e75:	fc                   	cld    
  800e76:	f3 ab                	rep stos %eax,%es:(%edi)
  800e78:	eb 03                	jmp    800e7d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e7a:	fc                   	cld    
  800e7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e7d:	89 f8                	mov    %edi,%eax
  800e7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e88:	89 ec                	mov    %ebp,%esp
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e95:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ea1:	39 c6                	cmp    %eax,%esi
  800ea3:	73 36                	jae    800edb <memmove+0x4f>
  800ea5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ea8:	39 d0                	cmp    %edx,%eax
  800eaa:	73 2f                	jae    800edb <memmove+0x4f>
		s += n;
		d += n;
  800eac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eaf:	f6 c2 03             	test   $0x3,%dl
  800eb2:	75 1b                	jne    800ecf <memmove+0x43>
  800eb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eba:	75 13                	jne    800ecf <memmove+0x43>
  800ebc:	f6 c1 03             	test   $0x3,%cl
  800ebf:	75 0e                	jne    800ecf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ec1:	83 ef 04             	sub    $0x4,%edi
  800ec4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ec7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eca:	fd                   	std    
  800ecb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ecd:	eb 09                	jmp    800ed8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ecf:	83 ef 01             	sub    $0x1,%edi
  800ed2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ed5:	fd                   	std    
  800ed6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ed8:	fc                   	cld    
  800ed9:	eb 20                	jmp    800efb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ee1:	75 13                	jne    800ef6 <memmove+0x6a>
  800ee3:	a8 03                	test   $0x3,%al
  800ee5:	75 0f                	jne    800ef6 <memmove+0x6a>
  800ee7:	f6 c1 03             	test   $0x3,%cl
  800eea:	75 0a                	jne    800ef6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800eef:	89 c7                	mov    %eax,%edi
  800ef1:	fc                   	cld    
  800ef2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ef4:	eb 05                	jmp    800efb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ef6:	89 c7                	mov    %eax,%edi
  800ef8:	fc                   	cld    
  800ef9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800efb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800efe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f01:	89 ec                	mov    %ebp,%esp
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	89 04 24             	mov    %eax,(%esp)
  800f1f:	e8 68 ff ff ff       	call   800e8c <memmove>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f32:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f3a:	85 ff                	test   %edi,%edi
  800f3c:	74 37                	je     800f75 <memcmp+0x4f>
		if (*s1 != *s2)
  800f3e:	0f b6 03             	movzbl (%ebx),%eax
  800f41:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f44:	83 ef 01             	sub    $0x1,%edi
  800f47:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f4c:	38 c8                	cmp    %cl,%al
  800f4e:	74 1c                	je     800f6c <memcmp+0x46>
  800f50:	eb 10                	jmp    800f62 <memcmp+0x3c>
  800f52:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f57:	83 c2 01             	add    $0x1,%edx
  800f5a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f5e:	38 c8                	cmp    %cl,%al
  800f60:	74 0a                	je     800f6c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f62:	0f b6 c0             	movzbl %al,%eax
  800f65:	0f b6 c9             	movzbl %cl,%ecx
  800f68:	29 c8                	sub    %ecx,%eax
  800f6a:	eb 09                	jmp    800f75 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f6c:	39 fa                	cmp    %edi,%edx
  800f6e:	75 e2                	jne    800f52 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f80:	89 c2                	mov    %eax,%edx
  800f82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f85:	39 d0                	cmp    %edx,%eax
  800f87:	73 19                	jae    800fa2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f8d:	38 08                	cmp    %cl,(%eax)
  800f8f:	75 06                	jne    800f97 <memfind+0x1d>
  800f91:	eb 0f                	jmp    800fa2 <memfind+0x28>
  800f93:	38 08                	cmp    %cl,(%eax)
  800f95:	74 0b                	je     800fa2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f97:	83 c0 01             	add    $0x1,%eax
  800f9a:	39 d0                	cmp    %edx,%eax
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	75 f1                	jne    800f93 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
  800fad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb0:	0f b6 02             	movzbl (%edx),%eax
  800fb3:	3c 20                	cmp    $0x20,%al
  800fb5:	74 04                	je     800fbb <strtol+0x17>
  800fb7:	3c 09                	cmp    $0x9,%al
  800fb9:	75 0e                	jne    800fc9 <strtol+0x25>
		s++;
  800fbb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fbe:	0f b6 02             	movzbl (%edx),%eax
  800fc1:	3c 20                	cmp    $0x20,%al
  800fc3:	74 f6                	je     800fbb <strtol+0x17>
  800fc5:	3c 09                	cmp    $0x9,%al
  800fc7:	74 f2                	je     800fbb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fc9:	3c 2b                	cmp    $0x2b,%al
  800fcb:	75 0a                	jne    800fd7 <strtol+0x33>
		s++;
  800fcd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fd5:	eb 10                	jmp    800fe7 <strtol+0x43>
  800fd7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fdc:	3c 2d                	cmp    $0x2d,%al
  800fde:	75 07                	jne    800fe7 <strtol+0x43>
		s++, neg = 1;
  800fe0:	83 c2 01             	add    $0x1,%edx
  800fe3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe7:	85 db                	test   %ebx,%ebx
  800fe9:	0f 94 c0             	sete   %al
  800fec:	74 05                	je     800ff3 <strtol+0x4f>
  800fee:	83 fb 10             	cmp    $0x10,%ebx
  800ff1:	75 15                	jne    801008 <strtol+0x64>
  800ff3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff6:	75 10                	jne    801008 <strtol+0x64>
  800ff8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ffc:	75 0a                	jne    801008 <strtol+0x64>
		s += 2, base = 16;
  800ffe:	83 c2 02             	add    $0x2,%edx
  801001:	bb 10 00 00 00       	mov    $0x10,%ebx
  801006:	eb 13                	jmp    80101b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801008:	84 c0                	test   %al,%al
  80100a:	74 0f                	je     80101b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80100c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801011:	80 3a 30             	cmpb   $0x30,(%edx)
  801014:	75 05                	jne    80101b <strtol+0x77>
		s++, base = 8;
  801016:	83 c2 01             	add    $0x1,%edx
  801019:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
  801020:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801022:	0f b6 0a             	movzbl (%edx),%ecx
  801025:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801028:	80 fb 09             	cmp    $0x9,%bl
  80102b:	77 08                	ja     801035 <strtol+0x91>
			dig = *s - '0';
  80102d:	0f be c9             	movsbl %cl,%ecx
  801030:	83 e9 30             	sub    $0x30,%ecx
  801033:	eb 1e                	jmp    801053 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801035:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801038:	80 fb 19             	cmp    $0x19,%bl
  80103b:	77 08                	ja     801045 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80103d:	0f be c9             	movsbl %cl,%ecx
  801040:	83 e9 57             	sub    $0x57,%ecx
  801043:	eb 0e                	jmp    801053 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801045:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801048:	80 fb 19             	cmp    $0x19,%bl
  80104b:	77 14                	ja     801061 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80104d:	0f be c9             	movsbl %cl,%ecx
  801050:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801053:	39 f1                	cmp    %esi,%ecx
  801055:	7d 0e                	jge    801065 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801057:	83 c2 01             	add    $0x1,%edx
  80105a:	0f af c6             	imul   %esi,%eax
  80105d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80105f:	eb c1                	jmp    801022 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801061:	89 c1                	mov    %eax,%ecx
  801063:	eb 02                	jmp    801067 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801065:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801067:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80106b:	74 05                	je     801072 <strtol+0xce>
		*endptr = (char *) s;
  80106d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801070:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801072:	89 ca                	mov    %ecx,%edx
  801074:	f7 da                	neg    %edx
  801076:	85 ff                	test   %edi,%edi
  801078:	0f 45 c2             	cmovne %edx,%eax
}
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <__udivdi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801087:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80108b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80108f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801093:	89 74 24 10          	mov    %esi,0x10(%esp)
  801097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80109b:	85 ff                	test   %edi,%edi
  80109d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	89 cd                	mov    %ecx,%ebp
  8010a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ab:	75 33                	jne    8010e0 <__udivdi3+0x60>
  8010ad:	39 f1                	cmp    %esi,%ecx
  8010af:	77 57                	ja     801108 <__udivdi3+0x88>
  8010b1:	85 c9                	test   %ecx,%ecx
  8010b3:	75 0b                	jne    8010c0 <__udivdi3+0x40>
  8010b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ba:	31 d2                	xor    %edx,%edx
  8010bc:	f7 f1                	div    %ecx
  8010be:	89 c1                	mov    %eax,%ecx
  8010c0:	89 f0                	mov    %esi,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	f7 f1                	div    %ecx
  8010c6:	89 c6                	mov    %eax,%esi
  8010c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010cc:	f7 f1                	div    %ecx
  8010ce:	89 f2                	mov    %esi,%edx
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	31 d2                	xor    %edx,%edx
  8010e2:	31 c0                	xor    %eax,%eax
  8010e4:	39 f7                	cmp    %esi,%edi
  8010e6:	77 e8                	ja     8010d0 <__udivdi3+0x50>
  8010e8:	0f bd cf             	bsr    %edi,%ecx
  8010eb:	83 f1 1f             	xor    $0x1f,%ecx
  8010ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010f2:	75 2c                	jne    801120 <__udivdi3+0xa0>
  8010f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010f8:	76 04                	jbe    8010fe <__udivdi3+0x7e>
  8010fa:	39 f7                	cmp    %esi,%edi
  8010fc:	73 d2                	jae    8010d0 <__udivdi3+0x50>
  8010fe:	31 d2                	xor    %edx,%edx
  801100:	b8 01 00 00 00       	mov    $0x1,%eax
  801105:	eb c9                	jmp    8010d0 <__udivdi3+0x50>
  801107:	90                   	nop
  801108:	89 f2                	mov    %esi,%edx
  80110a:	f7 f1                	div    %ecx
  80110c:	31 d2                	xor    %edx,%edx
  80110e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801112:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801116:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111a:	83 c4 1c             	add    $0x1c,%esp
  80111d:	c3                   	ret    
  80111e:	66 90                	xchg   %ax,%ax
  801120:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801125:	b8 20 00 00 00       	mov    $0x20,%eax
  80112a:	89 ea                	mov    %ebp,%edx
  80112c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801130:	d3 e7                	shl    %cl,%edi
  801132:	89 c1                	mov    %eax,%ecx
  801134:	d3 ea                	shr    %cl,%edx
  801136:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113b:	09 fa                	or     %edi,%edx
  80113d:	89 f7                	mov    %esi,%edi
  80113f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801143:	89 f2                	mov    %esi,%edx
  801145:	8b 74 24 08          	mov    0x8(%esp),%esi
  801149:	d3 e5                	shl    %cl,%ebp
  80114b:	89 c1                	mov    %eax,%ecx
  80114d:	d3 ef                	shr    %cl,%edi
  80114f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801154:	d3 e2                	shl    %cl,%edx
  801156:	89 c1                	mov    %eax,%ecx
  801158:	d3 ee                	shr    %cl,%esi
  80115a:	09 d6                	or     %edx,%esi
  80115c:	89 fa                	mov    %edi,%edx
  80115e:	89 f0                	mov    %esi,%eax
  801160:	f7 74 24 0c          	divl   0xc(%esp)
  801164:	89 d7                	mov    %edx,%edi
  801166:	89 c6                	mov    %eax,%esi
  801168:	f7 e5                	mul    %ebp
  80116a:	39 d7                	cmp    %edx,%edi
  80116c:	72 22                	jb     801190 <__udivdi3+0x110>
  80116e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801172:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801177:	d3 e5                	shl    %cl,%ebp
  801179:	39 c5                	cmp    %eax,%ebp
  80117b:	73 04                	jae    801181 <__udivdi3+0x101>
  80117d:	39 d7                	cmp    %edx,%edi
  80117f:	74 0f                	je     801190 <__udivdi3+0x110>
  801181:	89 f0                	mov    %esi,%eax
  801183:	31 d2                	xor    %edx,%edx
  801185:	e9 46 ff ff ff       	jmp    8010d0 <__udivdi3+0x50>
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	8d 46 ff             	lea    -0x1(%esi),%eax
  801193:	31 d2                	xor    %edx,%edx
  801195:	8b 74 24 10          	mov    0x10(%esp),%esi
  801199:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80119d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a1:	83 c4 1c             	add    $0x1c,%esp
  8011a4:	c3                   	ret    
	...

008011b0 <__umoddi3>:
  8011b0:	83 ec 1c             	sub    $0x1c,%esp
  8011b3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011b7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011c3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011cb:	85 ed                	test   %ebp,%ebp
  8011cd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	89 cf                	mov    %ecx,%edi
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	89 f2                	mov    %esi,%edx
  8011dc:	75 1a                	jne    8011f8 <__umoddi3+0x48>
  8011de:	39 f1                	cmp    %esi,%ecx
  8011e0:	76 4e                	jbe    801230 <__umoddi3+0x80>
  8011e2:	f7 f1                	div    %ecx
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	31 d2                	xor    %edx,%edx
  8011e8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011ec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011f4:	83 c4 1c             	add    $0x1c,%esp
  8011f7:	c3                   	ret    
  8011f8:	39 f5                	cmp    %esi,%ebp
  8011fa:	77 54                	ja     801250 <__umoddi3+0xa0>
  8011fc:	0f bd c5             	bsr    %ebp,%eax
  8011ff:	83 f0 1f             	xor    $0x1f,%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	75 60                	jne    801268 <__umoddi3+0xb8>
  801208:	3b 0c 24             	cmp    (%esp),%ecx
  80120b:	0f 87 07 01 00 00    	ja     801318 <__umoddi3+0x168>
  801211:	89 f2                	mov    %esi,%edx
  801213:	8b 34 24             	mov    (%esp),%esi
  801216:	29 ce                	sub    %ecx,%esi
  801218:	19 ea                	sbb    %ebp,%edx
  80121a:	89 34 24             	mov    %esi,(%esp)
  80121d:	8b 04 24             	mov    (%esp),%eax
  801220:	8b 74 24 10          	mov    0x10(%esp),%esi
  801224:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801228:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122c:	83 c4 1c             	add    $0x1c,%esp
  80122f:	c3                   	ret    
  801230:	85 c9                	test   %ecx,%ecx
  801232:	75 0b                	jne    80123f <__umoddi3+0x8f>
  801234:	b8 01 00 00 00       	mov    $0x1,%eax
  801239:	31 d2                	xor    %edx,%edx
  80123b:	f7 f1                	div    %ecx
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	89 f0                	mov    %esi,%eax
  801241:	31 d2                	xor    %edx,%edx
  801243:	f7 f1                	div    %ecx
  801245:	8b 04 24             	mov    (%esp),%eax
  801248:	f7 f1                	div    %ecx
  80124a:	eb 98                	jmp    8011e4 <__umoddi3+0x34>
  80124c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 f2                	mov    %esi,%edx
  801252:	8b 74 24 10          	mov    0x10(%esp),%esi
  801256:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80125a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80125e:	83 c4 1c             	add    $0x1c,%esp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126d:	89 e8                	mov    %ebp,%eax
  80126f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801274:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801278:	89 fa                	mov    %edi,%edx
  80127a:	d3 e0                	shl    %cl,%eax
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 ea                	shr    %cl,%edx
  801280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801285:	09 c2                	or     %eax,%edx
  801287:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128b:	89 14 24             	mov    %edx,(%esp)
  80128e:	89 f2                	mov    %esi,%edx
  801290:	d3 e7                	shl    %cl,%edi
  801292:	89 e9                	mov    %ebp,%ecx
  801294:	d3 ea                	shr    %cl,%edx
  801296:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80129f:	d3 e6                	shl    %cl,%esi
  8012a1:	89 e9                	mov    %ebp,%ecx
  8012a3:	d3 e8                	shr    %cl,%eax
  8012a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012aa:	09 f0                	or     %esi,%eax
  8012ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012b0:	f7 34 24             	divl   (%esp)
  8012b3:	d3 e6                	shl    %cl,%esi
  8012b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012b9:	89 d6                	mov    %edx,%esi
  8012bb:	f7 e7                	mul    %edi
  8012bd:	39 d6                	cmp    %edx,%esi
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	89 d7                	mov    %edx,%edi
  8012c3:	72 3f                	jb     801304 <__umoddi3+0x154>
  8012c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012c9:	72 35                	jb     801300 <__umoddi3+0x150>
  8012cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cf:	29 c8                	sub    %ecx,%eax
  8012d1:	19 fe                	sbb    %edi,%esi
  8012d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d8:	89 f2                	mov    %esi,%edx
  8012da:	d3 e8                	shr    %cl,%eax
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012e5:	09 d0                	or     %edx,%eax
  8012e7:	89 f2                	mov    %esi,%edx
  8012e9:	d3 ea                	shr    %cl,%edx
  8012eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012f7:	83 c4 1c             	add    $0x1c,%esp
  8012fa:	c3                   	ret    
  8012fb:	90                   	nop
  8012fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 d6                	cmp    %edx,%esi
  801302:	75 c7                	jne    8012cb <__umoddi3+0x11b>
  801304:	89 d7                	mov    %edx,%edi
  801306:	89 c1                	mov    %eax,%ecx
  801308:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80130c:	1b 3c 24             	sbb    (%esp),%edi
  80130f:	eb ba                	jmp    8012cb <__umoddi3+0x11b>
  801311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801318:	39 f5                	cmp    %esi,%ebp
  80131a:	0f 82 f1 fe ff ff    	jb     801211 <__umoddi3+0x61>
  801320:	e9 f8 fe ff ff       	jmp    80121d <__umoddi3+0x6d>
