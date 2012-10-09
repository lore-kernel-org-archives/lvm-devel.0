From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  9 Oct 2012 14:39:23 +0000 (UTC)
Subject: master - test: move raid10 test into separate test files
Message-ID: <20121009143923.2FFA5E1C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7b3179669dd82de7dab88309a9234d4cdbc6554
Commit:        d7b3179669dd82de7dab88309a9234d4cdbc6554
Parent:        93d7d3ed2c16317812e553a25babf5225471e8d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 9 13:51:30 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 9 16:38:12 2012 +0200

test: move raid10 test into separate test files

New features tested in new files.
---
 test/shell/lvcreate-raid.sh   |   25 +---------------------
 test/shell/lvcreate-raid10.sh |   42 +++++++++++++++++++++++++++++++++++++
 test/shell/lvresize-raid.sh   |   33 -----------------------------
 test/shell/lvresize-raid10.sh |   46 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 89 insertions(+), 57 deletions(-)

diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 81e5a5d..05c7428 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -47,26 +47,3 @@ for i in raid4 \
 	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
-
-#
-# Create RAID10:
-#
-
-aux target_at_least dm-raid 1 3 0 || skip
-
-# Should not allow more than 2-way mirror
-not lvcreate --type raid10 -m 2 -i 2 -l 2 -n $lv1 $vg
-
-# 2-way mirror, 2-stripes
-lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
-lvremove -ff $vg
-
-# 2-way mirror, 3-stripes
-lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
-lvremove -ff $vg
-
-#
-# FIXME: Add tests that specify particular PVs to use for creation
-#
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
new file mode 100644
index 0000000..63d086f
--- /dev/null
+++ b/test/shell/lvcreate-raid10.sh
@@ -0,0 +1,42 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+########################################################
+# MAIN
+########################################################
+aux target_at_least dm-raid 1 3 0 || skip
+
+aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
+vgcreate -c n -s 512k $vg $(cat DEVICES)
+
+#
+# Create RAID10:
+#
+
+
+# Should not allow more than 2-way mirror
+not lvcreate --type raid10 -m 2 -i 2 -l 2 -n $lv1 $vg
+
+# 2-way mirror, 2-stripes
+lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvremove -ff $vg
+
+# 2-way mirror, 3-stripes
+lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
+aux wait_for_sync $vg $lv1
+lvremove -ff $vg
+
+#
+# FIXME: Add tests that specify particular PVs to use for creation
+#
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 08382a5..f999a31 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -78,36 +78,3 @@ for i in 4 5 6 ; do
 		lvremove -ff $vg
 	done
 done
-
-aux target_at_least dm-raid 1 3 0 || skip
-
-# Extend RAID10 (2-stripes, 2-mirror)
-for deactivate in true false; do
-	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
-
-	if $deactivate; then
-		lvchange -an $vg/$lv1
-	fi
-
-	lvresize -l +2 $vg/$lv1
-
-	#check raid_images_contiguous $vg $lv1
-
-	lvremove -ff $vg
-done
-
-# Reduce RAID10 (2-stripes, 2-mirror)
-for deactivate in true false; do
-	lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg
-
-	if $deactivate; then
-		lvchange -an $vg/$lv1
-	fi
-
-	should lvresize -y -l -2 $vg/$lv1
-
-	#check raid_images_contiguous $vg $lv1
-
-	lvremove -ff $vg
-done
-
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
new file mode 100644
index 0000000..9b71708
--- /dev/null
+++ b/test/shell/lvresize-raid10.sh
@@ -0,0 +1,46 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux target_at_least dm-raid 1 3 0 || skip
+
+aux prepare_vg 5 80
+
+# Extend RAID10 (2-stripes, 2-mirror)
+for deactivate in true false; do
+	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
+
+	if $deactivate; then
+		lvchange -an $vg/$lv1
+	fi
+
+	lvresize -l +2 $vg/$lv1
+
+	#check raid_images_contiguous $vg $lv1
+
+	lvremove -ff $vg
+done
+
+# Reduce RAID10 (2-stripes, 2-mirror)
+for deactivate in true false; do
+	lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg
+
+	if $deactivate; then
+		lvchange -an $vg/$lv1
+	fi
+
+	should lvresize -y -l -2 $vg/$lv1
+
+	#check raid_images_contiguous $vg $lv1
+
+	lvremove -ff $vg
+done


