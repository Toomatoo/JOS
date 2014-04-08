
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 a2 01 00 00       	call   8001f8 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 07 03 00 00       	call   800371 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008a:	e8 09 01 00 00       	call   800198 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 61 00 00 00       	call   80013b <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 c3                	mov    %eax,%ebx
  8000f8:	89 c7                	mov    %eax,%edi
  8000fa:	89 c6                	mov    %eax,%esi
  8000fc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800101:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800104:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_cgetc>:

int
sys_cgetc(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800114:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800117:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 01 00 00 00       	mov    $0x1,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800131:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800134:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800137:	89 ec                	mov    %ebp,%esp
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 38             	sub    $0x38,%esp
  800141:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800144:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800147:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014f:	b8 03 00 00 00       	mov    $0x3,%eax
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	89 cb                	mov    %ecx,%ebx
  800159:	89 cf                	mov    %ecx,%edi
  80015b:	89 ce                	mov    %ecx,%esi
  80015d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80015f:	85 c0                	test   %eax,%eax
  800161:	7e 28                	jle    80018b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800163:	89 44 24 10          	mov    %eax,0x10(%esp)
  800167:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80016e:	00 
  80016f:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800186:	e8 d5 02 00 00       	call   800460 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80018b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800191:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b1:	89 d1                	mov    %edx,%ecx
  8001b3:	89 d3                	mov    %edx,%ebx
  8001b5:	89 d7                	mov    %edx,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c4:	89 ec                	mov    %ebp,%esp
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <sys_yield>:

void
sys_yield(void)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	89 d3                	mov    %edx,%ebx
  8001e5:	89 d7                	mov    %edx,%edi
  8001e7:	89 d6                	mov    %edx,%esi
  8001e9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001f4:	89 ec                	mov    %ebp,%esp
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 38             	sub    $0x38,%esp
  8001fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800201:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800204:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	be 00 00 00 00       	mov    $0x0,%esi
  80020c:	b8 04 00 00 00       	mov    $0x4,%eax
  800211:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	89 f7                	mov    %esi,%edi
  80021c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7e 28                	jle    80024a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800222:	89 44 24 10          	mov    %eax,0x10(%esp)
  800226:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80022d:	00 
  80022e:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800235:	00 
  800236:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023d:	00 
  80023e:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800245:	e8 16 02 00 00       	call   800460 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80024a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80024d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800250:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800253:	89 ec                	mov    %ebp,%esp
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 38             	sub    $0x38,%esp
  80025d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800260:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800263:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800266:	b8 05 00 00 00       	mov    $0x5,%eax
  80026b:	8b 75 18             	mov    0x18(%ebp),%esi
  80026e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800271:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 28                	jle    8002a8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	89 44 24 10          	mov    %eax,0x10(%esp)
  800284:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80028b:	00 
  80028c:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800293:	00 
  800294:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029b:	00 
  80029c:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  8002a3:	e8 b8 01 00 00       	call   800460 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b1:	89 ec                	mov    %ebp,%esp
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 38             	sub    $0x38,%esp
  8002bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 28                	jle    800306 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002e9:	00 
  8002ea:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f9:	00 
  8002fa:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800301:	e8 5a 01 00 00       	call   800460 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800306:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800309:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80030c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80030f:	89 ec                	mov    %ebp,%esp
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 38             	sub    $0x38,%esp
  800319:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80031c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80031f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 08 00 00 00       	mov    $0x8,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  80035f:	e8 fc 00 00 00       	call   800460 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800364:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800367:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80036a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80036d:	89 ec                	mov    %ebp,%esp
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 38             	sub    $0x38,%esp
  800377:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80037a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80037d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800380:	bb 00 00 00 00       	mov    $0x0,%ebx
  800385:	b8 09 00 00 00       	mov    $0x9,%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	89 df                	mov    %ebx,%edi
  800392:	89 de                	mov    %ebx,%esi
  800394:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800396:	85 c0                	test   %eax,%eax
  800398:	7e 28                	jle    8003c2 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003a5:	00 
  8003a6:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  8003ad:	00 
  8003ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b5:	00 
  8003b6:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  8003bd:	e8 9e 00 00 00       	call   800460 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003cb:	89 ec                	mov    %ebp,%esp
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 0c             	sub    $0xc,%esp
  8003d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	be 00 00 00 00       	mov    $0x0,%esi
  8003e3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003e8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003ff:	89 ec                	mov    %ebp,%esp
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 38             	sub    $0x38,%esp
  800409:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80040c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80040f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	b8 0c 00 00 00       	mov    $0xc,%eax
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	89 cb                	mov    %ecx,%ebx
  800421:	89 cf                	mov    %ecx,%edi
  800423:	89 ce                	mov    %ecx,%esi
  800425:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800427:	85 c0                	test   %eax,%eax
  800429:	7e 28                	jle    800453 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80042b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80042f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800436:	00 
  800437:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  80044e:	e8 0d 00 00 00       	call   800460 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800453:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800456:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800459:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80045c:	89 ec                	mov    %ebp,%esp
  80045e:	5d                   	pop    %ebp
  80045f:	c3                   	ret    

00800460 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800471:	e8 22 fd ff ff       	call   800198 <sys_getenvid>
  800476:	8b 55 0c             	mov    0xc(%ebp),%edx
  800479:	89 54 24 10          	mov    %edx,0x10(%esp)
  80047d:	8b 55 08             	mov    0x8(%ebp),%edx
  800480:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800484:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	c7 04 24 78 13 80 00 	movl   $0x801378,(%esp)
  800493:	e8 c3 00 00 00       	call   80055b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800498:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049c:	8b 45 10             	mov    0x10(%ebp),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	e8 53 00 00 00       	call   8004fa <vcprintf>
	cprintf("\n");
  8004a7:	c7 04 24 9c 13 80 00 	movl   $0x80139c,(%esp)
  8004ae:	e8 a8 00 00 00       	call   80055b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b3:	cc                   	int3   
  8004b4:	eb fd                	jmp    8004b3 <_panic+0x53>
	...

008004b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	53                   	push   %ebx
  8004bc:	83 ec 14             	sub    $0x14,%esp
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004c2:	8b 03                	mov    (%ebx),%eax
  8004c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004cb:	83 c0 01             	add    $0x1,%eax
  8004ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d5:	75 19                	jne    8004f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004de:	00 
  8004df:	8d 43 08             	lea    0x8(%ebx),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	e8 f2 fb ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  8004ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f4:	83 c4 14             	add    $0x14,%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800503:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80050a:	00 00 00 
	b.cnt = 0;
  80050d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800514:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800517:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	89 44 24 08          	mov    %eax,0x8(%esp)
  800525:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	c7 04 24 b8 04 80 00 	movl   $0x8004b8,(%esp)
  800536:	e8 97 01 00 00       	call   8006d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80053b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800541:	89 44 24 04          	mov    %eax,0x4(%esp)
  800545:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	e8 89 fb ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  800553:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800559:	c9                   	leave  
  80055a:	c3                   	ret    

0080055b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800561:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800564:	89 44 24 04          	mov    %eax,0x4(%esp)
  800568:	8b 45 08             	mov    0x8(%ebp),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	e8 87 ff ff ff       	call   8004fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800573:	c9                   	leave  
  800574:	c3                   	ret    
  800575:	00 00                	add    %al,(%eax)
	...

00800578 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	57                   	push   %edi
  80057c:	56                   	push   %esi
  80057d:	53                   	push   %ebx
  80057e:	83 ec 3c             	sub    $0x3c,%esp
  800581:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800584:	89 d7                	mov    %edx,%edi
  800586:	8b 45 08             	mov    0x8(%ebp),%eax
  800589:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80058c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800592:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800595:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800598:	b8 00 00 00 00       	mov    $0x0,%eax
  80059d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005a0:	72 11                	jb     8005b3 <printnum+0x3b>
  8005a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005a8:	76 09                	jbe    8005b3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005aa:	83 eb 01             	sub    $0x1,%ebx
  8005ad:	85 db                	test   %ebx,%ebx
  8005af:	7f 51                	jg     800602 <printnum+0x8a>
  8005b1:	eb 5e                	jmp    800611 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005b7:	83 eb 01             	sub    $0x1,%ebx
  8005ba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005be:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005c9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d4:	00 
  8005d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e2:	e8 a9 0a 00 00       	call   801090 <__udivdi3>
  8005e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f6:	89 fa                	mov    %edi,%edx
  8005f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fb:	e8 78 ff ff ff       	call   800578 <printnum>
  800600:	eb 0f                	jmp    800611 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	89 34 24             	mov    %esi,(%esp)
  800609:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80060c:	83 eb 01             	sub    $0x1,%ebx
  80060f:	75 f1                	jne    800602 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800611:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800615:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800619:	8b 45 10             	mov    0x10(%ebp),%eax
  80061c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800620:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800627:	00 
  800628:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800631:	89 44 24 04          	mov    %eax,0x4(%esp)
  800635:	e8 86 0b 00 00       	call   8011c0 <__umoddi3>
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	0f be 80 9e 13 80 00 	movsbl 0x80139e(%eax),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80064b:	83 c4 3c             	add    $0x3c,%esp
  80064e:	5b                   	pop    %ebx
  80064f:	5e                   	pop    %esi
  800650:	5f                   	pop    %edi
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800656:	83 fa 01             	cmp    $0x1,%edx
  800659:	7e 0e                	jle    800669 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800660:	89 08                	mov    %ecx,(%eax)
  800662:	8b 02                	mov    (%edx),%eax
  800664:	8b 52 04             	mov    0x4(%edx),%edx
  800667:	eb 22                	jmp    80068b <getuint+0x38>
	else if (lflag)
  800669:	85 d2                	test   %edx,%edx
  80066b:	74 10                	je     80067d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800672:	89 08                	mov    %ecx,(%eax)
  800674:	8b 02                	mov    (%edx),%eax
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
  80067b:	eb 0e                	jmp    80068b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800682:	89 08                	mov    %ecx,(%eax)
  800684:	8b 02                	mov    (%edx),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800693:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800697:	8b 10                	mov    (%eax),%edx
  800699:	3b 50 04             	cmp    0x4(%eax),%edx
  80069c:	73 0a                	jae    8006a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80069e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a1:	88 0a                	mov    %cl,(%edx)
  8006a3:	83 c2 01             	add    $0x1,%edx
  8006a6:	89 10                	mov    %edx,(%eax)
}
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	e8 02 00 00 00       	call   8006d2 <vprintfmt>
	va_end(ap);
}
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 5c             	sub    $0x5c,%esp
  8006db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006de:	8b 75 10             	mov    0x10(%ebp),%esi
  8006e1:	eb 12                	jmp    8006f5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	0f 84 e4 04 00 00    	je     800bcf <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f5:	0f b6 06             	movzbl (%esi),%eax
  8006f8:	83 c6 01             	add    $0x1,%esi
  8006fb:	83 f8 25             	cmp    $0x25,%eax
  8006fe:	75 e3                	jne    8006e3 <vprintfmt+0x11>
  800700:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800704:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80070b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800710:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800717:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80071f:	eb 2b                	jmp    80074c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800724:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800728:	eb 22                	jmp    80074c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80072d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800731:	eb 19                	jmp    80074c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800736:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80073d:	eb 0d                	jmp    80074c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80073f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800742:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800745:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074c:	0f b6 06             	movzbl (%esi),%eax
  80074f:	0f b6 d0             	movzbl %al,%edx
  800752:	8d 7e 01             	lea    0x1(%esi),%edi
  800755:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800758:	83 e8 23             	sub    $0x23,%eax
  80075b:	3c 55                	cmp    $0x55,%al
  80075d:	0f 87 46 04 00 00    	ja     800ba9 <vprintfmt+0x4d7>
  800763:	0f b6 c0             	movzbl %al,%eax
  800766:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80076d:	83 ea 30             	sub    $0x30,%edx
  800770:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800773:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800777:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80077d:	83 fa 09             	cmp    $0x9,%edx
  800780:	77 4a                	ja     8007cc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800785:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800788:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80078b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80078f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800792:	8d 50 d0             	lea    -0x30(%eax),%edx
  800795:	83 fa 09             	cmp    $0x9,%edx
  800798:	76 eb                	jbe    800785 <vprintfmt+0xb3>
  80079a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80079d:	eb 2d                	jmp    8007cc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 04             	lea    0x4(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007b0:	eb 1a                	jmp    8007cc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007b5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007b9:	79 91                	jns    80074c <vprintfmt+0x7a>
  8007bb:	e9 73 ff ff ff       	jmp    800733 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007ca:	eb 80                	jmp    80074c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007d0:	0f 89 76 ff ff ff    	jns    80074c <vprintfmt+0x7a>
  8007d6:	e9 64 ff ff ff       	jmp    80073f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007db:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007de:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007e1:	e9 66 ff ff ff       	jmp    80074c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f3:	8b 00                	mov    (%eax),%eax
  8007f5:	89 04 24             	mov    %eax,(%esp)
  8007f8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007fe:	e9 f2 fe ff ff       	jmp    8006f5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800803:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800807:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80080a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80080e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800811:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800815:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800818:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80081b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80081f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800822:	80 f9 09             	cmp    $0x9,%cl
  800825:	77 1d                	ja     800844 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800827:	0f be c0             	movsbl %al,%eax
  80082a:	6b c0 64             	imul   $0x64,%eax,%eax
  80082d:	0f be d2             	movsbl %dl,%edx
  800830:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800833:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80083a:	a3 04 20 80 00       	mov    %eax,0x802004
  80083f:	e9 b1 fe ff ff       	jmp    8006f5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800844:	c7 44 24 04 b6 13 80 	movl   $0x8013b6,0x4(%esp)
  80084b:	00 
  80084c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 14 05 00 00       	call   800d6b <strcmp>
  800857:	85 c0                	test   %eax,%eax
  800859:	75 0f                	jne    80086a <vprintfmt+0x198>
  80085b:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800862:	00 00 00 
  800865:	e9 8b fe ff ff       	jmp    8006f5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80086a:	c7 44 24 04 ba 13 80 	movl   $0x8013ba,0x4(%esp)
  800871:	00 
  800872:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800875:	89 14 24             	mov    %edx,(%esp)
  800878:	e8 ee 04 00 00       	call   800d6b <strcmp>
  80087d:	85 c0                	test   %eax,%eax
  80087f:	75 0f                	jne    800890 <vprintfmt+0x1be>
  800881:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800888:	00 00 00 
  80088b:	e9 65 fe ff ff       	jmp    8006f5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800890:	c7 44 24 04 be 13 80 	movl   $0x8013be,0x4(%esp)
  800897:	00 
  800898:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80089b:	89 0c 24             	mov    %ecx,(%esp)
  80089e:	e8 c8 04 00 00       	call   800d6b <strcmp>
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	75 0f                	jne    8008b6 <vprintfmt+0x1e4>
  8008a7:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8008ae:	00 00 00 
  8008b1:	e9 3f fe ff ff       	jmp    8006f5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008b6:	c7 44 24 04 c2 13 80 	movl   $0x8013c2,0x4(%esp)
  8008bd:	00 
  8008be:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008c1:	89 3c 24             	mov    %edi,(%esp)
  8008c4:	e8 a2 04 00 00       	call   800d6b <strcmp>
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	75 0f                	jne    8008dc <vprintfmt+0x20a>
  8008cd:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008d4:	00 00 00 
  8008d7:	e9 19 fe ff ff       	jmp    8006f5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008dc:	c7 44 24 04 c6 13 80 	movl   $0x8013c6,0x4(%esp)
  8008e3:	00 
  8008e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	e8 7c 04 00 00       	call   800d6b <strcmp>
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	75 0f                	jne    800902 <vprintfmt+0x230>
  8008f3:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008fa:	00 00 00 
  8008fd:	e9 f3 fd ff ff       	jmp    8006f5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800902:	c7 44 24 04 ca 13 80 	movl   $0x8013ca,0x4(%esp)
  800909:	00 
  80090a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80090d:	89 14 24             	mov    %edx,(%esp)
  800910:	e8 56 04 00 00       	call   800d6b <strcmp>
  800915:	83 f8 01             	cmp    $0x1,%eax
  800918:	19 c0                	sbb    %eax,%eax
  80091a:	f7 d0                	not    %eax
  80091c:	83 c0 08             	add    $0x8,%eax
  80091f:	a3 04 20 80 00       	mov    %eax,0x802004
  800924:	e9 cc fd ff ff       	jmp    8006f5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8d 50 04             	lea    0x4(%eax),%edx
  80092f:	89 55 14             	mov    %edx,0x14(%ebp)
  800932:	8b 00                	mov    (%eax),%eax
  800934:	89 c2                	mov    %eax,%edx
  800936:	c1 fa 1f             	sar    $0x1f,%edx
  800939:	31 d0                	xor    %edx,%eax
  80093b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093d:	83 f8 08             	cmp    $0x8,%eax
  800940:	7f 0b                	jg     80094d <vprintfmt+0x27b>
  800942:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800949:	85 d2                	test   %edx,%edx
  80094b:	75 23                	jne    800970 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80094d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800951:	c7 44 24 08 ce 13 80 	movl   $0x8013ce,0x8(%esp)
  800958:	00 
  800959:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800960:	89 3c 24             	mov    %edi,(%esp)
  800963:	e8 42 fd ff ff       	call   8006aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80096b:	e9 85 fd ff ff       	jmp    8006f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800970:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800974:	c7 44 24 08 d7 13 80 	movl   $0x8013d7,0x8(%esp)
  80097b:	00 
  80097c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800980:	8b 7d 08             	mov    0x8(%ebp),%edi
  800983:	89 3c 24             	mov    %edi,(%esp)
  800986:	e8 1f fd ff ff       	call   8006aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80098e:	e9 62 fd ff ff       	jmp    8006f5 <vprintfmt+0x23>
  800993:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800996:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800999:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8d 50 04             	lea    0x4(%eax),%edx
  8009a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009a7:	85 f6                	test   %esi,%esi
  8009a9:	b8 af 13 80 00       	mov    $0x8013af,%eax
  8009ae:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009b1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009b5:	7e 06                	jle    8009bd <vprintfmt+0x2eb>
  8009b7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009bb:	75 13                	jne    8009d0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009bd:	0f be 06             	movsbl (%esi),%eax
  8009c0:	83 c6 01             	add    $0x1,%esi
  8009c3:	85 c0                	test   %eax,%eax
  8009c5:	0f 85 94 00 00 00    	jne    800a5f <vprintfmt+0x38d>
  8009cb:	e9 81 00 00 00       	jmp    800a51 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d4:	89 34 24             	mov    %esi,(%esp)
  8009d7:	e8 9f 02 00 00       	call   800c7b <strnlen>
  8009dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009df:	29 c2                	sub    %eax,%edx
  8009e1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009e4:	85 d2                	test   %edx,%edx
  8009e6:	7e d5                	jle    8009bd <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009e8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009ec:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009ef:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009f2:	89 d6                	mov    %edx,%esi
  8009f4:	89 cf                	mov    %ecx,%edi
  8009f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fa:	89 3c 24             	mov    %edi,(%esp)
  8009fd:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a00:	83 ee 01             	sub    $0x1,%esi
  800a03:	75 f1                	jne    8009f6 <vprintfmt+0x324>
  800a05:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a08:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a0b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a0e:	eb ad                	jmp    8009bd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a10:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a14:	74 1b                	je     800a31 <vprintfmt+0x35f>
  800a16:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a19:	83 fa 5e             	cmp    $0x5e,%edx
  800a1c:	76 13                	jbe    800a31 <vprintfmt+0x35f>
					putch('?', putdat);
  800a1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a2c:	ff 55 08             	call   *0x8(%ebp)
  800a2f:	eb 0d                	jmp    800a3e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a31:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a34:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a38:	89 04 24             	mov    %eax,(%esp)
  800a3b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3e:	83 eb 01             	sub    $0x1,%ebx
  800a41:	0f be 06             	movsbl (%esi),%eax
  800a44:	83 c6 01             	add    $0x1,%esi
  800a47:	85 c0                	test   %eax,%eax
  800a49:	75 1a                	jne    800a65 <vprintfmt+0x393>
  800a4b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a4e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a51:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a54:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a58:	7f 1c                	jg     800a76 <vprintfmt+0x3a4>
  800a5a:	e9 96 fc ff ff       	jmp    8006f5 <vprintfmt+0x23>
  800a5f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a62:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a65:	85 ff                	test   %edi,%edi
  800a67:	78 a7                	js     800a10 <vprintfmt+0x33e>
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	79 a2                	jns    800a10 <vprintfmt+0x33e>
  800a6e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a71:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a74:	eb db                	jmp    800a51 <vprintfmt+0x37f>
  800a76:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a79:	89 de                	mov    %ebx,%esi
  800a7b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a82:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a89:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a8b:	83 eb 01             	sub    $0x1,%ebx
  800a8e:	75 ee                	jne    800a7e <vprintfmt+0x3ac>
  800a90:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a92:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a95:	e9 5b fc ff ff       	jmp    8006f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a9a:	83 f9 01             	cmp    $0x1,%ecx
  800a9d:	7e 10                	jle    800aaf <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa2:	8d 50 08             	lea    0x8(%eax),%edx
  800aa5:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa8:	8b 30                	mov    (%eax),%esi
  800aaa:	8b 78 04             	mov    0x4(%eax),%edi
  800aad:	eb 26                	jmp    800ad5 <vprintfmt+0x403>
	else if (lflag)
  800aaf:	85 c9                	test   %ecx,%ecx
  800ab1:	74 12                	je     800ac5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800ab3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab6:	8d 50 04             	lea    0x4(%eax),%edx
  800ab9:	89 55 14             	mov    %edx,0x14(%ebp)
  800abc:	8b 30                	mov    (%eax),%esi
  800abe:	89 f7                	mov    %esi,%edi
  800ac0:	c1 ff 1f             	sar    $0x1f,%edi
  800ac3:	eb 10                	jmp    800ad5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8d 50 04             	lea    0x4(%eax),%edx
  800acb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ace:	8b 30                	mov    (%eax),%esi
  800ad0:	89 f7                	mov    %esi,%edi
  800ad2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	78 0e                	js     800ae7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800add:	be 0a 00 00 00       	mov    $0xa,%esi
  800ae2:	e9 84 00 00 00       	jmp    800b6b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ae7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aeb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800af2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800af5:	89 f0                	mov    %esi,%eax
  800af7:	89 fa                	mov    %edi,%edx
  800af9:	f7 d8                	neg    %eax
  800afb:	83 d2 00             	adc    $0x0,%edx
  800afe:	f7 da                	neg    %edx
			}
			base = 10;
  800b00:	be 0a 00 00 00       	mov    $0xa,%esi
  800b05:	eb 64                	jmp    800b6b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b07:	89 ca                	mov    %ecx,%edx
  800b09:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0c:	e8 42 fb ff ff       	call   800653 <getuint>
			base = 10;
  800b11:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b16:	eb 53                	jmp    800b6b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b18:	89 ca                	mov    %ecx,%edx
  800b1a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1d:	e8 31 fb ff ff       	call   800653 <getuint>
    			base = 8;
  800b22:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b27:	eb 42                	jmp    800b6b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b2d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b34:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b42:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b45:	8b 45 14             	mov    0x14(%ebp),%eax
  800b48:	8d 50 04             	lea    0x4(%eax),%edx
  800b4b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b4e:	8b 00                	mov    (%eax),%eax
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b55:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b5a:	eb 0f                	jmp    800b6b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b5c:	89 ca                	mov    %ecx,%edx
  800b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b61:	e8 ed fa ff ff       	call   800653 <getuint>
			base = 16;
  800b66:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b6b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b6f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b73:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b76:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b7a:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b7e:	89 04 24             	mov    %eax,(%esp)
  800b81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b85:	89 da                	mov    %ebx,%edx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	e8 e9 f9 ff ff       	call   800578 <printnum>
			break;
  800b8f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b92:	e9 5e fb ff ff       	jmp    8006f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9b:	89 14 24             	mov    %edx,(%esp)
  800b9e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ba1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ba4:	e9 4c fb ff ff       	jmp    8006f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ba9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bad:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bb4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bb7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bbb:	0f 84 34 fb ff ff    	je     8006f5 <vprintfmt+0x23>
  800bc1:	83 ee 01             	sub    $0x1,%esi
  800bc4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bc8:	75 f7                	jne    800bc1 <vprintfmt+0x4ef>
  800bca:	e9 26 fb ff ff       	jmp    8006f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bcf:	83 c4 5c             	add    $0x5c,%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 28             	sub    $0x28,%esp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	74 30                	je     800c28 <vsnprintf+0x51>
  800bf8:	85 d2                	test   %edx,%edx
  800bfa:	7e 2c                	jle    800c28 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c03:	8b 45 10             	mov    0x10(%ebp),%eax
  800c06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c11:	c7 04 24 8d 06 80 00 	movl   $0x80068d,(%esp)
  800c18:	e8 b5 fa ff ff       	call   8006d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c20:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c26:	eb 05                	jmp    800c2d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c35:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c38:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	89 04 24             	mov    %eax,(%esp)
  800c50:	e8 82 ff ff ff       	call   800bd7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    
	...

00800c60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c6e:	74 09                	je     800c79 <strlen+0x19>
		n++;
  800c70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c77:	75 f7                	jne    800c70 <strlen+0x10>
		n++;
	return n;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8a:	85 c9                	test   %ecx,%ecx
  800c8c:	74 1a                	je     800ca8 <strnlen+0x2d>
  800c8e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c91:	74 15                	je     800ca8 <strnlen+0x2d>
  800c93:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c98:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c9a:	39 ca                	cmp    %ecx,%edx
  800c9c:	74 0a                	je     800ca8 <strnlen+0x2d>
  800c9e:	83 c2 01             	add    $0x1,%edx
  800ca1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ca6:	75 f0                	jne    800c98 <strnlen+0x1d>
		n++;
	return n;
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cbe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cc1:	83 c2 01             	add    $0x1,%edx
  800cc4:	84 c9                	test   %cl,%cl
  800cc6:	75 f2                	jne    800cba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 08             	sub    $0x8,%esp
  800cd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cd5:	89 1c 24             	mov    %ebx,(%esp)
  800cd8:	e8 83 ff ff ff       	call   800c60 <strlen>
	strcpy(dst + len, src);
  800cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ce4:	01 d8                	add    %ebx,%eax
  800ce6:	89 04 24             	mov    %eax,(%esp)
  800ce9:	e8 bd ff ff ff       	call   800cab <strcpy>
	return dst;
}
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	83 c4 08             	add    $0x8,%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d04:	85 f6                	test   %esi,%esi
  800d06:	74 18                	je     800d20 <strncpy+0x2a>
  800d08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d0d:	0f b6 1a             	movzbl (%edx),%ebx
  800d10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d13:	80 3a 01             	cmpb   $0x1,(%edx)
  800d16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d19:	83 c1 01             	add    $0x1,%ecx
  800d1c:	39 f1                	cmp    %esi,%ecx
  800d1e:	75 ed                	jne    800d0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d30:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d33:	89 f8                	mov    %edi,%eax
  800d35:	85 f6                	test   %esi,%esi
  800d37:	74 2b                	je     800d64 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d39:	83 fe 01             	cmp    $0x1,%esi
  800d3c:	74 23                	je     800d61 <strlcpy+0x3d>
  800d3e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d41:	84 c9                	test   %cl,%cl
  800d43:	74 1c                	je     800d61 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d45:	83 ee 02             	sub    $0x2,%esi
  800d48:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d4d:	88 08                	mov    %cl,(%eax)
  800d4f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d52:	39 f2                	cmp    %esi,%edx
  800d54:	74 0b                	je     800d61 <strlcpy+0x3d>
  800d56:	83 c2 01             	add    $0x1,%edx
  800d59:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d5d:	84 c9                	test   %cl,%cl
  800d5f:	75 ec                	jne    800d4d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d64:	29 f8                	sub    %edi,%eax
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d74:	0f b6 01             	movzbl (%ecx),%eax
  800d77:	84 c0                	test   %al,%al
  800d79:	74 16                	je     800d91 <strcmp+0x26>
  800d7b:	3a 02                	cmp    (%edx),%al
  800d7d:	75 12                	jne    800d91 <strcmp+0x26>
		p++, q++;
  800d7f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d82:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d86:	84 c0                	test   %al,%al
  800d88:	74 07                	je     800d91 <strcmp+0x26>
  800d8a:	83 c1 01             	add    $0x1,%ecx
  800d8d:	3a 02                	cmp    (%edx),%al
  800d8f:	74 ee                	je     800d7f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d91:	0f b6 c0             	movzbl %al,%eax
  800d94:	0f b6 12             	movzbl (%edx),%edx
  800d97:	29 d0                	sub    %edx,%eax
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800da8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dad:	85 d2                	test   %edx,%edx
  800daf:	74 28                	je     800dd9 <strncmp+0x3e>
  800db1:	0f b6 01             	movzbl (%ecx),%eax
  800db4:	84 c0                	test   %al,%al
  800db6:	74 24                	je     800ddc <strncmp+0x41>
  800db8:	3a 03                	cmp    (%ebx),%al
  800dba:	75 20                	jne    800ddc <strncmp+0x41>
  800dbc:	83 ea 01             	sub    $0x1,%edx
  800dbf:	74 13                	je     800dd4 <strncmp+0x39>
		n--, p++, q++;
  800dc1:	83 c1 01             	add    $0x1,%ecx
  800dc4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dc7:	0f b6 01             	movzbl (%ecx),%eax
  800dca:	84 c0                	test   %al,%al
  800dcc:	74 0e                	je     800ddc <strncmp+0x41>
  800dce:	3a 03                	cmp    (%ebx),%al
  800dd0:	74 ea                	je     800dbc <strncmp+0x21>
  800dd2:	eb 08                	jmp    800ddc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddc:	0f b6 01             	movzbl (%ecx),%eax
  800ddf:	0f b6 13             	movzbl (%ebx),%edx
  800de2:	29 d0                	sub    %edx,%eax
  800de4:	eb f3                	jmp    800dd9 <strncmp+0x3e>

00800de6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df0:	0f b6 10             	movzbl (%eax),%edx
  800df3:	84 d2                	test   %dl,%dl
  800df5:	74 1c                	je     800e13 <strchr+0x2d>
		if (*s == c)
  800df7:	38 ca                	cmp    %cl,%dl
  800df9:	75 09                	jne    800e04 <strchr+0x1e>
  800dfb:	eb 1b                	jmp    800e18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800e00:	38 ca                	cmp    %cl,%dl
  800e02:	74 14                	je     800e18 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e04:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800e08:	84 d2                	test   %dl,%dl
  800e0a:	75 f1                	jne    800dfd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e11:	eb 05                	jmp    800e18 <strchr+0x32>
  800e13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e24:	0f b6 10             	movzbl (%eax),%edx
  800e27:	84 d2                	test   %dl,%dl
  800e29:	74 14                	je     800e3f <strfind+0x25>
		if (*s == c)
  800e2b:	38 ca                	cmp    %cl,%dl
  800e2d:	75 06                	jne    800e35 <strfind+0x1b>
  800e2f:	eb 0e                	jmp    800e3f <strfind+0x25>
  800e31:	38 ca                	cmp    %cl,%dl
  800e33:	74 0a                	je     800e3f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e35:	83 c0 01             	add    $0x1,%eax
  800e38:	0f b6 10             	movzbl (%eax),%edx
  800e3b:	84 d2                	test   %dl,%dl
  800e3d:	75 f2                	jne    800e31 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e59:	85 c9                	test   %ecx,%ecx
  800e5b:	74 30                	je     800e8d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e63:	75 25                	jne    800e8a <memset+0x49>
  800e65:	f6 c1 03             	test   $0x3,%cl
  800e68:	75 20                	jne    800e8a <memset+0x49>
		c &= 0xFF;
  800e6a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6d:	89 d3                	mov    %edx,%ebx
  800e6f:	c1 e3 08             	shl    $0x8,%ebx
  800e72:	89 d6                	mov    %edx,%esi
  800e74:	c1 e6 18             	shl    $0x18,%esi
  800e77:	89 d0                	mov    %edx,%eax
  800e79:	c1 e0 10             	shl    $0x10,%eax
  800e7c:	09 f0                	or     %esi,%eax
  800e7e:	09 d0                	or     %edx,%eax
  800e80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e82:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e85:	fc                   	cld    
  800e86:	f3 ab                	rep stos %eax,%es:(%edi)
  800e88:	eb 03                	jmp    800e8d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8a:	fc                   	cld    
  800e8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e8d:	89 f8                	mov    %edi,%eax
  800e8f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e92:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e95:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e98:	89 ec                	mov    %ebp,%esp
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800eb1:	39 c6                	cmp    %eax,%esi
  800eb3:	73 36                	jae    800eeb <memmove+0x4f>
  800eb5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eb8:	39 d0                	cmp    %edx,%eax
  800eba:	73 2f                	jae    800eeb <memmove+0x4f>
		s += n;
		d += n;
  800ebc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebf:	f6 c2 03             	test   $0x3,%dl
  800ec2:	75 1b                	jne    800edf <memmove+0x43>
  800ec4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eca:	75 13                	jne    800edf <memmove+0x43>
  800ecc:	f6 c1 03             	test   $0x3,%cl
  800ecf:	75 0e                	jne    800edf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ed1:	83 ef 04             	sub    $0x4,%edi
  800ed4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ed7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eda:	fd                   	std    
  800edb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800edd:	eb 09                	jmp    800ee8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800edf:	83 ef 01             	sub    $0x1,%edi
  800ee2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ee5:	fd                   	std    
  800ee6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ee8:	fc                   	cld    
  800ee9:	eb 20                	jmp    800f0b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eeb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ef1:	75 13                	jne    800f06 <memmove+0x6a>
  800ef3:	a8 03                	test   $0x3,%al
  800ef5:	75 0f                	jne    800f06 <memmove+0x6a>
  800ef7:	f6 c1 03             	test   $0x3,%cl
  800efa:	75 0a                	jne    800f06 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800efc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800eff:	89 c7                	mov    %eax,%edi
  800f01:	fc                   	cld    
  800f02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f04:	eb 05                	jmp    800f0b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f06:	89 c7                	mov    %eax,%edi
  800f08:	fc                   	cld    
  800f09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f11:	89 ec                	mov    %ebp,%esp
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	89 04 24             	mov    %eax,(%esp)
  800f2f:	e8 68 ff ff ff       	call   800e9c <memmove>
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	53                   	push   %ebx
  800f3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f42:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4a:	85 ff                	test   %edi,%edi
  800f4c:	74 37                	je     800f85 <memcmp+0x4f>
		if (*s1 != *s2)
  800f4e:	0f b6 03             	movzbl (%ebx),%eax
  800f51:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f54:	83 ef 01             	sub    $0x1,%edi
  800f57:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f5c:	38 c8                	cmp    %cl,%al
  800f5e:	74 1c                	je     800f7c <memcmp+0x46>
  800f60:	eb 10                	jmp    800f72 <memcmp+0x3c>
  800f62:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f67:	83 c2 01             	add    $0x1,%edx
  800f6a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f6e:	38 c8                	cmp    %cl,%al
  800f70:	74 0a                	je     800f7c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f72:	0f b6 c0             	movzbl %al,%eax
  800f75:	0f b6 c9             	movzbl %cl,%ecx
  800f78:	29 c8                	sub    %ecx,%eax
  800f7a:	eb 09                	jmp    800f85 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f7c:	39 fa                	cmp    %edi,%edx
  800f7e:	75 e2                	jne    800f62 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f90:	89 c2                	mov    %eax,%edx
  800f92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f95:	39 d0                	cmp    %edx,%eax
  800f97:	73 19                	jae    800fb2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f9d:	38 08                	cmp    %cl,(%eax)
  800f9f:	75 06                	jne    800fa7 <memfind+0x1d>
  800fa1:	eb 0f                	jmp    800fb2 <memfind+0x28>
  800fa3:	38 08                	cmp    %cl,(%eax)
  800fa5:	74 0b                	je     800fb2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fa7:	83 c0 01             	add    $0x1,%eax
  800faa:	39 d0                	cmp    %edx,%eax
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	75 f1                	jne    800fa3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fc0:	0f b6 02             	movzbl (%edx),%eax
  800fc3:	3c 20                	cmp    $0x20,%al
  800fc5:	74 04                	je     800fcb <strtol+0x17>
  800fc7:	3c 09                	cmp    $0x9,%al
  800fc9:	75 0e                	jne    800fd9 <strtol+0x25>
		s++;
  800fcb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fce:	0f b6 02             	movzbl (%edx),%eax
  800fd1:	3c 20                	cmp    $0x20,%al
  800fd3:	74 f6                	je     800fcb <strtol+0x17>
  800fd5:	3c 09                	cmp    $0x9,%al
  800fd7:	74 f2                	je     800fcb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fd9:	3c 2b                	cmp    $0x2b,%al
  800fdb:	75 0a                	jne    800fe7 <strtol+0x33>
		s++;
  800fdd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fe0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe5:	eb 10                	jmp    800ff7 <strtol+0x43>
  800fe7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fec:	3c 2d                	cmp    $0x2d,%al
  800fee:	75 07                	jne    800ff7 <strtol+0x43>
		s++, neg = 1;
  800ff0:	83 c2 01             	add    $0x1,%edx
  800ff3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ff7:	85 db                	test   %ebx,%ebx
  800ff9:	0f 94 c0             	sete   %al
  800ffc:	74 05                	je     801003 <strtol+0x4f>
  800ffe:	83 fb 10             	cmp    $0x10,%ebx
  801001:	75 15                	jne    801018 <strtol+0x64>
  801003:	80 3a 30             	cmpb   $0x30,(%edx)
  801006:	75 10                	jne    801018 <strtol+0x64>
  801008:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80100c:	75 0a                	jne    801018 <strtol+0x64>
		s += 2, base = 16;
  80100e:	83 c2 02             	add    $0x2,%edx
  801011:	bb 10 00 00 00       	mov    $0x10,%ebx
  801016:	eb 13                	jmp    80102b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801018:	84 c0                	test   %al,%al
  80101a:	74 0f                	je     80102b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80101c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801021:	80 3a 30             	cmpb   $0x30,(%edx)
  801024:	75 05                	jne    80102b <strtol+0x77>
		s++, base = 8;
  801026:	83 c2 01             	add    $0x1,%edx
  801029:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
  801030:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801032:	0f b6 0a             	movzbl (%edx),%ecx
  801035:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801038:	80 fb 09             	cmp    $0x9,%bl
  80103b:	77 08                	ja     801045 <strtol+0x91>
			dig = *s - '0';
  80103d:	0f be c9             	movsbl %cl,%ecx
  801040:	83 e9 30             	sub    $0x30,%ecx
  801043:	eb 1e                	jmp    801063 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801045:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801048:	80 fb 19             	cmp    $0x19,%bl
  80104b:	77 08                	ja     801055 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80104d:	0f be c9             	movsbl %cl,%ecx
  801050:	83 e9 57             	sub    $0x57,%ecx
  801053:	eb 0e                	jmp    801063 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801055:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801058:	80 fb 19             	cmp    $0x19,%bl
  80105b:	77 14                	ja     801071 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80105d:	0f be c9             	movsbl %cl,%ecx
  801060:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801063:	39 f1                	cmp    %esi,%ecx
  801065:	7d 0e                	jge    801075 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801067:	83 c2 01             	add    $0x1,%edx
  80106a:	0f af c6             	imul   %esi,%eax
  80106d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80106f:	eb c1                	jmp    801032 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801071:	89 c1                	mov    %eax,%ecx
  801073:	eb 02                	jmp    801077 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801075:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801077:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80107b:	74 05                	je     801082 <strtol+0xce>
		*endptr = (char *) s;
  80107d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801080:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801082:	89 ca                	mov    %ecx,%edx
  801084:	f7 da                	neg    %edx
  801086:	85 ff                	test   %edi,%edi
  801088:	0f 45 c2             	cmovne %edx,%eax
}
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <__udivdi3>:
  801090:	83 ec 1c             	sub    $0x1c,%esp
  801093:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801097:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80109b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80109f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010ab:	85 ff                	test   %edi,%edi
  8010ad:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b5:	89 cd                	mov    %ecx,%ebp
  8010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bb:	75 33                	jne    8010f0 <__udivdi3+0x60>
  8010bd:	39 f1                	cmp    %esi,%ecx
  8010bf:	77 57                	ja     801118 <__udivdi3+0x88>
  8010c1:	85 c9                	test   %ecx,%ecx
  8010c3:	75 0b                	jne    8010d0 <__udivdi3+0x40>
  8010c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ca:	31 d2                	xor    %edx,%edx
  8010cc:	f7 f1                	div    %ecx
  8010ce:	89 c1                	mov    %eax,%ecx
  8010d0:	89 f0                	mov    %esi,%eax
  8010d2:	31 d2                	xor    %edx,%edx
  8010d4:	f7 f1                	div    %ecx
  8010d6:	89 c6                	mov    %eax,%esi
  8010d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 f2                	mov    %esi,%edx
  8010e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ec:	83 c4 1c             	add    $0x1c,%esp
  8010ef:	c3                   	ret    
  8010f0:	31 d2                	xor    %edx,%edx
  8010f2:	31 c0                	xor    %eax,%eax
  8010f4:	39 f7                	cmp    %esi,%edi
  8010f6:	77 e8                	ja     8010e0 <__udivdi3+0x50>
  8010f8:	0f bd cf             	bsr    %edi,%ecx
  8010fb:	83 f1 1f             	xor    $0x1f,%ecx
  8010fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801102:	75 2c                	jne    801130 <__udivdi3+0xa0>
  801104:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801108:	76 04                	jbe    80110e <__udivdi3+0x7e>
  80110a:	39 f7                	cmp    %esi,%edi
  80110c:	73 d2                	jae    8010e0 <__udivdi3+0x50>
  80110e:	31 d2                	xor    %edx,%edx
  801110:	b8 01 00 00 00       	mov    $0x1,%eax
  801115:	eb c9                	jmp    8010e0 <__udivdi3+0x50>
  801117:	90                   	nop
  801118:	89 f2                	mov    %esi,%edx
  80111a:	f7 f1                	div    %ecx
  80111c:	31 d2                	xor    %edx,%edx
  80111e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801122:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801126:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80112a:	83 c4 1c             	add    $0x1c,%esp
  80112d:	c3                   	ret    
  80112e:	66 90                	xchg   %ax,%ax
  801130:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801135:	b8 20 00 00 00       	mov    $0x20,%eax
  80113a:	89 ea                	mov    %ebp,%edx
  80113c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801140:	d3 e7                	shl    %cl,%edi
  801142:	89 c1                	mov    %eax,%ecx
  801144:	d3 ea                	shr    %cl,%edx
  801146:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114b:	09 fa                	or     %edi,%edx
  80114d:	89 f7                	mov    %esi,%edi
  80114f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801153:	89 f2                	mov    %esi,%edx
  801155:	8b 74 24 08          	mov    0x8(%esp),%esi
  801159:	d3 e5                	shl    %cl,%ebp
  80115b:	89 c1                	mov    %eax,%ecx
  80115d:	d3 ef                	shr    %cl,%edi
  80115f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801164:	d3 e2                	shl    %cl,%edx
  801166:	89 c1                	mov    %eax,%ecx
  801168:	d3 ee                	shr    %cl,%esi
  80116a:	09 d6                	or     %edx,%esi
  80116c:	89 fa                	mov    %edi,%edx
  80116e:	89 f0                	mov    %esi,%eax
  801170:	f7 74 24 0c          	divl   0xc(%esp)
  801174:	89 d7                	mov    %edx,%edi
  801176:	89 c6                	mov    %eax,%esi
  801178:	f7 e5                	mul    %ebp
  80117a:	39 d7                	cmp    %edx,%edi
  80117c:	72 22                	jb     8011a0 <__udivdi3+0x110>
  80117e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801182:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801187:	d3 e5                	shl    %cl,%ebp
  801189:	39 c5                	cmp    %eax,%ebp
  80118b:	73 04                	jae    801191 <__udivdi3+0x101>
  80118d:	39 d7                	cmp    %edx,%edi
  80118f:	74 0f                	je     8011a0 <__udivdi3+0x110>
  801191:	89 f0                	mov    %esi,%eax
  801193:	31 d2                	xor    %edx,%edx
  801195:	e9 46 ff ff ff       	jmp    8010e0 <__udivdi3+0x50>
  80119a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011a9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011ad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011b1:	83 c4 1c             	add    $0x1c,%esp
  8011b4:	c3                   	ret    
	...

008011c0 <__umoddi3>:
  8011c0:	83 ec 1c             	sub    $0x1c,%esp
  8011c3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011c7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011d3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011db:	85 ed                	test   %ebp,%ebp
  8011dd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e5:	89 cf                	mov    %ecx,%edi
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	89 f2                	mov    %esi,%edx
  8011ec:	75 1a                	jne    801208 <__umoddi3+0x48>
  8011ee:	39 f1                	cmp    %esi,%ecx
  8011f0:	76 4e                	jbe    801240 <__umoddi3+0x80>
  8011f2:	f7 f1                	div    %ecx
  8011f4:	89 d0                	mov    %edx,%eax
  8011f6:	31 d2                	xor    %edx,%edx
  8011f8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801200:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801204:	83 c4 1c             	add    $0x1c,%esp
  801207:	c3                   	ret    
  801208:	39 f5                	cmp    %esi,%ebp
  80120a:	77 54                	ja     801260 <__umoddi3+0xa0>
  80120c:	0f bd c5             	bsr    %ebp,%eax
  80120f:	83 f0 1f             	xor    $0x1f,%eax
  801212:	89 44 24 04          	mov    %eax,0x4(%esp)
  801216:	75 60                	jne    801278 <__umoddi3+0xb8>
  801218:	3b 0c 24             	cmp    (%esp),%ecx
  80121b:	0f 87 07 01 00 00    	ja     801328 <__umoddi3+0x168>
  801221:	89 f2                	mov    %esi,%edx
  801223:	8b 34 24             	mov    (%esp),%esi
  801226:	29 ce                	sub    %ecx,%esi
  801228:	19 ea                	sbb    %ebp,%edx
  80122a:	89 34 24             	mov    %esi,(%esp)
  80122d:	8b 04 24             	mov    (%esp),%eax
  801230:	8b 74 24 10          	mov    0x10(%esp),%esi
  801234:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801238:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80123c:	83 c4 1c             	add    $0x1c,%esp
  80123f:	c3                   	ret    
  801240:	85 c9                	test   %ecx,%ecx
  801242:	75 0b                	jne    80124f <__umoddi3+0x8f>
  801244:	b8 01 00 00 00       	mov    $0x1,%eax
  801249:	31 d2                	xor    %edx,%edx
  80124b:	f7 f1                	div    %ecx
  80124d:	89 c1                	mov    %eax,%ecx
  80124f:	89 f0                	mov    %esi,%eax
  801251:	31 d2                	xor    %edx,%edx
  801253:	f7 f1                	div    %ecx
  801255:	8b 04 24             	mov    (%esp),%eax
  801258:	f7 f1                	div    %ecx
  80125a:	eb 98                	jmp    8011f4 <__umoddi3+0x34>
  80125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 f2                	mov    %esi,%edx
  801262:	8b 74 24 10          	mov    0x10(%esp),%esi
  801266:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80126a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80126e:	83 c4 1c             	add    $0x1c,%esp
  801271:	c3                   	ret    
  801272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801278:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80127d:	89 e8                	mov    %ebp,%eax
  80127f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801284:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801288:	89 fa                	mov    %edi,%edx
  80128a:	d3 e0                	shl    %cl,%eax
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 ea                	shr    %cl,%edx
  801290:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801295:	09 c2                	or     %eax,%edx
  801297:	8b 44 24 08          	mov    0x8(%esp),%eax
  80129b:	89 14 24             	mov    %edx,(%esp)
  80129e:	89 f2                	mov    %esi,%edx
  8012a0:	d3 e7                	shl    %cl,%edi
  8012a2:	89 e9                	mov    %ebp,%ecx
  8012a4:	d3 ea                	shr    %cl,%edx
  8012a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012af:	d3 e6                	shl    %cl,%esi
  8012b1:	89 e9                	mov    %ebp,%ecx
  8012b3:	d3 e8                	shr    %cl,%eax
  8012b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ba:	09 f0                	or     %esi,%eax
  8012bc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012c0:	f7 34 24             	divl   (%esp)
  8012c3:	d3 e6                	shl    %cl,%esi
  8012c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012c9:	89 d6                	mov    %edx,%esi
  8012cb:	f7 e7                	mul    %edi
  8012cd:	39 d6                	cmp    %edx,%esi
  8012cf:	89 c1                	mov    %eax,%ecx
  8012d1:	89 d7                	mov    %edx,%edi
  8012d3:	72 3f                	jb     801314 <__umoddi3+0x154>
  8012d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012d9:	72 35                	jb     801310 <__umoddi3+0x150>
  8012db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012df:	29 c8                	sub    %ecx,%eax
  8012e1:	19 fe                	sbb    %edi,%esi
  8012e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012e8:	89 f2                	mov    %esi,%edx
  8012ea:	d3 e8                	shr    %cl,%eax
  8012ec:	89 e9                	mov    %ebp,%ecx
  8012ee:	d3 e2                	shl    %cl,%edx
  8012f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f5:	09 d0                	or     %edx,%eax
  8012f7:	89 f2                	mov    %esi,%edx
  8012f9:	d3 ea                	shr    %cl,%edx
  8012fb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801303:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801307:	83 c4 1c             	add    $0x1c,%esp
  80130a:	c3                   	ret    
  80130b:	90                   	nop
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	39 d6                	cmp    %edx,%esi
  801312:	75 c7                	jne    8012db <__umoddi3+0x11b>
  801314:	89 d7                	mov    %edx,%edi
  801316:	89 c1                	mov    %eax,%ecx
  801318:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80131c:	1b 3c 24             	sbb    (%esp),%edi
  80131f:	eb ba                	jmp    8012db <__umoddi3+0x11b>
  801321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801328:	39 f5                	cmp    %esi,%ebp
  80132a:	0f 82 f1 fe ff ff    	jb     801221 <__umoddi3+0x61>
  801330:	e9 f8 fe ff ff       	jmp    80122d <__umoddi3+0x6d>
