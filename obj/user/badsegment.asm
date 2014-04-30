
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
  80005c:	c1 e0 07             	shl    $0x7,%eax
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
  800137:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  80014e:	e8 09 03 00 00       	call   80045c <_panic>

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
  8001f6:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800205:	00 
  800206:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  80020d:	e8 4a 02 00 00       	call   80045c <_panic>

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
  800254:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  80025b:	00 
  80025c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800263:	00 
  800264:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  80026b:	e8 ec 01 00 00       	call   80045c <_panic>

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
  8002b2:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  8002c9:	e8 8e 01 00 00       	call   80045c <_panic>

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
  800310:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800317:	00 
  800318:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031f:	00 
  800320:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800327:	e8 30 01 00 00       	call   80045c <_panic>

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
  80036e:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800375:	00 
  800376:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800385:	e8 d2 00 00 00       	call   80045c <_panic>

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
  8003ff:	c7 44 24 08 4a 13 80 	movl   $0x80134a,0x8(%esp)
  800406:	00 
  800407:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80040e:	00 
  80040f:	c7 04 24 67 13 80 00 	movl   $0x801367,(%esp)
  800416:	e8 41 00 00 00       	call   80045c <_panic>

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

00800428 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 0c             	sub    $0xc,%esp
  80042e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800431:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800434:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800437:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800441:	8b 55 08             	mov    0x8(%ebp),%edx
  800444:	89 cb                	mov    %ecx,%ebx
  800446:	89 cf                	mov    %ecx,%edi
  800448:	89 ce                	mov    %ecx,%esi
  80044a:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  80044c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80044f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800452:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800455:	89 ec                	mov    %ebp,%esp
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    
  800459:	00 00                	add    %al,(%eax)
	...

0080045c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	56                   	push   %esi
  800460:	53                   	push   %ebx
  800461:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800464:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800467:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80046d:	e8 ee fc ff ff       	call   800160 <sys_getenvid>
  800472:	8b 55 0c             	mov    0xc(%ebp),%edx
  800475:	89 54 24 10          	mov    %edx,0x10(%esp)
  800479:	8b 55 08             	mov    0x8(%ebp),%edx
  80047c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800480:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800484:	89 44 24 04          	mov    %eax,0x4(%esp)
  800488:	c7 04 24 78 13 80 00 	movl   $0x801378,(%esp)
  80048f:	e8 c3 00 00 00       	call   800557 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800494:	89 74 24 04          	mov    %esi,0x4(%esp)
  800498:	8b 45 10             	mov    0x10(%ebp),%eax
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	e8 53 00 00 00       	call   8004f6 <vcprintf>
	cprintf("\n");
  8004a3:	c7 04 24 9c 13 80 00 	movl   $0x80139c,(%esp)
  8004aa:	e8 a8 00 00 00       	call   800557 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004af:	cc                   	int3   
  8004b0:	eb fd                	jmp    8004af <_panic+0x53>
	...

008004b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	53                   	push   %ebx
  8004b8:	83 ec 14             	sub    $0x14,%esp
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004be:	8b 03                	mov    (%ebx),%eax
  8004c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004c7:	83 c0 01             	add    $0x1,%eax
  8004ca:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004d1:	75 19                	jne    8004ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004da:	00 
  8004db:	8d 43 08             	lea    0x8(%ebx),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	e8 be fb ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8004e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004f0:	83 c4 14             	add    $0x14,%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    

008004f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800506:	00 00 00 
	b.cnt = 0;
  800509:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800510:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800513:	8b 45 0c             	mov    0xc(%ebp),%eax
  800516:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800521:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052b:	c7 04 24 b4 04 80 00 	movl   $0x8004b4,(%esp)
  800532:	e8 97 01 00 00       	call   8006ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800537:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80053d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800541:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	e8 55 fb ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  80054f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800555:	c9                   	leave  
  800556:	c3                   	ret    

00800557 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800557:	55                   	push   %ebp
  800558:	89 e5                	mov    %esp,%ebp
  80055a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80055d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800560:	89 44 24 04          	mov    %eax,0x4(%esp)
  800564:	8b 45 08             	mov    0x8(%ebp),%eax
  800567:	89 04 24             	mov    %eax,(%esp)
  80056a:	e8 87 ff ff ff       	call   8004f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80056f:	c9                   	leave  
  800570:	c3                   	ret    
  800571:	00 00                	add    %al,(%eax)
	...

00800574 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 3c             	sub    $0x3c,%esp
  80057d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800580:	89 d7                	mov    %edx,%edi
  800582:	8b 45 08             	mov    0x8(%ebp),%eax
  800585:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800591:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800594:	b8 00 00 00 00       	mov    $0x0,%eax
  800599:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80059c:	72 11                	jb     8005af <printnum+0x3b>
  80059e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005a4:	76 09                	jbe    8005af <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005a6:	83 eb 01             	sub    $0x1,%ebx
  8005a9:	85 db                	test   %ebx,%ebx
  8005ab:	7f 51                	jg     8005fe <printnum+0x8a>
  8005ad:	eb 5e                	jmp    80060d <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005b3:	83 eb 01             	sub    $0x1,%ebx
  8005b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005c5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d0:	00 
  8005d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005de:	e8 ad 0a 00 00       	call   801090 <__udivdi3>
  8005e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f2:	89 fa                	mov    %edi,%edx
  8005f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f7:	e8 78 ff ff ff       	call   800574 <printnum>
  8005fc:	eb 0f                	jmp    80060d <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800602:	89 34 24             	mov    %esi,(%esp)
  800605:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	75 f1                	jne    8005fe <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80060d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800611:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800615:	8b 45 10             	mov    0x10(%ebp),%eax
  800618:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800623:	00 
  800624:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800631:	e8 8a 0b 00 00       	call   8011c0 <__umoddi3>
  800636:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063a:	0f be 80 9e 13 80 00 	movsbl 0x80139e(%eax),%eax
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800647:	83 c4 3c             	add    $0x3c,%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800652:	83 fa 01             	cmp    $0x1,%edx
  800655:	7e 0e                	jle    800665 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800657:	8b 10                	mov    (%eax),%edx
  800659:	8d 4a 08             	lea    0x8(%edx),%ecx
  80065c:	89 08                	mov    %ecx,(%eax)
  80065e:	8b 02                	mov    (%edx),%eax
  800660:	8b 52 04             	mov    0x4(%edx),%edx
  800663:	eb 22                	jmp    800687 <getuint+0x38>
	else if (lflag)
  800665:	85 d2                	test   %edx,%edx
  800667:	74 10                	je     800679 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80066e:	89 08                	mov    %ecx,(%eax)
  800670:	8b 02                	mov    (%edx),%eax
  800672:	ba 00 00 00 00       	mov    $0x0,%edx
  800677:	eb 0e                	jmp    800687 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067e:	89 08                	mov    %ecx,(%eax)
  800680:	8b 02                	mov    (%edx),%eax
  800682:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80068f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800693:	8b 10                	mov    (%eax),%edx
  800695:	3b 50 04             	cmp    0x4(%eax),%edx
  800698:	73 0a                	jae    8006a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80069a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069d:	88 0a                	mov    %cl,(%edx)
  80069f:	83 c2 01             	add    $0x1,%edx
  8006a2:	89 10                	mov    %edx,(%eax)
}
  8006a4:	5d                   	pop    %ebp
  8006a5:	c3                   	ret    

008006a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	e8 02 00 00 00       	call   8006ce <vprintfmt>
	va_end(ap);
}
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	57                   	push   %edi
  8006d2:	56                   	push   %esi
  8006d3:	53                   	push   %ebx
  8006d4:	83 ec 5c             	sub    $0x5c,%esp
  8006d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006da:	8b 75 10             	mov    0x10(%ebp),%esi
  8006dd:	eb 12                	jmp    8006f1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	0f 84 e4 04 00 00    	je     800bcb <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f1:	0f b6 06             	movzbl (%esi),%eax
  8006f4:	83 c6 01             	add    $0x1,%esi
  8006f7:	83 f8 25             	cmp    $0x25,%eax
  8006fa:	75 e3                	jne    8006df <vprintfmt+0x11>
  8006fc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800700:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800707:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80070c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800713:	b9 00 00 00 00       	mov    $0x0,%ecx
  800718:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80071b:	eb 2b                	jmp    800748 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800720:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800724:	eb 22                	jmp    800748 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800729:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80072d:	eb 19                	jmp    800748 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800732:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800739:	eb 0d                	jmp    800748 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80073b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80073e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800741:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800748:	0f b6 06             	movzbl (%esi),%eax
  80074b:	0f b6 d0             	movzbl %al,%edx
  80074e:	8d 7e 01             	lea    0x1(%esi),%edi
  800751:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800754:	83 e8 23             	sub    $0x23,%eax
  800757:	3c 55                	cmp    $0x55,%al
  800759:	0f 87 46 04 00 00    	ja     800ba5 <vprintfmt+0x4d7>
  80075f:	0f b6 c0             	movzbl %al,%eax
  800762:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800769:	83 ea 30             	sub    $0x30,%edx
  80076c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80076f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800773:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800779:	83 fa 09             	cmp    $0x9,%edx
  80077c:	77 4a                	ja     8007c8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800781:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800784:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800787:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80078b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80078e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800791:	83 fa 09             	cmp    $0x9,%edx
  800794:	76 eb                	jbe    800781 <vprintfmt+0xb3>
  800796:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800799:	eb 2d                	jmp    8007c8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 04             	lea    0x4(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007ac:	eb 1a                	jmp    8007c8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007b1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007b5:	79 91                	jns    800748 <vprintfmt+0x7a>
  8007b7:	e9 73 ff ff ff       	jmp    80072f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bf:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007c6:	eb 80                	jmp    800748 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007cc:	0f 89 76 ff ff ff    	jns    800748 <vprintfmt+0x7a>
  8007d2:	e9 64 ff ff ff       	jmp    80073b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007da:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007dd:	e9 66 ff ff ff       	jmp    800748 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ef:	8b 00                	mov    (%eax),%eax
  8007f1:	89 04 24             	mov    %eax,(%esp)
  8007f4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007fa:	e9 f2 fe ff ff       	jmp    8006f1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007ff:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800803:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  800806:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80080a:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  80080d:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800811:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800814:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  800817:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80081b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80081e:	80 f9 09             	cmp    $0x9,%cl
  800821:	77 1d                	ja     800840 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800823:	0f be c0             	movsbl %al,%eax
  800826:	6b c0 64             	imul   $0x64,%eax,%eax
  800829:	0f be d2             	movsbl %dl,%edx
  80082c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80082f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800836:	a3 04 20 80 00       	mov    %eax,0x802004
  80083b:	e9 b1 fe ff ff       	jmp    8006f1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800840:	c7 44 24 04 b6 13 80 	movl   $0x8013b6,0x4(%esp)
  800847:	00 
  800848:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 18 05 00 00       	call   800d6b <strcmp>
  800853:	85 c0                	test   %eax,%eax
  800855:	75 0f                	jne    800866 <vprintfmt+0x198>
  800857:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80085e:	00 00 00 
  800861:	e9 8b fe ff ff       	jmp    8006f1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800866:	c7 44 24 04 ba 13 80 	movl   $0x8013ba,0x4(%esp)
  80086d:	00 
  80086e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800871:	89 14 24             	mov    %edx,(%esp)
  800874:	e8 f2 04 00 00       	call   800d6b <strcmp>
  800879:	85 c0                	test   %eax,%eax
  80087b:	75 0f                	jne    80088c <vprintfmt+0x1be>
  80087d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800884:	00 00 00 
  800887:	e9 65 fe ff ff       	jmp    8006f1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80088c:	c7 44 24 04 be 13 80 	movl   $0x8013be,0x4(%esp)
  800893:	00 
  800894:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800897:	89 0c 24             	mov    %ecx,(%esp)
  80089a:	e8 cc 04 00 00       	call   800d6b <strcmp>
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	75 0f                	jne    8008b2 <vprintfmt+0x1e4>
  8008a3:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8008aa:	00 00 00 
  8008ad:	e9 3f fe ff ff       	jmp    8006f1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008b2:	c7 44 24 04 c2 13 80 	movl   $0x8013c2,0x4(%esp)
  8008b9:	00 
  8008ba:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008bd:	89 3c 24             	mov    %edi,(%esp)
  8008c0:	e8 a6 04 00 00       	call   800d6b <strcmp>
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	75 0f                	jne    8008d8 <vprintfmt+0x20a>
  8008c9:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008d0:	00 00 00 
  8008d3:	e9 19 fe ff ff       	jmp    8006f1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008d8:	c7 44 24 04 c6 13 80 	movl   $0x8013c6,0x4(%esp)
  8008df:	00 
  8008e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008e3:	89 04 24             	mov    %eax,(%esp)
  8008e6:	e8 80 04 00 00       	call   800d6b <strcmp>
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	75 0f                	jne    8008fe <vprintfmt+0x230>
  8008ef:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008f6:	00 00 00 
  8008f9:	e9 f3 fd ff ff       	jmp    8006f1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008fe:	c7 44 24 04 ca 13 80 	movl   $0x8013ca,0x4(%esp)
  800905:	00 
  800906:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800909:	89 14 24             	mov    %edx,(%esp)
  80090c:	e8 5a 04 00 00       	call   800d6b <strcmp>
  800911:	83 f8 01             	cmp    $0x1,%eax
  800914:	19 c0                	sbb    %eax,%eax
  800916:	f7 d0                	not    %eax
  800918:	83 c0 08             	add    $0x8,%eax
  80091b:	a3 04 20 80 00       	mov    %eax,0x802004
  800920:	e9 cc fd ff ff       	jmp    8006f1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8d 50 04             	lea    0x4(%eax),%edx
  80092b:	89 55 14             	mov    %edx,0x14(%ebp)
  80092e:	8b 00                	mov    (%eax),%eax
  800930:	89 c2                	mov    %eax,%edx
  800932:	c1 fa 1f             	sar    $0x1f,%edx
  800935:	31 d0                	xor    %edx,%eax
  800937:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800939:	83 f8 08             	cmp    $0x8,%eax
  80093c:	7f 0b                	jg     800949 <vprintfmt+0x27b>
  80093e:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800945:	85 d2                	test   %edx,%edx
  800947:	75 23                	jne    80096c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800949:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094d:	c7 44 24 08 ce 13 80 	movl   $0x8013ce,0x8(%esp)
  800954:	00 
  800955:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800959:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095c:	89 3c 24             	mov    %edi,(%esp)
  80095f:	e8 42 fd ff ff       	call   8006a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800964:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800967:	e9 85 fd ff ff       	jmp    8006f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80096c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800970:	c7 44 24 08 d7 13 80 	movl   $0x8013d7,0x8(%esp)
  800977:	00 
  800978:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097f:	89 3c 24             	mov    %edi,(%esp)
  800982:	e8 1f fd ff ff       	call   8006a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800987:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80098a:	e9 62 fd ff ff       	jmp    8006f1 <vprintfmt+0x23>
  80098f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800992:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800995:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800998:	8b 45 14             	mov    0x14(%ebp),%eax
  80099b:	8d 50 04             	lea    0x4(%eax),%edx
  80099e:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009a3:	85 f6                	test   %esi,%esi
  8009a5:	b8 af 13 80 00       	mov    $0x8013af,%eax
  8009aa:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009b1:	7e 06                	jle    8009b9 <vprintfmt+0x2eb>
  8009b3:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009b7:	75 13                	jne    8009cc <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b9:	0f be 06             	movsbl (%esi),%eax
  8009bc:	83 c6 01             	add    $0x1,%esi
  8009bf:	85 c0                	test   %eax,%eax
  8009c1:	0f 85 94 00 00 00    	jne    800a5b <vprintfmt+0x38d>
  8009c7:	e9 81 00 00 00       	jmp    800a4d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d0:	89 34 24             	mov    %esi,(%esp)
  8009d3:	e8 a3 02 00 00       	call   800c7b <strnlen>
  8009d8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009db:	29 c2                	sub    %eax,%edx
  8009dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009e0:	85 d2                	test   %edx,%edx
  8009e2:	7e d5                	jle    8009b9 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009e4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009e8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009eb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009ee:	89 d6                	mov    %edx,%esi
  8009f0:	89 cf                	mov    %ecx,%edi
  8009f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f6:	89 3c 24             	mov    %edi,(%esp)
  8009f9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009fc:	83 ee 01             	sub    $0x1,%esi
  8009ff:	75 f1                	jne    8009f2 <vprintfmt+0x324>
  800a01:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a04:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a07:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a0a:	eb ad                	jmp    8009b9 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a0c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a10:	74 1b                	je     800a2d <vprintfmt+0x35f>
  800a12:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a15:	83 fa 5e             	cmp    $0x5e,%edx
  800a18:	76 13                	jbe    800a2d <vprintfmt+0x35f>
					putch('?', putdat);
  800a1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a28:	ff 55 08             	call   *0x8(%ebp)
  800a2b:	eb 0d                	jmp    800a3a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a2d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a30:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a34:	89 04 24             	mov    %eax,(%esp)
  800a37:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3a:	83 eb 01             	sub    $0x1,%ebx
  800a3d:	0f be 06             	movsbl (%esi),%eax
  800a40:	83 c6 01             	add    $0x1,%esi
  800a43:	85 c0                	test   %eax,%eax
  800a45:	75 1a                	jne    800a61 <vprintfmt+0x393>
  800a47:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a4a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a50:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a54:	7f 1c                	jg     800a72 <vprintfmt+0x3a4>
  800a56:	e9 96 fc ff ff       	jmp    8006f1 <vprintfmt+0x23>
  800a5b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a5e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a61:	85 ff                	test   %edi,%edi
  800a63:	78 a7                	js     800a0c <vprintfmt+0x33e>
  800a65:	83 ef 01             	sub    $0x1,%edi
  800a68:	79 a2                	jns    800a0c <vprintfmt+0x33e>
  800a6a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a6d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a70:	eb db                	jmp    800a4d <vprintfmt+0x37f>
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	89 de                	mov    %ebx,%esi
  800a77:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a85:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a87:	83 eb 01             	sub    $0x1,%ebx
  800a8a:	75 ee                	jne    800a7a <vprintfmt+0x3ac>
  800a8c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a91:	e9 5b fc ff ff       	jmp    8006f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a96:	83 f9 01             	cmp    $0x1,%ecx
  800a99:	7e 10                	jle    800aab <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9e:	8d 50 08             	lea    0x8(%eax),%edx
  800aa1:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa4:	8b 30                	mov    (%eax),%esi
  800aa6:	8b 78 04             	mov    0x4(%eax),%edi
  800aa9:	eb 26                	jmp    800ad1 <vprintfmt+0x403>
	else if (lflag)
  800aab:	85 c9                	test   %ecx,%ecx
  800aad:	74 12                	je     800ac1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab2:	8d 50 04             	lea    0x4(%eax),%edx
  800ab5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab8:	8b 30                	mov    (%eax),%esi
  800aba:	89 f7                	mov    %esi,%edi
  800abc:	c1 ff 1f             	sar    $0x1f,%edi
  800abf:	eb 10                	jmp    800ad1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800ac1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac4:	8d 50 04             	lea    0x4(%eax),%edx
  800ac7:	89 55 14             	mov    %edx,0x14(%ebp)
  800aca:	8b 30                	mov    (%eax),%esi
  800acc:	89 f7                	mov    %esi,%edi
  800ace:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ad1:	85 ff                	test   %edi,%edi
  800ad3:	78 0e                	js     800ae3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad5:	89 f0                	mov    %esi,%eax
  800ad7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad9:	be 0a 00 00 00       	mov    $0xa,%esi
  800ade:	e9 84 00 00 00       	jmp    800b67 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ae3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800af1:	89 f0                	mov    %esi,%eax
  800af3:	89 fa                	mov    %edi,%edx
  800af5:	f7 d8                	neg    %eax
  800af7:	83 d2 00             	adc    $0x0,%edx
  800afa:	f7 da                	neg    %edx
			}
			base = 10;
  800afc:	be 0a 00 00 00       	mov    $0xa,%esi
  800b01:	eb 64                	jmp    800b67 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b03:	89 ca                	mov    %ecx,%edx
  800b05:	8d 45 14             	lea    0x14(%ebp),%eax
  800b08:	e8 42 fb ff ff       	call   80064f <getuint>
			base = 10;
  800b0d:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b12:	eb 53                	jmp    800b67 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b14:	89 ca                	mov    %ecx,%edx
  800b16:	8d 45 14             	lea    0x14(%ebp),%eax
  800b19:	e8 31 fb ff ff       	call   80064f <getuint>
    			base = 8;
  800b1e:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b23:	eb 42                	jmp    800b67 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b29:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b30:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b37:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b3e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 50 04             	lea    0x4(%eax),%edx
  800b47:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b4a:	8b 00                	mov    (%eax),%eax
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b51:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b56:	eb 0f                	jmp    800b67 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b58:	89 ca                	mov    %ecx,%edx
  800b5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5d:	e8 ed fa ff ff       	call   80064f <getuint>
			base = 16;
  800b62:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b67:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b6b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b6f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b72:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b76:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b7a:	89 04 24             	mov    %eax,(%esp)
  800b7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b81:	89 da                	mov    %ebx,%edx
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	e8 e9 f9 ff ff       	call   800574 <printnum>
			break;
  800b8b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b8e:	e9 5e fb ff ff       	jmp    8006f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b97:	89 14 24             	mov    %edx,(%esp)
  800b9a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ba0:	e9 4c fb ff ff       	jmp    8006f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ba5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bb0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bb3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bb7:	0f 84 34 fb ff ff    	je     8006f1 <vprintfmt+0x23>
  800bbd:	83 ee 01             	sub    $0x1,%esi
  800bc0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bc4:	75 f7                	jne    800bbd <vprintfmt+0x4ef>
  800bc6:	e9 26 fb ff ff       	jmp    8006f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bcb:	83 c4 5c             	add    $0x5c,%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 28             	sub    $0x28,%esp
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800be6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800be9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	74 30                	je     800c24 <vsnprintf+0x51>
  800bf4:	85 d2                	test   %edx,%edx
  800bf6:	7e 2c                	jle    800c24 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bf8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bff:	8b 45 10             	mov    0x10(%ebp),%eax
  800c02:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c06:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0d:	c7 04 24 89 06 80 00 	movl   $0x800689,(%esp)
  800c14:	e8 b5 fa ff ff       	call   8006ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c19:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c1c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c22:	eb 05                	jmp    800c29 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c31:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c34:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	89 04 24             	mov    %eax,(%esp)
  800c4c:	e8 82 ff ff ff       	call   800bd3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    
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
