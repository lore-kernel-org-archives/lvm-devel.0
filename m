From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Jul 2016 14:39:15 +0000 (UTC)
Subject: master - tests: updates for new raid allocation logic
Message-ID: <20160728143915.36590605F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02ddd48c1148052175ac2178f3f762ca0629d6e9
Commit:        02ddd48c1148052175ac2178f3f762ca0629d6e9
Parent:        edb5d12463b60b22ba6683cd9e2fd12b07f09fcf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 28 16:37:20 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 28 16:37:20 2016 +0200

tests: updates for new raid allocation logic

(with backward compatible settings user as well to check old logic
is still available when needed).
---
 test/shell/lvcreate-raid.sh   |   18 +++++++++++++++++-
 test/shell/lvcreate-raid10.sh |   26 +++++++++++++++++++++-----
 2 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 19c8c61..66434b0 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -178,6 +178,22 @@ lv_devices $vg raid6 5
 lvremove -ff $vg
 
 # Implicit count comes from total #PVs in VG (always 2 for mirror though)
+# Defaults -i2 even though more PVs listed
+lvcreate --type raid1 -l1 -an -Zn -n raid1 $vg
+lv_devices $vg raid1 2
+lvcreate --type raid5 -l2 -an -Zn -n raid5 $vg
+lv_devices $vg raid5 3
+lvcreate --type raid6 -l3 -an -Zn -n raid6 $vg
+lv_devices $vg raid6 5
+lvremove -ff $vg
+
+
+########################################################
+# Try again with backward compatible old logic applied #
+########################################################
+aux lvmconf 'allocation/raid_stripe_all_devices = 1'
+
+# Implicit count comes from total #PVs in VG (always 2 for mirror though)
 lvcreate --type raid1 -l1 -an -Zn -n raid1 $vg
 lv_devices $vg raid1 2
 lvcreate --type raid5 -l2 -an -Zn -n raid5 $vg
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 2cd5ac0..bebe221 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -67,16 +67,32 @@ lvremove -ff $vg
 not lvcreate --type raid10 -l2 $vg "$dev1" "$dev2" "$dev3"
 
 # Implicit count comes from #PVs given (always 2-way mirror)
+# Defaults -i2, which works with 4 PVs listed
 lvcreate --type raid10 -l2 -an -Zn -n raid10 $vg "$dev1" "$dev2" "$dev3" "$dev4"
 lv_devices $vg raid10 4
-lvremove -ff $vg
 
-# Implicit count comes from total #PVs in VG (always 2 for mirror though)
-lvcreate --type raid10 -l2 -an -Zn -n raid10 $vg
-lv_devices $vg raid10 6
+# Defaults -i2 even though more PVs listed
+lvcreate --type raid10 -l2 -an -Zn -n raid10_6 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+lv_devices $vg raid10_6 4
+
 lvremove -ff $vg
 
 #
 # FIXME: Add tests that specify particular PVs to use for creation
 #
+
+
+########################################################
+# Try again with backward compatible old logic applied #
+########################################################
+aux lvmconf 'allocation/raid_stripe_all_devices = 1'
+
+# Implicit count comes from #PVs given (always 2-way mirror)
+lvcreate --type raid10 -l2 -an -Zn -n raid10 $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lv_devices $vg raid10 4
+
+# Implicit count comes from total #PVs in VG (always 2 for mirror though)
+lvcreate --type raid10 -l2 -an -Zn -n raid10_vg $vg
+lv_devices $vg raid10_vg 6
+
 vgremove -ff $vg


