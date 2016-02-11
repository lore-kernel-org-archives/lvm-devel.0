From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:40:00 +0000 (UTC)
Subject: master - tests: check for automated dmeventd resize
Message-ID: <20160211174000.E305960DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba111e7f4a9481b2b419bd0f402dd0926ac1b0e9
Commit:        ba111e7f4a9481b2b419bd0f402dd0926ac1b0e9
Parent:        53058e523411d7ef09d9a934a48764fa9ad22b72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 11 18:05:58 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:38:40 2016 +0100

tests: check for automated dmeventd resize

Watermark support should handle relatively quickly data LV resizes.
So check if it does what is expected.
---
 test/shell/lvextend-thin-data-dmeventd.sh |   62 +++++++++++++++++++++++++++++
 1 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-thin-data-dmeventd.sh b/test/shell/lvextend-thin-data-dmeventd.sh
new file mode 100644
index 0000000..03bd23d
--- /dev/null
+++ b/test/shell/lvextend-thin-data-dmeventd.sh
@@ -0,0 +1,62 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test autoextension of thin data volume
+
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+# As we check for 'instant' reaction
+# retry only few times
+test_equal_() {
+	for i in $(seq 1 4) ; do
+		test "$(get lv_field $vg/pool data_percent)" = "$1" || return
+		sleep 1
+	done
+}
+
+aux have_thin 1 10 0 || skip
+
+aux prepare_dmeventd
+
+aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
+	    "activation/thin_pool_autoextend_threshold = 75"
+
+aux prepare_pvs 3 256
+
+vgcreate -s 256K $vg $(cat DEVICES)
+
+lvcreate -L1M -c 64k -T $vg/pool
+lvcreate -V1M $vg/pool -n $lv1
+
+# Fill exactly 75%
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv1" bs=786432c count=1 conv=fdatasync
+
+# when everything calcs correctly thin-pool should be exactly 75% full now
+# and the size should not have changed
+pre="75.00"
+test_equal_ $pre || die "Data percentage has changed!"
+
+
+# Now triger allocation of 1 extra pool chunk
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv1" bs=1c count=1 seek=786433 conv=fdatasync
+
+lvs -a -o+chunksize $vg
+dmsetup table
+dmsetup status
+
+# If the watermark works well - dmeventd should have already resized data LV
+test_equal_ $pre && die "Data percentage has NOT changed!"
+
+vgremove -f $vg


