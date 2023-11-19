
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020a2b7          	lui	t0,0xc020a
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020a137          	lui	sp,0xc020a

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000b517          	auipc	a0,0xb
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020b060 <edata>
ffffffffc020003e:	00016617          	auipc	a2,0x16
ffffffffc0200042:	5c260613          	addi	a2,a2,1474 # ffffffffc0216600 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	6cd040ef          	jal	ra,ffffffffc0204f1a <memset>

    cons_init();                // init the console
ffffffffc0200052:	4b4000ef          	jal	ra,ffffffffc0200506 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	f2258593          	addi	a1,a1,-222 # ffffffffc0204f78 <etext+0x4>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	f3a50513          	addi	a0,a0,-198 # ffffffffc0204f98 <etext+0x24>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16c000ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	7c1010ef          	jal	ra,ffffffffc020202e <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	56c000ef          	jal	ra,ffffffffc02005de <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5dc000ef          	jal	ra,ffffffffc0200652 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	1b9030ef          	jal	ra,ffffffffc0203a32 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	6a8040ef          	jal	ra,ffffffffc0204726 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f8000ef          	jal	ra,ffffffffc020057a <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2cb020ef          	jal	ra,ffffffffc0202b50 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	426000ef          	jal	ra,ffffffffc02004b0 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	544000ef          	jal	ra,ffffffffc02005d2 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	089040ef          	jal	ra,ffffffffc020491a <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	ef250513          	addi	a0,a0,-270 # ffffffffc0204fa0 <etext+0x2c>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	0000bb97          	auipc	s7,0xb
ffffffffc02000c8:	f9cb8b93          	addi	s7,s7,-100 # ffffffffc020b060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f6000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e4000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	0d0000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	0000b517          	auipc	a0,0xb
ffffffffc020012a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020b060 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	3ac000ef          	jal	ra,ffffffffc0200508 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	16f040ef          	jal	ra,ffffffffc0204af0 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	13b040ef          	jal	ra,ffffffffc0204af0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3460006f          	j	ffffffffc0200508 <cons_putc>

ffffffffc02001c6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c6:	1141                	addi	sp,sp,-16
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ca:	374000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001ce:	dd75                	beqz	a0,ffffffffc02001ca <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d0:	60a2                	ld	ra,8(sp)
ffffffffc02001d2:	0141                	addi	sp,sp,16
ffffffffc02001d4:	8082                	ret

ffffffffc02001d6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d8:	00005517          	auipc	a0,0x5
ffffffffc02001dc:	e0050513          	addi	a0,a0,-512 # ffffffffc0204fd8 <etext+0x64>
void print_kerninfo(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e2:	fadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e6:	00000597          	auipc	a1,0x0
ffffffffc02001ea:	e5058593          	addi	a1,a1,-432 # ffffffffc0200036 <kern_init>
ffffffffc02001ee:	00005517          	auipc	a0,0x5
ffffffffc02001f2:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204ff8 <etext+0x84>
ffffffffc02001f6:	f99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fa:	00005597          	auipc	a1,0x5
ffffffffc02001fe:	d7a58593          	addi	a1,a1,-646 # ffffffffc0204f74 <etext>
ffffffffc0200202:	00005517          	auipc	a0,0x5
ffffffffc0200206:	e1650513          	addi	a0,a0,-490 # ffffffffc0205018 <etext+0xa4>
ffffffffc020020a:	f85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020e:	0000b597          	auipc	a1,0xb
ffffffffc0200212:	e5258593          	addi	a1,a1,-430 # ffffffffc020b060 <edata>
ffffffffc0200216:	00005517          	auipc	a0,0x5
ffffffffc020021a:	e2250513          	addi	a0,a0,-478 # ffffffffc0205038 <etext+0xc4>
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200222:	00016597          	auipc	a1,0x16
ffffffffc0200226:	3de58593          	addi	a1,a1,990 # ffffffffc0216600 <end>
ffffffffc020022a:	00005517          	auipc	a0,0x5
ffffffffc020022e:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205058 <etext+0xe4>
ffffffffc0200232:	f5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200236:	00016597          	auipc	a1,0x16
ffffffffc020023a:	7c958593          	addi	a1,a1,1993 # ffffffffc02169ff <end+0x3ff>
ffffffffc020023e:	00000797          	auipc	a5,0x0
ffffffffc0200242:	df878793          	addi	a5,a5,-520 # ffffffffc0200036 <kern_init>
ffffffffc0200246:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200254:	95be                	add	a1,a1,a5
ffffffffc0200256:	85a9                	srai	a1,a1,0xa
ffffffffc0200258:	00005517          	auipc	a0,0x5
ffffffffc020025c:	e2050513          	addi	a0,a0,-480 # ffffffffc0205078 <etext+0x104>
}
ffffffffc0200260:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200262:	f2dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200266 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00005617          	auipc	a2,0x5
ffffffffc020026c:	d4060613          	addi	a2,a2,-704 # ffffffffc0204fa8 <etext+0x34>
ffffffffc0200270:	04d00593          	li	a1,77
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	d4c50513          	addi	a0,a0,-692 # ffffffffc0204fc0 <etext+0x4c>
void print_stackframe(void) {
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	1d2000ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	00005617          	auipc	a2,0x5
ffffffffc0200288:	f0460613          	addi	a2,a2,-252 # ffffffffc0205188 <commands+0xe0>
ffffffffc020028c:	00005597          	auipc	a1,0x5
ffffffffc0200290:	f1c58593          	addi	a1,a1,-228 # ffffffffc02051a8 <commands+0x100>
ffffffffc0200294:	00005517          	auipc	a0,0x5
ffffffffc0200298:	f1c50513          	addi	a0,a0,-228 # ffffffffc02051b0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029e:	ef1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002a2:	00005617          	auipc	a2,0x5
ffffffffc02002a6:	f1e60613          	addi	a2,a2,-226 # ffffffffc02051c0 <commands+0x118>
ffffffffc02002aa:	00005597          	auipc	a1,0x5
ffffffffc02002ae:	f3e58593          	addi	a1,a1,-194 # ffffffffc02051e8 <commands+0x140>
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	efe50513          	addi	a0,a0,-258 # ffffffffc02051b0 <commands+0x108>
ffffffffc02002ba:	ed5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002be:	00005617          	auipc	a2,0x5
ffffffffc02002c2:	f3a60613          	addi	a2,a2,-198 # ffffffffc02051f8 <commands+0x150>
ffffffffc02002c6:	00005597          	auipc	a1,0x5
ffffffffc02002ca:	f5258593          	addi	a1,a1,-174 # ffffffffc0205218 <commands+0x170>
ffffffffc02002ce:	00005517          	auipc	a0,0x5
ffffffffc02002d2:	ee250513          	addi	a0,a0,-286 # ffffffffc02051b0 <commands+0x108>
ffffffffc02002d6:	eb9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e6:	ef1ff0ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f2:	1141                	addi	sp,sp,-16
ffffffffc02002f4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f6:	f71ff0ef          	jal	ra,ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002fa:	60a2                	ld	ra,8(sp)
ffffffffc02002fc:	4501                	li	a0,0
ffffffffc02002fe:	0141                	addi	sp,sp,16
ffffffffc0200300:	8082                	ret

ffffffffc0200302 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200302:	7115                	addi	sp,sp,-224
ffffffffc0200304:	e962                	sd	s8,144(sp)
ffffffffc0200306:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200308:	00005517          	auipc	a0,0x5
ffffffffc020030c:	de850513          	addi	a0,a0,-536 # ffffffffc02050f0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200310:	ed86                	sd	ra,216(sp)
ffffffffc0200312:	e9a2                	sd	s0,208(sp)
ffffffffc0200314:	e5a6                	sd	s1,200(sp)
ffffffffc0200316:	e1ca                	sd	s2,192(sp)
ffffffffc0200318:	fd4e                	sd	s3,184(sp)
ffffffffc020031a:	f952                	sd	s4,176(sp)
ffffffffc020031c:	f556                	sd	s5,168(sp)
ffffffffc020031e:	f15a                	sd	s6,160(sp)
ffffffffc0200320:	ed5e                	sd	s7,152(sp)
ffffffffc0200322:	e566                	sd	s9,136(sp)
ffffffffc0200324:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200326:	e69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	dee50513          	addi	a0,a0,-530 # ffffffffc0205118 <commands+0x70>
ffffffffc0200332:	e5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200336:	000c0563          	beqz	s8,ffffffffc0200340 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033a:	8562                	mv	a0,s8
ffffffffc020033c:	4fe000ef          	jal	ra,ffffffffc020083a <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	4581                	li	a1,0
ffffffffc0200344:	4601                	li	a2,0
ffffffffc0200346:	48a1                	li	a7,8
ffffffffc0200348:	00000073          	ecall
ffffffffc020034c:	00005c97          	auipc	s9,0x5
ffffffffc0200350:	d5cc8c93          	addi	s9,s9,-676 # ffffffffc02050a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	00005997          	auipc	s3,0x5
ffffffffc0200358:	dec98993          	addi	s3,s3,-532 # ffffffffc0205140 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00005917          	auipc	s2,0x5
ffffffffc0200360:	dec90913          	addi	s2,s2,-532 # ffffffffc0205148 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200364:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	00005b17          	auipc	s6,0x5
ffffffffc020036a:	deab0b13          	addi	s6,s6,-534 # ffffffffc0205150 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036e:	00005a97          	auipc	s5,0x5
ffffffffc0200372:	e3aa8a93          	addi	s5,s5,-454 # ffffffffc02051a8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	854e                	mv	a0,s3
ffffffffc020037a:	d1dff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037e:	842a                	mv	s0,a0
ffffffffc0200380:	dd65                	beqz	a0,ffffffffc0200378 <kmonitor+0x76>
ffffffffc0200382:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200386:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200388:	c999                	beqz	a1,ffffffffc020039e <kmonitor+0x9c>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	371040ef          	jal	ra,ffffffffc0204efc <strchr>
ffffffffc0200390:	c925                	beqz	a0,ffffffffc0200400 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc0200392:	00144583          	lbu	a1,1(s0)
ffffffffc0200396:	00040023          	sb	zero,0(s0)
ffffffffc020039a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	f5fd                	bnez	a1,ffffffffc020038a <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039e:	dce9                	beqz	s1,ffffffffc0200378 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00005d17          	auipc	s10,0x5
ffffffffc02003a6:	d06d0d13          	addi	s10,s10,-762 # ffffffffc02050a8 <commands>
    if (argc == 0) {
ffffffffc02003aa:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	0d61                	addi	s10,s10,24
ffffffffc02003b0:	323040ef          	jal	ra,ffffffffc0204ed2 <strcmp>
ffffffffc02003b4:	c919                	beqz	a0,ffffffffc02003ca <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b6:	2405                	addiw	s0,s0,1
ffffffffc02003b8:	09740463          	beq	s0,s7,ffffffffc0200440 <kmonitor+0x13e>
ffffffffc02003bc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	0d61                	addi	s10,s10,24
ffffffffc02003c4:	30f040ef          	jal	ra,ffffffffc0204ed2 <strcmp>
ffffffffc02003c8:	f57d                	bnez	a0,ffffffffc02003b6 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003ca:	00141793          	slli	a5,s0,0x1
ffffffffc02003ce:	97a2                	add	a5,a5,s0
ffffffffc02003d0:	078e                	slli	a5,a5,0x3
ffffffffc02003d2:	97e6                	add	a5,a5,s9
ffffffffc02003d4:	6b9c                	ld	a5,16(a5)
ffffffffc02003d6:	8662                	mv	a2,s8
ffffffffc02003d8:	002c                	addi	a1,sp,8
ffffffffc02003da:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003e0:	f8055ce3          	bgez	a0,ffffffffc0200378 <kmonitor+0x76>
}
ffffffffc02003e4:	60ee                	ld	ra,216(sp)
ffffffffc02003e6:	644e                	ld	s0,208(sp)
ffffffffc02003e8:	64ae                	ld	s1,200(sp)
ffffffffc02003ea:	690e                	ld	s2,192(sp)
ffffffffc02003ec:	79ea                	ld	s3,184(sp)
ffffffffc02003ee:	7a4a                	ld	s4,176(sp)
ffffffffc02003f0:	7aaa                	ld	s5,168(sp)
ffffffffc02003f2:	7b0a                	ld	s6,160(sp)
ffffffffc02003f4:	6bea                	ld	s7,152(sp)
ffffffffc02003f6:	6c4a                	ld	s8,144(sp)
ffffffffc02003f8:	6caa                	ld	s9,136(sp)
ffffffffc02003fa:	6d0a                	ld	s10,128(sp)
ffffffffc02003fc:	612d                	addi	sp,sp,224
ffffffffc02003fe:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200400:	00044783          	lbu	a5,0(s0)
ffffffffc0200404:	dfc9                	beqz	a5,ffffffffc020039e <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200406:	03448863          	beq	s1,s4,ffffffffc0200436 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020040a:	00349793          	slli	a5,s1,0x3
ffffffffc020040e:	0118                	addi	a4,sp,128
ffffffffc0200410:	97ba                	add	a5,a5,a4
ffffffffc0200412:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200416:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020041a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041c:	e591                	bnez	a1,ffffffffc0200428 <kmonitor+0x126>
ffffffffc020041e:	b749                	j	ffffffffc02003a0 <kmonitor+0x9e>
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	00044583          	lbu	a1,0(s0)
ffffffffc0200426:	ddad                	beqz	a1,ffffffffc02003a0 <kmonitor+0x9e>
ffffffffc0200428:	854a                	mv	a0,s2
ffffffffc020042a:	2d3040ef          	jal	ra,ffffffffc0204efc <strchr>
ffffffffc020042e:	d96d                	beqz	a0,ffffffffc0200420 <kmonitor+0x11e>
ffffffffc0200430:	00044583          	lbu	a1,0(s0)
ffffffffc0200434:	bf91                	j	ffffffffc0200388 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	45c1                	li	a1,16
ffffffffc0200438:	855a                	mv	a0,s6
ffffffffc020043a:	d55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043e:	b7f1                	j	ffffffffc020040a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200440:	6582                	ld	a1,0(sp)
ffffffffc0200442:	00005517          	auipc	a0,0x5
ffffffffc0200446:	d2e50513          	addi	a0,a0,-722 # ffffffffc0205170 <commands+0xc8>
ffffffffc020044a:	d45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044e:	b72d                	j	ffffffffc0200378 <kmonitor+0x76>

ffffffffc0200450 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200450:	00016317          	auipc	t1,0x16
ffffffffc0200454:	02030313          	addi	t1,t1,32 # ffffffffc0216470 <is_panic>
ffffffffc0200458:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020045c:	715d                	addi	sp,sp,-80
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	e822                	sd	s0,16(sp)
ffffffffc0200462:	f436                	sd	a3,40(sp)
ffffffffc0200464:	f83a                	sd	a4,48(sp)
ffffffffc0200466:	fc3e                	sd	a5,56(sp)
ffffffffc0200468:	e0c2                	sd	a6,64(sp)
ffffffffc020046a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020046c:	02031c63          	bnez	t1,ffffffffc02004a4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200470:	4785                	li	a5,1
ffffffffc0200472:	8432                	mv	s0,a2
ffffffffc0200474:	00016717          	auipc	a4,0x16
ffffffffc0200478:	fef72e23          	sw	a5,-4(a4) # ffffffffc0216470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200480:	85aa                	mv	a1,a0
ffffffffc0200482:	00005517          	auipc	a0,0x5
ffffffffc0200486:	da650513          	addi	a0,a0,-602 # ffffffffc0205228 <commands+0x180>
    va_start(ap, fmt);
ffffffffc020048a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020048c:	d03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200490:	65a2                	ld	a1,8(sp)
ffffffffc0200492:	8522                	mv	a0,s0
ffffffffc0200494:	cdbff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200498:	00006517          	auipc	a0,0x6
ffffffffc020049c:	d1850513          	addi	a0,a0,-744 # ffffffffc02061b0 <default_pmm_manager+0x500>
ffffffffc02004a0:	cefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a4:	134000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e59ff0ef          	jal	ra,ffffffffc0200302 <kmonitor>
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x58>

ffffffffc02004b0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b0:	67e1                	lui	a5,0x18
ffffffffc02004b2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b6:	00016717          	auipc	a4,0x16
ffffffffc02004ba:	fcf73123          	sd	a5,-62(a4) # ffffffffc0216478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004be:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c4:	953e                	add	a0,a0,a5
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4881                	li	a7,0
ffffffffc02004ca:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ce:	02000793          	li	a5,32
ffffffffc02004d2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d6:	00005517          	auipc	a0,0x5
ffffffffc02004da:	d7250513          	addi	a0,a0,-654 # ffffffffc0205248 <commands+0x1a0>
    ticks = 0;
ffffffffc02004de:	00016797          	auipc	a5,0x16
ffffffffc02004e2:	fe07b923          	sd	zero,-14(a5) # ffffffffc02164d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e6:	ca9ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02004ea <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ea:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ee:	00016797          	auipc	a5,0x16
ffffffffc02004f2:	f8a78793          	addi	a5,a5,-118 # ffffffffc0216478 <timebase>
ffffffffc02004f6:	639c                	ld	a5,0(a5)
ffffffffc02004f8:	4581                	li	a1,0
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	953e                	add	a0,a0,a5
ffffffffc02004fe:	4881                	li	a7,0
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret

ffffffffc0200506 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200508:	100027f3          	csrr	a5,sstatus
ffffffffc020050c:	8b89                	andi	a5,a5,2
ffffffffc020050e:	0ff57513          	andi	a0,a0,255
ffffffffc0200512:	e799                	bnez	a5,ffffffffc0200520 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200514:	4581                	li	a1,0
ffffffffc0200516:	4601                	li	a2,0
ffffffffc0200518:	4885                	li	a7,1
ffffffffc020051a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020051e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200520:	1101                	addi	sp,sp,-32
ffffffffc0200522:	ec06                	sd	ra,24(sp)
ffffffffc0200524:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200526:	0b2000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020052a:	6522                	ld	a0,8(sp)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4885                	li	a7,1
ffffffffc0200532:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020053a:	0980006f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	07e000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	064000ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020057a:	8082                	ret

ffffffffc020057c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020057c:	00253513          	sltiu	a0,a0,2
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200582:	03800513          	li	a0,56
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200588:	0000b797          	auipc	a5,0xb
ffffffffc020058c:	ed878793          	addi	a5,a5,-296 # ffffffffc020b460 <ide>
ffffffffc0200590:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200594:	1141                	addi	sp,sp,-16
ffffffffc0200596:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200598:	95be                	add	a1,a1,a5
ffffffffc020059a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020059e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005a0:	18d040ef          	jal	ra,ffffffffc0204f2c <memcpy>
    return 0;
}
ffffffffc02005a4:	60a2                	ld	ra,8(sp)
ffffffffc02005a6:	4501                	li	a0,0
ffffffffc02005a8:	0141                	addi	sp,sp,16
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02005ac:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005ae:	0095979b          	slliw	a5,a1,0x9
ffffffffc02005b2:	0000b517          	auipc	a0,0xb
ffffffffc02005b6:	eae50513          	addi	a0,a0,-338 # ffffffffc020b460 <ide>
                   size_t nsecs) {
ffffffffc02005ba:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005bc:	00969613          	slli	a2,a3,0x9
ffffffffc02005c0:	85ba                	mv	a1,a4
ffffffffc02005c2:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005c6:	167040ef          	jal	ra,ffffffffc0204f2c <memcpy>
    return 0;
}
ffffffffc02005ca:	60a2                	ld	ra,8(sp)
ffffffffc02005cc:	4501                	li	a0,0
ffffffffc02005ce:	0141                	addi	sp,sp,16
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005dc:	8082                	ret

ffffffffc02005de <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e0:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e4:	1141                	addi	sp,sp,-16
ffffffffc02005e6:	e022                	sd	s0,0(sp)
ffffffffc02005e8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ea:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ee:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005f0:	11053583          	ld	a1,272(a0)
ffffffffc02005f4:	05500613          	li	a2,85
ffffffffc02005f8:	c399                	beqz	a5,ffffffffc02005fe <pgfault_handler+0x1e>
ffffffffc02005fa:	04b00613          	li	a2,75
ffffffffc02005fe:	11843703          	ld	a4,280(s0)
ffffffffc0200602:	47bd                	li	a5,15
ffffffffc0200604:	05700693          	li	a3,87
ffffffffc0200608:	00f70463          	beq	a4,a5,ffffffffc0200610 <pgfault_handler+0x30>
ffffffffc020060c:	05200693          	li	a3,82
ffffffffc0200610:	00005517          	auipc	a0,0x5
ffffffffc0200614:	f3050513          	addi	a0,a0,-208 # ffffffffc0205540 <commands+0x498>
ffffffffc0200618:	b77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020061c:	00016797          	auipc	a5,0x16
ffffffffc0200620:	fcc78793          	addi	a5,a5,-52 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0200624:	6388                	ld	a0,0(a5)
ffffffffc0200626:	c911                	beqz	a0,ffffffffc020063a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200628:	11043603          	ld	a2,272(s0)
ffffffffc020062c:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200630:	6402                	ld	s0,0(sp)
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200636:	1430306f          	j	ffffffffc0203f78 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020063a:	00005617          	auipc	a2,0x5
ffffffffc020063e:	f2660613          	addi	a2,a2,-218 # ffffffffc0205560 <commands+0x4b8>
ffffffffc0200642:	06400593          	li	a1,100
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	f3250513          	addi	a0,a0,-206 # ffffffffc0205578 <commands+0x4d0>
ffffffffc020064e:	e03ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200652 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200652:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200656:	00000797          	auipc	a5,0x0
ffffffffc020065a:	4b278793          	addi	a5,a5,1202 # ffffffffc0200b08 <__alltraps>
ffffffffc020065e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200662:	000407b7          	lui	a5,0x40
ffffffffc0200666:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020066a:	8082                	ret

ffffffffc020066c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020066e:	1141                	addi	sp,sp,-16
ffffffffc0200670:	e022                	sd	s0,0(sp)
ffffffffc0200672:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	f1c50513          	addi	a0,a0,-228 # ffffffffc0205590 <commands+0x4e8>
void print_regs(struct pushregs *gpr) {
ffffffffc020067c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067e:	b11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200682:	640c                	ld	a1,8(s0)
ffffffffc0200684:	00005517          	auipc	a0,0x5
ffffffffc0200688:	f2450513          	addi	a0,a0,-220 # ffffffffc02055a8 <commands+0x500>
ffffffffc020068c:	b03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200690:	680c                	ld	a1,16(s0)
ffffffffc0200692:	00005517          	auipc	a0,0x5
ffffffffc0200696:	f2e50513          	addi	a0,a0,-210 # ffffffffc02055c0 <commands+0x518>
ffffffffc020069a:	af5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069e:	6c0c                	ld	a1,24(s0)
ffffffffc02006a0:	00005517          	auipc	a0,0x5
ffffffffc02006a4:	f3850513          	addi	a0,a0,-200 # ffffffffc02055d8 <commands+0x530>
ffffffffc02006a8:	ae7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006ac:	700c                	ld	a1,32(s0)
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	f4250513          	addi	a0,a0,-190 # ffffffffc02055f0 <commands+0x548>
ffffffffc02006b6:	ad9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ba:	740c                	ld	a1,40(s0)
ffffffffc02006bc:	00005517          	auipc	a0,0x5
ffffffffc02006c0:	f4c50513          	addi	a0,a0,-180 # ffffffffc0205608 <commands+0x560>
ffffffffc02006c4:	acbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c8:	780c                	ld	a1,48(s0)
ffffffffc02006ca:	00005517          	auipc	a0,0x5
ffffffffc02006ce:	f5650513          	addi	a0,a0,-170 # ffffffffc0205620 <commands+0x578>
ffffffffc02006d2:	abdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d6:	7c0c                	ld	a1,56(s0)
ffffffffc02006d8:	00005517          	auipc	a0,0x5
ffffffffc02006dc:	f6050513          	addi	a0,a0,-160 # ffffffffc0205638 <commands+0x590>
ffffffffc02006e0:	aafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e4:	602c                	ld	a1,64(s0)
ffffffffc02006e6:	00005517          	auipc	a0,0x5
ffffffffc02006ea:	f6a50513          	addi	a0,a0,-150 # ffffffffc0205650 <commands+0x5a8>
ffffffffc02006ee:	aa1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006f2:	642c                	ld	a1,72(s0)
ffffffffc02006f4:	00005517          	auipc	a0,0x5
ffffffffc02006f8:	f7450513          	addi	a0,a0,-140 # ffffffffc0205668 <commands+0x5c0>
ffffffffc02006fc:	a93ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200700:	682c                	ld	a1,80(s0)
ffffffffc0200702:	00005517          	auipc	a0,0x5
ffffffffc0200706:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205680 <commands+0x5d8>
ffffffffc020070a:	a85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070e:	6c2c                	ld	a1,88(s0)
ffffffffc0200710:	00005517          	auipc	a0,0x5
ffffffffc0200714:	f8850513          	addi	a0,a0,-120 # ffffffffc0205698 <commands+0x5f0>
ffffffffc0200718:	a77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020071c:	702c                	ld	a1,96(s0)
ffffffffc020071e:	00005517          	auipc	a0,0x5
ffffffffc0200722:	f9250513          	addi	a0,a0,-110 # ffffffffc02056b0 <commands+0x608>
ffffffffc0200726:	a69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020072a:	742c                	ld	a1,104(s0)
ffffffffc020072c:	00005517          	auipc	a0,0x5
ffffffffc0200730:	f9c50513          	addi	a0,a0,-100 # ffffffffc02056c8 <commands+0x620>
ffffffffc0200734:	a5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200738:	782c                	ld	a1,112(s0)
ffffffffc020073a:	00005517          	auipc	a0,0x5
ffffffffc020073e:	fa650513          	addi	a0,a0,-90 # ffffffffc02056e0 <commands+0x638>
ffffffffc0200742:	a4dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200746:	7c2c                	ld	a1,120(s0)
ffffffffc0200748:	00005517          	auipc	a0,0x5
ffffffffc020074c:	fb050513          	addi	a0,a0,-80 # ffffffffc02056f8 <commands+0x650>
ffffffffc0200750:	a3fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200754:	604c                	ld	a1,128(s0)
ffffffffc0200756:	00005517          	auipc	a0,0x5
ffffffffc020075a:	fba50513          	addi	a0,a0,-70 # ffffffffc0205710 <commands+0x668>
ffffffffc020075e:	a31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200762:	644c                	ld	a1,136(s0)
ffffffffc0200764:	00005517          	auipc	a0,0x5
ffffffffc0200768:	fc450513          	addi	a0,a0,-60 # ffffffffc0205728 <commands+0x680>
ffffffffc020076c:	a23ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200770:	684c                	ld	a1,144(s0)
ffffffffc0200772:	00005517          	auipc	a0,0x5
ffffffffc0200776:	fce50513          	addi	a0,a0,-50 # ffffffffc0205740 <commands+0x698>
ffffffffc020077a:	a15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077e:	6c4c                	ld	a1,152(s0)
ffffffffc0200780:	00005517          	auipc	a0,0x5
ffffffffc0200784:	fd850513          	addi	a0,a0,-40 # ffffffffc0205758 <commands+0x6b0>
ffffffffc0200788:	a07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020078c:	704c                	ld	a1,160(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	fe250513          	addi	a0,a0,-30 # ffffffffc0205770 <commands+0x6c8>
ffffffffc0200796:	9f9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020079a:	744c                	ld	a1,168(s0)
ffffffffc020079c:	00005517          	auipc	a0,0x5
ffffffffc02007a0:	fec50513          	addi	a0,a0,-20 # ffffffffc0205788 <commands+0x6e0>
ffffffffc02007a4:	9ebff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a8:	784c                	ld	a1,176(s0)
ffffffffc02007aa:	00005517          	auipc	a0,0x5
ffffffffc02007ae:	ff650513          	addi	a0,a0,-10 # ffffffffc02057a0 <commands+0x6f8>
ffffffffc02007b2:	9ddff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b6:	7c4c                	ld	a1,184(s0)
ffffffffc02007b8:	00005517          	auipc	a0,0x5
ffffffffc02007bc:	00050513          	mv	a0,a0
ffffffffc02007c0:	9cfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c4:	606c                	ld	a1,192(s0)
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	00a50513          	addi	a0,a0,10 # ffffffffc02057d0 <commands+0x728>
ffffffffc02007ce:	9c1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007d2:	646c                	ld	a1,200(s0)
ffffffffc02007d4:	00005517          	auipc	a0,0x5
ffffffffc02007d8:	01450513          	addi	a0,a0,20 # ffffffffc02057e8 <commands+0x740>
ffffffffc02007dc:	9b3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e0:	686c                	ld	a1,208(s0)
ffffffffc02007e2:	00005517          	auipc	a0,0x5
ffffffffc02007e6:	01e50513          	addi	a0,a0,30 # ffffffffc0205800 <commands+0x758>
ffffffffc02007ea:	9a5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ee:	6c6c                	ld	a1,216(s0)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	02850513          	addi	a0,a0,40 # ffffffffc0205818 <commands+0x770>
ffffffffc02007f8:	997ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007fc:	706c                	ld	a1,224(s0)
ffffffffc02007fe:	00005517          	auipc	a0,0x5
ffffffffc0200802:	03250513          	addi	a0,a0,50 # ffffffffc0205830 <commands+0x788>
ffffffffc0200806:	989ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020080a:	746c                	ld	a1,232(s0)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	03c50513          	addi	a0,a0,60 # ffffffffc0205848 <commands+0x7a0>
ffffffffc0200814:	97bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200818:	786c                	ld	a1,240(s0)
ffffffffc020081a:	00005517          	auipc	a0,0x5
ffffffffc020081e:	04650513          	addi	a0,a0,70 # ffffffffc0205860 <commands+0x7b8>
ffffffffc0200822:	96dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200826:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200828:	6402                	ld	s0,0(sp)
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	04c50513          	addi	a0,a0,76 # ffffffffc0205878 <commands+0x7d0>
}
ffffffffc0200834:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	959ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020083a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	1141                	addi	sp,sp,-16
ffffffffc020083c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	04e50513          	addi	a0,a0,78 # ffffffffc0205890 <commands+0x7e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084c:	943ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200850:	8522                	mv	a0,s0
ffffffffc0200852:	e1bff0ef          	jal	ra,ffffffffc020066c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200856:	10043583          	ld	a1,256(s0)
ffffffffc020085a:	00005517          	auipc	a0,0x5
ffffffffc020085e:	04e50513          	addi	a0,a0,78 # ffffffffc02058a8 <commands+0x800>
ffffffffc0200862:	92dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200866:	10843583          	ld	a1,264(s0)
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	05650513          	addi	a0,a0,86 # ffffffffc02058c0 <commands+0x818>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200876:	11043583          	ld	a1,272(s0)
ffffffffc020087a:	00005517          	auipc	a0,0x5
ffffffffc020087e:	05e50513          	addi	a0,a0,94 # ffffffffc02058d8 <commands+0x830>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	11843583          	ld	a1,280(s0)
}
ffffffffc020088a:	6402                	ld	s0,0(sp)
ffffffffc020088c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	06250513          	addi	a0,a0,98 # ffffffffc02058f0 <commands+0x848>
}
ffffffffc0200896:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200898:	8f7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020089c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089c:	11853783          	ld	a5,280(a0)
ffffffffc02008a0:	577d                	li	a4,-1
ffffffffc02008a2:	8305                	srli	a4,a4,0x1
ffffffffc02008a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02008a6:	472d                	li	a4,11
ffffffffc02008a8:	06f76f63          	bltu	a4,a5,ffffffffc0200926 <interrupt_handler+0x8a>
ffffffffc02008ac:	00005717          	auipc	a4,0x5
ffffffffc02008b0:	9b870713          	addi	a4,a4,-1608 # ffffffffc0205264 <commands+0x1bc>
ffffffffc02008b4:	078a                	slli	a5,a5,0x2
ffffffffc02008b6:	97ba                	add	a5,a5,a4
ffffffffc02008b8:	439c                	lw	a5,0(a5)
ffffffffc02008ba:	97ba                	add	a5,a5,a4
ffffffffc02008bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	c3250513          	addi	a0,a0,-974 # ffffffffc02054f0 <commands+0x448>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	c0650513          	addi	a0,a0,-1018 # ffffffffc02054d0 <commands+0x428>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205490 <commands+0x3e8>
ffffffffc02008de:	8b1ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	bce50513          	addi	a0,a0,-1074 # ffffffffc02054b0 <commands+0x408>
ffffffffc02008ea:	8a5ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	c3250513          	addi	a0,a0,-974 # ffffffffc0205520 <commands+0x478>
ffffffffc02008f6:	899ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008fe:	bedff0ef          	jal	ra,ffffffffc02004ea <clock_set_next_event>
            if(++ticks % TICK_NUM == 0) {
ffffffffc0200902:	00016797          	auipc	a5,0x16
ffffffffc0200906:	bce78793          	addi	a5,a5,-1074 # ffffffffc02164d0 <ticks>
ffffffffc020090a:	639c                	ld	a5,0(a5)
ffffffffc020090c:	06400713          	li	a4,100
ffffffffc0200910:	0785                	addi	a5,a5,1
ffffffffc0200912:	02e7f733          	remu	a4,a5,a4
ffffffffc0200916:	00016697          	auipc	a3,0x16
ffffffffc020091a:	baf6bd23          	sd	a5,-1094(a3) # ffffffffc02164d0 <ticks>
ffffffffc020091e:	c711                	beqz	a4,ffffffffc020092a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200920:	60a2                	ld	ra,8(sp)
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret
            print_trapframe(tf);
ffffffffc0200926:	f15ff06f          	j	ffffffffc020083a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092a:	06400593          	li	a1,100
ffffffffc020092e:	00005517          	auipc	a0,0x5
ffffffffc0200932:	be250513          	addi	a0,a0,-1054 # ffffffffc0205510 <commands+0x468>
ffffffffc0200936:	859ff0ef          	jal	ra,ffffffffc020018e <cprintf>
                num ++;
ffffffffc020093a:	00016717          	auipc	a4,0x16
ffffffffc020093e:	b4670713          	addi	a4,a4,-1210 # ffffffffc0216480 <num>
ffffffffc0200942:	631c                	ld	a5,0(a4)
                if(num == 10){
ffffffffc0200944:	46a9                	li	a3,10
                num ++;
ffffffffc0200946:	0785                	addi	a5,a5,1
ffffffffc0200948:	00016617          	auipc	a2,0x16
ffffffffc020094c:	b2f63c23          	sd	a5,-1224(a2) # ffffffffc0216480 <num>
                if(num == 10){
ffffffffc0200950:	631c                	ld	a5,0(a4)
ffffffffc0200952:	fcd797e3          	bne	a5,a3,ffffffffc0200920 <interrupt_handler+0x84>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200956:	4501                	li	a0,0
ffffffffc0200958:	4581                	li	a1,0
ffffffffc020095a:	4601                	li	a2,0
ffffffffc020095c:	48a1                	li	a7,8
ffffffffc020095e:	00000073          	ecall
ffffffffc0200962:	bf7d                	j	ffffffffc0200920 <interrupt_handler+0x84>

ffffffffc0200964 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200964:	11853783          	ld	a5,280(a0)
ffffffffc0200968:	473d                	li	a4,15
ffffffffc020096a:	16f76563          	bltu	a4,a5,ffffffffc0200ad4 <exception_handler+0x170>
ffffffffc020096e:	00005717          	auipc	a4,0x5
ffffffffc0200972:	92670713          	addi	a4,a4,-1754 # ffffffffc0205294 <commands+0x1ec>
ffffffffc0200976:	078a                	slli	a5,a5,0x2
ffffffffc0200978:	97ba                	add	a5,a5,a4
ffffffffc020097a:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020097c:	1101                	addi	sp,sp,-32
ffffffffc020097e:	e822                	sd	s0,16(sp)
ffffffffc0200980:	ec06                	sd	ra,24(sp)
ffffffffc0200982:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200984:	97ba                	add	a5,a5,a4
ffffffffc0200986:	842a                	mv	s0,a0
ffffffffc0200988:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020098a:	00005517          	auipc	a0,0x5
ffffffffc020098e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0205478 <commands+0x3d0>
ffffffffc0200992:	ffcff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200996:	8522                	mv	a0,s0
ffffffffc0200998:	c49ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc020099c:	84aa                	mv	s1,a0
ffffffffc020099e:	12051d63          	bnez	a0,ffffffffc0200ad8 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02009a2:	60e2                	ld	ra,24(sp)
ffffffffc02009a4:	6442                	ld	s0,16(sp)
ffffffffc02009a6:	64a2                	ld	s1,8(sp)
ffffffffc02009a8:	6105                	addi	sp,sp,32
ffffffffc02009aa:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02009ac:	00005517          	auipc	a0,0x5
ffffffffc02009b0:	92c50513          	addi	a0,a0,-1748 # ffffffffc02052d8 <commands+0x230>
}
ffffffffc02009b4:	6442                	ld	s0,16(sp)
ffffffffc02009b6:	60e2                	ld	ra,24(sp)
ffffffffc02009b8:	64a2                	ld	s1,8(sp)
ffffffffc02009ba:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02009bc:	fd2ff06f          	j	ffffffffc020018e <cprintf>
ffffffffc02009c0:	00005517          	auipc	a0,0x5
ffffffffc02009c4:	93850513          	addi	a0,a0,-1736 # ffffffffc02052f8 <commands+0x250>
ffffffffc02009c8:	b7f5                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205318 <commands+0x270>
ffffffffc02009d2:	b7cd                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009d4:	00005517          	auipc	a0,0x5
ffffffffc02009d8:	95c50513          	addi	a0,a0,-1700 # ffffffffc0205330 <commands+0x288>
ffffffffc02009dc:	bfe1                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	96250513          	addi	a0,a0,-1694 # ffffffffc0205340 <commands+0x298>
ffffffffc02009e6:	b7f9                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009e8:	00005517          	auipc	a0,0x5
ffffffffc02009ec:	97850513          	addi	a0,a0,-1672 # ffffffffc0205360 <commands+0x2b8>
ffffffffc02009f0:	f9eff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	bebff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc02009fa:	84aa                	mv	s1,a0
ffffffffc02009fc:	d15d                	beqz	a0,ffffffffc02009a2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009fe:	8522                	mv	a0,s0
ffffffffc0200a00:	e3bff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a04:	86a6                	mv	a3,s1
ffffffffc0200a06:	00005617          	auipc	a2,0x5
ffffffffc0200a0a:	97260613          	addi	a2,a2,-1678 # ffffffffc0205378 <commands+0x2d0>
ffffffffc0200a0e:	0b900593          	li	a1,185
ffffffffc0200a12:	00005517          	auipc	a0,0x5
ffffffffc0200a16:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205578 <commands+0x4d0>
ffffffffc0200a1a:	a37ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205398 <commands+0x2f0>
ffffffffc0200a26:	b779                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a28:	00005517          	auipc	a0,0x5
ffffffffc0200a2c:	98850513          	addi	a0,a0,-1656 # ffffffffc02053b0 <commands+0x308>
ffffffffc0200a30:	f5eff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a34:	8522                	mv	a0,s0
ffffffffc0200a36:	babff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a3a:	84aa                	mv	s1,a0
ffffffffc0200a3c:	d13d                	beqz	a0,ffffffffc02009a2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a3e:	8522                	mv	a0,s0
ffffffffc0200a40:	dfbff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a44:	86a6                	mv	a3,s1
ffffffffc0200a46:	00005617          	auipc	a2,0x5
ffffffffc0200a4a:	93260613          	addi	a2,a2,-1742 # ffffffffc0205378 <commands+0x2d0>
ffffffffc0200a4e:	0c300593          	li	a1,195
ffffffffc0200a52:	00005517          	auipc	a0,0x5
ffffffffc0200a56:	b2650513          	addi	a0,a0,-1242 # ffffffffc0205578 <commands+0x4d0>
ffffffffc0200a5a:	9f7ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	96a50513          	addi	a0,a0,-1686 # ffffffffc02053c8 <commands+0x320>
ffffffffc0200a66:	b7b9                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a68:	00005517          	auipc	a0,0x5
ffffffffc0200a6c:	98050513          	addi	a0,a0,-1664 # ffffffffc02053e8 <commands+0x340>
ffffffffc0200a70:	b791                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	99650513          	addi	a0,a0,-1642 # ffffffffc0205408 <commands+0x360>
ffffffffc0200a7a:	bf2d                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a7c:	00005517          	auipc	a0,0x5
ffffffffc0200a80:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0205428 <commands+0x380>
ffffffffc0200a84:	bf05                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a86:	00005517          	auipc	a0,0x5
ffffffffc0200a8a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0205448 <commands+0x3a0>
ffffffffc0200a8e:	b71d                	j	ffffffffc02009b4 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a90:	00005517          	auipc	a0,0x5
ffffffffc0200a94:	9d050513          	addi	a0,a0,-1584 # ffffffffc0205460 <commands+0x3b8>
ffffffffc0200a98:	ef6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a9c:	8522                	mv	a0,s0
ffffffffc0200a9e:	b43ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200aa2:	84aa                	mv	s1,a0
ffffffffc0200aa4:	ee050fe3          	beqz	a0,ffffffffc02009a2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200aa8:	8522                	mv	a0,s0
ffffffffc0200aaa:	d91ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aae:	86a6                	mv	a3,s1
ffffffffc0200ab0:	00005617          	auipc	a2,0x5
ffffffffc0200ab4:	8c860613          	addi	a2,a2,-1848 # ffffffffc0205378 <commands+0x2d0>
ffffffffc0200ab8:	0d900593          	li	a1,217
ffffffffc0200abc:	00005517          	auipc	a0,0x5
ffffffffc0200ac0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0205578 <commands+0x4d0>
ffffffffc0200ac4:	98dff0ef          	jal	ra,ffffffffc0200450 <__panic>
}
ffffffffc0200ac8:	6442                	ld	s0,16(sp)
ffffffffc0200aca:	60e2                	ld	ra,24(sp)
ffffffffc0200acc:	64a2                	ld	s1,8(sp)
ffffffffc0200ace:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200ad0:	d6bff06f          	j	ffffffffc020083a <print_trapframe>
ffffffffc0200ad4:	d67ff06f          	j	ffffffffc020083a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	d61ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ade:	86a6                	mv	a3,s1
ffffffffc0200ae0:	00005617          	auipc	a2,0x5
ffffffffc0200ae4:	89860613          	addi	a2,a2,-1896 # ffffffffc0205378 <commands+0x2d0>
ffffffffc0200ae8:	0e000593          	li	a1,224
ffffffffc0200aec:	00005517          	auipc	a0,0x5
ffffffffc0200af0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0205578 <commands+0x4d0>
ffffffffc0200af4:	95dff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200af8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200af8:	11853783          	ld	a5,280(a0)
ffffffffc0200afc:	0007c463          	bltz	a5,ffffffffc0200b04 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200b00:	e65ff06f          	j	ffffffffc0200964 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200b04:	d99ff06f          	j	ffffffffc020089c <interrupt_handler>

ffffffffc0200b08 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200b08:	14011073          	csrw	sscratch,sp
ffffffffc0200b0c:	712d                	addi	sp,sp,-288
ffffffffc0200b0e:	e406                	sd	ra,8(sp)
ffffffffc0200b10:	ec0e                	sd	gp,24(sp)
ffffffffc0200b12:	f012                	sd	tp,32(sp)
ffffffffc0200b14:	f416                	sd	t0,40(sp)
ffffffffc0200b16:	f81a                	sd	t1,48(sp)
ffffffffc0200b18:	fc1e                	sd	t2,56(sp)
ffffffffc0200b1a:	e0a2                	sd	s0,64(sp)
ffffffffc0200b1c:	e4a6                	sd	s1,72(sp)
ffffffffc0200b1e:	e8aa                	sd	a0,80(sp)
ffffffffc0200b20:	ecae                	sd	a1,88(sp)
ffffffffc0200b22:	f0b2                	sd	a2,96(sp)
ffffffffc0200b24:	f4b6                	sd	a3,104(sp)
ffffffffc0200b26:	f8ba                	sd	a4,112(sp)
ffffffffc0200b28:	fcbe                	sd	a5,120(sp)
ffffffffc0200b2a:	e142                	sd	a6,128(sp)
ffffffffc0200b2c:	e546                	sd	a7,136(sp)
ffffffffc0200b2e:	e94a                	sd	s2,144(sp)
ffffffffc0200b30:	ed4e                	sd	s3,152(sp)
ffffffffc0200b32:	f152                	sd	s4,160(sp)
ffffffffc0200b34:	f556                	sd	s5,168(sp)
ffffffffc0200b36:	f95a                	sd	s6,176(sp)
ffffffffc0200b38:	fd5e                	sd	s7,184(sp)
ffffffffc0200b3a:	e1e2                	sd	s8,192(sp)
ffffffffc0200b3c:	e5e6                	sd	s9,200(sp)
ffffffffc0200b3e:	e9ea                	sd	s10,208(sp)
ffffffffc0200b40:	edee                	sd	s11,216(sp)
ffffffffc0200b42:	f1f2                	sd	t3,224(sp)
ffffffffc0200b44:	f5f6                	sd	t4,232(sp)
ffffffffc0200b46:	f9fa                	sd	t5,240(sp)
ffffffffc0200b48:	fdfe                	sd	t6,248(sp)
ffffffffc0200b4a:	14002473          	csrr	s0,sscratch
ffffffffc0200b4e:	100024f3          	csrr	s1,sstatus
ffffffffc0200b52:	14102973          	csrr	s2,sepc
ffffffffc0200b56:	143029f3          	csrr	s3,stval
ffffffffc0200b5a:	14202a73          	csrr	s4,scause
ffffffffc0200b5e:	e822                	sd	s0,16(sp)
ffffffffc0200b60:	e226                	sd	s1,256(sp)
ffffffffc0200b62:	e64a                	sd	s2,264(sp)
ffffffffc0200b64:	ea4e                	sd	s3,272(sp)
ffffffffc0200b66:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b68:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b6a:	f8fff0ef          	jal	ra,ffffffffc0200af8 <trap>

ffffffffc0200b6e <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b6e:	6492                	ld	s1,256(sp)
ffffffffc0200b70:	6932                	ld	s2,264(sp)
ffffffffc0200b72:	10049073          	csrw	sstatus,s1
ffffffffc0200b76:	14191073          	csrw	sepc,s2
ffffffffc0200b7a:	60a2                	ld	ra,8(sp)
ffffffffc0200b7c:	61e2                	ld	gp,24(sp)
ffffffffc0200b7e:	7202                	ld	tp,32(sp)
ffffffffc0200b80:	72a2                	ld	t0,40(sp)
ffffffffc0200b82:	7342                	ld	t1,48(sp)
ffffffffc0200b84:	73e2                	ld	t2,56(sp)
ffffffffc0200b86:	6406                	ld	s0,64(sp)
ffffffffc0200b88:	64a6                	ld	s1,72(sp)
ffffffffc0200b8a:	6546                	ld	a0,80(sp)
ffffffffc0200b8c:	65e6                	ld	a1,88(sp)
ffffffffc0200b8e:	7606                	ld	a2,96(sp)
ffffffffc0200b90:	76a6                	ld	a3,104(sp)
ffffffffc0200b92:	7746                	ld	a4,112(sp)
ffffffffc0200b94:	77e6                	ld	a5,120(sp)
ffffffffc0200b96:	680a                	ld	a6,128(sp)
ffffffffc0200b98:	68aa                	ld	a7,136(sp)
ffffffffc0200b9a:	694a                	ld	s2,144(sp)
ffffffffc0200b9c:	69ea                	ld	s3,152(sp)
ffffffffc0200b9e:	7a0a                	ld	s4,160(sp)
ffffffffc0200ba0:	7aaa                	ld	s5,168(sp)
ffffffffc0200ba2:	7b4a                	ld	s6,176(sp)
ffffffffc0200ba4:	7bea                	ld	s7,184(sp)
ffffffffc0200ba6:	6c0e                	ld	s8,192(sp)
ffffffffc0200ba8:	6cae                	ld	s9,200(sp)
ffffffffc0200baa:	6d4e                	ld	s10,208(sp)
ffffffffc0200bac:	6dee                	ld	s11,216(sp)
ffffffffc0200bae:	7e0e                	ld	t3,224(sp)
ffffffffc0200bb0:	7eae                	ld	t4,232(sp)
ffffffffc0200bb2:	7f4e                	ld	t5,240(sp)
ffffffffc0200bb4:	7fee                	ld	t6,248(sp)
ffffffffc0200bb6:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200bb8:	10200073          	sret

ffffffffc0200bbc <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200bbc:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200bbe:	bf45                	j	ffffffffc0200b6e <__trapret>
	...

ffffffffc0200bc2 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bc2:	00016797          	auipc	a5,0x16
ffffffffc0200bc6:	91678793          	addi	a5,a5,-1770 # ffffffffc02164d8 <free_area>
ffffffffc0200bca:	e79c                	sd	a5,8(a5)
ffffffffc0200bcc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200bce:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200bd2:	8082                	ret

ffffffffc0200bd4 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200bd4:	00016517          	auipc	a0,0x16
ffffffffc0200bd8:	91456503          	lwu	a0,-1772(a0) # ffffffffc02164e8 <free_area+0x10>
ffffffffc0200bdc:	8082                	ret

ffffffffc0200bde <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200bde:	715d                	addi	sp,sp,-80
ffffffffc0200be0:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200be2:	00016917          	auipc	s2,0x16
ffffffffc0200be6:	8f690913          	addi	s2,s2,-1802 # ffffffffc02164d8 <free_area>
ffffffffc0200bea:	00893783          	ld	a5,8(s2)
ffffffffc0200bee:	e486                	sd	ra,72(sp)
ffffffffc0200bf0:	e0a2                	sd	s0,64(sp)
ffffffffc0200bf2:	fc26                	sd	s1,56(sp)
ffffffffc0200bf4:	f44e                	sd	s3,40(sp)
ffffffffc0200bf6:	f052                	sd	s4,32(sp)
ffffffffc0200bf8:	ec56                	sd	s5,24(sp)
ffffffffc0200bfa:	e85a                	sd	s6,16(sp)
ffffffffc0200bfc:	e45e                	sd	s7,8(sp)
ffffffffc0200bfe:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c00:	31278463          	beq	a5,s2,ffffffffc0200f08 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c04:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c08:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c0a:	8b05                	andi	a4,a4,1
ffffffffc0200c0c:	30070263          	beqz	a4,ffffffffc0200f10 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200c10:	4401                	li	s0,0
ffffffffc0200c12:	4481                	li	s1,0
ffffffffc0200c14:	a031                	j	ffffffffc0200c20 <default_check+0x42>
ffffffffc0200c16:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200c1a:	8b09                	andi	a4,a4,2
ffffffffc0200c1c:	2e070a63          	beqz	a4,ffffffffc0200f10 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200c20:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c24:	679c                	ld	a5,8(a5)
ffffffffc0200c26:	2485                	addiw	s1,s1,1
ffffffffc0200c28:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c2a:	ff2796e3          	bne	a5,s2,ffffffffc0200c16 <default_check+0x38>
ffffffffc0200c2e:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200c30:	058010ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>
ffffffffc0200c34:	73351e63          	bne	a0,s3,ffffffffc0201370 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c38:	4505                	li	a0,1
ffffffffc0200c3a:	781000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200c3e:	8a2a                	mv	s4,a0
ffffffffc0200c40:	46050863          	beqz	a0,ffffffffc02010b0 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c44:	4505                	li	a0,1
ffffffffc0200c46:	775000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200c4a:	89aa                	mv	s3,a0
ffffffffc0200c4c:	74050263          	beqz	a0,ffffffffc0201390 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c50:	4505                	li	a0,1
ffffffffc0200c52:	769000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200c56:	8aaa                	mv	s5,a0
ffffffffc0200c58:	4c050c63          	beqz	a0,ffffffffc0201130 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c5c:	2d3a0a63          	beq	s4,s3,ffffffffc0200f30 <default_check+0x352>
ffffffffc0200c60:	2caa0863          	beq	s4,a0,ffffffffc0200f30 <default_check+0x352>
ffffffffc0200c64:	2ca98663          	beq	s3,a0,ffffffffc0200f30 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c68:	000a2783          	lw	a5,0(s4)
ffffffffc0200c6c:	2e079263          	bnez	a5,ffffffffc0200f50 <default_check+0x372>
ffffffffc0200c70:	0009a783          	lw	a5,0(s3)
ffffffffc0200c74:	2c079e63          	bnez	a5,ffffffffc0200f50 <default_check+0x372>
ffffffffc0200c78:	411c                	lw	a5,0(a0)
ffffffffc0200c7a:	2c079b63          	bnez	a5,ffffffffc0200f50 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c7e:	00016797          	auipc	a5,0x16
ffffffffc0200c82:	88a78793          	addi	a5,a5,-1910 # ffffffffc0216508 <pages>
ffffffffc0200c86:	639c                	ld	a5,0(a5)
ffffffffc0200c88:	00006717          	auipc	a4,0x6
ffffffffc0200c8c:	3d070713          	addi	a4,a4,976 # ffffffffc0207058 <nbase>
ffffffffc0200c90:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c92:	00016717          	auipc	a4,0x16
ffffffffc0200c96:	80670713          	addi	a4,a4,-2042 # ffffffffc0216498 <npage>
ffffffffc0200c9a:	6314                	ld	a3,0(a4)
ffffffffc0200c9c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200ca0:	8719                	srai	a4,a4,0x6
ffffffffc0200ca2:	9732                	add	a4,a4,a2
ffffffffc0200ca4:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ca6:	0732                	slli	a4,a4,0xc
ffffffffc0200ca8:	2cd77463          	bleu	a3,a4,ffffffffc0200f70 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200cac:	40f98733          	sub	a4,s3,a5
ffffffffc0200cb0:	8719                	srai	a4,a4,0x6
ffffffffc0200cb2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cb4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cb6:	4ed77d63          	bleu	a3,a4,ffffffffc02011b0 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200cba:	40f507b3          	sub	a5,a0,a5
ffffffffc0200cbe:	8799                	srai	a5,a5,0x6
ffffffffc0200cc0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cc2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cc4:	34d7f663          	bleu	a3,a5,ffffffffc0201010 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200cc8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cca:	00093c03          	ld	s8,0(s2)
ffffffffc0200cce:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200cd2:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200cd6:	00016797          	auipc	a5,0x16
ffffffffc0200cda:	8127b523          	sd	s2,-2038(a5) # ffffffffc02164e0 <free_area+0x8>
ffffffffc0200cde:	00015797          	auipc	a5,0x15
ffffffffc0200ce2:	7f27bd23          	sd	s2,2042(a5) # ffffffffc02164d8 <free_area>
    nr_free = 0;
ffffffffc0200ce6:	00016797          	auipc	a5,0x16
ffffffffc0200cea:	8007a123          	sw	zero,-2046(a5) # ffffffffc02164e8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cee:	6cd000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200cf2:	2e051f63          	bnez	a0,ffffffffc0200ff0 <default_check+0x412>
    free_page(p0);
ffffffffc0200cf6:	4585                	li	a1,1
ffffffffc0200cf8:	8552                	mv	a0,s4
ffffffffc0200cfa:	749000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    free_page(p1);
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	854e                	mv	a0,s3
ffffffffc0200d02:	741000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    free_page(p2);
ffffffffc0200d06:	4585                	li	a1,1
ffffffffc0200d08:	8556                	mv	a0,s5
ffffffffc0200d0a:	739000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    assert(nr_free == 3);
ffffffffc0200d0e:	01092703          	lw	a4,16(s2)
ffffffffc0200d12:	478d                	li	a5,3
ffffffffc0200d14:	2af71e63          	bne	a4,a5,ffffffffc0200fd0 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d18:	4505                	li	a0,1
ffffffffc0200d1a:	6a1000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200d1e:	89aa                	mv	s3,a0
ffffffffc0200d20:	28050863          	beqz	a0,ffffffffc0200fb0 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d24:	4505                	li	a0,1
ffffffffc0200d26:	695000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200d2a:	8aaa                	mv	s5,a0
ffffffffc0200d2c:	3e050263          	beqz	a0,ffffffffc0201110 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d30:	4505                	li	a0,1
ffffffffc0200d32:	689000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200d36:	8a2a                	mv	s4,a0
ffffffffc0200d38:	3a050c63          	beqz	a0,ffffffffc02010f0 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200d3c:	4505                	li	a0,1
ffffffffc0200d3e:	67d000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200d42:	38051763          	bnez	a0,ffffffffc02010d0 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200d46:	4585                	li	a1,1
ffffffffc0200d48:	854e                	mv	a0,s3
ffffffffc0200d4a:	6f9000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d4e:	00893783          	ld	a5,8(s2)
ffffffffc0200d52:	23278f63          	beq	a5,s2,ffffffffc0200f90 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200d56:	4505                	li	a0,1
ffffffffc0200d58:	663000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200d5c:	32a99a63          	bne	s3,a0,ffffffffc0201090 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200d60:	4505                	li	a0,1
ffffffffc0200d62:	659000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200d66:	30051563          	bnez	a0,ffffffffc0201070 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200d6a:	01092783          	lw	a5,16(s2)
ffffffffc0200d6e:	2e079163          	bnez	a5,ffffffffc0201050 <default_check+0x472>
    free_page(p);
ffffffffc0200d72:	854e                	mv	a0,s3
ffffffffc0200d74:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d76:	00015797          	auipc	a5,0x15
ffffffffc0200d7a:	7787b123          	sd	s8,1890(a5) # ffffffffc02164d8 <free_area>
ffffffffc0200d7e:	00015797          	auipc	a5,0x15
ffffffffc0200d82:	7777b123          	sd	s7,1890(a5) # ffffffffc02164e0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d86:	00015797          	auipc	a5,0x15
ffffffffc0200d8a:	7767a123          	sw	s6,1890(a5) # ffffffffc02164e8 <free_area+0x10>
    free_page(p);
ffffffffc0200d8e:	6b5000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    free_page(p1);
ffffffffc0200d92:	4585                	li	a1,1
ffffffffc0200d94:	8556                	mv	a0,s5
ffffffffc0200d96:	6ad000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    free_page(p2);
ffffffffc0200d9a:	4585                	li	a1,1
ffffffffc0200d9c:	8552                	mv	a0,s4
ffffffffc0200d9e:	6a5000ef          	jal	ra,ffffffffc0201c42 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200da2:	4515                	li	a0,5
ffffffffc0200da4:	617000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200da8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200daa:	28050363          	beqz	a0,ffffffffc0201030 <default_check+0x452>
ffffffffc0200dae:	651c                	ld	a5,8(a0)
ffffffffc0200db0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200db2:	8b85                	andi	a5,a5,1
ffffffffc0200db4:	54079e63          	bnez	a5,ffffffffc0201310 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200db8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200dba:	00093b03          	ld	s6,0(s2)
ffffffffc0200dbe:	00893a83          	ld	s5,8(s2)
ffffffffc0200dc2:	00015797          	auipc	a5,0x15
ffffffffc0200dc6:	7127bb23          	sd	s2,1814(a5) # ffffffffc02164d8 <free_area>
ffffffffc0200dca:	00015797          	auipc	a5,0x15
ffffffffc0200dce:	7127bb23          	sd	s2,1814(a5) # ffffffffc02164e0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200dd2:	5e9000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200dd6:	50051d63          	bnez	a0,ffffffffc02012f0 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200dda:	08098a13          	addi	s4,s3,128
ffffffffc0200dde:	8552                	mv	a0,s4
ffffffffc0200de0:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200de2:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200de6:	00015797          	auipc	a5,0x15
ffffffffc0200dea:	7007a123          	sw	zero,1794(a5) # ffffffffc02164e8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200dee:	655000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200df2:	4511                	li	a0,4
ffffffffc0200df4:	5c7000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200df8:	4c051c63          	bnez	a0,ffffffffc02012d0 <default_check+0x6f2>
ffffffffc0200dfc:	0889b783          	ld	a5,136(s3)
ffffffffc0200e00:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200e02:	8b85                	andi	a5,a5,1
ffffffffc0200e04:	4a078663          	beqz	a5,ffffffffc02012b0 <default_check+0x6d2>
ffffffffc0200e08:	0909a703          	lw	a4,144(s3)
ffffffffc0200e0c:	478d                	li	a5,3
ffffffffc0200e0e:	4af71163          	bne	a4,a5,ffffffffc02012b0 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200e12:	450d                	li	a0,3
ffffffffc0200e14:	5a7000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200e18:	8c2a                	mv	s8,a0
ffffffffc0200e1a:	46050b63          	beqz	a0,ffffffffc0201290 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200e1e:	4505                	li	a0,1
ffffffffc0200e20:	59b000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200e24:	44051663          	bnez	a0,ffffffffc0201270 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200e28:	438a1463          	bne	s4,s8,ffffffffc0201250 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200e2c:	4585                	li	a1,1
ffffffffc0200e2e:	854e                	mv	a0,s3
ffffffffc0200e30:	613000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    free_pages(p1, 3);
ffffffffc0200e34:	458d                	li	a1,3
ffffffffc0200e36:	8552                	mv	a0,s4
ffffffffc0200e38:	60b000ef          	jal	ra,ffffffffc0201c42 <free_pages>
ffffffffc0200e3c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e40:	04098c13          	addi	s8,s3,64
ffffffffc0200e44:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e46:	8b85                	andi	a5,a5,1
ffffffffc0200e48:	3e078463          	beqz	a5,ffffffffc0201230 <default_check+0x652>
ffffffffc0200e4c:	0109a703          	lw	a4,16(s3)
ffffffffc0200e50:	4785                	li	a5,1
ffffffffc0200e52:	3cf71f63          	bne	a4,a5,ffffffffc0201230 <default_check+0x652>
ffffffffc0200e56:	008a3783          	ld	a5,8(s4)
ffffffffc0200e5a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e5c:	8b85                	andi	a5,a5,1
ffffffffc0200e5e:	3a078963          	beqz	a5,ffffffffc0201210 <default_check+0x632>
ffffffffc0200e62:	010a2703          	lw	a4,16(s4)
ffffffffc0200e66:	478d                	li	a5,3
ffffffffc0200e68:	3af71463          	bne	a4,a5,ffffffffc0201210 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e6c:	4505                	li	a0,1
ffffffffc0200e6e:	54d000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200e72:	36a99f63          	bne	s3,a0,ffffffffc02011f0 <default_check+0x612>
    free_page(p0);
ffffffffc0200e76:	4585                	li	a1,1
ffffffffc0200e78:	5cb000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e7c:	4509                	li	a0,2
ffffffffc0200e7e:	53d000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200e82:	34aa1763          	bne	s4,a0,ffffffffc02011d0 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200e86:	4589                	li	a1,2
ffffffffc0200e88:	5bb000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    free_page(p2);
ffffffffc0200e8c:	4585                	li	a1,1
ffffffffc0200e8e:	8562                	mv	a0,s8
ffffffffc0200e90:	5b3000ef          	jal	ra,ffffffffc0201c42 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e94:	4515                	li	a0,5
ffffffffc0200e96:	525000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200e9a:	89aa                	mv	s3,a0
ffffffffc0200e9c:	48050a63          	beqz	a0,ffffffffc0201330 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200ea0:	4505                	li	a0,1
ffffffffc0200ea2:	519000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0200ea6:	2e051563          	bnez	a0,ffffffffc0201190 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200eaa:	01092783          	lw	a5,16(s2)
ffffffffc0200eae:	2c079163          	bnez	a5,ffffffffc0201170 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200eb2:	4595                	li	a1,5
ffffffffc0200eb4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200eb6:	00015797          	auipc	a5,0x15
ffffffffc0200eba:	6377a923          	sw	s7,1586(a5) # ffffffffc02164e8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200ebe:	00015797          	auipc	a5,0x15
ffffffffc0200ec2:	6167bd23          	sd	s6,1562(a5) # ffffffffc02164d8 <free_area>
ffffffffc0200ec6:	00015797          	auipc	a5,0x15
ffffffffc0200eca:	6157bd23          	sd	s5,1562(a5) # ffffffffc02164e0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200ece:	575000ef          	jal	ra,ffffffffc0201c42 <free_pages>
    return listelm->next;
ffffffffc0200ed2:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ed6:	01278963          	beq	a5,s2,ffffffffc0200ee8 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200eda:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ede:	679c                	ld	a5,8(a5)
ffffffffc0200ee0:	34fd                	addiw	s1,s1,-1
ffffffffc0200ee2:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ee4:	ff279be3          	bne	a5,s2,ffffffffc0200eda <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200ee8:	26049463          	bnez	s1,ffffffffc0201150 <default_check+0x572>
    assert(total == 0);
ffffffffc0200eec:	46041263          	bnez	s0,ffffffffc0201350 <default_check+0x772>
}
ffffffffc0200ef0:	60a6                	ld	ra,72(sp)
ffffffffc0200ef2:	6406                	ld	s0,64(sp)
ffffffffc0200ef4:	74e2                	ld	s1,56(sp)
ffffffffc0200ef6:	7942                	ld	s2,48(sp)
ffffffffc0200ef8:	79a2                	ld	s3,40(sp)
ffffffffc0200efa:	7a02                	ld	s4,32(sp)
ffffffffc0200efc:	6ae2                	ld	s5,24(sp)
ffffffffc0200efe:	6b42                	ld	s6,16(sp)
ffffffffc0200f00:	6ba2                	ld	s7,8(sp)
ffffffffc0200f02:	6c02                	ld	s8,0(sp)
ffffffffc0200f04:	6161                	addi	sp,sp,80
ffffffffc0200f06:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f08:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200f0a:	4401                	li	s0,0
ffffffffc0200f0c:	4481                	li	s1,0
ffffffffc0200f0e:	b30d                	j	ffffffffc0200c30 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200f10:	00005697          	auipc	a3,0x5
ffffffffc0200f14:	9f868693          	addi	a3,a3,-1544 # ffffffffc0205908 <commands+0x860>
ffffffffc0200f18:	00005617          	auipc	a2,0x5
ffffffffc0200f1c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0205918 <commands+0x870>
ffffffffc0200f20:	0f000593          	li	a1,240
ffffffffc0200f24:	00005517          	auipc	a0,0x5
ffffffffc0200f28:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0205930 <commands+0x888>
ffffffffc0200f2c:	d24ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f30:	00005697          	auipc	a3,0x5
ffffffffc0200f34:	a9868693          	addi	a3,a3,-1384 # ffffffffc02059c8 <commands+0x920>
ffffffffc0200f38:	00005617          	auipc	a2,0x5
ffffffffc0200f3c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0205918 <commands+0x870>
ffffffffc0200f40:	0bd00593          	li	a1,189
ffffffffc0200f44:	00005517          	auipc	a0,0x5
ffffffffc0200f48:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0205930 <commands+0x888>
ffffffffc0200f4c:	d04ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f50:	00005697          	auipc	a3,0x5
ffffffffc0200f54:	aa068693          	addi	a3,a3,-1376 # ffffffffc02059f0 <commands+0x948>
ffffffffc0200f58:	00005617          	auipc	a2,0x5
ffffffffc0200f5c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0205918 <commands+0x870>
ffffffffc0200f60:	0be00593          	li	a1,190
ffffffffc0200f64:	00005517          	auipc	a0,0x5
ffffffffc0200f68:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0205930 <commands+0x888>
ffffffffc0200f6c:	ce4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f70:	00005697          	auipc	a3,0x5
ffffffffc0200f74:	ac068693          	addi	a3,a3,-1344 # ffffffffc0205a30 <commands+0x988>
ffffffffc0200f78:	00005617          	auipc	a2,0x5
ffffffffc0200f7c:	9a060613          	addi	a2,a2,-1632 # ffffffffc0205918 <commands+0x870>
ffffffffc0200f80:	0c000593          	li	a1,192
ffffffffc0200f84:	00005517          	auipc	a0,0x5
ffffffffc0200f88:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0205930 <commands+0x888>
ffffffffc0200f8c:	cc4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f90:	00005697          	auipc	a3,0x5
ffffffffc0200f94:	b2868693          	addi	a3,a3,-1240 # ffffffffc0205ab8 <commands+0xa10>
ffffffffc0200f98:	00005617          	auipc	a2,0x5
ffffffffc0200f9c:	98060613          	addi	a2,a2,-1664 # ffffffffc0205918 <commands+0x870>
ffffffffc0200fa0:	0d900593          	li	a1,217
ffffffffc0200fa4:	00005517          	auipc	a0,0x5
ffffffffc0200fa8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0205930 <commands+0x888>
ffffffffc0200fac:	ca4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fb0:	00005697          	auipc	a3,0x5
ffffffffc0200fb4:	9b868693          	addi	a3,a3,-1608 # ffffffffc0205968 <commands+0x8c0>
ffffffffc0200fb8:	00005617          	auipc	a2,0x5
ffffffffc0200fbc:	96060613          	addi	a2,a2,-1696 # ffffffffc0205918 <commands+0x870>
ffffffffc0200fc0:	0d200593          	li	a1,210
ffffffffc0200fc4:	00005517          	auipc	a0,0x5
ffffffffc0200fc8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0205930 <commands+0x888>
ffffffffc0200fcc:	c84ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 3);
ffffffffc0200fd0:	00005697          	auipc	a3,0x5
ffffffffc0200fd4:	ad868693          	addi	a3,a3,-1320 # ffffffffc0205aa8 <commands+0xa00>
ffffffffc0200fd8:	00005617          	auipc	a2,0x5
ffffffffc0200fdc:	94060613          	addi	a2,a2,-1728 # ffffffffc0205918 <commands+0x870>
ffffffffc0200fe0:	0d000593          	li	a1,208
ffffffffc0200fe4:	00005517          	auipc	a0,0x5
ffffffffc0200fe8:	94c50513          	addi	a0,a0,-1716 # ffffffffc0205930 <commands+0x888>
ffffffffc0200fec:	c64ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ff0:	00005697          	auipc	a3,0x5
ffffffffc0200ff4:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205a90 <commands+0x9e8>
ffffffffc0200ff8:	00005617          	auipc	a2,0x5
ffffffffc0200ffc:	92060613          	addi	a2,a2,-1760 # ffffffffc0205918 <commands+0x870>
ffffffffc0201000:	0cb00593          	li	a1,203
ffffffffc0201004:	00005517          	auipc	a0,0x5
ffffffffc0201008:	92c50513          	addi	a0,a0,-1748 # ffffffffc0205930 <commands+0x888>
ffffffffc020100c:	c44ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201010:	00005697          	auipc	a3,0x5
ffffffffc0201014:	a6068693          	addi	a3,a3,-1440 # ffffffffc0205a70 <commands+0x9c8>
ffffffffc0201018:	00005617          	auipc	a2,0x5
ffffffffc020101c:	90060613          	addi	a2,a2,-1792 # ffffffffc0205918 <commands+0x870>
ffffffffc0201020:	0c200593          	li	a1,194
ffffffffc0201024:	00005517          	auipc	a0,0x5
ffffffffc0201028:	90c50513          	addi	a0,a0,-1780 # ffffffffc0205930 <commands+0x888>
ffffffffc020102c:	c24ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != NULL);
ffffffffc0201030:	00005697          	auipc	a3,0x5
ffffffffc0201034:	ad068693          	addi	a3,a3,-1328 # ffffffffc0205b00 <commands+0xa58>
ffffffffc0201038:	00005617          	auipc	a2,0x5
ffffffffc020103c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0205918 <commands+0x870>
ffffffffc0201040:	0f800593          	li	a1,248
ffffffffc0201044:	00005517          	auipc	a0,0x5
ffffffffc0201048:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205930 <commands+0x888>
ffffffffc020104c:	c04ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201050:	00005697          	auipc	a3,0x5
ffffffffc0201054:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205af0 <commands+0xa48>
ffffffffc0201058:	00005617          	auipc	a2,0x5
ffffffffc020105c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0205918 <commands+0x870>
ffffffffc0201060:	0df00593          	li	a1,223
ffffffffc0201064:	00005517          	auipc	a0,0x5
ffffffffc0201068:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0205930 <commands+0x888>
ffffffffc020106c:	be4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201070:	00005697          	auipc	a3,0x5
ffffffffc0201074:	a2068693          	addi	a3,a3,-1504 # ffffffffc0205a90 <commands+0x9e8>
ffffffffc0201078:	00005617          	auipc	a2,0x5
ffffffffc020107c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0205918 <commands+0x870>
ffffffffc0201080:	0dd00593          	li	a1,221
ffffffffc0201084:	00005517          	auipc	a0,0x5
ffffffffc0201088:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0205930 <commands+0x888>
ffffffffc020108c:	bc4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201090:	00005697          	auipc	a3,0x5
ffffffffc0201094:	a4068693          	addi	a3,a3,-1472 # ffffffffc0205ad0 <commands+0xa28>
ffffffffc0201098:	00005617          	auipc	a2,0x5
ffffffffc020109c:	88060613          	addi	a2,a2,-1920 # ffffffffc0205918 <commands+0x870>
ffffffffc02010a0:	0dc00593          	li	a1,220
ffffffffc02010a4:	00005517          	auipc	a0,0x5
ffffffffc02010a8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205930 <commands+0x888>
ffffffffc02010ac:	ba4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010b0:	00005697          	auipc	a3,0x5
ffffffffc02010b4:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205968 <commands+0x8c0>
ffffffffc02010b8:	00005617          	auipc	a2,0x5
ffffffffc02010bc:	86060613          	addi	a2,a2,-1952 # ffffffffc0205918 <commands+0x870>
ffffffffc02010c0:	0b900593          	li	a1,185
ffffffffc02010c4:	00005517          	auipc	a0,0x5
ffffffffc02010c8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0205930 <commands+0x888>
ffffffffc02010cc:	b84ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010d0:	00005697          	auipc	a3,0x5
ffffffffc02010d4:	9c068693          	addi	a3,a3,-1600 # ffffffffc0205a90 <commands+0x9e8>
ffffffffc02010d8:	00005617          	auipc	a2,0x5
ffffffffc02010dc:	84060613          	addi	a2,a2,-1984 # ffffffffc0205918 <commands+0x870>
ffffffffc02010e0:	0d600593          	li	a1,214
ffffffffc02010e4:	00005517          	auipc	a0,0x5
ffffffffc02010e8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0205930 <commands+0x888>
ffffffffc02010ec:	b64ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010f0:	00005697          	auipc	a3,0x5
ffffffffc02010f4:	8b868693          	addi	a3,a3,-1864 # ffffffffc02059a8 <commands+0x900>
ffffffffc02010f8:	00005617          	auipc	a2,0x5
ffffffffc02010fc:	82060613          	addi	a2,a2,-2016 # ffffffffc0205918 <commands+0x870>
ffffffffc0201100:	0d400593          	li	a1,212
ffffffffc0201104:	00005517          	auipc	a0,0x5
ffffffffc0201108:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205930 <commands+0x888>
ffffffffc020110c:	b44ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201110:	00005697          	auipc	a3,0x5
ffffffffc0201114:	87868693          	addi	a3,a3,-1928 # ffffffffc0205988 <commands+0x8e0>
ffffffffc0201118:	00005617          	auipc	a2,0x5
ffffffffc020111c:	80060613          	addi	a2,a2,-2048 # ffffffffc0205918 <commands+0x870>
ffffffffc0201120:	0d300593          	li	a1,211
ffffffffc0201124:	00005517          	auipc	a0,0x5
ffffffffc0201128:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205930 <commands+0x888>
ffffffffc020112c:	b24ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201130:	00005697          	auipc	a3,0x5
ffffffffc0201134:	87868693          	addi	a3,a3,-1928 # ffffffffc02059a8 <commands+0x900>
ffffffffc0201138:	00004617          	auipc	a2,0x4
ffffffffc020113c:	7e060613          	addi	a2,a2,2016 # ffffffffc0205918 <commands+0x870>
ffffffffc0201140:	0bb00593          	li	a1,187
ffffffffc0201144:	00004517          	auipc	a0,0x4
ffffffffc0201148:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205930 <commands+0x888>
ffffffffc020114c:	b04ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(count == 0);
ffffffffc0201150:	00005697          	auipc	a3,0x5
ffffffffc0201154:	b0068693          	addi	a3,a3,-1280 # ffffffffc0205c50 <commands+0xba8>
ffffffffc0201158:	00004617          	auipc	a2,0x4
ffffffffc020115c:	7c060613          	addi	a2,a2,1984 # ffffffffc0205918 <commands+0x870>
ffffffffc0201160:	12500593          	li	a1,293
ffffffffc0201164:	00004517          	auipc	a0,0x4
ffffffffc0201168:	7cc50513          	addi	a0,a0,1996 # ffffffffc0205930 <commands+0x888>
ffffffffc020116c:	ae4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201170:	00005697          	auipc	a3,0x5
ffffffffc0201174:	98068693          	addi	a3,a3,-1664 # ffffffffc0205af0 <commands+0xa48>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	7a060613          	addi	a2,a2,1952 # ffffffffc0205918 <commands+0x870>
ffffffffc0201180:	11a00593          	li	a1,282
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205930 <commands+0x888>
ffffffffc020118c:	ac4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201190:	00005697          	auipc	a3,0x5
ffffffffc0201194:	90068693          	addi	a3,a3,-1792 # ffffffffc0205a90 <commands+0x9e8>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	78060613          	addi	a2,a2,1920 # ffffffffc0205918 <commands+0x870>
ffffffffc02011a0:	11800593          	li	a1,280
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	78c50513          	addi	a0,a0,1932 # ffffffffc0205930 <commands+0x888>
ffffffffc02011ac:	aa4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02011b0:	00005697          	auipc	a3,0x5
ffffffffc02011b4:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205a50 <commands+0x9a8>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	76060613          	addi	a2,a2,1888 # ffffffffc0205918 <commands+0x870>
ffffffffc02011c0:	0c100593          	li	a1,193
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	76c50513          	addi	a0,a0,1900 # ffffffffc0205930 <commands+0x888>
ffffffffc02011cc:	a84ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02011d0:	00005697          	auipc	a3,0x5
ffffffffc02011d4:	a4068693          	addi	a3,a3,-1472 # ffffffffc0205c10 <commands+0xb68>
ffffffffc02011d8:	00004617          	auipc	a2,0x4
ffffffffc02011dc:	74060613          	addi	a2,a2,1856 # ffffffffc0205918 <commands+0x870>
ffffffffc02011e0:	11200593          	li	a1,274
ffffffffc02011e4:	00004517          	auipc	a0,0x4
ffffffffc02011e8:	74c50513          	addi	a0,a0,1868 # ffffffffc0205930 <commands+0x888>
ffffffffc02011ec:	a64ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011f0:	00005697          	auipc	a3,0x5
ffffffffc02011f4:	a0068693          	addi	a3,a3,-1536 # ffffffffc0205bf0 <commands+0xb48>
ffffffffc02011f8:	00004617          	auipc	a2,0x4
ffffffffc02011fc:	72060613          	addi	a2,a2,1824 # ffffffffc0205918 <commands+0x870>
ffffffffc0201200:	11000593          	li	a1,272
ffffffffc0201204:	00004517          	auipc	a0,0x4
ffffffffc0201208:	72c50513          	addi	a0,a0,1836 # ffffffffc0205930 <commands+0x888>
ffffffffc020120c:	a44ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201210:	00005697          	auipc	a3,0x5
ffffffffc0201214:	9b868693          	addi	a3,a3,-1608 # ffffffffc0205bc8 <commands+0xb20>
ffffffffc0201218:	00004617          	auipc	a2,0x4
ffffffffc020121c:	70060613          	addi	a2,a2,1792 # ffffffffc0205918 <commands+0x870>
ffffffffc0201220:	10e00593          	li	a1,270
ffffffffc0201224:	00004517          	auipc	a0,0x4
ffffffffc0201228:	70c50513          	addi	a0,a0,1804 # ffffffffc0205930 <commands+0x888>
ffffffffc020122c:	a24ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201230:	00005697          	auipc	a3,0x5
ffffffffc0201234:	97068693          	addi	a3,a3,-1680 # ffffffffc0205ba0 <commands+0xaf8>
ffffffffc0201238:	00004617          	auipc	a2,0x4
ffffffffc020123c:	6e060613          	addi	a2,a2,1760 # ffffffffc0205918 <commands+0x870>
ffffffffc0201240:	10d00593          	li	a1,269
ffffffffc0201244:	00004517          	auipc	a0,0x4
ffffffffc0201248:	6ec50513          	addi	a0,a0,1772 # ffffffffc0205930 <commands+0x888>
ffffffffc020124c:	a04ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201250:	00005697          	auipc	a3,0x5
ffffffffc0201254:	94068693          	addi	a3,a3,-1728 # ffffffffc0205b90 <commands+0xae8>
ffffffffc0201258:	00004617          	auipc	a2,0x4
ffffffffc020125c:	6c060613          	addi	a2,a2,1728 # ffffffffc0205918 <commands+0x870>
ffffffffc0201260:	10800593          	li	a1,264
ffffffffc0201264:	00004517          	auipc	a0,0x4
ffffffffc0201268:	6cc50513          	addi	a0,a0,1740 # ffffffffc0205930 <commands+0x888>
ffffffffc020126c:	9e4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201270:	00005697          	auipc	a3,0x5
ffffffffc0201274:	82068693          	addi	a3,a3,-2016 # ffffffffc0205a90 <commands+0x9e8>
ffffffffc0201278:	00004617          	auipc	a2,0x4
ffffffffc020127c:	6a060613          	addi	a2,a2,1696 # ffffffffc0205918 <commands+0x870>
ffffffffc0201280:	10700593          	li	a1,263
ffffffffc0201284:	00004517          	auipc	a0,0x4
ffffffffc0201288:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205930 <commands+0x888>
ffffffffc020128c:	9c4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201290:	00005697          	auipc	a3,0x5
ffffffffc0201294:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205b70 <commands+0xac8>
ffffffffc0201298:	00004617          	auipc	a2,0x4
ffffffffc020129c:	68060613          	addi	a2,a2,1664 # ffffffffc0205918 <commands+0x870>
ffffffffc02012a0:	10600593          	li	a1,262
ffffffffc02012a4:	00004517          	auipc	a0,0x4
ffffffffc02012a8:	68c50513          	addi	a0,a0,1676 # ffffffffc0205930 <commands+0x888>
ffffffffc02012ac:	9a4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02012b0:	00005697          	auipc	a3,0x5
ffffffffc02012b4:	89068693          	addi	a3,a3,-1904 # ffffffffc0205b40 <commands+0xa98>
ffffffffc02012b8:	00004617          	auipc	a2,0x4
ffffffffc02012bc:	66060613          	addi	a2,a2,1632 # ffffffffc0205918 <commands+0x870>
ffffffffc02012c0:	10500593          	li	a1,261
ffffffffc02012c4:	00004517          	auipc	a0,0x4
ffffffffc02012c8:	66c50513          	addi	a0,a0,1644 # ffffffffc0205930 <commands+0x888>
ffffffffc02012cc:	984ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02012d0:	00005697          	auipc	a3,0x5
ffffffffc02012d4:	85868693          	addi	a3,a3,-1960 # ffffffffc0205b28 <commands+0xa80>
ffffffffc02012d8:	00004617          	auipc	a2,0x4
ffffffffc02012dc:	64060613          	addi	a2,a2,1600 # ffffffffc0205918 <commands+0x870>
ffffffffc02012e0:	10400593          	li	a1,260
ffffffffc02012e4:	00004517          	auipc	a0,0x4
ffffffffc02012e8:	64c50513          	addi	a0,a0,1612 # ffffffffc0205930 <commands+0x888>
ffffffffc02012ec:	964ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012f0:	00004697          	auipc	a3,0x4
ffffffffc02012f4:	7a068693          	addi	a3,a3,1952 # ffffffffc0205a90 <commands+0x9e8>
ffffffffc02012f8:	00004617          	auipc	a2,0x4
ffffffffc02012fc:	62060613          	addi	a2,a2,1568 # ffffffffc0205918 <commands+0x870>
ffffffffc0201300:	0fe00593          	li	a1,254
ffffffffc0201304:	00004517          	auipc	a0,0x4
ffffffffc0201308:	62c50513          	addi	a0,a0,1580 # ffffffffc0205930 <commands+0x888>
ffffffffc020130c:	944ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201310:	00005697          	auipc	a3,0x5
ffffffffc0201314:	80068693          	addi	a3,a3,-2048 # ffffffffc0205b10 <commands+0xa68>
ffffffffc0201318:	00004617          	auipc	a2,0x4
ffffffffc020131c:	60060613          	addi	a2,a2,1536 # ffffffffc0205918 <commands+0x870>
ffffffffc0201320:	0f900593          	li	a1,249
ffffffffc0201324:	00004517          	auipc	a0,0x4
ffffffffc0201328:	60c50513          	addi	a0,a0,1548 # ffffffffc0205930 <commands+0x888>
ffffffffc020132c:	924ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201330:	00005697          	auipc	a3,0x5
ffffffffc0201334:	90068693          	addi	a3,a3,-1792 # ffffffffc0205c30 <commands+0xb88>
ffffffffc0201338:	00004617          	auipc	a2,0x4
ffffffffc020133c:	5e060613          	addi	a2,a2,1504 # ffffffffc0205918 <commands+0x870>
ffffffffc0201340:	11700593          	li	a1,279
ffffffffc0201344:	00004517          	auipc	a0,0x4
ffffffffc0201348:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205930 <commands+0x888>
ffffffffc020134c:	904ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == 0);
ffffffffc0201350:	00005697          	auipc	a3,0x5
ffffffffc0201354:	91068693          	addi	a3,a3,-1776 # ffffffffc0205c60 <commands+0xbb8>
ffffffffc0201358:	00004617          	auipc	a2,0x4
ffffffffc020135c:	5c060613          	addi	a2,a2,1472 # ffffffffc0205918 <commands+0x870>
ffffffffc0201360:	12600593          	li	a1,294
ffffffffc0201364:	00004517          	auipc	a0,0x4
ffffffffc0201368:	5cc50513          	addi	a0,a0,1484 # ffffffffc0205930 <commands+0x888>
ffffffffc020136c:	8e4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201370:	00004697          	auipc	a3,0x4
ffffffffc0201374:	5d868693          	addi	a3,a3,1496 # ffffffffc0205948 <commands+0x8a0>
ffffffffc0201378:	00004617          	auipc	a2,0x4
ffffffffc020137c:	5a060613          	addi	a2,a2,1440 # ffffffffc0205918 <commands+0x870>
ffffffffc0201380:	0f300593          	li	a1,243
ffffffffc0201384:	00004517          	auipc	a0,0x4
ffffffffc0201388:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205930 <commands+0x888>
ffffffffc020138c:	8c4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201390:	00004697          	auipc	a3,0x4
ffffffffc0201394:	5f868693          	addi	a3,a3,1528 # ffffffffc0205988 <commands+0x8e0>
ffffffffc0201398:	00004617          	auipc	a2,0x4
ffffffffc020139c:	58060613          	addi	a2,a2,1408 # ffffffffc0205918 <commands+0x870>
ffffffffc02013a0:	0ba00593          	li	a1,186
ffffffffc02013a4:	00004517          	auipc	a0,0x4
ffffffffc02013a8:	58c50513          	addi	a0,a0,1420 # ffffffffc0205930 <commands+0x888>
ffffffffc02013ac:	8a4ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02013b0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02013b0:	1141                	addi	sp,sp,-16
ffffffffc02013b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013b4:	16058e63          	beqz	a1,ffffffffc0201530 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02013b8:	00659693          	slli	a3,a1,0x6
ffffffffc02013bc:	96aa                	add	a3,a3,a0
ffffffffc02013be:	02d50d63          	beq	a0,a3,ffffffffc02013f8 <default_free_pages+0x48>
ffffffffc02013c2:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013c4:	8b85                	andi	a5,a5,1
ffffffffc02013c6:	14079563          	bnez	a5,ffffffffc0201510 <default_free_pages+0x160>
ffffffffc02013ca:	651c                	ld	a5,8(a0)
ffffffffc02013cc:	8385                	srli	a5,a5,0x1
ffffffffc02013ce:	8b85                	andi	a5,a5,1
ffffffffc02013d0:	14079063          	bnez	a5,ffffffffc0201510 <default_free_pages+0x160>
ffffffffc02013d4:	87aa                	mv	a5,a0
ffffffffc02013d6:	a809                	j	ffffffffc02013e8 <default_free_pages+0x38>
ffffffffc02013d8:	6798                	ld	a4,8(a5)
ffffffffc02013da:	8b05                	andi	a4,a4,1
ffffffffc02013dc:	12071a63          	bnez	a4,ffffffffc0201510 <default_free_pages+0x160>
ffffffffc02013e0:	6798                	ld	a4,8(a5)
ffffffffc02013e2:	8b09                	andi	a4,a4,2
ffffffffc02013e4:	12071663          	bnez	a4,ffffffffc0201510 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02013e8:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02013ec:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013f0:	04078793          	addi	a5,a5,64
ffffffffc02013f4:	fed792e3          	bne	a5,a3,ffffffffc02013d8 <default_free_pages+0x28>
    base->property = n;
ffffffffc02013f8:	2581                	sext.w	a1,a1
ffffffffc02013fa:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02013fc:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201400:	4789                	li	a5,2
ffffffffc0201402:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201406:	00015697          	auipc	a3,0x15
ffffffffc020140a:	0d268693          	addi	a3,a3,210 # ffffffffc02164d8 <free_area>
ffffffffc020140e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201410:	669c                	ld	a5,8(a3)
ffffffffc0201412:	9db9                	addw	a1,a1,a4
ffffffffc0201414:	00015717          	auipc	a4,0x15
ffffffffc0201418:	0cb72a23          	sw	a1,212(a4) # ffffffffc02164e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020141c:	0cd78163          	beq	a5,a3,ffffffffc02014de <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201420:	fe878713          	addi	a4,a5,-24
ffffffffc0201424:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201426:	4801                	li	a6,0
ffffffffc0201428:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020142c:	00e56a63          	bltu	a0,a4,ffffffffc0201440 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0201430:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201432:	04d70f63          	beq	a4,a3,ffffffffc0201490 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201436:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201438:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020143c:	fee57ae3          	bleu	a4,a0,ffffffffc0201430 <default_free_pages+0x80>
ffffffffc0201440:	00080663          	beqz	a6,ffffffffc020144c <default_free_pages+0x9c>
ffffffffc0201444:	00015817          	auipc	a6,0x15
ffffffffc0201448:	08b83a23          	sd	a1,148(a6) # ffffffffc02164d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020144c:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020144e:	e390                	sd	a2,0(a5)
ffffffffc0201450:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201452:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201454:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201456:	06d58a63          	beq	a1,a3,ffffffffc02014ca <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc020145a:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020145e:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201462:	02061793          	slli	a5,a2,0x20
ffffffffc0201466:	83e9                	srli	a5,a5,0x1a
ffffffffc0201468:	97ba                	add	a5,a5,a4
ffffffffc020146a:	04f51b63          	bne	a0,a5,ffffffffc02014c0 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020146e:	491c                	lw	a5,16(a0)
ffffffffc0201470:	9e3d                	addw	a2,a2,a5
ffffffffc0201472:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201476:	57f5                	li	a5,-3
ffffffffc0201478:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020147c:	01853803          	ld	a6,24(a0)
ffffffffc0201480:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201482:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201484:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201488:	659c                	ld	a5,8(a1)
ffffffffc020148a:	01063023          	sd	a6,0(a2)
ffffffffc020148e:	a815                	j	ffffffffc02014c2 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201490:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201492:	f114                	sd	a3,32(a0)
ffffffffc0201494:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201496:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201498:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020149a:	00d70563          	beq	a4,a3,ffffffffc02014a4 <default_free_pages+0xf4>
ffffffffc020149e:	4805                	li	a6,1
ffffffffc02014a0:	87ba                	mv	a5,a4
ffffffffc02014a2:	bf59                	j	ffffffffc0201438 <default_free_pages+0x88>
ffffffffc02014a4:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02014a6:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02014a8:	00d78d63          	beq	a5,a3,ffffffffc02014c2 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02014ac:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02014b0:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02014b4:	02061793          	slli	a5,a2,0x20
ffffffffc02014b8:	83e9                	srli	a5,a5,0x1a
ffffffffc02014ba:	97ba                	add	a5,a5,a4
ffffffffc02014bc:	faf509e3          	beq	a0,a5,ffffffffc020146e <default_free_pages+0xbe>
ffffffffc02014c0:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02014c2:	fe878713          	addi	a4,a5,-24
ffffffffc02014c6:	00d78963          	beq	a5,a3,ffffffffc02014d8 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02014ca:	4910                	lw	a2,16(a0)
ffffffffc02014cc:	02061693          	slli	a3,a2,0x20
ffffffffc02014d0:	82e9                	srli	a3,a3,0x1a
ffffffffc02014d2:	96aa                	add	a3,a3,a0
ffffffffc02014d4:	00d70e63          	beq	a4,a3,ffffffffc02014f0 <default_free_pages+0x140>
}
ffffffffc02014d8:	60a2                	ld	ra,8(sp)
ffffffffc02014da:	0141                	addi	sp,sp,16
ffffffffc02014dc:	8082                	ret
ffffffffc02014de:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014e0:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014e4:	e398                	sd	a4,0(a5)
ffffffffc02014e6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014e8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014ea:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014ec:	0141                	addi	sp,sp,16
ffffffffc02014ee:	8082                	ret
            base->property += p->property;
ffffffffc02014f0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014f4:	ff078693          	addi	a3,a5,-16
ffffffffc02014f8:	9e39                	addw	a2,a2,a4
ffffffffc02014fa:	c910                	sw	a2,16(a0)
ffffffffc02014fc:	5775                	li	a4,-3
ffffffffc02014fe:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201502:	6398                	ld	a4,0(a5)
ffffffffc0201504:	679c                	ld	a5,8(a5)
}
ffffffffc0201506:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201508:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020150a:	e398                	sd	a4,0(a5)
ffffffffc020150c:	0141                	addi	sp,sp,16
ffffffffc020150e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201510:	00004697          	auipc	a3,0x4
ffffffffc0201514:	76068693          	addi	a3,a3,1888 # ffffffffc0205c70 <commands+0xbc8>
ffffffffc0201518:	00004617          	auipc	a2,0x4
ffffffffc020151c:	40060613          	addi	a2,a2,1024 # ffffffffc0205918 <commands+0x870>
ffffffffc0201520:	08300593          	li	a1,131
ffffffffc0201524:	00004517          	auipc	a0,0x4
ffffffffc0201528:	40c50513          	addi	a0,a0,1036 # ffffffffc0205930 <commands+0x888>
ffffffffc020152c:	f25fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc0201530:	00004697          	auipc	a3,0x4
ffffffffc0201534:	76868693          	addi	a3,a3,1896 # ffffffffc0205c98 <commands+0xbf0>
ffffffffc0201538:	00004617          	auipc	a2,0x4
ffffffffc020153c:	3e060613          	addi	a2,a2,992 # ffffffffc0205918 <commands+0x870>
ffffffffc0201540:	08000593          	li	a1,128
ffffffffc0201544:	00004517          	auipc	a0,0x4
ffffffffc0201548:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205930 <commands+0x888>
ffffffffc020154c:	f05fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201550 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201550:	c959                	beqz	a0,ffffffffc02015e6 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0201552:	00015597          	auipc	a1,0x15
ffffffffc0201556:	f8658593          	addi	a1,a1,-122 # ffffffffc02164d8 <free_area>
ffffffffc020155a:	0105a803          	lw	a6,16(a1)
ffffffffc020155e:	862a                	mv	a2,a0
ffffffffc0201560:	02081793          	slli	a5,a6,0x20
ffffffffc0201564:	9381                	srli	a5,a5,0x20
ffffffffc0201566:	00a7ee63          	bltu	a5,a0,ffffffffc0201582 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020156a:	87ae                	mv	a5,a1
ffffffffc020156c:	a801                	j	ffffffffc020157c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020156e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201572:	02071693          	slli	a3,a4,0x20
ffffffffc0201576:	9281                	srli	a3,a3,0x20
ffffffffc0201578:	00c6f763          	bleu	a2,a3,ffffffffc0201586 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020157c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020157e:	feb798e3          	bne	a5,a1,ffffffffc020156e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201582:	4501                	li	a0,0
}
ffffffffc0201584:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201586:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020158a:	dd6d                	beqz	a0,ffffffffc0201584 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020158c:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201590:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201594:	00060e1b          	sext.w	t3,a2
ffffffffc0201598:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020159c:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02015a0:	02d67863          	bleu	a3,a2,ffffffffc02015d0 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02015a4:	061a                	slli	a2,a2,0x6
ffffffffc02015a6:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02015a8:	41c7073b          	subw	a4,a4,t3
ffffffffc02015ac:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015ae:	00860693          	addi	a3,a2,8
ffffffffc02015b2:	4709                	li	a4,2
ffffffffc02015b4:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02015b8:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02015bc:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02015c0:	0105a803          	lw	a6,16(a1)
ffffffffc02015c4:	e314                	sd	a3,0(a4)
ffffffffc02015c6:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02015ca:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02015cc:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02015d0:	41c8083b          	subw	a6,a6,t3
ffffffffc02015d4:	00015717          	auipc	a4,0x15
ffffffffc02015d8:	f1072a23          	sw	a6,-236(a4) # ffffffffc02164e8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015dc:	5775                	li	a4,-3
ffffffffc02015de:	17c1                	addi	a5,a5,-16
ffffffffc02015e0:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02015e4:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02015e6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02015e8:	00004697          	auipc	a3,0x4
ffffffffc02015ec:	6b068693          	addi	a3,a3,1712 # ffffffffc0205c98 <commands+0xbf0>
ffffffffc02015f0:	00004617          	auipc	a2,0x4
ffffffffc02015f4:	32860613          	addi	a2,a2,808 # ffffffffc0205918 <commands+0x870>
ffffffffc02015f8:	06200593          	li	a1,98
ffffffffc02015fc:	00004517          	auipc	a0,0x4
ffffffffc0201600:	33450513          	addi	a0,a0,820 # ffffffffc0205930 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201604:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201606:	e4bfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020160a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020160a:	1141                	addi	sp,sp,-16
ffffffffc020160c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020160e:	c1ed                	beqz	a1,ffffffffc02016f0 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201610:	00659693          	slli	a3,a1,0x6
ffffffffc0201614:	96aa                	add	a3,a3,a0
ffffffffc0201616:	02d50463          	beq	a0,a3,ffffffffc020163e <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020161a:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020161c:	87aa                	mv	a5,a0
ffffffffc020161e:	8b05                	andi	a4,a4,1
ffffffffc0201620:	e709                	bnez	a4,ffffffffc020162a <default_init_memmap+0x20>
ffffffffc0201622:	a07d                	j	ffffffffc02016d0 <default_init_memmap+0xc6>
ffffffffc0201624:	6798                	ld	a4,8(a5)
ffffffffc0201626:	8b05                	andi	a4,a4,1
ffffffffc0201628:	c745                	beqz	a4,ffffffffc02016d0 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc020162a:	0007a823          	sw	zero,16(a5)
ffffffffc020162e:	0007b423          	sd	zero,8(a5)
ffffffffc0201632:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201636:	04078793          	addi	a5,a5,64
ffffffffc020163a:	fed795e3          	bne	a5,a3,ffffffffc0201624 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc020163e:	2581                	sext.w	a1,a1
ffffffffc0201640:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201642:	4789                	li	a5,2
ffffffffc0201644:	00850713          	addi	a4,a0,8
ffffffffc0201648:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020164c:	00015697          	auipc	a3,0x15
ffffffffc0201650:	e8c68693          	addi	a3,a3,-372 # ffffffffc02164d8 <free_area>
ffffffffc0201654:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201656:	669c                	ld	a5,8(a3)
ffffffffc0201658:	9db9                	addw	a1,a1,a4
ffffffffc020165a:	00015717          	auipc	a4,0x15
ffffffffc020165e:	e8b72723          	sw	a1,-370(a4) # ffffffffc02164e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201662:	04d78a63          	beq	a5,a3,ffffffffc02016b6 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0201666:	fe878713          	addi	a4,a5,-24
ffffffffc020166a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020166c:	4801                	li	a6,0
ffffffffc020166e:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201672:	00e56a63          	bltu	a0,a4,ffffffffc0201686 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0201676:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201678:	02d70563          	beq	a4,a3,ffffffffc02016a2 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020167c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020167e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201682:	fee57ae3          	bleu	a4,a0,ffffffffc0201676 <default_init_memmap+0x6c>
ffffffffc0201686:	00080663          	beqz	a6,ffffffffc0201692 <default_init_memmap+0x88>
ffffffffc020168a:	00015717          	auipc	a4,0x15
ffffffffc020168e:	e4b73723          	sd	a1,-434(a4) # ffffffffc02164d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201692:	6398                	ld	a4,0(a5)
}
ffffffffc0201694:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201696:	e390                	sd	a2,0(a5)
ffffffffc0201698:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020169a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020169c:	ed18                	sd	a4,24(a0)
ffffffffc020169e:	0141                	addi	sp,sp,16
ffffffffc02016a0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016a2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016a4:	f114                	sd	a3,32(a0)
ffffffffc02016a6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016a8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016aa:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ac:	00d70e63          	beq	a4,a3,ffffffffc02016c8 <default_init_memmap+0xbe>
ffffffffc02016b0:	4805                	li	a6,1
ffffffffc02016b2:	87ba                	mv	a5,a4
ffffffffc02016b4:	b7e9                	j	ffffffffc020167e <default_init_memmap+0x74>
}
ffffffffc02016b6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02016b8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02016bc:	e398                	sd	a4,0(a5)
ffffffffc02016be:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02016c0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016c2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02016c4:	0141                	addi	sp,sp,16
ffffffffc02016c6:	8082                	ret
ffffffffc02016c8:	60a2                	ld	ra,8(sp)
ffffffffc02016ca:	e290                	sd	a2,0(a3)
ffffffffc02016cc:	0141                	addi	sp,sp,16
ffffffffc02016ce:	8082                	ret
        assert(PageReserved(p));
ffffffffc02016d0:	00004697          	auipc	a3,0x4
ffffffffc02016d4:	5d068693          	addi	a3,a3,1488 # ffffffffc0205ca0 <commands+0xbf8>
ffffffffc02016d8:	00004617          	auipc	a2,0x4
ffffffffc02016dc:	24060613          	addi	a2,a2,576 # ffffffffc0205918 <commands+0x870>
ffffffffc02016e0:	04900593          	li	a1,73
ffffffffc02016e4:	00004517          	auipc	a0,0x4
ffffffffc02016e8:	24c50513          	addi	a0,a0,588 # ffffffffc0205930 <commands+0x888>
ffffffffc02016ec:	d65fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02016f0:	00004697          	auipc	a3,0x4
ffffffffc02016f4:	5a868693          	addi	a3,a3,1448 # ffffffffc0205c98 <commands+0xbf0>
ffffffffc02016f8:	00004617          	auipc	a2,0x4
ffffffffc02016fc:	22060613          	addi	a2,a2,544 # ffffffffc0205918 <commands+0x870>
ffffffffc0201700:	04600593          	li	a1,70
ffffffffc0201704:	00004517          	auipc	a0,0x4
ffffffffc0201708:	22c50513          	addi	a0,a0,556 # ffffffffc0205930 <commands+0x888>
ffffffffc020170c:	d45fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201710 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201710:	c125                	beqz	a0,ffffffffc0201770 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201712:	e1a5                	bnez	a1,ffffffffc0201772 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201714:	100027f3          	csrr	a5,sstatus
ffffffffc0201718:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020171a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020171c:	e3bd                	bnez	a5,ffffffffc0201782 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020171e:	0000a797          	auipc	a5,0xa
ffffffffc0201722:	93278793          	addi	a5,a5,-1742 # ffffffffc020b050 <slobfree>
ffffffffc0201726:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201728:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020172a:	00a7fa63          	bleu	a0,a5,ffffffffc020173e <slob_free+0x2e>
ffffffffc020172e:	00e56c63          	bltu	a0,a4,ffffffffc0201746 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201732:	00e7fa63          	bleu	a4,a5,ffffffffc0201746 <slob_free+0x36>
    return 0;
ffffffffc0201736:	87ba                	mv	a5,a4
ffffffffc0201738:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020173a:	fea7eae3          	bltu	a5,a0,ffffffffc020172e <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020173e:	fee7ece3          	bltu	a5,a4,ffffffffc0201736 <slob_free+0x26>
ffffffffc0201742:	fee57ae3          	bleu	a4,a0,ffffffffc0201736 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201746:	4110                	lw	a2,0(a0)
ffffffffc0201748:	00461693          	slli	a3,a2,0x4
ffffffffc020174c:	96aa                	add	a3,a3,a0
ffffffffc020174e:	08d70b63          	beq	a4,a3,ffffffffc02017e4 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201752:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201754:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201756:	00469713          	slli	a4,a3,0x4
ffffffffc020175a:	973e                	add	a4,a4,a5
ffffffffc020175c:	08e50f63          	beq	a0,a4,ffffffffc02017fa <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201760:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201762:	0000a717          	auipc	a4,0xa
ffffffffc0201766:	8ef73723          	sd	a5,-1810(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc020176a:	c199                	beqz	a1,ffffffffc0201770 <slob_free+0x60>
        intr_enable();
ffffffffc020176c:	e67fe06f          	j	ffffffffc02005d2 <intr_enable>
ffffffffc0201770:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201772:	05bd                	addi	a1,a1,15
ffffffffc0201774:	8191                	srli	a1,a1,0x4
ffffffffc0201776:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201778:	100027f3          	csrr	a5,sstatus
ffffffffc020177c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020177e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201780:	dfd9                	beqz	a5,ffffffffc020171e <slob_free+0xe>
{
ffffffffc0201782:	1101                	addi	sp,sp,-32
ffffffffc0201784:	e42a                	sd	a0,8(sp)
ffffffffc0201786:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201788:	e51fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020178c:	0000a797          	auipc	a5,0xa
ffffffffc0201790:	8c478793          	addi	a5,a5,-1852 # ffffffffc020b050 <slobfree>
ffffffffc0201794:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201796:	6522                	ld	a0,8(sp)
ffffffffc0201798:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020179a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020179c:	00a7fa63          	bleu	a0,a5,ffffffffc02017b0 <slob_free+0xa0>
ffffffffc02017a0:	00e56c63          	bltu	a0,a4,ffffffffc02017b8 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017a4:	00e7fa63          	bleu	a4,a5,ffffffffc02017b8 <slob_free+0xa8>
    return 0;
ffffffffc02017a8:	87ba                	mv	a5,a4
ffffffffc02017aa:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017ac:	fea7eae3          	bltu	a5,a0,ffffffffc02017a0 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017b0:	fee7ece3          	bltu	a5,a4,ffffffffc02017a8 <slob_free+0x98>
ffffffffc02017b4:	fee57ae3          	bleu	a4,a0,ffffffffc02017a8 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02017b8:	4110                	lw	a2,0(a0)
ffffffffc02017ba:	00461693          	slli	a3,a2,0x4
ffffffffc02017be:	96aa                	add	a3,a3,a0
ffffffffc02017c0:	04d70763          	beq	a4,a3,ffffffffc020180e <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02017c4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017c6:	4394                	lw	a3,0(a5)
ffffffffc02017c8:	00469713          	slli	a4,a3,0x4
ffffffffc02017cc:	973e                	add	a4,a4,a5
ffffffffc02017ce:	04e50663          	beq	a0,a4,ffffffffc020181a <slob_free+0x10a>
		cur->next = b;
ffffffffc02017d2:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02017d4:	0000a717          	auipc	a4,0xa
ffffffffc02017d8:	86f73e23          	sd	a5,-1924(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc02017dc:	e58d                	bnez	a1,ffffffffc0201806 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02017de:	60e2                	ld	ra,24(sp)
ffffffffc02017e0:	6105                	addi	sp,sp,32
ffffffffc02017e2:	8082                	ret
		b->units += cur->next->units;
ffffffffc02017e4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017e6:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017e8:	9e35                	addw	a2,a2,a3
ffffffffc02017ea:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02017ec:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02017ee:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017f0:	00469713          	slli	a4,a3,0x4
ffffffffc02017f4:	973e                	add	a4,a4,a5
ffffffffc02017f6:	f6e515e3          	bne	a0,a4,ffffffffc0201760 <slob_free+0x50>
		cur->units += b->units;
ffffffffc02017fa:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017fc:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017fe:	9eb9                	addw	a3,a3,a4
ffffffffc0201800:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201802:	e790                	sd	a2,8(a5)
ffffffffc0201804:	bfb9                	j	ffffffffc0201762 <slob_free+0x52>
}
ffffffffc0201806:	60e2                	ld	ra,24(sp)
ffffffffc0201808:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020180a:	dc9fe06f          	j	ffffffffc02005d2 <intr_enable>
		b->units += cur->next->units;
ffffffffc020180e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201810:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201812:	9e35                	addw	a2,a2,a3
ffffffffc0201814:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201816:	e518                	sd	a4,8(a0)
ffffffffc0201818:	b77d                	j	ffffffffc02017c6 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020181a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020181c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020181e:	9eb9                	addw	a3,a3,a4
ffffffffc0201820:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201822:	e790                	sd	a2,8(a5)
ffffffffc0201824:	bf45                	j	ffffffffc02017d4 <slob_free+0xc4>

ffffffffc0201826 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201826:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201828:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020182a:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020182e:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201830:	38a000ef          	jal	ra,ffffffffc0201bba <alloc_pages>
  if(!page)
ffffffffc0201834:	c139                	beqz	a0,ffffffffc020187a <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201836:	00015797          	auipc	a5,0x15
ffffffffc020183a:	cd278793          	addi	a5,a5,-814 # ffffffffc0216508 <pages>
ffffffffc020183e:	6394                	ld	a3,0(a5)
ffffffffc0201840:	00006797          	auipc	a5,0x6
ffffffffc0201844:	81878793          	addi	a5,a5,-2024 # ffffffffc0207058 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201848:	00015717          	auipc	a4,0x15
ffffffffc020184c:	c5070713          	addi	a4,a4,-944 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0201850:	40d506b3          	sub	a3,a0,a3
ffffffffc0201854:	6388                	ld	a0,0(a5)
ffffffffc0201856:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201858:	57fd                	li	a5,-1
ffffffffc020185a:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc020185c:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020185e:	83b1                	srli	a5,a5,0xc
ffffffffc0201860:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201862:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201864:	00e7ff63          	bleu	a4,a5,ffffffffc0201882 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201868:	00015797          	auipc	a5,0x15
ffffffffc020186c:	c9078793          	addi	a5,a5,-880 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201870:	6388                	ld	a0,0(a5)
}
ffffffffc0201872:	60a2                	ld	ra,8(sp)
ffffffffc0201874:	9536                	add	a0,a0,a3
ffffffffc0201876:	0141                	addi	sp,sp,16
ffffffffc0201878:	8082                	ret
ffffffffc020187a:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc020187c:	4501                	li	a0,0
}
ffffffffc020187e:	0141                	addi	sp,sp,16
ffffffffc0201880:	8082                	ret
ffffffffc0201882:	00004617          	auipc	a2,0x4
ffffffffc0201886:	47e60613          	addi	a2,a2,1150 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc020188a:	06900593          	li	a1,105
ffffffffc020188e:	00004517          	auipc	a0,0x4
ffffffffc0201892:	49a50513          	addi	a0,a0,1178 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0201896:	bbbfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020189a <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020189a:	7179                	addi	sp,sp,-48
ffffffffc020189c:	f406                	sd	ra,40(sp)
ffffffffc020189e:	f022                	sd	s0,32(sp)
ffffffffc02018a0:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02018a2:	01050713          	addi	a4,a0,16
ffffffffc02018a6:	6785                	lui	a5,0x1
ffffffffc02018a8:	0cf77b63          	bleu	a5,a4,ffffffffc020197e <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02018ac:	00f50413          	addi	s0,a0,15
ffffffffc02018b0:	8011                	srli	s0,s0,0x4
ffffffffc02018b2:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018b4:	10002673          	csrr	a2,sstatus
ffffffffc02018b8:	8a09                	andi	a2,a2,2
ffffffffc02018ba:	ea5d                	bnez	a2,ffffffffc0201970 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc02018bc:	00009497          	auipc	s1,0x9
ffffffffc02018c0:	79448493          	addi	s1,s1,1940 # ffffffffc020b050 <slobfree>
ffffffffc02018c4:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018c6:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018c8:	4398                	lw	a4,0(a5)
ffffffffc02018ca:	0a875763          	ble	s0,a4,ffffffffc0201978 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02018ce:	00f68a63          	beq	a3,a5,ffffffffc02018e2 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018d2:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018d4:	4118                	lw	a4,0(a0)
ffffffffc02018d6:	02875763          	ble	s0,a4,ffffffffc0201904 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02018da:	6094                	ld	a3,0(s1)
ffffffffc02018dc:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02018de:	fef69ae3          	bne	a3,a5,ffffffffc02018d2 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc02018e2:	ea39                	bnez	a2,ffffffffc0201938 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02018e4:	4501                	li	a0,0
ffffffffc02018e6:	f41ff0ef          	jal	ra,ffffffffc0201826 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018ea:	cd29                	beqz	a0,ffffffffc0201944 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02018ec:	6585                	lui	a1,0x1
ffffffffc02018ee:	e23ff0ef          	jal	ra,ffffffffc0201710 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018f2:	10002673          	csrr	a2,sstatus
ffffffffc02018f6:	8a09                	andi	a2,a2,2
ffffffffc02018f8:	ea1d                	bnez	a2,ffffffffc020192e <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc02018fa:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018fc:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018fe:	4118                	lw	a4,0(a0)
ffffffffc0201900:	fc874de3          	blt	a4,s0,ffffffffc02018da <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201904:	04e40663          	beq	s0,a4,ffffffffc0201950 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201908:	00441693          	slli	a3,s0,0x4
ffffffffc020190c:	96aa                	add	a3,a3,a0
ffffffffc020190e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201910:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201912:	9f01                	subw	a4,a4,s0
ffffffffc0201914:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201916:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201918:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc020191a:	00009717          	auipc	a4,0x9
ffffffffc020191e:	72f73b23          	sd	a5,1846(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc0201922:	ee15                	bnez	a2,ffffffffc020195e <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201924:	70a2                	ld	ra,40(sp)
ffffffffc0201926:	7402                	ld	s0,32(sp)
ffffffffc0201928:	64e2                	ld	s1,24(sp)
ffffffffc020192a:	6145                	addi	sp,sp,48
ffffffffc020192c:	8082                	ret
        intr_disable();
ffffffffc020192e:	cabfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201932:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201934:	609c                	ld	a5,0(s1)
ffffffffc0201936:	b7d9                	j	ffffffffc02018fc <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201938:	c9bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020193c:	4501                	li	a0,0
ffffffffc020193e:	ee9ff0ef          	jal	ra,ffffffffc0201826 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201942:	f54d                	bnez	a0,ffffffffc02018ec <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201944:	70a2                	ld	ra,40(sp)
ffffffffc0201946:	7402                	ld	s0,32(sp)
ffffffffc0201948:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc020194a:	4501                	li	a0,0
}
ffffffffc020194c:	6145                	addi	sp,sp,48
ffffffffc020194e:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201950:	6518                	ld	a4,8(a0)
ffffffffc0201952:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201954:	00009717          	auipc	a4,0x9
ffffffffc0201958:	6ef73e23          	sd	a5,1788(a4) # ffffffffc020b050 <slobfree>
    if (flag) {
ffffffffc020195c:	d661                	beqz	a2,ffffffffc0201924 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc020195e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201960:	c73fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc0201964:	70a2                	ld	ra,40(sp)
ffffffffc0201966:	7402                	ld	s0,32(sp)
ffffffffc0201968:	6522                	ld	a0,8(sp)
ffffffffc020196a:	64e2                	ld	s1,24(sp)
ffffffffc020196c:	6145                	addi	sp,sp,48
ffffffffc020196e:	8082                	ret
        intr_disable();
ffffffffc0201970:	c69fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201974:	4605                	li	a2,1
ffffffffc0201976:	b799                	j	ffffffffc02018bc <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201978:	853e                	mv	a0,a5
ffffffffc020197a:	87b6                	mv	a5,a3
ffffffffc020197c:	b761                	j	ffffffffc0201904 <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020197e:	00004697          	auipc	a3,0x4
ffffffffc0201982:	42268693          	addi	a3,a3,1058 # ffffffffc0205da0 <default_pmm_manager+0xf0>
ffffffffc0201986:	00004617          	auipc	a2,0x4
ffffffffc020198a:	f9260613          	addi	a2,a2,-110 # ffffffffc0205918 <commands+0x870>
ffffffffc020198e:	06300593          	li	a1,99
ffffffffc0201992:	00004517          	auipc	a0,0x4
ffffffffc0201996:	42e50513          	addi	a0,a0,1070 # ffffffffc0205dc0 <default_pmm_manager+0x110>
ffffffffc020199a:	ab7fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020199e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc020199e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02019a0:	00004517          	auipc	a0,0x4
ffffffffc02019a4:	43850513          	addi	a0,a0,1080 # ffffffffc0205dd8 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc02019a8:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02019aa:	fe4fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02019ae:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019b0:	00004517          	auipc	a0,0x4
ffffffffc02019b4:	3d050513          	addi	a0,a0,976 # ffffffffc0205d80 <default_pmm_manager+0xd0>
}
ffffffffc02019b8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019ba:	fd4fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc02019be <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02019be:	1101                	addi	sp,sp,-32
ffffffffc02019c0:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019c2:	6905                	lui	s2,0x1
{
ffffffffc02019c4:	e822                	sd	s0,16(sp)
ffffffffc02019c6:	ec06                	sd	ra,24(sp)
ffffffffc02019c8:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019ca:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc02019ce:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019d0:	04a7fc63          	bleu	a0,a5,ffffffffc0201a28 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02019d4:	4561                	li	a0,24
ffffffffc02019d6:	ec5ff0ef          	jal	ra,ffffffffc020189a <slob_alloc.isra.1.constprop.3>
ffffffffc02019da:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02019dc:	cd21                	beqz	a0,ffffffffc0201a34 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02019de:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02019e2:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019e4:	00f95763          	ble	a5,s2,ffffffffc02019f2 <kmalloc+0x34>
ffffffffc02019e8:	6705                	lui	a4,0x1
ffffffffc02019ea:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02019ec:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019ee:	fef74ee3          	blt	a4,a5,ffffffffc02019ea <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02019f2:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02019f4:	e33ff0ef          	jal	ra,ffffffffc0201826 <__slob_get_free_pages.isra.0>
ffffffffc02019f8:	e488                	sd	a0,8(s1)
ffffffffc02019fa:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02019fc:	c935                	beqz	a0,ffffffffc0201a70 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019fe:	100027f3          	csrr	a5,sstatus
ffffffffc0201a02:	8b89                	andi	a5,a5,2
ffffffffc0201a04:	e3a1                	bnez	a5,ffffffffc0201a44 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201a06:	00015797          	auipc	a5,0x15
ffffffffc0201a0a:	a8278793          	addi	a5,a5,-1406 # ffffffffc0216488 <bigblocks>
ffffffffc0201a0e:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a10:	00015717          	auipc	a4,0x15
ffffffffc0201a14:	a6973c23          	sd	s1,-1416(a4) # ffffffffc0216488 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a18:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a1a:	8522                	mv	a0,s0
ffffffffc0201a1c:	60e2                	ld	ra,24(sp)
ffffffffc0201a1e:	6442                	ld	s0,16(sp)
ffffffffc0201a20:	64a2                	ld	s1,8(sp)
ffffffffc0201a22:	6902                	ld	s2,0(sp)
ffffffffc0201a24:	6105                	addi	sp,sp,32
ffffffffc0201a26:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a28:	0541                	addi	a0,a0,16
ffffffffc0201a2a:	e71ff0ef          	jal	ra,ffffffffc020189a <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a2e:	01050413          	addi	s0,a0,16
ffffffffc0201a32:	f565                	bnez	a0,ffffffffc0201a1a <kmalloc+0x5c>
ffffffffc0201a34:	4401                	li	s0,0
}
ffffffffc0201a36:	8522                	mv	a0,s0
ffffffffc0201a38:	60e2                	ld	ra,24(sp)
ffffffffc0201a3a:	6442                	ld	s0,16(sp)
ffffffffc0201a3c:	64a2                	ld	s1,8(sp)
ffffffffc0201a3e:	6902                	ld	s2,0(sp)
ffffffffc0201a40:	6105                	addi	sp,sp,32
ffffffffc0201a42:	8082                	ret
        intr_disable();
ffffffffc0201a44:	b95fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a48:	00015797          	auipc	a5,0x15
ffffffffc0201a4c:	a4078793          	addi	a5,a5,-1472 # ffffffffc0216488 <bigblocks>
ffffffffc0201a50:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a52:	00015717          	auipc	a4,0x15
ffffffffc0201a56:	a2973b23          	sd	s1,-1482(a4) # ffffffffc0216488 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a5a:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201a5c:	b77fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201a60:	6480                	ld	s0,8(s1)
}
ffffffffc0201a62:	60e2                	ld	ra,24(sp)
ffffffffc0201a64:	64a2                	ld	s1,8(sp)
ffffffffc0201a66:	8522                	mv	a0,s0
ffffffffc0201a68:	6442                	ld	s0,16(sp)
ffffffffc0201a6a:	6902                	ld	s2,0(sp)
ffffffffc0201a6c:	6105                	addi	sp,sp,32
ffffffffc0201a6e:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a70:	45e1                	li	a1,24
ffffffffc0201a72:	8526                	mv	a0,s1
ffffffffc0201a74:	c9dff0ef          	jal	ra,ffffffffc0201710 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201a78:	b74d                	j	ffffffffc0201a1a <kmalloc+0x5c>

ffffffffc0201a7a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a7a:	c175                	beqz	a0,ffffffffc0201b5e <kfree+0xe4>
{
ffffffffc0201a7c:	1101                	addi	sp,sp,-32
ffffffffc0201a7e:	e426                	sd	s1,8(sp)
ffffffffc0201a80:	ec06                	sd	ra,24(sp)
ffffffffc0201a82:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201a84:	03451793          	slli	a5,a0,0x34
ffffffffc0201a88:	84aa                	mv	s1,a0
ffffffffc0201a8a:	eb8d                	bnez	a5,ffffffffc0201abc <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a8c:	100027f3          	csrr	a5,sstatus
ffffffffc0201a90:	8b89                	andi	a5,a5,2
ffffffffc0201a92:	efc9                	bnez	a5,ffffffffc0201b2c <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a94:	00015797          	auipc	a5,0x15
ffffffffc0201a98:	9f478793          	addi	a5,a5,-1548 # ffffffffc0216488 <bigblocks>
ffffffffc0201a9c:	6394                	ld	a3,0(a5)
ffffffffc0201a9e:	ce99                	beqz	a3,ffffffffc0201abc <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201aa0:	669c                	ld	a5,8(a3)
ffffffffc0201aa2:	6a80                	ld	s0,16(a3)
ffffffffc0201aa4:	0af50e63          	beq	a0,a5,ffffffffc0201b60 <kfree+0xe6>
    return 0;
ffffffffc0201aa8:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201aaa:	c801                	beqz	s0,ffffffffc0201aba <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201aac:	6418                	ld	a4,8(s0)
ffffffffc0201aae:	681c                	ld	a5,16(s0)
ffffffffc0201ab0:	00970f63          	beq	a4,s1,ffffffffc0201ace <kfree+0x54>
ffffffffc0201ab4:	86a2                	mv	a3,s0
ffffffffc0201ab6:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ab8:	f875                	bnez	s0,ffffffffc0201aac <kfree+0x32>
    if (flag) {
ffffffffc0201aba:	e659                	bnez	a2,ffffffffc0201b48 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201abc:	6442                	ld	s0,16(sp)
ffffffffc0201abe:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ac0:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201ac4:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ac6:	4581                	li	a1,0
}
ffffffffc0201ac8:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201aca:	c47ff06f          	j	ffffffffc0201710 <slob_free>
				*last = bb->next;
ffffffffc0201ace:	ea9c                	sd	a5,16(a3)
ffffffffc0201ad0:	e641                	bnez	a2,ffffffffc0201b58 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201ad2:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201ad6:	4018                	lw	a4,0(s0)
ffffffffc0201ad8:	08f4ea63          	bltu	s1,a5,ffffffffc0201b6c <kfree+0xf2>
ffffffffc0201adc:	00015797          	auipc	a5,0x15
ffffffffc0201ae0:	a1c78793          	addi	a5,a5,-1508 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201ae4:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201ae6:	00015797          	auipc	a5,0x15
ffffffffc0201aea:	9b278793          	addi	a5,a5,-1614 # ffffffffc0216498 <npage>
ffffffffc0201aee:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201af0:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201af2:	80b1                	srli	s1,s1,0xc
ffffffffc0201af4:	08f4f963          	bleu	a5,s1,ffffffffc0201b86 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201af8:	00005797          	auipc	a5,0x5
ffffffffc0201afc:	56078793          	addi	a5,a5,1376 # ffffffffc0207058 <nbase>
ffffffffc0201b00:	639c                	ld	a5,0(a5)
ffffffffc0201b02:	00015697          	auipc	a3,0x15
ffffffffc0201b06:	a0668693          	addi	a3,a3,-1530 # ffffffffc0216508 <pages>
ffffffffc0201b0a:	6288                	ld	a0,0(a3)
ffffffffc0201b0c:	8c9d                	sub	s1,s1,a5
ffffffffc0201b0e:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b10:	4585                	li	a1,1
ffffffffc0201b12:	9526                	add	a0,a0,s1
ffffffffc0201b14:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b18:	12a000ef          	jal	ra,ffffffffc0201c42 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b1c:	8522                	mv	a0,s0
}
ffffffffc0201b1e:	6442                	ld	s0,16(sp)
ffffffffc0201b20:	60e2                	ld	ra,24(sp)
ffffffffc0201b22:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b24:	45e1                	li	a1,24
}
ffffffffc0201b26:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b28:	be9ff06f          	j	ffffffffc0201710 <slob_free>
        intr_disable();
ffffffffc0201b2c:	aadfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b30:	00015797          	auipc	a5,0x15
ffffffffc0201b34:	95878793          	addi	a5,a5,-1704 # ffffffffc0216488 <bigblocks>
ffffffffc0201b38:	6394                	ld	a3,0(a5)
ffffffffc0201b3a:	c699                	beqz	a3,ffffffffc0201b48 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201b3c:	669c                	ld	a5,8(a3)
ffffffffc0201b3e:	6a80                	ld	s0,16(a3)
ffffffffc0201b40:	00f48763          	beq	s1,a5,ffffffffc0201b4e <kfree+0xd4>
        return 1;
ffffffffc0201b44:	4605                	li	a2,1
ffffffffc0201b46:	b795                	j	ffffffffc0201aaa <kfree+0x30>
        intr_enable();
ffffffffc0201b48:	a8bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b4c:	bf85                	j	ffffffffc0201abc <kfree+0x42>
				*last = bb->next;
ffffffffc0201b4e:	00015797          	auipc	a5,0x15
ffffffffc0201b52:	9287bd23          	sd	s0,-1734(a5) # ffffffffc0216488 <bigblocks>
ffffffffc0201b56:	8436                	mv	s0,a3
ffffffffc0201b58:	a7bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b5c:	bf9d                	j	ffffffffc0201ad2 <kfree+0x58>
ffffffffc0201b5e:	8082                	ret
ffffffffc0201b60:	00015797          	auipc	a5,0x15
ffffffffc0201b64:	9287b423          	sd	s0,-1752(a5) # ffffffffc0216488 <bigblocks>
ffffffffc0201b68:	8436                	mv	s0,a3
ffffffffc0201b6a:	b7a5                	j	ffffffffc0201ad2 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201b6c:	86a6                	mv	a3,s1
ffffffffc0201b6e:	00004617          	auipc	a2,0x4
ffffffffc0201b72:	1ca60613          	addi	a2,a2,458 # ffffffffc0205d38 <default_pmm_manager+0x88>
ffffffffc0201b76:	06e00593          	li	a1,110
ffffffffc0201b7a:	00004517          	auipc	a0,0x4
ffffffffc0201b7e:	1ae50513          	addi	a0,a0,430 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0201b82:	8cffe0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201b86:	00004617          	auipc	a2,0x4
ffffffffc0201b8a:	1da60613          	addi	a2,a2,474 # ffffffffc0205d60 <default_pmm_manager+0xb0>
ffffffffc0201b8e:	06200593          	li	a1,98
ffffffffc0201b92:	00004517          	auipc	a0,0x4
ffffffffc0201b96:	19650513          	addi	a0,a0,406 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0201b9a:	8b7fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b9e <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201b9e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201ba0:	00004617          	auipc	a2,0x4
ffffffffc0201ba4:	1c060613          	addi	a2,a2,448 # ffffffffc0205d60 <default_pmm_manager+0xb0>
ffffffffc0201ba8:	06200593          	li	a1,98
ffffffffc0201bac:	00004517          	auipc	a0,0x4
ffffffffc0201bb0:	17c50513          	addi	a0,a0,380 # ffffffffc0205d28 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201bb4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201bb6:	89bfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201bba <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201bba:	715d                	addi	sp,sp,-80
ffffffffc0201bbc:	e0a2                	sd	s0,64(sp)
ffffffffc0201bbe:	fc26                	sd	s1,56(sp)
ffffffffc0201bc0:	f84a                	sd	s2,48(sp)
ffffffffc0201bc2:	f44e                	sd	s3,40(sp)
ffffffffc0201bc4:	f052                	sd	s4,32(sp)
ffffffffc0201bc6:	ec56                	sd	s5,24(sp)
ffffffffc0201bc8:	e486                	sd	ra,72(sp)
ffffffffc0201bca:	842a                	mv	s0,a0
ffffffffc0201bcc:	00015497          	auipc	s1,0x15
ffffffffc0201bd0:	92448493          	addi	s1,s1,-1756 # ffffffffc02164f0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bd4:	4985                	li	s3,1
ffffffffc0201bd6:	00015a17          	auipc	s4,0x15
ffffffffc0201bda:	8d2a0a13          	addi	s4,s4,-1838 # ffffffffc02164a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bde:	0005091b          	sext.w	s2,a0
ffffffffc0201be2:	00015a97          	auipc	s5,0x15
ffffffffc0201be6:	a06a8a93          	addi	s5,s5,-1530 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0201bea:	a00d                	j	ffffffffc0201c0c <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bec:	609c                	ld	a5,0(s1)
ffffffffc0201bee:	6f9c                	ld	a5,24(a5)
ffffffffc0201bf0:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bf2:	4601                	li	a2,0
ffffffffc0201bf4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bf6:	ed0d                	bnez	a0,ffffffffc0201c30 <alloc_pages+0x76>
ffffffffc0201bf8:	0289ec63          	bltu	s3,s0,ffffffffc0201c30 <alloc_pages+0x76>
ffffffffc0201bfc:	000a2783          	lw	a5,0(s4)
ffffffffc0201c00:	2781                	sext.w	a5,a5
ffffffffc0201c02:	c79d                	beqz	a5,ffffffffc0201c30 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c04:	000ab503          	ld	a0,0(s5)
ffffffffc0201c08:	6dc010ef          	jal	ra,ffffffffc02032e4 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c0c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c10:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c12:	8522                	mv	a0,s0
ffffffffc0201c14:	dfe1                	beqz	a5,ffffffffc0201bec <alloc_pages+0x32>
        intr_disable();
ffffffffc0201c16:	9c3fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201c1a:	609c                	ld	a5,0(s1)
ffffffffc0201c1c:	8522                	mv	a0,s0
ffffffffc0201c1e:	6f9c                	ld	a5,24(a5)
ffffffffc0201c20:	9782                	jalr	a5
ffffffffc0201c22:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c24:	9affe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201c28:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c2a:	4601                	li	a2,0
ffffffffc0201c2c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c2e:	d569                	beqz	a0,ffffffffc0201bf8 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201c30:	60a6                	ld	ra,72(sp)
ffffffffc0201c32:	6406                	ld	s0,64(sp)
ffffffffc0201c34:	74e2                	ld	s1,56(sp)
ffffffffc0201c36:	7942                	ld	s2,48(sp)
ffffffffc0201c38:	79a2                	ld	s3,40(sp)
ffffffffc0201c3a:	7a02                	ld	s4,32(sp)
ffffffffc0201c3c:	6ae2                	ld	s5,24(sp)
ffffffffc0201c3e:	6161                	addi	sp,sp,80
ffffffffc0201c40:	8082                	ret

ffffffffc0201c42 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c42:	100027f3          	csrr	a5,sstatus
ffffffffc0201c46:	8b89                	andi	a5,a5,2
ffffffffc0201c48:	eb89                	bnez	a5,ffffffffc0201c5a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c4a:	00015797          	auipc	a5,0x15
ffffffffc0201c4e:	8a678793          	addi	a5,a5,-1882 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201c52:	639c                	ld	a5,0(a5)
ffffffffc0201c54:	0207b303          	ld	t1,32(a5)
ffffffffc0201c58:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c5a:	1101                	addi	sp,sp,-32
ffffffffc0201c5c:	ec06                	sd	ra,24(sp)
ffffffffc0201c5e:	e822                	sd	s0,16(sp)
ffffffffc0201c60:	e426                	sd	s1,8(sp)
ffffffffc0201c62:	842a                	mv	s0,a0
ffffffffc0201c64:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c66:	973fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c6a:	00015797          	auipc	a5,0x15
ffffffffc0201c6e:	88678793          	addi	a5,a5,-1914 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201c72:	639c                	ld	a5,0(a5)
ffffffffc0201c74:	85a6                	mv	a1,s1
ffffffffc0201c76:	8522                	mv	a0,s0
ffffffffc0201c78:	739c                	ld	a5,32(a5)
ffffffffc0201c7a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c7c:	6442                	ld	s0,16(sp)
ffffffffc0201c7e:	60e2                	ld	ra,24(sp)
ffffffffc0201c80:	64a2                	ld	s1,8(sp)
ffffffffc0201c82:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c84:	94ffe06f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc0201c88 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c88:	100027f3          	csrr	a5,sstatus
ffffffffc0201c8c:	8b89                	andi	a5,a5,2
ffffffffc0201c8e:	eb89                	bnez	a5,ffffffffc0201ca0 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c90:	00015797          	auipc	a5,0x15
ffffffffc0201c94:	86078793          	addi	a5,a5,-1952 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201c98:	639c                	ld	a5,0(a5)
ffffffffc0201c9a:	0287b303          	ld	t1,40(a5)
ffffffffc0201c9e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201ca0:	1141                	addi	sp,sp,-16
ffffffffc0201ca2:	e406                	sd	ra,8(sp)
ffffffffc0201ca4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201ca6:	933fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201caa:	00015797          	auipc	a5,0x15
ffffffffc0201cae:	84678793          	addi	a5,a5,-1978 # ffffffffc02164f0 <pmm_manager>
ffffffffc0201cb2:	639c                	ld	a5,0(a5)
ffffffffc0201cb4:	779c                	ld	a5,40(a5)
ffffffffc0201cb6:	9782                	jalr	a5
ffffffffc0201cb8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cba:	919fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201cbe:	8522                	mv	a0,s0
ffffffffc0201cc0:	60a2                	ld	ra,8(sp)
ffffffffc0201cc2:	6402                	ld	s0,0(sp)
ffffffffc0201cc4:	0141                	addi	sp,sp,16
ffffffffc0201cc6:	8082                	ret

ffffffffc0201cc8 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cc8:	7139                	addi	sp,sp,-64
ffffffffc0201cca:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ccc:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201cd0:	1ff4f493          	andi	s1,s1,511
ffffffffc0201cd4:	048e                	slli	s1,s1,0x3
ffffffffc0201cd6:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cd8:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cda:	f04a                	sd	s2,32(sp)
ffffffffc0201cdc:	ec4e                	sd	s3,24(sp)
ffffffffc0201cde:	e852                	sd	s4,16(sp)
ffffffffc0201ce0:	fc06                	sd	ra,56(sp)
ffffffffc0201ce2:	f822                	sd	s0,48(sp)
ffffffffc0201ce4:	e456                	sd	s5,8(sp)
ffffffffc0201ce6:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201ce8:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cec:	892e                	mv	s2,a1
ffffffffc0201cee:	8a32                	mv	s4,a2
ffffffffc0201cf0:	00014997          	auipc	s3,0x14
ffffffffc0201cf4:	7a898993          	addi	s3,s3,1960 # ffffffffc0216498 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cf8:	e7bd                	bnez	a5,ffffffffc0201d66 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201cfa:	12060c63          	beqz	a2,ffffffffc0201e32 <get_pte+0x16a>
ffffffffc0201cfe:	4505                	li	a0,1
ffffffffc0201d00:	ebbff0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0201d04:	842a                	mv	s0,a0
ffffffffc0201d06:	12050663          	beqz	a0,ffffffffc0201e32 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d0a:	00014b17          	auipc	s6,0x14
ffffffffc0201d0e:	7feb0b13          	addi	s6,s6,2046 # ffffffffc0216508 <pages>
ffffffffc0201d12:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201d16:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d18:	00014997          	auipc	s3,0x14
ffffffffc0201d1c:	78098993          	addi	s3,s3,1920 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0201d20:	40a40533          	sub	a0,s0,a0
ffffffffc0201d24:	00080ab7          	lui	s5,0x80
ffffffffc0201d28:	8519                	srai	a0,a0,0x6
ffffffffc0201d2a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201d2e:	c01c                	sw	a5,0(s0)
ffffffffc0201d30:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201d32:	9556                	add	a0,a0,s5
ffffffffc0201d34:	83b1                	srli	a5,a5,0xc
ffffffffc0201d36:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d38:	0532                	slli	a0,a0,0xc
ffffffffc0201d3a:	14e7f363          	bleu	a4,a5,ffffffffc0201e80 <get_pte+0x1b8>
ffffffffc0201d3e:	00014797          	auipc	a5,0x14
ffffffffc0201d42:	7ba78793          	addi	a5,a5,1978 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201d46:	639c                	ld	a5,0(a5)
ffffffffc0201d48:	6605                	lui	a2,0x1
ffffffffc0201d4a:	4581                	li	a1,0
ffffffffc0201d4c:	953e                	add	a0,a0,a5
ffffffffc0201d4e:	1cc030ef          	jal	ra,ffffffffc0204f1a <memset>
    return page - pages + nbase;
ffffffffc0201d52:	000b3683          	ld	a3,0(s6)
ffffffffc0201d56:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d5a:	8699                	srai	a3,a3,0x6
ffffffffc0201d5c:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d5e:	06aa                	slli	a3,a3,0xa
ffffffffc0201d60:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d64:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d66:	77fd                	lui	a5,0xfffff
ffffffffc0201d68:	068a                	slli	a3,a3,0x2
ffffffffc0201d6a:	0009b703          	ld	a4,0(s3)
ffffffffc0201d6e:	8efd                	and	a3,a3,a5
ffffffffc0201d70:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d74:	0ce7f163          	bleu	a4,a5,ffffffffc0201e36 <get_pte+0x16e>
ffffffffc0201d78:	00014a97          	auipc	s5,0x14
ffffffffc0201d7c:	780a8a93          	addi	s5,s5,1920 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0201d80:	000ab403          	ld	s0,0(s5)
ffffffffc0201d84:	01595793          	srli	a5,s2,0x15
ffffffffc0201d88:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d8c:	96a2                	add	a3,a3,s0
ffffffffc0201d8e:	00379413          	slli	s0,a5,0x3
ffffffffc0201d92:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d94:	6014                	ld	a3,0(s0)
ffffffffc0201d96:	0016f793          	andi	a5,a3,1
ffffffffc0201d9a:	e3ad                	bnez	a5,ffffffffc0201dfc <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d9c:	080a0b63          	beqz	s4,ffffffffc0201e32 <get_pte+0x16a>
ffffffffc0201da0:	4505                	li	a0,1
ffffffffc0201da2:	e19ff0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0201da6:	84aa                	mv	s1,a0
ffffffffc0201da8:	c549                	beqz	a0,ffffffffc0201e32 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201daa:	00014b17          	auipc	s6,0x14
ffffffffc0201dae:	75eb0b13          	addi	s6,s6,1886 # ffffffffc0216508 <pages>
ffffffffc0201db2:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201db6:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201db8:	00080a37          	lui	s4,0x80
ffffffffc0201dbc:	40a48533          	sub	a0,s1,a0
ffffffffc0201dc0:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201dc2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201dc6:	c09c                	sw	a5,0(s1)
ffffffffc0201dc8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201dca:	9552                	add	a0,a0,s4
ffffffffc0201dcc:	83b1                	srli	a5,a5,0xc
ffffffffc0201dce:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dd0:	0532                	slli	a0,a0,0xc
ffffffffc0201dd2:	08e7fa63          	bleu	a4,a5,ffffffffc0201e66 <get_pte+0x19e>
ffffffffc0201dd6:	000ab783          	ld	a5,0(s5)
ffffffffc0201dda:	6605                	lui	a2,0x1
ffffffffc0201ddc:	4581                	li	a1,0
ffffffffc0201dde:	953e                	add	a0,a0,a5
ffffffffc0201de0:	13a030ef          	jal	ra,ffffffffc0204f1a <memset>
    return page - pages + nbase;
ffffffffc0201de4:	000b3683          	ld	a3,0(s6)
ffffffffc0201de8:	40d486b3          	sub	a3,s1,a3
ffffffffc0201dec:	8699                	srai	a3,a3,0x6
ffffffffc0201dee:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201df0:	06aa                	slli	a3,a3,0xa
ffffffffc0201df2:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201df6:	e014                	sd	a3,0(s0)
ffffffffc0201df8:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201dfc:	068a                	slli	a3,a3,0x2
ffffffffc0201dfe:	757d                	lui	a0,0xfffff
ffffffffc0201e00:	8ee9                	and	a3,a3,a0
ffffffffc0201e02:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e06:	04e7f463          	bleu	a4,a5,ffffffffc0201e4e <get_pte+0x186>
ffffffffc0201e0a:	000ab503          	ld	a0,0(s5)
ffffffffc0201e0e:	00c95793          	srli	a5,s2,0xc
ffffffffc0201e12:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e16:	96aa                	add	a3,a3,a0
ffffffffc0201e18:	00379513          	slli	a0,a5,0x3
ffffffffc0201e1c:	9536                	add	a0,a0,a3
}
ffffffffc0201e1e:	70e2                	ld	ra,56(sp)
ffffffffc0201e20:	7442                	ld	s0,48(sp)
ffffffffc0201e22:	74a2                	ld	s1,40(sp)
ffffffffc0201e24:	7902                	ld	s2,32(sp)
ffffffffc0201e26:	69e2                	ld	s3,24(sp)
ffffffffc0201e28:	6a42                	ld	s4,16(sp)
ffffffffc0201e2a:	6aa2                	ld	s5,8(sp)
ffffffffc0201e2c:	6b02                	ld	s6,0(sp)
ffffffffc0201e2e:	6121                	addi	sp,sp,64
ffffffffc0201e30:	8082                	ret
            return NULL;
ffffffffc0201e32:	4501                	li	a0,0
ffffffffc0201e34:	b7ed                	j	ffffffffc0201e1e <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e36:	00004617          	auipc	a2,0x4
ffffffffc0201e3a:	eca60613          	addi	a2,a2,-310 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0201e3e:	0e400593          	li	a1,228
ffffffffc0201e42:	00004517          	auipc	a0,0x4
ffffffffc0201e46:	fae50513          	addi	a0,a0,-82 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0201e4a:	e06fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e4e:	00004617          	auipc	a2,0x4
ffffffffc0201e52:	eb260613          	addi	a2,a2,-334 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0201e56:	0ef00593          	li	a1,239
ffffffffc0201e5a:	00004517          	auipc	a0,0x4
ffffffffc0201e5e:	f9650513          	addi	a0,a0,-106 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0201e62:	deefe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e66:	86aa                	mv	a3,a0
ffffffffc0201e68:	00004617          	auipc	a2,0x4
ffffffffc0201e6c:	e9860613          	addi	a2,a2,-360 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0201e70:	0ec00593          	li	a1,236
ffffffffc0201e74:	00004517          	auipc	a0,0x4
ffffffffc0201e78:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0201e7c:	dd4fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e80:	86aa                	mv	a3,a0
ffffffffc0201e82:	00004617          	auipc	a2,0x4
ffffffffc0201e86:	e7e60613          	addi	a2,a2,-386 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0201e8a:	0e100593          	li	a1,225
ffffffffc0201e8e:	00004517          	auipc	a0,0x4
ffffffffc0201e92:	f6250513          	addi	a0,a0,-158 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0201e96:	dbafe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201e9a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e9a:	1141                	addi	sp,sp,-16
ffffffffc0201e9c:	e022                	sd	s0,0(sp)
ffffffffc0201e9e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ea0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201ea2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ea4:	e25ff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201ea8:	c011                	beqz	s0,ffffffffc0201eac <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201eaa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201eac:	c129                	beqz	a0,ffffffffc0201eee <get_page+0x54>
ffffffffc0201eae:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201eb0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201eb2:	0017f713          	andi	a4,a5,1
ffffffffc0201eb6:	e709                	bnez	a4,ffffffffc0201ec0 <get_page+0x26>
}
ffffffffc0201eb8:	60a2                	ld	ra,8(sp)
ffffffffc0201eba:	6402                	ld	s0,0(sp)
ffffffffc0201ebc:	0141                	addi	sp,sp,16
ffffffffc0201ebe:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ec0:	00014717          	auipc	a4,0x14
ffffffffc0201ec4:	5d870713          	addi	a4,a4,1496 # ffffffffc0216498 <npage>
ffffffffc0201ec8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201eca:	078a                	slli	a5,a5,0x2
ffffffffc0201ecc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ece:	02e7f563          	bleu	a4,a5,ffffffffc0201ef8 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ed2:	00014717          	auipc	a4,0x14
ffffffffc0201ed6:	63670713          	addi	a4,a4,1590 # ffffffffc0216508 <pages>
ffffffffc0201eda:	6308                	ld	a0,0(a4)
ffffffffc0201edc:	60a2                	ld	ra,8(sp)
ffffffffc0201ede:	6402                	ld	s0,0(sp)
ffffffffc0201ee0:	fff80737          	lui	a4,0xfff80
ffffffffc0201ee4:	97ba                	add	a5,a5,a4
ffffffffc0201ee6:	079a                	slli	a5,a5,0x6
ffffffffc0201ee8:	953e                	add	a0,a0,a5
ffffffffc0201eea:	0141                	addi	sp,sp,16
ffffffffc0201eec:	8082                	ret
ffffffffc0201eee:	60a2                	ld	ra,8(sp)
ffffffffc0201ef0:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201ef2:	4501                	li	a0,0
}
ffffffffc0201ef4:	0141                	addi	sp,sp,16
ffffffffc0201ef6:	8082                	ret
ffffffffc0201ef8:	ca7ff0ef          	jal	ra,ffffffffc0201b9e <pa2page.part.4>

ffffffffc0201efc <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201efc:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201efe:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f00:	e426                	sd	s1,8(sp)
ffffffffc0201f02:	ec06                	sd	ra,24(sp)
ffffffffc0201f04:	e822                	sd	s0,16(sp)
ffffffffc0201f06:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f08:	dc1ff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
    if (ptep != NULL) {
ffffffffc0201f0c:	c511                	beqz	a0,ffffffffc0201f18 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201f0e:	611c                	ld	a5,0(a0)
ffffffffc0201f10:	842a                	mv	s0,a0
ffffffffc0201f12:	0017f713          	andi	a4,a5,1
ffffffffc0201f16:	e711                	bnez	a4,ffffffffc0201f22 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201f18:	60e2                	ld	ra,24(sp)
ffffffffc0201f1a:	6442                	ld	s0,16(sp)
ffffffffc0201f1c:	64a2                	ld	s1,8(sp)
ffffffffc0201f1e:	6105                	addi	sp,sp,32
ffffffffc0201f20:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f22:	00014717          	auipc	a4,0x14
ffffffffc0201f26:	57670713          	addi	a4,a4,1398 # ffffffffc0216498 <npage>
ffffffffc0201f2a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f2c:	078a                	slli	a5,a5,0x2
ffffffffc0201f2e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f30:	02e7fe63          	bleu	a4,a5,ffffffffc0201f6c <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f34:	00014717          	auipc	a4,0x14
ffffffffc0201f38:	5d470713          	addi	a4,a4,1492 # ffffffffc0216508 <pages>
ffffffffc0201f3c:	6308                	ld	a0,0(a4)
ffffffffc0201f3e:	fff80737          	lui	a4,0xfff80
ffffffffc0201f42:	97ba                	add	a5,a5,a4
ffffffffc0201f44:	079a                	slli	a5,a5,0x6
ffffffffc0201f46:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f48:	411c                	lw	a5,0(a0)
ffffffffc0201f4a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f4e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201f50:	cb11                	beqz	a4,ffffffffc0201f64 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201f52:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f56:	12048073          	sfence.vma	s1
}
ffffffffc0201f5a:	60e2                	ld	ra,24(sp)
ffffffffc0201f5c:	6442                	ld	s0,16(sp)
ffffffffc0201f5e:	64a2                	ld	s1,8(sp)
ffffffffc0201f60:	6105                	addi	sp,sp,32
ffffffffc0201f62:	8082                	ret
            free_page(page);
ffffffffc0201f64:	4585                	li	a1,1
ffffffffc0201f66:	cddff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
ffffffffc0201f6a:	b7e5                	j	ffffffffc0201f52 <page_remove+0x56>
ffffffffc0201f6c:	c33ff0ef          	jal	ra,ffffffffc0201b9e <pa2page.part.4>

ffffffffc0201f70 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f70:	7179                	addi	sp,sp,-48
ffffffffc0201f72:	e44e                	sd	s3,8(sp)
ffffffffc0201f74:	89b2                	mv	s3,a2
ffffffffc0201f76:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f78:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f7a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f7c:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f7e:	ec26                	sd	s1,24(sp)
ffffffffc0201f80:	f406                	sd	ra,40(sp)
ffffffffc0201f82:	e84a                	sd	s2,16(sp)
ffffffffc0201f84:	e052                	sd	s4,0(sp)
ffffffffc0201f86:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f88:	d41ff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
    if (ptep == NULL) {
ffffffffc0201f8c:	cd49                	beqz	a0,ffffffffc0202026 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201f8e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201f90:	611c                	ld	a5,0(a0)
ffffffffc0201f92:	892a                	mv	s2,a0
ffffffffc0201f94:	0016871b          	addiw	a4,a3,1
ffffffffc0201f98:	c018                	sw	a4,0(s0)
ffffffffc0201f9a:	0017f713          	andi	a4,a5,1
ffffffffc0201f9e:	ef05                	bnez	a4,ffffffffc0201fd6 <page_insert+0x66>
ffffffffc0201fa0:	00014797          	auipc	a5,0x14
ffffffffc0201fa4:	56878793          	addi	a5,a5,1384 # ffffffffc0216508 <pages>
ffffffffc0201fa8:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201faa:	8c19                	sub	s0,s0,a4
ffffffffc0201fac:	000806b7          	lui	a3,0x80
ffffffffc0201fb0:	8419                	srai	s0,s0,0x6
ffffffffc0201fb2:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fb4:	042a                	slli	s0,s0,0xa
ffffffffc0201fb6:	8c45                	or	s0,s0,s1
ffffffffc0201fb8:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201fbc:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fc0:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201fc4:	4501                	li	a0,0
}
ffffffffc0201fc6:	70a2                	ld	ra,40(sp)
ffffffffc0201fc8:	7402                	ld	s0,32(sp)
ffffffffc0201fca:	64e2                	ld	s1,24(sp)
ffffffffc0201fcc:	6942                	ld	s2,16(sp)
ffffffffc0201fce:	69a2                	ld	s3,8(sp)
ffffffffc0201fd0:	6a02                	ld	s4,0(sp)
ffffffffc0201fd2:	6145                	addi	sp,sp,48
ffffffffc0201fd4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201fd6:	00014717          	auipc	a4,0x14
ffffffffc0201fda:	4c270713          	addi	a4,a4,1218 # ffffffffc0216498 <npage>
ffffffffc0201fde:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fe0:	078a                	slli	a5,a5,0x2
ffffffffc0201fe2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fe4:	04e7f363          	bleu	a4,a5,ffffffffc020202a <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fe8:	00014a17          	auipc	s4,0x14
ffffffffc0201fec:	520a0a13          	addi	s4,s4,1312 # ffffffffc0216508 <pages>
ffffffffc0201ff0:	000a3703          	ld	a4,0(s4)
ffffffffc0201ff4:	fff80537          	lui	a0,0xfff80
ffffffffc0201ff8:	953e                	add	a0,a0,a5
ffffffffc0201ffa:	051a                	slli	a0,a0,0x6
ffffffffc0201ffc:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201ffe:	00a40a63          	beq	s0,a0,ffffffffc0202012 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202002:	411c                	lw	a5,0(a0)
ffffffffc0202004:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202008:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc020200a:	c691                	beqz	a3,ffffffffc0202016 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020200c:	12098073          	sfence.vma	s3
ffffffffc0202010:	bf69                	j	ffffffffc0201faa <page_insert+0x3a>
ffffffffc0202012:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202014:	bf59                	j	ffffffffc0201faa <page_insert+0x3a>
            free_page(page);
ffffffffc0202016:	4585                	li	a1,1
ffffffffc0202018:	c2bff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
ffffffffc020201c:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202020:	12098073          	sfence.vma	s3
ffffffffc0202024:	b759                	j	ffffffffc0201faa <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202026:	5571                	li	a0,-4
ffffffffc0202028:	bf79                	j	ffffffffc0201fc6 <page_insert+0x56>
ffffffffc020202a:	b75ff0ef          	jal	ra,ffffffffc0201b9e <pa2page.part.4>

ffffffffc020202e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020202e:	00004797          	auipc	a5,0x4
ffffffffc0202032:	c8278793          	addi	a5,a5,-894 # ffffffffc0205cb0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202036:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202038:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020203a:	00004517          	auipc	a0,0x4
ffffffffc020203e:	dde50513          	addi	a0,a0,-546 # ffffffffc0205e18 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc0202042:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202044:	00014717          	auipc	a4,0x14
ffffffffc0202048:	4af73623          	sd	a5,1196(a4) # ffffffffc02164f0 <pmm_manager>
void pmm_init(void) {
ffffffffc020204c:	e0a2                	sd	s0,64(sp)
ffffffffc020204e:	fc26                	sd	s1,56(sp)
ffffffffc0202050:	f84a                	sd	s2,48(sp)
ffffffffc0202052:	f44e                	sd	s3,40(sp)
ffffffffc0202054:	f052                	sd	s4,32(sp)
ffffffffc0202056:	ec56                	sd	s5,24(sp)
ffffffffc0202058:	e85a                	sd	s6,16(sp)
ffffffffc020205a:	e45e                	sd	s7,8(sp)
ffffffffc020205c:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020205e:	00014417          	auipc	s0,0x14
ffffffffc0202062:	49240413          	addi	s0,s0,1170 # ffffffffc02164f0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202066:	928fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc020206a:	601c                	ld	a5,0(s0)
ffffffffc020206c:	00014497          	auipc	s1,0x14
ffffffffc0202070:	42c48493          	addi	s1,s1,1068 # ffffffffc0216498 <npage>
ffffffffc0202074:	00014917          	auipc	s2,0x14
ffffffffc0202078:	49490913          	addi	s2,s2,1172 # ffffffffc0216508 <pages>
ffffffffc020207c:	679c                	ld	a5,8(a5)
ffffffffc020207e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202080:	57f5                	li	a5,-3
ffffffffc0202082:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202084:	00004517          	auipc	a0,0x4
ffffffffc0202088:	dac50513          	addi	a0,a0,-596 # ffffffffc0205e30 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020208c:	00014717          	auipc	a4,0x14
ffffffffc0202090:	46f73623          	sd	a5,1132(a4) # ffffffffc02164f8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202094:	8fafe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202098:	46c5                	li	a3,17
ffffffffc020209a:	06ee                	slli	a3,a3,0x1b
ffffffffc020209c:	40100613          	li	a2,1025
ffffffffc02020a0:	16fd                	addi	a3,a3,-1
ffffffffc02020a2:	0656                	slli	a2,a2,0x15
ffffffffc02020a4:	07e005b7          	lui	a1,0x7e00
ffffffffc02020a8:	00004517          	auipc	a0,0x4
ffffffffc02020ac:	da050513          	addi	a0,a0,-608 # ffffffffc0205e48 <default_pmm_manager+0x198>
ffffffffc02020b0:	8defe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02020b4:	777d                	lui	a4,0xfffff
ffffffffc02020b6:	00015797          	auipc	a5,0x15
ffffffffc02020ba:	54978793          	addi	a5,a5,1353 # ffffffffc02175ff <end+0xfff>
ffffffffc02020be:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02020c0:	00088737          	lui	a4,0x88
ffffffffc02020c4:	00014697          	auipc	a3,0x14
ffffffffc02020c8:	3ce6ba23          	sd	a4,980(a3) # ffffffffc0216498 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02020cc:	00014717          	auipc	a4,0x14
ffffffffc02020d0:	42f73e23          	sd	a5,1084(a4) # ffffffffc0216508 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020d4:	4701                	li	a4,0
ffffffffc02020d6:	4685                	li	a3,1
ffffffffc02020d8:	fff80837          	lui	a6,0xfff80
ffffffffc02020dc:	a019                	j	ffffffffc02020e2 <pmm_init+0xb4>
ffffffffc02020de:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02020e2:	00671613          	slli	a2,a4,0x6
ffffffffc02020e6:	97b2                	add	a5,a5,a2
ffffffffc02020e8:	07a1                	addi	a5,a5,8
ffffffffc02020ea:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020ee:	6090                	ld	a2,0(s1)
ffffffffc02020f0:	0705                	addi	a4,a4,1
ffffffffc02020f2:	010607b3          	add	a5,a2,a6
ffffffffc02020f6:	fef764e3          	bltu	a4,a5,ffffffffc02020de <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020fa:	00093503          	ld	a0,0(s2)
ffffffffc02020fe:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202102:	00661693          	slli	a3,a2,0x6
ffffffffc0202106:	97aa                	add	a5,a5,a0
ffffffffc0202108:	96be                	add	a3,a3,a5
ffffffffc020210a:	c02007b7          	lui	a5,0xc0200
ffffffffc020210e:	7af6ed63          	bltu	a3,a5,ffffffffc02028c8 <pmm_init+0x89a>
ffffffffc0202112:	00014997          	auipc	s3,0x14
ffffffffc0202116:	3e698993          	addi	s3,s3,998 # ffffffffc02164f8 <va_pa_offset>
ffffffffc020211a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020211e:	47c5                	li	a5,17
ffffffffc0202120:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202122:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202124:	02f6f763          	bleu	a5,a3,ffffffffc0202152 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202128:	6585                	lui	a1,0x1
ffffffffc020212a:	15fd                	addi	a1,a1,-1
ffffffffc020212c:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc020212e:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202132:	48c77a63          	bleu	a2,a4,ffffffffc02025c6 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202136:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202138:	75fd                	lui	a1,0xfffff
ffffffffc020213a:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020213c:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020213e:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202140:	40d786b3          	sub	a3,a5,a3
ffffffffc0202144:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202146:	00c6d593          	srli	a1,a3,0xc
ffffffffc020214a:	953a                	add	a0,a0,a4
ffffffffc020214c:	9602                	jalr	a2
ffffffffc020214e:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202152:	00004517          	auipc	a0,0x4
ffffffffc0202156:	d1e50513          	addi	a0,a0,-738 # ffffffffc0205e70 <default_pmm_manager+0x1c0>
ffffffffc020215a:	834fe0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020215e:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202160:	00014417          	auipc	s0,0x14
ffffffffc0202164:	33040413          	addi	s0,s0,816 # ffffffffc0216490 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202168:	7b9c                	ld	a5,48(a5)
ffffffffc020216a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020216c:	00004517          	auipc	a0,0x4
ffffffffc0202170:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205e88 <default_pmm_manager+0x1d8>
ffffffffc0202174:	81afe0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202178:	00008697          	auipc	a3,0x8
ffffffffc020217c:	e8868693          	addi	a3,a3,-376 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202180:	00014797          	auipc	a5,0x14
ffffffffc0202184:	30d7b823          	sd	a3,784(a5) # ffffffffc0216490 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202188:	c02007b7          	lui	a5,0xc0200
ffffffffc020218c:	10f6eae3          	bltu	a3,a5,ffffffffc0202aa0 <pmm_init+0xa72>
ffffffffc0202190:	0009b783          	ld	a5,0(s3)
ffffffffc0202194:	8e9d                	sub	a3,a3,a5
ffffffffc0202196:	00014797          	auipc	a5,0x14
ffffffffc020219a:	36d7b523          	sd	a3,874(a5) # ffffffffc0216500 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020219e:	aebff0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02021a2:	6098                	ld	a4,0(s1)
ffffffffc02021a4:	c80007b7          	lui	a5,0xc8000
ffffffffc02021a8:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02021aa:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02021ac:	0ce7eae3          	bltu	a5,a4,ffffffffc0202a80 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021b0:	6008                	ld	a0,0(s0)
ffffffffc02021b2:	44050463          	beqz	a0,ffffffffc02025fa <pmm_init+0x5cc>
ffffffffc02021b6:	6785                	lui	a5,0x1
ffffffffc02021b8:	17fd                	addi	a5,a5,-1
ffffffffc02021ba:	8fe9                	and	a5,a5,a0
ffffffffc02021bc:	2781                	sext.w	a5,a5
ffffffffc02021be:	42079e63          	bnez	a5,ffffffffc02025fa <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021c2:	4601                	li	a2,0
ffffffffc02021c4:	4581                	li	a1,0
ffffffffc02021c6:	cd5ff0ef          	jal	ra,ffffffffc0201e9a <get_page>
ffffffffc02021ca:	78051b63          	bnez	a0,ffffffffc0202960 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02021ce:	4505                	li	a0,1
ffffffffc02021d0:	9ebff0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc02021d4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021d6:	6008                	ld	a0,0(s0)
ffffffffc02021d8:	4681                	li	a3,0
ffffffffc02021da:	4601                	li	a2,0
ffffffffc02021dc:	85d6                	mv	a1,s5
ffffffffc02021de:	d93ff0ef          	jal	ra,ffffffffc0201f70 <page_insert>
ffffffffc02021e2:	7a051f63          	bnez	a0,ffffffffc02029a0 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021e6:	6008                	ld	a0,0(s0)
ffffffffc02021e8:	4601                	li	a2,0
ffffffffc02021ea:	4581                	li	a1,0
ffffffffc02021ec:	addff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc02021f0:	78050863          	beqz	a0,ffffffffc0202980 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02021f4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02021f6:	0017f713          	andi	a4,a5,1
ffffffffc02021fa:	3e070463          	beqz	a4,ffffffffc02025e2 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02021fe:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202200:	078a                	slli	a5,a5,0x2
ffffffffc0202202:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202204:	3ce7f163          	bleu	a4,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202208:	00093683          	ld	a3,0(s2)
ffffffffc020220c:	fff80637          	lui	a2,0xfff80
ffffffffc0202210:	97b2                	add	a5,a5,a2
ffffffffc0202212:	079a                	slli	a5,a5,0x6
ffffffffc0202214:	97b6                	add	a5,a5,a3
ffffffffc0202216:	72fa9563          	bne	s5,a5,ffffffffc0202940 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc020221a:	000aab83          	lw	s7,0(s5)
ffffffffc020221e:	4785                	li	a5,1
ffffffffc0202220:	70fb9063          	bne	s7,a5,ffffffffc0202920 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202224:	6008                	ld	a0,0(s0)
ffffffffc0202226:	76fd                	lui	a3,0xfffff
ffffffffc0202228:	611c                	ld	a5,0(a0)
ffffffffc020222a:	078a                	slli	a5,a5,0x2
ffffffffc020222c:	8ff5                	and	a5,a5,a3
ffffffffc020222e:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202232:	66e67e63          	bleu	a4,a2,ffffffffc02028ae <pmm_init+0x880>
ffffffffc0202236:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020223a:	97e2                	add	a5,a5,s8
ffffffffc020223c:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0202240:	0b0a                	slli	s6,s6,0x2
ffffffffc0202242:	00db7b33          	and	s6,s6,a3
ffffffffc0202246:	00cb5793          	srli	a5,s6,0xc
ffffffffc020224a:	56e7f863          	bleu	a4,a5,ffffffffc02027ba <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020224e:	4601                	li	a2,0
ffffffffc0202250:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202252:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202254:	a75ff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202258:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020225a:	55651063          	bne	a0,s6,ffffffffc020279a <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc020225e:	4505                	li	a0,1
ffffffffc0202260:	95bff0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0202264:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202266:	6008                	ld	a0,0(s0)
ffffffffc0202268:	46d1                	li	a3,20
ffffffffc020226a:	6605                	lui	a2,0x1
ffffffffc020226c:	85da                	mv	a1,s6
ffffffffc020226e:	d03ff0ef          	jal	ra,ffffffffc0201f70 <page_insert>
ffffffffc0202272:	50051463          	bnez	a0,ffffffffc020277a <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202276:	6008                	ld	a0,0(s0)
ffffffffc0202278:	4601                	li	a2,0
ffffffffc020227a:	6585                	lui	a1,0x1
ffffffffc020227c:	a4dff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc0202280:	4c050d63          	beqz	a0,ffffffffc020275a <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0202284:	611c                	ld	a5,0(a0)
ffffffffc0202286:	0107f713          	andi	a4,a5,16
ffffffffc020228a:	4a070863          	beqz	a4,ffffffffc020273a <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc020228e:	8b91                	andi	a5,a5,4
ffffffffc0202290:	48078563          	beqz	a5,ffffffffc020271a <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202294:	6008                	ld	a0,0(s0)
ffffffffc0202296:	611c                	ld	a5,0(a0)
ffffffffc0202298:	8bc1                	andi	a5,a5,16
ffffffffc020229a:	46078063          	beqz	a5,ffffffffc02026fa <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc020229e:	000b2783          	lw	a5,0(s6)
ffffffffc02022a2:	43779c63          	bne	a5,s7,ffffffffc02026da <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02022a6:	4681                	li	a3,0
ffffffffc02022a8:	6605                	lui	a2,0x1
ffffffffc02022aa:	85d6                	mv	a1,s5
ffffffffc02022ac:	cc5ff0ef          	jal	ra,ffffffffc0201f70 <page_insert>
ffffffffc02022b0:	40051563          	bnez	a0,ffffffffc02026ba <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02022b4:	000aa703          	lw	a4,0(s5)
ffffffffc02022b8:	4789                	li	a5,2
ffffffffc02022ba:	3ef71063          	bne	a4,a5,ffffffffc020269a <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02022be:	000b2783          	lw	a5,0(s6)
ffffffffc02022c2:	3a079c63          	bnez	a5,ffffffffc020267a <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022c6:	6008                	ld	a0,0(s0)
ffffffffc02022c8:	4601                	li	a2,0
ffffffffc02022ca:	6585                	lui	a1,0x1
ffffffffc02022cc:	9fdff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc02022d0:	38050563          	beqz	a0,ffffffffc020265a <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02022d4:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02022d6:	00177793          	andi	a5,a4,1
ffffffffc02022da:	30078463          	beqz	a5,ffffffffc02025e2 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02022de:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02022e0:	00271793          	slli	a5,a4,0x2
ffffffffc02022e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022e6:	2ed7f063          	bleu	a3,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ea:	00093683          	ld	a3,0(s2)
ffffffffc02022ee:	fff80637          	lui	a2,0xfff80
ffffffffc02022f2:	97b2                	add	a5,a5,a2
ffffffffc02022f4:	079a                	slli	a5,a5,0x6
ffffffffc02022f6:	97b6                	add	a5,a5,a3
ffffffffc02022f8:	32fa9163          	bne	s5,a5,ffffffffc020261a <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02022fc:	8b41                	andi	a4,a4,16
ffffffffc02022fe:	70071163          	bnez	a4,ffffffffc0202a00 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202302:	6008                	ld	a0,0(s0)
ffffffffc0202304:	4581                	li	a1,0
ffffffffc0202306:	bf7ff0ef          	jal	ra,ffffffffc0201efc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020230a:	000aa703          	lw	a4,0(s5)
ffffffffc020230e:	4785                	li	a5,1
ffffffffc0202310:	6cf71863          	bne	a4,a5,ffffffffc02029e0 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202314:	000b2783          	lw	a5,0(s6)
ffffffffc0202318:	6a079463          	bnez	a5,ffffffffc02029c0 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020231c:	6008                	ld	a0,0(s0)
ffffffffc020231e:	6585                	lui	a1,0x1
ffffffffc0202320:	bddff0ef          	jal	ra,ffffffffc0201efc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202324:	000aa783          	lw	a5,0(s5)
ffffffffc0202328:	50079363          	bnez	a5,ffffffffc020282e <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc020232c:	000b2783          	lw	a5,0(s6)
ffffffffc0202330:	4c079f63          	bnez	a5,ffffffffc020280e <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202334:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202338:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020233a:	000ab783          	ld	a5,0(s5)
ffffffffc020233e:	078a                	slli	a5,a5,0x2
ffffffffc0202340:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202342:	28c7f263          	bleu	a2,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202346:	fff80737          	lui	a4,0xfff80
ffffffffc020234a:	00093503          	ld	a0,0(s2)
ffffffffc020234e:	97ba                	add	a5,a5,a4
ffffffffc0202350:	079a                	slli	a5,a5,0x6
ffffffffc0202352:	00f50733          	add	a4,a0,a5
ffffffffc0202356:	4314                	lw	a3,0(a4)
ffffffffc0202358:	4705                	li	a4,1
ffffffffc020235a:	48e69a63          	bne	a3,a4,ffffffffc02027ee <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc020235e:	8799                	srai	a5,a5,0x6
ffffffffc0202360:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202364:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0202366:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202368:	8331                	srli	a4,a4,0xc
ffffffffc020236a:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020236c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020236e:	46c77363          	bleu	a2,a4,ffffffffc02027d4 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202372:	0009b683          	ld	a3,0(s3)
ffffffffc0202376:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202378:	639c                	ld	a5,0(a5)
ffffffffc020237a:	078a                	slli	a5,a5,0x2
ffffffffc020237c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020237e:	24c7f463          	bleu	a2,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202382:	416787b3          	sub	a5,a5,s6
ffffffffc0202386:	079a                	slli	a5,a5,0x6
ffffffffc0202388:	953e                	add	a0,a0,a5
ffffffffc020238a:	4585                	li	a1,1
ffffffffc020238c:	8b7ff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202390:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0202394:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202396:	078a                	slli	a5,a5,0x2
ffffffffc0202398:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020239a:	22e7f663          	bleu	a4,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020239e:	00093503          	ld	a0,0(s2)
ffffffffc02023a2:	416787b3          	sub	a5,a5,s6
ffffffffc02023a6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02023a8:	953e                	add	a0,a0,a5
ffffffffc02023aa:	4585                	li	a1,1
ffffffffc02023ac:	897ff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02023b0:	601c                	ld	a5,0(s0)
ffffffffc02023b2:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02023b6:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02023ba:	8cfff0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>
ffffffffc02023be:	68aa1163          	bne	s4,a0,ffffffffc0202a40 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02023c2:	00004517          	auipc	a0,0x4
ffffffffc02023c6:	dd650513          	addi	a0,a0,-554 # ffffffffc0206198 <default_pmm_manager+0x4e8>
ffffffffc02023ca:	dc5fd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02023ce:	8bbff0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023d2:	6098                	ld	a4,0(s1)
ffffffffc02023d4:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02023d8:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023da:	00c71693          	slli	a3,a4,0xc
ffffffffc02023de:	18d7f563          	bleu	a3,a5,ffffffffc0202568 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023e2:	83b1                	srli	a5,a5,0xc
ffffffffc02023e4:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023e6:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023ea:	1ae7f163          	bleu	a4,a5,ffffffffc020258c <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023ee:	7bfd                	lui	s7,0xfffff
ffffffffc02023f0:	6b05                	lui	s6,0x1
ffffffffc02023f2:	a029                	j	ffffffffc02023fc <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023f4:	00cad713          	srli	a4,s5,0xc
ffffffffc02023f8:	18f77a63          	bleu	a5,a4,ffffffffc020258c <pmm_init+0x55e>
ffffffffc02023fc:	0009b583          	ld	a1,0(s3)
ffffffffc0202400:	4601                	li	a2,0
ffffffffc0202402:	95d6                	add	a1,a1,s5
ffffffffc0202404:	8c5ff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc0202408:	16050263          	beqz	a0,ffffffffc020256c <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020240c:	611c                	ld	a5,0(a0)
ffffffffc020240e:	078a                	slli	a5,a5,0x2
ffffffffc0202410:	0177f7b3          	and	a5,a5,s7
ffffffffc0202414:	19579963          	bne	a5,s5,ffffffffc02025a6 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202418:	609c                	ld	a5,0(s1)
ffffffffc020241a:	9ada                	add	s5,s5,s6
ffffffffc020241c:	6008                	ld	a0,0(s0)
ffffffffc020241e:	00c79713          	slli	a4,a5,0xc
ffffffffc0202422:	fceae9e3          	bltu	s5,a4,ffffffffc02023f4 <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0202426:	611c                	ld	a5,0(a0)
ffffffffc0202428:	62079c63          	bnez	a5,ffffffffc0202a60 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc020242c:	4505                	li	a0,1
ffffffffc020242e:	f8cff0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0202432:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202434:	6008                	ld	a0,0(s0)
ffffffffc0202436:	4699                	li	a3,6
ffffffffc0202438:	10000613          	li	a2,256
ffffffffc020243c:	85d6                	mv	a1,s5
ffffffffc020243e:	b33ff0ef          	jal	ra,ffffffffc0201f70 <page_insert>
ffffffffc0202442:	1e051c63          	bnez	a0,ffffffffc020263a <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202446:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc020244a:	4785                	li	a5,1
ffffffffc020244c:	44f71163          	bne	a4,a5,ffffffffc020288e <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202450:	6008                	ld	a0,0(s0)
ffffffffc0202452:	6b05                	lui	s6,0x1
ffffffffc0202454:	4699                	li	a3,6
ffffffffc0202456:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc020245a:	85d6                	mv	a1,s5
ffffffffc020245c:	b15ff0ef          	jal	ra,ffffffffc0201f70 <page_insert>
ffffffffc0202460:	40051763          	bnez	a0,ffffffffc020286e <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202464:	000aa703          	lw	a4,0(s5)
ffffffffc0202468:	4789                	li	a5,2
ffffffffc020246a:	3ef71263          	bne	a4,a5,ffffffffc020284e <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020246e:	00004597          	auipc	a1,0x4
ffffffffc0202472:	e6258593          	addi	a1,a1,-414 # ffffffffc02062d0 <default_pmm_manager+0x620>
ffffffffc0202476:	10000513          	li	a0,256
ffffffffc020247a:	247020ef          	jal	ra,ffffffffc0204ec0 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020247e:	100b0593          	addi	a1,s6,256
ffffffffc0202482:	10000513          	li	a0,256
ffffffffc0202486:	24d020ef          	jal	ra,ffffffffc0204ed2 <strcmp>
ffffffffc020248a:	44051b63          	bnez	a0,ffffffffc02028e0 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc020248e:	00093683          	ld	a3,0(s2)
ffffffffc0202492:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202496:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202498:	40da86b3          	sub	a3,s5,a3
ffffffffc020249c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020249e:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02024a0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02024a2:	00cb5b13          	srli	s6,s6,0xc
ffffffffc02024a6:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024aa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024ac:	10f77f63          	bleu	a5,a4,ffffffffc02025ca <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02024b0:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02024b4:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02024b8:	96be                	add	a3,a3,a5
ffffffffc02024ba:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde8b00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02024be:	1bf020ef          	jal	ra,ffffffffc0204e7c <strlen>
ffffffffc02024c2:	54051f63          	bnez	a0,ffffffffc0202a20 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02024c6:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02024ca:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024cc:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde8a00>
ffffffffc02024d0:	068a                	slli	a3,a3,0x2
ffffffffc02024d2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024d4:	0ef6f963          	bleu	a5,a3,ffffffffc02025c6 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc02024d8:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024dc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024de:	0efb7663          	bleu	a5,s6,ffffffffc02025ca <pmm_init+0x59c>
ffffffffc02024e2:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02024e6:	4585                	li	a1,1
ffffffffc02024e8:	8556                	mv	a0,s5
ffffffffc02024ea:	99b6                	add	s3,s3,a3
ffffffffc02024ec:	f56ff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024f0:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02024f4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024f6:	078a                	slli	a5,a5,0x2
ffffffffc02024f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024fa:	0ce7f663          	bleu	a4,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024fe:	00093503          	ld	a0,0(s2)
ffffffffc0202502:	fff809b7          	lui	s3,0xfff80
ffffffffc0202506:	97ce                	add	a5,a5,s3
ffffffffc0202508:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020250a:	953e                	add	a0,a0,a5
ffffffffc020250c:	4585                	li	a1,1
ffffffffc020250e:	f34ff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202512:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202516:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202518:	078a                	slli	a5,a5,0x2
ffffffffc020251a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020251c:	0ae7f563          	bleu	a4,a5,ffffffffc02025c6 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202520:	00093503          	ld	a0,0(s2)
ffffffffc0202524:	97ce                	add	a5,a5,s3
ffffffffc0202526:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202528:	953e                	add	a0,a0,a5
ffffffffc020252a:	4585                	li	a1,1
ffffffffc020252c:	f16ff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202530:	601c                	ld	a5,0(s0)
ffffffffc0202532:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202536:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020253a:	f4eff0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>
ffffffffc020253e:	3caa1163          	bne	s4,a0,ffffffffc0202900 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202542:	00004517          	auipc	a0,0x4
ffffffffc0202546:	e0650513          	addi	a0,a0,-506 # ffffffffc0206348 <default_pmm_manager+0x698>
ffffffffc020254a:	c45fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020254e:	6406                	ld	s0,64(sp)
ffffffffc0202550:	60a6                	ld	ra,72(sp)
ffffffffc0202552:	74e2                	ld	s1,56(sp)
ffffffffc0202554:	7942                	ld	s2,48(sp)
ffffffffc0202556:	79a2                	ld	s3,40(sp)
ffffffffc0202558:	7a02                	ld	s4,32(sp)
ffffffffc020255a:	6ae2                	ld	s5,24(sp)
ffffffffc020255c:	6b42                	ld	s6,16(sp)
ffffffffc020255e:	6ba2                	ld	s7,8(sp)
ffffffffc0202560:	6c02                	ld	s8,0(sp)
ffffffffc0202562:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202564:	c3aff06f          	j	ffffffffc020199e <kmalloc_init>
ffffffffc0202568:	6008                	ld	a0,0(s0)
ffffffffc020256a:	bd75                	j	ffffffffc0202426 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020256c:	00004697          	auipc	a3,0x4
ffffffffc0202570:	c4c68693          	addi	a3,a3,-948 # ffffffffc02061b8 <default_pmm_manager+0x508>
ffffffffc0202574:	00003617          	auipc	a2,0x3
ffffffffc0202578:	3a460613          	addi	a2,a2,932 # ffffffffc0205918 <commands+0x870>
ffffffffc020257c:	19d00593          	li	a1,413
ffffffffc0202580:	00004517          	auipc	a0,0x4
ffffffffc0202584:	87050513          	addi	a0,a0,-1936 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202588:	ec9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020258c:	86d6                	mv	a3,s5
ffffffffc020258e:	00003617          	auipc	a2,0x3
ffffffffc0202592:	77260613          	addi	a2,a2,1906 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0202596:	19d00593          	li	a1,413
ffffffffc020259a:	00004517          	auipc	a0,0x4
ffffffffc020259e:	85650513          	addi	a0,a0,-1962 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02025a2:	eaffd0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02025a6:	00004697          	auipc	a3,0x4
ffffffffc02025aa:	c5268693          	addi	a3,a3,-942 # ffffffffc02061f8 <default_pmm_manager+0x548>
ffffffffc02025ae:	00003617          	auipc	a2,0x3
ffffffffc02025b2:	36a60613          	addi	a2,a2,874 # ffffffffc0205918 <commands+0x870>
ffffffffc02025b6:	19e00593          	li	a1,414
ffffffffc02025ba:	00004517          	auipc	a0,0x4
ffffffffc02025be:	83650513          	addi	a0,a0,-1994 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02025c2:	e8ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02025c6:	dd8ff0ef          	jal	ra,ffffffffc0201b9e <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	73660613          	addi	a2,a2,1846 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc02025d2:	06900593          	li	a1,105
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	75250513          	addi	a0,a0,1874 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc02025de:	e73fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02025e2:	00004617          	auipc	a2,0x4
ffffffffc02025e6:	9a660613          	addi	a2,a2,-1626 # ffffffffc0205f88 <default_pmm_manager+0x2d8>
ffffffffc02025ea:	07400593          	li	a1,116
ffffffffc02025ee:	00003517          	auipc	a0,0x3
ffffffffc02025f2:	73a50513          	addi	a0,a0,1850 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc02025f6:	e5bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02025fa:	00004697          	auipc	a3,0x4
ffffffffc02025fe:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0205ec8 <default_pmm_manager+0x218>
ffffffffc0202602:	00003617          	auipc	a2,0x3
ffffffffc0202606:	31660613          	addi	a2,a2,790 # ffffffffc0205918 <commands+0x870>
ffffffffc020260a:	16100593          	li	a1,353
ffffffffc020260e:	00003517          	auipc	a0,0x3
ffffffffc0202612:	7e250513          	addi	a0,a0,2018 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202616:	e3bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020261a:	00004697          	auipc	a3,0x4
ffffffffc020261e:	99668693          	addi	a3,a3,-1642 # ffffffffc0205fb0 <default_pmm_manager+0x300>
ffffffffc0202622:	00003617          	auipc	a2,0x3
ffffffffc0202626:	2f660613          	addi	a2,a2,758 # ffffffffc0205918 <commands+0x870>
ffffffffc020262a:	17d00593          	li	a1,381
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	7c250513          	addi	a0,a0,1986 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202636:	e1bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020263a:	00004697          	auipc	a3,0x4
ffffffffc020263e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0206228 <default_pmm_manager+0x578>
ffffffffc0202642:	00003617          	auipc	a2,0x3
ffffffffc0202646:	2d660613          	addi	a2,a2,726 # ffffffffc0205918 <commands+0x870>
ffffffffc020264a:	1a500593          	li	a1,421
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	7a250513          	addi	a0,a0,1954 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202656:	dfbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020265a:	00004697          	auipc	a3,0x4
ffffffffc020265e:	9e668693          	addi	a3,a3,-1562 # ffffffffc0206040 <default_pmm_manager+0x390>
ffffffffc0202662:	00003617          	auipc	a2,0x3
ffffffffc0202666:	2b660613          	addi	a2,a2,694 # ffffffffc0205918 <commands+0x870>
ffffffffc020266a:	17c00593          	li	a1,380
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	78250513          	addi	a0,a0,1922 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202676:	ddbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020267a:	00004697          	auipc	a3,0x4
ffffffffc020267e:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0206108 <default_pmm_manager+0x458>
ffffffffc0202682:	00003617          	auipc	a2,0x3
ffffffffc0202686:	29660613          	addi	a2,a2,662 # ffffffffc0205918 <commands+0x870>
ffffffffc020268a:	17b00593          	li	a1,379
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	76250513          	addi	a0,a0,1890 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202696:	dbbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020269a:	00004697          	auipc	a3,0x4
ffffffffc020269e:	a5668693          	addi	a3,a3,-1450 # ffffffffc02060f0 <default_pmm_manager+0x440>
ffffffffc02026a2:	00003617          	auipc	a2,0x3
ffffffffc02026a6:	27660613          	addi	a2,a2,630 # ffffffffc0205918 <commands+0x870>
ffffffffc02026aa:	17a00593          	li	a1,378
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	74250513          	addi	a0,a0,1858 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02026b6:	d9bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02026ba:	00004697          	auipc	a3,0x4
ffffffffc02026be:	a0668693          	addi	a3,a3,-1530 # ffffffffc02060c0 <default_pmm_manager+0x410>
ffffffffc02026c2:	00003617          	auipc	a2,0x3
ffffffffc02026c6:	25660613          	addi	a2,a2,598 # ffffffffc0205918 <commands+0x870>
ffffffffc02026ca:	17900593          	li	a1,377
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	72250513          	addi	a0,a0,1826 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02026d6:	d7bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02026da:	00004697          	auipc	a3,0x4
ffffffffc02026de:	9ce68693          	addi	a3,a3,-1586 # ffffffffc02060a8 <default_pmm_manager+0x3f8>
ffffffffc02026e2:	00003617          	auipc	a2,0x3
ffffffffc02026e6:	23660613          	addi	a2,a2,566 # ffffffffc0205918 <commands+0x870>
ffffffffc02026ea:	17700593          	li	a1,375
ffffffffc02026ee:	00003517          	auipc	a0,0x3
ffffffffc02026f2:	70250513          	addi	a0,a0,1794 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02026f6:	d5bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02026fa:	00004697          	auipc	a3,0x4
ffffffffc02026fe:	99668693          	addi	a3,a3,-1642 # ffffffffc0206090 <default_pmm_manager+0x3e0>
ffffffffc0202702:	00003617          	auipc	a2,0x3
ffffffffc0202706:	21660613          	addi	a2,a2,534 # ffffffffc0205918 <commands+0x870>
ffffffffc020270a:	17600593          	li	a1,374
ffffffffc020270e:	00003517          	auipc	a0,0x3
ffffffffc0202712:	6e250513          	addi	a0,a0,1762 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202716:	d3bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020271a:	00004697          	auipc	a3,0x4
ffffffffc020271e:	96668693          	addi	a3,a3,-1690 # ffffffffc0206080 <default_pmm_manager+0x3d0>
ffffffffc0202722:	00003617          	auipc	a2,0x3
ffffffffc0202726:	1f660613          	addi	a2,a2,502 # ffffffffc0205918 <commands+0x870>
ffffffffc020272a:	17500593          	li	a1,373
ffffffffc020272e:	00003517          	auipc	a0,0x3
ffffffffc0202732:	6c250513          	addi	a0,a0,1730 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202736:	d1bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020273a:	00004697          	auipc	a3,0x4
ffffffffc020273e:	93668693          	addi	a3,a3,-1738 # ffffffffc0206070 <default_pmm_manager+0x3c0>
ffffffffc0202742:	00003617          	auipc	a2,0x3
ffffffffc0202746:	1d660613          	addi	a2,a2,470 # ffffffffc0205918 <commands+0x870>
ffffffffc020274a:	17400593          	li	a1,372
ffffffffc020274e:	00003517          	auipc	a0,0x3
ffffffffc0202752:	6a250513          	addi	a0,a0,1698 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202756:	cfbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020275a:	00004697          	auipc	a3,0x4
ffffffffc020275e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0206040 <default_pmm_manager+0x390>
ffffffffc0202762:	00003617          	auipc	a2,0x3
ffffffffc0202766:	1b660613          	addi	a2,a2,438 # ffffffffc0205918 <commands+0x870>
ffffffffc020276a:	17300593          	li	a1,371
ffffffffc020276e:	00003517          	auipc	a0,0x3
ffffffffc0202772:	68250513          	addi	a0,a0,1666 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202776:	cdbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020277a:	00004697          	auipc	a3,0x4
ffffffffc020277e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0206008 <default_pmm_manager+0x358>
ffffffffc0202782:	00003617          	auipc	a2,0x3
ffffffffc0202786:	19660613          	addi	a2,a2,406 # ffffffffc0205918 <commands+0x870>
ffffffffc020278a:	17200593          	li	a1,370
ffffffffc020278e:	00003517          	auipc	a0,0x3
ffffffffc0202792:	66250513          	addi	a0,a0,1634 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202796:	cbbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020279a:	00004697          	auipc	a3,0x4
ffffffffc020279e:	84668693          	addi	a3,a3,-1978 # ffffffffc0205fe0 <default_pmm_manager+0x330>
ffffffffc02027a2:	00003617          	auipc	a2,0x3
ffffffffc02027a6:	17660613          	addi	a2,a2,374 # ffffffffc0205918 <commands+0x870>
ffffffffc02027aa:	16f00593          	li	a1,367
ffffffffc02027ae:	00003517          	auipc	a0,0x3
ffffffffc02027b2:	64250513          	addi	a0,a0,1602 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02027b6:	c9bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027ba:	86da                	mv	a3,s6
ffffffffc02027bc:	00003617          	auipc	a2,0x3
ffffffffc02027c0:	54460613          	addi	a2,a2,1348 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc02027c4:	16e00593          	li	a1,366
ffffffffc02027c8:	00003517          	auipc	a0,0x3
ffffffffc02027cc:	62850513          	addi	a0,a0,1576 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02027d0:	c81fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc02027d4:	86be                	mv	a3,a5
ffffffffc02027d6:	00003617          	auipc	a2,0x3
ffffffffc02027da:	52a60613          	addi	a2,a2,1322 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc02027de:	06900593          	li	a1,105
ffffffffc02027e2:	00003517          	auipc	a0,0x3
ffffffffc02027e6:	54650513          	addi	a0,a0,1350 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc02027ea:	c67fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02027ee:	00004697          	auipc	a3,0x4
ffffffffc02027f2:	96268693          	addi	a3,a3,-1694 # ffffffffc0206150 <default_pmm_manager+0x4a0>
ffffffffc02027f6:	00003617          	auipc	a2,0x3
ffffffffc02027fa:	12260613          	addi	a2,a2,290 # ffffffffc0205918 <commands+0x870>
ffffffffc02027fe:	18800593          	li	a1,392
ffffffffc0202802:	00003517          	auipc	a0,0x3
ffffffffc0202806:	5ee50513          	addi	a0,a0,1518 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020280a:	c47fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020280e:	00004697          	auipc	a3,0x4
ffffffffc0202812:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0206108 <default_pmm_manager+0x458>
ffffffffc0202816:	00003617          	auipc	a2,0x3
ffffffffc020281a:	10260613          	addi	a2,a2,258 # ffffffffc0205918 <commands+0x870>
ffffffffc020281e:	18600593          	li	a1,390
ffffffffc0202822:	00003517          	auipc	a0,0x3
ffffffffc0202826:	5ce50513          	addi	a0,a0,1486 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020282a:	c27fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020282e:	00004697          	auipc	a3,0x4
ffffffffc0202832:	90a68693          	addi	a3,a3,-1782 # ffffffffc0206138 <default_pmm_manager+0x488>
ffffffffc0202836:	00003617          	auipc	a2,0x3
ffffffffc020283a:	0e260613          	addi	a2,a2,226 # ffffffffc0205918 <commands+0x870>
ffffffffc020283e:	18500593          	li	a1,389
ffffffffc0202842:	00003517          	auipc	a0,0x3
ffffffffc0202846:	5ae50513          	addi	a0,a0,1454 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020284a:	c07fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020284e:	00004697          	auipc	a3,0x4
ffffffffc0202852:	a6a68693          	addi	a3,a3,-1430 # ffffffffc02062b8 <default_pmm_manager+0x608>
ffffffffc0202856:	00003617          	auipc	a2,0x3
ffffffffc020285a:	0c260613          	addi	a2,a2,194 # ffffffffc0205918 <commands+0x870>
ffffffffc020285e:	1a800593          	li	a1,424
ffffffffc0202862:	00003517          	auipc	a0,0x3
ffffffffc0202866:	58e50513          	addi	a0,a0,1422 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020286a:	be7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020286e:	00004697          	auipc	a3,0x4
ffffffffc0202872:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0206278 <default_pmm_manager+0x5c8>
ffffffffc0202876:	00003617          	auipc	a2,0x3
ffffffffc020287a:	0a260613          	addi	a2,a2,162 # ffffffffc0205918 <commands+0x870>
ffffffffc020287e:	1a700593          	li	a1,423
ffffffffc0202882:	00003517          	auipc	a0,0x3
ffffffffc0202886:	56e50513          	addi	a0,a0,1390 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020288a:	bc7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020288e:	00004697          	auipc	a3,0x4
ffffffffc0202892:	9d268693          	addi	a3,a3,-1582 # ffffffffc0206260 <default_pmm_manager+0x5b0>
ffffffffc0202896:	00003617          	auipc	a2,0x3
ffffffffc020289a:	08260613          	addi	a2,a2,130 # ffffffffc0205918 <commands+0x870>
ffffffffc020289e:	1a600593          	li	a1,422
ffffffffc02028a2:	00003517          	auipc	a0,0x3
ffffffffc02028a6:	54e50513          	addi	a0,a0,1358 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02028aa:	ba7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02028ae:	86be                	mv	a3,a5
ffffffffc02028b0:	00003617          	auipc	a2,0x3
ffffffffc02028b4:	45060613          	addi	a2,a2,1104 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc02028b8:	16d00593          	li	a1,365
ffffffffc02028bc:	00003517          	auipc	a0,0x3
ffffffffc02028c0:	53450513          	addi	a0,a0,1332 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02028c4:	b8dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028c8:	00003617          	auipc	a2,0x3
ffffffffc02028cc:	47060613          	addi	a2,a2,1136 # ffffffffc0205d38 <default_pmm_manager+0x88>
ffffffffc02028d0:	07f00593          	li	a1,127
ffffffffc02028d4:	00003517          	auipc	a0,0x3
ffffffffc02028d8:	51c50513          	addi	a0,a0,1308 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02028dc:	b75fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02028e0:	00004697          	auipc	a3,0x4
ffffffffc02028e4:	a0868693          	addi	a3,a3,-1528 # ffffffffc02062e8 <default_pmm_manager+0x638>
ffffffffc02028e8:	00003617          	auipc	a2,0x3
ffffffffc02028ec:	03060613          	addi	a2,a2,48 # ffffffffc0205918 <commands+0x870>
ffffffffc02028f0:	1ac00593          	li	a1,428
ffffffffc02028f4:	00003517          	auipc	a0,0x3
ffffffffc02028f8:	4fc50513          	addi	a0,a0,1276 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02028fc:	b55fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202900:	00004697          	auipc	a3,0x4
ffffffffc0202904:	87868693          	addi	a3,a3,-1928 # ffffffffc0206178 <default_pmm_manager+0x4c8>
ffffffffc0202908:	00003617          	auipc	a2,0x3
ffffffffc020290c:	01060613          	addi	a2,a2,16 # ffffffffc0205918 <commands+0x870>
ffffffffc0202910:	1b800593          	li	a1,440
ffffffffc0202914:	00003517          	auipc	a0,0x3
ffffffffc0202918:	4dc50513          	addi	a0,a0,1244 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020291c:	b35fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202920:	00003697          	auipc	a3,0x3
ffffffffc0202924:	6a868693          	addi	a3,a3,1704 # ffffffffc0205fc8 <default_pmm_manager+0x318>
ffffffffc0202928:	00003617          	auipc	a2,0x3
ffffffffc020292c:	ff060613          	addi	a2,a2,-16 # ffffffffc0205918 <commands+0x870>
ffffffffc0202930:	16b00593          	li	a1,363
ffffffffc0202934:	00003517          	auipc	a0,0x3
ffffffffc0202938:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020293c:	b15fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202940:	00003697          	auipc	a3,0x3
ffffffffc0202944:	67068693          	addi	a3,a3,1648 # ffffffffc0205fb0 <default_pmm_manager+0x300>
ffffffffc0202948:	00003617          	auipc	a2,0x3
ffffffffc020294c:	fd060613          	addi	a2,a2,-48 # ffffffffc0205918 <commands+0x870>
ffffffffc0202950:	16a00593          	li	a1,362
ffffffffc0202954:	00003517          	auipc	a0,0x3
ffffffffc0202958:	49c50513          	addi	a0,a0,1180 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020295c:	af5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202960:	00003697          	auipc	a3,0x3
ffffffffc0202964:	5a068693          	addi	a3,a3,1440 # ffffffffc0205f00 <default_pmm_manager+0x250>
ffffffffc0202968:	00003617          	auipc	a2,0x3
ffffffffc020296c:	fb060613          	addi	a2,a2,-80 # ffffffffc0205918 <commands+0x870>
ffffffffc0202970:	16200593          	li	a1,354
ffffffffc0202974:	00003517          	auipc	a0,0x3
ffffffffc0202978:	47c50513          	addi	a0,a0,1148 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020297c:	ad5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202980:	00003697          	auipc	a3,0x3
ffffffffc0202984:	5d868693          	addi	a3,a3,1496 # ffffffffc0205f58 <default_pmm_manager+0x2a8>
ffffffffc0202988:	00003617          	auipc	a2,0x3
ffffffffc020298c:	f9060613          	addi	a2,a2,-112 # ffffffffc0205918 <commands+0x870>
ffffffffc0202990:	16900593          	li	a1,361
ffffffffc0202994:	00003517          	auipc	a0,0x3
ffffffffc0202998:	45c50513          	addi	a0,a0,1116 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc020299c:	ab5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02029a0:	00003697          	auipc	a3,0x3
ffffffffc02029a4:	58868693          	addi	a3,a3,1416 # ffffffffc0205f28 <default_pmm_manager+0x278>
ffffffffc02029a8:	00003617          	auipc	a2,0x3
ffffffffc02029ac:	f7060613          	addi	a2,a2,-144 # ffffffffc0205918 <commands+0x870>
ffffffffc02029b0:	16600593          	li	a1,358
ffffffffc02029b4:	00003517          	auipc	a0,0x3
ffffffffc02029b8:	43c50513          	addi	a0,a0,1084 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02029bc:	a95fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02029c0:	00003697          	auipc	a3,0x3
ffffffffc02029c4:	74868693          	addi	a3,a3,1864 # ffffffffc0206108 <default_pmm_manager+0x458>
ffffffffc02029c8:	00003617          	auipc	a2,0x3
ffffffffc02029cc:	f5060613          	addi	a2,a2,-176 # ffffffffc0205918 <commands+0x870>
ffffffffc02029d0:	18200593          	li	a1,386
ffffffffc02029d4:	00003517          	auipc	a0,0x3
ffffffffc02029d8:	41c50513          	addi	a0,a0,1052 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02029dc:	a75fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02029e0:	00003697          	auipc	a3,0x3
ffffffffc02029e4:	5e868693          	addi	a3,a3,1512 # ffffffffc0205fc8 <default_pmm_manager+0x318>
ffffffffc02029e8:	00003617          	auipc	a2,0x3
ffffffffc02029ec:	f3060613          	addi	a2,a2,-208 # ffffffffc0205918 <commands+0x870>
ffffffffc02029f0:	18100593          	li	a1,385
ffffffffc02029f4:	00003517          	auipc	a0,0x3
ffffffffc02029f8:	3fc50513          	addi	a0,a0,1020 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc02029fc:	a55fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a00:	00003697          	auipc	a3,0x3
ffffffffc0202a04:	72068693          	addi	a3,a3,1824 # ffffffffc0206120 <default_pmm_manager+0x470>
ffffffffc0202a08:	00003617          	auipc	a2,0x3
ffffffffc0202a0c:	f1060613          	addi	a2,a2,-240 # ffffffffc0205918 <commands+0x870>
ffffffffc0202a10:	17e00593          	li	a1,382
ffffffffc0202a14:	00003517          	auipc	a0,0x3
ffffffffc0202a18:	3dc50513          	addi	a0,a0,988 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202a1c:	a35fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a20:	00004697          	auipc	a3,0x4
ffffffffc0202a24:	90068693          	addi	a3,a3,-1792 # ffffffffc0206320 <default_pmm_manager+0x670>
ffffffffc0202a28:	00003617          	auipc	a2,0x3
ffffffffc0202a2c:	ef060613          	addi	a2,a2,-272 # ffffffffc0205918 <commands+0x870>
ffffffffc0202a30:	1af00593          	li	a1,431
ffffffffc0202a34:	00003517          	auipc	a0,0x3
ffffffffc0202a38:	3bc50513          	addi	a0,a0,956 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202a3c:	a15fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202a40:	00003697          	auipc	a3,0x3
ffffffffc0202a44:	73868693          	addi	a3,a3,1848 # ffffffffc0206178 <default_pmm_manager+0x4c8>
ffffffffc0202a48:	00003617          	auipc	a2,0x3
ffffffffc0202a4c:	ed060613          	addi	a2,a2,-304 # ffffffffc0205918 <commands+0x870>
ffffffffc0202a50:	19000593          	li	a1,400
ffffffffc0202a54:	00003517          	auipc	a0,0x3
ffffffffc0202a58:	39c50513          	addi	a0,a0,924 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202a5c:	9f5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a60:	00003697          	auipc	a3,0x3
ffffffffc0202a64:	7b068693          	addi	a3,a3,1968 # ffffffffc0206210 <default_pmm_manager+0x560>
ffffffffc0202a68:	00003617          	auipc	a2,0x3
ffffffffc0202a6c:	eb060613          	addi	a2,a2,-336 # ffffffffc0205918 <commands+0x870>
ffffffffc0202a70:	1a100593          	li	a1,417
ffffffffc0202a74:	00003517          	auipc	a0,0x3
ffffffffc0202a78:	37c50513          	addi	a0,a0,892 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202a7c:	9d5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202a80:	00003697          	auipc	a3,0x3
ffffffffc0202a84:	42868693          	addi	a3,a3,1064 # ffffffffc0205ea8 <default_pmm_manager+0x1f8>
ffffffffc0202a88:	00003617          	auipc	a2,0x3
ffffffffc0202a8c:	e9060613          	addi	a2,a2,-368 # ffffffffc0205918 <commands+0x870>
ffffffffc0202a90:	16000593          	li	a1,352
ffffffffc0202a94:	00003517          	auipc	a0,0x3
ffffffffc0202a98:	35c50513          	addi	a0,a0,860 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202a9c:	9b5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202aa0:	00003617          	auipc	a2,0x3
ffffffffc0202aa4:	29860613          	addi	a2,a2,664 # ffffffffc0205d38 <default_pmm_manager+0x88>
ffffffffc0202aa8:	0c300593          	li	a1,195
ffffffffc0202aac:	00003517          	auipc	a0,0x3
ffffffffc0202ab0:	34450513          	addi	a0,a0,836 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202ab4:	99dfd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0202ab8 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202ab8:	12058073          	sfence.vma	a1
}
ffffffffc0202abc:	8082                	ret

ffffffffc0202abe <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202abe:	7179                	addi	sp,sp,-48
ffffffffc0202ac0:	e84a                	sd	s2,16(sp)
ffffffffc0202ac2:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202ac4:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202ac6:	f022                	sd	s0,32(sp)
ffffffffc0202ac8:	ec26                	sd	s1,24(sp)
ffffffffc0202aca:	e44e                	sd	s3,8(sp)
ffffffffc0202acc:	f406                	sd	ra,40(sp)
ffffffffc0202ace:	84ae                	mv	s1,a1
ffffffffc0202ad0:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202ad2:	8e8ff0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0202ad6:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202ad8:	cd19                	beqz	a0,ffffffffc0202af6 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202ada:	85aa                	mv	a1,a0
ffffffffc0202adc:	86ce                	mv	a3,s3
ffffffffc0202ade:	8626                	mv	a2,s1
ffffffffc0202ae0:	854a                	mv	a0,s2
ffffffffc0202ae2:	c8eff0ef          	jal	ra,ffffffffc0201f70 <page_insert>
ffffffffc0202ae6:	ed39                	bnez	a0,ffffffffc0202b44 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202ae8:	00014797          	auipc	a5,0x14
ffffffffc0202aec:	9c078793          	addi	a5,a5,-1600 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0202af0:	439c                	lw	a5,0(a5)
ffffffffc0202af2:	2781                	sext.w	a5,a5
ffffffffc0202af4:	eb89                	bnez	a5,ffffffffc0202b06 <pgdir_alloc_page+0x48>
}
ffffffffc0202af6:	8522                	mv	a0,s0
ffffffffc0202af8:	70a2                	ld	ra,40(sp)
ffffffffc0202afa:	7402                	ld	s0,32(sp)
ffffffffc0202afc:	64e2                	ld	s1,24(sp)
ffffffffc0202afe:	6942                	ld	s2,16(sp)
ffffffffc0202b00:	69a2                	ld	s3,8(sp)
ffffffffc0202b02:	6145                	addi	sp,sp,48
ffffffffc0202b04:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202b06:	00014797          	auipc	a5,0x14
ffffffffc0202b0a:	ae278793          	addi	a5,a5,-1310 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0202b0e:	6388                	ld	a0,0(a5)
ffffffffc0202b10:	4681                	li	a3,0
ffffffffc0202b12:	8622                	mv	a2,s0
ffffffffc0202b14:	85a6                	mv	a1,s1
ffffffffc0202b16:	7be000ef          	jal	ra,ffffffffc02032d4 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202b1a:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202b1c:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202b1e:	4785                	li	a5,1
ffffffffc0202b20:	fcf70be3          	beq	a4,a5,ffffffffc0202af6 <pgdir_alloc_page+0x38>
ffffffffc0202b24:	00003697          	auipc	a3,0x3
ffffffffc0202b28:	2dc68693          	addi	a3,a3,732 # ffffffffc0205e00 <default_pmm_manager+0x150>
ffffffffc0202b2c:	00003617          	auipc	a2,0x3
ffffffffc0202b30:	dec60613          	addi	a2,a2,-532 # ffffffffc0205918 <commands+0x870>
ffffffffc0202b34:	14800593          	li	a1,328
ffffffffc0202b38:	00003517          	auipc	a0,0x3
ffffffffc0202b3c:	2b850513          	addi	a0,a0,696 # ffffffffc0205df0 <default_pmm_manager+0x140>
ffffffffc0202b40:	911fd0ef          	jal	ra,ffffffffc0200450 <__panic>
            free_page(page);
ffffffffc0202b44:	8522                	mv	a0,s0
ffffffffc0202b46:	4585                	li	a1,1
ffffffffc0202b48:	8faff0ef          	jal	ra,ffffffffc0201c42 <free_pages>
            return NULL;
ffffffffc0202b4c:	4401                	li	s0,0
ffffffffc0202b4e:	b765                	j	ffffffffc0202af6 <pgdir_alloc_page+0x38>

ffffffffc0202b50 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202b50:	7135                	addi	sp,sp,-160
ffffffffc0202b52:	ed06                	sd	ra,152(sp)
ffffffffc0202b54:	e922                	sd	s0,144(sp)
ffffffffc0202b56:	e526                	sd	s1,136(sp)
ffffffffc0202b58:	e14a                	sd	s2,128(sp)
ffffffffc0202b5a:	fcce                	sd	s3,120(sp)
ffffffffc0202b5c:	f8d2                	sd	s4,112(sp)
ffffffffc0202b5e:	f4d6                	sd	s5,104(sp)
ffffffffc0202b60:	f0da                	sd	s6,96(sp)
ffffffffc0202b62:	ecde                	sd	s7,88(sp)
ffffffffc0202b64:	e8e2                	sd	s8,80(sp)
ffffffffc0202b66:	e4e6                	sd	s9,72(sp)
ffffffffc0202b68:	e0ea                	sd	s10,64(sp)
ffffffffc0202b6a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b6c:	4f2010ef          	jal	ra,ffffffffc020405e <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b70:	00014797          	auipc	a5,0x14
ffffffffc0202b74:	a2878793          	addi	a5,a5,-1496 # ffffffffc0216598 <max_swap_offset>
ffffffffc0202b78:	6394                	ld	a3,0(a5)
ffffffffc0202b7a:	010007b7          	lui	a5,0x1000
ffffffffc0202b7e:	17e1                	addi	a5,a5,-8
ffffffffc0202b80:	ff968713          	addi	a4,a3,-7
ffffffffc0202b84:	4ae7e863          	bltu	a5,a4,ffffffffc0203034 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b88:	00008797          	auipc	a5,0x8
ffffffffc0202b8c:	48878793          	addi	a5,a5,1160 # ffffffffc020b010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b90:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b92:	00014697          	auipc	a3,0x14
ffffffffc0202b96:	90f6b723          	sd	a5,-1778(a3) # ffffffffc02164a0 <sm>
     int r = sm->init();
ffffffffc0202b9a:	9702                	jalr	a4
ffffffffc0202b9c:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202b9e:	c10d                	beqz	a0,ffffffffc0202bc0 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202ba0:	60ea                	ld	ra,152(sp)
ffffffffc0202ba2:	644a                	ld	s0,144(sp)
ffffffffc0202ba4:	8556                	mv	a0,s5
ffffffffc0202ba6:	64aa                	ld	s1,136(sp)
ffffffffc0202ba8:	690a                	ld	s2,128(sp)
ffffffffc0202baa:	79e6                	ld	s3,120(sp)
ffffffffc0202bac:	7a46                	ld	s4,112(sp)
ffffffffc0202bae:	7aa6                	ld	s5,104(sp)
ffffffffc0202bb0:	7b06                	ld	s6,96(sp)
ffffffffc0202bb2:	6be6                	ld	s7,88(sp)
ffffffffc0202bb4:	6c46                	ld	s8,80(sp)
ffffffffc0202bb6:	6ca6                	ld	s9,72(sp)
ffffffffc0202bb8:	6d06                	ld	s10,64(sp)
ffffffffc0202bba:	7de2                	ld	s11,56(sp)
ffffffffc0202bbc:	610d                	addi	sp,sp,160
ffffffffc0202bbe:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bc0:	00014797          	auipc	a5,0x14
ffffffffc0202bc4:	8e078793          	addi	a5,a5,-1824 # ffffffffc02164a0 <sm>
ffffffffc0202bc8:	639c                	ld	a5,0(a5)
ffffffffc0202bca:	00004517          	auipc	a0,0x4
ffffffffc0202bce:	81e50513          	addi	a0,a0,-2018 # ffffffffc02063e8 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0202bd2:	00014417          	auipc	s0,0x14
ffffffffc0202bd6:	90640413          	addi	s0,s0,-1786 # ffffffffc02164d8 <free_area>
ffffffffc0202bda:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202bdc:	4785                	li	a5,1
ffffffffc0202bde:	00014717          	auipc	a4,0x14
ffffffffc0202be2:	8cf72523          	sw	a5,-1846(a4) # ffffffffc02164a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202be6:	da8fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202bea:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bec:	36878863          	beq	a5,s0,ffffffffc0202f5c <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202bf0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bf4:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202bf6:	8b05                	andi	a4,a4,1
ffffffffc0202bf8:	36070663          	beqz	a4,ffffffffc0202f64 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202bfc:	4481                	li	s1,0
ffffffffc0202bfe:	4901                	li	s2,0
ffffffffc0202c00:	a031                	j	ffffffffc0202c0c <swap_init+0xbc>
ffffffffc0202c02:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202c06:	8b09                	andi	a4,a4,2
ffffffffc0202c08:	34070e63          	beqz	a4,ffffffffc0202f64 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202c0c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c10:	679c                	ld	a5,8(a5)
ffffffffc0202c12:	2905                	addiw	s2,s2,1
ffffffffc0202c14:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c16:	fe8796e3          	bne	a5,s0,ffffffffc0202c02 <swap_init+0xb2>
ffffffffc0202c1a:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202c1c:	86cff0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>
ffffffffc0202c20:	69351263          	bne	a0,s3,ffffffffc02032a4 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c24:	8626                	mv	a2,s1
ffffffffc0202c26:	85ca                	mv	a1,s2
ffffffffc0202c28:	00003517          	auipc	a0,0x3
ffffffffc0202c2c:	7d850513          	addi	a0,a0,2008 # ffffffffc0206400 <default_pmm_manager+0x750>
ffffffffc0202c30:	d5efd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c34:	44b000ef          	jal	ra,ffffffffc020387e <mm_create>
ffffffffc0202c38:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202c3a:	60050563          	beqz	a0,ffffffffc0203244 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202c3e:	00014797          	auipc	a5,0x14
ffffffffc0202c42:	9aa78793          	addi	a5,a5,-1622 # ffffffffc02165e8 <check_mm_struct>
ffffffffc0202c46:	639c                	ld	a5,0(a5)
ffffffffc0202c48:	60079e63          	bnez	a5,ffffffffc0203264 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c4c:	00014797          	auipc	a5,0x14
ffffffffc0202c50:	84478793          	addi	a5,a5,-1980 # ffffffffc0216490 <boot_pgdir>
ffffffffc0202c54:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202c58:	00014797          	auipc	a5,0x14
ffffffffc0202c5c:	98a7b823          	sd	a0,-1648(a5) # ffffffffc02165e8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c60:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c64:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c68:	4e079263          	bnez	a5,ffffffffc020314c <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c6c:	6599                	lui	a1,0x6
ffffffffc0202c6e:	460d                	li	a2,3
ffffffffc0202c70:	6505                	lui	a0,0x1
ffffffffc0202c72:	459000ef          	jal	ra,ffffffffc02038ca <vma_create>
ffffffffc0202c76:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c78:	4e050a63          	beqz	a0,ffffffffc020316c <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202c7c:	855e                	mv	a0,s7
ffffffffc0202c7e:	4b9000ef          	jal	ra,ffffffffc0203936 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c82:	00003517          	auipc	a0,0x3
ffffffffc0202c86:	7ee50513          	addi	a0,a0,2030 # ffffffffc0206470 <default_pmm_manager+0x7c0>
ffffffffc0202c8a:	d04fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c8e:	018bb503          	ld	a0,24(s7)
ffffffffc0202c92:	4605                	li	a2,1
ffffffffc0202c94:	6585                	lui	a1,0x1
ffffffffc0202c96:	832ff0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c9a:	4e050963          	beqz	a0,ffffffffc020318c <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c9e:	00004517          	auipc	a0,0x4
ffffffffc0202ca2:	82250513          	addi	a0,a0,-2014 # ffffffffc02064c0 <default_pmm_manager+0x810>
ffffffffc0202ca6:	00014997          	auipc	s3,0x14
ffffffffc0202caa:	86a98993          	addi	s3,s3,-1942 # ffffffffc0216510 <check_rp>
ffffffffc0202cae:	ce0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cb2:	00014a17          	auipc	s4,0x14
ffffffffc0202cb6:	87ea0a13          	addi	s4,s4,-1922 # ffffffffc0216530 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202cba:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202cbc:	4505                	li	a0,1
ffffffffc0202cbe:	efdfe0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
ffffffffc0202cc2:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202cc6:	32050763          	beqz	a0,ffffffffc0202ff4 <swap_init+0x4a4>
ffffffffc0202cca:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202ccc:	8b89                	andi	a5,a5,2
ffffffffc0202cce:	30079363          	bnez	a5,ffffffffc0202fd4 <swap_init+0x484>
ffffffffc0202cd2:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cd4:	ff4c14e3          	bne	s8,s4,ffffffffc0202cbc <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202cd8:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202cda:	00014c17          	auipc	s8,0x14
ffffffffc0202cde:	836c0c13          	addi	s8,s8,-1994 # ffffffffc0216510 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202ce2:	ec3e                	sd	a5,24(sp)
ffffffffc0202ce4:	641c                	ld	a5,8(s0)
ffffffffc0202ce6:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202ce8:	481c                	lw	a5,16(s0)
ffffffffc0202cea:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202cec:	00013797          	auipc	a5,0x13
ffffffffc0202cf0:	7e87ba23          	sd	s0,2036(a5) # ffffffffc02164e0 <free_area+0x8>
ffffffffc0202cf4:	00013797          	auipc	a5,0x13
ffffffffc0202cf8:	7e87b223          	sd	s0,2020(a5) # ffffffffc02164d8 <free_area>
     nr_free = 0;
ffffffffc0202cfc:	00013797          	auipc	a5,0x13
ffffffffc0202d00:	7e07a623          	sw	zero,2028(a5) # ffffffffc02164e8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202d04:	000c3503          	ld	a0,0(s8)
ffffffffc0202d08:	4585                	li	a1,1
ffffffffc0202d0a:	0c21                	addi	s8,s8,8
ffffffffc0202d0c:	f37fe0ef          	jal	ra,ffffffffc0201c42 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d10:	ff4c1ae3          	bne	s8,s4,ffffffffc0202d04 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d14:	01042c03          	lw	s8,16(s0)
ffffffffc0202d18:	4791                	li	a5,4
ffffffffc0202d1a:	50fc1563          	bne	s8,a5,ffffffffc0203224 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202d1e:	00004517          	auipc	a0,0x4
ffffffffc0202d22:	82a50513          	addi	a0,a0,-2006 # ffffffffc0206548 <default_pmm_manager+0x898>
ffffffffc0202d26:	c68fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d2a:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202d2c:	00013797          	auipc	a5,0x13
ffffffffc0202d30:	7807a023          	sw	zero,1920(a5) # ffffffffc02164ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d34:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202d36:	00013797          	auipc	a5,0x13
ffffffffc0202d3a:	77678793          	addi	a5,a5,1910 # ffffffffc02164ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d3e:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d42:	4398                	lw	a4,0(a5)
ffffffffc0202d44:	4585                	li	a1,1
ffffffffc0202d46:	2701                	sext.w	a4,a4
ffffffffc0202d48:	38b71263          	bne	a4,a1,ffffffffc02030cc <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d4c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202d50:	4394                	lw	a3,0(a5)
ffffffffc0202d52:	2681                	sext.w	a3,a3
ffffffffc0202d54:	38e69c63          	bne	a3,a4,ffffffffc02030ec <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d58:	6689                	lui	a3,0x2
ffffffffc0202d5a:	462d                	li	a2,11
ffffffffc0202d5c:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d60:	4398                	lw	a4,0(a5)
ffffffffc0202d62:	4589                	li	a1,2
ffffffffc0202d64:	2701                	sext.w	a4,a4
ffffffffc0202d66:	2eb71363          	bne	a4,a1,ffffffffc020304c <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d6a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d6e:	4394                	lw	a3,0(a5)
ffffffffc0202d70:	2681                	sext.w	a3,a3
ffffffffc0202d72:	2ee69d63          	bne	a3,a4,ffffffffc020306c <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d76:	668d                	lui	a3,0x3
ffffffffc0202d78:	4631                	li	a2,12
ffffffffc0202d7a:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d7e:	4398                	lw	a4,0(a5)
ffffffffc0202d80:	458d                	li	a1,3
ffffffffc0202d82:	2701                	sext.w	a4,a4
ffffffffc0202d84:	30b71463          	bne	a4,a1,ffffffffc020308c <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d88:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d8c:	4394                	lw	a3,0(a5)
ffffffffc0202d8e:	2681                	sext.w	a3,a3
ffffffffc0202d90:	30e69e63          	bne	a3,a4,ffffffffc02030ac <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d94:	6691                	lui	a3,0x4
ffffffffc0202d96:	4635                	li	a2,13
ffffffffc0202d98:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d9c:	4398                	lw	a4,0(a5)
ffffffffc0202d9e:	2701                	sext.w	a4,a4
ffffffffc0202da0:	37871663          	bne	a4,s8,ffffffffc020310c <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202da4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202da8:	439c                	lw	a5,0(a5)
ffffffffc0202daa:	2781                	sext.w	a5,a5
ffffffffc0202dac:	38e79063          	bne	a5,a4,ffffffffc020312c <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202db0:	481c                	lw	a5,16(s0)
ffffffffc0202db2:	3e079d63          	bnez	a5,ffffffffc02031ac <swap_init+0x65c>
ffffffffc0202db6:	00013797          	auipc	a5,0x13
ffffffffc0202dba:	77a78793          	addi	a5,a5,1914 # ffffffffc0216530 <swap_in_seq_no>
ffffffffc0202dbe:	00013717          	auipc	a4,0x13
ffffffffc0202dc2:	79a70713          	addi	a4,a4,1946 # ffffffffc0216558 <swap_out_seq_no>
ffffffffc0202dc6:	00013617          	auipc	a2,0x13
ffffffffc0202dca:	79260613          	addi	a2,a2,1938 # ffffffffc0216558 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202dce:	56fd                	li	a3,-1
ffffffffc0202dd0:	c394                	sw	a3,0(a5)
ffffffffc0202dd2:	c314                	sw	a3,0(a4)
ffffffffc0202dd4:	0791                	addi	a5,a5,4
ffffffffc0202dd6:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202dd8:	fef61ce3          	bne	a2,a5,ffffffffc0202dd0 <swap_init+0x280>
ffffffffc0202ddc:	00013697          	auipc	a3,0x13
ffffffffc0202de0:	7dc68693          	addi	a3,a3,2012 # ffffffffc02165b8 <check_ptep>
ffffffffc0202de4:	00013817          	auipc	a6,0x13
ffffffffc0202de8:	72c80813          	addi	a6,a6,1836 # ffffffffc0216510 <check_rp>
ffffffffc0202dec:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202dee:	00013c97          	auipc	s9,0x13
ffffffffc0202df2:	6aac8c93          	addi	s9,s9,1706 # ffffffffc0216498 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202df6:	00004d97          	auipc	s11,0x4
ffffffffc0202dfa:	262d8d93          	addi	s11,s11,610 # ffffffffc0207058 <nbase>
ffffffffc0202dfe:	00013c17          	auipc	s8,0x13
ffffffffc0202e02:	70ac0c13          	addi	s8,s8,1802 # ffffffffc0216508 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202e06:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e0a:	4601                	li	a2,0
ffffffffc0202e0c:	85ea                	mv	a1,s10
ffffffffc0202e0e:	855a                	mv	a0,s6
ffffffffc0202e10:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202e12:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e14:	eb5fe0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc0202e18:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202e1a:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e1c:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202e1e:	1e050b63          	beqz	a0,ffffffffc0203014 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e22:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e24:	0017f613          	andi	a2,a5,1
ffffffffc0202e28:	18060a63          	beqz	a2,ffffffffc0202fbc <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202e2c:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e30:	078a                	slli	a5,a5,0x2
ffffffffc0202e32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e34:	14c7f863          	bleu	a2,a5,ffffffffc0202f84 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e38:	000db703          	ld	a4,0(s11)
ffffffffc0202e3c:	000c3603          	ld	a2,0(s8)
ffffffffc0202e40:	00083583          	ld	a1,0(a6)
ffffffffc0202e44:	8f99                	sub	a5,a5,a4
ffffffffc0202e46:	079a                	slli	a5,a5,0x6
ffffffffc0202e48:	e43a                	sd	a4,8(sp)
ffffffffc0202e4a:	97b2                	add	a5,a5,a2
ffffffffc0202e4c:	14f59863          	bne	a1,a5,ffffffffc0202f9c <swap_init+0x44c>
ffffffffc0202e50:	6785                	lui	a5,0x1
ffffffffc0202e52:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e54:	6795                	lui	a5,0x5
ffffffffc0202e56:	06a1                	addi	a3,a3,8
ffffffffc0202e58:	0821                	addi	a6,a6,8
ffffffffc0202e5a:	fafd16e3          	bne	s10,a5,ffffffffc0202e06 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e5e:	00003517          	auipc	a0,0x3
ffffffffc0202e62:	79250513          	addi	a0,a0,1938 # ffffffffc02065f0 <default_pmm_manager+0x940>
ffffffffc0202e66:	b28fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e6a:	00013797          	auipc	a5,0x13
ffffffffc0202e6e:	63678793          	addi	a5,a5,1590 # ffffffffc02164a0 <sm>
ffffffffc0202e72:	639c                	ld	a5,0(a5)
ffffffffc0202e74:	7f9c                	ld	a5,56(a5)
ffffffffc0202e76:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e78:	40051663          	bnez	a0,ffffffffc0203284 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202e7c:	77a2                	ld	a5,40(sp)
ffffffffc0202e7e:	00013717          	auipc	a4,0x13
ffffffffc0202e82:	66f72523          	sw	a5,1642(a4) # ffffffffc02164e8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e86:	67e2                	ld	a5,24(sp)
ffffffffc0202e88:	00013717          	auipc	a4,0x13
ffffffffc0202e8c:	64f73823          	sd	a5,1616(a4) # ffffffffc02164d8 <free_area>
ffffffffc0202e90:	7782                	ld	a5,32(sp)
ffffffffc0202e92:	00013717          	auipc	a4,0x13
ffffffffc0202e96:	64f73723          	sd	a5,1614(a4) # ffffffffc02164e0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e9a:	0009b503          	ld	a0,0(s3)
ffffffffc0202e9e:	4585                	li	a1,1
ffffffffc0202ea0:	09a1                	addi	s3,s3,8
ffffffffc0202ea2:	da1fe0ef          	jal	ra,ffffffffc0201c42 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ea6:	ff499ae3          	bne	s3,s4,ffffffffc0202e9a <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202eaa:	855e                	mv	a0,s7
ffffffffc0202eac:	359000ef          	jal	ra,ffffffffc0203a04 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202eb0:	00013797          	auipc	a5,0x13
ffffffffc0202eb4:	5e078793          	addi	a5,a5,1504 # ffffffffc0216490 <boot_pgdir>
ffffffffc0202eb8:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202eba:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ebe:	6394                	ld	a3,0(a5)
ffffffffc0202ec0:	068a                	slli	a3,a3,0x2
ffffffffc0202ec2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ec4:	0ce6f063          	bleu	a4,a3,ffffffffc0202f84 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ec8:	67a2                	ld	a5,8(sp)
ffffffffc0202eca:	000c3503          	ld	a0,0(s8)
ffffffffc0202ece:	8e9d                	sub	a3,a3,a5
ffffffffc0202ed0:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202ed2:	8699                	srai	a3,a3,0x6
ffffffffc0202ed4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202ed6:	57fd                	li	a5,-1
ffffffffc0202ed8:	83b1                	srli	a5,a5,0xc
ffffffffc0202eda:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202edc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ede:	2ee7f763          	bleu	a4,a5,ffffffffc02031cc <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202ee2:	00013797          	auipc	a5,0x13
ffffffffc0202ee6:	61678793          	addi	a5,a5,1558 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0202eea:	639c                	ld	a5,0(a5)
ffffffffc0202eec:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eee:	629c                	ld	a5,0(a3)
ffffffffc0202ef0:	078a                	slli	a5,a5,0x2
ffffffffc0202ef2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ef4:	08e7f863          	bleu	a4,a5,ffffffffc0202f84 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ef8:	69a2                	ld	s3,8(sp)
ffffffffc0202efa:	4585                	li	a1,1
ffffffffc0202efc:	413787b3          	sub	a5,a5,s3
ffffffffc0202f00:	079a                	slli	a5,a5,0x6
ffffffffc0202f02:	953e                	add	a0,a0,a5
ffffffffc0202f04:	d3ffe0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f08:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202f0c:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f10:	078a                	slli	a5,a5,0x2
ffffffffc0202f12:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f14:	06e7f863          	bleu	a4,a5,ffffffffc0202f84 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f18:	000c3503          	ld	a0,0(s8)
ffffffffc0202f1c:	413787b3          	sub	a5,a5,s3
ffffffffc0202f20:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202f22:	4585                	li	a1,1
ffffffffc0202f24:	953e                	add	a0,a0,a5
ffffffffc0202f26:	d1dfe0ef          	jal	ra,ffffffffc0201c42 <free_pages>
     pgdir[0] = 0;
ffffffffc0202f2a:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202f2e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202f32:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f34:	00878963          	beq	a5,s0,ffffffffc0202f46 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202f38:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f3c:	679c                	ld	a5,8(a5)
ffffffffc0202f3e:	397d                	addiw	s2,s2,-1
ffffffffc0202f40:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f42:	fe879be3          	bne	a5,s0,ffffffffc0202f38 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202f46:	28091f63          	bnez	s2,ffffffffc02031e4 <swap_init+0x694>
     assert(total==0);
ffffffffc0202f4a:	2a049d63          	bnez	s1,ffffffffc0203204 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f4e:	00003517          	auipc	a0,0x3
ffffffffc0202f52:	6f250513          	addi	a0,a0,1778 # ffffffffc0206640 <default_pmm_manager+0x990>
ffffffffc0202f56:	a38fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202f5a:	b199                	j	ffffffffc0202ba0 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202f5c:	4481                	li	s1,0
ffffffffc0202f5e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f60:	4981                	li	s3,0
ffffffffc0202f62:	b96d                	j	ffffffffc0202c1c <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205908 <commands+0x860>
ffffffffc0202f6c:	00003617          	auipc	a2,0x3
ffffffffc0202f70:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0205918 <commands+0x870>
ffffffffc0202f74:	0bd00593          	li	a1,189
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	46050513          	addi	a0,a0,1120 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0202f80:	cd0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f84:	00003617          	auipc	a2,0x3
ffffffffc0202f88:	ddc60613          	addi	a2,a2,-548 # ffffffffc0205d60 <default_pmm_manager+0xb0>
ffffffffc0202f8c:	06200593          	li	a1,98
ffffffffc0202f90:	00003517          	auipc	a0,0x3
ffffffffc0202f94:	d9850513          	addi	a0,a0,-616 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0202f98:	cb8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f9c:	00003697          	auipc	a3,0x3
ffffffffc0202fa0:	62c68693          	addi	a3,a3,1580 # ffffffffc02065c8 <default_pmm_manager+0x918>
ffffffffc0202fa4:	00003617          	auipc	a2,0x3
ffffffffc0202fa8:	97460613          	addi	a2,a2,-1676 # ffffffffc0205918 <commands+0x870>
ffffffffc0202fac:	0fd00593          	li	a1,253
ffffffffc0202fb0:	00003517          	auipc	a0,0x3
ffffffffc0202fb4:	42850513          	addi	a0,a0,1064 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0202fb8:	c98fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202fbc:	00003617          	auipc	a2,0x3
ffffffffc0202fc0:	fcc60613          	addi	a2,a2,-52 # ffffffffc0205f88 <default_pmm_manager+0x2d8>
ffffffffc0202fc4:	07400593          	li	a1,116
ffffffffc0202fc8:	00003517          	auipc	a0,0x3
ffffffffc0202fcc:	d6050513          	addi	a0,a0,-672 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0202fd0:	c80fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fd4:	00003697          	auipc	a3,0x3
ffffffffc0202fd8:	52c68693          	addi	a3,a3,1324 # ffffffffc0206500 <default_pmm_manager+0x850>
ffffffffc0202fdc:	00003617          	auipc	a2,0x3
ffffffffc0202fe0:	93c60613          	addi	a2,a2,-1732 # ffffffffc0205918 <commands+0x870>
ffffffffc0202fe4:	0de00593          	li	a1,222
ffffffffc0202fe8:	00003517          	auipc	a0,0x3
ffffffffc0202fec:	3f050513          	addi	a0,a0,1008 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0202ff0:	c60fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ff4:	00003697          	auipc	a3,0x3
ffffffffc0202ff8:	4f468693          	addi	a3,a3,1268 # ffffffffc02064e8 <default_pmm_manager+0x838>
ffffffffc0202ffc:	00003617          	auipc	a2,0x3
ffffffffc0203000:	91c60613          	addi	a2,a2,-1764 # ffffffffc0205918 <commands+0x870>
ffffffffc0203004:	0dd00593          	li	a1,221
ffffffffc0203008:	00003517          	auipc	a0,0x3
ffffffffc020300c:	3d050513          	addi	a0,a0,976 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203010:	c40fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203014:	00003697          	auipc	a3,0x3
ffffffffc0203018:	59c68693          	addi	a3,a3,1436 # ffffffffc02065b0 <default_pmm_manager+0x900>
ffffffffc020301c:	00003617          	auipc	a2,0x3
ffffffffc0203020:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0205918 <commands+0x870>
ffffffffc0203024:	0fc00593          	li	a1,252
ffffffffc0203028:	00003517          	auipc	a0,0x3
ffffffffc020302c:	3b050513          	addi	a0,a0,944 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203030:	c20fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203034:	00003617          	auipc	a2,0x3
ffffffffc0203038:	38460613          	addi	a2,a2,900 # ffffffffc02063b8 <default_pmm_manager+0x708>
ffffffffc020303c:	02a00593          	li	a1,42
ffffffffc0203040:	00003517          	auipc	a0,0x3
ffffffffc0203044:	39850513          	addi	a0,a0,920 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203048:	c08fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc020304c:	00003697          	auipc	a3,0x3
ffffffffc0203050:	53468693          	addi	a3,a3,1332 # ffffffffc0206580 <default_pmm_manager+0x8d0>
ffffffffc0203054:	00003617          	auipc	a2,0x3
ffffffffc0203058:	8c460613          	addi	a2,a2,-1852 # ffffffffc0205918 <commands+0x870>
ffffffffc020305c:	09800593          	li	a1,152
ffffffffc0203060:	00003517          	auipc	a0,0x3
ffffffffc0203064:	37850513          	addi	a0,a0,888 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203068:	be8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc020306c:	00003697          	auipc	a3,0x3
ffffffffc0203070:	51468693          	addi	a3,a3,1300 # ffffffffc0206580 <default_pmm_manager+0x8d0>
ffffffffc0203074:	00003617          	auipc	a2,0x3
ffffffffc0203078:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205918 <commands+0x870>
ffffffffc020307c:	09a00593          	li	a1,154
ffffffffc0203080:	00003517          	auipc	a0,0x3
ffffffffc0203084:	35850513          	addi	a0,a0,856 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203088:	bc8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc020308c:	00003697          	auipc	a3,0x3
ffffffffc0203090:	50468693          	addi	a3,a3,1284 # ffffffffc0206590 <default_pmm_manager+0x8e0>
ffffffffc0203094:	00003617          	auipc	a2,0x3
ffffffffc0203098:	88460613          	addi	a2,a2,-1916 # ffffffffc0205918 <commands+0x870>
ffffffffc020309c:	09c00593          	li	a1,156
ffffffffc02030a0:	00003517          	auipc	a0,0x3
ffffffffc02030a4:	33850513          	addi	a0,a0,824 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02030a8:	ba8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc02030ac:	00003697          	auipc	a3,0x3
ffffffffc02030b0:	4e468693          	addi	a3,a3,1252 # ffffffffc0206590 <default_pmm_manager+0x8e0>
ffffffffc02030b4:	00003617          	auipc	a2,0x3
ffffffffc02030b8:	86460613          	addi	a2,a2,-1948 # ffffffffc0205918 <commands+0x870>
ffffffffc02030bc:	09e00593          	li	a1,158
ffffffffc02030c0:	00003517          	auipc	a0,0x3
ffffffffc02030c4:	31850513          	addi	a0,a0,792 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02030c8:	b88fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030cc:	00003697          	auipc	a3,0x3
ffffffffc02030d0:	4a468693          	addi	a3,a3,1188 # ffffffffc0206570 <default_pmm_manager+0x8c0>
ffffffffc02030d4:	00003617          	auipc	a2,0x3
ffffffffc02030d8:	84460613          	addi	a2,a2,-1980 # ffffffffc0205918 <commands+0x870>
ffffffffc02030dc:	09400593          	li	a1,148
ffffffffc02030e0:	00003517          	auipc	a0,0x3
ffffffffc02030e4:	2f850513          	addi	a0,a0,760 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02030e8:	b68fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030ec:	00003697          	auipc	a3,0x3
ffffffffc02030f0:	48468693          	addi	a3,a3,1156 # ffffffffc0206570 <default_pmm_manager+0x8c0>
ffffffffc02030f4:	00003617          	auipc	a2,0x3
ffffffffc02030f8:	82460613          	addi	a2,a2,-2012 # ffffffffc0205918 <commands+0x870>
ffffffffc02030fc:	09600593          	li	a1,150
ffffffffc0203100:	00003517          	auipc	a0,0x3
ffffffffc0203104:	2d850513          	addi	a0,a0,728 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203108:	b48fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc020310c:	00003697          	auipc	a3,0x3
ffffffffc0203110:	49468693          	addi	a3,a3,1172 # ffffffffc02065a0 <default_pmm_manager+0x8f0>
ffffffffc0203114:	00003617          	auipc	a2,0x3
ffffffffc0203118:	80460613          	addi	a2,a2,-2044 # ffffffffc0205918 <commands+0x870>
ffffffffc020311c:	0a000593          	li	a1,160
ffffffffc0203120:	00003517          	auipc	a0,0x3
ffffffffc0203124:	2b850513          	addi	a0,a0,696 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203128:	b28fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc020312c:	00003697          	auipc	a3,0x3
ffffffffc0203130:	47468693          	addi	a3,a3,1140 # ffffffffc02065a0 <default_pmm_manager+0x8f0>
ffffffffc0203134:	00002617          	auipc	a2,0x2
ffffffffc0203138:	7e460613          	addi	a2,a2,2020 # ffffffffc0205918 <commands+0x870>
ffffffffc020313c:	0a200593          	li	a1,162
ffffffffc0203140:	00003517          	auipc	a0,0x3
ffffffffc0203144:	29850513          	addi	a0,a0,664 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203148:	b08fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgdir[0] == 0);
ffffffffc020314c:	00003697          	auipc	a3,0x3
ffffffffc0203150:	30468693          	addi	a3,a3,772 # ffffffffc0206450 <default_pmm_manager+0x7a0>
ffffffffc0203154:	00002617          	auipc	a2,0x2
ffffffffc0203158:	7c460613          	addi	a2,a2,1988 # ffffffffc0205918 <commands+0x870>
ffffffffc020315c:	0cd00593          	li	a1,205
ffffffffc0203160:	00003517          	auipc	a0,0x3
ffffffffc0203164:	27850513          	addi	a0,a0,632 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203168:	ae8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(vma != NULL);
ffffffffc020316c:	00003697          	auipc	a3,0x3
ffffffffc0203170:	2f468693          	addi	a3,a3,756 # ffffffffc0206460 <default_pmm_manager+0x7b0>
ffffffffc0203174:	00002617          	auipc	a2,0x2
ffffffffc0203178:	7a460613          	addi	a2,a2,1956 # ffffffffc0205918 <commands+0x870>
ffffffffc020317c:	0d000593          	li	a1,208
ffffffffc0203180:	00003517          	auipc	a0,0x3
ffffffffc0203184:	25850513          	addi	a0,a0,600 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203188:	ac8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020318c:	00003697          	auipc	a3,0x3
ffffffffc0203190:	31c68693          	addi	a3,a3,796 # ffffffffc02064a8 <default_pmm_manager+0x7f8>
ffffffffc0203194:	00002617          	auipc	a2,0x2
ffffffffc0203198:	78460613          	addi	a2,a2,1924 # ffffffffc0205918 <commands+0x870>
ffffffffc020319c:	0d800593          	li	a1,216
ffffffffc02031a0:	00003517          	auipc	a0,0x3
ffffffffc02031a4:	23850513          	addi	a0,a0,568 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02031a8:	aa8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert( nr_free == 0);         
ffffffffc02031ac:	00003697          	auipc	a3,0x3
ffffffffc02031b0:	94468693          	addi	a3,a3,-1724 # ffffffffc0205af0 <commands+0xa48>
ffffffffc02031b4:	00002617          	auipc	a2,0x2
ffffffffc02031b8:	76460613          	addi	a2,a2,1892 # ffffffffc0205918 <commands+0x870>
ffffffffc02031bc:	0f400593          	li	a1,244
ffffffffc02031c0:	00003517          	auipc	a0,0x3
ffffffffc02031c4:	21850513          	addi	a0,a0,536 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02031c8:	a88fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031cc:	00003617          	auipc	a2,0x3
ffffffffc02031d0:	b3460613          	addi	a2,a2,-1228 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc02031d4:	06900593          	li	a1,105
ffffffffc02031d8:	00003517          	auipc	a0,0x3
ffffffffc02031dc:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc02031e0:	a70fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(count==0);
ffffffffc02031e4:	00003697          	auipc	a3,0x3
ffffffffc02031e8:	43c68693          	addi	a3,a3,1084 # ffffffffc0206620 <default_pmm_manager+0x970>
ffffffffc02031ec:	00002617          	auipc	a2,0x2
ffffffffc02031f0:	72c60613          	addi	a2,a2,1836 # ffffffffc0205918 <commands+0x870>
ffffffffc02031f4:	11c00593          	li	a1,284
ffffffffc02031f8:	00003517          	auipc	a0,0x3
ffffffffc02031fc:	1e050513          	addi	a0,a0,480 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203200:	a50fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total==0);
ffffffffc0203204:	00003697          	auipc	a3,0x3
ffffffffc0203208:	42c68693          	addi	a3,a3,1068 # ffffffffc0206630 <default_pmm_manager+0x980>
ffffffffc020320c:	00002617          	auipc	a2,0x2
ffffffffc0203210:	70c60613          	addi	a2,a2,1804 # ffffffffc0205918 <commands+0x870>
ffffffffc0203214:	11d00593          	li	a1,285
ffffffffc0203218:	00003517          	auipc	a0,0x3
ffffffffc020321c:	1c050513          	addi	a0,a0,448 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203220:	a30fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203224:	00003697          	auipc	a3,0x3
ffffffffc0203228:	2fc68693          	addi	a3,a3,764 # ffffffffc0206520 <default_pmm_manager+0x870>
ffffffffc020322c:	00002617          	auipc	a2,0x2
ffffffffc0203230:	6ec60613          	addi	a2,a2,1772 # ffffffffc0205918 <commands+0x870>
ffffffffc0203234:	0eb00593          	li	a1,235
ffffffffc0203238:	00003517          	auipc	a0,0x3
ffffffffc020323c:	1a050513          	addi	a0,a0,416 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203240:	a10fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(mm != NULL);
ffffffffc0203244:	00003697          	auipc	a3,0x3
ffffffffc0203248:	1e468693          	addi	a3,a3,484 # ffffffffc0206428 <default_pmm_manager+0x778>
ffffffffc020324c:	00002617          	auipc	a2,0x2
ffffffffc0203250:	6cc60613          	addi	a2,a2,1740 # ffffffffc0205918 <commands+0x870>
ffffffffc0203254:	0c500593          	li	a1,197
ffffffffc0203258:	00003517          	auipc	a0,0x3
ffffffffc020325c:	18050513          	addi	a0,a0,384 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203260:	9f0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203264:	00003697          	auipc	a3,0x3
ffffffffc0203268:	1d468693          	addi	a3,a3,468 # ffffffffc0206438 <default_pmm_manager+0x788>
ffffffffc020326c:	00002617          	auipc	a2,0x2
ffffffffc0203270:	6ac60613          	addi	a2,a2,1708 # ffffffffc0205918 <commands+0x870>
ffffffffc0203274:	0c800593          	li	a1,200
ffffffffc0203278:	00003517          	auipc	a0,0x3
ffffffffc020327c:	16050513          	addi	a0,a0,352 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc0203280:	9d0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(ret==0);
ffffffffc0203284:	00003697          	auipc	a3,0x3
ffffffffc0203288:	39468693          	addi	a3,a3,916 # ffffffffc0206618 <default_pmm_manager+0x968>
ffffffffc020328c:	00002617          	auipc	a2,0x2
ffffffffc0203290:	68c60613          	addi	a2,a2,1676 # ffffffffc0205918 <commands+0x870>
ffffffffc0203294:	10300593          	li	a1,259
ffffffffc0203298:	00003517          	auipc	a0,0x3
ffffffffc020329c:	14050513          	addi	a0,a0,320 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02032a0:	9b0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total == nr_free_pages());
ffffffffc02032a4:	00002697          	auipc	a3,0x2
ffffffffc02032a8:	6a468693          	addi	a3,a3,1700 # ffffffffc0205948 <commands+0x8a0>
ffffffffc02032ac:	00002617          	auipc	a2,0x2
ffffffffc02032b0:	66c60613          	addi	a2,a2,1644 # ffffffffc0205918 <commands+0x870>
ffffffffc02032b4:	0c000593          	li	a1,192
ffffffffc02032b8:	00003517          	auipc	a0,0x3
ffffffffc02032bc:	12050513          	addi	a0,a0,288 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02032c0:	990fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02032c4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02032c4:	00013797          	auipc	a5,0x13
ffffffffc02032c8:	1dc78793          	addi	a5,a5,476 # ffffffffc02164a0 <sm>
ffffffffc02032cc:	639c                	ld	a5,0(a5)
ffffffffc02032ce:	0107b303          	ld	t1,16(a5)
ffffffffc02032d2:	8302                	jr	t1

ffffffffc02032d4 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02032d4:	00013797          	auipc	a5,0x13
ffffffffc02032d8:	1cc78793          	addi	a5,a5,460 # ffffffffc02164a0 <sm>
ffffffffc02032dc:	639c                	ld	a5,0(a5)
ffffffffc02032de:	0207b303          	ld	t1,32(a5)
ffffffffc02032e2:	8302                	jr	t1

ffffffffc02032e4 <swap_out>:
{
ffffffffc02032e4:	711d                	addi	sp,sp,-96
ffffffffc02032e6:	ec86                	sd	ra,88(sp)
ffffffffc02032e8:	e8a2                	sd	s0,80(sp)
ffffffffc02032ea:	e4a6                	sd	s1,72(sp)
ffffffffc02032ec:	e0ca                	sd	s2,64(sp)
ffffffffc02032ee:	fc4e                	sd	s3,56(sp)
ffffffffc02032f0:	f852                	sd	s4,48(sp)
ffffffffc02032f2:	f456                	sd	s5,40(sp)
ffffffffc02032f4:	f05a                	sd	s6,32(sp)
ffffffffc02032f6:	ec5e                	sd	s7,24(sp)
ffffffffc02032f8:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032fa:	cde9                	beqz	a1,ffffffffc02033d4 <swap_out+0xf0>
ffffffffc02032fc:	8ab2                	mv	s5,a2
ffffffffc02032fe:	892a                	mv	s2,a0
ffffffffc0203300:	8a2e                	mv	s4,a1
ffffffffc0203302:	4401                	li	s0,0
ffffffffc0203304:	00013997          	auipc	s3,0x13
ffffffffc0203308:	19c98993          	addi	s3,s3,412 # ffffffffc02164a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020330c:	00003b17          	auipc	s6,0x3
ffffffffc0203310:	3b4b0b13          	addi	s6,s6,948 # ffffffffc02066c0 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203314:	00003b97          	auipc	s7,0x3
ffffffffc0203318:	394b8b93          	addi	s7,s7,916 # ffffffffc02066a8 <default_pmm_manager+0x9f8>
ffffffffc020331c:	a825                	j	ffffffffc0203354 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020331e:	67a2                	ld	a5,8(sp)
ffffffffc0203320:	8626                	mv	a2,s1
ffffffffc0203322:	85a2                	mv	a1,s0
ffffffffc0203324:	7f94                	ld	a3,56(a5)
ffffffffc0203326:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203328:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020332a:	82b1                	srli	a3,a3,0xc
ffffffffc020332c:	0685                	addi	a3,a3,1
ffffffffc020332e:	e61fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203332:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203334:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203336:	7d1c                	ld	a5,56(a0)
ffffffffc0203338:	83b1                	srli	a5,a5,0xc
ffffffffc020333a:	0785                	addi	a5,a5,1
ffffffffc020333c:	07a2                	slli	a5,a5,0x8
ffffffffc020333e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203342:	901fe0ef          	jal	ra,ffffffffc0201c42 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203346:	01893503          	ld	a0,24(s2)
ffffffffc020334a:	85a6                	mv	a1,s1
ffffffffc020334c:	f6cff0ef          	jal	ra,ffffffffc0202ab8 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203350:	048a0d63          	beq	s4,s0,ffffffffc02033aa <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203354:	0009b783          	ld	a5,0(s3)
ffffffffc0203358:	8656                	mv	a2,s5
ffffffffc020335a:	002c                	addi	a1,sp,8
ffffffffc020335c:	7b9c                	ld	a5,48(a5)
ffffffffc020335e:	854a                	mv	a0,s2
ffffffffc0203360:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203362:	e12d                	bnez	a0,ffffffffc02033c4 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203364:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203366:	01893503          	ld	a0,24(s2)
ffffffffc020336a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020336c:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020336e:	85a6                	mv	a1,s1
ffffffffc0203370:	959fe0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203374:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203376:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203378:	8b85                	andi	a5,a5,1
ffffffffc020337a:	cfb9                	beqz	a5,ffffffffc02033d8 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020337c:	65a2                	ld	a1,8(sp)
ffffffffc020337e:	7d9c                	ld	a5,56(a1)
ffffffffc0203380:	83b1                	srli	a5,a5,0xc
ffffffffc0203382:	00178513          	addi	a0,a5,1
ffffffffc0203386:	0522                	slli	a0,a0,0x8
ffffffffc0203388:	5a7000ef          	jal	ra,ffffffffc020412e <swapfs_write>
ffffffffc020338c:	d949                	beqz	a0,ffffffffc020331e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020338e:	855e                	mv	a0,s7
ffffffffc0203390:	dfffc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203394:	0009b783          	ld	a5,0(s3)
ffffffffc0203398:	6622                	ld	a2,8(sp)
ffffffffc020339a:	4681                	li	a3,0
ffffffffc020339c:	739c                	ld	a5,32(a5)
ffffffffc020339e:	85a6                	mv	a1,s1
ffffffffc02033a0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02033a2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02033a4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02033a6:	fa8a17e3          	bne	s4,s0,ffffffffc0203354 <swap_out+0x70>
}
ffffffffc02033aa:	8522                	mv	a0,s0
ffffffffc02033ac:	60e6                	ld	ra,88(sp)
ffffffffc02033ae:	6446                	ld	s0,80(sp)
ffffffffc02033b0:	64a6                	ld	s1,72(sp)
ffffffffc02033b2:	6906                	ld	s2,64(sp)
ffffffffc02033b4:	79e2                	ld	s3,56(sp)
ffffffffc02033b6:	7a42                	ld	s4,48(sp)
ffffffffc02033b8:	7aa2                	ld	s5,40(sp)
ffffffffc02033ba:	7b02                	ld	s6,32(sp)
ffffffffc02033bc:	6be2                	ld	s7,24(sp)
ffffffffc02033be:	6c42                	ld	s8,16(sp)
ffffffffc02033c0:	6125                	addi	sp,sp,96
ffffffffc02033c2:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02033c4:	85a2                	mv	a1,s0
ffffffffc02033c6:	00003517          	auipc	a0,0x3
ffffffffc02033ca:	29a50513          	addi	a0,a0,666 # ffffffffc0206660 <default_pmm_manager+0x9b0>
ffffffffc02033ce:	dc1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc02033d2:	bfe1                	j	ffffffffc02033aa <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02033d4:	4401                	li	s0,0
ffffffffc02033d6:	bfd1                	j	ffffffffc02033aa <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02033d8:	00003697          	auipc	a3,0x3
ffffffffc02033dc:	2b868693          	addi	a3,a3,696 # ffffffffc0206690 <default_pmm_manager+0x9e0>
ffffffffc02033e0:	00002617          	auipc	a2,0x2
ffffffffc02033e4:	53860613          	addi	a2,a2,1336 # ffffffffc0205918 <commands+0x870>
ffffffffc02033e8:	06900593          	li	a1,105
ffffffffc02033ec:	00003517          	auipc	a0,0x3
ffffffffc02033f0:	fec50513          	addi	a0,a0,-20 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc02033f4:	85cfd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02033f8 <swap_in>:
{
ffffffffc02033f8:	7179                	addi	sp,sp,-48
ffffffffc02033fa:	e84a                	sd	s2,16(sp)
ffffffffc02033fc:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02033fe:	4505                	li	a0,1
{
ffffffffc0203400:	ec26                	sd	s1,24(sp)
ffffffffc0203402:	e44e                	sd	s3,8(sp)
ffffffffc0203404:	f406                	sd	ra,40(sp)
ffffffffc0203406:	f022                	sd	s0,32(sp)
ffffffffc0203408:	84ae                	mv	s1,a1
ffffffffc020340a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020340c:	faefe0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
     assert(result!=NULL);
ffffffffc0203410:	c129                	beqz	a0,ffffffffc0203452 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203412:	842a                	mv	s0,a0
ffffffffc0203414:	01893503          	ld	a0,24(s2)
ffffffffc0203418:	4601                	li	a2,0
ffffffffc020341a:	85a6                	mv	a1,s1
ffffffffc020341c:	8adfe0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc0203420:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203422:	6108                	ld	a0,0(a0)
ffffffffc0203424:	85a2                	mv	a1,s0
ffffffffc0203426:	471000ef          	jal	ra,ffffffffc0204096 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020342a:	00093583          	ld	a1,0(s2)
ffffffffc020342e:	8626                	mv	a2,s1
ffffffffc0203430:	00003517          	auipc	a0,0x3
ffffffffc0203434:	f4850513          	addi	a0,a0,-184 # ffffffffc0206378 <default_pmm_manager+0x6c8>
ffffffffc0203438:	81a1                	srli	a1,a1,0x8
ffffffffc020343a:	d55fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020343e:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203440:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203444:	7402                	ld	s0,32(sp)
ffffffffc0203446:	64e2                	ld	s1,24(sp)
ffffffffc0203448:	6942                	ld	s2,16(sp)
ffffffffc020344a:	69a2                	ld	s3,8(sp)
ffffffffc020344c:	4501                	li	a0,0
ffffffffc020344e:	6145                	addi	sp,sp,48
ffffffffc0203450:	8082                	ret
     assert(result!=NULL);
ffffffffc0203452:	00003697          	auipc	a3,0x3
ffffffffc0203456:	f1668693          	addi	a3,a3,-234 # ffffffffc0206368 <default_pmm_manager+0x6b8>
ffffffffc020345a:	00002617          	auipc	a2,0x2
ffffffffc020345e:	4be60613          	addi	a2,a2,1214 # ffffffffc0205918 <commands+0x870>
ffffffffc0203462:	07f00593          	li	a1,127
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	f7250513          	addi	a0,a0,-142 # ffffffffc02063d8 <default_pmm_manager+0x728>
ffffffffc020346e:	fe3fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203472 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203472:	00013797          	auipc	a5,0x13
ffffffffc0203476:	16678793          	addi	a5,a5,358 # ffffffffc02165d8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020347a:	f51c                	sd	a5,40(a0)
ffffffffc020347c:	e79c                	sd	a5,8(a5)
ffffffffc020347e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203480:	4501                	li	a0,0
ffffffffc0203482:	8082                	ret

ffffffffc0203484 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203484:	4501                	li	a0,0
ffffffffc0203486:	8082                	ret

ffffffffc0203488 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203488:	4501                	li	a0,0
ffffffffc020348a:	8082                	ret

ffffffffc020348c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020348c:	4501                	li	a0,0
ffffffffc020348e:	8082                	ret

ffffffffc0203490 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203490:	711d                	addi	sp,sp,-96
ffffffffc0203492:	fc4e                	sd	s3,56(sp)
ffffffffc0203494:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203496:	00003517          	auipc	a0,0x3
ffffffffc020349a:	26a50513          	addi	a0,a0,618 # ffffffffc0206700 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020349e:	698d                	lui	s3,0x3
ffffffffc02034a0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02034a2:	e8a2                	sd	s0,80(sp)
ffffffffc02034a4:	e4a6                	sd	s1,72(sp)
ffffffffc02034a6:	ec86                	sd	ra,88(sp)
ffffffffc02034a8:	e0ca                	sd	s2,64(sp)
ffffffffc02034aa:	f456                	sd	s5,40(sp)
ffffffffc02034ac:	f05a                	sd	s6,32(sp)
ffffffffc02034ae:	ec5e                	sd	s7,24(sp)
ffffffffc02034b0:	e862                	sd	s8,16(sp)
ffffffffc02034b2:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02034b4:	00013417          	auipc	s0,0x13
ffffffffc02034b8:	ff840413          	addi	s0,s0,-8 # ffffffffc02164ac <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034bc:	cd3fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034c0:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02034c4:	4004                	lw	s1,0(s0)
ffffffffc02034c6:	4791                	li	a5,4
ffffffffc02034c8:	2481                	sext.w	s1,s1
ffffffffc02034ca:	14f49963          	bne	s1,a5,ffffffffc020361c <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034ce:	00003517          	auipc	a0,0x3
ffffffffc02034d2:	27250513          	addi	a0,a0,626 # ffffffffc0206740 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034d6:	6a85                	lui	s5,0x1
ffffffffc02034d8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034da:	cb5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034de:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02034e2:	00042903          	lw	s2,0(s0)
ffffffffc02034e6:	2901                	sext.w	s2,s2
ffffffffc02034e8:	2a991a63          	bne	s2,s1,ffffffffc020379c <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034ec:	00003517          	auipc	a0,0x3
ffffffffc02034f0:	27c50513          	addi	a0,a0,636 # ffffffffc0206768 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034f4:	6b91                	lui	s7,0x4
ffffffffc02034f6:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034f8:	c97fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034fc:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203500:	4004                	lw	s1,0(s0)
ffffffffc0203502:	2481                	sext.w	s1,s1
ffffffffc0203504:	27249c63          	bne	s1,s2,ffffffffc020377c <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203508:	00003517          	auipc	a0,0x3
ffffffffc020350c:	28850513          	addi	a0,a0,648 # ffffffffc0206790 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203510:	6909                	lui	s2,0x2
ffffffffc0203512:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203514:	c7bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203518:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020351c:	401c                	lw	a5,0(s0)
ffffffffc020351e:	2781                	sext.w	a5,a5
ffffffffc0203520:	22979e63          	bne	a5,s1,ffffffffc020375c <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203524:	00003517          	auipc	a0,0x3
ffffffffc0203528:	29450513          	addi	a0,a0,660 # ffffffffc02067b8 <default_pmm_manager+0xb08>
ffffffffc020352c:	c63fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203530:	6795                	lui	a5,0x5
ffffffffc0203532:	4739                	li	a4,14
ffffffffc0203534:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203538:	4004                	lw	s1,0(s0)
ffffffffc020353a:	4795                	li	a5,5
ffffffffc020353c:	2481                	sext.w	s1,s1
ffffffffc020353e:	1ef49f63          	bne	s1,a5,ffffffffc020373c <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203542:	00003517          	auipc	a0,0x3
ffffffffc0203546:	24e50513          	addi	a0,a0,590 # ffffffffc0206790 <default_pmm_manager+0xae0>
ffffffffc020354a:	c45fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020354e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203552:	401c                	lw	a5,0(s0)
ffffffffc0203554:	2781                	sext.w	a5,a5
ffffffffc0203556:	1c979363          	bne	a5,s1,ffffffffc020371c <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020355a:	00003517          	auipc	a0,0x3
ffffffffc020355e:	1e650513          	addi	a0,a0,486 # ffffffffc0206740 <default_pmm_manager+0xa90>
ffffffffc0203562:	c2dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203566:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020356a:	401c                	lw	a5,0(s0)
ffffffffc020356c:	4719                	li	a4,6
ffffffffc020356e:	2781                	sext.w	a5,a5
ffffffffc0203570:	18e79663          	bne	a5,a4,ffffffffc02036fc <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203574:	00003517          	auipc	a0,0x3
ffffffffc0203578:	21c50513          	addi	a0,a0,540 # ffffffffc0206790 <default_pmm_manager+0xae0>
ffffffffc020357c:	c13fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203580:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203584:	401c                	lw	a5,0(s0)
ffffffffc0203586:	471d                	li	a4,7
ffffffffc0203588:	2781                	sext.w	a5,a5
ffffffffc020358a:	14e79963          	bne	a5,a4,ffffffffc02036dc <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020358e:	00003517          	auipc	a0,0x3
ffffffffc0203592:	17250513          	addi	a0,a0,370 # ffffffffc0206700 <default_pmm_manager+0xa50>
ffffffffc0203596:	bf9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020359a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020359e:	401c                	lw	a5,0(s0)
ffffffffc02035a0:	4721                	li	a4,8
ffffffffc02035a2:	2781                	sext.w	a5,a5
ffffffffc02035a4:	10e79c63          	bne	a5,a4,ffffffffc02036bc <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035a8:	00003517          	auipc	a0,0x3
ffffffffc02035ac:	1c050513          	addi	a0,a0,448 # ffffffffc0206768 <default_pmm_manager+0xab8>
ffffffffc02035b0:	bdffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035b4:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02035b8:	401c                	lw	a5,0(s0)
ffffffffc02035ba:	4725                	li	a4,9
ffffffffc02035bc:	2781                	sext.w	a5,a5
ffffffffc02035be:	0ce79f63          	bne	a5,a4,ffffffffc020369c <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02035c2:	00003517          	auipc	a0,0x3
ffffffffc02035c6:	1f650513          	addi	a0,a0,502 # ffffffffc02067b8 <default_pmm_manager+0xb08>
ffffffffc02035ca:	bc5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02035ce:	6795                	lui	a5,0x5
ffffffffc02035d0:	4739                	li	a4,14
ffffffffc02035d2:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02035d6:	4004                	lw	s1,0(s0)
ffffffffc02035d8:	47a9                	li	a5,10
ffffffffc02035da:	2481                	sext.w	s1,s1
ffffffffc02035dc:	0af49063          	bne	s1,a5,ffffffffc020367c <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035e0:	00003517          	auipc	a0,0x3
ffffffffc02035e4:	16050513          	addi	a0,a0,352 # ffffffffc0206740 <default_pmm_manager+0xa90>
ffffffffc02035e8:	ba7fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035ec:	6785                	lui	a5,0x1
ffffffffc02035ee:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02035f2:	06979563          	bne	a5,s1,ffffffffc020365c <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc02035f6:	401c                	lw	a5,0(s0)
ffffffffc02035f8:	472d                	li	a4,11
ffffffffc02035fa:	2781                	sext.w	a5,a5
ffffffffc02035fc:	04e79063          	bne	a5,a4,ffffffffc020363c <_fifo_check_swap+0x1ac>
}
ffffffffc0203600:	60e6                	ld	ra,88(sp)
ffffffffc0203602:	6446                	ld	s0,80(sp)
ffffffffc0203604:	64a6                	ld	s1,72(sp)
ffffffffc0203606:	6906                	ld	s2,64(sp)
ffffffffc0203608:	79e2                	ld	s3,56(sp)
ffffffffc020360a:	7a42                	ld	s4,48(sp)
ffffffffc020360c:	7aa2                	ld	s5,40(sp)
ffffffffc020360e:	7b02                	ld	s6,32(sp)
ffffffffc0203610:	6be2                	ld	s7,24(sp)
ffffffffc0203612:	6c42                	ld	s8,16(sp)
ffffffffc0203614:	6ca2                	ld	s9,8(sp)
ffffffffc0203616:	4501                	li	a0,0
ffffffffc0203618:	6125                	addi	sp,sp,96
ffffffffc020361a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020361c:	00003697          	auipc	a3,0x3
ffffffffc0203620:	f8468693          	addi	a3,a3,-124 # ffffffffc02065a0 <default_pmm_manager+0x8f0>
ffffffffc0203624:	00002617          	auipc	a2,0x2
ffffffffc0203628:	2f460613          	addi	a2,a2,756 # ffffffffc0205918 <commands+0x870>
ffffffffc020362c:	05100593          	li	a1,81
ffffffffc0203630:	00003517          	auipc	a0,0x3
ffffffffc0203634:	0f850513          	addi	a0,a0,248 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203638:	e19fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==11);
ffffffffc020363c:	00003697          	auipc	a3,0x3
ffffffffc0203640:	22c68693          	addi	a3,a3,556 # ffffffffc0206868 <default_pmm_manager+0xbb8>
ffffffffc0203644:	00002617          	auipc	a2,0x2
ffffffffc0203648:	2d460613          	addi	a2,a2,724 # ffffffffc0205918 <commands+0x870>
ffffffffc020364c:	07300593          	li	a1,115
ffffffffc0203650:	00003517          	auipc	a0,0x3
ffffffffc0203654:	0d850513          	addi	a0,a0,216 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203658:	df9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020365c:	00003697          	auipc	a3,0x3
ffffffffc0203660:	1e468693          	addi	a3,a3,484 # ffffffffc0206840 <default_pmm_manager+0xb90>
ffffffffc0203664:	00002617          	auipc	a2,0x2
ffffffffc0203668:	2b460613          	addi	a2,a2,692 # ffffffffc0205918 <commands+0x870>
ffffffffc020366c:	07100593          	li	a1,113
ffffffffc0203670:	00003517          	auipc	a0,0x3
ffffffffc0203674:	0b850513          	addi	a0,a0,184 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203678:	dd9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==10);
ffffffffc020367c:	00003697          	auipc	a3,0x3
ffffffffc0203680:	1b468693          	addi	a3,a3,436 # ffffffffc0206830 <default_pmm_manager+0xb80>
ffffffffc0203684:	00002617          	auipc	a2,0x2
ffffffffc0203688:	29460613          	addi	a2,a2,660 # ffffffffc0205918 <commands+0x870>
ffffffffc020368c:	06f00593          	li	a1,111
ffffffffc0203690:	00003517          	auipc	a0,0x3
ffffffffc0203694:	09850513          	addi	a0,a0,152 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203698:	db9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==9);
ffffffffc020369c:	00003697          	auipc	a3,0x3
ffffffffc02036a0:	18468693          	addi	a3,a3,388 # ffffffffc0206820 <default_pmm_manager+0xb70>
ffffffffc02036a4:	00002617          	auipc	a2,0x2
ffffffffc02036a8:	27460613          	addi	a2,a2,628 # ffffffffc0205918 <commands+0x870>
ffffffffc02036ac:	06c00593          	li	a1,108
ffffffffc02036b0:	00003517          	auipc	a0,0x3
ffffffffc02036b4:	07850513          	addi	a0,a0,120 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc02036b8:	d99fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==8);
ffffffffc02036bc:	00003697          	auipc	a3,0x3
ffffffffc02036c0:	15468693          	addi	a3,a3,340 # ffffffffc0206810 <default_pmm_manager+0xb60>
ffffffffc02036c4:	00002617          	auipc	a2,0x2
ffffffffc02036c8:	25460613          	addi	a2,a2,596 # ffffffffc0205918 <commands+0x870>
ffffffffc02036cc:	06900593          	li	a1,105
ffffffffc02036d0:	00003517          	auipc	a0,0x3
ffffffffc02036d4:	05850513          	addi	a0,a0,88 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc02036d8:	d79fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==7);
ffffffffc02036dc:	00003697          	auipc	a3,0x3
ffffffffc02036e0:	12468693          	addi	a3,a3,292 # ffffffffc0206800 <default_pmm_manager+0xb50>
ffffffffc02036e4:	00002617          	auipc	a2,0x2
ffffffffc02036e8:	23460613          	addi	a2,a2,564 # ffffffffc0205918 <commands+0x870>
ffffffffc02036ec:	06600593          	li	a1,102
ffffffffc02036f0:	00003517          	auipc	a0,0x3
ffffffffc02036f4:	03850513          	addi	a0,a0,56 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc02036f8:	d59fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==6);
ffffffffc02036fc:	00003697          	auipc	a3,0x3
ffffffffc0203700:	0f468693          	addi	a3,a3,244 # ffffffffc02067f0 <default_pmm_manager+0xb40>
ffffffffc0203704:	00002617          	auipc	a2,0x2
ffffffffc0203708:	21460613          	addi	a2,a2,532 # ffffffffc0205918 <commands+0x870>
ffffffffc020370c:	06300593          	li	a1,99
ffffffffc0203710:	00003517          	auipc	a0,0x3
ffffffffc0203714:	01850513          	addi	a0,a0,24 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203718:	d39fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc020371c:	00003697          	auipc	a3,0x3
ffffffffc0203720:	0c468693          	addi	a3,a3,196 # ffffffffc02067e0 <default_pmm_manager+0xb30>
ffffffffc0203724:	00002617          	auipc	a2,0x2
ffffffffc0203728:	1f460613          	addi	a2,a2,500 # ffffffffc0205918 <commands+0x870>
ffffffffc020372c:	06000593          	li	a1,96
ffffffffc0203730:	00003517          	auipc	a0,0x3
ffffffffc0203734:	ff850513          	addi	a0,a0,-8 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203738:	d19fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc020373c:	00003697          	auipc	a3,0x3
ffffffffc0203740:	0a468693          	addi	a3,a3,164 # ffffffffc02067e0 <default_pmm_manager+0xb30>
ffffffffc0203744:	00002617          	auipc	a2,0x2
ffffffffc0203748:	1d460613          	addi	a2,a2,468 # ffffffffc0205918 <commands+0x870>
ffffffffc020374c:	05d00593          	li	a1,93
ffffffffc0203750:	00003517          	auipc	a0,0x3
ffffffffc0203754:	fd850513          	addi	a0,a0,-40 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203758:	cf9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc020375c:	00003697          	auipc	a3,0x3
ffffffffc0203760:	e4468693          	addi	a3,a3,-444 # ffffffffc02065a0 <default_pmm_manager+0x8f0>
ffffffffc0203764:	00002617          	auipc	a2,0x2
ffffffffc0203768:	1b460613          	addi	a2,a2,436 # ffffffffc0205918 <commands+0x870>
ffffffffc020376c:	05a00593          	li	a1,90
ffffffffc0203770:	00003517          	auipc	a0,0x3
ffffffffc0203774:	fb850513          	addi	a0,a0,-72 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203778:	cd9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc020377c:	00003697          	auipc	a3,0x3
ffffffffc0203780:	e2468693          	addi	a3,a3,-476 # ffffffffc02065a0 <default_pmm_manager+0x8f0>
ffffffffc0203784:	00002617          	auipc	a2,0x2
ffffffffc0203788:	19460613          	addi	a2,a2,404 # ffffffffc0205918 <commands+0x870>
ffffffffc020378c:	05700593          	li	a1,87
ffffffffc0203790:	00003517          	auipc	a0,0x3
ffffffffc0203794:	f9850513          	addi	a0,a0,-104 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc0203798:	cb9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc020379c:	00003697          	auipc	a3,0x3
ffffffffc02037a0:	e0468693          	addi	a3,a3,-508 # ffffffffc02065a0 <default_pmm_manager+0x8f0>
ffffffffc02037a4:	00002617          	auipc	a2,0x2
ffffffffc02037a8:	17460613          	addi	a2,a2,372 # ffffffffc0205918 <commands+0x870>
ffffffffc02037ac:	05400593          	li	a1,84
ffffffffc02037b0:	00003517          	auipc	a0,0x3
ffffffffc02037b4:	f7850513          	addi	a0,a0,-136 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc02037b8:	c99fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02037bc <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02037bc:	751c                	ld	a5,40(a0)
{
ffffffffc02037be:	1141                	addi	sp,sp,-16
ffffffffc02037c0:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02037c2:	cf91                	beqz	a5,ffffffffc02037de <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02037c4:	ee0d                	bnez	a2,ffffffffc02037fe <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02037c6:	679c                	ld	a5,8(a5)
}
ffffffffc02037c8:	60a2                	ld	ra,8(sp)
ffffffffc02037ca:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02037cc:	6394                	ld	a3,0(a5)
ffffffffc02037ce:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02037d0:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02037d4:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02037d6:	e314                	sd	a3,0(a4)
ffffffffc02037d8:	e19c                	sd	a5,0(a1)
}
ffffffffc02037da:	0141                	addi	sp,sp,16
ffffffffc02037dc:	8082                	ret
         assert(head != NULL);
ffffffffc02037de:	00003697          	auipc	a3,0x3
ffffffffc02037e2:	0ba68693          	addi	a3,a3,186 # ffffffffc0206898 <default_pmm_manager+0xbe8>
ffffffffc02037e6:	00002617          	auipc	a2,0x2
ffffffffc02037ea:	13260613          	addi	a2,a2,306 # ffffffffc0205918 <commands+0x870>
ffffffffc02037ee:	04100593          	li	a1,65
ffffffffc02037f2:	00003517          	auipc	a0,0x3
ffffffffc02037f6:	f3650513          	addi	a0,a0,-202 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc02037fa:	c57fc0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(in_tick==0);
ffffffffc02037fe:	00003697          	auipc	a3,0x3
ffffffffc0203802:	0aa68693          	addi	a3,a3,170 # ffffffffc02068a8 <default_pmm_manager+0xbf8>
ffffffffc0203806:	00002617          	auipc	a2,0x2
ffffffffc020380a:	11260613          	addi	a2,a2,274 # ffffffffc0205918 <commands+0x870>
ffffffffc020380e:	04200593          	li	a1,66
ffffffffc0203812:	00003517          	auipc	a0,0x3
ffffffffc0203816:	f1650513          	addi	a0,a0,-234 # ffffffffc0206728 <default_pmm_manager+0xa78>
ffffffffc020381a:	c37fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020381e <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020381e:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203822:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203824:	cb09                	beqz	a4,ffffffffc0203836 <_fifo_map_swappable+0x18>
ffffffffc0203826:	cb81                	beqz	a5,ffffffffc0203836 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203828:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020382a:	e398                	sd	a4,0(a5)
}
ffffffffc020382c:	4501                	li	a0,0
ffffffffc020382e:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203830:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203832:	f614                	sd	a3,40(a2)
ffffffffc0203834:	8082                	ret
{
ffffffffc0203836:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203838:	00003697          	auipc	a3,0x3
ffffffffc020383c:	04068693          	addi	a3,a3,64 # ffffffffc0206878 <default_pmm_manager+0xbc8>
ffffffffc0203840:	00002617          	auipc	a2,0x2
ffffffffc0203844:	0d860613          	addi	a2,a2,216 # ffffffffc0205918 <commands+0x870>
ffffffffc0203848:	03200593          	li	a1,50
ffffffffc020384c:	00003517          	auipc	a0,0x3
ffffffffc0203850:	edc50513          	addi	a0,a0,-292 # ffffffffc0206728 <default_pmm_manager+0xa78>
{
ffffffffc0203854:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203856:	bfbfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020385a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020385a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020385c:	00003697          	auipc	a3,0x3
ffffffffc0203860:	07468693          	addi	a3,a3,116 # ffffffffc02068d0 <default_pmm_manager+0xc20>
ffffffffc0203864:	00002617          	auipc	a2,0x2
ffffffffc0203868:	0b460613          	addi	a2,a2,180 # ffffffffc0205918 <commands+0x870>
ffffffffc020386c:	07e00593          	li	a1,126
ffffffffc0203870:	00003517          	auipc	a0,0x3
ffffffffc0203874:	08050513          	addi	a0,a0,128 # ffffffffc02068f0 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203878:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020387a:	bd7fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020387e <mm_create>:
mm_create(void) {
ffffffffc020387e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203880:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203884:	e022                	sd	s0,0(sp)
ffffffffc0203886:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203888:	936fe0ef          	jal	ra,ffffffffc02019be <kmalloc>
ffffffffc020388c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020388e:	c115                	beqz	a0,ffffffffc02038b2 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203890:	00013797          	auipc	a5,0x13
ffffffffc0203894:	c1878793          	addi	a5,a5,-1000 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0203898:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020389a:	e408                	sd	a0,8(s0)
ffffffffc020389c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020389e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02038a2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02038a6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038aa:	2781                	sext.w	a5,a5
ffffffffc02038ac:	eb81                	bnez	a5,ffffffffc02038bc <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02038ae:	02053423          	sd	zero,40(a0)
}
ffffffffc02038b2:	8522                	mv	a0,s0
ffffffffc02038b4:	60a2                	ld	ra,8(sp)
ffffffffc02038b6:	6402                	ld	s0,0(sp)
ffffffffc02038b8:	0141                	addi	sp,sp,16
ffffffffc02038ba:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038bc:	a09ff0ef          	jal	ra,ffffffffc02032c4 <swap_init_mm>
}
ffffffffc02038c0:	8522                	mv	a0,s0
ffffffffc02038c2:	60a2                	ld	ra,8(sp)
ffffffffc02038c4:	6402                	ld	s0,0(sp)
ffffffffc02038c6:	0141                	addi	sp,sp,16
ffffffffc02038c8:	8082                	ret

ffffffffc02038ca <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038ca:	1101                	addi	sp,sp,-32
ffffffffc02038cc:	e04a                	sd	s2,0(sp)
ffffffffc02038ce:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038d0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038d4:	e822                	sd	s0,16(sp)
ffffffffc02038d6:	e426                	sd	s1,8(sp)
ffffffffc02038d8:	ec06                	sd	ra,24(sp)
ffffffffc02038da:	84ae                	mv	s1,a1
ffffffffc02038dc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038de:	8e0fe0ef          	jal	ra,ffffffffc02019be <kmalloc>
    if (vma != NULL) {
ffffffffc02038e2:	c509                	beqz	a0,ffffffffc02038ec <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02038e4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02038e8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02038ea:	cd00                	sw	s0,24(a0)
}
ffffffffc02038ec:	60e2                	ld	ra,24(sp)
ffffffffc02038ee:	6442                	ld	s0,16(sp)
ffffffffc02038f0:	64a2                	ld	s1,8(sp)
ffffffffc02038f2:	6902                	ld	s2,0(sp)
ffffffffc02038f4:	6105                	addi	sp,sp,32
ffffffffc02038f6:	8082                	ret

ffffffffc02038f8 <find_vma>:
    if (mm != NULL) {
ffffffffc02038f8:	c51d                	beqz	a0,ffffffffc0203926 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02038fa:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02038fc:	c781                	beqz	a5,ffffffffc0203904 <find_vma+0xc>
ffffffffc02038fe:	6798                	ld	a4,8(a5)
ffffffffc0203900:	02e5f663          	bleu	a4,a1,ffffffffc020392c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203904:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203906:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203908:	00f50f63          	beq	a0,a5,ffffffffc0203926 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020390c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203910:	fee5ebe3          	bltu	a1,a4,ffffffffc0203906 <find_vma+0xe>
ffffffffc0203914:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203918:	fee5f7e3          	bleu	a4,a1,ffffffffc0203906 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020391c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020391e:	c781                	beqz	a5,ffffffffc0203926 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203920:	e91c                	sd	a5,16(a0)
}
ffffffffc0203922:	853e                	mv	a0,a5
ffffffffc0203924:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203926:	4781                	li	a5,0
}
ffffffffc0203928:	853e                	mv	a0,a5
ffffffffc020392a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020392c:	6b98                	ld	a4,16(a5)
ffffffffc020392e:	fce5fbe3          	bleu	a4,a1,ffffffffc0203904 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203932:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203934:	b7fd                	j	ffffffffc0203922 <find_vma+0x2a>

ffffffffc0203936 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203936:	6590                	ld	a2,8(a1)
ffffffffc0203938:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020393c:	1141                	addi	sp,sp,-16
ffffffffc020393e:	e406                	sd	ra,8(sp)
ffffffffc0203940:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203942:	01066863          	bltu	a2,a6,ffffffffc0203952 <insert_vma_struct+0x1c>
ffffffffc0203946:	a8b9                	j	ffffffffc02039a4 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203948:	fe87b683          	ld	a3,-24(a5)
ffffffffc020394c:	04d66763          	bltu	a2,a3,ffffffffc020399a <insert_vma_struct+0x64>
ffffffffc0203950:	873e                	mv	a4,a5
ffffffffc0203952:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203954:	fef51ae3          	bne	a0,a5,ffffffffc0203948 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203958:	02a70463          	beq	a4,a0,ffffffffc0203980 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020395c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203960:	fe873883          	ld	a7,-24(a4)
ffffffffc0203964:	08d8f063          	bleu	a3,a7,ffffffffc02039e4 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203968:	04d66e63          	bltu	a2,a3,ffffffffc02039c4 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc020396c:	00f50a63          	beq	a0,a5,ffffffffc0203980 <insert_vma_struct+0x4a>
ffffffffc0203970:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203974:	0506e863          	bltu	a3,a6,ffffffffc02039c4 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203978:	ff07b603          	ld	a2,-16(a5)
ffffffffc020397c:	02c6f263          	bleu	a2,a3,ffffffffc02039a0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203980:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203982:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203984:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203988:	e390                	sd	a2,0(a5)
ffffffffc020398a:	e710                	sd	a2,8(a4)
}
ffffffffc020398c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020398e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203990:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203992:	2685                	addiw	a3,a3,1
ffffffffc0203994:	d114                	sw	a3,32(a0)
}
ffffffffc0203996:	0141                	addi	sp,sp,16
ffffffffc0203998:	8082                	ret
    if (le_prev != list) {
ffffffffc020399a:	fca711e3          	bne	a4,a0,ffffffffc020395c <insert_vma_struct+0x26>
ffffffffc020399e:	bfd9                	j	ffffffffc0203974 <insert_vma_struct+0x3e>
ffffffffc02039a0:	ebbff0ef          	jal	ra,ffffffffc020385a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02039a4:	00003697          	auipc	a3,0x3
ffffffffc02039a8:	ffc68693          	addi	a3,a3,-4 # ffffffffc02069a0 <default_pmm_manager+0xcf0>
ffffffffc02039ac:	00002617          	auipc	a2,0x2
ffffffffc02039b0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0205918 <commands+0x870>
ffffffffc02039b4:	08500593          	li	a1,133
ffffffffc02039b8:	00003517          	auipc	a0,0x3
ffffffffc02039bc:	f3850513          	addi	a0,a0,-200 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc02039c0:	a91fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039c4:	00003697          	auipc	a3,0x3
ffffffffc02039c8:	01c68693          	addi	a3,a3,28 # ffffffffc02069e0 <default_pmm_manager+0xd30>
ffffffffc02039cc:	00002617          	auipc	a2,0x2
ffffffffc02039d0:	f4c60613          	addi	a2,a2,-180 # ffffffffc0205918 <commands+0x870>
ffffffffc02039d4:	07d00593          	li	a1,125
ffffffffc02039d8:	00003517          	auipc	a0,0x3
ffffffffc02039dc:	f1850513          	addi	a0,a0,-232 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc02039e0:	a71fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02039e4:	00003697          	auipc	a3,0x3
ffffffffc02039e8:	fdc68693          	addi	a3,a3,-36 # ffffffffc02069c0 <default_pmm_manager+0xd10>
ffffffffc02039ec:	00002617          	auipc	a2,0x2
ffffffffc02039f0:	f2c60613          	addi	a2,a2,-212 # ffffffffc0205918 <commands+0x870>
ffffffffc02039f4:	07c00593          	li	a1,124
ffffffffc02039f8:	00003517          	auipc	a0,0x3
ffffffffc02039fc:	ef850513          	addi	a0,a0,-264 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203a00:	a51fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203a04 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203a04:	1141                	addi	sp,sp,-16
ffffffffc0203a06:	e022                	sd	s0,0(sp)
ffffffffc0203a08:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203a0a:	6508                	ld	a0,8(a0)
ffffffffc0203a0c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203a0e:	00a40c63          	beq	s0,a0,ffffffffc0203a26 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a12:	6118                	ld	a4,0(a0)
ffffffffc0203a14:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203a16:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a18:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a1a:	e398                	sd	a4,0(a5)
ffffffffc0203a1c:	85efe0ef          	jal	ra,ffffffffc0201a7a <kfree>
    return listelm->next;
ffffffffc0203a20:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a22:	fea418e3          	bne	s0,a0,ffffffffc0203a12 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203a26:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203a28:	6402                	ld	s0,0(sp)
ffffffffc0203a2a:	60a2                	ld	ra,8(sp)
ffffffffc0203a2c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203a2e:	84cfe06f          	j	ffffffffc0201a7a <kfree>

ffffffffc0203a32 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203a32:	7139                	addi	sp,sp,-64
ffffffffc0203a34:	f822                	sd	s0,48(sp)
ffffffffc0203a36:	f426                	sd	s1,40(sp)
ffffffffc0203a38:	fc06                	sd	ra,56(sp)
ffffffffc0203a3a:	f04a                	sd	s2,32(sp)
ffffffffc0203a3c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a3e:	e852                	sd	s4,16(sp)
ffffffffc0203a40:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0203a42:	e3dff0ef          	jal	ra,ffffffffc020387e <mm_create>
    assert(mm != NULL);
ffffffffc0203a46:	842a                	mv	s0,a0
ffffffffc0203a48:	03200493          	li	s1,50
ffffffffc0203a4c:	e919                	bnez	a0,ffffffffc0203a62 <vmm_init+0x30>
ffffffffc0203a4e:	a989                	j	ffffffffc0203ea0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0203a50:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a52:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a54:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a58:	14ed                	addi	s1,s1,-5
ffffffffc0203a5a:	8522                	mv	a0,s0
ffffffffc0203a5c:	edbff0ef          	jal	ra,ffffffffc0203936 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a60:	c88d                	beqz	s1,ffffffffc0203a92 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a62:	03000513          	li	a0,48
ffffffffc0203a66:	f59fd0ef          	jal	ra,ffffffffc02019be <kmalloc>
ffffffffc0203a6a:	85aa                	mv	a1,a0
ffffffffc0203a6c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a70:	f165                	bnez	a0,ffffffffc0203a50 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0203a72:	00003697          	auipc	a3,0x3
ffffffffc0203a76:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0206460 <default_pmm_manager+0x7b0>
ffffffffc0203a7a:	00002617          	auipc	a2,0x2
ffffffffc0203a7e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0205918 <commands+0x870>
ffffffffc0203a82:	0c900593          	li	a1,201
ffffffffc0203a86:	00003517          	auipc	a0,0x3
ffffffffc0203a8a:	e6a50513          	addi	a0,a0,-406 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203a8e:	9c3fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a92:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a96:	1f900913          	li	s2,505
ffffffffc0203a9a:	a819                	j	ffffffffc0203ab0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0203a9c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a9e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203aa0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203aa4:	0495                	addi	s1,s1,5
ffffffffc0203aa6:	8522                	mv	a0,s0
ffffffffc0203aa8:	e8fff0ef          	jal	ra,ffffffffc0203936 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203aac:	03248a63          	beq	s1,s2,ffffffffc0203ae0 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ab0:	03000513          	li	a0,48
ffffffffc0203ab4:	f0bfd0ef          	jal	ra,ffffffffc02019be <kmalloc>
ffffffffc0203ab8:	85aa                	mv	a1,a0
ffffffffc0203aba:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203abe:	fd79                	bnez	a0,ffffffffc0203a9c <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203ac0:	00003697          	auipc	a3,0x3
ffffffffc0203ac4:	9a068693          	addi	a3,a3,-1632 # ffffffffc0206460 <default_pmm_manager+0x7b0>
ffffffffc0203ac8:	00002617          	auipc	a2,0x2
ffffffffc0203acc:	e5060613          	addi	a2,a2,-432 # ffffffffc0205918 <commands+0x870>
ffffffffc0203ad0:	0cf00593          	li	a1,207
ffffffffc0203ad4:	00003517          	auipc	a0,0x3
ffffffffc0203ad8:	e1c50513          	addi	a0,a0,-484 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203adc:	975fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203ae0:	6418                	ld	a4,8(s0)
ffffffffc0203ae2:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203ae4:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203ae8:	2ee40063          	beq	s0,a4,ffffffffc0203dc8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203aec:	fe873603          	ld	a2,-24(a4)
ffffffffc0203af0:	ffe78693          	addi	a3,a5,-2
ffffffffc0203af4:	24d61a63          	bne	a2,a3,ffffffffc0203d48 <vmm_init+0x316>
ffffffffc0203af8:	ff073683          	ld	a3,-16(a4)
ffffffffc0203afc:	24f69663          	bne	a3,a5,ffffffffc0203d48 <vmm_init+0x316>
ffffffffc0203b00:	0795                	addi	a5,a5,5
ffffffffc0203b02:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203b04:	feb792e3          	bne	a5,a1,ffffffffc0203ae8 <vmm_init+0xb6>
ffffffffc0203b08:	491d                	li	s2,7
ffffffffc0203b0a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b0c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b10:	85a6                	mv	a1,s1
ffffffffc0203b12:	8522                	mv	a0,s0
ffffffffc0203b14:	de5ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
ffffffffc0203b18:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203b1a:	30050763          	beqz	a0,ffffffffc0203e28 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203b1e:	00148593          	addi	a1,s1,1
ffffffffc0203b22:	8522                	mv	a0,s0
ffffffffc0203b24:	dd5ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
ffffffffc0203b28:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b2a:	2c050f63          	beqz	a0,ffffffffc0203e08 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203b2e:	85ca                	mv	a1,s2
ffffffffc0203b30:	8522                	mv	a0,s0
ffffffffc0203b32:	dc7ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b36:	2a051963          	bnez	a0,ffffffffc0203de8 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203b3a:	00348593          	addi	a1,s1,3
ffffffffc0203b3e:	8522                	mv	a0,s0
ffffffffc0203b40:	db9ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b44:	32051263          	bnez	a0,ffffffffc0203e68 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203b48:	00448593          	addi	a1,s1,4
ffffffffc0203b4c:	8522                	mv	a0,s0
ffffffffc0203b4e:	dabff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b52:	2e051b63          	bnez	a0,ffffffffc0203e48 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b56:	008a3783          	ld	a5,8(s4)
ffffffffc0203b5a:	20979763          	bne	a5,s1,ffffffffc0203d68 <vmm_init+0x336>
ffffffffc0203b5e:	010a3783          	ld	a5,16(s4)
ffffffffc0203b62:	21279363          	bne	a5,s2,ffffffffc0203d68 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b66:	0089b783          	ld	a5,8(s3)
ffffffffc0203b6a:	20979f63          	bne	a5,s1,ffffffffc0203d88 <vmm_init+0x356>
ffffffffc0203b6e:	0109b783          	ld	a5,16(s3)
ffffffffc0203b72:	21279b63          	bne	a5,s2,ffffffffc0203d88 <vmm_init+0x356>
ffffffffc0203b76:	0495                	addi	s1,s1,5
ffffffffc0203b78:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b7a:	f9549be3          	bne	s1,s5,ffffffffc0203b10 <vmm_init+0xde>
ffffffffc0203b7e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203b80:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203b82:	85a6                	mv	a1,s1
ffffffffc0203b84:	8522                	mv	a0,s0
ffffffffc0203b86:	d73ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
ffffffffc0203b8a:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203b8e:	c90d                	beqz	a0,ffffffffc0203bc0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203b90:	6914                	ld	a3,16(a0)
ffffffffc0203b92:	6510                	ld	a2,8(a0)
ffffffffc0203b94:	00003517          	auipc	a0,0x3
ffffffffc0203b98:	f6c50513          	addi	a0,a0,-148 # ffffffffc0206b00 <default_pmm_manager+0xe50>
ffffffffc0203b9c:	df2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203ba0:	00003697          	auipc	a3,0x3
ffffffffc0203ba4:	f8868693          	addi	a3,a3,-120 # ffffffffc0206b28 <default_pmm_manager+0xe78>
ffffffffc0203ba8:	00002617          	auipc	a2,0x2
ffffffffc0203bac:	d7060613          	addi	a2,a2,-656 # ffffffffc0205918 <commands+0x870>
ffffffffc0203bb0:	0f100593          	li	a1,241
ffffffffc0203bb4:	00003517          	auipc	a0,0x3
ffffffffc0203bb8:	d3c50513          	addi	a0,a0,-708 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203bbc:	895fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203bc0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203bc2:	fd2490e3          	bne	s1,s2,ffffffffc0203b82 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203bc6:	8522                	mv	a0,s0
ffffffffc0203bc8:	e3dff0ef          	jal	ra,ffffffffc0203a04 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203bcc:	00003517          	auipc	a0,0x3
ffffffffc0203bd0:	f7450513          	addi	a0,a0,-140 # ffffffffc0206b40 <default_pmm_manager+0xe90>
ffffffffc0203bd4:	dbafc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203bd8:	8b0fe0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>
ffffffffc0203bdc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203bde:	ca1ff0ef          	jal	ra,ffffffffc020387e <mm_create>
ffffffffc0203be2:	00013797          	auipc	a5,0x13
ffffffffc0203be6:	a0a7b323          	sd	a0,-1530(a5) # ffffffffc02165e8 <check_mm_struct>
ffffffffc0203bea:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203bec:	36050663          	beqz	a0,ffffffffc0203f58 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203bf0:	00013797          	auipc	a5,0x13
ffffffffc0203bf4:	8a078793          	addi	a5,a5,-1888 # ffffffffc0216490 <boot_pgdir>
ffffffffc0203bf8:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203bfc:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c00:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203c04:	2c079e63          	bnez	a5,ffffffffc0203ee0 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c08:	03000513          	li	a0,48
ffffffffc0203c0c:	db3fd0ef          	jal	ra,ffffffffc02019be <kmalloc>
ffffffffc0203c10:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203c12:	18050b63          	beqz	a0,ffffffffc0203da8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203c16:	002007b7          	lui	a5,0x200
ffffffffc0203c1a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203c1c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203c1e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203c20:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c22:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203c24:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c28:	d0fff0ef          	jal	ra,ffffffffc0203936 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c2c:	10000593          	li	a1,256
ffffffffc0203c30:	8526                	mv	a0,s1
ffffffffc0203c32:	cc7ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>
ffffffffc0203c36:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203c3a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c3e:	2ca41163          	bne	s0,a0,ffffffffc0203f00 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203c42:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203c46:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c48:	fee79de3          	bne	a5,a4,ffffffffc0203c42 <vmm_init+0x210>
        sum += i;
ffffffffc0203c4c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c4e:	10000793          	li	a5,256
        sum += i;
ffffffffc0203c52:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203c56:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203c5a:	0007c683          	lbu	a3,0(a5)
ffffffffc0203c5e:	0785                	addi	a5,a5,1
ffffffffc0203c60:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203c62:	fec79ce3          	bne	a5,a2,ffffffffc0203c5a <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203c66:	2c071963          	bnez	a4,ffffffffc0203f38 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c6a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c6e:	00013a97          	auipc	s5,0x13
ffffffffc0203c72:	82aa8a93          	addi	s5,s5,-2006 # ffffffffc0216498 <npage>
ffffffffc0203c76:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c7a:	078a                	slli	a5,a5,0x2
ffffffffc0203c7c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c7e:	20e7f563          	bleu	a4,a5,ffffffffc0203e88 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c82:	00003697          	auipc	a3,0x3
ffffffffc0203c86:	3d668693          	addi	a3,a3,982 # ffffffffc0207058 <nbase>
ffffffffc0203c8a:	0006ba03          	ld	s4,0(a3)
ffffffffc0203c8e:	414786b3          	sub	a3,a5,s4
ffffffffc0203c92:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203c94:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203c96:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203c98:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203c9a:	83b1                	srli	a5,a5,0xc
ffffffffc0203c9c:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c9e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203ca0:	28e7f063          	bleu	a4,a5,ffffffffc0203f20 <vmm_init+0x4ee>
ffffffffc0203ca4:	00013797          	auipc	a5,0x13
ffffffffc0203ca8:	85478793          	addi	a5,a5,-1964 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0203cac:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203cae:	4581                	li	a1,0
ffffffffc0203cb0:	854a                	mv	a0,s2
ffffffffc0203cb2:	9436                	add	s0,s0,a3
ffffffffc0203cb4:	a48fe0ef          	jal	ra,ffffffffc0201efc <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cb8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203cba:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cbe:	078a                	slli	a5,a5,0x2
ffffffffc0203cc0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cc2:	1ce7f363          	bleu	a4,a5,ffffffffc0203e88 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cc6:	00013417          	auipc	s0,0x13
ffffffffc0203cca:	84240413          	addi	s0,s0,-1982 # ffffffffc0216508 <pages>
ffffffffc0203cce:	6008                	ld	a0,0(s0)
ffffffffc0203cd0:	414787b3          	sub	a5,a5,s4
ffffffffc0203cd4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203cd6:	953e                	add	a0,a0,a5
ffffffffc0203cd8:	4585                	li	a1,1
ffffffffc0203cda:	f69fd0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cde:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203ce2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ce6:	078a                	slli	a5,a5,0x2
ffffffffc0203ce8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cea:	18e7ff63          	bleu	a4,a5,ffffffffc0203e88 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cee:	6008                	ld	a0,0(s0)
ffffffffc0203cf0:	414787b3          	sub	a5,a5,s4
ffffffffc0203cf4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203cf6:	4585                	li	a1,1
ffffffffc0203cf8:	953e                	add	a0,a0,a5
ffffffffc0203cfa:	f49fd0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    pgdir[0] = 0;
ffffffffc0203cfe:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203d02:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203d06:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203d0a:	8526                	mv	a0,s1
ffffffffc0203d0c:	cf9ff0ef          	jal	ra,ffffffffc0203a04 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203d10:	00013797          	auipc	a5,0x13
ffffffffc0203d14:	8c07bc23          	sd	zero,-1832(a5) # ffffffffc02165e8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d18:	f71fd0ef          	jal	ra,ffffffffc0201c88 <nr_free_pages>
ffffffffc0203d1c:	1aa99263          	bne	s3,a0,ffffffffc0203ec0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203d20:	00003517          	auipc	a0,0x3
ffffffffc0203d24:	eb050513          	addi	a0,a0,-336 # ffffffffc0206bd0 <default_pmm_manager+0xf20>
ffffffffc0203d28:	c66fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203d2c:	7442                	ld	s0,48(sp)
ffffffffc0203d2e:	70e2                	ld	ra,56(sp)
ffffffffc0203d30:	74a2                	ld	s1,40(sp)
ffffffffc0203d32:	7902                	ld	s2,32(sp)
ffffffffc0203d34:	69e2                	ld	s3,24(sp)
ffffffffc0203d36:	6a42                	ld	s4,16(sp)
ffffffffc0203d38:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d3a:	00003517          	auipc	a0,0x3
ffffffffc0203d3e:	eb650513          	addi	a0,a0,-330 # ffffffffc0206bf0 <default_pmm_manager+0xf40>
}
ffffffffc0203d42:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d44:	c4afc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d48:	00003697          	auipc	a3,0x3
ffffffffc0203d4c:	cd068693          	addi	a3,a3,-816 # ffffffffc0206a18 <default_pmm_manager+0xd68>
ffffffffc0203d50:	00002617          	auipc	a2,0x2
ffffffffc0203d54:	bc860613          	addi	a2,a2,-1080 # ffffffffc0205918 <commands+0x870>
ffffffffc0203d58:	0d800593          	li	a1,216
ffffffffc0203d5c:	00003517          	auipc	a0,0x3
ffffffffc0203d60:	b9450513          	addi	a0,a0,-1132 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203d64:	eecfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203d68:	00003697          	auipc	a3,0x3
ffffffffc0203d6c:	d3868693          	addi	a3,a3,-712 # ffffffffc0206aa0 <default_pmm_manager+0xdf0>
ffffffffc0203d70:	00002617          	auipc	a2,0x2
ffffffffc0203d74:	ba860613          	addi	a2,a2,-1112 # ffffffffc0205918 <commands+0x870>
ffffffffc0203d78:	0e800593          	li	a1,232
ffffffffc0203d7c:	00003517          	auipc	a0,0x3
ffffffffc0203d80:	b7450513          	addi	a0,a0,-1164 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203d84:	eccfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203d88:	00003697          	auipc	a3,0x3
ffffffffc0203d8c:	d4868693          	addi	a3,a3,-696 # ffffffffc0206ad0 <default_pmm_manager+0xe20>
ffffffffc0203d90:	00002617          	auipc	a2,0x2
ffffffffc0203d94:	b8860613          	addi	a2,a2,-1144 # ffffffffc0205918 <commands+0x870>
ffffffffc0203d98:	0e900593          	li	a1,233
ffffffffc0203d9c:	00003517          	auipc	a0,0x3
ffffffffc0203da0:	b5450513          	addi	a0,a0,-1196 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203da4:	eacfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(vma != NULL);
ffffffffc0203da8:	00002697          	auipc	a3,0x2
ffffffffc0203dac:	6b868693          	addi	a3,a3,1720 # ffffffffc0206460 <default_pmm_manager+0x7b0>
ffffffffc0203db0:	00002617          	auipc	a2,0x2
ffffffffc0203db4:	b6860613          	addi	a2,a2,-1176 # ffffffffc0205918 <commands+0x870>
ffffffffc0203db8:	10800593          	li	a1,264
ffffffffc0203dbc:	00003517          	auipc	a0,0x3
ffffffffc0203dc0:	b3450513          	addi	a0,a0,-1228 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203dc4:	e8cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203dc8:	00003697          	auipc	a3,0x3
ffffffffc0203dcc:	c3868693          	addi	a3,a3,-968 # ffffffffc0206a00 <default_pmm_manager+0xd50>
ffffffffc0203dd0:	00002617          	auipc	a2,0x2
ffffffffc0203dd4:	b4860613          	addi	a2,a2,-1208 # ffffffffc0205918 <commands+0x870>
ffffffffc0203dd8:	0d600593          	li	a1,214
ffffffffc0203ddc:	00003517          	auipc	a0,0x3
ffffffffc0203de0:	b1450513          	addi	a0,a0,-1260 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203de4:	e6cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma3 == NULL);
ffffffffc0203de8:	00003697          	auipc	a3,0x3
ffffffffc0203dec:	c8868693          	addi	a3,a3,-888 # ffffffffc0206a70 <default_pmm_manager+0xdc0>
ffffffffc0203df0:	00002617          	auipc	a2,0x2
ffffffffc0203df4:	b2860613          	addi	a2,a2,-1240 # ffffffffc0205918 <commands+0x870>
ffffffffc0203df8:	0e200593          	li	a1,226
ffffffffc0203dfc:	00003517          	auipc	a0,0x3
ffffffffc0203e00:	af450513          	addi	a0,a0,-1292 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203e04:	e4cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2 != NULL);
ffffffffc0203e08:	00003697          	auipc	a3,0x3
ffffffffc0203e0c:	c5868693          	addi	a3,a3,-936 # ffffffffc0206a60 <default_pmm_manager+0xdb0>
ffffffffc0203e10:	00002617          	auipc	a2,0x2
ffffffffc0203e14:	b0860613          	addi	a2,a2,-1272 # ffffffffc0205918 <commands+0x870>
ffffffffc0203e18:	0e000593          	li	a1,224
ffffffffc0203e1c:	00003517          	auipc	a0,0x3
ffffffffc0203e20:	ad450513          	addi	a0,a0,-1324 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203e24:	e2cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1 != NULL);
ffffffffc0203e28:	00003697          	auipc	a3,0x3
ffffffffc0203e2c:	c2868693          	addi	a3,a3,-984 # ffffffffc0206a50 <default_pmm_manager+0xda0>
ffffffffc0203e30:	00002617          	auipc	a2,0x2
ffffffffc0203e34:	ae860613          	addi	a2,a2,-1304 # ffffffffc0205918 <commands+0x870>
ffffffffc0203e38:	0de00593          	li	a1,222
ffffffffc0203e3c:	00003517          	auipc	a0,0x3
ffffffffc0203e40:	ab450513          	addi	a0,a0,-1356 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203e44:	e0cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e48:	00003697          	auipc	a3,0x3
ffffffffc0203e4c:	c4868693          	addi	a3,a3,-952 # ffffffffc0206a90 <default_pmm_manager+0xde0>
ffffffffc0203e50:	00002617          	auipc	a2,0x2
ffffffffc0203e54:	ac860613          	addi	a2,a2,-1336 # ffffffffc0205918 <commands+0x870>
ffffffffc0203e58:	0e600593          	li	a1,230
ffffffffc0203e5c:	00003517          	auipc	a0,0x3
ffffffffc0203e60:	a9450513          	addi	a0,a0,-1388 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203e64:	decfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e68:	00003697          	auipc	a3,0x3
ffffffffc0203e6c:	c1868693          	addi	a3,a3,-1000 # ffffffffc0206a80 <default_pmm_manager+0xdd0>
ffffffffc0203e70:	00002617          	auipc	a2,0x2
ffffffffc0203e74:	aa860613          	addi	a2,a2,-1368 # ffffffffc0205918 <commands+0x870>
ffffffffc0203e78:	0e400593          	li	a1,228
ffffffffc0203e7c:	00003517          	auipc	a0,0x3
ffffffffc0203e80:	a7450513          	addi	a0,a0,-1420 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203e84:	dccfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e88:	00002617          	auipc	a2,0x2
ffffffffc0203e8c:	ed860613          	addi	a2,a2,-296 # ffffffffc0205d60 <default_pmm_manager+0xb0>
ffffffffc0203e90:	06200593          	li	a1,98
ffffffffc0203e94:	00002517          	auipc	a0,0x2
ffffffffc0203e98:	e9450513          	addi	a0,a0,-364 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0203e9c:	db4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(mm != NULL);
ffffffffc0203ea0:	00002697          	auipc	a3,0x2
ffffffffc0203ea4:	58868693          	addi	a3,a3,1416 # ffffffffc0206428 <default_pmm_manager+0x778>
ffffffffc0203ea8:	00002617          	auipc	a2,0x2
ffffffffc0203eac:	a7060613          	addi	a2,a2,-1424 # ffffffffc0205918 <commands+0x870>
ffffffffc0203eb0:	0c200593          	li	a1,194
ffffffffc0203eb4:	00003517          	auipc	a0,0x3
ffffffffc0203eb8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203ebc:	d94fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ec0:	00003697          	auipc	a3,0x3
ffffffffc0203ec4:	ce868693          	addi	a3,a3,-792 # ffffffffc0206ba8 <default_pmm_manager+0xef8>
ffffffffc0203ec8:	00002617          	auipc	a2,0x2
ffffffffc0203ecc:	a5060613          	addi	a2,a2,-1456 # ffffffffc0205918 <commands+0x870>
ffffffffc0203ed0:	12400593          	li	a1,292
ffffffffc0203ed4:	00003517          	auipc	a0,0x3
ffffffffc0203ed8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203edc:	d74fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203ee0:	00002697          	auipc	a3,0x2
ffffffffc0203ee4:	57068693          	addi	a3,a3,1392 # ffffffffc0206450 <default_pmm_manager+0x7a0>
ffffffffc0203ee8:	00002617          	auipc	a2,0x2
ffffffffc0203eec:	a3060613          	addi	a2,a2,-1488 # ffffffffc0205918 <commands+0x870>
ffffffffc0203ef0:	10500593          	li	a1,261
ffffffffc0203ef4:	00003517          	auipc	a0,0x3
ffffffffc0203ef8:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203efc:	d54fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203f00:	00003697          	auipc	a3,0x3
ffffffffc0203f04:	c7868693          	addi	a3,a3,-904 # ffffffffc0206b78 <default_pmm_manager+0xec8>
ffffffffc0203f08:	00002617          	auipc	a2,0x2
ffffffffc0203f0c:	a1060613          	addi	a2,a2,-1520 # ffffffffc0205918 <commands+0x870>
ffffffffc0203f10:	10d00593          	li	a1,269
ffffffffc0203f14:	00003517          	auipc	a0,0x3
ffffffffc0203f18:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203f1c:	d34fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203f20:	00002617          	auipc	a2,0x2
ffffffffc0203f24:	de060613          	addi	a2,a2,-544 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0203f28:	06900593          	li	a1,105
ffffffffc0203f2c:	00002517          	auipc	a0,0x2
ffffffffc0203f30:	dfc50513          	addi	a0,a0,-516 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0203f34:	d1cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(sum == 0);
ffffffffc0203f38:	00003697          	auipc	a3,0x3
ffffffffc0203f3c:	c6068693          	addi	a3,a3,-928 # ffffffffc0206b98 <default_pmm_manager+0xee8>
ffffffffc0203f40:	00002617          	auipc	a2,0x2
ffffffffc0203f44:	9d860613          	addi	a2,a2,-1576 # ffffffffc0205918 <commands+0x870>
ffffffffc0203f48:	11700593          	li	a1,279
ffffffffc0203f4c:	00003517          	auipc	a0,0x3
ffffffffc0203f50:	9a450513          	addi	a0,a0,-1628 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203f54:	cfcfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203f58:	00003697          	auipc	a3,0x3
ffffffffc0203f5c:	c0868693          	addi	a3,a3,-1016 # ffffffffc0206b60 <default_pmm_manager+0xeb0>
ffffffffc0203f60:	00002617          	auipc	a2,0x2
ffffffffc0203f64:	9b860613          	addi	a2,a2,-1608 # ffffffffc0205918 <commands+0x870>
ffffffffc0203f68:	10100593          	li	a1,257
ffffffffc0203f6c:	00003517          	auipc	a0,0x3
ffffffffc0203f70:	98450513          	addi	a0,a0,-1660 # ffffffffc02068f0 <default_pmm_manager+0xc40>
ffffffffc0203f74:	cdcfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203f78 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f78:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f7a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f7c:	f022                	sd	s0,32(sp)
ffffffffc0203f7e:	ec26                	sd	s1,24(sp)
ffffffffc0203f80:	f406                	sd	ra,40(sp)
ffffffffc0203f82:	e84a                	sd	s2,16(sp)
ffffffffc0203f84:	8432                	mv	s0,a2
ffffffffc0203f86:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f88:	971ff0ef          	jal	ra,ffffffffc02038f8 <find_vma>

    pgfault_num++;
ffffffffc0203f8c:	00012797          	auipc	a5,0x12
ffffffffc0203f90:	52078793          	addi	a5,a5,1312 # ffffffffc02164ac <pgfault_num>
ffffffffc0203f94:	439c                	lw	a5,0(a5)
ffffffffc0203f96:	2785                	addiw	a5,a5,1
ffffffffc0203f98:	00012717          	auipc	a4,0x12
ffffffffc0203f9c:	50f72a23          	sw	a5,1300(a4) # ffffffffc02164ac <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203fa0:	c551                	beqz	a0,ffffffffc020402c <do_pgfault+0xb4>
ffffffffc0203fa2:	651c                	ld	a5,8(a0)
ffffffffc0203fa4:	08f46463          	bltu	s0,a5,ffffffffc020402c <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203fa8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203faa:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203fac:	8b89                	andi	a5,a5,2
ffffffffc0203fae:	efb1                	bnez	a5,ffffffffc020400a <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203fb0:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203fb2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203fb4:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203fb6:	85a2                	mv	a1,s0
ffffffffc0203fb8:	4605                	li	a2,1
ffffffffc0203fba:	d0ffd0ef          	jal	ra,ffffffffc0201cc8 <get_pte>
ffffffffc0203fbe:	c941                	beqz	a0,ffffffffc020404e <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203fc0:	610c                	ld	a1,0(a0)
ffffffffc0203fc2:	c5b1                	beqz	a1,ffffffffc020400e <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203fc4:	00012797          	auipc	a5,0x12
ffffffffc0203fc8:	4e478793          	addi	a5,a5,1252 # ffffffffc02164a8 <swap_init_ok>
ffffffffc0203fcc:	439c                	lw	a5,0(a5)
ffffffffc0203fce:	2781                	sext.w	a5,a5
ffffffffc0203fd0:	c7bd                	beqz	a5,ffffffffc020403e <do_pgfault+0xc6>
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            // 将addr线性地址对应的物理页数据从磁盘交换到物理内存中(令Page指针指向交换成功后的物理页)
            swap_in(mm, addr, &page);
ffffffffc0203fd2:	85a2                	mv	a1,s0
ffffffffc0203fd4:	0030                	addi	a2,sp,8
ffffffffc0203fd6:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203fd8:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203fda:	c1eff0ef          	jal	ra,ffffffffc02033f8 <swap_in>
            // 将交换进来的page页与mm->padir页表中对应addr的二级页表项建立映射关系(perm标识这个二级页表的各个权限位)
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203fde:	65a2                	ld	a1,8(sp)
ffffffffc0203fe0:	6c88                	ld	a0,24(s1)
ffffffffc0203fe2:	86ca                	mv	a3,s2
ffffffffc0203fe4:	8622                	mv	a2,s0
ffffffffc0203fe6:	f8bfd0ef          	jal	ra,ffffffffc0201f70 <page_insert>
            // 当前page是为可交换的，将其加入全局虚拟内存交换管理器的管理
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203fea:	6622                	ld	a2,8(sp)
ffffffffc0203fec:	4685                	li	a3,1
ffffffffc0203fee:	85a2                	mv	a1,s0
ffffffffc0203ff0:	8526                	mv	a0,s1
ffffffffc0203ff2:	ae2ff0ef          	jal	ra,ffffffffc02032d4 <swap_map_swappable>
            
            page->pra_vaddr = addr;
ffffffffc0203ff6:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203ff8:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203ffa:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0203ffc:	70a2                	ld	ra,40(sp)
ffffffffc0203ffe:	7402                	ld	s0,32(sp)
ffffffffc0204000:	64e2                	ld	s1,24(sp)
ffffffffc0204002:	6942                	ld	s2,16(sp)
ffffffffc0204004:	853e                	mv	a0,a5
ffffffffc0204006:	6145                	addi	sp,sp,48
ffffffffc0204008:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020400a:	495d                	li	s2,23
ffffffffc020400c:	b755                	j	ffffffffc0203fb0 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020400e:	6c88                	ld	a0,24(s1)
ffffffffc0204010:	864a                	mv	a2,s2
ffffffffc0204012:	85a2                	mv	a1,s0
ffffffffc0204014:	aabfe0ef          	jal	ra,ffffffffc0202abe <pgdir_alloc_page>
   ret = 0;
ffffffffc0204018:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020401a:	f16d                	bnez	a0,ffffffffc0203ffc <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020401c:	00003517          	auipc	a0,0x3
ffffffffc0204020:	93450513          	addi	a0,a0,-1740 # ffffffffc0206950 <default_pmm_manager+0xca0>
ffffffffc0204024:	96afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204028:	57f1                	li	a5,-4
            goto failed;
ffffffffc020402a:	bfc9                	j	ffffffffc0203ffc <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020402c:	85a2                	mv	a1,s0
ffffffffc020402e:	00003517          	auipc	a0,0x3
ffffffffc0204032:	8d250513          	addi	a0,a0,-1838 # ffffffffc0206900 <default_pmm_manager+0xc50>
ffffffffc0204036:	958fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc020403a:	57f5                	li	a5,-3
        goto failed;
ffffffffc020403c:	b7c1                	j	ffffffffc0203ffc <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020403e:	00003517          	auipc	a0,0x3
ffffffffc0204042:	93a50513          	addi	a0,a0,-1734 # ffffffffc0206978 <default_pmm_manager+0xcc8>
ffffffffc0204046:	948fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020404a:	57f1                	li	a5,-4
            goto failed;
ffffffffc020404c:	bf45                	j	ffffffffc0203ffc <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020404e:	00003517          	auipc	a0,0x3
ffffffffc0204052:	8e250513          	addi	a0,a0,-1822 # ffffffffc0206930 <default_pmm_manager+0xc80>
ffffffffc0204056:	938fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020405a:	57f1                	li	a5,-4
        goto failed;
ffffffffc020405c:	b745                	j	ffffffffc0203ffc <do_pgfault+0x84>

ffffffffc020405e <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc020405e:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204060:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204062:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204064:	d18fc0ef          	jal	ra,ffffffffc020057c <ide_device_valid>
ffffffffc0204068:	cd01                	beqz	a0,ffffffffc0204080 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020406a:	4505                	li	a0,1
ffffffffc020406c:	d16fc0ef          	jal	ra,ffffffffc0200582 <ide_device_size>
}
ffffffffc0204070:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204072:	810d                	srli	a0,a0,0x3
ffffffffc0204074:	00012797          	auipc	a5,0x12
ffffffffc0204078:	52a7b223          	sd	a0,1316(a5) # ffffffffc0216598 <max_swap_offset>
}
ffffffffc020407c:	0141                	addi	sp,sp,16
ffffffffc020407e:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204080:	00003617          	auipc	a2,0x3
ffffffffc0204084:	b8860613          	addi	a2,a2,-1144 # ffffffffc0206c08 <default_pmm_manager+0xf58>
ffffffffc0204088:	45b5                	li	a1,13
ffffffffc020408a:	00003517          	auipc	a0,0x3
ffffffffc020408e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0206c28 <default_pmm_manager+0xf78>
ffffffffc0204092:	bbefc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204096 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204096:	1141                	addi	sp,sp,-16
ffffffffc0204098:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020409a:	00855793          	srli	a5,a0,0x8
ffffffffc020409e:	cfb9                	beqz	a5,ffffffffc02040fc <swapfs_read+0x66>
ffffffffc02040a0:	00012717          	auipc	a4,0x12
ffffffffc02040a4:	4f870713          	addi	a4,a4,1272 # ffffffffc0216598 <max_swap_offset>
ffffffffc02040a8:	6318                	ld	a4,0(a4)
ffffffffc02040aa:	04e7f963          	bleu	a4,a5,ffffffffc02040fc <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc02040ae:	00012717          	auipc	a4,0x12
ffffffffc02040b2:	45a70713          	addi	a4,a4,1114 # ffffffffc0216508 <pages>
ffffffffc02040b6:	6310                	ld	a2,0(a4)
ffffffffc02040b8:	00003717          	auipc	a4,0x3
ffffffffc02040bc:	fa070713          	addi	a4,a4,-96 # ffffffffc0207058 <nbase>
    return KADDR(page2pa(page));
ffffffffc02040c0:	00012697          	auipc	a3,0x12
ffffffffc02040c4:	3d868693          	addi	a3,a3,984 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc02040c8:	40c58633          	sub	a2,a1,a2
ffffffffc02040cc:	630c                	ld	a1,0(a4)
ffffffffc02040ce:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02040d0:	577d                	li	a4,-1
ffffffffc02040d2:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc02040d4:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02040d6:	8331                	srli	a4,a4,0xc
ffffffffc02040d8:	8f71                	and	a4,a4,a2
ffffffffc02040da:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02040de:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02040e0:	02d77a63          	bleu	a3,a4,ffffffffc0204114 <swapfs_read+0x7e>
ffffffffc02040e4:	00012797          	auipc	a5,0x12
ffffffffc02040e8:	41478793          	addi	a5,a5,1044 # ffffffffc02164f8 <va_pa_offset>
ffffffffc02040ec:	639c                	ld	a5,0(a5)
}
ffffffffc02040ee:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040f0:	46a1                	li	a3,8
ffffffffc02040f2:	963e                	add	a2,a2,a5
ffffffffc02040f4:	4505                	li	a0,1
}
ffffffffc02040f6:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040f8:	c90fc06f          	j	ffffffffc0200588 <ide_read_secs>
ffffffffc02040fc:	86aa                	mv	a3,a0
ffffffffc02040fe:	00003617          	auipc	a2,0x3
ffffffffc0204102:	b4260613          	addi	a2,a2,-1214 # ffffffffc0206c40 <default_pmm_manager+0xf90>
ffffffffc0204106:	45d1                	li	a1,20
ffffffffc0204108:	00003517          	auipc	a0,0x3
ffffffffc020410c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0206c28 <default_pmm_manager+0xf78>
ffffffffc0204110:	b40fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0204114:	86b2                	mv	a3,a2
ffffffffc0204116:	06900593          	li	a1,105
ffffffffc020411a:	00002617          	auipc	a2,0x2
ffffffffc020411e:	be660613          	addi	a2,a2,-1050 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc0204122:	00002517          	auipc	a0,0x2
ffffffffc0204126:	c0650513          	addi	a0,a0,-1018 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc020412a:	b26fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020412e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc020412e:	1141                	addi	sp,sp,-16
ffffffffc0204130:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204132:	00855793          	srli	a5,a0,0x8
ffffffffc0204136:	cfb9                	beqz	a5,ffffffffc0204194 <swapfs_write+0x66>
ffffffffc0204138:	00012717          	auipc	a4,0x12
ffffffffc020413c:	46070713          	addi	a4,a4,1120 # ffffffffc0216598 <max_swap_offset>
ffffffffc0204140:	6318                	ld	a4,0(a4)
ffffffffc0204142:	04e7f963          	bleu	a4,a5,ffffffffc0204194 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204146:	00012717          	auipc	a4,0x12
ffffffffc020414a:	3c270713          	addi	a4,a4,962 # ffffffffc0216508 <pages>
ffffffffc020414e:	6310                	ld	a2,0(a4)
ffffffffc0204150:	00003717          	auipc	a4,0x3
ffffffffc0204154:	f0870713          	addi	a4,a4,-248 # ffffffffc0207058 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204158:	00012697          	auipc	a3,0x12
ffffffffc020415c:	34068693          	addi	a3,a3,832 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0204160:	40c58633          	sub	a2,a1,a2
ffffffffc0204164:	630c                	ld	a1,0(a4)
ffffffffc0204166:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204168:	577d                	li	a4,-1
ffffffffc020416a:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc020416c:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020416e:	8331                	srli	a4,a4,0xc
ffffffffc0204170:	8f71                	and	a4,a4,a2
ffffffffc0204172:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204176:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204178:	02d77a63          	bleu	a3,a4,ffffffffc02041ac <swapfs_write+0x7e>
ffffffffc020417c:	00012797          	auipc	a5,0x12
ffffffffc0204180:	37c78793          	addi	a5,a5,892 # ffffffffc02164f8 <va_pa_offset>
ffffffffc0204184:	639c                	ld	a5,0(a5)
}
ffffffffc0204186:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204188:	46a1                	li	a3,8
ffffffffc020418a:	963e                	add	a2,a2,a5
ffffffffc020418c:	4505                	li	a0,1
}
ffffffffc020418e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204190:	c1cfc06f          	j	ffffffffc02005ac <ide_write_secs>
ffffffffc0204194:	86aa                	mv	a3,a0
ffffffffc0204196:	00003617          	auipc	a2,0x3
ffffffffc020419a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206c40 <default_pmm_manager+0xf90>
ffffffffc020419e:	45e5                	li	a1,25
ffffffffc02041a0:	00003517          	auipc	a0,0x3
ffffffffc02041a4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0206c28 <default_pmm_manager+0xf78>
ffffffffc02041a8:	aa8fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02041ac:	86b2                	mv	a3,a2
ffffffffc02041ae:	06900593          	li	a1,105
ffffffffc02041b2:	00002617          	auipc	a2,0x2
ffffffffc02041b6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc02041ba:	00002517          	auipc	a0,0x2
ffffffffc02041be:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc02041c2:	a8efc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02041c6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02041c6:	8526                	mv	a0,s1
	jalr s0
ffffffffc02041c8:	9402                	jalr	s0

	jal do_exit
ffffffffc02041ca:	540000ef          	jal	ra,ffffffffc020470a <do_exit>

ffffffffc02041ce <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc02041ce:	1141                	addi	sp,sp,-16
    // 通过kmalloc函数获得proc_struct结构的一块内存块，作为进程控制块
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041d0:	0e800513          	li	a0,232
{
ffffffffc02041d4:	e022                	sd	s0,0(sp)
ffffffffc02041d6:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041d8:	fe6fd0ef          	jal	ra,ffffffffc02019be <kmalloc>
ffffffffc02041dc:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02041de:	c529                	beqz	a0,ffffffffc0204228 <alloc_proc+0x5a>
         *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */

        proc->state = PROC_UNINIT;
ffffffffc02041e0:	57fd                	li	a5,-1
ffffffffc02041e2:	1782                	slli	a5,a5,0x20
ffffffffc02041e4:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041e6:	07000613          	li	a2,112
ffffffffc02041ea:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc02041ec:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc02041f0:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc02041f4:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc02041f8:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc02041fc:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204200:	03050513          	addi	a0,a0,48
ffffffffc0204204:	517000ef          	jal	ra,ffffffffc0204f1a <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204208:	00012797          	auipc	a5,0x12
ffffffffc020420c:	2f878793          	addi	a5,a5,760 # ffffffffc0216500 <boot_cr3>
ffffffffc0204210:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204212:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204216:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc020421a:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc020421c:	463d                	li	a2,15
ffffffffc020421e:	4581                	li	a1,0
ffffffffc0204220:	0b440513          	addi	a0,s0,180
ffffffffc0204224:	4f7000ef          	jal	ra,ffffffffc0204f1a <memset>
    }
    return proc;
}
ffffffffc0204228:	8522                	mv	a0,s0
ffffffffc020422a:	60a2                	ld	ra,8(sp)
ffffffffc020422c:	6402                	ld	s0,0(sp)
ffffffffc020422e:	0141                	addi	sp,sp,16
ffffffffc0204230:	8082                	ret

ffffffffc0204232 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204232:	00012797          	auipc	a5,0x12
ffffffffc0204236:	27e78793          	addi	a5,a5,638 # ffffffffc02164b0 <current>
ffffffffc020423a:	639c                	ld	a5,0(a5)
ffffffffc020423c:	73c8                	ld	a0,160(a5)
ffffffffc020423e:	97ffc06f          	j	ffffffffc0200bbc <forkrets>

ffffffffc0204242 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204242:	1101                	addi	sp,sp,-32
ffffffffc0204244:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204246:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020424a:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020424c:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020424e:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204250:	8522                	mv	a0,s0
ffffffffc0204252:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204254:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204256:	4c5000ef          	jal	ra,ffffffffc0204f1a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020425a:	8522                	mv	a0,s0
}
ffffffffc020425c:	6442                	ld	s0,16(sp)
ffffffffc020425e:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204260:	85a6                	mv	a1,s1
}
ffffffffc0204262:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204264:	463d                	li	a2,15
}
ffffffffc0204266:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204268:	4c50006f          	j	ffffffffc0204f2c <memcpy>

ffffffffc020426c <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc020426c:	1101                	addi	sp,sp,-32
ffffffffc020426e:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204270:	00012417          	auipc	s0,0x12
ffffffffc0204274:	1f040413          	addi	s0,s0,496 # ffffffffc0216460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc0204278:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc020427a:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc020427c:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc020427e:	4581                	li	a1,0
ffffffffc0204280:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc0204282:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204284:	497000ef          	jal	ra,ffffffffc0204f1a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204288:	8522                	mv	a0,s0
}
ffffffffc020428a:	6442                	ld	s0,16(sp)
ffffffffc020428c:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020428e:	0b448593          	addi	a1,s1,180
}
ffffffffc0204292:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204294:	463d                	li	a2,15
}
ffffffffc0204296:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204298:	4950006f          	j	ffffffffc0204f2c <memcpy>

ffffffffc020429c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020429c:	00012797          	auipc	a5,0x12
ffffffffc02042a0:	21478793          	addi	a5,a5,532 # ffffffffc02164b0 <current>
ffffffffc02042a4:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02042a6:	1101                	addi	sp,sp,-32
ffffffffc02042a8:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042aa:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02042ac:	e822                	sd	s0,16(sp)
ffffffffc02042ae:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042b0:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02042b2:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042b4:	fb9ff0ef          	jal	ra,ffffffffc020426c <get_proc_name>
ffffffffc02042b8:	862a                	mv	a2,a0
ffffffffc02042ba:	85a6                	mv	a1,s1
ffffffffc02042bc:	00003517          	auipc	a0,0x3
ffffffffc02042c0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0206ca8 <default_pmm_manager+0xff8>
ffffffffc02042c4:	ecbfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02042c8:	85a2                	mv	a1,s0
ffffffffc02042ca:	00003517          	auipc	a0,0x3
ffffffffc02042ce:	a0650513          	addi	a0,a0,-1530 # ffffffffc0206cd0 <default_pmm_manager+0x1020>
ffffffffc02042d2:	ebdfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02042d6:	00003517          	auipc	a0,0x3
ffffffffc02042da:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0206ce0 <default_pmm_manager+0x1030>
ffffffffc02042de:	eb1fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02042e2:	60e2                	ld	ra,24(sp)
ffffffffc02042e4:	6442                	ld	s0,16(sp)
ffffffffc02042e6:	64a2                	ld	s1,8(sp)
ffffffffc02042e8:	4501                	li	a0,0
ffffffffc02042ea:	6105                	addi	sp,sp,32
ffffffffc02042ec:	8082                	ret

ffffffffc02042ee <proc_run>:
{
ffffffffc02042ee:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02042f0:	00012797          	auipc	a5,0x12
ffffffffc02042f4:	1c078793          	addi	a5,a5,448 # ffffffffc02164b0 <current>
{
ffffffffc02042f8:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc02042fa:	6384                	ld	s1,0(a5)
{
ffffffffc02042fc:	ec06                	sd	ra,24(sp)
ffffffffc02042fe:	e822                	sd	s0,16(sp)
ffffffffc0204300:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204302:	02a48c63          	beq	s1,a0,ffffffffc020433a <proc_run+0x4c>
ffffffffc0204306:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204308:	100027f3          	csrr	a5,sstatus
ffffffffc020430c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020430e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204310:	e3b1                	bnez	a5,ffffffffc0204354 <proc_run+0x66>
            lcr3(next->cr3);
ffffffffc0204312:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204314:	00012717          	auipc	a4,0x12
ffffffffc0204318:	18873e23          	sd	s0,412(a4) # ffffffffc02164b0 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020431c:	80000737          	lui	a4,0x80000
ffffffffc0204320:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204324:	8fd9                	or	a5,a5,a4
ffffffffc0204326:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc020432a:	03040593          	addi	a1,s0,48
ffffffffc020432e:	03048513          	addi	a0,s1,48
ffffffffc0204332:	604000ef          	jal	ra,ffffffffc0204936 <switch_to>
    if (flag) {
ffffffffc0204336:	00091863          	bnez	s2,ffffffffc0204346 <proc_run+0x58>
}
ffffffffc020433a:	60e2                	ld	ra,24(sp)
ffffffffc020433c:	6442                	ld	s0,16(sp)
ffffffffc020433e:	64a2                	ld	s1,8(sp)
ffffffffc0204340:	6902                	ld	s2,0(sp)
ffffffffc0204342:	6105                	addi	sp,sp,32
ffffffffc0204344:	8082                	ret
ffffffffc0204346:	6442                	ld	s0,16(sp)
ffffffffc0204348:	60e2                	ld	ra,24(sp)
ffffffffc020434a:	64a2                	ld	s1,8(sp)
ffffffffc020434c:	6902                	ld	s2,0(sp)
ffffffffc020434e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204350:	a82fc06f          	j	ffffffffc02005d2 <intr_enable>
        intr_disable();
ffffffffc0204354:	a84fc0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc0204358:	4905                	li	s2,1
ffffffffc020435a:	bf65                	j	ffffffffc0204312 <proc_run+0x24>

ffffffffc020435c <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc020435c:	0005071b          	sext.w	a4,a0
ffffffffc0204360:	6789                	lui	a5,0x2
ffffffffc0204362:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204366:	17f9                	addi	a5,a5,-2
ffffffffc0204368:	04d7e063          	bltu	a5,a3,ffffffffc02043a8 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc020436c:	1141                	addi	sp,sp,-16
ffffffffc020436e:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204370:	45a9                	li	a1,10
ffffffffc0204372:	842a                	mv	s0,a0
ffffffffc0204374:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204376:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204378:	6f4000ef          	jal	ra,ffffffffc0204a6c <hash32>
ffffffffc020437c:	02051693          	slli	a3,a0,0x20
ffffffffc0204380:	82f1                	srli	a3,a3,0x1c
ffffffffc0204382:	0000e517          	auipc	a0,0xe
ffffffffc0204386:	0de50513          	addi	a0,a0,222 # ffffffffc0212460 <hash_list>
ffffffffc020438a:	96aa                	add	a3,a3,a0
ffffffffc020438c:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020438e:	a029                	j	ffffffffc0204398 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204390:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc0204394:	00870c63          	beq	a4,s0,ffffffffc02043ac <find_proc+0x50>
ffffffffc0204398:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020439a:	fef69be3          	bne	a3,a5,ffffffffc0204390 <find_proc+0x34>
}
ffffffffc020439e:	60a2                	ld	ra,8(sp)
ffffffffc02043a0:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02043a2:	4501                	li	a0,0
}
ffffffffc02043a4:	0141                	addi	sp,sp,16
ffffffffc02043a6:	8082                	ret
    return NULL;
ffffffffc02043a8:	4501                	li	a0,0
}
ffffffffc02043aa:	8082                	ret
ffffffffc02043ac:	60a2                	ld	ra,8(sp)
ffffffffc02043ae:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02043b0:	f2878513          	addi	a0,a5,-216
}
ffffffffc02043b4:	0141                	addi	sp,sp,16
ffffffffc02043b6:	8082                	ret

ffffffffc02043b8 <do_fork>:
{
ffffffffc02043b8:	7179                	addi	sp,sp,-48
ffffffffc02043ba:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043bc:	00012917          	auipc	s2,0x12
ffffffffc02043c0:	10c90913          	addi	s2,s2,268 # ffffffffc02164c8 <nr_process>
ffffffffc02043c4:	00092703          	lw	a4,0(s2)
{
ffffffffc02043c8:	f406                	sd	ra,40(sp)
ffffffffc02043ca:	f022                	sd	s0,32(sp)
ffffffffc02043cc:	ec26                	sd	s1,24(sp)
ffffffffc02043ce:	e44e                	sd	s3,8(sp)
ffffffffc02043d0:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043d2:	6785                	lui	a5,0x1
ffffffffc02043d4:	26f75b63          	ble	a5,a4,ffffffffc020464a <do_fork+0x292>
ffffffffc02043d8:	89ae                	mv	s3,a1
ffffffffc02043da:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL) { // 分配proc_struct结构体并初始化
ffffffffc02043dc:	df3ff0ef          	jal	ra,ffffffffc02041ce <alloc_proc>
ffffffffc02043e0:	842a                	mv	s0,a0
ffffffffc02043e2:	26050663          	beqz	a0,ffffffffc020464e <do_fork+0x296>
    proc->parent = current; // 更新创建proc的parent父线程变量为当前线程
ffffffffc02043e6:	00012a17          	auipc	s4,0x12
ffffffffc02043ea:	0caa0a13          	addi	s4,s4,202 # ffffffffc02164b0 <current>
ffffffffc02043ee:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043f2:	4509                	li	a0,2
    proc->parent = current; // 更新创建proc的parent父线程变量为当前线程
ffffffffc02043f4:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043f6:	fc4fd0ef          	jal	ra,ffffffffc0201bba <alloc_pages>
    if (page != NULL) {
ffffffffc02043fa:	1e050f63          	beqz	a0,ffffffffc02045f8 <do_fork+0x240>
    return page - pages + nbase;
ffffffffc02043fe:	00012797          	auipc	a5,0x12
ffffffffc0204402:	10a78793          	addi	a5,a5,266 # ffffffffc0216508 <pages>
ffffffffc0204406:	6394                	ld	a3,0(a5)
ffffffffc0204408:	00003797          	auipc	a5,0x3
ffffffffc020440c:	c5078793          	addi	a5,a5,-944 # ffffffffc0207058 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204410:	00012717          	auipc	a4,0x12
ffffffffc0204414:	08870713          	addi	a4,a4,136 # ffffffffc0216498 <npage>
    return page - pages + nbase;
ffffffffc0204418:	40d506b3          	sub	a3,a0,a3
ffffffffc020441c:	6388                	ld	a0,0(a5)
ffffffffc020441e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204420:	57fd                	li	a5,-1
ffffffffc0204422:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204424:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204426:	83b1                	srli	a5,a5,0xc
ffffffffc0204428:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020442a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020442c:	24e7f363          	bleu	a4,a5,ffffffffc0204672 <do_fork+0x2ba>
    assert(current->mm == NULL);
ffffffffc0204430:	000a3783          	ld	a5,0(s4)
ffffffffc0204434:	00012717          	auipc	a4,0x12
ffffffffc0204438:	0c470713          	addi	a4,a4,196 # ffffffffc02164f8 <va_pa_offset>
ffffffffc020443c:	6318                	ld	a4,0(a4)
ffffffffc020443e:	779c                	ld	a5,40(a5)
ffffffffc0204440:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204442:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204444:	20079763          	bnez	a5,ffffffffc0204652 <do_fork+0x29a>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204448:	6789                	lui	a5,0x2
ffffffffc020444a:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc020444e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204450:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204452:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204454:	87b6                	mv	a5,a3
ffffffffc0204456:	12048893          	addi	a7,s1,288
ffffffffc020445a:	00063803          	ld	a6,0(a2)
ffffffffc020445e:	6608                	ld	a0,8(a2)
ffffffffc0204460:	6a0c                	ld	a1,16(a2)
ffffffffc0204462:	6e18                	ld	a4,24(a2)
ffffffffc0204464:	0107b023          	sd	a6,0(a5)
ffffffffc0204468:	e788                	sd	a0,8(a5)
ffffffffc020446a:	eb8c                	sd	a1,16(a5)
ffffffffc020446c:	ef98                	sd	a4,24(a5)
ffffffffc020446e:	02060613          	addi	a2,a2,32
ffffffffc0204472:	02078793          	addi	a5,a5,32
ffffffffc0204476:	ff1612e3          	bne	a2,a7,ffffffffc020445a <do_fork+0xa2>
    proc->tf->gpr.a0 = 0;
ffffffffc020447a:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020447e:	10098e63          	beqz	s3,ffffffffc020459a <do_fork+0x1e2>
ffffffffc0204482:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204486:	00000797          	auipc	a5,0x0
ffffffffc020448a:	dac78793          	addi	a5,a5,-596 # ffffffffc0204232 <forkret>
ffffffffc020448e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204490:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204492:	100027f3          	csrr	a5,sstatus
ffffffffc0204496:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204498:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020449a:	10079f63          	bnez	a5,ffffffffc02045b8 <do_fork+0x200>
    if (++ last_pid >= MAX_PID) {
ffffffffc020449e:	00007797          	auipc	a5,0x7
ffffffffc02044a2:	bba78793          	addi	a5,a5,-1094 # ffffffffc020b058 <last_pid.1575>
ffffffffc02044a6:	439c                	lw	a5,0(a5)
ffffffffc02044a8:	6709                	lui	a4,0x2
ffffffffc02044aa:	0017851b          	addiw	a0,a5,1
ffffffffc02044ae:	00007697          	auipc	a3,0x7
ffffffffc02044b2:	baa6a523          	sw	a0,-1110(a3) # ffffffffc020b058 <last_pid.1575>
ffffffffc02044b6:	12e55263          	ble	a4,a0,ffffffffc02045da <do_fork+0x222>
    if (last_pid >= next_safe) {
ffffffffc02044ba:	00007797          	auipc	a5,0x7
ffffffffc02044be:	ba278793          	addi	a5,a5,-1118 # ffffffffc020b05c <next_safe.1574>
ffffffffc02044c2:	439c                	lw	a5,0(a5)
ffffffffc02044c4:	00012497          	auipc	s1,0x12
ffffffffc02044c8:	12c48493          	addi	s1,s1,300 # ffffffffc02165f0 <proc_list>
ffffffffc02044cc:	06f54063          	blt	a0,a5,ffffffffc020452c <do_fork+0x174>
        next_safe = MAX_PID;
ffffffffc02044d0:	6789                	lui	a5,0x2
ffffffffc02044d2:	00007717          	auipc	a4,0x7
ffffffffc02044d6:	b8f72523          	sw	a5,-1142(a4) # ffffffffc020b05c <next_safe.1574>
ffffffffc02044da:	4581                	li	a1,0
ffffffffc02044dc:	87aa                	mv	a5,a0
ffffffffc02044de:	00012497          	auipc	s1,0x12
ffffffffc02044e2:	11248493          	addi	s1,s1,274 # ffffffffc02165f0 <proc_list>
    repeat:
ffffffffc02044e6:	6889                	lui	a7,0x2
ffffffffc02044e8:	882e                	mv	a6,a1
ffffffffc02044ea:	6609                	lui	a2,0x2
        le = list;
ffffffffc02044ec:	00012697          	auipc	a3,0x12
ffffffffc02044f0:	10468693          	addi	a3,a3,260 # ffffffffc02165f0 <proc_list>
ffffffffc02044f4:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02044f6:	00968f63          	beq	a3,s1,ffffffffc0204514 <do_fork+0x15c>
            if (proc->pid == last_pid) {
ffffffffc02044fa:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02044fe:	08e78963          	beq	a5,a4,ffffffffc0204590 <do_fork+0x1d8>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204502:	fee7d9e3          	ble	a4,a5,ffffffffc02044f4 <do_fork+0x13c>
ffffffffc0204506:	fec757e3          	ble	a2,a4,ffffffffc02044f4 <do_fork+0x13c>
ffffffffc020450a:	6694                	ld	a3,8(a3)
ffffffffc020450c:	863a                	mv	a2,a4
ffffffffc020450e:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204510:	fe9695e3          	bne	a3,s1,ffffffffc02044fa <do_fork+0x142>
ffffffffc0204514:	c591                	beqz	a1,ffffffffc0204520 <do_fork+0x168>
ffffffffc0204516:	00007717          	auipc	a4,0x7
ffffffffc020451a:	b4f72123          	sw	a5,-1214(a4) # ffffffffc020b058 <last_pid.1575>
ffffffffc020451e:	853e                	mv	a0,a5
ffffffffc0204520:	00080663          	beqz	a6,ffffffffc020452c <do_fork+0x174>
ffffffffc0204524:	00007797          	auipc	a5,0x7
ffffffffc0204528:	b2c7ac23          	sw	a2,-1224(a5) # ffffffffc020b05c <next_safe.1574>
        proc->pid = get_pid();  // 为创建的进程proc分配一个pid号
ffffffffc020452c:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020452e:	45a9                	li	a1,10
ffffffffc0204530:	2501                	sext.w	a0,a0
ffffffffc0204532:	53a000ef          	jal	ra,ffffffffc0204a6c <hash32>
ffffffffc0204536:	1502                	slli	a0,a0,0x20
ffffffffc0204538:	0000e797          	auipc	a5,0xe
ffffffffc020453c:	f2878793          	addi	a5,a5,-216 # ffffffffc0212460 <hash_list>
ffffffffc0204540:	8171                	srli	a0,a0,0x1c
ffffffffc0204542:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204544:	6510                	ld	a2,8(a0)
ffffffffc0204546:	0d840793          	addi	a5,s0,216
ffffffffc020454a:	6494                	ld	a3,8(s1)
        nr_process++; // 进程块数+1
ffffffffc020454c:	00092703          	lw	a4,0(s2)
    prev->next = next->prev = elm;
ffffffffc0204550:	e21c                	sd	a5,0(a2)
ffffffffc0204552:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204554:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc0204556:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc020455a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020455c:	e29c                	sd	a5,0(a3)
        nr_process++; // 进程块数+1
ffffffffc020455e:	2705                	addiw	a4,a4,1
ffffffffc0204560:	00012617          	auipc	a2,0x12
ffffffffc0204564:	08f63c23          	sd	a5,152(a2) # ffffffffc02165f8 <proc_list+0x8>
    elm->next = next;
ffffffffc0204568:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc020456a:	e464                	sd	s1,200(s0)
ffffffffc020456c:	00012797          	auipc	a5,0x12
ffffffffc0204570:	f4e7ae23          	sw	a4,-164(a5) # ffffffffc02164c8 <nr_process>
    if (flag) {
ffffffffc0204574:	06099a63          	bnez	s3,ffffffffc02045e8 <do_fork+0x230>
    wakeup_proc(proc); // 将创建线程设置为就绪状态：PROC_RUNNABLE
ffffffffc0204578:	8522                	mv	a0,s0
ffffffffc020457a:	426000ef          	jal	ra,ffffffffc02049a0 <wakeup_proc>
    ret = proc->pid; // 返回值设置为线程id
ffffffffc020457e:	4048                	lw	a0,4(s0)
}
ffffffffc0204580:	70a2                	ld	ra,40(sp)
ffffffffc0204582:	7402                	ld	s0,32(sp)
ffffffffc0204584:	64e2                	ld	s1,24(sp)
ffffffffc0204586:	6942                	ld	s2,16(sp)
ffffffffc0204588:	69a2                	ld	s3,8(sp)
ffffffffc020458a:	6a02                	ld	s4,0(sp)
ffffffffc020458c:	6145                	addi	sp,sp,48
ffffffffc020458e:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204590:	2785                	addiw	a5,a5,1
ffffffffc0204592:	04c7de63          	ble	a2,a5,ffffffffc02045ee <do_fork+0x236>
ffffffffc0204596:	4585                	li	a1,1
ffffffffc0204598:	bfb1                	j	ffffffffc02044f4 <do_fork+0x13c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020459a:	89b6                	mv	s3,a3
ffffffffc020459c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02045a0:	00000797          	auipc	a5,0x0
ffffffffc02045a4:	c9278793          	addi	a5,a5,-878 # ffffffffc0204232 <forkret>
ffffffffc02045a8:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02045aa:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045ac:	100027f3          	csrr	a5,sstatus
ffffffffc02045b0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045b2:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045b4:	ee0785e3          	beqz	a5,ffffffffc020449e <do_fork+0xe6>
        intr_disable();
ffffffffc02045b8:	820fc0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02045bc:	00007797          	auipc	a5,0x7
ffffffffc02045c0:	a9c78793          	addi	a5,a5,-1380 # ffffffffc020b058 <last_pid.1575>
ffffffffc02045c4:	439c                	lw	a5,0(a5)
ffffffffc02045c6:	6709                	lui	a4,0x2
        return 1;
ffffffffc02045c8:	4985                	li	s3,1
ffffffffc02045ca:	0017851b          	addiw	a0,a5,1
ffffffffc02045ce:	00007697          	auipc	a3,0x7
ffffffffc02045d2:	a8a6a523          	sw	a0,-1398(a3) # ffffffffc020b058 <last_pid.1575>
ffffffffc02045d6:	eee542e3          	blt	a0,a4,ffffffffc02044ba <do_fork+0x102>
        last_pid = 1;
ffffffffc02045da:	4785                	li	a5,1
ffffffffc02045dc:	00007717          	auipc	a4,0x7
ffffffffc02045e0:	a6f72e23          	sw	a5,-1412(a4) # ffffffffc020b058 <last_pid.1575>
ffffffffc02045e4:	4505                	li	a0,1
ffffffffc02045e6:	b5ed                	j	ffffffffc02044d0 <do_fork+0x118>
        intr_enable();
ffffffffc02045e8:	febfb0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc02045ec:	b771                	j	ffffffffc0204578 <do_fork+0x1c0>
                    if (last_pid >= MAX_PID) {
ffffffffc02045ee:	0117c363          	blt	a5,a7,ffffffffc02045f4 <do_fork+0x23c>
                        last_pid = 1;
ffffffffc02045f2:	4785                	li	a5,1
                    goto repeat;
ffffffffc02045f4:	4585                	li	a1,1
ffffffffc02045f6:	bdcd                	j	ffffffffc02044e8 <do_fork+0x130>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02045f8:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02045fa:	c02007b7          	lui	a5,0xc0200
ffffffffc02045fe:	0af6e263          	bltu	a3,a5,ffffffffc02046a2 <do_fork+0x2ea>
ffffffffc0204602:	00012797          	auipc	a5,0x12
ffffffffc0204606:	ef678793          	addi	a5,a5,-266 # ffffffffc02164f8 <va_pa_offset>
ffffffffc020460a:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020460c:	00012717          	auipc	a4,0x12
ffffffffc0204610:	e8c70713          	addi	a4,a4,-372 # ffffffffc0216498 <npage>
ffffffffc0204614:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc0204616:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020461a:	83b1                	srli	a5,a5,0xc
ffffffffc020461c:	06e7f763          	bleu	a4,a5,ffffffffc020468a <do_fork+0x2d2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204620:	00003717          	auipc	a4,0x3
ffffffffc0204624:	a3870713          	addi	a4,a4,-1480 # ffffffffc0207058 <nbase>
ffffffffc0204628:	6318                	ld	a4,0(a4)
ffffffffc020462a:	00012697          	auipc	a3,0x12
ffffffffc020462e:	ede68693          	addi	a3,a3,-290 # ffffffffc0216508 <pages>
ffffffffc0204632:	6288                	ld	a0,0(a3)
ffffffffc0204634:	8f99                	sub	a5,a5,a4
ffffffffc0204636:	079a                	slli	a5,a5,0x6
ffffffffc0204638:	953e                	add	a0,a0,a5
ffffffffc020463a:	4589                	li	a1,2
ffffffffc020463c:	e06fd0ef          	jal	ra,ffffffffc0201c42 <free_pages>
    kfree(proc);
ffffffffc0204640:	8522                	mv	a0,s0
ffffffffc0204642:	c38fd0ef          	jal	ra,ffffffffc0201a7a <kfree>
    ret = -E_NO_MEM;
ffffffffc0204646:	5571                	li	a0,-4
    goto fork_out;
ffffffffc0204648:	bf25                	j	ffffffffc0204580 <do_fork+0x1c8>
    int ret = -E_NO_FREE_PROC;
ffffffffc020464a:	556d                	li	a0,-5
ffffffffc020464c:	bf15                	j	ffffffffc0204580 <do_fork+0x1c8>
    ret = -E_NO_MEM;
ffffffffc020464e:	5571                	li	a0,-4
ffffffffc0204650:	bf05                	j	ffffffffc0204580 <do_fork+0x1c8>
    assert(current->mm == NULL);
ffffffffc0204652:	00002697          	auipc	a3,0x2
ffffffffc0204656:	62668693          	addi	a3,a3,1574 # ffffffffc0206c78 <default_pmm_manager+0xfc8>
ffffffffc020465a:	00001617          	auipc	a2,0x1
ffffffffc020465e:	2be60613          	addi	a2,a2,702 # ffffffffc0205918 <commands+0x870>
ffffffffc0204662:	11100593          	li	a1,273
ffffffffc0204666:	00002517          	auipc	a0,0x2
ffffffffc020466a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206c90 <default_pmm_manager+0xfe0>
ffffffffc020466e:	de3fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204672:	00001617          	auipc	a2,0x1
ffffffffc0204676:	68e60613          	addi	a2,a2,1678 # ffffffffc0205d00 <default_pmm_manager+0x50>
ffffffffc020467a:	06900593          	li	a1,105
ffffffffc020467e:	00001517          	auipc	a0,0x1
ffffffffc0204682:	6aa50513          	addi	a0,a0,1706 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc0204686:	dcbfb0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020468a:	00001617          	auipc	a2,0x1
ffffffffc020468e:	6d660613          	addi	a2,a2,1750 # ffffffffc0205d60 <default_pmm_manager+0xb0>
ffffffffc0204692:	06200593          	li	a1,98
ffffffffc0204696:	00001517          	auipc	a0,0x1
ffffffffc020469a:	69250513          	addi	a0,a0,1682 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc020469e:	db3fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02046a2:	00001617          	auipc	a2,0x1
ffffffffc02046a6:	69660613          	addi	a2,a2,1686 # ffffffffc0205d38 <default_pmm_manager+0x88>
ffffffffc02046aa:	06e00593          	li	a1,110
ffffffffc02046ae:	00001517          	auipc	a0,0x1
ffffffffc02046b2:	67a50513          	addi	a0,a0,1658 # ffffffffc0205d28 <default_pmm_manager+0x78>
ffffffffc02046b6:	d9bfb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02046ba <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02046ba:	7129                	addi	sp,sp,-320
ffffffffc02046bc:	fa22                	sd	s0,304(sp)
ffffffffc02046be:	f626                	sd	s1,296(sp)
ffffffffc02046c0:	f24a                	sd	s2,288(sp)
ffffffffc02046c2:	84ae                	mv	s1,a1
ffffffffc02046c4:	892a                	mv	s2,a0
ffffffffc02046c6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046c8:	4581                	li	a1,0
ffffffffc02046ca:	12000613          	li	a2,288
ffffffffc02046ce:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02046d0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02046d2:	049000ef          	jal	ra,ffffffffc0204f1a <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02046d6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02046d8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02046da:	100027f3          	csrr	a5,sstatus
ffffffffc02046de:	edd7f793          	andi	a5,a5,-291
ffffffffc02046e2:	1207e793          	ori	a5,a5,288
ffffffffc02046e6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046e8:	860a                	mv	a2,sp
ffffffffc02046ea:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046ee:	00000797          	auipc	a5,0x0
ffffffffc02046f2:	ad878793          	addi	a5,a5,-1320 # ffffffffc02041c6 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046f6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046f8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046fa:	cbfff0ef          	jal	ra,ffffffffc02043b8 <do_fork>
}
ffffffffc02046fe:	70f2                	ld	ra,312(sp)
ffffffffc0204700:	7452                	ld	s0,304(sp)
ffffffffc0204702:	74b2                	ld	s1,296(sp)
ffffffffc0204704:	7912                	ld	s2,288(sp)
ffffffffc0204706:	6131                	addi	sp,sp,320
ffffffffc0204708:	8082                	ret

ffffffffc020470a <do_exit>:
do_exit(int error_code) {
ffffffffc020470a:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc020470c:	00002617          	auipc	a2,0x2
ffffffffc0204710:	55460613          	addi	a2,a2,1364 # ffffffffc0206c60 <default_pmm_manager+0xfb0>
ffffffffc0204714:	17900593          	li	a1,377
ffffffffc0204718:	00002517          	auipc	a0,0x2
ffffffffc020471c:	57850513          	addi	a0,a0,1400 # ffffffffc0206c90 <default_pmm_manager+0xfe0>
do_exit(int error_code) {
ffffffffc0204720:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204722:	d2ffb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204726 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0204726:	00012797          	auipc	a5,0x12
ffffffffc020472a:	eca78793          	addi	a5,a5,-310 # ffffffffc02165f0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc020472e:	1101                	addi	sp,sp,-32
ffffffffc0204730:	00012717          	auipc	a4,0x12
ffffffffc0204734:	ecf73423          	sd	a5,-312(a4) # ffffffffc02165f8 <proc_list+0x8>
ffffffffc0204738:	00012717          	auipc	a4,0x12
ffffffffc020473c:	eaf73c23          	sd	a5,-328(a4) # ffffffffc02165f0 <proc_list>
ffffffffc0204740:	ec06                	sd	ra,24(sp)
ffffffffc0204742:	e822                	sd	s0,16(sp)
ffffffffc0204744:	e426                	sd	s1,8(sp)
ffffffffc0204746:	e04a                	sd	s2,0(sp)
ffffffffc0204748:	0000e797          	auipc	a5,0xe
ffffffffc020474c:	d1878793          	addi	a5,a5,-744 # ffffffffc0212460 <hash_list>
ffffffffc0204750:	00012717          	auipc	a4,0x12
ffffffffc0204754:	d1070713          	addi	a4,a4,-752 # ffffffffc0216460 <name.1565>
ffffffffc0204758:	e79c                	sd	a5,8(a5)
ffffffffc020475a:	e39c                	sd	a5,0(a5)
ffffffffc020475c:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020475e:	fee79de3          	bne	a5,a4,ffffffffc0204758 <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204762:	a6dff0ef          	jal	ra,ffffffffc02041ce <alloc_proc>
ffffffffc0204766:	00012797          	auipc	a5,0x12
ffffffffc020476a:	d4a7b923          	sd	a0,-686(a5) # ffffffffc02164b8 <idleproc>
ffffffffc020476e:	00012417          	auipc	s0,0x12
ffffffffc0204772:	d4a40413          	addi	s0,s0,-694 # ffffffffc02164b8 <idleproc>
ffffffffc0204776:	12050a63          	beqz	a0,ffffffffc02048aa <proc_init+0x184>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020477a:	07000513          	li	a0,112
ffffffffc020477e:	a40fd0ef          	jal	ra,ffffffffc02019be <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204782:	07000613          	li	a2,112
ffffffffc0204786:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204788:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020478a:	790000ef          	jal	ra,ffffffffc0204f1a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020478e:	6008                	ld	a0,0(s0)
ffffffffc0204790:	85a6                	mv	a1,s1
ffffffffc0204792:	07000613          	li	a2,112
ffffffffc0204796:	03050513          	addi	a0,a0,48
ffffffffc020479a:	7aa000ef          	jal	ra,ffffffffc0204f44 <memcmp>
ffffffffc020479e:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02047a0:	453d                	li	a0,15
ffffffffc02047a2:	a1cfd0ef          	jal	ra,ffffffffc02019be <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02047a6:	463d                	li	a2,15
ffffffffc02047a8:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02047aa:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02047ac:	76e000ef          	jal	ra,ffffffffc0204f1a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02047b0:	6008                	ld	a0,0(s0)
ffffffffc02047b2:	463d                	li	a2,15
ffffffffc02047b4:	85a6                	mv	a1,s1
ffffffffc02047b6:	0b450513          	addi	a0,a0,180
ffffffffc02047ba:	78a000ef          	jal	ra,ffffffffc0204f44 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047be:	601c                	ld	a5,0(s0)
ffffffffc02047c0:	00012717          	auipc	a4,0x12
ffffffffc02047c4:	d4070713          	addi	a4,a4,-704 # ffffffffc0216500 <boot_cr3>
ffffffffc02047c8:	6318                	ld	a4,0(a4)
ffffffffc02047ca:	77d4                	ld	a3,168(a5)
ffffffffc02047cc:	08e68e63          	beq	a3,a4,ffffffffc0204868 <proc_init+0x142>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02047d0:	4709                	li	a4,2
ffffffffc02047d2:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02047d4:	00004717          	auipc	a4,0x4
ffffffffc02047d8:	82c70713          	addi	a4,a4,-2004 # ffffffffc0208000 <bootstack>
ffffffffc02047dc:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02047de:	4705                	li	a4,1
ffffffffc02047e0:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02047e2:	00002597          	auipc	a1,0x2
ffffffffc02047e6:	54e58593          	addi	a1,a1,1358 # ffffffffc0206d30 <default_pmm_manager+0x1080>
ffffffffc02047ea:	853e                	mv	a0,a5
ffffffffc02047ec:	a57ff0ef          	jal	ra,ffffffffc0204242 <set_proc_name>
    nr_process ++;
ffffffffc02047f0:	00012797          	auipc	a5,0x12
ffffffffc02047f4:	cd878793          	addi	a5,a5,-808 # ffffffffc02164c8 <nr_process>
ffffffffc02047f8:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02047fa:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047fc:	4601                	li	a2,0
    nr_process ++;
ffffffffc02047fe:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204800:	00002597          	auipc	a1,0x2
ffffffffc0204804:	53858593          	addi	a1,a1,1336 # ffffffffc0206d38 <default_pmm_manager+0x1088>
ffffffffc0204808:	00000517          	auipc	a0,0x0
ffffffffc020480c:	a9450513          	addi	a0,a0,-1388 # ffffffffc020429c <init_main>
    nr_process ++;
ffffffffc0204810:	00012697          	auipc	a3,0x12
ffffffffc0204814:	caf6ac23          	sw	a5,-840(a3) # ffffffffc02164c8 <nr_process>
    current = idleproc;
ffffffffc0204818:	00012797          	auipc	a5,0x12
ffffffffc020481c:	c8e7bc23          	sd	a4,-872(a5) # ffffffffc02164b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204820:	e9bff0ef          	jal	ra,ffffffffc02046ba <kernel_thread>
    if (pid <= 0) {
ffffffffc0204824:	0ca05f63          	blez	a0,ffffffffc0204902 <proc_init+0x1dc>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204828:	b35ff0ef          	jal	ra,ffffffffc020435c <find_proc>
    set_proc_name(initproc, "init");
ffffffffc020482c:	00002597          	auipc	a1,0x2
ffffffffc0204830:	53c58593          	addi	a1,a1,1340 # ffffffffc0206d68 <default_pmm_manager+0x10b8>
    initproc = find_proc(pid);
ffffffffc0204834:	00012797          	auipc	a5,0x12
ffffffffc0204838:	c8a7b623          	sd	a0,-884(a5) # ffffffffc02164c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc020483c:	a07ff0ef          	jal	ra,ffffffffc0204242 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204840:	601c                	ld	a5,0(s0)
ffffffffc0204842:	c3c5                	beqz	a5,ffffffffc02048e2 <proc_init+0x1bc>
ffffffffc0204844:	43dc                	lw	a5,4(a5)
ffffffffc0204846:	efd1                	bnez	a5,ffffffffc02048e2 <proc_init+0x1bc>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204848:	00012797          	auipc	a5,0x12
ffffffffc020484c:	c7878793          	addi	a5,a5,-904 # ffffffffc02164c0 <initproc>
ffffffffc0204850:	639c                	ld	a5,0(a5)
ffffffffc0204852:	cba5                	beqz	a5,ffffffffc02048c2 <proc_init+0x19c>
ffffffffc0204854:	43d8                	lw	a4,4(a5)
ffffffffc0204856:	4785                	li	a5,1
ffffffffc0204858:	06f71563          	bne	a4,a5,ffffffffc02048c2 <proc_init+0x19c>
}
ffffffffc020485c:	60e2                	ld	ra,24(sp)
ffffffffc020485e:	6442                	ld	s0,16(sp)
ffffffffc0204860:	64a2                	ld	s1,8(sp)
ffffffffc0204862:	6902                	ld	s2,0(sp)
ffffffffc0204864:	6105                	addi	sp,sp,32
ffffffffc0204866:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204868:	73d8                	ld	a4,160(a5)
ffffffffc020486a:	f33d                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
ffffffffc020486c:	f60912e3          	bnez	s2,ffffffffc02047d0 <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204870:	6394                	ld	a3,0(a5)
ffffffffc0204872:	577d                	li	a4,-1
ffffffffc0204874:	1702                	slli	a4,a4,0x20
ffffffffc0204876:	f4e69de3          	bne	a3,a4,ffffffffc02047d0 <proc_init+0xaa>
ffffffffc020487a:	4798                	lw	a4,8(a5)
ffffffffc020487c:	fb31                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc020487e:	6b98                	ld	a4,16(a5)
ffffffffc0204880:	fb21                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
ffffffffc0204882:	4f98                	lw	a4,24(a5)
ffffffffc0204884:	2701                	sext.w	a4,a4
ffffffffc0204886:	f729                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
ffffffffc0204888:	7398                	ld	a4,32(a5)
ffffffffc020488a:	f339                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc020488c:	7798                	ld	a4,40(a5)
ffffffffc020488e:	f329                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
ffffffffc0204890:	0b07a703          	lw	a4,176(a5)
ffffffffc0204894:	8f49                	or	a4,a4,a0
ffffffffc0204896:	2701                	sext.w	a4,a4
ffffffffc0204898:	ff05                	bnez	a4,ffffffffc02047d0 <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc020489a:	00002517          	auipc	a0,0x2
ffffffffc020489e:	47e50513          	addi	a0,a0,1150 # ffffffffc0206d18 <default_pmm_manager+0x1068>
ffffffffc02048a2:	8edfb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02048a6:	601c                	ld	a5,0(s0)
ffffffffc02048a8:	b725                	j	ffffffffc02047d0 <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc02048aa:	00002617          	auipc	a2,0x2
ffffffffc02048ae:	45660613          	addi	a2,a2,1110 # ffffffffc0206d00 <default_pmm_manager+0x1050>
ffffffffc02048b2:	19100593          	li	a1,401
ffffffffc02048b6:	00002517          	auipc	a0,0x2
ffffffffc02048ba:	3da50513          	addi	a0,a0,986 # ffffffffc0206c90 <default_pmm_manager+0xfe0>
ffffffffc02048be:	b93fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02048c2:	00002697          	auipc	a3,0x2
ffffffffc02048c6:	4d668693          	addi	a3,a3,1238 # ffffffffc0206d98 <default_pmm_manager+0x10e8>
ffffffffc02048ca:	00001617          	auipc	a2,0x1
ffffffffc02048ce:	04e60613          	addi	a2,a2,78 # ffffffffc0205918 <commands+0x870>
ffffffffc02048d2:	1b800593          	li	a1,440
ffffffffc02048d6:	00002517          	auipc	a0,0x2
ffffffffc02048da:	3ba50513          	addi	a0,a0,954 # ffffffffc0206c90 <default_pmm_manager+0xfe0>
ffffffffc02048de:	b73fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048e2:	00002697          	auipc	a3,0x2
ffffffffc02048e6:	48e68693          	addi	a3,a3,1166 # ffffffffc0206d70 <default_pmm_manager+0x10c0>
ffffffffc02048ea:	00001617          	auipc	a2,0x1
ffffffffc02048ee:	02e60613          	addi	a2,a2,46 # ffffffffc0205918 <commands+0x870>
ffffffffc02048f2:	1b700593          	li	a1,439
ffffffffc02048f6:	00002517          	auipc	a0,0x2
ffffffffc02048fa:	39a50513          	addi	a0,a0,922 # ffffffffc0206c90 <default_pmm_manager+0xfe0>
ffffffffc02048fe:	b53fb0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204902:	00002617          	auipc	a2,0x2
ffffffffc0204906:	44660613          	addi	a2,a2,1094 # ffffffffc0206d48 <default_pmm_manager+0x1098>
ffffffffc020490a:	1b100593          	li	a1,433
ffffffffc020490e:	00002517          	auipc	a0,0x2
ffffffffc0204912:	38250513          	addi	a0,a0,898 # ffffffffc0206c90 <default_pmm_manager+0xfe0>
ffffffffc0204916:	b3bfb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020491a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020491a:	1141                	addi	sp,sp,-16
ffffffffc020491c:	e022                	sd	s0,0(sp)
ffffffffc020491e:	e406                	sd	ra,8(sp)
ffffffffc0204920:	00012417          	auipc	s0,0x12
ffffffffc0204924:	b9040413          	addi	s0,s0,-1136 # ffffffffc02164b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204928:	6018                	ld	a4,0(s0)
ffffffffc020492a:	4f1c                	lw	a5,24(a4)
ffffffffc020492c:	2781                	sext.w	a5,a5
ffffffffc020492e:	dff5                	beqz	a5,ffffffffc020492a <cpu_idle+0x10>
            schedule();
ffffffffc0204930:	0a2000ef          	jal	ra,ffffffffc02049d2 <schedule>
ffffffffc0204934:	bfd5                	j	ffffffffc0204928 <cpu_idle+0xe>

ffffffffc0204936 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204936:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020493a:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020493e:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204940:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204942:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204946:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020494a:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020494e:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204952:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204956:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020495a:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020495e:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204962:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204966:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020496a:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020496e:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204972:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204974:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204976:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc020497a:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020497e:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204982:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204986:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc020498a:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020498e:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204992:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204996:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc020499a:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020499e:	8082                	ret

ffffffffc02049a0 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02049a0:	411c                	lw	a5,0(a0)
ffffffffc02049a2:	4705                	li	a4,1
ffffffffc02049a4:	37f9                	addiw	a5,a5,-2
ffffffffc02049a6:	00f77563          	bleu	a5,a4,ffffffffc02049b0 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc02049aa:	4789                	li	a5,2
ffffffffc02049ac:	c11c                	sw	a5,0(a0)
ffffffffc02049ae:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc02049b0:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02049b2:	00002697          	auipc	a3,0x2
ffffffffc02049b6:	40e68693          	addi	a3,a3,1038 # ffffffffc0206dc0 <default_pmm_manager+0x1110>
ffffffffc02049ba:	00001617          	auipc	a2,0x1
ffffffffc02049be:	f5e60613          	addi	a2,a2,-162 # ffffffffc0205918 <commands+0x870>
ffffffffc02049c2:	45a5                	li	a1,9
ffffffffc02049c4:	00002517          	auipc	a0,0x2
ffffffffc02049c8:	43c50513          	addi	a0,a0,1084 # ffffffffc0206e00 <default_pmm_manager+0x1150>
wakeup_proc(struct proc_struct *proc) {
ffffffffc02049cc:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02049ce:	a83fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02049d2 <schedule>:
}

void
schedule(void) {
ffffffffc02049d2:	1141                	addi	sp,sp,-16
ffffffffc02049d4:	e406                	sd	ra,8(sp)
ffffffffc02049d6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02049d8:	100027f3          	csrr	a5,sstatus
ffffffffc02049dc:	8b89                	andi	a5,a5,2
ffffffffc02049de:	4401                	li	s0,0
ffffffffc02049e0:	e3d1                	bnez	a5,ffffffffc0204a64 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02049e2:	00012797          	auipc	a5,0x12
ffffffffc02049e6:	ace78793          	addi	a5,a5,-1330 # ffffffffc02164b0 <current>
ffffffffc02049ea:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049ee:	00012797          	auipc	a5,0x12
ffffffffc02049f2:	aca78793          	addi	a5,a5,-1334 # ffffffffc02164b8 <idleproc>
ffffffffc02049f6:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02049f8:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049fc:	04a88e63          	beq	a7,a0,ffffffffc0204a58 <schedule+0x86>
ffffffffc0204a00:	0c888693          	addi	a3,a7,200
ffffffffc0204a04:	00012617          	auipc	a2,0x12
ffffffffc0204a08:	bec60613          	addi	a2,a2,-1044 # ffffffffc02165f0 <proc_list>
        le = last;
ffffffffc0204a0c:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204a0e:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a10:	4809                	li	a6,2
    return listelm->next;
ffffffffc0204a12:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204a14:	00c78863          	beq	a5,a2,ffffffffc0204a24 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a18:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204a1c:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204a20:	01070463          	beq	a4,a6,ffffffffc0204a28 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204a24:	fef697e3          	bne	a3,a5,ffffffffc0204a12 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204a28:	c589                	beqz	a1,ffffffffc0204a32 <schedule+0x60>
ffffffffc0204a2a:	4198                	lw	a4,0(a1)
ffffffffc0204a2c:	4789                	li	a5,2
ffffffffc0204a2e:	00f70e63          	beq	a4,a5,ffffffffc0204a4a <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204a32:	451c                	lw	a5,8(a0)
ffffffffc0204a34:	2785                	addiw	a5,a5,1
ffffffffc0204a36:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204a38:	00a88463          	beq	a7,a0,ffffffffc0204a40 <schedule+0x6e>
            proc_run(next);
ffffffffc0204a3c:	8b3ff0ef          	jal	ra,ffffffffc02042ee <proc_run>
    if (flag) {
ffffffffc0204a40:	e419                	bnez	s0,ffffffffc0204a4e <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204a42:	60a2                	ld	ra,8(sp)
ffffffffc0204a44:	6402                	ld	s0,0(sp)
ffffffffc0204a46:	0141                	addi	sp,sp,16
ffffffffc0204a48:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204a4a:	852e                	mv	a0,a1
ffffffffc0204a4c:	b7dd                	j	ffffffffc0204a32 <schedule+0x60>
}
ffffffffc0204a4e:	6402                	ld	s0,0(sp)
ffffffffc0204a50:	60a2                	ld	ra,8(sp)
ffffffffc0204a52:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204a54:	b7ffb06f          	j	ffffffffc02005d2 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204a58:	00012617          	auipc	a2,0x12
ffffffffc0204a5c:	b9860613          	addi	a2,a2,-1128 # ffffffffc02165f0 <proc_list>
ffffffffc0204a60:	86b2                	mv	a3,a2
ffffffffc0204a62:	b76d                	j	ffffffffc0204a0c <schedule+0x3a>
        intr_disable();
ffffffffc0204a64:	b75fb0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc0204a68:	4405                	li	s0,1
ffffffffc0204a6a:	bfa5                	j	ffffffffc02049e2 <schedule+0x10>

ffffffffc0204a6c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204a6c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204a70:	2785                	addiw	a5,a5,1
ffffffffc0204a72:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204a76:	02000793          	li	a5,32
ffffffffc0204a7a:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204a7e:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204a82:	8082                	ret

ffffffffc0204a84 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204a84:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a88:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204a8a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a8e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204a90:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a94:	f022                	sd	s0,32(sp)
ffffffffc0204a96:	ec26                	sd	s1,24(sp)
ffffffffc0204a98:	e84a                	sd	s2,16(sp)
ffffffffc0204a9a:	f406                	sd	ra,40(sp)
ffffffffc0204a9c:	e44e                	sd	s3,8(sp)
ffffffffc0204a9e:	84aa                	mv	s1,a0
ffffffffc0204aa0:	892e                	mv	s2,a1
ffffffffc0204aa2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204aa6:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204aa8:	03067e63          	bleu	a6,a2,ffffffffc0204ae4 <printnum+0x60>
ffffffffc0204aac:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204aae:	00805763          	blez	s0,ffffffffc0204abc <printnum+0x38>
ffffffffc0204ab2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204ab4:	85ca                	mv	a1,s2
ffffffffc0204ab6:	854e                	mv	a0,s3
ffffffffc0204ab8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204aba:	fc65                	bnez	s0,ffffffffc0204ab2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204abc:	1a02                	slli	s4,s4,0x20
ffffffffc0204abe:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204ac2:	00002797          	auipc	a5,0x2
ffffffffc0204ac6:	4e678793          	addi	a5,a5,1254 # ffffffffc0206fa8 <error_string+0x38>
ffffffffc0204aca:	9a3e                	add	s4,s4,a5
}
ffffffffc0204acc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ace:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204ad2:	70a2                	ld	ra,40(sp)
ffffffffc0204ad4:	69a2                	ld	s3,8(sp)
ffffffffc0204ad6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ad8:	85ca                	mv	a1,s2
ffffffffc0204ada:	8326                	mv	t1,s1
}
ffffffffc0204adc:	6942                	ld	s2,16(sp)
ffffffffc0204ade:	64e2                	ld	s1,24(sp)
ffffffffc0204ae0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ae2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204ae4:	03065633          	divu	a2,a2,a6
ffffffffc0204ae8:	8722                	mv	a4,s0
ffffffffc0204aea:	f9bff0ef          	jal	ra,ffffffffc0204a84 <printnum>
ffffffffc0204aee:	b7f9                	j	ffffffffc0204abc <printnum+0x38>

ffffffffc0204af0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204af0:	7119                	addi	sp,sp,-128
ffffffffc0204af2:	f4a6                	sd	s1,104(sp)
ffffffffc0204af4:	f0ca                	sd	s2,96(sp)
ffffffffc0204af6:	e8d2                	sd	s4,80(sp)
ffffffffc0204af8:	e4d6                	sd	s5,72(sp)
ffffffffc0204afa:	e0da                	sd	s6,64(sp)
ffffffffc0204afc:	fc5e                	sd	s7,56(sp)
ffffffffc0204afe:	f862                	sd	s8,48(sp)
ffffffffc0204b00:	f06a                	sd	s10,32(sp)
ffffffffc0204b02:	fc86                	sd	ra,120(sp)
ffffffffc0204b04:	f8a2                	sd	s0,112(sp)
ffffffffc0204b06:	ecce                	sd	s3,88(sp)
ffffffffc0204b08:	f466                	sd	s9,40(sp)
ffffffffc0204b0a:	ec6e                	sd	s11,24(sp)
ffffffffc0204b0c:	892a                	mv	s2,a0
ffffffffc0204b0e:	84ae                	mv	s1,a1
ffffffffc0204b10:	8d32                	mv	s10,a2
ffffffffc0204b12:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b14:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b16:	00002a17          	auipc	s4,0x2
ffffffffc0204b1a:	302a0a13          	addi	s4,s4,770 # ffffffffc0206e18 <default_pmm_manager+0x1168>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b1e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b22:	00002c17          	auipc	s8,0x2
ffffffffc0204b26:	44ec0c13          	addi	s8,s8,1102 # ffffffffc0206f70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b2a:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204b2e:	02500793          	li	a5,37
ffffffffc0204b32:	001d0413          	addi	s0,s10,1
ffffffffc0204b36:	00f50e63          	beq	a0,a5,ffffffffc0204b52 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204b3a:	c521                	beqz	a0,ffffffffc0204b82 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b3c:	02500993          	li	s3,37
ffffffffc0204b40:	a011                	j	ffffffffc0204b44 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204b42:	c121                	beqz	a0,ffffffffc0204b82 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204b44:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b46:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b48:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b4a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b4e:	ff351ae3          	bne	a0,s3,ffffffffc0204b42 <vprintfmt+0x52>
ffffffffc0204b52:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b56:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b5a:	4981                	li	s3,0
ffffffffc0204b5c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204b5e:	5cfd                	li	s9,-1
ffffffffc0204b60:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b62:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b66:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b68:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204b6c:	0ff6f693          	andi	a3,a3,255
ffffffffc0204b70:	00140d13          	addi	s10,s0,1
ffffffffc0204b74:	20d5e563          	bltu	a1,a3,ffffffffc0204d7e <vprintfmt+0x28e>
ffffffffc0204b78:	068a                	slli	a3,a3,0x2
ffffffffc0204b7a:	96d2                	add	a3,a3,s4
ffffffffc0204b7c:	4294                	lw	a3,0(a3)
ffffffffc0204b7e:	96d2                	add	a3,a3,s4
ffffffffc0204b80:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204b82:	70e6                	ld	ra,120(sp)
ffffffffc0204b84:	7446                	ld	s0,112(sp)
ffffffffc0204b86:	74a6                	ld	s1,104(sp)
ffffffffc0204b88:	7906                	ld	s2,96(sp)
ffffffffc0204b8a:	69e6                	ld	s3,88(sp)
ffffffffc0204b8c:	6a46                	ld	s4,80(sp)
ffffffffc0204b8e:	6aa6                	ld	s5,72(sp)
ffffffffc0204b90:	6b06                	ld	s6,64(sp)
ffffffffc0204b92:	7be2                	ld	s7,56(sp)
ffffffffc0204b94:	7c42                	ld	s8,48(sp)
ffffffffc0204b96:	7ca2                	ld	s9,40(sp)
ffffffffc0204b98:	7d02                	ld	s10,32(sp)
ffffffffc0204b9a:	6de2                	ld	s11,24(sp)
ffffffffc0204b9c:	6109                	addi	sp,sp,128
ffffffffc0204b9e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204ba0:	4705                	li	a4,1
ffffffffc0204ba2:	008a8593          	addi	a1,s5,8
ffffffffc0204ba6:	01074463          	blt	a4,a6,ffffffffc0204bae <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204baa:	26080363          	beqz	a6,ffffffffc0204e10 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204bae:	000ab603          	ld	a2,0(s5)
ffffffffc0204bb2:	46c1                	li	a3,16
ffffffffc0204bb4:	8aae                	mv	s5,a1
ffffffffc0204bb6:	a06d                	j	ffffffffc0204c60 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204bb8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204bbc:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bbe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bc0:	b765                	j	ffffffffc0204b68 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204bc2:	000aa503          	lw	a0,0(s5)
ffffffffc0204bc6:	85a6                	mv	a1,s1
ffffffffc0204bc8:	0aa1                	addi	s5,s5,8
ffffffffc0204bca:	9902                	jalr	s2
            break;
ffffffffc0204bcc:	bfb9                	j	ffffffffc0204b2a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204bce:	4705                	li	a4,1
ffffffffc0204bd0:	008a8993          	addi	s3,s5,8
ffffffffc0204bd4:	01074463          	blt	a4,a6,ffffffffc0204bdc <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204bd8:	22080463          	beqz	a6,ffffffffc0204e00 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204bdc:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204be0:	24044463          	bltz	s0,ffffffffc0204e28 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204be4:	8622                	mv	a2,s0
ffffffffc0204be6:	8ace                	mv	s5,s3
ffffffffc0204be8:	46a9                	li	a3,10
ffffffffc0204bea:	a89d                	j	ffffffffc0204c60 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204bec:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bf0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204bf2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204bf4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204bf8:	8fb5                	xor	a5,a5,a3
ffffffffc0204bfa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bfe:	1ad74363          	blt	a4,a3,ffffffffc0204da4 <vprintfmt+0x2b4>
ffffffffc0204c02:	00369793          	slli	a5,a3,0x3
ffffffffc0204c06:	97e2                	add	a5,a5,s8
ffffffffc0204c08:	639c                	ld	a5,0(a5)
ffffffffc0204c0a:	18078d63          	beqz	a5,ffffffffc0204da4 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204c0e:	86be                	mv	a3,a5
ffffffffc0204c10:	00000617          	auipc	a2,0x0
ffffffffc0204c14:	39060613          	addi	a2,a2,912 # ffffffffc0204fa0 <etext+0x2c>
ffffffffc0204c18:	85a6                	mv	a1,s1
ffffffffc0204c1a:	854a                	mv	a0,s2
ffffffffc0204c1c:	240000ef          	jal	ra,ffffffffc0204e5c <printfmt>
ffffffffc0204c20:	b729                	j	ffffffffc0204b2a <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204c22:	00144603          	lbu	a2,1(s0)
ffffffffc0204c26:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c28:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c2a:	bf3d                	j	ffffffffc0204b68 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204c2c:	4705                	li	a4,1
ffffffffc0204c2e:	008a8593          	addi	a1,s5,8
ffffffffc0204c32:	01074463          	blt	a4,a6,ffffffffc0204c3a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204c36:	1e080263          	beqz	a6,ffffffffc0204e1a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204c3a:	000ab603          	ld	a2,0(s5)
ffffffffc0204c3e:	46a1                	li	a3,8
ffffffffc0204c40:	8aae                	mv	s5,a1
ffffffffc0204c42:	a839                	j	ffffffffc0204c60 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204c44:	03000513          	li	a0,48
ffffffffc0204c48:	85a6                	mv	a1,s1
ffffffffc0204c4a:	e03e                	sd	a5,0(sp)
ffffffffc0204c4c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204c4e:	85a6                	mv	a1,s1
ffffffffc0204c50:	07800513          	li	a0,120
ffffffffc0204c54:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204c56:	0aa1                	addi	s5,s5,8
ffffffffc0204c58:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204c5c:	6782                	ld	a5,0(sp)
ffffffffc0204c5e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c60:	876e                	mv	a4,s11
ffffffffc0204c62:	85a6                	mv	a1,s1
ffffffffc0204c64:	854a                	mv	a0,s2
ffffffffc0204c66:	e1fff0ef          	jal	ra,ffffffffc0204a84 <printnum>
            break;
ffffffffc0204c6a:	b5c1                	j	ffffffffc0204b2a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204c6c:	000ab603          	ld	a2,0(s5)
ffffffffc0204c70:	0aa1                	addi	s5,s5,8
ffffffffc0204c72:	1c060663          	beqz	a2,ffffffffc0204e3e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204c76:	00160413          	addi	s0,a2,1
ffffffffc0204c7a:	17b05c63          	blez	s11,ffffffffc0204df2 <vprintfmt+0x302>
ffffffffc0204c7e:	02d00593          	li	a1,45
ffffffffc0204c82:	14b79263          	bne	a5,a1,ffffffffc0204dc6 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c86:	00064783          	lbu	a5,0(a2)
ffffffffc0204c8a:	0007851b          	sext.w	a0,a5
ffffffffc0204c8e:	c905                	beqz	a0,ffffffffc0204cbe <vprintfmt+0x1ce>
ffffffffc0204c90:	000cc563          	bltz	s9,ffffffffc0204c9a <vprintfmt+0x1aa>
ffffffffc0204c94:	3cfd                	addiw	s9,s9,-1
ffffffffc0204c96:	036c8263          	beq	s9,s6,ffffffffc0204cba <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204c9a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204c9c:	18098463          	beqz	s3,ffffffffc0204e24 <vprintfmt+0x334>
ffffffffc0204ca0:	3781                	addiw	a5,a5,-32
ffffffffc0204ca2:	18fbf163          	bleu	a5,s7,ffffffffc0204e24 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204ca6:	03f00513          	li	a0,63
ffffffffc0204caa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cac:	0405                	addi	s0,s0,1
ffffffffc0204cae:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204cb2:	3dfd                	addiw	s11,s11,-1
ffffffffc0204cb4:	0007851b          	sext.w	a0,a5
ffffffffc0204cb8:	fd61                	bnez	a0,ffffffffc0204c90 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204cba:	e7b058e3          	blez	s11,ffffffffc0204b2a <vprintfmt+0x3a>
ffffffffc0204cbe:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204cc0:	85a6                	mv	a1,s1
ffffffffc0204cc2:	02000513          	li	a0,32
ffffffffc0204cc6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204cc8:	e60d81e3          	beqz	s11,ffffffffc0204b2a <vprintfmt+0x3a>
ffffffffc0204ccc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204cce:	85a6                	mv	a1,s1
ffffffffc0204cd0:	02000513          	li	a0,32
ffffffffc0204cd4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204cd6:	fe0d94e3          	bnez	s11,ffffffffc0204cbe <vprintfmt+0x1ce>
ffffffffc0204cda:	bd81                	j	ffffffffc0204b2a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204cdc:	4705                	li	a4,1
ffffffffc0204cde:	008a8593          	addi	a1,s5,8
ffffffffc0204ce2:	01074463          	blt	a4,a6,ffffffffc0204cea <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204ce6:	12080063          	beqz	a6,ffffffffc0204e06 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204cea:	000ab603          	ld	a2,0(s5)
ffffffffc0204cee:	46a9                	li	a3,10
ffffffffc0204cf0:	8aae                	mv	s5,a1
ffffffffc0204cf2:	b7bd                	j	ffffffffc0204c60 <vprintfmt+0x170>
ffffffffc0204cf4:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204cf8:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cfc:	846a                	mv	s0,s10
ffffffffc0204cfe:	b5ad                	j	ffffffffc0204b68 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204d00:	85a6                	mv	a1,s1
ffffffffc0204d02:	02500513          	li	a0,37
ffffffffc0204d06:	9902                	jalr	s2
            break;
ffffffffc0204d08:	b50d                	j	ffffffffc0204b2a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204d0a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204d0e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204d12:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d14:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204d16:	e40dd9e3          	bgez	s11,ffffffffc0204b68 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204d1a:	8de6                	mv	s11,s9
ffffffffc0204d1c:	5cfd                	li	s9,-1
ffffffffc0204d1e:	b5a9                	j	ffffffffc0204b68 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204d20:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204d24:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d28:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204d2a:	bd3d                	j	ffffffffc0204b68 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204d2c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204d30:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d34:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204d36:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204d3a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d3e:	fcd56ce3          	bltu	a0,a3,ffffffffc0204d16 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204d42:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204d44:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204d48:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204d4c:	0196873b          	addw	a4,a3,s9
ffffffffc0204d50:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204d54:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204d58:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204d5c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204d60:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d64:	fcd57fe3          	bleu	a3,a0,ffffffffc0204d42 <vprintfmt+0x252>
ffffffffc0204d68:	b77d                	j	ffffffffc0204d16 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204d6a:	fffdc693          	not	a3,s11
ffffffffc0204d6e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204d70:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204d74:	00144603          	lbu	a2,1(s0)
ffffffffc0204d78:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d7a:	846a                	mv	s0,s10
ffffffffc0204d7c:	b3f5                	j	ffffffffc0204b68 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204d7e:	85a6                	mv	a1,s1
ffffffffc0204d80:	02500513          	li	a0,37
ffffffffc0204d84:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204d86:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204d8a:	02500793          	li	a5,37
ffffffffc0204d8e:	8d22                	mv	s10,s0
ffffffffc0204d90:	d8f70de3          	beq	a4,a5,ffffffffc0204b2a <vprintfmt+0x3a>
ffffffffc0204d94:	02500713          	li	a4,37
ffffffffc0204d98:	1d7d                	addi	s10,s10,-1
ffffffffc0204d9a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204d9e:	fee79de3          	bne	a5,a4,ffffffffc0204d98 <vprintfmt+0x2a8>
ffffffffc0204da2:	b361                	j	ffffffffc0204b2a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204da4:	00002617          	auipc	a2,0x2
ffffffffc0204da8:	2a460613          	addi	a2,a2,676 # ffffffffc0207048 <error_string+0xd8>
ffffffffc0204dac:	85a6                	mv	a1,s1
ffffffffc0204dae:	854a                	mv	a0,s2
ffffffffc0204db0:	0ac000ef          	jal	ra,ffffffffc0204e5c <printfmt>
ffffffffc0204db4:	bb9d                	j	ffffffffc0204b2a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204db6:	00002617          	auipc	a2,0x2
ffffffffc0204dba:	28a60613          	addi	a2,a2,650 # ffffffffc0207040 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204dbe:	00002417          	auipc	s0,0x2
ffffffffc0204dc2:	28340413          	addi	s0,s0,643 # ffffffffc0207041 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dc6:	8532                	mv	a0,a2
ffffffffc0204dc8:	85e6                	mv	a1,s9
ffffffffc0204dca:	e032                	sd	a2,0(sp)
ffffffffc0204dcc:	e43e                	sd	a5,8(sp)
ffffffffc0204dce:	0cc000ef          	jal	ra,ffffffffc0204e9a <strnlen>
ffffffffc0204dd2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204dd6:	6602                	ld	a2,0(sp)
ffffffffc0204dd8:	01b05d63          	blez	s11,ffffffffc0204df2 <vprintfmt+0x302>
ffffffffc0204ddc:	67a2                	ld	a5,8(sp)
ffffffffc0204dde:	2781                	sext.w	a5,a5
ffffffffc0204de0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204de2:	6522                	ld	a0,8(sp)
ffffffffc0204de4:	85a6                	mv	a1,s1
ffffffffc0204de6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204de8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204dea:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dec:	6602                	ld	a2,0(sp)
ffffffffc0204dee:	fe0d9ae3          	bnez	s11,ffffffffc0204de2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204df2:	00064783          	lbu	a5,0(a2)
ffffffffc0204df6:	0007851b          	sext.w	a0,a5
ffffffffc0204dfa:	e8051be3          	bnez	a0,ffffffffc0204c90 <vprintfmt+0x1a0>
ffffffffc0204dfe:	b335                	j	ffffffffc0204b2a <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204e00:	000aa403          	lw	s0,0(s5)
ffffffffc0204e04:	bbf1                	j	ffffffffc0204be0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204e06:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e0a:	46a9                	li	a3,10
ffffffffc0204e0c:	8aae                	mv	s5,a1
ffffffffc0204e0e:	bd89                	j	ffffffffc0204c60 <vprintfmt+0x170>
ffffffffc0204e10:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e14:	46c1                	li	a3,16
ffffffffc0204e16:	8aae                	mv	s5,a1
ffffffffc0204e18:	b5a1                	j	ffffffffc0204c60 <vprintfmt+0x170>
ffffffffc0204e1a:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e1e:	46a1                	li	a3,8
ffffffffc0204e20:	8aae                	mv	s5,a1
ffffffffc0204e22:	bd3d                	j	ffffffffc0204c60 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204e24:	9902                	jalr	s2
ffffffffc0204e26:	b559                	j	ffffffffc0204cac <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204e28:	85a6                	mv	a1,s1
ffffffffc0204e2a:	02d00513          	li	a0,45
ffffffffc0204e2e:	e03e                	sd	a5,0(sp)
ffffffffc0204e30:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204e32:	8ace                	mv	s5,s3
ffffffffc0204e34:	40800633          	neg	a2,s0
ffffffffc0204e38:	46a9                	li	a3,10
ffffffffc0204e3a:	6782                	ld	a5,0(sp)
ffffffffc0204e3c:	b515                	j	ffffffffc0204c60 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204e3e:	01b05663          	blez	s11,ffffffffc0204e4a <vprintfmt+0x35a>
ffffffffc0204e42:	02d00693          	li	a3,45
ffffffffc0204e46:	f6d798e3          	bne	a5,a3,ffffffffc0204db6 <vprintfmt+0x2c6>
ffffffffc0204e4a:	00002417          	auipc	s0,0x2
ffffffffc0204e4e:	1f740413          	addi	s0,s0,503 # ffffffffc0207041 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e52:	02800513          	li	a0,40
ffffffffc0204e56:	02800793          	li	a5,40
ffffffffc0204e5a:	bd1d                	j	ffffffffc0204c90 <vprintfmt+0x1a0>

ffffffffc0204e5c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e5c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e5e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e62:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e64:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e66:	ec06                	sd	ra,24(sp)
ffffffffc0204e68:	f83a                	sd	a4,48(sp)
ffffffffc0204e6a:	fc3e                	sd	a5,56(sp)
ffffffffc0204e6c:	e0c2                	sd	a6,64(sp)
ffffffffc0204e6e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204e70:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e72:	c7fff0ef          	jal	ra,ffffffffc0204af0 <vprintfmt>
}
ffffffffc0204e76:	60e2                	ld	ra,24(sp)
ffffffffc0204e78:	6161                	addi	sp,sp,80
ffffffffc0204e7a:	8082                	ret

ffffffffc0204e7c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204e7c:	00054783          	lbu	a5,0(a0)
ffffffffc0204e80:	cb91                	beqz	a5,ffffffffc0204e94 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204e82:	4781                	li	a5,0
        cnt ++;
ffffffffc0204e84:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204e86:	00f50733          	add	a4,a0,a5
ffffffffc0204e8a:	00074703          	lbu	a4,0(a4)
ffffffffc0204e8e:	fb7d                	bnez	a4,ffffffffc0204e84 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204e90:	853e                	mv	a0,a5
ffffffffc0204e92:	8082                	ret
    size_t cnt = 0;
ffffffffc0204e94:	4781                	li	a5,0
}
ffffffffc0204e96:	853e                	mv	a0,a5
ffffffffc0204e98:	8082                	ret

ffffffffc0204e9a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e9a:	c185                	beqz	a1,ffffffffc0204eba <strnlen+0x20>
ffffffffc0204e9c:	00054783          	lbu	a5,0(a0)
ffffffffc0204ea0:	cf89                	beqz	a5,ffffffffc0204eba <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204ea2:	4781                	li	a5,0
ffffffffc0204ea4:	a021                	j	ffffffffc0204eac <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204ea6:	00074703          	lbu	a4,0(a4)
ffffffffc0204eaa:	c711                	beqz	a4,ffffffffc0204eb6 <strnlen+0x1c>
        cnt ++;
ffffffffc0204eac:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204eae:	00f50733          	add	a4,a0,a5
ffffffffc0204eb2:	fef59ae3          	bne	a1,a5,ffffffffc0204ea6 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204eb6:	853e                	mv	a0,a5
ffffffffc0204eb8:	8082                	ret
    size_t cnt = 0;
ffffffffc0204eba:	4781                	li	a5,0
}
ffffffffc0204ebc:	853e                	mv	a0,a5
ffffffffc0204ebe:	8082                	ret

ffffffffc0204ec0 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204ec0:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204ec2:	0585                	addi	a1,a1,1
ffffffffc0204ec4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204ec8:	0785                	addi	a5,a5,1
ffffffffc0204eca:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204ece:	fb75                	bnez	a4,ffffffffc0204ec2 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204ed0:	8082                	ret

ffffffffc0204ed2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204ed2:	00054783          	lbu	a5,0(a0)
ffffffffc0204ed6:	0005c703          	lbu	a4,0(a1)
ffffffffc0204eda:	cb91                	beqz	a5,ffffffffc0204eee <strcmp+0x1c>
ffffffffc0204edc:	00e79c63          	bne	a5,a4,ffffffffc0204ef4 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204ee0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204ee2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204ee6:	0585                	addi	a1,a1,1
ffffffffc0204ee8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204eec:	fbe5                	bnez	a5,ffffffffc0204edc <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204eee:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204ef0:	9d19                	subw	a0,a0,a4
ffffffffc0204ef2:	8082                	ret
ffffffffc0204ef4:	0007851b          	sext.w	a0,a5
ffffffffc0204ef8:	9d19                	subw	a0,a0,a4
ffffffffc0204efa:	8082                	ret

ffffffffc0204efc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204efc:	00054783          	lbu	a5,0(a0)
ffffffffc0204f00:	cb91                	beqz	a5,ffffffffc0204f14 <strchr+0x18>
        if (*s == c) {
ffffffffc0204f02:	00b79563          	bne	a5,a1,ffffffffc0204f0c <strchr+0x10>
ffffffffc0204f06:	a809                	j	ffffffffc0204f18 <strchr+0x1c>
ffffffffc0204f08:	00b78763          	beq	a5,a1,ffffffffc0204f16 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204f0c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204f0e:	00054783          	lbu	a5,0(a0)
ffffffffc0204f12:	fbfd                	bnez	a5,ffffffffc0204f08 <strchr+0xc>
    }
    return NULL;
ffffffffc0204f14:	4501                	li	a0,0
}
ffffffffc0204f16:	8082                	ret
ffffffffc0204f18:	8082                	ret

ffffffffc0204f1a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204f1a:	ca01                	beqz	a2,ffffffffc0204f2a <memset+0x10>
ffffffffc0204f1c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204f1e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204f20:	0785                	addi	a5,a5,1
ffffffffc0204f22:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204f26:	fec79de3          	bne	a5,a2,ffffffffc0204f20 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204f2a:	8082                	ret

ffffffffc0204f2c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204f2c:	ca19                	beqz	a2,ffffffffc0204f42 <memcpy+0x16>
ffffffffc0204f2e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204f30:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204f32:	0585                	addi	a1,a1,1
ffffffffc0204f34:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204f38:	0785                	addi	a5,a5,1
ffffffffc0204f3a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204f3e:	fec59ae3          	bne	a1,a2,ffffffffc0204f32 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204f42:	8082                	ret

ffffffffc0204f44 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204f44:	c21d                	beqz	a2,ffffffffc0204f6a <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204f46:	00054783          	lbu	a5,0(a0)
ffffffffc0204f4a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f4e:	962a                	add	a2,a2,a0
ffffffffc0204f50:	00f70963          	beq	a4,a5,ffffffffc0204f62 <memcmp+0x1e>
ffffffffc0204f54:	a829                	j	ffffffffc0204f6e <memcmp+0x2a>
ffffffffc0204f56:	00054783          	lbu	a5,0(a0)
ffffffffc0204f5a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204f5e:	00e79863          	bne	a5,a4,ffffffffc0204f6e <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204f62:	0505                	addi	a0,a0,1
ffffffffc0204f64:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204f66:	fea618e3          	bne	a2,a0,ffffffffc0204f56 <memcmp+0x12>
    }
    return 0;
ffffffffc0204f6a:	4501                	li	a0,0
}
ffffffffc0204f6c:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204f6e:	40e7853b          	subw	a0,a5,a4
ffffffffc0204f72:	8082                	ret
