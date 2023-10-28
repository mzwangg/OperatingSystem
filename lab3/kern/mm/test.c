// #include <defs.h>
// #include <riscv.h>
// #include <stdio.h>
// #include <string.h>
// #include <swap.h>
// #include <swap_lru.h>
// #include <list.h>


// list_entry_t pra_list_head;

// static int
// _lru_init_mm(struct mm_struct *mm)
// {
//     list_init(&pra_list_head);
//     mm->sm_priv = &pra_list_head;
//     return 0;
// }

// static int
// _lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
// {
//     list_entry_t *head = (list_entry_t *)mm->sm_priv;
//     list_entry_t *entry = &(page->pra_page_link);
 
//     assert(entry != NULL && head != NULL);

//     list_add_before(head, entry);
//     return 0;
// }

// static int
// _lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
// {
//     list_entry_t *head = (list_entry_t *)mm->sm_priv;
//     assert(head != NULL);
//     assert(in_tick == 0);

//     /* Select the victim */
//     list_entry_t *entry = list_next(head);
//     if (entry != head) {
//         // 找到最早被访问的页面
//         struct Page *page = le2page(entry, pra_page_link);
//         list_del(entry);
//         *ptr_page = page;
//     } else {
//         *ptr_page = NULL;
//     }
//     return 0;
// }

// // 定义遍历链表的宏
// #define list_entry_foreach(pos, head) \
//     for (pos = list_next(head); pos != (head); pos = list_next(pos))

// static
// int move_page_to_end(uintptr_t addr) 
// {
//     struct Page *page;
//     list_entry_t *pos;

//     // 遍历链表找到对应虚拟地址的页面
//     list_entry_foreach(pos, &pra_list_head) 
//     {
//         page = le2page(pos, pra_page_link); 
//         if (page->pra_vaddr == addr) {
//             // 从链表中找到 addr 对应的 page ，将其放到链表末尾
//             list_del(&(page->pra_page_link));
//             list_add_before(&pra_list_head, &(page->pra_page_link));
//             break; 
//         }
//     }
//     return 0;
// }

// static int 
// memory_access(uintptr_t addr, uint32_t value, int write) 
// {   
//     int pre_num = pgfault_num; 

//     if (write) {
//         *(unsigned char *)addr = value;
//     } else {
//         value = *(unsigned char *)addr;
//     }
    
//     // 只需处理访存成功的情况
//     if (pgfault_num == pre_num) 
//     {
//         cprintf("Access Finished !\n");
//         move_page_to_end(addr);
//     }
    
//     return 0;
// }

// /* 
// static inline void
// check_content_set(void)
// {
//      *(unsigned char *)0x1000 = 0x0a;
//      assert(pgfault_num==1);
//      *(unsigned char *)0x1010 = 0x0a;
//      assert(pgfault_num==1);
//      *(unsigned char *)0x2000 = 0x0b;
//      assert(pgfault_num==2);
//      *(unsigned char *)0x2010 = 0x0b;
//      assert(pgfault_num==2);
//      *(unsigned char *)0x3000 = 0x0c;
//      assert(pgfault_num==3);
//      *(unsigned char *)0x3010 = 0x0c;
//      assert(pgfault_num==3);
//      *(unsigned char *)0x4000 = 0x0d;
//      assert(pgfault_num==4);
//      *(unsigned char *)0x4010 = 0x0d;
//      assert(pgfault_num==4);
// }
// */

// static int _lru_check_swap(void) 
// {
//     memory_access(0x3000, 0x0c, 1);
//     assert(pgfault_num == 4);
//     memory_access(0x1000, 0x0a, 1);
//     assert(pgfault_num == 4);
//     memory_access(0x2000, 0x0b, 1);
//     assert(pgfault_num == 4);
//     memory_access(0x4000, 0x0d, 1);
//     assert(pgfault_num == 4);
//     memory_access(0x5000, 0x0e, 1);
//     assert(pgfault_num == 5);

//     // 按照 lru 的逻辑 ，0x3000 所对应的页已被换出了
//     // 此时再访问则会导致 page_fault 
//     // 下面的 sample 同理
//     memory_access(0x3000, 0x0c, 1);
//     assert(pgfault_num == 6);
//     memory_access(0x1000, 0x0a, 1);
//     assert(pgfault_num == 7);
//     memory_access(0x2000, 0x0b, 1);
//     assert(pgfault_num == 8);
//     memory_access(0x4000, 0x0d, 1);
//     assert(pgfault_num == 9);

//     return 0;
// }


// static int
// _lru_init(void)
// {
//     return 0;
// }

// static int
// _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
// {
//     return 0;
// }

// static int
// _lru_tick_event(struct mm_struct *mm)
// {
//     return 0;
// }

// struct swap_manager swap_manager_lru =
// {
//      .name            = "lru swap manager",
//      .init            = &_lru_init,
//      .init_mm         = &_lru_init_mm,
//      .tick_event      = &_lru_tick_event,
//      .map_swappable   = &_lru_map_swappable,
//      .set_unswappable = &_lru_set_unswappable,
//      .swap_out_victim = &_lru_swap_out_victim,
//      .check_swap      = &_lru_check_swap,
// };