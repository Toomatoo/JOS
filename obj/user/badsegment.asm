
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 09 01 00 00       	call   800160 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800088:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008b:	89 ec                	mov    %ebp,%esp
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 61 00 00 00       	call   800103 <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	89 c3                	mov    %eax,%ebx
  8000c0:	89 c7                	mov    %eax,%edi
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cf:	89 ec                	mov    %ebp,%esp
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000df:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000ff:	89 ec                	mov    %ebp,%esp
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 38             	sub    $0x38,%esp
  800109:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80010c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7e 28                	jle    800153 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800136:	00 
  800137:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  80014e:	e8 d5 02 00 00       	call   800428 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800156:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800159:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80015c:	89 ec                	mov    %ebp,%esp
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800169:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80016c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 02 00 00 00       	mov    $0x2,%eax
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 d3                	mov    %edx,%ebx
  80017d:	89 d7                	mov    %edx,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800183:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800186:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800189:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80018c:	89 ec                	mov    %ebp,%esp
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_yield>:

void
sys_yield(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800199:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80019c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001a9:	89 d1                	mov    %edx,%ecx
  8001ab:	89 d3                	mov    %edx,%ebx
  8001ad:	89 d7                	mov    %edx,%edi
  8001af:	89 d6                	mov    %edx,%esi
  8001b1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001bc:	89 ec                	mov    %ebp,%esp
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    

008001c0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 38             	sub    $0x38,%esp
  8001c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cf:	be 00 00 00 00       	mov    $0x0,%esi
  8001d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e2:	89 f7                	mov    %esi,%edi
  8001e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	7e 28                	jle    800212 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ee:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800205:	00 
  800206:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  80020d:	e8 16 02 00 00       	call   800428 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800212:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800215:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800218:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80021b:	89 ec                	mov    %ebp,%esp
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 38             	sub    $0x38,%esp
  800225:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800228:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80022b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	b8 05 00 00 00       	mov    $0x5,%eax
  800233:	8b 75 18             	mov    0x18(%ebp),%esi
  800236:	8b 7d 14             	mov    0x14(%ebp),%edi
  800239:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 28                	jle    800270 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800253:	00 
  800254:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  80025b:	00 
  80025c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800263:	00 
  800264:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  80026b:	e8 b8 01 00 00       	call   800428 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800270:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800273:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800276:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800279:	89 ec                	mov    %ebp,%esp
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 38             	sub    $0x38,%esp
  800283:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800286:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800289:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 06 00 00 00       	mov    $0x6,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 28                	jle    8002ce <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002aa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  8002c9:	e8 5a 01 00 00       	call   800428 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d7:	89 ec                	mov    %ebp,%esp
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 38             	sub    $0x38,%esp
  8002e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ef:	b8 08 00 00 00       	mov    $0x8,%eax
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fa:	89 df                	mov    %ebx,%edi
  8002fc:	89 de                	mov    %ebx,%esi
  8002fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800300:	85 c0                	test   %eax,%eax
  800302:	7e 28                	jle    80032c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800304:	89 44 24 10          	mov    %eax,0x10(%esp)
  800308:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80030f:	00 
  800310:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800317:	00 
  800318:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031f:	00 
  800320:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800327:	e8 fc 00 00 00       	call   800428 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80032c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80032f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800332:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800335:	89 ec                	mov    %ebp,%esp
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 38             	sub    $0x38,%esp
  80033f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800342:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800345:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800348:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034d:	b8 09 00 00 00       	mov    $0x9,%eax
  800352:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	89 df                	mov    %ebx,%edi
  80035a:	89 de                	mov    %ebx,%esi
  80035c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035e:	85 c0                	test   %eax,%eax
  800360:	7e 28                	jle    80038a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800362:	89 44 24 10          	mov    %eax,0x10(%esp)
  800366:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80036d:	00 
  80036e:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800375:	00 
  800376:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800385:	e8 9e 00 00 00       	call   800428 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80038a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80038d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800390:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800393:	89 ec                	mov    %ebp,%esp
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	83 ec 0c             	sub    $0xc,%esp
  80039d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003a0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003a3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a6:	be 00 00 00 00       	mov    $0x0,%esi
  8003ab:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003be:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003c7:	89 ec                	mov    %ebp,%esp
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 38             	sub    $0x38,%esp
  8003d1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003d7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003df:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e7:	89 cb                	mov    %ecx,%ebx
  8003e9:	89 cf                	mov    %ecx,%edi
  8003eb:	89 ce                	mov    %ecx,%esi
  8003ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	7e 28                	jle    80041b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f7:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8003fe:	00 
  8003ff:	c7 44 24 08 0a 13 80 	movl   $0x80130a,0x8(%esp)
  800406:	00 
  800407:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040e:	00 
  80040f:	c7 04 24 27 13 80 00 	movl   $0x801327,(%esp)
  800416:	e8 0d 00 00 00       	call   800428 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80041b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80041e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800421:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800424:	89 ec                	mov    %ebp,%esp
  800426:	5d                   	pop    %ebp
  800427:	c3                   	ret    

00800428 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	56                   	push   %esi
  80042c:	53                   	push   %ebx
  80042d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800433:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800439:	e8 22 fd ff ff       	call   800160 <sys_getenvid>
  80043e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800441:	89 54 24 10          	mov    %edx,0x10(%esp)
  800445:	8b 55 08             	mov    0x8(%ebp),%edx
  800448:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800450:	89 44 24 04          	mov    %eax,0x4(%esp)
  800454:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  80045b:	e8 c3 00 00 00       	call   800523 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800460:	89 74 24 04          	mov    %esi,0x4(%esp)
  800464:	8b 45 10             	mov    0x10(%ebp),%eax
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	e8 53 00 00 00       	call   8004c2 <vcprintf>
	cprintf("\n");
  80046f:	c7 04 24 5c 13 80 00 	movl   $0x80135c,(%esp)
  800476:	e8 a8 00 00 00       	call   800523 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047b:	cc                   	int3   
  80047c:	eb fd                	jmp    80047b <_panic+0x53>
	...

00800480 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	53                   	push   %ebx
  800484:	83 ec 14             	sub    $0x14,%esp
  800487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80048a:	8b 03                	mov    (%ebx),%eax
  80048c:	8b 55 08             	mov    0x8(%ebp),%edx
  80048f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800493:	83 c0 01             	add    $0x1,%eax
  800496:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800498:	3d ff 00 00 00       	cmp    $0xff,%eax
  80049d:	75 19                	jne    8004b8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80049f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004a6:	00 
  8004a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	e8 f2 fb ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8004b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004bc:	83 c4 14             	add    $0x14,%esp
  8004bf:	5b                   	pop    %ebx
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004d2:	00 00 00 
	b.cnt = 0;
  8004d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f7:	c7 04 24 80 04 80 00 	movl   $0x800480,(%esp)
  8004fe:	e8 97 01 00 00       	call   80069a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800503:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800513:	89 04 24             	mov    %eax,(%esp)
  800516:	e8 89 fb ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  80051b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800521:	c9                   	leave  
  800522:	c3                   	ret    

00800523 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800529:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80052c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	e8 87 ff ff ff       	call   8004c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    
  80053d:	00 00                	add    %al,(%eax)
	...

00800540 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
  800546:	83 ec 3c             	sub    $0x3c,%esp
  800549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054c:	89 d7                	mov    %edx,%edi
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800554:	8b 45 0c             	mov    0xc(%ebp),%eax
  800557:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80055d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800560:	b8 00 00 00 00       	mov    $0x0,%eax
  800565:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800568:	72 11                	jb     80057b <printnum+0x3b>
  80056a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80056d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800570:	76 09                	jbe    80057b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800572:	83 eb 01             	sub    $0x1,%ebx
  800575:	85 db                	test   %ebx,%ebx
  800577:	7f 51                	jg     8005ca <printnum+0x8a>
  800579:	eb 5e                	jmp    8005d9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80057b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80057f:	83 eb 01             	sub    $0x1,%ebx
  800582:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800586:	8b 45 10             	mov    0x10(%ebp),%eax
  800589:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800591:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800595:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80059c:	00 
  80059d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005aa:	e8 a1 0a 00 00       	call   801050 <__udivdi3>
  8005af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005be:	89 fa                	mov    %edi,%edx
  8005c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c3:	e8 78 ff ff ff       	call   800540 <printnum>
  8005c8:	eb 0f                	jmp    8005d9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ce:	89 34 24             	mov    %esi,(%esp)
  8005d1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005d4:	83 eb 01             	sub    $0x1,%ebx
  8005d7:	75 f1                	jne    8005ca <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ef:	00 
  8005f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f3:	89 04 24             	mov    %eax,(%esp)
  8005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	e8 7e 0b 00 00       	call   801180 <__umoddi3>
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	0f be 80 5e 13 80 00 	movsbl 0x80135e(%eax),%eax
  80060d:	89 04 24             	mov    %eax,(%esp)
  800610:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800613:	83 c4 3c             	add    $0x3c,%esp
  800616:	5b                   	pop    %ebx
  800617:	5e                   	pop    %esi
  800618:	5f                   	pop    %edi
  800619:	5d                   	pop    %ebp
  80061a:	c3                   	ret    

0080061b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80061e:	83 fa 01             	cmp    $0x1,%edx
  800621:	7e 0e                	jle    800631 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800623:	8b 10                	mov    (%eax),%edx
  800625:	8d 4a 08             	lea    0x8(%edx),%ecx
  800628:	89 08                	mov    %ecx,(%eax)
  80062a:	8b 02                	mov    (%edx),%eax
  80062c:	8b 52 04             	mov    0x4(%edx),%edx
  80062f:	eb 22                	jmp    800653 <getuint+0x38>
	else if (lflag)
  800631:	85 d2                	test   %edx,%edx
  800633:	74 10                	je     800645 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800635:	8b 10                	mov    (%eax),%edx
  800637:	8d 4a 04             	lea    0x4(%edx),%ecx
  80063a:	89 08                	mov    %ecx,(%eax)
  80063c:	8b 02                	mov    (%edx),%eax
  80063e:	ba 00 00 00 00       	mov    $0x0,%edx
  800643:	eb 0e                	jmp    800653 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800645:	8b 10                	mov    (%eax),%edx
  800647:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064a:	89 08                	mov    %ecx,(%eax)
  80064c:	8b 02                	mov    (%edx),%eax
  80064e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    

00800655 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80065b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	3b 50 04             	cmp    0x4(%eax),%edx
  800664:	73 0a                	jae    800670 <sprintputch+0x1b>
		*b->buf++ = ch;
  800666:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800669:	88 0a                	mov    %cl,(%edx)
  80066b:	83 c2 01             	add    $0x1,%edx
  80066e:	89 10                	mov    %edx,(%eax)
}
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80067b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067f:	8b 45 10             	mov    0x10(%ebp),%eax
  800682:	89 44 24 08          	mov    %eax,0x8(%esp)
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 02 00 00 00       	call   80069a <vprintfmt>
	va_end(ap);
}
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 5c             	sub    $0x5c,%esp
  8006a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006a9:	eb 12                	jmp    8006bd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	0f 84 e4 04 00 00    	je     800b97 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006bd:	0f b6 06             	movzbl (%esi),%eax
  8006c0:	83 c6 01             	add    $0x1,%esi
  8006c3:	83 f8 25             	cmp    $0x25,%eax
  8006c6:	75 e3                	jne    8006ab <vprintfmt+0x11>
  8006c8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8006cc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8006d3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006d8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8006e7:	eb 2b                	jmp    800714 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ec:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8006f0:	eb 22                	jmp    800714 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006f5:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8006f9:	eb 19                	jmp    800714 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8006fe:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800707:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80070a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80070d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800714:	0f b6 06             	movzbl (%esi),%eax
  800717:	0f b6 d0             	movzbl %al,%edx
  80071a:	8d 7e 01             	lea    0x1(%esi),%edi
  80071d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800720:	83 e8 23             	sub    $0x23,%eax
  800723:	3c 55                	cmp    $0x55,%al
  800725:	0f 87 46 04 00 00    	ja     800b71 <vprintfmt+0x4d7>
  80072b:	0f b6 c0             	movzbl %al,%eax
  80072e:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800735:	83 ea 30             	sub    $0x30,%edx
  800738:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80073b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80073f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800742:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800745:	83 fa 09             	cmp    $0x9,%edx
  800748:	77 4a                	ja     800794 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80074d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800750:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800753:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800757:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80075a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80075d:	83 fa 09             	cmp    $0x9,%edx
  800760:	76 eb                	jbe    80074d <vprintfmt+0xb3>
  800762:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800765:	eb 2d                	jmp    800794 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 50 04             	lea    0x4(%eax),%edx
  80076d:	89 55 14             	mov    %edx,0x14(%ebp)
  800770:	8b 00                	mov    (%eax),%eax
  800772:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800775:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800778:	eb 1a                	jmp    800794 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80077d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800781:	79 91                	jns    800714 <vprintfmt+0x7a>
  800783:	e9 73 ff ff ff       	jmp    8006fb <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800792:	eb 80                	jmp    800714 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800794:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800798:	0f 89 76 ff ff ff    	jns    800714 <vprintfmt+0x7a>
  80079e:	e9 64 ff ff ff       	jmp    800707 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007a3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007a9:	e9 66 ff ff ff       	jmp    800714 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	89 04 24             	mov    %eax,(%esp)
  8007c0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007c6:	e9 f2 fe ff ff       	jmp    8006bd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007cb:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8007cf:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8007d2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8007d6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8007d9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8007dd:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8007e0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8007e3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8007e7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007ea:	80 f9 09             	cmp    $0x9,%cl
  8007ed:	77 1d                	ja     80080c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8007ef:	0f be c0             	movsbl %al,%eax
  8007f2:	6b c0 64             	imul   $0x64,%eax,%eax
  8007f5:	0f be d2             	movsbl %dl,%edx
  8007f8:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8007fb:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800802:	a3 04 20 80 00       	mov    %eax,0x802004
  800807:	e9 b1 fe ff ff       	jmp    8006bd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80080c:	c7 44 24 04 76 13 80 	movl   $0x801376,0x4(%esp)
  800813:	00 
  800814:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	e8 0c 05 00 00       	call   800d2b <strcmp>
  80081f:	85 c0                	test   %eax,%eax
  800821:	75 0f                	jne    800832 <vprintfmt+0x198>
  800823:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80082a:	00 00 00 
  80082d:	e9 8b fe ff ff       	jmp    8006bd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800832:	c7 44 24 04 7a 13 80 	movl   $0x80137a,0x4(%esp)
  800839:	00 
  80083a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80083d:	89 14 24             	mov    %edx,(%esp)
  800840:	e8 e6 04 00 00       	call   800d2b <strcmp>
  800845:	85 c0                	test   %eax,%eax
  800847:	75 0f                	jne    800858 <vprintfmt+0x1be>
  800849:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800850:	00 00 00 
  800853:	e9 65 fe ff ff       	jmp    8006bd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800858:	c7 44 24 04 7e 13 80 	movl   $0x80137e,0x4(%esp)
  80085f:	00 
  800860:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800863:	89 0c 24             	mov    %ecx,(%esp)
  800866:	e8 c0 04 00 00       	call   800d2b <strcmp>
  80086b:	85 c0                	test   %eax,%eax
  80086d:	75 0f                	jne    80087e <vprintfmt+0x1e4>
  80086f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800876:	00 00 00 
  800879:	e9 3f fe ff ff       	jmp    8006bd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80087e:	c7 44 24 04 82 13 80 	movl   $0x801382,0x4(%esp)
  800885:	00 
  800886:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800889:	89 3c 24             	mov    %edi,(%esp)
  80088c:	e8 9a 04 00 00       	call   800d2b <strcmp>
  800891:	85 c0                	test   %eax,%eax
  800893:	75 0f                	jne    8008a4 <vprintfmt+0x20a>
  800895:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  80089c:	00 00 00 
  80089f:	e9 19 fe ff ff       	jmp    8006bd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008a4:	c7 44 24 04 86 13 80 	movl   $0x801386,0x4(%esp)
  8008ab:	00 
  8008ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008af:	89 04 24             	mov    %eax,(%esp)
  8008b2:	e8 74 04 00 00       	call   800d2b <strcmp>
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	75 0f                	jne    8008ca <vprintfmt+0x230>
  8008bb:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008c2:	00 00 00 
  8008c5:	e9 f3 fd ff ff       	jmp    8006bd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008ca:	c7 44 24 04 8a 13 80 	movl   $0x80138a,0x4(%esp)
  8008d1:	00 
  8008d2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008d5:	89 14 24             	mov    %edx,(%esp)
  8008d8:	e8 4e 04 00 00       	call   800d2b <strcmp>
  8008dd:	83 f8 01             	cmp    $0x1,%eax
  8008e0:	19 c0                	sbb    %eax,%eax
  8008e2:	f7 d0                	not    %eax
  8008e4:	83 c0 08             	add    $0x8,%eax
  8008e7:	a3 04 20 80 00       	mov    %eax,0x802004
  8008ec:	e9 cc fd ff ff       	jmp    8006bd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8008f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f4:	8d 50 04             	lea    0x4(%eax),%edx
  8008f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fa:	8b 00                	mov    (%eax),%eax
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	c1 fa 1f             	sar    $0x1f,%edx
  800901:	31 d0                	xor    %edx,%eax
  800903:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800905:	83 f8 08             	cmp    $0x8,%eax
  800908:	7f 0b                	jg     800915 <vprintfmt+0x27b>
  80090a:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  800911:	85 d2                	test   %edx,%edx
  800913:	75 23                	jne    800938 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800915:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800919:	c7 44 24 08 8e 13 80 	movl   $0x80138e,0x8(%esp)
  800920:	00 
  800921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800925:	8b 7d 08             	mov    0x8(%ebp),%edi
  800928:	89 3c 24             	mov    %edi,(%esp)
  80092b:	e8 42 fd ff ff       	call   800672 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800930:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800933:	e9 85 fd ff ff       	jmp    8006bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800938:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80093c:	c7 44 24 08 97 13 80 	movl   $0x801397,0x8(%esp)
  800943:	00 
  800944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	89 3c 24             	mov    %edi,(%esp)
  80094e:	e8 1f fd ff ff       	call   800672 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800953:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800956:	e9 62 fd ff ff       	jmp    8006bd <vprintfmt+0x23>
  80095b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80095e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800961:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8d 50 04             	lea    0x4(%eax),%edx
  80096a:	89 55 14             	mov    %edx,0x14(%ebp)
  80096d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80096f:	85 f6                	test   %esi,%esi
  800971:	b8 6f 13 80 00       	mov    $0x80136f,%eax
  800976:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800979:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80097d:	7e 06                	jle    800985 <vprintfmt+0x2eb>
  80097f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800983:	75 13                	jne    800998 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800985:	0f be 06             	movsbl (%esi),%eax
  800988:	83 c6 01             	add    $0x1,%esi
  80098b:	85 c0                	test   %eax,%eax
  80098d:	0f 85 94 00 00 00    	jne    800a27 <vprintfmt+0x38d>
  800993:	e9 81 00 00 00       	jmp    800a19 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800998:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80099c:	89 34 24             	mov    %esi,(%esp)
  80099f:	e8 97 02 00 00       	call   800c3b <strnlen>
  8009a4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009a7:	29 c2                	sub    %eax,%edx
  8009a9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009ac:	85 d2                	test   %edx,%edx
  8009ae:	7e d5                	jle    800985 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009b0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009b4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009b7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	89 cf                	mov    %ecx,%edi
  8009be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c2:	89 3c 24             	mov    %edi,(%esp)
  8009c5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c8:	83 ee 01             	sub    $0x1,%esi
  8009cb:	75 f1                	jne    8009be <vprintfmt+0x324>
  8009cd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8009d0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8009d3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8009d6:	eb ad                	jmp    800985 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009d8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8009dc:	74 1b                	je     8009f9 <vprintfmt+0x35f>
  8009de:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009e1:	83 fa 5e             	cmp    $0x5e,%edx
  8009e4:	76 13                	jbe    8009f9 <vprintfmt+0x35f>
					putch('?', putdat);
  8009e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ed:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
  8009f7:	eb 0d                	jmp    800a06 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8009f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8009fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a00:	89 04 24             	mov    %eax,(%esp)
  800a03:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a06:	83 eb 01             	sub    $0x1,%ebx
  800a09:	0f be 06             	movsbl (%esi),%eax
  800a0c:	83 c6 01             	add    $0x1,%esi
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	75 1a                	jne    800a2d <vprintfmt+0x393>
  800a13:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a16:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a19:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a1c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a20:	7f 1c                	jg     800a3e <vprintfmt+0x3a4>
  800a22:	e9 96 fc ff ff       	jmp    8006bd <vprintfmt+0x23>
  800a27:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a2a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2d:	85 ff                	test   %edi,%edi
  800a2f:	78 a7                	js     8009d8 <vprintfmt+0x33e>
  800a31:	83 ef 01             	sub    $0x1,%edi
  800a34:	79 a2                	jns    8009d8 <vprintfmt+0x33e>
  800a36:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a39:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a3c:	eb db                	jmp    800a19 <vprintfmt+0x37f>
  800a3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a41:	89 de                	mov    %ebx,%esi
  800a43:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a51:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a53:	83 eb 01             	sub    $0x1,%ebx
  800a56:	75 ee                	jne    800a46 <vprintfmt+0x3ac>
  800a58:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a5d:	e9 5b fc ff ff       	jmp    8006bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a62:	83 f9 01             	cmp    $0x1,%ecx
  800a65:	7e 10                	jle    800a77 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	8d 50 08             	lea    0x8(%eax),%edx
  800a6d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a70:	8b 30                	mov    (%eax),%esi
  800a72:	8b 78 04             	mov    0x4(%eax),%edi
  800a75:	eb 26                	jmp    800a9d <vprintfmt+0x403>
	else if (lflag)
  800a77:	85 c9                	test   %ecx,%ecx
  800a79:	74 12                	je     800a8d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7e:	8d 50 04             	lea    0x4(%eax),%edx
  800a81:	89 55 14             	mov    %edx,0x14(%ebp)
  800a84:	8b 30                	mov    (%eax),%esi
  800a86:	89 f7                	mov    %esi,%edi
  800a88:	c1 ff 1f             	sar    $0x1f,%edi
  800a8b:	eb 10                	jmp    800a9d <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a90:	8d 50 04             	lea    0x4(%eax),%edx
  800a93:	89 55 14             	mov    %edx,0x14(%ebp)
  800a96:	8b 30                	mov    (%eax),%esi
  800a98:	89 f7                	mov    %esi,%edi
  800a9a:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a9d:	85 ff                	test   %edi,%edi
  800a9f:	78 0e                	js     800aaf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aa1:	89 f0                	mov    %esi,%eax
  800aa3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aa5:	be 0a 00 00 00       	mov    $0xa,%esi
  800aaa:	e9 84 00 00 00       	jmp    800b33 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800aaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800abd:	89 f0                	mov    %esi,%eax
  800abf:	89 fa                	mov    %edi,%edx
  800ac1:	f7 d8                	neg    %eax
  800ac3:	83 d2 00             	adc    $0x0,%edx
  800ac6:	f7 da                	neg    %edx
			}
			base = 10;
  800ac8:	be 0a 00 00 00       	mov    $0xa,%esi
  800acd:	eb 64                	jmp    800b33 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800acf:	89 ca                	mov    %ecx,%edx
  800ad1:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad4:	e8 42 fb ff ff       	call   80061b <getuint>
			base = 10;
  800ad9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800ade:	eb 53                	jmp    800b33 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ae0:	89 ca                	mov    %ecx,%edx
  800ae2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae5:	e8 31 fb ff ff       	call   80061b <getuint>
    			base = 8;
  800aea:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800aef:	eb 42                	jmp    800b33 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800af1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800afc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800aff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b03:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b0a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b10:	8d 50 04             	lea    0x4(%eax),%edx
  800b13:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b16:	8b 00                	mov    (%eax),%eax
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b1d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b22:	eb 0f                	jmp    800b33 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b24:	89 ca                	mov    %ecx,%edx
  800b26:	8d 45 14             	lea    0x14(%ebp),%eax
  800b29:	e8 ed fa ff ff       	call   80061b <getuint>
			base = 16;
  800b2e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b33:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b37:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b3b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b3e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b42:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b4d:	89 da                	mov    %ebx,%edx
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	e8 e9 f9 ff ff       	call   800540 <printnum>
			break;
  800b57:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b5a:	e9 5e fb ff ff       	jmp    8006bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b63:	89 14 24             	mov    %edx,(%esp)
  800b66:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b69:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b6c:	e9 4c fb ff ff       	jmp    8006bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b75:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b7c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b7f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b83:	0f 84 34 fb ff ff    	je     8006bd <vprintfmt+0x23>
  800b89:	83 ee 01             	sub    $0x1,%esi
  800b8c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b90:	75 f7                	jne    800b89 <vprintfmt+0x4ef>
  800b92:	e9 26 fb ff ff       	jmp    8006bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b97:	83 c4 5c             	add    $0x5c,%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 28             	sub    $0x28,%esp
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bb2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	74 30                	je     800bf0 <vsnprintf+0x51>
  800bc0:	85 d2                	test   %edx,%edx
  800bc2:	7e 2c                	jle    800bf0 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd9:	c7 04 24 55 06 80 00 	movl   $0x800655,(%esp)
  800be0:	e8 b5 fa ff ff       	call   80069a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bee:	eb 05                	jmp    800bf5 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bfd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c04:	8b 45 10             	mov    0x10(%ebp),%eax
  800c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	e8 82 ff ff ff       	call   800b9f <vsnprintf>
	va_end(ap);

	return rc;
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    
	...

00800c20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c2e:	74 09                	je     800c39 <strlen+0x19>
		n++;
  800c30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c37:	75 f7                	jne    800c30 <strlen+0x10>
		n++;
	return n;
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	53                   	push   %ebx
  800c3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4a:	85 c9                	test   %ecx,%ecx
  800c4c:	74 1a                	je     800c68 <strnlen+0x2d>
  800c4e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c51:	74 15                	je     800c68 <strnlen+0x2d>
  800c53:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c58:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5a:	39 ca                	cmp    %ecx,%edx
  800c5c:	74 0a                	je     800c68 <strnlen+0x2d>
  800c5e:	83 c2 01             	add    $0x1,%edx
  800c61:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c66:	75 f0                	jne    800c58 <strnlen+0x1d>
		n++;
	return n;
}
  800c68:	5b                   	pop    %ebx
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c7e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c81:	83 c2 01             	add    $0x1,%edx
  800c84:	84 c9                	test   %cl,%cl
  800c86:	75 f2                	jne    800c7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c88:	5b                   	pop    %ebx
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c95:	89 1c 24             	mov    %ebx,(%esp)
  800c98:	e8 83 ff ff ff       	call   800c20 <strlen>
	strcpy(dst + len, src);
  800c9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ca4:	01 d8                	add    %ebx,%eax
  800ca6:	89 04 24             	mov    %eax,(%esp)
  800ca9:	e8 bd ff ff ff       	call   800c6b <strcpy>
	return dst;
}
  800cae:	89 d8                	mov    %ebx,%eax
  800cb0:	83 c4 08             	add    $0x8,%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cc4:	85 f6                	test   %esi,%esi
  800cc6:	74 18                	je     800ce0 <strncpy+0x2a>
  800cc8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800ccd:	0f b6 1a             	movzbl (%edx),%ebx
  800cd0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cd3:	80 3a 01             	cmpb   $0x1,(%edx)
  800cd6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd9:	83 c1 01             	add    $0x1,%ecx
  800cdc:	39 f1                	cmp    %esi,%ecx
  800cde:	75 ed                	jne    800ccd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cf0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf3:	89 f8                	mov    %edi,%eax
  800cf5:	85 f6                	test   %esi,%esi
  800cf7:	74 2b                	je     800d24 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800cf9:	83 fe 01             	cmp    $0x1,%esi
  800cfc:	74 23                	je     800d21 <strlcpy+0x3d>
  800cfe:	0f b6 0b             	movzbl (%ebx),%ecx
  800d01:	84 c9                	test   %cl,%cl
  800d03:	74 1c                	je     800d21 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d05:	83 ee 02             	sub    $0x2,%esi
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d0d:	88 08                	mov    %cl,(%eax)
  800d0f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d12:	39 f2                	cmp    %esi,%edx
  800d14:	74 0b                	je     800d21 <strlcpy+0x3d>
  800d16:	83 c2 01             	add    $0x1,%edx
  800d19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d1d:	84 c9                	test   %cl,%cl
  800d1f:	75 ec                	jne    800d0d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d21:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d24:	29 f8                	sub    %edi,%eax
}
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d34:	0f b6 01             	movzbl (%ecx),%eax
  800d37:	84 c0                	test   %al,%al
  800d39:	74 16                	je     800d51 <strcmp+0x26>
  800d3b:	3a 02                	cmp    (%edx),%al
  800d3d:	75 12                	jne    800d51 <strcmp+0x26>
		p++, q++;
  800d3f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d42:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d46:	84 c0                	test   %al,%al
  800d48:	74 07                	je     800d51 <strcmp+0x26>
  800d4a:	83 c1 01             	add    $0x1,%ecx
  800d4d:	3a 02                	cmp    (%edx),%al
  800d4f:	74 ee                	je     800d3f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d51:	0f b6 c0             	movzbl %al,%eax
  800d54:	0f b6 12             	movzbl (%edx),%edx
  800d57:	29 d0                	sub    %edx,%eax
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	53                   	push   %ebx
  800d5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d68:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d6d:	85 d2                	test   %edx,%edx
  800d6f:	74 28                	je     800d99 <strncmp+0x3e>
  800d71:	0f b6 01             	movzbl (%ecx),%eax
  800d74:	84 c0                	test   %al,%al
  800d76:	74 24                	je     800d9c <strncmp+0x41>
  800d78:	3a 03                	cmp    (%ebx),%al
  800d7a:	75 20                	jne    800d9c <strncmp+0x41>
  800d7c:	83 ea 01             	sub    $0x1,%edx
  800d7f:	74 13                	je     800d94 <strncmp+0x39>
		n--, p++, q++;
  800d81:	83 c1 01             	add    $0x1,%ecx
  800d84:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d87:	0f b6 01             	movzbl (%ecx),%eax
  800d8a:	84 c0                	test   %al,%al
  800d8c:	74 0e                	je     800d9c <strncmp+0x41>
  800d8e:	3a 03                	cmp    (%ebx),%al
  800d90:	74 ea                	je     800d7c <strncmp+0x21>
  800d92:	eb 08                	jmp    800d9c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d94:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9c:	0f b6 01             	movzbl (%ecx),%eax
  800d9f:	0f b6 13             	movzbl (%ebx),%edx
  800da2:	29 d0                	sub    %edx,%eax
  800da4:	eb f3                	jmp    800d99 <strncmp+0x3e>

00800da6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800db0:	0f b6 10             	movzbl (%eax),%edx
  800db3:	84 d2                	test   %dl,%dl
  800db5:	74 1c                	je     800dd3 <strchr+0x2d>
		if (*s == c)
  800db7:	38 ca                	cmp    %cl,%dl
  800db9:	75 09                	jne    800dc4 <strchr+0x1e>
  800dbb:	eb 1b                	jmp    800dd8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dbd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800dc0:	38 ca                	cmp    %cl,%dl
  800dc2:	74 14                	je     800dd8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dc4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800dc8:	84 d2                	test   %dl,%dl
  800dca:	75 f1                	jne    800dbd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd1:	eb 05                	jmp    800dd8 <strchr+0x32>
  800dd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de4:	0f b6 10             	movzbl (%eax),%edx
  800de7:	84 d2                	test   %dl,%dl
  800de9:	74 14                	je     800dff <strfind+0x25>
		if (*s == c)
  800deb:	38 ca                	cmp    %cl,%dl
  800ded:	75 06                	jne    800df5 <strfind+0x1b>
  800def:	eb 0e                	jmp    800dff <strfind+0x25>
  800df1:	38 ca                	cmp    %cl,%dl
  800df3:	74 0a                	je     800dff <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800df5:	83 c0 01             	add    $0x1,%eax
  800df8:	0f b6 10             	movzbl (%eax),%edx
  800dfb:	84 d2                	test   %dl,%dl
  800dfd:	75 f2                	jne    800df1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e19:	85 c9                	test   %ecx,%ecx
  800e1b:	74 30                	je     800e4d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e23:	75 25                	jne    800e4a <memset+0x49>
  800e25:	f6 c1 03             	test   $0x3,%cl
  800e28:	75 20                	jne    800e4a <memset+0x49>
		c &= 0xFF;
  800e2a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e2d:	89 d3                	mov    %edx,%ebx
  800e2f:	c1 e3 08             	shl    $0x8,%ebx
  800e32:	89 d6                	mov    %edx,%esi
  800e34:	c1 e6 18             	shl    $0x18,%esi
  800e37:	89 d0                	mov    %edx,%eax
  800e39:	c1 e0 10             	shl    $0x10,%eax
  800e3c:	09 f0                	or     %esi,%eax
  800e3e:	09 d0                	or     %edx,%eax
  800e40:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e42:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e45:	fc                   	cld    
  800e46:	f3 ab                	rep stos %eax,%es:(%edi)
  800e48:	eb 03                	jmp    800e4d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e4a:	fc                   	cld    
  800e4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e4d:	89 f8                	mov    %edi,%eax
  800e4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e58:	89 ec                	mov    %ebp,%esp
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e65:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e71:	39 c6                	cmp    %eax,%esi
  800e73:	73 36                	jae    800eab <memmove+0x4f>
  800e75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e78:	39 d0                	cmp    %edx,%eax
  800e7a:	73 2f                	jae    800eab <memmove+0x4f>
		s += n;
		d += n;
  800e7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e7f:	f6 c2 03             	test   $0x3,%dl
  800e82:	75 1b                	jne    800e9f <memmove+0x43>
  800e84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e8a:	75 13                	jne    800e9f <memmove+0x43>
  800e8c:	f6 c1 03             	test   $0x3,%cl
  800e8f:	75 0e                	jne    800e9f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e91:	83 ef 04             	sub    $0x4,%edi
  800e94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e97:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e9a:	fd                   	std    
  800e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e9d:	eb 09                	jmp    800ea8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e9f:	83 ef 01             	sub    $0x1,%edi
  800ea2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ea5:	fd                   	std    
  800ea6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ea8:	fc                   	cld    
  800ea9:	eb 20                	jmp    800ecb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eb1:	75 13                	jne    800ec6 <memmove+0x6a>
  800eb3:	a8 03                	test   $0x3,%al
  800eb5:	75 0f                	jne    800ec6 <memmove+0x6a>
  800eb7:	f6 c1 03             	test   $0x3,%cl
  800eba:	75 0a                	jne    800ec6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ebc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ebf:	89 c7                	mov    %eax,%edi
  800ec1:	fc                   	cld    
  800ec2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec4:	eb 05                	jmp    800ecb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ec6:	89 c7                	mov    %eax,%edi
  800ec8:	fc                   	cld    
  800ec9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ecb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ece:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed1:	89 ec                	mov    %ebp,%esp
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800edb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ede:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	89 04 24             	mov    %eax,(%esp)
  800eef:	e8 68 ff ff ff       	call   800e5c <memmove>
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f02:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f0a:	85 ff                	test   %edi,%edi
  800f0c:	74 37                	je     800f45 <memcmp+0x4f>
		if (*s1 != *s2)
  800f0e:	0f b6 03             	movzbl (%ebx),%eax
  800f11:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f14:	83 ef 01             	sub    $0x1,%edi
  800f17:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f1c:	38 c8                	cmp    %cl,%al
  800f1e:	74 1c                	je     800f3c <memcmp+0x46>
  800f20:	eb 10                	jmp    800f32 <memcmp+0x3c>
  800f22:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f27:	83 c2 01             	add    $0x1,%edx
  800f2a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f2e:	38 c8                	cmp    %cl,%al
  800f30:	74 0a                	je     800f3c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f32:	0f b6 c0             	movzbl %al,%eax
  800f35:	0f b6 c9             	movzbl %cl,%ecx
  800f38:	29 c8                	sub    %ecx,%eax
  800f3a:	eb 09                	jmp    800f45 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f3c:	39 fa                	cmp    %edi,%edx
  800f3e:	75 e2                	jne    800f22 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f50:	89 c2                	mov    %eax,%edx
  800f52:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f55:	39 d0                	cmp    %edx,%eax
  800f57:	73 19                	jae    800f72 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f5d:	38 08                	cmp    %cl,(%eax)
  800f5f:	75 06                	jne    800f67 <memfind+0x1d>
  800f61:	eb 0f                	jmp    800f72 <memfind+0x28>
  800f63:	38 08                	cmp    %cl,(%eax)
  800f65:	74 0b                	je     800f72 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f67:	83 c0 01             	add    $0x1,%eax
  800f6a:	39 d0                	cmp    %edx,%eax
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	75 f1                	jne    800f63 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f80:	0f b6 02             	movzbl (%edx),%eax
  800f83:	3c 20                	cmp    $0x20,%al
  800f85:	74 04                	je     800f8b <strtol+0x17>
  800f87:	3c 09                	cmp    $0x9,%al
  800f89:	75 0e                	jne    800f99 <strtol+0x25>
		s++;
  800f8b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f8e:	0f b6 02             	movzbl (%edx),%eax
  800f91:	3c 20                	cmp    $0x20,%al
  800f93:	74 f6                	je     800f8b <strtol+0x17>
  800f95:	3c 09                	cmp    $0x9,%al
  800f97:	74 f2                	je     800f8b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f99:	3c 2b                	cmp    $0x2b,%al
  800f9b:	75 0a                	jne    800fa7 <strtol+0x33>
		s++;
  800f9d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fa0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa5:	eb 10                	jmp    800fb7 <strtol+0x43>
  800fa7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fac:	3c 2d                	cmp    $0x2d,%al
  800fae:	75 07                	jne    800fb7 <strtol+0x43>
		s++, neg = 1;
  800fb0:	83 c2 01             	add    $0x1,%edx
  800fb3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fb7:	85 db                	test   %ebx,%ebx
  800fb9:	0f 94 c0             	sete   %al
  800fbc:	74 05                	je     800fc3 <strtol+0x4f>
  800fbe:	83 fb 10             	cmp    $0x10,%ebx
  800fc1:	75 15                	jne    800fd8 <strtol+0x64>
  800fc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fc6:	75 10                	jne    800fd8 <strtol+0x64>
  800fc8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fcc:	75 0a                	jne    800fd8 <strtol+0x64>
		s += 2, base = 16;
  800fce:	83 c2 02             	add    $0x2,%edx
  800fd1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fd6:	eb 13                	jmp    800feb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800fd8:	84 c0                	test   %al,%al
  800fda:	74 0f                	je     800feb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fdc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fe1:	80 3a 30             	cmpb   $0x30,(%edx)
  800fe4:	75 05                	jne    800feb <strtol+0x77>
		s++, base = 8;
  800fe6:	83 c2 01             	add    $0x1,%edx
  800fe9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ff2:	0f b6 0a             	movzbl (%edx),%ecx
  800ff5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ff8:	80 fb 09             	cmp    $0x9,%bl
  800ffb:	77 08                	ja     801005 <strtol+0x91>
			dig = *s - '0';
  800ffd:	0f be c9             	movsbl %cl,%ecx
  801000:	83 e9 30             	sub    $0x30,%ecx
  801003:	eb 1e                	jmp    801023 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801005:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801008:	80 fb 19             	cmp    $0x19,%bl
  80100b:	77 08                	ja     801015 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80100d:	0f be c9             	movsbl %cl,%ecx
  801010:	83 e9 57             	sub    $0x57,%ecx
  801013:	eb 0e                	jmp    801023 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801015:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801018:	80 fb 19             	cmp    $0x19,%bl
  80101b:	77 14                	ja     801031 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80101d:	0f be c9             	movsbl %cl,%ecx
  801020:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801023:	39 f1                	cmp    %esi,%ecx
  801025:	7d 0e                	jge    801035 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801027:	83 c2 01             	add    $0x1,%edx
  80102a:	0f af c6             	imul   %esi,%eax
  80102d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80102f:	eb c1                	jmp    800ff2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801031:	89 c1                	mov    %eax,%ecx
  801033:	eb 02                	jmp    801037 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801035:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801037:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80103b:	74 05                	je     801042 <strtol+0xce>
		*endptr = (char *) s;
  80103d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801040:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801042:	89 ca                	mov    %ecx,%edx
  801044:	f7 da                	neg    %edx
  801046:	85 ff                	test   %edi,%edi
  801048:	0f 45 c2             	cmovne %edx,%eax
}
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <__udivdi3>:
  801050:	83 ec 1c             	sub    $0x1c,%esp
  801053:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801057:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80105b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80105f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801063:	89 74 24 10          	mov    %esi,0x10(%esp)
  801067:	8b 74 24 24          	mov    0x24(%esp),%esi
  80106b:	85 ff                	test   %edi,%edi
  80106d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801071:	89 44 24 08          	mov    %eax,0x8(%esp)
  801075:	89 cd                	mov    %ecx,%ebp
  801077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107b:	75 33                	jne    8010b0 <__udivdi3+0x60>
  80107d:	39 f1                	cmp    %esi,%ecx
  80107f:	77 57                	ja     8010d8 <__udivdi3+0x88>
  801081:	85 c9                	test   %ecx,%ecx
  801083:	75 0b                	jne    801090 <__udivdi3+0x40>
  801085:	b8 01 00 00 00       	mov    $0x1,%eax
  80108a:	31 d2                	xor    %edx,%edx
  80108c:	f7 f1                	div    %ecx
  80108e:	89 c1                	mov    %eax,%ecx
  801090:	89 f0                	mov    %esi,%eax
  801092:	31 d2                	xor    %edx,%edx
  801094:	f7 f1                	div    %ecx
  801096:	89 c6                	mov    %eax,%esi
  801098:	8b 44 24 04          	mov    0x4(%esp),%eax
  80109c:	f7 f1                	div    %ecx
  80109e:	89 f2                	mov    %esi,%edx
  8010a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ac:	83 c4 1c             	add    $0x1c,%esp
  8010af:	c3                   	ret    
  8010b0:	31 d2                	xor    %edx,%edx
  8010b2:	31 c0                	xor    %eax,%eax
  8010b4:	39 f7                	cmp    %esi,%edi
  8010b6:	77 e8                	ja     8010a0 <__udivdi3+0x50>
  8010b8:	0f bd cf             	bsr    %edi,%ecx
  8010bb:	83 f1 1f             	xor    $0x1f,%ecx
  8010be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010c2:	75 2c                	jne    8010f0 <__udivdi3+0xa0>
  8010c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010c8:	76 04                	jbe    8010ce <__udivdi3+0x7e>
  8010ca:	39 f7                	cmp    %esi,%edi
  8010cc:	73 d2                	jae    8010a0 <__udivdi3+0x50>
  8010ce:	31 d2                	xor    %edx,%edx
  8010d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d5:	eb c9                	jmp    8010a0 <__udivdi3+0x50>
  8010d7:	90                   	nop
  8010d8:	89 f2                	mov    %esi,%edx
  8010da:	f7 f1                	div    %ecx
  8010dc:	31 d2                	xor    %edx,%edx
  8010de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ea:	83 c4 1c             	add    $0x1c,%esp
  8010ed:	c3                   	ret    
  8010ee:	66 90                	xchg   %ax,%ax
  8010f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010fa:	89 ea                	mov    %ebp,%edx
  8010fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801100:	d3 e7                	shl    %cl,%edi
  801102:	89 c1                	mov    %eax,%ecx
  801104:	d3 ea                	shr    %cl,%edx
  801106:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110b:	09 fa                	or     %edi,%edx
  80110d:	89 f7                	mov    %esi,%edi
  80110f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801113:	89 f2                	mov    %esi,%edx
  801115:	8b 74 24 08          	mov    0x8(%esp),%esi
  801119:	d3 e5                	shl    %cl,%ebp
  80111b:	89 c1                	mov    %eax,%ecx
  80111d:	d3 ef                	shr    %cl,%edi
  80111f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801124:	d3 e2                	shl    %cl,%edx
  801126:	89 c1                	mov    %eax,%ecx
  801128:	d3 ee                	shr    %cl,%esi
  80112a:	09 d6                	or     %edx,%esi
  80112c:	89 fa                	mov    %edi,%edx
  80112e:	89 f0                	mov    %esi,%eax
  801130:	f7 74 24 0c          	divl   0xc(%esp)
  801134:	89 d7                	mov    %edx,%edi
  801136:	89 c6                	mov    %eax,%esi
  801138:	f7 e5                	mul    %ebp
  80113a:	39 d7                	cmp    %edx,%edi
  80113c:	72 22                	jb     801160 <__udivdi3+0x110>
  80113e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801142:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801147:	d3 e5                	shl    %cl,%ebp
  801149:	39 c5                	cmp    %eax,%ebp
  80114b:	73 04                	jae    801151 <__udivdi3+0x101>
  80114d:	39 d7                	cmp    %edx,%edi
  80114f:	74 0f                	je     801160 <__udivdi3+0x110>
  801151:	89 f0                	mov    %esi,%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	e9 46 ff ff ff       	jmp    8010a0 <__udivdi3+0x50>
  80115a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801160:	8d 46 ff             	lea    -0x1(%esi),%eax
  801163:	31 d2                	xor    %edx,%edx
  801165:	8b 74 24 10          	mov    0x10(%esp),%esi
  801169:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80116d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801171:	83 c4 1c             	add    $0x1c,%esp
  801174:	c3                   	ret    
	...

00801180 <__umoddi3>:
  801180:	83 ec 1c             	sub    $0x1c,%esp
  801183:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801187:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80118b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80118f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801193:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801197:	8b 74 24 24          	mov    0x24(%esp),%esi
  80119b:	85 ed                	test   %ebp,%ebp
  80119d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a5:	89 cf                	mov    %ecx,%edi
  8011a7:	89 04 24             	mov    %eax,(%esp)
  8011aa:	89 f2                	mov    %esi,%edx
  8011ac:	75 1a                	jne    8011c8 <__umoddi3+0x48>
  8011ae:	39 f1                	cmp    %esi,%ecx
  8011b0:	76 4e                	jbe    801200 <__umoddi3+0x80>
  8011b2:	f7 f1                	div    %ecx
  8011b4:	89 d0                	mov    %edx,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c4:	83 c4 1c             	add    $0x1c,%esp
  8011c7:	c3                   	ret    
  8011c8:	39 f5                	cmp    %esi,%ebp
  8011ca:	77 54                	ja     801220 <__umoddi3+0xa0>
  8011cc:	0f bd c5             	bsr    %ebp,%eax
  8011cf:	83 f0 1f             	xor    $0x1f,%eax
  8011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d6:	75 60                	jne    801238 <__umoddi3+0xb8>
  8011d8:	3b 0c 24             	cmp    (%esp),%ecx
  8011db:	0f 87 07 01 00 00    	ja     8012e8 <__umoddi3+0x168>
  8011e1:	89 f2                	mov    %esi,%edx
  8011e3:	8b 34 24             	mov    (%esp),%esi
  8011e6:	29 ce                	sub    %ecx,%esi
  8011e8:	19 ea                	sbb    %ebp,%edx
  8011ea:	89 34 24             	mov    %esi,(%esp)
  8011ed:	8b 04 24             	mov    (%esp),%eax
  8011f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011fc:	83 c4 1c             	add    $0x1c,%esp
  8011ff:	c3                   	ret    
  801200:	85 c9                	test   %ecx,%ecx
  801202:	75 0b                	jne    80120f <__umoddi3+0x8f>
  801204:	b8 01 00 00 00       	mov    $0x1,%eax
  801209:	31 d2                	xor    %edx,%edx
  80120b:	f7 f1                	div    %ecx
  80120d:	89 c1                	mov    %eax,%ecx
  80120f:	89 f0                	mov    %esi,%eax
  801211:	31 d2                	xor    %edx,%edx
  801213:	f7 f1                	div    %ecx
  801215:	8b 04 24             	mov    (%esp),%eax
  801218:	f7 f1                	div    %ecx
  80121a:	eb 98                	jmp    8011b4 <__umoddi3+0x34>
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 f2                	mov    %esi,%edx
  801222:	8b 74 24 10          	mov    0x10(%esp),%esi
  801226:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80122a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80122e:	83 c4 1c             	add    $0x1c,%esp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80123d:	89 e8                	mov    %ebp,%eax
  80123f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801244:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801248:	89 fa                	mov    %edi,%edx
  80124a:	d3 e0                	shl    %cl,%eax
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	d3 ea                	shr    %cl,%edx
  801250:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801255:	09 c2                	or     %eax,%edx
  801257:	8b 44 24 08          	mov    0x8(%esp),%eax
  80125b:	89 14 24             	mov    %edx,(%esp)
  80125e:	89 f2                	mov    %esi,%edx
  801260:	d3 e7                	shl    %cl,%edi
  801262:	89 e9                	mov    %ebp,%ecx
  801264:	d3 ea                	shr    %cl,%edx
  801266:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80126f:	d3 e6                	shl    %cl,%esi
  801271:	89 e9                	mov    %ebp,%ecx
  801273:	d3 e8                	shr    %cl,%eax
  801275:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80127a:	09 f0                	or     %esi,%eax
  80127c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801280:	f7 34 24             	divl   (%esp)
  801283:	d3 e6                	shl    %cl,%esi
  801285:	89 74 24 08          	mov    %esi,0x8(%esp)
  801289:	89 d6                	mov    %edx,%esi
  80128b:	f7 e7                	mul    %edi
  80128d:	39 d6                	cmp    %edx,%esi
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	89 d7                	mov    %edx,%edi
  801293:	72 3f                	jb     8012d4 <__umoddi3+0x154>
  801295:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801299:	72 35                	jb     8012d0 <__umoddi3+0x150>
  80129b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80129f:	29 c8                	sub    %ecx,%eax
  8012a1:	19 fe                	sbb    %edi,%esi
  8012a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a8:	89 f2                	mov    %esi,%edx
  8012aa:	d3 e8                	shr    %cl,%eax
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 e2                	shl    %cl,%edx
  8012b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012b5:	09 d0                	or     %edx,%eax
  8012b7:	89 f2                	mov    %esi,%edx
  8012b9:	d3 ea                	shr    %cl,%edx
  8012bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012c7:	83 c4 1c             	add    $0x1c,%esp
  8012ca:	c3                   	ret    
  8012cb:	90                   	nop
  8012cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	39 d6                	cmp    %edx,%esi
  8012d2:	75 c7                	jne    80129b <__umoddi3+0x11b>
  8012d4:	89 d7                	mov    %edx,%edi
  8012d6:	89 c1                	mov    %eax,%ecx
  8012d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012dc:	1b 3c 24             	sbb    (%esp),%edi
  8012df:	eb ba                	jmp    80129b <__umoddi3+0x11b>
  8012e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	39 f5                	cmp    %esi,%ebp
  8012ea:	0f 82 f1 fe ff ff    	jb     8011e1 <__umoddi3+0x61>
  8012f0:	e9 f8 fe ff ff       	jmp    8011ed <__umoddi3+0x6d>
