
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 40 	movl   $0x801340,0x802000
  800041:	13 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 53 01 00 00       	call   80019c <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 09 01 00 00       	call   80016c <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	c1 e0 07             	shl    $0x7,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800084:	89 34 24             	mov    %esi,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800094:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800097:	89 ec                	mov    %ebp,%esp
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 61 00 00 00       	call   80010f <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000db:	89 ec                	mov    %ebp,%esp
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800105:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800108:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 38             	sub    $0x38,%esp
  800115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	89 cb                	mov    %ecx,%ebx
  80012d:	89 cf                	mov    %ecx,%edi
  80012f:	89 ce                	mov    %ecx,%esi
  800131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800133:	85 c0                	test   %eax,%eax
  800135:	7e 28                	jle    80015f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800142:	00 
  800143:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  80014a:	00 
  80014b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800152:	00 
  800153:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  80015a:	e8 09 03 00 00       	call   800468 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800162:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800165:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800168:	89 ec                	mov    %ebp,%esp
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800175:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800178:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800192:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800198:	89 ec                	mov    %ebp,%esp
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_yield>:

void
sys_yield(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b5:	89 d1                	mov    %edx,%ecx
  8001b7:	89 d3                	mov    %edx,%ebx
  8001b9:	89 d7                	mov    %edx,%edi
  8001bb:	89 d6                	mov    %edx,%esi
  8001bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c8:	89 ec                	mov    %ebp,%esp
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 38             	sub    $0x38,%esp
  8001d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	be 00 00 00 00       	mov    $0x0,%esi
  8001e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	89 f7                	mov    %esi,%edi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 28                	jle    80021e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  800219:	e8 4a 02 00 00       	call   800468 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800221:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800224:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800227:	89 ec                	mov    %ebp,%esp
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 38             	sub    $0x38,%esp
  800231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800237:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	b8 05 00 00 00       	mov    $0x5,%eax
  80023f:	8b 75 18             	mov    0x18(%ebp),%esi
  800242:	8b 7d 14             	mov    0x14(%ebp),%edi
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 28                	jle    80027c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	89 44 24 10          	mov    %eax,0x10(%esp)
  800258:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80025f:	00 
  800260:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  800267:	00 
  800268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026f:	00 
  800270:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  800277:	e8 ec 01 00 00       	call   800468 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80027c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80027f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 38             	sub    $0x38,%esp
  80028f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800292:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 28                	jle    8002da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002bd:	00 
  8002be:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002cd:	00 
  8002ce:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  8002d5:	e8 8e 01 00 00       	call   800468 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e3:	89 ec                	mov    %ebp,%esp
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 38             	sub    $0x38,%esp
  8002ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fb:	b8 08 00 00 00       	mov    $0x8,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 df                	mov    %ebx,%edi
  800308:	89 de                	mov    %ebx,%esi
  80030a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030c:	85 c0                	test   %eax,%eax
  80030e:	7e 28                	jle    800338 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800310:	89 44 24 10          	mov    %eax,0x10(%esp)
  800314:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031b:	00 
  80031c:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  800323:	00 
  800324:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032b:	00 
  80032c:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  800333:	e8 30 01 00 00       	call   800468 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800338:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80033e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800341:	89 ec                	mov    %ebp,%esp
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 38             	sub    $0x38,%esp
  80034b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80034e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800351:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800354:	bb 00 00 00 00       	mov    $0x0,%ebx
  800359:	b8 09 00 00 00       	mov    $0x9,%eax
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 df                	mov    %ebx,%edi
  800366:	89 de                	mov    %ebx,%esi
  800368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  800391:	e8 d2 00 00 00       	call   800468 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800396:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800399:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80039c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039f:	89 ec                	mov    %ebp,%esp
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 0c             	sub    $0xc,%esp
  8003a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b2:	be 00 00 00 00       	mov    $0x0,%esi
  8003b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d3:	89 ec                	mov    %ebp,%esp
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 38             	sub    $0x38,%esp
  8003dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	89 cb                	mov    %ecx,%ebx
  8003f5:	89 cf                	mov    %ecx,%edi
  8003f7:	89 ce                	mov    %ecx,%esi
  8003f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	7e 28                	jle    800427 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800403:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80040a:	00 
  80040b:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  800412:	00 
  800413:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041a:	00 
  80041b:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  800422:	e8 41 00 00 00       	call   800468 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800427:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800430:	89 ec                	mov    %ebp,%esp
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 0c             	sub    $0xc,%esp
  80043a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80043d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800440:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800443:	b9 00 00 00 00       	mov    $0x0,%ecx
  800448:	b8 0d 00 00 00       	mov    $0xd,%eax
  80044d:	8b 55 08             	mov    0x8(%ebp),%edx
  800450:	89 cb                	mov    %ecx,%ebx
  800452:	89 cf                	mov    %ecx,%edi
  800454:	89 ce                	mov    %ecx,%esi
  800456:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  800458:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80045b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80045e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800461:	89 ec                	mov    %ebp,%esp
  800463:	5d                   	pop    %ebp
  800464:	c3                   	ret    
  800465:	00 00                	add    %al,(%eax)
	...

00800468 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	56                   	push   %esi
  80046c:	53                   	push   %ebx
  80046d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800470:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800473:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800479:	e8 ee fc ff ff       	call   80016c <sys_getenvid>
  80047e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800481:	89 54 24 10          	mov    %edx,0x10(%esp)
  800485:	8b 55 08             	mov    0x8(%ebp),%edx
  800488:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800490:	89 44 24 04          	mov    %eax,0x4(%esp)
  800494:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  80049b:	e8 c3 00 00 00       	call   800563 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	e8 53 00 00 00       	call   800502 <vcprintf>
	cprintf("\n");
  8004af:	c7 04 24 a0 13 80 00 	movl   $0x8013a0,(%esp)
  8004b6:	e8 a8 00 00 00       	call   800563 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004bb:	cc                   	int3   
  8004bc:	eb fd                	jmp    8004bb <_panic+0x53>
	...

008004c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 14             	sub    $0x14,%esp
  8004c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ca:	8b 03                	mov    (%ebx),%eax
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004d3:	83 c0 01             	add    $0x1,%eax
  8004d6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004dd:	75 19                	jne    8004f8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004e6:	00 
  8004e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	e8 be fb ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8004f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004fc:	83 c4 14             	add    $0x14,%esp
  8004ff:	5b                   	pop    %ebx
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80050b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800512:	00 00 00 
	b.cnt = 0;
  800515:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80051c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80051f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800522:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800533:	89 44 24 04          	mov    %eax,0x4(%esp)
  800537:	c7 04 24 c0 04 80 00 	movl   $0x8004c0,(%esp)
  80053e:	e8 97 01 00 00       	call   8006da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800543:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	e8 55 fb ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  80055b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800569:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80056c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800570:	8b 45 08             	mov    0x8(%ebp),%eax
  800573:	89 04 24             	mov    %eax,(%esp)
  800576:	e8 87 ff ff ff       	call   800502 <vcprintf>
	va_end(ap);

	return cnt;
}
  80057b:	c9                   	leave  
  80057c:	c3                   	ret    
  80057d:	00 00                	add    %al,(%eax)
	...

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 3c             	sub    $0x3c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d7                	mov    %edx,%edi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80059d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005a8:	72 11                	jb     8005bb <printnum+0x3b>
  8005aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005b0:	76 09                	jbe    8005bb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005b2:	83 eb 01             	sub    $0x1,%ebx
  8005b5:	85 db                	test   %ebx,%ebx
  8005b7:	7f 51                	jg     80060a <printnum+0x8a>
  8005b9:	eb 5e                	jmp    800619 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005bf:	83 eb 01             	sub    $0x1,%ebx
  8005c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005cd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005d1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005dc:	00 
  8005dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ea:	e8 a1 0a 00 00       	call   801090 <__udivdi3>
  8005ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005fe:	89 fa                	mov    %edi,%edx
  800600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800603:	e8 78 ff ff ff       	call   800580 <printnum>
  800608:	eb 0f                	jmp    800619 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80060a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060e:	89 34 24             	mov    %esi,(%esp)
  800611:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800614:	83 eb 01             	sub    $0x1,%ebx
  800617:	75 f1                	jne    80060a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800621:	8b 45 10             	mov    0x10(%ebp),%eax
  800624:	89 44 24 08          	mov    %eax,0x8(%esp)
  800628:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80062f:	00 
  800630:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800633:	89 04 24             	mov    %eax,(%esp)
  800636:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063d:	e8 7e 0b 00 00       	call   8011c0 <__umoddi3>
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	0f be 80 a2 13 80 00 	movsbl 0x8013a2(%eax),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800653:	83 c4 3c             	add    $0x3c,%esp
  800656:	5b                   	pop    %ebx
  800657:	5e                   	pop    %esi
  800658:	5f                   	pop    %edi
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80065e:	83 fa 01             	cmp    $0x1,%edx
  800661:	7e 0e                	jle    800671 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800663:	8b 10                	mov    (%eax),%edx
  800665:	8d 4a 08             	lea    0x8(%edx),%ecx
  800668:	89 08                	mov    %ecx,(%eax)
  80066a:	8b 02                	mov    (%edx),%eax
  80066c:	8b 52 04             	mov    0x4(%edx),%edx
  80066f:	eb 22                	jmp    800693 <getuint+0x38>
	else if (lflag)
  800671:	85 d2                	test   %edx,%edx
  800673:	74 10                	je     800685 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800675:	8b 10                	mov    (%eax),%edx
  800677:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067a:	89 08                	mov    %ecx,(%eax)
  80067c:	8b 02                	mov    (%edx),%eax
  80067e:	ba 00 00 00 00       	mov    $0x0,%edx
  800683:	eb 0e                	jmp    800693 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800685:	8b 10                	mov    (%eax),%edx
  800687:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068a:	89 08                	mov    %ecx,(%eax)
  80068c:	8b 02                	mov    (%edx),%eax
  80068e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80069b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8006a4:	73 0a                	jae    8006b0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a9:	88 0a                	mov    %cl,(%edx)
  8006ab:	83 c2 01             	add    $0x1,%edx
  8006ae:	89 10                	mov    %edx,(%eax)
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d0:	89 04 24             	mov    %eax,(%esp)
  8006d3:	e8 02 00 00 00       	call   8006da <vprintfmt>
	va_end(ap);
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	57                   	push   %edi
  8006de:	56                   	push   %esi
  8006df:	53                   	push   %ebx
  8006e0:	83 ec 5c             	sub    $0x5c,%esp
  8006e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006e9:	eb 12                	jmp    8006fd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	0f 84 e4 04 00 00    	je     800bd7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f7:	89 04 24             	mov    %eax,(%esp)
  8006fa:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fd:	0f b6 06             	movzbl (%esi),%eax
  800700:	83 c6 01             	add    $0x1,%esi
  800703:	83 f8 25             	cmp    $0x25,%eax
  800706:	75 e3                	jne    8006eb <vprintfmt+0x11>
  800708:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  80070c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800713:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800718:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800727:	eb 2b                	jmp    800754 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80072c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800730:	eb 22                	jmp    800754 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800735:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800739:	eb 19                	jmp    800754 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80073e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800747:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80074a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80074d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800754:	0f b6 06             	movzbl (%esi),%eax
  800757:	0f b6 d0             	movzbl %al,%edx
  80075a:	8d 7e 01             	lea    0x1(%esi),%edi
  80075d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800760:	83 e8 23             	sub    $0x23,%eax
  800763:	3c 55                	cmp    $0x55,%al
  800765:	0f 87 46 04 00 00    	ja     800bb1 <vprintfmt+0x4d7>
  80076b:	0f b6 c0             	movzbl %al,%eax
  80076e:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800775:	83 ea 30             	sub    $0x30,%edx
  800778:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80077b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80077f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800785:	83 fa 09             	cmp    $0x9,%edx
  800788:	77 4a                	ja     8007d4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800790:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800793:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800797:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80079a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80079d:	83 fa 09             	cmp    $0x9,%edx
  8007a0:	76 eb                	jbe    80078d <vprintfmt+0xb3>
  8007a2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8007a5:	eb 2d                	jmp    8007d4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 50 04             	lea    0x4(%eax),%edx
  8007ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b0:	8b 00                	mov    (%eax),%eax
  8007b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007b8:	eb 1a                	jmp    8007d4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007bd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007c1:	79 91                	jns    800754 <vprintfmt+0x7a>
  8007c3:	e9 73 ff ff ff       	jmp    80073b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007cb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007d2:	eb 80                	jmp    800754 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007d4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007d8:	0f 89 76 ff ff ff    	jns    800754 <vprintfmt+0x7a>
  8007de:	e9 64 ff ff ff       	jmp    800747 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007e9:	e9 66 ff ff ff       	jmp    800754 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 50 04             	lea    0x4(%eax),%edx
  8007f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800803:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800806:	e9 f2 fe ff ff       	jmp    8006fd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80080b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80080f:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800812:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800816:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800819:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  80081d:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800820:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800823:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800827:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80082a:	80 f9 09             	cmp    $0x9,%cl
  80082d:	77 1d                	ja     80084c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80082f:	0f be c0             	movsbl %al,%eax
  800832:	6b c0 64             	imul   $0x64,%eax,%eax
  800835:	0f be d2             	movsbl %dl,%edx
  800838:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80083b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800842:	a3 04 20 80 00       	mov    %eax,0x802004
  800847:	e9 b1 fe ff ff       	jmp    8006fd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80084c:	c7 44 24 04 ba 13 80 	movl   $0x8013ba,0x4(%esp)
  800853:	00 
  800854:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 0c 05 00 00       	call   800d6b <strcmp>
  80085f:	85 c0                	test   %eax,%eax
  800861:	75 0f                	jne    800872 <vprintfmt+0x198>
  800863:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80086a:	00 00 00 
  80086d:	e9 8b fe ff ff       	jmp    8006fd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800872:	c7 44 24 04 be 13 80 	movl   $0x8013be,0x4(%esp)
  800879:	00 
  80087a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80087d:	89 14 24             	mov    %edx,(%esp)
  800880:	e8 e6 04 00 00       	call   800d6b <strcmp>
  800885:	85 c0                	test   %eax,%eax
  800887:	75 0f                	jne    800898 <vprintfmt+0x1be>
  800889:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800890:	00 00 00 
  800893:	e9 65 fe ff ff       	jmp    8006fd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800898:	c7 44 24 04 c2 13 80 	movl   $0x8013c2,0x4(%esp)
  80089f:	00 
  8008a0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8008a3:	89 0c 24             	mov    %ecx,(%esp)
  8008a6:	e8 c0 04 00 00       	call   800d6b <strcmp>
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	75 0f                	jne    8008be <vprintfmt+0x1e4>
  8008af:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8008b6:	00 00 00 
  8008b9:	e9 3f fe ff ff       	jmp    8006fd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008be:	c7 44 24 04 c6 13 80 	movl   $0x8013c6,0x4(%esp)
  8008c5:	00 
  8008c6:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008c9:	89 3c 24             	mov    %edi,(%esp)
  8008cc:	e8 9a 04 00 00       	call   800d6b <strcmp>
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	75 0f                	jne    8008e4 <vprintfmt+0x20a>
  8008d5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008dc:	00 00 00 
  8008df:	e9 19 fe ff ff       	jmp    8006fd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008e4:	c7 44 24 04 ca 13 80 	movl   $0x8013ca,0x4(%esp)
  8008eb:	00 
  8008ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	e8 74 04 00 00       	call   800d6b <strcmp>
  8008f7:	85 c0                	test   %eax,%eax
  8008f9:	75 0f                	jne    80090a <vprintfmt+0x230>
  8008fb:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800902:	00 00 00 
  800905:	e9 f3 fd ff ff       	jmp    8006fd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  80090a:	c7 44 24 04 ce 13 80 	movl   $0x8013ce,0x4(%esp)
  800911:	00 
  800912:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800915:	89 14 24             	mov    %edx,(%esp)
  800918:	e8 4e 04 00 00       	call   800d6b <strcmp>
  80091d:	83 f8 01             	cmp    $0x1,%eax
  800920:	19 c0                	sbb    %eax,%eax
  800922:	f7 d0                	not    %eax
  800924:	83 c0 08             	add    $0x8,%eax
  800927:	a3 04 20 80 00       	mov    %eax,0x802004
  80092c:	e9 cc fd ff ff       	jmp    8006fd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800931:	8b 45 14             	mov    0x14(%ebp),%eax
  800934:	8d 50 04             	lea    0x4(%eax),%edx
  800937:	89 55 14             	mov    %edx,0x14(%ebp)
  80093a:	8b 00                	mov    (%eax),%eax
  80093c:	89 c2                	mov    %eax,%edx
  80093e:	c1 fa 1f             	sar    $0x1f,%edx
  800941:	31 d0                	xor    %edx,%eax
  800943:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800945:	83 f8 08             	cmp    $0x8,%eax
  800948:	7f 0b                	jg     800955 <vprintfmt+0x27b>
  80094a:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800951:	85 d2                	test   %edx,%edx
  800953:	75 23                	jne    800978 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800955:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800959:	c7 44 24 08 d2 13 80 	movl   $0x8013d2,0x8(%esp)
  800960:	00 
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	8b 7d 08             	mov    0x8(%ebp),%edi
  800968:	89 3c 24             	mov    %edi,(%esp)
  80096b:	e8 42 fd ff ff       	call   8006b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800973:	e9 85 fd ff ff       	jmp    8006fd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800978:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80097c:	c7 44 24 08 db 13 80 	movl   $0x8013db,0x8(%esp)
  800983:	00 
  800984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800988:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098b:	89 3c 24             	mov    %edi,(%esp)
  80098e:	e8 1f fd ff ff       	call   8006b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800996:	e9 62 fd ff ff       	jmp    8006fd <vprintfmt+0x23>
  80099b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80099e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8d 50 04             	lea    0x4(%eax),%edx
  8009aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009af:	85 f6                	test   %esi,%esi
  8009b1:	b8 b3 13 80 00       	mov    $0x8013b3,%eax
  8009b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009b9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009bd:	7e 06                	jle    8009c5 <vprintfmt+0x2eb>
  8009bf:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009c3:	75 13                	jne    8009d8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c5:	0f be 06             	movsbl (%esi),%eax
  8009c8:	83 c6 01             	add    $0x1,%esi
  8009cb:	85 c0                	test   %eax,%eax
  8009cd:	0f 85 94 00 00 00    	jne    800a67 <vprintfmt+0x38d>
  8009d3:	e9 81 00 00 00       	jmp    800a59 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009dc:	89 34 24             	mov    %esi,(%esp)
  8009df:	e8 97 02 00 00       	call   800c7b <strnlen>
  8009e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009e7:	29 c2                	sub    %eax,%edx
  8009e9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009ec:	85 d2                	test   %edx,%edx
  8009ee:	7e d5                	jle    8009c5 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009f0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009f4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009f7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009fa:	89 d6                	mov    %edx,%esi
  8009fc:	89 cf                	mov    %ecx,%edi
  8009fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a02:	89 3c 24             	mov    %edi,(%esp)
  800a05:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a08:	83 ee 01             	sub    $0x1,%esi
  800a0b:	75 f1                	jne    8009fe <vprintfmt+0x324>
  800a0d:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a10:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a13:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a16:	eb ad                	jmp    8009c5 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a18:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a1c:	74 1b                	je     800a39 <vprintfmt+0x35f>
  800a1e:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a21:	83 fa 5e             	cmp    $0x5e,%edx
  800a24:	76 13                	jbe    800a39 <vprintfmt+0x35f>
					putch('?', putdat);
  800a26:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a34:	ff 55 08             	call   *0x8(%ebp)
  800a37:	eb 0d                	jmp    800a46 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a39:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a40:	89 04 24             	mov    %eax,(%esp)
  800a43:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a46:	83 eb 01             	sub    $0x1,%ebx
  800a49:	0f be 06             	movsbl (%esi),%eax
  800a4c:	83 c6 01             	add    $0x1,%esi
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	75 1a                	jne    800a6d <vprintfmt+0x393>
  800a53:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a56:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a59:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a5c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a60:	7f 1c                	jg     800a7e <vprintfmt+0x3a4>
  800a62:	e9 96 fc ff ff       	jmp    8006fd <vprintfmt+0x23>
  800a67:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a6a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6d:	85 ff                	test   %edi,%edi
  800a6f:	78 a7                	js     800a18 <vprintfmt+0x33e>
  800a71:	83 ef 01             	sub    $0x1,%edi
  800a74:	79 a2                	jns    800a18 <vprintfmt+0x33e>
  800a76:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a79:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a7c:	eb db                	jmp    800a59 <vprintfmt+0x37f>
  800a7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a81:	89 de                	mov    %ebx,%esi
  800a83:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a8a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a91:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a93:	83 eb 01             	sub    $0x1,%ebx
  800a96:	75 ee                	jne    800a86 <vprintfmt+0x3ac>
  800a98:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a9d:	e9 5b fc ff ff       	jmp    8006fd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aa2:	83 f9 01             	cmp    $0x1,%ecx
  800aa5:	7e 10                	jle    800ab7 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaa:	8d 50 08             	lea    0x8(%eax),%edx
  800aad:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab0:	8b 30                	mov    (%eax),%esi
  800ab2:	8b 78 04             	mov    0x4(%eax),%edi
  800ab5:	eb 26                	jmp    800add <vprintfmt+0x403>
	else if (lflag)
  800ab7:	85 c9                	test   %ecx,%ecx
  800ab9:	74 12                	je     800acd <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800abb:	8b 45 14             	mov    0x14(%ebp),%eax
  800abe:	8d 50 04             	lea    0x4(%eax),%edx
  800ac1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac4:	8b 30                	mov    (%eax),%esi
  800ac6:	89 f7                	mov    %esi,%edi
  800ac8:	c1 ff 1f             	sar    $0x1f,%edi
  800acb:	eb 10                	jmp    800add <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800acd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad0:	8d 50 04             	lea    0x4(%eax),%edx
  800ad3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad6:	8b 30                	mov    (%eax),%esi
  800ad8:	89 f7                	mov    %esi,%edi
  800ada:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800add:	85 ff                	test   %edi,%edi
  800adf:	78 0e                	js     800aef <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ae1:	89 f0                	mov    %esi,%eax
  800ae3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ae5:	be 0a 00 00 00       	mov    $0xa,%esi
  800aea:	e9 84 00 00 00       	jmp    800b73 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800aef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800afa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	89 fa                	mov    %edi,%edx
  800b01:	f7 d8                	neg    %eax
  800b03:	83 d2 00             	adc    $0x0,%edx
  800b06:	f7 da                	neg    %edx
			}
			base = 10;
  800b08:	be 0a 00 00 00       	mov    $0xa,%esi
  800b0d:	eb 64                	jmp    800b73 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b0f:	89 ca                	mov    %ecx,%edx
  800b11:	8d 45 14             	lea    0x14(%ebp),%eax
  800b14:	e8 42 fb ff ff       	call   80065b <getuint>
			base = 10;
  800b19:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b1e:	eb 53                	jmp    800b73 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b20:	89 ca                	mov    %ecx,%edx
  800b22:	8d 45 14             	lea    0x14(%ebp),%eax
  800b25:	e8 31 fb ff ff       	call   80065b <getuint>
    			base = 8;
  800b2a:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b2f:	eb 42                	jmp    800b73 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b35:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b3c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b43:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b4a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b50:	8d 50 04             	lea    0x4(%eax),%edx
  800b53:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b56:	8b 00                	mov    (%eax),%eax
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b5d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b62:	eb 0f                	jmp    800b73 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b64:	89 ca                	mov    %ecx,%edx
  800b66:	8d 45 14             	lea    0x14(%ebp),%eax
  800b69:	e8 ed fa ff ff       	call   80065b <getuint>
			base = 16;
  800b6e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b73:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b77:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b7b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b7e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b82:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b86:	89 04 24             	mov    %eax,(%esp)
  800b89:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b8d:	89 da                	mov    %ebx,%edx
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	e8 e9 f9 ff ff       	call   800580 <printnum>
			break;
  800b97:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b9a:	e9 5e fb ff ff       	jmp    8006fd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba3:	89 14 24             	mov    %edx,(%esp)
  800ba6:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ba9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bac:	e9 4c fb ff ff       	jmp    8006fd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bb5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bbc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bbf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bc3:	0f 84 34 fb ff ff    	je     8006fd <vprintfmt+0x23>
  800bc9:	83 ee 01             	sub    $0x1,%esi
  800bcc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bd0:	75 f7                	jne    800bc9 <vprintfmt+0x4ef>
  800bd2:	e9 26 fb ff ff       	jmp    8006fd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bd7:	83 c4 5c             	add    $0x5c,%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 28             	sub    $0x28,%esp
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bf2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	74 30                	je     800c30 <vsnprintf+0x51>
  800c00:	85 d2                	test   %edx,%edx
  800c02:	7e 2c                	jle    800c30 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c12:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	c7 04 24 95 06 80 00 	movl   $0x800695,(%esp)
  800c20:	e8 b5 fa ff ff       	call   8006da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c25:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c28:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2e:	eb 05                	jmp    800c35 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c3d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c44:	8b 45 10             	mov    0x10(%ebp),%eax
  800c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 82 ff ff ff       	call   800bdf <vsnprintf>
	va_end(ap);

	return rc;
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    
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
