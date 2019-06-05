From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 5 Jun 2019 09:57:47 -0400
Subject: stable-2.02 - tests: check no_discard_passdown
Message-ID: <201906051357.x55DvlHh028646@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb7766bc1411c3350e79241122a974dac7fcc902
Commit:        cb7766bc1411c3350e79241122a974dac7fcc902
Parent:        1308572a8754f1f5f614218dc08d15f1b562fb0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 15:46:43 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 5 15:54:59 2019 +0200

tests: check no_discard_passdown

Check reporting works
---
 test/shell/cache-no-discard.sh |   45 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/test/shell/cache-no-discard.sh b/test/shell/cache-no-discard.sh
new file mode 100644
index 0000000..3ab0594
--- /dev/null
+++ b/test/shell/cache-no-discard.sh
@@ -0,0 +1,45 @@
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
+# Check reporting of no_discard_passdown
+
+SKIP_WITH_LVMPOLLD=1
+
+# Until new version of cache_check tools - no integrity validation
+LVM_TEST_CACHE_CHECK_CMD=""
+
+. lib/inittest
+
+aux kernel_at_least 5 1 || skip
+
+aux have_cache 2 0
+
+aux prepare_vg 1
+
+# Create thinLV without discard
+lvcreate --discards=ignore -T -V20 -L20 -n $lv $vg/pool
+
+aux extend_filter_LVMTEST
+
+# Use discard-less LV as PV for $vg1
+pvcreate "$DM_DEV_DIR/$vg/$lv"
+vgcreate -s 128K $vg1 "$DM_DEV_DIR/$vg/$lv"
+
+# Create simple cache LV
+lvcreate -L2 -n $lv1 $vg1
+lvcreate -H -L2 $vg1/$lv1
+
+#lvs -ao+kernel_discards $vg1
+check lv_field $vg1/$lv1 kernel_discards "nopassdown"
+
+vgremove -f $vg1
+vgremove -f $vg


