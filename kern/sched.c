#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	/*
	if(curenv != NULL) {
		idle = curenv->env_link;
	}
	else {
		idle = envs;	
	}	

//cprintf("****Get idle start\n");

	int i;
	bool found = false;
//cprintf("**idle env_status: %x\n", envs[0].env_status);
//cprintf("**idle env_status: %x\n", envs[1].env_status);
	for(i=0; i<NENV; i++) {
		// Check
		if(idle->env_status == ENV_RUNNABLE) {
			found = true;
			break;
		}
//cprintf("**Continue finding\n");
		// Go to the next
		if(idle->env_link == NULL) {
//cprintf("****back\n");
			idle = &envs[0];
		}
		else
			idle = idle->env_link;
	}
	// Did not find one, check for the current env
//cprintf("****Found one!\n");
	if(!found && curenv && curenv->env_status == ENV_RUNNING) {
//cprintf("****run curenv!\n");
		env_run(curenv);
	}
	// If found one, then run it.
	if(found) {
//cprintf("**Success to find one: \n");
		env_run(idle);
	}

*/
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_link->env_id);
		else cur = 0;
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
			if (j == 1) 
				cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);

	// sched_halt never returns
cprintf("**Fail to find one\n");
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

