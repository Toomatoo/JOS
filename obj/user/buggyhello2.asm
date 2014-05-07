
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 30 80 00       	mov    0x803000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 71 00 00 00       	call   8000c0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800066:	e8 11 01 00 00       	call   80017c <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	c1 e0 07             	shl    $0x7,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 4f 06 00 00       	call   8006fe <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 64 00 00 00       	call   80011f <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

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
  800153:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  80016a:	e8 61 11 00 00       	call   8012d0 <_panic>

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
  8001c0:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800212:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  800229:	e8 a2 10 00 00       	call   8012d0 <_panic>

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
  800270:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  800287:	e8 44 10 00 00       	call   8012d0 <_panic>

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
  8002ce:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  8002e5:	e8 e6 0f 00 00       	call   8012d0 <_panic>

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
  80032c:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  800343:	e8 88 0f 00 00       	call   8012d0 <_panic>

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

00800355 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  80037c:	7e 28                	jle    8003a6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800382:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800389:	00 
  80038a:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  8003a1:	e8 2a 0f 00 00       	call   8012d0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003af:	89 ec                	mov    %ebp,%esp
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	83 ec 38             	sub    $0x38,%esp
  8003b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d2:	89 df                	mov    %ebx,%edi
  8003d4:	89 de                	mov    %ebx,%esi
  8003d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	7e 28                	jle    800404 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003e0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003e7:	00 
  8003e8:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  8003ef:	00 
  8003f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f7:	00 
  8003f8:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  8003ff:	e8 cc 0e 00 00       	call   8012d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800404:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800407:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80040a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80040d:	89 ec                	mov    %ebp,%esp
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 0c             	sub    $0xc,%esp
  800417:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80041a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80041d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800420:	be 00 00 00 00       	mov    $0x0,%esi
  800425:	b8 0c 00 00 00       	mov    $0xc,%eax
  80042a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80042d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800433:	8b 55 08             	mov    0x8(%ebp),%edx
  800436:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800438:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80043b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800441:	89 ec                	mov    %ebp,%esp
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 38             	sub    $0x38,%esp
  80044b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80044e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800451:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
  800459:	b8 0d 00 00 00       	mov    $0xd,%eax
  80045e:	8b 55 08             	mov    0x8(%ebp),%edx
  800461:	89 cb                	mov    %ecx,%ebx
  800463:	89 cf                	mov    %ecx,%edi
  800465:	89 ce                	mov    %ecx,%esi
  800467:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800469:	85 c0                	test   %eax,%eax
  80046b:	7e 28                	jle    800495 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80046d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800471:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800478:	00 
  800479:	c7 44 24 08 38 23 80 	movl   $0x802338,0x8(%esp)
  800480:	00 
  800481:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800488:	00 
  800489:	c7 04 24 55 23 80 00 	movl   $0x802355,(%esp)
  800490:	e8 3b 0e 00 00       	call   8012d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800495:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800498:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80049b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80049e:	89 ec                	mov    %ebp,%esp
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	83 ec 0c             	sub    $0xc,%esp
  8004a8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004ab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004ae:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8004bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004be:	89 cb                	mov    %ecx,%ebx
  8004c0:	89 cf                	mov    %ecx,%edi
  8004c2:	89 ce                	mov    %ecx,%esi
  8004c4:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8004c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004cf:	89 ec                	mov    %ebp,%esp
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    
	...

008004e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 04 24             	mov    %eax,(%esp)
  8004fc:	e8 df ff ff ff       	call   8004e0 <fd2num>
  800501:	05 20 00 0d 00       	add    $0xd0020,%eax
  800506:	c1 e0 0c             	shl    $0xc,%eax
}
  800509:	c9                   	leave  
  80050a:	c3                   	ret    

0080050b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	53                   	push   %ebx
  80050f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800512:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800517:	a8 01                	test   $0x1,%al
  800519:	74 34                	je     80054f <fd_alloc+0x44>
  80051b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800520:	a8 01                	test   $0x1,%al
  800522:	74 32                	je     800556 <fd_alloc+0x4b>
  800524:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800529:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80052b:	89 c2                	mov    %eax,%edx
  80052d:	c1 ea 16             	shr    $0x16,%edx
  800530:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800537:	f6 c2 01             	test   $0x1,%dl
  80053a:	74 1f                	je     80055b <fd_alloc+0x50>
  80053c:	89 c2                	mov    %eax,%edx
  80053e:	c1 ea 0c             	shr    $0xc,%edx
  800541:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800548:	f6 c2 01             	test   $0x1,%dl
  80054b:	75 17                	jne    800564 <fd_alloc+0x59>
  80054d:	eb 0c                	jmp    80055b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80054f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800554:	eb 05                	jmp    80055b <fd_alloc+0x50>
  800556:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80055b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80055d:	b8 00 00 00 00       	mov    $0x0,%eax
  800562:	eb 17                	jmp    80057b <fd_alloc+0x70>
  800564:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800569:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80056e:	75 b9                	jne    800529 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800570:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800576:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80057b:	5b                   	pop    %ebx
  80057c:	5d                   	pop    %ebp
  80057d:	c3                   	ret    

0080057e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800584:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800589:	83 fa 1f             	cmp    $0x1f,%edx
  80058c:	77 3f                	ja     8005cd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80058e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  800594:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800597:	89 d0                	mov    %edx,%eax
  800599:	c1 e8 16             	shr    $0x16,%eax
  80059c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8005a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8005a8:	f6 c1 01             	test   $0x1,%cl
  8005ab:	74 20                	je     8005cd <fd_lookup+0x4f>
  8005ad:	89 d0                	mov    %edx,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8005b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8005be:	f6 c1 01             	test   $0x1,%cl
  8005c1:	74 0a                	je     8005cd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8005c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	53                   	push   %ebx
  8005d3:	83 ec 14             	sub    $0x14,%esp
  8005d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8005dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8005e1:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8005e7:	75 17                	jne    800600 <dev_lookup+0x31>
  8005e9:	eb 07                	jmp    8005f2 <dev_lookup+0x23>
  8005eb:	39 0a                	cmp    %ecx,(%edx)
  8005ed:	75 11                	jne    800600 <dev_lookup+0x31>
  8005ef:	90                   	nop
  8005f0:	eb 05                	jmp    8005f7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005f2:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8005f7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8005f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fe:	eb 35                	jmp    800635 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800600:	83 c0 01             	add    $0x1,%eax
  800603:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  80060a:	85 d2                	test   %edx,%edx
  80060c:	75 dd                	jne    8005eb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80060e:	a1 04 40 80 00       	mov    0x804004,%eax
  800613:	8b 40 48             	mov    0x48(%eax),%eax
  800616:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061e:	c7 04 24 64 23 80 00 	movl   $0x802364,(%esp)
  800625:	e8 a1 0d 00 00       	call   8013cb <cprintf>
	*dev = 0;
  80062a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800630:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800635:	83 c4 14             	add    $0x14,%esp
  800638:	5b                   	pop    %ebx
  800639:	5d                   	pop    %ebp
  80063a:	c3                   	ret    

0080063b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	83 ec 38             	sub    $0x38,%esp
  800641:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800644:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800647:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80064a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800651:	89 3c 24             	mov    %edi,(%esp)
  800654:	e8 87 fe ff ff       	call   8004e0 <fd2num>
  800659:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80065c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	e8 16 ff ff ff       	call   80057e <fd_lookup>
  800668:	89 c3                	mov    %eax,%ebx
  80066a:	85 c0                	test   %eax,%eax
  80066c:	78 05                	js     800673 <fd_close+0x38>
	    || fd != fd2)
  80066e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800671:	74 0e                	je     800681 <fd_close+0x46>
		return (must_exist ? r : 0);
  800673:	89 f0                	mov    %esi,%eax
  800675:	84 c0                	test   %al,%al
  800677:	b8 00 00 00 00       	mov    $0x0,%eax
  80067c:	0f 44 d8             	cmove  %eax,%ebx
  80067f:	eb 3d                	jmp    8006be <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800681:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	8b 07                	mov    (%edi),%eax
  80068a:	89 04 24             	mov    %eax,(%esp)
  80068d:	e8 3d ff ff ff       	call   8005cf <dev_lookup>
  800692:	89 c3                	mov    %eax,%ebx
  800694:	85 c0                	test   %eax,%eax
  800696:	78 16                	js     8006ae <fd_close+0x73>
		if (dev->dev_close)
  800698:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80069e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 07                	je     8006ae <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8006a7:	89 3c 24             	mov    %edi,(%esp)
  8006aa:	ff d0                	call   *%eax
  8006ac:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8006ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006b9:	e8 db fb ff ff       	call   800299 <sys_page_unmap>
	return r;
}
  8006be:	89 d8                	mov    %ebx,%eax
  8006c0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006c3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006c6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006c9:	89 ec                	mov    %ebp,%esp
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	e8 99 fe ff ff       	call   80057e <fd_lookup>
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 13                	js     8006fc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8006e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8006f0:	00 
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	e8 3f ff ff ff       	call   80063b <fd_close>
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <close_all>:

void
close_all(void)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	53                   	push   %ebx
  800702:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800705:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80070a:	89 1c 24             	mov    %ebx,(%esp)
  80070d:	e8 bb ff ff ff       	call   8006cd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800712:	83 c3 01             	add    $0x1,%ebx
  800715:	83 fb 20             	cmp    $0x20,%ebx
  800718:	75 f0                	jne    80070a <close_all+0xc>
		close(i);
}
  80071a:	83 c4 14             	add    $0x14,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 58             	sub    $0x58,%esp
  800726:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800729:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80072c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80072f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800732:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	e8 3a fe ff ff       	call   80057e <fd_lookup>
  800744:	89 c3                	mov    %eax,%ebx
  800746:	85 c0                	test   %eax,%eax
  800748:	0f 88 e1 00 00 00    	js     80082f <dup+0x10f>
		return r;
	close(newfdnum);
  80074e:	89 3c 24             	mov    %edi,(%esp)
  800751:	e8 77 ff ff ff       	call   8006cd <close>

	newfd = INDEX2FD(newfdnum);
  800756:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80075c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80075f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800762:	89 04 24             	mov    %eax,(%esp)
  800765:	e8 86 fd ff ff       	call   8004f0 <fd2data>
  80076a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80076c:	89 34 24             	mov    %esi,(%esp)
  80076f:	e8 7c fd ff ff       	call   8004f0 <fd2data>
  800774:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800777:	89 d8                	mov    %ebx,%eax
  800779:	c1 e8 16             	shr    $0x16,%eax
  80077c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800783:	a8 01                	test   $0x1,%al
  800785:	74 46                	je     8007cd <dup+0xad>
  800787:	89 d8                	mov    %ebx,%eax
  800789:	c1 e8 0c             	shr    $0xc,%eax
  80078c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800793:	f6 c2 01             	test   $0x1,%dl
  800796:	74 35                	je     8007cd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800798:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80079f:	25 07 0e 00 00       	and    $0xe07,%eax
  8007a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007b6:	00 
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007c2:	e8 74 fa ff ff       	call   80023b <sys_page_map>
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 3b                	js     800808 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	c1 ea 0c             	shr    $0xc,%edx
  8007d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007dc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8007e2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007f1:	00 
  8007f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007fd:	e8 39 fa ff ff       	call   80023b <sys_page_map>
  800802:	89 c3                	mov    %eax,%ebx
  800804:	85 c0                	test   %eax,%eax
  800806:	79 25                	jns    80082d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800808:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800813:	e8 81 fa ff ff       	call   800299 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800818:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80081b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800826:	e8 6e fa ff ff       	call   800299 <sys_page_unmap>
	return r;
  80082b:	eb 02                	jmp    80082f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80082d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800834:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800837:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80083a:	89 ec                	mov    %ebp,%esp
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	83 ec 24             	sub    $0x24,%esp
  800845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800848:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084f:	89 1c 24             	mov    %ebx,(%esp)
  800852:	e8 27 fd ff ff       	call   80057e <fd_lookup>
  800857:	85 c0                	test   %eax,%eax
  800859:	78 6d                	js     8008c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800865:	8b 00                	mov    (%eax),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	e8 60 fd ff ff       	call   8005cf <dev_lookup>
  80086f:	85 c0                	test   %eax,%eax
  800871:	78 55                	js     8008c8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800873:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800876:	8b 50 08             	mov    0x8(%eax),%edx
  800879:	83 e2 03             	and    $0x3,%edx
  80087c:	83 fa 01             	cmp    $0x1,%edx
  80087f:	75 23                	jne    8008a4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800881:	a1 04 40 80 00       	mov    0x804004,%eax
  800886:	8b 40 48             	mov    0x48(%eax),%eax
  800889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	c7 04 24 a5 23 80 00 	movl   $0x8023a5,(%esp)
  800898:	e8 2e 0b 00 00       	call   8013cb <cprintf>
		return -E_INVAL;
  80089d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a2:	eb 24                	jmp    8008c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8008a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008a7:	8b 52 08             	mov    0x8(%edx),%edx
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	74 15                	je     8008c3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	ff d2                	call   *%edx
  8008c1:	eb 05                	jmp    8008c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8008c8:	83 c4 24             	add    $0x24,%esp
  8008cb:	5b                   	pop    %ebx
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	83 ec 1c             	sub    $0x1c,%esp
  8008d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e2:	85 f6                	test   %esi,%esi
  8008e4:	74 30                	je     800916 <readn+0x48>
  8008e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	29 c2                	sub    %eax,%edx
  8008ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008f3:	03 45 0c             	add    0xc(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	89 3c 24             	mov    %edi,(%esp)
  8008fd:	e8 3c ff ff ff       	call   80083e <read>
		if (m < 0)
  800902:	85 c0                	test   %eax,%eax
  800904:	78 10                	js     800916 <readn+0x48>
			return m;
		if (m == 0)
  800906:	85 c0                	test   %eax,%eax
  800908:	74 0a                	je     800914 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80090a:	01 c3                	add    %eax,%ebx
  80090c:	89 d8                	mov    %ebx,%eax
  80090e:	39 f3                	cmp    %esi,%ebx
  800910:	72 d9                	jb     8008eb <readn+0x1d>
  800912:	eb 02                	jmp    800916 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800914:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800916:	83 c4 1c             	add    $0x1c,%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	83 ec 24             	sub    $0x24,%esp
  800925:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800928:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80092b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092f:	89 1c 24             	mov    %ebx,(%esp)
  800932:	e8 47 fc ff ff       	call   80057e <fd_lookup>
  800937:	85 c0                	test   %eax,%eax
  800939:	78 68                	js     8009a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80093b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800942:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800945:	8b 00                	mov    (%eax),%eax
  800947:	89 04 24             	mov    %eax,(%esp)
  80094a:	e8 80 fc ff ff       	call   8005cf <dev_lookup>
  80094f:	85 c0                	test   %eax,%eax
  800951:	78 50                	js     8009a3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800956:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80095a:	75 23                	jne    80097f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80095c:	a1 04 40 80 00       	mov    0x804004,%eax
  800961:	8b 40 48             	mov    0x48(%eax),%eax
  800964:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096c:	c7 04 24 c1 23 80 00 	movl   $0x8023c1,(%esp)
  800973:	e8 53 0a 00 00       	call   8013cb <cprintf>
		return -E_INVAL;
  800978:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80097d:	eb 24                	jmp    8009a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80097f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800982:	8b 52 0c             	mov    0xc(%edx),%edx
  800985:	85 d2                	test   %edx,%edx
  800987:	74 15                	je     80099e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800989:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80098c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800993:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800997:	89 04 24             	mov    %eax,(%esp)
  80099a:	ff d2                	call   *%edx
  80099c:	eb 05                	jmp    8009a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80099e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8009a3:	83 c4 24             	add    $0x24,%esp
  8009a6:	5b                   	pop    %ebx
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8009b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	89 04 24             	mov    %eax,(%esp)
  8009bc:	e8 bd fb ff ff       	call   80057e <fd_lookup>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 0e                	js     8009d3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 24             	sub    $0x24,%esp
  8009dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	89 1c 24             	mov    %ebx,(%esp)
  8009e9:	e8 90 fb ff ff       	call   80057e <fd_lookup>
  8009ee:	85 c0                	test   %eax,%eax
  8009f0:	78 61                	js     800a53 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fc:	8b 00                	mov    (%eax),%eax
  8009fe:	89 04 24             	mov    %eax,(%esp)
  800a01:	e8 c9 fb ff ff       	call   8005cf <dev_lookup>
  800a06:	85 c0                	test   %eax,%eax
  800a08:	78 49                	js     800a53 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a11:	75 23                	jne    800a36 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a13:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a18:	8b 40 48             	mov    0x48(%eax),%eax
  800a1b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a23:	c7 04 24 84 23 80 00 	movl   $0x802384,(%esp)
  800a2a:	e8 9c 09 00 00       	call   8013cb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a34:	eb 1d                	jmp    800a53 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a39:	8b 52 18             	mov    0x18(%edx),%edx
  800a3c:	85 d2                	test   %edx,%edx
  800a3e:	74 0e                	je     800a4e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a47:	89 04 24             	mov    %eax,(%esp)
  800a4a:	ff d2                	call   *%edx
  800a4c:	eb 05                	jmp    800a53 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a4e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a53:	83 c4 24             	add    $0x24,%esp
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 24             	sub    $0x24,%esp
  800a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	89 04 24             	mov    %eax,(%esp)
  800a70:	e8 09 fb ff ff       	call   80057e <fd_lookup>
  800a75:	85 c0                	test   %eax,%eax
  800a77:	78 52                	js     800acb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a83:	8b 00                	mov    (%eax),%eax
  800a85:	89 04 24             	mov    %eax,(%esp)
  800a88:	e8 42 fb ff ff       	call   8005cf <dev_lookup>
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	78 3a                	js     800acb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a94:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a98:	74 2c                	je     800ac6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a9a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a9d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800aa4:	00 00 00 
	stat->st_isdir = 0;
  800aa7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800aae:	00 00 00 
	stat->st_dev = dev;
  800ab1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ab7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800abb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800abe:	89 14 24             	mov    %edx,(%esp)
  800ac1:	ff 50 14             	call   *0x14(%eax)
  800ac4:	eb 05                	jmp    800acb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ac6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800acb:	83 c4 24             	add    $0x24,%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 18             	sub    $0x18,%esp
  800ad7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ada:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800add:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ae4:	00 
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 bc 01 00 00       	call   800cac <open>
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 1b                	js     800b11 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afd:	89 1c 24             	mov    %ebx,(%esp)
  800b00:	e8 54 ff ff ff       	call   800a59 <fstat>
  800b05:	89 c6                	mov    %eax,%esi
	close(fd);
  800b07:	89 1c 24             	mov    %ebx,(%esp)
  800b0a:	e8 be fb ff ff       	call   8006cd <close>
	return r;
  800b0f:	89 f3                	mov    %esi,%ebx
}
  800b11:	89 d8                	mov    %ebx,%eax
  800b13:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b16:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b19:	89 ec                	mov    %ebp,%esp
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    
  800b1d:	00 00                	add    %al,(%eax)
	...

00800b20 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 18             	sub    $0x18,%esp
  800b26:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b29:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b30:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b37:	75 11                	jne    800b4a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b40:	e8 8c 14 00 00       	call   801fd1 <ipc_find_env>
  800b45:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b4a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b51:	00 
  800b52:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b59:	00 
  800b5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b5e:	a1 00 40 80 00       	mov    0x804000,%eax
  800b63:	89 04 24             	mov    %eax,(%esp)
  800b66:	e8 fb 13 00 00       	call   801f66 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  800b6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b72:	00 
  800b73:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b7e:	e8 7d 13 00 00       	call   801f00 <ipc_recv>
}
  800b83:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b86:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b89:	89 ec                	mov    %ebp,%esp
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	53                   	push   %ebx
  800b91:	83 ec 14             	sub    $0x14,%esp
  800b94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	8b 40 0c             	mov    0xc(%eax),%eax
  800b9d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bac:	e8 6f ff ff ff       	call   800b20 <fsipc>
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	78 2b                	js     800be0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800bb5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bbc:	00 
  800bbd:	89 1c 24             	mov    %ebx,(%esp)
  800bc0:	e8 56 0f 00 00       	call   801b1b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800bc5:	a1 80 50 80 00       	mov    0x805080,%eax
  800bca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bd0:	a1 84 50 80 00       	mov    0x805084,%eax
  800bd5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be0:	83 c4 14             	add    $0x14,%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 06 00 00 00       	mov    $0x6,%eax
  800c01:	e8 1a ff ff ff       	call   800b20 <fsipc>
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 10             	sub    $0x10,%esp
  800c10:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 40 0c             	mov    0xc(%eax),%eax
  800c19:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800c1e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2e:	e8 ed fe ff ff       	call   800b20 <fsipc>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	85 c0                	test   %eax,%eax
  800c37:	78 6a                	js     800ca3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c39:	39 c6                	cmp    %eax,%esi
  800c3b:	73 24                	jae    800c61 <devfile_read+0x59>
  800c3d:	c7 44 24 0c f0 23 80 	movl   $0x8023f0,0xc(%esp)
  800c44:	00 
  800c45:	c7 44 24 08 f7 23 80 	movl   $0x8023f7,0x8(%esp)
  800c4c:	00 
  800c4d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800c54:	00 
  800c55:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  800c5c:	e8 6f 06 00 00       	call   8012d0 <_panic>
	assert(r <= PGSIZE);
  800c61:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c66:	7e 24                	jle    800c8c <devfile_read+0x84>
  800c68:	c7 44 24 0c 17 24 80 	movl   $0x802417,0xc(%esp)
  800c6f:	00 
  800c70:	c7 44 24 08 f7 23 80 	movl   $0x8023f7,0x8(%esp)
  800c77:	00 
  800c78:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c7f:	00 
  800c80:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  800c87:	e8 44 06 00 00       	call   8012d0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800c8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c90:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c97:	00 
  800c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9b:	89 04 24             	mov    %eax,(%esp)
  800c9e:	e8 69 10 00 00       	call   801d0c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  800ca3:	89 d8                	mov    %ebx,%eax
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 20             	sub    $0x20,%esp
  800cb4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800cb7:	89 34 24             	mov    %esi,(%esp)
  800cba:	e8 11 0e 00 00       	call   801ad0 <strlen>
		return -E_BAD_PATH;
  800cbf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800cc4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cc9:	7f 5e                	jg     800d29 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ccb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cce:	89 04 24             	mov    %eax,(%esp)
  800cd1:	e8 35 f8 ff ff       	call   80050b <fd_alloc>
  800cd6:	89 c3                	mov    %eax,%ebx
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	78 4d                	js     800d29 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cdc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ce7:	e8 2f 0e 00 00       	call   801b1b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfc:	e8 1f fe ff ff       	call   800b20 <fsipc>
  800d01:	89 c3                	mov    %eax,%ebx
  800d03:	85 c0                	test   %eax,%eax
  800d05:	79 15                	jns    800d1c <open+0x70>
		fd_close(fd, 0);
  800d07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d0e:	00 
  800d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d12:	89 04 24             	mov    %eax,(%esp)
  800d15:	e8 21 f9 ff ff       	call   80063b <fd_close>
		return r;
  800d1a:	eb 0d                	jmp    800d29 <open+0x7d>
	}

	return fd2num(fd);
  800d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1f:	89 04 24             	mov    %eax,(%esp)
  800d22:	e8 b9 f7 ff ff       	call   8004e0 <fd2num>
  800d27:	89 c3                	mov    %eax,%ebx
}
  800d29:	89 d8                	mov    %ebx,%eax
  800d2b:	83 c4 20             	add    $0x20,%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
	...

00800d40 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 18             	sub    $0x18,%esp
  800d46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d49:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d4c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 96 f7 ff ff       	call   8004f0 <fd2data>
  800d5a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d5c:	c7 44 24 04 23 24 80 	movl   $0x802423,0x4(%esp)
  800d63:	00 
  800d64:	89 34 24             	mov    %esi,(%esp)
  800d67:	e8 af 0d 00 00       	call   801b1b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d6c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d6f:	2b 03                	sub    (%ebx),%eax
  800d71:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d77:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d7e:	00 00 00 
	stat->st_dev = &devpipe;
  800d81:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  800d88:	30 80 00 
	return 0;
}
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d90:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d93:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d96:	89 ec                	mov    %ebp,%esp
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 14             	sub    $0x14,%esp
  800da1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800da4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800daf:	e8 e5 f4 ff ff       	call   800299 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800db4:	89 1c 24             	mov    %ebx,(%esp)
  800db7:	e8 34 f7 ff ff       	call   8004f0 <fd2data>
  800dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dc7:	e8 cd f4 ff ff       	call   800299 <sys_page_unmap>
}
  800dcc:	83 c4 14             	add    $0x14,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 2c             	sub    $0x2c,%esp
  800ddb:	89 c7                	mov    %eax,%edi
  800ddd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800de0:	a1 04 40 80 00       	mov    0x804004,%eax
  800de5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800de8:	89 3c 24             	mov    %edi,(%esp)
  800deb:	e8 2c 12 00 00       	call   80201c <pageref>
  800df0:	89 c6                	mov    %eax,%esi
  800df2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df5:	89 04 24             	mov    %eax,(%esp)
  800df8:	e8 1f 12 00 00       	call   80201c <pageref>
  800dfd:	39 c6                	cmp    %eax,%esi
  800dff:	0f 94 c0             	sete   %al
  800e02:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800e05:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800e0b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800e0e:	39 cb                	cmp    %ecx,%ebx
  800e10:	75 08                	jne    800e1a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800e12:	83 c4 2c             	add    $0x2c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800e1a:	83 f8 01             	cmp    $0x1,%eax
  800e1d:	75 c1                	jne    800de0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800e1f:	8b 52 58             	mov    0x58(%edx),%edx
  800e22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e26:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e2e:	c7 04 24 2a 24 80 00 	movl   $0x80242a,(%esp)
  800e35:	e8 91 05 00 00       	call   8013cb <cprintf>
  800e3a:	eb a4                	jmp    800de0 <_pipeisclosed+0xe>

00800e3c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	83 ec 2c             	sub    $0x2c,%esp
  800e45:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800e48:	89 34 24             	mov    %esi,(%esp)
  800e4b:	e8 a0 f6 ff ff       	call   8004f0 <fd2data>
  800e50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e52:	bf 00 00 00 00       	mov    $0x0,%edi
  800e57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e5b:	75 50                	jne    800ead <devpipe_write+0x71>
  800e5d:	eb 5c                	jmp    800ebb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e5f:	89 da                	mov    %ebx,%edx
  800e61:	89 f0                	mov    %esi,%eax
  800e63:	e8 6a ff ff ff       	call   800dd2 <_pipeisclosed>
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	75 53                	jne    800ebf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e6c:	e8 3b f3 ff ff       	call   8001ac <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e71:	8b 43 04             	mov    0x4(%ebx),%eax
  800e74:	8b 13                	mov    (%ebx),%edx
  800e76:	83 c2 20             	add    $0x20,%edx
  800e79:	39 d0                	cmp    %edx,%eax
  800e7b:	73 e2                	jae    800e5f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e80:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  800e84:	88 55 e7             	mov    %dl,-0x19(%ebp)
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	c1 fa 1f             	sar    $0x1f,%edx
  800e8c:	c1 ea 1b             	shr    $0x1b,%edx
  800e8f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800e92:	83 e1 1f             	and    $0x1f,%ecx
  800e95:	29 d1                	sub    %edx,%ecx
  800e97:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800e9b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800e9f:	83 c0 01             	add    $0x1,%eax
  800ea2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ea5:	83 c7 01             	add    $0x1,%edi
  800ea8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800eab:	74 0e                	je     800ebb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ead:	8b 43 04             	mov    0x4(%ebx),%eax
  800eb0:	8b 13                	mov    (%ebx),%edx
  800eb2:	83 c2 20             	add    $0x20,%edx
  800eb5:	39 d0                	cmp    %edx,%eax
  800eb7:	73 a6                	jae    800e5f <devpipe_write+0x23>
  800eb9:	eb c2                	jmp    800e7d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	eb 05                	jmp    800ec4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ebf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ec4:	83 c4 2c             	add    $0x2c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 28             	sub    $0x28,%esp
  800ed2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800edb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ede:	89 3c 24             	mov    %edi,(%esp)
  800ee1:	e8 0a f6 ff ff       	call   8004f0 <fd2data>
  800ee6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ee8:	be 00 00 00 00       	mov    $0x0,%esi
  800eed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef1:	75 47                	jne    800f3a <devpipe_read+0x6e>
  800ef3:	eb 52                	jmp    800f47 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800ef5:	89 f0                	mov    %esi,%eax
  800ef7:	eb 5e                	jmp    800f57 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ef9:	89 da                	mov    %ebx,%edx
  800efb:	89 f8                	mov    %edi,%eax
  800efd:	8d 76 00             	lea    0x0(%esi),%esi
  800f00:	e8 cd fe ff ff       	call   800dd2 <_pipeisclosed>
  800f05:	85 c0                	test   %eax,%eax
  800f07:	75 49                	jne    800f52 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  800f09:	e8 9e f2 ff ff       	call   8001ac <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800f0e:	8b 03                	mov    (%ebx),%eax
  800f10:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f13:	74 e4                	je     800ef9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800f15:	89 c2                	mov    %eax,%edx
  800f17:	c1 fa 1f             	sar    $0x1f,%edx
  800f1a:	c1 ea 1b             	shr    $0x1b,%edx
  800f1d:	01 d0                	add    %edx,%eax
  800f1f:	83 e0 1f             	and    $0x1f,%eax
  800f22:	29 d0                	sub    %edx,%eax
  800f24:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800f2f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800f32:	83 c6 01             	add    $0x1,%esi
  800f35:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f38:	74 0d                	je     800f47 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  800f3a:	8b 03                	mov    (%ebx),%eax
  800f3c:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f3f:	75 d4                	jne    800f15 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800f41:	85 f6                	test   %esi,%esi
  800f43:	75 b0                	jne    800ef5 <devpipe_read+0x29>
  800f45:	eb b2                	jmp    800ef9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	eb 05                	jmp    800f57 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800f52:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800f57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f60:	89 ec                	mov    %ebp,%esp
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 48             	sub    $0x48,%esp
  800f6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f70:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f73:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800f76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f79:	89 04 24             	mov    %eax,(%esp)
  800f7c:	e8 8a f5 ff ff       	call   80050b <fd_alloc>
  800f81:	89 c3                	mov    %eax,%ebx
  800f83:	85 c0                	test   %eax,%eax
  800f85:	0f 88 45 01 00 00    	js     8010d0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f8b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f92:	00 
  800f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa1:	e8 36 f2 ff ff       	call   8001dc <sys_page_alloc>
  800fa6:	89 c3                	mov    %eax,%ebx
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	0f 88 20 01 00 00    	js     8010d0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800fb0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fb3:	89 04 24             	mov    %eax,(%esp)
  800fb6:	e8 50 f5 ff ff       	call   80050b <fd_alloc>
  800fbb:	89 c3                	mov    %eax,%ebx
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	0f 88 f8 00 00 00    	js     8010bd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fc5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fcc:	00 
  800fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdb:	e8 fc f1 ff ff       	call   8001dc <sys_page_alloc>
  800fe0:	89 c3                	mov    %eax,%ebx
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	0f 88 d3 00 00 00    	js     8010bd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800fea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fed:	89 04 24             	mov    %eax,(%esp)
  800ff0:	e8 fb f4 ff ff       	call   8004f0 <fd2data>
  800ff5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ff7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ffe:	00 
  800fff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801003:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100a:	e8 cd f1 ff ff       	call   8001dc <sys_page_alloc>
  80100f:	89 c3                	mov    %eax,%ebx
  801011:	85 c0                	test   %eax,%eax
  801013:	0f 88 91 00 00 00    	js     8010aa <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801019:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80101c:	89 04 24             	mov    %eax,(%esp)
  80101f:	e8 cc f4 ff ff       	call   8004f0 <fd2data>
  801024:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80102b:	00 
  80102c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801030:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801037:	00 
  801038:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801043:	e8 f3 f1 ff ff       	call   80023b <sys_page_map>
  801048:	89 c3                	mov    %eax,%ebx
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 4c                	js     80109a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80104e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801057:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801063:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801069:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80106c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80106e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801071:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801078:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107b:	89 04 24             	mov    %eax,(%esp)
  80107e:	e8 5d f4 ff ff       	call   8004e0 <fd2num>
  801083:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801085:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801088:	89 04 24             	mov    %eax,(%esp)
  80108b:	e8 50 f4 ff ff       	call   8004e0 <fd2num>
  801090:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
  801098:	eb 36                	jmp    8010d0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80109a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a5:	e8 ef f1 ff ff       	call   800299 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8010aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b8:	e8 dc f1 ff ff       	call   800299 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8010bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cb:	e8 c9 f1 ff ff       	call   800299 <sys_page_unmap>
    err:
	return r;
}
  8010d0:	89 d8                	mov    %ebx,%eax
  8010d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010db:	89 ec                	mov    %ebp,%esp
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	89 04 24             	mov    %eax,(%esp)
  8010f2:	e8 87 f4 ff ff       	call   80057e <fd_lookup>
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 15                	js     801110 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8010fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fe:	89 04 24             	mov    %eax,(%esp)
  801101:	e8 ea f3 ff ff       	call   8004f0 <fd2data>
	return _pipeisclosed(fd, p);
  801106:	89 c2                	mov    %eax,%edx
  801108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110b:	e8 c2 fc ff ff       	call   800dd2 <_pipeisclosed>
}
  801110:	c9                   	leave  
  801111:	c3                   	ret    
	...

00801120 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801123:	b8 00 00 00 00       	mov    $0x0,%eax
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801130:	c7 44 24 04 42 24 80 	movl   $0x802442,0x4(%esp)
  801137:	00 
  801138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113b:	89 04 24             	mov    %eax,(%esp)
  80113e:	e8 d8 09 00 00       	call   801b1b <strcpy>
	return 0;
}
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801156:	be 00 00 00 00       	mov    $0x0,%esi
  80115b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80115f:	74 43                	je     8011a4 <devcons_write+0x5a>
  801161:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801166:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80116c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80116f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801171:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801174:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801179:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80117c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801180:	03 45 0c             	add    0xc(%ebp),%eax
  801183:	89 44 24 04          	mov    %eax,0x4(%esp)
  801187:	89 3c 24             	mov    %edi,(%esp)
  80118a:	e8 7d 0b 00 00       	call   801d0c <memmove>
		sys_cputs(buf, m);
  80118f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801193:	89 3c 24             	mov    %edi,(%esp)
  801196:	e8 25 ef ff ff       	call   8000c0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80119b:	01 de                	add    %ebx,%esi
  80119d:	89 f0                	mov    %esi,%eax
  80119f:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011a2:	72 c8                	jb     80116c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8011a4:	89 f0                	mov    %esi,%eax
  8011a6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8011bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011c0:	75 07                	jne    8011c9 <devcons_read+0x18>
  8011c2:	eb 31                	jmp    8011f5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8011c4:	e8 e3 ef ff ff       	call   8001ac <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	e8 1a ef ff ff       	call   8000ef <sys_cgetc>
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	74 eb                	je     8011c4 <devcons_read+0x13>
  8011d9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 16                	js     8011f5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8011df:	83 f8 04             	cmp    $0x4,%eax
  8011e2:	74 0c                	je     8011f0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e7:	88 10                	mov    %dl,(%eax)
	return 1;
  8011e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ee:	eb 05                	jmp    8011f5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801203:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80120a:	00 
  80120b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80120e:	89 04 24             	mov    %eax,(%esp)
  801211:	e8 aa ee ff ff       	call   8000c0 <sys_cputs>
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <getchar>:

int
getchar(void)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80121e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801225:	00 
  801226:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801234:	e8 05 f6 ff ff       	call   80083e <read>
	if (r < 0)
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 0f                	js     80124c <getchar+0x34>
		return r;
	if (r < 1)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	7e 06                	jle    801247 <getchar+0x2f>
		return -E_EOF;
	return c;
  801241:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801245:	eb 05                	jmp    80124c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801247:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	89 04 24             	mov    %eax,(%esp)
  801261:	e8 18 f3 ff ff       	call   80057e <fd_lookup>
  801266:	85 c0                	test   %eax,%eax
  801268:	78 11                	js     80127b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80126a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801273:	39 10                	cmp    %edx,(%eax)
  801275:	0f 94 c0             	sete   %al
  801278:	0f b6 c0             	movzbl %al,%eax
}
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <opencons>:

int
opencons(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801283:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801286:	89 04 24             	mov    %eax,(%esp)
  801289:	e8 7d f2 ff ff       	call   80050b <fd_alloc>
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 3c                	js     8012ce <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801292:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801299:	00 
  80129a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a8:	e8 2f ef ff ff       	call   8001dc <sys_page_alloc>
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 1d                	js     8012ce <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8012b1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8012bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 12 f2 ff ff       	call   8004e0 <fd2num>
}
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012d8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012db:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8012e1:	e8 96 ee ff ff       	call   80017c <sys_getenvid>
  8012e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fc:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  801303:	e8 c3 00 00 00       	call   8013cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801308:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130c:	8b 45 10             	mov    0x10(%ebp),%eax
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	e8 53 00 00 00       	call   80136a <vcprintf>
	cprintf("\n");
  801317:	c7 04 24 3b 24 80 00 	movl   $0x80243b,(%esp)
  80131e:	e8 a8 00 00 00       	call   8013cb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801323:	cc                   	int3   
  801324:	eb fd                	jmp    801323 <_panic+0x53>
	...

00801328 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	83 ec 14             	sub    $0x14,%esp
  80132f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801332:	8b 03                	mov    (%ebx),%eax
  801334:	8b 55 08             	mov    0x8(%ebp),%edx
  801337:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80133b:	83 c0 01             	add    $0x1,%eax
  80133e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801340:	3d ff 00 00 00       	cmp    $0xff,%eax
  801345:	75 19                	jne    801360 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801347:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80134e:	00 
  80134f:	8d 43 08             	lea    0x8(%ebx),%eax
  801352:	89 04 24             	mov    %eax,(%esp)
  801355:	e8 66 ed ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  80135a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801360:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801364:	83 c4 14             	add    $0x14,%esp
  801367:	5b                   	pop    %ebx
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801373:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80137a:	00 00 00 
	b.cnt = 0;
  80137d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801384:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	89 44 24 08          	mov    %eax,0x8(%esp)
  801395:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	c7 04 24 28 13 80 00 	movl   $0x801328,(%esp)
  8013a6:	e8 97 01 00 00       	call   801542 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8013ab:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8013b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 fd ec ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8013c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8013c9:	c9                   	leave  
  8013ca:	c3                   	ret    

008013cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8013d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 87 ff ff ff       	call   80136a <vcprintf>
	va_end(ap);

	return cnt;
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    
  8013e5:	00 00                	add    %al,(%eax)
	...

008013e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	57                   	push   %edi
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 3c             	sub    $0x3c,%esp
  8013f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013f4:	89 d7                	mov    %edx,%edi
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801402:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801405:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
  80140d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801410:	72 11                	jb     801423 <printnum+0x3b>
  801412:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801415:	39 45 10             	cmp    %eax,0x10(%ebp)
  801418:	76 09                	jbe    801423 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80141a:	83 eb 01             	sub    $0x1,%ebx
  80141d:	85 db                	test   %ebx,%ebx
  80141f:	7f 51                	jg     801472 <printnum+0x8a>
  801421:	eb 5e                	jmp    801481 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801423:	89 74 24 10          	mov    %esi,0x10(%esp)
  801427:	83 eb 01             	sub    $0x1,%ebx
  80142a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80142e:	8b 45 10             	mov    0x10(%ebp),%eax
  801431:	89 44 24 08          	mov    %eax,0x8(%esp)
  801435:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801439:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80143d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801444:	00 
  801445:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801448:	89 04 24             	mov    %eax,(%esp)
  80144b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80144e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801452:	e8 09 0c 00 00       	call   802060 <__udivdi3>
  801457:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80145b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80145f:	89 04 24             	mov    %eax,(%esp)
  801462:	89 54 24 04          	mov    %edx,0x4(%esp)
  801466:	89 fa                	mov    %edi,%edx
  801468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80146b:	e8 78 ff ff ff       	call   8013e8 <printnum>
  801470:	eb 0f                	jmp    801481 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801472:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801476:	89 34 24             	mov    %esi,(%esp)
  801479:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80147c:	83 eb 01             	sub    $0x1,%ebx
  80147f:	75 f1                	jne    801472 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801481:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801485:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801489:	8b 45 10             	mov    0x10(%ebp),%eax
  80148c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801497:	00 
  801498:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a5:	e8 e6 0c 00 00       	call   802190 <__umoddi3>
  8014aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ae:	0f be 80 73 24 80 00 	movsbl 0x802473(%eax),%eax
  8014b5:	89 04 24             	mov    %eax,(%esp)
  8014b8:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014bb:	83 c4 3c             	add    $0x3c,%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5e                   	pop    %esi
  8014c0:	5f                   	pop    %edi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014c6:	83 fa 01             	cmp    $0x1,%edx
  8014c9:	7e 0e                	jle    8014d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014cb:	8b 10                	mov    (%eax),%edx
  8014cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014d0:	89 08                	mov    %ecx,(%eax)
  8014d2:	8b 02                	mov    (%edx),%eax
  8014d4:	8b 52 04             	mov    0x4(%edx),%edx
  8014d7:	eb 22                	jmp    8014fb <getuint+0x38>
	else if (lflag)
  8014d9:	85 d2                	test   %edx,%edx
  8014db:	74 10                	je     8014ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014dd:	8b 10                	mov    (%eax),%edx
  8014df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014e2:	89 08                	mov    %ecx,(%eax)
  8014e4:	8b 02                	mov    (%edx),%eax
  8014e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014eb:	eb 0e                	jmp    8014fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8014ed:	8b 10                	mov    (%eax),%edx
  8014ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014f2:	89 08                	mov    %ecx,(%eax)
  8014f4:	8b 02                	mov    (%edx),%eax
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801503:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801507:	8b 10                	mov    (%eax),%edx
  801509:	3b 50 04             	cmp    0x4(%eax),%edx
  80150c:	73 0a                	jae    801518 <sprintputch+0x1b>
		*b->buf++ = ch;
  80150e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801511:	88 0a                	mov    %cl,(%edx)
  801513:	83 c2 01             	add    $0x1,%edx
  801516:	89 10                	mov    %edx,(%eax)
}
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801520:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801527:	8b 45 10             	mov    0x10(%ebp),%eax
  80152a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80152e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801531:	89 44 24 04          	mov    %eax,0x4(%esp)
  801535:	8b 45 08             	mov    0x8(%ebp),%eax
  801538:	89 04 24             	mov    %eax,(%esp)
  80153b:	e8 02 00 00 00       	call   801542 <vprintfmt>
	va_end(ap);
}
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	57                   	push   %edi
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
  801548:	83 ec 5c             	sub    $0x5c,%esp
  80154b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
  801551:	eb 12                	jmp    801565 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801553:	85 c0                	test   %eax,%eax
  801555:	0f 84 e4 04 00 00    	je     801a3f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80155b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155f:	89 04 24             	mov    %eax,(%esp)
  801562:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801565:	0f b6 06             	movzbl (%esi),%eax
  801568:	83 c6 01             	add    $0x1,%esi
  80156b:	83 f8 25             	cmp    $0x25,%eax
  80156e:	75 e3                	jne    801553 <vprintfmt+0x11>
  801570:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  801574:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80157b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801580:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801587:	b9 00 00 00 00       	mov    $0x0,%ecx
  80158c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80158f:	eb 2b                	jmp    8015bc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801591:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801594:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  801598:	eb 22                	jmp    8015bc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80159d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8015a1:	eb 19                	jmp    8015bc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8015a6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8015ad:	eb 0d                	jmp    8015bc <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8015af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8015b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015b5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015bc:	0f b6 06             	movzbl (%esi),%eax
  8015bf:	0f b6 d0             	movzbl %al,%edx
  8015c2:	8d 7e 01             	lea    0x1(%esi),%edi
  8015c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8015c8:	83 e8 23             	sub    $0x23,%eax
  8015cb:	3c 55                	cmp    $0x55,%al
  8015cd:	0f 87 46 04 00 00    	ja     801a19 <vprintfmt+0x4d7>
  8015d3:	0f b6 c0             	movzbl %al,%eax
  8015d6:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015dd:	83 ea 30             	sub    $0x30,%edx
  8015e0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8015e3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8015e7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ea:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8015ed:	83 fa 09             	cmp    $0x9,%edx
  8015f0:	77 4a                	ja     80163c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015f5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8015f8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8015fb:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8015ff:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801602:	8d 50 d0             	lea    -0x30(%eax),%edx
  801605:	83 fa 09             	cmp    $0x9,%edx
  801608:	76 eb                	jbe    8015f5 <vprintfmt+0xb3>
  80160a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80160d:	eb 2d                	jmp    80163c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80160f:	8b 45 14             	mov    0x14(%ebp),%eax
  801612:	8d 50 04             	lea    0x4(%eax),%edx
  801615:	89 55 14             	mov    %edx,0x14(%ebp)
  801618:	8b 00                	mov    (%eax),%eax
  80161a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801620:	eb 1a                	jmp    80163c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801622:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  801625:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801629:	79 91                	jns    8015bc <vprintfmt+0x7a>
  80162b:	e9 73 ff ff ff       	jmp    8015a3 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801630:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801633:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80163a:	eb 80                	jmp    8015bc <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80163c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801640:	0f 89 76 ff ff ff    	jns    8015bc <vprintfmt+0x7a>
  801646:	e9 64 ff ff ff       	jmp    8015af <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80164b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801651:	e9 66 ff ff ff       	jmp    8015bc <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801656:	8b 45 14             	mov    0x14(%ebp),%eax
  801659:	8d 50 04             	lea    0x4(%eax),%edx
  80165c:	89 55 14             	mov    %edx,0x14(%ebp)
  80165f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801663:	8b 00                	mov    (%eax),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80166e:	e9 f2 fe ff ff       	jmp    801565 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  801673:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  801677:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80167a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80167e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  801681:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  801685:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  801688:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80168b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80168f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801692:	80 f9 09             	cmp    $0x9,%cl
  801695:	77 1d                	ja     8016b4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  801697:	0f be c0             	movsbl %al,%eax
  80169a:	6b c0 64             	imul   $0x64,%eax,%eax
  80169d:	0f be d2             	movsbl %dl,%edx
  8016a0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8016a3:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8016aa:	a3 5c 30 80 00       	mov    %eax,0x80305c
  8016af:	e9 b1 fe ff ff       	jmp    801565 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8016b4:	c7 44 24 04 8b 24 80 	movl   $0x80248b,0x4(%esp)
  8016bb:	00 
  8016bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 14 05 00 00       	call   801bdb <strcmp>
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	75 0f                	jne    8016da <vprintfmt+0x198>
  8016cb:	c7 05 5c 30 80 00 04 	movl   $0x4,0x80305c
  8016d2:	00 00 00 
  8016d5:	e9 8b fe ff ff       	jmp    801565 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8016da:	c7 44 24 04 8f 24 80 	movl   $0x80248f,0x4(%esp)
  8016e1:	00 
  8016e2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8016e5:	89 14 24             	mov    %edx,(%esp)
  8016e8:	e8 ee 04 00 00       	call   801bdb <strcmp>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	75 0f                	jne    801700 <vprintfmt+0x1be>
  8016f1:	c7 05 5c 30 80 00 02 	movl   $0x2,0x80305c
  8016f8:	00 00 00 
  8016fb:	e9 65 fe ff ff       	jmp    801565 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  801700:	c7 44 24 04 93 24 80 	movl   $0x802493,0x4(%esp)
  801707:	00 
  801708:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80170b:	89 0c 24             	mov    %ecx,(%esp)
  80170e:	e8 c8 04 00 00       	call   801bdb <strcmp>
  801713:	85 c0                	test   %eax,%eax
  801715:	75 0f                	jne    801726 <vprintfmt+0x1e4>
  801717:	c7 05 5c 30 80 00 01 	movl   $0x1,0x80305c
  80171e:	00 00 00 
  801721:	e9 3f fe ff ff       	jmp    801565 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  801726:	c7 44 24 04 97 24 80 	movl   $0x802497,0x4(%esp)
  80172d:	00 
  80172e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  801731:	89 3c 24             	mov    %edi,(%esp)
  801734:	e8 a2 04 00 00       	call   801bdb <strcmp>
  801739:	85 c0                	test   %eax,%eax
  80173b:	75 0f                	jne    80174c <vprintfmt+0x20a>
  80173d:	c7 05 5c 30 80 00 06 	movl   $0x6,0x80305c
  801744:	00 00 00 
  801747:	e9 19 fe ff ff       	jmp    801565 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80174c:	c7 44 24 04 9b 24 80 	movl   $0x80249b,0x4(%esp)
  801753:	00 
  801754:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801757:	89 04 24             	mov    %eax,(%esp)
  80175a:	e8 7c 04 00 00       	call   801bdb <strcmp>
  80175f:	85 c0                	test   %eax,%eax
  801761:	75 0f                	jne    801772 <vprintfmt+0x230>
  801763:	c7 05 5c 30 80 00 07 	movl   $0x7,0x80305c
  80176a:	00 00 00 
  80176d:	e9 f3 fd ff ff       	jmp    801565 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  801772:	c7 44 24 04 9f 24 80 	movl   $0x80249f,0x4(%esp)
  801779:	00 
  80177a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80177d:	89 14 24             	mov    %edx,(%esp)
  801780:	e8 56 04 00 00       	call   801bdb <strcmp>
  801785:	83 f8 01             	cmp    $0x1,%eax
  801788:	19 c0                	sbb    %eax,%eax
  80178a:	f7 d0                	not    %eax
  80178c:	83 c0 08             	add    $0x8,%eax
  80178f:	a3 5c 30 80 00       	mov    %eax,0x80305c
  801794:	e9 cc fd ff ff       	jmp    801565 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  801799:	8b 45 14             	mov    0x14(%ebp),%eax
  80179c:	8d 50 04             	lea    0x4(%eax),%edx
  80179f:	89 55 14             	mov    %edx,0x14(%ebp)
  8017a2:	8b 00                	mov    (%eax),%eax
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	c1 fa 1f             	sar    $0x1f,%edx
  8017a9:	31 d0                	xor    %edx,%eax
  8017ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ad:	83 f8 0f             	cmp    $0xf,%eax
  8017b0:	7f 0b                	jg     8017bd <vprintfmt+0x27b>
  8017b2:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8017b9:	85 d2                	test   %edx,%edx
  8017bb:	75 23                	jne    8017e0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8017bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017c1:	c7 44 24 08 a3 24 80 	movl   $0x8024a3,0x8(%esp)
  8017c8:	00 
  8017c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d0:	89 3c 24             	mov    %edi,(%esp)
  8017d3:	e8 42 fd ff ff       	call   80151a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017db:	e9 85 fd ff ff       	jmp    801565 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8017e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017e4:	c7 44 24 08 09 24 80 	movl   $0x802409,0x8(%esp)
  8017eb:	00 
  8017ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f3:	89 3c 24             	mov    %edi,(%esp)
  8017f6:	e8 1f fd ff ff       	call   80151a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8017fe:	e9 62 fd ff ff       	jmp    801565 <vprintfmt+0x23>
  801803:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  801806:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801809:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80180c:	8b 45 14             	mov    0x14(%ebp),%eax
  80180f:	8d 50 04             	lea    0x4(%eax),%edx
  801812:	89 55 14             	mov    %edx,0x14(%ebp)
  801815:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801817:	85 f6                	test   %esi,%esi
  801819:	b8 84 24 80 00       	mov    $0x802484,%eax
  80181e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801821:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801825:	7e 06                	jle    80182d <vprintfmt+0x2eb>
  801827:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80182b:	75 13                	jne    801840 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80182d:	0f be 06             	movsbl (%esi),%eax
  801830:	83 c6 01             	add    $0x1,%esi
  801833:	85 c0                	test   %eax,%eax
  801835:	0f 85 94 00 00 00    	jne    8018cf <vprintfmt+0x38d>
  80183b:	e9 81 00 00 00       	jmp    8018c1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801840:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801844:	89 34 24             	mov    %esi,(%esp)
  801847:	e8 9f 02 00 00       	call   801aeb <strnlen>
  80184c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80184f:	29 c2                	sub    %eax,%edx
  801851:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801854:	85 d2                	test   %edx,%edx
  801856:	7e d5                	jle    80182d <vprintfmt+0x2eb>
					putch(padc, putdat);
  801858:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80185c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80185f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  801862:	89 d6                	mov    %edx,%esi
  801864:	89 cf                	mov    %ecx,%edi
  801866:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80186a:	89 3c 24             	mov    %edi,(%esp)
  80186d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801870:	83 ee 01             	sub    $0x1,%esi
  801873:	75 f1                	jne    801866 <vprintfmt+0x324>
  801875:	8b 7d c0             	mov    -0x40(%ebp),%edi
  801878:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80187b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80187e:	eb ad                	jmp    80182d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801880:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  801884:	74 1b                	je     8018a1 <vprintfmt+0x35f>
  801886:	8d 50 e0             	lea    -0x20(%eax),%edx
  801889:	83 fa 5e             	cmp    $0x5e,%edx
  80188c:	76 13                	jbe    8018a1 <vprintfmt+0x35f>
					putch('?', putdat);
  80188e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801891:	89 44 24 04          	mov    %eax,0x4(%esp)
  801895:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80189c:	ff 55 08             	call   *0x8(%ebp)
  80189f:	eb 0d                	jmp    8018ae <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8018a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8018a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018a8:	89 04 24             	mov    %eax,(%esp)
  8018ab:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ae:	83 eb 01             	sub    $0x1,%ebx
  8018b1:	0f be 06             	movsbl (%esi),%eax
  8018b4:	83 c6 01             	add    $0x1,%esi
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	75 1a                	jne    8018d5 <vprintfmt+0x393>
  8018bb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8018be:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018c4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8018c8:	7f 1c                	jg     8018e6 <vprintfmt+0x3a4>
  8018ca:	e9 96 fc ff ff       	jmp    801565 <vprintfmt+0x23>
  8018cf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8018d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d5:	85 ff                	test   %edi,%edi
  8018d7:	78 a7                	js     801880 <vprintfmt+0x33e>
  8018d9:	83 ef 01             	sub    $0x1,%edi
  8018dc:	79 a2                	jns    801880 <vprintfmt+0x33e>
  8018de:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8018e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8018e4:	eb db                	jmp    8018c1 <vprintfmt+0x37f>
  8018e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018e9:	89 de                	mov    %ebx,%esi
  8018eb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8018f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018fb:	83 eb 01             	sub    $0x1,%ebx
  8018fe:	75 ee                	jne    8018ee <vprintfmt+0x3ac>
  801900:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801902:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801905:	e9 5b fc ff ff       	jmp    801565 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80190a:	83 f9 01             	cmp    $0x1,%ecx
  80190d:	7e 10                	jle    80191f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80190f:	8b 45 14             	mov    0x14(%ebp),%eax
  801912:	8d 50 08             	lea    0x8(%eax),%edx
  801915:	89 55 14             	mov    %edx,0x14(%ebp)
  801918:	8b 30                	mov    (%eax),%esi
  80191a:	8b 78 04             	mov    0x4(%eax),%edi
  80191d:	eb 26                	jmp    801945 <vprintfmt+0x403>
	else if (lflag)
  80191f:	85 c9                	test   %ecx,%ecx
  801921:	74 12                	je     801935 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  801923:	8b 45 14             	mov    0x14(%ebp),%eax
  801926:	8d 50 04             	lea    0x4(%eax),%edx
  801929:	89 55 14             	mov    %edx,0x14(%ebp)
  80192c:	8b 30                	mov    (%eax),%esi
  80192e:	89 f7                	mov    %esi,%edi
  801930:	c1 ff 1f             	sar    $0x1f,%edi
  801933:	eb 10                	jmp    801945 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  801935:	8b 45 14             	mov    0x14(%ebp),%eax
  801938:	8d 50 04             	lea    0x4(%eax),%edx
  80193b:	89 55 14             	mov    %edx,0x14(%ebp)
  80193e:	8b 30                	mov    (%eax),%esi
  801940:	89 f7                	mov    %esi,%edi
  801942:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801945:	85 ff                	test   %edi,%edi
  801947:	78 0e                	js     801957 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801949:	89 f0                	mov    %esi,%eax
  80194b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80194d:	be 0a 00 00 00       	mov    $0xa,%esi
  801952:	e9 84 00 00 00       	jmp    8019db <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801957:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801962:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801965:	89 f0                	mov    %esi,%eax
  801967:	89 fa                	mov    %edi,%edx
  801969:	f7 d8                	neg    %eax
  80196b:	83 d2 00             	adc    $0x0,%edx
  80196e:	f7 da                	neg    %edx
			}
			base = 10;
  801970:	be 0a 00 00 00       	mov    $0xa,%esi
  801975:	eb 64                	jmp    8019db <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801977:	89 ca                	mov    %ecx,%edx
  801979:	8d 45 14             	lea    0x14(%ebp),%eax
  80197c:	e8 42 fb ff ff       	call   8014c3 <getuint>
			base = 10;
  801981:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  801986:	eb 53                	jmp    8019db <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801988:	89 ca                	mov    %ecx,%edx
  80198a:	8d 45 14             	lea    0x14(%ebp),%eax
  80198d:	e8 31 fb ff ff       	call   8014c3 <getuint>
    			base = 8;
  801992:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  801997:	eb 42                	jmp    8019db <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  801999:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8019a4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8019a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8019b2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b8:	8d 50 04             	lea    0x4(%eax),%edx
  8019bb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019be:	8b 00                	mov    (%eax),%eax
  8019c0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019c5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8019ca:	eb 0f                	jmp    8019db <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019cc:	89 ca                	mov    %ecx,%edx
  8019ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8019d1:	e8 ed fa ff ff       	call   8014c3 <getuint>
			base = 16;
  8019d6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019db:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8019df:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8019e3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8019e6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019ea:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019f5:	89 da                	mov    %ebx,%edx
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	e8 e9 f9 ff ff       	call   8013e8 <printnum>
			break;
  8019ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801a02:	e9 5e fb ff ff       	jmp    801565 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0b:	89 14 24             	mov    %edx,(%esp)
  801a0e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a11:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a14:	e9 4c fb ff ff       	jmp    801565 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801a24:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a27:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a2b:	0f 84 34 fb ff ff    	je     801565 <vprintfmt+0x23>
  801a31:	83 ee 01             	sub    $0x1,%esi
  801a34:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a38:	75 f7                	jne    801a31 <vprintfmt+0x4ef>
  801a3a:	e9 26 fb ff ff       	jmp    801565 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801a3f:	83 c4 5c             	add    $0x5c,%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	5f                   	pop    %edi
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 28             	sub    $0x28,%esp
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a56:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a5a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	74 30                	je     801a98 <vsnprintf+0x51>
  801a68:	85 d2                	test   %edx,%edx
  801a6a:	7e 2c                	jle    801a98 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a73:	8b 45 10             	mov    0x10(%ebp),%eax
  801a76:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	c7 04 24 fd 14 80 00 	movl   $0x8014fd,(%esp)
  801a88:	e8 b5 fa ff ff       	call   801542 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a90:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a96:	eb 05                	jmp    801a9d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aa5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aac:	8b 45 10             	mov    0x10(%ebp),%eax
  801aaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 82 ff ff ff       	call   801a47 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    
	...

00801ad0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  801adb:	80 3a 00             	cmpb   $0x0,(%edx)
  801ade:	74 09                	je     801ae9 <strlen+0x19>
		n++;
  801ae0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ae3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ae7:	75 f7                	jne    801ae0 <strlen+0x10>
		n++;
	return n;
}
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	53                   	push   %ebx
  801aef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
  801afa:	85 c9                	test   %ecx,%ecx
  801afc:	74 1a                	je     801b18 <strnlen+0x2d>
  801afe:	80 3b 00             	cmpb   $0x0,(%ebx)
  801b01:	74 15                	je     801b18 <strnlen+0x2d>
  801b03:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801b08:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b0a:	39 ca                	cmp    %ecx,%edx
  801b0c:	74 0a                	je     801b18 <strnlen+0x2d>
  801b0e:	83 c2 01             	add    $0x1,%edx
  801b11:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801b16:	75 f0                	jne    801b08 <strnlen+0x1d>
		n++;
	return n;
}
  801b18:	5b                   	pop    %ebx
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	53                   	push   %ebx
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801b2e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801b31:	83 c2 01             	add    $0x1,%edx
  801b34:	84 c9                	test   %cl,%cl
  801b36:	75 f2                	jne    801b2a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b38:	5b                   	pop    %ebx
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 08             	sub    $0x8,%esp
  801b42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b45:	89 1c 24             	mov    %ebx,(%esp)
  801b48:	e8 83 ff ff ff       	call   801ad0 <strlen>
	strcpy(dst + len, src);
  801b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b50:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b54:	01 d8                	add    %ebx,%eax
  801b56:	89 04 24             	mov    %eax,(%esp)
  801b59:	e8 bd ff ff ff       	call   801b1b <strcpy>
	return dst;
}
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	83 c4 08             	add    $0x8,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b74:	85 f6                	test   %esi,%esi
  801b76:	74 18                	je     801b90 <strncpy+0x2a>
  801b78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b7d:	0f b6 1a             	movzbl (%edx),%ebx
  801b80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b83:	80 3a 01             	cmpb   $0x1,(%edx)
  801b86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b89:	83 c1 01             	add    $0x1,%ecx
  801b8c:	39 f1                	cmp    %esi,%ecx
  801b8e:	75 ed                	jne    801b7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ba0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ba3:	89 f8                	mov    %edi,%eax
  801ba5:	85 f6                	test   %esi,%esi
  801ba7:	74 2b                	je     801bd4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801ba9:	83 fe 01             	cmp    $0x1,%esi
  801bac:	74 23                	je     801bd1 <strlcpy+0x3d>
  801bae:	0f b6 0b             	movzbl (%ebx),%ecx
  801bb1:	84 c9                	test   %cl,%cl
  801bb3:	74 1c                	je     801bd1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801bb5:	83 ee 02             	sub    $0x2,%esi
  801bb8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bbd:	88 08                	mov    %cl,(%eax)
  801bbf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bc2:	39 f2                	cmp    %esi,%edx
  801bc4:	74 0b                	je     801bd1 <strlcpy+0x3d>
  801bc6:	83 c2 01             	add    $0x1,%edx
  801bc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801bcd:	84 c9                	test   %cl,%cl
  801bcf:	75 ec                	jne    801bbd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  801bd1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bd4:	29 f8                	sub    %edi,%eax
}
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801be4:	0f b6 01             	movzbl (%ecx),%eax
  801be7:	84 c0                	test   %al,%al
  801be9:	74 16                	je     801c01 <strcmp+0x26>
  801beb:	3a 02                	cmp    (%edx),%al
  801bed:	75 12                	jne    801c01 <strcmp+0x26>
		p++, q++;
  801bef:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bf2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801bf6:	84 c0                	test   %al,%al
  801bf8:	74 07                	je     801c01 <strcmp+0x26>
  801bfa:	83 c1 01             	add    $0x1,%ecx
  801bfd:	3a 02                	cmp    (%edx),%al
  801bff:	74 ee                	je     801bef <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c01:	0f b6 c0             	movzbl %al,%eax
  801c04:	0f b6 12             	movzbl (%edx),%edx
  801c07:	29 d0                	sub    %edx,%eax
}
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c1d:	85 d2                	test   %edx,%edx
  801c1f:	74 28                	je     801c49 <strncmp+0x3e>
  801c21:	0f b6 01             	movzbl (%ecx),%eax
  801c24:	84 c0                	test   %al,%al
  801c26:	74 24                	je     801c4c <strncmp+0x41>
  801c28:	3a 03                	cmp    (%ebx),%al
  801c2a:	75 20                	jne    801c4c <strncmp+0x41>
  801c2c:	83 ea 01             	sub    $0x1,%edx
  801c2f:	74 13                	je     801c44 <strncmp+0x39>
		n--, p++, q++;
  801c31:	83 c1 01             	add    $0x1,%ecx
  801c34:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c37:	0f b6 01             	movzbl (%ecx),%eax
  801c3a:	84 c0                	test   %al,%al
  801c3c:	74 0e                	je     801c4c <strncmp+0x41>
  801c3e:	3a 03                	cmp    (%ebx),%al
  801c40:	74 ea                	je     801c2c <strncmp+0x21>
  801c42:	eb 08                	jmp    801c4c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c49:	5b                   	pop    %ebx
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4c:	0f b6 01             	movzbl (%ecx),%eax
  801c4f:	0f b6 13             	movzbl (%ebx),%edx
  801c52:	29 d0                	sub    %edx,%eax
  801c54:	eb f3                	jmp    801c49 <strncmp+0x3e>

00801c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c60:	0f b6 10             	movzbl (%eax),%edx
  801c63:	84 d2                	test   %dl,%dl
  801c65:	74 1c                	je     801c83 <strchr+0x2d>
		if (*s == c)
  801c67:	38 ca                	cmp    %cl,%dl
  801c69:	75 09                	jne    801c74 <strchr+0x1e>
  801c6b:	eb 1b                	jmp    801c88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c6d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  801c70:	38 ca                	cmp    %cl,%dl
  801c72:	74 14                	je     801c88 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c74:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  801c78:	84 d2                	test   %dl,%dl
  801c7a:	75 f1                	jne    801c6d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c81:	eb 05                	jmp    801c88 <strchr+0x32>
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c94:	0f b6 10             	movzbl (%eax),%edx
  801c97:	84 d2                	test   %dl,%dl
  801c99:	74 14                	je     801caf <strfind+0x25>
		if (*s == c)
  801c9b:	38 ca                	cmp    %cl,%dl
  801c9d:	75 06                	jne    801ca5 <strfind+0x1b>
  801c9f:	eb 0e                	jmp    801caf <strfind+0x25>
  801ca1:	38 ca                	cmp    %cl,%dl
  801ca3:	74 0a                	je     801caf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801ca5:	83 c0 01             	add    $0x1,%eax
  801ca8:	0f b6 10             	movzbl (%eax),%edx
  801cab:	84 d2                	test   %dl,%dl
  801cad:	75 f2                	jne    801ca1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 0c             	sub    $0xc,%esp
  801cb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801cba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc9:	85 c9                	test   %ecx,%ecx
  801ccb:	74 30                	je     801cfd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ccd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cd3:	75 25                	jne    801cfa <memset+0x49>
  801cd5:	f6 c1 03             	test   $0x3,%cl
  801cd8:	75 20                	jne    801cfa <memset+0x49>
		c &= 0xFF;
  801cda:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cdd:	89 d3                	mov    %edx,%ebx
  801cdf:	c1 e3 08             	shl    $0x8,%ebx
  801ce2:	89 d6                	mov    %edx,%esi
  801ce4:	c1 e6 18             	shl    $0x18,%esi
  801ce7:	89 d0                	mov    %edx,%eax
  801ce9:	c1 e0 10             	shl    $0x10,%eax
  801cec:	09 f0                	or     %esi,%eax
  801cee:	09 d0                	or     %edx,%eax
  801cf0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cf2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801cf5:	fc                   	cld    
  801cf6:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf8:	eb 03                	jmp    801cfd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cfa:	fc                   	cld    
  801cfb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cfd:	89 f8                	mov    %edi,%eax
  801cff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d02:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d05:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d08:	89 ec                	mov    %ebp,%esp
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d15:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d21:	39 c6                	cmp    %eax,%esi
  801d23:	73 36                	jae    801d5b <memmove+0x4f>
  801d25:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d28:	39 d0                	cmp    %edx,%eax
  801d2a:	73 2f                	jae    801d5b <memmove+0x4f>
		s += n;
		d += n;
  801d2c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2f:	f6 c2 03             	test   $0x3,%dl
  801d32:	75 1b                	jne    801d4f <memmove+0x43>
  801d34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d3a:	75 13                	jne    801d4f <memmove+0x43>
  801d3c:	f6 c1 03             	test   $0x3,%cl
  801d3f:	75 0e                	jne    801d4f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d41:	83 ef 04             	sub    $0x4,%edi
  801d44:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d47:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d4a:	fd                   	std    
  801d4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4d:	eb 09                	jmp    801d58 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d4f:	83 ef 01             	sub    $0x1,%edi
  801d52:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d55:	fd                   	std    
  801d56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d58:	fc                   	cld    
  801d59:	eb 20                	jmp    801d7b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d61:	75 13                	jne    801d76 <memmove+0x6a>
  801d63:	a8 03                	test   $0x3,%al
  801d65:	75 0f                	jne    801d76 <memmove+0x6a>
  801d67:	f6 c1 03             	test   $0x3,%cl
  801d6a:	75 0a                	jne    801d76 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d6c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801d6f:	89 c7                	mov    %eax,%edi
  801d71:	fc                   	cld    
  801d72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d74:	eb 05                	jmp    801d7b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d76:	89 c7                	mov    %eax,%edi
  801d78:	fc                   	cld    
  801d79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d7b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d7e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d81:	89 ec                	mov    %ebp,%esp
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 68 ff ff ff       	call   801d0c <memmove>
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	57                   	push   %edi
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801daf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801db2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801db5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dba:	85 ff                	test   %edi,%edi
  801dbc:	74 37                	je     801df5 <memcmp+0x4f>
		if (*s1 != *s2)
  801dbe:	0f b6 03             	movzbl (%ebx),%eax
  801dc1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc4:	83 ef 01             	sub    $0x1,%edi
  801dc7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  801dcc:	38 c8                	cmp    %cl,%al
  801dce:	74 1c                	je     801dec <memcmp+0x46>
  801dd0:	eb 10                	jmp    801de2 <memcmp+0x3c>
  801dd2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801dd7:	83 c2 01             	add    $0x1,%edx
  801dda:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801dde:	38 c8                	cmp    %cl,%al
  801de0:	74 0a                	je     801dec <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801de2:	0f b6 c0             	movzbl %al,%eax
  801de5:	0f b6 c9             	movzbl %cl,%ecx
  801de8:	29 c8                	sub    %ecx,%eax
  801dea:	eb 09                	jmp    801df5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dec:	39 fa                	cmp    %edi,%edx
  801dee:	75 e2                	jne    801dd2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e00:	89 c2                	mov    %eax,%edx
  801e02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e05:	39 d0                	cmp    %edx,%eax
  801e07:	73 19                	jae    801e22 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801e0d:	38 08                	cmp    %cl,(%eax)
  801e0f:	75 06                	jne    801e17 <memfind+0x1d>
  801e11:	eb 0f                	jmp    801e22 <memfind+0x28>
  801e13:	38 08                	cmp    %cl,(%eax)
  801e15:	74 0b                	je     801e22 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e17:	83 c0 01             	add    $0x1,%eax
  801e1a:	39 d0                	cmp    %edx,%eax
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	75 f1                	jne    801e13 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	57                   	push   %edi
  801e28:	56                   	push   %esi
  801e29:	53                   	push   %ebx
  801e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e30:	0f b6 02             	movzbl (%edx),%eax
  801e33:	3c 20                	cmp    $0x20,%al
  801e35:	74 04                	je     801e3b <strtol+0x17>
  801e37:	3c 09                	cmp    $0x9,%al
  801e39:	75 0e                	jne    801e49 <strtol+0x25>
		s++;
  801e3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3e:	0f b6 02             	movzbl (%edx),%eax
  801e41:	3c 20                	cmp    $0x20,%al
  801e43:	74 f6                	je     801e3b <strtol+0x17>
  801e45:	3c 09                	cmp    $0x9,%al
  801e47:	74 f2                	je     801e3b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e49:	3c 2b                	cmp    $0x2b,%al
  801e4b:	75 0a                	jne    801e57 <strtol+0x33>
		s++;
  801e4d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e50:	bf 00 00 00 00       	mov    $0x0,%edi
  801e55:	eb 10                	jmp    801e67 <strtol+0x43>
  801e57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e5c:	3c 2d                	cmp    $0x2d,%al
  801e5e:	75 07                	jne    801e67 <strtol+0x43>
		s++, neg = 1;
  801e60:	83 c2 01             	add    $0x1,%edx
  801e63:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e67:	85 db                	test   %ebx,%ebx
  801e69:	0f 94 c0             	sete   %al
  801e6c:	74 05                	je     801e73 <strtol+0x4f>
  801e6e:	83 fb 10             	cmp    $0x10,%ebx
  801e71:	75 15                	jne    801e88 <strtol+0x64>
  801e73:	80 3a 30             	cmpb   $0x30,(%edx)
  801e76:	75 10                	jne    801e88 <strtol+0x64>
  801e78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e7c:	75 0a                	jne    801e88 <strtol+0x64>
		s += 2, base = 16;
  801e7e:	83 c2 02             	add    $0x2,%edx
  801e81:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e86:	eb 13                	jmp    801e9b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801e88:	84 c0                	test   %al,%al
  801e8a:	74 0f                	je     801e9b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e91:	80 3a 30             	cmpb   $0x30,(%edx)
  801e94:	75 05                	jne    801e9b <strtol+0x77>
		s++, base = 8;
  801e96:	83 c2 01             	add    $0x1,%edx
  801e99:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ea2:	0f b6 0a             	movzbl (%edx),%ecx
  801ea5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801ea8:	80 fb 09             	cmp    $0x9,%bl
  801eab:	77 08                	ja     801eb5 <strtol+0x91>
			dig = *s - '0';
  801ead:	0f be c9             	movsbl %cl,%ecx
  801eb0:	83 e9 30             	sub    $0x30,%ecx
  801eb3:	eb 1e                	jmp    801ed3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801eb5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801eb8:	80 fb 19             	cmp    $0x19,%bl
  801ebb:	77 08                	ja     801ec5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  801ebd:	0f be c9             	movsbl %cl,%ecx
  801ec0:	83 e9 57             	sub    $0x57,%ecx
  801ec3:	eb 0e                	jmp    801ed3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801ec5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801ec8:	80 fb 19             	cmp    $0x19,%bl
  801ecb:	77 14                	ja     801ee1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ecd:	0f be c9             	movsbl %cl,%ecx
  801ed0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ed3:	39 f1                	cmp    %esi,%ecx
  801ed5:	7d 0e                	jge    801ee5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801ed7:	83 c2 01             	add    $0x1,%edx
  801eda:	0f af c6             	imul   %esi,%eax
  801edd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801edf:	eb c1                	jmp    801ea2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801ee1:	89 c1                	mov    %eax,%ecx
  801ee3:	eb 02                	jmp    801ee7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ee5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801ee7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eeb:	74 05                	je     801ef2 <strtol+0xce>
		*endptr = (char *) s;
  801eed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ef0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801ef2:	89 ca                	mov    %ecx,%edx
  801ef4:	f7 da                	neg    %edx
  801ef6:	85 ff                	test   %edi,%edi
  801ef8:	0f 45 c2             	cmovne %edx,%eax
}
  801efb:	5b                   	pop    %ebx
  801efc:	5e                   	pop    %esi
  801efd:	5f                   	pop    %edi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 10             	sub    $0x10,%esp
  801f08:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f11:	85 db                	test   %ebx,%ebx
  801f13:	74 06                	je     801f1b <ipc_recv+0x1b>
  801f15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f1b:	85 f6                	test   %esi,%esi
  801f1d:	74 06                	je     801f25 <ipc_recv+0x25>
  801f1f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f25:	85 c0                	test   %eax,%eax
  801f27:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f2c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f2f:	89 04 24             	mov    %eax,(%esp)
  801f32:	e8 0e e5 ff ff       	call   800445 <sys_ipc_recv>
    if (ret) return ret;
  801f37:	85 c0                	test   %eax,%eax
  801f39:	75 24                	jne    801f5f <ipc_recv+0x5f>
    if (from_env_store)
  801f3b:	85 db                	test   %ebx,%ebx
  801f3d:	74 0a                	je     801f49 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f3f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f44:	8b 40 74             	mov    0x74(%eax),%eax
  801f47:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f49:	85 f6                	test   %esi,%esi
  801f4b:	74 0a                	je     801f57 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f4d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f52:	8b 40 78             	mov    0x78(%eax),%eax
  801f55:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f57:	a1 04 40 80 00       	mov    0x804004,%eax
  801f5c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	5b                   	pop    %ebx
  801f63:	5e                   	pop    %esi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    

00801f66 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	57                   	push   %edi
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 1c             	sub    $0x1c,%esp
  801f6f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f72:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f78:	85 db                	test   %ebx,%ebx
  801f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f7f:	0f 44 d8             	cmove  %eax,%ebx
  801f82:	eb 2a                	jmp    801fae <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f84:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f87:	74 20                	je     801fa9 <ipc_send+0x43>
  801f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8d:	c7 44 24 08 80 27 80 	movl   $0x802780,0x8(%esp)
  801f94:	00 
  801f95:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801f9c:	00 
  801f9d:	c7 04 24 97 27 80 00 	movl   $0x802797,(%esp)
  801fa4:	e8 27 f3 ff ff       	call   8012d0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801fa9:	e8 fe e1 ff ff       	call   8001ac <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fae:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fbd:	89 34 24             	mov    %esi,(%esp)
  801fc0:	e8 4c e4 ff ff       	call   800411 <sys_ipc_try_send>
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	75 bb                	jne    801f84 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fc9:	83 c4 1c             	add    $0x1c,%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5f                   	pop    %edi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fd7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801fdc:	39 c8                	cmp    %ecx,%eax
  801fde:	74 19                	je     801ff9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fe5:	89 c2                	mov    %eax,%edx
  801fe7:	c1 e2 07             	shl    $0x7,%edx
  801fea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff0:	8b 52 50             	mov    0x50(%edx),%edx
  801ff3:	39 ca                	cmp    %ecx,%edx
  801ff5:	75 14                	jne    80200b <ipc_find_env+0x3a>
  801ff7:	eb 05                	jmp    801ffe <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ffe:	c1 e0 07             	shl    $0x7,%eax
  802001:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802006:	8b 40 40             	mov    0x40(%eax),%eax
  802009:	eb 0e                	jmp    802019 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80200b:	83 c0 01             	add    $0x1,%eax
  80200e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802013:	75 d0                	jne    801fe5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802015:	66 b8 00 00          	mov    $0x0,%ax
}
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    
	...

0080201c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802022:	89 d0                	mov    %edx,%eax
  802024:	c1 e8 16             	shr    $0x16,%eax
  802027:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802033:	f6 c1 01             	test   $0x1,%cl
  802036:	74 1d                	je     802055 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802038:	c1 ea 0c             	shr    $0xc,%edx
  80203b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802042:	f6 c2 01             	test   $0x1,%dl
  802045:	74 0e                	je     802055 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802047:	c1 ea 0c             	shr    $0xc,%edx
  80204a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802051:	ef 
  802052:	0f b7 c0             	movzwl %ax,%eax
}
  802055:	5d                   	pop    %ebp
  802056:	c3                   	ret    
	...

00802060 <__udivdi3>:
  802060:	83 ec 1c             	sub    $0x1c,%esp
  802063:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802067:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80206b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80206f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802073:	89 74 24 10          	mov    %esi,0x10(%esp)
  802077:	8b 74 24 24          	mov    0x24(%esp),%esi
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802081:	89 44 24 08          	mov    %eax,0x8(%esp)
  802085:	89 cd                	mov    %ecx,%ebp
  802087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208b:	75 33                	jne    8020c0 <__udivdi3+0x60>
  80208d:	39 f1                	cmp    %esi,%ecx
  80208f:	77 57                	ja     8020e8 <__udivdi3+0x88>
  802091:	85 c9                	test   %ecx,%ecx
  802093:	75 0b                	jne    8020a0 <__udivdi3+0x40>
  802095:	b8 01 00 00 00       	mov    $0x1,%eax
  80209a:	31 d2                	xor    %edx,%edx
  80209c:	f7 f1                	div    %ecx
  80209e:	89 c1                	mov    %eax,%ecx
  8020a0:	89 f0                	mov    %esi,%eax
  8020a2:	31 d2                	xor    %edx,%edx
  8020a4:	f7 f1                	div    %ecx
  8020a6:	89 c6                	mov    %eax,%esi
  8020a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020ac:	f7 f1                	div    %ecx
  8020ae:	89 f2                	mov    %esi,%edx
  8020b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	c3                   	ret    
  8020c0:	31 d2                	xor    %edx,%edx
  8020c2:	31 c0                	xor    %eax,%eax
  8020c4:	39 f7                	cmp    %esi,%edi
  8020c6:	77 e8                	ja     8020b0 <__udivdi3+0x50>
  8020c8:	0f bd cf             	bsr    %edi,%ecx
  8020cb:	83 f1 1f             	xor    $0x1f,%ecx
  8020ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020d2:	75 2c                	jne    802100 <__udivdi3+0xa0>
  8020d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020d8:	76 04                	jbe    8020de <__udivdi3+0x7e>
  8020da:	39 f7                	cmp    %esi,%edi
  8020dc:	73 d2                	jae    8020b0 <__udivdi3+0x50>
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e5:	eb c9                	jmp    8020b0 <__udivdi3+0x50>
  8020e7:	90                   	nop
  8020e8:	89 f2                	mov    %esi,%edx
  8020ea:	f7 f1                	div    %ecx
  8020ec:	31 d2                	xor    %edx,%edx
  8020ee:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	c3                   	ret    
  8020fe:	66 90                	xchg   %ax,%ax
  802100:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802105:	b8 20 00 00 00       	mov    $0x20,%eax
  80210a:	89 ea                	mov    %ebp,%edx
  80210c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802110:	d3 e7                	shl    %cl,%edi
  802112:	89 c1                	mov    %eax,%ecx
  802114:	d3 ea                	shr    %cl,%edx
  802116:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80211b:	09 fa                	or     %edi,%edx
  80211d:	89 f7                	mov    %esi,%edi
  80211f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802123:	89 f2                	mov    %esi,%edx
  802125:	8b 74 24 08          	mov    0x8(%esp),%esi
  802129:	d3 e5                	shl    %cl,%ebp
  80212b:	89 c1                	mov    %eax,%ecx
  80212d:	d3 ef                	shr    %cl,%edi
  80212f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802134:	d3 e2                	shl    %cl,%edx
  802136:	89 c1                	mov    %eax,%ecx
  802138:	d3 ee                	shr    %cl,%esi
  80213a:	09 d6                	or     %edx,%esi
  80213c:	89 fa                	mov    %edi,%edx
  80213e:	89 f0                	mov    %esi,%eax
  802140:	f7 74 24 0c          	divl   0xc(%esp)
  802144:	89 d7                	mov    %edx,%edi
  802146:	89 c6                	mov    %eax,%esi
  802148:	f7 e5                	mul    %ebp
  80214a:	39 d7                	cmp    %edx,%edi
  80214c:	72 22                	jb     802170 <__udivdi3+0x110>
  80214e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802152:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802157:	d3 e5                	shl    %cl,%ebp
  802159:	39 c5                	cmp    %eax,%ebp
  80215b:	73 04                	jae    802161 <__udivdi3+0x101>
  80215d:	39 d7                	cmp    %edx,%edi
  80215f:	74 0f                	je     802170 <__udivdi3+0x110>
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	e9 46 ff ff ff       	jmp    8020b0 <__udivdi3+0x50>
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	8d 46 ff             	lea    -0x1(%esi),%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	8b 74 24 10          	mov    0x10(%esp),%esi
  802179:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80217d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	c3                   	ret    
	...

00802190 <__umoddi3>:
  802190:	83 ec 1c             	sub    $0x1c,%esp
  802193:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802197:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80219b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80219f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021ab:	85 ed                	test   %ebp,%ebp
  8021ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b5:	89 cf                	mov    %ecx,%edi
  8021b7:	89 04 24             	mov    %eax,(%esp)
  8021ba:	89 f2                	mov    %esi,%edx
  8021bc:	75 1a                	jne    8021d8 <__umoddi3+0x48>
  8021be:	39 f1                	cmp    %esi,%ecx
  8021c0:	76 4e                	jbe    802210 <__umoddi3+0x80>
  8021c2:	f7 f1                	div    %ecx
  8021c4:	89 d0                	mov    %edx,%eax
  8021c6:	31 d2                	xor    %edx,%edx
  8021c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	c3                   	ret    
  8021d8:	39 f5                	cmp    %esi,%ebp
  8021da:	77 54                	ja     802230 <__umoddi3+0xa0>
  8021dc:	0f bd c5             	bsr    %ebp,%eax
  8021df:	83 f0 1f             	xor    $0x1f,%eax
  8021e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e6:	75 60                	jne    802248 <__umoddi3+0xb8>
  8021e8:	3b 0c 24             	cmp    (%esp),%ecx
  8021eb:	0f 87 07 01 00 00    	ja     8022f8 <__umoddi3+0x168>
  8021f1:	89 f2                	mov    %esi,%edx
  8021f3:	8b 34 24             	mov    (%esp),%esi
  8021f6:	29 ce                	sub    %ecx,%esi
  8021f8:	19 ea                	sbb    %ebp,%edx
  8021fa:	89 34 24             	mov    %esi,(%esp)
  8021fd:	8b 04 24             	mov    (%esp),%eax
  802200:	8b 74 24 10          	mov    0x10(%esp),%esi
  802204:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802208:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	c3                   	ret    
  802210:	85 c9                	test   %ecx,%ecx
  802212:	75 0b                	jne    80221f <__umoddi3+0x8f>
  802214:	b8 01 00 00 00       	mov    $0x1,%eax
  802219:	31 d2                	xor    %edx,%edx
  80221b:	f7 f1                	div    %ecx
  80221d:	89 c1                	mov    %eax,%ecx
  80221f:	89 f0                	mov    %esi,%eax
  802221:	31 d2                	xor    %edx,%edx
  802223:	f7 f1                	div    %ecx
  802225:	8b 04 24             	mov    (%esp),%eax
  802228:	f7 f1                	div    %ecx
  80222a:	eb 98                	jmp    8021c4 <__umoddi3+0x34>
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f2                	mov    %esi,%edx
  802232:	8b 74 24 10          	mov    0x10(%esp),%esi
  802236:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80223a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80223e:	83 c4 1c             	add    $0x1c,%esp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80224d:	89 e8                	mov    %ebp,%eax
  80224f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802254:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802258:	89 fa                	mov    %edi,%edx
  80225a:	d3 e0                	shl    %cl,%eax
  80225c:	89 e9                	mov    %ebp,%ecx
  80225e:	d3 ea                	shr    %cl,%edx
  802260:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802265:	09 c2                	or     %eax,%edx
  802267:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226b:	89 14 24             	mov    %edx,(%esp)
  80226e:	89 f2                	mov    %esi,%edx
  802270:	d3 e7                	shl    %cl,%edi
  802272:	89 e9                	mov    %ebp,%ecx
  802274:	d3 ea                	shr    %cl,%edx
  802276:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80227b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80227f:	d3 e6                	shl    %cl,%esi
  802281:	89 e9                	mov    %ebp,%ecx
  802283:	d3 e8                	shr    %cl,%eax
  802285:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80228a:	09 f0                	or     %esi,%eax
  80228c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802290:	f7 34 24             	divl   (%esp)
  802293:	d3 e6                	shl    %cl,%esi
  802295:	89 74 24 08          	mov    %esi,0x8(%esp)
  802299:	89 d6                	mov    %edx,%esi
  80229b:	f7 e7                	mul    %edi
  80229d:	39 d6                	cmp    %edx,%esi
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	89 d7                	mov    %edx,%edi
  8022a3:	72 3f                	jb     8022e4 <__umoddi3+0x154>
  8022a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022a9:	72 35                	jb     8022e0 <__umoddi3+0x150>
  8022ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022af:	29 c8                	sub    %ecx,%eax
  8022b1:	19 fe                	sbb    %edi,%esi
  8022b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022b8:	89 f2                	mov    %esi,%edx
  8022ba:	d3 e8                	shr    %cl,%eax
  8022bc:	89 e9                	mov    %ebp,%ecx
  8022be:	d3 e2                	shl    %cl,%edx
  8022c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022c5:	09 d0                	or     %edx,%eax
  8022c7:	89 f2                	mov    %esi,%edx
  8022c9:	d3 ea                	shr    %cl,%edx
  8022cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022d7:	83 c4 1c             	add    $0x1c,%esp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 d6                	cmp    %edx,%esi
  8022e2:	75 c7                	jne    8022ab <__umoddi3+0x11b>
  8022e4:	89 d7                	mov    %edx,%edi
  8022e6:	89 c1                	mov    %eax,%ecx
  8022e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8022ec:	1b 3c 24             	sbb    (%esp),%edi
  8022ef:	eb ba                	jmp    8022ab <__umoddi3+0x11b>
  8022f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 f5                	cmp    %esi,%ebp
  8022fa:	0f 82 f1 fe ff ff    	jb     8021f1 <__umoddi3+0x61>
  802300:	e9 f8 fe ff ff       	jmp    8021fd <__umoddi3+0x6d>
