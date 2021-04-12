From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 10:08:54 +0000 (GMT)
Subject: main - tests: race on md raid still being hit on 5.12-rc6
Message-ID: <20210412100854.73C21384403E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a33388c1ac69cd23d28e3d53c59130726670c98
Commit:        9a33388c1ac69cd23d28e3d53c59130726670c98
Parent:        9eca1312569f89884ca4c0a767d6c603ab7613db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 12 12:04:50 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 12:04:50 2021 +0200

tests: race on md raid still being hit on 5.12-rc6

Still hits the race in initialization:

kernel BUG at drivers/md/raid5.c:7549!
invalid opcode: 0000 [#1] SMP PTI
CPU: 0 PID: 525149 Comm: dmsetup Tainted: G           OEi
    --------- ---  5.12.0-0.rc6.184.fc35.x86_64 #1
Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
RIP: 0010:raid5_run+0x40b/0x4b0 [raid456]
Code: 00 8b 83 3c 01 00 00 39 83 bc 00 00 00 0f 85 ac 00 00 00
      48 c7 44 24 08 00 00 00 00 8b bb 30 01 00 00 85 ff 0f 84
      88 fd ff ff <0f> 0b 48 8b 43 48 48 c7 c6 40 93 92 c0 48
      c7 c7 70 2c 93 c0 48 85
Call Trace:
 md_run+0x4d6/0xbc0
 ? super_validate+0x2e1/0x4b0 [dm_raid]
 raid_ctr+0x133e/0x281b [dm_raid]
 dm_table_add_target+0x167/0x330
 table_load+0x103/0x350
 ctl_ioctl+0x1b4/0x430
 ? dev_suspend+0x2c0/0x2c0
 dm_ctl_ioctl+0xa/0x10
 __x64_sys_ioctl+0x82/0xb0
 do_syscall_64+0x33/0x40
 entry_SYSCALL_64_after_hwframe+0x44/0xae
---
 test/shell/lvconvert-raid-reshape-stripes-load-reload.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 1170e6567..fb4b3d1d1 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -72,7 +72,7 @@ check lv_first_seg_field $vg/$lv1 stripes 16
 
 # Reload table during reshape to test for data corruption
 case "$(uname -r)" in
-  5.[89]*|5.1[01].*|3.10.0-862*|4.18.0-*.el8*)
+  5.[89]*|5.1[012].*|3.10.0-862*|4.18.0-*.el8*)
 	should not echo "Skipping table reload test on on unfixed kernel!!!" ;;
   *)
 for i in {0..5}


