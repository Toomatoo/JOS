
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800056:	e8 09 01 00 00       	call   800164 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 61 00 00 00       	call   800107 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000d3:	89 ec                	mov    %ebp,%esp
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800100:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800103:	89 ec                	mov    %ebp,%esp
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 38             	sub    $0x38,%esp
  80010d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800110:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800113:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	b8 03 00 00 00       	mov    $0x3,%eax
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7e 28                	jle    800157 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013a:	00 
  80013b:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  800152:	e8 d5 02 00 00       	call   80042c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800157:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80015a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80015d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800160:	89 ec                	mov    %ebp,%esp
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80016d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800170:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	ba 00 00 00 00       	mov    $0x0,%edx
  800178:	b8 02 00 00 00       	mov    $0x2,%eax
  80017d:	89 d1                	mov    %edx,%ecx
  80017f:	89 d3                	mov    %edx,%ebx
  800181:	89 d7                	mov    %edx,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800187:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80018d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800190:	89 ec                	mov    %ebp,%esp
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <sys_yield>:

void
sys_yield(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80019d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001ad:	89 d1                	mov    %edx,%ecx
  8001af:	89 d3                	mov    %edx,%ebx
  8001b1:	89 d7                	mov    %edx,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c0:	89 ec                	mov    %ebp,%esp
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 38             	sub    $0x38,%esp
  8001ca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001cd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d3:	be 00 00 00 00       	mov    $0x0,%esi
  8001d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	89 f7                	mov    %esi,%edi
  8001e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	7e 28                	jle    800216 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800201:	00 
  800202:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800209:	00 
  80020a:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  800211:	e8 16 02 00 00       	call   80042c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800216:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800219:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80021c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80021f:	89 ec                	mov    %ebp,%esp
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 38             	sub    $0x38,%esp
  800229:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80022c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80022f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	b8 05 00 00 00       	mov    $0x5,%eax
  800237:	8b 75 18             	mov    0x18(%ebp),%esi
  80023a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80023d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 28                	jle    800274 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800250:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800257:	00 
  800258:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  80025f:	00 
  800260:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800267:	00 
  800268:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  80026f:	e8 b8 01 00 00       	call   80042c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800274:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800277:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80027a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80027d:	89 ec                	mov    %ebp,%esp
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 38             	sub    $0x38,%esp
  800287:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80028a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80028d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 06 00 00 00       	mov    $0x6,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 28                	jle    8002d2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  8002cd:	e8 5a 01 00 00       	call   80042c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002db:	89 ec                	mov    %ebp,%esp
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 38             	sub    $0x38,%esp
  8002e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8002f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fe:	89 df                	mov    %ebx,%edi
  800300:	89 de                	mov    %ebx,%esi
  800302:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800304:	85 c0                	test   %eax,%eax
  800306:	7e 28                	jle    800330 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800308:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800313:	00 
  800314:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  80031b:	00 
  80031c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800323:	00 
  800324:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  80032b:	e8 fc 00 00 00       	call   80042c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800330:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800333:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800336:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800339:	89 ec                	mov    %ebp,%esp
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	83 ec 38             	sub    $0x38,%esp
  800343:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800346:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800349:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800351:	b8 09 00 00 00       	mov    $0x9,%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 df                	mov    %ebx,%edi
  80035e:	89 de                	mov    %ebx,%esi
  800360:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  800389:	e8 9e 00 00 00       	call   80042c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80038e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800391:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800394:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800397:	89 ec                	mov    %ebp,%esp
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	83 ec 0c             	sub    $0xc,%esp
  8003a1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003a4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003aa:	be 00 00 00 00       	mov    $0x0,%esi
  8003af:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003cb:	89 ec                	mov    %ebp,%esp
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 38             	sub    $0x38,%esp
  8003d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003eb:	89 cb                	mov    %ecx,%ebx
  8003ed:	89 cf                	mov    %ecx,%edi
  8003ef:	89 ce                	mov    %ecx,%esi
  8003f1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	7e 28                	jle    80041f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003fb:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800402:	00 
  800403:	c7 44 24 08 2a 13 80 	movl   $0x80132a,0x8(%esp)
  80040a:	00 
  80040b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800412:	00 
  800413:	c7 04 24 47 13 80 00 	movl   $0x801347,(%esp)
  80041a:	e8 0d 00 00 00       	call   80042c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80041f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800422:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800425:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800428:	89 ec                	mov    %ebp,%esp
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	56                   	push   %esi
  800430:	53                   	push   %ebx
  800431:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800437:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80043d:	e8 22 fd ff ff       	call   800164 <sys_getenvid>
  800442:	8b 55 0c             	mov    0xc(%ebp),%edx
  800445:	89 54 24 10          	mov    %edx,0x10(%esp)
  800449:	8b 55 08             	mov    0x8(%ebp),%edx
  80044c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800450:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	c7 04 24 58 13 80 00 	movl   $0x801358,(%esp)
  80045f:	e8 c3 00 00 00       	call   800527 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800464:	89 74 24 04          	mov    %esi,0x4(%esp)
  800468:	8b 45 10             	mov    0x10(%ebp),%eax
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	e8 53 00 00 00       	call   8004c6 <vcprintf>
	cprintf("\n");
  800473:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  80047a:	e8 a8 00 00 00       	call   800527 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047f:	cc                   	int3   
  800480:	eb fd                	jmp    80047f <_panic+0x53>
	...

00800484 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	53                   	push   %ebx
  800488:	83 ec 14             	sub    $0x14,%esp
  80048b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80048e:	8b 03                	mov    (%ebx),%eax
  800490:	8b 55 08             	mov    0x8(%ebp),%edx
  800493:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800497:	83 c0 01             	add    $0x1,%eax
  80049a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80049c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a1:	75 19                	jne    8004bc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004a3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004aa:	00 
  8004ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	e8 f2 fb ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8004b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004c0:	83 c4 14             	add    $0x14,%esp
  8004c3:	5b                   	pop    %ebx
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004d6:	00 00 00 
	b.cnt = 0;
  8004d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fb:	c7 04 24 84 04 80 00 	movl   $0x800484,(%esp)
  800502:	e8 97 01 00 00       	call   80069e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800507:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800517:	89 04 24             	mov    %eax,(%esp)
  80051a:	e8 89 fb ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80051f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80052d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	8b 45 08             	mov    0x8(%ebp),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	e8 87 ff ff ff       	call   8004c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    
  800541:	00 00                	add    %al,(%eax)
	...

00800544 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 3c             	sub    $0x3c,%esp
  80054d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800550:	89 d7                	mov    %edx,%edi
  800552:	8b 45 08             	mov    0x8(%ebp),%eax
  800555:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800561:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800564:	b8 00 00 00 00       	mov    $0x0,%eax
  800569:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80056c:	72 11                	jb     80057f <printnum+0x3b>
  80056e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800571:	39 45 10             	cmp    %eax,0x10(%ebp)
  800574:	76 09                	jbe    80057f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800576:	83 eb 01             	sub    $0x1,%ebx
  800579:	85 db                	test   %ebx,%ebx
  80057b:	7f 51                	jg     8005ce <printnum+0x8a>
  80057d:	eb 5e                	jmp    8005dd <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80057f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800583:	83 eb 01             	sub    $0x1,%ebx
  800586:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80058a:	8b 45 10             	mov    0x10(%ebp),%eax
  80058d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800591:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800595:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800599:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005a0:	00 
  8005a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ae:	e8 ad 0a 00 00       	call   801060 <__udivdi3>
  8005b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c2:	89 fa                	mov    %edi,%edx
  8005c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c7:	e8 78 ff ff ff       	call   800544 <printnum>
  8005cc:	eb 0f                	jmp    8005dd <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d2:	89 34 24             	mov    %esi,(%esp)
  8005d5:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005d8:	83 eb 01             	sub    $0x1,%ebx
  8005db:	75 f1                	jne    8005ce <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005f3:	00 
  8005f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	e8 8a 0b 00 00       	call   801190 <__umoddi3>
  800606:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060a:	0f be 80 7e 13 80 00 	movsbl 0x80137e(%eax),%eax
  800611:	89 04 24             	mov    %eax,(%esp)
  800614:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800617:	83 c4 3c             	add    $0x3c,%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5e                   	pop    %esi
  80061c:	5f                   	pop    %edi
  80061d:	5d                   	pop    %ebp
  80061e:	c3                   	ret    

0080061f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800622:	83 fa 01             	cmp    $0x1,%edx
  800625:	7e 0e                	jle    800635 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800627:	8b 10                	mov    (%eax),%edx
  800629:	8d 4a 08             	lea    0x8(%edx),%ecx
  80062c:	89 08                	mov    %ecx,(%eax)
  80062e:	8b 02                	mov    (%edx),%eax
  800630:	8b 52 04             	mov    0x4(%edx),%edx
  800633:	eb 22                	jmp    800657 <getuint+0x38>
	else if (lflag)
  800635:	85 d2                	test   %edx,%edx
  800637:	74 10                	je     800649 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80063e:	89 08                	mov    %ecx,(%eax)
  800640:	8b 02                	mov    (%edx),%eax
  800642:	ba 00 00 00 00       	mov    $0x0,%edx
  800647:	eb 0e                	jmp    800657 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064e:	89 08                	mov    %ecx,(%eax)
  800650:	8b 02                	mov    (%edx),%eax
  800652:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    

00800659 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80065f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800663:	8b 10                	mov    (%eax),%edx
  800665:	3b 50 04             	cmp    0x4(%eax),%edx
  800668:	73 0a                	jae    800674 <sprintputch+0x1b>
		*b->buf++ = ch;
  80066a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80066d:	88 0a                	mov    %cl,(%edx)
  80066f:	83 c2 01             	add    $0x1,%edx
  800672:	89 10                	mov    %edx,(%eax)
}
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80067f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800683:	8b 45 10             	mov    0x10(%ebp),%eax
  800686:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800691:	8b 45 08             	mov    0x8(%ebp),%eax
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	e8 02 00 00 00       	call   80069e <vprintfmt>
	va_end(ap);
}
  80069c:	c9                   	leave  
  80069d:	c3                   	ret    

0080069e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	57                   	push   %edi
  8006a2:	56                   	push   %esi
  8006a3:	53                   	push   %ebx
  8006a4:	83 ec 5c             	sub    $0x5c,%esp
  8006a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006aa:	8b 75 10             	mov    0x10(%ebp),%esi
  8006ad:	eb 12                	jmp    8006c1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	0f 84 e4 04 00 00    	je     800b9b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c1:	0f b6 06             	movzbl (%esi),%eax
  8006c4:	83 c6 01             	add    $0x1,%esi
  8006c7:	83 f8 25             	cmp    $0x25,%eax
  8006ca:	75 e3                	jne    8006af <vprintfmt+0x11>
  8006cc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8006d0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8006d7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006dc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8006eb:	eb 2b                	jmp    800718 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006f0:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8006f4:	eb 22                	jmp    800718 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8006f9:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8006fd:	eb 19                	jmp    800718 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ff:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800702:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800709:	eb 0d                	jmp    800718 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80070b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80070e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800711:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	0f b6 06             	movzbl (%esi),%eax
  80071b:	0f b6 d0             	movzbl %al,%edx
  80071e:	8d 7e 01             	lea    0x1(%esi),%edi
  800721:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800724:	83 e8 23             	sub    $0x23,%eax
  800727:	3c 55                	cmp    $0x55,%al
  800729:	0f 87 46 04 00 00    	ja     800b75 <vprintfmt+0x4d7>
  80072f:	0f b6 c0             	movzbl %al,%eax
  800732:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800739:	83 ea 30             	sub    $0x30,%edx
  80073c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80073f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800743:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800749:	83 fa 09             	cmp    $0x9,%edx
  80074c:	77 4a                	ja     800798 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800751:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800754:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800757:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80075b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80075e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800761:	83 fa 09             	cmp    $0x9,%edx
  800764:	76 eb                	jbe    800751 <vprintfmt+0xb3>
  800766:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800769:	eb 2d                	jmp    800798 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)
  800774:	8b 00                	mov    (%eax),%eax
  800776:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80077c:	eb 1a                	jmp    800798 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800781:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800785:	79 91                	jns    800718 <vprintfmt+0x7a>
  800787:	e9 73 ff ff ff       	jmp    8006ff <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80078f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800796:	eb 80                	jmp    800718 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800798:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80079c:	0f 89 76 ff ff ff    	jns    800718 <vprintfmt+0x7a>
  8007a2:	e9 64 ff ff ff       	jmp    80070b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007a7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ad:	e9 66 ff ff ff       	jmp    800718 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 50 04             	lea    0x4(%eax),%edx
  8007b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	89 04 24             	mov    %eax,(%esp)
  8007c4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007ca:	e9 f2 fe ff ff       	jmp    8006c1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007cf:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8007d3:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8007d6:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8007da:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8007dd:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8007e1:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8007e4:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8007e7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8007eb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007ee:	80 f9 09             	cmp    $0x9,%cl
  8007f1:	77 1d                	ja     800810 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8007f3:	0f be c0             	movsbl %al,%eax
  8007f6:	6b c0 64             	imul   $0x64,%eax,%eax
  8007f9:	0f be d2             	movsbl %dl,%edx
  8007fc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8007ff:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800806:	a3 04 20 80 00       	mov    %eax,0x802004
  80080b:	e9 b1 fe ff ff       	jmp    8006c1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800810:	c7 44 24 04 96 13 80 	movl   $0x801396,0x4(%esp)
  800817:	00 
  800818:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 18 05 00 00       	call   800d3b <strcmp>
  800823:	85 c0                	test   %eax,%eax
  800825:	75 0f                	jne    800836 <vprintfmt+0x198>
  800827:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  80082e:	00 00 00 
  800831:	e9 8b fe ff ff       	jmp    8006c1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800836:	c7 44 24 04 9a 13 80 	movl   $0x80139a,0x4(%esp)
  80083d:	00 
  80083e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800841:	89 14 24             	mov    %edx,(%esp)
  800844:	e8 f2 04 00 00       	call   800d3b <strcmp>
  800849:	85 c0                	test   %eax,%eax
  80084b:	75 0f                	jne    80085c <vprintfmt+0x1be>
  80084d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800854:	00 00 00 
  800857:	e9 65 fe ff ff       	jmp    8006c1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80085c:	c7 44 24 04 9e 13 80 	movl   $0x80139e,0x4(%esp)
  800863:	00 
  800864:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800867:	89 0c 24             	mov    %ecx,(%esp)
  80086a:	e8 cc 04 00 00       	call   800d3b <strcmp>
  80086f:	85 c0                	test   %eax,%eax
  800871:	75 0f                	jne    800882 <vprintfmt+0x1e4>
  800873:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  80087a:	00 00 00 
  80087d:	e9 3f fe ff ff       	jmp    8006c1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800882:	c7 44 24 04 a2 13 80 	movl   $0x8013a2,0x4(%esp)
  800889:	00 
  80088a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80088d:	89 3c 24             	mov    %edi,(%esp)
  800890:	e8 a6 04 00 00       	call   800d3b <strcmp>
  800895:	85 c0                	test   %eax,%eax
  800897:	75 0f                	jne    8008a8 <vprintfmt+0x20a>
  800899:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  8008a0:	00 00 00 
  8008a3:	e9 19 fe ff ff       	jmp    8006c1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008a8:	c7 44 24 04 a6 13 80 	movl   $0x8013a6,0x4(%esp)
  8008af:	00 
  8008b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 80 04 00 00       	call   800d3b <strcmp>
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	75 0f                	jne    8008ce <vprintfmt+0x230>
  8008bf:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  8008c6:	00 00 00 
  8008c9:	e9 f3 fd ff ff       	jmp    8006c1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008ce:	c7 44 24 04 aa 13 80 	movl   $0x8013aa,0x4(%esp)
  8008d5:	00 
  8008d6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008d9:	89 14 24             	mov    %edx,(%esp)
  8008dc:	e8 5a 04 00 00       	call   800d3b <strcmp>
  8008e1:	83 f8 01             	cmp    $0x1,%eax
  8008e4:	19 c0                	sbb    %eax,%eax
  8008e6:	f7 d0                	not    %eax
  8008e8:	83 c0 08             	add    $0x8,%eax
  8008eb:	a3 04 20 80 00       	mov    %eax,0x802004
  8008f0:	e9 cc fd ff ff       	jmp    8006c1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 50 04             	lea    0x4(%eax),%edx
  8008fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fe:	8b 00                	mov    (%eax),%eax
  800900:	89 c2                	mov    %eax,%edx
  800902:	c1 fa 1f             	sar    $0x1f,%edx
  800905:	31 d0                	xor    %edx,%eax
  800907:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800909:	83 f8 08             	cmp    $0x8,%eax
  80090c:	7f 0b                	jg     800919 <vprintfmt+0x27b>
  80090e:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  800915:	85 d2                	test   %edx,%edx
  800917:	75 23                	jne    80093c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800919:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80091d:	c7 44 24 08 ae 13 80 	movl   $0x8013ae,0x8(%esp)
  800924:	00 
  800925:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800929:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092c:	89 3c 24             	mov    %edi,(%esp)
  80092f:	e8 42 fd ff ff       	call   800676 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800934:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800937:	e9 85 fd ff ff       	jmp    8006c1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80093c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800940:	c7 44 24 08 b7 13 80 	movl   $0x8013b7,0x8(%esp)
  800947:	00 
  800948:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094f:	89 3c 24             	mov    %edi,(%esp)
  800952:	e8 1f fd ff ff       	call   800676 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800957:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80095a:	e9 62 fd ff ff       	jmp    8006c1 <vprintfmt+0x23>
  80095f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800962:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800965:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	8d 50 04             	lea    0x4(%eax),%edx
  80096e:	89 55 14             	mov    %edx,0x14(%ebp)
  800971:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800973:	85 f6                	test   %esi,%esi
  800975:	b8 8f 13 80 00       	mov    $0x80138f,%eax
  80097a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80097d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800981:	7e 06                	jle    800989 <vprintfmt+0x2eb>
  800983:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800987:	75 13                	jne    80099c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800989:	0f be 06             	movsbl (%esi),%eax
  80098c:	83 c6 01             	add    $0x1,%esi
  80098f:	85 c0                	test   %eax,%eax
  800991:	0f 85 94 00 00 00    	jne    800a2b <vprintfmt+0x38d>
  800997:	e9 81 00 00 00       	jmp    800a1d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80099c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a0:	89 34 24             	mov    %esi,(%esp)
  8009a3:	e8 a3 02 00 00       	call   800c4b <strnlen>
  8009a8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009ab:	29 c2                	sub    %eax,%edx
  8009ad:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009b0:	85 d2                	test   %edx,%edx
  8009b2:	7e d5                	jle    800989 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009b4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009b8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009bb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	89 cf                	mov    %ecx,%edi
  8009c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c6:	89 3c 24             	mov    %edi,(%esp)
  8009c9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cc:	83 ee 01             	sub    $0x1,%esi
  8009cf:	75 f1                	jne    8009c2 <vprintfmt+0x324>
  8009d1:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8009d4:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8009d7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8009da:	eb ad                	jmp    800989 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009dc:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8009e0:	74 1b                	je     8009fd <vprintfmt+0x35f>
  8009e2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009e5:	83 fa 5e             	cmp    $0x5e,%edx
  8009e8:	76 13                	jbe    8009fd <vprintfmt+0x35f>
					putch('?', putdat);
  8009ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009f8:	ff 55 08             	call   *0x8(%ebp)
  8009fb:	eb 0d                	jmp    800a0a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8009fd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a00:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a04:	89 04 24             	mov    %eax,(%esp)
  800a07:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0a:	83 eb 01             	sub    $0x1,%ebx
  800a0d:	0f be 06             	movsbl (%esi),%eax
  800a10:	83 c6 01             	add    $0x1,%esi
  800a13:	85 c0                	test   %eax,%eax
  800a15:	75 1a                	jne    800a31 <vprintfmt+0x393>
  800a17:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a1a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a20:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a24:	7f 1c                	jg     800a42 <vprintfmt+0x3a4>
  800a26:	e9 96 fc ff ff       	jmp    8006c1 <vprintfmt+0x23>
  800a2b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a2e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a31:	85 ff                	test   %edi,%edi
  800a33:	78 a7                	js     8009dc <vprintfmt+0x33e>
  800a35:	83 ef 01             	sub    $0x1,%edi
  800a38:	79 a2                	jns    8009dc <vprintfmt+0x33e>
  800a3a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a3d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a40:	eb db                	jmp    800a1d <vprintfmt+0x37f>
  800a42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a45:	89 de                	mov    %ebx,%esi
  800a47:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a55:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a57:	83 eb 01             	sub    $0x1,%ebx
  800a5a:	75 ee                	jne    800a4a <vprintfmt+0x3ac>
  800a5c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a61:	e9 5b fc ff ff       	jmp    8006c1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a66:	83 f9 01             	cmp    $0x1,%ecx
  800a69:	7e 10                	jle    800a7b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6e:	8d 50 08             	lea    0x8(%eax),%edx
  800a71:	89 55 14             	mov    %edx,0x14(%ebp)
  800a74:	8b 30                	mov    (%eax),%esi
  800a76:	8b 78 04             	mov    0x4(%eax),%edi
  800a79:	eb 26                	jmp    800aa1 <vprintfmt+0x403>
	else if (lflag)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 12                	je     800a91 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a82:	8d 50 04             	lea    0x4(%eax),%edx
  800a85:	89 55 14             	mov    %edx,0x14(%ebp)
  800a88:	8b 30                	mov    (%eax),%esi
  800a8a:	89 f7                	mov    %esi,%edi
  800a8c:	c1 ff 1f             	sar    $0x1f,%edi
  800a8f:	eb 10                	jmp    800aa1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800a91:	8b 45 14             	mov    0x14(%ebp),%eax
  800a94:	8d 50 04             	lea    0x4(%eax),%edx
  800a97:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9a:	8b 30                	mov    (%eax),%esi
  800a9c:	89 f7                	mov    %esi,%edi
  800a9e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	78 0e                	js     800ab3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aa5:	89 f0                	mov    %esi,%eax
  800aa7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aa9:	be 0a 00 00 00       	mov    $0xa,%esi
  800aae:	e9 84 00 00 00       	jmp    800b37 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ab3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800abe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ac1:	89 f0                	mov    %esi,%eax
  800ac3:	89 fa                	mov    %edi,%edx
  800ac5:	f7 d8                	neg    %eax
  800ac7:	83 d2 00             	adc    $0x0,%edx
  800aca:	f7 da                	neg    %edx
			}
			base = 10;
  800acc:	be 0a 00 00 00       	mov    $0xa,%esi
  800ad1:	eb 64                	jmp    800b37 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ad3:	89 ca                	mov    %ecx,%edx
  800ad5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad8:	e8 42 fb ff ff       	call   80061f <getuint>
			base = 10;
  800add:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800ae2:	eb 53                	jmp    800b37 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ae4:	89 ca                	mov    %ecx,%edx
  800ae6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae9:	e8 31 fb ff ff       	call   80061f <getuint>
    			base = 8;
  800aee:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800af3:	eb 42                	jmp    800b37 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800af5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b00:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b07:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b0e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b11:	8b 45 14             	mov    0x14(%ebp),%eax
  800b14:	8d 50 04             	lea    0x4(%eax),%edx
  800b17:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b1a:	8b 00                	mov    (%eax),%eax
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b21:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b26:	eb 0f                	jmp    800b37 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b28:	89 ca                	mov    %ecx,%edx
  800b2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2d:	e8 ed fa ff ff       	call   80061f <getuint>
			base = 16;
  800b32:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b37:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b3b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b3f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b42:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b46:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b4a:	89 04 24             	mov    %eax,(%esp)
  800b4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b51:	89 da                	mov    %ebx,%edx
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	e8 e9 f9 ff ff       	call   800544 <printnum>
			break;
  800b5b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b5e:	e9 5e fb ff ff       	jmp    8006c1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b67:	89 14 24             	mov    %edx,(%esp)
  800b6a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b6d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b70:	e9 4c fb ff ff       	jmp    8006c1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b79:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b80:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b83:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b87:	0f 84 34 fb ff ff    	je     8006c1 <vprintfmt+0x23>
  800b8d:	83 ee 01             	sub    $0x1,%esi
  800b90:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b94:	75 f7                	jne    800b8d <vprintfmt+0x4ef>
  800b96:	e9 26 fb ff ff       	jmp    8006c1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b9b:	83 c4 5c             	add    $0x5c,%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 28             	sub    $0x28,%esp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800baf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bb6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	74 30                	je     800bf4 <vsnprintf+0x51>
  800bc4:	85 d2                	test   %edx,%edx
  800bc6:	7e 2c                	jle    800bf4 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdd:	c7 04 24 59 06 80 00 	movl   $0x800659,(%esp)
  800be4:	e8 b5 fa ff ff       	call   80069e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf2:	eb 05                	jmp    800bf9 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c08:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	89 04 24             	mov    %eax,(%esp)
  800c1c:	e8 82 ff ff ff       	call   800ba3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    
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
