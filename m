From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  9 Oct 2012 14:39:25 +0000 (UTC)
Subject: master - test: more thin tests
Message-ID: <20121009143925.98751E1C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=439989adab473b2fa867b1e492b205084471051a
Commit:        439989adab473b2fa867b1e492b205084471051a
Parent:        d7b3179669dd82de7dab88309a9234d4cdbc6554
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 9 16:32:11 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 9 16:38:42 2012 +0200

test: more thin tests

---
 test/shell/discards-thin.sh      |   56 +++++++++++++++++++++++++++++++++
 test/shell/lvconvert-thin.sh     |   49 +++++++++++++++++++++++++++++
 test/shell/lvcreate-thin-snap.sh |   63 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 168 insertions(+), 0 deletions(-)

diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
new file mode 100644
index 0000000..28300d9
--- /dev/null
+++ b/test/shell/discards-thin.sh
@@ -0,0 +1,56 @@
+#!/bin/sh
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# test support of thin discards
+#
+
+. lib/test
+
+#
+# Main
+#
+aux target_at_least dm-thin-pool 1 1 0 || skip
+
+aux prepare_pvs 2 64
+
+# disable thin_check if not present in system
+which thin_check || aux lvmconf 'global/thin_check_executable = ""'
+
+clustered=
+test -e LOCAL_CLVMD && clustered="--clustered y"
+
+vgcreate $clustered $vg -s 64K $(cat DEVICES)
+
+# Create named pool only
+lvcreate -l1 --discards ignore -T $vg/pool
+check lv_field $vg/pool discards "ignore"
+lvcreate -l1 --discards nopassdown -T $vg/pool1
+check lv_field $vg/pool1 discards "nopassdown"
+lvcreate -l1 --discards passdown -T $vg/pool2
+check lv_field $vg/pool2 discards "passdown"
+
+lvchange --discards nopassdown $vg/pool2
+
+# cannot convert active  ignore -> passdown
+not lvchange --discards passdown $vg/pool
+
+# cannot convert active  nopassdown -> ignore
+not lvchange --discards ignore $vg/pool1
+
+# deactivate
+lvchange -an $vg/pool $vg/pool1
+lvchange --discards passdown $vg/pool
+check lv_field $vg/pool discards "passdown"
+lvchange --discards ignore $vg/pool1
+check lv_field $vg/pool1 discards "ignore"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
new file mode 100644
index 0000000..3ad3248
--- /dev/null
+++ b/test/shell/lvconvert-thin.sh
@@ -0,0 +1,49 @@
+#!/bin/sh
+
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
+#
+# Main
+#
+aux target_at_least dm-thin-pool 1 0 0 || skip
+
+aux prepare_pvs 4 64
+
+# disable thin_check if not present in system
+which thin_check || aux lvmconf 'global/thin_check_executable = ""'
+
+clustered=
+test -e LOCAL_CLVMD && clustered="--clustered y"
+
+vgcreate $clustered $vg -s 64K $(cat DEVICES)
+
+# create mirrored LVs for data and metadata volumes
+lvcreate -l8 -m1 --mirrorlog core -n $lv1 $vg
+lvcreate -l4 -m1 --mirrorlog core -n $lv2 $vg
+
+lvconvert -c 64K --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+
+lvcreate -V10M -T $vg/$lv1 --name $lv3
+
+# check lvrename work properly
+lvrename $vg/$lv1  $vg/pool
+check lv_field $vg/pool name "pool"
+
+lvrename $vg/$lv3  $vg/$lv4
+check lv_field $vg/$lv4 name "$lv4"
+
+# not yet supported conversions
+not lvconvert -m 1 $vg/pool
+not lvconvert -m 1 $vg/$lv3
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
new file mode 100644
index 0000000..0e91222
--- /dev/null
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -0,0 +1,63 @@
+#!/bin/sh
+
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
+check_lv_field_modules_()
+{
+	mod=$1
+	shift
+
+	for d in $*; do
+		check lv_field $vg/$d modules $mod
+	done
+}
+
+
+#
+# Main
+#
+aux target_at_least dm-thin-pool 1 0 0 || skip
+
+aux prepare_pvs 2 64
+
+# disable thin_check if not present in system
+which thin_check || aux lvmconf 'global/thin_check_executable = ""'
+
+clustered=
+test -e LOCAL_CLVMD && clustered="--clustered y"
+
+vgcreate $clustered $vg -s 64K $(cat DEVICES)
+
+lvcreate -L10M -V10M -T $vg/pool --name $lv1
+mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
+# create thin snapshot of thin LV
+lvcreate -s $vg/$lv1
+# check snapshot filesystem was properly frozen before snapping
+fsck -p $DM_DEV_DIR/$vg/lvol0
+lvcreate -s $vg/$lv1 --name $lv2
+lvcreate -s $vg/$lv1 --name $vg/$lv3
+lvcreate --type snapshot $vg/$lv1
+lvcreate --type snapshot $vg/$lv1 --name $lv4
+lvcreate --type snapshot $vg/$lv1 --name $vg/$lv5
+
+# create old-style snapshot
+lvcreate -s -L10M --name oldsnap1 $vg/$lv2
+lvcreate -s -L10M --name oldsnap2 $vg/$lv2
+
+# thin snap of snap of snap...
+lvcreate -s --name sn1 $vg/$lv2
+lvcreate -s --name sn2 $vg/sn1
+lvcreate -s --name sn3 $vg/sn2
+lvcreate -s --name sn4 $vg/sn3
+
+vgremove -ff $vg


