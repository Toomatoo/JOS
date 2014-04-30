
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 78 04 80 	movl   $0x800478,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 07 03 00 00       	call   800355 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006e:	e8 09 01 00 00       	call   80017c <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	c1 e0 07             	shl    $0x7,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 61 00 00 00       	call   80011f <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	89 d1                	mov    %edx,%ecx
  80010a:	89 d3                	mov    %edx,%ebx
  80010c:	89 d7                	mov    %edx,%edi
  80010e:	89 d6                	mov    %edx,%esi
  800110:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800112:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800115:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800118:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 38             	sub    $0x38,%esp
  800125:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800128:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80012b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  80016a:	e8 2d 03 00 00       	call   80049c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800185:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800188:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 02 00 00 00       	mov    $0x2,%eax
  800195:	89 d1                	mov    %edx,%ecx
  800197:	89 d3                	mov    %edx,%ebx
  800199:	89 d7                	mov    %edx,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c5:	89 d1                	mov    %edx,%ecx
  8001c7:	89 d3                	mov    %edx,%ebx
  8001c9:	89 d7                	mov    %edx,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d8:	89 ec                	mov    %ebp,%esp
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 38             	sub    $0x38,%esp
  8001e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001eb:	be 00 00 00 00       	mov    $0x0,%esi
  8001f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 f7                	mov    %esi,%edi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 28                	jle    80022e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800211:	00 
  800212:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  800229:	e8 6e 02 00 00       	call   80049c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800231:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 38             	sub    $0x38,%esp
  800241:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800244:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800247:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	b8 05 00 00 00       	mov    $0x5,%eax
  80024f:	8b 75 18             	mov    0x18(%ebp),%esi
  800252:	8b 7d 14             	mov    0x14(%ebp),%edi
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025b:	8b 55 08             	mov    0x8(%ebp),%edx
  80025e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 28                	jle    80028c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	89 44 24 10          	mov    %eax,0x10(%esp)
  800268:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80026f:	00 
  800270:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  800287:	e8 10 02 00 00       	call   80049c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800292:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800295:	89 ec                	mov    %ebp,%esp
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 38             	sub    $0x38,%esp
  80029f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 28                	jle    8002ea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8002e5:	e8 b2 01 00 00       	call   80049c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f3:	89 ec                	mov    %ebp,%esp
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 38             	sub    $0x38,%esp
  8002fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800300:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800303:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	b8 08 00 00 00       	mov    $0x8,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7e 28                	jle    800348 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	89 44 24 10          	mov    %eax,0x10(%esp)
  800324:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80032b:	00 
  80032c:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  800343:	e8 54 01 00 00       	call   80049c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800351:	89 ec                	mov    %ebp,%esp
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 38             	sub    $0x38,%esp
  80035b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800361:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	bb 00 00 00 00       	mov    $0x0,%ebx
  800369:	b8 09 00 00 00       	mov    $0x9,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	89 df                	mov    %ebx,%edi
  800376:	89 de                	mov    %ebx,%esi
  800378:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	7e 28                	jle    8003a6 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800382:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800389:	00 
  80038a:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8003a1:	e8 f6 00 00 00       	call   80049c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003af:	89 ec                	mov    %ebp,%esp
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	83 ec 0c             	sub    $0xc,%esp
  8003b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	be 00 00 00 00       	mov    $0x0,%esi
  8003c7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003e3:	89 ec                	mov    %ebp,%esp
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 38             	sub    $0x38,%esp
  8003ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800400:	8b 55 08             	mov    0x8(%ebp),%edx
  800403:	89 cb                	mov    %ecx,%ebx
  800405:	89 cf                	mov    %ecx,%edi
  800407:	89 ce                	mov    %ecx,%esi
  800409:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80040b:	85 c0                	test   %eax,%eax
  80040d:	7e 28                	jle    800437 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800413:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80041a:	00 
  80041b:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  800422:	00 
  800423:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042a:	00 
  80042b:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  800432:	e8 65 00 00 00       	call   80049c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800437:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80043a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800440:	89 ec                	mov    %ebp,%esp
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80044d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800450:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800453:	b9 00 00 00 00       	mov    $0x0,%ecx
  800458:	b8 0d 00 00 00       	mov    $0xd,%eax
  80045d:	8b 55 08             	mov    0x8(%ebp),%edx
  800460:	89 cb                	mov    %ecx,%ebx
  800462:	89 cf                	mov    %ecx,%edi
  800464:	89 ce                	mov    %ecx,%esi
  800466:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  800468:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80046b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80046e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800471:	89 ec                	mov    %ebp,%esp
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    
  800475:	00 00                	add    %al,(%eax)
	...

00800478 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800478:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800479:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80047e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800480:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  800483:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  800487:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  80048c:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  800490:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  800492:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  800495:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  800496:	83 c4 04             	add    $0x4,%esp
    popfl
  800499:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  80049a:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  80049b:	c3                   	ret    

0080049c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	56                   	push   %esi
  8004a0:	53                   	push   %ebx
  8004a1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004a7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004ad:	e8 ca fc ff ff       	call   80017c <sys_getenvid>
  8004b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c8:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  8004cf:	e8 c3 00 00 00       	call   800597 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004db:	89 04 24             	mov    %eax,(%esp)
  8004de:	e8 53 00 00 00       	call   800536 <vcprintf>
	cprintf("\n");
  8004e3:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  8004ea:	e8 a8 00 00 00       	call   800597 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ef:	cc                   	int3   
  8004f0:	eb fd                	jmp    8004ef <_panic+0x53>
	...

008004f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 14             	sub    $0x14,%esp
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004fe:	8b 03                	mov    (%ebx),%eax
  800500:	8b 55 08             	mov    0x8(%ebp),%edx
  800503:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800507:	83 c0 01             	add    $0x1,%eax
  80050a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80050c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800511:	75 19                	jne    80052c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800513:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80051a:	00 
  80051b:	8d 43 08             	lea    0x8(%ebx),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 9a fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  800526:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80052c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800530:	83 c4 14             	add    $0x14,%esp
  800533:	5b                   	pop    %ebx
  800534:	5d                   	pop    %ebp
  800535:	c3                   	ret    

00800536 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80053f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800546:	00 00 00 
	b.cnt = 0;
  800549:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800550:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
  800556:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055a:	8b 45 08             	mov    0x8(%ebp),%eax
  80055d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800561:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800567:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056b:	c7 04 24 f4 04 80 00 	movl   $0x8004f4,(%esp)
  800572:	e8 97 01 00 00       	call   80070e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800577:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80057d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800581:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800587:	89 04 24             	mov    %eax,(%esp)
  80058a:	e8 31 fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  80058f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80059d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	e8 87 ff ff ff       	call   800536 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    
  8005b1:	00 00                	add    %al,(%eax)
	...

008005b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	57                   	push   %edi
  8005b8:	56                   	push   %esi
  8005b9:	53                   	push   %ebx
  8005ba:	83 ec 3c             	sub    $0x3c,%esp
  8005bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c0:	89 d7                	mov    %edx,%edi
  8005c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005dc:	72 11                	jb     8005ef <printnum+0x3b>
  8005de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005e4:	76 09                	jbe    8005ef <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e6:	83 eb 01             	sub    $0x1,%ebx
  8005e9:	85 db                	test   %ebx,%ebx
  8005eb:	7f 51                	jg     80063e <printnum+0x8a>
  8005ed:	eb 5e                	jmp    80064d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ef:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005f3:	83 eb 01             	sub    $0x1,%ebx
  8005f6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800601:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800605:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800609:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800610:	00 
  800611:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061e:	e8 3d 0b 00 00       	call   801160 <__udivdi3>
  800623:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800627:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800632:	89 fa                	mov    %edi,%edx
  800634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800637:	e8 78 ff ff ff       	call   8005b4 <printnum>
  80063c:	eb 0f                	jmp    80064d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800642:	89 34 24             	mov    %esi,(%esp)
  800645:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	75 f1                	jne    80063e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800651:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800655:	8b 45 10             	mov    0x10(%ebp),%eax
  800658:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800663:	00 
  800664:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800671:	e8 1a 0c 00 00       	call   801290 <__umoddi3>
  800676:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067a:	0f be 80 7d 14 80 00 	movsbl 0x80147d(%eax),%eax
  800681:	89 04 24             	mov    %eax,(%esp)
  800684:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800687:	83 c4 3c             	add    $0x3c,%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5f                   	pop    %edi
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    

0080068f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800692:	83 fa 01             	cmp    $0x1,%edx
  800695:	7e 0e                	jle    8006a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8d 4a 08             	lea    0x8(%edx),%ecx
  80069c:	89 08                	mov    %ecx,(%eax)
  80069e:	8b 02                	mov    (%edx),%eax
  8006a0:	8b 52 04             	mov    0x4(%edx),%edx
  8006a3:	eb 22                	jmp    8006c7 <getuint+0x38>
	else if (lflag)
  8006a5:	85 d2                	test   %edx,%edx
  8006a7:	74 10                	je     8006b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ae:	89 08                	mov    %ecx,(%eax)
  8006b0:	8b 02                	mov    (%edx),%eax
  8006b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b7:	eb 0e                	jmp    8006c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006be:	89 08                	mov    %ecx,(%eax)
  8006c0:	8b 02                	mov    (%edx),%eax
  8006c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8006d8:	73 0a                	jae    8006e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	88 0a                	mov    %cl,(%edx)
  8006df:	83 c2 01             	add    $0x1,%edx
  8006e2:	89 10                	mov    %edx,(%eax)
}
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	e8 02 00 00 00       	call   80070e <vprintfmt>
	va_end(ap);
}
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    

0080070e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	57                   	push   %edi
  800712:	56                   	push   %esi
  800713:	53                   	push   %ebx
  800714:	83 ec 5c             	sub    $0x5c,%esp
  800717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071a:	8b 75 10             	mov    0x10(%ebp),%esi
  80071d:	eb 12                	jmp    800731 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80071f:	85 c0                	test   %eax,%eax
  800721:	0f 84 e4 04 00 00    	je     800c0b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800727:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800731:	0f b6 06             	movzbl (%esi),%eax
  800734:	83 c6 01             	add    $0x1,%esi
  800737:	83 f8 25             	cmp    $0x25,%eax
  80073a:	75 e3                	jne    80071f <vprintfmt+0x11>
  80073c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800740:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800747:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80074c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800753:	b9 00 00 00 00       	mov    $0x0,%ecx
  800758:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80075b:	eb 2b                	jmp    800788 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800760:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800764:	eb 22                	jmp    800788 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800766:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80076d:	eb 19                	jmp    800788 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800772:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800779:	eb 0d                	jmp    800788 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80077b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80077e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800781:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	0f b6 06             	movzbl (%esi),%eax
  80078b:	0f b6 d0             	movzbl %al,%edx
  80078e:	8d 7e 01             	lea    0x1(%esi),%edi
  800791:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800794:	83 e8 23             	sub    $0x23,%eax
  800797:	3c 55                	cmp    $0x55,%al
  800799:	0f 87 46 04 00 00    	ja     800be5 <vprintfmt+0x4d7>
  80079f:	0f b6 c0             	movzbl %al,%eax
  8007a2:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007a9:	83 ea 30             	sub    $0x30,%edx
  8007ac:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8007af:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8007b3:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8007b9:	83 fa 09             	cmp    $0x9,%edx
  8007bc:	77 4a                	ja     800808 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007c1:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8007c4:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8007c7:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8007cb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007ce:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007d1:	83 fa 09             	cmp    $0x9,%edx
  8007d4:	76 eb                	jbe    8007c1 <vprintfmt+0xb3>
  8007d6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8007d9:	eb 2d                	jmp    800808 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 04             	lea    0x4(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 00                	mov    (%eax),%eax
  8007e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007ec:	eb 1a                	jmp    800808 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007f5:	79 91                	jns    800788 <vprintfmt+0x7a>
  8007f7:	e9 73 ff ff ff       	jmp    80076f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007ff:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800806:	eb 80                	jmp    800788 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800808:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80080c:	0f 89 76 ff ff ff    	jns    800788 <vprintfmt+0x7a>
  800812:	e9 64 ff ff ff       	jmp    80077b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800817:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80081d:	e9 66 ff ff ff       	jmp    800788 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8d 50 04             	lea    0x4(%eax),%edx
  800828:	89 55 14             	mov    %edx,0x14(%ebp)
  80082b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	89 04 24             	mov    %eax,(%esp)
  800834:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80083a:	e9 f2 fe ff ff       	jmp    800731 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80083f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800843:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800846:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80084a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80084d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800851:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800854:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800857:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80085b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80085e:	80 f9 09             	cmp    $0x9,%cl
  800861:	77 1d                	ja     800880 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800863:	0f be c0             	movsbl %al,%eax
  800866:	6b c0 64             	imul   $0x64,%eax,%eax
  800869:	0f be d2             	movsbl %dl,%edx
  80086c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80086f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800876:	a3 04 20 80 00       	mov    %eax,0x802004
  80087b:	e9 b1 fe ff ff       	jmp    800731 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800880:	c7 44 24 04 95 14 80 	movl   $0x801495,0x4(%esp)
  800887:	00 
  800888:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80088b:	89 04 24             	mov    %eax,(%esp)
  80088e:	e8 18 05 00 00       	call   800dab <strcmp>
  800893:	85 c0                	test   %eax,%eax
  800895:	75 0f                	jne    8008a6 <vprintfmt+0x198>
  800897:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80089e:	00 00 00 
  8008a1:	e9 8b fe ff ff       	jmp    800731 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8008a6:	c7 44 24 04 99 14 80 	movl   $0x801499,0x4(%esp)
  8008ad:	00 
  8008ae:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008b1:	89 14 24             	mov    %edx,(%esp)
  8008b4:	e8 f2 04 00 00       	call   800dab <strcmp>
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	75 0f                	jne    8008cc <vprintfmt+0x1be>
  8008bd:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8008c4:	00 00 00 
  8008c7:	e9 65 fe ff ff       	jmp    800731 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8008cc:	c7 44 24 04 9d 14 80 	movl   $0x80149d,0x4(%esp)
  8008d3:	00 
  8008d4:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8008d7:	89 0c 24             	mov    %ecx,(%esp)
  8008da:	e8 cc 04 00 00       	call   800dab <strcmp>
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	75 0f                	jne    8008f2 <vprintfmt+0x1e4>
  8008e3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8008ea:	00 00 00 
  8008ed:	e9 3f fe ff ff       	jmp    800731 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008f2:	c7 44 24 04 a1 14 80 	movl   $0x8014a1,0x4(%esp)
  8008f9:	00 
  8008fa:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008fd:	89 3c 24             	mov    %edi,(%esp)
  800900:	e8 a6 04 00 00       	call   800dab <strcmp>
  800905:	85 c0                	test   %eax,%eax
  800907:	75 0f                	jne    800918 <vprintfmt+0x20a>
  800909:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800910:	00 00 00 
  800913:	e9 19 fe ff ff       	jmp    800731 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800918:	c7 44 24 04 a5 14 80 	movl   $0x8014a5,0x4(%esp)
  80091f:	00 
  800920:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800923:	89 04 24             	mov    %eax,(%esp)
  800926:	e8 80 04 00 00       	call   800dab <strcmp>
  80092b:	85 c0                	test   %eax,%eax
  80092d:	75 0f                	jne    80093e <vprintfmt+0x230>
  80092f:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800936:	00 00 00 
  800939:	e9 f3 fd ff ff       	jmp    800731 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80093e:	c7 44 24 04 a9 14 80 	movl   $0x8014a9,0x4(%esp)
  800945:	00 
  800946:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800949:	89 14 24             	mov    %edx,(%esp)
  80094c:	e8 5a 04 00 00       	call   800dab <strcmp>
  800951:	83 f8 01             	cmp    $0x1,%eax
  800954:	19 c0                	sbb    %eax,%eax
  800956:	f7 d0                	not    %eax
  800958:	83 c0 08             	add    $0x8,%eax
  80095b:	a3 04 20 80 00       	mov    %eax,0x802004
  800960:	e9 cc fd ff ff       	jmp    800731 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800965:	8b 45 14             	mov    0x14(%ebp),%eax
  800968:	8d 50 04             	lea    0x4(%eax),%edx
  80096b:	89 55 14             	mov    %edx,0x14(%ebp)
  80096e:	8b 00                	mov    (%eax),%eax
  800970:	89 c2                	mov    %eax,%edx
  800972:	c1 fa 1f             	sar    $0x1f,%edx
  800975:	31 d0                	xor    %edx,%eax
  800977:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800979:	83 f8 08             	cmp    $0x8,%eax
  80097c:	7f 0b                	jg     800989 <vprintfmt+0x27b>
  80097e:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  800985:	85 d2                	test   %edx,%edx
  800987:	75 23                	jne    8009ac <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098d:	c7 44 24 08 ad 14 80 	movl   $0x8014ad,0x8(%esp)
  800994:	00 
  800995:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800999:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099c:	89 3c 24             	mov    %edi,(%esp)
  80099f:	e8 42 fd ff ff       	call   8006e6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009a7:	e9 85 fd ff ff       	jmp    800731 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8009ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009b0:	c7 44 24 08 b6 14 80 	movl   $0x8014b6,0x8(%esp)
  8009b7:	00 
  8009b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bf:	89 3c 24             	mov    %edi,(%esp)
  8009c2:	e8 1f fd ff ff       	call   8006e6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8009ca:	e9 62 fd ff ff       	jmp    800731 <vprintfmt+0x23>
  8009cf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8009d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009d5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009db:	8d 50 04             	lea    0x4(%eax),%edx
  8009de:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009e3:	85 f6                	test   %esi,%esi
  8009e5:	b8 8e 14 80 00       	mov    $0x80148e,%eax
  8009ea:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009f1:	7e 06                	jle    8009f9 <vprintfmt+0x2eb>
  8009f3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009f7:	75 13                	jne    800a0c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f9:	0f be 06             	movsbl (%esi),%eax
  8009fc:	83 c6 01             	add    $0x1,%esi
  8009ff:	85 c0                	test   %eax,%eax
  800a01:	0f 85 94 00 00 00    	jne    800a9b <vprintfmt+0x38d>
  800a07:	e9 81 00 00 00       	jmp    800a8d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a10:	89 34 24             	mov    %esi,(%esp)
  800a13:	e8 a3 02 00 00       	call   800cbb <strnlen>
  800a18:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a1b:	29 c2                	sub    %eax,%edx
  800a1d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800a20:	85 d2                	test   %edx,%edx
  800a22:	7e d5                	jle    8009f9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800a24:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800a28:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800a2b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800a2e:	89 d6                	mov    %edx,%esi
  800a30:	89 cf                	mov    %ecx,%edi
  800a32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a36:	89 3c 24             	mov    %edi,(%esp)
  800a39:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a3c:	83 ee 01             	sub    $0x1,%esi
  800a3f:	75 f1                	jne    800a32 <vprintfmt+0x324>
  800a41:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a44:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a47:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a4a:	eb ad                	jmp    8009f9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a4c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a50:	74 1b                	je     800a6d <vprintfmt+0x35f>
  800a52:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a55:	83 fa 5e             	cmp    $0x5e,%edx
  800a58:	76 13                	jbe    800a6d <vprintfmt+0x35f>
					putch('?', putdat);
  800a5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a61:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a68:	ff 55 08             	call   *0x8(%ebp)
  800a6b:	eb 0d                	jmp    800a7a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a6d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a70:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a74:	89 04 24             	mov    %eax,(%esp)
  800a77:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7a:	83 eb 01             	sub    $0x1,%ebx
  800a7d:	0f be 06             	movsbl (%esi),%eax
  800a80:	83 c6 01             	add    $0x1,%esi
  800a83:	85 c0                	test   %eax,%eax
  800a85:	75 1a                	jne    800aa1 <vprintfmt+0x393>
  800a87:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a8a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a90:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a94:	7f 1c                	jg     800ab2 <vprintfmt+0x3a4>
  800a96:	e9 96 fc ff ff       	jmp    800731 <vprintfmt+0x23>
  800a9b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a9e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	78 a7                	js     800a4c <vprintfmt+0x33e>
  800aa5:	83 ef 01             	sub    $0x1,%edi
  800aa8:	79 a2                	jns    800a4c <vprintfmt+0x33e>
  800aaa:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800aad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ab0:	eb db                	jmp    800a8d <vprintfmt+0x37f>
  800ab2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab5:	89 de                	mov    %ebx,%esi
  800ab7:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800abe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ac5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ac7:	83 eb 01             	sub    $0x1,%ebx
  800aca:	75 ee                	jne    800aba <vprintfmt+0x3ac>
  800acc:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ace:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ad1:	e9 5b fc ff ff       	jmp    800731 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ad6:	83 f9 01             	cmp    $0x1,%ecx
  800ad9:	7e 10                	jle    800aeb <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800adb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ade:	8d 50 08             	lea    0x8(%eax),%edx
  800ae1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae4:	8b 30                	mov    (%eax),%esi
  800ae6:	8b 78 04             	mov    0x4(%eax),%edi
  800ae9:	eb 26                	jmp    800b11 <vprintfmt+0x403>
	else if (lflag)
  800aeb:	85 c9                	test   %ecx,%ecx
  800aed:	74 12                	je     800b01 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8d 50 04             	lea    0x4(%eax),%edx
  800af5:	89 55 14             	mov    %edx,0x14(%ebp)
  800af8:	8b 30                	mov    (%eax),%esi
  800afa:	89 f7                	mov    %esi,%edi
  800afc:	c1 ff 1f             	sar    $0x1f,%edi
  800aff:	eb 10                	jmp    800b11 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800b01:	8b 45 14             	mov    0x14(%ebp),%eax
  800b04:	8d 50 04             	lea    0x4(%eax),%edx
  800b07:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0a:	8b 30                	mov    (%eax),%esi
  800b0c:	89 f7                	mov    %esi,%edi
  800b0e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b11:	85 ff                	test   %edi,%edi
  800b13:	78 0e                	js     800b23 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b15:	89 f0                	mov    %esi,%eax
  800b17:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b19:	be 0a 00 00 00       	mov    $0xa,%esi
  800b1e:	e9 84 00 00 00       	jmp    800ba7 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800b23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b27:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b2e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b31:	89 f0                	mov    %esi,%eax
  800b33:	89 fa                	mov    %edi,%edx
  800b35:	f7 d8                	neg    %eax
  800b37:	83 d2 00             	adc    $0x0,%edx
  800b3a:	f7 da                	neg    %edx
			}
			base = 10;
  800b3c:	be 0a 00 00 00       	mov    $0xa,%esi
  800b41:	eb 64                	jmp    800ba7 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b43:	89 ca                	mov    %ecx,%edx
  800b45:	8d 45 14             	lea    0x14(%ebp),%eax
  800b48:	e8 42 fb ff ff       	call   80068f <getuint>
			base = 10;
  800b4d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b52:	eb 53                	jmp    800ba7 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b54:	89 ca                	mov    %ecx,%edx
  800b56:	8d 45 14             	lea    0x14(%ebp),%eax
  800b59:	e8 31 fb ff ff       	call   80068f <getuint>
    			base = 8;
  800b5e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b63:	eb 42                	jmp    800ba7 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b69:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b70:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b77:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b7e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b81:	8b 45 14             	mov    0x14(%ebp),%eax
  800b84:	8d 50 04             	lea    0x4(%eax),%edx
  800b87:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b8a:	8b 00                	mov    (%eax),%eax
  800b8c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b91:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b96:	eb 0f                	jmp    800ba7 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b98:	89 ca                	mov    %ecx,%edx
  800b9a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9d:	e8 ed fa ff ff       	call   80068f <getuint>
			base = 16;
  800ba2:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ba7:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800bab:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800baf:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800bb2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800bb6:	89 74 24 08          	mov    %esi,0x8(%esp)
  800bba:	89 04 24             	mov    %eax,(%esp)
  800bbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc1:	89 da                	mov    %ebx,%edx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	e8 e9 f9 ff ff       	call   8005b4 <printnum>
			break;
  800bcb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800bce:	e9 5e fb ff ff       	jmp    800731 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bd7:	89 14 24             	mov    %edx,(%esp)
  800bda:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bdd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800be0:	e9 4c fb ff ff       	jmp    800731 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800be5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800be9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bf0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bf3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bf7:	0f 84 34 fb ff ff    	je     800731 <vprintfmt+0x23>
  800bfd:	83 ee 01             	sub    $0x1,%esi
  800c00:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c04:	75 f7                	jne    800bfd <vprintfmt+0x4ef>
  800c06:	e9 26 fb ff ff       	jmp    800731 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800c0b:	83 c4 5c             	add    $0x5c,%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 28             	sub    $0x28,%esp
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c22:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c26:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	74 30                	je     800c64 <vsnprintf+0x51>
  800c34:	85 d2                	test   %edx,%edx
  800c36:	7e 2c                	jle    800c64 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c38:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c46:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4d:	c7 04 24 c9 06 80 00 	movl   $0x8006c9,(%esp)
  800c54:	e8 b5 fa ff ff       	call   80070e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c62:	eb 05                	jmp    800c69 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c71:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	89 04 24             	mov    %eax,(%esp)
  800c8c:	e8 82 ff ff ff       	call   800c13 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    
	...

00800ca0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cab:	80 3a 00             	cmpb   $0x0,(%edx)
  800cae:	74 09                	je     800cb9 <strlen+0x19>
		n++;
  800cb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cb7:	75 f7                	jne    800cb0 <strlen+0x10>
		n++;
	return n;
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	53                   	push   %ebx
  800cbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	85 c9                	test   %ecx,%ecx
  800ccc:	74 1a                	je     800ce8 <strnlen+0x2d>
  800cce:	80 3b 00             	cmpb   $0x0,(%ebx)
  800cd1:	74 15                	je     800ce8 <strnlen+0x2d>
  800cd3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800cd8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cda:	39 ca                	cmp    %ecx,%edx
  800cdc:	74 0a                	je     800ce8 <strnlen+0x2d>
  800cde:	83 c2 01             	add    $0x1,%edx
  800ce1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ce6:	75 f0                	jne    800cd8 <strnlen+0x1d>
		n++;
	return n;
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cfe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d01:	83 c2 01             	add    $0x1,%edx
  800d04:	84 c9                	test   %cl,%cl
  800d06:	75 f2                	jne    800cfa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d08:	5b                   	pop    %ebx
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 08             	sub    $0x8,%esp
  800d12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d15:	89 1c 24             	mov    %ebx,(%esp)
  800d18:	e8 83 ff ff ff       	call   800ca0 <strlen>
	strcpy(dst + len, src);
  800d1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d20:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d24:	01 d8                	add    %ebx,%eax
  800d26:	89 04 24             	mov    %eax,(%esp)
  800d29:	e8 bd ff ff ff       	call   800ceb <strcpy>
	return dst;
}
  800d2e:	89 d8                	mov    %ebx,%eax
  800d30:	83 c4 08             	add    $0x8,%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d44:	85 f6                	test   %esi,%esi
  800d46:	74 18                	je     800d60 <strncpy+0x2a>
  800d48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d4d:	0f b6 1a             	movzbl (%edx),%ebx
  800d50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d53:	80 3a 01             	cmpb   $0x1,(%edx)
  800d56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d59:	83 c1 01             	add    $0x1,%ecx
  800d5c:	39 f1                	cmp    %esi,%ecx
  800d5e:	75 ed                	jne    800d4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d70:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d73:	89 f8                	mov    %edi,%eax
  800d75:	85 f6                	test   %esi,%esi
  800d77:	74 2b                	je     800da4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d79:	83 fe 01             	cmp    $0x1,%esi
  800d7c:	74 23                	je     800da1 <strlcpy+0x3d>
  800d7e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d81:	84 c9                	test   %cl,%cl
  800d83:	74 1c                	je     800da1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d85:	83 ee 02             	sub    $0x2,%esi
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d8d:	88 08                	mov    %cl,(%eax)
  800d8f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d92:	39 f2                	cmp    %esi,%edx
  800d94:	74 0b                	je     800da1 <strlcpy+0x3d>
  800d96:	83 c2 01             	add    $0x1,%edx
  800d99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d9d:	84 c9                	test   %cl,%cl
  800d9f:	75 ec                	jne    800d8d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800da1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da4:	29 f8                	sub    %edi,%eax
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db4:	0f b6 01             	movzbl (%ecx),%eax
  800db7:	84 c0                	test   %al,%al
  800db9:	74 16                	je     800dd1 <strcmp+0x26>
  800dbb:	3a 02                	cmp    (%edx),%al
  800dbd:	75 12                	jne    800dd1 <strcmp+0x26>
		p++, q++;
  800dbf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800dc6:	84 c0                	test   %al,%al
  800dc8:	74 07                	je     800dd1 <strcmp+0x26>
  800dca:	83 c1 01             	add    $0x1,%ecx
  800dcd:	3a 02                	cmp    (%edx),%al
  800dcf:	74 ee                	je     800dbf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd1:	0f b6 c0             	movzbl %al,%eax
  800dd4:	0f b6 12             	movzbl (%edx),%edx
  800dd7:	29 d0                	sub    %edx,%eax
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ded:	85 d2                	test   %edx,%edx
  800def:	74 28                	je     800e19 <strncmp+0x3e>
  800df1:	0f b6 01             	movzbl (%ecx),%eax
  800df4:	84 c0                	test   %al,%al
  800df6:	74 24                	je     800e1c <strncmp+0x41>
  800df8:	3a 03                	cmp    (%ebx),%al
  800dfa:	75 20                	jne    800e1c <strncmp+0x41>
  800dfc:	83 ea 01             	sub    $0x1,%edx
  800dff:	74 13                	je     800e14 <strncmp+0x39>
		n--, p++, q++;
  800e01:	83 c1 01             	add    $0x1,%ecx
  800e04:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e07:	0f b6 01             	movzbl (%ecx),%eax
  800e0a:	84 c0                	test   %al,%al
  800e0c:	74 0e                	je     800e1c <strncmp+0x41>
  800e0e:	3a 03                	cmp    (%ebx),%al
  800e10:	74 ea                	je     800dfc <strncmp+0x21>
  800e12:	eb 08                	jmp    800e1c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e1c:	0f b6 01             	movzbl (%ecx),%eax
  800e1f:	0f b6 13             	movzbl (%ebx),%edx
  800e22:	29 d0                	sub    %edx,%eax
  800e24:	eb f3                	jmp    800e19 <strncmp+0x3e>

00800e26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e30:	0f b6 10             	movzbl (%eax),%edx
  800e33:	84 d2                	test   %dl,%dl
  800e35:	74 1c                	je     800e53 <strchr+0x2d>
		if (*s == c)
  800e37:	38 ca                	cmp    %cl,%dl
  800e39:	75 09                	jne    800e44 <strchr+0x1e>
  800e3b:	eb 1b                	jmp    800e58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800e40:	38 ca                	cmp    %cl,%dl
  800e42:	74 14                	je     800e58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e44:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800e48:	84 d2                	test   %dl,%dl
  800e4a:	75 f1                	jne    800e3d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e51:	eb 05                	jmp    800e58 <strchr+0x32>
  800e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e64:	0f b6 10             	movzbl (%eax),%edx
  800e67:	84 d2                	test   %dl,%dl
  800e69:	74 14                	je     800e7f <strfind+0x25>
		if (*s == c)
  800e6b:	38 ca                	cmp    %cl,%dl
  800e6d:	75 06                	jne    800e75 <strfind+0x1b>
  800e6f:	eb 0e                	jmp    800e7f <strfind+0x25>
  800e71:	38 ca                	cmp    %cl,%dl
  800e73:	74 0a                	je     800e7f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e75:	83 c0 01             	add    $0x1,%eax
  800e78:	0f b6 10             	movzbl (%eax),%edx
  800e7b:	84 d2                	test   %dl,%dl
  800e7d:	75 f2                	jne    800e71 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e99:	85 c9                	test   %ecx,%ecx
  800e9b:	74 30                	je     800ecd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ea3:	75 25                	jne    800eca <memset+0x49>
  800ea5:	f6 c1 03             	test   $0x3,%cl
  800ea8:	75 20                	jne    800eca <memset+0x49>
		c &= 0xFF;
  800eaa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ead:	89 d3                	mov    %edx,%ebx
  800eaf:	c1 e3 08             	shl    $0x8,%ebx
  800eb2:	89 d6                	mov    %edx,%esi
  800eb4:	c1 e6 18             	shl    $0x18,%esi
  800eb7:	89 d0                	mov    %edx,%eax
  800eb9:	c1 e0 10             	shl    $0x10,%eax
  800ebc:	09 f0                	or     %esi,%eax
  800ebe:	09 d0                	or     %edx,%eax
  800ec0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ec2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ec5:	fc                   	cld    
  800ec6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec8:	eb 03                	jmp    800ecd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eca:	fc                   	cld    
  800ecb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ecd:	89 f8                	mov    %edi,%eax
  800ecf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed8:	89 ec                	mov    %ebp,%esp
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 08             	sub    $0x8,%esp
  800ee2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ef1:	39 c6                	cmp    %eax,%esi
  800ef3:	73 36                	jae    800f2b <memmove+0x4f>
  800ef5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ef8:	39 d0                	cmp    %edx,%eax
  800efa:	73 2f                	jae    800f2b <memmove+0x4f>
		s += n;
		d += n;
  800efc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eff:	f6 c2 03             	test   $0x3,%dl
  800f02:	75 1b                	jne    800f1f <memmove+0x43>
  800f04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f0a:	75 13                	jne    800f1f <memmove+0x43>
  800f0c:	f6 c1 03             	test   $0x3,%cl
  800f0f:	75 0e                	jne    800f1f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f11:	83 ef 04             	sub    $0x4,%edi
  800f14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f1a:	fd                   	std    
  800f1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1d:	eb 09                	jmp    800f28 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f1f:	83 ef 01             	sub    $0x1,%edi
  800f22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f25:	fd                   	std    
  800f26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f28:	fc                   	cld    
  800f29:	eb 20                	jmp    800f4b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f31:	75 13                	jne    800f46 <memmove+0x6a>
  800f33:	a8 03                	test   $0x3,%al
  800f35:	75 0f                	jne    800f46 <memmove+0x6a>
  800f37:	f6 c1 03             	test   $0x3,%cl
  800f3a:	75 0a                	jne    800f46 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f3c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f3f:	89 c7                	mov    %eax,%edi
  800f41:	fc                   	cld    
  800f42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f44:	eb 05                	jmp    800f4b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f46:	89 c7                	mov    %eax,%edi
  800f48:	fc                   	cld    
  800f49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f51:	89 ec                	mov    %ebp,%esp
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	89 04 24             	mov    %eax,(%esp)
  800f6f:	e8 68 ff ff ff       	call   800edc <memmove>
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f82:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f8a:	85 ff                	test   %edi,%edi
  800f8c:	74 37                	je     800fc5 <memcmp+0x4f>
		if (*s1 != *s2)
  800f8e:	0f b6 03             	movzbl (%ebx),%eax
  800f91:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f94:	83 ef 01             	sub    $0x1,%edi
  800f97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f9c:	38 c8                	cmp    %cl,%al
  800f9e:	74 1c                	je     800fbc <memcmp+0x46>
  800fa0:	eb 10                	jmp    800fb2 <memcmp+0x3c>
  800fa2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800fa7:	83 c2 01             	add    $0x1,%edx
  800faa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800fae:	38 c8                	cmp    %cl,%al
  800fb0:	74 0a                	je     800fbc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800fb2:	0f b6 c0             	movzbl %al,%eax
  800fb5:	0f b6 c9             	movzbl %cl,%ecx
  800fb8:	29 c8                	sub    %ecx,%eax
  800fba:	eb 09                	jmp    800fc5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fbc:	39 fa                	cmp    %edi,%edx
  800fbe:	75 e2                	jne    800fa2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fd0:	89 c2                	mov    %eax,%edx
  800fd2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fd5:	39 d0                	cmp    %edx,%eax
  800fd7:	73 19                	jae    800ff2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800fdd:	38 08                	cmp    %cl,(%eax)
  800fdf:	75 06                	jne    800fe7 <memfind+0x1d>
  800fe1:	eb 0f                	jmp    800ff2 <memfind+0x28>
  800fe3:	38 08                	cmp    %cl,(%eax)
  800fe5:	74 0b                	je     800ff2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fe7:	83 c0 01             	add    $0x1,%eax
  800fea:	39 d0                	cmp    %edx,%eax
  800fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	75 f1                	jne    800fe3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801000:	0f b6 02             	movzbl (%edx),%eax
  801003:	3c 20                	cmp    $0x20,%al
  801005:	74 04                	je     80100b <strtol+0x17>
  801007:	3c 09                	cmp    $0x9,%al
  801009:	75 0e                	jne    801019 <strtol+0x25>
		s++;
  80100b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100e:	0f b6 02             	movzbl (%edx),%eax
  801011:	3c 20                	cmp    $0x20,%al
  801013:	74 f6                	je     80100b <strtol+0x17>
  801015:	3c 09                	cmp    $0x9,%al
  801017:	74 f2                	je     80100b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801019:	3c 2b                	cmp    $0x2b,%al
  80101b:	75 0a                	jne    801027 <strtol+0x33>
		s++;
  80101d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801020:	bf 00 00 00 00       	mov    $0x0,%edi
  801025:	eb 10                	jmp    801037 <strtol+0x43>
  801027:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80102c:	3c 2d                	cmp    $0x2d,%al
  80102e:	75 07                	jne    801037 <strtol+0x43>
		s++, neg = 1;
  801030:	83 c2 01             	add    $0x1,%edx
  801033:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801037:	85 db                	test   %ebx,%ebx
  801039:	0f 94 c0             	sete   %al
  80103c:	74 05                	je     801043 <strtol+0x4f>
  80103e:	83 fb 10             	cmp    $0x10,%ebx
  801041:	75 15                	jne    801058 <strtol+0x64>
  801043:	80 3a 30             	cmpb   $0x30,(%edx)
  801046:	75 10                	jne    801058 <strtol+0x64>
  801048:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80104c:	75 0a                	jne    801058 <strtol+0x64>
		s += 2, base = 16;
  80104e:	83 c2 02             	add    $0x2,%edx
  801051:	bb 10 00 00 00       	mov    $0x10,%ebx
  801056:	eb 13                	jmp    80106b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801058:	84 c0                	test   %al,%al
  80105a:	74 0f                	je     80106b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80105c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801061:	80 3a 30             	cmpb   $0x30,(%edx)
  801064:	75 05                	jne    80106b <strtol+0x77>
		s++, base = 8;
  801066:	83 c2 01             	add    $0x1,%edx
  801069:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
  801070:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801072:	0f b6 0a             	movzbl (%edx),%ecx
  801075:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801078:	80 fb 09             	cmp    $0x9,%bl
  80107b:	77 08                	ja     801085 <strtol+0x91>
			dig = *s - '0';
  80107d:	0f be c9             	movsbl %cl,%ecx
  801080:	83 e9 30             	sub    $0x30,%ecx
  801083:	eb 1e                	jmp    8010a3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801085:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801088:	80 fb 19             	cmp    $0x19,%bl
  80108b:	77 08                	ja     801095 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80108d:	0f be c9             	movsbl %cl,%ecx
  801090:	83 e9 57             	sub    $0x57,%ecx
  801093:	eb 0e                	jmp    8010a3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801095:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801098:	80 fb 19             	cmp    $0x19,%bl
  80109b:	77 14                	ja     8010b1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80109d:	0f be c9             	movsbl %cl,%ecx
  8010a0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8010a3:	39 f1                	cmp    %esi,%ecx
  8010a5:	7d 0e                	jge    8010b5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8010a7:	83 c2 01             	add    $0x1,%edx
  8010aa:	0f af c6             	imul   %esi,%eax
  8010ad:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8010af:	eb c1                	jmp    801072 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8010b1:	89 c1                	mov    %eax,%ecx
  8010b3:	eb 02                	jmp    8010b7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010b5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8010b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010bb:	74 05                	je     8010c2 <strtol+0xce>
		*endptr = (char *) s;
  8010bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010c0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8010c2:	89 ca                	mov    %ecx,%edx
  8010c4:	f7 da                	neg    %edx
  8010c6:	85 ff                	test   %edi,%edi
  8010c8:	0f 45 c2             	cmovne %edx,%eax
}
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010d6:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010dd:	75 3c                	jne    80111b <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8010df:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010ee:	ee 
  8010ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f6:	e8 e1 f0 ff ff       	call   8001dc <sys_page_alloc>
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 1c                	jns    80111b <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  8010ff:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  801106:	00 
  801107:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80110e:	00 
  80110f:	c7 04 24 48 17 80 00 	movl   $0x801748,(%esp)
  801116:	e8 81 f3 ff ff       	call   80049c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801123:	c7 44 24 04 78 04 80 	movl   $0x800478,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801132:	e8 1e f2 ff ff       	call   800355 <sys_env_set_pgfault_upcall>
  801137:	85 c0                	test   %eax,%eax
  801139:	79 1c                	jns    801157 <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80113b:	c7 44 24 08 10 17 80 	movl   $0x801710,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 48 17 80 00 	movl   $0x801748,(%esp)
  801152:	e8 45 f3 ff ff       	call   80049c <_panic>
}
  801157:	c9                   	leave  
  801158:	c3                   	ret    
  801159:	00 00                	add    %al,(%eax)
  80115b:	00 00                	add    %al,(%eax)
  80115d:	00 00                	add    %al,(%eax)
	...

00801160 <__udivdi3>:
  801160:	83 ec 1c             	sub    $0x1c,%esp
  801163:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801167:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80116b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80116f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801173:	89 74 24 10          	mov    %esi,0x10(%esp)
  801177:	8b 74 24 24          	mov    0x24(%esp),%esi
  80117b:	85 ff                	test   %edi,%edi
  80117d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801181:	89 44 24 08          	mov    %eax,0x8(%esp)
  801185:	89 cd                	mov    %ecx,%ebp
  801187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118b:	75 33                	jne    8011c0 <__udivdi3+0x60>
  80118d:	39 f1                	cmp    %esi,%ecx
  80118f:	77 57                	ja     8011e8 <__udivdi3+0x88>
  801191:	85 c9                	test   %ecx,%ecx
  801193:	75 0b                	jne    8011a0 <__udivdi3+0x40>
  801195:	b8 01 00 00 00       	mov    $0x1,%eax
  80119a:	31 d2                	xor    %edx,%edx
  80119c:	f7 f1                	div    %ecx
  80119e:	89 c1                	mov    %eax,%ecx
  8011a0:	89 f0                	mov    %esi,%eax
  8011a2:	31 d2                	xor    %edx,%edx
  8011a4:	f7 f1                	div    %ecx
  8011a6:	89 c6                	mov    %eax,%esi
  8011a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8011ac:	f7 f1                	div    %ecx
  8011ae:	89 f2                	mov    %esi,%edx
  8011b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011bc:	83 c4 1c             	add    $0x1c,%esp
  8011bf:	c3                   	ret    
  8011c0:	31 d2                	xor    %edx,%edx
  8011c2:	31 c0                	xor    %eax,%eax
  8011c4:	39 f7                	cmp    %esi,%edi
  8011c6:	77 e8                	ja     8011b0 <__udivdi3+0x50>
  8011c8:	0f bd cf             	bsr    %edi,%ecx
  8011cb:	83 f1 1f             	xor    $0x1f,%ecx
  8011ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011d2:	75 2c                	jne    801200 <__udivdi3+0xa0>
  8011d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8011d8:	76 04                	jbe    8011de <__udivdi3+0x7e>
  8011da:	39 f7                	cmp    %esi,%edi
  8011dc:	73 d2                	jae    8011b0 <__udivdi3+0x50>
  8011de:	31 d2                	xor    %edx,%edx
  8011e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e5:	eb c9                	jmp    8011b0 <__udivdi3+0x50>
  8011e7:	90                   	nop
  8011e8:	89 f2                	mov    %esi,%edx
  8011ea:	f7 f1                	div    %ecx
  8011ec:	31 d2                	xor    %edx,%edx
  8011ee:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011fa:	83 c4 1c             	add    $0x1c,%esp
  8011fd:	c3                   	ret    
  8011fe:	66 90                	xchg   %ax,%ax
  801200:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801205:	b8 20 00 00 00       	mov    $0x20,%eax
  80120a:	89 ea                	mov    %ebp,%edx
  80120c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801210:	d3 e7                	shl    %cl,%edi
  801212:	89 c1                	mov    %eax,%ecx
  801214:	d3 ea                	shr    %cl,%edx
  801216:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80121b:	09 fa                	or     %edi,%edx
  80121d:	89 f7                	mov    %esi,%edi
  80121f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801223:	89 f2                	mov    %esi,%edx
  801225:	8b 74 24 08          	mov    0x8(%esp),%esi
  801229:	d3 e5                	shl    %cl,%ebp
  80122b:	89 c1                	mov    %eax,%ecx
  80122d:	d3 ef                	shr    %cl,%edi
  80122f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801234:	d3 e2                	shl    %cl,%edx
  801236:	89 c1                	mov    %eax,%ecx
  801238:	d3 ee                	shr    %cl,%esi
  80123a:	09 d6                	or     %edx,%esi
  80123c:	89 fa                	mov    %edi,%edx
  80123e:	89 f0                	mov    %esi,%eax
  801240:	f7 74 24 0c          	divl   0xc(%esp)
  801244:	89 d7                	mov    %edx,%edi
  801246:	89 c6                	mov    %eax,%esi
  801248:	f7 e5                	mul    %ebp
  80124a:	39 d7                	cmp    %edx,%edi
  80124c:	72 22                	jb     801270 <__udivdi3+0x110>
  80124e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801252:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801257:	d3 e5                	shl    %cl,%ebp
  801259:	39 c5                	cmp    %eax,%ebp
  80125b:	73 04                	jae    801261 <__udivdi3+0x101>
  80125d:	39 d7                	cmp    %edx,%edi
  80125f:	74 0f                	je     801270 <__udivdi3+0x110>
  801261:	89 f0                	mov    %esi,%eax
  801263:	31 d2                	xor    %edx,%edx
  801265:	e9 46 ff ff ff       	jmp    8011b0 <__udivdi3+0x50>
  80126a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801270:	8d 46 ff             	lea    -0x1(%esi),%eax
  801273:	31 d2                	xor    %edx,%edx
  801275:	8b 74 24 10          	mov    0x10(%esp),%esi
  801279:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80127d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801281:	83 c4 1c             	add    $0x1c,%esp
  801284:	c3                   	ret    
	...

00801290 <__umoddi3>:
  801290:	83 ec 1c             	sub    $0x1c,%esp
  801293:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801297:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80129b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80129f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8012a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8012ab:	85 ed                	test   %ebp,%ebp
  8012ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8012b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b5:	89 cf                	mov    %ecx,%edi
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	89 f2                	mov    %esi,%edx
  8012bc:	75 1a                	jne    8012d8 <__umoddi3+0x48>
  8012be:	39 f1                	cmp    %esi,%ecx
  8012c0:	76 4e                	jbe    801310 <__umoddi3+0x80>
  8012c2:	f7 f1                	div    %ecx
  8012c4:	89 d0                	mov    %edx,%eax
  8012c6:	31 d2                	xor    %edx,%edx
  8012c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012d4:	83 c4 1c             	add    $0x1c,%esp
  8012d7:	c3                   	ret    
  8012d8:	39 f5                	cmp    %esi,%ebp
  8012da:	77 54                	ja     801330 <__umoddi3+0xa0>
  8012dc:	0f bd c5             	bsr    %ebp,%eax
  8012df:	83 f0 1f             	xor    $0x1f,%eax
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	75 60                	jne    801348 <__umoddi3+0xb8>
  8012e8:	3b 0c 24             	cmp    (%esp),%ecx
  8012eb:	0f 87 07 01 00 00    	ja     8013f8 <__umoddi3+0x168>
  8012f1:	89 f2                	mov    %esi,%edx
  8012f3:	8b 34 24             	mov    (%esp),%esi
  8012f6:	29 ce                	sub    %ecx,%esi
  8012f8:	19 ea                	sbb    %ebp,%edx
  8012fa:	89 34 24             	mov    %esi,(%esp)
  8012fd:	8b 04 24             	mov    (%esp),%eax
  801300:	8b 74 24 10          	mov    0x10(%esp),%esi
  801304:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801308:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80130c:	83 c4 1c             	add    $0x1c,%esp
  80130f:	c3                   	ret    
  801310:	85 c9                	test   %ecx,%ecx
  801312:	75 0b                	jne    80131f <__umoddi3+0x8f>
  801314:	b8 01 00 00 00       	mov    $0x1,%eax
  801319:	31 d2                	xor    %edx,%edx
  80131b:	f7 f1                	div    %ecx
  80131d:	89 c1                	mov    %eax,%ecx
  80131f:	89 f0                	mov    %esi,%eax
  801321:	31 d2                	xor    %edx,%edx
  801323:	f7 f1                	div    %ecx
  801325:	8b 04 24             	mov    (%esp),%eax
  801328:	f7 f1                	div    %ecx
  80132a:	eb 98                	jmp    8012c4 <__umoddi3+0x34>
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	89 f2                	mov    %esi,%edx
  801332:	8b 74 24 10          	mov    0x10(%esp),%esi
  801336:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80133a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80133e:	83 c4 1c             	add    $0x1c,%esp
  801341:	c3                   	ret    
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80134d:	89 e8                	mov    %ebp,%eax
  80134f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801354:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801358:	89 fa                	mov    %edi,%edx
  80135a:	d3 e0                	shl    %cl,%eax
  80135c:	89 e9                	mov    %ebp,%ecx
  80135e:	d3 ea                	shr    %cl,%edx
  801360:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801365:	09 c2                	or     %eax,%edx
  801367:	8b 44 24 08          	mov    0x8(%esp),%eax
  80136b:	89 14 24             	mov    %edx,(%esp)
  80136e:	89 f2                	mov    %esi,%edx
  801370:	d3 e7                	shl    %cl,%edi
  801372:	89 e9                	mov    %ebp,%ecx
  801374:	d3 ea                	shr    %cl,%edx
  801376:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80137b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80137f:	d3 e6                	shl    %cl,%esi
  801381:	89 e9                	mov    %ebp,%ecx
  801383:	d3 e8                	shr    %cl,%eax
  801385:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80138a:	09 f0                	or     %esi,%eax
  80138c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801390:	f7 34 24             	divl   (%esp)
  801393:	d3 e6                	shl    %cl,%esi
  801395:	89 74 24 08          	mov    %esi,0x8(%esp)
  801399:	89 d6                	mov    %edx,%esi
  80139b:	f7 e7                	mul    %edi
  80139d:	39 d6                	cmp    %edx,%esi
  80139f:	89 c1                	mov    %eax,%ecx
  8013a1:	89 d7                	mov    %edx,%edi
  8013a3:	72 3f                	jb     8013e4 <__umoddi3+0x154>
  8013a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013a9:	72 35                	jb     8013e0 <__umoddi3+0x150>
  8013ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013af:	29 c8                	sub    %ecx,%eax
  8013b1:	19 fe                	sbb    %edi,%esi
  8013b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013b8:	89 f2                	mov    %esi,%edx
  8013ba:	d3 e8                	shr    %cl,%eax
  8013bc:	89 e9                	mov    %ebp,%ecx
  8013be:	d3 e2                	shl    %cl,%edx
  8013c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013c5:	09 d0                	or     %edx,%eax
  8013c7:	89 f2                	mov    %esi,%edx
  8013c9:	d3 ea                	shr    %cl,%edx
  8013cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013d7:	83 c4 1c             	add    $0x1c,%esp
  8013da:	c3                   	ret    
  8013db:	90                   	nop
  8013dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	39 d6                	cmp    %edx,%esi
  8013e2:	75 c7                	jne    8013ab <__umoddi3+0x11b>
  8013e4:	89 d7                	mov    %edx,%edi
  8013e6:	89 c1                	mov    %eax,%ecx
  8013e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8013ec:	1b 3c 24             	sbb    (%esp),%edi
  8013ef:	eb ba                	jmp    8013ab <__umoddi3+0x11b>
  8013f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	39 f5                	cmp    %esi,%ebp
  8013fa:	0f 82 f1 fe ff ff    	jb     8012f1 <__umoddi3+0x61>
  801400:	e9 f8 fe ff ff       	jmp    8012fd <__umoddi3+0x6d>
