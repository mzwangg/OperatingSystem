
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	ffc50513          	addi	a0,a0,-4 # 80204008 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	00460613          	addi	a2,a2,4 # 80204018 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	1b1000ef          	jal	ra,802009d4 <memset>

    cons_init();  // init the console
    80200028:	142000ef          	jal	ra,8020016a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	9bc58593          	addi	a1,a1,-1604 # 802009e8 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	9d450513          	addi	a0,a0,-1580 # 80200a08 <etext+0x22>
    8020003c:	036000ef          	jal	ra,80200072 <cprintf>

    print_kerninfo();
    80200040:	066000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	136000ef          	jal	ra,8020017a <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0ee000ef          	jal	ra,80200136 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	128000ef          	jal	ra,80200174 <intr_enable>
    
    asm volatile("ebreak");
    80200050:	9002                	ebreak
    asm volatile("mret");
    80200052:	30200073          	mret

    while (1)
        ;
    80200056:	a001                	j	80200056 <kern_init+0x4a>

0000000080200058 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200058:	1141                	addi	sp,sp,-16
    8020005a:	e022                	sd	s0,0(sp)
    8020005c:	e406                	sd	ra,8(sp)
    8020005e:	842e                	mv	s0,a1
    cons_putc(c);
    80200060:	10c000ef          	jal	ra,8020016c <cons_putc>
    (*cnt)++;
    80200064:	401c                	lw	a5,0(s0)
}
    80200066:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200068:	2785                	addiw	a5,a5,1
    8020006a:	c01c                	sw	a5,0(s0)
}
    8020006c:	6402                	ld	s0,0(sp)
    8020006e:	0141                	addi	sp,sp,16
    80200070:	8082                	ret

0000000080200072 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200072:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200074:	02810313          	addi	t1,sp,40 # 80204028 <end+0x10>
int cprintf(const char *fmt, ...) {
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	862a                	mv	a2,a0
    80200080:	004c                	addi	a1,sp,4
    80200082:	00000517          	auipc	a0,0x0
    80200086:	fd650513          	addi	a0,a0,-42 # 80200058 <cputch>
    8020008a:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	550000ef          	jal	ra,802005ea <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	96850513          	addi	a0,a0,-1688 # 80200a10 <etext+0x2a>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5658593          	addi	a1,a1,-170 # 8020000c <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	97250513          	addi	a0,a0,-1678 # 80200a30 <etext+0x4a>
    802000c6:	fadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	91c58593          	addi	a1,a1,-1764 # 802009e6 <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	97e50513          	addi	a0,a0,-1666 # 80200a50 <etext+0x6a>
    802000da:	f99ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f2a58593          	addi	a1,a1,-214 # 80204008 <edata>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	98a50513          	addi	a0,a0,-1654 # 80200a70 <etext+0x8a>
    802000ee:	f85ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f2658593          	addi	a1,a1,-218 # 80204018 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	99650513          	addi	a0,a0,-1642 # 80200a90 <etext+0xaa>
    80200102:	f71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	31158593          	addi	a1,a1,785 # 80204417 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efe78793          	addi	a5,a5,-258 # 8020000c <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	98850513          	addi	a0,a0,-1656 # 80200ab0 <etext+0xca>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	f41ff06f          	j	80200072 <cprintf>

0000000080200136 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200136:	1141                	addi	sp,sp,-16
    80200138:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020013a:	02000793          	li	a5,32
    8020013e:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200142:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200146:	67e1                	lui	a5,0x18
    80200148:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014c:	953e                	add	a0,a0,a5
    8020014e:	045000ef          	jal	ra,80200992 <sbi_set_timer>
}
    80200152:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200154:	00004797          	auipc	a5,0x4
    80200158:	ea07be23          	sd	zero,-324(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015c:	00001517          	auipc	a0,0x1
    80200160:	98450513          	addi	a0,a0,-1660 # 80200ae0 <etext+0xfa>
}
    80200164:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200166:	f0dff06f          	j	80200072 <cprintf>

000000008020016a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016a:	8082                	ret

000000008020016c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020016c:	0ff57513          	andi	a0,a0,255
    80200170:	0070006f          	j	80200976 <sbi_console_putchar>

0000000080200174 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200174:	100167f3          	csrrsi	a5,sstatus,2
    80200178:	8082                	ret

000000008020017a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020017e:	00000797          	auipc	a5,0x0
    80200182:	34a78793          	addi	a5,a5,842 # 802004c8 <__alltraps>
    80200186:	10579073          	csrw	stvec,a5
}
    8020018a:	8082                	ret

000000008020018c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020018e:	1141                	addi	sp,sp,-16
    80200190:	e022                	sd	s0,0(sp)
    80200192:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200194:	00001517          	auipc	a0,0x1
    80200198:	ad450513          	addi	a0,a0,-1324 # 80200c68 <etext+0x282>
void print_regs(struct pushregs *gpr) {
    8020019c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	ed5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a2:	640c                	ld	a1,8(s0)
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	adc50513          	addi	a0,a0,-1316 # 80200c80 <etext+0x29a>
    802001ac:	ec7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b0:	680c                	ld	a1,16(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	ae650513          	addi	a0,a0,-1306 # 80200c98 <etext+0x2b2>
    802001ba:	eb9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001be:	6c0c                	ld	a1,24(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	af050513          	addi	a0,a0,-1296 # 80200cb0 <etext+0x2ca>
    802001c8:	eabff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001cc:	700c                	ld	a1,32(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	afa50513          	addi	a0,a0,-1286 # 80200cc8 <etext+0x2e2>
    802001d6:	e9dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001da:	740c                	ld	a1,40(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	b0450513          	addi	a0,a0,-1276 # 80200ce0 <etext+0x2fa>
    802001e4:	e8fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001e8:	780c                	ld	a1,48(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	b0e50513          	addi	a0,a0,-1266 # 80200cf8 <etext+0x312>
    802001f2:	e81ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f6:	7c0c                	ld	a1,56(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	b1850513          	addi	a0,a0,-1256 # 80200d10 <etext+0x32a>
    80200200:	e73ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200204:	602c                	ld	a1,64(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	b2250513          	addi	a0,a0,-1246 # 80200d28 <etext+0x342>
    8020020e:	e65ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200212:	642c                	ld	a1,72(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	b2c50513          	addi	a0,a0,-1236 # 80200d40 <etext+0x35a>
    8020021c:	e57ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200220:	682c                	ld	a1,80(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	b3650513          	addi	a0,a0,-1226 # 80200d58 <etext+0x372>
    8020022a:	e49ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020022e:	6c2c                	ld	a1,88(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	b4050513          	addi	a0,a0,-1216 # 80200d70 <etext+0x38a>
    80200238:	e3bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020023c:	702c                	ld	a1,96(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	b4a50513          	addi	a0,a0,-1206 # 80200d88 <etext+0x3a2>
    80200246:	e2dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024a:	742c                	ld	a1,104(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	b5450513          	addi	a0,a0,-1196 # 80200da0 <etext+0x3ba>
    80200254:	e1fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200258:	782c                	ld	a1,112(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	b5e50513          	addi	a0,a0,-1186 # 80200db8 <etext+0x3d2>
    80200262:	e11ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200266:	7c2c                	ld	a1,120(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	b6850513          	addi	a0,a0,-1176 # 80200dd0 <etext+0x3ea>
    80200270:	e03ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200274:	604c                	ld	a1,128(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	b7250513          	addi	a0,a0,-1166 # 80200de8 <etext+0x402>
    8020027e:	df5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200282:	644c                	ld	a1,136(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	b7c50513          	addi	a0,a0,-1156 # 80200e00 <etext+0x41a>
    8020028c:	de7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200290:	684c                	ld	a1,144(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	b8650513          	addi	a0,a0,-1146 # 80200e18 <etext+0x432>
    8020029a:	dd9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    8020029e:	6c4c                	ld	a1,152(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	b9050513          	addi	a0,a0,-1136 # 80200e30 <etext+0x44a>
    802002a8:	dcbff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ac:	704c                	ld	a1,160(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	b9a50513          	addi	a0,a0,-1126 # 80200e48 <etext+0x462>
    802002b6:	dbdff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ba:	744c                	ld	a1,168(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	ba450513          	addi	a0,a0,-1116 # 80200e60 <etext+0x47a>
    802002c4:	dafff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002c8:	784c                	ld	a1,176(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	bae50513          	addi	a0,a0,-1106 # 80200e78 <etext+0x492>
    802002d2:	da1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d6:	7c4c                	ld	a1,184(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	bb850513          	addi	a0,a0,-1096 # 80200e90 <etext+0x4aa>
    802002e0:	d93ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e4:	606c                	ld	a1,192(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	bc250513          	addi	a0,a0,-1086 # 80200ea8 <etext+0x4c2>
    802002ee:	d85ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f2:	646c                	ld	a1,200(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	bcc50513          	addi	a0,a0,-1076 # 80200ec0 <etext+0x4da>
    802002fc:	d77ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200300:	686c                	ld	a1,208(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	bd650513          	addi	a0,a0,-1066 # 80200ed8 <etext+0x4f2>
    8020030a:	d69ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020030e:	6c6c                	ld	a1,216(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	be050513          	addi	a0,a0,-1056 # 80200ef0 <etext+0x50a>
    80200318:	d5bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020031c:	706c                	ld	a1,224(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	bea50513          	addi	a0,a0,-1046 # 80200f08 <etext+0x522>
    80200326:	d4dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032a:	746c                	ld	a1,232(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	bf450513          	addi	a0,a0,-1036 # 80200f20 <etext+0x53a>
    80200334:	d3fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200338:	786c                	ld	a1,240(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	bfe50513          	addi	a0,a0,-1026 # 80200f38 <etext+0x552>
    80200342:	d31ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200346:	7c6c                	ld	a1,248(s0)
}
    80200348:	6402                	ld	s0,0(sp)
    8020034a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	00001517          	auipc	a0,0x1
    80200350:	c0450513          	addi	a0,a0,-1020 # 80200f50 <etext+0x56a>
}
    80200354:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	d1dff06f          	j	80200072 <cprintf>

000000008020035a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035a:	1141                	addi	sp,sp,-16
    8020035c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020035e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200360:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200362:	00001517          	auipc	a0,0x1
    80200366:	c0650513          	addi	a0,a0,-1018 # 80200f68 <etext+0x582>
void print_trapframe(struct trapframe *tf) {
    8020036a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	d07ff0ef          	jal	ra,80200072 <cprintf>
    print_regs(&tf->gpr);
    80200370:	8522                	mv	a0,s0
    80200372:	e1bff0ef          	jal	ra,8020018c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200376:	10043583          	ld	a1,256(s0)
    8020037a:	00001517          	auipc	a0,0x1
    8020037e:	c0650513          	addi	a0,a0,-1018 # 80200f80 <etext+0x59a>
    80200382:	cf1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200386:	10843583          	ld	a1,264(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	c0e50513          	addi	a0,a0,-1010 # 80200f98 <etext+0x5b2>
    80200392:	ce1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200396:	11043583          	ld	a1,272(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	c1650513          	addi	a0,a0,-1002 # 80200fb0 <etext+0x5ca>
    802003a2:	cd1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a6:	11843583          	ld	a1,280(s0)
}
    802003aa:	6402                	ld	s0,0(sp)
    802003ac:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ae:	00001517          	auipc	a0,0x1
    802003b2:	c1a50513          	addi	a0,a0,-998 # 80200fc8 <etext+0x5e2>
}
    802003b6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	cbbff06f          	j	80200072 <cprintf>

00000000802003bc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003bc:	11853783          	ld	a5,280(a0)
    802003c0:	577d                	li	a4,-1
    802003c2:	8305                	srli	a4,a4,0x1
    802003c4:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003c6:	472d                	li	a4,11
    802003c8:	04f76a63          	bltu	a4,a5,8020041c <interrupt_handler+0x60>
    802003cc:	00000717          	auipc	a4,0x0
    802003d0:	73070713          	addi	a4,a4,1840 # 80200afc <etext+0x116>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	84a50513          	addi	a0,a0,-1974 # 80200c28 <etext+0x242>
    802003e6:	c8dff06f          	j	80200072 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003ea:	00001517          	auipc	a0,0x1
    802003ee:	81e50513          	addi	a0,a0,-2018 # 80200c08 <etext+0x222>
    802003f2:	c81ff06f          	j	80200072 <cprintf>
            cprintf("User software interrupt\n");
    802003f6:	00000517          	auipc	a0,0x0
    802003fa:	7d250513          	addi	a0,a0,2002 # 80200bc8 <etext+0x1e2>
    802003fe:	c75ff06f          	j	80200072 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200402:	00000517          	auipc	a0,0x0
    80200406:	7e650513          	addi	a0,a0,2022 # 80200be8 <etext+0x202>
    8020040a:	c69ff06f          	j	80200072 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020040e:	00001517          	auipc	a0,0x1
    80200412:	83a50513          	addi	a0,a0,-1990 # 80200c48 <etext+0x262>
    80200416:	c5dff06f          	j	80200072 <cprintf>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020041a:	8082                	ret
            print_trapframe(tf);
    8020041c:	f3fff06f          	j	8020035a <print_trapframe>

0000000080200420 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200420:	11853783          	ld	a5,280(a0)
    80200424:	472d                	li	a4,11
    80200426:	02f76863          	bltu	a4,a5,80200456 <exception_handler+0x36>
    8020042a:	4705                	li	a4,1
    8020042c:	00f71733          	sll	a4,a4,a5
    80200430:	6785                	lui	a5,0x1
    80200432:	17cd                	addi	a5,a5,-13
    80200434:	8ff9                	and	a5,a5,a4
    80200436:	ef99                	bnez	a5,80200454 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    80200438:	1141                	addi	sp,sp,-16
    8020043a:	e022                	sd	s0,0(sp)
    8020043c:	e406                	sd	ra,8(sp)
    8020043e:	00877793          	andi	a5,a4,8
    80200442:	842a                	mv	s0,a0
    80200444:	e3b1                	bnez	a5,80200488 <exception_handler+0x68>
    80200446:	8b11                	andi	a4,a4,4
    80200448:	eb09                	bnez	a4,8020045a <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020044a:	6402                	ld	s0,0(sp)
    8020044c:	60a2                	ld	ra,8(sp)
    8020044e:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    80200450:	f0bff06f          	j	8020035a <print_trapframe>
    80200454:	8082                	ret
    80200456:	f05ff06f          	j	8020035a <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");
    8020045a:	00000517          	auipc	a0,0x0
    8020045e:	6d650513          	addi	a0,a0,1750 # 80200b30 <etext+0x14a>
    80200462:	c11ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
    80200466:	10843583          	ld	a1,264(s0)
    8020046a:	00000517          	auipc	a0,0x0
    8020046e:	6ee50513          	addi	a0,a0,1774 # 80200b58 <etext+0x172>
    80200472:	c01ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 4;
    80200476:	10843783          	ld	a5,264(s0)
}
    8020047a:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    8020047c:	0791                	addi	a5,a5,4
    8020047e:	10f43423          	sd	a5,264(s0)
}
    80200482:	6402                	ld	s0,0(sp)
    80200484:	0141                	addi	sp,sp,16
    80200486:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    80200488:	00000517          	auipc	a0,0x0
    8020048c:	70050513          	addi	a0,a0,1792 # 80200b88 <etext+0x1a2>
    80200490:	be3ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
    80200494:	10843583          	ld	a1,264(s0)
    80200498:	00000517          	auipc	a0,0x0
    8020049c:	71050513          	addi	a0,a0,1808 # 80200ba8 <etext+0x1c2>
    802004a0:	bd3ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 2;
    802004a4:	10843783          	ld	a5,264(s0)
}
    802004a8:	60a2                	ld	ra,8(sp)
            tf->epc += 2;
    802004aa:	0789                	addi	a5,a5,2
    802004ac:	10f43423          	sd	a5,264(s0)
}
    802004b0:	6402                	ld	s0,0(sp)
    802004b2:	0141                	addi	sp,sp,16
    802004b4:	8082                	ret

00000000802004b6 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004b6:	11853783          	ld	a5,280(a0)
    802004ba:	0007c463          	bltz	a5,802004c2 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004be:	f63ff06f          	j	80200420 <exception_handler>
        interrupt_handler(tf);
    802004c2:	efbff06f          	j	802003bc <interrupt_handler>
	...

00000000802004c8 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004c8:	14011073          	csrw	sscratch,sp
    802004cc:	712d                	addi	sp,sp,-288
    802004ce:	e002                	sd	zero,0(sp)
    802004d0:	e406                	sd	ra,8(sp)
    802004d2:	ec0e                	sd	gp,24(sp)
    802004d4:	f012                	sd	tp,32(sp)
    802004d6:	f416                	sd	t0,40(sp)
    802004d8:	f81a                	sd	t1,48(sp)
    802004da:	fc1e                	sd	t2,56(sp)
    802004dc:	e0a2                	sd	s0,64(sp)
    802004de:	e4a6                	sd	s1,72(sp)
    802004e0:	e8aa                	sd	a0,80(sp)
    802004e2:	ecae                	sd	a1,88(sp)
    802004e4:	f0b2                	sd	a2,96(sp)
    802004e6:	f4b6                	sd	a3,104(sp)
    802004e8:	f8ba                	sd	a4,112(sp)
    802004ea:	fcbe                	sd	a5,120(sp)
    802004ec:	e142                	sd	a6,128(sp)
    802004ee:	e546                	sd	a7,136(sp)
    802004f0:	e94a                	sd	s2,144(sp)
    802004f2:	ed4e                	sd	s3,152(sp)
    802004f4:	f152                	sd	s4,160(sp)
    802004f6:	f556                	sd	s5,168(sp)
    802004f8:	f95a                	sd	s6,176(sp)
    802004fa:	fd5e                	sd	s7,184(sp)
    802004fc:	e1e2                	sd	s8,192(sp)
    802004fe:	e5e6                	sd	s9,200(sp)
    80200500:	e9ea                	sd	s10,208(sp)
    80200502:	edee                	sd	s11,216(sp)
    80200504:	f1f2                	sd	t3,224(sp)
    80200506:	f5f6                	sd	t4,232(sp)
    80200508:	f9fa                	sd	t5,240(sp)
    8020050a:	fdfe                	sd	t6,248(sp)
    8020050c:	14001473          	csrrw	s0,sscratch,zero
    80200510:	100024f3          	csrr	s1,sstatus
    80200514:	14102973          	csrr	s2,sepc
    80200518:	143029f3          	csrr	s3,stval
    8020051c:	14202a73          	csrr	s4,scause
    80200520:	e822                	sd	s0,16(sp)
    80200522:	e226                	sd	s1,256(sp)
    80200524:	e64a                	sd	s2,264(sp)
    80200526:	ea4e                	sd	s3,272(sp)
    80200528:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020052a:	850a                	mv	a0,sp
    jal trap
    8020052c:	f8bff0ef          	jal	ra,802004b6 <trap>

0000000080200530 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200530:	6492                	ld	s1,256(sp)
    80200532:	6932                	ld	s2,264(sp)
    80200534:	10049073          	csrw	sstatus,s1
    80200538:	14191073          	csrw	sepc,s2
    8020053c:	60a2                	ld	ra,8(sp)
    8020053e:	61e2                	ld	gp,24(sp)
    80200540:	7202                	ld	tp,32(sp)
    80200542:	72a2                	ld	t0,40(sp)
    80200544:	7342                	ld	t1,48(sp)
    80200546:	73e2                	ld	t2,56(sp)
    80200548:	6406                	ld	s0,64(sp)
    8020054a:	64a6                	ld	s1,72(sp)
    8020054c:	6546                	ld	a0,80(sp)
    8020054e:	65e6                	ld	a1,88(sp)
    80200550:	7606                	ld	a2,96(sp)
    80200552:	76a6                	ld	a3,104(sp)
    80200554:	7746                	ld	a4,112(sp)
    80200556:	77e6                	ld	a5,120(sp)
    80200558:	680a                	ld	a6,128(sp)
    8020055a:	68aa                	ld	a7,136(sp)
    8020055c:	694a                	ld	s2,144(sp)
    8020055e:	69ea                	ld	s3,152(sp)
    80200560:	7a0a                	ld	s4,160(sp)
    80200562:	7aaa                	ld	s5,168(sp)
    80200564:	7b4a                	ld	s6,176(sp)
    80200566:	7bea                	ld	s7,184(sp)
    80200568:	6c0e                	ld	s8,192(sp)
    8020056a:	6cae                	ld	s9,200(sp)
    8020056c:	6d4e                	ld	s10,208(sp)
    8020056e:	6dee                	ld	s11,216(sp)
    80200570:	7e0e                	ld	t3,224(sp)
    80200572:	7eae                	ld	t4,232(sp)
    80200574:	7f4e                	ld	t5,240(sp)
    80200576:	7fee                	ld	t6,248(sp)
    80200578:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020057a:	10200073          	sret

000000008020057e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020057e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200582:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200584:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200588:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020058a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020058e:	f022                	sd	s0,32(sp)
    80200590:	ec26                	sd	s1,24(sp)
    80200592:	e84a                	sd	s2,16(sp)
    80200594:	f406                	sd	ra,40(sp)
    80200596:	e44e                	sd	s3,8(sp)
    80200598:	84aa                	mv	s1,a0
    8020059a:	892e                	mv	s2,a1
    8020059c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005a0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005a2:	03067e63          	bleu	a6,a2,802005de <printnum+0x60>
    802005a6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005a8:	00805763          	blez	s0,802005b6 <printnum+0x38>
    802005ac:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005ae:	85ca                	mv	a1,s2
    802005b0:	854e                	mv	a0,s3
    802005b2:	9482                	jalr	s1
        while (-- width > 0)
    802005b4:	fc65                	bnez	s0,802005ac <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005b6:	1a02                	slli	s4,s4,0x20
    802005b8:	020a5a13          	srli	s4,s4,0x20
    802005bc:	00001797          	auipc	a5,0x1
    802005c0:	bb478793          	addi	a5,a5,-1100 # 80201170 <error_string+0x38>
    802005c4:	9a3e                	add	s4,s4,a5
}
    802005c6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005c8:	000a4503          	lbu	a0,0(s4)
}
    802005cc:	70a2                	ld	ra,40(sp)
    802005ce:	69a2                	ld	s3,8(sp)
    802005d0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005d2:	85ca                	mv	a1,s2
    802005d4:	8326                	mv	t1,s1
}
    802005d6:	6942                	ld	s2,16(sp)
    802005d8:	64e2                	ld	s1,24(sp)
    802005da:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005dc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802005de:	03065633          	divu	a2,a2,a6
    802005e2:	8722                	mv	a4,s0
    802005e4:	f9bff0ef          	jal	ra,8020057e <printnum>
    802005e8:	b7f9                	j	802005b6 <printnum+0x38>

00000000802005ea <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005ea:	7119                	addi	sp,sp,-128
    802005ec:	f4a6                	sd	s1,104(sp)
    802005ee:	f0ca                	sd	s2,96(sp)
    802005f0:	e8d2                	sd	s4,80(sp)
    802005f2:	e4d6                	sd	s5,72(sp)
    802005f4:	e0da                	sd	s6,64(sp)
    802005f6:	fc5e                	sd	s7,56(sp)
    802005f8:	f862                	sd	s8,48(sp)
    802005fa:	f06a                	sd	s10,32(sp)
    802005fc:	fc86                	sd	ra,120(sp)
    802005fe:	f8a2                	sd	s0,112(sp)
    80200600:	ecce                	sd	s3,88(sp)
    80200602:	f466                	sd	s9,40(sp)
    80200604:	ec6e                	sd	s11,24(sp)
    80200606:	892a                	mv	s2,a0
    80200608:	84ae                	mv	s1,a1
    8020060a:	8d32                	mv	s10,a2
    8020060c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020060e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200610:	00001a17          	auipc	s4,0x1
    80200614:	9cca0a13          	addi	s4,s4,-1588 # 80200fdc <etext+0x5f6>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200618:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020061c:	00001c17          	auipc	s8,0x1
    80200620:	b1cc0c13          	addi	s8,s8,-1252 # 80201138 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200624:	000d4503          	lbu	a0,0(s10)
    80200628:	02500793          	li	a5,37
    8020062c:	001d0413          	addi	s0,s10,1
    80200630:	00f50e63          	beq	a0,a5,8020064c <vprintfmt+0x62>
            if (ch == '\0') {
    80200634:	c521                	beqz	a0,8020067c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200636:	02500993          	li	s3,37
    8020063a:	a011                	j	8020063e <vprintfmt+0x54>
            if (ch == '\0') {
    8020063c:	c121                	beqz	a0,8020067c <vprintfmt+0x92>
            putch(ch, putdat);
    8020063e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200640:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200642:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200644:	fff44503          	lbu	a0,-1(s0)
    80200648:	ff351ae3          	bne	a0,s3,8020063c <vprintfmt+0x52>
    8020064c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200650:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200654:	4981                	li	s3,0
    80200656:	4801                	li	a6,0
        width = precision = -1;
    80200658:	5cfd                	li	s9,-1
    8020065a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    8020065c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200660:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200662:	fdd6069b          	addiw	a3,a2,-35
    80200666:	0ff6f693          	andi	a3,a3,255
    8020066a:	00140d13          	addi	s10,s0,1
    8020066e:	20d5e563          	bltu	a1,a3,80200878 <vprintfmt+0x28e>
    80200672:	068a                	slli	a3,a3,0x2
    80200674:	96d2                	add	a3,a3,s4
    80200676:	4294                	lw	a3,0(a3)
    80200678:	96d2                	add	a3,a3,s4
    8020067a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020067c:	70e6                	ld	ra,120(sp)
    8020067e:	7446                	ld	s0,112(sp)
    80200680:	74a6                	ld	s1,104(sp)
    80200682:	7906                	ld	s2,96(sp)
    80200684:	69e6                	ld	s3,88(sp)
    80200686:	6a46                	ld	s4,80(sp)
    80200688:	6aa6                	ld	s5,72(sp)
    8020068a:	6b06                	ld	s6,64(sp)
    8020068c:	7be2                	ld	s7,56(sp)
    8020068e:	7c42                	ld	s8,48(sp)
    80200690:	7ca2                	ld	s9,40(sp)
    80200692:	7d02                	ld	s10,32(sp)
    80200694:	6de2                	ld	s11,24(sp)
    80200696:	6109                	addi	sp,sp,128
    80200698:	8082                	ret
    if (lflag >= 2) {
    8020069a:	4705                	li	a4,1
    8020069c:	008a8593          	addi	a1,s5,8
    802006a0:	01074463          	blt	a4,a6,802006a8 <vprintfmt+0xbe>
    else if (lflag) {
    802006a4:	26080363          	beqz	a6,8020090a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    802006a8:	000ab603          	ld	a2,0(s5)
    802006ac:	46c1                	li	a3,16
    802006ae:	8aae                	mv	s5,a1
    802006b0:	a06d                	j	8020075a <vprintfmt+0x170>
            goto reswitch;
    802006b2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802006b6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    802006b8:	846a                	mv	s0,s10
            goto reswitch;
    802006ba:	b765                	j	80200662 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    802006bc:	000aa503          	lw	a0,0(s5)
    802006c0:	85a6                	mv	a1,s1
    802006c2:	0aa1                	addi	s5,s5,8
    802006c4:	9902                	jalr	s2
            break;
    802006c6:	bfb9                	j	80200624 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006c8:	4705                	li	a4,1
    802006ca:	008a8993          	addi	s3,s5,8
    802006ce:	01074463          	blt	a4,a6,802006d6 <vprintfmt+0xec>
    else if (lflag) {
    802006d2:	22080463          	beqz	a6,802008fa <vprintfmt+0x310>
        return va_arg(*ap, long);
    802006d6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    802006da:	24044463          	bltz	s0,80200922 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    802006de:	8622                	mv	a2,s0
    802006e0:	8ace                	mv	s5,s3
    802006e2:	46a9                	li	a3,10
    802006e4:	a89d                	j	8020075a <vprintfmt+0x170>
            err = va_arg(ap, int);
    802006e6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006ea:	4719                	li	a4,6
            err = va_arg(ap, int);
    802006ec:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    802006ee:	41f7d69b          	sraiw	a3,a5,0x1f
    802006f2:	8fb5                	xor	a5,a5,a3
    802006f4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006f8:	1ad74363          	blt	a4,a3,8020089e <vprintfmt+0x2b4>
    802006fc:	00369793          	slli	a5,a3,0x3
    80200700:	97e2                	add	a5,a5,s8
    80200702:	639c                	ld	a5,0(a5)
    80200704:	18078d63          	beqz	a5,8020089e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200708:	86be                	mv	a3,a5
    8020070a:	00001617          	auipc	a2,0x1
    8020070e:	b1660613          	addi	a2,a2,-1258 # 80201220 <error_string+0xe8>
    80200712:	85a6                	mv	a1,s1
    80200714:	854a                	mv	a0,s2
    80200716:	240000ef          	jal	ra,80200956 <printfmt>
    8020071a:	b729                	j	80200624 <vprintfmt+0x3a>
            lflag ++;
    8020071c:	00144603          	lbu	a2,1(s0)
    80200720:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200722:	846a                	mv	s0,s10
            goto reswitch;
    80200724:	bf3d                	j	80200662 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200726:	4705                	li	a4,1
    80200728:	008a8593          	addi	a1,s5,8
    8020072c:	01074463          	blt	a4,a6,80200734 <vprintfmt+0x14a>
    else if (lflag) {
    80200730:	1e080263          	beqz	a6,80200914 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200734:	000ab603          	ld	a2,0(s5)
    80200738:	46a1                	li	a3,8
    8020073a:	8aae                	mv	s5,a1
    8020073c:	a839                	j	8020075a <vprintfmt+0x170>
            putch('0', putdat);
    8020073e:	03000513          	li	a0,48
    80200742:	85a6                	mv	a1,s1
    80200744:	e03e                	sd	a5,0(sp)
    80200746:	9902                	jalr	s2
            putch('x', putdat);
    80200748:	85a6                	mv	a1,s1
    8020074a:	07800513          	li	a0,120
    8020074e:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200750:	0aa1                	addi	s5,s5,8
    80200752:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200756:	6782                	ld	a5,0(sp)
    80200758:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    8020075a:	876e                	mv	a4,s11
    8020075c:	85a6                	mv	a1,s1
    8020075e:	854a                	mv	a0,s2
    80200760:	e1fff0ef          	jal	ra,8020057e <printnum>
            break;
    80200764:	b5c1                	j	80200624 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200766:	000ab603          	ld	a2,0(s5)
    8020076a:	0aa1                	addi	s5,s5,8
    8020076c:	1c060663          	beqz	a2,80200938 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200770:	00160413          	addi	s0,a2,1
    80200774:	17b05c63          	blez	s11,802008ec <vprintfmt+0x302>
    80200778:	02d00593          	li	a1,45
    8020077c:	14b79263          	bne	a5,a1,802008c0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200780:	00064783          	lbu	a5,0(a2)
    80200784:	0007851b          	sext.w	a0,a5
    80200788:	c905                	beqz	a0,802007b8 <vprintfmt+0x1ce>
    8020078a:	000cc563          	bltz	s9,80200794 <vprintfmt+0x1aa>
    8020078e:	3cfd                	addiw	s9,s9,-1
    80200790:	036c8263          	beq	s9,s6,802007b4 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200794:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200796:	18098463          	beqz	s3,8020091e <vprintfmt+0x334>
    8020079a:	3781                	addiw	a5,a5,-32
    8020079c:	18fbf163          	bleu	a5,s7,8020091e <vprintfmt+0x334>
                    putch('?', putdat);
    802007a0:	03f00513          	li	a0,63
    802007a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007a6:	0405                	addi	s0,s0,1
    802007a8:	fff44783          	lbu	a5,-1(s0)
    802007ac:	3dfd                	addiw	s11,s11,-1
    802007ae:	0007851b          	sext.w	a0,a5
    802007b2:	fd61                	bnez	a0,8020078a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    802007b4:	e7b058e3          	blez	s11,80200624 <vprintfmt+0x3a>
    802007b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007ba:	85a6                	mv	a1,s1
    802007bc:	02000513          	li	a0,32
    802007c0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007c2:	e60d81e3          	beqz	s11,80200624 <vprintfmt+0x3a>
    802007c6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007c8:	85a6                	mv	a1,s1
    802007ca:	02000513          	li	a0,32
    802007ce:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007d0:	fe0d94e3          	bnez	s11,802007b8 <vprintfmt+0x1ce>
    802007d4:	bd81                	j	80200624 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007d6:	4705                	li	a4,1
    802007d8:	008a8593          	addi	a1,s5,8
    802007dc:	01074463          	blt	a4,a6,802007e4 <vprintfmt+0x1fa>
    else if (lflag) {
    802007e0:	12080063          	beqz	a6,80200900 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    802007e4:	000ab603          	ld	a2,0(s5)
    802007e8:	46a9                	li	a3,10
    802007ea:	8aae                	mv	s5,a1
    802007ec:	b7bd                	j	8020075a <vprintfmt+0x170>
    802007ee:	00144603          	lbu	a2,1(s0)
            padc = '-';
    802007f2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    802007f6:	846a                	mv	s0,s10
    802007f8:	b5ad                	j	80200662 <vprintfmt+0x78>
            putch(ch, putdat);
    802007fa:	85a6                	mv	a1,s1
    802007fc:	02500513          	li	a0,37
    80200800:	9902                	jalr	s2
            break;
    80200802:	b50d                	j	80200624 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200804:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200808:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020080c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020080e:	846a                	mv	s0,s10
            if (width < 0)
    80200810:	e40dd9e3          	bgez	s11,80200662 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200814:	8de6                	mv	s11,s9
    80200816:	5cfd                	li	s9,-1
    80200818:	b5a9                	j	80200662 <vprintfmt+0x78>
            goto reswitch;
    8020081a:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020081e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200822:	846a                	mv	s0,s10
            goto reswitch;
    80200824:	bd3d                	j	80200662 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200826:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020082a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020082e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200830:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200834:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200838:	fcd56ce3          	bltu	a0,a3,80200810 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    8020083c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020083e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200842:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200846:	0196873b          	addw	a4,a3,s9
    8020084a:	0017171b          	slliw	a4,a4,0x1
    8020084e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200852:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200856:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020085a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020085e:	fcd57fe3          	bleu	a3,a0,8020083c <vprintfmt+0x252>
    80200862:	b77d                	j	80200810 <vprintfmt+0x226>
            if (width < 0)
    80200864:	fffdc693          	not	a3,s11
    80200868:	96fd                	srai	a3,a3,0x3f
    8020086a:	00ddfdb3          	and	s11,s11,a3
    8020086e:	00144603          	lbu	a2,1(s0)
    80200872:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    80200874:	846a                	mv	s0,s10
    80200876:	b3f5                	j	80200662 <vprintfmt+0x78>
            putch('%', putdat);
    80200878:	85a6                	mv	a1,s1
    8020087a:	02500513          	li	a0,37
    8020087e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200880:	fff44703          	lbu	a4,-1(s0)
    80200884:	02500793          	li	a5,37
    80200888:	8d22                	mv	s10,s0
    8020088a:	d8f70de3          	beq	a4,a5,80200624 <vprintfmt+0x3a>
    8020088e:	02500713          	li	a4,37
    80200892:	1d7d                	addi	s10,s10,-1
    80200894:	fffd4783          	lbu	a5,-1(s10)
    80200898:	fee79de3          	bne	a5,a4,80200892 <vprintfmt+0x2a8>
    8020089c:	b361                	j	80200624 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020089e:	00001617          	auipc	a2,0x1
    802008a2:	97260613          	addi	a2,a2,-1678 # 80201210 <error_string+0xd8>
    802008a6:	85a6                	mv	a1,s1
    802008a8:	854a                	mv	a0,s2
    802008aa:	0ac000ef          	jal	ra,80200956 <printfmt>
    802008ae:	bb9d                	j	80200624 <vprintfmt+0x3a>
                p = "(null)";
    802008b0:	00001617          	auipc	a2,0x1
    802008b4:	95860613          	addi	a2,a2,-1704 # 80201208 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008b8:	00001417          	auipc	s0,0x1
    802008bc:	95140413          	addi	s0,s0,-1711 # 80201209 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008c0:	8532                	mv	a0,a2
    802008c2:	85e6                	mv	a1,s9
    802008c4:	e032                	sd	a2,0(sp)
    802008c6:	e43e                	sd	a5,8(sp)
    802008c8:	0e6000ef          	jal	ra,802009ae <strnlen>
    802008cc:	40ad8dbb          	subw	s11,s11,a0
    802008d0:	6602                	ld	a2,0(sp)
    802008d2:	01b05d63          	blez	s11,802008ec <vprintfmt+0x302>
    802008d6:	67a2                	ld	a5,8(sp)
    802008d8:	2781                	sext.w	a5,a5
    802008da:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    802008dc:	6522                	ld	a0,8(sp)
    802008de:	85a6                	mv	a1,s1
    802008e0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008e2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008e4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008e6:	6602                	ld	a2,0(sp)
    802008e8:	fe0d9ae3          	bnez	s11,802008dc <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008ec:	00064783          	lbu	a5,0(a2)
    802008f0:	0007851b          	sext.w	a0,a5
    802008f4:	e8051be3          	bnez	a0,8020078a <vprintfmt+0x1a0>
    802008f8:	b335                	j	80200624 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802008fa:	000aa403          	lw	s0,0(s5)
    802008fe:	bbf1                	j	802006da <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200900:	000ae603          	lwu	a2,0(s5)
    80200904:	46a9                	li	a3,10
    80200906:	8aae                	mv	s5,a1
    80200908:	bd89                	j	8020075a <vprintfmt+0x170>
    8020090a:	000ae603          	lwu	a2,0(s5)
    8020090e:	46c1                	li	a3,16
    80200910:	8aae                	mv	s5,a1
    80200912:	b5a1                	j	8020075a <vprintfmt+0x170>
    80200914:	000ae603          	lwu	a2,0(s5)
    80200918:	46a1                	li	a3,8
    8020091a:	8aae                	mv	s5,a1
    8020091c:	bd3d                	j	8020075a <vprintfmt+0x170>
                    putch(ch, putdat);
    8020091e:	9902                	jalr	s2
    80200920:	b559                	j	802007a6 <vprintfmt+0x1bc>
                putch('-', putdat);
    80200922:	85a6                	mv	a1,s1
    80200924:	02d00513          	li	a0,45
    80200928:	e03e                	sd	a5,0(sp)
    8020092a:	9902                	jalr	s2
                num = -(long long)num;
    8020092c:	8ace                	mv	s5,s3
    8020092e:	40800633          	neg	a2,s0
    80200932:	46a9                	li	a3,10
    80200934:	6782                	ld	a5,0(sp)
    80200936:	b515                	j	8020075a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200938:	01b05663          	blez	s11,80200944 <vprintfmt+0x35a>
    8020093c:	02d00693          	li	a3,45
    80200940:	f6d798e3          	bne	a5,a3,802008b0 <vprintfmt+0x2c6>
    80200944:	00001417          	auipc	s0,0x1
    80200948:	8c540413          	addi	s0,s0,-1851 # 80201209 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020094c:	02800513          	li	a0,40
    80200950:	02800793          	li	a5,40
    80200954:	bd1d                	j	8020078a <vprintfmt+0x1a0>

0000000080200956 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200956:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200958:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020095c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020095e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200960:	ec06                	sd	ra,24(sp)
    80200962:	f83a                	sd	a4,48(sp)
    80200964:	fc3e                	sd	a5,56(sp)
    80200966:	e0c2                	sd	a6,64(sp)
    80200968:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    8020096a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020096c:	c7fff0ef          	jal	ra,802005ea <vprintfmt>
}
    80200970:	60e2                	ld	ra,24(sp)
    80200972:	6161                	addi	sp,sp,80
    80200974:	8082                	ret

0000000080200976 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200976:	00003797          	auipc	a5,0x3
    8020097a:	68a78793          	addi	a5,a5,1674 # 80204000 <bootstacktop>
    __asm__ volatile (
    8020097e:	6398                	ld	a4,0(a5)
    80200980:	4781                	li	a5,0
    80200982:	88ba                	mv	a7,a4
    80200984:	852a                	mv	a0,a0
    80200986:	85be                	mv	a1,a5
    80200988:	863e                	mv	a2,a5
    8020098a:	00000073          	ecall
    8020098e:	87aa                	mv	a5,a0
}
    80200990:	8082                	ret

0000000080200992 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200992:	00003797          	auipc	a5,0x3
    80200996:	67678793          	addi	a5,a5,1654 # 80204008 <edata>
    __asm__ volatile (
    8020099a:	6398                	ld	a4,0(a5)
    8020099c:	4781                	li	a5,0
    8020099e:	88ba                	mv	a7,a4
    802009a0:	852a                	mv	a0,a0
    802009a2:	85be                	mv	a1,a5
    802009a4:	863e                	mv	a2,a5
    802009a6:	00000073          	ecall
    802009aa:	87aa                	mv	a5,a0
}
    802009ac:	8082                	ret

00000000802009ae <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802009ae:	c185                	beqz	a1,802009ce <strnlen+0x20>
    802009b0:	00054783          	lbu	a5,0(a0)
    802009b4:	cf89                	beqz	a5,802009ce <strnlen+0x20>
    size_t cnt = 0;
    802009b6:	4781                	li	a5,0
    802009b8:	a021                	j	802009c0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802009ba:	00074703          	lbu	a4,0(a4)
    802009be:	c711                	beqz	a4,802009ca <strnlen+0x1c>
        cnt ++;
    802009c0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009c2:	00f50733          	add	a4,a0,a5
    802009c6:	fef59ae3          	bne	a1,a5,802009ba <strnlen+0xc>
    }
    return cnt;
}
    802009ca:	853e                	mv	a0,a5
    802009cc:	8082                	ret
    size_t cnt = 0;
    802009ce:	4781                	li	a5,0
}
    802009d0:	853e                	mv	a0,a5
    802009d2:	8082                	ret

00000000802009d4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802009d4:	ca01                	beqz	a2,802009e4 <memset+0x10>
    802009d6:	962a                	add	a2,a2,a0
    char *p = s;
    802009d8:	87aa                	mv	a5,a0
        *p ++ = c;
    802009da:	0785                	addi	a5,a5,1
    802009dc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009e0:	fec79de3          	bne	a5,a2,802009da <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009e4:	8082                	ret
