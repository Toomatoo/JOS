
obj/user/faultevilhandler:     file format elf32-i386


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
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
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
  800094:	c1 e0 07             	shl    $0x7,%eax
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
  80016f:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800186:	e8 09 03 00 00       	call   800494 <_panic>

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
  80022e:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800235:	00 
  800236:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023d:	00 
  80023e:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800245:	e8 4a 02 00 00       	call   800494 <_panic>

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
  80028c:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800293:	00 
  800294:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029b:	00 
  80029c:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8002a3:	e8 ec 01 00 00       	call   800494 <_panic>

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
  8002ea:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f9:	00 
  8002fa:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800301:	e8 8e 01 00 00       	call   800494 <_panic>

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
  800348:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80035f:	e8 30 01 00 00       	call   800494 <_panic>

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
  8003a6:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8003ad:	00 
  8003ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b5:	00 
  8003b6:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8003bd:	e8 d2 00 00 00       	call   800494 <_panic>

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
  800437:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80044e:	e8 41 00 00 00       	call   800494 <_panic>

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

00800460 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	83 ec 0c             	sub    $0xc,%esp
  800466:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800469:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80046c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80046f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800474:	b8 0d 00 00 00       	mov    $0xd,%eax
  800479:	8b 55 08             	mov    0x8(%ebp),%edx
  80047c:	89 cb                	mov    %ecx,%ebx
  80047e:	89 cf                	mov    %ecx,%edi
  800480:	89 ce                	mov    %ecx,%esi
  800482:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  800484:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800487:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80048a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80048d:	89 ec                	mov    %ebp,%esp
  80048f:	5d                   	pop    %ebp
  800490:	c3                   	ret    
  800491:	00 00                	add    %al,(%eax)
	...

00800494 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80049c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80049f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004a5:	e8 ee fc ff ff       	call   800198 <sys_getenvid>
  8004aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c0:	c7 04 24 b8 13 80 00 	movl   $0x8013b8,(%esp)
  8004c7:	e8 c3 00 00 00       	call   80058f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	e8 53 00 00 00       	call   80052e <vcprintf>
	cprintf("\n");
  8004db:	c7 04 24 dc 13 80 00 	movl   $0x8013dc,(%esp)
  8004e2:	e8 a8 00 00 00       	call   80058f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004e7:	cc                   	int3   
  8004e8:	eb fd                	jmp    8004e7 <_panic+0x53>
	...

008004ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	53                   	push   %ebx
  8004f0:	83 ec 14             	sub    $0x14,%esp
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004f6:	8b 03                	mov    (%ebx),%eax
  8004f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004ff:	83 c0 01             	add    $0x1,%eax
  800502:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800504:	3d ff 00 00 00       	cmp    $0xff,%eax
  800509:	75 19                	jne    800524 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80050b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800512:	00 
  800513:	8d 43 08             	lea    0x8(%ebx),%eax
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	e8 be fb ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  80051e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800524:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800528:	83 c4 14             	add    $0x14,%esp
  80052b:	5b                   	pop    %ebx
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    

0080052e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800537:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80053e:	00 00 00 
	b.cnt = 0;
  800541:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800548:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800552:	8b 45 08             	mov    0x8(%ebp),%eax
  800555:	89 44 24 08          	mov    %eax,0x8(%esp)
  800559:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	c7 04 24 ec 04 80 00 	movl   $0x8004ec,(%esp)
  80056a:	e8 97 01 00 00       	call   800706 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80056f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 55 fb ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  800587:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80058d:	c9                   	leave  
  80058e:	c3                   	ret    

0080058f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800595:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	8b 45 08             	mov    0x8(%ebp),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	e8 87 ff ff ff       	call   80052e <vcprintf>
	va_end(ap);

	return cnt;
}
  8005a7:	c9                   	leave  
  8005a8:	c3                   	ret    
  8005a9:	00 00                	add    %al,(%eax)
	...

008005ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	57                   	push   %edi
  8005b0:	56                   	push   %esi
  8005b1:	53                   	push   %ebx
  8005b2:	83 ec 3c             	sub    $0x3c,%esp
  8005b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b8:	89 d7                	mov    %edx,%edi
  8005ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005d4:	72 11                	jb     8005e7 <printnum+0x3b>
  8005d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005dc:	76 09                	jbe    8005e7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005de:	83 eb 01             	sub    $0x1,%ebx
  8005e1:	85 db                	test   %ebx,%ebx
  8005e3:	7f 51                	jg     800636 <printnum+0x8a>
  8005e5:	eb 5e                	jmp    800645 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005eb:	83 eb 01             	sub    $0x1,%ebx
  8005ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f9:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005fd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800601:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800608:	00 
  800609:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060c:	89 04 24             	mov    %eax,(%esp)
  80060f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800612:	89 44 24 04          	mov    %eax,0x4(%esp)
  800616:	e8 a5 0a 00 00       	call   8010c0 <__udivdi3>
  80061b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80061f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062a:	89 fa                	mov    %edi,%edx
  80062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062f:	e8 78 ff ff ff       	call   8005ac <printnum>
  800634:	eb 0f                	jmp    800645 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800636:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063a:	89 34 24             	mov    %esi,(%esp)
  80063d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800640:	83 eb 01             	sub    $0x1,%ebx
  800643:	75 f1                	jne    800636 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800645:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800649:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80064d:	8b 45 10             	mov    0x10(%ebp),%eax
  800650:	89 44 24 08          	mov    %eax,0x8(%esp)
  800654:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80065b:	00 
  80065c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800665:	89 44 24 04          	mov    %eax,0x4(%esp)
  800669:	e8 82 0b 00 00       	call   8011f0 <__umoddi3>
  80066e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800672:	0f be 80 de 13 80 00 	movsbl 0x8013de(%eax),%eax
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80067f:	83 c4 3c             	add    $0x3c,%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068a:	83 fa 01             	cmp    $0x1,%edx
  80068d:	7e 0e                	jle    80069d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	8d 4a 08             	lea    0x8(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 02                	mov    (%edx),%eax
  800698:	8b 52 04             	mov    0x4(%edx),%edx
  80069b:	eb 22                	jmp    8006bf <getuint+0x38>
	else if (lflag)
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 10                	je     8006b1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006a1:	8b 10                	mov    (%eax),%edx
  8006a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a6:	89 08                	mov    %ecx,(%eax)
  8006a8:	8b 02                	mov    (%edx),%eax
  8006aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006af:	eb 0e                	jmp    8006bf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b6:	89 08                	mov    %ecx,(%eax)
  8006b8:	8b 02                	mov    (%edx),%eax
  8006ba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    

008006c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8006d0:	73 0a                	jae    8006dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8006d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d5:	88 0a                	mov    %cl,(%edx)
  8006d7:	83 c2 01             	add    $0x1,%edx
  8006da:	89 10                	mov    %edx,(%eax)
}
  8006dc:	5d                   	pop    %ebp
  8006dd:	c3                   	ret    

008006de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	e8 02 00 00 00       	call   800706 <vprintfmt>
	va_end(ap);
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	57                   	push   %edi
  80070a:	56                   	push   %esi
  80070b:	53                   	push   %ebx
  80070c:	83 ec 5c             	sub    $0x5c,%esp
  80070f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800712:	8b 75 10             	mov    0x10(%ebp),%esi
  800715:	eb 12                	jmp    800729 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800717:	85 c0                	test   %eax,%eax
  800719:	0f 84 e4 04 00 00    	je     800c03 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80071f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800729:	0f b6 06             	movzbl (%esi),%eax
  80072c:	83 c6 01             	add    $0x1,%esi
  80072f:	83 f8 25             	cmp    $0x25,%eax
  800732:	75 e3                	jne    800717 <vprintfmt+0x11>
  800734:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800738:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80073f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800744:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80074b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800750:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800753:	eb 2b                	jmp    800780 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800755:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800758:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80075c:	eb 22                	jmp    800780 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800761:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800765:	eb 19                	jmp    800780 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80076a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800771:	eb 0d                	jmp    800780 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800773:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800776:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800779:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800780:	0f b6 06             	movzbl (%esi),%eax
  800783:	0f b6 d0             	movzbl %al,%edx
  800786:	8d 7e 01             	lea    0x1(%esi),%edi
  800789:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80078c:	83 e8 23             	sub    $0x23,%eax
  80078f:	3c 55                	cmp    $0x55,%al
  800791:	0f 87 46 04 00 00    	ja     800bdd <vprintfmt+0x4d7>
  800797:	0f b6 c0             	movzbl %al,%eax
  80079a:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007a1:	83 ea 30             	sub    $0x30,%edx
  8007a4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8007a7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8007ab:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8007b1:	83 fa 09             	cmp    $0x9,%edx
  8007b4:	77 4a                	ja     800800 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007b9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8007bc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8007bf:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8007c3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007c6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007c9:	83 fa 09             	cmp    $0x9,%edx
  8007cc:	76 eb                	jbe    8007b9 <vprintfmt+0xb3>
  8007ce:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8007d1:	eb 2d                	jmp    800800 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 00                	mov    (%eax),%eax
  8007de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007e4:	eb 1a                	jmp    800800 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007e9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007ed:	79 91                	jns    800780 <vprintfmt+0x7a>
  8007ef:	e9 73 ff ff ff       	jmp    800767 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007f7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007fe:	eb 80                	jmp    800780 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800800:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800804:	0f 89 76 ff ff ff    	jns    800780 <vprintfmt+0x7a>
  80080a:	e9 64 ff ff ff       	jmp    800773 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80080f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800815:	e9 66 ff ff ff       	jmp    800780 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8d 50 04             	lea    0x4(%eax),%edx
  800820:	89 55 14             	mov    %edx,0x14(%ebp)
  800823:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800827:	8b 00                	mov    (%eax),%eax
  800829:	89 04 24             	mov    %eax,(%esp)
  80082c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800832:	e9 f2 fe ff ff       	jmp    800729 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800837:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80083b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80083e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800842:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800845:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800849:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80084c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80084f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800853:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800856:	80 f9 09             	cmp    $0x9,%cl
  800859:	77 1d                	ja     800878 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80085b:	0f be c0             	movsbl %al,%eax
  80085e:	6b c0 64             	imul   $0x64,%eax,%eax
  800861:	0f be d2             	movsbl %dl,%edx
  800864:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800867:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80086e:	a3 04 20 80 00       	mov    %eax,0x802004
  800873:	e9 b1 fe ff ff       	jmp    800729 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800878:	c7 44 24 04 f6 13 80 	movl   $0x8013f6,0x4(%esp)
  80087f:	00 
  800880:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 10 05 00 00       	call   800d9b <strcmp>
  80088b:	85 c0                	test   %eax,%eax
  80088d:	75 0f                	jne    80089e <vprintfmt+0x198>
  80088f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800896:	00 00 00 
  800899:	e9 8b fe ff ff       	jmp    800729 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80089e:	c7 44 24 04 fa 13 80 	movl   $0x8013fa,0x4(%esp)
  8008a5:	00 
  8008a6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008a9:	89 14 24             	mov    %edx,(%esp)
  8008ac:	e8 ea 04 00 00       	call   800d9b <strcmp>
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	75 0f                	jne    8008c4 <vprintfmt+0x1be>
  8008b5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8008bc:	00 00 00 
  8008bf:	e9 65 fe ff ff       	jmp    800729 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8008c4:	c7 44 24 04 fe 13 80 	movl   $0x8013fe,0x4(%esp)
  8008cb:	00 
  8008cc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8008cf:	89 0c 24             	mov    %ecx,(%esp)
  8008d2:	e8 c4 04 00 00       	call   800d9b <strcmp>
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	75 0f                	jne    8008ea <vprintfmt+0x1e4>
  8008db:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8008e2:	00 00 00 
  8008e5:	e9 3f fe ff ff       	jmp    800729 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008ea:	c7 44 24 04 02 14 80 	movl   $0x801402,0x4(%esp)
  8008f1:	00 
  8008f2:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008f5:	89 3c 24             	mov    %edi,(%esp)
  8008f8:	e8 9e 04 00 00       	call   800d9b <strcmp>
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	75 0f                	jne    800910 <vprintfmt+0x20a>
  800901:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800908:	00 00 00 
  80090b:	e9 19 fe ff ff       	jmp    800729 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800910:	c7 44 24 04 06 14 80 	movl   $0x801406,0x4(%esp)
  800917:	00 
  800918:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	e8 78 04 00 00       	call   800d9b <strcmp>
  800923:	85 c0                	test   %eax,%eax
  800925:	75 0f                	jne    800936 <vprintfmt+0x230>
  800927:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80092e:	00 00 00 
  800931:	e9 f3 fd ff ff       	jmp    800729 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800936:	c7 44 24 04 0a 14 80 	movl   $0x80140a,0x4(%esp)
  80093d:	00 
  80093e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800941:	89 14 24             	mov    %edx,(%esp)
  800944:	e8 52 04 00 00       	call   800d9b <strcmp>
  800949:	83 f8 01             	cmp    $0x1,%eax
  80094c:	19 c0                	sbb    %eax,%eax
  80094e:	f7 d0                	not    %eax
  800950:	83 c0 08             	add    $0x8,%eax
  800953:	a3 04 20 80 00       	mov    %eax,0x802004
  800958:	e9 cc fd ff ff       	jmp    800729 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	8d 50 04             	lea    0x4(%eax),%edx
  800963:	89 55 14             	mov    %edx,0x14(%ebp)
  800966:	8b 00                	mov    (%eax),%eax
  800968:	89 c2                	mov    %eax,%edx
  80096a:	c1 fa 1f             	sar    $0x1f,%edx
  80096d:	31 d0                	xor    %edx,%eax
  80096f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800971:	83 f8 08             	cmp    $0x8,%eax
  800974:	7f 0b                	jg     800981 <vprintfmt+0x27b>
  800976:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  80097d:	85 d2                	test   %edx,%edx
  80097f:	75 23                	jne    8009a4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800981:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800985:	c7 44 24 08 0e 14 80 	movl   $0x80140e,0x8(%esp)
  80098c:	00 
  80098d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800991:	8b 7d 08             	mov    0x8(%ebp),%edi
  800994:	89 3c 24             	mov    %edi,(%esp)
  800997:	e8 42 fd ff ff       	call   8006de <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80099f:	e9 85 fd ff ff       	jmp    800729 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8009a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009a8:	c7 44 24 08 17 14 80 	movl   $0x801417,0x8(%esp)
  8009af:	00 
  8009b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b7:	89 3c 24             	mov    %edi,(%esp)
  8009ba:	e8 1f fd ff ff       	call   8006de <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009c2:	e9 62 fd ff ff       	jmp    800729 <vprintfmt+0x23>
  8009c7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8009ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009cd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d3:	8d 50 04             	lea    0x4(%eax),%edx
  8009d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009db:	85 f6                	test   %esi,%esi
  8009dd:	b8 ef 13 80 00       	mov    $0x8013ef,%eax
  8009e2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009e5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009e9:	7e 06                	jle    8009f1 <vprintfmt+0x2eb>
  8009eb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009ef:	75 13                	jne    800a04 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f1:	0f be 06             	movsbl (%esi),%eax
  8009f4:	83 c6 01             	add    $0x1,%esi
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	0f 85 94 00 00 00    	jne    800a93 <vprintfmt+0x38d>
  8009ff:	e9 81 00 00 00       	jmp    800a85 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a04:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a08:	89 34 24             	mov    %esi,(%esp)
  800a0b:	e8 9b 02 00 00       	call   800cab <strnlen>
  800a10:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a13:	29 c2                	sub    %eax,%edx
  800a15:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800a18:	85 d2                	test   %edx,%edx
  800a1a:	7e d5                	jle    8009f1 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800a1c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800a20:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800a23:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800a26:	89 d6                	mov    %edx,%esi
  800a28:	89 cf                	mov    %ecx,%edi
  800a2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2e:	89 3c 24             	mov    %edi,(%esp)
  800a31:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a34:	83 ee 01             	sub    $0x1,%esi
  800a37:	75 f1                	jne    800a2a <vprintfmt+0x324>
  800a39:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a3c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a3f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a42:	eb ad                	jmp    8009f1 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a44:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a48:	74 1b                	je     800a65 <vprintfmt+0x35f>
  800a4a:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a4d:	83 fa 5e             	cmp    $0x5e,%edx
  800a50:	76 13                	jbe    800a65 <vprintfmt+0x35f>
					putch('?', putdat);
  800a52:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a59:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a60:	ff 55 08             	call   *0x8(%ebp)
  800a63:	eb 0d                	jmp    800a72 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a65:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a68:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a6c:	89 04 24             	mov    %eax,(%esp)
  800a6f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a72:	83 eb 01             	sub    $0x1,%ebx
  800a75:	0f be 06             	movsbl (%esi),%eax
  800a78:	83 c6 01             	add    $0x1,%esi
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	75 1a                	jne    800a99 <vprintfmt+0x393>
  800a7f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a82:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a85:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a88:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a8c:	7f 1c                	jg     800aaa <vprintfmt+0x3a4>
  800a8e:	e9 96 fc ff ff       	jmp    800729 <vprintfmt+0x23>
  800a93:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a96:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	78 a7                	js     800a44 <vprintfmt+0x33e>
  800a9d:	83 ef 01             	sub    $0x1,%edi
  800aa0:	79 a2                	jns    800a44 <vprintfmt+0x33e>
  800aa2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800aa5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800aa8:	eb db                	jmp    800a85 <vprintfmt+0x37f>
  800aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aad:	89 de                	mov    %ebx,%esi
  800aaf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ab2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ab6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800abd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800abf:	83 eb 01             	sub    $0x1,%ebx
  800ac2:	75 ee                	jne    800ab2 <vprintfmt+0x3ac>
  800ac4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ac9:	e9 5b fc ff ff       	jmp    800729 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ace:	83 f9 01             	cmp    $0x1,%ecx
  800ad1:	7e 10                	jle    800ae3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800ad3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad6:	8d 50 08             	lea    0x8(%eax),%edx
  800ad9:	89 55 14             	mov    %edx,0x14(%ebp)
  800adc:	8b 30                	mov    (%eax),%esi
  800ade:	8b 78 04             	mov    0x4(%eax),%edi
  800ae1:	eb 26                	jmp    800b09 <vprintfmt+0x403>
	else if (lflag)
  800ae3:	85 c9                	test   %ecx,%ecx
  800ae5:	74 12                	je     800af9 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800ae7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aea:	8d 50 04             	lea    0x4(%eax),%edx
  800aed:	89 55 14             	mov    %edx,0x14(%ebp)
  800af0:	8b 30                	mov    (%eax),%esi
  800af2:	89 f7                	mov    %esi,%edi
  800af4:	c1 ff 1f             	sar    $0x1f,%edi
  800af7:	eb 10                	jmp    800b09 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8d 50 04             	lea    0x4(%eax),%edx
  800aff:	89 55 14             	mov    %edx,0x14(%ebp)
  800b02:	8b 30                	mov    (%eax),%esi
  800b04:	89 f7                	mov    %esi,%edi
  800b06:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b09:	85 ff                	test   %edi,%edi
  800b0b:	78 0e                	js     800b1b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b0d:	89 f0                	mov    %esi,%eax
  800b0f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b11:	be 0a 00 00 00       	mov    $0xa,%esi
  800b16:	e9 84 00 00 00       	jmp    800b9f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800b1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b26:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b29:	89 f0                	mov    %esi,%eax
  800b2b:	89 fa                	mov    %edi,%edx
  800b2d:	f7 d8                	neg    %eax
  800b2f:	83 d2 00             	adc    $0x0,%edx
  800b32:	f7 da                	neg    %edx
			}
			base = 10;
  800b34:	be 0a 00 00 00       	mov    $0xa,%esi
  800b39:	eb 64                	jmp    800b9f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b3b:	89 ca                	mov    %ecx,%edx
  800b3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800b40:	e8 42 fb ff ff       	call   800687 <getuint>
			base = 10;
  800b45:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b4a:	eb 53                	jmp    800b9f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b4c:	89 ca                	mov    %ecx,%edx
  800b4e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b51:	e8 31 fb ff ff       	call   800687 <getuint>
    			base = 8;
  800b56:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b5b:	eb 42                	jmp    800b9f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b61:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b68:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b6b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b6f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b76:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b79:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7c:	8d 50 04             	lea    0x4(%eax),%edx
  800b7f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b82:	8b 00                	mov    (%eax),%eax
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b89:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b8e:	eb 0f                	jmp    800b9f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b90:	89 ca                	mov    %ecx,%edx
  800b92:	8d 45 14             	lea    0x14(%ebp),%eax
  800b95:	e8 ed fa ff ff       	call   800687 <getuint>
			base = 16;
  800b9a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b9f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800ba3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ba7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800baa:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bae:	89 74 24 08          	mov    %esi,0x8(%esp)
  800bb2:	89 04 24             	mov    %eax,(%esp)
  800bb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb9:	89 da                	mov    %ebx,%edx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	e8 e9 f9 ff ff       	call   8005ac <printnum>
			break;
  800bc3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800bc6:	e9 5e fb ff ff       	jmp    800729 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bcb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bcf:	89 14 24             	mov    %edx,(%esp)
  800bd2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bd8:	e9 4c fb ff ff       	jmp    800729 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800be1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800be8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800beb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bef:	0f 84 34 fb ff ff    	je     800729 <vprintfmt+0x23>
  800bf5:	83 ee 01             	sub    $0x1,%esi
  800bf8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bfc:	75 f7                	jne    800bf5 <vprintfmt+0x4ef>
  800bfe:	e9 26 fb ff ff       	jmp    800729 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800c03:	83 c4 5c             	add    $0x5c,%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 28             	sub    $0x28,%esp
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c17:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c1a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c1e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	74 30                	je     800c5c <vsnprintf+0x51>
  800c2c:	85 d2                	test   %edx,%edx
  800c2e:	7e 2c                	jle    800c5c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c30:	8b 45 14             	mov    0x14(%ebp),%eax
  800c33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c37:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c45:	c7 04 24 c1 06 80 00 	movl   $0x8006c1,(%esp)
  800c4c:	e8 b5 fa ff ff       	call   800706 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c51:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c54:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5a:	eb 05                	jmp    800c61 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c69:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	89 04 24             	mov    %eax,(%esp)
  800c84:	e8 82 ff ff ff       	call   800c0b <vsnprintf>
	va_end(ap);

	return rc;
}
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    
  800c8b:	00 00                	add    %al,(%eax)
  800c8d:	00 00                	add    %al,(%eax)
	...

00800c90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c9e:	74 09                	je     800ca9 <strlen+0x19>
		n++;
  800ca0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ca7:	75 f7                	jne    800ca0 <strlen+0x10>
		n++;
	return n;
}
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cba:	85 c9                	test   %ecx,%ecx
  800cbc:	74 1a                	je     800cd8 <strnlen+0x2d>
  800cbe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800cc1:	74 15                	je     800cd8 <strnlen+0x2d>
  800cc3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800cc8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cca:	39 ca                	cmp    %ecx,%edx
  800ccc:	74 0a                	je     800cd8 <strnlen+0x2d>
  800cce:	83 c2 01             	add    $0x1,%edx
  800cd1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800cd6:	75 f0                	jne    800cc8 <strnlen+0x1d>
		n++;
	return n;
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	53                   	push   %ebx
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ce5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cf1:	83 c2 01             	add    $0x1,%edx
  800cf4:	84 c9                	test   %cl,%cl
  800cf6:	75 f2                	jne    800cea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 08             	sub    $0x8,%esp
  800d02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d05:	89 1c 24             	mov    %ebx,(%esp)
  800d08:	e8 83 ff ff ff       	call   800c90 <strlen>
	strcpy(dst + len, src);
  800d0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d14:	01 d8                	add    %ebx,%eax
  800d16:	89 04 24             	mov    %eax,(%esp)
  800d19:	e8 bd ff ff ff       	call   800cdb <strcpy>
	return dst;
}
  800d1e:	89 d8                	mov    %ebx,%eax
  800d20:	83 c4 08             	add    $0x8,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d34:	85 f6                	test   %esi,%esi
  800d36:	74 18                	je     800d50 <strncpy+0x2a>
  800d38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d3d:	0f b6 1a             	movzbl (%edx),%ebx
  800d40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d43:	80 3a 01             	cmpb   $0x1,(%edx)
  800d46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d49:	83 c1 01             	add    $0x1,%ecx
  800d4c:	39 f1                	cmp    %esi,%ecx
  800d4e:	75 ed                	jne    800d3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d60:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d63:	89 f8                	mov    %edi,%eax
  800d65:	85 f6                	test   %esi,%esi
  800d67:	74 2b                	je     800d94 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d69:	83 fe 01             	cmp    $0x1,%esi
  800d6c:	74 23                	je     800d91 <strlcpy+0x3d>
  800d6e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d71:	84 c9                	test   %cl,%cl
  800d73:	74 1c                	je     800d91 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d75:	83 ee 02             	sub    $0x2,%esi
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d7d:	88 08                	mov    %cl,(%eax)
  800d7f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d82:	39 f2                	cmp    %esi,%edx
  800d84:	74 0b                	je     800d91 <strlcpy+0x3d>
  800d86:	83 c2 01             	add    $0x1,%edx
  800d89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d8d:	84 c9                	test   %cl,%cl
  800d8f:	75 ec                	jne    800d7d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d94:	29 f8                	sub    %edi,%eax
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800da4:	0f b6 01             	movzbl (%ecx),%eax
  800da7:	84 c0                	test   %al,%al
  800da9:	74 16                	je     800dc1 <strcmp+0x26>
  800dab:	3a 02                	cmp    (%edx),%al
  800dad:	75 12                	jne    800dc1 <strcmp+0x26>
		p++, q++;
  800daf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800db2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800db6:	84 c0                	test   %al,%al
  800db8:	74 07                	je     800dc1 <strcmp+0x26>
  800dba:	83 c1 01             	add    $0x1,%ecx
  800dbd:	3a 02                	cmp    (%edx),%al
  800dbf:	74 ee                	je     800daf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc1:	0f b6 c0             	movzbl %al,%eax
  800dc4:	0f b6 12             	movzbl (%edx),%edx
  800dc7:	29 d0                	sub    %edx,%eax
}
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	53                   	push   %ebx
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ddd:	85 d2                	test   %edx,%edx
  800ddf:	74 28                	je     800e09 <strncmp+0x3e>
  800de1:	0f b6 01             	movzbl (%ecx),%eax
  800de4:	84 c0                	test   %al,%al
  800de6:	74 24                	je     800e0c <strncmp+0x41>
  800de8:	3a 03                	cmp    (%ebx),%al
  800dea:	75 20                	jne    800e0c <strncmp+0x41>
  800dec:	83 ea 01             	sub    $0x1,%edx
  800def:	74 13                	je     800e04 <strncmp+0x39>
		n--, p++, q++;
  800df1:	83 c1 01             	add    $0x1,%ecx
  800df4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800df7:	0f b6 01             	movzbl (%ecx),%eax
  800dfa:	84 c0                	test   %al,%al
  800dfc:	74 0e                	je     800e0c <strncmp+0x41>
  800dfe:	3a 03                	cmp    (%ebx),%al
  800e00:	74 ea                	je     800dec <strncmp+0x21>
  800e02:	eb 08                	jmp    800e0c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e04:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e0c:	0f b6 01             	movzbl (%ecx),%eax
  800e0f:	0f b6 13             	movzbl (%ebx),%edx
  800e12:	29 d0                	sub    %edx,%eax
  800e14:	eb f3                	jmp    800e09 <strncmp+0x3e>

00800e16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e20:	0f b6 10             	movzbl (%eax),%edx
  800e23:	84 d2                	test   %dl,%dl
  800e25:	74 1c                	je     800e43 <strchr+0x2d>
		if (*s == c)
  800e27:	38 ca                	cmp    %cl,%dl
  800e29:	75 09                	jne    800e34 <strchr+0x1e>
  800e2b:	eb 1b                	jmp    800e48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e2d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800e30:	38 ca                	cmp    %cl,%dl
  800e32:	74 14                	je     800e48 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e34:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800e38:	84 d2                	test   %dl,%dl
  800e3a:	75 f1                	jne    800e2d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	eb 05                	jmp    800e48 <strchr+0x32>
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e54:	0f b6 10             	movzbl (%eax),%edx
  800e57:	84 d2                	test   %dl,%dl
  800e59:	74 14                	je     800e6f <strfind+0x25>
		if (*s == c)
  800e5b:	38 ca                	cmp    %cl,%dl
  800e5d:	75 06                	jne    800e65 <strfind+0x1b>
  800e5f:	eb 0e                	jmp    800e6f <strfind+0x25>
  800e61:	38 ca                	cmp    %cl,%dl
  800e63:	74 0a                	je     800e6f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e65:	83 c0 01             	add    $0x1,%eax
  800e68:	0f b6 10             	movzbl (%eax),%edx
  800e6b:	84 d2                	test   %dl,%dl
  800e6d:	75 f2                	jne    800e61 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e89:	85 c9                	test   %ecx,%ecx
  800e8b:	74 30                	je     800ebd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e93:	75 25                	jne    800eba <memset+0x49>
  800e95:	f6 c1 03             	test   $0x3,%cl
  800e98:	75 20                	jne    800eba <memset+0x49>
		c &= 0xFF;
  800e9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e9d:	89 d3                	mov    %edx,%ebx
  800e9f:	c1 e3 08             	shl    $0x8,%ebx
  800ea2:	89 d6                	mov    %edx,%esi
  800ea4:	c1 e6 18             	shl    $0x18,%esi
  800ea7:	89 d0                	mov    %edx,%eax
  800ea9:	c1 e0 10             	shl    $0x10,%eax
  800eac:	09 f0                	or     %esi,%eax
  800eae:	09 d0                	or     %edx,%eax
  800eb0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eb2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eb5:	fc                   	cld    
  800eb6:	f3 ab                	rep stos %eax,%es:(%edi)
  800eb8:	eb 03                	jmp    800ebd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eba:	fc                   	cld    
  800ebb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ebd:	89 f8                	mov    %edi,%eax
  800ebf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec8:	89 ec                	mov    %ebp,%esp
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ede:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ee1:	39 c6                	cmp    %eax,%esi
  800ee3:	73 36                	jae    800f1b <memmove+0x4f>
  800ee5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ee8:	39 d0                	cmp    %edx,%eax
  800eea:	73 2f                	jae    800f1b <memmove+0x4f>
		s += n;
		d += n;
  800eec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eef:	f6 c2 03             	test   $0x3,%dl
  800ef2:	75 1b                	jne    800f0f <memmove+0x43>
  800ef4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800efa:	75 13                	jne    800f0f <memmove+0x43>
  800efc:	f6 c1 03             	test   $0x3,%cl
  800eff:	75 0e                	jne    800f0f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f01:	83 ef 04             	sub    $0x4,%edi
  800f04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f0a:	fd                   	std    
  800f0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0d:	eb 09                	jmp    800f18 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f0f:	83 ef 01             	sub    $0x1,%edi
  800f12:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f15:	fd                   	std    
  800f16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f18:	fc                   	cld    
  800f19:	eb 20                	jmp    800f3b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f21:	75 13                	jne    800f36 <memmove+0x6a>
  800f23:	a8 03                	test   $0x3,%al
  800f25:	75 0f                	jne    800f36 <memmove+0x6a>
  800f27:	f6 c1 03             	test   $0x3,%cl
  800f2a:	75 0a                	jne    800f36 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f2c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f2f:	89 c7                	mov    %eax,%edi
  800f31:	fc                   	cld    
  800f32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f34:	eb 05                	jmp    800f3b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f36:	89 c7                	mov    %eax,%edi
  800f38:	fc                   	cld    
  800f39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f41:	89 ec                	mov    %ebp,%esp
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	89 04 24             	mov    %eax,(%esp)
  800f5f:	e8 68 ff ff ff       	call   800ecc <memmove>
}
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    

00800f66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f72:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f7a:	85 ff                	test   %edi,%edi
  800f7c:	74 37                	je     800fb5 <memcmp+0x4f>
		if (*s1 != *s2)
  800f7e:	0f b6 03             	movzbl (%ebx),%eax
  800f81:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f84:	83 ef 01             	sub    $0x1,%edi
  800f87:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f8c:	38 c8                	cmp    %cl,%al
  800f8e:	74 1c                	je     800fac <memcmp+0x46>
  800f90:	eb 10                	jmp    800fa2 <memcmp+0x3c>
  800f92:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f97:	83 c2 01             	add    $0x1,%edx
  800f9a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f9e:	38 c8                	cmp    %cl,%al
  800fa0:	74 0a                	je     800fac <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800fa2:	0f b6 c0             	movzbl %al,%eax
  800fa5:	0f b6 c9             	movzbl %cl,%ecx
  800fa8:	29 c8                	sub    %ecx,%eax
  800faa:	eb 09                	jmp    800fb5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fac:	39 fa                	cmp    %edi,%edx
  800fae:	75 e2                	jne    800f92 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fc0:	89 c2                	mov    %eax,%edx
  800fc2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fc5:	39 d0                	cmp    %edx,%eax
  800fc7:	73 19                	jae    800fe2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800fcd:	38 08                	cmp    %cl,(%eax)
  800fcf:	75 06                	jne    800fd7 <memfind+0x1d>
  800fd1:	eb 0f                	jmp    800fe2 <memfind+0x28>
  800fd3:	38 08                	cmp    %cl,(%eax)
  800fd5:	74 0b                	je     800fe2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fd7:	83 c0 01             	add    $0x1,%eax
  800fda:	39 d0                	cmp    %edx,%eax
  800fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	75 f1                	jne    800fd3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	53                   	push   %ebx
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ff0:	0f b6 02             	movzbl (%edx),%eax
  800ff3:	3c 20                	cmp    $0x20,%al
  800ff5:	74 04                	je     800ffb <strtol+0x17>
  800ff7:	3c 09                	cmp    $0x9,%al
  800ff9:	75 0e                	jne    801009 <strtol+0x25>
		s++;
  800ffb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ffe:	0f b6 02             	movzbl (%edx),%eax
  801001:	3c 20                	cmp    $0x20,%al
  801003:	74 f6                	je     800ffb <strtol+0x17>
  801005:	3c 09                	cmp    $0x9,%al
  801007:	74 f2                	je     800ffb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801009:	3c 2b                	cmp    $0x2b,%al
  80100b:	75 0a                	jne    801017 <strtol+0x33>
		s++;
  80100d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801010:	bf 00 00 00 00       	mov    $0x0,%edi
  801015:	eb 10                	jmp    801027 <strtol+0x43>
  801017:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80101c:	3c 2d                	cmp    $0x2d,%al
  80101e:	75 07                	jne    801027 <strtol+0x43>
		s++, neg = 1;
  801020:	83 c2 01             	add    $0x1,%edx
  801023:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801027:	85 db                	test   %ebx,%ebx
  801029:	0f 94 c0             	sete   %al
  80102c:	74 05                	je     801033 <strtol+0x4f>
  80102e:	83 fb 10             	cmp    $0x10,%ebx
  801031:	75 15                	jne    801048 <strtol+0x64>
  801033:	80 3a 30             	cmpb   $0x30,(%edx)
  801036:	75 10                	jne    801048 <strtol+0x64>
  801038:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80103c:	75 0a                	jne    801048 <strtol+0x64>
		s += 2, base = 16;
  80103e:	83 c2 02             	add    $0x2,%edx
  801041:	bb 10 00 00 00       	mov    $0x10,%ebx
  801046:	eb 13                	jmp    80105b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801048:	84 c0                	test   %al,%al
  80104a:	74 0f                	je     80105b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80104c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801051:	80 3a 30             	cmpb   $0x30,(%edx)
  801054:	75 05                	jne    80105b <strtol+0x77>
		s++, base = 8;
  801056:	83 c2 01             	add    $0x1,%edx
  801059:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
  801060:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801062:	0f b6 0a             	movzbl (%edx),%ecx
  801065:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801068:	80 fb 09             	cmp    $0x9,%bl
  80106b:	77 08                	ja     801075 <strtol+0x91>
			dig = *s - '0';
  80106d:	0f be c9             	movsbl %cl,%ecx
  801070:	83 e9 30             	sub    $0x30,%ecx
  801073:	eb 1e                	jmp    801093 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801075:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801078:	80 fb 19             	cmp    $0x19,%bl
  80107b:	77 08                	ja     801085 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80107d:	0f be c9             	movsbl %cl,%ecx
  801080:	83 e9 57             	sub    $0x57,%ecx
  801083:	eb 0e                	jmp    801093 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801085:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801088:	80 fb 19             	cmp    $0x19,%bl
  80108b:	77 14                	ja     8010a1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80108d:	0f be c9             	movsbl %cl,%ecx
  801090:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801093:	39 f1                	cmp    %esi,%ecx
  801095:	7d 0e                	jge    8010a5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801097:	83 c2 01             	add    $0x1,%edx
  80109a:	0f af c6             	imul   %esi,%eax
  80109d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80109f:	eb c1                	jmp    801062 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8010a1:	89 c1                	mov    %eax,%ecx
  8010a3:	eb 02                	jmp    8010a7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010a5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8010a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010ab:	74 05                	je     8010b2 <strtol+0xce>
		*endptr = (char *) s;
  8010ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010b0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010b2:	89 ca                	mov    %ecx,%edx
  8010b4:	f7 da                	neg    %edx
  8010b6:	85 ff                	test   %edi,%edi
  8010b8:	0f 45 c2             	cmovne %edx,%eax
}
  8010bb:	5b                   	pop    %ebx
  8010bc:	5e                   	pop    %esi
  8010bd:	5f                   	pop    %edi
  8010be:	5d                   	pop    %ebp
  8010bf:	c3                   	ret    

008010c0 <__udivdi3>:
  8010c0:	83 ec 1c             	sub    $0x1c,%esp
  8010c3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010c7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010cf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010d3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010db:	85 ff                	test   %edi,%edi
  8010dd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e5:	89 cd                	mov    %ecx,%ebp
  8010e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010eb:	75 33                	jne    801120 <__udivdi3+0x60>
  8010ed:	39 f1                	cmp    %esi,%ecx
  8010ef:	77 57                	ja     801148 <__udivdi3+0x88>
  8010f1:	85 c9                	test   %ecx,%ecx
  8010f3:	75 0b                	jne    801100 <__udivdi3+0x40>
  8010f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010fa:	31 d2                	xor    %edx,%edx
  8010fc:	f7 f1                	div    %ecx
  8010fe:	89 c1                	mov    %eax,%ecx
  801100:	89 f0                	mov    %esi,%eax
  801102:	31 d2                	xor    %edx,%edx
  801104:	f7 f1                	div    %ecx
  801106:	89 c6                	mov    %eax,%esi
  801108:	8b 44 24 04          	mov    0x4(%esp),%eax
  80110c:	f7 f1                	div    %ecx
  80110e:	89 f2                	mov    %esi,%edx
  801110:	8b 74 24 10          	mov    0x10(%esp),%esi
  801114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111c:	83 c4 1c             	add    $0x1c,%esp
  80111f:	c3                   	ret    
  801120:	31 d2                	xor    %edx,%edx
  801122:	31 c0                	xor    %eax,%eax
  801124:	39 f7                	cmp    %esi,%edi
  801126:	77 e8                	ja     801110 <__udivdi3+0x50>
  801128:	0f bd cf             	bsr    %edi,%ecx
  80112b:	83 f1 1f             	xor    $0x1f,%ecx
  80112e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801132:	75 2c                	jne    801160 <__udivdi3+0xa0>
  801134:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801138:	76 04                	jbe    80113e <__udivdi3+0x7e>
  80113a:	39 f7                	cmp    %esi,%edi
  80113c:	73 d2                	jae    801110 <__udivdi3+0x50>
  80113e:	31 d2                	xor    %edx,%edx
  801140:	b8 01 00 00 00       	mov    $0x1,%eax
  801145:	eb c9                	jmp    801110 <__udivdi3+0x50>
  801147:	90                   	nop
  801148:	89 f2                	mov    %esi,%edx
  80114a:	f7 f1                	div    %ecx
  80114c:	31 d2                	xor    %edx,%edx
  80114e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801152:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801156:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80115a:	83 c4 1c             	add    $0x1c,%esp
  80115d:	c3                   	ret    
  80115e:	66 90                	xchg   %ax,%ax
  801160:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801165:	b8 20 00 00 00       	mov    $0x20,%eax
  80116a:	89 ea                	mov    %ebp,%edx
  80116c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801170:	d3 e7                	shl    %cl,%edi
  801172:	89 c1                	mov    %eax,%ecx
  801174:	d3 ea                	shr    %cl,%edx
  801176:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117b:	09 fa                	or     %edi,%edx
  80117d:	89 f7                	mov    %esi,%edi
  80117f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801183:	89 f2                	mov    %esi,%edx
  801185:	8b 74 24 08          	mov    0x8(%esp),%esi
  801189:	d3 e5                	shl    %cl,%ebp
  80118b:	89 c1                	mov    %eax,%ecx
  80118d:	d3 ef                	shr    %cl,%edi
  80118f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801194:	d3 e2                	shl    %cl,%edx
  801196:	89 c1                	mov    %eax,%ecx
  801198:	d3 ee                	shr    %cl,%esi
  80119a:	09 d6                	or     %edx,%esi
  80119c:	89 fa                	mov    %edi,%edx
  80119e:	89 f0                	mov    %esi,%eax
  8011a0:	f7 74 24 0c          	divl   0xc(%esp)
  8011a4:	89 d7                	mov    %edx,%edi
  8011a6:	89 c6                	mov    %eax,%esi
  8011a8:	f7 e5                	mul    %ebp
  8011aa:	39 d7                	cmp    %edx,%edi
  8011ac:	72 22                	jb     8011d0 <__udivdi3+0x110>
  8011ae:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8011b2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b7:	d3 e5                	shl    %cl,%ebp
  8011b9:	39 c5                	cmp    %eax,%ebp
  8011bb:	73 04                	jae    8011c1 <__udivdi3+0x101>
  8011bd:	39 d7                	cmp    %edx,%edi
  8011bf:	74 0f                	je     8011d0 <__udivdi3+0x110>
  8011c1:	89 f0                	mov    %esi,%eax
  8011c3:	31 d2                	xor    %edx,%edx
  8011c5:	e9 46 ff ff ff       	jmp    801110 <__udivdi3+0x50>
  8011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011d3:	31 d2                	xor    %edx,%edx
  8011d5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011d9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011dd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e1:	83 c4 1c             	add    $0x1c,%esp
  8011e4:	c3                   	ret    
	...

008011f0 <__umoddi3>:
  8011f0:	83 ec 1c             	sub    $0x1c,%esp
  8011f3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011f7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011fb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011ff:	89 74 24 10          	mov    %esi,0x10(%esp)
  801203:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801207:	8b 74 24 24          	mov    0x24(%esp),%esi
  80120b:	85 ed                	test   %ebp,%ebp
  80120d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801211:	89 44 24 08          	mov    %eax,0x8(%esp)
  801215:	89 cf                	mov    %ecx,%edi
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	89 f2                	mov    %esi,%edx
  80121c:	75 1a                	jne    801238 <__umoddi3+0x48>
  80121e:	39 f1                	cmp    %esi,%ecx
  801220:	76 4e                	jbe    801270 <__umoddi3+0x80>
  801222:	f7 f1                	div    %ecx
  801224:	89 d0                	mov    %edx,%eax
  801226:	31 d2                	xor    %edx,%edx
  801228:	8b 74 24 10          	mov    0x10(%esp),%esi
  80122c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801230:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801234:	83 c4 1c             	add    $0x1c,%esp
  801237:	c3                   	ret    
  801238:	39 f5                	cmp    %esi,%ebp
  80123a:	77 54                	ja     801290 <__umoddi3+0xa0>
  80123c:	0f bd c5             	bsr    %ebp,%eax
  80123f:	83 f0 1f             	xor    $0x1f,%eax
  801242:	89 44 24 04          	mov    %eax,0x4(%esp)
  801246:	75 60                	jne    8012a8 <__umoddi3+0xb8>
  801248:	3b 0c 24             	cmp    (%esp),%ecx
  80124b:	0f 87 07 01 00 00    	ja     801358 <__umoddi3+0x168>
  801251:	89 f2                	mov    %esi,%edx
  801253:	8b 34 24             	mov    (%esp),%esi
  801256:	29 ce                	sub    %ecx,%esi
  801258:	19 ea                	sbb    %ebp,%edx
  80125a:	89 34 24             	mov    %esi,(%esp)
  80125d:	8b 04 24             	mov    (%esp),%eax
  801260:	8b 74 24 10          	mov    0x10(%esp),%esi
  801264:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801268:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80126c:	83 c4 1c             	add    $0x1c,%esp
  80126f:	c3                   	ret    
  801270:	85 c9                	test   %ecx,%ecx
  801272:	75 0b                	jne    80127f <__umoddi3+0x8f>
  801274:	b8 01 00 00 00       	mov    $0x1,%eax
  801279:	31 d2                	xor    %edx,%edx
  80127b:	f7 f1                	div    %ecx
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	89 f0                	mov    %esi,%eax
  801281:	31 d2                	xor    %edx,%edx
  801283:	f7 f1                	div    %ecx
  801285:	8b 04 24             	mov    (%esp),%eax
  801288:	f7 f1                	div    %ecx
  80128a:	eb 98                	jmp    801224 <__umoddi3+0x34>
  80128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801290:	89 f2                	mov    %esi,%edx
  801292:	8b 74 24 10          	mov    0x10(%esp),%esi
  801296:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80129a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80129e:	83 c4 1c             	add    $0x1c,%esp
  8012a1:	c3                   	ret    
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ad:	89 e8                	mov    %ebp,%eax
  8012af:	bd 20 00 00 00       	mov    $0x20,%ebp
  8012b4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8012b8:	89 fa                	mov    %edi,%edx
  8012ba:	d3 e0                	shl    %cl,%eax
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	d3 ea                	shr    %cl,%edx
  8012c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012c5:	09 c2                	or     %eax,%edx
  8012c7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012cb:	89 14 24             	mov    %edx,(%esp)
  8012ce:	89 f2                	mov    %esi,%edx
  8012d0:	d3 e7                	shl    %cl,%edi
  8012d2:	89 e9                	mov    %ebp,%ecx
  8012d4:	d3 ea                	shr    %cl,%edx
  8012d6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012df:	d3 e6                	shl    %cl,%esi
  8012e1:	89 e9                	mov    %ebp,%ecx
  8012e3:	d3 e8                	shr    %cl,%eax
  8012e5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ea:	09 f0                	or     %esi,%eax
  8012ec:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012f0:	f7 34 24             	divl   (%esp)
  8012f3:	d3 e6                	shl    %cl,%esi
  8012f5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012f9:	89 d6                	mov    %edx,%esi
  8012fb:	f7 e7                	mul    %edi
  8012fd:	39 d6                	cmp    %edx,%esi
  8012ff:	89 c1                	mov    %eax,%ecx
  801301:	89 d7                	mov    %edx,%edi
  801303:	72 3f                	jb     801344 <__umoddi3+0x154>
  801305:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801309:	72 35                	jb     801340 <__umoddi3+0x150>
  80130b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80130f:	29 c8                	sub    %ecx,%eax
  801311:	19 fe                	sbb    %edi,%esi
  801313:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801318:	89 f2                	mov    %esi,%edx
  80131a:	d3 e8                	shr    %cl,%eax
  80131c:	89 e9                	mov    %ebp,%ecx
  80131e:	d3 e2                	shl    %cl,%edx
  801320:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801325:	09 d0                	or     %edx,%eax
  801327:	89 f2                	mov    %esi,%edx
  801329:	d3 ea                	shr    %cl,%edx
  80132b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80132f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801333:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801337:	83 c4 1c             	add    $0x1c,%esp
  80133a:	c3                   	ret    
  80133b:	90                   	nop
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	39 d6                	cmp    %edx,%esi
  801342:	75 c7                	jne    80130b <__umoddi3+0x11b>
  801344:	89 d7                	mov    %edx,%edi
  801346:	89 c1                	mov    %eax,%ecx
  801348:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80134c:	1b 3c 24             	sbb    (%esp),%edi
  80134f:	eb ba                	jmp    80130b <__umoddi3+0x11b>
  801351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801358:	39 f5                	cmp    %esi,%ebp
  80135a:	0f 82 f1 fe ff ff    	jb     801251 <__umoddi3+0x61>
  801360:	e9 f8 fe ff ff       	jmp    80125d <__umoddi3+0x6d>
