
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 66 00 00 00       	call   8000b4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 09 01 00 00       	call   800170 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 61 00 00 00       	call   800113 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fc:	89 d1                	mov    %edx,%ecx
  8000fe:	89 d3                	mov    %edx,%ebx
  800100:	89 d7                	mov    %edx,%edi
  800102:	89 d6                	mov    %edx,%esi
  800104:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800106:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800109:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80010c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 38             	sub    $0x38,%esp
  800119:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80011c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	b9 00 00 00 00       	mov    $0x0,%ecx
  800127:	b8 03 00 00 00       	mov    $0x3,%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	89 cb                	mov    %ecx,%ebx
  800131:	89 cf                	mov    %ecx,%edi
  800133:	89 ce                	mov    %ecx,%esi
  800135:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800137:	85 c0                	test   %eax,%eax
  800139:	7e 28                	jle    800163 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800146:	00 
  800147:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  80014e:	00 
  80014f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800156:	00 
  800157:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  80015e:	e8 d5 02 00 00       	call   800438 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800163:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800166:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800169:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80016c:	89 ec                	mov    %ebp,%esp
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800179:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80017c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017f:	ba 00 00 00 00       	mov    $0x0,%edx
  800184:	b8 02 00 00 00       	mov    $0x2,%eax
  800189:	89 d1                	mov    %edx,%ecx
  80018b:	89 d3                	mov    %edx,%ebx
  80018d:	89 d7                	mov    %edx,%edi
  80018f:	89 d6                	mov    %edx,%esi
  800191:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800193:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800196:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800199:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019c:	89 ec                	mov    %ebp,%esp
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <sys_yield>:

void
sys_yield(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001b9:	89 d1                	mov    %edx,%ecx
  8001bb:	89 d3                	mov    %edx,%ebx
  8001bd:	89 d7                	mov    %edx,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001cc:	89 ec                	mov    %ebp,%esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 38             	sub    $0x38,%esp
  8001d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001df:	be 00 00 00 00       	mov    $0x0,%esi
  8001e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	89 f7                	mov    %esi,%edi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 28                	jle    800222 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800205:	00 
  800206:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  80021d:	e8 16 02 00 00       	call   800438 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800222:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800225:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800228:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80022b:	89 ec                	mov    %ebp,%esp
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 38             	sub    $0x38,%esp
  800235:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800238:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80023b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023e:	b8 05 00 00 00       	mov    $0x5,%eax
  800243:	8b 75 18             	mov    0x18(%ebp),%esi
  800246:	8b 7d 14             	mov    0x14(%ebp),%edi
  800249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800254:	85 c0                	test   %eax,%eax
  800256:	7e 28                	jle    800280 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800263:	00 
  800264:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  80026b:	00 
  80026c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800273:	00 
  800274:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  80027b:	e8 b8 01 00 00       	call   800438 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800280:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800283:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800286:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800289:	89 ec                	mov    %ebp,%esp
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 38             	sub    $0x38,%esp
  800293:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800296:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800299:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  8002d9:	e8 5a 01 00 00       	call   800438 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e7:	89 ec                	mov    %ebp,%esp
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 38             	sub    $0x38,%esp
  8002f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ff:	b8 08 00 00 00       	mov    $0x8,%eax
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	8b 55 08             	mov    0x8(%ebp),%edx
  80030a:	89 df                	mov    %ebx,%edi
  80030c:	89 de                	mov    %ebx,%esi
  80030e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800310:	85 c0                	test   %eax,%eax
  800312:	7e 28                	jle    80033c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800314:	89 44 24 10          	mov    %eax,0x10(%esp)
  800318:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031f:	00 
  800320:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800327:	00 
  800328:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032f:	00 
  800330:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  800337:	e8 fc 00 00 00       	call   800438 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80033c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800342:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800345:	89 ec                	mov    %ebp,%esp
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 38             	sub    $0x38,%esp
  80034f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800352:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800355:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800358:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035d:	b8 09 00 00 00       	mov    $0x9,%eax
  800362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800365:	8b 55 08             	mov    0x8(%ebp),%edx
  800368:	89 df                	mov    %ebx,%edi
  80036a:	89 de                	mov    %ebx,%esi
  80036c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036e:	85 c0                	test   %eax,%eax
  800370:	7e 28                	jle    80039a <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800372:	89 44 24 10          	mov    %eax,0x10(%esp)
  800376:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80037d:	00 
  80037e:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  800395:	e8 9e 00 00 00       	call   800438 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80039d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a3:	89 ec                	mov    %ebp,%esp
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003b3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b6:	be 00 00 00 00       	mov    $0x0,%esi
  8003bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d7:	89 ec                	mov    %ebp,%esp
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 38             	sub    $0x38,%esp
  8003e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	89 cb                	mov    %ecx,%ebx
  8003f9:	89 cf                	mov    %ecx,%edi
  8003fb:	89 ce                	mov    %ecx,%esi
  8003fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003ff:	85 c0                	test   %eax,%eax
  800401:	7e 28                	jle    80042b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800403:	89 44 24 10          	mov    %eax,0x10(%esp)
  800407:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80040e:	00 
  80040f:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800416:	00 
  800417:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041e:	00 
  80041f:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  800426:	e8 0d 00 00 00       	call   800438 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800431:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800434:	89 ec                	mov    %ebp,%esp
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	56                   	push   %esi
  80043c:	53                   	push   %ebx
  80043d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800440:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800443:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800449:	e8 22 fd ff ff       	call   800170 <sys_getenvid>
  80044e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800451:	89 54 24 10          	mov    %edx,0x10(%esp)
  800455:	8b 55 08             	mov    0x8(%ebp),%edx
  800458:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 58 13 80 00 	movl   $0x801358,(%esp)
  80046b:	e8 c3 00 00 00       	call   800533 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800470:	89 74 24 04          	mov    %esi,0x4(%esp)
  800474:	8b 45 10             	mov    0x10(%ebp),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	e8 53 00 00 00       	call   8004d2 <vcprintf>
	cprintf("\n");
  80047f:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  800486:	e8 a8 00 00 00       	call   800533 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048b:	cc                   	int3   
  80048c:	eb fd                	jmp    80048b <_panic+0x53>
	...

00800490 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	53                   	push   %ebx
  800494:	83 ec 14             	sub    $0x14,%esp
  800497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049a:	8b 03                	mov    (%ebx),%eax
  80049c:	8b 55 08             	mov    0x8(%ebp),%edx
  80049f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a3:	83 c0 01             	add    $0x1,%eax
  8004a6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ad:	75 19                	jne    8004c8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004af:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004b6:	00 
  8004b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ba:	89 04 24             	mov    %eax,(%esp)
  8004bd:	e8 f2 fb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8004c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004cc:	83 c4 14             	add    $0x14,%esp
  8004cf:	5b                   	pop    %ebx
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e2:	00 00 00 
	b.cnt = 0;
  8004e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	c7 04 24 90 04 80 00 	movl   $0x800490,(%esp)
  80050e:	e8 97 01 00 00       	call   8006aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800513:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	e8 89 fb ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80052b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800539:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80053c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800540:	8b 45 08             	mov    0x8(%ebp),%eax
  800543:	89 04 24             	mov    %eax,(%esp)
  800546:	e8 87 ff ff ff       	call   8004d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    
  80054d:	00 00                	add    %al,(%eax)
	...

00800550 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 3c             	sub    $0x3c,%esp
  800559:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055c:	89 d7                	mov    %edx,%edi
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80056d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800578:	72 11                	jb     80058b <printnum+0x3b>
  80057a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80057d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800580:	76 09                	jbe    80058b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	85 db                	test   %ebx,%ebx
  800587:	7f 51                	jg     8005da <printnum+0x8a>
  800589:	eb 5e                	jmp    8005e9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800596:	8b 45 10             	mov    0x10(%ebp),%eax
  800599:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ac:	00 
  8005ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ba:	e8 a1 0a 00 00       	call   801060 <__udivdi3>
  8005bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ce:	89 fa                	mov    %edi,%edx
  8005d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d3:	e8 78 ff ff ff       	call   800550 <printnum>
  8005d8:	eb 0f                	jmp    8005e9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005de:	89 34 24             	mov    %esi,(%esp)
  8005e1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e4:	83 eb 01             	sub    $0x1,%ebx
  8005e7:	75 f1                	jne    8005da <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ed:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ff:	00 
  800600:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	e8 7e 0b 00 00       	call   801190 <__umoddi3>
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	0f be 80 7e 13 80 00 	movsbl 0x80137e(%eax),%eax
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800623:	83 c4 3c             	add    $0x3c,%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80062e:	83 fa 01             	cmp    $0x1,%edx
  800631:	7e 0e                	jle    800641 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800633:	8b 10                	mov    (%eax),%edx
  800635:	8d 4a 08             	lea    0x8(%edx),%ecx
  800638:	89 08                	mov    %ecx,(%eax)
  80063a:	8b 02                	mov    (%edx),%eax
  80063c:	8b 52 04             	mov    0x4(%edx),%edx
  80063f:	eb 22                	jmp    800663 <getuint+0x38>
	else if (lflag)
  800641:	85 d2                	test   %edx,%edx
  800643:	74 10                	je     800655 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800645:	8b 10                	mov    (%eax),%edx
  800647:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064a:	89 08                	mov    %ecx,(%eax)
  80064c:	8b 02                	mov    (%edx),%eax
  80064e:	ba 00 00 00 00       	mov    $0x0,%edx
  800653:	eb 0e                	jmp    800663 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800655:	8b 10                	mov    (%eax),%edx
  800657:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065a:	89 08                	mov    %ecx,(%eax)
  80065c:	8b 02                	mov    (%edx),%eax
  80065e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80066b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	3b 50 04             	cmp    0x4(%eax),%edx
  800674:	73 0a                	jae    800680 <sprintputch+0x1b>
		*b->buf++ = ch;
  800676:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800679:	88 0a                	mov    %cl,(%edx)
  80067b:	83 c2 01             	add    $0x1,%edx
  80067e:	89 10                	mov    %edx,(%eax)
}
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068f:	8b 45 10             	mov    0x10(%ebp),%eax
  800692:	89 44 24 08          	mov    %eax,0x8(%esp)
  800696:	8b 45 0c             	mov    0xc(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	89 04 24             	mov    %eax,(%esp)
  8006a3:	e8 02 00 00 00       	call   8006aa <vprintfmt>
	va_end(ap);
}
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    

008006aa <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	57                   	push   %edi
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
  8006b0:	83 ec 5c             	sub    $0x5c,%esp
  8006b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b6:	8b 75 10             	mov    0x10(%ebp),%esi
  8006b9:	eb 12                	jmp    8006cd <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	0f 84 e4 04 00 00    	je     800ba7 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006cd:	0f b6 06             	movzbl (%esi),%eax
  8006d0:	83 c6 01             	add    $0x1,%esi
  8006d3:	83 f8 25             	cmp    $0x25,%eax
  8006d6:	75 e3                	jne    8006bb <vprintfmt+0x11>
  8006d8:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8006dc:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8006e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006e8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8006f7:	eb 2b                	jmp    800724 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006fc:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800700:	eb 22                	jmp    800724 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800702:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800705:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800709:	eb 19                	jmp    800724 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80070e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800715:	eb 0d                	jmp    800724 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800717:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80071a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80071d:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	0f b6 06             	movzbl (%esi),%eax
  800727:	0f b6 d0             	movzbl %al,%edx
  80072a:	8d 7e 01             	lea    0x1(%esi),%edi
  80072d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800730:	83 e8 23             	sub    $0x23,%eax
  800733:	3c 55                	cmp    $0x55,%al
  800735:	0f 87 46 04 00 00    	ja     800b81 <vprintfmt+0x4d7>
  80073b:	0f b6 c0             	movzbl %al,%eax
  80073e:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800745:	83 ea 30             	sub    $0x30,%edx
  800748:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80074b:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80074f:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800752:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800755:	83 fa 09             	cmp    $0x9,%edx
  800758:	77 4a                	ja     8007a4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800760:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800763:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800767:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80076a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80076d:	83 fa 09             	cmp    $0x9,%edx
  800770:	76 eb                	jbe    80075d <vprintfmt+0xb3>
  800772:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800775:	eb 2d                	jmp    8007a4 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)
  800780:	8b 00                	mov    (%eax),%eax
  800782:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800785:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800788:	eb 1a                	jmp    8007a4 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  80078d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800791:	79 91                	jns    800724 <vprintfmt+0x7a>
  800793:	e9 73 ff ff ff       	jmp    80070b <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800798:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80079b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007a2:	eb 80                	jmp    800724 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007a4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007a8:	0f 89 76 ff ff ff    	jns    800724 <vprintfmt+0x7a>
  8007ae:	e9 64 ff ff ff       	jmp    800717 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007b3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007b9:	e9 66 ff ff ff       	jmp    800724 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 50 04             	lea    0x4(%eax),%edx
  8007c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	89 04 24             	mov    %eax,(%esp)
  8007d0:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007d6:	e9 f2 fe ff ff       	jmp    8006cd <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007db:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8007df:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8007e2:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8007e6:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8007e9:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8007ed:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8007f0:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8007f3:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8007f7:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007fa:	80 f9 09             	cmp    $0x9,%cl
  8007fd:	77 1d                	ja     80081c <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8007ff:	0f be c0             	movsbl %al,%eax
  800802:	6b c0 64             	imul   $0x64,%eax,%eax
  800805:	0f be d2             	movsbl %dl,%edx
  800808:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80080b:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800812:	a3 04 20 80 00       	mov    %eax,0x802004
  800817:	e9 b1 fe ff ff       	jmp    8006cd <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  80081c:	c7 44 24 04 96 13 80 	movl   $0x801396,0x4(%esp)
  800823:	00 
  800824:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 0c 05 00 00       	call   800d3b <strcmp>
  80082f:	85 c0                	test   %eax,%eax
  800831:	75 0f                	jne    800842 <vprintfmt+0x198>
  800833:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80083a:	00 00 00 
  80083d:	e9 8b fe ff ff       	jmp    8006cd <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800842:	c7 44 24 04 9a 13 80 	movl   $0x80139a,0x4(%esp)
  800849:	00 
  80084a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80084d:	89 14 24             	mov    %edx,(%esp)
  800850:	e8 e6 04 00 00       	call   800d3b <strcmp>
  800855:	85 c0                	test   %eax,%eax
  800857:	75 0f                	jne    800868 <vprintfmt+0x1be>
  800859:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800860:	00 00 00 
  800863:	e9 65 fe ff ff       	jmp    8006cd <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800868:	c7 44 24 04 9e 13 80 	movl   $0x80139e,0x4(%esp)
  80086f:	00 
  800870:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800873:	89 0c 24             	mov    %ecx,(%esp)
  800876:	e8 c0 04 00 00       	call   800d3b <strcmp>
  80087b:	85 c0                	test   %eax,%eax
  80087d:	75 0f                	jne    80088e <vprintfmt+0x1e4>
  80087f:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800886:	00 00 00 
  800889:	e9 3f fe ff ff       	jmp    8006cd <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  80088e:	c7 44 24 04 a2 13 80 	movl   $0x8013a2,0x4(%esp)
  800895:	00 
  800896:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800899:	89 3c 24             	mov    %edi,(%esp)
  80089c:	e8 9a 04 00 00       	call   800d3b <strcmp>
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	75 0f                	jne    8008b4 <vprintfmt+0x20a>
  8008a5:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008ac:	00 00 00 
  8008af:	e9 19 fe ff ff       	jmp    8006cd <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008b4:	c7 44 24 04 a6 13 80 	movl   $0x8013a6,0x4(%esp)
  8008bb:	00 
  8008bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	e8 74 04 00 00       	call   800d3b <strcmp>
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	75 0f                	jne    8008da <vprintfmt+0x230>
  8008cb:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008d2:	00 00 00 
  8008d5:	e9 f3 fd ff ff       	jmp    8006cd <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008da:	c7 44 24 04 aa 13 80 	movl   $0x8013aa,0x4(%esp)
  8008e1:	00 
  8008e2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008e5:	89 14 24             	mov    %edx,(%esp)
  8008e8:	e8 4e 04 00 00       	call   800d3b <strcmp>
  8008ed:	83 f8 01             	cmp    $0x1,%eax
  8008f0:	19 c0                	sbb    %eax,%eax
  8008f2:	f7 d0                	not    %eax
  8008f4:	83 c0 08             	add    $0x8,%eax
  8008f7:	a3 04 20 80 00       	mov    %eax,0x802004
  8008fc:	e9 cc fd ff ff       	jmp    8006cd <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8d 50 04             	lea    0x4(%eax),%edx
  800907:	89 55 14             	mov    %edx,0x14(%ebp)
  80090a:	8b 00                	mov    (%eax),%eax
  80090c:	89 c2                	mov    %eax,%edx
  80090e:	c1 fa 1f             	sar    $0x1f,%edx
  800911:	31 d0                	xor    %edx,%eax
  800913:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800915:	83 f8 08             	cmp    $0x8,%eax
  800918:	7f 0b                	jg     800925 <vprintfmt+0x27b>
  80091a:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  800921:	85 d2                	test   %edx,%edx
  800923:	75 23                	jne    800948 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800925:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800929:	c7 44 24 08 ae 13 80 	movl   $0x8013ae,0x8(%esp)
  800930:	00 
  800931:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	89 3c 24             	mov    %edi,(%esp)
  80093b:	e8 42 fd ff ff       	call   800682 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800943:	e9 85 fd ff ff       	jmp    8006cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800948:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80094c:	c7 44 24 08 b7 13 80 	movl   $0x8013b7,0x8(%esp)
  800953:	00 
  800954:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	89 3c 24             	mov    %edi,(%esp)
  80095e:	e8 1f fd ff ff       	call   800682 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800963:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800966:	e9 62 fd ff ff       	jmp    8006cd <vprintfmt+0x23>
  80096b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  80096e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800971:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800974:	8b 45 14             	mov    0x14(%ebp),%eax
  800977:	8d 50 04             	lea    0x4(%eax),%edx
  80097a:	89 55 14             	mov    %edx,0x14(%ebp)
  80097d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80097f:	85 f6                	test   %esi,%esi
  800981:	b8 8f 13 80 00       	mov    $0x80138f,%eax
  800986:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800989:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80098d:	7e 06                	jle    800995 <vprintfmt+0x2eb>
  80098f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800993:	75 13                	jne    8009a8 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800995:	0f be 06             	movsbl (%esi),%eax
  800998:	83 c6 01             	add    $0x1,%esi
  80099b:	85 c0                	test   %eax,%eax
  80099d:	0f 85 94 00 00 00    	jne    800a37 <vprintfmt+0x38d>
  8009a3:	e9 81 00 00 00       	jmp    800a29 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ac:	89 34 24             	mov    %esi,(%esp)
  8009af:	e8 97 02 00 00       	call   800c4b <strnlen>
  8009b4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009b7:	29 c2                	sub    %eax,%edx
  8009b9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009bc:	85 d2                	test   %edx,%edx
  8009be:	7e d5                	jle    800995 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009c0:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009c4:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009c7:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009ca:	89 d6                	mov    %edx,%esi
  8009cc:	89 cf                	mov    %ecx,%edi
  8009ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d2:	89 3c 24             	mov    %edi,(%esp)
  8009d5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d8:	83 ee 01             	sub    $0x1,%esi
  8009db:	75 f1                	jne    8009ce <vprintfmt+0x324>
  8009dd:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8009e0:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8009e3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8009e6:	eb ad                	jmp    800995 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009e8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8009ec:	74 1b                	je     800a09 <vprintfmt+0x35f>
  8009ee:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009f1:	83 fa 5e             	cmp    $0x5e,%edx
  8009f4:	76 13                	jbe    800a09 <vprintfmt+0x35f>
					putch('?', putdat);
  8009f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a04:	ff 55 08             	call   *0x8(%ebp)
  800a07:	eb 0d                	jmp    800a16 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a09:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a10:	89 04 24             	mov    %eax,(%esp)
  800a13:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a16:	83 eb 01             	sub    $0x1,%ebx
  800a19:	0f be 06             	movsbl (%esi),%eax
  800a1c:	83 c6 01             	add    $0x1,%esi
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	75 1a                	jne    800a3d <vprintfmt+0x393>
  800a23:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a26:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a29:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a2c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a30:	7f 1c                	jg     800a4e <vprintfmt+0x3a4>
  800a32:	e9 96 fc ff ff       	jmp    8006cd <vprintfmt+0x23>
  800a37:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a3a:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	78 a7                	js     8009e8 <vprintfmt+0x33e>
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	79 a2                	jns    8009e8 <vprintfmt+0x33e>
  800a46:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a49:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a4c:	eb db                	jmp    800a29 <vprintfmt+0x37f>
  800a4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a51:	89 de                	mov    %ebx,%esi
  800a53:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a61:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a63:	83 eb 01             	sub    $0x1,%ebx
  800a66:	75 ee                	jne    800a56 <vprintfmt+0x3ac>
  800a68:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a6d:	e9 5b fc ff ff       	jmp    8006cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a72:	83 f9 01             	cmp    $0x1,%ecx
  800a75:	7e 10                	jle    800a87 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a77:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7a:	8d 50 08             	lea    0x8(%eax),%edx
  800a7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a80:	8b 30                	mov    (%eax),%esi
  800a82:	8b 78 04             	mov    0x4(%eax),%edi
  800a85:	eb 26                	jmp    800aad <vprintfmt+0x403>
	else if (lflag)
  800a87:	85 c9                	test   %ecx,%ecx
  800a89:	74 12                	je     800a9d <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8e:	8d 50 04             	lea    0x4(%eax),%edx
  800a91:	89 55 14             	mov    %edx,0x14(%ebp)
  800a94:	8b 30                	mov    (%eax),%esi
  800a96:	89 f7                	mov    %esi,%edi
  800a98:	c1 ff 1f             	sar    $0x1f,%edi
  800a9b:	eb 10                	jmp    800aad <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa0:	8d 50 04             	lea    0x4(%eax),%edx
  800aa3:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa6:	8b 30                	mov    (%eax),%esi
  800aa8:	89 f7                	mov    %esi,%edi
  800aaa:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800aad:	85 ff                	test   %edi,%edi
  800aaf:	78 0e                	js     800abf <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ab1:	89 f0                	mov    %esi,%eax
  800ab3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ab5:	be 0a 00 00 00       	mov    $0xa,%esi
  800aba:	e9 84 00 00 00       	jmp    800b43 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800abf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800acd:	89 f0                	mov    %esi,%eax
  800acf:	89 fa                	mov    %edi,%edx
  800ad1:	f7 d8                	neg    %eax
  800ad3:	83 d2 00             	adc    $0x0,%edx
  800ad6:	f7 da                	neg    %edx
			}
			base = 10;
  800ad8:	be 0a 00 00 00       	mov    $0xa,%esi
  800add:	eb 64                	jmp    800b43 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800adf:	89 ca                	mov    %ecx,%edx
  800ae1:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae4:	e8 42 fb ff ff       	call   80062b <getuint>
			base = 10;
  800ae9:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800aee:	eb 53                	jmp    800b43 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800af0:	89 ca                	mov    %ecx,%edx
  800af2:	8d 45 14             	lea    0x14(%ebp),%eax
  800af5:	e8 31 fb ff ff       	call   80062b <getuint>
    			base = 8;
  800afa:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800aff:	eb 42                	jmp    800b43 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b05:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b0c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b13:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b1a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b20:	8d 50 04             	lea    0x4(%eax),%edx
  800b23:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b26:	8b 00                	mov    (%eax),%eax
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b2d:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b32:	eb 0f                	jmp    800b43 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b34:	89 ca                	mov    %ecx,%edx
  800b36:	8d 45 14             	lea    0x14(%ebp),%eax
  800b39:	e8 ed fa ff ff       	call   80062b <getuint>
			base = 16;
  800b3e:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b43:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b47:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b4b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b4e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b52:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b56:	89 04 24             	mov    %eax,(%esp)
  800b59:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b5d:	89 da                	mov    %ebx,%edx
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	e8 e9 f9 ff ff       	call   800550 <printnum>
			break;
  800b67:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b6a:	e9 5e fb ff ff       	jmp    8006cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b73:	89 14 24             	mov    %edx,(%esp)
  800b76:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b79:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b7c:	e9 4c fb ff ff       	jmp    8006cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b85:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b8c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b8f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b93:	0f 84 34 fb ff ff    	je     8006cd <vprintfmt+0x23>
  800b99:	83 ee 01             	sub    $0x1,%esi
  800b9c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ba0:	75 f7                	jne    800b99 <vprintfmt+0x4ef>
  800ba2:	e9 26 fb ff ff       	jmp    8006cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ba7:	83 c4 5c             	add    $0x5c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 28             	sub    $0x28,%esp
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bbb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	74 30                	je     800c00 <vsnprintf+0x51>
  800bd0:	85 d2                	test   %edx,%edx
  800bd2:	7e 2c                	jle    800c00 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be9:	c7 04 24 65 06 80 00 	movl   $0x800665,(%esp)
  800bf0:	e8 b5 fa ff ff       	call   8006aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bfe:	eb 05                	jmp    800c05 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c14:	8b 45 10             	mov    0x10(%ebp),%eax
  800c17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	89 04 24             	mov    %eax,(%esp)
  800c28:	e8 82 ff ff ff       	call   800baf <vsnprintf>
	va_end(ap);

	return rc;
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    
	...

00800c30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c3e:	74 09                	je     800c49 <strlen+0x19>
		n++;
  800c40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c47:	75 f7                	jne    800c40 <strlen+0x10>
		n++;
	return n;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	53                   	push   %ebx
  800c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	85 c9                	test   %ecx,%ecx
  800c5c:	74 1a                	je     800c78 <strnlen+0x2d>
  800c5e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c61:	74 15                	je     800c78 <strnlen+0x2d>
  800c63:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c68:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6a:	39 ca                	cmp    %ecx,%edx
  800c6c:	74 0a                	je     800c78 <strnlen+0x2d>
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c76:	75 f0                	jne    800c68 <strnlen+0x1d>
		n++;
	return n;
}
  800c78:	5b                   	pop    %ebx
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c8e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c91:	83 c2 01             	add    $0x1,%edx
  800c94:	84 c9                	test   %cl,%cl
  800c96:	75 f2                	jne    800c8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 08             	sub    $0x8,%esp
  800ca2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca5:	89 1c 24             	mov    %ebx,(%esp)
  800ca8:	e8 83 ff ff ff       	call   800c30 <strlen>
	strcpy(dst + len, src);
  800cad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb4:	01 d8                	add    %ebx,%eax
  800cb6:	89 04 24             	mov    %eax,(%esp)
  800cb9:	e8 bd ff ff ff       	call   800c7b <strcpy>
	return dst;
}
  800cbe:	89 d8                	mov    %ebx,%eax
  800cc0:	83 c4 08             	add    $0x8,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd4:	85 f6                	test   %esi,%esi
  800cd6:	74 18                	je     800cf0 <strncpy+0x2a>
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800cdd:	0f b6 1a             	movzbl (%edx),%ebx
  800ce0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ce3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ce6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce9:	83 c1 01             	add    $0x1,%ecx
  800cec:	39 f1                	cmp    %esi,%ecx
  800cee:	75 ed                	jne    800cdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d00:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d03:	89 f8                	mov    %edi,%eax
  800d05:	85 f6                	test   %esi,%esi
  800d07:	74 2b                	je     800d34 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d09:	83 fe 01             	cmp    $0x1,%esi
  800d0c:	74 23                	je     800d31 <strlcpy+0x3d>
  800d0e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d11:	84 c9                	test   %cl,%cl
  800d13:	74 1c                	je     800d31 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d15:	83 ee 02             	sub    $0x2,%esi
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d1d:	88 08                	mov    %cl,(%eax)
  800d1f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d22:	39 f2                	cmp    %esi,%edx
  800d24:	74 0b                	je     800d31 <strlcpy+0x3d>
  800d26:	83 c2 01             	add    $0x1,%edx
  800d29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d2d:	84 c9                	test   %cl,%cl
  800d2f:	75 ec                	jne    800d1d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d34:	29 f8                	sub    %edi,%eax
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d41:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d44:	0f b6 01             	movzbl (%ecx),%eax
  800d47:	84 c0                	test   %al,%al
  800d49:	74 16                	je     800d61 <strcmp+0x26>
  800d4b:	3a 02                	cmp    (%edx),%al
  800d4d:	75 12                	jne    800d61 <strcmp+0x26>
		p++, q++;
  800d4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d52:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d56:	84 c0                	test   %al,%al
  800d58:	74 07                	je     800d61 <strcmp+0x26>
  800d5a:	83 c1 01             	add    $0x1,%ecx
  800d5d:	3a 02                	cmp    (%edx),%al
  800d5f:	74 ee                	je     800d4f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d61:	0f b6 c0             	movzbl %al,%eax
  800d64:	0f b6 12             	movzbl (%edx),%edx
  800d67:	29 d0                	sub    %edx,%eax
}
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d75:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d7d:	85 d2                	test   %edx,%edx
  800d7f:	74 28                	je     800da9 <strncmp+0x3e>
  800d81:	0f b6 01             	movzbl (%ecx),%eax
  800d84:	84 c0                	test   %al,%al
  800d86:	74 24                	je     800dac <strncmp+0x41>
  800d88:	3a 03                	cmp    (%ebx),%al
  800d8a:	75 20                	jne    800dac <strncmp+0x41>
  800d8c:	83 ea 01             	sub    $0x1,%edx
  800d8f:	74 13                	je     800da4 <strncmp+0x39>
		n--, p++, q++;
  800d91:	83 c1 01             	add    $0x1,%ecx
  800d94:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d97:	0f b6 01             	movzbl (%ecx),%eax
  800d9a:	84 c0                	test   %al,%al
  800d9c:	74 0e                	je     800dac <strncmp+0x41>
  800d9e:	3a 03                	cmp    (%ebx),%al
  800da0:	74 ea                	je     800d8c <strncmp+0x21>
  800da2:	eb 08                	jmp    800dac <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800da4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 01             	movzbl (%ecx),%eax
  800daf:	0f b6 13             	movzbl (%ebx),%edx
  800db2:	29 d0                	sub    %edx,%eax
  800db4:	eb f3                	jmp    800da9 <strncmp+0x3e>

00800db6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc0:	0f b6 10             	movzbl (%eax),%edx
  800dc3:	84 d2                	test   %dl,%dl
  800dc5:	74 1c                	je     800de3 <strchr+0x2d>
		if (*s == c)
  800dc7:	38 ca                	cmp    %cl,%dl
  800dc9:	75 09                	jne    800dd4 <strchr+0x1e>
  800dcb:	eb 1b                	jmp    800de8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dcd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800dd0:	38 ca                	cmp    %cl,%dl
  800dd2:	74 14                	je     800de8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dd4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800dd8:	84 d2                	test   %dl,%dl
  800dda:	75 f1                	jne    800dcd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  800de1:	eb 05                	jmp    800de8 <strchr+0x32>
  800de3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df4:	0f b6 10             	movzbl (%eax),%edx
  800df7:	84 d2                	test   %dl,%dl
  800df9:	74 14                	je     800e0f <strfind+0x25>
		if (*s == c)
  800dfb:	38 ca                	cmp    %cl,%dl
  800dfd:	75 06                	jne    800e05 <strfind+0x1b>
  800dff:	eb 0e                	jmp    800e0f <strfind+0x25>
  800e01:	38 ca                	cmp    %cl,%dl
  800e03:	74 0a                	je     800e0f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e05:	83 c0 01             	add    $0x1,%eax
  800e08:	0f b6 10             	movzbl (%eax),%edx
  800e0b:	84 d2                	test   %dl,%dl
  800e0d:	75 f2                	jne    800e01 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e29:	85 c9                	test   %ecx,%ecx
  800e2b:	74 30                	je     800e5d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e33:	75 25                	jne    800e5a <memset+0x49>
  800e35:	f6 c1 03             	test   $0x3,%cl
  800e38:	75 20                	jne    800e5a <memset+0x49>
		c &= 0xFF;
  800e3a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e3d:	89 d3                	mov    %edx,%ebx
  800e3f:	c1 e3 08             	shl    $0x8,%ebx
  800e42:	89 d6                	mov    %edx,%esi
  800e44:	c1 e6 18             	shl    $0x18,%esi
  800e47:	89 d0                	mov    %edx,%eax
  800e49:	c1 e0 10             	shl    $0x10,%eax
  800e4c:	09 f0                	or     %esi,%eax
  800e4e:	09 d0                	or     %edx,%eax
  800e50:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e52:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e55:	fc                   	cld    
  800e56:	f3 ab                	rep stos %eax,%es:(%edi)
  800e58:	eb 03                	jmp    800e5d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e5a:	fc                   	cld    
  800e5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e62:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e65:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e68:	89 ec                	mov    %ebp,%esp
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e81:	39 c6                	cmp    %eax,%esi
  800e83:	73 36                	jae    800ebb <memmove+0x4f>
  800e85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e88:	39 d0                	cmp    %edx,%eax
  800e8a:	73 2f                	jae    800ebb <memmove+0x4f>
		s += n;
		d += n;
  800e8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e8f:	f6 c2 03             	test   $0x3,%dl
  800e92:	75 1b                	jne    800eaf <memmove+0x43>
  800e94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e9a:	75 13                	jne    800eaf <memmove+0x43>
  800e9c:	f6 c1 03             	test   $0x3,%cl
  800e9f:	75 0e                	jne    800eaf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ea1:	83 ef 04             	sub    $0x4,%edi
  800ea4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ea7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eaa:	fd                   	std    
  800eab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ead:	eb 09                	jmp    800eb8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eaf:	83 ef 01             	sub    $0x1,%edi
  800eb2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb5:	fd                   	std    
  800eb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eb8:	fc                   	cld    
  800eb9:	eb 20                	jmp    800edb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ec1:	75 13                	jne    800ed6 <memmove+0x6a>
  800ec3:	a8 03                	test   $0x3,%al
  800ec5:	75 0f                	jne    800ed6 <memmove+0x6a>
  800ec7:	f6 c1 03             	test   $0x3,%cl
  800eca:	75 0a                	jne    800ed6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ecc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ecf:	89 c7                	mov    %eax,%edi
  800ed1:	fc                   	cld    
  800ed2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed4:	eb 05                	jmp    800edb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed6:	89 c7                	mov    %eax,%edi
  800ed8:	fc                   	cld    
  800ed9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ede:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee1:	89 ec                	mov    %ebp,%esp
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800eee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	89 04 24             	mov    %eax,(%esp)
  800eff:	e8 68 ff ff ff       	call   800e6c <memmove>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f12:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1a:	85 ff                	test   %edi,%edi
  800f1c:	74 37                	je     800f55 <memcmp+0x4f>
		if (*s1 != *s2)
  800f1e:	0f b6 03             	movzbl (%ebx),%eax
  800f21:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f24:	83 ef 01             	sub    $0x1,%edi
  800f27:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f2c:	38 c8                	cmp    %cl,%al
  800f2e:	74 1c                	je     800f4c <memcmp+0x46>
  800f30:	eb 10                	jmp    800f42 <memcmp+0x3c>
  800f32:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f37:	83 c2 01             	add    $0x1,%edx
  800f3a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f3e:	38 c8                	cmp    %cl,%al
  800f40:	74 0a                	je     800f4c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f42:	0f b6 c0             	movzbl %al,%eax
  800f45:	0f b6 c9             	movzbl %cl,%ecx
  800f48:	29 c8                	sub    %ecx,%eax
  800f4a:	eb 09                	jmp    800f55 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4c:	39 fa                	cmp    %edi,%edx
  800f4e:	75 e2                	jne    800f32 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f65:	39 d0                	cmp    %edx,%eax
  800f67:	73 19                	jae    800f82 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f6d:	38 08                	cmp    %cl,(%eax)
  800f6f:	75 06                	jne    800f77 <memfind+0x1d>
  800f71:	eb 0f                	jmp    800f82 <memfind+0x28>
  800f73:	38 08                	cmp    %cl,(%eax)
  800f75:	74 0b                	je     800f82 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f77:	83 c0 01             	add    $0x1,%eax
  800f7a:	39 d0                	cmp    %edx,%eax
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	75 f1                	jne    800f73 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f90:	0f b6 02             	movzbl (%edx),%eax
  800f93:	3c 20                	cmp    $0x20,%al
  800f95:	74 04                	je     800f9b <strtol+0x17>
  800f97:	3c 09                	cmp    $0x9,%al
  800f99:	75 0e                	jne    800fa9 <strtol+0x25>
		s++;
  800f9b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f9e:	0f b6 02             	movzbl (%edx),%eax
  800fa1:	3c 20                	cmp    $0x20,%al
  800fa3:	74 f6                	je     800f9b <strtol+0x17>
  800fa5:	3c 09                	cmp    $0x9,%al
  800fa7:	74 f2                	je     800f9b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fa9:	3c 2b                	cmp    $0x2b,%al
  800fab:	75 0a                	jne    800fb7 <strtol+0x33>
		s++;
  800fad:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb5:	eb 10                	jmp    800fc7 <strtol+0x43>
  800fb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fbc:	3c 2d                	cmp    $0x2d,%al
  800fbe:	75 07                	jne    800fc7 <strtol+0x43>
		s++, neg = 1;
  800fc0:	83 c2 01             	add    $0x1,%edx
  800fc3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fc7:	85 db                	test   %ebx,%ebx
  800fc9:	0f 94 c0             	sete   %al
  800fcc:	74 05                	je     800fd3 <strtol+0x4f>
  800fce:	83 fb 10             	cmp    $0x10,%ebx
  800fd1:	75 15                	jne    800fe8 <strtol+0x64>
  800fd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fd6:	75 10                	jne    800fe8 <strtol+0x64>
  800fd8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fdc:	75 0a                	jne    800fe8 <strtol+0x64>
		s += 2, base = 16;
  800fde:	83 c2 02             	add    $0x2,%edx
  800fe1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fe6:	eb 13                	jmp    800ffb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800fe8:	84 c0                	test   %al,%al
  800fea:	74 0f                	je     800ffb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ff1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ff4:	75 05                	jne    800ffb <strtol+0x77>
		s++, base = 8;
  800ff6:	83 c2 01             	add    $0x1,%edx
  800ff9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  801000:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801002:	0f b6 0a             	movzbl (%edx),%ecx
  801005:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801008:	80 fb 09             	cmp    $0x9,%bl
  80100b:	77 08                	ja     801015 <strtol+0x91>
			dig = *s - '0';
  80100d:	0f be c9             	movsbl %cl,%ecx
  801010:	83 e9 30             	sub    $0x30,%ecx
  801013:	eb 1e                	jmp    801033 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801015:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801018:	80 fb 19             	cmp    $0x19,%bl
  80101b:	77 08                	ja     801025 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80101d:	0f be c9             	movsbl %cl,%ecx
  801020:	83 e9 57             	sub    $0x57,%ecx
  801023:	eb 0e                	jmp    801033 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801025:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801028:	80 fb 19             	cmp    $0x19,%bl
  80102b:	77 14                	ja     801041 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80102d:	0f be c9             	movsbl %cl,%ecx
  801030:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801033:	39 f1                	cmp    %esi,%ecx
  801035:	7d 0e                	jge    801045 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801037:	83 c2 01             	add    $0x1,%edx
  80103a:	0f af c6             	imul   %esi,%eax
  80103d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80103f:	eb c1                	jmp    801002 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801041:	89 c1                	mov    %eax,%ecx
  801043:	eb 02                	jmp    801047 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801045:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801047:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80104b:	74 05                	je     801052 <strtol+0xce>
		*endptr = (char *) s;
  80104d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801050:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801052:	89 ca                	mov    %ecx,%edx
  801054:	f7 da                	neg    %edx
  801056:	85 ff                	test   %edi,%edi
  801058:	0f 45 c2             	cmovne %edx,%eax
}
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <__udivdi3>:
  801060:	83 ec 1c             	sub    $0x1c,%esp
  801063:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801067:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80106b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80106f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801073:	89 74 24 10          	mov    %esi,0x10(%esp)
  801077:	8b 74 24 24          	mov    0x24(%esp),%esi
  80107b:	85 ff                	test   %edi,%edi
  80107d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	89 cd                	mov    %ecx,%ebp
  801087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108b:	75 33                	jne    8010c0 <__udivdi3+0x60>
  80108d:	39 f1                	cmp    %esi,%ecx
  80108f:	77 57                	ja     8010e8 <__udivdi3+0x88>
  801091:	85 c9                	test   %ecx,%ecx
  801093:	75 0b                	jne    8010a0 <__udivdi3+0x40>
  801095:	b8 01 00 00 00       	mov    $0x1,%eax
  80109a:	31 d2                	xor    %edx,%edx
  80109c:	f7 f1                	div    %ecx
  80109e:	89 c1                	mov    %eax,%ecx
  8010a0:	89 f0                	mov    %esi,%eax
  8010a2:	31 d2                	xor    %edx,%edx
  8010a4:	f7 f1                	div    %ecx
  8010a6:	89 c6                	mov    %eax,%esi
  8010a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ac:	f7 f1                	div    %ecx
  8010ae:	89 f2                	mov    %esi,%edx
  8010b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010bc:	83 c4 1c             	add    $0x1c,%esp
  8010bf:	c3                   	ret    
  8010c0:	31 d2                	xor    %edx,%edx
  8010c2:	31 c0                	xor    %eax,%eax
  8010c4:	39 f7                	cmp    %esi,%edi
  8010c6:	77 e8                	ja     8010b0 <__udivdi3+0x50>
  8010c8:	0f bd cf             	bsr    %edi,%ecx
  8010cb:	83 f1 1f             	xor    $0x1f,%ecx
  8010ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010d2:	75 2c                	jne    801100 <__udivdi3+0xa0>
  8010d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010d8:	76 04                	jbe    8010de <__udivdi3+0x7e>
  8010da:	39 f7                	cmp    %esi,%edi
  8010dc:	73 d2                	jae    8010b0 <__udivdi3+0x50>
  8010de:	31 d2                	xor    %edx,%edx
  8010e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e5:	eb c9                	jmp    8010b0 <__udivdi3+0x50>
  8010e7:	90                   	nop
  8010e8:	89 f2                	mov    %esi,%edx
  8010ea:	f7 f1                	div    %ecx
  8010ec:	31 d2                	xor    %edx,%edx
  8010ee:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fa:	83 c4 1c             	add    $0x1c,%esp
  8010fd:	c3                   	ret    
  8010fe:	66 90                	xchg   %ax,%ax
  801100:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801105:	b8 20 00 00 00       	mov    $0x20,%eax
  80110a:	89 ea                	mov    %ebp,%edx
  80110c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801110:	d3 e7                	shl    %cl,%edi
  801112:	89 c1                	mov    %eax,%ecx
  801114:	d3 ea                	shr    %cl,%edx
  801116:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111b:	09 fa                	or     %edi,%edx
  80111d:	89 f7                	mov    %esi,%edi
  80111f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801123:	89 f2                	mov    %esi,%edx
  801125:	8b 74 24 08          	mov    0x8(%esp),%esi
  801129:	d3 e5                	shl    %cl,%ebp
  80112b:	89 c1                	mov    %eax,%ecx
  80112d:	d3 ef                	shr    %cl,%edi
  80112f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801134:	d3 e2                	shl    %cl,%edx
  801136:	89 c1                	mov    %eax,%ecx
  801138:	d3 ee                	shr    %cl,%esi
  80113a:	09 d6                	or     %edx,%esi
  80113c:	89 fa                	mov    %edi,%edx
  80113e:	89 f0                	mov    %esi,%eax
  801140:	f7 74 24 0c          	divl   0xc(%esp)
  801144:	89 d7                	mov    %edx,%edi
  801146:	89 c6                	mov    %eax,%esi
  801148:	f7 e5                	mul    %ebp
  80114a:	39 d7                	cmp    %edx,%edi
  80114c:	72 22                	jb     801170 <__udivdi3+0x110>
  80114e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801152:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801157:	d3 e5                	shl    %cl,%ebp
  801159:	39 c5                	cmp    %eax,%ebp
  80115b:	73 04                	jae    801161 <__udivdi3+0x101>
  80115d:	39 d7                	cmp    %edx,%edi
  80115f:	74 0f                	je     801170 <__udivdi3+0x110>
  801161:	89 f0                	mov    %esi,%eax
  801163:	31 d2                	xor    %edx,%edx
  801165:	e9 46 ff ff ff       	jmp    8010b0 <__udivdi3+0x50>
  80116a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801170:	8d 46 ff             	lea    -0x1(%esi),%eax
  801173:	31 d2                	xor    %edx,%edx
  801175:	8b 74 24 10          	mov    0x10(%esp),%esi
  801179:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80117d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801181:	83 c4 1c             	add    $0x1c,%esp
  801184:	c3                   	ret    
	...

00801190 <__umoddi3>:
  801190:	83 ec 1c             	sub    $0x1c,%esp
  801193:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801197:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80119b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80119f:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011ab:	85 ed                	test   %ebp,%ebp
  8011ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	89 cf                	mov    %ecx,%edi
  8011b7:	89 04 24             	mov    %eax,(%esp)
  8011ba:	89 f2                	mov    %esi,%edx
  8011bc:	75 1a                	jne    8011d8 <__umoddi3+0x48>
  8011be:	39 f1                	cmp    %esi,%ecx
  8011c0:	76 4e                	jbe    801210 <__umoddi3+0x80>
  8011c2:	f7 f1                	div    %ecx
  8011c4:	89 d0                	mov    %edx,%eax
  8011c6:	31 d2                	xor    %edx,%edx
  8011c8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011d4:	83 c4 1c             	add    $0x1c,%esp
  8011d7:	c3                   	ret    
  8011d8:	39 f5                	cmp    %esi,%ebp
  8011da:	77 54                	ja     801230 <__umoddi3+0xa0>
  8011dc:	0f bd c5             	bsr    %ebp,%eax
  8011df:	83 f0 1f             	xor    $0x1f,%eax
  8011e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e6:	75 60                	jne    801248 <__umoddi3+0xb8>
  8011e8:	3b 0c 24             	cmp    (%esp),%ecx
  8011eb:	0f 87 07 01 00 00    	ja     8012f8 <__umoddi3+0x168>
  8011f1:	89 f2                	mov    %esi,%edx
  8011f3:	8b 34 24             	mov    (%esp),%esi
  8011f6:	29 ce                	sub    %ecx,%esi
  8011f8:	19 ea                	sbb    %ebp,%edx
  8011fa:	89 34 24             	mov    %esi,(%esp)
  8011fd:	8b 04 24             	mov    (%esp),%eax
  801200:	8b 74 24 10          	mov    0x10(%esp),%esi
  801204:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801208:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80120c:	83 c4 1c             	add    $0x1c,%esp
  80120f:	c3                   	ret    
  801210:	85 c9                	test   %ecx,%ecx
  801212:	75 0b                	jne    80121f <__umoddi3+0x8f>
  801214:	b8 01 00 00 00       	mov    $0x1,%eax
  801219:	31 d2                	xor    %edx,%edx
  80121b:	f7 f1                	div    %ecx
  80121d:	89 c1                	mov    %eax,%ecx
  80121f:	89 f0                	mov    %esi,%eax
  801221:	31 d2                	xor    %edx,%edx
  801223:	f7 f1                	div    %ecx
  801225:	8b 04 24             	mov    (%esp),%eax
  801228:	f7 f1                	div    %ecx
  80122a:	eb 98                	jmp    8011c4 <__umoddi3+0x34>
  80122c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 f2                	mov    %esi,%edx
  801232:	8b 74 24 10          	mov    0x10(%esp),%esi
  801236:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80123a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80123e:	83 c4 1c             	add    $0x1c,%esp
  801241:	c3                   	ret    
  801242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801248:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80124d:	89 e8                	mov    %ebp,%eax
  80124f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801254:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801258:	89 fa                	mov    %edi,%edx
  80125a:	d3 e0                	shl    %cl,%eax
  80125c:	89 e9                	mov    %ebp,%ecx
  80125e:	d3 ea                	shr    %cl,%edx
  801260:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801265:	09 c2                	or     %eax,%edx
  801267:	8b 44 24 08          	mov    0x8(%esp),%eax
  80126b:	89 14 24             	mov    %edx,(%esp)
  80126e:	89 f2                	mov    %esi,%edx
  801270:	d3 e7                	shl    %cl,%edi
  801272:	89 e9                	mov    %ebp,%ecx
  801274:	d3 ea                	shr    %cl,%edx
  801276:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80127b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80127f:	d3 e6                	shl    %cl,%esi
  801281:	89 e9                	mov    %ebp,%ecx
  801283:	d3 e8                	shr    %cl,%eax
  801285:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128a:	09 f0                	or     %esi,%eax
  80128c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801290:	f7 34 24             	divl   (%esp)
  801293:	d3 e6                	shl    %cl,%esi
  801295:	89 74 24 08          	mov    %esi,0x8(%esp)
  801299:	89 d6                	mov    %edx,%esi
  80129b:	f7 e7                	mul    %edi
  80129d:	39 d6                	cmp    %edx,%esi
  80129f:	89 c1                	mov    %eax,%ecx
  8012a1:	89 d7                	mov    %edx,%edi
  8012a3:	72 3f                	jb     8012e4 <__umoddi3+0x154>
  8012a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012a9:	72 35                	jb     8012e0 <__umoddi3+0x150>
  8012ab:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012af:	29 c8                	sub    %ecx,%eax
  8012b1:	19 fe                	sbb    %edi,%esi
  8012b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012b8:	89 f2                	mov    %esi,%edx
  8012ba:	d3 e8                	shr    %cl,%eax
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	d3 e2                	shl    %cl,%edx
  8012c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012c5:	09 d0                	or     %edx,%eax
  8012c7:	89 f2                	mov    %esi,%edx
  8012c9:	d3 ea                	shr    %cl,%edx
  8012cb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012d7:	83 c4 1c             	add    $0x1c,%esp
  8012da:	c3                   	ret    
  8012db:	90                   	nop
  8012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	39 d6                	cmp    %edx,%esi
  8012e2:	75 c7                	jne    8012ab <__umoddi3+0x11b>
  8012e4:	89 d7                	mov    %edx,%edi
  8012e6:	89 c1                	mov    %eax,%ecx
  8012e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012ec:	1b 3c 24             	sbb    (%esp),%edi
  8012ef:	eb ba                	jmp    8012ab <__umoddi3+0x11b>
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	39 f5                	cmp    %esi,%ebp
  8012fa:	0f 82 f1 fe ff ff    	jb     8011f1 <__umoddi3+0x61>
  801300:	e9 f8 fe ff ff       	jmp    8011fd <__umoddi3+0x6d>
