From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  9 Aug 2016 16:16:55 +0000 (UTC)
Subject: master - test: fix/enhance lvcreate-large-raid*.sh
Message-ID: <20160809161655.E9AAB60243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb9789f2b3404893dcb92cfc2d1eeec002c90140
Commit:        bb9789f2b3404893dcb92cfc2d1eeec002c90140
Parent:        48e14390c13d26e86c359532d796258608414cee
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 9 18:16:01 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 9 18:16:01 2016 +0200

test: fix/enhance lvcreate-large-raid*.sh

Multi-step extend to even larger raid10 LV lvcreate-large-raid.sh.

Comment fixes.
---
 test/shell/lvcreate-large-raid.sh   |    1 +
 test/shell/lvcreate-large-raid10.sh |   23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 088d995..24f4fb8 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -109,4 +109,5 @@ lvremove -ff $vg1
 
 # bz837927 END
 
+vgremove -ff $vg1
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index e249e77..33af630 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012,2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -22,24 +22,31 @@ aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
 
-lvcreate --type snapshot -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
-lvcreate --type snapshot -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+# Fake ~2.5PiB volume group $vg1 via snapshot LVs
+for device in "$lv1" "$lv2" "$lv3" "$lv4" "$lv5" 
+do
+	lvcreate --type snapshot -s -l 20%FREE -n $device $vg --virtualsize 520T
+done
 
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR"/$vg/$lv[12345]
 vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
 
+
 #
-# Create large RAID LVs
+# Create and extend large RAID10 LV
 #
 # We need '--nosync' or our virtual devices won't work
 
 lvcreate --type raid10 -m 1 -i 2 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
-vgremove -ff $vg1
+lvextend -L +200T $vg1/$lv1
+check lv_field $vg1/$lv1 size "400.00t"
+lvextend -L +100T $vg1/$lv1
+check lv_field $vg1/$lv1 size "500.00t"
+lvextend -L 1P $vg1/$lv1
+check lv_field $vg1/$lv1 size "1.00p"
 
+vgremove -ff $vg1
 vgremove -ff $vg


