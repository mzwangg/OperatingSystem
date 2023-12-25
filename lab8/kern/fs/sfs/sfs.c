#include <defs.h>
#include <sfs.h>
#include <error.h>
#include <assert.h>

/*
 * sfs_init - mount sfs on disk0
 *
 * CALL GRAPH:
 *   kern_init-->fs_init-->sfs_init
 */
void
sfs_init(void) {
    int ret;
    if ((ret = sfs_mount("disk0")) != 0) {  //完成对Simple FS的初始化工作，并把此实例文件系统挂在虚拟文件系统中
        panic("failed: sfs: sfs_mount: %e.\n", ret);
    }
}

