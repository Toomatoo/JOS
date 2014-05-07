
obj/user/badsegment.debug:     file format elf32-i386


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
  800052:	e8 11 01 00 00       	call   800168 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  800096:	e8 43 06 00 00       	call   8006de <close_all>
	sys_env_destroy(0);
  80009b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a2:	e8 64 00 00 00       	call   80010b <sys_env_destroy>
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	89 c3                	mov    %eax,%ebx
  8000c8:	89 c7                	mov    %eax,%edi
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000d7:	89 ec                	mov    %ebp,%esp
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f4:	89 d1                	mov    %edx,%ecx
  8000f6:	89 d3                	mov    %edx,%ebx
  8000f8:	89 d7                	mov    %edx,%edi
  8000fa:	89 d6                	mov    %edx,%esi
  8000fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800101:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800104:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 38             	sub    $0x38,%esp
  800111:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800114:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800117:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	b8 03 00 00 00       	mov    $0x3,%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	89 cb                	mov    %ecx,%ebx
  800129:	89 cf                	mov    %ecx,%edi
  80012b:	89 ce                	mov    %ecx,%esi
  80012d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012f:	85 c0                	test   %eax,%eax
  800131:	7e 28                	jle    80015b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800133:	89 44 24 10          	mov    %eax,0x10(%esp)
  800137:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013e:	00 
  80013f:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  800146:	00 
  800147:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014e:	00 
  80014f:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800156:	e8 55 11 00 00       	call   8012b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80015e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800161:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800164:	89 ec                	mov    %ebp,%esp
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800171:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800174:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800177:	ba 00 00 00 00       	mov    $0x0,%edx
  80017c:	b8 02 00 00 00       	mov    $0x2,%eax
  800181:	89 d1                	mov    %edx,%ecx
  800183:	89 d3                	mov    %edx,%ebx
  800185:	89 d7                	mov    %edx,%edi
  800187:	89 d6                	mov    %edx,%esi
  800189:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800191:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_yield>:

void
sys_yield(void)
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
  8001ac:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b1:	89 d1                	mov    %edx,%ecx
  8001b3:	89 d3                	mov    %edx,%ebx
  8001b5:	89 d7                	mov    %edx,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c4:	89 ec                	mov    %ebp,%esp
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 38             	sub    $0x38,%esp
  8001ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d7:	be 00 00 00 00       	mov    $0x0,%esi
  8001dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	89 f7                	mov    %esi,%edi
  8001ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7e 28                	jle    80021a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  800205:	00 
  800206:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020d:	00 
  80020e:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800215:	e8 96 10 00 00       	call   8012b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80021d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800220:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800223:	89 ec                	mov    %ebp,%esp
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 38             	sub    $0x38,%esp
  80022d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800230:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800233:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	b8 05 00 00 00       	mov    $0x5,%eax
  80023b:	8b 75 18             	mov    0x18(%ebp),%esi
  80023e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800241:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 28                	jle    800278 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	89 44 24 10          	mov    %eax,0x10(%esp)
  800254:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80025b:	00 
  80025c:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  800263:	00 
  800264:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026b:	00 
  80026c:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800273:	e8 38 10 00 00       	call   8012b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800278:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80027b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80027e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800281:	89 ec                	mov    %ebp,%esp
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 38             	sub    $0x38,%esp
  80028b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80028e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800291:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 06 00 00 00       	mov    $0x6,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  8002d1:	e8 da 0f 00 00       	call   8012b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002df:	89 ec                	mov    %ebp,%esp
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 38             	sub    $0x38,%esp
  8002e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	89 df                	mov    %ebx,%edi
  800304:	89 de                	mov    %ebx,%esi
  800306:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 28                	jle    800334 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80030c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800310:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800317:	00 
  800318:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  80031f:	00 
  800320:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800327:	00 
  800328:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80032f:	e8 7c 0f 00 00       	call   8012b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800334:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800337:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80033a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80033d:	89 ec                	mov    %ebp,%esp
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	83 ec 38             	sub    $0x38,%esp
  800347:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80034a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80034d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800350:	bb 00 00 00 00       	mov    $0x0,%ebx
  800355:	b8 09 00 00 00       	mov    $0x9,%eax
  80035a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80035d:	8b 55 08             	mov    0x8(%ebp),%edx
  800360:	89 df                	mov    %ebx,%edi
  800362:	89 de                	mov    %ebx,%esi
  800364:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800366:	85 c0                	test   %eax,%eax
  800368:	7e 28                	jle    800392 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800375:	00 
  800376:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  80037d:	00 
  80037e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800385:	00 
  800386:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80038d:	e8 1e 0f 00 00       	call   8012b0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800392:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800395:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800398:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039b:	89 ec                	mov    %ebp,%esp
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 38             	sub    $0x38,%esp
  8003a5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003a8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003ab:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003be:	89 df                	mov    %ebx,%edi
  8003c0:	89 de                	mov    %ebx,%esi
  8003c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	7e 28                	jle    8003f0 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003cc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003d3:	00 
  8003d4:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  8003db:	00 
  8003dc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e3:	00 
  8003e4:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  8003eb:	e8 c0 0e 00 00       	call   8012b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003f0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003f3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003f6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003f9:	89 ec                	mov    %ebp,%esp
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 0c             	sub    $0xc,%esp
  800403:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800406:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800409:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040c:	be 00 00 00 00       	mov    $0x0,%esi
  800411:	b8 0c 00 00 00       	mov    $0xc,%eax
  800416:	8b 7d 14             	mov    0x14(%ebp),%edi
  800419:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80041c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041f:	8b 55 08             	mov    0x8(%ebp),%edx
  800422:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800424:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800427:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80042d:	89 ec                	mov    %ebp,%esp
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 38             	sub    $0x38,%esp
  800437:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80043a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80043d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800440:	b9 00 00 00 00       	mov    $0x0,%ecx
  800445:	b8 0d 00 00 00       	mov    $0xd,%eax
  80044a:	8b 55 08             	mov    0x8(%ebp),%edx
  80044d:	89 cb                	mov    %ecx,%ebx
  80044f:	89 cf                	mov    %ecx,%edi
  800451:	89 ce                	mov    %ecx,%esi
  800453:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800455:	85 c0                	test   %eax,%eax
  800457:	7e 28                	jle    800481 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800459:	89 44 24 10          	mov    %eax,0x10(%esp)
  80045d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800464:	00 
  800465:	c7 44 24 08 0a 23 80 	movl   $0x80230a,0x8(%esp)
  80046c:	00 
  80046d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800474:	00 
  800475:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80047c:	e8 2f 0e 00 00       	call   8012b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800481:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800484:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800487:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80048a:	89 ec                	mov    %ebp,%esp
  80048c:	5d                   	pop    %ebp
  80048d:	c3                   	ret    

0080048e <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	83 ec 0c             	sub    $0xc,%esp
  800494:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800497:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80049a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80049d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8004a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8004aa:	89 cb                	mov    %ecx,%ebx
  8004ac:	89 cf                	mov    %ecx,%edi
  8004ae:	89 ce                	mov    %ecx,%esi
  8004b0:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8004b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004bb:	89 ec                	mov    %ebp,%esp
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    
	...

008004c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 df ff ff ff       	call   8004c0 <fd2num>
  8004e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8004e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	53                   	push   %ebx
  8004ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8004f2:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8004f7:	a8 01                	test   $0x1,%al
  8004f9:	74 34                	je     80052f <fd_alloc+0x44>
  8004fb:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800500:	a8 01                	test   $0x1,%al
  800502:	74 32                	je     800536 <fd_alloc+0x4b>
  800504:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800509:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80050b:	89 c2                	mov    %eax,%edx
  80050d:	c1 ea 16             	shr    $0x16,%edx
  800510:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800517:	f6 c2 01             	test   $0x1,%dl
  80051a:	74 1f                	je     80053b <fd_alloc+0x50>
  80051c:	89 c2                	mov    %eax,%edx
  80051e:	c1 ea 0c             	shr    $0xc,%edx
  800521:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800528:	f6 c2 01             	test   $0x1,%dl
  80052b:	75 17                	jne    800544 <fd_alloc+0x59>
  80052d:	eb 0c                	jmp    80053b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80052f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800534:	eb 05                	jmp    80053b <fd_alloc+0x50>
  800536:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80053b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80053d:	b8 00 00 00 00       	mov    $0x0,%eax
  800542:	eb 17                	jmp    80055b <fd_alloc+0x70>
  800544:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800549:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80054e:	75 b9                	jne    800509 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800550:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800556:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80055b:	5b                   	pop    %ebx
  80055c:	5d                   	pop    %ebp
  80055d:	c3                   	ret    

0080055e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800569:	83 fa 1f             	cmp    $0x1f,%edx
  80056c:	77 3f                	ja     8005ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80056e:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  800574:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800577:	89 d0                	mov    %edx,%eax
  800579:	c1 e8 16             	shr    $0x16,%eax
  80057c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800583:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800588:	f6 c1 01             	test   $0x1,%cl
  80058b:	74 20                	je     8005ad <fd_lookup+0x4f>
  80058d:	89 d0                	mov    %edx,%eax
  80058f:	c1 e8 0c             	shr    $0xc,%eax
  800592:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800599:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80059e:	f6 c1 01             	test   $0x1,%cl
  8005a1:	74 0a                	je     8005ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8005ad:	5d                   	pop    %ebp
  8005ae:	c3                   	ret    

008005af <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005af:	55                   	push   %ebp
  8005b0:	89 e5                	mov    %esp,%ebp
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 14             	sub    $0x14,%esp
  8005b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8005bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  8005c1:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8005c7:	75 17                	jne    8005e0 <dev_lookup+0x31>
  8005c9:	eb 07                	jmp    8005d2 <dev_lookup+0x23>
  8005cb:	39 0a                	cmp    %ecx,(%edx)
  8005cd:	75 11                	jne    8005e0 <dev_lookup+0x31>
  8005cf:	90                   	nop
  8005d0:	eb 05                	jmp    8005d7 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005d2:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8005d7:	89 13                	mov    %edx,(%ebx)
			return 0;
  8005d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005de:	eb 35                	jmp    800615 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005e0:	83 c0 01             	add    $0x1,%eax
  8005e3:	8b 14 85 b4 23 80 00 	mov    0x8023b4(,%eax,4),%edx
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	75 dd                	jne    8005cb <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8005f3:	8b 40 48             	mov    0x48(%eax),%eax
  8005f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fe:	c7 04 24 38 23 80 00 	movl   $0x802338,(%esp)
  800605:	e8 a1 0d 00 00       	call   8013ab <cprintf>
	*dev = 0;
  80060a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800610:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800615:	83 c4 14             	add    $0x14,%esp
  800618:	5b                   	pop    %ebx
  800619:	5d                   	pop    %ebp
  80061a:	c3                   	ret    

0080061b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
  80061e:	83 ec 38             	sub    $0x38,%esp
  800621:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800624:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800627:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80062a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800631:	89 3c 24             	mov    %edi,(%esp)
  800634:	e8 87 fe ff ff       	call   8004c0 <fd2num>
  800639:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80063c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	e8 16 ff ff ff       	call   80055e <fd_lookup>
  800648:	89 c3                	mov    %eax,%ebx
  80064a:	85 c0                	test   %eax,%eax
  80064c:	78 05                	js     800653 <fd_close+0x38>
	    || fd != fd2)
  80064e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800651:	74 0e                	je     800661 <fd_close+0x46>
		return (must_exist ? r : 0);
  800653:	89 f0                	mov    %esi,%eax
  800655:	84 c0                	test   %al,%al
  800657:	b8 00 00 00 00       	mov    $0x0,%eax
  80065c:	0f 44 d8             	cmove  %eax,%ebx
  80065f:	eb 3d                	jmp    80069e <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800661:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800664:	89 44 24 04          	mov    %eax,0x4(%esp)
  800668:	8b 07                	mov    (%edi),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	e8 3d ff ff ff       	call   8005af <dev_lookup>
  800672:	89 c3                	mov    %eax,%ebx
  800674:	85 c0                	test   %eax,%eax
  800676:	78 16                	js     80068e <fd_close+0x73>
		if (dev->dev_close)
  800678:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80067e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800683:	85 c0                	test   %eax,%eax
  800685:	74 07                	je     80068e <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  800687:	89 3c 24             	mov    %edi,(%esp)
  80068a:	ff d0                	call   *%eax
  80068c:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80068e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800692:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800699:	e8 e7 fb ff ff       	call   800285 <sys_page_unmap>
	return r;
}
  80069e:	89 d8                	mov    %ebx,%eax
  8006a0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006a3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006a6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006a9:	89 ec                	mov    %ebp,%esp
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	e8 99 fe ff ff       	call   80055e <fd_lookup>
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	78 13                	js     8006dc <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8006c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8006d0:	00 
  8006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	e8 3f ff ff ff       	call   80061b <fd_close>
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <close_all>:

void
close_all(void)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8006e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8006ea:	89 1c 24             	mov    %ebx,(%esp)
  8006ed:	e8 bb ff ff ff       	call   8006ad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8006f2:	83 c3 01             	add    $0x1,%ebx
  8006f5:	83 fb 20             	cmp    $0x20,%ebx
  8006f8:	75 f0                	jne    8006ea <close_all+0xc>
		close(i);
}
  8006fa:	83 c4 14             	add    $0x14,%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 58             	sub    $0x58,%esp
  800706:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800709:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80070c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80070f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800712:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800715:	89 44 24 04          	mov    %eax,0x4(%esp)
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	e8 3a fe ff ff       	call   80055e <fd_lookup>
  800724:	89 c3                	mov    %eax,%ebx
  800726:	85 c0                	test   %eax,%eax
  800728:	0f 88 e1 00 00 00    	js     80080f <dup+0x10f>
		return r;
	close(newfdnum);
  80072e:	89 3c 24             	mov    %edi,(%esp)
  800731:	e8 77 ff ff ff       	call   8006ad <close>

	newfd = INDEX2FD(newfdnum);
  800736:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80073c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80073f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800742:	89 04 24             	mov    %eax,(%esp)
  800745:	e8 86 fd ff ff       	call   8004d0 <fd2data>
  80074a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80074c:	89 34 24             	mov    %esi,(%esp)
  80074f:	e8 7c fd ff ff       	call   8004d0 <fd2data>
  800754:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800757:	89 d8                	mov    %ebx,%eax
  800759:	c1 e8 16             	shr    $0x16,%eax
  80075c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800763:	a8 01                	test   $0x1,%al
  800765:	74 46                	je     8007ad <dup+0xad>
  800767:	89 d8                	mov    %ebx,%eax
  800769:	c1 e8 0c             	shr    $0xc,%eax
  80076c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800773:	f6 c2 01             	test   $0x1,%dl
  800776:	74 35                	je     8007ad <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800778:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80077f:	25 07 0e 00 00       	and    $0xe07,%eax
  800784:	89 44 24 10          	mov    %eax,0x10(%esp)
  800788:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80078b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800796:	00 
  800797:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007a2:	e8 80 fa ff ff       	call   800227 <sys_page_map>
  8007a7:	89 c3                	mov    %eax,%ebx
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	78 3b                	js     8007e8 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	c1 ea 0c             	shr    $0xc,%edx
  8007b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8007c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007d1:	00 
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007dd:	e8 45 fa ff ff       	call   800227 <sys_page_map>
  8007e2:	89 c3                	mov    %eax,%ebx
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	79 25                	jns    80080d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8007e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007f3:	e8 8d fa ff ff       	call   800285 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8007f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800806:	e8 7a fa ff ff       	call   800285 <sys_page_unmap>
	return r;
  80080b:	eb 02                	jmp    80080f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80080d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800814:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800817:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80081a:	89 ec                	mov    %ebp,%esp
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	83 ec 24             	sub    $0x24,%esp
  800825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800828:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	89 1c 24             	mov    %ebx,(%esp)
  800832:	e8 27 fd ff ff       	call   80055e <fd_lookup>
  800837:	85 c0                	test   %eax,%eax
  800839:	78 6d                	js     8008a8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 60 fd ff ff       	call   8005af <dev_lookup>
  80084f:	85 c0                	test   %eax,%eax
  800851:	78 55                	js     8008a8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800856:	8b 50 08             	mov    0x8(%eax),%edx
  800859:	83 e2 03             	and    $0x3,%edx
  80085c:	83 fa 01             	cmp    $0x1,%edx
  80085f:	75 23                	jne    800884 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800861:	a1 04 40 80 00       	mov    0x804004,%eax
  800866:	8b 40 48             	mov    0x48(%eax),%eax
  800869:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	c7 04 24 79 23 80 00 	movl   $0x802379,(%esp)
  800878:	e8 2e 0b 00 00       	call   8013ab <cprintf>
		return -E_INVAL;
  80087d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800882:	eb 24                	jmp    8008a8 <read+0x8a>
	}
	if (!dev->dev_read)
  800884:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800887:	8b 52 08             	mov    0x8(%edx),%edx
  80088a:	85 d2                	test   %edx,%edx
  80088c:	74 15                	je     8008a3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  80088e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800891:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800895:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800898:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80089c:	89 04 24             	mov    %eax,(%esp)
  80089f:	ff d2                	call   *%edx
  8008a1:	eb 05                	jmp    8008a8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8008a8:	83 c4 24             	add    $0x24,%esp
  8008ab:	5b                   	pop    %ebx
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 1c             	sub    $0x1c,%esp
  8008b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	85 f6                	test   %esi,%esi
  8008c4:	74 30                	je     8008f6 <readn+0x48>
  8008c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008cb:	89 f2                	mov    %esi,%edx
  8008cd:	29 c2                	sub    %eax,%edx
  8008cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8008d3:	03 45 0c             	add    0xc(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	89 3c 24             	mov    %edi,(%esp)
  8008dd:	e8 3c ff ff ff       	call   80081e <read>
		if (m < 0)
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	78 10                	js     8008f6 <readn+0x48>
			return m;
		if (m == 0)
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	74 0a                	je     8008f4 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008ea:	01 c3                	add    %eax,%ebx
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	39 f3                	cmp    %esi,%ebx
  8008f0:	72 d9                	jb     8008cb <readn+0x1d>
  8008f2:	eb 02                	jmp    8008f6 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8008f4:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8008f6:	83 c4 1c             	add    $0x1c,%esp
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	53                   	push   %ebx
  800902:	83 ec 24             	sub    $0x24,%esp
  800905:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800908:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	89 1c 24             	mov    %ebx,(%esp)
  800912:	e8 47 fc ff ff       	call   80055e <fd_lookup>
  800917:	85 c0                	test   %eax,%eax
  800919:	78 68                	js     800983 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800925:	8b 00                	mov    (%eax),%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 80 fc ff ff       	call   8005af <dev_lookup>
  80092f:	85 c0                	test   %eax,%eax
  800931:	78 50                	js     800983 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800933:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800936:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80093a:	75 23                	jne    80095f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80093c:	a1 04 40 80 00       	mov    0x804004,%eax
  800941:	8b 40 48             	mov    0x48(%eax),%eax
  800944:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	c7 04 24 95 23 80 00 	movl   $0x802395,(%esp)
  800953:	e8 53 0a 00 00       	call   8013ab <cprintf>
		return -E_INVAL;
  800958:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095d:	eb 24                	jmp    800983 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80095f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800962:	8b 52 0c             	mov    0xc(%edx),%edx
  800965:	85 d2                	test   %edx,%edx
  800967:	74 15                	je     80097e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800970:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800973:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800977:	89 04 24             	mov    %eax,(%esp)
  80097a:	ff d2                	call   *%edx
  80097c:	eb 05                	jmp    800983 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80097e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800983:	83 c4 24             	add    $0x24,%esp
  800986:	5b                   	pop    %ebx
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <seek>:

int
seek(int fdnum, off_t offset)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80098f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800992:	89 44 24 04          	mov    %eax,0x4(%esp)
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	e8 bd fb ff ff       	call   80055e <fd_lookup>
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	78 0e                	js     8009b3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	53                   	push   %ebx
  8009b9:	83 ec 24             	sub    $0x24,%esp
  8009bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c6:	89 1c 24             	mov    %ebx,(%esp)
  8009c9:	e8 90 fb ff ff       	call   80055e <fd_lookup>
  8009ce:	85 c0                	test   %eax,%eax
  8009d0:	78 61                	js     800a33 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009dc:	8b 00                	mov    (%eax),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 c9 fb ff ff       	call   8005af <dev_lookup>
  8009e6:	85 c0                	test   %eax,%eax
  8009e8:	78 49                	js     800a33 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8009f1:	75 23                	jne    800a16 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8009f3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8009f8:	8b 40 48             	mov    0x48(%eax),%eax
  8009fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a03:	c7 04 24 58 23 80 00 	movl   $0x802358,(%esp)
  800a0a:	e8 9c 09 00 00       	call   8013ab <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a14:	eb 1d                	jmp    800a33 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a19:	8b 52 18             	mov    0x18(%edx),%edx
  800a1c:	85 d2                	test   %edx,%edx
  800a1e:	74 0e                	je     800a2e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a27:	89 04 24             	mov    %eax,(%esp)
  800a2a:	ff d2                	call   *%edx
  800a2c:	eb 05                	jmp    800a33 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a2e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a33:	83 c4 24             	add    $0x24,%esp
  800a36:	5b                   	pop    %ebx
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	53                   	push   %ebx
  800a3d:	83 ec 24             	sub    $0x24,%esp
  800a40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	e8 09 fb ff ff       	call   80055e <fd_lookup>
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 52                	js     800aab <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a63:	8b 00                	mov    (%eax),%eax
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	e8 42 fb ff ff       	call   8005af <dev_lookup>
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	78 3a                	js     800aab <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a74:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800a78:	74 2c                	je     800aa6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800a7a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a7d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a84:	00 00 00 
	stat->st_isdir = 0;
  800a87:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a8e:	00 00 00 
	stat->st_dev = dev;
  800a91:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a9e:	89 14 24             	mov    %edx,(%esp)
  800aa1:	ff 50 14             	call   *0x14(%eax)
  800aa4:	eb 05                	jmp    800aab <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800aa6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800aab:	83 c4 24             	add    $0x24,%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 18             	sub    $0x18,%esp
  800ab7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800aba:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800abd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ac4:	00 
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	89 04 24             	mov    %eax,(%esp)
  800acb:	e8 bc 01 00 00       	call   800c8c <open>
  800ad0:	89 c3                	mov    %eax,%ebx
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	78 1b                	js     800af1 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800add:	89 1c 24             	mov    %ebx,(%esp)
  800ae0:	e8 54 ff ff ff       	call   800a39 <fstat>
  800ae5:	89 c6                	mov    %eax,%esi
	close(fd);
  800ae7:	89 1c 24             	mov    %ebx,(%esp)
  800aea:	e8 be fb ff ff       	call   8006ad <close>
	return r;
  800aef:	89 f3                	mov    %esi,%ebx
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800af6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800af9:	89 ec                	mov    %ebp,%esp
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    
  800afd:	00 00                	add    %al,(%eax)
	...

00800b00 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	83 ec 18             	sub    $0x18,%esp
  800b06:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b09:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b0c:	89 c3                	mov    %eax,%ebx
  800b0e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b10:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b17:	75 11                	jne    800b2a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b20:	e8 8c 14 00 00       	call   801fb1 <ipc_find_env>
  800b25:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b2a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b31:	00 
  800b32:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b39:	00 
  800b3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3e:	a1 00 40 80 00       	mov    0x804000,%eax
  800b43:	89 04 24             	mov    %eax,(%esp)
  800b46:	e8 fb 13 00 00       	call   801f46 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  800b4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b52:	00 
  800b53:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b5e:	e8 7d 13 00 00       	call   801ee0 <ipc_recv>
}
  800b63:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b66:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b69:	89 ec                	mov    %ebp,%esp
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	53                   	push   %ebx
  800b71:	83 ec 14             	sub    $0x14,%esp
  800b74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 40 0c             	mov    0xc(%eax),%eax
  800b7d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8c:	e8 6f ff ff ff       	call   800b00 <fsipc>
  800b91:	85 c0                	test   %eax,%eax
  800b93:	78 2b                	js     800bc0 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b95:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b9c:	00 
  800b9d:	89 1c 24             	mov    %ebx,(%esp)
  800ba0:	e8 56 0f 00 00       	call   801afb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ba5:	a1 80 50 80 00       	mov    0x805080,%eax
  800baa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bb0:	a1 84 50 80 00       	mov    0x805084,%eax
  800bb5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc0:	83 c4 14             	add    $0x14,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	8b 40 0c             	mov    0xc(%eax),%eax
  800bd2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 06 00 00 00       	mov    $0x6,%eax
  800be1:	e8 1a ff ff ff       	call   800b00 <fsipc>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 10             	sub    $0x10,%esp
  800bf0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bfe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0e:	e8 ed fe ff ff       	call   800b00 <fsipc>
  800c13:	89 c3                	mov    %eax,%ebx
  800c15:	85 c0                	test   %eax,%eax
  800c17:	78 6a                	js     800c83 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c19:	39 c6                	cmp    %eax,%esi
  800c1b:	73 24                	jae    800c41 <devfile_read+0x59>
  800c1d:	c7 44 24 0c c4 23 80 	movl   $0x8023c4,0xc(%esp)
  800c24:	00 
  800c25:	c7 44 24 08 cb 23 80 	movl   $0x8023cb,0x8(%esp)
  800c2c:	00 
  800c2d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800c34:	00 
  800c35:	c7 04 24 e0 23 80 00 	movl   $0x8023e0,(%esp)
  800c3c:	e8 6f 06 00 00       	call   8012b0 <_panic>
	assert(r <= PGSIZE);
  800c41:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c46:	7e 24                	jle    800c6c <devfile_read+0x84>
  800c48:	c7 44 24 0c eb 23 80 	movl   $0x8023eb,0xc(%esp)
  800c4f:	00 
  800c50:	c7 44 24 08 cb 23 80 	movl   $0x8023cb,0x8(%esp)
  800c57:	00 
  800c58:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c5f:	00 
  800c60:	c7 04 24 e0 23 80 00 	movl   $0x8023e0,(%esp)
  800c67:	e8 44 06 00 00       	call   8012b0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800c6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c70:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c77:	00 
  800c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	e8 69 10 00 00       	call   801cec <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  800c83:	89 d8                	mov    %ebx,%eax
  800c85:	83 c4 10             	add    $0x10,%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 20             	sub    $0x20,%esp
  800c94:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c97:	89 34 24             	mov    %esi,(%esp)
  800c9a:	e8 11 0e 00 00       	call   801ab0 <strlen>
		return -E_BAD_PATH;
  800c9f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ca4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ca9:	7f 5e                	jg     800d09 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800cab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cae:	89 04 24             	mov    %eax,(%esp)
  800cb1:	e8 35 f8 ff ff       	call   8004eb <fd_alloc>
  800cb6:	89 c3                	mov    %eax,%ebx
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	78 4d                	js     800d09 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cc7:	e8 2f 0e 00 00       	call   801afb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdc:	e8 1f fe ff ff       	call   800b00 <fsipc>
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	79 15                	jns    800cfc <open+0x70>
		fd_close(fd, 0);
  800ce7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cee:	00 
  800cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf2:	89 04 24             	mov    %eax,(%esp)
  800cf5:	e8 21 f9 ff ff       	call   80061b <fd_close>
		return r;
  800cfa:	eb 0d                	jmp    800d09 <open+0x7d>
	}

	return fd2num(fd);
  800cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cff:	89 04 24             	mov    %eax,(%esp)
  800d02:	e8 b9 f7 ff ff       	call   8004c0 <fd2num>
  800d07:	89 c3                	mov    %eax,%ebx
}
  800d09:	89 d8                	mov    %ebx,%eax
  800d0b:	83 c4 20             	add    $0x20,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
	...

00800d20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 18             	sub    $0x18,%esp
  800d26:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d29:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d2c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	89 04 24             	mov    %eax,(%esp)
  800d35:	e8 96 f7 ff ff       	call   8004d0 <fd2data>
  800d3a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d3c:	c7 44 24 04 f7 23 80 	movl   $0x8023f7,0x4(%esp)
  800d43:	00 
  800d44:	89 34 24             	mov    %esi,(%esp)
  800d47:	e8 af 0d 00 00       	call   801afb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d4c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d4f:	2b 03                	sub    (%ebx),%eax
  800d51:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d57:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d5e:	00 00 00 
	stat->st_dev = &devpipe;
  800d61:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d68:	30 80 00 
	return 0;
}
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d73:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d76:	89 ec                	mov    %ebp,%esp
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 14             	sub    $0x14,%esp
  800d81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d8f:	e8 f1 f4 ff ff       	call   800285 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d94:	89 1c 24             	mov    %ebx,(%esp)
  800d97:	e8 34 f7 ff ff       	call   8004d0 <fd2data>
  800d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800da7:	e8 d9 f4 ff ff       	call   800285 <sys_page_unmap>
}
  800dac:	83 c4 14             	add    $0x14,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 2c             	sub    $0x2c,%esp
  800dbb:	89 c7                	mov    %eax,%edi
  800dbd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800dc0:	a1 04 40 80 00       	mov    0x804004,%eax
  800dc5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800dc8:	89 3c 24             	mov    %edi,(%esp)
  800dcb:	e8 2c 12 00 00       	call   801ffc <pageref>
  800dd0:	89 c6                	mov    %eax,%esi
  800dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dd5:	89 04 24             	mov    %eax,(%esp)
  800dd8:	e8 1f 12 00 00       	call   801ffc <pageref>
  800ddd:	39 c6                	cmp    %eax,%esi
  800ddf:	0f 94 c0             	sete   %al
  800de2:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800de5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800deb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800dee:	39 cb                	cmp    %ecx,%ebx
  800df0:	75 08                	jne    800dfa <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800df2:	83 c4 2c             	add    $0x2c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800dfa:	83 f8 01             	cmp    $0x1,%eax
  800dfd:	75 c1                	jne    800dc0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800dff:	8b 52 58             	mov    0x58(%edx),%edx
  800e02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e06:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e0e:	c7 04 24 fe 23 80 00 	movl   $0x8023fe,(%esp)
  800e15:	e8 91 05 00 00       	call   8013ab <cprintf>
  800e1a:	eb a4                	jmp    800dc0 <_pipeisclosed+0xe>

00800e1c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	83 ec 2c             	sub    $0x2c,%esp
  800e25:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800e28:	89 34 24             	mov    %esi,(%esp)
  800e2b:	e8 a0 f6 ff ff       	call   8004d0 <fd2data>
  800e30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e32:	bf 00 00 00 00       	mov    $0x0,%edi
  800e37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e3b:	75 50                	jne    800e8d <devpipe_write+0x71>
  800e3d:	eb 5c                	jmp    800e9b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e3f:	89 da                	mov    %ebx,%edx
  800e41:	89 f0                	mov    %esi,%eax
  800e43:	e8 6a ff ff ff       	call   800db2 <_pipeisclosed>
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	75 53                	jne    800e9f <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e4c:	e8 47 f3 ff ff       	call   800198 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e51:	8b 43 04             	mov    0x4(%ebx),%eax
  800e54:	8b 13                	mov    (%ebx),%edx
  800e56:	83 c2 20             	add    $0x20,%edx
  800e59:	39 d0                	cmp    %edx,%eax
  800e5b:	73 e2                	jae    800e3f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e60:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  800e64:	88 55 e7             	mov    %dl,-0x19(%ebp)
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	c1 fa 1f             	sar    $0x1f,%edx
  800e6c:	c1 ea 1b             	shr    $0x1b,%edx
  800e6f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800e72:	83 e1 1f             	and    $0x1f,%ecx
  800e75:	29 d1                	sub    %edx,%ecx
  800e77:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800e7b:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800e7f:	83 c0 01             	add    $0x1,%eax
  800e82:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e85:	83 c7 01             	add    $0x1,%edi
  800e88:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e8b:	74 0e                	je     800e9b <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e8d:	8b 43 04             	mov    0x4(%ebx),%eax
  800e90:	8b 13                	mov    (%ebx),%edx
  800e92:	83 c2 20             	add    $0x20,%edx
  800e95:	39 d0                	cmp    %edx,%eax
  800e97:	73 a6                	jae    800e3f <devpipe_write+0x23>
  800e99:	eb c2                	jmp    800e5d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e9b:	89 f8                	mov    %edi,%eax
  800e9d:	eb 05                	jmp    800ea4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ea4:	83 c4 2c             	add    $0x2c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 28             	sub    $0x28,%esp
  800eb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ebb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ebe:	89 3c 24             	mov    %edi,(%esp)
  800ec1:	e8 0a f6 ff ff       	call   8004d0 <fd2data>
  800ec6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ec8:	be 00 00 00 00       	mov    $0x0,%esi
  800ecd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ed1:	75 47                	jne    800f1a <devpipe_read+0x6e>
  800ed3:	eb 52                	jmp    800f27 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800ed5:	89 f0                	mov    %esi,%eax
  800ed7:	eb 5e                	jmp    800f37 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ed9:	89 da                	mov    %ebx,%edx
  800edb:	89 f8                	mov    %edi,%eax
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
  800ee0:	e8 cd fe ff ff       	call   800db2 <_pipeisclosed>
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	75 49                	jne    800f32 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  800ee9:	e8 aa f2 ff ff       	call   800198 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800eee:	8b 03                	mov    (%ebx),%eax
  800ef0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ef3:	74 e4                	je     800ed9 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ef5:	89 c2                	mov    %eax,%edx
  800ef7:	c1 fa 1f             	sar    $0x1f,%edx
  800efa:	c1 ea 1b             	shr    $0x1b,%edx
  800efd:	01 d0                	add    %edx,%eax
  800eff:	83 e0 1f             	and    $0x1f,%eax
  800f02:	29 d0                	sub    %edx,%eax
  800f04:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800f0f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800f12:	83 c6 01             	add    $0x1,%esi
  800f15:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f18:	74 0d                	je     800f27 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  800f1a:	8b 03                	mov    (%ebx),%eax
  800f1c:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f1f:	75 d4                	jne    800ef5 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800f21:	85 f6                	test   %esi,%esi
  800f23:	75 b0                	jne    800ed5 <devpipe_read+0x29>
  800f25:	eb b2                	jmp    800ed9 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800f27:	89 f0                	mov    %esi,%eax
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	eb 05                	jmp    800f37 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800f37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f40:	89 ec                	mov    %ebp,%esp
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 48             	sub    $0x48,%esp
  800f4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f50:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f53:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800f56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f59:	89 04 24             	mov    %eax,(%esp)
  800f5c:	e8 8a f5 ff ff       	call   8004eb <fd_alloc>
  800f61:	89 c3                	mov    %eax,%ebx
  800f63:	85 c0                	test   %eax,%eax
  800f65:	0f 88 45 01 00 00    	js     8010b0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f6b:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f72:	00 
  800f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f81:	e8 42 f2 ff ff       	call   8001c8 <sys_page_alloc>
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	0f 88 20 01 00 00    	js     8010b0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f90:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f93:	89 04 24             	mov    %eax,(%esp)
  800f96:	e8 50 f5 ff ff       	call   8004eb <fd_alloc>
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	0f 88 f8 00 00 00    	js     80109d <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fa5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fac:	00 
  800fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbb:	e8 08 f2 ff ff       	call   8001c8 <sys_page_alloc>
  800fc0:	89 c3                	mov    %eax,%ebx
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	0f 88 d3 00 00 00    	js     80109d <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800fca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	e8 fb f4 ff ff       	call   8004d0 <fd2data>
  800fd5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fd7:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fde:	00 
  800fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fea:	e8 d9 f1 ff ff       	call   8001c8 <sys_page_alloc>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	0f 88 91 00 00 00    	js     80108a <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ff9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ffc:	89 04 24             	mov    %eax,(%esp)
  800fff:	e8 cc f4 ff ff       	call   8004d0 <fd2data>
  801004:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80100b:	00 
  80100c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801010:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801017:	00 
  801018:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801023:	e8 ff f1 ff ff       	call   800227 <sys_page_map>
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 4c                	js     80107a <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80102e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801034:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801037:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80103c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801043:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801049:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80104c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80104e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801051:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105b:	89 04 24             	mov    %eax,(%esp)
  80105e:	e8 5d f4 ff ff       	call   8004c0 <fd2num>
  801063:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801065:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801068:	89 04 24             	mov    %eax,(%esp)
  80106b:	e8 50 f4 ff ff       	call   8004c0 <fd2num>
  801070:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801073:	bb 00 00 00 00       	mov    $0x0,%ebx
  801078:	eb 36                	jmp    8010b0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  80107a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801085:	e8 fb f1 ff ff       	call   800285 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80108a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80108d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801098:	e8 e8 f1 ff ff       	call   800285 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80109d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ab:	e8 d5 f1 ff ff       	call   800285 <sys_page_unmap>
    err:
	return r;
}
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010bb:	89 ec                	mov    %ebp,%esp
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	e8 87 f4 ff ff       	call   80055e <fd_lookup>
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 15                	js     8010f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8010db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010de:	89 04 24             	mov    %eax,(%esp)
  8010e1:	e8 ea f3 ff ff       	call   8004d0 <fd2data>
	return _pipeisclosed(fd, p);
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010eb:	e8 c2 fc ff ff       	call   800db2 <_pipeisclosed>
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    
	...

00801100 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801103:	b8 00 00 00 00       	mov    $0x0,%eax
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801110:	c7 44 24 04 16 24 80 	movl   $0x802416,0x4(%esp)
  801117:	00 
  801118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111b:	89 04 24             	mov    %eax,(%esp)
  80111e:	e8 d8 09 00 00       	call   801afb <strcpy>
	return 0;
}
  801123:	b8 00 00 00 00       	mov    $0x0,%eax
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801136:	be 00 00 00 00       	mov    $0x0,%esi
  80113b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80113f:	74 43                	je     801184 <devcons_write+0x5a>
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801146:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801151:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801154:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801159:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80115c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801160:	03 45 0c             	add    0xc(%ebp),%eax
  801163:	89 44 24 04          	mov    %eax,0x4(%esp)
  801167:	89 3c 24             	mov    %edi,(%esp)
  80116a:	e8 7d 0b 00 00       	call   801cec <memmove>
		sys_cputs(buf, m);
  80116f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801173:	89 3c 24             	mov    %edi,(%esp)
  801176:	e8 31 ef ff ff       	call   8000ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80117b:	01 de                	add    %ebx,%esi
  80117d:	89 f0                	mov    %esi,%eax
  80117f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801182:	72 c8                	jb     80114c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801184:	89 f0                	mov    %esi,%eax
  801186:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80119c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011a0:	75 07                	jne    8011a9 <devcons_read+0x18>
  8011a2:	eb 31                	jmp    8011d5 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8011a4:	e8 ef ef ff ff       	call   800198 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	e8 26 ef ff ff       	call   8000db <sys_cgetc>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	74 eb                	je     8011a4 <devcons_read+0x13>
  8011b9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 16                	js     8011d5 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8011bf:	83 f8 04             	cmp    $0x4,%eax
  8011c2:	74 0c                	je     8011d0 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  8011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c7:	88 10                	mov    %dl,(%eax)
	return 1;
  8011c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ce:	eb 05                	jmp    8011d5 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8011e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011ea:	00 
  8011eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8011ee:	89 04 24             	mov    %eax,(%esp)
  8011f1:	e8 b6 ee ff ff       	call   8000ac <sys_cputs>
}
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <getchar>:

int
getchar(void)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8011fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801205:	00 
  801206:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801214:	e8 05 f6 ff ff       	call   80081e <read>
	if (r < 0)
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 0f                	js     80122c <getchar+0x34>
		return r;
	if (r < 1)
  80121d:	85 c0                	test   %eax,%eax
  80121f:	7e 06                	jle    801227 <getchar+0x2f>
		return -E_EOF;
	return c;
  801221:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801225:	eb 05                	jmp    80122c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801227:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
  80123e:	89 04 24             	mov    %eax,(%esp)
  801241:	e8 18 f3 ff ff       	call   80055e <fd_lookup>
  801246:	85 c0                	test   %eax,%eax
  801248:	78 11                	js     80125b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801253:	39 10                	cmp    %edx,(%eax)
  801255:	0f 94 c0             	sete   %al
  801258:	0f b6 c0             	movzbl %al,%eax
}
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <opencons>:

int
opencons(void)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	89 04 24             	mov    %eax,(%esp)
  801269:	e8 7d f2 ff ff       	call   8004eb <fd_alloc>
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 3c                	js     8012ae <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801272:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801279:	00 
  80127a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801281:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801288:	e8 3b ef ff ff       	call   8001c8 <sys_page_alloc>
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 1d                	js     8012ae <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801291:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801297:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8012a6:	89 04 24             	mov    %eax,(%esp)
  8012a9:	e8 12 f2 ff ff       	call   8004c0 <fd2num>
}
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012b8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012bb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8012c1:	e8 a2 ee ff ff       	call   800168 <sys_getenvid>
  8012c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dc:	c7 04 24 24 24 80 00 	movl   $0x802424,(%esp)
  8012e3:	e8 c3 00 00 00       	call   8013ab <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ef:	89 04 24             	mov    %eax,(%esp)
  8012f2:	e8 53 00 00 00       	call   80134a <vcprintf>
	cprintf("\n");
  8012f7:	c7 04 24 0f 24 80 00 	movl   $0x80240f,(%esp)
  8012fe:	e8 a8 00 00 00       	call   8013ab <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801303:	cc                   	int3   
  801304:	eb fd                	jmp    801303 <_panic+0x53>
	...

00801308 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 14             	sub    $0x14,%esp
  80130f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801312:	8b 03                	mov    (%ebx),%eax
  801314:	8b 55 08             	mov    0x8(%ebp),%edx
  801317:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80131b:	83 c0 01             	add    $0x1,%eax
  80131e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801320:	3d ff 00 00 00       	cmp    $0xff,%eax
  801325:	75 19                	jne    801340 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801327:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80132e:	00 
  80132f:	8d 43 08             	lea    0x8(%ebx),%eax
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 72 ed ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  80133a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801340:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801344:	83 c4 14             	add    $0x14,%esp
  801347:	5b                   	pop    %ebx
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801353:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80135a:	00 00 00 
	b.cnt = 0;
  80135d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801364:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	89 44 24 08          	mov    %eax,0x8(%esp)
  801375:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80137b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137f:	c7 04 24 08 13 80 00 	movl   $0x801308,(%esp)
  801386:	e8 97 01 00 00       	call   801522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80138b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801391:	89 44 24 04          	mov    %eax,0x4(%esp)
  801395:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80139b:	89 04 24             	mov    %eax,(%esp)
  80139e:	e8 09 ed ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8013a3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8013b1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 87 ff ff ff       	call   80134a <vcprintf>
	va_end(ap);

	return cnt;
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    
  8013c5:	00 00                	add    %al,(%eax)
	...

008013c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	57                   	push   %edi
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 3c             	sub    $0x3c,%esp
  8013d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013d4:	89 d7                	mov    %edx,%edi
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8013e5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8013f0:	72 11                	jb     801403 <printnum+0x3b>
  8013f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8013f8:	76 09                	jbe    801403 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8013fa:	83 eb 01             	sub    $0x1,%ebx
  8013fd:	85 db                	test   %ebx,%ebx
  8013ff:	7f 51                	jg     801452 <printnum+0x8a>
  801401:	eb 5e                	jmp    801461 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801403:	89 74 24 10          	mov    %esi,0x10(%esp)
  801407:	83 eb 01             	sub    $0x1,%ebx
  80140a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80140e:	8b 45 10             	mov    0x10(%ebp),%eax
  801411:	89 44 24 08          	mov    %eax,0x8(%esp)
  801415:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801419:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80141d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801424:	00 
  801425:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801428:	89 04 24             	mov    %eax,(%esp)
  80142b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80142e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801432:	e8 09 0c 00 00       	call   802040 <__udivdi3>
  801437:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80143b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	89 54 24 04          	mov    %edx,0x4(%esp)
  801446:	89 fa                	mov    %edi,%edx
  801448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80144b:	e8 78 ff ff ff       	call   8013c8 <printnum>
  801450:	eb 0f                	jmp    801461 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801452:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801456:	89 34 24             	mov    %esi,(%esp)
  801459:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80145c:	83 eb 01             	sub    $0x1,%ebx
  80145f:	75 f1                	jne    801452 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801461:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801465:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801469:	8b 45 10             	mov    0x10(%ebp),%eax
  80146c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801470:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801477:	00 
  801478:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80147b:	89 04 24             	mov    %eax,(%esp)
  80147e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801481:	89 44 24 04          	mov    %eax,0x4(%esp)
  801485:	e8 e6 0c 00 00       	call   802170 <__umoddi3>
  80148a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80148e:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80149b:	83 c4 3c             	add    $0x3c,%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014a6:	83 fa 01             	cmp    $0x1,%edx
  8014a9:	7e 0e                	jle    8014b9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014ab:	8b 10                	mov    (%eax),%edx
  8014ad:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014b0:	89 08                	mov    %ecx,(%eax)
  8014b2:	8b 02                	mov    (%edx),%eax
  8014b4:	8b 52 04             	mov    0x4(%edx),%edx
  8014b7:	eb 22                	jmp    8014db <getuint+0x38>
	else if (lflag)
  8014b9:	85 d2                	test   %edx,%edx
  8014bb:	74 10                	je     8014cd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014bd:	8b 10                	mov    (%eax),%edx
  8014bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014c2:	89 08                	mov    %ecx,(%eax)
  8014c4:	8b 02                	mov    (%edx),%eax
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	eb 0e                	jmp    8014db <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8014cd:	8b 10                	mov    (%eax),%edx
  8014cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014d2:	89 08                	mov    %ecx,(%eax)
  8014d4:	8b 02                	mov    (%edx),%eax
  8014d6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8014e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8014e7:	8b 10                	mov    (%eax),%edx
  8014e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8014ec:	73 0a                	jae    8014f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8014ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f1:	88 0a                	mov    %cl,(%edx)
  8014f3:	83 c2 01             	add    $0x1,%edx
  8014f6:	89 10                	mov    %edx,(%eax)
}
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801500:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801503:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801507:	8b 45 10             	mov    0x10(%ebp),%eax
  80150a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80150e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801511:	89 44 24 04          	mov    %eax,0x4(%esp)
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	89 04 24             	mov    %eax,(%esp)
  80151b:	e8 02 00 00 00       	call   801522 <vprintfmt>
	va_end(ap);
}
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	57                   	push   %edi
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 5c             	sub    $0x5c,%esp
  80152b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80152e:	8b 75 10             	mov    0x10(%ebp),%esi
  801531:	eb 12                	jmp    801545 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801533:	85 c0                	test   %eax,%eax
  801535:	0f 84 e4 04 00 00    	je     801a1f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80153b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80153f:	89 04 24             	mov    %eax,(%esp)
  801542:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801545:	0f b6 06             	movzbl (%esi),%eax
  801548:	83 c6 01             	add    $0x1,%esi
  80154b:	83 f8 25             	cmp    $0x25,%eax
  80154e:	75 e3                	jne    801533 <vprintfmt+0x11>
  801550:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  801554:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80155b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801560:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  801567:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80156f:	eb 2b                	jmp    80159c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801571:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801574:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  801578:	eb 22                	jmp    80159c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80157a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80157d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  801581:	eb 19                	jmp    80159c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801583:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801586:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80158d:	eb 0d                	jmp    80159c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80158f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  801592:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801595:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159c:	0f b6 06             	movzbl (%esi),%eax
  80159f:	0f b6 d0             	movzbl %al,%edx
  8015a2:	8d 7e 01             	lea    0x1(%esi),%edi
  8015a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8015a8:	83 e8 23             	sub    $0x23,%eax
  8015ab:	3c 55                	cmp    $0x55,%al
  8015ad:	0f 87 46 04 00 00    	ja     8019f9 <vprintfmt+0x4d7>
  8015b3:	0f b6 c0             	movzbl %al,%eax
  8015b6:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015bd:	83 ea 30             	sub    $0x30,%edx
  8015c0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8015c3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8015c7:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8015cd:	83 fa 09             	cmp    $0x9,%edx
  8015d0:	77 4a                	ja     80161c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015d5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8015d8:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8015db:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8015df:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8015e2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8015e5:	83 fa 09             	cmp    $0x9,%edx
  8015e8:	76 eb                	jbe    8015d5 <vprintfmt+0xb3>
  8015ea:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8015ed:	eb 2d                	jmp    80161c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f2:	8d 50 04             	lea    0x4(%eax),%edx
  8015f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8015f8:	8b 00                	mov    (%eax),%eax
  8015fa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801600:	eb 1a                	jmp    80161c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801602:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  801605:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801609:	79 91                	jns    80159c <vprintfmt+0x7a>
  80160b:	e9 73 ff ff ff       	jmp    801583 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801610:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801613:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80161a:	eb 80                	jmp    80159c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80161c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801620:	0f 89 76 ff ff ff    	jns    80159c <vprintfmt+0x7a>
  801626:	e9 64 ff ff ff       	jmp    80158f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80162b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80162e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801631:	e9 66 ff ff ff       	jmp    80159c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801636:	8b 45 14             	mov    0x14(%ebp),%eax
  801639:	8d 50 04             	lea    0x4(%eax),%edx
  80163c:	89 55 14             	mov    %edx,0x14(%ebp)
  80163f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801643:	8b 00                	mov    (%eax),%eax
  801645:	89 04 24             	mov    %eax,(%esp)
  801648:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80164e:	e9 f2 fe ff ff       	jmp    801545 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  801653:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  801657:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80165a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80165e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  801661:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  801665:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  801668:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80166b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80166f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  801672:	80 f9 09             	cmp    $0x9,%cl
  801675:	77 1d                	ja     801694 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  801677:	0f be c0             	movsbl %al,%eax
  80167a:	6b c0 64             	imul   $0x64,%eax,%eax
  80167d:	0f be d2             	movsbl %dl,%edx
  801680:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801683:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80168a:	a3 58 30 80 00       	mov    %eax,0x803058
  80168f:	e9 b1 fe ff ff       	jmp    801545 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  801694:	c7 44 24 04 5f 24 80 	movl   $0x80245f,0x4(%esp)
  80169b:	00 
  80169c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80169f:	89 04 24             	mov    %eax,(%esp)
  8016a2:	e8 14 05 00 00       	call   801bbb <strcmp>
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	75 0f                	jne    8016ba <vprintfmt+0x198>
  8016ab:	c7 05 58 30 80 00 04 	movl   $0x4,0x803058
  8016b2:	00 00 00 
  8016b5:	e9 8b fe ff ff       	jmp    801545 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8016ba:	c7 44 24 04 63 24 80 	movl   $0x802463,0x4(%esp)
  8016c1:	00 
  8016c2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8016c5:	89 14 24             	mov    %edx,(%esp)
  8016c8:	e8 ee 04 00 00       	call   801bbb <strcmp>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	75 0f                	jne    8016e0 <vprintfmt+0x1be>
  8016d1:	c7 05 58 30 80 00 02 	movl   $0x2,0x803058
  8016d8:	00 00 00 
  8016db:	e9 65 fe ff ff       	jmp    801545 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8016e0:	c7 44 24 04 67 24 80 	movl   $0x802467,0x4(%esp)
  8016e7:	00 
  8016e8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8016eb:	89 0c 24             	mov    %ecx,(%esp)
  8016ee:	e8 c8 04 00 00       	call   801bbb <strcmp>
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	75 0f                	jne    801706 <vprintfmt+0x1e4>
  8016f7:	c7 05 58 30 80 00 01 	movl   $0x1,0x803058
  8016fe:	00 00 00 
  801701:	e9 3f fe ff ff       	jmp    801545 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  801706:	c7 44 24 04 6b 24 80 	movl   $0x80246b,0x4(%esp)
  80170d:	00 
  80170e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  801711:	89 3c 24             	mov    %edi,(%esp)
  801714:	e8 a2 04 00 00       	call   801bbb <strcmp>
  801719:	85 c0                	test   %eax,%eax
  80171b:	75 0f                	jne    80172c <vprintfmt+0x20a>
  80171d:	c7 05 58 30 80 00 06 	movl   $0x6,0x803058
  801724:	00 00 00 
  801727:	e9 19 fe ff ff       	jmp    801545 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80172c:	c7 44 24 04 6f 24 80 	movl   $0x80246f,0x4(%esp)
  801733:	00 
  801734:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 7c 04 00 00       	call   801bbb <strcmp>
  80173f:	85 c0                	test   %eax,%eax
  801741:	75 0f                	jne    801752 <vprintfmt+0x230>
  801743:	c7 05 58 30 80 00 07 	movl   $0x7,0x803058
  80174a:	00 00 00 
  80174d:	e9 f3 fd ff ff       	jmp    801545 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  801752:	c7 44 24 04 73 24 80 	movl   $0x802473,0x4(%esp)
  801759:	00 
  80175a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80175d:	89 14 24             	mov    %edx,(%esp)
  801760:	e8 56 04 00 00       	call   801bbb <strcmp>
  801765:	83 f8 01             	cmp    $0x1,%eax
  801768:	19 c0                	sbb    %eax,%eax
  80176a:	f7 d0                	not    %eax
  80176c:	83 c0 08             	add    $0x8,%eax
  80176f:	a3 58 30 80 00       	mov    %eax,0x803058
  801774:	e9 cc fd ff ff       	jmp    801545 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  801779:	8b 45 14             	mov    0x14(%ebp),%eax
  80177c:	8d 50 04             	lea    0x4(%eax),%edx
  80177f:	89 55 14             	mov    %edx,0x14(%ebp)
  801782:	8b 00                	mov    (%eax),%eax
  801784:	89 c2                	mov    %eax,%edx
  801786:	c1 fa 1f             	sar    $0x1f,%edx
  801789:	31 d0                	xor    %edx,%eax
  80178b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80178d:	83 f8 0f             	cmp    $0xf,%eax
  801790:	7f 0b                	jg     80179d <vprintfmt+0x27b>
  801792:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  801799:	85 d2                	test   %edx,%edx
  80179b:	75 23                	jne    8017c0 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80179d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a1:	c7 44 24 08 77 24 80 	movl   $0x802477,0x8(%esp)
  8017a8:	00 
  8017a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017b0:	89 3c 24             	mov    %edi,(%esp)
  8017b3:	e8 42 fd ff ff       	call   8014fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017bb:	e9 85 fd ff ff       	jmp    801545 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8017c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017c4:	c7 44 24 08 dd 23 80 	movl   $0x8023dd,0x8(%esp)
  8017cb:	00 
  8017cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d3:	89 3c 24             	mov    %edi,(%esp)
  8017d6:	e8 1f fd ff ff       	call   8014fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017db:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8017de:	e9 62 fd ff ff       	jmp    801545 <vprintfmt+0x23>
  8017e3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8017e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8017e9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ef:	8d 50 04             	lea    0x4(%eax),%edx
  8017f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8017f5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8017f7:	85 f6                	test   %esi,%esi
  8017f9:	b8 58 24 80 00       	mov    $0x802458,%eax
  8017fe:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801801:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801805:	7e 06                	jle    80180d <vprintfmt+0x2eb>
  801807:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80180b:	75 13                	jne    801820 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80180d:	0f be 06             	movsbl (%esi),%eax
  801810:	83 c6 01             	add    $0x1,%esi
  801813:	85 c0                	test   %eax,%eax
  801815:	0f 85 94 00 00 00    	jne    8018af <vprintfmt+0x38d>
  80181b:	e9 81 00 00 00       	jmp    8018a1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801820:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801824:	89 34 24             	mov    %esi,(%esp)
  801827:	e8 9f 02 00 00       	call   801acb <strnlen>
  80182c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80182f:	29 c2                	sub    %eax,%edx
  801831:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801834:	85 d2                	test   %edx,%edx
  801836:	7e d5                	jle    80180d <vprintfmt+0x2eb>
					putch(padc, putdat);
  801838:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80183c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80183f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  801842:	89 d6                	mov    %edx,%esi
  801844:	89 cf                	mov    %ecx,%edi
  801846:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80184a:	89 3c 24             	mov    %edi,(%esp)
  80184d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801850:	83 ee 01             	sub    $0x1,%esi
  801853:	75 f1                	jne    801846 <vprintfmt+0x324>
  801855:	8b 7d c0             	mov    -0x40(%ebp),%edi
  801858:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80185b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80185e:	eb ad                	jmp    80180d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801860:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  801864:	74 1b                	je     801881 <vprintfmt+0x35f>
  801866:	8d 50 e0             	lea    -0x20(%eax),%edx
  801869:	83 fa 5e             	cmp    $0x5e,%edx
  80186c:	76 13                	jbe    801881 <vprintfmt+0x35f>
					putch('?', putdat);
  80186e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801871:	89 44 24 04          	mov    %eax,0x4(%esp)
  801875:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80187c:	ff 55 08             	call   *0x8(%ebp)
  80187f:	eb 0d                	jmp    80188e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  801881:	8b 55 d0             	mov    -0x30(%ebp),%edx
  801884:	89 54 24 04          	mov    %edx,0x4(%esp)
  801888:	89 04 24             	mov    %eax,(%esp)
  80188b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80188e:	83 eb 01             	sub    $0x1,%ebx
  801891:	0f be 06             	movsbl (%esi),%eax
  801894:	83 c6 01             	add    $0x1,%esi
  801897:	85 c0                	test   %eax,%eax
  801899:	75 1a                	jne    8018b5 <vprintfmt+0x393>
  80189b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80189e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018a4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8018a8:	7f 1c                	jg     8018c6 <vprintfmt+0x3a4>
  8018aa:	e9 96 fc ff ff       	jmp    801545 <vprintfmt+0x23>
  8018af:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8018b2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018b5:	85 ff                	test   %edi,%edi
  8018b7:	78 a7                	js     801860 <vprintfmt+0x33e>
  8018b9:	83 ef 01             	sub    $0x1,%edi
  8018bc:	79 a2                	jns    801860 <vprintfmt+0x33e>
  8018be:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8018c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8018c4:	eb db                	jmp    8018a1 <vprintfmt+0x37f>
  8018c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018c9:	89 de                	mov    %ebx,%esi
  8018cb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8018d9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018db:	83 eb 01             	sub    $0x1,%ebx
  8018de:	75 ee                	jne    8018ce <vprintfmt+0x3ac>
  8018e0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8018e5:	e9 5b fc ff ff       	jmp    801545 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018ea:	83 f9 01             	cmp    $0x1,%ecx
  8018ed:	7e 10                	jle    8018ff <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8018ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f2:	8d 50 08             	lea    0x8(%eax),%edx
  8018f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f8:	8b 30                	mov    (%eax),%esi
  8018fa:	8b 78 04             	mov    0x4(%eax),%edi
  8018fd:	eb 26                	jmp    801925 <vprintfmt+0x403>
	else if (lflag)
  8018ff:	85 c9                	test   %ecx,%ecx
  801901:	74 12                	je     801915 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  801903:	8b 45 14             	mov    0x14(%ebp),%eax
  801906:	8d 50 04             	lea    0x4(%eax),%edx
  801909:	89 55 14             	mov    %edx,0x14(%ebp)
  80190c:	8b 30                	mov    (%eax),%esi
  80190e:	89 f7                	mov    %esi,%edi
  801910:	c1 ff 1f             	sar    $0x1f,%edi
  801913:	eb 10                	jmp    801925 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  801915:	8b 45 14             	mov    0x14(%ebp),%eax
  801918:	8d 50 04             	lea    0x4(%eax),%edx
  80191b:	89 55 14             	mov    %edx,0x14(%ebp)
  80191e:	8b 30                	mov    (%eax),%esi
  801920:	89 f7                	mov    %esi,%edi
  801922:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801925:	85 ff                	test   %edi,%edi
  801927:	78 0e                	js     801937 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801929:	89 f0                	mov    %esi,%eax
  80192b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80192d:	be 0a 00 00 00       	mov    $0xa,%esi
  801932:	e9 84 00 00 00       	jmp    8019bb <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801937:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80193b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801942:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801945:	89 f0                	mov    %esi,%eax
  801947:	89 fa                	mov    %edi,%edx
  801949:	f7 d8                	neg    %eax
  80194b:	83 d2 00             	adc    $0x0,%edx
  80194e:	f7 da                	neg    %edx
			}
			base = 10;
  801950:	be 0a 00 00 00       	mov    $0xa,%esi
  801955:	eb 64                	jmp    8019bb <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801957:	89 ca                	mov    %ecx,%edx
  801959:	8d 45 14             	lea    0x14(%ebp),%eax
  80195c:	e8 42 fb ff ff       	call   8014a3 <getuint>
			base = 10;
  801961:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  801966:	eb 53                	jmp    8019bb <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801968:	89 ca                	mov    %ecx,%edx
  80196a:	8d 45 14             	lea    0x14(%ebp),%eax
  80196d:	e8 31 fb ff ff       	call   8014a3 <getuint>
    			base = 8;
  801972:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  801977:	eb 42                	jmp    8019bb <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  801979:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801984:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801987:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801992:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801995:	8b 45 14             	mov    0x14(%ebp),%eax
  801998:	8d 50 04             	lea    0x4(%eax),%edx
  80199b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80199e:	8b 00                	mov    (%eax),%eax
  8019a0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019a5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8019aa:	eb 0f                	jmp    8019bb <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019ac:	89 ca                	mov    %ecx,%edx
  8019ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8019b1:	e8 ed fa ff ff       	call   8014a3 <getuint>
			base = 16;
  8019b6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019bb:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8019bf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8019c3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8019c6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019ca:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019d5:	89 da                	mov    %ebx,%edx
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	e8 e9 f9 ff ff       	call   8013c8 <printnum>
			break;
  8019df:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8019e2:	e9 5e fb ff ff       	jmp    801545 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019eb:	89 14 24             	mov    %edx,(%esp)
  8019ee:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8019f4:	e9 4c fb ff ff       	jmp    801545 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019fd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801a04:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a07:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a0b:	0f 84 34 fb ff ff    	je     801545 <vprintfmt+0x23>
  801a11:	83 ee 01             	sub    $0x1,%esi
  801a14:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a18:	75 f7                	jne    801a11 <vprintfmt+0x4ef>
  801a1a:	e9 26 fb ff ff       	jmp    801545 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801a1f:	83 c4 5c             	add    $0x5c,%esp
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5f                   	pop    %edi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 28             	sub    $0x28,%esp
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a36:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a44:	85 c0                	test   %eax,%eax
  801a46:	74 30                	je     801a78 <vsnprintf+0x51>
  801a48:	85 d2                	test   %edx,%edx
  801a4a:	7e 2c                	jle    801a78 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a53:	8b 45 10             	mov    0x10(%ebp),%eax
  801a56:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a61:	c7 04 24 dd 14 80 00 	movl   $0x8014dd,(%esp)
  801a68:	e8 b5 fa ff ff       	call   801522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a70:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a76:	eb 05                	jmp    801a7d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a85:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	89 04 24             	mov    %eax,(%esp)
  801aa0:	e8 82 ff ff ff       	call   801a27 <vsnprintf>
	va_end(ap);

	return rc;
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    
	...

00801ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  801abb:	80 3a 00             	cmpb   $0x0,(%edx)
  801abe:	74 09                	je     801ac9 <strlen+0x19>
		n++;
  801ac0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ac3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ac7:	75 f7                	jne    801ac0 <strlen+0x10>
		n++;
	return n;
}
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	53                   	push   %ebx
  801acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ada:	85 c9                	test   %ecx,%ecx
  801adc:	74 1a                	je     801af8 <strnlen+0x2d>
  801ade:	80 3b 00             	cmpb   $0x0,(%ebx)
  801ae1:	74 15                	je     801af8 <strnlen+0x2d>
  801ae3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801ae8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801aea:	39 ca                	cmp    %ecx,%edx
  801aec:	74 0a                	je     801af8 <strnlen+0x2d>
  801aee:	83 c2 01             	add    $0x1,%edx
  801af1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801af6:	75 f0                	jne    801ae8 <strnlen+0x1d>
		n++;
	return n;
}
  801af8:	5b                   	pop    %ebx
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	53                   	push   %ebx
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b05:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801b0e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801b11:	83 c2 01             	add    $0x1,%edx
  801b14:	84 c9                	test   %cl,%cl
  801b16:	75 f2                	jne    801b0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b18:	5b                   	pop    %ebx
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	53                   	push   %ebx
  801b1f:	83 ec 08             	sub    $0x8,%esp
  801b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b25:	89 1c 24             	mov    %ebx,(%esp)
  801b28:	e8 83 ff ff ff       	call   801ab0 <strlen>
	strcpy(dst + len, src);
  801b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b30:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b34:	01 d8                	add    %ebx,%eax
  801b36:	89 04 24             	mov    %eax,(%esp)
  801b39:	e8 bd ff ff ff       	call   801afb <strcpy>
	return dst;
}
  801b3e:	89 d8                	mov    %ebx,%eax
  801b40:	83 c4 08             	add    $0x8,%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	56                   	push   %esi
  801b4a:	53                   	push   %ebx
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b54:	85 f6                	test   %esi,%esi
  801b56:	74 18                	je     801b70 <strncpy+0x2a>
  801b58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b5d:	0f b6 1a             	movzbl (%edx),%ebx
  801b60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b63:	80 3a 01             	cmpb   $0x1,(%edx)
  801b66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b69:	83 c1 01             	add    $0x1,%ecx
  801b6c:	39 f1                	cmp    %esi,%ecx
  801b6e:	75 ed                	jne    801b5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b80:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b83:	89 f8                	mov    %edi,%eax
  801b85:	85 f6                	test   %esi,%esi
  801b87:	74 2b                	je     801bb4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801b89:	83 fe 01             	cmp    $0x1,%esi
  801b8c:	74 23                	je     801bb1 <strlcpy+0x3d>
  801b8e:	0f b6 0b             	movzbl (%ebx),%ecx
  801b91:	84 c9                	test   %cl,%cl
  801b93:	74 1c                	je     801bb1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801b95:	83 ee 02             	sub    $0x2,%esi
  801b98:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b9d:	88 08                	mov    %cl,(%eax)
  801b9f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ba2:	39 f2                	cmp    %esi,%edx
  801ba4:	74 0b                	je     801bb1 <strlcpy+0x3d>
  801ba6:	83 c2 01             	add    $0x1,%edx
  801ba9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801bad:	84 c9                	test   %cl,%cl
  801baf:	75 ec                	jne    801b9d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  801bb1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bb4:	29 f8                	sub    %edi,%eax
}
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5f                   	pop    %edi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bc4:	0f b6 01             	movzbl (%ecx),%eax
  801bc7:	84 c0                	test   %al,%al
  801bc9:	74 16                	je     801be1 <strcmp+0x26>
  801bcb:	3a 02                	cmp    (%edx),%al
  801bcd:	75 12                	jne    801be1 <strcmp+0x26>
		p++, q++;
  801bcf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bd2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801bd6:	84 c0                	test   %al,%al
  801bd8:	74 07                	je     801be1 <strcmp+0x26>
  801bda:	83 c1 01             	add    $0x1,%ecx
  801bdd:	3a 02                	cmp    (%edx),%al
  801bdf:	74 ee                	je     801bcf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801be1:	0f b6 c0             	movzbl %al,%eax
  801be4:	0f b6 12             	movzbl (%edx),%edx
  801be7:	29 d0                	sub    %edx,%eax
}
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	53                   	push   %ebx
  801bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bf5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bfd:	85 d2                	test   %edx,%edx
  801bff:	74 28                	je     801c29 <strncmp+0x3e>
  801c01:	0f b6 01             	movzbl (%ecx),%eax
  801c04:	84 c0                	test   %al,%al
  801c06:	74 24                	je     801c2c <strncmp+0x41>
  801c08:	3a 03                	cmp    (%ebx),%al
  801c0a:	75 20                	jne    801c2c <strncmp+0x41>
  801c0c:	83 ea 01             	sub    $0x1,%edx
  801c0f:	74 13                	je     801c24 <strncmp+0x39>
		n--, p++, q++;
  801c11:	83 c1 01             	add    $0x1,%ecx
  801c14:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c17:	0f b6 01             	movzbl (%ecx),%eax
  801c1a:	84 c0                	test   %al,%al
  801c1c:	74 0e                	je     801c2c <strncmp+0x41>
  801c1e:	3a 03                	cmp    (%ebx),%al
  801c20:	74 ea                	je     801c0c <strncmp+0x21>
  801c22:	eb 08                	jmp    801c2c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c29:	5b                   	pop    %ebx
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c2c:	0f b6 01             	movzbl (%ecx),%eax
  801c2f:	0f b6 13             	movzbl (%ebx),%edx
  801c32:	29 d0                	sub    %edx,%eax
  801c34:	eb f3                	jmp    801c29 <strncmp+0x3e>

00801c36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c40:	0f b6 10             	movzbl (%eax),%edx
  801c43:	84 d2                	test   %dl,%dl
  801c45:	74 1c                	je     801c63 <strchr+0x2d>
		if (*s == c)
  801c47:	38 ca                	cmp    %cl,%dl
  801c49:	75 09                	jne    801c54 <strchr+0x1e>
  801c4b:	eb 1b                	jmp    801c68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c4d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  801c50:	38 ca                	cmp    %cl,%dl
  801c52:	74 14                	je     801c68 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c54:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  801c58:	84 d2                	test   %dl,%dl
  801c5a:	75 f1                	jne    801c4d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c61:	eb 05                	jmp    801c68 <strchr+0x32>
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c74:	0f b6 10             	movzbl (%eax),%edx
  801c77:	84 d2                	test   %dl,%dl
  801c79:	74 14                	je     801c8f <strfind+0x25>
		if (*s == c)
  801c7b:	38 ca                	cmp    %cl,%dl
  801c7d:	75 06                	jne    801c85 <strfind+0x1b>
  801c7f:	eb 0e                	jmp    801c8f <strfind+0x25>
  801c81:	38 ca                	cmp    %cl,%dl
  801c83:	74 0a                	je     801c8f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c85:	83 c0 01             	add    $0x1,%eax
  801c88:	0f b6 10             	movzbl (%eax),%edx
  801c8b:	84 d2                	test   %dl,%dl
  801c8d:	75 f2                	jne    801c81 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca9:	85 c9                	test   %ecx,%ecx
  801cab:	74 30                	je     801cdd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb3:	75 25                	jne    801cda <memset+0x49>
  801cb5:	f6 c1 03             	test   $0x3,%cl
  801cb8:	75 20                	jne    801cda <memset+0x49>
		c &= 0xFF;
  801cba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cbd:	89 d3                	mov    %edx,%ebx
  801cbf:	c1 e3 08             	shl    $0x8,%ebx
  801cc2:	89 d6                	mov    %edx,%esi
  801cc4:	c1 e6 18             	shl    $0x18,%esi
  801cc7:	89 d0                	mov    %edx,%eax
  801cc9:	c1 e0 10             	shl    $0x10,%eax
  801ccc:	09 f0                	or     %esi,%eax
  801cce:	09 d0                	or     %edx,%eax
  801cd0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cd2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801cd5:	fc                   	cld    
  801cd6:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd8:	eb 03                	jmp    801cdd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cda:	fc                   	cld    
  801cdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cdd:	89 f8                	mov    %edi,%eax
  801cdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ce2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ce5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ce8:	89 ec                	mov    %ebp,%esp
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
  801cf2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cf5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d01:	39 c6                	cmp    %eax,%esi
  801d03:	73 36                	jae    801d3b <memmove+0x4f>
  801d05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d08:	39 d0                	cmp    %edx,%eax
  801d0a:	73 2f                	jae    801d3b <memmove+0x4f>
		s += n;
		d += n;
  801d0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d0f:	f6 c2 03             	test   $0x3,%dl
  801d12:	75 1b                	jne    801d2f <memmove+0x43>
  801d14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d1a:	75 13                	jne    801d2f <memmove+0x43>
  801d1c:	f6 c1 03             	test   $0x3,%cl
  801d1f:	75 0e                	jne    801d2f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d21:	83 ef 04             	sub    $0x4,%edi
  801d24:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d2a:	fd                   	std    
  801d2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d2d:	eb 09                	jmp    801d38 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d2f:	83 ef 01             	sub    $0x1,%edi
  801d32:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d35:	fd                   	std    
  801d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d38:	fc                   	cld    
  801d39:	eb 20                	jmp    801d5b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d3b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d41:	75 13                	jne    801d56 <memmove+0x6a>
  801d43:	a8 03                	test   $0x3,%al
  801d45:	75 0f                	jne    801d56 <memmove+0x6a>
  801d47:	f6 c1 03             	test   $0x3,%cl
  801d4a:	75 0a                	jne    801d56 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d4c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801d4f:	89 c7                	mov    %eax,%edi
  801d51:	fc                   	cld    
  801d52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d54:	eb 05                	jmp    801d5b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d56:	89 c7                	mov    %eax,%edi
  801d58:	fc                   	cld    
  801d59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d61:	89 ec                	mov    %ebp,%esp
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d6b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	89 04 24             	mov    %eax,(%esp)
  801d7f:	e8 68 ff ff ff       	call   801cec <memmove>
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	57                   	push   %edi
  801d8a:	56                   	push   %esi
  801d8b:	53                   	push   %ebx
  801d8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d92:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d9a:	85 ff                	test   %edi,%edi
  801d9c:	74 37                	je     801dd5 <memcmp+0x4f>
		if (*s1 != *s2)
  801d9e:	0f b6 03             	movzbl (%ebx),%eax
  801da1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da4:	83 ef 01             	sub    $0x1,%edi
  801da7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  801dac:	38 c8                	cmp    %cl,%al
  801dae:	74 1c                	je     801dcc <memcmp+0x46>
  801db0:	eb 10                	jmp    801dc2 <memcmp+0x3c>
  801db2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801db7:	83 c2 01             	add    $0x1,%edx
  801dba:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801dbe:	38 c8                	cmp    %cl,%al
  801dc0:	74 0a                	je     801dcc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801dc2:	0f b6 c0             	movzbl %al,%eax
  801dc5:	0f b6 c9             	movzbl %cl,%ecx
  801dc8:	29 c8                	sub    %ecx,%eax
  801dca:	eb 09                	jmp    801dd5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dcc:	39 fa                	cmp    %edi,%edx
  801dce:	75 e2                	jne    801db2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5f                   	pop    %edi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    

00801dda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801de0:	89 c2                	mov    %eax,%edx
  801de2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801de5:	39 d0                	cmp    %edx,%eax
  801de7:	73 19                	jae    801e02 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801ded:	38 08                	cmp    %cl,(%eax)
  801def:	75 06                	jne    801df7 <memfind+0x1d>
  801df1:	eb 0f                	jmp    801e02 <memfind+0x28>
  801df3:	38 08                	cmp    %cl,(%eax)
  801df5:	74 0b                	je     801e02 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801df7:	83 c0 01             	add    $0x1,%eax
  801dfa:	39 d0                	cmp    %edx,%eax
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	75 f1                	jne    801df3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	57                   	push   %edi
  801e08:	56                   	push   %esi
  801e09:	53                   	push   %ebx
  801e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e10:	0f b6 02             	movzbl (%edx),%eax
  801e13:	3c 20                	cmp    $0x20,%al
  801e15:	74 04                	je     801e1b <strtol+0x17>
  801e17:	3c 09                	cmp    $0x9,%al
  801e19:	75 0e                	jne    801e29 <strtol+0x25>
		s++;
  801e1b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e1e:	0f b6 02             	movzbl (%edx),%eax
  801e21:	3c 20                	cmp    $0x20,%al
  801e23:	74 f6                	je     801e1b <strtol+0x17>
  801e25:	3c 09                	cmp    $0x9,%al
  801e27:	74 f2                	je     801e1b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e29:	3c 2b                	cmp    $0x2b,%al
  801e2b:	75 0a                	jne    801e37 <strtol+0x33>
		s++;
  801e2d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e30:	bf 00 00 00 00       	mov    $0x0,%edi
  801e35:	eb 10                	jmp    801e47 <strtol+0x43>
  801e37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e3c:	3c 2d                	cmp    $0x2d,%al
  801e3e:	75 07                	jne    801e47 <strtol+0x43>
		s++, neg = 1;
  801e40:	83 c2 01             	add    $0x1,%edx
  801e43:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e47:	85 db                	test   %ebx,%ebx
  801e49:	0f 94 c0             	sete   %al
  801e4c:	74 05                	je     801e53 <strtol+0x4f>
  801e4e:	83 fb 10             	cmp    $0x10,%ebx
  801e51:	75 15                	jne    801e68 <strtol+0x64>
  801e53:	80 3a 30             	cmpb   $0x30,(%edx)
  801e56:	75 10                	jne    801e68 <strtol+0x64>
  801e58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e5c:	75 0a                	jne    801e68 <strtol+0x64>
		s += 2, base = 16;
  801e5e:	83 c2 02             	add    $0x2,%edx
  801e61:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e66:	eb 13                	jmp    801e7b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801e68:	84 c0                	test   %al,%al
  801e6a:	74 0f                	je     801e7b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e71:	80 3a 30             	cmpb   $0x30,(%edx)
  801e74:	75 05                	jne    801e7b <strtol+0x77>
		s++, base = 8;
  801e76:	83 c2 01             	add    $0x1,%edx
  801e79:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e82:	0f b6 0a             	movzbl (%edx),%ecx
  801e85:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e88:	80 fb 09             	cmp    $0x9,%bl
  801e8b:	77 08                	ja     801e95 <strtol+0x91>
			dig = *s - '0';
  801e8d:	0f be c9             	movsbl %cl,%ecx
  801e90:	83 e9 30             	sub    $0x30,%ecx
  801e93:	eb 1e                	jmp    801eb3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801e95:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801e98:	80 fb 19             	cmp    $0x19,%bl
  801e9b:	77 08                	ja     801ea5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  801e9d:	0f be c9             	movsbl %cl,%ecx
  801ea0:	83 e9 57             	sub    $0x57,%ecx
  801ea3:	eb 0e                	jmp    801eb3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801ea5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801ea8:	80 fb 19             	cmp    $0x19,%bl
  801eab:	77 14                	ja     801ec1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ead:	0f be c9             	movsbl %cl,%ecx
  801eb0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801eb3:	39 f1                	cmp    %esi,%ecx
  801eb5:	7d 0e                	jge    801ec5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801eb7:	83 c2 01             	add    $0x1,%edx
  801eba:	0f af c6             	imul   %esi,%eax
  801ebd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801ebf:	eb c1                	jmp    801e82 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801ec1:	89 c1                	mov    %eax,%ecx
  801ec3:	eb 02                	jmp    801ec7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ec5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801ec7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ecb:	74 05                	je     801ed2 <strtol+0xce>
		*endptr = (char *) s;
  801ecd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ed0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801ed2:	89 ca                	mov    %ecx,%edx
  801ed4:	f7 da                	neg    %edx
  801ed6:	85 ff                	test   %edi,%edi
  801ed8:	0f 45 c2             	cmovne %edx,%eax
}
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5f                   	pop    %edi
  801ede:	5d                   	pop    %ebp
  801edf:	c3                   	ret    

00801ee0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 10             	sub    $0x10,%esp
  801ee8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eee:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ef1:	85 db                	test   %ebx,%ebx
  801ef3:	74 06                	je     801efb <ipc_recv+0x1b>
  801ef5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801efb:	85 f6                	test   %esi,%esi
  801efd:	74 06                	je     801f05 <ipc_recv+0x25>
  801eff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f05:	85 c0                	test   %eax,%eax
  801f07:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f0c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f0f:	89 04 24             	mov    %eax,(%esp)
  801f12:	e8 1a e5 ff ff       	call   800431 <sys_ipc_recv>
    if (ret) return ret;
  801f17:	85 c0                	test   %eax,%eax
  801f19:	75 24                	jne    801f3f <ipc_recv+0x5f>
    if (from_env_store)
  801f1b:	85 db                	test   %ebx,%ebx
  801f1d:	74 0a                	je     801f29 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f1f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f24:	8b 40 74             	mov    0x74(%eax),%eax
  801f27:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f29:	85 f6                	test   %esi,%esi
  801f2b:	74 0a                	je     801f37 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f32:	8b 40 78             	mov    0x78(%eax),%eax
  801f35:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f37:	a1 04 40 80 00       	mov    0x804004,%eax
  801f3c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	5b                   	pop    %ebx
  801f43:	5e                   	pop    %esi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	57                   	push   %edi
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
  801f4c:	83 ec 1c             	sub    $0x1c,%esp
  801f4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f52:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f58:	85 db                	test   %ebx,%ebx
  801f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f5f:	0f 44 d8             	cmove  %eax,%ebx
  801f62:	eb 2a                	jmp    801f8e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801f64:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f67:	74 20                	je     801f89 <ipc_send+0x43>
  801f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6d:	c7 44 24 08 60 27 80 	movl   $0x802760,0x8(%esp)
  801f74:	00 
  801f75:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801f7c:	00 
  801f7d:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  801f84:	e8 27 f3 ff ff       	call   8012b0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801f89:	e8 0a e2 ff ff       	call   800198 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f95:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f99:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f9d:	89 34 24             	mov    %esi,(%esp)
  801fa0:	e8 58 e4 ff ff       	call   8003fd <sys_ipc_try_send>
  801fa5:	85 c0                	test   %eax,%eax
  801fa7:	75 bb                	jne    801f64 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fa9:	83 c4 1c             	add    $0x1c,%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5e                   	pop    %esi
  801fae:	5f                   	pop    %edi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fb7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801fbc:	39 c8                	cmp    %ecx,%eax
  801fbe:	74 19                	je     801fd9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fc0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	c1 e2 07             	shl    $0x7,%edx
  801fca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fd0:	8b 52 50             	mov    0x50(%edx),%edx
  801fd3:	39 ca                	cmp    %ecx,%edx
  801fd5:	75 14                	jne    801feb <ipc_find_env+0x3a>
  801fd7:	eb 05                	jmp    801fde <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801fde:	c1 e0 07             	shl    $0x7,%eax
  801fe1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801fe6:	8b 40 40             	mov    0x40(%eax),%eax
  801fe9:	eb 0e                	jmp    801ff9 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801feb:	83 c0 01             	add    $0x1,%eax
  801fee:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff3:	75 d0                	jne    801fc5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ff5:	66 b8 00 00          	mov    $0x0,%ax
}
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    
	...

00801ffc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802002:	89 d0                	mov    %edx,%eax
  802004:	c1 e8 16             	shr    $0x16,%eax
  802007:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802013:	f6 c1 01             	test   $0x1,%cl
  802016:	74 1d                	je     802035 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802018:	c1 ea 0c             	shr    $0xc,%edx
  80201b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802022:	f6 c2 01             	test   $0x1,%dl
  802025:	74 0e                	je     802035 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802027:	c1 ea 0c             	shr    $0xc,%edx
  80202a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802031:	ef 
  802032:	0f b7 c0             	movzwl %ax,%eax
}
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    
	...

00802040 <__udivdi3>:
  802040:	83 ec 1c             	sub    $0x1c,%esp
  802043:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802047:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80204b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80204f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802053:	89 74 24 10          	mov    %esi,0x10(%esp)
  802057:	8b 74 24 24          	mov    0x24(%esp),%esi
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802061:	89 44 24 08          	mov    %eax,0x8(%esp)
  802065:	89 cd                	mov    %ecx,%ebp
  802067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206b:	75 33                	jne    8020a0 <__udivdi3+0x60>
  80206d:	39 f1                	cmp    %esi,%ecx
  80206f:	77 57                	ja     8020c8 <__udivdi3+0x88>
  802071:	85 c9                	test   %ecx,%ecx
  802073:	75 0b                	jne    802080 <__udivdi3+0x40>
  802075:	b8 01 00 00 00       	mov    $0x1,%eax
  80207a:	31 d2                	xor    %edx,%edx
  80207c:	f7 f1                	div    %ecx
  80207e:	89 c1                	mov    %eax,%ecx
  802080:	89 f0                	mov    %esi,%eax
  802082:	31 d2                	xor    %edx,%edx
  802084:	f7 f1                	div    %ecx
  802086:	89 c6                	mov    %eax,%esi
  802088:	8b 44 24 04          	mov    0x4(%esp),%eax
  80208c:	f7 f1                	div    %ecx
  80208e:	89 f2                	mov    %esi,%edx
  802090:	8b 74 24 10          	mov    0x10(%esp),%esi
  802094:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802098:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	c3                   	ret    
  8020a0:	31 d2                	xor    %edx,%edx
  8020a2:	31 c0                	xor    %eax,%eax
  8020a4:	39 f7                	cmp    %esi,%edi
  8020a6:	77 e8                	ja     802090 <__udivdi3+0x50>
  8020a8:	0f bd cf             	bsr    %edi,%ecx
  8020ab:	83 f1 1f             	xor    $0x1f,%ecx
  8020ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020b2:	75 2c                	jne    8020e0 <__udivdi3+0xa0>
  8020b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020b8:	76 04                	jbe    8020be <__udivdi3+0x7e>
  8020ba:	39 f7                	cmp    %esi,%edi
  8020bc:	73 d2                	jae    802090 <__udivdi3+0x50>
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c5:	eb c9                	jmp    802090 <__udivdi3+0x50>
  8020c7:	90                   	nop
  8020c8:	89 f2                	mov    %esi,%edx
  8020ca:	f7 f1                	div    %ecx
  8020cc:	31 d2                	xor    %edx,%edx
  8020ce:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	c3                   	ret    
  8020de:	66 90                	xchg   %ax,%ax
  8020e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020e5:	b8 20 00 00 00       	mov    $0x20,%eax
  8020ea:	89 ea                	mov    %ebp,%edx
  8020ec:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020f0:	d3 e7                	shl    %cl,%edi
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	d3 ea                	shr    %cl,%edx
  8020f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020fb:	09 fa                	or     %edi,%edx
  8020fd:	89 f7                	mov    %esi,%edi
  8020ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802103:	89 f2                	mov    %esi,%edx
  802105:	8b 74 24 08          	mov    0x8(%esp),%esi
  802109:	d3 e5                	shl    %cl,%ebp
  80210b:	89 c1                	mov    %eax,%ecx
  80210d:	d3 ef                	shr    %cl,%edi
  80210f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802114:	d3 e2                	shl    %cl,%edx
  802116:	89 c1                	mov    %eax,%ecx
  802118:	d3 ee                	shr    %cl,%esi
  80211a:	09 d6                	or     %edx,%esi
  80211c:	89 fa                	mov    %edi,%edx
  80211e:	89 f0                	mov    %esi,%eax
  802120:	f7 74 24 0c          	divl   0xc(%esp)
  802124:	89 d7                	mov    %edx,%edi
  802126:	89 c6                	mov    %eax,%esi
  802128:	f7 e5                	mul    %ebp
  80212a:	39 d7                	cmp    %edx,%edi
  80212c:	72 22                	jb     802150 <__udivdi3+0x110>
  80212e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802132:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802137:	d3 e5                	shl    %cl,%ebp
  802139:	39 c5                	cmp    %eax,%ebp
  80213b:	73 04                	jae    802141 <__udivdi3+0x101>
  80213d:	39 d7                	cmp    %edx,%edi
  80213f:	74 0f                	je     802150 <__udivdi3+0x110>
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	e9 46 ff ff ff       	jmp    802090 <__udivdi3+0x50>
  80214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802150:	8d 46 ff             	lea    -0x1(%esi),%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	8b 74 24 10          	mov    0x10(%esp),%esi
  802159:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80215d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	c3                   	ret    
	...

00802170 <__umoddi3>:
  802170:	83 ec 1c             	sub    $0x1c,%esp
  802173:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802177:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80217b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80217f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802183:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802187:	8b 74 24 24          	mov    0x24(%esp),%esi
  80218b:	85 ed                	test   %ebp,%ebp
  80218d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802191:	89 44 24 08          	mov    %eax,0x8(%esp)
  802195:	89 cf                	mov    %ecx,%edi
  802197:	89 04 24             	mov    %eax,(%esp)
  80219a:	89 f2                	mov    %esi,%edx
  80219c:	75 1a                	jne    8021b8 <__umoddi3+0x48>
  80219e:	39 f1                	cmp    %esi,%ecx
  8021a0:	76 4e                	jbe    8021f0 <__umoddi3+0x80>
  8021a2:	f7 f1                	div    %ecx
  8021a4:	89 d0                	mov    %edx,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	c3                   	ret    
  8021b8:	39 f5                	cmp    %esi,%ebp
  8021ba:	77 54                	ja     802210 <__umoddi3+0xa0>
  8021bc:	0f bd c5             	bsr    %ebp,%eax
  8021bf:	83 f0 1f             	xor    $0x1f,%eax
  8021c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c6:	75 60                	jne    802228 <__umoddi3+0xb8>
  8021c8:	3b 0c 24             	cmp    (%esp),%ecx
  8021cb:	0f 87 07 01 00 00    	ja     8022d8 <__umoddi3+0x168>
  8021d1:	89 f2                	mov    %esi,%edx
  8021d3:	8b 34 24             	mov    (%esp),%esi
  8021d6:	29 ce                	sub    %ecx,%esi
  8021d8:	19 ea                	sbb    %ebp,%edx
  8021da:	89 34 24             	mov    %esi,(%esp)
  8021dd:	8b 04 24             	mov    (%esp),%eax
  8021e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	c3                   	ret    
  8021f0:	85 c9                	test   %ecx,%ecx
  8021f2:	75 0b                	jne    8021ff <__umoddi3+0x8f>
  8021f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f9:	31 d2                	xor    %edx,%edx
  8021fb:	f7 f1                	div    %ecx
  8021fd:	89 c1                	mov    %eax,%ecx
  8021ff:	89 f0                	mov    %esi,%eax
  802201:	31 d2                	xor    %edx,%edx
  802203:	f7 f1                	div    %ecx
  802205:	8b 04 24             	mov    (%esp),%eax
  802208:	f7 f1                	div    %ecx
  80220a:	eb 98                	jmp    8021a4 <__umoddi3+0x34>
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 f2                	mov    %esi,%edx
  802212:	8b 74 24 10          	mov    0x10(%esp),%esi
  802216:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80221a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80221e:	83 c4 1c             	add    $0x1c,%esp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80222d:	89 e8                	mov    %ebp,%eax
  80222f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802234:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802238:	89 fa                	mov    %edi,%edx
  80223a:	d3 e0                	shl    %cl,%eax
  80223c:	89 e9                	mov    %ebp,%ecx
  80223e:	d3 ea                	shr    %cl,%edx
  802240:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802245:	09 c2                	or     %eax,%edx
  802247:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224b:	89 14 24             	mov    %edx,(%esp)
  80224e:	89 f2                	mov    %esi,%edx
  802250:	d3 e7                	shl    %cl,%edi
  802252:	89 e9                	mov    %ebp,%ecx
  802254:	d3 ea                	shr    %cl,%edx
  802256:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80225b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80225f:	d3 e6                	shl    %cl,%esi
  802261:	89 e9                	mov    %ebp,%ecx
  802263:	d3 e8                	shr    %cl,%eax
  802265:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80226a:	09 f0                	or     %esi,%eax
  80226c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802270:	f7 34 24             	divl   (%esp)
  802273:	d3 e6                	shl    %cl,%esi
  802275:	89 74 24 08          	mov    %esi,0x8(%esp)
  802279:	89 d6                	mov    %edx,%esi
  80227b:	f7 e7                	mul    %edi
  80227d:	39 d6                	cmp    %edx,%esi
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	89 d7                	mov    %edx,%edi
  802283:	72 3f                	jb     8022c4 <__umoddi3+0x154>
  802285:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802289:	72 35                	jb     8022c0 <__umoddi3+0x150>
  80228b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228f:	29 c8                	sub    %ecx,%eax
  802291:	19 fe                	sbb    %edi,%esi
  802293:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802298:	89 f2                	mov    %esi,%edx
  80229a:	d3 e8                	shr    %cl,%eax
  80229c:	89 e9                	mov    %ebp,%ecx
  80229e:	d3 e2                	shl    %cl,%edx
  8022a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022a5:	09 d0                	or     %edx,%eax
  8022a7:	89 f2                	mov    %esi,%edx
  8022a9:	d3 ea                	shr    %cl,%edx
  8022ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022b7:	83 c4 1c             	add    $0x1c,%esp
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 d6                	cmp    %edx,%esi
  8022c2:	75 c7                	jne    80228b <__umoddi3+0x11b>
  8022c4:	89 d7                	mov    %edx,%edi
  8022c6:	89 c1                	mov    %eax,%ecx
  8022c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8022cc:	1b 3c 24             	sbb    (%esp),%edi
  8022cf:	eb ba                	jmp    80228b <__umoddi3+0x11b>
  8022d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 f5                	cmp    %esi,%ebp
  8022da:	0f 82 f1 fe ff ff    	jb     8021d1 <__umoddi3+0x61>
  8022e0:	e9 f8 fe ff ff       	jmp    8021dd <__umoddi3+0x6d>
