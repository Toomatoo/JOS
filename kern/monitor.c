// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.
// See

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <inc/stdarg.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display a procedure of backtrace", mon_backtrace },
	{ "showmappings", "Displaythe physical page mappings at a range of virtual space", mon_showmappings},
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

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

	cprintf ("Stack backtrace:\n");

	while (ebp != 0) {
		cprintf ("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
			arg0, arg1, arg2, arg3, arg4);

		struct Eipdebuginfo info;
		if (debuginfo_eip((uintptr_t)eip, &info) < 0)
			return -1;
		
		char eip_file[50]; 
		strcpy(eip_file, info.eip_file);

		int eip_line = info.eip_line;

		char eip_fn_name[50];
		strncpy(eip_fn_name, info.eip_fn_name, info.eip_fn_namelen); 
		eip_fn_name[info.eip_fn_namelen] = '\0';
		
		uintptr_t eip_fn_line = (uintptr_t)eip - info.eip_fn_addr;


		cprintf ("         %s:%d: %s+%u\n", eip_file, eip_line, 
			eip_fn_name, eip_fn_line);

		ebp = (uint32_t*) ebp[0];
		eip = (uint32_t*) ebp[1];
		arg0 = ebp[2];
		arg1 = ebp[3];
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}


int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	// The instruction 'showmappings' must be attached with 2 arguments
	if(argc > 3)
		return -1;

	// Get the 2 arguments
	extern pde_t *kern_pgdir;
	unsigned int num[2];

	num[0] = strtol(argv[1], NULL, 16);
	num[1] = strtol(argv[2], NULL, 16);

	// Show the mappings
	for(; num[0]<=num[1]; num[0] += PGSIZE) {
		unsigned int pte;
		struct PageInfo *pageofva = page_lookup(kern_pgdir, &num[0], (pte_t **)(&pte));

		if(!pageofva) {
			cprintf("0x%x: There is no physical page here.");
			continue;
		}

		unsigned int perm = (unsigned int) (pte - PTE_ADDR(pte));

		cprintf("0x%x: physical address - 0x%x, permission bits: 0x%x", 
			PTE_ADDR(pte), perm);
	}
	return 0;
}
/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("%CredWelcome to the %CgrnJOS kernel %Cpurmonitor!\n");
	cprintf("%CredType %Cgrn'help' for a list of %Cpurcommands.\n");
	
	// Lab1 Ex8 Q4
	//unsigned int i = 0x00646c72;
    //cprintf("H%x Wo%s\n", 57616, &i);
    
    // Lab1 Ex8 Q5
    //cprintf("x=%d y=%d\n", 3);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
