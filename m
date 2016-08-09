From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  9 Aug 2016 15:46:37 +0000 (UTC)
Subject: master - test: fix lvcreate-large-raid.sh
Message-ID: <20160809154637.7A60160ACD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48e14390c13d26e86c359532d796258608414cee
Commit:        48e14390c13d26e86c359532d796258608414cee
Parent:        3d3f62e10acee60bd61a401b76f009a611d22f9e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 9 17:45:37 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 9 17:45:37 2016 +0200

test: fix lvcreate-large-raid.sh

RAID6 LVs may not be created with --nosync or data corruption
may occur in case of device failures.  The underlying MD raid6
personality used to drive the RaidLV performs read-modify-write
updates on stripes and thus relies on properly written parity
(P and Q Syndromes) during initial synchronization.

Once on it, enhance test to create/extend more and
larger RaidLVs and check sync/nosync status.
---
 test/shell/lvcreate-large-raid.sh |   63 ++++++++++++++++++++++++++++--------
 1 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 133e517..088d995 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012,2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -21,13 +21,13 @@ aux can_use_16T || skip
 
 aux have_raid 1 3 0 || skip
 
-aux prepare_vg 5
+aux prepare_vg 5 32
 
-lvcreate --type snapshot -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+# Fake 5 PiB volume group $vg1 via snapshot LVs
+for device in "$lv1" "$lv2" "$lv3" "$lv4" "$lv5"
+do
+	lvcreate --type snapshot -s -l 20%FREE -n $device $vg --virtualsize 1P
+done
 
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
@@ -35,41 +35,76 @@ lvcreate --type snapshot -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR"/$vg/$lv[12345]
-vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
+vgcreate -s 2M $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
+
+# Delay PVs so that resynchronization doesn't fill
+# the snapshots before removal of the RaidLV
+for device in "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+do
+	aux delay_dev "$device" 0 1
+done
 
 # bz837927 START
 
 #
 # Create large RAID LVs
 #
-# We need '--nosync' or our virtual devices won't work
+
+# 200 TiB raid1
 lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
+aux check_status_chars $vg1 $lv1 "AA"
+lvremove -ff $vg1
+
+# 1 PiB raid1
+lvcreate --type raid1 -m 1 -L 1P -n $lv1 $vg1 --nosync
+check lv_field $vg1/$lv1 size "1.00p"
+aux check_status_chars $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
-for segtype in raid4 raid5 raid6; do
+# 750 TiB raid4/5
+for segtype in raid4 raid5; do
         lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
         check lv_field $vg1/$lv1 size "750.00t"
+        aux check_status_chars $vg1 $lv1 "AAAA"
         lvremove -ff $vg1
 done
 
+# 750 TiB raid6 (with --nosync rejection check)
+[ aux have_raid 1 9 0 ] && not lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1 --nosync
+lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1
+check lv_field $vg1/$lv1 size "750.00t"
+aux check_status_chars $vg1 $lv1 "aaaaa"
+lvremove -ff $vg1
+
+# 1 PiB raid6 (with --nosync rejection check), then extend up to 2 PiB
+[ aux have_raid 1 9 0 ] && not lvcreate --type raid6 -i 3 -L -L 1P -n $lv1 $vg1 --nosync
+lvcreate --type raid6 -i 3 -L 1P -n $lv1 $vg1
+check lv_field $vg1/$lv1 size "1.00p"
+aux check_status_chars $vg1 $lv1 "aaaaa"
+lvextend -L +1P $vg1/$lv1
+check lv_field $vg1/$lv1 size "2.00p"
+aux check_status_chars $vg1 $lv1 "aaaaa"
+lvremove -ff $vg1
+
 #
-# Convert large linear to RAID1 (belong in different test script?)
+# Convert large 200 TiB linear to RAID1 (belong in different test script?)
 #
 lvcreate -aey -L 200T -n $lv1 $vg1
-# Need to deactivate or the up-convert will start sync'ing
-lvchange -an $vg1/$lv1
 lvconvert --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
+aux check_status_chars $vg1 $lv1 "aa"
 lvremove -ff $vg1
 
 #
-# Extending large RAID LV (belong in different script?)
+# Extending large 200 TiB RAID LV to 400 TiB (belong in different script?)
 #
 lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
+aux check_status_chars $vg1 $lv1 "AA"
 lvextend -L +200T $vg1/$lv1
 check lv_field $vg1/$lv1 size "400.00t"
+aux check_status_chars $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 # bz837927 END


