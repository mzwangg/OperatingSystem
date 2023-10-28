#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

list_entry_t pra_list_head;

// lru初始化：初始化pra_list_head并赋值给mm->sm_priv
static int
_lru_init_mm(struct mm_struct *mm){   
    //初始化pra_list_head并赋值给mm->sm_priv
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
    return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in){
    // 得到head和entry
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && head != NULL);

    //将entry加到首位
    list_add(head, entry);

    return 0;
}

static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick){
    // 得到head
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);

    //换出最后一个页面
    list_entry_t* entry = list_prev(head);
    if (entry != head) {// 如果链表不为空
        list_del(entry);//将最后一个页面从链表中删除
        *ptr_page = le2page(entry, pra_page_link);//得到对应的page
    } else {//为空时返回的页面为NULL
        *ptr_page = NULL;
    }

    return 0;
}

static void
move2begin(uintptr_t addr) 
{
    // 遍历链表找到对应虚拟地址的页面
    for (list_entry_t * pos = list_next(&pra_list_head); pos != (&pra_list_head); pos = list_next(pos))
    {
        struct Page *page = le2page(pos, pra_page_link); 
        if (page->pra_vaddr == addr) {
            // 从链表中找到 addr 对应的 page ，将其放到链表末尾
            list_del(&(page->pra_page_link));
            list_add(&pra_list_head, &(page->pra_page_link));
            break; 
        }
    }
}

static void
read(uintptr_t addr, unsigned char* value){
    *value = *(unsigned char *)addr;
    move2begin(addr);
}

static void
write(uintptr_t addr, unsigned char value){
    *(unsigned char *)addr = value;
    move2begin(addr);
}

// 通过判断链表中page的pra_vaddr是否与addr相等来判断该页面是否换出
static bool
is_swap(uintptr_t addr){
    for (list_entry_t * pos = list_next(&pra_list_head); pos != (&pra_list_head); pos = list_next(pos))
    {
        struct Page *page = le2page(pos, pra_page_link); 
        if (page->pra_vaddr == addr) {
            return false;
        }
    }

    return true;
}

static int
_lru_check_swap(void) {
    //用于读取值
    unsigned char value;

    // 1. 写普通页面
    //此时队列为4, 3, 2, 1
    write(0x1000, 0x1a);
    //判断是否没有换出页面
    assert(is_swap(0x5000));
    //判断是否成功在0x1000写入
    read(0x1000, &value);
    assert(value==0x1a);
    //pgfault_num不变
    assert(pgfault_num == 4);

    // 2. 写换出页面
    //此时队列为1, 4, 3, 2，所以会先交换0x2000
    write(0x5000, 0x2a);
    //判断是否换出0x2000
    assert(is_swap(0x2000));
    //判断是否成功在0x5000写入0x2a
    read(0x5000, &value);
    assert(value==0x2a);
    //pgfault_num加1
    assert(pgfault_num == 5);

    // 3. 读普通页面
    //此时队列为5, 1, 4, 3
    read(0x1000, &value);
    //判断是否没有换出页面
    assert(is_swap(0x2000));
    //判断值是否正确
    assert(value==0x1a);
    //pgfault_num不变
    assert(pgfault_num == 5);

    // 4. 读换出页面
    //此时队列为1, 5, 4, 3，所以会先交换0x3000
    read(0x2000, &value);
    //判断是否换出0x3000
    assert(is_swap(0x3000));
    //pgfault_num加1
    assert(pgfault_num == 6);

    // 5. 多次写
    //此时队列为2, 1, 5, 4
    write(0x1000, 0x3a);
    write(0x3000, 0x3a);
    assert(is_swap(0x4000));
    write(0x5000, 0x3a);
    write(0x4000, 0x3a);
    assert(is_swap(0x2000));
    write(0x2000, 0x3a);
    assert(is_swap(0x1000));
    assert(pgfault_num == 9);

    // 6. 多次读
    //此时队列为2, 4, 5, 3
    read(0x2000, &value);
    read(0x1000, &value);
    assert(is_swap(0x3000));
    read(0x4000, &value);
    read(0x5000, &value);
    read(0x5000, &value);
    assert(pgfault_num == 10);

    // 7. 读写混合
    //此时队列为5, 4, 1, 2
    write(0x4000, 0x3a);
    read(0x2000, &value);
    read(0x1000, &value);
    read(0x5000, &value);
    write(0x2000, 0x3a);
    write(0x1000, 0x3a);
    read(0x3000, &value);
    assert(is_swap(0x4000));
    read(0x2000, &value);
    write(0x3000, 0x3a);
    assert(pgfault_num == 11);

    return 0;
}


static int
_lru_init(void){
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr){
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm){
    return 0; 
}

struct swap_manager swap_manager_lru ={
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
