
obj/user/buggyhello2:     file format elf32-i386


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
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 69 00 00 00       	call   8000b8 <sys_cputs>
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
  800066:	e8 09 01 00 00       	call   800174 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

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
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 61 00 00 00       	call   800117 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	89 d1                	mov    %edx,%ecx
  800102:	89 d3                	mov    %edx,%ebx
  800104:	89 d7                	mov    %edx,%edi
  800106:	89 d6                	mov    %edx,%esi
  800108:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80010d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800110:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 38             	sub    $0x38,%esp
  80011d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800120:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800123:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 03 00 00 00       	mov    $0x3,%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	89 ce                	mov    %ecx,%esi
  800139:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 28                	jle    800167 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800143:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014a:	00 
  80014b:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  800162:	e8 d5 02 00 00       	call   80043c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80016d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80017d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800180:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	b8 02 00 00 00       	mov    $0x2,%eax
  80018d:	89 d1                	mov    %edx,%ecx
  80018f:	89 d3                	mov    %edx,%ebx
  800191:	89 d7                	mov    %edx,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800197:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80019d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a0:	89 ec                	mov    %ebp,%esp
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <sys_yield>:

void
sys_yield(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001bd:	89 d1                	mov    %edx,%ecx
  8001bf:	89 d3                	mov    %edx,%ebx
  8001c1:	89 d7                	mov    %edx,%edi
  8001c3:	89 d6                	mov    %edx,%esi
  8001c5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ca:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001cd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d0:	89 ec                	mov    %ebp,%esp
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    

008001d4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 38             	sub    $0x38,%esp
  8001da:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001dd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	be 00 00 00 00       	mov    $0x0,%esi
  8001e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	89 f7                	mov    %esi,%edi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 28                	jle    800226 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800202:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800209:	00 
  80020a:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  800221:	e8 16 02 00 00       	call   80043c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800226:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800229:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80022c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 38             	sub    $0x38,%esp
  800239:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80023c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80023f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800242:	b8 05 00 00 00       	mov    $0x5,%eax
  800247:	8b 75 18             	mov    0x18(%ebp),%esi
  80024a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80024d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800253:	8b 55 08             	mov    0x8(%ebp),%edx
  800256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 28                	jle    800284 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800260:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800267:	00 
  800268:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  80026f:	00 
  800270:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800277:	00 
  800278:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  80027f:	e8 b8 01 00 00       	call   80043c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800284:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800287:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80028a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80028d:	89 ec                	mov    %ebp,%esp
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 38             	sub    $0x38,%esp
  800297:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80029a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80029d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 df                	mov    %ebx,%edi
  8002b2:	89 de                	mov    %ebx,%esi
  8002b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 28                	jle    8002e2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002be:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  8002dd:	e8 5a 01 00 00       	call   80043c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002eb:	89 ec                	mov    %ebp,%esp
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 38             	sub    $0x38,%esp
  8002f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800303:	b8 08 00 00 00       	mov    $0x8,%eax
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	89 df                	mov    %ebx,%edi
  800310:	89 de                	mov    %ebx,%esi
  800312:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800314:	85 c0                	test   %eax,%eax
  800316:	7e 28                	jle    800340 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800318:	89 44 24 10          	mov    %eax,0x10(%esp)
  80031c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800323:	00 
  800324:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  80032b:	00 
  80032c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800333:	00 
  800334:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  80033b:	e8 fc 00 00 00       	call   80043c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800340:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800343:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800346:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800349:	89 ec                	mov    %ebp,%esp
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 38             	sub    $0x38,%esp
  800353:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800356:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800359:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800361:	b8 09 00 00 00       	mov    $0x9,%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	89 df                	mov    %ebx,%edi
  80036e:	89 de                	mov    %ebx,%esi
  800370:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 28                	jle    80039e <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800381:	00 
  800382:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  800399:	e8 9e 00 00 00       	call   80043c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80039e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003a4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003a7:	89 ec                	mov    %ebp,%esp
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 0c             	sub    $0xc,%esp
  8003b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ba:	be 00 00 00 00       	mov    $0x0,%esi
  8003bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003db:	89 ec                	mov    %ebp,%esp
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 38             	sub    $0x38,%esp
  8003e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	89 cb                	mov    %ecx,%ebx
  8003fd:	89 cf                	mov    %ecx,%edi
  8003ff:	89 ce                	mov    %ecx,%esi
  800401:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800403:	85 c0                	test   %eax,%eax
  800405:	7e 28                	jle    80042f <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800407:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040b:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800412:	00 
  800413:	c7 44 24 08 38 13 80 	movl   $0x801338,0x8(%esp)
  80041a:	00 
  80041b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800422:	00 
  800423:	c7 04 24 55 13 80 00 	movl   $0x801355,(%esp)
  80042a:	e8 0d 00 00 00       	call   80043c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80042f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800432:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800435:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800438:	89 ec                	mov    %ebp,%esp
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	56                   	push   %esi
  800440:	53                   	push   %ebx
  800441:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800444:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800447:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80044d:	e8 22 fd ff ff       	call   800174 <sys_getenvid>
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 54 24 10          	mov    %edx,0x10(%esp)
  800459:	8b 55 08             	mov    0x8(%ebp),%edx
  80045c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800460:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	c7 04 24 64 13 80 00 	movl   $0x801364,(%esp)
  80046f:	e8 c3 00 00 00       	call   800537 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800474:	89 74 24 04          	mov    %esi,0x4(%esp)
  800478:	8b 45 10             	mov    0x10(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	e8 53 00 00 00       	call   8004d6 <vcprintf>
	cprintf("\n");
  800483:	c7 04 24 2c 13 80 00 	movl   $0x80132c,(%esp)
  80048a:	e8 a8 00 00 00       	call   800537 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048f:	cc                   	int3   
  800490:	eb fd                	jmp    80048f <_panic+0x53>
	...

00800494 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	53                   	push   %ebx
  800498:	83 ec 14             	sub    $0x14,%esp
  80049b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80049e:	8b 03                	mov    (%ebx),%eax
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a7:	83 c0 01             	add    $0x1,%eax
  8004aa:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b1:	75 19                	jne    8004cc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004b3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ba:	00 
  8004bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	e8 f2 fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8004c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004d0:	83 c4 14             	add    $0x14,%esp
  8004d3:	5b                   	pop    %ebx
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e6:	00 00 00 
	b.cnt = 0;
  8004e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800501:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	c7 04 24 94 04 80 00 	movl   $0x800494,(%esp)
  800512:	e8 97 01 00 00       	call   8006ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800517:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 89 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  80052f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800540:	89 44 24 04          	mov    %eax,0x4(%esp)
  800544:	8b 45 08             	mov    0x8(%ebp),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	e8 87 ff ff ff       	call   8004d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    
  800551:	00 00                	add    %al,(%eax)
	...

00800554 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	57                   	push   %edi
  800558:	56                   	push   %esi
  800559:	53                   	push   %ebx
  80055a:	83 ec 3c             	sub    $0x3c,%esp
  80055d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800560:	89 d7                	mov    %edx,%edi
  800562:	8b 45 08             	mov    0x8(%ebp),%eax
  800565:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800571:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800574:	b8 00 00 00 00       	mov    $0x0,%eax
  800579:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80057c:	72 11                	jb     80058f <printnum+0x3b>
  80057e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800581:	39 45 10             	cmp    %eax,0x10(%ebp)
  800584:	76 09                	jbe    80058f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	85 db                	test   %ebx,%ebx
  80058b:	7f 51                	jg     8005de <printnum+0x8a>
  80058d:	eb 5e                	jmp    8005ed <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800593:	83 eb 01             	sub    $0x1,%ebx
  800596:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059a:	8b 45 10             	mov    0x10(%ebp),%eax
  80059d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a1:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b0:	00 
  8005b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005be:	e8 ad 0a 00 00       	call   801070 <__udivdi3>
  8005c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d2:	89 fa                	mov    %edi,%edx
  8005d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d7:	e8 78 ff ff ff       	call   800554 <printnum>
  8005dc:	eb 0f                	jmp    8005ed <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e2:	89 34 24             	mov    %esi,(%esp)
  8005e5:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e8:	83 eb 01             	sub    $0x1,%ebx
  8005eb:	75 f1                	jne    8005de <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800603:	00 
  800604:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	e8 8a 0b 00 00       	call   8011a0 <__umoddi3>
  800616:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061a:	0f be 80 88 13 80 00 	movsbl 0x801388(%eax),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800627:	83 c4 3c             	add    $0x3c,%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800632:	83 fa 01             	cmp    $0x1,%edx
  800635:	7e 0e                	jle    800645 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800637:	8b 10                	mov    (%eax),%edx
  800639:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063c:	89 08                	mov    %ecx,(%eax)
  80063e:	8b 02                	mov    (%edx),%eax
  800640:	8b 52 04             	mov    0x4(%edx),%edx
  800643:	eb 22                	jmp    800667 <getuint+0x38>
	else if (lflag)
  800645:	85 d2                	test   %edx,%edx
  800647:	74 10                	je     800659 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80064e:	89 08                	mov    %ecx,(%eax)
  800650:	8b 02                	mov    (%edx),%eax
  800652:	ba 00 00 00 00       	mov    $0x0,%edx
  800657:	eb 0e                	jmp    800667 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80065e:	89 08                	mov    %ecx,(%eax)
  800660:	8b 02                	mov    (%edx),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800667:	5d                   	pop    %ebp
  800668:	c3                   	ret    

00800669 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80066f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800673:	8b 10                	mov    (%eax),%edx
  800675:	3b 50 04             	cmp    0x4(%eax),%edx
  800678:	73 0a                	jae    800684 <sprintputch+0x1b>
		*b->buf++ = ch;
  80067a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067d:	88 0a                	mov    %cl,(%edx)
  80067f:	83 c2 01             	add    $0x1,%edx
  800682:	89 10                	mov    %edx,(%eax)
}
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 10             	mov    0x10(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 02 00 00 00       	call   8006ae <vprintfmt>
	va_end(ap);
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	57                   	push   %edi
  8006b2:	56                   	push   %esi
  8006b3:	53                   	push   %ebx
  8006b4:	83 ec 5c             	sub    $0x5c,%esp
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bd:	eb 12                	jmp    8006d1 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 84 e4 04 00 00    	je     800bab <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d1:	0f b6 06             	movzbl (%esi),%eax
  8006d4:	83 c6 01             	add    $0x1,%esi
  8006d7:	83 f8 25             	cmp    $0x25,%eax
  8006da:	75 e3                	jne    8006bf <vprintfmt+0x11>
  8006dc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8006e0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8006e7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ec:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8006fb:	eb 2b                	jmp    800728 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800700:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800704:	eb 22                	jmp    800728 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800709:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80070d:	eb 19                	jmp    800728 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800712:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800719:	eb 0d                	jmp    800728 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80071b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80071e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800721:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	0f b6 06             	movzbl (%esi),%eax
  80072b:	0f b6 d0             	movzbl %al,%edx
  80072e:	8d 7e 01             	lea    0x1(%esi),%edi
  800731:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800734:	83 e8 23             	sub    $0x23,%eax
  800737:	3c 55                	cmp    $0x55,%al
  800739:	0f 87 46 04 00 00    	ja     800b85 <vprintfmt+0x4d7>
  80073f:	0f b6 c0             	movzbl %al,%eax
  800742:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800749:	83 ea 30             	sub    $0x30,%edx
  80074c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80074f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800753:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800756:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800759:	83 fa 09             	cmp    $0x9,%edx
  80075c:	77 4a                	ja     8007a8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800761:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800764:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800767:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80076b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80076e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800771:	83 fa 09             	cmp    $0x9,%edx
  800774:	76 eb                	jbe    800761 <vprintfmt+0xb3>
  800776:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800779:	eb 2d                	jmp    8007a8 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 50 04             	lea    0x4(%eax),%edx
  800781:	89 55 14             	mov    %edx,0x14(%ebp)
  800784:	8b 00                	mov    (%eax),%eax
  800786:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80078c:	eb 1a                	jmp    8007a8 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800791:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800795:	79 91                	jns    800728 <vprintfmt+0x7a>
  800797:	e9 73 ff ff ff       	jmp    80070f <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80079f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007a6:	eb 80                	jmp    800728 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007ac:	0f 89 76 ff ff ff    	jns    800728 <vprintfmt+0x7a>
  8007b2:	e9 64 ff ff ff       	jmp    80071b <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007b7:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007bd:	e9 66 ff ff ff       	jmp    800728 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 04 24             	mov    %eax,(%esp)
  8007d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007da:	e9 f2 fe ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8007df:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8007e3:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8007e6:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8007ea:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8007ed:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8007f1:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8007f4:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8007f7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8007fb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8007fe:	80 f9 09             	cmp    $0x9,%cl
  800801:	77 1d                	ja     800820 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800803:	0f be c0             	movsbl %al,%eax
  800806:	6b c0 64             	imul   $0x64,%eax,%eax
  800809:	0f be d2             	movsbl %dl,%edx
  80080c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80080f:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  800816:	a3 08 20 80 00       	mov    %eax,0x802008
  80081b:	e9 b1 fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800820:	c7 44 24 04 a0 13 80 	movl   $0x8013a0,0x4(%esp)
  800827:	00 
  800828:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	e8 18 05 00 00       	call   800d4b <strcmp>
  800833:	85 c0                	test   %eax,%eax
  800835:	75 0f                	jne    800846 <vprintfmt+0x198>
  800837:	c7 05 08 20 80 00 04 	movl   $0x4,0x802008
  80083e:	00 00 00 
  800841:	e9 8b fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800846:	c7 44 24 04 a4 13 80 	movl   $0x8013a4,0x4(%esp)
  80084d:	00 
  80084e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800851:	89 14 24             	mov    %edx,(%esp)
  800854:	e8 f2 04 00 00       	call   800d4b <strcmp>
  800859:	85 c0                	test   %eax,%eax
  80085b:	75 0f                	jne    80086c <vprintfmt+0x1be>
  80085d:	c7 05 08 20 80 00 02 	movl   $0x2,0x802008
  800864:	00 00 00 
  800867:	e9 65 fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  80086c:	c7 44 24 04 a8 13 80 	movl   $0x8013a8,0x4(%esp)
  800873:	00 
  800874:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800877:	89 0c 24             	mov    %ecx,(%esp)
  80087a:	e8 cc 04 00 00       	call   800d4b <strcmp>
  80087f:	85 c0                	test   %eax,%eax
  800881:	75 0f                	jne    800892 <vprintfmt+0x1e4>
  800883:	c7 05 08 20 80 00 01 	movl   $0x1,0x802008
  80088a:	00 00 00 
  80088d:	e9 3f fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800892:	c7 44 24 04 ac 13 80 	movl   $0x8013ac,0x4(%esp)
  800899:	00 
  80089a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80089d:	89 3c 24             	mov    %edi,(%esp)
  8008a0:	e8 a6 04 00 00       	call   800d4b <strcmp>
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	75 0f                	jne    8008b8 <vprintfmt+0x20a>
  8008a9:	c7 05 08 20 80 00 06 	movl   $0x6,0x802008
  8008b0:	00 00 00 
  8008b3:	e9 19 fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008b8:	c7 44 24 04 b0 13 80 	movl   $0x8013b0,0x4(%esp)
  8008bf:	00 
  8008c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	e8 80 04 00 00       	call   800d4b <strcmp>
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	75 0f                	jne    8008de <vprintfmt+0x230>
  8008cf:	c7 05 08 20 80 00 07 	movl   $0x7,0x802008
  8008d6:	00 00 00 
  8008d9:	e9 f3 fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  8008de:	c7 44 24 04 b4 13 80 	movl   $0x8013b4,0x4(%esp)
  8008e5:	00 
  8008e6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008e9:	89 14 24             	mov    %edx,(%esp)
  8008ec:	e8 5a 04 00 00       	call   800d4b <strcmp>
  8008f1:	83 f8 01             	cmp    $0x1,%eax
  8008f4:	19 c0                	sbb    %eax,%eax
  8008f6:	f7 d0                	not    %eax
  8008f8:	83 c0 08             	add    $0x8,%eax
  8008fb:	a3 08 20 80 00       	mov    %eax,0x802008
  800900:	e9 cc fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 04             	lea    0x4(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	8b 00                	mov    (%eax),%eax
  800910:	89 c2                	mov    %eax,%edx
  800912:	c1 fa 1f             	sar    $0x1f,%edx
  800915:	31 d0                	xor    %edx,%eax
  800917:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800919:	83 f8 08             	cmp    $0x8,%eax
  80091c:	7f 0b                	jg     800929 <vprintfmt+0x27b>
  80091e:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  800925:	85 d2                	test   %edx,%edx
  800927:	75 23                	jne    80094c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800929:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092d:	c7 44 24 08 b8 13 80 	movl   $0x8013b8,0x8(%esp)
  800934:	00 
  800935:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093c:	89 3c 24             	mov    %edi,(%esp)
  80093f:	e8 42 fd ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800944:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800947:	e9 85 fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80094c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800950:	c7 44 24 08 c1 13 80 	movl   $0x8013c1,0x8(%esp)
  800957:	00 
  800958:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	89 3c 24             	mov    %edi,(%esp)
  800962:	e8 1f fd ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800967:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80096a:	e9 62 fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
  80096f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800972:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800975:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8d 50 04             	lea    0x4(%eax),%edx
  80097e:	89 55 14             	mov    %edx,0x14(%ebp)
  800981:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800983:	85 f6                	test   %esi,%esi
  800985:	b8 99 13 80 00       	mov    $0x801399,%eax
  80098a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80098d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800991:	7e 06                	jle    800999 <vprintfmt+0x2eb>
  800993:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800997:	75 13                	jne    8009ac <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800999:	0f be 06             	movsbl (%esi),%eax
  80099c:	83 c6 01             	add    $0x1,%esi
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	0f 85 94 00 00 00    	jne    800a3b <vprintfmt+0x38d>
  8009a7:	e9 81 00 00 00       	jmp    800a2d <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b0:	89 34 24             	mov    %esi,(%esp)
  8009b3:	e8 a3 02 00 00       	call   800c5b <strnlen>
  8009b8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009bb:	29 c2                	sub    %eax,%edx
  8009bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009c0:	85 d2                	test   %edx,%edx
  8009c2:	7e d5                	jle    800999 <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009c4:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009c8:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009cb:	89 7d c0             	mov    %edi,-0x40(%ebp)
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	89 cf                	mov    %ecx,%edi
  8009d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d6:	89 3c 24             	mov    %edi,(%esp)
  8009d9:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009dc:	83 ee 01             	sub    $0x1,%esi
  8009df:	75 f1                	jne    8009d2 <vprintfmt+0x324>
  8009e1:	8b 7d c0             	mov    -0x40(%ebp),%edi
  8009e4:	89 75 cc             	mov    %esi,-0x34(%ebp)
  8009e7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  8009ea:	eb ad                	jmp    800999 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ec:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8009f0:	74 1b                	je     800a0d <vprintfmt+0x35f>
  8009f2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009f5:	83 fa 5e             	cmp    $0x5e,%edx
  8009f8:	76 13                	jbe    800a0d <vprintfmt+0x35f>
					putch('?', putdat);
  8009fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8009fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a01:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a08:	ff 55 08             	call   *0x8(%ebp)
  800a0b:	eb 0d                	jmp    800a1a <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a0d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a10:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a14:	89 04 24             	mov    %eax,(%esp)
  800a17:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1a:	83 eb 01             	sub    $0x1,%ebx
  800a1d:	0f be 06             	movsbl (%esi),%eax
  800a20:	83 c6 01             	add    $0x1,%esi
  800a23:	85 c0                	test   %eax,%eax
  800a25:	75 1a                	jne    800a41 <vprintfmt+0x393>
  800a27:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a2a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a30:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a34:	7f 1c                	jg     800a52 <vprintfmt+0x3a4>
  800a36:	e9 96 fc ff ff       	jmp    8006d1 <vprintfmt+0x23>
  800a3b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a3e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a41:	85 ff                	test   %edi,%edi
  800a43:	78 a7                	js     8009ec <vprintfmt+0x33e>
  800a45:	83 ef 01             	sub    $0x1,%edi
  800a48:	79 a2                	jns    8009ec <vprintfmt+0x33e>
  800a4a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a4d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a50:	eb db                	jmp    800a2d <vprintfmt+0x37f>
  800a52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a55:	89 de                	mov    %ebx,%esi
  800a57:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a65:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a67:	83 eb 01             	sub    $0x1,%ebx
  800a6a:	75 ee                	jne    800a5a <vprintfmt+0x3ac>
  800a6c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800a71:	e9 5b fc ff ff       	jmp    8006d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a76:	83 f9 01             	cmp    $0x1,%ecx
  800a79:	7e 10                	jle    800a8b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7e:	8d 50 08             	lea    0x8(%eax),%edx
  800a81:	89 55 14             	mov    %edx,0x14(%ebp)
  800a84:	8b 30                	mov    (%eax),%esi
  800a86:	8b 78 04             	mov    0x4(%eax),%edi
  800a89:	eb 26                	jmp    800ab1 <vprintfmt+0x403>
	else if (lflag)
  800a8b:	85 c9                	test   %ecx,%ecx
  800a8d:	74 12                	je     800aa1 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a92:	8d 50 04             	lea    0x4(%eax),%edx
  800a95:	89 55 14             	mov    %edx,0x14(%ebp)
  800a98:	8b 30                	mov    (%eax),%esi
  800a9a:	89 f7                	mov    %esi,%edi
  800a9c:	c1 ff 1f             	sar    $0x1f,%edi
  800a9f:	eb 10                	jmp    800ab1 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800aa1:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa4:	8d 50 04             	lea    0x4(%eax),%edx
  800aa7:	89 55 14             	mov    %edx,0x14(%ebp)
  800aaa:	8b 30                	mov    (%eax),%esi
  800aac:	89 f7                	mov    %esi,%edi
  800aae:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ab1:	85 ff                	test   %edi,%edi
  800ab3:	78 0e                	js     800ac3 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ab5:	89 f0                	mov    %esi,%eax
  800ab7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ab9:	be 0a 00 00 00       	mov    $0xa,%esi
  800abe:	e9 84 00 00 00       	jmp    800b47 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ac3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ace:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ad1:	89 f0                	mov    %esi,%eax
  800ad3:	89 fa                	mov    %edi,%edx
  800ad5:	f7 d8                	neg    %eax
  800ad7:	83 d2 00             	adc    $0x0,%edx
  800ada:	f7 da                	neg    %edx
			}
			base = 10;
  800adc:	be 0a 00 00 00       	mov    $0xa,%esi
  800ae1:	eb 64                	jmp    800b47 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ae3:	89 ca                	mov    %ecx,%edx
  800ae5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae8:	e8 42 fb ff ff       	call   80062f <getuint>
			base = 10;
  800aed:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800af2:	eb 53                	jmp    800b47 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800af4:	89 ca                	mov    %ecx,%edx
  800af6:	8d 45 14             	lea    0x14(%ebp),%eax
  800af9:	e8 31 fb ff ff       	call   80062f <getuint>
    			base = 8;
  800afe:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b03:	eb 42                	jmp    800b47 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b09:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b10:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b17:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b1e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 04             	lea    0x4(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b2a:	8b 00                	mov    (%eax),%eax
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b31:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b36:	eb 0f                	jmp    800b47 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b38:	89 ca                	mov    %ecx,%edx
  800b3a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3d:	e8 ed fa ff ff       	call   80062f <getuint>
			base = 16;
  800b42:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b47:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b4b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b4f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b52:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b56:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b5a:	89 04 24             	mov    %eax,(%esp)
  800b5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b61:	89 da                	mov    %ebx,%edx
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	e8 e9 f9 ff ff       	call   800554 <printnum>
			break;
  800b6b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b6e:	e9 5e fb ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b77:	89 14 24             	mov    %edx,(%esp)
  800b7a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b7d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b80:	e9 4c fb ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b89:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b90:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b93:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b97:	0f 84 34 fb ff ff    	je     8006d1 <vprintfmt+0x23>
  800b9d:	83 ee 01             	sub    $0x1,%esi
  800ba0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ba4:	75 f7                	jne    800b9d <vprintfmt+0x4ef>
  800ba6:	e9 26 fb ff ff       	jmp    8006d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bab:	83 c4 5c             	add    $0x5c,%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 28             	sub    $0x28,%esp
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bc2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	74 30                	je     800c04 <vsnprintf+0x51>
  800bd4:	85 d2                	test   %edx,%edx
  800bd6:	7e 2c                	jle    800c04 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bed:	c7 04 24 69 06 80 00 	movl   $0x800669,(%esp)
  800bf4:	e8 b5 fa ff ff       	call   8006ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bfc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c02:	eb 05                	jmp    800c09 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c18:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	89 04 24             	mov    %eax,(%esp)
  800c2c:	e8 82 ff ff ff       	call   800bb3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    
	...

00800c40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c4e:	74 09                	je     800c59 <strlen+0x19>
		n++;
  800c50:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c53:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c57:	75 f7                	jne    800c50 <strlen+0x10>
		n++;
	return n;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	53                   	push   %ebx
  800c5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	85 c9                	test   %ecx,%ecx
  800c6c:	74 1a                	je     800c88 <strnlen+0x2d>
  800c6e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c71:	74 15                	je     800c88 <strnlen+0x2d>
  800c73:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c78:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7a:	39 ca                	cmp    %ecx,%edx
  800c7c:	74 0a                	je     800c88 <strnlen+0x2d>
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c86:	75 f0                	jne    800c78 <strnlen+0x1d>
		n++;
	return n;
}
  800c88:	5b                   	pop    %ebx
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	53                   	push   %ebx
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c95:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c9e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ca1:	83 c2 01             	add    $0x1,%edx
  800ca4:	84 c9                	test   %cl,%cl
  800ca6:	75 f2                	jne    800c9a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	83 ec 08             	sub    $0x8,%esp
  800cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cb5:	89 1c 24             	mov    %ebx,(%esp)
  800cb8:	e8 83 ff ff ff       	call   800c40 <strlen>
	strcpy(dst + len, src);
  800cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cc4:	01 d8                	add    %ebx,%eax
  800cc6:	89 04 24             	mov    %eax,(%esp)
  800cc9:	e8 bd ff ff ff       	call   800c8b <strcpy>
	return dst;
}
  800cce:	89 d8                	mov    %ebx,%eax
  800cd0:	83 c4 08             	add    $0x8,%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce4:	85 f6                	test   %esi,%esi
  800ce6:	74 18                	je     800d00 <strncpy+0x2a>
  800ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800ced:	0f b6 1a             	movzbl (%edx),%ebx
  800cf0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cf3:	80 3a 01             	cmpb   $0x1,(%edx)
  800cf6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	39 f1                	cmp    %esi,%ecx
  800cfe:	75 ed                	jne    800ced <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d10:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d13:	89 f8                	mov    %edi,%eax
  800d15:	85 f6                	test   %esi,%esi
  800d17:	74 2b                	je     800d44 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d19:	83 fe 01             	cmp    $0x1,%esi
  800d1c:	74 23                	je     800d41 <strlcpy+0x3d>
  800d1e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d21:	84 c9                	test   %cl,%cl
  800d23:	74 1c                	je     800d41 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d25:	83 ee 02             	sub    $0x2,%esi
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d2d:	88 08                	mov    %cl,(%eax)
  800d2f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d32:	39 f2                	cmp    %esi,%edx
  800d34:	74 0b                	je     800d41 <strlcpy+0x3d>
  800d36:	83 c2 01             	add    $0x1,%edx
  800d39:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d3d:	84 c9                	test   %cl,%cl
  800d3f:	75 ec                	jne    800d2d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d44:	29 f8                	sub    %edi,%eax
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d51:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d54:	0f b6 01             	movzbl (%ecx),%eax
  800d57:	84 c0                	test   %al,%al
  800d59:	74 16                	je     800d71 <strcmp+0x26>
  800d5b:	3a 02                	cmp    (%edx),%al
  800d5d:	75 12                	jne    800d71 <strcmp+0x26>
		p++, q++;
  800d5f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d62:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d66:	84 c0                	test   %al,%al
  800d68:	74 07                	je     800d71 <strcmp+0x26>
  800d6a:	83 c1 01             	add    $0x1,%ecx
  800d6d:	3a 02                	cmp    (%edx),%al
  800d6f:	74 ee                	je     800d5f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d71:	0f b6 c0             	movzbl %al,%eax
  800d74:	0f b6 12             	movzbl (%edx),%edx
  800d77:	29 d0                	sub    %edx,%eax
}
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	53                   	push   %ebx
  800d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d85:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d8d:	85 d2                	test   %edx,%edx
  800d8f:	74 28                	je     800db9 <strncmp+0x3e>
  800d91:	0f b6 01             	movzbl (%ecx),%eax
  800d94:	84 c0                	test   %al,%al
  800d96:	74 24                	je     800dbc <strncmp+0x41>
  800d98:	3a 03                	cmp    (%ebx),%al
  800d9a:	75 20                	jne    800dbc <strncmp+0x41>
  800d9c:	83 ea 01             	sub    $0x1,%edx
  800d9f:	74 13                	je     800db4 <strncmp+0x39>
		n--, p++, q++;
  800da1:	83 c1 01             	add    $0x1,%ecx
  800da4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800da7:	0f b6 01             	movzbl (%ecx),%eax
  800daa:	84 c0                	test   %al,%al
  800dac:	74 0e                	je     800dbc <strncmp+0x41>
  800dae:	3a 03                	cmp    (%ebx),%al
  800db0:	74 ea                	je     800d9c <strncmp+0x21>
  800db2:	eb 08                	jmp    800dbc <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	0f b6 13             	movzbl (%ebx),%edx
  800dc2:	29 d0                	sub    %edx,%eax
  800dc4:	eb f3                	jmp    800db9 <strncmp+0x3e>

00800dc6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dd0:	0f b6 10             	movzbl (%eax),%edx
  800dd3:	84 d2                	test   %dl,%dl
  800dd5:	74 1c                	je     800df3 <strchr+0x2d>
		if (*s == c)
  800dd7:	38 ca                	cmp    %cl,%dl
  800dd9:	75 09                	jne    800de4 <strchr+0x1e>
  800ddb:	eb 1b                	jmp    800df8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ddd:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800de0:	38 ca                	cmp    %cl,%dl
  800de2:	74 14                	je     800df8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800de4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800de8:	84 d2                	test   %dl,%dl
  800dea:	75 f1                	jne    800ddd <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	eb 05                	jmp    800df8 <strchr+0x32>
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e04:	0f b6 10             	movzbl (%eax),%edx
  800e07:	84 d2                	test   %dl,%dl
  800e09:	74 14                	je     800e1f <strfind+0x25>
		if (*s == c)
  800e0b:	38 ca                	cmp    %cl,%dl
  800e0d:	75 06                	jne    800e15 <strfind+0x1b>
  800e0f:	eb 0e                	jmp    800e1f <strfind+0x25>
  800e11:	38 ca                	cmp    %cl,%dl
  800e13:	74 0a                	je     800e1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e15:	83 c0 01             	add    $0x1,%eax
  800e18:	0f b6 10             	movzbl (%eax),%edx
  800e1b:	84 d2                	test   %dl,%dl
  800e1d:	75 f2                	jne    800e11 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e2a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e39:	85 c9                	test   %ecx,%ecx
  800e3b:	74 30                	je     800e6d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e43:	75 25                	jne    800e6a <memset+0x49>
  800e45:	f6 c1 03             	test   $0x3,%cl
  800e48:	75 20                	jne    800e6a <memset+0x49>
		c &= 0xFF;
  800e4a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4d:	89 d3                	mov    %edx,%ebx
  800e4f:	c1 e3 08             	shl    $0x8,%ebx
  800e52:	89 d6                	mov    %edx,%esi
  800e54:	c1 e6 18             	shl    $0x18,%esi
  800e57:	89 d0                	mov    %edx,%eax
  800e59:	c1 e0 10             	shl    $0x10,%eax
  800e5c:	09 f0                	or     %esi,%eax
  800e5e:	09 d0                	or     %edx,%eax
  800e60:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e62:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e65:	fc                   	cld    
  800e66:	f3 ab                	rep stos %eax,%es:(%edi)
  800e68:	eb 03                	jmp    800e6d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e6a:	fc                   	cld    
  800e6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e6d:	89 f8                	mov    %edi,%eax
  800e6f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e72:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e75:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e85:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e91:	39 c6                	cmp    %eax,%esi
  800e93:	73 36                	jae    800ecb <memmove+0x4f>
  800e95:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e98:	39 d0                	cmp    %edx,%eax
  800e9a:	73 2f                	jae    800ecb <memmove+0x4f>
		s += n;
		d += n;
  800e9c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e9f:	f6 c2 03             	test   $0x3,%dl
  800ea2:	75 1b                	jne    800ebf <memmove+0x43>
  800ea4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eaa:	75 13                	jne    800ebf <memmove+0x43>
  800eac:	f6 c1 03             	test   $0x3,%cl
  800eaf:	75 0e                	jne    800ebf <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb1:	83 ef 04             	sub    $0x4,%edi
  800eb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eb7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eba:	fd                   	std    
  800ebb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ebd:	eb 09                	jmp    800ec8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ebf:	83 ef 01             	sub    $0x1,%edi
  800ec2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ec5:	fd                   	std    
  800ec6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ec8:	fc                   	cld    
  800ec9:	eb 20                	jmp    800eeb <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ecb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ed1:	75 13                	jne    800ee6 <memmove+0x6a>
  800ed3:	a8 03                	test   $0x3,%al
  800ed5:	75 0f                	jne    800ee6 <memmove+0x6a>
  800ed7:	f6 c1 03             	test   $0x3,%cl
  800eda:	75 0a                	jne    800ee6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800edc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800edf:	89 c7                	mov    %eax,%edi
  800ee1:	fc                   	cld    
  800ee2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee4:	eb 05                	jmp    800eeb <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ee6:	89 c7                	mov    %eax,%edi
  800ee8:	fc                   	cld    
  800ee9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eeb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eee:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800efb:	8b 45 10             	mov    0x10(%ebp),%eax
  800efe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	89 04 24             	mov    %eax,(%esp)
  800f0f:	e8 68 ff ff ff       	call   800e7c <memmove>
}
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f22:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f2a:	85 ff                	test   %edi,%edi
  800f2c:	74 37                	je     800f65 <memcmp+0x4f>
		if (*s1 != *s2)
  800f2e:	0f b6 03             	movzbl (%ebx),%eax
  800f31:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f34:	83 ef 01             	sub    $0x1,%edi
  800f37:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f3c:	38 c8                	cmp    %cl,%al
  800f3e:	74 1c                	je     800f5c <memcmp+0x46>
  800f40:	eb 10                	jmp    800f52 <memcmp+0x3c>
  800f42:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f47:	83 c2 01             	add    $0x1,%edx
  800f4a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f4e:	38 c8                	cmp    %cl,%al
  800f50:	74 0a                	je     800f5c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f52:	0f b6 c0             	movzbl %al,%eax
  800f55:	0f b6 c9             	movzbl %cl,%ecx
  800f58:	29 c8                	sub    %ecx,%eax
  800f5a:	eb 09                	jmp    800f65 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f5c:	39 fa                	cmp    %edi,%edx
  800f5e:	75 e2                	jne    800f42 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f70:	89 c2                	mov    %eax,%edx
  800f72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f75:	39 d0                	cmp    %edx,%eax
  800f77:	73 19                	jae    800f92 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f7d:	38 08                	cmp    %cl,(%eax)
  800f7f:	75 06                	jne    800f87 <memfind+0x1d>
  800f81:	eb 0f                	jmp    800f92 <memfind+0x28>
  800f83:	38 08                	cmp    %cl,(%eax)
  800f85:	74 0b                	je     800f92 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f87:	83 c0 01             	add    $0x1,%eax
  800f8a:	39 d0                	cmp    %edx,%eax
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	75 f1                	jne    800f83 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa0:	0f b6 02             	movzbl (%edx),%eax
  800fa3:	3c 20                	cmp    $0x20,%al
  800fa5:	74 04                	je     800fab <strtol+0x17>
  800fa7:	3c 09                	cmp    $0x9,%al
  800fa9:	75 0e                	jne    800fb9 <strtol+0x25>
		s++;
  800fab:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fae:	0f b6 02             	movzbl (%edx),%eax
  800fb1:	3c 20                	cmp    $0x20,%al
  800fb3:	74 f6                	je     800fab <strtol+0x17>
  800fb5:	3c 09                	cmp    $0x9,%al
  800fb7:	74 f2                	je     800fab <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fb9:	3c 2b                	cmp    $0x2b,%al
  800fbb:	75 0a                	jne    800fc7 <strtol+0x33>
		s++;
  800fbd:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc5:	eb 10                	jmp    800fd7 <strtol+0x43>
  800fc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fcc:	3c 2d                	cmp    $0x2d,%al
  800fce:	75 07                	jne    800fd7 <strtol+0x43>
		s++, neg = 1;
  800fd0:	83 c2 01             	add    $0x1,%edx
  800fd3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd7:	85 db                	test   %ebx,%ebx
  800fd9:	0f 94 c0             	sete   %al
  800fdc:	74 05                	je     800fe3 <strtol+0x4f>
  800fde:	83 fb 10             	cmp    $0x10,%ebx
  800fe1:	75 15                	jne    800ff8 <strtol+0x64>
  800fe3:	80 3a 30             	cmpb   $0x30,(%edx)
  800fe6:	75 10                	jne    800ff8 <strtol+0x64>
  800fe8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fec:	75 0a                	jne    800ff8 <strtol+0x64>
		s += 2, base = 16;
  800fee:	83 c2 02             	add    $0x2,%edx
  800ff1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ff6:	eb 13                	jmp    80100b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ff8:	84 c0                	test   %al,%al
  800ffa:	74 0f                	je     80100b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ffc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801001:	80 3a 30             	cmpb   $0x30,(%edx)
  801004:	75 05                	jne    80100b <strtol+0x77>
		s++, base = 8;
  801006:	83 c2 01             	add    $0x1,%edx
  801009:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80100b:	b8 00 00 00 00       	mov    $0x0,%eax
  801010:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801012:	0f b6 0a             	movzbl (%edx),%ecx
  801015:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801018:	80 fb 09             	cmp    $0x9,%bl
  80101b:	77 08                	ja     801025 <strtol+0x91>
			dig = *s - '0';
  80101d:	0f be c9             	movsbl %cl,%ecx
  801020:	83 e9 30             	sub    $0x30,%ecx
  801023:	eb 1e                	jmp    801043 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801025:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801028:	80 fb 19             	cmp    $0x19,%bl
  80102b:	77 08                	ja     801035 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80102d:	0f be c9             	movsbl %cl,%ecx
  801030:	83 e9 57             	sub    $0x57,%ecx
  801033:	eb 0e                	jmp    801043 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801035:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801038:	80 fb 19             	cmp    $0x19,%bl
  80103b:	77 14                	ja     801051 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80103d:	0f be c9             	movsbl %cl,%ecx
  801040:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801043:	39 f1                	cmp    %esi,%ecx
  801045:	7d 0e                	jge    801055 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801047:	83 c2 01             	add    $0x1,%edx
  80104a:	0f af c6             	imul   %esi,%eax
  80104d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80104f:	eb c1                	jmp    801012 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801051:	89 c1                	mov    %eax,%ecx
  801053:	eb 02                	jmp    801057 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801055:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801057:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80105b:	74 05                	je     801062 <strtol+0xce>
		*endptr = (char *) s;
  80105d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801060:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801062:	89 ca                	mov    %ecx,%edx
  801064:	f7 da                	neg    %edx
  801066:	85 ff                	test   %edi,%edi
  801068:	0f 45 c2             	cmovne %edx,%eax
}
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <__udivdi3>:
  801070:	83 ec 1c             	sub    $0x1c,%esp
  801073:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801077:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80107b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80107f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801083:	89 74 24 10          	mov    %esi,0x10(%esp)
  801087:	8b 74 24 24          	mov    0x24(%esp),%esi
  80108b:	85 ff                	test   %edi,%edi
  80108d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801091:	89 44 24 08          	mov    %eax,0x8(%esp)
  801095:	89 cd                	mov    %ecx,%ebp
  801097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109b:	75 33                	jne    8010d0 <__udivdi3+0x60>
  80109d:	39 f1                	cmp    %esi,%ecx
  80109f:	77 57                	ja     8010f8 <__udivdi3+0x88>
  8010a1:	85 c9                	test   %ecx,%ecx
  8010a3:	75 0b                	jne    8010b0 <__udivdi3+0x40>
  8010a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010aa:	31 d2                	xor    %edx,%edx
  8010ac:	f7 f1                	div    %ecx
  8010ae:	89 c1                	mov    %eax,%ecx
  8010b0:	89 f0                	mov    %esi,%eax
  8010b2:	31 d2                	xor    %edx,%edx
  8010b4:	f7 f1                	div    %ecx
  8010b6:	89 c6                	mov    %eax,%esi
  8010b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010bc:	f7 f1                	div    %ecx
  8010be:	89 f2                	mov    %esi,%edx
  8010c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010c4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010cc:	83 c4 1c             	add    $0x1c,%esp
  8010cf:	c3                   	ret    
  8010d0:	31 d2                	xor    %edx,%edx
  8010d2:	31 c0                	xor    %eax,%eax
  8010d4:	39 f7                	cmp    %esi,%edi
  8010d6:	77 e8                	ja     8010c0 <__udivdi3+0x50>
  8010d8:	0f bd cf             	bsr    %edi,%ecx
  8010db:	83 f1 1f             	xor    $0x1f,%ecx
  8010de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010e2:	75 2c                	jne    801110 <__udivdi3+0xa0>
  8010e4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010e8:	76 04                	jbe    8010ee <__udivdi3+0x7e>
  8010ea:	39 f7                	cmp    %esi,%edi
  8010ec:	73 d2                	jae    8010c0 <__udivdi3+0x50>
  8010ee:	31 d2                	xor    %edx,%edx
  8010f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f5:	eb c9                	jmp    8010c0 <__udivdi3+0x50>
  8010f7:	90                   	nop
  8010f8:	89 f2                	mov    %esi,%edx
  8010fa:	f7 f1                	div    %ecx
  8010fc:	31 d2                	xor    %edx,%edx
  8010fe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801102:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801106:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110a:	83 c4 1c             	add    $0x1c,%esp
  80110d:	c3                   	ret    
  80110e:	66 90                	xchg   %ax,%ax
  801110:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801115:	b8 20 00 00 00       	mov    $0x20,%eax
  80111a:	89 ea                	mov    %ebp,%edx
  80111c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801120:	d3 e7                	shl    %cl,%edi
  801122:	89 c1                	mov    %eax,%ecx
  801124:	d3 ea                	shr    %cl,%edx
  801126:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112b:	09 fa                	or     %edi,%edx
  80112d:	89 f7                	mov    %esi,%edi
  80112f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801133:	89 f2                	mov    %esi,%edx
  801135:	8b 74 24 08          	mov    0x8(%esp),%esi
  801139:	d3 e5                	shl    %cl,%ebp
  80113b:	89 c1                	mov    %eax,%ecx
  80113d:	d3 ef                	shr    %cl,%edi
  80113f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801144:	d3 e2                	shl    %cl,%edx
  801146:	89 c1                	mov    %eax,%ecx
  801148:	d3 ee                	shr    %cl,%esi
  80114a:	09 d6                	or     %edx,%esi
  80114c:	89 fa                	mov    %edi,%edx
  80114e:	89 f0                	mov    %esi,%eax
  801150:	f7 74 24 0c          	divl   0xc(%esp)
  801154:	89 d7                	mov    %edx,%edi
  801156:	89 c6                	mov    %eax,%esi
  801158:	f7 e5                	mul    %ebp
  80115a:	39 d7                	cmp    %edx,%edi
  80115c:	72 22                	jb     801180 <__udivdi3+0x110>
  80115e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801162:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801167:	d3 e5                	shl    %cl,%ebp
  801169:	39 c5                	cmp    %eax,%ebp
  80116b:	73 04                	jae    801171 <__udivdi3+0x101>
  80116d:	39 d7                	cmp    %edx,%edi
  80116f:	74 0f                	je     801180 <__udivdi3+0x110>
  801171:	89 f0                	mov    %esi,%eax
  801173:	31 d2                	xor    %edx,%edx
  801175:	e9 46 ff ff ff       	jmp    8010c0 <__udivdi3+0x50>
  80117a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801180:	8d 46 ff             	lea    -0x1(%esi),%eax
  801183:	31 d2                	xor    %edx,%edx
  801185:	8b 74 24 10          	mov    0x10(%esp),%esi
  801189:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80118d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801191:	83 c4 1c             	add    $0x1c,%esp
  801194:	c3                   	ret    
	...

008011a0 <__umoddi3>:
  8011a0:	83 ec 1c             	sub    $0x1c,%esp
  8011a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011bb:	85 ed                	test   %ebp,%ebp
  8011bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	89 cf                	mov    %ecx,%edi
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	89 f2                	mov    %esi,%edx
  8011cc:	75 1a                	jne    8011e8 <__umoddi3+0x48>
  8011ce:	39 f1                	cmp    %esi,%ecx
  8011d0:	76 4e                	jbe    801220 <__umoddi3+0x80>
  8011d2:	f7 f1                	div    %ecx
  8011d4:	89 d0                	mov    %edx,%eax
  8011d6:	31 d2                	xor    %edx,%edx
  8011d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e4:	83 c4 1c             	add    $0x1c,%esp
  8011e7:	c3                   	ret    
  8011e8:	39 f5                	cmp    %esi,%ebp
  8011ea:	77 54                	ja     801240 <__umoddi3+0xa0>
  8011ec:	0f bd c5             	bsr    %ebp,%eax
  8011ef:	83 f0 1f             	xor    $0x1f,%eax
  8011f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f6:	75 60                	jne    801258 <__umoddi3+0xb8>
  8011f8:	3b 0c 24             	cmp    (%esp),%ecx
  8011fb:	0f 87 07 01 00 00    	ja     801308 <__umoddi3+0x168>
  801201:	89 f2                	mov    %esi,%edx
  801203:	8b 34 24             	mov    (%esp),%esi
  801206:	29 ce                	sub    %ecx,%esi
  801208:	19 ea                	sbb    %ebp,%edx
  80120a:	89 34 24             	mov    %esi,(%esp)
  80120d:	8b 04 24             	mov    (%esp),%eax
  801210:	8b 74 24 10          	mov    0x10(%esp),%esi
  801214:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801218:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80121c:	83 c4 1c             	add    $0x1c,%esp
  80121f:	c3                   	ret    
  801220:	85 c9                	test   %ecx,%ecx
  801222:	75 0b                	jne    80122f <__umoddi3+0x8f>
  801224:	b8 01 00 00 00       	mov    $0x1,%eax
  801229:	31 d2                	xor    %edx,%edx
  80122b:	f7 f1                	div    %ecx
  80122d:	89 c1                	mov    %eax,%ecx
  80122f:	89 f0                	mov    %esi,%eax
  801231:	31 d2                	xor    %edx,%edx
  801233:	f7 f1                	div    %ecx
  801235:	8b 04 24             	mov    (%esp),%eax
  801238:	f7 f1                	div    %ecx
  80123a:	eb 98                	jmp    8011d4 <__umoddi3+0x34>
  80123c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801240:	89 f2                	mov    %esi,%edx
  801242:	8b 74 24 10          	mov    0x10(%esp),%esi
  801246:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80124a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124e:	83 c4 1c             	add    $0x1c,%esp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125d:	89 e8                	mov    %ebp,%eax
  80125f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801264:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801268:	89 fa                	mov    %edi,%edx
  80126a:	d3 e0                	shl    %cl,%eax
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	d3 ea                	shr    %cl,%edx
  801270:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801275:	09 c2                	or     %eax,%edx
  801277:	8b 44 24 08          	mov    0x8(%esp),%eax
  80127b:	89 14 24             	mov    %edx,(%esp)
  80127e:	89 f2                	mov    %esi,%edx
  801280:	d3 e7                	shl    %cl,%edi
  801282:	89 e9                	mov    %ebp,%ecx
  801284:	d3 ea                	shr    %cl,%edx
  801286:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80128f:	d3 e6                	shl    %cl,%esi
  801291:	89 e9                	mov    %ebp,%ecx
  801293:	d3 e8                	shr    %cl,%eax
  801295:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129a:	09 f0                	or     %esi,%eax
  80129c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012a0:	f7 34 24             	divl   (%esp)
  8012a3:	d3 e6                	shl    %cl,%esi
  8012a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012a9:	89 d6                	mov    %edx,%esi
  8012ab:	f7 e7                	mul    %edi
  8012ad:	39 d6                	cmp    %edx,%esi
  8012af:	89 c1                	mov    %eax,%ecx
  8012b1:	89 d7                	mov    %edx,%edi
  8012b3:	72 3f                	jb     8012f4 <__umoddi3+0x154>
  8012b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012b9:	72 35                	jb     8012f0 <__umoddi3+0x150>
  8012bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012bf:	29 c8                	sub    %ecx,%eax
  8012c1:	19 fe                	sbb    %edi,%esi
  8012c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012c8:	89 f2                	mov    %esi,%edx
  8012ca:	d3 e8                	shr    %cl,%eax
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d5:	09 d0                	or     %edx,%eax
  8012d7:	89 f2                	mov    %esi,%edx
  8012d9:	d3 ea                	shr    %cl,%edx
  8012db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012e7:	83 c4 1c             	add    $0x1c,%esp
  8012ea:	c3                   	ret    
  8012eb:	90                   	nop
  8012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	39 d6                	cmp    %edx,%esi
  8012f2:	75 c7                	jne    8012bb <__umoddi3+0x11b>
  8012f4:	89 d7                	mov    %edx,%edi
  8012f6:	89 c1                	mov    %eax,%ecx
  8012f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012fc:	1b 3c 24             	sbb    (%esp),%edi
  8012ff:	eb ba                	jmp    8012bb <__umoddi3+0x11b>
  801301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 f5                	cmp    %esi,%ebp
  80130a:	0f 82 f1 fe ff ff    	jb     801201 <__umoddi3+0x61>
  801310:	e9 f8 fe ff ff       	jmp    80120d <__umoddi3+0x6d>
