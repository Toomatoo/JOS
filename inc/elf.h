#ifndef JOS_INC_ELF_H
#define JOS_INC_ELF_H

#define ELF_MAGIC 0x464C457FU	/* "\x7FELF" in little endian */

struct Elf {
	uint32_t e_magic;		// must equal ELF_MAGIC
	uint8_t e_elf[12];		// some information
	uint16_t e_type;		// format of the ELF
	uint16_t e_machine;		// machine architecture
	uint32_t e_version;		// version of ELF
	uint32_t e_entry;		// entry of program

	uint32_t e_phoff;		// offset to Program Header Table
	uint32_t e_shoff;		// offset to Section Header Table
	
	uint32_t e_flags;		// 
	uint16_t e_ehsize;		// size of ELF header

	uint16_t e_phentsize;	// size of Program Header Table entry
	uint16_t e_phnum;		// sum of Program Header Table entry

	uint16_t e_shentsize;	// size of Section Header Table entry
	uint16_t e_shnum;		// sum of Section Header Table entry
	uint16_t e_shstrndx;
};

struct Proghdr {
	uint32_t p_type;		// type of segment
	uint32_t p_offset;		// offset to segment
	uint32_t p_va;			// load virtual address
	uint32_t p_pa;			// load physical address
	uint32_t p_filesz;		// size of map in disk
	uint32_t p_memsz;		// size of map in memory
	uint32_t p_flags;		// some flag bits
	uint32_t p_align;		// align
};

struct Secthdr {
	uint32_t sh_name;
	uint32_t sh_type;
	uint32_t sh_flags;
	uint32_t sh_addr;
	uint32_t sh_offset;
	uint32_t sh_size;
	uint32_t sh_link;
	uint32_t sh_info;
	uint32_t sh_addralign;
	uint32_t sh_entsize;
};

// Values for Proghdr::p_type
#define ELF_PROG_LOAD		1

// Flag bits for Proghdr::p_flags
#define ELF_PROG_FLAG_EXEC	1
#define ELF_PROG_FLAG_WRITE	2
#define ELF_PROG_FLAG_READ	4

// Values for Secthdr::sh_type
#define ELF_SHT_NULL		0
#define ELF_SHT_PROGBITS	1
#define ELF_SHT_SYMTAB		2
#define ELF_SHT_STRTAB		3

// Values for Secthdr::sh_name
#define ELF_SHN_UNDEF		0

#endif /* !JOS_INC_ELF_H */
