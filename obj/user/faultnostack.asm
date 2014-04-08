
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
  80003a:	c7 44 24 04 44 04 80 	movl   $0x800444,0x4(%esp)
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
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
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
  800153:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  80016a:	e8 e1 02 00 00       	call   800450 <_panic>

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
  800212:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800229:	e8 22 02 00 00       	call   800450 <_panic>

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
  800270:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800287:	e8 c4 01 00 00       	call   800450 <_panic>

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
  8002ce:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8002e5:	e8 66 01 00 00       	call   800450 <_panic>

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
  80032c:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800343:	e8 08 01 00 00       	call   800450 <_panic>

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
  80038a:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  8003a1:	e8 aa 00 00 00       	call   800450 <_panic>

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
  80041b:	c7 44 24 08 8a 13 80 	movl   $0x80138a,0x8(%esp)
  800422:	00 
  800423:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80042a:	00 
  80042b:	c7 04 24 a7 13 80 00 	movl   $0x8013a7,(%esp)
  800432:	e8 19 00 00 00       	call   800450 <_panic>

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

00800444 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800444:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800445:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80044a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80044c:	83 c4 04             	add    $0x4,%esp
	...

00800450 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800458:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800461:	e8 16 fd ff ff       	call   80017c <sys_getenvid>
  800466:	8b 55 0c             	mov    0xc(%ebp),%edx
  800469:	89 54 24 10          	mov    %edx,0x10(%esp)
  80046d:	8b 55 08             	mov    0x8(%ebp),%edx
  800470:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800474:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047c:	c7 04 24 b8 13 80 00 	movl   $0x8013b8,(%esp)
  800483:	e8 c3 00 00 00       	call   80054b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800488:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048c:	8b 45 10             	mov    0x10(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	e8 53 00 00 00       	call   8004ea <vcprintf>
	cprintf("\n");
  800497:	c7 04 24 db 13 80 00 	movl   $0x8013db,(%esp)
  80049e:	e8 a8 00 00 00       	call   80054b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a3:	cc                   	int3   
  8004a4:	eb fd                	jmp    8004a3 <_panic+0x53>
	...

008004a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 14             	sub    $0x14,%esp
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b2:	8b 03                	mov    (%ebx),%eax
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bb:	83 c0 01             	add    $0x1,%eax
  8004be:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c5:	75 19                	jne    8004e0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004c7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ce:	00 
  8004cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d2:	89 04 24             	mov    %eax,(%esp)
  8004d5:	e8 e6 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8004da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004e4:	83 c4 14             	add    $0x14,%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fa:	00 00 00 
	b.cnt = 0;
  8004fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800504:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 44 24 08          	mov    %eax,0x8(%esp)
  800515:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	c7 04 24 a8 04 80 00 	movl   $0x8004a8,(%esp)
  800526:	e8 97 01 00 00       	call   8006c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800531:	89 44 24 04          	mov    %eax,0x4(%esp)
  800535:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	e8 7d fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800543:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800551:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 87 ff ff ff       	call   8004ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800563:	c9                   	leave  
  800564:	c3                   	ret    
  800565:	00 00                	add    %al,(%eax)
	...

00800568 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 3c             	sub    $0x3c,%esp
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	89 d7                	mov    %edx,%edi
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80057c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800585:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	b8 00 00 00 00       	mov    $0x0,%eax
  80058d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800590:	72 11                	jb     8005a3 <printnum+0x3b>
  800592:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800595:	39 45 10             	cmp    %eax,0x10(%ebp)
  800598:	76 09                	jbe    8005a3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80059a:	83 eb 01             	sub    $0x1,%ebx
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	7f 51                	jg     8005f2 <printnum+0x8a>
  8005a1:	eb 5e                	jmp    800601 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005a7:	83 eb 01             	sub    $0x1,%ebx
  8005aa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005b9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005c4:	00 
  8005c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d2:	e8 e9 0a 00 00       	call   8010c0 <__udivdi3>
  8005d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e6:	89 fa                	mov    %edi,%edx
  8005e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005eb:	e8 78 ff ff ff       	call   800568 <printnum>
  8005f0:	eb 0f                	jmp    800601 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	89 34 24             	mov    %esi,(%esp)
  8005f9:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005fc:	83 eb 01             	sub    $0x1,%ebx
  8005ff:	75 f1                	jne    8005f2 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800601:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800605:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800609:	8b 45 10             	mov    0x10(%ebp),%eax
  80060c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800610:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800617:	00 
  800618:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800621:	89 44 24 04          	mov    %eax,0x4(%esp)
  800625:	e8 c6 0b 00 00       	call   8011f0 <__umoddi3>
  80062a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062e:	0f be 80 dd 13 80 00 	movsbl 0x8013dd(%eax),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80063b:	83 c4 3c             	add    $0x3c,%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5f                   	pop    %edi
  800641:	5d                   	pop    %ebp
  800642:	c3                   	ret    

00800643 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800646:	83 fa 01             	cmp    $0x1,%edx
  800649:	7e 0e                	jle    800659 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800650:	89 08                	mov    %ecx,(%eax)
  800652:	8b 02                	mov    (%edx),%eax
  800654:	8b 52 04             	mov    0x4(%edx),%edx
  800657:	eb 22                	jmp    80067b <getuint+0x38>
	else if (lflag)
  800659:	85 d2                	test   %edx,%edx
  80065b:	74 10                	je     80066d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800662:	89 08                	mov    %ecx,(%eax)
  800664:	8b 02                	mov    (%edx),%eax
  800666:	ba 00 00 00 00       	mov    $0x0,%edx
  80066b:	eb 0e                	jmp    80067b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800672:	89 08                	mov    %ecx,(%eax)
  800674:	8b 02                	mov    (%edx),%eax
  800676:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800683:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800687:	8b 10                	mov    (%eax),%edx
  800689:	3b 50 04             	cmp    0x4(%eax),%edx
  80068c:	73 0a                	jae    800698 <sprintputch+0x1b>
		*b->buf++ = ch;
  80068e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800691:	88 0a                	mov    %cl,(%edx)
  800693:	83 c2 01             	add    $0x1,%edx
  800696:	89 10                	mov    %edx,(%eax)
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	e8 02 00 00 00       	call   8006c2 <vprintfmt>
	va_end(ap);
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	57                   	push   %edi
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	83 ec 5c             	sub    $0x5c,%esp
  8006cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8006d1:	eb 12                	jmp    8006e5 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	0f 84 e4 04 00 00    	je     800bbf <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006df:	89 04 24             	mov    %eax,(%esp)
  8006e2:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e5:	0f b6 06             	movzbl (%esi),%eax
  8006e8:	83 c6 01             	add    $0x1,%esi
  8006eb:	83 f8 25             	cmp    $0x25,%eax
  8006ee:	75 e3                	jne    8006d3 <vprintfmt+0x11>
  8006f0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8006f4:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8006fb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800700:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800707:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80070f:	eb 2b                	jmp    80073c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800711:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800714:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800718:	eb 22                	jmp    80073c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80071d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800721:	eb 19                	jmp    80073c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800723:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800726:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80072d:	eb 0d                	jmp    80073c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80072f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800732:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800735:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073c:	0f b6 06             	movzbl (%esi),%eax
  80073f:	0f b6 d0             	movzbl %al,%edx
  800742:	8d 7e 01             	lea    0x1(%esi),%edi
  800745:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800748:	83 e8 23             	sub    $0x23,%eax
  80074b:	3c 55                	cmp    $0x55,%al
  80074d:	0f 87 46 04 00 00    	ja     800b99 <vprintfmt+0x4d7>
  800753:	0f b6 c0             	movzbl %al,%eax
  800756:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80075d:	83 ea 30             	sub    $0x30,%edx
  800760:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800763:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800767:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80076d:	83 fa 09             	cmp    $0x9,%edx
  800770:	77 4a                	ja     8007bc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800775:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800778:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80077b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80077f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800782:	8d 50 d0             	lea    -0x30(%eax),%edx
  800785:	83 fa 09             	cmp    $0x9,%edx
  800788:	76 eb                	jbe    800775 <vprintfmt+0xb3>
  80078a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80078d:	eb 2d                	jmp    8007bc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a0:	eb 1a                	jmp    8007bc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007a5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007a9:	79 91                	jns    80073c <vprintfmt+0x7a>
  8007ab:	e9 73 ff ff ff       	jmp    800723 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007b3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007ba:	eb 80                	jmp    80073c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007bc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007c0:	0f 89 76 ff ff ff    	jns    80073c <vprintfmt+0x7a>
  8007c6:	e9 64 ff ff ff       	jmp    80072f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007cb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007d1:	e9 66 ff ff ff       	jmp    80073c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8d 50 04             	lea    0x4(%eax),%edx
  8007dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007eb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ee:	e9 f2 fe ff ff       	jmp    8006e5 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007f3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8007f7:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8007fa:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8007fe:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800801:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800805:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800808:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80080b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80080f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800812:	80 f9 09             	cmp    $0x9,%cl
  800815:	77 1d                	ja     800834 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800817:	0f be c0             	movsbl %al,%eax
  80081a:	6b c0 64             	imul   $0x64,%eax,%eax
  80081d:	0f be d2             	movsbl %dl,%edx
  800820:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800823:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80082a:	a3 04 20 80 00       	mov    %eax,0x802004
  80082f:	e9 b1 fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800834:	c7 44 24 04 f5 13 80 	movl   $0x8013f5,0x4(%esp)
  80083b:	00 
  80083c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 14 05 00 00       	call   800d5b <strcmp>
  800847:	85 c0                	test   %eax,%eax
  800849:	75 0f                	jne    80085a <vprintfmt+0x198>
  80084b:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  800852:	00 00 00 
  800855:	e9 8b fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80085a:	c7 44 24 04 f9 13 80 	movl   $0x8013f9,0x4(%esp)
  800861:	00 
  800862:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800865:	89 14 24             	mov    %edx,(%esp)
  800868:	e8 ee 04 00 00       	call   800d5b <strcmp>
  80086d:	85 c0                	test   %eax,%eax
  80086f:	75 0f                	jne    800880 <vprintfmt+0x1be>
  800871:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800878:	00 00 00 
  80087b:	e9 65 fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800880:	c7 44 24 04 fd 13 80 	movl   $0x8013fd,0x4(%esp)
  800887:	00 
  800888:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80088b:	89 0c 24             	mov    %ecx,(%esp)
  80088e:	e8 c8 04 00 00       	call   800d5b <strcmp>
  800893:	85 c0                	test   %eax,%eax
  800895:	75 0f                	jne    8008a6 <vprintfmt+0x1e4>
  800897:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  80089e:	00 00 00 
  8008a1:	e9 3f fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008a6:	c7 44 24 04 01 14 80 	movl   $0x801401,0x4(%esp)
  8008ad:	00 
  8008ae:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008b1:	89 3c 24             	mov    %edi,(%esp)
  8008b4:	e8 a2 04 00 00       	call   800d5b <strcmp>
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	75 0f                	jne    8008cc <vprintfmt+0x20a>
  8008bd:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008c4:	00 00 00 
  8008c7:	e9 19 fe ff ff       	jmp    8006e5 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008cc:	c7 44 24 04 05 14 80 	movl   $0x801405,0x4(%esp)
  8008d3:	00 
  8008d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008d7:	89 04 24             	mov    %eax,(%esp)
  8008da:	e8 7c 04 00 00       	call   800d5b <strcmp>
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	75 0f                	jne    8008f2 <vprintfmt+0x230>
  8008e3:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008ea:	00 00 00 
  8008ed:	e9 f3 fd ff ff       	jmp    8006e5 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008f2:	c7 44 24 04 09 14 80 	movl   $0x801409,0x4(%esp)
  8008f9:	00 
  8008fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008fd:	89 14 24             	mov    %edx,(%esp)
  800900:	e8 56 04 00 00       	call   800d5b <strcmp>
  800905:	83 f8 01             	cmp    $0x1,%eax
  800908:	19 c0                	sbb    %eax,%eax
  80090a:	f7 d0                	not    %eax
  80090c:	83 c0 08             	add    $0x8,%eax
  80090f:	a3 04 20 80 00       	mov    %eax,0x802004
  800914:	e9 cc fd ff ff       	jmp    8006e5 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8d 50 04             	lea    0x4(%eax),%edx
  80091f:	89 55 14             	mov    %edx,0x14(%ebp)
  800922:	8b 00                	mov    (%eax),%eax
  800924:	89 c2                	mov    %eax,%edx
  800926:	c1 fa 1f             	sar    $0x1f,%edx
  800929:	31 d0                	xor    %edx,%eax
  80092b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092d:	83 f8 08             	cmp    $0x8,%eax
  800930:	7f 0b                	jg     80093d <vprintfmt+0x27b>
  800932:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800939:	85 d2                	test   %edx,%edx
  80093b:	75 23                	jne    800960 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80093d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800941:	c7 44 24 08 0d 14 80 	movl   $0x80140d,0x8(%esp)
  800948:	00 
  800949:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	89 3c 24             	mov    %edi,(%esp)
  800953:	e8 42 fd ff ff       	call   80069a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800958:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80095b:	e9 85 fd ff ff       	jmp    8006e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800960:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800964:	c7 44 24 08 16 14 80 	movl   $0x801416,0x8(%esp)
  80096b:	00 
  80096c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800970:	8b 7d 08             	mov    0x8(%ebp),%edi
  800973:	89 3c 24             	mov    %edi,(%esp)
  800976:	e8 1f fd ff ff       	call   80069a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80097e:	e9 62 fd ff ff       	jmp    8006e5 <vprintfmt+0x23>
  800983:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800986:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800989:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80098c:	8b 45 14             	mov    0x14(%ebp),%eax
  80098f:	8d 50 04             	lea    0x4(%eax),%edx
  800992:	89 55 14             	mov    %edx,0x14(%ebp)
  800995:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800997:	85 f6                	test   %esi,%esi
  800999:	b8 ee 13 80 00       	mov    $0x8013ee,%eax
  80099e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009a1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009a5:	7e 06                	jle    8009ad <vprintfmt+0x2eb>
  8009a7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009ab:	75 13                	jne    8009c0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ad:	0f be 06             	movsbl (%esi),%eax
  8009b0:	83 c6 01             	add    $0x1,%esi
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	0f 85 94 00 00 00    	jne    800a4f <vprintfmt+0x38d>
  8009bb:	e9 81 00 00 00       	jmp    800a41 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009c4:	89 34 24             	mov    %esi,(%esp)
  8009c7:	e8 9f 02 00 00       	call   800c6b <strnlen>
  8009cc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009cf:	29 c2                	sub    %eax,%edx
  8009d1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009d4:	85 d2                	test   %edx,%edx
  8009d6:	7e d5                	jle    8009ad <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009d8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009dc:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009df:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009e2:	89 d6                	mov    %edx,%esi
  8009e4:	89 cf                	mov    %ecx,%edi
  8009e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ea:	89 3c 24             	mov    %edi,(%esp)
  8009ed:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f0:	83 ee 01             	sub    $0x1,%esi
  8009f3:	75 f1                	jne    8009e6 <vprintfmt+0x324>
  8009f5:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8009f8:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8009fb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8009fe:	eb ad                	jmp    8009ad <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a00:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a04:	74 1b                	je     800a21 <vprintfmt+0x35f>
  800a06:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a09:	83 fa 5e             	cmp    $0x5e,%edx
  800a0c:	76 13                	jbe    800a21 <vprintfmt+0x35f>
					putch('?', putdat);
  800a0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a15:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a1c:	ff 55 08             	call   *0x8(%ebp)
  800a1f:	eb 0d                	jmp    800a2e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a21:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a24:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2e:	83 eb 01             	sub    $0x1,%ebx
  800a31:	0f be 06             	movsbl (%esi),%eax
  800a34:	83 c6 01             	add    $0x1,%esi
  800a37:	85 c0                	test   %eax,%eax
  800a39:	75 1a                	jne    800a55 <vprintfmt+0x393>
  800a3b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a3e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a41:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a44:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a48:	7f 1c                	jg     800a66 <vprintfmt+0x3a4>
  800a4a:	e9 96 fc ff ff       	jmp    8006e5 <vprintfmt+0x23>
  800a4f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a52:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a55:	85 ff                	test   %edi,%edi
  800a57:	78 a7                	js     800a00 <vprintfmt+0x33e>
  800a59:	83 ef 01             	sub    $0x1,%edi
  800a5c:	79 a2                	jns    800a00 <vprintfmt+0x33e>
  800a5e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a61:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a64:	eb db                	jmp    800a41 <vprintfmt+0x37f>
  800a66:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a69:	89 de                	mov    %ebx,%esi
  800a6b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a72:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a79:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a7b:	83 eb 01             	sub    $0x1,%ebx
  800a7e:	75 ee                	jne    800a6e <vprintfmt+0x3ac>
  800a80:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a82:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a85:	e9 5b fc ff ff       	jmp    8006e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8a:	83 f9 01             	cmp    $0x1,%ecx
  800a8d:	7e 10                	jle    800a9f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a92:	8d 50 08             	lea    0x8(%eax),%edx
  800a95:	89 55 14             	mov    %edx,0x14(%ebp)
  800a98:	8b 30                	mov    (%eax),%esi
  800a9a:	8b 78 04             	mov    0x4(%eax),%edi
  800a9d:	eb 26                	jmp    800ac5 <vprintfmt+0x403>
	else if (lflag)
  800a9f:	85 c9                	test   %ecx,%ecx
  800aa1:	74 12                	je     800ab5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	8d 50 04             	lea    0x4(%eax),%edx
  800aa9:	89 55 14             	mov    %edx,0x14(%ebp)
  800aac:	8b 30                	mov    (%eax),%esi
  800aae:	89 f7                	mov    %esi,%edi
  800ab0:	c1 ff 1f             	sar    $0x1f,%edi
  800ab3:	eb 10                	jmp    800ac5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800ab5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab8:	8d 50 04             	lea    0x4(%eax),%edx
  800abb:	89 55 14             	mov    %edx,0x14(%ebp)
  800abe:	8b 30                	mov    (%eax),%esi
  800ac0:	89 f7                	mov    %esi,%edi
  800ac2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	78 0e                	js     800ad7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ac9:	89 f0                	mov    %esi,%eax
  800acb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800acd:	be 0a 00 00 00       	mov    $0xa,%esi
  800ad2:	e9 84 00 00 00       	jmp    800b5b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ad7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800adb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ae2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ae5:	89 f0                	mov    %esi,%eax
  800ae7:	89 fa                	mov    %edi,%edx
  800ae9:	f7 d8                	neg    %eax
  800aeb:	83 d2 00             	adc    $0x0,%edx
  800aee:	f7 da                	neg    %edx
			}
			base = 10;
  800af0:	be 0a 00 00 00       	mov    $0xa,%esi
  800af5:	eb 64                	jmp    800b5b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800af7:	89 ca                	mov    %ecx,%edx
  800af9:	8d 45 14             	lea    0x14(%ebp),%eax
  800afc:	e8 42 fb ff ff       	call   800643 <getuint>
			base = 10;
  800b01:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b06:	eb 53                	jmp    800b5b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b08:	89 ca                	mov    %ecx,%edx
  800b0a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0d:	e8 31 fb ff ff       	call   800643 <getuint>
    			base = 8;
  800b12:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b17:	eb 42                	jmp    800b5b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b24:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b2b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b32:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b35:	8b 45 14             	mov    0x14(%ebp),%eax
  800b38:	8d 50 04             	lea    0x4(%eax),%edx
  800b3b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3e:	8b 00                	mov    (%eax),%eax
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b45:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b4a:	eb 0f                	jmp    800b5b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4c:	89 ca                	mov    %ecx,%edx
  800b4e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b51:	e8 ed fa ff ff       	call   800643 <getuint>
			base = 16;
  800b56:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b5f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b63:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b66:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b6a:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b6e:	89 04 24             	mov    %eax,(%esp)
  800b71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b75:	89 da                	mov    %ebx,%edx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	e8 e9 f9 ff ff       	call   800568 <printnum>
			break;
  800b7f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b82:	e9 5e fb ff ff       	jmp    8006e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8b:	89 14 24             	mov    %edx,(%esp)
  800b8e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b91:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b94:	e9 4c fb ff ff       	jmp    8006e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ba4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ba7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bab:	0f 84 34 fb ff ff    	je     8006e5 <vprintfmt+0x23>
  800bb1:	83 ee 01             	sub    $0x1,%esi
  800bb4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bb8:	75 f7                	jne    800bb1 <vprintfmt+0x4ef>
  800bba:	e9 26 fb ff ff       	jmp    8006e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bbf:	83 c4 5c             	add    $0x5c,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 28             	sub    $0x28,%esp
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bd6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bdd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	74 30                	je     800c18 <vsnprintf+0x51>
  800be8:	85 d2                	test   %edx,%edx
  800bea:	7e 2c                	jle    800c18 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bec:	8b 45 14             	mov    0x14(%ebp),%eax
  800bef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c01:	c7 04 24 7d 06 80 00 	movl   $0x80067d,(%esp)
  800c08:	e8 b5 fa ff ff       	call   8006c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c10:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c16:	eb 05                	jmp    800c1d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c25:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	89 04 24             	mov    %eax,(%esp)
  800c40:	e8 82 ff ff ff       	call   800bc7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    
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

00801080 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801086:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80108d:	75 1c                	jne    8010ab <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  80108f:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  801096:	00 
  801097:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80109e:	00 
  80109f:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8010a6:	e8 a5 f3 ff ff       	call   800450 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    
	...

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
