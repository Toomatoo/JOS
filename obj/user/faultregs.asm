
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 91 19 80 	movl   $0x801991,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 60 19 80 00 	movl   $0x801960,(%esp)
  80005b:	e8 97 06 00 00       	call   8006f7 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 70 19 80 	movl   $0x801970,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  80007b:	e8 77 06 00 00       	call   8006f7 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  80008d:	e8 65 06 00 00       	call   8006f7 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  8000a0:	e8 52 06 00 00       	call   8006f7 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 92 19 80 	movl   $0x801992,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  8000c7:	e8 2b 06 00 00       	call   8006f7 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  8000db:	e8 17 06 00 00       	call   8006f7 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  8000e9:	e8 09 06 00 00       	call   8006f7 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 96 19 80 	movl   $0x801996,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  800110:	e8 e2 05 00 00       	call   8006f7 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  800124:	e8 ce 05 00 00       	call   8006f7 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  800132:	e8 c0 05 00 00       	call   8006f7 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 9a 19 80 	movl   $0x80199a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  800159:	e8 99 05 00 00       	call   8006f7 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  80016d:	e8 85 05 00 00       	call   8006f7 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  80017b:	e8 77 05 00 00       	call   8006f7 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 9e 19 80 	movl   $0x80199e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  8001a2:	e8 50 05 00 00       	call   8006f7 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  8001b6:	e8 3c 05 00 00       	call   8006f7 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  8001c4:	e8 2e 05 00 00       	call   8006f7 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 a2 19 80 	movl   $0x8019a2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  8001eb:	e8 07 05 00 00       	call   8006f7 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  8001ff:	e8 f3 04 00 00       	call   8006f7 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  80020d:	e8 e5 04 00 00       	call   8006f7 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 a6 19 80 	movl   $0x8019a6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  800234:	e8 be 04 00 00       	call   8006f7 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  800248:	e8 aa 04 00 00       	call   8006f7 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  800256:	e8 9c 04 00 00       	call   8006f7 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 aa 19 80 	movl   $0x8019aa,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  80027d:	e8 75 04 00 00       	call   8006f7 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  800291:	e8 61 04 00 00       	call   8006f7 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  80029f:	e8 53 04 00 00       	call   8006f7 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ae 19 80 	movl   $0x8019ae,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  8002c6:	e8 2c 04 00 00       	call   8006f7 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  8002da:	e8 18 04 00 00       	call   8006f7 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  8002e8:	e8 0a 04 00 00       	call   8006f7 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 b5 19 80 	movl   $0x8019b5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 74 19 80 00 	movl   $0x801974,(%esp)
  80030f:	e8 e3 03 00 00       	call   8006f7 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  800323:	e8 cf 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 b9 19 80 00 	movl   $0x8019b9,(%esp)
  800336:	e8 bc 03 00 00       	call   8006f7 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  800348:	e8 aa 03 00 00       	call   8006f7 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 b9 19 80 00 	movl   $0x8019b9,(%esp)
  80035b:	e8 97 03 00 00       	call   8006f7 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 84 19 80 00 	movl   $0x801984,(%esp)
  800369:	e8 89 03 00 00       	call   8006f7 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 88 19 80 00 	movl   $0x801988,(%esp)
  800377:	e8 7b 03 00 00       	call   8006f7 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 28             	sub    $0x28,%esp
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800395:	74 27                	je     8003be <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800397:	8b 40 28             	mov    0x28(%eax),%eax
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	c7 44 24 08 20 1a 80 	movl   $0x801a20,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 c7 19 80 00 	movl   $0x8019c7,(%esp)
  8003b9:	e8 3e 02 00 00       	call   8005fc <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 a0 20 80 00    	mov    %edx,0x8020a0
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 a4 20 80 00    	mov    %edx,0x8020a4
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 a8 20 80 00    	mov    %edx,0x8020a8
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 ac 20 80 00    	mov    %edx,0x8020ac
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 b0 20 80 00    	mov    %edx,0x8020b0
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 b8 20 80 00    	mov    %edx,0x8020b8
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 bc 20 80 00    	mov    %edx,0x8020bc
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 c0 20 80 00    	mov    %edx,0x8020c0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 c4 20 80 00    	mov    %edx,0x8020c4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 c8 20 80 00       	mov    %eax,0x8020c8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 df 19 80 	movl   $0x8019df,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 ed 19 80 00 	movl   $0x8019ed,(%esp)
  80042f:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800434:	ba d8 19 80 00       	mov    $0x8019d8,%edx
  800439:	b8 20 20 80 00       	mov    $0x802020,%eax
  80043e:	e8 f1 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800443:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80044a:	00 
  80044b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045a:	e8 ed 0e 00 00       	call   80134c <sys_page_alloc>
  80045f:	85 c0                	test   %eax,%eax
  800461:	79 20                	jns    800483 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 f4 19 80 	movl   $0x8019f4,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 c7 19 80 00 	movl   $0x8019c7,(%esp)
  80047e:	e8 79 01 00 00       	call   8005fc <_panic>
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <umain>:

void
umain(int argc, char **argv)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800492:	e8 51 11 00 00       	call   8015e8 <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 44 20 80 00       	mov    %eax,0x802044
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 40 20 80 00       	mov    %eax,0x802040
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004b8:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004be:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004c4:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004ca:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004d0:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8004d6:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8004db:	89 25 48 20 80 00    	mov    %esp,0x802048
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 60 20 80 00    	mov    %edi,0x802060
  8004f1:	89 35 64 20 80 00    	mov    %esi,0x802064
  8004f7:	89 2d 68 20 80 00    	mov    %ebp,0x802068
  8004fd:	89 1d 70 20 80 00    	mov    %ebx,0x802070
  800503:	89 15 74 20 80 00    	mov    %edx,0x802074
  800509:	89 0d 78 20 80 00    	mov    %ecx,0x802078
  80050f:	a3 7c 20 80 00       	mov    %eax,0x80207c
  800514:	89 25 88 20 80 00    	mov    %esp,0x802088
  80051a:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  800520:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800526:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  80052c:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800532:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800538:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80053e:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800543:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 84 20 80 00       	mov    %eax,0x802084
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 54 1a 80 00 	movl   $0x801a54,(%esp)
  800562:	e8 90 01 00 00       	call   8006f7 <cprintf>
	after.eip = before.eip;
  800567:	a1 40 20 80 00       	mov    0x802040,%eax
  80056c:	a3 80 20 80 00       	mov    %eax,0x802080

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 07 1a 80 	movl   $0x801a07,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 18 1a 80 00 	movl   $0x801a18,(%esp)
  800580:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800585:	ba d8 19 80 00       	mov    $0x8019d8,%edx
  80058a:	b8 20 20 80 00       	mov    $0x802020,%eax
  80058f:	e8 a0 fa ff ff       	call   800034 <check_regs>
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    
	...

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005aa:	e8 3d 0d 00 00       	call   8012ec <sys_getenvid>
  8005af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b4:	c1 e0 07             	shl    $0x7,%eax
  8005b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bc:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 03                	mov    (%ebx),%eax
  8005c7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 34 24             	mov    %esi,(%esp)
  8005d3:	e8 ad fe ff ff       	call   800485 <umain>

	// exit gracefully
	exit();
  8005d8:	e8 0b 00 00 00       	call   8005e8 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    
	...

008005e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f5:	e8 95 0c 00 00       	call   80128f <sys_env_destroy>
}
  8005fa:	c9                   	leave  
  8005fb:	c3                   	ret    

008005fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800607:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80060d:	e8 da 0c 00 00       	call   8012ec <sys_getenvid>
  800612:	8b 55 0c             	mov    0xc(%ebp),%edx
  800615:	89 54 24 10          	mov    %edx,0x10(%esp)
  800619:	8b 55 08             	mov    0x8(%ebp),%edx
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80062f:	e8 c3 00 00 00       	call   8006f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800634:	89 74 24 04          	mov    %esi,0x4(%esp)
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 53 00 00 00       	call   800696 <vcprintf>
	cprintf("\n");
  800643:	c7 04 24 90 19 80 00 	movl   $0x801990,(%esp)
  80064a:	e8 a8 00 00 00       	call   8006f7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80064f:	cc                   	int3   
  800650:	eb fd                	jmp    80064f <_panic+0x53>
	...

00800654 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	53                   	push   %ebx
  800658:	83 ec 14             	sub    $0x14,%esp
  80065b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80065e:	8b 03                	mov    (%ebx),%eax
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800667:	83 c0 01             	add    $0x1,%eax
  80066a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80066c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800671:	75 19                	jne    80068c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800673:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80067a:	00 
  80067b:	8d 43 08             	lea    0x8(%ebx),%eax
  80067e:	89 04 24             	mov    %eax,(%esp)
  800681:	e8 aa 0b 00 00       	call   801230 <sys_cputs>
		b->idx = 0;
  800686:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80068c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800690:	83 c4 14             	add    $0x14,%esp
  800693:	5b                   	pop    %ebx
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80069f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006a6:	00 00 00 
	b.cnt = 0;
  8006a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	c7 04 24 54 06 80 00 	movl   $0x800654,(%esp)
  8006d2:	e8 97 01 00 00       	call   80086e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e7:	89 04 24             	mov    %eax,(%esp)
  8006ea:	e8 41 0b 00 00       	call   801230 <sys_cputs>

	return b.cnt;
}
  8006ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 87 ff ff ff       	call   800696 <vcprintf>
	va_end(ap);

	return cnt;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
  800711:	00 00                	add    %al,(%eax)
	...

00800714 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	57                   	push   %edi
  800718:	56                   	push   %esi
  800719:	53                   	push   %ebx
  80071a:	83 ec 3c             	sub    $0x3c,%esp
  80071d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800720:	89 d7                	mov    %edx,%edi
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80072e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800731:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800734:	b8 00 00 00 00       	mov    $0x0,%eax
  800739:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80073c:	72 11                	jb     80074f <printnum+0x3b>
  80073e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800741:	39 45 10             	cmp    %eax,0x10(%ebp)
  800744:	76 09                	jbe    80074f <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800746:	83 eb 01             	sub    $0x1,%ebx
  800749:	85 db                	test   %ebx,%ebx
  80074b:	7f 51                	jg     80079e <printnum+0x8a>
  80074d:	eb 5e                	jmp    8007ad <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80074f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800753:	83 eb 01             	sub    $0x1,%ebx
  800756:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80075a:	8b 45 10             	mov    0x10(%ebp),%eax
  80075d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800761:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800765:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800769:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800770:	00 
  800771:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80077a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077e:	e8 1d 0f 00 00       	call   8016a0 <__udivdi3>
  800783:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800787:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800792:	89 fa                	mov    %edi,%edx
  800794:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800797:	e8 78 ff ff ff       	call   800714 <printnum>
  80079c:	eb 0f                	jmp    8007ad <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80079e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a2:	89 34 24             	mov    %esi,(%esp)
  8007a5:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007a8:	83 eb 01             	sub    $0x1,%ebx
  8007ab:	75 f1                	jne    80079e <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007c3:	00 
  8007c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007c7:	89 04 24             	mov    %eax,(%esp)
  8007ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d1:	e8 fa 0f 00 00       	call   8017d0 <__umoddi3>
  8007d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007da:	0f be 80 a3 1a 80 00 	movsbl 0x801aa3(%eax),%eax
  8007e1:	89 04 24             	mov    %eax,(%esp)
  8007e4:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007e7:	83 c4 3c             	add    $0x3c,%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007f2:	83 fa 01             	cmp    $0x1,%edx
  8007f5:	7e 0e                	jle    800805 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007fc:	89 08                	mov    %ecx,(%eax)
  8007fe:	8b 02                	mov    (%edx),%eax
  800800:	8b 52 04             	mov    0x4(%edx),%edx
  800803:	eb 22                	jmp    800827 <getuint+0x38>
	else if (lflag)
  800805:	85 d2                	test   %edx,%edx
  800807:	74 10                	je     800819 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80080e:	89 08                	mov    %ecx,(%eax)
  800810:	8b 02                	mov    (%edx),%eax
  800812:	ba 00 00 00 00       	mov    $0x0,%edx
  800817:	eb 0e                	jmp    800827 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800819:	8b 10                	mov    (%eax),%edx
  80081b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80081e:	89 08                	mov    %ecx,(%eax)
  800820:	8b 02                	mov    (%edx),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800833:	8b 10                	mov    (%eax),%edx
  800835:	3b 50 04             	cmp    0x4(%eax),%edx
  800838:	73 0a                	jae    800844 <sprintputch+0x1b>
		*b->buf++ = ch;
  80083a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083d:	88 0a                	mov    %cl,(%edx)
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	89 10                	mov    %edx,(%eax)
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800853:	8b 45 10             	mov    0x10(%ebp),%eax
  800856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 02 00 00 00       	call   80086e <vprintfmt>
	va_end(ap);
}
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	57                   	push   %edi
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	83 ec 5c             	sub    $0x5c,%esp
  800877:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80087a:	8b 75 10             	mov    0x10(%ebp),%esi
  80087d:	eb 12                	jmp    800891 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80087f:	85 c0                	test   %eax,%eax
  800881:	0f 84 e4 04 00 00    	je     800d6b <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  800887:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088b:	89 04 24             	mov    %eax,(%esp)
  80088e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800891:	0f b6 06             	movzbl (%esi),%eax
  800894:	83 c6 01             	add    $0x1,%esi
  800897:	83 f8 25             	cmp    $0x25,%eax
  80089a:	75 e3                	jne    80087f <vprintfmt+0x11>
  80089c:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8008a0:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8008a7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008ac:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8008bb:	eb 2b                	jmp    8008e8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bd:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008c0:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8008c4:	eb 22                	jmp    8008e8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008c9:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8008cd:	eb 19                	jmp    8008e8 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8008d2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8008d9:	eb 0d                	jmp    8008e8 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008db:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8008de:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8008e1:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e8:	0f b6 06             	movzbl (%esi),%eax
  8008eb:	0f b6 d0             	movzbl %al,%edx
  8008ee:	8d 7e 01             	lea    0x1(%esi),%edi
  8008f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008f4:	83 e8 23             	sub    $0x23,%eax
  8008f7:	3c 55                	cmp    $0x55,%al
  8008f9:	0f 87 46 04 00 00    	ja     800d45 <vprintfmt+0x4d7>
  8008ff:	0f b6 c0             	movzbl %al,%eax
  800902:	ff 24 85 80 1b 80 00 	jmp    *0x801b80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800909:	83 ea 30             	sub    $0x30,%edx
  80090c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  80090f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800913:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800919:	83 fa 09             	cmp    $0x9,%edx
  80091c:	77 4a                	ja     800968 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800921:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800924:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800927:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80092b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80092e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800931:	83 fa 09             	cmp    $0x9,%edx
  800934:	76 eb                	jbe    800921 <vprintfmt+0xb3>
  800936:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800939:	eb 2d                	jmp    800968 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	8d 50 04             	lea    0x4(%eax),%edx
  800941:	89 55 14             	mov    %edx,0x14(%ebp)
  800944:	8b 00                	mov    (%eax),%eax
  800946:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800949:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094c:	eb 1a                	jmp    800968 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800951:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800955:	79 91                	jns    8008e8 <vprintfmt+0x7a>
  800957:	e9 73 ff ff ff       	jmp    8008cf <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80095f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  800966:	eb 80                	jmp    8008e8 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800968:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80096c:	0f 89 76 ff ff ff    	jns    8008e8 <vprintfmt+0x7a>
  800972:	e9 64 ff ff ff       	jmp    8008db <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800977:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80097d:	e9 66 ff ff ff       	jmp    8008e8 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 50 04             	lea    0x4(%eax),%edx
  800988:	89 55 14             	mov    %edx,0x14(%ebp)
  80098b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098f:	8b 00                	mov    (%eax),%eax
  800991:	89 04 24             	mov    %eax,(%esp)
  800994:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800997:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80099a:	e9 f2 fe ff ff       	jmp    800891 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  80099f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8009a3:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8009a6:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8009aa:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8009ad:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8009b1:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8009b4:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8009b7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8009bb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8009be:	80 f9 09             	cmp    $0x9,%cl
  8009c1:	77 1d                	ja     8009e0 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8009c3:	0f be c0             	movsbl %al,%eax
  8009c6:	6b c0 64             	imul   $0x64,%eax,%eax
  8009c9:	0f be d2             	movsbl %dl,%edx
  8009cc:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8009cf:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8009d6:	a3 04 20 80 00       	mov    %eax,0x802004
  8009db:	e9 b1 fe ff ff       	jmp    800891 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8009e0:	c7 44 24 04 bb 1a 80 	movl   $0x801abb,0x4(%esp)
  8009e7:	00 
  8009e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009eb:	89 04 24             	mov    %eax,(%esp)
  8009ee:	e8 18 05 00 00       	call   800f0b <strcmp>
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	75 0f                	jne    800a06 <vprintfmt+0x198>
  8009f7:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8009fe:	00 00 00 
  800a01:	e9 8b fe ff ff       	jmp    800891 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800a06:	c7 44 24 04 bf 1a 80 	movl   $0x801abf,0x4(%esp)
  800a0d:	00 
  800a0e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800a11:	89 14 24             	mov    %edx,(%esp)
  800a14:	e8 f2 04 00 00       	call   800f0b <strcmp>
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	75 0f                	jne    800a2c <vprintfmt+0x1be>
  800a1d:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  800a24:	00 00 00 
  800a27:	e9 65 fe ff ff       	jmp    800891 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800a2c:	c7 44 24 04 c3 1a 80 	movl   $0x801ac3,0x4(%esp)
  800a33:	00 
  800a34:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800a37:	89 0c 24             	mov    %ecx,(%esp)
  800a3a:	e8 cc 04 00 00       	call   800f0b <strcmp>
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	75 0f                	jne    800a52 <vprintfmt+0x1e4>
  800a43:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  800a4a:	00 00 00 
  800a4d:	e9 3f fe ff ff       	jmp    800891 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800a52:	c7 44 24 04 c7 1a 80 	movl   $0x801ac7,0x4(%esp)
  800a59:	00 
  800a5a:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800a5d:	89 3c 24             	mov    %edi,(%esp)
  800a60:	e8 a6 04 00 00       	call   800f0b <strcmp>
  800a65:	85 c0                	test   %eax,%eax
  800a67:	75 0f                	jne    800a78 <vprintfmt+0x20a>
  800a69:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800a70:	00 00 00 
  800a73:	e9 19 fe ff ff       	jmp    800891 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800a78:	c7 44 24 04 cb 1a 80 	movl   $0x801acb,0x4(%esp)
  800a7f:	00 
  800a80:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 80 04 00 00       	call   800f0b <strcmp>
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	75 0f                	jne    800a9e <vprintfmt+0x230>
  800a8f:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  800a96:	00 00 00 
  800a99:	e9 f3 fd ff ff       	jmp    800891 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800a9e:	c7 44 24 04 cf 1a 80 	movl   $0x801acf,0x4(%esp)
  800aa5:	00 
  800aa6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800aa9:	89 14 24             	mov    %edx,(%esp)
  800aac:	e8 5a 04 00 00       	call   800f0b <strcmp>
  800ab1:	83 f8 01             	cmp    $0x1,%eax
  800ab4:	19 c0                	sbb    %eax,%eax
  800ab6:	f7 d0                	not    %eax
  800ab8:	83 c0 08             	add    $0x8,%eax
  800abb:	a3 04 20 80 00       	mov    %eax,0x802004
  800ac0:	e9 cc fd ff ff       	jmp    800891 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8d 50 04             	lea    0x4(%eax),%edx
  800acb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ace:	8b 00                	mov    (%eax),%eax
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	c1 fa 1f             	sar    $0x1f,%edx
  800ad5:	31 d0                	xor    %edx,%eax
  800ad7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ad9:	83 f8 08             	cmp    $0x8,%eax
  800adc:	7f 0b                	jg     800ae9 <vprintfmt+0x27b>
  800ade:	8b 14 85 e0 1c 80 00 	mov    0x801ce0(,%eax,4),%edx
  800ae5:	85 d2                	test   %edx,%edx
  800ae7:	75 23                	jne    800b0c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800ae9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aed:	c7 44 24 08 d3 1a 80 	movl   $0x801ad3,0x8(%esp)
  800af4:	00 
  800af5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afc:	89 3c 24             	mov    %edi,(%esp)
  800aff:	e8 42 fd ff ff       	call   800846 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b04:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b07:	e9 85 fd ff ff       	jmp    800891 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b0c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b10:	c7 44 24 08 dc 1a 80 	movl   $0x801adc,0x8(%esp)
  800b17:	00 
  800b18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1f:	89 3c 24             	mov    %edi,(%esp)
  800b22:	e8 1f fd ff ff       	call   800846 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b27:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b2a:	e9 62 fd ff ff       	jmp    800891 <vprintfmt+0x23>
  800b2f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800b32:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b35:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 50 04             	lea    0x4(%eax),%edx
  800b3e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b41:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800b43:	85 f6                	test   %esi,%esi
  800b45:	b8 b4 1a 80 00       	mov    $0x801ab4,%eax
  800b4a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800b4d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800b51:	7e 06                	jle    800b59 <vprintfmt+0x2eb>
  800b53:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800b57:	75 13                	jne    800b6c <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b59:	0f be 06             	movsbl (%esi),%eax
  800b5c:	83 c6 01             	add    $0x1,%esi
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	0f 85 94 00 00 00    	jne    800bfb <vprintfmt+0x38d>
  800b67:	e9 81 00 00 00       	jmp    800bed <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b6c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b70:	89 34 24             	mov    %esi,(%esp)
  800b73:	e8 a3 02 00 00       	call   800e1b <strnlen>
  800b78:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800b7b:	29 c2                	sub    %eax,%edx
  800b7d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800b80:	85 d2                	test   %edx,%edx
  800b82:	7e d5                	jle    800b59 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800b84:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b88:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800b8b:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	89 cf                	mov    %ecx,%edi
  800b92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b96:	89 3c 24             	mov    %edi,(%esp)
  800b99:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b9c:	83 ee 01             	sub    $0x1,%esi
  800b9f:	75 f1                	jne    800b92 <vprintfmt+0x324>
  800ba1:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800ba4:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800ba7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800baa:	eb ad                	jmp    800b59 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800bac:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800bb0:	74 1b                	je     800bcd <vprintfmt+0x35f>
  800bb2:	8d 50 e0             	lea    -0x20(%eax),%edx
  800bb5:	83 fa 5e             	cmp    $0x5e,%edx
  800bb8:	76 13                	jbe    800bcd <vprintfmt+0x35f>
					putch('?', putdat);
  800bba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bc8:	ff 55 08             	call   *0x8(%ebp)
  800bcb:	eb 0d                	jmp    800bda <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800bcd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bd0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bd4:	89 04 24             	mov    %eax,(%esp)
  800bd7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bda:	83 eb 01             	sub    $0x1,%ebx
  800bdd:	0f be 06             	movsbl (%esi),%eax
  800be0:	83 c6 01             	add    $0x1,%esi
  800be3:	85 c0                	test   %eax,%eax
  800be5:	75 1a                	jne    800c01 <vprintfmt+0x393>
  800be7:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800bea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bed:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bf0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800bf4:	7f 1c                	jg     800c12 <vprintfmt+0x3a4>
  800bf6:	e9 96 fc ff ff       	jmp    800891 <vprintfmt+0x23>
  800bfb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800bfe:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c01:	85 ff                	test   %edi,%edi
  800c03:	78 a7                	js     800bac <vprintfmt+0x33e>
  800c05:	83 ef 01             	sub    $0x1,%edi
  800c08:	79 a2                	jns    800bac <vprintfmt+0x33e>
  800c0a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800c0d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c10:	eb db                	jmp    800bed <vprintfmt+0x37f>
  800c12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c15:	89 de                	mov    %ebx,%esi
  800c17:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c1e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c25:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c27:	83 eb 01             	sub    $0x1,%ebx
  800c2a:	75 ee                	jne    800c1a <vprintfmt+0x3ac>
  800c2c:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c2e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800c31:	e9 5b fc ff ff       	jmp    800891 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c36:	83 f9 01             	cmp    $0x1,%ecx
  800c39:	7e 10                	jle    800c4b <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800c3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3e:	8d 50 08             	lea    0x8(%eax),%edx
  800c41:	89 55 14             	mov    %edx,0x14(%ebp)
  800c44:	8b 30                	mov    (%eax),%esi
  800c46:	8b 78 04             	mov    0x4(%eax),%edi
  800c49:	eb 26                	jmp    800c71 <vprintfmt+0x403>
	else if (lflag)
  800c4b:	85 c9                	test   %ecx,%ecx
  800c4d:	74 12                	je     800c61 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800c4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c52:	8d 50 04             	lea    0x4(%eax),%edx
  800c55:	89 55 14             	mov    %edx,0x14(%ebp)
  800c58:	8b 30                	mov    (%eax),%esi
  800c5a:	89 f7                	mov    %esi,%edi
  800c5c:	c1 ff 1f             	sar    $0x1f,%edi
  800c5f:	eb 10                	jmp    800c71 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800c61:	8b 45 14             	mov    0x14(%ebp),%eax
  800c64:	8d 50 04             	lea    0x4(%eax),%edx
  800c67:	89 55 14             	mov    %edx,0x14(%ebp)
  800c6a:	8b 30                	mov    (%eax),%esi
  800c6c:	89 f7                	mov    %esi,%edi
  800c6e:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c71:	85 ff                	test   %edi,%edi
  800c73:	78 0e                	js     800c83 <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c75:	89 f0                	mov    %esi,%eax
  800c77:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c79:	be 0a 00 00 00       	mov    $0xa,%esi
  800c7e:	e9 84 00 00 00       	jmp    800d07 <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800c83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c87:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c8e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c91:	89 f0                	mov    %esi,%eax
  800c93:	89 fa                	mov    %edi,%edx
  800c95:	f7 d8                	neg    %eax
  800c97:	83 d2 00             	adc    $0x0,%edx
  800c9a:	f7 da                	neg    %edx
			}
			base = 10;
  800c9c:	be 0a 00 00 00       	mov    $0xa,%esi
  800ca1:	eb 64                	jmp    800d07 <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ca3:	89 ca                	mov    %ecx,%edx
  800ca5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca8:	e8 42 fb ff ff       	call   8007ef <getuint>
			base = 10;
  800cad:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800cb2:	eb 53                	jmp    800d07 <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800cb4:	89 ca                	mov    %ecx,%edx
  800cb6:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb9:	e8 31 fb ff ff       	call   8007ef <getuint>
    			base = 8;
  800cbe:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800cc3:	eb 42                	jmp    800d07 <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800cc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cd0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800cde:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ce1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce4:	8d 50 04             	lea    0x4(%eax),%edx
  800ce7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cea:	8b 00                	mov    (%eax),%eax
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cf1:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800cf6:	eb 0f                	jmp    800d07 <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cf8:	89 ca                	mov    %ecx,%edx
  800cfa:	8d 45 14             	lea    0x14(%ebp),%eax
  800cfd:	e8 ed fa ff ff       	call   8007ef <getuint>
			base = 16;
  800d02:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d07:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800d0b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d0f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d12:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d16:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d1a:	89 04 24             	mov    %eax,(%esp)
  800d1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d21:	89 da                	mov    %ebx,%edx
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	e8 e9 f9 ff ff       	call   800714 <printnum>
			break;
  800d2b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800d2e:	e9 5e fb ff ff       	jmp    800891 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d37:	89 14 24             	mov    %edx,(%esp)
  800d3a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d40:	e9 4c fb ff ff       	jmp    800891 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d49:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d50:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d53:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d57:	0f 84 34 fb ff ff    	je     800891 <vprintfmt+0x23>
  800d5d:	83 ee 01             	sub    $0x1,%esi
  800d60:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d64:	75 f7                	jne    800d5d <vprintfmt+0x4ef>
  800d66:	e9 26 fb ff ff       	jmp    800891 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800d6b:	83 c4 5c             	add    $0x5c,%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 28             	sub    $0x28,%esp
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d82:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d86:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	74 30                	je     800dc4 <vsnprintf+0x51>
  800d94:	85 d2                	test   %edx,%edx
  800d96:	7e 2c                	jle    800dc4 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d98:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800da2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dad:	c7 04 24 29 08 80 00 	movl   $0x800829,(%esp)
  800db4:	e8 b5 fa ff ff       	call   80086e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800db9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dbc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc2:	eb 05                	jmp    800dc9 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800dc4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    

00800dcb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800dd1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800dd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	89 04 24             	mov    %eax,(%esp)
  800dec:	e8 82 ff ff ff       	call   800d73 <vsnprintf>
	va_end(ap);

	return rc;
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
	...

00800e00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	80 3a 00             	cmpb   $0x0,(%edx)
  800e0e:	74 09                	je     800e19 <strlen+0x19>
		n++;
  800e10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e17:	75 f7                	jne    800e10 <strlen+0x10>
		n++;
	return n;
}
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	53                   	push   %ebx
  800e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2a:	85 c9                	test   %ecx,%ecx
  800e2c:	74 1a                	je     800e48 <strnlen+0x2d>
  800e2e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800e31:	74 15                	je     800e48 <strnlen+0x2d>
  800e33:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800e38:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e3a:	39 ca                	cmp    %ecx,%edx
  800e3c:	74 0a                	je     800e48 <strnlen+0x2d>
  800e3e:	83 c2 01             	add    $0x1,%edx
  800e41:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800e46:	75 f0                	jne    800e38 <strnlen+0x1d>
		n++;
	return n;
}
  800e48:	5b                   	pop    %ebx
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	53                   	push   %ebx
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e55:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e5e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e61:	83 c2 01             	add    $0x1,%edx
  800e64:	84 c9                	test   %cl,%cl
  800e66:	75 f2                	jne    800e5a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e68:	5b                   	pop    %ebx
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e75:	89 1c 24             	mov    %ebx,(%esp)
  800e78:	e8 83 ff ff ff       	call   800e00 <strlen>
	strcpy(dst + len, src);
  800e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e80:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e84:	01 d8                	add    %ebx,%eax
  800e86:	89 04 24             	mov    %eax,(%esp)
  800e89:	e8 bd ff ff ff       	call   800e4b <strcpy>
	return dst;
}
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	83 c4 08             	add    $0x8,%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ea4:	85 f6                	test   %esi,%esi
  800ea6:	74 18                	je     800ec0 <strncpy+0x2a>
  800ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800ead:	0f b6 1a             	movzbl (%edx),%ebx
  800eb0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800eb3:	80 3a 01             	cmpb   $0x1,(%edx)
  800eb6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800eb9:	83 c1 01             	add    $0x1,%ecx
  800ebc:	39 f1                	cmp    %esi,%ecx
  800ebe:	75 ed                	jne    800ead <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
  800eca:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ecd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed0:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ed3:	89 f8                	mov    %edi,%eax
  800ed5:	85 f6                	test   %esi,%esi
  800ed7:	74 2b                	je     800f04 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800ed9:	83 fe 01             	cmp    $0x1,%esi
  800edc:	74 23                	je     800f01 <strlcpy+0x3d>
  800ede:	0f b6 0b             	movzbl (%ebx),%ecx
  800ee1:	84 c9                	test   %cl,%cl
  800ee3:	74 1c                	je     800f01 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800ee5:	83 ee 02             	sub    $0x2,%esi
  800ee8:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800eed:	88 08                	mov    %cl,(%eax)
  800eef:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ef2:	39 f2                	cmp    %esi,%edx
  800ef4:	74 0b                	je     800f01 <strlcpy+0x3d>
  800ef6:	83 c2 01             	add    $0x1,%edx
  800ef9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800efd:	84 c9                	test   %cl,%cl
  800eff:	75 ec                	jne    800eed <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800f01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f04:	29 f8                	sub    %edi,%eax
}
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f11:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f14:	0f b6 01             	movzbl (%ecx),%eax
  800f17:	84 c0                	test   %al,%al
  800f19:	74 16                	je     800f31 <strcmp+0x26>
  800f1b:	3a 02                	cmp    (%edx),%al
  800f1d:	75 12                	jne    800f31 <strcmp+0x26>
		p++, q++;
  800f1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f22:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800f26:	84 c0                	test   %al,%al
  800f28:	74 07                	je     800f31 <strcmp+0x26>
  800f2a:	83 c1 01             	add    $0x1,%ecx
  800f2d:	3a 02                	cmp    (%edx),%al
  800f2f:	74 ee                	je     800f1f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f31:	0f b6 c0             	movzbl %al,%eax
  800f34:	0f b6 12             	movzbl (%edx),%edx
  800f37:	29 d0                	sub    %edx,%eax
}
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	53                   	push   %ebx
  800f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f4d:	85 d2                	test   %edx,%edx
  800f4f:	74 28                	je     800f79 <strncmp+0x3e>
  800f51:	0f b6 01             	movzbl (%ecx),%eax
  800f54:	84 c0                	test   %al,%al
  800f56:	74 24                	je     800f7c <strncmp+0x41>
  800f58:	3a 03                	cmp    (%ebx),%al
  800f5a:	75 20                	jne    800f7c <strncmp+0x41>
  800f5c:	83 ea 01             	sub    $0x1,%edx
  800f5f:	74 13                	je     800f74 <strncmp+0x39>
		n--, p++, q++;
  800f61:	83 c1 01             	add    $0x1,%ecx
  800f64:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f67:	0f b6 01             	movzbl (%ecx),%eax
  800f6a:	84 c0                	test   %al,%al
  800f6c:	74 0e                	je     800f7c <strncmp+0x41>
  800f6e:	3a 03                	cmp    (%ebx),%al
  800f70:	74 ea                	je     800f5c <strncmp+0x21>
  800f72:	eb 08                	jmp    800f7c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f79:	5b                   	pop    %ebx
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f7c:	0f b6 01             	movzbl (%ecx),%eax
  800f7f:	0f b6 13             	movzbl (%ebx),%edx
  800f82:	29 d0                	sub    %edx,%eax
  800f84:	eb f3                	jmp    800f79 <strncmp+0x3e>

00800f86 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f90:	0f b6 10             	movzbl (%eax),%edx
  800f93:	84 d2                	test   %dl,%dl
  800f95:	74 1c                	je     800fb3 <strchr+0x2d>
		if (*s == c)
  800f97:	38 ca                	cmp    %cl,%dl
  800f99:	75 09                	jne    800fa4 <strchr+0x1e>
  800f9b:	eb 1b                	jmp    800fb8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f9d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800fa0:	38 ca                	cmp    %cl,%dl
  800fa2:	74 14                	je     800fb8 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fa4:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800fa8:	84 d2                	test   %dl,%dl
  800faa:	75 f1                	jne    800f9d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	eb 05                	jmp    800fb8 <strchr+0x32>
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fc4:	0f b6 10             	movzbl (%eax),%edx
  800fc7:	84 d2                	test   %dl,%dl
  800fc9:	74 14                	je     800fdf <strfind+0x25>
		if (*s == c)
  800fcb:	38 ca                	cmp    %cl,%dl
  800fcd:	75 06                	jne    800fd5 <strfind+0x1b>
  800fcf:	eb 0e                	jmp    800fdf <strfind+0x25>
  800fd1:	38 ca                	cmp    %cl,%dl
  800fd3:	74 0a                	je     800fdf <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800fd5:	83 c0 01             	add    $0x1,%eax
  800fd8:	0f b6 10             	movzbl (%eax),%edx
  800fdb:	84 d2                	test   %dl,%dl
  800fdd:	75 f2                	jne    800fd1 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fed:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ff0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ff9:	85 c9                	test   %ecx,%ecx
  800ffb:	74 30                	je     80102d <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ffd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801003:	75 25                	jne    80102a <memset+0x49>
  801005:	f6 c1 03             	test   $0x3,%cl
  801008:	75 20                	jne    80102a <memset+0x49>
		c &= 0xFF;
  80100a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80100d:	89 d3                	mov    %edx,%ebx
  80100f:	c1 e3 08             	shl    $0x8,%ebx
  801012:	89 d6                	mov    %edx,%esi
  801014:	c1 e6 18             	shl    $0x18,%esi
  801017:	89 d0                	mov    %edx,%eax
  801019:	c1 e0 10             	shl    $0x10,%eax
  80101c:	09 f0                	or     %esi,%eax
  80101e:	09 d0                	or     %edx,%eax
  801020:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801022:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801025:	fc                   	cld    
  801026:	f3 ab                	rep stos %eax,%es:(%edi)
  801028:	eb 03                	jmp    80102d <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80102a:	fc                   	cld    
  80102b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80102d:	89 f8                	mov    %edi,%eax
  80102f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801032:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801035:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801038:	89 ec                	mov    %ebp,%esp
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801045:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801048:	8b 45 08             	mov    0x8(%ebp),%eax
  80104b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80104e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801051:	39 c6                	cmp    %eax,%esi
  801053:	73 36                	jae    80108b <memmove+0x4f>
  801055:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801058:	39 d0                	cmp    %edx,%eax
  80105a:	73 2f                	jae    80108b <memmove+0x4f>
		s += n;
		d += n;
  80105c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80105f:	f6 c2 03             	test   $0x3,%dl
  801062:	75 1b                	jne    80107f <memmove+0x43>
  801064:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80106a:	75 13                	jne    80107f <memmove+0x43>
  80106c:	f6 c1 03             	test   $0x3,%cl
  80106f:	75 0e                	jne    80107f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801071:	83 ef 04             	sub    $0x4,%edi
  801074:	8d 72 fc             	lea    -0x4(%edx),%esi
  801077:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80107a:	fd                   	std    
  80107b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80107d:	eb 09                	jmp    801088 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80107f:	83 ef 01             	sub    $0x1,%edi
  801082:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801085:	fd                   	std    
  801086:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801088:	fc                   	cld    
  801089:	eb 20                	jmp    8010ab <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80108b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801091:	75 13                	jne    8010a6 <memmove+0x6a>
  801093:	a8 03                	test   $0x3,%al
  801095:	75 0f                	jne    8010a6 <memmove+0x6a>
  801097:	f6 c1 03             	test   $0x3,%cl
  80109a:	75 0a                	jne    8010a6 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80109c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80109f:	89 c7                	mov    %eax,%edi
  8010a1:	fc                   	cld    
  8010a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010a4:	eb 05                	jmp    8010ab <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010a6:	89 c7                	mov    %eax,%edi
  8010a8:	fc                   	cld    
  8010a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b1:	89 ec                	mov    %ebp,%esp
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8010bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8010be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	89 04 24             	mov    %eax,(%esp)
  8010cf:	e8 68 ff ff ff       	call   80103c <memmove>
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
  8010dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e2:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010e5:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010ea:	85 ff                	test   %edi,%edi
  8010ec:	74 37                	je     801125 <memcmp+0x4f>
		if (*s1 != *s2)
  8010ee:	0f b6 03             	movzbl (%ebx),%eax
  8010f1:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010f4:	83 ef 01             	sub    $0x1,%edi
  8010f7:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8010fc:	38 c8                	cmp    %cl,%al
  8010fe:	74 1c                	je     80111c <memcmp+0x46>
  801100:	eb 10                	jmp    801112 <memcmp+0x3c>
  801102:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  801107:	83 c2 01             	add    $0x1,%edx
  80110a:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  80110e:	38 c8                	cmp    %cl,%al
  801110:	74 0a                	je     80111c <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  801112:	0f b6 c0             	movzbl %al,%eax
  801115:	0f b6 c9             	movzbl %cl,%ecx
  801118:	29 c8                	sub    %ecx,%eax
  80111a:	eb 09                	jmp    801125 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80111c:	39 fa                	cmp    %edi,%edx
  80111e:	75 e2                	jne    801102 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801130:	89 c2                	mov    %eax,%edx
  801132:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801135:	39 d0                	cmp    %edx,%eax
  801137:	73 19                	jae    801152 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801139:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  80113d:	38 08                	cmp    %cl,(%eax)
  80113f:	75 06                	jne    801147 <memfind+0x1d>
  801141:	eb 0f                	jmp    801152 <memfind+0x28>
  801143:	38 08                	cmp    %cl,(%eax)
  801145:	74 0b                	je     801152 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801147:	83 c0 01             	add    $0x1,%eax
  80114a:	39 d0                	cmp    %edx,%eax
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	75 f1                	jne    801143 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	8b 55 08             	mov    0x8(%ebp),%edx
  80115d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801160:	0f b6 02             	movzbl (%edx),%eax
  801163:	3c 20                	cmp    $0x20,%al
  801165:	74 04                	je     80116b <strtol+0x17>
  801167:	3c 09                	cmp    $0x9,%al
  801169:	75 0e                	jne    801179 <strtol+0x25>
		s++;
  80116b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80116e:	0f b6 02             	movzbl (%edx),%eax
  801171:	3c 20                	cmp    $0x20,%al
  801173:	74 f6                	je     80116b <strtol+0x17>
  801175:	3c 09                	cmp    $0x9,%al
  801177:	74 f2                	je     80116b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801179:	3c 2b                	cmp    $0x2b,%al
  80117b:	75 0a                	jne    801187 <strtol+0x33>
		s++;
  80117d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801180:	bf 00 00 00 00       	mov    $0x0,%edi
  801185:	eb 10                	jmp    801197 <strtol+0x43>
  801187:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80118c:	3c 2d                	cmp    $0x2d,%al
  80118e:	75 07                	jne    801197 <strtol+0x43>
		s++, neg = 1;
  801190:	83 c2 01             	add    $0x1,%edx
  801193:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801197:	85 db                	test   %ebx,%ebx
  801199:	0f 94 c0             	sete   %al
  80119c:	74 05                	je     8011a3 <strtol+0x4f>
  80119e:	83 fb 10             	cmp    $0x10,%ebx
  8011a1:	75 15                	jne    8011b8 <strtol+0x64>
  8011a3:	80 3a 30             	cmpb   $0x30,(%edx)
  8011a6:	75 10                	jne    8011b8 <strtol+0x64>
  8011a8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8011ac:	75 0a                	jne    8011b8 <strtol+0x64>
		s += 2, base = 16;
  8011ae:	83 c2 02             	add    $0x2,%edx
  8011b1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8011b6:	eb 13                	jmp    8011cb <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8011b8:	84 c0                	test   %al,%al
  8011ba:	74 0f                	je     8011cb <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011bc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011c1:	80 3a 30             	cmpb   $0x30,(%edx)
  8011c4:	75 05                	jne    8011cb <strtol+0x77>
		s++, base = 8;
  8011c6:	83 c2 01             	add    $0x1,%edx
  8011c9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011d2:	0f b6 0a             	movzbl (%edx),%ecx
  8011d5:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8011d8:	80 fb 09             	cmp    $0x9,%bl
  8011db:	77 08                	ja     8011e5 <strtol+0x91>
			dig = *s - '0';
  8011dd:	0f be c9             	movsbl %cl,%ecx
  8011e0:	83 e9 30             	sub    $0x30,%ecx
  8011e3:	eb 1e                	jmp    801203 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  8011e5:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8011e8:	80 fb 19             	cmp    $0x19,%bl
  8011eb:	77 08                	ja     8011f5 <strtol+0xa1>
			dig = *s - 'a' + 10;
  8011ed:	0f be c9             	movsbl %cl,%ecx
  8011f0:	83 e9 57             	sub    $0x57,%ecx
  8011f3:	eb 0e                	jmp    801203 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  8011f5:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8011f8:	80 fb 19             	cmp    $0x19,%bl
  8011fb:	77 14                	ja     801211 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8011fd:	0f be c9             	movsbl %cl,%ecx
  801200:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801203:	39 f1                	cmp    %esi,%ecx
  801205:	7d 0e                	jge    801215 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801207:	83 c2 01             	add    $0x1,%edx
  80120a:	0f af c6             	imul   %esi,%eax
  80120d:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80120f:	eb c1                	jmp    8011d2 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801211:	89 c1                	mov    %eax,%ecx
  801213:	eb 02                	jmp    801217 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801215:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801217:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80121b:	74 05                	je     801222 <strtol+0xce>
		*endptr = (char *) s;
  80121d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801220:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801222:	89 ca                	mov    %ecx,%edx
  801224:	f7 da                	neg    %edx
  801226:	85 ff                	test   %edi,%edi
  801228:	0f 45 c2             	cmovne %edx,%eax
}
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801239:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80123c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801247:	8b 55 08             	mov    0x8(%ebp),%edx
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	89 c7                	mov    %eax,%edi
  80124e:	89 c6                	mov    %eax,%esi
  801250:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801252:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801255:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801258:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80125b:	89 ec                	mov    %ebp,%esp
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <sys_cgetc>:

int
sys_cgetc(void)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801268:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80126b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126e:	ba 00 00 00 00       	mov    $0x0,%edx
  801273:	b8 01 00 00 00       	mov    $0x1,%eax
  801278:	89 d1                	mov    %edx,%ecx
  80127a:	89 d3                	mov    %edx,%ebx
  80127c:	89 d7                	mov    %edx,%edi
  80127e:	89 d6                	mov    %edx,%esi
  801280:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801282:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801285:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801288:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80128b:	89 ec                	mov    %ebp,%esp
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 38             	sub    $0x38,%esp
  801295:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801298:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80129b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8012a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ab:	89 cb                	mov    %ecx,%ebx
  8012ad:	89 cf                	mov    %ecx,%edi
  8012af:	89 ce                	mov    %ecx,%esi
  8012b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	7e 28                	jle    8012df <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d2:	00 
  8012d3:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  8012da:	e8 1d f3 ff ff       	call   8005fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012e8:	89 ec                	mov    %ebp,%esp
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801300:	b8 02 00 00 00       	mov    $0x2,%eax
  801305:	89 d1                	mov    %edx,%ecx
  801307:	89 d3                	mov    %edx,%ebx
  801309:	89 d7                	mov    %edx,%edi
  80130b:	89 d6                	mov    %edx,%esi
  80130d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80130f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801312:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801315:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801318:	89 ec                	mov    %ebp,%esp
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <sys_yield>:

void
sys_yield(void)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801325:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801328:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80132b:	ba 00 00 00 00       	mov    $0x0,%edx
  801330:	b8 0a 00 00 00       	mov    $0xa,%eax
  801335:	89 d1                	mov    %edx,%ecx
  801337:	89 d3                	mov    %edx,%ebx
  801339:	89 d7                	mov    %edx,%edi
  80133b:	89 d6                	mov    %edx,%esi
  80133d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80133f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801342:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801345:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801348:	89 ec                	mov    %ebp,%esp
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 38             	sub    $0x38,%esp
  801352:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801355:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801358:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80135b:	be 00 00 00 00       	mov    $0x0,%esi
  801360:	b8 04 00 00 00       	mov    $0x4,%eax
  801365:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801368:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	89 f7                	mov    %esi,%edi
  801370:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801372:	85 c0                	test   %eax,%eax
  801374:	7e 28                	jle    80139e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80137a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801381:	00 
  801382:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  801389:	00 
  80138a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801391:	00 
  801392:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  801399:	e8 5e f2 ff ff       	call   8005fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80139e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013a1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013a4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013a7:	89 ec                	mov    %ebp,%esp
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 38             	sub    $0x38,%esp
  8013b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8013bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8013c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	7e 28                	jle    8013fc <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013d8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013df:	00 
  8013e0:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  8013e7:	00 
  8013e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ef:	00 
  8013f0:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  8013f7:	e8 00 f2 ff ff       	call   8005fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8013fc:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013ff:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801402:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801405:	89 ec                	mov    %ebp,%esp
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    

00801409 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 38             	sub    $0x38,%esp
  80140f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801412:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801415:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801418:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141d:	b8 06 00 00 00       	mov    $0x6,%eax
  801422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801425:	8b 55 08             	mov    0x8(%ebp),%edx
  801428:	89 df                	mov    %ebx,%edi
  80142a:	89 de                	mov    %ebx,%esi
  80142c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80142e:	85 c0                	test   %eax,%eax
  801430:	7e 28                	jle    80145a <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801432:	89 44 24 10          	mov    %eax,0x10(%esp)
  801436:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80143d:	00 
  80143e:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  801445:	00 
  801446:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80144d:	00 
  80144e:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  801455:	e8 a2 f1 ff ff       	call   8005fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80145a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80145d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801460:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801463:	89 ec                	mov    %ebp,%esp
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 38             	sub    $0x38,%esp
  80146d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801470:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801473:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801476:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147b:	b8 08 00 00 00       	mov    $0x8,%eax
  801480:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801483:	8b 55 08             	mov    0x8(%ebp),%edx
  801486:	89 df                	mov    %ebx,%edi
  801488:	89 de                	mov    %ebx,%esi
  80148a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80148c:	85 c0                	test   %eax,%eax
  80148e:	7e 28                	jle    8014b8 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801490:	89 44 24 10          	mov    %eax,0x10(%esp)
  801494:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80149b:	00 
  80149c:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  8014a3:	00 
  8014a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ab:	00 
  8014ac:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  8014b3:	e8 44 f1 ff ff       	call   8005fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014b8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014bb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014be:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014c1:	89 ec                	mov    %ebp,%esp
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 38             	sub    $0x38,%esp
  8014cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014ce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014d1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8014de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e4:	89 df                	mov    %ebx,%edi
  8014e6:	89 de                	mov    %ebx,%esi
  8014e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	7e 28                	jle    801516 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  801501:	00 
  801502:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801509:	00 
  80150a:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  801511:	e8 e6 f0 ff ff       	call   8005fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801516:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801519:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80151c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80151f:	89 ec                	mov    %ebp,%esp
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80152c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80152f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801532:	be 00 00 00 00       	mov    $0x0,%esi
  801537:	b8 0b 00 00 00       	mov    $0xb,%eax
  80153c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80153f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801542:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801545:	8b 55 08             	mov    0x8(%ebp),%edx
  801548:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80154a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80154d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801550:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801553:	89 ec                	mov    %ebp,%esp
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	83 ec 38             	sub    $0x38,%esp
  80155d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801560:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801563:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801570:	8b 55 08             	mov    0x8(%ebp),%edx
  801573:	89 cb                	mov    %ecx,%ebx
  801575:	89 cf                	mov    %ecx,%edi
  801577:	89 ce                	mov    %ecx,%esi
  801579:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80157b:	85 c0                	test   %eax,%eax
  80157d:	7e 28                	jle    8015a7 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80157f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801583:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80158a:	00 
  80158b:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  801592:	00 
  801593:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80159a:	00 
  80159b:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  8015a2:	e8 55 f0 ff ff       	call   8005fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8015a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015b0:	89 ec                	mov    %ebp,%esp
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 0c             	sub    $0xc,%esp
  8015ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8015cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d0:	89 cb                	mov    %ecx,%ebx
  8015d2:	89 cf                	mov    %ecx,%edi
  8015d4:	89 ce                	mov    %ecx,%esi
  8015d6:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
  8015d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015db:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015de:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015e1:	89 ec                	mov    %ebp,%esp
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    
  8015e5:	00 00                	add    %al,(%eax)
	...

008015e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8015ee:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8015f5:	75 3c                	jne    801633 <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8015f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015fe:	00 
  8015ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801606:	ee 
  801607:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160e:	e8 39 fd ff ff       	call   80134c <sys_page_alloc>
  801613:	85 c0                	test   %eax,%eax
  801615:	79 1c                	jns    801633 <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801617:	c7 44 24 08 30 1d 80 	movl   $0x801d30,0x8(%esp)
  80161e:	00 
  80161f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801626:	00 
  801627:	c7 04 24 94 1d 80 00 	movl   $0x801d94,(%esp)
  80162e:	e8 c9 ef ff ff       	call   8005fc <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801633:	8b 45 08             	mov    0x8(%ebp),%eax
  801636:	a3 d0 20 80 00       	mov    %eax,0x8020d0
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80163b:	c7 44 24 04 74 16 80 	movl   $0x801674,0x4(%esp)
  801642:	00 
  801643:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164a:	e8 76 fe ff ff       	call   8014c5 <sys_env_set_pgfault_upcall>
  80164f:	85 c0                	test   %eax,%eax
  801651:	79 1c                	jns    80166f <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801653:	c7 44 24 08 5c 1d 80 	movl   $0x801d5c,0x8(%esp)
  80165a:	00 
  80165b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801662:	00 
  801663:	c7 04 24 94 1d 80 00 	movl   $0x801d94,(%esp)
  80166a:	e8 8d ef ff ff       	call   8005fc <_panic>
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    
  801671:	00 00                	add    %al,(%eax)
	...

00801674 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801674:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801675:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80167a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80167c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  80167f:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  801683:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  801688:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  80168c:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  80168e:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  801691:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  801692:	83 c4 04             	add    $0x4,%esp
    popfl
  801695:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  801696:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  801697:	c3                   	ret    
	...

008016a0 <__udivdi3>:
  8016a0:	83 ec 1c             	sub    $0x1c,%esp
  8016a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8016a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8016ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8016af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8016b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8016bb:	85 ff                	test   %edi,%edi
  8016bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8016c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016c5:	89 cd                	mov    %ecx,%ebp
  8016c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cb:	75 33                	jne    801700 <__udivdi3+0x60>
  8016cd:	39 f1                	cmp    %esi,%ecx
  8016cf:	77 57                	ja     801728 <__udivdi3+0x88>
  8016d1:	85 c9                	test   %ecx,%ecx
  8016d3:	75 0b                	jne    8016e0 <__udivdi3+0x40>
  8016d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8016da:	31 d2                	xor    %edx,%edx
  8016dc:	f7 f1                	div    %ecx
  8016de:	89 c1                	mov    %eax,%ecx
  8016e0:	89 f0                	mov    %esi,%eax
  8016e2:	31 d2                	xor    %edx,%edx
  8016e4:	f7 f1                	div    %ecx
  8016e6:	89 c6                	mov    %eax,%esi
  8016e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8016ec:	f7 f1                	div    %ecx
  8016ee:	89 f2                	mov    %esi,%edx
  8016f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8016f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8016f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8016fc:	83 c4 1c             	add    $0x1c,%esp
  8016ff:	c3                   	ret    
  801700:	31 d2                	xor    %edx,%edx
  801702:	31 c0                	xor    %eax,%eax
  801704:	39 f7                	cmp    %esi,%edi
  801706:	77 e8                	ja     8016f0 <__udivdi3+0x50>
  801708:	0f bd cf             	bsr    %edi,%ecx
  80170b:	83 f1 1f             	xor    $0x1f,%ecx
  80170e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801712:	75 2c                	jne    801740 <__udivdi3+0xa0>
  801714:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801718:	76 04                	jbe    80171e <__udivdi3+0x7e>
  80171a:	39 f7                	cmp    %esi,%edi
  80171c:	73 d2                	jae    8016f0 <__udivdi3+0x50>
  80171e:	31 d2                	xor    %edx,%edx
  801720:	b8 01 00 00 00       	mov    $0x1,%eax
  801725:	eb c9                	jmp    8016f0 <__udivdi3+0x50>
  801727:	90                   	nop
  801728:	89 f2                	mov    %esi,%edx
  80172a:	f7 f1                	div    %ecx
  80172c:	31 d2                	xor    %edx,%edx
  80172e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801732:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801736:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80173a:	83 c4 1c             	add    $0x1c,%esp
  80173d:	c3                   	ret    
  80173e:	66 90                	xchg   %ax,%ax
  801740:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801745:	b8 20 00 00 00       	mov    $0x20,%eax
  80174a:	89 ea                	mov    %ebp,%edx
  80174c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801750:	d3 e7                	shl    %cl,%edi
  801752:	89 c1                	mov    %eax,%ecx
  801754:	d3 ea                	shr    %cl,%edx
  801756:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80175b:	09 fa                	or     %edi,%edx
  80175d:	89 f7                	mov    %esi,%edi
  80175f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801763:	89 f2                	mov    %esi,%edx
  801765:	8b 74 24 08          	mov    0x8(%esp),%esi
  801769:	d3 e5                	shl    %cl,%ebp
  80176b:	89 c1                	mov    %eax,%ecx
  80176d:	d3 ef                	shr    %cl,%edi
  80176f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801774:	d3 e2                	shl    %cl,%edx
  801776:	89 c1                	mov    %eax,%ecx
  801778:	d3 ee                	shr    %cl,%esi
  80177a:	09 d6                	or     %edx,%esi
  80177c:	89 fa                	mov    %edi,%edx
  80177e:	89 f0                	mov    %esi,%eax
  801780:	f7 74 24 0c          	divl   0xc(%esp)
  801784:	89 d7                	mov    %edx,%edi
  801786:	89 c6                	mov    %eax,%esi
  801788:	f7 e5                	mul    %ebp
  80178a:	39 d7                	cmp    %edx,%edi
  80178c:	72 22                	jb     8017b0 <__udivdi3+0x110>
  80178e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801792:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801797:	d3 e5                	shl    %cl,%ebp
  801799:	39 c5                	cmp    %eax,%ebp
  80179b:	73 04                	jae    8017a1 <__udivdi3+0x101>
  80179d:	39 d7                	cmp    %edx,%edi
  80179f:	74 0f                	je     8017b0 <__udivdi3+0x110>
  8017a1:	89 f0                	mov    %esi,%eax
  8017a3:	31 d2                	xor    %edx,%edx
  8017a5:	e9 46 ff ff ff       	jmp    8016f0 <__udivdi3+0x50>
  8017aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8017b3:	31 d2                	xor    %edx,%edx
  8017b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8017b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8017bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8017c1:	83 c4 1c             	add    $0x1c,%esp
  8017c4:	c3                   	ret    
	...

008017d0 <__umoddi3>:
  8017d0:	83 ec 1c             	sub    $0x1c,%esp
  8017d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8017d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8017db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8017df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8017e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8017e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8017eb:	85 ed                	test   %ebp,%ebp
  8017ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8017f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f5:	89 cf                	mov    %ecx,%edi
  8017f7:	89 04 24             	mov    %eax,(%esp)
  8017fa:	89 f2                	mov    %esi,%edx
  8017fc:	75 1a                	jne    801818 <__umoddi3+0x48>
  8017fe:	39 f1                	cmp    %esi,%ecx
  801800:	76 4e                	jbe    801850 <__umoddi3+0x80>
  801802:	f7 f1                	div    %ecx
  801804:	89 d0                	mov    %edx,%eax
  801806:	31 d2                	xor    %edx,%edx
  801808:	8b 74 24 10          	mov    0x10(%esp),%esi
  80180c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801810:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801814:	83 c4 1c             	add    $0x1c,%esp
  801817:	c3                   	ret    
  801818:	39 f5                	cmp    %esi,%ebp
  80181a:	77 54                	ja     801870 <__umoddi3+0xa0>
  80181c:	0f bd c5             	bsr    %ebp,%eax
  80181f:	83 f0 1f             	xor    $0x1f,%eax
  801822:	89 44 24 04          	mov    %eax,0x4(%esp)
  801826:	75 60                	jne    801888 <__umoddi3+0xb8>
  801828:	3b 0c 24             	cmp    (%esp),%ecx
  80182b:	0f 87 07 01 00 00    	ja     801938 <__umoddi3+0x168>
  801831:	89 f2                	mov    %esi,%edx
  801833:	8b 34 24             	mov    (%esp),%esi
  801836:	29 ce                	sub    %ecx,%esi
  801838:	19 ea                	sbb    %ebp,%edx
  80183a:	89 34 24             	mov    %esi,(%esp)
  80183d:	8b 04 24             	mov    (%esp),%eax
  801840:	8b 74 24 10          	mov    0x10(%esp),%esi
  801844:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801848:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80184c:	83 c4 1c             	add    $0x1c,%esp
  80184f:	c3                   	ret    
  801850:	85 c9                	test   %ecx,%ecx
  801852:	75 0b                	jne    80185f <__umoddi3+0x8f>
  801854:	b8 01 00 00 00       	mov    $0x1,%eax
  801859:	31 d2                	xor    %edx,%edx
  80185b:	f7 f1                	div    %ecx
  80185d:	89 c1                	mov    %eax,%ecx
  80185f:	89 f0                	mov    %esi,%eax
  801861:	31 d2                	xor    %edx,%edx
  801863:	f7 f1                	div    %ecx
  801865:	8b 04 24             	mov    (%esp),%eax
  801868:	f7 f1                	div    %ecx
  80186a:	eb 98                	jmp    801804 <__umoddi3+0x34>
  80186c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801870:	89 f2                	mov    %esi,%edx
  801872:	8b 74 24 10          	mov    0x10(%esp),%esi
  801876:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80187a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80187e:	83 c4 1c             	add    $0x1c,%esp
  801881:	c3                   	ret    
  801882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801888:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80188d:	89 e8                	mov    %ebp,%eax
  80188f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801894:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801898:	89 fa                	mov    %edi,%edx
  80189a:	d3 e0                	shl    %cl,%eax
  80189c:	89 e9                	mov    %ebp,%ecx
  80189e:	d3 ea                	shr    %cl,%edx
  8018a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018a5:	09 c2                	or     %eax,%edx
  8018a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018ab:	89 14 24             	mov    %edx,(%esp)
  8018ae:	89 f2                	mov    %esi,%edx
  8018b0:	d3 e7                	shl    %cl,%edi
  8018b2:	89 e9                	mov    %ebp,%ecx
  8018b4:	d3 ea                	shr    %cl,%edx
  8018b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018bf:	d3 e6                	shl    %cl,%esi
  8018c1:	89 e9                	mov    %ebp,%ecx
  8018c3:	d3 e8                	shr    %cl,%eax
  8018c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018ca:	09 f0                	or     %esi,%eax
  8018cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8018d0:	f7 34 24             	divl   (%esp)
  8018d3:	d3 e6                	shl    %cl,%esi
  8018d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8018d9:	89 d6                	mov    %edx,%esi
  8018db:	f7 e7                	mul    %edi
  8018dd:	39 d6                	cmp    %edx,%esi
  8018df:	89 c1                	mov    %eax,%ecx
  8018e1:	89 d7                	mov    %edx,%edi
  8018e3:	72 3f                	jb     801924 <__umoddi3+0x154>
  8018e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8018e9:	72 35                	jb     801920 <__umoddi3+0x150>
  8018eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018ef:	29 c8                	sub    %ecx,%eax
  8018f1:	19 fe                	sbb    %edi,%esi
  8018f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8018f8:	89 f2                	mov    %esi,%edx
  8018fa:	d3 e8                	shr    %cl,%eax
  8018fc:	89 e9                	mov    %ebp,%ecx
  8018fe:	d3 e2                	shl    %cl,%edx
  801900:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801905:	09 d0                	or     %edx,%eax
  801907:	89 f2                	mov    %esi,%edx
  801909:	d3 ea                	shr    %cl,%edx
  80190b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80190f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801913:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801917:	83 c4 1c             	add    $0x1c,%esp
  80191a:	c3                   	ret    
  80191b:	90                   	nop
  80191c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801920:	39 d6                	cmp    %edx,%esi
  801922:	75 c7                	jne    8018eb <__umoddi3+0x11b>
  801924:	89 d7                	mov    %edx,%edi
  801926:	89 c1                	mov    %eax,%ecx
  801928:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80192c:	1b 3c 24             	sbb    (%esp),%edi
  80192f:	eb ba                	jmp    8018eb <__umoddi3+0x11b>
  801931:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801938:	39 f5                	cmp    %esi,%ebp
  80193a:	0f 82 f1 fe ff ff    	jb     801831 <__umoddi3+0x61>
  801940:	e9 f8 fe ff ff       	jmp    80183d <__umoddi3+0x6d>
