From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:07 +0100
Subject: [PATCH 6/6] tests: lvconvert external origin
In-Reply-To: <cover.1360072297.git.zkabelac@redhat.com>
References: <cover.1360072297.git.zkabelac@redhat.com>
Message-ID: <f3f6b4388426aa809b453127cdd4626588d2d7ef.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/shell/lvconvert-thin-external.sh | 82 +++++++++++++++++++++++++++++++++++
 1 file changed, 82 insertions(+)
 create mode 100644 test/shell/lvconvert-thin-external.sh

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
new file mode 100644
index 0000000..06fc731
--- /dev/null
+++ b/test/shell/lvconvert-thin-external.sh
@@ -0,0 +1,82 @@
+#!/bin/sh
+
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# test thin external origin behavior
+
+. lib/test
+
+#
+# Main
+#
+aux have_thin 1 5 0 || skip
+
+aux prepare_pvs 2 64
+
+vgcreate $vg -s 64K $(cat DEVICES)
+
+# create thin pool
+lvcreate -L8M -T $vg/pool
+
+# create plain LV
+lvcreate -L8M -n $lv1 $vg
+
+mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
+mkdir mnt
+mount $DM_DEV_DIR/$vg/$lv1 mnt
+
+dd if=/dev/zero of=mnt/test1 bs=1M count=1
+
+# convert plain LV into thin external snapshot volume
+# during conversion dd above could be still flushed
+
+lvconvert -T --originname extorg --thinpool $vg/pool $vg/$lv1
+
+check active $vg $lv1
+check inactive $vg extorg
+
+touch mnt/test
+umount mnt
+
+fsck $DM_DEV_DIR/$vg/$lv1
+
+lvchange -ay $vg/extorg
+lvchange -an $vg/$lv1
+
+check active $vg extorg
+check inactive $vg $lv1
+
+# fsck in read-only mode
+fsck -n $DM_DEV_DIR/$vg/extorg
+
+not lvresize -l+8 $vg/extorg
+not lvresize -l-4 $vg/extorg
+not lvchange -p rw $vg/extorg
+
+lvresize -L+8M $vg/$lv1
+lvresize -L-4M $vg/$lv1
+lvchange -p r $vg/$lv1
+lvchange -p rw $vg/$lv1
+
+lvconvert --originname extorg1 --thinpool $vg/pool -T $vg/extorg
+lvconvert --originname extorglv1 --thinpool $vg/pool -T $vg/extorg1
+
+lvcreate -l10 -s $vg/$lv1
+
+# Remove all volumes dependent on external origin
+lvremove -f $vg/extorglv1
+
+#lvs -a -o+origin_size,seg_size $vg
+
+# Only pool is left
+check vg_field $vg lv_count 1
+
+vgremove -ff $vg
-- 
1.8.1.2


