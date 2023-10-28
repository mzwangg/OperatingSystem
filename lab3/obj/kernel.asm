
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2be040ef          	jal	ra,ffffffffc020430c <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2e658593          	addi	a1,a1,742 # ffffffffc0204338 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2fe50513          	addi	a0,a0,766 # ffffffffc0204358 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2cd010ef          	jal	ra,ffffffffc0201b36 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	5b0030ef          	jal	ra,ffffffffc0203622 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7b2020ef          	jal	ra,ffffffffc020282c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39e000ef          	jal	ra,ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	573030ef          	jal	ra,ffffffffc0203e24 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	53f030ef          	jal	ra,ffffffffc0203e24 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3380006f          	j	ffffffffc020042a <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	366000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	28850513          	addi	a0,a0,648 # ffffffffc0204390 <etext+0x5a>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	29250513          	addi	a0,a0,658 # ffffffffc02043b0 <etext+0x7a>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	20c58593          	addi	a1,a1,524 # ffffffffc0204336 <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	29e50513          	addi	a0,a0,670 # ffffffffc02043d0 <etext+0x9a>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	2aa50513          	addi	a0,a0,682 # ffffffffc02043f0 <etext+0xba>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	44e58593          	addi	a1,a1,1102 # ffffffffc02115a0 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	2b650513          	addi	a0,a0,694 # ffffffffc0204410 <etext+0xda>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	83958593          	addi	a1,a1,-1991 # ffffffffc021199f <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec878793          	addi	a5,a5,-312 # ffffffffc0200036 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	2a850513          	addi	a0,a0,680 # ffffffffc0204430 <etext+0xfa>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	f2dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200196 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200198:	00004617          	auipc	a2,0x4
ffffffffc020019c:	1c860613          	addi	a2,a2,456 # ffffffffc0204360 <etext+0x2a>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	1d450513          	addi	a0,a0,468 # ffffffffc0204378 <etext+0x42>
void print_stackframe(void) {
ffffffffc02001ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ae:	1c6000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b4:	00004617          	auipc	a2,0x4
ffffffffc02001b8:	38460613          	addi	a2,a2,900 # ffffffffc0204538 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	39c58593          	addi	a1,a1,924 # ffffffffc0204558 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	39c50513          	addi	a0,a0,924 # ffffffffc0204560 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	39e60613          	addi	a2,a2,926 # ffffffffc0204570 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	3be58593          	addi	a1,a1,958 # ffffffffc0204598 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	37e50513          	addi	a0,a0,894 # ffffffffc0204560 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	3ba60613          	addi	a2,a2,954 # ffffffffc02045a8 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	3d258593          	addi	a1,a1,978 # ffffffffc02045c8 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	36250513          	addi	a0,a0,866 # ffffffffc0204560 <commands+0x100>
ffffffffc0200206:	eb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
ffffffffc020020c:	4501                	li	a0,0
ffffffffc020020e:	0141                	addi	sp,sp,16
ffffffffc0200210:	8082                	ret

ffffffffc0200212 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
ffffffffc0200214:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200216:	ef1ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	0141                	addi	sp,sp,16
ffffffffc0200220:	8082                	ret

ffffffffc0200222 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	1141                	addi	sp,sp,-16
ffffffffc0200224:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200226:	f71ff0ef          	jal	ra,ffffffffc0200196 <print_stackframe>
    return 0;
}
ffffffffc020022a:	60a2                	ld	ra,8(sp)
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	0141                	addi	sp,sp,16
ffffffffc0200230:	8082                	ret

ffffffffc0200232 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200232:	7115                	addi	sp,sp,-224
ffffffffc0200234:	e962                	sd	s8,144(sp)
ffffffffc0200236:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	27050513          	addi	a0,a0,624 # ffffffffc02044a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200240:	ed86                	sd	ra,216(sp)
ffffffffc0200242:	e9a2                	sd	s0,208(sp)
ffffffffc0200244:	e5a6                	sd	s1,200(sp)
ffffffffc0200246:	e1ca                	sd	s2,192(sp)
ffffffffc0200248:	fd4e                	sd	s3,184(sp)
ffffffffc020024a:	f952                	sd	s4,176(sp)
ffffffffc020024c:	f556                	sd	s5,168(sp)
ffffffffc020024e:	f15a                	sd	s6,160(sp)
ffffffffc0200250:	ed5e                	sd	s7,152(sp)
ffffffffc0200252:	e566                	sd	s9,136(sp)
ffffffffc0200254:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200256:	e69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	27650513          	addi	a0,a0,630 # ffffffffc02044d0 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4f2000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	1f0c8c93          	addi	s9,s9,496 # ffffffffc0204460 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	78098993          	addi	s3,s3,1920 # ffffffffc02059f8 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	27890913          	addi	s2,s2,632 # ffffffffc02044f8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	276b0b13          	addi	s6,s6,630 # ffffffffc0204500 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	2c6a8a93          	addi	s5,s5,710 # ffffffffc0204558 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	713030ef          	jal	ra,ffffffffc02041b0 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	03e040ef          	jal	ra,ffffffffc02042ee <strchr>
ffffffffc02002b4:	c925                	beqz	a0,ffffffffc0200324 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b6:	00144583          	lbu	a1,1(s0)
ffffffffc02002ba:	00040023          	sb	zero,0(s0)
ffffffffc02002be:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	f5fd                	bnez	a1,ffffffffc02002ae <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002c2:	dce9                	beqz	s1,ffffffffc020029c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c4:	6582                	ld	a1,0(sp)
ffffffffc02002c6:	00004d17          	auipc	s10,0x4
ffffffffc02002ca:	19ad0d13          	addi	s10,s10,410 # ffffffffc0204460 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	7f1030ef          	jal	ra,ffffffffc02042c4 <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	7dd030ef          	jal	ra,ffffffffc02042c4 <strcmp>
ffffffffc02002ec:	f57d                	bnez	a0,ffffffffc02002da <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ee:	00141793          	slli	a5,s0,0x1
ffffffffc02002f2:	97a2                	add	a5,a5,s0
ffffffffc02002f4:	078e                	slli	a5,a5,0x3
ffffffffc02002f6:	97e6                	add	a5,a5,s9
ffffffffc02002f8:	6b9c                	ld	a5,16(a5)
ffffffffc02002fa:	8662                	mv	a2,s8
ffffffffc02002fc:	002c                	addi	a1,sp,8
ffffffffc02002fe:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200302:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200304:	f8055ce3          	bgez	a0,ffffffffc020029c <kmonitor+0x6a>
}
ffffffffc0200308:	60ee                	ld	ra,216(sp)
ffffffffc020030a:	644e                	ld	s0,208(sp)
ffffffffc020030c:	64ae                	ld	s1,200(sp)
ffffffffc020030e:	690e                	ld	s2,192(sp)
ffffffffc0200310:	79ea                	ld	s3,184(sp)
ffffffffc0200312:	7a4a                	ld	s4,176(sp)
ffffffffc0200314:	7aaa                	ld	s5,168(sp)
ffffffffc0200316:	7b0a                	ld	s6,160(sp)
ffffffffc0200318:	6bea                	ld	s7,152(sp)
ffffffffc020031a:	6c4a                	ld	s8,144(sp)
ffffffffc020031c:	6caa                	ld	s9,136(sp)
ffffffffc020031e:	6d0a                	ld	s10,128(sp)
ffffffffc0200320:	612d                	addi	sp,sp,224
ffffffffc0200322:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200324:	00044783          	lbu	a5,0(s0)
ffffffffc0200328:	dfc9                	beqz	a5,ffffffffc02002c2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020032a:	03448863          	beq	s1,s4,ffffffffc020035a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032e:	00349793          	slli	a5,s1,0x3
ffffffffc0200332:	0118                	addi	a4,sp,128
ffffffffc0200334:	97ba                	add	a5,a5,a4
ffffffffc0200336:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200340:	e591                	bnez	a1,ffffffffc020034c <kmonitor+0x11a>
ffffffffc0200342:	b749                	j	ffffffffc02002c4 <kmonitor+0x92>
            buf ++;
ffffffffc0200344:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200346:	00044583          	lbu	a1,0(s0)
ffffffffc020034a:	ddad                	beqz	a1,ffffffffc02002c4 <kmonitor+0x92>
ffffffffc020034c:	854a                	mv	a0,s2
ffffffffc020034e:	7a1030ef          	jal	ra,ffffffffc02042ee <strchr>
ffffffffc0200352:	d96d                	beqz	a0,ffffffffc0200344 <kmonitor+0x112>
ffffffffc0200354:	00044583          	lbu	a1,0(s0)
ffffffffc0200358:	bf91                	j	ffffffffc02002ac <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200362:	b7f1                	j	ffffffffc020032e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	1ba50513          	addi	a0,a0,442 # ffffffffc0204520 <commands+0xc0>
ffffffffc020036e:	d51ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200372:	b72d                	j	ffffffffc020029c <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0211440 <is_panic>
ffffffffc020037c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	02031c63          	bnez	t1,ffffffffc02003c8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	8432                	mv	s0,a2
ffffffffc0200398:	00011717          	auipc	a4,0x11
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	23250513          	addi	a0,a0,562 # ffffffffc02045d8 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00005517          	auipc	a0,0x5
ffffffffc02003c0:	19450513          	addi	a0,a0,404 # ffffffffc0205550 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	132000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	1fe50513          	addi	a0,a0,510 # ffffffffc02045f8 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0607bb23          	sd	zero,118(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00011797          	auipc	a5,0x11
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0211448 <timebase>
ffffffffc020041a:	639c                	ld	a5,0(a5)
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	953e                	add	a0,a0,a5
ffffffffc0200422:	4881                	li	a7,0
ffffffffc0200424:	00000073          	ecall
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020042a:	100027f3          	csrr	a5,sstatus
ffffffffc020042e:	8b89                	andi	a5,a5,2
ffffffffc0200430:	0ff57513          	andi	a0,a0,255
ffffffffc0200434:	e799                	bnez	a5,ffffffffc0200442 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200436:	4581                	li	a1,0
ffffffffc0200438:	4601                	li	a2,0
ffffffffc020043a:	4885                	li	a7,1
ffffffffc020043c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200440:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200442:	1101                	addi	sp,sp,-32
ffffffffc0200444:	ec06                	sd	ra,24(sp)
ffffffffc0200446:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200448:	0b2000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020044c:	6522                	ld	a0,8(sp)
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4885                	li	a7,1
ffffffffc0200454:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200458:	60e2                	ld	ra,24(sp)
ffffffffc020045a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020045c:	0980006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200460 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200460:	100027f3          	csrr	a5,sstatus
ffffffffc0200464:	8b89                	andi	a5,a5,2
ffffffffc0200466:	eb89                	bnez	a5,ffffffffc0200478 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200468:	4501                	li	a0,0
ffffffffc020046a:	4581                	li	a1,0
ffffffffc020046c:	4601                	li	a2,0
ffffffffc020046e:	4889                	li	a7,2
ffffffffc0200470:	00000073          	ecall
ffffffffc0200474:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200476:	8082                	ret
int cons_getc(void) {
ffffffffc0200478:	1101                	addi	sp,sp,-32
ffffffffc020047a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020047c:	07e000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	064000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc0200494:	60e2                	ld	ra,24(sp)
ffffffffc0200496:	6522                	ld	a0,8(sp)
ffffffffc0200498:	6105                	addi	sp,sp,32
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	b9678793          	addi	a5,a5,-1130 # ffffffffc020a040 <edata>
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	65d030ef          	jal	ra,ffffffffc020431e <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ce:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004d4:	0000a517          	auipc	a0,0xa
ffffffffc02004d8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004dc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	00969613          	slli	a2,a3,0x9
ffffffffc02004e2:	85ba                	mv	a1,a4
ffffffffc02004e4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004e6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e8:	637030ef          	jal	ra,ffffffffc020431e <memcpy>
    return 0;
}
ffffffffc02004ec:	60a2                	ld	ra,8(sp)
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	0141                	addi	sp,sp,16
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	3c050513          	addi	a0,a0,960 # ffffffffc02048f0 <commands+0x490>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	05c78793          	addi	a5,a5,92 # ffffffffc0211598 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	60a0306f          	j	ffffffffc0203b60 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	3b660613          	addi	a2,a2,950 # ffffffffc0204910 <commands+0x4b0>
ffffffffc0200562:	07900593          	li	a1,121
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	3c250513          	addi	a0,a0,962 # ffffffffc0204928 <commands+0x4c8>
ffffffffc020056e:	e07ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	4ba78793          	addi	a5,a5,1210 # ffffffffc0200a30 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	3a850513          	addi	a0,a0,936 # ffffffffc0204940 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	3b050513          	addi	a0,a0,944 # ffffffffc0204958 <commands+0x4f8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	3ba50513          	addi	a0,a0,954 # ffffffffc0204970 <commands+0x510>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	3c450513          	addi	a0,a0,964 # ffffffffc0204988 <commands+0x528>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	3ce50513          	addi	a0,a0,974 # ffffffffc02049a0 <commands+0x540>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	3d850513          	addi	a0,a0,984 # ffffffffc02049b8 <commands+0x558>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	3e250513          	addi	a0,a0,994 # ffffffffc02049d0 <commands+0x570>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	3ec50513          	addi	a0,a0,1004 # ffffffffc02049e8 <commands+0x588>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	3f650513          	addi	a0,a0,1014 # ffffffffc0204a00 <commands+0x5a0>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	40050513          	addi	a0,a0,1024 # ffffffffc0204a18 <commands+0x5b8>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	40a50513          	addi	a0,a0,1034 # ffffffffc0204a30 <commands+0x5d0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	41450513          	addi	a0,a0,1044 # ffffffffc0204a48 <commands+0x5e8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	41e50513          	addi	a0,a0,1054 # ffffffffc0204a60 <commands+0x600>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	42850513          	addi	a0,a0,1064 # ffffffffc0204a78 <commands+0x618>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	43250513          	addi	a0,a0,1074 # ffffffffc0204a90 <commands+0x630>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	43c50513          	addi	a0,a0,1084 # ffffffffc0204aa8 <commands+0x648>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	44650513          	addi	a0,a0,1094 # ffffffffc0204ac0 <commands+0x660>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	45050513          	addi	a0,a0,1104 # ffffffffc0204ad8 <commands+0x678>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	45a50513          	addi	a0,a0,1114 # ffffffffc0204af0 <commands+0x690>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	46450513          	addi	a0,a0,1124 # ffffffffc0204b08 <commands+0x6a8>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	46e50513          	addi	a0,a0,1134 # ffffffffc0204b20 <commands+0x6c0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	47850513          	addi	a0,a0,1144 # ffffffffc0204b38 <commands+0x6d8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	48250513          	addi	a0,a0,1154 # ffffffffc0204b50 <commands+0x6f0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	48c50513          	addi	a0,a0,1164 # ffffffffc0204b68 <commands+0x708>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	49650513          	addi	a0,a0,1174 # ffffffffc0204b80 <commands+0x720>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	4a050513          	addi	a0,a0,1184 # ffffffffc0204b98 <commands+0x738>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204bb0 <commands+0x750>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	4b450513          	addi	a0,a0,1204 # ffffffffc0204bc8 <commands+0x768>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	4be50513          	addi	a0,a0,1214 # ffffffffc0204be0 <commands+0x780>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	4c850513          	addi	a0,a0,1224 # ffffffffc0204bf8 <commands+0x798>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	4d250513          	addi	a0,a0,1234 # ffffffffc0204c10 <commands+0x7b0>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	4d850513          	addi	a0,a0,1240 # ffffffffc0204c28 <commands+0x7c8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	4da50513          	addi	a0,a0,1242 # ffffffffc0204c40 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	4da50513          	addi	a0,a0,1242 # ffffffffc0204c58 <commands+0x7f8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	4e250513          	addi	a0,a0,1250 # ffffffffc0204c70 <commands+0x810>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0204c88 <commands+0x828>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	4ee50513          	addi	a0,a0,1262 # ffffffffc0204ca0 <commands+0x840>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e4470713          	addi	a4,a4,-444 # ffffffffc0204614 <commands+0x1b4>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	0be50513          	addi	a0,a0,190 # ffffffffc02048a0 <commands+0x440>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	09250513          	addi	a0,a0,146 # ffffffffc0204880 <commands+0x420>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	04650513          	addi	a0,a0,70 # ffffffffc0204840 <commands+0x3e0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	05a50513          	addi	a0,a0,90 # ffffffffc0204860 <commands+0x400>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	0be50513          	addi	a0,a0,190 # ffffffffc02048d0 <commands+0x470>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	bedff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
            if(++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211478 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020084e:	06400593          	li	a1,100
ffffffffc0200852:	00004517          	auipc	a0,0x4
ffffffffc0200856:	06e50513          	addi	a0,a0,110 # ffffffffc02048c0 <commands+0x460>
ffffffffc020085a:	865ff0ef          	jal	ra,ffffffffc02000be <cprintf>
                num ++;
ffffffffc020085e:	00011717          	auipc	a4,0x11
ffffffffc0200862:	bf270713          	addi	a4,a4,-1038 # ffffffffc0211450 <num>
ffffffffc0200866:	631c                	ld	a5,0(a4)
                if(num == 10){
ffffffffc0200868:	46a9                	li	a3,10
                num ++;
ffffffffc020086a:	0785                	addi	a5,a5,1
ffffffffc020086c:	00011617          	auipc	a2,0x11
ffffffffc0200870:	bef63223          	sd	a5,-1052(a2) # ffffffffc0211450 <num>
                if(num == 10){
ffffffffc0200874:	631c                	ld	a5,0(a4)
ffffffffc0200876:	fcd797e3          	bne	a5,a3,ffffffffc0200844 <interrupt_handler+0x84>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020087a:	4501                	li	a0,0
ffffffffc020087c:	4581                	li	a1,0
ffffffffc020087e:	4601                	li	a2,0
ffffffffc0200880:	48a1                	li	a7,8
ffffffffc0200882:	00000073          	ecall
ffffffffc0200886:	bf7d                	j	ffffffffc0200844 <interrupt_handler+0x84>

ffffffffc0200888 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200888:	11853783          	ld	a5,280(a0)
ffffffffc020088c:	473d                	li	a4,15
ffffffffc020088e:	16f76563          	bltu	a4,a5,ffffffffc02009f8 <exception_handler+0x170>
ffffffffc0200892:	00004717          	auipc	a4,0x4
ffffffffc0200896:	db270713          	addi	a4,a4,-590 # ffffffffc0204644 <commands+0x1e4>
ffffffffc020089a:	078a                	slli	a5,a5,0x2
ffffffffc020089c:	97ba                	add	a5,a5,a4
ffffffffc020089e:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc02008a0:	1101                	addi	sp,sp,-32
ffffffffc02008a2:	e822                	sd	s0,16(sp)
ffffffffc02008a4:	ec06                	sd	ra,24(sp)
ffffffffc02008a6:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc02008a8:	97ba                	add	a5,a5,a4
ffffffffc02008aa:	842a                	mv	s0,a0
ffffffffc02008ac:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	f7a50513          	addi	a0,a0,-134 # ffffffffc0204828 <commands+0x3c8>
ffffffffc02008b6:	809ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008ba:	8522                	mv	a0,s0
ffffffffc02008bc:	c45ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008c0:	84aa                	mv	s1,a0
ffffffffc02008c2:	12051d63          	bnez	a0,ffffffffc02009fc <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008c6:	60e2                	ld	ra,24(sp)
ffffffffc02008c8:	6442                	ld	s0,16(sp)
ffffffffc02008ca:	64a2                	ld	s1,8(sp)
ffffffffc02008cc:	6105                	addi	sp,sp,32
ffffffffc02008ce:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008d0:	00004517          	auipc	a0,0x4
ffffffffc02008d4:	db850513          	addi	a0,a0,-584 # ffffffffc0204688 <commands+0x228>
}
ffffffffc02008d8:	6442                	ld	s0,16(sp)
ffffffffc02008da:	60e2                	ld	ra,24(sp)
ffffffffc02008dc:	64a2                	ld	s1,8(sp)
ffffffffc02008de:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008e0:	fdeff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008e4:	00004517          	auipc	a0,0x4
ffffffffc02008e8:	dc450513          	addi	a0,a0,-572 # ffffffffc02046a8 <commands+0x248>
ffffffffc02008ec:	b7f5                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ee:	00004517          	auipc	a0,0x4
ffffffffc02008f2:	dda50513          	addi	a0,a0,-550 # ffffffffc02046c8 <commands+0x268>
ffffffffc02008f6:	b7cd                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008f8:	00004517          	auipc	a0,0x4
ffffffffc02008fc:	de850513          	addi	a0,a0,-536 # ffffffffc02046e0 <commands+0x280>
ffffffffc0200900:	bfe1                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	dee50513          	addi	a0,a0,-530 # ffffffffc02046f0 <commands+0x290>
ffffffffc020090a:	b7f9                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	e0450513          	addi	a0,a0,-508 # ffffffffc0204710 <commands+0x2b0>
ffffffffc0200914:	faaff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	be7ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d15d                	beqz	a0,ffffffffc02008c6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e3bff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	dfe60613          	addi	a2,a2,-514 # ffffffffc0204728 <commands+0x2c8>
ffffffffc0200932:	0cf00593          	li	a1,207
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	ff250513          	addi	a0,a0,-14 # ffffffffc0204928 <commands+0x4c8>
ffffffffc020093e:	a37ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	e0650513          	addi	a0,a0,-506 # ffffffffc0204748 <commands+0x2e8>
ffffffffc020094a:	b779                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	e1450513          	addi	a0,a0,-492 # ffffffffc0204760 <commands+0x300>
ffffffffc0200954:	f6aff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200958:	8522                	mv	a0,s0
ffffffffc020095a:	ba7ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020095e:	84aa                	mv	s1,a0
ffffffffc0200960:	d13d                	beqz	a0,ffffffffc02008c6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200962:	8522                	mv	a0,s0
ffffffffc0200964:	dfbff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200968:	86a6                	mv	a3,s1
ffffffffc020096a:	00004617          	auipc	a2,0x4
ffffffffc020096e:	dbe60613          	addi	a2,a2,-578 # ffffffffc0204728 <commands+0x2c8>
ffffffffc0200972:	0d900593          	li	a1,217
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	fb250513          	addi	a0,a0,-78 # ffffffffc0204928 <commands+0x4c8>
ffffffffc020097e:	9f7ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	df650513          	addi	a0,a0,-522 # ffffffffc0204778 <commands+0x318>
ffffffffc020098a:	b7b9                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020098c:	00004517          	auipc	a0,0x4
ffffffffc0200990:	e0c50513          	addi	a0,a0,-500 # ffffffffc0204798 <commands+0x338>
ffffffffc0200994:	b791                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200996:	00004517          	auipc	a0,0x4
ffffffffc020099a:	e2250513          	addi	a0,a0,-478 # ffffffffc02047b8 <commands+0x358>
ffffffffc020099e:	bf2d                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	e3850513          	addi	a0,a0,-456 # ffffffffc02047d8 <commands+0x378>
ffffffffc02009a8:	bf05                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009aa:	00004517          	auipc	a0,0x4
ffffffffc02009ae:	e4e50513          	addi	a0,a0,-434 # ffffffffc02047f8 <commands+0x398>
ffffffffc02009b2:	b71d                	j	ffffffffc02008d8 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009b4:	00004517          	auipc	a0,0x4
ffffffffc02009b8:	e5c50513          	addi	a0,a0,-420 # ffffffffc0204810 <commands+0x3b0>
ffffffffc02009bc:	f02ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c0:	8522                	mv	a0,s0
ffffffffc02009c2:	b3fff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009c6:	84aa                	mv	s1,a0
ffffffffc02009c8:	ee050fe3          	beqz	a0,ffffffffc02008c6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009cc:	8522                	mv	a0,s0
ffffffffc02009ce:	d91ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d2:	86a6                	mv	a3,s1
ffffffffc02009d4:	00004617          	auipc	a2,0x4
ffffffffc02009d8:	d5460613          	addi	a2,a2,-684 # ffffffffc0204728 <commands+0x2c8>
ffffffffc02009dc:	0ef00593          	li	a1,239
ffffffffc02009e0:	00004517          	auipc	a0,0x4
ffffffffc02009e4:	f4850513          	addi	a0,a0,-184 # ffffffffc0204928 <commands+0x4c8>
ffffffffc02009e8:	98dff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc02009ec:	6442                	ld	s0,16(sp)
ffffffffc02009ee:	60e2                	ld	ra,24(sp)
ffffffffc02009f0:	64a2                	ld	s1,8(sp)
ffffffffc02009f2:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009f4:	d6bff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009f8:	d67ff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009fc:	8522                	mv	a0,s0
ffffffffc02009fe:	d61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a02:	86a6                	mv	a3,s1
ffffffffc0200a04:	00004617          	auipc	a2,0x4
ffffffffc0200a08:	d2460613          	addi	a2,a2,-732 # ffffffffc0204728 <commands+0x2c8>
ffffffffc0200a0c:	0f600593          	li	a1,246
ffffffffc0200a10:	00004517          	auipc	a0,0x4
ffffffffc0200a14:	f1850513          	addi	a0,a0,-232 # ffffffffc0204928 <commands+0x4c8>
ffffffffc0200a18:	95dff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a1c <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a1c:	11853783          	ld	a5,280(a0)
ffffffffc0200a20:	0007c463          	bltz	a5,ffffffffc0200a28 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a24:	e65ff06f          	j	ffffffffc0200888 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a28:	d99ff06f          	j	ffffffffc02007c0 <interrupt_handler>
ffffffffc0200a2c:	0000                	unimp
	...

ffffffffc0200a30 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a30:	14011073          	csrw	sscratch,sp
ffffffffc0200a34:	712d                	addi	sp,sp,-288
ffffffffc0200a36:	e406                	sd	ra,8(sp)
ffffffffc0200a38:	ec0e                	sd	gp,24(sp)
ffffffffc0200a3a:	f012                	sd	tp,32(sp)
ffffffffc0200a3c:	f416                	sd	t0,40(sp)
ffffffffc0200a3e:	f81a                	sd	t1,48(sp)
ffffffffc0200a40:	fc1e                	sd	t2,56(sp)
ffffffffc0200a42:	e0a2                	sd	s0,64(sp)
ffffffffc0200a44:	e4a6                	sd	s1,72(sp)
ffffffffc0200a46:	e8aa                	sd	a0,80(sp)
ffffffffc0200a48:	ecae                	sd	a1,88(sp)
ffffffffc0200a4a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a4c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a4e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a50:	fcbe                	sd	a5,120(sp)
ffffffffc0200a52:	e142                	sd	a6,128(sp)
ffffffffc0200a54:	e546                	sd	a7,136(sp)
ffffffffc0200a56:	e94a                	sd	s2,144(sp)
ffffffffc0200a58:	ed4e                	sd	s3,152(sp)
ffffffffc0200a5a:	f152                	sd	s4,160(sp)
ffffffffc0200a5c:	f556                	sd	s5,168(sp)
ffffffffc0200a5e:	f95a                	sd	s6,176(sp)
ffffffffc0200a60:	fd5e                	sd	s7,184(sp)
ffffffffc0200a62:	e1e2                	sd	s8,192(sp)
ffffffffc0200a64:	e5e6                	sd	s9,200(sp)
ffffffffc0200a66:	e9ea                	sd	s10,208(sp)
ffffffffc0200a68:	edee                	sd	s11,216(sp)
ffffffffc0200a6a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a6c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a6e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a70:	fdfe                	sd	t6,248(sp)
ffffffffc0200a72:	14002473          	csrr	s0,sscratch
ffffffffc0200a76:	100024f3          	csrr	s1,sstatus
ffffffffc0200a7a:	14102973          	csrr	s2,sepc
ffffffffc0200a7e:	143029f3          	csrr	s3,stval
ffffffffc0200a82:	14202a73          	csrr	s4,scause
ffffffffc0200a86:	e822                	sd	s0,16(sp)
ffffffffc0200a88:	e226                	sd	s1,256(sp)
ffffffffc0200a8a:	e64a                	sd	s2,264(sp)
ffffffffc0200a8c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a8e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a90:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a92:	f8bff0ef          	jal	ra,ffffffffc0200a1c <trap>

ffffffffc0200a96 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a96:	6492                	ld	s1,256(sp)
ffffffffc0200a98:	6932                	ld	s2,264(sp)
ffffffffc0200a9a:	10049073          	csrw	sstatus,s1
ffffffffc0200a9e:	14191073          	csrw	sepc,s2
ffffffffc0200aa2:	60a2                	ld	ra,8(sp)
ffffffffc0200aa4:	61e2                	ld	gp,24(sp)
ffffffffc0200aa6:	7202                	ld	tp,32(sp)
ffffffffc0200aa8:	72a2                	ld	t0,40(sp)
ffffffffc0200aaa:	7342                	ld	t1,48(sp)
ffffffffc0200aac:	73e2                	ld	t2,56(sp)
ffffffffc0200aae:	6406                	ld	s0,64(sp)
ffffffffc0200ab0:	64a6                	ld	s1,72(sp)
ffffffffc0200ab2:	6546                	ld	a0,80(sp)
ffffffffc0200ab4:	65e6                	ld	a1,88(sp)
ffffffffc0200ab6:	7606                	ld	a2,96(sp)
ffffffffc0200ab8:	76a6                	ld	a3,104(sp)
ffffffffc0200aba:	7746                	ld	a4,112(sp)
ffffffffc0200abc:	77e6                	ld	a5,120(sp)
ffffffffc0200abe:	680a                	ld	a6,128(sp)
ffffffffc0200ac0:	68aa                	ld	a7,136(sp)
ffffffffc0200ac2:	694a                	ld	s2,144(sp)
ffffffffc0200ac4:	69ea                	ld	s3,152(sp)
ffffffffc0200ac6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ac8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aca:	7b4a                	ld	s6,176(sp)
ffffffffc0200acc:	7bea                	ld	s7,184(sp)
ffffffffc0200ace:	6c0e                	ld	s8,192(sp)
ffffffffc0200ad0:	6cae                	ld	s9,200(sp)
ffffffffc0200ad2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ad4:	6dee                	ld	s11,216(sp)
ffffffffc0200ad6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ad8:	7eae                	ld	t4,232(sp)
ffffffffc0200ada:	7f4e                	ld	t5,240(sp)
ffffffffc0200adc:	7fee                	ld	t6,248(sp)
ffffffffc0200ade:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ae0:	10200073          	sret
	...

ffffffffc0200af0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200af0:	00011797          	auipc	a5,0x11
ffffffffc0200af4:	99078793          	addi	a5,a5,-1648 # ffffffffc0211480 <free_area>
ffffffffc0200af8:	e79c                	sd	a5,8(a5)
ffffffffc0200afa:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200afc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b00:	8082                	ret

ffffffffc0200b02 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b02:	00011517          	auipc	a0,0x11
ffffffffc0200b06:	98e56503          	lwu	a0,-1650(a0) # ffffffffc0211490 <free_area+0x10>
ffffffffc0200b0a:	8082                	ret

ffffffffc0200b0c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b0c:	715d                	addi	sp,sp,-80
ffffffffc0200b0e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b10:	00011917          	auipc	s2,0x11
ffffffffc0200b14:	97090913          	addi	s2,s2,-1680 # ffffffffc0211480 <free_area>
ffffffffc0200b18:	00893783          	ld	a5,8(s2)
ffffffffc0200b1c:	e486                	sd	ra,72(sp)
ffffffffc0200b1e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b20:	fc26                	sd	s1,56(sp)
ffffffffc0200b22:	f44e                	sd	s3,40(sp)
ffffffffc0200b24:	f052                	sd	s4,32(sp)
ffffffffc0200b26:	ec56                	sd	s5,24(sp)
ffffffffc0200b28:	e85a                	sd	s6,16(sp)
ffffffffc0200b2a:	e45e                	sd	s7,8(sp)
ffffffffc0200b2c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b2e:	31278f63          	beq	a5,s2,ffffffffc0200e4c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b32:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b36:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b38:	8b05                	andi	a4,a4,1
ffffffffc0200b3a:	30070d63          	beqz	a4,ffffffffc0200e54 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b3e:	4401                	li	s0,0
ffffffffc0200b40:	4481                	li	s1,0
ffffffffc0200b42:	a031                	j	ffffffffc0200b4e <default_check+0x42>
ffffffffc0200b44:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b48:	8b09                	andi	a4,a4,2
ffffffffc0200b4a:	30070563          	beqz	a4,ffffffffc0200e54 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b4e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b52:	679c                	ld	a5,8(a5)
ffffffffc0200b54:	2485                	addiw	s1,s1,1
ffffffffc0200b56:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b58:	ff2796e3          	bne	a5,s2,ffffffffc0200b44 <default_check+0x38>
ffffffffc0200b5c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b5e:	3ef000ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc0200b62:	75351963          	bne	a0,s3,ffffffffc02012b4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b66:	4505                	li	a0,1
ffffffffc0200b68:	317000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200b6c:	8a2a                	mv	s4,a0
ffffffffc0200b6e:	48050363          	beqz	a0,ffffffffc0200ff4 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b72:	4505                	li	a0,1
ffffffffc0200b74:	30b000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200b78:	89aa                	mv	s3,a0
ffffffffc0200b7a:	74050d63          	beqz	a0,ffffffffc02012d4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b7e:	4505                	li	a0,1
ffffffffc0200b80:	2ff000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200b84:	8aaa                	mv	s5,a0
ffffffffc0200b86:	4e050763          	beqz	a0,ffffffffc0201074 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b8a:	2f3a0563          	beq	s4,s3,ffffffffc0200e74 <default_check+0x368>
ffffffffc0200b8e:	2eaa0363          	beq	s4,a0,ffffffffc0200e74 <default_check+0x368>
ffffffffc0200b92:	2ea98163          	beq	s3,a0,ffffffffc0200e74 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b96:	000a2783          	lw	a5,0(s4)
ffffffffc0200b9a:	2e079d63          	bnez	a5,ffffffffc0200e94 <default_check+0x388>
ffffffffc0200b9e:	0009a783          	lw	a5,0(s3)
ffffffffc0200ba2:	2e079963          	bnez	a5,ffffffffc0200e94 <default_check+0x388>
ffffffffc0200ba6:	411c                	lw	a5,0(a0)
ffffffffc0200ba8:	2e079663          	bnez	a5,ffffffffc0200e94 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bac:	00011797          	auipc	a5,0x11
ffffffffc0200bb0:	90478793          	addi	a5,a5,-1788 # ffffffffc02114b0 <pages>
ffffffffc0200bb4:	639c                	ld	a5,0(a5)
ffffffffc0200bb6:	00004717          	auipc	a4,0x4
ffffffffc0200bba:	10270713          	addi	a4,a4,258 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0200bbe:	630c                	ld	a1,0(a4)
ffffffffc0200bc0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bc4:	870d                	srai	a4,a4,0x3
ffffffffc0200bc6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bca:	00005697          	auipc	a3,0x5
ffffffffc0200bce:	57668693          	addi	a3,a3,1398 # ffffffffc0206140 <nbase>
ffffffffc0200bd2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bd4:	00011697          	auipc	a3,0x11
ffffffffc0200bd8:	88c68693          	addi	a3,a3,-1908 # ffffffffc0211460 <npage>
ffffffffc0200bdc:	6294                	ld	a3,0(a3)
ffffffffc0200bde:	06b2                	slli	a3,a3,0xc
ffffffffc0200be0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200be2:	0732                	slli	a4,a4,0xc
ffffffffc0200be4:	2cd77863          	bleu	a3,a4,ffffffffc0200eb4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200be8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bec:	870d                	srai	a4,a4,0x3
ffffffffc0200bee:	02b70733          	mul	a4,a4,a1
ffffffffc0200bf2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bf6:	4ed77f63          	bleu	a3,a4,ffffffffc02010f4 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bfa:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bfe:	878d                	srai	a5,a5,0x3
ffffffffc0200c00:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c04:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c06:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c08:	34d7f663          	bleu	a3,a5,ffffffffc0200f54 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c0c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c0e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c12:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c16:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c1a:	00011797          	auipc	a5,0x11
ffffffffc0200c1e:	8727b723          	sd	s2,-1938(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc0200c22:	00011797          	auipc	a5,0x11
ffffffffc0200c26:	8527bf23          	sd	s2,-1954(a5) # ffffffffc0211480 <free_area>
    nr_free = 0;
ffffffffc0200c2a:	00011797          	auipc	a5,0x11
ffffffffc0200c2e:	8607a323          	sw	zero,-1946(a5) # ffffffffc0211490 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c32:	24d000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200c36:	2e051f63          	bnez	a0,ffffffffc0200f34 <default_check+0x428>
    free_page(p0);
ffffffffc0200c3a:	4585                	li	a1,1
ffffffffc0200c3c:	8552                	mv	a0,s4
ffffffffc0200c3e:	2c9000ef          	jal	ra,ffffffffc0201706 <free_pages>
    free_page(p1);
ffffffffc0200c42:	4585                	li	a1,1
ffffffffc0200c44:	854e                	mv	a0,s3
ffffffffc0200c46:	2c1000ef          	jal	ra,ffffffffc0201706 <free_pages>
    free_page(p2);
ffffffffc0200c4a:	4585                	li	a1,1
ffffffffc0200c4c:	8556                	mv	a0,s5
ffffffffc0200c4e:	2b9000ef          	jal	ra,ffffffffc0201706 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c52:	01092703          	lw	a4,16(s2)
ffffffffc0200c56:	478d                	li	a5,3
ffffffffc0200c58:	2af71e63          	bne	a4,a5,ffffffffc0200f14 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c5c:	4505                	li	a0,1
ffffffffc0200c5e:	221000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200c62:	89aa                	mv	s3,a0
ffffffffc0200c64:	28050863          	beqz	a0,ffffffffc0200ef4 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c68:	4505                	li	a0,1
ffffffffc0200c6a:	215000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200c6e:	8aaa                	mv	s5,a0
ffffffffc0200c70:	3e050263          	beqz	a0,ffffffffc0201054 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c74:	4505                	li	a0,1
ffffffffc0200c76:	209000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200c7a:	8a2a                	mv	s4,a0
ffffffffc0200c7c:	3a050c63          	beqz	a0,ffffffffc0201034 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	1fd000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200c86:	38051763          	bnez	a0,ffffffffc0201014 <default_check+0x508>
    free_page(p0);
ffffffffc0200c8a:	4585                	li	a1,1
ffffffffc0200c8c:	854e                	mv	a0,s3
ffffffffc0200c8e:	279000ef          	jal	ra,ffffffffc0201706 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c92:	00893783          	ld	a5,8(s2)
ffffffffc0200c96:	23278f63          	beq	a5,s2,ffffffffc0200ed4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c9a:	4505                	li	a0,1
ffffffffc0200c9c:	1e3000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200ca0:	32a99a63          	bne	s3,a0,ffffffffc0200fd4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200ca4:	4505                	li	a0,1
ffffffffc0200ca6:	1d9000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200caa:	30051563          	bnez	a0,ffffffffc0200fb4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cae:	01092783          	lw	a5,16(s2)
ffffffffc0200cb2:	2e079163          	bnez	a5,ffffffffc0200f94 <default_check+0x488>
    free_page(p);
ffffffffc0200cb6:	854e                	mv	a0,s3
ffffffffc0200cb8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cba:	00010797          	auipc	a5,0x10
ffffffffc0200cbe:	7d87b323          	sd	s8,1990(a5) # ffffffffc0211480 <free_area>
ffffffffc0200cc2:	00010797          	auipc	a5,0x10
ffffffffc0200cc6:	7d77b323          	sd	s7,1990(a5) # ffffffffc0211488 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cca:	00010797          	auipc	a5,0x10
ffffffffc0200cce:	7d67a323          	sw	s6,1990(a5) # ffffffffc0211490 <free_area+0x10>
    free_page(p);
ffffffffc0200cd2:	235000ef          	jal	ra,ffffffffc0201706 <free_pages>
    free_page(p1);
ffffffffc0200cd6:	4585                	li	a1,1
ffffffffc0200cd8:	8556                	mv	a0,s5
ffffffffc0200cda:	22d000ef          	jal	ra,ffffffffc0201706 <free_pages>
    free_page(p2);
ffffffffc0200cde:	4585                	li	a1,1
ffffffffc0200ce0:	8552                	mv	a0,s4
ffffffffc0200ce2:	225000ef          	jal	ra,ffffffffc0201706 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ce6:	4515                	li	a0,5
ffffffffc0200ce8:	197000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200cec:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cee:	28050363          	beqz	a0,ffffffffc0200f74 <default_check+0x468>
ffffffffc0200cf2:	651c                	ld	a5,8(a0)
ffffffffc0200cf4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cf6:	8b85                	andi	a5,a5,1
ffffffffc0200cf8:	54079e63          	bnez	a5,ffffffffc0201254 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cfc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cfe:	00093b03          	ld	s6,0(s2)
ffffffffc0200d02:	00893a83          	ld	s5,8(s2)
ffffffffc0200d06:	00010797          	auipc	a5,0x10
ffffffffc0200d0a:	7727bd23          	sd	s2,1914(a5) # ffffffffc0211480 <free_area>
ffffffffc0200d0e:	00010797          	auipc	a5,0x10
ffffffffc0200d12:	7727bd23          	sd	s2,1914(a5) # ffffffffc0211488 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d16:	169000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200d1a:	50051d63          	bnez	a0,ffffffffc0201234 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d1e:	09098a13          	addi	s4,s3,144
ffffffffc0200d22:	8552                	mv	a0,s4
ffffffffc0200d24:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d26:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d2a:	00010797          	auipc	a5,0x10
ffffffffc0200d2e:	7607a323          	sw	zero,1894(a5) # ffffffffc0211490 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d32:	1d5000ef          	jal	ra,ffffffffc0201706 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d36:	4511                	li	a0,4
ffffffffc0200d38:	147000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200d3c:	4c051c63          	bnez	a0,ffffffffc0201214 <default_check+0x708>
ffffffffc0200d40:	0989b783          	ld	a5,152(s3)
ffffffffc0200d44:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d46:	8b85                	andi	a5,a5,1
ffffffffc0200d48:	4a078663          	beqz	a5,ffffffffc02011f4 <default_check+0x6e8>
ffffffffc0200d4c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d50:	478d                	li	a5,3
ffffffffc0200d52:	4af71163          	bne	a4,a5,ffffffffc02011f4 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d56:	450d                	li	a0,3
ffffffffc0200d58:	127000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200d5c:	8c2a                	mv	s8,a0
ffffffffc0200d5e:	46050b63          	beqz	a0,ffffffffc02011d4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d62:	4505                	li	a0,1
ffffffffc0200d64:	11b000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200d68:	44051663          	bnez	a0,ffffffffc02011b4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d6c:	438a1463          	bne	s4,s8,ffffffffc0201194 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d70:	4585                	li	a1,1
ffffffffc0200d72:	854e                	mv	a0,s3
ffffffffc0200d74:	193000ef          	jal	ra,ffffffffc0201706 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d78:	458d                	li	a1,3
ffffffffc0200d7a:	8552                	mv	a0,s4
ffffffffc0200d7c:	18b000ef          	jal	ra,ffffffffc0201706 <free_pages>
ffffffffc0200d80:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d84:	04898c13          	addi	s8,s3,72
ffffffffc0200d88:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d8a:	8b85                	andi	a5,a5,1
ffffffffc0200d8c:	3e078463          	beqz	a5,ffffffffc0201174 <default_check+0x668>
ffffffffc0200d90:	0189a703          	lw	a4,24(s3)
ffffffffc0200d94:	4785                	li	a5,1
ffffffffc0200d96:	3cf71f63          	bne	a4,a5,ffffffffc0201174 <default_check+0x668>
ffffffffc0200d9a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d9e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200da0:	8b85                	andi	a5,a5,1
ffffffffc0200da2:	3a078963          	beqz	a5,ffffffffc0201154 <default_check+0x648>
ffffffffc0200da6:	018a2703          	lw	a4,24(s4)
ffffffffc0200daa:	478d                	li	a5,3
ffffffffc0200dac:	3af71463          	bne	a4,a5,ffffffffc0201154 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200db0:	4505                	li	a0,1
ffffffffc0200db2:	0cd000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200db6:	36a99f63          	bne	s3,a0,ffffffffc0201134 <default_check+0x628>
    free_page(p0);
ffffffffc0200dba:	4585                	li	a1,1
ffffffffc0200dbc:	14b000ef          	jal	ra,ffffffffc0201706 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200dc0:	4509                	li	a0,2
ffffffffc0200dc2:	0bd000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200dc6:	34aa1763          	bne	s4,a0,ffffffffc0201114 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dca:	4589                	li	a1,2
ffffffffc0200dcc:	13b000ef          	jal	ra,ffffffffc0201706 <free_pages>
    free_page(p2);
ffffffffc0200dd0:	4585                	li	a1,1
ffffffffc0200dd2:	8562                	mv	a0,s8
ffffffffc0200dd4:	133000ef          	jal	ra,ffffffffc0201706 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dd8:	4515                	li	a0,5
ffffffffc0200dda:	0a5000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200dde:	89aa                	mv	s3,a0
ffffffffc0200de0:	48050a63          	beqz	a0,ffffffffc0201274 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200de4:	4505                	li	a0,1
ffffffffc0200de6:	099000ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0200dea:	2e051563          	bnez	a0,ffffffffc02010d4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dee:	01092783          	lw	a5,16(s2)
ffffffffc0200df2:	2c079163          	bnez	a5,ffffffffc02010b4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200df6:	4595                	li	a1,5
ffffffffc0200df8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dfa:	00010797          	auipc	a5,0x10
ffffffffc0200dfe:	6977ab23          	sw	s7,1686(a5) # ffffffffc0211490 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e02:	00010797          	auipc	a5,0x10
ffffffffc0200e06:	6767bf23          	sd	s6,1662(a5) # ffffffffc0211480 <free_area>
ffffffffc0200e0a:	00010797          	auipc	a5,0x10
ffffffffc0200e0e:	6757bf23          	sd	s5,1662(a5) # ffffffffc0211488 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e12:	0f5000ef          	jal	ra,ffffffffc0201706 <free_pages>
    return listelm->next;
ffffffffc0200e16:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e1a:	01278963          	beq	a5,s2,ffffffffc0200e2c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e1e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e22:	679c                	ld	a5,8(a5)
ffffffffc0200e24:	34fd                	addiw	s1,s1,-1
ffffffffc0200e26:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e28:	ff279be3          	bne	a5,s2,ffffffffc0200e1e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e2c:	26049463          	bnez	s1,ffffffffc0201094 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e30:	46041263          	bnez	s0,ffffffffc0201294 <default_check+0x788>
}
ffffffffc0200e34:	60a6                	ld	ra,72(sp)
ffffffffc0200e36:	6406                	ld	s0,64(sp)
ffffffffc0200e38:	74e2                	ld	s1,56(sp)
ffffffffc0200e3a:	7942                	ld	s2,48(sp)
ffffffffc0200e3c:	79a2                	ld	s3,40(sp)
ffffffffc0200e3e:	7a02                	ld	s4,32(sp)
ffffffffc0200e40:	6ae2                	ld	s5,24(sp)
ffffffffc0200e42:	6b42                	ld	s6,16(sp)
ffffffffc0200e44:	6ba2                	ld	s7,8(sp)
ffffffffc0200e46:	6c02                	ld	s8,0(sp)
ffffffffc0200e48:	6161                	addi	sp,sp,80
ffffffffc0200e4a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e4c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e4e:	4401                	li	s0,0
ffffffffc0200e50:	4481                	li	s1,0
ffffffffc0200e52:	b331                	j	ffffffffc0200b5e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e54:	00004697          	auipc	a3,0x4
ffffffffc0200e58:	e6c68693          	addi	a3,a3,-404 # ffffffffc0204cc0 <commands+0x860>
ffffffffc0200e5c:	00004617          	auipc	a2,0x4
ffffffffc0200e60:	e7460613          	addi	a2,a2,-396 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200e64:	0f000593          	li	a1,240
ffffffffc0200e68:	00004517          	auipc	a0,0x4
ffffffffc0200e6c:	e8050513          	addi	a0,a0,-384 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200e70:	d04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e74:	00004697          	auipc	a3,0x4
ffffffffc0200e78:	f0c68693          	addi	a3,a3,-244 # ffffffffc0204d80 <commands+0x920>
ffffffffc0200e7c:	00004617          	auipc	a2,0x4
ffffffffc0200e80:	e5460613          	addi	a2,a2,-428 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200e84:	0bd00593          	li	a1,189
ffffffffc0200e88:	00004517          	auipc	a0,0x4
ffffffffc0200e8c:	e6050513          	addi	a0,a0,-416 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200e90:	ce4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e94:	00004697          	auipc	a3,0x4
ffffffffc0200e98:	f1468693          	addi	a3,a3,-236 # ffffffffc0204da8 <commands+0x948>
ffffffffc0200e9c:	00004617          	auipc	a2,0x4
ffffffffc0200ea0:	e3460613          	addi	a2,a2,-460 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200ea4:	0be00593          	li	a1,190
ffffffffc0200ea8:	00004517          	auipc	a0,0x4
ffffffffc0200eac:	e4050513          	addi	a0,a0,-448 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200eb0:	cc4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	f3468693          	addi	a3,a3,-204 # ffffffffc0204de8 <commands+0x988>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	e1460613          	addi	a2,a2,-492 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200ec4:	0c000593          	li	a1,192
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	e2050513          	addi	a0,a0,-480 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200ed0:	ca4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	f9c68693          	addi	a3,a3,-100 # ffffffffc0204e70 <commands+0xa10>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	df460613          	addi	a2,a2,-524 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200ee4:	0d900593          	li	a1,217
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	e0050513          	addi	a0,a0,-512 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200ef0:	c84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	e2c68693          	addi	a3,a3,-468 # ffffffffc0204d20 <commands+0x8c0>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	dd460613          	addi	a2,a2,-556 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200f04:	0d200593          	li	a1,210
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	de050513          	addi	a0,a0,-544 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200f10:	c64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	f4c68693          	addi	a3,a3,-180 # ffffffffc0204e60 <commands+0xa00>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	db460613          	addi	a2,a2,-588 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200f24:	0d000593          	li	a1,208
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	dc050513          	addi	a0,a0,-576 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200f30:	c44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	f1468693          	addi	a3,a3,-236 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	d9460613          	addi	a2,a2,-620 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200f44:	0cb00593          	li	a1,203
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	da050513          	addi	a0,a0,-608 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200f50:	c24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f54:	00004697          	auipc	a3,0x4
ffffffffc0200f58:	ed468693          	addi	a3,a3,-300 # ffffffffc0204e28 <commands+0x9c8>
ffffffffc0200f5c:	00004617          	auipc	a2,0x4
ffffffffc0200f60:	d7460613          	addi	a2,a2,-652 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200f64:	0c200593          	li	a1,194
ffffffffc0200f68:	00004517          	auipc	a0,0x4
ffffffffc0200f6c:	d8050513          	addi	a0,a0,-640 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200f70:	c04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f74:	00004697          	auipc	a3,0x4
ffffffffc0200f78:	f4468693          	addi	a3,a3,-188 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc0200f7c:	00004617          	auipc	a2,0x4
ffffffffc0200f80:	d5460613          	addi	a2,a2,-684 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200f84:	0f800593          	li	a1,248
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	d6050513          	addi	a0,a0,-672 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200f90:	be4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f94:	00004697          	auipc	a3,0x4
ffffffffc0200f98:	f1468693          	addi	a3,a3,-236 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc0200f9c:	00004617          	auipc	a2,0x4
ffffffffc0200fa0:	d3460613          	addi	a2,a2,-716 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200fa4:	0df00593          	li	a1,223
ffffffffc0200fa8:	00004517          	auipc	a0,0x4
ffffffffc0200fac:	d4050513          	addi	a0,a0,-704 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200fb0:	bc4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb4:	00004697          	auipc	a3,0x4
ffffffffc0200fb8:	e9468693          	addi	a3,a3,-364 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc0200fbc:	00004617          	auipc	a2,0x4
ffffffffc0200fc0:	d1460613          	addi	a2,a2,-748 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200fc4:	0dd00593          	li	a1,221
ffffffffc0200fc8:	00004517          	auipc	a0,0x4
ffffffffc0200fcc:	d2050513          	addi	a0,a0,-736 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200fd0:	ba4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fd4:	00004697          	auipc	a3,0x4
ffffffffc0200fd8:	eb468693          	addi	a3,a3,-332 # ffffffffc0204e88 <commands+0xa28>
ffffffffc0200fdc:	00004617          	auipc	a2,0x4
ffffffffc0200fe0:	cf460613          	addi	a2,a2,-780 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200fe4:	0dc00593          	li	a1,220
ffffffffc0200fe8:	00004517          	auipc	a0,0x4
ffffffffc0200fec:	d0050513          	addi	a0,a0,-768 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0200ff0:	b84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ff4:	00004697          	auipc	a3,0x4
ffffffffc0200ff8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204d20 <commands+0x8c0>
ffffffffc0200ffc:	00004617          	auipc	a2,0x4
ffffffffc0201000:	cd460613          	addi	a2,a2,-812 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201004:	0b900593          	li	a1,185
ffffffffc0201008:	00004517          	auipc	a0,0x4
ffffffffc020100c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201010:	b64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201014:	00004697          	auipc	a3,0x4
ffffffffc0201018:	e3468693          	addi	a3,a3,-460 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc020101c:	00004617          	auipc	a2,0x4
ffffffffc0201020:	cb460613          	addi	a2,a2,-844 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201024:	0d600593          	li	a1,214
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	cc050513          	addi	a0,a0,-832 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201030:	b44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201034:	00004697          	auipc	a3,0x4
ffffffffc0201038:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204d60 <commands+0x900>
ffffffffc020103c:	00004617          	auipc	a2,0x4
ffffffffc0201040:	c9460613          	addi	a2,a2,-876 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201044:	0d400593          	li	a1,212
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	ca050513          	addi	a0,a0,-864 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201050:	b24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201054:	00004697          	auipc	a3,0x4
ffffffffc0201058:	cec68693          	addi	a3,a3,-788 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	c7460613          	addi	a2,a2,-908 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201064:	0d300593          	li	a1,211
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	c8050513          	addi	a0,a0,-896 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201070:	b04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201074:	00004697          	auipc	a3,0x4
ffffffffc0201078:	cec68693          	addi	a3,a3,-788 # ffffffffc0204d60 <commands+0x900>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	c5460613          	addi	a2,a2,-940 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201084:	0bb00593          	li	a1,187
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	c6050513          	addi	a0,a0,-928 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201090:	ae4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201094:	00004697          	auipc	a3,0x4
ffffffffc0201098:	f7468693          	addi	a3,a3,-140 # ffffffffc0205008 <commands+0xba8>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	c3460613          	addi	a2,a2,-972 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02010a4:	12500593          	li	a1,293
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	c4050513          	addi	a0,a0,-960 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02010b0:	ac4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc02010b4:	00004697          	auipc	a3,0x4
ffffffffc02010b8:	df468693          	addi	a3,a3,-524 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02010c4:	11a00593          	li	a1,282
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	c2050513          	addi	a0,a0,-992 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02010d0:	aa4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	d7468693          	addi	a3,a3,-652 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02010e4:	11800593          	li	a1,280
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02010f0:	a84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	d1468693          	addi	a3,a3,-748 # ffffffffc0204e08 <commands+0x9a8>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201104:	0c100593          	li	a1,193
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201110:	a64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201114:	00004697          	auipc	a3,0x4
ffffffffc0201118:	eb468693          	addi	a3,a3,-332 # ffffffffc0204fc8 <commands+0xb68>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201124:	11200593          	li	a1,274
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201130:	a44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201134:	00004697          	auipc	a3,0x4
ffffffffc0201138:	e7468693          	addi	a3,a3,-396 # ffffffffc0204fa8 <commands+0xb48>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201144:	11000593          	li	a1,272
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201150:	a24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201154:	00004697          	auipc	a3,0x4
ffffffffc0201158:	e2c68693          	addi	a3,a3,-468 # ffffffffc0204f80 <commands+0xb20>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201164:	10e00593          	li	a1,270
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201170:	a04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201174:	00004697          	auipc	a3,0x4
ffffffffc0201178:	de468693          	addi	a3,a3,-540 # ffffffffc0204f58 <commands+0xaf8>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201184:	10d00593          	li	a1,269
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201190:	9e4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201194:	00004697          	auipc	a3,0x4
ffffffffc0201198:	db468693          	addi	a3,a3,-588 # ffffffffc0204f48 <commands+0xae8>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02011a4:	10800593          	li	a1,264
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02011b0:	9c4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011b4:	00004697          	auipc	a3,0x4
ffffffffc02011b8:	c9468693          	addi	a3,a3,-876 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02011c4:	10700593          	li	a1,263
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02011d0:	9a4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011d4:	00004697          	auipc	a3,0x4
ffffffffc02011d8:	d5468693          	addi	a3,a3,-684 # ffffffffc0204f28 <commands+0xac8>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	af460613          	addi	a2,a2,-1292 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02011e4:	10600593          	li	a1,262
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02011f0:	984ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011f4:	00004697          	auipc	a3,0x4
ffffffffc02011f8:	d0468693          	addi	a3,a3,-764 # ffffffffc0204ef8 <commands+0xa98>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201204:	10500593          	li	a1,261
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201210:	964ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201214:	00004697          	auipc	a3,0x4
ffffffffc0201218:	ccc68693          	addi	a3,a3,-820 # ffffffffc0204ee0 <commands+0xa80>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201224:	10400593          	li	a1,260
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201230:	944ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	c1468693          	addi	a3,a3,-1004 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201244:	0fe00593          	li	a1,254
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201250:	924ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201254:	00004697          	auipc	a3,0x4
ffffffffc0201258:	c7468693          	addi	a3,a3,-908 # ffffffffc0204ec8 <commands+0xa68>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201264:	0f900593          	li	a1,249
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201270:	904ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	d7468693          	addi	a3,a3,-652 # ffffffffc0204fe8 <commands+0xb88>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201284:	11700593          	li	a1,279
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201290:	8e4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	d8468693          	addi	a3,a3,-636 # ffffffffc0205018 <commands+0xbb8>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02012a4:	12600593          	li	a1,294
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02012b0:	8c4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012b4:	00004697          	auipc	a3,0x4
ffffffffc02012b8:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0204d00 <commands+0x8a0>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02012c4:	0f300593          	li	a1,243
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02012d0:	8a4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012d4:	00004697          	auipc	a3,0x4
ffffffffc02012d8:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02012dc:	00004617          	auipc	a2,0x4
ffffffffc02012e0:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02012e4:	0ba00593          	li	a1,186
ffffffffc02012e8:	00004517          	auipc	a0,0x4
ffffffffc02012ec:	a0050513          	addi	a0,a0,-1536 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02012f0:	884ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02012f4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012f4:	1141                	addi	sp,sp,-16
ffffffffc02012f6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012f8:	18058063          	beqz	a1,ffffffffc0201478 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012fc:	00359693          	slli	a3,a1,0x3
ffffffffc0201300:	96ae                	add	a3,a3,a1
ffffffffc0201302:	068e                	slli	a3,a3,0x3
ffffffffc0201304:	96aa                	add	a3,a3,a0
ffffffffc0201306:	02d50d63          	beq	a0,a3,ffffffffc0201340 <default_free_pages+0x4c>
ffffffffc020130a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020130c:	8b85                	andi	a5,a5,1
ffffffffc020130e:	14079563          	bnez	a5,ffffffffc0201458 <default_free_pages+0x164>
ffffffffc0201312:	651c                	ld	a5,8(a0)
ffffffffc0201314:	8385                	srli	a5,a5,0x1
ffffffffc0201316:	8b85                	andi	a5,a5,1
ffffffffc0201318:	14079063          	bnez	a5,ffffffffc0201458 <default_free_pages+0x164>
ffffffffc020131c:	87aa                	mv	a5,a0
ffffffffc020131e:	a809                	j	ffffffffc0201330 <default_free_pages+0x3c>
ffffffffc0201320:	6798                	ld	a4,8(a5)
ffffffffc0201322:	8b05                	andi	a4,a4,1
ffffffffc0201324:	12071a63          	bnez	a4,ffffffffc0201458 <default_free_pages+0x164>
ffffffffc0201328:	6798                	ld	a4,8(a5)
ffffffffc020132a:	8b09                	andi	a4,a4,2
ffffffffc020132c:	12071663          	bnez	a4,ffffffffc0201458 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201330:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201334:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201338:	04878793          	addi	a5,a5,72
ffffffffc020133c:	fed792e3          	bne	a5,a3,ffffffffc0201320 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201340:	2581                	sext.w	a1,a1
ffffffffc0201342:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201344:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201348:	4789                	li	a5,2
ffffffffc020134a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020134e:	00010697          	auipc	a3,0x10
ffffffffc0201352:	13268693          	addi	a3,a3,306 # ffffffffc0211480 <free_area>
ffffffffc0201356:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201358:	669c                	ld	a5,8(a3)
ffffffffc020135a:	9db9                	addw	a1,a1,a4
ffffffffc020135c:	00010717          	auipc	a4,0x10
ffffffffc0201360:	12b72a23          	sw	a1,308(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201364:	08d78f63          	beq	a5,a3,ffffffffc0201402 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201368:	fe078713          	addi	a4,a5,-32
ffffffffc020136c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020136e:	4801                	li	a6,0
ffffffffc0201370:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201374:	00e56a63          	bltu	a0,a4,ffffffffc0201388 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201378:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020137a:	02d70563          	beq	a4,a3,ffffffffc02013a4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020137e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201380:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201384:	fee57ae3          	bleu	a4,a0,ffffffffc0201378 <default_free_pages+0x84>
ffffffffc0201388:	00080663          	beqz	a6,ffffffffc0201394 <default_free_pages+0xa0>
ffffffffc020138c:	00010817          	auipc	a6,0x10
ffffffffc0201390:	0eb83a23          	sd	a1,244(a6) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201394:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201396:	e390                	sd	a2,0(a5)
ffffffffc0201398:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020139a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020139c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020139e:	02d59163          	bne	a1,a3,ffffffffc02013c0 <default_free_pages+0xcc>
ffffffffc02013a2:	a091                	j	ffffffffc02013e6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013a4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013a6:	f514                	sd	a3,40(a0)
ffffffffc02013a8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013aa:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013ac:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ae:	00d70563          	beq	a4,a3,ffffffffc02013b8 <default_free_pages+0xc4>
ffffffffc02013b2:	4805                	li	a6,1
ffffffffc02013b4:	87ba                	mv	a5,a4
ffffffffc02013b6:	b7e9                	j	ffffffffc0201380 <default_free_pages+0x8c>
ffffffffc02013b8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013ba:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013bc:	02d78163          	beq	a5,a3,ffffffffc02013de <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013c0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013c4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013c8:	02081713          	slli	a4,a6,0x20
ffffffffc02013cc:	9301                	srli	a4,a4,0x20
ffffffffc02013ce:	00371793          	slli	a5,a4,0x3
ffffffffc02013d2:	97ba                	add	a5,a5,a4
ffffffffc02013d4:	078e                	slli	a5,a5,0x3
ffffffffc02013d6:	97b2                	add	a5,a5,a2
ffffffffc02013d8:	02f50e63          	beq	a0,a5,ffffffffc0201414 <default_free_pages+0x120>
ffffffffc02013dc:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02013de:	fe078713          	addi	a4,a5,-32
ffffffffc02013e2:	00d78d63          	beq	a5,a3,ffffffffc02013fc <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013e6:	4d0c                	lw	a1,24(a0)
ffffffffc02013e8:	02059613          	slli	a2,a1,0x20
ffffffffc02013ec:	9201                	srli	a2,a2,0x20
ffffffffc02013ee:	00361693          	slli	a3,a2,0x3
ffffffffc02013f2:	96b2                	add	a3,a3,a2
ffffffffc02013f4:	068e                	slli	a3,a3,0x3
ffffffffc02013f6:	96aa                	add	a3,a3,a0
ffffffffc02013f8:	04d70063          	beq	a4,a3,ffffffffc0201438 <default_free_pages+0x144>
}
ffffffffc02013fc:	60a2                	ld	ra,8(sp)
ffffffffc02013fe:	0141                	addi	sp,sp,16
ffffffffc0201400:	8082                	ret
ffffffffc0201402:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201404:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201408:	e398                	sd	a4,0(a5)
ffffffffc020140a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020140c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020140e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201410:	0141                	addi	sp,sp,16
ffffffffc0201412:	8082                	ret
            p->property += base->property;
ffffffffc0201414:	4d1c                	lw	a5,24(a0)
ffffffffc0201416:	0107883b          	addw	a6,a5,a6
ffffffffc020141a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020141e:	57f5                	li	a5,-3
ffffffffc0201420:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201424:	02053803          	ld	a6,32(a0)
ffffffffc0201428:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020142a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020142c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201430:	659c                	ld	a5,8(a1)
ffffffffc0201432:	01073023          	sd	a6,0(a4)
ffffffffc0201436:	b765                	j	ffffffffc02013de <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020143c:	fe878693          	addi	a3,a5,-24
ffffffffc0201440:	9db9                	addw	a1,a1,a4
ffffffffc0201442:	cd0c                	sw	a1,24(a0)
ffffffffc0201444:	5775                	li	a4,-3
ffffffffc0201446:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020144a:	6398                	ld	a4,0(a5)
ffffffffc020144c:	679c                	ld	a5,8(a5)
}
ffffffffc020144e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201450:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201452:	e398                	sd	a4,0(a5)
ffffffffc0201454:	0141                	addi	sp,sp,16
ffffffffc0201456:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201458:	00004697          	auipc	a3,0x4
ffffffffc020145c:	bd068693          	addi	a3,a3,-1072 # ffffffffc0205028 <commands+0xbc8>
ffffffffc0201460:	00004617          	auipc	a2,0x4
ffffffffc0201464:	87060613          	addi	a2,a2,-1936 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201468:	08300593          	li	a1,131
ffffffffc020146c:	00004517          	auipc	a0,0x4
ffffffffc0201470:	87c50513          	addi	a0,a0,-1924 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201474:	f01fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201478:	00004697          	auipc	a3,0x4
ffffffffc020147c:	bd868693          	addi	a3,a3,-1064 # ffffffffc0205050 <commands+0xbf0>
ffffffffc0201480:	00004617          	auipc	a2,0x4
ffffffffc0201484:	85060613          	addi	a2,a2,-1968 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201488:	08000593          	li	a1,128
ffffffffc020148c:	00004517          	auipc	a0,0x4
ffffffffc0201490:	85c50513          	addi	a0,a0,-1956 # ffffffffc0204ce8 <commands+0x888>
ffffffffc0201494:	ee1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201498 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201498:	cd51                	beqz	a0,ffffffffc0201534 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020149a:	00010597          	auipc	a1,0x10
ffffffffc020149e:	fe658593          	addi	a1,a1,-26 # ffffffffc0211480 <free_area>
ffffffffc02014a2:	0105a803          	lw	a6,16(a1)
ffffffffc02014a6:	862a                	mv	a2,a0
ffffffffc02014a8:	02081793          	slli	a5,a6,0x20
ffffffffc02014ac:	9381                	srli	a5,a5,0x20
ffffffffc02014ae:	00a7ee63          	bltu	a5,a0,ffffffffc02014ca <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014b2:	87ae                	mv	a5,a1
ffffffffc02014b4:	a801                	j	ffffffffc02014c4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014b6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014ba:	02071693          	slli	a3,a4,0x20
ffffffffc02014be:	9281                	srli	a3,a3,0x20
ffffffffc02014c0:	00c6f763          	bleu	a2,a3,ffffffffc02014ce <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014c4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014c6:	feb798e3          	bne	a5,a1,ffffffffc02014b6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ca:	4501                	li	a0,0
}
ffffffffc02014cc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014ce:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02014d2:	dd6d                	beqz	a0,ffffffffc02014cc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02014d4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014d8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02014dc:	00060e1b          	sext.w	t3,a2
ffffffffc02014e0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014e4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014e8:	02d67b63          	bleu	a3,a2,ffffffffc020151e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014ec:	00361693          	slli	a3,a2,0x3
ffffffffc02014f0:	96b2                	add	a3,a3,a2
ffffffffc02014f2:	068e                	slli	a3,a3,0x3
ffffffffc02014f4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014f6:	41c7073b          	subw	a4,a4,t3
ffffffffc02014fa:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014fc:	00868613          	addi	a2,a3,8
ffffffffc0201500:	4709                	li	a4,2
ffffffffc0201502:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201506:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020150a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020150e:	0105a803          	lw	a6,16(a1)
ffffffffc0201512:	e310                	sd	a2,0(a4)
ffffffffc0201514:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201518:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020151a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020151e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201522:	00010717          	auipc	a4,0x10
ffffffffc0201526:	f7072723          	sw	a6,-146(a4) # ffffffffc0211490 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020152a:	5775                	li	a4,-3
ffffffffc020152c:	17a1                	addi	a5,a5,-24
ffffffffc020152e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201532:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201534:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201536:	00004697          	auipc	a3,0x4
ffffffffc020153a:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0205050 <commands+0xbf0>
ffffffffc020153e:	00003617          	auipc	a2,0x3
ffffffffc0201542:	79260613          	addi	a2,a2,1938 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201546:	06200593          	li	a1,98
ffffffffc020154a:	00003517          	auipc	a0,0x3
ffffffffc020154e:	79e50513          	addi	a0,a0,1950 # ffffffffc0204ce8 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201552:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201554:	e21fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201558 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201558:	1141                	addi	sp,sp,-16
ffffffffc020155a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020155c:	c1fd                	beqz	a1,ffffffffc0201642 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020155e:	00359693          	slli	a3,a1,0x3
ffffffffc0201562:	96ae                	add	a3,a3,a1
ffffffffc0201564:	068e                	slli	a3,a3,0x3
ffffffffc0201566:	96aa                	add	a3,a3,a0
ffffffffc0201568:	02d50463          	beq	a0,a3,ffffffffc0201590 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020156c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020156e:	87aa                	mv	a5,a0
ffffffffc0201570:	8b05                	andi	a4,a4,1
ffffffffc0201572:	e709                	bnez	a4,ffffffffc020157c <default_init_memmap+0x24>
ffffffffc0201574:	a07d                	j	ffffffffc0201622 <default_init_memmap+0xca>
ffffffffc0201576:	6798                	ld	a4,8(a5)
ffffffffc0201578:	8b05                	andi	a4,a4,1
ffffffffc020157a:	c745                	beqz	a4,ffffffffc0201622 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020157c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201580:	0007b423          	sd	zero,8(a5)
ffffffffc0201584:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201588:	04878793          	addi	a5,a5,72
ffffffffc020158c:	fed795e3          	bne	a5,a3,ffffffffc0201576 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201590:	2581                	sext.w	a1,a1
ffffffffc0201592:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201594:	4789                	li	a5,2
ffffffffc0201596:	00850713          	addi	a4,a0,8
ffffffffc020159a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020159e:	00010697          	auipc	a3,0x10
ffffffffc02015a2:	ee268693          	addi	a3,a3,-286 # ffffffffc0211480 <free_area>
ffffffffc02015a6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015a8:	669c                	ld	a5,8(a3)
ffffffffc02015aa:	9db9                	addw	a1,a1,a4
ffffffffc02015ac:	00010717          	auipc	a4,0x10
ffffffffc02015b0:	eeb72223          	sw	a1,-284(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015b4:	04d78a63          	beq	a5,a3,ffffffffc0201608 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015b8:	fe078713          	addi	a4,a5,-32
ffffffffc02015bc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015be:	4801                	li	a6,0
ffffffffc02015c0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015c4:	00e56a63          	bltu	a0,a4,ffffffffc02015d8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015c8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015ca:	02d70563          	beq	a4,a3,ffffffffc02015f4 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015ce:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015d0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015d4:	fee57ae3          	bleu	a4,a0,ffffffffc02015c8 <default_init_memmap+0x70>
ffffffffc02015d8:	00080663          	beqz	a6,ffffffffc02015e4 <default_init_memmap+0x8c>
ffffffffc02015dc:	00010717          	auipc	a4,0x10
ffffffffc02015e0:	eab73223          	sd	a1,-348(a4) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015e4:	6398                	ld	a4,0(a5)
}
ffffffffc02015e6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015e8:	e390                	sd	a2,0(a5)
ffffffffc02015ea:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015ec:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015ee:	f118                	sd	a4,32(a0)
ffffffffc02015f0:	0141                	addi	sp,sp,16
ffffffffc02015f2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015f6:	f514                	sd	a3,40(a0)
ffffffffc02015f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015fa:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02015fc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015fe:	00d70e63          	beq	a4,a3,ffffffffc020161a <default_init_memmap+0xc2>
ffffffffc0201602:	4805                	li	a6,1
ffffffffc0201604:	87ba                	mv	a5,a4
ffffffffc0201606:	b7e9                	j	ffffffffc02015d0 <default_init_memmap+0x78>
}
ffffffffc0201608:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020160a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020160e:	e398                	sd	a4,0(a5)
ffffffffc0201610:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201612:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201614:	f11c                	sd	a5,32(a0)
}
ffffffffc0201616:	0141                	addi	sp,sp,16
ffffffffc0201618:	8082                	ret
ffffffffc020161a:	60a2                	ld	ra,8(sp)
ffffffffc020161c:	e290                	sd	a2,0(a3)
ffffffffc020161e:	0141                	addi	sp,sp,16
ffffffffc0201620:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201622:	00004697          	auipc	a3,0x4
ffffffffc0201626:	a3668693          	addi	a3,a3,-1482 # ffffffffc0205058 <commands+0xbf8>
ffffffffc020162a:	00003617          	auipc	a2,0x3
ffffffffc020162e:	6a660613          	addi	a2,a2,1702 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201632:	04900593          	li	a1,73
ffffffffc0201636:	00003517          	auipc	a0,0x3
ffffffffc020163a:	6b250513          	addi	a0,a0,1714 # ffffffffc0204ce8 <commands+0x888>
ffffffffc020163e:	d37fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201642:	00004697          	auipc	a3,0x4
ffffffffc0201646:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205050 <commands+0xbf0>
ffffffffc020164a:	00003617          	auipc	a2,0x3
ffffffffc020164e:	68660613          	addi	a2,a2,1670 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0201652:	04600593          	li	a1,70
ffffffffc0201656:	00003517          	auipc	a0,0x3
ffffffffc020165a:	69250513          	addi	a0,a0,1682 # ffffffffc0204ce8 <commands+0x888>
ffffffffc020165e:	d17fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201662 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201662:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201664:	00004617          	auipc	a2,0x4
ffffffffc0201668:	acc60613          	addi	a2,a2,-1332 # ffffffffc0205130 <default_pmm_manager+0xc8>
ffffffffc020166c:	06500593          	li	a1,101
ffffffffc0201670:	00004517          	auipc	a0,0x4
ffffffffc0201674:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205150 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201678:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020167a:	cfbfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020167e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020167e:	715d                	addi	sp,sp,-80
ffffffffc0201680:	e0a2                	sd	s0,64(sp)
ffffffffc0201682:	fc26                	sd	s1,56(sp)
ffffffffc0201684:	f84a                	sd	s2,48(sp)
ffffffffc0201686:	f44e                	sd	s3,40(sp)
ffffffffc0201688:	f052                	sd	s4,32(sp)
ffffffffc020168a:	ec56                	sd	s5,24(sp)
ffffffffc020168c:	e486                	sd	ra,72(sp)
ffffffffc020168e:	842a                	mv	s0,a0
ffffffffc0201690:	00010497          	auipc	s1,0x10
ffffffffc0201694:	e0848493          	addi	s1,s1,-504 # ffffffffc0211498 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201698:	4985                	li	s3,1
ffffffffc020169a:	00010a17          	auipc	s4,0x10
ffffffffc020169e:	dd6a0a13          	addi	s4,s4,-554 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016a2:	0005091b          	sext.w	s2,a0
ffffffffc02016a6:	00010a97          	auipc	s5,0x10
ffffffffc02016aa:	ef2a8a93          	addi	s5,s5,-270 # ffffffffc0211598 <check_mm_struct>
ffffffffc02016ae:	a00d                	j	ffffffffc02016d0 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016b0:	609c                	ld	a5,0(s1)
ffffffffc02016b2:	6f9c                	ld	a5,24(a5)
ffffffffc02016b4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016b6:	4601                	li	a2,0
ffffffffc02016b8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016ba:	ed0d                	bnez	a0,ffffffffc02016f4 <alloc_pages+0x76>
ffffffffc02016bc:	0289ec63          	bltu	s3,s0,ffffffffc02016f4 <alloc_pages+0x76>
ffffffffc02016c0:	000a2783          	lw	a5,0(s4)
ffffffffc02016c4:	2781                	sext.w	a5,a5
ffffffffc02016c6:	c79d                	beqz	a5,ffffffffc02016f4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016c8:	000ab503          	ld	a0,0(s5)
ffffffffc02016cc:	021010ef          	jal	ra,ffffffffc0202eec <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016d0:	100027f3          	csrr	a5,sstatus
ffffffffc02016d4:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016d6:	8522                	mv	a0,s0
ffffffffc02016d8:	dfe1                	beqz	a5,ffffffffc02016b0 <alloc_pages+0x32>
        intr_disable();
ffffffffc02016da:	e21fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02016de:	609c                	ld	a5,0(s1)
ffffffffc02016e0:	8522                	mv	a0,s0
ffffffffc02016e2:	6f9c                	ld	a5,24(a5)
ffffffffc02016e4:	9782                	jalr	a5
ffffffffc02016e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016e8:	e0dfe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc02016ec:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016ee:	4601                	li	a2,0
ffffffffc02016f0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016f2:	d569                	beqz	a0,ffffffffc02016bc <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02016f4:	60a6                	ld	ra,72(sp)
ffffffffc02016f6:	6406                	ld	s0,64(sp)
ffffffffc02016f8:	74e2                	ld	s1,56(sp)
ffffffffc02016fa:	7942                	ld	s2,48(sp)
ffffffffc02016fc:	79a2                	ld	s3,40(sp)
ffffffffc02016fe:	7a02                	ld	s4,32(sp)
ffffffffc0201700:	6ae2                	ld	s5,24(sp)
ffffffffc0201702:	6161                	addi	sp,sp,80
ffffffffc0201704:	8082                	ret

ffffffffc0201706 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201706:	100027f3          	csrr	a5,sstatus
ffffffffc020170a:	8b89                	andi	a5,a5,2
ffffffffc020170c:	eb89                	bnez	a5,ffffffffc020171e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020170e:	00010797          	auipc	a5,0x10
ffffffffc0201712:	d8a78793          	addi	a5,a5,-630 # ffffffffc0211498 <pmm_manager>
ffffffffc0201716:	639c                	ld	a5,0(a5)
ffffffffc0201718:	0207b303          	ld	t1,32(a5)
ffffffffc020171c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020171e:	1101                	addi	sp,sp,-32
ffffffffc0201720:	ec06                	sd	ra,24(sp)
ffffffffc0201722:	e822                	sd	s0,16(sp)
ffffffffc0201724:	e426                	sd	s1,8(sp)
ffffffffc0201726:	842a                	mv	s0,a0
ffffffffc0201728:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020172a:	dd1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020172e:	00010797          	auipc	a5,0x10
ffffffffc0201732:	d6a78793          	addi	a5,a5,-662 # ffffffffc0211498 <pmm_manager>
ffffffffc0201736:	639c                	ld	a5,0(a5)
ffffffffc0201738:	85a6                	mv	a1,s1
ffffffffc020173a:	8522                	mv	a0,s0
ffffffffc020173c:	739c                	ld	a5,32(a5)
ffffffffc020173e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201740:	6442                	ld	s0,16(sp)
ffffffffc0201742:	60e2                	ld	ra,24(sp)
ffffffffc0201744:	64a2                	ld	s1,8(sp)
ffffffffc0201746:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201748:	dadfe06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc020174c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020174c:	100027f3          	csrr	a5,sstatus
ffffffffc0201750:	8b89                	andi	a5,a5,2
ffffffffc0201752:	eb89                	bnez	a5,ffffffffc0201764 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201754:	00010797          	auipc	a5,0x10
ffffffffc0201758:	d4478793          	addi	a5,a5,-700 # ffffffffc0211498 <pmm_manager>
ffffffffc020175c:	639c                	ld	a5,0(a5)
ffffffffc020175e:	0287b303          	ld	t1,40(a5)
ffffffffc0201762:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201764:	1141                	addi	sp,sp,-16
ffffffffc0201766:	e406                	sd	ra,8(sp)
ffffffffc0201768:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020176a:	d91fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020176e:	00010797          	auipc	a5,0x10
ffffffffc0201772:	d2a78793          	addi	a5,a5,-726 # ffffffffc0211498 <pmm_manager>
ffffffffc0201776:	639c                	ld	a5,0(a5)
ffffffffc0201778:	779c                	ld	a5,40(a5)
ffffffffc020177a:	9782                	jalr	a5
ffffffffc020177c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020177e:	d77fe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201782:	8522                	mv	a0,s0
ffffffffc0201784:	60a2                	ld	ra,8(sp)
ffffffffc0201786:	6402                	ld	s0,0(sp)
ffffffffc0201788:	0141                	addi	sp,sp,16
ffffffffc020178a:	8082                	ret

ffffffffc020178c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020178c:	715d                	addi	sp,sp,-80
ffffffffc020178e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201790:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201794:	1ff4f493          	andi	s1,s1,511
ffffffffc0201798:	048e                	slli	s1,s1,0x3
ffffffffc020179a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020179c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020179e:	f84a                	sd	s2,48(sp)
ffffffffc02017a0:	f44e                	sd	s3,40(sp)
ffffffffc02017a2:	f052                	sd	s4,32(sp)
ffffffffc02017a4:	e486                	sd	ra,72(sp)
ffffffffc02017a6:	e0a2                	sd	s0,64(sp)
ffffffffc02017a8:	ec56                	sd	s5,24(sp)
ffffffffc02017aa:	e85a                	sd	s6,16(sp)
ffffffffc02017ac:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ae:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017b2:	892e                	mv	s2,a1
ffffffffc02017b4:	8a32                	mv	s4,a2
ffffffffc02017b6:	00010997          	auipc	s3,0x10
ffffffffc02017ba:	caa98993          	addi	s3,s3,-854 # ffffffffc0211460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017be:	e3c9                	bnez	a5,ffffffffc0201840 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017c0:	16060163          	beqz	a2,ffffffffc0201922 <get_pte+0x196>
ffffffffc02017c4:	4505                	li	a0,1
ffffffffc02017c6:	eb9ff0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc02017ca:	842a                	mv	s0,a0
ffffffffc02017cc:	14050b63          	beqz	a0,ffffffffc0201922 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017d0:	00010b97          	auipc	s7,0x10
ffffffffc02017d4:	ce0b8b93          	addi	s7,s7,-800 # ffffffffc02114b0 <pages>
ffffffffc02017d8:	000bb503          	ld	a0,0(s7)
ffffffffc02017dc:	00003797          	auipc	a5,0x3
ffffffffc02017e0:	4dc78793          	addi	a5,a5,1244 # ffffffffc0204cb8 <commands+0x858>
ffffffffc02017e4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017e8:	40a40533          	sub	a0,s0,a0
ffffffffc02017ec:	850d                	srai	a0,a0,0x3
ffffffffc02017ee:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017f2:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017f4:	00010997          	auipc	s3,0x10
ffffffffc02017f8:	c6c98993          	addi	s3,s3,-916 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017fc:	00080ab7          	lui	s5,0x80
ffffffffc0201800:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201804:	c01c                	sw	a5,0(s0)
ffffffffc0201806:	57fd                	li	a5,-1
ffffffffc0201808:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020180a:	9556                	add	a0,a0,s5
ffffffffc020180c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020180e:	0532                	slli	a0,a0,0xc
ffffffffc0201810:	16e7f063          	bleu	a4,a5,ffffffffc0201970 <get_pte+0x1e4>
ffffffffc0201814:	00010797          	auipc	a5,0x10
ffffffffc0201818:	c8c78793          	addi	a5,a5,-884 # ffffffffc02114a0 <va_pa_offset>
ffffffffc020181c:	639c                	ld	a5,0(a5)
ffffffffc020181e:	6605                	lui	a2,0x1
ffffffffc0201820:	4581                	li	a1,0
ffffffffc0201822:	953e                	add	a0,a0,a5
ffffffffc0201824:	2e9020ef          	jal	ra,ffffffffc020430c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201828:	000bb683          	ld	a3,0(s7)
ffffffffc020182c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201830:	868d                	srai	a3,a3,0x3
ffffffffc0201832:	036686b3          	mul	a3,a3,s6
ffffffffc0201836:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201838:	06aa                	slli	a3,a3,0xa
ffffffffc020183a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020183e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201840:	77fd                	lui	a5,0xfffff
ffffffffc0201842:	068a                	slli	a3,a3,0x2
ffffffffc0201844:	0009b703          	ld	a4,0(s3)
ffffffffc0201848:	8efd                	and	a3,a3,a5
ffffffffc020184a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020184e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201926 <get_pte+0x19a>
ffffffffc0201852:	00010a97          	auipc	s5,0x10
ffffffffc0201856:	c4ea8a93          	addi	s5,s5,-946 # ffffffffc02114a0 <va_pa_offset>
ffffffffc020185a:	000ab403          	ld	s0,0(s5)
ffffffffc020185e:	01595793          	srli	a5,s2,0x15
ffffffffc0201862:	1ff7f793          	andi	a5,a5,511
ffffffffc0201866:	96a2                	add	a3,a3,s0
ffffffffc0201868:	00379413          	slli	s0,a5,0x3
ffffffffc020186c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020186e:	6014                	ld	a3,0(s0)
ffffffffc0201870:	0016f793          	andi	a5,a3,1
ffffffffc0201874:	ebbd                	bnez	a5,ffffffffc02018ea <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201876:	0a0a0663          	beqz	s4,ffffffffc0201922 <get_pte+0x196>
ffffffffc020187a:	4505                	li	a0,1
ffffffffc020187c:	e03ff0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0201880:	84aa                	mv	s1,a0
ffffffffc0201882:	c145                	beqz	a0,ffffffffc0201922 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201884:	00010b97          	auipc	s7,0x10
ffffffffc0201888:	c2cb8b93          	addi	s7,s7,-980 # ffffffffc02114b0 <pages>
ffffffffc020188c:	000bb503          	ld	a0,0(s7)
ffffffffc0201890:	00003797          	auipc	a5,0x3
ffffffffc0201894:	42878793          	addi	a5,a5,1064 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0201898:	0007bb03          	ld	s6,0(a5)
ffffffffc020189c:	40a48533          	sub	a0,s1,a0
ffffffffc02018a0:	850d                	srai	a0,a0,0x3
ffffffffc02018a2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018a6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018a8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018ac:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018b0:	c09c                	sw	a5,0(s1)
ffffffffc02018b2:	57fd                	li	a5,-1
ffffffffc02018b4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018b6:	9552                	add	a0,a0,s4
ffffffffc02018b8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018ba:	0532                	slli	a0,a0,0xc
ffffffffc02018bc:	08e7fd63          	bleu	a4,a5,ffffffffc0201956 <get_pte+0x1ca>
ffffffffc02018c0:	000ab783          	ld	a5,0(s5)
ffffffffc02018c4:	6605                	lui	a2,0x1
ffffffffc02018c6:	4581                	li	a1,0
ffffffffc02018c8:	953e                	add	a0,a0,a5
ffffffffc02018ca:	243020ef          	jal	ra,ffffffffc020430c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018ce:	000bb683          	ld	a3,0(s7)
ffffffffc02018d2:	40d486b3          	sub	a3,s1,a3
ffffffffc02018d6:	868d                	srai	a3,a3,0x3
ffffffffc02018d8:	036686b3          	mul	a3,a3,s6
ffffffffc02018dc:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02018de:	06aa                	slli	a3,a3,0xa
ffffffffc02018e0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018e4:	e014                	sd	a3,0(s0)
ffffffffc02018e6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018ea:	068a                	slli	a3,a3,0x2
ffffffffc02018ec:	757d                	lui	a0,0xfffff
ffffffffc02018ee:	8ee9                	and	a3,a3,a0
ffffffffc02018f0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02018f4:	04e7f563          	bleu	a4,a5,ffffffffc020193e <get_pte+0x1b2>
ffffffffc02018f8:	000ab503          	ld	a0,0(s5)
ffffffffc02018fc:	00c95793          	srli	a5,s2,0xc
ffffffffc0201900:	1ff7f793          	andi	a5,a5,511
ffffffffc0201904:	96aa                	add	a3,a3,a0
ffffffffc0201906:	00379513          	slli	a0,a5,0x3
ffffffffc020190a:	9536                	add	a0,a0,a3
}
ffffffffc020190c:	60a6                	ld	ra,72(sp)
ffffffffc020190e:	6406                	ld	s0,64(sp)
ffffffffc0201910:	74e2                	ld	s1,56(sp)
ffffffffc0201912:	7942                	ld	s2,48(sp)
ffffffffc0201914:	79a2                	ld	s3,40(sp)
ffffffffc0201916:	7a02                	ld	s4,32(sp)
ffffffffc0201918:	6ae2                	ld	s5,24(sp)
ffffffffc020191a:	6b42                	ld	s6,16(sp)
ffffffffc020191c:	6ba2                	ld	s7,8(sp)
ffffffffc020191e:	6161                	addi	sp,sp,80
ffffffffc0201920:	8082                	ret
            return NULL;
ffffffffc0201922:	4501                	li	a0,0
ffffffffc0201924:	b7e5                	j	ffffffffc020190c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201926:	00003617          	auipc	a2,0x3
ffffffffc020192a:	79260613          	addi	a2,a2,1938 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc020192e:	10200593          	li	a1,258
ffffffffc0201932:	00003517          	auipc	a0,0x3
ffffffffc0201936:	7ae50513          	addi	a0,a0,1966 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020193a:	a3bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020193e:	00003617          	auipc	a2,0x3
ffffffffc0201942:	77a60613          	addi	a2,a2,1914 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc0201946:	10f00593          	li	a1,271
ffffffffc020194a:	00003517          	auipc	a0,0x3
ffffffffc020194e:	79650513          	addi	a0,a0,1942 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0201952:	a23fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201956:	86aa                	mv	a3,a0
ffffffffc0201958:	00003617          	auipc	a2,0x3
ffffffffc020195c:	76060613          	addi	a2,a2,1888 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc0201960:	10b00593          	li	a1,267
ffffffffc0201964:	00003517          	auipc	a0,0x3
ffffffffc0201968:	77c50513          	addi	a0,a0,1916 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020196c:	a09fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201970:	86aa                	mv	a3,a0
ffffffffc0201972:	00003617          	auipc	a2,0x3
ffffffffc0201976:	74660613          	addi	a2,a2,1862 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc020197a:	0ff00593          	li	a1,255
ffffffffc020197e:	00003517          	auipc	a0,0x3
ffffffffc0201982:	76250513          	addi	a0,a0,1890 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0201986:	9effe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020198a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020198a:	1141                	addi	sp,sp,-16
ffffffffc020198c:	e022                	sd	s0,0(sp)
ffffffffc020198e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201990:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201992:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201994:	df9ff0ef          	jal	ra,ffffffffc020178c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201998:	c011                	beqz	s0,ffffffffc020199c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020199a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020199c:	c521                	beqz	a0,ffffffffc02019e4 <get_page+0x5a>
ffffffffc020199e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019a0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019a2:	0017f713          	andi	a4,a5,1
ffffffffc02019a6:	e709                	bnez	a4,ffffffffc02019b0 <get_page+0x26>
}
ffffffffc02019a8:	60a2                	ld	ra,8(sp)
ffffffffc02019aa:	6402                	ld	s0,0(sp)
ffffffffc02019ac:	0141                	addi	sp,sp,16
ffffffffc02019ae:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019b0:	00010717          	auipc	a4,0x10
ffffffffc02019b4:	ab070713          	addi	a4,a4,-1360 # ffffffffc0211460 <npage>
ffffffffc02019b8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019ba:	078a                	slli	a5,a5,0x2
ffffffffc02019bc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019be:	02e7f863          	bleu	a4,a5,ffffffffc02019ee <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc02019c2:	fff80537          	lui	a0,0xfff80
ffffffffc02019c6:	97aa                	add	a5,a5,a0
ffffffffc02019c8:	00010697          	auipc	a3,0x10
ffffffffc02019cc:	ae868693          	addi	a3,a3,-1304 # ffffffffc02114b0 <pages>
ffffffffc02019d0:	6288                	ld	a0,0(a3)
ffffffffc02019d2:	60a2                	ld	ra,8(sp)
ffffffffc02019d4:	6402                	ld	s0,0(sp)
ffffffffc02019d6:	00379713          	slli	a4,a5,0x3
ffffffffc02019da:	97ba                	add	a5,a5,a4
ffffffffc02019dc:	078e                	slli	a5,a5,0x3
ffffffffc02019de:	953e                	add	a0,a0,a5
ffffffffc02019e0:	0141                	addi	sp,sp,16
ffffffffc02019e2:	8082                	ret
ffffffffc02019e4:	60a2                	ld	ra,8(sp)
ffffffffc02019e6:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02019e8:	4501                	li	a0,0
}
ffffffffc02019ea:	0141                	addi	sp,sp,16
ffffffffc02019ec:	8082                	ret
ffffffffc02019ee:	c75ff0ef          	jal	ra,ffffffffc0201662 <pa2page.part.4>

ffffffffc02019f2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019f2:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019f4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019f6:	e406                	sd	ra,8(sp)
ffffffffc02019f8:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019fa:	d93ff0ef          	jal	ra,ffffffffc020178c <get_pte>
    if (ptep != NULL) {
ffffffffc02019fe:	c511                	beqz	a0,ffffffffc0201a0a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a00:	611c                	ld	a5,0(a0)
ffffffffc0201a02:	842a                	mv	s0,a0
ffffffffc0201a04:	0017f713          	andi	a4,a5,1
ffffffffc0201a08:	e709                	bnez	a4,ffffffffc0201a12 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a0a:	60a2                	ld	ra,8(sp)
ffffffffc0201a0c:	6402                	ld	s0,0(sp)
ffffffffc0201a0e:	0141                	addi	sp,sp,16
ffffffffc0201a10:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a12:	00010717          	auipc	a4,0x10
ffffffffc0201a16:	a4e70713          	addi	a4,a4,-1458 # ffffffffc0211460 <npage>
ffffffffc0201a1a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a1c:	078a                	slli	a5,a5,0x2
ffffffffc0201a1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a20:	04e7f063          	bleu	a4,a5,ffffffffc0201a60 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a24:	fff80737          	lui	a4,0xfff80
ffffffffc0201a28:	97ba                	add	a5,a5,a4
ffffffffc0201a2a:	00010717          	auipc	a4,0x10
ffffffffc0201a2e:	a8670713          	addi	a4,a4,-1402 # ffffffffc02114b0 <pages>
ffffffffc0201a32:	6308                	ld	a0,0(a4)
ffffffffc0201a34:	00379713          	slli	a4,a5,0x3
ffffffffc0201a38:	97ba                	add	a5,a5,a4
ffffffffc0201a3a:	078e                	slli	a5,a5,0x3
ffffffffc0201a3c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a3e:	411c                	lw	a5,0(a0)
ffffffffc0201a40:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a44:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a46:	cb09                	beqz	a4,ffffffffc0201a58 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a48:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a4c:	12000073          	sfence.vma
}
ffffffffc0201a50:	60a2                	ld	ra,8(sp)
ffffffffc0201a52:	6402                	ld	s0,0(sp)
ffffffffc0201a54:	0141                	addi	sp,sp,16
ffffffffc0201a56:	8082                	ret
            free_page(page);
ffffffffc0201a58:	4585                	li	a1,1
ffffffffc0201a5a:	cadff0ef          	jal	ra,ffffffffc0201706 <free_pages>
ffffffffc0201a5e:	b7ed                	j	ffffffffc0201a48 <page_remove+0x56>
ffffffffc0201a60:	c03ff0ef          	jal	ra,ffffffffc0201662 <pa2page.part.4>

ffffffffc0201a64 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a64:	7179                	addi	sp,sp,-48
ffffffffc0201a66:	87b2                	mv	a5,a2
ffffffffc0201a68:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a6a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a6c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a6e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a70:	ec26                	sd	s1,24(sp)
ffffffffc0201a72:	f406                	sd	ra,40(sp)
ffffffffc0201a74:	e84a                	sd	s2,16(sp)
ffffffffc0201a76:	e44e                	sd	s3,8(sp)
ffffffffc0201a78:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a7a:	d13ff0ef          	jal	ra,ffffffffc020178c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a7e:	c945                	beqz	a0,ffffffffc0201b2e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a80:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a82:	611c                	ld	a5,0(a0)
ffffffffc0201a84:	892a                	mv	s2,a0
ffffffffc0201a86:	0016871b          	addiw	a4,a3,1
ffffffffc0201a8a:	c018                	sw	a4,0(s0)
ffffffffc0201a8c:	0017f713          	andi	a4,a5,1
ffffffffc0201a90:	e339                	bnez	a4,ffffffffc0201ad6 <page_insert+0x72>
ffffffffc0201a92:	00010797          	auipc	a5,0x10
ffffffffc0201a96:	a1e78793          	addi	a5,a5,-1506 # ffffffffc02114b0 <pages>
ffffffffc0201a9a:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a9c:	00003717          	auipc	a4,0x3
ffffffffc0201aa0:	21c70713          	addi	a4,a4,540 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0201aa4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201aa8:	6300                	ld	s0,0(a4)
ffffffffc0201aaa:	878d                	srai	a5,a5,0x3
ffffffffc0201aac:	000806b7          	lui	a3,0x80
ffffffffc0201ab0:	028787b3          	mul	a5,a5,s0
ffffffffc0201ab4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ab6:	07aa                	slli	a5,a5,0xa
ffffffffc0201ab8:	8fc5                	or	a5,a5,s1
ffffffffc0201aba:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201abe:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ac2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201ac6:	4501                	li	a0,0
}
ffffffffc0201ac8:	70a2                	ld	ra,40(sp)
ffffffffc0201aca:	7402                	ld	s0,32(sp)
ffffffffc0201acc:	64e2                	ld	s1,24(sp)
ffffffffc0201ace:	6942                	ld	s2,16(sp)
ffffffffc0201ad0:	69a2                	ld	s3,8(sp)
ffffffffc0201ad2:	6145                	addi	sp,sp,48
ffffffffc0201ad4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ad6:	00010717          	auipc	a4,0x10
ffffffffc0201ada:	98a70713          	addi	a4,a4,-1654 # ffffffffc0211460 <npage>
ffffffffc0201ade:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ae0:	00279513          	slli	a0,a5,0x2
ffffffffc0201ae4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ae6:	04e57663          	bleu	a4,a0,ffffffffc0201b32 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201aea:	fff807b7          	lui	a5,0xfff80
ffffffffc0201aee:	953e                	add	a0,a0,a5
ffffffffc0201af0:	00010997          	auipc	s3,0x10
ffffffffc0201af4:	9c098993          	addi	s3,s3,-1600 # ffffffffc02114b0 <pages>
ffffffffc0201af8:	0009b783          	ld	a5,0(s3)
ffffffffc0201afc:	00351713          	slli	a4,a0,0x3
ffffffffc0201b00:	953a                	add	a0,a0,a4
ffffffffc0201b02:	050e                	slli	a0,a0,0x3
ffffffffc0201b04:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b06:	00a40e63          	beq	s0,a0,ffffffffc0201b22 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b0a:	411c                	lw	a5,0(a0)
ffffffffc0201b0c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b10:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b12:	cb11                	beqz	a4,ffffffffc0201b26 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b14:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b18:	12000073          	sfence.vma
ffffffffc0201b1c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b20:	bfb5                	j	ffffffffc0201a9c <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b22:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b24:	bfa5                	j	ffffffffc0201a9c <page_insert+0x38>
            free_page(page);
ffffffffc0201b26:	4585                	li	a1,1
ffffffffc0201b28:	bdfff0ef          	jal	ra,ffffffffc0201706 <free_pages>
ffffffffc0201b2c:	b7e5                	j	ffffffffc0201b14 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b2e:	5571                	li	a0,-4
ffffffffc0201b30:	bf61                	j	ffffffffc0201ac8 <page_insert+0x64>
ffffffffc0201b32:	b31ff0ef          	jal	ra,ffffffffc0201662 <pa2page.part.4>

ffffffffc0201b36 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b36:	00003797          	auipc	a5,0x3
ffffffffc0201b3a:	53278793          	addi	a5,a5,1330 # ffffffffc0205068 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b3e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b40:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b42:	00003517          	auipc	a0,0x3
ffffffffc0201b46:	63650513          	addi	a0,a0,1590 # ffffffffc0205178 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b4a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b4c:	00010717          	auipc	a4,0x10
ffffffffc0201b50:	94f73623          	sd	a5,-1716(a4) # ffffffffc0211498 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b54:	e8a2                	sd	s0,80(sp)
ffffffffc0201b56:	e4a6                	sd	s1,72(sp)
ffffffffc0201b58:	e0ca                	sd	s2,64(sp)
ffffffffc0201b5a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b5c:	f852                	sd	s4,48(sp)
ffffffffc0201b5e:	f456                	sd	s5,40(sp)
ffffffffc0201b60:	f05a                	sd	s6,32(sp)
ffffffffc0201b62:	ec5e                	sd	s7,24(sp)
ffffffffc0201b64:	e862                	sd	s8,16(sp)
ffffffffc0201b66:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b68:	00010417          	auipc	s0,0x10
ffffffffc0201b6c:	93040413          	addi	s0,s0,-1744 # ffffffffc0211498 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b70:	d4efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b74:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b76:	49c5                	li	s3,17
ffffffffc0201b78:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b7c:	679c                	ld	a5,8(a5)
ffffffffc0201b7e:	00010497          	auipc	s1,0x10
ffffffffc0201b82:	8e248493          	addi	s1,s1,-1822 # ffffffffc0211460 <npage>
ffffffffc0201b86:	00010917          	auipc	s2,0x10
ffffffffc0201b8a:	92a90913          	addi	s2,s2,-1750 # ffffffffc02114b0 <pages>
ffffffffc0201b8e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b90:	57f5                	li	a5,-3
ffffffffc0201b92:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b94:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b98:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b9c:	015a1593          	slli	a1,s4,0x15
ffffffffc0201ba0:	00003517          	auipc	a0,0x3
ffffffffc0201ba4:	5f050513          	addi	a0,a0,1520 # ffffffffc0205190 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201ba8:	00010717          	auipc	a4,0x10
ffffffffc0201bac:	8ef73c23          	sd	a5,-1800(a4) # ffffffffc02114a0 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bb0:	d0efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201bb4:	00003517          	auipc	a0,0x3
ffffffffc0201bb8:	60c50513          	addi	a0,a0,1548 # ffffffffc02051c0 <default_pmm_manager+0x158>
ffffffffc0201bbc:	d02fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201bc0:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201bc4:	16fd                	addi	a3,a3,-1
ffffffffc0201bc6:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bca:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bce:	00003517          	auipc	a0,0x3
ffffffffc0201bd2:	60a50513          	addi	a0,a0,1546 # ffffffffc02051d8 <default_pmm_manager+0x170>
ffffffffc0201bd6:	ce8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bda:	777d                	lui	a4,0xfffff
ffffffffc0201bdc:	00011797          	auipc	a5,0x11
ffffffffc0201be0:	9c378793          	addi	a5,a5,-1597 # ffffffffc021259f <end+0xfff>
ffffffffc0201be4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201be6:	00088737          	lui	a4,0x88
ffffffffc0201bea:	00010697          	auipc	a3,0x10
ffffffffc0201bee:	86e6bb23          	sd	a4,-1930(a3) # ffffffffc0211460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bf2:	00010717          	auipc	a4,0x10
ffffffffc0201bf6:	8af73f23          	sd	a5,-1858(a4) # ffffffffc02114b0 <pages>
ffffffffc0201bfa:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bfc:	4701                	li	a4,0
ffffffffc0201bfe:	4585                	li	a1,1
ffffffffc0201c00:	fff80637          	lui	a2,0xfff80
ffffffffc0201c04:	a019                	j	ffffffffc0201c0a <pmm_init+0xd4>
ffffffffc0201c06:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c0a:	97b6                	add	a5,a5,a3
ffffffffc0201c0c:	07a1                	addi	a5,a5,8
ffffffffc0201c0e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c12:	609c                	ld	a5,0(s1)
ffffffffc0201c14:	0705                	addi	a4,a4,1
ffffffffc0201c16:	04868693          	addi	a3,a3,72
ffffffffc0201c1a:	00c78533          	add	a0,a5,a2
ffffffffc0201c1e:	fea764e3          	bltu	a4,a0,ffffffffc0201c06 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c22:	00093503          	ld	a0,0(s2)
ffffffffc0201c26:	00379693          	slli	a3,a5,0x3
ffffffffc0201c2a:	96be                	add	a3,a3,a5
ffffffffc0201c2c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c30:	972a                	add	a4,a4,a0
ffffffffc0201c32:	068e                	slli	a3,a3,0x3
ffffffffc0201c34:	96ba                	add	a3,a3,a4
ffffffffc0201c36:	c0200737          	lui	a4,0xc0200
ffffffffc0201c3a:	58e6ea63          	bltu	a3,a4,ffffffffc02021ce <pmm_init+0x698>
ffffffffc0201c3e:	00010997          	auipc	s3,0x10
ffffffffc0201c42:	86298993          	addi	s3,s3,-1950 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0201c46:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c4a:	45c5                	li	a1,17
ffffffffc0201c4c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c4e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c50:	44b6ef63          	bltu	a3,a1,ffffffffc02020ae <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c54:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c56:	00010417          	auipc	s0,0x10
ffffffffc0201c5a:	80240413          	addi	s0,s0,-2046 # ffffffffc0211458 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c5e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c60:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c62:	00003517          	auipc	a0,0x3
ffffffffc0201c66:	5c650513          	addi	a0,a0,1478 # ffffffffc0205228 <default_pmm_manager+0x1c0>
ffffffffc0201c6a:	c54fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c6e:	00007697          	auipc	a3,0x7
ffffffffc0201c72:	39268693          	addi	a3,a3,914 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c76:	0000f797          	auipc	a5,0xf
ffffffffc0201c7a:	7ed7b123          	sd	a3,2018(a5) # ffffffffc0211458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c7e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c82:	0ef6ece3          	bltu	a3,a5,ffffffffc020257a <pmm_init+0xa44>
ffffffffc0201c86:	0009b783          	ld	a5,0(s3)
ffffffffc0201c8a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c8c:	00010797          	auipc	a5,0x10
ffffffffc0201c90:	80d7be23          	sd	a3,-2020(a5) # ffffffffc02114a8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c94:	ab9ff0ef          	jal	ra,ffffffffc020174c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c98:	6098                	ld	a4,0(s1)
ffffffffc0201c9a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c9e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201ca0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201ca2:	0ae7ece3          	bltu	a5,a4,ffffffffc020255a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201ca6:	6008                	ld	a0,0(s0)
ffffffffc0201ca8:	4c050363          	beqz	a0,ffffffffc020216e <pmm_init+0x638>
ffffffffc0201cac:	6785                	lui	a5,0x1
ffffffffc0201cae:	17fd                	addi	a5,a5,-1
ffffffffc0201cb0:	8fe9                	and	a5,a5,a0
ffffffffc0201cb2:	2781                	sext.w	a5,a5
ffffffffc0201cb4:	4a079d63          	bnez	a5,ffffffffc020216e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201cb8:	4601                	li	a2,0
ffffffffc0201cba:	4581                	li	a1,0
ffffffffc0201cbc:	ccfff0ef          	jal	ra,ffffffffc020198a <get_page>
ffffffffc0201cc0:	4c051763          	bnez	a0,ffffffffc020218e <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201cc4:	4505                	li	a0,1
ffffffffc0201cc6:	9b9ff0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0201cca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201ccc:	6008                	ld	a0,0(s0)
ffffffffc0201cce:	4681                	li	a3,0
ffffffffc0201cd0:	4601                	li	a2,0
ffffffffc0201cd2:	85d6                	mv	a1,s5
ffffffffc0201cd4:	d91ff0ef          	jal	ra,ffffffffc0201a64 <page_insert>
ffffffffc0201cd8:	52051763          	bnez	a0,ffffffffc0202206 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cdc:	6008                	ld	a0,0(s0)
ffffffffc0201cde:	4601                	li	a2,0
ffffffffc0201ce0:	4581                	li	a1,0
ffffffffc0201ce2:	aabff0ef          	jal	ra,ffffffffc020178c <get_pte>
ffffffffc0201ce6:	50050063          	beqz	a0,ffffffffc02021e6 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cec:	0017f713          	andi	a4,a5,1
ffffffffc0201cf0:	46070363          	beqz	a4,ffffffffc0202156 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201cf4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cf6:	078a                	slli	a5,a5,0x2
ffffffffc0201cf8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cfa:	44c7f063          	bleu	a2,a5,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cfe:	fff80737          	lui	a4,0xfff80
ffffffffc0201d02:	97ba                	add	a5,a5,a4
ffffffffc0201d04:	00379713          	slli	a4,a5,0x3
ffffffffc0201d08:	00093683          	ld	a3,0(s2)
ffffffffc0201d0c:	97ba                	add	a5,a5,a4
ffffffffc0201d0e:	078e                	slli	a5,a5,0x3
ffffffffc0201d10:	97b6                	add	a5,a5,a3
ffffffffc0201d12:	5efa9463          	bne	s5,a5,ffffffffc02022fa <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d16:	000aab83          	lw	s7,0(s5)
ffffffffc0201d1a:	4785                	li	a5,1
ffffffffc0201d1c:	5afb9f63          	bne	s7,a5,ffffffffc02022da <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d20:	6008                	ld	a0,0(s0)
ffffffffc0201d22:	76fd                	lui	a3,0xfffff
ffffffffc0201d24:	611c                	ld	a5,0(a0)
ffffffffc0201d26:	078a                	slli	a5,a5,0x2
ffffffffc0201d28:	8ff5                	and	a5,a5,a3
ffffffffc0201d2a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d2e:	58c77963          	bleu	a2,a4,ffffffffc02022c0 <pmm_init+0x78a>
ffffffffc0201d32:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d36:	97e2                	add	a5,a5,s8
ffffffffc0201d38:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d3c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d3e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d42:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d46:	56c7f063          	bleu	a2,a5,ffffffffc02022a6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d4a:	4601                	li	a2,0
ffffffffc0201d4c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d4e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d50:	a3dff0ef          	jal	ra,ffffffffc020178c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d54:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d56:	53651863          	bne	a0,s6,ffffffffc0202286 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d5a:	4505                	li	a0,1
ffffffffc0201d5c:	923ff0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0201d60:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d62:	6008                	ld	a0,0(s0)
ffffffffc0201d64:	46d1                	li	a3,20
ffffffffc0201d66:	6605                	lui	a2,0x1
ffffffffc0201d68:	85da                	mv	a1,s6
ffffffffc0201d6a:	cfbff0ef          	jal	ra,ffffffffc0201a64 <page_insert>
ffffffffc0201d6e:	4e051c63          	bnez	a0,ffffffffc0202266 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d72:	6008                	ld	a0,0(s0)
ffffffffc0201d74:	4601                	li	a2,0
ffffffffc0201d76:	6585                	lui	a1,0x1
ffffffffc0201d78:	a15ff0ef          	jal	ra,ffffffffc020178c <get_pte>
ffffffffc0201d7c:	4c050563          	beqz	a0,ffffffffc0202246 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201d80:	611c                	ld	a5,0(a0)
ffffffffc0201d82:	0107f713          	andi	a4,a5,16
ffffffffc0201d86:	4a070063          	beqz	a4,ffffffffc0202226 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201d8a:	8b91                	andi	a5,a5,4
ffffffffc0201d8c:	66078763          	beqz	a5,ffffffffc02023fa <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d90:	6008                	ld	a0,0(s0)
ffffffffc0201d92:	611c                	ld	a5,0(a0)
ffffffffc0201d94:	8bc1                	andi	a5,a5,16
ffffffffc0201d96:	64078263          	beqz	a5,ffffffffc02023da <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201d9a:	000b2783          	lw	a5,0(s6)
ffffffffc0201d9e:	61779e63          	bne	a5,s7,ffffffffc02023ba <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201da2:	4681                	li	a3,0
ffffffffc0201da4:	6605                	lui	a2,0x1
ffffffffc0201da6:	85d6                	mv	a1,s5
ffffffffc0201da8:	cbdff0ef          	jal	ra,ffffffffc0201a64 <page_insert>
ffffffffc0201dac:	5e051763          	bnez	a0,ffffffffc020239a <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201db0:	000aa703          	lw	a4,0(s5)
ffffffffc0201db4:	4789                	li	a5,2
ffffffffc0201db6:	5cf71263          	bne	a4,a5,ffffffffc020237a <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201dba:	000b2783          	lw	a5,0(s6)
ffffffffc0201dbe:	58079e63          	bnez	a5,ffffffffc020235a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dc2:	6008                	ld	a0,0(s0)
ffffffffc0201dc4:	4601                	li	a2,0
ffffffffc0201dc6:	6585                	lui	a1,0x1
ffffffffc0201dc8:	9c5ff0ef          	jal	ra,ffffffffc020178c <get_pte>
ffffffffc0201dcc:	56050763          	beqz	a0,ffffffffc020233a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dd0:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201dd2:	0016f793          	andi	a5,a3,1
ffffffffc0201dd6:	38078063          	beqz	a5,ffffffffc0202156 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201dda:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ddc:	00269793          	slli	a5,a3,0x2
ffffffffc0201de0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201de2:	34e7fc63          	bleu	a4,a5,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201de6:	fff80737          	lui	a4,0xfff80
ffffffffc0201dea:	97ba                	add	a5,a5,a4
ffffffffc0201dec:	00379713          	slli	a4,a5,0x3
ffffffffc0201df0:	00093603          	ld	a2,0(s2)
ffffffffc0201df4:	97ba                	add	a5,a5,a4
ffffffffc0201df6:	078e                	slli	a5,a5,0x3
ffffffffc0201df8:	97b2                	add	a5,a5,a2
ffffffffc0201dfa:	52fa9063          	bne	s5,a5,ffffffffc020231a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dfe:	8ac1                	andi	a3,a3,16
ffffffffc0201e00:	6e069d63          	bnez	a3,ffffffffc02024fa <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e04:	6008                	ld	a0,0(s0)
ffffffffc0201e06:	4581                	li	a1,0
ffffffffc0201e08:	bebff0ef          	jal	ra,ffffffffc02019f2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e0c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e10:	4785                	li	a5,1
ffffffffc0201e12:	6cf71463          	bne	a4,a5,ffffffffc02024da <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e16:	000b2783          	lw	a5,0(s6)
ffffffffc0201e1a:	6a079063          	bnez	a5,ffffffffc02024ba <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e1e:	6008                	ld	a0,0(s0)
ffffffffc0201e20:	6585                	lui	a1,0x1
ffffffffc0201e22:	bd1ff0ef          	jal	ra,ffffffffc02019f2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e26:	000aa783          	lw	a5,0(s5)
ffffffffc0201e2a:	66079863          	bnez	a5,ffffffffc020249a <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e2e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e32:	70079463          	bnez	a5,ffffffffc020253a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e36:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e3a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e3c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e40:	078a                	slli	a5,a5,0x2
ffffffffc0201e42:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e44:	2eb7fb63          	bleu	a1,a5,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e48:	fff80737          	lui	a4,0xfff80
ffffffffc0201e4c:	973e                	add	a4,a4,a5
ffffffffc0201e4e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e52:	00093603          	ld	a2,0(s2)
ffffffffc0201e56:	97ba                	add	a5,a5,a4
ffffffffc0201e58:	078e                	slli	a5,a5,0x3
ffffffffc0201e5a:	00f60733          	add	a4,a2,a5
ffffffffc0201e5e:	4314                	lw	a3,0(a4)
ffffffffc0201e60:	4705                	li	a4,1
ffffffffc0201e62:	6ae69c63          	bne	a3,a4,ffffffffc020251a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e66:	00003a97          	auipc	s5,0x3
ffffffffc0201e6a:	e52a8a93          	addi	s5,s5,-430 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0201e6e:	000ab703          	ld	a4,0(s5)
ffffffffc0201e72:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e76:	00080bb7          	lui	s7,0x80
ffffffffc0201e7a:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e7e:	577d                	li	a4,-1
ffffffffc0201e80:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e82:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e84:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e86:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e88:	2ab77b63          	bleu	a1,a4,ffffffffc020213e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e8c:	0009b783          	ld	a5,0(s3)
ffffffffc0201e90:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e92:	629c                	ld	a5,0(a3)
ffffffffc0201e94:	078a                	slli	a5,a5,0x2
ffffffffc0201e96:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e98:	2ab7f163          	bleu	a1,a5,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e9c:	417787b3          	sub	a5,a5,s7
ffffffffc0201ea0:	00379513          	slli	a0,a5,0x3
ffffffffc0201ea4:	97aa                	add	a5,a5,a0
ffffffffc0201ea6:	00379513          	slli	a0,a5,0x3
ffffffffc0201eaa:	9532                	add	a0,a0,a2
ffffffffc0201eac:	4585                	li	a1,1
ffffffffc0201eae:	859ff0ef          	jal	ra,ffffffffc0201706 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201eb2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201eb6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201eb8:	050a                	slli	a0,a0,0x2
ffffffffc0201eba:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ebc:	26f57f63          	bleu	a5,a0,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ec0:	417507b3          	sub	a5,a0,s7
ffffffffc0201ec4:	00379513          	slli	a0,a5,0x3
ffffffffc0201ec8:	00093703          	ld	a4,0(s2)
ffffffffc0201ecc:	953e                	add	a0,a0,a5
ffffffffc0201ece:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201ed0:	4585                	li	a1,1
ffffffffc0201ed2:	953a                	add	a0,a0,a4
ffffffffc0201ed4:	833ff0ef          	jal	ra,ffffffffc0201706 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201ed8:	601c                	ld	a5,0(s0)
ffffffffc0201eda:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201ede:	86fff0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc0201ee2:	2caa1663          	bne	s4,a0,ffffffffc02021ae <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ee6:	00003517          	auipc	a0,0x3
ffffffffc0201eea:	65250513          	addi	a0,a0,1618 # ffffffffc0205538 <default_pmm_manager+0x4d0>
ffffffffc0201eee:	9d0fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201ef2:	85bff0ef          	jal	ra,ffffffffc020174c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ef6:	6098                	ld	a4,0(s1)
ffffffffc0201ef8:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201efc:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201efe:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f02:	1cd7fd63          	bleu	a3,a5,ffffffffc02020dc <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f06:	83b1                	srli	a5,a5,0xc
ffffffffc0201f08:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f0a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f0e:	1ce7f963          	bleu	a4,a5,ffffffffc02020e0 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f12:	7c7d                	lui	s8,0xfffff
ffffffffc0201f14:	6b85                	lui	s7,0x1
ffffffffc0201f16:	a029                	j	ffffffffc0201f20 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f18:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f1c:	1cf77263          	bleu	a5,a4,ffffffffc02020e0 <pmm_init+0x5aa>
ffffffffc0201f20:	0009b583          	ld	a1,0(s3)
ffffffffc0201f24:	4601                	li	a2,0
ffffffffc0201f26:	95d2                	add	a1,a1,s4
ffffffffc0201f28:	865ff0ef          	jal	ra,ffffffffc020178c <get_pte>
ffffffffc0201f2c:	1c050763          	beqz	a0,ffffffffc02020fa <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f30:	611c                	ld	a5,0(a0)
ffffffffc0201f32:	078a                	slli	a5,a5,0x2
ffffffffc0201f34:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f38:	1f479163          	bne	a5,s4,ffffffffc020211a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f3c:	609c                	ld	a5,0(s1)
ffffffffc0201f3e:	9a5e                	add	s4,s4,s7
ffffffffc0201f40:	6008                	ld	a0,0(s0)
ffffffffc0201f42:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f46:	fcea69e3          	bltu	s4,a4,ffffffffc0201f18 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f4a:	611c                	ld	a5,0(a0)
ffffffffc0201f4c:	6a079363          	bnez	a5,ffffffffc02025f2 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f50:	4505                	li	a0,1
ffffffffc0201f52:	f2cff0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0201f56:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f58:	6008                	ld	a0,0(s0)
ffffffffc0201f5a:	4699                	li	a3,6
ffffffffc0201f5c:	10000613          	li	a2,256
ffffffffc0201f60:	85d2                	mv	a1,s4
ffffffffc0201f62:	b03ff0ef          	jal	ra,ffffffffc0201a64 <page_insert>
ffffffffc0201f66:	66051663          	bnez	a0,ffffffffc02025d2 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f6a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f6e:	4785                	li	a5,1
ffffffffc0201f70:	64f71163          	bne	a4,a5,ffffffffc02025b2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f74:	6008                	ld	a0,0(s0)
ffffffffc0201f76:	6b85                	lui	s7,0x1
ffffffffc0201f78:	4699                	li	a3,6
ffffffffc0201f7a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f7e:	85d2                	mv	a1,s4
ffffffffc0201f80:	ae5ff0ef          	jal	ra,ffffffffc0201a64 <page_insert>
ffffffffc0201f84:	60051763          	bnez	a0,ffffffffc0202592 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201f88:	000a2703          	lw	a4,0(s4)
ffffffffc0201f8c:	4789                	li	a5,2
ffffffffc0201f8e:	4ef71663          	bne	a4,a5,ffffffffc020247a <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f92:	00003597          	auipc	a1,0x3
ffffffffc0201f96:	6de58593          	addi	a1,a1,1758 # ffffffffc0205670 <default_pmm_manager+0x608>
ffffffffc0201f9a:	10000513          	li	a0,256
ffffffffc0201f9e:	314020ef          	jal	ra,ffffffffc02042b2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fa2:	100b8593          	addi	a1,s7,256
ffffffffc0201fa6:	10000513          	li	a0,256
ffffffffc0201faa:	31a020ef          	jal	ra,ffffffffc02042c4 <strcmp>
ffffffffc0201fae:	4a051663          	bnez	a0,ffffffffc020245a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fb2:	00093683          	ld	a3,0(s2)
ffffffffc0201fb6:	000abc83          	ld	s9,0(s5)
ffffffffc0201fba:	00080c37          	lui	s8,0x80
ffffffffc0201fbe:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fc2:	868d                	srai	a3,a3,0x3
ffffffffc0201fc4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc8:	5afd                	li	s5,-1
ffffffffc0201fca:	609c                	ld	a5,0(s1)
ffffffffc0201fcc:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fd0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd2:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd8:	16f77363          	bleu	a5,a4,ffffffffc020213e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fdc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fe0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fe4:	96be                	add	a3,a3,a5
ffffffffc0201fe6:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fea:	284020ef          	jal	ra,ffffffffc020426e <strlen>
ffffffffc0201fee:	44051663          	bnez	a0,ffffffffc020243a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ff2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201ff6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ff8:	000bb783          	ld	a5,0(s7)
ffffffffc0201ffc:	078a                	slli	a5,a5,0x2
ffffffffc0201ffe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202000:	12e7fd63          	bleu	a4,a5,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202004:	418787b3          	sub	a5,a5,s8
ffffffffc0202008:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020200c:	96be                	add	a3,a3,a5
ffffffffc020200e:	039686b3          	mul	a3,a3,s9
ffffffffc0202012:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202014:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202018:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020201a:	12eaf263          	bleu	a4,s5,ffffffffc020213e <pmm_init+0x608>
ffffffffc020201e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202022:	4585                	li	a1,1
ffffffffc0202024:	8552                	mv	a0,s4
ffffffffc0202026:	99b6                	add	s3,s3,a3
ffffffffc0202028:	edeff0ef          	jal	ra,ffffffffc0201706 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020202c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202030:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202032:	078a                	slli	a5,a5,0x2
ffffffffc0202034:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202036:	10e7f263          	bleu	a4,a5,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020203a:	fff809b7          	lui	s3,0xfff80
ffffffffc020203e:	97ce                	add	a5,a5,s3
ffffffffc0202040:	00379513          	slli	a0,a5,0x3
ffffffffc0202044:	00093703          	ld	a4,0(s2)
ffffffffc0202048:	97aa                	add	a5,a5,a0
ffffffffc020204a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020204e:	953a                	add	a0,a0,a4
ffffffffc0202050:	4585                	li	a1,1
ffffffffc0202052:	eb4ff0ef          	jal	ra,ffffffffc0201706 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202056:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020205a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020205c:	050a                	slli	a0,a0,0x2
ffffffffc020205e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202060:	0cf57d63          	bleu	a5,a0,ffffffffc020213a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202064:	013507b3          	add	a5,a0,s3
ffffffffc0202068:	00379513          	slli	a0,a5,0x3
ffffffffc020206c:	00093703          	ld	a4,0(s2)
ffffffffc0202070:	953e                	add	a0,a0,a5
ffffffffc0202072:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202074:	4585                	li	a1,1
ffffffffc0202076:	953a                	add	a0,a0,a4
ffffffffc0202078:	e8eff0ef          	jal	ra,ffffffffc0201706 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020207c:	601c                	ld	a5,0(s0)
ffffffffc020207e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202082:	ecaff0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc0202086:	38ab1a63          	bne	s6,a0,ffffffffc020241a <pmm_init+0x8e4>
}
ffffffffc020208a:	6446                	ld	s0,80(sp)
ffffffffc020208c:	60e6                	ld	ra,88(sp)
ffffffffc020208e:	64a6                	ld	s1,72(sp)
ffffffffc0202090:	6906                	ld	s2,64(sp)
ffffffffc0202092:	79e2                	ld	s3,56(sp)
ffffffffc0202094:	7a42                	ld	s4,48(sp)
ffffffffc0202096:	7aa2                	ld	s5,40(sp)
ffffffffc0202098:	7b02                	ld	s6,32(sp)
ffffffffc020209a:	6be2                	ld	s7,24(sp)
ffffffffc020209c:	6c42                	ld	s8,16(sp)
ffffffffc020209e:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020a0:	00003517          	auipc	a0,0x3
ffffffffc02020a4:	64850513          	addi	a0,a0,1608 # ffffffffc02056e8 <default_pmm_manager+0x680>
}
ffffffffc02020a8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020aa:	814fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020ae:	6705                	lui	a4,0x1
ffffffffc02020b0:	177d                	addi	a4,a4,-1
ffffffffc02020b2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020b4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020b8:	08f77163          	bleu	a5,a4,ffffffffc020213a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020bc:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020c0:	9732                	add	a4,a4,a2
ffffffffc02020c2:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020c6:	767d                	lui	a2,0xfffff
ffffffffc02020c8:	8ef1                	and	a3,a3,a2
ffffffffc02020ca:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020cc:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020d0:	8d95                	sub	a1,a1,a3
ffffffffc02020d2:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020d4:	81b1                	srli	a1,a1,0xc
ffffffffc02020d6:	953e                	add	a0,a0,a5
ffffffffc02020d8:	9702                	jalr	a4
ffffffffc02020da:	bead                	j	ffffffffc0201c54 <pmm_init+0x11e>
ffffffffc02020dc:	6008                	ld	a0,0(s0)
ffffffffc02020de:	b5b5                	j	ffffffffc0201f4a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02020e0:	86d2                	mv	a3,s4
ffffffffc02020e2:	00003617          	auipc	a2,0x3
ffffffffc02020e6:	fd660613          	addi	a2,a2,-42 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc02020ea:	1cd00593          	li	a1,461
ffffffffc02020ee:	00003517          	auipc	a0,0x3
ffffffffc02020f2:	ff250513          	addi	a0,a0,-14 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02020f6:	a7efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02020fa:	00003697          	auipc	a3,0x3
ffffffffc02020fe:	45e68693          	addi	a3,a3,1118 # ffffffffc0205558 <default_pmm_manager+0x4f0>
ffffffffc0202102:	00003617          	auipc	a2,0x3
ffffffffc0202106:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020210a:	1cd00593          	li	a1,461
ffffffffc020210e:	00003517          	auipc	a0,0x3
ffffffffc0202112:	fd250513          	addi	a0,a0,-46 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202116:	a5efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020211a:	00003697          	auipc	a3,0x3
ffffffffc020211e:	47e68693          	addi	a3,a3,1150 # ffffffffc0205598 <default_pmm_manager+0x530>
ffffffffc0202122:	00003617          	auipc	a2,0x3
ffffffffc0202126:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020212a:	1ce00593          	li	a1,462
ffffffffc020212e:	00003517          	auipc	a0,0x3
ffffffffc0202132:	fb250513          	addi	a0,a0,-78 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202136:	a3efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020213a:	d28ff0ef          	jal	ra,ffffffffc0201662 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020213e:	00003617          	auipc	a2,0x3
ffffffffc0202142:	f7a60613          	addi	a2,a2,-134 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc0202146:	06a00593          	li	a1,106
ffffffffc020214a:	00003517          	auipc	a0,0x3
ffffffffc020214e:	00650513          	addi	a0,a0,6 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0202152:	a22fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202156:	00003617          	auipc	a2,0x3
ffffffffc020215a:	1d260613          	addi	a2,a2,466 # ffffffffc0205328 <default_pmm_manager+0x2c0>
ffffffffc020215e:	07000593          	li	a1,112
ffffffffc0202162:	00003517          	auipc	a0,0x3
ffffffffc0202166:	fee50513          	addi	a0,a0,-18 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc020216a:	a0afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020216e:	00003697          	auipc	a3,0x3
ffffffffc0202172:	0fa68693          	addi	a3,a3,250 # ffffffffc0205268 <default_pmm_manager+0x200>
ffffffffc0202176:	00003617          	auipc	a2,0x3
ffffffffc020217a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020217e:	19300593          	li	a1,403
ffffffffc0202182:	00003517          	auipc	a0,0x3
ffffffffc0202186:	f5e50513          	addi	a0,a0,-162 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020218a:	9eafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020218e:	00003697          	auipc	a3,0x3
ffffffffc0202192:	11268693          	addi	a3,a3,274 # ffffffffc02052a0 <default_pmm_manager+0x238>
ffffffffc0202196:	00003617          	auipc	a2,0x3
ffffffffc020219a:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020219e:	19400593          	li	a1,404
ffffffffc02021a2:	00003517          	auipc	a0,0x3
ffffffffc02021a6:	f3e50513          	addi	a0,a0,-194 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02021aa:	9cafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021ae:	00003697          	auipc	a3,0x3
ffffffffc02021b2:	36a68693          	addi	a3,a3,874 # ffffffffc0205518 <default_pmm_manager+0x4b0>
ffffffffc02021b6:	00003617          	auipc	a2,0x3
ffffffffc02021ba:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02021be:	1c000593          	li	a1,448
ffffffffc02021c2:	00003517          	auipc	a0,0x3
ffffffffc02021c6:	f1e50513          	addi	a0,a0,-226 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02021ca:	9aafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021ce:	00003617          	auipc	a2,0x3
ffffffffc02021d2:	03260613          	addi	a2,a2,50 # ffffffffc0205200 <default_pmm_manager+0x198>
ffffffffc02021d6:	07700593          	li	a1,119
ffffffffc02021da:	00003517          	auipc	a0,0x3
ffffffffc02021de:	f0650513          	addi	a0,a0,-250 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02021e2:	992fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021e6:	00003697          	auipc	a3,0x3
ffffffffc02021ea:	11268693          	addi	a3,a3,274 # ffffffffc02052f8 <default_pmm_manager+0x290>
ffffffffc02021ee:	00003617          	auipc	a2,0x3
ffffffffc02021f2:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02021f6:	19a00593          	li	a1,410
ffffffffc02021fa:	00003517          	auipc	a0,0x3
ffffffffc02021fe:	ee650513          	addi	a0,a0,-282 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202202:	972fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202206:	00003697          	auipc	a3,0x3
ffffffffc020220a:	0c268693          	addi	a3,a3,194 # ffffffffc02052c8 <default_pmm_manager+0x260>
ffffffffc020220e:	00003617          	auipc	a2,0x3
ffffffffc0202212:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202216:	19800593          	li	a1,408
ffffffffc020221a:	00003517          	auipc	a0,0x3
ffffffffc020221e:	ec650513          	addi	a0,a0,-314 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202222:	952fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202226:	00003697          	auipc	a3,0x3
ffffffffc020222a:	1ea68693          	addi	a3,a3,490 # ffffffffc0205410 <default_pmm_manager+0x3a8>
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202236:	1a500593          	li	a1,421
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	ea650513          	addi	a0,a0,-346 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202242:	932fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	19a68693          	addi	a3,a3,410 # ffffffffc02053e0 <default_pmm_manager+0x378>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202256:	1a400593          	li	a1,420
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	e8650513          	addi	a0,a0,-378 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202262:	912fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202266:	00003697          	auipc	a3,0x3
ffffffffc020226a:	14268693          	addi	a3,a3,322 # ffffffffc02053a8 <default_pmm_manager+0x340>
ffffffffc020226e:	00003617          	auipc	a2,0x3
ffffffffc0202272:	a6260613          	addi	a2,a2,-1438 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202276:	1a300593          	li	a1,419
ffffffffc020227a:	00003517          	auipc	a0,0x3
ffffffffc020227e:	e6650513          	addi	a0,a0,-410 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202282:	8f2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202286:	00003697          	auipc	a3,0x3
ffffffffc020228a:	0fa68693          	addi	a3,a3,250 # ffffffffc0205380 <default_pmm_manager+0x318>
ffffffffc020228e:	00003617          	auipc	a2,0x3
ffffffffc0202292:	a4260613          	addi	a2,a2,-1470 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202296:	1a000593          	li	a1,416
ffffffffc020229a:	00003517          	auipc	a0,0x3
ffffffffc020229e:	e4650513          	addi	a0,a0,-442 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02022a2:	8d2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022a6:	86da                	mv	a3,s6
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	e1060613          	addi	a2,a2,-496 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc02022b0:	19f00593          	li	a1,415
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	e2c50513          	addi	a0,a0,-468 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02022bc:	8b8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022c0:	86be                	mv	a3,a5
ffffffffc02022c2:	00003617          	auipc	a2,0x3
ffffffffc02022c6:	df660613          	addi	a2,a2,-522 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc02022ca:	19e00593          	li	a1,414
ffffffffc02022ce:	00003517          	auipc	a0,0x3
ffffffffc02022d2:	e1250513          	addi	a0,a0,-494 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02022d6:	89efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02022da:	00003697          	auipc	a3,0x3
ffffffffc02022de:	08e68693          	addi	a3,a3,142 # ffffffffc0205368 <default_pmm_manager+0x300>
ffffffffc02022e2:	00003617          	auipc	a2,0x3
ffffffffc02022e6:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02022ea:	19c00593          	li	a1,412
ffffffffc02022ee:	00003517          	auipc	a0,0x3
ffffffffc02022f2:	df250513          	addi	a0,a0,-526 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02022f6:	87efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022fa:	00003697          	auipc	a3,0x3
ffffffffc02022fe:	05668693          	addi	a3,a3,86 # ffffffffc0205350 <default_pmm_manager+0x2e8>
ffffffffc0202302:	00003617          	auipc	a2,0x3
ffffffffc0202306:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020230a:	19b00593          	li	a1,411
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	dd250513          	addi	a0,a0,-558 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202316:	85efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020231a:	00003697          	auipc	a3,0x3
ffffffffc020231e:	03668693          	addi	a3,a3,54 # ffffffffc0205350 <default_pmm_manager+0x2e8>
ffffffffc0202322:	00003617          	auipc	a2,0x3
ffffffffc0202326:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020232a:	1ae00593          	li	a1,430
ffffffffc020232e:	00003517          	auipc	a0,0x3
ffffffffc0202332:	db250513          	addi	a0,a0,-590 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202336:	83efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020233a:	00003697          	auipc	a3,0x3
ffffffffc020233e:	0a668693          	addi	a3,a3,166 # ffffffffc02053e0 <default_pmm_manager+0x378>
ffffffffc0202342:	00003617          	auipc	a2,0x3
ffffffffc0202346:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020234a:	1ad00593          	li	a1,429
ffffffffc020234e:	00003517          	auipc	a0,0x3
ffffffffc0202352:	d9250513          	addi	a0,a0,-622 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202356:	81efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020235a:	00003697          	auipc	a3,0x3
ffffffffc020235e:	14e68693          	addi	a3,a3,334 # ffffffffc02054a8 <default_pmm_manager+0x440>
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020236a:	1ac00593          	li	a1,428
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	d7250513          	addi	a0,a0,-654 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202376:	ffffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	11668693          	addi	a3,a3,278 # ffffffffc0205490 <default_pmm_manager+0x428>
ffffffffc0202382:	00003617          	auipc	a2,0x3
ffffffffc0202386:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020238a:	1ab00593          	li	a1,427
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	d5250513          	addi	a0,a0,-686 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202396:	fdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	0c668693          	addi	a3,a3,198 # ffffffffc0205460 <default_pmm_manager+0x3f8>
ffffffffc02023a2:	00003617          	auipc	a2,0x3
ffffffffc02023a6:	92e60613          	addi	a2,a2,-1746 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02023aa:	1aa00593          	li	a1,426
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	d3250513          	addi	a0,a0,-718 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02023b6:	fbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	08e68693          	addi	a3,a3,142 # ffffffffc0205448 <default_pmm_manager+0x3e0>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02023ca:	1a800593          	li	a1,424
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	d1250513          	addi	a0,a0,-750 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02023d6:	f9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	05668693          	addi	a3,a3,86 # ffffffffc0205430 <default_pmm_manager+0x3c8>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02023ea:	1a700593          	li	a1,423
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	cf250513          	addi	a0,a0,-782 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02023f6:	f7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	02668693          	addi	a3,a3,38 # ffffffffc0205420 <default_pmm_manager+0x3b8>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020240a:	1a600593          	li	a1,422
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	cd250513          	addi	a0,a0,-814 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202416:	f5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	0fe68693          	addi	a3,a3,254 # ffffffffc0205518 <default_pmm_manager+0x4b0>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020242a:	1e800593          	li	a1,488
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	cb250513          	addi	a0,a0,-846 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202436:	f3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	28668693          	addi	a3,a3,646 # ffffffffc02056c0 <default_pmm_manager+0x658>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020244a:	1e000593          	li	a1,480
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	c9250513          	addi	a0,a0,-878 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202456:	f1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	22e68693          	addi	a3,a3,558 # ffffffffc0205688 <default_pmm_manager+0x620>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020246a:	1dd00593          	li	a1,477
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	c7250513          	addi	a0,a0,-910 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202476:	efffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	1de68693          	addi	a3,a3,478 # ffffffffc0205658 <default_pmm_manager+0x5f0>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020248a:	1d900593          	li	a1,473
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	c5250513          	addi	a0,a0,-942 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202496:	edffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	03e68693          	addi	a3,a3,62 # ffffffffc02054d8 <default_pmm_manager+0x470>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02024aa:	1b600593          	li	a1,438
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	c3250513          	addi	a0,a0,-974 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02024b6:	ebffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024ba:	00003697          	auipc	a3,0x3
ffffffffc02024be:	fee68693          	addi	a3,a3,-18 # ffffffffc02054a8 <default_pmm_manager+0x440>
ffffffffc02024c2:	00003617          	auipc	a2,0x3
ffffffffc02024c6:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02024ca:	1b300593          	li	a1,435
ffffffffc02024ce:	00003517          	auipc	a0,0x3
ffffffffc02024d2:	c1250513          	addi	a0,a0,-1006 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02024d6:	e9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024da:	00003697          	auipc	a3,0x3
ffffffffc02024de:	e8e68693          	addi	a3,a3,-370 # ffffffffc0205368 <default_pmm_manager+0x300>
ffffffffc02024e2:	00002617          	auipc	a2,0x2
ffffffffc02024e6:	7ee60613          	addi	a2,a2,2030 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02024ea:	1b200593          	li	a1,434
ffffffffc02024ee:	00003517          	auipc	a0,0x3
ffffffffc02024f2:	bf250513          	addi	a0,a0,-1038 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02024f6:	e7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024fa:	00003697          	auipc	a3,0x3
ffffffffc02024fe:	fc668693          	addi	a3,a3,-58 # ffffffffc02054c0 <default_pmm_manager+0x458>
ffffffffc0202502:	00002617          	auipc	a2,0x2
ffffffffc0202506:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020250a:	1af00593          	li	a1,431
ffffffffc020250e:	00003517          	auipc	a0,0x3
ffffffffc0202512:	bd250513          	addi	a0,a0,-1070 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202516:	e5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020251a:	00003697          	auipc	a3,0x3
ffffffffc020251e:	fd668693          	addi	a3,a3,-42 # ffffffffc02054f0 <default_pmm_manager+0x488>
ffffffffc0202522:	00002617          	auipc	a2,0x2
ffffffffc0202526:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020252a:	1b900593          	li	a1,441
ffffffffc020252e:	00003517          	auipc	a0,0x3
ffffffffc0202532:	bb250513          	addi	a0,a0,-1102 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202536:	e3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020253a:	00003697          	auipc	a3,0x3
ffffffffc020253e:	f6e68693          	addi	a3,a3,-146 # ffffffffc02054a8 <default_pmm_manager+0x440>
ffffffffc0202542:	00002617          	auipc	a2,0x2
ffffffffc0202546:	78e60613          	addi	a2,a2,1934 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020254a:	1b700593          	li	a1,439
ffffffffc020254e:	00003517          	auipc	a0,0x3
ffffffffc0202552:	b9250513          	addi	a0,a0,-1134 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202556:	e1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020255a:	00003697          	auipc	a3,0x3
ffffffffc020255e:	cee68693          	addi	a3,a3,-786 # ffffffffc0205248 <default_pmm_manager+0x1e0>
ffffffffc0202562:	00002617          	auipc	a2,0x2
ffffffffc0202566:	76e60613          	addi	a2,a2,1902 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020256a:	19200593          	li	a1,402
ffffffffc020256e:	00003517          	auipc	a0,0x3
ffffffffc0202572:	b7250513          	addi	a0,a0,-1166 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202576:	dfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020257a:	00003617          	auipc	a2,0x3
ffffffffc020257e:	c8660613          	addi	a2,a2,-890 # ffffffffc0205200 <default_pmm_manager+0x198>
ffffffffc0202582:	0bd00593          	li	a1,189
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020258e:	de7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	08668693          	addi	a3,a3,134 # ffffffffc0205618 <default_pmm_manager+0x5b0>
ffffffffc020259a:	00002617          	auipc	a2,0x2
ffffffffc020259e:	73660613          	addi	a2,a2,1846 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02025a2:	1d800593          	li	a1,472
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02025ae:	dc7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	04e68693          	addi	a3,a3,78 # ffffffffc0205600 <default_pmm_manager+0x598>
ffffffffc02025ba:	00002617          	auipc	a2,0x2
ffffffffc02025be:	71660613          	addi	a2,a2,1814 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02025c2:	1d700593          	li	a1,471
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02025ce:	da7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	ff668693          	addi	a3,a3,-10 # ffffffffc02055c8 <default_pmm_manager+0x560>
ffffffffc02025da:	00002617          	auipc	a2,0x2
ffffffffc02025de:	6f660613          	addi	a2,a2,1782 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02025e2:	1d600593          	li	a1,470
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	afa50513          	addi	a0,a0,-1286 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02025ee:	d87fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	fbe68693          	addi	a3,a3,-66 # ffffffffc02055b0 <default_pmm_manager+0x548>
ffffffffc02025fa:	00002617          	auipc	a2,0x2
ffffffffc02025fe:	6d660613          	addi	a2,a2,1750 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202602:	1d200593          	li	a1,466
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	ada50513          	addi	a0,a0,-1318 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020260e:	d67fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202612 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202612:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202616:	8082                	ret

ffffffffc0202618 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202618:	7179                	addi	sp,sp,-48
ffffffffc020261a:	e84a                	sd	s2,16(sp)
ffffffffc020261c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020261e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202620:	f022                	sd	s0,32(sp)
ffffffffc0202622:	ec26                	sd	s1,24(sp)
ffffffffc0202624:	e44e                	sd	s3,8(sp)
ffffffffc0202626:	f406                	sd	ra,40(sp)
ffffffffc0202628:	84ae                	mv	s1,a1
ffffffffc020262a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020262c:	852ff0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc0202630:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202632:	cd19                	beqz	a0,ffffffffc0202650 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202634:	85aa                	mv	a1,a0
ffffffffc0202636:	86ce                	mv	a3,s3
ffffffffc0202638:	8626                	mv	a2,s1
ffffffffc020263a:	854a                	mv	a0,s2
ffffffffc020263c:	c28ff0ef          	jal	ra,ffffffffc0201a64 <page_insert>
ffffffffc0202640:	ed39                	bnez	a0,ffffffffc020269e <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202642:	0000f797          	auipc	a5,0xf
ffffffffc0202646:	e2e78793          	addi	a5,a5,-466 # ffffffffc0211470 <swap_init_ok>
ffffffffc020264a:	439c                	lw	a5,0(a5)
ffffffffc020264c:	2781                	sext.w	a5,a5
ffffffffc020264e:	eb89                	bnez	a5,ffffffffc0202660 <pgdir_alloc_page+0x48>
}
ffffffffc0202650:	8522                	mv	a0,s0
ffffffffc0202652:	70a2                	ld	ra,40(sp)
ffffffffc0202654:	7402                	ld	s0,32(sp)
ffffffffc0202656:	64e2                	ld	s1,24(sp)
ffffffffc0202658:	6942                	ld	s2,16(sp)
ffffffffc020265a:	69a2                	ld	s3,8(sp)
ffffffffc020265c:	6145                	addi	sp,sp,48
ffffffffc020265e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202660:	0000f797          	auipc	a5,0xf
ffffffffc0202664:	f3878793          	addi	a5,a5,-200 # ffffffffc0211598 <check_mm_struct>
ffffffffc0202668:	6388                	ld	a0,0(a5)
ffffffffc020266a:	4681                	li	a3,0
ffffffffc020266c:	8622                	mv	a2,s0
ffffffffc020266e:	85a6                	mv	a1,s1
ffffffffc0202670:	06d000ef          	jal	ra,ffffffffc0202edc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202674:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202676:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202678:	4785                	li	a5,1
ffffffffc020267a:	fcf70be3          	beq	a4,a5,ffffffffc0202650 <pgdir_alloc_page+0x38>
ffffffffc020267e:	00003697          	auipc	a3,0x3
ffffffffc0202682:	ae268693          	addi	a3,a3,-1310 # ffffffffc0205160 <default_pmm_manager+0xf8>
ffffffffc0202686:	00002617          	auipc	a2,0x2
ffffffffc020268a:	64a60613          	addi	a2,a2,1610 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020268e:	17a00593          	li	a1,378
ffffffffc0202692:	00003517          	auipc	a0,0x3
ffffffffc0202696:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020269a:	cdbfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc020269e:	8522                	mv	a0,s0
ffffffffc02026a0:	4585                	li	a1,1
ffffffffc02026a2:	864ff0ef          	jal	ra,ffffffffc0201706 <free_pages>
            return NULL;
ffffffffc02026a6:	4401                	li	s0,0
ffffffffc02026a8:	b765                	j	ffffffffc0202650 <pgdir_alloc_page+0x38>

ffffffffc02026aa <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026aa:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026ac:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026ae:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026b0:	fff50713          	addi	a4,a0,-1
ffffffffc02026b4:	17f9                	addi	a5,a5,-2
ffffffffc02026b6:	04e7ee63          	bltu	a5,a4,ffffffffc0202712 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026ba:	6785                	lui	a5,0x1
ffffffffc02026bc:	17fd                	addi	a5,a5,-1
ffffffffc02026be:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026c0:	8131                	srli	a0,a0,0xc
ffffffffc02026c2:	fbdfe0ef          	jal	ra,ffffffffc020167e <alloc_pages>
    assert(base != NULL);
ffffffffc02026c6:	c159                	beqz	a0,ffffffffc020274c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026c8:	0000f797          	auipc	a5,0xf
ffffffffc02026cc:	de878793          	addi	a5,a5,-536 # ffffffffc02114b0 <pages>
ffffffffc02026d0:	639c                	ld	a5,0(a5)
ffffffffc02026d2:	8d1d                	sub	a0,a0,a5
ffffffffc02026d4:	00002797          	auipc	a5,0x2
ffffffffc02026d8:	5e478793          	addi	a5,a5,1508 # ffffffffc0204cb8 <commands+0x858>
ffffffffc02026dc:	6394                	ld	a3,0(a5)
ffffffffc02026de:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026e0:	0000f797          	auipc	a5,0xf
ffffffffc02026e4:	d8078793          	addi	a5,a5,-640 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026e8:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026ec:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026ee:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026f2:	57fd                	li	a5,-1
ffffffffc02026f4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026f6:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026f8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02026fa:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026fc:	02e7fb63          	bleu	a4,a5,ffffffffc0202732 <kmalloc+0x88>
ffffffffc0202700:	0000f797          	auipc	a5,0xf
ffffffffc0202704:	da078793          	addi	a5,a5,-608 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0202708:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020270a:	60a2                	ld	ra,8(sp)
ffffffffc020270c:	953e                	add	a0,a0,a5
ffffffffc020270e:	0141                	addi	sp,sp,16
ffffffffc0202710:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202712:	00003697          	auipc	a3,0x3
ffffffffc0202716:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0205100 <default_pmm_manager+0x98>
ffffffffc020271a:	00002617          	auipc	a2,0x2
ffffffffc020271e:	5b660613          	addi	a2,a2,1462 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202722:	1f000593          	li	a1,496
ffffffffc0202726:	00003517          	auipc	a0,0x3
ffffffffc020272a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc020272e:	c47fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202732:	86aa                	mv	a3,a0
ffffffffc0202734:	00003617          	auipc	a2,0x3
ffffffffc0202738:	98460613          	addi	a2,a2,-1660 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc020273c:	06a00593          	li	a1,106
ffffffffc0202740:	00003517          	auipc	a0,0x3
ffffffffc0202744:	a1050513          	addi	a0,a0,-1520 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0202748:	c2dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020274c:	00003697          	auipc	a3,0x3
ffffffffc0202750:	9d468693          	addi	a3,a3,-1580 # ffffffffc0205120 <default_pmm_manager+0xb8>
ffffffffc0202754:	00002617          	auipc	a2,0x2
ffffffffc0202758:	57c60613          	addi	a2,a2,1404 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020275c:	1f300593          	li	a1,499
ffffffffc0202760:	00003517          	auipc	a0,0x3
ffffffffc0202764:	98050513          	addi	a0,a0,-1664 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202768:	c0dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020276c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020276c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020276e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202770:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202772:	fff58713          	addi	a4,a1,-1
ffffffffc0202776:	17f9                	addi	a5,a5,-2
ffffffffc0202778:	04e7eb63          	bltu	a5,a4,ffffffffc02027ce <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020277c:	c941                	beqz	a0,ffffffffc020280c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020277e:	6785                	lui	a5,0x1
ffffffffc0202780:	17fd                	addi	a5,a5,-1
ffffffffc0202782:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202784:	c02007b7          	lui	a5,0xc0200
ffffffffc0202788:	81b1                	srli	a1,a1,0xc
ffffffffc020278a:	06f56463          	bltu	a0,a5,ffffffffc02027f2 <kfree+0x86>
ffffffffc020278e:	0000f797          	auipc	a5,0xf
ffffffffc0202792:	d1278793          	addi	a5,a5,-750 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0202796:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202798:	0000f717          	auipc	a4,0xf
ffffffffc020279c:	cc870713          	addi	a4,a4,-824 # ffffffffc0211460 <npage>
ffffffffc02027a0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027a2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027a6:	83b1                	srli	a5,a5,0xc
ffffffffc02027a8:	04e7f363          	bleu	a4,a5,ffffffffc02027ee <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ac:	fff80537          	lui	a0,0xfff80
ffffffffc02027b0:	97aa                	add	a5,a5,a0
ffffffffc02027b2:	0000f697          	auipc	a3,0xf
ffffffffc02027b6:	cfe68693          	addi	a3,a3,-770 # ffffffffc02114b0 <pages>
ffffffffc02027ba:	6288                	ld	a0,0(a3)
ffffffffc02027bc:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027c0:	60a2                	ld	ra,8(sp)
ffffffffc02027c2:	97ba                	add	a5,a5,a4
ffffffffc02027c4:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027c6:	953e                	add	a0,a0,a5
}
ffffffffc02027c8:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027ca:	f3dfe06f          	j	ffffffffc0201706 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ce:	00003697          	auipc	a3,0x3
ffffffffc02027d2:	93268693          	addi	a3,a3,-1742 # ffffffffc0205100 <default_pmm_manager+0x98>
ffffffffc02027d6:	00002617          	auipc	a2,0x2
ffffffffc02027da:	4fa60613          	addi	a2,a2,1274 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02027de:	1f900593          	li	a1,505
ffffffffc02027e2:	00003517          	auipc	a0,0x3
ffffffffc02027e6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc02027ea:	b8bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027ee:	e75fe0ef          	jal	ra,ffffffffc0201662 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027f2:	86aa                	mv	a3,a0
ffffffffc02027f4:	00003617          	auipc	a2,0x3
ffffffffc02027f8:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0205200 <default_pmm_manager+0x198>
ffffffffc02027fc:	06c00593          	li	a1,108
ffffffffc0202800:	00003517          	auipc	a0,0x3
ffffffffc0202804:	95050513          	addi	a0,a0,-1712 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0202808:	b6dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020280c:	00003697          	auipc	a3,0x3
ffffffffc0202810:	8e468693          	addi	a3,a3,-1820 # ffffffffc02050f0 <default_pmm_manager+0x88>
ffffffffc0202814:	00002617          	auipc	a2,0x2
ffffffffc0202818:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020281c:	1fa00593          	li	a1,506
ffffffffc0202820:	00003517          	auipc	a0,0x3
ffffffffc0202824:	8c050513          	addi	a0,a0,-1856 # ffffffffc02050e0 <default_pmm_manager+0x78>
ffffffffc0202828:	b4dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020282c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020282c:	7135                	addi	sp,sp,-160
ffffffffc020282e:	ed06                	sd	ra,152(sp)
ffffffffc0202830:	e922                	sd	s0,144(sp)
ffffffffc0202832:	e526                	sd	s1,136(sp)
ffffffffc0202834:	e14a                	sd	s2,128(sp)
ffffffffc0202836:	fcce                	sd	s3,120(sp)
ffffffffc0202838:	f8d2                	sd	s4,112(sp)
ffffffffc020283a:	f4d6                	sd	s5,104(sp)
ffffffffc020283c:	f0da                	sd	s6,96(sp)
ffffffffc020283e:	ecde                	sd	s7,88(sp)
ffffffffc0202840:	e8e2                	sd	s8,80(sp)
ffffffffc0202842:	e4e6                	sd	s9,72(sp)
ffffffffc0202844:	e0ea                	sd	s10,64(sp)
ffffffffc0202846:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202848:	3ec010ef          	jal	ra,ffffffffc0203c34 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020284c:	0000f797          	auipc	a5,0xf
ffffffffc0202850:	cf478793          	addi	a5,a5,-780 # ffffffffc0211540 <max_swap_offset>
ffffffffc0202854:	6394                	ld	a3,0(a5)
ffffffffc0202856:	010007b7          	lui	a5,0x1000
ffffffffc020285a:	17e1                	addi	a5,a5,-8
ffffffffc020285c:	ff968713          	addi	a4,a3,-7
ffffffffc0202860:	42e7ea63          	bltu	a5,a4,ffffffffc0202c94 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     // sm = &swap_manager_fifo;
     sm = &swap_manager_clock;
ffffffffc0202864:	00007797          	auipc	a5,0x7
ffffffffc0202868:	79c78793          	addi	a5,a5,1948 # ffffffffc020a000 <swap_manager_clock>
     // sm = &swap_manager_lru;

     int r = sm->init();
ffffffffc020286c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;
ffffffffc020286e:	0000f697          	auipc	a3,0xf
ffffffffc0202872:	bef6bd23          	sd	a5,-1030(a3) # ffffffffc0211468 <sm>
     int r = sm->init();
ffffffffc0202876:	9702                	jalr	a4
ffffffffc0202878:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020287a:	c10d                	beqz	a0,ffffffffc020289c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020287c:	60ea                	ld	ra,152(sp)
ffffffffc020287e:	644a                	ld	s0,144(sp)
ffffffffc0202880:	855a                	mv	a0,s6
ffffffffc0202882:	64aa                	ld	s1,136(sp)
ffffffffc0202884:	690a                	ld	s2,128(sp)
ffffffffc0202886:	79e6                	ld	s3,120(sp)
ffffffffc0202888:	7a46                	ld	s4,112(sp)
ffffffffc020288a:	7aa6                	ld	s5,104(sp)
ffffffffc020288c:	7b06                	ld	s6,96(sp)
ffffffffc020288e:	6be6                	ld	s7,88(sp)
ffffffffc0202890:	6c46                	ld	s8,80(sp)
ffffffffc0202892:	6ca6                	ld	s9,72(sp)
ffffffffc0202894:	6d06                	ld	s10,64(sp)
ffffffffc0202896:	7de2                	ld	s11,56(sp)
ffffffffc0202898:	610d                	addi	sp,sp,160
ffffffffc020289a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020289c:	0000f797          	auipc	a5,0xf
ffffffffc02028a0:	bcc78793          	addi	a5,a5,-1076 # ffffffffc0211468 <sm>
ffffffffc02028a4:	639c                	ld	a5,0(a5)
ffffffffc02028a6:	00003517          	auipc	a0,0x3
ffffffffc02028aa:	ee250513          	addi	a0,a0,-286 # ffffffffc0205788 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc02028ae:	0000f417          	auipc	s0,0xf
ffffffffc02028b2:	bd240413          	addi	s0,s0,-1070 # ffffffffc0211480 <free_area>
ffffffffc02028b6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028b8:	4785                	li	a5,1
ffffffffc02028ba:	0000f717          	auipc	a4,0xf
ffffffffc02028be:	baf72b23          	sw	a5,-1098(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028c2:	ffcfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028c6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028c8:	2e878a63          	beq	a5,s0,ffffffffc0202bbc <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028cc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02028d0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028d2:	8b05                	andi	a4,a4,1
ffffffffc02028d4:	2e070863          	beqz	a4,ffffffffc0202bc4 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02028d8:	4481                	li	s1,0
ffffffffc02028da:	4901                	li	s2,0
ffffffffc02028dc:	a031                	j	ffffffffc02028e8 <swap_init+0xbc>
ffffffffc02028de:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02028e2:	8b09                	andi	a4,a4,2
ffffffffc02028e4:	2e070063          	beqz	a4,ffffffffc0202bc4 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02028e8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028ec:	679c                	ld	a5,8(a5)
ffffffffc02028ee:	2905                	addiw	s2,s2,1
ffffffffc02028f0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028f2:	fe8796e3          	bne	a5,s0,ffffffffc02028de <swap_init+0xb2>
ffffffffc02028f6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02028f8:	e55fe0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc02028fc:	5b351863          	bne	a0,s3,ffffffffc0202eac <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202900:	8626                	mv	a2,s1
ffffffffc0202902:	85ca                	mv	a1,s2
ffffffffc0202904:	00003517          	auipc	a0,0x3
ffffffffc0202908:	e9c50513          	addi	a0,a0,-356 # ffffffffc02057a0 <default_pmm_manager+0x738>
ffffffffc020290c:	fb2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202910:	357000ef          	jal	ra,ffffffffc0203466 <mm_create>
ffffffffc0202914:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202916:	50050b63          	beqz	a0,ffffffffc0202e2c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020291a:	0000f797          	auipc	a5,0xf
ffffffffc020291e:	c7e78793          	addi	a5,a5,-898 # ffffffffc0211598 <check_mm_struct>
ffffffffc0202922:	639c                	ld	a5,0(a5)
ffffffffc0202924:	52079463          	bnez	a5,ffffffffc0202e4c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202928:	0000f797          	auipc	a5,0xf
ffffffffc020292c:	b3078793          	addi	a5,a5,-1232 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202930:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202932:	0000f797          	auipc	a5,0xf
ffffffffc0202936:	c6a7b323          	sd	a0,-922(a5) # ffffffffc0211598 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020293a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020293c:	ec3a                	sd	a4,24(sp)
ffffffffc020293e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202940:	52079663          	bnez	a5,ffffffffc0202e6c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202944:	6599                	lui	a1,0x6
ffffffffc0202946:	460d                	li	a2,3
ffffffffc0202948:	6505                	lui	a0,0x1
ffffffffc020294a:	369000ef          	jal	ra,ffffffffc02034b2 <vma_create>
ffffffffc020294e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202950:	52050e63          	beqz	a0,ffffffffc0202e8c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202954:	855e                	mv	a0,s7
ffffffffc0202956:	3c9000ef          	jal	ra,ffffffffc020351e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020295a:	00003517          	auipc	a0,0x3
ffffffffc020295e:	eb650513          	addi	a0,a0,-330 # ffffffffc0205810 <default_pmm_manager+0x7a8>
ffffffffc0202962:	f5cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202966:	018bb503          	ld	a0,24(s7)
ffffffffc020296a:	4605                	li	a2,1
ffffffffc020296c:	6585                	lui	a1,0x1
ffffffffc020296e:	e1ffe0ef          	jal	ra,ffffffffc020178c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202972:	40050d63          	beqz	a0,ffffffffc0202d8c <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202976:	00003517          	auipc	a0,0x3
ffffffffc020297a:	eea50513          	addi	a0,a0,-278 # ffffffffc0205860 <default_pmm_manager+0x7f8>
ffffffffc020297e:	0000fa17          	auipc	s4,0xf
ffffffffc0202982:	b3aa0a13          	addi	s4,s4,-1222 # ffffffffc02114b8 <check_rp>
ffffffffc0202986:	f38fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020298a:	0000fa97          	auipc	s5,0xf
ffffffffc020298e:	b4ea8a93          	addi	s5,s5,-1202 # ffffffffc02114d8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202992:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202994:	4505                	li	a0,1
ffffffffc0202996:	ce9fe0ef          	jal	ra,ffffffffc020167e <alloc_pages>
ffffffffc020299a:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea60>
          assert(check_rp[i] != NULL );
ffffffffc020299e:	2a050b63          	beqz	a0,ffffffffc0202c54 <swap_init+0x428>
ffffffffc02029a2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029a4:	8b89                	andi	a5,a5,2
ffffffffc02029a6:	28079763          	bnez	a5,ffffffffc0202c34 <swap_init+0x408>
ffffffffc02029aa:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029ac:	ff5994e3          	bne	s3,s5,ffffffffc0202994 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029b0:	601c                	ld	a5,0(s0)
ffffffffc02029b2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029b6:	0000fd17          	auipc	s10,0xf
ffffffffc02029ba:	b02d0d13          	addi	s10,s10,-1278 # ffffffffc02114b8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029be:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029c0:	481c                	lw	a5,16(s0)
ffffffffc02029c2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029c4:	0000f797          	auipc	a5,0xf
ffffffffc02029c8:	ac87b223          	sd	s0,-1340(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc02029cc:	0000f797          	auipc	a5,0xf
ffffffffc02029d0:	aa87ba23          	sd	s0,-1356(a5) # ffffffffc0211480 <free_area>
     nr_free = 0;
ffffffffc02029d4:	0000f797          	auipc	a5,0xf
ffffffffc02029d8:	aa07ae23          	sw	zero,-1348(a5) # ffffffffc0211490 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02029dc:	000d3503          	ld	a0,0(s10)
ffffffffc02029e0:	4585                	li	a1,1
ffffffffc02029e2:	0d21                	addi	s10,s10,8
ffffffffc02029e4:	d23fe0ef          	jal	ra,ffffffffc0201706 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029e8:	ff5d1ae3          	bne	s10,s5,ffffffffc02029dc <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029ec:	01042d03          	lw	s10,16(s0)
ffffffffc02029f0:	4791                	li	a5,4
ffffffffc02029f2:	36fd1d63          	bne	s10,a5,ffffffffc0202d6c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02029f6:	00003517          	auipc	a0,0x3
ffffffffc02029fa:	ef250513          	addi	a0,a0,-270 # ffffffffc02058e8 <default_pmm_manager+0x880>
ffffffffc02029fe:	ec0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a02:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a04:	0000f797          	auipc	a5,0xf
ffffffffc0202a08:	a607a823          	sw	zero,-1424(a5) # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a0c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a0e:	0000f797          	auipc	a5,0xf
ffffffffc0202a12:	a6678793          	addi	a5,a5,-1434 # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a16:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a1a:	4398                	lw	a4,0(a5)
ffffffffc0202a1c:	4585                	li	a1,1
ffffffffc0202a1e:	2701                	sext.w	a4,a4
ffffffffc0202a20:	30b71663          	bne	a4,a1,ffffffffc0202d2c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a24:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a28:	4394                	lw	a3,0(a5)
ffffffffc0202a2a:	2681                	sext.w	a3,a3
ffffffffc0202a2c:	32e69063          	bne	a3,a4,ffffffffc0202d4c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a30:	6689                	lui	a3,0x2
ffffffffc0202a32:	462d                	li	a2,11
ffffffffc0202a34:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a38:	4398                	lw	a4,0(a5)
ffffffffc0202a3a:	4589                	li	a1,2
ffffffffc0202a3c:	2701                	sext.w	a4,a4
ffffffffc0202a3e:	26b71763          	bne	a4,a1,ffffffffc0202cac <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a42:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a46:	4394                	lw	a3,0(a5)
ffffffffc0202a48:	2681                	sext.w	a3,a3
ffffffffc0202a4a:	28e69163          	bne	a3,a4,ffffffffc0202ccc <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a4e:	668d                	lui	a3,0x3
ffffffffc0202a50:	4631                	li	a2,12
ffffffffc0202a52:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a56:	4398                	lw	a4,0(a5)
ffffffffc0202a58:	458d                	li	a1,3
ffffffffc0202a5a:	2701                	sext.w	a4,a4
ffffffffc0202a5c:	28b71863          	bne	a4,a1,ffffffffc0202cec <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a60:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a64:	4394                	lw	a3,0(a5)
ffffffffc0202a66:	2681                	sext.w	a3,a3
ffffffffc0202a68:	2ae69263          	bne	a3,a4,ffffffffc0202d0c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a6c:	6691                	lui	a3,0x4
ffffffffc0202a6e:	4635                	li	a2,13
ffffffffc0202a70:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a74:	4398                	lw	a4,0(a5)
ffffffffc0202a76:	2701                	sext.w	a4,a4
ffffffffc0202a78:	33a71a63          	bne	a4,s10,ffffffffc0202dac <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a7c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a80:	439c                	lw	a5,0(a5)
ffffffffc0202a82:	2781                	sext.w	a5,a5
ffffffffc0202a84:	34e79463          	bne	a5,a4,ffffffffc0202dcc <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a88:	481c                	lw	a5,16(s0)
ffffffffc0202a8a:	36079163          	bnez	a5,ffffffffc0202dec <swap_init+0x5c0>
ffffffffc0202a8e:	0000f797          	auipc	a5,0xf
ffffffffc0202a92:	a4a78793          	addi	a5,a5,-1462 # ffffffffc02114d8 <swap_in_seq_no>
ffffffffc0202a96:	0000f717          	auipc	a4,0xf
ffffffffc0202a9a:	a6a70713          	addi	a4,a4,-1430 # ffffffffc0211500 <swap_out_seq_no>
ffffffffc0202a9e:	0000f617          	auipc	a2,0xf
ffffffffc0202aa2:	a6260613          	addi	a2,a2,-1438 # ffffffffc0211500 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202aa6:	56fd                	li	a3,-1
ffffffffc0202aa8:	c394                	sw	a3,0(a5)
ffffffffc0202aaa:	c314                	sw	a3,0(a4)
ffffffffc0202aac:	0791                	addi	a5,a5,4
ffffffffc0202aae:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202ab0:	fec79ce3          	bne	a5,a2,ffffffffc0202aa8 <swap_init+0x27c>
ffffffffc0202ab4:	0000f697          	auipc	a3,0xf
ffffffffc0202ab8:	aac68693          	addi	a3,a3,-1364 # ffffffffc0211560 <check_ptep>
ffffffffc0202abc:	0000f817          	auipc	a6,0xf
ffffffffc0202ac0:	9fc80813          	addi	a6,a6,-1540 # ffffffffc02114b8 <check_rp>
ffffffffc0202ac4:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ac6:	0000fc97          	auipc	s9,0xf
ffffffffc0202aca:	99ac8c93          	addi	s9,s9,-1638 # ffffffffc0211460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ace:	0000fd97          	auipc	s11,0xf
ffffffffc0202ad2:	9e2d8d93          	addi	s11,s11,-1566 # ffffffffc02114b0 <pages>
ffffffffc0202ad6:	00003d17          	auipc	s10,0x3
ffffffffc0202ada:	66ad0d13          	addi	s10,s10,1642 # ffffffffc0206140 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ade:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202ae0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ae4:	4601                	li	a2,0
ffffffffc0202ae6:	85e2                	mv	a1,s8
ffffffffc0202ae8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202aea:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202aec:	ca1fe0ef          	jal	ra,ffffffffc020178c <get_pte>
ffffffffc0202af0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202af2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202af4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202af6:	16050f63          	beqz	a0,ffffffffc0202c74 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202afa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202afc:	0017f613          	andi	a2,a5,1
ffffffffc0202b00:	10060263          	beqz	a2,ffffffffc0202c04 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b04:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b08:	078a                	slli	a5,a5,0x2
ffffffffc0202b0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b0c:	10c7f863          	bleu	a2,a5,ffffffffc0202c1c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b10:	000d3603          	ld	a2,0(s10)
ffffffffc0202b14:	000db583          	ld	a1,0(s11)
ffffffffc0202b18:	00083503          	ld	a0,0(a6)
ffffffffc0202b1c:	8f91                	sub	a5,a5,a2
ffffffffc0202b1e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b22:	97b2                	add	a5,a5,a2
ffffffffc0202b24:	078e                	slli	a5,a5,0x3
ffffffffc0202b26:	97ae                	add	a5,a5,a1
ffffffffc0202b28:	0af51e63          	bne	a0,a5,ffffffffc0202be4 <swap_init+0x3b8>
ffffffffc0202b2c:	6785                	lui	a5,0x1
ffffffffc0202b2e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b30:	6795                	lui	a5,0x5
ffffffffc0202b32:	06a1                	addi	a3,a3,8
ffffffffc0202b34:	0821                	addi	a6,a6,8
ffffffffc0202b36:	fafc14e3          	bne	s8,a5,ffffffffc0202ade <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b3a:	00003517          	auipc	a0,0x3
ffffffffc0202b3e:	e5650513          	addi	a0,a0,-426 # ffffffffc0205990 <default_pmm_manager+0x928>
ffffffffc0202b42:	d7cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b46:	0000f797          	auipc	a5,0xf
ffffffffc0202b4a:	92278793          	addi	a5,a5,-1758 # ffffffffc0211468 <sm>
ffffffffc0202b4e:	639c                	ld	a5,0(a5)
ffffffffc0202b50:	7f9c                	ld	a5,56(a5)
ffffffffc0202b52:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b54:	2a051c63          	bnez	a0,ffffffffc0202e0c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b58:	000a3503          	ld	a0,0(s4)
ffffffffc0202b5c:	4585                	li	a1,1
ffffffffc0202b5e:	0a21                	addi	s4,s4,8
ffffffffc0202b60:	ba7fe0ef          	jal	ra,ffffffffc0201706 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b64:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b58 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b68:	855e                	mv	a0,s7
ffffffffc0202b6a:	283000ef          	jal	ra,ffffffffc02035ec <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b6e:	77a2                	ld	a5,40(sp)
ffffffffc0202b70:	0000f717          	auipc	a4,0xf
ffffffffc0202b74:	92f72023          	sw	a5,-1760(a4) # ffffffffc0211490 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b78:	7782                	ld	a5,32(sp)
ffffffffc0202b7a:	0000f717          	auipc	a4,0xf
ffffffffc0202b7e:	90f73323          	sd	a5,-1786(a4) # ffffffffc0211480 <free_area>
ffffffffc0202b82:	0000f797          	auipc	a5,0xf
ffffffffc0202b86:	9137b323          	sd	s3,-1786(a5) # ffffffffc0211488 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b8a:	00898a63          	beq	s3,s0,ffffffffc0202b9e <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b8e:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b92:	0089b983          	ld	s3,8(s3)
ffffffffc0202b96:	397d                	addiw	s2,s2,-1
ffffffffc0202b98:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b9a:	fe899ae3          	bne	s3,s0,ffffffffc0202b8e <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b9e:	8626                	mv	a2,s1
ffffffffc0202ba0:	85ca                	mv	a1,s2
ffffffffc0202ba2:	00003517          	auipc	a0,0x3
ffffffffc0202ba6:	e1e50513          	addi	a0,a0,-482 # ffffffffc02059c0 <default_pmm_manager+0x958>
ffffffffc0202baa:	d14fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bae:	00003517          	auipc	a0,0x3
ffffffffc0202bb2:	e3250513          	addi	a0,a0,-462 # ffffffffc02059e0 <default_pmm_manager+0x978>
ffffffffc0202bb6:	d08fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202bba:	b1c9                	j	ffffffffc020287c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bbc:	4481                	li	s1,0
ffffffffc0202bbe:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bc0:	4981                	li	s3,0
ffffffffc0202bc2:	bb1d                	j	ffffffffc02028f8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202bc4:	00002697          	auipc	a3,0x2
ffffffffc0202bc8:	0fc68693          	addi	a3,a3,252 # ffffffffc0204cc0 <commands+0x860>
ffffffffc0202bcc:	00002617          	auipc	a2,0x2
ffffffffc0202bd0:	10460613          	addi	a2,a2,260 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202bd4:	0be00593          	li	a1,190
ffffffffc0202bd8:	00003517          	auipc	a0,0x3
ffffffffc0202bdc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202be0:	f94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202be4:	00003697          	auipc	a3,0x3
ffffffffc0202be8:	d8468693          	addi	a3,a3,-636 # ffffffffc0205968 <default_pmm_manager+0x900>
ffffffffc0202bec:	00002617          	auipc	a2,0x2
ffffffffc0202bf0:	0e460613          	addi	a2,a2,228 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202bf4:	0fe00593          	li	a1,254
ffffffffc0202bf8:	00003517          	auipc	a0,0x3
ffffffffc0202bfc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202c00:	f74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c04:	00002617          	auipc	a2,0x2
ffffffffc0202c08:	72460613          	addi	a2,a2,1828 # ffffffffc0205328 <default_pmm_manager+0x2c0>
ffffffffc0202c0c:	07000593          	li	a1,112
ffffffffc0202c10:	00002517          	auipc	a0,0x2
ffffffffc0202c14:	54050513          	addi	a0,a0,1344 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0202c18:	f5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c1c:	00002617          	auipc	a2,0x2
ffffffffc0202c20:	51460613          	addi	a2,a2,1300 # ffffffffc0205130 <default_pmm_manager+0xc8>
ffffffffc0202c24:	06500593          	li	a1,101
ffffffffc0202c28:	00002517          	auipc	a0,0x2
ffffffffc0202c2c:	52850513          	addi	a0,a0,1320 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0202c30:	f44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c34:	00003697          	auipc	a3,0x3
ffffffffc0202c38:	c6c68693          	addi	a3,a3,-916 # ffffffffc02058a0 <default_pmm_manager+0x838>
ffffffffc0202c3c:	00002617          	auipc	a2,0x2
ffffffffc0202c40:	09460613          	addi	a2,a2,148 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202c44:	0df00593          	li	a1,223
ffffffffc0202c48:	00003517          	auipc	a0,0x3
ffffffffc0202c4c:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202c50:	f24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c54:	00003697          	auipc	a3,0x3
ffffffffc0202c58:	c3468693          	addi	a3,a3,-972 # ffffffffc0205888 <default_pmm_manager+0x820>
ffffffffc0202c5c:	00002617          	auipc	a2,0x2
ffffffffc0202c60:	07460613          	addi	a2,a2,116 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202c64:	0de00593          	li	a1,222
ffffffffc0202c68:	00003517          	auipc	a0,0x3
ffffffffc0202c6c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202c70:	f04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c74:	00003697          	auipc	a3,0x3
ffffffffc0202c78:	cdc68693          	addi	a3,a3,-804 # ffffffffc0205950 <default_pmm_manager+0x8e8>
ffffffffc0202c7c:	00002617          	auipc	a2,0x2
ffffffffc0202c80:	05460613          	addi	a2,a2,84 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202c84:	0fd00593          	li	a1,253
ffffffffc0202c88:	00003517          	auipc	a0,0x3
ffffffffc0202c8c:	af050513          	addi	a0,a0,-1296 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202c90:	ee4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c94:	00003617          	auipc	a2,0x3
ffffffffc0202c98:	ac460613          	addi	a2,a2,-1340 # ffffffffc0205758 <default_pmm_manager+0x6f0>
ffffffffc0202c9c:	02800593          	li	a1,40
ffffffffc0202ca0:	00003517          	auipc	a0,0x3
ffffffffc0202ca4:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202ca8:	eccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cac:	00003697          	auipc	a3,0x3
ffffffffc0202cb0:	c7468693          	addi	a3,a3,-908 # ffffffffc0205920 <default_pmm_manager+0x8b8>
ffffffffc0202cb4:	00002617          	auipc	a2,0x2
ffffffffc0202cb8:	01c60613          	addi	a2,a2,28 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202cbc:	09900593          	li	a1,153
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202cc8:	eacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ccc:	00003697          	auipc	a3,0x3
ffffffffc0202cd0:	c5468693          	addi	a3,a3,-940 # ffffffffc0205920 <default_pmm_manager+0x8b8>
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202cdc:	09b00593          	li	a1,155
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cec:	00003697          	auipc	a3,0x3
ffffffffc0202cf0:	c4468693          	addi	a3,a3,-956 # ffffffffc0205930 <default_pmm_manager+0x8c8>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202cfc:	09d00593          	li	a1,157
ffffffffc0202d00:	00003517          	auipc	a0,0x3
ffffffffc0202d04:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202d08:	e6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	c2468693          	addi	a3,a3,-988 # ffffffffc0205930 <default_pmm_manager+0x8c8>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202d1c:	09f00593          	li	a1,159
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	a5850513          	addi	a0,a0,-1448 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d2c:	00003697          	auipc	a3,0x3
ffffffffc0202d30:	be468693          	addi	a3,a3,-1052 # ffffffffc0205910 <default_pmm_manager+0x8a8>
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202d3c:	09500593          	li	a1,149
ffffffffc0202d40:	00003517          	auipc	a0,0x3
ffffffffc0202d44:	a3850513          	addi	a0,a0,-1480 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202d48:	e2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	bc468693          	addi	a3,a3,-1084 # ffffffffc0205910 <default_pmm_manager+0x8a8>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202d5c:	09700593          	li	a1,151
ffffffffc0202d60:	00003517          	auipc	a0,0x3
ffffffffc0202d64:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202d68:	e0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d6c:	00003697          	auipc	a3,0x3
ffffffffc0202d70:	b5468693          	addi	a3,a3,-1196 # ffffffffc02058c0 <default_pmm_manager+0x858>
ffffffffc0202d74:	00002617          	auipc	a2,0x2
ffffffffc0202d78:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202d7c:	0ec00593          	li	a1,236
ffffffffc0202d80:	00003517          	auipc	a0,0x3
ffffffffc0202d84:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202d88:	decfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d8c:	00003697          	auipc	a3,0x3
ffffffffc0202d90:	abc68693          	addi	a3,a3,-1348 # ffffffffc0205848 <default_pmm_manager+0x7e0>
ffffffffc0202d94:	00002617          	auipc	a2,0x2
ffffffffc0202d98:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202d9c:	0d900593          	li	a1,217
ffffffffc0202da0:	00003517          	auipc	a0,0x3
ffffffffc0202da4:	9d850513          	addi	a0,a0,-1576 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202da8:	dccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dac:	00003697          	auipc	a3,0x3
ffffffffc0202db0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205940 <default_pmm_manager+0x8d8>
ffffffffc0202db4:	00002617          	auipc	a2,0x2
ffffffffc0202db8:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202dbc:	0a100593          	li	a1,161
ffffffffc0202dc0:	00003517          	auipc	a0,0x3
ffffffffc0202dc4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202dc8:	dacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dcc:	00003697          	auipc	a3,0x3
ffffffffc0202dd0:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205940 <default_pmm_manager+0x8d8>
ffffffffc0202dd4:	00002617          	auipc	a2,0x2
ffffffffc0202dd8:	efc60613          	addi	a2,a2,-260 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202ddc:	0a300593          	li	a1,163
ffffffffc0202de0:	00003517          	auipc	a0,0x3
ffffffffc0202de4:	99850513          	addi	a0,a0,-1640 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202de8:	d8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202dec:	00002697          	auipc	a3,0x2
ffffffffc0202df0:	0bc68693          	addi	a3,a3,188 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc0202df4:	00002617          	auipc	a2,0x2
ffffffffc0202df8:	edc60613          	addi	a2,a2,-292 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202dfc:	0f500593          	li	a1,245
ffffffffc0202e00:	00003517          	auipc	a0,0x3
ffffffffc0202e04:	97850513          	addi	a0,a0,-1672 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202e08:	d6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202e0c:	00003697          	auipc	a3,0x3
ffffffffc0202e10:	bac68693          	addi	a3,a3,-1108 # ffffffffc02059b8 <default_pmm_manager+0x950>
ffffffffc0202e14:	00002617          	auipc	a2,0x2
ffffffffc0202e18:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202e1c:	10400593          	li	a1,260
ffffffffc0202e20:	00003517          	auipc	a0,0x3
ffffffffc0202e24:	95850513          	addi	a0,a0,-1704 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202e28:	d4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e2c:	00003697          	auipc	a3,0x3
ffffffffc0202e30:	99c68693          	addi	a3,a3,-1636 # ffffffffc02057c8 <default_pmm_manager+0x760>
ffffffffc0202e34:	00002617          	auipc	a2,0x2
ffffffffc0202e38:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202e3c:	0c600593          	li	a1,198
ffffffffc0202e40:	00003517          	auipc	a0,0x3
ffffffffc0202e44:	93850513          	addi	a0,a0,-1736 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202e48:	d2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e4c:	00003697          	auipc	a3,0x3
ffffffffc0202e50:	98c68693          	addi	a3,a3,-1652 # ffffffffc02057d8 <default_pmm_manager+0x770>
ffffffffc0202e54:	00002617          	auipc	a2,0x2
ffffffffc0202e58:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202e5c:	0c900593          	li	a1,201
ffffffffc0202e60:	00003517          	auipc	a0,0x3
ffffffffc0202e64:	91850513          	addi	a0,a0,-1768 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202e68:	d0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e6c:	00003697          	auipc	a3,0x3
ffffffffc0202e70:	98468693          	addi	a3,a3,-1660 # ffffffffc02057f0 <default_pmm_manager+0x788>
ffffffffc0202e74:	00002617          	auipc	a2,0x2
ffffffffc0202e78:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202e7c:	0ce00593          	li	a1,206
ffffffffc0202e80:	00003517          	auipc	a0,0x3
ffffffffc0202e84:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202e88:	cecfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e8c:	00003697          	auipc	a3,0x3
ffffffffc0202e90:	97468693          	addi	a3,a3,-1676 # ffffffffc0205800 <default_pmm_manager+0x798>
ffffffffc0202e94:	00002617          	auipc	a2,0x2
ffffffffc0202e98:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202e9c:	0d100593          	li	a1,209
ffffffffc0202ea0:	00003517          	auipc	a0,0x3
ffffffffc0202ea4:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202ea8:	cccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202eac:	00002697          	auipc	a3,0x2
ffffffffc0202eb0:	e5468693          	addi	a3,a3,-428 # ffffffffc0204d00 <commands+0x8a0>
ffffffffc0202eb4:	00002617          	auipc	a2,0x2
ffffffffc0202eb8:	e1c60613          	addi	a2,a2,-484 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202ebc:	0c100593          	li	a1,193
ffffffffc0202ec0:	00003517          	auipc	a0,0x3
ffffffffc0202ec4:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202ec8:	cacfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202ecc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202ecc:	0000e797          	auipc	a5,0xe
ffffffffc0202ed0:	59c78793          	addi	a5,a5,1436 # ffffffffc0211468 <sm>
ffffffffc0202ed4:	639c                	ld	a5,0(a5)
ffffffffc0202ed6:	0107b303          	ld	t1,16(a5)
ffffffffc0202eda:	8302                	jr	t1

ffffffffc0202edc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202edc:	0000e797          	auipc	a5,0xe
ffffffffc0202ee0:	58c78793          	addi	a5,a5,1420 # ffffffffc0211468 <sm>
ffffffffc0202ee4:	639c                	ld	a5,0(a5)
ffffffffc0202ee6:	0207b303          	ld	t1,32(a5)
ffffffffc0202eea:	8302                	jr	t1

ffffffffc0202eec <swap_out>:
{
ffffffffc0202eec:	711d                	addi	sp,sp,-96
ffffffffc0202eee:	ec86                	sd	ra,88(sp)
ffffffffc0202ef0:	e8a2                	sd	s0,80(sp)
ffffffffc0202ef2:	e4a6                	sd	s1,72(sp)
ffffffffc0202ef4:	e0ca                	sd	s2,64(sp)
ffffffffc0202ef6:	fc4e                	sd	s3,56(sp)
ffffffffc0202ef8:	f852                	sd	s4,48(sp)
ffffffffc0202efa:	f456                	sd	s5,40(sp)
ffffffffc0202efc:	f05a                	sd	s6,32(sp)
ffffffffc0202efe:	ec5e                	sd	s7,24(sp)
ffffffffc0202f00:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f02:	cde9                	beqz	a1,ffffffffc0202fdc <swap_out+0xf0>
ffffffffc0202f04:	8ab2                	mv	s5,a2
ffffffffc0202f06:	892a                	mv	s2,a0
ffffffffc0202f08:	8a2e                	mv	s4,a1
ffffffffc0202f0a:	4401                	li	s0,0
ffffffffc0202f0c:	0000e997          	auipc	s3,0xe
ffffffffc0202f10:	55c98993          	addi	s3,s3,1372 # ffffffffc0211468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f14:	00003b17          	auipc	s6,0x3
ffffffffc0202f18:	b4cb0b13          	addi	s6,s6,-1204 # ffffffffc0205a60 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f1c:	00003b97          	auipc	s7,0x3
ffffffffc0202f20:	b2cb8b93          	addi	s7,s7,-1236 # ffffffffc0205a48 <default_pmm_manager+0x9e0>
ffffffffc0202f24:	a825                	j	ffffffffc0202f5c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f26:	67a2                	ld	a5,8(sp)
ffffffffc0202f28:	8626                	mv	a2,s1
ffffffffc0202f2a:	85a2                	mv	a1,s0
ffffffffc0202f2c:	63b4                	ld	a3,64(a5)
ffffffffc0202f2e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f30:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f32:	82b1                	srli	a3,a3,0xc
ffffffffc0202f34:	0685                	addi	a3,a3,1
ffffffffc0202f36:	988fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f3a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f3c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f3e:	613c                	ld	a5,64(a0)
ffffffffc0202f40:	83b1                	srli	a5,a5,0xc
ffffffffc0202f42:	0785                	addi	a5,a5,1
ffffffffc0202f44:	07a2                	slli	a5,a5,0x8
ffffffffc0202f46:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f4a:	fbcfe0ef          	jal	ra,ffffffffc0201706 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f4e:	01893503          	ld	a0,24(s2)
ffffffffc0202f52:	85a6                	mv	a1,s1
ffffffffc0202f54:	ebeff0ef          	jal	ra,ffffffffc0202612 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f58:	048a0d63          	beq	s4,s0,ffffffffc0202fb2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f5c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f60:	8656                	mv	a2,s5
ffffffffc0202f62:	002c                	addi	a1,sp,8
ffffffffc0202f64:	7b9c                	ld	a5,48(a5)
ffffffffc0202f66:	854a                	mv	a0,s2
ffffffffc0202f68:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f6a:	e12d                	bnez	a0,ffffffffc0202fcc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f6c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f6e:	01893503          	ld	a0,24(s2)
ffffffffc0202f72:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f74:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f76:	85a6                	mv	a1,s1
ffffffffc0202f78:	815fe0ef          	jal	ra,ffffffffc020178c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f7c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f7e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f80:	8b85                	andi	a5,a5,1
ffffffffc0202f82:	cfb9                	beqz	a5,ffffffffc0202fe0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f84:	65a2                	ld	a1,8(sp)
ffffffffc0202f86:	61bc                	ld	a5,64(a1)
ffffffffc0202f88:	83b1                	srli	a5,a5,0xc
ffffffffc0202f8a:	00178513          	addi	a0,a5,1
ffffffffc0202f8e:	0522                	slli	a0,a0,0x8
ffffffffc0202f90:	583000ef          	jal	ra,ffffffffc0203d12 <swapfs_write>
ffffffffc0202f94:	d949                	beqz	a0,ffffffffc0202f26 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f96:	855e                	mv	a0,s7
ffffffffc0202f98:	926fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f9c:	0009b783          	ld	a5,0(s3)
ffffffffc0202fa0:	6622                	ld	a2,8(sp)
ffffffffc0202fa2:	4681                	li	a3,0
ffffffffc0202fa4:	739c                	ld	a5,32(a5)
ffffffffc0202fa6:	85a6                	mv	a1,s1
ffffffffc0202fa8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202faa:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fac:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202fae:	fa8a17e3          	bne	s4,s0,ffffffffc0202f5c <swap_out+0x70>
}
ffffffffc0202fb2:	8522                	mv	a0,s0
ffffffffc0202fb4:	60e6                	ld	ra,88(sp)
ffffffffc0202fb6:	6446                	ld	s0,80(sp)
ffffffffc0202fb8:	64a6                	ld	s1,72(sp)
ffffffffc0202fba:	6906                	ld	s2,64(sp)
ffffffffc0202fbc:	79e2                	ld	s3,56(sp)
ffffffffc0202fbe:	7a42                	ld	s4,48(sp)
ffffffffc0202fc0:	7aa2                	ld	s5,40(sp)
ffffffffc0202fc2:	7b02                	ld	s6,32(sp)
ffffffffc0202fc4:	6be2                	ld	s7,24(sp)
ffffffffc0202fc6:	6c42                	ld	s8,16(sp)
ffffffffc0202fc8:	6125                	addi	sp,sp,96
ffffffffc0202fca:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202fcc:	85a2                	mv	a1,s0
ffffffffc0202fce:	00003517          	auipc	a0,0x3
ffffffffc0202fd2:	a3250513          	addi	a0,a0,-1486 # ffffffffc0205a00 <default_pmm_manager+0x998>
ffffffffc0202fd6:	8e8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202fda:	bfe1                	j	ffffffffc0202fb2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202fdc:	4401                	li	s0,0
ffffffffc0202fde:	bfd1                	j	ffffffffc0202fb2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fe0:	00003697          	auipc	a3,0x3
ffffffffc0202fe4:	a5068693          	addi	a3,a3,-1456 # ffffffffc0205a30 <default_pmm_manager+0x9c8>
ffffffffc0202fe8:	00002617          	auipc	a2,0x2
ffffffffc0202fec:	ce860613          	addi	a2,a2,-792 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0202ff0:	06a00593          	li	a1,106
ffffffffc0202ff4:	00002517          	auipc	a0,0x2
ffffffffc0202ff8:	78450513          	addi	a0,a0,1924 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0202ffc:	b78fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203000 <swap_in>:
{
ffffffffc0203000:	7179                	addi	sp,sp,-48
ffffffffc0203002:	e84a                	sd	s2,16(sp)
ffffffffc0203004:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203006:	4505                	li	a0,1
{
ffffffffc0203008:	ec26                	sd	s1,24(sp)
ffffffffc020300a:	e44e                	sd	s3,8(sp)
ffffffffc020300c:	f406                	sd	ra,40(sp)
ffffffffc020300e:	f022                	sd	s0,32(sp)
ffffffffc0203010:	84ae                	mv	s1,a1
ffffffffc0203012:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203014:	e6afe0ef          	jal	ra,ffffffffc020167e <alloc_pages>
     assert(result!=NULL);
ffffffffc0203018:	c129                	beqz	a0,ffffffffc020305a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020301a:	842a                	mv	s0,a0
ffffffffc020301c:	01893503          	ld	a0,24(s2)
ffffffffc0203020:	4601                	li	a2,0
ffffffffc0203022:	85a6                	mv	a1,s1
ffffffffc0203024:	f68fe0ef          	jal	ra,ffffffffc020178c <get_pte>
ffffffffc0203028:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020302a:	6108                	ld	a0,0(a0)
ffffffffc020302c:	85a2                	mv	a1,s0
ffffffffc020302e:	43f000ef          	jal	ra,ffffffffc0203c6c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203032:	00093583          	ld	a1,0(s2)
ffffffffc0203036:	8626                	mv	a2,s1
ffffffffc0203038:	00002517          	auipc	a0,0x2
ffffffffc020303c:	6e050513          	addi	a0,a0,1760 # ffffffffc0205718 <default_pmm_manager+0x6b0>
ffffffffc0203040:	81a1                	srli	a1,a1,0x8
ffffffffc0203042:	87cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203046:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203048:	0089b023          	sd	s0,0(s3)
}
ffffffffc020304c:	7402                	ld	s0,32(sp)
ffffffffc020304e:	64e2                	ld	s1,24(sp)
ffffffffc0203050:	6942                	ld	s2,16(sp)
ffffffffc0203052:	69a2                	ld	s3,8(sp)
ffffffffc0203054:	4501                	li	a0,0
ffffffffc0203056:	6145                	addi	sp,sp,48
ffffffffc0203058:	8082                	ret
     assert(result!=NULL);
ffffffffc020305a:	00002697          	auipc	a3,0x2
ffffffffc020305e:	6ae68693          	addi	a3,a3,1710 # ffffffffc0205708 <default_pmm_manager+0x6a0>
ffffffffc0203062:	00002617          	auipc	a2,0x2
ffffffffc0203066:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020306a:	08000593          	li	a1,128
ffffffffc020306e:	00002517          	auipc	a0,0x2
ffffffffc0203072:	70a50513          	addi	a0,a0,1802 # ffffffffc0205778 <default_pmm_manager+0x710>
ffffffffc0203076:	afefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020307a <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc020307a:	4501                	li	a0,0
ffffffffc020307c:	8082                	ret

ffffffffc020307e <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020307e:	4501                	li	a0,0
ffffffffc0203080:	8082                	ret

ffffffffc0203082 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203082:	4501                	li	a0,0
ffffffffc0203084:	8082                	ret

ffffffffc0203086 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0203086:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203088:	678d                	lui	a5,0x3
ffffffffc020308a:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc020308c:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020308e:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203092:	0000e797          	auipc	a5,0xe
ffffffffc0203096:	3e278793          	addi	a5,a5,994 # ffffffffc0211474 <pgfault_num>
ffffffffc020309a:	4398                	lw	a4,0(a5)
ffffffffc020309c:	4691                	li	a3,4
ffffffffc020309e:	2701                	sext.w	a4,a4
ffffffffc02030a0:	08d71f63          	bne	a4,a3,ffffffffc020313e <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030a4:	6685                	lui	a3,0x1
ffffffffc02030a6:	4629                	li	a2,10
ffffffffc02030a8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030ac:	4394                	lw	a3,0(a5)
ffffffffc02030ae:	2681                	sext.w	a3,a3
ffffffffc02030b0:	20e69763          	bne	a3,a4,ffffffffc02032be <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030b4:	6711                	lui	a4,0x4
ffffffffc02030b6:	4635                	li	a2,13
ffffffffc02030b8:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02030bc:	4398                	lw	a4,0(a5)
ffffffffc02030be:	2701                	sext.w	a4,a4
ffffffffc02030c0:	1cd71f63          	bne	a4,a3,ffffffffc020329e <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030c4:	6689                	lui	a3,0x2
ffffffffc02030c6:	462d                	li	a2,11
ffffffffc02030c8:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02030cc:	4394                	lw	a3,0(a5)
ffffffffc02030ce:	2681                	sext.w	a3,a3
ffffffffc02030d0:	1ae69763          	bne	a3,a4,ffffffffc020327e <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030d4:	6715                	lui	a4,0x5
ffffffffc02030d6:	46b9                	li	a3,14
ffffffffc02030d8:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030dc:	4398                	lw	a4,0(a5)
ffffffffc02030de:	4695                	li	a3,5
ffffffffc02030e0:	2701                	sext.w	a4,a4
ffffffffc02030e2:	16d71e63          	bne	a4,a3,ffffffffc020325e <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc02030e6:	4394                	lw	a3,0(a5)
ffffffffc02030e8:	2681                	sext.w	a3,a3
ffffffffc02030ea:	14e69a63          	bne	a3,a4,ffffffffc020323e <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc02030ee:	4398                	lw	a4,0(a5)
ffffffffc02030f0:	2701                	sext.w	a4,a4
ffffffffc02030f2:	12d71663          	bne	a4,a3,ffffffffc020321e <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc02030f6:	4394                	lw	a3,0(a5)
ffffffffc02030f8:	2681                	sext.w	a3,a3
ffffffffc02030fa:	10e69263          	bne	a3,a4,ffffffffc02031fe <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc02030fe:	4398                	lw	a4,0(a5)
ffffffffc0203100:	2701                	sext.w	a4,a4
ffffffffc0203102:	0cd71e63          	bne	a4,a3,ffffffffc02031de <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203106:	4394                	lw	a3,0(a5)
ffffffffc0203108:	2681                	sext.w	a3,a3
ffffffffc020310a:	0ae69a63          	bne	a3,a4,ffffffffc02031be <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020310e:	6715                	lui	a4,0x5
ffffffffc0203110:	46b9                	li	a3,14
ffffffffc0203112:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203116:	4398                	lw	a4,0(a5)
ffffffffc0203118:	4695                	li	a3,5
ffffffffc020311a:	2701                	sext.w	a4,a4
ffffffffc020311c:	08d71163          	bne	a4,a3,ffffffffc020319e <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203120:	6705                	lui	a4,0x1
ffffffffc0203122:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203126:	4729                	li	a4,10
ffffffffc0203128:	04e69b63          	bne	a3,a4,ffffffffc020317e <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020312c:	439c                	lw	a5,0(a5)
ffffffffc020312e:	4719                	li	a4,6
ffffffffc0203130:	2781                	sext.w	a5,a5
ffffffffc0203132:	02e79663          	bne	a5,a4,ffffffffc020315e <_clock_check_swap+0xd8>
}
ffffffffc0203136:	60a2                	ld	ra,8(sp)
ffffffffc0203138:	4501                	li	a0,0
ffffffffc020313a:	0141                	addi	sp,sp,16
ffffffffc020313c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020313e:	00003697          	auipc	a3,0x3
ffffffffc0203142:	80268693          	addi	a3,a3,-2046 # ffffffffc0205940 <default_pmm_manager+0x8d8>
ffffffffc0203146:	00002617          	auipc	a2,0x2
ffffffffc020314a:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020314e:	0a500593          	li	a1,165
ffffffffc0203152:	00003517          	auipc	a0,0x3
ffffffffc0203156:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020315a:	a1afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc020315e:	00003697          	auipc	a3,0x3
ffffffffc0203162:	99268693          	addi	a3,a3,-1646 # ffffffffc0205af0 <default_pmm_manager+0xa88>
ffffffffc0203166:	00002617          	auipc	a2,0x2
ffffffffc020316a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020316e:	0bc00593          	li	a1,188
ffffffffc0203172:	00003517          	auipc	a0,0x3
ffffffffc0203176:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020317a:	9fafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020317e:	00003697          	auipc	a3,0x3
ffffffffc0203182:	94a68693          	addi	a3,a3,-1718 # ffffffffc0205ac8 <default_pmm_manager+0xa60>
ffffffffc0203186:	00002617          	auipc	a2,0x2
ffffffffc020318a:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020318e:	0ba00593          	li	a1,186
ffffffffc0203192:	00003517          	auipc	a0,0x3
ffffffffc0203196:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020319a:	9dafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020319e:	00003697          	auipc	a3,0x3
ffffffffc02031a2:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc02031a6:	00002617          	auipc	a2,0x2
ffffffffc02031aa:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02031ae:	0b900593          	li	a1,185
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc02031ba:	9bafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031be:	00003697          	auipc	a3,0x3
ffffffffc02031c2:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc02031c6:	00002617          	auipc	a2,0x2
ffffffffc02031ca:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02031ce:	0b700593          	li	a1,183
ffffffffc02031d2:	00003517          	auipc	a0,0x3
ffffffffc02031d6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc02031da:	99afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031de:	00003697          	auipc	a3,0x3
ffffffffc02031e2:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc02031e6:	00002617          	auipc	a2,0x2
ffffffffc02031ea:	aea60613          	addi	a2,a2,-1302 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02031ee:	0b500593          	li	a1,181
ffffffffc02031f2:	00003517          	auipc	a0,0x3
ffffffffc02031f6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc02031fa:	97afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031fe:	00003697          	auipc	a3,0x3
ffffffffc0203202:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc0203206:	00002617          	auipc	a2,0x2
ffffffffc020320a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020320e:	0b300593          	li	a1,179
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	88e50513          	addi	a0,a0,-1906 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020321a:	95afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020321e:	00003697          	auipc	a3,0x3
ffffffffc0203222:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc0203226:	00002617          	auipc	a2,0x2
ffffffffc020322a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020322e:	0b100593          	li	a1,177
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	86e50513          	addi	a0,a0,-1938 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020323a:	93afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020323e:	00003697          	auipc	a3,0x3
ffffffffc0203242:	87a68693          	addi	a3,a3,-1926 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020324e:	0af00593          	li	a1,175
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	84e50513          	addi	a0,a0,-1970 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020325a:	91afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020325e:	00003697          	auipc	a3,0x3
ffffffffc0203262:	85a68693          	addi	a3,a3,-1958 # ffffffffc0205ab8 <default_pmm_manager+0xa50>
ffffffffc0203266:	00002617          	auipc	a2,0x2
ffffffffc020326a:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020326e:	0ad00593          	li	a1,173
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020327a:	8fafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc020327e:	00002697          	auipc	a3,0x2
ffffffffc0203282:	6c268693          	addi	a3,a3,1730 # ffffffffc0205940 <default_pmm_manager+0x8d8>
ffffffffc0203286:	00002617          	auipc	a2,0x2
ffffffffc020328a:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020328e:	0ab00593          	li	a1,171
ffffffffc0203292:	00003517          	auipc	a0,0x3
ffffffffc0203296:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020329a:	8dafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc020329e:	00002697          	auipc	a3,0x2
ffffffffc02032a2:	6a268693          	addi	a3,a3,1698 # ffffffffc0205940 <default_pmm_manager+0x8d8>
ffffffffc02032a6:	00002617          	auipc	a2,0x2
ffffffffc02032aa:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02032ae:	0a900593          	li	a1,169
ffffffffc02032b2:	00002517          	auipc	a0,0x2
ffffffffc02032b6:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc02032ba:	8bafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032be:	00002697          	auipc	a3,0x2
ffffffffc02032c2:	68268693          	addi	a3,a3,1666 # ffffffffc0205940 <default_pmm_manager+0x8d8>
ffffffffc02032c6:	00002617          	auipc	a2,0x2
ffffffffc02032ca:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02032ce:	0a700593          	li	a1,167
ffffffffc02032d2:	00002517          	auipc	a0,0x2
ffffffffc02032d6:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc02032da:	89afd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032de <_clock_init_mm>:
{     
ffffffffc02032de:	1141                	addi	sp,sp,-16
ffffffffc02032e0:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02032e2:	0000e797          	auipc	a5,0xe
ffffffffc02032e6:	29e78793          	addi	a5,a5,670 # ffffffffc0211580 <pra_list_head>
    mm->sm_priv = &pra_list_head;
ffffffffc02032ea:	f51c                	sd	a5,40(a0)
    cprintf("curr_ptr 0xffffffff%x\n", curr_ptr);
ffffffffc02032ec:	85be                	mv	a1,a5
ffffffffc02032ee:	00003517          	auipc	a0,0x3
ffffffffc02032f2:	81250513          	addi	a0,a0,-2030 # ffffffffc0205b00 <default_pmm_manager+0xa98>
ffffffffc02032f6:	e79c                	sd	a5,8(a5)
ffffffffc02032f8:	e39c                	sd	a5,0(a5)
    curr_ptr = &pra_list_head;
ffffffffc02032fa:	0000e717          	auipc	a4,0xe
ffffffffc02032fe:	28f73b23          	sd	a5,662(a4) # ffffffffc0211590 <curr_ptr>
    cprintf("curr_ptr 0xffffffff%x\n", curr_ptr);
ffffffffc0203302:	dbdfc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203306:	60a2                	ld	ra,8(sp)
ffffffffc0203308:	4501                	li	a0,0
ffffffffc020330a:	0141                	addi	sp,sp,16
ffffffffc020330c:	8082                	ret

ffffffffc020330e <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020330e:	03060793          	addi	a5,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203312:	c79d                	beqz	a5,ffffffffc0203340 <_clock_map_swappable+0x32>
ffffffffc0203314:	0000e717          	auipc	a4,0xe
ffffffffc0203318:	27c70713          	addi	a4,a4,636 # ffffffffc0211590 <curr_ptr>
ffffffffc020331c:	6318                	ld	a4,0(a4)
ffffffffc020331e:	c30d                	beqz	a4,ffffffffc0203340 <_clock_map_swappable+0x32>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203320:	0000e697          	auipc	a3,0xe
ffffffffc0203324:	26068693          	addi	a3,a3,608 # ffffffffc0211580 <pra_list_head>
ffffffffc0203328:	6298                	ld	a4,0(a3)
    prev->next = next->prev = elm;
ffffffffc020332a:	0000e597          	auipc	a1,0xe
ffffffffc020332e:	24f5bb23          	sd	a5,598(a1) # ffffffffc0211580 <pra_list_head>
}
ffffffffc0203332:	4501                	li	a0,0
ffffffffc0203334:	e71c                	sd	a5,8(a4)
    page->visited = 1;
ffffffffc0203336:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203338:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc020333a:	fa18                	sd	a4,48(a2)
ffffffffc020333c:	ea1c                	sd	a5,16(a2)
}
ffffffffc020333e:	8082                	ret
{
ffffffffc0203340:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203342:	00002697          	auipc	a3,0x2
ffffffffc0203346:	7d668693          	addi	a3,a3,2006 # ffffffffc0205b18 <default_pmm_manager+0xab0>
ffffffffc020334a:	00002617          	auipc	a2,0x2
ffffffffc020334e:	98660613          	addi	a2,a2,-1658 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203352:	04000593          	li	a1,64
ffffffffc0203356:	00002517          	auipc	a0,0x2
ffffffffc020335a:	74a50513          	addi	a0,a0,1866 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
{
ffffffffc020335e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203360:	814fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203364 <_clock_swap_out_victim>:
{
ffffffffc0203364:	7179                	addi	sp,sp,-48
ffffffffc0203366:	e44e                	sd	s3,8(sp)
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203368:	02853983          	ld	s3,40(a0)
{
ffffffffc020336c:	f406                	sd	ra,40(sp)
ffffffffc020336e:	f022                	sd	s0,32(sp)
ffffffffc0203370:	ec26                	sd	s1,24(sp)
ffffffffc0203372:	e84a                	sd	s2,16(sp)
ffffffffc0203374:	e052                	sd	s4,0(sp)
         assert(head != NULL);
ffffffffc0203376:	08098663          	beqz	s3,ffffffffc0203402 <_clock_swap_out_victim+0x9e>
ffffffffc020337a:	8a2e                	mv	s4,a1
     assert(in_tick==0);
ffffffffc020337c:	0000e917          	auipc	s2,0xe
ffffffffc0203380:	21490913          	addi	s2,s2,532 # ffffffffc0211590 <curr_ptr>
            cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc0203384:	00002497          	auipc	s1,0x2
ffffffffc0203388:	7dc48493          	addi	s1,s1,2012 # ffffffffc0205b60 <default_pmm_manager+0xaf8>
     assert(in_tick==0);
ffffffffc020338c:	ce19                	beqz	a2,ffffffffc02033aa <_clock_swap_out_victim+0x46>
ffffffffc020338e:	a851                	j	ffffffffc0203422 <_clock_swap_out_victim+0xbe>
        cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc0203390:	85be                	mv	a1,a5
ffffffffc0203392:	8526                	mv	a0,s1
        curr_ptr = list_next(curr_ptr);
ffffffffc0203394:	0000e717          	auipc	a4,0xe
ffffffffc0203398:	1ef73e23          	sd	a5,508(a4) # ffffffffc0211590 <curr_ptr>
        cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc020339c:	d23fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        if (page->visited == 0) {
ffffffffc02033a0:	fe043783          	ld	a5,-32(s0)
ffffffffc02033a4:	cf95                	beqz	a5,ffffffffc02033e0 <_clock_swap_out_victim+0x7c>
            page->visited = 0;
ffffffffc02033a6:	fe043023          	sd	zero,-32(s0)
        if (curr_ptr == head) {
ffffffffc02033aa:	00093403          	ld	s0,0(s2)
ffffffffc02033ae:	641c                	ld	a5,8(s0)
ffffffffc02033b0:	ff3410e3          	bne	s0,s3,ffffffffc0203390 <_clock_swap_out_victim+0x2c>
            cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc02033b4:	85be                	mv	a1,a5
ffffffffc02033b6:	8526                	mv	a0,s1
            curr_ptr = list_next(curr_ptr);
ffffffffc02033b8:	0000e717          	auipc	a4,0xe
ffffffffc02033bc:	1cf73c23          	sd	a5,472(a4) # ffffffffc0211590 <curr_ptr>
            cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc02033c0:	cfffc0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02033c4:	00093403          	ld	s0,0(s2)
        cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc02033c8:	8526                	mv	a0,s1
ffffffffc02033ca:	641c                	ld	a5,8(s0)
ffffffffc02033cc:	85be                	mv	a1,a5
        curr_ptr = list_next(curr_ptr);
ffffffffc02033ce:	0000e717          	auipc	a4,0xe
ffffffffc02033d2:	1cf73123          	sd	a5,450(a4) # ffffffffc0211590 <curr_ptr>
        cprintf("curr_ptr %p\n", (void*)curr_ptr);
ffffffffc02033d6:	ce9fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        if (page->visited == 0) {
ffffffffc02033da:	fe043783          	ld	a5,-32(s0)
ffffffffc02033de:	f7e1                	bnez	a5,ffffffffc02033a6 <_clock_swap_out_victim+0x42>
    __list_del(listelm->prev, listelm->next);
ffffffffc02033e0:	6018                	ld	a4,0(s0)
ffffffffc02033e2:	641c                	ld	a5,8(s0)
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc02033e4:	fd040413          	addi	s0,s0,-48
}
ffffffffc02033e8:	70a2                	ld	ra,40(sp)
    prev->next = next;
ffffffffc02033ea:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033ec:	e398                	sd	a4,0(a5)
            *ptr_page = page;
ffffffffc02033ee:	008a3023          	sd	s0,0(s4)
}
ffffffffc02033f2:	7402                	ld	s0,32(sp)
ffffffffc02033f4:	64e2                	ld	s1,24(sp)
ffffffffc02033f6:	6942                	ld	s2,16(sp)
ffffffffc02033f8:	69a2                	ld	s3,8(sp)
ffffffffc02033fa:	6a02                	ld	s4,0(sp)
ffffffffc02033fc:	4501                	li	a0,0
ffffffffc02033fe:	6145                	addi	sp,sp,48
ffffffffc0203400:	8082                	ret
         assert(head != NULL);
ffffffffc0203402:	00002697          	auipc	a3,0x2
ffffffffc0203406:	73e68693          	addi	a3,a3,1854 # ffffffffc0205b40 <default_pmm_manager+0xad8>
ffffffffc020340a:	00002617          	auipc	a2,0x2
ffffffffc020340e:	8c660613          	addi	a2,a2,-1850 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203412:	05700593          	li	a1,87
ffffffffc0203416:	00002517          	auipc	a0,0x2
ffffffffc020341a:	68a50513          	addi	a0,a0,1674 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020341e:	f57fc0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(in_tick==0);
ffffffffc0203422:	00002697          	auipc	a3,0x2
ffffffffc0203426:	72e68693          	addi	a3,a3,1838 # ffffffffc0205b50 <default_pmm_manager+0xae8>
ffffffffc020342a:	00002617          	auipc	a2,0x2
ffffffffc020342e:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203432:	05800593          	li	a1,88
ffffffffc0203436:	00002517          	auipc	a0,0x2
ffffffffc020343a:	66a50513          	addi	a0,a0,1642 # ffffffffc0205aa0 <default_pmm_manager+0xa38>
ffffffffc020343e:	f37fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203442 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203442:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203444:	00002697          	auipc	a3,0x2
ffffffffc0203448:	74468693          	addi	a3,a3,1860 # ffffffffc0205b88 <default_pmm_manager+0xb20>
ffffffffc020344c:	00002617          	auipc	a2,0x2
ffffffffc0203450:	88460613          	addi	a2,a2,-1916 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203454:	07d00593          	li	a1,125
ffffffffc0203458:	00002517          	auipc	a0,0x2
ffffffffc020345c:	75050513          	addi	a0,a0,1872 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203460:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203462:	f13fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203466 <mm_create>:
mm_create(void) {
ffffffffc0203466:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203468:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020346c:	e022                	sd	s0,0(sp)
ffffffffc020346e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203470:	a3aff0ef          	jal	ra,ffffffffc02026aa <kmalloc>
ffffffffc0203474:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203476:	c115                	beqz	a0,ffffffffc020349a <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203478:	0000e797          	auipc	a5,0xe
ffffffffc020347c:	ff878793          	addi	a5,a5,-8 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203480:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0203482:	e408                	sd	a0,8(s0)
ffffffffc0203484:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203486:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020348a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020348e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203492:	2781                	sext.w	a5,a5
ffffffffc0203494:	eb81                	bnez	a5,ffffffffc02034a4 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0203496:	02053423          	sd	zero,40(a0)
}
ffffffffc020349a:	8522                	mv	a0,s0
ffffffffc020349c:	60a2                	ld	ra,8(sp)
ffffffffc020349e:	6402                	ld	s0,0(sp)
ffffffffc02034a0:	0141                	addi	sp,sp,16
ffffffffc02034a2:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034a4:	a29ff0ef          	jal	ra,ffffffffc0202ecc <swap_init_mm>
}
ffffffffc02034a8:	8522                	mv	a0,s0
ffffffffc02034aa:	60a2                	ld	ra,8(sp)
ffffffffc02034ac:	6402                	ld	s0,0(sp)
ffffffffc02034ae:	0141                	addi	sp,sp,16
ffffffffc02034b0:	8082                	ret

ffffffffc02034b2 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034b2:	1101                	addi	sp,sp,-32
ffffffffc02034b4:	e04a                	sd	s2,0(sp)
ffffffffc02034b6:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034b8:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034bc:	e822                	sd	s0,16(sp)
ffffffffc02034be:	e426                	sd	s1,8(sp)
ffffffffc02034c0:	ec06                	sd	ra,24(sp)
ffffffffc02034c2:	84ae                	mv	s1,a1
ffffffffc02034c4:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034c6:	9e4ff0ef          	jal	ra,ffffffffc02026aa <kmalloc>
    if (vma != NULL) {
ffffffffc02034ca:	c509                	beqz	a0,ffffffffc02034d4 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02034cc:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034d0:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034d2:	ed00                	sd	s0,24(a0)
}
ffffffffc02034d4:	60e2                	ld	ra,24(sp)
ffffffffc02034d6:	6442                	ld	s0,16(sp)
ffffffffc02034d8:	64a2                	ld	s1,8(sp)
ffffffffc02034da:	6902                	ld	s2,0(sp)
ffffffffc02034dc:	6105                	addi	sp,sp,32
ffffffffc02034de:	8082                	ret

ffffffffc02034e0 <find_vma>:
    if (mm != NULL) {
ffffffffc02034e0:	c51d                	beqz	a0,ffffffffc020350e <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034e2:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034e4:	c781                	beqz	a5,ffffffffc02034ec <find_vma+0xc>
ffffffffc02034e6:	6798                	ld	a4,8(a5)
ffffffffc02034e8:	02e5f663          	bleu	a4,a1,ffffffffc0203514 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02034ec:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02034ee:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02034f0:	00f50f63          	beq	a0,a5,ffffffffc020350e <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02034f4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02034f8:	fee5ebe3          	bltu	a1,a4,ffffffffc02034ee <find_vma+0xe>
ffffffffc02034fc:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203500:	fee5f7e3          	bleu	a4,a1,ffffffffc02034ee <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203504:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203506:	c781                	beqz	a5,ffffffffc020350e <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203508:	e91c                	sd	a5,16(a0)
}
ffffffffc020350a:	853e                	mv	a0,a5
ffffffffc020350c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020350e:	4781                	li	a5,0
}
ffffffffc0203510:	853e                	mv	a0,a5
ffffffffc0203512:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203514:	6b98                	ld	a4,16(a5)
ffffffffc0203516:	fce5fbe3          	bleu	a4,a1,ffffffffc02034ec <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020351a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020351c:	b7fd                	j	ffffffffc020350a <find_vma+0x2a>

ffffffffc020351e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020351e:	6590                	ld	a2,8(a1)
ffffffffc0203520:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203524:	1141                	addi	sp,sp,-16
ffffffffc0203526:	e406                	sd	ra,8(sp)
ffffffffc0203528:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020352a:	01066863          	bltu	a2,a6,ffffffffc020353a <insert_vma_struct+0x1c>
ffffffffc020352e:	a8b9                	j	ffffffffc020358c <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203530:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203534:	04d66763          	bltu	a2,a3,ffffffffc0203582 <insert_vma_struct+0x64>
ffffffffc0203538:	873e                	mv	a4,a5
ffffffffc020353a:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020353c:	fef51ae3          	bne	a0,a5,ffffffffc0203530 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203540:	02a70463          	beq	a4,a0,ffffffffc0203568 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203544:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203548:	fe873883          	ld	a7,-24(a4)
ffffffffc020354c:	08d8f063          	bleu	a3,a7,ffffffffc02035cc <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203550:	04d66e63          	bltu	a2,a3,ffffffffc02035ac <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203554:	00f50a63          	beq	a0,a5,ffffffffc0203568 <insert_vma_struct+0x4a>
ffffffffc0203558:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020355c:	0506e863          	bltu	a3,a6,ffffffffc02035ac <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203560:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203564:	02c6f263          	bleu	a2,a3,ffffffffc0203588 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203568:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020356a:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020356c:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203570:	e390                	sd	a2,0(a5)
ffffffffc0203572:	e710                	sd	a2,8(a4)
}
ffffffffc0203574:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203576:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203578:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020357a:	2685                	addiw	a3,a3,1
ffffffffc020357c:	d114                	sw	a3,32(a0)
}
ffffffffc020357e:	0141                	addi	sp,sp,16
ffffffffc0203580:	8082                	ret
    if (le_prev != list) {
ffffffffc0203582:	fca711e3          	bne	a4,a0,ffffffffc0203544 <insert_vma_struct+0x26>
ffffffffc0203586:	bfd9                	j	ffffffffc020355c <insert_vma_struct+0x3e>
ffffffffc0203588:	ebbff0ef          	jal	ra,ffffffffc0203442 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020358c:	00002697          	auipc	a3,0x2
ffffffffc0203590:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205c38 <default_pmm_manager+0xbd0>
ffffffffc0203594:	00001617          	auipc	a2,0x1
ffffffffc0203598:	73c60613          	addi	a2,a2,1852 # ffffffffc0204cd0 <commands+0x870>
ffffffffc020359c:	08400593          	li	a1,132
ffffffffc02035a0:	00002517          	auipc	a0,0x2
ffffffffc02035a4:	60850513          	addi	a0,a0,1544 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02035a8:	dcdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035ac:	00002697          	auipc	a3,0x2
ffffffffc02035b0:	6cc68693          	addi	a3,a3,1740 # ffffffffc0205c78 <default_pmm_manager+0xc10>
ffffffffc02035b4:	00001617          	auipc	a2,0x1
ffffffffc02035b8:	71c60613          	addi	a2,a2,1820 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02035bc:	07c00593          	li	a1,124
ffffffffc02035c0:	00002517          	auipc	a0,0x2
ffffffffc02035c4:	5e850513          	addi	a0,a0,1512 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02035c8:	dadfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035cc:	00002697          	auipc	a3,0x2
ffffffffc02035d0:	68c68693          	addi	a3,a3,1676 # ffffffffc0205c58 <default_pmm_manager+0xbf0>
ffffffffc02035d4:	00001617          	auipc	a2,0x1
ffffffffc02035d8:	6fc60613          	addi	a2,a2,1788 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02035dc:	07b00593          	li	a1,123
ffffffffc02035e0:	00002517          	auipc	a0,0x2
ffffffffc02035e4:	5c850513          	addi	a0,a0,1480 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02035e8:	d8dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035ec <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02035ec:	1141                	addi	sp,sp,-16
ffffffffc02035ee:	e022                	sd	s0,0(sp)
ffffffffc02035f0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02035f2:	6508                	ld	a0,8(a0)
ffffffffc02035f4:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02035f6:	00a40e63          	beq	s0,a0,ffffffffc0203612 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02035fa:	6118                	ld	a4,0(a0)
ffffffffc02035fc:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02035fe:	03000593          	li	a1,48
ffffffffc0203602:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203604:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203606:	e398                	sd	a4,0(a5)
ffffffffc0203608:	964ff0ef          	jal	ra,ffffffffc020276c <kfree>
    return listelm->next;
ffffffffc020360c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020360e:	fea416e3          	bne	s0,a0,ffffffffc02035fa <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203612:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203614:	6402                	ld	s0,0(sp)
ffffffffc0203616:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203618:	03000593          	li	a1,48
}
ffffffffc020361c:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020361e:	94eff06f          	j	ffffffffc020276c <kfree>

ffffffffc0203622 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203622:	715d                	addi	sp,sp,-80
ffffffffc0203624:	e486                	sd	ra,72(sp)
ffffffffc0203626:	e0a2                	sd	s0,64(sp)
ffffffffc0203628:	fc26                	sd	s1,56(sp)
ffffffffc020362a:	f84a                	sd	s2,48(sp)
ffffffffc020362c:	f052                	sd	s4,32(sp)
ffffffffc020362e:	f44e                	sd	s3,40(sp)
ffffffffc0203630:	ec56                	sd	s5,24(sp)
ffffffffc0203632:	e85a                	sd	s6,16(sp)
ffffffffc0203634:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203636:	916fe0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc020363a:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020363c:	910fe0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc0203640:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0203642:	e25ff0ef          	jal	ra,ffffffffc0203466 <mm_create>
    assert(mm != NULL);
ffffffffc0203646:	842a                	mv	s0,a0
ffffffffc0203648:	03200493          	li	s1,50
ffffffffc020364c:	e919                	bnez	a0,ffffffffc0203662 <vmm_init+0x40>
ffffffffc020364e:	aeed                	j	ffffffffc0203a48 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0203650:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203652:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203654:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203658:	14ed                	addi	s1,s1,-5
ffffffffc020365a:	8522                	mv	a0,s0
ffffffffc020365c:	ec3ff0ef          	jal	ra,ffffffffc020351e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203660:	c88d                	beqz	s1,ffffffffc0203692 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203662:	03000513          	li	a0,48
ffffffffc0203666:	844ff0ef          	jal	ra,ffffffffc02026aa <kmalloc>
ffffffffc020366a:	85aa                	mv	a1,a0
ffffffffc020366c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203670:	f165                	bnez	a0,ffffffffc0203650 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0203672:	00002697          	auipc	a3,0x2
ffffffffc0203676:	18e68693          	addi	a3,a3,398 # ffffffffc0205800 <default_pmm_manager+0x798>
ffffffffc020367a:	00001617          	auipc	a2,0x1
ffffffffc020367e:	65660613          	addi	a2,a2,1622 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203682:	0ce00593          	li	a1,206
ffffffffc0203686:	00002517          	auipc	a0,0x2
ffffffffc020368a:	52250513          	addi	a0,a0,1314 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc020368e:	ce7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203692:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203696:	1f900993          	li	s3,505
ffffffffc020369a:	a819                	j	ffffffffc02036b0 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc020369c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020369e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02036a0:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02036a4:	0495                	addi	s1,s1,5
ffffffffc02036a6:	8522                	mv	a0,s0
ffffffffc02036a8:	e77ff0ef          	jal	ra,ffffffffc020351e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02036ac:	03348a63          	beq	s1,s3,ffffffffc02036e0 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036b0:	03000513          	li	a0,48
ffffffffc02036b4:	ff7fe0ef          	jal	ra,ffffffffc02026aa <kmalloc>
ffffffffc02036b8:	85aa                	mv	a1,a0
ffffffffc02036ba:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02036be:	fd79                	bnez	a0,ffffffffc020369c <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02036c0:	00002697          	auipc	a3,0x2
ffffffffc02036c4:	14068693          	addi	a3,a3,320 # ffffffffc0205800 <default_pmm_manager+0x798>
ffffffffc02036c8:	00001617          	auipc	a2,0x1
ffffffffc02036cc:	60860613          	addi	a2,a2,1544 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02036d0:	0d400593          	li	a1,212
ffffffffc02036d4:	00002517          	auipc	a0,0x2
ffffffffc02036d8:	4d450513          	addi	a0,a0,1236 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02036dc:	c99fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02036e0:	6418                	ld	a4,8(s0)
ffffffffc02036e2:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02036e4:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02036e8:	2ae40063          	beq	s0,a4,ffffffffc0203988 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036ec:	fe873603          	ld	a2,-24(a4)
ffffffffc02036f0:	ffe78693          	addi	a3,a5,-2
ffffffffc02036f4:	20d61a63          	bne	a2,a3,ffffffffc0203908 <vmm_init+0x2e6>
ffffffffc02036f8:	ff073683          	ld	a3,-16(a4)
ffffffffc02036fc:	20d79663          	bne	a5,a3,ffffffffc0203908 <vmm_init+0x2e6>
ffffffffc0203700:	0795                	addi	a5,a5,5
ffffffffc0203702:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203704:	feb792e3          	bne	a5,a1,ffffffffc02036e8 <vmm_init+0xc6>
ffffffffc0203708:	499d                	li	s3,7
ffffffffc020370a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020370c:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203710:	85a6                	mv	a1,s1
ffffffffc0203712:	8522                	mv	a0,s0
ffffffffc0203714:	dcdff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
ffffffffc0203718:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc020371a:	2e050763          	beqz	a0,ffffffffc0203a08 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020371e:	00148593          	addi	a1,s1,1
ffffffffc0203722:	8522                	mv	a0,s0
ffffffffc0203724:	dbdff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
ffffffffc0203728:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc020372a:	2a050f63          	beqz	a0,ffffffffc02039e8 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020372e:	85ce                	mv	a1,s3
ffffffffc0203730:	8522                	mv	a0,s0
ffffffffc0203732:	dafff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203736:	28051963          	bnez	a0,ffffffffc02039c8 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020373a:	00348593          	addi	a1,s1,3
ffffffffc020373e:	8522                	mv	a0,s0
ffffffffc0203740:	da1ff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203744:	26051263          	bnez	a0,ffffffffc02039a8 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203748:	00448593          	addi	a1,s1,4
ffffffffc020374c:	8522                	mv	a0,s0
ffffffffc020374e:	d93ff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203752:	2c051b63          	bnez	a0,ffffffffc0203a28 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203756:	008b3783          	ld	a5,8(s6)
ffffffffc020375a:	1c979763          	bne	a5,s1,ffffffffc0203928 <vmm_init+0x306>
ffffffffc020375e:	010b3783          	ld	a5,16(s6)
ffffffffc0203762:	1d379363          	bne	a5,s3,ffffffffc0203928 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203766:	008ab783          	ld	a5,8(s5)
ffffffffc020376a:	1c979f63          	bne	a5,s1,ffffffffc0203948 <vmm_init+0x326>
ffffffffc020376e:	010ab783          	ld	a5,16(s5)
ffffffffc0203772:	1d379b63          	bne	a5,s3,ffffffffc0203948 <vmm_init+0x326>
ffffffffc0203776:	0495                	addi	s1,s1,5
ffffffffc0203778:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020377a:	f9749be3          	bne	s1,s7,ffffffffc0203710 <vmm_init+0xee>
ffffffffc020377e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203780:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203782:	85a6                	mv	a1,s1
ffffffffc0203784:	8522                	mv	a0,s0
ffffffffc0203786:	d5bff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
ffffffffc020378a:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020378e:	c90d                	beqz	a0,ffffffffc02037c0 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203790:	6914                	ld	a3,16(a0)
ffffffffc0203792:	6510                	ld	a2,8(a0)
ffffffffc0203794:	00002517          	auipc	a0,0x2
ffffffffc0203798:	60450513          	addi	a0,a0,1540 # ffffffffc0205d98 <default_pmm_manager+0xd30>
ffffffffc020379c:	923fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02037a0:	00002697          	auipc	a3,0x2
ffffffffc02037a4:	62068693          	addi	a3,a3,1568 # ffffffffc0205dc0 <default_pmm_manager+0xd58>
ffffffffc02037a8:	00001617          	auipc	a2,0x1
ffffffffc02037ac:	52860613          	addi	a2,a2,1320 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02037b0:	0f600593          	li	a1,246
ffffffffc02037b4:	00002517          	auipc	a0,0x2
ffffffffc02037b8:	3f450513          	addi	a0,a0,1012 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02037bc:	bb9fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02037c0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02037c2:	fd3490e3          	bne	s1,s3,ffffffffc0203782 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02037c6:	8522                	mv	a0,s0
ffffffffc02037c8:	e25ff0ef          	jal	ra,ffffffffc02035ec <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037cc:	f81fd0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc02037d0:	28aa1c63          	bne	s4,a0,ffffffffc0203a68 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02037d4:	00002517          	auipc	a0,0x2
ffffffffc02037d8:	62c50513          	addi	a0,a0,1580 # ffffffffc0205e00 <default_pmm_manager+0xd98>
ffffffffc02037dc:	8e3fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037e0:	f6dfd0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc02037e4:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02037e6:	c81ff0ef          	jal	ra,ffffffffc0203466 <mm_create>
ffffffffc02037ea:	0000e797          	auipc	a5,0xe
ffffffffc02037ee:	daa7b723          	sd	a0,-594(a5) # ffffffffc0211598 <check_mm_struct>
ffffffffc02037f2:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02037f4:	2a050a63          	beqz	a0,ffffffffc0203aa8 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037f8:	0000e797          	auipc	a5,0xe
ffffffffc02037fc:	c6078793          	addi	a5,a5,-928 # ffffffffc0211458 <boot_pgdir>
ffffffffc0203800:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203802:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203804:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203806:	32079d63          	bnez	a5,ffffffffc0203b40 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020380a:	03000513          	li	a0,48
ffffffffc020380e:	e9dfe0ef          	jal	ra,ffffffffc02026aa <kmalloc>
ffffffffc0203812:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203814:	14050a63          	beqz	a0,ffffffffc0203968 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0203818:	002007b7          	lui	a5,0x200
ffffffffc020381c:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203820:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203822:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203824:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203828:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020382a:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020382e:	cf1ff0ef          	jal	ra,ffffffffc020351e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203832:	10000593          	li	a1,256
ffffffffc0203836:	8522                	mv	a0,s0
ffffffffc0203838:	ca9ff0ef          	jal	ra,ffffffffc02034e0 <find_vma>
ffffffffc020383c:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203840:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203844:	2aaa1263          	bne	s4,a0,ffffffffc0203ae8 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0203848:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc020384c:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020384e:	fee79de3          	bne	a5,a4,ffffffffc0203848 <vmm_init+0x226>
        sum += i;
ffffffffc0203852:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203854:	10000793          	li	a5,256
        sum += i;
ffffffffc0203858:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020385c:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203860:	0007c683          	lbu	a3,0(a5)
ffffffffc0203864:	0785                	addi	a5,a5,1
ffffffffc0203866:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203868:	fec79ce3          	bne	a5,a2,ffffffffc0203860 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc020386c:	2a071a63          	bnez	a4,ffffffffc0203b20 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203870:	4581                	li	a1,0
ffffffffc0203872:	8526                	mv	a0,s1
ffffffffc0203874:	97efe0ef          	jal	ra,ffffffffc02019f2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203878:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020387a:	0000e717          	auipc	a4,0xe
ffffffffc020387e:	be670713          	addi	a4,a4,-1050 # ffffffffc0211460 <npage>
ffffffffc0203882:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203884:	078a                	slli	a5,a5,0x2
ffffffffc0203886:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203888:	28e7f063          	bleu	a4,a5,ffffffffc0203b08 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc020388c:	00003717          	auipc	a4,0x3
ffffffffc0203890:	8b470713          	addi	a4,a4,-1868 # ffffffffc0206140 <nbase>
ffffffffc0203894:	6318                	ld	a4,0(a4)
ffffffffc0203896:	0000e697          	auipc	a3,0xe
ffffffffc020389a:	c1a68693          	addi	a3,a3,-998 # ffffffffc02114b0 <pages>
ffffffffc020389e:	6288                	ld	a0,0(a3)
ffffffffc02038a0:	8f99                	sub	a5,a5,a4
ffffffffc02038a2:	00379713          	slli	a4,a5,0x3
ffffffffc02038a6:	97ba                	add	a5,a5,a4
ffffffffc02038a8:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02038aa:	953e                	add	a0,a0,a5
ffffffffc02038ac:	4585                	li	a1,1
ffffffffc02038ae:	e59fd0ef          	jal	ra,ffffffffc0201706 <free_pages>

    pgdir[0] = 0;
ffffffffc02038b2:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02038b6:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02038b8:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02038bc:	d31ff0ef          	jal	ra,ffffffffc02035ec <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02038c0:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02038c2:	0000e797          	auipc	a5,0xe
ffffffffc02038c6:	cc07bb23          	sd	zero,-810(a5) # ffffffffc0211598 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038ca:	e83fd0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
ffffffffc02038ce:	1aa99d63          	bne	s3,a0,ffffffffc0203a88 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02038d2:	00002517          	auipc	a0,0x2
ffffffffc02038d6:	59650513          	addi	a0,a0,1430 # ffffffffc0205e68 <default_pmm_manager+0xe00>
ffffffffc02038da:	fe4fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038de:	e6ffd0ef          	jal	ra,ffffffffc020174c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038e2:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038e4:	1ea91263          	bne	s2,a0,ffffffffc0203ac8 <vmm_init+0x4a6>
}
ffffffffc02038e8:	6406                	ld	s0,64(sp)
ffffffffc02038ea:	60a6                	ld	ra,72(sp)
ffffffffc02038ec:	74e2                	ld	s1,56(sp)
ffffffffc02038ee:	7942                	ld	s2,48(sp)
ffffffffc02038f0:	79a2                	ld	s3,40(sp)
ffffffffc02038f2:	7a02                	ld	s4,32(sp)
ffffffffc02038f4:	6ae2                	ld	s5,24(sp)
ffffffffc02038f6:	6b42                	ld	s6,16(sp)
ffffffffc02038f8:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038fa:	00002517          	auipc	a0,0x2
ffffffffc02038fe:	58e50513          	addi	a0,a0,1422 # ffffffffc0205e88 <default_pmm_manager+0xe20>
}
ffffffffc0203902:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203904:	fbafc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203908:	00002697          	auipc	a3,0x2
ffffffffc020390c:	3a868693          	addi	a3,a3,936 # ffffffffc0205cb0 <default_pmm_manager+0xc48>
ffffffffc0203910:	00001617          	auipc	a2,0x1
ffffffffc0203914:	3c060613          	addi	a2,a2,960 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203918:	0dd00593          	li	a1,221
ffffffffc020391c:	00002517          	auipc	a0,0x2
ffffffffc0203920:	28c50513          	addi	a0,a0,652 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203924:	a51fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203928:	00002697          	auipc	a3,0x2
ffffffffc020392c:	41068693          	addi	a3,a3,1040 # ffffffffc0205d38 <default_pmm_manager+0xcd0>
ffffffffc0203930:	00001617          	auipc	a2,0x1
ffffffffc0203934:	3a060613          	addi	a2,a2,928 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203938:	0ed00593          	li	a1,237
ffffffffc020393c:	00002517          	auipc	a0,0x2
ffffffffc0203940:	26c50513          	addi	a0,a0,620 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203944:	a31fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203948:	00002697          	auipc	a3,0x2
ffffffffc020394c:	42068693          	addi	a3,a3,1056 # ffffffffc0205d68 <default_pmm_manager+0xd00>
ffffffffc0203950:	00001617          	auipc	a2,0x1
ffffffffc0203954:	38060613          	addi	a2,a2,896 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203958:	0ee00593          	li	a1,238
ffffffffc020395c:	00002517          	auipc	a0,0x2
ffffffffc0203960:	24c50513          	addi	a0,a0,588 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203964:	a11fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203968:	00002697          	auipc	a3,0x2
ffffffffc020396c:	e9868693          	addi	a3,a3,-360 # ffffffffc0205800 <default_pmm_manager+0x798>
ffffffffc0203970:	00001617          	auipc	a2,0x1
ffffffffc0203974:	36060613          	addi	a2,a2,864 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203978:	11100593          	li	a1,273
ffffffffc020397c:	00002517          	auipc	a0,0x2
ffffffffc0203980:	22c50513          	addi	a0,a0,556 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203984:	9f1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203988:	00002697          	auipc	a3,0x2
ffffffffc020398c:	31068693          	addi	a3,a3,784 # ffffffffc0205c98 <default_pmm_manager+0xc30>
ffffffffc0203990:	00001617          	auipc	a2,0x1
ffffffffc0203994:	34060613          	addi	a2,a2,832 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203998:	0db00593          	li	a1,219
ffffffffc020399c:	00002517          	auipc	a0,0x2
ffffffffc02039a0:	20c50513          	addi	a0,a0,524 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02039a4:	9d1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc02039a8:	00002697          	auipc	a3,0x2
ffffffffc02039ac:	37068693          	addi	a3,a3,880 # ffffffffc0205d18 <default_pmm_manager+0xcb0>
ffffffffc02039b0:	00001617          	auipc	a2,0x1
ffffffffc02039b4:	32060613          	addi	a2,a2,800 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02039b8:	0e900593          	li	a1,233
ffffffffc02039bc:	00002517          	auipc	a0,0x2
ffffffffc02039c0:	1ec50513          	addi	a0,a0,492 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02039c4:	9b1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc02039c8:	00002697          	auipc	a3,0x2
ffffffffc02039cc:	34068693          	addi	a3,a3,832 # ffffffffc0205d08 <default_pmm_manager+0xca0>
ffffffffc02039d0:	00001617          	auipc	a2,0x1
ffffffffc02039d4:	30060613          	addi	a2,a2,768 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02039d8:	0e700593          	li	a1,231
ffffffffc02039dc:	00002517          	auipc	a0,0x2
ffffffffc02039e0:	1cc50513          	addi	a0,a0,460 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc02039e4:	991fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc02039e8:	00002697          	auipc	a3,0x2
ffffffffc02039ec:	31068693          	addi	a3,a3,784 # ffffffffc0205cf8 <default_pmm_manager+0xc90>
ffffffffc02039f0:	00001617          	auipc	a2,0x1
ffffffffc02039f4:	2e060613          	addi	a2,a2,736 # ffffffffc0204cd0 <commands+0x870>
ffffffffc02039f8:	0e500593          	li	a1,229
ffffffffc02039fc:	00002517          	auipc	a0,0x2
ffffffffc0203a00:	1ac50513          	addi	a0,a0,428 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203a04:	971fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203a08:	00002697          	auipc	a3,0x2
ffffffffc0203a0c:	2e068693          	addi	a3,a3,736 # ffffffffc0205ce8 <default_pmm_manager+0xc80>
ffffffffc0203a10:	00001617          	auipc	a2,0x1
ffffffffc0203a14:	2c060613          	addi	a2,a2,704 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203a18:	0e300593          	li	a1,227
ffffffffc0203a1c:	00002517          	auipc	a0,0x2
ffffffffc0203a20:	18c50513          	addi	a0,a0,396 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203a24:	951fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203a28:	00002697          	auipc	a3,0x2
ffffffffc0203a2c:	30068693          	addi	a3,a3,768 # ffffffffc0205d28 <default_pmm_manager+0xcc0>
ffffffffc0203a30:	00001617          	auipc	a2,0x1
ffffffffc0203a34:	2a060613          	addi	a2,a2,672 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203a38:	0eb00593          	li	a1,235
ffffffffc0203a3c:	00002517          	auipc	a0,0x2
ffffffffc0203a40:	16c50513          	addi	a0,a0,364 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203a44:	931fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203a48:	00002697          	auipc	a3,0x2
ffffffffc0203a4c:	d8068693          	addi	a3,a3,-640 # ffffffffc02057c8 <default_pmm_manager+0x760>
ffffffffc0203a50:	00001617          	auipc	a2,0x1
ffffffffc0203a54:	28060613          	addi	a2,a2,640 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203a58:	0c700593          	li	a1,199
ffffffffc0203a5c:	00002517          	auipc	a0,0x2
ffffffffc0203a60:	14c50513          	addi	a0,a0,332 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203a64:	911fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a68:	00002697          	auipc	a3,0x2
ffffffffc0203a6c:	37068693          	addi	a3,a3,880 # ffffffffc0205dd8 <default_pmm_manager+0xd70>
ffffffffc0203a70:	00001617          	auipc	a2,0x1
ffffffffc0203a74:	26060613          	addi	a2,a2,608 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203a78:	0fb00593          	li	a1,251
ffffffffc0203a7c:	00002517          	auipc	a0,0x2
ffffffffc0203a80:	12c50513          	addi	a0,a0,300 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203a84:	8f1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a88:	00002697          	auipc	a3,0x2
ffffffffc0203a8c:	35068693          	addi	a3,a3,848 # ffffffffc0205dd8 <default_pmm_manager+0xd70>
ffffffffc0203a90:	00001617          	auipc	a2,0x1
ffffffffc0203a94:	24060613          	addi	a2,a2,576 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203a98:	12e00593          	li	a1,302
ffffffffc0203a9c:	00002517          	auipc	a0,0x2
ffffffffc0203aa0:	10c50513          	addi	a0,a0,268 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203aa4:	8d1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203aa8:	00002697          	auipc	a3,0x2
ffffffffc0203aac:	37868693          	addi	a3,a3,888 # ffffffffc0205e20 <default_pmm_manager+0xdb8>
ffffffffc0203ab0:	00001617          	auipc	a2,0x1
ffffffffc0203ab4:	22060613          	addi	a2,a2,544 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203ab8:	10a00593          	li	a1,266
ffffffffc0203abc:	00002517          	auipc	a0,0x2
ffffffffc0203ac0:	0ec50513          	addi	a0,a0,236 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203ac4:	8b1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ac8:	00002697          	auipc	a3,0x2
ffffffffc0203acc:	31068693          	addi	a3,a3,784 # ffffffffc0205dd8 <default_pmm_manager+0xd70>
ffffffffc0203ad0:	00001617          	auipc	a2,0x1
ffffffffc0203ad4:	20060613          	addi	a2,a2,512 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203ad8:	0bd00593          	li	a1,189
ffffffffc0203adc:	00002517          	auipc	a0,0x2
ffffffffc0203ae0:	0cc50513          	addi	a0,a0,204 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203ae4:	891fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ae8:	00002697          	auipc	a3,0x2
ffffffffc0203aec:	35068693          	addi	a3,a3,848 # ffffffffc0205e38 <default_pmm_manager+0xdd0>
ffffffffc0203af0:	00001617          	auipc	a2,0x1
ffffffffc0203af4:	1e060613          	addi	a2,a2,480 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203af8:	11600593          	li	a1,278
ffffffffc0203afc:	00002517          	auipc	a0,0x2
ffffffffc0203b00:	0ac50513          	addi	a0,a0,172 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203b04:	871fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203b08:	00001617          	auipc	a2,0x1
ffffffffc0203b0c:	62860613          	addi	a2,a2,1576 # ffffffffc0205130 <default_pmm_manager+0xc8>
ffffffffc0203b10:	06500593          	li	a1,101
ffffffffc0203b14:	00001517          	auipc	a0,0x1
ffffffffc0203b18:	63c50513          	addi	a0,a0,1596 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0203b1c:	859fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203b20:	00002697          	auipc	a3,0x2
ffffffffc0203b24:	33868693          	addi	a3,a3,824 # ffffffffc0205e58 <default_pmm_manager+0xdf0>
ffffffffc0203b28:	00001617          	auipc	a2,0x1
ffffffffc0203b2c:	1a860613          	addi	a2,a2,424 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203b30:	12000593          	li	a1,288
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	07450513          	addi	a0,a0,116 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203b3c:	839fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b40:	00002697          	auipc	a3,0x2
ffffffffc0203b44:	cb068693          	addi	a3,a3,-848 # ffffffffc02057f0 <default_pmm_manager+0x788>
ffffffffc0203b48:	00001617          	auipc	a2,0x1
ffffffffc0203b4c:	18860613          	addi	a2,a2,392 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0203b50:	10d00593          	li	a1,269
ffffffffc0203b54:	00002517          	auipc	a0,0x2
ffffffffc0203b58:	05450513          	addi	a0,a0,84 # ffffffffc0205ba8 <default_pmm_manager+0xb40>
ffffffffc0203b5c:	819fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b60 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b60:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b62:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b64:	f022                	sd	s0,32(sp)
ffffffffc0203b66:	ec26                	sd	s1,24(sp)
ffffffffc0203b68:	f406                	sd	ra,40(sp)
ffffffffc0203b6a:	e84a                	sd	s2,16(sp)
ffffffffc0203b6c:	8432                	mv	s0,a2
ffffffffc0203b6e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b70:	971ff0ef          	jal	ra,ffffffffc02034e0 <find_vma>

    pgfault_num++;
ffffffffc0203b74:	0000e797          	auipc	a5,0xe
ffffffffc0203b78:	90078793          	addi	a5,a5,-1792 # ffffffffc0211474 <pgfault_num>
ffffffffc0203b7c:	439c                	lw	a5,0(a5)
ffffffffc0203b7e:	2785                	addiw	a5,a5,1
ffffffffc0203b80:	0000e717          	auipc	a4,0xe
ffffffffc0203b84:	8ef72a23          	sw	a5,-1804(a4) # ffffffffc0211474 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b88:	c549                	beqz	a0,ffffffffc0203c12 <do_pgfault+0xb2>
ffffffffc0203b8a:	651c                	ld	a5,8(a0)
ffffffffc0203b8c:	08f46363          	bltu	s0,a5,ffffffffc0203c12 <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b90:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b92:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b94:	8b89                	andi	a5,a5,2
ffffffffc0203b96:	efa9                	bnez	a5,ffffffffc0203bf0 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b98:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b9a:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b9c:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b9e:	85a2                	mv	a1,s0
ffffffffc0203ba0:	4605                	li	a2,1
ffffffffc0203ba2:	bebfd0ef          	jal	ra,ffffffffc020178c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203ba6:	610c                	ld	a1,0(a0)
ffffffffc0203ba8:	c5b1                	beqz	a1,ffffffffc0203bf4 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203baa:	0000e797          	auipc	a5,0xe
ffffffffc0203bae:	8c678793          	addi	a5,a5,-1850 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203bb2:	439c                	lw	a5,0(a5)
ffffffffc0203bb4:	2781                	sext.w	a5,a5
ffffffffc0203bb6:	c7bd                	beqz	a5,ffffffffc0203c24 <do_pgfault+0xc4>
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            // 将addr线性地址对应的物理页数据从磁盘交换到物理内存中(令Page指针指向交换成功后的物理页)
            swap_in(mm, addr, &page);
ffffffffc0203bb8:	85a2                	mv	a1,s0
ffffffffc0203bba:	0030                	addi	a2,sp,8
ffffffffc0203bbc:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203bbe:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203bc0:	c40ff0ef          	jal	ra,ffffffffc0203000 <swap_in>
            // 将交换进来的page页与mm->padir页表中对应addr的二级页表项建立映射关系(perm标识这个二级页表的各个权限位)
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203bc4:	65a2                	ld	a1,8(sp)
ffffffffc0203bc6:	6c88                	ld	a0,24(s1)
ffffffffc0203bc8:	86ca                	mv	a3,s2
ffffffffc0203bca:	8622                	mv	a2,s0
ffffffffc0203bcc:	e99fd0ef          	jal	ra,ffffffffc0201a64 <page_insert>
            // 当前page是为可交换的，将其加入全局虚拟内存交换管理器的管理
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203bd0:	6622                	ld	a2,8(sp)
ffffffffc0203bd2:	4685                	li	a3,1
ffffffffc0203bd4:	85a2                	mv	a1,s0
ffffffffc0203bd6:	8526                	mv	a0,s1
ffffffffc0203bd8:	b04ff0ef          	jal	ra,ffffffffc0202edc <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0203bdc:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203bde:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203be0:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0203be2:	70a2                	ld	ra,40(sp)
ffffffffc0203be4:	7402                	ld	s0,32(sp)
ffffffffc0203be6:	64e2                	ld	s1,24(sp)
ffffffffc0203be8:	6942                	ld	s2,16(sp)
ffffffffc0203bea:	853e                	mv	a0,a5
ffffffffc0203bec:	6145                	addi	sp,sp,48
ffffffffc0203bee:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203bf0:	4959                	li	s2,22
ffffffffc0203bf2:	b75d                	j	ffffffffc0203b98 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bf4:	6c88                	ld	a0,24(s1)
ffffffffc0203bf6:	864a                	mv	a2,s2
ffffffffc0203bf8:	85a2                	mv	a1,s0
ffffffffc0203bfa:	a1ffe0ef          	jal	ra,ffffffffc0202618 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203bfe:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203c00:	f16d                	bnez	a0,ffffffffc0203be2 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203c02:	00002517          	auipc	a0,0x2
ffffffffc0203c06:	fe650513          	addi	a0,a0,-26 # ffffffffc0205be8 <default_pmm_manager+0xb80>
ffffffffc0203c0a:	cb4fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c0e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c10:	bfc9                	j	ffffffffc0203be2 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203c12:	85a2                	mv	a1,s0
ffffffffc0203c14:	00002517          	auipc	a0,0x2
ffffffffc0203c18:	fa450513          	addi	a0,a0,-92 # ffffffffc0205bb8 <default_pmm_manager+0xb50>
ffffffffc0203c1c:	ca2fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c20:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203c22:	b7c1                	j	ffffffffc0203be2 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c24:	00002517          	auipc	a0,0x2
ffffffffc0203c28:	fec50513          	addi	a0,a0,-20 # ffffffffc0205c10 <default_pmm_manager+0xba8>
ffffffffc0203c2c:	c92fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c30:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c32:	bf45                	j	ffffffffc0203be2 <do_pgfault+0x82>

ffffffffc0203c34 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c34:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c36:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c38:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c3a:	865fc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203c3e:	cd01                	beqz	a0,ffffffffc0203c56 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c40:	4505                	li	a0,1
ffffffffc0203c42:	863fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203c46:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c48:	810d                	srli	a0,a0,0x3
ffffffffc0203c4a:	0000e797          	auipc	a5,0xe
ffffffffc0203c4e:	8ea7bb23          	sd	a0,-1802(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203c52:	0141                	addi	sp,sp,16
ffffffffc0203c54:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c56:	00002617          	auipc	a2,0x2
ffffffffc0203c5a:	24a60613          	addi	a2,a2,586 # ffffffffc0205ea0 <default_pmm_manager+0xe38>
ffffffffc0203c5e:	45b5                	li	a1,13
ffffffffc0203c60:	00002517          	auipc	a0,0x2
ffffffffc0203c64:	26050513          	addi	a0,a0,608 # ffffffffc0205ec0 <default_pmm_manager+0xe58>
ffffffffc0203c68:	f0cfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c6c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c6c:	1141                	addi	sp,sp,-16
ffffffffc0203c6e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c70:	00855793          	srli	a5,a0,0x8
ffffffffc0203c74:	c7b5                	beqz	a5,ffffffffc0203ce0 <swapfs_read+0x74>
ffffffffc0203c76:	0000e717          	auipc	a4,0xe
ffffffffc0203c7a:	8ca70713          	addi	a4,a4,-1846 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203c7e:	6318                	ld	a4,0(a4)
ffffffffc0203c80:	06e7f063          	bleu	a4,a5,ffffffffc0203ce0 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c84:	0000e717          	auipc	a4,0xe
ffffffffc0203c88:	82c70713          	addi	a4,a4,-2004 # ffffffffc02114b0 <pages>
ffffffffc0203c8c:	6310                	ld	a2,0(a4)
ffffffffc0203c8e:	00001717          	auipc	a4,0x1
ffffffffc0203c92:	02a70713          	addi	a4,a4,42 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0203c96:	00002697          	auipc	a3,0x2
ffffffffc0203c9a:	4aa68693          	addi	a3,a3,1194 # ffffffffc0206140 <nbase>
ffffffffc0203c9e:	40c58633          	sub	a2,a1,a2
ffffffffc0203ca2:	630c                	ld	a1,0(a4)
ffffffffc0203ca4:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca6:	0000d717          	auipc	a4,0xd
ffffffffc0203caa:	7ba70713          	addi	a4,a4,1978 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cae:	02b60633          	mul	a2,a2,a1
ffffffffc0203cb2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cb6:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb8:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cba:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cbc:	57fd                	li	a5,-1
ffffffffc0203cbe:	83b1                	srli	a5,a5,0xc
ffffffffc0203cc0:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cc2:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cc4:	02e7fa63          	bleu	a4,a5,ffffffffc0203cf8 <swapfs_read+0x8c>
ffffffffc0203cc8:	0000d797          	auipc	a5,0xd
ffffffffc0203ccc:	7d878793          	addi	a5,a5,2008 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203cd0:	639c                	ld	a5,0(a5)
}
ffffffffc0203cd2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cd4:	46a1                	li	a3,8
ffffffffc0203cd6:	963e                	add	a2,a2,a5
ffffffffc0203cd8:	4505                	li	a0,1
}
ffffffffc0203cda:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cdc:	fcefc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203ce0:	86aa                	mv	a3,a0
ffffffffc0203ce2:	00002617          	auipc	a2,0x2
ffffffffc0203ce6:	1f660613          	addi	a2,a2,502 # ffffffffc0205ed8 <default_pmm_manager+0xe70>
ffffffffc0203cea:	45d1                	li	a1,20
ffffffffc0203cec:	00002517          	auipc	a0,0x2
ffffffffc0203cf0:	1d450513          	addi	a0,a0,468 # ffffffffc0205ec0 <default_pmm_manager+0xe58>
ffffffffc0203cf4:	e80fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203cf8:	86b2                	mv	a3,a2
ffffffffc0203cfa:	06a00593          	li	a1,106
ffffffffc0203cfe:	00001617          	auipc	a2,0x1
ffffffffc0203d02:	3ba60613          	addi	a2,a2,954 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc0203d06:	00001517          	auipc	a0,0x1
ffffffffc0203d0a:	44a50513          	addi	a0,a0,1098 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0203d0e:	e66fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d12 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d12:	1141                	addi	sp,sp,-16
ffffffffc0203d14:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d16:	00855793          	srli	a5,a0,0x8
ffffffffc0203d1a:	c7b5                	beqz	a5,ffffffffc0203d86 <swapfs_write+0x74>
ffffffffc0203d1c:	0000e717          	auipc	a4,0xe
ffffffffc0203d20:	82470713          	addi	a4,a4,-2012 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203d24:	6318                	ld	a4,0(a4)
ffffffffc0203d26:	06e7f063          	bleu	a4,a5,ffffffffc0203d86 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d2a:	0000d717          	auipc	a4,0xd
ffffffffc0203d2e:	78670713          	addi	a4,a4,1926 # ffffffffc02114b0 <pages>
ffffffffc0203d32:	6310                	ld	a2,0(a4)
ffffffffc0203d34:	00001717          	auipc	a4,0x1
ffffffffc0203d38:	f8470713          	addi	a4,a4,-124 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0203d3c:	00002697          	auipc	a3,0x2
ffffffffc0203d40:	40468693          	addi	a3,a3,1028 # ffffffffc0206140 <nbase>
ffffffffc0203d44:	40c58633          	sub	a2,a1,a2
ffffffffc0203d48:	630c                	ld	a1,0(a4)
ffffffffc0203d4a:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4c:	0000d717          	auipc	a4,0xd
ffffffffc0203d50:	71470713          	addi	a4,a4,1812 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d54:	02b60633          	mul	a2,a2,a1
ffffffffc0203d58:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d5c:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d5e:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d60:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d62:	57fd                	li	a5,-1
ffffffffc0203d64:	83b1                	srli	a5,a5,0xc
ffffffffc0203d66:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d68:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d6a:	02e7fa63          	bleu	a4,a5,ffffffffc0203d9e <swapfs_write+0x8c>
ffffffffc0203d6e:	0000d797          	auipc	a5,0xd
ffffffffc0203d72:	73278793          	addi	a5,a5,1842 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203d76:	639c                	ld	a5,0(a5)
}
ffffffffc0203d78:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d7a:	46a1                	li	a3,8
ffffffffc0203d7c:	963e                	add	a2,a2,a5
ffffffffc0203d7e:	4505                	li	a0,1
}
ffffffffc0203d80:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d82:	f4cfc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203d86:	86aa                	mv	a3,a0
ffffffffc0203d88:	00002617          	auipc	a2,0x2
ffffffffc0203d8c:	15060613          	addi	a2,a2,336 # ffffffffc0205ed8 <default_pmm_manager+0xe70>
ffffffffc0203d90:	45e5                	li	a1,25
ffffffffc0203d92:	00002517          	auipc	a0,0x2
ffffffffc0203d96:	12e50513          	addi	a0,a0,302 # ffffffffc0205ec0 <default_pmm_manager+0xe58>
ffffffffc0203d9a:	ddafc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203d9e:	86b2                	mv	a3,a2
ffffffffc0203da0:	06a00593          	li	a1,106
ffffffffc0203da4:	00001617          	auipc	a2,0x1
ffffffffc0203da8:	31460613          	addi	a2,a2,788 # ffffffffc02050b8 <default_pmm_manager+0x50>
ffffffffc0203dac:	00001517          	auipc	a0,0x1
ffffffffc0203db0:	3a450513          	addi	a0,a0,932 # ffffffffc0205150 <default_pmm_manager+0xe8>
ffffffffc0203db4:	dc0fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203db8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203db8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dbc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203dbe:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dc2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203dc4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dc8:	f022                	sd	s0,32(sp)
ffffffffc0203dca:	ec26                	sd	s1,24(sp)
ffffffffc0203dcc:	e84a                	sd	s2,16(sp)
ffffffffc0203dce:	f406                	sd	ra,40(sp)
ffffffffc0203dd0:	e44e                	sd	s3,8(sp)
ffffffffc0203dd2:	84aa                	mv	s1,a0
ffffffffc0203dd4:	892e                	mv	s2,a1
ffffffffc0203dd6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203dda:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203ddc:	03067e63          	bleu	a6,a2,ffffffffc0203e18 <printnum+0x60>
ffffffffc0203de0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203de2:	00805763          	blez	s0,ffffffffc0203df0 <printnum+0x38>
ffffffffc0203de6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203de8:	85ca                	mv	a1,s2
ffffffffc0203dea:	854e                	mv	a0,s3
ffffffffc0203dec:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203dee:	fc65                	bnez	s0,ffffffffc0203de6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203df0:	1a02                	slli	s4,s4,0x20
ffffffffc0203df2:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203df6:	00002797          	auipc	a5,0x2
ffffffffc0203dfa:	29278793          	addi	a5,a5,658 # ffffffffc0206088 <error_string+0x38>
ffffffffc0203dfe:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e00:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e02:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e06:	70a2                	ld	ra,40(sp)
ffffffffc0203e08:	69a2                	ld	s3,8(sp)
ffffffffc0203e0a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e0c:	85ca                	mv	a1,s2
ffffffffc0203e0e:	8326                	mv	t1,s1
}
ffffffffc0203e10:	6942                	ld	s2,16(sp)
ffffffffc0203e12:	64e2                	ld	s1,24(sp)
ffffffffc0203e14:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e16:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e18:	03065633          	divu	a2,a2,a6
ffffffffc0203e1c:	8722                	mv	a4,s0
ffffffffc0203e1e:	f9bff0ef          	jal	ra,ffffffffc0203db8 <printnum>
ffffffffc0203e22:	b7f9                	j	ffffffffc0203df0 <printnum+0x38>

ffffffffc0203e24 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e24:	7119                	addi	sp,sp,-128
ffffffffc0203e26:	f4a6                	sd	s1,104(sp)
ffffffffc0203e28:	f0ca                	sd	s2,96(sp)
ffffffffc0203e2a:	e8d2                	sd	s4,80(sp)
ffffffffc0203e2c:	e4d6                	sd	s5,72(sp)
ffffffffc0203e2e:	e0da                	sd	s6,64(sp)
ffffffffc0203e30:	fc5e                	sd	s7,56(sp)
ffffffffc0203e32:	f862                	sd	s8,48(sp)
ffffffffc0203e34:	f06a                	sd	s10,32(sp)
ffffffffc0203e36:	fc86                	sd	ra,120(sp)
ffffffffc0203e38:	f8a2                	sd	s0,112(sp)
ffffffffc0203e3a:	ecce                	sd	s3,88(sp)
ffffffffc0203e3c:	f466                	sd	s9,40(sp)
ffffffffc0203e3e:	ec6e                	sd	s11,24(sp)
ffffffffc0203e40:	892a                	mv	s2,a0
ffffffffc0203e42:	84ae                	mv	s1,a1
ffffffffc0203e44:	8d32                	mv	s10,a2
ffffffffc0203e46:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e48:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e4a:	00002a17          	auipc	s4,0x2
ffffffffc0203e4e:	0aea0a13          	addi	s4,s4,174 # ffffffffc0205ef8 <default_pmm_manager+0xe90>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e52:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e56:	00002c17          	auipc	s8,0x2
ffffffffc0203e5a:	1fac0c13          	addi	s8,s8,506 # ffffffffc0206050 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e5e:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e62:	02500793          	li	a5,37
ffffffffc0203e66:	001d0413          	addi	s0,s10,1
ffffffffc0203e6a:	00f50e63          	beq	a0,a5,ffffffffc0203e86 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e6e:	c521                	beqz	a0,ffffffffc0203eb6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e70:	02500993          	li	s3,37
ffffffffc0203e74:	a011                	j	ffffffffc0203e78 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e76:	c121                	beqz	a0,ffffffffc0203eb6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e78:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e7a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203e7c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e7e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203e82:	ff351ae3          	bne	a0,s3,ffffffffc0203e76 <vprintfmt+0x52>
ffffffffc0203e86:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203e8a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203e8e:	4981                	li	s3,0
ffffffffc0203e90:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203e92:	5cfd                	li	s9,-1
ffffffffc0203e94:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e96:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203e9a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e9c:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203ea0:	0ff6f693          	andi	a3,a3,255
ffffffffc0203ea4:	00140d13          	addi	s10,s0,1
ffffffffc0203ea8:	20d5e563          	bltu	a1,a3,ffffffffc02040b2 <vprintfmt+0x28e>
ffffffffc0203eac:	068a                	slli	a3,a3,0x2
ffffffffc0203eae:	96d2                	add	a3,a3,s4
ffffffffc0203eb0:	4294                	lw	a3,0(a3)
ffffffffc0203eb2:	96d2                	add	a3,a3,s4
ffffffffc0203eb4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eb6:	70e6                	ld	ra,120(sp)
ffffffffc0203eb8:	7446                	ld	s0,112(sp)
ffffffffc0203eba:	74a6                	ld	s1,104(sp)
ffffffffc0203ebc:	7906                	ld	s2,96(sp)
ffffffffc0203ebe:	69e6                	ld	s3,88(sp)
ffffffffc0203ec0:	6a46                	ld	s4,80(sp)
ffffffffc0203ec2:	6aa6                	ld	s5,72(sp)
ffffffffc0203ec4:	6b06                	ld	s6,64(sp)
ffffffffc0203ec6:	7be2                	ld	s7,56(sp)
ffffffffc0203ec8:	7c42                	ld	s8,48(sp)
ffffffffc0203eca:	7ca2                	ld	s9,40(sp)
ffffffffc0203ecc:	7d02                	ld	s10,32(sp)
ffffffffc0203ece:	6de2                	ld	s11,24(sp)
ffffffffc0203ed0:	6109                	addi	sp,sp,128
ffffffffc0203ed2:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ed4:	4705                	li	a4,1
ffffffffc0203ed6:	008a8593          	addi	a1,s5,8
ffffffffc0203eda:	01074463          	blt	a4,a6,ffffffffc0203ee2 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203ede:	26080363          	beqz	a6,ffffffffc0204144 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203ee2:	000ab603          	ld	a2,0(s5)
ffffffffc0203ee6:	46c1                	li	a3,16
ffffffffc0203ee8:	8aae                	mv	s5,a1
ffffffffc0203eea:	a06d                	j	ffffffffc0203f94 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203eec:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203ef0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ef2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ef4:	b765                	j	ffffffffc0203e9c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ef6:	000aa503          	lw	a0,0(s5)
ffffffffc0203efa:	85a6                	mv	a1,s1
ffffffffc0203efc:	0aa1                	addi	s5,s5,8
ffffffffc0203efe:	9902                	jalr	s2
            break;
ffffffffc0203f00:	bfb9                	j	ffffffffc0203e5e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f02:	4705                	li	a4,1
ffffffffc0203f04:	008a8993          	addi	s3,s5,8
ffffffffc0203f08:	01074463          	blt	a4,a6,ffffffffc0203f10 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f0c:	22080463          	beqz	a6,ffffffffc0204134 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f10:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f14:	24044463          	bltz	s0,ffffffffc020415c <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f18:	8622                	mv	a2,s0
ffffffffc0203f1a:	8ace                	mv	s5,s3
ffffffffc0203f1c:	46a9                	li	a3,10
ffffffffc0203f1e:	a89d                	j	ffffffffc0203f94 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f20:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f24:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f26:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f28:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f2c:	8fb5                	xor	a5,a5,a3
ffffffffc0203f2e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f32:	1ad74363          	blt	a4,a3,ffffffffc02040d8 <vprintfmt+0x2b4>
ffffffffc0203f36:	00369793          	slli	a5,a3,0x3
ffffffffc0203f3a:	97e2                	add	a5,a5,s8
ffffffffc0203f3c:	639c                	ld	a5,0(a5)
ffffffffc0203f3e:	18078d63          	beqz	a5,ffffffffc02040d8 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f42:	86be                	mv	a3,a5
ffffffffc0203f44:	00002617          	auipc	a2,0x2
ffffffffc0203f48:	1f460613          	addi	a2,a2,500 # ffffffffc0206138 <error_string+0xe8>
ffffffffc0203f4c:	85a6                	mv	a1,s1
ffffffffc0203f4e:	854a                	mv	a0,s2
ffffffffc0203f50:	240000ef          	jal	ra,ffffffffc0204190 <printfmt>
ffffffffc0203f54:	b729                	j	ffffffffc0203e5e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f56:	00144603          	lbu	a2,1(s0)
ffffffffc0203f5a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f5c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f5e:	bf3d                	j	ffffffffc0203e9c <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f60:	4705                	li	a4,1
ffffffffc0203f62:	008a8593          	addi	a1,s5,8
ffffffffc0203f66:	01074463          	blt	a4,a6,ffffffffc0203f6e <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f6a:	1e080263          	beqz	a6,ffffffffc020414e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f6e:	000ab603          	ld	a2,0(s5)
ffffffffc0203f72:	46a1                	li	a3,8
ffffffffc0203f74:	8aae                	mv	s5,a1
ffffffffc0203f76:	a839                	j	ffffffffc0203f94 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203f78:	03000513          	li	a0,48
ffffffffc0203f7c:	85a6                	mv	a1,s1
ffffffffc0203f7e:	e03e                	sd	a5,0(sp)
ffffffffc0203f80:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203f82:	85a6                	mv	a1,s1
ffffffffc0203f84:	07800513          	li	a0,120
ffffffffc0203f88:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f8a:	0aa1                	addi	s5,s5,8
ffffffffc0203f8c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203f90:	6782                	ld	a5,0(sp)
ffffffffc0203f92:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203f94:	876e                	mv	a4,s11
ffffffffc0203f96:	85a6                	mv	a1,s1
ffffffffc0203f98:	854a                	mv	a0,s2
ffffffffc0203f9a:	e1fff0ef          	jal	ra,ffffffffc0203db8 <printnum>
            break;
ffffffffc0203f9e:	b5c1                	j	ffffffffc0203e5e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203fa0:	000ab603          	ld	a2,0(s5)
ffffffffc0203fa4:	0aa1                	addi	s5,s5,8
ffffffffc0203fa6:	1c060663          	beqz	a2,ffffffffc0204172 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203faa:	00160413          	addi	s0,a2,1
ffffffffc0203fae:	17b05c63          	blez	s11,ffffffffc0204126 <vprintfmt+0x302>
ffffffffc0203fb2:	02d00593          	li	a1,45
ffffffffc0203fb6:	14b79263          	bne	a5,a1,ffffffffc02040fa <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fba:	00064783          	lbu	a5,0(a2)
ffffffffc0203fbe:	0007851b          	sext.w	a0,a5
ffffffffc0203fc2:	c905                	beqz	a0,ffffffffc0203ff2 <vprintfmt+0x1ce>
ffffffffc0203fc4:	000cc563          	bltz	s9,ffffffffc0203fce <vprintfmt+0x1aa>
ffffffffc0203fc8:	3cfd                	addiw	s9,s9,-1
ffffffffc0203fca:	036c8263          	beq	s9,s6,ffffffffc0203fee <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203fce:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203fd0:	18098463          	beqz	s3,ffffffffc0204158 <vprintfmt+0x334>
ffffffffc0203fd4:	3781                	addiw	a5,a5,-32
ffffffffc0203fd6:	18fbf163          	bleu	a5,s7,ffffffffc0204158 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203fda:	03f00513          	li	a0,63
ffffffffc0203fde:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fe0:	0405                	addi	s0,s0,1
ffffffffc0203fe2:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203fe6:	3dfd                	addiw	s11,s11,-1
ffffffffc0203fe8:	0007851b          	sext.w	a0,a5
ffffffffc0203fec:	fd61                	bnez	a0,ffffffffc0203fc4 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203fee:	e7b058e3          	blez	s11,ffffffffc0203e5e <vprintfmt+0x3a>
ffffffffc0203ff2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203ff4:	85a6                	mv	a1,s1
ffffffffc0203ff6:	02000513          	li	a0,32
ffffffffc0203ffa:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ffc:	e60d81e3          	beqz	s11,ffffffffc0203e5e <vprintfmt+0x3a>
ffffffffc0204000:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204002:	85a6                	mv	a1,s1
ffffffffc0204004:	02000513          	li	a0,32
ffffffffc0204008:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020400a:	fe0d94e3          	bnez	s11,ffffffffc0203ff2 <vprintfmt+0x1ce>
ffffffffc020400e:	bd81                	j	ffffffffc0203e5e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204010:	4705                	li	a4,1
ffffffffc0204012:	008a8593          	addi	a1,s5,8
ffffffffc0204016:	01074463          	blt	a4,a6,ffffffffc020401e <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020401a:	12080063          	beqz	a6,ffffffffc020413a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020401e:	000ab603          	ld	a2,0(s5)
ffffffffc0204022:	46a9                	li	a3,10
ffffffffc0204024:	8aae                	mv	s5,a1
ffffffffc0204026:	b7bd                	j	ffffffffc0203f94 <vprintfmt+0x170>
ffffffffc0204028:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020402c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204030:	846a                	mv	s0,s10
ffffffffc0204032:	b5ad                	j	ffffffffc0203e9c <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204034:	85a6                	mv	a1,s1
ffffffffc0204036:	02500513          	li	a0,37
ffffffffc020403a:	9902                	jalr	s2
            break;
ffffffffc020403c:	b50d                	j	ffffffffc0203e5e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020403e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204042:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204046:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204048:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020404a:	e40dd9e3          	bgez	s11,ffffffffc0203e9c <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020404e:	8de6                	mv	s11,s9
ffffffffc0204050:	5cfd                	li	s9,-1
ffffffffc0204052:	b5a9                	j	ffffffffc0203e9c <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204054:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204058:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020405c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020405e:	bd3d                	j	ffffffffc0203e9c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204060:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204064:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204068:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020406a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020406e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204072:	fcd56ce3          	bltu	a0,a3,ffffffffc020404a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204076:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204078:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020407c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204080:	0196873b          	addw	a4,a3,s9
ffffffffc0204084:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204088:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020408c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204090:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204094:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204098:	fcd57fe3          	bleu	a3,a0,ffffffffc0204076 <vprintfmt+0x252>
ffffffffc020409c:	b77d                	j	ffffffffc020404a <vprintfmt+0x226>
            if (width < 0)
ffffffffc020409e:	fffdc693          	not	a3,s11
ffffffffc02040a2:	96fd                	srai	a3,a3,0x3f
ffffffffc02040a4:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040a8:	00144603          	lbu	a2,1(s0)
ffffffffc02040ac:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ae:	846a                	mv	s0,s10
ffffffffc02040b0:	b3f5                	j	ffffffffc0203e9c <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02040b2:	85a6                	mv	a1,s1
ffffffffc02040b4:	02500513          	li	a0,37
ffffffffc02040b8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040ba:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040be:	02500793          	li	a5,37
ffffffffc02040c2:	8d22                	mv	s10,s0
ffffffffc02040c4:	d8f70de3          	beq	a4,a5,ffffffffc0203e5e <vprintfmt+0x3a>
ffffffffc02040c8:	02500713          	li	a4,37
ffffffffc02040cc:	1d7d                	addi	s10,s10,-1
ffffffffc02040ce:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040d2:	fee79de3          	bne	a5,a4,ffffffffc02040cc <vprintfmt+0x2a8>
ffffffffc02040d6:	b361                	j	ffffffffc0203e5e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040d8:	00002617          	auipc	a2,0x2
ffffffffc02040dc:	05060613          	addi	a2,a2,80 # ffffffffc0206128 <error_string+0xd8>
ffffffffc02040e0:	85a6                	mv	a1,s1
ffffffffc02040e2:	854a                	mv	a0,s2
ffffffffc02040e4:	0ac000ef          	jal	ra,ffffffffc0204190 <printfmt>
ffffffffc02040e8:	bb9d                	j	ffffffffc0203e5e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02040ea:	00002617          	auipc	a2,0x2
ffffffffc02040ee:	03660613          	addi	a2,a2,54 # ffffffffc0206120 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02040f2:	00002417          	auipc	s0,0x2
ffffffffc02040f6:	02f40413          	addi	s0,s0,47 # ffffffffc0206121 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040fa:	8532                	mv	a0,a2
ffffffffc02040fc:	85e6                	mv	a1,s9
ffffffffc02040fe:	e032                	sd	a2,0(sp)
ffffffffc0204100:	e43e                	sd	a5,8(sp)
ffffffffc0204102:	18a000ef          	jal	ra,ffffffffc020428c <strnlen>
ffffffffc0204106:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020410a:	6602                	ld	a2,0(sp)
ffffffffc020410c:	01b05d63          	blez	s11,ffffffffc0204126 <vprintfmt+0x302>
ffffffffc0204110:	67a2                	ld	a5,8(sp)
ffffffffc0204112:	2781                	sext.w	a5,a5
ffffffffc0204114:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204116:	6522                	ld	a0,8(sp)
ffffffffc0204118:	85a6                	mv	a1,s1
ffffffffc020411a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020411c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020411e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204120:	6602                	ld	a2,0(sp)
ffffffffc0204122:	fe0d9ae3          	bnez	s11,ffffffffc0204116 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204126:	00064783          	lbu	a5,0(a2)
ffffffffc020412a:	0007851b          	sext.w	a0,a5
ffffffffc020412e:	e8051be3          	bnez	a0,ffffffffc0203fc4 <vprintfmt+0x1a0>
ffffffffc0204132:	b335                	j	ffffffffc0203e5e <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204134:	000aa403          	lw	s0,0(s5)
ffffffffc0204138:	bbf1                	j	ffffffffc0203f14 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020413a:	000ae603          	lwu	a2,0(s5)
ffffffffc020413e:	46a9                	li	a3,10
ffffffffc0204140:	8aae                	mv	s5,a1
ffffffffc0204142:	bd89                	j	ffffffffc0203f94 <vprintfmt+0x170>
ffffffffc0204144:	000ae603          	lwu	a2,0(s5)
ffffffffc0204148:	46c1                	li	a3,16
ffffffffc020414a:	8aae                	mv	s5,a1
ffffffffc020414c:	b5a1                	j	ffffffffc0203f94 <vprintfmt+0x170>
ffffffffc020414e:	000ae603          	lwu	a2,0(s5)
ffffffffc0204152:	46a1                	li	a3,8
ffffffffc0204154:	8aae                	mv	s5,a1
ffffffffc0204156:	bd3d                	j	ffffffffc0203f94 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204158:	9902                	jalr	s2
ffffffffc020415a:	b559                	j	ffffffffc0203fe0 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020415c:	85a6                	mv	a1,s1
ffffffffc020415e:	02d00513          	li	a0,45
ffffffffc0204162:	e03e                	sd	a5,0(sp)
ffffffffc0204164:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204166:	8ace                	mv	s5,s3
ffffffffc0204168:	40800633          	neg	a2,s0
ffffffffc020416c:	46a9                	li	a3,10
ffffffffc020416e:	6782                	ld	a5,0(sp)
ffffffffc0204170:	b515                	j	ffffffffc0203f94 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204172:	01b05663          	blez	s11,ffffffffc020417e <vprintfmt+0x35a>
ffffffffc0204176:	02d00693          	li	a3,45
ffffffffc020417a:	f6d798e3          	bne	a5,a3,ffffffffc02040ea <vprintfmt+0x2c6>
ffffffffc020417e:	00002417          	auipc	s0,0x2
ffffffffc0204182:	fa340413          	addi	s0,s0,-93 # ffffffffc0206121 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204186:	02800513          	li	a0,40
ffffffffc020418a:	02800793          	li	a5,40
ffffffffc020418e:	bd1d                	j	ffffffffc0203fc4 <vprintfmt+0x1a0>

ffffffffc0204190 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204190:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204192:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204196:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204198:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020419a:	ec06                	sd	ra,24(sp)
ffffffffc020419c:	f83a                	sd	a4,48(sp)
ffffffffc020419e:	fc3e                	sd	a5,56(sp)
ffffffffc02041a0:	e0c2                	sd	a6,64(sp)
ffffffffc02041a2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041a4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041a6:	c7fff0ef          	jal	ra,ffffffffc0203e24 <vprintfmt>
}
ffffffffc02041aa:	60e2                	ld	ra,24(sp)
ffffffffc02041ac:	6161                	addi	sp,sp,80
ffffffffc02041ae:	8082                	ret

ffffffffc02041b0 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041b0:	715d                	addi	sp,sp,-80
ffffffffc02041b2:	e486                	sd	ra,72(sp)
ffffffffc02041b4:	e0a2                	sd	s0,64(sp)
ffffffffc02041b6:	fc26                	sd	s1,56(sp)
ffffffffc02041b8:	f84a                	sd	s2,48(sp)
ffffffffc02041ba:	f44e                	sd	s3,40(sp)
ffffffffc02041bc:	f052                	sd	s4,32(sp)
ffffffffc02041be:	ec56                	sd	s5,24(sp)
ffffffffc02041c0:	e85a                	sd	s6,16(sp)
ffffffffc02041c2:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041c4:	c901                	beqz	a0,ffffffffc02041d4 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041c6:	85aa                	mv	a1,a0
ffffffffc02041c8:	00002517          	auipc	a0,0x2
ffffffffc02041cc:	f7050513          	addi	a0,a0,-144 # ffffffffc0206138 <error_string+0xe8>
ffffffffc02041d0:	eeffb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02041d4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041d6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041d8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041da:	4aa9                	li	s5,10
ffffffffc02041dc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02041de:	0000db97          	auipc	s7,0xd
ffffffffc02041e2:	e62b8b93          	addi	s7,s7,-414 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041e6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02041ea:	f0dfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041ee:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041f0:	00054b63          	bltz	a0,ffffffffc0204206 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041f4:	00a95b63          	ble	a0,s2,ffffffffc020420a <readline+0x5a>
ffffffffc02041f8:	029a5463          	ble	s1,s4,ffffffffc0204220 <readline+0x70>
        c = getchar();
ffffffffc02041fc:	efbfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204200:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204202:	fe0559e3          	bgez	a0,ffffffffc02041f4 <readline+0x44>
            return NULL;
ffffffffc0204206:	4501                	li	a0,0
ffffffffc0204208:	a099                	j	ffffffffc020424e <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020420a:	03341463          	bne	s0,s3,ffffffffc0204232 <readline+0x82>
ffffffffc020420e:	e8b9                	bnez	s1,ffffffffc0204264 <readline+0xb4>
        c = getchar();
ffffffffc0204210:	ee7fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204214:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204216:	fe0548e3          	bltz	a0,ffffffffc0204206 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020421a:	fea958e3          	ble	a0,s2,ffffffffc020420a <readline+0x5a>
ffffffffc020421e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204220:	8522                	mv	a0,s0
ffffffffc0204222:	ed1fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0204226:	009b87b3          	add	a5,s7,s1
ffffffffc020422a:	00878023          	sb	s0,0(a5)
ffffffffc020422e:	2485                	addiw	s1,s1,1
ffffffffc0204230:	bf6d                	j	ffffffffc02041ea <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204232:	01540463          	beq	s0,s5,ffffffffc020423a <readline+0x8a>
ffffffffc0204236:	fb641ae3          	bne	s0,s6,ffffffffc02041ea <readline+0x3a>
            cputchar(c);
ffffffffc020423a:	8522                	mv	a0,s0
ffffffffc020423c:	eb7fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204240:	0000d517          	auipc	a0,0xd
ffffffffc0204244:	e0050513          	addi	a0,a0,-512 # ffffffffc0211040 <buf>
ffffffffc0204248:	94aa                	add	s1,s1,a0
ffffffffc020424a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020424e:	60a6                	ld	ra,72(sp)
ffffffffc0204250:	6406                	ld	s0,64(sp)
ffffffffc0204252:	74e2                	ld	s1,56(sp)
ffffffffc0204254:	7942                	ld	s2,48(sp)
ffffffffc0204256:	79a2                	ld	s3,40(sp)
ffffffffc0204258:	7a02                	ld	s4,32(sp)
ffffffffc020425a:	6ae2                	ld	s5,24(sp)
ffffffffc020425c:	6b42                	ld	s6,16(sp)
ffffffffc020425e:	6ba2                	ld	s7,8(sp)
ffffffffc0204260:	6161                	addi	sp,sp,80
ffffffffc0204262:	8082                	ret
            cputchar(c);
ffffffffc0204264:	4521                	li	a0,8
ffffffffc0204266:	e8dfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020426a:	34fd                	addiw	s1,s1,-1
ffffffffc020426c:	bfbd                	j	ffffffffc02041ea <readline+0x3a>

ffffffffc020426e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020426e:	00054783          	lbu	a5,0(a0)
ffffffffc0204272:	cb91                	beqz	a5,ffffffffc0204286 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204274:	4781                	li	a5,0
        cnt ++;
ffffffffc0204276:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204278:	00f50733          	add	a4,a0,a5
ffffffffc020427c:	00074703          	lbu	a4,0(a4)
ffffffffc0204280:	fb7d                	bnez	a4,ffffffffc0204276 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204282:	853e                	mv	a0,a5
ffffffffc0204284:	8082                	ret
    size_t cnt = 0;
ffffffffc0204286:	4781                	li	a5,0
}
ffffffffc0204288:	853e                	mv	a0,a5
ffffffffc020428a:	8082                	ret

ffffffffc020428c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020428c:	c185                	beqz	a1,ffffffffc02042ac <strnlen+0x20>
ffffffffc020428e:	00054783          	lbu	a5,0(a0)
ffffffffc0204292:	cf89                	beqz	a5,ffffffffc02042ac <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204294:	4781                	li	a5,0
ffffffffc0204296:	a021                	j	ffffffffc020429e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204298:	00074703          	lbu	a4,0(a4)
ffffffffc020429c:	c711                	beqz	a4,ffffffffc02042a8 <strnlen+0x1c>
        cnt ++;
ffffffffc020429e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042a0:	00f50733          	add	a4,a0,a5
ffffffffc02042a4:	fef59ae3          	bne	a1,a5,ffffffffc0204298 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02042a8:	853e                	mv	a0,a5
ffffffffc02042aa:	8082                	ret
    size_t cnt = 0;
ffffffffc02042ac:	4781                	li	a5,0
}
ffffffffc02042ae:	853e                	mv	a0,a5
ffffffffc02042b0:	8082                	ret

ffffffffc02042b2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02042b2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02042b4:	0585                	addi	a1,a1,1
ffffffffc02042b6:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042ba:	0785                	addi	a5,a5,1
ffffffffc02042bc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042c0:	fb75                	bnez	a4,ffffffffc02042b4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042c2:	8082                	ret

ffffffffc02042c4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042c4:	00054783          	lbu	a5,0(a0)
ffffffffc02042c8:	0005c703          	lbu	a4,0(a1)
ffffffffc02042cc:	cb91                	beqz	a5,ffffffffc02042e0 <strcmp+0x1c>
ffffffffc02042ce:	00e79c63          	bne	a5,a4,ffffffffc02042e6 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042d2:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042d4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042d8:	0585                	addi	a1,a1,1
ffffffffc02042da:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042de:	fbe5                	bnez	a5,ffffffffc02042ce <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02042e0:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02042e2:	9d19                	subw	a0,a0,a4
ffffffffc02042e4:	8082                	ret
ffffffffc02042e6:	0007851b          	sext.w	a0,a5
ffffffffc02042ea:	9d19                	subw	a0,a0,a4
ffffffffc02042ec:	8082                	ret

ffffffffc02042ee <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02042ee:	00054783          	lbu	a5,0(a0)
ffffffffc02042f2:	cb91                	beqz	a5,ffffffffc0204306 <strchr+0x18>
        if (*s == c) {
ffffffffc02042f4:	00b79563          	bne	a5,a1,ffffffffc02042fe <strchr+0x10>
ffffffffc02042f8:	a809                	j	ffffffffc020430a <strchr+0x1c>
ffffffffc02042fa:	00b78763          	beq	a5,a1,ffffffffc0204308 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02042fe:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204300:	00054783          	lbu	a5,0(a0)
ffffffffc0204304:	fbfd                	bnez	a5,ffffffffc02042fa <strchr+0xc>
    }
    return NULL;
ffffffffc0204306:	4501                	li	a0,0
}
ffffffffc0204308:	8082                	ret
ffffffffc020430a:	8082                	ret

ffffffffc020430c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020430c:	ca01                	beqz	a2,ffffffffc020431c <memset+0x10>
ffffffffc020430e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204310:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204312:	0785                	addi	a5,a5,1
ffffffffc0204314:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204318:	fec79de3          	bne	a5,a2,ffffffffc0204312 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020431c:	8082                	ret

ffffffffc020431e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020431e:	ca19                	beqz	a2,ffffffffc0204334 <memcpy+0x16>
ffffffffc0204320:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204322:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204324:	0585                	addi	a1,a1,1
ffffffffc0204326:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020432a:	0785                	addi	a5,a5,1
ffffffffc020432c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204330:	fec59ae3          	bne	a1,a2,ffffffffc0204324 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204334:	8082                	ret
