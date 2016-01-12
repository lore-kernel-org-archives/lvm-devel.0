From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 Jan 2016 10:42:51 +0000 (UTC)
Subject: master - test: add test for autoactivation regression
Message-ID: <20160112104251.064D760B3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d09246a07d3e4d9940cdbbd017b1bc8319384081
Commit:        d09246a07d3e4d9940cdbbd017b1bc8319384081
Parent:        40701af9696a302c904fad30951385eb5a5adb85
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Jan 7 15:30:22 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Jan 12 11:40:43 2016 +0100

test: add test for autoactivation regression

add test for a regression fixed in
40701af9696a302c904fad30951385eb5a5adb85
---
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |   70 ++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
new file mode 100644
index 0000000..f7ea912
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -0,0 +1,70 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+SKIP_WITHOUT_LVMETAD=1
+
+. lib/inittest
+
+which mkfs.ext3 || skip
+
+lvdev_() {
+    echo "$DM_DEV_DIR/$1/$2"
+}
+
+snap_lv_name_() {
+    echo ${1}_snap
+}
+
+setup_merge_() {
+    local VG_NAME=$1
+    local LV_NAME=$2
+    local NUM_EXTRA_SNAPS=${3:-0}
+    local BASE_SNAP_LV_NAME
+
+    BASE_SNAP_LV_NAME=$(snap_lv_name_ $LV_NAME)
+
+    lvcreate -aey -n $LV_NAME -l 50%FREE $VG_NAME
+    lvs
+    lvcreate -s -n $BASE_SNAP_LV_NAME -l 20%FREE ${VG_NAME}/${LV_NAME}
+    mkfs.ext3 "$(lvdev_ $VG_NAME $LV_NAME)"
+
+    if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
+	for i in $(seq 1 $NUM_EXTRA_SNAPS); do
+	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%ORIGIN ${VG_NAME}/${LV_NAME}
+	done
+    fi
+}
+
+aux prepare_pvs 1 50
+
+vgcreate $vg1 "$dev1"
+mkdir test_mnt
+
+setup_merge_ $vg1 $lv1
+mount "$(lvdev_ $vg1 $lv1)" test_mnt
+lvconvert --merge $vg1/$(snap_lv_name_ $lv1)
+umount test_mnt
+vgchange -an $vg1
+
+# check snapshot get removed on autoactivation
+pvscan --cache -aay "$dev1"
+
+check active $vg1 $lv1
+i=100
+while ! check lv_not_exists $vg1/$(snap_lv_name_ $lv1); do
+	test $i -lt 0 && fail "Background polling failed to remove merged snapshot LV"
+	sleep .1
+	i=$((i-1))
+done
+
+# TODO: add similar simple tests for other interrupted/unfinished polling operation
+
+vgremove -ff $vg1


