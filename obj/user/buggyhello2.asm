
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
  800070:	c1 e0 07             	shl    $0x7,%eax
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
  80014b:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  800162:	e8 09 03 00 00       	call   800470 <_panic>

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
  80020a:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  800211:	00 
  800212:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800219:	00 
  80021a:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  800221:	e8 4a 02 00 00       	call   800470 <_panic>

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
  800268:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  80026f:	00 
  800270:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800277:	00 
  800278:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  80027f:	e8 ec 01 00 00       	call   800470 <_panic>

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
  8002c6:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  8002dd:	e8 8e 01 00 00       	call   800470 <_panic>

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
  800324:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  80032b:	00 
  80032c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800333:	00 
  800334:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  80033b:	e8 30 01 00 00       	call   800470 <_panic>

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
  800382:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  800399:	e8 d2 00 00 00       	call   800470 <_panic>

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
  800413:	c7 44 24 08 78 13 80 	movl   $0x801378,0x8(%esp)
  80041a:	00 
  80041b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800422:	00 
  800423:	c7 04 24 95 13 80 00 	movl   $0x801395,(%esp)
  80042a:	e8 41 00 00 00       	call   800470 <_panic>

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

0080043c <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	83 ec 0c             	sub    $0xc,%esp
  800442:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800445:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800448:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80044b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800450:	b8 0d 00 00 00       	mov    $0xd,%eax
  800455:	8b 55 08             	mov    0x8(%ebp),%edx
  800458:	89 cb                	mov    %ecx,%ebx
  80045a:	89 cf                	mov    %ecx,%edi
  80045c:	89 ce                	mov    %ecx,%esi
  80045e:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  800460:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800463:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800466:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800469:	89 ec                	mov    %ebp,%esp
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    
  80046d:	00 00                	add    %al,(%eax)
	...

00800470 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	56                   	push   %esi
  800474:	53                   	push   %ebx
  800475:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800478:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80047b:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800481:	e8 ee fc ff ff       	call   800174 <sys_getenvid>
  800486:	8b 55 0c             	mov    0xc(%ebp),%edx
  800489:	89 54 24 10          	mov    %edx,0x10(%esp)
  80048d:	8b 55 08             	mov    0x8(%ebp),%edx
  800490:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800494:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049c:	c7 04 24 a4 13 80 00 	movl   $0x8013a4,(%esp)
  8004a3:	e8 c3 00 00 00       	call   80056b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	e8 53 00 00 00       	call   80050a <vcprintf>
	cprintf("\n");
  8004b7:	c7 04 24 6c 13 80 00 	movl   $0x80136c,(%esp)
  8004be:	e8 a8 00 00 00       	call   80056b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004c3:	cc                   	int3   
  8004c4:	eb fd                	jmp    8004c3 <_panic+0x53>
	...

008004c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	53                   	push   %ebx
  8004cc:	83 ec 14             	sub    $0x14,%esp
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004d2:	8b 03                	mov    (%ebx),%eax
  8004d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004db:	83 c0 01             	add    $0x1,%eax
  8004de:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e5:	75 19                	jne    800500 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004ee:	00 
  8004ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8004f2:	89 04 24             	mov    %eax,(%esp)
  8004f5:	e8 be fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  8004fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800500:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800504:	83 c4 14             	add    $0x14,%esp
  800507:	5b                   	pop    %ebx
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800513:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80051a:	00 00 00 
	b.cnt = 0;
  80051d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800524:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800527:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052e:	8b 45 08             	mov    0x8(%ebp),%eax
  800531:	89 44 24 08          	mov    %eax,0x8(%esp)
  800535:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	c7 04 24 c8 04 80 00 	movl   $0x8004c8,(%esp)
  800546:	e8 97 01 00 00       	call   8006e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80054b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	e8 55 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800563:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800569:	c9                   	leave  
  80056a:	c3                   	ret    

0080056b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80056b:	55                   	push   %ebp
  80056c:	89 e5                	mov    %esp,%ebp
  80056e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800571:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800574:	89 44 24 04          	mov    %eax,0x4(%esp)
  800578:	8b 45 08             	mov    0x8(%ebp),%eax
  80057b:	89 04 24             	mov    %eax,(%esp)
  80057e:	e8 87 ff ff ff       	call   80050a <vcprintf>
	va_end(ap);

	return cnt;
}
  800583:	c9                   	leave  
  800584:	c3                   	ret    
  800585:	00 00                	add    %al,(%eax)
	...

00800588 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	57                   	push   %edi
  80058c:	56                   	push   %esi
  80058d:	53                   	push   %ebx
  80058e:	83 ec 3c             	sub    $0x3c,%esp
  800591:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800594:	89 d7                	mov    %edx,%edi
  800596:	8b 45 08             	mov    0x8(%ebp),%eax
  800599:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80059c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005b0:	72 11                	jb     8005c3 <printnum+0x3b>
  8005b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005b8:	76 09                	jbe    8005c3 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005ba:	83 eb 01             	sub    $0x1,%ebx
  8005bd:	85 db                	test   %ebx,%ebx
  8005bf:	7f 51                	jg     800612 <printnum+0x8a>
  8005c1:	eb 5e                	jmp    800621 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005c3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005c7:	83 eb 01             	sub    $0x1,%ebx
  8005ca:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d5:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005d9:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005e4:	00 
  8005e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f2:	e8 a9 0a 00 00       	call   8010a0 <__udivdi3>
  8005f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005fb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	89 54 24 04          	mov    %edx,0x4(%esp)
  800606:	89 fa                	mov    %edi,%edx
  800608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060b:	e8 78 ff ff ff       	call   800588 <printnum>
  800610:	eb 0f                	jmp    800621 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 34 24             	mov    %esi,(%esp)
  800619:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80061c:	83 eb 01             	sub    $0x1,%ebx
  80061f:	75 f1                	jne    800612 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800621:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800625:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800629:	8b 45 10             	mov    0x10(%ebp),%eax
  80062c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800630:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800637:	00 
  800638:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800641:	89 44 24 04          	mov    %eax,0x4(%esp)
  800645:	e8 86 0b 00 00       	call   8011d0 <__umoddi3>
  80064a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064e:	0f be 80 c8 13 80 00 	movsbl 0x8013c8(%eax),%eax
  800655:	89 04 24             	mov    %eax,(%esp)
  800658:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80065b:	83 c4 3c             	add    $0x3c,%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800666:	83 fa 01             	cmp    $0x1,%edx
  800669:	7e 0e                	jle    800679 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800670:	89 08                	mov    %ecx,(%eax)
  800672:	8b 02                	mov    (%edx),%eax
  800674:	8b 52 04             	mov    0x4(%edx),%edx
  800677:	eb 22                	jmp    80069b <getuint+0x38>
	else if (lflag)
  800679:	85 d2                	test   %edx,%edx
  80067b:	74 10                	je     80068d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800682:	89 08                	mov    %ecx,(%eax)
  800684:	8b 02                	mov    (%edx),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
  80068b:	eb 0e                	jmp    80069b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800692:	89 08                	mov    %ecx,(%eax)
  800694:	8b 02                	mov    (%edx),%eax
  800696:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8006ac:	73 0a                	jae    8006b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b1:	88 0a                	mov    %cl,(%edx)
  8006b3:	83 c2 01             	add    $0x1,%edx
  8006b6:	89 10                	mov    %edx,(%eax)
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	e8 02 00 00 00       	call   8006e2 <vprintfmt>
	va_end(ap);
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	57                   	push   %edi
  8006e6:	56                   	push   %esi
  8006e7:	53                   	push   %ebx
  8006e8:	83 ec 5c             	sub    $0x5c,%esp
  8006eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8006f1:	eb 12                	jmp    800705 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	0f 84 e4 04 00 00    	je     800bdf <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  8006fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800705:	0f b6 06             	movzbl (%esi),%eax
  800708:	83 c6 01             	add    $0x1,%esi
  80070b:	83 f8 25             	cmp    $0x25,%eax
  80070e:	75 e3                	jne    8006f3 <vprintfmt+0x11>
  800710:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800714:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80071b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800720:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800727:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80072f:	eb 2b                	jmp    80075c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800731:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800734:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800738:	eb 22                	jmp    80075c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80073d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800741:	eb 19                	jmp    80075c <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800746:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80074d:	eb 0d                	jmp    80075c <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80074f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800752:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800755:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075c:	0f b6 06             	movzbl (%esi),%eax
  80075f:	0f b6 d0             	movzbl %al,%edx
  800762:	8d 7e 01             	lea    0x1(%esi),%edi
  800765:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800768:	83 e8 23             	sub    $0x23,%eax
  80076b:	3c 55                	cmp    $0x55,%al
  80076d:	0f 87 46 04 00 00    	ja     800bb9 <vprintfmt+0x4d7>
  800773:	0f b6 c0             	movzbl %al,%eax
  800776:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077d:	83 ea 30             	sub    $0x30,%edx
  800780:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800783:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800787:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80078d:	83 fa 09             	cmp    $0x9,%edx
  800790:	77 4a                	ja     8007dc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800795:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800798:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80079b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80079f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007a2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007a5:	83 fa 09             	cmp    $0x9,%edx
  8007a8:	76 eb                	jbe    800795 <vprintfmt+0xb3>
  8007aa:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8007ad:	eb 2d                	jmp    8007dc <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007c0:	eb 1a                	jmp    8007dc <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8007c5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007c9:	79 91                	jns    80075c <vprintfmt+0x7a>
  8007cb:	e9 73 ff ff ff       	jmp    800743 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007d3:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  8007da:	eb 80                	jmp    80075c <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8007dc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007e0:	0f 89 76 ff ff ff    	jns    80075c <vprintfmt+0x7a>
  8007e6:	e9 64 ff ff ff       	jmp    80074f <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f1:	e9 66 ff ff ff       	jmp    80075c <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800803:	8b 00                	mov    (%eax),%eax
  800805:	89 04 24             	mov    %eax,(%esp)
  800808:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80080e:	e9 f2 fe ff ff       	jmp    800705 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800813:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  800817:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80081a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80081e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800821:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800825:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  800828:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80082b:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  80082f:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800832:	80 f9 09             	cmp    $0x9,%cl
  800835:	77 1d                	ja     800854 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  800837:	0f be c0             	movsbl %al,%eax
  80083a:	6b c0 64             	imul   $0x64,%eax,%eax
  80083d:	0f be d2             	movsbl %dl,%edx
  800840:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800843:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80084a:	a3 08 20 80 00       	mov    %eax,0x802008
  80084f:	e9 b1 fe ff ff       	jmp    800705 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800854:	c7 44 24 04 e0 13 80 	movl   $0x8013e0,0x4(%esp)
  80085b:	00 
  80085c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 14 05 00 00       	call   800d7b <strcmp>
  800867:	85 c0                	test   %eax,%eax
  800869:	75 0f                	jne    80087a <vprintfmt+0x198>
  80086b:	c7 05 08 20 80 00 04 	movl   $0x4,0x802008
  800872:	00 00 00 
  800875:	e9 8b fe ff ff       	jmp    800705 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  80087a:	c7 44 24 04 e4 13 80 	movl   $0x8013e4,0x4(%esp)
  800881:	00 
  800882:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800885:	89 14 24             	mov    %edx,(%esp)
  800888:	e8 ee 04 00 00       	call   800d7b <strcmp>
  80088d:	85 c0                	test   %eax,%eax
  80088f:	75 0f                	jne    8008a0 <vprintfmt+0x1be>
  800891:	c7 05 08 20 80 00 02 	movl   $0x2,0x802008
  800898:	00 00 00 
  80089b:	e9 65 fe ff ff       	jmp    800705 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8008a0:	c7 44 24 04 e8 13 80 	movl   $0x8013e8,0x4(%esp)
  8008a7:	00 
  8008a8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8008ab:	89 0c 24             	mov    %ecx,(%esp)
  8008ae:	e8 c8 04 00 00       	call   800d7b <strcmp>
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	75 0f                	jne    8008c6 <vprintfmt+0x1e4>
  8008b7:	c7 05 08 20 80 00 01 	movl   $0x1,0x802008
  8008be:	00 00 00 
  8008c1:	e9 3f fe ff ff       	jmp    800705 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8008c6:	c7 44 24 04 ec 13 80 	movl   $0x8013ec,0x4(%esp)
  8008cd:	00 
  8008ce:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8008d1:	89 3c 24             	mov    %edi,(%esp)
  8008d4:	e8 a2 04 00 00       	call   800d7b <strcmp>
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	75 0f                	jne    8008ec <vprintfmt+0x20a>
  8008dd:	c7 05 08 20 80 00 06 	movl   $0x6,0x802008
  8008e4:	00 00 00 
  8008e7:	e9 19 fe ff ff       	jmp    800705 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  8008ec:	c7 44 24 04 f0 13 80 	movl   $0x8013f0,0x4(%esp)
  8008f3:	00 
  8008f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008f7:	89 04 24             	mov    %eax,(%esp)
  8008fa:	e8 7c 04 00 00       	call   800d7b <strcmp>
  8008ff:	85 c0                	test   %eax,%eax
  800901:	75 0f                	jne    800912 <vprintfmt+0x230>
  800903:	c7 05 08 20 80 00 07 	movl   $0x7,0x802008
  80090a:	00 00 00 
  80090d:	e9 f3 fd ff ff       	jmp    800705 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800912:	c7 44 24 04 f4 13 80 	movl   $0x8013f4,0x4(%esp)
  800919:	00 
  80091a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80091d:	89 14 24             	mov    %edx,(%esp)
  800920:	e8 56 04 00 00       	call   800d7b <strcmp>
  800925:	83 f8 01             	cmp    $0x1,%eax
  800928:	19 c0                	sbb    %eax,%eax
  80092a:	f7 d0                	not    %eax
  80092c:	83 c0 08             	add    $0x8,%eax
  80092f:	a3 08 20 80 00       	mov    %eax,0x802008
  800934:	e9 cc fd ff ff       	jmp    800705 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800939:	8b 45 14             	mov    0x14(%ebp),%eax
  80093c:	8d 50 04             	lea    0x4(%eax),%edx
  80093f:	89 55 14             	mov    %edx,0x14(%ebp)
  800942:	8b 00                	mov    (%eax),%eax
  800944:	89 c2                	mov    %eax,%edx
  800946:	c1 fa 1f             	sar    $0x1f,%edx
  800949:	31 d0                	xor    %edx,%eax
  80094b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094d:	83 f8 08             	cmp    $0x8,%eax
  800950:	7f 0b                	jg     80095d <vprintfmt+0x27b>
  800952:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800959:	85 d2                	test   %edx,%edx
  80095b:	75 23                	jne    800980 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80095d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800961:	c7 44 24 08 f8 13 80 	movl   $0x8013f8,0x8(%esp)
  800968:	00 
  800969:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	89 3c 24             	mov    %edi,(%esp)
  800973:	e8 42 fd ff ff       	call   8006ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800978:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80097b:	e9 85 fd ff ff       	jmp    800705 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800980:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800984:	c7 44 24 08 01 14 80 	movl   $0x801401,0x8(%esp)
  80098b:	00 
  80098c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800990:	8b 7d 08             	mov    0x8(%ebp),%edi
  800993:	89 3c 24             	mov    %edi,(%esp)
  800996:	e8 1f fd ff ff       	call   8006ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80099e:	e9 62 fd ff ff       	jmp    800705 <vprintfmt+0x23>
  8009a3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8009a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8009af:	8d 50 04             	lea    0x4(%eax),%edx
  8009b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8009b7:	85 f6                	test   %esi,%esi
  8009b9:	b8 d9 13 80 00       	mov    $0x8013d9,%eax
  8009be:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009c1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8009c5:	7e 06                	jle    8009cd <vprintfmt+0x2eb>
  8009c7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8009cb:	75 13                	jne    8009e0 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009cd:	0f be 06             	movsbl (%esi),%eax
  8009d0:	83 c6 01             	add    $0x1,%esi
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	0f 85 94 00 00 00    	jne    800a6f <vprintfmt+0x38d>
  8009db:	e9 81 00 00 00       	jmp    800a61 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009e4:	89 34 24             	mov    %esi,(%esp)
  8009e7:	e8 9f 02 00 00       	call   800c8b <strnlen>
  8009ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009ef:	29 c2                	sub    %eax,%edx
  8009f1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8009f4:	85 d2                	test   %edx,%edx
  8009f6:	7e d5                	jle    8009cd <vprintfmt+0x2eb>
					putch(padc, putdat);
  8009f8:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8009fc:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  8009ff:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800a02:	89 d6                	mov    %edx,%esi
  800a04:	89 cf                	mov    %ecx,%edi
  800a06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0a:	89 3c 24             	mov    %edi,(%esp)
  800a0d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a10:	83 ee 01             	sub    $0x1,%esi
  800a13:	75 f1                	jne    800a06 <vprintfmt+0x324>
  800a15:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800a18:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800a1b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800a1e:	eb ad                	jmp    8009cd <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a20:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a24:	74 1b                	je     800a41 <vprintfmt+0x35f>
  800a26:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a29:	83 fa 5e             	cmp    $0x5e,%edx
  800a2c:	76 13                	jbe    800a41 <vprintfmt+0x35f>
					putch('?', putdat);
  800a2e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a35:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a3c:	ff 55 08             	call   *0x8(%ebp)
  800a3f:	eb 0d                	jmp    800a4e <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800a41:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a44:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a48:	89 04 24             	mov    %eax,(%esp)
  800a4b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4e:	83 eb 01             	sub    $0x1,%ebx
  800a51:	0f be 06             	movsbl (%esi),%eax
  800a54:	83 c6 01             	add    $0x1,%esi
  800a57:	85 c0                	test   %eax,%eax
  800a59:	75 1a                	jne    800a75 <vprintfmt+0x393>
  800a5b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a5e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a61:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a64:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a68:	7f 1c                	jg     800a86 <vprintfmt+0x3a4>
  800a6a:	e9 96 fc ff ff       	jmp    800705 <vprintfmt+0x23>
  800a6f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800a72:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a75:	85 ff                	test   %edi,%edi
  800a77:	78 a7                	js     800a20 <vprintfmt+0x33e>
  800a79:	83 ef 01             	sub    $0x1,%edi
  800a7c:	79 a2                	jns    800a20 <vprintfmt+0x33e>
  800a7e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800a81:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a84:	eb db                	jmp    800a61 <vprintfmt+0x37f>
  800a86:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a89:	89 de                	mov    %ebx,%esi
  800a8b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a92:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a99:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a9b:	83 eb 01             	sub    $0x1,%ebx
  800a9e:	75 ee                	jne    800a8e <vprintfmt+0x3ac>
  800aa0:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa2:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800aa5:	e9 5b fc ff ff       	jmp    800705 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aaa:	83 f9 01             	cmp    $0x1,%ecx
  800aad:	7e 10                	jle    800abf <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab2:	8d 50 08             	lea    0x8(%eax),%edx
  800ab5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab8:	8b 30                	mov    (%eax),%esi
  800aba:	8b 78 04             	mov    0x4(%eax),%edi
  800abd:	eb 26                	jmp    800ae5 <vprintfmt+0x403>
	else if (lflag)
  800abf:	85 c9                	test   %ecx,%ecx
  800ac1:	74 12                	je     800ad5 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800ac3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac6:	8d 50 04             	lea    0x4(%eax),%edx
  800ac9:	89 55 14             	mov    %edx,0x14(%ebp)
  800acc:	8b 30                	mov    (%eax),%esi
  800ace:	89 f7                	mov    %esi,%edi
  800ad0:	c1 ff 1f             	sar    $0x1f,%edi
  800ad3:	eb 10                	jmp    800ae5 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800ad5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad8:	8d 50 04             	lea    0x4(%eax),%edx
  800adb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ade:	8b 30                	mov    (%eax),%esi
  800ae0:	89 f7                	mov    %esi,%edi
  800ae2:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	78 0e                	js     800af7 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ae9:	89 f0                	mov    %esi,%eax
  800aeb:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800aed:	be 0a 00 00 00       	mov    $0xa,%esi
  800af2:	e9 84 00 00 00       	jmp    800b7b <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800af7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800afb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b02:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800b05:	89 f0                	mov    %esi,%eax
  800b07:	89 fa                	mov    %edi,%edx
  800b09:	f7 d8                	neg    %eax
  800b0b:	83 d2 00             	adc    $0x0,%edx
  800b0e:	f7 da                	neg    %edx
			}
			base = 10;
  800b10:	be 0a 00 00 00       	mov    $0xa,%esi
  800b15:	eb 64                	jmp    800b7b <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b17:	89 ca                	mov    %ecx,%edx
  800b19:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1c:	e8 42 fb ff ff       	call   800663 <getuint>
			base = 10;
  800b21:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800b26:	eb 53                	jmp    800b7b <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b28:	89 ca                	mov    %ecx,%edx
  800b2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2d:	e8 31 fb ff ff       	call   800663 <getuint>
    			base = 8;
  800b32:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800b37:	eb 42                	jmp    800b7b <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800b39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b3d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b44:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b4b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b52:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b55:	8b 45 14             	mov    0x14(%ebp),%eax
  800b58:	8d 50 04             	lea    0x4(%eax),%edx
  800b5b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b5e:	8b 00                	mov    (%eax),%eax
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b65:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800b6a:	eb 0f                	jmp    800b7b <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b6c:	89 ca                	mov    %ecx,%edx
  800b6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b71:	e8 ed fa ff ff       	call   800663 <getuint>
			base = 16;
  800b76:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b7b:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b7f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800b83:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800b86:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800b8a:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b8e:	89 04 24             	mov    %eax,(%esp)
  800b91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b95:	89 da                	mov    %ebx,%edx
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	e8 e9 f9 ff ff       	call   800588 <printnum>
			break;
  800b9f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800ba2:	e9 5e fb ff ff       	jmp    800705 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ba7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bab:	89 14 24             	mov    %edx,(%esp)
  800bae:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bb4:	e9 4c fb ff ff       	jmp    800705 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bb9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bbd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800bc4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bc7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bcb:	0f 84 34 fb ff ff    	je     800705 <vprintfmt+0x23>
  800bd1:	83 ee 01             	sub    $0x1,%esi
  800bd4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800bd8:	75 f7                	jne    800bd1 <vprintfmt+0x4ef>
  800bda:	e9 26 fb ff ff       	jmp    800705 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bdf:	83 c4 5c             	add    $0x5c,%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 28             	sub    $0x28,%esp
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bf6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bfa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bfd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	74 30                	je     800c38 <vsnprintf+0x51>
  800c08:	85 d2                	test   %edx,%edx
  800c0a:	7e 2c                	jle    800c38 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c13:	8b 45 10             	mov    0x10(%ebp),%eax
  800c16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c21:	c7 04 24 9d 06 80 00 	movl   $0x80069d,(%esp)
  800c28:	e8 b5 fa ff ff       	call   8006e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c30:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c36:	eb 05                	jmp    800c3d <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c45:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	89 04 24             	mov    %eax,(%esp)
  800c60:	e8 82 ff ff ff       	call   800be7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    
	...

00800c70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800c7e:	74 09                	je     800c89 <strlen+0x19>
		n++;
  800c80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c87:	75 f7                	jne    800c80 <strlen+0x10>
		n++;
	return n;
}
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	53                   	push   %ebx
  800c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9a:	85 c9                	test   %ecx,%ecx
  800c9c:	74 1a                	je     800cb8 <strnlen+0x2d>
  800c9e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ca1:	74 15                	je     800cb8 <strnlen+0x2d>
  800ca3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ca8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800caa:	39 ca                	cmp    %ecx,%edx
  800cac:	74 0a                	je     800cb8 <strnlen+0x2d>
  800cae:	83 c2 01             	add    $0x1,%edx
  800cb1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800cb6:	75 f0                	jne    800ca8 <strnlen+0x1d>
		n++;
	return n;
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	53                   	push   %ebx
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800cce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800cd1:	83 c2 01             	add    $0x1,%edx
  800cd4:	84 c9                	test   %cl,%cl
  800cd6:	75 f2                	jne    800cca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 08             	sub    $0x8,%esp
  800ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ce5:	89 1c 24             	mov    %ebx,(%esp)
  800ce8:	e8 83 ff ff ff       	call   800c70 <strlen>
	strcpy(dst + len, src);
  800ced:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cf4:	01 d8                	add    %ebx,%eax
  800cf6:	89 04 24             	mov    %eax,(%esp)
  800cf9:	e8 bd ff ff ff       	call   800cbb <strcpy>
	return dst;
}
  800cfe:	89 d8                	mov    %ebx,%eax
  800d00:	83 c4 08             	add    $0x8,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d14:	85 f6                	test   %esi,%esi
  800d16:	74 18                	je     800d30 <strncpy+0x2a>
  800d18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800d1d:	0f b6 1a             	movzbl (%edx),%ebx
  800d20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d23:	80 3a 01             	cmpb   $0x1,(%edx)
  800d26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d29:	83 c1 01             	add    $0x1,%ecx
  800d2c:	39 f1                	cmp    %esi,%ecx
  800d2e:	75 ed                	jne    800d1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d40:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d43:	89 f8                	mov    %edi,%eax
  800d45:	85 f6                	test   %esi,%esi
  800d47:	74 2b                	je     800d74 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800d49:	83 fe 01             	cmp    $0x1,%esi
  800d4c:	74 23                	je     800d71 <strlcpy+0x3d>
  800d4e:	0f b6 0b             	movzbl (%ebx),%ecx
  800d51:	84 c9                	test   %cl,%cl
  800d53:	74 1c                	je     800d71 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800d55:	83 ee 02             	sub    $0x2,%esi
  800d58:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d5d:	88 08                	mov    %cl,(%eax)
  800d5f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d62:	39 f2                	cmp    %esi,%edx
  800d64:	74 0b                	je     800d71 <strlcpy+0x3d>
  800d66:	83 c2 01             	add    $0x1,%edx
  800d69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d6d:	84 c9                	test   %cl,%cl
  800d6f:	75 ec                	jne    800d5d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800d71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d74:	29 f8                	sub    %edi,%eax
}
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d81:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d84:	0f b6 01             	movzbl (%ecx),%eax
  800d87:	84 c0                	test   %al,%al
  800d89:	74 16                	je     800da1 <strcmp+0x26>
  800d8b:	3a 02                	cmp    (%edx),%al
  800d8d:	75 12                	jne    800da1 <strcmp+0x26>
		p++, q++;
  800d8f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d92:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800d96:	84 c0                	test   %al,%al
  800d98:	74 07                	je     800da1 <strcmp+0x26>
  800d9a:	83 c1 01             	add    $0x1,%ecx
  800d9d:	3a 02                	cmp    (%edx),%al
  800d9f:	74 ee                	je     800d8f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800da1:	0f b6 c0             	movzbl %al,%eax
  800da4:	0f b6 12             	movzbl (%edx),%edx
  800da7:	29 d0                	sub    %edx,%eax
}
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	53                   	push   %ebx
  800daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800db5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800db8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dbd:	85 d2                	test   %edx,%edx
  800dbf:	74 28                	je     800de9 <strncmp+0x3e>
  800dc1:	0f b6 01             	movzbl (%ecx),%eax
  800dc4:	84 c0                	test   %al,%al
  800dc6:	74 24                	je     800dec <strncmp+0x41>
  800dc8:	3a 03                	cmp    (%ebx),%al
  800dca:	75 20                	jne    800dec <strncmp+0x41>
  800dcc:	83 ea 01             	sub    $0x1,%edx
  800dcf:	74 13                	je     800de4 <strncmp+0x39>
		n--, p++, q++;
  800dd1:	83 c1 01             	add    $0x1,%ecx
  800dd4:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dd7:	0f b6 01             	movzbl (%ecx),%eax
  800dda:	84 c0                	test   %al,%al
  800ddc:	74 0e                	je     800dec <strncmp+0x41>
  800dde:	3a 03                	cmp    (%ebx),%al
  800de0:	74 ea                	je     800dcc <strncmp+0x21>
  800de2:	eb 08                	jmp    800dec <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dec:	0f b6 01             	movzbl (%ecx),%eax
  800def:	0f b6 13             	movzbl (%ebx),%edx
  800df2:	29 d0                	sub    %edx,%eax
  800df4:	eb f3                	jmp    800de9 <strncmp+0x3e>

00800df6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e00:	0f b6 10             	movzbl (%eax),%edx
  800e03:	84 d2                	test   %dl,%dl
  800e05:	74 1c                	je     800e23 <strchr+0x2d>
		if (*s == c)
  800e07:	38 ca                	cmp    %cl,%dl
  800e09:	75 09                	jne    800e14 <strchr+0x1e>
  800e0b:	eb 1b                	jmp    800e28 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e0d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800e10:	38 ca                	cmp    %cl,%dl
  800e12:	74 14                	je     800e28 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e14:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800e18:	84 d2                	test   %dl,%dl
  800e1a:	75 f1                	jne    800e0d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	eb 05                	jmp    800e28 <strchr+0x32>
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e34:	0f b6 10             	movzbl (%eax),%edx
  800e37:	84 d2                	test   %dl,%dl
  800e39:	74 14                	je     800e4f <strfind+0x25>
		if (*s == c)
  800e3b:	38 ca                	cmp    %cl,%dl
  800e3d:	75 06                	jne    800e45 <strfind+0x1b>
  800e3f:	eb 0e                	jmp    800e4f <strfind+0x25>
  800e41:	38 ca                	cmp    %cl,%dl
  800e43:	74 0a                	je     800e4f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e45:	83 c0 01             	add    $0x1,%eax
  800e48:	0f b6 10             	movzbl (%eax),%edx
  800e4b:	84 d2                	test   %dl,%dl
  800e4d:	75 f2                	jne    800e41 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e69:	85 c9                	test   %ecx,%ecx
  800e6b:	74 30                	je     800e9d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e73:	75 25                	jne    800e9a <memset+0x49>
  800e75:	f6 c1 03             	test   $0x3,%cl
  800e78:	75 20                	jne    800e9a <memset+0x49>
		c &= 0xFF;
  800e7a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e7d:	89 d3                	mov    %edx,%ebx
  800e7f:	c1 e3 08             	shl    $0x8,%ebx
  800e82:	89 d6                	mov    %edx,%esi
  800e84:	c1 e6 18             	shl    $0x18,%esi
  800e87:	89 d0                	mov    %edx,%eax
  800e89:	c1 e0 10             	shl    $0x10,%eax
  800e8c:	09 f0                	or     %esi,%eax
  800e8e:	09 d0                	or     %edx,%eax
  800e90:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e92:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e95:	fc                   	cld    
  800e96:	f3 ab                	rep stos %eax,%es:(%edi)
  800e98:	eb 03                	jmp    800e9d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e9a:	fc                   	cld    
  800e9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e9d:	89 f8                	mov    %edi,%eax
  800e9f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea8:	89 ec                	mov    %ebp,%esp
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ec1:	39 c6                	cmp    %eax,%esi
  800ec3:	73 36                	jae    800efb <memmove+0x4f>
  800ec5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ec8:	39 d0                	cmp    %edx,%eax
  800eca:	73 2f                	jae    800efb <memmove+0x4f>
		s += n;
		d += n;
  800ecc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ecf:	f6 c2 03             	test   $0x3,%dl
  800ed2:	75 1b                	jne    800eef <memmove+0x43>
  800ed4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800eda:	75 13                	jne    800eef <memmove+0x43>
  800edc:	f6 c1 03             	test   $0x3,%cl
  800edf:	75 0e                	jne    800eef <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ee1:	83 ef 04             	sub    $0x4,%edi
  800ee4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ee7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eea:	fd                   	std    
  800eeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eed:	eb 09                	jmp    800ef8 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eef:	83 ef 01             	sub    $0x1,%edi
  800ef2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 20                	jmp    800f1b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800efb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f01:	75 13                	jne    800f16 <memmove+0x6a>
  800f03:	a8 03                	test   $0x3,%al
  800f05:	75 0f                	jne    800f16 <memmove+0x6a>
  800f07:	f6 c1 03             	test   $0x3,%cl
  800f0a:	75 0a                	jne    800f16 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f0c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f0f:	89 c7                	mov    %eax,%edi
  800f11:	fc                   	cld    
  800f12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f14:	eb 05                	jmp    800f1b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f16:	89 c7                	mov    %eax,%edi
  800f18:	fc                   	cld    
  800f19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f21:	89 ec                	mov    %ebp,%esp
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	89 04 24             	mov    %eax,(%esp)
  800f3f:	e8 68 ff ff ff       	call   800eac <memmove>
}
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f52:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f5a:	85 ff                	test   %edi,%edi
  800f5c:	74 37                	je     800f95 <memcmp+0x4f>
		if (*s1 != *s2)
  800f5e:	0f b6 03             	movzbl (%ebx),%eax
  800f61:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f64:	83 ef 01             	sub    $0x1,%edi
  800f67:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800f6c:	38 c8                	cmp    %cl,%al
  800f6e:	74 1c                	je     800f8c <memcmp+0x46>
  800f70:	eb 10                	jmp    800f82 <memcmp+0x3c>
  800f72:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800f77:	83 c2 01             	add    $0x1,%edx
  800f7a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800f7e:	38 c8                	cmp    %cl,%al
  800f80:	74 0a                	je     800f8c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800f82:	0f b6 c0             	movzbl %al,%eax
  800f85:	0f b6 c9             	movzbl %cl,%ecx
  800f88:	29 c8                	sub    %ecx,%eax
  800f8a:	eb 09                	jmp    800f95 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f8c:	39 fa                	cmp    %edi,%edx
  800f8e:	75 e2                	jne    800f72 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fa5:	39 d0                	cmp    %edx,%eax
  800fa7:	73 19                	jae    800fc2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fa9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800fad:	38 08                	cmp    %cl,(%eax)
  800faf:	75 06                	jne    800fb7 <memfind+0x1d>
  800fb1:	eb 0f                	jmp    800fc2 <memfind+0x28>
  800fb3:	38 08                	cmp    %cl,(%eax)
  800fb5:	74 0b                	je     800fc2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fb7:	83 c0 01             	add    $0x1,%eax
  800fba:	39 d0                	cmp    %edx,%eax
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	75 f1                	jne    800fb3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fd0:	0f b6 02             	movzbl (%edx),%eax
  800fd3:	3c 20                	cmp    $0x20,%al
  800fd5:	74 04                	je     800fdb <strtol+0x17>
  800fd7:	3c 09                	cmp    $0x9,%al
  800fd9:	75 0e                	jne    800fe9 <strtol+0x25>
		s++;
  800fdb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fde:	0f b6 02             	movzbl (%edx),%eax
  800fe1:	3c 20                	cmp    $0x20,%al
  800fe3:	74 f6                	je     800fdb <strtol+0x17>
  800fe5:	3c 09                	cmp    $0x9,%al
  800fe7:	74 f2                	je     800fdb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fe9:	3c 2b                	cmp    $0x2b,%al
  800feb:	75 0a                	jne    800ff7 <strtol+0x33>
		s++;
  800fed:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ff0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff5:	eb 10                	jmp    801007 <strtol+0x43>
  800ff7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ffc:	3c 2d                	cmp    $0x2d,%al
  800ffe:	75 07                	jne    801007 <strtol+0x43>
		s++, neg = 1;
  801000:	83 c2 01             	add    $0x1,%edx
  801003:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801007:	85 db                	test   %ebx,%ebx
  801009:	0f 94 c0             	sete   %al
  80100c:	74 05                	je     801013 <strtol+0x4f>
  80100e:	83 fb 10             	cmp    $0x10,%ebx
  801011:	75 15                	jne    801028 <strtol+0x64>
  801013:	80 3a 30             	cmpb   $0x30,(%edx)
  801016:	75 10                	jne    801028 <strtol+0x64>
  801018:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80101c:	75 0a                	jne    801028 <strtol+0x64>
		s += 2, base = 16;
  80101e:	83 c2 02             	add    $0x2,%edx
  801021:	bb 10 00 00 00       	mov    $0x10,%ebx
  801026:	eb 13                	jmp    80103b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801028:	84 c0                	test   %al,%al
  80102a:	74 0f                	je     80103b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80102c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801031:	80 3a 30             	cmpb   $0x30,(%edx)
  801034:	75 05                	jne    80103b <strtol+0x77>
		s++, base = 8;
  801036:	83 c2 01             	add    $0x1,%edx
  801039:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  80103b:	b8 00 00 00 00       	mov    $0x0,%eax
  801040:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801042:	0f b6 0a             	movzbl (%edx),%ecx
  801045:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801048:	80 fb 09             	cmp    $0x9,%bl
  80104b:	77 08                	ja     801055 <strtol+0x91>
			dig = *s - '0';
  80104d:	0f be c9             	movsbl %cl,%ecx
  801050:	83 e9 30             	sub    $0x30,%ecx
  801053:	eb 1e                	jmp    801073 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801055:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801058:	80 fb 19             	cmp    $0x19,%bl
  80105b:	77 08                	ja     801065 <strtol+0xa1>
			dig = *s - 'a' + 10;
  80105d:	0f be c9             	movsbl %cl,%ecx
  801060:	83 e9 57             	sub    $0x57,%ecx
  801063:	eb 0e                	jmp    801073 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801065:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801068:	80 fb 19             	cmp    $0x19,%bl
  80106b:	77 14                	ja     801081 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80106d:	0f be c9             	movsbl %cl,%ecx
  801070:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801073:	39 f1                	cmp    %esi,%ecx
  801075:	7d 0e                	jge    801085 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801077:	83 c2 01             	add    $0x1,%edx
  80107a:	0f af c6             	imul   %esi,%eax
  80107d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80107f:	eb c1                	jmp    801042 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801081:	89 c1                	mov    %eax,%ecx
  801083:	eb 02                	jmp    801087 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801085:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801087:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80108b:	74 05                	je     801092 <strtol+0xce>
		*endptr = (char *) s;
  80108d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801090:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801092:	89 ca                	mov    %ecx,%edx
  801094:	f7 da                	neg    %edx
  801096:	85 ff                	test   %edi,%edi
  801098:	0f 45 c2             	cmovne %edx,%eax
}
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <__udivdi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ff                	test   %edi,%edi
  8010bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cd                	mov    %ecx,%ebp
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	75 33                	jne    801100 <__udivdi3+0x60>
  8010cd:	39 f1                	cmp    %esi,%ecx
  8010cf:	77 57                	ja     801128 <__udivdi3+0x88>
  8010d1:	85 c9                	test   %ecx,%ecx
  8010d3:	75 0b                	jne    8010e0 <__udivdi3+0x40>
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	31 d2                	xor    %edx,%edx
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 c1                	mov    %eax,%ecx
  8010e0:	89 f0                	mov    %esi,%eax
  8010e2:	31 d2                	xor    %edx,%edx
  8010e4:	f7 f1                	div    %ecx
  8010e6:	89 c6                	mov    %eax,%esi
  8010e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 f2                	mov    %esi,%edx
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	31 d2                	xor    %edx,%edx
  801102:	31 c0                	xor    %eax,%eax
  801104:	39 f7                	cmp    %esi,%edi
  801106:	77 e8                	ja     8010f0 <__udivdi3+0x50>
  801108:	0f bd cf             	bsr    %edi,%ecx
  80110b:	83 f1 1f             	xor    $0x1f,%ecx
  80110e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801112:	75 2c                	jne    801140 <__udivdi3+0xa0>
  801114:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801118:	76 04                	jbe    80111e <__udivdi3+0x7e>
  80111a:	39 f7                	cmp    %esi,%edi
  80111c:	73 d2                	jae    8010f0 <__udivdi3+0x50>
  80111e:	31 d2                	xor    %edx,%edx
  801120:	b8 01 00 00 00       	mov    $0x1,%eax
  801125:	eb c9                	jmp    8010f0 <__udivdi3+0x50>
  801127:	90                   	nop
  801128:	89 f2                	mov    %esi,%edx
  80112a:	f7 f1                	div    %ecx
  80112c:	31 d2                	xor    %edx,%edx
  80112e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801132:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801136:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80113a:	83 c4 1c             	add    $0x1c,%esp
  80113d:	c3                   	ret    
  80113e:	66 90                	xchg   %ax,%ax
  801140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801145:	b8 20 00 00 00       	mov    $0x20,%eax
  80114a:	89 ea                	mov    %ebp,%edx
  80114c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801150:	d3 e7                	shl    %cl,%edi
  801152:	89 c1                	mov    %eax,%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115b:	09 fa                	or     %edi,%edx
  80115d:	89 f7                	mov    %esi,%edi
  80115f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801163:	89 f2                	mov    %esi,%edx
  801165:	8b 74 24 08          	mov    0x8(%esp),%esi
  801169:	d3 e5                	shl    %cl,%ebp
  80116b:	89 c1                	mov    %eax,%ecx
  80116d:	d3 ef                	shr    %cl,%edi
  80116f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801174:	d3 e2                	shl    %cl,%edx
  801176:	89 c1                	mov    %eax,%ecx
  801178:	d3 ee                	shr    %cl,%esi
  80117a:	09 d6                	or     %edx,%esi
  80117c:	89 fa                	mov    %edi,%edx
  80117e:	89 f0                	mov    %esi,%eax
  801180:	f7 74 24 0c          	divl   0xc(%esp)
  801184:	89 d7                	mov    %edx,%edi
  801186:	89 c6                	mov    %eax,%esi
  801188:	f7 e5                	mul    %ebp
  80118a:	39 d7                	cmp    %edx,%edi
  80118c:	72 22                	jb     8011b0 <__udivdi3+0x110>
  80118e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801192:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801197:	d3 e5                	shl    %cl,%ebp
  801199:	39 c5                	cmp    %eax,%ebp
  80119b:	73 04                	jae    8011a1 <__udivdi3+0x101>
  80119d:	39 d7                	cmp    %edx,%edi
  80119f:	74 0f                	je     8011b0 <__udivdi3+0x110>
  8011a1:	89 f0                	mov    %esi,%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	e9 46 ff ff ff       	jmp    8010f0 <__udivdi3+0x50>
  8011aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c1:	83 c4 1c             	add    $0x1c,%esp
  8011c4:	c3                   	ret    
	...

008011d0 <__umoddi3>:
  8011d0:	83 ec 1c             	sub    $0x1c,%esp
  8011d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011eb:	85 ed                	test   %ebp,%ebp
  8011ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f5:	89 cf                	mov    %ecx,%edi
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	89 f2                	mov    %esi,%edx
  8011fc:	75 1a                	jne    801218 <__umoddi3+0x48>
  8011fe:	39 f1                	cmp    %esi,%ecx
  801200:	76 4e                	jbe    801250 <__umoddi3+0x80>
  801202:	f7 f1                	div    %ecx
  801204:	89 d0                	mov    %edx,%eax
  801206:	31 d2                	xor    %edx,%edx
  801208:	8b 74 24 10          	mov    0x10(%esp),%esi
  80120c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801210:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801214:	83 c4 1c             	add    $0x1c,%esp
  801217:	c3                   	ret    
  801218:	39 f5                	cmp    %esi,%ebp
  80121a:	77 54                	ja     801270 <__umoddi3+0xa0>
  80121c:	0f bd c5             	bsr    %ebp,%eax
  80121f:	83 f0 1f             	xor    $0x1f,%eax
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	75 60                	jne    801288 <__umoddi3+0xb8>
  801228:	3b 0c 24             	cmp    (%esp),%ecx
  80122b:	0f 87 07 01 00 00    	ja     801338 <__umoddi3+0x168>
  801231:	89 f2                	mov    %esi,%edx
  801233:	8b 34 24             	mov    (%esp),%esi
  801236:	29 ce                	sub    %ecx,%esi
  801238:	19 ea                	sbb    %ebp,%edx
  80123a:	89 34 24             	mov    %esi,(%esp)
  80123d:	8b 04 24             	mov    (%esp),%eax
  801240:	8b 74 24 10          	mov    0x10(%esp),%esi
  801244:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801248:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124c:	83 c4 1c             	add    $0x1c,%esp
  80124f:	c3                   	ret    
  801250:	85 c9                	test   %ecx,%ecx
  801252:	75 0b                	jne    80125f <__umoddi3+0x8f>
  801254:	b8 01 00 00 00       	mov    $0x1,%eax
  801259:	31 d2                	xor    %edx,%edx
  80125b:	f7 f1                	div    %ecx
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 f0                	mov    %esi,%eax
  801261:	31 d2                	xor    %edx,%edx
  801263:	f7 f1                	div    %ecx
  801265:	8b 04 24             	mov    (%esp),%eax
  801268:	f7 f1                	div    %ecx
  80126a:	eb 98                	jmp    801204 <__umoddi3+0x34>
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 f2                	mov    %esi,%edx
  801272:	8b 74 24 10          	mov    0x10(%esp),%esi
  801276:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80127a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80127e:	83 c4 1c             	add    $0x1c,%esp
  801281:	c3                   	ret    
  801282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801288:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128d:	89 e8                	mov    %ebp,%eax
  80128f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801294:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801298:	89 fa                	mov    %edi,%edx
  80129a:	d3 e0                	shl    %cl,%eax
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 ea                	shr    %cl,%edx
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	09 c2                	or     %eax,%edx
  8012a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ab:	89 14 24             	mov    %edx,(%esp)
  8012ae:	89 f2                	mov    %esi,%edx
  8012b0:	d3 e7                	shl    %cl,%edi
  8012b2:	89 e9                	mov    %ebp,%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	d3 e6                	shl    %cl,%esi
  8012c1:	89 e9                	mov    %ebp,%ecx
  8012c3:	d3 e8                	shr    %cl,%eax
  8012c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ca:	09 f0                	or     %esi,%eax
  8012cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012d0:	f7 34 24             	divl   (%esp)
  8012d3:	d3 e6                	shl    %cl,%esi
  8012d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012d9:	89 d6                	mov    %edx,%esi
  8012db:	f7 e7                	mul    %edi
  8012dd:	39 d6                	cmp    %edx,%esi
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	89 d7                	mov    %edx,%edi
  8012e3:	72 3f                	jb     801324 <__umoddi3+0x154>
  8012e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012e9:	72 35                	jb     801320 <__umoddi3+0x150>
  8012eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ef:	29 c8                	sub    %ecx,%eax
  8012f1:	19 fe                	sbb    %edi,%esi
  8012f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f8:	89 f2                	mov    %esi,%edx
  8012fa:	d3 e8                	shr    %cl,%eax
  8012fc:	89 e9                	mov    %ebp,%ecx
  8012fe:	d3 e2                	shl    %cl,%edx
  801300:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801305:	09 d0                	or     %edx,%eax
  801307:	89 f2                	mov    %esi,%edx
  801309:	d3 ea                	shr    %cl,%edx
  80130b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80130f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801313:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801317:	83 c4 1c             	add    $0x1c,%esp
  80131a:	c3                   	ret    
  80131b:	90                   	nop
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	39 d6                	cmp    %edx,%esi
  801322:	75 c7                	jne    8012eb <__umoddi3+0x11b>
  801324:	89 d7                	mov    %edx,%edi
  801326:	89 c1                	mov    %eax,%ecx
  801328:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80132c:	1b 3c 24             	sbb    (%esp),%edi
  80132f:	eb ba                	jmp    8012eb <__umoddi3+0x11b>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 f5                	cmp    %esi,%ebp
  80133a:	0f 82 f1 fe ff ff    	jb     801231 <__umoddi3+0x61>
  801340:	e9 f8 fe ff ff       	jmp    80123d <__umoddi3+0x6d>
