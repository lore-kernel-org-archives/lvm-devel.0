From: lixiaokeng <lixiaokeng@huawei.com>
Date: Thu, 9 Jul 2020 15:02:51 +0800
Subject: master - multipathd: fix fd leak when iscsi device logs in
Message-ID: <6eb10725-456f-de68-e927-1f5a9771c16c@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When one iscsi device logs in and logs out several times, the
number of fd, which points to '/dev/mapper/control', increases in
/proc/<multipathd-pid>/fd as follows,
[root at localhost fd]# ll | grep control
lrwx------. 1 root root 64 Jul  6 16:30 10 -> /dev/mapper/control
lrwx------. 1 root root 64 Jul  6 16:30 11 -> /dev/mapper/control
lrwx------. 1 root root 64 Jul  6 16:30 12 -> /dev/mapper/control
lrwx------. 1 root root 64 Jul  6 16:30 13 -> /dev/mapper/control
lrwx------. 1 root root 64 Jul  6 16:30 5 -> /dev/mapper/control
lrwx------. 1 root root 64 Jul  6 16:30 9 -> /dev/mapper/control

This is because that both wait_dmevents thread and uevqloop thread in
multipathd will concurrently open and use public _control_fd which points
to '/dev/mapper/control' by calling _open_and_assign_control_fd func.
Although, the legality of _control_fd will be checked before open
'/dev/mapper/control' in _open_control func. Due to lack of lock protection,
both wait_dmevents thread and uevqloop thread may concurrently find
_control_fd illegal, and concurrently open '/dev/mapper/control' and reset
the public _control_fd to their new fd, then finally the allocated fd in faster
one will leak.

The procedure details given as follows,
1. wait_dmevents thread
wait_dmevents
->dmevent_loop
    ->dm_get_events
        ->dm_task_run
            ->_open_control
                ->_open_and_assign_control_fd

2. uevqloop thread
uevqloop
->uevent_dispatch
    ->service_uevq
        ->ev_add_path
            ->__setup_multipath
                ->dm_get_info
                    ->dm_task_run
                        ->_open_control
                            ->_open_and_assign_control_fd

3. _open_control func
_open_control
    -> check whether _control_fd is legal, if _control_fd is legal, return 1
    -> _create_control
    ->_open_and_assign_control_fd
        -> open '/dev/mapper/control' and set _control_fd to the new fd

Here, we add _control_fd_mutex to protect the procedure of
open('/dev/mapper/control') in _open_and_assign_control_fd func.

Reported-by: Tianxiong Lu <lutianxiong@huawei.com>
Signed-off-by: lixiaokeng <lixiaokeng@huawei.com>
Signed-off-by: Guanghao Wu <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 libdm/ioctl/libdm-iface.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 7ad549c..7168369 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -23,6 +23,7 @@
 #include <sys/ioctl.h>
 #include <sys/utsname.h>
 #include <limits.h>
+#include <pthread.h>

 #ifdef __linux__
 #  include "libdm/misc/kdev_t.h"
@@ -81,6 +82,7 @@ static dm_bitset_t _dm_bitset = NULL;
 static uint32_t _dm_device_major = 0;

 static int _control_fd = -1;
+static pthread_mutex_t _control_fd_mutex = PTHREAD_MUTEX_INITIALIZER;
 static int _hold_control_fd_open = 0;
 static int _version_checked = 0;
 static int _version_ok = 1;
@@ -404,10 +406,19 @@ static void _close_control_fd(void)
 #ifdef DM_IOCTLS
 static int _open_and_assign_control_fd(const char *control)
 {
+	pthread_mutex_lock(&_control_fd_mutex);
+
+	if (_control_fd != -1) {
+		pthread_mutex_unlock(&_control_fd_mutex);
+		return 1;
+	}
+
 	if ((_control_fd = open(control, O_RDWR)) < 0) {
 		log_sys_error("open", control);
+		pthread_mutex_unlock(&_control_fd_mutex);
 		return 0;
 	}
+	pthread_mutex_unlock(&_control_fd_mutex);

 	return 1;
 }
-- 
1.8.3.1


