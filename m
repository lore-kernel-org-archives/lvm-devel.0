From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Sep 2015 18:20:44 +0000 (UTC)
Subject: master - tests: lvextend of full thin pool
Message-ID: <20150914182044.4B07D60CF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7e15631ddd9150fa7643ae2debac797dabc5d25
Commit:        e7e15631ddd9150fa7643ae2debac797dabc5d25
Parent:        ffeeb5c1e70e554defa45ee8aa28dcaeb47c705f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 20:09:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 20:18:54 2015 +0200

tests: lvextend of full thin pool

---
 test/shell/lvextend-thin-full.sh |   79 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
new file mode 100644
index 0000000..6b1b9e0
--- /dev/null
+++ b/test/shell/lvextend-thin-full.sh
@@ -0,0 +1,79 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# play with thin-pool resize in corner cases
+#
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+test -e LOCAL_LVMPOLLD && skip
+
+aux have_thin 1 0 0 || skip
+
+test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
+"$LVM_TEST_THIN_RESTORE_CMD" -V || skip
+
+#
+# Temporary solution to create some occupied thin metadata
+# This heavily depends on thin metadata output format to stay as is.
+# Currently it expects 2MB thin metadata and 200MB data volume size
+# Argument specifies how many devices should be created.
+fake_metadata_() {
+	echo '<superblock uuid="" time="1" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
+	for i in $(seq 1 $1)
+	do
+		echo ' <device dev_id="'$i'" mapped_blocks="37" transaction="0" creation_time="0" snap_time="1">'
+		echo '  <range_mapping origin_begin="0" data_begin="0" length="37" time="0"/>'
+		echo ' </device>'
+	done
+	echo "</superblock>"
+}
+
+aux have_thin 1 10 0 || skip
+
+aux prepare_pvs 3 256
+
+vgcreate -s 1M $vg $(cat DEVICES)
+
+aux lvmconf 'activation/thin_pool_autoextend_percent = 30' \
+	    'activation/thin_pool_autoextend_threshold = 70'
+
+fake_metadata_ 400 0 >data
+lvcreate -L200 -T $vg/pool
+lvchange -an $vg
+
+lvcreate -L2M -n $lv1 $vg
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+
+# Cannot resize if set to 0%
+not lvextend --use-policies --config 'activation{thin_pool_autoextend_percent = 0}' $vg/pool 2>&1 | tee err
+grep "0%" err
+
+# Locally active LV is needed
+not lvextend --use-policies $vg/pool 2>&1 | tee err
+grep "locally" err
+
+lvchange -ay $vg
+
+# Creation of new LV is not allowed when thinpool is over threshold
+not lvcreate -V10 $vg/pool
+
+
+lvextend --use-policies $vg/pool "$dev2" "$dev3"
+#should lvextend -l+100%FREE $vg/pool2
+
+lvs -a $vg
+
+vgremove -ff $vg


