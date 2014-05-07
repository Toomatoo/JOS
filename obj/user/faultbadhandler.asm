
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 aa 01 00 00       	call   800200 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 6d 03 00 00       	call   8003d7 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008a:	e8 11 01 00 00       	call   8001a0 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	c1 e0 07             	shl    $0x7,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ce:	e8 4b 06 00 00       	call   80071e <close_all>
	sys_env_destroy(0);
  8000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000da:	e8 64 00 00 00       	call   800143 <sys_env_destroy>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	89 c3                	mov    %eax,%ebx
  800100:	89 c7                	mov    %eax,%edi
  800102:	89 c6                	mov    %eax,%esi
  800104:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800106:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800109:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80010c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_cgetc>:

int
sys_cgetc(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80011c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 01 00 00 00       	mov    $0x1,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800136:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800139:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80013c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80013f:	89 ec                	mov    %ebp,%esp
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 38             	sub    $0x38,%esp
  800149:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80014c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80014f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	b9 00 00 00 00       	mov    $0x0,%ecx
  800157:	b8 03 00 00 00       	mov    $0x3,%eax
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	89 cb                	mov    %ecx,%ebx
  800161:	89 cf                	mov    %ecx,%edi
  800163:	89 ce                	mov    %ecx,%esi
  800165:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800167:	85 c0                	test   %eax,%eax
  800169:	7e 28                	jle    800193 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80016f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800176:	00 
  800177:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  80018e:	e8 5d 11 00 00       	call   8012f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800193:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800196:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800199:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019c:	89 ec                	mov    %ebp,%esp
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  8001b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b9:	89 d1                	mov    %edx,%ecx
  8001bb:	89 d3                	mov    %edx,%ebx
  8001bd:	89 d7                	mov    %edx,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001cc:	89 ec                	mov    %ebp,%esp
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_yield>:

void
sys_yield(void)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001df:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001e9:	89 d1                	mov    %edx,%ecx
  8001eb:	89 d3                	mov    %edx,%ebx
  8001ed:	89 d7                	mov    %edx,%edi
  8001ef:	89 d6                	mov    %edx,%esi
  8001f1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001f6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001f9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001fc:	89 ec                	mov    %ebp,%esp
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    

00800200 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 38             	sub    $0x38,%esp
  800206:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800209:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80020c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	be 00 00 00 00       	mov    $0x0,%esi
  800214:	b8 04 00 00 00       	mov    $0x4,%eax
  800219:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80021c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	89 f7                	mov    %esi,%edi
  800224:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	7e 28                	jle    800252 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80022e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800235:	00 
  800236:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  80023d:	00 
  80023e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800245:	00 
  800246:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  80024d:	e8 9e 10 00 00       	call   8012f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800252:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800255:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800258:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80025b:	89 ec                	mov    %ebp,%esp
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 38             	sub    $0x38,%esp
  800265:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800268:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80026b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	b8 05 00 00 00       	mov    $0x5,%eax
  800273:	8b 75 18             	mov    0x18(%ebp),%esi
  800276:	8b 7d 14             	mov    0x14(%ebp),%edi
  800279:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 28                	jle    8002b0 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800293:	00 
  800294:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  80029b:	00 
  80029c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a3:	00 
  8002a4:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  8002ab:	e8 40 10 00 00       	call   8012f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b9:	89 ec                	mov    %ebp,%esp
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 38             	sub    $0x38,%esp
  8002c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8002d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dc:	89 df                	mov    %ebx,%edi
  8002de:	89 de                	mov    %ebx,%esi
  8002e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 28                	jle    80030e <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ea:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800301:	00 
  800302:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  800309:	e8 e2 0f 00 00       	call   8012f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80030e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800311:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800314:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800317:	89 ec                	mov    %ebp,%esp
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 38             	sub    $0x38,%esp
  800321:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800324:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800327:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032f:	b8 08 00 00 00       	mov    $0x8,%eax
  800334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 df                	mov    %ebx,%edi
  80033c:	89 de                	mov    %ebx,%esi
  80033e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 28                	jle    80036c <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	89 44 24 10          	mov    %eax,0x10(%esp)
  800348:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80034f:	00 
  800350:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  800357:	00 
  800358:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035f:	00 
  800360:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  800367:	e8 84 0f 00 00       	call   8012f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80036c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80036f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800372:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800375:	89 ec                	mov    %ebp,%esp
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 38             	sub    $0x38,%esp
  80037f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800382:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800385:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800388:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038d:	b8 09 00 00 00       	mov    $0x9,%eax
  800392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	89 df                	mov    %ebx,%edi
  80039a:	89 de                	mov    %ebx,%esi
  80039c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	7e 28                	jle    8003ca <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003ad:	00 
  8003ae:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  8003b5:	00 
  8003b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003bd:	00 
  8003be:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  8003c5:	e8 26 0f 00 00       	call   8012f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003d3:	89 ec                	mov    %ebp,%esp
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  8003e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f6:	89 df                	mov    %ebx,%edi
  8003f8:	89 de                	mov    %ebx,%esi
  8003fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	7e 28                	jle    800428 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800400:	89 44 24 10          	mov    %eax,0x10(%esp)
  800404:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80040b:	00 
  80040c:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  800413:	00 
  800414:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041b:	00 
  80041c:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  800423:	e8 c8 0e 00 00       	call   8012f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800428:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800431:	89 ec                	mov    %ebp,%esp
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	83 ec 0c             	sub    $0xc,%esp
  80043b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80043e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800441:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800444:	be 00 00 00 00       	mov    $0x0,%esi
  800449:	b8 0c 00 00 00       	mov    $0xc,%eax
  80044e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800451:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800454:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800457:	8b 55 08             	mov    0x8(%ebp),%edx
  80045a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80045c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80045f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800462:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800465:	89 ec                	mov    %ebp,%esp
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	83 ec 38             	sub    $0x38,%esp
  80046f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800472:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800475:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800478:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800482:	8b 55 08             	mov    0x8(%ebp),%edx
  800485:	89 cb                	mov    %ecx,%ebx
  800487:	89 cf                	mov    %ecx,%edi
  800489:	89 ce                	mov    %ecx,%esi
  80048b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80048d:	85 c0                	test   %eax,%eax
  80048f:	7e 28                	jle    8004b9 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800491:	89 44 24 10          	mov    %eax,0x10(%esp)
  800495:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80049c:	00 
  80049d:	c7 44 24 08 4a 23 80 	movl   $0x80234a,0x8(%esp)
  8004a4:	00 
  8004a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004ac:	00 
  8004ad:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  8004b4:	e8 37 0e 00 00       	call   8012f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8004b9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004bc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004bf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004c2:	89 ec                	mov    %ebp,%esp
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8004cf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8004d2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004da:	b8 0e 00 00 00       	mov    $0xe,%eax
  8004df:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e2:	89 cb                	mov    %ecx,%ebx
  8004e4:	89 cf                	mov    %ecx,%edi
  8004e6:	89 ce                	mov    %ecx,%esi
  8004e8:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  8004ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004f3:	89 ec                	mov    %ebp,%esp
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    
	...

00800500 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	05 00 00 00 30       	add    $0x30000000,%eax
  80050b:	c1 e8 0c             	shr    $0xc,%eax
}
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 df ff ff ff       	call   800500 <fd2num>
  800521:	05 20 00 0d 00       	add    $0xd0020,%eax
  800526:	c1 e0 0c             	shl    $0xc,%eax
}
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	53                   	push   %ebx
  80052f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800532:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800537:	a8 01                	test   $0x1,%al
  800539:	74 34                	je     80056f <fd_alloc+0x44>
  80053b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800540:	a8 01                	test   $0x1,%al
  800542:	74 32                	je     800576 <fd_alloc+0x4b>
  800544:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800549:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80054b:	89 c2                	mov    %eax,%edx
  80054d:	c1 ea 16             	shr    $0x16,%edx
  800550:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800557:	f6 c2 01             	test   $0x1,%dl
  80055a:	74 1f                	je     80057b <fd_alloc+0x50>
  80055c:	89 c2                	mov    %eax,%edx
  80055e:	c1 ea 0c             	shr    $0xc,%edx
  800561:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800568:	f6 c2 01             	test   $0x1,%dl
  80056b:	75 17                	jne    800584 <fd_alloc+0x59>
  80056d:	eb 0c                	jmp    80057b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80056f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800574:	eb 05                	jmp    80057b <fd_alloc+0x50>
  800576:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80057b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80057d:	b8 00 00 00 00       	mov    $0x0,%eax
  800582:	eb 17                	jmp    80059b <fd_alloc+0x70>
  800584:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800589:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80058e:	75 b9                	jne    800549 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800590:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800596:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80059b:	5b                   	pop    %ebx
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8005a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005a9:	83 fa 1f             	cmp    $0x1f,%edx
  8005ac:	77 3f                	ja     8005ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005ae:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8005b4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8005b7:	89 d0                	mov    %edx,%eax
  8005b9:	c1 e8 16             	shr    $0x16,%eax
  8005bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8005c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8005c8:	f6 c1 01             	test   $0x1,%cl
  8005cb:	74 20                	je     8005ed <fd_lookup+0x4f>
  8005cd:	89 d0                	mov    %edx,%eax
  8005cf:	c1 e8 0c             	shr    $0xc,%eax
  8005d2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8005d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8005de:	f6 c1 01             	test   $0x1,%cl
  8005e1:	74 0a                	je     8005ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8005e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    

008005ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	53                   	push   %ebx
  8005f3:	83 ec 14             	sub    $0x14,%esp
  8005f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8005fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  800601:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800607:	75 17                	jne    800620 <dev_lookup+0x31>
  800609:	eb 07                	jmp    800612 <dev_lookup+0x23>
  80060b:	39 0a                	cmp    %ecx,(%edx)
  80060d:	75 11                	jne    800620 <dev_lookup+0x31>
  80060f:	90                   	nop
  800610:	eb 05                	jmp    800617 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800612:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800617:	89 13                	mov    %edx,(%ebx)
			return 0;
  800619:	b8 00 00 00 00       	mov    $0x0,%eax
  80061e:	eb 35                	jmp    800655 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800620:	83 c0 01             	add    $0x1,%eax
  800623:	8b 14 85 f4 23 80 00 	mov    0x8023f4(,%eax,4),%edx
  80062a:	85 d2                	test   %edx,%edx
  80062c:	75 dd                	jne    80060b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80062e:	a1 04 40 80 00       	mov    0x804004,%eax
  800633:	8b 40 48             	mov    0x48(%eax),%eax
  800636:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80063a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063e:	c7 04 24 78 23 80 00 	movl   $0x802378,(%esp)
  800645:	e8 a1 0d 00 00       	call   8013eb <cprintf>
	*dev = 0;
  80064a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800650:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800655:	83 c4 14             	add    $0x14,%esp
  800658:	5b                   	pop    %ebx
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	83 ec 38             	sub    $0x38,%esp
  800661:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800664:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800667:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80066a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800671:	89 3c 24             	mov    %edi,(%esp)
  800674:	e8 87 fe ff ff       	call   800500 <fd2num>
  800679:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80067c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	e8 16 ff ff ff       	call   80059e <fd_lookup>
  800688:	89 c3                	mov    %eax,%ebx
  80068a:	85 c0                	test   %eax,%eax
  80068c:	78 05                	js     800693 <fd_close+0x38>
	    || fd != fd2)
  80068e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800691:	74 0e                	je     8006a1 <fd_close+0x46>
		return (must_exist ? r : 0);
  800693:	89 f0                	mov    %esi,%eax
  800695:	84 c0                	test   %al,%al
  800697:	b8 00 00 00 00       	mov    $0x0,%eax
  80069c:	0f 44 d8             	cmove  %eax,%ebx
  80069f:	eb 3d                	jmp    8006de <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8006a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	8b 07                	mov    (%edi),%eax
  8006aa:	89 04 24             	mov    %eax,(%esp)
  8006ad:	e8 3d ff ff ff       	call   8005ef <dev_lookup>
  8006b2:	89 c3                	mov    %eax,%ebx
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 16                	js     8006ce <fd_close+0x73>
		if (dev->dev_close)
  8006b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8006be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	74 07                	je     8006ce <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8006c7:	89 3c 24             	mov    %edi,(%esp)
  8006ca:	ff d0                	call   *%eax
  8006cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8006ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d9:	e8 df fb ff ff       	call   8002bd <sys_page_unmap>
	return r;
}
  8006de:	89 d8                	mov    %ebx,%eax
  8006e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8006e3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8006e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8006e9:	89 ec                	mov    %ebp,%esp
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8006f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	89 04 24             	mov    %eax,(%esp)
  800700:	e8 99 fe ff ff       	call   80059e <fd_lookup>
  800705:	85 c0                	test   %eax,%eax
  800707:	78 13                	js     80071c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800709:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800710:	00 
  800711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	e8 3f ff ff ff       	call   80065b <fd_close>
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <close_all>:

void
close_all(void)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	53                   	push   %ebx
  800722:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800725:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80072a:	89 1c 24             	mov    %ebx,(%esp)
  80072d:	e8 bb ff ff ff       	call   8006ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800732:	83 c3 01             	add    $0x1,%ebx
  800735:	83 fb 20             	cmp    $0x20,%ebx
  800738:	75 f0                	jne    80072a <close_all+0xc>
		close(i);
}
  80073a:	83 c4 14             	add    $0x14,%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 58             	sub    $0x58,%esp
  800746:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800749:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80074c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80074f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800752:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	e8 3a fe ff ff       	call   80059e <fd_lookup>
  800764:	89 c3                	mov    %eax,%ebx
  800766:	85 c0                	test   %eax,%eax
  800768:	0f 88 e1 00 00 00    	js     80084f <dup+0x10f>
		return r;
	close(newfdnum);
  80076e:	89 3c 24             	mov    %edi,(%esp)
  800771:	e8 77 ff ff ff       	call   8006ed <close>

	newfd = INDEX2FD(newfdnum);
  800776:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80077c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800782:	89 04 24             	mov    %eax,(%esp)
  800785:	e8 86 fd ff ff       	call   800510 <fd2data>
  80078a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80078c:	89 34 24             	mov    %esi,(%esp)
  80078f:	e8 7c fd ff ff       	call   800510 <fd2data>
  800794:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800797:	89 d8                	mov    %ebx,%eax
  800799:	c1 e8 16             	shr    $0x16,%eax
  80079c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8007a3:	a8 01                	test   $0x1,%al
  8007a5:	74 46                	je     8007ed <dup+0xad>
  8007a7:	89 d8                	mov    %ebx,%eax
  8007a9:	c1 e8 0c             	shr    $0xc,%eax
  8007ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8007b3:	f6 c2 01             	test   $0x1,%dl
  8007b6:	74 35                	je     8007ed <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8007b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8007c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8007d6:	00 
  8007d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e2:	e8 78 fa ff ff       	call   80025f <sys_page_map>
  8007e7:	89 c3                	mov    %eax,%ebx
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 3b                	js     800828 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8007ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007f0:	89 c2                	mov    %eax,%edx
  8007f2:	c1 ea 0c             	shr    $0xc,%edx
  8007f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800802:	89 54 24 10          	mov    %edx,0x10(%esp)
  800806:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80080a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800811:	00 
  800812:	89 44 24 04          	mov    %eax,0x4(%esp)
  800816:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80081d:	e8 3d fa ff ff       	call   80025f <sys_page_map>
  800822:	89 c3                	mov    %eax,%ebx
  800824:	85 c0                	test   %eax,%eax
  800826:	79 25                	jns    80084d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800828:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800833:	e8 85 fa ff ff       	call   8002bd <sys_page_unmap>
	sys_page_unmap(0, nva);
  800838:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80083b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800846:	e8 72 fa ff ff       	call   8002bd <sys_page_unmap>
	return r;
  80084b:	eb 02                	jmp    80084f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80084d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800854:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800857:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80085a:	89 ec                	mov    %ebp,%esp
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 24             	sub    $0x24,%esp
  800865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	89 1c 24             	mov    %ebx,(%esp)
  800872:	e8 27 fd ff ff       	call   80059e <fd_lookup>
  800877:	85 c0                	test   %eax,%eax
  800879:	78 6d                	js     8008e8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800882:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800885:	8b 00                	mov    (%eax),%eax
  800887:	89 04 24             	mov    %eax,(%esp)
  80088a:	e8 60 fd ff ff       	call   8005ef <dev_lookup>
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 55                	js     8008e8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800893:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800896:	8b 50 08             	mov    0x8(%eax),%edx
  800899:	83 e2 03             	and    $0x3,%edx
  80089c:	83 fa 01             	cmp    $0x1,%edx
  80089f:	75 23                	jne    8008c4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8008a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8008a6:	8b 40 48             	mov    0x48(%eax),%eax
  8008a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	c7 04 24 b9 23 80 00 	movl   $0x8023b9,(%esp)
  8008b8:	e8 2e 0b 00 00       	call   8013eb <cprintf>
		return -E_INVAL;
  8008bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c2:	eb 24                	jmp    8008e8 <read+0x8a>
	}
	if (!dev->dev_read)
  8008c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c7:	8b 52 08             	mov    0x8(%edx),%edx
  8008ca:	85 d2                	test   %edx,%edx
  8008cc:	74 15                	je     8008e3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	ff d2                	call   *%edx
  8008e1:	eb 05                	jmp    8008e8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8008e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  8008e8:	83 c4 24             	add    $0x24,%esp
  8008eb:	5b                   	pop    %ebx
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 1c             	sub    $0x1c,%esp
  8008f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800902:	85 f6                	test   %esi,%esi
  800904:	74 30                	je     800936 <readn+0x48>
  800906:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80090b:	89 f2                	mov    %esi,%edx
  80090d:	29 c2                	sub    %eax,%edx
  80090f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800913:	03 45 0c             	add    0xc(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	89 3c 24             	mov    %edi,(%esp)
  80091d:	e8 3c ff ff ff       	call   80085e <read>
		if (m < 0)
  800922:	85 c0                	test   %eax,%eax
  800924:	78 10                	js     800936 <readn+0x48>
			return m;
		if (m == 0)
  800926:	85 c0                	test   %eax,%eax
  800928:	74 0a                	je     800934 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80092a:	01 c3                	add    %eax,%ebx
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	39 f3                	cmp    %esi,%ebx
  800930:	72 d9                	jb     80090b <readn+0x1d>
  800932:	eb 02                	jmp    800936 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800934:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800936:	83 c4 1c             	add    $0x1c,%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	83 ec 24             	sub    $0x24,%esp
  800945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800948:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	89 1c 24             	mov    %ebx,(%esp)
  800952:	e8 47 fc ff ff       	call   80059e <fd_lookup>
  800957:	85 c0                	test   %eax,%eax
  800959:	78 68                	js     8009c3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80095b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800965:	8b 00                	mov    (%eax),%eax
  800967:	89 04 24             	mov    %eax,(%esp)
  80096a:	e8 80 fc ff ff       	call   8005ef <dev_lookup>
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 50                	js     8009c3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800973:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800976:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80097a:	75 23                	jne    80099f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80097c:	a1 04 40 80 00       	mov    0x804004,%eax
  800981:	8b 40 48             	mov    0x48(%eax),%eax
  800984:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098c:	c7 04 24 d5 23 80 00 	movl   $0x8023d5,(%esp)
  800993:	e8 53 0a 00 00       	call   8013eb <cprintf>
		return -E_INVAL;
  800998:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099d:	eb 24                	jmp    8009c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80099f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	74 15                	je     8009be <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009b7:	89 04 24             	mov    %eax,(%esp)
  8009ba:	ff d2                	call   *%edx
  8009bc:	eb 05                	jmp    8009c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8009be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8009c3:	83 c4 24             	add    $0x24,%esp
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8009d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	89 04 24             	mov    %eax,(%esp)
  8009dc:	e8 bd fb ff ff       	call   80059e <fd_lookup>
  8009e1:	85 c0                	test   %eax,%eax
  8009e3:	78 0e                	js     8009f3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8009e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	53                   	push   %ebx
  8009f9:	83 ec 24             	sub    $0x24,%esp
  8009fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	89 1c 24             	mov    %ebx,(%esp)
  800a09:	e8 90 fb ff ff       	call   80059e <fd_lookup>
  800a0e:	85 c0                	test   %eax,%eax
  800a10:	78 61                	js     800a73 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a1c:	8b 00                	mov    (%eax),%eax
  800a1e:	89 04 24             	mov    %eax,(%esp)
  800a21:	e8 c9 fb ff ff       	call   8005ef <dev_lookup>
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 49                	js     800a73 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a2d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a31:	75 23                	jne    800a56 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800a33:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800a38:	8b 40 48             	mov    0x48(%eax),%eax
  800a3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	c7 04 24 98 23 80 00 	movl   $0x802398,(%esp)
  800a4a:	e8 9c 09 00 00       	call   8013eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800a4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a54:	eb 1d                	jmp    800a73 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a59:	8b 52 18             	mov    0x18(%edx),%edx
  800a5c:	85 d2                	test   %edx,%edx
  800a5e:	74 0e                	je     800a6e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800a60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a63:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a67:	89 04 24             	mov    %eax,(%esp)
  800a6a:	ff d2                	call   *%edx
  800a6c:	eb 05                	jmp    800a73 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800a6e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800a73:	83 c4 24             	add    $0x24,%esp
  800a76:	5b                   	pop    %ebx
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 24             	sub    $0x24,%esp
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 09 fb ff ff       	call   80059e <fd_lookup>
  800a95:	85 c0                	test   %eax,%eax
  800a97:	78 52                	js     800aeb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa3:	8b 00                	mov    (%eax),%eax
  800aa5:	89 04 24             	mov    %eax,(%esp)
  800aa8:	e8 42 fb ff ff       	call   8005ef <dev_lookup>
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	78 3a                	js     800aeb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ab4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ab8:	74 2c                	je     800ae6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800aba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800abd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ac4:	00 00 00 
	stat->st_isdir = 0;
  800ac7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ace:	00 00 00 
	stat->st_dev = dev;
  800ad1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ad7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800adb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ade:	89 14 24             	mov    %edx,(%esp)
  800ae1:	ff 50 14             	call   *0x14(%eax)
  800ae4:	eb 05                	jmp    800aeb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ae6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800aeb:	83 c4 24             	add    $0x24,%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 18             	sub    $0x18,%esp
  800af7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800afa:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800afd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800b04:	00 
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	89 04 24             	mov    %eax,(%esp)
  800b0b:	e8 bc 01 00 00       	call   800ccc <open>
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	85 c0                	test   %eax,%eax
  800b14:	78 1b                	js     800b31 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1d:	89 1c 24             	mov    %ebx,(%esp)
  800b20:	e8 54 ff ff ff       	call   800a79 <fstat>
  800b25:	89 c6                	mov    %eax,%esi
	close(fd);
  800b27:	89 1c 24             	mov    %ebx,(%esp)
  800b2a:	e8 be fb ff ff       	call   8006ed <close>
	return r;
  800b2f:	89 f3                	mov    %esi,%ebx
}
  800b31:	89 d8                	mov    %ebx,%eax
  800b33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b36:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b39:	89 ec                	mov    %ebp,%esp
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    
  800b3d:	00 00                	add    %al,(%eax)
	...

00800b40 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	83 ec 18             	sub    $0x18,%esp
  800b46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b49:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b50:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b57:	75 11                	jne    800b6a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b60:	e8 8c 14 00 00       	call   801ff1 <ipc_find_env>
  800b65:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b6a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b71:	00 
  800b72:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b79:	00 
  800b7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b7e:	a1 00 40 80 00       	mov    0x804000,%eax
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 fb 13 00 00       	call   801f86 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  800b8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b92:	00 
  800b93:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b9e:	e8 7d 13 00 00       	call   801f20 <ipc_recv>
}
  800ba3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ba6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ba9:	89 ec                	mov    %ebp,%esp
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 14             	sub    $0x14,%esp
  800bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 40 0c             	mov    0xc(%eax),%eax
  800bbd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcc:	e8 6f ff ff ff       	call   800b40 <fsipc>
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	78 2b                	js     800c00 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800bd5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bdc:	00 
  800bdd:	89 1c 24             	mov    %ebx,(%esp)
  800be0:	e8 56 0f 00 00       	call   801b3b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800be5:	a1 80 50 80 00       	mov    0x805080,%eax
  800bea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bf0:	a1 84 50 80 00       	mov    0x805084,%eax
  800bf5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c00:	83 c4 14             	add    $0x14,%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800c12:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c21:	e8 1a ff ff ff       	call   800b40 <fsipc>
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 10             	sub    $0x10,%esp
  800c30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	8b 40 0c             	mov    0xc(%eax),%eax
  800c39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800c3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
  800c49:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4e:	e8 ed fe ff ff       	call   800b40 <fsipc>
  800c53:	89 c3                	mov    %eax,%ebx
  800c55:	85 c0                	test   %eax,%eax
  800c57:	78 6a                	js     800cc3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c59:	39 c6                	cmp    %eax,%esi
  800c5b:	73 24                	jae    800c81 <devfile_read+0x59>
  800c5d:	c7 44 24 0c 04 24 80 	movl   $0x802404,0xc(%esp)
  800c64:	00 
  800c65:	c7 44 24 08 0b 24 80 	movl   $0x80240b,0x8(%esp)
  800c6c:	00 
  800c6d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800c74:	00 
  800c75:	c7 04 24 20 24 80 00 	movl   $0x802420,(%esp)
  800c7c:	e8 6f 06 00 00       	call   8012f0 <_panic>
	assert(r <= PGSIZE);
  800c81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c86:	7e 24                	jle    800cac <devfile_read+0x84>
  800c88:	c7 44 24 0c 2b 24 80 	movl   $0x80242b,0xc(%esp)
  800c8f:	00 
  800c90:	c7 44 24 08 0b 24 80 	movl   $0x80240b,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 20 24 80 00 	movl   $0x802420,(%esp)
  800ca7:	e8 44 06 00 00       	call   8012f0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800cac:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800cb7:	00 
  800cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbb:	89 04 24             	mov    %eax,(%esp)
  800cbe:	e8 69 10 00 00       	call   801d2c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  800cc3:	89 d8                	mov    %ebx,%eax
  800cc5:	83 c4 10             	add    $0x10,%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 20             	sub    $0x20,%esp
  800cd4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800cd7:	89 34 24             	mov    %esi,(%esp)
  800cda:	e8 11 0e 00 00       	call   801af0 <strlen>
		return -E_BAD_PATH;
  800cdf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ce4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ce9:	7f 5e                	jg     800d49 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cee:	89 04 24             	mov    %eax,(%esp)
  800cf1:	e8 35 f8 ff ff       	call   80052b <fd_alloc>
  800cf6:	89 c3                	mov    %eax,%ebx
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	78 4d                	js     800d49 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800cfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d00:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d07:	e8 2f 0e 00 00       	call   801b3b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800d14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d17:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1c:	e8 1f fe ff ff       	call   800b40 <fsipc>
  800d21:	89 c3                	mov    %eax,%ebx
  800d23:	85 c0                	test   %eax,%eax
  800d25:	79 15                	jns    800d3c <open+0x70>
		fd_close(fd, 0);
  800d27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d2e:	00 
  800d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d32:	89 04 24             	mov    %eax,(%esp)
  800d35:	e8 21 f9 ff ff       	call   80065b <fd_close>
		return r;
  800d3a:	eb 0d                	jmp    800d49 <open+0x7d>
	}

	return fd2num(fd);
  800d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3f:	89 04 24             	mov    %eax,(%esp)
  800d42:	e8 b9 f7 ff ff       	call   800500 <fd2num>
  800d47:	89 c3                	mov    %eax,%ebx
}
  800d49:	89 d8                	mov    %ebx,%eax
  800d4b:	83 c4 20             	add    $0x20,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
	...

00800d60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 18             	sub    $0x18,%esp
  800d66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d69:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	89 04 24             	mov    %eax,(%esp)
  800d75:	e8 96 f7 ff ff       	call   800510 <fd2data>
  800d7a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d7c:	c7 44 24 04 37 24 80 	movl   $0x802437,0x4(%esp)
  800d83:	00 
  800d84:	89 34 24             	mov    %esi,(%esp)
  800d87:	e8 af 0d 00 00       	call   801b3b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d8c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d8f:	2b 03                	sub    (%ebx),%eax
  800d91:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d97:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d9e:	00 00 00 
	stat->st_dev = &devpipe;
  800da1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800da8:	30 80 00 
	return 0;
}
  800dab:	b8 00 00 00 00       	mov    $0x0,%eax
  800db0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800db3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800db6:	89 ec                	mov    %ebp,%esp
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 14             	sub    $0x14,%esp
  800dc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800dc4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dcf:	e8 e9 f4 ff ff       	call   8002bd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800dd4:	89 1c 24             	mov    %ebx,(%esp)
  800dd7:	e8 34 f7 ff ff       	call   800510 <fd2data>
  800ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800de7:	e8 d1 f4 ff ff       	call   8002bd <sys_page_unmap>
}
  800dec:	83 c4 14             	add    $0x14,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 2c             	sub    $0x2c,%esp
  800dfb:	89 c7                	mov    %eax,%edi
  800dfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800e00:	a1 04 40 80 00       	mov    0x804004,%eax
  800e05:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800e08:	89 3c 24             	mov    %edi,(%esp)
  800e0b:	e8 2c 12 00 00       	call   80203c <pageref>
  800e10:	89 c6                	mov    %eax,%esi
  800e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e15:	89 04 24             	mov    %eax,(%esp)
  800e18:	e8 1f 12 00 00       	call   80203c <pageref>
  800e1d:	39 c6                	cmp    %eax,%esi
  800e1f:	0f 94 c0             	sete   %al
  800e22:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800e25:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800e2b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800e2e:	39 cb                	cmp    %ecx,%ebx
  800e30:	75 08                	jne    800e3a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800e32:	83 c4 2c             	add    $0x2c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800e3a:	83 f8 01             	cmp    $0x1,%eax
  800e3d:	75 c1                	jne    800e00 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800e3f:	8b 52 58             	mov    0x58(%edx),%edx
  800e42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e46:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e4e:	c7 04 24 3e 24 80 00 	movl   $0x80243e,(%esp)
  800e55:	e8 91 05 00 00       	call   8013eb <cprintf>
  800e5a:	eb a4                	jmp    800e00 <_pipeisclosed+0xe>

00800e5c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 2c             	sub    $0x2c,%esp
  800e65:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800e68:	89 34 24             	mov    %esi,(%esp)
  800e6b:	e8 a0 f6 ff ff       	call   800510 <fd2data>
  800e70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e72:	bf 00 00 00 00       	mov    $0x0,%edi
  800e77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e7b:	75 50                	jne    800ecd <devpipe_write+0x71>
  800e7d:	eb 5c                	jmp    800edb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e7f:	89 da                	mov    %ebx,%edx
  800e81:	89 f0                	mov    %esi,%eax
  800e83:	e8 6a ff ff ff       	call   800df2 <_pipeisclosed>
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	75 53                	jne    800edf <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e8c:	e8 3f f3 ff ff       	call   8001d0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e91:	8b 43 04             	mov    0x4(%ebx),%eax
  800e94:	8b 13                	mov    (%ebx),%edx
  800e96:	83 c2 20             	add    $0x20,%edx
  800e99:	39 d0                	cmp    %edx,%eax
  800e9b:	73 e2                	jae    800e7f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  800ea4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	c1 fa 1f             	sar    $0x1f,%edx
  800eac:	c1 ea 1b             	shr    $0x1b,%edx
  800eaf:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800eb2:	83 e1 1f             	and    $0x1f,%ecx
  800eb5:	29 d1                	sub    %edx,%ecx
  800eb7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  800ebb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  800ebf:	83 c0 01             	add    $0x1,%eax
  800ec2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ec5:	83 c7 01             	add    $0x1,%edi
  800ec8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ecb:	74 0e                	je     800edb <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ecd:	8b 43 04             	mov    0x4(%ebx),%eax
  800ed0:	8b 13                	mov    (%ebx),%edx
  800ed2:	83 c2 20             	add    $0x20,%edx
  800ed5:	39 d0                	cmp    %edx,%eax
  800ed7:	73 a6                	jae    800e7f <devpipe_write+0x23>
  800ed9:	eb c2                	jmp    800e9d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800edb:	89 f8                	mov    %edi,%eax
  800edd:	eb 05                	jmp    800ee4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ee4:	83 c4 2c             	add    $0x2c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 28             	sub    $0x28,%esp
  800ef2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800efb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800efe:	89 3c 24             	mov    %edi,(%esp)
  800f01:	e8 0a f6 ff ff       	call   800510 <fd2data>
  800f06:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800f08:	be 00 00 00 00       	mov    $0x0,%esi
  800f0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f11:	75 47                	jne    800f5a <devpipe_read+0x6e>
  800f13:	eb 52                	jmp    800f67 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800f15:	89 f0                	mov    %esi,%eax
  800f17:	eb 5e                	jmp    800f77 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800f19:	89 da                	mov    %ebx,%edx
  800f1b:	89 f8                	mov    %edi,%eax
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
  800f20:	e8 cd fe ff ff       	call   800df2 <_pipeisclosed>
  800f25:	85 c0                	test   %eax,%eax
  800f27:	75 49                	jne    800f72 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  800f29:	e8 a2 f2 ff ff       	call   8001d0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800f2e:	8b 03                	mov    (%ebx),%eax
  800f30:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f33:	74 e4                	je     800f19 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 fa 1f             	sar    $0x1f,%edx
  800f3a:	c1 ea 1b             	shr    $0x1b,%edx
  800f3d:	01 d0                	add    %edx,%eax
  800f3f:	83 e0 1f             	and    $0x1f,%eax
  800f42:	29 d0                	sub    %edx,%eax
  800f44:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800f4f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800f52:	83 c6 01             	add    $0x1,%esi
  800f55:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f58:	74 0d                	je     800f67 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  800f5a:	8b 03                	mov    (%ebx),%eax
  800f5c:	3b 43 04             	cmp    0x4(%ebx),%eax
  800f5f:	75 d4                	jne    800f35 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800f61:	85 f6                	test   %esi,%esi
  800f63:	75 b0                	jne    800f15 <devpipe_read+0x29>
  800f65:	eb b2                	jmp    800f19 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	eb 05                	jmp    800f77 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800f77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f80:	89 ec                	mov    %ebp,%esp
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 48             	sub    $0x48,%esp
  800f8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f90:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f93:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800f96:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f99:	89 04 24             	mov    %eax,(%esp)
  800f9c:	e8 8a f5 ff ff       	call   80052b <fd_alloc>
  800fa1:	89 c3                	mov    %eax,%ebx
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	0f 88 45 01 00 00    	js     8010f0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fb2:	00 
  800fb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc1:	e8 3a f2 ff ff       	call   800200 <sys_page_alloc>
  800fc6:	89 c3                	mov    %eax,%ebx
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	0f 88 20 01 00 00    	js     8010f0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800fd0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fd3:	89 04 24             	mov    %eax,(%esp)
  800fd6:	e8 50 f5 ff ff       	call   80052b <fd_alloc>
  800fdb:	89 c3                	mov    %eax,%ebx
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	0f 88 f8 00 00 00    	js     8010dd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800fe5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800fec:	00 
  800fed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffb:	e8 00 f2 ff ff       	call   800200 <sys_page_alloc>
  801000:	89 c3                	mov    %eax,%ebx
  801002:	85 c0                	test   %eax,%eax
  801004:	0f 88 d3 00 00 00    	js     8010dd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80100a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 fb f4 ff ff       	call   800510 <fd2data>
  801015:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801017:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80101e:	00 
  80101f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801023:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102a:	e8 d1 f1 ff ff       	call   800200 <sys_page_alloc>
  80102f:	89 c3                	mov    %eax,%ebx
  801031:	85 c0                	test   %eax,%eax
  801033:	0f 88 91 00 00 00    	js     8010ca <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801039:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80103c:	89 04 24             	mov    %eax,(%esp)
  80103f:	e8 cc f4 ff ff       	call   800510 <fd2data>
  801044:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80104b:	00 
  80104c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801050:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801057:	00 
  801058:	89 74 24 04          	mov    %esi,0x4(%esp)
  80105c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801063:	e8 f7 f1 ff ff       	call   80025f <sys_page_map>
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 4c                	js     8010ba <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80106e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801077:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801079:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801083:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801089:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80108c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80108e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801091:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109b:	89 04 24             	mov    %eax,(%esp)
  80109e:	e8 5d f4 ff ff       	call   800500 <fd2num>
  8010a3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8010a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010a8:	89 04 24             	mov    %eax,(%esp)
  8010ab:	e8 50 f4 ff ff       	call   800500 <fd2num>
  8010b0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8010b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b8:	eb 36                	jmp    8010f0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8010ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c5:	e8 f3 f1 ff ff       	call   8002bd <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8010ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d8:	e8 e0 f1 ff ff       	call   8002bd <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8010dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010eb:	e8 cd f1 ff ff       	call   8002bd <sys_page_unmap>
    err:
	return r;
}
  8010f0:	89 d8                	mov    %ebx,%eax
  8010f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010fb:	89 ec                	mov    %ebp,%esp
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801105:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	89 04 24             	mov    %eax,(%esp)
  801112:	e8 87 f4 ff ff       	call   80059e <fd_lookup>
  801117:	85 c0                	test   %eax,%eax
  801119:	78 15                	js     801130 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80111b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111e:	89 04 24             	mov    %eax,(%esp)
  801121:	e8 ea f3 ff ff       	call   800510 <fd2data>
	return _pipeisclosed(fd, p);
  801126:	89 c2                	mov    %eax,%edx
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	e8 c2 fc ff ff       	call   800df2 <_pipeisclosed>
}
  801130:	c9                   	leave  
  801131:	c3                   	ret    
	...

00801140 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801150:	c7 44 24 04 56 24 80 	movl   $0x802456,0x4(%esp)
  801157:	00 
  801158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115b:	89 04 24             	mov    %eax,(%esp)
  80115e:	e8 d8 09 00 00       	call   801b3b <strcpy>
	return 0;
}
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801176:	be 00 00 00 00       	mov    $0x0,%esi
  80117b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80117f:	74 43                	je     8011c4 <devcons_write+0x5a>
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801186:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80118c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801191:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801194:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801199:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80119c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011a0:	03 45 0c             	add    0xc(%ebp),%eax
  8011a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a7:	89 3c 24             	mov    %edi,(%esp)
  8011aa:	e8 7d 0b 00 00       	call   801d2c <memmove>
		sys_cputs(buf, m);
  8011af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011b3:	89 3c 24             	mov    %edi,(%esp)
  8011b6:	e8 29 ef ff ff       	call   8000e4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8011bb:	01 de                	add    %ebx,%esi
  8011bd:	89 f0                	mov    %esi,%eax
  8011bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011c2:	72 c8                	jb     80118c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8011c4:	89 f0                	mov    %esi,%eax
  8011c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8011dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011e0:	75 07                	jne    8011e9 <devcons_read+0x18>
  8011e2:	eb 31                	jmp    801215 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8011e4:	e8 e7 ef ff ff       	call   8001d0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	e8 1e ef ff ff       	call   800113 <sys_cgetc>
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	74 eb                	je     8011e4 <devcons_read+0x13>
  8011f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 16                	js     801215 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8011ff:	83 f8 04             	cmp    $0x4,%eax
  801202:	74 0c                	je     801210 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  801204:	8b 45 0c             	mov    0xc(%ebp),%eax
  801207:	88 10                	mov    %dl,(%eax)
	return 1;
  801209:	b8 01 00 00 00       	mov    $0x1,%eax
  80120e:	eb 05                	jmp    801215 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
  801220:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801223:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80122a:	00 
  80122b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80122e:	89 04 24             	mov    %eax,(%esp)
  801231:	e8 ae ee ff ff       	call   8000e4 <sys_cputs>
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <getchar>:

int
getchar(void)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80123e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801245:	00 
  801246:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801254:	e8 05 f6 ff ff       	call   80085e <read>
	if (r < 0)
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 0f                	js     80126c <getchar+0x34>
		return r;
	if (r < 1)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	7e 06                	jle    801267 <getchar+0x2f>
		return -E_EOF;
	return c;
  801261:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801265:	eb 05                	jmp    80126c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801267:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801274:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 18 f3 ff ff       	call   80059e <fd_lookup>
  801286:	85 c0                	test   %eax,%eax
  801288:	78 11                	js     80129b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80128a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801293:	39 10                	cmp    %edx,(%eax)
  801295:	0f 94 c0             	sete   %al
  801298:	0f b6 c0             	movzbl %al,%eax
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <opencons>:

int
opencons(void)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8012a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a6:	89 04 24             	mov    %eax,(%esp)
  8012a9:	e8 7d f2 ff ff       	call   80052b <fd_alloc>
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 3c                	js     8012ee <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8012b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012b9:	00 
  8012ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c8:	e8 33 ef ff ff       	call   800200 <sys_page_alloc>
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 1d                	js     8012ee <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8012d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012da:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012df:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 12 f2 ff ff       	call   800500 <fd2num>
}
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8012f8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012fb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801301:	e8 9a ee ff ff       	call   8001a0 <sys_getenvid>
  801306:	8b 55 0c             	mov    0xc(%ebp),%edx
  801309:	89 54 24 10          	mov    %edx,0x10(%esp)
  80130d:	8b 55 08             	mov    0x8(%ebp),%edx
  801310:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801314:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131c:	c7 04 24 64 24 80 00 	movl   $0x802464,(%esp)
  801323:	e8 c3 00 00 00       	call   8013eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801328:	89 74 24 04          	mov    %esi,0x4(%esp)
  80132c:	8b 45 10             	mov    0x10(%ebp),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 53 00 00 00       	call   80138a <vcprintf>
	cprintf("\n");
  801337:	c7 04 24 4f 24 80 00 	movl   $0x80244f,(%esp)
  80133e:	e8 a8 00 00 00       	call   8013eb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801343:	cc                   	int3   
  801344:	eb fd                	jmp    801343 <_panic+0x53>
	...

00801348 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 14             	sub    $0x14,%esp
  80134f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801352:	8b 03                	mov    (%ebx),%eax
  801354:	8b 55 08             	mov    0x8(%ebp),%edx
  801357:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80135b:	83 c0 01             	add    $0x1,%eax
  80135e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801360:	3d ff 00 00 00       	cmp    $0xff,%eax
  801365:	75 19                	jne    801380 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801367:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80136e:	00 
  80136f:	8d 43 08             	lea    0x8(%ebx),%eax
  801372:	89 04 24             	mov    %eax,(%esp)
  801375:	e8 6a ed ff ff       	call   8000e4 <sys_cputs>
		b->idx = 0;
  80137a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801384:	83 c4 14             	add    $0x14,%esp
  801387:	5b                   	pop    %ebx
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801393:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80139a:	00 00 00 
	b.cnt = 0;
  80139d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8013a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bf:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  8013c6:	e8 97 01 00 00       	call   801562 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8013cb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8013d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 01 ed ff ff       	call   8000e4 <sys_cputs>

	return b.cnt;
}
  8013e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8013f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	89 04 24             	mov    %eax,(%esp)
  8013fe:	e8 87 ff ff ff       	call   80138a <vcprintf>
	va_end(ap);

	return cnt;
}
  801403:	c9                   	leave  
  801404:	c3                   	ret    
  801405:	00 00                	add    %al,(%eax)
	...

00801408 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	57                   	push   %edi
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	83 ec 3c             	sub    $0x3c,%esp
  801411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801414:	89 d7                	mov    %edx,%edi
  801416:	8b 45 08             	mov    0x8(%ebp),%eax
  801419:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801422:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801425:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801428:	b8 00 00 00 00       	mov    $0x0,%eax
  80142d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801430:	72 11                	jb     801443 <printnum+0x3b>
  801432:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801435:	39 45 10             	cmp    %eax,0x10(%ebp)
  801438:	76 09                	jbe    801443 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80143a:	83 eb 01             	sub    $0x1,%ebx
  80143d:	85 db                	test   %ebx,%ebx
  80143f:	7f 51                	jg     801492 <printnum+0x8a>
  801441:	eb 5e                	jmp    8014a1 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801443:	89 74 24 10          	mov    %esi,0x10(%esp)
  801447:	83 eb 01             	sub    $0x1,%ebx
  80144a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80144e:	8b 45 10             	mov    0x10(%ebp),%eax
  801451:	89 44 24 08          	mov    %eax,0x8(%esp)
  801455:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801459:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80145d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801464:	00 
  801465:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801468:	89 04 24             	mov    %eax,(%esp)
  80146b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80146e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801472:	e8 09 0c 00 00       	call   802080 <__udivdi3>
  801477:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80147b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	89 54 24 04          	mov    %edx,0x4(%esp)
  801486:	89 fa                	mov    %edi,%edx
  801488:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80148b:	e8 78 ff ff ff       	call   801408 <printnum>
  801490:	eb 0f                	jmp    8014a1 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801496:	89 34 24             	mov    %esi,(%esp)
  801499:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80149c:	83 eb 01             	sub    $0x1,%ebx
  80149f:	75 f1                	jne    801492 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014a5:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8014ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014b7:	00 
  8014b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c5:	e8 e6 0c 00 00       	call   8021b0 <__umoddi3>
  8014ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ce:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014db:	83 c4 3c             	add    $0x3c,%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5f                   	pop    %edi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014e6:	83 fa 01             	cmp    $0x1,%edx
  8014e9:	7e 0e                	jle    8014f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014eb:	8b 10                	mov    (%eax),%edx
  8014ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014f0:	89 08                	mov    %ecx,(%eax)
  8014f2:	8b 02                	mov    (%edx),%eax
  8014f4:	8b 52 04             	mov    0x4(%edx),%edx
  8014f7:	eb 22                	jmp    80151b <getuint+0x38>
	else if (lflag)
  8014f9:	85 d2                	test   %edx,%edx
  8014fb:	74 10                	je     80150d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014fd:	8b 10                	mov    (%eax),%edx
  8014ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  801502:	89 08                	mov    %ecx,(%eax)
  801504:	8b 02                	mov    (%edx),%eax
  801506:	ba 00 00 00 00       	mov    $0x0,%edx
  80150b:	eb 0e                	jmp    80151b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80150d:	8b 10                	mov    (%eax),%edx
  80150f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801512:	89 08                	mov    %ecx,(%eax)
  801514:	8b 02                	mov    (%edx),%eax
  801516:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801523:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801527:	8b 10                	mov    (%eax),%edx
  801529:	3b 50 04             	cmp    0x4(%eax),%edx
  80152c:	73 0a                	jae    801538 <sprintputch+0x1b>
		*b->buf++ = ch;
  80152e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801531:	88 0a                	mov    %cl,(%edx)
  801533:	83 c2 01             	add    $0x1,%edx
  801536:	89 10                	mov    %edx,(%eax)
}
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801540:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801547:	8b 45 10             	mov    0x10(%ebp),%eax
  80154a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80154e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801551:	89 44 24 04          	mov    %eax,0x4(%esp)
  801555:	8b 45 08             	mov    0x8(%ebp),%eax
  801558:	89 04 24             	mov    %eax,(%esp)
  80155b:	e8 02 00 00 00       	call   801562 <vprintfmt>
	va_end(ap);
}
  801560:	c9                   	leave  
  801561:	c3                   	ret    

00801562 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	57                   	push   %edi
  801566:	56                   	push   %esi
  801567:	53                   	push   %ebx
  801568:	83 ec 5c             	sub    $0x5c,%esp
  80156b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80156e:	8b 75 10             	mov    0x10(%ebp),%esi
  801571:	eb 12                	jmp    801585 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801573:	85 c0                	test   %eax,%eax
  801575:	0f 84 e4 04 00 00    	je     801a5f <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80157b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80157f:	89 04 24             	mov    %eax,(%esp)
  801582:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801585:	0f b6 06             	movzbl (%esi),%eax
  801588:	83 c6 01             	add    $0x1,%esi
  80158b:	83 f8 25             	cmp    $0x25,%eax
  80158e:	75 e3                	jne    801573 <vprintfmt+0x11>
  801590:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  801594:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80159b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8015a0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8015a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ac:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8015af:	eb 2b                	jmp    8015dc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015b4:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8015b8:	eb 22                	jmp    8015dc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8015bd:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8015c1:	eb 19                	jmp    8015dc <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8015c6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8015cd:	eb 0d                	jmp    8015dc <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8015cf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8015d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8015d5:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015dc:	0f b6 06             	movzbl (%esi),%eax
  8015df:	0f b6 d0             	movzbl %al,%edx
  8015e2:	8d 7e 01             	lea    0x1(%esi),%edi
  8015e5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8015e8:	83 e8 23             	sub    $0x23,%eax
  8015eb:	3c 55                	cmp    $0x55,%al
  8015ed:	0f 87 46 04 00 00    	ja     801a39 <vprintfmt+0x4d7>
  8015f3:	0f b6 c0             	movzbl %al,%eax
  8015f6:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015fd:	83 ea 30             	sub    $0x30,%edx
  801600:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  801603:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  801607:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80160d:	83 fa 09             	cmp    $0x9,%edx
  801610:	77 4a                	ja     80165c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801612:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801615:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  801618:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80161b:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80161f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801622:	8d 50 d0             	lea    -0x30(%eax),%edx
  801625:	83 fa 09             	cmp    $0x9,%edx
  801628:	76 eb                	jbe    801615 <vprintfmt+0xb3>
  80162a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  80162d:	eb 2d                	jmp    80165c <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80162f:	8b 45 14             	mov    0x14(%ebp),%eax
  801632:	8d 50 04             	lea    0x4(%eax),%edx
  801635:	89 55 14             	mov    %edx,0x14(%ebp)
  801638:	8b 00                	mov    (%eax),%eax
  80163a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80163d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801640:	eb 1a                	jmp    80165c <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801642:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  801645:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801649:	79 91                	jns    8015dc <vprintfmt+0x7a>
  80164b:	e9 73 ff ff ff       	jmp    8015c3 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801650:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801653:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80165a:	eb 80                	jmp    8015dc <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80165c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801660:	0f 89 76 ff ff ff    	jns    8015dc <vprintfmt+0x7a>
  801666:	e9 64 ff ff ff       	jmp    8015cf <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80166b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801671:	e9 66 ff ff ff       	jmp    8015dc <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801676:	8b 45 14             	mov    0x14(%ebp),%eax
  801679:	8d 50 04             	lea    0x4(%eax),%edx
  80167c:	89 55 14             	mov    %edx,0x14(%ebp)
  80167f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801683:	8b 00                	mov    (%eax),%eax
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80168e:	e9 f2 fe ff ff       	jmp    801585 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  801693:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  801697:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80169a:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  80169e:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8016a1:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8016a5:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8016a8:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8016ab:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8016af:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8016b2:	80 f9 09             	cmp    $0x9,%cl
  8016b5:	77 1d                	ja     8016d4 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8016b7:	0f be c0             	movsbl %al,%eax
  8016ba:	6b c0 64             	imul   $0x64,%eax,%eax
  8016bd:	0f be d2             	movsbl %dl,%edx
  8016c0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8016c3:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8016ca:	a3 58 30 80 00       	mov    %eax,0x803058
  8016cf:	e9 b1 fe ff ff       	jmp    801585 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8016d4:	c7 44 24 04 9f 24 80 	movl   $0x80249f,0x4(%esp)
  8016db:	00 
  8016dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016df:	89 04 24             	mov    %eax,(%esp)
  8016e2:	e8 14 05 00 00       	call   801bfb <strcmp>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	75 0f                	jne    8016fa <vprintfmt+0x198>
  8016eb:	c7 05 58 30 80 00 04 	movl   $0x4,0x803058
  8016f2:	00 00 00 
  8016f5:	e9 8b fe ff ff       	jmp    801585 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8016fa:	c7 44 24 04 a3 24 80 	movl   $0x8024a3,0x4(%esp)
  801701:	00 
  801702:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801705:	89 14 24             	mov    %edx,(%esp)
  801708:	e8 ee 04 00 00       	call   801bfb <strcmp>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	75 0f                	jne    801720 <vprintfmt+0x1be>
  801711:	c7 05 58 30 80 00 02 	movl   $0x2,0x803058
  801718:	00 00 00 
  80171b:	e9 65 fe ff ff       	jmp    801585 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  801720:	c7 44 24 04 a7 24 80 	movl   $0x8024a7,0x4(%esp)
  801727:	00 
  801728:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80172b:	89 0c 24             	mov    %ecx,(%esp)
  80172e:	e8 c8 04 00 00       	call   801bfb <strcmp>
  801733:	85 c0                	test   %eax,%eax
  801735:	75 0f                	jne    801746 <vprintfmt+0x1e4>
  801737:	c7 05 58 30 80 00 01 	movl   $0x1,0x803058
  80173e:	00 00 00 
  801741:	e9 3f fe ff ff       	jmp    801585 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  801746:	c7 44 24 04 ab 24 80 	movl   $0x8024ab,0x4(%esp)
  80174d:	00 
  80174e:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  801751:	89 3c 24             	mov    %edi,(%esp)
  801754:	e8 a2 04 00 00       	call   801bfb <strcmp>
  801759:	85 c0                	test   %eax,%eax
  80175b:	75 0f                	jne    80176c <vprintfmt+0x20a>
  80175d:	c7 05 58 30 80 00 06 	movl   $0x6,0x803058
  801764:	00 00 00 
  801767:	e9 19 fe ff ff       	jmp    801585 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  80176c:	c7 44 24 04 af 24 80 	movl   $0x8024af,0x4(%esp)
  801773:	00 
  801774:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801777:	89 04 24             	mov    %eax,(%esp)
  80177a:	e8 7c 04 00 00       	call   801bfb <strcmp>
  80177f:	85 c0                	test   %eax,%eax
  801781:	75 0f                	jne    801792 <vprintfmt+0x230>
  801783:	c7 05 58 30 80 00 07 	movl   $0x7,0x803058
  80178a:	00 00 00 
  80178d:	e9 f3 fd ff ff       	jmp    801585 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  801792:	c7 44 24 04 b3 24 80 	movl   $0x8024b3,0x4(%esp)
  801799:	00 
  80179a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80179d:	89 14 24             	mov    %edx,(%esp)
  8017a0:	e8 56 04 00 00       	call   801bfb <strcmp>
  8017a5:	83 f8 01             	cmp    $0x1,%eax
  8017a8:	19 c0                	sbb    %eax,%eax
  8017aa:	f7 d0                	not    %eax
  8017ac:	83 c0 08             	add    $0x8,%eax
  8017af:	a3 58 30 80 00       	mov    %eax,0x803058
  8017b4:	e9 cc fd ff ff       	jmp    801585 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  8017b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bc:	8d 50 04             	lea    0x4(%eax),%edx
  8017bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8017c2:	8b 00                	mov    (%eax),%eax
  8017c4:	89 c2                	mov    %eax,%edx
  8017c6:	c1 fa 1f             	sar    $0x1f,%edx
  8017c9:	31 d0                	xor    %edx,%eax
  8017cb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017cd:	83 f8 0f             	cmp    $0xf,%eax
  8017d0:	7f 0b                	jg     8017dd <vprintfmt+0x27b>
  8017d2:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  8017d9:	85 d2                	test   %edx,%edx
  8017db:	75 23                	jne    801800 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8017dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e1:	c7 44 24 08 b7 24 80 	movl   $0x8024b7,0x8(%esp)
  8017e8:	00 
  8017e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f0:	89 3c 24             	mov    %edi,(%esp)
  8017f3:	e8 42 fd ff ff       	call   80153a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017fb:	e9 85 fd ff ff       	jmp    801585 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801800:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801804:	c7 44 24 08 1d 24 80 	movl   $0x80241d,0x8(%esp)
  80180b:	00 
  80180c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801810:	8b 7d 08             	mov    0x8(%ebp),%edi
  801813:	89 3c 24             	mov    %edi,(%esp)
  801816:	e8 1f fd ff ff       	call   80153a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80181e:	e9 62 fd ff ff       	jmp    801585 <vprintfmt+0x23>
  801823:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  801826:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801829:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80182c:	8b 45 14             	mov    0x14(%ebp),%eax
  80182f:	8d 50 04             	lea    0x4(%eax),%edx
  801832:	89 55 14             	mov    %edx,0x14(%ebp)
  801835:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  801837:	85 f6                	test   %esi,%esi
  801839:	b8 98 24 80 00       	mov    $0x802498,%eax
  80183e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  801841:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801845:	7e 06                	jle    80184d <vprintfmt+0x2eb>
  801847:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80184b:	75 13                	jne    801860 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80184d:	0f be 06             	movsbl (%esi),%eax
  801850:	83 c6 01             	add    $0x1,%esi
  801853:	85 c0                	test   %eax,%eax
  801855:	0f 85 94 00 00 00    	jne    8018ef <vprintfmt+0x38d>
  80185b:	e9 81 00 00 00       	jmp    8018e1 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801860:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801864:	89 34 24             	mov    %esi,(%esp)
  801867:	e8 9f 02 00 00       	call   801b0b <strnlen>
  80186c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80186f:	29 c2                	sub    %eax,%edx
  801871:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801874:	85 d2                	test   %edx,%edx
  801876:	7e d5                	jle    80184d <vprintfmt+0x2eb>
					putch(padc, putdat);
  801878:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  80187c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  80187f:	89 7d c0             	mov    %edi,-0x40(%ebp)
  801882:	89 d6                	mov    %edx,%esi
  801884:	89 cf                	mov    %ecx,%edi
  801886:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80188a:	89 3c 24             	mov    %edi,(%esp)
  80188d:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801890:	83 ee 01             	sub    $0x1,%esi
  801893:	75 f1                	jne    801886 <vprintfmt+0x324>
  801895:	8b 7d c0             	mov    -0x40(%ebp),%edi
  801898:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80189b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  80189e:	eb ad                	jmp    80184d <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018a0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8018a4:	74 1b                	je     8018c1 <vprintfmt+0x35f>
  8018a6:	8d 50 e0             	lea    -0x20(%eax),%edx
  8018a9:	83 fa 5e             	cmp    $0x5e,%edx
  8018ac:	76 13                	jbe    8018c1 <vprintfmt+0x35f>
					putch('?', putdat);
  8018ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b5:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8018bc:	ff 55 08             	call   *0x8(%ebp)
  8018bf:	eb 0d                	jmp    8018ce <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  8018c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8018c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ce:	83 eb 01             	sub    $0x1,%ebx
  8018d1:	0f be 06             	movsbl (%esi),%eax
  8018d4:	83 c6 01             	add    $0x1,%esi
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	75 1a                	jne    8018f5 <vprintfmt+0x393>
  8018db:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8018de:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018e4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8018e8:	7f 1c                	jg     801906 <vprintfmt+0x3a4>
  8018ea:	e9 96 fc ff ff       	jmp    801585 <vprintfmt+0x23>
  8018ef:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8018f2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018f5:	85 ff                	test   %edi,%edi
  8018f7:	78 a7                	js     8018a0 <vprintfmt+0x33e>
  8018f9:	83 ef 01             	sub    $0x1,%edi
  8018fc:	79 a2                	jns    8018a0 <vprintfmt+0x33e>
  8018fe:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  801901:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801904:	eb db                	jmp    8018e1 <vprintfmt+0x37f>
  801906:	8b 7d 08             	mov    0x8(%ebp),%edi
  801909:	89 de                	mov    %ebx,%esi
  80190b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80190e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801912:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801919:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80191b:	83 eb 01             	sub    $0x1,%ebx
  80191e:	75 ee                	jne    80190e <vprintfmt+0x3ac>
  801920:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801922:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801925:	e9 5b fc ff ff       	jmp    801585 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80192a:	83 f9 01             	cmp    $0x1,%ecx
  80192d:	7e 10                	jle    80193f <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  80192f:	8b 45 14             	mov    0x14(%ebp),%eax
  801932:	8d 50 08             	lea    0x8(%eax),%edx
  801935:	89 55 14             	mov    %edx,0x14(%ebp)
  801938:	8b 30                	mov    (%eax),%esi
  80193a:	8b 78 04             	mov    0x4(%eax),%edi
  80193d:	eb 26                	jmp    801965 <vprintfmt+0x403>
	else if (lflag)
  80193f:	85 c9                	test   %ecx,%ecx
  801941:	74 12                	je     801955 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  801943:	8b 45 14             	mov    0x14(%ebp),%eax
  801946:	8d 50 04             	lea    0x4(%eax),%edx
  801949:	89 55 14             	mov    %edx,0x14(%ebp)
  80194c:	8b 30                	mov    (%eax),%esi
  80194e:	89 f7                	mov    %esi,%edi
  801950:	c1 ff 1f             	sar    $0x1f,%edi
  801953:	eb 10                	jmp    801965 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8d 50 04             	lea    0x4(%eax),%edx
  80195b:	89 55 14             	mov    %edx,0x14(%ebp)
  80195e:	8b 30                	mov    (%eax),%esi
  801960:	89 f7                	mov    %esi,%edi
  801962:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801965:	85 ff                	test   %edi,%edi
  801967:	78 0e                	js     801977 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801969:	89 f0                	mov    %esi,%eax
  80196b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80196d:	be 0a 00 00 00       	mov    $0xa,%esi
  801972:	e9 84 00 00 00       	jmp    8019fb <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801977:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801982:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801985:	89 f0                	mov    %esi,%eax
  801987:	89 fa                	mov    %edi,%edx
  801989:	f7 d8                	neg    %eax
  80198b:	83 d2 00             	adc    $0x0,%edx
  80198e:	f7 da                	neg    %edx
			}
			base = 10;
  801990:	be 0a 00 00 00       	mov    $0xa,%esi
  801995:	eb 64                	jmp    8019fb <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801997:	89 ca                	mov    %ecx,%edx
  801999:	8d 45 14             	lea    0x14(%ebp),%eax
  80199c:	e8 42 fb ff ff       	call   8014e3 <getuint>
			base = 10;
  8019a1:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  8019a6:	eb 53                	jmp    8019fb <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8019a8:	89 ca                	mov    %ecx,%edx
  8019aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ad:	e8 31 fb ff ff       	call   8014e3 <getuint>
    			base = 8;
  8019b2:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  8019b7:	eb 42                	jmp    8019fb <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  8019b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019bd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8019c4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8019c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019cb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8019d2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d8:	8d 50 04             	lea    0x4(%eax),%edx
  8019db:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019de:	8b 00                	mov    (%eax),%eax
  8019e0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019e5:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  8019ea:	eb 0f                	jmp    8019fb <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019ec:	89 ca                	mov    %ecx,%edx
  8019ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f1:	e8 ed fa ff ff       	call   8014e3 <getuint>
			base = 16;
  8019f6:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019fb:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8019ff:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801a03:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801a06:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a0a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a15:	89 da                	mov    %ebx,%edx
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	e8 e9 f9 ff ff       	call   801408 <printnum>
			break;
  801a1f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  801a22:	e9 5e fb ff ff       	jmp    801585 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a2b:	89 14 24             	mov    %edx,(%esp)
  801a2e:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a31:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a34:	e9 4c fb ff ff       	jmp    801585 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a3d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801a44:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a47:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a4b:	0f 84 34 fb ff ff    	je     801585 <vprintfmt+0x23>
  801a51:	83 ee 01             	sub    $0x1,%esi
  801a54:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a58:	75 f7                	jne    801a51 <vprintfmt+0x4ef>
  801a5a:	e9 26 fb ff ff       	jmp    801585 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801a5f:	83 c4 5c             	add    $0x5c,%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5f                   	pop    %edi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 28             	sub    $0x28,%esp
  801a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a76:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a7a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a84:	85 c0                	test   %eax,%eax
  801a86:	74 30                	je     801ab8 <vsnprintf+0x51>
  801a88:	85 d2                	test   %edx,%edx
  801a8a:	7e 2c                	jle    801ab8 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a93:	8b 45 10             	mov    0x10(%ebp),%eax
  801a96:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa1:	c7 04 24 1d 15 80 00 	movl   $0x80151d,(%esp)
  801aa8:	e8 b5 fa ff ff       	call   801562 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ab0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	eb 05                	jmp    801abd <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ab8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ac5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ac8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801acc:	8b 45 10             	mov    0x10(%ebp),%eax
  801acf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	89 04 24             	mov    %eax,(%esp)
  801ae0:	e8 82 ff ff ff       	call   801a67 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ae5:	c9                   	leave  
  801ae6:	c3                   	ret    
	...

00801af0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
  801afb:	80 3a 00             	cmpb   $0x0,(%edx)
  801afe:	74 09                	je     801b09 <strlen+0x19>
		n++;
  801b00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b07:	75 f7                	jne    801b00 <strlen+0x10>
		n++;
	return n;
}
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	53                   	push   %ebx
  801b0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1a:	85 c9                	test   %ecx,%ecx
  801b1c:	74 1a                	je     801b38 <strnlen+0x2d>
  801b1e:	80 3b 00             	cmpb   $0x0,(%ebx)
  801b21:	74 15                	je     801b38 <strnlen+0x2d>
  801b23:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801b28:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2a:	39 ca                	cmp    %ecx,%edx
  801b2c:	74 0a                	je     801b38 <strnlen+0x2d>
  801b2e:	83 c2 01             	add    $0x1,%edx
  801b31:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801b36:	75 f0                	jne    801b28 <strnlen+0x1d>
		n++;
	return n;
}
  801b38:	5b                   	pop    %ebx
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	53                   	push   %ebx
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801b4e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801b51:	83 c2 01             	add    $0x1,%edx
  801b54:	84 c9                	test   %cl,%cl
  801b56:	75 f2                	jne    801b4a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b58:	5b                   	pop    %ebx
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 08             	sub    $0x8,%esp
  801b62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b65:	89 1c 24             	mov    %ebx,(%esp)
  801b68:	e8 83 ff ff ff       	call   801af0 <strlen>
	strcpy(dst + len, src);
  801b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b70:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b74:	01 d8                	add    %ebx,%eax
  801b76:	89 04 24             	mov    %eax,(%esp)
  801b79:	e8 bd ff ff ff       	call   801b3b <strcpy>
	return dst;
}
  801b7e:	89 d8                	mov    %ebx,%eax
  801b80:	83 c4 08             	add    $0x8,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	56                   	push   %esi
  801b8a:	53                   	push   %ebx
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b91:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b94:	85 f6                	test   %esi,%esi
  801b96:	74 18                	je     801bb0 <strncpy+0x2a>
  801b98:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b9d:	0f b6 1a             	movzbl (%edx),%ebx
  801ba0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba3:	80 3a 01             	cmpb   $0x1,(%edx)
  801ba6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba9:	83 c1 01             	add    $0x1,%ecx
  801bac:	39 f1                	cmp    %esi,%ecx
  801bae:	75 ed                	jne    801b9d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	57                   	push   %edi
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bc0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc3:	89 f8                	mov    %edi,%eax
  801bc5:	85 f6                	test   %esi,%esi
  801bc7:	74 2b                	je     801bf4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  801bc9:	83 fe 01             	cmp    $0x1,%esi
  801bcc:	74 23                	je     801bf1 <strlcpy+0x3d>
  801bce:	0f b6 0b             	movzbl (%ebx),%ecx
  801bd1:	84 c9                	test   %cl,%cl
  801bd3:	74 1c                	je     801bf1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  801bd5:	83 ee 02             	sub    $0x2,%esi
  801bd8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bdd:	88 08                	mov    %cl,(%eax)
  801bdf:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be2:	39 f2                	cmp    %esi,%edx
  801be4:	74 0b                	je     801bf1 <strlcpy+0x3d>
  801be6:	83 c2 01             	add    $0x1,%edx
  801be9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801bed:	84 c9                	test   %cl,%cl
  801bef:	75 ec                	jne    801bdd <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  801bf1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf4:	29 f8                	sub    %edi,%eax
}
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c04:	0f b6 01             	movzbl (%ecx),%eax
  801c07:	84 c0                	test   %al,%al
  801c09:	74 16                	je     801c21 <strcmp+0x26>
  801c0b:	3a 02                	cmp    (%edx),%al
  801c0d:	75 12                	jne    801c21 <strcmp+0x26>
		p++, q++;
  801c0f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c12:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  801c16:	84 c0                	test   %al,%al
  801c18:	74 07                	je     801c21 <strcmp+0x26>
  801c1a:	83 c1 01             	add    $0x1,%ecx
  801c1d:	3a 02                	cmp    (%edx),%al
  801c1f:	74 ee                	je     801c0f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c21:	0f b6 c0             	movzbl %al,%eax
  801c24:	0f b6 12             	movzbl (%edx),%edx
  801c27:	29 d0                	sub    %edx,%eax
}
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	53                   	push   %ebx
  801c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c35:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c3d:	85 d2                	test   %edx,%edx
  801c3f:	74 28                	je     801c69 <strncmp+0x3e>
  801c41:	0f b6 01             	movzbl (%ecx),%eax
  801c44:	84 c0                	test   %al,%al
  801c46:	74 24                	je     801c6c <strncmp+0x41>
  801c48:	3a 03                	cmp    (%ebx),%al
  801c4a:	75 20                	jne    801c6c <strncmp+0x41>
  801c4c:	83 ea 01             	sub    $0x1,%edx
  801c4f:	74 13                	je     801c64 <strncmp+0x39>
		n--, p++, q++;
  801c51:	83 c1 01             	add    $0x1,%ecx
  801c54:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c57:	0f b6 01             	movzbl (%ecx),%eax
  801c5a:	84 c0                	test   %al,%al
  801c5c:	74 0e                	je     801c6c <strncmp+0x41>
  801c5e:	3a 03                	cmp    (%ebx),%al
  801c60:	74 ea                	je     801c4c <strncmp+0x21>
  801c62:	eb 08                	jmp    801c6c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c69:	5b                   	pop    %ebx
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c6c:	0f b6 01             	movzbl (%ecx),%eax
  801c6f:	0f b6 13             	movzbl (%ebx),%edx
  801c72:	29 d0                	sub    %edx,%eax
  801c74:	eb f3                	jmp    801c69 <strncmp+0x3e>

00801c76 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c80:	0f b6 10             	movzbl (%eax),%edx
  801c83:	84 d2                	test   %dl,%dl
  801c85:	74 1c                	je     801ca3 <strchr+0x2d>
		if (*s == c)
  801c87:	38 ca                	cmp    %cl,%dl
  801c89:	75 09                	jne    801c94 <strchr+0x1e>
  801c8b:	eb 1b                	jmp    801ca8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c8d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  801c90:	38 ca                	cmp    %cl,%dl
  801c92:	74 14                	je     801ca8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c94:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  801c98:	84 d2                	test   %dl,%dl
  801c9a:	75 f1                	jne    801c8d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca1:	eb 05                	jmp    801ca8 <strchr+0x32>
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb4:	0f b6 10             	movzbl (%eax),%edx
  801cb7:	84 d2                	test   %dl,%dl
  801cb9:	74 14                	je     801ccf <strfind+0x25>
		if (*s == c)
  801cbb:	38 ca                	cmp    %cl,%dl
  801cbd:	75 06                	jne    801cc5 <strfind+0x1b>
  801cbf:	eb 0e                	jmp    801ccf <strfind+0x25>
  801cc1:	38 ca                	cmp    %cl,%dl
  801cc3:	74 0a                	je     801ccf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801cc5:	83 c0 01             	add    $0x1,%eax
  801cc8:	0f b6 10             	movzbl (%eax),%edx
  801ccb:	84 d2                	test   %dl,%dl
  801ccd:	75 f2                	jne    801cc1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    

00801cd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801cda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801cdd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ce0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ce9:	85 c9                	test   %ecx,%ecx
  801ceb:	74 30                	je     801d1d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ced:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cf3:	75 25                	jne    801d1a <memset+0x49>
  801cf5:	f6 c1 03             	test   $0x3,%cl
  801cf8:	75 20                	jne    801d1a <memset+0x49>
		c &= 0xFF;
  801cfa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cfd:	89 d3                	mov    %edx,%ebx
  801cff:	c1 e3 08             	shl    $0x8,%ebx
  801d02:	89 d6                	mov    %edx,%esi
  801d04:	c1 e6 18             	shl    $0x18,%esi
  801d07:	89 d0                	mov    %edx,%eax
  801d09:	c1 e0 10             	shl    $0x10,%eax
  801d0c:	09 f0                	or     %esi,%eax
  801d0e:	09 d0                	or     %edx,%eax
  801d10:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d12:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801d15:	fc                   	cld    
  801d16:	f3 ab                	rep stos %eax,%es:(%edi)
  801d18:	eb 03                	jmp    801d1d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d1a:	fc                   	cld    
  801d1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d1d:	89 f8                	mov    %edi,%eax
  801d1f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d22:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d25:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d28:	89 ec                	mov    %ebp,%esp
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 08             	sub    $0x8,%esp
  801d32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d35:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d41:	39 c6                	cmp    %eax,%esi
  801d43:	73 36                	jae    801d7b <memmove+0x4f>
  801d45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d48:	39 d0                	cmp    %edx,%eax
  801d4a:	73 2f                	jae    801d7b <memmove+0x4f>
		s += n;
		d += n;
  801d4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4f:	f6 c2 03             	test   $0x3,%dl
  801d52:	75 1b                	jne    801d6f <memmove+0x43>
  801d54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d5a:	75 13                	jne    801d6f <memmove+0x43>
  801d5c:	f6 c1 03             	test   $0x3,%cl
  801d5f:	75 0e                	jne    801d6f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d61:	83 ef 04             	sub    $0x4,%edi
  801d64:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d67:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801d6a:	fd                   	std    
  801d6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d6d:	eb 09                	jmp    801d78 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d6f:	83 ef 01             	sub    $0x1,%edi
  801d72:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d75:	fd                   	std    
  801d76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d78:	fc                   	cld    
  801d79:	eb 20                	jmp    801d9b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d7b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d81:	75 13                	jne    801d96 <memmove+0x6a>
  801d83:	a8 03                	test   $0x3,%al
  801d85:	75 0f                	jne    801d96 <memmove+0x6a>
  801d87:	f6 c1 03             	test   $0x3,%cl
  801d8a:	75 0a                	jne    801d96 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d8c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801d8f:	89 c7                	mov    %eax,%edi
  801d91:	fc                   	cld    
  801d92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d94:	eb 05                	jmp    801d9b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d96:	89 c7                	mov    %eax,%edi
  801d98:	fc                   	cld    
  801d99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d9b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d9e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801da1:	89 ec                	mov    %ebp,%esp
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801dab:	8b 45 10             	mov    0x10(%ebp),%eax
  801dae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	89 04 24             	mov    %eax,(%esp)
  801dbf:	e8 68 ff ff ff       	call   801d2c <memmove>
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	57                   	push   %edi
  801dca:	56                   	push   %esi
  801dcb:	53                   	push   %ebx
  801dcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801dcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dd2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dda:	85 ff                	test   %edi,%edi
  801ddc:	74 37                	je     801e15 <memcmp+0x4f>
		if (*s1 != *s2)
  801dde:	0f b6 03             	movzbl (%ebx),%eax
  801de1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801de4:	83 ef 01             	sub    $0x1,%edi
  801de7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  801dec:	38 c8                	cmp    %cl,%al
  801dee:	74 1c                	je     801e0c <memcmp+0x46>
  801df0:	eb 10                	jmp    801e02 <memcmp+0x3c>
  801df2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801df7:	83 c2 01             	add    $0x1,%edx
  801dfa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  801dfe:	38 c8                	cmp    %cl,%al
  801e00:	74 0a                	je     801e0c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801e02:	0f b6 c0             	movzbl %al,%eax
  801e05:	0f b6 c9             	movzbl %cl,%ecx
  801e08:	29 c8                	sub    %ecx,%eax
  801e0a:	eb 09                	jmp    801e15 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e0c:	39 fa                	cmp    %edi,%edx
  801e0e:	75 e2                	jne    801df2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    

00801e1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e20:	89 c2                	mov    %eax,%edx
  801e22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e25:	39 d0                	cmp    %edx,%eax
  801e27:	73 19                	jae    801e42 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e29:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801e2d:	38 08                	cmp    %cl,(%eax)
  801e2f:	75 06                	jne    801e37 <memfind+0x1d>
  801e31:	eb 0f                	jmp    801e42 <memfind+0x28>
  801e33:	38 08                	cmp    %cl,(%eax)
  801e35:	74 0b                	je     801e42 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e37:	83 c0 01             	add    $0x1,%eax
  801e3a:	39 d0                	cmp    %edx,%eax
  801e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e40:	75 f1                	jne    801e33 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	57                   	push   %edi
  801e48:	56                   	push   %esi
  801e49:	53                   	push   %ebx
  801e4a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e50:	0f b6 02             	movzbl (%edx),%eax
  801e53:	3c 20                	cmp    $0x20,%al
  801e55:	74 04                	je     801e5b <strtol+0x17>
  801e57:	3c 09                	cmp    $0x9,%al
  801e59:	75 0e                	jne    801e69 <strtol+0x25>
		s++;
  801e5b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e5e:	0f b6 02             	movzbl (%edx),%eax
  801e61:	3c 20                	cmp    $0x20,%al
  801e63:	74 f6                	je     801e5b <strtol+0x17>
  801e65:	3c 09                	cmp    $0x9,%al
  801e67:	74 f2                	je     801e5b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e69:	3c 2b                	cmp    $0x2b,%al
  801e6b:	75 0a                	jne    801e77 <strtol+0x33>
		s++;
  801e6d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e70:	bf 00 00 00 00       	mov    $0x0,%edi
  801e75:	eb 10                	jmp    801e87 <strtol+0x43>
  801e77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e7c:	3c 2d                	cmp    $0x2d,%al
  801e7e:	75 07                	jne    801e87 <strtol+0x43>
		s++, neg = 1;
  801e80:	83 c2 01             	add    $0x1,%edx
  801e83:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e87:	85 db                	test   %ebx,%ebx
  801e89:	0f 94 c0             	sete   %al
  801e8c:	74 05                	je     801e93 <strtol+0x4f>
  801e8e:	83 fb 10             	cmp    $0x10,%ebx
  801e91:	75 15                	jne    801ea8 <strtol+0x64>
  801e93:	80 3a 30             	cmpb   $0x30,(%edx)
  801e96:	75 10                	jne    801ea8 <strtol+0x64>
  801e98:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e9c:	75 0a                	jne    801ea8 <strtol+0x64>
		s += 2, base = 16;
  801e9e:	83 c2 02             	add    $0x2,%edx
  801ea1:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ea6:	eb 13                	jmp    801ebb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  801ea8:	84 c0                	test   %al,%al
  801eaa:	74 0f                	je     801ebb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801eac:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eb1:	80 3a 30             	cmpb   $0x30,(%edx)
  801eb4:	75 05                	jne    801ebb <strtol+0x77>
		s++, base = 8;
  801eb6:	83 c2 01             	add    $0x1,%edx
  801eb9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ec2:	0f b6 0a             	movzbl (%edx),%ecx
  801ec5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801ec8:	80 fb 09             	cmp    $0x9,%bl
  801ecb:	77 08                	ja     801ed5 <strtol+0x91>
			dig = *s - '0';
  801ecd:	0f be c9             	movsbl %cl,%ecx
  801ed0:	83 e9 30             	sub    $0x30,%ecx
  801ed3:	eb 1e                	jmp    801ef3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  801ed5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801ed8:	80 fb 19             	cmp    $0x19,%bl
  801edb:	77 08                	ja     801ee5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  801edd:	0f be c9             	movsbl %cl,%ecx
  801ee0:	83 e9 57             	sub    $0x57,%ecx
  801ee3:	eb 0e                	jmp    801ef3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  801ee5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801ee8:	80 fb 19             	cmp    $0x19,%bl
  801eeb:	77 14                	ja     801f01 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801eed:	0f be c9             	movsbl %cl,%ecx
  801ef0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ef3:	39 f1                	cmp    %esi,%ecx
  801ef5:	7d 0e                	jge    801f05 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801ef7:	83 c2 01             	add    $0x1,%edx
  801efa:	0f af c6             	imul   %esi,%eax
  801efd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801eff:	eb c1                	jmp    801ec2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801f01:	89 c1                	mov    %eax,%ecx
  801f03:	eb 02                	jmp    801f07 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f05:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801f07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f0b:	74 05                	je     801f12 <strtol+0xce>
		*endptr = (char *) s;
  801f0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f10:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801f12:	89 ca                	mov    %ecx,%edx
  801f14:	f7 da                	neg    %edx
  801f16:	85 ff                	test   %edi,%edi
  801f18:	0f 45 c2             	cmovne %edx,%eax
}
  801f1b:	5b                   	pop    %ebx
  801f1c:	5e                   	pop    %esi
  801f1d:	5f                   	pop    %edi
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    

00801f20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	83 ec 10             	sub    $0x10,%esp
  801f28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801f31:	85 db                	test   %ebx,%ebx
  801f33:	74 06                	je     801f3b <ipc_recv+0x1b>
  801f35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  801f3b:	85 f6                	test   %esi,%esi
  801f3d:	74 06                	je     801f45 <ipc_recv+0x25>
  801f3f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  801f45:	85 c0                	test   %eax,%eax
  801f47:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801f4c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 12 e5 ff ff       	call   800469 <sys_ipc_recv>
    if (ret) return ret;
  801f57:	85 c0                	test   %eax,%eax
  801f59:	75 24                	jne    801f7f <ipc_recv+0x5f>
    if (from_env_store)
  801f5b:	85 db                	test   %ebx,%ebx
  801f5d:	74 0a                	je     801f69 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  801f5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f64:	8b 40 74             	mov    0x74(%eax),%eax
  801f67:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  801f69:	85 f6                	test   %esi,%esi
  801f6b:	74 0a                	je     801f77 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  801f6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f72:	8b 40 78             	mov    0x78(%eax),%eax
  801f75:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  801f77:	a1 04 40 80 00       	mov    0x804004,%eax
  801f7c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	5b                   	pop    %ebx
  801f83:	5e                   	pop    %esi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	57                   	push   %edi
  801f8a:	56                   	push   %esi
  801f8b:	53                   	push   %ebx
  801f8c:	83 ec 1c             	sub    $0x1c,%esp
  801f8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f92:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801f98:	85 db                	test   %ebx,%ebx
  801f9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f9f:	0f 44 d8             	cmove  %eax,%ebx
  801fa2:	eb 2a                	jmp    801fce <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801fa4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa7:	74 20                	je     801fc9 <ipc_send+0x43>
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	c7 44 24 08 a0 27 80 	movl   $0x8027a0,0x8(%esp)
  801fb4:	00 
  801fb5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801fbc:	00 
  801fbd:	c7 04 24 b7 27 80 00 	movl   $0x8027b7,(%esp)
  801fc4:	e8 27 f3 ff ff       	call   8012f0 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  801fc9:	e8 02 e2 ff ff       	call   8001d0 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801fce:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fdd:	89 34 24             	mov    %esi,(%esp)
  801fe0:	e8 50 e4 ff ff       	call   800435 <sys_ipc_try_send>
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	75 bb                	jne    801fa4 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  801fe9:	83 c4 1c             	add    $0x1c,%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5e                   	pop    %esi
  801fee:	5f                   	pop    %edi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    

00801ff1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ff7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801ffc:	39 c8                	cmp    %ecx,%eax
  801ffe:	74 19                	je     802019 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802000:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802005:	89 c2                	mov    %eax,%edx
  802007:	c1 e2 07             	shl    $0x7,%edx
  80200a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802010:	8b 52 50             	mov    0x50(%edx),%edx
  802013:	39 ca                	cmp    %ecx,%edx
  802015:	75 14                	jne    80202b <ipc_find_env+0x3a>
  802017:	eb 05                	jmp    80201e <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80201e:	c1 e0 07             	shl    $0x7,%eax
  802021:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802026:	8b 40 40             	mov    0x40(%eax),%eax
  802029:	eb 0e                	jmp    802039 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80202b:	83 c0 01             	add    $0x1,%eax
  80202e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802033:	75 d0                	jne    802005 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802035:	66 b8 00 00          	mov    $0x0,%ax
}
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
	...

0080203c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802042:	89 d0                	mov    %edx,%eax
  802044:	c1 e8 16             	shr    $0x16,%eax
  802047:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80204e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802053:	f6 c1 01             	test   $0x1,%cl
  802056:	74 1d                	je     802075 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802058:	c1 ea 0c             	shr    $0xc,%edx
  80205b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802062:	f6 c2 01             	test   $0x1,%dl
  802065:	74 0e                	je     802075 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802067:	c1 ea 0c             	shr    $0xc,%edx
  80206a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802071:	ef 
  802072:	0f b7 c0             	movzwl %ax,%eax
}
  802075:	5d                   	pop    %ebp
  802076:	c3                   	ret    
	...

00802080 <__udivdi3>:
  802080:	83 ec 1c             	sub    $0x1c,%esp
  802083:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802087:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80208b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80208f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802093:	89 74 24 10          	mov    %esi,0x10(%esp)
  802097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8020a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020a5:	89 cd                	mov    %ecx,%ebp
  8020a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ab:	75 33                	jne    8020e0 <__udivdi3+0x60>
  8020ad:	39 f1                	cmp    %esi,%ecx
  8020af:	77 57                	ja     802108 <__udivdi3+0x88>
  8020b1:	85 c9                	test   %ecx,%ecx
  8020b3:	75 0b                	jne    8020c0 <__udivdi3+0x40>
  8020b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ba:	31 d2                	xor    %edx,%edx
  8020bc:	f7 f1                	div    %ecx
  8020be:	89 c1                	mov    %eax,%ecx
  8020c0:	89 f0                	mov    %esi,%eax
  8020c2:	31 d2                	xor    %edx,%edx
  8020c4:	f7 f1                	div    %ecx
  8020c6:	89 c6                	mov    %eax,%esi
  8020c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020cc:	f7 f1                	div    %ecx
  8020ce:	89 f2                	mov    %esi,%edx
  8020d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8020d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	c3                   	ret    
  8020e0:	31 d2                	xor    %edx,%edx
  8020e2:	31 c0                	xor    %eax,%eax
  8020e4:	39 f7                	cmp    %esi,%edi
  8020e6:	77 e8                	ja     8020d0 <__udivdi3+0x50>
  8020e8:	0f bd cf             	bsr    %edi,%ecx
  8020eb:	83 f1 1f             	xor    $0x1f,%ecx
  8020ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020f2:	75 2c                	jne    802120 <__udivdi3+0xa0>
  8020f4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8020f8:	76 04                	jbe    8020fe <__udivdi3+0x7e>
  8020fa:	39 f7                	cmp    %esi,%edi
  8020fc:	73 d2                	jae    8020d0 <__udivdi3+0x50>
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	b8 01 00 00 00       	mov    $0x1,%eax
  802105:	eb c9                	jmp    8020d0 <__udivdi3+0x50>
  802107:	90                   	nop
  802108:	89 f2                	mov    %esi,%edx
  80210a:	f7 f1                	div    %ecx
  80210c:	31 d2                	xor    %edx,%edx
  80210e:	8b 74 24 10          	mov    0x10(%esp),%esi
  802112:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802116:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	c3                   	ret    
  80211e:	66 90                	xchg   %ax,%ax
  802120:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802125:	b8 20 00 00 00       	mov    $0x20,%eax
  80212a:	89 ea                	mov    %ebp,%edx
  80212c:	2b 44 24 04          	sub    0x4(%esp),%eax
  802130:	d3 e7                	shl    %cl,%edi
  802132:	89 c1                	mov    %eax,%ecx
  802134:	d3 ea                	shr    %cl,%edx
  802136:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80213b:	09 fa                	or     %edi,%edx
  80213d:	89 f7                	mov    %esi,%edi
  80213f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802143:	89 f2                	mov    %esi,%edx
  802145:	8b 74 24 08          	mov    0x8(%esp),%esi
  802149:	d3 e5                	shl    %cl,%ebp
  80214b:	89 c1                	mov    %eax,%ecx
  80214d:	d3 ef                	shr    %cl,%edi
  80214f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802154:	d3 e2                	shl    %cl,%edx
  802156:	89 c1                	mov    %eax,%ecx
  802158:	d3 ee                	shr    %cl,%esi
  80215a:	09 d6                	or     %edx,%esi
  80215c:	89 fa                	mov    %edi,%edx
  80215e:	89 f0                	mov    %esi,%eax
  802160:	f7 74 24 0c          	divl   0xc(%esp)
  802164:	89 d7                	mov    %edx,%edi
  802166:	89 c6                	mov    %eax,%esi
  802168:	f7 e5                	mul    %ebp
  80216a:	39 d7                	cmp    %edx,%edi
  80216c:	72 22                	jb     802190 <__udivdi3+0x110>
  80216e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802172:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802177:	d3 e5                	shl    %cl,%ebp
  802179:	39 c5                	cmp    %eax,%ebp
  80217b:	73 04                	jae    802181 <__udivdi3+0x101>
  80217d:	39 d7                	cmp    %edx,%edi
  80217f:	74 0f                	je     802190 <__udivdi3+0x110>
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	e9 46 ff ff ff       	jmp    8020d0 <__udivdi3+0x50>
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	8d 46 ff             	lea    -0x1(%esi),%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	8b 74 24 10          	mov    0x10(%esp),%esi
  802199:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80219d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	c3                   	ret    
	...

008021b0 <__umoddi3>:
  8021b0:	83 ec 1c             	sub    $0x1c,%esp
  8021b3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8021b7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8021bb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8021bf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8021c3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8021c7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8021cb:	85 ed                	test   %ebp,%ebp
  8021cd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8021d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021d5:	89 cf                	mov    %ecx,%edi
  8021d7:	89 04 24             	mov    %eax,(%esp)
  8021da:	89 f2                	mov    %esi,%edx
  8021dc:	75 1a                	jne    8021f8 <__umoddi3+0x48>
  8021de:	39 f1                	cmp    %esi,%ecx
  8021e0:	76 4e                	jbe    802230 <__umoddi3+0x80>
  8021e2:	f7 f1                	div    %ecx
  8021e4:	89 d0                	mov    %edx,%eax
  8021e6:	31 d2                	xor    %edx,%edx
  8021e8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8021ec:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8021f0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	c3                   	ret    
  8021f8:	39 f5                	cmp    %esi,%ebp
  8021fa:	77 54                	ja     802250 <__umoddi3+0xa0>
  8021fc:	0f bd c5             	bsr    %ebp,%eax
  8021ff:	83 f0 1f             	xor    $0x1f,%eax
  802202:	89 44 24 04          	mov    %eax,0x4(%esp)
  802206:	75 60                	jne    802268 <__umoddi3+0xb8>
  802208:	3b 0c 24             	cmp    (%esp),%ecx
  80220b:	0f 87 07 01 00 00    	ja     802318 <__umoddi3+0x168>
  802211:	89 f2                	mov    %esi,%edx
  802213:	8b 34 24             	mov    (%esp),%esi
  802216:	29 ce                	sub    %ecx,%esi
  802218:	19 ea                	sbb    %ebp,%edx
  80221a:	89 34 24             	mov    %esi,(%esp)
  80221d:	8b 04 24             	mov    (%esp),%eax
  802220:	8b 74 24 10          	mov    0x10(%esp),%esi
  802224:	8b 7c 24 14          	mov    0x14(%esp),%edi
  802228:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	c3                   	ret    
  802230:	85 c9                	test   %ecx,%ecx
  802232:	75 0b                	jne    80223f <__umoddi3+0x8f>
  802234:	b8 01 00 00 00       	mov    $0x1,%eax
  802239:	31 d2                	xor    %edx,%edx
  80223b:	f7 f1                	div    %ecx
  80223d:	89 c1                	mov    %eax,%ecx
  80223f:	89 f0                	mov    %esi,%eax
  802241:	31 d2                	xor    %edx,%edx
  802243:	f7 f1                	div    %ecx
  802245:	8b 04 24             	mov    (%esp),%eax
  802248:	f7 f1                	div    %ecx
  80224a:	eb 98                	jmp    8021e4 <__umoddi3+0x34>
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 f2                	mov    %esi,%edx
  802252:	8b 74 24 10          	mov    0x10(%esp),%esi
  802256:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80225a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80225e:	83 c4 1c             	add    $0x1c,%esp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80226d:	89 e8                	mov    %ebp,%eax
  80226f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802274:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802278:	89 fa                	mov    %edi,%edx
  80227a:	d3 e0                	shl    %cl,%eax
  80227c:	89 e9                	mov    %ebp,%ecx
  80227e:	d3 ea                	shr    %cl,%edx
  802280:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802285:	09 c2                	or     %eax,%edx
  802287:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228b:	89 14 24             	mov    %edx,(%esp)
  80228e:	89 f2                	mov    %esi,%edx
  802290:	d3 e7                	shl    %cl,%edi
  802292:	89 e9                	mov    %ebp,%ecx
  802294:	d3 ea                	shr    %cl,%edx
  802296:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80229b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80229f:	d3 e6                	shl    %cl,%esi
  8022a1:	89 e9                	mov    %ebp,%ecx
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022aa:	09 f0                	or     %esi,%eax
  8022ac:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b0:	f7 34 24             	divl   (%esp)
  8022b3:	d3 e6                	shl    %cl,%esi
  8022b5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8022b9:	89 d6                	mov    %edx,%esi
  8022bb:	f7 e7                	mul    %edi
  8022bd:	39 d6                	cmp    %edx,%esi
  8022bf:	89 c1                	mov    %eax,%ecx
  8022c1:	89 d7                	mov    %edx,%edi
  8022c3:	72 3f                	jb     802304 <__umoddi3+0x154>
  8022c5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022c9:	72 35                	jb     802300 <__umoddi3+0x150>
  8022cb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cf:	29 c8                	sub    %ecx,%eax
  8022d1:	19 fe                	sbb    %edi,%esi
  8022d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	d3 e8                	shr    %cl,%eax
  8022dc:	89 e9                	mov    %ebp,%ecx
  8022de:	d3 e2                	shl    %cl,%edx
  8022e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022e5:	09 d0                	or     %edx,%eax
  8022e7:	89 f2                	mov    %esi,%edx
  8022e9:	d3 ea                	shr    %cl,%edx
  8022eb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022ef:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8022f3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8022f7:	83 c4 1c             	add    $0x1c,%esp
  8022fa:	c3                   	ret    
  8022fb:	90                   	nop
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	39 d6                	cmp    %edx,%esi
  802302:	75 c7                	jne    8022cb <__umoddi3+0x11b>
  802304:	89 d7                	mov    %edx,%edi
  802306:	89 c1                	mov    %eax,%ecx
  802308:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80230c:	1b 3c 24             	sbb    (%esp),%edi
  80230f:	eb ba                	jmp    8022cb <__umoddi3+0x11b>
  802311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802318:	39 f5                	cmp    %esi,%ebp
  80231a:	0f 82 f1 fe ff ff    	jb     802211 <__umoddi3+0x61>
  802320:	e9 f8 fe ff ff       	jmp    80221d <__umoddi3+0x6d>
