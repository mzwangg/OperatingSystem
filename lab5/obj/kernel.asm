
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	ffa50513          	addi	a0,a0,-6 # ffffffffc02a1030 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	57a60613          	addi	a2,a2,1402 # ffffffffc02ac5b8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	742060ef          	jal	ra,ffffffffc0206790 <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	76a58593          	addi	a1,a1,1898 # ffffffffc02067c0 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	78250513          	addi	a0,a0,1922 # ffffffffc02067e0 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5c6020ef          	jal	ra,ffffffffc0202634 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ee000ef          	jal	ra,ffffffffc0200660 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	466040ef          	jal	ra,ffffffffc02044e0 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	6a3050ef          	jal	ra,ffffffffc0205f20 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	384030ef          	jal	ra,ffffffffc020340a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c6000ef          	jal	ra,ffffffffc0200654 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	7db050ef          	jal	ra,ffffffffc020606c <cpu_idle>

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
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	73a50513          	addi	a0,a0,1850 # ffffffffc02067e8 <etext+0x2e>
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
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	f6cb8b93          	addi	s7,s7,-148 # ffffffffc02a1030 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	136000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	124000ef          	jal	ra,ffffffffc0200206 <getchar>
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
ffffffffc02000f6:	110000ef          	jal	ra,ffffffffc0200206 <getchar>
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
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	f0a50513          	addi	a0,a0,-246 # ffffffffc02a1030 <edata>
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
ffffffffc020015c:	42e000ef          	jal	ra,ffffffffc020058a <cons_putc>
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
ffffffffc0200182:	1e4060ef          	jal	ra,ffffffffc0206366 <vprintfmt>
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
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02001b6:	1b0060ef          	jal	ra,ffffffffc0206366 <vprintfmt>
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
ffffffffc02001c2:	3c80006f          	j	ffffffffc020058a <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	e822                	sd	s0,16(sp)
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e426                	sd	s1,8(sp)
ffffffffc02001ce:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00054503          	lbu	a0,0(a0)
ffffffffc02001d4:	c51d                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	4485                	li	s1,1
ffffffffc02001da:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001dc:	3ae000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc02001e0:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e4:	0405                	addi	s0,s0,1
ffffffffc02001e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ea:	f96d                	bnez	a0,ffffffffc02001dc <cputs+0x16>
ffffffffc02001ec:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f0:	4529                	li	a0,10
ffffffffc02001f2:	398000ef          	jal	ra,ffffffffc020058a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f6:	8522                	mv	a0,s0
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	6442                	ld	s0,16(sp)
ffffffffc02001fc:	64a2                	ld	s1,8(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200202:	4405                	li	s0,1
ffffffffc0200204:	b7f5                	j	ffffffffc02001f0 <cputs+0x2a>

ffffffffc0200206 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200206:	1141                	addi	sp,sp,-16
ffffffffc0200208:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020a:	3b6000ef          	jal	ra,ffffffffc02005c0 <cons_getc>
ffffffffc020020e:	dd75                	beqz	a0,ffffffffc020020a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	0141                	addi	sp,sp,16
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200216:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	60850513          	addi	a0,a0,1544 # ffffffffc0206820 <etext+0x66>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	61250513          	addi	a0,a0,1554 # ffffffffc0206840 <etext+0x86>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	58058593          	addi	a1,a1,1408 # ffffffffc02067ba <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	61e50513          	addi	a0,a0,1566 # ffffffffc0206860 <etext+0xa6>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	de258593          	addi	a1,a1,-542 # ffffffffc02a1030 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206880 <etext+0xc6>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	35658593          	addi	a1,a1,854 # ffffffffc02ac5b8 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	63650513          	addi	a0,a0,1590 # ffffffffc02068a0 <etext+0xe6>
ffffffffc0200272:	f1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200276:	000ac597          	auipc	a1,0xac
ffffffffc020027a:	74158593          	addi	a1,a1,1857 # ffffffffc02ac9b7 <end+0x3ff>
ffffffffc020027e:	00000797          	auipc	a5,0x0
ffffffffc0200282:	db878793          	addi	a5,a5,-584 # ffffffffc0200036 <kern_init>
ffffffffc0200286:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200294:	95be                	add	a1,a1,a5
ffffffffc0200296:	85a9                	srai	a1,a1,0xa
ffffffffc0200298:	00006517          	auipc	a0,0x6
ffffffffc020029c:	62850513          	addi	a0,a0,1576 # ffffffffc02068c0 <etext+0x106>
}
ffffffffc02002a0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	eedff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02002a6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a8:	00006617          	auipc	a2,0x6
ffffffffc02002ac:	54860613          	addi	a2,a2,1352 # ffffffffc02067f0 <etext+0x36>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	55450513          	addi	a0,a0,1364 # ffffffffc0206808 <etext+0x4e>
void print_stackframe(void) {
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002be:	1c6000ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02002c2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c4:	00006617          	auipc	a2,0x6
ffffffffc02002c8:	70c60613          	addi	a2,a2,1804 # ffffffffc02069d0 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	72458593          	addi	a1,a1,1828 # ffffffffc02069f0 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	72450513          	addi	a0,a0,1828 # ffffffffc02069f8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	72660613          	addi	a2,a2,1830 # ffffffffc0206a08 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	74658593          	addi	a1,a1,1862 # ffffffffc0206a30 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	70650513          	addi	a0,a0,1798 # ffffffffc02069f8 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	74260613          	addi	a2,a2,1858 # ffffffffc0206a40 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	75a58593          	addi	a1,a1,1882 # ffffffffc0206a60 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	6ea50513          	addi	a0,a0,1770 # ffffffffc02069f8 <commands+0x108>
ffffffffc0200316:	e79ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200326:	ef1ff0ef          	jal	ra,ffffffffc0200216 <print_kerninfo>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200332:	1141                	addi	sp,sp,-16
ffffffffc0200334:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200336:	f71ff0ef          	jal	ra,ffffffffc02002a6 <print_stackframe>
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200342:	7115                	addi	sp,sp,-224
ffffffffc0200344:	e962                	sd	s8,144(sp)
ffffffffc0200346:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200348:	00006517          	auipc	a0,0x6
ffffffffc020034c:	5f050513          	addi	a0,a0,1520 # ffffffffc0206938 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200350:	ed86                	sd	ra,216(sp)
ffffffffc0200352:	e9a2                	sd	s0,208(sp)
ffffffffc0200354:	e5a6                	sd	s1,200(sp)
ffffffffc0200356:	e1ca                	sd	s2,192(sp)
ffffffffc0200358:	fd4e                	sd	s3,184(sp)
ffffffffc020035a:	f952                	sd	s4,176(sp)
ffffffffc020035c:	f556                	sd	s5,168(sp)
ffffffffc020035e:	f15a                	sd	s6,160(sp)
ffffffffc0200360:	ed5e                	sd	s7,152(sp)
ffffffffc0200362:	e566                	sd	s9,136(sp)
ffffffffc0200364:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200366:	e29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	5f650513          	addi	a0,a0,1526 # ffffffffc0206960 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4ce000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	570c8c93          	addi	s9,s9,1392 # ffffffffc02068f0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	60098993          	addi	s3,s3,1536 # ffffffffc0206988 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	60090913          	addi	s2,s2,1536 # ffffffffc0206990 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	5feb0b13          	addi	s6,s6,1534 # ffffffffc0206998 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	64ea8a93          	addi	s5,s5,1614 # ffffffffc02069f0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	854e                	mv	a0,s3
ffffffffc02003ae:	ce9ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003b2:	842a                	mv	s0,a0
ffffffffc02003b4:	dd65                	beqz	a0,ffffffffc02003ac <kmonitor+0x6a>
ffffffffc02003b6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ba:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	c999                	beqz	a1,ffffffffc02003d2 <kmonitor+0x90>
ffffffffc02003be:	854a                	mv	a0,s2
ffffffffc02003c0:	3b2060ef          	jal	ra,ffffffffc0206772 <strchr>
ffffffffc02003c4:	c925                	beqz	a0,ffffffffc0200434 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ca:	00040023          	sb	zero,0(s0)
ffffffffc02003ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	f5fd                	bnez	a1,ffffffffc02003be <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d2:	dce9                	beqz	s1,ffffffffc02003ac <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d4:	6582                	ld	a1,0(sp)
ffffffffc02003d6:	00006d17          	auipc	s10,0x6
ffffffffc02003da:	51ad0d13          	addi	s10,s10,1306 # ffffffffc02068f0 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	364060ef          	jal	ra,ffffffffc0206748 <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	350060ef          	jal	ra,ffffffffc0206748 <strcmp>
ffffffffc02003fc:	f57d                	bnez	a0,ffffffffc02003ea <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fe:	00141793          	slli	a5,s0,0x1
ffffffffc0200402:	97a2                	add	a5,a5,s0
ffffffffc0200404:	078e                	slli	a5,a5,0x3
ffffffffc0200406:	97e6                	add	a5,a5,s9
ffffffffc0200408:	6b9c                	ld	a5,16(a5)
ffffffffc020040a:	8662                	mv	a2,s8
ffffffffc020040c:	002c                	addi	a1,sp,8
ffffffffc020040e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200412:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200414:	f8055ce3          	bgez	a0,ffffffffc02003ac <kmonitor+0x6a>
}
ffffffffc0200418:	60ee                	ld	ra,216(sp)
ffffffffc020041a:	644e                	ld	s0,208(sp)
ffffffffc020041c:	64ae                	ld	s1,200(sp)
ffffffffc020041e:	690e                	ld	s2,192(sp)
ffffffffc0200420:	79ea                	ld	s3,184(sp)
ffffffffc0200422:	7a4a                	ld	s4,176(sp)
ffffffffc0200424:	7aaa                	ld	s5,168(sp)
ffffffffc0200426:	7b0a                	ld	s6,160(sp)
ffffffffc0200428:	6bea                	ld	s7,152(sp)
ffffffffc020042a:	6c4a                	ld	s8,144(sp)
ffffffffc020042c:	6caa                	ld	s9,136(sp)
ffffffffc020042e:	6d0a                	ld	s10,128(sp)
ffffffffc0200430:	612d                	addi	sp,sp,224
ffffffffc0200432:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200434:	00044783          	lbu	a5,0(s0)
ffffffffc0200438:	dfc9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043a:	03448863          	beq	s1,s4,ffffffffc020046a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043e:	00349793          	slli	a5,s1,0x3
ffffffffc0200442:	0118                	addi	a4,sp,128
ffffffffc0200444:	97ba                	add	a5,a5,a4
ffffffffc0200446:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200450:	e591                	bnez	a1,ffffffffc020045c <kmonitor+0x11a>
ffffffffc0200452:	b749                	j	ffffffffc02003d4 <kmonitor+0x92>
            buf ++;
ffffffffc0200454:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
ffffffffc020045a:	ddad                	beqz	a1,ffffffffc02003d4 <kmonitor+0x92>
ffffffffc020045c:	854a                	mv	a0,s2
ffffffffc020045e:	314060ef          	jal	ra,ffffffffc0206772 <strchr>
ffffffffc0200462:	d96d                	beqz	a0,ffffffffc0200454 <kmonitor+0x112>
ffffffffc0200464:	00044583          	lbu	a1,0(s0)
ffffffffc0200468:	bf91                	j	ffffffffc02003bc <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046a:	45c1                	li	a1,16
ffffffffc020046c:	855a                	mv	a0,s6
ffffffffc020046e:	d21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200472:	b7f1                	j	ffffffffc020043e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006517          	auipc	a0,0x6
ffffffffc020047a:	54250513          	addi	a0,a0,1346 # ffffffffc02069b8 <commands+0xc8>
ffffffffc020047e:	d11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc0200482:	b72d                	j	ffffffffc02003ac <kmonitor+0x6a>

ffffffffc0200484 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200484:	000ac317          	auipc	t1,0xac
ffffffffc0200488:	fac30313          	addi	t1,t1,-84 # ffffffffc02ac430 <is_panic>
ffffffffc020048c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200490:	715d                	addi	sp,sp,-80
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e822                	sd	s0,16(sp)
ffffffffc0200496:	f436                	sd	a3,40(sp)
ffffffffc0200498:	f83a                	sd	a4,48(sp)
ffffffffc020049a:	fc3e                	sd	a5,56(sp)
ffffffffc020049c:	e0c2                	sd	a6,64(sp)
ffffffffc020049e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a0:	02031c63          	bnez	t1,ffffffffc02004d8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a4:	4785                	li	a5,1
ffffffffc02004a6:	8432                	mv	s0,a2
ffffffffc02004a8:	000ac717          	auipc	a4,0xac
ffffffffc02004ac:	f8f73423          	sd	a5,-120(a4) # ffffffffc02ac430 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	85aa                	mv	a1,a0
ffffffffc02004b6:	00006517          	auipc	a0,0x6
ffffffffc02004ba:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206a70 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c0:	ccfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c4:	65a2                	ld	a1,8(sp)
ffffffffc02004c6:	8522                	mv	a0,s0
ffffffffc02004c8:	ca7ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004cc:	00007517          	auipc	a0,0x7
ffffffffc02004d0:	58c50513          	addi	a0,a0,1420 # ffffffffc0207a58 <default_pmm_manager+0x560>
ffffffffc02004d4:	cbbff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	48a1                	li	a7,8
ffffffffc02004e0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e4:	176000ef          	jal	ra,ffffffffc020065a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e8:	4501                	li	a0,0
ffffffffc02004ea:	e59ff0ef          	jal	ra,ffffffffc0200342 <kmonitor>
ffffffffc02004ee:	bfed                	j	ffffffffc02004e8 <__panic+0x64>

ffffffffc02004f0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f0:	715d                	addi	sp,sp,-80
ffffffffc02004f2:	e822                	sd	s0,16(sp)
ffffffffc02004f4:	fc3e                	sd	a5,56(sp)
ffffffffc02004f6:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f8:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fa:	862e                	mv	a2,a1
ffffffffc02004fc:	85aa                	mv	a1,a0
ffffffffc02004fe:	00006517          	auipc	a0,0x6
ffffffffc0200502:	59250513          	addi	a0,a0,1426 # ffffffffc0206a90 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200506:	ec06                	sd	ra,24(sp)
ffffffffc0200508:	f436                	sd	a3,40(sp)
ffffffffc020050a:	f83a                	sd	a4,48(sp)
ffffffffc020050c:	e0c2                	sd	a6,64(sp)
ffffffffc020050e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200510:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200512:	c7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200516:	65a2                	ld	a1,8(sp)
ffffffffc0200518:	8522                	mv	a0,s0
ffffffffc020051a:	c55ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051e:	00007517          	auipc	a0,0x7
ffffffffc0200522:	53a50513          	addi	a0,a0,1338 # ffffffffc0207a58 <default_pmm_manager+0x560>
ffffffffc0200526:	c69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc020052a:	60e2                	ld	ra,24(sp)
ffffffffc020052c:	6442                	ld	s0,16(sp)
ffffffffc020052e:	6161                	addi	sp,sp,80
ffffffffc0200530:	8082                	ret

ffffffffc0200532 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200532:	67e1                	lui	a5,0x18
ffffffffc0200534:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc20>
ffffffffc0200538:	000ac717          	auipc	a4,0xac
ffffffffc020053c:	f0f73023          	sd	a5,-256(a4) # ffffffffc02ac438 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200540:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200544:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	953e                	add	a0,a0,a5
ffffffffc0200548:	4601                	li	a2,0
ffffffffc020054a:	4881                	li	a7,0
ffffffffc020054c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200550:	02000793          	li	a5,32
ffffffffc0200554:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	00006517          	auipc	a0,0x6
ffffffffc020055c:	55850513          	addi	a0,a0,1368 # ffffffffc0206ab0 <commands+0x1c0>
    ticks = 0;
ffffffffc0200560:	000ac797          	auipc	a5,0xac
ffffffffc0200564:	f207b423          	sd	zero,-216(a5) # ffffffffc02ac488 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200568:	c27ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020056c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200570:	000ac797          	auipc	a5,0xac
ffffffffc0200574:	ec878793          	addi	a5,a5,-312 # ffffffffc02ac438 <timebase>
ffffffffc0200578:	639c                	ld	a5,0(a5)
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4881                	li	a7,0
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200588:	8082                	ret

ffffffffc020058a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058a:	100027f3          	csrr	a5,sstatus
ffffffffc020058e:	8b89                	andi	a5,a5,2
ffffffffc0200590:	0ff57513          	andi	a0,a0,255
ffffffffc0200594:	e799                	bnez	a5,ffffffffc02005a2 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4885                	li	a7,1
ffffffffc020059c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005a0:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a2:	1101                	addi	sp,sp,-32
ffffffffc02005a4:	ec06                	sd	ra,24(sp)
ffffffffc02005a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a8:	0b2000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4885                	li	a7,1
ffffffffc02005b4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b8:	60e2                	ld	ra,24(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005bc:	0980006f          	j	ffffffffc0200654 <intr_enable>

ffffffffc02005c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005c0:	100027f3          	csrr	a5,sstatus
ffffffffc02005c4:	8b89                	andi	a5,a5,2
ffffffffc02005c6:	eb89                	bnez	a5,ffffffffc02005d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d6:	8082                	ret
int cons_getc(void) {
ffffffffc02005d8:	1101                	addi	sp,sp,-32
ffffffffc02005da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005dc:	07e000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005e0:	4501                	li	a0,0
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4889                	li	a7,2
ffffffffc02005e8:	00000073          	ecall
ffffffffc02005ec:	2501                	sext.w	a0,a0
ffffffffc02005ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f0:	064000ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc02005f4:	60e2                	ld	ra,24(sp)
ffffffffc02005f6:	6522                	ld	a0,8(sp)
ffffffffc02005f8:	6105                	addi	sp,sp,32
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005fe:	00253513          	sltiu	a0,a0,2
ffffffffc0200602:	8082                	ret

ffffffffc0200604 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200604:	03800513          	li	a0,56
ffffffffc0200608:	8082                	ret

ffffffffc020060a <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	000a1797          	auipc	a5,0xa1
ffffffffc020060e:	e2678793          	addi	a5,a5,-474 # ffffffffc02a1430 <ide>
ffffffffc0200612:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200616:	1141                	addi	sp,sp,-16
ffffffffc0200618:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	95be                	add	a1,a1,a5
ffffffffc020061c:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200620:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200622:	180060ef          	jal	ra,ffffffffc02067a2 <memcpy>
    return 0;
}
ffffffffc0200626:	60a2                	ld	ra,8(sp)
ffffffffc0200628:	4501                	li	a0,0
ffffffffc020062a:	0141                	addi	sp,sp,16
ffffffffc020062c:	8082                	ret

ffffffffc020062e <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020062e:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200630:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200634:	000a1517          	auipc	a0,0xa1
ffffffffc0200638:	dfc50513          	addi	a0,a0,-516 # ffffffffc02a1430 <ide>
                   size_t nsecs) {
ffffffffc020063c:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020063e:	00969613          	slli	a2,a3,0x9
ffffffffc0200642:	85ba                	mv	a1,a4
ffffffffc0200644:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200646:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200648:	15a060ef          	jal	ra,ffffffffc02067a2 <memcpy>
    return 0;
}
ffffffffc020064c:	60a2                	ld	ra,8(sp)
ffffffffc020064e:	4501                	li	a0,0
ffffffffc0200650:	0141                	addi	sp,sp,16
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020065e:	8082                	ret

ffffffffc0200660 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	77450513          	addi	a0,a0,1908 # ffffffffc0206df8 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	b01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	77c50513          	addi	a0,a0,1916 # ffffffffc0206e10 <commands+0x520>
ffffffffc020069c:	af3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	78650513          	addi	a0,a0,1926 # ffffffffc0206e28 <commands+0x538>
ffffffffc02006aa:	ae5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	79050513          	addi	a0,a0,1936 # ffffffffc0206e40 <commands+0x550>
ffffffffc02006b8:	ad7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	79a50513          	addi	a0,a0,1946 # ffffffffc0206e58 <commands+0x568>
ffffffffc02006c6:	ac9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	7a450513          	addi	a0,a0,1956 # ffffffffc0206e70 <commands+0x580>
ffffffffc02006d4:	abbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	7ae50513          	addi	a0,a0,1966 # ffffffffc0206e88 <commands+0x598>
ffffffffc02006e2:	aadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	7b850513          	addi	a0,a0,1976 # ffffffffc0206ea0 <commands+0x5b0>
ffffffffc02006f0:	a9fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	7c250513          	addi	a0,a0,1986 # ffffffffc0206eb8 <commands+0x5c8>
ffffffffc02006fe:	a91ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	7cc50513          	addi	a0,a0,1996 # ffffffffc0206ed0 <commands+0x5e0>
ffffffffc020070c:	a83ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	7d650513          	addi	a0,a0,2006 # ffffffffc0206ee8 <commands+0x5f8>
ffffffffc020071a:	a75ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	7e050513          	addi	a0,a0,2016 # ffffffffc0206f00 <commands+0x610>
ffffffffc0200728:	a67ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206f18 <commands+0x628>
ffffffffc0200736:	a59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	7f450513          	addi	a0,a0,2036 # ffffffffc0206f30 <commands+0x640>
ffffffffc0200744:	a4bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206f48 <commands+0x658>
ffffffffc0200752:	a3dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00007517          	auipc	a0,0x7
ffffffffc020075c:	80850513          	addi	a0,a0,-2040 # ffffffffc0206f60 <commands+0x670>
ffffffffc0200760:	a2fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00007517          	auipc	a0,0x7
ffffffffc020076a:	81250513          	addi	a0,a0,-2030 # ffffffffc0206f78 <commands+0x688>
ffffffffc020076e:	a21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00007517          	auipc	a0,0x7
ffffffffc0200778:	81c50513          	addi	a0,a0,-2020 # ffffffffc0206f90 <commands+0x6a0>
ffffffffc020077c:	a13ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00007517          	auipc	a0,0x7
ffffffffc0200786:	82650513          	addi	a0,a0,-2010 # ffffffffc0206fa8 <commands+0x6b8>
ffffffffc020078a:	a05ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00007517          	auipc	a0,0x7
ffffffffc0200794:	83050513          	addi	a0,a0,-2000 # ffffffffc0206fc0 <commands+0x6d0>
ffffffffc0200798:	9f7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00007517          	auipc	a0,0x7
ffffffffc02007a2:	83a50513          	addi	a0,a0,-1990 # ffffffffc0206fd8 <commands+0x6e8>
ffffffffc02007a6:	9e9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00007517          	auipc	a0,0x7
ffffffffc02007b0:	84450513          	addi	a0,a0,-1980 # ffffffffc0206ff0 <commands+0x700>
ffffffffc02007b4:	9dbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00007517          	auipc	a0,0x7
ffffffffc02007be:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207008 <commands+0x718>
ffffffffc02007c2:	9cdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00007517          	auipc	a0,0x7
ffffffffc02007cc:	85850513          	addi	a0,a0,-1960 # ffffffffc0207020 <commands+0x730>
ffffffffc02007d0:	9bfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00007517          	auipc	a0,0x7
ffffffffc02007da:	86250513          	addi	a0,a0,-1950 # ffffffffc0207038 <commands+0x748>
ffffffffc02007de:	9b1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00007517          	auipc	a0,0x7
ffffffffc02007e8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0207050 <commands+0x760>
ffffffffc02007ec:	9a3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00007517          	auipc	a0,0x7
ffffffffc02007f6:	87650513          	addi	a0,a0,-1930 # ffffffffc0207068 <commands+0x778>
ffffffffc02007fa:	995ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00007517          	auipc	a0,0x7
ffffffffc0200804:	88050513          	addi	a0,a0,-1920 # ffffffffc0207080 <commands+0x790>
ffffffffc0200808:	987ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00007517          	auipc	a0,0x7
ffffffffc0200812:	88a50513          	addi	a0,a0,-1910 # ffffffffc0207098 <commands+0x7a8>
ffffffffc0200816:	979ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00007517          	auipc	a0,0x7
ffffffffc0200820:	89450513          	addi	a0,a0,-1900 # ffffffffc02070b0 <commands+0x7c0>
ffffffffc0200824:	96bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00007517          	auipc	a0,0x7
ffffffffc020082e:	89e50513          	addi	a0,a0,-1890 # ffffffffc02070c8 <commands+0x7d8>
ffffffffc0200832:	95dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00007517          	auipc	a0,0x7
ffffffffc0200840:	8a450513          	addi	a0,a0,-1884 # ffffffffc02070e0 <commands+0x7f0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	949ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00007517          	auipc	a0,0x7
ffffffffc0200856:	8a650513          	addi	a0,a0,-1882 # ffffffffc02070f8 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	933ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00007517          	auipc	a0,0x7
ffffffffc020086e:	8a650513          	addi	a0,a0,-1882 # ffffffffc0207110 <commands+0x820>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00007517          	auipc	a0,0x7
ffffffffc020087e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207128 <commands+0x838>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00007517          	auipc	a0,0x7
ffffffffc020088e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207140 <commands+0x850>
ffffffffc0200892:	8fdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00007517          	auipc	a0,0x7
ffffffffc02008a2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0207150 <commands+0x860>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	8e7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	cf048493          	addi	s1,s1,-784 # ffffffffc02ac5a0 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	49250513          	addi	a0,a0,1170 # ffffffffc0206d78 <commands+0x488>
ffffffffc02008ee:	8a1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	b7278793          	addi	a5,a5,-1166 # ffffffffc02ac468 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	b7078793          	addi	a5,a5,-1168 # ffffffffc02ac470 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	1080406f          	j	ffffffffc0204a26 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	b3278793          	addi	a5,a5,-1230 # ffffffffc02ac468 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	0d20406f          	j	ffffffffc0204a26 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	44068693          	addi	a3,a3,1088 # ffffffffc0206d98 <commands+0x4a8>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	45060613          	addi	a2,a2,1104 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	45c50513          	addi	a0,a0,1116 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc0200974:	b11ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	3d650513          	addi	a0,a0,982 # ffffffffc0206d78 <commands+0x488>
ffffffffc02009aa:	fe4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	43260613          	addi	a2,a2,1074 # ffffffffc0206de0 <commands+0x4f0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	40e50513          	addi	a0,a0,1038 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc02009c2:	ac3ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	0f070713          	addi	a4,a4,240 # ffffffffc0206acc <commands+0x1dc>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	34a50513          	addi	a0,a0,842 # ffffffffc0206d38 <commands+0x448>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	31e50513          	addi	a0,a0,798 # ffffffffc0206d18 <commands+0x428>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	2d250513          	addi	a0,a0,722 # ffffffffc0206cd8 <commands+0x3e8>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	2e650513          	addi	a0,a0,742 # ffffffffc0206cf8 <commands+0x408>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	33a50513          	addi	a0,a0,826 # ffffffffc0206d58 <commands+0x468>
ffffffffc0200a26:	f68ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b3fff0ef          	jal	ra,ffffffffc020056c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	a5678793          	addi	a5,a5,-1450 # ffffffffc02ac488 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	a4f6b123          	sd	a5,-1470(a3) # ffffffffc02ac488 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	a1878793          	addi	a5,a5,-1512 # ffffffffc02ac468 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	08870713          	addi	a4,a4,136 # ffffffffc0206afc <commands+0x20c>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	1a050513          	addi	a0,a0,416 # ffffffffc0206c30 <commands+0x340>
ffffffffc0200a98:	ef6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	7b40506f          	j	ffffffffc0206262 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	19e50513          	addi	a0,a0,414 # ffffffffc0206c50 <commands+0x360>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	eccff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	1aa50513          	addi	a0,a0,426 # ffffffffc0206c70 <commands+0x380>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	1c050513          	addi	a0,a0,448 # ffffffffc0206c90 <commands+0x3a0>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	1ce50513          	addi	a0,a0,462 # ffffffffc0206ca8 <commands+0x3b8>
ffffffffc0200ae2:	eacff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	1c450513          	addi	a0,a0,452 # ffffffffc0206cc0 <commands+0x3d0>
ffffffffc0200b04:	e8aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	0c660613          	addi	a2,a2,198 # ffffffffc0206be0 <commands+0x2f0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	2a250513          	addi	a0,a0,674 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc0200b2e:	957ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	00e50513          	addi	a0,a0,14 # ffffffffc0206b40 <commands+0x250>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	02450513          	addi	a0,a0,36 # ffffffffc0206b60 <commands+0x270>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	03a50513          	addi	a0,a0,58 # ffffffffc0206b80 <commands+0x290>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	04850513          	addi	a0,a0,72 # ffffffffc0206b98 <commands+0x2a8>
ffffffffc0200b58:	e36ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	6f4050ef          	jal	ra,ffffffffc0206262 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	8f678793          	addi	a5,a5,-1802 # ffffffffc02ac468 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	01850513          	addi	a0,a0,24 # ffffffffc0206ba8 <commands+0x2b8>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	02e50513          	addi	a0,a0,46 # ffffffffc0206bc8 <commands+0x2d8>
ffffffffc0200ba2:	decff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	02860613          	addi	a2,a2,40 # ffffffffc0206be0 <commands+0x2f0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	20450513          	addi	a0,a0,516 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc0200bcc:	8b9ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	04850513          	addi	a0,a0,72 # ffffffffc0206c18 <commands+0x328>
ffffffffc0200bd8:	db6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	ff060613          	addi	a2,a2,-16 # ffffffffc0206be0 <commands+0x2f0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	1cc50513          	addi	a0,a0,460 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc0200c04:	881ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	fec60613          	addi	a2,a2,-20 # ffffffffc0206c00 <commands+0x310>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	1a850513          	addi	a0,a0,424 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc0200c28:	85dff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	fa860613          	addi	a2,a2,-88 # ffffffffc0206be0 <commands+0x2f0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	18450513          	addi	a0,a0,388 # ffffffffc0206dc8 <commands+0x4d8>
ffffffffc0200c4c:	839ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ac417          	auipc	s0,0xac
ffffffffc0200c58:	81440413          	addi	s0,s0,-2028 # ffffffffc02ac468 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	49c0506f          	j	ffffffffc020616c <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	091040ef          	jal	ra,ffffffffc0205566 <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e56:	000ab797          	auipc	a5,0xab
ffffffffc0200e5a:	63a78793          	addi	a5,a5,1594 # ffffffffc02ac490 <free_area>
ffffffffc0200e5e:	e79c                	sd	a5,8(a5)
ffffffffc0200e60:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e62:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e66:	8082                	ret

ffffffffc0200e68 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e68:	000ab517          	auipc	a0,0xab
ffffffffc0200e6c:	63856503          	lwu	a0,1592(a0) # ffffffffc02ac4a0 <free_area+0x10>
ffffffffc0200e70:	8082                	ret

ffffffffc0200e72 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e72:	715d                	addi	sp,sp,-80
ffffffffc0200e74:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e76:	000ab917          	auipc	s2,0xab
ffffffffc0200e7a:	61a90913          	addi	s2,s2,1562 # ffffffffc02ac490 <free_area>
ffffffffc0200e7e:	00893783          	ld	a5,8(s2)
ffffffffc0200e82:	e486                	sd	ra,72(sp)
ffffffffc0200e84:	e0a2                	sd	s0,64(sp)
ffffffffc0200e86:	fc26                	sd	s1,56(sp)
ffffffffc0200e88:	f44e                	sd	s3,40(sp)
ffffffffc0200e8a:	f052                	sd	s4,32(sp)
ffffffffc0200e8c:	ec56                	sd	s5,24(sp)
ffffffffc0200e8e:	e85a                	sd	s6,16(sp)
ffffffffc0200e90:	e45e                	sd	s7,8(sp)
ffffffffc0200e92:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e94:	31278463          	beq	a5,s2,ffffffffc020119c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e98:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e9c:	8305                	srli	a4,a4,0x1
ffffffffc0200e9e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ea0:	30070263          	beqz	a4,ffffffffc02011a4 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200ea4:	4401                	li	s0,0
ffffffffc0200ea6:	4481                	li	s1,0
ffffffffc0200ea8:	a031                	j	ffffffffc0200eb4 <default_check+0x42>
ffffffffc0200eaa:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200eae:	8b09                	andi	a4,a4,2
ffffffffc0200eb0:	2e070a63          	beqz	a4,ffffffffc02011a4 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200eb4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200eb8:	679c                	ld	a5,8(a5)
ffffffffc0200eba:	2485                	addiw	s1,s1,1
ffffffffc0200ebc:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ebe:	ff2796e3          	bne	a5,s2,ffffffffc0200eaa <default_check+0x38>
ffffffffc0200ec2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ec4:	05c010ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0200ec8:	73351e63          	bne	a0,s3,ffffffffc0201604 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ecc:	4505                	li	a0,1
ffffffffc0200ece:	785000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ed2:	8a2a                	mv	s4,a0
ffffffffc0200ed4:	46050863          	beqz	a0,ffffffffc0201344 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ed8:	4505                	li	a0,1
ffffffffc0200eda:	779000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ede:	89aa                	mv	s3,a0
ffffffffc0200ee0:	74050263          	beqz	a0,ffffffffc0201624 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ee4:	4505                	li	a0,1
ffffffffc0200ee6:	76d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200eea:	8aaa                	mv	s5,a0
ffffffffc0200eec:	4c050c63          	beqz	a0,ffffffffc02013c4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ef0:	2d3a0a63          	beq	s4,s3,ffffffffc02011c4 <default_check+0x352>
ffffffffc0200ef4:	2caa0863          	beq	s4,a0,ffffffffc02011c4 <default_check+0x352>
ffffffffc0200ef8:	2ca98663          	beq	s3,a0,ffffffffc02011c4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200efc:	000a2783          	lw	a5,0(s4)
ffffffffc0200f00:	2e079263          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
ffffffffc0200f04:	0009a783          	lw	a5,0(s3)
ffffffffc0200f08:	2c079e63          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
ffffffffc0200f0c:	411c                	lw	a5,0(a0)
ffffffffc0200f0e:	2c079b63          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f12:	000ab797          	auipc	a5,0xab
ffffffffc0200f16:	5ae78793          	addi	a5,a5,1454 # ffffffffc02ac4c0 <pages>
ffffffffc0200f1a:	639c                	ld	a5,0(a5)
ffffffffc0200f1c:	00008717          	auipc	a4,0x8
ffffffffc0200f20:	fcc70713          	addi	a4,a4,-52 # ffffffffc0208ee8 <nbase>
ffffffffc0200f24:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f26:	000ab717          	auipc	a4,0xab
ffffffffc0200f2a:	52a70713          	addi	a4,a4,1322 # ffffffffc02ac450 <npage>
ffffffffc0200f2e:	6314                	ld	a3,0(a4)
ffffffffc0200f30:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f34:	8719                	srai	a4,a4,0x6
ffffffffc0200f36:	9732                	add	a4,a4,a2
ffffffffc0200f38:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f3a:	0732                	slli	a4,a4,0xc
ffffffffc0200f3c:	2cd77463          	bleu	a3,a4,ffffffffc0201204 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f40:	40f98733          	sub	a4,s3,a5
ffffffffc0200f44:	8719                	srai	a4,a4,0x6
ffffffffc0200f46:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f48:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f4a:	4ed77d63          	bleu	a3,a4,ffffffffc0201444 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f4e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f52:	8799                	srai	a5,a5,0x6
ffffffffc0200f54:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f56:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f58:	34d7f663          	bleu	a3,a5,ffffffffc02012a4 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f5c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f5e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f62:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f66:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f6a:	000ab797          	auipc	a5,0xab
ffffffffc0200f6e:	5327b723          	sd	s2,1326(a5) # ffffffffc02ac498 <free_area+0x8>
ffffffffc0200f72:	000ab797          	auipc	a5,0xab
ffffffffc0200f76:	5127bf23          	sd	s2,1310(a5) # ffffffffc02ac490 <free_area>
    nr_free = 0;
ffffffffc0200f7a:	000ab797          	auipc	a5,0xab
ffffffffc0200f7e:	5207a323          	sw	zero,1318(a5) # ffffffffc02ac4a0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	6d1000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200f86:	2e051f63          	bnez	a0,ffffffffc0201284 <default_check+0x412>
    free_page(p0);
ffffffffc0200f8a:	4585                	li	a1,1
ffffffffc0200f8c:	8552                	mv	a0,s4
ffffffffc0200f8e:	74d000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p1);
ffffffffc0200f92:	4585                	li	a1,1
ffffffffc0200f94:	854e                	mv	a0,s3
ffffffffc0200f96:	745000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc0200f9a:	4585                	li	a1,1
ffffffffc0200f9c:	8556                	mv	a0,s5
ffffffffc0200f9e:	73d000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(nr_free == 3);
ffffffffc0200fa2:	01092703          	lw	a4,16(s2)
ffffffffc0200fa6:	478d                	li	a5,3
ffffffffc0200fa8:	2af71e63          	bne	a4,a5,ffffffffc0201264 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fac:	4505                	li	a0,1
ffffffffc0200fae:	6a5000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fb2:	89aa                	mv	s3,a0
ffffffffc0200fb4:	28050863          	beqz	a0,ffffffffc0201244 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	699000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fbe:	8aaa                	mv	s5,a0
ffffffffc0200fc0:	3e050263          	beqz	a0,ffffffffc02013a4 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fc4:	4505                	li	a0,1
ffffffffc0200fc6:	68d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fca:	8a2a                	mv	s4,a0
ffffffffc0200fcc:	3a050c63          	beqz	a0,ffffffffc0201384 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	681000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fd6:	38051763          	bnez	a0,ffffffffc0201364 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fda:	4585                	li	a1,1
ffffffffc0200fdc:	854e                	mv	a0,s3
ffffffffc0200fde:	6fd000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fe2:	00893783          	ld	a5,8(s2)
ffffffffc0200fe6:	23278f63          	beq	a5,s2,ffffffffc0201224 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fea:	4505                	li	a0,1
ffffffffc0200fec:	667000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ff0:	32a99a63          	bne	s3,a0,ffffffffc0201324 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200ff4:	4505                	li	a0,1
ffffffffc0200ff6:	65d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ffa:	30051563          	bnez	a0,ffffffffc0201304 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200ffe:	01092783          	lw	a5,16(s2)
ffffffffc0201002:	2e079163          	bnez	a5,ffffffffc02012e4 <default_check+0x472>
    free_page(p);
ffffffffc0201006:	854e                	mv	a0,s3
ffffffffc0201008:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020100a:	000ab797          	auipc	a5,0xab
ffffffffc020100e:	4987b323          	sd	s8,1158(a5) # ffffffffc02ac490 <free_area>
ffffffffc0201012:	000ab797          	auipc	a5,0xab
ffffffffc0201016:	4977b323          	sd	s7,1158(a5) # ffffffffc02ac498 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020101a:	000ab797          	auipc	a5,0xab
ffffffffc020101e:	4967a323          	sw	s6,1158(a5) # ffffffffc02ac4a0 <free_area+0x10>
    free_page(p);
ffffffffc0201022:	6b9000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p1);
ffffffffc0201026:	4585                	li	a1,1
ffffffffc0201028:	8556                	mv	a0,s5
ffffffffc020102a:	6b1000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc020102e:	4585                	li	a1,1
ffffffffc0201030:	8552                	mv	a0,s4
ffffffffc0201032:	6a9000ef          	jal	ra,ffffffffc0201eda <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201036:	4515                	li	a0,5
ffffffffc0201038:	61b000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020103c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020103e:	28050363          	beqz	a0,ffffffffc02012c4 <default_check+0x452>
ffffffffc0201042:	651c                	ld	a5,8(a0)
ffffffffc0201044:	8385                	srli	a5,a5,0x1
ffffffffc0201046:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201048:	54079e63          	bnez	a5,ffffffffc02015a4 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020104c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020104e:	00093b03          	ld	s6,0(s2)
ffffffffc0201052:	00893a83          	ld	s5,8(s2)
ffffffffc0201056:	000ab797          	auipc	a5,0xab
ffffffffc020105a:	4327bd23          	sd	s2,1082(a5) # ffffffffc02ac490 <free_area>
ffffffffc020105e:	000ab797          	auipc	a5,0xab
ffffffffc0201062:	4327bd23          	sd	s2,1082(a5) # ffffffffc02ac498 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201066:	5ed000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020106a:	50051d63          	bnez	a0,ffffffffc0201584 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020106e:	08098a13          	addi	s4,s3,128
ffffffffc0201072:	8552                	mv	a0,s4
ffffffffc0201074:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201076:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020107a:	000ab797          	auipc	a5,0xab
ffffffffc020107e:	4207a323          	sw	zero,1062(a5) # ffffffffc02ac4a0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201082:	659000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201086:	4511                	li	a0,4
ffffffffc0201088:	5cb000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020108c:	4c051c63          	bnez	a0,ffffffffc0201564 <default_check+0x6f2>
ffffffffc0201090:	0889b783          	ld	a5,136(s3)
ffffffffc0201094:	8385                	srli	a5,a5,0x1
ffffffffc0201096:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201098:	4a078663          	beqz	a5,ffffffffc0201544 <default_check+0x6d2>
ffffffffc020109c:	0909a703          	lw	a4,144(s3)
ffffffffc02010a0:	478d                	li	a5,3
ffffffffc02010a2:	4af71163          	bne	a4,a5,ffffffffc0201544 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010a6:	450d                	li	a0,3
ffffffffc02010a8:	5ab000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02010ac:	8c2a                	mv	s8,a0
ffffffffc02010ae:	46050b63          	beqz	a0,ffffffffc0201524 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010b2:	4505                	li	a0,1
ffffffffc02010b4:	59f000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02010b8:	44051663          	bnez	a0,ffffffffc0201504 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010bc:	438a1463          	bne	s4,s8,ffffffffc02014e4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010c0:	4585                	li	a1,1
ffffffffc02010c2:	854e                	mv	a0,s3
ffffffffc02010c4:	617000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_pages(p1, 3);
ffffffffc02010c8:	458d                	li	a1,3
ffffffffc02010ca:	8552                	mv	a0,s4
ffffffffc02010cc:	60f000ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc02010d0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010d4:	04098c13          	addi	s8,s3,64
ffffffffc02010d8:	8385                	srli	a5,a5,0x1
ffffffffc02010da:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010dc:	3e078463          	beqz	a5,ffffffffc02014c4 <default_check+0x652>
ffffffffc02010e0:	0109a703          	lw	a4,16(s3)
ffffffffc02010e4:	4785                	li	a5,1
ffffffffc02010e6:	3cf71f63          	bne	a4,a5,ffffffffc02014c4 <default_check+0x652>
ffffffffc02010ea:	008a3783          	ld	a5,8(s4)
ffffffffc02010ee:	8385                	srli	a5,a5,0x1
ffffffffc02010f0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010f2:	3a078963          	beqz	a5,ffffffffc02014a4 <default_check+0x632>
ffffffffc02010f6:	010a2703          	lw	a4,16(s4)
ffffffffc02010fa:	478d                	li	a5,3
ffffffffc02010fc:	3af71463          	bne	a4,a5,ffffffffc02014a4 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201100:	4505                	li	a0,1
ffffffffc0201102:	551000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201106:	36a99f63          	bne	s3,a0,ffffffffc0201484 <default_check+0x612>
    free_page(p0);
ffffffffc020110a:	4585                	li	a1,1
ffffffffc020110c:	5cf000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201110:	4509                	li	a0,2
ffffffffc0201112:	541000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201116:	34aa1763          	bne	s4,a0,ffffffffc0201464 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020111a:	4589                	li	a1,2
ffffffffc020111c:	5bf000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc0201120:	4585                	li	a1,1
ffffffffc0201122:	8562                	mv	a0,s8
ffffffffc0201124:	5b7000ef          	jal	ra,ffffffffc0201eda <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201128:	4515                	li	a0,5
ffffffffc020112a:	529000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020112e:	89aa                	mv	s3,a0
ffffffffc0201130:	48050a63          	beqz	a0,ffffffffc02015c4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201134:	4505                	li	a0,1
ffffffffc0201136:	51d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020113a:	2e051563          	bnez	a0,ffffffffc0201424 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020113e:	01092783          	lw	a5,16(s2)
ffffffffc0201142:	2c079163          	bnez	a5,ffffffffc0201404 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201146:	4595                	li	a1,5
ffffffffc0201148:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020114a:	000ab797          	auipc	a5,0xab
ffffffffc020114e:	3577ab23          	sw	s7,854(a5) # ffffffffc02ac4a0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201152:	000ab797          	auipc	a5,0xab
ffffffffc0201156:	3367bf23          	sd	s6,830(a5) # ffffffffc02ac490 <free_area>
ffffffffc020115a:	000ab797          	auipc	a5,0xab
ffffffffc020115e:	3357bf23          	sd	s5,830(a5) # ffffffffc02ac498 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201162:	579000ef          	jal	ra,ffffffffc0201eda <free_pages>
    return listelm->next;
ffffffffc0201166:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020116a:	01278963          	beq	a5,s2,ffffffffc020117c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020116e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201172:	679c                	ld	a5,8(a5)
ffffffffc0201174:	34fd                	addiw	s1,s1,-1
ffffffffc0201176:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201178:	ff279be3          	bne	a5,s2,ffffffffc020116e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020117c:	26049463          	bnez	s1,ffffffffc02013e4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201180:	46041263          	bnez	s0,ffffffffc02015e4 <default_check+0x772>
}
ffffffffc0201184:	60a6                	ld	ra,72(sp)
ffffffffc0201186:	6406                	ld	s0,64(sp)
ffffffffc0201188:	74e2                	ld	s1,56(sp)
ffffffffc020118a:	7942                	ld	s2,48(sp)
ffffffffc020118c:	79a2                	ld	s3,40(sp)
ffffffffc020118e:	7a02                	ld	s4,32(sp)
ffffffffc0201190:	6ae2                	ld	s5,24(sp)
ffffffffc0201192:	6b42                	ld	s6,16(sp)
ffffffffc0201194:	6ba2                	ld	s7,8(sp)
ffffffffc0201196:	6c02                	ld	s8,0(sp)
ffffffffc0201198:	6161                	addi	sp,sp,80
ffffffffc020119a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020119c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020119e:	4401                	li	s0,0
ffffffffc02011a0:	4481                	li	s1,0
ffffffffc02011a2:	b30d                	j	ffffffffc0200ec4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02011a4:	00006697          	auipc	a3,0x6
ffffffffc02011a8:	fc468693          	addi	a3,a3,-60 # ffffffffc0207168 <commands+0x878>
ffffffffc02011ac:	00006617          	auipc	a2,0x6
ffffffffc02011b0:	c0460613          	addi	a2,a2,-1020 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02011b4:	0f000593          	li	a1,240
ffffffffc02011b8:	00006517          	auipc	a0,0x6
ffffffffc02011bc:	fc050513          	addi	a0,a0,-64 # ffffffffc0207178 <commands+0x888>
ffffffffc02011c0:	ac4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011c4:	00006697          	auipc	a3,0x6
ffffffffc02011c8:	04c68693          	addi	a3,a3,76 # ffffffffc0207210 <commands+0x920>
ffffffffc02011cc:	00006617          	auipc	a2,0x6
ffffffffc02011d0:	be460613          	addi	a2,a2,-1052 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02011d4:	0bd00593          	li	a1,189
ffffffffc02011d8:	00006517          	auipc	a0,0x6
ffffffffc02011dc:	fa050513          	addi	a0,a0,-96 # ffffffffc0207178 <commands+0x888>
ffffffffc02011e0:	aa4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011e4:	00006697          	auipc	a3,0x6
ffffffffc02011e8:	05468693          	addi	a3,a3,84 # ffffffffc0207238 <commands+0x948>
ffffffffc02011ec:	00006617          	auipc	a2,0x6
ffffffffc02011f0:	bc460613          	addi	a2,a2,-1084 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02011f4:	0be00593          	li	a1,190
ffffffffc02011f8:	00006517          	auipc	a0,0x6
ffffffffc02011fc:	f8050513          	addi	a0,a0,-128 # ffffffffc0207178 <commands+0x888>
ffffffffc0201200:	a84ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201204:	00006697          	auipc	a3,0x6
ffffffffc0201208:	07468693          	addi	a3,a3,116 # ffffffffc0207278 <commands+0x988>
ffffffffc020120c:	00006617          	auipc	a2,0x6
ffffffffc0201210:	ba460613          	addi	a2,a2,-1116 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201214:	0c000593          	li	a1,192
ffffffffc0201218:	00006517          	auipc	a0,0x6
ffffffffc020121c:	f6050513          	addi	a0,a0,-160 # ffffffffc0207178 <commands+0x888>
ffffffffc0201220:	a64ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201224:	00006697          	auipc	a3,0x6
ffffffffc0201228:	0dc68693          	addi	a3,a3,220 # ffffffffc0207300 <commands+0xa10>
ffffffffc020122c:	00006617          	auipc	a2,0x6
ffffffffc0201230:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201234:	0d900593          	li	a1,217
ffffffffc0201238:	00006517          	auipc	a0,0x6
ffffffffc020123c:	f4050513          	addi	a0,a0,-192 # ffffffffc0207178 <commands+0x888>
ffffffffc0201240:	a44ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201244:	00006697          	auipc	a3,0x6
ffffffffc0201248:	f6c68693          	addi	a3,a3,-148 # ffffffffc02071b0 <commands+0x8c0>
ffffffffc020124c:	00006617          	auipc	a2,0x6
ffffffffc0201250:	b6460613          	addi	a2,a2,-1180 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201254:	0d200593          	li	a1,210
ffffffffc0201258:	00006517          	auipc	a0,0x6
ffffffffc020125c:	f2050513          	addi	a0,a0,-224 # ffffffffc0207178 <commands+0x888>
ffffffffc0201260:	a24ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc0201264:	00006697          	auipc	a3,0x6
ffffffffc0201268:	08c68693          	addi	a3,a3,140 # ffffffffc02072f0 <commands+0xa00>
ffffffffc020126c:	00006617          	auipc	a2,0x6
ffffffffc0201270:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201274:	0d000593          	li	a1,208
ffffffffc0201278:	00006517          	auipc	a0,0x6
ffffffffc020127c:	f0050513          	addi	a0,a0,-256 # ffffffffc0207178 <commands+0x888>
ffffffffc0201280:	a04ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201284:	00006697          	auipc	a3,0x6
ffffffffc0201288:	05468693          	addi	a3,a3,84 # ffffffffc02072d8 <commands+0x9e8>
ffffffffc020128c:	00006617          	auipc	a2,0x6
ffffffffc0201290:	b2460613          	addi	a2,a2,-1244 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201294:	0cb00593          	li	a1,203
ffffffffc0201298:	00006517          	auipc	a0,0x6
ffffffffc020129c:	ee050513          	addi	a0,a0,-288 # ffffffffc0207178 <commands+0x888>
ffffffffc02012a0:	9e4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	01468693          	addi	a3,a3,20 # ffffffffc02072b8 <commands+0x9c8>
ffffffffc02012ac:	00006617          	auipc	a2,0x6
ffffffffc02012b0:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02012b4:	0c200593          	li	a1,194
ffffffffc02012b8:	00006517          	auipc	a0,0x6
ffffffffc02012bc:	ec050513          	addi	a0,a0,-320 # ffffffffc0207178 <commands+0x888>
ffffffffc02012c0:	9c4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc02012c4:	00006697          	auipc	a3,0x6
ffffffffc02012c8:	08468693          	addi	a3,a3,132 # ffffffffc0207348 <commands+0xa58>
ffffffffc02012cc:	00006617          	auipc	a2,0x6
ffffffffc02012d0:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02012d4:	0f800593          	li	a1,248
ffffffffc02012d8:	00006517          	auipc	a0,0x6
ffffffffc02012dc:	ea050513          	addi	a0,a0,-352 # ffffffffc0207178 <commands+0x888>
ffffffffc02012e0:	9a4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc02012e4:	00006697          	auipc	a3,0x6
ffffffffc02012e8:	05468693          	addi	a3,a3,84 # ffffffffc0207338 <commands+0xa48>
ffffffffc02012ec:	00006617          	auipc	a2,0x6
ffffffffc02012f0:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02012f4:	0df00593          	li	a1,223
ffffffffc02012f8:	00006517          	auipc	a0,0x6
ffffffffc02012fc:	e8050513          	addi	a0,a0,-384 # ffffffffc0207178 <commands+0x888>
ffffffffc0201300:	984ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201304:	00006697          	auipc	a3,0x6
ffffffffc0201308:	fd468693          	addi	a3,a3,-44 # ffffffffc02072d8 <commands+0x9e8>
ffffffffc020130c:	00006617          	auipc	a2,0x6
ffffffffc0201310:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201314:	0dd00593          	li	a1,221
ffffffffc0201318:	00006517          	auipc	a0,0x6
ffffffffc020131c:	e6050513          	addi	a0,a0,-416 # ffffffffc0207178 <commands+0x888>
ffffffffc0201320:	964ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201324:	00006697          	auipc	a3,0x6
ffffffffc0201328:	ff468693          	addi	a3,a3,-12 # ffffffffc0207318 <commands+0xa28>
ffffffffc020132c:	00006617          	auipc	a2,0x6
ffffffffc0201330:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201334:	0dc00593          	li	a1,220
ffffffffc0201338:	00006517          	auipc	a0,0x6
ffffffffc020133c:	e4050513          	addi	a0,a0,-448 # ffffffffc0207178 <commands+0x888>
ffffffffc0201340:	944ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201344:	00006697          	auipc	a3,0x6
ffffffffc0201348:	e6c68693          	addi	a3,a3,-404 # ffffffffc02071b0 <commands+0x8c0>
ffffffffc020134c:	00006617          	auipc	a2,0x6
ffffffffc0201350:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201354:	0b900593          	li	a1,185
ffffffffc0201358:	00006517          	auipc	a0,0x6
ffffffffc020135c:	e2050513          	addi	a0,a0,-480 # ffffffffc0207178 <commands+0x888>
ffffffffc0201360:	924ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201364:	00006697          	auipc	a3,0x6
ffffffffc0201368:	f7468693          	addi	a3,a3,-140 # ffffffffc02072d8 <commands+0x9e8>
ffffffffc020136c:	00006617          	auipc	a2,0x6
ffffffffc0201370:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201374:	0d600593          	li	a1,214
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	e0050513          	addi	a0,a0,-512 # ffffffffc0207178 <commands+0x888>
ffffffffc0201380:	904ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	e6c68693          	addi	a3,a3,-404 # ffffffffc02071f0 <commands+0x900>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201394:	0d400593          	li	a1,212
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	de050513          	addi	a0,a0,-544 # ffffffffc0207178 <commands+0x888>
ffffffffc02013a0:	8e4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013a4:	00006697          	auipc	a3,0x6
ffffffffc02013a8:	e2c68693          	addi	a3,a3,-468 # ffffffffc02071d0 <commands+0x8e0>
ffffffffc02013ac:	00006617          	auipc	a2,0x6
ffffffffc02013b0:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02013b4:	0d300593          	li	a1,211
ffffffffc02013b8:	00006517          	auipc	a0,0x6
ffffffffc02013bc:	dc050513          	addi	a0,a0,-576 # ffffffffc0207178 <commands+0x888>
ffffffffc02013c0:	8c4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013c4:	00006697          	auipc	a3,0x6
ffffffffc02013c8:	e2c68693          	addi	a3,a3,-468 # ffffffffc02071f0 <commands+0x900>
ffffffffc02013cc:	00006617          	auipc	a2,0x6
ffffffffc02013d0:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02013d4:	0bb00593          	li	a1,187
ffffffffc02013d8:	00006517          	auipc	a0,0x6
ffffffffc02013dc:	da050513          	addi	a0,a0,-608 # ffffffffc0207178 <commands+0x888>
ffffffffc02013e0:	8a4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc02013e4:	00006697          	auipc	a3,0x6
ffffffffc02013e8:	0b468693          	addi	a3,a3,180 # ffffffffc0207498 <commands+0xba8>
ffffffffc02013ec:	00006617          	auipc	a2,0x6
ffffffffc02013f0:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02013f4:	12500593          	li	a1,293
ffffffffc02013f8:	00006517          	auipc	a0,0x6
ffffffffc02013fc:	d8050513          	addi	a0,a0,-640 # ffffffffc0207178 <commands+0x888>
ffffffffc0201400:	884ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc0201404:	00006697          	auipc	a3,0x6
ffffffffc0201408:	f3468693          	addi	a3,a3,-204 # ffffffffc0207338 <commands+0xa48>
ffffffffc020140c:	00006617          	auipc	a2,0x6
ffffffffc0201410:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201414:	11a00593          	li	a1,282
ffffffffc0201418:	00006517          	auipc	a0,0x6
ffffffffc020141c:	d6050513          	addi	a0,a0,-672 # ffffffffc0207178 <commands+0x888>
ffffffffc0201420:	864ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201424:	00006697          	auipc	a3,0x6
ffffffffc0201428:	eb468693          	addi	a3,a3,-332 # ffffffffc02072d8 <commands+0x9e8>
ffffffffc020142c:	00006617          	auipc	a2,0x6
ffffffffc0201430:	98460613          	addi	a2,a2,-1660 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201434:	11800593          	li	a1,280
ffffffffc0201438:	00006517          	auipc	a0,0x6
ffffffffc020143c:	d4050513          	addi	a0,a0,-704 # ffffffffc0207178 <commands+0x888>
ffffffffc0201440:	844ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201444:	00006697          	auipc	a3,0x6
ffffffffc0201448:	e5468693          	addi	a3,a3,-428 # ffffffffc0207298 <commands+0x9a8>
ffffffffc020144c:	00006617          	auipc	a2,0x6
ffffffffc0201450:	96460613          	addi	a2,a2,-1692 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201454:	0c100593          	li	a1,193
ffffffffc0201458:	00006517          	auipc	a0,0x6
ffffffffc020145c:	d2050513          	addi	a0,a0,-736 # ffffffffc0207178 <commands+0x888>
ffffffffc0201460:	824ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201464:	00006697          	auipc	a3,0x6
ffffffffc0201468:	ff468693          	addi	a3,a3,-12 # ffffffffc0207458 <commands+0xb68>
ffffffffc020146c:	00006617          	auipc	a2,0x6
ffffffffc0201470:	94460613          	addi	a2,a2,-1724 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201474:	11200593          	li	a1,274
ffffffffc0201478:	00006517          	auipc	a0,0x6
ffffffffc020147c:	d0050513          	addi	a0,a0,-768 # ffffffffc0207178 <commands+0x888>
ffffffffc0201480:	804ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201484:	00006697          	auipc	a3,0x6
ffffffffc0201488:	fb468693          	addi	a3,a3,-76 # ffffffffc0207438 <commands+0xb48>
ffffffffc020148c:	00006617          	auipc	a2,0x6
ffffffffc0201490:	92460613          	addi	a2,a2,-1756 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201494:	11000593          	li	a1,272
ffffffffc0201498:	00006517          	auipc	a0,0x6
ffffffffc020149c:	ce050513          	addi	a0,a0,-800 # ffffffffc0207178 <commands+0x888>
ffffffffc02014a0:	fe5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014a4:	00006697          	auipc	a3,0x6
ffffffffc02014a8:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207410 <commands+0xb20>
ffffffffc02014ac:	00006617          	auipc	a2,0x6
ffffffffc02014b0:	90460613          	addi	a2,a2,-1788 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02014b4:	10e00593          	li	a1,270
ffffffffc02014b8:	00006517          	auipc	a0,0x6
ffffffffc02014bc:	cc050513          	addi	a0,a0,-832 # ffffffffc0207178 <commands+0x888>
ffffffffc02014c0:	fc5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014c4:	00006697          	auipc	a3,0x6
ffffffffc02014c8:	f2468693          	addi	a3,a3,-220 # ffffffffc02073e8 <commands+0xaf8>
ffffffffc02014cc:	00006617          	auipc	a2,0x6
ffffffffc02014d0:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02014d4:	10d00593          	li	a1,269
ffffffffc02014d8:	00006517          	auipc	a0,0x6
ffffffffc02014dc:	ca050513          	addi	a0,a0,-864 # ffffffffc0207178 <commands+0x888>
ffffffffc02014e0:	fa5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014e4:	00006697          	auipc	a3,0x6
ffffffffc02014e8:	ef468693          	addi	a3,a3,-268 # ffffffffc02073d8 <commands+0xae8>
ffffffffc02014ec:	00006617          	auipc	a2,0x6
ffffffffc02014f0:	8c460613          	addi	a2,a2,-1852 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02014f4:	10800593          	li	a1,264
ffffffffc02014f8:	00006517          	auipc	a0,0x6
ffffffffc02014fc:	c8050513          	addi	a0,a0,-896 # ffffffffc0207178 <commands+0x888>
ffffffffc0201500:	f85fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201504:	00006697          	auipc	a3,0x6
ffffffffc0201508:	dd468693          	addi	a3,a3,-556 # ffffffffc02072d8 <commands+0x9e8>
ffffffffc020150c:	00006617          	auipc	a2,0x6
ffffffffc0201510:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201514:	10700593          	li	a1,263
ffffffffc0201518:	00006517          	auipc	a0,0x6
ffffffffc020151c:	c6050513          	addi	a0,a0,-928 # ffffffffc0207178 <commands+0x888>
ffffffffc0201520:	f65fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201524:	00006697          	auipc	a3,0x6
ffffffffc0201528:	e9468693          	addi	a3,a3,-364 # ffffffffc02073b8 <commands+0xac8>
ffffffffc020152c:	00006617          	auipc	a2,0x6
ffffffffc0201530:	88460613          	addi	a2,a2,-1916 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201534:	10600593          	li	a1,262
ffffffffc0201538:	00006517          	auipc	a0,0x6
ffffffffc020153c:	c4050513          	addi	a0,a0,-960 # ffffffffc0207178 <commands+0x888>
ffffffffc0201540:	f45fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201544:	00006697          	auipc	a3,0x6
ffffffffc0201548:	e4468693          	addi	a3,a3,-444 # ffffffffc0207388 <commands+0xa98>
ffffffffc020154c:	00006617          	auipc	a2,0x6
ffffffffc0201550:	86460613          	addi	a2,a2,-1948 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201554:	10500593          	li	a1,261
ffffffffc0201558:	00006517          	auipc	a0,0x6
ffffffffc020155c:	c2050513          	addi	a0,a0,-992 # ffffffffc0207178 <commands+0x888>
ffffffffc0201560:	f25fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201564:	00006697          	auipc	a3,0x6
ffffffffc0201568:	e0c68693          	addi	a3,a3,-500 # ffffffffc0207370 <commands+0xa80>
ffffffffc020156c:	00006617          	auipc	a2,0x6
ffffffffc0201570:	84460613          	addi	a2,a2,-1980 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201574:	10400593          	li	a1,260
ffffffffc0201578:	00006517          	auipc	a0,0x6
ffffffffc020157c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0207178 <commands+0x888>
ffffffffc0201580:	f05fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201584:	00006697          	auipc	a3,0x6
ffffffffc0201588:	d5468693          	addi	a3,a3,-684 # ffffffffc02072d8 <commands+0x9e8>
ffffffffc020158c:	00006617          	auipc	a2,0x6
ffffffffc0201590:	82460613          	addi	a2,a2,-2012 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201594:	0fe00593          	li	a1,254
ffffffffc0201598:	00006517          	auipc	a0,0x6
ffffffffc020159c:	be050513          	addi	a0,a0,-1056 # ffffffffc0207178 <commands+0x888>
ffffffffc02015a0:	ee5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015a4:	00006697          	auipc	a3,0x6
ffffffffc02015a8:	db468693          	addi	a3,a3,-588 # ffffffffc0207358 <commands+0xa68>
ffffffffc02015ac:	00006617          	auipc	a2,0x6
ffffffffc02015b0:	80460613          	addi	a2,a2,-2044 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02015b4:	0f900593          	li	a1,249
ffffffffc02015b8:	00006517          	auipc	a0,0x6
ffffffffc02015bc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0207178 <commands+0x888>
ffffffffc02015c0:	ec5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015c4:	00006697          	auipc	a3,0x6
ffffffffc02015c8:	eb468693          	addi	a3,a3,-332 # ffffffffc0207478 <commands+0xb88>
ffffffffc02015cc:	00005617          	auipc	a2,0x5
ffffffffc02015d0:	7e460613          	addi	a2,a2,2020 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02015d4:	11700593          	li	a1,279
ffffffffc02015d8:	00006517          	auipc	a0,0x6
ffffffffc02015dc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0207178 <commands+0x888>
ffffffffc02015e0:	ea5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc02015e4:	00006697          	auipc	a3,0x6
ffffffffc02015e8:	ec468693          	addi	a3,a3,-316 # ffffffffc02074a8 <commands+0xbb8>
ffffffffc02015ec:	00005617          	auipc	a2,0x5
ffffffffc02015f0:	7c460613          	addi	a2,a2,1988 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02015f4:	12600593          	li	a1,294
ffffffffc02015f8:	00006517          	auipc	a0,0x6
ffffffffc02015fc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0207178 <commands+0x888>
ffffffffc0201600:	e85fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201604:	00006697          	auipc	a3,0x6
ffffffffc0201608:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207190 <commands+0x8a0>
ffffffffc020160c:	00005617          	auipc	a2,0x5
ffffffffc0201610:	7a460613          	addi	a2,a2,1956 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201614:	0f300593          	li	a1,243
ffffffffc0201618:	00006517          	auipc	a0,0x6
ffffffffc020161c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0207178 <commands+0x888>
ffffffffc0201620:	e65fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201624:	00006697          	auipc	a3,0x6
ffffffffc0201628:	bac68693          	addi	a3,a3,-1108 # ffffffffc02071d0 <commands+0x8e0>
ffffffffc020162c:	00005617          	auipc	a2,0x5
ffffffffc0201630:	78460613          	addi	a2,a2,1924 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201634:	0ba00593          	li	a1,186
ffffffffc0201638:	00006517          	auipc	a0,0x6
ffffffffc020163c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0207178 <commands+0x888>
ffffffffc0201640:	e45fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201644 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201644:	1141                	addi	sp,sp,-16
ffffffffc0201646:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201648:	16058e63          	beqz	a1,ffffffffc02017c4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020164c:	00659693          	slli	a3,a1,0x6
ffffffffc0201650:	96aa                	add	a3,a3,a0
ffffffffc0201652:	02d50d63          	beq	a0,a3,ffffffffc020168c <default_free_pages+0x48>
ffffffffc0201656:	651c                	ld	a5,8(a0)
ffffffffc0201658:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020165a:	14079563          	bnez	a5,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc020165e:	651c                	ld	a5,8(a0)
ffffffffc0201660:	8385                	srli	a5,a5,0x1
ffffffffc0201662:	8b85                	andi	a5,a5,1
ffffffffc0201664:	14079063          	bnez	a5,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc0201668:	87aa                	mv	a5,a0
ffffffffc020166a:	a809                	j	ffffffffc020167c <default_free_pages+0x38>
ffffffffc020166c:	6798                	ld	a4,8(a5)
ffffffffc020166e:	8b05                	andi	a4,a4,1
ffffffffc0201670:	12071a63          	bnez	a4,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc0201674:	6798                	ld	a4,8(a5)
ffffffffc0201676:	8b09                	andi	a4,a4,2
ffffffffc0201678:	12071663          	bnez	a4,ffffffffc02017a4 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020167c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201680:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201684:	04078793          	addi	a5,a5,64
ffffffffc0201688:	fed792e3          	bne	a5,a3,ffffffffc020166c <default_free_pages+0x28>
    base->property = n;
ffffffffc020168c:	2581                	sext.w	a1,a1
ffffffffc020168e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201690:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201694:	4789                	li	a5,2
ffffffffc0201696:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020169a:	000ab697          	auipc	a3,0xab
ffffffffc020169e:	df668693          	addi	a3,a3,-522 # ffffffffc02ac490 <free_area>
ffffffffc02016a2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016a4:	669c                	ld	a5,8(a3)
ffffffffc02016a6:	9db9                	addw	a1,a1,a4
ffffffffc02016a8:	000ab717          	auipc	a4,0xab
ffffffffc02016ac:	deb72c23          	sw	a1,-520(a4) # ffffffffc02ac4a0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016b0:	0cd78163          	beq	a5,a3,ffffffffc0201772 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016b4:	fe878713          	addi	a4,a5,-24
ffffffffc02016b8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016ba:	4801                	li	a6,0
ffffffffc02016bc:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016c0:	00e56a63          	bltu	a0,a4,ffffffffc02016d4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016c4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016c6:	04d70f63          	beq	a4,a3,ffffffffc0201724 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ca:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016cc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016d0:	fee57ae3          	bleu	a4,a0,ffffffffc02016c4 <default_free_pages+0x80>
ffffffffc02016d4:	00080663          	beqz	a6,ffffffffc02016e0 <default_free_pages+0x9c>
ffffffffc02016d8:	000ab817          	auipc	a6,0xab
ffffffffc02016dc:	dab83c23          	sd	a1,-584(a6) # ffffffffc02ac490 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016e0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016e2:	e390                	sd	a2,0(a5)
ffffffffc02016e4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016e6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016e8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016ea:	06d58a63          	beq	a1,a3,ffffffffc020175e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016ee:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016f2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016f6:	02061793          	slli	a5,a2,0x20
ffffffffc02016fa:	83e9                	srli	a5,a5,0x1a
ffffffffc02016fc:	97ba                	add	a5,a5,a4
ffffffffc02016fe:	04f51b63          	bne	a0,a5,ffffffffc0201754 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201702:	491c                	lw	a5,16(a0)
ffffffffc0201704:	9e3d                	addw	a2,a2,a5
ffffffffc0201706:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020170a:	57f5                	li	a5,-3
ffffffffc020170c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201710:	01853803          	ld	a6,24(a0)
ffffffffc0201714:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201716:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201718:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020171c:	659c                	ld	a5,8(a1)
ffffffffc020171e:	01063023          	sd	a6,0(a2)
ffffffffc0201722:	a815                	j	ffffffffc0201756 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201724:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201726:	f114                	sd	a3,32(a0)
ffffffffc0201728:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020172a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020172c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020172e:	00d70563          	beq	a4,a3,ffffffffc0201738 <default_free_pages+0xf4>
ffffffffc0201732:	4805                	li	a6,1
ffffffffc0201734:	87ba                	mv	a5,a4
ffffffffc0201736:	bf59                	j	ffffffffc02016cc <default_free_pages+0x88>
ffffffffc0201738:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020173a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020173c:	00d78d63          	beq	a5,a3,ffffffffc0201756 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201740:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201744:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201748:	02061793          	slli	a5,a2,0x20
ffffffffc020174c:	83e9                	srli	a5,a5,0x1a
ffffffffc020174e:	97ba                	add	a5,a5,a4
ffffffffc0201750:	faf509e3          	beq	a0,a5,ffffffffc0201702 <default_free_pages+0xbe>
ffffffffc0201754:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201756:	fe878713          	addi	a4,a5,-24
ffffffffc020175a:	00d78963          	beq	a5,a3,ffffffffc020176c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020175e:	4910                	lw	a2,16(a0)
ffffffffc0201760:	02061693          	slli	a3,a2,0x20
ffffffffc0201764:	82e9                	srli	a3,a3,0x1a
ffffffffc0201766:	96aa                	add	a3,a3,a0
ffffffffc0201768:	00d70e63          	beq	a4,a3,ffffffffc0201784 <default_free_pages+0x140>
}
ffffffffc020176c:	60a2                	ld	ra,8(sp)
ffffffffc020176e:	0141                	addi	sp,sp,16
ffffffffc0201770:	8082                	ret
ffffffffc0201772:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201774:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201778:	e398                	sd	a4,0(a5)
ffffffffc020177a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020177c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020177e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201780:	0141                	addi	sp,sp,16
ffffffffc0201782:	8082                	ret
            base->property += p->property;
ffffffffc0201784:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201788:	ff078693          	addi	a3,a5,-16
ffffffffc020178c:	9e39                	addw	a2,a2,a4
ffffffffc020178e:	c910                	sw	a2,16(a0)
ffffffffc0201790:	5775                	li	a4,-3
ffffffffc0201792:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201796:	6398                	ld	a4,0(a5)
ffffffffc0201798:	679c                	ld	a5,8(a5)
}
ffffffffc020179a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020179c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020179e:	e398                	sd	a4,0(a5)
ffffffffc02017a0:	0141                	addi	sp,sp,16
ffffffffc02017a2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017a4:	00006697          	auipc	a3,0x6
ffffffffc02017a8:	d1468693          	addi	a3,a3,-748 # ffffffffc02074b8 <commands+0xbc8>
ffffffffc02017ac:	00005617          	auipc	a2,0x5
ffffffffc02017b0:	60460613          	addi	a2,a2,1540 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02017b4:	08300593          	li	a1,131
ffffffffc02017b8:	00006517          	auipc	a0,0x6
ffffffffc02017bc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0207178 <commands+0x888>
ffffffffc02017c0:	cc5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02017c4:	00006697          	auipc	a3,0x6
ffffffffc02017c8:	d1c68693          	addi	a3,a3,-740 # ffffffffc02074e0 <commands+0xbf0>
ffffffffc02017cc:	00005617          	auipc	a2,0x5
ffffffffc02017d0:	5e460613          	addi	a2,a2,1508 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02017d4:	08000593          	li	a1,128
ffffffffc02017d8:	00006517          	auipc	a0,0x6
ffffffffc02017dc:	9a050513          	addi	a0,a0,-1632 # ffffffffc0207178 <commands+0x888>
ffffffffc02017e0:	ca5fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02017e4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017e4:	c959                	beqz	a0,ffffffffc020187a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017e6:	000ab597          	auipc	a1,0xab
ffffffffc02017ea:	caa58593          	addi	a1,a1,-854 # ffffffffc02ac490 <free_area>
ffffffffc02017ee:	0105a803          	lw	a6,16(a1)
ffffffffc02017f2:	862a                	mv	a2,a0
ffffffffc02017f4:	02081793          	slli	a5,a6,0x20
ffffffffc02017f8:	9381                	srli	a5,a5,0x20
ffffffffc02017fa:	00a7ee63          	bltu	a5,a0,ffffffffc0201816 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017fe:	87ae                	mv	a5,a1
ffffffffc0201800:	a801                	j	ffffffffc0201810 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201802:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201806:	02071693          	slli	a3,a4,0x20
ffffffffc020180a:	9281                	srli	a3,a3,0x20
ffffffffc020180c:	00c6f763          	bleu	a2,a3,ffffffffc020181a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201810:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201812:	feb798e3          	bne	a5,a1,ffffffffc0201802 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201816:	4501                	li	a0,0
}
ffffffffc0201818:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020181a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020181e:	dd6d                	beqz	a0,ffffffffc0201818 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201820:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201824:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201828:	00060e1b          	sext.w	t3,a2
ffffffffc020182c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201830:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201834:	02d67863          	bleu	a3,a2,ffffffffc0201864 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201838:	061a                	slli	a2,a2,0x6
ffffffffc020183a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020183c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201840:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201842:	00860693          	addi	a3,a2,8
ffffffffc0201846:	4709                	li	a4,2
ffffffffc0201848:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020184c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201850:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201854:	0105a803          	lw	a6,16(a1)
ffffffffc0201858:	e314                	sd	a3,0(a4)
ffffffffc020185a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020185e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201860:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201864:	41c8083b          	subw	a6,a6,t3
ffffffffc0201868:	000ab717          	auipc	a4,0xab
ffffffffc020186c:	c3072c23          	sw	a6,-968(a4) # ffffffffc02ac4a0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201870:	5775                	li	a4,-3
ffffffffc0201872:	17c1                	addi	a5,a5,-16
ffffffffc0201874:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201878:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020187a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020187c:	00006697          	auipc	a3,0x6
ffffffffc0201880:	c6468693          	addi	a3,a3,-924 # ffffffffc02074e0 <commands+0xbf0>
ffffffffc0201884:	00005617          	auipc	a2,0x5
ffffffffc0201888:	52c60613          	addi	a2,a2,1324 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020188c:	06200593          	li	a1,98
ffffffffc0201890:	00006517          	auipc	a0,0x6
ffffffffc0201894:	8e850513          	addi	a0,a0,-1816 # ffffffffc0207178 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201898:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020189a:	bebfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020189e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020189e:	1141                	addi	sp,sp,-16
ffffffffc02018a0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018a2:	c1ed                	beqz	a1,ffffffffc0201984 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02018a4:	00659693          	slli	a3,a1,0x6
ffffffffc02018a8:	96aa                	add	a3,a3,a0
ffffffffc02018aa:	02d50463          	beq	a0,a3,ffffffffc02018d2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018ae:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018b0:	87aa                	mv	a5,a0
ffffffffc02018b2:	8b05                	andi	a4,a4,1
ffffffffc02018b4:	e709                	bnez	a4,ffffffffc02018be <default_init_memmap+0x20>
ffffffffc02018b6:	a07d                	j	ffffffffc0201964 <default_init_memmap+0xc6>
ffffffffc02018b8:	6798                	ld	a4,8(a5)
ffffffffc02018ba:	8b05                	andi	a4,a4,1
ffffffffc02018bc:	c745                	beqz	a4,ffffffffc0201964 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018be:	0007a823          	sw	zero,16(a5)
ffffffffc02018c2:	0007b423          	sd	zero,8(a5)
ffffffffc02018c6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018ca:	04078793          	addi	a5,a5,64
ffffffffc02018ce:	fed795e3          	bne	a5,a3,ffffffffc02018b8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018d2:	2581                	sext.w	a1,a1
ffffffffc02018d4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018d6:	4789                	li	a5,2
ffffffffc02018d8:	00850713          	addi	a4,a0,8
ffffffffc02018dc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018e0:	000ab697          	auipc	a3,0xab
ffffffffc02018e4:	bb068693          	addi	a3,a3,-1104 # ffffffffc02ac490 <free_area>
ffffffffc02018e8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018ea:	669c                	ld	a5,8(a3)
ffffffffc02018ec:	9db9                	addw	a1,a1,a4
ffffffffc02018ee:	000ab717          	auipc	a4,0xab
ffffffffc02018f2:	bab72923          	sw	a1,-1102(a4) # ffffffffc02ac4a0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018f6:	04d78a63          	beq	a5,a3,ffffffffc020194a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018fa:	fe878713          	addi	a4,a5,-24
ffffffffc02018fe:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201900:	4801                	li	a6,0
ffffffffc0201902:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201906:	00e56a63          	bltu	a0,a4,ffffffffc020191a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020190a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020190c:	02d70563          	beq	a4,a3,ffffffffc0201936 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201910:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201912:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201916:	fee57ae3          	bleu	a4,a0,ffffffffc020190a <default_init_memmap+0x6c>
ffffffffc020191a:	00080663          	beqz	a6,ffffffffc0201926 <default_init_memmap+0x88>
ffffffffc020191e:	000ab717          	auipc	a4,0xab
ffffffffc0201922:	b6b73923          	sd	a1,-1166(a4) # ffffffffc02ac490 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201926:	6398                	ld	a4,0(a5)
}
ffffffffc0201928:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020192a:	e390                	sd	a2,0(a5)
ffffffffc020192c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020192e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201930:	ed18                	sd	a4,24(a0)
ffffffffc0201932:	0141                	addi	sp,sp,16
ffffffffc0201934:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201936:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201938:	f114                	sd	a3,32(a0)
ffffffffc020193a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020193c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020193e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201940:	00d70e63          	beq	a4,a3,ffffffffc020195c <default_init_memmap+0xbe>
ffffffffc0201944:	4805                	li	a6,1
ffffffffc0201946:	87ba                	mv	a5,a4
ffffffffc0201948:	b7e9                	j	ffffffffc0201912 <default_init_memmap+0x74>
}
ffffffffc020194a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020194c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201950:	e398                	sd	a4,0(a5)
ffffffffc0201952:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201954:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201956:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201958:	0141                	addi	sp,sp,16
ffffffffc020195a:	8082                	ret
ffffffffc020195c:	60a2                	ld	ra,8(sp)
ffffffffc020195e:	e290                	sd	a2,0(a3)
ffffffffc0201960:	0141                	addi	sp,sp,16
ffffffffc0201962:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201964:	00006697          	auipc	a3,0x6
ffffffffc0201968:	b8468693          	addi	a3,a3,-1148 # ffffffffc02074e8 <commands+0xbf8>
ffffffffc020196c:	00005617          	auipc	a2,0x5
ffffffffc0201970:	44460613          	addi	a2,a2,1092 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201974:	04900593          	li	a1,73
ffffffffc0201978:	00006517          	auipc	a0,0x6
ffffffffc020197c:	80050513          	addi	a0,a0,-2048 # ffffffffc0207178 <commands+0x888>
ffffffffc0201980:	b05fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201984:	00006697          	auipc	a3,0x6
ffffffffc0201988:	b5c68693          	addi	a3,a3,-1188 # ffffffffc02074e0 <commands+0xbf0>
ffffffffc020198c:	00005617          	auipc	a2,0x5
ffffffffc0201990:	42460613          	addi	a2,a2,1060 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201994:	04600593          	li	a1,70
ffffffffc0201998:	00005517          	auipc	a0,0x5
ffffffffc020199c:	7e050513          	addi	a0,a0,2016 # ffffffffc0207178 <commands+0x888>
ffffffffc02019a0:	ae5fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02019a4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019a4:	c125                	beqz	a0,ffffffffc0201a04 <slob_free+0x60>
		return;

	if (size)
ffffffffc02019a6:	e1a5                	bnez	a1,ffffffffc0201a06 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a8:	100027f3          	csrr	a5,sstatus
ffffffffc02019ac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019ae:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b0:	e3bd                	bnez	a5,ffffffffc0201a16 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019b2:	0009f797          	auipc	a5,0x9f
ffffffffc02019b6:	66e78793          	addi	a5,a5,1646 # ffffffffc02a1020 <slobfree>
ffffffffc02019ba:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	00a7fa63          	bleu	a0,a5,ffffffffc02019d2 <slob_free+0x2e>
ffffffffc02019c2:	00e56c63          	bltu	a0,a4,ffffffffc02019da <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c6:	00e7fa63          	bleu	a4,a5,ffffffffc02019da <slob_free+0x36>
    return 0;
ffffffffc02019ca:	87ba                	mv	a5,a4
ffffffffc02019cc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ce:	fea7eae3          	bltu	a5,a0,ffffffffc02019c2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019d2:	fee7ece3          	bltu	a5,a4,ffffffffc02019ca <slob_free+0x26>
ffffffffc02019d6:	fee57ae3          	bleu	a4,a0,ffffffffc02019ca <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019da:	4110                	lw	a2,0(a0)
ffffffffc02019dc:	00461693          	slli	a3,a2,0x4
ffffffffc02019e0:	96aa                	add	a3,a3,a0
ffffffffc02019e2:	08d70b63          	beq	a4,a3,ffffffffc0201a78 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019e6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019e8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019ea:	00469713          	slli	a4,a3,0x4
ffffffffc02019ee:	973e                	add	a4,a4,a5
ffffffffc02019f0:	08e50f63          	beq	a0,a4,ffffffffc0201a8e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019f4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019f6:	0009f717          	auipc	a4,0x9f
ffffffffc02019fa:	62f73523          	sd	a5,1578(a4) # ffffffffc02a1020 <slobfree>
    if (flag) {
ffffffffc02019fe:	c199                	beqz	a1,ffffffffc0201a04 <slob_free+0x60>
        intr_enable();
ffffffffc0201a00:	c55fe06f          	j	ffffffffc0200654 <intr_enable>
ffffffffc0201a04:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201a06:	05bd                	addi	a1,a1,15
ffffffffc0201a08:	8191                	srli	a1,a1,0x4
ffffffffc0201a0a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a0c:	100027f3          	csrr	a5,sstatus
ffffffffc0201a10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a12:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a14:	dfd9                	beqz	a5,ffffffffc02019b2 <slob_free+0xe>
{
ffffffffc0201a16:	1101                	addi	sp,sp,-32
ffffffffc0201a18:	e42a                	sd	a0,8(sp)
ffffffffc0201a1a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a1c:	c3ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	0009f797          	auipc	a5,0x9f
ffffffffc0201a24:	60078793          	addi	a5,a5,1536 # ffffffffc02a1020 <slobfree>
ffffffffc0201a28:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a2a:	6522                	ld	a0,8(sp)
ffffffffc0201a2c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a30:	00a7fa63          	bleu	a0,a5,ffffffffc0201a44 <slob_free+0xa0>
ffffffffc0201a34:	00e56c63          	bltu	a0,a4,ffffffffc0201a4c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a38:	00e7fa63          	bleu	a4,a5,ffffffffc0201a4c <slob_free+0xa8>
    return 0;
ffffffffc0201a3c:	87ba                	mv	a5,a4
ffffffffc0201a3e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a40:	fea7eae3          	bltu	a5,a0,ffffffffc0201a34 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a44:	fee7ece3          	bltu	a5,a4,ffffffffc0201a3c <slob_free+0x98>
ffffffffc0201a48:	fee57ae3          	bleu	a4,a0,ffffffffc0201a3c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a4c:	4110                	lw	a2,0(a0)
ffffffffc0201a4e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a52:	96aa                	add	a3,a3,a0
ffffffffc0201a54:	04d70763          	beq	a4,a3,ffffffffc0201aa2 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a58:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a5a:	4394                	lw	a3,0(a5)
ffffffffc0201a5c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a60:	973e                	add	a4,a4,a5
ffffffffc0201a62:	04e50663          	beq	a0,a4,ffffffffc0201aae <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a66:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a68:	0009f717          	auipc	a4,0x9f
ffffffffc0201a6c:	5af73c23          	sd	a5,1464(a4) # ffffffffc02a1020 <slobfree>
    if (flag) {
ffffffffc0201a70:	e58d                	bnez	a1,ffffffffc0201a9a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a72:	60e2                	ld	ra,24(sp)
ffffffffc0201a74:	6105                	addi	sp,sp,32
ffffffffc0201a76:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a78:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a7a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a7c:	9e35                	addw	a2,a2,a3
ffffffffc0201a7e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a80:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a82:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a84:	00469713          	slli	a4,a3,0x4
ffffffffc0201a88:	973e                	add	a4,a4,a5
ffffffffc0201a8a:	f6e515e3          	bne	a0,a4,ffffffffc02019f4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a8e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a90:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a92:	9eb9                	addw	a3,a3,a4
ffffffffc0201a94:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a96:	e790                	sd	a2,8(a5)
ffffffffc0201a98:	bfb9                	j	ffffffffc02019f6 <slob_free+0x52>
}
ffffffffc0201a9a:	60e2                	ld	ra,24(sp)
ffffffffc0201a9c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a9e:	bb7fe06f          	j	ffffffffc0200654 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201aa2:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201aa4:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201aa6:	9e35                	addw	a2,a2,a3
ffffffffc0201aa8:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201aaa:	e518                	sd	a4,8(a0)
ffffffffc0201aac:	b77d                	j	ffffffffc0201a5a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201aae:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ab0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201ab2:	9eb9                	addw	a3,a3,a4
ffffffffc0201ab4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201ab6:	e790                	sd	a2,8(a5)
ffffffffc0201ab8:	bf45                	j	ffffffffc0201a68 <slob_free+0xc4>

ffffffffc0201aba <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aba:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201abc:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201abe:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ac2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ac4:	38e000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
  if(!page)
ffffffffc0201ac8:	c139                	beqz	a0,ffffffffc0201b0e <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aca:	000ab797          	auipc	a5,0xab
ffffffffc0201ace:	9f678793          	addi	a5,a5,-1546 # ffffffffc02ac4c0 <pages>
ffffffffc0201ad2:	6394                	ld	a3,0(a5)
ffffffffc0201ad4:	00007797          	auipc	a5,0x7
ffffffffc0201ad8:	41478793          	addi	a5,a5,1044 # ffffffffc0208ee8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201adc:	000ab717          	auipc	a4,0xab
ffffffffc0201ae0:	97470713          	addi	a4,a4,-1676 # ffffffffc02ac450 <npage>
    return page - pages + nbase;
ffffffffc0201ae4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ae8:	6388                	ld	a0,0(a5)
ffffffffc0201aea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201aec:	57fd                	li	a5,-1
ffffffffc0201aee:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201af0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201af2:	83b1                	srli	a5,a5,0xc
ffffffffc0201af4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201af6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201af8:	00e7ff63          	bleu	a4,a5,ffffffffc0201b16 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201afc:	000ab797          	auipc	a5,0xab
ffffffffc0201b00:	9b478793          	addi	a5,a5,-1612 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0201b04:	6388                	ld	a0,0(a5)
}
ffffffffc0201b06:	60a2                	ld	ra,8(sp)
ffffffffc0201b08:	9536                	add	a0,a0,a3
ffffffffc0201b0a:	0141                	addi	sp,sp,16
ffffffffc0201b0c:	8082                	ret
ffffffffc0201b0e:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b10:	4501                	li	a0,0
}
ffffffffc0201b12:	0141                	addi	sp,sp,16
ffffffffc0201b14:	8082                	ret
ffffffffc0201b16:	00006617          	auipc	a2,0x6
ffffffffc0201b1a:	a3260613          	addi	a2,a2,-1486 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0201b1e:	06900593          	li	a1,105
ffffffffc0201b22:	00006517          	auipc	a0,0x6
ffffffffc0201b26:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0201b2a:	95bfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b2e:	7179                	addi	sp,sp,-48
ffffffffc0201b30:	f406                	sd	ra,40(sp)
ffffffffc0201b32:	f022                	sd	s0,32(sp)
ffffffffc0201b34:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b36:	01050713          	addi	a4,a0,16
ffffffffc0201b3a:	6785                	lui	a5,0x1
ffffffffc0201b3c:	0cf77b63          	bleu	a5,a4,ffffffffc0201c12 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b40:	00f50413          	addi	s0,a0,15
ffffffffc0201b44:	8011                	srli	s0,s0,0x4
ffffffffc0201b46:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b48:	10002673          	csrr	a2,sstatus
ffffffffc0201b4c:	8a09                	andi	a2,a2,2
ffffffffc0201b4e:	ea5d                	bnez	a2,ffffffffc0201c04 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b50:	0009f497          	auipc	s1,0x9f
ffffffffc0201b54:	4d048493          	addi	s1,s1,1232 # ffffffffc02a1020 <slobfree>
ffffffffc0201b58:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b5a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b5c:	4398                	lw	a4,0(a5)
ffffffffc0201b5e:	0a875763          	ble	s0,a4,ffffffffc0201c0c <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b62:	00f68a63          	beq	a3,a5,ffffffffc0201b76 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b66:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b68:	4118                	lw	a4,0(a0)
ffffffffc0201b6a:	02875763          	ble	s0,a4,ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b6e:	6094                	ld	a3,0(s1)
ffffffffc0201b70:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b72:	fef69ae3          	bne	a3,a5,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b76:	ea39                	bnez	a2,ffffffffc0201bcc <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b78:	4501                	li	a0,0
ffffffffc0201b7a:	f41ff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b7e:	cd29                	beqz	a0,ffffffffc0201bd8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b80:	6585                	lui	a1,0x1
ffffffffc0201b82:	e23ff0ef          	jal	ra,ffffffffc02019a4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b86:	10002673          	csrr	a2,sstatus
ffffffffc0201b8a:	8a09                	andi	a2,a2,2
ffffffffc0201b8c:	ea1d                	bnez	a2,ffffffffc0201bc2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b8e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b90:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b92:	4118                	lw	a4,0(a0)
ffffffffc0201b94:	fc874de3          	blt	a4,s0,ffffffffc0201b6e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b98:	04e40663          	beq	s0,a4,ffffffffc0201be4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b9c:	00441693          	slli	a3,s0,0x4
ffffffffc0201ba0:	96aa                	add	a3,a3,a0
ffffffffc0201ba2:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201ba4:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201ba6:	9f01                	subw	a4,a4,s0
ffffffffc0201ba8:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201baa:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201bac:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201bae:	0009f717          	auipc	a4,0x9f
ffffffffc0201bb2:	46f73923          	sd	a5,1138(a4) # ffffffffc02a1020 <slobfree>
    if (flag) {
ffffffffc0201bb6:	ee15                	bnez	a2,ffffffffc0201bf2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201bb8:	70a2                	ld	ra,40(sp)
ffffffffc0201bba:	7402                	ld	s0,32(sp)
ffffffffc0201bbc:	64e2                	ld	s1,24(sp)
ffffffffc0201bbe:	6145                	addi	sp,sp,48
ffffffffc0201bc0:	8082                	ret
        intr_disable();
ffffffffc0201bc2:	a99fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201bc6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bc8:	609c                	ld	a5,0(s1)
ffffffffc0201bca:	b7d9                	j	ffffffffc0201b90 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bcc:	a89fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bd0:	4501                	li	a0,0
ffffffffc0201bd2:	ee9ff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bd6:	f54d                	bnez	a0,ffffffffc0201b80 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bd8:	70a2                	ld	ra,40(sp)
ffffffffc0201bda:	7402                	ld	s0,32(sp)
ffffffffc0201bdc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bde:	4501                	li	a0,0
}
ffffffffc0201be0:	6145                	addi	sp,sp,48
ffffffffc0201be2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201be4:	6518                	ld	a4,8(a0)
ffffffffc0201be6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201be8:	0009f717          	auipc	a4,0x9f
ffffffffc0201bec:	42f73c23          	sd	a5,1080(a4) # ffffffffc02a1020 <slobfree>
    if (flag) {
ffffffffc0201bf0:	d661                	beqz	a2,ffffffffc0201bb8 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bf2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bf4:	a61fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc0201bf8:	70a2                	ld	ra,40(sp)
ffffffffc0201bfa:	7402                	ld	s0,32(sp)
ffffffffc0201bfc:	6522                	ld	a0,8(sp)
ffffffffc0201bfe:	64e2                	ld	s1,24(sp)
ffffffffc0201c00:	6145                	addi	sp,sp,48
ffffffffc0201c02:	8082                	ret
        intr_disable();
ffffffffc0201c04:	a57fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201c08:	4605                	li	a2,1
ffffffffc0201c0a:	b799                	j	ffffffffc0201b50 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c0c:	853e                	mv	a0,a5
ffffffffc0201c0e:	87b6                	mv	a5,a3
ffffffffc0201c10:	b761                	j	ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c12:	00006697          	auipc	a3,0x6
ffffffffc0201c16:	9d668693          	addi	a3,a3,-1578 # ffffffffc02075e8 <default_pmm_manager+0xf0>
ffffffffc0201c1a:	00005617          	auipc	a2,0x5
ffffffffc0201c1e:	19660613          	addi	a2,a2,406 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0201c22:	06400593          	li	a1,100
ffffffffc0201c26:	00006517          	auipc	a0,0x6
ffffffffc0201c2a:	9e250513          	addi	a0,a0,-1566 # ffffffffc0207608 <default_pmm_manager+0x110>
ffffffffc0201c2e:	857fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201c32 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c32:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c34:	00006517          	auipc	a0,0x6
ffffffffc0201c38:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0207620 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c3c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c3e:	d50fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c42:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c44:	00006517          	auipc	a0,0x6
ffffffffc0201c48:	98450513          	addi	a0,a0,-1660 # ffffffffc02075c8 <default_pmm_manager+0xd0>
}
ffffffffc0201c4c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c4e:	d40fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c52 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c52:	4501                	li	a0,0
ffffffffc0201c54:	8082                	ret

ffffffffc0201c56 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c56:	1101                	addi	sp,sp,-32
ffffffffc0201c58:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c5a:	6905                	lui	s2,0x1
{
ffffffffc0201c5c:	e822                	sd	s0,16(sp)
ffffffffc0201c5e:	ec06                	sd	ra,24(sp)
ffffffffc0201c60:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c62:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8581>
{
ffffffffc0201c66:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c68:	04a7fc63          	bleu	a0,a5,ffffffffc0201cc0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c6c:	4561                	li	a0,24
ffffffffc0201c6e:	ec1ff0ef          	jal	ra,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c72:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c74:	cd21                	beqz	a0,ffffffffc0201ccc <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c76:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c7a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c7c:	00f95763          	ble	a5,s2,ffffffffc0201c8a <kmalloc+0x34>
ffffffffc0201c80:	6705                	lui	a4,0x1
ffffffffc0201c82:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c84:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c86:	fef74ee3          	blt	a4,a5,ffffffffc0201c82 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c8a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c8c:	e2fff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
ffffffffc0201c90:	e488                	sd	a0,8(s1)
ffffffffc0201c92:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c94:	c935                	beqz	a0,ffffffffc0201d08 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c96:	100027f3          	csrr	a5,sstatus
ffffffffc0201c9a:	8b89                	andi	a5,a5,2
ffffffffc0201c9c:	e3a1                	bnez	a5,ffffffffc0201cdc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c9e:	000aa797          	auipc	a5,0xaa
ffffffffc0201ca2:	7a278793          	addi	a5,a5,1954 # ffffffffc02ac440 <bigblocks>
ffffffffc0201ca6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201ca8:	000aa717          	auipc	a4,0xaa
ffffffffc0201cac:	78973c23          	sd	s1,1944(a4) # ffffffffc02ac440 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cb0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201cb2:	8522                	mv	a0,s0
ffffffffc0201cb4:	60e2                	ld	ra,24(sp)
ffffffffc0201cb6:	6442                	ld	s0,16(sp)
ffffffffc0201cb8:	64a2                	ld	s1,8(sp)
ffffffffc0201cba:	6902                	ld	s2,0(sp)
ffffffffc0201cbc:	6105                	addi	sp,sp,32
ffffffffc0201cbe:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cc0:	0541                	addi	a0,a0,16
ffffffffc0201cc2:	e6dff0ef          	jal	ra,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cc6:	01050413          	addi	s0,a0,16
ffffffffc0201cca:	f565                	bnez	a0,ffffffffc0201cb2 <kmalloc+0x5c>
ffffffffc0201ccc:	4401                	li	s0,0
}
ffffffffc0201cce:	8522                	mv	a0,s0
ffffffffc0201cd0:	60e2                	ld	ra,24(sp)
ffffffffc0201cd2:	6442                	ld	s0,16(sp)
ffffffffc0201cd4:	64a2                	ld	s1,8(sp)
ffffffffc0201cd6:	6902                	ld	s2,0(sp)
ffffffffc0201cd8:	6105                	addi	sp,sp,32
ffffffffc0201cda:	8082                	ret
        intr_disable();
ffffffffc0201cdc:	97ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ce0:	000aa797          	auipc	a5,0xaa
ffffffffc0201ce4:	76078793          	addi	a5,a5,1888 # ffffffffc02ac440 <bigblocks>
ffffffffc0201ce8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cea:	000aa717          	auipc	a4,0xaa
ffffffffc0201cee:	74973b23          	sd	s1,1878(a4) # ffffffffc02ac440 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cf2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cf4:	961fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201cf8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cfa:	60e2                	ld	ra,24(sp)
ffffffffc0201cfc:	64a2                	ld	s1,8(sp)
ffffffffc0201cfe:	8522                	mv	a0,s0
ffffffffc0201d00:	6442                	ld	s0,16(sp)
ffffffffc0201d02:	6902                	ld	s2,0(sp)
ffffffffc0201d04:	6105                	addi	sp,sp,32
ffffffffc0201d06:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d08:	45e1                	li	a1,24
ffffffffc0201d0a:	8526                	mv	a0,s1
ffffffffc0201d0c:	c99ff0ef          	jal	ra,ffffffffc02019a4 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d10:	b74d                	j	ffffffffc0201cb2 <kmalloc+0x5c>

ffffffffc0201d12 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d12:	c175                	beqz	a0,ffffffffc0201df6 <kfree+0xe4>
{
ffffffffc0201d14:	1101                	addi	sp,sp,-32
ffffffffc0201d16:	e426                	sd	s1,8(sp)
ffffffffc0201d18:	ec06                	sd	ra,24(sp)
ffffffffc0201d1a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d1c:	03451793          	slli	a5,a0,0x34
ffffffffc0201d20:	84aa                	mv	s1,a0
ffffffffc0201d22:	eb8d                	bnez	a5,ffffffffc0201d54 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d24:	100027f3          	csrr	a5,sstatus
ffffffffc0201d28:	8b89                	andi	a5,a5,2
ffffffffc0201d2a:	efc9                	bnez	a5,ffffffffc0201dc4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d2c:	000aa797          	auipc	a5,0xaa
ffffffffc0201d30:	71478793          	addi	a5,a5,1812 # ffffffffc02ac440 <bigblocks>
ffffffffc0201d34:	6394                	ld	a3,0(a5)
ffffffffc0201d36:	ce99                	beqz	a3,ffffffffc0201d54 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d38:	669c                	ld	a5,8(a3)
ffffffffc0201d3a:	6a80                	ld	s0,16(a3)
ffffffffc0201d3c:	0af50e63          	beq	a0,a5,ffffffffc0201df8 <kfree+0xe6>
    return 0;
ffffffffc0201d40:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d42:	c801                	beqz	s0,ffffffffc0201d52 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d44:	6418                	ld	a4,8(s0)
ffffffffc0201d46:	681c                	ld	a5,16(s0)
ffffffffc0201d48:	00970f63          	beq	a4,s1,ffffffffc0201d66 <kfree+0x54>
ffffffffc0201d4c:	86a2                	mv	a3,s0
ffffffffc0201d4e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d50:	f875                	bnez	s0,ffffffffc0201d44 <kfree+0x32>
    if (flag) {
ffffffffc0201d52:	e659                	bnez	a2,ffffffffc0201de0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d54:	6442                	ld	s0,16(sp)
ffffffffc0201d56:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d58:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d5c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d5e:	4581                	li	a1,0
}
ffffffffc0201d60:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d62:	c43ff06f          	j	ffffffffc02019a4 <slob_free>
				*last = bb->next;
ffffffffc0201d66:	ea9c                	sd	a5,16(a3)
ffffffffc0201d68:	e641                	bnez	a2,ffffffffc0201df0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d6a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d6e:	4018                	lw	a4,0(s0)
ffffffffc0201d70:	08f4ea63          	bltu	s1,a5,ffffffffc0201e04 <kfree+0xf2>
ffffffffc0201d74:	000aa797          	auipc	a5,0xaa
ffffffffc0201d78:	73c78793          	addi	a5,a5,1852 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0201d7c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d7e:	000aa797          	auipc	a5,0xaa
ffffffffc0201d82:	6d278793          	addi	a5,a5,1746 # ffffffffc02ac450 <npage>
ffffffffc0201d86:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d88:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d8a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d8c:	08f4f963          	bleu	a5,s1,ffffffffc0201e1e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d90:	00007797          	auipc	a5,0x7
ffffffffc0201d94:	15878793          	addi	a5,a5,344 # ffffffffc0208ee8 <nbase>
ffffffffc0201d98:	639c                	ld	a5,0(a5)
ffffffffc0201d9a:	000aa697          	auipc	a3,0xaa
ffffffffc0201d9e:	72668693          	addi	a3,a3,1830 # ffffffffc02ac4c0 <pages>
ffffffffc0201da2:	6288                	ld	a0,0(a3)
ffffffffc0201da4:	8c9d                	sub	s1,s1,a5
ffffffffc0201da6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201da8:	4585                	li	a1,1
ffffffffc0201daa:	9526                	add	a0,a0,s1
ffffffffc0201dac:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201db0:	12a000ef          	jal	ra,ffffffffc0201eda <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201db4:	8522                	mv	a0,s0
}
ffffffffc0201db6:	6442                	ld	s0,16(sp)
ffffffffc0201db8:	60e2                	ld	ra,24(sp)
ffffffffc0201dba:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dbc:	45e1                	li	a1,24
}
ffffffffc0201dbe:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201dc0:	be5ff06f          	j	ffffffffc02019a4 <slob_free>
        intr_disable();
ffffffffc0201dc4:	897fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201dc8:	000aa797          	auipc	a5,0xaa
ffffffffc0201dcc:	67878793          	addi	a5,a5,1656 # ffffffffc02ac440 <bigblocks>
ffffffffc0201dd0:	6394                	ld	a3,0(a5)
ffffffffc0201dd2:	c699                	beqz	a3,ffffffffc0201de0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201dd4:	669c                	ld	a5,8(a3)
ffffffffc0201dd6:	6a80                	ld	s0,16(a3)
ffffffffc0201dd8:	00f48763          	beq	s1,a5,ffffffffc0201de6 <kfree+0xd4>
        return 1;
ffffffffc0201ddc:	4605                	li	a2,1
ffffffffc0201dde:	b795                	j	ffffffffc0201d42 <kfree+0x30>
        intr_enable();
ffffffffc0201de0:	875fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201de4:	bf85                	j	ffffffffc0201d54 <kfree+0x42>
				*last = bb->next;
ffffffffc0201de6:	000aa797          	auipc	a5,0xaa
ffffffffc0201dea:	6487bd23          	sd	s0,1626(a5) # ffffffffc02ac440 <bigblocks>
ffffffffc0201dee:	8436                	mv	s0,a3
ffffffffc0201df0:	865fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201df4:	bf9d                	j	ffffffffc0201d6a <kfree+0x58>
ffffffffc0201df6:	8082                	ret
ffffffffc0201df8:	000aa797          	auipc	a5,0xaa
ffffffffc0201dfc:	6487b423          	sd	s0,1608(a5) # ffffffffc02ac440 <bigblocks>
ffffffffc0201e00:	8436                	mv	s0,a3
ffffffffc0201e02:	b7a5                	j	ffffffffc0201d6a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201e04:	86a6                	mv	a3,s1
ffffffffc0201e06:	00005617          	auipc	a2,0x5
ffffffffc0201e0a:	77a60613          	addi	a2,a2,1914 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc0201e0e:	06e00593          	li	a1,110
ffffffffc0201e12:	00005517          	auipc	a0,0x5
ffffffffc0201e16:	75e50513          	addi	a0,a0,1886 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0201e1a:	e6afe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e1e:	00005617          	auipc	a2,0x5
ffffffffc0201e22:	78a60613          	addi	a2,a2,1930 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc0201e26:	06200593          	li	a1,98
ffffffffc0201e2a:	00005517          	auipc	a0,0x5
ffffffffc0201e2e:	74650513          	addi	a0,a0,1862 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0201e32:	e52fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e36 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e36:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e38:	00005617          	auipc	a2,0x5
ffffffffc0201e3c:	77060613          	addi	a2,a2,1904 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc0201e40:	06200593          	li	a1,98
ffffffffc0201e44:	00005517          	auipc	a0,0x5
ffffffffc0201e48:	72c50513          	addi	a0,a0,1836 # ffffffffc0207570 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e4c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e4e:	e36fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e52 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e52:	715d                	addi	sp,sp,-80
ffffffffc0201e54:	e0a2                	sd	s0,64(sp)
ffffffffc0201e56:	fc26                	sd	s1,56(sp)
ffffffffc0201e58:	f84a                	sd	s2,48(sp)
ffffffffc0201e5a:	f44e                	sd	s3,40(sp)
ffffffffc0201e5c:	f052                	sd	s4,32(sp)
ffffffffc0201e5e:	ec56                	sd	s5,24(sp)
ffffffffc0201e60:	e486                	sd	ra,72(sp)
ffffffffc0201e62:	842a                	mv	s0,a0
ffffffffc0201e64:	000aa497          	auipc	s1,0xaa
ffffffffc0201e68:	64448493          	addi	s1,s1,1604 # ffffffffc02ac4a8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e6c:	4985                	li	s3,1
ffffffffc0201e6e:	000aaa17          	auipc	s4,0xaa
ffffffffc0201e72:	5f2a0a13          	addi	s4,s4,1522 # ffffffffc02ac460 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e76:	0005091b          	sext.w	s2,a0
ffffffffc0201e7a:	000aaa97          	auipc	s5,0xaa
ffffffffc0201e7e:	726a8a93          	addi	s5,s5,1830 # ffffffffc02ac5a0 <check_mm_struct>
ffffffffc0201e82:	a00d                	j	ffffffffc0201ea4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e84:	609c                	ld	a5,0(s1)
ffffffffc0201e86:	6f9c                	ld	a5,24(a5)
ffffffffc0201e88:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e8a:	4601                	li	a2,0
ffffffffc0201e8c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e8e:	ed0d                	bnez	a0,ffffffffc0201ec8 <alloc_pages+0x76>
ffffffffc0201e90:	0289ec63          	bltu	s3,s0,ffffffffc0201ec8 <alloc_pages+0x76>
ffffffffc0201e94:	000a2783          	lw	a5,0(s4)
ffffffffc0201e98:	2781                	sext.w	a5,a5
ffffffffc0201e9a:	c79d                	beqz	a5,ffffffffc0201ec8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e9c:	000ab503          	ld	a0,0(s5)
ffffffffc0201ea0:	50b010ef          	jal	ra,ffffffffc0203baa <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ea8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201eaa:	8522                	mv	a0,s0
ffffffffc0201eac:	dfe1                	beqz	a5,ffffffffc0201e84 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201eae:	facfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201eb2:	609c                	ld	a5,0(s1)
ffffffffc0201eb4:	8522                	mv	a0,s0
ffffffffc0201eb6:	6f9c                	ld	a5,24(a5)
ffffffffc0201eb8:	9782                	jalr	a5
ffffffffc0201eba:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ebc:	f98fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201ec0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ec2:	4601                	li	a2,0
ffffffffc0201ec4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ec6:	d569                	beqz	a0,ffffffffc0201e90 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ec8:	60a6                	ld	ra,72(sp)
ffffffffc0201eca:	6406                	ld	s0,64(sp)
ffffffffc0201ecc:	74e2                	ld	s1,56(sp)
ffffffffc0201ece:	7942                	ld	s2,48(sp)
ffffffffc0201ed0:	79a2                	ld	s3,40(sp)
ffffffffc0201ed2:	7a02                	ld	s4,32(sp)
ffffffffc0201ed4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ed6:	6161                	addi	sp,sp,80
ffffffffc0201ed8:	8082                	ret

ffffffffc0201eda <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eda:	100027f3          	csrr	a5,sstatus
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	eb89                	bnez	a5,ffffffffc0201ef2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ee2:	000aa797          	auipc	a5,0xaa
ffffffffc0201ee6:	5c678793          	addi	a5,a5,1478 # ffffffffc02ac4a8 <pmm_manager>
ffffffffc0201eea:	639c                	ld	a5,0(a5)
ffffffffc0201eec:	0207b303          	ld	t1,32(a5)
ffffffffc0201ef0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ef2:	1101                	addi	sp,sp,-32
ffffffffc0201ef4:	ec06                	sd	ra,24(sp)
ffffffffc0201ef6:	e822                	sd	s0,16(sp)
ffffffffc0201ef8:	e426                	sd	s1,8(sp)
ffffffffc0201efa:	842a                	mv	s0,a0
ffffffffc0201efc:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201efe:	f5cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f02:	000aa797          	auipc	a5,0xaa
ffffffffc0201f06:	5a678793          	addi	a5,a5,1446 # ffffffffc02ac4a8 <pmm_manager>
ffffffffc0201f0a:	639c                	ld	a5,0(a5)
ffffffffc0201f0c:	85a6                	mv	a1,s1
ffffffffc0201f0e:	8522                	mv	a0,s0
ffffffffc0201f10:	739c                	ld	a5,32(a5)
ffffffffc0201f12:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f14:	6442                	ld	s0,16(sp)
ffffffffc0201f16:	60e2                	ld	ra,24(sp)
ffffffffc0201f18:	64a2                	ld	s1,8(sp)
ffffffffc0201f1a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f1c:	f38fe06f          	j	ffffffffc0200654 <intr_enable>

ffffffffc0201f20 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f20:	100027f3          	csrr	a5,sstatus
ffffffffc0201f24:	8b89                	andi	a5,a5,2
ffffffffc0201f26:	eb89                	bnez	a5,ffffffffc0201f38 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f28:	000aa797          	auipc	a5,0xaa
ffffffffc0201f2c:	58078793          	addi	a5,a5,1408 # ffffffffc02ac4a8 <pmm_manager>
ffffffffc0201f30:	639c                	ld	a5,0(a5)
ffffffffc0201f32:	0287b303          	ld	t1,40(a5)
ffffffffc0201f36:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f38:	1141                	addi	sp,sp,-16
ffffffffc0201f3a:	e406                	sd	ra,8(sp)
ffffffffc0201f3c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f3e:	f1cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f42:	000aa797          	auipc	a5,0xaa
ffffffffc0201f46:	56678793          	addi	a5,a5,1382 # ffffffffc02ac4a8 <pmm_manager>
ffffffffc0201f4a:	639c                	ld	a5,0(a5)
ffffffffc0201f4c:	779c                	ld	a5,40(a5)
ffffffffc0201f4e:	9782                	jalr	a5
ffffffffc0201f50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f52:	f02fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f56:	8522                	mv	a0,s0
ffffffffc0201f58:	60a2                	ld	ra,8(sp)
ffffffffc0201f5a:	6402                	ld	s0,0(sp)
ffffffffc0201f5c:	0141                	addi	sp,sp,16
ffffffffc0201f5e:	8082                	ret

ffffffffc0201f60 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f60:	7139                	addi	sp,sp,-64
ffffffffc0201f62:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f64:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f68:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f6c:	048e                	slli	s1,s1,0x3
ffffffffc0201f6e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f70:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f72:	f04a                	sd	s2,32(sp)
ffffffffc0201f74:	ec4e                	sd	s3,24(sp)
ffffffffc0201f76:	e852                	sd	s4,16(sp)
ffffffffc0201f78:	fc06                	sd	ra,56(sp)
ffffffffc0201f7a:	f822                	sd	s0,48(sp)
ffffffffc0201f7c:	e456                	sd	s5,8(sp)
ffffffffc0201f7e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f80:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f84:	892e                	mv	s2,a1
ffffffffc0201f86:	8a32                	mv	s4,a2
ffffffffc0201f88:	000aa997          	auipc	s3,0xaa
ffffffffc0201f8c:	4c898993          	addi	s3,s3,1224 # ffffffffc02ac450 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f90:	e7bd                	bnez	a5,ffffffffc0201ffe <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f92:	12060c63          	beqz	a2,ffffffffc02020ca <get_pte+0x16a>
ffffffffc0201f96:	4505                	li	a0,1
ffffffffc0201f98:	ebbff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201f9c:	842a                	mv	s0,a0
ffffffffc0201f9e:	12050663          	beqz	a0,ffffffffc02020ca <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201fa2:	000aab17          	auipc	s6,0xaa
ffffffffc0201fa6:	51eb0b13          	addi	s6,s6,1310 # ffffffffc02ac4c0 <pages>
ffffffffc0201faa:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201fae:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fb0:	000aa997          	auipc	s3,0xaa
ffffffffc0201fb4:	4a098993          	addi	s3,s3,1184 # ffffffffc02ac450 <npage>
    return page - pages + nbase;
ffffffffc0201fb8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fbc:	00080ab7          	lui	s5,0x80
ffffffffc0201fc0:	8519                	srai	a0,a0,0x6
ffffffffc0201fc2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fc6:	c01c                	sw	a5,0(s0)
ffffffffc0201fc8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fca:	9556                	add	a0,a0,s5
ffffffffc0201fcc:	83b1                	srli	a5,a5,0xc
ffffffffc0201fce:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd0:	0532                	slli	a0,a0,0xc
ffffffffc0201fd2:	14e7f363          	bleu	a4,a5,ffffffffc0202118 <get_pte+0x1b8>
ffffffffc0201fd6:	000aa797          	auipc	a5,0xaa
ffffffffc0201fda:	4da78793          	addi	a5,a5,1242 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0201fde:	639c                	ld	a5,0(a5)
ffffffffc0201fe0:	6605                	lui	a2,0x1
ffffffffc0201fe2:	4581                	li	a1,0
ffffffffc0201fe4:	953e                	add	a0,a0,a5
ffffffffc0201fe6:	7aa040ef          	jal	ra,ffffffffc0206790 <memset>
    return page - pages + nbase;
ffffffffc0201fea:	000b3683          	ld	a3,0(s6)
ffffffffc0201fee:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ff2:	8699                	srai	a3,a3,0x6
ffffffffc0201ff4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ff6:	06aa                	slli	a3,a3,0xa
ffffffffc0201ff8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ffc:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201ffe:	77fd                	lui	a5,0xfffff
ffffffffc0202000:	068a                	slli	a3,a3,0x2
ffffffffc0202002:	0009b703          	ld	a4,0(s3)
ffffffffc0202006:	8efd                	and	a3,a3,a5
ffffffffc0202008:	00c6d793          	srli	a5,a3,0xc
ffffffffc020200c:	0ce7f163          	bleu	a4,a5,ffffffffc02020ce <get_pte+0x16e>
ffffffffc0202010:	000aaa97          	auipc	s5,0xaa
ffffffffc0202014:	4a0a8a93          	addi	s5,s5,1184 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0202018:	000ab403          	ld	s0,0(s5)
ffffffffc020201c:	01595793          	srli	a5,s2,0x15
ffffffffc0202020:	1ff7f793          	andi	a5,a5,511
ffffffffc0202024:	96a2                	add	a3,a3,s0
ffffffffc0202026:	00379413          	slli	s0,a5,0x3
ffffffffc020202a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020202c:	6014                	ld	a3,0(s0)
ffffffffc020202e:	0016f793          	andi	a5,a3,1
ffffffffc0202032:	e3ad                	bnez	a5,ffffffffc0202094 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202034:	080a0b63          	beqz	s4,ffffffffc02020ca <get_pte+0x16a>
ffffffffc0202038:	4505                	li	a0,1
ffffffffc020203a:	e19ff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020203e:	84aa                	mv	s1,a0
ffffffffc0202040:	c549                	beqz	a0,ffffffffc02020ca <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202042:	000aab17          	auipc	s6,0xaa
ffffffffc0202046:	47eb0b13          	addi	s6,s6,1150 # ffffffffc02ac4c0 <pages>
ffffffffc020204a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020204e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202050:	00080a37          	lui	s4,0x80
ffffffffc0202054:	40a48533          	sub	a0,s1,a0
ffffffffc0202058:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020205a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020205e:	c09c                	sw	a5,0(s1)
ffffffffc0202060:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202062:	9552                	add	a0,a0,s4
ffffffffc0202064:	83b1                	srli	a5,a5,0xc
ffffffffc0202066:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202068:	0532                	slli	a0,a0,0xc
ffffffffc020206a:	08e7fa63          	bleu	a4,a5,ffffffffc02020fe <get_pte+0x19e>
ffffffffc020206e:	000ab783          	ld	a5,0(s5)
ffffffffc0202072:	6605                	lui	a2,0x1
ffffffffc0202074:	4581                	li	a1,0
ffffffffc0202076:	953e                	add	a0,a0,a5
ffffffffc0202078:	718040ef          	jal	ra,ffffffffc0206790 <memset>
    return page - pages + nbase;
ffffffffc020207c:	000b3683          	ld	a3,0(s6)
ffffffffc0202080:	40d486b3          	sub	a3,s1,a3
ffffffffc0202084:	8699                	srai	a3,a3,0x6
ffffffffc0202086:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202088:	06aa                	slli	a3,a3,0xa
ffffffffc020208a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020208e:	e014                	sd	a3,0(s0)
ffffffffc0202090:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202094:	068a                	slli	a3,a3,0x2
ffffffffc0202096:	757d                	lui	a0,0xfffff
ffffffffc0202098:	8ee9                	and	a3,a3,a0
ffffffffc020209a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020209e:	04e7f463          	bleu	a4,a5,ffffffffc02020e6 <get_pte+0x186>
ffffffffc02020a2:	000ab503          	ld	a0,0(s5)
ffffffffc02020a6:	00c95793          	srli	a5,s2,0xc
ffffffffc02020aa:	1ff7f793          	andi	a5,a5,511
ffffffffc02020ae:	96aa                	add	a3,a3,a0
ffffffffc02020b0:	00379513          	slli	a0,a5,0x3
ffffffffc02020b4:	9536                	add	a0,a0,a3
}
ffffffffc02020b6:	70e2                	ld	ra,56(sp)
ffffffffc02020b8:	7442                	ld	s0,48(sp)
ffffffffc02020ba:	74a2                	ld	s1,40(sp)
ffffffffc02020bc:	7902                	ld	s2,32(sp)
ffffffffc02020be:	69e2                	ld	s3,24(sp)
ffffffffc02020c0:	6a42                	ld	s4,16(sp)
ffffffffc02020c2:	6aa2                	ld	s5,8(sp)
ffffffffc02020c4:	6b02                	ld	s6,0(sp)
ffffffffc02020c6:	6121                	addi	sp,sp,64
ffffffffc02020c8:	8082                	ret
            return NULL;
ffffffffc02020ca:	4501                	li	a0,0
ffffffffc02020cc:	b7ed                	j	ffffffffc02020b6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020ce:	00005617          	auipc	a2,0x5
ffffffffc02020d2:	47a60613          	addi	a2,a2,1146 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc02020d6:	0e300593          	li	a1,227
ffffffffc02020da:	00005517          	auipc	a0,0x5
ffffffffc02020de:	5be50513          	addi	a0,a0,1470 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02020e2:	ba2fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020e6:	00005617          	auipc	a2,0x5
ffffffffc02020ea:	46260613          	addi	a2,a2,1122 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc02020ee:	0ee00593          	li	a1,238
ffffffffc02020f2:	00005517          	auipc	a0,0x5
ffffffffc02020f6:	5a650513          	addi	a0,a0,1446 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02020fa:	b8afe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020fe:	86aa                	mv	a3,a0
ffffffffc0202100:	00005617          	auipc	a2,0x5
ffffffffc0202104:	44860613          	addi	a2,a2,1096 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202108:	0eb00593          	li	a1,235
ffffffffc020210c:	00005517          	auipc	a0,0x5
ffffffffc0202110:	58c50513          	addi	a0,a0,1420 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202114:	b70fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202118:	86aa                	mv	a3,a0
ffffffffc020211a:	00005617          	auipc	a2,0x5
ffffffffc020211e:	42e60613          	addi	a2,a2,1070 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202122:	0df00593          	li	a1,223
ffffffffc0202126:	00005517          	auipc	a0,0x5
ffffffffc020212a:	57250513          	addi	a0,a0,1394 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc020212e:	b56fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202132 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202132:	1141                	addi	sp,sp,-16
ffffffffc0202134:	e022                	sd	s0,0(sp)
ffffffffc0202136:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202138:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020213a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020213c:	e25ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202140:	c011                	beqz	s0,ffffffffc0202144 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202142:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202144:	c129                	beqz	a0,ffffffffc0202186 <get_page+0x54>
ffffffffc0202146:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202148:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020214a:	0017f713          	andi	a4,a5,1
ffffffffc020214e:	e709                	bnez	a4,ffffffffc0202158 <get_page+0x26>
}
ffffffffc0202150:	60a2                	ld	ra,8(sp)
ffffffffc0202152:	6402                	ld	s0,0(sp)
ffffffffc0202154:	0141                	addi	sp,sp,16
ffffffffc0202156:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202158:	000aa717          	auipc	a4,0xaa
ffffffffc020215c:	2f870713          	addi	a4,a4,760 # ffffffffc02ac450 <npage>
ffffffffc0202160:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202162:	078a                	slli	a5,a5,0x2
ffffffffc0202164:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202166:	02e7f563          	bleu	a4,a5,ffffffffc0202190 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020216a:	000aa717          	auipc	a4,0xaa
ffffffffc020216e:	35670713          	addi	a4,a4,854 # ffffffffc02ac4c0 <pages>
ffffffffc0202172:	6308                	ld	a0,0(a4)
ffffffffc0202174:	60a2                	ld	ra,8(sp)
ffffffffc0202176:	6402                	ld	s0,0(sp)
ffffffffc0202178:	fff80737          	lui	a4,0xfff80
ffffffffc020217c:	97ba                	add	a5,a5,a4
ffffffffc020217e:	079a                	slli	a5,a5,0x6
ffffffffc0202180:	953e                	add	a0,a0,a5
ffffffffc0202182:	0141                	addi	sp,sp,16
ffffffffc0202184:	8082                	ret
ffffffffc0202186:	60a2                	ld	ra,8(sp)
ffffffffc0202188:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020218a:	4501                	li	a0,0
}
ffffffffc020218c:	0141                	addi	sp,sp,16
ffffffffc020218e:	8082                	ret
ffffffffc0202190:	ca7ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202194 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202194:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202196:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020219a:	ec86                	sd	ra,88(sp)
ffffffffc020219c:	e8a2                	sd	s0,80(sp)
ffffffffc020219e:	e4a6                	sd	s1,72(sp)
ffffffffc02021a0:	e0ca                	sd	s2,64(sp)
ffffffffc02021a2:	fc4e                	sd	s3,56(sp)
ffffffffc02021a4:	f852                	sd	s4,48(sp)
ffffffffc02021a6:	f456                	sd	s5,40(sp)
ffffffffc02021a8:	f05a                	sd	s6,32(sp)
ffffffffc02021aa:	ec5e                	sd	s7,24(sp)
ffffffffc02021ac:	e862                	sd	s8,16(sp)
ffffffffc02021ae:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021b0:	03479713          	slli	a4,a5,0x34
ffffffffc02021b4:	eb71                	bnez	a4,ffffffffc0202288 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021b6:	002007b7          	lui	a5,0x200
ffffffffc02021ba:	842e                	mv	s0,a1
ffffffffc02021bc:	0af5e663          	bltu	a1,a5,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021c0:	8932                	mv	s2,a2
ffffffffc02021c2:	0ac5f363          	bleu	a2,a1,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021c6:	4785                	li	a5,1
ffffffffc02021c8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021ca:	08c7ef63          	bltu	a5,a2,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021ce:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021d0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021d2:	000aac97          	auipc	s9,0xaa
ffffffffc02021d6:	27ec8c93          	addi	s9,s9,638 # ffffffffc02ac450 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021da:	000aac17          	auipc	s8,0xaa
ffffffffc02021de:	2e6c0c13          	addi	s8,s8,742 # ffffffffc02ac4c0 <pages>
ffffffffc02021e2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021e6:	00200b37          	lui	s6,0x200
ffffffffc02021ea:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021ee:	4601                	li	a2,0
ffffffffc02021f0:	85a2                	mv	a1,s0
ffffffffc02021f2:	854e                	mv	a0,s3
ffffffffc02021f4:	d6dff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02021f8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021fa:	cd21                	beqz	a0,ffffffffc0202252 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021fc:	611c                	ld	a5,0(a0)
ffffffffc02021fe:	e38d                	bnez	a5,ffffffffc0202220 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0202200:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202202:	ff2466e3          	bltu	s0,s2,ffffffffc02021ee <unmap_range+0x5a>
}
ffffffffc0202206:	60e6                	ld	ra,88(sp)
ffffffffc0202208:	6446                	ld	s0,80(sp)
ffffffffc020220a:	64a6                	ld	s1,72(sp)
ffffffffc020220c:	6906                	ld	s2,64(sp)
ffffffffc020220e:	79e2                	ld	s3,56(sp)
ffffffffc0202210:	7a42                	ld	s4,48(sp)
ffffffffc0202212:	7aa2                	ld	s5,40(sp)
ffffffffc0202214:	7b02                	ld	s6,32(sp)
ffffffffc0202216:	6be2                	ld	s7,24(sp)
ffffffffc0202218:	6c42                	ld	s8,16(sp)
ffffffffc020221a:	6ca2                	ld	s9,8(sp)
ffffffffc020221c:	6125                	addi	sp,sp,96
ffffffffc020221e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202220:	0017f713          	andi	a4,a5,1
ffffffffc0202224:	df71                	beqz	a4,ffffffffc0202200 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202226:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020222a:	078a                	slli	a5,a5,0x2
ffffffffc020222c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020222e:	06e7fd63          	bleu	a4,a5,ffffffffc02022a8 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202232:	000c3503          	ld	a0,0(s8)
ffffffffc0202236:	97de                	add	a5,a5,s7
ffffffffc0202238:	079a                	slli	a5,a5,0x6
ffffffffc020223a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020223c:	411c                	lw	a5,0(a0)
ffffffffc020223e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202242:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202244:	cf11                	beqz	a4,ffffffffc0202260 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202246:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020224a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020224e:	9452                	add	s0,s0,s4
ffffffffc0202250:	bf4d                	j	ffffffffc0202202 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202252:	945a                	add	s0,s0,s6
ffffffffc0202254:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202258:	d45d                	beqz	s0,ffffffffc0202206 <unmap_range+0x72>
ffffffffc020225a:	f9246ae3          	bltu	s0,s2,ffffffffc02021ee <unmap_range+0x5a>
ffffffffc020225e:	b765                	j	ffffffffc0202206 <unmap_range+0x72>
            free_page(page);
ffffffffc0202260:	4585                	li	a1,1
ffffffffc0202262:	c79ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202266:	b7c5                	j	ffffffffc0202246 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202268:	00006697          	auipc	a3,0x6
ffffffffc020226c:	9d868693          	addi	a3,a3,-1576 # ffffffffc0207c40 <default_pmm_manager+0x748>
ffffffffc0202270:	00005617          	auipc	a2,0x5
ffffffffc0202274:	b4060613          	addi	a2,a2,-1216 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202278:	11000593          	li	a1,272
ffffffffc020227c:	00005517          	auipc	a0,0x5
ffffffffc0202280:	41c50513          	addi	a0,a0,1052 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202284:	a00fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202288:	00006697          	auipc	a3,0x6
ffffffffc020228c:	98868693          	addi	a3,a3,-1656 # ffffffffc0207c10 <default_pmm_manager+0x718>
ffffffffc0202290:	00005617          	auipc	a2,0x5
ffffffffc0202294:	b2060613          	addi	a2,a2,-1248 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202298:	10f00593          	li	a1,271
ffffffffc020229c:	00005517          	auipc	a0,0x5
ffffffffc02022a0:	3fc50513          	addi	a0,a0,1020 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02022a4:	9e0fe0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02022a8:	b8fff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc02022ac <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022ac:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ae:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022b2:	fc86                	sd	ra,120(sp)
ffffffffc02022b4:	f8a2                	sd	s0,112(sp)
ffffffffc02022b6:	f4a6                	sd	s1,104(sp)
ffffffffc02022b8:	f0ca                	sd	s2,96(sp)
ffffffffc02022ba:	ecce                	sd	s3,88(sp)
ffffffffc02022bc:	e8d2                	sd	s4,80(sp)
ffffffffc02022be:	e4d6                	sd	s5,72(sp)
ffffffffc02022c0:	e0da                	sd	s6,64(sp)
ffffffffc02022c2:	fc5e                	sd	s7,56(sp)
ffffffffc02022c4:	f862                	sd	s8,48(sp)
ffffffffc02022c6:	f466                	sd	s9,40(sp)
ffffffffc02022c8:	f06a                	sd	s10,32(sp)
ffffffffc02022ca:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022cc:	03479713          	slli	a4,a5,0x34
ffffffffc02022d0:	1c071163          	bnez	a4,ffffffffc0202492 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022d4:	002007b7          	lui	a5,0x200
ffffffffc02022d8:	20f5e563          	bltu	a1,a5,ffffffffc02024e2 <exit_range+0x236>
ffffffffc02022dc:	8b32                	mv	s6,a2
ffffffffc02022de:	20c5f263          	bleu	a2,a1,ffffffffc02024e2 <exit_range+0x236>
ffffffffc02022e2:	4785                	li	a5,1
ffffffffc02022e4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022e6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024e2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022ea:	c00009b7          	lui	s3,0xc0000
ffffffffc02022ee:	400007b7          	lui	a5,0x40000
ffffffffc02022f2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022f6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022f8:	c0000337          	lui	t1,0xc0000
ffffffffc02022fc:	00698933          	add	s2,s3,t1
ffffffffc0202300:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202304:	1ff97913          	andi	s2,s2,511
ffffffffc0202308:	8e2a                	mv	t3,a0
ffffffffc020230a:	090e                	slli	s2,s2,0x3
ffffffffc020230c:	9972                	add	s2,s2,t3
ffffffffc020230e:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202312:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202316:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0202318:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020231c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020231e:	000aad17          	auipc	s10,0xaa
ffffffffc0202322:	132d0d13          	addi	s10,s10,306 # ffffffffc02ac450 <npage>
    return KADDR(page2pa(page));
ffffffffc0202326:	00cddd93          	srli	s11,s11,0xc
ffffffffc020232a:	000aa717          	auipc	a4,0xaa
ffffffffc020232e:	18670713          	addi	a4,a4,390 # ffffffffc02ac4b0 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202332:	000aae97          	auipc	t4,0xaa
ffffffffc0202336:	18ee8e93          	addi	t4,t4,398 # ffffffffc02ac4c0 <pages>
        if (pde1&PTE_V){
ffffffffc020233a:	e79d                	bnez	a5,ffffffffc0202368 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020233c:	12098963          	beqz	s3,ffffffffc020246e <exit_range+0x1c2>
ffffffffc0202340:	400007b7          	lui	a5,0x40000
ffffffffc0202344:	84ce                	mv	s1,s3
ffffffffc0202346:	97ce                	add	a5,a5,s3
ffffffffc0202348:	1369f363          	bleu	s6,s3,ffffffffc020246e <exit_range+0x1c2>
ffffffffc020234c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020234e:	00698933          	add	s2,s3,t1
ffffffffc0202352:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202356:	1ff97913          	andi	s2,s2,511
ffffffffc020235a:	090e                	slli	s2,s2,0x3
ffffffffc020235c:	9972                	add	s2,s2,t3
ffffffffc020235e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202362:	001bf793          	andi	a5,s7,1
ffffffffc0202366:	dbf9                	beqz	a5,ffffffffc020233c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202368:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020236c:	0b8a                	slli	s7,s7,0x2
ffffffffc020236e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202372:	14fbfc63          	bleu	a5,s7,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202376:	fff80ab7          	lui	s5,0xfff80
ffffffffc020237a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020237c:	000806b7          	lui	a3,0x80
ffffffffc0202380:	96d6                	add	a3,a3,s5
ffffffffc0202382:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202386:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020238a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020238c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020238e:	12f67263          	bleu	a5,a2,ffffffffc02024b2 <exit_range+0x206>
ffffffffc0202392:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202396:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202398:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020239c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020239e:	00080837          	lui	a6,0x80
ffffffffc02023a2:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02023a4:	00200c37          	lui	s8,0x200
ffffffffc02023a8:	a801                	j	ffffffffc02023b8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02023aa:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02023ac:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023ae:	c0d9                	beqz	s1,ffffffffc0202434 <exit_range+0x188>
ffffffffc02023b0:	0934f263          	bleu	s3,s1,ffffffffc0202434 <exit_range+0x188>
ffffffffc02023b4:	0d64fc63          	bleu	s6,s1,ffffffffc020248c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023b8:	0154d413          	srli	s0,s1,0x15
ffffffffc02023bc:	1ff47413          	andi	s0,s0,511
ffffffffc02023c0:	040e                	slli	s0,s0,0x3
ffffffffc02023c2:	9452                	add	s0,s0,s4
ffffffffc02023c4:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023c6:	0017f693          	andi	a3,a5,1
ffffffffc02023ca:	d2e5                	beqz	a3,ffffffffc02023aa <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023cc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023d0:	00279513          	slli	a0,a5,0x2
ffffffffc02023d4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023d6:	0eb57a63          	bleu	a1,a0,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023da:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023dc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023e0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023e4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023e8:	0cb7f563          	bleu	a1,a5,ffffffffc02024b2 <exit_range+0x206>
ffffffffc02023ec:	631c                	ld	a5,0(a4)
ffffffffc02023ee:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023f0:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023f4:	629c                	ld	a5,0(a3)
ffffffffc02023f6:	8b85                	andi	a5,a5,1
ffffffffc02023f8:	fbd5                	bnez	a5,ffffffffc02023ac <exit_range+0x100>
ffffffffc02023fa:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023fc:	fed59ce3          	bne	a1,a3,ffffffffc02023f4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0202400:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0202404:	4585                	li	a1,1
ffffffffc0202406:	e072                	sd	t3,0(sp)
ffffffffc0202408:	953e                	add	a0,a0,a5
ffffffffc020240a:	ad1ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
                d0start += PTSIZE;
ffffffffc020240e:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202410:	00043023          	sd	zero,0(s0)
ffffffffc0202414:	000aae97          	auipc	t4,0xaa
ffffffffc0202418:	0ace8e93          	addi	t4,t4,172 # ffffffffc02ac4c0 <pages>
ffffffffc020241c:	6e02                	ld	t3,0(sp)
ffffffffc020241e:	c0000337          	lui	t1,0xc0000
ffffffffc0202422:	fff808b7          	lui	a7,0xfff80
ffffffffc0202426:	00080837          	lui	a6,0x80
ffffffffc020242a:	000aa717          	auipc	a4,0xaa
ffffffffc020242e:	08670713          	addi	a4,a4,134 # ffffffffc02ac4b0 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202432:	fcbd                	bnez	s1,ffffffffc02023b0 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202434:	f00c84e3          	beqz	s9,ffffffffc020233c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202438:	000d3783          	ld	a5,0(s10)
ffffffffc020243c:	e072                	sd	t3,0(sp)
ffffffffc020243e:	08fbf663          	bleu	a5,s7,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202442:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202446:	67a2                	ld	a5,8(sp)
ffffffffc0202448:	4585                	li	a1,1
ffffffffc020244a:	953e                	add	a0,a0,a5
ffffffffc020244c:	a8fff0ef          	jal	ra,ffffffffc0201eda <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202450:	00093023          	sd	zero,0(s2)
ffffffffc0202454:	000aa717          	auipc	a4,0xaa
ffffffffc0202458:	05c70713          	addi	a4,a4,92 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc020245c:	c0000337          	lui	t1,0xc0000
ffffffffc0202460:	6e02                	ld	t3,0(sp)
ffffffffc0202462:	000aae97          	auipc	t4,0xaa
ffffffffc0202466:	05ee8e93          	addi	t4,t4,94 # ffffffffc02ac4c0 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020246a:	ec099be3          	bnez	s3,ffffffffc0202340 <exit_range+0x94>
}
ffffffffc020246e:	70e6                	ld	ra,120(sp)
ffffffffc0202470:	7446                	ld	s0,112(sp)
ffffffffc0202472:	74a6                	ld	s1,104(sp)
ffffffffc0202474:	7906                	ld	s2,96(sp)
ffffffffc0202476:	69e6                	ld	s3,88(sp)
ffffffffc0202478:	6a46                	ld	s4,80(sp)
ffffffffc020247a:	6aa6                	ld	s5,72(sp)
ffffffffc020247c:	6b06                	ld	s6,64(sp)
ffffffffc020247e:	7be2                	ld	s7,56(sp)
ffffffffc0202480:	7c42                	ld	s8,48(sp)
ffffffffc0202482:	7ca2                	ld	s9,40(sp)
ffffffffc0202484:	7d02                	ld	s10,32(sp)
ffffffffc0202486:	6de2                	ld	s11,24(sp)
ffffffffc0202488:	6109                	addi	sp,sp,128
ffffffffc020248a:	8082                	ret
            if (free_pd0) {
ffffffffc020248c:	ea0c8ae3          	beqz	s9,ffffffffc0202340 <exit_range+0x94>
ffffffffc0202490:	b765                	j	ffffffffc0202438 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202492:	00005697          	auipc	a3,0x5
ffffffffc0202496:	77e68693          	addi	a3,a3,1918 # ffffffffc0207c10 <default_pmm_manager+0x718>
ffffffffc020249a:	00005617          	auipc	a2,0x5
ffffffffc020249e:	91660613          	addi	a2,a2,-1770 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02024a2:	12000593          	li	a1,288
ffffffffc02024a6:	00005517          	auipc	a0,0x5
ffffffffc02024aa:	1f250513          	addi	a0,a0,498 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02024ae:	fd7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024b2:	00005617          	auipc	a2,0x5
ffffffffc02024b6:	09660613          	addi	a2,a2,150 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc02024ba:	06900593          	li	a1,105
ffffffffc02024be:	00005517          	auipc	a0,0x5
ffffffffc02024c2:	0b250513          	addi	a0,a0,178 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc02024c6:	fbffd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024ca:	00005617          	auipc	a2,0x5
ffffffffc02024ce:	0de60613          	addi	a2,a2,222 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc02024d2:	06200593          	li	a1,98
ffffffffc02024d6:	00005517          	auipc	a0,0x5
ffffffffc02024da:	09a50513          	addi	a0,a0,154 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc02024de:	fa7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024e2:	00005697          	auipc	a3,0x5
ffffffffc02024e6:	75e68693          	addi	a3,a3,1886 # ffffffffc0207c40 <default_pmm_manager+0x748>
ffffffffc02024ea:	00005617          	auipc	a2,0x5
ffffffffc02024ee:	8c660613          	addi	a2,a2,-1850 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02024f2:	12100593          	li	a1,289
ffffffffc02024f6:	00005517          	auipc	a0,0x5
ffffffffc02024fa:	1a250513          	addi	a0,a0,418 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02024fe:	f87fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202502 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202502:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202504:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202506:	e426                	sd	s1,8(sp)
ffffffffc0202508:	ec06                	sd	ra,24(sp)
ffffffffc020250a:	e822                	sd	s0,16(sp)
ffffffffc020250c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020250e:	a53ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep != NULL) {
ffffffffc0202512:	c511                	beqz	a0,ffffffffc020251e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202514:	611c                	ld	a5,0(a0)
ffffffffc0202516:	842a                	mv	s0,a0
ffffffffc0202518:	0017f713          	andi	a4,a5,1
ffffffffc020251c:	e711                	bnez	a4,ffffffffc0202528 <page_remove+0x26>
}
ffffffffc020251e:	60e2                	ld	ra,24(sp)
ffffffffc0202520:	6442                	ld	s0,16(sp)
ffffffffc0202522:	64a2                	ld	s1,8(sp)
ffffffffc0202524:	6105                	addi	sp,sp,32
ffffffffc0202526:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202528:	000aa717          	auipc	a4,0xaa
ffffffffc020252c:	f2870713          	addi	a4,a4,-216 # ffffffffc02ac450 <npage>
ffffffffc0202530:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202532:	078a                	slli	a5,a5,0x2
ffffffffc0202534:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202536:	02e7fe63          	bleu	a4,a5,ffffffffc0202572 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020253a:	000aa717          	auipc	a4,0xaa
ffffffffc020253e:	f8670713          	addi	a4,a4,-122 # ffffffffc02ac4c0 <pages>
ffffffffc0202542:	6308                	ld	a0,0(a4)
ffffffffc0202544:	fff80737          	lui	a4,0xfff80
ffffffffc0202548:	97ba                	add	a5,a5,a4
ffffffffc020254a:	079a                	slli	a5,a5,0x6
ffffffffc020254c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020254e:	411c                	lw	a5,0(a0)
ffffffffc0202550:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202554:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202556:	cb11                	beqz	a4,ffffffffc020256a <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202558:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020255c:	12048073          	sfence.vma	s1
}
ffffffffc0202560:	60e2                	ld	ra,24(sp)
ffffffffc0202562:	6442                	ld	s0,16(sp)
ffffffffc0202564:	64a2                	ld	s1,8(sp)
ffffffffc0202566:	6105                	addi	sp,sp,32
ffffffffc0202568:	8082                	ret
            free_page(page);
ffffffffc020256a:	4585                	li	a1,1
ffffffffc020256c:	96fff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202570:	b7e5                	j	ffffffffc0202558 <page_remove+0x56>
ffffffffc0202572:	8c5ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202576 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202576:	7179                	addi	sp,sp,-48
ffffffffc0202578:	e44e                	sd	s3,8(sp)
ffffffffc020257a:	89b2                	mv	s3,a2
ffffffffc020257c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020257e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202580:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202582:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202584:	ec26                	sd	s1,24(sp)
ffffffffc0202586:	f406                	sd	ra,40(sp)
ffffffffc0202588:	e84a                	sd	s2,16(sp)
ffffffffc020258a:	e052                	sd	s4,0(sp)
ffffffffc020258c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020258e:	9d3ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep == NULL) {
ffffffffc0202592:	cd49                	beqz	a0,ffffffffc020262c <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202594:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202596:	611c                	ld	a5,0(a0)
ffffffffc0202598:	892a                	mv	s2,a0
ffffffffc020259a:	0016871b          	addiw	a4,a3,1
ffffffffc020259e:	c018                	sw	a4,0(s0)
ffffffffc02025a0:	0017f713          	andi	a4,a5,1
ffffffffc02025a4:	ef05                	bnez	a4,ffffffffc02025dc <page_insert+0x66>
ffffffffc02025a6:	000aa797          	auipc	a5,0xaa
ffffffffc02025aa:	f1a78793          	addi	a5,a5,-230 # ffffffffc02ac4c0 <pages>
ffffffffc02025ae:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025b0:	8c19                	sub	s0,s0,a4
ffffffffc02025b2:	000806b7          	lui	a3,0x80
ffffffffc02025b6:	8419                	srai	s0,s0,0x6
ffffffffc02025b8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025ba:	042a                	slli	s0,s0,0xa
ffffffffc02025bc:	8c45                	or	s0,s0,s1
ffffffffc02025be:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025c2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025c6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025ca:	4501                	li	a0,0
}
ffffffffc02025cc:	70a2                	ld	ra,40(sp)
ffffffffc02025ce:	7402                	ld	s0,32(sp)
ffffffffc02025d0:	64e2                	ld	s1,24(sp)
ffffffffc02025d2:	6942                	ld	s2,16(sp)
ffffffffc02025d4:	69a2                	ld	s3,8(sp)
ffffffffc02025d6:	6a02                	ld	s4,0(sp)
ffffffffc02025d8:	6145                	addi	sp,sp,48
ffffffffc02025da:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025dc:	000aa717          	auipc	a4,0xaa
ffffffffc02025e0:	e7470713          	addi	a4,a4,-396 # ffffffffc02ac450 <npage>
ffffffffc02025e4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025e6:	078a                	slli	a5,a5,0x2
ffffffffc02025e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ea:	04e7f363          	bleu	a4,a5,ffffffffc0202630 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ee:	000aaa17          	auipc	s4,0xaa
ffffffffc02025f2:	ed2a0a13          	addi	s4,s4,-302 # ffffffffc02ac4c0 <pages>
ffffffffc02025f6:	000a3703          	ld	a4,0(s4)
ffffffffc02025fa:	fff80537          	lui	a0,0xfff80
ffffffffc02025fe:	953e                	add	a0,a0,a5
ffffffffc0202600:	051a                	slli	a0,a0,0x6
ffffffffc0202602:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0202604:	00a40a63          	beq	s0,a0,ffffffffc0202618 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202608:	411c                	lw	a5,0(a0)
ffffffffc020260a:	fff7869b          	addiw	a3,a5,-1
ffffffffc020260e:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202610:	c691                	beqz	a3,ffffffffc020261c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202612:	12098073          	sfence.vma	s3
ffffffffc0202616:	bf69                	j	ffffffffc02025b0 <page_insert+0x3a>
ffffffffc0202618:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020261a:	bf59                	j	ffffffffc02025b0 <page_insert+0x3a>
            free_page(page);
ffffffffc020261c:	4585                	li	a1,1
ffffffffc020261e:	8bdff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202622:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202626:	12098073          	sfence.vma	s3
ffffffffc020262a:	b759                	j	ffffffffc02025b0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020262c:	5571                	li	a0,-4
ffffffffc020262e:	bf79                	j	ffffffffc02025cc <page_insert+0x56>
ffffffffc0202630:	807ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202634 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202634:	00005797          	auipc	a5,0x5
ffffffffc0202638:	ec478793          	addi	a5,a5,-316 # ffffffffc02074f8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020263c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020263e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202640:	00005517          	auipc	a0,0x5
ffffffffc0202644:	08050513          	addi	a0,a0,128 # ffffffffc02076c0 <default_pmm_manager+0x1c8>
void pmm_init(void) {
ffffffffc0202648:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020264a:	000aa717          	auipc	a4,0xaa
ffffffffc020264e:	e4f73f23          	sd	a5,-418(a4) # ffffffffc02ac4a8 <pmm_manager>
void pmm_init(void) {
ffffffffc0202652:	e0a2                	sd	s0,64(sp)
ffffffffc0202654:	fc26                	sd	s1,56(sp)
ffffffffc0202656:	f84a                	sd	s2,48(sp)
ffffffffc0202658:	f44e                	sd	s3,40(sp)
ffffffffc020265a:	f052                	sd	s4,32(sp)
ffffffffc020265c:	ec56                	sd	s5,24(sp)
ffffffffc020265e:	e85a                	sd	s6,16(sp)
ffffffffc0202660:	e45e                	sd	s7,8(sp)
ffffffffc0202662:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202664:	000aa417          	auipc	s0,0xaa
ffffffffc0202668:	e4440413          	addi	s0,s0,-444 # ffffffffc02ac4a8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020266c:	b23fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202670:	601c                	ld	a5,0(s0)
ffffffffc0202672:	000aa497          	auipc	s1,0xaa
ffffffffc0202676:	dde48493          	addi	s1,s1,-546 # ffffffffc02ac450 <npage>
ffffffffc020267a:	000aa917          	auipc	s2,0xaa
ffffffffc020267e:	e4690913          	addi	s2,s2,-442 # ffffffffc02ac4c0 <pages>
ffffffffc0202682:	679c                	ld	a5,8(a5)
ffffffffc0202684:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202686:	57f5                	li	a5,-3
ffffffffc0202688:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020268a:	00005517          	auipc	a0,0x5
ffffffffc020268e:	04e50513          	addi	a0,a0,78 # ffffffffc02076d8 <default_pmm_manager+0x1e0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202692:	000aa717          	auipc	a4,0xaa
ffffffffc0202696:	e0f73f23          	sd	a5,-482(a4) # ffffffffc02ac4b0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020269a:	af5fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020269e:	46c5                	li	a3,17
ffffffffc02026a0:	06ee                	slli	a3,a3,0x1b
ffffffffc02026a2:	40100613          	li	a2,1025
ffffffffc02026a6:	16fd                	addi	a3,a3,-1
ffffffffc02026a8:	0656                	slli	a2,a2,0x15
ffffffffc02026aa:	07e005b7          	lui	a1,0x7e00
ffffffffc02026ae:	00005517          	auipc	a0,0x5
ffffffffc02026b2:	04250513          	addi	a0,a0,66 # ffffffffc02076f0 <default_pmm_manager+0x1f8>
ffffffffc02026b6:	ad9fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026ba:	777d                	lui	a4,0xfffff
ffffffffc02026bc:	000ab797          	auipc	a5,0xab
ffffffffc02026c0:	efb78793          	addi	a5,a5,-261 # ffffffffc02ad5b7 <end+0xfff>
ffffffffc02026c4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026c6:	00088737          	lui	a4,0x88
ffffffffc02026ca:	000aa697          	auipc	a3,0xaa
ffffffffc02026ce:	d8e6b323          	sd	a4,-634(a3) # ffffffffc02ac450 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026d2:	000aa717          	auipc	a4,0xaa
ffffffffc02026d6:	def73723          	sd	a5,-530(a4) # ffffffffc02ac4c0 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026da:	4701                	li	a4,0
ffffffffc02026dc:	4685                	li	a3,1
ffffffffc02026de:	fff80837          	lui	a6,0xfff80
ffffffffc02026e2:	a019                	j	ffffffffc02026e8 <pmm_init+0xb4>
ffffffffc02026e4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026e8:	00671613          	slli	a2,a4,0x6
ffffffffc02026ec:	97b2                	add	a5,a5,a2
ffffffffc02026ee:	07a1                	addi	a5,a5,8
ffffffffc02026f0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026f4:	6090                	ld	a2,0(s1)
ffffffffc02026f6:	0705                	addi	a4,a4,1
ffffffffc02026f8:	010607b3          	add	a5,a2,a6
ffffffffc02026fc:	fef764e3          	bltu	a4,a5,ffffffffc02026e4 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202700:	00093503          	ld	a0,0(s2)
ffffffffc0202704:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202708:	00661693          	slli	a3,a2,0x6
ffffffffc020270c:	97aa                	add	a5,a5,a0
ffffffffc020270e:	96be                	add	a3,a3,a5
ffffffffc0202710:	c02007b7          	lui	a5,0xc0200
ffffffffc0202714:	7af6ed63          	bltu	a3,a5,ffffffffc0202ece <pmm_init+0x89a>
ffffffffc0202718:	000aa997          	auipc	s3,0xaa
ffffffffc020271c:	d9898993          	addi	s3,s3,-616 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0202720:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202724:	47c5                	li	a5,17
ffffffffc0202726:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202728:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020272a:	02f6f763          	bleu	a5,a3,ffffffffc0202758 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020272e:	6585                	lui	a1,0x1
ffffffffc0202730:	15fd                	addi	a1,a1,-1
ffffffffc0202732:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202734:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202738:	48c77a63          	bleu	a2,a4,ffffffffc0202bcc <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020273c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020273e:	75fd                	lui	a1,0xfffff
ffffffffc0202740:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202742:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202744:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202746:	40d786b3          	sub	a3,a5,a3
ffffffffc020274a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020274c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202750:	953a                	add	a0,a0,a4
ffffffffc0202752:	9602                	jalr	a2
ffffffffc0202754:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202758:	00005517          	auipc	a0,0x5
ffffffffc020275c:	fc050513          	addi	a0,a0,-64 # ffffffffc0207718 <default_pmm_manager+0x220>
ffffffffc0202760:	a2ffd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202764:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202766:	000aa417          	auipc	s0,0xaa
ffffffffc020276a:	ce240413          	addi	s0,s0,-798 # ffffffffc02ac448 <boot_pgdir>
    pmm_manager->check();
ffffffffc020276e:	7b9c                	ld	a5,48(a5)
ffffffffc0202770:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202772:	00005517          	auipc	a0,0x5
ffffffffc0202776:	fbe50513          	addi	a0,a0,-66 # ffffffffc0207730 <default_pmm_manager+0x238>
ffffffffc020277a:	a15fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020277e:	00009697          	auipc	a3,0x9
ffffffffc0202782:	88268693          	addi	a3,a3,-1918 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202786:	000aa797          	auipc	a5,0xaa
ffffffffc020278a:	ccd7b123          	sd	a3,-830(a5) # ffffffffc02ac448 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020278e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202792:	10f6eae3          	bltu	a3,a5,ffffffffc02030a6 <pmm_init+0xa72>
ffffffffc0202796:	0009b783          	ld	a5,0(s3)
ffffffffc020279a:	8e9d                	sub	a3,a3,a5
ffffffffc020279c:	000aa797          	auipc	a5,0xaa
ffffffffc02027a0:	d0d7be23          	sd	a3,-740(a5) # ffffffffc02ac4b8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02027a4:	f7cff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027a8:	6098                	ld	a4,0(s1)
ffffffffc02027aa:	c80007b7          	lui	a5,0xc8000
ffffffffc02027ae:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02027b0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027b2:	0ce7eae3          	bltu	a5,a4,ffffffffc0203086 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027b6:	6008                	ld	a0,0(s0)
ffffffffc02027b8:	44050463          	beqz	a0,ffffffffc0202c00 <pmm_init+0x5cc>
ffffffffc02027bc:	6785                	lui	a5,0x1
ffffffffc02027be:	17fd                	addi	a5,a5,-1
ffffffffc02027c0:	8fe9                	and	a5,a5,a0
ffffffffc02027c2:	2781                	sext.w	a5,a5
ffffffffc02027c4:	42079e63          	bnez	a5,ffffffffc0202c00 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027c8:	4601                	li	a2,0
ffffffffc02027ca:	4581                	li	a1,0
ffffffffc02027cc:	967ff0ef          	jal	ra,ffffffffc0202132 <get_page>
ffffffffc02027d0:	78051b63          	bnez	a0,ffffffffc0202f66 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027d4:	4505                	li	a0,1
ffffffffc02027d6:	e7cff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02027da:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027dc:	6008                	ld	a0,0(s0)
ffffffffc02027de:	4681                	li	a3,0
ffffffffc02027e0:	4601                	li	a2,0
ffffffffc02027e2:	85d6                	mv	a1,s5
ffffffffc02027e4:	d93ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc02027e8:	7a051f63          	bnez	a0,ffffffffc0202fa6 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027ec:	6008                	ld	a0,0(s0)
ffffffffc02027ee:	4601                	li	a2,0
ffffffffc02027f0:	4581                	li	a1,0
ffffffffc02027f2:	f6eff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02027f6:	78050863          	beqz	a0,ffffffffc0202f86 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027fa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027fc:	0017f713          	andi	a4,a5,1
ffffffffc0202800:	3e070463          	beqz	a4,ffffffffc0202be8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202804:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202806:	078a                	slli	a5,a5,0x2
ffffffffc0202808:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020280a:	3ce7f163          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020280e:	00093683          	ld	a3,0(s2)
ffffffffc0202812:	fff80637          	lui	a2,0xfff80
ffffffffc0202816:	97b2                	add	a5,a5,a2
ffffffffc0202818:	079a                	slli	a5,a5,0x6
ffffffffc020281a:	97b6                	add	a5,a5,a3
ffffffffc020281c:	72fa9563          	bne	s5,a5,ffffffffc0202f46 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202820:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0202824:	4785                	li	a5,1
ffffffffc0202826:	70fb9063          	bne	s7,a5,ffffffffc0202f26 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020282a:	6008                	ld	a0,0(s0)
ffffffffc020282c:	76fd                	lui	a3,0xfffff
ffffffffc020282e:	611c                	ld	a5,0(a0)
ffffffffc0202830:	078a                	slli	a5,a5,0x2
ffffffffc0202832:	8ff5                	and	a5,a5,a3
ffffffffc0202834:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202838:	66e67e63          	bleu	a4,a2,ffffffffc0202eb4 <pmm_init+0x880>
ffffffffc020283c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202840:	97e2                	add	a5,a5,s8
ffffffffc0202842:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0202846:	0b0a                	slli	s6,s6,0x2
ffffffffc0202848:	00db7b33          	and	s6,s6,a3
ffffffffc020284c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202850:	56e7f863          	bleu	a4,a5,ffffffffc0202dc0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202854:	4601                	li	a2,0
ffffffffc0202856:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202858:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020285a:	f06ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020285e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202860:	55651063          	bne	a0,s6,ffffffffc0202da0 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202864:	4505                	li	a0,1
ffffffffc0202866:	decff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020286a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	46d1                	li	a3,20
ffffffffc0202870:	6605                	lui	a2,0x1
ffffffffc0202872:	85da                	mv	a1,s6
ffffffffc0202874:	d03ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0202878:	50051463          	bnez	a0,ffffffffc0202d80 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020287c:	6008                	ld	a0,0(s0)
ffffffffc020287e:	4601                	li	a2,0
ffffffffc0202880:	6585                	lui	a1,0x1
ffffffffc0202882:	edeff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202886:	4c050d63          	beqz	a0,ffffffffc0202d60 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020288a:	611c                	ld	a5,0(a0)
ffffffffc020288c:	0107f713          	andi	a4,a5,16
ffffffffc0202890:	4a070863          	beqz	a4,ffffffffc0202d40 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202894:	8b91                	andi	a5,a5,4
ffffffffc0202896:	48078563          	beqz	a5,ffffffffc0202d20 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020289a:	6008                	ld	a0,0(s0)
ffffffffc020289c:	611c                	ld	a5,0(a0)
ffffffffc020289e:	8bc1                	andi	a5,a5,16
ffffffffc02028a0:	46078063          	beqz	a5,ffffffffc0202d00 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02028a4:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
ffffffffc02028a8:	43779c63          	bne	a5,s7,ffffffffc0202ce0 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02028ac:	4681                	li	a3,0
ffffffffc02028ae:	6605                	lui	a2,0x1
ffffffffc02028b0:	85d6                	mv	a1,s5
ffffffffc02028b2:	cc5ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc02028b6:	40051563          	bnez	a0,ffffffffc0202cc0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028ba:	000aa703          	lw	a4,0(s5)
ffffffffc02028be:	4789                	li	a5,2
ffffffffc02028c0:	3ef71063          	bne	a4,a5,ffffffffc0202ca0 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028c4:	000b2783          	lw	a5,0(s6)
ffffffffc02028c8:	3a079c63          	bnez	a5,ffffffffc0202c80 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028cc:	6008                	ld	a0,0(s0)
ffffffffc02028ce:	4601                	li	a2,0
ffffffffc02028d0:	6585                	lui	a1,0x1
ffffffffc02028d2:	e8eff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02028d6:	38050563          	beqz	a0,ffffffffc0202c60 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028da:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028dc:	00177793          	andi	a5,a4,1
ffffffffc02028e0:	30078463          	beqz	a5,ffffffffc0202be8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028e4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028e6:	00271793          	slli	a5,a4,0x2
ffffffffc02028ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028ec:	2ed7f063          	bleu	a3,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028f0:	00093683          	ld	a3,0(s2)
ffffffffc02028f4:	fff80637          	lui	a2,0xfff80
ffffffffc02028f8:	97b2                	add	a5,a5,a2
ffffffffc02028fa:	079a                	slli	a5,a5,0x6
ffffffffc02028fc:	97b6                	add	a5,a5,a3
ffffffffc02028fe:	32fa9163          	bne	s5,a5,ffffffffc0202c20 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202902:	8b41                	andi	a4,a4,16
ffffffffc0202904:	70071163          	bnez	a4,ffffffffc0203006 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202908:	6008                	ld	a0,0(s0)
ffffffffc020290a:	4581                	li	a1,0
ffffffffc020290c:	bf7ff0ef          	jal	ra,ffffffffc0202502 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202910:	000aa703          	lw	a4,0(s5)
ffffffffc0202914:	4785                	li	a5,1
ffffffffc0202916:	6cf71863          	bne	a4,a5,ffffffffc0202fe6 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020291a:	000b2783          	lw	a5,0(s6)
ffffffffc020291e:	6a079463          	bnez	a5,ffffffffc0202fc6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202922:	6008                	ld	a0,0(s0)
ffffffffc0202924:	6585                	lui	a1,0x1
ffffffffc0202926:	bddff0ef          	jal	ra,ffffffffc0202502 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020292a:	000aa783          	lw	a5,0(s5)
ffffffffc020292e:	50079363          	bnez	a5,ffffffffc0202e34 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202932:	000b2783          	lw	a5,0(s6)
ffffffffc0202936:	4c079f63          	bnez	a5,ffffffffc0202e14 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020293a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020293e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202940:	000ab783          	ld	a5,0(s5)
ffffffffc0202944:	078a                	slli	a5,a5,0x2
ffffffffc0202946:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202948:	28c7f263          	bleu	a2,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020294c:	fff80737          	lui	a4,0xfff80
ffffffffc0202950:	00093503          	ld	a0,0(s2)
ffffffffc0202954:	97ba                	add	a5,a5,a4
ffffffffc0202956:	079a                	slli	a5,a5,0x6
ffffffffc0202958:	00f50733          	add	a4,a0,a5
ffffffffc020295c:	4314                	lw	a3,0(a4)
ffffffffc020295e:	4705                	li	a4,1
ffffffffc0202960:	48e69a63          	bne	a3,a4,ffffffffc0202df4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202964:	8799                	srai	a5,a5,0x6
ffffffffc0202966:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020296a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020296c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020296e:	8331                	srli	a4,a4,0xc
ffffffffc0202970:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202972:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202974:	46c77363          	bleu	a2,a4,ffffffffc0202dda <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202978:	0009b683          	ld	a3,0(s3)
ffffffffc020297c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020297e:	639c                	ld	a5,0(a5)
ffffffffc0202980:	078a                	slli	a5,a5,0x2
ffffffffc0202982:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202984:	24c7f463          	bleu	a2,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202988:	416787b3          	sub	a5,a5,s6
ffffffffc020298c:	079a                	slli	a5,a5,0x6
ffffffffc020298e:	953e                	add	a0,a0,a5
ffffffffc0202990:	4585                	li	a1,1
ffffffffc0202992:	d48ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202996:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020299a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020299c:	078a                	slli	a5,a5,0x2
ffffffffc020299e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029a0:	22e7f663          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02029a4:	00093503          	ld	a0,0(s2)
ffffffffc02029a8:	416787b3          	sub	a5,a5,s6
ffffffffc02029ac:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02029ae:	953e                	add	a0,a0,a5
ffffffffc02029b0:	4585                	li	a1,1
ffffffffc02029b2:	d28ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029b6:	601c                	ld	a5,0(s0)
ffffffffc02029b8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029bc:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029c0:	d60ff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc02029c4:	68aa1163          	bne	s4,a0,ffffffffc0203046 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029c8:	00005517          	auipc	a0,0x5
ffffffffc02029cc:	07850513          	addi	a0,a0,120 # ffffffffc0207a40 <default_pmm_manager+0x548>
ffffffffc02029d0:	fbefd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029d4:	d4cff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029d8:	6098                	ld	a4,0(s1)
ffffffffc02029da:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029de:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029e0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029e4:	18d7f563          	bleu	a3,a5,ffffffffc0202b6e <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029e8:	83b1                	srli	a5,a5,0xc
ffffffffc02029ea:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029ec:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029f0:	1ae7f163          	bleu	a4,a5,ffffffffc0202b92 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029f4:	7bfd                	lui	s7,0xfffff
ffffffffc02029f6:	6b05                	lui	s6,0x1
ffffffffc02029f8:	a029                	j	ffffffffc0202a02 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029fa:	00cad713          	srli	a4,s5,0xc
ffffffffc02029fe:	18f77a63          	bleu	a5,a4,ffffffffc0202b92 <pmm_init+0x55e>
ffffffffc0202a02:	0009b583          	ld	a1,0(s3)
ffffffffc0202a06:	4601                	li	a2,0
ffffffffc0202a08:	95d6                	add	a1,a1,s5
ffffffffc0202a0a:	d56ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202a0e:	16050263          	beqz	a0,ffffffffc0202b72 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a12:	611c                	ld	a5,0(a0)
ffffffffc0202a14:	078a                	slli	a5,a5,0x2
ffffffffc0202a16:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a1a:	19579963          	bne	a5,s5,ffffffffc0202bac <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a1e:	609c                	ld	a5,0(s1)
ffffffffc0202a20:	9ada                	add	s5,s5,s6
ffffffffc0202a22:	6008                	ld	a0,0(s0)
ffffffffc0202a24:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a28:	fceae9e3          	bltu	s5,a4,ffffffffc02029fa <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a2c:	611c                	ld	a5,0(a0)
ffffffffc0202a2e:	62079c63          	bnez	a5,ffffffffc0203066 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a32:	4505                	li	a0,1
ffffffffc0202a34:	c1eff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0202a38:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a3a:	6008                	ld	a0,0(s0)
ffffffffc0202a3c:	4699                	li	a3,6
ffffffffc0202a3e:	10000613          	li	a2,256
ffffffffc0202a42:	85d6                	mv	a1,s5
ffffffffc0202a44:	b33ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0202a48:	1e051c63          	bnez	a0,ffffffffc0202c40 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a4c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a50:	4785                	li	a5,1
ffffffffc0202a52:	44f71163          	bne	a4,a5,ffffffffc0202e94 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a56:	6008                	ld	a0,0(s0)
ffffffffc0202a58:	6b05                	lui	s6,0x1
ffffffffc0202a5a:	4699                	li	a3,6
ffffffffc0202a5c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8470>
ffffffffc0202a60:	85d6                	mv	a1,s5
ffffffffc0202a62:	b15ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc0202a66:	40051763          	bnez	a0,ffffffffc0202e74 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a6a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a6e:	4789                	li	a5,2
ffffffffc0202a70:	3ef71263          	bne	a4,a5,ffffffffc0202e54 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a74:	00005597          	auipc	a1,0x5
ffffffffc0202a78:	10458593          	addi	a1,a1,260 # ffffffffc0207b78 <default_pmm_manager+0x680>
ffffffffc0202a7c:	10000513          	li	a0,256
ffffffffc0202a80:	4b7030ef          	jal	ra,ffffffffc0206736 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a84:	100b0593          	addi	a1,s6,256
ffffffffc0202a88:	10000513          	li	a0,256
ffffffffc0202a8c:	4bd030ef          	jal	ra,ffffffffc0206748 <strcmp>
ffffffffc0202a90:	44051b63          	bnez	a0,ffffffffc0202ee6 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a94:	00093683          	ld	a3,0(s2)
ffffffffc0202a98:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a9c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a9e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202aa2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202aa4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202aa6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202aa8:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202aac:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ab0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ab2:	10f77f63          	bleu	a5,a4,ffffffffc0202bd0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ab6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aba:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202abe:	96be                	add	a3,a3,a5
ffffffffc0202ac0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52b48>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ac4:	42f030ef          	jal	ra,ffffffffc02066f2 <strlen>
ffffffffc0202ac8:	54051f63          	bnez	a0,ffffffffc0203026 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202acc:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ad0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52a48>
ffffffffc0202ad6:	068a                	slli	a3,a3,0x2
ffffffffc0202ad8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ada:	0ef6f963          	bleu	a5,a3,ffffffffc0202bcc <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202ade:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ae2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ae4:	0efb7663          	bleu	a5,s6,ffffffffc0202bd0 <pmm_init+0x59c>
ffffffffc0202ae8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202aec:	4585                	li	a1,1
ffffffffc0202aee:	8556                	mv	a0,s5
ffffffffc0202af0:	99b6                	add	s3,s3,a3
ffffffffc0202af2:	be8ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202af6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202afa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202afc:	078a                	slli	a5,a5,0x2
ffffffffc0202afe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b00:	0ce7f663          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b04:	00093503          	ld	a0,0(s2)
ffffffffc0202b08:	fff809b7          	lui	s3,0xfff80
ffffffffc0202b0c:	97ce                	add	a5,a5,s3
ffffffffc0202b0e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b10:	953e                	add	a0,a0,a5
ffffffffc0202b12:	4585                	li	a1,1
ffffffffc0202b14:	bc6ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b18:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b1c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b1e:	078a                	slli	a5,a5,0x2
ffffffffc0202b20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b22:	0ae7f563          	bleu	a4,a5,ffffffffc0202bcc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b26:	00093503          	ld	a0,0(s2)
ffffffffc0202b2a:	97ce                	add	a5,a5,s3
ffffffffc0202b2c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b2e:	953e                	add	a0,a0,a5
ffffffffc0202b30:	4585                	li	a1,1
ffffffffc0202b32:	ba8ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b36:	601c                	ld	a5,0(s0)
ffffffffc0202b38:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b3c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b40:	be0ff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0202b44:	3caa1163          	bne	s4,a0,ffffffffc0202f06 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b48:	00005517          	auipc	a0,0x5
ffffffffc0202b4c:	0a850513          	addi	a0,a0,168 # ffffffffc0207bf0 <default_pmm_manager+0x6f8>
ffffffffc0202b50:	e3efd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b54:	6406                	ld	s0,64(sp)
ffffffffc0202b56:	60a6                	ld	ra,72(sp)
ffffffffc0202b58:	74e2                	ld	s1,56(sp)
ffffffffc0202b5a:	7942                	ld	s2,48(sp)
ffffffffc0202b5c:	79a2                	ld	s3,40(sp)
ffffffffc0202b5e:	7a02                	ld	s4,32(sp)
ffffffffc0202b60:	6ae2                	ld	s5,24(sp)
ffffffffc0202b62:	6b42                	ld	s6,16(sp)
ffffffffc0202b64:	6ba2                	ld	s7,8(sp)
ffffffffc0202b66:	6c02                	ld	s8,0(sp)
ffffffffc0202b68:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b6a:	8c8ff06f          	j	ffffffffc0201c32 <kmalloc_init>
ffffffffc0202b6e:	6008                	ld	a0,0(s0)
ffffffffc0202b70:	bd75                	j	ffffffffc0202a2c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b72:	00005697          	auipc	a3,0x5
ffffffffc0202b76:	eee68693          	addi	a3,a3,-274 # ffffffffc0207a60 <default_pmm_manager+0x568>
ffffffffc0202b7a:	00004617          	auipc	a2,0x4
ffffffffc0202b7e:	23660613          	addi	a2,a2,566 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202b82:	23500593          	li	a1,565
ffffffffc0202b86:	00005517          	auipc	a0,0x5
ffffffffc0202b8a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202b8e:	8f7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202b92:	86d6                	mv	a3,s5
ffffffffc0202b94:	00005617          	auipc	a2,0x5
ffffffffc0202b98:	9b460613          	addi	a2,a2,-1612 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202b9c:	23500593          	li	a1,565
ffffffffc0202ba0:	00005517          	auipc	a0,0x5
ffffffffc0202ba4:	af850513          	addi	a0,a0,-1288 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202ba8:	8ddfd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bac:	00005697          	auipc	a3,0x5
ffffffffc0202bb0:	ef468693          	addi	a3,a3,-268 # ffffffffc0207aa0 <default_pmm_manager+0x5a8>
ffffffffc0202bb4:	00004617          	auipc	a2,0x4
ffffffffc0202bb8:	1fc60613          	addi	a2,a2,508 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202bbc:	23600593          	li	a1,566
ffffffffc0202bc0:	00005517          	auipc	a0,0x5
ffffffffc0202bc4:	ad850513          	addi	a0,a0,-1320 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202bc8:	8bdfd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202bcc:	a6aff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bd0:	00005617          	auipc	a2,0x5
ffffffffc0202bd4:	97860613          	addi	a2,a2,-1672 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202bd8:	06900593          	li	a1,105
ffffffffc0202bdc:	00005517          	auipc	a0,0x5
ffffffffc0202be0:	99450513          	addi	a0,a0,-1644 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0202be4:	8a1fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202be8:	00005617          	auipc	a2,0x5
ffffffffc0202bec:	c4860613          	addi	a2,a2,-952 # ffffffffc0207830 <default_pmm_manager+0x338>
ffffffffc0202bf0:	07400593          	li	a1,116
ffffffffc0202bf4:	00005517          	auipc	a0,0x5
ffffffffc0202bf8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0202bfc:	889fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c00:	00005697          	auipc	a3,0x5
ffffffffc0202c04:	b7068693          	addi	a3,a3,-1168 # ffffffffc0207770 <default_pmm_manager+0x278>
ffffffffc0202c08:	00004617          	auipc	a2,0x4
ffffffffc0202c0c:	1a860613          	addi	a2,a2,424 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202c10:	1f900593          	li	a1,505
ffffffffc0202c14:	00005517          	auipc	a0,0x5
ffffffffc0202c18:	a8450513          	addi	a0,a0,-1404 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202c1c:	869fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c20:	00005697          	auipc	a3,0x5
ffffffffc0202c24:	c3868693          	addi	a3,a3,-968 # ffffffffc0207858 <default_pmm_manager+0x360>
ffffffffc0202c28:	00004617          	auipc	a2,0x4
ffffffffc0202c2c:	18860613          	addi	a2,a2,392 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202c30:	21500593          	li	a1,533
ffffffffc0202c34:	00005517          	auipc	a0,0x5
ffffffffc0202c38:	a6450513          	addi	a0,a0,-1436 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202c3c:	849fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c40:	00005697          	auipc	a3,0x5
ffffffffc0202c44:	e9068693          	addi	a3,a3,-368 # ffffffffc0207ad0 <default_pmm_manager+0x5d8>
ffffffffc0202c48:	00004617          	auipc	a2,0x4
ffffffffc0202c4c:	16860613          	addi	a2,a2,360 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202c50:	23e00593          	li	a1,574
ffffffffc0202c54:	00005517          	auipc	a0,0x5
ffffffffc0202c58:	a4450513          	addi	a0,a0,-1468 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202c5c:	829fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c60:	00005697          	auipc	a3,0x5
ffffffffc0202c64:	c8868693          	addi	a3,a3,-888 # ffffffffc02078e8 <default_pmm_manager+0x3f0>
ffffffffc0202c68:	00004617          	auipc	a2,0x4
ffffffffc0202c6c:	14860613          	addi	a2,a2,328 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202c70:	21400593          	li	a1,532
ffffffffc0202c74:	00005517          	auipc	a0,0x5
ffffffffc0202c78:	a2450513          	addi	a0,a0,-1500 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202c7c:	809fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c80:	00005697          	auipc	a3,0x5
ffffffffc0202c84:	d3068693          	addi	a3,a3,-720 # ffffffffc02079b0 <default_pmm_manager+0x4b8>
ffffffffc0202c88:	00004617          	auipc	a2,0x4
ffffffffc0202c8c:	12860613          	addi	a2,a2,296 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202c90:	21300593          	li	a1,531
ffffffffc0202c94:	00005517          	auipc	a0,0x5
ffffffffc0202c98:	a0450513          	addi	a0,a0,-1532 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202c9c:	fe8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202ca0:	00005697          	auipc	a3,0x5
ffffffffc0202ca4:	cf868693          	addi	a3,a3,-776 # ffffffffc0207998 <default_pmm_manager+0x4a0>
ffffffffc0202ca8:	00004617          	auipc	a2,0x4
ffffffffc0202cac:	10860613          	addi	a2,a2,264 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202cb0:	21200593          	li	a1,530
ffffffffc0202cb4:	00005517          	auipc	a0,0x5
ffffffffc0202cb8:	9e450513          	addi	a0,a0,-1564 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202cbc:	fc8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cc0:	00005697          	auipc	a3,0x5
ffffffffc0202cc4:	ca868693          	addi	a3,a3,-856 # ffffffffc0207968 <default_pmm_manager+0x470>
ffffffffc0202cc8:	00004617          	auipc	a2,0x4
ffffffffc0202ccc:	0e860613          	addi	a2,a2,232 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202cd0:	21100593          	li	a1,529
ffffffffc0202cd4:	00005517          	auipc	a0,0x5
ffffffffc0202cd8:	9c450513          	addi	a0,a0,-1596 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202cdc:	fa8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202ce0:	00005697          	auipc	a3,0x5
ffffffffc0202ce4:	c7068693          	addi	a3,a3,-912 # ffffffffc0207950 <default_pmm_manager+0x458>
ffffffffc0202ce8:	00004617          	auipc	a2,0x4
ffffffffc0202cec:	0c860613          	addi	a2,a2,200 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202cf0:	20f00593          	li	a1,527
ffffffffc0202cf4:	00005517          	auipc	a0,0x5
ffffffffc0202cf8:	9a450513          	addi	a0,a0,-1628 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202cfc:	f88fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202d00:	00005697          	auipc	a3,0x5
ffffffffc0202d04:	c3868693          	addi	a3,a3,-968 # ffffffffc0207938 <default_pmm_manager+0x440>
ffffffffc0202d08:	00004617          	auipc	a2,0x4
ffffffffc0202d0c:	0a860613          	addi	a2,a2,168 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202d10:	20e00593          	li	a1,526
ffffffffc0202d14:	00005517          	auipc	a0,0x5
ffffffffc0202d18:	98450513          	addi	a0,a0,-1660 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202d1c:	f68fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d20:	00005697          	auipc	a3,0x5
ffffffffc0202d24:	c0868693          	addi	a3,a3,-1016 # ffffffffc0207928 <default_pmm_manager+0x430>
ffffffffc0202d28:	00004617          	auipc	a2,0x4
ffffffffc0202d2c:	08860613          	addi	a2,a2,136 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202d30:	20d00593          	li	a1,525
ffffffffc0202d34:	00005517          	auipc	a0,0x5
ffffffffc0202d38:	96450513          	addi	a0,a0,-1692 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202d3c:	f48fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d40:	00005697          	auipc	a3,0x5
ffffffffc0202d44:	bd868693          	addi	a3,a3,-1064 # ffffffffc0207918 <default_pmm_manager+0x420>
ffffffffc0202d48:	00004617          	auipc	a2,0x4
ffffffffc0202d4c:	06860613          	addi	a2,a2,104 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202d50:	20c00593          	li	a1,524
ffffffffc0202d54:	00005517          	auipc	a0,0x5
ffffffffc0202d58:	94450513          	addi	a0,a0,-1724 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202d5c:	f28fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d60:	00005697          	auipc	a3,0x5
ffffffffc0202d64:	b8868693          	addi	a3,a3,-1144 # ffffffffc02078e8 <default_pmm_manager+0x3f0>
ffffffffc0202d68:	00004617          	auipc	a2,0x4
ffffffffc0202d6c:	04860613          	addi	a2,a2,72 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202d70:	20b00593          	li	a1,523
ffffffffc0202d74:	00005517          	auipc	a0,0x5
ffffffffc0202d78:	92450513          	addi	a0,a0,-1756 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202d7c:	f08fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d80:	00005697          	auipc	a3,0x5
ffffffffc0202d84:	b3068693          	addi	a3,a3,-1232 # ffffffffc02078b0 <default_pmm_manager+0x3b8>
ffffffffc0202d88:	00004617          	auipc	a2,0x4
ffffffffc0202d8c:	02860613          	addi	a2,a2,40 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202d90:	20a00593          	li	a1,522
ffffffffc0202d94:	00005517          	auipc	a0,0x5
ffffffffc0202d98:	90450513          	addi	a0,a0,-1788 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202d9c:	ee8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202da0:	00005697          	auipc	a3,0x5
ffffffffc0202da4:	ae868693          	addi	a3,a3,-1304 # ffffffffc0207888 <default_pmm_manager+0x390>
ffffffffc0202da8:	00004617          	auipc	a2,0x4
ffffffffc0202dac:	00860613          	addi	a2,a2,8 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202db0:	20700593          	li	a1,519
ffffffffc0202db4:	00005517          	auipc	a0,0x5
ffffffffc0202db8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202dbc:	ec8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202dc0:	86da                	mv	a3,s6
ffffffffc0202dc2:	00004617          	auipc	a2,0x4
ffffffffc0202dc6:	78660613          	addi	a2,a2,1926 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202dca:	20600593          	li	a1,518
ffffffffc0202dce:	00005517          	auipc	a0,0x5
ffffffffc0202dd2:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202dd6:	eaefd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dda:	86be                	mv	a3,a5
ffffffffc0202ddc:	00004617          	auipc	a2,0x4
ffffffffc0202de0:	76c60613          	addi	a2,a2,1900 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202de4:	06900593          	li	a1,105
ffffffffc0202de8:	00004517          	auipc	a0,0x4
ffffffffc0202dec:	78850513          	addi	a0,a0,1928 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0202df0:	e94fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202df4:	00005697          	auipc	a3,0x5
ffffffffc0202df8:	c0468693          	addi	a3,a3,-1020 # ffffffffc02079f8 <default_pmm_manager+0x500>
ffffffffc0202dfc:	00004617          	auipc	a2,0x4
ffffffffc0202e00:	fb460613          	addi	a2,a2,-76 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202e04:	22000593          	li	a1,544
ffffffffc0202e08:	00005517          	auipc	a0,0x5
ffffffffc0202e0c:	89050513          	addi	a0,a0,-1904 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202e10:	e74fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e14:	00005697          	auipc	a3,0x5
ffffffffc0202e18:	b9c68693          	addi	a3,a3,-1124 # ffffffffc02079b0 <default_pmm_manager+0x4b8>
ffffffffc0202e1c:	00004617          	auipc	a2,0x4
ffffffffc0202e20:	f9460613          	addi	a2,a2,-108 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202e24:	21e00593          	li	a1,542
ffffffffc0202e28:	00005517          	auipc	a0,0x5
ffffffffc0202e2c:	87050513          	addi	a0,a0,-1936 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202e30:	e54fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e34:	00005697          	auipc	a3,0x5
ffffffffc0202e38:	bac68693          	addi	a3,a3,-1108 # ffffffffc02079e0 <default_pmm_manager+0x4e8>
ffffffffc0202e3c:	00004617          	auipc	a2,0x4
ffffffffc0202e40:	f7460613          	addi	a2,a2,-140 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202e44:	21d00593          	li	a1,541
ffffffffc0202e48:	00005517          	auipc	a0,0x5
ffffffffc0202e4c:	85050513          	addi	a0,a0,-1968 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202e50:	e34fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e54:	00005697          	auipc	a3,0x5
ffffffffc0202e58:	d0c68693          	addi	a3,a3,-756 # ffffffffc0207b60 <default_pmm_manager+0x668>
ffffffffc0202e5c:	00004617          	auipc	a2,0x4
ffffffffc0202e60:	f5460613          	addi	a2,a2,-172 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202e64:	24100593          	li	a1,577
ffffffffc0202e68:	00005517          	auipc	a0,0x5
ffffffffc0202e6c:	83050513          	addi	a0,a0,-2000 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202e70:	e14fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e74:	00005697          	auipc	a3,0x5
ffffffffc0202e78:	cac68693          	addi	a3,a3,-852 # ffffffffc0207b20 <default_pmm_manager+0x628>
ffffffffc0202e7c:	00004617          	auipc	a2,0x4
ffffffffc0202e80:	f3460613          	addi	a2,a2,-204 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202e84:	24000593          	li	a1,576
ffffffffc0202e88:	00005517          	auipc	a0,0x5
ffffffffc0202e8c:	81050513          	addi	a0,a0,-2032 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202e90:	df4fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e94:	00005697          	auipc	a3,0x5
ffffffffc0202e98:	c7468693          	addi	a3,a3,-908 # ffffffffc0207b08 <default_pmm_manager+0x610>
ffffffffc0202e9c:	00004617          	auipc	a2,0x4
ffffffffc0202ea0:	f1460613          	addi	a2,a2,-236 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202ea4:	23f00593          	li	a1,575
ffffffffc0202ea8:	00004517          	auipc	a0,0x4
ffffffffc0202eac:	7f050513          	addi	a0,a0,2032 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202eb0:	dd4fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202eb4:	86be                	mv	a3,a5
ffffffffc0202eb6:	00004617          	auipc	a2,0x4
ffffffffc0202eba:	69260613          	addi	a2,a2,1682 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0202ebe:	20500593          	li	a1,517
ffffffffc0202ec2:	00004517          	auipc	a0,0x4
ffffffffc0202ec6:	7d650513          	addi	a0,a0,2006 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202eca:	dbafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ece:	00004617          	auipc	a2,0x4
ffffffffc0202ed2:	6b260613          	addi	a2,a2,1714 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc0202ed6:	07f00593          	li	a1,127
ffffffffc0202eda:	00004517          	auipc	a0,0x4
ffffffffc0202ede:	7be50513          	addi	a0,a0,1982 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202ee2:	da2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ee6:	00005697          	auipc	a3,0x5
ffffffffc0202eea:	caa68693          	addi	a3,a3,-854 # ffffffffc0207b90 <default_pmm_manager+0x698>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	ec260613          	addi	a2,a2,-318 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202ef6:	24500593          	li	a1,581
ffffffffc0202efa:	00004517          	auipc	a0,0x4
ffffffffc0202efe:	79e50513          	addi	a0,a0,1950 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202f02:	d82fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207a20 <default_pmm_manager+0x528>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	ea260613          	addi	a2,a2,-350 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202f16:	25100593          	li	a1,593
ffffffffc0202f1a:	00004517          	auipc	a0,0x4
ffffffffc0202f1e:	77e50513          	addi	a0,a0,1918 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202f22:	d62fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f26:	00005697          	auipc	a3,0x5
ffffffffc0202f2a:	94a68693          	addi	a3,a3,-1718 # ffffffffc0207870 <default_pmm_manager+0x378>
ffffffffc0202f2e:	00004617          	auipc	a2,0x4
ffffffffc0202f32:	e8260613          	addi	a2,a2,-382 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202f36:	20300593          	li	a1,515
ffffffffc0202f3a:	00004517          	auipc	a0,0x4
ffffffffc0202f3e:	75e50513          	addi	a0,a0,1886 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202f42:	d42fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f46:	00005697          	auipc	a3,0x5
ffffffffc0202f4a:	91268693          	addi	a3,a3,-1774 # ffffffffc0207858 <default_pmm_manager+0x360>
ffffffffc0202f4e:	00004617          	auipc	a2,0x4
ffffffffc0202f52:	e6260613          	addi	a2,a2,-414 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202f56:	20200593          	li	a1,514
ffffffffc0202f5a:	00004517          	auipc	a0,0x4
ffffffffc0202f5e:	73e50513          	addi	a0,a0,1854 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202f62:	d22fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f66:	00005697          	auipc	a3,0x5
ffffffffc0202f6a:	84268693          	addi	a3,a3,-1982 # ffffffffc02077a8 <default_pmm_manager+0x2b0>
ffffffffc0202f6e:	00004617          	auipc	a2,0x4
ffffffffc0202f72:	e4260613          	addi	a2,a2,-446 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202f76:	1fa00593          	li	a1,506
ffffffffc0202f7a:	00004517          	auipc	a0,0x4
ffffffffc0202f7e:	71e50513          	addi	a0,a0,1822 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202f82:	d02fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f86:	00005697          	auipc	a3,0x5
ffffffffc0202f8a:	87a68693          	addi	a3,a3,-1926 # ffffffffc0207800 <default_pmm_manager+0x308>
ffffffffc0202f8e:	00004617          	auipc	a2,0x4
ffffffffc0202f92:	e2260613          	addi	a2,a2,-478 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202f96:	20100593          	li	a1,513
ffffffffc0202f9a:	00004517          	auipc	a0,0x4
ffffffffc0202f9e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202fa2:	ce2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202fa6:	00005697          	auipc	a3,0x5
ffffffffc0202faa:	82a68693          	addi	a3,a3,-2006 # ffffffffc02077d0 <default_pmm_manager+0x2d8>
ffffffffc0202fae:	00004617          	auipc	a2,0x4
ffffffffc0202fb2:	e0260613          	addi	a2,a2,-510 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202fb6:	1fe00593          	li	a1,510
ffffffffc0202fba:	00004517          	auipc	a0,0x4
ffffffffc0202fbe:	6de50513          	addi	a0,a0,1758 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202fc2:	cc2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fc6:	00005697          	auipc	a3,0x5
ffffffffc0202fca:	9ea68693          	addi	a3,a3,-1558 # ffffffffc02079b0 <default_pmm_manager+0x4b8>
ffffffffc0202fce:	00004617          	auipc	a2,0x4
ffffffffc0202fd2:	de260613          	addi	a2,a2,-542 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202fd6:	21a00593          	li	a1,538
ffffffffc0202fda:	00004517          	auipc	a0,0x4
ffffffffc0202fde:	6be50513          	addi	a0,a0,1726 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0202fe2:	ca2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fe6:	00005697          	auipc	a3,0x5
ffffffffc0202fea:	88a68693          	addi	a3,a3,-1910 # ffffffffc0207870 <default_pmm_manager+0x378>
ffffffffc0202fee:	00004617          	auipc	a2,0x4
ffffffffc0202ff2:	dc260613          	addi	a2,a2,-574 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0202ff6:	21900593          	li	a1,537
ffffffffc0202ffa:	00004517          	auipc	a0,0x4
ffffffffc0202ffe:	69e50513          	addi	a0,a0,1694 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203002:	c82fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203006:	00005697          	auipc	a3,0x5
ffffffffc020300a:	9c268693          	addi	a3,a3,-1598 # ffffffffc02079c8 <default_pmm_manager+0x4d0>
ffffffffc020300e:	00004617          	auipc	a2,0x4
ffffffffc0203012:	da260613          	addi	a2,a2,-606 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203016:	21600593          	li	a1,534
ffffffffc020301a:	00004517          	auipc	a0,0x4
ffffffffc020301e:	67e50513          	addi	a0,a0,1662 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203022:	c62fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203026:	00005697          	auipc	a3,0x5
ffffffffc020302a:	ba268693          	addi	a3,a3,-1118 # ffffffffc0207bc8 <default_pmm_manager+0x6d0>
ffffffffc020302e:	00004617          	auipc	a2,0x4
ffffffffc0203032:	d8260613          	addi	a2,a2,-638 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203036:	24800593          	li	a1,584
ffffffffc020303a:	00004517          	auipc	a0,0x4
ffffffffc020303e:	65e50513          	addi	a0,a0,1630 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203042:	c42fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203046:	00005697          	auipc	a3,0x5
ffffffffc020304a:	9da68693          	addi	a3,a3,-1574 # ffffffffc0207a20 <default_pmm_manager+0x528>
ffffffffc020304e:	00004617          	auipc	a2,0x4
ffffffffc0203052:	d6260613          	addi	a2,a2,-670 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203056:	22800593          	li	a1,552
ffffffffc020305a:	00004517          	auipc	a0,0x4
ffffffffc020305e:	63e50513          	addi	a0,a0,1598 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203062:	c22fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203066:	00005697          	auipc	a3,0x5
ffffffffc020306a:	a5268693          	addi	a3,a3,-1454 # ffffffffc0207ab8 <default_pmm_manager+0x5c0>
ffffffffc020306e:	00004617          	auipc	a2,0x4
ffffffffc0203072:	d4260613          	addi	a2,a2,-702 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203076:	23a00593          	li	a1,570
ffffffffc020307a:	00004517          	auipc	a0,0x4
ffffffffc020307e:	61e50513          	addi	a0,a0,1566 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203082:	c02fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203086:	00004697          	auipc	a3,0x4
ffffffffc020308a:	6ca68693          	addi	a3,a3,1738 # ffffffffc0207750 <default_pmm_manager+0x258>
ffffffffc020308e:	00004617          	auipc	a2,0x4
ffffffffc0203092:	d2260613          	addi	a2,a2,-734 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203096:	1f800593          	li	a1,504
ffffffffc020309a:	00004517          	auipc	a0,0x4
ffffffffc020309e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02030a2:	be2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02030a6:	00004617          	auipc	a2,0x4
ffffffffc02030aa:	4da60613          	addi	a2,a2,1242 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc02030ae:	0c100593          	li	a1,193
ffffffffc02030b2:	00004517          	auipc	a0,0x4
ffffffffc02030b6:	5e650513          	addi	a0,a0,1510 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02030ba:	bcafd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02030be <copy_range>:
               bool share) {
ffffffffc02030be:	7119                	addi	sp,sp,-128
ffffffffc02030c0:	f0ca                	sd	s2,96(sp)
ffffffffc02030c2:	8936                	mv	s2,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030c4:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc02030c6:	fc86                	sd	ra,120(sp)
ffffffffc02030c8:	f8a2                	sd	s0,112(sp)
ffffffffc02030ca:	f4a6                	sd	s1,104(sp)
ffffffffc02030cc:	ecce                	sd	s3,88(sp)
ffffffffc02030ce:	e8d2                	sd	s4,80(sp)
ffffffffc02030d0:	e4d6                	sd	s5,72(sp)
ffffffffc02030d2:	e0da                	sd	s6,64(sp)
ffffffffc02030d4:	fc5e                	sd	s7,56(sp)
ffffffffc02030d6:	f862                	sd	s8,48(sp)
ffffffffc02030d8:	f466                	sd	s9,40(sp)
ffffffffc02030da:	f06a                	sd	s10,32(sp)
ffffffffc02030dc:	ec6e                	sd	s11,24(sp)
ffffffffc02030de:	e03a                	sd	a4,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030e0:	03469793          	slli	a5,a3,0x34
ffffffffc02030e4:	26079663          	bnez	a5,ffffffffc0203350 <copy_range+0x292>
    assert(USER_ACCESS(start, end));
ffffffffc02030e8:	00200737          	lui	a4,0x200
ffffffffc02030ec:	8db2                	mv	s11,a2
ffffffffc02030ee:	1ce66963          	bltu	a2,a4,ffffffffc02032c0 <copy_range+0x202>
ffffffffc02030f2:	1d267763          	bleu	s2,a2,ffffffffc02032c0 <copy_range+0x202>
ffffffffc02030f6:	4705                	li	a4,1
ffffffffc02030f8:	077e                	slli	a4,a4,0x1f
ffffffffc02030fa:	1d276363          	bltu	a4,s2,ffffffffc02032c0 <copy_range+0x202>
ffffffffc02030fe:	5afd                	li	s5,-1
ffffffffc0203100:	8b2a                	mv	s6,a0
ffffffffc0203102:	84ae                	mv	s1,a1
        start += PGSIZE;
ffffffffc0203104:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203106:	000a9c97          	auipc	s9,0xa9
ffffffffc020310a:	34ac8c93          	addi	s9,s9,842 # ffffffffc02ac450 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020310e:	000a9c17          	auipc	s8,0xa9
ffffffffc0203112:	3b2c0c13          	addi	s8,s8,946 # ffffffffc02ac4c0 <pages>
    return page - pages + nbase;
ffffffffc0203116:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc020311a:	00cada93          	srli	s5,s5,0xc
ffffffffc020311e:	000a9d17          	auipc	s10,0xa9
ffffffffc0203122:	392d0d13          	addi	s10,s10,914 # ffffffffc02ac4b0 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203126:	4601                	li	a2,0
ffffffffc0203128:	85ee                	mv	a1,s11
ffffffffc020312a:	8526                	mv	a0,s1
ffffffffc020312c:	e35fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203130:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc0203132:	c569                	beqz	a0,ffffffffc02031fc <copy_range+0x13e>
        if (*ptep & PTE_V) {
ffffffffc0203134:	6118                	ld	a4,0(a0)
ffffffffc0203136:	8b05                	andi	a4,a4,1
ffffffffc0203138:	e705                	bnez	a4,ffffffffc0203160 <copy_range+0xa2>
        start += PGSIZE;
ffffffffc020313a:	9dd2                	add	s11,s11,s4
    } while (start != 0 && start < end);
ffffffffc020313c:	ff2de5e3          	bltu	s11,s2,ffffffffc0203126 <copy_range+0x68>
    return 0;
ffffffffc0203140:	4501                	li	a0,0
}
ffffffffc0203142:	70e6                	ld	ra,120(sp)
ffffffffc0203144:	7446                	ld	s0,112(sp)
ffffffffc0203146:	74a6                	ld	s1,104(sp)
ffffffffc0203148:	7906                	ld	s2,96(sp)
ffffffffc020314a:	69e6                	ld	s3,88(sp)
ffffffffc020314c:	6a46                	ld	s4,80(sp)
ffffffffc020314e:	6aa6                	ld	s5,72(sp)
ffffffffc0203150:	6b06                	ld	s6,64(sp)
ffffffffc0203152:	7be2                	ld	s7,56(sp)
ffffffffc0203154:	7c42                	ld	s8,48(sp)
ffffffffc0203156:	7ca2                	ld	s9,40(sp)
ffffffffc0203158:	7d02                	ld	s10,32(sp)
ffffffffc020315a:	6de2                	ld	s11,24(sp)
ffffffffc020315c:	6109                	addi	sp,sp,128
ffffffffc020315e:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203160:	4605                	li	a2,1
ffffffffc0203162:	85ee                	mv	a1,s11
ffffffffc0203164:	855a                	mv	a0,s6
ffffffffc0203166:	dfbfe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc020316a:	12050c63          	beqz	a0,ffffffffc02032a2 <copy_range+0x1e4>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020316e:	6018                	ld	a4,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc0203170:	00177693          	andi	a3,a4,1
ffffffffc0203174:	0007099b          	sext.w	s3,a4
ffffffffc0203178:	1a068063          	beqz	a3,ffffffffc0203318 <copy_range+0x25a>
    if (PPN(pa) >= npage) {
ffffffffc020317c:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203180:	070a                	slli	a4,a4,0x2
ffffffffc0203182:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203184:	14d77e63          	bleu	a3,a4,ffffffffc02032e0 <copy_range+0x222>
    return &pages[PPN(pa) - nbase];
ffffffffc0203188:	000c3403          	ld	s0,0(s8)
ffffffffc020318c:	fff807b7          	lui	a5,0xfff80
ffffffffc0203190:	973e                	add	a4,a4,a5
ffffffffc0203192:	071a                	slli	a4,a4,0x6
ffffffffc0203194:	943a                	add	s0,s0,a4
            assert(page != NULL);
ffffffffc0203196:	18040d63          	beqz	s0,ffffffffc0203330 <copy_range+0x272>
            if(share){//如果COW机制启用
ffffffffc020319a:	6782                	ld	a5,0(sp)
ffffffffc020319c:	cfad                	beqz	a5,ffffffffc0203216 <copy_range+0x158>
    return page - pages + nbase;
ffffffffc020319e:	8719                	srai	a4,a4,0x6
ffffffffc02031a0:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc02031a2:	01577633          	and	a2,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02031a6:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02031a8:	0ed67f63          	bleu	a3,a2,ffffffffc02032a6 <copy_range+0x1e8>
ffffffffc02031ac:	000d3583          	ld	a1,0(s10)
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc02031b0:	00004517          	auipc	a0,0x4
ffffffffc02031b4:	49850513          	addi	a0,a0,1176 # ffffffffc0207648 <default_pmm_manager+0x150>
                page_insert(from, page, start, perm & ~PTE_W);
ffffffffc02031b8:	01b9f993          	andi	s3,s3,27
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc02031bc:	95ba                	add	a1,a1,a4
ffffffffc02031be:	fd1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                page_insert(from, page, start, perm & ~PTE_W);
ffffffffc02031c2:	86ce                	mv	a3,s3
ffffffffc02031c4:	866e                	mv	a2,s11
ffffffffc02031c6:	85a2                	mv	a1,s0
ffffffffc02031c8:	8526                	mv	a0,s1
ffffffffc02031ca:	bacff0ef          	jal	ra,ffffffffc0202576 <page_insert>
                ret = page_insert(to, page, start, perm & ~PTE_W);
ffffffffc02031ce:	86ce                	mv	a3,s3
ffffffffc02031d0:	866e                	mv	a2,s11
ffffffffc02031d2:	85a2                	mv	a1,s0
ffffffffc02031d4:	855a                	mv	a0,s6
ffffffffc02031d6:	ba0ff0ef          	jal	ra,ffffffffc0202576 <page_insert>
            assert(ret == 0);
ffffffffc02031da:	d125                	beqz	a0,ffffffffc020313a <copy_range+0x7c>
ffffffffc02031dc:	00004697          	auipc	a3,0x4
ffffffffc02031e0:	4ac68693          	addi	a3,a3,1196 # ffffffffc0207688 <default_pmm_manager+0x190>
ffffffffc02031e4:	00004617          	auipc	a2,0x4
ffffffffc02031e8:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02031ec:	19a00593          	li	a1,410
ffffffffc02031f0:	00004517          	auipc	a0,0x4
ffffffffc02031f4:	4a850513          	addi	a0,a0,1192 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02031f8:	a8cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02031fc:	00200737          	lui	a4,0x200
ffffffffc0203200:	00ed87b3          	add	a5,s11,a4
ffffffffc0203204:	ffe00737          	lui	a4,0xffe00
ffffffffc0203208:	00e7fdb3          	and	s11,a5,a4
    } while (start != 0 && start < end);
ffffffffc020320c:	f20d8ae3          	beqz	s11,ffffffffc0203140 <copy_range+0x82>
ffffffffc0203210:	f12debe3          	bltu	s11,s2,ffffffffc0203126 <copy_range+0x68>
ffffffffc0203214:	b735                	j	ffffffffc0203140 <copy_range+0x82>
                struct Page *npage = alloc_page();
ffffffffc0203216:	4505                	li	a0,1
ffffffffc0203218:	c3bfe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
                assert(npage!=NULL);
ffffffffc020321c:	cd71                	beqz	a0,ffffffffc02032f8 <copy_range+0x23a>
    return page - pages + nbase;
ffffffffc020321e:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0203222:	000cb703          	ld	a4,0(s9)
    return page - pages + nbase;
ffffffffc0203226:	40d506b3          	sub	a3,a0,a3
ffffffffc020322a:	8699                	srai	a3,a3,0x6
ffffffffc020322c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020322e:	0156f633          	and	a2,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203232:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203234:	06e67a63          	bleu	a4,a2,ffffffffc02032a8 <copy_range+0x1ea>
ffffffffc0203238:	000d3583          	ld	a1,0(s10)
ffffffffc020323c:	e42a                	sd	a0,8(sp)
                cprintf("alloc a new page 0x%x\n", page2kva(npage));
ffffffffc020323e:	00004517          	auipc	a0,0x4
ffffffffc0203242:	43250513          	addi	a0,a0,1074 # ffffffffc0207670 <default_pmm_manager+0x178>
ffffffffc0203246:	95b6                	add	a1,a1,a3
ffffffffc0203248:	f47fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    return page - pages + nbase;
ffffffffc020324c:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc0203250:	000cb603          	ld	a2,0(s9)
ffffffffc0203254:	6822                	ld	a6,8(sp)
    return page - pages + nbase;
ffffffffc0203256:	40e406b3          	sub	a3,s0,a4
ffffffffc020325a:	8699                	srai	a3,a3,0x6
ffffffffc020325c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020325e:	0156f5b3          	and	a1,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203262:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203264:	04c5f263          	bleu	a2,a1,ffffffffc02032a8 <copy_range+0x1ea>
    return page - pages + nbase;
ffffffffc0203268:	40e80733          	sub	a4,a6,a4
    return KADDR(page2pa(page));
ffffffffc020326c:	000d3503          	ld	a0,0(s10)
    return page - pages + nbase;
ffffffffc0203270:	8719                	srai	a4,a4,0x6
ffffffffc0203272:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc0203274:	015778b3          	and	a7,a4,s5
ffffffffc0203278:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020327c:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc020327e:	02c8f463          	bleu	a2,a7,ffffffffc02032a6 <copy_range+0x1e8>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);//复制
ffffffffc0203282:	6605                	lui	a2,0x1
ffffffffc0203284:	953a                	add	a0,a0,a4
ffffffffc0203286:	e442                	sd	a6,8(sp)
ffffffffc0203288:	51a030ef          	jal	ra,ffffffffc02067a2 <memcpy>
                ret = page_insert(to, npage, start, perm);//在子进程将该虚拟地址映射到对应的物理页
ffffffffc020328c:	6822                	ld	a6,8(sp)
ffffffffc020328e:	01f9f693          	andi	a3,s3,31
ffffffffc0203292:	866e                	mv	a2,s11
ffffffffc0203294:	85c2                	mv	a1,a6
ffffffffc0203296:	855a                	mv	a0,s6
ffffffffc0203298:	adeff0ef          	jal	ra,ffffffffc0202576 <page_insert>
            assert(ret == 0);
ffffffffc020329c:	e8050fe3          	beqz	a0,ffffffffc020313a <copy_range+0x7c>
ffffffffc02032a0:	bf35                	j	ffffffffc02031dc <copy_range+0x11e>
                return -E_NO_MEM;
ffffffffc02032a2:	5571                	li	a0,-4
ffffffffc02032a4:	bd79                	j	ffffffffc0203142 <copy_range+0x84>
ffffffffc02032a6:	86ba                	mv	a3,a4
ffffffffc02032a8:	00004617          	auipc	a2,0x4
ffffffffc02032ac:	2a060613          	addi	a2,a2,672 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc02032b0:	06900593          	li	a1,105
ffffffffc02032b4:	00004517          	auipc	a0,0x4
ffffffffc02032b8:	2bc50513          	addi	a0,a0,700 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc02032bc:	9c8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02032c0:	00005697          	auipc	a3,0x5
ffffffffc02032c4:	98068693          	addi	a3,a3,-1664 # ffffffffc0207c40 <default_pmm_manager+0x748>
ffffffffc02032c8:	00004617          	auipc	a2,0x4
ffffffffc02032cc:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02032d0:	15e00593          	li	a1,350
ffffffffc02032d4:	00004517          	auipc	a0,0x4
ffffffffc02032d8:	3c450513          	addi	a0,a0,964 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc02032dc:	9a8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032e0:	00004617          	auipc	a2,0x4
ffffffffc02032e4:	2c860613          	addi	a2,a2,712 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc02032e8:	06200593          	li	a1,98
ffffffffc02032ec:	00004517          	auipc	a0,0x4
ffffffffc02032f0:	28450513          	addi	a0,a0,644 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc02032f4:	990fd0ef          	jal	ra,ffffffffc0200484 <__panic>
                assert(npage!=NULL);
ffffffffc02032f8:	00004697          	auipc	a3,0x4
ffffffffc02032fc:	36868693          	addi	a3,a3,872 # ffffffffc0207660 <default_pmm_manager+0x168>
ffffffffc0203300:	00004617          	auipc	a2,0x4
ffffffffc0203304:	ab060613          	addi	a2,a2,-1360 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203308:	19100593          	li	a1,401
ffffffffc020330c:	00004517          	auipc	a0,0x4
ffffffffc0203310:	38c50513          	addi	a0,a0,908 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203314:	970fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203318:	00004617          	auipc	a2,0x4
ffffffffc020331c:	51860613          	addi	a2,a2,1304 # ffffffffc0207830 <default_pmm_manager+0x338>
ffffffffc0203320:	07400593          	li	a1,116
ffffffffc0203324:	00004517          	auipc	a0,0x4
ffffffffc0203328:	24c50513          	addi	a0,a0,588 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc020332c:	958fd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(page != NULL);
ffffffffc0203330:	00004697          	auipc	a3,0x4
ffffffffc0203334:	30868693          	addi	a3,a3,776 # ffffffffc0207638 <default_pmm_manager+0x140>
ffffffffc0203338:	00004617          	auipc	a2,0x4
ffffffffc020333c:	a7860613          	addi	a2,a2,-1416 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203340:	17200593          	li	a1,370
ffffffffc0203344:	00004517          	auipc	a0,0x4
ffffffffc0203348:	35450513          	addi	a0,a0,852 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc020334c:	938fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203350:	00005697          	auipc	a3,0x5
ffffffffc0203354:	8c068693          	addi	a3,a3,-1856 # ffffffffc0207c10 <default_pmm_manager+0x718>
ffffffffc0203358:	00004617          	auipc	a2,0x4
ffffffffc020335c:	a5860613          	addi	a2,a2,-1448 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203360:	15d00593          	li	a1,349
ffffffffc0203364:	00004517          	auipc	a0,0x4
ffffffffc0203368:	33450513          	addi	a0,a0,820 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc020336c:	918fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203370 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203370:	12058073          	sfence.vma	a1
}
ffffffffc0203374:	8082                	ret

ffffffffc0203376 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203376:	7179                	addi	sp,sp,-48
ffffffffc0203378:	e84a                	sd	s2,16(sp)
ffffffffc020337a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020337c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020337e:	f022                	sd	s0,32(sp)
ffffffffc0203380:	ec26                	sd	s1,24(sp)
ffffffffc0203382:	e44e                	sd	s3,8(sp)
ffffffffc0203384:	f406                	sd	ra,40(sp)
ffffffffc0203386:	84ae                	mv	s1,a1
ffffffffc0203388:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020338a:	ac9fe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020338e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203390:	cd1d                	beqz	a0,ffffffffc02033ce <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203392:	85aa                	mv	a1,a0
ffffffffc0203394:	86ce                	mv	a3,s3
ffffffffc0203396:	8626                	mv	a2,s1
ffffffffc0203398:	854a                	mv	a0,s2
ffffffffc020339a:	9dcff0ef          	jal	ra,ffffffffc0202576 <page_insert>
ffffffffc020339e:	e121                	bnez	a0,ffffffffc02033de <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc02033a0:	000a9797          	auipc	a5,0xa9
ffffffffc02033a4:	0c078793          	addi	a5,a5,192 # ffffffffc02ac460 <swap_init_ok>
ffffffffc02033a8:	439c                	lw	a5,0(a5)
ffffffffc02033aa:	2781                	sext.w	a5,a5
ffffffffc02033ac:	c38d                	beqz	a5,ffffffffc02033ce <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02033ae:	000a9797          	auipc	a5,0xa9
ffffffffc02033b2:	1f278793          	addi	a5,a5,498 # ffffffffc02ac5a0 <check_mm_struct>
ffffffffc02033b6:	6388                	ld	a0,0(a5)
ffffffffc02033b8:	c919                	beqz	a0,ffffffffc02033ce <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02033ba:	4681                	li	a3,0
ffffffffc02033bc:	8622                	mv	a2,s0
ffffffffc02033be:	85a6                	mv	a1,s1
ffffffffc02033c0:	7da000ef          	jal	ra,ffffffffc0203b9a <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02033c4:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02033c6:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02033c8:	4785                	li	a5,1
ffffffffc02033ca:	02f71063          	bne	a4,a5,ffffffffc02033ea <pgdir_alloc_page+0x74>
}
ffffffffc02033ce:	8522                	mv	a0,s0
ffffffffc02033d0:	70a2                	ld	ra,40(sp)
ffffffffc02033d2:	7402                	ld	s0,32(sp)
ffffffffc02033d4:	64e2                	ld	s1,24(sp)
ffffffffc02033d6:	6942                	ld	s2,16(sp)
ffffffffc02033d8:	69a2                	ld	s3,8(sp)
ffffffffc02033da:	6145                	addi	sp,sp,48
ffffffffc02033dc:	8082                	ret
            free_page(page);
ffffffffc02033de:	8522                	mv	a0,s0
ffffffffc02033e0:	4585                	li	a1,1
ffffffffc02033e2:	af9fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
            return NULL;
ffffffffc02033e6:	4401                	li	s0,0
ffffffffc02033e8:	b7dd                	j	ffffffffc02033ce <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc02033ea:	00004697          	auipc	a3,0x4
ffffffffc02033ee:	2be68693          	addi	a3,a3,702 # ffffffffc02076a8 <default_pmm_manager+0x1b0>
ffffffffc02033f2:	00004617          	auipc	a2,0x4
ffffffffc02033f6:	9be60613          	addi	a2,a2,-1602 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02033fa:	1d900593          	li	a1,473
ffffffffc02033fe:	00004517          	auipc	a0,0x4
ffffffffc0203402:	29a50513          	addi	a0,a0,666 # ffffffffc0207698 <default_pmm_manager+0x1a0>
ffffffffc0203406:	87efd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020340a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020340a:	7135                	addi	sp,sp,-160
ffffffffc020340c:	ed06                	sd	ra,152(sp)
ffffffffc020340e:	e922                	sd	s0,144(sp)
ffffffffc0203410:	e526                	sd	s1,136(sp)
ffffffffc0203412:	e14a                	sd	s2,128(sp)
ffffffffc0203414:	fcce                	sd	s3,120(sp)
ffffffffc0203416:	f8d2                	sd	s4,112(sp)
ffffffffc0203418:	f4d6                	sd	s5,104(sp)
ffffffffc020341a:	f0da                	sd	s6,96(sp)
ffffffffc020341c:	ecde                	sd	s7,88(sp)
ffffffffc020341e:	e8e2                	sd	s8,80(sp)
ffffffffc0203420:	e4e6                	sd	s9,72(sp)
ffffffffc0203422:	e0ea                	sd	s10,64(sp)
ffffffffc0203424:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203426:	09f010ef          	jal	ra,ffffffffc0204cc4 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020342a:	000a9797          	auipc	a5,0xa9
ffffffffc020342e:	12678793          	addi	a5,a5,294 # ffffffffc02ac550 <max_swap_offset>
ffffffffc0203432:	6394                	ld	a3,0(a5)
ffffffffc0203434:	010007b7          	lui	a5,0x1000
ffffffffc0203438:	17e1                	addi	a5,a5,-8
ffffffffc020343a:	ff968713          	addi	a4,a3,-7
ffffffffc020343e:	4ae7ee63          	bltu	a5,a4,ffffffffc02038fa <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203442:	0009e797          	auipc	a5,0x9e
ffffffffc0203446:	b9e78793          	addi	a5,a5,-1122 # ffffffffc02a0fe0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020344a:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020344c:	000a9697          	auipc	a3,0xa9
ffffffffc0203450:	00f6b623          	sd	a5,12(a3) # ffffffffc02ac458 <sm>
     int r = sm->init();
ffffffffc0203454:	9702                	jalr	a4
ffffffffc0203456:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0203458:	c10d                	beqz	a0,ffffffffc020347a <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020345a:	60ea                	ld	ra,152(sp)
ffffffffc020345c:	644a                	ld	s0,144(sp)
ffffffffc020345e:	8556                	mv	a0,s5
ffffffffc0203460:	64aa                	ld	s1,136(sp)
ffffffffc0203462:	690a                	ld	s2,128(sp)
ffffffffc0203464:	79e6                	ld	s3,120(sp)
ffffffffc0203466:	7a46                	ld	s4,112(sp)
ffffffffc0203468:	7aa6                	ld	s5,104(sp)
ffffffffc020346a:	7b06                	ld	s6,96(sp)
ffffffffc020346c:	6be6                	ld	s7,88(sp)
ffffffffc020346e:	6c46                	ld	s8,80(sp)
ffffffffc0203470:	6ca6                	ld	s9,72(sp)
ffffffffc0203472:	6d06                	ld	s10,64(sp)
ffffffffc0203474:	7de2                	ld	s11,56(sp)
ffffffffc0203476:	610d                	addi	sp,sp,160
ffffffffc0203478:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020347a:	000a9797          	auipc	a5,0xa9
ffffffffc020347e:	fde78793          	addi	a5,a5,-34 # ffffffffc02ac458 <sm>
ffffffffc0203482:	639c                	ld	a5,0(a5)
ffffffffc0203484:	00005517          	auipc	a0,0x5
ffffffffc0203488:	85450513          	addi	a0,a0,-1964 # ffffffffc0207cd8 <default_pmm_manager+0x7e0>
    return listelm->next;
ffffffffc020348c:	000a9417          	auipc	s0,0xa9
ffffffffc0203490:	00440413          	addi	s0,s0,4 # ffffffffc02ac490 <free_area>
ffffffffc0203494:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203496:	4785                	li	a5,1
ffffffffc0203498:	000a9717          	auipc	a4,0xa9
ffffffffc020349c:	fcf72423          	sw	a5,-56(a4) # ffffffffc02ac460 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034a0:	ceffc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02034a4:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034a6:	36878e63          	beq	a5,s0,ffffffffc0203822 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034aa:	ff07b703          	ld	a4,-16(a5)
ffffffffc02034ae:	8305                	srli	a4,a4,0x1
ffffffffc02034b0:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02034b2:	36070c63          	beqz	a4,ffffffffc020382a <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc02034b6:	4481                	li	s1,0
ffffffffc02034b8:	4901                	li	s2,0
ffffffffc02034ba:	a031                	j	ffffffffc02034c6 <swap_init+0xbc>
ffffffffc02034bc:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02034c0:	8b09                	andi	a4,a4,2
ffffffffc02034c2:	36070463          	beqz	a4,ffffffffc020382a <swap_init+0x420>
        count ++, total += p->property;
ffffffffc02034c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02034ca:	679c                	ld	a5,8(a5)
ffffffffc02034cc:	2905                	addiw	s2,s2,1
ffffffffc02034ce:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034d0:	fe8796e3          	bne	a5,s0,ffffffffc02034bc <swap_init+0xb2>
ffffffffc02034d4:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02034d6:	a4bfe0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc02034da:	69351863          	bne	a0,s3,ffffffffc0203b6a <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02034de:	8626                	mv	a2,s1
ffffffffc02034e0:	85ca                	mv	a1,s2
ffffffffc02034e2:	00005517          	auipc	a0,0x5
ffffffffc02034e6:	80e50513          	addi	a0,a0,-2034 # ffffffffc0207cf0 <default_pmm_manager+0x7f8>
ffffffffc02034ea:	ca5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02034ee:	457000ef          	jal	ra,ffffffffc0204144 <mm_create>
ffffffffc02034f2:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02034f4:	60050b63          	beqz	a0,ffffffffc0203b0a <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02034f8:	000a9797          	auipc	a5,0xa9
ffffffffc02034fc:	0a878793          	addi	a5,a5,168 # ffffffffc02ac5a0 <check_mm_struct>
ffffffffc0203500:	639c                	ld	a5,0(a5)
ffffffffc0203502:	62079463          	bnez	a5,ffffffffc0203b2a <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203506:	000a9797          	auipc	a5,0xa9
ffffffffc020350a:	f4278793          	addi	a5,a5,-190 # ffffffffc02ac448 <boot_pgdir>
ffffffffc020350e:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203512:	000a9797          	auipc	a5,0xa9
ffffffffc0203516:	08a7b723          	sd	a0,142(a5) # ffffffffc02ac5a0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020351a:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020351e:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203522:	4e079863          	bnez	a5,ffffffffc0203a12 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203526:	6599                	lui	a1,0x6
ffffffffc0203528:	460d                	li	a2,3
ffffffffc020352a:	6505                	lui	a0,0x1
ffffffffc020352c:	465000ef          	jal	ra,ffffffffc0204190 <vma_create>
ffffffffc0203530:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203532:	50050063          	beqz	a0,ffffffffc0203a32 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0203536:	855e                	mv	a0,s7
ffffffffc0203538:	4c5000ef          	jal	ra,ffffffffc02041fc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020353c:	00005517          	auipc	a0,0x5
ffffffffc0203540:	82450513          	addi	a0,a0,-2012 # ffffffffc0207d60 <default_pmm_manager+0x868>
ffffffffc0203544:	c4bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203548:	018bb503          	ld	a0,24(s7) # 80018 <_binary_obj___user_exit_out_size+0x75598>
ffffffffc020354c:	4605                	li	a2,1
ffffffffc020354e:	6585                	lui	a1,0x1
ffffffffc0203550:	a11fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203554:	4e050f63          	beqz	a0,ffffffffc0203a52 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203558:	00005517          	auipc	a0,0x5
ffffffffc020355c:	85850513          	addi	a0,a0,-1960 # ffffffffc0207db0 <default_pmm_manager+0x8b8>
ffffffffc0203560:	000a9997          	auipc	s3,0xa9
ffffffffc0203564:	f6898993          	addi	s3,s3,-152 # ffffffffc02ac4c8 <check_rp>
ffffffffc0203568:	c27fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020356c:	000a9a17          	auipc	s4,0xa9
ffffffffc0203570:	f7ca0a13          	addi	s4,s4,-132 # ffffffffc02ac4e8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203574:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203576:	4505                	li	a0,1
ffffffffc0203578:	8dbfe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020357c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0203580:	32050d63          	beqz	a0,ffffffffc02038ba <swap_init+0x4b0>
ffffffffc0203584:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203586:	8b89                	andi	a5,a5,2
ffffffffc0203588:	30079963          	bnez	a5,ffffffffc020389a <swap_init+0x490>
ffffffffc020358c:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020358e:	ff4c14e3          	bne	s8,s4,ffffffffc0203576 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203592:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203594:	000a9c17          	auipc	s8,0xa9
ffffffffc0203598:	f34c0c13          	addi	s8,s8,-204 # ffffffffc02ac4c8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020359c:	ec3e                	sd	a5,24(sp)
ffffffffc020359e:	641c                	ld	a5,8(s0)
ffffffffc02035a0:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02035a2:	481c                	lw	a5,16(s0)
ffffffffc02035a4:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02035a6:	000a9797          	auipc	a5,0xa9
ffffffffc02035aa:	ee87b923          	sd	s0,-270(a5) # ffffffffc02ac498 <free_area+0x8>
ffffffffc02035ae:	000a9797          	auipc	a5,0xa9
ffffffffc02035b2:	ee87b123          	sd	s0,-286(a5) # ffffffffc02ac490 <free_area>
     nr_free = 0;
ffffffffc02035b6:	000a9797          	auipc	a5,0xa9
ffffffffc02035ba:	ee07a523          	sw	zero,-278(a5) # ffffffffc02ac4a0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02035be:	000c3503          	ld	a0,0(s8)
ffffffffc02035c2:	4585                	li	a1,1
ffffffffc02035c4:	0c21                	addi	s8,s8,8
ffffffffc02035c6:	915fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035ca:	ff4c1ae3          	bne	s8,s4,ffffffffc02035be <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02035ce:	01042c03          	lw	s8,16(s0)
ffffffffc02035d2:	4791                	li	a5,4
ffffffffc02035d4:	50fc1b63          	bne	s8,a5,ffffffffc0203aea <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02035d8:	00005517          	auipc	a0,0x5
ffffffffc02035dc:	86050513          	addi	a0,a0,-1952 # ffffffffc0207e38 <default_pmm_manager+0x940>
ffffffffc02035e0:	baffc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035e4:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02035e6:	000a9797          	auipc	a5,0xa9
ffffffffc02035ea:	e607af23          	sw	zero,-386(a5) # ffffffffc02ac464 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035ee:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02035f0:	000a9797          	auipc	a5,0xa9
ffffffffc02035f4:	e7478793          	addi	a5,a5,-396 # ffffffffc02ac464 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035f8:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
     assert(pgfault_num==1);
ffffffffc02035fc:	4398                	lw	a4,0(a5)
ffffffffc02035fe:	4585                	li	a1,1
ffffffffc0203600:	2701                	sext.w	a4,a4
ffffffffc0203602:	38b71863          	bne	a4,a1,ffffffffc0203992 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203606:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020360a:	4394                	lw	a3,0(a5)
ffffffffc020360c:	2681                	sext.w	a3,a3
ffffffffc020360e:	3ae69263          	bne	a3,a4,ffffffffc02039b2 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203612:	6689                	lui	a3,0x2
ffffffffc0203614:	462d                	li	a2,11
ffffffffc0203616:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
     assert(pgfault_num==2);
ffffffffc020361a:	4398                	lw	a4,0(a5)
ffffffffc020361c:	4589                	li	a1,2
ffffffffc020361e:	2701                	sext.w	a4,a4
ffffffffc0203620:	2eb71963          	bne	a4,a1,ffffffffc0203912 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203624:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203628:	4394                	lw	a3,0(a5)
ffffffffc020362a:	2681                	sext.w	a3,a3
ffffffffc020362c:	30e69363          	bne	a3,a4,ffffffffc0203932 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203630:	668d                	lui	a3,0x3
ffffffffc0203632:	4631                	li	a2,12
ffffffffc0203634:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
     assert(pgfault_num==3);
ffffffffc0203638:	4398                	lw	a4,0(a5)
ffffffffc020363a:	458d                	li	a1,3
ffffffffc020363c:	2701                	sext.w	a4,a4
ffffffffc020363e:	30b71a63          	bne	a4,a1,ffffffffc0203952 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203642:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203646:	4394                	lw	a3,0(a5)
ffffffffc0203648:	2681                	sext.w	a3,a3
ffffffffc020364a:	32e69463          	bne	a3,a4,ffffffffc0203972 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020364e:	6691                	lui	a3,0x4
ffffffffc0203650:	4635                	li	a2,13
ffffffffc0203652:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
     assert(pgfault_num==4);
ffffffffc0203656:	4398                	lw	a4,0(a5)
ffffffffc0203658:	2701                	sext.w	a4,a4
ffffffffc020365a:	37871c63          	bne	a4,s8,ffffffffc02039d2 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020365e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203662:	439c                	lw	a5,0(a5)
ffffffffc0203664:	2781                	sext.w	a5,a5
ffffffffc0203666:	38e79663          	bne	a5,a4,ffffffffc02039f2 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020366a:	481c                	lw	a5,16(s0)
ffffffffc020366c:	40079363          	bnez	a5,ffffffffc0203a72 <swap_init+0x668>
ffffffffc0203670:	000a9797          	auipc	a5,0xa9
ffffffffc0203674:	e7878793          	addi	a5,a5,-392 # ffffffffc02ac4e8 <swap_in_seq_no>
ffffffffc0203678:	000a9717          	auipc	a4,0xa9
ffffffffc020367c:	e9870713          	addi	a4,a4,-360 # ffffffffc02ac510 <swap_out_seq_no>
ffffffffc0203680:	000a9617          	auipc	a2,0xa9
ffffffffc0203684:	e9060613          	addi	a2,a2,-368 # ffffffffc02ac510 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203688:	56fd                	li	a3,-1
ffffffffc020368a:	c394                	sw	a3,0(a5)
ffffffffc020368c:	c314                	sw	a3,0(a4)
ffffffffc020368e:	0791                	addi	a5,a5,4
ffffffffc0203690:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203692:	fef61ce3          	bne	a2,a5,ffffffffc020368a <swap_init+0x280>
ffffffffc0203696:	000a9697          	auipc	a3,0xa9
ffffffffc020369a:	eda68693          	addi	a3,a3,-294 # ffffffffc02ac570 <check_ptep>
ffffffffc020369e:	000a9817          	auipc	a6,0xa9
ffffffffc02036a2:	e2a80813          	addi	a6,a6,-470 # ffffffffc02ac4c8 <check_rp>
ffffffffc02036a6:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02036a8:	000a9c97          	auipc	s9,0xa9
ffffffffc02036ac:	da8c8c93          	addi	s9,s9,-600 # ffffffffc02ac450 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02036b0:	00006d97          	auipc	s11,0x6
ffffffffc02036b4:	838d8d93          	addi	s11,s11,-1992 # ffffffffc0208ee8 <nbase>
ffffffffc02036b8:	000a9c17          	auipc	s8,0xa9
ffffffffc02036bc:	e08c0c13          	addi	s8,s8,-504 # ffffffffc02ac4c0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02036c0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036c4:	4601                	li	a2,0
ffffffffc02036c6:	85ea                	mv	a1,s10
ffffffffc02036c8:	855a                	mv	a0,s6
ffffffffc02036ca:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02036cc:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036ce:	893fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02036d2:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02036d4:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036d6:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02036d8:	20050163          	beqz	a0,ffffffffc02038da <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02036dc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036de:	0017f613          	andi	a2,a5,1
ffffffffc02036e2:	1a060063          	beqz	a2,ffffffffc0203882 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc02036e6:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036ea:	078a                	slli	a5,a5,0x2
ffffffffc02036ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ee:	14c7fe63          	bleu	a2,a5,ffffffffc020384a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f2:	000db703          	ld	a4,0(s11)
ffffffffc02036f6:	000c3603          	ld	a2,0(s8)
ffffffffc02036fa:	00083583          	ld	a1,0(a6)
ffffffffc02036fe:	8f99                	sub	a5,a5,a4
ffffffffc0203700:	079a                	slli	a5,a5,0x6
ffffffffc0203702:	e43a                	sd	a4,8(sp)
ffffffffc0203704:	97b2                	add	a5,a5,a2
ffffffffc0203706:	14f59e63          	bne	a1,a5,ffffffffc0203862 <swap_init+0x458>
ffffffffc020370a:	6785                	lui	a5,0x1
ffffffffc020370c:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020370e:	6795                	lui	a5,0x5
ffffffffc0203710:	06a1                	addi	a3,a3,8
ffffffffc0203712:	0821                	addi	a6,a6,8
ffffffffc0203714:	fafd16e3          	bne	s10,a5,ffffffffc02036c0 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203718:	00004517          	auipc	a0,0x4
ffffffffc020371c:	7c850513          	addi	a0,a0,1992 # ffffffffc0207ee0 <default_pmm_manager+0x9e8>
ffffffffc0203720:	a6ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0203724:	000a9797          	auipc	a5,0xa9
ffffffffc0203728:	d3478793          	addi	a5,a5,-716 # ffffffffc02ac458 <sm>
ffffffffc020372c:	639c                	ld	a5,0(a5)
ffffffffc020372e:	7f9c                	ld	a5,56(a5)
ffffffffc0203730:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203732:	40051c63          	bnez	a0,ffffffffc0203b4a <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203736:	77a2                	ld	a5,40(sp)
ffffffffc0203738:	000a9717          	auipc	a4,0xa9
ffffffffc020373c:	d6f72423          	sw	a5,-664(a4) # ffffffffc02ac4a0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0203740:	67e2                	ld	a5,24(sp)
ffffffffc0203742:	000a9717          	auipc	a4,0xa9
ffffffffc0203746:	d4f73723          	sd	a5,-690(a4) # ffffffffc02ac490 <free_area>
ffffffffc020374a:	7782                	ld	a5,32(sp)
ffffffffc020374c:	000a9717          	auipc	a4,0xa9
ffffffffc0203750:	d4f73623          	sd	a5,-692(a4) # ffffffffc02ac498 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203754:	0009b503          	ld	a0,0(s3)
ffffffffc0203758:	4585                	li	a1,1
ffffffffc020375a:	09a1                	addi	s3,s3,8
ffffffffc020375c:	f7efe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203760:	ff499ae3          	bne	s3,s4,ffffffffc0203754 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203764:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0203768:	855e                	mv	a0,s7
ffffffffc020376a:	361000ef          	jal	ra,ffffffffc02042ca <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020376e:	000a9797          	auipc	a5,0xa9
ffffffffc0203772:	cda78793          	addi	a5,a5,-806 # ffffffffc02ac448 <boot_pgdir>
ffffffffc0203776:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203778:	000a9697          	auipc	a3,0xa9
ffffffffc020377c:	e206b423          	sd	zero,-472(a3) # ffffffffc02ac5a0 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203780:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203784:	6394                	ld	a3,0(a5)
ffffffffc0203786:	068a                	slli	a3,a3,0x2
ffffffffc0203788:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020378a:	0ce6f063          	bleu	a4,a3,ffffffffc020384a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020378e:	67a2                	ld	a5,8(sp)
ffffffffc0203790:	000c3503          	ld	a0,0(s8)
ffffffffc0203794:	8e9d                	sub	a3,a3,a5
ffffffffc0203796:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203798:	8699                	srai	a3,a3,0x6
ffffffffc020379a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020379c:	57fd                	li	a5,-1
ffffffffc020379e:	83b1                	srli	a5,a5,0xc
ffffffffc02037a0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02037a2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02037a4:	2ee7f763          	bleu	a4,a5,ffffffffc0203a92 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02037a8:	000a9797          	auipc	a5,0xa9
ffffffffc02037ac:	d0878793          	addi	a5,a5,-760 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc02037b0:	639c                	ld	a5,0(a5)
ffffffffc02037b2:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02037b4:	629c                	ld	a5,0(a3)
ffffffffc02037b6:	078a                	slli	a5,a5,0x2
ffffffffc02037b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037ba:	08e7f863          	bleu	a4,a5,ffffffffc020384a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02037be:	69a2                	ld	s3,8(sp)
ffffffffc02037c0:	4585                	li	a1,1
ffffffffc02037c2:	413787b3          	sub	a5,a5,s3
ffffffffc02037c6:	079a                	slli	a5,a5,0x6
ffffffffc02037c8:	953e                	add	a0,a0,a5
ffffffffc02037ca:	f10fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037ce:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02037d2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02037d6:	078a                	slli	a5,a5,0x2
ffffffffc02037d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037da:	06e7f863          	bleu	a4,a5,ffffffffc020384a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02037de:	000c3503          	ld	a0,0(s8)
ffffffffc02037e2:	413787b3          	sub	a5,a5,s3
ffffffffc02037e6:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02037e8:	4585                	li	a1,1
ffffffffc02037ea:	953e                	add	a0,a0,a5
ffffffffc02037ec:	eeefe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     pgdir[0] = 0;
ffffffffc02037f0:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02037f4:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02037f8:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037fa:	00878963          	beq	a5,s0,ffffffffc020380c <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02037fe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203802:	679c                	ld	a5,8(a5)
ffffffffc0203804:	397d                	addiw	s2,s2,-1
ffffffffc0203806:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203808:	fe879be3          	bne	a5,s0,ffffffffc02037fe <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020380c:	28091f63          	bnez	s2,ffffffffc0203aaa <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203810:	2a049d63          	bnez	s1,ffffffffc0203aca <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203814:	00004517          	auipc	a0,0x4
ffffffffc0203818:	71c50513          	addi	a0,a0,1820 # ffffffffc0207f30 <default_pmm_manager+0xa38>
ffffffffc020381c:	973fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203820:	b92d                	j	ffffffffc020345a <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203822:	4481                	li	s1,0
ffffffffc0203824:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203826:	4981                	li	s3,0
ffffffffc0203828:	b17d                	j	ffffffffc02034d6 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020382a:	00004697          	auipc	a3,0x4
ffffffffc020382e:	93e68693          	addi	a3,a3,-1730 # ffffffffc0207168 <commands+0x878>
ffffffffc0203832:	00003617          	auipc	a2,0x3
ffffffffc0203836:	57e60613          	addi	a2,a2,1406 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020383a:	0bc00593          	li	a1,188
ffffffffc020383e:	00004517          	auipc	a0,0x4
ffffffffc0203842:	48a50513          	addi	a0,a0,1162 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203846:	c3ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020384a:	00004617          	auipc	a2,0x4
ffffffffc020384e:	d5e60613          	addi	a2,a2,-674 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc0203852:	06200593          	li	a1,98
ffffffffc0203856:	00004517          	auipc	a0,0x4
ffffffffc020385a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc020385e:	c27fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203862:	00004697          	auipc	a3,0x4
ffffffffc0203866:	65668693          	addi	a3,a3,1622 # ffffffffc0207eb8 <default_pmm_manager+0x9c0>
ffffffffc020386a:	00003617          	auipc	a2,0x3
ffffffffc020386e:	54660613          	addi	a2,a2,1350 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203872:	0fc00593          	li	a1,252
ffffffffc0203876:	00004517          	auipc	a0,0x4
ffffffffc020387a:	45250513          	addi	a0,a0,1106 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc020387e:	c07fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203882:	00004617          	auipc	a2,0x4
ffffffffc0203886:	fae60613          	addi	a2,a2,-82 # ffffffffc0207830 <default_pmm_manager+0x338>
ffffffffc020388a:	07400593          	li	a1,116
ffffffffc020388e:	00004517          	auipc	a0,0x4
ffffffffc0203892:	ce250513          	addi	a0,a0,-798 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0203896:	beffc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020389a:	00004697          	auipc	a3,0x4
ffffffffc020389e:	55668693          	addi	a3,a3,1366 # ffffffffc0207df0 <default_pmm_manager+0x8f8>
ffffffffc02038a2:	00003617          	auipc	a2,0x3
ffffffffc02038a6:	50e60613          	addi	a2,a2,1294 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02038aa:	0dd00593          	li	a1,221
ffffffffc02038ae:	00004517          	auipc	a0,0x4
ffffffffc02038b2:	41a50513          	addi	a0,a0,1050 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc02038b6:	bcffc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02038ba:	00004697          	auipc	a3,0x4
ffffffffc02038be:	51e68693          	addi	a3,a3,1310 # ffffffffc0207dd8 <default_pmm_manager+0x8e0>
ffffffffc02038c2:	00003617          	auipc	a2,0x3
ffffffffc02038c6:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02038ca:	0dc00593          	li	a1,220
ffffffffc02038ce:	00004517          	auipc	a0,0x4
ffffffffc02038d2:	3fa50513          	addi	a0,a0,1018 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc02038d6:	baffc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02038da:	00004697          	auipc	a3,0x4
ffffffffc02038de:	5c668693          	addi	a3,a3,1478 # ffffffffc0207ea0 <default_pmm_manager+0x9a8>
ffffffffc02038e2:	00003617          	auipc	a2,0x3
ffffffffc02038e6:	4ce60613          	addi	a2,a2,1230 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02038ea:	0fb00593          	li	a1,251
ffffffffc02038ee:	00004517          	auipc	a0,0x4
ffffffffc02038f2:	3da50513          	addi	a0,a0,986 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc02038f6:	b8ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02038fa:	00004617          	auipc	a2,0x4
ffffffffc02038fe:	3ae60613          	addi	a2,a2,942 # ffffffffc0207ca8 <default_pmm_manager+0x7b0>
ffffffffc0203902:	02800593          	li	a1,40
ffffffffc0203906:	00004517          	auipc	a0,0x4
ffffffffc020390a:	3c250513          	addi	a0,a0,962 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc020390e:	b77fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203912:	00004697          	auipc	a3,0x4
ffffffffc0203916:	55e68693          	addi	a3,a3,1374 # ffffffffc0207e70 <default_pmm_manager+0x978>
ffffffffc020391a:	00003617          	auipc	a2,0x3
ffffffffc020391e:	49660613          	addi	a2,a2,1174 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203922:	09700593          	li	a1,151
ffffffffc0203926:	00004517          	auipc	a0,0x4
ffffffffc020392a:	3a250513          	addi	a0,a0,930 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc020392e:	b57fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203932:	00004697          	auipc	a3,0x4
ffffffffc0203936:	53e68693          	addi	a3,a3,1342 # ffffffffc0207e70 <default_pmm_manager+0x978>
ffffffffc020393a:	00003617          	auipc	a2,0x3
ffffffffc020393e:	47660613          	addi	a2,a2,1142 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203942:	09900593          	li	a1,153
ffffffffc0203946:	00004517          	auipc	a0,0x4
ffffffffc020394a:	38250513          	addi	a0,a0,898 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc020394e:	b37fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203952:	00004697          	auipc	a3,0x4
ffffffffc0203956:	52e68693          	addi	a3,a3,1326 # ffffffffc0207e80 <default_pmm_manager+0x988>
ffffffffc020395a:	00003617          	auipc	a2,0x3
ffffffffc020395e:	45660613          	addi	a2,a2,1110 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203962:	09b00593          	li	a1,155
ffffffffc0203966:	00004517          	auipc	a0,0x4
ffffffffc020396a:	36250513          	addi	a0,a0,866 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc020396e:	b17fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203972:	00004697          	auipc	a3,0x4
ffffffffc0203976:	50e68693          	addi	a3,a3,1294 # ffffffffc0207e80 <default_pmm_manager+0x988>
ffffffffc020397a:	00003617          	auipc	a2,0x3
ffffffffc020397e:	43660613          	addi	a2,a2,1078 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203982:	09d00593          	li	a1,157
ffffffffc0203986:	00004517          	auipc	a0,0x4
ffffffffc020398a:	34250513          	addi	a0,a0,834 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc020398e:	af7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203992:	00004697          	auipc	a3,0x4
ffffffffc0203996:	4ce68693          	addi	a3,a3,1230 # ffffffffc0207e60 <default_pmm_manager+0x968>
ffffffffc020399a:	00003617          	auipc	a2,0x3
ffffffffc020399e:	41660613          	addi	a2,a2,1046 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02039a2:	09300593          	li	a1,147
ffffffffc02039a6:	00004517          	auipc	a0,0x4
ffffffffc02039aa:	32250513          	addi	a0,a0,802 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc02039ae:	ad7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc02039b2:	00004697          	auipc	a3,0x4
ffffffffc02039b6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0207e60 <default_pmm_manager+0x968>
ffffffffc02039ba:	00003617          	auipc	a2,0x3
ffffffffc02039be:	3f660613          	addi	a2,a2,1014 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02039c2:	09500593          	li	a1,149
ffffffffc02039c6:	00004517          	auipc	a0,0x4
ffffffffc02039ca:	30250513          	addi	a0,a0,770 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc02039ce:	ab7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc02039d2:	00004697          	auipc	a3,0x4
ffffffffc02039d6:	4be68693          	addi	a3,a3,1214 # ffffffffc0207e90 <default_pmm_manager+0x998>
ffffffffc02039da:	00003617          	auipc	a2,0x3
ffffffffc02039de:	3d660613          	addi	a2,a2,982 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02039e2:	09f00593          	li	a1,159
ffffffffc02039e6:	00004517          	auipc	a0,0x4
ffffffffc02039ea:	2e250513          	addi	a0,a0,738 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc02039ee:	a97fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc02039f2:	00004697          	auipc	a3,0x4
ffffffffc02039f6:	49e68693          	addi	a3,a3,1182 # ffffffffc0207e90 <default_pmm_manager+0x998>
ffffffffc02039fa:	00003617          	auipc	a2,0x3
ffffffffc02039fe:	3b660613          	addi	a2,a2,950 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203a02:	0a100593          	li	a1,161
ffffffffc0203a06:	00004517          	auipc	a0,0x4
ffffffffc0203a0a:	2c250513          	addi	a0,a0,706 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203a0e:	a77fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203a12:	00004697          	auipc	a3,0x4
ffffffffc0203a16:	32e68693          	addi	a3,a3,814 # ffffffffc0207d40 <default_pmm_manager+0x848>
ffffffffc0203a1a:	00003617          	auipc	a2,0x3
ffffffffc0203a1e:	39660613          	addi	a2,a2,918 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203a22:	0cc00593          	li	a1,204
ffffffffc0203a26:	00004517          	auipc	a0,0x4
ffffffffc0203a2a:	2a250513          	addi	a0,a0,674 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203a2e:	a57fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc0203a32:	00004697          	auipc	a3,0x4
ffffffffc0203a36:	31e68693          	addi	a3,a3,798 # ffffffffc0207d50 <default_pmm_manager+0x858>
ffffffffc0203a3a:	00003617          	auipc	a2,0x3
ffffffffc0203a3e:	37660613          	addi	a2,a2,886 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203a42:	0cf00593          	li	a1,207
ffffffffc0203a46:	00004517          	auipc	a0,0x4
ffffffffc0203a4a:	28250513          	addi	a0,a0,642 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203a4e:	a37fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203a52:	00004697          	auipc	a3,0x4
ffffffffc0203a56:	34668693          	addi	a3,a3,838 # ffffffffc0207d98 <default_pmm_manager+0x8a0>
ffffffffc0203a5a:	00003617          	auipc	a2,0x3
ffffffffc0203a5e:	35660613          	addi	a2,a2,854 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203a62:	0d700593          	li	a1,215
ffffffffc0203a66:	00004517          	auipc	a0,0x4
ffffffffc0203a6a:	26250513          	addi	a0,a0,610 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203a6e:	a17fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc0203a72:	00004697          	auipc	a3,0x4
ffffffffc0203a76:	8c668693          	addi	a3,a3,-1850 # ffffffffc0207338 <commands+0xa48>
ffffffffc0203a7a:	00003617          	auipc	a2,0x3
ffffffffc0203a7e:	33660613          	addi	a2,a2,822 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203a82:	0f300593          	li	a1,243
ffffffffc0203a86:	00004517          	auipc	a0,0x4
ffffffffc0203a8a:	24250513          	addi	a0,a0,578 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203a8e:	9f7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a92:	00004617          	auipc	a2,0x4
ffffffffc0203a96:	ab660613          	addi	a2,a2,-1354 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0203a9a:	06900593          	li	a1,105
ffffffffc0203a9e:	00004517          	auipc	a0,0x4
ffffffffc0203aa2:	ad250513          	addi	a0,a0,-1326 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0203aa6:	9dffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc0203aaa:	00004697          	auipc	a3,0x4
ffffffffc0203aae:	46668693          	addi	a3,a3,1126 # ffffffffc0207f10 <default_pmm_manager+0xa18>
ffffffffc0203ab2:	00003617          	auipc	a2,0x3
ffffffffc0203ab6:	2fe60613          	addi	a2,a2,766 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203aba:	11d00593          	li	a1,285
ffffffffc0203abe:	00004517          	auipc	a0,0x4
ffffffffc0203ac2:	20a50513          	addi	a0,a0,522 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203ac6:	9bffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc0203aca:	00004697          	auipc	a3,0x4
ffffffffc0203ace:	45668693          	addi	a3,a3,1110 # ffffffffc0207f20 <default_pmm_manager+0xa28>
ffffffffc0203ad2:	00003617          	auipc	a2,0x3
ffffffffc0203ad6:	2de60613          	addi	a2,a2,734 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203ada:	11e00593          	li	a1,286
ffffffffc0203ade:	00004517          	auipc	a0,0x4
ffffffffc0203ae2:	1ea50513          	addi	a0,a0,490 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203ae6:	99ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203aea:	00004697          	auipc	a3,0x4
ffffffffc0203aee:	32668693          	addi	a3,a3,806 # ffffffffc0207e10 <default_pmm_manager+0x918>
ffffffffc0203af2:	00003617          	auipc	a2,0x3
ffffffffc0203af6:	2be60613          	addi	a2,a2,702 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203afa:	0ea00593          	li	a1,234
ffffffffc0203afe:	00004517          	auipc	a0,0x4
ffffffffc0203b02:	1ca50513          	addi	a0,a0,458 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203b06:	97ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc0203b0a:	00004697          	auipc	a3,0x4
ffffffffc0203b0e:	20e68693          	addi	a3,a3,526 # ffffffffc0207d18 <default_pmm_manager+0x820>
ffffffffc0203b12:	00003617          	auipc	a2,0x3
ffffffffc0203b16:	29e60613          	addi	a2,a2,670 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203b1a:	0c400593          	li	a1,196
ffffffffc0203b1e:	00004517          	auipc	a0,0x4
ffffffffc0203b22:	1aa50513          	addi	a0,a0,426 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203b26:	95ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203b2a:	00004697          	auipc	a3,0x4
ffffffffc0203b2e:	1fe68693          	addi	a3,a3,510 # ffffffffc0207d28 <default_pmm_manager+0x830>
ffffffffc0203b32:	00003617          	auipc	a2,0x3
ffffffffc0203b36:	27e60613          	addi	a2,a2,638 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203b3a:	0c700593          	li	a1,199
ffffffffc0203b3e:	00004517          	auipc	a0,0x4
ffffffffc0203b42:	18a50513          	addi	a0,a0,394 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203b46:	93ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203b4a:	00004697          	auipc	a3,0x4
ffffffffc0203b4e:	3be68693          	addi	a3,a3,958 # ffffffffc0207f08 <default_pmm_manager+0xa10>
ffffffffc0203b52:	00003617          	auipc	a2,0x3
ffffffffc0203b56:	25e60613          	addi	a2,a2,606 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203b5a:	10200593          	li	a1,258
ffffffffc0203b5e:	00004517          	auipc	a0,0x4
ffffffffc0203b62:	16a50513          	addi	a0,a0,362 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203b66:	91ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203b6a:	00003697          	auipc	a3,0x3
ffffffffc0203b6e:	62668693          	addi	a3,a3,1574 # ffffffffc0207190 <commands+0x8a0>
ffffffffc0203b72:	00003617          	auipc	a2,0x3
ffffffffc0203b76:	23e60613          	addi	a2,a2,574 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203b7a:	0bf00593          	li	a1,191
ffffffffc0203b7e:	00004517          	auipc	a0,0x4
ffffffffc0203b82:	14a50513          	addi	a0,a0,330 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203b86:	8fffc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203b8a <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b8a:	000a9797          	auipc	a5,0xa9
ffffffffc0203b8e:	8ce78793          	addi	a5,a5,-1842 # ffffffffc02ac458 <sm>
ffffffffc0203b92:	639c                	ld	a5,0(a5)
ffffffffc0203b94:	0107b303          	ld	t1,16(a5)
ffffffffc0203b98:	8302                	jr	t1

ffffffffc0203b9a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b9a:	000a9797          	auipc	a5,0xa9
ffffffffc0203b9e:	8be78793          	addi	a5,a5,-1858 # ffffffffc02ac458 <sm>
ffffffffc0203ba2:	639c                	ld	a5,0(a5)
ffffffffc0203ba4:	0207b303          	ld	t1,32(a5)
ffffffffc0203ba8:	8302                	jr	t1

ffffffffc0203baa <swap_out>:
{
ffffffffc0203baa:	711d                	addi	sp,sp,-96
ffffffffc0203bac:	ec86                	sd	ra,88(sp)
ffffffffc0203bae:	e8a2                	sd	s0,80(sp)
ffffffffc0203bb0:	e4a6                	sd	s1,72(sp)
ffffffffc0203bb2:	e0ca                	sd	s2,64(sp)
ffffffffc0203bb4:	fc4e                	sd	s3,56(sp)
ffffffffc0203bb6:	f852                	sd	s4,48(sp)
ffffffffc0203bb8:	f456                	sd	s5,40(sp)
ffffffffc0203bba:	f05a                	sd	s6,32(sp)
ffffffffc0203bbc:	ec5e                	sd	s7,24(sp)
ffffffffc0203bbe:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203bc0:	cde9                	beqz	a1,ffffffffc0203c9a <swap_out+0xf0>
ffffffffc0203bc2:	8ab2                	mv	s5,a2
ffffffffc0203bc4:	892a                	mv	s2,a0
ffffffffc0203bc6:	8a2e                	mv	s4,a1
ffffffffc0203bc8:	4401                	li	s0,0
ffffffffc0203bca:	000a9997          	auipc	s3,0xa9
ffffffffc0203bce:	88e98993          	addi	s3,s3,-1906 # ffffffffc02ac458 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bd2:	00004b17          	auipc	s6,0x4
ffffffffc0203bd6:	3deb0b13          	addi	s6,s6,990 # ffffffffc0207fb0 <default_pmm_manager+0xab8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bda:	00004b97          	auipc	s7,0x4
ffffffffc0203bde:	3beb8b93          	addi	s7,s7,958 # ffffffffc0207f98 <default_pmm_manager+0xaa0>
ffffffffc0203be2:	a825                	j	ffffffffc0203c1a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203be4:	67a2                	ld	a5,8(sp)
ffffffffc0203be6:	8626                	mv	a2,s1
ffffffffc0203be8:	85a2                	mv	a1,s0
ffffffffc0203bea:	7f94                	ld	a3,56(a5)
ffffffffc0203bec:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203bee:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bf0:	82b1                	srli	a3,a3,0xc
ffffffffc0203bf2:	0685                	addi	a3,a3,1
ffffffffc0203bf4:	d9afc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203bf8:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203bfa:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203bfc:	7d1c                	ld	a5,56(a0)
ffffffffc0203bfe:	83b1                	srli	a5,a5,0xc
ffffffffc0203c00:	0785                	addi	a5,a5,1
ffffffffc0203c02:	07a2                	slli	a5,a5,0x8
ffffffffc0203c04:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203c08:	ad2fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203c0c:	01893503          	ld	a0,24(s2)
ffffffffc0203c10:	85a6                	mv	a1,s1
ffffffffc0203c12:	f5eff0ef          	jal	ra,ffffffffc0203370 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c16:	048a0d63          	beq	s4,s0,ffffffffc0203c70 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c1a:	0009b783          	ld	a5,0(s3)
ffffffffc0203c1e:	8656                	mv	a2,s5
ffffffffc0203c20:	002c                	addi	a1,sp,8
ffffffffc0203c22:	7b9c                	ld	a5,48(a5)
ffffffffc0203c24:	854a                	mv	a0,s2
ffffffffc0203c26:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c28:	e12d                	bnez	a0,ffffffffc0203c8a <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203c2a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c2c:	01893503          	ld	a0,24(s2)
ffffffffc0203c30:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c32:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c34:	85a6                	mv	a1,s1
ffffffffc0203c36:	b2afe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c3a:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c3c:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c3e:	8b85                	andi	a5,a5,1
ffffffffc0203c40:	cfb9                	beqz	a5,ffffffffc0203c9e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203c42:	65a2                	ld	a1,8(sp)
ffffffffc0203c44:	7d9c                	ld	a5,56(a1)
ffffffffc0203c46:	83b1                	srli	a5,a5,0xc
ffffffffc0203c48:	00178513          	addi	a0,a5,1
ffffffffc0203c4c:	0522                	slli	a0,a0,0x8
ffffffffc0203c4e:	146010ef          	jal	ra,ffffffffc0204d94 <swapfs_write>
ffffffffc0203c52:	d949                	beqz	a0,ffffffffc0203be4 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c54:	855e                	mv	a0,s7
ffffffffc0203c56:	d38fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c5a:	0009b783          	ld	a5,0(s3)
ffffffffc0203c5e:	6622                	ld	a2,8(sp)
ffffffffc0203c60:	4681                	li	a3,0
ffffffffc0203c62:	739c                	ld	a5,32(a5)
ffffffffc0203c64:	85a6                	mv	a1,s1
ffffffffc0203c66:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203c68:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c6a:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203c6c:	fa8a17e3          	bne	s4,s0,ffffffffc0203c1a <swap_out+0x70>
}
ffffffffc0203c70:	8522                	mv	a0,s0
ffffffffc0203c72:	60e6                	ld	ra,88(sp)
ffffffffc0203c74:	6446                	ld	s0,80(sp)
ffffffffc0203c76:	64a6                	ld	s1,72(sp)
ffffffffc0203c78:	6906                	ld	s2,64(sp)
ffffffffc0203c7a:	79e2                	ld	s3,56(sp)
ffffffffc0203c7c:	7a42                	ld	s4,48(sp)
ffffffffc0203c7e:	7aa2                	ld	s5,40(sp)
ffffffffc0203c80:	7b02                	ld	s6,32(sp)
ffffffffc0203c82:	6be2                	ld	s7,24(sp)
ffffffffc0203c84:	6c42                	ld	s8,16(sp)
ffffffffc0203c86:	6125                	addi	sp,sp,96
ffffffffc0203c88:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c8a:	85a2                	mv	a1,s0
ffffffffc0203c8c:	00004517          	auipc	a0,0x4
ffffffffc0203c90:	2c450513          	addi	a0,a0,708 # ffffffffc0207f50 <default_pmm_manager+0xa58>
ffffffffc0203c94:	cfafc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203c98:	bfe1                	j	ffffffffc0203c70 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c9a:	4401                	li	s0,0
ffffffffc0203c9c:	bfd1                	j	ffffffffc0203c70 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c9e:	00004697          	auipc	a3,0x4
ffffffffc0203ca2:	2e268693          	addi	a3,a3,738 # ffffffffc0207f80 <default_pmm_manager+0xa88>
ffffffffc0203ca6:	00003617          	auipc	a2,0x3
ffffffffc0203caa:	10a60613          	addi	a2,a2,266 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203cae:	06800593          	li	a1,104
ffffffffc0203cb2:	00004517          	auipc	a0,0x4
ffffffffc0203cb6:	01650513          	addi	a0,a0,22 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203cba:	fcafc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203cbe <swap_in>:
{
ffffffffc0203cbe:	7179                	addi	sp,sp,-48
ffffffffc0203cc0:	e84a                	sd	s2,16(sp)
ffffffffc0203cc2:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203cc4:	4505                	li	a0,1
{
ffffffffc0203cc6:	ec26                	sd	s1,24(sp)
ffffffffc0203cc8:	e44e                	sd	s3,8(sp)
ffffffffc0203cca:	f406                	sd	ra,40(sp)
ffffffffc0203ccc:	f022                	sd	s0,32(sp)
ffffffffc0203cce:	84ae                	mv	s1,a1
ffffffffc0203cd0:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203cd2:	980fe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203cd6:	c129                	beqz	a0,ffffffffc0203d18 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203cd8:	842a                	mv	s0,a0
ffffffffc0203cda:	01893503          	ld	a0,24(s2)
ffffffffc0203cde:	4601                	li	a2,0
ffffffffc0203ce0:	85a6                	mv	a1,s1
ffffffffc0203ce2:	a7efe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203ce6:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203ce8:	6108                	ld	a0,0(a0)
ffffffffc0203cea:	85a2                	mv	a1,s0
ffffffffc0203cec:	010010ef          	jal	ra,ffffffffc0204cfc <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203cf0:	00093583          	ld	a1,0(s2)
ffffffffc0203cf4:	8626                	mv	a2,s1
ffffffffc0203cf6:	00004517          	auipc	a0,0x4
ffffffffc0203cfa:	f7250513          	addi	a0,a0,-142 # ffffffffc0207c68 <default_pmm_manager+0x770>
ffffffffc0203cfe:	81a1                	srli	a1,a1,0x8
ffffffffc0203d00:	c8efc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203d04:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203d06:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203d0a:	7402                	ld	s0,32(sp)
ffffffffc0203d0c:	64e2                	ld	s1,24(sp)
ffffffffc0203d0e:	6942                	ld	s2,16(sp)
ffffffffc0203d10:	69a2                	ld	s3,8(sp)
ffffffffc0203d12:	4501                	li	a0,0
ffffffffc0203d14:	6145                	addi	sp,sp,48
ffffffffc0203d16:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d18:	00004697          	auipc	a3,0x4
ffffffffc0203d1c:	f4068693          	addi	a3,a3,-192 # ffffffffc0207c58 <default_pmm_manager+0x760>
ffffffffc0203d20:	00003617          	auipc	a2,0x3
ffffffffc0203d24:	09060613          	addi	a2,a2,144 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203d28:	07e00593          	li	a1,126
ffffffffc0203d2c:	00004517          	auipc	a0,0x4
ffffffffc0203d30:	f9c50513          	addi	a0,a0,-100 # ffffffffc0207cc8 <default_pmm_manager+0x7d0>
ffffffffc0203d34:	f50fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203d38 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d38:	000a9797          	auipc	a5,0xa9
ffffffffc0203d3c:	85878793          	addi	a5,a5,-1960 # ffffffffc02ac590 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203d40:	f51c                	sd	a5,40(a0)
ffffffffc0203d42:	e79c                	sd	a5,8(a5)
ffffffffc0203d44:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203d46:	4501                	li	a0,0
ffffffffc0203d48:	8082                	ret

ffffffffc0203d4a <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203d4a:	4501                	li	a0,0
ffffffffc0203d4c:	8082                	ret

ffffffffc0203d4e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203d4e:	4501                	li	a0,0
ffffffffc0203d50:	8082                	ret

ffffffffc0203d52 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203d52:	4501                	li	a0,0
ffffffffc0203d54:	8082                	ret

ffffffffc0203d56 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203d56:	711d                	addi	sp,sp,-96
ffffffffc0203d58:	fc4e                	sd	s3,56(sp)
ffffffffc0203d5a:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d5c:	00004517          	auipc	a0,0x4
ffffffffc0203d60:	29450513          	addi	a0,a0,660 # ffffffffc0207ff0 <default_pmm_manager+0xaf8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d64:	698d                	lui	s3,0x3
ffffffffc0203d66:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203d68:	e8a2                	sd	s0,80(sp)
ffffffffc0203d6a:	e4a6                	sd	s1,72(sp)
ffffffffc0203d6c:	ec86                	sd	ra,88(sp)
ffffffffc0203d6e:	e0ca                	sd	s2,64(sp)
ffffffffc0203d70:	f456                	sd	s5,40(sp)
ffffffffc0203d72:	f05a                	sd	s6,32(sp)
ffffffffc0203d74:	ec5e                	sd	s7,24(sp)
ffffffffc0203d76:	e862                	sd	s8,16(sp)
ffffffffc0203d78:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203d7a:	000a8417          	auipc	s0,0xa8
ffffffffc0203d7e:	6ea40413          	addi	s0,s0,1770 # ffffffffc02ac464 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d82:	c0cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d86:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
    assert(pgfault_num==4);
ffffffffc0203d8a:	4004                	lw	s1,0(s0)
ffffffffc0203d8c:	4791                	li	a5,4
ffffffffc0203d8e:	2481                	sext.w	s1,s1
ffffffffc0203d90:	14f49963          	bne	s1,a5,ffffffffc0203ee2 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d94:	00004517          	auipc	a0,0x4
ffffffffc0203d98:	29c50513          	addi	a0,a0,668 # ffffffffc0208030 <default_pmm_manager+0xb38>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d9c:	6a85                	lui	s5,0x1
ffffffffc0203d9e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203da0:	beefc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203da4:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
    assert(pgfault_num==4);
ffffffffc0203da8:	00042903          	lw	s2,0(s0)
ffffffffc0203dac:	2901                	sext.w	s2,s2
ffffffffc0203dae:	2a991a63          	bne	s2,s1,ffffffffc0204062 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203db2:	00004517          	auipc	a0,0x4
ffffffffc0203db6:	2a650513          	addi	a0,a0,678 # ffffffffc0208058 <default_pmm_manager+0xb60>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dba:	6b91                	lui	s7,0x4
ffffffffc0203dbc:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203dbe:	bd0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dc2:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
    assert(pgfault_num==4);
ffffffffc0203dc6:	4004                	lw	s1,0(s0)
ffffffffc0203dc8:	2481                	sext.w	s1,s1
ffffffffc0203dca:	27249c63          	bne	s1,s2,ffffffffc0204042 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dce:	00004517          	auipc	a0,0x4
ffffffffc0203dd2:	2b250513          	addi	a0,a0,690 # ffffffffc0208080 <default_pmm_manager+0xb88>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dd6:	6909                	lui	s2,0x2
ffffffffc0203dd8:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dda:	bb4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dde:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
    assert(pgfault_num==4);
ffffffffc0203de2:	401c                	lw	a5,0(s0)
ffffffffc0203de4:	2781                	sext.w	a5,a5
ffffffffc0203de6:	22979e63          	bne	a5,s1,ffffffffc0204022 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dea:	00004517          	auipc	a0,0x4
ffffffffc0203dee:	2be50513          	addi	a0,a0,702 # ffffffffc02080a8 <default_pmm_manager+0xbb0>
ffffffffc0203df2:	b9cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203df6:	6795                	lui	a5,0x5
ffffffffc0203df8:	4739                	li	a4,14
ffffffffc0203dfa:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==5);
ffffffffc0203dfe:	4004                	lw	s1,0(s0)
ffffffffc0203e00:	4795                	li	a5,5
ffffffffc0203e02:	2481                	sext.w	s1,s1
ffffffffc0203e04:	1ef49f63          	bne	s1,a5,ffffffffc0204002 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e08:	00004517          	auipc	a0,0x4
ffffffffc0203e0c:	27850513          	addi	a0,a0,632 # ffffffffc0208080 <default_pmm_manager+0xb88>
ffffffffc0203e10:	b7efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e14:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203e18:	401c                	lw	a5,0(s0)
ffffffffc0203e1a:	2781                	sext.w	a5,a5
ffffffffc0203e1c:	1c979363          	bne	a5,s1,ffffffffc0203fe2 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e20:	00004517          	auipc	a0,0x4
ffffffffc0203e24:	21050513          	addi	a0,a0,528 # ffffffffc0208030 <default_pmm_manager+0xb38>
ffffffffc0203e28:	b66fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e2c:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e30:	401c                	lw	a5,0(s0)
ffffffffc0203e32:	4719                	li	a4,6
ffffffffc0203e34:	2781                	sext.w	a5,a5
ffffffffc0203e36:	18e79663          	bne	a5,a4,ffffffffc0203fc2 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e3a:	00004517          	auipc	a0,0x4
ffffffffc0203e3e:	24650513          	addi	a0,a0,582 # ffffffffc0208080 <default_pmm_manager+0xb88>
ffffffffc0203e42:	b4cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e46:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203e4a:	401c                	lw	a5,0(s0)
ffffffffc0203e4c:	471d                	li	a4,7
ffffffffc0203e4e:	2781                	sext.w	a5,a5
ffffffffc0203e50:	14e79963          	bne	a5,a4,ffffffffc0203fa2 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e54:	00004517          	auipc	a0,0x4
ffffffffc0203e58:	19c50513          	addi	a0,a0,412 # ffffffffc0207ff0 <default_pmm_manager+0xaf8>
ffffffffc0203e5c:	b32fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e60:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203e64:	401c                	lw	a5,0(s0)
ffffffffc0203e66:	4721                	li	a4,8
ffffffffc0203e68:	2781                	sext.w	a5,a5
ffffffffc0203e6a:	10e79c63          	bne	a5,a4,ffffffffc0203f82 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e6e:	00004517          	auipc	a0,0x4
ffffffffc0203e72:	1ea50513          	addi	a0,a0,490 # ffffffffc0208058 <default_pmm_manager+0xb60>
ffffffffc0203e76:	b18fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e7a:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e7e:	401c                	lw	a5,0(s0)
ffffffffc0203e80:	4725                	li	a4,9
ffffffffc0203e82:	2781                	sext.w	a5,a5
ffffffffc0203e84:	0ce79f63          	bne	a5,a4,ffffffffc0203f62 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e88:	00004517          	auipc	a0,0x4
ffffffffc0203e8c:	22050513          	addi	a0,a0,544 # ffffffffc02080a8 <default_pmm_manager+0xbb0>
ffffffffc0203e90:	afefc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e94:	6795                	lui	a5,0x5
ffffffffc0203e96:	4739                	li	a4,14
ffffffffc0203e98:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==10);
ffffffffc0203e9c:	4004                	lw	s1,0(s0)
ffffffffc0203e9e:	47a9                	li	a5,10
ffffffffc0203ea0:	2481                	sext.w	s1,s1
ffffffffc0203ea2:	0af49063          	bne	s1,a5,ffffffffc0203f42 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203ea6:	00004517          	auipc	a0,0x4
ffffffffc0203eaa:	18a50513          	addi	a0,a0,394 # ffffffffc0208030 <default_pmm_manager+0xb38>
ffffffffc0203eae:	ae0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203eb2:	6785                	lui	a5,0x1
ffffffffc0203eb4:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0203eb8:	06979563          	bne	a5,s1,ffffffffc0203f22 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203ebc:	401c                	lw	a5,0(s0)
ffffffffc0203ebe:	472d                	li	a4,11
ffffffffc0203ec0:	2781                	sext.w	a5,a5
ffffffffc0203ec2:	04e79063          	bne	a5,a4,ffffffffc0203f02 <_fifo_check_swap+0x1ac>
}
ffffffffc0203ec6:	60e6                	ld	ra,88(sp)
ffffffffc0203ec8:	6446                	ld	s0,80(sp)
ffffffffc0203eca:	64a6                	ld	s1,72(sp)
ffffffffc0203ecc:	6906                	ld	s2,64(sp)
ffffffffc0203ece:	79e2                	ld	s3,56(sp)
ffffffffc0203ed0:	7a42                	ld	s4,48(sp)
ffffffffc0203ed2:	7aa2                	ld	s5,40(sp)
ffffffffc0203ed4:	7b02                	ld	s6,32(sp)
ffffffffc0203ed6:	6be2                	ld	s7,24(sp)
ffffffffc0203ed8:	6c42                	ld	s8,16(sp)
ffffffffc0203eda:	6ca2                	ld	s9,8(sp)
ffffffffc0203edc:	4501                	li	a0,0
ffffffffc0203ede:	6125                	addi	sp,sp,96
ffffffffc0203ee0:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203ee2:	00004697          	auipc	a3,0x4
ffffffffc0203ee6:	fae68693          	addi	a3,a3,-82 # ffffffffc0207e90 <default_pmm_manager+0x998>
ffffffffc0203eea:	00003617          	auipc	a2,0x3
ffffffffc0203eee:	ec660613          	addi	a2,a2,-314 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203ef2:	05100593          	li	a1,81
ffffffffc0203ef6:	00004517          	auipc	a0,0x4
ffffffffc0203efa:	12250513          	addi	a0,a0,290 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203efe:	d86fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==11);
ffffffffc0203f02:	00004697          	auipc	a3,0x4
ffffffffc0203f06:	25668693          	addi	a3,a3,598 # ffffffffc0208158 <default_pmm_manager+0xc60>
ffffffffc0203f0a:	00003617          	auipc	a2,0x3
ffffffffc0203f0e:	ea660613          	addi	a2,a2,-346 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203f12:	07300593          	li	a1,115
ffffffffc0203f16:	00004517          	auipc	a0,0x4
ffffffffc0203f1a:	10250513          	addi	a0,a0,258 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203f1e:	d66fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f22:	00004697          	auipc	a3,0x4
ffffffffc0203f26:	20e68693          	addi	a3,a3,526 # ffffffffc0208130 <default_pmm_manager+0xc38>
ffffffffc0203f2a:	00003617          	auipc	a2,0x3
ffffffffc0203f2e:	e8660613          	addi	a2,a2,-378 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203f32:	07100593          	li	a1,113
ffffffffc0203f36:	00004517          	auipc	a0,0x4
ffffffffc0203f3a:	0e250513          	addi	a0,a0,226 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203f3e:	d46fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==10);
ffffffffc0203f42:	00004697          	auipc	a3,0x4
ffffffffc0203f46:	1de68693          	addi	a3,a3,478 # ffffffffc0208120 <default_pmm_manager+0xc28>
ffffffffc0203f4a:	00003617          	auipc	a2,0x3
ffffffffc0203f4e:	e6660613          	addi	a2,a2,-410 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203f52:	06f00593          	li	a1,111
ffffffffc0203f56:	00004517          	auipc	a0,0x4
ffffffffc0203f5a:	0c250513          	addi	a0,a0,194 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203f5e:	d26fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==9);
ffffffffc0203f62:	00004697          	auipc	a3,0x4
ffffffffc0203f66:	1ae68693          	addi	a3,a3,430 # ffffffffc0208110 <default_pmm_manager+0xc18>
ffffffffc0203f6a:	00003617          	auipc	a2,0x3
ffffffffc0203f6e:	e4660613          	addi	a2,a2,-442 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203f72:	06c00593          	li	a1,108
ffffffffc0203f76:	00004517          	auipc	a0,0x4
ffffffffc0203f7a:	0a250513          	addi	a0,a0,162 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203f7e:	d06fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==8);
ffffffffc0203f82:	00004697          	auipc	a3,0x4
ffffffffc0203f86:	17e68693          	addi	a3,a3,382 # ffffffffc0208100 <default_pmm_manager+0xc08>
ffffffffc0203f8a:	00003617          	auipc	a2,0x3
ffffffffc0203f8e:	e2660613          	addi	a2,a2,-474 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203f92:	06900593          	li	a1,105
ffffffffc0203f96:	00004517          	auipc	a0,0x4
ffffffffc0203f9a:	08250513          	addi	a0,a0,130 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203f9e:	ce6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==7);
ffffffffc0203fa2:	00004697          	auipc	a3,0x4
ffffffffc0203fa6:	14e68693          	addi	a3,a3,334 # ffffffffc02080f0 <default_pmm_manager+0xbf8>
ffffffffc0203faa:	00003617          	auipc	a2,0x3
ffffffffc0203fae:	e0660613          	addi	a2,a2,-506 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203fb2:	06600593          	li	a1,102
ffffffffc0203fb6:	00004517          	auipc	a0,0x4
ffffffffc0203fba:	06250513          	addi	a0,a0,98 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203fbe:	cc6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==6);
ffffffffc0203fc2:	00004697          	auipc	a3,0x4
ffffffffc0203fc6:	11e68693          	addi	a3,a3,286 # ffffffffc02080e0 <default_pmm_manager+0xbe8>
ffffffffc0203fca:	00003617          	auipc	a2,0x3
ffffffffc0203fce:	de660613          	addi	a2,a2,-538 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203fd2:	06300593          	li	a1,99
ffffffffc0203fd6:	00004517          	auipc	a0,0x4
ffffffffc0203fda:	04250513          	addi	a0,a0,66 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203fde:	ca6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203fe2:	00004697          	auipc	a3,0x4
ffffffffc0203fe6:	0ee68693          	addi	a3,a3,238 # ffffffffc02080d0 <default_pmm_manager+0xbd8>
ffffffffc0203fea:	00003617          	auipc	a2,0x3
ffffffffc0203fee:	dc660613          	addi	a2,a2,-570 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0203ff2:	06000593          	li	a1,96
ffffffffc0203ff6:	00004517          	auipc	a0,0x4
ffffffffc0203ffa:	02250513          	addi	a0,a0,34 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc0203ffe:	c86fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0204002:	00004697          	auipc	a3,0x4
ffffffffc0204006:	0ce68693          	addi	a3,a3,206 # ffffffffc02080d0 <default_pmm_manager+0xbd8>
ffffffffc020400a:	00003617          	auipc	a2,0x3
ffffffffc020400e:	da660613          	addi	a2,a2,-602 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204012:	05d00593          	li	a1,93
ffffffffc0204016:	00004517          	auipc	a0,0x4
ffffffffc020401a:	00250513          	addi	a0,a0,2 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc020401e:	c66fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0204022:	00004697          	auipc	a3,0x4
ffffffffc0204026:	e6e68693          	addi	a3,a3,-402 # ffffffffc0207e90 <default_pmm_manager+0x998>
ffffffffc020402a:	00003617          	auipc	a2,0x3
ffffffffc020402e:	d8660613          	addi	a2,a2,-634 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204032:	05a00593          	li	a1,90
ffffffffc0204036:	00004517          	auipc	a0,0x4
ffffffffc020403a:	fe250513          	addi	a0,a0,-30 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc020403e:	c46fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0204042:	00004697          	auipc	a3,0x4
ffffffffc0204046:	e4e68693          	addi	a3,a3,-434 # ffffffffc0207e90 <default_pmm_manager+0x998>
ffffffffc020404a:	00003617          	auipc	a2,0x3
ffffffffc020404e:	d6660613          	addi	a2,a2,-666 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204052:	05700593          	li	a1,87
ffffffffc0204056:	00004517          	auipc	a0,0x4
ffffffffc020405a:	fc250513          	addi	a0,a0,-62 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc020405e:	c26fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0204062:	00004697          	auipc	a3,0x4
ffffffffc0204066:	e2e68693          	addi	a3,a3,-466 # ffffffffc0207e90 <default_pmm_manager+0x998>
ffffffffc020406a:	00003617          	auipc	a2,0x3
ffffffffc020406e:	d4660613          	addi	a2,a2,-698 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204072:	05400593          	li	a1,84
ffffffffc0204076:	00004517          	auipc	a0,0x4
ffffffffc020407a:	fa250513          	addi	a0,a0,-94 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc020407e:	c06fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204082 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204082:	751c                	ld	a5,40(a0)
{
ffffffffc0204084:	1141                	addi	sp,sp,-16
ffffffffc0204086:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204088:	cf91                	beqz	a5,ffffffffc02040a4 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc020408a:	ee0d                	bnez	a2,ffffffffc02040c4 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc020408c:	679c                	ld	a5,8(a5)
}
ffffffffc020408e:	60a2                	ld	ra,8(sp)
ffffffffc0204090:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204092:	6394                	ld	a3,0(a5)
ffffffffc0204094:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204096:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020409a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020409c:	e314                	sd	a3,0(a4)
ffffffffc020409e:	e19c                	sd	a5,0(a1)
}
ffffffffc02040a0:	0141                	addi	sp,sp,16
ffffffffc02040a2:	8082                	ret
         assert(head != NULL);
ffffffffc02040a4:	00004697          	auipc	a3,0x4
ffffffffc02040a8:	0e468693          	addi	a3,a3,228 # ffffffffc0208188 <default_pmm_manager+0xc90>
ffffffffc02040ac:	00003617          	auipc	a2,0x3
ffffffffc02040b0:	d0460613          	addi	a2,a2,-764 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02040b4:	04100593          	li	a1,65
ffffffffc02040b8:	00004517          	auipc	a0,0x4
ffffffffc02040bc:	f6050513          	addi	a0,a0,-160 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc02040c0:	bc4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(in_tick==0);
ffffffffc02040c4:	00004697          	auipc	a3,0x4
ffffffffc02040c8:	0d468693          	addi	a3,a3,212 # ffffffffc0208198 <default_pmm_manager+0xca0>
ffffffffc02040cc:	00003617          	auipc	a2,0x3
ffffffffc02040d0:	ce460613          	addi	a2,a2,-796 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02040d4:	04200593          	li	a1,66
ffffffffc02040d8:	00004517          	auipc	a0,0x4
ffffffffc02040dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0208018 <default_pmm_manager+0xb20>
ffffffffc02040e0:	ba4fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02040e4 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02040e4:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040e8:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02040ea:	cb09                	beqz	a4,ffffffffc02040fc <_fifo_map_swappable+0x18>
ffffffffc02040ec:	cb81                	beqz	a5,ffffffffc02040fc <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02040ee:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc02040f0:	e398                	sd	a4,0(a5)
}
ffffffffc02040f2:	4501                	li	a0,0
ffffffffc02040f4:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc02040f6:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02040f8:	f614                	sd	a3,40(a2)
ffffffffc02040fa:	8082                	ret
{
ffffffffc02040fc:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02040fe:	00004697          	auipc	a3,0x4
ffffffffc0204102:	06a68693          	addi	a3,a3,106 # ffffffffc0208168 <default_pmm_manager+0xc70>
ffffffffc0204106:	00003617          	auipc	a2,0x3
ffffffffc020410a:	caa60613          	addi	a2,a2,-854 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020410e:	03200593          	li	a1,50
ffffffffc0204112:	00004517          	auipc	a0,0x4
ffffffffc0204116:	f0650513          	addi	a0,a0,-250 # ffffffffc0208018 <default_pmm_manager+0xb20>
{
ffffffffc020411a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020411c:	b68fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204120 <check_vma_overlap.isra.1.part.2>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204120:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204122:	00004697          	auipc	a3,0x4
ffffffffc0204126:	09e68693          	addi	a3,a3,158 # ffffffffc02081c0 <default_pmm_manager+0xcc8>
ffffffffc020412a:	00003617          	auipc	a2,0x3
ffffffffc020412e:	c8660613          	addi	a2,a2,-890 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204132:	06d00593          	li	a1,109
ffffffffc0204136:	00004517          	auipc	a0,0x4
ffffffffc020413a:	0aa50513          	addi	a0,a0,170 # ffffffffc02081e0 <default_pmm_manager+0xce8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020413e:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204140:	b44fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204144 <mm_create>:
mm_create(void) {
ffffffffc0204144:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204146:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020414a:	e022                	sd	s0,0(sp)
ffffffffc020414c:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020414e:	b09fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204152:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204154:	c515                	beqz	a0,ffffffffc0204180 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204156:	000a8797          	auipc	a5,0xa8
ffffffffc020415a:	30a78793          	addi	a5,a5,778 # ffffffffc02ac460 <swap_init_ok>
ffffffffc020415e:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0204160:	e408                	sd	a0,8(s0)
ffffffffc0204162:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204164:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204168:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020416c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204170:	2781                	sext.w	a5,a5
ffffffffc0204172:	ef81                	bnez	a5,ffffffffc020418a <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0204174:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204178:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020417c:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204180:	8522                	mv	a0,s0
ffffffffc0204182:	60a2                	ld	ra,8(sp)
ffffffffc0204184:	6402                	ld	s0,0(sp)
ffffffffc0204186:	0141                	addi	sp,sp,16
ffffffffc0204188:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020418a:	a01ff0ef          	jal	ra,ffffffffc0203b8a <swap_init_mm>
ffffffffc020418e:	b7ed                	j	ffffffffc0204178 <mm_create+0x34>

ffffffffc0204190 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204190:	1101                	addi	sp,sp,-32
ffffffffc0204192:	e04a                	sd	s2,0(sp)
ffffffffc0204194:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204196:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020419a:	e822                	sd	s0,16(sp)
ffffffffc020419c:	e426                	sd	s1,8(sp)
ffffffffc020419e:	ec06                	sd	ra,24(sp)
ffffffffc02041a0:	84ae                	mv	s1,a1
ffffffffc02041a2:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02041a4:	ab3fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
    if (vma != NULL) {
ffffffffc02041a8:	c509                	beqz	a0,ffffffffc02041b2 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02041aa:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02041ae:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02041b0:	cd00                	sw	s0,24(a0)
}
ffffffffc02041b2:	60e2                	ld	ra,24(sp)
ffffffffc02041b4:	6442                	ld	s0,16(sp)
ffffffffc02041b6:	64a2                	ld	s1,8(sp)
ffffffffc02041b8:	6902                	ld	s2,0(sp)
ffffffffc02041ba:	6105                	addi	sp,sp,32
ffffffffc02041bc:	8082                	ret

ffffffffc02041be <find_vma>:
    if (mm != NULL) {
ffffffffc02041be:	c51d                	beqz	a0,ffffffffc02041ec <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02041c0:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041c2:	c781                	beqz	a5,ffffffffc02041ca <find_vma+0xc>
ffffffffc02041c4:	6798                	ld	a4,8(a5)
ffffffffc02041c6:	02e5f663          	bleu	a4,a1,ffffffffc02041f2 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02041ca:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02041cc:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02041ce:	00f50f63          	beq	a0,a5,ffffffffc02041ec <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02041d2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02041d6:	fee5ebe3          	bltu	a1,a4,ffffffffc02041cc <find_vma+0xe>
ffffffffc02041da:	ff07b703          	ld	a4,-16(a5)
ffffffffc02041de:	fee5f7e3          	bleu	a4,a1,ffffffffc02041cc <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02041e2:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02041e4:	c781                	beqz	a5,ffffffffc02041ec <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02041e6:	e91c                	sd	a5,16(a0)
}
ffffffffc02041e8:	853e                	mv	a0,a5
ffffffffc02041ea:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02041ec:	4781                	li	a5,0
}
ffffffffc02041ee:	853e                	mv	a0,a5
ffffffffc02041f0:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041f2:	6b98                	ld	a4,16(a5)
ffffffffc02041f4:	fce5fbe3          	bleu	a4,a1,ffffffffc02041ca <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02041f8:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02041fa:	b7fd                	j	ffffffffc02041e8 <find_vma+0x2a>

ffffffffc02041fc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041fc:	6590                	ld	a2,8(a1)
ffffffffc02041fe:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8560>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204202:	1141                	addi	sp,sp,-16
ffffffffc0204204:	e406                	sd	ra,8(sp)
ffffffffc0204206:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204208:	01066863          	bltu	a2,a6,ffffffffc0204218 <insert_vma_struct+0x1c>
ffffffffc020420c:	a8b9                	j	ffffffffc020426a <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020420e:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204212:	04d66763          	bltu	a2,a3,ffffffffc0204260 <insert_vma_struct+0x64>
ffffffffc0204216:	873e                	mv	a4,a5
ffffffffc0204218:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020421a:	fef51ae3          	bne	a0,a5,ffffffffc020420e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020421e:	02a70463          	beq	a4,a0,ffffffffc0204246 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204222:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204226:	fe873883          	ld	a7,-24(a4)
ffffffffc020422a:	08d8f063          	bleu	a3,a7,ffffffffc02042aa <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020422e:	04d66e63          	bltu	a2,a3,ffffffffc020428a <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0204232:	00f50a63          	beq	a0,a5,ffffffffc0204246 <insert_vma_struct+0x4a>
ffffffffc0204236:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020423a:	0506e863          	bltu	a3,a6,ffffffffc020428a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020423e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204242:	02c6f263          	bleu	a2,a3,ffffffffc0204266 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204246:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0204248:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020424a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020424e:	e390                	sd	a2,0(a5)
ffffffffc0204250:	e710                	sd	a2,8(a4)
}
ffffffffc0204252:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204254:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204256:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0204258:	2685                	addiw	a3,a3,1
ffffffffc020425a:	d114                	sw	a3,32(a0)
}
ffffffffc020425c:	0141                	addi	sp,sp,16
ffffffffc020425e:	8082                	ret
    if (le_prev != list) {
ffffffffc0204260:	fca711e3          	bne	a4,a0,ffffffffc0204222 <insert_vma_struct+0x26>
ffffffffc0204264:	bfd9                	j	ffffffffc020423a <insert_vma_struct+0x3e>
ffffffffc0204266:	ebbff0ef          	jal	ra,ffffffffc0204120 <check_vma_overlap.isra.1.part.2>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020426a:	00004697          	auipc	a3,0x4
ffffffffc020426e:	08668693          	addi	a3,a3,134 # ffffffffc02082f0 <default_pmm_manager+0xdf8>
ffffffffc0204272:	00003617          	auipc	a2,0x3
ffffffffc0204276:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020427a:	07400593          	li	a1,116
ffffffffc020427e:	00004517          	auipc	a0,0x4
ffffffffc0204282:	f6250513          	addi	a0,a0,-158 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204286:	9fefc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020428a:	00004697          	auipc	a3,0x4
ffffffffc020428e:	0a668693          	addi	a3,a3,166 # ffffffffc0208330 <default_pmm_manager+0xe38>
ffffffffc0204292:	00003617          	auipc	a2,0x3
ffffffffc0204296:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020429a:	06c00593          	li	a1,108
ffffffffc020429e:	00004517          	auipc	a0,0x4
ffffffffc02042a2:	f4250513          	addi	a0,a0,-190 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02042a6:	9defc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02042aa:	00004697          	auipc	a3,0x4
ffffffffc02042ae:	06668693          	addi	a3,a3,102 # ffffffffc0208310 <default_pmm_manager+0xe18>
ffffffffc02042b2:	00003617          	auipc	a2,0x3
ffffffffc02042b6:	afe60613          	addi	a2,a2,-1282 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02042ba:	06b00593          	li	a1,107
ffffffffc02042be:	00004517          	auipc	a0,0x4
ffffffffc02042c2:	f2250513          	addi	a0,a0,-222 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02042c6:	9befc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02042ca <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02042ca:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02042cc:	1141                	addi	sp,sp,-16
ffffffffc02042ce:	e406                	sd	ra,8(sp)
ffffffffc02042d0:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02042d2:	e78d                	bnez	a5,ffffffffc02042fc <mm_destroy+0x32>
ffffffffc02042d4:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02042d6:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02042d8:	00a40c63          	beq	s0,a0,ffffffffc02042f0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02042dc:	6118                	ld	a4,0(a0)
ffffffffc02042de:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02042e0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02042e2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02042e4:	e398                	sd	a4,0(a5)
ffffffffc02042e6:	a2dfd0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return listelm->next;
ffffffffc02042ea:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02042ec:	fea418e3          	bne	s0,a0,ffffffffc02042dc <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02042f0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02042f2:	6402                	ld	s0,0(sp)
ffffffffc02042f4:	60a2                	ld	ra,8(sp)
ffffffffc02042f6:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02042f8:	a1bfd06f          	j	ffffffffc0201d12 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02042fc:	00004697          	auipc	a3,0x4
ffffffffc0204300:	05468693          	addi	a3,a3,84 # ffffffffc0208350 <default_pmm_manager+0xe58>
ffffffffc0204304:	00003617          	auipc	a2,0x3
ffffffffc0204308:	aac60613          	addi	a2,a2,-1364 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020430c:	09400593          	li	a1,148
ffffffffc0204310:	00004517          	auipc	a0,0x4
ffffffffc0204314:	ed050513          	addi	a0,a0,-304 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204318:	96cfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020431c <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020431c:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc020431e:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204320:	17fd                	addi	a5,a5,-1
ffffffffc0204322:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0204324:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204326:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc020432a:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020432c:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc020432e:	fc06                	sd	ra,56(sp)
ffffffffc0204330:	f04a                	sd	s2,32(sp)
ffffffffc0204332:	ec4e                	sd	s3,24(sp)
ffffffffc0204334:	e852                	sd	s4,16(sp)
ffffffffc0204336:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204338:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc020433c:	002007b7          	lui	a5,0x200
ffffffffc0204340:	01047433          	and	s0,s0,a6
ffffffffc0204344:	06f4e363          	bltu	s1,a5,ffffffffc02043aa <mm_map+0x8e>
ffffffffc0204348:	0684f163          	bleu	s0,s1,ffffffffc02043aa <mm_map+0x8e>
ffffffffc020434c:	4785                	li	a5,1
ffffffffc020434e:	07fe                	slli	a5,a5,0x1f
ffffffffc0204350:	0487ed63          	bltu	a5,s0,ffffffffc02043aa <mm_map+0x8e>
ffffffffc0204354:	89aa                	mv	s3,a0
ffffffffc0204356:	8a3a                	mv	s4,a4
ffffffffc0204358:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020435a:	c931                	beqz	a0,ffffffffc02043ae <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020435c:	85a6                	mv	a1,s1
ffffffffc020435e:	e61ff0ef          	jal	ra,ffffffffc02041be <find_vma>
ffffffffc0204362:	c501                	beqz	a0,ffffffffc020436a <mm_map+0x4e>
ffffffffc0204364:	651c                	ld	a5,8(a0)
ffffffffc0204366:	0487e263          	bltu	a5,s0,ffffffffc02043aa <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020436a:	03000513          	li	a0,48
ffffffffc020436e:	8e9fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204372:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204374:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204376:	02090163          	beqz	s2,ffffffffc0204398 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020437a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020437c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204380:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204384:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204388:	85ca                	mv	a1,s2
ffffffffc020438a:	e73ff0ef          	jal	ra,ffffffffc02041fc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020438e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204390:	000a0463          	beqz	s4,ffffffffc0204398 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204394:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204398:	70e2                	ld	ra,56(sp)
ffffffffc020439a:	7442                	ld	s0,48(sp)
ffffffffc020439c:	74a2                	ld	s1,40(sp)
ffffffffc020439e:	7902                	ld	s2,32(sp)
ffffffffc02043a0:	69e2                	ld	s3,24(sp)
ffffffffc02043a2:	6a42                	ld	s4,16(sp)
ffffffffc02043a4:	6aa2                	ld	s5,8(sp)
ffffffffc02043a6:	6121                	addi	sp,sp,64
ffffffffc02043a8:	8082                	ret
        return -E_INVAL;
ffffffffc02043aa:	5575                	li	a0,-3
ffffffffc02043ac:	b7f5                	j	ffffffffc0204398 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02043ae:	00004697          	auipc	a3,0x4
ffffffffc02043b2:	96a68693          	addi	a3,a3,-1686 # ffffffffc0207d18 <default_pmm_manager+0x820>
ffffffffc02043b6:	00003617          	auipc	a2,0x3
ffffffffc02043ba:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02043be:	0a700593          	li	a1,167
ffffffffc02043c2:	00004517          	auipc	a0,0x4
ffffffffc02043c6:	e1e50513          	addi	a0,a0,-482 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02043ca:	8bafc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043ce <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02043ce:	7139                	addi	sp,sp,-64
ffffffffc02043d0:	fc06                	sd	ra,56(sp)
ffffffffc02043d2:	f822                	sd	s0,48(sp)
ffffffffc02043d4:	f426                	sd	s1,40(sp)
ffffffffc02043d6:	f04a                	sd	s2,32(sp)
ffffffffc02043d8:	ec4e                	sd	s3,24(sp)
ffffffffc02043da:	e852                	sd	s4,16(sp)
ffffffffc02043dc:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02043de:	c535                	beqz	a0,ffffffffc020444a <dup_mmap+0x7c>
ffffffffc02043e0:	892a                	mv	s2,a0
ffffffffc02043e2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02043e4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02043e6:	e59d                	bnez	a1,ffffffffc0204414 <dup_mmap+0x46>
ffffffffc02043e8:	a08d                	j	ffffffffc020444a <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02043ea:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02043ec:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5588>
        insert_vma_struct(to, nvma);
ffffffffc02043f0:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02043f2:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02043f6:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02043fa:	e03ff0ef          	jal	ra,ffffffffc02041fc <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02043fe:	ff043683          	ld	a3,-16(s0)
ffffffffc0204402:	fe843603          	ld	a2,-24(s0)
ffffffffc0204406:	6c8c                	ld	a1,24(s1)
ffffffffc0204408:	01893503          	ld	a0,24(s2)
ffffffffc020440c:	4705                	li	a4,1
ffffffffc020440e:	cb1fe0ef          	jal	ra,ffffffffc02030be <copy_range>
ffffffffc0204412:	e105                	bnez	a0,ffffffffc0204432 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204414:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0204416:	02848863          	beq	s1,s0,ffffffffc0204446 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020441a:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020441e:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204422:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204426:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020442a:	82dfd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc020442e:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0204430:	fd4d                	bnez	a0,ffffffffc02043ea <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0204432:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0204434:	70e2                	ld	ra,56(sp)
ffffffffc0204436:	7442                	ld	s0,48(sp)
ffffffffc0204438:	74a2                	ld	s1,40(sp)
ffffffffc020443a:	7902                	ld	s2,32(sp)
ffffffffc020443c:	69e2                	ld	s3,24(sp)
ffffffffc020443e:	6a42                	ld	s4,16(sp)
ffffffffc0204440:	6aa2                	ld	s5,8(sp)
ffffffffc0204442:	6121                	addi	sp,sp,64
ffffffffc0204444:	8082                	ret
    return 0;
ffffffffc0204446:	4501                	li	a0,0
ffffffffc0204448:	b7f5                	j	ffffffffc0204434 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc020444a:	00004697          	auipc	a3,0x4
ffffffffc020444e:	e6668693          	addi	a3,a3,-410 # ffffffffc02082b0 <default_pmm_manager+0xdb8>
ffffffffc0204452:	00003617          	auipc	a2,0x3
ffffffffc0204456:	95e60613          	addi	a2,a2,-1698 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020445a:	0c000593          	li	a1,192
ffffffffc020445e:	00004517          	auipc	a0,0x4
ffffffffc0204462:	d8250513          	addi	a0,a0,-638 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204466:	81efc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020446a <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020446a:	1101                	addi	sp,sp,-32
ffffffffc020446c:	ec06                	sd	ra,24(sp)
ffffffffc020446e:	e822                	sd	s0,16(sp)
ffffffffc0204470:	e426                	sd	s1,8(sp)
ffffffffc0204472:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204474:	c531                	beqz	a0,ffffffffc02044c0 <exit_mmap+0x56>
ffffffffc0204476:	591c                	lw	a5,48(a0)
ffffffffc0204478:	84aa                	mv	s1,a0
ffffffffc020447a:	e3b9                	bnez	a5,ffffffffc02044c0 <exit_mmap+0x56>
    return listelm->next;
ffffffffc020447c:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020447e:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204482:	02850663          	beq	a0,s0,ffffffffc02044ae <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204486:	ff043603          	ld	a2,-16(s0)
ffffffffc020448a:	fe843583          	ld	a1,-24(s0)
ffffffffc020448e:	854a                	mv	a0,s2
ffffffffc0204490:	d05fd0ef          	jal	ra,ffffffffc0202194 <unmap_range>
ffffffffc0204494:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204496:	fe8498e3          	bne	s1,s0,ffffffffc0204486 <exit_mmap+0x1c>
ffffffffc020449a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020449c:	00848c63          	beq	s1,s0,ffffffffc02044b4 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044a0:	ff043603          	ld	a2,-16(s0)
ffffffffc02044a4:	fe843583          	ld	a1,-24(s0)
ffffffffc02044a8:	854a                	mv	a0,s2
ffffffffc02044aa:	e03fd0ef          	jal	ra,ffffffffc02022ac <exit_range>
ffffffffc02044ae:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02044b0:	fe8498e3          	bne	s1,s0,ffffffffc02044a0 <exit_mmap+0x36>
    }
}
ffffffffc02044b4:	60e2                	ld	ra,24(sp)
ffffffffc02044b6:	6442                	ld	s0,16(sp)
ffffffffc02044b8:	64a2                	ld	s1,8(sp)
ffffffffc02044ba:	6902                	ld	s2,0(sp)
ffffffffc02044bc:	6105                	addi	sp,sp,32
ffffffffc02044be:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02044c0:	00004697          	auipc	a3,0x4
ffffffffc02044c4:	e1068693          	addi	a3,a3,-496 # ffffffffc02082d0 <default_pmm_manager+0xdd8>
ffffffffc02044c8:	00003617          	auipc	a2,0x3
ffffffffc02044cc:	8e860613          	addi	a2,a2,-1816 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02044d0:	0d600593          	li	a1,214
ffffffffc02044d4:	00004517          	auipc	a0,0x4
ffffffffc02044d8:	d0c50513          	addi	a0,a0,-756 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02044dc:	fa9fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02044e0 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02044e0:	7139                	addi	sp,sp,-64
ffffffffc02044e2:	f822                	sd	s0,48(sp)
ffffffffc02044e4:	f426                	sd	s1,40(sp)
ffffffffc02044e6:	fc06                	sd	ra,56(sp)
ffffffffc02044e8:	f04a                	sd	s2,32(sp)
ffffffffc02044ea:	ec4e                	sd	s3,24(sp)
ffffffffc02044ec:	e852                	sd	s4,16(sp)
ffffffffc02044ee:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02044f0:	c55ff0ef          	jal	ra,ffffffffc0204144 <mm_create>
    assert(mm != NULL);
ffffffffc02044f4:	842a                	mv	s0,a0
ffffffffc02044f6:	03200493          	li	s1,50
ffffffffc02044fa:	e919                	bnez	a0,ffffffffc0204510 <vmm_init+0x30>
ffffffffc02044fc:	a989                	j	ffffffffc020494e <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc02044fe:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204500:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204502:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204506:	14ed                	addi	s1,s1,-5
ffffffffc0204508:	8522                	mv	a0,s0
ffffffffc020450a:	cf3ff0ef          	jal	ra,ffffffffc02041fc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020450e:	c88d                	beqz	s1,ffffffffc0204540 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204510:	03000513          	li	a0,48
ffffffffc0204514:	f42fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204518:	85aa                	mv	a1,a0
ffffffffc020451a:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020451e:	f165                	bnez	a0,ffffffffc02044fe <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204520:	00004697          	auipc	a3,0x4
ffffffffc0204524:	83068693          	addi	a3,a3,-2000 # ffffffffc0207d50 <default_pmm_manager+0x858>
ffffffffc0204528:	00003617          	auipc	a2,0x3
ffffffffc020452c:	88860613          	addi	a2,a2,-1912 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204530:	11300593          	li	a1,275
ffffffffc0204534:	00004517          	auipc	a0,0x4
ffffffffc0204538:	cac50513          	addi	a0,a0,-852 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc020453c:	f49fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204540:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204544:	1f900913          	li	s2,505
ffffffffc0204548:	a819                	j	ffffffffc020455e <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020454a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020454c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020454e:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204552:	0495                	addi	s1,s1,5
ffffffffc0204554:	8522                	mv	a0,s0
ffffffffc0204556:	ca7ff0ef          	jal	ra,ffffffffc02041fc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020455a:	03248a63          	beq	s1,s2,ffffffffc020458e <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020455e:	03000513          	li	a0,48
ffffffffc0204562:	ef4fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204566:	85aa                	mv	a1,a0
ffffffffc0204568:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020456c:	fd79                	bnez	a0,ffffffffc020454a <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020456e:	00003697          	auipc	a3,0x3
ffffffffc0204572:	7e268693          	addi	a3,a3,2018 # ffffffffc0207d50 <default_pmm_manager+0x858>
ffffffffc0204576:	00003617          	auipc	a2,0x3
ffffffffc020457a:	83a60613          	addi	a2,a2,-1990 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020457e:	11900593          	li	a1,281
ffffffffc0204582:	00004517          	auipc	a0,0x4
ffffffffc0204586:	c5e50513          	addi	a0,a0,-930 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc020458a:	efbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020458e:	6418                	ld	a4,8(s0)
ffffffffc0204590:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204592:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204596:	2ee40063          	beq	s0,a4,ffffffffc0204876 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020459a:	fe873603          	ld	a2,-24(a4)
ffffffffc020459e:	ffe78693          	addi	a3,a5,-2
ffffffffc02045a2:	24d61a63          	bne	a2,a3,ffffffffc02047f6 <vmm_init+0x316>
ffffffffc02045a6:	ff073683          	ld	a3,-16(a4)
ffffffffc02045aa:	24f69663          	bne	a3,a5,ffffffffc02047f6 <vmm_init+0x316>
ffffffffc02045ae:	0795                	addi	a5,a5,5
ffffffffc02045b0:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02045b2:	feb792e3          	bne	a5,a1,ffffffffc0204596 <vmm_init+0xb6>
ffffffffc02045b6:	491d                	li	s2,7
ffffffffc02045b8:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045ba:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02045be:	85a6                	mv	a1,s1
ffffffffc02045c0:	8522                	mv	a0,s0
ffffffffc02045c2:	bfdff0ef          	jal	ra,ffffffffc02041be <find_vma>
ffffffffc02045c6:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02045c8:	30050763          	beqz	a0,ffffffffc02048d6 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02045cc:	00148593          	addi	a1,s1,1
ffffffffc02045d0:	8522                	mv	a0,s0
ffffffffc02045d2:	bedff0ef          	jal	ra,ffffffffc02041be <find_vma>
ffffffffc02045d6:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02045d8:	2c050f63          	beqz	a0,ffffffffc02048b6 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02045dc:	85ca                	mv	a1,s2
ffffffffc02045de:	8522                	mv	a0,s0
ffffffffc02045e0:	bdfff0ef          	jal	ra,ffffffffc02041be <find_vma>
        assert(vma3 == NULL);
ffffffffc02045e4:	2a051963          	bnez	a0,ffffffffc0204896 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02045e8:	00348593          	addi	a1,s1,3
ffffffffc02045ec:	8522                	mv	a0,s0
ffffffffc02045ee:	bd1ff0ef          	jal	ra,ffffffffc02041be <find_vma>
        assert(vma4 == NULL);
ffffffffc02045f2:	32051263          	bnez	a0,ffffffffc0204916 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02045f6:	00448593          	addi	a1,s1,4
ffffffffc02045fa:	8522                	mv	a0,s0
ffffffffc02045fc:	bc3ff0ef          	jal	ra,ffffffffc02041be <find_vma>
        assert(vma5 == NULL);
ffffffffc0204600:	2e051b63          	bnez	a0,ffffffffc02048f6 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204604:	008a3783          	ld	a5,8(s4)
ffffffffc0204608:	20979763          	bne	a5,s1,ffffffffc0204816 <vmm_init+0x336>
ffffffffc020460c:	010a3783          	ld	a5,16(s4)
ffffffffc0204610:	21279363          	bne	a5,s2,ffffffffc0204816 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204614:	0089b783          	ld	a5,8(s3)
ffffffffc0204618:	20979f63          	bne	a5,s1,ffffffffc0204836 <vmm_init+0x356>
ffffffffc020461c:	0109b783          	ld	a5,16(s3)
ffffffffc0204620:	21279b63          	bne	a5,s2,ffffffffc0204836 <vmm_init+0x356>
ffffffffc0204624:	0495                	addi	s1,s1,5
ffffffffc0204626:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204628:	f9549be3          	bne	s1,s5,ffffffffc02045be <vmm_init+0xde>
ffffffffc020462c:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020462e:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204630:	85a6                	mv	a1,s1
ffffffffc0204632:	8522                	mv	a0,s0
ffffffffc0204634:	b8bff0ef          	jal	ra,ffffffffc02041be <find_vma>
ffffffffc0204638:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020463c:	c90d                	beqz	a0,ffffffffc020466e <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020463e:	6914                	ld	a3,16(a0)
ffffffffc0204640:	6510                	ld	a2,8(a0)
ffffffffc0204642:	00004517          	auipc	a0,0x4
ffffffffc0204646:	e2650513          	addi	a0,a0,-474 # ffffffffc0208468 <default_pmm_manager+0xf70>
ffffffffc020464a:	b45fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020464e:	00004697          	auipc	a3,0x4
ffffffffc0204652:	e4268693          	addi	a3,a3,-446 # ffffffffc0208490 <default_pmm_manager+0xf98>
ffffffffc0204656:	00002617          	auipc	a2,0x2
ffffffffc020465a:	75a60613          	addi	a2,a2,1882 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020465e:	13b00593          	li	a1,315
ffffffffc0204662:	00004517          	auipc	a0,0x4
ffffffffc0204666:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc020466a:	e1bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020466e:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204670:	fd2490e3          	bne	s1,s2,ffffffffc0204630 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204674:	8522                	mv	a0,s0
ffffffffc0204676:	c55ff0ef          	jal	ra,ffffffffc02042ca <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020467a:	00004517          	auipc	a0,0x4
ffffffffc020467e:	e2e50513          	addi	a0,a0,-466 # ffffffffc02084a8 <default_pmm_manager+0xfb0>
ffffffffc0204682:	b0dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204686:	89bfd0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc020468a:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020468c:	ab9ff0ef          	jal	ra,ffffffffc0204144 <mm_create>
ffffffffc0204690:	000a8797          	auipc	a5,0xa8
ffffffffc0204694:	f0a7b823          	sd	a0,-240(a5) # ffffffffc02ac5a0 <check_mm_struct>
ffffffffc0204698:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020469a:	36050663          	beqz	a0,ffffffffc0204a06 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020469e:	000a8797          	auipc	a5,0xa8
ffffffffc02046a2:	daa78793          	addi	a5,a5,-598 # ffffffffc02ac448 <boot_pgdir>
ffffffffc02046a6:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02046aa:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046ae:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02046b2:	2c079e63          	bnez	a5,ffffffffc020498e <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02046b6:	03000513          	li	a0,48
ffffffffc02046ba:	d9cfd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc02046be:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02046c0:	18050b63          	beqz	a0,ffffffffc0204856 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02046c4:	002007b7          	lui	a5,0x200
ffffffffc02046c8:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc02046ca:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02046cc:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02046ce:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc02046d0:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc02046d2:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc02046d6:	b27ff0ef          	jal	ra,ffffffffc02041fc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02046da:	10000593          	li	a1,256
ffffffffc02046de:	8526                	mv	a0,s1
ffffffffc02046e0:	adfff0ef          	jal	ra,ffffffffc02041be <find_vma>
ffffffffc02046e4:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02046e8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02046ec:	2ca41163          	bne	s0,a0,ffffffffc02049ae <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc02046f0:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
        sum += i;
ffffffffc02046f4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02046f6:	fee79de3          	bne	a5,a4,ffffffffc02046f0 <vmm_init+0x210>
        sum += i;
ffffffffc02046fa:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02046fc:	10000793          	li	a5,256
        sum += i;
ffffffffc0204700:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x821a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204704:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204708:	0007c683          	lbu	a3,0(a5)
ffffffffc020470c:	0785                	addi	a5,a5,1
ffffffffc020470e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204710:	fec79ce3          	bne	a5,a2,ffffffffc0204708 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204714:	2c071963          	bnez	a4,ffffffffc02049e6 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204718:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020471c:	000a8a97          	auipc	s5,0xa8
ffffffffc0204720:	d34a8a93          	addi	s5,s5,-716 # ffffffffc02ac450 <npage>
ffffffffc0204724:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204728:	078a                	slli	a5,a5,0x2
ffffffffc020472a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020472c:	20e7f563          	bleu	a4,a5,ffffffffc0204936 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204730:	00004697          	auipc	a3,0x4
ffffffffc0204734:	7b868693          	addi	a3,a3,1976 # ffffffffc0208ee8 <nbase>
ffffffffc0204738:	0006ba03          	ld	s4,0(a3)
ffffffffc020473c:	414786b3          	sub	a3,a5,s4
ffffffffc0204740:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204742:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204744:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0204746:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204748:	83b1                	srli	a5,a5,0xc
ffffffffc020474a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020474c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020474e:	28e7f063          	bleu	a4,a5,ffffffffc02049ce <vmm_init+0x4ee>
ffffffffc0204752:	000a8797          	auipc	a5,0xa8
ffffffffc0204756:	d5e78793          	addi	a5,a5,-674 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc020475a:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020475c:	4581                	li	a1,0
ffffffffc020475e:	854a                	mv	a0,s2
ffffffffc0204760:	9436                	add	s0,s0,a3
ffffffffc0204762:	da1fd0ef          	jal	ra,ffffffffc0202502 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204766:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204768:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020476c:	078a                	slli	a5,a5,0x2
ffffffffc020476e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204770:	1ce7f363          	bleu	a4,a5,ffffffffc0204936 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204774:	000a8417          	auipc	s0,0xa8
ffffffffc0204778:	d4c40413          	addi	s0,s0,-692 # ffffffffc02ac4c0 <pages>
ffffffffc020477c:	6008                	ld	a0,0(s0)
ffffffffc020477e:	414787b3          	sub	a5,a5,s4
ffffffffc0204782:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204784:	953e                	add	a0,a0,a5
ffffffffc0204786:	4585                	li	a1,1
ffffffffc0204788:	f52fd0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020478c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204790:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204794:	078a                	slli	a5,a5,0x2
ffffffffc0204796:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204798:	18e7ff63          	bleu	a4,a5,ffffffffc0204936 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020479c:	6008                	ld	a0,0(s0)
ffffffffc020479e:	414787b3          	sub	a5,a5,s4
ffffffffc02047a2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02047a4:	4585                	li	a1,1
ffffffffc02047a6:	953e                	add	a0,a0,a5
ffffffffc02047a8:	f32fd0ef          	jal	ra,ffffffffc0201eda <free_pages>
    pgdir[0] = 0;
ffffffffc02047ac:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc02047b0:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02047b4:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02047b8:	8526                	mv	a0,s1
ffffffffc02047ba:	b11ff0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02047be:	000a8797          	auipc	a5,0xa8
ffffffffc02047c2:	de07b123          	sd	zero,-542(a5) # ffffffffc02ac5a0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02047c6:	f5afd0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc02047ca:	1aa99263          	bne	s3,a0,ffffffffc020496e <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02047ce:	00004517          	auipc	a0,0x4
ffffffffc02047d2:	d6a50513          	addi	a0,a0,-662 # ffffffffc0208538 <default_pmm_manager+0x1040>
ffffffffc02047d6:	9b9fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02047da:	7442                	ld	s0,48(sp)
ffffffffc02047dc:	70e2                	ld	ra,56(sp)
ffffffffc02047de:	74a2                	ld	s1,40(sp)
ffffffffc02047e0:	7902                	ld	s2,32(sp)
ffffffffc02047e2:	69e2                	ld	s3,24(sp)
ffffffffc02047e4:	6a42                	ld	s4,16(sp)
ffffffffc02047e6:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02047e8:	00004517          	auipc	a0,0x4
ffffffffc02047ec:	d7050513          	addi	a0,a0,-656 # ffffffffc0208558 <default_pmm_manager+0x1060>
}
ffffffffc02047f0:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02047f2:	99dfb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02047f6:	00004697          	auipc	a3,0x4
ffffffffc02047fa:	b8a68693          	addi	a3,a3,-1142 # ffffffffc0208380 <default_pmm_manager+0xe88>
ffffffffc02047fe:	00002617          	auipc	a2,0x2
ffffffffc0204802:	5b260613          	addi	a2,a2,1458 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204806:	12200593          	li	a1,290
ffffffffc020480a:	00004517          	auipc	a0,0x4
ffffffffc020480e:	9d650513          	addi	a0,a0,-1578 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204812:	c73fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204816:	00004697          	auipc	a3,0x4
ffffffffc020481a:	bf268693          	addi	a3,a3,-1038 # ffffffffc0208408 <default_pmm_manager+0xf10>
ffffffffc020481e:	00002617          	auipc	a2,0x2
ffffffffc0204822:	59260613          	addi	a2,a2,1426 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204826:	13200593          	li	a1,306
ffffffffc020482a:	00004517          	auipc	a0,0x4
ffffffffc020482e:	9b650513          	addi	a0,a0,-1610 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204832:	c53fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204836:	00004697          	auipc	a3,0x4
ffffffffc020483a:	c0268693          	addi	a3,a3,-1022 # ffffffffc0208438 <default_pmm_manager+0xf40>
ffffffffc020483e:	00002617          	auipc	a2,0x2
ffffffffc0204842:	57260613          	addi	a2,a2,1394 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204846:	13300593          	li	a1,307
ffffffffc020484a:	00004517          	auipc	a0,0x4
ffffffffc020484e:	99650513          	addi	a0,a0,-1642 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204852:	c33fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc0204856:	00003697          	auipc	a3,0x3
ffffffffc020485a:	4fa68693          	addi	a3,a3,1274 # ffffffffc0207d50 <default_pmm_manager+0x858>
ffffffffc020485e:	00002617          	auipc	a2,0x2
ffffffffc0204862:	55260613          	addi	a2,a2,1362 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204866:	15200593          	li	a1,338
ffffffffc020486a:	00004517          	auipc	a0,0x4
ffffffffc020486e:	97650513          	addi	a0,a0,-1674 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204872:	c13fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204876:	00004697          	auipc	a3,0x4
ffffffffc020487a:	af268693          	addi	a3,a3,-1294 # ffffffffc0208368 <default_pmm_manager+0xe70>
ffffffffc020487e:	00002617          	auipc	a2,0x2
ffffffffc0204882:	53260613          	addi	a2,a2,1330 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204886:	12000593          	li	a1,288
ffffffffc020488a:	00004517          	auipc	a0,0x4
ffffffffc020488e:	95650513          	addi	a0,a0,-1706 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204892:	bf3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc0204896:	00004697          	auipc	a3,0x4
ffffffffc020489a:	b4268693          	addi	a3,a3,-1214 # ffffffffc02083d8 <default_pmm_manager+0xee0>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	51260613          	addi	a2,a2,1298 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02048a6:	12c00593          	li	a1,300
ffffffffc02048aa:	00004517          	auipc	a0,0x4
ffffffffc02048ae:	93650513          	addi	a0,a0,-1738 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02048b2:	bd3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc02048b6:	00004697          	auipc	a3,0x4
ffffffffc02048ba:	b1268693          	addi	a3,a3,-1262 # ffffffffc02083c8 <default_pmm_manager+0xed0>
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	4f260613          	addi	a2,a2,1266 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02048c6:	12a00593          	li	a1,298
ffffffffc02048ca:	00004517          	auipc	a0,0x4
ffffffffc02048ce:	91650513          	addi	a0,a0,-1770 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02048d2:	bb3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc02048d6:	00004697          	auipc	a3,0x4
ffffffffc02048da:	ae268693          	addi	a3,a3,-1310 # ffffffffc02083b8 <default_pmm_manager+0xec0>
ffffffffc02048de:	00002617          	auipc	a2,0x2
ffffffffc02048e2:	4d260613          	addi	a2,a2,1234 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02048e6:	12800593          	li	a1,296
ffffffffc02048ea:	00004517          	auipc	a0,0x4
ffffffffc02048ee:	8f650513          	addi	a0,a0,-1802 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02048f2:	b93fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc02048f6:	00004697          	auipc	a3,0x4
ffffffffc02048fa:	b0268693          	addi	a3,a3,-1278 # ffffffffc02083f8 <default_pmm_manager+0xf00>
ffffffffc02048fe:	00002617          	auipc	a2,0x2
ffffffffc0204902:	4b260613          	addi	a2,a2,1202 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204906:	13000593          	li	a1,304
ffffffffc020490a:	00004517          	auipc	a0,0x4
ffffffffc020490e:	8d650513          	addi	a0,a0,-1834 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204912:	b73fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc0204916:	00004697          	auipc	a3,0x4
ffffffffc020491a:	ad268693          	addi	a3,a3,-1326 # ffffffffc02083e8 <default_pmm_manager+0xef0>
ffffffffc020491e:	00002617          	auipc	a2,0x2
ffffffffc0204922:	49260613          	addi	a2,a2,1170 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204926:	12e00593          	li	a1,302
ffffffffc020492a:	00004517          	auipc	a0,0x4
ffffffffc020492e:	8b650513          	addi	a0,a0,-1866 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204932:	b53fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204936:	00003617          	auipc	a2,0x3
ffffffffc020493a:	c7260613          	addi	a2,a2,-910 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc020493e:	06200593          	li	a1,98
ffffffffc0204942:	00003517          	auipc	a0,0x3
ffffffffc0204946:	c2e50513          	addi	a0,a0,-978 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc020494a:	b3bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc020494e:	00003697          	auipc	a3,0x3
ffffffffc0204952:	3ca68693          	addi	a3,a3,970 # ffffffffc0207d18 <default_pmm_manager+0x820>
ffffffffc0204956:	00002617          	auipc	a2,0x2
ffffffffc020495a:	45a60613          	addi	a2,a2,1114 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020495e:	10c00593          	li	a1,268
ffffffffc0204962:	00004517          	auipc	a0,0x4
ffffffffc0204966:	87e50513          	addi	a0,a0,-1922 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc020496a:	b1bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020496e:	00004697          	auipc	a3,0x4
ffffffffc0204972:	ba268693          	addi	a3,a3,-1118 # ffffffffc0208510 <default_pmm_manager+0x1018>
ffffffffc0204976:	00002617          	auipc	a2,0x2
ffffffffc020497a:	43a60613          	addi	a2,a2,1082 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020497e:	17000593          	li	a1,368
ffffffffc0204982:	00004517          	auipc	a0,0x4
ffffffffc0204986:	85e50513          	addi	a0,a0,-1954 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc020498a:	afbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020498e:	00003697          	auipc	a3,0x3
ffffffffc0204992:	3b268693          	addi	a3,a3,946 # ffffffffc0207d40 <default_pmm_manager+0x848>
ffffffffc0204996:	00002617          	auipc	a2,0x2
ffffffffc020499a:	41a60613          	addi	a2,a2,1050 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020499e:	14f00593          	li	a1,335
ffffffffc02049a2:	00004517          	auipc	a0,0x4
ffffffffc02049a6:	83e50513          	addi	a0,a0,-1986 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02049aa:	adbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02049ae:	00004697          	auipc	a3,0x4
ffffffffc02049b2:	b3268693          	addi	a3,a3,-1230 # ffffffffc02084e0 <default_pmm_manager+0xfe8>
ffffffffc02049b6:	00002617          	auipc	a2,0x2
ffffffffc02049ba:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02049be:	15700593          	li	a1,343
ffffffffc02049c2:	00004517          	auipc	a0,0x4
ffffffffc02049c6:	81e50513          	addi	a0,a0,-2018 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc02049ca:	abbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02049ce:	00003617          	auipc	a2,0x3
ffffffffc02049d2:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc02049d6:	06900593          	li	a1,105
ffffffffc02049da:	00003517          	auipc	a0,0x3
ffffffffc02049de:	b9650513          	addi	a0,a0,-1130 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc02049e2:	aa3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc02049e6:	00004697          	auipc	a3,0x4
ffffffffc02049ea:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0208500 <default_pmm_manager+0x1008>
ffffffffc02049ee:	00002617          	auipc	a2,0x2
ffffffffc02049f2:	3c260613          	addi	a2,a2,962 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02049f6:	16300593          	li	a1,355
ffffffffc02049fa:	00003517          	auipc	a0,0x3
ffffffffc02049fe:	7e650513          	addi	a0,a0,2022 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204a02:	a83fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204a06:	00004697          	auipc	a3,0x4
ffffffffc0204a0a:	ac268693          	addi	a3,a3,-1342 # ffffffffc02084c8 <default_pmm_manager+0xfd0>
ffffffffc0204a0e:	00002617          	auipc	a2,0x2
ffffffffc0204a12:	3a260613          	addi	a2,a2,930 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0204a16:	14b00593          	li	a1,331
ffffffffc0204a1a:	00003517          	auipc	a0,0x3
ffffffffc0204a1e:	7c650513          	addi	a0,a0,1990 # ffffffffc02081e0 <default_pmm_manager+0xce8>
ffffffffc0204a22:	a63fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204a26 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a26:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a28:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a2a:	e0a2                	sd	s0,64(sp)
ffffffffc0204a2c:	fc26                	sd	s1,56(sp)
ffffffffc0204a2e:	e486                	sd	ra,72(sp)
ffffffffc0204a30:	f84a                	sd	s2,48(sp)
ffffffffc0204a32:	f44e                	sd	s3,40(sp)
ffffffffc0204a34:	f052                	sd	s4,32(sp)
ffffffffc0204a36:	ec56                	sd	s5,24(sp)
ffffffffc0204a38:	e85a                	sd	s6,16(sp)
ffffffffc0204a3a:	8432                	mv	s0,a2
ffffffffc0204a3c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a3e:	f80ff0ef          	jal	ra,ffffffffc02041be <find_vma>

    pgfault_num++;
ffffffffc0204a42:	000a8797          	auipc	a5,0xa8
ffffffffc0204a46:	a2278793          	addi	a5,a5,-1502 # ffffffffc02ac464 <pgfault_num>
ffffffffc0204a4a:	439c                	lw	a5,0(a5)
ffffffffc0204a4c:	2785                	addiw	a5,a5,1
ffffffffc0204a4e:	000a8717          	auipc	a4,0xa8
ffffffffc0204a52:	a0f72b23          	sw	a5,-1514(a4) # ffffffffc02ac464 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204a56:	14050e63          	beqz	a0,ffffffffc0204bb2 <do_pgfault+0x18c>
ffffffffc0204a5a:	651c                	ld	a5,8(a0)
ffffffffc0204a5c:	14f46b63          	bltu	s0,a5,ffffffffc0204bb2 <do_pgfault+0x18c>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a60:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204a62:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a64:	8b89                	andi	a5,a5,2
ffffffffc0204a66:	ebad                	bnez	a5,ffffffffc0204ad8 <do_pgfault+0xb2>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a68:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a6a:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a6c:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a6e:	85a2                	mv	a1,s0
ffffffffc0204a70:	4605                	li	a2,1
ffffffffc0204a72:	ceefd0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0204a76:	892a                	mv	s2,a0
ffffffffc0204a78:	14050f63          	beqz	a0,ffffffffc0204bd6 <do_pgfault+0x1b0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204a7c:	6110                	ld	a2,0(a0)
ffffffffc0204a7e:	10060463          	beqz	a2,ffffffffc0204b86 <do_pgfault+0x160>
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */

        if (*ptep & PTE_V) {
ffffffffc0204a82:	00167793          	andi	a5,a2,1
ffffffffc0204a86:	ebb9                	bnez	a5,ffffffffc0204adc <do_pgfault+0xb6>
                //如果该物理页面被一个进程引用，则说明是共享页面的最后一页
                //根据所处的vma恢复其权限perm
                page_insert(mm->pgdir, page, addr, perm);
            }
        } else {
            if (swap_init_ok) {
ffffffffc0204a88:	000a8797          	auipc	a5,0xa8
ffffffffc0204a8c:	9d878793          	addi	a5,a5,-1576 # ffffffffc02ac460 <swap_init_ok>
ffffffffc0204a90:	439c                	lw	a5,0(a5)
ffffffffc0204a92:	2781                	sext.w	a5,a5
ffffffffc0204a94:	12078863          	beqz	a5,ffffffffc0204bc4 <do_pgfault+0x19e>
                //addr AND page, setup the
                //map of phy addr <--->
                //logical addr
                //(3) make the page swappable.

                swap_in(mm, addr, &page);
ffffffffc0204a98:	85a2                	mv	a1,s0
ffffffffc0204a9a:	0030                	addi	a2,sp,8
ffffffffc0204a9c:	8526                	mv	a0,s1
                struct Page *page = NULL;
ffffffffc0204a9e:	e402                	sd	zero,8(sp)
                swap_in(mm, addr, &page);
ffffffffc0204aa0:	a1eff0ef          	jal	ra,ffffffffc0203cbe <swap_in>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204aa4:	65a2                	ld	a1,8(sp)
ffffffffc0204aa6:	6c88                	ld	a0,24(s1)
ffffffffc0204aa8:	86ce                	mv	a3,s3
ffffffffc0204aaa:	8622                	mv	a2,s0
ffffffffc0204aac:	acbfd0ef          	jal	ra,ffffffffc0202576 <page_insert>
                swap_map_swappable(mm, addr, page, 1);
ffffffffc0204ab0:	6622                	ld	a2,8(sp)
ffffffffc0204ab2:	4685                	li	a3,1
ffffffffc0204ab4:	85a2                	mv	a1,s0
ffffffffc0204ab6:	8526                	mv	a0,s1
ffffffffc0204ab8:	8e2ff0ef          	jal	ra,ffffffffc0203b9a <swap_map_swappable>

                page->pra_vaddr = addr;
ffffffffc0204abc:	6722                	ld	a4,8(sp)
                goto failed;
            }
        }

   }
   ret = 0;
ffffffffc0204abe:	4781                	li	a5,0
                page->pra_vaddr = addr;
ffffffffc0204ac0:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0204ac2:	60a6                	ld	ra,72(sp)
ffffffffc0204ac4:	6406                	ld	s0,64(sp)
ffffffffc0204ac6:	74e2                	ld	s1,56(sp)
ffffffffc0204ac8:	7942                	ld	s2,48(sp)
ffffffffc0204aca:	79a2                	ld	s3,40(sp)
ffffffffc0204acc:	7a02                	ld	s4,32(sp)
ffffffffc0204ace:	6ae2                	ld	s5,24(sp)
ffffffffc0204ad0:	6b42                	ld	s6,16(sp)
ffffffffc0204ad2:	853e                	mv	a0,a5
ffffffffc0204ad4:	6161                	addi	sp,sp,80
ffffffffc0204ad6:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204ad8:	49dd                	li	s3,23
ffffffffc0204ada:	b779                	j	ffffffffc0204a68 <do_pgfault+0x42>
            cprintf("\n\nCOW: ptep 0x%x, pte 0x%x\n",ptep, *ptep);
ffffffffc0204adc:	85aa                	mv	a1,a0
ffffffffc0204ade:	00003517          	auipc	a0,0x3
ffffffffc0204ae2:	78a50513          	addi	a0,a0,1930 # ffffffffc0208268 <default_pmm_manager+0xd70>
ffffffffc0204ae6:	ea8fb0ef          	jal	ra,ffffffffc020018e <cprintf>
            struct Page* page = pte2page(*ptep);//获取对应物理页
ffffffffc0204aea:	00093783          	ld	a5,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0204aee:	0017f713          	andi	a4,a5,1
ffffffffc0204af2:	10070763          	beqz	a4,ffffffffc0204c00 <do_pgfault+0x1da>
    if (PPN(pa) >= npage) {
ffffffffc0204af6:	000a8a97          	auipc	s5,0xa8
ffffffffc0204afa:	95aa8a93          	addi	s5,s5,-1702 # ffffffffc02ac450 <npage>
ffffffffc0204afe:	000ab703          	ld	a4,0(s5)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204b02:	078a                	slli	a5,a5,0x2
ffffffffc0204b04:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204b06:	10e7f963          	bleu	a4,a5,ffffffffc0204c18 <do_pgfault+0x1f2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204b0a:	00004717          	auipc	a4,0x4
ffffffffc0204b0e:	3de70713          	addi	a4,a4,990 # ffffffffc0208ee8 <nbase>
ffffffffc0204b12:	00073a03          	ld	s4,0(a4)
ffffffffc0204b16:	000a8b17          	auipc	s6,0xa8
ffffffffc0204b1a:	9aab0b13          	addi	s6,s6,-1622 # ffffffffc02ac4c0 <pages>
ffffffffc0204b1e:	000b3903          	ld	s2,0(s6)
ffffffffc0204b22:	414787b3          	sub	a5,a5,s4
ffffffffc0204b26:	079a                	slli	a5,a5,0x6
ffffffffc0204b28:	993e                	add	s2,s2,a5
            if(page_ref(page) > 1)
ffffffffc0204b2a:	00092703          	lw	a4,0(s2)
ffffffffc0204b2e:	4785                	li	a5,1
ffffffffc0204b30:	6c88                	ld	a0,24(s1)
ffffffffc0204b32:	06e7d963          	ble	a4,a5,ffffffffc0204ba4 <do_pgfault+0x17e>
                struct Page* new_page = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0204b36:	864e                	mv	a2,s3
ffffffffc0204b38:	85a2                	mv	a1,s0
ffffffffc0204b3a:	83dfe0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0204b3e:	000b3783          	ld	a5,0(s6)
    return KADDR(page2pa(page));
ffffffffc0204b42:	577d                	li	a4,-1
ffffffffc0204b44:	000ab603          	ld	a2,0(s5)
    return page - pages + nbase;
ffffffffc0204b48:	40f906b3          	sub	a3,s2,a5
ffffffffc0204b4c:	8699                	srai	a3,a3,0x6
ffffffffc0204b4e:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204b50:	8331                	srli	a4,a4,0xc
ffffffffc0204b52:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b56:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b58:	08c5f863          	bleu	a2,a1,ffffffffc0204be8 <do_pgfault+0x1c2>
    return page - pages + nbase;
ffffffffc0204b5c:	40f507b3          	sub	a5,a0,a5
    return KADDR(page2pa(page));
ffffffffc0204b60:	000a8597          	auipc	a1,0xa8
ffffffffc0204b64:	95058593          	addi	a1,a1,-1712 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0204b68:	6188                	ld	a0,0(a1)
    return page - pages + nbase;
ffffffffc0204b6a:	8799                	srai	a5,a5,0x6
ffffffffc0204b6c:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0204b6e:	8f7d                	and	a4,a4,a5
ffffffffc0204b70:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b74:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204b76:	06c77863          	bleu	a2,a4,ffffffffc0204be6 <do_pgfault+0x1c0>
                memcpy(dst_kva, src_kva, PGSIZE);//复制
ffffffffc0204b7a:	953e                	add	a0,a0,a5
ffffffffc0204b7c:	6605                	lui	a2,0x1
ffffffffc0204b7e:	425010ef          	jal	ra,ffffffffc02067a2 <memcpy>
   ret = 0;
ffffffffc0204b82:	4781                	li	a5,0
ffffffffc0204b84:	bf3d                	j	ffffffffc0204ac2 <do_pgfault+0x9c>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b86:	6c88                	ld	a0,24(s1)
ffffffffc0204b88:	864e                	mv	a2,s3
ffffffffc0204b8a:	85a2                	mv	a1,s0
ffffffffc0204b8c:	feafe0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204b90:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b92:	f905                	bnez	a0,ffffffffc0204ac2 <do_pgfault+0x9c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204b94:	00003517          	auipc	a0,0x3
ffffffffc0204b98:	6ac50513          	addi	a0,a0,1708 # ffffffffc0208240 <default_pmm_manager+0xd48>
ffffffffc0204b9c:	df2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204ba0:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204ba2:	b705                	j	ffffffffc0204ac2 <do_pgfault+0x9c>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204ba4:	86ce                	mv	a3,s3
ffffffffc0204ba6:	8622                	mv	a2,s0
ffffffffc0204ba8:	85ca                	mv	a1,s2
ffffffffc0204baa:	9cdfd0ef          	jal	ra,ffffffffc0202576 <page_insert>
   ret = 0;
ffffffffc0204bae:	4781                	li	a5,0
ffffffffc0204bb0:	bf09                	j	ffffffffc0204ac2 <do_pgfault+0x9c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204bb2:	85a2                	mv	a1,s0
ffffffffc0204bb4:	00003517          	auipc	a0,0x3
ffffffffc0204bb8:	63c50513          	addi	a0,a0,1596 # ffffffffc02081f0 <default_pmm_manager+0xcf8>
ffffffffc0204bbc:	dd2fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204bc0:	57f5                	li	a5,-3
        goto failed;
ffffffffc0204bc2:	b701                	j	ffffffffc0204ac2 <do_pgfault+0x9c>
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204bc4:	85b2                	mv	a1,a2
ffffffffc0204bc6:	00003517          	auipc	a0,0x3
ffffffffc0204bca:	6c250513          	addi	a0,a0,1730 # ffffffffc0208288 <default_pmm_manager+0xd90>
ffffffffc0204bce:	dc0fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204bd2:	57f1                	li	a5,-4
                goto failed;
ffffffffc0204bd4:	b5fd                	j	ffffffffc0204ac2 <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204bd6:	00003517          	auipc	a0,0x3
ffffffffc0204bda:	64a50513          	addi	a0,a0,1610 # ffffffffc0208220 <default_pmm_manager+0xd28>
ffffffffc0204bde:	db0fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204be2:	57f1                	li	a5,-4
        goto failed;
ffffffffc0204be4:	bdf9                	j	ffffffffc0204ac2 <do_pgfault+0x9c>
ffffffffc0204be6:	86be                	mv	a3,a5
ffffffffc0204be8:	00003617          	auipc	a2,0x3
ffffffffc0204bec:	96060613          	addi	a2,a2,-1696 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0204bf0:	06900593          	li	a1,105
ffffffffc0204bf4:	00003517          	auipc	a0,0x3
ffffffffc0204bf8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204bfc:	889fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204c00:	00003617          	auipc	a2,0x3
ffffffffc0204c04:	c3060613          	addi	a2,a2,-976 # ffffffffc0207830 <default_pmm_manager+0x338>
ffffffffc0204c08:	07400593          	li	a1,116
ffffffffc0204c0c:	00003517          	auipc	a0,0x3
ffffffffc0204c10:	96450513          	addi	a0,a0,-1692 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204c14:	871fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c18:	00003617          	auipc	a2,0x3
ffffffffc0204c1c:	99060613          	addi	a2,a2,-1648 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc0204c20:	06200593          	li	a1,98
ffffffffc0204c24:	00003517          	auipc	a0,0x3
ffffffffc0204c28:	94c50513          	addi	a0,a0,-1716 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204c2c:	859fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c30 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204c30:	7179                	addi	sp,sp,-48
ffffffffc0204c32:	f022                	sd	s0,32(sp)
ffffffffc0204c34:	f406                	sd	ra,40(sp)
ffffffffc0204c36:	ec26                	sd	s1,24(sp)
ffffffffc0204c38:	e84a                	sd	s2,16(sp)
ffffffffc0204c3a:	e44e                	sd	s3,8(sp)
ffffffffc0204c3c:	e052                	sd	s4,0(sp)
ffffffffc0204c3e:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204c40:	c135                	beqz	a0,ffffffffc0204ca4 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204c42:	002007b7          	lui	a5,0x200
ffffffffc0204c46:	04f5e663          	bltu	a1,a5,ffffffffc0204c92 <user_mem_check+0x62>
ffffffffc0204c4a:	00c584b3          	add	s1,a1,a2
ffffffffc0204c4e:	0495f263          	bleu	s1,a1,ffffffffc0204c92 <user_mem_check+0x62>
ffffffffc0204c52:	4785                	li	a5,1
ffffffffc0204c54:	07fe                	slli	a5,a5,0x1f
ffffffffc0204c56:	0297ee63          	bltu	a5,s1,ffffffffc0204c92 <user_mem_check+0x62>
ffffffffc0204c5a:	892a                	mv	s2,a0
ffffffffc0204c5c:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c5e:	6a05                	lui	s4,0x1
ffffffffc0204c60:	a821                	j	ffffffffc0204c78 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c62:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c66:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204c68:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c6a:	c685                	beqz	a3,ffffffffc0204c92 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204c6c:	c399                	beqz	a5,ffffffffc0204c72 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c6e:	02e46263          	bltu	s0,a4,ffffffffc0204c92 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204c72:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204c74:	04947663          	bleu	s1,s0,ffffffffc0204cc0 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204c78:	85a2                	mv	a1,s0
ffffffffc0204c7a:	854a                	mv	a0,s2
ffffffffc0204c7c:	d42ff0ef          	jal	ra,ffffffffc02041be <find_vma>
ffffffffc0204c80:	c909                	beqz	a0,ffffffffc0204c92 <user_mem_check+0x62>
ffffffffc0204c82:	6518                	ld	a4,8(a0)
ffffffffc0204c84:	00e46763          	bltu	s0,a4,ffffffffc0204c92 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c88:	4d1c                	lw	a5,24(a0)
ffffffffc0204c8a:	fc099ce3          	bnez	s3,ffffffffc0204c62 <user_mem_check+0x32>
ffffffffc0204c8e:	8b85                	andi	a5,a5,1
ffffffffc0204c90:	f3ed                	bnez	a5,ffffffffc0204c72 <user_mem_check+0x42>
            return 0;
ffffffffc0204c92:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204c94:	70a2                	ld	ra,40(sp)
ffffffffc0204c96:	7402                	ld	s0,32(sp)
ffffffffc0204c98:	64e2                	ld	s1,24(sp)
ffffffffc0204c9a:	6942                	ld	s2,16(sp)
ffffffffc0204c9c:	69a2                	ld	s3,8(sp)
ffffffffc0204c9e:	6a02                	ld	s4,0(sp)
ffffffffc0204ca0:	6145                	addi	sp,sp,48
ffffffffc0204ca2:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204ca4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204ca8:	4501                	li	a0,0
ffffffffc0204caa:	fef5e5e3          	bltu	a1,a5,ffffffffc0204c94 <user_mem_check+0x64>
ffffffffc0204cae:	962e                	add	a2,a2,a1
ffffffffc0204cb0:	fec5f2e3          	bleu	a2,a1,ffffffffc0204c94 <user_mem_check+0x64>
ffffffffc0204cb4:	c8000537          	lui	a0,0xc8000
ffffffffc0204cb8:	0505                	addi	a0,a0,1
ffffffffc0204cba:	00a63533          	sltu	a0,a2,a0
ffffffffc0204cbe:	bfd9                	j	ffffffffc0204c94 <user_mem_check+0x64>
        return 1;
ffffffffc0204cc0:	4505                	li	a0,1
ffffffffc0204cc2:	bfc9                	j	ffffffffc0204c94 <user_mem_check+0x64>

ffffffffc0204cc4 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204cc4:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204cc6:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204cc8:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204cca:	935fb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204cce:	cd01                	beqz	a0,ffffffffc0204ce6 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204cd0:	4505                	li	a0,1
ffffffffc0204cd2:	933fb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204cd6:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204cd8:	810d                	srli	a0,a0,0x3
ffffffffc0204cda:	000a8797          	auipc	a5,0xa8
ffffffffc0204cde:	86a7bb23          	sd	a0,-1930(a5) # ffffffffc02ac550 <max_swap_offset>
}
ffffffffc0204ce2:	0141                	addi	sp,sp,16
ffffffffc0204ce4:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204ce6:	00004617          	auipc	a2,0x4
ffffffffc0204cea:	88a60613          	addi	a2,a2,-1910 # ffffffffc0208570 <default_pmm_manager+0x1078>
ffffffffc0204cee:	45b5                	li	a1,13
ffffffffc0204cf0:	00004517          	auipc	a0,0x4
ffffffffc0204cf4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0208590 <default_pmm_manager+0x1098>
ffffffffc0204cf8:	f8cfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204cfc <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204cfc:	1141                	addi	sp,sp,-16
ffffffffc0204cfe:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d00:	00855793          	srli	a5,a0,0x8
ffffffffc0204d04:	cfb9                	beqz	a5,ffffffffc0204d62 <swapfs_read+0x66>
ffffffffc0204d06:	000a8717          	auipc	a4,0xa8
ffffffffc0204d0a:	84a70713          	addi	a4,a4,-1974 # ffffffffc02ac550 <max_swap_offset>
ffffffffc0204d0e:	6318                	ld	a4,0(a4)
ffffffffc0204d10:	04e7f963          	bleu	a4,a5,ffffffffc0204d62 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204d14:	000a7717          	auipc	a4,0xa7
ffffffffc0204d18:	7ac70713          	addi	a4,a4,1964 # ffffffffc02ac4c0 <pages>
ffffffffc0204d1c:	6310                	ld	a2,0(a4)
ffffffffc0204d1e:	00004717          	auipc	a4,0x4
ffffffffc0204d22:	1ca70713          	addi	a4,a4,458 # ffffffffc0208ee8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204d26:	000a7697          	auipc	a3,0xa7
ffffffffc0204d2a:	72a68693          	addi	a3,a3,1834 # ffffffffc02ac450 <npage>
    return page - pages + nbase;
ffffffffc0204d2e:	40c58633          	sub	a2,a1,a2
ffffffffc0204d32:	630c                	ld	a1,0(a4)
ffffffffc0204d34:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204d36:	577d                	li	a4,-1
ffffffffc0204d38:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204d3a:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204d3c:	8331                	srli	a4,a4,0xc
ffffffffc0204d3e:	8f71                	and	a4,a4,a2
ffffffffc0204d40:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d44:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d46:	02d77a63          	bleu	a3,a4,ffffffffc0204d7a <swapfs_read+0x7e>
ffffffffc0204d4a:	000a7797          	auipc	a5,0xa7
ffffffffc0204d4e:	76678793          	addi	a5,a5,1894 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0204d52:	639c                	ld	a5,0(a5)
}
ffffffffc0204d54:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d56:	46a1                	li	a3,8
ffffffffc0204d58:	963e                	add	a2,a2,a5
ffffffffc0204d5a:	4505                	li	a0,1
}
ffffffffc0204d5c:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d5e:	8adfb06f          	j	ffffffffc020060a <ide_read_secs>
ffffffffc0204d62:	86aa                	mv	a3,a0
ffffffffc0204d64:	00004617          	auipc	a2,0x4
ffffffffc0204d68:	84460613          	addi	a2,a2,-1980 # ffffffffc02085a8 <default_pmm_manager+0x10b0>
ffffffffc0204d6c:	45d1                	li	a1,20
ffffffffc0204d6e:	00004517          	auipc	a0,0x4
ffffffffc0204d72:	82250513          	addi	a0,a0,-2014 # ffffffffc0208590 <default_pmm_manager+0x1098>
ffffffffc0204d76:	f0efb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204d7a:	86b2                	mv	a3,a2
ffffffffc0204d7c:	06900593          	li	a1,105
ffffffffc0204d80:	00002617          	auipc	a2,0x2
ffffffffc0204d84:	7c860613          	addi	a2,a2,1992 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0204d88:	00002517          	auipc	a0,0x2
ffffffffc0204d8c:	7e850513          	addi	a0,a0,2024 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204d90:	ef4fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204d94 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204d94:	1141                	addi	sp,sp,-16
ffffffffc0204d96:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d98:	00855793          	srli	a5,a0,0x8
ffffffffc0204d9c:	cfb9                	beqz	a5,ffffffffc0204dfa <swapfs_write+0x66>
ffffffffc0204d9e:	000a7717          	auipc	a4,0xa7
ffffffffc0204da2:	7b270713          	addi	a4,a4,1970 # ffffffffc02ac550 <max_swap_offset>
ffffffffc0204da6:	6318                	ld	a4,0(a4)
ffffffffc0204da8:	04e7f963          	bleu	a4,a5,ffffffffc0204dfa <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204dac:	000a7717          	auipc	a4,0xa7
ffffffffc0204db0:	71470713          	addi	a4,a4,1812 # ffffffffc02ac4c0 <pages>
ffffffffc0204db4:	6310                	ld	a2,0(a4)
ffffffffc0204db6:	00004717          	auipc	a4,0x4
ffffffffc0204dba:	13270713          	addi	a4,a4,306 # ffffffffc0208ee8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204dbe:	000a7697          	auipc	a3,0xa7
ffffffffc0204dc2:	69268693          	addi	a3,a3,1682 # ffffffffc02ac450 <npage>
    return page - pages + nbase;
ffffffffc0204dc6:	40c58633          	sub	a2,a1,a2
ffffffffc0204dca:	630c                	ld	a1,0(a4)
ffffffffc0204dcc:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204dce:	577d                	li	a4,-1
ffffffffc0204dd0:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204dd2:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204dd4:	8331                	srli	a4,a4,0xc
ffffffffc0204dd6:	8f71                	and	a4,a4,a2
ffffffffc0204dd8:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ddc:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204dde:	02d77a63          	bleu	a3,a4,ffffffffc0204e12 <swapfs_write+0x7e>
ffffffffc0204de2:	000a7797          	auipc	a5,0xa7
ffffffffc0204de6:	6ce78793          	addi	a5,a5,1742 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0204dea:	639c                	ld	a5,0(a5)
}
ffffffffc0204dec:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dee:	46a1                	li	a3,8
ffffffffc0204df0:	963e                	add	a2,a2,a5
ffffffffc0204df2:	4505                	li	a0,1
}
ffffffffc0204df4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204df6:	839fb06f          	j	ffffffffc020062e <ide_write_secs>
ffffffffc0204dfa:	86aa                	mv	a3,a0
ffffffffc0204dfc:	00003617          	auipc	a2,0x3
ffffffffc0204e00:	7ac60613          	addi	a2,a2,1964 # ffffffffc02085a8 <default_pmm_manager+0x10b0>
ffffffffc0204e04:	45e5                	li	a1,25
ffffffffc0204e06:	00003517          	auipc	a0,0x3
ffffffffc0204e0a:	78a50513          	addi	a0,a0,1930 # ffffffffc0208590 <default_pmm_manager+0x1098>
ffffffffc0204e0e:	e76fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204e12:	86b2                	mv	a3,a2
ffffffffc0204e14:	06900593          	li	a1,105
ffffffffc0204e18:	00002617          	auipc	a2,0x2
ffffffffc0204e1c:	73060613          	addi	a2,a2,1840 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0204e20:	00002517          	auipc	a0,0x2
ffffffffc0204e24:	75050513          	addi	a0,a0,1872 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204e28:	e5cfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204e2c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204e2c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204e2e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204e30:	736000ef          	jal	ra,ffffffffc0205566 <do_exit>

ffffffffc0204e34 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204e34:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e36:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204e3a:	e022                	sd	s0,0(sp)
ffffffffc0204e3c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e3e:	e19fc0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204e42:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204e44:	cd29                	beqz	a0,ffffffffc0204e9e <alloc_proc+0x6a>
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */

       
        proc->state = PROC_UNINIT;
ffffffffc0204e46:	57fd                	li	a5,-1
ffffffffc0204e48:	1782                	slli	a5,a5,0x20
ffffffffc0204e4a:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e4c:	07000613          	li	a2,112
ffffffffc0204e50:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204e52:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204e56:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204e5a:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204e5e:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204e62:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e66:	03050513          	addi	a0,a0,48
ffffffffc0204e6a:	127010ef          	jal	ra,ffffffffc0206790 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204e6e:	000a7797          	auipc	a5,0xa7
ffffffffc0204e72:	64a78793          	addi	a5,a5,1610 # ffffffffc02ac4b8 <boot_cr3>
ffffffffc0204e76:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204e78:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204e7c:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204e80:	f45c                	sd	a5,168(s0)
        memset(&(proc->name), 0, PROC_NAME_LEN);
ffffffffc0204e82:	463d                	li	a2,15
ffffffffc0204e84:	4581                	li	a1,0
ffffffffc0204e86:	0b440513          	addi	a0,s0,180
ffffffffc0204e8a:	107010ef          	jal	ra,ffffffffc0206790 <memset>

        proc->wait_state = 0;
ffffffffc0204e8e:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204e92:	0e043823          	sd	zero,240(s0)
        proc->yptr = NULL;
ffffffffc0204e96:	0e043c23          	sd	zero,248(s0)
        proc->optr = NULL;
ffffffffc0204e9a:	10043023          	sd	zero,256(s0)

    }
    return proc;
}
ffffffffc0204e9e:	8522                	mv	a0,s0
ffffffffc0204ea0:	60a2                	ld	ra,8(sp)
ffffffffc0204ea2:	6402                	ld	s0,0(sp)
ffffffffc0204ea4:	0141                	addi	sp,sp,16
ffffffffc0204ea6:	8082                	ret

ffffffffc0204ea8 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204ea8:	000a7797          	auipc	a5,0xa7
ffffffffc0204eac:	5c078793          	addi	a5,a5,1472 # ffffffffc02ac468 <current>
ffffffffc0204eb0:	639c                	ld	a5,0(a5)
ffffffffc0204eb2:	73c8                	ld	a0,160(a5)
ffffffffc0204eb4:	ef7fb06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204eb8 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204eb8:	000a7797          	auipc	a5,0xa7
ffffffffc0204ebc:	5b078793          	addi	a5,a5,1456 # ffffffffc02ac468 <current>
ffffffffc0204ec0:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204ec2:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ec4:	00004617          	auipc	a2,0x4
ffffffffc0204ec8:	af460613          	addi	a2,a2,-1292 # ffffffffc02089b8 <default_pmm_manager+0x14c0>
ffffffffc0204ecc:	43cc                	lw	a1,4(a5)
ffffffffc0204ece:	00004517          	auipc	a0,0x4
ffffffffc0204ed2:	afa50513          	addi	a0,a0,-1286 # ffffffffc02089c8 <default_pmm_manager+0x14d0>
user_main(void *arg) {
ffffffffc0204ed6:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ed8:	ab6fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204edc:	00004797          	auipc	a5,0x4
ffffffffc0204ee0:	adc78793          	addi	a5,a5,-1316 # ffffffffc02089b8 <default_pmm_manager+0x14c0>
ffffffffc0204ee4:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204ee8:	3ec70713          	addi	a4,a4,1004 # a2d0 <_binary_obj___user_forktest_out_size>
ffffffffc0204eec:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204eee:	853e                	mv	a0,a5
ffffffffc0204ef0:	00043717          	auipc	a4,0x43
ffffffffc0204ef4:	14870713          	addi	a4,a4,328 # ffffffffc0248038 <_binary_obj___user_forktest_out_start>
ffffffffc0204ef8:	f03a                	sd	a4,32(sp)
ffffffffc0204efa:	f43e                	sd	a5,40(sp)
ffffffffc0204efc:	e802                	sd	zero,16(sp)
ffffffffc0204efe:	7f4010ef          	jal	ra,ffffffffc02066f2 <strlen>
ffffffffc0204f02:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f04:	4511                	li	a0,4
ffffffffc0204f06:	55a2                	lw	a1,40(sp)
ffffffffc0204f08:	4662                	lw	a2,24(sp)
ffffffffc0204f0a:	5682                	lw	a3,32(sp)
ffffffffc0204f0c:	4722                	lw	a4,8(sp)
ffffffffc0204f0e:	48a9                	li	a7,10
ffffffffc0204f10:	9002                	ebreak
ffffffffc0204f12:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204f14:	65c2                	ld	a1,16(sp)
ffffffffc0204f16:	00004517          	auipc	a0,0x4
ffffffffc0204f1a:	ada50513          	addi	a0,a0,-1318 # ffffffffc02089f0 <default_pmm_manager+0x14f8>
ffffffffc0204f1e:	a70fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204f22:	00004617          	auipc	a2,0x4
ffffffffc0204f26:	ade60613          	addi	a2,a2,-1314 # ffffffffc0208a00 <default_pmm_manager+0x1508>
ffffffffc0204f2a:	35700593          	li	a1,855
ffffffffc0204f2e:	00004517          	auipc	a0,0x4
ffffffffc0204f32:	af250513          	addi	a0,a0,-1294 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0204f36:	d4efb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204f3a <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204f3a:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204f3c:	1141                	addi	sp,sp,-16
ffffffffc0204f3e:	e406                	sd	ra,8(sp)
ffffffffc0204f40:	c02007b7          	lui	a5,0xc0200
ffffffffc0204f44:	04f6e263          	bltu	a3,a5,ffffffffc0204f88 <put_pgdir+0x4e>
ffffffffc0204f48:	000a7797          	auipc	a5,0xa7
ffffffffc0204f4c:	56878793          	addi	a5,a5,1384 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0204f50:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204f52:	000a7797          	auipc	a5,0xa7
ffffffffc0204f56:	4fe78793          	addi	a5,a5,1278 # ffffffffc02ac450 <npage>
ffffffffc0204f5a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204f5c:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204f5e:	82b1                	srli	a3,a3,0xc
ffffffffc0204f60:	04f6f063          	bleu	a5,a3,ffffffffc0204fa0 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204f64:	00004797          	auipc	a5,0x4
ffffffffc0204f68:	f8478793          	addi	a5,a5,-124 # ffffffffc0208ee8 <nbase>
ffffffffc0204f6c:	639c                	ld	a5,0(a5)
ffffffffc0204f6e:	000a7717          	auipc	a4,0xa7
ffffffffc0204f72:	55270713          	addi	a4,a4,1362 # ffffffffc02ac4c0 <pages>
ffffffffc0204f76:	6308                	ld	a0,0(a4)
}
ffffffffc0204f78:	60a2                	ld	ra,8(sp)
ffffffffc0204f7a:	8e9d                	sub	a3,a3,a5
ffffffffc0204f7c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204f7e:	4585                	li	a1,1
ffffffffc0204f80:	9536                	add	a0,a0,a3
}
ffffffffc0204f82:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204f84:	f57fc06f          	j	ffffffffc0201eda <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204f88:	00002617          	auipc	a2,0x2
ffffffffc0204f8c:	5f860613          	addi	a2,a2,1528 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc0204f90:	06e00593          	li	a1,110
ffffffffc0204f94:	00002517          	auipc	a0,0x2
ffffffffc0204f98:	5dc50513          	addi	a0,a0,1500 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204f9c:	ce8fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204fa0:	00002617          	auipc	a2,0x2
ffffffffc0204fa4:	60860613          	addi	a2,a2,1544 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc0204fa8:	06200593          	li	a1,98
ffffffffc0204fac:	00002517          	auipc	a0,0x2
ffffffffc0204fb0:	5c450513          	addi	a0,a0,1476 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0204fb4:	cd0fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204fb8 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204fb8:	1101                	addi	sp,sp,-32
ffffffffc0204fba:	e426                	sd	s1,8(sp)
ffffffffc0204fbc:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204fbe:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204fc0:	ec06                	sd	ra,24(sp)
ffffffffc0204fc2:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204fc4:	e8ffc0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0204fc8:	c125                	beqz	a0,ffffffffc0205028 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204fca:	000a7797          	auipc	a5,0xa7
ffffffffc0204fce:	4f678793          	addi	a5,a5,1270 # ffffffffc02ac4c0 <pages>
ffffffffc0204fd2:	6394                	ld	a3,0(a5)
ffffffffc0204fd4:	00004797          	auipc	a5,0x4
ffffffffc0204fd8:	f1478793          	addi	a5,a5,-236 # ffffffffc0208ee8 <nbase>
ffffffffc0204fdc:	6380                	ld	s0,0(a5)
ffffffffc0204fde:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204fe2:	000a7717          	auipc	a4,0xa7
ffffffffc0204fe6:	46e70713          	addi	a4,a4,1134 # ffffffffc02ac450 <npage>
    return page - pages + nbase;
ffffffffc0204fea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204fec:	57fd                	li	a5,-1
ffffffffc0204fee:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204ff0:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204ff2:	83b1                	srli	a5,a5,0xc
ffffffffc0204ff4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ff6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ff8:	02e7fa63          	bleu	a4,a5,ffffffffc020502c <setup_pgdir+0x74>
ffffffffc0204ffc:	000a7797          	auipc	a5,0xa7
ffffffffc0205000:	4b478793          	addi	a5,a5,1204 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0205004:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205006:	000a7797          	auipc	a5,0xa7
ffffffffc020500a:	44278793          	addi	a5,a5,1090 # ffffffffc02ac448 <boot_pgdir>
ffffffffc020500e:	638c                	ld	a1,0(a5)
ffffffffc0205010:	9436                	add	s0,s0,a3
ffffffffc0205012:	6605                	lui	a2,0x1
ffffffffc0205014:	8522                	mv	a0,s0
ffffffffc0205016:	78c010ef          	jal	ra,ffffffffc02067a2 <memcpy>
    return 0;
ffffffffc020501a:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc020501c:	ec80                	sd	s0,24(s1)
}
ffffffffc020501e:	60e2                	ld	ra,24(sp)
ffffffffc0205020:	6442                	ld	s0,16(sp)
ffffffffc0205022:	64a2                	ld	s1,8(sp)
ffffffffc0205024:	6105                	addi	sp,sp,32
ffffffffc0205026:	8082                	ret
        return -E_NO_MEM;
ffffffffc0205028:	5571                	li	a0,-4
ffffffffc020502a:	bfd5                	j	ffffffffc020501e <setup_pgdir+0x66>
ffffffffc020502c:	00002617          	auipc	a2,0x2
ffffffffc0205030:	51c60613          	addi	a2,a2,1308 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0205034:	06900593          	li	a1,105
ffffffffc0205038:	00002517          	auipc	a0,0x2
ffffffffc020503c:	53850513          	addi	a0,a0,1336 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0205040:	c44fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205044 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205044:	1101                	addi	sp,sp,-32
ffffffffc0205046:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205048:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020504c:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020504e:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205050:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205052:	8522                	mv	a0,s0
ffffffffc0205054:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205056:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205058:	738010ef          	jal	ra,ffffffffc0206790 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020505c:	8522                	mv	a0,s0
}
ffffffffc020505e:	6442                	ld	s0,16(sp)
ffffffffc0205060:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205062:	85a6                	mv	a1,s1
}
ffffffffc0205064:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205066:	463d                	li	a2,15
}
ffffffffc0205068:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020506a:	7380106f          	j	ffffffffc02067a2 <memcpy>

ffffffffc020506e <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc020506e:	1101                	addi	sp,sp,-32
ffffffffc0205070:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0205072:	000a7497          	auipc	s1,0xa7
ffffffffc0205076:	3f648493          	addi	s1,s1,1014 # ffffffffc02ac468 <current>
ffffffffc020507a:	6098                	ld	a4,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc020507c:	ec06                	sd	ra,24(sp)
ffffffffc020507e:	e822                	sd	s0,16(sp)
ffffffffc0205080:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0205082:	02a70b63          	beq	a4,a0,ffffffffc02050b8 <proc_run+0x4a>
ffffffffc0205086:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205088:	100027f3          	csrr	a5,sstatus
ffffffffc020508c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020508e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205090:	e3a9                	bnez	a5,ffffffffc02050d2 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0205092:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0205094:	000a7697          	auipc	a3,0xa7
ffffffffc0205098:	3c86ba23          	sd	s0,980(a3) # ffffffffc02ac468 <current>
ffffffffc020509c:	56fd                	li	a3,-1
ffffffffc020509e:	16fe                	slli	a3,a3,0x3f
ffffffffc02050a0:	83b1                	srli	a5,a5,0xc
ffffffffc02050a2:	8fd5                	or	a5,a5,a3
ffffffffc02050a4:	18079073          	csrw	satp,a5
            switch_to(&(temp_proc->context), &(current->context));
ffffffffc02050a8:	03040593          	addi	a1,s0,48
ffffffffc02050ac:	03070513          	addi	a0,a4,48
ffffffffc02050b0:	7d7000ef          	jal	ra,ffffffffc0206086 <switch_to>
    if (flag) {
ffffffffc02050b4:	00091863          	bnez	s2,ffffffffc02050c4 <proc_run+0x56>
}
ffffffffc02050b8:	60e2                	ld	ra,24(sp)
ffffffffc02050ba:	6442                	ld	s0,16(sp)
ffffffffc02050bc:	64a2                	ld	s1,8(sp)
ffffffffc02050be:	6902                	ld	s2,0(sp)
ffffffffc02050c0:	6105                	addi	sp,sp,32
ffffffffc02050c2:	8082                	ret
ffffffffc02050c4:	6442                	ld	s0,16(sp)
ffffffffc02050c6:	60e2                	ld	ra,24(sp)
ffffffffc02050c8:	64a2                	ld	s1,8(sp)
ffffffffc02050ca:	6902                	ld	s2,0(sp)
ffffffffc02050cc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02050ce:	d86fb06f          	j	ffffffffc0200654 <intr_enable>
        intr_disable();
ffffffffc02050d2:	d88fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02050d6:	6098                	ld	a4,0(s1)
ffffffffc02050d8:	4905                	li	s2,1
ffffffffc02050da:	bf65                	j	ffffffffc0205092 <proc_run+0x24>

ffffffffc02050dc <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02050dc:	0005071b          	sext.w	a4,a0
ffffffffc02050e0:	6789                	lui	a5,0x2
ffffffffc02050e2:	fff7069b          	addiw	a3,a4,-1
ffffffffc02050e6:	17f9                	addi	a5,a5,-2
ffffffffc02050e8:	04d7e063          	bltu	a5,a3,ffffffffc0205128 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02050ec:	1141                	addi	sp,sp,-16
ffffffffc02050ee:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02050f0:	45a9                	li	a1,10
ffffffffc02050f2:	842a                	mv	s0,a0
ffffffffc02050f4:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02050f6:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02050f8:	1ea010ef          	jal	ra,ffffffffc02062e2 <hash32>
ffffffffc02050fc:	02051693          	slli	a3,a0,0x20
ffffffffc0205100:	82f1                	srli	a3,a3,0x1c
ffffffffc0205102:	000a3517          	auipc	a0,0xa3
ffffffffc0205106:	32e50513          	addi	a0,a0,814 # ffffffffc02a8430 <hash_list>
ffffffffc020510a:	96aa                	add	a3,a3,a0
ffffffffc020510c:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020510e:	a029                	j	ffffffffc0205118 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0205110:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7644>
ffffffffc0205114:	00870c63          	beq	a4,s0,ffffffffc020512c <find_proc+0x50>
ffffffffc0205118:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020511a:	fef69be3          	bne	a3,a5,ffffffffc0205110 <find_proc+0x34>
}
ffffffffc020511e:	60a2                	ld	ra,8(sp)
ffffffffc0205120:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0205122:	4501                	li	a0,0
}
ffffffffc0205124:	0141                	addi	sp,sp,16
ffffffffc0205126:	8082                	ret
    return NULL;
ffffffffc0205128:	4501                	li	a0,0
}
ffffffffc020512a:	8082                	ret
ffffffffc020512c:	60a2                	ld	ra,8(sp)
ffffffffc020512e:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205130:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205134:	0141                	addi	sp,sp,16
ffffffffc0205136:	8082                	ret

ffffffffc0205138 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205138:	7159                	addi	sp,sp,-112
ffffffffc020513a:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020513c:	000a7a17          	auipc	s4,0xa7
ffffffffc0205140:	344a0a13          	addi	s4,s4,836 # ffffffffc02ac480 <nr_process>
ffffffffc0205144:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205148:	f486                	sd	ra,104(sp)
ffffffffc020514a:	f0a2                	sd	s0,96(sp)
ffffffffc020514c:	eca6                	sd	s1,88(sp)
ffffffffc020514e:	e8ca                	sd	s2,80(sp)
ffffffffc0205150:	e4ce                	sd	s3,72(sp)
ffffffffc0205152:	fc56                	sd	s5,56(sp)
ffffffffc0205154:	f85a                	sd	s6,48(sp)
ffffffffc0205156:	f45e                	sd	s7,40(sp)
ffffffffc0205158:	f062                	sd	s8,32(sp)
ffffffffc020515a:	ec66                	sd	s9,24(sp)
ffffffffc020515c:	e86a                	sd	s10,16(sp)
ffffffffc020515e:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205160:	6785                	lui	a5,0x1
ffffffffc0205162:	30f75b63          	ble	a5,a4,ffffffffc0205478 <do_fork+0x340>
ffffffffc0205166:	89aa                	mv	s3,a0
ffffffffc0205168:	892e                	mv	s2,a1
ffffffffc020516a:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020516c:	cc9ff0ef          	jal	ra,ffffffffc0204e34 <alloc_proc>
ffffffffc0205170:	842a                	mv	s0,a0
ffffffffc0205172:	2e050563          	beqz	a0,ffffffffc020545c <do_fork+0x324>
    proc->parent = current;
ffffffffc0205176:	000a7c17          	auipc	s8,0xa7
ffffffffc020517a:	2f2c0c13          	addi	s8,s8,754 # ffffffffc02ac468 <current>
ffffffffc020517e:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0205182:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8484>
    proc->parent = current;
ffffffffc0205186:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205188:	30071663          	bnez	a4,ffffffffc0205494 <do_fork+0x35c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020518c:	4509                	li	a0,2
ffffffffc020518e:	cc5fc0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
    if (page != NULL) {
ffffffffc0205192:	2c050263          	beqz	a0,ffffffffc0205456 <do_fork+0x31e>
    return page - pages + nbase;
ffffffffc0205196:	000a7a97          	auipc	s5,0xa7
ffffffffc020519a:	32aa8a93          	addi	s5,s5,810 # ffffffffc02ac4c0 <pages>
ffffffffc020519e:	000ab683          	ld	a3,0(s5)
ffffffffc02051a2:	00004b17          	auipc	s6,0x4
ffffffffc02051a6:	d46b0b13          	addi	s6,s6,-698 # ffffffffc0208ee8 <nbase>
ffffffffc02051aa:	000b3783          	ld	a5,0(s6)
ffffffffc02051ae:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02051b2:	000a7b97          	auipc	s7,0xa7
ffffffffc02051b6:	29eb8b93          	addi	s7,s7,670 # ffffffffc02ac450 <npage>
    return page - pages + nbase;
ffffffffc02051ba:	8699                	srai	a3,a3,0x6
ffffffffc02051bc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02051be:	000bb703          	ld	a4,0(s7)
ffffffffc02051c2:	57fd                	li	a5,-1
ffffffffc02051c4:	83b1                	srli	a5,a5,0xc
ffffffffc02051c6:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02051c8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051ca:	2ae7f963          	bleu	a4,a5,ffffffffc020547c <do_fork+0x344>
ffffffffc02051ce:	000a7c97          	auipc	s9,0xa7
ffffffffc02051d2:	2e2c8c93          	addi	s9,s9,738 # ffffffffc02ac4b0 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02051d6:	000c3703          	ld	a4,0(s8)
ffffffffc02051da:	000cb783          	ld	a5,0(s9)
ffffffffc02051de:	02873c03          	ld	s8,40(a4)
ffffffffc02051e2:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02051e4:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc02051e6:	020c0863          	beqz	s8,ffffffffc0205216 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc02051ea:	1009f993          	andi	s3,s3,256
ffffffffc02051ee:	1e098263          	beqz	s3,ffffffffc02053d2 <do_fork+0x29a>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02051f2:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02051f6:	018c3783          	ld	a5,24(s8)
ffffffffc02051fa:	c02006b7          	lui	a3,0xc0200
ffffffffc02051fe:	2705                	addiw	a4,a4,1
ffffffffc0205200:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205204:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205208:	2ad7e663          	bltu	a5,a3,ffffffffc02054b4 <do_fork+0x37c>
ffffffffc020520c:	000cb703          	ld	a4,0(s9)
ffffffffc0205210:	6814                	ld	a3,16(s0)
ffffffffc0205212:	8f99                	sub	a5,a5,a4
ffffffffc0205214:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205216:	6789                	lui	a5,0x2
ffffffffc0205218:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>
ffffffffc020521c:	96be                	add	a3,a3,a5
ffffffffc020521e:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205220:	87b6                	mv	a5,a3
ffffffffc0205222:	12048813          	addi	a6,s1,288
ffffffffc0205226:	6088                	ld	a0,0(s1)
ffffffffc0205228:	648c                	ld	a1,8(s1)
ffffffffc020522a:	6890                	ld	a2,16(s1)
ffffffffc020522c:	6c98                	ld	a4,24(s1)
ffffffffc020522e:	e388                	sd	a0,0(a5)
ffffffffc0205230:	e78c                	sd	a1,8(a5)
ffffffffc0205232:	eb90                	sd	a2,16(a5)
ffffffffc0205234:	ef98                	sd	a4,24(a5)
ffffffffc0205236:	02048493          	addi	s1,s1,32
ffffffffc020523a:	02078793          	addi	a5,a5,32
ffffffffc020523e:	ff0494e3          	bne	s1,a6,ffffffffc0205226 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0205242:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205246:	12090f63          	beqz	s2,ffffffffc0205384 <do_fork+0x24c>
ffffffffc020524a:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020524e:	00000797          	auipc	a5,0x0
ffffffffc0205252:	c5a78793          	addi	a5,a5,-934 # ffffffffc0204ea8 <forkret>
ffffffffc0205256:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205258:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020525a:	100027f3          	csrr	a5,sstatus
ffffffffc020525e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205260:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205262:	14079063          	bnez	a5,ffffffffc02053a2 <do_fork+0x26a>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205266:	0009c797          	auipc	a5,0x9c
ffffffffc020526a:	dc278793          	addi	a5,a5,-574 # ffffffffc02a1028 <last_pid.1691>
ffffffffc020526e:	439c                	lw	a5,0(a5)
ffffffffc0205270:	6709                	lui	a4,0x2
ffffffffc0205272:	0017851b          	addiw	a0,a5,1
ffffffffc0205276:	0009c697          	auipc	a3,0x9c
ffffffffc020527a:	daa6a923          	sw	a0,-590(a3) # ffffffffc02a1028 <last_pid.1691>
ffffffffc020527e:	14e55363          	ble	a4,a0,ffffffffc02053c4 <do_fork+0x28c>
    if (last_pid >= next_safe) {
ffffffffc0205282:	0009c797          	auipc	a5,0x9c
ffffffffc0205286:	daa78793          	addi	a5,a5,-598 # ffffffffc02a102c <next_safe.1690>
ffffffffc020528a:	439c                	lw	a5,0(a5)
ffffffffc020528c:	000a7617          	auipc	a2,0xa7
ffffffffc0205290:	31c60613          	addi	a2,a2,796 # ffffffffc02ac5a8 <proc_list>
ffffffffc0205294:	06f54163          	blt	a0,a5,ffffffffc02052f6 <do_fork+0x1be>
        next_safe = MAX_PID;
ffffffffc0205298:	6789                	lui	a5,0x2
ffffffffc020529a:	0009c717          	auipc	a4,0x9c
ffffffffc020529e:	d8f72923          	sw	a5,-622(a4) # ffffffffc02a102c <next_safe.1690>
ffffffffc02052a2:	4801                	li	a6,0
ffffffffc02052a4:	87aa                	mv	a5,a0
ffffffffc02052a6:	000a7617          	auipc	a2,0xa7
ffffffffc02052aa:	30260613          	addi	a2,a2,770 # ffffffffc02ac5a8 <proc_list>
    repeat:
ffffffffc02052ae:	6309                	lui	t1,0x2
ffffffffc02052b0:	88c2                	mv	a7,a6
ffffffffc02052b2:	6589                	lui	a1,0x2
        le = list;
ffffffffc02052b4:	000a7697          	auipc	a3,0xa7
ffffffffc02052b8:	2f468693          	addi	a3,a3,756 # ffffffffc02ac5a8 <proc_list>
ffffffffc02052bc:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02052be:	00c68f63          	beq	a3,a2,ffffffffc02052dc <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc02052c2:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02052c6:	0ae78a63          	beq	a5,a4,ffffffffc020537a <do_fork+0x242>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02052ca:	fee7d9e3          	ble	a4,a5,ffffffffc02052bc <do_fork+0x184>
ffffffffc02052ce:	feb757e3          	ble	a1,a4,ffffffffc02052bc <do_fork+0x184>
ffffffffc02052d2:	6694                	ld	a3,8(a3)
ffffffffc02052d4:	85ba                	mv	a1,a4
ffffffffc02052d6:	4885                	li	a7,1
        while ((le = list_next(le)) != list) {
ffffffffc02052d8:	fec695e3          	bne	a3,a2,ffffffffc02052c2 <do_fork+0x18a>
ffffffffc02052dc:	00080763          	beqz	a6,ffffffffc02052ea <do_fork+0x1b2>
ffffffffc02052e0:	0009c717          	auipc	a4,0x9c
ffffffffc02052e4:	d4f72423          	sw	a5,-696(a4) # ffffffffc02a1028 <last_pid.1691>
ffffffffc02052e8:	853e                	mv	a0,a5
ffffffffc02052ea:	00088663          	beqz	a7,ffffffffc02052f6 <do_fork+0x1be>
ffffffffc02052ee:	0009c797          	auipc	a5,0x9c
ffffffffc02052f2:	d2b7af23          	sw	a1,-706(a5) # ffffffffc02a102c <next_safe.1690>
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02052f6:	7018                	ld	a4,32(s0)
    __list_add(elm, listelm, listelm->next);
ffffffffc02052f8:	6614                	ld	a3,8(a2)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02052fa:	0c840593          	addi	a1,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02052fe:	7b7c                	ld	a5,240(a4)
        proc->pid = get_pid();
ffffffffc0205300:	c048                	sw	a0,4(s0)
    prev->next = next->prev = elm;
ffffffffc0205302:	e28c                	sd	a1,0(a3)
ffffffffc0205304:	000a7817          	auipc	a6,0xa7
ffffffffc0205308:	2ab83623          	sd	a1,684(a6) # ffffffffc02ac5b0 <proc_list+0x8>
    elm->next = next;
ffffffffc020530c:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc020530e:	e470                	sd	a2,200(s0)
    proc->yptr = NULL;
ffffffffc0205310:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205314:	10f43023          	sd	a5,256(s0)
ffffffffc0205318:	c391                	beqz	a5,ffffffffc020531c <do_fork+0x1e4>
        proc->optr->yptr = proc;
ffffffffc020531a:	ffe0                	sd	s0,248(a5)
    nr_process ++;
ffffffffc020531c:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc0205320:	fb60                	sd	s0,240(a4)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205322:	45a9                	li	a1,10
    nr_process ++;
ffffffffc0205324:	2785                	addiw	a5,a5,1
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205326:	2501                	sext.w	a0,a0
    nr_process ++;
ffffffffc0205328:	000a7717          	auipc	a4,0xa7
ffffffffc020532c:	14f72c23          	sw	a5,344(a4) # ffffffffc02ac480 <nr_process>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205330:	7b3000ef          	jal	ra,ffffffffc02062e2 <hash32>
ffffffffc0205334:	1502                	slli	a0,a0,0x20
ffffffffc0205336:	000a3797          	auipc	a5,0xa3
ffffffffc020533a:	0fa78793          	addi	a5,a5,250 # ffffffffc02a8430 <hash_list>
ffffffffc020533e:	8171                	srli	a0,a0,0x1c
ffffffffc0205340:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205342:	651c                	ld	a5,8(a0)
ffffffffc0205344:	0d840713          	addi	a4,s0,216
    prev->next = next->prev = elm;
ffffffffc0205348:	e398                	sd	a4,0(a5)
ffffffffc020534a:	e518                	sd	a4,8(a0)
    elm->next = next;
ffffffffc020534c:	f07c                	sd	a5,224(s0)
    elm->prev = prev;
ffffffffc020534e:	ec68                	sd	a0,216(s0)
    if (flag) {
ffffffffc0205350:	10049863          	bnez	s1,ffffffffc0205460 <do_fork+0x328>
    wakeup_proc(proc);
ffffffffc0205354:	8522                	mv	a0,s0
ffffffffc0205356:	59b000ef          	jal	ra,ffffffffc02060f0 <wakeup_proc>
    ret = proc->pid;
ffffffffc020535a:	4048                	lw	a0,4(s0)
}
ffffffffc020535c:	70a6                	ld	ra,104(sp)
ffffffffc020535e:	7406                	ld	s0,96(sp)
ffffffffc0205360:	64e6                	ld	s1,88(sp)
ffffffffc0205362:	6946                	ld	s2,80(sp)
ffffffffc0205364:	69a6                	ld	s3,72(sp)
ffffffffc0205366:	6a06                	ld	s4,64(sp)
ffffffffc0205368:	7ae2                	ld	s5,56(sp)
ffffffffc020536a:	7b42                	ld	s6,48(sp)
ffffffffc020536c:	7ba2                	ld	s7,40(sp)
ffffffffc020536e:	7c02                	ld	s8,32(sp)
ffffffffc0205370:	6ce2                	ld	s9,24(sp)
ffffffffc0205372:	6d42                	ld	s10,16(sp)
ffffffffc0205374:	6da2                	ld	s11,8(sp)
ffffffffc0205376:	6165                	addi	sp,sp,112
ffffffffc0205378:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc020537a:	2785                	addiw	a5,a5,1
ffffffffc020537c:	0eb7d563          	ble	a1,a5,ffffffffc0205466 <do_fork+0x32e>
ffffffffc0205380:	4805                	li	a6,1
ffffffffc0205382:	bf2d                	j	ffffffffc02052bc <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205384:	8936                	mv	s2,a3
ffffffffc0205386:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020538a:	00000797          	auipc	a5,0x0
ffffffffc020538e:	b1e78793          	addi	a5,a5,-1250 # ffffffffc0204ea8 <forkret>
ffffffffc0205392:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205394:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205396:	100027f3          	csrr	a5,sstatus
ffffffffc020539a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020539c:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020539e:	ec0784e3          	beqz	a5,ffffffffc0205266 <do_fork+0x12e>
        intr_disable();
ffffffffc02053a2:	ab8fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02053a6:	0009c797          	auipc	a5,0x9c
ffffffffc02053aa:	c8278793          	addi	a5,a5,-894 # ffffffffc02a1028 <last_pid.1691>
ffffffffc02053ae:	439c                	lw	a5,0(a5)
ffffffffc02053b0:	6709                	lui	a4,0x2
        return 1;
ffffffffc02053b2:	4485                	li	s1,1
ffffffffc02053b4:	0017851b          	addiw	a0,a5,1
ffffffffc02053b8:	0009c697          	auipc	a3,0x9c
ffffffffc02053bc:	c6a6a823          	sw	a0,-912(a3) # ffffffffc02a1028 <last_pid.1691>
ffffffffc02053c0:	ece541e3          	blt	a0,a4,ffffffffc0205282 <do_fork+0x14a>
        last_pid = 1;
ffffffffc02053c4:	4785                	li	a5,1
ffffffffc02053c6:	0009c717          	auipc	a4,0x9c
ffffffffc02053ca:	c6f72123          	sw	a5,-926(a4) # ffffffffc02a1028 <last_pid.1691>
ffffffffc02053ce:	4505                	li	a0,1
ffffffffc02053d0:	b5e1                	j	ffffffffc0205298 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc02053d2:	d73fe0ef          	jal	ra,ffffffffc0204144 <mm_create>
ffffffffc02053d6:	8d2a                	mv	s10,a0
ffffffffc02053d8:	c539                	beqz	a0,ffffffffc0205426 <do_fork+0x2ee>
    if (setup_pgdir(mm) != 0) {
ffffffffc02053da:	bdfff0ef          	jal	ra,ffffffffc0204fb8 <setup_pgdir>
ffffffffc02053de:	e949                	bnez	a0,ffffffffc0205470 <do_fork+0x338>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02053e0:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02053e4:	4785                	li	a5,1
ffffffffc02053e6:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc02053ea:	8b85                	andi	a5,a5,1
ffffffffc02053ec:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02053ee:	c799                	beqz	a5,ffffffffc02053fc <do_fork+0x2c4>
        schedule();
ffffffffc02053f0:	57d000ef          	jal	ra,ffffffffc020616c <schedule>
ffffffffc02053f4:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc02053f8:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02053fa:	fbfd                	bnez	a5,ffffffffc02053f0 <do_fork+0x2b8>
        ret = dup_mmap(mm, oldmm);
ffffffffc02053fc:	85e2                	mv	a1,s8
ffffffffc02053fe:	856a                	mv	a0,s10
ffffffffc0205400:	fcffe0ef          	jal	ra,ffffffffc02043ce <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205404:	57f9                	li	a5,-2
ffffffffc0205406:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020540a:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020540c:	c3e9                	beqz	a5,ffffffffc02054ce <do_fork+0x396>
    if (ret != 0) {
ffffffffc020540e:	8c6a                	mv	s8,s10
ffffffffc0205410:	de0501e3          	beqz	a0,ffffffffc02051f2 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205414:	856a                	mv	a0,s10
ffffffffc0205416:	854ff0ef          	jal	ra,ffffffffc020446a <exit_mmap>
    put_pgdir(mm);
ffffffffc020541a:	856a                	mv	a0,s10
ffffffffc020541c:	b1fff0ef          	jal	ra,ffffffffc0204f3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205420:	856a                	mv	a0,s10
ffffffffc0205422:	ea9fe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205426:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205428:	c02007b7          	lui	a5,0xc0200
ffffffffc020542c:	0cf6e963          	bltu	a3,a5,ffffffffc02054fe <do_fork+0x3c6>
ffffffffc0205430:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc0205434:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205438:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020543c:	83b1                	srli	a5,a5,0xc
ffffffffc020543e:	0ae7f463          	bleu	a4,a5,ffffffffc02054e6 <do_fork+0x3ae>
    return &pages[PPN(pa) - nbase];
ffffffffc0205442:	000b3703          	ld	a4,0(s6)
ffffffffc0205446:	000ab503          	ld	a0,0(s5)
ffffffffc020544a:	4589                	li	a1,2
ffffffffc020544c:	8f99                	sub	a5,a5,a4
ffffffffc020544e:	079a                	slli	a5,a5,0x6
ffffffffc0205450:	953e                	add	a0,a0,a5
ffffffffc0205452:	a89fc0ef          	jal	ra,ffffffffc0201eda <free_pages>
    kfree(proc);
ffffffffc0205456:	8522                	mv	a0,s0
ffffffffc0205458:	8bbfc0ef          	jal	ra,ffffffffc0201d12 <kfree>
    ret = -E_NO_MEM;
ffffffffc020545c:	5571                	li	a0,-4
    return ret;
ffffffffc020545e:	bdfd                	j	ffffffffc020535c <do_fork+0x224>
        intr_enable();
ffffffffc0205460:	9f4fb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205464:	bdc5                	j	ffffffffc0205354 <do_fork+0x21c>
                    if (last_pid >= MAX_PID) {
ffffffffc0205466:	0067c363          	blt	a5,t1,ffffffffc020546c <do_fork+0x334>
                        last_pid = 1;
ffffffffc020546a:	4785                	li	a5,1
                    goto repeat;
ffffffffc020546c:	4805                	li	a6,1
ffffffffc020546e:	b589                	j	ffffffffc02052b0 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc0205470:	856a                	mv	a0,s10
ffffffffc0205472:	e59fe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
ffffffffc0205476:	bf45                	j	ffffffffc0205426 <do_fork+0x2ee>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205478:	556d                	li	a0,-5
ffffffffc020547a:	b5cd                	j	ffffffffc020535c <do_fork+0x224>
    return KADDR(page2pa(page));
ffffffffc020547c:	00002617          	auipc	a2,0x2
ffffffffc0205480:	0cc60613          	addi	a2,a2,204 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0205484:	06900593          	li	a1,105
ffffffffc0205488:	00002517          	auipc	a0,0x2
ffffffffc020548c:	0e850513          	addi	a0,a0,232 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0205490:	ff5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205494:	00003697          	auipc	a3,0x3
ffffffffc0205498:	2fc68693          	addi	a3,a3,764 # ffffffffc0208790 <default_pmm_manager+0x1298>
ffffffffc020549c:	00002617          	auipc	a2,0x2
ffffffffc02054a0:	91460613          	addi	a2,a2,-1772 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02054a4:	1ba00593          	li	a1,442
ffffffffc02054a8:	00003517          	auipc	a0,0x3
ffffffffc02054ac:	57850513          	addi	a0,a0,1400 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc02054b0:	fd5fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02054b4:	86be                	mv	a3,a5
ffffffffc02054b6:	00002617          	auipc	a2,0x2
ffffffffc02054ba:	0ca60613          	addi	a2,a2,202 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc02054be:	16b00593          	li	a1,363
ffffffffc02054c2:	00003517          	auipc	a0,0x3
ffffffffc02054c6:	55e50513          	addi	a0,a0,1374 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc02054ca:	fbbfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc02054ce:	00003617          	auipc	a2,0x3
ffffffffc02054d2:	2e260613          	addi	a2,a2,738 # ffffffffc02087b0 <default_pmm_manager+0x12b8>
ffffffffc02054d6:	03100593          	li	a1,49
ffffffffc02054da:	00003517          	auipc	a0,0x3
ffffffffc02054de:	2e650513          	addi	a0,a0,742 # ffffffffc02087c0 <default_pmm_manager+0x12c8>
ffffffffc02054e2:	fa3fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02054e6:	00002617          	auipc	a2,0x2
ffffffffc02054ea:	0c260613          	addi	a2,a2,194 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc02054ee:	06200593          	li	a1,98
ffffffffc02054f2:	00002517          	auipc	a0,0x2
ffffffffc02054f6:	07e50513          	addi	a0,a0,126 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc02054fa:	f8bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02054fe:	00002617          	auipc	a2,0x2
ffffffffc0205502:	08260613          	addi	a2,a2,130 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc0205506:	06e00593          	li	a1,110
ffffffffc020550a:	00002517          	auipc	a0,0x2
ffffffffc020550e:	06650513          	addi	a0,a0,102 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0205512:	f73fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205516 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205516:	7129                	addi	sp,sp,-320
ffffffffc0205518:	fa22                	sd	s0,304(sp)
ffffffffc020551a:	f626                	sd	s1,296(sp)
ffffffffc020551c:	f24a                	sd	s2,288(sp)
ffffffffc020551e:	84ae                	mv	s1,a1
ffffffffc0205520:	892a                	mv	s2,a0
ffffffffc0205522:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205524:	4581                	li	a1,0
ffffffffc0205526:	12000613          	li	a2,288
ffffffffc020552a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020552c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020552e:	262010ef          	jal	ra,ffffffffc0206790 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205532:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205534:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205536:	100027f3          	csrr	a5,sstatus
ffffffffc020553a:	edd7f793          	andi	a5,a5,-291
ffffffffc020553e:	1207e793          	ori	a5,a5,288
ffffffffc0205542:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205544:	860a                	mv	a2,sp
ffffffffc0205546:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020554a:	00000797          	auipc	a5,0x0
ffffffffc020554e:	8e278793          	addi	a5,a5,-1822 # ffffffffc0204e2c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205552:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205554:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205556:	be3ff0ef          	jal	ra,ffffffffc0205138 <do_fork>
}
ffffffffc020555a:	70f2                	ld	ra,312(sp)
ffffffffc020555c:	7452                	ld	s0,304(sp)
ffffffffc020555e:	74b2                	ld	s1,296(sp)
ffffffffc0205560:	7912                	ld	s2,288(sp)
ffffffffc0205562:	6131                	addi	sp,sp,320
ffffffffc0205564:	8082                	ret

ffffffffc0205566 <do_exit>:
do_exit(int error_code) {
ffffffffc0205566:	7179                	addi	sp,sp,-48
ffffffffc0205568:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc020556a:	000a7717          	auipc	a4,0xa7
ffffffffc020556e:	f0670713          	addi	a4,a4,-250 # ffffffffc02ac470 <idleproc>
ffffffffc0205572:	000a7917          	auipc	s2,0xa7
ffffffffc0205576:	ef690913          	addi	s2,s2,-266 # ffffffffc02ac468 <current>
ffffffffc020557a:	00093783          	ld	a5,0(s2)
ffffffffc020557e:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205580:	f406                	sd	ra,40(sp)
ffffffffc0205582:	f022                	sd	s0,32(sp)
ffffffffc0205584:	ec26                	sd	s1,24(sp)
ffffffffc0205586:	e44e                	sd	s3,8(sp)
ffffffffc0205588:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020558a:	0ce78c63          	beq	a5,a4,ffffffffc0205662 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020558e:	000a7417          	auipc	s0,0xa7
ffffffffc0205592:	eea40413          	addi	s0,s0,-278 # ffffffffc02ac478 <initproc>
ffffffffc0205596:	6018                	ld	a4,0(s0)
ffffffffc0205598:	0ee78b63          	beq	a5,a4,ffffffffc020568e <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc020559c:	7784                	ld	s1,40(a5)
ffffffffc020559e:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02055a0:	c48d                	beqz	s1,ffffffffc02055ca <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02055a2:	000a7797          	auipc	a5,0xa7
ffffffffc02055a6:	f1678793          	addi	a5,a5,-234 # ffffffffc02ac4b8 <boot_cr3>
ffffffffc02055aa:	639c                	ld	a5,0(a5)
ffffffffc02055ac:	577d                	li	a4,-1
ffffffffc02055ae:	177e                	slli	a4,a4,0x3f
ffffffffc02055b0:	83b1                	srli	a5,a5,0xc
ffffffffc02055b2:	8fd9                	or	a5,a5,a4
ffffffffc02055b4:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02055b8:	589c                	lw	a5,48(s1)
ffffffffc02055ba:	fff7871b          	addiw	a4,a5,-1
ffffffffc02055be:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02055c0:	cf4d                	beqz	a4,ffffffffc020567a <do_exit+0x114>
        current->mm = NULL;
ffffffffc02055c2:	00093783          	ld	a5,0(s2)
ffffffffc02055c6:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02055ca:	00093783          	ld	a5,0(s2)
ffffffffc02055ce:	470d                	li	a4,3
ffffffffc02055d0:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02055d2:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055d6:	100027f3          	csrr	a5,sstatus
ffffffffc02055da:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055dc:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055de:	e7e1                	bnez	a5,ffffffffc02056a6 <do_exit+0x140>
        proc = current->parent;
ffffffffc02055e0:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055e4:	800007b7          	lui	a5,0x80000
ffffffffc02055e8:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02055ea:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055ec:	0ec52703          	lw	a4,236(a0)
ffffffffc02055f0:	0af70f63          	beq	a4,a5,ffffffffc02056ae <do_exit+0x148>
ffffffffc02055f4:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055f8:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055fc:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055fe:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205600:	7afc                	ld	a5,240(a3)
ffffffffc0205602:	cb95                	beqz	a5,ffffffffc0205636 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205604:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5680>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205608:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020560a:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020560c:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020560e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205612:	10e7b023          	sd	a4,256(a5)
ffffffffc0205616:	c311                	beqz	a4,ffffffffc020561a <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205618:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020561a:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020561c:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020561e:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205620:	fe9710e3          	bne	a4,s1,ffffffffc0205600 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205624:	0ec52783          	lw	a5,236(a0)
ffffffffc0205628:	fd379ce3          	bne	a5,s3,ffffffffc0205600 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020562c:	2c5000ef          	jal	ra,ffffffffc02060f0 <wakeup_proc>
ffffffffc0205630:	00093683          	ld	a3,0(s2)
ffffffffc0205634:	b7f1                	j	ffffffffc0205600 <do_exit+0x9a>
    if (flag) {
ffffffffc0205636:	020a1363          	bnez	s4,ffffffffc020565c <do_exit+0xf6>
    schedule();
ffffffffc020563a:	333000ef          	jal	ra,ffffffffc020616c <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020563e:	00093783          	ld	a5,0(s2)
ffffffffc0205642:	00003617          	auipc	a2,0x3
ffffffffc0205646:	12e60613          	addi	a2,a2,302 # ffffffffc0208770 <default_pmm_manager+0x1278>
ffffffffc020564a:	20d00593          	li	a1,525
ffffffffc020564e:	43d4                	lw	a3,4(a5)
ffffffffc0205650:	00003517          	auipc	a0,0x3
ffffffffc0205654:	3d050513          	addi	a0,a0,976 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205658:	e2dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc020565c:	ff9fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205660:	bfe9                	j	ffffffffc020563a <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205662:	00003617          	auipc	a2,0x3
ffffffffc0205666:	0ee60613          	addi	a2,a2,238 # ffffffffc0208750 <default_pmm_manager+0x1258>
ffffffffc020566a:	1e100593          	li	a1,481
ffffffffc020566e:	00003517          	auipc	a0,0x3
ffffffffc0205672:	3b250513          	addi	a0,a0,946 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205676:	e0ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc020567a:	8526                	mv	a0,s1
ffffffffc020567c:	deffe0ef          	jal	ra,ffffffffc020446a <exit_mmap>
            put_pgdir(mm);
ffffffffc0205680:	8526                	mv	a0,s1
ffffffffc0205682:	8b9ff0ef          	jal	ra,ffffffffc0204f3a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205686:	8526                	mv	a0,s1
ffffffffc0205688:	c43fe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
ffffffffc020568c:	bf1d                	j	ffffffffc02055c2 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020568e:	00003617          	auipc	a2,0x3
ffffffffc0205692:	0d260613          	addi	a2,a2,210 # ffffffffc0208760 <default_pmm_manager+0x1268>
ffffffffc0205696:	1e400593          	li	a1,484
ffffffffc020569a:	00003517          	auipc	a0,0x3
ffffffffc020569e:	38650513          	addi	a0,a0,902 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc02056a2:	de3fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc02056a6:	fb5fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02056aa:	4a05                	li	s4,1
ffffffffc02056ac:	bf15                	j	ffffffffc02055e0 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc02056ae:	243000ef          	jal	ra,ffffffffc02060f0 <wakeup_proc>
ffffffffc02056b2:	b789                	j	ffffffffc02055f4 <do_exit+0x8e>

ffffffffc02056b4 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02056b4:	7139                	addi	sp,sp,-64
ffffffffc02056b6:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02056b8:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02056bc:	f426                	sd	s1,40(sp)
ffffffffc02056be:	f04a                	sd	s2,32(sp)
ffffffffc02056c0:	ec4e                	sd	s3,24(sp)
ffffffffc02056c2:	e456                	sd	s5,8(sp)
ffffffffc02056c4:	e05a                	sd	s6,0(sp)
ffffffffc02056c6:	fc06                	sd	ra,56(sp)
ffffffffc02056c8:	f822                	sd	s0,48(sp)
ffffffffc02056ca:	89aa                	mv	s3,a0
ffffffffc02056cc:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02056ce:	000a7917          	auipc	s2,0xa7
ffffffffc02056d2:	d9a90913          	addi	s2,s2,-614 # ffffffffc02ac468 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056d6:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02056d8:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02056da:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02056dc:	02098f63          	beqz	s3,ffffffffc020571a <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02056e0:	854e                	mv	a0,s3
ffffffffc02056e2:	9fbff0ef          	jal	ra,ffffffffc02050dc <find_proc>
ffffffffc02056e6:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02056e8:	12050063          	beqz	a0,ffffffffc0205808 <do_wait.part.1+0x154>
ffffffffc02056ec:	00093703          	ld	a4,0(s2)
ffffffffc02056f0:	711c                	ld	a5,32(a0)
ffffffffc02056f2:	10e79b63          	bne	a5,a4,ffffffffc0205808 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056f6:	411c                	lw	a5,0(a0)
ffffffffc02056f8:	02978c63          	beq	a5,s1,ffffffffc0205730 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02056fc:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205700:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205704:	269000ef          	jal	ra,ffffffffc020616c <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205708:	00093783          	ld	a5,0(s2)
ffffffffc020570c:	0b07a783          	lw	a5,176(a5)
ffffffffc0205710:	8b85                	andi	a5,a5,1
ffffffffc0205712:	d7e9                	beqz	a5,ffffffffc02056dc <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205714:	555d                	li	a0,-9
ffffffffc0205716:	e51ff0ef          	jal	ra,ffffffffc0205566 <do_exit>
        proc = current->cptr;
ffffffffc020571a:	00093703          	ld	a4,0(s2)
ffffffffc020571e:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205720:	e409                	bnez	s0,ffffffffc020572a <do_wait.part.1+0x76>
ffffffffc0205722:	a0dd                	j	ffffffffc0205808 <do_wait.part.1+0x154>
ffffffffc0205724:	10043403          	ld	s0,256(s0)
ffffffffc0205728:	d871                	beqz	s0,ffffffffc02056fc <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020572a:	401c                	lw	a5,0(s0)
ffffffffc020572c:	fe979ce3          	bne	a5,s1,ffffffffc0205724 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205730:	000a7797          	auipc	a5,0xa7
ffffffffc0205734:	d4078793          	addi	a5,a5,-704 # ffffffffc02ac470 <idleproc>
ffffffffc0205738:	639c                	ld	a5,0(a5)
ffffffffc020573a:	0c878d63          	beq	a5,s0,ffffffffc0205814 <do_wait.part.1+0x160>
ffffffffc020573e:	000a7797          	auipc	a5,0xa7
ffffffffc0205742:	d3a78793          	addi	a5,a5,-710 # ffffffffc02ac478 <initproc>
ffffffffc0205746:	639c                	ld	a5,0(a5)
ffffffffc0205748:	0cf40663          	beq	s0,a5,ffffffffc0205814 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc020574c:	000b0663          	beqz	s6,ffffffffc0205758 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205750:	0e842783          	lw	a5,232(s0)
ffffffffc0205754:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205758:	100027f3          	csrr	a5,sstatus
ffffffffc020575c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020575e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205760:	e7d5                	bnez	a5,ffffffffc020580c <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205762:	6c70                	ld	a2,216(s0)
ffffffffc0205764:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205766:	10043703          	ld	a4,256(s0)
ffffffffc020576a:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020576c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020576e:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205770:	6470                	ld	a2,200(s0)
ffffffffc0205772:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205774:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205776:	e290                	sd	a2,0(a3)
ffffffffc0205778:	c319                	beqz	a4,ffffffffc020577e <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020577a:	ff7c                	sd	a5,248(a4)
ffffffffc020577c:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc020577e:	c3d1                	beqz	a5,ffffffffc0205802 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205780:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205784:	000a7797          	auipc	a5,0xa7
ffffffffc0205788:	cfc78793          	addi	a5,a5,-772 # ffffffffc02ac480 <nr_process>
ffffffffc020578c:	439c                	lw	a5,0(a5)
ffffffffc020578e:	37fd                	addiw	a5,a5,-1
ffffffffc0205790:	000a7717          	auipc	a4,0xa7
ffffffffc0205794:	cef72823          	sw	a5,-784(a4) # ffffffffc02ac480 <nr_process>
    if (flag) {
ffffffffc0205798:	e1b5                	bnez	a1,ffffffffc02057fc <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020579a:	6814                	ld	a3,16(s0)
ffffffffc020579c:	c02007b7          	lui	a5,0xc0200
ffffffffc02057a0:	0af6e263          	bltu	a3,a5,ffffffffc0205844 <do_wait.part.1+0x190>
ffffffffc02057a4:	000a7797          	auipc	a5,0xa7
ffffffffc02057a8:	d0c78793          	addi	a5,a5,-756 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc02057ac:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02057ae:	000a7797          	auipc	a5,0xa7
ffffffffc02057b2:	ca278793          	addi	a5,a5,-862 # ffffffffc02ac450 <npage>
ffffffffc02057b6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02057b8:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02057ba:	82b1                	srli	a3,a3,0xc
ffffffffc02057bc:	06f6f863          	bleu	a5,a3,ffffffffc020582c <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc02057c0:	00003797          	auipc	a5,0x3
ffffffffc02057c4:	72878793          	addi	a5,a5,1832 # ffffffffc0208ee8 <nbase>
ffffffffc02057c8:	639c                	ld	a5,0(a5)
ffffffffc02057ca:	000a7717          	auipc	a4,0xa7
ffffffffc02057ce:	cf670713          	addi	a4,a4,-778 # ffffffffc02ac4c0 <pages>
ffffffffc02057d2:	6308                	ld	a0,0(a4)
ffffffffc02057d4:	8e9d                	sub	a3,a3,a5
ffffffffc02057d6:	069a                	slli	a3,a3,0x6
ffffffffc02057d8:	9536                	add	a0,a0,a3
ffffffffc02057da:	4589                	li	a1,2
ffffffffc02057dc:	efefc0ef          	jal	ra,ffffffffc0201eda <free_pages>
    kfree(proc);
ffffffffc02057e0:	8522                	mv	a0,s0
ffffffffc02057e2:	d30fc0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return 0;
ffffffffc02057e6:	4501                	li	a0,0
}
ffffffffc02057e8:	70e2                	ld	ra,56(sp)
ffffffffc02057ea:	7442                	ld	s0,48(sp)
ffffffffc02057ec:	74a2                	ld	s1,40(sp)
ffffffffc02057ee:	7902                	ld	s2,32(sp)
ffffffffc02057f0:	69e2                	ld	s3,24(sp)
ffffffffc02057f2:	6a42                	ld	s4,16(sp)
ffffffffc02057f4:	6aa2                	ld	s5,8(sp)
ffffffffc02057f6:	6b02                	ld	s6,0(sp)
ffffffffc02057f8:	6121                	addi	sp,sp,64
ffffffffc02057fa:	8082                	ret
        intr_enable();
ffffffffc02057fc:	e59fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205800:	bf69                	j	ffffffffc020579a <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205802:	701c                	ld	a5,32(s0)
ffffffffc0205804:	fbf8                	sd	a4,240(a5)
ffffffffc0205806:	bfbd                	j	ffffffffc0205784 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205808:	5579                	li	a0,-2
ffffffffc020580a:	bff9                	j	ffffffffc02057e8 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc020580c:	e4ffa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205810:	4585                	li	a1,1
ffffffffc0205812:	bf81                	j	ffffffffc0205762 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205814:	00003617          	auipc	a2,0x3
ffffffffc0205818:	fc460613          	addi	a2,a2,-60 # ffffffffc02087d8 <default_pmm_manager+0x12e0>
ffffffffc020581c:	30500593          	li	a1,773
ffffffffc0205820:	00003517          	auipc	a0,0x3
ffffffffc0205824:	20050513          	addi	a0,a0,512 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205828:	c5dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020582c:	00002617          	auipc	a2,0x2
ffffffffc0205830:	d7c60613          	addi	a2,a2,-644 # ffffffffc02075a8 <default_pmm_manager+0xb0>
ffffffffc0205834:	06200593          	li	a1,98
ffffffffc0205838:	00002517          	auipc	a0,0x2
ffffffffc020583c:	d3850513          	addi	a0,a0,-712 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0205840:	c45fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205844:	00002617          	auipc	a2,0x2
ffffffffc0205848:	d3c60613          	addi	a2,a2,-708 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc020584c:	06e00593          	li	a1,110
ffffffffc0205850:	00002517          	auipc	a0,0x2
ffffffffc0205854:	d2050513          	addi	a0,a0,-736 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0205858:	c2dfa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020585c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020585c:	1141                	addi	sp,sp,-16
ffffffffc020585e:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205860:	ec0fc0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205864:	beefc0ef          	jal	ra,ffffffffc0201c52 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205868:	4601                	li	a2,0
ffffffffc020586a:	4581                	li	a1,0
ffffffffc020586c:	fffff517          	auipc	a0,0xfffff
ffffffffc0205870:	64c50513          	addi	a0,a0,1612 # ffffffffc0204eb8 <user_main>
ffffffffc0205874:	ca3ff0ef          	jal	ra,ffffffffc0205516 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205878:	00a04563          	bgtz	a0,ffffffffc0205882 <init_main+0x26>
ffffffffc020587c:	a841                	j	ffffffffc020590c <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020587e:	0ef000ef          	jal	ra,ffffffffc020616c <schedule>
    if (code_store != NULL) {
ffffffffc0205882:	4581                	li	a1,0
ffffffffc0205884:	4501                	li	a0,0
ffffffffc0205886:	e2fff0ef          	jal	ra,ffffffffc02056b4 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc020588a:	d975                	beqz	a0,ffffffffc020587e <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020588c:	00003517          	auipc	a0,0x3
ffffffffc0205890:	f8c50513          	addi	a0,a0,-116 # ffffffffc0208818 <default_pmm_manager+0x1320>
ffffffffc0205894:	8fbfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205898:	000a7797          	auipc	a5,0xa7
ffffffffc020589c:	be078793          	addi	a5,a5,-1056 # ffffffffc02ac478 <initproc>
ffffffffc02058a0:	639c                	ld	a5,0(a5)
ffffffffc02058a2:	7bf8                	ld	a4,240(a5)
ffffffffc02058a4:	e721                	bnez	a4,ffffffffc02058ec <init_main+0x90>
ffffffffc02058a6:	7ff8                	ld	a4,248(a5)
ffffffffc02058a8:	e331                	bnez	a4,ffffffffc02058ec <init_main+0x90>
ffffffffc02058aa:	1007b703          	ld	a4,256(a5)
ffffffffc02058ae:	ef1d                	bnez	a4,ffffffffc02058ec <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02058b0:	000a7717          	auipc	a4,0xa7
ffffffffc02058b4:	bd070713          	addi	a4,a4,-1072 # ffffffffc02ac480 <nr_process>
ffffffffc02058b8:	4314                	lw	a3,0(a4)
ffffffffc02058ba:	4709                	li	a4,2
ffffffffc02058bc:	0ae69463          	bne	a3,a4,ffffffffc0205964 <init_main+0x108>
    return listelm->next;
ffffffffc02058c0:	000a7697          	auipc	a3,0xa7
ffffffffc02058c4:	ce868693          	addi	a3,a3,-792 # ffffffffc02ac5a8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02058c8:	6698                	ld	a4,8(a3)
ffffffffc02058ca:	0c878793          	addi	a5,a5,200
ffffffffc02058ce:	06f71b63          	bne	a4,a5,ffffffffc0205944 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02058d2:	629c                	ld	a5,0(a3)
ffffffffc02058d4:	04f71863          	bne	a4,a5,ffffffffc0205924 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02058d8:	00003517          	auipc	a0,0x3
ffffffffc02058dc:	02850513          	addi	a0,a0,40 # ffffffffc0208900 <default_pmm_manager+0x1408>
ffffffffc02058e0:	8affa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02058e4:	60a2                	ld	ra,8(sp)
ffffffffc02058e6:	4501                	li	a0,0
ffffffffc02058e8:	0141                	addi	sp,sp,16
ffffffffc02058ea:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058ec:	00003697          	auipc	a3,0x3
ffffffffc02058f0:	f5468693          	addi	a3,a3,-172 # ffffffffc0208840 <default_pmm_manager+0x1348>
ffffffffc02058f4:	00001617          	auipc	a2,0x1
ffffffffc02058f8:	4bc60613          	addi	a2,a2,1212 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc02058fc:	36a00593          	li	a1,874
ffffffffc0205900:	00003517          	auipc	a0,0x3
ffffffffc0205904:	12050513          	addi	a0,a0,288 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205908:	b7dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc020590c:	00003617          	auipc	a2,0x3
ffffffffc0205910:	eec60613          	addi	a2,a2,-276 # ffffffffc02087f8 <default_pmm_manager+0x1300>
ffffffffc0205914:	36200593          	li	a1,866
ffffffffc0205918:	00003517          	auipc	a0,0x3
ffffffffc020591c:	10850513          	addi	a0,a0,264 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205920:	b65fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205924:	00003697          	auipc	a3,0x3
ffffffffc0205928:	fac68693          	addi	a3,a3,-84 # ffffffffc02088d0 <default_pmm_manager+0x13d8>
ffffffffc020592c:	00001617          	auipc	a2,0x1
ffffffffc0205930:	48460613          	addi	a2,a2,1156 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205934:	36d00593          	li	a1,877
ffffffffc0205938:	00003517          	auipc	a0,0x3
ffffffffc020593c:	0e850513          	addi	a0,a0,232 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205940:	b45fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205944:	00003697          	auipc	a3,0x3
ffffffffc0205948:	f5c68693          	addi	a3,a3,-164 # ffffffffc02088a0 <default_pmm_manager+0x13a8>
ffffffffc020594c:	00001617          	auipc	a2,0x1
ffffffffc0205950:	46460613          	addi	a2,a2,1124 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205954:	36c00593          	li	a1,876
ffffffffc0205958:	00003517          	auipc	a0,0x3
ffffffffc020595c:	0c850513          	addi	a0,a0,200 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205960:	b25fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc0205964:	00003697          	auipc	a3,0x3
ffffffffc0205968:	f2c68693          	addi	a3,a3,-212 # ffffffffc0208890 <default_pmm_manager+0x1398>
ffffffffc020596c:	00001617          	auipc	a2,0x1
ffffffffc0205970:	44460613          	addi	a2,a2,1092 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205974:	36b00593          	li	a1,875
ffffffffc0205978:	00003517          	auipc	a0,0x3
ffffffffc020597c:	0a850513          	addi	a0,a0,168 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205980:	b05fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205984 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205984:	7135                	addi	sp,sp,-160
ffffffffc0205986:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205988:	000a7a17          	auipc	s4,0xa7
ffffffffc020598c:	ae0a0a13          	addi	s4,s4,-1312 # ffffffffc02ac468 <current>
ffffffffc0205990:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205994:	e14a                	sd	s2,128(sp)
ffffffffc0205996:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205998:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020599c:	fcce                	sd	s3,120(sp)
ffffffffc020599e:	f0da                	sd	s6,96(sp)
ffffffffc02059a0:	89aa                	mv	s3,a0
ffffffffc02059a2:	842e                	mv	s0,a1
ffffffffc02059a4:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059a6:	4681                	li	a3,0
ffffffffc02059a8:	862e                	mv	a2,a1
ffffffffc02059aa:	85aa                	mv	a1,a0
ffffffffc02059ac:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059ae:	ed06                	sd	ra,152(sp)
ffffffffc02059b0:	e526                	sd	s1,136(sp)
ffffffffc02059b2:	f4d6                	sd	s5,104(sp)
ffffffffc02059b4:	ecde                	sd	s7,88(sp)
ffffffffc02059b6:	e8e2                	sd	s8,80(sp)
ffffffffc02059b8:	e4e6                	sd	s9,72(sp)
ffffffffc02059ba:	e0ea                	sd	s10,64(sp)
ffffffffc02059bc:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059be:	a72ff0ef          	jal	ra,ffffffffc0204c30 <user_mem_check>
ffffffffc02059c2:	40050663          	beqz	a0,ffffffffc0205dce <do_execve+0x44a>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02059c6:	4641                	li	a2,16
ffffffffc02059c8:	4581                	li	a1,0
ffffffffc02059ca:	1008                	addi	a0,sp,32
ffffffffc02059cc:	5c5000ef          	jal	ra,ffffffffc0206790 <memset>
    memcpy(local_name, name, len);
ffffffffc02059d0:	47bd                	li	a5,15
ffffffffc02059d2:	8622                	mv	a2,s0
ffffffffc02059d4:	0687ee63          	bltu	a5,s0,ffffffffc0205a50 <do_execve+0xcc>
ffffffffc02059d8:	85ce                	mv	a1,s3
ffffffffc02059da:	1008                	addi	a0,sp,32
ffffffffc02059dc:	5c7000ef          	jal	ra,ffffffffc02067a2 <memcpy>
    if (mm != NULL) {
ffffffffc02059e0:	06090f63          	beqz	s2,ffffffffc0205a5e <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02059e4:	00002517          	auipc	a0,0x2
ffffffffc02059e8:	33450513          	addi	a0,a0,820 # ffffffffc0207d18 <default_pmm_manager+0x820>
ffffffffc02059ec:	fdafa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3);
ffffffffc02059f0:	000a7797          	auipc	a5,0xa7
ffffffffc02059f4:	ac878793          	addi	a5,a5,-1336 # ffffffffc02ac4b8 <boot_cr3>
ffffffffc02059f8:	639c                	ld	a5,0(a5)
ffffffffc02059fa:	577d                	li	a4,-1
ffffffffc02059fc:	177e                	slli	a4,a4,0x3f
ffffffffc02059fe:	83b1                	srli	a5,a5,0xc
ffffffffc0205a00:	8fd9                	or	a5,a5,a4
ffffffffc0205a02:	18079073          	csrw	satp,a5
ffffffffc0205a06:	03092783          	lw	a5,48(s2)
ffffffffc0205a0a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205a0e:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205a12:	28070d63          	beqz	a4,ffffffffc0205cac <do_execve+0x328>
        current->mm = NULL;
ffffffffc0205a16:	000a3783          	ld	a5,0(s4)
ffffffffc0205a1a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205a1e:	f26fe0ef          	jal	ra,ffffffffc0204144 <mm_create>
ffffffffc0205a22:	892a                	mv	s2,a0
ffffffffc0205a24:	c135                	beqz	a0,ffffffffc0205a88 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205a26:	d92ff0ef          	jal	ra,ffffffffc0204fb8 <setup_pgdir>
ffffffffc0205a2a:	e931                	bnez	a0,ffffffffc0205a7e <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a2c:	000b2703          	lw	a4,0(s6)
ffffffffc0205a30:	464c47b7          	lui	a5,0x464c4
ffffffffc0205a34:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aff>
ffffffffc0205a38:	04f70a63          	beq	a4,a5,ffffffffc0205a8c <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205a3c:	854a                	mv	a0,s2
ffffffffc0205a3e:	cfcff0ef          	jal	ra,ffffffffc0204f3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a42:	854a                	mv	a0,s2
ffffffffc0205a44:	887fe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a48:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205a4a:	854e                	mv	a0,s3
ffffffffc0205a4c:	b1bff0ef          	jal	ra,ffffffffc0205566 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205a50:	463d                	li	a2,15
ffffffffc0205a52:	85ce                	mv	a1,s3
ffffffffc0205a54:	1008                	addi	a0,sp,32
ffffffffc0205a56:	54d000ef          	jal	ra,ffffffffc02067a2 <memcpy>
    if (mm != NULL) {
ffffffffc0205a5a:	f80915e3          	bnez	s2,ffffffffc02059e4 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205a5e:	000a3783          	ld	a5,0(s4)
ffffffffc0205a62:	779c                	ld	a5,40(a5)
ffffffffc0205a64:	dfcd                	beqz	a5,ffffffffc0205a1e <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205a66:	00003617          	auipc	a2,0x3
ffffffffc0205a6a:	b6260613          	addi	a2,a2,-1182 # ffffffffc02085c8 <default_pmm_manager+0x10d0>
ffffffffc0205a6e:	21700593          	li	a1,535
ffffffffc0205a72:	00003517          	auipc	a0,0x3
ffffffffc0205a76:	fae50513          	addi	a0,a0,-82 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205a7a:	a0bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    mm_destroy(mm);
ffffffffc0205a7e:	854a                	mv	a0,s2
ffffffffc0205a80:	84bfe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205a84:	59f1                	li	s3,-4
ffffffffc0205a86:	b7d1                	j	ffffffffc0205a4a <do_execve+0xc6>
ffffffffc0205a88:	59f1                	li	s3,-4
ffffffffc0205a8a:	b7c1                	j	ffffffffc0205a4a <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a8c:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a90:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a94:	00371793          	slli	a5,a4,0x3
ffffffffc0205a98:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a9a:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a9c:	078e                	slli	a5,a5,0x3
ffffffffc0205a9e:	97a2                	add	a5,a5,s0
ffffffffc0205aa0:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205aa2:	02f47b63          	bleu	a5,s0,ffffffffc0205ad8 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205aa6:	5bfd                	li	s7,-1
ffffffffc0205aa8:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205aac:	000a7d97          	auipc	s11,0xa7
ffffffffc0205ab0:	a14d8d93          	addi	s11,s11,-1516 # ffffffffc02ac4c0 <pages>
ffffffffc0205ab4:	00003d17          	auipc	s10,0x3
ffffffffc0205ab8:	434d0d13          	addi	s10,s10,1076 # ffffffffc0208ee8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205abc:	e43e                	sd	a5,8(sp)
ffffffffc0205abe:	000a7c97          	auipc	s9,0xa7
ffffffffc0205ac2:	992c8c93          	addi	s9,s9,-1646 # ffffffffc02ac450 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205ac6:	4018                	lw	a4,0(s0)
ffffffffc0205ac8:	4785                	li	a5,1
ffffffffc0205aca:	0ef70f63          	beq	a4,a5,ffffffffc0205bc8 <do_execve+0x244>
    for (; ph < ph_end; ph ++) {
ffffffffc0205ace:	67e2                	ld	a5,24(sp)
ffffffffc0205ad0:	03840413          	addi	s0,s0,56
ffffffffc0205ad4:	fef469e3          	bltu	s0,a5,ffffffffc0205ac6 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205ad8:	4701                	li	a4,0
ffffffffc0205ada:	46ad                	li	a3,11
ffffffffc0205adc:	00100637          	lui	a2,0x100
ffffffffc0205ae0:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205ae4:	854a                	mv	a0,s2
ffffffffc0205ae6:	837fe0ef          	jal	ra,ffffffffc020431c <mm_map>
ffffffffc0205aea:	89aa                	mv	s3,a0
ffffffffc0205aec:	1a051663          	bnez	a0,ffffffffc0205c98 <do_execve+0x314>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205af0:	01893503          	ld	a0,24(s2)
ffffffffc0205af4:	467d                	li	a2,31
ffffffffc0205af6:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205afa:	87dfd0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
ffffffffc0205afe:	36050463          	beqz	a0,ffffffffc0205e66 <do_execve+0x4e2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b02:	01893503          	ld	a0,24(s2)
ffffffffc0205b06:	467d                	li	a2,31
ffffffffc0205b08:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205b0c:	86bfd0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
ffffffffc0205b10:	32050b63          	beqz	a0,ffffffffc0205e46 <do_execve+0x4c2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b14:	01893503          	ld	a0,24(s2)
ffffffffc0205b18:	467d                	li	a2,31
ffffffffc0205b1a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205b1e:	859fd0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
ffffffffc0205b22:	30050263          	beqz	a0,ffffffffc0205e26 <do_execve+0x4a2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b26:	01893503          	ld	a0,24(s2)
ffffffffc0205b2a:	467d                	li	a2,31
ffffffffc0205b2c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205b30:	847fd0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
ffffffffc0205b34:	2c050963          	beqz	a0,ffffffffc0205e06 <do_execve+0x482>
    mm->mm_count += 1;
ffffffffc0205b38:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205b3c:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b40:	01893683          	ld	a3,24(s2)
ffffffffc0205b44:	2785                	addiw	a5,a5,1
ffffffffc0205b46:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205b4a:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55a8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b52:	28f6ee63          	bltu	a3,a5,ffffffffc0205dee <do_execve+0x46a>
ffffffffc0205b56:	000a7797          	auipc	a5,0xa7
ffffffffc0205b5a:	95a78793          	addi	a5,a5,-1702 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0205b5e:	639c                	ld	a5,0(a5)
ffffffffc0205b60:	577d                	li	a4,-1
ffffffffc0205b62:	177e                	slli	a4,a4,0x3f
ffffffffc0205b64:	8e9d                	sub	a3,a3,a5
ffffffffc0205b66:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205b6a:	f654                	sd	a3,168(a2)
ffffffffc0205b6c:	8fd9                	or	a5,a5,a4
ffffffffc0205b6e:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205b72:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b74:	4581                	li	a1,0
ffffffffc0205b76:	12000613          	li	a2,288
ffffffffc0205b7a:	8522                	mv	a0,s0
ffffffffc0205b7c:	415000ef          	jal	ra,ffffffffc0206790 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205b80:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b84:	4785                	li	a5,1
ffffffffc0205b86:	07fe                	slli	a5,a5,0x1f
ffffffffc0205b88:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205b8a:	10e43423          	sd	a4,264(s0)
    tf->status = (read_csr(sstatus) | SSTATUS_SPIE ) & ~SSTATUS_SPP;
ffffffffc0205b8e:	100027f3          	csrr	a5,sstatus
ffffffffc0205b92:	edf7f793          	andi	a5,a5,-289
    set_proc_name(current, local_name);
ffffffffc0205b96:	000a3503          	ld	a0,0(s4)
    tf->status = (read_csr(sstatus) | SSTATUS_SPIE ) & ~SSTATUS_SPP;
ffffffffc0205b9a:	0207e793          	ori	a5,a5,32
ffffffffc0205b9e:	10f43023          	sd	a5,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205ba2:	100c                	addi	a1,sp,32
ffffffffc0205ba4:	ca0ff0ef          	jal	ra,ffffffffc0205044 <set_proc_name>
}
ffffffffc0205ba8:	60ea                	ld	ra,152(sp)
ffffffffc0205baa:	644a                	ld	s0,144(sp)
ffffffffc0205bac:	854e                	mv	a0,s3
ffffffffc0205bae:	64aa                	ld	s1,136(sp)
ffffffffc0205bb0:	690a                	ld	s2,128(sp)
ffffffffc0205bb2:	79e6                	ld	s3,120(sp)
ffffffffc0205bb4:	7a46                	ld	s4,112(sp)
ffffffffc0205bb6:	7aa6                	ld	s5,104(sp)
ffffffffc0205bb8:	7b06                	ld	s6,96(sp)
ffffffffc0205bba:	6be6                	ld	s7,88(sp)
ffffffffc0205bbc:	6c46                	ld	s8,80(sp)
ffffffffc0205bbe:	6ca6                	ld	s9,72(sp)
ffffffffc0205bc0:	6d06                	ld	s10,64(sp)
ffffffffc0205bc2:	7de2                	ld	s11,56(sp)
ffffffffc0205bc4:	610d                	addi	sp,sp,160
ffffffffc0205bc6:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205bc8:	7410                	ld	a2,40(s0)
ffffffffc0205bca:	701c                	ld	a5,32(s0)
ffffffffc0205bcc:	20f66363          	bltu	a2,a5,ffffffffc0205dd2 <do_execve+0x44e>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bd0:	405c                	lw	a5,4(s0)
ffffffffc0205bd2:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bd6:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bda:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bdc:	0e071263          	bnez	a4,ffffffffc0205cc0 <do_execve+0x33c>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205be0:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205be2:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205be4:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205be6:	c789                	beqz	a5,ffffffffc0205bf0 <do_execve+0x26c>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205be8:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bea:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205bee:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205bf0:	0026f793          	andi	a5,a3,2
ffffffffc0205bf4:	efe1                	bnez	a5,ffffffffc0205ccc <do_execve+0x348>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205bf6:	0046f793          	andi	a5,a3,4
ffffffffc0205bfa:	c789                	beqz	a5,ffffffffc0205c04 <do_execve+0x280>
ffffffffc0205bfc:	6782                	ld	a5,0(sp)
ffffffffc0205bfe:	0087e793          	ori	a5,a5,8
ffffffffc0205c02:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205c04:	680c                	ld	a1,16(s0)
ffffffffc0205c06:	4701                	li	a4,0
ffffffffc0205c08:	854a                	mv	a0,s2
ffffffffc0205c0a:	f12fe0ef          	jal	ra,ffffffffc020431c <mm_map>
ffffffffc0205c0e:	89aa                	mv	s3,a0
ffffffffc0205c10:	e541                	bnez	a0,ffffffffc0205c98 <do_execve+0x314>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c12:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c16:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c1a:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c1e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c20:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c22:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c24:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205c28:	053bef63          	bltu	s7,s3,ffffffffc0205c86 <do_execve+0x302>
ffffffffc0205c2c:	aa79                	j	ffffffffc0205dca <do_execve+0x446>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c2e:	6785                	lui	a5,0x1
ffffffffc0205c30:	418b8533          	sub	a0,s7,s8
ffffffffc0205c34:	9c3e                	add	s8,s8,a5
ffffffffc0205c36:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205c3a:	0189f463          	bleu	s8,s3,ffffffffc0205c42 <do_execve+0x2be>
                size -= la - end;
ffffffffc0205c3e:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205c42:	000db683          	ld	a3,0(s11)
ffffffffc0205c46:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c4a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c4c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c50:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c52:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205c56:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205c58:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c5c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c5e:	16c5fc63          	bleu	a2,a1,ffffffffc0205dd6 <do_execve+0x452>
ffffffffc0205c62:	000a7797          	auipc	a5,0xa7
ffffffffc0205c66:	84e78793          	addi	a5,a5,-1970 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0205c6a:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c6e:	85d6                	mv	a1,s5
ffffffffc0205c70:	8642                	mv	a2,a6
ffffffffc0205c72:	96c6                	add	a3,a3,a7
ffffffffc0205c74:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205c76:	9bc2                	add	s7,s7,a6
ffffffffc0205c78:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c7a:	329000ef          	jal	ra,ffffffffc02067a2 <memcpy>
            start += size, from += size;
ffffffffc0205c7e:	6842                	ld	a6,16(sp)
ffffffffc0205c80:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205c82:	053bf863          	bleu	s3,s7,ffffffffc0205cd2 <do_execve+0x34e>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c86:	01893503          	ld	a0,24(s2)
ffffffffc0205c8a:	6602                	ld	a2,0(sp)
ffffffffc0205c8c:	85e2                	mv	a1,s8
ffffffffc0205c8e:	ee8fd0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
ffffffffc0205c92:	84aa                	mv	s1,a0
ffffffffc0205c94:	fd49                	bnez	a0,ffffffffc0205c2e <do_execve+0x2aa>
        ret = -E_NO_MEM;
ffffffffc0205c96:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205c98:	854a                	mv	a0,s2
ffffffffc0205c9a:	fd0fe0ef          	jal	ra,ffffffffc020446a <exit_mmap>
    put_pgdir(mm);
ffffffffc0205c9e:	854a                	mv	a0,s2
ffffffffc0205ca0:	a9aff0ef          	jal	ra,ffffffffc0204f3a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ca4:	854a                	mv	a0,s2
ffffffffc0205ca6:	e24fe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
    return ret;
ffffffffc0205caa:	b345                	j	ffffffffc0205a4a <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205cac:	854a                	mv	a0,s2
ffffffffc0205cae:	fbcfe0ef          	jal	ra,ffffffffc020446a <exit_mmap>
            put_pgdir(mm);
ffffffffc0205cb2:	854a                	mv	a0,s2
ffffffffc0205cb4:	a86ff0ef          	jal	ra,ffffffffc0204f3a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205cb8:	854a                	mv	a0,s2
ffffffffc0205cba:	e10fe0ef          	jal	ra,ffffffffc02042ca <mm_destroy>
ffffffffc0205cbe:	bba1                	j	ffffffffc0205a16 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205cc0:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205cc4:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205cc6:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205cc8:	f20790e3          	bnez	a5,ffffffffc0205be8 <do_execve+0x264>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ccc:	47dd                	li	a5,23
ffffffffc0205cce:	e03e                	sd	a5,0(sp)
ffffffffc0205cd0:	b71d                	j	ffffffffc0205bf6 <do_execve+0x272>
ffffffffc0205cd2:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205cd6:	7414                	ld	a3,40(s0)
ffffffffc0205cd8:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205cda:	098bf163          	bleu	s8,s7,ffffffffc0205d5c <do_execve+0x3d8>
            if (start == end) {
ffffffffc0205cde:	df7988e3          	beq	s3,s7,ffffffffc0205ace <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205ce2:	6505                	lui	a0,0x1
ffffffffc0205ce4:	955e                	add	a0,a0,s7
ffffffffc0205ce6:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205cea:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205cee:	0d89fb63          	bleu	s8,s3,ffffffffc0205dc4 <do_execve+0x440>
    return page - pages + nbase;
ffffffffc0205cf2:	000db683          	ld	a3,0(s11)
ffffffffc0205cf6:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205cfa:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205cfc:	40d486b3          	sub	a3,s1,a3
ffffffffc0205d00:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205d02:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205d06:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205d08:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d0c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d0e:	0cc5f463          	bleu	a2,a1,ffffffffc0205dd6 <do_execve+0x452>
ffffffffc0205d12:	000a6617          	auipc	a2,0xa6
ffffffffc0205d16:	79e60613          	addi	a2,a2,1950 # ffffffffc02ac4b0 <va_pa_offset>
ffffffffc0205d1a:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d1e:	4581                	li	a1,0
ffffffffc0205d20:	8656                	mv	a2,s5
ffffffffc0205d22:	96c2                	add	a3,a3,a6
ffffffffc0205d24:	9536                	add	a0,a0,a3
ffffffffc0205d26:	26b000ef          	jal	ra,ffffffffc0206790 <memset>
            start += size;
ffffffffc0205d2a:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d2e:	0389f463          	bleu	s8,s3,ffffffffc0205d56 <do_execve+0x3d2>
ffffffffc0205d32:	d8e98ee3          	beq	s3,a4,ffffffffc0205ace <do_execve+0x14a>
ffffffffc0205d36:	00003697          	auipc	a3,0x3
ffffffffc0205d3a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02085f0 <default_pmm_manager+0x10f8>
ffffffffc0205d3e:	00001617          	auipc	a2,0x1
ffffffffc0205d42:	07260613          	addi	a2,a2,114 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205d46:	26c00593          	li	a1,620
ffffffffc0205d4a:	00003517          	auipc	a0,0x3
ffffffffc0205d4e:	cd650513          	addi	a0,a0,-810 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205d52:	f32fa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0205d56:	ff8710e3          	bne	a4,s8,ffffffffc0205d36 <do_execve+0x3b2>
ffffffffc0205d5a:	8be2                	mv	s7,s8
ffffffffc0205d5c:	000a6a97          	auipc	s5,0xa6
ffffffffc0205d60:	754a8a93          	addi	s5,s5,1876 # ffffffffc02ac4b0 <va_pa_offset>
        while (start < end) {
ffffffffc0205d64:	053be763          	bltu	s7,s3,ffffffffc0205db2 <do_execve+0x42e>
ffffffffc0205d68:	b39d                	j	ffffffffc0205ace <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205d6a:	6785                	lui	a5,0x1
ffffffffc0205d6c:	418b8533          	sub	a0,s7,s8
ffffffffc0205d70:	9c3e                	add	s8,s8,a5
ffffffffc0205d72:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205d76:	0189f463          	bleu	s8,s3,ffffffffc0205d7e <do_execve+0x3fa>
                size -= la - end;
ffffffffc0205d7a:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205d7e:	000db683          	ld	a3,0(s11)
ffffffffc0205d82:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205d86:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205d88:	40d486b3          	sub	a3,s1,a3
ffffffffc0205d8c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205d8e:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205d92:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205d94:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d98:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d9a:	02b87e63          	bleu	a1,a6,ffffffffc0205dd6 <do_execve+0x452>
ffffffffc0205d9e:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205da2:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205da4:	4581                	li	a1,0
ffffffffc0205da6:	96c2                	add	a3,a3,a6
ffffffffc0205da8:	9536                	add	a0,a0,a3
ffffffffc0205daa:	1e7000ef          	jal	ra,ffffffffc0206790 <memset>
        while (start < end) {
ffffffffc0205dae:	d33bf0e3          	bleu	s3,s7,ffffffffc0205ace <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205db2:	01893503          	ld	a0,24(s2)
ffffffffc0205db6:	6602                	ld	a2,0(sp)
ffffffffc0205db8:	85e2                	mv	a1,s8
ffffffffc0205dba:	dbcfd0ef          	jal	ra,ffffffffc0203376 <pgdir_alloc_page>
ffffffffc0205dbe:	84aa                	mv	s1,a0
ffffffffc0205dc0:	f54d                	bnez	a0,ffffffffc0205d6a <do_execve+0x3e6>
ffffffffc0205dc2:	bdd1                	j	ffffffffc0205c96 <do_execve+0x312>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205dc4:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205dc8:	b72d                	j	ffffffffc0205cf2 <do_execve+0x36e>
        while (start < end) {
ffffffffc0205dca:	89de                	mv	s3,s7
ffffffffc0205dcc:	b729                	j	ffffffffc0205cd6 <do_execve+0x352>
        return -E_INVAL;
ffffffffc0205dce:	59f5                	li	s3,-3
ffffffffc0205dd0:	bbe1                	j	ffffffffc0205ba8 <do_execve+0x224>
            ret = -E_INVAL_ELF;
ffffffffc0205dd2:	59e1                	li	s3,-8
ffffffffc0205dd4:	b5d1                	j	ffffffffc0205c98 <do_execve+0x314>
ffffffffc0205dd6:	00001617          	auipc	a2,0x1
ffffffffc0205dda:	77260613          	addi	a2,a2,1906 # ffffffffc0207548 <default_pmm_manager+0x50>
ffffffffc0205dde:	06900593          	li	a1,105
ffffffffc0205de2:	00001517          	auipc	a0,0x1
ffffffffc0205de6:	78e50513          	addi	a0,a0,1934 # ffffffffc0207570 <default_pmm_manager+0x78>
ffffffffc0205dea:	e9afa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205dee:	00001617          	auipc	a2,0x1
ffffffffc0205df2:	79260613          	addi	a2,a2,1938 # ffffffffc0207580 <default_pmm_manager+0x88>
ffffffffc0205df6:	28700593          	li	a1,647
ffffffffc0205dfa:	00003517          	auipc	a0,0x3
ffffffffc0205dfe:	c2650513          	addi	a0,a0,-986 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205e02:	e82fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e06:	00003697          	auipc	a3,0x3
ffffffffc0205e0a:	90268693          	addi	a3,a3,-1790 # ffffffffc0208708 <default_pmm_manager+0x1210>
ffffffffc0205e0e:	00001617          	auipc	a2,0x1
ffffffffc0205e12:	fa260613          	addi	a2,a2,-94 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205e16:	28200593          	li	a1,642
ffffffffc0205e1a:	00003517          	auipc	a0,0x3
ffffffffc0205e1e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205e22:	e62fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e26:	00003697          	auipc	a3,0x3
ffffffffc0205e2a:	89a68693          	addi	a3,a3,-1894 # ffffffffc02086c0 <default_pmm_manager+0x11c8>
ffffffffc0205e2e:	00001617          	auipc	a2,0x1
ffffffffc0205e32:	f8260613          	addi	a2,a2,-126 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205e36:	28100593          	li	a1,641
ffffffffc0205e3a:	00003517          	auipc	a0,0x3
ffffffffc0205e3e:	be650513          	addi	a0,a0,-1050 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205e42:	e42fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e46:	00003697          	auipc	a3,0x3
ffffffffc0205e4a:	83268693          	addi	a3,a3,-1998 # ffffffffc0208678 <default_pmm_manager+0x1180>
ffffffffc0205e4e:	00001617          	auipc	a2,0x1
ffffffffc0205e52:	f6260613          	addi	a2,a2,-158 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205e56:	28000593          	li	a1,640
ffffffffc0205e5a:	00003517          	auipc	a0,0x3
ffffffffc0205e5e:	bc650513          	addi	a0,a0,-1082 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205e62:	e22fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205e66:	00002697          	auipc	a3,0x2
ffffffffc0205e6a:	7ca68693          	addi	a3,a3,1994 # ffffffffc0208630 <default_pmm_manager+0x1138>
ffffffffc0205e6e:	00001617          	auipc	a2,0x1
ffffffffc0205e72:	f4260613          	addi	a2,a2,-190 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0205e76:	27f00593          	li	a1,639
ffffffffc0205e7a:	00003517          	auipc	a0,0x3
ffffffffc0205e7e:	ba650513          	addi	a0,a0,-1114 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0205e82:	e02fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205e86 <do_yield>:
    current->need_resched = 1;
ffffffffc0205e86:	000a6797          	auipc	a5,0xa6
ffffffffc0205e8a:	5e278793          	addi	a5,a5,1506 # ffffffffc02ac468 <current>
ffffffffc0205e8e:	639c                	ld	a5,0(a5)
ffffffffc0205e90:	4705                	li	a4,1
}
ffffffffc0205e92:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205e94:	ef98                	sd	a4,24(a5)
}
ffffffffc0205e96:	8082                	ret

ffffffffc0205e98 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205e98:	1101                	addi	sp,sp,-32
ffffffffc0205e9a:	e822                	sd	s0,16(sp)
ffffffffc0205e9c:	e426                	sd	s1,8(sp)
ffffffffc0205e9e:	ec06                	sd	ra,24(sp)
ffffffffc0205ea0:	842e                	mv	s0,a1
ffffffffc0205ea2:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ea4:	cd81                	beqz	a1,ffffffffc0205ebc <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205ea6:	000a6797          	auipc	a5,0xa6
ffffffffc0205eaa:	5c278793          	addi	a5,a5,1474 # ffffffffc02ac468 <current>
ffffffffc0205eae:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205eb0:	4685                	li	a3,1
ffffffffc0205eb2:	4611                	li	a2,4
ffffffffc0205eb4:	7788                	ld	a0,40(a5)
ffffffffc0205eb6:	d7bfe0ef          	jal	ra,ffffffffc0204c30 <user_mem_check>
ffffffffc0205eba:	c909                	beqz	a0,ffffffffc0205ecc <do_wait+0x34>
ffffffffc0205ebc:	85a2                	mv	a1,s0
}
ffffffffc0205ebe:	6442                	ld	s0,16(sp)
ffffffffc0205ec0:	60e2                	ld	ra,24(sp)
ffffffffc0205ec2:	8526                	mv	a0,s1
ffffffffc0205ec4:	64a2                	ld	s1,8(sp)
ffffffffc0205ec6:	6105                	addi	sp,sp,32
ffffffffc0205ec8:	fecff06f          	j	ffffffffc02056b4 <do_wait.part.1>
ffffffffc0205ecc:	60e2                	ld	ra,24(sp)
ffffffffc0205ece:	6442                	ld	s0,16(sp)
ffffffffc0205ed0:	64a2                	ld	s1,8(sp)
ffffffffc0205ed2:	5575                	li	a0,-3
ffffffffc0205ed4:	6105                	addi	sp,sp,32
ffffffffc0205ed6:	8082                	ret

ffffffffc0205ed8 <do_kill>:
do_kill(int pid) {
ffffffffc0205ed8:	1141                	addi	sp,sp,-16
ffffffffc0205eda:	e406                	sd	ra,8(sp)
ffffffffc0205edc:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205ede:	9feff0ef          	jal	ra,ffffffffc02050dc <find_proc>
ffffffffc0205ee2:	cd0d                	beqz	a0,ffffffffc0205f1c <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205ee4:	0b052703          	lw	a4,176(a0)
ffffffffc0205ee8:	00177693          	andi	a3,a4,1
ffffffffc0205eec:	e695                	bnez	a3,ffffffffc0205f18 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205eee:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205ef2:	00176713          	ori	a4,a4,1
ffffffffc0205ef6:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205efa:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205efc:	0006c763          	bltz	a3,ffffffffc0205f0a <do_kill+0x32>
}
ffffffffc0205f00:	8522                	mv	a0,s0
ffffffffc0205f02:	60a2                	ld	ra,8(sp)
ffffffffc0205f04:	6402                	ld	s0,0(sp)
ffffffffc0205f06:	0141                	addi	sp,sp,16
ffffffffc0205f08:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205f0a:	1e6000ef          	jal	ra,ffffffffc02060f0 <wakeup_proc>
}
ffffffffc0205f0e:	8522                	mv	a0,s0
ffffffffc0205f10:	60a2                	ld	ra,8(sp)
ffffffffc0205f12:	6402                	ld	s0,0(sp)
ffffffffc0205f14:	0141                	addi	sp,sp,16
ffffffffc0205f16:	8082                	ret
        return -E_KILLED;
ffffffffc0205f18:	545d                	li	s0,-9
ffffffffc0205f1a:	b7dd                	j	ffffffffc0205f00 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205f1c:	5475                	li	s0,-3
ffffffffc0205f1e:	b7cd                	j	ffffffffc0205f00 <do_kill+0x28>

ffffffffc0205f20 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205f20:	000a6797          	auipc	a5,0xa6
ffffffffc0205f24:	68878793          	addi	a5,a5,1672 # ffffffffc02ac5a8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205f28:	1101                	addi	sp,sp,-32
ffffffffc0205f2a:	000a6717          	auipc	a4,0xa6
ffffffffc0205f2e:	68f73323          	sd	a5,1670(a4) # ffffffffc02ac5b0 <proc_list+0x8>
ffffffffc0205f32:	000a6717          	auipc	a4,0xa6
ffffffffc0205f36:	66f73b23          	sd	a5,1654(a4) # ffffffffc02ac5a8 <proc_list>
ffffffffc0205f3a:	ec06                	sd	ra,24(sp)
ffffffffc0205f3c:	e822                	sd	s0,16(sp)
ffffffffc0205f3e:	e426                	sd	s1,8(sp)
ffffffffc0205f40:	000a2797          	auipc	a5,0xa2
ffffffffc0205f44:	4f078793          	addi	a5,a5,1264 # ffffffffc02a8430 <hash_list>
ffffffffc0205f48:	000a6717          	auipc	a4,0xa6
ffffffffc0205f4c:	4e870713          	addi	a4,a4,1256 # ffffffffc02ac430 <is_panic>
ffffffffc0205f50:	e79c                	sd	a5,8(a5)
ffffffffc0205f52:	e39c                	sd	a5,0(a5)
ffffffffc0205f54:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205f56:	fee79de3          	bne	a5,a4,ffffffffc0205f50 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205f5a:	edbfe0ef          	jal	ra,ffffffffc0204e34 <alloc_proc>
ffffffffc0205f5e:	000a6717          	auipc	a4,0xa6
ffffffffc0205f62:	50a73923          	sd	a0,1298(a4) # ffffffffc02ac470 <idleproc>
ffffffffc0205f66:	000a6497          	auipc	s1,0xa6
ffffffffc0205f6a:	50a48493          	addi	s1,s1,1290 # ffffffffc02ac470 <idleproc>
ffffffffc0205f6e:	c559                	beqz	a0,ffffffffc0205ffc <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205f70:	4709                	li	a4,2
ffffffffc0205f72:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205f74:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f76:	00003717          	auipc	a4,0x3
ffffffffc0205f7a:	08a70713          	addi	a4,a4,138 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205f7e:	00003597          	auipc	a1,0x3
ffffffffc0205f82:	9ba58593          	addi	a1,a1,-1606 # ffffffffc0208938 <default_pmm_manager+0x1440>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f86:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205f88:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205f8a:	8baff0ef          	jal	ra,ffffffffc0205044 <set_proc_name>
    nr_process ++;
ffffffffc0205f8e:	000a6797          	auipc	a5,0xa6
ffffffffc0205f92:	4f278793          	addi	a5,a5,1266 # ffffffffc02ac480 <nr_process>
ffffffffc0205f96:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205f98:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f9a:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205f9c:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f9e:	4581                	li	a1,0
ffffffffc0205fa0:	00000517          	auipc	a0,0x0
ffffffffc0205fa4:	8bc50513          	addi	a0,a0,-1860 # ffffffffc020585c <init_main>
    nr_process ++;
ffffffffc0205fa8:	000a6697          	auipc	a3,0xa6
ffffffffc0205fac:	4cf6ac23          	sw	a5,1240(a3) # ffffffffc02ac480 <nr_process>
    current = idleproc;
ffffffffc0205fb0:	000a6797          	auipc	a5,0xa6
ffffffffc0205fb4:	4ae7bc23          	sd	a4,1208(a5) # ffffffffc02ac468 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fb8:	d5eff0ef          	jal	ra,ffffffffc0205516 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205fbc:	08a05c63          	blez	a0,ffffffffc0206054 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205fc0:	91cff0ef          	jal	ra,ffffffffc02050dc <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205fc4:	00003597          	auipc	a1,0x3
ffffffffc0205fc8:	99c58593          	addi	a1,a1,-1636 # ffffffffc0208960 <default_pmm_manager+0x1468>
    initproc = find_proc(pid);
ffffffffc0205fcc:	000a6797          	auipc	a5,0xa6
ffffffffc0205fd0:	4aa7b623          	sd	a0,1196(a5) # ffffffffc02ac478 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205fd4:	870ff0ef          	jal	ra,ffffffffc0205044 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205fd8:	609c                	ld	a5,0(s1)
ffffffffc0205fda:	cfa9                	beqz	a5,ffffffffc0206034 <proc_init+0x114>
ffffffffc0205fdc:	43dc                	lw	a5,4(a5)
ffffffffc0205fde:	ebb9                	bnez	a5,ffffffffc0206034 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205fe0:	000a6797          	auipc	a5,0xa6
ffffffffc0205fe4:	49878793          	addi	a5,a5,1176 # ffffffffc02ac478 <initproc>
ffffffffc0205fe8:	639c                	ld	a5,0(a5)
ffffffffc0205fea:	c78d                	beqz	a5,ffffffffc0206014 <proc_init+0xf4>
ffffffffc0205fec:	43dc                	lw	a5,4(a5)
ffffffffc0205fee:	02879363          	bne	a5,s0,ffffffffc0206014 <proc_init+0xf4>
}
ffffffffc0205ff2:	60e2                	ld	ra,24(sp)
ffffffffc0205ff4:	6442                	ld	s0,16(sp)
ffffffffc0205ff6:	64a2                	ld	s1,8(sp)
ffffffffc0205ff8:	6105                	addi	sp,sp,32
ffffffffc0205ffa:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205ffc:	00003617          	auipc	a2,0x3
ffffffffc0206000:	92460613          	addi	a2,a2,-1756 # ffffffffc0208920 <default_pmm_manager+0x1428>
ffffffffc0206004:	37f00593          	li	a1,895
ffffffffc0206008:	00003517          	auipc	a0,0x3
ffffffffc020600c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0206010:	c74fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206014:	00003697          	auipc	a3,0x3
ffffffffc0206018:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208990 <default_pmm_manager+0x1498>
ffffffffc020601c:	00001617          	auipc	a2,0x1
ffffffffc0206020:	d9460613          	addi	a2,a2,-620 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0206024:	39400593          	li	a1,916
ffffffffc0206028:	00003517          	auipc	a0,0x3
ffffffffc020602c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0206030:	c54fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206034:	00003697          	auipc	a3,0x3
ffffffffc0206038:	93468693          	addi	a3,a3,-1740 # ffffffffc0208968 <default_pmm_manager+0x1470>
ffffffffc020603c:	00001617          	auipc	a2,0x1
ffffffffc0206040:	d7460613          	addi	a2,a2,-652 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc0206044:	39300593          	li	a1,915
ffffffffc0206048:	00003517          	auipc	a0,0x3
ffffffffc020604c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0206050:	c34fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0206054:	00003617          	auipc	a2,0x3
ffffffffc0206058:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0208940 <default_pmm_manager+0x1448>
ffffffffc020605c:	38d00593          	li	a1,909
ffffffffc0206060:	00003517          	auipc	a0,0x3
ffffffffc0206064:	9c050513          	addi	a0,a0,-1600 # ffffffffc0208a20 <default_pmm_manager+0x1528>
ffffffffc0206068:	c1cfa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020606c <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020606c:	1141                	addi	sp,sp,-16
ffffffffc020606e:	e022                	sd	s0,0(sp)
ffffffffc0206070:	e406                	sd	ra,8(sp)
ffffffffc0206072:	000a6417          	auipc	s0,0xa6
ffffffffc0206076:	3f640413          	addi	s0,s0,1014 # ffffffffc02ac468 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020607a:	6018                	ld	a4,0(s0)
ffffffffc020607c:	6f1c                	ld	a5,24(a4)
ffffffffc020607e:	dffd                	beqz	a5,ffffffffc020607c <cpu_idle+0x10>
            schedule();
ffffffffc0206080:	0ec000ef          	jal	ra,ffffffffc020616c <schedule>
ffffffffc0206084:	bfdd                	j	ffffffffc020607a <cpu_idle+0xe>

ffffffffc0206086 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0206086:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020608a:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020608e:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0206090:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0206092:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0206096:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020609a:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020609e:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02060a2:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02060a6:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02060aa:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02060ae:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02060b2:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02060b6:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02060ba:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02060be:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02060c2:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02060c4:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02060c6:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02060ca:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02060ce:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02060d2:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02060d6:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02060da:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02060de:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02060e2:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02060e6:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02060ea:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02060ee:	8082                	ret

ffffffffc02060f0 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060f0:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02060f2:	1101                	addi	sp,sp,-32
ffffffffc02060f4:	ec06                	sd	ra,24(sp)
ffffffffc02060f6:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060f8:	478d                	li	a5,3
ffffffffc02060fa:	04f70a63          	beq	a4,a5,ffffffffc020614e <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060fe:	100027f3          	csrr	a5,sstatus
ffffffffc0206102:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206104:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206106:	ef8d                	bnez	a5,ffffffffc0206140 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206108:	4789                	li	a5,2
ffffffffc020610a:	00f70f63          	beq	a4,a5,ffffffffc0206128 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc020610e:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0206110:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0206114:	e409                	bnez	s0,ffffffffc020611e <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206116:	60e2                	ld	ra,24(sp)
ffffffffc0206118:	6442                	ld	s0,16(sp)
ffffffffc020611a:	6105                	addi	sp,sp,32
ffffffffc020611c:	8082                	ret
ffffffffc020611e:	6442                	ld	s0,16(sp)
ffffffffc0206120:	60e2                	ld	ra,24(sp)
ffffffffc0206122:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206124:	d30fa06f          	j	ffffffffc0200654 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206128:	00003617          	auipc	a2,0x3
ffffffffc020612c:	94860613          	addi	a2,a2,-1720 # ffffffffc0208a70 <default_pmm_manager+0x1578>
ffffffffc0206130:	45c9                	li	a1,18
ffffffffc0206132:	00003517          	auipc	a0,0x3
ffffffffc0206136:	92650513          	addi	a0,a0,-1754 # ffffffffc0208a58 <default_pmm_manager+0x1560>
ffffffffc020613a:	bb6fa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc020613e:	bfd9                	j	ffffffffc0206114 <wakeup_proc+0x24>
ffffffffc0206140:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0206142:	d18fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0206146:	6522                	ld	a0,8(sp)
ffffffffc0206148:	4405                	li	s0,1
ffffffffc020614a:	4118                	lw	a4,0(a0)
ffffffffc020614c:	bf75                	j	ffffffffc0206108 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020614e:	00003697          	auipc	a3,0x3
ffffffffc0206152:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0208a38 <default_pmm_manager+0x1540>
ffffffffc0206156:	00001617          	auipc	a2,0x1
ffffffffc020615a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206db0 <commands+0x4c0>
ffffffffc020615e:	45a5                	li	a1,9
ffffffffc0206160:	00003517          	auipc	a0,0x3
ffffffffc0206164:	8f850513          	addi	a0,a0,-1800 # ffffffffc0208a58 <default_pmm_manager+0x1560>
ffffffffc0206168:	b1cfa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020616c <schedule>:

void
schedule(void) {
ffffffffc020616c:	1141                	addi	sp,sp,-16
ffffffffc020616e:	e406                	sd	ra,8(sp)
ffffffffc0206170:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206172:	100027f3          	csrr	a5,sstatus
ffffffffc0206176:	8b89                	andi	a5,a5,2
ffffffffc0206178:	4401                	li	s0,0
ffffffffc020617a:	e3d1                	bnez	a5,ffffffffc02061fe <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020617c:	000a6797          	auipc	a5,0xa6
ffffffffc0206180:	2ec78793          	addi	a5,a5,748 # ffffffffc02ac468 <current>
ffffffffc0206184:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206188:	000a6797          	auipc	a5,0xa6
ffffffffc020618c:	2e878793          	addi	a5,a5,744 # ffffffffc02ac470 <idleproc>
ffffffffc0206190:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0206192:	0008bc23          	sd	zero,24(a7) # fffffffffff80018 <end+0x3fcd3a60>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206196:	04a88e63          	beq	a7,a0,ffffffffc02061f2 <schedule+0x86>
ffffffffc020619a:	0c888693          	addi	a3,a7,200
ffffffffc020619e:	000a6617          	auipc	a2,0xa6
ffffffffc02061a2:	40a60613          	addi	a2,a2,1034 # ffffffffc02ac5a8 <proc_list>
        le = last;
ffffffffc02061a6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02061a8:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061aa:	4809                	li	a6,2
    return listelm->next;
ffffffffc02061ac:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02061ae:	00c78863          	beq	a5,a2,ffffffffc02061be <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061b2:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02061b6:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061ba:	01070463          	beq	a4,a6,ffffffffc02061c2 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02061be:	fef697e3          	bne	a3,a5,ffffffffc02061ac <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061c2:	c589                	beqz	a1,ffffffffc02061cc <schedule+0x60>
ffffffffc02061c4:	4198                	lw	a4,0(a1)
ffffffffc02061c6:	4789                	li	a5,2
ffffffffc02061c8:	00f70e63          	beq	a4,a5,ffffffffc02061e4 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02061cc:	451c                	lw	a5,8(a0)
ffffffffc02061ce:	2785                	addiw	a5,a5,1
ffffffffc02061d0:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02061d2:	00a88463          	beq	a7,a0,ffffffffc02061da <schedule+0x6e>
            proc_run(next);
ffffffffc02061d6:	e99fe0ef          	jal	ra,ffffffffc020506e <proc_run>
    if (flag) {
ffffffffc02061da:	e419                	bnez	s0,ffffffffc02061e8 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02061dc:	60a2                	ld	ra,8(sp)
ffffffffc02061de:	6402                	ld	s0,0(sp)
ffffffffc02061e0:	0141                	addi	sp,sp,16
ffffffffc02061e2:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061e4:	852e                	mv	a0,a1
ffffffffc02061e6:	b7dd                	j	ffffffffc02061cc <schedule+0x60>
}
ffffffffc02061e8:	6402                	ld	s0,0(sp)
ffffffffc02061ea:	60a2                	ld	ra,8(sp)
ffffffffc02061ec:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02061ee:	c66fa06f          	j	ffffffffc0200654 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061f2:	000a6617          	auipc	a2,0xa6
ffffffffc02061f6:	3b660613          	addi	a2,a2,950 # ffffffffc02ac5a8 <proc_list>
ffffffffc02061fa:	86b2                	mv	a3,a2
ffffffffc02061fc:	b76d                	j	ffffffffc02061a6 <schedule+0x3a>
        intr_disable();
ffffffffc02061fe:	c5cfa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0206202:	4405                	li	s0,1
ffffffffc0206204:	bfa5                	j	ffffffffc020617c <schedule+0x10>

ffffffffc0206206 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206206:	000a6797          	auipc	a5,0xa6
ffffffffc020620a:	26278793          	addi	a5,a5,610 # ffffffffc02ac468 <current>
ffffffffc020620e:	639c                	ld	a5,0(a5)
}
ffffffffc0206210:	43c8                	lw	a0,4(a5)
ffffffffc0206212:	8082                	ret

ffffffffc0206214 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206214:	4501                	li	a0,0
ffffffffc0206216:	8082                	ret

ffffffffc0206218 <sys_putc>:
    cputchar(c);
ffffffffc0206218:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020621a:	1141                	addi	sp,sp,-16
ffffffffc020621c:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020621e:	fa5f90ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc0206222:	60a2                	ld	ra,8(sp)
ffffffffc0206224:	4501                	li	a0,0
ffffffffc0206226:	0141                	addi	sp,sp,16
ffffffffc0206228:	8082                	ret

ffffffffc020622a <sys_kill>:
    return do_kill(pid);
ffffffffc020622a:	4108                	lw	a0,0(a0)
ffffffffc020622c:	cadff06f          	j	ffffffffc0205ed8 <do_kill>

ffffffffc0206230 <sys_yield>:
    return do_yield();
ffffffffc0206230:	c57ff06f          	j	ffffffffc0205e86 <do_yield>

ffffffffc0206234 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206234:	6d14                	ld	a3,24(a0)
ffffffffc0206236:	6910                	ld	a2,16(a0)
ffffffffc0206238:	650c                	ld	a1,8(a0)
ffffffffc020623a:	6108                	ld	a0,0(a0)
ffffffffc020623c:	f48ff06f          	j	ffffffffc0205984 <do_execve>

ffffffffc0206240 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206240:	650c                	ld	a1,8(a0)
ffffffffc0206242:	4108                	lw	a0,0(a0)
ffffffffc0206244:	c55ff06f          	j	ffffffffc0205e98 <do_wait>

ffffffffc0206248 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206248:	000a6797          	auipc	a5,0xa6
ffffffffc020624c:	22078793          	addi	a5,a5,544 # ffffffffc02ac468 <current>
ffffffffc0206250:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206252:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206254:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206256:	6a0c                	ld	a1,16(a2)
ffffffffc0206258:	ee1fe06f          	j	ffffffffc0205138 <do_fork>

ffffffffc020625c <sys_exit>:
    return do_exit(error_code);
ffffffffc020625c:	4108                	lw	a0,0(a0)
ffffffffc020625e:	b08ff06f          	j	ffffffffc0205566 <do_exit>

ffffffffc0206262 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206262:	715d                	addi	sp,sp,-80
ffffffffc0206264:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206266:	000a6497          	auipc	s1,0xa6
ffffffffc020626a:	20248493          	addi	s1,s1,514 # ffffffffc02ac468 <current>
ffffffffc020626e:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206270:	e0a2                	sd	s0,64(sp)
ffffffffc0206272:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206274:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206276:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206278:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020627a:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020627e:	0327ee63          	bltu	a5,s2,ffffffffc02062ba <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206282:	00391713          	slli	a4,s2,0x3
ffffffffc0206286:	00003797          	auipc	a5,0x3
ffffffffc020628a:	85278793          	addi	a5,a5,-1966 # ffffffffc0208ad8 <syscalls>
ffffffffc020628e:	97ba                	add	a5,a5,a4
ffffffffc0206290:	639c                	ld	a5,0(a5)
ffffffffc0206292:	c785                	beqz	a5,ffffffffc02062ba <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206294:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206296:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206298:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020629a:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020629c:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020629e:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02062a0:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02062a2:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02062a4:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02062a6:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02062a8:	0028                	addi	a0,sp,8
ffffffffc02062aa:	9782                	jalr	a5
ffffffffc02062ac:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02062ae:	60a6                	ld	ra,72(sp)
ffffffffc02062b0:	6406                	ld	s0,64(sp)
ffffffffc02062b2:	74e2                	ld	s1,56(sp)
ffffffffc02062b4:	7942                	ld	s2,48(sp)
ffffffffc02062b6:	6161                	addi	sp,sp,80
ffffffffc02062b8:	8082                	ret
    print_trapframe(tf);
ffffffffc02062ba:	8522                	mv	a0,s0
ffffffffc02062bc:	d8efa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02062c0:	609c                	ld	a5,0(s1)
ffffffffc02062c2:	86ca                	mv	a3,s2
ffffffffc02062c4:	00002617          	auipc	a2,0x2
ffffffffc02062c8:	7cc60613          	addi	a2,a2,1996 # ffffffffc0208a90 <default_pmm_manager+0x1598>
ffffffffc02062cc:	43d8                	lw	a4,4(a5)
ffffffffc02062ce:	06300593          	li	a1,99
ffffffffc02062d2:	0b478793          	addi	a5,a5,180
ffffffffc02062d6:	00002517          	auipc	a0,0x2
ffffffffc02062da:	7ea50513          	addi	a0,a0,2026 # ffffffffc0208ac0 <default_pmm_manager+0x15c8>
ffffffffc02062de:	9a6fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02062e2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02062e2:	9e3707b7          	lui	a5,0x9e370
ffffffffc02062e6:	2785                	addiw	a5,a5,1
ffffffffc02062e8:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02062ec:	02000793          	li	a5,32
ffffffffc02062f0:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02062f4:	00b5553b          	srlw	a0,a0,a1
ffffffffc02062f8:	8082                	ret

ffffffffc02062fa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02062fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062fe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206300:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206304:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206306:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020630a:	f022                	sd	s0,32(sp)
ffffffffc020630c:	ec26                	sd	s1,24(sp)
ffffffffc020630e:	e84a                	sd	s2,16(sp)
ffffffffc0206310:	f406                	sd	ra,40(sp)
ffffffffc0206312:	e44e                	sd	s3,8(sp)
ffffffffc0206314:	84aa                	mv	s1,a0
ffffffffc0206316:	892e                	mv	s2,a1
ffffffffc0206318:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020631c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020631e:	03067e63          	bleu	a6,a2,ffffffffc020635a <printnum+0x60>
ffffffffc0206322:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206324:	00805763          	blez	s0,ffffffffc0206332 <printnum+0x38>
ffffffffc0206328:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020632a:	85ca                	mv	a1,s2
ffffffffc020632c:	854e                	mv	a0,s3
ffffffffc020632e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206330:	fc65                	bnez	s0,ffffffffc0206328 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206332:	1a02                	slli	s4,s4,0x20
ffffffffc0206334:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206338:	00003797          	auipc	a5,0x3
ffffffffc020633c:	ac078793          	addi	a5,a5,-1344 # ffffffffc0208df8 <error_string+0xc8>
ffffffffc0206340:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206342:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206344:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206348:	70a2                	ld	ra,40(sp)
ffffffffc020634a:	69a2                	ld	s3,8(sp)
ffffffffc020634c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020634e:	85ca                	mv	a1,s2
ffffffffc0206350:	8326                	mv	t1,s1
}
ffffffffc0206352:	6942                	ld	s2,16(sp)
ffffffffc0206354:	64e2                	ld	s1,24(sp)
ffffffffc0206356:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206358:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020635a:	03065633          	divu	a2,a2,a6
ffffffffc020635e:	8722                	mv	a4,s0
ffffffffc0206360:	f9bff0ef          	jal	ra,ffffffffc02062fa <printnum>
ffffffffc0206364:	b7f9                	j	ffffffffc0206332 <printnum+0x38>

ffffffffc0206366 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206366:	7119                	addi	sp,sp,-128
ffffffffc0206368:	f4a6                	sd	s1,104(sp)
ffffffffc020636a:	f0ca                	sd	s2,96(sp)
ffffffffc020636c:	e8d2                	sd	s4,80(sp)
ffffffffc020636e:	e4d6                	sd	s5,72(sp)
ffffffffc0206370:	e0da                	sd	s6,64(sp)
ffffffffc0206372:	fc5e                	sd	s7,56(sp)
ffffffffc0206374:	f862                	sd	s8,48(sp)
ffffffffc0206376:	f06a                	sd	s10,32(sp)
ffffffffc0206378:	fc86                	sd	ra,120(sp)
ffffffffc020637a:	f8a2                	sd	s0,112(sp)
ffffffffc020637c:	ecce                	sd	s3,88(sp)
ffffffffc020637e:	f466                	sd	s9,40(sp)
ffffffffc0206380:	ec6e                	sd	s11,24(sp)
ffffffffc0206382:	892a                	mv	s2,a0
ffffffffc0206384:	84ae                	mv	s1,a1
ffffffffc0206386:	8d32                	mv	s10,a2
ffffffffc0206388:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020638a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020638c:	00003a17          	auipc	s4,0x3
ffffffffc0206390:	84ca0a13          	addi	s4,s4,-1972 # ffffffffc0208bd8 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206394:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206398:	00003c17          	auipc	s8,0x3
ffffffffc020639c:	998c0c13          	addi	s8,s8,-1640 # ffffffffc0208d30 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063a0:	000d4503          	lbu	a0,0(s10)
ffffffffc02063a4:	02500793          	li	a5,37
ffffffffc02063a8:	001d0413          	addi	s0,s10,1
ffffffffc02063ac:	00f50e63          	beq	a0,a5,ffffffffc02063c8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02063b0:	c521                	beqz	a0,ffffffffc02063f8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063b2:	02500993          	li	s3,37
ffffffffc02063b6:	a011                	j	ffffffffc02063ba <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02063b8:	c121                	beqz	a0,ffffffffc02063f8 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02063ba:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063bc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02063be:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063c0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02063c4:	ff351ae3          	bne	a0,s3,ffffffffc02063b8 <vprintfmt+0x52>
ffffffffc02063c8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02063cc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02063d0:	4981                	li	s3,0
ffffffffc02063d2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02063d4:	5cfd                	li	s9,-1
ffffffffc02063d6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063d8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02063dc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063de:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02063e2:	0ff6f693          	andi	a3,a3,255
ffffffffc02063e6:	00140d13          	addi	s10,s0,1
ffffffffc02063ea:	20d5e563          	bltu	a1,a3,ffffffffc02065f4 <vprintfmt+0x28e>
ffffffffc02063ee:	068a                	slli	a3,a3,0x2
ffffffffc02063f0:	96d2                	add	a3,a3,s4
ffffffffc02063f2:	4294                	lw	a3,0(a3)
ffffffffc02063f4:	96d2                	add	a3,a3,s4
ffffffffc02063f6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02063f8:	70e6                	ld	ra,120(sp)
ffffffffc02063fa:	7446                	ld	s0,112(sp)
ffffffffc02063fc:	74a6                	ld	s1,104(sp)
ffffffffc02063fe:	7906                	ld	s2,96(sp)
ffffffffc0206400:	69e6                	ld	s3,88(sp)
ffffffffc0206402:	6a46                	ld	s4,80(sp)
ffffffffc0206404:	6aa6                	ld	s5,72(sp)
ffffffffc0206406:	6b06                	ld	s6,64(sp)
ffffffffc0206408:	7be2                	ld	s7,56(sp)
ffffffffc020640a:	7c42                	ld	s8,48(sp)
ffffffffc020640c:	7ca2                	ld	s9,40(sp)
ffffffffc020640e:	7d02                	ld	s10,32(sp)
ffffffffc0206410:	6de2                	ld	s11,24(sp)
ffffffffc0206412:	6109                	addi	sp,sp,128
ffffffffc0206414:	8082                	ret
    if (lflag >= 2) {
ffffffffc0206416:	4705                	li	a4,1
ffffffffc0206418:	008a8593          	addi	a1,s5,8
ffffffffc020641c:	01074463          	blt	a4,a6,ffffffffc0206424 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0206420:	26080363          	beqz	a6,ffffffffc0206686 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0206424:	000ab603          	ld	a2,0(s5)
ffffffffc0206428:	46c1                	li	a3,16
ffffffffc020642a:	8aae                	mv	s5,a1
ffffffffc020642c:	a06d                	j	ffffffffc02064d6 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020642e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206432:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206434:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206436:	b765                	j	ffffffffc02063de <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206438:	000aa503          	lw	a0,0(s5)
ffffffffc020643c:	85a6                	mv	a1,s1
ffffffffc020643e:	0aa1                	addi	s5,s5,8
ffffffffc0206440:	9902                	jalr	s2
            break;
ffffffffc0206442:	bfb9                	j	ffffffffc02063a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206444:	4705                	li	a4,1
ffffffffc0206446:	008a8993          	addi	s3,s5,8
ffffffffc020644a:	01074463          	blt	a4,a6,ffffffffc0206452 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020644e:	22080463          	beqz	a6,ffffffffc0206676 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0206452:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0206456:	24044463          	bltz	s0,ffffffffc020669e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020645a:	8622                	mv	a2,s0
ffffffffc020645c:	8ace                	mv	s5,s3
ffffffffc020645e:	46a9                	li	a3,10
ffffffffc0206460:	a89d                	j	ffffffffc02064d6 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0206462:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206466:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206468:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020646a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020646e:	8fb5                	xor	a5,a5,a3
ffffffffc0206470:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206474:	1ad74363          	blt	a4,a3,ffffffffc020661a <vprintfmt+0x2b4>
ffffffffc0206478:	00369793          	slli	a5,a3,0x3
ffffffffc020647c:	97e2                	add	a5,a5,s8
ffffffffc020647e:	639c                	ld	a5,0(a5)
ffffffffc0206480:	18078d63          	beqz	a5,ffffffffc020661a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206484:	86be                	mv	a3,a5
ffffffffc0206486:	00000617          	auipc	a2,0x0
ffffffffc020648a:	36260613          	addi	a2,a2,866 # ffffffffc02067e8 <etext+0x2e>
ffffffffc020648e:	85a6                	mv	a1,s1
ffffffffc0206490:	854a                	mv	a0,s2
ffffffffc0206492:	240000ef          	jal	ra,ffffffffc02066d2 <printfmt>
ffffffffc0206496:	b729                	j	ffffffffc02063a0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206498:	00144603          	lbu	a2,1(s0)
ffffffffc020649c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020649e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064a0:	bf3d                	j	ffffffffc02063de <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02064a2:	4705                	li	a4,1
ffffffffc02064a4:	008a8593          	addi	a1,s5,8
ffffffffc02064a8:	01074463          	blt	a4,a6,ffffffffc02064b0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02064ac:	1e080263          	beqz	a6,ffffffffc0206690 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02064b0:	000ab603          	ld	a2,0(s5)
ffffffffc02064b4:	46a1                	li	a3,8
ffffffffc02064b6:	8aae                	mv	s5,a1
ffffffffc02064b8:	a839                	j	ffffffffc02064d6 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02064ba:	03000513          	li	a0,48
ffffffffc02064be:	85a6                	mv	a1,s1
ffffffffc02064c0:	e03e                	sd	a5,0(sp)
ffffffffc02064c2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02064c4:	85a6                	mv	a1,s1
ffffffffc02064c6:	07800513          	li	a0,120
ffffffffc02064ca:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02064cc:	0aa1                	addi	s5,s5,8
ffffffffc02064ce:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02064d2:	6782                	ld	a5,0(sp)
ffffffffc02064d4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02064d6:	876e                	mv	a4,s11
ffffffffc02064d8:	85a6                	mv	a1,s1
ffffffffc02064da:	854a                	mv	a0,s2
ffffffffc02064dc:	e1fff0ef          	jal	ra,ffffffffc02062fa <printnum>
            break;
ffffffffc02064e0:	b5c1                	j	ffffffffc02063a0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064e2:	000ab603          	ld	a2,0(s5)
ffffffffc02064e6:	0aa1                	addi	s5,s5,8
ffffffffc02064e8:	1c060663          	beqz	a2,ffffffffc02066b4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02064ec:	00160413          	addi	s0,a2,1
ffffffffc02064f0:	17b05c63          	blez	s11,ffffffffc0206668 <vprintfmt+0x302>
ffffffffc02064f4:	02d00593          	li	a1,45
ffffffffc02064f8:	14b79263          	bne	a5,a1,ffffffffc020663c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064fc:	00064783          	lbu	a5,0(a2)
ffffffffc0206500:	0007851b          	sext.w	a0,a5
ffffffffc0206504:	c905                	beqz	a0,ffffffffc0206534 <vprintfmt+0x1ce>
ffffffffc0206506:	000cc563          	bltz	s9,ffffffffc0206510 <vprintfmt+0x1aa>
ffffffffc020650a:	3cfd                	addiw	s9,s9,-1
ffffffffc020650c:	036c8263          	beq	s9,s6,ffffffffc0206530 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0206510:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206512:	18098463          	beqz	s3,ffffffffc020669a <vprintfmt+0x334>
ffffffffc0206516:	3781                	addiw	a5,a5,-32
ffffffffc0206518:	18fbf163          	bleu	a5,s7,ffffffffc020669a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020651c:	03f00513          	li	a0,63
ffffffffc0206520:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206522:	0405                	addi	s0,s0,1
ffffffffc0206524:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206528:	3dfd                	addiw	s11,s11,-1
ffffffffc020652a:	0007851b          	sext.w	a0,a5
ffffffffc020652e:	fd61                	bnez	a0,ffffffffc0206506 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206530:	e7b058e3          	blez	s11,ffffffffc02063a0 <vprintfmt+0x3a>
ffffffffc0206534:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206536:	85a6                	mv	a1,s1
ffffffffc0206538:	02000513          	li	a0,32
ffffffffc020653c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020653e:	e60d81e3          	beqz	s11,ffffffffc02063a0 <vprintfmt+0x3a>
ffffffffc0206542:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206544:	85a6                	mv	a1,s1
ffffffffc0206546:	02000513          	li	a0,32
ffffffffc020654a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020654c:	fe0d94e3          	bnez	s11,ffffffffc0206534 <vprintfmt+0x1ce>
ffffffffc0206550:	bd81                	j	ffffffffc02063a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206552:	4705                	li	a4,1
ffffffffc0206554:	008a8593          	addi	a1,s5,8
ffffffffc0206558:	01074463          	blt	a4,a6,ffffffffc0206560 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020655c:	12080063          	beqz	a6,ffffffffc020667c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206560:	000ab603          	ld	a2,0(s5)
ffffffffc0206564:	46a9                	li	a3,10
ffffffffc0206566:	8aae                	mv	s5,a1
ffffffffc0206568:	b7bd                	j	ffffffffc02064d6 <vprintfmt+0x170>
ffffffffc020656a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020656e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206572:	846a                	mv	s0,s10
ffffffffc0206574:	b5ad                	j	ffffffffc02063de <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206576:	85a6                	mv	a1,s1
ffffffffc0206578:	02500513          	li	a0,37
ffffffffc020657c:	9902                	jalr	s2
            break;
ffffffffc020657e:	b50d                	j	ffffffffc02063a0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206580:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206584:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206588:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020658a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020658c:	e40dd9e3          	bgez	s11,ffffffffc02063de <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206590:	8de6                	mv	s11,s9
ffffffffc0206592:	5cfd                	li	s9,-1
ffffffffc0206594:	b5a9                	j	ffffffffc02063de <vprintfmt+0x78>
            goto reswitch;
ffffffffc0206596:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020659a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020659e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02065a0:	bd3d                	j	ffffffffc02063de <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02065a2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02065a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065aa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02065ac:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02065b0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02065b4:	fcd56ce3          	bltu	a0,a3,ffffffffc020658c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02065b8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02065ba:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02065be:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02065c2:	0196873b          	addw	a4,a3,s9
ffffffffc02065c6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02065ca:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02065ce:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02065d2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02065d6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02065da:	fcd57fe3          	bleu	a3,a0,ffffffffc02065b8 <vprintfmt+0x252>
ffffffffc02065de:	b77d                	j	ffffffffc020658c <vprintfmt+0x226>
            if (width < 0)
ffffffffc02065e0:	fffdc693          	not	a3,s11
ffffffffc02065e4:	96fd                	srai	a3,a3,0x3f
ffffffffc02065e6:	00ddfdb3          	and	s11,s11,a3
ffffffffc02065ea:	00144603          	lbu	a2,1(s0)
ffffffffc02065ee:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065f0:	846a                	mv	s0,s10
ffffffffc02065f2:	b3f5                	j	ffffffffc02063de <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02065f4:	85a6                	mv	a1,s1
ffffffffc02065f6:	02500513          	li	a0,37
ffffffffc02065fa:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02065fc:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206600:	02500793          	li	a5,37
ffffffffc0206604:	8d22                	mv	s10,s0
ffffffffc0206606:	d8f70de3          	beq	a4,a5,ffffffffc02063a0 <vprintfmt+0x3a>
ffffffffc020660a:	02500713          	li	a4,37
ffffffffc020660e:	1d7d                	addi	s10,s10,-1
ffffffffc0206610:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206614:	fee79de3          	bne	a5,a4,ffffffffc020660e <vprintfmt+0x2a8>
ffffffffc0206618:	b361                	j	ffffffffc02063a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020661a:	00003617          	auipc	a2,0x3
ffffffffc020661e:	8be60613          	addi	a2,a2,-1858 # ffffffffc0208ed8 <error_string+0x1a8>
ffffffffc0206622:	85a6                	mv	a1,s1
ffffffffc0206624:	854a                	mv	a0,s2
ffffffffc0206626:	0ac000ef          	jal	ra,ffffffffc02066d2 <printfmt>
ffffffffc020662a:	bb9d                	j	ffffffffc02063a0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020662c:	00003617          	auipc	a2,0x3
ffffffffc0206630:	8a460613          	addi	a2,a2,-1884 # ffffffffc0208ed0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206634:	00003417          	auipc	s0,0x3
ffffffffc0206638:	89d40413          	addi	s0,s0,-1891 # ffffffffc0208ed1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020663c:	8532                	mv	a0,a2
ffffffffc020663e:	85e6                	mv	a1,s9
ffffffffc0206640:	e032                	sd	a2,0(sp)
ffffffffc0206642:	e43e                	sd	a5,8(sp)
ffffffffc0206644:	0cc000ef          	jal	ra,ffffffffc0206710 <strnlen>
ffffffffc0206648:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020664c:	6602                	ld	a2,0(sp)
ffffffffc020664e:	01b05d63          	blez	s11,ffffffffc0206668 <vprintfmt+0x302>
ffffffffc0206652:	67a2                	ld	a5,8(sp)
ffffffffc0206654:	2781                	sext.w	a5,a5
ffffffffc0206656:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206658:	6522                	ld	a0,8(sp)
ffffffffc020665a:	85a6                	mv	a1,s1
ffffffffc020665c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020665e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206660:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206662:	6602                	ld	a2,0(sp)
ffffffffc0206664:	fe0d9ae3          	bnez	s11,ffffffffc0206658 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206668:	00064783          	lbu	a5,0(a2)
ffffffffc020666c:	0007851b          	sext.w	a0,a5
ffffffffc0206670:	e8051be3          	bnez	a0,ffffffffc0206506 <vprintfmt+0x1a0>
ffffffffc0206674:	b335                	j	ffffffffc02063a0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0206676:	000aa403          	lw	s0,0(s5)
ffffffffc020667a:	bbf1                	j	ffffffffc0206456 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020667c:	000ae603          	lwu	a2,0(s5)
ffffffffc0206680:	46a9                	li	a3,10
ffffffffc0206682:	8aae                	mv	s5,a1
ffffffffc0206684:	bd89                	j	ffffffffc02064d6 <vprintfmt+0x170>
ffffffffc0206686:	000ae603          	lwu	a2,0(s5)
ffffffffc020668a:	46c1                	li	a3,16
ffffffffc020668c:	8aae                	mv	s5,a1
ffffffffc020668e:	b5a1                	j	ffffffffc02064d6 <vprintfmt+0x170>
ffffffffc0206690:	000ae603          	lwu	a2,0(s5)
ffffffffc0206694:	46a1                	li	a3,8
ffffffffc0206696:	8aae                	mv	s5,a1
ffffffffc0206698:	bd3d                	j	ffffffffc02064d6 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020669a:	9902                	jalr	s2
ffffffffc020669c:	b559                	j	ffffffffc0206522 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020669e:	85a6                	mv	a1,s1
ffffffffc02066a0:	02d00513          	li	a0,45
ffffffffc02066a4:	e03e                	sd	a5,0(sp)
ffffffffc02066a6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02066a8:	8ace                	mv	s5,s3
ffffffffc02066aa:	40800633          	neg	a2,s0
ffffffffc02066ae:	46a9                	li	a3,10
ffffffffc02066b0:	6782                	ld	a5,0(sp)
ffffffffc02066b2:	b515                	j	ffffffffc02064d6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02066b4:	01b05663          	blez	s11,ffffffffc02066c0 <vprintfmt+0x35a>
ffffffffc02066b8:	02d00693          	li	a3,45
ffffffffc02066bc:	f6d798e3          	bne	a5,a3,ffffffffc020662c <vprintfmt+0x2c6>
ffffffffc02066c0:	00003417          	auipc	s0,0x3
ffffffffc02066c4:	81140413          	addi	s0,s0,-2031 # ffffffffc0208ed1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02066c8:	02800513          	li	a0,40
ffffffffc02066cc:	02800793          	li	a5,40
ffffffffc02066d0:	bd1d                	j	ffffffffc0206506 <vprintfmt+0x1a0>

ffffffffc02066d2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066d2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02066d4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066d8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02066da:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066dc:	ec06                	sd	ra,24(sp)
ffffffffc02066de:	f83a                	sd	a4,48(sp)
ffffffffc02066e0:	fc3e                	sd	a5,56(sp)
ffffffffc02066e2:	e0c2                	sd	a6,64(sp)
ffffffffc02066e4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02066e6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02066e8:	c7fff0ef          	jal	ra,ffffffffc0206366 <vprintfmt>
}
ffffffffc02066ec:	60e2                	ld	ra,24(sp)
ffffffffc02066ee:	6161                	addi	sp,sp,80
ffffffffc02066f0:	8082                	ret

ffffffffc02066f2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02066f2:	00054783          	lbu	a5,0(a0)
ffffffffc02066f6:	cb91                	beqz	a5,ffffffffc020670a <strlen+0x18>
    size_t cnt = 0;
ffffffffc02066f8:	4781                	li	a5,0
        cnt ++;
ffffffffc02066fa:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02066fc:	00f50733          	add	a4,a0,a5
ffffffffc0206700:	00074703          	lbu	a4,0(a4)
ffffffffc0206704:	fb7d                	bnez	a4,ffffffffc02066fa <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206706:	853e                	mv	a0,a5
ffffffffc0206708:	8082                	ret
    size_t cnt = 0;
ffffffffc020670a:	4781                	li	a5,0
}
ffffffffc020670c:	853e                	mv	a0,a5
ffffffffc020670e:	8082                	ret

ffffffffc0206710 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206710:	c185                	beqz	a1,ffffffffc0206730 <strnlen+0x20>
ffffffffc0206712:	00054783          	lbu	a5,0(a0)
ffffffffc0206716:	cf89                	beqz	a5,ffffffffc0206730 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206718:	4781                	li	a5,0
ffffffffc020671a:	a021                	j	ffffffffc0206722 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020671c:	00074703          	lbu	a4,0(a4)
ffffffffc0206720:	c711                	beqz	a4,ffffffffc020672c <strnlen+0x1c>
        cnt ++;
ffffffffc0206722:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206724:	00f50733          	add	a4,a0,a5
ffffffffc0206728:	fef59ae3          	bne	a1,a5,ffffffffc020671c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020672c:	853e                	mv	a0,a5
ffffffffc020672e:	8082                	ret
    size_t cnt = 0;
ffffffffc0206730:	4781                	li	a5,0
}
ffffffffc0206732:	853e                	mv	a0,a5
ffffffffc0206734:	8082                	ret

ffffffffc0206736 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206736:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206738:	0585                	addi	a1,a1,1
ffffffffc020673a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020673e:	0785                	addi	a5,a5,1
ffffffffc0206740:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206744:	fb75                	bnez	a4,ffffffffc0206738 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206746:	8082                	ret

ffffffffc0206748 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206748:	00054783          	lbu	a5,0(a0)
ffffffffc020674c:	0005c703          	lbu	a4,0(a1)
ffffffffc0206750:	cb91                	beqz	a5,ffffffffc0206764 <strcmp+0x1c>
ffffffffc0206752:	00e79c63          	bne	a5,a4,ffffffffc020676a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206756:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206758:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020675c:	0585                	addi	a1,a1,1
ffffffffc020675e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206762:	fbe5                	bnez	a5,ffffffffc0206752 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206764:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206766:	9d19                	subw	a0,a0,a4
ffffffffc0206768:	8082                	ret
ffffffffc020676a:	0007851b          	sext.w	a0,a5
ffffffffc020676e:	9d19                	subw	a0,a0,a4
ffffffffc0206770:	8082                	ret

ffffffffc0206772 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206772:	00054783          	lbu	a5,0(a0)
ffffffffc0206776:	cb91                	beqz	a5,ffffffffc020678a <strchr+0x18>
        if (*s == c) {
ffffffffc0206778:	00b79563          	bne	a5,a1,ffffffffc0206782 <strchr+0x10>
ffffffffc020677c:	a809                	j	ffffffffc020678e <strchr+0x1c>
ffffffffc020677e:	00b78763          	beq	a5,a1,ffffffffc020678c <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206782:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206784:	00054783          	lbu	a5,0(a0)
ffffffffc0206788:	fbfd                	bnez	a5,ffffffffc020677e <strchr+0xc>
    }
    return NULL;
ffffffffc020678a:	4501                	li	a0,0
}
ffffffffc020678c:	8082                	ret
ffffffffc020678e:	8082                	ret

ffffffffc0206790 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206790:	ca01                	beqz	a2,ffffffffc02067a0 <memset+0x10>
ffffffffc0206792:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206794:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206796:	0785                	addi	a5,a5,1
ffffffffc0206798:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020679c:	fec79de3          	bne	a5,a2,ffffffffc0206796 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02067a0:	8082                	ret

ffffffffc02067a2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02067a2:	ca19                	beqz	a2,ffffffffc02067b8 <memcpy+0x16>
ffffffffc02067a4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02067a6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02067a8:	0585                	addi	a1,a1,1
ffffffffc02067aa:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02067ae:	0785                	addi	a5,a5,1
ffffffffc02067b0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02067b4:	fec59ae3          	bne	a1,a2,ffffffffc02067a8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02067b8:	8082                	ret
