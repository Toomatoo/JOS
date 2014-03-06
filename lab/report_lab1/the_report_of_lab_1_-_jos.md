# Report Of Lab 1, JOS  

**1100012713 Siyuan Liu**   
5th March, 2014



## Introduction
###0.1 Check for the type of my machine, whether it is an i386 machine

We can type `uname -a` to check for the type with the following knowledge:

* i386/i686 denotes the 32-bit	
* x86-64 denotes the 64-bit
		
###0.2 Clone the codes of JOS to my host

	mkdir ~/JOS
	cd ~/JOS
	git clone http://pdos.csail.mit.edu/6.828/2012/jos.git lab
	cd lab
		
To do my works, I'd like to use `git` to control the versions of my codes.


###0.3 Compiler Toolchain

I have to check for whether the tools for compiling are working well. And the handout suggest me to adding the following line to `conf/env.mk`: this should be added when my machine does not exist the Compiler Tools. However most of the machines with  a `gcc` do not need now.

	GCCPREFIX=

###0.4 Install the Qemu

	git clone http://pdos.csail.mit.edu/6.828/qemu.git -b 6.828-0.15
	sudo apt-get install libsdl1.2-dev
	./configure --disable-kvm [--prefix=PFX] [--target-list="i386-softmmu x86_64-softmmu"]
	make
	make install
			
The `prefix` argument specifies where to install `QEMU`; without it QEMU will install to `/usr/local` by default. The `target-list` argument simply slims down the architectures QEMU will build support for. If use the prefix to control the procedure of installation of qemu, I can not use qemu. In the meantime, target-list is needed to be set.			

And I found QEMU Doc: http://wiki.qemu.org/download/qemu-doc.html
	 
## Part 1 PC Bootstrap
### 1.1 Getting Started with x86 assembly
	
> **Exercise 1** Familiarize yourself with the assembly language materials available on the 6.828 reference page. You don't have to read them now, but you'll almost certainly want to refer to some of this material when reading and writing x86 assembly.
> 
> We do recommend reading the section "The Syntax" in Brennan's Guide to Inline Assembly. It gives a good (and quite brief) description of the AT&T assembly syntax we'll be using with the GNU assembler in JOS.

About this exercise, I have done the following things:

* Familar with the PC Assembly Language Book

	We will use GNU assembler but this book is written by NASM assembler.

_Exercise 1 End_
	
### 1.2 Simulating the x86
In this part, the lab want us to be familar with the `qemu` and start JOS to see some outcome of the lab1. My classmates and I have thought about why we are supposed to use `qemu`. And I concluded that qemu can provide VGA display which means that we can see diverse colors by changing the codes(It is just the Challenge of Lab 1).

### 1.3 The PC's Physical Address Space

<table align="center"><tr><td>
<pre>
+------------------+  &lt;- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  &lt;- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  &lt;- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  &lt;- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  &lt;- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  &lt;- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  &lt;- 0x00000000
</pre>
</td></tr>
</table>
	
* I got some points about the PC's physical address space of JOS:

	* 0x00000000~0x000FFFFF: Low Memory only random-access memory (RAM) that an early PC could use;
	* 0x000A0000~0x000FFFFF: used by the hardware, the most import part is BIOS  
	* 80286 and 80386 support the 16MB and 4GB, nevertheless they preserve the low address space of 1MB to ensure backward compatibility with existing software. So the address space has a "hole". And address 0x000A0000 divides the space into 2 parts: conventional memory(or low, the first 640KB), extended memory(other part).  
	* At the very top of the space is reserved by the BIOS for some PCI devices.
	* Now there is 64-bit PC, and it is the same that there must be another hole to keep compatibility with 32-bit PC.
	* JOS only use 256MB of the first physical address space.
	
### 1.4 The ROM BIOS

##### To begin with JOS, I am supposed to open two terminal windows:####

* make qemu-gdb: start up with qemu, the qemu stops before the processor executes the first instruction and waits for a debugging connection from GDB
* gdb: this gdb links with the gdb. With the operation on this gdb, we can debug with JOS.
	##### Why the qemu starts like that?

	* The `qemu` starts at some address, 0xffff0, which is in the ROM BIOS. When the computer power up or reset, the BIOS get the controls and execute first. 
	* The qemu emulator comes with the BIOS
	* The process first enters into the real mode
	* There is only 16bytes for the BIOS	

##### After some work to initial some hardware, the BIOS reads the boot loader from the disk and transfer control to it.

> **Exercise 2** Use GDB's si (Step Instruction) command to trace into the ROM BIOS for a few more instructions, and try to guess what it might be doing. You might want to look at Phil Storrs I/O Ports Description, as well as other materials on the 6.828 reference materials page. No need to figure out all the details - just the general idea of what the BIOS is doing first. 

About this exercise, I have done the following things:
	
* Check for the manual of `gdb`, and get familiar with some operations, such as `si`, `c`, `layout split`, `b`, etc.
* Take a look a I/O manual, but not much.

_Exercise 2 End_

## Part 2 The Boot Loader
### 2.1 From BIOS into boot loader
We aim to load boot loader into memory, and transfer the control from BIOS to boot loader. So, I'd to like to list some important points for the boot loader:

1. Sectors in disk: it is the unit of disk. The space of reading and writting must align on a sector boundry. 

2. The first sector in disk is called `boot loader`. When the BIOS find a bootable hard disk, the first 512 bytes will be loaded into the physical address space from `0x7c00` to `0x7dff`. Then the BIOS will use `jmp` to transfer the control to the boot loader 

3. JOS's boot loader files are boot.S and main.c
	* `boot.S`: this part of codes is executed in real mode which then transfer to protected mode. Jump into main.c  
		At the beginning of the Boot Loader, `boot.S` set the cr0 to set the real mode. cr0 is a control register, and cr0 controls the condition of the whole system not an indivitual tast.  
		Then `boot.S` transfers the kernel running on protected mode.  
		1) Disable the interrupt  
		2) Enable the physical address line 20  
		3) Switch from real mode to protected mode; still use the GDT and segment translation so the address transmision does not change during the switch  
		4) Call bootmain  
	* `main.c`: this part of codes reads kernel in the memory and control the running code to jump into it(at address 0x1000c).  
		1) Read 1st page off disk into memory  
		2) Load each segment: In disk view, first sector-boot loader(boot.S, main.c), second sector-the kernel of JOS, ELF file. 
		3) Call the entry point from the ELF header, not return.  
		call readseg to get every segment, in redseg, call readsect to get every sector
	
4. Aisassembly of the compiled boot loader, get file of obj/boot/boot.asm(actually with kernel) which is loaded at 0x7c00.

> **Exercise 3** Take a look at the lab tools guide, especially the section on GDB commands. Even if you're familiar with GDB, this includes some esoteric GDB commands that are useful for OS work.
> 
> Set a breakpoint at address 0x7c00, which is where the boot sector will be loaded. Continue execution until that breakpoint. Trace through the code in boot/boot.S, using the source code and the disassembly file obj/boot/boot.asm to keep track of where you are. Also use the x/i command in GDB to disassemble sequences of instructions in the boot loader, and compare the original boot loader source code with both the disassembly in obj/boot/boot.asm and GDB.
> 
> Trace into bootmain() in boot/main.c, and then into readsect(). Identify the exact assembly instructions that correspond to each of the statements in readsect(). Trace through the rest of readsect() and back out into bootmain(), and identify the begin and end of the for loop that reads the remaining sectors of the kernel from the disk. Find out what code will run when the loop is finished, set a breakpoint there, and continue to that breakpoint. Then step through the remainder of the boot loader.

About this exercise, I have done the following things:

* Continue to get familiar with `gdb`, make the gdb debugging get into some position of running kernel.

_Exercise 3 End_

> Be able to answer the following questions:  
> 
> 1. At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
> 2. What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?
> 3. Where is the first instruction of the kernel?
> 4. How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?
	
1. The processor enters boot loader-`boot/boot.S`, changes the last bit of cr0 to 1. Then the processor switch from 16-bit to 32-bit mode.

		44 # Switch from real to protected mode, using a bootstrap GDT
		45 # and segment translation that makes virtual addresses 
		46 # identical to their physical addresses, so that the 
		47 # effective memory map does not change during the switch.
		48 lgdt    gdtdesc
		49 movl    %cr0, %eax
		50 orl     $CR0_PE_ON, %eax
		51 movl    %eax, %cr0
2. It is obvious that the last instruction of boot loader is the call for the entry of kernel, which is line 60 in the `boot/main.c`.

		58 // call the entry point from the ELF header
		59 // note: does not return!
		60 ((void (*)(void)) (ELFHDR->e_entry))();  

3. We can type `objdump -f obj/kern/kernel` to get the entry position of kernel. Then I use gdb to stop at 0x10000c to get the first instruction of kernel.

		0x10000c:	movw   $0x1234,0x472	

4. The kernel is ELF, so I check the kernel for the details of segments. I type `objdump -x obj/kern/kernel`: then I can see the  size, load address and file off for each segment.
		
### 2.2 Boot Loader Loads the Kernel
For this part I'd like to list some points first which I learnt during reading this part: 

* The process of compiling: .c->.o object file(binary file which is assembly language), then linker combine the several object file to an ELF file(Executable and Linkable Format)
* ELF: `objdump -h obj/kern/kernel`. In .text segment, there are VMA(link address) and LMA(load address, it is a physical address). In JOS, these two address in boot loader are the same, but in kernel are not.
* boot loader and ELF kernel are loaded at 0x7c00 together: We set the link address by passing -Ttext 0x7C00 to the linker in boot/Makefrag.
* The entry of ELF is at 0x10000c: `objdump -f obj/kern/kernel`  

> **Exercise 4** Read about programming with pointers in C. The best reference for the C language is The C Programming Language by Brian Kernighan and Dennis Ritchie (known as 'K&R'). We recommend that students purchase this book (here is an Amazon Link) or find one of MIT's 7 copies.

> Read 5.1 (Pointers and Addresses) through 5.5 (Character Pointers and Functions) in K&R. Then download the code for pointers.c, run it, and make sure you understand where all of the printed values come from. In particular, make sure you understand where the pointer addresses in lines 1 and 6 come from, how all the values in lines 2 through 4 get there, and why the values printed in line 5 are seemingly corrupted.

> There are other references on pointers in C, though not as strongly recommended. A tutorial by Ted Jensen that cites K&R heavily is available in the course readings.

> Warning: Unless you are already thoroughly versed in C, do not skip or even skim this reading exercise. If you do not really understand pointers in C, you will suffer untold pain and misery in subsequent labs, and then eventually come to understand them the hard way. Trust us; you don't want to find out what "the hard way" is.

About this exercise, I reviewed some knowledge of C language, such C pointers and addresses. 

* The critical view is that the pointer increase or decreace according to their types. For example, if `int *a`, `a+1` means that the value of `a` plus `4` because `a` is a `int` type pointer;

_Exercise 4 End_

> **Exercise 5** Trace through the first few instructions of the boot loader again and identify the first instruction that would "break" or otherwise do the wrong thing if you were to get the boot loader's link address wrong. Then change the link address in boot/Makefrag to something wrong, run make clean, recompile the lab with make, and trace into the boot loader again to see what happens. Don't forget to change the link address back and make clean again afterward!

About this exercise, I have done two part of work:

1. Assume that the first instruction that would "break" is: in `obj/boot/boot.asm`

		0x7c29:	ljmp    $PROT_MODE_CSEG, $protcseg
	Because when executing the boot loader and transmission from real mode to protected mode, this line involves relative jump which may error if the link address and load address are not accordant. 

2. Modify the boot loader address which is `0x7c00` in `boot/Makefrag` to `0x8c00`: the processor crashed at
  
		0x7c2d:	ljmp   $0x8,$0x8c32 
		
	The result vertified my assumption. And we can see the jump address is related to the modified link address of boot loader, but the load adress is still 0x7c2d.
	
_Exercise 5 End_

> **Exercise 6** We can examine memory using GDB's x command. The GDB manual has full details, but for now, it is enough to know that the command x/Nx ADDR prints N words of memory at ADDR. (Note that both 'x's in the command are lowercase.) Warning: The size of a word is not a universal standard. In GNU assembly, a word is two bytes (the 'w' in xorw, which stands for word, means 2 bytes).

> Reset the machine (exit QEMU/GDB and start them again). Examine the 8 words of memory at 0x00100000 at the point the BIOS enters the boot loader, and then again at the point the boot loader enters the kernel. Why are they different? What is there at the second breakpoint? (You do not really need to use QEMU to answer this question. Just think.)

About this exercise, before loading the ELF kernel, there is some default data at 0x100000. After loading ELF kernel, the content of the kernel is at 0x100000.

I compared the changes at 0x100000 between entering boot loader(entering bootmain) and entering the kernel(finishing reading ELF and enter kernel): it is accordant with my assumption
		
		(gdb) x/8 0x100000
		0x100000:	add    %al,(%bx,%si)
		0x100002:	add    %al,(%bx,%si)
		0x100004:	add    %al,(%bx,%si)
		0x100006:	add    %al,(%bx,%si)
		0x100008:	add    %al,(%bx,%si)
		0x10000a:	add    %al,(%bx,%si)
		0x10000c:	add    %al,(%bx,%si)
		0x10000e:	add    %al,(%bx,%si)

		(gdb) x/8 0x100000
		0x100000:	add    0x1bad(%eax),%dh
		0x100006:	add    %al,(%eax)
		0x100008:	decb   0x52(%edi)
		0x10000b:	in     $0x66,%al
		0x10000d:	movl   $0xb81234,0x472
		0x100017:	add    %dl,(%ecx)
		0x100019:	add    %cl,(%edi)
		0x10001b:	and    %al,%bl
 
_Exercise 6 End_
 
		
## Part 3 The Kernel

###3.1 Using virtual memory to work around position dependence  

For this part I'd like to list some points first which I learnt during reading this part: 

* Link address: Operating system kernels often like to be linked and run at very high virtual address, such as 0xf0100000, in order to leave the lower part of the processor's virtual address space for user programs to use. But many machines do not have the physical space above 0xf0100000. So JOS design the 0xf0100000 to be a virtual address(which denotes the physical address of 0x100000). The low address is used as user address space
* The transmision between virtual address and physical address(linear addresses): until the entrypgdir is built, the address transmission will be done by using the 'pages'.(CR0_PG is set in kern/entry.S, before, boot/boot.S set up the mapping from linear addresses to physical addresses)
* Virtual address 0xf0000000 through 0xf0400000 to physical addresses 0x00000000 through 0x00400000, as well as virtual addresses 0x00000000 through 0x00400000 to physical addresses 0x00000000 through 0x00400000. Paging will transfer the low space (below 0xf0400000 which is low space for user) to other space.
	
> **Exercise 7** Use QEMU and GDB to trace into the JOS kernel and stop at the movl %eax, %cr0. Examine memory at 0x00100000 and at 0xf0100000. Now, single step over that instruction using the stepi GDB command. Again, examine memory at 0x00100000 and at 0xf0100000. Make sure you understand what just happened.
>
> What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? Comment out the movl %eax, %cr0 in kern/entry.S, trace into it, and see if you were right.

About this exercise, we are supposed to check the change from 'no-paging' to 'paging'. After cr0 paging is set, the kernel address will be transfered to high space. So, I made some experiment using gdb to check memory content before and after 'paging' is set.

	=> 0x100025:    mov    %eax,%cr0
	0x00100025 in ?? ()
	(gdb) print *0x100000
	$1 = 464367618
	(gdb) x/1 0x100000 
	0x100000:    add    0x1bad(%eax),%dh
	(gdb) x/1 0xf0100000
	0xf0100000:  (bad)  

	
	(gdb) si
	=> 0x100028:    mov    $0xf010002f,%eax
	0x00100028 in ?? ()
	(gdb) x/1 0x100000
	0x100000:    add    0x1bad(%eax),%dh
	(gdb) x/1 0xf0100000
	0xf0100000:  add    0x1bad(%eax),%dh

Actually, the entry of kernel is at 0x10000c. The code text is at 0x10000c, so it is more meaningful to check memory content at 0x10000c. We can type `x/1 0x10000c` or `x/1 0xf010000c` into gdb. I am not going to list the result here.

_Exercise 7 End_


### 3.2 Formatted Printing to the Console 

The `monitor.c` control the shell, what to display on the screen and the commands of the shell. So the defination of `print`
 is needed.
 

 
> **Exercise 8** We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

About this exercise, I am supposed to add a small fragment of code in the function `printfmt` of `lib/printfmt.c`. Bacause the function `cprintf` is a function whose sum of arguments is not uncertain. The compiler help the `printf` to collect arguments, store them in the memory and provide a pointer pointing to the argument table. 

When some function calls `cprintf`, for example, the `console` calls `cprintf`, the 'chain of print' is `cprintf`->`vcprintf`->`vprintfmt`check for argument -> `putch` output->`cputchar`output a character on concole or screen.

So, add some codes below the form "%o" in `vprintfmt` helps the processor to print octal numbers. Similar to the codes of "%u", the work is finished when I just changed the `base`(denoting scale) to 8.
		
	// (unsigned) octal
	case 'o':
	num = getuint(&ap, lflag);
	base = 8;
	goto number; 

_Exercise 8 End_


> Be able to answer the following questions:
> 
> 1. Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?
> 
> 2. Explain the a fragment of code from console.c:
> 
> 3. For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86.
> Trace the execution of the following code step-by-step:  
> 		int x = 1, y = 3, z = 4;  
> 		cprintf("x %d, y %x, z %d\n", x, y, z);  
> In the call to cprintf(), to what does fmt point? To what does ap point?  
> List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.
>   
> 4. Run the following code.  
>     unsigned int i = 0x00646c72;  
>     cprintf("H%x Wo%s", 57616, &i);  
> What is the output? Explain how this output is arrived at in the step-by-step manner of the previous exercise. Here's an ASCII table that maps bytes to characters.  
> The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set i to in order to yield the same output? Would you need to change 57616 to a different value?  
>  
> 5. In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?  
>     cprintf("x=%d y=%d", 3);
>     
> 6. Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?

1. Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?  
	
	kern/console.c provide some interface used to promote the iteraction between the hardware and other program.  
	Furthermore, console.c provides kern/printf.c mainly with the cputchar.  
	cputchar put a certain char on the screen, which is called by putch in printf.c 

2. Explain the following from console.c:   
	The purpose of this part of code is that check if the screen is full. If so, the program will set the last row to be a row of blank. And it abandons the first row, put the cursor to the start of last row. 

3. For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86. 		+ In the call to cprintf(), to what does fmt point? To what does ap point?
 		* The fmt points "x %d, y %x, z %d\n"
 		* ap points to the the table of variables.  
	+ List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.
		* In order of execution: call vcprintf to start the print, and the first character is x, so the printf will put it on the console directly-call cputchar. Then the '%' is detected by the function vprintfmt. And vprintfmt continues its step to detect 'd' which means a output format of signed decimal, then the vprintfmt drives the function printnum to put the num on the console...Following is similar which I am going to omit.
		* va_arg(ap, type) is a method of getting next argument of ap with the type. And After calling this function, ap will point to the next argument.
		* For vcprintf, the first argument fmt is "x %d, y %x, z %d\n" and the second  ap is a pointer points to the argument table(Which contains x, y, z with their types).
		
4. Run the following code.        unsigned int i = 0x00646c72;          cprintf("H%x Wo%s", 57616, &i);	
		* I have add these codes into `kern/monitor.c`, and the output of this String is 'He110 World'. The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set i to in order to yield the same output? Would you need to change 57616 to a different value?		* If big-endian, the change will effect the convert from the unsighed int i to string, not the output of 57616. (Because whether we use big-endian or little endian, the value of 57616 does not change. But it is different for the transmission from unsigned int to string)

5. In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?

		cprintf("x=%d y=%d", 3);
    * (In `lib/printfmt.c`)The function vprintfmt will find next argument by getint(according to '%d'). And we can see, if the argument table ap is not long enough, the ap will return a unknown pointer and we will get a unknown value.6. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments? 

	* We can see that in `inc/stdarg.h`, the argument table ap is initialized from the last of the argments. It means that JOS has consider the compiler's rule of converting arguments-the arguments will be pushed into stack by the order of the argument given. If we change the rule of compiler, we have to initialize the argument table reversely according to the order of the arguments.
	
	
> **Challenge** Enhance the console to allow text to be printed in different colors. The traditional way to do this is to make it interpret ANSI escape sequences embedded in the text strings printed to the console, but you may use any mechanism you like. There is plenty of information on the 6.828 reference page and elsewhere on the web on programming the VGA display hardware. If you're feeling really adventurous, you could try switching the VGA hardware into a graphics mode and making the console draw text onto the graphical frame buffer.

About this Challenge, first I'd like to show the procedure of print again: When some function calls `cprintf`, for example, the `console` calls `cprintf`, the 'chain of print' is `cprintf`->`vcprintf`->`vprintfmt`check for argument -> `putch` output->`cputchar`output a character on concole or screen -> `cons_putc` -> `cga_putc`.

And we can see the color trick in `cga_putc`:
	
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;

The argument `int c` has 32 bits, but an character is 8 bits only. So, we can utilize the high bits to add the information of color.

Firstly, bacause I want to use the hight 24 bits, so I need a varible to catch the information of color. I decided to add a global varible `int ncolor` in `lib/printfmt.c` to record the color when `%C` is detected. And I declare `int color` into `kern/console.c`, the code is:

	static void
	cga_putc(int c)
	{
		c = c + (ncolor << 8);
		// if no attribute given, then use black on white
		if (!(c & ~0xFF))
			c |= 0x0700; 
	...
	
Secondly, I need to finish the most important part-when `%C` is detected, record the color information,I have regulated the length of corlor information to be 3 bits, like color white to 'wht' And I have regulated value of color to be 3 bits, like color red to 4. All the color I defined is in lib/printfmt.c. so my critical codes are: 

	// color
	case 'C':
		// Get the color index
		
		col[0] = *(unsigned char *) fmt++;
		col[1] = *(unsigned char *) fmt++;
		col[2] = *(unsigned char *) fmt++;
		col[3] = '\0';
		// check for the color
		if (col[0] >= '0' && col[0] <= '9') {
			ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
		} 
		else {
			if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
			else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
			else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
			else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
			else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
			else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
			else ncolor = COLOR_WHT;
		}
		break;
 
 Last, display on monitor. I modify the function `monitor` in `kern/monitor.c`. I changed the hello words:
 
	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");

And the result on `qemu` is:

![](./color.jpg) 

_Challenge End_

### 3.3 The Stack  
In this part, I am supposed to explore the way C language uses the stack on the x86, and write a useful new kernel monitor function that prints the backtrace of the stack-a series of calls.  

> **Exercise 9**. Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?

I find that the the information of stack is defined in the `kern/entry.S`. Definately, in the `.data segment` of the ELF file.The initialization work of stack is that the kernel initialize the `ebp` to 0, and `esp` to `bootstacktop`. And there are bootstack's size(KSTKSIZE=32KB) and top position. Another part is `bootstacktop` denoting the base of the stack, and the stack grows towards low address space.

_Exercise 9 End_
 
The register `esp`: is the top of the stack which can decreace (Practically, expand the stack) when pushing some value onto the stack, and increace(Practically, shrink the stack) when poping some value off the stack.    
The register `ebp`: on entry to a C function, the caller saves its base on the stack, and gives its `esp` in the callee's ebp in the duration of the callee's function. `ebp` is useful for backtracing what offend current executing when some panics happen.

> **Exercise 10** To become familiar with the C calling conventions on the x86, find the address of the test_backtrace function in obj/kern/kernel.asm, set a breakpoint there, and examine what happens each time it gets called after the kernel starts. How many 32-bit words does each recursive nesting level of test_backtrace push on the stack, and what are those words?
>
>Note that, for this exercise to work properly, you should be using the patched version of QEMU available on the tools page or on Athena. Otherwise, you'll have to manually translate all breakpoint and memory addresses to linear addresses.

* Each time the test_backtrace is called means one more recursive nesting begins. In the meantime, the test_backtrace will get the argument x from the stack which is stored in register `ebx` temporarily. 
	
* For each recursive nesting level of test_backtrace, there are 32 bytes pushed on stack:
  
	`push 	%ebp`: Save the former ebp	-	4 bytes  
	`push 	%ebx`: Save the ebx bacause in this function ebx is used as a temporary variable.	-	4 bytes  
	`sub    $0x14,%esp`: Reverse a stack space of 20 bytes for some varibles.	- 	20 bytes	   
	`call 	f0100040`: For saving the register eip(return address).  	-	4 bytes
	
After studying the procedure of call, we leant more details about recursive nesting.

_Exercise 10 End_

> **Exercise 11** Implement the backtrace function as specified above. Use the same format as in the example, since otherwise the grading script will be confused. When you think you have it working right, run make grade to see if its output conforms to what our grading script expects, and fix it if it doesn't. After you have handed in your Lab 1 code, you are welcome to change the output format of the backtrace function any way you like.

After previous studying, I knew that from top to bottom of stack are:

1. Temporary varible in the callee function
2. Caller's `ebp`
3. Return address for callee `eip`
4. Arguments for callee.

So, we can call the function  `read_ebp` first to get address of `ebp`(on stack). Then according to this address, we can get `eip` and five arguments. Last, we print out these information with the given format. The critical codes are:
	
	int
	mon_backtrace(int argc, char **argv, struct Trapframe *tf)
	{
		// Lab1 Ex11.	
		uint32_t *ebp, *eip;
		uint32_t arg0, arg1, arg2, arg3, arg4;
	
		ebp = (uint32_t*) read_ebp();
	 	eip = (uint32_t*) ebp[1];
	 	arg0 = ebp[2];
	 	arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	...

_Exercise 11 End_
	
Sometimes, backtrace function makes mistakes or is interrupted. At this time, we want some debug information to find the error out. Actually, in many cases, we need the debug information.

There is a function `debuginfo_eip`, which looks up `eip` in the symbol table and returns the debugging information for that address. This function is defined in `kern/kdebug.c`.

> **Exercise 12** Modify your stack backtrace function to display, for each eip, the function name, source file name, and line number corresponding to that eip.
> 
> In debuginfo_eip, where do __STAB_* come from? This question has a long answer; to help you to discover the answer, here are some things you might want to do:
> 
> look in the file kern/kernel.ld for __STAB_*
> run i386-jos-elf-objdump -h obj/kern/kernel
> run i386-jos-elf-objdump -G obj/kern/kernel
> run i386-jos-elf-gcc -pipe -nostdinc -O2 -fno-builtin -I. -MD -Wall -Wno-format -DJOS_KERNEL -gstabs -c -S kern/init.c, and look at init.s.
> see if the bootloader loads the symbol table in memory as part of loading the kernel binary
> Complete the implementation of debuginfo_eip by inserting the call to stab_binsearch to find the line number for an address.
> 
> Add a backtrace command to the kernel monitor, and extend your implementation of mon_backtrace to call debuginfo_eip and print a line for each stack frame of the form:
> 
> K> backtrace
> Stack backtrace:
>   ebp f010ff78  eip f01008ae  args 00000001 f010ff8c 00000000 f0110580 00000000
>          kern/monitor.c:143: monitor+106
>   ebp f010ffd8  eip f0100193  args 00000000 00001aac 00000660 00000000 00000000
>          kern/init.c:49: i386_init+59
>   ebp f010fff8  eip f010003d  args 00000000 00000000 0000ffff 10cf9a00 0000ffff
>          kern/entry.S:70: <unknown>+0
> K> 
> Each line gives the file name and line within that file of the stack frame's eip, followed by the name of the function and the offset of the eip from the first instruction of the function (e.g., monitor+106 means the return eip is 106 bytes past the beginning of monitor).
> 
> Be sure to print the file and function names on a separate line, to avoid confusing the grading script.
> 
> Tip: printf format strings provide an easy, albeit obscure, way to print non-null-terminated strings like those in STABS tables.	 printf("%.*s", length, string) prints at most length characters of string. Take a look at the printf man page to find out why this works.
> 
> You may find that some functions are missing from the backtrace. For example, you will probably see a call to monitor() but not to runcmd(). This is because the compiler in-lines some function calls. Other optimizations may cause you to see unexpected line numbers. If you get rid of the -O2 from GNUMakefile, the backtraces may make more sense (but your kernel will run more slowly). 

To finish this exercise, there are 3 parts of work we need to do.

Firstly, we need complete the function `debuginfo_eip`, the fragment code of finding the corresponding line of the given `eip` is absent. The comment has suggest what to do. We can use the `lline` and `rline` gotten below the code to call `stab_binsearch` to get the line according to `addr`. The `N_SLINE` means that we want to get line number from the procedure of `stab_binsearch`.

	...
	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);

	if(lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
	...

Secondly, we need add some codes into `mon_backtrace` to display the debug information. This part is similar to Exercise 12. We just need to add what to display in `monitor`. The critical codes are:

	if (debuginfo_eip((uintptr_t)eip, &info) < 0)
		return -1;
	...
	cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
		eip_fn_name, eip_fn_line);
			
Last, we are supposed to add the command `backtrace` into the monitor's command list. This part is simple. I found the `static struct Command commands[]`. And I just added an entity into it:

	static struct Command commands[] = {
		{ "help", "Display this list of commands", mon_help },
		{ "kerninfo", "Display information about the kernel", mon_kerninfo },
		{ "backtrace", "Display a procedure of backtrace", mon_backtrace },
	};


_Exercise 12 End_

##_Report of Lab 1 End_##

