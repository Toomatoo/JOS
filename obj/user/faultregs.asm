
obj/user/faultregs.debug:     file format elf32-i386


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
  80004c:	c7 44 24 04 31 29 80 	movl   $0x802931,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 00 29 80 00 	movl   $0x802900,(%esp)
  80005b:	e8 9f 06 00 00       	call   8006ff <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 10 29 80 	movl   $0x802910,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  80007b:	e8 7f 06 00 00       	call   8006ff <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  80008d:	e8 6d 06 00 00       	call   8006ff <cprintf>

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
  800099:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  8000a0:	e8 5a 06 00 00       	call   8006ff <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 32 29 80 	movl   $0x802932,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8000c7:	e8 33 06 00 00       	call   8006ff <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8000db:	e8 1f 06 00 00       	call   8006ff <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  8000e9:	e8 11 06 00 00       	call   8006ff <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 36 29 80 	movl   $0x802936,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  800110:	e8 ea 05 00 00       	call   8006ff <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  800124:	e8 d6 05 00 00       	call   8006ff <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  800132:	e8 c8 05 00 00       	call   8006ff <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 3a 29 80 	movl   $0x80293a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  800159:	e8 a1 05 00 00       	call   8006ff <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  80016d:	e8 8d 05 00 00       	call   8006ff <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  80017b:	e8 7f 05 00 00       	call   8006ff <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 3e 29 80 	movl   $0x80293e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8001a2:	e8 58 05 00 00       	call   8006ff <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8001b6:	e8 44 05 00 00       	call   8006ff <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  8001c4:	e8 36 05 00 00       	call   8006ff <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 42 29 80 	movl   $0x802942,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8001eb:	e8 0f 05 00 00       	call   8006ff <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8001ff:	e8 fb 04 00 00       	call   8006ff <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  80020d:	e8 ed 04 00 00       	call   8006ff <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 46 29 80 	movl   $0x802946,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  800234:	e8 c6 04 00 00       	call   8006ff <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  800248:	e8 b2 04 00 00       	call   8006ff <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  800256:	e8 a4 04 00 00       	call   8006ff <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 4a 29 80 	movl   $0x80294a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  80027d:	e8 7d 04 00 00       	call   8006ff <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  800291:	e8 69 04 00 00       	call   8006ff <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  80029f:	e8 5b 04 00 00       	call   8006ff <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 4e 29 80 	movl   $0x80294e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  8002c6:	e8 34 04 00 00       	call   8006ff <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8002da:	e8 20 04 00 00       	call   8006ff <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  8002e8:	e8 12 04 00 00       	call   8006ff <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 55 29 80 	movl   $0x802955,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 14 29 80 00 	movl   $0x802914,(%esp)
  80030f:	e8 eb 03 00 00       	call   8006ff <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  800323:	e8 d7 03 00 00       	call   8006ff <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 59 29 80 00 	movl   $0x802959,(%esp)
  800336:	e8 c4 03 00 00       	call   8006ff <cprintf>
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
  800341:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  800348:	e8 b2 03 00 00       	call   8006ff <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 59 29 80 00 	movl   $0x802959,(%esp)
  80035b:	e8 9f 03 00 00       	call   8006ff <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  800369:	e8 91 03 00 00       	call   8006ff <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 28 29 80 00 	movl   $0x802928,(%esp)
  800377:	e8 83 03 00 00       	call   8006ff <cprintf>
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
  8003a2:	c7 44 24 08 c0 29 80 	movl   $0x8029c0,0x8(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b1:	00 
  8003b2:	c7 04 24 67 29 80 00 	movl   $0x802967,(%esp)
  8003b9:	e8 46 02 00 00       	call   800604 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003be:	8b 50 08             	mov    0x8(%eax),%edx
  8003c1:	89 15 80 40 80 00    	mov    %edx,0x804080
  8003c7:	8b 50 0c             	mov    0xc(%eax),%edx
  8003ca:	89 15 84 40 80 00    	mov    %edx,0x804084
  8003d0:	8b 50 10             	mov    0x10(%eax),%edx
  8003d3:	89 15 88 40 80 00    	mov    %edx,0x804088
  8003d9:	8b 50 14             	mov    0x14(%eax),%edx
  8003dc:	89 15 8c 40 80 00    	mov    %edx,0x80408c
  8003e2:	8b 50 18             	mov    0x18(%eax),%edx
  8003e5:	89 15 90 40 80 00    	mov    %edx,0x804090
  8003eb:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ee:	89 15 94 40 80 00    	mov    %edx,0x804094
  8003f4:	8b 50 20             	mov    0x20(%eax),%edx
  8003f7:	89 15 98 40 80 00    	mov    %edx,0x804098
  8003fd:	8b 50 24             	mov    0x24(%eax),%edx
  800400:	89 15 9c 40 80 00    	mov    %edx,0x80409c
	during.eip = utf->utf_eip;
  800406:	8b 50 28             	mov    0x28(%eax),%edx
  800409:	89 15 a0 40 80 00    	mov    %edx,0x8040a0
	during.eflags = utf->utf_eflags;
  80040f:	8b 50 2c             	mov    0x2c(%eax),%edx
  800412:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  800418:	8b 40 30             	mov    0x30(%eax),%eax
  80041b:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800420:	c7 44 24 04 7f 29 80 	movl   $0x80297f,0x4(%esp)
  800427:	00 
  800428:	c7 04 24 8d 29 80 00 	movl   $0x80298d,(%esp)
  80042f:	b9 80 40 80 00       	mov    $0x804080,%ecx
  800434:	ba 78 29 80 00       	mov    $0x802978,%edx
  800439:	b8 00 40 80 00       	mov    $0x804000,%eax
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
  800467:	c7 44 24 08 94 29 80 	movl   $0x802994,0x8(%esp)
  80046e:	00 
  80046f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800476:	00 
  800477:	c7 04 24 67 29 80 00 	movl   $0x802967,(%esp)
  80047e:	e8 81 01 00 00       	call   800604 <_panic>
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
  800492:	e8 ad 11 00 00       	call   801644 <set_pgfault_handler>

	__asm __volatile(
  800497:	50                   	push   %eax
  800498:	9c                   	pushf  
  800499:	58                   	pop    %eax
  80049a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049f:	50                   	push   %eax
  8004a0:	9d                   	popf   
  8004a1:	a3 24 40 80 00       	mov    %eax,0x804024
  8004a6:	8d 05 e1 04 80 00    	lea    0x8004e1,%eax
  8004ac:	a3 20 40 80 00       	mov    %eax,0x804020
  8004b1:	58                   	pop    %eax
  8004b2:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004b8:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004be:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004c4:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004ca:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004d0:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004d6:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004db:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004e1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e8:	00 00 00 
  8004eb:	89 3d 40 40 80 00    	mov    %edi,0x804040
  8004f1:	89 35 44 40 80 00    	mov    %esi,0x804044
  8004f7:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  8004fd:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  800503:	89 15 54 40 80 00    	mov    %edx,0x804054
  800509:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  80050f:	a3 5c 40 80 00       	mov    %eax,0x80405c
  800514:	89 25 68 40 80 00    	mov    %esp,0x804068
  80051a:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  800520:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800526:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  80052c:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  800532:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800538:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  80053e:	a1 1c 40 80 00       	mov    0x80401c,%eax
  800543:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800549:	50                   	push   %eax
  80054a:	9c                   	pushf  
  80054b:	58                   	pop    %eax
  80054c:	a3 64 40 80 00       	mov    %eax,0x804064
  800551:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800552:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800559:	74 0c                	je     800567 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055b:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  800562:	e8 98 01 00 00       	call   8006ff <cprintf>
	after.eip = before.eip;
  800567:	a1 20 40 80 00       	mov    0x804020,%eax
  80056c:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	c7 44 24 04 a7 29 80 	movl   $0x8029a7,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  800580:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800585:	ba 78 29 80 00       	mov    $0x802978,%edx
  80058a:	b8 00 40 80 00       	mov    $0x804000,%eax
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
  8005bc:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 03                	mov    (%ebx),%eax
  8005c7:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8005ee:	e8 2b 13 00 00       	call   80191e <close_all>
	sys_env_destroy(0);
  8005f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005fa:	e8 90 0c 00 00       	call   80128f <sys_env_destroy>
}
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    
  800601:	00 00                	add    %al,(%eax)
	...

00800604 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	56                   	push   %esi
  800608:	53                   	push   %ebx
  800609:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80060c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80060f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800615:	e8 d2 0c 00 00       	call   8012ec <sys_getenvid>
  80061a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800621:	8b 55 08             	mov    0x8(%ebp),%edx
  800624:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800628:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  800637:	e8 c3 00 00 00       	call   8006ff <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80063c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800640:	8b 45 10             	mov    0x10(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 53 00 00 00       	call   80069e <vcprintf>
	cprintf("\n");
  80064b:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  800652:	e8 a8 00 00 00       	call   8006ff <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800657:	cc                   	int3   
  800658:	eb fd                	jmp    800657 <_panic+0x53>
	...

0080065c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	53                   	push   %ebx
  800660:	83 ec 14             	sub    $0x14,%esp
  800663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800666:	8b 03                	mov    (%ebx),%eax
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80066f:	83 c0 01             	add    $0x1,%eax
  800672:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800674:	3d ff 00 00 00       	cmp    $0xff,%eax
  800679:	75 19                	jne    800694 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80067b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800682:	00 
  800683:	8d 43 08             	lea    0x8(%ebx),%eax
  800686:	89 04 24             	mov    %eax,(%esp)
  800689:	e8 a2 0b 00 00       	call   801230 <sys_cputs>
		b->idx = 0;
  80068e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800694:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800698:	83 c4 14             	add    $0x14,%esp
  80069b:	5b                   	pop    %ebx
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006ae:	00 00 00 
	b.cnt = 0;
  8006b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	c7 04 24 5c 06 80 00 	movl   $0x80065c,(%esp)
  8006da:	e8 97 01 00 00       	call   800876 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006df:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 39 0b 00 00       	call   801230 <sys_cputs>

	return b.cnt;
}
  8006f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800705:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	e8 87 ff ff ff       	call   80069e <vcprintf>
	va_end(ap);

	return cnt;
}
  800717:	c9                   	leave  
  800718:	c3                   	ret    
  800719:	00 00                	add    %al,(%eax)
	...

0080071c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	57                   	push   %edi
  800720:	56                   	push   %esi
  800721:	53                   	push   %ebx
  800722:	83 ec 3c             	sub    $0x3c,%esp
  800725:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800728:	89 d7                	mov    %edx,%edi
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800730:	8b 45 0c             	mov    0xc(%ebp),%eax
  800733:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800736:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800739:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80073c:	b8 00 00 00 00       	mov    $0x0,%eax
  800741:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800744:	72 11                	jb     800757 <printnum+0x3b>
  800746:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800749:	39 45 10             	cmp    %eax,0x10(%ebp)
  80074c:	76 09                	jbe    800757 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80074e:	83 eb 01             	sub    $0x1,%ebx
  800751:	85 db                	test   %ebx,%ebx
  800753:	7f 51                	jg     8007a6 <printnum+0x8a>
  800755:	eb 5e                	jmp    8007b5 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800757:	89 74 24 10          	mov    %esi,0x10(%esp)
  80075b:	83 eb 01             	sub    $0x1,%ebx
  80075e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80076d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800771:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800778:	00 
  800779:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800782:	89 44 24 04          	mov    %eax,0x4(%esp)
  800786:	e8 c5 1e 00 00       	call   802650 <__udivdi3>
  80078b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80078f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079a:	89 fa                	mov    %edi,%edx
  80079c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079f:	e8 78 ff ff ff       	call   80071c <printnum>
  8007a4:	eb 0f                	jmp    8007b5 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007aa:	89 34 24             	mov    %esi,(%esp)
  8007ad:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007b0:	83 eb 01             	sub    $0x1,%ebx
  8007b3:	75 f1                	jne    8007a6 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007cb:	00 
  8007cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	e8 a2 1f 00 00       	call   802780 <__umoddi3>
  8007de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e2:	0f be 80 43 2a 80 00 	movsbl 0x802a43(%eax),%eax
  8007e9:	89 04 24             	mov    %eax,(%esp)
  8007ec:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ef:	83 c4 3c             	add    $0x3c,%esp
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5f                   	pop    %edi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007fa:	83 fa 01             	cmp    $0x1,%edx
  8007fd:	7e 0e                	jle    80080d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	8d 4a 08             	lea    0x8(%edx),%ecx
  800804:	89 08                	mov    %ecx,(%eax)
  800806:	8b 02                	mov    (%edx),%eax
  800808:	8b 52 04             	mov    0x4(%edx),%edx
  80080b:	eb 22                	jmp    80082f <getuint+0x38>
	else if (lflag)
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 10                	je     800821 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800811:	8b 10                	mov    (%eax),%edx
  800813:	8d 4a 04             	lea    0x4(%edx),%ecx
  800816:	89 08                	mov    %ecx,(%eax)
  800818:	8b 02                	mov    (%edx),%eax
  80081a:	ba 00 00 00 00       	mov    $0x0,%edx
  80081f:	eb 0e                	jmp    80082f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800821:	8b 10                	mov    (%eax),%edx
  800823:	8d 4a 04             	lea    0x4(%edx),%ecx
  800826:	89 08                	mov    %ecx,(%eax)
  800828:	8b 02                	mov    (%edx),%eax
  80082a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800837:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	3b 50 04             	cmp    0x4(%eax),%edx
  800840:	73 0a                	jae    80084c <sprintputch+0x1b>
		*b->buf++ = ch;
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	88 0a                	mov    %cl,(%edx)
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	89 10                	mov    %edx,(%eax)
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800857:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085b:	8b 45 10             	mov    0x10(%ebp),%eax
  80085e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800862:	8b 45 0c             	mov    0xc(%ebp),%eax
  800865:	89 44 24 04          	mov    %eax,0x4(%esp)
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	e8 02 00 00 00       	call   800876 <vprintfmt>
	va_end(ap);
}
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	57                   	push   %edi
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	83 ec 5c             	sub    $0x5c,%esp
  80087f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800882:	8b 75 10             	mov    0x10(%ebp),%esi
  800885:	eb 12                	jmp    800899 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800887:	85 c0                	test   %eax,%eax
  800889:	0f 84 e4 04 00 00    	je     800d73 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80088f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800899:	0f b6 06             	movzbl (%esi),%eax
  80089c:	83 c6 01             	add    $0x1,%esi
  80089f:	83 f8 25             	cmp    $0x25,%eax
  8008a2:	75 e3                	jne    800887 <vprintfmt+0x11>
  8008a4:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  8008a8:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8008af:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c0:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8008c3:	eb 2b                	jmp    8008f0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c5:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008c8:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  8008cc:	eb 22                	jmp    8008f0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ce:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008d1:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  8008d5:	eb 19                	jmp    8008f0 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8008da:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8008e1:	eb 0d                	jmp    8008f0 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8008e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8008e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8008e9:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f0:	0f b6 06             	movzbl (%esi),%eax
  8008f3:	0f b6 d0             	movzbl %al,%edx
  8008f6:	8d 7e 01             	lea    0x1(%esi),%edi
  8008f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008fc:	83 e8 23             	sub    $0x23,%eax
  8008ff:	3c 55                	cmp    $0x55,%al
  800901:	0f 87 46 04 00 00    	ja     800d4d <vprintfmt+0x4d7>
  800907:	0f b6 c0             	movzbl %al,%eax
  80090a:	ff 24 85 a0 2b 80 00 	jmp    *0x802ba0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800911:	83 ea 30             	sub    $0x30,%edx
  800914:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  800917:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80091b:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  800921:	83 fa 09             	cmp    $0x9,%edx
  800924:	77 4a                	ja     800970 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800926:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800929:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80092c:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80092f:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800933:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800936:	8d 50 d0             	lea    -0x30(%eax),%edx
  800939:	83 fa 09             	cmp    $0x9,%edx
  80093c:	76 eb                	jbe    800929 <vprintfmt+0xb3>
  80093e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800941:	eb 2d                	jmp    800970 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	8d 50 04             	lea    0x4(%eax),%edx
  800949:	89 55 14             	mov    %edx,0x14(%ebp)
  80094c:	8b 00                	mov    (%eax),%eax
  80094e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800951:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800954:	eb 1a                	jmp    800970 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800959:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80095d:	79 91                	jns    8008f0 <vprintfmt+0x7a>
  80095f:	e9 73 ff ff ff       	jmp    8008d7 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800964:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800967:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80096e:	eb 80                	jmp    8008f0 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800970:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800974:	0f 89 76 ff ff ff    	jns    8008f0 <vprintfmt+0x7a>
  80097a:	e9 64 ff ff ff       	jmp    8008e3 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80097f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800982:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800985:	e9 66 ff ff ff       	jmp    8008f0 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80098a:	8b 45 14             	mov    0x14(%ebp),%eax
  80098d:	8d 50 04             	lea    0x4(%eax),%edx
  800990:	89 55 14             	mov    %edx,0x14(%ebp)
  800993:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800997:	8b 00                	mov    (%eax),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009a2:	e9 f2 fe ff ff       	jmp    800899 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  8009a7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  8009ab:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  8009ae:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  8009b2:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  8009b5:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  8009b9:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  8009bc:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  8009bf:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  8009c3:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8009c6:	80 f9 09             	cmp    $0x9,%cl
  8009c9:	77 1d                	ja     8009e8 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  8009cb:	0f be c0             	movsbl %al,%eax
  8009ce:	6b c0 64             	imul   $0x64,%eax,%eax
  8009d1:	0f be d2             	movsbl %dl,%edx
  8009d4:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8009d7:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  8009de:	a3 04 30 80 00       	mov    %eax,0x803004
  8009e3:	e9 b1 fe ff ff       	jmp    800899 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  8009e8:	c7 44 24 04 5b 2a 80 	movl   $0x802a5b,0x4(%esp)
  8009ef:	00 
  8009f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 10 05 00 00       	call   800f0b <strcmp>
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	75 0f                	jne    800a0e <vprintfmt+0x198>
  8009ff:	c7 05 04 30 80 00 04 	movl   $0x4,0x803004
  800a06:	00 00 00 
  800a09:	e9 8b fe ff ff       	jmp    800899 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  800a0e:	c7 44 24 04 5f 2a 80 	movl   $0x802a5f,0x4(%esp)
  800a15:	00 
  800a16:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800a19:	89 14 24             	mov    %edx,(%esp)
  800a1c:	e8 ea 04 00 00       	call   800f0b <strcmp>
  800a21:	85 c0                	test   %eax,%eax
  800a23:	75 0f                	jne    800a34 <vprintfmt+0x1be>
  800a25:	c7 05 04 30 80 00 02 	movl   $0x2,0x803004
  800a2c:	00 00 00 
  800a2f:	e9 65 fe ff ff       	jmp    800899 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  800a34:	c7 44 24 04 63 2a 80 	movl   $0x802a63,0x4(%esp)
  800a3b:	00 
  800a3c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800a3f:	89 0c 24             	mov    %ecx,(%esp)
  800a42:	e8 c4 04 00 00       	call   800f0b <strcmp>
  800a47:	85 c0                	test   %eax,%eax
  800a49:	75 0f                	jne    800a5a <vprintfmt+0x1e4>
  800a4b:	c7 05 04 30 80 00 01 	movl   $0x1,0x803004
  800a52:	00 00 00 
  800a55:	e9 3f fe ff ff       	jmp    800899 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  800a5a:	c7 44 24 04 67 2a 80 	movl   $0x802a67,0x4(%esp)
  800a61:	00 
  800a62:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800a65:	89 3c 24             	mov    %edi,(%esp)
  800a68:	e8 9e 04 00 00       	call   800f0b <strcmp>
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	75 0f                	jne    800a80 <vprintfmt+0x20a>
  800a71:	c7 05 04 30 80 00 06 	movl   $0x6,0x803004
  800a78:	00 00 00 
  800a7b:	e9 19 fe ff ff       	jmp    800899 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800a80:	c7 44 24 04 6b 2a 80 	movl   $0x802a6b,0x4(%esp)
  800a87:	00 
  800a88:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a8b:	89 04 24             	mov    %eax,(%esp)
  800a8e:	e8 78 04 00 00       	call   800f0b <strcmp>
  800a93:	85 c0                	test   %eax,%eax
  800a95:	75 0f                	jne    800aa6 <vprintfmt+0x230>
  800a97:	c7 05 04 30 80 00 07 	movl   $0x7,0x803004
  800a9e:	00 00 00 
  800aa1:	e9 f3 fd ff ff       	jmp    800899 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800aa6:	c7 44 24 04 6f 2a 80 	movl   $0x802a6f,0x4(%esp)
  800aad:	00 
  800aae:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800ab1:	89 14 24             	mov    %edx,(%esp)
  800ab4:	e8 52 04 00 00       	call   800f0b <strcmp>
  800ab9:	83 f8 01             	cmp    $0x1,%eax
  800abc:	19 c0                	sbb    %eax,%eax
  800abe:	f7 d0                	not    %eax
  800ac0:	83 c0 08             	add    $0x8,%eax
  800ac3:	a3 04 30 80 00       	mov    %eax,0x803004
  800ac8:	e9 cc fd ff ff       	jmp    800899 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  800acd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad0:	8d 50 04             	lea    0x4(%eax),%edx
  800ad3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad6:	8b 00                	mov    (%eax),%eax
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	c1 fa 1f             	sar    $0x1f,%edx
  800add:	31 d0                	xor    %edx,%eax
  800adf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ae1:	83 f8 0f             	cmp    $0xf,%eax
  800ae4:	7f 0b                	jg     800af1 <vprintfmt+0x27b>
  800ae6:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  800aed:	85 d2                	test   %edx,%edx
  800aef:	75 23                	jne    800b14 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800af1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af5:	c7 44 24 08 73 2a 80 	movl   $0x802a73,0x8(%esp)
  800afc:	00 
  800afd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b04:	89 3c 24             	mov    %edi,(%esp)
  800b07:	e8 42 fd ff ff       	call   80084e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b0f:	e9 85 fd ff ff       	jmp    800899 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b18:	c7 44 24 08 a5 2e 80 	movl   $0x802ea5,0x8(%esp)
  800b1f:	00 
  800b20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b27:	89 3c 24             	mov    %edi,(%esp)
  800b2a:	e8 1f fd ff ff       	call   80084e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b2f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800b32:	e9 62 fd ff ff       	jmp    800899 <vprintfmt+0x23>
  800b37:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  800b3a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b3d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b40:	8b 45 14             	mov    0x14(%ebp),%eax
  800b43:	8d 50 04             	lea    0x4(%eax),%edx
  800b46:	89 55 14             	mov    %edx,0x14(%ebp)
  800b49:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800b4b:	85 f6                	test   %esi,%esi
  800b4d:	b8 54 2a 80 00       	mov    $0x802a54,%eax
  800b52:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800b55:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800b59:	7e 06                	jle    800b61 <vprintfmt+0x2eb>
  800b5b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800b5f:	75 13                	jne    800b74 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b61:	0f be 06             	movsbl (%esi),%eax
  800b64:	83 c6 01             	add    $0x1,%esi
  800b67:	85 c0                	test   %eax,%eax
  800b69:	0f 85 94 00 00 00    	jne    800c03 <vprintfmt+0x38d>
  800b6f:	e9 81 00 00 00       	jmp    800bf5 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b74:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b78:	89 34 24             	mov    %esi,(%esp)
  800b7b:	e8 9b 02 00 00       	call   800e1b <strnlen>
  800b80:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800b83:	29 c2                	sub    %eax,%edx
  800b85:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800b88:	85 d2                	test   %edx,%edx
  800b8a:	7e d5                	jle    800b61 <vprintfmt+0x2eb>
					putch(padc, putdat);
  800b8c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800b90:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800b93:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	89 cf                	mov    %ecx,%edi
  800b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9e:	89 3c 24             	mov    %edi,(%esp)
  800ba1:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800ba4:	83 ee 01             	sub    $0x1,%esi
  800ba7:	75 f1                	jne    800b9a <vprintfmt+0x324>
  800ba9:	8b 7d c0             	mov    -0x40(%ebp),%edi
  800bac:	89 75 cc             	mov    %esi,-0x34(%ebp)
  800baf:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800bb2:	eb ad                	jmp    800b61 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800bb4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800bb8:	74 1b                	je     800bd5 <vprintfmt+0x35f>
  800bba:	8d 50 e0             	lea    -0x20(%eax),%edx
  800bbd:	83 fa 5e             	cmp    $0x5e,%edx
  800bc0:	76 13                	jbe    800bd5 <vprintfmt+0x35f>
					putch('?', putdat);
  800bc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800bd0:	ff 55 08             	call   *0x8(%ebp)
  800bd3:	eb 0d                	jmp    800be2 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800bd5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bd8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bdc:	89 04 24             	mov    %eax,(%esp)
  800bdf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800be2:	83 eb 01             	sub    $0x1,%ebx
  800be5:	0f be 06             	movsbl (%esi),%eax
  800be8:	83 c6 01             	add    $0x1,%esi
  800beb:	85 c0                	test   %eax,%eax
  800bed:	75 1a                	jne    800c09 <vprintfmt+0x393>
  800bef:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800bf2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bf8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800bfc:	7f 1c                	jg     800c1a <vprintfmt+0x3a4>
  800bfe:	e9 96 fc ff ff       	jmp    800899 <vprintfmt+0x23>
  800c03:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800c06:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c09:	85 ff                	test   %edi,%edi
  800c0b:	78 a7                	js     800bb4 <vprintfmt+0x33e>
  800c0d:	83 ef 01             	sub    $0x1,%edi
  800c10:	79 a2                	jns    800bb4 <vprintfmt+0x33e>
  800c12:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800c15:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c18:	eb db                	jmp    800bf5 <vprintfmt+0x37f>
  800c1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c1d:	89 de                	mov    %ebx,%esi
  800c1f:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c22:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c26:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c2d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c2f:	83 eb 01             	sub    $0x1,%ebx
  800c32:	75 ee                	jne    800c22 <vprintfmt+0x3ac>
  800c34:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c36:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800c39:	e9 5b fc ff ff       	jmp    800899 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c3e:	83 f9 01             	cmp    $0x1,%ecx
  800c41:	7e 10                	jle    800c53 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  800c43:	8b 45 14             	mov    0x14(%ebp),%eax
  800c46:	8d 50 08             	lea    0x8(%eax),%edx
  800c49:	89 55 14             	mov    %edx,0x14(%ebp)
  800c4c:	8b 30                	mov    (%eax),%esi
  800c4e:	8b 78 04             	mov    0x4(%eax),%edi
  800c51:	eb 26                	jmp    800c79 <vprintfmt+0x403>
	else if (lflag)
  800c53:	85 c9                	test   %ecx,%ecx
  800c55:	74 12                	je     800c69 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  800c57:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5a:	8d 50 04             	lea    0x4(%eax),%edx
  800c5d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c60:	8b 30                	mov    (%eax),%esi
  800c62:	89 f7                	mov    %esi,%edi
  800c64:	c1 ff 1f             	sar    $0x1f,%edi
  800c67:	eb 10                	jmp    800c79 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800c69:	8b 45 14             	mov    0x14(%ebp),%eax
  800c6c:	8d 50 04             	lea    0x4(%eax),%edx
  800c6f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c72:	8b 30                	mov    (%eax),%esi
  800c74:	89 f7                	mov    %esi,%edi
  800c76:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c79:	85 ff                	test   %edi,%edi
  800c7b:	78 0e                	js     800c8b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c81:	be 0a 00 00 00       	mov    $0xa,%esi
  800c86:	e9 84 00 00 00       	jmp    800d0f <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c8f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800c96:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800c99:	89 f0                	mov    %esi,%eax
  800c9b:	89 fa                	mov    %edi,%edx
  800c9d:	f7 d8                	neg    %eax
  800c9f:	83 d2 00             	adc    $0x0,%edx
  800ca2:	f7 da                	neg    %edx
			}
			base = 10;
  800ca4:	be 0a 00 00 00       	mov    $0xa,%esi
  800ca9:	eb 64                	jmp    800d0f <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cab:	89 ca                	mov    %ecx,%edx
  800cad:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb0:	e8 42 fb ff ff       	call   8007f7 <getuint>
			base = 10;
  800cb5:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  800cba:	eb 53                	jmp    800d0f <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800cbc:	89 ca                	mov    %ecx,%edx
  800cbe:	8d 45 14             	lea    0x14(%ebp),%eax
  800cc1:	e8 31 fb ff ff       	call   8007f7 <getuint>
    			base = 8;
  800cc6:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  800ccb:	eb 42                	jmp    800d0f <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  800ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800cd8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800cdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cdf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ce6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ce9:	8b 45 14             	mov    0x14(%ebp),%eax
  800cec:	8d 50 04             	lea    0x4(%eax),%edx
  800cef:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cf2:	8b 00                	mov    (%eax),%eax
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cf9:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  800cfe:	eb 0f                	jmp    800d0f <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d00:	89 ca                	mov    %ecx,%edx
  800d02:	8d 45 14             	lea    0x14(%ebp),%eax
  800d05:	e8 ed fa ff ff       	call   8007f7 <getuint>
			base = 16;
  800d0a:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d0f:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800d13:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d17:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d1a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800d22:	89 04 24             	mov    %eax,(%esp)
  800d25:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d29:	89 da                	mov    %ebx,%edx
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	e8 e9 f9 ff ff       	call   80071c <printnum>
			break;
  800d33:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800d36:	e9 5e fb ff ff       	jmp    800899 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3f:	89 14 24             	mov    %edx,(%esp)
  800d42:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d45:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d48:	e9 4c fb ff ff       	jmp    800899 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d51:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d58:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d5b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d5f:	0f 84 34 fb ff ff    	je     800899 <vprintfmt+0x23>
  800d65:	83 ee 01             	sub    $0x1,%esi
  800d68:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800d6c:	75 f7                	jne    800d65 <vprintfmt+0x4ef>
  800d6e:	e9 26 fb ff ff       	jmp    800899 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800d73:	83 c4 5c             	add    $0x5c,%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	83 ec 28             	sub    $0x28,%esp
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d8a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d8e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	74 30                	je     800dcc <vsnprintf+0x51>
  800d9c:	85 d2                	test   %edx,%edx
  800d9e:	7e 2c                	jle    800dcc <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800da0:	8b 45 14             	mov    0x14(%ebp),%eax
  800da3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800da7:	8b 45 10             	mov    0x10(%ebp),%eax
  800daa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db5:	c7 04 24 31 08 80 00 	movl   $0x800831,(%esp)
  800dbc:	e8 b5 fa ff ff       	call   800876 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800dc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dca:	eb 05                	jmp    800dd1 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800dcc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800dd9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ddc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de0:	8b 45 10             	mov    0x10(%ebp),%eax
  800de3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 82 ff ff ff       	call   800d7b <vsnprintf>
	va_end(ap);

	return rc;
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    
  800dfb:	00 00                	add    %al,(%eax)
  800dfd:	00 00                	add    %al,(%eax)
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
  8012c3:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012d2:	00 
  8012d3:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  8012da:	e8 25 f3 ff ff       	call   800604 <_panic>

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
  801330:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  801382:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801389:	00 
  80138a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801391:	00 
  801392:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801399:	e8 66 f2 ff ff       	call   800604 <_panic>

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
  8013e0:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  8013e7:	00 
  8013e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ef:	00 
  8013f0:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  8013f7:	e8 08 f2 ff ff       	call   800604 <_panic>

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
  80143e:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801445:	00 
  801446:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80144d:	00 
  80144e:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801455:	e8 aa f1 ff ff       	call   800604 <_panic>

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
  80149c:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  8014a3:	00 
  8014a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ab:	00 
  8014ac:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  8014b3:	e8 4c f1 ff ff       	call   800604 <_panic>

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

008014c5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  8014ec:	7e 28                	jle    801516 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  801501:	00 
  801502:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801509:	00 
  80150a:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801511:	e8 ee f0 ff ff       	call   800604 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801516:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801519:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80151c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80151f:	89 ec                	mov    %ebp,%esp
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 38             	sub    $0x38,%esp
  801529:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80152c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80152f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801532:	bb 00 00 00 00       	mov    $0x0,%ebx
  801537:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80153f:	8b 55 08             	mov    0x8(%ebp),%edx
  801542:	89 df                	mov    %ebx,%edi
  801544:	89 de                	mov    %ebx,%esi
  801546:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801548:	85 c0                	test   %eax,%eax
  80154a:	7e 28                	jle    801574 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80154c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801550:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801557:	00 
  801558:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  80155f:	00 
  801560:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801567:	00 
  801568:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  80156f:	e8 90 f0 ff ff       	call   800604 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801574:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801577:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80157a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80157d:	89 ec                	mov    %ebp,%esp
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80158a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80158d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801590:	be 00 00 00 00       	mov    $0x0,%esi
  801595:	b8 0c 00 00 00       	mov    $0xc,%eax
  80159a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80159d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8015a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015b1:	89 ec                	mov    %ebp,%esp
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 38             	sub    $0x38,%esp
  8015bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8015ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d1:	89 cb                	mov    %ecx,%ebx
  8015d3:	89 cf                	mov    %ecx,%edi
  8015d5:	89 ce                	mov    %ecx,%esi
  8015d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	7e 28                	jle    801605 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8015e8:	00 
  8015e9:	c7 44 24 08 5f 2d 80 	movl   $0x802d5f,0x8(%esp)
  8015f0:	00 
  8015f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015f8:	00 
  8015f9:	c7 04 24 7c 2d 80 00 	movl   $0x802d7c,(%esp)
  801600:	e8 ff ef ff ff       	call   800604 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801605:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801608:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80160b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80160e:	89 ec                	mov    %ebp,%esp
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <sys_change_pr>:

int 
sys_change_pr(int pr)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 0c             	sub    $0xc,%esp
  801618:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80161b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80161e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801621:	b9 00 00 00 00       	mov    $0x0,%ecx
  801626:	b8 0e 00 00 00       	mov    $0xe,%eax
  80162b:	8b 55 08             	mov    0x8(%ebp),%edx
  80162e:	89 cb                	mov    %ecx,%ebx
  801630:	89 cf                	mov    %ecx,%edi
  801632:	89 ce                	mov    %ecx,%esi
  801634:	cd 30                	int    $0x30

int 
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  801636:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801639:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80163c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80163f:	89 ec                	mov    %ebp,%esp
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    
	...

00801644 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80164a:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801651:	75 3c                	jne    80168f <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801653:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80165a:	00 
  80165b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801662:	ee 
  801663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166a:	e8 dd fc ff ff       	call   80134c <sys_page_alloc>
  80166f:	85 c0                	test   %eax,%eax
  801671:	79 1c                	jns    80168f <set_pgfault_handler+0x4b>
            panic("set_pgfault_handler:sys_page_alloc failed");
  801673:	c7 44 24 08 8c 2d 80 	movl   $0x802d8c,0x8(%esp)
  80167a:	00 
  80167b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801682:	00 
  801683:	c7 04 24 ee 2d 80 00 	movl   $0x802dee,(%esp)
  80168a:	e8 75 ef ff ff       	call   800604 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801697:	c7 44 24 04 d0 16 80 	movl   $0x8016d0,0x4(%esp)
  80169e:	00 
  80169f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a6:	e8 78 fe ff ff       	call   801523 <sys_env_set_pgfault_upcall>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	79 1c                	jns    8016cb <set_pgfault_handler+0x87>
        panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8016af:	c7 44 24 08 b8 2d 80 	movl   $0x802db8,0x8(%esp)
  8016b6:	00 
  8016b7:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8016be:	00 
  8016bf:	c7 04 24 ee 2d 80 00 	movl   $0x802dee,(%esp)
  8016c6:	e8 39 ef ff ff       	call   800604 <_panic>
}
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    
  8016cd:	00 00                	add    %al,(%eax)
	...

008016d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016d1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8016d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8016d8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx # trap-time eip
  8016db:	8b 54 24 28          	mov    0x28(%esp),%edx
    subl $0x4, 0x30(%esp) # we have to use subl now because we can't use after popfl
  8016df:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    movl 0x30(%esp), %eax # trap-time esp-4
  8016e4:	8b 44 24 30          	mov    0x30(%esp),%eax
    movl %edx, (%eax)
  8016e8:	89 10                	mov    %edx,(%eax)
    addl $0x8, %esp
  8016ea:	83 c4 08             	add    $0x8,%esp
    
	// Restore the trap-time registers.  After you do this, you
    // can no longer modify any general-purpose registers.
    // LAB 4: Your code here.
    popal
  8016ed:	61                   	popa   

    // Restore eflags from the stack.  After you do this, you can
    // no longer use arithmetic operations or anything else that
    // modifies eflags.
    // LAB 4: Your code here.
    addl $0x4, %esp #eip
  8016ee:	83 c4 04             	add    $0x4,%esp
    popfl
  8016f1:	9d                   	popf   

    // Switch back to the adjusted trap-time stack.
    // LAB 4: Your code here.
    popl %esp
  8016f2:	5c                   	pop    %esp

    // Return to re-execute the instruction that faulted.
    // LAB 4: Your code here.
    ret
  8016f3:	c3                   	ret    
	...

00801700 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	05 00 00 00 30       	add    $0x30000000,%eax
  80170b:	c1 e8 0c             	shr    $0xc,%eax
}
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	89 04 24             	mov    %eax,(%esp)
  80171c:	e8 df ff ff ff       	call   801700 <fd2num>
  801721:	05 20 00 0d 00       	add    $0xd0020,%eax
  801726:	c1 e0 0c             	shl    $0xc,%eax
}
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	53                   	push   %ebx
  80172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801732:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801737:	a8 01                	test   $0x1,%al
  801739:	74 34                	je     80176f <fd_alloc+0x44>
  80173b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801740:	a8 01                	test   $0x1,%al
  801742:	74 32                	je     801776 <fd_alloc+0x4b>
  801744:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801749:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	c1 ea 16             	shr    $0x16,%edx
  801750:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801757:	f6 c2 01             	test   $0x1,%dl
  80175a:	74 1f                	je     80177b <fd_alloc+0x50>
  80175c:	89 c2                	mov    %eax,%edx
  80175e:	c1 ea 0c             	shr    $0xc,%edx
  801761:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801768:	f6 c2 01             	test   $0x1,%dl
  80176b:	75 17                	jne    801784 <fd_alloc+0x59>
  80176d:	eb 0c                	jmp    80177b <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80176f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801774:	eb 05                	jmp    80177b <fd_alloc+0x50>
  801776:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80177b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
  801782:	eb 17                	jmp    80179b <fd_alloc+0x70>
  801784:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801789:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80178e:	75 b9                	jne    801749 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801790:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801796:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80179b:	5b                   	pop    %ebx
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017a9:	83 fa 1f             	cmp    $0x1f,%edx
  8017ac:	77 3f                	ja     8017ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017ae:	81 c2 00 00 0d 00    	add    $0xd0000,%edx
  8017b4:	c1 e2 0c             	shl    $0xc,%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017b7:	89 d0                	mov    %edx,%eax
  8017b9:	c1 e8 16             	shr    $0x16,%eax
  8017bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017c8:	f6 c1 01             	test   $0x1,%cl
  8017cb:	74 20                	je     8017ed <fd_lookup+0x4f>
  8017cd:	89 d0                	mov    %edx,%eax
  8017cf:	c1 e8 0c             	shr    $0xc,%eax
  8017d2:	8b 0c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%ecx
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017de:	f6 c1 01             	test   $0x1,%cl
  8017e1:	74 0a                	je     8017ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e6:	89 10                	mov    %edx,(%eax)
//cprintf("fd_loop: return\n");
	return 0;
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 14             	sub    $0x14,%esp
  8017f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (devtab[i]->dev_id == dev_id) {
  801801:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  801807:	75 17                	jne    801820 <dev_lookup+0x31>
  801809:	eb 07                	jmp    801812 <dev_lookup+0x23>
  80180b:	39 0a                	cmp    %ecx,(%edx)
  80180d:	75 11                	jne    801820 <dev_lookup+0x31>
  80180f:	90                   	nop
  801810:	eb 05                	jmp    801817 <dev_lookup+0x28>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801812:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801817:	89 13                	mov    %edx,(%ebx)
			return 0;
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
  80181e:	eb 35                	jmp    801855 <dev_lookup+0x66>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	8b 14 85 7c 2e 80 00 	mov    0x802e7c(,%eax,4),%edx
  80182a:	85 d2                	test   %edx,%edx
  80182c:	75 dd                	jne    80180b <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80182e:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801833:	8b 40 48             	mov    0x48(%eax),%eax
  801836:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80183a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183e:	c7 04 24 fc 2d 80 00 	movl   $0x802dfc,(%esp)
  801845:	e8 b5 ee ff ff       	call   8006ff <cprintf>
	*dev = 0;
  80184a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801850:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801855:	83 c4 14             	add    $0x14,%esp
  801858:	5b                   	pop    %ebx
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 38             	sub    $0x38,%esp
  801861:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801864:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801867:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80186a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186d:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801871:	89 3c 24             	mov    %edi,(%esp)
  801874:	e8 87 fe ff ff       	call   801700 <fd2num>
  801879:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80187c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801880:	89 04 24             	mov    %eax,(%esp)
  801883:	e8 16 ff ff ff       	call   80179e <fd_lookup>
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 05                	js     801893 <fd_close+0x38>
	    || fd != fd2)
  80188e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801891:	74 0e                	je     8018a1 <fd_close+0x46>
		return (must_exist ? r : 0);
  801893:	89 f0                	mov    %esi,%eax
  801895:	84 c0                	test   %al,%al
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
  80189c:	0f 44 d8             	cmove  %eax,%ebx
  80189f:	eb 3d                	jmp    8018de <fd_close+0x83>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	8b 07                	mov    (%edi),%eax
  8018aa:	89 04 24             	mov    %eax,(%esp)
  8018ad:	e8 3d ff ff ff       	call   8017ef <dev_lookup>
  8018b2:	89 c3                	mov    %eax,%ebx
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 16                	js     8018ce <fd_close+0x73>
		if (dev->dev_close)
  8018b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018be:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	74 07                	je     8018ce <fd_close+0x73>
			r = (*dev->dev_close)(fd);
  8018c7:	89 3c 24             	mov    %edi,(%esp)
  8018ca:	ff d0                	call   *%eax
  8018cc:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d9:	e8 2b fb ff ff       	call   801409 <sys_page_unmap>
	return r;
}
  8018de:	89 d8                	mov    %ebx,%eax
  8018e0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018e3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018e6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018e9:	89 ec                	mov    %ebp,%esp
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	e8 99 fe ff ff       	call   80179e <fd_lookup>
  801905:	85 c0                	test   %eax,%eax
  801907:	78 13                	js     80191c <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801909:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801910:	00 
  801911:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801914:	89 04 24             	mov    %eax,(%esp)
  801917:	e8 3f ff ff ff       	call   80185b <fd_close>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <close_all>:

void
close_all(void)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801925:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80192a:	89 1c 24             	mov    %ebx,(%esp)
  80192d:	e8 bb ff ff ff       	call   8018ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801932:	83 c3 01             	add    $0x1,%ebx
  801935:	83 fb 20             	cmp    $0x20,%ebx
  801938:	75 f0                	jne    80192a <close_all+0xc>
		close(i);
}
  80193a:	83 c4 14             	add    $0x14,%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 58             	sub    $0x58,%esp
  801946:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801949:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80194c:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80194f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801952:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	89 04 24             	mov    %eax,(%esp)
  80195f:	e8 3a fe ff ff       	call   80179e <fd_lookup>
  801964:	89 c3                	mov    %eax,%ebx
  801966:	85 c0                	test   %eax,%eax
  801968:	0f 88 e1 00 00 00    	js     801a4f <dup+0x10f>
		return r;
	close(newfdnum);
  80196e:	89 3c 24             	mov    %edi,(%esp)
  801971:	e8 77 ff ff ff       	call   8018ed <close>

	newfd = INDEX2FD(newfdnum);
  801976:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80197c:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80197f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801982:	89 04 24             	mov    %eax,(%esp)
  801985:	e8 86 fd ff ff       	call   801710 <fd2data>
  80198a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80198c:	89 34 24             	mov    %esi,(%esp)
  80198f:	e8 7c fd ff ff       	call   801710 <fd2data>
  801994:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801997:	89 d8                	mov    %ebx,%eax
  801999:	c1 e8 16             	shr    $0x16,%eax
  80199c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019a3:	a8 01                	test   $0x1,%al
  8019a5:	74 46                	je     8019ed <dup+0xad>
  8019a7:	89 d8                	mov    %ebx,%eax
  8019a9:	c1 e8 0c             	shr    $0xc,%eax
  8019ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019b3:	f6 c2 01             	test   $0x1,%dl
  8019b6:	74 35                	je     8019ed <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8019c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019d6:	00 
  8019d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e2:	e8 c4 f9 ff ff       	call   8013ab <sys_page_map>
  8019e7:	89 c3                	mov    %eax,%ebx
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 3b                	js     801a28 <dup+0xe8>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	c1 ea 0c             	shr    $0xc,%edx
  8019f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a02:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a06:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a11:	00 
  801a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a1d:	e8 89 f9 ff ff       	call   8013ab <sys_page_map>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	85 c0                	test   %eax,%eax
  801a26:	79 25                	jns    801a4d <dup+0x10d>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a28:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a33:	e8 d1 f9 ff ff       	call   801409 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a46:	e8 be f9 ff ff       	call   801409 <sys_page_unmap>
	return r;
  801a4b:	eb 02                	jmp    801a4f <dup+0x10f>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801a4d:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801a4f:	89 d8                	mov    %ebx,%eax
  801a51:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a54:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a57:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a5a:	89 ec                	mov    %ebp,%esp
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	53                   	push   %ebx
  801a62:	83 ec 24             	sub    $0x24,%esp
  801a65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
//cprintf("Read in\n");
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	89 1c 24             	mov    %ebx,(%esp)
  801a72:	e8 27 fd ff ff       	call   80179e <fd_lookup>
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 6d                	js     801ae8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a85:	8b 00                	mov    (%eax),%eax
  801a87:	89 04 24             	mov    %eax,(%esp)
  801a8a:	e8 60 fd ff ff       	call   8017ef <dev_lookup>
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 55                	js     801ae8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a96:	8b 50 08             	mov    0x8(%eax),%edx
  801a99:	83 e2 03             	and    $0x3,%edx
  801a9c:	83 fa 01             	cmp    $0x1,%edx
  801a9f:	75 23                	jne    801ac4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801aa1:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801aa6:	8b 40 48             	mov    0x48(%eax),%eax
  801aa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab1:	c7 04 24 40 2e 80 00 	movl   $0x802e40,(%esp)
  801ab8:	e8 42 ec ff ff       	call   8006ff <cprintf>
		return -E_INVAL;
  801abd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ac2:	eb 24                	jmp    801ae8 <read+0x8a>
	}
	if (!dev->dev_read)
  801ac4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac7:	8b 52 08             	mov    0x8(%edx),%edx
  801aca:	85 d2                	test   %edx,%edx
  801acc:	74 15                	je     801ae3 <read+0x85>
		return -E_NOT_SUPP;
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
  801ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ad1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801adc:	89 04 24             	mov    %eax,(%esp)
  801adf:	ff d2                	call   *%edx
  801ae1:	eb 05                	jmp    801ae8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801ae3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
//cprintf("read: get to return\n");
	return (*dev->dev_read)(fd, buf, n);
}
  801ae8:	83 c4 24             	add    $0x24,%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
  801af7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
  801b02:	85 f6                	test   %esi,%esi
  801b04:	74 30                	je     801b36 <readn+0x48>
  801b06:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b0b:	89 f2                	mov    %esi,%edx
  801b0d:	29 c2                	sub    %eax,%edx
  801b0f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b13:	03 45 0c             	add    0xc(%ebp),%eax
  801b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1a:	89 3c 24             	mov    %edi,(%esp)
  801b1d:	e8 3c ff ff ff       	call   801a5e <read>
		if (m < 0)
  801b22:	85 c0                	test   %eax,%eax
  801b24:	78 10                	js     801b36 <readn+0x48>
			return m;
		if (m == 0)
  801b26:	85 c0                	test   %eax,%eax
  801b28:	74 0a                	je     801b34 <readn+0x46>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b2a:	01 c3                	add    %eax,%ebx
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	39 f3                	cmp    %esi,%ebx
  801b30:	72 d9                	jb     801b0b <readn+0x1d>
  801b32:	eb 02                	jmp    801b36 <readn+0x48>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801b34:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801b36:	83 c4 1c             	add    $0x1c,%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	53                   	push   %ebx
  801b42:	83 ec 24             	sub    $0x24,%esp
  801b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4f:	89 1c 24             	mov    %ebx,(%esp)
  801b52:	e8 47 fc ff ff       	call   80179e <fd_lookup>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 68                	js     801bc3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b65:	8b 00                	mov    (%eax),%eax
  801b67:	89 04 24             	mov    %eax,(%esp)
  801b6a:	e8 80 fc ff ff       	call   8017ef <dev_lookup>
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 50                	js     801bc3 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b76:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b7a:	75 23                	jne    801b9f <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b7c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b81:	8b 40 48             	mov    0x48(%eax),%eax
  801b84:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8c:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801b93:	e8 67 eb ff ff       	call   8006ff <cprintf>
		return -E_INVAL;
  801b98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b9d:	eb 24                	jmp    801bc3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba2:	8b 52 0c             	mov    0xc(%edx),%edx
  801ba5:	85 d2                	test   %edx,%edx
  801ba7:	74 15                	je     801bbe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ba9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bb7:	89 04 24             	mov    %eax,(%esp)
  801bba:	ff d2                	call   *%edx
  801bbc:	eb 05                	jmp    801bc3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801bbe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801bc3:	83 c4 24             	add    $0x24,%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <seek>:

int
seek(int fdnum, off_t offset)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bcf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd9:	89 04 24             	mov    %eax,(%esp)
  801bdc:	e8 bd fb ff ff       	call   80179e <fd_lookup>
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 0e                	js     801bf3 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801be5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801be8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801beb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 24             	sub    $0x24,%esp
  801bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c06:	89 1c 24             	mov    %ebx,(%esp)
  801c09:	e8 90 fb ff ff       	call   80179e <fd_lookup>
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 61                	js     801c73 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1c:	8b 00                	mov    (%eax),%eax
  801c1e:	89 04 24             	mov    %eax,(%esp)
  801c21:	e8 c9 fb ff ff       	call   8017ef <dev_lookup>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 49                	js     801c73 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c31:	75 23                	jne    801c56 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c33:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c38:	8b 40 48             	mov    0x48(%eax),%eax
  801c3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c43:	c7 04 24 1c 2e 80 00 	movl   $0x802e1c,(%esp)
  801c4a:	e8 b0 ea ff ff       	call   8006ff <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c54:	eb 1d                	jmp    801c73 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c59:	8b 52 18             	mov    0x18(%edx),%edx
  801c5c:	85 d2                	test   %edx,%edx
  801c5e:	74 0e                	je     801c6e <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c63:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	ff d2                	call   *%edx
  801c6c:	eb 05                	jmp    801c73 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c6e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c73:	83 c4 24             	add    $0x24,%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	53                   	push   %ebx
  801c7d:	83 ec 24             	sub    $0x24,%esp
  801c80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8d:	89 04 24             	mov    %eax,(%esp)
  801c90:	e8 09 fb ff ff       	call   80179e <fd_lookup>
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 52                	js     801ceb <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca3:	8b 00                	mov    (%eax),%eax
  801ca5:	89 04 24             	mov    %eax,(%esp)
  801ca8:	e8 42 fb ff ff       	call   8017ef <dev_lookup>
  801cad:	85 c0                	test   %eax,%eax
  801caf:	78 3a                	js     801ceb <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801cb8:	74 2c                	je     801ce6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cbd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cc4:	00 00 00 
	stat->st_isdir = 0;
  801cc7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cce:	00 00 00 
	stat->st_dev = dev;
  801cd1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801cd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cde:	89 14 24             	mov    %edx,(%esp)
  801ce1:	ff 50 14             	call   *0x14(%eax)
  801ce4:	eb 05                	jmp    801ceb <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ce6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ceb:	83 c4 24             	add    $0x24,%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 18             	sub    $0x18,%esp
  801cf7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cfa:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801cfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d04:	00 
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	89 04 24             	mov    %eax,(%esp)
  801d0b:	e8 bc 01 00 00       	call   801ecc <open>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 1b                	js     801d31 <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1d:	89 1c 24             	mov    %ebx,(%esp)
  801d20:	e8 54 ff ff ff       	call   801c79 <fstat>
  801d25:	89 c6                	mov    %eax,%esi
	close(fd);
  801d27:	89 1c 24             	mov    %ebx,(%esp)
  801d2a:	e8 be fb ff ff       	call   8018ed <close>
	return r;
  801d2f:	89 f3                	mov    %esi,%ebx
}
  801d31:	89 d8                	mov    %ebx,%eax
  801d33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d36:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d39:	89 ec                	mov    %ebp,%esp
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    
  801d3d:	00 00                	add    %al,(%eax)
	...

00801d40 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 18             	sub    $0x18,%esp
  801d46:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d49:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d50:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801d57:	75 11                	jne    801d6a <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d60:	e8 5c 08 00 00       	call   8025c1 <ipc_find_env>
  801d65:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d6a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d71:	00 
  801d72:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d79:	00 
  801d7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d7e:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801d83:	89 04 24             	mov    %eax,(%esp)
  801d86:	e8 cb 07 00 00       	call   802556 <ipc_send>
//cprintf("fsipc: ipc_recv\n");
	return ipc_recv(NULL, dstva, NULL);
  801d8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d92:	00 
  801d93:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d9e:	e8 4d 07 00 00       	call   8024f0 <ipc_recv>
}
  801da3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801da6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801da9:	89 ec                	mov    %ebp,%esp
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	53                   	push   %ebx
  801db1:	83 ec 14             	sub    $0x14,%esp
  801db4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	8b 40 0c             	mov    0xc(%eax),%eax
  801dbd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	b8 05 00 00 00       	mov    $0x5,%eax
  801dcc:	e8 6f ff ff ff       	call   801d40 <fsipc>
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	78 2b                	js     801e00 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801dd5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ddc:	00 
  801ddd:	89 1c 24             	mov    %ebx,(%esp)
  801de0:	e8 66 f0 ff ff       	call   800e4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801de5:	a1 80 50 80 00       	mov    0x805080,%eax
  801dea:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801df0:	a1 84 50 80 00       	mov    0x805084,%eax
  801df5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801dfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e00:	83 c4 14             	add    $0x14,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    

00801e06 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e12:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801e17:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1c:	b8 06 00 00 00       	mov    $0x6,%eax
  801e21:	e8 1a ff ff ff       	call   801d40 <fsipc>
}
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	56                   	push   %esi
  801e2c:	53                   	push   %ebx
  801e2d:	83 ec 10             	sub    $0x10,%esp
  801e30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
//cprintf("devfile_read: into\n");
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	8b 40 0c             	mov    0xc(%eax),%eax
  801e39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801e3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e44:	ba 00 00 00 00       	mov    $0x0,%edx
  801e49:	b8 03 00 00 00       	mov    $0x3,%eax
  801e4e:	e8 ed fe ff ff       	call   801d40 <fsipc>
  801e53:	89 c3                	mov    %eax,%ebx
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 6a                	js     801ec3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e59:	39 c6                	cmp    %eax,%esi
  801e5b:	73 24                	jae    801e81 <devfile_read+0x59>
  801e5d:	c7 44 24 0c 8c 2e 80 	movl   $0x802e8c,0xc(%esp)
  801e64:	00 
  801e65:	c7 44 24 08 93 2e 80 	movl   $0x802e93,0x8(%esp)
  801e6c:	00 
  801e6d:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  801e74:	00 
  801e75:	c7 04 24 a8 2e 80 00 	movl   $0x802ea8,(%esp)
  801e7c:	e8 83 e7 ff ff       	call   800604 <_panic>
	assert(r <= PGSIZE);
  801e81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e86:	7e 24                	jle    801eac <devfile_read+0x84>
  801e88:	c7 44 24 0c b3 2e 80 	movl   $0x802eb3,0xc(%esp)
  801e8f:	00 
  801e90:	c7 44 24 08 93 2e 80 	movl   $0x802e93,0x8(%esp)
  801e97:	00 
  801e98:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e9f:	00 
  801ea0:	c7 04 24 a8 2e 80 00 	movl   $0x802ea8,(%esp)
  801ea7:	e8 58 e7 ff ff       	call   800604 <_panic>
	memmove(buf, &fsipcbuf, r);
  801eac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801eb7:	00 
  801eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebb:	89 04 24             	mov    %eax,(%esp)
  801ebe:	e8 79 f1 ff ff       	call   80103c <memmove>
//cprintf("devfile_read: return\n");
	return r;
}
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    

00801ecc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	56                   	push   %esi
  801ed0:	53                   	push   %ebx
  801ed1:	83 ec 20             	sub    $0x20,%esp
  801ed4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ed7:	89 34 24             	mov    %esi,(%esp)
  801eda:	e8 21 ef ff ff       	call   800e00 <strlen>
		return -E_BAD_PATH;
  801edf:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ee4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ee9:	7f 5e                	jg     801f49 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eee:	89 04 24             	mov    %eax,(%esp)
  801ef1:	e8 35 f8 ff ff       	call   80172b <fd_alloc>
  801ef6:	89 c3                	mov    %eax,%ebx
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 4d                	js     801f49 <open+0x7d>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801efc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f00:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f07:	e8 3f ef ff ff       	call   800e4b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f17:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1c:	e8 1f fe ff ff       	call   801d40 <fsipc>
  801f21:	89 c3                	mov    %eax,%ebx
  801f23:	85 c0                	test   %eax,%eax
  801f25:	79 15                	jns    801f3c <open+0x70>
		fd_close(fd, 0);
  801f27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f2e:	00 
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	89 04 24             	mov    %eax,(%esp)
  801f35:	e8 21 f9 ff ff       	call   80185b <fd_close>
		return r;
  801f3a:	eb 0d                	jmp    801f49 <open+0x7d>
	}

	return fd2num(fd);
  801f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3f:	89 04 24             	mov    %eax,(%esp)
  801f42:	e8 b9 f7 ff ff       	call   801700 <fd2num>
  801f47:	89 c3                	mov    %eax,%ebx
}
  801f49:	89 d8                	mov    %ebx,%eax
  801f4b:	83 c4 20             	add    $0x20,%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
	...

00801f60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 18             	sub    $0x18,%esp
  801f66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f69:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f72:	89 04 24             	mov    %eax,(%esp)
  801f75:	e8 96 f7 ff ff       	call   801710 <fd2data>
  801f7a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f7c:	c7 44 24 04 bf 2e 80 	movl   $0x802ebf,0x4(%esp)
  801f83:	00 
  801f84:	89 34 24             	mov    %esi,(%esp)
  801f87:	e8 bf ee ff ff       	call   800e4b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f8c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f8f:	2b 03                	sub    (%ebx),%eax
  801f91:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f97:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f9e:	00 00 00 
	stat->st_dev = &devpipe;
  801fa1:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801fa8:	30 80 00 
	return 0;
}
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb0:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fb3:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fb6:	89 ec                	mov    %ebp,%esp
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    

00801fba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 14             	sub    $0x14,%esp
  801fc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fc4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fcf:	e8 35 f4 ff ff       	call   801409 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fd4:	89 1c 24             	mov    %ebx,(%esp)
  801fd7:	e8 34 f7 ff ff       	call   801710 <fd2data>
  801fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe7:	e8 1d f4 ff ff       	call   801409 <sys_page_unmap>
}
  801fec:	83 c4 14             	add    $0x14,%esp
  801fef:	5b                   	pop    %ebx
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    

00801ff2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 2c             	sub    $0x2c,%esp
  801ffb:	89 c7                	mov    %eax,%edi
  801ffd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802000:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802005:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802008:	89 3c 24             	mov    %edi,(%esp)
  80200b:	e8 fc 05 00 00       	call   80260c <pageref>
  802010:	89 c6                	mov    %eax,%esi
  802012:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802015:	89 04 24             	mov    %eax,(%esp)
  802018:	e8 ef 05 00 00       	call   80260c <pageref>
  80201d:	39 c6                	cmp    %eax,%esi
  80201f:	0f 94 c0             	sete   %al
  802022:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802025:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  80202b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80202e:	39 cb                	cmp    %ecx,%ebx
  802030:	75 08                	jne    80203a <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802032:	83 c4 2c             	add    $0x2c,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80203a:	83 f8 01             	cmp    $0x1,%eax
  80203d:	75 c1                	jne    802000 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80203f:	8b 52 58             	mov    0x58(%edx),%edx
  802042:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802046:	89 54 24 08          	mov    %edx,0x8(%esp)
  80204a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80204e:	c7 04 24 c6 2e 80 00 	movl   $0x802ec6,(%esp)
  802055:	e8 a5 e6 ff ff       	call   8006ff <cprintf>
  80205a:	eb a4                	jmp    802000 <_pipeisclosed+0xe>

0080205c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	57                   	push   %edi
  802060:	56                   	push   %esi
  802061:	53                   	push   %ebx
  802062:	83 ec 2c             	sub    $0x2c,%esp
  802065:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802068:	89 34 24             	mov    %esi,(%esp)
  80206b:	e8 a0 f6 ff ff       	call   801710 <fd2data>
  802070:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802072:	bf 00 00 00 00       	mov    $0x0,%edi
  802077:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80207b:	75 50                	jne    8020cd <devpipe_write+0x71>
  80207d:	eb 5c                	jmp    8020db <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80207f:	89 da                	mov    %ebx,%edx
  802081:	89 f0                	mov    %esi,%eax
  802083:	e8 6a ff ff ff       	call   801ff2 <_pipeisclosed>
  802088:	85 c0                	test   %eax,%eax
  80208a:	75 53                	jne    8020df <devpipe_write+0x83>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80208c:	e8 8b f2 ff ff       	call   80131c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802091:	8b 43 04             	mov    0x4(%ebx),%eax
  802094:	8b 13                	mov    (%ebx),%edx
  802096:	83 c2 20             	add    $0x20,%edx
  802099:	39 d0                	cmp    %edx,%eax
  80209b:	73 e2                	jae    80207f <devpipe_write+0x23>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80209d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a0:	0f b6 14 3a          	movzbl (%edx,%edi,1),%edx
  8020a4:	88 55 e7             	mov    %dl,-0x19(%ebp)
  8020a7:	89 c2                	mov    %eax,%edx
  8020a9:	c1 fa 1f             	sar    $0x1f,%edx
  8020ac:	c1 ea 1b             	shr    $0x1b,%edx
  8020af:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8020b2:	83 e1 1f             	and    $0x1f,%ecx
  8020b5:	29 d1                	sub    %edx,%ecx
  8020b7:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8020bb:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8020bf:	83 c0 01             	add    $0x1,%eax
  8020c2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c5:	83 c7 01             	add    $0x1,%edi
  8020c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cb:	74 0e                	je     8020db <devpipe_write+0x7f>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d0:	8b 13                	mov    (%ebx),%edx
  8020d2:	83 c2 20             	add    $0x20,%edx
  8020d5:	39 d0                	cmp    %edx,%eax
  8020d7:	73 a6                	jae    80207f <devpipe_write+0x23>
  8020d9:	eb c2                	jmp    80209d <devpipe_write+0x41>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020db:	89 f8                	mov    %edi,%eax
  8020dd:	eb 05                	jmp    8020e4 <devpipe_write+0x88>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020df:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020e4:	83 c4 2c             	add    $0x2c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    

008020ec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	83 ec 28             	sub    $0x28,%esp
  8020f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020fb:	8b 7d 08             	mov    0x8(%ebp),%edi
//cprintf("devpipe_read\n");
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020fe:	89 3c 24             	mov    %edi,(%esp)
  802101:	e8 0a f6 ff ff       	call   801710 <fd2data>
  802106:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802108:	be 00 00 00 00       	mov    $0x0,%esi
  80210d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802111:	75 47                	jne    80215a <devpipe_read+0x6e>
  802113:	eb 52                	jmp    802167 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802115:	89 f0                	mov    %esi,%eax
  802117:	eb 5e                	jmp    802177 <devpipe_read+0x8b>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802119:	89 da                	mov    %ebx,%edx
  80211b:	89 f8                	mov    %edi,%eax
  80211d:	8d 76 00             	lea    0x0(%esi),%esi
  802120:	e8 cd fe ff ff       	call   801ff2 <_pipeisclosed>
  802125:	85 c0                	test   %eax,%eax
  802127:	75 49                	jne    802172 <devpipe_read+0x86>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
  802129:	e8 ee f1 ff ff       	call   80131c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80212e:	8b 03                	mov    (%ebx),%eax
  802130:	3b 43 04             	cmp    0x4(%ebx),%eax
  802133:	74 e4                	je     802119 <devpipe_read+0x2d>
//cprintf("devpipe_read: p_rpos=%d, p_wpos=%d\n", p->p_rpos, p->p_wpos);
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802135:	89 c2                	mov    %eax,%edx
  802137:	c1 fa 1f             	sar    $0x1f,%edx
  80213a:	c1 ea 1b             	shr    $0x1b,%edx
  80213d:	01 d0                	add    %edx,%eax
  80213f:	83 e0 1f             	and    $0x1f,%eax
  802142:	29 d0                	sub    %edx,%eax
  802144:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802149:	8b 55 0c             	mov    0xc(%ebp),%edx
  80214c:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80214f:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802152:	83 c6 01             	add    $0x1,%esi
  802155:	3b 75 10             	cmp    0x10(%ebp),%esi
  802158:	74 0d                	je     802167 <devpipe_read+0x7b>
		while (p->p_rpos == p->p_wpos) {
  80215a:	8b 03                	mov    (%ebx),%eax
  80215c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80215f:	75 d4                	jne    802135 <devpipe_read+0x49>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802161:	85 f6                	test   %esi,%esi
  802163:	75 b0                	jne    802115 <devpipe_read+0x29>
  802165:	eb b2                	jmp    802119 <devpipe_read+0x2d>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802167:	89 f0                	mov    %esi,%eax
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	eb 05                	jmp    802177 <devpipe_read+0x8b>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802172:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802177:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80217a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80217d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802180:	89 ec                	mov    %ebp,%esp
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	83 ec 48             	sub    $0x48,%esp
  80218a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80218d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802190:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802193:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802196:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802199:	89 04 24             	mov    %eax,(%esp)
  80219c:	e8 8a f5 ff ff       	call   80172b <fd_alloc>
  8021a1:	89 c3                	mov    %eax,%ebx
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	0f 88 45 01 00 00    	js     8022f0 <pipe+0x16c>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ab:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021b2:	00 
  8021b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c1:	e8 86 f1 ff ff       	call   80134c <sys_page_alloc>
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	85 c0                	test   %eax,%eax
  8021ca:	0f 88 20 01 00 00    	js     8022f0 <pipe+0x16c>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8021d3:	89 04 24             	mov    %eax,(%esp)
  8021d6:	e8 50 f5 ff ff       	call   80172b <fd_alloc>
  8021db:	89 c3                	mov    %eax,%ebx
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	0f 88 f8 00 00 00    	js     8022dd <pipe+0x159>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021ec:	00 
  8021ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021fb:	e8 4c f1 ff ff       	call   80134c <sys_page_alloc>
  802200:	89 c3                	mov    %eax,%ebx
  802202:	85 c0                	test   %eax,%eax
  802204:	0f 88 d3 00 00 00    	js     8022dd <pipe+0x159>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80220a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80220d:	89 04 24             	mov    %eax,(%esp)
  802210:	e8 fb f4 ff ff       	call   801710 <fd2data>
  802215:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802217:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80221e:	00 
  80221f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802223:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222a:	e8 1d f1 ff ff       	call   80134c <sys_page_alloc>
  80222f:	89 c3                	mov    %eax,%ebx
  802231:	85 c0                	test   %eax,%eax
  802233:	0f 88 91 00 00 00    	js     8022ca <pipe+0x146>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802239:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80223c:	89 04 24             	mov    %eax,(%esp)
  80223f:	e8 cc f4 ff ff       	call   801710 <fd2data>
  802244:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80224b:	00 
  80224c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802250:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802257:	00 
  802258:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802263:	e8 43 f1 ff ff       	call   8013ab <sys_page_map>
  802268:	89 c3                	mov    %eax,%ebx
  80226a:	85 c0                	test   %eax,%eax
  80226c:	78 4c                	js     8022ba <pipe+0x136>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80226e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802277:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802279:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80227c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802283:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802289:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80228c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80228e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802291:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802298:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80229b:	89 04 24             	mov    %eax,(%esp)
  80229e:	e8 5d f4 ff ff       	call   801700 <fd2num>
  8022a3:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8022a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022a8:	89 04 24             	mov    %eax,(%esp)
  8022ab:	e8 50 f4 ff ff       	call   801700 <fd2num>
  8022b0:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8022b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022b8:	eb 36                	jmp    8022f0 <pipe+0x16c>

    err3:
	sys_page_unmap(0, va);
  8022ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022c5:	e8 3f f1 ff ff       	call   801409 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d8:	e8 2c f1 ff ff       	call   801409 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022eb:	e8 19 f1 ff ff       	call   801409 <sys_page_unmap>
    err:
	return r;
}
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8022f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8022f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8022fb:	89 ec                	mov    %ebp,%esp
  8022fd:	5d                   	pop    %ebp
  8022fe:	c3                   	ret    

008022ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
  802302:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802305:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	89 04 24             	mov    %eax,(%esp)
  802312:	e8 87 f4 ff ff       	call   80179e <fd_lookup>
  802317:	85 c0                	test   %eax,%eax
  802319:	78 15                	js     802330 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231e:	89 04 24             	mov    %eax,(%esp)
  802321:	e8 ea f3 ff ff       	call   801710 <fd2data>
	return _pipeisclosed(fd, p);
  802326:	89 c2                	mov    %eax,%edx
  802328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232b:	e8 c2 fc ff ff       	call   801ff2 <_pipeisclosed>
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    
	...

00802340 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802343:	b8 00 00 00 00       	mov    $0x0,%eax
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    

0080234a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802350:	c7 44 24 04 de 2e 80 	movl   $0x802ede,0x4(%esp)
  802357:	00 
  802358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235b:	89 04 24             	mov    %eax,(%esp)
  80235e:	e8 e8 ea ff ff       	call   800e4b <strcpy>
	return 0;
}
  802363:	b8 00 00 00 00       	mov    $0x0,%eax
  802368:	c9                   	leave  
  802369:	c3                   	ret    

0080236a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	57                   	push   %edi
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
  802370:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802376:	be 00 00 00 00       	mov    $0x0,%esi
  80237b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80237f:	74 43                	je     8023c4 <devcons_write+0x5a>
  802381:	b8 00 00 00 00       	mov    $0x0,%eax
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802386:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80238c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80238f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802391:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802394:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802399:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80239c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a0:	03 45 0c             	add    0xc(%ebp),%eax
  8023a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a7:	89 3c 24             	mov    %edi,(%esp)
  8023aa:	e8 8d ec ff ff       	call   80103c <memmove>
		sys_cputs(buf, m);
  8023af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023b3:	89 3c 24             	mov    %edi,(%esp)
  8023b6:	e8 75 ee ff ff       	call   801230 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023bb:	01 de                	add    %ebx,%esi
  8023bd:	89 f0                	mov    %esi,%eax
  8023bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023c2:	72 c8                	jb     80238c <devcons_write+0x22>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023c4:	89 f0                	mov    %esi,%eax
  8023c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8023cc:	5b                   	pop    %ebx
  8023cd:	5e                   	pop    %esi
  8023ce:	5f                   	pop    %edi
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    

008023d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023d7:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023e0:	75 07                	jne    8023e9 <devcons_read+0x18>
  8023e2:	eb 31                	jmp    802415 <devcons_read+0x44>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023e4:	e8 33 ef ff ff       	call   80131c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	e8 6a ee ff ff       	call   80125f <sys_cgetc>
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	74 eb                	je     8023e4 <devcons_read+0x13>
  8023f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	78 16                	js     802415 <devcons_read+0x44>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023ff:	83 f8 04             	cmp    $0x4,%eax
  802402:	74 0c                	je     802410 <devcons_read+0x3f>
		return 0;
	*(char*)vbuf = c;
  802404:	8b 45 0c             	mov    0xc(%ebp),%eax
  802407:	88 10                	mov    %dl,(%eax)
	return 1;
  802409:	b8 01 00 00 00       	mov    $0x1,%eax
  80240e:	eb 05                	jmp    802415 <devcons_read+0x44>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802410:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802415:	c9                   	leave  
  802416:	c3                   	ret    

00802417 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
  80241a:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80241d:	8b 45 08             	mov    0x8(%ebp),%eax
  802420:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802423:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80242a:	00 
  80242b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80242e:	89 04 24             	mov    %eax,(%esp)
  802431:	e8 fa ed ff ff       	call   801230 <sys_cputs>
}
  802436:	c9                   	leave  
  802437:	c3                   	ret    

00802438 <getchar>:

int
getchar(void)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80243e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802445:	00 
  802446:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80244d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802454:	e8 05 f6 ff ff       	call   801a5e <read>
	if (r < 0)
  802459:	85 c0                	test   %eax,%eax
  80245b:	78 0f                	js     80246c <getchar+0x34>
		return r;
	if (r < 1)
  80245d:	85 c0                	test   %eax,%eax
  80245f:	7e 06                	jle    802467 <getchar+0x2f>
		return -E_EOF;
	return c;
  802461:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802465:	eb 05                	jmp    80246c <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802467:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80246c:	c9                   	leave  
  80246d:	c3                   	ret    

0080246e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80246e:	55                   	push   %ebp
  80246f:	89 e5                	mov    %esp,%ebp
  802471:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247b:	8b 45 08             	mov    0x8(%ebp),%eax
  80247e:	89 04 24             	mov    %eax,(%esp)
  802481:	e8 18 f3 ff ff       	call   80179e <fd_lookup>
  802486:	85 c0                	test   %eax,%eax
  802488:	78 11                	js     80249b <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80248a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802493:	39 10                	cmp    %edx,(%eax)
  802495:	0f 94 c0             	sete   %al
  802498:	0f b6 c0             	movzbl %al,%eax
}
  80249b:	c9                   	leave  
  80249c:	c3                   	ret    

0080249d <opencons>:

int
opencons(void)
{
  80249d:	55                   	push   %ebp
  80249e:	89 e5                	mov    %esp,%ebp
  8024a0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a6:	89 04 24             	mov    %eax,(%esp)
  8024a9:	e8 7d f2 ff ff       	call   80172b <fd_alloc>
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	78 3c                	js     8024ee <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024b9:	00 
  8024ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c8:	e8 7f ee ff ff       	call   80134c <sys_page_alloc>
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	78 1d                	js     8024ee <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024d1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8024d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024da:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024df:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024e6:	89 04 24             	mov    %eax,(%esp)
  8024e9:	e8 12 f2 ff ff       	call   801700 <fd2num>
}
  8024ee:	c9                   	leave  
  8024ef:	c3                   	ret    

008024f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	56                   	push   %esi
  8024f4:	53                   	push   %ebx
  8024f5:	83 ec 10             	sub    $0x10,%esp
  8024f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8024fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024fe:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802501:	85 db                	test   %ebx,%ebx
  802503:	74 06                	je     80250b <ipc_recv+0x1b>
  802505:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (perm_store) *perm_store = 0;
  80250b:	85 f6                	test   %esi,%esi
  80250d:	74 06                	je     802515 <ipc_recv+0x25>
  80250f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (!pg) pg = (void*) -1;
  802515:	85 c0                	test   %eax,%eax
  802517:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80251c:	0f 44 c2             	cmove  %edx,%eax
    int ret = sys_ipc_recv(pg);
  80251f:	89 04 24             	mov    %eax,(%esp)
  802522:	e8 8e f0 ff ff       	call   8015b5 <sys_ipc_recv>
    if (ret) return ret;
  802527:	85 c0                	test   %eax,%eax
  802529:	75 24                	jne    80254f <ipc_recv+0x5f>
    if (from_env_store)
  80252b:	85 db                	test   %ebx,%ebx
  80252d:	74 0a                	je     802539 <ipc_recv+0x49>
        *from_env_store = thisenv->env_ipc_from;
  80252f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802534:	8b 40 74             	mov    0x74(%eax),%eax
  802537:	89 03                	mov    %eax,(%ebx)
    if (perm_store)
  802539:	85 f6                	test   %esi,%esi
  80253b:	74 0a                	je     802547 <ipc_recv+0x57>
        *perm_store = thisenv->env_ipc_perm;
  80253d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802542:	8b 40 78             	mov    0x78(%eax),%eax
  802545:	89 06                	mov    %eax,(%esi)
//cprintf("ipc_recv: return\n");
    return thisenv->env_ipc_value;
  802547:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80254c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	5b                   	pop    %ebx
  802553:	5e                   	pop    %esi
  802554:	5d                   	pop    %ebp
  802555:	c3                   	ret    

00802556 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802556:	55                   	push   %ebp
  802557:	89 e5                	mov    %esp,%ebp
  802559:	57                   	push   %edi
  80255a:	56                   	push   %esi
  80255b:	53                   	push   %ebx
  80255c:	83 ec 1c             	sub    $0x1c,%esp
  80255f:	8b 75 08             	mov    0x8(%ebp),%esi
  802562:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802565:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802568:	85 db                	test   %ebx,%ebx
  80256a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80256f:	0f 44 d8             	cmove  %eax,%ebx
  802572:	eb 2a                	jmp    80259e <ipc_send+0x48>
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
//cprintf("ipc_send: loop\n");
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802574:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802577:	74 20                	je     802599 <ipc_send+0x43>
  802579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80257d:	c7 44 24 08 ea 2e 80 	movl   $0x802eea,0x8(%esp)
  802584:	00 
  802585:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80258c:	00 
  80258d:	c7 04 24 01 2f 80 00 	movl   $0x802f01,(%esp)
  802594:	e8 6b e0 ff ff       	call   800604 <_panic>
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
  802599:	e8 7e ed ff ff       	call   80131c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
    int ret;
    while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80259e:	8b 45 14             	mov    0x14(%ebp),%eax
  8025a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025ad:	89 34 24             	mov    %esi,(%esp)
  8025b0:	e8 cc ef ff ff       	call   801581 <sys_ipc_try_send>
  8025b5:	85 c0                	test   %eax,%eax
  8025b7:	75 bb                	jne    802574 <ipc_send+0x1e>
        if (ret == 0) break;
        if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
//cprintf("ipc_send: sys_yield\n");
        sys_yield();
    }
}
  8025b9:	83 c4 1c             	add    $0x1c,%esp
  8025bc:	5b                   	pop    %ebx
  8025bd:	5e                   	pop    %esi
  8025be:	5f                   	pop    %edi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    

008025c1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025c1:	55                   	push   %ebp
  8025c2:	89 e5                	mov    %esp,%ebp
  8025c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8025c7:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8025cc:	39 c8                	cmp    %ecx,%eax
  8025ce:	74 19                	je     8025e9 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025d0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8025d5:	89 c2                	mov    %eax,%edx
  8025d7:	c1 e2 07             	shl    $0x7,%edx
  8025da:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025e0:	8b 52 50             	mov    0x50(%edx),%edx
  8025e3:	39 ca                	cmp    %ecx,%edx
  8025e5:	75 14                	jne    8025fb <ipc_find_env+0x3a>
  8025e7:	eb 05                	jmp    8025ee <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025e9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8025ee:	c1 e0 07             	shl    $0x7,%eax
  8025f1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8025f6:	8b 40 40             	mov    0x40(%eax),%eax
  8025f9:	eb 0e                	jmp    802609 <ipc_find_env+0x48>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025fb:	83 c0 01             	add    $0x1,%eax
  8025fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802603:	75 d0                	jne    8025d5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802605:	66 b8 00 00          	mov    $0x0,%ax
}
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    
	...

0080260c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80260c:	55                   	push   %ebp
  80260d:	89 e5                	mov    %esp,%ebp
  80260f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802612:	89 d0                	mov    %edx,%eax
  802614:	c1 e8 16             	shr    $0x16,%eax
  802617:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80261e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802623:	f6 c1 01             	test   $0x1,%cl
  802626:	74 1d                	je     802645 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802628:	c1 ea 0c             	shr    $0xc,%edx
  80262b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802632:	f6 c2 01             	test   $0x1,%dl
  802635:	74 0e                	je     802645 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802637:	c1 ea 0c             	shr    $0xc,%edx
  80263a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802641:	ef 
  802642:	0f b7 c0             	movzwl %ax,%eax
}
  802645:	5d                   	pop    %ebp
  802646:	c3                   	ret    
	...

00802650 <__udivdi3>:
  802650:	83 ec 1c             	sub    $0x1c,%esp
  802653:	89 7c 24 14          	mov    %edi,0x14(%esp)
  802657:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80265b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80265f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802663:	89 74 24 10          	mov    %esi,0x10(%esp)
  802667:	8b 74 24 24          	mov    0x24(%esp),%esi
  80266b:	85 ff                	test   %edi,%edi
  80266d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802671:	89 44 24 08          	mov    %eax,0x8(%esp)
  802675:	89 cd                	mov    %ecx,%ebp
  802677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80267b:	75 33                	jne    8026b0 <__udivdi3+0x60>
  80267d:	39 f1                	cmp    %esi,%ecx
  80267f:	77 57                	ja     8026d8 <__udivdi3+0x88>
  802681:	85 c9                	test   %ecx,%ecx
  802683:	75 0b                	jne    802690 <__udivdi3+0x40>
  802685:	b8 01 00 00 00       	mov    $0x1,%eax
  80268a:	31 d2                	xor    %edx,%edx
  80268c:	f7 f1                	div    %ecx
  80268e:	89 c1                	mov    %eax,%ecx
  802690:	89 f0                	mov    %esi,%eax
  802692:	31 d2                	xor    %edx,%edx
  802694:	f7 f1                	div    %ecx
  802696:	89 c6                	mov    %eax,%esi
  802698:	8b 44 24 04          	mov    0x4(%esp),%eax
  80269c:	f7 f1                	div    %ecx
  80269e:	89 f2                	mov    %esi,%edx
  8026a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	c3                   	ret    
  8026b0:	31 d2                	xor    %edx,%edx
  8026b2:	31 c0                	xor    %eax,%eax
  8026b4:	39 f7                	cmp    %esi,%edi
  8026b6:	77 e8                	ja     8026a0 <__udivdi3+0x50>
  8026b8:	0f bd cf             	bsr    %edi,%ecx
  8026bb:	83 f1 1f             	xor    $0x1f,%ecx
  8026be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8026c2:	75 2c                	jne    8026f0 <__udivdi3+0xa0>
  8026c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8026c8:	76 04                	jbe    8026ce <__udivdi3+0x7e>
  8026ca:	39 f7                	cmp    %esi,%edi
  8026cc:	73 d2                	jae    8026a0 <__udivdi3+0x50>
  8026ce:	31 d2                	xor    %edx,%edx
  8026d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8026d5:	eb c9                	jmp    8026a0 <__udivdi3+0x50>
  8026d7:	90                   	nop
  8026d8:	89 f2                	mov    %esi,%edx
  8026da:	f7 f1                	div    %ecx
  8026dc:	31 d2                	xor    %edx,%edx
  8026de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8026e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8026e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8026ea:	83 c4 1c             	add    $0x1c,%esp
  8026ed:	c3                   	ret    
  8026ee:	66 90                	xchg   %ax,%ax
  8026f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8026fa:	89 ea                	mov    %ebp,%edx
  8026fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  802700:	d3 e7                	shl    %cl,%edi
  802702:	89 c1                	mov    %eax,%ecx
  802704:	d3 ea                	shr    %cl,%edx
  802706:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80270b:	09 fa                	or     %edi,%edx
  80270d:	89 f7                	mov    %esi,%edi
  80270f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802713:	89 f2                	mov    %esi,%edx
  802715:	8b 74 24 08          	mov    0x8(%esp),%esi
  802719:	d3 e5                	shl    %cl,%ebp
  80271b:	89 c1                	mov    %eax,%ecx
  80271d:	d3 ef                	shr    %cl,%edi
  80271f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802724:	d3 e2                	shl    %cl,%edx
  802726:	89 c1                	mov    %eax,%ecx
  802728:	d3 ee                	shr    %cl,%esi
  80272a:	09 d6                	or     %edx,%esi
  80272c:	89 fa                	mov    %edi,%edx
  80272e:	89 f0                	mov    %esi,%eax
  802730:	f7 74 24 0c          	divl   0xc(%esp)
  802734:	89 d7                	mov    %edx,%edi
  802736:	89 c6                	mov    %eax,%esi
  802738:	f7 e5                	mul    %ebp
  80273a:	39 d7                	cmp    %edx,%edi
  80273c:	72 22                	jb     802760 <__udivdi3+0x110>
  80273e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  802742:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802747:	d3 e5                	shl    %cl,%ebp
  802749:	39 c5                	cmp    %eax,%ebp
  80274b:	73 04                	jae    802751 <__udivdi3+0x101>
  80274d:	39 d7                	cmp    %edx,%edi
  80274f:	74 0f                	je     802760 <__udivdi3+0x110>
  802751:	89 f0                	mov    %esi,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	e9 46 ff ff ff       	jmp    8026a0 <__udivdi3+0x50>
  80275a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802760:	8d 46 ff             	lea    -0x1(%esi),%eax
  802763:	31 d2                	xor    %edx,%edx
  802765:	8b 74 24 10          	mov    0x10(%esp),%esi
  802769:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80276d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  802771:	83 c4 1c             	add    $0x1c,%esp
  802774:	c3                   	ret    
	...

00802780 <__umoddi3>:
  802780:	83 ec 1c             	sub    $0x1c,%esp
  802783:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  802787:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80278b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80278f:	89 74 24 10          	mov    %esi,0x10(%esp)
  802793:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802797:	8b 74 24 24          	mov    0x24(%esp),%esi
  80279b:	85 ed                	test   %ebp,%ebp
  80279d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8027a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027a5:	89 cf                	mov    %ecx,%edi
  8027a7:	89 04 24             	mov    %eax,(%esp)
  8027aa:	89 f2                	mov    %esi,%edx
  8027ac:	75 1a                	jne    8027c8 <__umoddi3+0x48>
  8027ae:	39 f1                	cmp    %esi,%ecx
  8027b0:	76 4e                	jbe    802800 <__umoddi3+0x80>
  8027b2:	f7 f1                	div    %ecx
  8027b4:	89 d0                	mov    %edx,%eax
  8027b6:	31 d2                	xor    %edx,%edx
  8027b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027c4:	83 c4 1c             	add    $0x1c,%esp
  8027c7:	c3                   	ret    
  8027c8:	39 f5                	cmp    %esi,%ebp
  8027ca:	77 54                	ja     802820 <__umoddi3+0xa0>
  8027cc:	0f bd c5             	bsr    %ebp,%eax
  8027cf:	83 f0 1f             	xor    $0x1f,%eax
  8027d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d6:	75 60                	jne    802838 <__umoddi3+0xb8>
  8027d8:	3b 0c 24             	cmp    (%esp),%ecx
  8027db:	0f 87 07 01 00 00    	ja     8028e8 <__umoddi3+0x168>
  8027e1:	89 f2                	mov    %esi,%edx
  8027e3:	8b 34 24             	mov    (%esp),%esi
  8027e6:	29 ce                	sub    %ecx,%esi
  8027e8:	19 ea                	sbb    %ebp,%edx
  8027ea:	89 34 24             	mov    %esi,(%esp)
  8027ed:	8b 04 24             	mov    (%esp),%eax
  8027f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8027f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8027f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8027fc:	83 c4 1c             	add    $0x1c,%esp
  8027ff:	c3                   	ret    
  802800:	85 c9                	test   %ecx,%ecx
  802802:	75 0b                	jne    80280f <__umoddi3+0x8f>
  802804:	b8 01 00 00 00       	mov    $0x1,%eax
  802809:	31 d2                	xor    %edx,%edx
  80280b:	f7 f1                	div    %ecx
  80280d:	89 c1                	mov    %eax,%ecx
  80280f:	89 f0                	mov    %esi,%eax
  802811:	31 d2                	xor    %edx,%edx
  802813:	f7 f1                	div    %ecx
  802815:	8b 04 24             	mov    (%esp),%eax
  802818:	f7 f1                	div    %ecx
  80281a:	eb 98                	jmp    8027b4 <__umoddi3+0x34>
  80281c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802820:	89 f2                	mov    %esi,%edx
  802822:	8b 74 24 10          	mov    0x10(%esp),%esi
  802826:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80282a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80282e:	83 c4 1c             	add    $0x1c,%esp
  802831:	c3                   	ret    
  802832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802838:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80283d:	89 e8                	mov    %ebp,%eax
  80283f:	bd 20 00 00 00       	mov    $0x20,%ebp
  802844:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  802848:	89 fa                	mov    %edi,%edx
  80284a:	d3 e0                	shl    %cl,%eax
  80284c:	89 e9                	mov    %ebp,%ecx
  80284e:	d3 ea                	shr    %cl,%edx
  802850:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802855:	09 c2                	or     %eax,%edx
  802857:	8b 44 24 08          	mov    0x8(%esp),%eax
  80285b:	89 14 24             	mov    %edx,(%esp)
  80285e:	89 f2                	mov    %esi,%edx
  802860:	d3 e7                	shl    %cl,%edi
  802862:	89 e9                	mov    %ebp,%ecx
  802864:	d3 ea                	shr    %cl,%edx
  802866:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80286b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80286f:	d3 e6                	shl    %cl,%esi
  802871:	89 e9                	mov    %ebp,%ecx
  802873:	d3 e8                	shr    %cl,%eax
  802875:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80287a:	09 f0                	or     %esi,%eax
  80287c:	8b 74 24 08          	mov    0x8(%esp),%esi
  802880:	f7 34 24             	divl   (%esp)
  802883:	d3 e6                	shl    %cl,%esi
  802885:	89 74 24 08          	mov    %esi,0x8(%esp)
  802889:	89 d6                	mov    %edx,%esi
  80288b:	f7 e7                	mul    %edi
  80288d:	39 d6                	cmp    %edx,%esi
  80288f:	89 c1                	mov    %eax,%ecx
  802891:	89 d7                	mov    %edx,%edi
  802893:	72 3f                	jb     8028d4 <__umoddi3+0x154>
  802895:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802899:	72 35                	jb     8028d0 <__umoddi3+0x150>
  80289b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80289f:	29 c8                	sub    %ecx,%eax
  8028a1:	19 fe                	sbb    %edi,%esi
  8028a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028a8:	89 f2                	mov    %esi,%edx
  8028aa:	d3 e8                	shr    %cl,%eax
  8028ac:	89 e9                	mov    %ebp,%ecx
  8028ae:	d3 e2                	shl    %cl,%edx
  8028b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028b5:	09 d0                	or     %edx,%eax
  8028b7:	89 f2                	mov    %esi,%edx
  8028b9:	d3 ea                	shr    %cl,%edx
  8028bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8028bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8028c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8028c7:	83 c4 1c             	add    $0x1c,%esp
  8028ca:	c3                   	ret    
  8028cb:	90                   	nop
  8028cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028d0:	39 d6                	cmp    %edx,%esi
  8028d2:	75 c7                	jne    80289b <__umoddi3+0x11b>
  8028d4:	89 d7                	mov    %edx,%edi
  8028d6:	89 c1                	mov    %eax,%ecx
  8028d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8028dc:	1b 3c 24             	sbb    (%esp),%edi
  8028df:	eb ba                	jmp    80289b <__umoddi3+0x11b>
  8028e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e8:	39 f5                	cmp    %esi,%ebp
  8028ea:	0f 82 f1 fe ff ff    	jb     8027e1 <__umoddi3+0x61>
  8028f0:	e9 f8 fe ff ff       	jmp    8027ed <__umoddi3+0x6d>
