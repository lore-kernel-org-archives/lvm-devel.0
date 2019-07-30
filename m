From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Jul 2019 17:15:31 -0400
Subject: stable-2.02 - tests: large-physical-sector-size
Message-ID: <201907302115.x6ULFVWS018143@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a178ad0858a9fa3fbef97b3fa5148ab432b61422
Commit:        a178ad0858a9fa3fbef97b3fa5148ab432b61422
Parent:        7550665ba49ac7d497d5b212e14b69298ef01361
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 30 15:59:11 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 30 16:12:45 2019 -0500

tests: large-physical-sector-size

---
 test/shell/large-physical-sector-size.sh |   43 ++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/test/shell/large-physical-sector-size.sh b/test/shell/large-physical-sector-size.sh
new file mode 100644
index 0000000..891f409
--- /dev/null
+++ b/test/shell/large-physical-sector-size.sh
@@ -0,0 +1,43 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+LOGICAL_BLOCK_SIZE=4096
+
+# PHYSICAL_BLOCK_SIZE is set with physblk_exp which
+# shifts the logical block size value.
+
+# 4096 << 9 = 2MB physical block size
+PHYSICAL_BLOCK_SHIFT=9
+
+aux prepare_scsi_debug_dev 256 sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=$PHYSICAL_BLOCK_SHIFT
+
+check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "$LOGICAL_BLOCK_SIZE"
+
+aux prepare_pvs 1 256
+
+get_devs
+
+vgcreate $SHARED $vg "$dev1"
+
+for i in `seq 1 40`; do lvcreate -an -l1 $vg; done;
+
+lvs $vg
+
+lvremove -y $vg
+
+vgremove $vg
+
+aux cleanup_scsi_debug_dev


