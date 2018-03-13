From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 13 Mar 2018 08:43:31 -0400
Subject: master - test: Skip tests which require too much RAM
Message-ID: <201803131243.w2DChVrT010975@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eae54b67d8b7e6236816aa6c4b9bfa95f81d65fe
Commit:        eae54b67d8b7e6236816aa6c4b9bfa95f81d65fe
Parent:        90512910e5ecf1a4b1538d9d9165cb0f44e2c291
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 13 13:41:33 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 13 13:42:45 2018 +0100

test: Skip tests which require too much RAM

- Tests for RAID reshape under load require too much RAM
---
 test/shell/lvconvert-raid-reshape-load.sh          |    3 +++
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    3 +++
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    6 ++++++
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    3 +++
 4 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index d17b186..23046e5 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -17,6 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
+# FIXME: This test requires 3GB in /dev/shm!
+test $(aux total_mem) -gt $((4096*1024)) || skip
+
 which mkfs.ext4 || skip
 aux have_raid 1 13 1 || skip
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 3fac9a4..e7066be 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -20,6 +20,9 @@ skip
 
 # Test reshaping under io load
 
+# FIXME: This test requires 3GB in /dev/shm!
+test $(aux total_mem) -gt $((4096*1024)) || skip
+
 which mkfs.ext4 || skip
 aux have_raid 1 13 1 || skip
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index f0a71c3..fc463bf 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -17,6 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
+# FIXME: This test requires 3GB in /dev/shm!
+test $(aux total_mem) -gt $((4096*1024)) || skip
+
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
@@ -49,10 +52,13 @@ mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
 mkdir -p $mount_dir/1 $mount_dir/2
 
 echo 3 >/proc/sys/vm/drop_caches
+# FIXME: This is filling up ram disk. Use sane amount of data please! Rate limit the data written!
 cp -r /usr/bin $mount_dir/1 >/dev/null 2>/dev/null &
 cp -r /usr/bin $mount_dir/2 >/dev/null 2>/dev/null &
+# FIXME: should this wait for above two processes and sync then?
 sync &
 
+# FIXME: wait_for_sync - is this really testing anything under load?
 aux wait_for_sync $vg $lv1
 aux delay_dev "$dev2" 0 200
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 785ee76..2143b4c 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -17,6 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
+# FIXME: This test requires 3GB in /dev/shm!
+test $(aux total_mem) -gt $((4096*1024)) || skip
+
 which mkfs.ext4 || skip
 aux have_raid 1 13 1 || skip
 


